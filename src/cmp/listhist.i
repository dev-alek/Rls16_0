/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение временной таблицы для заполнения истории для механизмов списков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/17/05
Author: Bakhtadze Natalya
Creation date: 09/17/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if  "{2}" = "method"
&then

method public void empty-{1}-hist ():
   for each {1}-hist :
      delete {1}-hist.
   end.
end.
method public void get-glob-{1}-hist ():
end.
method public void set-glob-{1}-hist ():
end.
method public void get-{1}-hist (output table {1} bind):
end.
method public void set-{1}-hist (input table {1} bind):
end.
method public character  get-{1}-note ():
   define variable o-notes as character no-undo.
   define variable v-i as integer no-undo.
   for each {1}-hist :
      v-i = v-i + 1 .
      o-notes = o-notes + {&new-line} + {1}-hist.hist-mode +  {1}-hist.des .
      if v-i > 10 
      then do:
         o-notes = o-notes + " ... " .
         leave.
      end.
   end.
end.

&else
define  {2}  temp-table {1}-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
&endif

/* $Workfile$ e n d */