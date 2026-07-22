/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка списка recid-ов при нажатии кнопки b-mark ( {&Btn_Mark} )

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/04
Author: Bakhtadze Natalya
Creation date: 09/29/04

Параметры:
  {1} - буфер;
  {2} - список;
  {3} - переменная или поле, если в список помешаются не RECID`ы.
Должны быть заданы: {2} (обязательно) и {1} или {3} (любой по выбору).

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop seq {&sequence}

&if '{3}' = '' &then
  &if '{1}' = '' &then
&message не задан буфер
  &else
  &scop list-item recid( {1} )
  &endif
&else
  &scop list-item {3}
&endif
&if '{2}' = '' &then
  &message не задан список
&endif

define variable v-str-recid{&seq} as character no-undo .
define variable v-num-entry{&seq} as integer   no-undo .

assign
  v-str-recid{&seq} = trim( string( {&list-item} , "->>>>>>>>>>>9":U ) )
  v-num-entry{&seq} = lookup( v-str-recid{&seq} , {2} )
.
if v-num-entry{&seq} > 0 then do:
  assign
    entry( v-num-entry{&seq}, {2} ) = "":U
    {2} = trim( replace( {2} , {&comma-char} + {&comma-char} , {&comma-char} ) , {&comma-char} )
  .
end.
else do:
  assign
    {2} = {2} + ( if {2} = "":U then "":U else {&comma-char} ) + v-str-recid{&seq}
  .
end.

/* $Workfile$   E n d */