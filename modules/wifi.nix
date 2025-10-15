{ config, pkgs, ... }:
{
  networking.wireless = {
    enable = true;
    network = {
      "Ani ben Hashem" = {
        psk = "Amen ve amen";
      };
    };
  };
}
