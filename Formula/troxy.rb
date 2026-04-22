class Troxy < Formula
  desc "Terminal proxy inspector — mitmproxy flows for CLI and Claude MCP"
  homepage "https://github.com/Peter1119/troxy"
  url "https://github.com/Peter1119/troxy.git", tag: "v0.4.0"
  license "MIT"
  revision 3

  depends_on "python@3.14"
  depends_on "uv"

  def install
    libexec.install Dir["*"]

    # Call the venv entry points directly (rather than `uv run ...`) so the
    # first invocation does not print uv sync noise and there is no uv-level
    # staleness check on every command.
    (bin/"troxy").write <<~SH
      #!/bin/bash
      exec "#{libexec}/.venv/bin/troxy" "$@"
    SH

    (bin/"troxy-mcp").write <<~SH
      #!/bin/bash
      exec "#{libexec}/.venv/bin/troxy-mcp" "$@"
    SH
  end

  def post_install
    # post_install runs in brew's sandbox which blocks ~/.cache/uv. Route
    # uv's cache into the prefix, and use brew's python@3.14 instead of
    # letting uv download its own managed interpreter into ~/.local/share/uv.
    uv_cache = libexec/".uv-cache"
    ENV["UV_CACHE_DIR"] = uv_cache.to_s

    cd libexec do
      system Formula["uv"].opt_bin/"uv", "sync", "--all-extras",
             "--python", Formula["python@3.14"].opt_bin/"python3.14"
    end

    # Drop the cache once the venv is realised — keeps install size minimal.
    uv_cache.rmtree if uv_cache.exist?
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
    EOS
  end

  test do
    system bin/"troxy", "status", "--no-color"
  end
end
