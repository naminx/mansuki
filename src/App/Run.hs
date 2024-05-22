{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE NoFieldSelectors #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}

module App.Run where

import App.Import hiding (link, on)
import App.Types.Domain
import Control.Lens (imap)
import Data.Aeson as JSON (
    Result (..),
    Value,
    encode,
    fromJSON,
    json,
    object,
    (.=),
 )
import qualified Data.Aeson.Encoding as JE
import Data.Attoparsec.ByteString.Lazy (endOfInput, parseOnly)
import Data.Binary.Builder (toLazyByteString)
import Data.Binary.Get (getLazyByteString, getWord32host, runGet)
import Data.Binary.Put (putLazyByteString, putWord32host, runPut)
import Data.String.Conversions (cs)
import Data.String.QM (qt)
import qualified Data.Text.IO as T
import Database.Esqueleto.Experimental hiding (Value, set, (<&>), (^.))
import Options.Applicative.Simple (simpleVersion)
import Path (Abs, File, addExtension, parent, toFilePath, (</>))
import Paths_mansuki (version)
import qualified RIO.ByteString as BS
import qualified RIO.ByteString.Lazy as BL
import System.Directory (createDirectory, doesDirectoryExist)
import Text.URI (
    Authority (Authority, authHost),
    URI (uriAuthority),
    UserInfo (UserInfo),
    emptyURI,
    renderStr,
    unRText,
 )
import Text.URI.QQ (uri)


run :: RIO App ()
run = do
    mode <- asks (.options.mode)
    case mode of
        NativeMessageHost -> runHost
        ListWebs -> runListWebs
        ListComics -> runListComics
        ListAllowedOrigins -> runListAllowedOrigins
        AddComic title folder -> runAddComic title folder
        RemoveComic comic -> runRemoveComic comic
        SetChapter comic chapter -> runSetChapter comic chapter
        DisplayVersion -> runDisplayVersion
        ProduceNativeMessage val -> putMsg val


putMsg :: Value -> RIO App ()
putMsg = BL.putStr . valToMsg


valToMsg :: Value -> BL.ByteString
valToMsg jsonVal =
    runPut $ do
        putWord32host $ fromIntegral $ BL.length payload
        putLazyByteString payload
  where
    payload = toLazyByteString $ JE.fromEncoding $ JE.value jsonVal


runHost :: RIO App ()
runHost = do
    input <- BL.getContents
    let jsonBs = flip runGet input $ do
            len <- getWord32host
            getLazyByteString $ fromIntegral len
    case parseOnly (json <* endOfInput) jsonBs of
        Left err -> do
            throwM $ InvalidJSON (cs' jsonBs) err
        Right result ->
            case (fromJSON result :: Result Message) of
                Error err -> throwM $ InvalidMessage err
                Success msg -> runCommand msg


runListWebs :: RIO App ()
runListWebs = do
    dbFile <- asks (.dbFile)
    allWebs <- queryAllWebInfo dbFile
    traverse_ printWeb allWebs
  where
    printWeb :: WebInfo -> RIO App ()
    printWeb web =
        liftIO
            $ T.putStrLn [qt|${green'}${webWeb}${black'}) ${cyan}${webDomain}${default'}|]
      where
        webWeb = web.web.getWeb
        webDomain = unRText web.domain


runListComics :: RIO App ()
runListComics = do
    dbFile <- asks (.dbFile)
    allComics <- queryAllComicInfo dbFile
    traverse_ printComic allComics
  where
    printComic :: ComicInfo -> RIO App ()
    printComic comic =
        liftIO $ T.putStrLn [qt|${green'}${comicComic}${black'}) ${cyan}${comicTitle}|]
      where
        comicComic = comic.comic.getComic
        comicTitle = comic.title.getTitle


runListAllowedOrigins :: RIO App ()
runListAllowedOrigins =
    liftIO $ traverse_ printMe knownAllowedOrigins
  where
    printMe allowedOrigin =
        T.putStrLn [qt|${green}${allowedOrigin}${default'}|]


runDisplayVersion :: RIO App ()
runDisplayVersion =
    liftIO $ T.putStrLn [qt|${ver}|]
  where
    ver = $(simpleVersion version)


runDisplayHelp :: RIO App ()
runDisplayHelp =
    liftIO
        $ T.putStrLn
            [qt|
Usage:
  mansuki [--verbose]
          [--debug] 
          [ (-w|--list-webs)
          | (-c|--list-comics)
          | (-a|--add-comic TITLE) (-f|--comic-folder FOLDER)
          | (-r|--remove-comic COMIC_NO)
          | (-v|--version)
          | (-h|--help)
          | ALLOWED_ORIGIN
          | JSON
          ]
Global options:
  --verbose
  --debug

Available commands:
  -w, --list-webs                List known webs
  -c, --list-comics              List known comics
  -a, --add-comic TITLE          Add comic, requires -f
  -f, --comic-folder FOLDER      Comic folder, requires -a
  -r, --remove-comic COMIC_NO    Remove comic
  -v, --version                  Display version
  -h, --help                     Display this help text
|]


runCommand :: Message -> RIO App ()
runCommand msg = do
    case msg of
        GetKnownWebs -> runGetKnownWebs
        GetKnownComics {domain} -> runGetKnownComics domain
        GetWebInfo {url} -> runGetWebInfo url
        GetComicInfos {urls} -> runGetComicInfos urls
        SaveImage {file, uri} -> runSaveImage file uri
        UpdateChapter {comic, chapter} -> runUpdateChapter comic chapter
        UpdateVolume {comic, volume} -> runUpdateVolume comic volume
        UpdateLastVisit {domain, url} -> runUpdateLastVisit domain url


runGetKnownWebs :: RIO App ()
runGetKnownWebs = do
    dbFile <- asks (.dbFile)
    bytes <- encode <$> queryKnownWebs dbFile
    BL.putStr $ runPut $ do
        putWord32host $ fromIntegral $ BL.length bytes
        putLazyByteString bytes


queryKnownWebs ::
    (MonadThrow m, MonadUnliftIO m) =>
    Path Abs File
    -> m [Domain]
queryKnownWebs dbFile =
    fmap (.domain) <$> queryAllWebInfo dbFile


runGetKnownComics :: Domain -> RIO App ()
runGetKnownComics domain = do
    dbFile <- asks (.dbFile)
    bytes <- encode <$> queryKnownComics dbFile domain
    BL.putStr $ runPut $ do
        putWord32host $ fromIntegral $ BL.length bytes
        putLazyByteString bytes


queryKnownComics ::
    (MonadThrow m, MonadUnliftIO m) =>
    Path Abs File
    -> Domain
    -> m [ComicInfo]
queryKnownComics dbFile domain = do
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ (map unValues <$>)
        . runSqlConn query
  where
    https domain path = val [uri|https://|] ++. castString domain ++. path
    query = select $ do
        webs :& urls :& comics <-
            from
                $ table @Webs
                `InnerJoin` table @Urls
                `on` (\(webs :& urls) -> webs.web ==. urls.web)
                `InnerJoin` table @Comics
                `on` (\(_ :& urls :& comics) -> urls.comic ==. comics.comic)
        where_ (webs.domain ==. val domain)
        orderBy [asc comics.folder]
        return
            ( comics.comic
            , https webs.domain urls.path
            , comics.title
            , comics.folder
            , comics.volume
            , comics.chapter
            )
    unValues (comic, url, title, folder, volume, chapter) =
        ComicInfo
            { comic = unValue comic
            , url = unValue url
            , title = unValue title
            , folder = unValue folder
            , volume = unValue volume
            , chapter = unValue chapter
            }


runGetWebInfo :: URI -> RIO App ()
runGetWebInfo url = do
    dbFile <- asks (.dbFile)
    bytes <- encode <$> queryWebInfo dbFile url
    BL.putStr $ runPut $ do
        putWord32host $ fromIntegral $ BL.length bytes
        putLazyByteString bytes


queryWebInfo ::
    (MonadThrow m, MonadUnliftIO m) =>
    Path Abs File
    -> URI
    -> m WebInfo
queryWebInfo dbFile url =
    case url.uriAuthority of
        Left _ -> throwM $ UrlNotContainHostName $ renderStr url
        Right Authority {authHost} -> do
            allWebInfo <- queryAllWebInfo dbFile
            case filter ((.domain) >>> (== authHost)) allWebInfo of
                [] -> throwM $ UnknownWeb $ renderStr url
                result : _ -> return result


queryAllWebInfo ::
    (MonadThrow m, MonadUnliftIO m) =>
    Path Abs File
    -> m [WebInfo]
queryAllWebInfo dbFile =
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ (map unValues <$>)
        . runSqlConn query
  where
    query = select $ do
        webs <- from $ table @Webs
        orderBy [asc webs.web]
        return
            ( webs.web
            , webs.domain
            , webs.username
            , webs.password
            , webs.lastVisit
            , webs.getNthPage
            , webs.getComics
            , webs.getLatestChap
            , webs.getChapters
            , webs.getImages
            )
    unValues
        ( web
            , domain
            , username
            , password
            , lastVisit
            , getNthPage
            , getComics
            , getLatestChap
            , getChapters
            , getImages
            ) =
            WebInfo
                { web = unValue web
                , domain = unValue domain
                , userInfo =
                    unValue username <&> flip UserInfo (unValue password)
                , lastVisit = unValue lastVisit
                , getNthPage = unValue getNthPage
                , getComics = unValue getComics
                , getLatestChap = unValue getLatestChap
                , getChapters = unValue getChapters
                , getImages = unValue getImages
                }


queryAllComicInfo ::
    (MonadThrow m, MonadUnliftIO m) =>
    Path Abs File
    -> m [ComicInfo]
queryAllComicInfo dbFile =
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ (map unValues <$>)
        . runSqlConn query
  where
    query = select $ do
        comics <- from $ table @Comics
        orderBy [asc comics.comic]
        return
            ( comics.comic
            , comics.title
            , comics.folder
            , comics.volume
            , comics.chapter
            )
    unValues
        ( comic
            , title
            , folder
            , volume
            , chapter
            ) =
            ComicInfo
                { comic = unValue comic
                , url = emptyURI
                , title = unValue title
                , folder = unValue folder
                , volume = unValue volume
                , chapter = unValue chapter
                }


runGetComicInfos :: [URI] -> RIO App ()
runGetComicInfos urls = do
    dbFile <- asks (.dbFile)
    bytes <- encode <$> queryComicInfos dbFile urls
    BL.putStr $ runPut $ do
        putWord32host $ fromIntegral $ BL.length bytes
        putLazyByteString bytes


-- Lookup for comics.
-- This version keeps the order of comics supplied
-- by means of immediate index & values table.
queryComicInfos :: MonadUnliftIO m => Path Abs File -> [URI] -> m [ComicInfo]
queryComicInfos _ [] = return []
queryComicInfos dbFile (link : links) =
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ (map unValues <$>)
        . runSqlConn query
  where
    https domain path = val [uri|https://|] ++. castString domain ++. path
    enval i n = (val i, val n)
    query = select $ do
        _ :& urls :& comics :& (idx, url) <-
            {- HLINT ignore "Fuse on/on" -}
            from
                $ table @Webs
                `InnerJoin` table @Urls
                `on` (\(webs :& urls) -> webs.web ==. urls.web)
                `InnerJoin` table @Comics
                `on` (\(_ :& urls :& comics) -> urls.comic ==. comics.comic)
                `InnerJoin` from (values $ imap enval $ link :| links)
                `on` ( \(webs :& urls :& _ :& (_, url)) ->
                        https webs.domain urls.path ==. url
                     )
        orderBy [asc idx]
        return
            ( urls.comic
            , url
            , comics.title
            , comics.folder
            , comics.volume
            , comics.chapter
            )
    unValues (comic, url, title, folder, volume, chapter) =
        ComicInfo
            { comic = unValue comic
            , url = unValue url
            , title = unValue title
            , folder = unValue folder
            , volume = unValue volume
            , chapter = unValue chapter
            }


runSaveImage :: Path Rel File -> Text -> RIO App ()
runSaveImage relBase dataUri =
    case parseOnly (parseImageData <* endOfInput) (cs dataUri) of
        Left _ ->
            throwM $ InvalidDataURI $ cs' dataUri
        Right (ext, byteData) -> do
            let dotExt = cs [qt|.${ext}|]
                absBase = defaultComicDir </> relBase
            mkDirs $ parent absBase
            case addExtension dotExt absBase of
                Left _ -> throwM $ InvalidFileExt $ cs ext
                Right absFile -> do
                    BS.writeFile (toFilePath absFile) byteData
                    let bytes = encode $ object ["size" .= BS.length byteData]
                    BL.putStr $ runPut $ do
                        putWord32host $ fromIntegral $ BL.length bytes
                        putLazyByteString bytes
  where
    mkDirs :: MonadUnliftIO m => Path Abs Dir -> m ()
    mkDirs dir = do
        dirExists <- liftIO $ doesDirectoryExist $ toFilePath dir
        unless dirExists $ liftIO $ do
            mkDirs $ parent dir
            createDirectory $ toFilePath dir


runUpdateChapter :: Comic -> Chapter -> RIO App ()
runUpdateChapter comic chapter = do
    dbFile <- asks (.dbFile)
    count <- updateChapter dbFile comic chapter
    let bytes = encode $ object ["count" .= count]
    BL.putStr $ runPut $ do
        putWord32host $ fromIntegral $ BL.length bytes
        putLazyByteString bytes


updateChapter :: MonadUnliftIO m => Path Abs File -> Comic -> Chapter -> m Int
updateChapter dbFile comic chapter =
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ runSqlConn
        $ fromIntegral
        <$> query
  where
    query = updateCount $ \row -> do
        set_ row [ComicsChapter =. val chapter]
        where_ $ row.comic ==. val comic


runUpdateVolume :: Comic -> Volume -> RIO App ()
runUpdateVolume comic volume = do
    dbFile <- asks (.dbFile)
    count <- updateVolume dbFile comic volume
    let bytes = encode $ object ["count" .= count]
    BL.putStr $ runPut $ do
        putWord32host $ fromIntegral $ BL.length bytes
        putLazyByteString bytes


updateVolume :: MonadUnliftIO m => Path Abs File -> Comic -> Volume -> m Int
updateVolume dbFile comic volume =
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ runSqlConn
        $ fromIntegral
        <$> query
  where
    query = updateCount $ \row -> do
        set_ row [ComicsVolume =. val volume]
        where_ $ row.comic ==. val comic


runUpdateLastVisit :: Domain -> URI -> RIO App ()
runUpdateLastVisit domain url = do
    dbFile <- asks (.dbFile)
    count <- updateLastVisit dbFile domain url
    let bytes = encode $ object ["count" .= count]
    BL.putStr $ runPut $ do
        putWord32host $ fromIntegral $ BL.length bytes
        putLazyByteString bytes


updateLastVisit :: MonadUnliftIO m => Path Abs File -> Domain -> URI -> m Int
updateLastVisit dbFile domain url =
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ runSqlConn
        $ fromIntegral
        <$> query
  where
    query = updateCount $ \row -> do
        set_ row [WebsLastVisit =. val url]
        where_ $ row.domain ==. val domain


runAddComic :: Title -> Path Rel Dir -> RIO App ()
runAddComic title folder = do
    dbFile <- asks (.dbFile)
    insertComic dbFile title folder


insertComic ::
    (MonadThrow m, MonadUnliftIO m) =>
    Path Abs File
    -> Title
    -> Path Rel Dir
    -> m ()
insertComic dbFile title folder = do
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ runSqlConn
        $ do
            rawExecute "PRAGMA foreign_keys = ON;" []
            -- SELECT MIN(comic)
            --   FROM comics
            --  WHERE folder > '...';
            result <- select $ do
                comics <- from $ table @Comics
                where_ $ comics.folder >=. val folder
                return $ min_ comics.comic
            case mapMaybe unValue result of
                comic : _ -> do
                    -- UPDATE comics
                    --    SET comic = -1 - comic
                    --  WHERE comic >= comicNo;
                    update $ \comics -> do
                        set_ comics [ComicsComic =. val (Comic $ -1) -. comics.comic]
                        where_ $ comics.comic >=. val comic
                    -- UPDATE comics
                    --    SET comic = -comic
                    --  WHERE comic < 0;
                    update $ \comics -> do
                        set_ comics [ComicsComic =. val (Comic 0) -. comics.comic]
                        where_ $ comics.comic <. val (Comic 0)
                    insertIntoComics comic title folder
                _ -> do
                    -- SELECT MAX(comic)+1
                    --   FROM comics;
                    result <- select $ do
                        comics <- from $ table @Comics
                        return $ max_ (comics.comic +. val (Comic 1))
                    case mapMaybe unValue result of
                        comic : _ -> do
                            insertIntoComics comic title folder
                        _ ->
                            insertIntoComics (Comic 1) title folder
  where
    insertIntoComics comic title folder =
        insert_
            $ Comics
                comic
                title
                folder
                (Volume 0)
                (Chapter 0 Nothing "")


runRemoveComic :: Comic -> RIO App ()
runRemoveComic (Comic comic) = do
    dbFile <- asks (.dbFile)
    bracket (createSqlBackend dbFile) (liftIO . close')
        $ runSqlConn
        $ do
            -- DELETE FROM comics
            --  WHERE comic
            delete $ do
                comics <- from $ table @Comics
                where_ $ comics.comic ==. val (Comic comic)
            -- UPDATE comics
            --    SET comic = 1 - comic
            --  WHERE comic > comicNo;
            update $ \comics -> do
                set_ comics [ComicsComic =. val (Comic 1) -. comics.comic]
                where_ $ comics.comic >. val (Comic comic)
            -- UPDATE comics
            --    SET comic = -comic
            --  WHERE comic < 0;
            update $ \comics -> do
                set_ comics [ComicsComic =. val (Comic 0) -. comics.comic]
                where_ $ comics.comic <. val (Comic 0)


runSetChapter :: Comic -> Chapter -> RIO App ()
runSetChapter comic chapter = do
    dbFile <- asks (.dbFile)
    void $ updateChapter dbFile comic chapter
