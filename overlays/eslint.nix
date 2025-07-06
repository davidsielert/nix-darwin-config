self: prev: {
  eslint = prev.nodePackages.eslint or null;
  nodejs = prev.nodejs.overrideAttrs (old: {doCheck = false;});


}
