_: {
  # Claude Code installed via nix derivation (packages/claude-code.nix)
  # This manages the MCP server configuration
  xdg.configFile."claude/settings.json".text = builtins.toJSON {
    mcpServers = {
      brave-search = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-brave-search"
          "-s"
          "user"
        ];
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
    };
  };
}
