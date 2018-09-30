unit beatinc;

interface

const
   ImpedOfFreeSpace = 377; (* Ohms *)
   SpeedOfLight = 9.84e8;  (* Ft/sec *)
   pi = 3.1415927;
   ResistCopper = 6.79e-7; (* Ohms inch *)
   ScreenDepth = 24;
   ScreenWidth = 80;
   BIG = 1.0e36;
   SMALL = 1.0e-36;
   MaxOpt = 15;            (* Maximum number of menu selections *)
   MaxUnits = 10;          (* Number of various units required for input *)
   StrLen = 50;            (* Length of string arrays *)
   Iseed = 123;            (* Dummy constant for random0 *)  
   IterationsMax = 100;   (* Max Num of iterations for stat analysis *)


type
   opt = 0..MaxOpt;
   str = string[StrLen];
   strgarray = packed array[1..MaxOpt] of str;
   basearray = array[1..2] of string[8];  (*for unit sys. selection*)
       (* The next two data types are for conversion Metric/Inperial System *)
   unittextarray = array[1..2] of array [1..MaxUnits] of str;
   unitconversionarray = array[1..2] of array [1..MaxUnits] of extended;
   extendedvector = array[0..500] of extended;
   REALorIMAG = (r,i);
   complex = array[REALorIMAG] of extended;

var
   NumSeg:integer;
   SegCap,SegInd,SegRes:extended;
   LineImp,
   EvenLineImp,
   OddLineImp,
   LoadImp,
   IntImped,
   EffImped,
   IntProp,
   IntRes,
   Resist,   (* made global 6/89 to carry over into LadderNetAnal *)
   EmbedHeight,
   IntImpedEmbed,
   IntPropEmbed,
   EffDiConstmicro,
   EffDiConstburied,
   EffProp,
   IntCap,
   IntInd,
   DistCap,
   TraceWidth,
   TraceHeight,
   TraceThick,
   TraceSpacing,
   BackCrossConst,
   ForCrossConst,
   UpCap,
   EvenUpCap,
   OddUpCap,
   LowCap,
   FringeCap,
   EvenFringeCap,
   OddFringeCap,
   OddIntProp,
   EvenIntProp,
   DiConst,
   EffDiConst,
   ReflectionCoef,
   SigPlaneSep,
   TraceLength,
   TRise,
   Period : extended;
   SoldMask : char;
   OptArray : strgarray;
   Header : str;
   SelOpt : opt;
   Ende : boolean;  
   Time, Magnitude:extendedvector;
   NumHarmonics,
   NumPoints,
   UnitSys: integer;              (* 1 - Metric sys, 2 - Imperial sys *)
   base : basearray;              (* Set up as a variable array, since this *)
                                  (* Pascal apparently doesn't allow array- *)
                                  (* type constants.   *)
   InputUnits : unittextarray;    (* see comment above *)
   UnitConversion : unitconversionarray;
     (*********************************************************************)
     (*  Explanation of Unit Conversion                            
         Numerical input data are always requested via GetParam. From now
         on this routine evaluates tow additional parameters: UnitSys and
         UnitSel.
         UnitSys determines whether input will be in the metric or the
         imperial syustem. 
         UnitSel determines which input unit is required.
         So UnitSys and UnitSel act as pointers into InputUnits, which
         tells GetParam what unit the user should be prompted for and
         into UnitConversion which contains a factor to immediately
         convert all input data into the imperial system.                 *)
     (*********************************************************************) 
   FourierCoefDat, OutDat, FreqDat1, FreqDat2 : text;
   NumIterations : integer; (*user selection of num of iterations for stat.*) 
   TraceThickMean,TraceThickSigma,TraceThickVal,  (* Variables for stat. *)
   TraceWidthMean,TraceWidthSigma,TraceWidthVal,  (* Analysis *)
   TraceHeightMean,TraceHeightSigma,TraceHeightVal,
   DiConstMean,DiConstSigma,DiConstVal,
   SigPlaneSepMean,SigPlaneSepSigma,SigPlaneSepVal,
   IntImpedMean,IntImpedSigma,
   IntPropMean,IntPropSigma,
   EffImpedMean,EffImpedSigma,
   EffPropMean,EffPropSigma,
   IntCapMean,IntCapSigma,
   IntInductMean,IntInductSigma,
   IntResistMean,IntResistSigma : extended;
   StatData : array[1..5] of array [1..IterationsMax] of extended;

implementation

end. 
