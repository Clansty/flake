{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; with config.nur.repos; [
    gnome.gnome-tweaks
    vscode jupyter
    gparted
    arduino libusb1 libusb-compat-0_1
    remmina
    krita gimp inkscape gwenview libsForQt5.kolourpaint
    libreoffice-fresh
    vlc yesplaymusic obs-studio
    balena-etcher
    icalingua-pp
    tdesktop-x64
    rewine.landrop
    rewine.aliyunpan
    charles
  ];
  services.udev.packages = [ 
    pkgs.micronucleus-udev-rules 
  ];
}
