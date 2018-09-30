{$N+ }
unit beatio;

interface
 uses beatinc;

procedure menu(NumOpt : integer; Header : str; OptArray : strgarray; var SelOpt : opt);
procedure GetParam (question : str; UnitSel : integer; var number : extended);
procedure GetIParam (question : str; var number : integer);
procedure GetResponse (question : str; var response : boolean);
procedure GetTraceParam;
procedure GetTraceStatParam;
procedure TraceParamOut;
procedure LineAnalOut(EffImped, EffProp, IntCap, IntInduct, IntRes : extended);
procedure LineAnalStatOut(EffImpedMean,EffImpedSigma,EffPropMean,
	EffPropSigma,IntCapMean,IntCapSigma,IntInductMean,
	IntInductSigma,IntResMean,IntResSigma: real);
procedure StatIterNum;

implementation
  uses crt;
  
(****************************************************************************)
procedure menu;
(****************************************************************************)

(* This procedure provides the ability to generate a menu driven program *)
(* Options are limited to ten selections.  The Option number selected is *)
(* returned to the main program.                                         *)

var
   Temp,
   DepthMargin,
   WidthMargin : integer;
   Option : opt;

begin

   Temp := 0;
   ClrScr; (*  Clear Screen *)
   for Temp:= 1 to ((ScreenWidth - 48) div 2) do
   write (' ');
   writeln ('Board Electrical Analysis Tool - BEAT (Rev 4.0)');
   DepthMargin := (ScreenDepth - NumOpt - 5) div 2;
   WidthMargin := (ScreenWidth - 40) div 2;
   for Temp:= 1 to DepthMargin do
      writeln;
   for Temp := 1 to WidthMargin do
      write(' ');
   writeln(Header);
   for Temp := 1 to WidthMargin do
      write(' ');
   writeln('------------------------------------------------');
   writeln;
   for Option := 1 to NumOpt do
   begin
      for Temp := 1 to (WidthMargin - 3) do
         write(' ');
      write(Option,') ');
      writeln(OptArray[Option]);
   end;
   writeln;
   for Temp := 1 to WidthMargin do
      write(' ');
   write ('Select Option number: ');
   readln (SelOpt);
end (* menu *);


(****************************************************************************)
procedure GetParam;
(****************************************************************************)

var
   temp : str;
   error : integer;

begin
   write(question,'[', number:3:4,'] ');
   readln(temp);
   if temp <> '' then
      Val(temp, number, error);
end (* GetParam *);



(****************************************************************************)
procedure GetIParam;
(****************************************************************************)

var
   temp : str;
   error : integer;

begin
   write(question,'[', number:6,'] ');
   readln(temp);
   if temp <> '' then
     Val(temp,number,error);
end (* GetIParam *);

(****************************************************************************)
procedure GetResponse;
(****************************************************************************)

var
   temp,Query : char;

begin
    writeln (question, '[n] ');
    repeat
     temp := Readkey;
    until (temp = 'y') OR (temp = 'Y') OR (temp = 'n') OR (temp = 'N') OR (temp = ^M);
    if temp <> ^M then Query := temp;
    if (Query = 'y') OR (Query = 'Y') then
        Response := true
    else
        Response := false;
end; (* GetResponse *)

(****************************************************************************)
procedure GetTraceParam;
(****************************************************************************)

begin
   If (UnitSys = 1) then
    begin
     TraceThick  := TraceThick*25.4;
     TraceWidth  := TraceWidth*25.4;
     TraceHeight := TraceHeight*25.4;
     GetParam('What is the trace thickness? [mm]  ',1,TraceThick);
     GetParam('What is the trace width? [mm]  ',1,TraceWidth);
     GetParam('What is the trace height? [mm]  ',1,TraceHeight);
     GetParam('What is the dielectric constant? ',0,DiConst);
    end
   else
    begin
     GetParam('What is the trace thickness? [in]  ',1,TraceThick);
     GetParam('What is the trace width? [in]  ',1,TraceWidth);
     GetParam('What is the trace height? [in]  ',1,TraceHeight);
     GetParam('What is the dielectric constant? ',0,DiConst);
    end;
end; (* GetTraceParam *)


(**************************************************************************)
procedure GetTraceStatParam;
(*
    This routine was derived from GetTraceParam.
    It differs from that routine in that it not only asks for the values
    of the input parameters (mean), but also for a standard deviation
    (sigma) for each parameter.                                           *)
(**************************************************************************)

begin                         (* initialize default values first *)
   if TraceThickMean=0 then TraceThickMean := TraceThick;
   if TraceWidthMean=0 then TraceWidthMean := TraceWidth;
   if TraceHeightMean=0 then TraceHeightMean := TraceHeight;
   if DiConstMean=0 then DiConstMean := DiConst;

   GetParam('What is the mean trace thickness? ',1,TraceThickMean);
   GetParam('What is the standard deviation? ',1,TraceThickSigma);
   GetParam('What is the mean trace width? ',1,TraceWidthMean);
   GetParam('What is the standard deviation? ',1,TraceWidthSigma);
   GetParam('What is the mean trace height? ',1,TraceHeightMean);
   GetParam('What is the standard deviation? ',1,TraceHeightSigma);
   GetParam('What is the mean dielectric constant? ',0,DiConstMean);
   GetParam('What is the standard deviation? ',0,DiConstSigma);

   TraceThick := TraceThickMean;  (* Keep the entered values as defaults *)
   TraceWidth := TraceWidthMean;
   TraceHeight := TraceHeightMean;
   DiConst := DiConstMean;
end; (* GetTraceStatParam *)


(****************************************************************************)
procedure TraceParamOut;
(****************************************************************************)

begin
      writeln ('Micro-strip Trace Parameters');
      writeln ('-----------------------------');
      writeln ('Thickness: ',TraceThick:5:4, ' in.');
      writeln ('Width:      ',TraceWidth:4:3,' in.');
      writeln ('Height:     ',TraceHeight:4:3,' in.');
      writeln ('Spacing:    ',TraceSpacing:4:3,' in.');
      writeln ('Er:         ',DiConst:3:2);
      writeln ('DistCap     ',DistCap:5:4);
      writeln;
end; (* TraceParamOut *)


(****************************************************************************)
procedure LineAnalOut;
(****************************************************************************)

begin
   writeln;
   writeln ('Line analysis:');
   writeln ('--------------');
   writeln ('Impedance (ohms):                = ',EffImped:3:1);
   writeln ('Propagation Delay (ns/ft):       = ',EffProp:2:2);
   writeln ('Intrinsic Capacitance (pf/in):   = ',IntCap:2:2);
   writeln ('Intrinsic Inductance (nH/in):    = ',IntInduct:2:2);
   writeln ('Intrinsic Resistance (mohms/in)  = ',IntRes:2:2);
   writeln;
end; (* LineAnalOut *)


(**************************************************************************)
procedure LineAnalStatOut;
(*
    output of the data which resulted from statistical analysis. This is
    basically a modified version of LineAnalOut.                          *)
(**************************************************************************)

begin
   writeln;
   writeln ('Line analysis:');
   writeln ('--------------');
   writeln ('Impedance (ohms):               mean = ',EffImpedMean:3:1,'   sigma = ',EffImpedSigma:3:3);
   writeln ('Propagation Delay (ns/ft):      mean = ',EffPropMean:2:2,'   sigma = ',EffPropSigma:2:4);
   writeln ('Intrinsic Capacitance (pf/in):  mean = ',IntCapMean:2:2,'   sigma = ',IntCapSigma:2:4);
   writeln ('Intrinsic Inductance (nH/in):   mean = ',IntInductMean:2:2,'   sigma = ',IntInductSigma:2:4);
   writeln ('Intrinsic Resistance (mohms/in) mean = ',IntResistMean:2:2,'   sigma = ',IntResistSigma:2:4);
   writeln;
end; (* LineAnalStatOut *)

(**************************************************************************)
procedure StatIterNum;
(*
    Asks the user for the number of iterations which the statistics
    routines should run to obtain a normal distribution of the output
    parameters.                                                           *)
(**************************************************************************)

var answer : boolean;
var NumIterations, IterationsMax : integer;

begin
  NumIterations := 10;
  repeat
    begin
      GetIParam('Enter number of iterations : ',NumIterations);
      if (NumIterations <= 0) or (NumIterations > IterationsMax) then begin
        writeln;
        writeln ('The number of iterations must be more than 1.');
        writeln ('If you want to exceed ',IterationsMax,' Iterations,');
        writeln ('you will have to change the constant "IterationsMax"');
        writeln ('in "beat.h" and recompile the program.');
        writeln;
        GetResponse ('Hit >RETURN< to continue',answer);
      end;
    end;
  until (NumIterations >0) and (NumIterations <= IterationsMax);
end;

end.
