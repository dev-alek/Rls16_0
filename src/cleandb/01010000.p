block-level on error undo, throw.
/*

Чистка БД. История действий пользователя. 

Автор: Ростовцев Александр
Дата создания: 23/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/23/25
*/

&scop Tables История действий пользователя
/*&scop Tables c-user-log ~*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Oct 23 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 01010000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/01010000.p $".
define variable vss-description as character no-undo init "Чистка УБД..".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cleandb/defs.i }

define buffer c-user-log         for ub.c-user-log.

on delete of ub.c-user-log       override do: end.

for each c-user-log exclusive-lock
   where c-user-log.corr-user-name > ""
     and c-user-log.corr-date < vardate-actual-docs
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    delete c-user-log.
    vDeleted = vDeleted + 1.
end.

{cleandb/setresval.i}
return vResult.
