block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись строки ассортиментной матрицы

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.assortment-matrix-goods OLD old_assortment-matrix-goods.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись ассортиментной матрицы".
{ cmp/vssrevis.i "substitute('&1', ub.assortment-matrix-goods.asmt-id ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ nws/lib-nws.i  }
{ ref/assgrpmt.i }
define buffer buf_c-assortment-matrix-goods for ub.c-assortment-matrix-goods.
define buffer buf_c-gds-hist                for ub.c-gds-hist.
define buffer buf_assortment-matrix         for ub.assortment-matrix.
define buffer buf_goods                     for ub.goods  .

define variable v-date as date no-undo .
define variable v-time as integer no-undo .


main-block :
do transaction
on error undo main-block, return error
:
run cur-time in this-procedure(output v-date, output v-time).
if not g#news  then do:
find first buf_assortment-matrix no-lock where
           buf_assortment-matrix.asmt-id = ub.assortment-matrix-goods.asmt-id and
           buf_assortment-matrix.db-num  = ub.assortment-matrix-goods.db-num      no-error .

IF ub.assortment-matrix-goods.asmg-db-num-create = ? THEN DO:
assign
    ub.assortment-matrix-goods.asmg-date-create    = v-date
    ub.assortment-matrix-goods.asmg-time-create    = v-time
    ub.assortment-matrix-goods.asmg-db-num-create  = g#db-num
    ub.assortment-matrix-goods.asmg-who-create     = g#userid
    ub.assortment-matrix-goods.db-num              = g#db-num
    ub.assortment-matrix-goods.obj-type            = buf_assortment-matrix.obj-type
    ub.assortment-matrix-goods.obj-code            = buf_assortment-matrix.obj-code
.
END.
  assign
    ub.assortment-matrix-goods.asmg-date-update     = v-date
    ub.assortment-matrix-goods.asmg-time-update     = v-time
    ub.assortment-matrix-goods.asmg-db-num-update   = g#db-num
    ub.assortment-matrix-goods.asmg-who-update      = g#userid
    ub.assortment-matrix-goods.obj-type            = buf_assortment-matrix.obj-type
    ub.assortment-matrix-goods.obj-code            = buf_assortment-matrix.obj-code
  .
end.


/*
  при смене статуса товара в АссМатр и при добавлении в матрицу ОБЪЕКТНУЮ
  считать {&ggoattr-QntyAssMat} и в ГБД и в УБД не посылая по новостям.
*/

find first buf_goods no-lock where
           buf_goods.gds-code = ub.assortment-matrix-goods.gds-code no-error .

if ub.assortment-matrix-goods.obj-type <> "" then do:
  if ( old_assortment-matrix-goods.asmg-status <> ub.assortment-matrix-goods.asmg-status
       or new ub.assortment-matrix-goods
      )
   and
      ub.assortment-matrix-goods.asmg-status = int({&current-status-int}) then do:
      run recalc-gds-assgrp
        (  /* пересчет после удаления или внесения товара в матрицу */
          input  '+'  ,
          input  buf_goods.gds-code  ,
          input  buf_goods.grp-code  ,
          input  ub.assortment-matrix-goods.asmt-id      ,
          input  ub.assortment-matrix-goods.db-num  )
          no-error .
  end.

  if old_assortment-matrix-goods.asmg-status <> ub.assortment-matrix-goods.asmg-status  and
      ub.assortment-matrix-goods.asmg-status = int({&deleted-status-int}) then do:
      run recalc-gds-assgrp
        (  /* пересчет после удаления или внесения товара в матрицу */
          input  '-'  ,
          input  buf_goods.gds-code  ,
          input  buf_goods.grp-code  ,
          input  ub.assortment-matrix-goods.asmt-id      ,
          input  ub.assortment-matrix-goods.db-num  )
          no-error .
  end.
end.

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
    if old_assortment-matrix-goods.asmg-db-num-create <> ? then do:
        create buf_c-assortment-matrix-goods.
        buffer-copy old_assortment-matrix-goods to buf_c-assortment-matrix-goods
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
          buf_c-gds-hist.action = (if new ub.assortment-matrix-goods then integer({&hn-create}) else integer({&hn-update}))
          buf_c-gds-hist.subject = {&table_assortment-matrix-goods}
          buf_c-gds-hist.obj-code = if available buf_assortment-matrix then buf_assortment-matrix.obj-code else 0
          buf_c-gds-hist.obj-type = if available buf_assortment-matrix then  buf_assortment-matrix.obj-type else ""
          buf_c-gds-hist.is-news = g#news
          buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
          buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
          buf_c-gds-hist.corr-date         =          buf_c-assortment-matrix-goods.casg-date-his
          buf_c-gds-hist.corr-time         =          buf_c-assortment-matrix-goods.casg-time-his
          buf_c-gds-hist.corr-user-db-num  =          buf_c-assortment-matrix-goods.corr-user-db-num
          buf_c-gds-hist.corr-user-name    =          buf_c-assortment-matrix-goods.corr-user-name
      .

    end.
    else do:
        create buf_c-assortment-matrix-goods.
        buffer-copy assortment-matrix-goods to buf_c-assortment-matrix-goods
        assign
          buf_c-assortment-matrix-goods.chip-num        = next-value (s-gds-chip, {&db-name_schema})
          buf_c-assortment-matrix-goods.casg-date-his   = v-date
          buf_c-assortment-matrix-goods.casg-time-his   = v-time
          buf_c-assortment-matrix-goods.corr-user-db-num = g#db-num
          buf_c-assortment-matrix-goods.corr-user-name  = g#userid
          buf_c-assortment-matrix-goods.asmg-status     = ?
        .

      create buf_c-gds-hist.
      buffer-copy buf_c-assortment-matrix-goods to buf_c-gds-hist
      assign
          buf_c-gds-hist.action             = integer({&hn-create})
          buf_c-gds-hist.subject            = {&table_assortment-matrix-goods}
          buf_c-gds-hist.obj-code           = if available buf_assortment-matrix then buf_assortment-matrix.obj-code else 0
          buf_c-gds-hist.obj-type           = if available buf_assortment-matrix then  buf_assortment-matrix.obj-type else ""
          buf_c-gds-hist.is-news            = g#news
          buf_c-gds-hist.source-type        = (if g#news then {&hn-source-db} else "":U)
          buf_c-gds-hist.source-ref         = (if g#news then string(g#news-source-db) else "":U)
          buf_c-gds-hist.corr-date         = v-date
          buf_c-gds-hist.corr-time         = v-time
          buf_c-gds-hist.corr-user-db-num  = g#db-num
          buf_c-gds-hist.corr-user-name    = g#userid
      .
    end.
    /* Не новости и не ГБД */
    if g#db-num > 0 then do:
        run str/callnews.p
          (input "c-assortment-matrix-goods"
          ,input (buffer buf_c-assortment-matrix-goods:handle)
          ) no-error .
        if error-status:error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при передаче в новости buf_c-assortment-matrix-goods" skip
            return-value skip
            view-as alert-box error .
            return error.
        end.
    end.
  end.
/* Отправка по новостям */
  if /* g#db-num = 0 or ( g#db-num <> 0 and g#news = false ) */   true  then do:
      run str/callnews.p
        (input "assortment-matrix-goods"
        ,input (buffer ub.assortment-matrix-goods:handle)
        ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при передаче в новости" skip
          return-value skip
          view-as alert-box error .
          return error.
      end.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_assortment-matrix-goods}
        , input ( buffer ub.assortment-matrix-goods:handle )
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