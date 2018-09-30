unit beatcrosstalk;

interface

procedure Crosstalk;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;


(****************************************************************************)
procedure Crosstalk;
(*                                                                          *)
(* This procedure calculates the backward and forward crosstalk for         *)
(* microstrip.  It allows for bus structures, distributed capacitance,      *)
(* termination values, different solder mask, and interlaced grounds.       *)
(*                                                                          *)
(* Several papers were used to derive the crosstalk calculation algorithms  *)
(* used in this procedure.  First, the microstrip characteristics are for   *)
(* even and odd modes are determined using the models defined by Schwarzmann*)
(* in his paper "Microstrip plus equations adds up to fast designs".        *)
(* Second, papers by Ivor Catt, "Crosstalk in Digital Systems" and John     *)
(* Defalco were used for basic crosstalk theory and crosstalk reflection    *)
(* analysis.  Data in these papers were also used for verification of the   *)
(* single line to line crosstalk.  Extrapolations to multiple lines and     *)
(* ground interlacing were primarily intuitive derviations and have been    *)
(* verified against GS2 processor board and backplane data.                 *)
(*                                                                          *)
(* Corrections to the propagation constant (because of solder mask have     *)
(* been added based on emperical data from GS2 boards.  The correction      *)
(* factor was derived similar to the techinique in "Characteristics of      *)
(* Microstrip Transmission Lines", by H. R. Kaupp.                          *)
(*                                                                          *)
(****************************************************************************)

var
   TraceSpace,
   RiseTime,
   VoltStep,
   BackVolt,
   ForVolt,
   BackPulWid,
   ForPulWid,
   VoltOdd,
   FCrC,
   BCrC : extended;
   Count,
   CountLimit,
   ActLines : integer;
   BusStruct,
   Update,
   Again,IntGnd : boolean;
   SoldMask : char;

begin
   Again :=true;
   VoltStep := 3.0; (*v*)
   RiseTime := 2.8; (*ns*)
   TraceLength := 10.5; (*in*)
   while Again = true do
   begin
      IntGnd := false;
      BusStruct := false;
      ActLines := 1;
      BCrC := 0;
      FCrC := 0;
      BackCrossConst := 0;
      ForCrossConst := 0;
      BackVolt := 0;
      ForVolt := 0;
      VoltOdd := 0;
      SoldMask := 'w';
      EffDiConst := 0.58*DiConst + 0.55; (* Set for wet solder mask *)
      ClrScr;
      writeln ('Crosstalk Analysis');
      writeln ('-----------------------------------------------------------');
      writeln;
      TraceParamOut;
      GetResponse ('New trace parameters (y/n)? ', Update );
      if Update = true then
         begin
            GetTraceParam;

            (* Adjust the dielectric constant for solder mask *)

            write ('Solder mask? (w-wet, d-dry, n-none) ', SoldMask);
            readln (SoldMask);
            case SoldMask of
               'n' : EffDiConst := 0.475*DiConst + 0.67;
               'w' : EffDiConst := 0.58*DiConst + 0.55;
               'd' : EffDiConst := DiConst;
            end
      end;

      (* Request data essential for crosstalk analysis *)

      GetParam ('Trace spacing from edge to edge ?',1, TraceSpacing);
      GetParam ('Trace length ?',1, TraceLength);
      GetParam ('What is the distributed cap.?',3, DistCap);
      GetParam ('Signal Rise time ?',4, RiseTime);
      GetParam ('Voltage step ?',5, VoltStep);
      GetParam ('What is the load impedance ? ',2, LoadImp);
      GetResponse ('Interlaced grounds (y/n)? ',  IntGnd);
      GetResponse ('Bus Structure (y/n)? ',  BusStruct);

      (* For a bus structure *)

      if BusStruct = true then
         begin

         (* Request the number of active lines *)

         writeln;
         write ('Number of active lines (1,2,4,6)? ', '[', ActLines:1,' ]');
         readln (ActLines);
         if (IntGnd = true) or (ActLines = 1) then
            CountLimit := 1
          else
            CountLimit := ActLines div 2;

         (* For the number of active lines divided by two, interatively add *)
         (* up the crosstalk constants                                      *)

         for Count := CountLimit downto 1 do
            begin
            TraceSpace := TraceSpacing;
            TraceSpacing := Count*TraceSpacing + (Count-1)*TraceWidth;
            LinCap ( LowCap, UpCap, FringeCap);
            EvenLineCap ( EvenUpCap, EvenFringeCap);
            OddLineCap (OddUpCap, OddFringeCap);
            PropConst (EvenIntProp, LowCap, EvenUpCap, EvenUpCap, EvenFringeCap, EvenFringeCap);
            PropConst (OddIntProp, LowCap, OddUpCap, OddUpCap, OddFringeCap, OddFringeCap);
            LineImped (EvenLineImp, EvenIntProp, LowCap, EvenUpCap, EvenUpCap, EvenFringeCap, EvenFringeCap);
            LineImped (OddLineImp, OddIntProp, LowCap, OddUpCap, OddUpCap, OddFringeCap, OddFringeCap);
            BCrC := (EvenLineImp - OddLineImp) / (EvenLineImp + OddLineImp);
            if BCrC >= 0 then
               BackCrossConst := BackCrossConst + BCrC;
            FCrC := (EvenIntProp - OddIntProp);
            if FCrC >= 0 then
               ForCrossConst := ForCrossConst + FCrC;
            TraceSpacing := TraceSpace
            end (* Loop *);

            (* If bus structure and interlaced grounds then iteratively add *)
            (* the squares of the backward constants and divide the odd mode*)
            (* voltage by 2                                                 *)

            if IntGnd = true then
               begin

               (* Adjust backward constant for a single adjacent bus trace  *)

               BCrC := BackCrossConst/2;

               BackCrossConst := 0;
               if ActLines >= 2 then
                  CountLimit := ActLines div 2;
               for Count := CountLimit downto 1 do
                  begin
                  BCrC := sqr(BCrC);
                  BackCrossConst := BackCrossConst + BCrC;
                  VoltOdd := VoltOdd/4 + VoltStep/4
                  end;

               (* Correct for bus symmetry *)

               BackCrossConst := BackCrossConst*2;

               end
              else (* if no interlaced ground *)
               VoltOdd := VoltStep/2;

            if ActLines = 1 then (* Correct for no bus symmetry *)
               BackCrossConst := BackCrossConst/2;

         end (*Bustruct = true *)

       else (* BusStruct = false *)
         begin
            LinCap ( LowCap, UpCap, FringeCap);
            EvenLineCap ( EvenUpCap, EvenFringeCap);
            OddLineCap (OddUpCap, OddFringeCap);
            PropConst (EvenIntProp, LowCap, UpCap, EvenUpCap, FringeCap, EvenFringeCap);
            PropConst (OddIntProp, LowCap, UpCap, OddUpCap, FringeCap, OddFringeCap);
            LineImped (EvenLineImp, EvenIntProp, LowCap, UpCap, EvenUpCap, FringeCap, EvenFringeCap);
            LineImped (OddLineImp, OddIntProp, LowCap, UpCap, OddUpCap, FringeCap, OddFringeCap);
            BackCrossConst := (EvenLineImp - OddLineImp) / (EvenLineImp + OddLineImp);
            ForCrossConst := (EvenIntProp - OddIntProp);

(* If not bus structure but interlaced ground *)

            if IntGnd = true then
               begin
                  BackCrossConst := sqr(BackCrossConst);
                  VoltOdd := VoltOdd/4 + VoltStep/4
               end
             else
               VoltOdd := VoltStep/2;  (* End interlaced ground *)
         end (* BusStruct = false *);

      (* Determine the line impedance *)

      LineImp := sqrt(EvenLineImp * OddLineImp);

      (* Determine the max. backward crosstalk amplitude and pulse width *)

      BackVolt := BackCrossConst*VoltStep;
      BackPulWid := 2*EvenIntProp*TraceLength/12;

      (* Adjust the amplitude for the edge rate and trace length if needed *)

      if  RiseTime > 2*(EvenIntProp*TraceLength/12) then
         BackVolt := BackVolt*(2*(EvenIntProp*TraceLength/12)/RiseTime);

      (* Determine the forward crosstalk amplitude and pulse width *)

      ForPulWid := RiseTime;
      if (ForCrossConst*TraceLength/12) > RiseTime then
         ForVolt := VoltOdd
       else
         ForVolt := ((TraceLength/12)*ForCrossConst*VoltOdd)/RiseTime;

(* Correct for termination mismatch *)

      ReflectionCoef := (LoadImp - LineImp)/(LoadImp + LineImp);
      BackVolt := BackVolt * (1 + ReflectionCoef);
      ForVolt := ForVolt *  (1 + ReflectionCoef);

(* Output the test conditions and results *)

      ClrScr;
      writeln ('Test Parameters');
      writeln ('-------------------------');
      writeln ('RiseTime:      ',RiseTime:3:2,'ns');
      writeln ('Voltage Step:  ',VoltStep:4:2,'v');
      writeln ('Dist. Cap.:    ',DistCap:4:2,' pf/in');
      writeln ('Trace Length:  ',TraceLength:4:2);
      if IntGnd = true then
        writeln ( 'Interlaced grounds');
      writeln;
      writeln ('Crosstalk Data');
      writeln ('-------------------------');
      writeln ('Backward Crosstalk Constant:    ',BackCrossConst:4:3);
      writeln ('Backward Crosstalk Voltage:     ',BackVolt:4:3,' v');
      writeln ('Backward Crosstalk Pulse Width: ',BackPulWid:4:3,' ns');
      writeln ('Forward Crosstalk Constant:     ',ForCrossConst:4:3,' ns/ft');
      writeln ('Forward Crosstalk Voltage:      ',ForVolt:4:3,' v');
      writeln ('Forward Crosstalk Pulse Width:  ',ForPulWid:4:3,' ns');
      writeln ('Even Line Impedance:            ',EvenLineImp:4:2,' ohms');
      writeln ('Odd Line Impedance:             ',OddLineImp:4:2,' ohms');
      writeln ('Even Prop Const:                ',EvenIntProp:4:3,' ns/ft');
      writeln ('Odd Prop Const:                 ',OddIntProp:4:3,' ns/ft');
      writeln;
      GetResponse('Another crosstalk analysis? (y/n) ',Again);
   end;
end; (* Crosstalk *)

end.


