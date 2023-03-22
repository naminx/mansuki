{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Run (run) where

import Import
import Text.Pretty.Simple (pPrint)


run :: RIO App ()
run = do
    opt <- asks (.options)
    void $ case opt.command of
        v@(ListTable _) -> pPrint v
        v@(AddComic _ _) -> pPrint v
