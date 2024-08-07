{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Config where

import Data.Aeson
import Path (Abs, Dir, File, Path, absdir, absfile)
import RIO

defaultComicDir :: Path Abs Dir
defaultComicDir = [absdir|/home/namin/comics/|]

defaultDbFile :: Path Abs File
defaultDbFile = [absfile|/home/namin/haskell/mansuki/mansuki.db|]

defaultConfig :: Value
defaultConfig =
    object
        [ "comic-dir" .= defaultComicDir
        , "db-file" .= defaultDbFile
        ]

maxContentLen :: Int
maxContentLen = 500

knownAllowedOrigins :: [Text]
knownAllowedOrigins =
    [ "chrome-extension://aehehgedpojgjoiliflhejlfbgibfegn/"
    , "chrome-extension://jghmmckjljfmiflifjlgalcaoelcmenl/"
    ]
