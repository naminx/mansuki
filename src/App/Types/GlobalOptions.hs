{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.GlobalOptions (GlobalOptions (..)) where

import Data.Monoid (Any (..), Last (..))
import Path (Dir, File, SomeBase)
import RIO


data GlobalOptions = GlobalOptions
  { verbose :: !Any
  , comicDir :: !(Last (SomeBase Dir))
  , dbFile :: !(Last (SomeBase File))
  }
  deriving (Eq, Show)


instance Semigroup GlobalOptions where
  (GlobalOptions v1 r1 d1) <> (GlobalOptions v2 r2 d2) =
    GlobalOptions (v1 <> v2) (r1 <> r2) (d1 <> d2)


instance Monoid GlobalOptions where
  mempty = GlobalOptions mempty mempty mempty
