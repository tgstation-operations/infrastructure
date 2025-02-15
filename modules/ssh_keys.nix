builtins.concatLists
(builtins.attrValues
  (builtins.zipAttrsWith
    (name: values: let
      attrs = builtins.head values;
    in
      if (builtins.hasAttr "extraGroups" attrs) && builtins.elem "wheel" attrs.extraGroups
      then attrs.openssh.authorizedKeys.keys
      else [])
    (map
      (x:
        ((import x) {
          pkgs = {};
          config = {};
        })
        .users
        .users)
      ((import ./users/operator) {}).imports)))
