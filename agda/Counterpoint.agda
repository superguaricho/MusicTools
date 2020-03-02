{-# OPTIONS --without-K #-}

module Counterpoint where

open import Data.Bool using (Bool; true; false; if_then_else_; _∨_; _∧_; not)
open import Data.Fin using (Fin; #_)
open import Data.Integer using (+_)
open import Data.List using (List; []; _∷_; mapMaybe; map; zip; _++_; concatMap)
open import Data.Maybe using (Maybe; just; nothing)
open import Data.Nat using (suc; _+_; _≡ᵇ_; _<ᵇ_; compare; _∸_; ℕ; zero)
open import Data.Product using (_×_; _,_; proj₁; proj₂; uncurry)
open import Data.Vec using ([]; _∷_; Vec; lookup; drop; reverse)

open import Function using (_∘_)

open import Relation.Binary.PropositionalEquality using (_≡_; refl)

open import Music
open import Note
open import Pitch
open import Interval
open import Util using (pairs)

------------------------------------------------

data BeginningError : Set where
  not158   : PitchInterval → BeginningError

checkBeginning : PitchInterval → Maybe BeginningError
checkBeginning pi@(_ , i) =
  if ((i == per1) ∨ (i == per5) ∨ (i == per8))
  then nothing
  else just (not158 pi)
  
------------------------------------------------

data IntervalError : Set where
  dissonant : Interval → IntervalError
  unison    : Pitch    → IntervalError

intervalCheck : PitchInterval → Maybe IntervalError
intervalCheck (p , i) with isConsonant i | isUnison i
intervalCheck (p , i) | false | _    = just (dissonant i)
intervalCheck (p , i) | _     | true = just (unison p)
intervalCheck (p , i) | _     | _    = nothing

checkIntervals : List PitchInterval → List IntervalError
checkIntervals = mapMaybe intervalCheck

------------------------------------------------

data Motion : Set where
  contrary : Motion
  parallel : Motion
  similar  : Motion
  oblique  : Motion

motion : PitchInterval → PitchInterval → Motion
motion (pitch p , interval i) (pitch q , interval j) =
  let p' = p + i; q' = q + j
  in if i ≡ᵇ j then parallel
     else (if (p ≡ᵇ q) ∨ (p' ≡ᵇ q') then oblique
           else (if p <ᵇ q then (if p' <ᵇ q' then similar  else contrary)
                 else           (if p' <ᵇ q' then contrary else similar)))

data MotionError : Set where
  parallel : PitchInterval → PitchInterval → MotionError
  similar  : PitchInterval → PitchInterval → MotionError

motionCheck : PitchInterval → PitchInterval → Maybe MotionError
motionCheck i1 i2 with motion i1 i2 | isPerfect (proj₂ i2)
motionCheck i1 i2 | contrary | _     = nothing
motionCheck i1 i2 | oblique  | _     = nothing
motionCheck i1 i2 | parallel | false = nothing
motionCheck i1 i2 | parallel | true  = just (parallel i1 i2)
motionCheck i1 i2 | similar  | false = nothing
motionCheck i1 i2 | similar  | true  = just (similar i1 i2)

checkMotion : List PitchInterval → List MotionError
checkMotion = mapMaybe (uncurry motionCheck) ∘ pairs

------------------------------------------------

data EndingError : Set where
  not18    : PitchInterval → EndingError
  not27    : PitchInterval → EndingError
  tooShort : List PitchInterval → EndingError

endingCheck : PitchInterval → PitchInterval → Maybe EndingError
endingCheck pi1@(pitch p , i) (pitch q , interval 0)  = 
  if ((p + 1 ≡ᵇ q) ∧ (i == min3)) then nothing else just (not27 pi1)
endingCheck pi1@(pitch p , i) (pitch q , interval 12) =
  if ((q + 2 ≡ᵇ p) ∧ (i == maj6) ∨ (p + 1 ≡ᵇ q) ∧ (i == min10))
  then nothing
  else just (not27 pi1)
endingCheck pi1               pi2                     =
  just (not18 pi2)

checkEnding : List PitchInterval → PitchInterval → Maybe EndingError
checkEnding []       _ = just (tooShort [])
checkEnding (p ∷ []) q = endingCheck p q
checkEnding (p ∷ ps) q = checkEnding ps q

------------------------------------------------

record FirstSpecies : Set where
  constructor firstSpecies
  field
    firstBar    : PitchInterval
    middleBars  : List PitchInterval
    lastBar     : PitchInterval
    beginningOk : checkBeginning firstBar ≡ nothing
    intervalsOk : checkIntervals middleBars ≡ []
    motionOk    : checkMotion (firstBar ∷ middleBars) ≡ []
                  -- no need to include the last bar,
                  -- since endingOK guarantees contrary motion in the ending
    endingOk    : checkEnding middleBars lastBar ≡ nothing

------------------------------------------------
-- Second Species

PitchInterval2 : Set
PitchInterval2 = Pitch × Interval × Interval

strongBeat : PitchInterval2 → PitchInterval
strongBeat (p , i , _) = p , i

weakBeat : PitchInterval2 → PitchInterval
weakBeat (p , _ , i) = p , i

expandPitchInterval2 : PitchInterval2 → List PitchInterval
expandPitchInterval2 (p , i , j) = (p , i) ∷ (p , j) ∷ []

expandPitchIntervals2 : List PitchInterval2 → List PitchInterval
expandPitchIntervals2 = concatMap expandPitchInterval2

data BeginningError2 : Set where
  not58    : PitchInterval → BeginningError2

checkBeginning2 : PitchInterval → Maybe BeginningError2
checkBeginning2 pi@(_ , i) =
  if ((i == per5) ∨ (i == per8))
  then nothing
  else just (not58 pi)

checkEnding2 : List PitchInterval2 → PitchInterval → Maybe EndingError
checkEnding2 []           _   = just (tooShort [])
checkEnding2 (p ∷ [])     q   = endingCheck (weakBeat p) q
checkEnding2 (_ ∷ p ∷ ps) q   = checkEnding2 (p ∷ ps) q

-- We might want to lift the ordinary interval error to one involving PitchInterval2
-- to give the user more context, but for now keep it simple.

checkStrongBeats : List PitchInterval2 → List IntervalError
checkStrongBeats = checkIntervals ∘ map strongBeat

checkWeakBeat : PitchInterval2 → Pitch → Maybe IntervalError
checkWeakBeat (p , i , j) q with isConsonant j | isUnison j 
checkWeakBeat (p , i , j) q | false | _ =
  if isPassingTone (secondPitch (p , i)) (secondPitch (p , j)) q
  then nothing
  else just (dissonant j)
checkWeakBeat (p , i , j) q | _ | true =
  if isOppositeStep (secondPitch (p , i)) (secondPitch (p , j)) q
  then nothing
  else just (unison p)
checkWeakBeat (p , i , j) q | _ | _    =
  nothing
 
checkWeakBeats : List PitchInterval2 → Pitch → List IntervalError
checkWeakBeats []            p = []
checkWeakBeats pis@(_ ∷ qis) p =
  mapMaybe (uncurry checkWeakBeat)
           (zip pis
                (map (λ {(q , i , j) → proj₂ (pitchIntervalToPitchPair (q , i))}) qis ++ (p ∷ [])))

-- no parallel or similar motion to a perfect interval across bars
-- assumes a bar after the first PitchInterval, and then after every other PitchInterval
checkMotion2 : List PitchInterval → List MotionError
checkMotion2 []           = []
checkMotion2 (_ ∷ [])     = []
checkMotion2 (p ∷ q ∷ ps) = checkMotion (p ∷ q ∷ []) ++ checkMotion2 ps

-- Still more conditions to be added, but these are the main points.
record SecondSpecies : Set where
  constructor secondSpecies
  field
    firstBar      : PitchInterval -- for now require counterpont to start with a rest, which is preferred
    middleBars    : List PitchInterval2
    lastBar       : PitchInterval -- for now require counterpoint to end with only a single whole note, which is preferred
    beginningOk   : checkBeginning2 firstBar ≡ nothing
    strongBeatsOk : checkStrongBeats middleBars ≡ []
    weakBeatsOk   : checkWeakBeats middleBars (secondPitch lastBar) ≡ []
    motionOk      : checkMotion2 (firstBar ∷ (expandPitchIntervals2 middleBars)) ≡ []
    endingOk      : checkEnding2 middleBars lastBar ≡ nothing
