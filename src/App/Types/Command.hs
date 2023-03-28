{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Command (Command (..), Tables (..)) where

import Path (Dir, Path, Rel)
import RIO


data Command
  = ListTable Tables
  | AddComic Text (Path Rel Dir)
  | Nop
  deriving (Eq, Show)


data Tables
  = WebsTable
  | ComicsTable
  deriving (Eq, Show)
