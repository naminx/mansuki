{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Types where

import RIO
import RIO.Process

-- | Command line arguments
data Options = Options
    { verbose :: !Bool
    , version :: !Bool
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
