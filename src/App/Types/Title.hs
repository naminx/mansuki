{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Title (Title (..)) where

import Data.Aeson (FromJSON, ToJSON)
import Database.Esqueleto.Experimental (PersistField, PersistFieldSql)
import RIO (Eq, Ord, Read, Show, Text)


newtype Title = Title {getTitle :: Text}
  deriving (Eq, Ord, Show, Read)
  deriving newtype
    ( FromJSON
    , ToJSON
    , PersistField
    , PersistFieldSql
    )
