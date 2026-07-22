/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для определения имени расширенного типа документов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 11/05/02 11:28

*/

{ cmp/str-glbl.i }
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
 { rep/gn-ext.i
    p-ext-type
    p-caps
    v-ext-name
    no-error }
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type   /* тогда паказываем код */
       .
    end.

 return (v-ext-name) .
end.


procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :

define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .

define variable v-num as integer no-undo .

  if lookup ( p-ext-type , {&TDEDT_List} ) = 0 then do :
    message
      vss-include-info{&vssseq} skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.

  v-num      = lookup ( p-ext-type , {&TDEDT_List} ) .
  p-ext-name = entry  ( v-num , {&TDEDT_List-full} ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .


  end. /* do */
end procedure. /* get-name-from-ext-type */


/* $Workfile$ e n d */