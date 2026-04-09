# homebrew-troxy

Homebrew tap for [troxy](https://github.com/Peter1119/troxy) — terminal proxy inspector.

## Install

```bash
brew tap Peter1119/troxy
brew install troxy
```

## Usage

```bash
troxy start                  # Start mitmproxy with troxy addon
troxy flows -d example.com   # Query captured flows
troxy flow 42 --body         # View flow body
troxy search "token"         # Search across all flows
```

## Claude MCP

```bash
claude mcp add -e TROXY_DB=~/.troxy/flows.db -s user troxy -- troxy-mcp
```
