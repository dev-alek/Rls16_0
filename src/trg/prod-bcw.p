block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись бар-кода производителя.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

TRIGGER PROCEDURE FOR WRITE OF ub.prod-bc  OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись бар-кода производител ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/new-bcod.i }
{ trg/prod-bch.i trig oldb ub.prod-bc }
{ gbl/cur-time.i }
{ trg/check-bc.i }
define variable mMessFlg  as logical no-undo.
define variable mMessText as character no-undo.

mMessFlg =     not g#news 
           and not g#auto
           and not g#oxml
           and not g#esys.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  define buffer buf_goods    for ub.goods .
  define buffer buf_bar-code for ub.bar-code .
  define buffer b-prod-bc for ub.prod-bc.

  define variable v-db-num as integer            no-undo . /* номер БД к которой относится бар-код */
  define variable v-on     as logical            no-undo .
  define variable v-b-str  like ub.prod-bc.b-str no-undo .

  define variable v-is-scgb     as logical no-undo .

  DEFINE VARIABLE loc#log as logical no-undo .
  define buffer buf_prod-bc-db for ub.prod-bc-db.

  /* определяем код локальный или нет */
  /* локальный код это
     код, который имеет единицу измерени
       весовой
       или
       дробно-бензиновый

     и длина бар-кода строго меньше 6
   */
  define variable l-prod-bc-global as logical no-undo .
  define variable l-prod-bc-weight as logical no-undo .
  define variable l-prod-bc-pgweight as logical no-undo .
  define variable vB-Str-Int         as integer no-undo.
  vB-Str-Int = int( ub.prod-bc.b-str) no-error.
  if     not error-status:error
     and vB-Str-Int ne 0
     and not ub.prod-bc.b-str begins "0"
  then do:
     find buf_bar-code where buf_bar-code.b-code = vB-Str-Int no-lock no-error.
     if available buf_bar-code
     then do:
        mMessText = substitute("Ошибка создания/изменения дополнительный бар-код &2 &1Уже существует основной бар-код &3&1для товара с кодом &4",
             {&new-line},
             ub.prod-bc.b-str,
             buf_bar-code.b-code,
             buf_bar-code.gds-code).
        if mMessflg
        then 
           message 
              vss-workfile vss-revision vss-description skip
              mMessText view-as alert-box error .
        undo main-block, return error mMessText.
     end.
  end. 
  
  { gbl/prodbcat.i
    ub.prod-bc
    "'global=request':u"
    l-prod-bc-global
    no-error
  }
  if error-status :error then do:
    mMessText = substitute("Ошибка при определении типа дополнительного бар-кода prodbcat &1Основной бар-код &2 &1 Дополнительный бар-код &3&1Действие global=request",
             {&new-line},
             ub.prod-bc.b-code,
             ub.prod-bc.b-str).
    if mMessFlg
    then
    message
      vss-workfile vss-revision vss-description skip
      mMessText skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error mMessText.
  end.
  { gbl/prodbcat.i
    ub.prod-bc
    "'weight=request':u"
    l-prod-bc-weight
    no-error
  }
  if error-status :error then do:
    mMessText = substitute("Ошибка при определении типа дополнительного бар-кода prodbcat &1Основной бар-код &2 &1 Дополнительный бар-код &3&1Действие weight=request",
             {&new-line},
             ub.prod-bc.b-code,
             ub.prod-bc.b-str).
    if mMessFlg
    then
    message
      vss-workfile vss-revision vss-description skip
      mMessText skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error mMessText.
  end.

  { gbl/prodbcat.i
    ub.prod-bc
    "'pgweight=request':u"
    l-prod-bc-pgweight
    no-error
  }
  if error-status :error then do:
     mMessText = substitute("Ошибка при определении типа дополнительного бар-кода prodbcat &1Основной бар-код &2 &1 Дополнительный бар-код &3&1Действие pgweight=request",
             {&new-line},
             ub.prod-bc.b-code,
             ub.prod-bc.b-str).
    if mMessFlg
    then
    message
      vss-workfile vss-revision vss-description skip
      mMessText skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error mMessText.
  end.

  if g#news then do:
    assign
      v-db-num = g#news-source-db
    .
  end.
  else do:
    assign
      v-db-num = g#db-num
    .
  end.
  if new(ub.prod-bc) and
  not g#news then do:
    assign
    ub.prod-bc.cr-db-num = g#db-num
    .
  end.

  if    l-prod-bc-global = true 
     or ub.prod-bc.bc-on-type eq {&gtin}
  then do:
    if l-prod-bc-weight = true then do:
      if not g#news then do:
    { gbl/getsect.i def "''" 0 {&attr-gds-ref} }
    { gbl/getsect.i run "''" 0 {&attr-gds-ref} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = {&attr-gds-ref_is-scgb} then v-is-scgb = thbjattr_thbj-attr.property-value-logical .
    end.
    if v-is-scgb <> true then do:
       mMessText = substitute("Создание глобальных весовых кодов запрещено параметром (is-scgb)! &1Изменить этот параметр можно в Администратор-Глобальные настройки",
             {&new-line}).
      if mMessFlg
      then
          message
            vss-workfile vss-revision vss-description skip
            mMessText skip
            view-as alert-box.
          undo main-block, return error mMessText.
        end.
      end.
      if new( ub.prod-bc ) then do:
        /* только для новых записей надо искать диапазон старые и так там находятся */
        run gen-new-code-range-if-neces( input v-db-num
                                        ,input {&gbl-sc-code}
                                        ,input int( ub.prod-bc.b-str )
                                        ,input g#news
                                        ,input g#db-num
                                        ,input g#news-source-db
                                        ) no-error .
        if error-status:error then do:
          message
          vss-workfile vss-revision vss-description skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error .
          undo main-block, return error .
        end.
      end.
    end.
    /* в случае создания нового товара prod-bc создается до товара (это нужно для новостей) */
    /* и отправлять его отдельно не надо                                                    */
    find buf_bar-code where buf_bar-code.b-code = ub.prod-bc.b-code no-lock no-error .
    if available buf_bar-code then do:
      find buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock no-error .
      if available buf_goods and not new buf_goods then do:
        run str/callnews.p (
                               input {&table_prod-bc}
                              ,input (buffer ub.prod-bc:handle)
                              ) no-error .
        if error-status :error then do:
           mMessText = substitute("Невозможно маршрутизировать prod-bc для отправки в новости",
             {&new-line}).
          if mMessFlg
          then
          message
            vss-workfile vss-revision vss-description skip
            mMessText skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box.
          undo main-block, return error mMessText.
        end.
      end.
    end.
  end.
  else do: /* not l-prod-bc-global */
    if new( ub.prod-bc ) /* только для новых записей надо искать диапазон старые и так там находятся */
       and l-prod-bc-weight
    then do:
      run gen-new-code-range-if-neces( input 0,
                                       input {&loc-sc-code},
                                       input int( ub.prod-bc.b-str ),
                                       input g#news,
                                       input g#db-num,
                                       input g#news-source-db
                                      ) no-error  .
      if error-status:error then do:
        message
        vss-workfile vss-revision vss-description skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    if new( ub.prod-bc ) /* только для новых записей надо искать диапазон старые и так там находятся */
       and l-prod-bc-pgweight
    then do:
      run gen-new-code-range-if-neces( input 0,
                                       input {&loc-pg-code},
                                       input int( ub.prod-bc.b-str ),
                                       input g#news,
                                       input g#db-num,
                                       input g#news-source-db
                                      ) no-error  .
      if error-status:error then do:
        message
        vss-workfile vss-revision vss-description skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.
  if (l-prod-bc-weight
  or l-prod-bc-pgweight)
  and (new( ub.prod-bc ) or
                           (oldb.bc-on = no and
                            (oldb.bc-on <> ub.prod-bc.bc-on)
                           )
                          ) then do:
  /* только для новых записей или включаемых повторно вес кодов для всех объектов БД*/
   /* если еще нет ни одного включенного весового кода на этот товар */
   if l-prod-bc-weight then
   run trg/isvescod.p (input ub.prod-bc.b-code, yes, no, yes, ub.prod-bc.b-str, output loc#log, output v-on, output v-b-str) no-error.
   else
   run trg/ispgwcod.p (input ub.prod-bc.b-code, yes, no, yes, ub.prod-bc.b-str, output loc#log, output v-on, output v-b-str) no-error.
   if not (loc#log and v-on) then do:
     /*создание атрибута товара на объекте*/
     FIND FIRST buf_bar-code where
                buf_bar-code.b-code = ub.prod-bc.b-code No-ERROR.
     { gbl/sclcdatr.i buf_bar-code.gds-code "''" 0 ? yes no-error }
      if error-status:error then do:
           mMessText = substitute("Не удалось создать атрибут товара на объекте ВЕСОВОЙ КОД" ,
             {&new-line}).
            if mMessFlg
            then
            message
            vss-workfile vss-revision vss-description skip
            mMessText skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box.
          undo main-block, return error mMessText.
      end.
   end.
  end.
  if not g#news then do:
  run check-use-bar-code in this-procedure ( input ub.prod-bc.b-code) no-error.
  if error-status:error then do:
    undo main-block, return error return-value .
  end.
  end.

  /*если это локальный и весовой бар-код то запишем его в prod-bc-db - как в транспорт - чтобы потом можно было из ГБД выгрузить УБД*/
  if not g#news
  and ((l-prod-bc-weight
  and not l-prod-bc-global)
     or (l-prod-bc-pgweight
       and not l-prod-bc-global)
     )
    then do:
      find first buf_prod-bc-db where
                 buf_prod-bc-db.b-str = ub.prod-bc.b-str
            AND  buf_prod-bc-db.b-code = ub.prod-bc.b-code
            AND  buf_prod-bc-db.db-num = g#db-num no-error.
      if not available buf_prod-bc-db then do:
        create buf_prod-bc-db.
      end.
      buffer-copy ub.prod-bc to buf_prod-bc-db
      assign
      buf_prod-bc-db.db-num = g#db-num
      .
  end.
  find buf_bar-code where buf_bar-code.b-code = ub.prod-bc.b-code no-lock no-error .
  if available buf_bar-code then do:
    run prod-bch_write-prod-bc-trigger in this-procedure  (
                                        input new(ub.prod-bc)
                                        ,input integer({&hn-update})
                                        ,input buf_bar-code.gds-code
                                        ,input (if g#news
                                                then {&hn-source-db}
                                                else (if g#esys
                                                      then {&hn-source-esys}
                                                      else "":U)
                                                )
                                        ,input  (if g#news
                                                  then string(g#news-source-db)
                                                  else (if g#esys
                                                        then string(g#esys-source-esys)
                                                        else "":U)
                                                  )
                                      ) .
  end.
  { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    " ( if new(ub.prod-bc) then {&goods-proc_addprcode} else {&goods-proc_updateprcode} )"
    " buffer oldb:handle "
    " buffer ub.prod-bc:handle "
    ''
    ''
    no-error
    }
  if error-status:error
  then do:
    if mMessFlg then do:
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
          input {&nwsdochs_action_update}
        , input {&table_prod-bc}
        , input ( buffer ub.prod-bc:handle )
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