{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Chapters where

import App.Types.Chapter (Chapter (extra), chapter, chapterNo)
import Data.Aeson (FromJSON (parseJSON), ToJSON (toJSON), withText)
import Data.Attoparsec.Text
  ( Parser
  , anyChar
  , endOfInput
  , parseOnly
  , string
  )
import RIO
  ( Alternative (many, (<|>))
  , Applicative ((<*))
  , Either
  , Eq
  , Functor (fmap)
  , Maybe (..)
  , Monad (return, (>>))
  , MonadFail (fail)
  , Ord ((<=))
  , Semigroup ((<>))
  , Show (..)
  , String
  , Text
  , either
  , ($)
  , (.)
  )
import qualified RIO.Text as T
import Replace.Attoparsec.Text (anyTill)


data Chapters = Chapters {fromChap :: Chapter, toChap :: Maybe Chapter}
  deriving (Eq)


instance Show Chapters where
  show Chapters {fromChap, toChap} = show fromChap <> "-" <> show toChap


instance Ord Chapters where
  x <= y = x.fromChap <= y.fromChap


chapters :: Parser Chapters
chapters = do
  fromchapNo <- chapterNo
  (residual, tochap) <-
    fmap (fmap Just) (anyTill $ string "-" >> chapter)
      <|> fmap ((,Nothing) . T.pack) (many anyChar)
  return $ Chapters (fromchapNo {extra = residual}) tochap


mkChapters :: Text -> Either String Chapters
mkChapters = parseOnly $ chapters <* endOfInput


instance FromJSON Chapters where
  parseJSON = withText "chapters" $ either fail return . mkChapters


instance ToJSON Chapters where
  toJSON = toJSON . show
