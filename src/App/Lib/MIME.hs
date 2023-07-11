{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Lib.MIME where

import Data.Attoparsec.ByteString.Base64 (base64)
import Data.Attoparsec.ByteString.Lazy as Atto (Parser, string)
import Data.ByteString.Base64 (decodeBase64Lenient)
import Data.Char (toLower)
import Data.IMF.Syntax (original)
import Data.MIME (ctSubtype, ctType, parseContentType)
import Data.String.Conversions (cs)
import Data.String.QM (qm)
import RIO
import qualified RIO.Text as T


-- Return (subtype, binary)
-- Subtype is needed to tell whether the binary is JPEG, WEBP, etc.
parseImageData :: Parser (Text, ByteString)
parseImageData = do
  _ <- string "data:"
  contentType <- parseContentType
  let contentTypeStr = map toLower $ show contentType
  when (contentType ^. ctType /= "image") $
    fail [qm|Error: Expecting image/... type, received: ${contentTypeStr}|]
  _ <- string ";base64,"
  base64data <- base64
  let ext = case contentType ^. ctSubtype of
        "jpeg" -> "jpg"
        v -> T.map toLower $ cs $ original v
      bytes = decodeBase64Lenient base64data
  return (ext, bytes)
