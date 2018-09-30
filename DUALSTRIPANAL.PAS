unit dualstripanal;

interface

procedure DualStripLineAnal;
procedure DualStripLineStatAnal;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;

(****************************************************************************)
procedure DualStripLineAnal;
(*                                                                          *)
(* Determines the impedance and propagation constant of dual-stripline      *)
(* using the equation found the IPC Standard "Design standard for electronic*)
(* packaging utilizing high speed techniques".                              *)
(*                                                                          *)
(* Please keep in mind that the same equations used in this procedure are
   also contained in DualStripStatAnal.                                     *)
(****************************************************************************)

var
   Cap, Induct,
   ImpFactor1,ImpFactor2, ImpFactor3 : real;
   Again : boolean;

begin
   Again := true;
   while Again = true do
   begin
      ClrScr;
      writeln ('Dual-stripline analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      GetTraceParam;
      GetParam('What is the signal plane separation? ',1,SigPlaneSep);
      ImpFactor1 := 80/sqrt(DiConst);
      ImpFactor2 := ln(1.9*(2*TraceHeight + TraceThick)/(0.8*TraceWidth + TraceThick));
      ImpFactor3 := 1 - (TraceHeight/(4*(TraceHeight + SigPlaneSep + TraceThick)));
      IntImped := ImpFactor1 * ImpFactor2 * ImpFactor3;
      IntProp := 1.017*sqrt(DiConst);
      Cap := IntCapac(IntImped, IntProp)*1e3/12;
      Induct := IntInduct(IntImped, IntProp)/12;
      Resist := IntResist(TraceThick, TraceWidth);
      LineAnalOut(IntImped, IntProp, Cap, Induct, Resist);
      GetResponse('Another dual-stripline analysis (y/n)?',Again);
   end;
end; (* DualStripLineAnal *)

(**************************************************************************)
procedure DualStripLineStatAnal;
(*                                                                          *)
(* Determines the impedance and propagation constant of dual-stripline      *)
(* using the equation found the IPC Standard "Design standard for electronic*)
(* packaging utilizing high speed techniques".                              *)
(*                                                                          *)
(*  Containes the same equations as DualStripAnal, however this routine
    is controlled by some statistics code.
    For comments on program statements, please refer to StripLineStatAnal,
    which is structured similarly                                           *)
(****************************************************************************)

var
   Cap,CapMean,CapSigma, Induct,InductMean,InductSigma,
   ResistMean,ResistSigma,
   ImpFactor1,ImpFactor2, ImpFactor3 : real;
   i : integer;
   Again : boolean;

begin
   NumIterations := 10;
   Again := true;
   while Again = true do
   begin
      ClrScr;
      writeln ('S t a t i s t i c a l    Dual-strip Line Analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      StatIterNum;
      GetTraceStatParam;
      SigPlaneSepMean := SigPlaneSep;  (* Get default value *)
      GetParam('What is the mean signal plane separation? ',1,SigPlaneSepMean);
      GetParam('What is the standard deviation? ',1,SigPlaneSepSigma);
      SigPlaneSep := SigPlaneSepMean;  (* Keep as default value *)
      writeln;
      writeln('Working');

      for i := 1 to NumIterations do begin
        TraceThickVal := RNDNormal(TraceThickMean,TraceThickSigma);
        TraceWidthVal := RNDNormal(TraceWidthMean,TraceWidthSigma);
        TraceHeightVal := RNDNormal(TraceHeightMean,TraceHeightSigma);
        DiConstVal := RNDNormal(DiConstMean,DiConstSigma);
        SigPlaneSepVal := RNDNormal(SigPlaneSepMean,SigPlaneSepSigma);


        ImpFactor1 := 80/sqrt(DiConstVal);
        ImpFactor2 := ln(1.9*(2*TraceHeightVal + TraceThickVal)/(0.8*TraceWidthVal + TraceThickVal));
        ImpFactor3 := 1 - (TraceHeightVal/(4*(TraceHeightVal + SigPlaneSepVal + TraceThickVal)));
        IntImped := ImpFactor1 * ImpFactor2 * ImpFactor3;
        IntProp := 1.017*sqrt(DiConstVal);
        Cap := IntCapac(IntImped, IntProp)*1e3/12;
        Induct := IntInduct(IntImped, IntProp)/12;
        Resist := IntResist(TraceThickVal, TraceWidthVal);

        StatData[1][i] := IntImped;
        StatData[2][i] := IntProp;
        StatData[3][i] := Cap;
        StatData[4][i] := Induct;
        StatData[5][i] := Resist;
      end;

      IntImpedMean := 0;
      IntPropMean := 0;
      CapMean := 0;
      InductMean := 0;
      ResistMean := 0;
      for i := 1 to NumIterations do begin
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

      IntImpedSigma := 0;
      IntPropSigma := 0;
      CapSigma := 0;
      InductSigma := 0;
      ResistSigma := 0;
      for i := 1 to NumIterations do begin
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
      GetResponse('Another statistical dual stripline analysis (y/n)?',Again);
   end;
end; (* DualStripLineStatAnal *)

end.


