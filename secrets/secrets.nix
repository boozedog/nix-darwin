# This file is used by agenix to determine which keys can decrypt which secrets.
# Run `agenix -e secrets/brave-api-key.age` to create/edit the secret.
let
  # Your SSH public key (used for encryption)
  david = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFN/6POWwlIKI7fT3Oio/PHvBcE0h+meq78vVTTnC6kV";
in
{
  "brave-api-key.age".publicKeys = [ david ];
}
