{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wmissed-extra-shared-lib #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}

module App.Types.Persist where

import App.Lib.Path (Dir, Path, Rel)
import App.Lib.RText (RText, RTextLabel (Password, Username))

import App.Lib.URI (URI)
import App.Types.Chapter (Chapter)
import App.Types.Comic (Comic (Comic))
import App.Types.Domain (Domain)
import App.Types.Title (Title)
import App.Types.Volume (Volume)
import App.Types.Web (Web (Web))
import Database.Persist.TH (mkPersist, persistLowerCase, share, sqlSettings)
import RIO (Eq, Show, Text)

share
    [mkPersist sqlSettings]
    [persistLowerCase|
  Webs
    web Web
    domain Domain
    username (RText 'Username) Maybe
    password (RText 'Password) Maybe
    lastVisit URI
    getNthPage Text
    getComics Text
    getLatestChap Text
    getChapters Text
    getImages Text
    Primary web
    deriving Eq Show
  Comics
    comic Comic Primary
    title Title
    folder (Path Rel Dir)
    volume Volume
    chapter Chapter
    Primary comic
    deriving Eq Show
  Urls
    web Web
    comic Comic
    path URI
    Primary web comic
    deriving Eq Show
|]
