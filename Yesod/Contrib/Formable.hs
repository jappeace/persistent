{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
module Yesod.Contrib.Formable where

import Text.Formlets
import Text.Hamlet
import Text.Hamlet.Monad (hamletToText, htmlContentToText)
import Data.Functor.Identity
import qualified Data.Text as T
import Data.Text.Lazy (toChunks)
import Data.Maybe (isJust, fromJust)
import Data.Time (Day)
import Control.Applicative
import Control.Applicative.Error
import Data.Monoid
import Web.Routes.Quasi (SinglePiece)
import Database.Persist (Persistable)
import Data.Char (isAlphaNum)
import Language.Haskell.TH.Syntax
import Database.Persist (Table (..))
import Database.Persist.Helper (upperFirst)

-- orphans
instance Monad m => Monoid (Hamlet url m ()) where
    mempty = return ()
    mappend = (>>)

class Formable a where
    formable :: (Functor m, Applicative m, Monad m)
             => Formlet (Hamlet url IO ()) m a

class Fieldable a where
    fieldable :: (Functor m, Applicative m, Monad m)
              => String -> Formlet (Hamlet url IO ()) m a

hamletToHtml :: Hamlet a Identity () -> HtmlContent
hamletToHtml =
    Encoded . T.concat . toChunks . runIdentity . hamletToText undefined

pack' :: String -> HtmlContent
pack' = Unencoded . T.pack

repack :: HtmlContent -> HtmlContent
repack = Encoded . htmlContentToText

instance Fieldable [Char] where
    fieldable label = input' go
      where
        go name val = [$hamlet|
%tr
    %th $pack'.label$
    %td
        %input!type=text!name=$pack'.name$!value=$pack'.val$
|]

instance Fieldable HtmlContent where
    fieldable label =
        fmap (Encoded . T.pack)
      . input' go
      . fmap (T.unpack . htmlContentToText)
      where
        go name val = [$hamlet|
%tr
    %th $pack'.label$
    %td
        %textarea!name=$pack'.name$
            $pack'.val$
|]

instance Fieldable Day where
    fieldable label x = input' go (fmap show x) `check` asDay
      where
        go name val = [$hamlet|
%tr
    %th $pack'.label$
    %td
        %input!type=date!name=$pack'.name$!value=$pack'.val$
|]
        asDay s = maybeRead' s "Invalid day"

newtype Slug = Slug { unSlug :: String }
    deriving (Read, Eq, Show, SinglePiece, Persistable)

instance Fieldable Slug where
    fieldable label x = input' go (fmap unSlug x) `check` asSlug
      where
        go name val = [$hamlet|
%tr
    %th $pack'.label$
    %td
        %input!type=text!name=$pack'.name$!value=$pack'.val$
|]
        asSlug [] = Failure ["Slug must be non-empty"]
        asSlug x
            | all (\c -> c `elem` "-_" || isAlphaNum c) x =
                Success $ Slug x
            | otherwise = Failure ["Slug must be alphanumeric, - and _"]

share2 :: Monad m => (a -> m [b]) -> (a -> m [b]) -> a -> m [b]
share2 f g a = do
    f' <- f a
    g' <- g a
    return $ f' ++ g'

deriveFormable :: [Table] -> Q [Dec]
deriveFormable = mapM derive
  where
    derive :: Table -> Q Dec
    derive t = do
        let cols = map (upperFirst . fst) $ tableColumns t
        ap <- [|(<*>)|]
        just <- [|Just|]
        nothing <- [|Nothing|]
        let just' = just `AppE` ConE (mkName $ tableName t)
        let c1 = Clause [ConP (mkName "Nothing") []]
                        (NormalB $ go ap just' $ zip cols $ map (const nothing) cols)
                        []
        xs <- mapM (const $ newName "x") cols
        let xs' = map (AppE just . VarE) xs
        let c2 = Clause [ConP (mkName "Just") $ map VarP xs]
                        (NormalB $ go ap just' $ zip cols xs')
                        []
        return $ InstanceD [] (ConT ''Formable `AppT` ConT (mkName $ tableName t))
            [FunD (mkName "formable") [c1, c2]]
    go ap just' = foldl (ap' ap) just' . map go'
    go' (label, ex) = VarE (mkName "fieldable") `AppE` LitE (StringL label) `AppE` ex
    ap' ap x y = InfixE (Just x) ap (Just y)