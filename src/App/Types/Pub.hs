{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module App.Types.Pub
  ( Pub (..)
  , module App.Types.Chapter
  , module App.Types.Chapters
  , module App.Types.Volume
  ) where

import App.Types.Chapter
import App.Types.Chapters
import App.Types.Volume
import Data.Aeson
  ( FromJSON (parseJSON)
  , ToJSON (toJSON)
  , Value (Number)
  , withText
  )
import Data.Scientific (toBoundedInteger)
import RIO


newtype Pub = Pub {getPub :: Either Volume Chapters}


instance FromJSON Pub where
  parseJSON v = case v of
    Number n ->
      maybe (fail "") (return . Pub . Left . Volume) $
        toBoundedInteger n
    other -> withText "Pub" mkChap other
   where
    mkChap =
      either (fail . displayException) (return . Pub . Right) . mkChapters


instance ToJSON Pub where
  toJSON pub = case pub.getPub of
    Left vol -> toJSON vol
    Right chap -> toJSON $ show chap
