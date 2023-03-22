{pkgs}: let
  myHaskell = pkgs.haskellPackages.override {
    overrides = self: super: {
      script-monad = pkgs.haskell.lib.dontCheck super.script-monad;
      webdriver-w3c = pkgs.haskell.lib.dontCheck super.webdriver-w3c;
    };
  };
in {
  deps = [
    pkgs.alejandra
    pkgs.fish
    pkgs.less
    pkgs.neovim
    pkgs.nodejs
    pkgs.sqlite
    pkgs.stack
    pkgs.unzip
    # Chrome
    # pkgs.chromedriver
    # pkgs.google-chrome
    # Haskell
    pkgs.cabal-install
    pkgs.haskell-language-server
    # (pkgs.haskellPackages.ghcWithPackages (pkgs:
    (myHaskell.ghcWithPackages (pkgs:
      with pkgs; [
        # Custom packages
        esqueleto
        fourmolu
        implicit-hie
        modern-uri
        optparse-applicative
        optparse-simple
        path
        persistent-sqlite
        pretty-simple
        purebred-email
        raw-strings-qq
        rio
        witherable
        wreq
        script-monad
        webdriver-w3c
      ]))
  ];
}
