unit beatreflectcoef;

interface

procedure reflectcoef;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;


(****************************************************************************)
procedure reflectcoef;
(****************************************************************************)

(* This program calculates the reflection coefficient given the load
impedance and the line impedance *)

var

   Again : boolean;

begin
   Again := true;
   while Again = true do
   begin
      ClrScr;
      writeln ('This program calculates the reflection coefficient');
      writeln ('-----------------------------------------------------------');
      writeln;
      GetParam('Line impedance ? ',2,LineImp);
      GetParam('Load impedance ? ',2,LoadImp);
      ReflectionCoef := (LoadImp - LineImp)/(LoadImp + LineImp);
      writeln ('Reflection coeffiecient = ', ReflectionCoef:1:2);
      writeln ;
      GetResponse('Another reflection calculation (y/n)?',Again);
   end;
end;

end.


