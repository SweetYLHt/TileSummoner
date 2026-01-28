"""GDScript LSP Bridge: stdio <-> TCP bridge for Godot's built-in LSP server.

Connects Claude Code's stdio-based LSP client to Godot Editor's TCP-based
LSP server running on 127.0.0.1:6005.

Architecture:
    Claude Code (stdio) -> this bridge -> TCP:6005 -> Godot Editor LSP

Two threads handle bidirectional forwarding:
    Thread 1: stdin -> TCP  (Claude Code requests -> Godot LSP)
    Thread 2: TCP -> stdout (Godot LSP responses -> Claude Code)
"""

import sys
import socket
import threading
import json
import logging
import os
import time

# -- Configuration --
LSP_HOST = os.environ.get("GODOT_LSP_HOST", "127.0.0.1")
LSP_PORT = int(os.environ.get("GODOT_LSP_PORT", "6005"))
CONNECT_TIMEOUT = 5.0
CONNECT_RETRIES = 3
CONNECT_RETRY_DELAY = 1.0

# -- Logging (stderr only, never stdout) --
logging.basicConfig(
    stream=sys.stderr,
    level=logging.DEBUG,
    format="[GDScript-LSP-Bridge] %(levelname)s: %(message)s",
)
log = logging.getLogger("gdscript-lsp-bridge")

# -- Windows binary mode --
if sys.platform == "win32":
    import msvcrt
    msvcrt.setmode(sys.stdin.fileno(), os.O_BINARY)
    msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)


def read_lsp_message(stream):
    """Read one LSP message from a byte stream (stdin or socket file).

    LSP messages use Content-Length headers:
        Content-Length: N\\r\\n
        \\r\\n
        <N bytes of JSON-RPC body>

    Returns the raw body bytes, or None on EOF/error.
    """
    # Read headers
    content_length = -1
    while True:
        line = stream.readline()
        if not line:
            return None  # EOF
        line_str = line.decode("ascii", errors="replace").strip()
        if not line_str:
            break  # Empty line = end of headers
        if line_str.lower().startswith("content-length:"):
            try:
                content_length = int(line_str.split(":", 1)[1].strip())
            except ValueError:
                log.error("Invalid Content-Length: %s", line_str)
                return None

    if content_length < 0:
        log.error("Missing Content-Length header")
        return None

    # Read body
    body = b""
    remaining = content_length
    while remaining > 0:
        chunk = stream.read(remaining)
        if not chunk:
            return None  # EOF
        body += chunk
        remaining -= len(chunk)

    return body


def write_lsp_message(stream, body_bytes):
    """Write one LSP message to a byte stream (stdout or socket file).

    Prepends Content-Length header and double CRLF separator.
    """
    header = f"Content-Length: {len(body_bytes)}\r\n\r\n".encode("ascii")
    stream.write(header + body_bytes)
    stream.flush()


def log_message_summary(direction, body_bytes):
    """Log a brief summary of an LSP message for debugging."""
    try:
        msg = json.loads(body_bytes)
        method = msg.get("method", "")
        msg_id = msg.get("id", "")
        if method:
            log.debug("%s method=%s id=%s", direction, method, msg_id)
        elif "result" in msg or "error" in msg:
            log.debug("%s response id=%s", direction, msg_id)
        else:
            log.debug("%s unknown message", direction)
    except (json.JSONDecodeError, UnicodeDecodeError):
        log.debug("%s (unparseable, %d bytes)", direction, len(body_bytes))


def forward_stdin_to_tcp(stdin_stream, tcp_wfile, shutdown_event):
    """Thread: read LSP messages from stdin, forward to TCP socket."""
    log.info("stdin->TCP forwarder started")
    try:
        while not shutdown_event.is_set():
            body = read_lsp_message(stdin_stream)
            if body is None:
                log.info("stdin EOF, shutting down")
                shutdown_event.set()
                break
            log_message_summary("-->", body)
            write_lsp_message(tcp_wfile, body)
    except (OSError, BrokenPipeError) as e:
        log.error("stdin->TCP error: %s", e)
        shutdown_event.set()
    log.info("stdin->TCP forwarder stopped")


def forward_tcp_to_stdout(tcp_rfile, stdout_stream, shutdown_event):
    """Thread: read LSP messages from TCP socket, forward to stdout."""
    log.info("TCP->stdout forwarder started")
    try:
        while not shutdown_event.is_set():
            body = read_lsp_message(tcp_rfile)
            if body is None:
                log.info("TCP EOF, shutting down")
                shutdown_event.set()
                break
            log_message_summary("<--", body)
            write_lsp_message(stdout_stream, body)
    except (OSError, BrokenPipeError) as e:
        log.error("TCP->stdout error: %s", e)
        shutdown_event.set()
    log.info("TCP->stdout forwarder stopped")


def connect_to_godot_lsp():
    """Connect to Godot's LSP server with retries.

    Returns a connected socket, or exits with code 1 on failure.
    """
    for attempt in range(1, CONNECT_RETRIES + 1):
        try:
            log.info(
                "Connecting to Godot LSP at %s:%d (attempt %d/%d)",
                LSP_HOST, LSP_PORT, attempt, CONNECT_RETRIES,
            )
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(CONNECT_TIMEOUT)
            sock.connect((LSP_HOST, LSP_PORT))
            sock.settimeout(None)  # blocking mode after connect
            log.info("Connected to Godot LSP")
            return sock
        except (socket.timeout, ConnectionRefusedError, OSError) as e:
            log.warning("Connection attempt %d failed: %s", attempt, e)
            if attempt < CONNECT_RETRIES:
                time.sleep(CONNECT_RETRY_DELAY)

    log.error(
        "Failed to connect to Godot LSP at %s:%d after %d attempts. "
        "Is the Godot Editor running with LSP enabled (port %d)?",
        LSP_HOST, LSP_PORT, CONNECT_RETRIES, LSP_PORT,
    )
    sys.exit(1)


def main():
    log.info("GDScript LSP Bridge starting")
    log.info("Target: %s:%d", LSP_HOST, LSP_PORT)

    sock = connect_to_godot_lsp()
    tcp_rfile = sock.makefile("rb")
    tcp_wfile = sock.makefile("wb")
    stdin_stream = sys.stdin.buffer
    stdout_stream = sys.stdout.buffer

    shutdown_event = threading.Event()

    t_in = threading.Thread(
        target=forward_stdin_to_tcp,
        args=(stdin_stream, tcp_wfile, shutdown_event),
        daemon=True,
        name="stdin-to-tcp",
    )
    t_out = threading.Thread(
        target=forward_tcp_to_stdout,
        args=(tcp_rfile, stdout_stream, shutdown_event),
        daemon=True,
        name="tcp-to-stdout",
    )

    t_in.start()
    t_out.start()

    # Wait for either thread to signal shutdown
    try:
        shutdown_event.wait()
    except KeyboardInterrupt:
        log.info("Interrupted by user")
        shutdown_event.set()

    # Cleanup
    log.info("Shutting down bridge")
    try:
        sock.shutdown(socket.SHUT_RDWR)
    except OSError:
        pass
    sock.close()

    # Give threads a moment to finish
    t_in.join(timeout=2.0)
    t_out.join(timeout=2.0)

    log.info("GDScript LSP Bridge stopped")


if __name__ == "__main__":
    main()
