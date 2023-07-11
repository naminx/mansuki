{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Chapter where

import Data.Aeson (FromJSON (parseJSON), ToJSON (toJSON), withText)
import Data.Attoparsec.Text
  ( Parser
  , anyChar
  , decimal
  , endOfInput
  , parseOnly
  , string
  )
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
  ( Alternative (many)
  , Applicative ((<*))
  , Bifunctor (first)
  , Bool (False, True)
  , Either
  , Eq
  , Int
  , Maybe (..)
  , Monad (return, (>>))
  , MonadFail (fail)
  , Ord ((<), (<=), (>))
  , Show (..)
  , String
  , Text
  , either
  , optional
  , otherwise
  , ($)
  , (.)
  , (<=<)
  )
import qualified RIO.Text as T
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
  return $ chap {extra = T.pack extra}


mkChapter :: Text -> Either String Chapter
mkChapter = parseOnly $ chapter <* endOfInput


instance FromJSON Chapter where
  parseJSON = withText "chapter" $ either fail return . mkChapter


instance ToJSON Chapter where
  toJSON = toJSON . show


instance PersistField Chapter where
  toPersistValue chap = PersistText $ T.pack $ show chap
  fromPersistValue = first T.pack . mkChapter <=< fromPersistValueText


instance PersistFieldSql Chapter where
  sqlType _ = SqlString


instance SqlString Chapter
