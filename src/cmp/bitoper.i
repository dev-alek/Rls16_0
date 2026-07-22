/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

функции побитных операций

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*функция преобразования неотрицательного целого числа в строковое двоичное длиной 32 разряда*/
/*самые младшие биты стоят справа*/
/*CintBinS(1) =  "00000000000000000000000000000001"*/
/*CintBinS(109)  "00000000000000000000000001101101"*/


FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
/*vl_int число подлежащее преобразованию*/

def var vl_bin as char no-undo init "".

if vl_int < 0 OR vl_int = ? then return ?.

do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .

END FUNCTION.

/*функция побитного сравнения неотрицательного целого чиcла с маской наложенной от правого конца*/
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
/*vl_int число, которое необходимо сравнить*/
/*побитная маска заданная в виде последовательности символов 1 (бит взведен), 0 (бит лежит) x(все равно)*/

/*например */
/* BinMask( 42   ,"XX101X") дает yes потому что 42 в двоичном виде   101010
   BinMask( 75   ,"XX101X") дает yes потому что 75 в двоичном виде  1001011
   BinMask( 76   ,"XX101X") дает no  потому что 76 в двоичном виде  1001100
   BinMask( 75   ,"0X101X") дает no  потому что 75 в двоичном виде  1001011
*/

DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.

/*сначала сконвертируем vl_int в двоичное строковое*/
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.

assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.

DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.

return yes.

END FUNCTION.

/* $Workfile$ e n d */