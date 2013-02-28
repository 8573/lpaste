{-# OPTIONS -Wall #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Home page controller.

module Amelie.Controller.Home
  (handle)
  where

import Amelie.Controller       (outputText,getMyURI)
import Amelie.Controller.Cache (cache)
import Amelie.Controller.Paste (pasteForm)
import Amelie.Model
import Amelie.Model.Channel    (getChannels)
import Amelie.Model.Language   (getLanguages)
import Amelie.Model.Paste      (getLatestPastes)
import Amelie.Types.Cache      as Key
import Amelie.View.Home        (page)

-- | Handle the home page, display a simple list and paste form.
handle :: Controller ()
handle = do
  html <- cache Key.Home $ do
    pastes <- model $ getLatestPastes
    chans <- model $ getChannels
    langs <- model $ getLanguages
    form <- pasteForm chans langs Nothing Nothing Nothing
    uri <- getMyURI
    return $ Just $ page uri chans langs pastes form
  maybe (return ()) outputText html
