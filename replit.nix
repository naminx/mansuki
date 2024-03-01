{pkgs}: let
  myHaskellPackages = pkgs.haskellPackages.override {
    overrides = self: super:
      with pkgs.haskell.lib; {
        #       script-monad = dontCheck super.script-monad;
        #       webdriver-w3c = dontCheck super.webdriver-w3c;
      };
  };
in {
  deps = with pkgs; [
    alejandra
    fish
    less
    neovim
    # nodejs
    sqlite
    stack
    unzip
    zip
    # dejavu_fonts
    # ipafont
    # imagemagick
    starship
    # Chrome
    # chromedriver
    # google-chrome
    chromium
    # Haskell
    cabal-install
    # haskell-language-server
    # node.js Packages
    # nodePackages.prettier
    # (haskellPackages.ghcWithPackages (pkgs:
    (myHaskellPackages.ghcWithPackages (pkgs:
      with pkgs; [
        # Custom packages
        attoparsec-base64
        base64
        esqueleto
        fourmolu
        implicit-hie
        modern-uri
        optparse-simple
        path
        persistent-sqlite
        pretty-simple
        purebred-email
        rawstring-qm
        replace-attoparsec
        rio
        yaml
        string-conversions
      ]))
  ];
}
