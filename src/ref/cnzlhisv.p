block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cnzlhisv.p $
$Archive: ref/cnzlhisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории пистолета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/07/05
Author: Bakhtadze Natalya
Creation date: 08/07/05

*/

define input parameter p-obj-type like ub.c-nzl-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-nzl-hist.obj-code no-undo .
define input parameter p-nozzle-code like ub.c-nzl-hist.nozzle-code no-undo .
define input parameter p-chip-num like ub.c-nzl-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-nzl-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-nzl-hist.subject no-undo .
define input parameter p-action   like ub.c-nzl-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cnzlhisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cnzlhisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории пистолета".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/nzzlattr.i }


define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-nzl-hist for ub.c-nzl-hist.
define stream LogStream.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-nzl-hist no-lock where
          buf_c-nzl-hist.obj-type = p-obj-type
      AND buf_c-nzl-hist.obj-code = p-obj-code
      AND buf_c-nzl-hist.nozzle-code = p-nozzle-code
      AND buf_c-nzl-hist.chip-num = p-chip-num
      AND buf_c-nzl-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-nzl-hist.subject  = p-subject no-error .
if not available buf_c-nzl-hist then do:
  return error .
end.
CASE p-subject:
  when {&table_nozzle} then do:
    run nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pump-nozzle} then do:
    run pump-nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-pump-nozzle} then do:
    run pl-pump-nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_nozzle-attr} then do:
    run nozzle-attr-proc in this-procedure(output p-description) no-error  .
  end.
END CASE.
if error-status:error then do:
  return error .
end.

procedure nozzle-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-nozzle for ub.c-nozzle  .


  do
  on error undo, return error
  :
    find first curr_c-nozzle no-lock where
               curr_c-nozzle.obj-type = p-obj-type
           AND curr_c-nozzle.obj-code = p-obj-code
           AND curr_c-nozzle.nozzle-code = buf_c-nzl-hist.nozzle-code
           AND curr_c-nozzle.chip-num = p-chip-num
           AND curr_c-nozzle.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-nozzle then do:
      v-mess = "Неверная ссылка на c-nozzle в таблице c-nzl-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list "nozzle-code,obj-code,obj-type,PS,status_"
define variable v-label-param as character no-undo .

v-label-param =
  "nozzle-code" + {&delim-par} + "№ пистолета" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input (buf_c-nzl-hist.action = integer({&hn-create}))
                                            ,input (buf_c-nzl-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-nozzle:handle
                                            ,input  {&table_nozzle}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* nozzle-proc */



procedure pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pump-nozzle for ub.c-pump-nozzle  .


  do
  on error undo, return error
  :

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-nzl-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-nzl-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-nzl-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-nzl-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

    find first curr_c-pump-nozzle no-lock where
               curr_c-pump-nozzle.obj-type = buf_c-nzl-hist.obj-type
           AND curr_c-pump-nozzle.obj-code = buf_c-nzl-hist.obj-code
           AND curr_c-pump-nozzle.nozzle-code = buf_c-nzl-hist.nozzle-code
           AND curr_c-pump-nozzle.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pump-nozzle.corr-user-db-num = buf_c-table-bind.corr-user-db-num no-error .
    if not avail curr_c-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pump-nozzle в таблице c-nzl-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error.
    end.
&scop fields-name-list "nozzle-code,obj-code,obj-type,PS,status_,is-meas,pump-code"
define variable v-label-param as character no-undo .

v-label-param =
  "nozzle-code" + {&delim-par} + "№ пистолета" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "is-meas" + {&delim-par} + "Измеряется приборами" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + ""  + {&delim-flf}
 + "ef-nid" + {&delim-par} + "Идентификатор EasyFuel" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input (buf_c-nzl-hist.action = integer({&hn-create}))
                                            ,input (buf_c-nzl-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pump-nozzle:handle
                                            ,input  {&table_pump-nozzle}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.

end procedure. /* pump-nozzle-proc */


procedure pl-pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-pump-nozzle for ub.c-pl-pump-nozzle  .


  do
  on error undo, return error
  :

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-nzl-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-nzl-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-nzl-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-nzl-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-pl-pump-nozzle no-lock where
               curr_c-pl-pump-nozzle.nozzle-code = buf_c-nzl-hist.nozzle-code
           AND curr_c-pl-pump-nozzle.obj-type = buf_c-nzl-hist.obj-type
           AND curr_c-pl-pump-nozzle.obj-code = buf_c-nzl-hist.obj-code
           AND curr_c-pl-pump-nozzle.chip-num = buf_c-table-bind.chip-num-src
           AND curr_c-pl-pump-nozzle.corr-user-db-num = buf_c-table-bind.corr-user-db-num  no-error .
    if not avail curr_c-pl-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pl-pump-nozzle в таблице c-nzl-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess .
    end.

&scop fields-name-list "nozzle-code,obj-code,obj-type,PS,status_,is-meas,pump-code,pl-code"

define variable v-label-param as character no-undo .

v-label-param =
  "nozzle-code" + {&delim-par} + "№ пистолета" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "is-meas" + {&delim-par} + "Измеряется приборами" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input (buf_c-nzl-hist.action = integer({&hn-create}))
                                            ,input (buf_c-nzl-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pl-pump-nozzle:handle
                                            ,input  {&table_pl-pump-nozzle}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* pl-pump-nozzle-proc */

procedure nozzle-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-nozzle-attr for ub.c-nozzle-attr  .


  do
  on error undo, return error
  :
    find first current_c-nozzle-attr no-lock where
               current_c-nozzle-attr.chip-num = p-chip-num
           AND current_c-nozzle-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-nozzle-attr.obj-type = p-obj-type
           AND current_c-nozzle-attr.obj-code = p-obj-code
           AND current_c-nozzle-attr.nozzle-code = p-nozzle-code  no-error .
    if not avail current_c-nozzle-attr then do:
      v-mess = "Неверная ссылка на c-nozzle-attr в таблице c-nzl-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run nzzlattr-tooltip in this-procedure (
                input  current_c-nozzle-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list "nozzle-code,obj-code,obj-type,attr-value"

define variable v-label-param as character no-undo .

v-label-param =
  "nozzle-code" + {&delim-par} + "№ пистолета" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input (buf_c-nzl-hist.action = integer({&hn-create}))
                                            ,input (buf_c-nzl-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-nozzle-attr:handle
                                            ,input  {&table_nozzle-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* nozzle-attr-proc */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История пистолета &1 на &2&3: щепка &4 БД:&5  Предмет изменений &6&7&8"
                  ,p-nozzle-code
                  ,p-obj-type
                  ,p-obj-code
                  ,p-chip-num
                  ,p-corr-user-db-num
                  ,p-subject
                  ,{&new-line}
                  ,p-mess
                  ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.