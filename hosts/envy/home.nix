{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      nixfmt-rfc-style
    ];
    stateVersion = "24.05";
    username = "zeno";
    homeDirectory = "/home/zeno";
  };

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      terminal = "kitty";
    };
  };

  programs = {
    kitty.enable = true;
    git = {
      enable = true;
      extraConfig.core.editor = "nvim";
      userName = "Zeno343";
      userEmail = "zeno@outernet.digital";
      hooks = {
        pre-commit = pkgs.writeShellScript "nixfmt" ''
          #!/bin/bash
          STAGED_NIX=$(git diff --staged --name-only |grep .nix)
          if [[ -n $STAGED_NIX ]] && ! nixfmt -c $STAGED_NIX; then
            echo "found unformatted nix files in commit, please format and try again"
            exit 1
          fi
        '';
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    neovim = with pkgs; {
      enable = true;
      defaultEditor = true;
      extraPackages = [ nixd ];
      plugins = with vimPlugins; [
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''require("lspconfig").nixd.setup{}'';
        }
      ];
    };
  };
}
