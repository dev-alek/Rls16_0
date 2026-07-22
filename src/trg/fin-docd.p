block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление финансового док-та

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fin-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление финансового док-та ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.fin-doc.host-code, ub.fin-doc.fin-doc-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ ref/fd-attr.i }
{ trg/fin-doch.i }
{ gbl/thbjattr.i }

define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-connect for ub.fin-connect.
define buffer buf_fin-doc-tax for ub.fin-doc-tax.
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
define buffer buf_fin-ob for ub.fin-ob.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    find first buf_sysconf no-lock where buf_sysconf.host-code = ub.fin-doc.host-code.
  if not g#news then do:
    if ub.fin-doc.obj-type <> ''
    or ub.fin-doc.obj-code <> 0 then do:
      define variable v-obj-db-num as integer no-undo .
      { gbl/objdbnum.i ub.fin-doc.obj-type ub.fin-doc.obj-code v-obj-db-num }
    end.
    if not (buf_sysconf.firm-db-num = g#db-num
            or v-obj-db-num = g#db-num)
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять запись ПЛАТЕЖА в БД, отличной от главной БД фирмы и/или БД объекта" skip
      "Номер текущей БД" g#db-num skip(0)
      "Номер главной БД фирмы" buf_sysconf.firm-db-num skip(0)
      "Номер БД объекта" v-obj-db-num
      view-as alert-box error .
      undo main-block, return error .
    end.
    find first buf_fin-connect NO-LOCK
      where buf_fin-connect.host-code = ub.fin-doc.host-code
        and buf_fin-connect.fin-doc-code = ub.fin-doc.fin-doc-code
    no-error .
    if available buf_fin-connect then do:
      define variable  v-delcnavt        as logical no-undo .
      define variable  par-type          as character no-undo .
      define variable  v-found           as logical   no-undo .
      define variable  v-value-date      as date   no-undo .
      define variable  v-value-decimal   as decimal   no-undo .
      define variable  v-value-integer   as integer   no-undo .
      define variable  v-value-logical   as logical   no-undo .
      define variable  v-value-character as character no-undo .

      run thbjattr_value in this-procedure  (
        input   "",
        input   0 ,
        input   {&attr-fin-global} ,
        input   'del-conn-avt'  ,
        output  v-value-character ,
        output  v-value-date      ,
        output  v-value-decimal   ,
        output  v-value-integer   ,
        output  v-delcnavt  ,
        output  par-type            ,
        output  v-found
        ) no-error
        .
      if error-status :error then v-delcnavt = false .

      if v-delcnavt = no then do: /* параметр, удалять ли связи автоматом */
        MESSAGE
          "Нельзя удалять связанный платеж! Сначала удалите связь с фин. обязательствами."
        VIEW-AS ALERT-BOX ERROR TITLE "Удаление невозможно!" .
        UNDO main-block, RETURN ERROR.
      end.
      else do:
        for each buf_fin-connect exclusive-lock
          where buf_fin-connect.host-code = ub.fin-doc.host-code
            and buf_fin-connect.fin-doc-code = ub.fin-doc.fin-doc-code
          :
          find first buf_fin-ob exclusive-lock where
                     buf_fin-ob.host-code = buf_fin-connect.host-code
                 and buf_fin-ob.doc-code = buf_fin-connect.fin-ob-code .
          assign
            buf_fin-ob.con-sum-rubl  = buf_fin-ob.con-sum-rubl  - buf_fin-connect.sum-rubl
            buf_fin-ob.con-sum-base  = buf_fin-ob.con-sum-base  - buf_fin-connect.sum-base
            buf_fin-ob.con-sum-doc   = buf_fin-ob.con-sum-doc   - buf_fin-connect.sum-doc
            buf_fin-ob.con-sum-contr = buf_fin-ob.con-sum-contr - buf_fin-connect.sum-contr
          .
          if buf_fin-ob.con-sum-contr = 0 then assign buf_fin-ob.con-stat = 0 .
          else                             assign buf_fin-ob.con-stat = 1 .
          delete buf_fin-connect .
        end.
      end.
    end.
  end.


  if (ub.fin-doc.status_ = {&fin-fact}
  OR ub.fin-doc.status_ = {&fin-bank})
  and ub.fin-doc.is-del  <> yes
  and not g#news
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять платеж, закрытый до статуса" ub.fin-doc.status_ skip
      "Фирма" ub.fin-doc.host-code skip
      "Платеж" ub.fin-doc.fin-doc-code skip
      "Статус платежа" ub.fin-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if not g#news
  and ub.fin-doc.status_ <> {&fin-new}
  and ub.fin-doc.status_ <> {&fin-fact} then do:
    run write-fin-doc-history in this-procedure( buffer ub.fin-doc) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обновлении истории по платежу" skip
        "Фирма" ub.fin-doc.host-code skip
        "Платеж" ub.fin-doc.fin-doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  /* удаляем строки платежа */
  for each buf_fin-doc-tax where
          buf_fin-doc-tax.fin-doc-code = ub.fin-doc.fin-doc-code
     AND  buf_fin-doc-tax.host-code = ub.fin-doc.host-code
  on error undo main-block, return error
  :
    delete buf_fin-doc-tax .
  end.

  if ub.fin-doc.status_ = {&fin-new} then do:
    on delete of ub.fin-doc-attr override do: end.
    on delete of ub.c-fin-doc-attr override do: end.
  end.

  for each buf_fin-doc-attr where
          buf_fin-doc-attr.fin-doc-code = ub.fin-doc.fin-doc-code
     AND  buf_fin-doc-attr.host-code = ub.fin-doc.host-code
  on error undo main-block, return error
  :
    delete buf_fin-doc-attr .
  end.

  if ub.fin-doc.status_ = {&fin-new} then do:
    for each buf_c-fin-doc-attr where
            buf_c-fin-doc-attr.fin-doc-code = ub.fin-doc.fin-doc-code
      AND  buf_c-fin-doc-attr.host-code = ub.fin-doc.host-code
    on error undo main-block, return error
    :
      delete buf_c-fin-doc-attr .
    end.
  end.


  if g#news then do:
    for each buf_fin-connect NO-LOCK
      where buf_fin-connect.host-code = ub.fin-doc.host-code
        and buf_fin-connect.fin-doc-code = ub.fin-doc.fin-doc-code:
      delete buf_fin-connect .
    end.
  end.
  if (g#db-num <> 0 and not g#news)
  or (v-obj-db-num >= 0 and g#db-num <> v-obj-db-num and not g#news)
  then do:
    /* отправляем команду по новостям */
    /*удалиться может в УБД тольо если главная БД фирмы не равна 0 и тогда надо посылать только в "0"*/
    run nws/cmd-del.p
      ( input {&table_fin-doc}
       ,input (buffer ub.fin-doc:handle)
       ,input (if g#db-num > 0
               then "0":U
               else string(v-obj-db-num)
               )
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fin-doc}
        , input ( buffer ub.fin-doc:handle )
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
    
    
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_fin-doc}
      " buffer ub.fin-doc:handle "
      ''
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