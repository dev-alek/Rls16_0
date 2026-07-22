block-level on error undo, throw.
/*

$Revision: 63f60a8c7447, 2876, rls $
$Author: SSlivenko $
$Date: Пн ноя 22 19:49:10 2021 +0300 $
$Workfile: cplchisv.p $
$Archive: ref/cplchisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории скл места

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/07/05
Author: Bakhtadze Natalya
Creation date: 08/07/05

*/

define input parameter p-obj-type like ub.c-plc-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-plc-hist.obj-code no-undo .
define input parameter p-pl-code like ub.c-plc-hist.pl-code no-undo .
define input parameter p-chip-num like ub.c-plc-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-plc-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-plc-hist.subject no-undo .
define input parameter p-action   like ub.c-plc-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 63f60a8c7447, 2876, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cplchisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cplchisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории скл места".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ gbl/placattr.i }
{ gbl/plgdattr.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-plc-hist for ub.c-plc-hist.
&Glob VisibleKeyField yes
{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-plc-hist no-lock where
          buf_c-plc-hist.obj-type = p-obj-type
      AND buf_c-plc-hist.obj-code = p-obj-code
      AND buf_c-plc-hist.pl-code = p-pl-code
      AND buf_c-plc-hist.chip-num = p-chip-num
      AND buf_c-plc-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-plc-hist.subject  = p-subject no-error .
if not available buf_c-plc-hist then do:
  return error .
end.
CASE p-subject:
  when {&table_place} then do:
    run place-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-gds} then do:
    run pl-gds-proc in this-procedure(output p-description) no-error  .
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
  when {&table_place-attr} then do:
    run place-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-gds-attr} then do:
    run pl-gds-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-level} then do:
    run pl-level-proc in this-procedure(output p-description) no-error  .
  end.

END CASE.
if error-status:error then do:
  return error substitute("&1 &2", error-status:get-message(1), return-value ) .
end.

procedure place-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-place for ub.c-place  .

  do
  on error undo, return error
  :
    find first curr_c-place no-lock where
               curr_c-place.obj-type = p-obj-type
           AND curr_c-place.obj-code = p-obj-code
           AND curr_c-place.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-place.chip-num = p-chip-num
           AND curr_c-place.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-place then do:
      v-mess = "Неверная ссылка на c-place в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
&scop fields-name-list  "add-qnty,is-meas,loc1,loc2,loc3,loc4,max-qnty,pl-name,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "add-qnty" + {&delim-par} + "Дополнительное количество" + {&delim-par} + "" + {&delim-flf}
 + "is-meas" + {&delim-par} + "Измеряется приборами" + {&delim-par} + "" + {&delim-flf}
 + "loc1" + {&delim-par} + "Коорд1" + {&delim-par} + "" + {&delim-flf}
 + "loc2" + {&delim-par} + "Коорд2" + {&delim-par} + "" + {&delim-flf}
 + "loc3" + {&delim-par} + "Коорд3" + {&delim-par} + "" + {&delim-flf}
 + "loc4" + {&delim-par} + "Коорд4" + {&delim-par} + "" + {&delim-flf}
 + "max-qnty" + {&delim-par} + "Максимальное количество" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объектаТип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "pl-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer curr_c-place:handle
                                            ,input  {&table_place}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* place-proc */




procedure pl-gds-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-gds for ub.c-pl-gds  .

  do
  on error undo, return error
  :
    find first curr_c-pl-gds no-lock where
               curr_c-pl-gds.gds-code = buf_c-plc-hist.gds-code
           AND curr_c-pl-gds.obj-type = p-obj-type
           AND curr_c-pl-gds.obj-code = p-obj-code
           AND curr_c-pl-gds.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-gds.chip-num = p-chip-num
           AND curr_c-pl-gds.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-pl-gds then do:
      v-mess = "Неверная ссылка на c-pl-gds в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "tolerance,max-qnty,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "tolerance" + {&delim-par} + "Допустимое отклонение" + {&delim-par} + "" + {&delim-flf}
 + "max-qnty" + {&delim-par} + "Максимальное количество" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer curr_c-pl-gds:handle
                                            ,input  {&table_pl-gds}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).




end.

end procedure. /* pl-gds-proc */


procedure pl-gds-pump-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-gds-pump for ub.c-pl-gds-pump  .


  do
  on error undo, return error
  :
    find first curr_c-pl-gds-pump no-lock where
               curr_c-pl-gds-pump.gds-code = buf_c-plc-hist.gds-code
           AND curr_c-pl-gds-pump.obj-type = p-obj-type
           AND curr_c-pl-gds-pump.obj-code = p-obj-code
           AND curr_c-pl-gds-pump.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-gds-pump.pump-code = buf_c-plc-hist.pump-code
           AND curr_c-pl-gds-pump.chip-num = p-chip-num
           AND curr_c-pl-gds-pump.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-pl-gds-pump then do:
      v-mess = "Неверная ссылка на c-pl-gds-pump в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
&scop fields-name-list  "pump-code,gds-code,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer curr_c-pl-gds-pump:handle
                                            ,input  {&table_pl-gds-pump}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* pl-gds-pump-proc */


procedure pl-pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-pump-nozzle for ub.c-pl-pump-nozzle  .

  do
  on error undo, return error
  :
    find first curr_c-pl-pump-nozzle no-lock where
               curr_c-pl-pump-nozzle.nozzle-code = buf_c-plc-hist.nozzle-code
           AND curr_c-pl-pump-nozzle.obj-type = p-obj-type
           AND curr_c-pl-pump-nozzle.obj-code = p-obj-code
           AND curr_c-pl-pump-nozzle.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-pump-nozzle.pump-code = buf_c-plc-hist.pump-code
           AND curr_c-pl-pump-nozzle.chip-num = p-chip-num
           AND curr_c-pl-pump-nozzle.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-pl-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pl-pump-nozzle в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

define variable v-label-param as character no-undo .

v-label-param =
  "nozzle-code" + {&delim-par} + "№ пистолета" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer curr_c-pl-pump-nozzle:handle
                                            ,input  {&table_pl-pump-nozzle}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* pl-pump-nozzle-proc */



procedure pl-pump-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-pump for ub.c-pl-pump  .

  do
  on error undo, return error
  :
    find first curr_c-pl-pump no-lock where
               curr_c-pl-pump.obj-type = p-obj-type
           AND curr_c-pl-pump.obj-code = p-obj-code
           AND curr_c-pl-pump.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-pump.pump-code = buf_c-plc-hist.pump-code
           AND curr_c-pl-pump.chip-num = p-chip-num
           AND curr_c-pl-pump.corr-user-db-num = p-corr-user-db-num  no-error .
    if not avail curr_c-pl-pump then do:
      v-mess = "Неверная ссылка на c-pl-pump в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "pump-code,obj-code,obj-type,pl-code,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "pump-code" + {&delim-par} + "№ ТРК" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer curr_c-pl-pump:handle
                                            ,input  {&table_pl-pump}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* pl-pump-proc */

function  getPlaceAttrCode returns character (istr as char ):
   define variable OStr as character no-undo.
   if istr eq "disable-level-alarm"
   then
      OStr = "Сообщения о переполнении".
   else if istr eq "disable-water-alarm"
   then
      OStr = "Сообщения по воде".
   else if istr eq "place-need-RVD-rvs"
   then
      OStr = "Необходимо сделать сверку с РВД".
   else if istr eq "place-SI-level"
   then
      OStr = "Доп. средство измерения уровня".  
   else if istr eq "place-SI-dens"
   then
      OStr = "Доп. средство измерения плотности".
   else if istr eq "place-SI-temp"
   then
      OStr = "Доп. средство измерения температуры". 
   else if istr eq "place-SI"
   then
      OStr = "Основное средство измерения".
   else
      OStr = istr.
   return OStr.
end.

function  getPlaceAttrValue returns character (istr as char ):
   define variable OStr as character no-undo.
   define variable vFlag as logical no-undo.
   if    entry(1,istr,{&delim-par}) eq "enable"
   then
      assign
         OStr = "Включено"
         vFlag = yes
      .
   else if    entry(1,istr,{&delim-par}) eq "disable"
   then
      assign
         OStr  = "Выключено"
         vFlag = yes
      .
   else
      OStr = istr.
   if     vFlag
      and num-entries (istr,{&delim-par}) > 2
   then
      OStr = OStr + " для смены № " + entry(3,istr,{&delim-par}) + " Дата " + entry(2,istr,{&delim-par}).
   return OStr.
end.

function getSIname returns character (si-code as char) :
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = integer(si-code) :
    return sr-izmerenia.sr-model .
  end .
end .

procedure place-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-place-attr for ub.c-place-attr  .


  do
  on error undo, return error
  :
    find first current_c-place-attr no-lock where
               current_c-place-attr.chip-num = p-chip-num
           AND current_c-place-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-place-attr.obj-type = p-obj-type
           AND current_c-place-attr.obj-code = p-obj-code
           AND current_c-place-attr.pl-code = p-pl-code  no-error .
    if not avail current_c-place-attr then do:
      v-mess = "Неверная ссылка на c-place-attr в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run placattr-tooltip in this-procedure (
                input  current_c-place-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .

&scop fields-name-list  "attr-code,attr-value,PS,status_"

define variable v-label-param as character no-undo .

if current_c-place-attr.attr-code = "place-SI"
or current_c-place-attr.attr-code = "place-SI-temp"
or current_c-place-attr.attr-code = "place-SI-dens"
or current_c-place-attr.attr-code = "place-SI-level"
then do :
  v-label-param =
    "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "getSIname" + {&delim-flf}
   + "attr-code" + {&delim-par} + "Код атрибута" + {&delim-par} + "getPlaceAttrCode"   .
end .
else do :
  v-label-param =
    "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "getPlaceAttrValue" + {&delim-flf}
   + "attr-code" + {&delim-par} + "Код атрибута" + {&delim-par} + "getPlaceAttrCode" + {&delim-flf}
   + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
   + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
end . 
 
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-place-attr:handle
                                            ,input  {&table_place-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* place-attr-proc */


procedure pl-gds-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-pl-gds-attr for ub.c-pl-gds-attr  .


  do
  on error undo, return error
  :
    find first current_c-pl-gds-attr no-lock where
               current_c-pl-gds-attr.gds-code = buf_c-plc-hist.gds-code
           AND current_c-pl-gds-attr.chip-num = p-chip-num
           AND current_c-pl-gds-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-pl-gds-attr.obj-type = p-obj-type
           AND current_c-pl-gds-attr.obj-code = p-obj-code
           AND current_c-pl-gds-attr.pl-code = p-pl-code  no-error .
    if not avail current_c-pl-gds-attr then do:
      v-mess = "Неверная ссылка на c-pl-gds-attr в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run plgdattr-tooltip in this-procedure (
                input  current_c-pl-gds-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list  "attr-code,attr-value,gds-code,PS,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + "" + {&delim-flf}
  + "attr-code" + {&delim-par} + "Код атрибута" + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-pl-gds-attr:handle
                                            ,input  {&table_pl-gds-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).




end.

end procedure. /* pl-gds-attr-proc */

procedure pl-level-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-level for ub.c-pl-level  .

  do
  on error undo, return error
  :
    find first curr_c-pl-level no-lock where
               curr_c-pl-level.obj-type = p-obj-type
           AND curr_c-pl-level.obj-code = p-obj-code
           AND curr_c-pl-level.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-level.chip-num = p-chip-num
           AND curr_c-pl-level.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-pl-level then do:
      v-mess = "Неверная ссылка на c-pl-level в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list  "pl-level,pl-qnty"

define variable v-label-param as character no-undo .

v-label-param =
   "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код складского места" + {&delim-par} + "" + {&delim-flf}
 + "pl-level" + {&delim-par} + "Уровень в см" + {&delim-par} + "" + {&delim-flf}
 + "pl-qnty" + {&delim-par} + "Объем в л" + {&delim-par} + "".
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer({&hn-create})
                                            ,input buf_c-plc-hist.action = integer({&hn-delete})
                                            ,input  buffer curr_c-pl-level:handle
                                            ,input  {&table_pl-level}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* pl-level-proc */



PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История складского места &1 на &2&3: щепка &4 БД:&5  Предмет изменений &6&7&8"
                  ,p-pl-code
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