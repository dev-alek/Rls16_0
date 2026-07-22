block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Генерация списка БД где нужно удалять правило скидки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/14/06
Author: Bakhtadze Natalya
Creation date: 05/14/06

*/

define input  parameter p-action       as character no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
define output parameter p-list-db      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Генерация списка БД где нужно удалять праивла скидок".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/key-rec.i }

do
on error undo, return error return-value
:

  define variable v-tbl-name as character no-undo .
  define variable v-tbl-row as rowid no-undo .

  define buffer buf_dis-rule for ub.dis-rule.
  define buffer buf_db-rec-attr for ub.db-rec-attr.
  define buffer buf_clients for ub.clients.
  define buffer buf_db for ub.db .

  run gen-row-keyr in this-procedure
    ( input  p-uniq-key-rec
     ,input ?
     ,input "ub":U
     ,input ?
     ,input share-lock
     ,output v-tbl-row
     ,output v-tbl-name
    ) .

  if v-tbl-name <> {&table_dis-rule} then do:
    return error substitute( "&1. Данная процедура может работать только с таблицей правил скидок", vss-workfile ).
  end.
  find first buf_dis-rule no-lock where
            rowid(buf_dis-rule) = v-tbl-row no-error .
  if available buf_dis-rule then do:
    if not (buf_dis-rule.obj-type = '':U
            and
            buf_dis-rule.obj-code = 0) then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_dis-rule.obj-type
            and buf_clients.obj-code = buf_dis-rule.obj-code no-error .
      if not available buf_clients then do:
        return error substitute("&1 Не найден объект &2&3 для правила скидки № &4"
                                 ,vss-workfile
                                 ,buf_dis-rule.obj-type
                                 ,buf_dis-rule.obj-code
                                 ,buf_dis-rule.rule-num ).
      end.
      if buf_clients.db-num = ? then do:
        return error substitute("&1 Неверный номер БД &2 для объекта &3&4 правила скидки № &5"
                                 ,vss-workfile
                                 ,{&question-mark}
                                 ,buf_dis-rule.obj-type
                                 ,buf_dis-rule.obj-code
                                 ,buf_dis-rule.rule-num ).
      end.
      if buf_clients.db-num > 0 then
      assign
        p-list-db = string(0) + {&comma-char} +  string(buf_Clients.db-num)
      .
      return.
    end.
  end. /*if avail dis-rul*/
  else do:
    find first buf_db-rec-attr no-lock where
              buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
          and buf_db-rec-attr.attr-code          = p-action no-error .
    if not available buf_db-rec-attr then do:
      p-list-db = {&question-mark}.
    end.
    else do:
      assign
        p-list-db = entry(3, buf_db-rec-attr.attr-value, {&delim-par}).
      .
    end.
    if p-list-db <> {&question-mark} then do:
      return.
    end.
  end.
  assign
    p-list-db = "":U .
  .
  for each buf_db no-lock
    where buf_db.db-num >= 0
  on error undo, return error
  :
    if p-list-db = "":U then do:
      assign
        p-list-db = string( buf_db.db-num ).
      .
    end.
    else do:
      assign
        p-list-db = p-list-db + {&comma-char} + string( buf_db.db-num ).
      .
    end.
  end.

end.

return.