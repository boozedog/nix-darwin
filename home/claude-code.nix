{ pkgs, ... }:
let
  brave-search-mcp = pkgs.callPackage ../packages/brave-search-mcp.nix { };

  mcpConfig = builtins.toJSON {
    mcpServers = {
      brave-search = {
        type = "stdio";
        command = "${brave-search-mcp}/bin/brave-search-mcp";
        args = [ ];
        env = { };
      };
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
        args = [ "chrome-devtools-mcp@latest" ];
        env = { };
      };
      nixos = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
    };
  };
in
{
  # Claude Code installed via nix derivation (packages/claude-code.nix)
  home = {
    # uv provides uvx, needed for mcp-nixos server
    packages = [ pkgs.uv ];

    # Settings go in .claude/settings.json (plugins, preferences)
    file.".claude/settings.json".text = builtins.toJSON {
      enabledPlugins = {
        "frontend-design@claude-code-plugins" = true;
      };
      alwaysThinkingEnabled = true;
    };

    # MCP servers must be configured in ~/.claude.json (not settings.json)
    # This file is also used by Claude for runtime state, so we merge
    # mcpServers into existing content rather than overwriting.
    activation.claudeMcpServers = ''
      CLAUDE_JSON="$HOME/.claude.json"
      if [ -f "$CLAUDE_JSON" ]; then
        # Merge mcpServers into existing file, preserving other keys
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$CLAUDE_JSON" <(echo '${mcpConfig}') > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
      else
        echo '${mcpConfig}' > "$CLAUDE_JSON"
      fi
    '';
  };
}
