{$N+ }
(* {$M 65520,0,655360} for TP5.0 *)
(*               BOARD ELECTRICAL ANALYSIS TOOL (BEAT)                       *
*                             7-1-88                                         *
*                                                                            *
*  This is a program which assist the engineer in dealing with transmission  *
*  line issues such as the line impedance, propagation delay, reflection     *
*  coefficient, distributed capacitance, etc.                                *
*                                                                            *
*  Modifications to BEAT:                                                    *
*  6/89, Ulf Schlichtmann                                                    *
*  Comments on details of the modifications appear throughout the program    *
*									                                         *
*  8/1989, Klaus Ruff							                             *
*  Ported to Turbo-Pascal 5 on PC					                         *
*  4/1991 Klaus Ruff								                         *
*  Ported to Turbo Pascal Windows (Text Mode)                                *
*  9/2018 Klaus Ruff                                                         +
*  Ported to Free Pascal 3.0 (Text Mode)                                     *
*                                                                            *
*  Key Global Variables:                                                     *
*                                                                            *
* 	IntImped (ohms)	= Intrinsic impedance of a line (no dist. cap.)          *
*	EffImped (ohms)	= Effective impedance after dist. cap. considered.       *
*	IntProp (ns/ft)= Intrinsic prop. delay of a line (no dist. cap.)         *
*	EffProp (ns/ft)= Effective prop. delay after dist. cap. considered.      *
*	IntCap (pf/in)	= Intrinsic capacitance of the line.                     *
*	DistCap	(pf/in)	= Extra capacitance distributed along a line.            *
*	IntInd (nH/in)	= Intrinsic inductance of the line.                      *
*	IntRes (ohms/in)= Intrinsic resistance of the line.                      *
*                                                                            *
******************************************************************************)


program BrdElectAnalTool (input,output,FourierCoefDat,OutDat
                          ,FreqDat1,FreqDat2);
 uses
  crt, beatinc, beatio, beatmath, beatcalc, beatcrosstalk, beatreflectcoef, beatsetunit, beatladdernetanal, beatdistcapanal, beatloadparameters, statanal, stripanal, microstripanal, dualstripanal, embedmicrostripanal;


(****************************************************************************)
procedure DoesntWork;
(****************************************************************************)
begin
end;

 
(****************************************************************************)
procedure Help;
(****************************************************************************)

var
   Ende : boolean;
   HelpBuffer,Again : char;
   helpfile : text;

(* Set up the help menu selection for BEAT *)

begin
   Ende := false;
   while Ende = false do begin
   Header := 'Electrical Analysis - Help Menu - BEAT (Rev 4.0)';
   OptArray[1] := 'Return to Main Menu';
   OptArray[2] := 'Reflection Analysis';
   OptArray[3] := 'Strip Line Analysis';
   OptArray[4] := 'Microstrip Line Analysis';
   OptArray[5] := 'Dual-strip Line Analysis';
   OptArray[6] := 'Embedded Microstrip Line Analysis';
   OptArray[7] := 'Dist. Cap. Analysis';
   OptArray[8] := 'Crosstalk Analysis';
   OptArray[9] := 'Trace Pi Model Generation';
   OptArray[10] := 'Fourier Analysis';
   OptArray[11] := 'Statistical Analysis';
   OptArray[12] := 'Metric / Imperial System';
   OptArray[13] := 'Load Library Parameters';
   menu (13, Header, OptArray, SelOpt);

(* Reset selected help file and display the file *)

   case SelOpt of
      1 : Ende := true;
      2 : assign(helpfile,'reflect.HLP');
      3 : assign(helpfile,'stripanal.hlp');
      4 : assign(helpfile,'microanal.hlp');
      5 : assign(helpfile,'dualanal.hlp');
      6 : assign(helpfile,'embedmicro.hlp');
      7 : assign(helpfile,'distcap.hlp');
      8 : assign(helpfile,'crosstalk.hlp');
      9 : assign(helpfile,'tmodel.hlp');
     10 : assign(helpfile,'fourier.hlp');
     11 : assign(helpfile,'statistics.hlp');
     12 : assign(helpfile,'unitsel.hlp');
     13 : assign(helpfile,'library.hlp');
   end;
   if Ende <> true then
   begin
   reset(helpfile);	
   while not eof(helpfile) do
   begin
      while not eoln(helpfile) do
      begin
         read(helpfile, HelpBuffer);
         write(HelpBuffer);
      end; (* While not eoln *)
      readln(helpfile);
      writeln;
   end; (* While not eof *)
   writeln;
   writeln ('Hit <RETURN> to return to Help Menu: ');
   Again := Readkey;
   close(helpfile);
   end; (* If *)
   end;
end; (* Help *)

begin  (* Main Program *)

(* Define default paramter values *)

   DiConst := 4.7;
   EffDiConst := DiConst;
   Ende := false;
   LoadImp := 100;
   LineImp := 100;
   IntImped := 48;
   EffImped := 100;
   IntProp := 2.5;
   DistCap := 0;
   TraceWidth := 0.011;
   TraceThick := 0.0021;
   TraceHeight := 0.026;
   TraceSpacing := 0.089;
   Period := 20.0 ;
   SigPlaneSep := 0.004;
   NumPoints := 5;
   Time[1] :=  0.0;  Magnitude[1] := 0.0;
   Time[2] :=  1.0;  Magnitude[2] := 0.0;
   Time[3] :=  2.0;  Magnitude[3] := 5.0;
   Time[4] := 12.0;  Magnitude[4] := 5.0;
   Time[5] := 13.0;  Magnitude[5] := 0.0;
   NumHarmonics := 10;
   SoldMask := 'n';
   base[1] := 'Metric';
   base[2] := 'Imperial';
   UnitSys := 2;                              (* Default: Imperial System *)

      (* texts to prompt the user to use the correct unit *)
   InputUnits[1][1]:='(mm)';        InputUnits[2][1]:='(inch)';
   InputUnits[1][2]:='(ohms)';      InputUnits[2][2]:='(ohms)';
   InputUnits[1][3]:='(pF/mm)';     InputUnits[2][3]:='(pF/in)';
   InputUnits[1][4]:='(ns)';        InputUnits[2][4]:='(ns)';
   InputUnits[1][5]:='(volts)';     InputUnits[2][5]:='(volts)';
   InputUnits[1][6]:='(ns/mm)';     InputUnits[2][6]:='(ns/ft)';
   InputUnits[1][7]:='(mohms)';     InputUnits[2][7]:='(mohms)';
   InputUnits[1][8]:='(pF)';        InputUnits[2][8]:='(pF)';
   InputUnits[1][9]:='(nH)';        InputUnits[2][9]:='(nH)';
   InputUnits[1][10]:='mohms/mm';   InputUnits[2][10]:='mohms/inch';

      (* conversion factors from metric to the respective imperial units *)
   UnitConversion[1][1]:=25.4;   UnitConversion[2][1]:=1;
   UnitConversion[1][2]:=1;      UnitConversion[2][2]:=1;
   UnitConversion[1][3]:=1/25.4; UnitConversion[2][3]:=1;
   UnitConversion[1][4]:=1;      UnitConversion[2][4]:=1;
   UnitConversion[1][5]:=1;      UnitConversion[2][5]:=1;
   UnitConversion[1][6]:=1/304.8;UnitConversion[2][6]:=1;
   UnitConversion[1][7]:=1;      UnitConversion[2][7]:=1;
   UnitConversion[1][8]:=1;      UnitConversion[2][8]:=1;
   UnitConversion[1][9]:=1;      UnitConversion[2][9]:=1;
   UnitConversion[1][10]:=1/25.4;UnitConversion[2][10]:=1;

   NumIterations := IterationsMax;  (*Default for Iterations for Stat. Anal.*)

(* Setup the main menu for BEAT and go to selected routine *)

   while Ende = false do begin
   Header := 'Electrical Analysis - Main Menu - BEAT (Rev 4.0)';
   OptArray[1] := 'Exit';
   OptArray[2] := 'Reflection Analysis';
   OptArray[3] := 'Strip Line Analysis';
   OptArray[4] := 'Microstrip Line Analysis';
   OptArray[5] := 'Dual-strip Line Analysis';
   OptArray[6] := 'Embedded Microstrip Line Analysis';
   OptArray[7] := 'Dist. Cap. Analysis';
   OptArray[8] := 'Crosstalk Analysis';
   OptArray[9] := 'Trace Pi Model Generation';
   OptArray[10] :='Fourier Analysis';
   OptArray[11] :='Statistical Analysis';
   OptArray[12] :='Set Unit System';
   OptArray[13] :='Load Library Parameters';
   OptArray[14] :='Help';
   menu (14, Header, OptArray, SelOpt);
   case SelOpt of
      1 : Ende := true;
      2 : Reflectcoef;
      3 : StripLineAnal;
      4 : MicroStripLineAnal;
      5 : DualStripLineAnal;
      6 : EmbeddedMicroStripLineAnal;
      7 : DistCapAnal;
      8 : Crosstalk;
      9 : LadderNetAnal;
     10 : FourierAnal;
     11 : StaticAnal;
     12 : SetUnit;
     13 : LoadParameters;
     14 : Help;
   end;
end;
end.


