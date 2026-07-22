block-level on error undo, throw.
/*

Чистка БД. Топливные транзакции. 

Автор: Ростовцев Александр
Дата создания: 28/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/29/25
*/

&scop Tables Топливные транзакции
/*&scop Tables tran-fuel ~*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Oct 28 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 01020000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/01020000.p $".
define variable vss-description as character no-undo init "Чистка УБД..".
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cleandb/defs.i }

define buffer tran-fuel         for ub.tran-fuel.

on delete of ub.tran-fuel       override do: end.

for each tran-fuel exclusive-lock
   where /*tran-fuel.date-beg < datetime(vardate-actual-docs,0)
     and*/ tran-fuel.date-end < datetime(vardate-actual-docs,0)
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
    delete tran-fuel.
    vDeleted = vDeleted + 1.
end.

{cleandb/setresval.i}
return vResult.
