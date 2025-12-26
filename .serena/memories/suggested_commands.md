# Suggested Commands (Darwin / macOS)

## Quick Start

- Start all services: `docker compose up -d`
- Start specific services: `docker compose up -d awesome-copilot everything context7`
- View logs: `docker compose logs -f`
- Stop all services: `docker compose down`

## Setup

- Copy env template: `cp .env.example .env`
- Edit environment variables in `.env` as needed

## Validate client config samples

- JSON syntax check: `python -m json.tool mcp.json >/dev/null` (repeat for `claude.json`)
- Quick view: `sed -n '1,120p' mcp.json`

## Build / Rebuild Images

- Build all images: `docker compose build`
- Rebuild specific service: `docker compose build everything`
- Build without cache: `docker compose build --no-cache`

## Docker Services Management

- Check running containers: `docker compose ps`
- Restart a service: `docker compose restart context7`
- View service logs: `docker compose logs awesome-copilot`
- Execute command in container: `docker compose exec everything sh`

## Useful System / Repo Commands

- Git: `git status`, `git diff`, `git log --oneline --decorate -n 20`
- Files: `ls -la`, `find . -maxdepth 3 -type f`, `rg "pattern" .`
- Check ports: `lsof -i :48080`, `netstat -an | grep LISTEN`
