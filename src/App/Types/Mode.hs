{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Mode (Mode (..)) where

import App.Types.Title
import Data.Aeson (Value)
import Path (Dir, Path, Rel)
import RIO


data Mode
  = NativeMessageHost
  | ListWebs
  | ListComics
  | AddComic Title (Path Rel Dir)
  | RemoveComic Int
  | DisplayVersion
  | DisplayHelp
  | ProduceNativeMessage Value
