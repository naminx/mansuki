{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Mode (Mode (..)) where

import App.Types.Chapter
import App.Types.Comic
import App.Types.Title
import Data.Aeson (Value)
import Path (Dir, Path, Rel)


data Mode
  = NativeMessageHost
  | ProduceNativeMessage Value
  | ListWebs
  | ListComics
  | ListAllowedOrigins
  | AddComic Title (Path Rel Dir)
  | RemoveComic Comic
  | SetChapter Comic Chapter
  | DisplayVersion
