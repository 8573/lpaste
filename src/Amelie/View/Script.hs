{-# OPTIONS -Wall -fno-warn-orphans -fno-warn-name-shadowing -fno-warn-unused-do-bind #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeSynonymInstances #-}

-- | Page script.

module Amelie.View.Script
  (script)
  where

import Data.Text.Lazy                (Text,pack)
import HJScript
import HJScript.Objects.JQuery       hiding (prepend,append)
import HJScript.Objects.JQuery.Extra
import Prelude                       hiding ((++),max)

-- | All scripts on the site. Not much to do.
script :: Text
script = pack $ show $ snd $ evalHJScript $ do
  ready $ do
    resizePage
    toggleHints
    togglePaste

-- | Resize the width of the page to match content width.
resizePage :: HJScript ()
resizePage = do
  max <- varWith (int 0)
  each (do max .=. (mathMax 500
                            (mathMax (getWidth this' + 50) (val max)))
           return true)
       (j ".amelie-code")
  each (do setWidth (mathMax (val max) 500)
                    (j ".amelie-wrap")
           return true)
       (j ".amelie-code")
  each (do setWidth (mathMax (getWidth this') 500)
                    (j ".amelie-wrap")
           return true)
       (j ".amelie-latest-pastes")
       
-- | Collapse/expand hints when toggled.
toggleHints :: HJScript ()
toggleHints = do
  each (do this <- varWith this'
           collapse this
           css' "cursor" "pointer" (parent this)
           toggle (expand this)
                  (collapse this)
                  (parent this)
           return true)
       (j ".amelie-hint")

    where collapse o = do
            css "height" "1em" o
            css "overflow" "hidden" o
            return false
          expand o = do
            css "height" "auto" o
            return false

-- | Toggle paste details.
togglePaste :: HJScript ()
togglePaste = do
  each (do btn <- varWith (j "<a href=\"\">Expand</a>")
           this <- varWith this'
           prepend (string " - ") this
           prepend (val btn) this
           details <- varWith (siblings ".amelie-paste-specs" this)
           display btn "none" details
           toggle (display btn "block" details)
                  (display btn "none" details)
                  btn
           return true)
       (j ".amelie-paste-nav")

   where display btn prop o = do
           css "display" prop o
           setText (string caption) btn
           return false
           where caption = if prop == "block" then "Collapse" else "Expand"
