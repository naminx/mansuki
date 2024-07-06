{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module App.Types.WebInfo (WebInfo (..)) where

import App.Lib.RText ()
import App.Lib.URI (URI)
import App.Types.Domain (Domain)
import App.Types.Web (Web)
import Data.Aeson (FromJSON (..), ToJSON (..))
import RIO (Eq, Generic, Maybe, Show, Text)
import Text.URI (UserInfo)

deriving instance FromJSON UserInfo

deriving instance ToJSON UserInfo

data WebInfo = WebInfo
    { web :: !Web
    , domain :: !Domain
    , userInfo :: !(Maybe UserInfo)
    , lastVisit :: !URI
    , getNthPage :: !Text
    , getComics :: !Text
    , getLatestChap :: !Text
    , getChapters :: !Text
    , getImages :: !Text
    }
    deriving (Eq, Show, Generic, ToJSON, FromJSON)
