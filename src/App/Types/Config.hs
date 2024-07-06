{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Config where

import Data.Aeson
import Path (Abs, Dir, File, Path)
import RIO


data Config = Config
  { comicDir :: !(Path Abs Dir)
  , dbFile :: !(Path Abs File)
  }
  deriving (Show)


instance FromJSON Config where
  parseJSON = withObject "Config" $ \o ->
    Config
      <$> (o .: "comic-dir")
      <*> (o .: "db-file")
