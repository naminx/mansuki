{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Run (run) where

import Import
import Options.Applicative.Simple (simpleVersion)
import qualified Paths_mansuki
import qualified RIO.Text as T

run :: RIO App ()
run = do
    displayVersion <- asks (.options.version)
    if displayVersion
        then logInfo $ display $ T.pack $(simpleVersion Paths_mansuki.version)
        else do
            optCommand <- asks (.options.command)
            logInfo $ displayShow optCommand
