block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание документов межфирменного перемещения.

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

1) Создает документ внешнего прихода от своей фирмы по документу внешнего расхода на свою фирму.
2) Создает документ возврата от покупателя от своей фирмы по документу внешнего прихода на свою фирму.
3) Создает документ возврата от покупателя от своей фирмы по документу возврата поставщику - своей фирме.

*/

define input parameter v-doc-code like ub.trn-doc.doc-code no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание документов межфирменного перемещения":U .

{ cmp/vssrevis.i "substitute('&1':u,v-doc-code)" }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ trg/holdprts.i }
{ str/lib-def.i  }
{ str/doc-code.i }
{ str/hold-ret.i }
{ cmp/gds-list.i gds-list def }
{ gbl/waitfram.i }
{ cmp/library.i  }

define variable v-today         as date                      no-undo.
define variable varhave-ret     as logical                   no-undo.
define variable varchg-inv      as logical                   no-undo.

define buffer bf-src_trn-doc       for ub.trn-doc.
define buffer bf-src_doc-line      for ub.doc-line.
define buffer bf-src_doc-line-attr for ub.doc-line-attr.
define buffer bf-src_goods         for ub.goods.
define buffer bf-src_gds-dtl       for ub.gds-dtl.
define buffer bf-src_parts         for ub.parts.
define buffer bf-src_units         for ub.units.
define buffer bf_trn-doc           for ub.trn-doc.
define buffer buf_trn-doc          for ub.trn-doc.
define buffer bf-cur-obj_clients   for ub.clients.
define buffer bf-hold-obj_clients  for ub.clients.
define buffer bf-hold_sysconf      for ub.sysconf.
define buffer bf-hold_firm         for ub.firm   .
define buffer bf-cur-firm_clients  for ub.clients.
define buffer bf-cur_sysconf       for ub.sysconf.
define buffer bf_doc-line          for ub.doc-line.
define buffer bf_doc-line-attr     for ub.doc-line-attr.
define buffer bf_gds-dtl           for ub.gds-dtl.
define buffer bf_parts             for ub.parts.
define buffer bf_contract          for ub.contract.
define buffer bf_currency          for ub.currency.
define buffer bf_goods             for ub.goods.


define variable v-base-code-cur  like ub.currency.curr-code     no-undo.
define variable v-base-code-hold like ub.currency.curr-code     no-undo.
define variable vardoc-code      like ub.trn-doc.doc-code       no-undo.
define variable varexch-rate     like ub.trn-doc.exch-rate      no-undo.
define variable varexch-scale    like ub.trn-doc.exch-scale     no-undo.
define variable varcurr-abbr     as   character                 no-undo.
define variable v-base-code-from like ub.sysconf.base-code      no-undo.
define variable v-base-code-to   like ub.sysconf.base-code      no-undo.

define variable is-petrol as logical no-undo.
define variable is-pieces as logical no-undo.
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code as character no-undo .

if retry then do:
  message "Несанкционированное завершение транзакции progress." skip
          "Отправьте, пожалуйста, экран с этим сообщением в отдел сопровождения компании IBS." skip
          "return-value"                 return-value                 skip
          "error-status :error"          error-status :error          skip
          "error-status :get-message(1)" error-status :get-message(1) skip
          "error-status :get-message(2)" error-status :get-message(2) skip
          "error-status :get-message(3)" error-status :get-message(3) skip
          "error-status :get-message(4)" error-status :get-message(4) skip
          "error-status :get-message(5)" error-status :get-message(5) skip
          "конец сообщения"
  view-as alert-box error.
  return error return-value.
end.

main-block:
do for bf-src_trn-doc       ,
       bf-src_doc-line      ,
       bf-src_doc-line-attr ,
       bf-src_goods         ,
       bf-src_gds-dtl       ,
       bf-src_parts         ,
       bf-src_units         ,
       bf_trn-doc           ,
       bf-cur-obj_clients   ,
       bf-hold-obj_clients  ,
       bf-hold_sysconf      ,
       bf-hold_firm         ,
       bf-cur-firm_clients  ,
       bf-cur_sysconf       ,
       bf_doc-line          ,
       bf_doc-line-attr     ,
       bf_gds-dtl           ,
       bf_parts             ,
       bf_contract          ,
       bf_currency
transaction
on error undo main-block, return error return-value
:
  find first bf-src_trn-doc
    where bf-src_trn-doc.doc-code = v-doc-code
    no-error .
  if not available bf-src_trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ " v-doc-code
      view-as alert-box .
    undo main-block, return error .
  end.
  if bf-src_trn-doc.office then do:
    /*услуги не приходуются*/
    return.
  end.
  find first bf-cur_sysconf no-lock
  where bf-cur_sysconf.host-code = bf-src_trn-doc.host-code
  no-error.
  find first bf-hold_sysconf no-lock
  where bf-hold_sysconf.host-code = bf-src_trn-doc.cli-code
  no-error .
  if  bf-src_trn-doc.status_  = {&fact}
  and (bf-src_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}   or
       bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}   or
       bf-src_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} ) then do:
    /* правильный документ */
  end.
  else do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "В качестве параметра можно передавать" skip
      "только документы внешнего расхода или внешнего прихода" skip
      "закрытые до статуса" {&fact} skip
      "Документ" bf-src_trn-doc.doc-code skip
      "Тип документа" bf-src_trn-doc.doc-type skip
      "Внутренний" bf-src_trn-doc.internal skip
      "Тип скидки" bf-src_trn-doc.discnt-type skip
      "Статус" bf-src_trn-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable v-is-hold as logical   no-undo .
  { gbl/hold-doc.i
    bf-src_trn-doc.doc-code
    v-is-hold
    no-error
  }

  if error-status :error or v-is-hold = false then return .
  if not available bf-hold_sysconf or
     bf-src_trn-doc.cli-type <> {&cmp} or
     (bf-src_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}    and bf-src_trn-doc.hold-doc-code-child  = "no-hold") or
     (bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}    and bf-src_trn-doc.hold-doc-code-parent = "no-hold") or
     (bf-src_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} and bf-src_trn-doc.hold-doc-code-child  = "no-hold")
    then do:
    /* это внешний расход на обычную организацию или внешний приход от обычной организации*/
    /* ничего не надо делать */
    return . /* --->>>--- */
  end.
  find first bf-hold_firm where bf-hold_firm.firm-code = bf-hold_sysconf.host-code no-lock.

  /* определяем код базовой валюты для фирмы исходного документа */
  { gbl/basecode.i
    bf-src_trn-doc.host-code
    v-base-code-cur
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ перемещения" bf-src_trn-doc.doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  /* определяем код базовой валюты для фирмы */
  { gbl/basecode.i
    bf-src_trn-doc.cli-code
    v-base-code-hold
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении кода базовой валюты для фирмы" skip
      "Документ перемещения" bf-src_trn-doc.doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if v-base-code-hold <> v-base-code-cur then do: /* коды базовой валюты для фирм источника и приемника разные - запрещаем перемещение */
    message
      vss-workfile vss-revision vss-description skip
      "Коды базовой валюты для фирм источника и приемника разные" skip
      "Документ перемещения" bf-src_trn-doc.doc-code skip
      "Источник-фирма " bf-src_trn-doc.host-code skip
      "Приемник-фирма " bf-src_trn-doc.cli-code
      view-as alert-box error .
    undo, return error .
  end.

  /* ищем объект приемника при расходе */
  case bf-src_trn-doc.ext-doc-type :
  when {&TDEDT_Ras_Vnesh} then do:
    find first bf-hold-obj_clients no-lock
      where bf-hold-obj_clients.obj-type = bf-src_trn-doc.hold-obj-type
        and bf-hold-obj_clients.obj-code = bf-src_trn-doc.hold-obj-code
      no-error .
    if not available bf-hold-obj_clients then do: /* нет объекта приемника, нельзя копировать */
      message
        vss-workfile vss-revision vss-description skip
        "Нет объекта-приемника, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект-приемник" bf-src_trn-doc.hold-obj-type bf-src_trn-doc.hold-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first bf-cur-firm_clients no-lock
      where bf-cur-firm_clients.obj-type = {&cmp} and
            bf-cur-firm_clients.obj-code = bf-src_trn-doc.host-code
    no-error.
    if not available bf-cur-firm_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет фирмы для документа перемещения, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        view-as alert-box error .
      undo, return error .
    end.
  end.
  when {&TDEDT_Ras_Vnesh_VP} then do:
    find first bf-hold-obj_clients no-lock
      where bf-hold-obj_clients.obj-type = bf-src_trn-doc.hold-obj-type
        and bf-hold-obj_clients.obj-code = bf-src_trn-doc.hold-obj-code
      no-error .
    if not available bf-hold-obj_clients then do: /* нет объекта приемника, нельзя копировать */
      message
        vss-workfile vss-revision vss-description skip
        "Нет объекта-приемника, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект-приемник" bf-src_trn-doc.hold-obj-type bf-src_trn-doc.hold-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first bf-cur-firm_clients no-lock
      where bf-cur-firm_clients.obj-type = {&cmp} and
            bf-cur-firm_clients.obj-code = bf-src_trn-doc.host-code
    no-error.
    if not available bf-cur-firm_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет фирмы для документа перемещения, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        view-as alert-box error .
      undo, return error .
    end.
  end.
  when {&TDEDT_Pri_Vnesh} then do:
    find bf-hold-obj_clients where bf-hold-obj_clients.obj-type = bf-src_trn-doc.hold-obj-type and
                                   bf-hold-obj_clients.obj-code = bf-src_trn-doc.hold-obj-code no-lock no-error.
    if not available bf-hold-obj_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет объекта для создания документа межфирменного перемещения, нельзя копировать" skip
        "Документ прихода" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        "Объект для генерации документа " bf-src_trn-doc.hold-obj-type " " bf-src_trn-doc.hold-obj-code
        view-as alert-box error .
      undo, return error .
    end.
    find first bf-cur-firm_clients no-lock
      where bf-cur-firm_clients.obj-type = {&cmp} and
            bf-cur-firm_clients.obj-code = bf-src_trn-doc.host-code
    no-error.
    if not available bf-cur-firm_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нет фирмы для документа перемещения, нельзя копировать" skip
        "Документ перемещения" bf-src_trn-doc.doc-code skip
        "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
        "Фирма" bf-src_trn-doc.host-code
        view-as alert-box error .
      undo, return error .
    end.
  end.
  otherwise do:
    message "Неверный расширенный тип документа для межфирменного перемещения: " bf-src_trn-doc.ext-doc-type " ."
    view-as alert-box error.
    undo, return error.
  end.
  end case.

  find first bf-cur-obj_clients no-lock
    where bf-cur-obj_clients.obj-type = bf-src_trn-doc.obj-type
      and bf-cur-obj_clients.obj-code = bf-src_trn-doc.obj-code
    no-error .
  if not available bf-cur-obj_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный клиент" skip
      "Документ " v-doc-code skip
      "Объект" bf-src_trn-doc.obj-type bf-src_trn-doc.obj-code skip
      "Клиент" bf-src_trn-doc.cli-code bf-src_trn-doc.cli-type skip
      view-as alert-box .
    undo main-block, return error .
  end.
  if not (
     (bf-cur-obj_clients.db-num = bf-hold-obj_clients.db-num and
      g#db-num = bf-cur-obj_clients.db-num                ) or
     (bf-cur-obj_clients.db-num <> bf-hold-obj_clients.db-num and
      g#db-num         =  0                     )
     )
  then do:
    return . /* нельзя копировать - БД источника и приемника не совпали и работаем не в офисе */
  end.

  if bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
    assign varhave-ret = no.
    for each bf-src_doc-line where bf-src_doc-line.doc-code = bf-src_trn-doc.doc-code on error undo, return error return-value :
       if bf-src_doc-line.doc-qnty <> bf-src_doc-line.fact-qnty then do:
         assign varhave-ret = yes.
         leave.
       end.
    end.
    if varhave-ret = no then do :
      /*Возвращать(делать внешний приход контрагенту) нечего*/
      return.
    end.
  end.
  run doc-code in this-procedure
   (input  "main":u,
    input  bf-hold-obj_clients.obj-type,
    input  bf-hold-obj_clients.obj-code,
    input  ?,
    output vardoc-code) no-error.
  if error-status :error then do:
    message "Ошибка при генерации номера документа." skip
            return-value skip
            error-status :get-message(1)
    view-as alert-box error.
    undo, return error.
  end.
  { gbl/curobjdt.i bf-hold-obj_clients.obj-type bf-hold-obj_clients.obj-code v-today }
  case bf-src_trn-doc.ext-doc-type :
  when {&TDEDT_Ras_Vnesh} then do:
    { str/crtrndoc.i
     ?
     ?
     bf-src_trn-doc.base-rate
     bf-src_trn-doc.base-scale
     bf-src_trn-doc.host-code
     {&cmp}
     bf-cur-firm_clients.obj-name
     g#db-num
     bf-src_trn-doc.creid
     "''"
     vardoc-code
     v-today
     {&income}
     false
     bf-src_trn-doc.cli-code
     no
     bf-hold-obj_clients.obj-code
     bf-hold-obj_clients.obj-type
     bf-src_trn-doc.office
     bf-src_trn-doc.pay-code
     "''"
     no
     ?
     {&wayb}
     ?
     {&TDEDT_Pri_Vnesh}
     {&repayment-code}
     no-error
    }
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа межфирменного перемещения" skip
      "Исходный документ межфирменного перемещения" bf-src_trn-doc.doc-code skip
      "Объект" bf-src_trn-doc.cli-type bf-src_trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  when {&TDEDT_Ras_Vnesh_VP} then do:
    { str/crtrndoc.i
     ?
     ?
     bf-src_trn-doc.base-rate
     bf-src_trn-doc.base-scale
     bf-src_trn-doc.host-code
     {&cmp}
     bf-cur-firm_clients.obj-name
     g#db-num
     bf-src_trn-doc.creid
     {&percent}
     vardoc-code
     v-today
     {&return}
     false
     bf-src_trn-doc.cli-code
     no
     bf-hold-obj_clients.obj-code
     bf-hold-obj_clients.obj-type
     bf-src_trn-doc.office
     bf-src_trn-doc.pay-code
     "''"
     no
     ?
     {&wayb}
     ?
     {&TDEDT_Vozvrat_Vnesh}
     {&repayment-code}
     no-error
    }
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа межфирменного перемещения" skip
      "Исходный документ межфирменного перемещения" bf-src_trn-doc.doc-code skip
      "Объект" bf-src_trn-doc.cli-type bf-src_trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  when {&TDEDT_Pri_Vnesh} then do:
    { str/crtrndoc.i
     ?
     ?
     bf-src_trn-doc.base-rate
     bf-src_trn-doc.base-scale
     bf-src_trn-doc.host-code
     {&cmp}
     bf-cur-firm_clients.obj-name
     g#db-num
     bf-src_trn-doc.creid
     {&percent}
     vardoc-code
     v-today
     {&return}
     false
     bf-src_trn-doc.cli-code
     no
     bf-hold-obj_clients.obj-code
     bf-hold-obj_clients.obj-type
     bf-src_trn-doc.office
     bf-src_trn-doc.pay-code
     "''"
     no
     ?
     {&wayb}
     ?
     {&TDEDT_Vozvrat_Vnesh}
     {&repayment-code}
     no-error
    }
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа межфирменного перемещения" skip
      "Исходный документ межфирменного перемещения" bf-src_trn-doc.doc-code skip
      "Объект" bf-src_trn-doc.cli-type bf-src_trn-doc.cli-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      undo, return error.
    end.
  end.
  otherwise do:
    message "Неверный расширенный тип документа для межфирменного перемещения: " bf-src_trn-doc.ext-doc-type " ."
    view-as alert-box error.
    undo, return error.
  end.
  end case.
  find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code .
  assign
    bf_trn-doc.PS          = "Документ межфирменного перемещения создан на основании документа: " + bf-src_trn-doc.doc-code
                             + {&new-line} + "Комментарий родительского документа: " + bf-src_trn-doc.ps
    bf_trn-doc.out-code    = ?
    bf_trn-doc.fact-base   = ?
    bf_trn-doc.fact-rubl   = ?
  .
  assign
    bf-src_trn-doc.hold-doc-code-child = bf_trn-doc.doc-code
    bf_trn-doc.out-code                = bf-src_trn-doc.doc-code
    bf_trn-doc.hold-doc-code-parent    = bf-src_trn-doc.doc-code
    bf_trn-doc.hold-obj-type           = bf-src_trn-doc.obj-type
    bf_trn-doc.hold-obj-code           = bf-src_trn-doc.obj-code
    bf_trn-doc.reason-code             = bf-src_trn-doc.reason-code
  .
  /*Приходную накладную оформим через р_у_бли*/
  if bf_trn-doc.ext-doc-type      =  {&TDEDT_Pri_Vnesh} and
     bf-src_trn-doc.contract-code <> 0                  then do:
    find bf_contract where bf_contract.host-code     = bf_trn-doc.host-code and  bf_contract.cli-code = bf_trn-doc.cli-code and bf_contract.status_ <> {&close-contr} no-lock no-error.
      if available bf_contract then do:
      if ambiguous bf_contract then bf_trn-doc.contract-code = 0 . else bf_trn-doc.contract-code = bf_contract.contract-code .
      end.
    find first bf_contract where bf_contract.contract-code = bf-src_trn-doc.contract-code no-lock.
    find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
    if not available bf_currency then do:
      return error substitute ("В договоре на приход указана валюта &1. Но этой валюты нет в справочнике валют.", bf_contract.curr-code).
    end.
     { gbl/exchrate.i
       bf_currency.curr-code
       bf_trn-doc.exch-date
       varexch-rate
       varexch-scale
       varcurr-abbr
       no-error
     }
     if error-status :error then do:
       return error "Ошибка при поиске курса валюты поставки по договору.".
     end.
     assign
      
       bf_trn-doc.exch-code     = bf_contract.curr-code
       bf_trn-doc.exch-rate     = varexch-rate
       bf_trn-doc.exch-scale    = varexch-scale
     .
    if lookup (bf_contract.contract-type, {&contr-purch-repayment}) > 0 then do:
      assign
        bf_trn-doc.purch-code = {&bef-repayment-code}.
    end.
    else do:
      if lookup (bf_contract.contract-type, {&contr-purch-consignation}) > 0 then do:
        assign
          bf_trn-doc.purch-code = {&bef-consignation-code}.
      end.
      else do:
        if lookup (bf_contract.contract-type, {&contr-purch-resp-store}) > 0 then do:
          assign
            bf_trn-doc.purch-code = {&bef-responsible-storage-code}.
        end.
        else do:
          return error substitute("Нельзя определить по договору  &1 с типом &2 тип приобретения для партий накладной.", bf_contract.contract-prn-code, bf_contract.contract-type ).
        end.
      end.
    end.
  end.
  else do:

find first buf_trn-doc where buf_trn-doc.doc-code = bf-src_trn-doc.out-code no-lock no-error .
if available buf_trn-doc then do:
  find first bf_contract where bf_contract.contract-code = buf_trn-doc.contract-code no-lock no-error.
  if available bf_contract then bf_trn-doc.contract-code = bf_contract.contract-code.
end.   
else do:
  find first bf_contract where bf_contract.host-code = bf_trn-doc.host-code and bf_contract.cli-code = bf_trn-doc.cli-code  no-lock no-error.
  if available bf_contract then bf_trn-doc.contract-code = bf_contract.contract-code.
end.  
    if bf-src_trn-doc.exch-code <> 0 then do:
      /*ищем баз валюты обоих фирм*/
      { gbl/basecode.i bf-src_trn-doc.host-code v-base-code-from }
      { gbl/basecode.i bf_trn-doc.host-code v-base-code-to }

      if v-base-code-from = v-base-code-to
      and v-base-code-from <> 0 then do:
      { gbl/exchrate.i
        v-base-code-from
        bf_trn-doc.exch-date
        varexch-rate
        varexch-scale
        varcurr-abbr
        no-error
      }
        if error-status :error then do:
          return error substitute("Ошибка при поиске курса валюты &1:&2&3 &4."
                                 , v-base-code-from
                                 , {&new-line}
                                 , error-status :get-message(1)
                                 , return-value
                                 ).
        end.
        assign
        bf_trn-doc.exch-code  = v-base-code-from
        bf_trn-doc.exch-rate  = varexch-rate
        bf_trn-doc.exch-scale = varexch-scale
        .
      end.
      else do:
        assign
        bf_trn-doc.exch-code  = 0
        bf_trn-doc.exch-rate  = 1
        bf_trn-doc.exch-scale = 1.
      end.
    end.
    else do:
      assign
      bf_trn-doc.exch-code  = 0
      bf_trn-doc.exch-rate  = 1
      bf_trn-doc.exch-scale = 1.
    end.
  end.
  assign
    bf_trn-doc.vat-type   = {&inc-vat}
    bf_trn-doc.slt-type   = {&without-slt}.
  for each lib-trn_ret-doc on error undo, return error return-value :
    delete lib-trn_ret-doc.
  end.
  create lib-trn_ret-doc.
  buffer-copy bf-src_trn-doc except bf-src_trn-doc.fact-date bf-src_trn-doc.shift-date bf-src_trn-doc.shift-num to lib-trn_ret-doc.
  for each lib-trn_ret-line on error undo, return error return-value :
    delete lib-trn_ret-line.
  end.
  for each lib-trn_ret-line-attr on error undo, return error return-value :
    delete lib-trn_ret-line-attr.
  end.
  for each lib-trn_ret-dtl on error undo, return error return-value :
    delete lib-trn_ret-dtl.
  end.
  for each lib-trn_ret-parts on error undo, return error return-value :
    delete lib-trn_ret-parts.
  end.
  doc-line-label:
  for each bf-src_doc-line where bf-src_doc-line.doc-code = bf-src_trn-doc.doc-code on error undo, return error return-value :
    find first bf-src_goods where bf-src_goods.artic     = bf-src_doc-line.artic     and
                              bf-src_goods.prod-type = bf-src_doc-line.prod-type and
                              bf-src_goods.prod-code = bf-src_doc-line.prod-code no-lock.
    if bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}    and
       bf-src_doc-line.doc-qnty    = bf-src_doc-line.fact-qnty then do:
       next doc-line-label.
    end.
    create lib-trn_ret-line.
    buffer-copy bf-src_doc-line except bf-src_doc-line.doc-qnty bf-src_doc-line.fact-qnty to lib-trn_ret-line.
    assign
    lib-trn_ret-line.doc-qnty  = (if bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then bf-src_doc-line.doc-qnty - bf-src_doc-line.fact-qnty else bf-src_doc-line.fact-qnty)
    lib-trn_ret-line.fact-qnty = lib-trn_ret-line.doc-qnty
    lib-trn_ret-line.cst-code  = bf_trn-doc.cst-code.


    for each bf-src_doc-line-attr where bf-src_doc-line-attr.doc-code  = bf-src_trn-doc.doc-code and
                                        bf-src_doc-line-attr.gds-code  = bf-src_goods.gds-code   on error undo, return error return-value :
      create lib-trn_ret-line-attr.
      buffer-copy bf-src_doc-line-attr to lib-trn_ret-line-attr.
    end.
    gds-dtl-label:
    for each bf-src_gds-dtl where bf-src_gds-dtl.doc-code  = bf-src_trn-doc.doc-code   and
                                  bf-src_gds-dtl.artic     = bf-src_doc-line.artic     and
                                  bf-src_gds-dtl.prod-type = bf-src_doc-line.prod-type and
                                  bf-src_gds-dtl.prod-code = bf-src_doc-line.prod-code on error undo, return error return-value :
      if bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}   and
         bf-src_gds-dtl.doc-qnty     = bf-src_gds-dtl.fact-qnty then do:
         next gds-dtl-label.
      end.
      create lib-trn_ret-dtl.
      buffer-copy bf-src_gds-dtl except bf-src_gds-dtl.doc-qnty bf-src_gds-dtl.fact-qnty bf-src_gds-dtl.price-base bf-src_gds-dtl.discnt-base bf-src_gds-dtl.price-rubl bf-src_gds-dtl.discnt-rubl to lib-trn_ret-dtl.
      assign
        lib-trn_ret-dtl.price-base  = bf-src_gds-dtl.price-base - bf-src_gds-dtl.discnt-base
        lib-trn_ret-dtl.discnt-base = 0
        lib-trn_ret-dtl.price-rubl  = bf-src_gds-dtl.price-rubl - bf-src_gds-dtl.discnt-rubl
        lib-trn_ret-dtl.discnt-rubl = 0
        lib-trn_ret-dtl.doc-qnty    = (if bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then bf-src_gds-dtl.doc-qnty - bf-src_gds-dtl.fact-qnty else bf-src_gds-dtl.fact-qnty)
        lib-trn_ret-dtl.fact-qnty   = lib-trn_ret-dtl.doc-qnty.
    end.
    parts-label:
    for each bf-src_parts where bf-src_parts.out-code  = bf-src_trn-doc.doc-code   and
                                bf-src_parts.obj-type  = bf-src_trn-doc.obj-type   and
                                bf-src_parts.obj-code  = bf-src_trn-doc.obj-code   and
                                bf-src_parts.artic     = bf-src_doc-line.artic     and
                                bf-src_parts.prod-type = bf-src_doc-line.prod-type and
                                bf-src_parts.prod-code = bf-src_doc-line.prod-code on error undo, return error return-value :
      if bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}   and
         bf-src_parts.qnty           = bf-src_parts.fact-qnty then do:
         next parts-label.
      end.
      bf-src_parts.hold-date = v-today .
      create lib-trn_ret-parts.
      buffer-copy bf-src_parts except bf-src_parts.qnty bf-src_parts.fact-qnty to lib-trn_ret-parts.
      assign
        lib-trn_ret-parts.qnty      = (if bf-src_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then bf-src_parts.qnty - bf-src_parts.fact-qnty else bf-src_parts.fact-qnty)
        lib-trn_ret-parts.fact-qnty = lib-trn_ret-parts.qnty
      	lib-trn_ret-parts.contract-code = bf_trn-doc.contract-code .
        if bf-src_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}  then do:
           lib-trn_ret-parts.hold-date = v-today .
        end.
    end.
  end.
  if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
    assign
      lib-trn_ret-doc.doc-type     = {&income}
      lib-trn_ret-doc.internal     = no
      lib-trn_ret-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
      lib-trn_ret-doc.exch-code    = bf_trn-doc.exch-code
      lib-trn_ret-doc.exch-rate    = bf_trn-doc.exch-rate
      lib-trn_ret-doc.exch-scale   = bf_trn-doc.exch-scale
      .
    for each lib-trn_ret-dtl break by lib-trn_ret-dtl.doc-code by lib-trn_ret-dtl.artic by lib-trn_ret-dtl.prod-type by lib-trn_ret-dtl.prod-code on error undo, return error return-value :
        find first lib-trn_ret-line where lib-trn_ret-line.doc-code  = lib-trn_ret-dtl.doc-code  and
                                          lib-trn_ret-line.artic     = lib-trn_ret-dtl.artic     and
                                          lib-trn_ret-line.prod-type = lib-trn_ret-dtl.prod-type and
                                          lib-trn_ret-line.prod-code = lib-trn_ret-dtl.prod-code .


        assign
          lib-trn_ret-line.price-rubl = lib-trn_ret-dtl.price-rubl
          lib-trn_ret-line.price-base = lib-trn_ret-dtl.price-base
        .
    end.

    for each lib-trn_ret-line on error undo, return error return-value :
      find first bf_goods no-lock where
                 bf_goods.artic     = lib-trn_ret-line.artic     and
                 bf_goods.prod-type = lib-trn_ret-line.prod-type and
                 bf_goods.prod-code = lib-trn_ret-line.prod-code .
      { str/is-petrl.i bf_goods.artic
                   bf_goods.prod-type
                   bf_goods.prod-code
                   is-petrol
                   is-pieces          no-error }
      if not error-status :error and is-petrol = yes and is-pieces = no then do:
        assign lib-trn_ret-line.price-cli     = lib-trn_ret-line.price-rubl / lib-trn_ret-doc.exch-rate
                                                                            * lib-trn_ret-doc.exch-scale
                                                                            * lib-trn_ret-line.cli-base-rate.
      end.
      else do:
        assign lib-trn_ret-line.cli-base-rate = 1
               lib-trn_ret-line.price-cli     = lib-trn_ret-line.price-rubl / lib-trn_ret-doc.exch-rate
               lib-trn_ret-line.unit-cli      = bf_goods.unit-base.
      end.
      assign
        lib-trn_ret-line.cli-base-rate = 1
        lib-trn_ret-line.price-cli     = lib-trn_ret-line.price-rubl / lib-trn_ret-doc.exch-rate * lib-trn_ret-doc.exch-scale
        lib-trn_ret-line.unit-cli      = bf_goods.unit-base.
    end.
    { str/copy-in.i
      ?
      recid(bf_trn-doc)
      lib-trn_ret-doc
      lib-trn_ret-line
      lib-trn_ret-line-attr
      lib-trn_ret-dtl
      lib-trn_ret-parts
      no
      yes
      yes
      yes
      this-procedure
      no-error
    }
    if error-status :error then do:
      return error return-value.
    end.
    assign
      bf_trn-doc.agnt       = bf-src_trn-doc.agnt
      bf_trn-doc.boss       = bf-src_trn-doc.boss
      bf_trn-doc.wrkr       = bf-src_trn-doc.wrkr.
  end.
  else do:
    run hold-ret in this-procedure (input bf_trn-doc.doc-code) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при заполнении документа возврата" skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error return-value.
    end.
  end.
  /* проверить правильность атрибутов документа */
  run holdprts-validate-document in this-procedure
    (input bf_trn-doc.doc-code /* p-target-doc-code */
    ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
  /* рассчитываем шапку накладной */
  run gbl/calc-trn.p (input ? /*parparentproc*/ , input recid(bf_trn-doc)) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
  if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
    assign
      bf_trn-doc.tot-cli = bf_trn-doc.tot-calc.
  end.
  /* закрываем накладную       */
  /* накл- -> накл+ */
  run str/trn-stat.p (input this-procedure,  /* parparentproc */
                  input ?,
                  input {&close-doc},
                  input vardoc-code,
                  input no,
                  input g#db-num,
                  input ?,
                  input ?,
                  input ?,
                  input ?,
                  input (if g#news = yes then no else yes),
                  output varchg-inv,
                  output table gds-list) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при закрытии документа " vardoc-code skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
    view-as alert-box error.
    return error.
  end.
  /* Проверка ассортиментной политики */
  define variable vv-gds-code as integer   no-undo .

  for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
    { gbl/gds-code.i
      bf_doc-line.artic
      bf_doc-line.prod-type
      bf_doc-line.prod-code
      vv-gds-code
    }
    var-ok-assort-pol = true .
    if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
         v-event-code = substitute("mf_&1" ,bf_trn-doc.ext-doc-type ) .
        { gbl/goassizt.i
          v-event-code
          vv-gds-code
          bf_trn-doc.obj-type
          bf_trn-doc.obj-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
        }
    end.
    if var-ok-assort-pol = false then do:
        bf_trn-doc.PS = bf_trn-doc.PS + {&new-line} + var-mess-assort-pol .
    end.
  end.
  /* рассчитываем шапку накладной */
  run gbl/calc-trn.p (input ? /*parparentproc*/ , input recid(bf_trn-doc)) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
  /* Создать поставку - свзязку если нужно */
    run cus/oo-mkrcv.p (
        buffer bf-src_trn-doc ,
        buffer bf_trn-doc  )
        no-error .
  if error-status :error then do:
    undo, return error return-value.
  end.

/*  /* В стандартном случае она должна уйти в новости по вызову callnews.p. Обрабатываем особый случай. */*/
/*  теперь все должно уходить стандартно, так же как и с обычными документами!!! */
/*  if  g#news                                                   and  /*в новостях*/*/
/*      g#db-num            =  0                                and  /*в главной базе данных*/*/
/*      bf-cur-obj_clients.db-num  <> bf-hold-obj_clients.db-num and  /*при генерации для другой базы данных*/*/
/*      bf-hold-obj_clients.db-num <> 0                          and  /*но не для главной БД*/*/
/*      bf-cur-obj_clients.db-num  <> 0                               /*и не от главной БД*/*/
/*      then do:*/
/*    /* маршрутизируем документ для отправки в УБД */*/
/*    run str/callnews.p*/
/*      (input "trn-doc"*/
/*      ,input (buffer bf_trn-doc:handle)*/
/*      ).*/
/*  end.*/
end. /* do for */