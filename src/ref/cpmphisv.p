block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cpmphisv.p $
$Archive: ref/cpmphisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/07/05
Author: Bakhtadze Natalya
Creation date: 08/07/05

*/

define input parameter p-obj-type like ub.c-pmp-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-pmp-hist.obj-code no-undo .
define input parameter p-pump-code like ub.c-pmp-hist.pl-code no-undo .
define input parameter p-chip-num like ub.c-pmp-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-pmp-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-pmp-hist.subject no-undo .
define input parameter p-action   like ub.c-pmp-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable  vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable  vss-author      as character no-undo init "$Author: expertek $":U .
define variable  vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable  vss-workfile    as character no-undo init "$Workfile: cpmphisv.p $":U .
define variable  vss-archive     as character no-undo init "$Archive: ref/cpmphisv.p $":U .
define variable  vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории ТРК".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/pumpattr.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-pmp-hist for ub.c-pmp-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action"}


find first buf_c-pmp-hist no-lock where
          buf_c-pmp-hist.obj-type = p-obj-type
      AND buf_c-pmp-hist.obj-code = p-obj-code
      AND buf_c-pmp-hist.pump-code = p-pump-code
      AND buf_c-pmp-hist.chip-num = p-chip-num
      AND buf_c-pmp-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-pmp-hist.subject  = p-subject no-error .
if not available buf_c-pmp-hist then do:
  return error .
end.
CASE p-subject:
  when {&table_pump} then do:
    run pump-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pump-nozzle} then do:
    run pump-nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-gds-pump} then do:
    run pl-gds-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-pump} then do:
    run pl-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-pump-nozzle} then do:
    run pl-pump-nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pump-attr} then do:
    run pump-attr-proc in this-procedure(output p-description) no-error  .
  end.
END CASE.
if error-status:error then do:
  return error .
end.

procedure pump-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pump for ub.c-pump  .


  do
  on error undo, return error
  :
    find first curr_c-pump no-lock where
               curr_c-pump.obj-type = p-obj-type
           AND curr_c-pump.obj-code = p-obj-code
           AND curr_c-pump.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pump.chip-num = p-chip-num
           AND curr_c-pump.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-pump then do:
      v-mess = "Неверная ссылка на c-pump в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "pump-code,obj-code,obj-type,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-pmp-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pump:handle
                                            ,input  {&table_pump}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* pump-proc */




procedure pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pump-nozzle for ub.c-pump-nozzle  .

  do
  on error undo, return error
  :
    find first curr_c-pump-nozzle no-lock where
               curr_c-pump-nozzle.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pump-nozzle.obj-type = p-obj-type
           AND curr_c-pump-nozzle.obj-code = p-obj-code
           AND curr_c-pump-nozzle.nozzle-code = buf_c-pmp-hist.nozzle-code
           AND curr_c-pump-nozzle.chip-num = p-chip-num
           AND curr_c-pump-nozzle.corr-user-db-num = p-corr-user-db-num  no-error .
    if not avail curr_c-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pump-nozzle в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "nozzle-code,pump-code,is-meas,obj-code,obj-type,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "nozzle-code" + {&delim-par} + "№ пистолета" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "is-meas" + {&delim-par} + "Измеряется приборами" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  + {&delim-flf}
 + "ef-nid" + {&delim-par} + "Идентификатор EasyFuel" + {&delim-par} + ""
   .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-pmp-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pump-nozzle:handle
                                            ,input  {&table_pump-nozzle}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).




end.

end procedure. /* pump-nozzle-proc */


procedure pl-gds-pump-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-gds-pump for ub.c-pl-gds-pump  .


  do
  on error undo, return error
  :

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-pmp-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-pmp-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess ).
      return error v-mess .
    end.
    find first curr_c-pl-gds-pump no-lock where
               curr_c-pl-gds-pump.obj-type = buf_c-pmp-hist.obj-type
           AND curr_c-pl-gds-pump.obj-code = buf_c-pmp-hist.obj-code
           AND curr_c-pl-gds-pump.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pl-gds-pump.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pl-gds-pump.corr-user-db-num = buf_c-table-bind.corr-user-db-num no-error .
    if not avail curr_c-pl-gds-pump then do:
      v-mess = "Неверная ссылка на c-pl-gds-pump в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess ).
      return error v-mess .
    end.

&scop fields-name-list  "gds-code,pl-code,pump-code,obj-code,obj-type,PS,status_"


define variable v-label-param as character no-undo .

v-label-param =
  "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-pmp-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pl-gds-pump:handle
                                            ,input  {&table_pl-gds-pump}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* pl-gds-pump-proc */


procedure pl-pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-pump-nozzle for ub.c-pl-pump-nozzle  .

  do
  on error undo, return error
  :
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-pmp-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-pmp-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

    find first curr_c-pl-pump-nozzle no-lock where
               curr_c-pl-pump-nozzle.obj-type = buf_c-pmp-hist.obj-type
           AND curr_c-pl-pump-nozzle.obj-code = buf_c-pmp-hist.obj-code
           AND curr_c-pl-pump-nozzle.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pl-pump-nozzle.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pl-pump-nozzle.corr-user-db-num = buf_c-table-bind.corr-user-db-num   no-error .
    if not avail curr_c-pl-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pl-pump-nozzle в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "nozzle-code,pl-code,pump-code,obj-code,obj-type,PS,status_"


define variable v-label-param as character no-undo .

v-label-param =
  "nozzle-code" + {&delim-par} + "№ пистолета" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-pmp-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pl-pump-nozzle:handle
                                            ,input  {&table_pl-pump-nozzle}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* pl-pump-nozzle-proc */



procedure pl-pump-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-pump for ub.c-pl-pump  .


  do
  on error undo, return error
  :
    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-pmp-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-pmp-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-pl-pump no-lock where
               curr_c-pl-pump.obj-type = buf_c-pmp-hist.obj-type
           AND curr_c-pl-pump.obj-code = buf_c-pmp-hist.obj-code
           AND curr_c-pl-pump.pump-code = buf_c-pmp-hist.pump-code
           AND curr_c-pl-pump.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pl-pump.corr-user-db-num = buf_c-table-bind.corr-user-db-num   no-error .
    if not avail curr_c-pl-pump then do:
      v-mess = "Неверная ссылка на c-pl-pump в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "pl-code,pump-code,obj-code,obj-type,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-pmp-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pl-pump:handle
                                            ,input  {&table_pl-pump}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* pl-pump-proc */

procedure pump-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-pump-attr for ub.c-pump-attr  .


  do
  on error undo, return error
  :
    find first current_c-pump-attr no-lock where
               current_c-pump-attr.chip-num = p-chip-num
           AND current_c-pump-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-pump-attr.obj-type = p-obj-type
           AND current_c-pump-attr.obj-code = p-obj-code
           AND current_c-pump-attr.pump-code = p-pump-code  no-error .
    if not avail current_c-pump-attr then do:
      v-mess = "Неверная ссылка на c-pump-attr в таблице c-pmp-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run pumpattr-tooltip in this-procedure (
                input  current_c-pump-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list  "attr-value,pump-code,obj-code,obj-type,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-pmp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-pmp-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-pump-attr:handle
                                            ,input  {&table_pump-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* pump-attr-proc */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История ТРК &1 на &2&3: щепка &4 БД:&5  Предмет изменений &6&7&8"
                  ,p-pump-code
                  , p-obj-type
                  , p-obj-code
                  , p-chip-num
                  , p-corr-user-db-num
                  , p-subject
                  , {&new-line}
                  , p-mess
                  ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.