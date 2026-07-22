/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/08/06
Author: Bakhtadze Natalya
Creation date: 11/08/06

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }

define temp-table temp-dis-card-type no-undo like ub.dis-card-type.

procedure get-cd-sumid :
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-type as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-host-code as integer no-undo .
define output parameter p-sum-id-value as character no-undo .
define output parameter p-sum-id-output as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-dt-code as integer no-undo .
define variable v-dtm-code as integer no-undo .
define variable v-caller-id as character no-undo .
define variable v-node-code as integer no-undo .
define variable v-node-value-type as character no-undo .
define variable v-value-field-name as character no-undo .
define variable v-storage-place as character no-undo .
define variable v-current-sum-id1 as character no-undo .
define variable v-current-sum-id2 as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ii as integer no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_temp-dis-card-type for temp-dis-card-type.
define buffer buf_dis-card-type for ub.dis-card-type.

do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  find first buf_temp-dis-card-type no-lock where
            buf_temp-dis-card-type.emitent-host-code = p-emitent-host-code
        and buf_temp-dis-card-type.type = p-type
        and buf_temp-dis-card-type.obj-type = p-obj-type
        and buf_temp-dis-card-type.obj-code = p-obj-code no-error .
  if not available buf_temp-dis-card-type then do:
    find first buf_dis-card-type no-lock where
              buf_dis-card-type.emitent-host-code = p-emitent-host-code
          and buf_dis-card-type.type = p-type
          and buf_dis-card-type.obj-type = p-obj-type
          and buf_dis-card-type.obj-code = p-obj-code no-error .
    if not available buf_Dis-card-type then do:
      find first buf_dis-card-type no-lock where
                buf_dis-card-type.emitent-host-code = p-emitent-host-code
            and buf_dis-card-type.type = p-type
            and buf_dis-card-type.host-code = p-host-code no-error .
      if not available buf_Dis-card-type
      and p-emitent-host-code = 0 then do:
        find first buf_dis-card-type no-lock where
                  buf_dis-card-type.emitent-host-code = p-emitent-host-code
              and buf_dis-card-type.type = p-type
              and buf_dis-card-type.host-code = 0 no-error .
      end.
    end.
    if available buf_dis-card-type then do:
      find first buf_temp-dis-card-type where
                  buf_temp-dis-card-type.emitent-host-code = p-emitent-host-code
              and buf_temp-dis-card-type.type = p-type
              and buf_temp-dis-card-type.host-code = 0 no-error .
      if not available buf_temp-dis-card-type then do:
        create buf_temp-dis-card-type.
        buffer-copy buf_dis-card-type to
        buf_temp-dis-card-type.
      end.
    end.
  end. /*if not available buf_temp-dis-card-type then do:*/
  if available buf_temp-dis-card-type then do:
    assign
    v-sum-id-value = buf_temp-dis-card-type.custom-sent
    p-sum-id-output = not (v-sum-id-value = fill({&question-mark}, num-entries(v-sum-id-value)))
    .
  end.
  if p-sum-id-output then do:
    do v-ii = 1 to num-entries(v-sum-id-value):
      assign
      v-value-character = entry(v-ii, v-sum-id-value)
      v-storage-place = entry(1, v-value-character, {&delim-par})
      v-dtm-code = integer(entry(2, v-value-character, {&delim-par}))
      v-sum-id   = entry(3, v-value-character, {&delim-par})
      v-caller-id = entry(4, v-value-character, {&delim-par})
      v-node-code = integer(entry(5, v-value-character, {&delim-par}))
      no-error .
      if error-status:error then do:
        assign
        p-sum-id-value = {&question-mark}
        p-sum-id-output = no
        .
        return.
      end.
      else do:
        run cur-time in this-procedure ( output v-today, output v-time).
        _prop-ref:
        for each buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = v-dtm-code
            and buf_prop-ref.caller_id = v-caller-id,
            first buf_prop-map no-lock where
                  buf_prop-map.dtm-code = v-dtm-code
              and buf_prop-map.node-code = v-node-code
        by buf_prop-ref.dtm-code
        by buf_prop-ref.sum-id:
          assign
          p-sum-id-value = substitute("&2&1&3&1&4&1&5"
                                      , {&delim-par}
                                      ,v-storage-place
                                      ,buf_prop-ref.dt-code
                                      ,v-node-code
                                      ,buf_prop-map.node-name).
          if buf_prop-ref.ref-type = {&sum-id-type-period} then do:
            v-current-sum-id1 = entry(1, buf_prop-ref.sum-id, "-":U) + "-" + dct-algo-Date-to-String(v-today).
            v-current-sum-id2 = dct-algo-Date-to-String(v-today) + "-" + entry(2, buf_prop-ref.sum-id, "-":U).
            if v-current-sum-id1 <= buf_prop-ref.sum-id
            and v-current-sum-id2 >= buf_prop-ref.sum-id
            then do:
              leave _prop-ref.
            end.
          end.
          else do:
            if buf_prop-ref.sum-id = v-sum-id then leave _prop-ref.
          end.
        end. /*for each buf_prop-ref*/
        if not available buf_prop-ref then do:
          assign
          p-sum-id-value = {&question-mark}
          p-sum-id-output = no
          .
        end.
      end. /*else if error-status_error */
    end.  /* do v-ii = 1 to num-entries(v-sum-id-value):*/
  end. /*if p-sum-id-output then do::*/
end. /*doe*/
end procedure. /* get-cd-sumid */


/* $Workfile$ e n d */