
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление пар-ров объекта TH".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.thbj-attr.obj-type
                         , ub.thbj-attr.obj-code
                         , ub.thbj-attr.upper-prop-code
                         , ub.thbj-attr.prop-code
                         ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{cmp/str-glbl.i}

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

define buffer buf_c-thbj-attr for ub.c-thbj-attr.
define buffer buf_c-cli-hist for ub.c-cli-hist.

on DELETE of ub.thbj-attr override do: 
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
 if not g#news then do:
   if (ub.thbj-attr.obj-type = {&cmp}
   or ub.thbj-attr.obj-type = '':U)
   or (ub.thbj-attr.obj-type = {&db} and  g#db-num <>  ub.thbj-attr.obj-code)
   and g#db-num > 0 then do:
   /*  message
     vss-workfile vss-revision vss-description skip
     "Запрещено удалять параметры объектов TH в УБД"
     substitute("Параметр &1 &2 фирма &3"
                 , ub.thbj-attr.upper-prop-code
                 , ub.thbj-attr.prop-code
                 , ub.thbj-attr.obj-code)
     view-as alert-box error . */
   end.
 end.


  if g#news then do:
    define variable v-send as integer no-undo .
    v-send = integer({&hn-is-on}).
    { gbl/get-hn.i
    g#db-num
    {&table_thbj-attr}
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
    create buf_c-thbj-attr.
    buffer-copy ub.thbj-attr to buf_c-thbj-attr
    assign
    buf_c-thbj-attr.chip-num           = next-value (s-cli-chip, {&db-name_schema})
    buf_c-thbj-attr.corr-time          = v-time
    buf_c-thbj-attr.corr-user-db-num   = g#db-num
    buf_c-thbj-attr.corr-user-name     = (if g#news
                                          then {&nts-user}
                                          else (if g#esys
                                                then {&esys-user}
                                                else g#userid)
                                          )
    buf_c-thbj-attr.corr-date          = v-date
    buf_c-thbj-attr.action = (if new (ub.thbj-attr )
                            then integer({&hn-create})
                            else integer({&hn-update}))
    buf_c-thbj-attr.subject = {&table_thbj-attr}
    .
    if ub.thbj-attr.obj-type = {&shop}
    or ub.thbj-attr.obj-type = {&stock} then do:
      { gbl/hostcode.i ub.thbj-attr.obj-type ub.thbj-attr.obj-code v-host-code }
    end.
    create buf_c-cli-hist.
    buffer-copy buf_c-thbj-attr to buf_c-cli-hist
    assign
    buf_c-cli-hist.action = integer({&hn-delete})
    buf_c-cli-hist.subject = {&table_thbj-attr}
    buf_c-cli-hist.host-code = v-host-code
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-cli-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
  end.
  run nws/cmd-del.p
    ( input {&table_thbj-attr}
      ,input (buffer ub.thbj-attr:handle)
      ,input "":U
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_thbj-attr}
        , input ( buffer ub.thbj-attr:handle )
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


end.


DEFINE INPUT  PARAMETER parparentproc AS HANDLE    NO-UNDO.
DEFINE INPUT  PARAMETER iparam        AS CHARACTER NO-UNDO. 
DEFINE OUTPUT PARAMETER oOk           AS LOGICAL   NO-UNDO. 

DEFINE BUFFER db FOR ub.db.
DEFINE BUFFER thbj-attr FOR ub.thbj-attr.
/*g#news = YES. */



OUTPUT TO "errors.log".

    FOR EACH db NO-LOCK:
        DO TRANSACTION:
            FOR EACH thbj-attr 
                WHERE thbj-attr.upper-prop-code EQ "marking"
                     AND (thbj-attr.prop-code   EQ "marking-type"
                    OR thbj-attr.prop-code      EQ "marking-type-blockCashUnMark"
                    OR thbj-attr.prop-code      EQ "marking-type-saleUPD"
                    OR thbj-attr.prop-code      EQ "marking-type-onlySale")
                EXCLUSIVE-LOCK:
                DELETE thbj-attr NO-ERROR.
                IF ERROR-STATUS:ERROR THEN  ERROR-STATUS:ERROR = NO. 
            END. 
        END. 
    END. 

OUTPUT CLOSE.

/* g#news = NO. */
oOk = TRUE. 
