block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление привязки элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.layout-elem-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление привязки элемента раскладки".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.layout-elem-rule.layout-id
                         , ub.layout-elem-rule.mode-id
                         , ub.layout-elem-rule.widget-id
                                                  ) " }

{ cmp/trg-def.i }
define buffer buf_layout for ub.layout.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
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
    if buf_layout.is-default = integer({&layout-default}) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять привязку элемента эталонной раскладки в УБД"
      view-as alert-box error .
    end.
  end.
  for each buf_rule-by-call where
          buf_rule-by-call.call_id  = ub.layout-elem-rule.uniq-key-rec
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    delete buf_rule-by-call.
  end.
  for each buf_rule-call-param where
          buf_rule-call-param.call_id  = ub.layout-elem-rule.uniq-key-rec
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    delete buf_rule-call-param.
  end.
  /*запись в историю надо осуществлять в редакторе раскладки*/
  /*маршрутизация в СПН - через куст layout*/
end. /*doe*/