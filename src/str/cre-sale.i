/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедура создания продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/05
Author: Bakhtadze Natalya
Creation date: 03/22/05

требует определени
{ str/lib-trn.i }
{ str/doc-code.i }
{ str/trdcalib.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ str/saledoc.i " " }
{ gbl/thbj-def.i }
{ gbl/cur-time.i }

procedure cre-docs.
define input parameter p-auto          as integer no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-shift-date    like ub.inkas.shift-date no-undo .
define input parameter p-shift-num     like ub.inkas.shift-num  no-undo .
define input parameter p-filter-name   as character             no-undo .
define input parameter p-filter-str    as character             no-undo .
define input parameter p-filter-str-rus as character            no-undo .
define input parameter p-doc-mode      as character no-undo . /*{&sale} {&inquiry}*/
define output parameter p-doc-rec      as recid no-undo.

DEFINE VARIABLE sys-today as date no-undo .
define variable vardoc-code like ub.trn-doc.doc-code no-undo.
define variable varret-code like ub.trn-doc.doc-code no-undo.
define variable v-curr-r-b as character no-undo .
define variable v-chk-pay     like ub.shop.chk-pay no-undo .
define variable v-dead-doc   as character initial no no-undo.
define variable v-type       as character initial ? no-undo.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
/*использовать смены на кассе для данного объекта*/
define variable cas-shft as logical no-undo init no.
/*использовать смены для данного объекта*/
define variable l-shift-on as logical no-undo init no.
/*текущие*/
define variable v-shift-date like ub.shift-obj.shift-date no-undo.
define variable v-shift-num  like ub.shift-obj.shift-num no-undo.
define variable v-shift-name  like ub.shift-obj.shift-name no-undo.
/*в продажу закачивать чеки только по фильтру - если задан*/
define variable sale-filter as logical no-undo init no.
define variable one-sale-per-day as logical no-undo .
define variable v-index as integer no-undo .
define variable v-wrkr as integer no-undo .
define variable v-agnt as integer no-undo .
define variable v-boss as integer no-undo .




define buffer buf_ret-doc     for ub.trn-doc.
define buffer buf_trn-doc     for ub.trn-doc.
define buffer buf_inkas       for ub.inkas.
define buffer buf_curr-shop   for ub.curr-shop.
define buffer buf_shift-obj for ub.shift-obj.
define variable v-mes as character no-undo .
define variable v-ps as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .



define buffer buf_shop for ub.shop.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients .
define buffer real_clients for ub.clients .
define buffer buf_sale-doc for ub.sale-doc.

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  { gbl/curr-r-b.i
    v-curr-r-b
  }
  find first buf_clients no-lock where
            buf_Clients.obj-type = p-curr-obj-type
        AND buf_Clients.obj-code = p-curr-obj-code no-error .
  if not available buf_clients then do:
    v-mes = substitute("Не найден объект &1&2"
                ,p-curr-obj-type
                ,p-curr-obj-code)
    .
    undo, return error v-mes.
  end.
  find first buf_shop no-lock where
            buf_shop.obj-code = p-curr-obj-code no-error .
  if not available buf_clients then do:
    v-mes = substitute("Не найден  магазин &1"
                ,p-curr-obj-code).
    undo, return error v-mes.
  end.
  assign
  v-chk-pay = buf_shop.chk-pay
  .

  find first buf_sysconf no-lock where
          buf_sysconf.host-code = buf_clients.host-code no-error .
  if not available buf_sysconf then do:
    v-mes =  substitute("Не найдена фирма &1 для объекта&2&3"
                ,buf_clients.host-code
                ,p-curr-obj-type
                ,p-curr-obj-code).
    undo, return error v-mes.
  end.

  { gbl/conf-rd.i
    "'dead-doc'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-dead-doc
    v-type
    no-error
  }
  if  error-status :error  = false then do:
    if v-dead-doc = "yes"  then  do:
      v-mes = "В системе установлен запрет на ввод документов - параметр dead-doc".
      undo, return error v-mes.
    end.
  end.

  /*найдем параметр - чеки по одному выбранному курсу или нет*/
  /*найдем параметр - откуда брать цены на товар в накладную - из чека или из прайс-листа*/
  /*по умолчанию из чека*/
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-curr-obj-type
      ,input  p-curr-obj-code
      ,input  {&attr-autosale}
      ,input  '':U /*p-param-code*/
      ,output  v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type /*p-param-value*/
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if error-status:error then do:
     v-mes = substitute("Ошибка при получении опций работы с продажей НА ОБЪЕКТЕ &1&2:&3&4 &5"
                        , p-curr-obj-type
                        , p-curr-obj-code
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value ).
      return error v-mes.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-curr-obj-type
        and thbjattr_thbj-attr.obj-code = p-curr-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_sale-filter} no-error.
  if available thbjattr_thbj-attr then do:
    assign
    sale-filter = thbjattr_thbj-attr.property-value-logical
    .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-curr-obj-type
        and thbjattr_thbj-attr.obj-code = p-curr-obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_one-sale-per-day} no-error.
  if available thbjattr_thbj-attr then do:
    assign
    one-sale-per-day = thbjattr_thbj-attr.property-value-logical
    .
  end.
  /*найдем параметр - использовать смены на кассе или нет*/
  run adm/shattri.p (
      input "get":U
      ,input  p-curr-obj-type
      ,input  p-curr-obj-code
      ,input  {&attr-get-chk}
      ,input  {&attr-get-chk_cas-shft} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type /*p-param-value*/
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .

  if error-status:error then do:
     v-mes = substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                        , p-curr-obj-type
                        , p-curr-obj-code
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value ).
      return error v-mes.
  end.
  assign
  cas-shft = v-value-logical.

  { gbl/objat.i
    p-curr-obj-type
    p-curr-obj-code
    "'shift-on=request'"
    l-shift-on
  }


  if l-shift-on and not cas-shft then do:
    v-mes = substitute("Внимание! На текущем объекте &1&2 требуется использование смен,&3" +
                        "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо."
                       , p-curr-obj-type
                       , p-curr-obj-code
                       , {&new-line}).
    return ERROR v-mes.
  end.
  if l-shift-on then do:
    if p-auto > 0 then do:
      assign
      p-shift-date = ?
      p-shift-num = ?
      .
    end.
    if p-shift-date <> ?
    and p-shift-num <> ?
    and p-auto = 0
    then do:
      find first buf_shift-obj no-lock where
                buf_shift-obj.obj-type = p-curr-obj-type
            and buf_shift-obj.obj-code = p-curr-obj-code
            and buf_shift-obj.shift-date = p-shift-date
            and buf_shift-obj.shift-num = p-shift-num
            and buf_shift-obj.status_ = {&sht-closed} no-error.
     if not available buf_shift-obj then do:
        v-mes = substitute("Не найдена закрытая смена от &1 c пор. &2 для &3&4, по которой предлагалось создать продажу"
                          , string(p-shift-date, "99/99/9999")
                          , p-shift-num
                          , p-curr-obj-type
                          , p-curr-obj-code
                           ).
        return error v-mes.
      end.
      assign
      v-shift-date = p-shift-date
      v-shift-num = p-shift-num
      v-shift-name = buf_shift-obj.shift-name
      .
    end.
    else do:
      { gbl/curshift.i p-curr-obj-type p-curr-obj-code v-shift-date v-shift-num v-shift-name no-error }
      if error-status:error then do:
        v-mes = substitute("Ошибка при получении признака СМЕНЫ НА ОБЪЕКТЕ &1&2:&3&4 &5"
                          , p-curr-obj-type
                          , p-curr-obj-code
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value ).
        return error v-mes.
      end.
      find first buf_shift-obj where
              buf_shift-obj.obj-type = p-curr-obj-type
          AND buf_shift-obj.obj-code = p-curr-obj-code
          AND buf_shift-obj.shift-date = v-shift-date
          AND buf_shift-obj.shift-num = v-shift-num.
      assign
      v-shift-name = buf_shift-obj.shift-name.
    end.
  end.

    FIND LAST buf_curr-shop WHERE
              buf_curr-shop.curr-code = buf_sysconf.base-code AND
              buf_curr-shop.obj-type = p-curr-obj-type AND
              buf_curr-shop.obj-code = p-curr-obj-code AND
              buf_curr-shop.exch-date <= (if l-shift-on then v-shift-date else sys-today)
                                              use-index pi NO-ERROR.
    if NOT available buf_curr-shop then do:
      v-mes = substitute("На &1&2 на дату &3 неизвестен магазинный курс базовой валюты."
                        , p-curr-obj-type
                        , p-curr-obj-code
                        ,(if l-shift-on then v-shift-date else sys-today)).
      undo, return error v-mes.
    end.
    FIND real_clients WHERE
         real_clients.obj-type = buf_sysconf.sale-type AND
         real_clients.obj-code = buf_sysconf.sale-code NO-LOCK NO-ERROR .
    if NOT available real_clients then do:
      v-mes = substitute("Неправильные настройки системы !&1" +
                         "КОНТРАГЕНТ &2&3, указанный в настройках фирмы &4 как КОНТРАГЕНТ для РЕАЛИЗАЦИИ,&1" +
                          "отсутствует в справочнике !&1"  +
                          "Обратитесь к администратору."
                          , {&new-line}
                          , buf_sysconf.sale-type
                          , buf_sysconf.sale-code
                          , buf_sysconf.host-code
                          ).
      undo, return error v-mes.
    end.

  if p-shift-date = ? then do:
    if p-auto = 4 /*из кассы*/ then do:
      DEFINE VARIABLE v-time as integer no-undo .
      run cur-time in this-procedure ( output sys-today, output v-time).
    end.
    else do:
      { gbl/curobjdt.i p-curr-obj-type p-curr-obj-code sys-today no-error }
    end.
    if error-status:error then return error return-value .
  end.
  else do:
    assign
    sys-today = p-shift-date
    v-shift-num = p-shift-num
    .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_wrkr}.
  assign
  v-wrkr = thbjattr_thbj-attr.property-value-integer
  .
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_agnt}.
  v-agnt = thbjattr_thbj-attr.property-value-integer.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_boss}.
  v-boss = thbjattr_thbj-attr.property-value-integer
  no-error.
  assign
  v-wrkr  = (if v-wrkr = 0 then ? else v-wrkr)
  v-agnt  = (if v-agnt = 0 then ? else v-agnt)
  v-boss  = (if v-boss = 0 then ? else v-boss)
  .
  /*проверим а может уже есть продажа за данный день/смену?*/
  if one-sale-per-day then do:
    if l-shift-on
    or cas-shft
    then do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  p-curr-obj-type
            and buf_inkas.obj-code =  p-curr-obj-code
            and buf_inkas.shift-date = v-shift-date
            and buf_inkas.shift-num = (if l-shift-on
                                      then v-shift-num
                                      else (if p-auto > 0
                                          then v-shift-num
                                          else 1)
                                      )
            no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за смену &1 П. &2 - запрещено параметрами"
                          , string(v-shift-date, "99/99/9999")
                          , (if l-shift-on
                            then v-shift-num
                            else (if p-auto > 0
                                then v-shift-num
                                else 1)
                            )).
        undo, return error v-mes.
      end.
    end.
    else do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  p-curr-obj-type
            and buf_inkas.obj-code =  p-curr-obj-code
            and buf_inkas.doc-date = sys-today no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за день &1 - запрещено параметрами"
                          , string(sys-today, "99/99/9999")
                          ).
        undo, return error v-mes.
      end.
    end.
  end.




    run doc-code in this-procedure
     (input "main",
      input p-curr-obj-type,
      input p-curr-obj-code,
      input ?,
      output vardoc-code ) no-error.
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации номера документа продажи:&1&2 &3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value).
      undo, return error v-mes.
    end.

&scop sale-doc-kind  ~{&TDEDT_Ras_Vnesh_kass~}

v-ps = set-sale-doc-PS ( buffer buf_sale-doc ).

    { str/crtrndoc.i
     ?
     ?
     buf_curr-shop.exch-rate
     buf_curr-shop.exch-scale
     buf_sysconf.sale-code
     buf_sysconf.sale-type
     real_clients.obj-name
     g#db-num
     g#userid
     {&cash-desk}
     vardoc-code
     "(if l-shift-on then v-shift-date else sys-today)"
     {&expense}
     no
     buf_sysconf.host-code
     no
     p-curr-obj-code
     p-curr-obj-type
     no
     v-chk-pay
     v-ps
     no
     ?
     p-doc-mode
     ?
     {&TDEDT_Ras_Vnesh_Kass}
     ?
     no-error
    }
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации  расходной накладной по продаже &4:&1&2 &3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        , vardoc-code
                        ).
      undo, return error v-mes.
    end.

    find buf_trn-doc where buf_trn-doc.doc-code = vardoc-code.
    assign
    buf_trn-doc.fact-date  = if l-shift-on then v-shift-date else sys-today
    buf_trn-doc.shift-date = if l-shift-on then v-shift-date else sys-today
    buf_trn-doc.shift-num  = if l-shift-on
                              then v-shift-num
                              else (IF cas-shft
                                    then (if p-auto > 0
                                          then v-shift-num
                                          else 1)
                                    else 0)
    buf_trn-doc.shift-name  = if l-shift-on then v-shift-name  else (IF cas-shft then string(1) else '')
    buf_trn-doc.wrkr = v-wrkr
    buf_trn-doc.agnt = v-agnt
    buf_trn-doc.boss = v-boss
        .
    CREATE buf_inkas.
    assign
    buf_inkas.inkas-code = buf_trn-doc.doc-code
    buf_inkas.obj-type = p-curr-obj-type
    buf_inkas.obj-code = p-curr-obj-code
    buf_inkas.host-code = buf_sysconf.host-code
    buf_inkas.status_ = {&g___new}
    buf_inkas.acc-date = ?
    buf_inkas.doc-date = if l-shift-on then v-shift-date else sys-today
    buf_inkas.shift-date = if l-shift-on then v-shift-date else sys-today
    buf_inkas.fact-date = if l-shift-on then v-shift-date else sys-today
    buf_inkas.office = no
    buf_inkas.shift-num = if l-shift-on
                              then v-shift-num
                              else (IF cas-shft
                                    then (if p-auto > 0
                                          then v-shift-num
                                          else 1)
                                    else 0)
    buf_inkas.shift-name = if l-shift-on then v-shift-name else (IF cas-shft then string(1) else '')
    buf_inkas.is-mand-sale-filter = sale-filter
    buf_Inkas.is-auto-born = (p-auto>= 2)
    p-doc-rec         = recid(buf_inkas)
    .

    if v-curr-r-b = {&r-b-rubl} then do:
      assign
      buf_trn-doc.exch-code = 0
      buf_trn-doc.exch-rate = 1
      buf_trn-doc.exch-scale = 1
      buf_trn-doc.print-rubl = yes
      .
    end.
    else do:
      assign
      buf_trn-doc.exch-code = base-code
      buf_trn-doc.exch-rate = buf_trn-doc.base-rate
      buf_trn-doc.exch-scale = buf_trn-doc.base-scale
      buf_trn-doc.print-rubl = no
      .
   end.
    if p-filter-str <> "":U then do:
      /*запишем в ink-doc.*/
      assign
      buf_Inkas.sale-filter = p-filter-str
      buf_Inkas.sale-filter-name = p-filter-name
      buf_Inkas.sale-filter-rus = p-filter-str-rus
      .
    end.
    run saledoc-create  in this-procedure (
                                            input buf_trn-doc.doc-code
                                            ,input buf_trn-doc.host-code
                                            ,input buf_trn-doc.obj-type
                                            ,input buf_trn-doc.obj-code
                                            ,input {&TDEDT_Ras_Vnesh_Kass}
                                            ,input {&gds-goods}
                                            ,input no /*p-tpsidoc*/
                                            ,input '':U /*p-alias-type-price*/
                                            ,input '':U /*p-price-obj-type*/
                                            ,input 0 /*price-obj-code*/
                                            ,buffer buf_trn-doc
                                            ) no-error .
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации записи связанного документа для расходной накладной по продаже &4:&1&2 &3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        , vardoc-code
                        ).
      undo, return error v-mes.
    end.
end. /*doe*/

end procedure.


/* $Workfile$   E n d */