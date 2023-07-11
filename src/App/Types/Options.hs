{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Options (Options (..)) where

import App.Types.Mode
import RIO (Bool)


data Options = Options
  { verbose :: !Bool
  , debug :: !Bool
  , mode :: !Mode
  }
