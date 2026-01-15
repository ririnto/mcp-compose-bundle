#!/bin/bash
# -*- coding: utf-8 -*-
# MCP Configuration Generator
# This script generates claude.json and mcp.json from the master config.yaml file.
# Only servers with enabled=true are included in the generated files.

set -euo pipefail

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: yq is not installed. Please install yq first."
    echo "Installation options:"
    echo "  - macOS: brew install yq"
    echo "  - Linux: sudo snap install yq or sudo apt-get install yq"
    echo "  - Windows: choco install yq"
    exit 1
fi

echo "Starting MCP configuration generation..."

# Filter enabled servers and generate intermediate JSON
ENABLED_SERVERS=$(yq eval '.mcp_servers | with_entries(select(.value.enabled == true)) | with_entries(.value |= del(.enabled))' config.yaml -o=json)

# Get all servers with enabled field preserved
ALL_SERVERS=$(yq eval '.mcp_servers' config.yaml -o=json)

ENABLED_COUNT=$(echo "$ENABLED_SERVERS" | python3 -c 'import json, sys; print(len(json.load(sys.stdin)))')
ALL_COUNT=$(echo "$ALL_SERVERS" | python3 -c 'import json, sys; print(len(json.load(sys.stdin)))')

echo "Found $ENABLED_COUNT enabled servers"
echo "Found $ALL_COUNT total servers"

# Generate claude.json
echo "Generating claude.json..."
echo "$ENABLED_SERVERS" | yq eval '{"mcpServers": .}' -o=json > claude.json

# Generate copilot.json
echo "Generating copilot.json..."
echo "$ENABLED_SERVERS" | yq eval '{"servers": .}' -o=json > copilot.json

# Generate opencode.json
echo "Generating opencode.json..."
echo "$ALL_SERVERS" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
result = {}

for server_name, server_config in data.items():
    original_enabled = server_config.get("enabled", True)
    if server_config.get("type") == "stdio":
        cmd_args = server_config.get("args", [])
        result[server_name] = {
            "type": "local",
            "command": [server_config["command"]] + cmd_args,
            "enabled": original_enabled
        }
        if "env" in server_config:
            result[server_name]["environment"] = server_config["env"]
    elif server_config.get("type") == "http":
        result[server_name] = {
            "type": "remote",
            "url": server_config["url"],
            "enabled": original_enabled
        }

print(json.dumps({"mcp": result}, indent=2))
' > opencode.json

# Generate codex.toml
echo "Generating codex.toml..."

# Check if Python is available
if command -v python3 &> /dev/null; then
    # Check if toml library is available, install if not
    if ! python3 -c "import toml" 2>/dev/null; then
        echo "Installing toml library..."
        pip3 install toml --break-system-packages --quiet || {
            echo "Error: Failed to install toml library. Please install it manually with 'pip3 install toml --break-system-packages'" >&2
            exit 1
        }
    fi

    # Generate TOML using inline Python code
    echo "$ALL_SERVERS" | python3 -c '
import json
import sys
import toml
import re

data = json.load(sys.stdin)

result = {}
for server_name, server_config in data.items():
    server_entry = {}
    original_enabled = server_config.get("enabled", True)
    for key, value in server_config.items():
        if key == "args":
            server_entry[key] = value
        elif key == "env":
            server_entry[key] = value
        elif key == "type":
            # Convert stdio to local for opencode compatibility
            if value == "stdio":
                server_entry["type"] = "local"
            elif value == "http":
                server_entry["type"] = "remote"
            else:
                server_entry[key] = value
        elif key == "enabled":
            server_entry[key] = original_enabled
        else:
            server_entry[key] = value
    result[server_name] = server_entry

toml_str = toml.dumps({"mcp_servers": result})
toml_str = re.sub(r"(\w+ = \[)(.*?),(\])", r"\1\2\3", toml_str)
print(toml_str)
' > codex.toml

    # Add header to the generated file
    sed -i '' '1i\
# Generated from config.yaml - do not edit manually\
' codex.toml
else
    echo "Error: python3 is not installed. Cannot generate codex.toml" >&2
    echo "Please install python3 to generate TOML configuration." >&2
    exit 1
fi

echo "Configuration generation complete!"
echo "Generated files:"
echo "  - claude.json (JSON format)"
echo "  - copilot.json (JSON format)"
echo "  - codex.toml (TOML format)"
echo "  - opencode.json (JSON format)"

# Show summary
echo ""
echo "Summary:"
echo "  Enabled servers: $(echo "$ENABLED_SERVERS" | yq eval 'length')"
echo "  Total servers: $(echo "$ALL_SERVERS" | yq eval 'length')"

echo ""
echo "Note: config.yaml is the master configuration file."
echo "      claude.json and copilot.json include only enabled servers."
echo "      codex.toml and opencode.json include all servers with enabled field."
