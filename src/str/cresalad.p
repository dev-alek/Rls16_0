block-level on error undo, throw.
/*

$Revision: 315b966a6a9b, 3487, rls $
$Author: BelovaMM $
$Date: 2023/10/16 15:13:36 $
$Workfile: cresalad.p $
$Archive: str/cresalad.p $

Генерация дополнительных (помимо простого расхода и возврата) документов, привязанных к продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/05
Author: Bakhtadze Natalya
Creation date: 09/29/05

*/

define parameter buffer buf_main_trn-doc for ub.trn-doc.
/*передадим буфер расходной части в качестве своебразного шаблона*/
define parameter buffer buf_trn-doc for ub.trn-doc.
/*буфер получившегося документа*/
define input parameter p-doc-kind as character no-undo .
/*ключевое слово, описывающее КАКОЙ документ нам надо сгенерить и по какому контрагенту*/
/*может быть tech-refuell write-off
тогда генерится документ списания на контрагента, определяемого соответствующими атрибутами фирмы
*/
define input parameter p-office as character no-undo .

/* Для определения контрагента при создании доп документа в соотв. с атрибутом типа оплаты */
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .

/*ключевое слово, описывающее ТИП ТОВАРА*/
define output parameter p-doc-code like ub.trn-doc.doc-code no-undo .
/*номер сгенеренного документа*/

define variable vss-revision    as character no-undo init "$Revision: 315b966a6a9b, 3487, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cresalad.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cresalad.p $":U .
define variable vss-description as character no-undo init "Генерация дополнительных (помимо простого расхода и возврата) документов, привязанных к продаже".
{ cmp/vssrevis.i }
{ cmp/trg-def.i } /*МОЖЕТ ВЫЗЫВАТЬСЯ АВТОМАТОМ ПО РАСПИСАНИЮ!!*/
{ cmp/library.i }
{ str/lib-trn.i }
{ str/trdcalib.i }
{ str/saledoc.i  }
{ str/doc-code.i }

define variable v-doc-type like ub.trn-doc.doc-type no-undo .
define variable v-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define variable v-cli-type like ub.trn-doc.cli-type no-undo .
define variable v-cli-code like ub.trn-doc.cli-code no-undo .
define variable v-cli-name like ub.trn-doc.cli-name no-undo .
define variable v-internal like ub.trn-doc.internal no-undo .
define variable v-pay-code like ub.trn-doc.pay-code no-undo .
define variable v-purch-code like ub.trn-doc.purch-code no-undo .
define variable v-status    like ub.trn-doc.status_ no-undo .
define variable v-ps like ub.trn-doc.ps no-undo .
define variable v-mes as character no-undo .
define variable v-entry as character no-undo .
define variable v-doc-kind as character no-undo .
define variable v-doc-kind-label as character no-undo .
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-down-pay like ub.shop.down-pay no-undo .
define variable ii as integer no-undo .
define variable v-doc-code-parameter as character no-undo .
define variable v-cntxt-userid as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.

&scop sale-add-kind p-doc-kind
&scop sale-doc-kind p-doc-kind

_main:
do
on error undo, return error return-value
:

  if lookup(p-doc-kind, {&sale-all-doc-kinds}) = 0 then do:
    v-mes = substitute("Неизвестный вид автодокумента &1 для продажи &2"
                      , p-doc-kind
                      , buf_main_trn-doc.doc-code
                      ).
    undo _main, return error v-mes.
  end.
  if p-doc-kind = {&TDEDT_Ras_Vnesh_Kass}
  and p-office = {&gds-goods}
  then do:
    v-mes = substitute("Автодокумент &1 для продажи товаров типа &2 с номером &3 должен быть создан вместе с продажей"
                      , p-doc-kind
                      , {&gds-goods}
                      , buf_main_trn-doc.doc-code
                      ).
    undo _main, return error v-mes.
  end.

  if not available buf_main_trn-doc then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Нет записи в буфере-параметре при вызове")
    view-as alert-box error .
    undo _main, return error .
  end.
  if buf_main_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_Kass} then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Неверный расш. тип докум &1 &2 в буфере-параметре при вызове"
               , buf_main_trn-doc.doc-code
               , buf_main_trn-doc.ext-doc-type)
    view-as alert-box error .
    undo _main, return error .
  end.

  assign
    v-doc-code-parameter = {&sale-doc-kind-born} + (if p-office = {&gds-office} then "_s" else "":U)
  no-error .
  if error-status:error then do:
    message
    vss-workfile vss-revision vss-description skip
    substitute("Неверно определено или не определено правило создания номера документа для дополнительного документа по продаже вида &1"
                , {&sale-doc-name}
               )
    view-as alert-box error .
    undo _main, return error .
  end.
  run doc-code in this-procedure
      (input v-doc-code-parameter
      ,input buf_main_trn-doc.obj-type
      ,input buf_main_trn-doc.obj-code
      ,input buf_main_trn-doc.doc-code
      ,output p-doc-code ) no-error.
  if error-status:error then do:
    v-mes = substitute("Ошибка при генерации номера дополнительного документа вида &5 для продажи &4:&1&2 &3"
                      , {&new-line}
                      , error-status:get-message(1)
                      , return-value
                      , buf_main_trn-doc.doc-code
                      , p-doc-kind
                      ).
    undo _main, return error v-mes.
  end.
  find first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = p-doc-code
        AND buf_trn-doc.out-code = buf_main_trn-doc.doc-code no-error .
  if locked buf_trn-doc then do:
    return 'locked':U.
  end.
  else do:
    if available buf_trn-doc then return.
  end.
  if lookup(p-doc-kind, {&sale-add-kinds}) > 0 and p-cli-code = 0 and p-cli-type = "" then do: /* проверил, что это не атрибут платежа */
    /*найдем контрагента*/
    run adm/shattri.p (
        input "get":U
        ,input  buf_main_trn-doc.obj-type
        ,input  buf_main_trn-doc.obj-code
        ,input  {&attr-autosale}
        ,input  {&attr-autosale_sale-add} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output  v-value-decimal
        ,output  v-value-integer
        ,output  v-value-logical
        ,output par-type /*p-param-value*/
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    v-mes = substitute("Ошибка при определении контрагента дополнительного документа вида &5 для продажи &4:&1&2 &3"
                      , {&new-line}
                      , error-status:get-message(1)
                      , return-value
                      , buf_main_trn-doc.doc-code
                      , {&sale-doc-name}
                      ).
    if error-status:error
    then do:
      delete object v-tth.
      undo _main, return error v-mes.
    end.
    delete object v-tth.
    _ii:
    do ii = 1 to num-entries(v-value-character, ';':U):
      assign
        v-entry =  ENTRY(ii, v-value-character, ';':U)
        v-doc-kind = ENTRY(1, v-entry)
        v-cli-type = ENTRY(2, v-entry)
        v-cli-code = integer(ENTRY(3, v-entry))
      .
      assign
        v-doc-kind-label = {&sale-doc-name}
      no-error .

      if v-doc-kind = p-doc-kind then do:
        leave _ii.
      end.
    end. /*do ii*/
    if v-cli-type = '':U
    or v-cli-code = 0 then do:
      v-mes = substitute("Ошибка при определении контрагента дополнительного документа вида &5 для продажи &4:&1&2 &3"
                        , {&new-line}
                        , error-status:get-message(1)
                        , "Контрагент не задан - задайте контрагента (АРМ Администратор-Справочники-Магазины-Параметры-Опции работы с продажей"
                        , buf_main_trn-doc.doc-code
                        , {&sale-doc-name}
                        ).
      if error-status:error
      then do:
        undo _main, return error v-mes.
      end.
    end.
    find first buf_clients no-lock where buf_clients.obj-type  = v-cli-type
                                     and buf_clients.obj-code  = v-cli-code
    no-error .
    if not available buf_clients then do:
      undo _main, return error v-mes.
    end.
  end. /* if lookup(p-doc-kind, {&sale-add-kinds}) > 0 then do: если дополнительный длокумента продажи*/
  v-ps = substitute('&1&2 &1&3&1 Кол-во_чеков 0&1строк_чеков 0&1 товаров 0&1признаков 0&1'
                    , {&delim-par}
                    , (if buf_main_trn-doc.office then "УСЛУГИ." else "ТОВАРЫ." )
                    , {&sale-doc-name}
                    ).
  CASE p-doc-kind:
    when {&TDEDT_Ras_Vnesh_Kass} then do:
      v-mes = '':U.
      assign
        v-ext-doc-type       = {&TDEDT_Ras_Vnesh_Kass}
        v-doc-type           = {&expense}
        v-cli-type = buf_main_trn-doc.cli-type
        v-cli-code = buf_main_trn-doc.cli-code
        v-cli-name           = buf_main_trn-doc.cli-name
        v-internal = no
        v-pay-code = buf_main_trn-doc.pay-code
        v-status   = (if buf_main_trn-doc.status_ = {&inquiry}
                      then {&inquiry}
                      else {&cash-desk})
        v-purch-code  = buf_main_trn-doc.purch-code
        v-discnt-type = {&cash-desk}
      .
    end.
    when {&TDEDT_Vozvrat_Vnesh_Kass} then do:
      v-mes = '':U.
      assign
        v-ext-doc-type       = {&TDEDT_Vozvrat_Vnesh_Kass}
        v-doc-type           = {&return}
        v-cli-type = buf_main_trn-doc.cli-type
        v-cli-code = buf_main_trn-doc.cli-code
        v-cli-name           = buf_main_trn-doc.cli-name
        v-internal = no
        v-pay-code = buf_main_trn-doc.pay-code
        v-status   = (if buf_main_trn-doc.status_ = {&inquiry}
                      then {&inquiry}
                      else {&cash-desk})
        v-purch-code  = buf_main_trn-doc.purch-code
        v-discnt-type = {&cash-desk}
      .
    end.
    when {&sale-add-tech-refuell}
    or
    when {&sale-add-return-write-off}
    or
    when {&sale-add-write-off}
    or
    when {&sale-add-vir-res}
    then do:
      case buf_main_trn-doc.obj-type :
        when {&shop} then do:
          find first buf_shop no-lock where
                  buf_shop.obj-code = buf_main_trn-doc.obj-code.
          v-down-pay = buf_shop.down-pay.
        end.
        when {&stock} then do:
          find first buf_store no-lock where
                  buf_store.obj-code = buf_main_trn-doc.obj-code.
          v-down-pay = buf_store.down-pay.
        end.
      END CASE.
      v-mes = '':U.
      assign
        v-ext-doc-type       = entry(lookup(p-doc-kind, {&sale-add-kinds}), {&sale-add-ext-doc-types})
        v-cli-name           = if available(buf_clients) then buf_clients.obj-name else ''
        v-internal = no
        v-pay-code = v-down-pay
        v-ps = '':U
        v-status   = (if buf_main_trn-doc.status_ = {&inquiry}
                then {&inquiry}
                else {&doc-froze})
        v-purch-code  = ?
        v-discnt-type = {&row}
      .
      v-doc-type = if p-doc-kind = {&sale-add-vir-res} then {&expense} else {&write-off}.
    end.
  END CASE.
  
  /* Контрагент при создании доп. док-та по атрибуту типа платежа */
  if p-cli-type <> "" and p-cli-code > 0 then do:
    for first buf_clients no-lock where buf_clients.obj-type = p-cli-type
                                    and buf_clients.obj-code = p-cli-code
    :
      assign
        v-cli-type = buf_clients.obj-type
        v-cli-code = buf_clients.obj-code
        v-cli-name = buf_clients.obj-name
      .
    end.
  end. /*  if p-cli-type */

  { str/crtrndoc.i
    ?
    ?
    buf_main_trn-doc.base-rate
    buf_main_trn-doc.base-scale
    v-cli-code
    v-cli-type
    v-cli-name
    buf_main_trn-doc.cr-db-num
    g#userid
    v-discnt-type
    p-doc-code
    buf_main_trn-doc.doc-date
    v-doc-type
    no
    buf_main_trn-doc.host-code
    v-internal
    buf_main_trn-doc.obj-code
    buf_main_trn-doc.obj-type
    buf_main_trn-doc.office
    v-pay-code
    v-ps
    no
    ?
    v-status
    ?
    v-ext-doc-type
    v-purch-code
    no-error
  }
  if error-status:error then do:
    v-mes = substitute("Ошибка при генерации автодокумента вида &5 для продажи &4:&1&2 &3"
                      , {&new-line}
                      , error-status:get-message(1)
                      , return-value
                      , buf_main_trn-doc.doc-code
                      , p-doc-kind
                      ).
    undo _main, return error v-mes.
  end.

  find buf_trn-doc where buf_trn-doc.doc-code = p-doc-code.
  assign
    buf_trn-doc.fact-date  = buf_main_trn-doc.fact-date
    buf_trn-doc.shift-date = buf_main_trn-doc.shift-date
    buf_trn-doc.shift-num  = buf_main_trn-doc.shift-num
    buf_trn-doc.shift-name = buf_main_trn-doc.shift-name
    buf_trn-doc.exch-code  = buf_main_trn-doc.exch-code
    buf_trn-doc.exch-rate  = buf_main_trn-doc.exch-rate
    buf_trn-doc.exch-scale = buf_main_trn-doc.exch-scale
    buf_trn-doc.print-rubl = buf_main_trn-doc.print-rubl
    buf_trn-doc.out-code   = buf_main_trn-doc.doc-code
    buf_trn-doc.office     = (if p-office = {&gds-office} then yes else no)
    buf_main_trn-doc.out-code = (if (p-doc-kind = {&TDEDT_Vozvrat_Vnesh_kass} and p-office = {&gds-goods}) then buf_trn-doc.doc-code else buf_main_trn-doc.out-code)
    buf_trn-doc.wrkr = buf_main_trn-doc.wrkr
    buf_trn-doc.agnt = buf_main_trn-doc.agnt
    buf_trn-doc.boss = buf_main_trn-doc.boss
  .
  /* для техпролива и списания ставим атрибут другое перемещение для доп.документа */
  if p-doc-kind = {&sale-add-write-off} or
     p-doc-kind = {&sale-add-tech-refuell}   
  then do:
     { str/tdat-wrt.i                                    
          buf_trn-doc.doc-code
          {&trdcattr-othermoves}
          "yes" 
       no-error}
  end.           
  run saledoc-create  in this-procedure (
                                           input buf_main_trn-doc.doc-code
                                          ,input buf_main_trn-doc.host-code
                                          ,input buf_main_trn-doc.obj-type
                                          ,input buf_main_trn-doc.obj-code
                                          ,input p-doc-kind
                                          ,input p-office
                                          ,input no /*p-tpsidoc*/
                                          ,input '':U /*p-alias-type-type*/
                                          ,input '':U /*p-price-obj-type*/
                                          ,input 0 /*p-price-obj-code*/
                                          ,buffer buf_trn-doc ) no-error .
  if error-status:error then do:
    undo, return error substitute("Ошибка записи данных автодокумента вида &5 для продажи &4 во временную таблицу:&1&2 &3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  , buf_main_trn-doc.doc-code
                                  , p-doc-kind
                                  ).
  end.
end. /*doe*/