block-level on error undo, throw.
/*

Чистка БД. clob-data.

Автор: Ростовцев Александр
Дата создания: 03/10/2025
Author: Aleksandr Rostovtsev
Creation date: 10/03/25
*/

&scop Tables Двоичные данные документов 
/*&scop Tables clob-bind clob-data*/

define variable vss-revision    as character no-undo init "$Revision: b1849e93de2b, 967, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: 03/10/2025":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00994000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00994000.p $".
define variable vss-description as character no-undo init "Файл пирога чистки БД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-bh as handle no-undo .
define variable lob-reslist-date-egais as character no-undo .
define variable v-ii as integer no-undo .
define variable v-entry as character no-undo .
define variable v-doc-code as character no-undo .

define buffer clob-bind     for ub.clob-bind.
define buffer buf_clob-bind for ub.clob-bind.
define buffer clob-data     for ub.clob-data.

on delete of ub.clob-bind             override do: end.
on delete of ub.clob-data             override do: end.

lob-reslist-date-egais = {&lob-egais-ab} + {&comma-char} + {&lob-egais-awo} + {&comma-char}
  + {&comma-char} + {&lob-egais-ab_shop} + {&comma-char} + {&lob-egais-awo_shop}.

do v-ii = 1 to num-entries(lob-reslist-date-egais):
  v-entry = entry(v-ii, lob-reslist-date-egais).
  cicl0_:
  for each clob-bind no-lock where
           clob-bind.resource-type = v-entry 
       and clob-bind.sys-date      < vardate-actual-docs
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    for each clob-data exclusive-lock where 
             clob-data.db-num = clob-bind.db-num
         and clob-data.int64-id = clob-bind.int64-id 
    :
      delete clob-data.
      vDeleted = vDeleted + 1.
    end.
    { cleandb/delmainrec.i  clob-bind}
  end.

end.

{cleandb/setresval.i}
return vResult.


