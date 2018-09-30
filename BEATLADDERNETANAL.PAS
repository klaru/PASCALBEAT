unit beatladdernetanal;

interface

procedure LadderNetAnal;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;

(****************************************************************************)
procedure LadderNetAnal;
(* Completely modified 6/89, Ulf Schlichtmann *)
(* This procedure requests as input the line impedance and propagation delay
   constant of a line as well as the total length of the line and the rise
   time of the signal that needs to be analyzed.
   It then proceeds to compute the cutoff frequency of that signal and the
   number of RLC segments this line has to be split up into if it is to be
   modelled correctly by SPICE. The values for the R, L and C elements of each
   segment are also calcutlated and output.
   To calculate the number of required segments, a "rule of thumb" is used  *)
(****************************************************************************)

var
   Again:boolean;
   SegCap, SegInd, SegRes,  (* values per segment *)
   CornerFrequ :real;
   NumSeg:integer;


(***************************************************************************)
procedure GetNetInfo;
(***************************************************************************)

begin
     GetParam('What is the line impedance?',2,IntImped);
     GetParam('What is the propagation delay?',6,IntProp);
     GetParam('What is the intrinsic resistance?',10,Resist);
     GetParam('What is the line length?',1,TraceLength);
     GetParam('What is the rise time?',4,TRise);
end;



begin  (* LadderNetAnal *)
   Again := true;
   while Again = true do begin
     ClrScr;
     writeln ('Trace Pi Model Generation');
     writeln ('-----------------------------------------');
     writeln;
     GetNetInfo;
     CornerFrequ := 2/TRise;         (* Cutoff Frequency *)
     IntCap := IntProp*TraceLength/IntImped*1000/12;
                                     (*1000:Conversion to pF*)
                                     (*12: Conversion from ft to inch *)
     IntInd := IntProp*TraceLength*IntImped/12;
                                     (*12: Conversion from ft to inch *)
     NumSeg := trunc(5/2*CornerFrequ* sqrt(IntCap*IntInd)*sqrt(0.001));
                                     (* "Rule of Thumb" *)
                                     (* sqrt(.001): unit correction factor *)
     writeln;
     writeln ('Trace Pi Model Analysis');
     writeln ('------------------------');
     writeln ('Calculations have determined the following number of segments.');
     writeln ('Confirm this number by hitting RETURN or change it.');
     GetIParam ('Number of segments:                ',NumSeg);

     SegCap := IntCap/NumSeg;        (* Capacitance per segment *)
     SegInd := IntInd/NumSeg;        (* Inductance per segment *)
     SegRes := Resist*TraceLength/NumSeg/1000;  (* Resistance per segment *)
                                     (* 1000 : Conversion mohms --> ohms *)

     writeln ('Capacitance per segment (pF):      ',SegCap:2:2);
     writeln ('Inductance per segment (nH):       ',SegInd:2:2);
     writeln ('Resistance per segment (ohms):     ',SegRes:2:2);
     writeln;

     GetResponse('One More Time ?',Again)
   end;
end;

end.


