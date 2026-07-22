/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметр Объект АПТЕКА

Автор: Чернова Светлана Александровна
Дата создания: 11/27/09
Author: Svetlana Chernova
Creation date: 11/27/09

&1  - obj-type
&2  - obj-code
&3  - параметр конфигурационный Аптека

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
{ cmp/str-glbl.i }

define variable v-o-pharm    as character no-undo .
define variable v-o-var-type as character no-undo .

  run clntattr-value in this-procedure
    ( input   {1} ,
      input   {2} ,
      input  {&attr-pharm},
      output v-o-pharm    ,
      output v-o-var-type )
     no-error .
  if v-o-pharm <> "yes":u or error-status :error then do:
     {3} = "no"  .
  end.