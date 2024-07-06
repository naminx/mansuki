{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Chapter where

import App.Types.Exceptions
import Data.Aeson (FromJSON (parseJSON), ToJSON (toJSON), withText)
import Data.Attoparsec.Text
  ( Parser
  , anyChar
  , decimal
  , endOfInput
  , parseOnly
  , string
  )
import Data.String.Conversions
import Data.String.QM (qtl)
import Database.Esqueleto.Experimental
  ( PersistField (..)
  , PersistFieldSql (..)
  , PersistValue (PersistText)
  , SqlType (SqlString)
  , fromPersistValueText
  )
import Database.Esqueleto.Internal.Internal (SqlString)
import RIO
import qualified RIO.Text.Lazy as TL


data Chapter = Chapter {chapNo :: Int, section :: Maybe Int, extra :: Text}
  deriving (Eq)


instance Show Chapter where
  show Chapter {chapNo, section, extra} =
    TL.unpack $ case section of
      Just sect -> [qtl|${chapNo}.${sect}${extra}|]
      Nothing -> [qtl|${chapNo}${extra}|]


instance Ord Chapter where
  x <= y
    | x.chapNo < y.chapNo = True
    | x.chapNo > y.chapNo = False
    | x.section < y.section = True
    | x.section > y.section = False
    | otherwise = x.extra <= y.extra


chapterNo :: Parser Chapter
chapterNo = do
  chap <- decimal
  sect <- optional (string "." >> decimal)
  return $ Chapter chap sect ""


chapter :: Parser Chapter
chapter = do
  chap <- chapterNo
  extra <- many anyChar
  return $ chap {extra = cs extra}


mkChapter :: (MonadThrow m, ConvertibleStrings a Text) => a -> m Chapter
mkChapter input = case parseOnly (chapter <* endOfInput) (cs input) of
  Left err -> throwM $ BadChapter err
  Right chap -> return chap


instance FromJSON Chapter where
  parseJSON =
    withText "chapter" $
      either (fail . displayException) return . mkChapter


instance ToJSON Chapter where
  toJSON = toJSON . show


instance PersistField Chapter where
  toPersistValue chap = PersistText $ cs $ show chap
  fromPersistValue =
    first (cs . displayException) . mkChapter <=< fromPersistValueText


instance PersistFieldSql Chapter where
  sqlType _ = SqlString


instance SqlString Chapter
