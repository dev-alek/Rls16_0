/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список объектов

Автор: Рубан Дмитрий
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
temp-table &if "{2}" <> "" &then {2} &else g#customer &endif no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.

&if     "{2}" = "" 
    and "{1}" <> "local"
&then

/* Процедура создания записи в ТТ obj-list */
&if "{1}" = "class"
&then
method public void empty-g#customer  ():
   for each g#customer  :
      delete g#customer .
   end.
end.
method public logical can-find-g#customer  ():
   return can-find (first g#customer  no-lock).
end.
/* method public void get-glob-g#customer  ():
   
end.
method public void set-glob-g#customer  ():
end. */
method public void get-g#customer  (output table obj-list bind):
end.
method public void set-g#customer  (input table obj-list bind):
end.
method public void create_g#customer  (p-obj-type as char, p-obj-code as integer,p-obj-Name as character  ):
&else
procedure create_g#customer  :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   define input parameter p-obj-Name like ub.clients.obj-name no-undo .
&endif
   do
   on error undo, return error return-value
   :

      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .

      define buffer buf_g#customer for g#customer .

      find first buf_g#customer  where buf_g#customer.obj-type eq p-obj-type
                                   and buf_g#customer.obj-code eq p-obj-code
      no-error.
      if not available buf_g#customer 
      then do:
         find first cli-obj where
                    cli-obj.obj-type = p-obj-type
                and cli-obj.obj-code = p-obj-code
         no-lock no-error.

         if available cli-obj 
         then do:
            create buf_g#customer.
            assign
               buf_g#customer.obj-code = cli-obj.obj-code
               buf_g#customer.obj-type = cli-obj.obj-type
               buf_g#customer.obj-name = cli-obj.obj-name
            .
         end.
      end.
   end. /* do */
end. /* create_obj-list */
&endif

/* $Workfile$ e n d */