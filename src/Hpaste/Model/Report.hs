{-# OPTIONS -Wall -fno-warn-name-shadowing #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE ViewPatterns #-}

-- | Report model.

module Hpaste.Model.Report
 (getSomeReports,createReport,countReports)
  where

import           Hpaste.Types
import           Hpaste.Controller.Cache
import           Hpaste.Types.Cache as Key

import           Control.Monad

import           Control.Monad.Env
import           Control.Monad.IO
import           Data.Maybe
import           Data.Monoid.Operator ((++))
import qualified Data.Text as T
import qualified Data.Text.Lazy as LT
import           Network.Mail.Mime
import           Prelude              hiding ((++))
import           Snap.App

-- | Get some paginated reports.
getSomeReports :: Pagination -> Model c s [Report]
getSomeReports Pagination{..} =
  queryNoParams ["SELECT created,paste,comments"
                ,"FROM report"
                ,"ORDER BY id DESC"
                ,"OFFSET " ++ show (max 0 (pnPage - 1) * pnLimit)
                ,"LIMIT " ++ show pnLimit]

-- | Count reports.
countReports :: Model c s Integer
countReports = do
  rows <- singleNoParams ["SELECT COUNT(*)"
                         ,"FROM report"]
  return $ fromMaybe 0 rows

-- | Create a new report.
createReport :: ReportSubmit -> Model Config s (Maybe ReportId)
createReport rs@ReportSubmit{..} = do
  res <- single ["INSERT INTO report"
                ,"(paste,comments)"
                ,"VALUES"
                ,"(?,?)"
                ,"returning id"]
                (rsPaste,rsComments)
  _ <- exec ["UPDATE paste"
       	    ,"SET public = false"
	    ,"WHERE id = ?"]
	    (Only rsPaste)
  let reset pid = do
        resetCacheModel (Key.Paste (fromIntegral pid))
        resetCacheModel (Key.Revision (fromIntegral pid))
  reset rsPaste
  sendReport rs
  return res

sendReport :: ReportSubmit -> Model Config s ()
sendReport ReportSubmit{..} = do
  conf <- env modelStateConfig
  _ <- io $ simpleMail (configAdmin conf)
		       (configSiteAddy conf)
		       (T.pack ("Paste reported: #" ++ show rsPaste))
		       (LT.pack body)
		       (LT.pack body)
		       []
  return ()

  where body =
  	  "Paste " ++ show rsPaste ++ "\n\n" ++
	  rsComments
