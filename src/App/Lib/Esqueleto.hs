{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MonoLocalBinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Lib.Esqueleto where

import qualified Data.List.NonEmpty as NE
import qualified Data.Text.Internal.Builder as TLB
import Database.Esqueleto.Experimental
import Database.Esqueleto.Internal.Internal hiding (From, random_)
import RIO hiding (set, (^.))
import qualified RIO.Text.Lazy as TL


(.^) ::
  forall typ val.
  (PersistEntity val, PersistField typ) =>
  SqlExpr (Entity val) ->
  EntityField val typ ->
  SqlExpr (Value typ)
(.^) = (^.)
infixr 9 .^


set_ ::
  PersistEntity val =>
  SqlExpr (Entity val) ->
  [SqlExpr (Entity val) -> SqlExpr Update] ->
  SqlQuery ()
set_ = set


values ::
  (ToSomeValues a, ToAliasReference a, ToAlias a) =>
  NE.NonEmpty a ->
  From a
values exprs = From $ do
  ident <- newIdentFor $ DBName "vq"
  alias <- toAlias $ NE.head exprs
  ref <- toAliasReference ident alias
  let aliasIdents =
        mapMaybe
          (\(SomeValue (ERaw aliasMeta _)) -> sqlExprMetaAlias aliasMeta)
          $ toSomeValues ref
  pure (ref, const $ mkExpr ident aliasIdents)
 where
  someValueToSql :: IdentInfo -> SomeValue -> (TLB.Builder, [PersistValue])
  someValueToSql info (SomeValue expr) = materializeExpr info expr

  mkValuesRowSql :: ToSomeValues a => [Ident] -> IdentInfo -> NE.NonEmpty a -> (TLB.Builder, [PersistValue])
  mkValuesRowSql colIdents info (expr :| []) =
    let materialized = someValueToSql info <$> toSomeValues expr
        valsSql = TLB.toLazyText . fst <$> materialized
        params = concatMap snd materialized
        valueAsColAlias valSql colAlias = valSql <> " AS " <> colAlias
        colsAliases =
          TL.intercalate "," $
            zipWith valueAsColAlias valsSql $
              map (TLB.toLazyText . useIdent info) colIdents
     in ("SELECT " <> TLB.fromLazyText colsAliases, params)
  mkValuesRowSql colIdents info (expr :| exprs_) =
    let (selectValuesAsColAliases, selectParams) =
          mkValuesRowSql colIdents info (expr :| [])
        materialized = map (someValueToSql info) . toSomeValues <$> exprs_
        valsSql =
          TL.intercalate "," . map (TLB.toLazyText . fst) <$> materialized
        params = concat $ concatMap (fmap snd) materialized
     in ( selectValuesAsColAliases
            <> " UNION"
            <> " SELECT * FROM"
            <> (" (VALUES (" <> TLB.fromLazyText (TL.intercalate "),(" valsSql) <> "))")
        , selectParams <> params
        )

  -- Final output:
  -- /* The first line is always output. */
  -- ( SELECT v11 AS "vq"."v", v12 AS "vq"."v2", ...
  --   /* The following is optional, and will be output */
  --   /* only if there are two or more records. */
  --   UNION
  --   SELECT * FROM
  --   (VALUES (v12,..), (v22,..))
  -- ) as "vq"
  mkExpr :: Ident -> [Ident] -> IdentInfo -> (TLB.Builder, [PersistValue])
  mkExpr valsIdent colIdents info =
    let materialized = mkValuesRowSql colIdents info exprs
        valsSql = TLB.toLazyText $ fst materialized
        params = snd materialized
     in ( ("(" <> TLB.fromLazyText valsSql <> ") AS ")
            <> useIdent info valsIdent
        , params
        )
