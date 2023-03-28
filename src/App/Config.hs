{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverlappingInstances #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Config where

import App.Import
import Data.Monoid
import Data.Yaml
import Path
import System.Environment (lookupEnv)
import System.FilePath (splitSearchPath)
import Text.Pretty.Simple


defaultConfigFile :: Path Rel File
defaultConfigFile = [relfile|mansuki.yaml|]


defaultConfig :: Config
defaultConfig =
  Config
    (Rel [reldir|.|])
    (Rel [relfile|mansuki.db|])


readConfig :: MonadIO m => m Config
readConfig = do
  lookupResult <- liftIO $ lookupEnv "XDG_CONFIG_HOME"
  pPrint lookupResult
  case lookupResult of
    Nothing -> return defaultConfig
    Just xdgConfigSearchPath -> do
      readConfigFileResult <-
        liftIO $ foldMap readConfigFile $ splitSearchPath xdgConfigSearchPath
      case getFirst readConfigFileResult of
        Nothing -> return defaultConfig
        Just config -> return config


readConfigFile :: FilePath -> IO (First Config)
readConfigFile x = do
  pPrint x
  return $ First Nothing

-- }

{--
  case parseAbsDir xdgConfigDir of
    Nothing -> return defaultConfig
    Just xdgConfigPath -> do
      decodeResult <-
        liftIO $ decodeFileEither $ toFilePath $ xdgConfigPath </> defaultConfigFile
      case decodeResult of
        Left _ -> return defaultConfig
        Right result -> return result
--}
