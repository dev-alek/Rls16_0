block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR delete OF ub.assortment-matrix-goods  .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ".
{ cmp/vssrevis.i  }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }


main-block :
do transaction
on error undo main-block, return error
:
define buffer buf_c-assortment-matrix-goods for ub.c-assortment-matrix-goods.
define buffer buf_c-gds-hist                for ub.c-gds-hist.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .



/* ИСТОРИЯ */
  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    ~{&table_assortment-matrix-goods~}
    0
    '':U
    0
    '':U
    '':U
    '':U
    0
    0
    0
    ~{&nws-to-hist~}
    v-send
    no-error
    }
  end.
  if not g#news
  or v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).

    create buf_c-assortment-matrix-goods.
    buffer-copy ub.assortment-matrix-goods to buf_c-assortment-matrix-goods
    assign
      buf_c-assortment-matrix-goods.chip-num        = next-value (s-gds-chip, {&db-name_schema})
      buf_c-assortment-matrix-goods.casg-date-his   = v-date
      buf_c-assortment-matrix-goods.casg-time-his   = v-time
      buf_c-assortment-matrix-goods.corr-user-db-num = g#db-num
      buf_c-assortment-matrix-goods.corr-user-name   = g#userid
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-assortment-matrix-goods to buf_c-gds-hist
    assign
        buf_c-gds-hist.action =  integer({&hn-delete})
        buf_c-gds-hist.subject = {&table_assortment-matrix-goods}
        buf_c-gds-hist.is-news           = g#news
        buf_c-gds-hist.source-type       = (if g#news then {&hn-source-db} else "":U)
        buf_c-gds-hist.source-ref        = (if g#news then string(g#news-source-db) else "":U)
        buf_c-gds-hist.corr-date         =  buf_c-assortment-matrix-goods.casg-date-his
        buf_c-gds-hist.corr-time         =  buf_c-assortment-matrix-goods.casg-time-his
        buf_c-gds-hist.corr-user-db-num  =  buf_c-assortment-matrix-goods.corr-user-db-num
        buf_c-gds-hist.corr-user-name    =  buf_c-assortment-matrix-goods.corr-user-name
    .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_assortment-matrix-goods}
        , input ( buffer ub.assortment-matrix-goods:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                            , {&new-line}
                            , vss-workfile
                            , return-value
                            , error-status :get-message ( 1 ) ).
    end.
    end.
end.