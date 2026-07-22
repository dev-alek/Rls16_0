block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись весов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.scales OLD o-scales.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись весов".
{ cmp/vssrevis.i "substitute('&1|&2', ub.scales.db-num,ub.scales.scales-num) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-cmp as logical no-undo .
define buffer buf_c-scales for ub.c-scales.
define buffer slave_scales for ub.scales.
define buffer m-scales for ub.scales.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:





  if not g#news
  and g#db-num <> scales.db-num then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя изменять запись ВЕСОВ в чужой БД" skip
    view-as alert-box error .
    undo main-block, return error .
  end.

  if not g#news then do:
    if ub.scales.scales-num = 0 then do:
      undo main-block, return error.
    end.

    IF ub.scales.master = 0 then do:
        if ub.scales.scales-name = "" then do:
                undo main-block, return error .
        end.
        if ub.scales.address = "" then do:
                undo main-block, return error.
        end.
        if ub.scales.unit-base = "" then do:
                undo main-block, return error.
        end.
        if NOT can-find( first ub.units where ub.units.unit-name = ub.scales.unit-base ) then do:
                undo main-block, return error.
        end.
        if ub.scales.max-gds = 0 then do:
                undo main-block, return error.
        end.

        /*уже есть с таким номером*/
        if can-find (m-scales where
                        m-scales.scales-num = ub.scales.scales-num
                        and recid(scales) <> recid(m-scales)
                        and m-scales.db-num = ub.scales.db-num
                        )
          then do:
          undo main-block, return error.
        end.
        /*уменьшение номенлатуры невозможно*/
        if  ub.scales.max-gds < o-scales.max-gds  AND
            can-find( FIRST ub.scales-gds WHERE
                            ub.scales-gds.scales-num = ub.scales.scales-num
                        and ub.scales-gds.db-num = ub.scales.db-num)
            then do:
                undo main-block, return error.
        end.
        FOR EACH slave_scales where
              slave_scales.master = ub.scales.scales-num
          and slave_scales.db-num = ub.scales.db-num
        on error undo, return error:
          BUFFER-COPY ub.scales
          EXCEPT scales-num master address scales-name
          to slave_scales
          .
        END.
    end. /*if master = 0*/
    else do:
    /*Не найдены главные весы, подчиненными которым будут данные весы*/
        FIND FIRST m-scales where
                m-scales.scales-num = ub.scales.master
            and m-scales.db-num  = ub.scales.db-num No-ERROR.
        if not avail m-scales then do:
            undo main-block, return error.
        end.
        /*Весы не могут быть главными сами для себя!*/
        if ub.scales.master = ub.scales.scales-num then do:
          undo main-block, return error.
        end.
        /*Главные весы имеют отличный от данных весов ТИП или
        НОМЕНКЛАТУРУ или ЕДИНИЦУ ИЗМЕРЕНИЯ*/
        if m-scales.scales-type <> ub.scales.scales-type OR
          m-scales.max-gds <> ub.scales.max-gds OR
          m-scales.unit-base <> ub.scales.unit-base then do:
            undo main-block, return error.
        end.
        /*Главные-весы сами по себе являются подчиненными для других весов*/
        if m-scales.master > 0 then do:
            undo main-block, return error.
        end.
    end.
  end.
  if not g#news then do:
    if not new(ub.scales) then do:
      buffer-compare ub.scales
      except to-send
      to o-scales save result in v-cmp.
    end.
      if not v-cmp then do:
    run str/callnews.p
      (input {&table_scales}
      ,input (buffer ub.scales:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block,  return error return-value .
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-scales.
    buffer-copy o-scales to buf_c-scales
    assign
    buf_c-scales.scales-num         = ub.scales.scales-num
    buf_c-scales.db-num             = ub.scales.db-num
    buf_c-scales.chip-num           = next-value (s-scales-chip, {&db-name_schema})
    buf_c-scales.corr-time          = v-time
    buf_c-scales.corr-user-db-num   = g#db-num
    buf_c-scales.corr-user-name     = g#userid
    buf_c-scales.corr-date          = v-date
    buf_c-scales.subject            = {&table_scales}
    buf_c-scales.action             = integer(if new(ub.scales) then {&hn-create} else {&hn-update})
    buf_c-scales.attr-code          = "":U
    .
  end.
    end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_scales}
        , input ( buffer ub.scales:handle )
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