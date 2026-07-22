/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры работы с ракскладками при запуске кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/23/08
Author: Bakhtadze Natalya
Creation date: 10/23/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def-tt" &then

define {2} temp-table temp-layout-elem-rule no-undo like ub.layout-elem-rule.
define {2} temp-table temp-rule-call-param no-undo like ub.rule-call-param
field layout-type as character
field device-type as character
field mode-id as character
field widget-id as character
index pi is unique primary
layout-type
device-type
mode-id
widget-id
param-name
p-index
.

&endif

&if "{2}" = "def-proc" &then

procedure prep-lay_get-layout :
define input parameter p-layout-type as character no-undo .
define input parameter p-device-type as character no-undo .
define input parameter p-layout-id as character no-undo .

define buffer buf_layout for ub.layout.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-layout-elem-rule for temp-layout-elem-rule.
define buffer buf_temp-rule-call-param for temp-rule-call-param .

main-block:
do
on error undo, return error
:
  for each buf_temp-layout-elem-rule where buf_temp-layout-elem-rule.layout-id = p-layout-id:
    for each buf_temp-rule-call-param where
            buf_temp-rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
    :
      delete buf_temp-rule-call-param.
    end.

    delete buf_temp-layout-elem-rule.
  end.
  find first buf_layout share-lock where
            buf_layout.layout-id = p-layout-id no-error.
  if not available buf_layout
  or buf_layout.sts <> integer({&current-status-int}) then do:
    find first buf_layout share-lock where
            buf_layout.layout-type = p-layout-type
        and buf_layout.device-type = p-device-type
        and buf_layout.is-default = integer({&layout-default}) no-error .
    if not available buf_layout then do:
      undo, return error substitute("Не найдено ни один подходящей раскладки типа &1 для &2"
                                  ,p-layout-type
                                  ,p-device-type).
    end.
  end.
  for each buf_layout-elem-rule no-lock where
          buf_layout-elem-rule.layout-id = buf_layout.layout-id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    create buf_temp-layout-elem-rule.
    buffer-copy buf_layout-elem-rule to buf_temp-layout-elem-rule.
    for each buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
        create buf_temp-rule-call-param.
        buffer-copy buf_rule-call-param to buf_temp-rule-call-param
        assign
        buf_temp-rule-call-param.layout-type = buf_layout.layout-type
        buf_temp-rule-call-param.device-type = buf_layout.device-type
        buf_temp-rule-call-param.mode-id = buf_layout-elem-rule.mode-id
        buf_temp-rule-call-param.widget-id = buf_layout-elem-rule.widget-id
        .
    end.
  end. /*    for each buf_layout-elem-rule no-lock where*/
end. /*doe*/

end procedure. /* prep-lay_get-layout */

&endif

/* $Workfile$ e n d */