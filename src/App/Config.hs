{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Config where

import Data.Aeson
import Path (Abs, Dir, File, Path, absdir, absfile)
import RIO

defaultComicDir :: Path Abs Dir
-- defaultComicDir = [absdir|/home/runner/mansuki/comics|]
defaultComicDir = [absdir|/mnt/n/Documents/Comics/|]

defaultDbFile :: Path Abs File
-- defaultDbFile = [absfile|/home/runner/mansuki/mansuki.db|]
defaultDbFile = [absfile|/home/namin/mansuki/mansuki.db|]

defaultConfig :: Value
defaultConfig =
  object
    [ "comic-dir" .= defaultComicDir,
      "db-file" .= defaultDbFile
    ]

maxContentLen :: Int
maxContentLen = 500

knownAllowedOrigins :: [Text]
knownAllowedOrigins =
  [ "chrome-extension://ddlogfgmonfikdiffdnjfilpmncgkiml/", -- wsl2
    "chrome-extension://fnkbdldbljelgeikcfipeglijfmgcbah/" -- replit.com
  ]
