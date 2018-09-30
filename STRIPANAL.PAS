unit stripanal;

interface

procedure StripLineAnal;
procedure StripLineStatAnal;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;

(****************************************************************************)
procedure StripLineAnal;
(*                                                                          *)
(* Determines the impedance and propagation constant of a stripline         *)
(* using the standard equation found in Motorola's MECL Handbook or a       *)
(* hundred other books.                                                     *)
(*                                                                          *)
(* Please keep in mind that the same equations used in this procedure are
   also contained in StripLineStatAnal.                                     *)
(****************************************************************************)

var
   Cap, Induct,
   PlaneSpace,
   ImpFactor1,ImpFactor2 : real;
   Again : boolean;

begin
   Again := true;
   while Again = true do
   begin
      ClrScr;
      writeln ('Stripline analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      GetTraceParam;
      PlaneSpace := 2*TraceHeight + TraceThick;
      ImpFactor1 := 60/sqrt(DiConst);
      ImpFactor2 := ln(4*PlaneSpace/(0.67*pi*TraceWidth*(0.8 + TraceThick/TraceWidth)));
      IntImped := ImpFactor1 * ImpFactor2;
      IntProp := 1.017*sqrt(DiConst);
      Cap := IntCapac(IntImped, IntProp)*1e3/12;
      Induct := IntInduct(IntImped, IntProp)/12;
      Resist := IntResist(TraceThick, TraceWidth);
      LineAnalOut(IntImped, IntProp, Cap, Induct, Resist);
      GetResponse('Another stripline analysis (y/n)?',Again);
   end;
end; (* StripLineAnal *)


(**************************************************************************)
procedure StripLineStatAnal;
(*                                                                          *)
(* Determines the impedance and propagation constant of a stripline         *)
(* using the standard equation found in Motorola's MECL Handbook or a       *)
(* hundred other books.                                                     *)
(*                                                                          *)
(* Containes the same equations as StripLineAnal, however this routine
   is controlled by some statistics code.                                   *)
(****************************************************************************)

var
   Cap,CapMean,CapSigma,Induct,InductMean,InductSigma,
   ResistMean,ResistSigma,
   PlaneSpace,
   ImpFactor1,ImpFactor2 : real;
   i : integer;
   Again : boolean;

begin
   NumIterations := 10;
   Again := true;
   while Again = true do
   begin
      ClrScr;
      writeln ('S t a t i s t i c a l    Strip Line Analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      StatIterNum;
      GetTraceStatParam;
      writeln;
      writeln ('Working');

      for i := 1 to NumIterations do begin         (* Main Loop *)
        TraceThickVal := RNDNormal(TraceThickMean,TraceThickSigma);  (* Get *)
        TraceWidthVal := RNDNormal(TraceWidthMean,TraceWidthSigma);  (*Value*)
        TraceHeightVal := RNDNormal(TraceHeightMean,TraceHeightSigma);(*for*)
        DiConstVal := RNDNormal(DiConstMean,DiConstSigma);  (*each parameter*)

        PlaneSpace := 2*TraceHeightVal + TraceThickVal; (*calculate output*)
        ImpFactor1 := 60/sqrt(DiConstVal);  (*for these input data *)
        ImpFactor2 := ln(4*PlaneSpace/(0.67*pi*TraceWidthVal*(0.8 + TraceThickVal/TraceWidthVal)));
        IntImped := ImpFactor1 * ImpFactor2;
        IntProp := 1.017*sqrt(DiConstVal);
        Cap := IntCapac(IntImped, IntProp)*1e3/12;
        Induct := IntInduct(IntImped, IntProp)/12;
        Resist := IntResist(TraceThickVal, TraceWidthVal);

        StatData[1][i] := IntImped;   (* store resulting data *)
        StatData[2][i] := IntProp;
        StatData[3][i] := Cap;
        StatData[4][i] := Induct;
        StatData[5][i] := Resist;
      end;    (* Main Loop *)

      IntImpedMean := 0;  (* initialize variables to determine mean value *)
      IntPropMean := 0;   (* of each output parameter *)
      CapMean := 0;
      InductMean := 0;
      ResistMean := 0;
      for i := 1 to NumIterations do begin  (* determine mean *)
        IntImpedMean := IntImpedMean + StatData[1][i];
        IntPropMean := IntPropMean + StatData[2][i];
        CapMean := CapMean + StatData[3][i];
        InductMean := InductMean + StatData[4][i];
        ResistMean := ResistMean + StatData[5][i];
      end;
      IntImpedMean := IntImpedMean / NumIterations;
      IntPropMean := IntPropMean / NumIterations;
      CapMean := CapMean/ NumIterations;
      InductMean := InductMean / NumIterations;
      ResistMean := ResistMean / NumIterations;

      IntImpedSigma := 0;  (* initialize variables for determining *)
      IntPropSigma := 0;   (* standard deviation for each output parameter *)
      CapSigma := 0;
      InductSigma := 0;
      ResistSigma := 0;
      for i := 1 to NumIterations do begin  (* determine standard deviation *)
        IntImpedSigma := IntImpedSigma + sqr(StatData[1][i]-IntImpedMean);
        IntPropSigma := IntPropSigma + sqr(StatData[2][i]-IntPropMean);
        CapSigma := CapSigma + sqr(StatData[3][i]-CapMean);
        InductSigma := InductSigma + sqr(StatData[4][i]-InductMean);
        ResistSigma := ResistSigma + sqr(StatData[5][i]-ResistMean);
      end;
      IntImpedSigma := sqrt(IntImpedSigma / (NumIterations-1));
      IntPropSigma := sqrt(IntPropSigma / (NumIterations-1));
      CapSigma := sqrt(CapSigma/ (NumIterations-1));
      InductSigma := sqrt(InductSigma / (NumIterations-1));
      ResistSigma := sqrt(ResistSigma / (NumIterations-1));
      LineAnalStatOut(IntImpedMean,IntImpedSigma, IntPropMean,IntPropSigma,
        CapMean,CapSigma, InductMean,InductSigma, ResistMean,ResistSigma);

      GetResponse('Another statistical stripline analysis (y/n)?',Again);
   end;
end; (* StripLineStatAnal *)

end.


