unit microstripanal;

interface

procedure MicroStripLineAnal;
procedure MicroStripLineStatAnal;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;

(****************************************************************************)
procedure MicroStripLineAnal;
(*                                                                          *)
(* Calculates the line impedance of a microstrip trace using the model      *)
(* defined by Schwarzmann in his paper "Microstrip plus equations adds      *)
(* up to fast designs" for an isolated conductor. He breaks the line        *)
(* capacitance up into:                                                     *)
(*                                                                          *)
(*   Cppu := the upper plate capacitance (UpCap)                            *)
(*   Cpp  := the lower plate capacitance (LowCap)                           *)
(*   Cf   := the fringe capacitances (FringeCap)                            *)
(*                                                                          *)
(* Corrections to the propagation constant (because of solder mask have     *)
(* been added based on emperical data from GS2 boards.  The correction      *)
(* factor was derived similar to the techinique in "Characteristics of      *)
(* Microstrip Transmission Lines", by H. R. Kaupp.                          *)
(*                                                                          *)
(* Please keep in mind that the same equations used in this procedure are
   also contained in MicroStripStatAnal.                                    *)
(****************************************************************************)

var
   Cap, Induct : real;
   Again: boolean;
   temp : char;

begin
   Again :=true;
   while Again = true do
   begin
      ClrScr;
      writeln ('Micro-stripline analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      GetTraceParam;
      write ('Solder mask? (w-wet, d-dry, n-none)  [', SoldMask,']');
      repeat
      	temp := Readkey;
      until(temp = 'n') OR (temp = 'w') OR (temp = 'd') OR (temp = ^M);
      if (temp <> ^M) then SoldMask := temp;
      case SoldMask of
         'n' : EffDiConst := 0.475*DiConst + 0.67;
         'w' : EffDiConst := 0.58*DiConst + 0.55;
         'd' : EffDiConst := DiConst;
      end;
      LinCap (LowCap, UpCap, FringeCap);
      PropConst (IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
      LineImped (IntImped, IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
      Cap := (2*(UpCap + FringeCap) + LowCap)/12;
      Induct := IntInduct(IntImped, IntProp)/12;
      Resist := IntResist(TraceThick, TraceWidth);
      LineAnalOut(IntImped, IntProp, Cap, Induct, Resist);
      GetResponse('Another micro-stripline analysis (y/n)?',Again);
   end;
end;


(**************************************************************************)
procedure MicroStripLineStatAnal;
(*                                                                          *)
(* Calculates the line impedance of a microstrip trace using the model      *)
(* defined by Schwarzmann in his paper "Microstrip plus equations adds      *)
(* up to fast designs" for an isolated conductor. He breaks the line        *)
(* capacitance up into:                                                     *)
(*                                                                          *)
(*   Cppu := the upper plate capacitance (UpCap)                            *)
(*   Cpp  := the lower plate capacitance (LowCap)                           *)
(*   Cf   := the fringe capacitances (FringeCap)                            *)
(*                                                                          *)
(* Corrections to the propagation constant (because of solder mask have     *)
(* been added based on emperical data from GS2 boards.  The correction      *)
(* factor was derived similar to the techinique in "Characteristics of      *)
(* Microstrip Transmission Lines", by H. R. Kaupp.                          *)
(*                                                                          *)
(*  Containes the same equations as MicroStripAnal, however this routine
    is controlled by some statistics code.
    For comments on program statements, please refer to StripLineStatAnal,
    which is structured similarly                                           *)
(****************************************************************************)

var
   Cap,CapMean,CapSigma, Induct,InductMean,InductSigma,
   ResistMean,ResistSigma : real;
   i : integer;
   Again : boolean;
   temp : char;
   begin
   NumIterations := 10;
   Again := true;
   while Again = true do
   begin
      ClrScr;
      writeln ('S t a t i s t i c a l    Microstrip Line Analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      StatIterNum;
      GetTraceStatParam;
      write ('Solder mask ? (w-wet, d-dry, n-none)   [',SoldMask,']');

      repeat
	temp := Readkey;
      until(temp = 'n') OR (temp = 'w') OR (temp = 'd') OR (temp = ^M);
      if (temp <> ^M) then SoldMask := temp;

                  (* Here I cannot use TraceThickVal etc. as in the other
                  statistical routines, because the called procedures,
                  such as LinCap etc. expect TraceThick etc.
                  In order not to destroy the defaults contained in
                  TraceThick etc. by putting the output of the random
                  generator in these variables, I save them first and
                  then restore them to their original value lateron.   *)

      TraceThickVal := TraceThick;
      TraceWidthVal := TraceWidth;
      TraceHeightVal := TraceHeight;
      DiConstVal := DiConst;
      writeln;
      writeln ('Working');

      for i := 1 to NumIterations do begin
        TraceThick := RNDNormal(TraceThickMean,TraceThickSigma);
        TraceWidth := RNDNormal(TraceWidthMean,TraceWidthSigma);
        TraceHeight := RNDNormal(TraceHeightMean,TraceHeightSigma);
        DiConst := RNDNormal(DiConstMean,DiConstSigma);

        case SoldMask of
          'n' : EffDiConst := 0.475*DiConst + 0.67;
          'w' : EffDiConst := 0.58*DiConst + 0.55;
          'd' : EffDiConst := DiConst;
        end;

        LinCap (LowCap, UpCap, FringeCap);
        PropConst (IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
        LineImped (IntImped, IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
        Cap := (2*(UpCap + FringeCap) + LowCap)/12;
        Induct := IntInduct(IntImped, IntProp)/12;
        Resist := IntResist(TraceThick, TraceWidth);

        StatData[1][i] := IntImped;
        StatData[2][i] := IntProp;
        StatData[3][i] := Cap;
        StatData[4][i] := Induct;
        StatData[5][i] := Resist;
      end;

      TraceThick := TraceThickVal;
      TraceWidth := TraceWidthVal;
      TraceHeight := TraceHeightVal;
      DiConst := DiConstVal;

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
      GetResponse('Another statistical microstripline analysis (y/n)?',Again);
   end;
end; (* MicroStripLineStatAnal *)

end.


