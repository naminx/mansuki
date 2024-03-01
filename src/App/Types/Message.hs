{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-partial-fields #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module App.Types.Message where

import App.Lib.URI (URI)
import App.Types.Chapter (Chapter)
import App.Types.Comic (Comic)
import App.Types.Domain (Domain)
import App.Types.Volume (Volume)
import Data.Aeson
  ( FromJSON (parseJSON)
  , KeyValue ((.=))
  , Options (constructorTagModifier)
  , ToJSON (toJSON)
  , camelTo2
  , defaultOptions
  , genericParseJSON
  , object
  )
import Data.String.QM (qm)
import Path (File, Path, Rel)
import RIO (Eq, Generic, Show, Text)


data Message
  = GetKnownWebs
  | GetKnownComics {domain :: Domain}
  | GetWebInfo {url :: URI}
  | GetComicInfos {urls :: [URI]}
  | SaveImage {file :: Path Rel File, uri :: Text}
  | UpdateChapter {comic :: Comic, chapter :: Chapter}
  | UpdateVolume {comic :: Comic, volume :: Volume}
  | UpdateLastVisit {domain :: Domain, url :: URI}
  deriving (Eq, Show, Generic)


instance FromJSON Message where
  parseJSON =
    genericParseJSON defaultOptions {constructorTagModifier = camelTo2 '_'}


-- { "tag" : "save_image"
--   Relative path to comic directory, if the path to the file does not
--     exist (chapter directory etc.), mansuki will create directory(s).
--     as needed.
-- , "file" : ".../..."
-- , "uri" : "data:..."
-- }
instance ToJSON Message where
  toJSON GetKnownWebs =
    object
      ["tag" .= [qm|get_known_webs|]]
  toJSON GetKnownComics {domain} =
    object
      [ "tag" .= [qm|get_known_comics|]
      , "domain" .= domain
      ]
  toJSON GetWebInfo {url} =
    object
      [ "tag" .= [qm|get_web_info|]
      , "url" .= url
      ]
  toJSON GetComicInfos {urls} =
    object
      [ "tag" .= [qm|get_comic_infos|]
      , "urls" .= urls
      ]
  toJSON SaveImage {file, uri} =
    object
      [ "tag" .= [qm|save_image|]
      , "file" .= file
      , "uri" .= uri
      ]
  toJSON UpdateChapter {comic, chapter} =
    object
      [ "tag" .= [qm|update_chapter|]
      , "comic" .= comic
      , "chapter" .= chapter
      ]
  toJSON UpdateVolume {comic, volume} =
    object
      [ "tag" .= [qm|update_volume|]
      , "comic" .= comic
      , "volume" .= volume
      ]
  toJSON UpdateLastVisit {domain, url} =
    object
      [ "tag" .= [qm|update_last_visit|]
      , "domain" .= domain
      , "url" .= url
      ]
