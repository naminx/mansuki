{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Main (main) where

import Import
import Options
import Options.Applicative (execParser)
import RIO.Process
import Run


main :: IO ()
main = do
    programOptions <- execParser userOptions

    logOptions <- logOptionsHandle stderr (programOptions.globalOptions.verbose)
    procContext <- mkDefaultProcessContext
    withLogFunc logOptions $ \logFunction ->
        let app =
                App
                    { logFunc = logFunction
                    , processContext = procContext
                    , options = programOptions
                    }
         in runRIO app run
