block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись point-io

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/09
Author: Bakhtadze Natalya
Creation date: 09/29/09

*/

TRIGGER PROCEDURE FOR WRITE OF ub.point-point-rel old oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись point-point-rel".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'~
                             , ub.point-point-rel.from-db-num ~
                             , ub.point-point-rel.from-point-code ~
                             , ub.point-point-rel.to-db-num ~
                             , ub.point-point-rel.to-point-code ~
                             , ub.point-point-rel.deliv-type-code ~
                             , ub.point-point-rel.cond-keep-code ~
                              ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-sys-time as character no-undo .
define buffer buf_c-point-point-rel for ub.c-point-point-rel .

main-block:
do on error undo main-block, return error return-value :

  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-point-point-rel .
  BUFFER-COPY oldb  except
  from-point-code from-db-num
  to-point-code to-db-num
  deliv-type-code
  TO buf_c-point-point-rel
  assign
  buf_c-point-point-rel.from-point-code = ub.point-point-rel.from-point-code
  buf_c-point-point-rel.from-db-num = ub.point-point-rel.from-db-num
  buf_c-point-point-rel.to-point-code = ub.point-point-rel.to-point-code
  buf_c-point-point-rel.to-db-num = ub.point-point-rel.to-db-num
  buf_c-point-point-rel.deliv-type-code = ub.point-point-rel.deliv-type-code
  buf_c-point-point-rel.cond-keep-code = ub.point-point-rel.cond-keep-code
  buf_c-point-point-rel.chip-num  = next-value (s-chip-point-io, {&db-name_schema}) .
  { gbl/curdburt.i
   buf_c-point-point-rel.corr-user-db-num
   buf_c-point-point-rel.corr-user-name
   buf_c-point-point-rel.corr-date
   v-sys-time
   buf_c-point-point-rel.corr-time  }

  run str/callnews.p ( input {&table_point-point-rel}
                     , input (buffer ub.point-point-rel:handle) ) .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_point-point-rel}
        , input ( buffer ub.point-point-rel:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.