{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Urbit.Azimuth.Contract (
    Contracts(..)
  , getContracts
  , withContract

  , Azimuth(..)
  , runAzimuth
  ) where

import Control.Monad.Trans (lift)
import Control.Monad.Reader (ReaderT(..), ask)
import Data.Solidity.Prim.Address (Address)
import Network.Ethereum.Account (LocalKeyAccount, LocalKey, withAccount)
import qualified Network.Ethereum.Account as Ethereum.Account
import qualified Network.Ethereum.Account.Internal as AI
import qualified Network.Ethereum.Ens as Ethereum.Ens
import Network.JsonRpc.TinyClient (JsonRpc)

-- | Supported Azimuth contracts.
data Contracts = Contracts {
    azimuth  :: Address
  , ecliptic :: Address
  } deriving stock Show

-- | The Azimuth type represents an authenticated connection to a JSON RPC by
--   way of a local private key, and has access to a 'Contracts' object.
newtype Azimuth m a =
    Azimuth (ReaderT Contracts (LocalKeyAccount m) a)
  deriving newtype (Functor, Applicative, Monad)

-- | Run an Azimuth action.
runAzimuth
  :: JsonRpc m
  => Contracts
  -> LocalKey
  -> Azimuth m a
  -> m a
runAzimuth contracts account (Azimuth action) = withAccount account $
  runReaderT action contracts

-- | Fetch the Azimuth and Ecliptic contracts by way of their ENS records.
getContracts :: JsonRpc m => m Contracts
getContracts = withAccount () $ do
  azimuth  <- Ethereum.Ens.resolve "azimuth.eth"
  ecliptic <- Ethereum.Ens.resolve "ecliptic.eth"
  pure Contracts {..}

-- | Perform an Azimuth action, targeting the appropriate contract.
withContract
  :: Monad m
  => (Contracts -> Address)
  -> LocalKeyAccount m a
  -> Azimuth m a
withContract selector action = Azimuth $ do
  contracts <- ask
  lift $ Ethereum.Account.withParam (\param -> param {
    AI._to    = Just (selector contracts)
  -- NB hardcoded to 40 gwei at present
  -- going to want a better way to specify gas price
  , AI._gasPrice = Just 40_000_000_000
  }) action

