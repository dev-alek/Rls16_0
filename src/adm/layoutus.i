/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка РАСКЛАДКИ на испльзуемость

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/27/08
Author: Bakhtadze Natalya
Creation date: 10/27/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure layoutus_is-used :
define input parameter p-layout-type as character no-undo .
define input parameter p-layout-id as character no-undo .
define output parameter p-is-used as logical no-undo .
define output parameter p-mess as character no-undo .

define variable v-upper-prop-code as character no-undo .
define variable v-prop-code as character no-undo .

define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.


do
on error undo, return error
:

  p-is-used = yes.
  case p-layout-type:
    when {&th-pos-keyboard} then do:
       assign
       v-upper-prop-code = {&attr-cd-type-IBS-TH_ibs-th_devices}
       v-prop-code = {&attr-cd-type-IBS-TH_ibs-th_devices_keyboard-layout-id}
       .
    end.
    when {&th-pos-screen} then do:
      assign
      v-upper-prop-code = {&attr-cd-type-IBS-TH_ibs-th_interface}
      v-prop-code = {&attr-cd-type-IBS-TH_ibs-th_interface_screen-layout-id}
      .
    end.
  end.
  for each buf_thbj-attr no-lock where
          buf_thbj-attr.upper-prop-code = v-upper-prop-code
      and buf_thbj-attr.prop-code = v-prop-code:
    if buf_thbj-attr.property-value-character = p-layout-id then do:
      p-mess = substitute("Нельзя удалить раскладку &1 - она используется в параметрах для IBS POS TH &2"
                        , p-layout-id
                        , get-objregion(  input buf_thbj-attr.obj-type
                                         ,input buf_thbj-attr.obj-code)
                        ).
     return.
    end.
  end.
  case p-layout-type:
    when {&th-pos-keyboard} then do:
       assign
       v-upper-prop-code = {&cda-IBS-TH_devices}
       v-prop-code = {&cda-IBS-TH_devices_keyboard-layout-id}
       .
    end.
    when {&th-pos-screen} then do:
      assign
      v-upper-prop-code = {&cda-IBS-TH_interface}
      v-prop-code = {&cda-IBS-TH_interface_screen-layout-id}
      .
    end.
  end.
  for each buf_cash-desk-attr no-lock where
          buf_cash-desk-attr.upper-attr-code = v-upper-prop-code
      and buf_cash-desk-attr.attr-code = v-prop-code:
    if buf_cash-desk-attr.attr-value-character = p-layout-id then do:
      p-mess = substitute("Нельзя удалить раскладку &1 - она используется в параметрах для IBS POS TH &2 касса &3"
                        , p-layout-id
                        , get-objregion(  input {&shop}
                                         ,input buf_cash-desk-attr.obj-code)
                        , buf_Cash-desk-attr.cash-num
                        ).
      return.
    end.
  end.
  p-is-used = no.
end.

end procedure. /* layoutus */


/* $Workfile$ e n d */