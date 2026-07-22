block-level on error undo, throw.
/*

$Revision: b4bfe3261567, 1895, rls $
$Author: SSlivenko $
$Date: Fri Jun 07 16:26:45 2019 +0300 $
$Workfile: extsyss1.p $
$Archive: bge/extsyss1.p $

Сохранение ВНЕШНЕЙ СИСТЕМЫ типа спец

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/19/08
Author: Bakhtadze Natalya
Creation date: 02/19/08

*/

define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input-output parameter p-rec as recid no-undo .
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-esys-name as character no-undo .
define input parameter p-esys-des as character no-undo .
define input parameter p-esys-have-export as logical no-undo .
define input parameter p-esys-db-num-exp as integer no-undo .
define input parameter p-esys-send-news-exp  as logical no-undo .
define input parameter p-esys-num-days-keep-exp  as integer no-undo .
define input parameter p-esys-max-p-size as integer no-undo .
define input parameter p-exp-conf-wait as integer no-undo .
define input parameter p-max-p-queue as integer no-undo .
define input parameter p-max-p-time as integer no-undo .
define input parameter p-esys-have-import as logical no-undo .
define input parameter p-esys-db-num-imp as integer no-undo .
define input parameter p-esys-send-news-imp  as logical no-undo .
define input parameter p-esys-num-days-keep-imp  as integer no-undo .
define input parameter p-imp-conf-send as integer no-undo .
define input parameter p-esys-type as integer no-undo .
define input parameter p-delivery-method as integer no-undo .
define input parameter p-delete-pck-on as integer no-undo .
define input parameter p-save-days-pck-num as integer no-undo .
define temp-table tt-ext-system-attr no-undo like ub.ext-system-attr.
DEFINE INPUT PARAMETER TABLE FOR tt-ext-system-attr.



define variable vss-revision    as character no-undo init "$Revision: b4bfe3261567, 1895, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 07 16:26:45 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extsyss1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/extsyss1.p $":U .
define variable vss-description as character no-undo init "Сохранение ВНЕШНЕЙ СИСТЕМЫ типа спец".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ bge/oxmlext.i  }
{ gbl/cur-time.i }
{ bge/extsyssl.i }
{ bge/esysattr.i }

define variable v-mess as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ok as logical no-undo .
define variable v-ii as integer   no-undo .
define variable v-exp-nums as integer no-undo .
define variable v-imp-nums as integer no-undo .
define variable v-exp-nums-already as integer no-undo .
define variable v-imp-nums-already as integer no-undo .
define variable v-exp-nums-permitted as integer no-undo .
define variable v-imp-nums-permitted as integer no-undo .
define variable v-exp-nums-permitted-chr as character no-undo .
define variable v-imp-nums-permitted-chr as character no-undo .

define variable v-type as character no-undo .


define buffer buf_db for ub.db.
define buffer buf_ext-system for ub.ext-system.
define buffer buf2_ext-system for ub.ext-system.
define buffer buf_ext-classif for ub.ext-classif.


do : // проверки
  if ibs.th.gbl.gbl-var:g#db-num <> 0 then do:
    v-mess = "Запрещено вызывать процедуру в УБД" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else '':U).
  end.

  if p-esys-name = '':U then do:
      v-mess = substitute("Не задано Название внешней системы").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else 'esys-name':U).
  end.

  if lookup(string(p-delivery-method), {&esys-dm-list}) = 0 then do:
    v-mess = substitute("Неверный метод доставки").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'delivery-method':U).
  end.
  if p-delivery-method = integer({&esys-dm-oracle-retail})
   and p-imp-conf-send = INTEGER({&openxml-imp-conf-send}) then do:
    v-mess = substitute("Нельзя установить опцию &1&2и метод доставки &3 одновременно"
                        , {&openxml-imp-conf-send-full}
                        , {&new-line}
                        , {&esys-dm-oracle-retail-full}
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'T-imp-conf-send':U).
  end.
  if p-delivery-method = integer({&esys-dm-oracle-retail})
   and p-exp-conf-wait = INTEGER({&openxml-exp-conf-wait}) then do:
    v-mess = substitute("Нельзя установить опцию &1&2и метод доставки &3 одновременно"
                        , {&openxml-exp-conf-wait-full}
                        , {&new-line}
                        , {&esys-dm-oracle-retail-full}
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'T-exp-conf-wait':U).
  end.

  if lookup(string(p-esys-type), {&openxml-type-list}) = 0 then do:
    v-mess = substitute("Неверный тип ВС").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'esys-type':U).
  end.
  if p-esys-type = integer({&openxml-type-exite-edi})
  and (p-delivery-method <> integer({&esys-dm-exite-edi}) and p-delivery-method <> integer({&esys-dm-contour-edi})) then do:
    &scop openxml-type-code string(p-esys-type)
    v-mess = substitute("Для ВС типа &2 (&1)&3 метод доставки должен быть Exite-EDI или Контур.EDI"
                        , p-esys-type
                        , {&openxml-type-name}
                        , {&new-line}
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else '':U).
  end.

  if p-delete-pck-on <> 0 and p-delete-pck-on <> 1 then do:
    v-mess = substitute("Неверное значение поля Удалять файлы из HEAP = &1", p-delete-pck-on).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'delete-pck-on':U).
  end.

  if p-esys-have-export and p-esys-db-num-exp > 0 then do:
    if not can-find (first buf_db where buf_db.db-num = p-esys-db-num-exp) then do:
      v-mess = substitute("Неверно задан номер БД для экспорта &1", p-esys-db-num-exp).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
  end.

  if p-esys-have-import and p-esys-db-num-imp > 0 then do:
    if not can-find (first buf_db where buf_db.db-num = p-esys-db-num-imp) then do:
      v-mess = substitute("Неверно задан номер БД для импорта &1", p-esys-db-num-imp).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
  end.

  if p-mode = {&add-def} then do:
    if can-find (first ext-system where ext-system.esys-id = p-esys-id) then do :
      v-mess = substitute("ВС с кодом &1 уже существует. Повторное добавление запрещено.", p-esys-id) .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
  end .
  else if p-mode <> {&update} then do:
    message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
    view-as alert-box error .
    return error '':u.
  end.
end . // end_of проверки

  

_main:
do for buf_ext-system
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = {&add-def} then do:
    /* 29/VIII-2018 - заинлайнена run oxmlext-esys-id in this-procedure ( output p-esys-id ). */
    p-esys-id = next-value( s-ext-system, {&db-name_schema} ) . // @NOTE !! p-esys-id - INPUT parameter, не OUTPUT !!
    
    create buf_ext-system.
    assign
    buf_ext-system.esys-id = p-esys-id
    buf_ext-system.db-num =  0
    buf_ext-system.esys-type = p-esys-type
    .
    for each tt-ext-system-attr
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      assign
      tt-ext-system-attr.esys-id = p-esys-id
      tt-ext-system-attr.db-num = 0
      .
    end.
  end.
  if p-mode = {&update} then do:
    find first buf_ext-system exclusive-lock where
              recid(buf_ext-system) = p-rec .
    if not (buf_ext-system.esys-type > integer({&openxml-type-ordinal}))
    then do:
      assign
      v-mess = substitute("Данная система не имеет типа СПЕЦИАЛЬНАЯ").
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if (p-esys-have-export
    and p-esys-db-num-exp <>  buf_ext-system.esys-db-num-exp
    and buf_ext-system.esys-have-export)
    or (p-esys-have-import
    and p-esys-db-num-imp <>  buf_ext-system.esys-db-num-imp
    and buf_ext-system.esys-have-import)
    or (p-esys-have-export <> buf_ext-system.esys-have-export)
    or (p-esys-have-import <> buf_ext-system.esys-have-import)
    then do:
      run extsyssl in this-procedure ( buffer buf_ext-system
                                      ,output v-ok) no-error.
      if not v-ok then do:
        assign
        v-mess = return-value .
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end.
  if lookup(string(p-esys-type), {&openxml-licensed-type-list}) > 0 then do:
    if p-esys-have-export then do:
      for each buf2_ext-system no-lock where
            buf2_ext-system.esys-have-export = yes
            and buf2_ext-system.esys-db-num-exp = p-esys-db-num-exp
            and buf2_ext-system.esys-type = p-esys-type
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        v-exp-nums = v-exp-nums + 1.
      end.
    end.
    if p-esys-have-import then do:
      for each buf2_ext-system no-lock where
            buf2_ext-system.esys-have-import = yes
            and buf2_ext-system.esys-db-num-imp = p-esys-db-num-imp
            and buf2_ext-system.esys-type = p-esys-type
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        v-imp-nums = v-imp-nums + 1.
      end.
    end.
    assign
    v-exp-nums-already = v-exp-nums
    v-imp-nums-already = v-imp-nums
    .
    if p-mode = {&add-def} then do:
      assign
      v-exp-nums = v-exp-nums + 1
      v-imp-nums = v-imp-nums + 1
      .
    end.
    if p-mode = {&update}
    and buf_ext-system.esys-type <> p-esys-type then do:
      assign
      v-exp-nums = v-exp-nums + 1
      v-imp-nums = v-imp-nums + 1
      .
    end.
    define variable v-param-code as character no-undo .
    v-param-code = substitute("esys-&1", string(p-esys-type, "999")).
    /*лицензионность!!!*/
    if v-exp-nums > 0 then do:
      { gbl/confrddb.i
        v-param-code
        p-esys-db-num-exp
        0
        ''
        0
        p-silent
        v-exp-nums-permitted-chr
        v-type
        no-error
        }
      assign
      v-exp-nums-permitted = integer(v-exp-nums-permitted-chr)
      no-error .
      if v-exp-nums-permitted < v-exp-nums then do:
        &scop openxml-type-code string(p-esys-type)
        v-mess = substitute("Количество разрешенных согласно параметру <esys-&7>  ВС с типом &2 (&1)&5 для БД &4 (БД экспорта) = &3,&5 количество ВС такого типа в БД &4 уже = &6"
                            , p-esys-type
                            , {&openxml-type-name}
                            , v-exp-nums-permitted
                            , p-esys-db-num-exp
                            , {&new-line}
                            , v-exp-nums-already
                            , string(p-esys-type, "999")
                            ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    if v-imp-nums > 0 then do:
      { gbl/confrddb.i
        v-param-code
        p-esys-db-num-imp
        0
        ''
        0
        p-silent
        v-imp-nums-permitted-chr
        v-type
        no-error
        }
      assign
      v-imp-nums-permitted = integer(v-imp-nums-permitted-chr)
      no-error .
      if v-imp-nums-permitted < v-imp-nums then do:
        &scop openxml-type-code string(p-esys-type)
        v-mess = substitute("Количество разрешенных согласно параметру <esys-&7> ВС с типом &2 (&1)&5 для БД &4 (БД импорта) = &3,&5 количество ВС такого типа в БД &4 уже = &6 "
                            , p-esys-type
                            , {&openxml-type-name}
                            , v-imp-nums-permitted
                            , p-esys-db-num-imp
                            , {&new-line}
                            , v-imp-nums-already
                            , string(p-esys-type, "999")
                            ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end. /*if lookup(string(p-esys-type), {&openxml-licensed-type-list}) > 0 then do:*/
  /*для некоторых ВС БД экспорта и импорта должны совпадать!!!*/
  if lookup(string(p-esys-type), {&openxml-type-exite-edi} + {&comma-char} +
                         {&openxml-type-edoc-nn} + {&comma-char} +
                         {&openxml-type-dklink}) > 0
  and  (p-esys-have-export <> p-esys-have-import
        or
        p-esys-db-num-exp <> p-esys-db-num-imp
        ) then do:
    &scop openxml-type-code string(p-esys-type)
    v-mess = substitute("Для ВС типа &2 (&1)&3 БД импорта и экспорта должны быть одной и той же БД"
                        , p-esys-type
                        , {&openxml-type-name}
                        , {&new-line}
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  buf_ext-system.esys-name                = p-esys-name
  buf_ext-system.esys-des                 = p-esys-des
  buf_ext-system.esys-have-export         = p-esys-have-export
  buf_ext-system.esys-db-num-exp          = (if p-esys-have-export then p-esys-db-num-exp        else 0)
  buf_ext-system.esys-send-news-exp       = (if p-esys-have-export then p-esys-send-news-exp     else no)
  buf_ext-system.esys-num-days-keep-exp   = (if p-esys-have-export then p-esys-num-days-keep-exp else 0)
  buf_ext-system.esys-max-p-size          = (if p-esys-have-export then p-esys-max-p-size        else 0)
  buf_ext-system.exp-conf-wait            = p-exp-conf-wait
  buf_ext-system.max-p-queue              = p-max-p-queue
  buf_ext-system.max-p-time               = p-max-p-time
  buf_ext-system.esys-have-import         = p-esys-have-import
  buf_ext-system.esys-db-num-imp          = (if p-esys-have-import then p-esys-db-num-imp        else 0)
  buf_ext-system.esys-send-news-imp       = (if p-esys-have-import then p-esys-send-news-imp     else no)
  buf_ext-system.esys-num-days-keep-imp   = (if p-esys-have-import then p-esys-num-days-keep-imp else 0)
  buf_ext-system.imp-conf-send            = p-imp-conf-send
  buf_ext-system.esys-date-change         = v-today
  buf_ext-system.esys-chk-ingr-imp                = yes
  buf_ext-system.esys-chk-seq-imp                 = yes
  buf_ext-system.esys-date-change-attr            = v-today
  buf_ext-system.esys-date-change-exp             = v-today
  buf_ext-system.esys-date-change-imp             = v-today
  buf_ext-system.esys-status                      = integer( {&openxml-status-working} )
  buf_ext-system.esys-work-update                 = no
  buf_ext-system.esys-creid                       = ibs.th.gbl.gbl-var:g#userid
  buf_ext-system.delivery-method                  = p-delivery-method
  buf_ext-system.delete-pck-on                    = p-delete-pck-on
  buf_ext-system.save-days-pck-num                = p-save-days-pck-num
  buf_ext-system.esys-type                        = p-esys-type
  .
  p-rec = recid(buf_ext-system).
  release  buf_ext-system no-error.
  if error-status:error then do:
      assign
      v-mess = substitute("Ошибка при сохранении внешней системы&1&2&1&3"
                           , {&new-line}
                           , error-status:get-message(1)
                           , return-value
                           ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.
  do v-ii = 1 to num-entries({&form-esys-attr}):
     find first tt-ext-system-attr where
              tt-ext-system-attr.esya-attr-code  = entry(v-ii, {&form-esys-attr})
          and tt-ext-system-attr.esys-id = p-esys-id
          and tt-ext-system-attr.db-num = p-db-num no-error.
     if available tt-ext-system-attr then do:

      run ext-system-attr-write in this-procedure (
                                                     input p-esys-id
                                                    ,input p-db-num
                                                    ,input tt-ext-system-attr.esya-attr-code
                                                    ,input tt-ext-system-attr.esya-attr-value) no-error .
      if error-status :error then do:
        assign
        v-mess = substitute("Ошибка при сохранении внешней системы (атрибут &4)&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value
                            , tt-ext-system-attr.esya-attr-code
                            ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).

      end.
    end.
  end.
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Специальная внешняя система &1:&2&3"
                         , p-esys-id
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.