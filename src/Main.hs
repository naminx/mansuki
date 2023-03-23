{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Main where

import Data.Monoid
import Import
import ManSuki.Config
import Options
import Options.Applicative (execParser)
import Path
import RIO.Process
import Run
import System.Directory (getCurrentDirectory)


main :: IO ()
main = do
  yamlConfig <- readConfig
  let defaultRootDir = yamlConfig.rootDirCfg
      defaultDbaseFile = yamlConfig.dbaseFileCfg
  programOptions <- execParser userOptions
  let logVerbose = getAny programOptions.globalOptions.verboseOpt
  logOptions <- logOptionsHandle stderr logVerbose
  procContext <- mkDefaultProcessContext
  Just cwd <- parseAbsDir <$> getCurrentDirectory
  let globalOpts = programOptions.globalOptions
      absRootDir = case getLast globalOpts.rootDirOpt of
        Just (Abs absDir) -> absDir
        Just (Rel relDir) -> cwd </> relDir
        Nothing -> case defaultRootDir of
          Abs absDefaultRootDir -> absDefaultRootDir
          Rel relDefaultRootDir -> cwd </> relDefaultRootDir
      absDbaseFile = case getLast globalOpts.dbaseFileOpt of
        Just (Abs absFile) -> absFile
        Just (Rel relFile) -> absRootDir </> relFile
        Nothing -> case defaultDbaseFile of
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
  logOptions <- logOptionsHandle stderr True
  procContext <- mkDefaultProcessContext
  let app logFunction =
        App
          { logFunc = logFunction
          , processContext = procContext
          , options = Options (GlobalOptions (Any True) mempty mempty) Nop
          , verbose = True
          , rootDir = defaultRootDir
          , dbaseFile = defaultRootDir </> defaultDbaseFile
          }
  withLogFunc logOptions $ flip runRIO action . app
