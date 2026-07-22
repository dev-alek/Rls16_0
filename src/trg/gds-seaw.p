block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение товара по сезону

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 08/19/04 11:22

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-season.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение товара по сезону".

{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.gds-season.sea-code, ub.gds-season.db-num, ub.gds-season.gds-code) "}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ok as logical no-undo.
define variable v-seaobj as character no-undo.
define variable v-sea-code as integer no-undo.
define variable v-db-num as integer no-undo.
define buffer buf_c-gds-season for ub.c-gds-season.
define buffer buf_c-gds-hist     for ub.c-gds-hist.
define buffer buf_season for ub.season.
define buffer buf_season-attr for ub.season-attr.

main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_gds-season}
    0
    '':U
    0
    '':U
    '':U
    '':U
    0
    0
    0
    {&nws-to-hist}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).

    create buf_c-gds-season.
    buffer-copy ub.gds-season to buf_c-gds-season
    assign
      buf_c-gds-season.chip-num           = next-value (s-corr-chip, {&db-name_schema})
      buf_c-gds-season.corr-time          = v-time
      buf_c-gds-season.corr-user-db-num   = g#db-num
      buf_c-gds-season.corr-user-name     = g#userid
      buf_c-gds-season.corr-date          = v-date
    .
      create buf_c-gds-hist.
      buffer-copy buf_c-gds-season to buf_c-gds-hist
      assign
      buf_c-gds-hist.action       = (if new ub.gds-season then integer({&hn-create}) else integer({&hn-update}))
      buf_c-gds-hist.subject      = {&table_gds-season}
      buf_c-gds-hist.is-news      = g#news
      buf_c-gds-hist.source-type  = (if g#news then {&hn-source-db} else "":U)
      buf_c-gds-hist.source-ref   = (if g#news then string(g#news-source-db) else "":U)
      .
  end.
  if not g#news  or  ( g#news and g#db-num = 0 ) then do:
    run str/callnews.p
      (input {&table_gds-season}
      ,input (buffer ub.gds-season:handle)
      ) no-error .
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при передаче в новости товара по Сезону" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
        return error.
    end.
    for each ub.gds-season-attr where ub.gds-season-attr.sea-code = ub.gds-season.sea-code
      and ub.gds-season-attr.db-num = ub.gds-season.db-num
      and ub.gds-season-attr.gds-code = ub.gds-season.gds-code:
      run str/callnews.p
        (input {&table_gds-season-attr}
        ,input (buffer ub.gds-season-attr:handle)
        ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при передаче в новости атрибута товара по Сезону" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
          return error.
      end.
  end.
  end.
  
  if g#news then do: /* пришел по новостям, проверим не возникли ли пересечения с сезонами измененными на бд приемнике*/
    find first buf_season no-lock where buf_season.sea-code = ub.gds-season.sea-code 
      and buf_season.db-num = ub.gds-season.db-num
      no-error.
    find first buf_season-attr no-lock where buf_season-attr.sea-code = ub.gds-season.sea-code 
      and buf_season-attr.db-num = ub.gds-season.db-num
      and buf_season-attr.attr-code = {&seaattr-obj} no-error.
    if available buf_season-attr then
          assign
            v-seaobj = buf_season-attr.attr-value
            .
      run chk-gdssea in this-procedure 
        ( input ub.gds-season.gds-code,
          input v-seaobj,
          input buf_season.sea-month-1,
          input buf_season.sea-month-2,
          input rowid(buf_season),
          output v-sea-code,
          output v-db-num,
          output v-ok) no-error.
      if not v-ok then do:
        find current buf_season exclusive-lock.
        assign
          buf_season.des = "пересечение"
          .
      end.
  end.
  
  
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_gds-season}
        , input ( buffer ub.gds-season:handle )
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