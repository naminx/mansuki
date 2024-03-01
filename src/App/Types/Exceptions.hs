{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Types.Exceptions where

import App.Config
import Data.List (splitAt)
import Data.String.Conversions (ConvertibleStrings, cs)
import Data.String.QM (qm)
import RIO


-- cs' works like cs but truncate the input to maxContentLen and append "..."
cs' :: ConvertibleStrings a String => a -> String
cs' content =
  let (keep, rest) = splitAt maxContentLen $ cs content
   in if not $ null rest
        then keep <> "..."
        else keep


newtype BadChapter = BadChapter String
  deriving (Eq, Show)


instance Exception BadChapter where
  displayException (BadChapter err) =
    cs [qm|Bad Chapter: ${err}|]


newtype UnknownWeb = UnknownWeb String
  deriving (Eq, Show)


instance Exception UnknownWeb where
  displayException (UnknownWeb web) =
    cs [qm|Unknown web: ${web}|]


data InvalidJSON = InvalidJSON String String
  deriving (Eq, Show)


instance Exception InvalidJSON where
  displayException (InvalidJSON json err) =
    [qm|Invalid JSON: "${json}"
${err}|]


newtype InvalidFileExt = InvalidFileExt String
  deriving (Eq, Show)


instance Exception InvalidFileExt where
  displayException (InvalidFileExt ext) =
    [qm|Invalid file extention: "${ext}"|]


newtype InvalidDataURI = InvalidDataURI String
  deriving (Eq, Show)


instance Exception InvalidDataURI where
  displayException (InvalidDataURI datauri) =
    [qm|Invalid data-uri: "${datauri}"|]


newtype InvalidMessage = InvalidMessage String
  deriving (Eq, Show)


instance Exception InvalidMessage where
  displayException (InvalidMessage err) =
    [qm|Invalid message: ${err}|]


newtype UrlNotContainHostName = UrlNotContainHostName String
  deriving (Eq, Show)


instance Exception UrlNotContainHostName where
  displayException (UrlNotContainHostName uri) =
    [qm|URL not contain host name: "${uri}"|]
