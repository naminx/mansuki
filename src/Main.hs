{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Main (main) where

import Import
import Options
import Options.Applicative
import RIO.Process
import Run

main :: IO ()
main = do
    userOptions <- execParser cmdOptions

    lo <- logOptionsHandle stderr (userOptions.verbose)
    pc <- mkDefaultProcessContext
    withLogFunc lo $ \lf ->
        let app =
                App
                    { logFunc = lf
                    , processContext = pc
                    , options = userOptions
                    }
         in runRIO app run
