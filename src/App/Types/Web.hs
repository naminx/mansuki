{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Web where

import Data.Aeson (FromJSON, ToJSON)
import Database.Esqueleto.Experimental (PersistField, PersistFieldSql)
import RIO (Eq, Int, Ord, Read, Show)
import Web.Internal.HttpApiData (FromHttpApiData, ToHttpApiData)
import Web.PathPieces (PathPiece)


newtype Web = Web {getWeb :: Int}
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


mangaRawSo :: Web
mangaRawSo = Web 0


mangaRawIo :: Web
mangaRawIo = Web 1


manga1001Su :: Web
manga1001Su = Web 2


weLoMaArt :: Web
weLoMaArt = Web 3


weLoveMangaOne :: Web
weLoveMangaOne = Web 4


klMangaNet :: Web
klMangaNet = Web 5


hachiMangaCom :: Web
hachiMangaCom = Web 6


j8JpCom :: Web
j8JpCom = Web 7
