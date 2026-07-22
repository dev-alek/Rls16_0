block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись fbr-gds-obj

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/04/03
Author: Bakhtadze Natalya
Creation date: 09/04/03

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fbr-gds-obj OLD oldb.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись fbr-gds-obj".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.fbr-gds-obj.obj-type,ub.fbr-gds-obj.obj-code,ub.fbr-gds-obj.gds-code)"}
{ cmp/trg-def.i  }

DEFINE VARIABLE conf-par as character no-undo .
DEFINE VARIABLE par-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code .
define variable v-l as logical no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .

{ gbl/cur-time.i }
{ nws/lib-nws.i }
define buffer buf_clients for ub.clients.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define buffer buf_c-fbr-gds-obj for ub.c-fbr-gds-obj.
define buffer buf_c-gds-hist for ub.c-gds-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    find first buf_clients no-lock where
               buf_clients.obj-type = ub.fbr-gds-obj.obj-type
           AND buf_clients.obj-code = ub.fbr-gds-obj.obj-code.
    if buf_clients.db-num <> g#db-num then do:
      message
      "Нельзя изменять запись атрибута товара (РЕСТОРАН) на объекте," skip
      "принадлежащем другой БД"
      view-as alert-box .
      undo main-block, return error.
    end.
  end.

  find first buf_fbr-gds-obj no-lock where
             buf_fbr-gds-obj.gds-code = ub.fbr-gds-obj.gds-code
         AND buf_fbr-gds-obj.obj-type = ub.fbr-gds-obj.obj-type
         AND buf_fbr-gds-obj.obj-code = ub.fbr-gds-obj.obj-code

         AND recid(buf_fbr-gds-obj) <> recid(ub.fbr-gds-obj)
         no-error .
  if available buf_fbr-gds-obj then do:
    message
    "Товар"  ub.fbr-gds-obj.gds-code skip
    "Уже есть атрибут товара (РЕСТОРАН) на объекте" ub.fbr-gds-obj.obj-type ub.fbr-gds-obj.obj-code
    view-as alert-box error .
    undo main-block, return error .
  end.
  if g#db-num > 0
  and not g#news then do:
    run str/callnews.p
      ( input {&table_fbr-gds-obj}
      ,input (buffer ub.fbr-gds-obj:handle)
      ) .
  end.
  /*создаем batchporcess для отсылки на кассы*/
  { ref/send-ref.i conf-par par-type }
  if not g#news and send-ref then do:
    /*для новых товаров не имеет смысла т.к. они все равно вбез цен на кассу не должны попасть*/
    /*выясним что изменилось*/
    assign
    v-l = yes
    .
    buffer-compare ub.fbr-gds-obj using
    fbr-grp-code
    fbr-obj-code fbr-obj-type
    is-cd is-menu is-modificator is-null-price is-semi-finished
    to oldb
    case-sensitive
    save result in v-l .
    if not v-l then do:
      { gbl/hostcode.i ub.fbr-gds-obj.obj-type  ub.fbr-gds-obj.obj-code v-host-code }
      run trg/nu_gds.p (
                      input  ub.fbr-gds-obj.gds-code
                    ,input  v-host-code
                    ,input  ub.fbr-gds-obj.obj-type
                    ,input  ub.fbr-gds-obj.obj-code
                    ,input  (if not ub.fbr-gds-obj.is-cd  then "D":U else "U":U)
                    ).
    end.
  end.
  buffer-compare ub.fbr-gds-obj
  to oldb
  case-sensitive
  save result in v-l.
  if v-l = no then do:
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer({&hn-is-on}).
      { gbl/get-hn.i
      g#db-num
      {&table_fbr-gds-obj}
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
      create buf_c-fbr-gds-obj.
      buffer-copy oldb to buf_c-fbr-gds-obj
      assign
      buf_c-fbr-gds-obj.gds-code           = ub.fbr-gds-obj.gds-code
      buf_c-fbr-gds-obj.obj-type           = ub.fbr-gds-obj.obj-type
      buf_c-fbr-gds-obj.obj-code           = ub.fbr-gds-obj.obj-code
      buf_c-fbr-gds-obj.chip-num           = next-value (s-gds-chip, {&db-name_schema})
      buf_c-fbr-gds-obj.corr-time          = v-time
      buf_c-fbr-gds-obj.corr-user-db-num   = g#db-num
      buf_c-fbr-gds-obj.corr-user-name     = (if g#news
                                             then {&nts-user}
                                             else (if g#esys
                                                   then {&esys-user}
                                                   else g#userid)
                                             )
      buf_c-fbr-gds-obj.corr-date          = v-date
      .
      if v-host-code = 0 then do:
        { gbl/hostcode.i ub.fbr-gds-obj.obj-type ub.fbr-gds-obj.obj-code v-host-code }
      end.
      create buf_c-gds-hist.
      buffer-copy buf_c-fbr-gds-obj to buf_c-gds-hist
      assign
      buf_c-gds-hist.action = (if new ub.fbr-gds-obj then integer({&hn-create}) else integer({&hn-update}))
      buf_c-gds-hist.subject = {&table_fbr-gds-obj}
      buf_c-gds-hist.host-code = v-host-code
      buf_c-gds-hist.is-news = g#news
      buf_c-gds-hist.source-type = (if g#news
                                    then {&hn-source-db}
                                    else (if g#esys
                                          then  {&hn-source-esys}
                                          else "":U)
                                    )
      buf_c-gds-hist.source-ref = (if g#news
                                   then string(g#news-source-db)
                                   else  (if g#esys
                                          then string(g#esys-source-esys)
                                          else "":U)
                                   )
      .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fbr-gds-obj}
        , input ( buffer ub.fbr-gds-obj:handle )
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