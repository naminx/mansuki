{pkgs}: let
  myHaskellPackages = pkgs.haskellPackages.override {
    overrides = self: super: with pkgs.haskell.lib; {
      script-monad = dontCheck super.script-monad;
      webdriver-w3c = dontCheck super.webdriver-w3c;
    };
  };
in {
  deps = with pkgs; [
    alejandra
    fish
    less
    neovim
    nodejs
    sqlite
    stack
    unzip
    # Chrome
    # chromedriver
    # google-chrome
    # Haskell
    cabal-install
    haskell-language-server
    # (haskellPackages.ghcWithPackages (pkgs:
    (myHaskellPackages.ghcWithPackages (pkgs:
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
