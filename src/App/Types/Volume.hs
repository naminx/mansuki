{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Volume (Volume (..)) where

import Data.Aeson (FromJSON, ToJSON)
import Database.Esqueleto.Experimental (PersistField, PersistFieldSql)
import RIO (Eq, Int, Ord, Read, Show)


newtype Volume = Volume {getVolume :: Int}
  deriving (Eq, Ord, Show, Read)
  deriving newtype
    ( FromJSON
    , ToJSON
    , PersistField
    , PersistFieldSql
    )
