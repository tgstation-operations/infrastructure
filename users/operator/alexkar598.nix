{
  pkgs,
  config,
  ...
}: {
  users.users.alexkar598 = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvwltMXxHVGEKsbtzBF5v5k0P4HPY8jLZldtMi/AcuEgzs4BTAGIC5ML0twd5lMHZXcj23KN1A2gCCQtSFPtypKTX+YqyUikNZkCPKsGIVvDkDlbupi3Z269QOxPk8Hp6xSnlM7fIUTeM75dZ1pKVcjdd0QYrf2goSio/qBKinbJeT8YANw1JZnIuwpvXJrFsAFBU6LQDKq9NhJSORkhU2slvIUfLg1k7kUNmdlFKUKDeHHkzMgt9y577058uIwhcO58xAAj7o7XNwDNfti/thuuAYM6ZKA/rerUsinIuX1dR69Vl12jj7k7Y5zMLc9LNySEs2d1ADCV6EtW7hZigG+Px21jvAcNETMP25Sa6YO8VnMd2c0sv64r2zC7/TlBOD9k5nmbi4H47gBAruw/ufRCjobyoPnLs8gyQX1hi+FkHeh3fpVhThY+BMs/dOG6ro7TrYTuVgTdjRbSagsqt1ybzyIvrX+LxNVBY7Mu6yXZW0BHwl5q9i3dZMjwY1fQc="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDS5qyqSoB+C5Y6t4beorc3/dJ2a5XJX3zsSjn+x2jbIwmx/XaTl+s2ozbo7BtXvSll+4+0RHj+TtCfuvaY1w1bvSJ0gr6uhYPuq6s5480feM6+h/AE8Ji9870JQRcAgPEdqRd7iosarxVGdm5Que9TNovFMRgU5l4ozXhelZ33QpbaFHSW5AptikbpV9ncm0EfPOgMSJxF4yKKlGaoj5bK6GfQTKGKAMq4RQBa5oPlHlfavWxQcyfnAfIV+d2Yhq4DI0O+zoLbLs9t+Z7cGpunjihDqTcmWecmBz4oqYr2L5J3DVN8ILeCePt5j6Ynli4Shm6w3jDiTQnavtcyoKcoVpPaoWD1kMXuTJ5/7dQFpeEuXObZCGBKQrp8gAGbujjMmDb6udM7Em/G3bejlg/Lmq3AS79AeJOM0ACeYYwUrsOTEVGbHHHVxqtNROWyVTCrr499tMRzatn9BQMHrLT9vhkhylqETQAZZkt0ocRN0/1OzrqiRmQBeho4Pyr1Bz0="
    ];
  };

  home-manager.users.alexkar598 = {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        eval $(${pkgs.starship}/bin/starship init bash)
      '';
    };

    home.stateVersion = config.system.stateVersion;
  };
}
