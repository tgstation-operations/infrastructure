{
  config,
  pkgs,
  ...
}: {
  users.users.aa07 = {
    isNormalUser = true;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAihqleUUO9ZOFAuKe/S0mnNe16Mz0BnrUt2Z5uM+5pa9apM3Kb3sb5GD7nnWYgALer4MjvV8HfRKE/3nu00v0DRkjX6/NlXkHX4x3C5xm89o4qFoyS3JqwdD+vdpywj4ie1iCp66tAKf5rDwhOAIU4ylBCHwgzGpoOtLOVQeZ6hpPtk2Yi750m/wIibBm8VYUWiFk+609mB20++brlrjgQIOPNW9abtjx6VK01phSRBkMquGOyBEMcPGXzW/TJiAOwYF8PZG+8jMU6i/pXmLnbBhvz9MuKOoqEWo+8emdHB4GE/QjiyqZxioLWg48XQX9efMtJOUVER6j4tQj0qalsQZNBF8PV/Rlzrkk9XdCG48r/5FjGakycrVTXrc/pbW4gIF6+kougM9+jdYLzyDaWpzONNz8NsNOEhjS+z6V++gpurbS9OwmyAaP7A6mh2qGnNGF/axAYfkoT0Al/kpP/JfZEn0GL9oWFrJ/fCC7IAXl6p8RyGZqqN/dX1Ql1ZAhpsFSARXo7lRYfeua4N/3CIbHzvehALIz9kL6pd4zsDGtOqpICBHvZGeAQ06o0jAhIuiEgccE/06n7PiVnFi0WLO30+TV/gznQ7onYXeT5K+lbcpbO+pUmaJDQrd7gbxJ6vanAa9TQX6k1jLZYWOM3iadRAK3m/8kd779GRbQz0U= AA07-MASTER"
    ];
  };

  home-manager.users.aa07 = {
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
