/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса ipc-servis+

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" &then
  assign
  out = {&cd-buffer}.addr-path + "in\"
  fname = string(year(today) modulo 10) + string(month(today),"99") +
                string(day(today),"99") + string(next-value(s-file-num, {&db-name_schema}),"999") .
  output stream plucash to value(
  string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu'
                                                    )
  convert target "ibm866".
  output stream bar to value(
  string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar'
                                                    )
  convert target "ibm866".
&endif

&if "{&subject}" = "dis-card" &then
  assign
  out = {&cd-buffer}.addr-path + "in\":U
  fname = "disccli":U
  .
  output to value(
  string( session:temp-directory + "cli":U + string( var-report-num ) ) + '.cli':U
        )
  convert target "ibm866".

&endif
&if "{&subject}" = "seller" &then
  assign
  out = {&cd-buffer}.addr-path + "in\"
  fname = string(year(today) modulo 10) + string(month(today),"99") +
                string(day(today),"99") + string(next-value(s-file-num, {&db-name_schema}),"999") .
  output stream IBMstream to value(
  string( session:temp-directory + "depart" + string( var-report-num ) ) + '.dep')
  convert target "ibm866".
&endif

&if "{&subject}" = "currency" &then
  assign
  out = {&cd-buffer}.addr-path + "in\"
  fname = string( year( today ) modulo 10 ) +
          string( month( today ), "99" ) + string( day( today ), "99" ) +
          string( next-value( s-file-num, {&db-name_schema} ), "999" ) .
  .
  output stream Ibmstream to value(out  + fname + '.cur') convert target "ibm866".
&Endif

/* $Workfile$ e n d */