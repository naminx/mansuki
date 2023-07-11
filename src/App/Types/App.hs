{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.App (App (..)) where

import App.Types.Options (Options)
import Path (Abs, Dir, File, Path)
import RIO (HasLogFunc (..), LogFunc, Text, lens)
import RIO.Process (HasProcessContext (..), ProcessContext)


data App = App
  { logFunc :: !LogFunc
  , processContext :: !ProcessContext
  , -- Add other app-specific configuration information here
    options :: !Options
  , comicDir :: !(Path Abs Dir)
  , dbFile :: !(Path Abs File)
  , allowedOrigins :: ![Text]
  }


instance HasLogFunc App where
  logFuncL = lens (.logFunc) (\a x -> a {logFunc = x})


instance HasProcessContext App where
  processContextL = lens (.processContext) (\a x -> a {processContext = x})
