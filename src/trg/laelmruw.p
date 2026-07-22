block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись привязки элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.layout-elem-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись привязки элемента раскладки".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.layout-elem-rule.layout-id
                         , ub.layout-elem-rule.mode-id
                         , ub.layout-elem-rule.widget-id
                                                  ) " }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
define variable v-uniq-key-rec as character no-undo .
define buffer buf_layout for ub.layout.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if new (ub.layout)
  and not g#news
  then do:
    assign
    ub.layout-elem-rule.cr-db-num = g#db-num.
  end.
  if not g#news
  and g#db-num > 0 then do:
    find first buf_layout no-lock where
              buf_layout.layout-id = ub.layout-elem-rule.layout-id no-error .
    if not available buf_layout then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Не найдена раскладка &1 для привязки элемента интферфейса &2"
                 , ub.layout-elem-rule.layout-id
                 , ub.layout-elem-rule.widget-id)
      view-as alert-box error .
      undo main-block, return error .
    end.
    if buf_layout.is-default = integer({&layout-default})
    or buf_layout.is-default = integer({&layout-mandatory})
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя добавлять/изменять привязку элемента эталонной раскладки в УБД"
      view-as alert-box error .
    end.
  end.
  if new(ub.layout-elem-rule) then do:
      run gen-key-rec in this-procedure ( input {&table_layout-elem-rule}
                                          ,input buffer ub.layout-elem-rule:handle
                                          ,output v-uniq-key-rec).
    assign
    ub.layout-elem-rule.uniq-key-rec = v-uniq-key-rec.
  end.
  /*запись в историю надо осуществлять в редакторе раскладки*/
  /*маршрутизация в СПН - через куст layout*/
end. /*doe*/