# mcp-compose-bundle - Project Overview

## Purpose

Docker Compose setup for running **native HTTP / streamableHttp** Model Context Protocol (MCP) servers.
Servers that do **not** natively support HTTP/streamableHttp are configured to run **locally via stdio** (no Docker).

## Architecture

### Docker Services (HTTP/streamableHttp)

- **awesome-copilot** (port 48080): Meta prompts for discovering GitHub Copilot chat modes, collections, and agents
- **context7** (port 48082): Fetches up-to-date library documentation from Context7
- **everything** (port 48081): MCP test server demonstrating MCP protocol features
- **markitdown** (port 48083): Converts documents (PDF, images, Office, etc.) to Markdown
- **playwright** (port 48084): Browser automation for web testing and scraping

### Local stdio Servers (no Docker)

Local stdio servers are configured in the repo-root [`mcp.json`](../../mcp.json).
Typical examples include `filesystem`, `git`, and `serena`.

#### Why git & serena run locally

- **git** needs access to per-user credentials/SSH/config and a specific repo context
- **serena** depends on per-project config (e.g., `serena.yaml`) and local language servers

## Client config samples (repo root)

- [`mcp.json`](../../mcp.json): generic MCP client sample (uses `${env:...}` placeholders)
- [`claude.json`](../../claude.json): Claude Code MCP config sample (uses `${HOME}` for paths)
- [`config.toml`](../../config.toml): Codex CLI config sample (MCP servers only)

## Project Structure

```text
mcp-compose-bundle/
├── .env.example                        # Environment variables template
├── claude.json                         # Claude Code MCP configuration example
├── config.toml                         # Codex CLI config example (MCP servers only)
├── mcp.json                            # Generic MCP client config example
├── docker-compose.yaml                 # Main compose configuration
├── dockerfiles/
│   ├── context7.Dockerfile             # Context7 MCP server
│   ├── everything.Dockerfile           # Everything MCP server
│   └── markitdown-mcp.Dockerfile       # Markitdown MCP server
└── README.md                           # Documentation
```

## Environment Variables

- `MCP_LANG`: Locale for all containers (default: `ko_KR.UTF-8`)
- `MCP_TZ`: Timezone for all containers (default: `Asia/Seoul`)
- `MCP_AWESOME_COPILOT_PORT`: Port for awesome-copilot (default: `48080`)
- `MCP_CONTEXT7_PORT`: Port for context7 (default: `48082`)
- `MCP_CONTEXT7_API_KEY`: Optional API key for higher rate limits
- `MCP_EVERYTHING_PORT`: Port for everything (default: `48081`)
- `MCP_MARKITDOWN_PORT`: Port for markitdown (default: `48083`)
- `MCP_MARKITDOWN_WORKDIR_PATH`: Directory mounted in markitdown (default: `${HOME}/Projects`)
- `MCP_PLAYWRIGHT_PORT`: Port for playwright (default: `48084`)

## Default Settings

- Timezone: `Asia/Seoul`
- Locale: `ko_KR.UTF-8`
- Restart Policy: `unless-stopped`
- Memory Limit: `128m` per container

## Docker Images Used

- `ghcr.io/microsoft/mcp-dotnet-samples/awesome-copilot`: Awesome Copilot (native HTTP)
- `mcr.microsoft.com/playwright/mcp`: Playwright MCP server
- `node:24-alpine`: Base for context7, everything
- `python:3.13-slim`: Base for markitdown
