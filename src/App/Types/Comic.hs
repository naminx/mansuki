{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Comic (Comic (..)) where

import Data.Aeson (FromJSON, ToJSON)
import Database.Esqueleto.Experimental (PersistField, PersistFieldSql)
import RIO (Eq, Int, Ord, Read, Show)
import Web.Internal.HttpApiData (FromHttpApiData, ToHttpApiData)
import Web.PathPieces (PathPiece)


newtype Comic = Comic {getComic :: Int}
  deriving (Eq, Ord, Show, Read)
  deriving newtype
    ( FromJSON
    , ToJSON
    , PathPiece
    , ToHttpApiData
    , FromHttpApiData
    , PersistField
    , PersistFieldSql
    )
