block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00996000.p $
$Archive: cut/00996000.p $

Файл пирога обрезания. Относится к категории 996.

c-table-bind

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/09
Author: Bakhtadze Natalya
Creation date: 05/25/09

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00996000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00996000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 996.".
{ cmp/str-glbl.i }

define buffer old-c-table-bind for src.c-table-bind.
define buffer new-c-table-bind for dst.c-table-bind.
define buffer old-c-gds-hist for src.c-gds-hist.
define buffer old-c-recipe-hist for src.c-recipe-hist.
define buffer new-goods for dst.goods.



do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
{ utl/00000001.i }

on WRITE of dst.c-table-bind override do: end.

if varstay-history then do:
  for each old-c-table-bind no-lock:
    /* в 15.0 переносим все - индексов нет!!!*/
    /*
    if old-c-table-bind.tbl-name-rec = {&table_c-gds-hist} then do:
      find first old-c-gds-hist no-lock where
                old-c-gds-hist.chip-num = old-c-table-bind.chip-num-rec
            and old-c-gds-hist.corr-user-db-num = old-c-table-bind.corr-user-db-num no-error.
      if not available old-c-gds-hist then next.
      find first new-goods no-lock where
                new-goods.gds-code = old-c-gds-hist.gds-code no-error.
      if not available new-goods then next.
    end.
    if old-c-table-bind.tbl-name-rec = {&table_c-recipe-gds}
    or old-c-table-bind.tbl-name-rec = {&table_c-recipe} then do:
      find first old-c-recipe-hist no-lock where
                old-c-recipe-hist.chip-num = old-c-table-bind.chip-num-rec
            and old-c-recipe-hist.corr-user-db-num = old-c-table-bind.corr-user-db-num no-error.
      if not available old-c-recipe-hist then next.
      find first new-goods no-lock where
                new-goods.gds-code = old-c-recipe-hist.gds-code no-error.
      if not available new-goods then next.
    end.
    if old-c-table-bind.tbl-name-src = {&table_c-gds-hist} then do:
      find first old-c-gds-hist no-lock where
                old-c-gds-hist.chip-num = old-c-table-bind.chip-num-src
            and old-c-gds-hist.corr-user-db-num = old-c-table-bind.corr-user-db-num no-error.
      if not available old-c-gds-hist then next.
      find first new-goods no-lock where
                new-goods.gds-code = old-c-gds-hist.gds-code no-error.
      if not available new-goods then next.
    end.
    if old-c-table-bind.tbl-name-src = {&table_c-recipe}
    or old-c-table-bind.tbl-name-src = {&table_c-recipe-gds} then do:
      find first old-c-recipe-hist no-lock where
                old-c-recipe-hist.chip-num = old-c-table-bind.chip-num-src
            and old-c-recipe-hist.corr-user-db-num = old-c-table-bind.corr-user-db-num no-error.
      if not available old-c-recipe-hist then next.
      find first new-goods no-lock where
                new-goods.gds-code = old-c-recipe-hist.gds-code no-error.
      if not available new-goods then next.
    end.
    */
    create new-c-table-bind.
    buffer-copy old-c-table-bind to new-c-table-bind.

  end.
end.
output stream str-gen close.
return "Произведен экспорт таблиц: c-table-bind .".
end.




