module Oden.Output.Infer where

import Text.PrettyPrint

import Oden.Infer
import Oden.Infer.Subsumption
import Oden.Output
import Oden.Pretty
import Oden.SourceInfo

instance OdenOutput TypeError where
  outputType _ = Error

  name (UnificationFail _ _ _)                              = "Infer.UnificationFail"
  name (InfiniteType _ _ _)                                 = "Infer.InfiniteType"
  name (NotInScope _ _)                                     = "Infer.NotInScope"
  name (UnificationMismatch _ _ _)                          = "Infer.UnificationMismatch"
  name (ArgumentCountMismatch _ _ _)                        = "Infer.ArgumentCountMismatch"
  name (TypeSignatureSubsumptionError _ SubsumptionError{}) = "Infer.TypeSignatureSubsumptionError"

  header (UnificationFail _ t1 t2) s = text "Cannot unify types"
    <+> code s (pp t1) <+> text "and" <+> code s (pp t2)
  header (InfiniteType _ _ _) _ = text "Cannot construct an infinite type"
  header (NotInScope _ i) s = code s (pp i) <+> text "is not in scope"
  header (UnificationMismatch _ _ _) _ = text "Types do not match"
  header (ArgumentCountMismatch _ as ps) _ | length as > length ps =
    text "Function is applied to too few arguments"
  header (ArgumentCountMismatch _ _ _) _ =
    text "Function is applied to too many arguments"
  header (TypeSignatureSubsumptionError n SubsumptionError{}) s =
    text "Type signature for" <+> strCode s n
    <+> text "does not subsume the type of the definition"

  details (UnificationFail _ _ _) _ = empty
  details (InfiniteType _ v t) s = code s (pp v) <+> equals <+> code s (pp t)
  details (NotInScope _ _) _ = empty
  details (UnificationMismatch _ ts1 ts2) s = vcat (zipWith formatTypes ts1 ts2)
    where formatTypes t1 t2 | t1 == t2 = code s (pp t1) <+> text "==" <+> code s (pp t2)
          formatTypes t1 t2 = code s (pp t1) <+> text "!=" <+> code s (pp t2)
  details (ArgumentCountMismatch _ as1 as2) s =
    text "Expected:" <+> vcat (map (code s . pp) as1)
    $+$ text "Actual:" <+> vcat (map (code s . pp) as2)
    -- TODO: Print something like "In the expression: ..."
  details (TypeSignatureSubsumptionError _ (SubsumptionError _ t1 t2)) s =
    text "Type" <+> code s (pp t1) <+> text "does not subsume" <+> code s (pp t2)

  sourceInfo (ArgumentCountMismatch e _ _)                               = Just (getSourceInfo e)
  sourceInfo (UnificationFail si _ _)                                    = Just si
  sourceInfo (UnificationMismatch si _ _)                                = Just si
  sourceInfo (NotInScope si _)                                           = Just si
  sourceInfo (InfiniteType si _ _)                                       = Just si
  sourceInfo (TypeSignatureSubsumptionError _ (SubsumptionError si _ _)) = Just si
