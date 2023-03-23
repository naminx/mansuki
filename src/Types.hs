{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Types where

import Data.Monoid (Any (..), Last (..))
import Path
import RIO
import RIO.Process


defaultRootDir :: Path Abs Dir
defaultRootDir = [absdir|/home/namin/comics|]


defaultDbaseFile :: Path Rel File
defaultDbaseFile = [relfile|mansuki.db|]


data Options = Options
  { globalOptions :: GlobalOptions
  , command :: Command
  }


data GlobalOptions = GlobalOptions
  { verboseOpt :: !Any
  , rootDirOpt :: !(Last (SomeBase Dir))
  , dbaseFileOpt :: !(Last (SomeBase File))
  }


data Command
  = ListTable Tables
  | AddComic Text (Path Rel Dir)
  | Nop
  deriving (Eq, Show)


data Tables
  = WebsTable
  | ComicsTable
  deriving (Eq, Show)


data App = App
  { logFunc :: !LogFunc
  , processContext :: !ProcessContext
  , options :: !Options
  , -- Add other app-specific configuration information here
    verbose :: !Bool
  , rootDir :: !(Path Abs Dir)
  , dbaseFile :: !(Path Abs File)
  }


instance Semigroup GlobalOptions where
  (GlobalOptions v1 r1 d1) <> (GlobalOptions v2 r2 d2) =
    GlobalOptions (v1 <> v2) (r1 <> r2) (d1 <> d2)


instance Monoid GlobalOptions where
  mempty = GlobalOptions mempty mempty mempty


instance HasLogFunc App where
  logFuncL = lens (.logFunc) (\a x -> a {logFunc = x})


instance HasProcessContext App where
  processContextL = lens (.processContext) (\a x -> a {processContext = x})
