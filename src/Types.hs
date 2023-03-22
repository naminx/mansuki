{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Types where

import RIO
import RIO.Process

data Tables
    = WebsTable
    | ComicsTable
    deriving (Eq, Show)

data Command
    = List Tables
    | Add
    deriving (Eq, Show)

-- | Command line arguments
data Options = Options
    { verbose :: !Bool
    , version :: !Bool
    , command :: Command
    }

data App = App
    { logFunc :: !LogFunc
    , processContext :: !ProcessContext
    , options :: !Options
    -- Add other app-specific configuration information here
    }

instance HasLogFunc App where
    logFuncL = lens (.logFunc) (\a x -> a{logFunc = x})

instance HasProcessContext App where
    processContextL = lens (.processContext) (\a x -> a{processContext = x})
