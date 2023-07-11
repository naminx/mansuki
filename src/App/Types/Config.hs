{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Config where

import Data.Aeson
import Path (Abs, Dir, File, Path)
import RIO

data Config = Config
  { comicDir :: !(Path Abs Dir),
    dbFile :: !(Path Abs File)
  }
  deriving (Show)

instance FromJSON Config where
  parseJSON = withObject "Config" $ \o ->
    Config
      <$> (o .: "comic-dir")
      <*> (o .: "db-file")

{--
defaultComicDir :: Path Abs Dir
-- defaultComicDir = [absdir|/home/runner/mansuki/comics|]
defaultComicDir = [absdir|/mnt/n/Documents/Comics/|]

defaultDbFile :: Path Abs File
-- defaultDbFile = [absfile|/home/runner/mansuki/mansuki.db|]
defaultDbFile = [absfile|/home/namin/mansuki/mansuki.db|]

maxContentLen :: Int
maxContentLen = 500

knownAllowedOrigins :: [Text]
knownAllowedOrigins =
  [ "chrome-extension://ddlogfgmonfikdiffdnjfilpmncgkiml/" -- wsl2
  , "chrome-extension://fnkbdldbljelgeikcfipeglijfmgcbah/" -- replit.com
  ]

--}
