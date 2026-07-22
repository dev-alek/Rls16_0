/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для детал. оборотки с признаками

Автор: Демин Алексей Сергеевич
Дата создания: 03/22/06
Author: Alexey Demin
Creation date: 03/22/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  /* остатки */
  /* нужны остатки на конец в ценах продажи */
  if use-column[6] = yes or use-column[7] = yes or use-column[51] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-crsa}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.
  /* нужны остатки на конец в учет. ценах */
  if use-column[7] = yes or use-column[32] = yes or use-column[13] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-cost}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order < v-fact-order-end
      use-index category no-error .

    if available buf_stk-line then do:
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.
  /* нужны остатки на начало в ценах продажи */
  if use-column[6] = yes or use-column[50] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-crsa}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order  <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.
  /* нужны остатки на начало в учет. ценах */
  if use-column[12] = yes or use-column[31] = yes then do:
    find last buf_stk-line no-lock
      where buf_stk-line.obj-type  = buf_gds-obj.obj-type
        and buf_stk-line.obj-code  = buf_gds-obj.obj-code
        and buf_stk-line.artic     = buf_gds-obj.artic
        and buf_stk-line.prod-type = buf_gds-obj.prod-type
        and buf_stk-line.prod-code = buf_gds-obj.prod-code
        and buf_stk-line.sum-type  = {&arh-cost}
        and buf_stk-line.cat-id    = '##,##'
        and buf_stk-line.fact-order <= v-fact-order-start
      use-index category no-error .

    if available buf_stk-line then do:
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
      if x-SET_val_TYPE = 1  then  run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-rubl) .
      else                         run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", -1, gds-prop.b-code, buf_stk-line.sum-base) .
    end.
  end.

  /* а теперь остатки на альтернативных объектах */
  if RADIO-AltObj = 2 then do :  /* все */
    for each buf_clients no-lock :
      find first b_obj-list no-lock where b_obj-list.obj-type = buf_clients.obj-type and b_obj-list.obj-code = buf_clients.obj-code no-error .
      if available b_obj-list then next .

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_clients.obj-type
          and buf_stk-line.obj-code  = buf_clients.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "alt-ost", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
    end.
  end.
  else do:
    if RADIO-AltObj = 3 then do :  /* выбран список */
      assign p-num = num-entries( AltObj-list ) .
      do ii = 1 to p-num by 2 :
        find last buf_stk-line no-lock
          where buf_stk-line.obj-type  = entry( ii, AltObj-list )
            and buf_stk-line.obj-code  = integer( entry( ii + 1 , AltObj-list ))
            and buf_stk-line.artic     = buf_gds-obj.artic
            and buf_stk-line.prod-type = buf_gds-obj.prod-type
            and buf_stk-line.prod-code = buf_gds-obj.prod-code
            and buf_stk-line.sum-type  = {&arh-cost}
            and buf_stk-line.cat-id    = '##,##'
            and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
        if available buf_stk-line then run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "alt-ost", -1, gds-prop.b-code, buf_stk-line.fact-qnty) .
      end.
    end.
  end.

/* остатки */
if gds-prop.empty-scale = no then do: /* это шкальный товар */

  define var parrecid-prl as recid no-undo .
  define variable v-prt-b-code like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define buffer buf_gds-prop for gds-prop.

  define variable vat-pc-sale-prl     as decimal   no-undo .
  define variable slt-pc-sale-prl     as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl     as decimal   no-undo .
  define variable price-base-with-tax-sale-prl     as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl  as decimal   no-undo .
  define variable price-base-without-tax-sale-prl  as decimal   no-undo .
  define variable vat-base-sale-prl                as decimal   no-undo .
  define variable vat-rubl-sale-prl                as decimal   no-undo .
  define variable vat-base-buyer-prl               as decimal   no-undo .
  define variable vat-rubl-buyer-prl               as decimal   no-undo .
  define variable slt-base-sale-prl                as decimal   no-undo .
  define variable slt-rubl-sale-prl                as decimal   no-undo .
  define variable road-tax-base-sale-prl           as decimal   no-undo .
  define variable road-tax-rubl-sale-prl           as decimal   no-undo .
  define variable excise-base-sale-prl             as decimal   no-undo .
  define variable excise-rubl-sale-prl             as decimal   no-undo .
  define variable discnt-base-sale-prl             as decimal   no-undo .
  define variable discnt-rubl-sale-prl             as decimal   no-undo .

  define variable sum-zak  as decimal   no-undo .
  define variable sum-prod as decimal   no-undo .

  if use-column[7] = yes or use-column[12] = yes or use-column[31] = yes or use-column[50] = yes then do:
    run  prdoclib-init-prt-obj-by-factord in this-procedure  /* на начало */
       ( input buf_gds-obj.obj-type  ,         input buf_gds-obj.obj-code  ,         input buf_gds-obj.artic  ,
         input buf_gds-obj.prod-type ,         input buf_gds-obj.prod-code ,         input v-fact-order-start ,
         input false ) .

    /* определяем сумму в закуп-ных ценах */
    if use-column[7] = yes or use-column[31] = yes then do:
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order  <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        if x-SET_val_TYPE = 1  then assign sum-zak = buf_stk-line.sum-rubl / buf_stk-line.fact-qnty .
        else                        assign sum-zak = buf_stk-line.sum-base / buf_stk-line.fact-qnty .
      end.
      else assign sum-zak = 0.
    end.
    /* определяем сумму в продажных ценах */
    for each buf_temp-prt-obj no-lock :    /* определяем продажную цену на дату инициализации архива */
      { gbl/gdsbcode.i buf_gds-obj.gds-code buf_temp-prt-obj.prt-code v-prt-b-code  no-error  }
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
              "Код товара"   buf_gds-obj.gds-code skip  "Код признака" buf_temp-prt-obj.prt-code skip error-status :get-message(1) skip
          return-value skip
        view-as alert-box error .
        undo, return error .
      end.

      { gbl/bcodepls.i  buf_gds-obj.obj-type  buf_gds-obj.obj-code  v-prt-b-code  0  v-fact-order-start  parrecid-prl  v-cli-base-rate no-error }
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении цены бар-кода" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip  "Бар-код" v-prt-b-code skip
              "fact-order" v-fact-order-start skip  error-status :get-message(1) skip  return-value skip
        view-as alert-box error .
        undo, return error .
      end.

      if parrecid-prl <> ? then do:
        run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl         ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl                       ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl                      ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl                       ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl                  ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl                    ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl                    ,output discnt-rubl-sale-prl
            ) no-error .
        if error-status :error then do:
            message vss-workfile vss-revision vss-description skip "Ошибка при вызове процеды prl-vat" skip
              "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
              error-status :get-message(1) skip  return-value skip    view-as alert-box error .
            undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
        .
      end.
      if x-SET_val_TYPE = 1 then assign sum-prod = price-rubl-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .
      else                       assign sum-prod = price-base-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .

      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-beg", buf_temp-prt-obj.prt-code, v-prt-b-code, buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-beg", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-zak * buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-beg", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-prod) .
    end. /* each buf_temp-prt-obj */
  end.
  if use-column[7] = yes or use-column[13] = yes or use-column[32] = yes or use-column[51] = yes then do:
    run  prdoclib-init-prt-obj-by-factord in this-procedure  /* на конец */
       ( input buf_gds-obj.obj-type  ,         input buf_gds-obj.obj-code  ,         input buf_gds-obj.artic     ,
         input buf_gds-obj.prod-type ,         input buf_gds-obj.prod-code ,         input v-fact-order-end ,
         input false ) .

    /* определяем сумму в закуп-ных ценах */
    if use-column[7] = yes or use-column[31] = yes then do:
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order  <= v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        if x-SET_val_TYPE = 1  then assign sum-zak = buf_stk-line.sum-rubl / buf_stk-line.fact-qnty .
        else                        assign sum-zak = buf_stk-line.sum-base / buf_stk-line.fact-qnty .
      end.
      else assign sum-zak = 0.
    end.
    /* определяем сумму в продажных ценах */
    for each buf_temp-prt-obj no-lock :    /* определяем продажную цену на дату инициализации архива */
      { gbl/gdsbcode.i buf_gds-obj.gds-code buf_temp-prt-obj.prt-code v-prt-b-code  no-error  }
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip
              "Код товара"   buf_gds-obj.gds-code skip  "Код признака" buf_temp-prt-obj.prt-code skip error-status :get-message(1) skip
          return-value skip
        view-as alert-box error .
        undo, return error .
      end.

      { gbl/bcodepls.i  buf_gds-obj.obj-type  buf_gds-obj.obj-code  v-prt-b-code  0  v-fact-order-end  parrecid-prl  v-cli-base-rate no-error }
      if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip "Ошибка при определении цены бар-кода" skip
              "Объект" buf_gds-obj.obj-type buf_gds-obj.obj-code skip  "Бар-код" v-prt-b-code skip
              "fact-order" v-fact-order-start skip  error-status :get-message(1) skip  return-value skip
        view-as alert-box error .
        undo, return error .
      end.

      if parrecid-prl <> ? then do:
        run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl   ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl              ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl             ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl              ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl         ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl           ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl           ,output discnt-rubl-sale-prl
         ) no-error .
        if error-status :error then do:
            message vss-workfile vss-revision vss-description skip "Ошибка при вызове процеды prl-vat" skip
              "Артикул" buf_gds-obj.artic buf_gds-obj.prod-type buf_gds-obj.prod-code skip
              error-status :get-message(1) skip  return-value skip    view-as alert-box error .
            undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
        .
      end.
      if x-SET_val_TYPE = 1 then assign sum-prod = price-rubl-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .
      else                       assign sum-prod = price-base-with-tax-sale-prl * buf_temp-prt-obj.fact-qnty  .

      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 0, "ost-end", buf_temp-prt-obj.prt-code, v-prt-b-code, buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 1, "ost-end", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-zak * buf_temp-prt-obj.fact-qnty) .
      run Add-temp-prt ( gds-prop.obj-code, gds-prop.obj-type,  gds-prop.gds-code, 2, "ost-end", buf_temp-prt-obj.prt-code, v-prt-b-code, sum-prod) .
    end. /* each buf_temp-prt-obj */
  end.
end.
/* ************************************************************************************ */
/*else do:*/
/*end.*/

/* $Workfile$   E n d */