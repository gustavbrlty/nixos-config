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

    # Regarding launching GUI from CLI, x11docker doesn't use the 
    # binary on the machine but use a new one at each new launch,
    # also since x11docker launch the application in a container,
    # the application may take more time to load, and to finish
    # it was tricky to try x11docker.

    vim
    git
    rustup
    
    # I prefer using the 'Epiphany' web browser rather
    # than Firefox; I found Epiphany more sexy 🔥 ;).
    # However this browser is hard to install so I forsake it.
    # Instead of epiphany I've found qutebrowser that looks
    # great also.
    qutebrowser
   
    # However qutebrowser (nor Epiphany) doesn't have passkey 
    # implented yet, so if I need to connect to an account 
    # with my YubiKey I would simply use Firefox at the moment.
    firefox

    vlc

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

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

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

  # To have a more powerful terminal: tmux.
  programs.tmux.enable = true;

  # To start with a tmux shell rather than on a bash one.
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ "$(tty)" =~ /dev/tty ]] && [[ -z "$TMUX" ]]; then
        SHELL=tmux exec fbterm
      fi
    '';
  };

  # To desactivate Ctrl+Z since it can force the user to switch off the computer.
  programs.tmux.extraConfig = ''
    unbind-key C-z
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
   
    ".config/openbox/rc.xml".source = pkgs.writeText "openbox-rc.xml" ''
<?xml version="1.0" encoding="UTF-8"?>
<!-- Configuration Openbox générée pour NixOS -->
<openbox_config>
<!-- Vos autres sections ici (thèmes, raccourcis, etc.) -->
<!-- Exemple basique pour les applications -->
<applications>
<!-- Règle pour Qutebrowser : pas de décorations -->
<application class="qutebrowser">
<decor>no</decor>  <!-- Désactive les décorations (barre de titre, bordures) -->
<!-- Optionnel : maximiser par défaut -->
<!-- <maximized>yes</maximized> -->
</application>
<application class="firefox">
<decor>no</decor>  <!-- Désactive les décorations (barre de titre, bordures) -->
<!-- Optionnel : maximiser par défaut -->
<!-- <maximized>yes</maximized> -->
</application>
</applications>
<mouse>
<!-- CONTEXTE RACINE (bureau) -->
<context name="Root">
<!-- Menu sur clic droit du bureau -->
<mousebind button="Right" action="Press">
<action name="ShowMenu">
<menu>root-menu</menu>
</action>
</mousebind>
</context>

<!-- CONTEXTE FRAME (cadre de fenêtre) -->
<context name="Frame">
<!-- Menu sur clic droit du cadre -->
<mousebind button="Right" action="Press">
<action name="ShowMenu">
<menu>client-menu</menu>
</action>
</mousebind>

<!-- Déplacement avec Alt + Clic gauche -->
<mousebind button="A-Left" action="Drag">
<action name="Move"/>
</mousebind>

<!-- Redimensionnement libre avec Alt + Clic droit -->
<mousebind button="A-Right" action="Drag">
<action name="Resize"/>
</mousebind>
</context>

<!-- CONTEXTE TITLEBAR (barre de titre) -->
<context name="Titlebar">
<!-- Menu sur clic droit de la barre de titre -->
<mousebind button="Right" action="Press">
<action name="ShowMenu">
<menu>client-menu</menu>
</action>
</mousebind>

<!-- Déplacement avec clic normal -->
<mousebind button="Left" action="Drag">
<action name="Move"/>
</mousebind>

<!-- Maximiser avec double-clic -->
<mousebind button="Left" action="DoubleClick">
<action name="ToggleMaximize"/>
</mousebind>
</context>

<!-- BORDS - Redimensionnement unidirectionnel -->
<context name="Top">
<mousebind button="Left" action="Drag">
<action name="Resize">
<edge>top</edge>
</action>
</mousebind>
</context>

<context name="Bottom">
<mousebind button="Left" action="Drag">
<action name="Resize">
<edge>bottom</edge>
</action>
</mousebind>
</context>

<context name="Left">
<mousebind button="Left" action="Drag">
<action name="Resize">
<edge>left</edge>
</action>
</mousebind>
</context>

<context name="Right">
<mousebind button="Left" action="Drag">
<action name="Resize">
<edge>right</edge>
</action>
</mousebind>
</context>

<context name="TLCorner">
<mousebind button="Left" action="Drag">
<action name="Resize"/>
</mousebind>
</context>
<context name="TRCorner">
<mousebind button="Left" action="Drag">
<action name="Resize"/>
</mousebind>
</context>
<context name="BLCorner">
<mousebind button="Left" action="Drag">
<action name="Resize"/>
</mousebind>
</context>
<context name="BRCorner">
<mousebind button="Left" action="Drag">
<action name="Resize"/>
</mousebind>
</context>

<context name="Desktop">
<mousebind button="Up" action="Click">
<action name="GoToDesktop"><to>previous</to></action>
</mousebind>
<mousebind button="Down" action="Click">
<action name="GoToDesktop"><to>next</to></action>
</mousebind>
</context>
</mouse>

<keyboard>
<!-- Navigation entre bureaux -->
<keybind key="C-A-Left">
<action name="GoToDesktop"><to>left</to></action>
</keybind>
<keybind key="C-A-Right">
<action name="GoToDesktop"><to>right</to></action>
</keybind>
<keybind key="C-A-Up">
<action name="GoToDesktop"><to>up</to></action>
</keybind>
<keybind key="C-A-Down">
<action name="GoToDesktop"><to>down</to></action>
</keybind>

<!-- Accès direct aux bureaux -->
<keybind key="S-A-1">
<action name="GoToDesktop"><to>1</to></action>
</keybind>
<keybind key="S-A-2">
<action name="GoToDesktop"><to>2</to></action>
</keybind>
<keybind key="S-A-3">
<action name="GoToDesktop"><to>3</to></action>
</keybind>
<keybind key="S-A-4">
<action name="GoToDesktop"><to>4</to></action>
</keybind>
</keyboard>
</openbox_config>
    '';

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
