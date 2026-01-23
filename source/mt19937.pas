unit mt19937;

interface

procedure init_genrand(s:longword);
function genrand_int32:longword;

implementation

{ The following are inherited Comments from the original C-source.}

(*
   A C-program for MT19937, with initialization improved 2002/1/26.
   Coded by Takuji Nishimura and Makoto Matsumoto.

   Before using, initialize the state by using init_genrand(seed)
   or init_by_array(init_key, key_length).

   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote
        products derived from this software without specific prior written
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


   Any feedback is very welcome.
   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
   email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)
*)

(* Period parameters *) 
const  
  N= 624;
  M= 397;
  MATRIX_A= $9908b0df;   (* constant vector a *)
  UPPER_MASK= $80000000; (* most significant w-r bits *)
  LOWER_MASK= $7fffffff; (* least significant r bits *)
var
  mt: array[0..N-1] of longword; (* the array for the state vector  *)
  mti:integer=N+1;               (* mti=N+1 means mt[N] is not initialized *)

(* initializes mt[N] with a seed *)
procedure init_genrand(s:longword);
begin
    mt[0]:= s {and $ffffffff};
    mti:=1;
    while mti<N do
      begin
        mt[mti]:=(1812433253*(Mt[mti-1] xor (Mt[mti-1] shr 30))+mti);

       ///* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
        ///* In the previous versions, MSBs of the seed affect   */
        ///* only MSBs of the array mt[].                        */
        ///* 2002/01/09 modified by Makoto Matsumoto             */
        {Mt[mti]:=Mt[mti] and $ffffffff;}(* for >32 bit machines *)
        mti:=mti+1;
      end;
end;

///* initialize by an array with array-length */
///* init_key is the array for initializing keys */
///* key_length is its length */
///* slight change for C++, 2004/2/26 */
(*
void init_by_array(unsigned long init_key[], int key_length)
{
    int i, j, k;
    init_genrand(19650218UL);
    i=1; j=0;
    k = (N>key_length ? N : key_length);
    for (; k; k--) {
        mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525UL))
          + init_key[j] + j; /* non linear */
        mt[i] &= 0xffffffffUL; /* for WORDSIZE > 32 machines */
        i++; j++;
        if (i>=N) { mt[0] = mt[N-1]; i=1; }
        if (j>=key_length) j=0;
    }
    for (k=N-1; k; k--) {
        mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941UL))
          - i; /* non linear */
        mt[i] &= 0xffffffffUL; /* for WORDSIZE > 32 machines */
        i++;
        if (i>=N) { mt[0] = mt[N-1]; i=1; }
    }

    mt[0] = 0x80000000UL; /* MSB is 1; assuring non-zero initial array */ 
}
*)

(* generates a random number on [0,0xffffffff]-interval *)

function genrand_int32:longword;
const
  mag01 : array[0..1] of longword=(0,MATRIX_A);

       (* mag01[x] = x * MATRIX_A  for x=0,1 *)

var
   y:longword;
   kk:integer;
begin
   if (mti >= N)  then       (* generate N words at one time *)
     begin
        if (mti = N+1) then   (* if init_genrand() has not been called, *)
            init_genrand(5489);    (* a default initial seed is used *)

        for kk:=0 to N-M-1 do
          begin
            y:= (mt[kk] and UPPER_MASK) or (mt[kk+1] and LOWER_MASK);
            Mt[kk]:=Mt[kk+M] xor (y shr 1) xor mag01[y and 1];
          end;
        for kk:=N-M to N-2 do
          begin
            y:= (mt[kk] and UPPER_MASK) or (mt[kk+1] and LOWER_MASK);
            mt[kk]:=mt[kk+(M-N)] xor (y shr 1) xor mag01[y and 1];
          end;

        y:= (mt[N-1] and UPPER_MASK) or (mt[0] and LOWER_MASK);
        mt[N-1]:=mt[M-1] xor (y shr 1) xor mag01[y and 1];

        mti:= 0;
    end;
  
    y:= mt[mti];
    mti:=mti +1;

    (* Tempering *)
    y:=y xor (y shr 11);
    y:=y xor ((y shl 7) and $9d2c5680);
    y:=y xor ((y shl 15) and $efc60000);
    y:=y xor (y shr 18);
    result:=y;
end;


end.



