{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Main (main) where

import Import
import Options.Applicative
import Options.Applicative.Simple (simpleVersion)
import qualified Paths_mansuki
import RIO.Process
import Run

main :: IO ()
main = do
    userOptions <- execParser opts

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

opts :: ParserInfo Options
opts =
    info
        (sample <**> helper)
        ( fullDesc
            <> header
                ( "Header for command line arguments "
                    <> $(simpleVersion Paths_mansuki.version)
                )
            <> progDesc "Program description, also for command line arguments"
        )

sample :: Parser Options
sample =
    Options
        <$> switch
            ( long "verbose"
                <> short 'v'
                <> help "Verbose output?"
            )
        <*> switch
            ( long "version"
                <> help "Display version information and exit"
            )
