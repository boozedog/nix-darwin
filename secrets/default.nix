_: {
  age.identityPaths = [ "/Users/david/.ssh/id_ed25519_agenix" ];

  age.secrets = {
    brave-api-key = {
      file = ./brave-api-key.age;
      owner = "david";
      mode = "0400";
    };
  };
}
