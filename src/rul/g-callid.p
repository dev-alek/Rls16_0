block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение значения уникального ключа привязки правила , профайла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/07/07
Author: Bakhtadze Natalya
Creation date: 03/07/07

*/

define input parameter p-call-type as character no-undo .
define input parameter p-call-id as character no-undo .
define output parameter p-call#-id as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Получение значения уникального ключа привязки правила , профайла".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ trg/new-bcod.i }

define variable v-1 as integer no-undo .
define variable v-2 as integer no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_c-rp-by-call for ub.c-rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_c-rule-by-call for ub.c-rule-by-call.
define buffer buf_prop-ref-call for ub.prop-ref-call.
define buffer buf_some-lk for ub.some-lk.

main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  case p-call-type:
    when {&table_dis-card-type}
    or
    when {&edoc}
    or
    when {&table_goods}
    or
    when {&table_clients}
    or
    when {&table_gds-grp}
    or
    when {&table_cli-grp}
    or
    when {&table_chk-doc} + "_" + {&cd-type-ibs-th}
    or
    when {&table_chk-doc} + "_" + {&cd-type-ibs-th-mob}
    or
    when {&edoc}
    or
    when {&thref}
    or
    when {&pdf}
    or
    when {&rep}
    or
    when {&ord}
    or
    when {&cmb}
    or
    when {&fdoc}
    then do:
      find first buf_rp-by-call no-lock where
                buf_rp-by-call.call_id = p-call-id no-error .
      if available buf_rp-by-call then do:
        p-call#-id = buf_rp-by-call.call#_id.
        return.
      end.
      find first buf_c-rp-by-call no-lock where
                buf_c-rp-by-call.call_id = p-call-id no-error.
      if available buf_c-rp-by-call then do:
        p-call#-id = buf_c-rp-by-call.call#_id.
        return.
      end.
      find first buf_rule-by-call no-lock where
                buf_rule-by-call.call_id = p-call-id no-error .
      if available buf_rule-by-call then do:
        p-call#-id = buf_rule-by-call.call#_id.
        return.
      end.
      find first buf_c-rule-by-call no-lock where
                buf_c-rule-by-call.call_id = p-call-id no-error .
      if available buf_c-rule-by-call then do:
        p-call#-id = buf_c-rule-by-call.call#_id.
        return.
      end.
      find first buf_prop-ref-call no-lock where
                buf_prop-ref-call.call_id = p-call-id no-error .
      if available buf_prop-ref-call then do:
        p-call#-id = buf_prop-ref-call.call#_id.
        return.
      end.
      run gen-b-code in this-procedure ( input {&gbl-ca-code}, output p-call#-id) no-error .
      if error-status:error then do:
        message
        vss-workfile vss-revision vss-description skip
        "Невозможно определить уникальный идентификатор точки вызова" p-call-id
        view-as alert-box error .
        undo main-block, return error .

      end.
    end.
    when {&table_layout-elem-rule}
    then do:
      find first buf_rule-by-call no-lock where
                buf_rule-by-call.call_id = p-call-id no-error .
      if available buf_rule-by-call then do:
        p-call#-id = buf_rule-by-call.call#_id.
        return.
      end.
      find first buf_c-rule-by-call no-lock where
                buf_c-rule-by-call.call_id = p-call-id no-error .
      if available buf_c-rule-by-call then do:
        p-call#-id = buf_c-rule-by-call.call#_id.
        return.
      end.
      run gen-b-code in this-procedure ( input {&gbl-ca-code}, output p-call#-id) no-error .
      if error-status:error then do:
        message
        vss-workfile vss-revision vss-description skip
        "Невозможно определить уникальный идентификатор точки вызова" p-call-id
        view-as alert-box error .
        undo main-block, return error .
      end.
     end.
     when ({&table_layout-elem-rule} + {&comma-char} + "minus") then do:
      find first buf_rule-by-call no-lock where
                buf_rule-by-call.call_id = p-call-id
            and buf_rule-by-call.call#_id < 0
                no-error .
      if available buf_rule-by-call then do:
        p-call#-id = buf_rule-by-call.call#_id.
        return.
      end.
      find first buf_c-rule-by-call no-lock where
                buf_c-rule-by-call.call_id = p-call-id
             and buf_c-rule-by-call.call#_id < 0
                no-error .
      if available buf_c-rule-by-call then do:
        p-call#-id = buf_c-rule-by-call.call#_id.
        return.
      end.
      find first buf_rule-by-call no-lock where
                buf_rule-by-call.call#_id  < 0 no-error .
      if available buf_rule-by-call then do:
        v-1 = buf_rule-by-call.call#_id.
      end.
      find first buf_c-rule-by-call no-lock where
                buf_c-rule-by-call.call#_id < 0 no-error .
      if available buf_c-rule-by-call then do:
        v-2 = buf_c-rule-by-call.call#_id.
      end.
      assign
      p-call#-id = minimum(-1, v-1, v-2) - 1
      .
    end.
    when {&table_some-lk} then do:
      find first buf_some-lk no-lock where
                buf_some-lk.resource_id = p-call-id no-error .
      if available buf_some-lk then do:
        p-call#-id = buf_some-lk.resource#_id.
        return.
      end.
      if g#db-num = 0 then do:
        p-call#-id = next-value(s-lk-chip, {&db-name_schema}).
      end.
      else do:
        message
        vss-workfile vss-revision vss-description skip
        "Невозможно определить уникальный идентификатор точки блокировки" p-call-id
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    otherwise do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра вызова p-call-type=" p-call-type
      view-as alert-box error .
      undo main-block, return error .
    end.

  end case.
end. /*doe*/