block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение сезона

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 08/19/04 11:22

*/
TRIGGER PROCEDURE FOR WRITE OF ub.season.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение сезона".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.season.sea-code, ub.season.db-num , ub.season.sea-name) "}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ ref/chgdssea.i }
main-block :
do transaction
on error undo main-block, return error
:
define buffer buf_c-season for ub.c-season.
define buffer buf_season-attr for ub.season-attr.
define buffer buf_gds-season for ub.gds-season.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-ok as logical no-undo.
define variable v-seaobj as character no-undo.
define variable v-sea-code as integer no-undo.
define variable v-db-num as integer no-undo.

  run cur-time in this-procedure(output v-date, output v-time).

  create buf_c-season.
  buffer-copy ub.season to buf_c-season
  assign
    buf_c-season.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-season.corr-time          = v-time
    buf_c-season.corr-user-db-num   = g#db-num
    buf_c-season.corr-user-name     = g#userid
    buf_c-season.corr-date          = v-date
  .
  if not g#news  or  ( g#news and g#db-num = 0 ) then do:
    run str/callnews.p
      (input "season"
      ,input (buffer ub.season:handle)
      ) no-error .
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при передаче в новости Сезона" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
            return error.
        end.
  end.
  
  if g#news then do: /* пришел по новостям, проверим не возникли ли пересечения с сезонами измененными на бд приемнике*/
    find first buf_season-attr no-lock where buf_season-attr.sea-code = ub.season.sea-code 
      and buf_season-attr.db-num = ub.season.db-num
      and buf_season-attr.attr-code = {&seaattr-obj} no-error.
    if available buf_season-attr then
          assign
            v-seaobj = buf_season-attr.attr-value
            .
    _foreach-gds-season:
    for each buf_gds-season no-lock where buf_gds-season.sea-code = ub.season.sea-code
      and buf_gds-season.db-num = ub.season.db-num:
      run chk-gdssea in this-procedure 
        ( input buf_gds-season.gds-code,
          input v-seaobj,
          input ub.season.sea-month-1,
          input ub.season.sea-month-2,
          input rowid (ub.season),
          output v-sea-code,
          output v-db-num,
          output v-ok) no-error.
      if not v-ok then do:
        assign
          ub.season.des = "пересечение"
          .
        leave _foreach-gds-season.
      end.
    end.
  end.
  
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_season}
        , input ( buffer ub.season:handle )
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