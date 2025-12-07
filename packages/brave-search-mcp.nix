{ pkgs }:
pkgs.writeShellApplication {
  name = "brave-search-mcp";
  runtimeInputs = [ pkgs.nodejs ];
  text = ''
    export BRAVE_API_KEY
    BRAVE_API_KEY=$(cat /run/agenix/brave-api-key)
    exec npx -y @modelcontextprotocol/server-brave-search -s user "$@"
  '';
}
