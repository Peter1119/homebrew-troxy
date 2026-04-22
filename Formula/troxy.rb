class Troxy < Formula
  desc "Terminal proxy inspector — mitmproxy flows for CLI and Claude MCP"
  homepage "https://github.com/Peter1119/troxy"
  url "https://github.com/Peter1119/troxy.git", tag: "v0.4.0"
  license "MIT"
  revision 4

  depends_on "python@3.14"
  depends_on "uv"

  def install
    system "uv", "sync", "--all-extras"
    libexec.install Dir["*"]

    (bin/"troxy").write <<~SH
      #!/bin/bash
      exec uv --directory "#{libexec}" run troxy "$@"
    SH

    (bin/"troxy-mcp").write <<~SH
      #!/bin/bash
      exec uv --directory "#{libexec}" run python -m troxy.mcp.server "$@"
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
    EOS
  end

  test do
    system bin/"troxy", "status", "--no-color"
  end
end
