{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Main where

import App.Config
import App.Import
import App.Options
import App.Run
import Data.Monoid
import Options.Applicative (execParser)
import Path
import RIO.Process
import System.Directory (getCurrentDirectory)


main :: IO ()
main = do
  yamlConfig <- readConfig
  let configRootDir = yamlConfig.rootDirCfg
      configDbaseFile = yamlConfig.dbaseFileCfg
  programOptions <- execParser $ userOptions configRootDir configDbaseFile
  let logVerbose = getAny programOptions.globalOptions.verboseOpt
  logOptions <- logOptionsHandle stderr logVerbose
  procContext <- mkDefaultProcessContext
  Just cwd <- parseAbsDir <$> getCurrentDirectory
  let globalOpts = programOptions.globalOptions
      absRootDir = case getLast globalOpts.rootDirOpt of
        Just (Abs absDir) -> absDir
        Just (Rel relDir) -> cwd </> relDir
        Nothing -> case configRootDir of
          Abs absDefaultRootDir -> absDefaultRootDir
          Rel relDefaultRootDir -> cwd </> relDefaultRootDir
      absDbaseFile = case getLast globalOpts.dbaseFileOpt of
        Just (Abs absFile) -> absFile
        Just (Rel relFile) -> absRootDir </> relFile
        Nothing -> case configDbaseFile of
          Abs absDefaultDbaseFile -> absDefaultDbaseFile
          Rel relDefaultDbaseFile -> absRootDir </> relDefaultDbaseFile
      app logFunction =
        App
          { logFunc = logFunction
          , processContext = procContext
          , options = programOptions
          , verbose = getAny globalOpts.verboseOpt
          , rootDir = absRootDir
          , dbaseFile = absDbaseFile
          }
  withLogFunc logOptions $ flip runRIO run . app


mainRIO :: RIO App a -> RIO App a
mainRIO action = do
  yamlConfig <- readConfig
  let configRootDir = yamlConfig.rootDirCfg
      configDbaseFile = yamlConfig.dbaseFileCfg
  logOptions <- logOptionsHandle stderr True
  procContext <- mkDefaultProcessContext
  maybeCwd <- parseAbsDir <$> liftIO getCurrentDirectory
  let cwd = fromMaybe [absdir|/|] maybeCwd
      absConfigRootDir = case configRootDir of
        Abs absRootDir -> absRootDir
        Rel relRootDir -> cwd </> relRootDir
      absConfigDbaseFile = case configDbaseFile of
        Abs absDBaseFile -> absDBaseFile
        Rel relDbaseFile -> absConfigRootDir </> relDbaseFile
      app logFunction =
        App
          { logFunc = logFunction
          , processContext = procContext
          , options = Options (GlobalOptions (Any True) mempty mempty) Nop
          , verbose = True
          , rootDir = absConfigRootDir
          , dbaseFile = absConfigDbaseFile
          }
  withLogFunc logOptions $ flip runRIO action . app
