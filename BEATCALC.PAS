unit beatcalc;

interface

procedure LineImped (var LineImp : extended; Prop,LowCap,UpCap1,UpCap2,FringeCap1,FringeCap2 : extended);
procedure PropConst (var IntProp : extended; LowCap, UpCap1, UpCap2, FringeCap1, FringeCap2 : extended);
procedure LinCap (var LowCap, UpCap, FringeCap : extended);
procedure EvenLineCap ( var EvenUpCap, EvenFringeCap : extended);
procedure OddLineCap ( var OddUpCap, OddFringeCap : extended);
function IntCapac( IntImped,IntProp : extended) : extended;
function RNDNormal(center, sigma :extended) : extended;
function IntInduct( IntImped,IntProp : extended) : extended;
function IntResist( TraceThick,TraceWidth : extended) : extended;
function LoadAdjust (IntCap, DistCap : extended) : extended;

implementation
 uses crt, math, beatio, beatinc, beatmath;
 
(**************************************************************************)
function RNDNormal(center, sigma :extended) : extended;
(*
    This routine uses the built-in random number generator (which generates
    a uniform distribution between 0 and +1) and transforms this into
    a normal distribution with parameters mean (center) and standard
    deviation (sigma).
    This routine was derived from a similar algorithm by D.E. Knuth in
    "The Art of Computer Programming", volume 2, chapter 3.4.1,
    algorithm P                                                           *)
(**************************************************************************)

var u1,u2,v1,v2,s : real;

begin
  repeat 
    u1 := random(); 
    u2 := random();
    v1 := 2*u1-1;   (* Shift distribution from 0 .. +1  to  -1 .. +1 *)
    v2 := 2*u2-1;
    s := v1*v1 + v2*v2;
  until s<1; 
  RNDNormal := v1 * sqrt((-2)*ln(s)/s) * sigma + center;
end; (* RNDNormal *)

(****************************************************************************)
procedure LineImped;
(*                                                                          *)
(* Calculates the line impedance of a microstrip trace using the model      *)
(* defined by Schwarzmann in his paper "Microstrip plus equations adds      *)
(* up to fast designs". He breaks the line capacitance up into:             *)
(*                                                                          *)
(*   Cppu := the upper plate capacitance (UpCap1 and UpCap2)                *)
(*   Cpp  := the lower plate capacitance (LowCap)                           *)
(*   Cf1  & Cf2 := the fringe capacitances (FringeCap1 & FringeCap2)        *)
(*                                                                          *)
(* The capacitance values passed depend on the presense of adjacent traces  *)
(* such as bus structures or whether we are calculated the odd or even mode *)
(* impednaces.                                                              *)
(*                                                                          *)
(* The impedance is then equal to the propagation constant divided by the   *)
(* total line capacitance (TotalCap).  The propagation constant passed      *)
(* will be different for different line coatings and odd and even modes.    *)
(*                                                                          *)
(****************************************************************************)

var
   TotalCap : real;

begin
   TotalCap := LowCap + FringeCap1 + FringeCap2 + UpCap1 + UpCap2;
   LineImp := (Prop*1e-9) / (TotalCap*1e-12);
end (* LineImped *);

(****************************************************************************)
procedure PropConst;
(*                                                                          *)
(* Calculates the propagation constant of a microstrip trace using the model*)
(* defined by Schwarzmann in his paper "Microstrip plus equations adds      *)
(* up to fast designs". He breaks the line capacitance up into:             *)
(*                                                                          *)
(*   Cppu := the upper plate capacitance (UpCap1 and UpCap2)                *)
(*   Cpp  := the lower plate capacitance (LowCap)                           *)
(*   Cf1  & Cf2 := the fringe capacitances (FringeCap1 & FringeCap2)        *)
(*                                                                          *)
(* The capacitance values passed depend on the presense of adjacent traces  *)
(* such as bus structures or whether we are calculated the odd or even mode *)
(* impednaces.                                                              *)
(*                                                                          *)
(* The impedance is then equal to the propagation constant divided by the   *)
(* total line capacitance (TotalCap).  The propagation constant passed      *)
(* will be different for different line coatings and odd and even modes.    *)
(*                                                                          *)
(****************************************************************************)

var
   Cap,
   VelSub,
   VelConst : real;

begin
   Cap := LowCap + FringeCap1 + FringeCap2 + UpCap1 + UpCap2;
   VelSub :=1/(1 + ((FringeCap1 + FringeCap2)*(DiConst/EffDiConst - 1) + (UpCap1 + UpCap2)*(sqrt(DiConst) - 1))/Cap);
   VelConst :=1/sqrt(1 + sqr(VelSub)*(DiConst -1));
   IntProp :=1/(SpeedOfLight * VelConst) * 1e9;
end (* PropConst *);


(****************************************************************************)
procedure LinCap;
(*                                                                          *)
(* Calculates the capacitances of a microstrip trace using the model        *)
(* defined by Schwarzmann in his paper "Microstrip plus equations adds      *)
(* up to fast designs" for an isolated conductor. He breaks the line        *)
(* capacitance up into:                                                     *)
(*                                                                          *)
(*   Cppu := the upper plate capacitance                                    *)
(*   Cpp  := the lower plate capacitance                                    *)
(*   Cf   := the fringe capacitance                                         *)
(*                                                                          *)
(****************************************************************************)

var
   CommonTerm : real;

begin
   CommonTerm :=DiConst / (SpeedOfLight * ImpedOfFreeSpace);
   LowCap := CommonTerm * TraceWidth / TraceHeight * 1e12;
   UpCap := 2/6 * (LowCap/sqrt(DiConst));
   FringeCap := CommonTerm*(EffDiConst/DiConst) * pi / ln(4*TraceHeight/TraceThick) * 1e12;
end (* LinCap *);

(****************************************************************************)
procedure EvenLineCap;
(*                                                                          *)
(* Calculates the capacitances of a microstrip trace using the model        *)
(* defined by Schwarzmann in his paper "Microstrip plus equations adds      *)
(* up to fast designs" two conductors - even-mode.  He defines two new line *)
(* capacitances:                                                            *)
(*                                                                          *)
(*   Cppue := the even-mode upper plate capacitance (EvenUpCap)             *)
(*   Cfe  := the even-mode fringe capacitance (EvenFringeCap)               *)
(*                                                                          *)
(****************************************************************************)

var
   EvenCoupConst : real;

begin
   EvenCoupConst :=1 / ((TraceWidth / TraceSpacing) + 1);
   EvenUpCap := UpCap * EvenCoupConst;
   EvenFringeCap := FringeCap * EvenCoupConst;
end (* EvenLineCap *);

(****************************************************************************)
procedure OddLineCap;
(*                                                                          *)
(* Calculates the capacitances of a microstrip trace using the model        *)
(* defined by Schwarzmann in his paper "Microstrip plus equations adds      *)
(* up to fast designs" two conductors - odd-mode.  He defines two new line  *)
(* capacitances:                                                            *)
(*                                                                          *)
(*   Cppuo := the odd-mode upper plate capacitance (OddUpCap)               *)
(*   Cfo  := the odd-mode fringe capacitance (OddFringeCap)                 *)
(*                                                                          *)
(****************************************************************************)

var
   OddCoupConst,
   OddFringeDenom,
   CommonTerm : real;

begin
   CommonTerm :=DiConst / (SpeedOfLight * ImpedOfFreeSpace);
   OddCoupConst := 1 / ((TraceSpacing / TraceWidth) + 1);
   OddUpCap := 8/6 * ((CommonTerm * OddCoupConst)/sqrt(DiConst)) * 1e12;
   OddFringeDenom :=ln(4*TraceSpacing * tanh(4*TraceHeight/TraceSpacing) / (pi*TraceThick));
   OddFringeCap := (CommonTerm*(EffDiConst/DiConst)*pi/OddFringeDenom)*1e12;
end (* OddLineCap *);

(****************************************************************************)
function IntCapac;
(* Calculates the capacitance of a trace per unit of measure *)
(****************************************************************************)

begin
   IntCapac := IntProp/IntImped;
end; (* IntCapac *)

(****************************************************************************)
function IntInduct;
(* Calculates the inductance of a trace per unit of measure *)
(****************************************************************************)

begin
   IntInduct := IntImped * IntProp;
end; (* IntInduct *)

(****************************************************************************)
function IntResist;
(* Calculates the trace resist in mohms per inch of copper trace *)
(****************************************************************************)

begin
   IntResist := ResistCopper/(TraceThick * TraceWidth)*1000;
end; (* IntResist *)

(****************************************************************************)
function LoadAdjust;
(****************************************************************************)

(* This function calculates the constant used to adjust the impedance or  *)
(* propagation delay based on the added load capacitance per unit length *)

begin
   LoadAdjust := sqrt(1 + (DistCap/IntCap));
end;

end.


