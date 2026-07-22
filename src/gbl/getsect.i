/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить всю секцию во временную таблицу

Автор: Чернова Светлана Александровна
Дата создания: 07/09/08
Author: Svetlana Chernova
Creation date: 07/09/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "def"  &then
{ gbl/thbj-def.i  }
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
&endif


&if "{1}" = "run"  &then
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input {2}
  ,input {3}
  ,input {4}
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
&endif

/* $Workfile$ e n d */