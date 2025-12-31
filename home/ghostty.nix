_: {
  programs.ghostty = {
    enable = true;
    package = null;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    #installBatSyntax = true;
    #installVimSyntax = true;
    settings = {
      bell-features = "audio,system,title";
      font-family = "Maple Mono NL NF";
      font-size = 16;
      # support claude code shift+enter
      keybind = "shift+enter=text:\\x1b\\r";
      # support alt key in tmux
      macos-option-as-alt = "left";
      macos-titlebar-style = "hidden";
      quit-after-last-window-closed = false;
      theme = "GitHub Dark";
      window-padding-x = 16;
      window-padding-y = 16;
      window-save-state = "always";
    };
  };
}
