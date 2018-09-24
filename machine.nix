let
  machine = import <nixpkgs/nixos> {
    system = "x86_64-linux";
    configuration = { pkgs, ... }:
      let
        server = pkgs.haskellPackages.callPackage ./hello-world/default.nix {};
      in {
        imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
        networking.firewall.enable = false;
        users.extraUsers.hello =
          { isSystemUser = true;
            description = "the hello world daemon";
          };
        systemd.services.hello-world =
          { wantedBy = [ "multi-user.target" ];
            enable = true;            
            description = "the super scalable hello world service - it's web scale!";
            script = "${server}/bin/server +RTS";
            serviceConfig =
              { Restart = "always";
                User = "hello";
              };
          };
      };        
  };
in
  machine.system
    
  
