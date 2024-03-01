{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.ComicInfo where

import App.Lib.URI (URI)
import App.Types.Chapter (Chapter)
import App.Types.Comic (Comic)
import App.Types.Title (Title)
import App.Types.Volume (Volume)
import Data.Aeson (FromJSON, ToJSON)
import Path (Dir, Path, Rel)
import RIO (Eq, Generic, Show)


data ComicInfo = ComicInfo
  { comic :: Comic
  , url :: URI
  , title :: Title
  , folder :: Path Rel Dir
  , volume :: Volume
  , chapter :: Chapter
  }
  deriving (Eq, Show, Generic, FromJSON, ToJSON)
