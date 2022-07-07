{-# OPTIONS --erased-cubical --safe #-}

module NormalForm where

open import Cubical.Core.Everything using (_≡_; Level; Type; Σ; _,_; fst; snd; _≃_; ~_)

open import Cubical.Foundations.Prelude     using (refl; sym; _∙_; cong; transport; subst; funExt; transp; i0; i1)
--open import Cubical.Foundations.Function    using (_∘_)
open import Cubical.Foundations.Univalence  using (ua)
open import Cubical.Foundations.Isomorphism using (iso; Iso; isoToPath; section; retract; isoToEquiv)

open import Data.Bool       using (Bool; false; true; if_then_else_)
open import Data.Integer    using (ℤ; +_; -[1+_])
open import Data.Fin        using (Fin; toℕ; #_; _≟_) renaming (zero to fz; suc to fs)
open import Data.List       using (List; []; _∷_; foldr; length; map)
open import Data.Maybe      using (Maybe; just; nothing) renaming (map to mmap)
open import Data.Nat        using (ℕ; zero; suc; pred; _+_; _*_; _∸_; _≡ᵇ_; _>_; _<ᵇ_)
open import Data.Nat.DivMod using (_mod_; _div_)
open import Data.Product    using (_×_; _,_; proj₁)
open import Data.Vec        using (Vec; []; _∷_; lookup; replicate; _[_]%=_; toList) renaming (map to vmap)

open import Relation.Nullary using (yes; no)

open import BitVec          using (BitVec; insert; empty; show)
open import Util
open import Pitch
open import Interval

-- True iff each element in the first list
-- is ≤ the correspondng element of the second list.
_≤[]_ : List ℕ → List ℕ → Bool
[]       ≤[] ys = true
(x ∷ xs) ≤[] [] = false
(x ∷ xs) ≤[] (y ∷ ys) =
  if x ≡ᵇ y
  then xs ≤[] ys
  else (if x <ᵇ y then true else false)

-- True iff each opci between pcs in the first list
-- is ≤ the correspondng opci between pcs in the second list.
_≤[opci]_ : List PC → List PC → Bool
_≤[opci]_ xs ys =
  (map toℕ (pcIntervals xs)) ≤[]
  (map toℕ (pcIntervals ys))

-- Given a list of pc lists, return the pc list that
-- is is smallest under ≤[opci] ordering. The first argument
-- is the current smallest list, normally passed in as [].
bestPitchClassList : List PC → List (List PC) → List PC
bestPitchClassList xs         []         = xs
bestPitchClassList []         (ys ∷ yss) = bestPitchClassList ys yss
bestPitchClassList xs@(_ ∷ _) (ys ∷ yss) =
  if xs ≤[opci] ys
  then bestPitchClassList xs yss
  else bestPitchClassList ys yss

-- Find the normal form of a pc set.
normalForm : PCSet → List PC
normalForm pcs =
  let xs  = fromPCSet pcs
  in bestPitchClassList [] (iter rotateLeft (pred (length xs)) xs)

-- Find the best normal form of a pc set.
-- The best normal form is the smaller of the normal form of the original set
-- and the inverted set under ≤[opci] ordering.
bestNormalForm : PCSet → List PC
bestNormalForm pcs =
  let xs = normalForm pcs
      ys = normalForm (I pcs)
  in if xs ≤[opci] ys then xs else ys

-- Find the prime form of a pc set.
-- The prime form is the best normal form, normalized so that the first pc is 0.
primeForm : PCSet → List PC
primeForm pcs with bestNormalForm pcs
... | []                    = []
... | xs@(p ∷ _) = map (Tp (toℕ (opposite p))) xs

-- Test

ss : Vec PC 4
ss = # 2 ∷ # 0 ∷ # 5 ∷ # 6 ∷ []
--ss = # 4 ∷ # 7 ∷ # 9 ∷ []
--ss = # 8 ∷ # 9 ∷ # 11 ∷ # 0 ∷ # 4 ∷ []
--ss = # 8 ∷ # 7 ∷ # 4 ∷ # 3 ∷ # 11 ∷ # 0 ∷ []

aa = show (toPCSet (toList ss))
bb = map toℕ (fromPCSet (toPCSet (toList ss)))
cc = map toℕ (normalForm (toPCSet (toList ss)))
dd = map toℕ (bestNormalForm (toPCSet (toList ss)))
ee = map toℕ (primeForm (toPCSet (toList ss)))
ff = icVector (primeForm (toPCSet (toList ss)))
gg = map toℕ (fromPCSet (T 8 (toPCSet (toList ss))))

