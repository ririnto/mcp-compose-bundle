# mcp-compose-bundle

[한국어](README.md)

A Docker Compose bundle to run **native HTTP / streamableHttp**
Model Context Protocol (MCP) servers.
Servers that don't natively support HTTP/streamableHttp are configured
to run **locally via stdio** (no Docker) via sample configs
(`mcp.json`, `claude.json`, `config.toml`).

## :rocket: Quick Start

```sh
# Initialize submodule (includes guidelines folder)
git submodule update --init --recursive

# Set up environment variables (create .env file)
cp .env.example .env

# Start services
docker compose up -d
docker compose up -d awesome-copilot everything context7
docker compose logs -f
docker compose down
```

## :wrench: Prerequisites

Before using local stdio MCP servers, install the following packages:

```sh
# Install MCP servers (using uv tool)
uv tool install mcp-server-fetch
uv tool install mcp-server-git
uv tool install git+https://github.com/oraios/serena
```

> **Note**: `uv` is a Python package manager. If not installed, install it first:
> On macOS, you can install uv using Homebrew:
> ```sh
> brew install uv
> ```
> Or use the official installer:
> ```sh
> curl -LsSf https://astral.sh/uv/install.sh | sh
> ```

## :package: Included MCP Servers

### Docker Services (HTTP/streamableHttp)

| Service         | Port  | Description                            |
|-----------------|-------|----------------------------------------|
| awesome-copilot | 48080 | Copilot chat modes, collections        |
| context7        | 48082 | Library docs from Context7             |
| markitdown      | 48083 | Converts docs to Markdown              |
| playwright      | 48084 | Browser automation                     |

### Public HTTP Servers (Hosted)

Publicly hosted HTTP MCP servers. Connect directly via HTTP URL without installation:

| Service   | URL                       | Description                                        |
|-----------|---------------------------|----------------------------------------------------|
| exa       | https://mcp.exa.ai/mcp    | AI-powered web search, code search, research tools |
| grep-app  | https://mcp.grep.app      | Search code across public GitHub repositories      |

### Local stdio Servers (no Docker)

Local stdio servers are configured in [`mcp.json`](./mcp.json). After installation, they execute directly:

- **filesystem**: local file system operations (`npx -y @modelcontextprotocol/server-filesystem`)
- **git**: Git operations on your local repo (`mcp-server-git`)
- **serena**: semantic code analysis via local language servers (`serena-mcp-server`)
- **fetch**: fetches URLs from the internet (supports robots.txt bypass) (`mcp-server-fetch`)

## :wrench: Notes

### Environment Variables

Copy `.env.example` to `.env` and customize as needed:

```sh
cp .env.example .env
```

Key environment variables:
- `MCP_CONTEXT7_API_KEY`: Context7 API key (optional, for higher rate limits or private repo access)
- `MCP_MARKITDOWN_WORKDIR_PATH`: Local directory path to mount in MarkItDown (default: `$HOME/Projects`)

### Disabling servers in JSON configs

`mcp.json` / `claude.json` are JSON, so you can’t comment out entries.
To disable a server, remove its server entry from the file.
(For Codex `config.toml`, you can use `enabled = true/false`.)

### `fetch` MCP server (robots.txt bypass)

`mcp-server-fetch` obeys robots.txt by default.
You can disable this behavior by adding `--ignore-robots-txt` to the `args` list.

- Upstream: [mcp-server-fetch][fetch-upstream]

### Serena context selection

Serena adjusts its toolset at startup with `--context <name>`.
For the most up-to-date definitions,
check the official docs and the actual context YAMLs.

- [Serena Docs][serena-docs]
- Context YAMLs:
  - [claude-code.yml][serena-claude]
  - [ide.yml][serena-ide]
  - [codex.yml][serena-codex]

## :gear: JetBrains MCP setup

JetBrains IDE MCP(stdio) requires the GitHub Copilot MCP stdio bundle jar.
This repo wraps the command with `command = "sh"` and uses a `$HOME`-based
jar path so the jar filename/version can change.

- [MCP stdio bundle][jetbrains-bundle]

## :triangular_ruler: Client Config Samples

- VS Code: see [`mcp.json`](./mcp.json)
- Codex CLI: see [`config.toml`](./config.toml)
- Claude Code: see [`claude.json`](./claude.json)

## :card_file_box: Project Structure

```text
mcp-compose-bundle/
├── .env.example              # Environment variables template
├── .gitmodules              # Git submodule configuration
├── claude.json              # Claude Code MCP config
├── mcp.json                 # VS Code MCP config
├── config.toml              # Codex CLI MCP config
├── docker-compose.yaml       # Docker Compose configuration
├── .github/workflows/       # GitHub Actions (guidelines submodule update)
├── dockerfiles/             # MCP server Dockerfiles
└── guidelines/              # Git submodule: agent guidelines
```

## :memo: Architecture (high level)

```mermaid
flowchart TB
    subgraph clients["MCP Clients"]
        direction LR
        VSCode["VS Code"]
        Claude["Claude Code"]
        Codex["Codex"]
        Other["..."]

        VSCode ~~~ Claude ~~~ Codex ~~~ Other
    end

    subgraph docker["Docker Compose (native HTTP/streamableHttp)"]
        direction LR
        subgraph c7_container["context7"]
            C7["context7-mcp"]
        end

        subgraph pw_container["playwright"]
            PW["playwright-mcp"]
        end

        subgraph md_container["markitdown"]
            MD["markitdown-mcp"]
        end

        subgraph ac_container["awesome-copilot"]
            AC["awesome-copilot"]
        end

        subgraph ev_container["everything"]
            EV["mcp-server-everything"]
        end
    end

    clients -->|:48082 → :3000| C7
    clients -->|:48084 → :48084| PW
    clients -->|:48083 → :3001| MD
    clients -->|:48080 → :8080| AC
    subgraph local["Local stdio MCP servers"]
        direction LR
        CDP["chrome-devtools-mcp"]
        Fetch["fetch (--ignore-robots-txt)"]
        RG["ripgrep"]
        Memory["memory"]
        Seq["sequential-thinking"]
        FS["filesystem"]
        Git["git"]
        JetBrains["jetbrains"]
        Serena["serena"]
        CodexSrv["codex-mcp-server"]
    end

    clients -->|stdio| CDP
    clients -->|stdio| Fetch
    clients -->|stdio| RG
    clients -->|stdio| Memory
    clients -->|stdio| Seq
    clients -->|stdio| FS
    clients -->|stdio| Git
    clients -->|stdio| JetBrains
    clients -->|stdio| Serena
    clients -->|stdio| CodexSrv

    classDef clientStyle fill:#e1f5ff,stroke:#01579b,stroke-width:2px,color:#000
    classDef redStyle fill:#ffebee,stroke:#c62828,stroke-width:2px,color:#000
    classDef orangeStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000
    classDef yellowStyle fill:#fffde7,stroke:#f57f17,stroke-width:2px,color:#000
    classDef greenStyle fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px,color:#000
    classDef blueStyle fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,color:#000
    classDef indigoStyle fill:#e8eaf6,stroke:#283593,stroke-width:2px,color:#000
    classDef purpleStyle fill:#f3e5f5,stroke:#6a1b9a,stroke-width:2px,color:#000

    class VSCode,Claude,Codex,Other clientStyle
    class C7,PW,Fetch,CDP redStyle
    class MD,RG,Memory orangeStyle
    class Seq yellowStyle
    class FS greenStyle
    class Git,JetBrains blueStyle
    class Serena,CodexSrv indigoStyle
    class AC purpleStyle

    linkStyle 3,4,5,6,7 stroke:#0d47a1,stroke-width:2.5px
    linkStyle 8,9,10,11,12,13,14,15,16,17,18 stroke:#1b5e20,stroke-width:2.5px
```

> :bulb: **Port mapping**: `host:container`
> (e.g., `48080→8080` means host port 48080 maps to container port 8080).
> Only servers that are **native HTTP/streamableHttp** are kept in Docker.

### MCP Server Classification by Type

| Color  | Type          | Servers                                      |
|--------|---------------|----------------------------------------------|
| Red    | Web/Network   | Context7, Playwright, Fetch, Chrome DevTools |
| Orange | Utilities     | MarkItDown, Ripgrep, Memory                  |
| Yellow | AI/Thinking   | Sequential Thinking                          |
| Green  | File System   | Filesystem                                   |
| Blue   | Dev Tools     | Git, JetBrains                               |
| Indigo | Code Analysis | Serena, Codex MCP Server                     |
| Purple | Meta/Testing  | Awesome GitHub Copilot                     |

**Connection Type Colors**:

- **Blue arrows**: HTTP/streamableHttp (Docker)
- **Green arrows**: stdio (local)

[fetch-upstream]: https://github.com/modelcontextprotocol/servers/tree/main/src/fetch
[serena-docs]: https://oraios.github.io/serena/02-usage/050_configuration.html
[serena-claude]: https://raw.githubusercontent.com/oraios/serena/main/src/serena/resources/config/contexts/claude-code.yml
[serena-ide]: https://raw.githubusercontent.com/oraios/serena/main/src/serena/resources/config/contexts/ide.yml
[serena-codex]: https://raw.githubusercontent.com/oraios/serena/main/src/serena/resources/config/contexts/codex.yml
[jetbrains-bundle]: https://github.com/ririnto/mcpserver-stdio-bundle
