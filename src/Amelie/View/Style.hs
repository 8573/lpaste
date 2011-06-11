{-# OPTIONS -Wall #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Page style.

module Amelie.View.Style
  (style)
  where

import Data.Monoid.Operator ((++))
import Data.Text.Lazy       (Text)
import Prelude              hiding ((++))
import Text.CSS

-- | Side-wide style sheet.
style :: Text
style = renderCSS $ runCSS $ do
  layout
  sections
  paste
  utils
  highlighter
  form
  home
  browse
  footer
  activity

-- | Footer.
footer :: CSS Rule
footer = do
  classRule "footer" $ do
    textAlign "center"
    subRule "a" $ do 
      textDecoration "none"
    subRule "a:hover" $ do
      textDecoration "underline"

-- | General layout styles.
layout :: CSS Rule
layout = do
  rule "body" $ do
    fontFamily "'DejaVu Sans', sans-serif"
    fontSize "13px"
    textAlign "center"
    
  classRule "logo" $ do
    margin "1em 0 1em 0"
    border "0"
  
  classRule "wrap" $ do
    margin "auto"
    textAlign "left"
    
  classRule "nav" $ do
    float "right"
    marginTop "1em"

-- | Paste form.
form :: CSS Rule
form = do
  inputs
  classRule "spam" $ do
    display "none"
  classRule "errors" $ do
    color "#743838"
    fontWeight "bold"

-- | Input style.
inputs :: CSS Rule
inputs =
  rule "form p label" $ do
    subRule "textarea" $ do
      width "100%"
      height "20em"
      clear "both"
      margin "1em 0 0 0"
         
    subRule "textarea, input.text" $ do
      border "2px solid #ddd"
      borderRadius "4px"
    subRule "textarea:focus, input.text:focus" $ do
      background "#eee"
      
    subRule "span" $ do
      float "left"
      width "7em"
      display "block"

-- | Section styles.
sections :: CSS Rule
sections = do
  classRule "section" $ do
    borderRadius "5px"
    padding "10px"
    border "3px solid #000"
    margin "0 0 1em 0"
     
    subRule "h2" $ do
      margin "0"
      fontSize "1.2em"
      padding "0 0 0.5em 0"
  
  classRule "section-dark" $ do
    background "#453D5B"
    borderColor "#A9A0D2"
    color "#FFF"

    subRule "h2" $ do
      color "#FFF"
    
    subRule "a" $ do
      color "#8ae0c2"
      textDecoration "none"

    subRule "a:hover" $ do
      textDecoration "underline"

  classRule "section-light" $ do
    background "#FFF"
    borderColor "#EEE"
    color "#000"

    subRule "h2" $ do
      color "#2D2542"
   
  classRule "section-error" $ do
    background "#FFDFDF"
    color "#5b4444"
    border "1px solid #EFB3B3"

    subRule "pre" $ do
      margin "0"
    subRule "h2" $ do
      color "#2D2542"
   
  classRule "section-warn" $ do
    background "#FFF9C7"
    color "#915c31"
    border "1px solid #FFF178"
    subRule "pre" $ do
      margin "0"
    subRule "h2" $ do
      color "#2D2542"

-- | Paste view styles.
paste :: CSS Rule
paste = do
  classRule "paste-specs" $ do
    margin "0"
    padding "0"
    listStyle "none"
    lineHeight "1.5em"
    
    subRule "strong" $ do
      fontWeight "normal"
      width "8em"
      display "block"
      float "left"

-- | Utility styles to help with HTML weirdness.
utils :: CSS Rule
utils = do
  classRule "clear" $ do
    clear "both"

-- | A short-hand for prefixing rules with ‘.amelie-’.
classRule :: Text -> CSS (Either Property Rule) -> CSS Rule
classRule = rule . (".amelie-" ++)

-- | Styles for the highlighter.
highlighter :: CSS Rule
highlighter = do
  classRule "code" $ do
    tokens
    lineNumbers

    subRule "pre" $ do
      margin "0"

    subRule "td" $ do
      verticalAlign "top"

-- | Tokens colours and styles.
tokens :: CSS (Either Property Rule)
tokens = do
  subRule "pre" $ do
    marginTop "0"
    tokenColor "comment" "#555"
    tokenColor "keyword" "#397460"
    tokenColor "str" "#366354"
    tokenColor "conid" "#4F4371"
    tokenColor "varop" "#333"
    tokenColor "varid" "#333"
    
  where token name props = subRule (".hs-" ++ name) $ props
        tokenColor name col = token name $ color col

-- | The line number part.
lineNumbers :: CSS (Either Property Rule)
lineNumbers = do
  subRule ".linenodiv" $ do
    margin "0 1em 0 0"
    textAlign "right"

    subRule "a" $ do
      textDecoration "none"
      color "#555"

-- | Home page styles.
home :: CSS Rule
home = do
  rule "#new" wrap
  classRule "browse-link" $ do
    margin "1em 0 0 0"
  
  where wrap = subRule ".amelie-wrap" $ do
                 width "50em"

-- | Browse page styles.
browse :: CSS Rule
browse = do
  classRule "pagination" $ do
    textAlign "center"
    margin "1em"

    subRule ".amelie-inner" $ do
      margin "auto"
      width "15em"

-- | Developer activity page styles.
activity :: CSS Rule
activity = do
  rule "#activity" $ do
    subRule ".amelie-wrap" $ do
      width "50em"
