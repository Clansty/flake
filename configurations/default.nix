inputs:
let
  basicModules = [
    ./boot.nix
    ./environment.nix
    ./services/openssh.nix
    ./commandLine
    ./i18n.nix
    ./users
    ./nfsClient.nix
    ./networking.nix
  ];

  darwinModules = [
    ./environment.nix
    ./commandLine
    ./darwin
    ./users
    ./graphic/fonts.nix
  ];

  desktopModules = [
    ./graphic
  ];

  mkLinux = { name, desktop ? false, arch ? "x86_64", extraModules ? [ ] }: {
    name = "clansty-${name}";
    value = inputs.nixpkgs.lib.nixosSystem {
      system = "${arch}-linux";
      modules = [
        ./machines/${name}.nix
        inputs.nur.nixosModules.nur
        inputs.home-manager.nixosModules.home-manager
        { networking.hostName = "clansty-${name}"; }
      ] ++ basicModules ++ (if desktop then desktopModules else [ ]) ++ extraModules;
      specialArgs = {
        inherit inputs arch;
        flake = inputs.self;
        isLinux = true;
      };
    };
  };

  mkDarwin = { name, arch ? "aarch64", extraModules ? [ ] }: {
    name = "clansty-${name}";
    value = inputs.darwin.lib.darwinSystem {
      system = "${arch}-darwin";
      modules = [
        inputs.nur.nixosModules.nur
        inputs.home-manager.darwinModules.home-manager
        {
          networking.hostName = "clansty-${name}";
          networking.localHostName = "clansty-${name}";
          services.nix-daemon.enable = true;
        }
      ] ++ darwinModules ++ extraModules;
      specialArgs = {
        inherit inputs arch;
        flake = inputs.self;
        isLinux = false;
      };
    };
  };

  mkHome = { system, name, extraModules ? [ ], home }: {
    inherit name;
    value = inputs.home-manager.lib.homeManagerConfiguration
      {
        modules = [
          ./users/clansty/home
          { home.homeDirectory = home; }
        ];
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs;
          flake = inputs.self;
        };
      };
  };
in
{
  nixos = builtins.listToAttrs (map mkLinux [
    {
      name = "w510";
      desktop = true;
      arch = "aarch64";
      extraModules = [
        ./graphic/xremap.nix
        ./services/code-server.nix
        ./services/nginx-pc.nix
        ./emulation/riscv.nix
        ./services/samba-home.nix
      ];
    }
    {
      name = "x1c";
      desktop = true;
    }
    {
      name = "nixserver";
      extraModules = [
        ./services/postgres.nix
        ./services/superstar-checkin.nix
        ./services/q2tg.nix
        ./services/ctm-record.nix
      ];
    }
  ]);
  darwin = builtins.listToAttrs (map mkDarwin [
    {
      name = "m1";
      extraModules = [ ];
    }
  ]);
  home = builtins.listToAttrs (map mkHome [
    {
      name = "aarch64-darwin";
      system = "aarch64-darwin";
      home = "/Users/clansty";
    }
    {
      name = "aarch64-lima";
      system = "aarch64-linux";
      home = "/home/clansty.linux";
    }
    {
      name = "aarch64-linux";
      system = "aarch64-linux";
      home = "/home/clansty";
    }
    {
      name = "x86_64-linux";
      system = "x86_64-linux";
      home = "/home/clansty";
    }
  ]);
}
