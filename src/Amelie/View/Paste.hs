{-# OPTIONS -Wall -fno-warn-name-shadowing #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

-- | Paste views.

module Amelie.View.Paste
  (pasteFormlet
  ,page
  ,pasteLink
  ,pasteRawLink)
  where

import           Amelie.Types
import           Amelie.View.Highlight       (highlightPaste)
import           Amelie.View.Hlint           (viewHints)
import           Amelie.View.Html
import           Amelie.View.Layout

import           Control.Applicative         ((<$>),(<*>),pure)
import           Control.Arrow               ((&&&))
import           Control.Monad               (when)
import           Data.ByteString.UTF8        (toString)
import           Data.List                   (find)
import qualified Data.Map                    as M
import           Data.Monoid.Operator        ((++))
import           Data.Text                   (Text)
import qualified Data.Text                   as T
import           Data.Text.Lazy              (fromStrict)
import           Data.Time.Show              (showDateTime)
import           Data.Traversable
import           Prelude                     hiding ((++))
import           Safe                        (readMay)
import           Text.Blaze.Html5            as H hiding (map)
import qualified Text.Blaze.Html5.Attributes as A
import           Text.Blaze.Html5.Extra
import           Text.Formlet

-- | Render the page page.
page :: PastePage -> Html
page PastePage {ppPaste=p@Paste{..},..} =
  layoutPage $ Page {
    pageTitle = pasteTitle
  , pageBody = do viewPaste ppChans ppLangs p
                  viewHints ppHints
                  viewAnnotations ppChans ppLangs ppAnnotations
  , pageName = "paste"
  }
  
-- | A formlet for paste submission / editing.
pasteFormlet :: PasteFormlet -> (Formlet PasteSubmit,Html)
pasteFormlet pf@PasteFormlet{..} =
  let form = postForm ! A.action "/new" $ do
        when pfSubmitted $
          when (not (null pfErrors)) $
            H.div ! aClass "errors" $
              mapM_ (p . toHtml) pfErrors
        formletHtml (pasteSubmit pf) pfParams
        submitInput "submit" "Submit"
  in (pasteSubmit pf,form)

-- | The paste submitting formlet itself.
pasteSubmit :: PasteFormlet -> Formlet PasteSubmit
pasteSubmit pf@PasteFormlet{..} =
  PasteSubmit
    <$> pure (getPasteId pf)
    <*> req (textInput "title" "Title")
    <*> req (textInput "author" "Author")
    <*> parse (traverse lookupLang)
              (opt (dropInput languages "language" "Language" (snd defChan)))
    <*> parse (traverse lookupChan)
              (opt (dropInput channels "channel" "Channel" (fst defChan)))
    <*> req (areaInput "paste" "Paste")
    <*> opt (wrap (H.div ! aClass "spam") (textInput "email" "Email"))

    where channels = options channelName channelName pfChannels
          languages = options languageName languageTitle pfLanguages
          
          lookupLang slug = findOption ((==slug).languageName) pfLanguages languageId
          lookupChan slug = findOption ((==slug).channelName) pfChannels channelId
          
          defChan = maybe ("","haskell")
                          (channelName &&& trim.channelName)
                          (pfDefChan >>= findChan)
          findChan name = find ((==name).trim.channelName) pfChannels
          trim = T.dropWhile (=='#')

-- | Get the paste id.
getPasteId :: PasteFormlet -> Maybe PasteId
getPasteId PasteFormlet{..} =
  M.lookup "paste_id" pfParams >>=
  readMay . concat . map toString >>=
  return . (fromIntegral :: Integer -> PasteId)

-- | View the paste's annotations.
viewAnnotations :: [Channel] -> [Language] -> [Paste] -> Html
viewAnnotations chans langs pastes = do
  mapM_ (viewPaste chans langs) pastes

-- | View a paste's details and content.
viewPaste :: [Channel] -> [Language] -> Paste -> Html
viewPaste chans langs paste@Paste{..} = do
  pasteDetails chans langs paste
  pasteContent langs paste

-- | List the details of the page in a dark section.
pasteDetails :: [Channel] -> [Language] -> Paste -> Html
pasteDetails chans langs paste@Paste{..} =
  darkSection (fromStrict pasteTitle) $ do
      ul ! aClass "paste-specs" $ do
        detail "Paste" $ pasteLink paste $ "#" ++ show pasteId
        detail "Author" $ pasteAuthor
        detail "Language" $ showLanguage langs pasteLanguage
        detail "Channel" $ showChannel chans pasteChannel
        detail "Created" $ showDateTime pasteDate
        detail "Raw" $ pasteRawLink paste $ ("View raw link" :: Text)
      clear

    where detail title content = do
            li $ do strong (title ++ ":"); toHtml content

-- | Show the paste content with highlighting.
pasteContent :: [Language] -> Paste -> Html
pasteContent langs paste =
  lightNoTitleSection $ highlightPaste langs paste

-- | The href link to a paste.
pasteLink :: ToHtml html => Paste -> html -> Html
pasteLink Paste{..} inner = href ("/" ++ show pasteId) inner

-- | The href link to a paste, raw content.
pasteRawLink :: ToHtml html => Paste -> html -> Html
pasteRawLink Paste{..} inner = href ("/raw/" ++ show pasteId) inner
