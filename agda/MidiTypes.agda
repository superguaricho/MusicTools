{-# OPTIONS --without-K --safe #-}

module MidiTypes where

open import Prelude

-- General MIDI instrument numbers range from 1 to 128,
-- so this is the actual instrument number minus 1.
InstrumentNumber-1 : Type
InstrumentNumber-1 = Fin 128

maxChannels : ℕ
maxChannels = 16
