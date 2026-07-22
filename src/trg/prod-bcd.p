block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление prod-bc

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

TRIGGER PROCEDURE FOR DELETE OF ub.prod-bc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление prod-bc".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/prod-bch.i trig ub.prod-bc ub.prod-bc }
{ gbl/cur-time.i }
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc-db for ub.prod-bc-db.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  find buf_bar-code where buf_bar-code.b-code = ub.prod-bc.b-code no-lock no-error .
  if available buf_bar-code then do:
    run prod-bch_write-prod-bc-trigger in this-procedure  (
                                         input no
                                        ,input integer({&hn-delete})
                                        ,input buf_bar-code.gds-code
                                        ,input (if g#news
                                                then {&hn-source-db}
                                                else (if g#esys
                                                      then {&hn-source-esys}
                                                      else "":U)
                                                )
                                        ,input (if g#news
                                                then string(g#news-source-db)
                                                else (if g#esys
                                                      then string(g#esys-source-esys)
                                                      else  "":U)
                                                )
                                      ) .
  end.
  /* отправляем команду на удаление в другие БД если это надо*/
  define variable l-prod-bc-global as logical no-undo .
  { gbl/prodbcat.i
    ub.prod-bc
    "'global=request':u"
    l-prod-bc-global
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
      "Основной бар-код" ub.prod-bc.b-code skip
      "Дополнительный бар-код" ub.prod-bc.b-str skip
      "Действие global=request" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  /*если это локальный и весовой бар-код то удалим его в prod-bc-db - как в транспорт
  - чтобы потом можно было из ГБД выгрузить УБД*/
  if not g#news
  and not l-prod-bc-global then do:
  define variable l-prod-bc-weight as logical no-undo .
  define variable l-prod-bc-scaleable as logical no-undo .
  define variable l-prod-bc-pgweight as logical no-undo .
    { gbl/prodbcat.i
      ub.prod-bc
      "'weight=request':u"
      l-prod-bc-weight
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
        "Основной бар-код" ub.prod-bc.b-code skip
        "Дополнительный бар-код" ub.prod-bc.b-str skip
        "Действие weight=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
    if not l-prod-bc-weight then do:
      { gbl/prodbcat.i
        ub.prod-bc
        "'scaleable=request':u"
        l-prod-bc-scaleable
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении типа дополнительного бар-кода prodbcat" skip
          "Основной бар-код" ub.prod-bc.b-code skip
          "Дополнительный бар-код" ub.prod-bc.b-str skip
          "Действие scaleable=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    if not g#news
    and (l-prod-bc-weight or l-prod-bc-scaleable or ub.prod-bc.bc-on-type = {&loc-pg-code})
    then do:
        find first buf_prod-bc-db where
                  buf_prod-bc-db.b-str = ub.prod-bc.b-str
              AND  buf_prod-bc-db.b-code = ub.prod-bc.b-code
              AND  buf_prod-bc-db.db-num = g#db-num no-error.
        if available buf_prod-bc-db then do:
          delete buf_prod-bc-db.
        end.
      end.
    end.
  if l-prod-bc-global or prod-bc.bc-on-type eq {&gtin} then do:
    run nws/cmd-del.p
      ( input {&table_prod-bc}
       ,input (buffer ub.prod-bc:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&goods-proc_delprcode}
    " buffer ub.prod-bc:handle "
    ?
    ''
    ''
    no-error
    }
  if error-status:error
  then do:
    if not g#news then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры rum-runa.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo main-block,  return error return-value .
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_prod-bc}
        , input ( buffer ub.prod-bc:handle )
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

for each prod-bc-attr where prod-bc-attr.b-code eq prod-bc.b-code
                        and prod-bc-attr.b-str  eq prod-bc.b-str
   exclusive-lock:
       delete prod-bc-attr.
end.                     