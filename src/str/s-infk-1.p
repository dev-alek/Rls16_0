/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Посылка на ИНФОКИОСК справочника групп и шкал по необходимости

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/30/05
Author: Bakhtadze Natalya
Creation date: 08/30/05

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter as character no-undo .
/*
p-parameter включает
def input param p-obj-code like ub.clients.obj-code no-undo.
def input param p-necessary as logical no-undo.
*/
define variable p-obj-code like ub.cash-desk.obj-code no-undo .
define variable p-necessary as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Посылка на ИНФОКИОСК справочника групп и шкал по необходимости".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cd-attr.i }
{ gbl/cur-time.i }
{ cmp/obj-list.i NEW }


define variable v-character as character no-undo .
define variable v-character-new as character no-undo .
define variable v-date as date no-undo .
define variable v-decimal as decimal no-undo .
define variable v-integer as date no-undo .
define variable v-logical as logical no-undo .
define variable v-attr-type as character no-undo .
define variable v-first-time as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-prt for ub.c-gds-prt.
define buffer buf_cash-desk for ub.cash-desk.

assign
p-obj-code = abs(integer(entry(1, p-parameter, {&delim-par})))
p-necessary = (if num-entries(p-parameter, {&delim-par}) > 1
               then logical(entry(2, p-parameter, {&delim-par}))
               else no)
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         )).
  undo, return error .
end .

find first buf_cash-desk no-lock where
          buf_cash-desk.db-num = g#db-num
      AND buf_cash-desk.obj-code = p-obj-code
      AND buf_cash-desk.pos-type = {&cd-type-infokiosk} no-error .
if not available buf_cash-desk then return error substitute("Нет кассы &1 на маг&2"
                                                            , {&cd-type-infokiosk}
                                                            , p-obj-code ).
/*ищем последнее изменение справочника групп в текущей БД*/
find last buf_c-gds-grp-hist where
      buf_c-gds-grp-hist.node-code = 0
  AND buf_c-gds-grp-hist.corr-user-db-num = 0
  AND buf_c-gds-grp-hist.host-code = 0
  AND buf_c-gds-grp-hist.obj-type = '':U
  AND buf_c-gds-grp-hist.obj-code = 0
  AND buf_c-gds-grp-hist.subject = {&table_gds-grp} no-error.

/*для групп проверим а изменение было ?*/
run cd-attr-value in this-procedure (
                                            input g#db-num
                                          ,input p-obj-code
                                          ,input buf_cash-desk.pos-type
                                          ,input buf_cash-desk.cash-num
                                          ,input {&cda-infokiosk_operative}
                                          ,input {&cda-infokiosk_operative_last-grp-change}
                                          ,output v-character
                                          ,output v-date
                                          ,output v-decimal
                                          ,output v-integer
                                          ,output v-logical
                                          ,output v-attr-type     ) no-error.
if error-status:error
or v-character = '':U
or not available buf_c-gds-grp-hist
or integer(entry(3, v-character, {&space-char} )) < buf_c-gds-grp-hist.chip-num then do:
  if not available buf_c-gds-grp-hist
  or v-character = '':U
  then do:
    run cur-time in this-procedure(output v-today, output v-time).
    v-first-time = yes.
  end.
  assign
  v-character-new =  (if available buf_c-gds-grp-hist
                        then
                        (string(buf_c-gds-grp-hist.corr-date, "99/99/9999") + {&space-char} +
                        string(buf_c-gds-grp-hist.corr-time, "hh:mm:ss") + {&space-char} +
                        string(buf_c-gds-grp-hist.chip-num)
                        )
                        else
                        (string(v-today, "99/99/9999") + {&space-char} +
                        string(v-time, "hh:mm:ss") + {&space-char} +
                        string(current-value (s-gds-grp-chip, {&db-name_schema}))
                        )
                        )
  .
  if v-character <> v-character-new then do:
    run cd-attr-write  in this-procedure (
                                            input g#db-num
                                            ,input p-obj-code
                                            ,input buf_cash-desk.pos-type
                                            ,input buf_cash-desk.cash-num
                                            ,input {&cda-infokiosk_operative}
                                            ,input {&cda-infokiosk_operative_last-grp-change}
                                            ,input v-character-new
                                            ,input ? /*p-attr-date*/
                                            ,input 0.0 /*p-attr-decimal*/
                                            ,input 0 /*p-attr-integer*/
                                            ,input no /*p-attr-logical*/
                                          ) no-error.
  end.
end.
if v-character-new = '':U then do:
  assign
  v-character-new = v-character.
end.
if p-necessary = yes
or (available buf_c-gds-grp-hist
and integer(entry(3, v-character-new, {&space-char} )) < buf_c-gds-grp-hist.chip-num)
or v-first-time
or (not available buf_c-gds-grp-hist
    and
    (date(entry(1, v-character-new, {&space-char} )) < v-today
    or
    (date(entry(1, v-character-new, {&space-char} )) = v-today
    and
    integer(entry(2, v-character-new, {&space-char} )) < v-time
    )
    )
  )
then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка групп товаров")) .
  run str/sendgrup.p (
                  input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(p-obj-code) + {&delim-par} + 'A':U + {&delim-par} + 'group-BO')
                  ) no-error .

end.
assign
v-character = '':U
v-character-new = '':U
v-first-time = no
.

/*ищем последнее изменение справочника в текущей БД*/
find last buf_c-gds-prt where
      buf_c-gds-prt.node-code = 0
  AND buf_c-gds-prt.corr-user-db-num = 0   no-error.

/*для групп проверим а изменение было ?*/
run cd-attr-value in this-procedure (
                                            input g#db-num
                                          ,input p-obj-code
                                          ,input buf_cash-desk.pos-type
                                          ,input buf_cash-desk.cash-num
                                          ,input {&cda-infokiosk_operative}
                                          ,input {&cda-infokiosk_operative_last-prt-change}
                                          ,output v-character
                                          ,output v-date
                                          ,output v-decimal
                                          ,output v-integer
                                          ,output v-logical
                                          ,output v-attr-type     ) no-error.
if error-status:error
or v-character = '':U
or not available buf_c-gds-prt
or integer(entry(3, v-character, {&space-char} )) < buf_c-gds-prt.chip-num
then do:
  if not available buf_c-gds-prt
  or v-character = '':U
  then do:
    run cur-time in this-procedure(output v-today, output v-time).
    v-first-time = yes.
  end.
  assign
  v-character-new =  (if available buf_c-gds-prt
                        then
                        (string(buf_c-gds-prt.corr-date, "99/99/9999") + {&space-char} +
                        string(buf_c-gds-prt.corr-time, "hh:mm:ss") + {&space-char} +
                        string(buf_c-gds-prt.chip-num)
                        )
                        else
                        (string(v-today, "99/99/9999") + {&space-char} +
                        string(v-time, "hh:mm:ss") + {&space-char} +
                        string(current-value (s-gds-grp-chip, {&db-name_schema}))
                        )
                      )
  .

  if v-character <> v-character-new then do:
    run cd-attr-write  in this-procedure (
                                            input g#db-num
                                            ,input p-obj-code
                                            ,input buf_cash-desk.pos-type
                                            ,input buf_cash-desk.cash-num
                                            ,input {&cda-infokiosk_operative}
                                            ,input {&cda-infokiosk_operative_last-prt-change}
                                            ,input v-character-new
                                            ,input ? /*p-attr-date*/
                                            ,input 0.0 /*p-attr-decimal*/
                                            ,input 0 /*p-attr-integer*/
                                            ,input no /*p-attr-logical*/

                                          ) no-error.
  end.
end.
if v-character-new = '':U then do:
  assign
  v-character-new = v-character.
end.
if p-necessary = yes
or (available buf_c-gds-prt
and integer(entry(3, v-character-new, {&space-char} )) < buf_c-gds-prt.chip-num)
or v-first-time
or (not available buf_c-gds-prt
    and
    (date(entry(1, v-character-new, {&space-char} )) < v-today
    or
    (date(entry(1, v-character-new, {&space-char} )) = v-today
    and
    integer(entry(2, v-character-new, {&space-char} )) < v-time
    )
    )
  )
then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка шкал")) .

  run str/sendgrup.p (
                  input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(p-obj-code) + {&delim-par} + 'A':U + {&delim-par} + 'gds-prt')
                  ) no-error .
end.


finally :
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
  define variable v-save-file-name as character no-undo .
  v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
  OS-APPEND value(log-file-name) value(v-save-file-name).
  OS-DELETE value(log-file-name).
end finally .
