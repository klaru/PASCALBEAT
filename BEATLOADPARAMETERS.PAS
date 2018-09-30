unit beatloadparameters;

interface
 uses beatinc;

procedure LoadParameters;

implementation
  uses crt, beatio;

(***************************************************************************)
procedure LoadParameters;
(*  This procedures accesses the database "library.bea".
    The database contains specifications of multilayer boards and may
    be changed or appended at any time.
    However, when modifying the database please take the rather stringent
    data structure into account. It is described in the user's manual.
    Deviating from this structure may very likely casuse BEAT to either
    run into one of the traps incorporated in this procedure or just
    crash.
    Ulf Schlichtmann, 6/89                                                 *)
(***************************************************************************)

const
   LibStringLength = 70;  (* no database entry may exceed 70 characters *)
   LayerTypeLength = 10;  (* keyword for layer type : 10 chars max *)
                          (* Note: if this parameter is changed, the
                                   comparisons between LayerType and some
                                   string constants below will have to be
                                   changed also                           *)
   LayerTypeMax = 10;     (* Max # of layer that can be stored. Since boards
                             are assumed to be symmetrical, boards with twice
                             as many layers can be handled                *)
   SpecMax = 20 ;         (* Current max # of specs that can be handled   *)

type
   LibString = array[1..LibStringLength] of char;
   LayerTypeString = array[1..LayerTypeLength] of char;

var
   i, j, k, l,
   NumSpecs,SpecSelect,
   NumLayers,LayerNum,LayerSelect,
   TempIndex : integer;
   dummy : char;
   InRange, LayerTypeOK, LoadOK : boolean;
   SpecDocNum,SpecDescription : array[1..SpecMax] of LibString;
   LayerType : array[1..LayerTypeMax] of LayerTypeString;
   lib:text;


begin (* Load Trace Parameters *)
      (* First part of this procedure reads all available specs from the
         library, displays the titles and gets a user selection *)
   LoadOK := true;
   ClrScr;
   writeln ('Load Library Parameters:');
   writeln ('Listing of currently available Specifications');
   writeln ('--------------------------------------------------------------');

   assign(lib,'library.bea');
   reset(lib);
   readln (lib, NumSpecs);  (* # of available specs *)
   readln (lib, dummy);     (* 'blank' line *)

   if NumSpecs>SpecMax then begin (* too many specs in database *)
       LoadOK := false;
       writeln;
       writeln ('Database contains ',NumSpecs:3,' specs.');
       writeln ('Currently BEAT can handle only ',SpecMax:3,' specs, however');
       writeln ('Please change the parameter "SpecMax" and recompile BEAT');
       writeln;
       write ('Hit RETURN to continue');
       readln;
     end; (* Load Trace Parameters *)




   for i := 1 to NumSpecs do begin  (* read Doc-# and -description for *)
     for j := 1 to LibStringLength do begin  (* all specs *)
       SpecDocNum[i][j] := ' ';
       SpecDescription[i][j] := ' ';
     end;
     j := 1;
     while not eoln(lib) do begin
       read (lib, SpecDocNum[i][j]);
       j := j + 1;
     end;
     read (lib, dummy);   (* read EOLN character *)
     j := 1;
     while not eoln(lib) do begin
       read (lib, SpecDescription[i][j]);
       j := j + 1;
     end;
     read(lib, dummy);    (* read EOLN character *)
     writeln (i:2,' : ',SpecDocNum[i]);  (* print out information *)
     writeln ('     ',SpecDescription[i]);
   end;

   SpecSelect := 1;   (* Get user selection *)
   writeln;
   repeat begin
     InRange := true;
     GetIParam ('Select by entering a number : ',SpecSelect);
     if (SpecSelect<1) or (SpecSelect>NumSpecs) then begin
       InRange := false;
       writeln ('Incorrect Selection!   Try Again');
     end;
   end;
   until InRange=true;

         (* Second part of this procedure reads and displays the available
            layers for the selected spec and gets a user selection.
            Only first 50% of layers are displayed since boards are
            assumed to be symmectrical.                                    *)
   ClrScr;
   writeln ('Load Library Parameters:');
   writeln (SpecDescription[SpecSelect]);
   writeln ('Listing of available layers');
   writeln ('--------------------------------------------------------------');

   assign(lib,'library.bea');
   reset(lib);
   readln (lib, dummy);       (* skip thru listing of available specs *)
   readln (lib, dummy);
   for i:=1 to NumSpecs do begin
     readln(lib, dummy);
     readln (lib,dummy);
   end;
   readln (lib, dummy);  (* go thru this loop for all specs up to the *)
   for i := 1 to SpecSelect do begin  (* selected spec. Only the data for *)
     readln (lib, dummy);  (* the selected spec are displayed, however *)
     readln (lib, dummy);
     readln (lib, NumLayers);  (* # of layers for this spec *)
     if NumLayers/2<>trunc(NumLayers/2) then begin (* only even # allowed *)
       LoadOK := false;
       writeln;
       writeln ('Database shows ',NumLayers:2,' layers for spec. # ',i:2,'.');
       writeln ('This is incorrect. Only even numbers are allowed.');
       writeln ('The boards are assumed to be symmetrical.');
       writeln ('Please check the manual and correct the database');
       writeln;
       write ('Hit RETURN to continue');
       readln;
     end;
     readln (lib, dummy);   (* # of this layer *)
     for j := 1 to trunc(NumLayers/2) do begin  (* type of this layer *)
       readln (lib, LayerNum);
       for k := 1 to LayerTypeLength do LayerType[j][k] := ' ';
       k := 1;
       while not eoln(lib) do begin
         read (lib, LayerType[j][k]);
         k := k + 1;
       end;
       read (lib, dummy);

       LayerTypeOK := false;    (* make sure it is permitted layer type *)
       if (LayerType[j]='strip     ') or  (* skip next data depending on *)
          (LayerType[j]='embedmicro') then begin  (* type of layer *)
            for l := 1 to 4 do readln (lib, dummy);
            LayerTypeOK := true;
       end;
       if (LayerType[j]='microstrip') or
          (LayerType[j]='dualstrip ') then begin
            for l := 1 to 5 do readln (lib, dummy);
            LayerTypeOK := true;
       end;
       if (LayerType[j]='gnd       ') or (LayerType[j]='pwr       ') or
          (LayerType[j]='gnd/pwr   ') then LayerTypeOK := true;

       if LayerTypeOK=false then begin
         LoadOK := true;
         writeln;
         writeln (LayerType[j]);
         writeln ('This is not a recognized layer type.');
         writeln ('Please check the manual and correct the database');
         writeln;
         write ('Hit RETURN to continue');
         readln;
       end;

       readln (lib, dummy);
       if i=SpecSelect then writeln (j:2,' : ',LayerType[j]);
     end;
   end;

            (* The third parat of this procedure loads the data for the
               selected layer of the selected board into the applicable
               variables.                                                *)
            (* Please note:
               Because of the way this is handled - all data up to the
               selected layer are loaded into the variables, only the selec-
               ted layer will not be overwritten, all variables involved in
               this probably will be clobbered.                          *)
   LayerSelect := 1;
   writeln;
   repeat begin
     InRange := true;
     GetIParam ('Select by entering a number : ',LayerSelect);
     if (LayerSelect<1) or (LayerSelect>NumLayers/2) then begin
       InRange := false;
       writeln ('Incorrect Selection!   Try Again');
     end;
     if (LayerType[LayerSelect]='gnd       ') or
        (LayerType[LayerSelect]='pwr       ') or
        (LayerType[LayerSelect]='gnd/pwr   ') then begin
           InRange := false;
           writeln (LayerType[LayerSelect],':');
           writeln ('This layer cannot be selected for analysis!    Try Again');
     end;
   end;
   until InRange=true;


   assign(lib,'library.bea');
   reset(lib);
   readln (lib, dummy);
   readln (lib, dummy);
   for i:=1 to NumSpecs do begin
     readln(lib, dummy);
     readln (lib,dummy);
   end;
   readln (lib, dummy);
   for i := 1 to SpecSelect do begin
     readln (lib, dummy);
     readln (lib, dummy);
     readln (lib, NumLayers);
     readln (lib, dummy);
     if i=SpecSelect then TempIndex := LayerSelect else
                          TempIndex := trunc(NumLayers/2);
     for j := 1 to TempIndex do begin
       readln (lib, LayerNum);
       for k := 1 to LayerTypeLength do LayerType[j][k] := ' ';
       k := 1;
       while not eoln(lib) do begin
         read (lib, LayerType[j][k]);
         k := k + 1;
       end;
       read (lib, dummy);
       if (LayerType[j]='strip     ') or (LayerType[j]='embedmicro') then begin
         readln (lib, TraceThick);
         readln (lib, TraceWidth);
         readln (lib, TraceHeight);
         readln (lib, DiConst);
       end;
       if LayerType[j]='microstrip' then begin
         readln (lib, TraceThick);
         readln (lib, TraceWidth);
         readln (lib, TraceHeight);
         readln (lib, DiConst);
         readln (lib, SoldMask);
       end;
       if LayerType[j]='dualstrip ' then begin
         readln (lib, TraceThick);
         readln (lib, TraceWidth);
         readln (lib, TraceHeight);
         readln (lib, SigPlaneSep);
         readln (lib, DiConst);
       end;
       readln (lib, dummy);
     end;
   end;
   if LoadOK=true then begin
     writeln;
     writeln ('Parameter have been loaded into variables.');
     writeln;
     write ('Hit RETURN to continue.');
     readln;
   end;
end; (* LoadParameters *)

end.
