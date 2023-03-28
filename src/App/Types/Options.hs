{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Options (Options (..)) where

import App.Types.Command
import App.Types.GlobalOptions


data Options = Options
  { globalOptions :: GlobalOptions
  , command :: Command
  }
