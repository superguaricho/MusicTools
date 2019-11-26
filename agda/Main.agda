{-# OPTIONS --without-K #-}

module Main where

open import Data.List

open import Midi
open import Note

open import Exercises
--open import Hanon
--open import Montuno
--open import LookVsTime
open import Yamanote

main : IO Unit
main =
  let channel      = 0
      ticksPerBeat = 4 -- 16th notes
      file         = "/Users/leo/Downloads/test.mid"
      song         = ycpTracks
  in exportTracks file ticksPerBeat (map track→htrack song)
