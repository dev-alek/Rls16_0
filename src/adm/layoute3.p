block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: layoute3.p $
$Archive: adm/layoute3.p $

Удаление элемента раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/30/08
Author: Bakhtadze Natalya
Creation date: 09/30/08

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: layoute3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/layoute3.p $":U .
define variable vss-description as character no-undo init "Удаление элемента раскладки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/get-regf.i }

define variable v-mess as character no-undo .
define variable v-prop-code as character no-undo .
define buffer buf_layout-elem  for ub.layout-elem.
define buffer buf_layout  for ub.layout.
define buffer buf_layout-elem-rule  for ub.layout-elem-rule.
define buffer buf_thbj-attr for ub.thbj-attr.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_layout-elem exclusive-lock where
          recid(buf_layout-elem) = p-rec .
  if g#db-num > 0 then do:
    v-mess = substitute("Нельзя удалять элемент раскладки в УБД"
                        ).
    run err-mess in this-procedure ( input-output v-mess) .
    undo main-block, return error (if p-silent = yes then v-mess else '':U).

  end.
  for each buf_layout no-lock where
          buf_layout.layout-type = buf_layout-elem.layout-type
      and buf_layout.device-type = buf_layout-elem.device-type,
      each buf_layout-elem-rule no-lock where
              buf_layout-elem-rule.layout-id  = buf_layout.layout-id
           and buf_layout-elem-rule.mode-id = buf_layout-elem.mode-id
           and buf_layout-elem-rule.widget-id = buf_layout-elem.widget-id :
    leave.
  end.
  if available buf_layout-elem-rule then do:
    v-mess = substitute("Нельзя удалить элемент раскладки  -  есть привязанные элементы в раскладке &1)"
                      , buf_layout.layout-id

                      ).
    run err-mess in this-procedure ( input-output v-mess) .
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  delete buf_layout-elem.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Элемент &4 раскладки типа &1 для устройства &2 режим &3: &5"
                         , buf_layout-elem.layout-type
                         , buf_layout-elem.device-type
                         , buf_layout-elem.mode-id
                         , buf_layout-elem.widget-id
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.