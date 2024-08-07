{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Main where

import App.Import
import App.Options
import App.Run
import qualified Data.Text.IO as T
import Data.Yaml.Config
import Options.Applicative (execParser)
import RIO
import RIO.Process (mkDefaultProcessContext)
import System.Directory
import Text.Pretty.Simple

main :: IO ()
main = do
    userConfigDir <- getXdgDirectory XdgConfig "mansuki"
    config <-
        loadYamlSettings
            [userConfigDir <> "/mansuki.yaml"]
            [defaultConfig]
            ignoreEnv ::
            IO Config
    options <- execParser userOptions
    logOptions <- logOptionsHandle stderr options.verbose
    procContext <- mkDefaultProcessContext
    withLogFunc logOptions $ \logFunction -> do
        let app =
                App
                    { logFunc = logFunction
                    , processContext = procContext
                    , options = options
                    , comicDir = config.comicDir
                    , dbFile = config.dbFile
                    , allowedOrigins = knownAllowedOrigins
                    }
        runRIO app run
