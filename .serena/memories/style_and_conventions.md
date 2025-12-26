# Style & Conventions

This repository is primarily configuration and documentation for MCP servers.

## YAML (docker-compose.yaml)

- Uses standard Docker Compose v3.8+ structure
- Common environment variables defined with anchors (`x-common-env`)
- Environment variable interpolation from `.env` file
- Services named in kebab-case: `awesome-copilot`, `context7`, `everything`, `markitdown`, `playwright`

## Dockerfiles

- Minimal Alpine/slim images for efficiency:
    - `node:24-alpine` for Node.js services (context7, everything)
    - `python:3.13-slim` for Python services (markitdown)
- Uses BuildKit cache mounts for performance:
    - `RUN --mount=type=cache,target=/root/.npm` for npm
    - `RUN --mount=type=cache,target=/root/.cache/pip` for pip
    - `RUN --mount=type=cache,target=/var/cache/apt` for apt

## Naming Conventions

- Compose service names: lowercase with hyphens (`awesome-copilot`)
- Container names: prefixed with `mcp-` (e.g., `mcp-awesome-copilot`)
- Dockerfile names: `{service}.Dockerfile` in `dockerfiles/` directory

## Configuration

- All configurable values via `.env` file (see `.env.example`)
- Port mappings follow pattern: `MCP_{SERVICE}_PORT`
- Host ports bound to `127.0.0.1` for local-only exposure
- Default timezone: `Asia/Seoul`
- Default locale: `ko_KR.UTF-8`
- Default restart policy: `unless-stopped`
- Default memory limit: `128m` per container

## Documentation

- Main docs in `README.md` with clear sections
- Client config samples live at repo root:
  - `mcp.json` (generic MCP client; uses `${env:...}` placeholders)
  - `claude.json` (Claude Code; uses `${HOME}` for paths)
  - `config.toml` (Codex CLI; MCP servers only)
- README avoids duplicating long JSON blocks; it points to the sample files instead
