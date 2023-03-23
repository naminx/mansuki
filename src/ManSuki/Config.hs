{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module ManSuki.Config where

import Data.Yaml
import Path
import RIO
import System.Environment (lookupEnv)


configFile :: Path Rel File
configFile = [relfile|mansuki.yaml|]


data ConfigData = ConfigData
  { rootDirCfg :: SomeBase Dir
  , dbaseFileCfg :: SomeBase File
  }
  deriving (Eq, Show)


defaultConfig :: ConfigData
defaultConfig =
  ConfigData
    (Rel [reldir|.|])
    (Rel [relfile|mansuki.db|])


instance FromJSON ConfigData where
  parseJSON (Object v) =
    ConfigData
      <$> (v .: "root-directory")
      <*> (v .: "database-file")
  parseJSON _ = error "expecting object"


readConfig :: IO ConfigData
readConfig = do
  lookupResult <- lookupEnv "XDG_CONFIG_HOME"
  case lookupResult of
    Nothing -> return defaultConfig
    Just xdgConfigDir ->
      case parseAbsDir xdgConfigDir of
        Nothing -> return defaultConfig
        Just xdgConfigPath -> do
          decodeResult <-
            decodeFileEither $ toFilePath $ xdgConfigPath </> configFile
          case decodeResult of
            Left _ -> return defaultConfig
            Right result -> return result
