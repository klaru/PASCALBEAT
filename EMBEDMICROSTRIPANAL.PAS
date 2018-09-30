unit embedmicrostripanal;

interface

procedure EmbeddedMicroStripLineAnal;
procedure EmbeddedMicroStripLineStatAnal;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;

(********************************************************************************)
procedure EmbeddedMicroStripLineAnal;
(*                                                                              *)
(* Calculates the line impedance of an embedded microstrip trace by calculating *)
(* first the impedance of  the microstripline case and then adjusting for the   *)
(* higher effective impedance of the embedded case.                             *)
(*                                                                              *)
(* Please keep in mind that the same equations used in this procedure are       *)
(*  also contained in MicroStripStatAnal.                                       *)
(********************************************************************************)

var
   Cap, Induct : real;
   Again: boolean;
   temp : char;

begin
   EmbedHeight := 0.004;
   Again :=true;
   while Again = true do
   begin
      ClrScr;
      writeln ('Embedded microstripline analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      GetTraceParam;
      GetParam('What is the dielectric height above the bottom of the trace? ',1,EmbedHeight);
      EffDiConst := DiConst;
      LinCap (LowCap, UpCap, FringeCap);
      PropConst (IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
      LineImped (IntImped, IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
      EffDiConstmicro := IntProp*1e9*IntProp*1e9/(SpeedOfLight*SpeedOfLight);
      EffDiConstburied := EffDiConstmicro*Exp(-2*EmbedHeight/TraceHeight) + DiConst*(1 - Exp(-2*EmbedHeight/TraceHeight));
      EffDiConst := EffDiConstburied;
      LinCap(LowCap, UpCap, FringeCap);
      PropConst(IntPropEmbed, LowCap, UpCap, UpCap, FringeCap, FringeCap);
      IntImpedEmbed := IntImped*sqrt(EffDiConstmicro)/sqrt(EffDiConstburied); 
      Cap := (2*(UpCap + FringeCap) + LowCap)/12;
      Induct := IntInduct(IntImpedEmbed, IntPropEmbed)/12;
      Resist := IntResist(TraceThick, TraceWidth);
      LineAnalOut(IntImpedEmbed, IntPropEmbed, Cap, Induct, Resist);
      GetResponse('Another embedded microstripline analysis (y/n)?',Again);
   end;
end; (* EmbeddedMicroStripLineAnal *)


(********************************************************************************)
procedure EmbeddedMicroStripLineStatAnal;
(*                                                                              *)
(* Calculates the line impedance of an embedded microstrip trace by calculating *)
(* first the impedance of  the microstripline case and then adjusting for the   *)
(* higher effective impedance of the embedded case.                             *)
(*                                                                              *)
(*  Containes the same equations as MicroStripAnal, however this routine        *)
(*   is controlled by some statistics code.                                     *)
(*    For comments on program statements, please refer to StripLineStatAnal,    *)
(*    which is structured similarly                                             *)
(********************************************************************************)
var
   Cap,CapMean,CapSigma, Induct,InductMean,InductSigma,
   ResistMean,ResistSigma : real;
   i : integer;
   Again : boolean;
   temp : char;
   begin
   Again := true;
   while Again = true do
   begin
      ClrScr;
      writeln ('S t a t i s t i c a l    Embedded microstrip Line Analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      StatIterNum;
      GetTraceStatParam;
      GetParam('What is the dielectric height above the bottom of the trace? ',1,EmbedHeight);

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

        EffDiConst := DiConst;

        LinCap (LowCap, UpCap, FringeCap);
        PropConst (IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
        LineImped (IntImped, IntProp, LowCap, UpCap, UpCap, FringeCap, FringeCap);
        EffDiConstmicro := IntProp*1e9*IntProp*1e9/(SpeedOfLight*SpeedOfLight);
        EffDiConstburied := EffDiConstmicro*Exp(-2*EmbedHeight/TraceHeight) + DiConst*(1 - Exp(-2*EmbedHeight/TraceHeight));
        EffDiConst := EffDiConstburied;
        LinCap(LowCap, UpCap, FringeCap);
        PropConst(IntPropEmbed, LowCap, UpCap, UpCap, FringeCap, FringeCap);
        IntImpedEmbed := IntImped*sqrt(EffDiConstmicro)/sqrt(EffDiConstburied);         
        Cap := (2*(UpCap + FringeCap) + LowCap)/12;
        Induct := IntInduct(IntImpedEmbed, IntPropEmbed)/12;
        Resist := IntResist(TraceThick, TraceWidth);

        StatData[1][i] := IntImpedEmbed;
        StatData[2][i] := IntPropEmbed;
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
      GetResponse('Another statistical embedded microstripline analysis (y/n)?',Again);
   end;
end; (* EmbeddedMicroStripLineStatAnal *)

end.
