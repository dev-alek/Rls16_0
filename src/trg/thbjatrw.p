block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись пар-ров объекта TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/17/07
Author: Bakhtadze Natalya
Creation date: 01/17/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.thbj-attr OLD oldthbj-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись пар-ров объекта TH".
{ cmp/vssrevis.i "substitute('&1|&2'
                         , ub.thbj-attr.obj-type
                         , ub.thbj-attr.obj-code
                         , ub.thbj-attr.upper-prop-code
                         , ub.thbj-attr.prop-code
                         ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .

define buffer buf_c-thbj-attr for ub.c-thbj-attr.
define buffer buf_c-cli-hist for ub.c-cli-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

 if not g#news then do:
   if (ub.thbj-attr.obj-type = {&cmp}
   or ub.thbj-attr.obj-type = '':U
   or (ub.thbj-attr.obj-type = {&db} and  g#db-num <>  ub.thbj-attr.obj-code)
   )
   and g#db-num > 0 then do:
     message
     vss-workfile vss-revision vss-description skip
     "Запрещено создавать/изменять параметры объектов TH в УБД"
     substitute("Параметр &1 &2 тип объекта &3 код объекта &4"
                 , ub.thbj-attr.upper-prop-code
                 , ub.thbj-attr.prop-code
                 , ub.thbj-attr.obj-code
                 , ub.thbj-attr.obj-type
                 )
     view-as alert-box error .
   end.
 end.

 run str/callnews.p
    ( input {&table_thbj-attr}
      ,input (buffer ub.thbj-attr:handle)
    ) .

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
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-thbj-attr.
    buffer-copy oldthbj-attr to buf_c-thbj-attr
    assign
    buf_c-thbj-attr.obj-type           = ub.thbj-attr.obj-type
    buf_c-thbj-attr.obj-code           = ub.thbj-attr.obj-code
    buf_c-thbj-attr.upper-prop-code    = ub.thbj-attr.upper-prop-code
    buf_c-thbj-attr.prop-code          = ub.thbj-attr.prop-code
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
    buf_c-cli-hist.action = (if new (ub.thbj-attr )
                            then integer({&hn-create})
                            else integer({&hn-update}))
    buf_c-cli-hist.subject = {&table_thbj-attr}
    buf_c-cli-hist.host-code = v-host-code
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-cli-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
    .
    if ub.thbj-attr.upper-prop-code = {&attr-marking} and 
       ub.thbj-attr.prop-code = {&attr-marking_ban-recipes} and 
       ub.thbj-attr.property-value-logical = true then do:
          if buf_c-thbj-attr.property-value-logical <> ub.thbj-attr.property-value-logical then { str/promoMark.i } .
    end.      
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_thbj-attr}
        , input ( buffer ub.thbj-attr:handle )
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
end. /*doe*/