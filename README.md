# mcp-compose-bundle

[English](README.en.md)

Docker Compose로 **native HTTP / streamableHttp**
Model Context Protocol (MCP) 서버들을 한 번에 띄우는 번들입니다.
HTTP를 지원하지 않는 서버는 **로컬 stdio**로 실행하도록 샘플 설정
(`mcp.json`, `claude.json`, `config.toml`)을 제공합니다.

## :rocket: Quick Start

```sh
# Submodule 초기화 (guidelines 폴더 포함)
git submodule update --init --recursive

# 환경 변수 설정 (.env 파일 생성)
cp .env.example .env

# 서비스 시작
docker compose up -d
docker compose up -d awesome-copilot everything context7
docker compose logs -f
docker compose down
```

## :wrench: Configuration Management

이 프로젝트는 **YAML 기반의 단일 구성 관리 시스템**을 사용합니다:

- **마스터 구성 파일**: `config.yaml` (이 파일만 편집하세요)
- **생성된 파일**: `claude.json`, `mcp.json` (자동 생성됨)

### 구성 생성

```bash
# 구성 파일 생성
./scripts/generate_configs.sh
```

자세한 내용은 [scripts/README.md](scripts/README.md)를 참조하세요.

## :wrench: Prerequisites

로컬 stdio MCP 서버를 사용하기 전에 다음 패키지를 설치해야 합니다:

```sh
# MCP 서버 설치 (uv tool 사용)
uv tool install mcp-server-fetch
uv tool install mcp-server-git
uv tool install git+https://github.com/oraios/serena
```

> **Note**: `uv`는 Python 패키지 관리 도구입니다. 아직 설치하지 않았다면 먼저 설치하세요:
> macOS에서는 Homebrew를 사용해 uv를 설치할 수 있습니다:
> ```sh
> brew install uv
> ```
> 또는 공식 설치 스크립트를 사용하세요:
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

공개 호스팅되는 HTTP MCP 서버들입니다. 별도 설치 없이 HTTP URL로 직접 연결합니다:

| Service   | URL                       | Description                                        |
|-----------|---------------------------|----------------------------------------------------|
| exa       | https://mcp.exa.ai/mcp    | AI-powered web search, code search, research tools |
| grep-app  | https://mcp.grep.app      | Search code across public GitHub repositories      |

### Local stdio Servers (no Docker)

로컬 stdio 서버들은 [`mcp.json`](./mcp.json)에 설정되어 있습니다.
설치 후 직접 명령어를 실행합니다:

- **filesystem**: local file system operations (`npx -y @modelcontextprotocol/server-filesystem`)
- **git**: Git operations on your local repo (`mcp-server-git`)
- **serena**: semantic code analysis via local language servers (`serena-mcp-server`)
- **fetch**: fetches URLs from the internet (supports robots.txt bypass) (`mcp-server-fetch`)

## :wrench: Notes

### 환경 변수 설정

`.env.example`을 복사하여 `.env` 파일을 생성하고 필요한 환경 변수를 설정합니다:

```sh
cp .env.example .env
```

주요 환경 변수:
- `MCP_CONTEXT7_API_KEY`: Context7의 API key (선택사항, rate limit 증가 또는 private repo 접근용)
- `MCP_MARKITDOWN_WORKDIR_PATH`: MarkItDown에서 마운트할 로컬 디렉토리 (기본값: `$HOME/Projects`)

### JSON config에서 비활성화

`mcp.json` / `claude.json`은 JSON이라 주석 처리가 불가능합니다.
특정 서버를 끌려면 해당 서버 엔트리를 **삭제**하는 방식으로 관리하세요.
(`config.toml`은 `enabled = true/false`로 토글 가능)

### `fetch` MCP server (robots.txt bypass)

`mcp-server-fetch`는 기본적으로 robots.txt를 따릅니다.
`--ignore-robots-txt`를 `args`에 추가하면 비활성화할 수 있습니다.

- Upstream: [mcp-server-fetch][fetch-upstream]

### Serena context selection

Serena는 실행 시점에 `--context <name>`으로 toolset을 조정합니다.
가장 최신 정의/설명은 공식 문서와 context YAML을 확인하세요.

- [Serena Docs][serena-docs]
- Context YAMLs:
  - [claude-code.yml][serena-claude]
  - [ide.yml][serena-ide]
  - [codex.yml][serena-codex]

## :gear: JetBrains MCP setup

JetBrains IDE MCP(stdio)는 GitHub Copilot MCP stdio bundle jar가 필요합니다.
`command = "sh"`로 감싸 `$HOME` 기반 경로를 사용합니다.

- [MCP stdio bundle][jetbrains-bundle]

## :triangular_ruler: Client Config Samples

- VS Code: see [`mcp.json`](./mcp.json)
- Codex CLI: see [`config.toml`](./config.toml)
- Claude Code: see [`claude.json`](./claude.json)

## :card_file_box: Project Structure

```text
mcp-compose-bundle/
├── .env.example              # 환경 변수 설정 템플릿
├── .gitmodules              # Git submodule 설정
├── claude.json              # Claude Code MCP 설정
├── mcp.json                 # VS Code MCP 설정
├── config.toml              # Codex CLI MCP 설정
├── docker-compose.yaml       # Docker Compose 설정
├── .github/workflows/       # GitHub Actions (guidelines submodule 업데이트)
├── dockerfiles/             # MCP 서버 Dockerfile들
└── guidelines/              # Git submodule: 에이전트 가이드라인
```

## :memo: Architecture (high level)

```mermaid
flowchart LR
    subgraph clients["MCP Clients"]
        direction TB
        VSCode["VS Code"]
        Claude["Claude Code"]
        Codex["Codex"]
        Other["..."]

        VSCode ~~~ Claude ~~~ Codex ~~~ Other
    end

    subgraph docker["Docker Compose (native HTTP/streamableHttp)"]
        direction TB
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
        direction TB
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
