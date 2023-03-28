{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.App (App (..)) where

import App.Types.Options
import Path (Abs, Dir, File, Path)
import RIO
import RIO.Process


data App = App
  { logFunc :: !LogFunc
  , processContext :: !ProcessContext
  , options :: !Options
  , -- Add other app-specific configuration information here
    verbose :: !Bool
  , comicDir :: !(Path Abs Dir)
  , dbFile :: !(Path Abs File)
  }


instance HasLogFunc App where
  logFuncL = lens (.logFunc) (\a x -> a {logFunc = x})


instance HasProcessContext App where
  processContextL = lens (.processContext) (\a x -> a {processContext = x})
