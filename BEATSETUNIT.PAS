unit beatsetunit;

interface

procedure SetUnit;

implementation
 uses crt, math, beatio, beatinc, beatmath, beatcalc;

(**************************************************************************)
procedure SetUnit;
(*                                                                        *)
(*  This routine enables the user to select whether he wants to enter     *)
(*  his input data in the metric or in the imperial system of measurement *)
(*  units.                                                                *)
(*  Added 6/89 , Ulf Schlichtmann                                         *)
(**************************************************************************)

var
   UnitChar, temp : char;

begin     (* SetUnit *)
     ClrScr;
     writeln ('Set the Unit System for your input data');
     writeln ('---------------------------------------');
     writeln;
     writeln ('You may now select whether you want to input your data in ');
     writeln ('the Metric or in the Imperial system.');
     writeln;
     writeln ('Please keep in mind that the data in the library are in ');
     writeln ('the Imperial system');
     writeln;
     writeln ('Currently selected: ',base[UnitSys]);
     writeln;
     writeln;
     case UnitSys of
       1 : UnitChar := 'm';
       2 : UnitChar := 'i';
     end;
     write ('Metric or Imperial system?  (m or i)   [',UnitChar,'] ');

     repeat
      	temp := Readkey;
      until(temp = 'm') OR (temp = 'i') OR (temp = ^M);
      if (temp <> ^M) then UnitChar := temp;


	case UnitChar of
       'm' : UnitSys := 1;
       'i' : UnitSys := 2;
     end;
end;      (* SetUnit *)

end.


