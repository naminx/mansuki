{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Options where

import App.Config
import App.Types
import Data.Aeson (json)
import Data.Attoparsec.ByteString.Lazy (endOfInput, parseOnly)
import Data.String.Conversions (cs)
import Options.Applicative
import Path (parseRelDir)
import RIO


userOptions :: ParserInfo Options
userOptions =
  info (opts <**> helper) desc
 where
  opts =
    Options
      <$> switch (long "verbose")
      <*> switch (long "debug")
      <*> ( hsubparser
              ( cmdAddComic -- add
                  <> cmdList -- list
                  <> cmdProduceNativeMsg -- message
                  <> cmdRemoveComic -- remove
                  <> cmdSetChapter -- setchap
                  <> cmdDisplayVersion -- version
              )
              <|> hsubparser cmdNativeMsgHost -- chrome
          )
  desc =
    fullDesc
      <> header "Header for command line arguments "
      <> progDesc appDesc
  appDesc = "mansuki: Native messgage host for google chrome"


cmdNativeMsgHost :: Mod CommandFields Mode
cmdNativeMsgHost =
  mconcat $ map cmdNativeMsgHostFor knownAllowedOrigins


cmdNativeMsgHostFor :: Text -> Mod CommandFields Mode
cmdNativeMsgHostFor allowedOrigin =
  command
    (cs allowedOrigin)
    (info parser mempty)
    <> internal
 where
  parser = pure NativeMessageHost


cmdProduceNativeMsg :: Mod CommandFields Mode
cmdProduceNativeMsg =
  command "message" $ info parser $ progDesc "Produce a native message"
 where
  parser =
    ProduceNativeMessage
      <$> argument
        (eitherReader $ parseOnly (json <* endOfInput) . cs)
        (metavar "JSON")


cmdList :: Mod CommandFields Mode
cmdList =
  command "list" $ info parser $ progDesc "List various information"
 where
  parser =
    flag' ListWebs (short 'w' <> long "webs")
      <|> flag' ListComics (short 'c' <> long "comics")
      <|> flag' ListAllowedOrigins (short 'o' <> long "allowed-origins")


cmdAddComic :: Mod CommandFields Mode
cmdAddComic =
  command "add" $ info parser $ progDesc "Add a new comic"
 where
  parser =
    AddComic
      <$> (Title <$> strArgument (metavar "TITLE"))
      <*> argument
        (eitherReader $ parseRelDir >>> first displayException)
        (metavar "FOLDER")


cmdRemoveComic :: Mod CommandFields Mode
cmdRemoveComic =
  command "remove" $ info parser $ progDesc "Remove a comic"
 where
  parser = RemoveComic <$> (Comic <$> argument auto (metavar "COMIC_NO"))


cmdSetChapter :: Mod CommandFields Mode
cmdSetChapter =
  command "setchap" $ info parser $ progDesc "Set the latest chapter for a comic"
 where
  parser =
    SetChapter
      <$> (Comic <$> argument auto (metavar "COMIC_NO"))
      <*> argument
        (eitherReader $ first displayException . mkChapter)
        (metavar "CHAPTER")


cmdDisplayVersion :: Mod CommandFields Mode
cmdDisplayVersion =
  command "version" $ info parser $ progDesc "Display version"
 where
  parser = pure DisplayVersion
