{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unticked-promoted-constructors #-}

module App.Types.Domain
  ( Domain
  ) where

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
  ( Applicative (pure)
  , Bifunctor (first)
  , Exception (displayException)
  , MonadFail (fail)
  , either
  , ($)
  , (.)
  , (<=<)
  )
import qualified RIO.Text as T (pack)
import Text.URI (RText, RTextLabel (Host), mkHost, unRText)


type Domain = RText Host


instance FromJSON Domain where
  parseJSON =
    withText "Text" $ either (fail . displayException) pure . mkHost


instance ToJSON Domain where
  toJSON = toJSON . unRText


instance PersistField Domain where
  toPersistValue hostName = PersistText $ unRText hostName
  fromPersistValue =
    first (T.pack . displayException) . mkHost <=< fromPersistValueText


instance PersistFieldSql Domain where
  sqlType _ = SqlString


instance ES.SqlString Domain
