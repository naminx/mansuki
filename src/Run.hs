{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Run (run) where

import Import
import Path
import Text.Pretty.Simple (pPrint)


run :: RIO App ()
run = do
  rootDirectory <- asks (.rootDir)
  databaseFile <- asks (.dbaseFile)
  pPrint $ "root directory: " <> fromAbsDir rootDirectory
  pPrint $ "database file: " <> fromAbsFile databaseFile
