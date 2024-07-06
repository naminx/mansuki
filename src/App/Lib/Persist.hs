{-# LANGUAGE NoImplicitPrelude #-}

module App.Lib.Persist where

import Database.Persist.Sqlite
import Database.Sqlite (open)
import Path (Abs, File, Path, toFilePath)
import RIO
import qualified RIO.Text as T (pack)


createSqlBackend :: MonadUnliftIO m => Path Abs File -> m SqlBackend
createSqlBackend dbFilePath = do
  conn <- liftIO $ open filePath
  liftIO $ wrapConnectionInfo (mkSqliteConnectionInfo filePath) conn defaultLogFunc
 where
  filePath = T.pack $ toFilePath dbFilePath
  defaultLogFunc _ _ _ _ = return ()
