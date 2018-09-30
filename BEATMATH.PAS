{$N+ }
unit beatmath;

interface
 uses crt, beatinc, beatio;

function tanh (x : real) : real;
procedure cdivide(var c:complex;a,b:complex);
procedure cpolar(var magnitude,phase:real;a:complex);
procedure cexp(var c:complex;a:complex;x:real);
procedure cmult(var c:complex;a,b:complex);
procedure FourierValues(var Cmag, Cphase:extendedvector);
procedure FourierAnal;


implementation

(****************************************************************************)
function tanh;
(****************************************************************************)
   begin
      tanh := (exp(x) - exp(-x)) / (exp(x) + exp(-x));
   end (* tanh *);

(* Complex divide *)
procedure cdivide;
var denominator:real;
begin
      if (abs(b[r]) > sqrt(BIG)) or (abs(b[i]) > sqrt(BIG)) then begin
         c[r] := 0.0;
         c[i] := 0.0;
      end
      else begin
         denominator := sqr(b[r]) + sqr(b[i]);
         if (denominator = 0.0) then writeln('Divide by zero in cdivide');
         c[r] := (a[r]*b[r] + a[i]*b[i]) / denominator;
         c[i] := (a[i]*b[r] - a[r]*b[i]) / denominator;
      end;
end; (*cdivide *)

(* Complex to polar coordinates *)
procedure cpolar;
begin
      if (abs(a[r]) > sqrt(BIG)) or (abs(a[i]) > sqrt(BIG)) then
         writeln('Overflow in cpolar');
      magnitude := sqrt( sqr(a[r]) + sqr(a[i]) );
      if (abs(a[r]) < SMALL) then
          begin
              if abs(a[i]) < SMALL then
                  phase := 0.0
              else begin
                  if a[i]>0.0 then
                       phase := pi/2.0
                  else
                       phase := -pi/2.0;
              end;
          end
      else
          begin
             phase     := arctan( a[i] / a[r] );
             if a[r]<0 then
                if a[i]>0 then
                       phase := pi+phase else phase := phase-pi;
          end;
end; (* cpolar *)

(* c=a^x where a is complex and x is real *)
procedure cexp;
      var
        phase,magnitude:real;
      begin
        if x=0 then begin
          c[r] := 1.0; c[i] := 0;
        end
        else begin
          cpolar(magnitude,phase,a);
          if (magnitude <= SMALL) then begin
            c[i] := 0; c[r] := 0;
          end
          else begin
            c[i] := exp(ln(magnitude)*x)*sin(phase*x);
            c[r] := exp(ln(magnitude)*x)*cos(phase*x)
          end;
        end;
      end; (* cexp *)

(* Complex multiply : c=ab  *)
procedure cmult;
begin
      c[r] := a[r]*b[r] - a[i]*b[i];
      c[i] := a[r]*b[i] + a[i]*b[r]
end; (* cmult *)

procedure FourierValues;

var
   Csub,
   Slope : extendedvector;
   X,K : integer;
   NumHarmonics,NumPoints : integer;
   A,B : real;
   Period : extended;

begin
   writeln;
   GetIParam('Number of Harmonics? ',NumHarmonics);
   GetIParam('Number of Points? ',NumPoints);
   GetParam('Enter Period : ',4,Period);
   for X := 1 to NumPoints do
   begin
      writeln;
      GetParam('Enter time : ',4,Time[X]);
      GetParam('Enter magnitude: ',0,Magnitude[X]);
   end;

   Magnitude[NumPoints + 1] := Magnitude[1];
   Time[NumPoints + 1] := Period;
   Cmag[0] := 0 ; Cphase[0] := 0;
   for X := 1 to NumPoints do begin
      Cmag[0] := Cmag[0] + 0.5*(Magnitude[X+1]+Magnitude[X])
                   *(Time[X+1]-Time[X])/Period;
      Slope[X] := (Magnitude[X+1] - Magnitude[X])
                           /(Time[X+1] - Time[X]);
   end;
   Csub[1] := Slope[1]-Slope[NumPoints];
   for X := 1 to NumPoints-1 do
      Csub[X+1] := Slope[X+1] - Slope[X];
   for K := 1 to NumHarmonics do
   begin
      A := 0;
      B := 0;
      for X := 1 to NumPoints do
      begin
         A := -Csub[X] * cos(2*pi*K*Time[X]/Period) + A;
         B := Csub[X] * sin(2*pi*K*Time[X]/Period) + B;
      end;
      Cmag[K] := (Period/(sqr(2*pi*K)))*sqrt(sqr(A) + sqr(B));
(*      Cphase[K] := atan2(B,A); *)
   end;
   ClrScr;
   writeln ('FUNCTION DEFINITION');
   writeln ('------------------------------');
   writeln ('Period(ns) ', Period);
   writeln;
   writeln ('| Point | Time(ns)| Magnitude |');
   writeln ('------------------------------');
   for X := 1 to NumPoints do
      writeln ('|',X:6,' |',Time[X]:7, ' |',Magnitude[X]:10,' |');
   writeln;
end; (*FourierValues *)

(****************************************************************************)
procedure FourierAnal;
(****************************************************************************)

var
   Cmag,Cphase : extendedvector;
   Again : boolean;
   K : integer;
   FourierCoefDat : File of extended;

begin
   Again := true;
   while Again = true do
   begin
      Assign (FourierCoefDat, 'FourierCoef.dat');
      rewrite(FourierCoefDat);
      ClrScr;
      writeln ('This program executes a fourier analysis');
      writeln ('-----------------------------------------------------------');
      FourierValues(Cmag,Cphase);
      writeln;
      writeln ('| Harmonic | C_Mag     | C_Phase    |');
      writeln ('-------------------------------------');
      write(FourierCoefDat,NumHarmonics,Period);
      for K := 0 to NumHarmonics do begin
         writeln ('|',K:9,' |',Cmag[K]:10, ' |',Cphase[K]:10,' |');
         write(FourierCoefDat,K,Cmag[K],Cphase[K]);
      end;
      writeln('(Coefficient data written to file "FourierCoefDat".)');
      writeln;
      close(FourierCoefDat);
      GetResponse('Another fourier analysis (y/n)? ',Again);
   end;
end; (* FourierAnal *)

end.
