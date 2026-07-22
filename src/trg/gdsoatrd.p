block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление gds-obj-attr

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/29/06
Author: Bakhtadze Natalya
Creation date: 03/29/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-obj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление gds-obj-attr".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ ref/gdsoattr.i trigger }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/getcntxa.i }

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-type           as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-user-can-edit  as logical   no-undo .
define variable v-output-display as logical   no-undo .
define variable v-other          as character no-undo .
define variable jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
define variable v-db-list as character no-undo .
define variable v-manual-editing as integer no-undo .
define variable dbNum as integer no-undo .
define variable listPromoIds as character no-undo .
define variable sendGoods2Kassa as logical no-undo init false.
define buffer buf_c-gds-obj-attr for ub.c-gds-obj-attr.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer locked_gds-obj-attr for ub.gds-obj-attr.
define buffer PromoGoods  for ub.PromoGoods.
define buffer PromoAction for ub.PromoAction.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   if not ub.gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o} then do:
    run gdsoattr-manual-edit in this-procedure (
                                                    input ub.gds-obj-attr.attr-code
                                                    ,output v-manual-editing
                                                    ) no-error .
    if not error-status:error
    and v-manual-editing > 0 then do:
    Find first locked_gds-obj-attr exclusive-lock  where
            locked_gds-obj-attr.gds-code = ub.gds-obj-attr.gds-code
        AND locked_gds-obj-attr.obj-type = ub.gds-obj-attr.obj-type
        AND locked_gds-obj-attr.obj-code = ub.gds-obj-attr.obj-code
        and locked_gds-obj-attr.attr-code = {&attr-gds-obj-attr-lock-o}
        no-error no-wait.
    if locked locked_gds-obj-attr then
    undo main-block, return error substitute("&1&2Атрибут товара на объекте &3 товар &4 &5&6 занят"
                                              , {&attr-gds-obj-attr-lock-o}
                                              , {&delim-par}
                                              , ub.gds-obj-attr.attr-code
                                              , ub.gds-obj-attr.gds-code
                                              , ub.gds-obj-attr.obj-type
                                              , ub.gds-obj-attr.obj-code).

     end.
   end.



  { ref/send-ref.i conf-par par-type }
  if send-ref then do:
    run gdsoattr-name in this-procedure (
                                           input  ub.gds-obj-attr.attr-code
                                          ,output v-type
                                          ,output v-format
                                          ,output v-label
                                          ,output v-user-can-edit
                                          ,output v-output-display
                                          ,output v-other
    ) .
    _do:
    do jj = 1 to num-entries(v-other, {&slash-char}):
      assign
      v-dop1 = entry(1, entry(jj, v-other, {&slash-char}), '=':U)
      v-dop2 = entry(2, entry(jj, v-other, {&slash-char}), '=':U)
      .
      if v-dop1 = "cd":U then do:
        run trg/nu_gds.p (
                      input  ub.gds-obj-attr.gds-code
                      ,input  0
                      ,input  ub.gds-obj-attr.obj-type
                      ,input  ub.gds-obj-attr.obj-code
                      ,input  "U":U  /*здесь действительно надо U!!! не меняйте на D*/
                    ).
        sendGoods2Kassa = true.
        NEXT _do.
      end.
      { trg/gdsoatr_send2kassa.i "getPromoIds"}
    end.
  end. /*if send-ref*/
  if g#news then do:
    define variable v-send as INTEGER no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    ~{&table_gds-obj-attr~}
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
  create buf_c-gds-obj-attr.
  buffer-copy ub.gds-obj-attr to buf_c-gds-obj-attr
  assign
  buf_c-gds-obj-attr.chip-num           = next-value (s-gds-chip, {&db-name_schema})
  buf_c-gds-obj-attr.corr-time          = v-time
  buf_c-gds-obj-attr.corr-user-db-num   = g#db-num
  buf_c-gds-obj-attr.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else (if g#esys
                                          then {&esys-user}
                                          else g#userid)
                                    )
  buf_c-gds-obj-attr.corr-date          = v-date
  .
  { gbl/hostcode.i ub.gds-obj-attr.obj-type ub.gds-obj-attr.obj-code v-host-code }
  create buf_c-gds-hist.
  buffer-copy buf_c-gds-obj-attr to buf_c-gds-hist
  assign
  buf_c-gds-hist.action = integer({&hn-delete})
  buf_c-gds-hist.subject = {&table_gds-obj-attr}
  buf_c-gds-hist.host-code = v-host-code
  buf_c-gds-hist.is-news   = g#news
  buf_c-gds-hist.source-type = (if g#news
                                then {&hn-source-db}
                                else (if g#esys
                                      then {&hn-source-esys}
                                      else "":U)
                                )
  buf_c-gds-hist.source-ref = (if g#news
                                then string(g#news-source-db)
                                else (if g#esys
                                      then string(g#esys-source-esys)
                                      else "":U)
                                )
  .
  end.
  { gbl/objdbnum.i ub.gds-obj-attr.obj-type ub.gds-obj-attr.obj-code  v-obj-db-num }
  if g#db-num = 0 and v-obj-db-num <> 0  then do:
    assign v-db-list = string( v-obj-db-num ) .
  end.
  if g#db-num <> 0 and not g#news then do:
    assign v-db-list = "0" .
  end.
  run nws/cmd-del.p
    ( input {&table_gds-obj-attr}
     ,input (buffer ub.gds-obj-attr:handle)
     ,input v-db-list
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_gds-obj-attr}
        , input ( buffer ub.gds-obj-attr:handle )
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
  { trg/gdsoatr_send2kassa.i "send2Kassa"}
end.