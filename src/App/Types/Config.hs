{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Config (Config (..)) where

import Data.Aeson (FromJSON (..), Value (Object), (.:))
import Path (Dir, File, SomeBase)
import RIO


data Config = Config
  { comicDir :: SomeBase Dir
  , dbFile :: SomeBase File
  }
  deriving (Eq, Show)


instance FromJSON Config where
  parseJSON (Object v) =
    Config
      <$> (v .: "comic-directory")
      <*> (v .: "database-file")
  parseJSON _ = error "expecting object"
