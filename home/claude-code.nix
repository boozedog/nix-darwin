{ pkgs, ... }:
let
  statuslineScript = ./claude-statusline.sh;

  mcpConfig = builtins.toJSON {
    mcpServers = {
      context7 = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
        env = { };
      };
      chrome-devtools = {
        type = "stdio";
        command = "npx";
        args = [
          "chrome-devtools-mcp@latest"
        ];
        env = { };
      };
      deepwiki = {
        type = "stdio";
        command = "npx";
        args = [
          "mcp-remote@latest"
          "https://mcp.deepwiki.com/mcp"
        ];
        env = { };
        transport = "http";
        scope = "user";
      };
      nixos = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp/";
        headers = {
          Authorization = "Bearer __GITHUB_TOKEN__";
        };
      };
    };
  };
in
{
  # Claude Code installed via nix derivation (packages/claude-code.nix)
  home = {
    # uv provides uvx, needed for mcp-nixos server
    # bc needed for statusline calculations
    packages = [
      pkgs.uv
      pkgs.bc
    ];

    # Statusline script for Claude Code
    file.".claude/statusline.sh" = {
      source = statuslineScript;
      executable = true;
    };

    # Settings go in .claude/settings.json (plugins, preferences)
    file.".claude/settings.json".text = builtins.toJSON {
      # Status line showing comprehensive session info
      statusLine = {
        type = "command";
        command = "~/.claude/statusline.sh";
        padding = 0;
      };
      # enabledPlugins = {
      #   "frontend-design@claude-code-plugins" = true;
      # };
      alwaysThinkingEnabled = true;
      preferredNotifChannel = "terminal_bell";
      hooks = {
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "say 'Task complete'";
              }
            ];
          }
        ];
        Notification = [
          {
            matcher = "permission_prompt";
            hooks = [
              {
                type = "command";
                command = "say 'Awaiting approval'";
              }
            ];
          }
        ];
      };
    };

    # MCP servers must be configured in ~/.claude.json (not settings.json)
    # This file is also used by Claude for runtime state, so we merge
    # mcpServers into existing content rather than overwriting.
    activation.claudeMcpServers = ''
      CLAUDE_JSON="$HOME/.claude.json"
      GITHUB_TOKEN=$(${pkgs.gh}/bin/gh auth token 2>/dev/null || echo "")
      MCP_CONFIG='${mcpConfig}'
      MCP_CONFIG=$(echo "$MCP_CONFIG" | ${pkgs.gnused}/bin/sed "s/__GITHUB_TOKEN__/$GITHUB_TOKEN/")
      if [ -f "$CLAUDE_JSON" ]; then
        # Merge mcpServers into existing file, preserving other keys
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$CLAUDE_JSON" <(echo "$MCP_CONFIG") > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
      else
        echo "$MCP_CONFIG" > "$CLAUDE_JSON"
      fi
    '';
  };
}
