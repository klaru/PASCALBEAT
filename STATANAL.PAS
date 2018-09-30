unit statanal;

interface

procedure StaticAnal;

implementation
 uses crt, beatinc, beatio, beatcalc, stripanal, microstripanal, dualstripanal, embedmicrostripanal;

(**************************************************************************)
procedure StaticAnal;
(**************************************************************************)

var Ende : boolean;

begin
  Ende := false;
  while Ende = false do begin
    Header := 'Statistical Analysis';
    OptArray[1] := 'Exit to Main Menue';
    OptArray[2] := 'Strip Line Analysis';
    OptArray[3] := 'Microstrip Line Analysis';
    OptArray[4] := 'Dual-Strip Line Analysis'; 
    OptArray[5] := 'Embedded Strip Line Analysis';
    menu(5,Header,OptArray,SelOpt);
    case SelOpt of
      1 : Ende := true;
      2 : StripLineStatAnal;
      3 : MicroStripLineStatAnal;
      4 : DualStripLineStatAnal;
      5 : EmbeddedMicroStripLineStatAnal;
    end;
  end;
end;

end.


