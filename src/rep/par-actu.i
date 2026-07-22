/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

временна€ таблица дл€ хранени€ параметров отчетов

јвтор: „ернова —ветлана јлександровна
ƒата создани€: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 01/17/03 10:25

*/
&if "{1}"   = "" &then
define temp-table param-to-export no-undo
field param-code     as character
field param-sub-code as character
field param-type     as character
field param-value    as character
field param-comment  as character
index pi is unique primary  param-code     param-sub-code
.
&endif

&if     "{1}"   <> "run-proc"
    and "{1}"   <> "proc"
    and "{1}"   <> "method"
    and "{1}"   <> "" &then
  {1}:create-param-to-export
  ( input {2}  , /* код параметра */
   input {3}  , /* подкод параметра дл€ списков  */
   input {4}  , /* тип параметра character integer logical data decimal*/
   input {5}  , /* значение параметра */
   input {6} )  /* комментарий по параметру */
  {7}
 .

&endif

&if "{1}"   = "run-proc" &then
  run create-param-to-export  in this-procedure
  ( input {2}  , /* код параметра */
   input {3}  , /* подкод параметра дл€ списков  */
   input {4}  , /* тип параметра character integer logical data decimal*/
   input {5}  , /* значение параметра */
   input {6} )  /* комментарий по параметру */
  {7}
 .

&endif

&if "{1}"   = "method" &then
method public void create-param-to-export 
 ( p1 as character,
   p2 as character,
   p3 as character,
   p4 as character,
   p5 as character
  )  
      
         
            :
 do
 on error undo, return error return-value
 :


  create  param-to-export.
  assign
     param-to-export.param-code     =  p1
     param-to-export.param-sub-code =  p2
     param-to-export.param-type     =  p3
     param-to-export.param-value    =  p4
     param-to-export.param-comment  =  p5
  .

 end. /* do */
end . /* create-param-to-export */

method public void get-param-to-export (output table param-to-export):
end.
method public void set-param-to-export (input table param-to-export):
end.
&endif

&if "{1}"   = "proc" &then
procedure create-param-to-export :
 do
 on error undo, return error return-value
 :
 define input parameter p1 as character no-undo .
 define input parameter p2 as character no-undo .
 define input parameter p3 as character no-undo .
 define input parameter p4 as character no-undo .
 define input parameter p5 as character no-undo .

  create  param-to-export.
  assign
     param-to-export.param-code     =  p1
     param-to-export.param-sub-code =  p2
     param-to-export.param-type     =  p3
     param-to-export.param-value    =  p4
     param-to-export.param-comment  =  p5
  .

 end. /* do */
end procedure. /* create-param-to-export */

&endif



/* $Workfile$ e n d */