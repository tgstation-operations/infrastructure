{...}: {
  imports = [
    ./bot
    ./keyholder
    ./operator
  ];

  users.groups = {
    db-operator = {};
  };
}
