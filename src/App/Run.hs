{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Run (run) where

import App.Import
import Path
import Text.Pretty.Simple (pPrint)


run :: RIO App ()
run = do
  comicDir <- asks (.comicDir)
  dbFile <- asks (.dbFile)
  pPrint $ "root directory: " <> fromAbsDir comicDir
  pPrint $ "database file: " <> fromAbsFile dbFile
