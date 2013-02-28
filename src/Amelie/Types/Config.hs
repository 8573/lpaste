-- | Site-wide configuration.

module Amelie.Types.Config
       (Config(..)
       ,Announcer(..))
       where

import Database.PostgreSQL.Simple (ConnectInfo)
import Network.Mail.Mime (Address)

-- | Site-wide configuration.
data Config = Config {
    configAnnounce        :: Announcer
  , configPostgres        :: ConnectInfo
  , configDomain          :: String
  , configCommits         :: String
  , configRepoURL         :: String
  , configStepevalPrelude :: FilePath
  , configIrcDir          :: FilePath
  , configAdmin           :: Address
  , configSiteAddy        :: Address
  , configCacheDir        :: FilePath
  }

-- | Announcer configuration.
data Announcer = Announcer {
    announceUser :: String
  , announcePass :: String
  , announceHost :: String
  , announcePort :: Int
} deriving (Show)
