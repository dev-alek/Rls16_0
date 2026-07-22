/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список объектов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def 
&if     "{1}" <> "class"
    and "{1}" <> "local"
&then
{1} shared
&endif 
temp-table &if "{2}" <> "" &then {2} &else obj-list &endif no-undo 
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.

&if     "{2}" = "" 
    and "{1}" <> "local"
&then

/* Процедура создания записи в ТТ obj-list */
&if "{1}" = "class"
&then
method public void empty-obj-list ():
   for each obj-list :
      delete obj-list.
   end.
end.
method public logical can-find-obj-list ():
   return can-find (first obj-list no-lock).
end.
/*method public void get-glob-obj-list ():
end.
method public void set-glob-obj-list ():
end.*/
method public void get-obj-list (output table obj-list bind):
end.
method public void set-obj-list (input table obj-list bind):
end.
method public void create_obj-list{2} (p-obj-type as char, p-obj-code as integer ):
&else
procedure create_obj-list{2} :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
&endif
   do
   on error undo, return error return-value
   :

      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .

      define buffer buf_obj-list for obj-list .

      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list 
      then 
         p-var = buf_obj-list.obj-id + 1.
      else 
         p-var = 1.

      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.

      if available cli-obj 
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end. /* do */
end. /* create_obj-list */
&endif

/* $Workfile$ e n d */