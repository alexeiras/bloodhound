{-# LANGUAGE DeriveGeneric #-}

module Database.Bloodhound.Types
       ( defaultCache
       , defaultIndexSettings
       , halfRangeToKV
       , maybeJson
       , maybeJsonF
       , mkSort
       , rangeToKV
       , showText
       , unpackId
       , Version(..)
       , Status(..)
       , Existence(..)
       , NullValue(..)
       , IndexSettings(..)
       , Server(..)
       , Reply(..)
       , EsResult(..)
       , Query(..)
       , Search(..)
       , SearchResult(..)
       , SearchHits(..)
       , ShardResult(..)
       , Hit(..)
       , Filter(..)
       , Seminearring(..)
       , BoolMatch(..)
       , Term(..)
       , GeoPoint(..)
       , GeoBoundingBoxConstraint(..)
       , GeoBoundingBox(..)
       , GeoFilterType(..)
       , Distance(..)
       , DistanceUnit(..)
       , DistanceType(..)
       , DistanceRange(..)
       , OptimizeBbox(..)
       , LatLon(..)
       , Range(..)
       , HalfRange(..)
       , RangeExecution(..)
       , LessThan(..)
       , LessThanEq(..)
       , GreaterThan(..)
       , GreaterThanEq(..)
       , Regexp(..)
       , RegexpFlags(..)
       , FieldName(..)
       , IndexName(..)
       , MappingName(..)
       , DocId(..)
       , CacheName(..)
       , CacheKey(..)
       , BulkOperation(..)
       , ReplicaCount(..)
       , ShardCount(..)
       , Sort(..)
       , SortMode(..)
       , SortOrder(..)
       , SortSpec(..)
       , DefaultSort(..)
       , Missing(..)
       , OpenCloseIndex(..)
       , Method(..)
         ) where

import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as L
import Data.Text (Text)
import qualified Data.Text as T
import Data.Time.Clock (UTCTime)
import Database.Bloodhound.Types.Class
import GHC.Generics (Generic)
import Network.HTTP.Conduit
import qualified Network.HTTP.Types.Method as NHTM

data Version = Version { number          :: Text
                       , build_hash      :: Text
                       , build_timestamp :: UTCTime
                       , build_snapshot  :: Bool
                       , lucene_version  :: Text } deriving (Show, Generic)

data (FromJSON a, ToJSON a) => Status a =
                     Status { ok      :: Bool
                            , status  :: Int
                            , name    :: Text
                            , version :: a
                            , tagline :: Text } deriving (Eq, Show)

newtype ShardCount   = ShardCount   Int deriving (Eq, Show, Generic)
newtype ReplicaCount = ReplicaCount Int deriving (Eq, Show, Generic)

data IndexSettings =
  IndexSettings { indexShards   :: ShardCount
                , indexReplicas :: ReplicaCount } deriving (Eq, Show)

defaultIndexSettings = IndexSettings (ShardCount 3) (ReplicaCount 2)

data Strategy = RoundRobinStrat | RandomStrat | HeadStrat deriving (Eq, Show)

newtype Server = Server String deriving (Eq, Show)

type Reply = Network.HTTP.Conduit.Response L.ByteString
type Method = NHTM.Method

data OpenCloseIndex = OpenIndex | CloseIndex deriving (Eq, Show)

data FieldType = GeoPointType
               | GeoShapeType
               | FloatType
               | IntegerType
               | LongType
               | ShortType
               | ByteType deriving (Eq, Show)

data FieldDefinition =
  FieldDefinition { fieldType :: FieldType } deriving (Eq, Show)

data MappingField =
  MappingField   { mappingFieldName       :: FieldName
                 , fieldDefinition :: FieldDefinition } deriving (Eq, Show)

data Mapping = Mapping { typeName :: Text
                       , fields   :: [MappingField] } deriving (Eq, Show)

data BulkOperation =
    BulkIndex  IndexName MappingName DocId Value
  | BulkCreate IndexName MappingName DocId Value
  | BulkDelete IndexName MappingName DocId
  | BulkUpdate IndexName MappingName DocId Value deriving (Eq, Show)

data EsResult a = EsResult { _index   :: Text
                           , _type    :: Text
                           , _id      :: Text
                           , _version :: Int
                           , found    :: Maybe Bool
                           , _source  :: a } deriving (Eq, Show)

type Sort = [SortSpec]

data SortSpec = DefaultSortSpec DefaultSort
              | GeoDistanceSortSpec SortOrder GeoPoint deriving (Eq, Show)

data DefaultSort =
  DefaultSort { sortFieldName  :: FieldName
              , sortOrder      :: SortOrder
                                  -- default False
              , ignoreUnmapped :: Bool
              , sortMode       :: Maybe SortMode
              , missingSort    :: Maybe Missing
              , nestedFilter   :: Maybe Filter } deriving (Eq, Show)

data SortOrder = Ascending
               | Descending deriving (Eq, Show)

data Missing = LastMissing
             | FirstMissing
             | CustomMissing Text deriving (Eq, Show)

data SortMode = SortMin
              | SortMax
              | SortSum
              | SortAvg deriving (Eq, Show)

mkSort :: FieldName -> SortOrder -> DefaultSort
mkSort fieldName sortOrder = DefaultSort fieldName sortOrder False Nothing Nothing Nothing

type Cache     = Bool -- caching on/off
defaultCache   = False

type PrefixValue = Text

data BooleanOperator = And | Or deriving (Eq, Show)

newtype IndexName           = IndexName String deriving (Eq, Generic, Show)
newtype MappingName         = MappingName String deriving (Eq, Generic, Show)
newtype DocId               = DocId String deriving (Eq, Generic, Show)
newtype QueryString         = QueryString Text deriving (Eq, Show)
newtype FieldName           = FieldName Text deriving (Eq, Show)
newtype CacheName           = CacheName Text deriving (Eq, Show)
newtype CacheKey            = CacheKey  Text deriving (Eq, Show)
newtype Existence           = Existence Bool deriving (Eq, Show)
newtype NullValue           = NullValue Bool deriving (Eq, Show)
newtype CutoffFrequency     = CutoffFrequency Double deriving (Eq, Show)
newtype Analyzer            = Analyzer Text deriving (Eq, Show)
newtype MaxExpansions       = MaxExpansions Int deriving (Eq, Show)
newtype Lenient             = Lenient Bool deriving (Eq, Show)
newtype Tiebreaker          = Tiebreaker Double deriving (Eq, Show)
newtype Boost               = Boost Double deriving (Eq, Show)
newtype MinimumMatch        = MinimumMatch Int deriving (Eq, Show)
newtype MinimumMatchText    = MinimumMatchText Text deriving (Eq, Show)
newtype DisableCoord        = DisableCoord Bool deriving (Eq, Show)
newtype IgnoreTermFrequency = IgnoreTermFrequency Bool deriving (Eq, Show)
newtype MaxQueryTerms       = MaxQueryTerms Int deriving (Eq, Show)
newtype Fuzziness           = Fuzziness Double deriving (Eq, Show)
newtype PrefixLength        = PrefixLength Int deriving (Eq, Show)

unpackId :: DocId -> String
unpackId (DocId docId) = docId

type TrackSortScores = Bool
type From = Int
type Size = Int

data Search = Search { queryBody  :: Maybe Query
                     , filterBody :: Maybe Filter
                     , sortBody   :: Maybe Sort
                       -- default False
                     , trackSortScores :: TrackSortScores
                     , from :: From
                     , size :: Size } deriving (Eq, Show)

data Query = TermQuery                Term (Maybe Boost)
           | QueryMatchQuery          MatchQuery
           | QueryMultiMatchQuery     MultiMatchQuery
           | QueryBoolQuery           BoolQuery
           | QueryBoostingQuery       BoostingQuery
           | QueryCommonTermsQuery    CommonTermsQuery
           | ConstantScoreFilter      Filter Boost
           | ConstantScoreQuery       Query  Boost
           | QueryDisMaxQuery         DisMaxQuery
           | QueryFilteredQuery       FilteredQuery
           | QueryFuzzyLikeThisQuery  FuzzyLikeThisQuery
           | QueryFuzzyLikeFieldQuery FuzzyLikeFieldQuery
           | QueryFunctionScoreQuery  FunctionScoreQuery
             deriving (Eq, Show)

data FuzzyLikeFieldQuery =
  FuzzyLikeFieldQuery { fuzzyLikeField                    :: FieldName
                        -- anaphora is good for the soul.
                      , fuzzyLikeFieldText                :: Text
                      , fuzzyLikeFieldMaxQueryTerms       :: MaxQueryTerms
                      , fuzzyLikeFieldIgnoreTermFrequency :: IgnoreTermFrequency
                      , fuzzyLikeFieldFuzziness           :: Fuzziness
                      , fuzzyLikeFieldPrefixLength        :: PrefixLength
                      , fuzzyLikeFieldBoost               :: Boost
                      , fuzzyLikeFieldAnalyzer            :: Maybe Analyzer
                      } deriving (Eq, Show)

data FuzzyLikeThisQuery =
  FuzzyLikeThisQuery { fuzzyLikeFields              :: [FieldName]
                     , fuzzyLikeText                :: Text
                     , fuzzyLikeMaxQueryTerms       :: MaxQueryTerms
                     , fuzzyLikeIgnoreTermFrequency :: IgnoreTermFrequency
                     , fuzzyLikeFuzziness           :: Fuzziness
                     , fuzzyLikePrefixLength        :: PrefixLength
                     , fuzzyLikeBoost               :: Boost
                     , fuzzyLikeAnalyzer            :: Maybe Analyzer
                     } deriving (Eq, Show)

data FilteredQuery =
  FilteredQuery { filteredQuery  :: Query
                , filteredFilter :: Filter } deriving (Eq, Show)

data DisMaxQuery = DisMaxQuery { disMaxQueries    :: [Query]
                                 -- default 0.0
                               , disMaxTiebreaker :: Tiebreaker
                               , disMaxBoost      :: Maybe Boost
                               } deriving (Eq, Show)
data MatchQuery =
  MatchQuery { matchQueryField           :: FieldName
             , matchQueryQueryString     :: QueryString
             , matchQueryOperator        :: BooleanOperator
             , matchQueryZeroTerms       :: ZeroTermsQuery
             , matchQueryCutoffFrequency :: Maybe CutoffFrequency
             , matchQueryMatchType       :: Maybe MatchQueryType
             , matchQueryAnalyzer        :: Maybe Analyzer
             , matchQueryMaxExpansions   :: Maybe MaxExpansions
             , matchQueryLenient         :: Maybe Lenient } deriving (Eq, Show)

mkMatchQuery :: FieldName -> QueryString -> MatchQuery
mkMatchQuery field query = MatchQuery field query Or ZeroTermsNone Nothing Nothing Nothing Nothing Nothing

data MatchQueryType = MatchPhrase
                    | MatchPhrasePrefix deriving (Eq, Show)

data MultiMatchQuery =
  MultiMatchQuery { multiMatchQueryFields          :: [FieldName]
                  , multiMatchQueryString          :: QueryString
                  , multiMatchQueryOperator        :: BooleanOperator
                  , multiMatchQueryZeroTerms       :: ZeroTermsQuery
                  , multiMatchQueryTiebreaker      :: Maybe Tiebreaker
                  , multiMatchQueryType            :: Maybe MultiMatchQueryType
                  , multiMatchQueryCutoffFrequency :: Maybe CutoffFrequency
                  , multiMatchQueryAnalyzer        :: Maybe Analyzer
                  , multiMatchQueryMaxExpansions   :: Maybe MaxExpansions
                  , multiMatchQueryLenient         :: Maybe Lenient } deriving (Eq, Show)

data MultiMatchQueryType = MultiMatchBestFields
                         | MultiMatchMostFields
                         | MultiMatchCrossFields
                         | MultiMatchPhrase
                         | MultiMatchPhrasePrefix deriving (Eq, Show)

data BoolQuery = BoolQuery { boolQueryMustMatch          :: Maybe Query
                           , boolQueryMustNotMatch       :: Maybe Query
                           , boolQueryShouldMatch        :: Maybe [Query]
                           , boolQueryMinimumShouldMatch :: Maybe MinimumMatch
                           , boolQueryBoost              :: Maybe Boost
                           , boolQueryDisableCoord       :: Maybe DisableCoord
                           } deriving (Eq, Show)

data BoostingQuery = BoostingQuery { positiveQuery :: Maybe Query
                                   , negativeQuery :: Maybe Query
                                   , positiveBoost :: Maybe Boost
                                   , negativeBoost :: Maybe Boost } deriving (Eq, Show)

data CommonTermsQuery =
  CommonTermsQuery { commonQuery              :: QueryString
                   , commonCutoffFrequency    :: CutoffFrequency
                   , commonLowFreqOperator    :: BooleanOperator
                   , commonHighFreqOperator   :: BooleanOperator
                   , commonMinimumShouldMatch :: Maybe CommonMinimumMatch
                   , commonBoost              :: Maybe Boost
                   , commonAnalyzer           :: Maybe Analyzer
                   , commonDisableCoord       :: Maybe DisableCoord
                   } deriving (Eq, Show)

data CommonMinimumMatch = CommonMinimumMatchHighLow MinimumMatchHighLow
                        | CommonMinimumMatch MinimumMatchText deriving (Eq, Show)

data MinimumMatchHighLow =
  MinimumMatchHighLow { lowFreq :: MinimumMatch
                      , highFreq :: MinimumMatch } deriving (Eq, Show)

data Filter = AndFilter [Filter] Cache
            | OrFilter  [Filter] Cache
            | NotFilter Filter   Cache
            | IdentityFilter
            | BoolFilter BoolMatch
            | ExistsFilter FieldName -- always cached
            | GeoBoundingBoxFilter GeoBoundingBoxConstraint GeoFilterType
            | GeoDistanceFilter GeoPoint Distance DistanceType OptimizeBbox Cache
            | GeoDistanceRangeFilter GeoPoint DistanceRange
            | GeoPolygonFilter FieldName [LatLon]
            | IdsFilter MappingName [DocId]
            | LimitFilter Int
            | MissingFilter FieldName Existence NullValue
            | PrefixFilter  FieldName PrefixValue Cache
            | RangeFilter   FieldName (Either HalfRange Range) RangeExecution Cache
            | RegexpFilter  FieldName Regexp RegexpFlags CacheName Cache CacheKey
              deriving (Eq, Show)

data ZeroTermsQuery = ZeroTermsNone | ZeroTermsAll deriving (Eq, Show)

-- lt, lte | gt, gte
newtype LessThan      = LessThan      Double deriving (Eq, Show)
newtype LessThanEq    = LessThanEq    Double deriving (Eq, Show)
newtype GreaterThan   = GreaterThan   Double deriving (Eq, Show)
newtype GreaterThanEq = GreaterThanEq Double deriving (Eq, Show)

data HalfRange = HalfRangeLt  LessThan
               | HalfRangeLte LessThanEq
               | HalfRangeGt  GreaterThan
               | HalfRangeGte GreaterThanEq deriving (Eq, Show)

data Range = RangeLtGt   LessThan GreaterThan
           | RangeLtGte  LessThan GreaterThanEq
           | RangeLteGt  LessThanEq GreaterThan
           | RangeLteGte LessThanEq GreaterThanEq deriving (Eq, Show)

data RangeExecution = RangeExecutionIndex
                    | RangeExecutionFielddata deriving (Eq, Show)

newtype Regexp = Regexp Text deriving (Eq, Show)
data RegexpFlags = RegexpAll
                 | Complement
                 | Interval
                 | Intersection
                 | AnyString
                 | CompInterval
                 | CompIntersection
                 | CompAnyString
                 | IntervalIntersection
                 | IntervalAnyString
                 | IntersectionAnyString deriving (Eq, Show)

halfRangeToKV :: HalfRange -> (Text, Double)
halfRangeToKV (HalfRangeLt  (LessThan n))      = ("lt",  n)
halfRangeToKV (HalfRangeLte (LessThanEq n))    = ("lte", n)
halfRangeToKV (HalfRangeGt  (GreaterThan n))   = ("gt",  n)
halfRangeToKV (HalfRangeGte (GreaterThanEq n)) = ("gte", n)

rangeToKV :: Range -> (Text, Double, Text, Double)
rangeToKV (RangeLtGt   (LessThan m)   (GreaterThan n))   = ("lt",  m, "gt",  n)
rangeToKV (RangeLtGte  (LessThan m)   (GreaterThanEq n)) = ("lt",  m, "gte", n)
rangeToKV (RangeLteGt  (LessThanEq m) (GreaterThan n))   = ("lte", m, "gt",  n)
rangeToKV (RangeLteGte (LessThanEq m) (GreaterThanEq n)) = ("lte", m, "gte", n)

-- phew. Coulda used Agda style case breaking there but, you know, whatever. :)

data Term = Term { termField :: Text
                 , termValue :: Text } deriving (Eq, Show)

data BoolMatch = MustMatch    Term  Cache
               | MustNotMatch Term  Cache
               | ShouldMatch [Term] Cache deriving (Eq, Show)

-- "memory" or "indexed"
data GeoFilterType = GeoFilterMemory
                   | GeoFilterIndexed deriving (Eq, Show)


data LatLon = LatLon { lat :: Double
                     , lon :: Double } deriving (Eq, Show)

data GeoBoundingBox =
  GeoBoundingBox { topLeft     :: LatLon
                 , bottomRight :: LatLon } deriving (Eq, Show)

data GeoBoundingBoxConstraint =
  GeoBoundingBoxConstraint { geoBBField        :: FieldName
                           , constraintBox     :: GeoBoundingBox
                           , bbConstraintcache :: Cache
                           } deriving (Eq, Show)

data GeoPoint =
  GeoPoint { geoField :: FieldName
           , latLon   :: LatLon} deriving (Eq, Show)

data DistanceUnit = Miles
                  | Yards
                  | Feet
                  | Inches
                  | Kilometers
                  | Meters
                  | Centimeters
                  | Millimeters
                  | NauticalMiles deriving (Eq, Show)

data DistanceType = Arc
                  | SloppyArc -- doesn't exist <1.0
                  | Plane deriving (Eq, Show)

data OptimizeBbox = OptimizeGeoFilterType GeoFilterType
                  | NoOptimizeBbox deriving (Eq, Show)

data Distance =
  Distance { coefficient :: Double
           , unit        :: DistanceUnit } deriving (Eq, Show)

data DistanceRange =
  DistanceRange { distanceFrom :: Distance
                , distanceTo   :: Distance } deriving (Eq, Show)

data FromJSON a => SearchResult a =
  SearchResult { took       :: Int
               , timedOut   :: Bool
               , shards     :: ShardResult
               , searchHits :: SearchHits a } deriving (Eq, Show)

type Score = Double

data FromJSON a => SearchHits a =
  SearchHits { hitsTotal :: Int
             , maxScore  :: Score
             , hits      :: [Hit a] } deriving (Eq, Show)

data FromJSON a => Hit a =
  Hit { hitIndex      :: IndexName
      , hitType       :: MappingName
      , hitDocId      :: DocId
      , hitScore      :: Score
      , hitSource     :: a } deriving (Eq, Show)

data ShardResult =
  ShardResult { shardTotal       :: Int
              , shardsSuccessful :: Int
              , shardsFailed     :: Int } deriving (Eq, Show, Generic)

-- defaultFieldMaybeJSON :: Text -> Maybe a -> 
maybeJson field (Just value) = [field .= toJSON value]
maybeJson _ _ = []
maybeJsonF field (Just value) = [field .= fmap toJSON value]
maybeJsonF _ _ = []

showText :: Show a => a -> Text
showText = T.pack . show
