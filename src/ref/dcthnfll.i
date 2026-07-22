/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение по умолчанию временной таблицы опции истории и маршрутизации для типов ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/04/07
Author: Bakhtadze Natalya
Creation date: 05/04/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


PROCEDURE fill-tt0-hist-nws-option :
define input parameter p-emitent-host-code as integer no-undo .
define input parameter p-type as character no-undo .
define buffer  buf_tt0-hist-nws-option for tt0-hist-nws-option.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-table-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-label0 AS CHARACTER NO-UNDO.
define variable v-region as character no-undo .
DEFINE VARIABLE v-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-done AS CHARACTER NO-UNDO.
define variable v-hn-id as integer no-undo .
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
FOR EACH buf_prop-head NO-LOCK WHERE
    buf_prop-head.general CONTAINS  {&TABLE_dis-card-type}
    and
    buf_prop-head.general-view CONTAINS  {&TABLE_dis-card-type}
ON ERROR UNDO, RETURN ERROR :
    v-label0 = buf_prop-head.prop-label.
    v-done = '':U.
    v-table-name = '':U.
   _v-ii:
   DO v-ii = 1 TO 3:
     IF v-ii = 1 THEN do:
        v-table-name = buf_prop-head.storage-place.
        v-label = substitute("&1_", v-label0).
        v-region = "".
     END.
     IF v-ii = 2 THEN do:
        v-table-name = buf_prop-head.storage-place-host.
        v-label = substitute("&1_Фирма", v-label0).
        v-region = "Фирма".
     END.
     IF v-ii = 3 THEN do:
        v-table-name = buf_prop-head.storage-place-obj.
        v-label = substitute("&1_Объект", v-label0).
        v-region = "Объект".
     END.
     IF v-table-name = '':U
     OR v-table-name = ?
     OR v-table-name = {&question-mark} THEN NEXT _v-ii.
     IF v-table-name > '':U and LOOKUP(v-table-name, v-done) = 0
     THEN do:
       FIND FIRST buf_tt0-hist-nws-option WHERE
                buf_tt0-hist-nws-option.db-num = 0
            AND buf_tt0-hist-nws-option.table-name = v-table-name
            and buf_tt0-hist-nws-option.host-code = p-emitent-host-code
            and buf_tt0-hist-nws-option.obj-type = '':U
            and buf_tt0-hist-nws-option.obj-code = 0
            and buf_tt0-hist-nws-option.key#_one = buf_prop-head.dtm-code
            and buf_tt0-hist-nws-option.charkey_one = p-type no-error.
       if not available buf_tt0-hist-nws-option then do:
         create buf_tt0-hist-nws-option.
         assign
         buf_tt0-hist-nws-option.db-num = 0
         buf_tt0-hist-nws-option.table-name = v-table-name
         buf_tt0-hist-nws-option.host-code = p-emitent-host-code
         buf_tt0-hist-nws-option.obj-type = '':U
         buf_tt0-hist-nws-option.obj-code = 0
         buf_tt0-hist-nws-option.key#_one = buf_prop-head.dtm-code
         buf_tt0-hist-nws-option.charkey_one = p-type
         buf_tt0-hist-nws-option.get-hist-from-nws = buf_prop-head.get-hist-from-nws

         buf_tt0-hist-nws-option.hist-to-nws = buf_prop-head.hist-to-nws
         buf_tt0-hist-nws-option.nws-to-hist = buf_prop-head.nws-to-hist
         buf_tt0-hist-nws-option.hist-from-prim = buf_prop-head.hist-from-prim
         buf_tt0-hist-nws-option.nws-to-cd = buf_prop-head.nws-to-cd
         buf_tt0-hist-nws-option.smart-nws = buf_prop-head.smart-nws
         buf_tt0-hist-nws-option.get-hist-from-nws = buf_prop-head.get-hist-from-nws
         buf_tt0-hist-nws-option.subject-group = {&table_c-dc-hist}
         buf_tt0-hist-nws-option.option-desc = v-label
         buf_tt0-hist-nws-option.hn-id = v-hn-id
         v-hn-id = v-hn-id + 1
         .
      END. /*if not available*/
      else do:
        if entry(num-entries(buf_tt0-hist-nws-option.option-desc, "_")
                  , buf_tt0-hist-nws-option.option-desc
                  , "_") <> v-region
          or v-ii = 1 then do:
          v-label = substitute("&1/&2"
                                , buf_tt0-hist-nws-option.option-desc
                                , (if v-ii = 1
                                    then "_Глобально"
                                    else (if v-ii = 2
                                        then "_Фирма"
                                        else "_Объект"
                                        )
                                  )
                                ).

          assign
          buf_tt0-hist-nws-option.option-desc = v-label
          .
        end.
      end.

      &if "{1}" = "extended" &then
&scop hn-option-val-code        string(buf_tt0-hist-nws-option.smart-nws)
        ASSIGN
        buf_tt0-hist-nws-option.hist-to-nws-is-on = (buf_tt0-hist-nws-option.hist-to-nws >= 0)
        buf_tt0-hist-nws-option.nws-to-hist-is-on = (buf_tt0-hist-nws-option.nws-to-hist >= 0)
        buf_tt0-hist-nws-option.hist-from-prim-is-on = (buf_tt0-hist-nws-option.hist-from-prim >= 0)
        buf_tt0-hist-nws-option.nws-to-cd-is-on = (buf_tt0-hist-nws-option.nws-to-cd >= 0)
        buf_tt0-hist-nws-option.smart-nws-is-on = {&hn-option-val-name}
        buf_tt0-hist-nws-option.get-hist-from-nws-is-on = (buf_tt0-hist-nws-option.get-hist-from-nws >= 0)


        buf_tt0-hist-nws-option.hist-to-nws-can = NOT ((buf_tt0-hist-nws-option.hist-to-nws = INTEGER({&hn-is-on-blocked})) OR
                                                  (buf_tt0-hist-nws-option.hist-to-nws = INTEGER({&hn-is-off-blocked})))
        buf_tt0-hist-nws-option.nws-to-hist-can = NOT ((buf_tt0-hist-nws-option.nws-to-hist = INTEGER({&hn-is-on-blocked})) OR
                                                  (buf_tt0-hist-nws-option.nws-to-hist = INTEGER({&hn-is-off-blocked})))
        buf_tt0-hist-nws-option.hist-from-prim-can = NOT ((buf_tt0-hist-nws-option.hist-from-prim = INTEGER({&hn-is-on-blocked})) OR
                                                                (buf_tt0-hist-nws-option.hist-from-prim = INTEGER({&hn-is-off-blocked})))
        buf_tt0-hist-nws-option.nws-to-cd-can = NOT ((buf_tt0-hist-nws-option.nws-to-cd = INTEGER({&hn-is-on-blocked})) OR
                                                      (buf_tt0-hist-nws-option.nws-to-cd = INTEGER({&hn-is-off-blocked})))
        buf_tt0-hist-nws-option.smart-nws-can = NOT ((buf_tt0-hist-nws-option.smart-nws = INTEGER({&hn-is-on-blocked})) OR
                                                          (buf_tt0-hist-nws-option.smart-nws = INTEGER({&hn-is-off-blocked})))
        buf_tt0-hist-nws-option.get-hist-from-nws-can = NOT ((buf_tt0-hist-nws-option.get-hist-from-nws = INTEGER({&hn-is-on-blocked})) OR
                                                        (buf_tt0-hist-nws-option.get-hist-from-nws = INTEGER({&hn-is-off-blocked})))
        .
        &scop hn-option-val-code        {&hn-is-off}
        if buf_tt0-hist-nws-option.smart-nws = integer({&hn-is-off-blocked}) then do:
          buf_tt0-hist-nws-option.smart-nws-is-on = {&hn-option-val-name}.
        end.
        &scop hn-option-val-code        {&hn-is-on}
        if buf_tt0-hist-nws-option.smart-nws = integer({&hn-is-on-blocked}) then do:
          buf_tt0-hist-nws-option.smart-nws-is-on = {&hn-option-val-name}.
        end.

      &Endif
    end.
    IF v-table-name > '':U and LOOKUP(v-table-name, v-done) > 0
    THEN do:
       FIND FIRST buf_tt0-hist-nws-option WHERE
                buf_tt0-hist-nws-option.db-num = 0
            AND buf_tt0-hist-nws-option.table-name = v-table-name
            and buf_tt0-hist-nws-option.host-code = p-emitent-host-code
            and buf_tt0-hist-nws-option.obj-type = '':U
            and buf_tt0-hist-nws-option.obj-code = 0
            and buf_tt0-hist-nws-option.key#_one = buf_prop-head.dtm-code
            and buf_tt0-hist-nws-option.charkey_one = p-type no-error.
       if available buf_tt0-hist-nws-option then do:
        if entry(num-entries(buf_tt0-hist-nws-option.option-desc, "_")
                , buf_tt0-hist-nws-option.option-desc
                , "_") <> v-region
        or v-ii = 1 then do:

          v-label = substitute("&1/&2"
                                , buf_tt0-hist-nws-option.option-desc
                                , (if v-ii = 1
                                    then "_Глобально"
                                    else (if v-ii = 2
                                        then "_Фирма"
                                        else "_Объект"
                                        )
                                  )
                                ).

          assign
          buf_tt0-hist-nws-option.option-desc = v-label
          .
        end.
      end.
    end.
    v-done = v-done + {&comma-char} + v-table-name.
  END. /*v-ii*/
END. /*FOR EACH buf_prop-ref NO-LOCK*/
END PROCEDURE.