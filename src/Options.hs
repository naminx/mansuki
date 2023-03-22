{-# LANGUAGE NoImplicitPrelude #-}

module Options (cmdOptions) where

import Import (Options)
import Import hiding (Options (command))
import Options.Applicative

cmdOptions :: ParserInfo Options
cmdOptions =
    info
        (userOptions <**> helper)
        ( fullDesc
            <> header "Header for command line arguments "
            <> progDesc "Program description, also for command line arguments"
        )

userOptions :: Parser Options
userOptions =
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
        <|> subparser
            ( command "list" (info listCommand (progDesc "List known webs/comics"))
                <> command "add" (info addCommand (progDesc "Add new comic"))
            )

listCommand :: Parser Command
listCommand = option parseTables mempty
  where
    parseTables = eitherReader strToTable
    strToTable s
        | s == "webs" = Right $ List WebsTable
        | s == "comics" = Right $ List ComicsTable
        | otherwise = Left "Expecting webs/comics"

addCommand :: Parser Command
addCommand = pure Add
