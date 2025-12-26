# When a Task is Done (Repo Workflow)

This repository is primarily Docker Compose configuration and Dockerfiles for MCP servers.

## After Making Changes

### If you changed docker-compose.yaml or Dockerfiles

1. Verify Compose configuration parses correctly:

   ```bash
   docker compose config
   ```

2. Build the affected services:

   ```bash
   docker compose build
   # or for specific service
   docker compose build {service-name}
   ```

3. Start services to verify they work:

   ```bash
   docker compose up -d
   ```

4. Smoke-check the services:

   ```bash
   docker compose logs -f
   ```

    - Verify expected ports are listening (48080-48084)
    - Check for no crash loops or error messages
    - Confirm services respond correctly

5. (Optional) Test HTTP endpoints:
    - awesome-copilot: `http://localhost:48080/mcp`
    - context7: `http://localhost:48082/mcp`
    - everything: `http://localhost:48081/mcp`
    - markitdown: `http://localhost:48083/mcp`
    - playwright: `http://localhost:48084/mcp`

### If you changed .env.example or README.md

- Ensure documentation stays consistent with:
    - Default ports (48080-48084)
    - Service names and descriptions
    - Environment variable names and defaults
    - Client config samples at repo root:
        - `mcp.json`
        - `claude.json`
        - `config.toml`

### If you changed client config samples

- Validate syntax:
    - `mcp.json` / `claude.json`: valid JSON
    - `config.toml`: valid TOML
- Keep placeholder semantics consistent:
    - `mcp.json` uses `${env:...}` placeholders
    - `claude.json` uses `${HOME}` for paths

## Cleanup

```bash
# Stop all services
docker compose down

# Remove volumes if needed
docker compose down -v

# Remove images if needed
docker compose down --rmi all
```
