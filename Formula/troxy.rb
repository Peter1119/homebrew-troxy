class Troxy < Formula
  desc "Terminal proxy inspector — mitmproxy flows for CLI and Claude MCP"
  homepage "https://github.com/Peter1119/troxy"
  url "https://github.com/Peter1119/troxy.git", tag: "v0.5.7"
  license "MIT"

  depends_on "python@3.14"
  depends_on "uv"

  def install
    # Just copy the project into libexec. The venv is created lazily on the
    # first `troxy` run (see the wrapper below) — doing it here is blocked by
    # brew's install sandbox on macOS 26 (Tahoe).
    libexec.install Dir["*"]

    uv_bin = Formula["uv"].opt_bin/"uv"

    # Wrapper: if the venv hasn't been materialised yet, do it now — quietly —
    # then exec the venv's own `troxy` binary. Later runs skip straight to exec.
    (bin/"troxy").write <<~SH
      #!/bin/bash
      if [ ! -x "#{libexec}/.venv/bin/troxy" ]; then
        echo "troxy: first-run setup (creating virtualenv)..." >&2
        "#{uv_bin}" --directory "#{libexec}" sync --all-extras --quiet >/dev/null 2>&1 || {
          echo "troxy: setup failed. Try: brew reinstall peter1119/troxy/troxy" >&2
          exit 1
        }
      fi
      exec "#{libexec}/.venv/bin/troxy" "$@"
    SH

    # troxy-mcp is spawned by Claude over stdio; it must never print to stdout
    # (MCP protocol parses stdout), so the lazy-sync block stays silent.
    (bin/"troxy-mcp").write <<~SH
      #!/bin/bash
      if [ ! -x "#{libexec}/.venv/bin/troxy-mcp" ]; then
        "#{uv_bin}" --directory "#{libexec}" sync --all-extras --quiet >/dev/null 2>&1 || exit 1
      fi
      exec "#{libexec}/.venv/bin/troxy-mcp" "$@"
    SH
  end

  def caveats
    <<~EOS
      To start mitmproxy with troxy addon:
        troxy start

      Guided first-run setup (CA generate + keychain trust + device hints):
        troxy onboard

      To register MCP server for Claude Code:
        claude mcp add -e TROXY_DB=~/.troxy/flows.db -s user troxy -- troxy-mcp

      Flows are stored in ~/.troxy/flows.db by default.
      The first `troxy` invocation will create a Python virtualenv under the
      prefix (one-time, ~2s).
    EOS
  end

  test do
    system bin/"troxy", "status", "--no-color"
  end
end
