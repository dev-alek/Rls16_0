block-level on error undo, throw.
/*

$Revision: 66c80260f80d, 2644, rls $
$Author: SSlivenko $
$Date: 2020/10/23 18:03:38 $
$Workfile: pstlnadd.p $
$Archive: str/pstlnadd.p $

Добавление связки пересортицы

Автор: Чернова Светлана Александровна
Дата создания: 09/12/07
Author: Svetlana Chernova
Creation date: 09/12/07

Автор1: Суслов Алексей Юрьевич
Дата создания: 05/18/06

*/
define variable vss-revision    as character no-undo initial "$Revision: 66c80260f80d, 2644, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2020/10/23 18:03:38 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: pstlnadd.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/pstlnadd.p $":U .
define variable vss-description as character no-undo initial "Добавление связки пересортицы":U .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/peresort.i }


define input  parameter parparentproc      as   handle              no-undo.
define input  parameter parcallback        as   handle              no-undo.
define input  parameter pardoc-code        like ub.trn-doc.doc-code no-undo.
define input  parameter parold-supp-cntr   as   logical             no-undo.
define input  parameter parpstunqtn-log    as   logical             no-undo.
define input  parameter parmxpcicp-dec     as   decimal             no-undo.
define input  parameter parmxpcdcp-dec     as   decimal             no-undo.
define input  parameter parmxsmicp-dec     as   decimal             no-undo.
define input  parameter parmxsmdcp-dec     as   decimal             no-undo.
define input  parameter pargrp-is-eq       as   logical             no-undo.
define input  parameter parpstunit         as   logical             no-undo.
define output parameter parrec-minus-line  as   recid               no-undo.
define output parameter parrec-plus-line   as   recid               no-undo.
define output parameter paradd             as   logical initial no  no-undo.
define variable varoutgds-code           like ub.goods.gds-code  no-undo.
define variable varoutgds-code-plus      like ub.goods.gds-code  no-undo.
define variable varoutqnty               as   decimal            no-undo.
define variable varoutqnty-plus          as   decimal            no-undo.
define variable varoutqnty-kg            as   decimal            no-undo.
define variable varoutqnty-kg-plus       as   decimal            no-undo.
define variable varset                   as   logical            no-undo.
define variable varvat-pc                as   decimal            no-undo.
define variable varvat-pc-plus           as   decimal            no-undo.
define variable vartax-date              as   date               no-undo.
define variable varmem-qnty              as   decimal            no-undo.
define variable varchg-qnty              as   decimal            no-undo.
define variable varqnty-check            as   decimal            no-undo.
define variable varqnty-check-plus       as   decimal            no-undo.
define variable varqnty-check-pl         as   decimal            no-undo.
define variable varqnty-check-pl-plus    as   decimal            no-undo.
define variable varqnty-check-pl-kg      as   decimal            no-undo.
define variable varqnty-check-pl-kg-plus as   decimal            no-undo.
define variable varkoeff                 as   decimal            no-undo.
define variable varpart-code             as   character          no-undo.
define variable varlog                   as   logical            no-undo.
define variable varinv-on                as   logical            no-undo.
define variable varshift-on              as   logical            no-undo.
define variable varfact-order            as   decimal            no-undo.
define variable varshift-fo              as   decimal            no-undo.
define variable varday-fo                as   decimal            no-undo.
define variable varis-petrol             as   logical            no-undo.
define variable varis-pieces             as   logical            no-undo.
define variable varis-petrol-plus        as   logical            no-undo.
define variable varis-pieces-plus        as   logical            no-undo.
define variable varrsrv-plus-parts       as   logical            no-undo.
define variable varunrsrv-qnty-pl        as   decimal            no-undo.
define variable varcrparts-qnty          as   decimal            no-undo.
define variable vardensity-reserv        as   decimal            no-undo.
define variable varcli-base-rate-reserv  as   decimal            no-undo.
define variable varprice-reserv          as   decimal            no-undo.
define variable varcorrect               as   logical            no-undo.
define variable varqnty-pieces           as   decimal            no-undo.
define variable varpices-varkoeff        as   decimal            no-undo.

define variable vartotal-rsrv-qnty-parts   like ub.parts.fact-qnty  no-undo.
define variable vartotal-rsrv-qnty-gds-dtl like ub.gds-dtl.doc-qnty no-undo.
define variable varbefore-qnty             like ub.gds-dtl.doc-qnty no-undo.
define buffer bf_trn-doc           for ub.trn-doc.
define buffer bf-add_goods         for ub.goods.
define buffer bf-add-plus_goods    for ub.goods.
define buffer bf-add_doc-line      for ub.doc-line.
define buffer bf-add_inv-line      for ub.inv-line.
define buffer bf-add-plus_doc-line for ub.doc-line.
define buffer bf-add-plus_inv-line for ub.inv-line.
define buffer bf-add_parts-root    for ub.parts-root.
define buffer bf-add-cr_parts-root for ub.parts-root.
define buffer bf-add_parts         for ub.parts.
define buffer bf-add-plus_parts    for ub.parts.
define buffer bf-add_gds-dtl       for ub.gds-dtl.
define buffer bf-add-plus_gds-dtl  for ub.gds-dtl.
define buffer bf-inv_doc-line      for ub.doc-line.
define buffer bf_sysconf           for ub.sysconf.
define buffer bf-add_doc-pl        for ub.doc-pl.
define buffer bf-add-plus_doc-pl   for ub.doc-pl.
define buffer bf_parts-root        for ub.parts-root.
define temp-table tt-parts       no-undo like ub.parts.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code.
find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
for each tt-gds-dtl on error undo, return error return-value :
  delete tt-gds-dtl.
end.
for each tt-pl-qty on error undo, return error return-value :
  delete tt-pl-qty.
end.
for each tt-gds-dtl-plus on error undo, return error return-value :
  delete tt-gds-dtl-plus.
end.
for each tt-pl-qty-plus on error undo, return error return-value :
  delete tt-pl-qty-plus.
end.
run str/prst-gds.w (input  parparentproc,
                input  bf_trn-doc.doc-code,
                input  {&add-def},
                input  bf_trn-doc.obj-type,
                input  bf_trn-doc.obj-code,
                input  ?,
                input  ?,
                input  ?,
                input  ?,
                input  ?,
                input  ?,
                input  parpstunqtn-log,
                input  parpstunit,
                input  parmxpcicp-dec,
                input  parmxpcdcp-dec,
                input  parmxsmicp-dec,
                input  parmxsmdcp-dec,
                output varoutgds-code,
                output varoutgds-code-plus,
                output table tt-gds-dtl,
                output table tt-pl-qty,
                output varoutqnty,
                output varoutqnty-plus,
                output varoutqnty-kg,
                output varoutqnty-kg-plus,
                output table tt-gds-dtl-plus,
                output table tt-pl-qty-plus,
                output varset) no-error.
if varset = yes then do transaction on error undo, return error return-value :
  assign
    paradd = yes.
  find first bf-add_goods where bf-add_goods.gds-code = varoutgds-code no-lock no-error.
  if not available bf-add_goods then do:
    undo, return error substitute ("Не найден товар для списания с внутренним кодом: &1.", varoutgds-code).
  end.
  find first bf-add-plus_goods where bf-add-plus_goods.gds-code = varoutgds-code-plus no-lock no-error.
  if not available bf-add-plus_goods then do:
    undo, return error substitute ("Не найден товар для оприходования с внутренним кодом: &1.", varoutgds-code).
  end.
  if bf-add_goods.grp-code <> bf-add-plus_goods.grp-code and pargrp-is-eq then
    undo, return error "Включен параметр pstgrp(Запрещена пересортица товаров из разных групп) из секции настроек ИНВЕНТАРИЗАЦИИ. Товары можно добавлять только из одной группы".
  if not (varoutqnty > 0) /*<= или ?*/ then do:
    undo, return error substitute ("Неверно задано количество по списываемому товару: &1.", varoutqnty).
  end.
  if not (varoutqnty-plus > 0) /*<= или ?*/ then do:
    undo, return error substitute ("Неверно задано количество по оприходуемому товару: &1.", varoutqnty-plus).
  end.
  { str/is-petrl.i
    bf-add_goods.artic
    bf-add_goods.prod-type
    bf-add_goods.prod-code
    varis-petrol
    varis-pieces
  }
  { str/is-petrl.i
    bf-add-plus_goods.artic
    bf-add-plus_goods.prod-type
    bf-add-plus_goods.prod-code
    varis-petrol-plus
    varis-pieces-plus
  }
  if varis-petrol     and
     not varis-pieces then do:
    if not (varoutqnty-kg > 0) /*<= или ?*/ then do:
      undo, return error substitute ("Неверно задано количество по списываемому товару в килограммах: &1.", varoutqnty-kg).
    end.
  end.
  if varis-petrol-plus     and
     not varis-pieces-plus then do:
    if not (varoutqnty-kg-plus > 0) /*<= или ?*/ then do:
      undo, return error substitute ("Неверно задано количество по оприходуемому товару в килограммах: &1.", varoutqnty-kg-plus).
    end.
  end.

  assign
    varqnty-check            = 0.00
    varqnty-check-plus       = 0.00
    varqnty-check-pl         = 0.00
    varqnty-check-pl-plus    = 0.00
    varqnty-check-pl-kg      = 0.00
    varqnty-check-pl-kg-plus = 0.00
    .
  for each tt-gds-dtl on error undo, return error return-value :
    if tt-gds-dtl.gds-code <> bf-add_goods.gds-code then do:
      undo, return error substitute ("Критическая ошибка. В признаках для списания товара указан товар с внутренним кодом: &1. Товар для списания с внутренним кодом: &2", tt-gds-dtl.gds-code, bf-add_goods.gds-code).
    end.
    assign
      varqnty-check = varqnty-check + tt-gds-dtl.qnty.
  end.

  for each tt-gds-dtl-plus on error undo, return error return-value :
    if tt-gds-dtl-plus.gds-code <> bf-add-plus_goods.gds-code then do:
      undo, return error substitute ("Критическая ошибка. В признаках для оприходования товара указан товар с внутренним кодом: &1. Товар для оприходования с внутренним кодом: &2.", tt-gds-dtl-plus.gds-code, bf-add-plus_goods.gds-code).
    end.
    assign
      varqnty-check-plus = varqnty-check-plus + tt-gds-dtl-plus.qnty.
  end.
  if varoutqnty <> varqnty-check then do:
    undo, return error substitute ("Ошибка в количестве по списываемому товару: &1 &2 &3 &4. Задано количество по товару: &5. Задано количество по признакам: &6.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, varoutqnty, varqnty-check) .
  end.
  if varoutqnty-plus <> varqnty-check-plus then do:
    undo, return error substitute("Ошибка в количестве по оприходоваемому товару: &1 &2 &3 &4. Задано количество по товару: &5. Задано количество по признакам: &6.", bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name, varoutqnty-plus, varqnty-check-plus).
  end.
  if varis-petrol     and
     not varis-pieces then do:
    for each tt-pl-qty on error undo, return error return-value :
      assign
        varqnty-check-pl    = varqnty-check-pl    + tt-pl-qty.qnty-l
        varqnty-check-pl-kg = varqnty-check-pl-kg + tt-pl-qty.qnty-kg.
    end.
    if varoutqnty <> varqnty-check-pl then do:
      undo, return error substitute ("Ошибка в количестве по списываемому товару: &1 &2 &3 &4. Задано количество по товару: &5. Задано количество по резервуарам: &6.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, varoutqnty, varqnty-check-pl) .
    end.
    if varoutqnty-kg <> varqnty-check-pl-kg then do:
      undo, return error substitute ("Ошибка в количестве в кг по списываемому товару: &1 &2 &3 &4. Задано количество по товару: &5. Задано количество по резервуарам: &6.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, varoutqnty-kg, varqnty-check-pl-kg) .
    end.
  end.
  if varis-petrol-plus     and
     not varis-pieces-plus then do:
    for each tt-pl-qty-plus on error undo, return error return-value :
      assign
        varqnty-check-pl-plus    = varqnty-check-pl-plus    + tt-pl-qty-plus.qnty-l
        varqnty-check-pl-kg-plus = varqnty-check-pl-kg-plus + tt-pl-qty-plus.qnty-kg.
    end.
    if varoutqnty-plus <> varqnty-check-pl-plus then do:
      undo, return error substitute("Ошибка в количестве по оприходоваемому товару: &1 &2 &3 &4. Задано количество по товару: &5. Задано количество по резервуарам: &6.", bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name, varoutqnty-plus, varqnty-check-pl-plus).
    end.
    if varoutqnty-kg-plus <> varqnty-check-pl-kg-plus then do:
      undo, return error substitute("Ошибка в количестве в кг по оприходоваемому товару: &1 &2 &3 &4. Задано количество по товару: &5. Задано количество по резервуарам: &6.", bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name, varoutqnty-kg-plus, varqnty-check-pl-kg-plus).
    end.
  end.
  assign
    varkoeff = varoutqnty-plus / varoutqnty.
  /*Недопустимо если уже есть связка товар1-товар2, делать связку товар2-товар1*/
  find first bf-add_parts-root where bf-add_parts-root.doc-code      = bf_trn-doc.doc-code        and
                                     bf-add_parts-root.orig-gds-code = bf-add-plus_goods.gds-code and
                                     bf-add_parts-root.gds-code      = bf-add_goods.gds-code      use-index pi no-error.
  if available bf-add_parts-root then do:
    return error substitute ("Для списания выбран товар: &1 &2 &3 &4. Для оприходывания выбран товар: &5 &6 &7 &8. Но уже есть связка когда списываемый товар оприходуется, а оприходуемый списывается. Это недопустимо.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name ).
  end.
  /*Уже есть такая же связка, тогда редактирование*/
  find first bf-add_parts-root where bf-add_parts-root.doc-code      = bf_trn-doc.doc-code        and
                                     bf-add_parts-root.orig-gds-code = bf-add_goods.gds-code      and
                                     bf-add_parts-root.gds-code      = bf-add-plus_goods.gds-code use-index pi no-error.
  if available bf-add_parts-root then do:
    /*редактирование*/
    assign
      varlog = no.
    message "В документе уже есть связка по пересортице выбранных товаров." skip
            "Вы хотите добавить к существующей пересортице установленные количества?"
     view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then do:
      return error.
    end.
  end.
  else do:
    /*простое добавление*/
    if bf_trn-doc.fact-date <> ?
    then do:
      assign
        vartax-date = bf_trn-doc.fact-date
      .
    end.
    else do:
      assign
        vartax-date = ?
      .
    end.
    if bf_sysconf.cons-vat-pc = ? then do:
      undo, return error substitute ("У Вас не установлен НДС для консигнационного товара по фирме.").
    end.
    find first bf-add_doc-line where bf-add_doc-line.doc-code  = bf_trn-doc.doc-code     and
                                     bf-add_doc-line.artic     = bf-add_goods.artic      and
                                     bf-add_doc-line.prod-type = bf-add_goods.prod-type  and
                                     bf-add_doc-line.prod-code = bf-add_goods.prod-code  exclusive-lock no-error.
    if not available bf-add_doc-line then do:
      { str/chkgdsd.i
        recid(bf_trn-doc)
        recid(bf-add_goods)
        no-error
      }
      if error-status :error then do:
        /*message error-status:get-message(1) view-as alert-box.*/
        undo, return error substitute ("Ошибка проверки включения товара в документ. Документ &1 Объект &2 &3 Товар &4 &5 &6 - << &7 >>", bf_trn-doc.doc-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, return-value).
      end.
      /*проверяем нет ли инвентаризаций наперед*/
      if bf_trn-doc.fact-date <> ? then do:
        { gbl/objat.i
          bf_trn-doc.obj-type
          bf_trn-doc.obj-code
          "'shift-on=request'"
          varshift-on
          no-error
        }

        run factord in parcallback (  input bf_trn-doc.fact-date,
                                      input bf_trn-doc.fact-time,
                                      input current-value( s-trn-fact, {&db-name_schema} ),
                                      input bf_trn-doc.shift-date,
                                      input bf_trn-doc.shift-num,
                                      input varshift-on,
                                     output varfact-order,
                                     output varshift-fo,
                                     output varday-fo   ) no-error.

        if error-status:error then do:
          return error substitute ("Ошибка при определении fact-order для документа закрываемого задним числом &1. ", return-value).
        end.
        for first bf-inv_doc-line where bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type       and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code       and
                                        bf-inv_doc-line.prod-type    = bf-add_goods.prod-type    and
                                        bf-inv_doc-line.prod-code    = bf-add_goods.prod-code    and
                                        bf-inv_doc-line.artic        = bf-add_goods.artic        and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Inv}              and
                                        bf-inv_doc-line.status_      = {&fact}                   and
                                        bf-inv_doc-line.fact-order   > varfact-order             or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type       and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code       and
                                        bf-inv_doc-line.prod-type    = bf-add_goods.prod-type    and
                                        bf-inv_doc-line.prod-code    = bf-add_goods.prod-code    and
                                        bf-inv_doc-line.artic        = bf-add_goods.artic        and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Peresort}         and
                                        bf-inv_doc-line.status_      = {&fact}                   and
                                        bf-inv_doc-line.fact-order   > varfact-order             or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type       and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code       and
                                        bf-inv_doc-line.prod-type    = bf-add_goods.prod-type    and
                                        bf-inv_doc-line.prod-code    = bf-add_goods.prod-code    and
                                        bf-inv_doc-line.artic        = bf-add_goods.artic        and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Corr_Acc_Price}   and
                                        bf-inv_doc-line.status_      = {&fact}                   and
                                        bf-inv_doc-line.fact-order   > varfact-order             or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type       and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code       and
                                        bf-inv_doc-line.prod-type    = bf-add_goods.prod-type    and
                                        bf-inv_doc-line.prod-code    = bf-add_goods.prod-code    and
                                        bf-inv_doc-line.artic        = bf-add_goods.artic        and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Chg_Purch_Code}   and
                                        bf-inv_doc-line.status_      = {&fact}                   and
                                        bf-inv_doc-line.fact-order   > varfact-order             or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type       and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code       and
                                        bf-inv_doc-line.prod-type    = bf-add_goods.prod-type    and
                                        bf-inv_doc-line.prod-code    = bf-add_goods.prod-code    and
                                        bf-inv_doc-line.artic        = bf-add_goods.artic        and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Corr_Minus_Parts} and
                                        bf-inv_doc-line.status_      = {&fact}                   and
                                        bf-inv_doc-line.fact-order   > varfact-order             on error undo, return error return-value :
          return error substitute ("По товару &1 &2 &3 есть документ типа инвентаризация &4 более поздней датой", bf-inv_doc-line.artic, bf-inv_doc-line.prod-type, bf-inv_doc-line.prod-code, bf-inv_doc-line.doc-code).
        end.
      end.
      /*Выставляем флаг - товар в инвентаризации*/
      { gbl/gdsobjat.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        bf-add_goods.artic
        bf-add_goods.prod-type
        bf-add_goods.prod-code
        "'inv-on=true'"
        varinv-on
        no-error
      }
      if error-status :error then do:
        undo, return error substitute ("Ошибка установки атрибута товара на объекте. Документ &1 Объект &2 &3 Артикул &4 &5 &6 признак инвентаризации &7 &8", bf_trn-doc.doc-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, varinv-on, return-value).
      end.
      { gbl/pftxvalg.i
        bf-add_goods.gds-code
        {&vat-tax-code}
        vartax-date
        bf_trn-doc.host-code
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        varvat-pc
        no-error
      }
      if error-status:error then do:
        undo, return error substitute ("Ошибка при определении НДС для товара: &1 &2 &3 &4 на объекте: &5 &6.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      end.
      { str/crdoclin.i
        bf_trn-doc.doc-code
        bf-add_goods.artic
        bf-add_goods.prod-type
        bf-add_goods.prod-code
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        bf_trn-doc.status_
        bf_trn-doc.ext-doc-type
        bf-add_goods.prt-root
        varvat-pc
        0
        bf_sysconf.cons-vat-pc
        no-error
      }
      if error-status:error then do:
        undo, return error substitute ("Ошибка при создании строки для товара: &1 &2 &3 &4 на объекте: ", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      end.
      find first bf-add_doc-line where bf-add_doc-line.doc-code  = bf_trn-doc.doc-code     and
                                       bf-add_doc-line.artic     = bf-add_goods.artic      and
                                       bf-add_doc-line.prod-type = bf-add_goods.prod-type  and
                                       bf-add_doc-line.prod-code = bf-add_goods.prod-code  exclusive-lock.
       assign
         bf-add_doc-line.fact-qnty = 0.00
         bf-add_doc-line.cli-qnty  = 0.00.
      if varis-petrol     and
         not varis-pieces then do:
        find first bf-add_inv-line where bf-add_inv-line.doc-code  = bf-add_doc-line.doc-code  and
                                         bf-add_inv-line.artic     = bf-add_doc-line.artic     and
                                         bf-add_inv-line.prod-type = bf-add_doc-line.prod-type and
                                         bf-add_inv-line.prod-code = bf-add_doc-line.prod-code .
        assign
          bf-add_inv-line.wast-cli-qnty  = 0.00
          bf-add_inv-line.after-cli-qnty = 0.00.
      end.
    end.
    find first bf-add-plus_doc-line where bf-add-plus_doc-line.doc-code  = bf_trn-doc.doc-code          and
                                          bf-add-plus_doc-line.artic     = bf-add-plus_goods.artic      and
                                          bf-add-plus_doc-line.prod-type = bf-add-plus_goods.prod-type  and
                                          bf-add-plus_doc-line.prod-code = bf-add-plus_goods.prod-code  exclusive-lock no-error.
    if not available bf-add-plus_doc-line then do:
      { str/chkgdsd.i
        recid(bf_trn-doc)
        recid(bf-add-plus_goods)
        no-error
      }
      if error-status :error then do:
        undo, return error substitute ("Ошибка проверки включения товара в документ. Документ &1 Объект &2 &3 Артикул &4 &5 &6: &7", bf_trn-doc.doc-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, return-value).
      end.
      /*проверяем нет ли инвентаризаций наперед*/
      if bf_trn-doc.fact-date <> ? then do:
        for first bf-inv_doc-line where bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type         and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code         and
                                        bf-inv_doc-line.prod-type    = bf-add-plus_goods.prod-type and
                                        bf-inv_doc-line.prod-code    = bf-add-plus_goods.prod-code and
                                        bf-inv_doc-line.artic        = bf-add-plus_goods.artic     and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Inv}                and
                                        bf-inv_doc-line.status_      = {&fact}                     and
                                        bf-inv_doc-line.fact-order   > varfact-order               or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type         and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code         and
                                        bf-inv_doc-line.prod-type    = bf-add-plus_goods.prod-type and
                                        bf-inv_doc-line.prod-code    = bf-add-plus_goods.prod-code and
                                        bf-inv_doc-line.artic        = bf-add-plus_goods.artic     and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Peresort}           and
                                        bf-inv_doc-line.status_      = {&fact}                     and
                                        bf-inv_doc-line.fact-order   > varfact-order               or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type         and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code         and
                                        bf-inv_doc-line.prod-type    = bf-add-plus_goods.prod-type and
                                        bf-inv_doc-line.prod-code    = bf-add-plus_goods.prod-code and
                                        bf-inv_doc-line.artic        = bf-add-plus_goods.artic     and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Corr_Acc_Price}     and
                                        bf-inv_doc-line.status_      = {&fact}                     and
                                        bf-inv_doc-line.fact-order   > varfact-order               or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type         and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code         and
                                        bf-inv_doc-line.prod-type    = bf-add-plus_goods.prod-type and
                                        bf-inv_doc-line.prod-code    = bf-add-plus_goods.prod-code and
                                        bf-inv_doc-line.artic        = bf-add-plus_goods.artic     and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Chg_Purch_Code}     and
                                        bf-inv_doc-line.status_      = {&fact}                     and
                                        bf-inv_doc-line.fact-order   > varfact-order               or
                                        bf-inv_doc-line.obj-type     = bf_trn-doc.obj-type         and
                                        bf-inv_doc-line.obj-code     = bf_trn-doc.obj-code         and
                                        bf-inv_doc-line.prod-type    = bf-add-plus_goods.prod-type and
                                        bf-inv_doc-line.prod-code    = bf-add-plus_goods.prod-code and
                                        bf-inv_doc-line.artic        = bf-add-plus_goods.artic     and
                                        bf-inv_doc-line.ext-doc-type = {&TDEDT_Corr_Minus_Parts}      and
                                        bf-inv_doc-line.status_      = {&fact}                        and
                                        bf-inv_doc-line.fact-order   > varfact-order                  on error undo, return error return-value :
          return error substitute ("По товару &1 &2 &3 есть документ типа инвентаризация &4 более поздней датой.", bf-inv_doc-line.artic, bf-inv_doc-line.prod-type, bf-inv_doc-line.prod-code, bf-inv_doc-line.doc-code).
        end.
      end.

      /*Выставляем флаг - товар в инвентаризации*/
      { gbl/gdsobjat.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        bf-add-plus_goods.artic
        bf-add-plus_goods.prod-type
        bf-add-plus_goods.prod-code
        "'inv-on=true'"
        varinv-on
        no-error
      }
      if error-status :error then do:
        undo, return error substitute ("Ошибка установки атрибута товара на объекте. Документ &1 Объект &2 &3 Артикул &4 &5 &6 признак инвентаризации &7  &8", bf_trn-doc.doc-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, varinv-on, return-value).
      end.
      { gbl/pftxvalg.i
        bf-add-plus_goods.gds-code
        {&vat-tax-code}
        vartax-date
        bf_trn-doc.host-code
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        varvat-pc-plus
        no-error
      }
      if error-status:error then do:
        undo, return error substitute ("Ошибка при определении НДС для товара: &1 &2 &3 &4 на объекте: &5 &6.", bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      end.
      { str/crdoclin.i
        bf_trn-doc.doc-code
        bf-add-plus_goods.artic
        bf-add-plus_goods.prod-type
        bf-add-plus_goods.prod-code
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        bf_trn-doc.status_
        bf_trn-doc.ext-doc-type
        bf-add-plus_goods.prt-root
        varvat-pc-plus
        0
        bf_sysconf.cons-vat-pc
        no-error
      }
      if error-status:error then do:
        undo, return error substitute ("Ошибка при создании строки для товара: &1 &2 &3 &4 на объекте: &5 &6.", bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      end.
      find first bf-add-plus_doc-line where bf-add-plus_doc-line.doc-code  = bf_trn-doc.doc-code         and
                                            bf-add-plus_doc-line.artic     = bf-add-plus_goods.artic     and
                                            bf-add-plus_doc-line.prod-type = bf-add-plus_goods.prod-type and
                                            bf-add-plus_doc-line.prod-code = bf-add-plus_goods.prod-code exclusive-lock.
       assign
         bf-add-plus_doc-line.fact-qnty = 0.00
         bf-add-plus_doc-line.cli-qnty  = 0.00.
      if varis-petrol-plus     and
         not varis-pieces-plus then do:
        find first bf-add-plus_inv-line where bf-add-plus_inv-line.doc-code  = bf-add-plus_doc-line.doc-code  and
                                              bf-add-plus_inv-line.artic     = bf-add-plus_doc-line.artic     and
                                              bf-add-plus_inv-line.prod-type = bf-add-plus_doc-line.prod-type and
                                              bf-add-plus_inv-line.prod-code = bf-add-plus_doc-line.prod-code .
        assign
          bf-add-plus_inv-line.wast-cli-qnty  = 0.00
          bf-add-plus_inv-line.after-cli-qnty = 0.00.
      end.
    end.
  end.
  find first bf-add_doc-line where bf-add_doc-line.doc-code  = bf_trn-doc.doc-code     and
                                   bf-add_doc-line.artic     = bf-add_goods.artic      and
                                   bf-add_doc-line.prod-type = bf-add_goods.prod-type  and
                                   bf-add_doc-line.prod-code = bf-add_goods.prod-code  exclusive-lock.
  assign
    parrec-minus-line = recid(bf-add_doc-line).
  run local-recalc in parcallback (input "old":u,
                                   input recid(bf-add_doc-line),
                                   input yes) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.
  find first bf-add-plus_doc-line where bf-add-plus_doc-line.doc-code  = bf_trn-doc.doc-code          and
                                        bf-add-plus_doc-line.artic     = bf-add-plus_goods.artic      and
                                        bf-add-plus_doc-line.prod-type = bf-add-plus_goods.prod-type  and
                                        bf-add-plus_doc-line.prod-code = bf-add-plus_goods.prod-code  exclusive-lock.
  assign
    parrec-plus-line = recid(bf-add-plus_doc-line).
  for each tt-parts on error undo, return error return-value :
    delete tt-parts.
  end.
  /*Запоминаем уже списанные партии по товару*/
  for each bf-add_parts where bf-add_parts.out-code   = bf_trn-doc.doc-code    and
                              bf-add_parts.obj-type   = bf_trn-doc.obj-type    and
                              bf-add_parts.obj-code   = bf_trn-doc.obj-code    and
                              bf-add_parts.artic      = bf-add_goods.artic     and
                              bf-add_parts.prod-type  = bf-add_goods.prod-type and
                              bf-add_parts.prod-code  = bf-add_goods.prod-code and
                              bf-add_parts.fact-qnty  < 0                      on error undo, return error return-value :
    create tt-parts.
    buffer-copy bf-add_parts to tt-parts.
  end.
  /*Создаем признаки и производим резервирование*/
  for each tt-gds-dtl on error undo, return error return-value :
    { str/crgdsdtl.i
      bf_trn-doc.obj-code
      bf_trn-doc.obj-type
      bf_trn-doc.doc-code
      bf-add_goods.artic
      bf-add_goods.prod-code
      bf-add_goods.prod-type
      tt-gds-dtl.prt-code
      yes
      no-error
    }
    if error-status:error then do:
      undo, return error substitute("Ошибка при создании признака для товара: &1 &2 &3 &4 на объекте: &5 &6.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, tt-gds-dtl.prt-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code ).
    end.
    find first bf-add_gds-dtl where bf-add_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                    bf-add_gds-dtl.artic     = bf-add_goods.artic     and
                                    bf-add_gds-dtl.prod-type = bf-add_goods.prod-type and
                                    bf-add_gds-dtl.prod-code = bf-add_goods.prod-code and
                                    bf-add_gds-dtl.prt-code  = tt-gds-dtl.prt-code    exclusive-lock.
    if varis-petrol     and
       not varis-pieces then do:
      for each tt-pl-qty on error undo, return error return-value :
        assign
          varmem-qnty = - tt-pl-qty.qnty-l
          varchg-qnty = varmem-qnty.
        run trg/rsrv-dtl.p (input parparentproc,
                        {&rsrv-dtl_action_reserv} + ',' + {&rsrv-dtl_negative-check} + "=2" + "," + {&rsrv-dtl_pl-code} + "=" + string(tt-pl-qty.pl-code),
                        buffer bf-add_gds-dtl,
                        input-output varchg-qnty,
                        input-output bf-add_doc-line.price-base,
                        input-output bf-add_doc-line.price-rubl,
                        -1, "") no-error.
        if error-status:error then do:
          undo, return error substitute ("Ошибка при резервировании по товару &1 &2 &3 &4: &5.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, return-value).
        end.
        if varmem-qnty <> varchg-qnty then do:
          undo, return error substitute("Не все количество было зарезервировано по товару: &1 &2 &3 &4. Количество для резервирования: &5. Зарезервированное количество: &6.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, varmem-qnty, varchg-qnty).
        end.
        find first bf-add_doc-pl where bf-add_doc-pl.obj-type = bf_trn-doc.obj-type   and
                                       bf-add_doc-pl.obj-code = bf_trn-doc.obj-code   and
                                       bf-add_doc-pl.pl-code  = tt-pl-qty.pl-code     and
                                       bf-add_doc-pl.out-code = bf_trn-doc.doc-code   and
                                       bf-add_doc-pl.gds-code = bf-add_goods.gds-code no-error.
        if not available bf-add_doc-pl then do:
          create bf-add_doc-pl.
          assign
            bf-add_doc-pl.obj-type = bf_trn-doc.obj-type
            bf-add_doc-pl.obj-code = bf_trn-doc.obj-code
            bf-add_doc-pl.pl-code  = tt-pl-qty.pl-code
            bf-add_doc-pl.out-code = bf_trn-doc.doc-code
            bf-add_doc-pl.gds-code = bf-add_goods.gds-code
          .
        end.
        assign
          bf-add_doc-pl.doc-qnty      = bf-add_doc-pl.doc-qnty + varchg-qnty
          bf-add_doc-pl.fact-qnty     = bf-add_doc-pl.doc-qnty
          bf-add_doc-pl.cli-qnty      = bf-add_doc-pl.cli-qnty + varchg-qnty * (tt-pl-qty.qnty-kg / tt-pl-qty.qnty-l)
          bf-add_doc-pl.cli-doc-qnty  = bf-add_doc-pl.cli-qnty
          bf-add_doc-pl.cli-fact-qnty = bf-add_doc-pl.cli-qnty
        .
        assign
          bf-add_doc-line.cli-qnty  = bf-add_doc-line.cli-qnty  - tt-pl-qty.qnty-kg.
      end.
    end.
    else do:
      assign
        varmem-qnty = - tt-gds-dtl.qnty
        varchg-qnty = varmem-qnty.
      run trg/rsrv-dtl.p (input parparentproc,
                      {&rsrv-dtl_action_reserv} + ',' + {&rsrv-dtl_negative-check} + "=2",
                      buffer bf-add_gds-dtl,
                      input-output varchg-qnty,
                      input-output bf-add_doc-line.price-base,
                      input-output bf-add_doc-line.price-rubl,
                      -1, "") no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при резервировании по товару &1 &2 &3 &4: &5.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, return-value).
      end.
      if varmem-qnty <> varchg-qnty then do:
        undo, return error substitute("Не все количество было зарезервировано по товару: &1 &2 &3 &4. Количество для резервирования: &5. Зарезервированное количество: &6.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, varmem-qnty, varchg-qnty).
      end.
    end.
    { str/set-pr.i
      recid(bf-add_gds-dtl)
      no
      ?
      no-error
    }
    if error-status:error then do:
      undo, return error substitute ("Ошибка при установке цены признака товара: &1 &2 &3 &4 &5 на объекте: &6 &7.", bf-add_goods.artic, bf-add_goods.prod-type, bf-add_goods.prod-code, bf-add_goods.gds-name, tt-gds-dtl.prt-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
    end.
    assign
      bf-add_gds-dtl.doc-qnty   = bf-add_gds-dtl.doc-qnty   - tt-gds-dtl.qnty
      bf-add_doc-line.fact-qnty = bf-add_doc-line.fact-qnty - tt-gds-dtl.qnty
    .
  end.
  /*На всякий случай пройдем по отрезервированым до нашего резервирования партиям и проверим, что они все не испорчены*/
  for each tt-parts on error undo, return error return-value :
    find first bf-add_parts where bf-add_parts.obj-type  = tt-parts.obj-type  and
                                  bf-add_parts.obj-code  = tt-parts.obj-code  and
                                  bf-add_parts.artic     = tt-parts.artic     and
                                  bf-add_parts.prod-type = tt-parts.prod-type and
                                  bf-add_parts.prod-code = tt-parts.prod-code and
                                  bf-add_parts.in-code   = tt-parts.in-code   and
                                  bf-add_parts.out-code  = tt-parts.out-code  and
                                  bf-add_parts.part-code = tt-parts.part-code no-error.
    if not available bf-add_parts then do:
      undo, return error substitute ("До резервирования списанного товара была партия к списанию которой нет после резервирования по этому товару. Партия: Тип объекта &1 Код объекта &2 Товар &3 &4 &5 Код ПН &6 Код документа &7 Код партии &8 Фактическое количество в партии &9.", tt-parts.obj-type, tt-parts.obj-code, tt-parts.artic, tt-parts.prod-type, tt-parts.prod-code, tt-parts.in-code, tt-parts.out-code, tt-parts.part-code, tt-parts.fact-qnty).
    end.
    if bf-add_parts.fact-qnty > tt-parts.fact-qnty then do:
      undo, return error substitute("До резервирования списанного товара была партия количество к списанию в которой было больше после резервирования по этому товару. Партия: Тип объекта &1 Код объекта &2 Товар &3 Код ПН &4 Код документа &5 Код партии &6 Фактическое количество к списанию в партии до резервирования &7 Фактическое количество к списанию в партии после резервирования &8.",
                                    tt-parts.obj-type,
                                    tt-parts.obj-code,
                                    tt-parts.artic + " " +  tt-parts.prod-type + " " + string(tt-parts.prod-code),
                                    tt-parts.in-code,
                                    tt-parts.out-code,
                                    tt-parts.part-code,
                                    tt-parts.fact-qnty,
                                    bf-add_parts.fact-qnty).
    end.
  end.
  run local-recalc in parcallback (input "update":u,
                                   input recid(bf-add_doc-line),
                                   input yes) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.
  run local-recalc in parcallback (input "old":u,
                                   input recid(bf-add-plus_doc-line),
                                   input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.

  /*Порождаем оприходованные партии и создаем оприходованные признаки по тем же поставщикам и договорам*/
  /*Создадим признаки на приходуемый товар*/
  assign
    vartotal-rsrv-qnty-gds-dtl = 0.00.
  for each tt-gds-dtl-plus on error undo, return error return-value :
    { str/crgdsdtl.i
      bf_trn-doc.obj-code
      bf_trn-doc.obj-type
      bf_trn-doc.doc-code
      bf-add-plus_goods.artic
      bf-add-plus_goods.prod-code
      bf-add-plus_goods.prod-type
      tt-gds-dtl-plus.prt-code
      yes
      no-error
    }
    if error-status:error then do:
      undo, return error substitute ("Ошибка при создании признака для товара: &1 &2 &3 &4 &5 на объекте: &6 &7.", bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name, tt-gds-dtl-plus.prt-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
    end.
    find first bf-add-plus_gds-dtl where bf-add-plus_gds-dtl.doc-code  = bf_trn-doc.doc-code         and
                                         bf-add-plus_gds-dtl.artic     = bf-add-plus_goods.artic     and
                                         bf-add-plus_gds-dtl.prod-type = bf-add-plus_goods.prod-type and
                                         bf-add-plus_gds-dtl.prod-code = bf-add-plus_goods.prod-code and
                                         bf-add-plus_gds-dtl.prt-code  = tt-gds-dtl-plus.prt-code    exclusive-lock.
    assign
      varbefore-qnty = bf-add-plus_gds-dtl.doc-qnty.
    assign
      bf-add-plus_gds-dtl.doc-qnty   = bf-add-plus_gds-dtl.doc-qnty   + tt-gds-dtl-plus.qnty
      bf-add-plus_doc-line.fact-qnty = bf-add-plus_doc-line.fact-qnty + tt-gds-dtl-plus.qnty
     .

    assign
      vartotal-rsrv-qnty-gds-dtl = vartotal-rsrv-qnty-gds-dtl + (bf-add-plus_gds-dtl.doc-qnty - varbefore-qnty).
    if varis-petrol-plus     and
       not varis-pieces-plus then do:
      for each tt-pl-qty-plus on error undo, return error return-value :
        assign
          bf-add-plus_doc-line.cli-qnty  = bf-add-plus_doc-line.cli-qnty  + tt-pl-qty-plus.qnty-kg.
      end.
    end.
    { str/set-pr.i
      recid(bf-add-plus_gds-dtl)
      no
      ?
      no-error
    }
    if error-status:error then do:
      undo, return error substitute("Ошибка при установке цены признака товара: &1 &2 &3 &4 &5 на объекте: &6 &7.", bf-add-plus_goods.artic, bf-add-plus_goods.prod-type, bf-add-plus_goods.prod-code, bf-add-plus_goods.gds-name, tt-gds-dtl-plus.prt-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
    end.
  end.

  assign
    vartotal-rsrv-qnty-parts = 0.00
    varpices-varkoeff = varkoeff
  .
  
  for each bf-add_parts where bf-add_parts.out-code   = bf_trn-doc.doc-code    and
                              bf-add_parts.obj-type   = bf_trn-doc.obj-type    and
                              bf-add_parts.obj-code   = bf_trn-doc.obj-code    and
                              bf-add_parts.artic      = bf-add_goods.artic     and
                              bf-add_parts.prod-type  = bf-add_goods.prod-type and
                              bf-add_parts.prod-code  = bf-add_goods.prod-code and
                              bf-add_parts.fact-qnty  < 0                      on error undo, return error return-value :

    find first tt-parts where tt-parts.obj-type  = bf-add_parts.obj-type  and
                              tt-parts.obj-code  = bf-add_parts.obj-code  and
                              tt-parts.artic     = bf-add_parts.artic     and
                              tt-parts.prod-type = bf-add_parts.prod-type and
                              tt-parts.prod-code = bf-add_parts.prod-code and
                              tt-parts.in-code   = bf-add_parts.in-code   and
                              tt-parts.out-code  = bf-add_parts.out-code  and
                              tt-parts.part-code = bf-add_parts.part-code no-error.
    if not available tt-parts or
       available tt-parts and - tt-parts.fact-qnty < - bf-add_parts.fact-qnty then do:
      if varis-petrol-plus     and
         not varis-pieces-plus then do:
        assign
          varrsrv-plus-parts = no
          varunrsrv-qnty-pl  = (if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty) * varkoeff else - bf-add_parts.fact-qnty * varkoeff).
        for each tt-pl-qty-plus where tt-pl-qty-plus.qnty-l - tt-pl-qty-plus.rsrv-l > 0 on error undo, return error return-value :
          assign
            vardensity-reserv       = tt-pl-qty-plus.qnty-kg  / tt-pl-qty-plus.qnty-l
            varcli-base-rate-reserv = tt-pl-qty-plus.qnty-l   / tt-pl-qty-plus.qnty-kg
            varprice-reserv         = bf-add_parts.price-rubl / varkoeff / vardensity-reserv.
          if tt-pl-qty-plus.qnty-l - tt-pl-qty-plus.rsrv-l >= varunrsrv-qnty-pl then do:
            /*Создаем партию по складскому месту*/
            assign
              varcrparts-qnty   = varunrsrv-qnty-pl.
            run local-create-parts in this-procedure
            (varcrparts-qnty,
             vardensity-reserv * varcrparts-qnty,
             varprice-reserv,
             varcli-base-rate-reserv,
             varcrparts-qnty / varkoeff,
             tt-pl-qty-plus.pl-code,
             (if parold-supp-cntr then bf-add_parts.supp-type     else bf_trn-doc.cli-type),
             (if parold-supp-cntr then bf-add_parts.supp-code     else bf_trn-doc.cli-code),
             (if parold-supp-cntr then bf-add_parts.contract-code else bf_trn-doc.contract-code)
             ) no-error.
            if error-status :error then do:
              undo, return error substitute ("Ошибка при создании партии: &1", return-value).
            end.
            assign
              tt-pl-qty-plus.rsrv-l = tt-pl-qty-plus.rsrv-l + varunrsrv-qnty-pl
              varunrsrv-qnty-pl     = 0.00
              varrsrv-plus-parts    = yes.
            leave.
          end.
          else do:
            assign
              tt-pl-qty-plus.rsrv-l = tt-pl-qty-plus.qnty-l
              varunrsrv-qnty-pl     = varunrsrv-qnty-pl - (tt-pl-qty-plus.qnty-l - tt-pl-qty-plus.rsrv-l) .
            /*Создаем партию по складскому месту*/
            assign
              varcrparts-qnty = (tt-pl-qty-plus.qnty-l - tt-pl-qty-plus.rsrv-l).
            run local-create-parts in this-procedure
            (varcrparts-qnty,
             vardensity-reserv * varcrparts-qnty,
             varprice-reserv,
             varcli-base-rate-reserv,
             varcrparts-qnty / varkoeff,
             tt-pl-qty-plus.pl-code,
             (if parold-supp-cntr then bf-add_parts.supp-type     else bf_trn-doc.cli-type),
             (if parold-supp-cntr then bf-add_parts.supp-code     else bf_trn-doc.cli-code),
             (if parold-supp-cntr then bf-add_parts.contract-code else bf_trn-doc.contract-code)) no-error.
            if error-status :error then do:
              undo, return error substitute ("Ошибка при создании партии: &1", return-value).
            end.
          end.
        end.
        if varrsrv-plus-parts = no then do:
          undo, return error "Не удалось зарезервировать оприходованное количество в разрезе складских мест".
        end.
      end.
      else if not varis-pieces-plus then do:
        run local-create-parts in this-procedure
        ((if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty) * varkoeff else - bf-add_parts.fact-qnty * varkoeff),
         (if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty) * varkoeff else - bf-add_parts.fact-qnty * varkoeff),
         (bf-add_parts.price-rubl - bf-add_parts.road-tax-rubl - bf-add_parts.transport-rubl - bf-add_parts.other-rubl )/ varkoeff,
         1,
         (if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty)  else - bf-add_parts.fact-qnty),
         0,
         (if parold-supp-cntr then bf-add_parts.supp-type     else bf_trn-doc.cli-type),
         (if parold-supp-cntr then bf-add_parts.supp-code     else bf_trn-doc.cli-code),
         (if parold-supp-cntr then bf-add_parts.contract-code else bf_trn-doc.contract-code)
         )
        no-error.
        if error-status :error then do:
          undo, return error substitute ("Ошибка при создании партии: &1", return-value).
        end.
      end.
      else do:
        if varoutqnty = (if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty) else - bf-add_parts.fact-qnty) then varqnty-pieces = varoutqnty-plus.
        else  varqnty-pieces = max(1,(if available tt-parts then - truncate((bf-add_parts.fact-qnty - tt-parts.fact-qnty) * varpices-varkoeff, 0) else - truncate(bf-add_parts.fact-qnty * varpices-varkoeff, 0))).
        run local-create-parts in this-procedure
        (
         varqnty-pieces,
         varqnty-pieces,
         ((bf-add_parts.price-rubl - bf-add_parts.road-tax-rubl - bf-add_parts.transport-rubl - bf-add_parts.other-rubl ) / (varqnty-pieces / (if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty) else - bf-add_parts.fact-qnty) )),
         1,
         (if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty)  else - bf-add_parts.fact-qnty),
         0,
         (if parold-supp-cntr then bf-add_parts.supp-type     else bf_trn-doc.cli-type),
         (if parold-supp-cntr then bf-add_parts.supp-code     else bf_trn-doc.cli-code),
         (if parold-supp-cntr then bf-add_parts.contract-code else bf_trn-doc.contract-code)
         )
        no-error.
        if error-status :error then do:
          undo, return error substitute ("Ошибка при создании партии: &1", return-value).
        end.
        varoutqnty-plus = varoutqnty-plus - varqnty-pieces.
        varoutqnty = varoutqnty - (if available tt-parts then - (bf-add_parts.fact-qnty - tt-parts.fact-qnty)  else - bf-add_parts.fact-qnty).
        varpices-varkoeff = varoutqnty-plus / varoutqnty.
      end.
    end.
  end.

  if vartotal-rsrv-qnty-parts <> vartotal-rsrv-qnty-gds-dtl then do:
    if abs (vartotal-rsrv-qnty-parts - vartotal-rsrv-qnty-gds-dtl) > 0.01 then do:
       message "Невозможно зарезервировать данную связку товаров при установленных количествах." skip
               "Зарезервированное количество по партиям:   " vartotal-rsrv-qnty-parts skip
               "Зарезервированное количество по признакам: " vartotal-rsrv-qnty-gds-dtl
       view-as alert-box.
       return error.
    end.
    assign
      varcorrect = no.
    for each bf_parts-root where bf_parts-root.doc-code      = bf_trn-doc.doc-code        and
                                 bf_parts-root.orig-gds-code = bf-add_goods.gds-code      and
                                 bf_parts-root.gds-code      = bf-add-plus_goods.gds-code,
      first bf-add-plus_parts where bf-add-plus_parts.out-code   = bf_trn-doc.doc-code         and
                                    bf-add-plus_parts.obj-type   = bf_trn-doc.obj-type         and
                                    bf-add-plus_parts.obj-code   = bf_trn-doc.obj-code         and
                                    bf-add-plus_parts.artic      = bf-add-plus_goods.artic     and
                                    bf-add-plus_parts.prod-type  = bf-add-plus_goods.prod-type and
                                    bf-add-plus_parts.prod-code  = bf-add-plus_goods.prod-code and
                                    bf-add-plus_parts.in-code    = bf_parts-root.in-code       and
                                    bf-add-plus_parts.part-code  = bf_parts-root.part-code     and
                                    bf-add-plus_parts.fact-qnty  > 0                           and
                                    bf-add-plus_parts.fact-qnty  > vartotal-rsrv-qnty-parts - vartotal-rsrv-qnty-gds-dtl :
      assign
        bf-add-plus_parts.fact-qnty = bf-add-plus_parts.fact-qnty - (vartotal-rsrv-qnty-parts - vartotal-rsrv-qnty-gds-dtl)
        varcorrect = yes.
      leave.
    end.
    if varcorrect = no then do:
       message "Невозможно зарезервировать данную связку товаров при установленных количествах." skip
       view-as alert-box.
       return error.
    end.
  end.
  run local-recalc in parcallback (input "update":u,
                                   input recid(bf-add-plus_doc-line),
                                   input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.
end.
end.

procedure local-create-parts:
define input parameter parqnty          as decimal   no-undo.
define input parameter parcli-qnty      as decimal   no-undo.
define input parameter parprice-cli     as decimal   no-undo.
define input parameter parcli-base-rate as decimal   no-undo.
define input parameter parreal-qnty     as decimal   no-undo.
define input parameter parpl-code       as integer   no-undo.
define input parameter parsupp-type     as character no-undo.
define input parameter parsupp-code     as integer   no-undo.
define input parameter parcontract-code as integer   no-undo.

define buffer bf-add-plus_parts    for ub.parts.

define variable new-qnty as decimal no-undo.
define variable Loc-cr-varkoeff  as decimal no-undo.
define variable new-cli-qnty as decimal no-undo.

do on error undo, return error return-value :
    
  run holdprts-get-part-code in parcallback ( input bf_trn-doc.doc-code
                                             ,output varpart-code
                                            ) no-error .
  if error-status:error then do:
    undo, return error substitute ("Ошибка при получении кода партии: &1", return-value).
  end.
  
  Loc-cr-varkoeff = varkoeff.
  /* если штучный */
  if varis-pieces-plus then do:
     Loc-cr-varkoeff =  parqnty / parreal-qnty.
  end.

  create bf-add-plus_parts.
  assign
    bf-add-plus_parts.prod-type      = bf-add-plus_goods.prod-type
    bf-add-plus_parts.prod-code      = bf-add-plus_goods.prod-code
    bf-add-plus_parts.artic          = bf-add-plus_goods.artic
    bf-add-plus_parts.in-code        = bf_trn-doc.doc-code
    bf-add-plus_parts.out-code       = bf_trn-doc.doc-code
    bf-add-plus_parts.price-base     = bf-add_parts.price-base / Loc-cr-varkoeff
    bf-add-plus_parts.price-rubl     = bf-add_parts.price-rubl / Loc-cr-varkoeff
    bf-add-plus_parts.obj-type       = bf_trn-doc.obj-type
    bf-add-plus_parts.obj-code       = bf_trn-doc.obj-code
    bf-add-plus_parts.VAT-pc         = bf-add_parts.vat-pc
    bf-add-plus_parts.part-code      = varpart-code
    bf-add-plus_parts.PS             = bf-add_parts.PS
    bf-add-plus_parts.pay-code       = bf-add_parts.pay-code
    bf-add-plus_parts.status_        = no
    bf-add-plus_parts.supp-type      = parsupp-type
    bf-add-plus_parts.supp-code      = parsupp-code
    bf-add-plus_parts.rsrv-free      = ?
    bf-add-plus_parts.doc-type       = bf_trn-doc.doc-type
    bf-add-plus_parts.pl-code        = 0
    bf-add-plus_parts.VAT-type       = bf-add_parts.vat-type
    bf-add-plus_parts.exch-code      = 0
    bf-add-plus_parts.SLT-pc         = bf-add_parts.slt-pc
    bf-add-plus_parts.host-code      = bf_trn-doc.host-code
    bf-add-plus_parts.is-supp        = yes
    bf-add-plus_parts.SLT-type       = bf-add_parts.slt-type
    bf-add-plus_parts.cst-code       = "":u
    bf-add-plus_parts.last-date      = ?
    bf-add-plus_parts.road-tax-base  = bf-add_parts.road-tax-base  / Loc-cr-varkoeff
    bf-add-plus_parts.road-tax-rubl  = bf-add_parts.road-tax-rubl  / Loc-cr-varkoeff
    bf-add-plus_parts.transport-base = bf-add_parts.transport-base / Loc-cr-varkoeff
    bf-add-plus_parts.transport-rubl = bf-add_parts.transport-rubl / Loc-cr-varkoeff
    bf-add-plus_parts.other-base     = bf-add_parts.other-base     / Loc-cr-varkoeff
    bf-add-plus_parts.other-rubl     = bf-add_parts.other-rubl     / Loc-cr-varkoeff
    bf-add-plus_parts.purch-code     = bf-add_parts.purch-code
    bf-add-plus_parts.contract-code  = parcontract-code
    bf-add-plus_parts.qnty           = parqnty
    bf-add-plus_parts.cli-qnty       = parcli-qnty
    bf-add-plus_parts.price-cli      = parprice-cli
    bf-add-plus_parts.cli-base-rate  = parcli-base-rate
    bf-add-plus_parts.real-qnty      = parreal-qnty
    bf-add-plus_parts.fact-qnty      = bf-add-plus_parts.qnty
    bf-add-plus_parts.pl-code        = parpl-code
  .
  
  if bf-add-plus_parts.supp-type = bf-add-plus_parts.obj-type and
     bf-add-plus_parts.supp-code = bf-add-plus_parts.obj-code then do:
    assign
      bf-add-plus_parts.is-supp = no.
  end.

  assign
    vartotal-rsrv-qnty-parts = vartotal-rsrv-qnty-parts + bf-add-plus_parts.fact-qnty.
  create bf-add-cr_parts-root.
  assign
    bf-add-cr_parts-root.doc-code       = bf-add_parts.out-code
    bf-add-cr_parts-root.orig-in-code   = bf-add_parts.in-code
    bf-add-cr_parts-root.orig-gds-code  = bf-add_goods.gds-code
    bf-add-cr_parts-root.orig-part-code = bf-add_parts.part-code
    bf-add-cr_parts-root.in-code        = bf-add-plus_parts.in-code
    bf-add-cr_parts-root.gds-code       = bf-add-plus_goods.gds-code
    bf-add-cr_parts-root.part-code      = bf-add-plus_parts.part-code
  .
  find first bf-add-plus_doc-pl where bf-add-plus_doc-pl.obj-type = bf_trn-doc.obj-type        and
                                      bf-add-plus_doc-pl.obj-code = bf_trn-doc.obj-code        and
                                      bf-add-plus_doc-pl.pl-code  = parpl-code                 and
                                      bf-add-plus_doc-pl.out-code = bf_trn-doc.doc-code        and
                                      bf-add-plus_doc-pl.gds-code = bf-add-plus_goods.gds-code no-error.
  if not available bf-add-plus_doc-pl then do:
    create bf-add-plus_doc-pl.
    assign
      bf-add-plus_doc-pl.obj-type = bf_trn-doc.obj-type
      bf-add-plus_doc-pl.obj-code = bf_trn-doc.obj-code
      bf-add-plus_doc-pl.pl-code  = parpl-code
      bf-add-plus_doc-pl.out-code = bf_trn-doc.doc-code
      bf-add-plus_doc-pl.gds-code = bf-add-plus_goods.gds-code
    .
  end.
  assign
    bf-add-plus_doc-pl.doc-qnty      = bf-add-plus_doc-pl.doc-qnty + parqnty
    bf-add-plus_doc-pl.fact-qnty     = bf-add-plus_doc-pl.doc-qnty
    bf-add-plus_doc-pl.cli-qnty      = bf-add-plus_doc-pl.cli-qnty + parcli-qnty
    bf-add-plus_doc-pl.cli-doc-qnty  = bf-add-plus_doc-pl.cli-qnty
    bf-add-plus_doc-pl.cli-fact-qnty = bf-add-plus_doc-pl.cli-qnty
  .
end.
end procedure.