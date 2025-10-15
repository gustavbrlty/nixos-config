{ config, pkgs, ... }:
{

  networking.wireless = {
    enable = true;
    networks = {

      "Ani ben Hashem" = {
        psk = "Amen ve amen";
      };

    };
  };
}
