unit beatdistcapanal;

interface

procedure DistCapAnal;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;


(****************************************************************************)
procedure DistCapAnal;
(*
   Determines the effects of distributed capacitances on effective
   impediance and propagation delay of a transmission line. The equations
   can be found in any applicable textbook and also easily be derived.      *)
(****************************************************************************)

var
   Again : boolean;

begin (* Distributed Capacitance Analysis *)

   Again := true;
   while Again =true do
   begin
      ClrScr;
      writeln ('Calculates the effective impedance and prop delay');
      writeln ('-----------------------------------------------------------');
      writeln;
      GetParam('What is the intrinsic impedance ?',2,IntImped);
      GetParam('What is the intrinsic delay ? ',6,IntProp);
      GetParam('What is the distributed capacitance ?',3,DistCap);
      IntCap := IntCapac(IntImped, IntProp)*1e3/12;
      EffImped := IntImped / LoadAdjust(IntCap, DistCap);
      EffProp := IntProp * LoadAdjust(IntCap, DistCap);
      writeln;
      writeln ('Line analysis:');
      writeln ('--------------');
      writeln ('Impedance (ohms):                = ',EffImped:3:1);
      writeln ('Propagation Delay (ns/ft):       = ',EffProp:2:2);
      writeln ('Intrinsic Capacitance (pf/in):   = ',IntCap:2:2);
      writeln ('Distributed Capacitance (pF/in): = ',DistCap:2:2);
      writeln;
      GetResponse('Another calculation (y/n)? ',Again);
   end;
end;

end.


