{ config, pkgs, ... }:
{

  networking.hostName = "pc"; # Define your hostname.

  # On desactive Network_manager pour utiliser
  # a la place la methode declarative wpa_supplicant.
  networking.networkmanager.enable = false;

  networking.wireless = {

    enable = true;

    # Pour qu'on puisse gerer la connexion manuellement.   
    # cad avec wpa_cli ou wpa_gui.
    userControlled.enable = true;
    userControlled.group = "wheel";

    networks = {

      "Ani ben Hashem" = {
        psk = "Amen ve amen";
      };

      "BNF" = {
        auth = ''
          key_mgmt=NONE
        '';
      };

    };
   
    # Assure la compatibilite.
    extraConfig = "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}
