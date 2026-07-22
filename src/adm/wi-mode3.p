block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wi-mode3.p $
$Archive: adm/wi-mode3.p $

Удаление режимов работы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/03/08
Author: Bakhtadze Natalya
Creation date: 10/03/08

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wi-mode3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/wi-mode3.p $":U .
define variable vss-description as character no-undo init "Удаление режимов работы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .

define buffer buf_wi-mode  for dictdb.wi-mode.
define buffer buf_layout-elem-rule  for dictdb.layout-elem-rule.
define buffer buf_layout-elem  for dictdb.layout-elem.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Данная процедуры не может вызываться в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_wi-mode exclusive-lock where
        recid(buf_wi-mode) = p-rec .
  find first buf_layout-elem-rule no-lock where
          buf_layout-elem-rule.mode-id = buf_wi-mode.mode-id
       no-error .
  if available buf_layout-elem-rule then do:
    v-mess = substitute("К данному режиму работы привязан элемент &1 раскладке с  id &2&3Удаление невозможно"
                        , buf_layout-elem-rule.mode-id
                        , buf_layout-elem-rule.layout-id
                        , {&new-line}
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.

  find first buf_layout-elem no-lock where
          buf_layout-elem.mode-id = buf_wi-mode.mode-id
          no-error .
  if available buf_layout-elem then do:
  v-mess = substitute("К данному режиму привязан элемент &1 раскладки типа &2  для устройства &3&4Удаление невозможно"
                      , buf_layout-elem.widget-id
                      , buf_layout-elem.layout-type
                      , buf_layout-elem.device-type
                      , {&new-line}
                      ).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else '':U).
  end.
  delete buf_wi-mode.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Тип режма &1 режим &2&3: &4"
                         , buf_wi-mode.mode-type
                         , buf_wi-mode.mode-id
                         , {&new-line}
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