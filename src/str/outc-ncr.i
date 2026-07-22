/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса NCR

Автор: Бахтадзе Наталья Викторовна
Дата создания:  12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" &then
  fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 ).
  output stream IBMStream
  to value( out + fname + '.dat' ) convert target "ibm866".
  .

&endif

&if "{&subject}" = "parameters" &then
  fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 ).
&endif


&if "{&subject}" = "dis-card" &then
  fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 ).
  output stream IBMStream
  to value( out + fname + '.dat' ) convert target "ibm866".
  .
  /*выясним формат посылки с точки зрения частных итогов*/
  /*
  assign
  v-sum-id-output = no
  v-sum-id-field-abbr = '':U
  v-sum-id-field-num = 0
  .
  if index({&cd-buffer}.version, 'sum-id=':U) > 0 then do:
    v-sum-id-field-abbr = substring({&cd-buffer}.version, index({&cd-buffer}.version, 'sum-id=':U) + length('sum-id=')).
    do v-sum-id-field-num = 1 to 3:
      if v-sum-id-field-abbr begins algo-field-abbr[v-sum-id-field-num] then do:
        v-sum-id-output = yes.
        leave.
      end.
    end.
  end.
  */
&endif

/* $Workfile$ e n d */