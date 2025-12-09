{-# OPTIONS --without-K --safe #-}

module Instruments where

open import Data.Fin  using (#_)
open import MidiTypes using (InstrumentNumber-1; maxChannels)
open import Data.Vec        using (Vec; []; _∷_)

-- Start of an instrument list

-- all instruments have this type
piano : InstrumentNumber-1

piano                 = # 0
brightPiano           = # 1
electricGrandPiano    = # 2
honkyTonkPiano        = # 3
electricPiano1        = # 4
electricPiano2        = # 5
harpsichord           = # 6
clavinet              = # 7

celesta               = # 8
vibraphone            = # 11

drawbarOrgan          = # 16
percussiveOrgan       = # 17
rockOrgan             = # 18
churchOrgan           = # 19

acousticGuitar[nylon] = # 24
acousticGuitar[steel] = # 25
electricGuitar[jazz]  = # 26
electricGuitar[clean] = # 27
electricGuitar[muted] = # 28
overdrivenGuitar      = # 29
distortionGuitar      = # 30
guitarHarmonics       = # 31

harp                  = # 46

-- Cuerdas (Strings)
violin                = # 40 -- String Ensemble 1
viola                 = # 41 -- String Ensemble 2
cello                 = # 42 -- String Ensemble 3
contrabass            = # 43 -- String Ensemble 4

-- Maderas (Woodwinds)
flute                 = # 73
oboe                  = # 69
clarinet              = # 71
bassoon               = # 70

-- Metales (Brass)
trumpet               = # 57
trombone              = # 58
tuba                  = # 59
frenchHorn            = # 60

----------------

drums : InstrumentNumber-1
drums      = # 0

----------------

-- Assign piano to all tracks
-- Note that channel 10 (9 as Channel-1) is percussion
pianos : Vec InstrumentNumber-1 maxChannels
pianos =
  piano ∷ -- 1
  piano ∷ -- 2
  piano ∷ -- 3
  piano ∷ -- 4
  piano ∷ -- 5
  piano ∷ -- 6
  piano ∷ -- 7
  piano ∷ -- 8
  piano ∷ -- 9
  drums ∷ -- 10 (percussion)
  piano ∷ -- 11
  piano ∷ -- 12
  piano ∷ -- 13
  piano ∷ -- 14
  piano ∷ -- 15
  piano ∷ -- 16
  []

