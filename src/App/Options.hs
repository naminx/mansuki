{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Options where

import App.Config
import App.Types
import Data.Aeson (json)
import Data.Attoparsec.ByteString.Lazy (endOfInput, parseOnly)
import Data.String.Conversions (cs)
import Data.String.QM (qn)
import Options.Applicative
import Path (parseRelDir)
import RIO
import qualified RIO.Text as T


userOptions :: ParserInfo Options
userOptions =
  info (opts <**> helper) desc
 where
  desc =
    fullDesc
      <> header "Header for command line arguments "
      <> progDesc appDesc

  opts =
    Options
      <$> switch (long "verbose")
      <*> switch (long "debug")
      <*> ( fromMaybe NativeMessageHost
              <$> optional
                ( modeListWebs
                    <|> modeListComics
                    <|> modeAddComic
                    <|> modeRemoveComic
                    <|> modeDisplayVersion
                    <|> modeDisplayHelp
                    <|> parseArg
                )
          )
  appDesc = "mansuki: Native messgage host for google chrome"


modeListWebs :: Parser Mode
modeListWebs =
  flag' ListWebs (short 'w' <> long "list-webs")


modeListComics :: Parser Mode
modeListComics =
  flag' ListComics (short 'c' <> long "list-comics")


modeAddComic :: Parser Mode
modeAddComic =
  AddComic
    <$> ( Title
            <$> strOption
              ( short 'a'
                  <> long "add-comic"
                  <> metavar "TITLE"
              )
        )
    <*> option
      (eitherReader $ parseRelDir >>> first displayException)
      ( short 'f'
          <> long "comic-folder"
          <> metavar "FOLDER"
      )


modeRemoveComic :: Parser Mode
modeRemoveComic =
  RemoveComic
    <$> option
      auto
      ( short 'r'
          <> long "remove-comic"
          <> metavar "COMIC_NO"
      )


modeDisplayVersion :: Parser Mode
modeDisplayVersion =
  flag'
    DisplayVersion
    ( short 'v'
        <> long "version"
    )


modeDisplayHelp :: Parser Mode
modeDisplayHelp =
  flag'
    DisplayHelp
    ( short 'h'
        <> long "help"
    )


parseArg :: Parser Mode
parseArg =
  argument
    (eitherReader hostOrProduce)
    (metavar "ALLOWED_ORIGIN | JSON")
 where
  hostOrProduce :: String -> Either String Mode
  hostOrProduce arg =
    if T.pack arg `elem` knownAllowedOrigins
      then Right NativeMessageHost
      else case parseOnly (json <* endOfInput) $ cs arg of
        Left _ ->
          Left [qn|Error: expecting ${listOfKnownAllowedOrigins} or a valid JSON value.|]
        Right val -> Right $ ProduceNativeMessage val
  listOfKnownAllowedOrigins =
    T.unpack $ T.intercalate ",\n" $ map enquote knownAllowedOrigins
  enquote x = "\"" <> x <> "\""
