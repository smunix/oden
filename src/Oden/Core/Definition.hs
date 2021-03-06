module Oden.Core.Definition where

import           Oden.Core.Expr
import           Oden.Core.ProtocolImplementation

import           Oden.Metadata
import           Oden.QualifiedName
import           Oden.SourceInfo

import           Oden.Type.Polymorphic

data Definition e
  = Definition (Metadata SourceInfo) QualifiedName (Scheme, e)
  | ForeignDefinition (Metadata SourceInfo) QualifiedName Scheme
  | TypeDefinition (Metadata SourceInfo) QualifiedName [NameBinding] Type
  | ProtocolDefinition (Metadata SourceInfo) QualifiedName Protocol
  | Implementation (Metadata SourceInfo) (ProtocolImplementation e)
  deriving (Show, Eq, Ord)
