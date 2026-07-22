/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса OMRON-NEW

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


assign
v-versiond = decimal({&cd-buffer}.version)
no-error .
if error-status:error
or v-versiond < 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute("Неверное значение поля <ВЕРСИЯ> &1 для кассы типа &2 № &3 в справочнике касс&4" +
              "Значение версии может быть только десятичным числом > 0"
              ,{&cd-buffer}.version
              ,{&cd-buffer}.pos-type
              ,{&cd-buffer}.cash-num
              ,{&new-line}
              ) ).
  return error .
end.

&if "{&subject}" = "good" &then
  assign
  out = ({&cd-buffer}.addr-path + "out\" )
  fname = 'plu'.
  output to value( out + fname + '.dat' ) convert target "ibm866".
&endif

&if "{&subject}" = "dis-card" &then
  assign
  out = ({&cd-buffer}.addr-path + "out\":U )
  fname = 'client'.
  output to value( out + fname + '.dat':U ) convert target "ibm866".
&endif

&if "{&subject}"= "currency" &then
  assign
  out = ({&cd-buffer}.addr-path + "out\"   )
  fname = "currency" .
  output to value(out  + fname + '.dat') convert target "ibm866".
&endif

/* $Workfile$ e n d */