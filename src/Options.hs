{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Options (userOptions) where

import Control.Arrow (left)
import Data.Monoid (Any (..), Last (..))
import Import (Options)
import Import hiding (Options (command))
import Options.Applicative
import Options.Applicative.Simple (simpleVersion)
import Options.Applicative.Types
import Path
import qualified Paths_mansuki


userOptions :: ParserInfo Options
userOptions =
  info
    (helper <*> commandLineOptions)
    ( fullDesc
        <> header "Header for command line arguments "
        <> progDesc "Program description, also for command line arguments"
    )


commandLineOptions :: Parser Options
commandLineOptions =
  uncurry Options
    <$> customSubParser
      globalOpts
      ( listTableCommand
          <> addComicCommand
      )


customSubParser ::
  forall a b.
  Monoid a =>
  Parser a ->
  Mod CommandFields b ->
  Parser (a, b)
customSubParser globals cmds = do
  g1 <- globals
  (g2, r) <- addGlobals $ hsubparser cmds
  pure (g1 <> g2, r)
 where
  addGlobals :: forall c. Parser c -> Parser (a, c)
  addGlobals (NilP x) = NilP $ (mempty,) <$> x
  addGlobals (OptP (Option (CmdReader n cs g) ps)) =
    OptP (Option (CmdReader n cs $ fmap go . g) ps)
   where
    go p = p {infoParser = (,) <$> globals <*> infoParser p}
  addGlobals (OptP o) = OptP ((mempty,) <$> o)
  addGlobals (AltP p1 p2) = AltP (addGlobals p1) (addGlobals p2)
  addGlobals (MultP p1 p2) =
    MultP
      ((\(g2, f) (g1, x) -> (g1 <> g2, f x)) <$> addGlobals p1)
      (addGlobals p2)
  addGlobals (BindP p k) = BindP (addGlobals p) $ \(g1, x) ->
    BindP (addGlobals $ k x) $ \(g2, x') ->
      pure (g1 <> g2, x')


globalOpts :: Parser GlobalOptions
globalOpts =
  versionOption
    <*> ( GlobalOptions
            <$> verboseOption
            <*> rootDirOption
            <*> dbaseFileOption
        )
 where
  versionOption =
    infoOption
      $(simpleVersion Paths_mansuki.version)
      (long "version" <> help "Display version")
  verboseOption =
    Any
      <$> switch
        ( long "verbose"
            <> short 'v'
            <> help "Verbose output?"
        )
  rootDirOption =
    Last
      <$> option
        (eitherReader $ left displayException . fmap Just . parseSomeDir)
        ( short 'r'
            <> long "root"
            <> metavar "DIR"
            <> value Nothing
            <> showDefaultWith (maybe (fromAbsDir defaultRootDir) fromSomeDir)
            <> help "Full path or relative path from current working directory to root directory of comics"
        )
  dbaseFileOption =
    Last
      <$> option
        (eitherReader $ left displayException . fmap Just . parseSomeFile)
        ( short 'b'
            <> long "database"
            <> metavar "FILE"
            <> value Nothing
            <> showDefaultWith (maybe (fromRelFile defaultDbaseFile) fromSomeFile)
            <> help "Full path or relative path from root directory of comics to database file"
        )


listTableCommand :: Mod CommandFields Command
listTableCommand =
  command "list" (info listTableOptions (progDesc "List known webs/comics"))
 where
  listTableOptions =
    ListTable <$> argument parseTables (metavar "[webs|comics]")
  parseTables = eitherReader strToTable
  strToTable s
    | s == "webs" = Right WebsTable
    | s == "comics" = Right ComicsTable
    | otherwise = Left "Expecting webs/comics"


addComicCommand :: Mod CommandFields Command
addComicCommand =
  command "add" (info addComicOptions (progDesc "Add new comic"))
 where
  addComicOptions =
    AddComic
      <$> strOption
        ( short 't'
            <> long "title"
            <> metavar "TITLE"
            <> help "Title of the comic"
        )
      <*> option
        (eitherReader $ left displayException . parseRelDir)
        ( short 'f'
            <> long "folder"
            <> metavar "FOLDER"
            <> help "Folder to store the comic"
        )
