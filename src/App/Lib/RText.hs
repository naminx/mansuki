{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unticked-promoted-constructors #-}

module App.Lib.RText (module URI) where

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
import Text.URI (mkPassword, mkUsername, unRText)
import Text.URI as URI (RText, RTextLabel (Password, Username))


instance FromJSON (RText Username) where
  parseJSON =
    withText "Text" $ either (fail . displayException) pure . mkUsername


instance FromJSON (RText Password) where
  parseJSON =
    withText "Text" $ either (fail . displayException) pure . mkPassword


instance ToJSON (RText Username) where
  toJSON = toJSON . unRText


instance ToJSON (RText Password) where
  toJSON = toJSON . unRText


instance PersistField (RText Username) where
  toPersistValue hostName = PersistText $ unRText hostName
  fromPersistValue =
    first (T.pack . displayException) . mkUsername <=< fromPersistValueText


instance PersistFieldSql (RText Username) where
  sqlType _ = SqlString


instance ES.SqlString (RText Username)


instance PersistField (RText Password) where
  toPersistValue hostName = PersistText $ unRText hostName
  fromPersistValue =
    first (T.pack . displayException) . mkPassword <=< fromPersistValueText


instance PersistFieldSql (RText Password) where
  sqlType _ = SqlString


instance ES.SqlString (RText Password)
