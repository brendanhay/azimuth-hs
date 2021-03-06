{-# LANGUAGE DataKinds #-}

module Urbit.Ob.Extended (
    patpToPoint
  , patpToSolidity16
  , patpToSolidity256
  , patpToGalaxy
  , pointToPatp
  ) where

import qualified Data.Solidity.Prim
import qualified Urbit.Ob as Ob

data ObError = InvalidClass Ob.Class

-- | Convert a @p value to an Azimuth point.
--
--   Note that moon, comet, and higher-byte @p values will silently overflow on
--   conversion to a 32-bit Azimuth point!
patpToPoint :: Ob.Patp -> Data.Solidity.Prim.UIntN 32
patpToPoint = fromIntegral . Ob.fromPatp

-- | Convert a @p value to a 256-bit integer.
patpToSolidity256 :: Ob.Patp -> Data.Solidity.Prim.UIntN 256
patpToSolidity256 = fromIntegral . Ob.fromPatp

-- | Convert a star-or-galaxy class @p value to a 16-bit integer.
patpToSolidity16 :: Ob.Patp -> Either ObError (Data.Solidity.Prim.UIntN 16)
patpToSolidity16 patp = case clan of
    Ob.Galaxy -> pure (fromIntegral (Ob.fromPatp patp))
    Ob.Star   -> pure (fromIntegral (Ob.fromPatp patp))
    _         -> Left (InvalidClass clan)
  where
    clan = Ob.clan patp

-- | Convert a galaxy-class @p value to an Azimuth point.
patpToGalaxy :: Ob.Patp -> Either ObError (Data.Solidity.Prim.UIntN 8)
patpToGalaxy patp = case clan of
    Ob.Galaxy -> pure (fromIntegral (Ob.fromPatp patp))
    _         -> Left (InvalidClass clan)
  where
    clan = Ob.clan patp

-- | Convert an Azimuth point to a @p value.
pointToPatp :: Data.Solidity.Prim.UIntN 32 -> Ob.Patp
pointToPatp = Ob.patp . fromIntegral

