_: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Multiple colorschemes - switch with :colorscheme <name>
    colorscheme = "oxocarbon";
    colorschemes = {
      tokyonight = {
        enable = true;
        settings.style = "night"; # night, storm, day, moon
      };
      catppuccin = {
        enable = true;
        settings.flavour = "mocha"; # latte, frappe, macchiato, mocha
      };
      kanagawa.enable = true;
      onedark = {
        enable = true;
        settings.style = "darker";
      };
      github-theme.enable = true;
      oxocarbon.enable = true;
    };

    # General options
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      signcolumn = "yes";
      termguicolors = true;
    };

    # Snacks keymaps (using raw lua for lazy-loaded functions)
    keymaps = [
      {
        key = "<leader>e";
        action.__raw = "function() Snacks.explorer() end";
        options.desc = "Open file explorer";
      }
      {
        key = "<leader>ff";
        action.__raw = "function() Snacks.picker.files() end";
        options.desc = "Find files";
      }
      {
        key = "<leader>fg";
        action.__raw = "function() Snacks.picker.grep() end";
        options.desc = "Live grep";
      }
      {
        key = "<leader>fb";
        action.__raw = "function() Snacks.picker.buffers() end";
        options.desc = "Find buffers";
      }
      {
        key = "<leader>fh";
        action.__raw = "function() Snacks.picker.help() end";
        options.desc = "Help tags";
      }
      {
        key = "<leader>fr";
        action.__raw = "function() Snacks.picker.lsp_references() end";
        options.desc = "LSP references";
      }
      {
        key = "<leader>fd";
        action.__raw = "function() Snacks.picker.lsp_definitions() end";
        options.desc = "LSP definitions";
      }
      {
        key = "-";
        action.__raw = "function() Snacks.picker.files() end";
        options.desc = "Find files";
      }
    ];

    # Disable netrw and open snacks picker when opening a directory
    globals = {
      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
    };

    autoCmd = [
      {
        event = [ "VimEnter" ];
        callback.__raw = ''
          function(data)
            -- Check if argument is a directory
            local directory = vim.fn.isdirectory(data.file) == 1
            if not directory then
              return
            end
            -- Change to the directory
            vim.cmd.cd(data.file)
            -- Open snacks picker
            Snacks.picker.files()
          end
        '';
      }
    ];

    # All plugins configuration
    plugins = {
      # Treesitter for better syntax highlighting
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
        settings.indent.enable = true;
      };

      # Icons
      web-devicons.enable = true;

      # Snacks - QoL plugins collection (replaces telescope, oil)
      snacks = {
        enable = true;
        settings = {
          # File picker (replaces telescope)
          picker = {
            enabled = true;
            sources.files.hidden = true;
            sources.grep.hidden = true;
          };
          # File explorer (manual only, doesn't auto-open for directories)
          explorer = {
            enabled = true;
            replace_netrw = false;
          };
          # Nice extras
          notifier.enabled = true;
          quickfile.enabled = true; # Fast file open
          statuscolumn.enabled = true;
          indent.enabled = true;
          scope.enabled = true;
        };
      };

      # LSP configuration
      lsp = {
        enable = true;
        inlayHints = true; # Enable inlay hints (type annotations, parameter names)
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "gi" = "implementation";
            "gr" = "references";
            "K" = "hover";
            "<leader>rn" = "rename";
            "<leader>ca" = "code_action";
            "<leader>f" = "format";
          };
          diagnostic = {
            "<leader>e" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
        };
        servers = {
          # Nix (nixd is better - uses your .nixd.json)
          nixd.enable = true;

          # Lua
          lua_ls.enable = true;

          # TypeScript/JavaScript
          ts_ls.enable = true;

          # JSON
          jsonls.enable = true;

          # YAML
          yamlls.enable = true;

          # Bash
          bashls.enable = true;

          # Python
          pyright.enable = true;
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        settings.mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-e>" = "cmp.mapping.close()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
        };
      };

      # none-ls for statix (Nix linter) inline diagnostics
      none-ls = {
        enable = true;
        sources = {
          diagnostics.statix.enable = true; # Nix linter warnings inline
          code_actions.statix.enable = true; # Quick fixes via <leader>ca
        };
      };

      # conform-nvim for format on save
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback"; # Use LSP if no formatter configured
          };
          # Uses formatters from PATH (devShells), falls back to LSP
          formatters_by_ft = {
            nix = [
              "nixfmt"
              "alejandra"
            ];
          };
        };
      };
    };

    # Configure diagnostic display (virtual text = inline hints)
    diagnostic.settings = {
      virtual_text = {
        prefix = "●"; # Or "■", "▎", etc.
        spacing = 2;
      };
      signs = true;
      underline = true;
      update_in_insert = false; # Don't update while typing
      severity_sort = true;
    };
  };
}
