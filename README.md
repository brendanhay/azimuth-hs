# azimuth-hs

[![Hackage Version](https://img.shields.io/hackage/v/azimuth-hs.svg)](http://hackage.haskell.org/package/azimuth-hs)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)

Interact with [Azimuth](https://github.com/urbit/azimuth-solidity) from
Haskell.

## Basic Usage

You can get started by pulling in `Urbit.Azimuth` (probably qualified):

```
import qualified Urbit.Azimuth as A
```

Friendly wrappers for the Azimuth and Ecliptic contracts can be found in
`Urbit.Azimuth.Azimuth` and `Urbit.Azimuth.Ecliptic`.  They'll both be pulled
in via `import Urbit.Azimuth`.

If you want to work with the raw hs-web3 functions generated from the contract
ABIs, you can import `Urbit.Azimuth.Azimuth.Internal` or
`Urbit.Azimuth.Ecliptic.Internal` directly.

To use the various functions provided, you'll generally want to:

* define a web3 endpoint (probably via
  [hs-web3](https://github.com/airalab/hs-web3)'s `defaultSettings` function,
  re-exported here),

* provide a `Contracts` object (this can be procured via `getContracts`),

* provide a private key, and then,

* use `runAzimuth` to call the desired contract function with the necessary
  information.

You can check out the [quickstart section](#quickstart) below to see an example
of the whole dance.

## Quickstart

This example uses an [Infura](https://infura.io/) endpoint as a provider for
web3:

```
{-# LANGUAGE OverloadedStrings #-}

import qualified Urbit.Azimuth as A
import qualified Urbit.Ob as Ob

-- A simple test endpoint.  You'll probably want to set up your own.
infura :: String
infura = "https://mainnet.infura.io/v3/b7d2af9f01534031ba773374f766ef65"

-- A simple example of setting up an endpoint, fetching the Azimuth contracts,
-- getting a private key from a BIP39 mnemonic and HD path, and fetching ~zod's
-- public information.

main :: IO ()
main = do
  endpoint  <- A.defaultSettings infura
  contracts <- A.runWeb3 endpoint A.getContracts

  let zod = Ob.patp 0
      nec = Ob.patp 1

  -- fetch ~zod's public info, using endpoint's default account
  zodInfo <- A.runWeb3 endpoint $
    A.runAzimuth contracts () $
      A.getPoint zod

  -- to use an account..

  -- use a test mnemonic
  let mnem = "benefit crew supreme gesture quantum "
          <> "web media hazard theory mercy wing kitten"

  -- and a standard HD path
  let hdpath  = "m/44'/60'/0'/0/0" :: A.DerivPath

  let account = case A.toPrivateKey mnem mempty hdpath of
        Left _    -> error "bogus creds"
        Right acc -> acc

  -- fetch ~nec's public info, using a local account
  necInfo <- A.runWeb3 endpoint $
    A.runAzimuth contracts account $
      A.getPoint zod

  -- print the details
  print zodInfo
  print necInfo
```

## Building

Note that depending on your system and GHC installation, a few transitive
dependencies may prove tricky to build.

In particular, if you've installed GHC with [Nix](https://nixos.org/nix), you
may need to build from within a Nix shell with
[zlib-dev](https://www.zlib.net/),
[libsecp256k1](https://github.com/bitcoin-core/secp256k1), and
[pkg-config](https://en.wikipedia.org/wiki/Pkg-config) present.  That can be
done as follows:

```
~/src/azimuth-hs$ nix-shell -p zlib.dev secp256k1 pkg-config
[nix-shell:~src/azimuth-hs]$ cabal new-repl azimuth-hs
```
