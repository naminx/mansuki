{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module App.Lib.URI (module ModernURI) where

import Data.Aeson (FromJSON (..), ToJSON (..), withText)
import Database.Esqueleto.Experimental
  ( PersistField (..)
  , PersistFieldSql (..)
  , PersistValue (PersistText)
  , SqlType (SqlString)
  , fromPersistValueText
  )
import qualified Database.Esqueleto.Internal.Internal as ES (SqlString)
import RIO
import qualified RIO.Text as T (pack)
import Text.URI (mkURI, render)
import Text.URI as ModernURI (URI)


instance FromJSON URI where
  parseJSON =
    withText "Text" $ either (fail . displayException) pure . mkURI


instance ToJSON URI where
  toJSON = toJSON . render


instance PersistField URI where
  toPersistValue url = PersistText $ render url
  fromPersistValue =
    first (T.pack . displayException) . mkURI <=< fromPersistValueText


instance PersistFieldSql URI where
  sqlType _ = SqlString


instance ES.SqlString URI
