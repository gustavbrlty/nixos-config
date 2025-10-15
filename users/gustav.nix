{ config, pkgs, ... }:

{

  # We want the user to be able to use qemu.
  imports = [
    ../modules/qemu_virtu.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "gustav";
  home.homeDirectory = "/home/gustav";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [

    git
    rustup
    
    # I prefer using the 'Epiphany' web browser rather
    # than firefox, I found Epiphany more friendly/sexy.

    # Mes clés SSH sont stockées sur YubiKey.
    yubikey-manager
    yubico-piv-tool
    
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      url."git@github-kylak:kylak".insteadOf = "git@github.com:kylak";
      url."git@github-gustavbrlty:gustavbrlty".insteadOf = "git@github.com:gustavbrlty";
      safe.directory = "/etc/nixos"; # To save the NixOS config.
    };
  };
  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks = {
    "github-kylak" = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/YubiKey_SSH_1.pub";
    };
    "github-gustavbrlty" = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/YubiKey_SSH_2.pub";
    };
    "c" = {
      hostname = "c";
      user = "git";
      identityFile = "~/.ssh/YubiKey_SSH_1.pub";
    };
    "*" = {};
  };
  # Configure SSH pour utiliser la clé PIV stockée sur la YubiKey.
  programs.ssh.extraConfig = ''
    PKCS11Provider "${pkgs.yubico-piv-tool}/lib/libykcs11.so"
  '';

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/gustav/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
