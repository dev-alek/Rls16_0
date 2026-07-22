block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись финансового док-та

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fin-doc OLD buffer oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись финансового док-та ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-doc.host-code, ub.fin-doc.fin-doc-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/factord.i }
{ ref/fd-attr.i }
{ trg/fin-doch.i }
{ trg/new-bcod.i }


define variable v-creating-hist as logical no-undo .
define variable v-cmp as character no-undo .
define variable v-err as logical no-undo .
define variable v-obj-db-num as integer no-undo init -1.

define buffer buf_sysconf  for ub.sysconf.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if new(ub.fin-doc) then do:
   /* только для новых записей надо искать диапазон
    старые и так там находятся */
    define variable v-db-num as integer   no-undo .
    if g#news then assign v-db-num = g#news-source-db .
    else           assign v-db-num = g#db-num .

    run gen-new-code-range-if-neces( input v-db-num,
                                     input {&gbl-fd-code},
                                     input ub.fin-doc.fin-doc-code,
                                     input g#news,
                                     input g#db-num,
                                     input g#news-source-db
                                   ) no-error .
    if error-status:error then do:
      message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value
      view-as alert-box error .
      undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ) .
    end.
  end.

  if not g#news then do:
    find first buf_sysconf no-lock where buf_sysconf.host-code = ub.fin-doc.host-code.
    if buf_sysconf.firm-db-num <> g#db-num
    then do:
      if ub.fin-doc.obj-type <> ''
      and ub.fin-doc.obj-code <> 0 then do:
        { gbl/objdbnum.i  ub.fin-doc.obj-type ub.fin-doc.obj-code v-obj-db-num }
        if not (v-obj-db-num = g#db-num or g#db-num = 0)
        or not (ub.fin-doc.fin-ext-doc-type = {&FDEDT_income_cash}
               or
               ub.fin-doc.fin-ext-doc-type = {&FDEDT_expense_cash}
               )
       then do:
         v-err = yes.
        end.
      end.
      else do:
        v-err  = yes.
      end.
      if v-err then do:
        define variable v-mess  as character no-undo .
        &scop fin-ext-doc-type-code ub.fin-doc.fin-ext-doc-type
        v-mess = substitute("&1 &2 &3&4" +
                             "Нельзя изменять запись ПЛАТЕЖА:&4" +
                             "    в БД, отличной от главной БД фирмы&4"  +
                             "или ПЛАТЕЖИ, не привязанные к объекту текущей БД в УБД&4" +
                             "или БЕЗНАЛИЧНЫЕ ПЛАТЕЖИ в УБД" +
                             "Номер текущей БД &5 Номер главной БД фирмы &6 Платеж привязан к объекту &7&8 тип платежа &9"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              , {&new-line}
                              , g#db-num
                              ,buf_sysconf.firm-db-num
                              , ub.fin-doc.obj-type
                              , ub.fin-doc.obj-code
                              , {&fin-ext-doc-type-name}
                              ).
      message
        v-mess
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
  end.
  if not g#news
  and not new(ub.fin-doc)
  and (ub.fin-doc.status_ <> {&fin-new}
       or oldb.status_ <> {&fin-new}
       ) then do:
    buffer-compare oldb
    to ub.fin-doc
    case-sensitive
    save result in v-cmp
    .
    if v-cmp <> "":U then do:
      assign
      v-creating-hist = yes
      .
      run write-fin-doc-history in this-procedure (buffer oldb).
    end.
  end.
  if oldb.status_ <> ub.fin-doc.status_
  AND not new(ub.fin-doc)
  and not g#news
  then do:
    run str/callnews.p
      (input {&table_fin-doc}
      ,input (buffer ub.fin-doc:handle)
      ).
  end.
  if oldb.prn-doc-code <> ub.fin-doc.prn-doc-code and ub.fin-doc.prn-doc-code <> "тех_"
  AND not new(ub.fin-doc) and g#db-num <> 0 
  and oldb.status_ = ub.fin-doc.status_
  and ub.fin-doc.status_ = {&fin-fact}
  then do:      
  run nws/cr-route.p ( input {&send-cmd}
                ,input "command":U + {&delim-nws} + "fin-doc-prn-doc":U + {&delim-nws} + string(ub.fin-doc.fin-doc-code) + {&delim-nws} + string(ub.fin-doc.host-code) + {&delim-nws} + string(ub.fin-doc.prn-doc-code) + {&delim-nws} + "yes" + {&delim-nws} + "1"
                ,input ?
                ,input 0
               ).      
  end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fin-doc}
        , input ( buffer ub.fin-doc:handle )
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
    if ub.fin-doc.status_ = {&fin-fact} then do:
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_fin-doc}
      " buffer oldb:handle "
      " buffer ub.fin-doc:handle "
      ''
      ''
      no-error
    }
    if error-status :error
    then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
    end.
    
end.