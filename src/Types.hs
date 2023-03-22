{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Types where

import Data.Semigroup (Last (..))
import Path
import RIO
import RIO.Process


defaultRootDir :: SomeBase Dir
defaultRootDir = Abs [absdir|/home/namin/comics|]


defaultDbaseFile :: SomeBase File
defaultDbaseFile = Rel [relfile|mansuki.db|]


data Options = Options
    { globalOptions :: GlobalOptions
    , command :: Command
    }


data GlobalOptions = GlobalOptions
    { verbose :: !Bool
    , rootDir :: !(SomeBase Dir)
    , dbaseFile :: !(SomeBase File)
    }


data Command
    = ListTable Tables
    | AddComic Text (Path Rel Dir)
    deriving (Eq, Show)


data Tables
    = WebsTable
    | ComicsTable
    deriving (Eq, Show)


data App = App
    { logFunc :: !LogFunc
    , processContext :: !ProcessContext
    , options :: !Options
    -- Add other app-specific configuration information here
    }


instance Semigroup GlobalOptions where
    (GlobalOptions v1 r1 d1) <> (GlobalOptions v2 r2 d2) =
        GlobalOptions
            (getLast (Last v1 <> Last v2))
            (getLast (Last r1 <> Last r2))
            (getLast (Last d1 <> Last d2))


instance Monoid GlobalOptions where
    mempty = GlobalOptions False (Rel [reldir|.|]) defaultDbaseFile


instance HasLogFunc App where
    logFuncL = lens (.logFunc) (\a x -> a {logFunc = x})


instance HasProcessContext App where
    processContextL = lens (.processContext) (\a x -> a {processContext = x})
