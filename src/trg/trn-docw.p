block-level on error undo, throw.
/*

$Revision: c96af91888ad, 3081, rls $
$Author: SSlivenko $
$Date: 2022/08/05 16:16:26 $
$Workfile: trn-docw.p $
$Archive: trg/trn-docw.p $

Триггер на запись документа

Автор: Чернова Светлана Александровна
Дата создания: 05/04/07
Author: Svetlana Chernova
Creation date: 05/04/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/01/00
Первоначальный автор неизвестен

*/
using ibs.th.str.alcohol.*.

TRIGGER PROCEDURE FOR WRITE OF ub.trn-doc OLD BUFFER old-doc .

define variable vss-revision    as character no-undo initial "$Revision: c96af91888ad, 3081, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2022/08/05 16:16:26 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: trn-docw.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: trg/trn-docw.p $":U .
define variable vss-description as character no-undo initial "Триггер на запись документа":U .

&scoped-define IF_MESSAGE if g#news = false and g#esys = false and g#auto = false then

define variable chg-qnty      as   decimal no-undo .

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',ub.trn-doc.doc-code,ub.trn-doc.ext-doc-type,ub.trn-doc.status_,ub.trn-doc.flag_)" }
{ cmp/trg-def.i  }
{ trg/gdsobjcl.i }
{ trg/cust_prc.i }
{ trg/factord.i  }
{ trg/trndocrs.i }
{ trg/trndocgs.i }
{ trg/tdparts.i  }
{ trg/partrqst.i }
{ str/lib-trn.i  }
{ str/hvrdtax.i  }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ trg/set-cli.i  }
{ trg/trnbccr.i  }
{ gbl/tax-name.i }
{ str/chkprice.i }
{ str/chksltpc.i }
{ str/chkvatpc.i }
{ str/prl-vat.i  }
{ trg/r-crsa.i   }
{ rep/r-sale.i   }
{ trg/chkzero.i  }
{ trg/lggdstrn.i }
{ gbl/cur-time.i }
{ trg/clientsh.i }
{ str/libtfarh.i }
{ cmp/library.i  }
{ gbl/getsect.i def }
{ gbl/lineattr.i }
{ str/trdcalib.i }
{ gbl/clntattr.i }

define variable num_rec          as integer   no-undo .
define variable num_gds          as integer   no-undo .
define variable v-start-time     as int64     no-undo .
define variable v-current-time   as character no-undo .
define variable v-current-action as character no-undo .

define variable v-price-cli                like ub.doc-line.price-rubl no-undo.
define variable v-price-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax           like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp          like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp      like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs        like ub.doc-line.price-rubl no-undo.
define variable v-price-slt                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt             like ub.doc-line.price-rubl no-undo.
define variable v-price-vat                like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define variable v-price-rubl               like ub.doc-line.price-rubl no-undo.
define variable v-price-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define variable v-price-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define variable v-price-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define variable v-price-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define variable v-price-slt-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define variable v-price-vat-rubl           like ub.doc-line.price-rubl no-undo.
define variable v-price-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define variable v-price-base               like ub.doc-line.price-base no-undo.
define variable v-price-road-tax-base      like ub.doc-line.price-base no-undo.
define variable v-price-other-exp-base     like ub.doc-line.price-base no-undo.
define variable v-price-transport-exp-base like ub.doc-line.price-base no-undo.
define variable v-price-without-abs-base   like ub.doc-line.price-base no-undo.
define variable v-price-slt-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-slt-base        like ub.doc-line.price-base no-undo.
define variable v-price-vat-base           like ub.doc-line.price-base no-undo.
define variable v-price-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define variable p-error as logical   no-undo .
define variable v-message as character no-undo .
define variable v-event-code as character no-undo .
define variable par-is-pharm as character no-undo .
define variable v-varsum     as decimal no-undo .
define variable v-is-bge as character no-undo.
define variable v-bge-incr-last-shift-date as character no-undo.
define variable v-bge-incr-last-shift-num as character no-undo.
define variable v-type as character no-undo.
define variable loc#in-ov as logical no-undo.
define variable v-not-close-news as logical no-undo .
/* дата документа или дата фактического закрытия документа
   при закрытии по факту
 */
define variable v-document-date        as date      no-undo .

define variable l-is-custm             as logical   no-undo initial false . /* таможня - да/нет */
define variable v-is-hold              as logical   no-undo .
define variable v-need-send            as logical   no-undo initial false .

define variable v-description-doc-type as character no-undo .

define variable loc#obj-active  as logical no-undo. /* текущ. объект: yes - активный */
define variable loc#side-active as logical no-undo. /* текущ. сторона: yes - активная */

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define variable v-min-ass-exist  as logical   no-undo init false .

define variable v-sale-auto                as   logical                no-undo.
define variable v-trdcattr-value           as   character              no-undo .
define variable v-trdcattr-type            as   character              no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-new-trn-doc       as logical   no-undo . /* true - документ создан, false - документ изменён */

define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .

define buffer buf_goods       for ub.goods .
define buffer buf_es_trn-doc  for ub.trn-doc.
define buffer buf_doc-line    for ub.doc-line .
define buffer buf_inv-line    for ub.inv-line .
define buffer buf_gds-dtl     for ub.gds-dtl .
define buffer buf_parts       for ub.parts .
define buffer buf-obj_clients for ub.clients .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_previous-shift-obj for ub.shift-obj.

assign
  v-description-doc-type = ub.trn-doc.doc-type
                         + " " + string(ub.trn-doc.internal, "внут/внеш")
.

/* для показа процесса закрытия документа */
def frame a
  ub.trn-doc.doc-code                           label "Документ"             skip
  v-description-doc-type                        label "Тип документа"        skip
  v-current-action       format "x(40)":U    no-label                        skip
  num_rec                format ">>>>>>>9":U    label "Обработано артикулов" skip
  buf_doc-line.artic                            label "Текущий артикул"      skip
  num_gds                format ">>>>>>>9":U    label "Обработано признаков" skip
  v-current-time         format "x(8)":U        label "Время"                skip
with view-as dialog-box side-labels three-d
     title "Обработка документа"
  .


MAIN-BLOCK:
do transaction
on error   undo main-block, return error substitute('trn-docw error main-block,&1', return-value )
on end-key undo main-block, return error substitute('trn-docw end-key main-block,&1', return-value )
:

  assign
    v-new-trn-doc = new(ub.trn-doc)
  .
  
  /* --- Проверки на основе данных редактируемой записи --- */
  
  /* проверяем правильность задания типа документа */
do :
  if ub.trn-doc.ext-doc-type = ""
  or ub.trn-doc.ext-doc-type = ?
  then do:
    v-message = "Не задан расширенный тип документа" .
    {&IF_MESSAGE}
    message
      vss-workfile vss-revision vss-description skip
      v-message skip
      "Документ" ub.trn-doc.doc-code skip
      "Тип документа" ub.trn-doc.ext-doc-type skip
      "doc-type" ub.trn-doc.doc-type skip
      "internal" ub.trn-doc.internal skip
      "discnt-type" ub.trn-doc.discnt-type skip
      "ret-supp" ub.trn-doc.ret-supp skip
      "pay-code" ub.trn-doc.pay-code skip
      view-as alert-box error .
    undo main-block, return error v-message .
  end.
  if v-new-trn-doc = false
  and ub.trn-doc.ext-doc-type <> old-doc.ext-doc-type
  and not (old-doc.ext-doc-type = {&TDEDT_Pri_Perem} or ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Perem})
  then do:
    /* новое в 16.0 по сравнению с 15.1: расширенный тип документа можно менять с &TDEDT_Pri_Perem на любой, либо с любого на &TDEDT_Pri_Perem */
    v-message = "Расширенный тип документа нельзя менять" .
    {&IF_MESSAGE}
    message
      vss-workfile vss-revision vss-description skip
      v-message skip
      "Документ" ub.trn-doc.doc-code skip
      "Новый тип документа" ub.trn-doc.ext-doc-type skip
      "Старый тип документа" old-doc.ext-doc-type skip
      "doc-type" ub.trn-doc.doc-type skip
      "internal" ub.trn-doc.internal skip
      "discnt-type" ub.trn-doc.discnt-type skip
      "ret-supp" ub.trn-doc.ret-supp skip
      "pay-code" ub.trn-doc.pay-code skip
      view-as alert-box error .
    undo, return error v-message .
  end.
  else do:
    if old-doc.ext-doc-type <> ub.trn-doc.ext-doc-type then do:
      for each buf_doc-line exclusive-lock where
               buf_doc-line.doc-code = ub.trn-doc.doc-code
      :
        buf_doc-line.ext-doc-type = ub.trn-doc.ext-doc-type.  
      end.  
    end.  
  end.
  { gbl/chkextdt.i
    ub.trn-doc
    no-error
  }
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при проверке типа документа.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    {&IF_MESSAGE}
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
end . /* end_of проверяем правильность задания типа документа */
  
  /* --- Проверки на основе данных, связанных с редактируемой записью --- */


  
  run init-local-vars in this-procedure no-error .
  /* установлен буффер ub.store или ub.shop, заполнены loc#obj-active и loc#in-ov */
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при инициализации глобальных переменных.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    {&IF_MESSAGE}
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.


  define variable custvalue     as character initial ? no-undo.
  define variable custtype      as character initial ? no-undo.

  { gbl/conf-rd.i
    "'is-custm'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    custvalue
    custtype
    no-error
  }
  if error-status :error then do:
    /* параметр может быть не задан */
  end.
  else do:
    assign
      l-is-custm = can-do("yes,true", custvalue)
    .
  end.


{ gbl/conf-rd.i "'is-pharm'" ub.trn-doc.host-code ub.trn-doc.obj-type ub.trn-doc.obj-code "''" "''" "''" no  par-is-pharm  par-type no-error } .
if par-is-pharm <> "yes"  then par-is-pharm = "no" .
else do:
   { str/opharm.i ub.trn-doc.obj-type ub.trn-doc.obj-code par-is-pharm }
end.




  /* проверяем уникальность кода документа */
  run trg/chkdocnm.p
    (input ub.trn-doc.doc-code /* p-doc-code   */
    ,input {&table_trn-doc}    /* p-table-name */
    ,input recid(ub.trn-doc)   /* p-recid      */
    ) no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при проверке уникальности кода документа.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    {&IF_MESSAGE}
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.

  /* @futu добавить вызов curr-time() */

  if v-new-trn-doc = true then do:
   assign
      ub.trn-doc.real-date-create = today
      ub.trn-doc.real-time-create = time
   .
  end.
  find first ub.clients no-lock
    where ub.clients.obj-type = ub.trn-doc.cli-type
      and ub.clients.obj-code = ub.trn-doc.cli-code
    no-error .
  if  v-new-trn-doc = true
  then do:

    define variable v-vid-action  as integer    no-undo.
    define variable v-vid-param   as longchar   no-undo.

    { str/initiator.i }
  
    v-vid-action = 55 .
    v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                  "SHOP_NUM=" + string(ub.trn-doc.obj-code) + {&delim-par} +
                  "DocNum=" + string(ub.trn-doc.doc-code) + {&delim-par} +
                  "DocType=" + string(ub.trn-doc.doc-type) + {&delim-par} +
                  "RESULT=0" + {&delim-par} + 
                  "Description=".
    
    run trg/userlog.p (
          input {&nwsdochs_action_create}
        , input {&table_trn-doc}
        , input ( buffer ub.trn-doc :handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.

  end.
  if not available ub.clients
  then do:
    if  v-new-trn-doc = true
    and g#news = false
    and ub.trn-doc.cli-type = ?
    and ub.trn-doc.cli-code = ?
    then do:
      /* это создается новая запись - не выполняем триггер */
      return .  /* --->>>--- */
    end.
    else do:
      {&IF_MESSAGE}
      message
        vss-workfile vss-revision vss-description skip
        "Указан неправильный контрагент" skip
        "Документ" ub.trn-doc.doc-code skip
        "Контрагент" ub.trn-doc.cli-type ub.trn-doc.cli-code skip
        "Документ новый" v-new-trn-doc skip
        "Новости" g#news skip
        view-as alert-box error .
      return error return-value .
    end.
  end.

  assign
    ub.trn-doc.cli-name = ub.clients.obj-name
  .

  define buffer trn-doc_clients for ub.clients .
  find first trn-doc_clients no-lock
    where trn-doc_clients.obj-type = ub.trn-doc.obj-type
      and trn-doc_clients.obj-code = ub.trn-doc.obj-code
    no-error .
  if not available trn-doc_clients
  then do:
    {&IF_MESSAGE}
    message
      vss-workfile vss-revision vss-description skip
      "Не найден объект" skip
      "Документ" ub.trn-doc.doc-type skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* TODO текущая сторона пассивная/активная сторона */
  if trn-doc_clients.db-num = g#db-num
  then do:
    assign
      loc#side-active = loc#obj-active
    .
  end.
  else do:
    assign
      loc#side-active = not loc#obj-active
    .
  end.

  /* обновляем пользователя, дату и время последнего обновления */
  if not g#news or v-not-close-news
  then do:
    { gbl/curdburt.i
      ub.trn-doc.user-db-num
      ub.trn-doc.user-name
      ub.trn-doc.sys-date
      ub.trn-doc.sys-time
      ub.trn-doc.sys-time-int
    }

    /* и обновляем fact-order при изменении fact-date */
    if old-doc.fact-order > 0 and old-doc.fact-date <> trn-doc.fact-date then
    do:
      run factord in this-procedure
        (input  ub.trn-doc.fact-date   /* p-fact-date            */
        ,input  ub.trn-doc.fact-time   /* p-fact-time            */
        ,input  ub.trn-doc.fact-num    /* p-fact-num             */
        ,input  ub.trn-doc.shift-date  /* p-shift-date           */
        ,input  ub.trn-doc.shift-num   /* p-shift-num            */
        ,input  l-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0
      then do:
        {&IF_MESSAGE}
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-date"               ub.trn-doc.fact-date   skip
          "fact-time"               ub.trn-doc.fact-time   skip
          "fact-num"                ub.trn-doc.fact-num    skip
          "shift-date"              ub.trn-doc.shift-date  skip
          "shift-num"               ub.trn-doc.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        ub.trn-doc.fact-order = v-fact-order
      .
    end.
  end.

  if ub.trn-doc.status_ = {&cash-desk}
  then do:
    return . /* --->>>--- */
  end.

  if  ub.trn-doc.status_ = old-doc.status_
  and ub.trn-doc.flag_   = old-doc.flag_
  then do:
    if ub.trn-doc.status_ = {&fact} and
      (ub.trn-doc.buyer-fo-date <> old-doc.buyer-fo-date  or
       ub.trn-doc.cr-fo-buyer   <> old-doc.cr-fo-buyer    or
       ub.trn-doc.need-buyer    <> old-doc.need-buyer    ) then  do:
       run trn-doc-cmd-chance-h-fo ( input ub.trn-doc.doc-code ) .
    end.
    if ub.trn-doc.status_ = {&fact} and
      (ub.trn-doc.factur-date    <> old-doc.factur-date  or
       ub.trn-doc.cr-factur      <> old-doc.cr-factur    or
       ub.trn-doc.need-factur    <> old-doc.need-factur   ) then  do:
       run trn-doc-cmd-chance-h-factur ( input ub.trn-doc.doc-code ) .
    end.


    return . /* --->>>--- */
  end.
/*-----------------------------------------------------------------------------------------------------------------*/
  /* накладываем блокировку на все используемые товары */
  /* при этом проверяется, что товар не входит в другие документы инвентаризации */
  /* ??? надо пересмотреть условие, так как у нас есть
     документы инвентаризации пересортицы */
  define variable l-need-check-inv as logical no-undo initial false .

  define variable v-old-can-edit-inv-on as character no-undo .

  if available old-doc
  then do:
    { gbl/trnat.i
      old-doc.doc-type
      old-doc.internal
      old-doc.discnt-type
      old-doc.status_
      old-doc.flag_
      old-doc.ext-doc-type
      "'can-change-status-inv-on=request'"
      v-old-can-edit-inv-on
      no-error
    }
    if error-status :error
    then do:
      {&IF_MESSAGE}
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признак складского документа (old-doc)" skip
        "Документ" ub.trn-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
  else do:
    /* если документ не существовал, то считается что мы могли его редактировать */
    assign
      v-old-can-edit-inv-on = "true":u
    .
  end.

  define variable v-new-can-edit-inv-on as character no-undo .

  { gbl/trnat.i
    ub.trn-doc.doc-type
    ub.trn-doc.internal
    ub.trn-doc.discnt-type
    ub.trn-doc.status_
    ub.trn-doc.flag_
    ub.trn-doc.ext-doc-type
    "'can-change-status-inv-on=request'"
    v-new-can-edit-inv-on
    no-error
  }
  if error-status :error
  then do:
    {&IF_MESSAGE}
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно запросить признак складского документа (trn-doc)" skip
      "Документ" ub.trn-doc.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if not g#news
  then do:
    if v-new-can-edit-inv-on <> "true":u
    or v-old-can-edit-inv-on <> "true":u
    or ub.trn-doc.status_ = {&fact}
    or (ub.trn-doc.doc-type    = {&inventory}
        and ( ub.trn-doc.status_ = {&permitted}
              or ub.trn-doc.status_ = {&rvs-froze}
             )
        and ub.trn-doc.flag_   = true
        )
    then do:
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = ub.trn-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'invMultDevice' and ub.inv-doc-attr.attr-value = string(true) no-error .
      if not available (ub.inv-doc-attr) then l-need-check-inv = true .
    end.

    /* мы переключаемся из статуса разр + */
    /* товар помечен, как находящийся в инвентаризации */
    /* поэтому мы отключаем проверку инвентаризации */
    if not new ub.trn-doc
    and old-doc.doc-type     = {&inventory}
    and
       (   ( old-doc.status_ = {&permitted} or old-doc.status_ = {&rvs-froze} )
       and old-doc.flag_        = true
       and old-doc.ext-doc-type = {&TDEDT_Inv} or
           old-doc.status_      = {&wayb}
       and old-doc.flag_        = false
       and old-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price} or
           old-doc.status_      = {&wayb}
       and old-doc.flag_        = false
       and old-doc.ext-doc-type = {&TDEDT_Peresort}
       )
    then do:
      assign
        l-need-check-inv = false
      .
    end.
  end.

  if  not new ub.trn-doc
  and old-doc.status_    = {&fact}
  and ub.trn-doc.status_ <> {&fact}
  then do:
    {&IF_MESSAGE}
    message
      vss-workfile vss-revision vss-description skip
      "Изменение статуса документа невозможно" skip
      "Документ" ub.trn-doc.doc-code skip
      "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
      "Документ закрыт до статуса" {&fact} skip
      "Нельзя изменить статус документа на" ub.trn-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.
  define buffer buf_sale-doc for ub.sale-doc.
  if not g#news
  and ub.trn-doc.out-code <> '':U
  and LOOKUP(ub.trn-doc.ext-doc-type, {&sale-add-ext-doc-types}) > 0 then do:
    find first buf_sale-doc no-lock  where
             buf_sale-doc.doc-code = ub.trn-doc.doc-code
         and buf_sale-doc.inkas-code = ub.trn-doc.out-code no-error .
    if available buf_sale-doc
    and buf_sale-doc.order > 0 then do:
      v-sale-auto = yes.
    end.
  end.

  /* определяем текущую дату документа или дату закрытия документа по факту */
  if ub.trn-doc.status_ = {&fact}
  then do:
    if  ub.trn-doc.fact-num = 0
    and /* не новости */
        ( ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
         or ub.trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
        )
    and ub.trn-doc.obj-type <> {&shop}
    then do:
      {&IF_MESSAGE}
      message
        vss-workfile vss-revision vss-description skip
        "Продажа через магазин может быть закрыта только на объекте типа магазин" skip
        "Документ" ub.trn-doc.doc-code skip
        "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
        view-as alert-box error .
      undo main-block, return error return-value .
    end.

    if not g#news and not g#esys
    then do:
    /* проверяем факт дату, время */
      if ub.trn-doc.fact-date = ? and ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Object} then do :
        { gbl/curobjdt.i ub.trn-doc.obj-type ub.trn-doc.obj-code ub.trn-doc.fact-date }    
      end.
      run gbl/chk-date.p
        (input ub.trn-doc.obj-type
        ,input ub.trn-doc.obj-code
        ,input ub.trn-doc.fact-date
        ,input ub.trn-doc.fact-time
        ,input ub.trn-doc.shift-date
        ,input ub.trn-doc.shift-num
        ,input yes
        ) no-error .
      if error-status :error
      then do:
        {&IF_MESSAGE}
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при установке дат, времен, смен в документе (trn-doc)." skip
            "Документ" ub.trn-doc.doc-code skip
            "fact-date"  ub.trn-doc.fact-date  skip
            "fact-time"  ub.trn-doc.fact-time  skip
            "shift-date" ub.trn-doc.shift-date skip
            "shift-num"  ub.trn-doc.shift-num  skip
          error-status :get-message(1) skip
          return-value skip
        view-as alert-box error .
        undo main-block, return error return-value .
      end.
    end.
    assign
      v-document-date = ub.trn-doc.fact-date
    .
    if v-document-date = ?
    then do:
      assign
        v-message = substitute( "&1. Не задана фактическая дата документа.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.
  else do:
/*    assign*/
/*      v-document-date = ub.trn-doc.doc-date*/
/*    .*/
    /* резервирование всегда производим текущей датой */
    assign
      v-document-date = ?
    .
  end.
  if ub.trn-doc.status_ = {&fact} and not g#news
  then do:
    /*локируем запись финансовых архивов по своим контрактам*/
    { str/latrncnt.i ub.trn-doc.doc-code no-error }
    if error-status :error then do:
      return error substitute ("&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2)).
    end.
/*    find first ub.user-account no-lock where ub.user-account.user-id = g#userid no-error.                */
/*    if available (ub.user-account) and not (ub.user-account.psn-code = 0 or ub.user-account.psn-code = ?)*/
/*    then do:                                                                                             */
/*      ub.trn-doc.wrkr = ub.user-account.psn-code.                                                        */
/*    end.                                                                                                 */
  end.

  /* определяем фактический номер документа */
  if ub.trn-doc.status_ = {&fact}
  then do:
    if g#news
    then do:
      if ub.trn-doc.fact-num = ?
      or ub.trn-doc.fact-num = 0
      then do:
        assign
          v-message = substitute( "&1. fact-num не задан в складском документе.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.

      if ub.trn-doc.fact-order = ?
      or ub.trn-doc.fact-order = 0
      then do:
        {&IF_MESSAGE}
        message
          vss-workfile vss-revision vss-description skip
          "fact-order не задан в складском документе" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-order" ub.trn-doc.fact-order skip
          view-as alert-box error .
        undo main-block, return error return-value .
      end.
    end.

    if not g#news or v-not-close-news
    then do:
      if ub.trn-doc.fact-num > 0
      then do:
        {&IF_MESSAGE}
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-num" ub.trn-doc.fact-num skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if ub.trn-doc.fact-order > 0
      then do:
        {&IF_MESSAGE}
        message
          vss-workfile vss-revision vss-description skip
          "Ошибочно задан фактический номер складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-order" ub.trn-doc.fact-order skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* определяем порядковый номер */
      assign
        ub.trn-doc.fact-num = next-value (s-trn-fact, {&db-name_schema})
      .

      /* определяем fact-order */
      { gbl/objat.i
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if error-status :error
      then do:
        {&IF_MESSAGE}
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута объекта" skip
          "Документ" ub.trn-doc.doc-code skip
          "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error return-value .
      end.

      run factord in this-procedure
        (input  ub.trn-doc.fact-date   /* p-fact-date            */
        ,input  ub.trn-doc.fact-time   /* p-fact-time            */
        ,input  ub.trn-doc.fact-num    /* p-fact-num             */
        ,input  ub.trn-doc.shift-date  /* p-shift-date           */
        ,input  ub.trn-doc.shift-num   /* p-shift-num            */
        ,input  l-shift-on             /* p-shift-on             */
        ,output v-fact-order           /* p-fact-order           */
        ,output v-shift-end-fact-order /* p-shift-end-fact-order */
        ,output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0
      then do:
        {&IF_MESSAGE}
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера складского документа" skip
          "Документ" ub.trn-doc.doc-code skip
          "fact-date"               ub.trn-doc.fact-date   skip
          "fact-time"               ub.trn-doc.fact-time   skip
          "fact-num"                ub.trn-doc.fact-num    skip
          "shift-date"              ub.trn-doc.shift-date  skip
          "shift-num"               ub.trn-doc.shift-num   skip
          "v-fact-order"            v-fact-order           skip
          "v-shift-end-fact-order"  v-shift-end-fact-order skip
          "v-day-end-fact-order"    v-day-end-fact-order   skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        ub.trn-doc.fact-order = v-fact-order
      .
    end.
  end.

  if ub.trn-doc.status_ = {&inquiry}
  then do:
    /* обработать запрос */
    run process-inquiry in this-procedure no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при обработке документа запроса.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
    return . /* --->>>--- */
  end.

  /* блокируем товары на объекте */
  run trg/lock-gds.p
    (input ub.trn-doc.doc-code            /* v-trn-doc-doc-code     */
    ,input l-need-check-inv               /* p-check-inv            */
    ,input no                             /* p-check-inv-rasr-minus */
    ,input (if ub.trn-doc.is-back-date = yes   /* p-document-fact-order  */
            then 0
            else ub.trn-doc.fact-order)   /* p-document-fact-order-price  */
    ,input (if ub.trn-doc.is-back-date = yes
            then 0
            else ub.trn-doc.fact-order)   /* p-document-fact-order-price  */
    ,input (ub.trn-doc.status_ = {&fact}) /* p-fact-close           */
    ,input g#news                         /* p-is-news              */
    ) no-error .
  if error-status :error
  then do:
    assign
      v-message = substitute( "&1. Не удалось наложить блокировку на все товары принадлежащие документу.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    {&IF_MESSAGE}
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.
  if  ub.trn-doc.is-back-date
  and ub.trn-doc.status_ = {&fact}
  and not g#news
  then do:
    run check-close-back-date in this-procedure no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Недопустимо закрытие данного документа.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.

  if  ub.trn-doc.doc-type = {&inventory}
  and not g#news
  then do:
    define variable l-old-inv-on as logical no-undo init false .
    define variable l-new-inv-on as logical no-undo init false .

    if  ( old-doc.status_    = {&permitted}
          or old-doc.status_ = {&rvs-froze}
        )
    and old-doc.flag_        = true
    and old-doc.ext-doc-type = {&TDEDt_Inv}
    then do:
      assign
        l-old-inv-on = true
      .
    end.
    if  old-doc.status_      = {&wayb}
    and old-doc.flag_        = false
    and old-doc.ext-doc-type = {&TDEDt_Corr_Acc_Price}
    then do:
      assign
        l-old-inv-on = true
      .
    end.
    if  old-doc.status_      = {&wayb}
    and old-doc.flag_        = false
    and old-doc.ext-doc-type = {&TDEDT_Peresort}
    then do:
      assign
        l-old-inv-on = true
      .
    end.

    if  ( ub.trn-doc.status_    = {&permitted}
          or ub.trn-doc.status_ = {&rvs-froze}
        )
    and ub.trn-doc.flag_        = true
    and ub.trn-doc.ext-doc-type = {&TDEDT_Inv}
    then do:
      assign
        l-new-inv-on = true
      .
    end.

    if l-new-inv-on <> l-old-inv-on
    then do:
      for each buf_doc-line no-lock
        where buf_doc-line.doc-code = ub.trn-doc.doc-code
      on error undo main-block, return error return-value
      :
        define variable l-inv-on as logical no-undo .
        define variable v-inv-on-attr as character no-undo .

        assign
          v-inv-on-attr = "inv-on=" + (if l-new-inv-on then "true" else "false")
        .
        find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = ub.trn-doc.doc-code and
          ub.inv-doc-attr.attr-code = "invMultDevice" and 
          ub.inv-doc-attr.attr-value = string(true) no-error .
        if available(ub.inv-doc-attr) then return .
 
        { gbl/gdsobjat.i
          buf_doc-line.obj-type
          buf_doc-line.obj-code
          buf_doc-line.artic
          buf_doc-line.prod-type
          buf_doc-line.prod-code
          v-inv-on-attr
          l-inv-on
          no-error
        }
        if error-status :error
        then do:
          {&IF_MESSAGE}
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка установки атрибута товара на объекте" skip
            "Документ" ub.trn-doc.doc-code skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "l-new-inv-on" l-new-inv-on skip
            view-as alert-box error .
          undo main-block, return error return-value .
        end.
      end.
    end.
  end.

  if  ub.trn-doc.status_ = {&permitted}
  and ub.trn-doc.flag_   = no
  then do:
    return . /* --->>>--- */
  end.

  assign
    v-start-time = etime
  .
  assign
    v-current-action = "Обработка товара."
  .

  view frame a.
  display
    ub.trn-doc.doc-code
    v-description-doc-type
    with frame a.

  /* проверяем, что фирма правильно заполнена */
  define variable v-host-code like ub.trn-doc.host-code no-undo .

  { gbl/hostcode.i
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
    v-host-code
    no-error
  }
  if error-status :error
  then do:
    {&IF_MESSAGE}
    message
      vss-workfile vss-revision vss-description skip
      "Ошика при определении кода фирмы для объекта" skip
      "Документ" ub.trn-doc.doc-code skip
      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.
  if ub.trn-doc.host-code <> v-host-code
  then do:
    {&IF_MESSAGE}
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Документ" ub.trn-doc.doc-code skip
      "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
      "Объект"  ub.trn-doc.obj-type ub.trn-doc.obj-code skip
      "Фирма"   ub.trn-doc.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error return-value .
  end.

  if not g#news or v-not-close-news
  then do:
    /* инициализируем признак того, что была автоматическая переоценка */
    assign
      ub.trn-doc.ov        = no
    .

    /* определяем пользователя */
    if ub.trn-doc.status_ = {&permitted}
      or ub.trn-doc.status_ = {&rvs-froze}
    then do:
      assign
        ub.trn-doc.creid = g#userid
      .
    end.

    if ub.trn-doc.creid = ""
    then do:
      assign
        ub.trn-doc.creid = g#userid
      .
    end.
  end.

  run show-action in this-procedure
    (input "Обновляем суммы по документу"
    ).
  run update-doc-sum in this-procedure
    (input ub.trn-doc.doc-code   /* p-doc-code */
    ,input ub.trn-doc.fact-order /* p-fact-order */
    ) no-error .
  if error-status :error
  then do:
    assign
      v-message = substitute( "&1. Ошибка при обработке сумм по документу.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    {&IF_MESSAGE}
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.

  run show-action in this-procedure
    (input "Обработка строк документа"
    ).
  for each buf_doc-line exclusive-lock
    where buf_doc-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error return-value
  :
    run process-line in this-procedure no-error .
    if error-status :error
    then do:
      {&IF_MESSAGE}
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара" skip
        "Документ" ub.trn-doc.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error return-value .
    end.
  end.

  /* создаем атрибуты партий */
  if  not g#news
  and ub.trn-doc.status_ = {&fact}
  then do:
    run show-action in this-procedure
      (input "Создание атрибутов партий"
      ).
    run trg/prtatrcr.p
      (input ub.trn-doc.doc-code /* p-doc-code   */
      ,input false               /* p-create-all */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при создании атрибутов партий.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.

  /* создаем документы, которые необходимо порождать при внутреннем перемещении */
  if  ub.trn-doc.status_  = {&fact}
  and lookup(ub.trn-doc.doc-type, {&expense_income}) > 0
  and ub.trn-doc.internal = yes
  and ub.trn-doc.discnt-type <> {&manufactured}
  and ub.trn-doc.ext-doc-type <> {&TDEDT_Pri_Object}
  then do:
    run show-action in this-procedure
      (input "Создание внутренних перемещений"
      ).
    run trg/trndocmv.p
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при создании документа внутреннего прихода/возврата.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.

  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  /* создаем документы, межфирменных перемещений                                   */
  /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
  define variable hold-value as character no-undo .
  define variable hold-type  as character no-undo.

  define variable v-holding as logical   no-undo .

  { gbl/conf-rd.i
    "'holding'"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    hold-value
    hold-type
    no-error
  }
  if  ( not error-status :error )
  and hold-value = "yes"
  then do:
    assign
      v-holding = true
    .
  end.
  else do:
    assign
      v-holding = false
    .
  end.

  if v-holding = true
  then do:
    if  ub.trn-doc.status_  = {&fact}
    and (ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or
         ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
         ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh})
    then do:
      run show-action in this-procedure
        (input "Создание межфирм. перемещений"
        ).
      run trg/trndocmh.p
        (input ub.trn-doc.doc-code
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Ошибка при создании документа межфирменного прихода/возврата.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.
  end.
  /* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11111111111 */


  if ub.trn-doc.status_  = {&fact}
  then do:
    /* в партии записывается fact-num, fact-date текущего документа */
    /* данная операция должна производиться после */
    /* создания документа внутреннего перемещения */
    run show-action in this-procedure
      (input "Обработка архивных партий"
      ).
    run update-archive-parts-on-fact-close in this-procedure no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при обработке архивных партий документа.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.

    if g#news = false then do:
      /* расчет шапки документа в учетных ценах
        и дополнительных сумм по документу

        выполняется только на активной стороне
      */
      run show-action in this-procedure
        (input "Расчет шапки накладной"
        ).
      run str/calc-hd.p
        (input ub.trn-doc.doc-code /* v-doc-code */
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Ошибка при расчете шапки документа.&2Информация об ошибке выведена в файл calc-hd.err&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
      /*рассчитываем финансовые архивы*/
      { str/catrncnt.i ub.trn-doc.doc-code no-error }
      if error-status :error then do:
        return error substitute ("&1 &2 &3", return-value, error-status :get-message(1), error-status :get-message(2)).
      end.
    end.

    run show-action in this-procedure
      (input "Проверка целостности документа"
      ).
    run validate-trn-doc in this-procedure no-error .
    if error-status :error
    then do:
      undo main-block, return error return-value .
    end.

    if ub.trn-doc.is-back-date = true
    then do:
      run show-action in this-procedure
        (input "Пересчет топливных остатков в последующих документах"
        ).
      { str/reclcptr.i
        "(buffer ub.trn-doc:handle)"
        ?
        1.0
        ub.trn-doc.ext-doc-type
        "dynamic-next-value('s-corr-chip':U,'{&db-name_schema}':U)"
        no-error
      }
      if error-status :error then do:
        assign
          v-message = substitute( "&1. Ошибка пересчета факт. кол-ва топлива в последующих документах.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.
  
  /* Если у документа статус факт и он закрыт задним числом */

  /* Проверим что объект сменный */  
      { gbl/objat.i
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        "'shift-on=request'"
        l-shift-on
        no-error
      }
      if error-status :error
      then do:
        {&IF_MESSAGE}
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута объекта" skip
          "Документ" ub.trn-doc.doc-code skip
          "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error return-value .
      end.
  
  if l-shift-on then do:  

    /* Проверим is-bge */
      { gbl/conf-rd.i
        "'is-bge':U"
        "'':U"
        "'':U"
        0
        "'':U"
        "'':U"
        "'':U"
        no
        v-is-bge
        par-type
        no-error
      }
      if v-is-bge = 'yes' or v-is-bge = 'true' then do:

        run clntattr-value(ub.trn-doc.obj-type,
                           ub.trn-doc.obj-code,
                           {&attr-bge-incr-last-shift-date},
                           output v-bge-incr-last-shift-date,
                           output v-type).
      
        run clntattr-value(ub.trn-doc.obj-type,
                           ub.trn-doc.obj-code,
                           {&attr-bge-incr-last-shift-num},
                           output v-bge-incr-last-shift-num,
                           output v-type).      

        /* Проверим, была ли выгружена эта смена в инкрементальной выгрузке */
        if ub.trn-doc.shift-date < date(v-bge-incr-last-shift-date)
         or (ub.trn-doc.shift-date = date(v-bge-incr-last-shift-date)
           and ub.trn-doc.shift-num <= integer(v-bge-incr-last-shift-num)) then do:
             
          /* Поставим предыдущую выгруженную смену относительно документа */
          find last buf_previous-shift-obj where buf_previous-shift-obj.obj-type = ub.trn-doc.obj-type
                                             and buf_previous-shift-obj.obj-code = ub.trn-doc.obj-code
                                             and ((buf_previous-shift-obj.shift-date = ub.trn-doc.shift-date
                                                   and buf_previous-shift-obj.shift-num < ub.trn-doc.shift-num)
                                                  or buf_previous-shift-obj.shift-date < ub.trn-doc.shift-date)
                                                  use-index pi no-lock no-error.
          
          if not available(buf_previous-shift-obj) then do:
              
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                              {&attr-bge-incr-last-shift-date},
                               string(ub.trn-doc.shift-date)).
          
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                               {&attr-bge-incr-last-shift-num},
                               '0').   
          end. /* if not available */
            
          else do:
            
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                              {&attr-bge-incr-last-shift-date},
                               string(buf_previous-shift-obj.shift-date)).
          
            run clntattr-write(ub.trn-doc.obj-type,
                               ub.trn-doc.obj-code,
                               {&attr-bge-incr-last-shift-num},
                               string(buf_previous-shift-obj.shift-num)).   
          end. /* else do */
        end. /* if ub.trn-doc.shift-date */
      end. /* if v-is-bge = 'yes' */
    end. /* if l-shift-on */
  end.

  if  ( ub.trn-doc.status_ = {&wayb} and ub.trn-doc.flag_ = false ) and
        ( old-doc.flag_ = true or
          old-doc.status_ = {&permitted} )then  do:
        run nws/cmd-del.p
          ( input "trn-doc":U
          , input ( buffer ub.trn-doc :handle )
          , input "":U
          ) no-error .
        if error-status :error then do:
          return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
        end.
  end.

  /* передача документа через СПН (Система Передачи Новостей) */
  /* через СПН передаются только определенные смены статусов  */
  if  (ub.trn-doc.status_ = {&wayb}      and ub.trn-doc.flag_ = true )
      or (ub.trn-doc.status_ = {&permitted} and ub.trn-doc.flag_ = true )
      or (ub.trn-doc.status_ = {&rvs-froze} and ub.trn-doc.flag_ = true )
      or (ub.trn-doc.status_ = {&ready})
      or (ub.trn-doc.status_ = {&rejected})
      or (ub.trn-doc.status_ = {&fact})
  then do:
    run show-action in this-procedure
      (input "Проверка целостности документа"
      ).
    run trg/chktdcpl.p
      ( input ub.trn-doc.doc-code
      ) no-error.
    if error-status :error then do:
      assign
        v-message = substitute('&1 &2 &3':U, vss-workfile, vss-revision, vss-description) + {&new-line}
                  + "Ошибка при проверке целостности топливных товаров" + {&new-line}
                  + substitute('Документ &1':U, ub.trn-doc.doc-code)  + {&new-line}
                  + substitute('&1':U, return-value)  + {&new-line}
                  + substitute('&1':U, error-status :get-message(1))  + {&new-line}
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.

    if g#news = false then do:
      assign
        v-need-send = true
      .
    end.
    else do: /* в сессии СПН также могут автоматически генерироваться и отправляются документы  */
      if g#db-num = 0   /* спец. случай возможен в сессии СПН только в ГБД                      */
      then do:
        case ub.trn-doc.ext-doc-type :
          when {&TDEDT_Pri_Perem}
          or when {&TDEDT_Vozvrat_Perem}
          then do:
            /* внутреннее перемещение (trndocmv.p) */
            find first buf-obj_clients no-lock /* объект контрагента */
              where buf-obj_clients.obj-type = ub.trn-doc.cli-type
                and buf-obj_clients.obj-code = ub.trn-doc.cli-code
              no-error .
            if not available buf-obj_clients
            then do:
              undo main-block, return error substitute( "&1. Не найден объект контрагента.&2Документ &3 (&4)&2Объект &5 &6"
                                                        , vss-workfile
                                                        , {&new-line}
                                                        , ub.trn-doc.doc-code
                                                        , ub.trn-doc.ext-doc-type
                                                        , ub.trn-doc.cli-type
                                                        , ub.trn-doc.cli-code
                                                        ).
            end.
            if trn-doc_clients.db-num <> 0                         /* если объект источник (расход) живет в УБД                                   */
              and trn-doc_clients.db-num <> g#news-source-db       /* не прием закрытого на активной стороне документа                            */
              and buf-obj_clients.db-num <> 0                      /* целевой объект (приход/возврат) живет в УБД                                 */
              and trn-doc_clients.db-num <> buf-obj_clients.db-num /* причем в УБД отличной от той где живет источник (расход)                    */
            then do:
              assign
                v-need-send = true
              .
            end.
          end.
          when {&TDEDT_Pri_Vnesh}
          or when {&TDEDT_Vozvrat_Vnesh}
          then do:
            { gbl/hold-doc.i
              ub.trn-doc.doc-code
              v-is-hold
            }
            if v-is-hold = true
            then do:
              /* межфирменное перемещение (trndocmh.p) */
              find first buf-obj_clients no-lock /* объект контрагента */
                where buf-obj_clients.obj-type = ub.trn-doc.hold-obj-type
                  and buf-obj_clients.obj-code = ub.trn-doc.hold-obj-code
                no-error .
              if not available buf-obj_clients
              then do:
                undo main-block, return error substitute( "&1. Не найден объект контрагента.&2Документ &3 (&4)&2Объект &5 &6"
                                                          , vss-workfile
                                                          , {&new-line}
                                                          , ub.trn-doc.doc-code
                                                          , ub.trn-doc.ext-doc-type
                                                          , ub.trn-doc.hold-obj-type
                                                          , ub.trn-doc.hold-obj-code
                                                          ).
              end.
              if trn-doc_clients.db-num <> 0                         /* если объект источник (расход) живет в УБД                                   */
                and trn-doc_clients.db-num <> g#news-source-db       /* не прием закрытого на активной стороне документа                            */
                and buf-obj_clients.db-num <> 0                      /* целевой объект (приход/возврат) живет в УБД                                 */
                and trn-doc_clients.db-num <> buf-obj_clients.db-num /* причем в УБД отличной от той где живет источник (расход)                    */
              then do:
                assign
                  v-need-send = true
                .
              end.
            end.
          end.
        end case.
      end. /* g#db-num = 0 */
    end. /* g#news = true */

    if v-need-send = true then do:
      run trg/trn-docv.p
        ( input ub.trn-doc.doc-code
        , output p-error
        , output v-message
        ) .
      if p-error = true then do:
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
      run show-action in this-procedure
        (input "Отправка документа в новости"
        ).
      run str/callnews.p
        (input {&table_trn-doc}
        ,input (buffer ub.trn-doc:handle)
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Невозможно маршрутизировать документ для отправки в СПН.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
      if ub.trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:
       for each ub.marking-lines exclusive-lock where ub.marking-lines.out-code = ub.trn-doc.doc-code 
                                                  and ub.marking-lines.obj-code = ub.trn-doc.obj-code
                                                  and ub.marking-lines.obj-type = ub.trn-doc.obj-type:
          for each ub.marking exclusive-lock where ub.marking.mark = ub.marking-lines.mark:
            find first ub.clients where ub.clients.obj-type = ub.trn-doc.obj-type and ub.clients.obj-code = ub.trn-doc.obj-code.
            run nws/cr-route.p 
              ( input {&send-tbl}, 
                input {&table_marking}, input (buffer ub.marking:handle), input string (ub.clients.db-num) ) no-error.
          end.
        end.
      end. 
    end.
  end.


  /* если необходимо создаются бар-коды для всех порожденных партий */
  if  g#news = false
  and ub.trn-doc.status_ = {&fact}
  then do:
    run show-action in this-procedure
      (input "Создание бар-кодов для порожденных партий"
      ).
    run trnbccr in this-procedure
      (input ub.trn-doc.doc-code
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при создании бар-кодов партий.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.
  end.
  { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&edoc-proc_event_trn-doc}
    " buffer old-doc:handle "
    " buffer ub.trn-doc:handle "
    ''
    ''
    no-error
  }
  if error-status:error
  then do:
    v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,{&new-line}
                          , error-status:get-message(1)
                          , return-value ).
    {&IF_MESSAGE}
      message
      v-message
      view-as alert-box error .
    undo main-block,  return error v-message.
  end.
  
  if g#news
  and g#db-num = 0
  and ub.trn-doc.status_ = {&fact}
  then do :
    if ub.trn-doc.ext-doc-type = {&TDEDT_Inv}
    or ub.trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
    or ub.trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
    then do :
      run show-action in this-procedure
      (input "Создание документов Вывода из оборота (ОСУ) для отправки в ГИС МТ"
      ).
      run str/create-LK_RECEIPT.p (input ub.trn-doc.doc-code) .
    end .
  end .

  /****** Передача информации об остатках товара через новости ********/
  run show-action in this-procedure
    (input "Передача остатков товара через новости"
    ).
  run trg/prtobrem.p
    (input true                /* p-trn-doc    */
    ,input ub.trn-doc.doc-code /* p-doc-code   */
    ,input false               /* p-delete-doc */
    ) no-error .
  if error-status :error
  then do:
    assign
      v-message = substitute( "&1. Ошибка при передаче остатков товара через СПН.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
    .
    {&IF_MESSAGE}
      message
        v-message
        view-as alert-box error .
    undo main-block, return error v-message .
  end.

  if ub.trn-doc.status_ = {&fact}
  then do:
    run show-action in this-procedure
      (input "Регистрируем номер документа в архивах"
      ).
    run trg/nu_arh.p
      (input ub.trn-doc.doc-code /* p-doc-code   */
      ,input {&table_trn-doc}    /* p-table-name */
      ,input ub.trn-doc.obj-type /* p-obj-type   */
      ,input ub.trn-doc.obj-code /* p-obj-code   */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при вызове процедуры nu_arh.p.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.

    run trg/nu_ahsp.p
      (input ub.trn-doc.doc-code /* p-doc-code   */
      ,input {&table_trn-doc}    /* p-table-name */
      ,input ub.trn-doc.obj-type /* p-obj-type   */
      ,input ub.trn-doc.obj-code /* p-obj-code   */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при вызове процедуры nu_ahsp.p.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.

    run trg/nu_aht.p
      (input ub.trn-doc.doc-code /* p-doc-code   */
      ,input {&table_trn-doc}    /* p-table-name */
      ,input ub.trn-doc.obj-type /* p-obj-type   */
      ,input ub.trn-doc.obj-code /* p-obj-code   */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при вызове процедуры nu_aht.p.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.

    /* проверяем необходимость расчета межфирменных архивов */
    if  g#db-num = 0
    and v-holding = true
    then do:
      run trg/nu_hold.p
        (input ub.trn-doc.doc-code /* p-doc-code */
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute( "&1. Ошибка при вызове процедуры nu_hold.p.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.

    if ub.trn-doc.is-back-date
    then do:
      run show-action in this-procedure
        (input "Закрытие документа задним числом"
        ).

      define buffer calc-arh-lock_batchprocess for ub.batchprocess .

      run gbl/lock-prc.p
        (input {&lock-prc-calc-arh}
        ,input ub.trn-doc.obj-code
        ,input 0
        ,input 0
        ,input ub.trn-doc.obj-type
        ,input ""
        ,input ""
        ,input "Объект,,, ,,,Расчет складского архива по товарам"
        ,input false
        ,buffer calc-arh-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + {&new-line}
                    + "В данный момент рассчитывается складской архив по товарам" + {&new-line}
                    + "Невозможно закрыть документ задним числом"  + {&new-line}
                    + substitute('&1':u, return-value)
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo, return error v-message .
      end.

      define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

      run gbl/lock-prc.p
        (input {&lock-prc-calc-supp-arh}
        ,input ub.trn-doc.obj-code
        ,input 0
        ,input 0
        ,input ub.trn-doc.obj-type
        ,input ""
        ,input ""
        ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
        ,input false
        ,buffer calc-supp-arh-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + {&new-line}
                    + "В данный момент рассчитывается складской архив по поставщикам" + {&new-line}
                    + "Невозможно закрыть документ задним числом"  + {&new-line}
                    + substitute('&1':u, return-value)
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo, return error v-message .
      end.

      define buffer calc-aht-lock_batchprocess for ub.batchprocess .

      run gbl/lock-prc.p
        (input {&lock-prc-calc-aht}
        ,input ub.trn-doc.obj-code
        ,input 0
        ,input 0
        ,input ub.trn-doc.obj-type
        ,input ""
        ,input ""
        ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
        ,input false
        ,buffer calc-aht-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        assign
          v-message = substitute('&1 &2 &3':u, vss-workfile, vss-revision, vss-description) + {&new-line}
                    + "В данный момент рассчитывается складской архив по типам приобретения" + {&new-line}
                    + "Невозможно закрыть документ задним числом"  + {&new-line}
                    + substitute('&1':u, return-value)
        .
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo, return error v-message .
      end.

      run show-action in this-procedure
        (input "Закрытие задним числом. Отметка переоценок, требующих перерасчета"
        ).
      run trg/mark-prc.p
        (input  ub.trn-doc.doc-code   /* p-doc-code            */
        ,input  ub.trn-doc.fact-order /* p-fact-order          */
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          assign
            v-message = substitute( "&1. Закрытие документа задним числом.&2Ошибка при отметке переоценок, требующих перерасчета.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
          .
        end.
        else do:
          assign
            v-message = substitute( "&1. Документ &3 не может быть закрыт задним числом.&2", vss-workfile, {&new-line}, ub.trn-doc.doc-code ).
          .
        end.
        {&IF_MESSAGE}
          message
            v-message
            view-as alert-box error .
        undo main-block, return error v-message .
      end.
    end.

    /****** Обновление остатков по поставщику на фирме ********/
    run show-action in this-procedure
      (input "Обновление остатков по поставщику на фирме"
      ).
    run trg/trn-supp.p
      (input  ub.trn-doc.doc-code  /* p-doc-code       */
      ,input  true                 /* p-trn-doc-close  */
      ,input  true                 /* p-update-supp    */
      ,input  true                 /* p-update-chk-doc */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при обновлении остатков по поставщику на фирме.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.

    /****** Установка признаков клиента ********/
    run show-action in this-procedure
      (input "Установка признаков клиента"
      ).
    RUN set-cli in this-procedure
      (input recid(ub.trn-doc) /* p-trn-doc-recid */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при установке признаков клиента.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      {&IF_MESSAGE}
        message
          v-message
          view-as alert-box error .
      undo main-block, return error v-message .
    end.

    if old-doc.status_ <> {&fact} and old-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:
      assign
        ub.trn-doc.creid = g#userid
      .
      /* Убийство внутреннего запроса */
      if g#db-num = 0 then do:
          run str/inqivdel.p ( input ub.trn-doc.doc-code ) no-error  .
          if error-status :error then do:
            /**/
          end.
      end.
    end.
    run show-action in this-procedure
      (input "Обработка документа завершена"
      ).
  end.
  if g#oxml = true   then do:

    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_trn-doc}
        , input ( buffer ub.trn-doc:handle )
    ) no-error.
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при отправке записи в систему OpenXML.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      undo main-block, return error v-message .
    end.
  end.
end. /* MAIN-BLOCK */


procedure validate-trn-doc :

  define variable v-curr-r-b as character no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/curr-r-b.i
      v-curr-r-b
    }

    /* Проверка целостности документа с точки зрения соответствия налогов с продаж и НДС*/
    run chksltpc in this-procedure
      (input ub.trn-doc.doc-code /* pardoc-code */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке соответсвия типов налога с продаж и процентов ставок.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.

    run chkvatpc in this-procedure
      (input ub.trn-doc.doc-code /* pardoc-code */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке соответсвия типа НДС и процентов ставок.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.

    /* Проверка цен в документе */
    run chkprice in this-procedure
      (input ub.trn-doc.doc-code /* pardoc-code */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке цен документа.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.

    /* проверка нулевых строк документа */
    run chkzero in this-procedure
      (input ub.trn-doc.doc-code /* pardoc-code */
      ) no-error .
    if error-status :error
    then do:
      assign
        v-message = substitute( "&1. Ошибка при проверке нулевых строк документа.&2Документ &3&2&4&2&5", vss-workfile, {&new-line}, ub.trn-doc.doc-code, return-value, error-status :get-message ( 1 ) ).
      .
      if g#news = false then do:
        message
          v-message
          view-as alert-box error .
      end.
      return error v-message .
    end.

    /* учитываются ли признаки на объекте */
    define variable l-doc-prt as logical no-undo .

    { gbl/objat.i
      ub.trn-doc.obj-type
      ub.trn-doc.obj-code
      "'doc-prt=request'"
      l-doc-prt
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Документ" ub.trn-doc.doc-code skip
        "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
        "Запрашивался атрибут" "doc-prt=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
    or ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Prvo}
    then do:
      if  ub.trn-doc.vat-type <> {&inc-vat}
      and ub.trn-doc.vat-type <> {&no-vat}
      and ub.trn-doc.vat-type <> {&without-vat}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестной значение поля тип НДС" skip
          "Документ" ub.trn-doc.doc-code skip
          "Тип НДС" ub.trn-doc.vat-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if  ub.trn-doc.slt-type <> {&inc-slt}
      and ub.trn-doc.slt-type <> {&no-slt}
      and ub.trn-doc.slt-type <> {&without-slt}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестной значение поля тип НП" skip
          "Документ" ub.trn-doc.doc-code skip
          "Тип НП" ub.trn-doc.slt-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    /* проверяем целостность закрытого документа */
    for each buf_parts no-lock
      where buf_parts.out-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      if buf_parts.status_ <> yes
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту остались зависшие резервы."  skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "buf_parts.status_" buf_parts.status_ skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if buf_parts.obj-type <> ub.trn-doc.obj-type
      or buf_parts.obj-code <> ub.trn-doc.obj-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту имеются партии с неправильной ссылкой на объект." skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "buf_parts.obj-type" buf_parts.obj-type skip
          "buf_parts.obj-code" buf_parts.obj-code skip
          "ub.trn-doc.obj-type" ub.trn-doc.obj-type skip
          "ub.trn-doc.obj-code" ub.trn-doc.obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = ub.trn-doc.doc-code
          and buf_doc-line.artic     = buf_parts.artic
          and buf_doc-line.prod-type = buf_parts.prod-type
          and buf_doc-line.prod-code = buf_parts.prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту остались зависшие резервы." skip
          "Не найден doc-line." skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if buf_parts.purch-code = ?
      or lookup(string(buf_parts.purch-code), {&purchase-codes} ) = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип приобретения партии" skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Партия" buf_parts.in-code buf_parts.part-code skip
          "Тип приобретения" buf_parts.purch-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      find first buf_doc-line
        where buf_doc-line.doc-code  = ub.trn-doc.doc-code
          and buf_doc-line.artic     = buf_gds-dtl.artic
          and buf_doc-line.prod-type = buf_gds-dtl.prod-type
          and buf_doc-line.prod-code = buf_gds-dtl.prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "При закрытии документа по факту остались зависшие признаки." skip
          "Не найден doc-line." skip
          "Документ" ub.trn-doc.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    /* проверяем целостность документа с точки зрения количеств */

    define variable v-parts-fact-qnty   as decimal no-undo .
    define variable v-parts-qnty        as decimal no-undo .
    define variable v-parts-cli-qnty    as decimal no-undo .
    define variable v-gds-dtl-fact-qnty as decimal no-undo .
    define variable v-gds-dtl-doc-qnty  as decimal no-undo .
    define variable l-has-gds-dtl       as logical no-undo .
    define variable l-empty-scale       as logical no-undo .
    define variable l-goods-twounit     as logical no-undo .
    define variable v-root-node         like ub.gds-prt.node-code no-undo .

    for each buf_doc-line no-lock
      where buf_doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      if  buf_doc-line.obj-type <> ub.trn-doc.obj-type
      and buf_doc-line.obj-code <> ub.trn-doc.obj-code
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает объект в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Объект документа" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
          "Объект строки" buf_doc-line.obj-type buf_doc-line.obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if buf_doc-line.fact-order <> ub.trn-doc.fact-order
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает логический номер в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Логический номер документа" ub.trn-doc.fact-order skip
          "Логический номер строки" buf_doc-line.fact-order skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if buf_doc-line.status_ <> ub.trn-doc.status_
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает статус в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Статус документа" ub.trn-doc.status_ skip
          "Статус строки" buf_doc-line.status_ skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if buf_doc-line.ext-doc-type <> ub.trn-doc.ext-doc-type
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не совпадает расширенный тип документа в строке и в документе"  skip
          "Документ" ub.trn-doc.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Расширенный тип строки" buf_doc-line.ext-doc-type skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      assign
        v-parts-fact-qnty   = 0
        v-parts-qnty        = 0
        v-parts-cli-qnty    = 0
        v-gds-dtl-fact-qnty = 0
        v-gds-dtl-doc-qnty  = 0
        l-has-gds-dtl       = false
      .

      find first buf_goods no-lock
        where buf_goods.artic     = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code
        .

      define variable v-gds-goods      as logical   no-undo .
      define variable v-gds-pl-reserv  as logical   no-undo .
      define variable v-gds-is-twounit as logical   no-undo .
      define variable v-gds-is-serial  as logical   no-undo .
      define variable v-gds-is-legal   as logical   no-undo .

      { gbl/gdscdat.i
        buf_goods.gds-code
        "'gds-goods=request':u"
        v-gds-goods
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Атрибут" 'gds-goods=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      { gbl/gdsobjat.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        "'place-rsrv=request':u"
        v-gds-pl-reserv
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара на объекте" skip
          "Атрибут" 'place-rsrv=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      { gbl/gdscdat.i
        buf_goods.gds-code
        "'twounit=request':u"
        v-gds-is-twounit
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Атрибут" 'twounit=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      { gbl/gdscdat.i
        buf_goods.gds-code
        "'serial=request':u"
        v-gds-is-serial
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Атрибут" 'serial=request':u skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Код товара" buf_goods.gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      run lggdstrn in this-procedure
        (  input ub.trn-doc.ext-doc-type
        ,  input ub.trn-doc.office
        ,  input ub.trn-doc.purch-code
        ,  input (v-gds-goods <> true)
        ,  input v-gds-pl-reserv
        ,  input v-gds-is-twounit
        ,  input v-gds-is-serial
        ,  input buf_goods.artic
        ,  input buf_goods.prod-type
        ,  input buf_goods.prod-code
        ,  input ub.trn-doc.doc-code
        , output v-gds-is-legal
        ) no-error .
      if error-status :error
      or v-gds-is-legal <> true
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не прошла проверка допустимости включения товара в документ" skip
          "Документ" ub.trn-doc.doc-code skip
          "Товар" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* определяется корень шкалы товара */
      { gbl/rootnode.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        v-root-node
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении корневого признака товара" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* определяем, имеет ли товар пустую шкалу или шкалу с признаками */
      { gbl/prtat.i
        v-root-node
        "'empty-scale=request'"
        l-empty-scale
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута признака" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Признак" v-root-node skip
          "Запрашивался атрибут" "empty-scale=request" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* определяется, что товар учитывается в двух единицах измерения */
      { gbl/gdsat.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        "'twounit=request':u"
        l-goods-twounit
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* проверяем, что товар учитывается по схеме FIFO */
      /* начиная с версии 10.3 мы перестаем поддерживать */
      /* метод расчета по средней учетной цене */
      if buf_goods.cost-calc <> {&fifo}
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Товар имеет метод учета отличный от" {&fifo} skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Метод расчета" buf_goods.cost-calc skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if buf_doc-line.vat-pc < 0
      or buf_doc-line.vat-pc >= 100
      or buf_doc-line.vat-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Строка документа имеет недопустмиый НДС" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "НДС" buf_doc-line.vat-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if buf_doc-line.slt-pc < 0
      or buf_doc-line.slt-pc >= 100
      or buf_doc-line.slt-pc = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Строка документа имеет недопустмиый НП" skip
          "Документ" buf_doc-line.doc-code skip
          "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "НП" buf_doc-line.vat-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      /* если это товар, то необходимо проверить целостность партий */
      if buf_goods.gds-type = {&gds-goods}
      then do:

        for each buf_parts no-lock
          where buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
            and buf_parts.out-code  = buf_doc-line.doc-code
        on error undo, return error return-value
        :
          if ub.trn-doc.doc-type <> {&inventory}
          then do:
            if buf_parts.fact-qnty < 0
            or buf_parts.qnty < 0
            or buf_parts.cli-qnty < 0
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "При закрытии документа по факту имеются партии с отрицательными количествами." skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "parts.fact-qnty" buf_parts.fact-qnty skip
                "parts.qnty" buf_parts.qnty skip
                "parts.cli-qnty" buf_parts.cli-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          
          define variable v-is-petrol-trn  as logical   no-undo.
          define variable v-is-pieces      as logical   no-undo.
  
          
          if old-doc.ext-doc-type = {&TDEDT_Pri_Perem}
          then do:
            { str/is-petrl.i
                buf_parts.artic
                buf_parts.prod-type
                buf_parts.prod-code
                v-is-petrol-trn
                v-is-pieces
            }
            if not v-is-petrol-trn 
            then do:  
              find current buf_parts exclusive-lock. 
              buf_parts.cli-qnty = buf_parts.qnty.
              find current buf_parts no-lock.
            end.
          end.

          assign
            v-parts-fact-qnty = v-parts-fact-qnty + buf_parts.fact-qnty
            v-parts-qnty      = v-parts-qnty      + buf_parts.qnty
            v-parts-cli-qnty  = v-parts-cli-qnty  + buf_parts.cli-qnty
          .

          /* проверяем информацию в архивной партии связанную с документом */

          /* тип документа */
          if buf_parts.doc-type <> ub.trn-doc.doc-type
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Неправильный тип партии" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "ub.trn-doc.doc-type" ub.trn-doc.doc-type skip
              "buf_parts.doc-type" buf_parts.doc-type skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          /* код фирмы */
          if buf_parts.host-code <> ub.trn-doc.host-code
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Код фирмы партии не совпадает с кодом фирмы документа" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "buf_parts.host-code" buf_parts.host-code skip
              "ub.trn-doc.host-code" ub.trn-doc.host-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          /* фактический номер закрытия */
          if buf_parts.fact-num <> ub.trn-doc.fact-num
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Фактический номер партии не совпадает с фактическим номером документа" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "buf_parts.fact-num" buf_parts.fact-num skip
              "ub.trn-doc.fact-num" ub.trn-doc.fact-num skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          /* дата фактического документа */
          if buf_parts.fact-date <> ub.trn-doc.fact-date
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Дата партии не совпадает с датой фактического закрытия документа" skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
              "buf_parts.fact-date" buf_parts.fact-date skip
              "ub.trn-doc.fact-date" ub.trn-doc.fact-date skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          /* проверяем параметры порожденных партий для партий внешнего прихода */
          if ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
          then do:
            if buf_parts.VAT-pc <> buf_doc-line.VAT-pc
            or buf_parts.SLT-pc <> buf_doc-line.SLT-pc
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Отличаются параметры порожденной партии от строки документа" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_parts.VAT-pc"           buf_parts.VAT-pc           skip
                "buf_parts.SLT-pc"           buf_parts.SLT-pc           skip
                "buf_doc-line.VAT-pc"        buf_doc-line.VAT-pc        skip
                "buf_doc-line.SLT-pc"        buf_doc-line.SLT-pc        skip
                view-as alert-box error .
              undo, return error return-value .
            end.

            if l-goods-twounit = false
            then do:
              if buf_parts.cli-base-rate <> buf_doc-line.cli-base-rate
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Отличаются параметры порожденной партии от строки документа" skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                  "buf_parts.cli-base-rate"    buf_parts.cli-base-rate    skip
                  "buf_doc-line.cli-base-rate" buf_doc-line.cli-base-rate skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.

            /* price-base, price-rubl не контролируется, так как
              пользователь может заводить партии с различной учетной ценой
            */
            if buf_parts.exch-code <> ub.trn-doc.exch-code
            or buf_parts.pay-code  <> ub.trn-doc.pay-code
            or buf_parts.VAT-type  <> ub.trn-doc.vat-type
            or buf_parts.SLT-type  <> ub.trn-doc.slt-type
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Отличаются параметры порожденной партии от строки документа" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_parts.exch-code"   buf_parts.exch-code   skip
                "buf_parts.pay-code"    buf_parts.pay-code    skip
                "buf_parts.VAT-type"    buf_parts.VAT-type    skip
                "buf_parts.SLT-type"    buf_parts.SLT-type    skip
                "ub.trn-doc.exch-code" ub.trn-doc.exch-code skip
                "ub.trn-doc.pay-code"  ub.trn-doc.pay-code  skip
                "ub.trn-doc.vat-type"  ub.trn-doc.vat-type  skip
                "ub.trn-doc.slt-type"  ub.trn-doc.slt-type  skip
                view-as alert-box error .
              undo, return error return-value .
            end.

            define variable v-curr-road-tax as decimal   no-undo .

            /* проверка соответствия цен клиента и учетной цены */

            /* проверяем совпадение дорожного налога по приходу */
            v-curr-road-tax = if v-curr-r-b = {&r-b-base} then buf_parts.road-tax-base else buf_parts.road-tax-rubl .
            if v-curr-road-tax <> buf_doc-line.road-tax
            then do:
                define variable v-road-tax-name as character no-undo .
                run tax-name in this-procedure
                  (input {&road-tax}      /* pardef-tax  */
                  ,output v-road-tax-name /* parname-tax */
                  ) .
                message
                  vss-workfile vss-revision vss-description skip
                  "Различается" v-road-tax-name "по приходу и по расходу" skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                  "buf_parts.road-tax-base"  buf_parts.road-tax-base skip
                  "buf_parts.road-tax-rubl"  buf_parts.road-tax-rubl skip
                  "buf_doc-line.road-tax"      buf_doc-line.road-tax skip
                  view-as alert-box error .
                undo, return error return-value .
            end.

            /* вычисляем учетную цену */
            define variable v-parts-artic          like ub.parts.artic           no-undo .
            define variable v-parts-prod-type      like ub.parts.prod-type       no-undo .
            define variable v-parts-prod-code      like ub.parts.prod-code       no-undo .
/*12/II-2019 - не используется*/
/*            define variable v-parts-price-base     like ub.parts.price-base      no-undo .*/
/*            define variable v-parts-price-rubl     like ub.parts.price-rubl      no-undo .*/
/*            define variable v-parts-road-tax-base  like ub.parts.road-tax-base   no-undo .*/
/*            define variable v-parts-road-tax-rubl  like ub.parts.road-tax-rubl   no-undo .*/
            define variable v-parts-other-base     like ub.parts.other-base      no-undo .
            define variable v-parts-other-rubl     like ub.parts.other-rubl      no-undo .
            define variable v-parts-transport-base like ub.parts.transport-base  no-undo .
            define variable v-parts-transport-rubl like ub.parts.transport-rubl  no-undo .
            define variable v-parts-SLT-PC         like ub.parts.SLT-PC          no-undo .
            define variable v-parts-VAT-PC         like ub.parts.VAT-PC          no-undo .
            define variable v-parts-price-cli      like ub.parts.price-cli       no-undo .
            define variable v-parts-cli-base-rate  like ub.parts.cli-base-rate   no-undo .

            assign
              v-parts-artic          = buf_parts.artic
              v-parts-prod-type      = buf_parts.prod-type
              v-parts-prod-code      = buf_parts.prod-code
/*              v-parts-price-base     = buf_parts.price-base   */
/*              v-parts-price-rubl     = buf_parts.price-rubl   */
/*              v-parts-road-tax-base  = buf_parts.road-tax-base*/
/*              v-parts-road-tax-rubl  = buf_parts.road-tax-rubl*/
              v-parts-other-base     = buf_parts.other-base
              v-parts-other-rubl     = buf_parts.other-rubl
              v-parts-transport-base = buf_parts.transport-base
              v-parts-transport-rubl = buf_parts.transport-rubl
              v-parts-SLT-PC         = buf_parts.SLT-PC
              v-parts-VAT-PC         = buf_parts.VAT-PC
              v-parts-price-cli      = buf_parts.price-cli
              v-parts-cli-base-rate  = buf_parts.cli-base-rate
            .


            if v-parts-vat-pc < 0
            or v-parts-vat-pc >= 100
            or v-parts-vat-pc = ?
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Неправильный НДС в партии товара" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "НДС" v-parts-vat-pc skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Неправильный НДС в партии товара".
            end.

            if v-parts-slt-pc < 0
            or v-parts-slt-pc >= 100
            or v-parts-slt-pc = ?
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Неправильный НП в партии товара" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.in-code buf_parts.part-code skip
                "НП" v-parts-slt-pc skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Неправильный НП в партии товара".
            end.

            { str/in-vat.i
              ub.trn-doc.doc-code
              ub.trn-doc.base-rate
              ub.trn-doc.base-scale
              ub.trn-doc.exch-rate
              ub.trn-doc.exch-scale
              ub.trn-doc.vat-type
              ub.trn-doc.slt-type
              v-parts-artic
              v-parts-prod-type
              v-parts-prod-code
              v-parts-price-cli
              v-parts-cli-base-rate
              buf_parts.price-rubl
              v-parts-vat-pc
              v-parts-slt-pc
              v-curr-road-tax
              v-parts-transport-rubl
              v-parts-other-rubl
              v-price-cli
              v-price-cli-unit-base
              v-price-road-tax
              v-price-other-exp
              v-price-transport-exp
              v-price-without-abs
              v-price-slt
              v-price-no-slt
              v-price-vat
              v-price-no-vat-slt
              v-price-rubl
              v-price-road-tax-rubl
              v-price-other-exp-rubl
              v-price-transport-exp-rubl
              v-price-without-abs-rubl
              v-price-slt-rubl
              v-price-no-slt-rubl
              v-price-vat-rubl
              v-price-no-vat-slt-rubl
              v-price-base
              v-price-road-tax-base
              v-price-other-exp-base
              v-price-transport-exp-base
              v-price-without-abs-base
              v-price-slt-base
              v-price-no-slt-base
              v-price-vat-base
              v-price-no-vat-slt-base
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при перерасчете линии документа" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error "Ошибка при пересчете линии документа" .
            end.
            assign
              v-parts-price-cli  = v-price-cli
/*              v-parts-price-rubl = v-price-rubl*/
/*              v-parts-price-base = v-price-base*/
            .
            /* проверяем соответствие с точностью до 7 знака */
            &scoped-define seven-sign 0.0000001
            &scoped-define seven-trun 7
            if abs(buf_parts.price-base - v-price-base) > {&seven-sign} /* = v-parts-price-base */
            or abs(buf_parts.price-rubl - v-price-rubl) > {&seven-sign} /* = v-parts-price-rubl */
            then do:
              v-message = substitute( "Несоответсвие учетной цены и цены поставщика. Артикул &1 &2 &3",
                                      buf_parts.artic, buf_parts.prod-type, buf_parts.prod-code ) .
              message
                vss-workfile vss-revision vss-description skip
                "Документ" ub.trn-doc.doc-code
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "buf_parts.part-code"       buf_parts.part-code       skip
                "" skip
"Поле"           {&tabulation} {&tabulation} "Отлич."                                           {&tabulation} "Партия"                 {&tabulation} "Должно быть значение"  skip
"price-base"                   {&tabulation} buf_parts.price-base     <> v-price-base           {&tabulation} buf_parts.price-base     {&tabulation} truncate(v-price-base, {&seven-trun}) skip
"price-rubl "                  {&tabulation} buf_parts.price-rubl     <> v-price-rubl           {&tabulation} buf_parts.price-rubl     {&tabulation} truncate(v-price-rubl, {&seven-trun}) skip
"other-base"                   {&tabulation} buf_parts.other-base     <> v-parts-other-base     {&tabulation} buf_parts.other-base     {&tabulation} v-parts-other-base      skip
"other-rubl "                  {&tabulation} buf_parts.other-rubl     <> v-parts-other-rubl     {&tabulation} buf_parts.other-rubl     {&tabulation} v-parts-other-rubl      skip
"transport-base"               {&tabulation} buf_parts.transport-base <> v-parts-transport-base {&tabulation} buf_parts.transport-base {&tabulation} v-parts-transport-base  skip
"transport-rubl"               {&tabulation} buf_parts.transport-rubl <> v-parts-transport-rubl {&tabulation} buf_parts.transport-rubl {&tabulation} v-parts-transport-rubl  skip
"SLT-PC"         {&tabulation} {&tabulation} buf_parts.SLT-PC         <> v-parts-SLT-PC         {&tabulation} buf_parts.SLT-PC         {&tabulation} v-parts-SLT-PC          skip
"VAT-PC"         {&tabulation} {&tabulation} buf_parts.VAT-PC         <> v-parts-VAT-PC         {&tabulation} buf_parts.VAT-PC         {&tabulation} v-parts-VAT-PC          skip
"price-cli"      {&tabulation} {&tabulation} buf_parts.price-cli      <> v-parts-price-cli      {&tabulation} buf_parts.price-cli      {&tabulation} v-parts-price-cli       skip
"cli-base-rate"                {&tabulation} buf_parts.cli-base-rate  <> v-parts-cli-base-rate  {&tabulation} buf_parts.cli-base-rate  {&tabulation} v-parts-cli-base-rate   skip
              view-as alert-box error .
              undo, return error v-message .
            end.

            if buf_parts.supp-code <> ub.trn-doc.cli-code
            or buf_parts.supp-type <> ub.trn-doc.cli-type
            or buf_parts.is-supp   <> true
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Отличаются параметры порожденной партии документа внешнего прихода" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_parts.supp-code"  buf_parts.supp-code  skip
                "buf_parts.supp-type"  buf_parts.supp-type  skip
                "buf_parts.is-supp"    buf_parts.is-supp    skip
                "ub.trn-doc.cli-code" ub.trn-doc.cli-code skip
                "ub.trn-doc.cli-type" ub.trn-doc.cli-type skip
                view-as alert-box error .
              undo, return error return-value .
            end.

            /* Проверяем соответствие количеств по ТТН
                и количеств по документу */
            define variable v-test-parts-qnty like ub.parts.qnty no-undo .
            assign
              v-test-parts-qnty = buf_parts.cli-qnty * buf_parts.cli-base-rate
            .
            if (buf_parts.cli-base-rate = 1
                and buf_parts.qnty <> v-test-parts-qnty
              )
            or (buf_parts.cli-base-rate <> 1
                and abs(buf_parts.qnty - v-test-parts-qnty) > 0.1
              )
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Количество по ТТН не соответсвует количеству по документу" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "Партия" buf_parts.part-code skip
                "buf_parts.qnty" buf_parts.qnty skip
                "buf_parts.cli-qnty * buf_parts.cli-base-rate" v-test-parts-qnty skip
                "buf_parts.cli-qnty" buf_parts.cli-qnty skip
                "buf_parts.cli-base-rate" buf_parts.cli-base-rate skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
          else do:
            /* ub.trn-docext-doc-type <> {&TDEDT_Pri_Vnesh} */
            if buf_parts.in-code = buf_parts.out-code
            then do:
              /* проверяем параметры партии, порожденной не внешним приходом */
       
              if buf_parts.supp-type <> { trg/partsprm.i "supp-type" "ub.trn-doc." }
              or buf_parts.supp-code <> { trg/partsprm.i "supp-code" "ub.trn-doc." }
              then do:
                
                      
                /* поставщика можно менять только для партий возврата
                  для документа внешнего возврата и документа инвентаризации
                */
                if ub.trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}
                or ub.trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
                or ub.trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts}
                then do:
                  /* это специальный случай - мы не производим контроль */
                  /* так как значения наследуются из других партий */
                end.
                else do:
                  if (ub.trn-doc.doc-type = {&return}
                    and ub.trn-doc.internal = false
                    )
                  or (ub.trn-doc.ext-doc-type = {&TDEDT_Inv}
                    and buf_parts.fact-qnty > 0 )
                  or (ub.trn-doc.ext-doc-type = {&TDEDT_Peresort}
                    and buf_parts.fact-qnty > 0 )
                  then do:
                    if  buf_parts.supp-type <> {&prs}
                    and buf_parts.supp-type <> {&cmp}
                    then do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "Поставщиком порожденной партии старого возврата может быть только человек или организация" skip
                        "Документ" ub.trn-doc.doc-code skip
                        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                        "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                        "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                    if buf_parts.is-supp = false
                    then do:
                      message
                        vss-workfile vss-revision vss-description skip
                        "У партии старого возврата должен быть установлен признак от поставщика" skip
                        "Документ" ub.trn-doc.doc-code skip
                        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                        "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                        "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                        "is-supp" buf_parts.is-supp skip
                        view-as alert-box error .
                      undo, return error return-value .
                    end.
                  end.
                  else do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Поставщиком порожденной партии может быть только объект документа" skip
                      "Документ" ub.trn-doc.doc-code skip
                      "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                      "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                      "Объект документа" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
                      "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                      view-as alert-box error .
                    undo, return error return-value .
                  end.
                end.
              end.
              else do:
                if buf_parts.is-supp = true
                then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "У порожденной партии должен быть установлен признак, что она порождена" skip
                    "Документ" ub.trn-doc.doc-code skip
                    "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                    "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                    "Поставщик партии" buf_parts.supp-type buf_parts.supp-code skip
                    "is-supp" buf_parts.is-supp skip
                    view-as alert-box error .
                  undo, return error return-value .
                end.
              end.

              define variable v-is-hold as logical   no-undo .
              { gbl/hold-doc.i
                ub.trn-doc.doc-code
                v-is-hold
                no-error
              }
              if error-status :error
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении типа документа" skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  view-as alert-box error .
                undo, return error return-value .
              end.

              if ub.trn-doc.ext-doc-type  = {&TDEDT_Ras_Vnesh_VP}
              /*or ub.trn-doc.ext-doc-type  = {&TDEDT_Ras_Perem}*/
              /*or v-is-hold*/
              then do:
                /* не позволяем порождать партии в этом же документе */
                message
                  vss-workfile vss-revision vss-description skip
                  "Партии не могут порождаться документами:" skip
                  "  " "расход внешний возврат поставщику" skip
                  /* "  " "перемещение" skip */
                  /*"  " "межфирменное перемещение" skip*/
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Межфирменный" v-is-hold skip
                  "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.
         end.

            if g#news = false
            then do:
              if buf_parts.price-base = 0
              or buf_parts.price-rubl = 0
              then do:
                define variable v-parameter-name as character no-undo .
                define variable conf-par as character no-undo .
                define variable par-type as character no-undo .
                define variable v-prcshfc0 as character no-undo .
                define variable v-prdocfc0 as character no-undo .

                { gbl/getsect.i run ub.trn-doc.obj-type ub.trn-doc.obj-code  {&attr-rezerv-obj} }
                for each thbjattr_thbj-attr :
                  if thbjattr_thbj-attr.prop-code = 'prcshfc0'  then  v-prcshfc0  = string(thbjattr_thbj-attr.property-value-logical).
                  if thbjattr_thbj-attr.prop-code = 'prdocfc0'  then  v-prdocfc0  = string(thbjattr_thbj-attr.property-value-logical).
                end.

                if ub.trn-doc.discnt-type = {&cash-desk}
                then do:
                  assign
                    v-parameter-name = "prcshfc0"
                    conf-par = v-prcshfc0
                  .
                end.
                else do:
                  assign
                    v-parameter-name = "prdocfc0"
                    conf-par = v-prdocfc0
                  .
                end.

                if can-do( "true,yes", conf-par )
                then do:
                  /* */
                end.
                else do:
                  message
                    "Документ" ub.trn-doc.doc-code skip
                    "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                    "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                    "Порожденная партия имеет нулевую учетную цену" skip
                    "buf_parts.in-code"          buf_parts.in-code skip
                    "buf_parts.part-code"        buf_parts.part-code skip
                    "buf_parts.price-base"       buf_parts.price-base skip
                    "buf_parts.price-rubl"       buf_parts.price-rubl skip
                    "Откорректируйте цену партии" skip
                    view-as alert-box information .
                  undo, return error return-value .
                end.
              end.
            
         end. 

          define variable v-reason       as character no-undo .
          define variable l-process-part as logical no-undo .

          /* контроль правильности резервирования порожденных партий */
          /* правильность резервирования по складским местам проверяется */
          { gbl/part-prc.i
            buf_parts
            ub.trn-doc
            "false"
            "'':u"
            "'':u"
            "0"
            "false"
            "'':u"
            "0"
            "false"
            v-reason
            l-process-part
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении возможности резервирования партии" skip
              "Документ" buf_doc-line.doc-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if l-process-part <> true
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Контроль правильности резервирования порожденных партий" skip
              "Партия ошибочно зарезервирована за документом" skip
              "Документ" buf_doc-line.doc-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              v-reason skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.

        /* проверяем целостность товара
          gds-obj совпадает с корневым prt-obj  и
          с партиями свободной зоны и зарезервированными из свободной зоны
        */
        /* уберем ка, а то 500 раз это делаем при закрытии
        if not g#news then do:
        { gbl/gdscheck.i
          buf_doc-line.obj-type
          buf_doc-line.obj-code
          buf_doc-line.artic
          buf_doc-line.prod-type
          buf_doc-line.prod-code
          v-root-node
          "''"
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке целостности товара" skip
            "Документ" ub.trn-doc.doc-code skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Товар"  buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "Закрытие документа невозможно" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        end.
        */
      end. /* if buf_goods.gds-type = {&gds-goods} */

      /* проверка целостности признаков в накладной */
      for each buf_gds-dtl no-lock
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :
        /* проверим, что gds-dtl заведен на правильный признак */
        { gbl/prtcheck.i
          l-doc-prt
          buf_gds-dtl.prt-code
          v-root-node
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "В документе используется недопустимый признак" skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
            "На объекте разрешены признаки" l-doc-prt skip
            "Код признака" buf_gds-dtl.prt-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        
        if ub.trn-doc.doc-type <> {&inventory}
        then do:
          if buf_gds-dtl.fact-qnty < 0
          or buf_gds-dtl.doc-qnty  < 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеются партии с отрицательными количествами." skip
              "Документ" ub.trn-doc.doc-code skip
              "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
              "gds-dtl.fact-qnty" buf_gds-dtl.fact-qnty skip
              "gds-dtl.doc-qnty" buf_gds-dtl.doc-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.

        assign
          v-gds-dtl-fact-qnty = v-gds-dtl-fact-qnty + buf_gds-dtl.fact-qnty
          v-gds-dtl-doc-qnty  = v-gds-dtl-doc-qnty  + buf_gds-dtl.doc-qnty
        .
        if buf_gds-dtl.doc-qnty <> 0
        then do:
          assign
            l-has-gds-dtl = true
          .
        end.

        /* проверка допустимости отрицательных остатков */
        if  not g#news
        and buf_goods.negative-rest <> true
        and ub.trn-doc.discnt-type <> {&cash-desk}
        then do:
          { gbl/prtobjcr.i
            buf_gds-dtl.obj-type
            buf_gds-dtl.obj-code
            buf_gds-dtl.artic
            buf_gds-dtl.prod-type
            buf_gds-dtl.prod-code
            buf_gds-dtl.prt-code
            ub.prt-obj
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно найти признак на объекте" skip
              "Документ" buf_gds-dtl.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул"  buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          if ub.prt-obj.fact-qnty < 0
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Отрицательное количество по признаку на объекте не допустимо" skip
              "Документ" buf_gds-dtl.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_gds-dtl.artic buf_gds-dtl.prod-type buf_gds-dtl.prod-code skip
              "buf_gds-dtl.fact-qnty" buf_gds-dtl.fact-qnty skip
              "ub.prt-obj.fact-qnty" ub.prt-obj.fact-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.

      /* проверяем целостность линии по партиям */
      if buf_goods.gds-type = {&gds-goods}
      then do:
        /* количество по ТТН */
        if  ub.trn-doc.doc-type = {&income}
        and ub.trn-doc.internal = false
        then do:
          /* контролируем для внешнего прихода количетсво по ТТН */
          /* количества должны совпадать в случае, если товар имеет пустую шкалу */
          /* или количество по документу в партиях отлично от нуля */
          if l-empty-scale
          or v-parts-cli-qnty <> 0
          then do:
            if      buf_doc-line.cli-qnty <> v-parts-cli-qnty and
               abs( buf_doc-line.cli-qnty  - v-parts-cli-qnty ) > 0.001
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "При закрытии документа по факту имеется несоответствие строки документа" skip
                "с количеством по партиям (количество по ТТН)." skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                "  " "buf_doc-line.cli-qnty" buf_doc-line.cli-qnty skip
                "  " "v-parts-cli-qnty"  v-parts-cli-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.

          /* проверка совпадения количества по документу и количества клиента */
          /* в случае одинаковых единиц измерения */
          if buf_doc-line.cli-base-rate = 1
          then do:
            if buf_doc-line.doc-qnty <> buf_doc-line.cli-qnty
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "В строке накладной количество по ТТН не соответсвует количеству по документу" skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
                "buf_doc-line.doc-qnty"      buf_doc-line.doc-qnty      skip
                "buf_doc-line.cli-qnty"      buf_doc-line.cli-qnty      skip
                "buf_doc-line.cli-base-rate" buf_doc-line.cli-base-rate skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.


        if ub.trn-doc.doc-type <> {&inventory}
        then do:
          /* количество по документу */
          if ub.trn-doc.doc-type = {&income}
          and ub.trn-doc.internal = false
          and not l-empty-scale
          then do:
            /* документ внешнего прихода, товар имеет признаки
              признаки могли быть созданы в статусе "накл+" в этом случае количество buf_parts.qnty = 0
              */
            if v-parts-qnty <> 0
            then do:
              if      buf_doc-line.doc-qnty <> v-parts-qnty and
                 abs( buf_doc-line.doc-qnty  - v-parts-qnty ) > 0.001
              then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "При закрытии документа по факту имеется несоответствие строки документа" skip
                  "с количеством по партиям (количество по документу)." skip
                  "Документ" ub.trn-doc.doc-code skip
                  "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                  "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                  "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
                  "v-parts-qnty" v-parts-qnty skip
                  "Закрытие документа невозможно." skip
                  view-as alert-box error .
                undo, return error return-value .
              end.
            end.
          end.
          else do:
            if      buf_doc-line.doc-qnty <> v-parts-qnty and
               abs( buf_doc-line.doc-qnty  - v-parts-qnty ) > 0.001
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "При закрытии документа по факту имеется несоответствие строки документа" skip
                "с количеством по партиям (количество по документу)." skip
                "Документ" ub.trn-doc.doc-code skip
                "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
                "v-parts-qnty" v-parts-qnty skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
        find first doc-fbr-gds no-lock where (doc-fbr-gds.out-code = buf_doc-line.doc-code or
                                              doc-fbr-gds.out-code = replace(buf_doc-line.doc-code, "=", "-") ) 
                                         and doc-fbr-gds.gds-code = buf_goods.gds-code
                                         no-error .
        if available doc-fbr-gds
        then do :
          if      buf_doc-line.doc-qnty <> v-parts-fact-qnty and
             abs( buf_doc-line.doc-qnty  - v-parts-fact-qnty ) > 0.001
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеется несоответствие строки (Производство) документа" skip
              "с количеством по партиям (фактическое количество)." skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
              "v-parts-fact-qnty" v-parts-fact-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        else do :                                 
          if      buf_doc-line.fact-qnty <> v-parts-fact-qnty and
             abs( buf_doc-line.fact-qnty  - v-parts-fact-qnty ) > 0.001
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеется несоответствие строки документа" skip
              "с количеством по партиям (фактическое количество)." skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "buf_doc-line.fact-qnty" buf_doc-line.fact-qnty skip
              "v-parts-fact-qnty" v-parts-fact-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.

      /* проверяем целостность линии по признакам */
      if ub.trn-doc.doc-type <> {&inventory}
      then do:
        /* количество по документу */
        if ub.trn-doc.doc-type = {&income}
        and ub.trn-doc.internal = false
        and not l-empty-scale
        then do:
          /* документ внешнего прихода, товар имеет признаки
              мы не должны проверять количество по документу, так как признаки
              могли быть созданы в статусе "накл+" в этом случае количество buf_gds-dtl.doc-qnty = 0
            */
        end.
        else do:
          if buf_doc-line.doc-qnty <> v-gds-dtl-doc-qnty
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "При закрытии документа по факту имеется несоответствие строки документа" skip
              "с количеством по признакам (количество по документу)." skip
              "Документ" ub.trn-doc.doc-code skip
              "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
              "v-gds-dtl-doc-qnty" v-gds-dtl-doc-qnty skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.

        /* фактическое количество */
        if buf_doc-line.fact-qnty <> v-gds-dtl-fact-qnty
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "При закрытии документа по факту имеется несоответствие строки документа" skip
            "с количеством по признакам (фактическое количество)." skip
            "Документ" ub.trn-doc.doc-code skip
            "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "buf_doc-line.fact-qnty" buf_doc-line.fact-qnty skip
            "v-gds-dtl-fact-qnty" v-gds-dtl-fact-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        /* документ инвентаризации */

        /* количество по документу
          проверяем только в том случае, если товар имеет пустую шкалу
          и у линии имеются признаки с фактическим количеством отличным от нуля .
        */
        if  l-empty-scale
        and l-has-gds-dtl
        and buf_doc-line.doc-qnty <> v-gds-dtl-fact-qnty
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "При закрытии документа по факту имеются несоответствие строки документа" skip
            "с количеством по признакам (количество по документу)." skip
            "Документ" ub.trn-doc.doc-code skip
            "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "buf_doc-line.doc-qnty" buf_doc-line.doc-qnty skip
            "v-gds-dtl-fact-qnty" v-gds-dtl-fact-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        /* фактическое количество */
        if buf_doc-line.fact-qnty <> v-gds-dtl-doc-qnty
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "При закрытии документа по факту имеются несоответствие строки документа" skip
            "с количеством по признакам (фактическое количество)." skip
            "Документ" ub.trn-doc.doc-code skip
            "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            "buf_doc-line.fact-qnty" buf_doc-line.fact-qnty skip
            "v-gds-dtl-doc-qnty" v-gds-dtl-doc-qnty skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
    end.
  end.
end procedure . /* validate-trn-doc */


procedure process-line :
  do
  on error undo, return error return-value
  :

    define variable v-root-node like ub.gds-prt.node-code no-undo .
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    define variable return-AssMin   as logical   no-undo .
    define variable return-igt      as character no-undo .
    define variable gdop-min-stock  as decimal   no-undo .
    define variable grop-max-stock  as decimal   no-undo .
    define variable grop-level-always-presence  as decimal   no-undo .
    define variable grop-min-order as decimal   no-undo .

    def buffer buf_parts for ub.parts .

    /* обновить информацию о текущей закрываемой строке */
    assign
      num_rec   = num_rec + 1
    .

    if num_rec mod 10 = 0
    then do:
      assign
        v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
      .
      display
        num_rec buf_doc-line.artic num_gds v-current-time v-current-action
        with frame a.
      /*if not g#auto then
        process events .*/
    end.


    assign
      buf_doc-line.fact-order   = ub.trn-doc.fact-order
      buf_doc-line.status_      = ub.trn-doc.status_
      buf_doc-line.ext-doc-type = ub.trn-doc.ext-doc-type
    .
    find first buf_inv-line exclusive-lock
      where buf_inv-line.doc-code  = buf_doc-line.doc-code
        and buf_inv-line.artic     = buf_doc-line.artic
        and buf_inv-line.prod-type = buf_doc-line.prod-type
        and buf_inv-line.prod-code = buf_doc-line.prod-code
      no-error.
    if available buf_inv-line then do:
      assign
        buf_inv-line.fact-order   = ub.trn-doc.fact-order
        buf_inv-line.status_      = ub.trn-doc.status_
        buf_inv-line.host-code    = ub.trn-doc.host-code
        buf_inv-line.obj-type     = ub.trn-doc.obj-type
        buf_inv-line.obj-code     = ub.trn-doc.obj-code
        buf_inv-line.ext-doc-type = ub.trn-doc.ext-doc-type
      .
    end. /* if available buf_inv-line */

    find first buf_goods no-lock
      where buf_goods.artic     = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Документ" ub.trn-doc.doc-code skip
        "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
        "" (if g#db-num = 0
            then "Если товар был переименован," + {&new-line}
               + "необходимо принять новости в УБД и переформировать пакеты"
            else ""
          ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code  = buf_goods.gds-code and
               buf_gds-obj.obj-type  = ub.trn-doc.obj-type and
               buf_gds-obj.obj-code  = ub.trn-doc.obj-code and
               buf_gds-obj.cash-parts = true no-error .
    if available buf_gds-obj then do:
    /* только для аптечных объектов */
       if par-is-pharm = "yes"   then do:
          buf_doc-line.is-parts = yes .
          run create-price-cash-parts in this-procedure (
                input buf_doc-line.doc-code
              , input buf_goods.gds-code
              , input buf_goods.artic
              , input buf_goods.prod-type
              , input buf_goods.prod-code
              ) no-error .
              if error-status :error  and  return-value = "no-bar-code-parts" then do:
                 buf_doc-line.is-parts = no .
              end.
              if error-status :error  and  return-value <> "no-bar-code-parts" then do:
               message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "Ошибка"
                view-as alert-box error
              .
              end.
       end.
    end.

    if  ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
      if buf_doc-line.unit-cli = "" or buf_doc-line.unit-cli = ? then do:
         buf_doc-line.unit-cli = buf_goods.unit-cli.
      end.
    end.
    /* Проверка ассортиментной матрицы для объекта приемника  с НАКЛ- */
    if lookup (ub.trn-doc.ext-doc-type,
              {&TDEDT_Ras_Vnesh} + "," +
              {&TDEDT_Ras_Perem} ) <> 0  and
              ((old-doc.status_ = {&wayb} and ub.trn-doc.flag_ = true ) or
                ub.trn-doc.status_ = {&fact} )
    then do:
      var-ok-assort-pol = true .
      if not (ub.trn-doc.cli-type = {&cmp} or ub.trn-doc.cli-type = {&prs}) then do:
         v-event-code = substitute("cli_&1-" ,ub.trn-doc.ext-doc-type ) .
        { gbl/goassizt.i
          v-event-code
          buf_goods.gds-code
          ub.trn-doc.cli-type
          ub.trn-doc.cli-code
          "if g#news then false else true"
          var-ok-assort-pol
          var-mess-assort-pol
        }
        end.
        else do:
            { gbl/hold-doc.i
              ub.trn-doc.doc-code
              v-is-hold
            }
         if v-is-hold then do:
          v-event-code = substitute("cli_mf_&1-" ,ub.trn-doc.ext-doc-type ) .
          { gbl/goassizt.i
            v-event-code
            buf_goods.gds-code
            ub.trn-doc.hold-obj-type
            ub.trn-doc.hold-obj-code
            "if (g#news and not v-not-close-news) then false else true"
            var-ok-assort-pol
            var-mess-assort-pol
          }
          end.
        end.
       if var-ok-assort-pol = false then do:
         if not g#news then do:
            undo, return error var-mess-assort-pol .
         end.
       end.
    end.
    /* Ассортиментная политика по объекту с НАКЛ- */
    if lookup (ub.trn-doc.ext-doc-type,
              {&TDEDT_Inv} + "," +
              {&TDEDT_Peresort} + "," +
              {&TDEDT_Spi_Vnesh} + "," +
              {&TDEDT_Spi_Prvo} + ","  +
              {&TDEDT_Ras_Vnesh_Kass} + ","+
              {&TDEDT_Vozvrat_Vnesh} + "," +
              {&TDEDT_Ras_Vnesh_VP} + ","  +
              {&TDEDT_Chg_Purch_Code} + ","  +
              {&TDEDT_Corr_Minus_Parts} + ","  +
              {&TDEDT_Corr_Acc_Price}   + "," +
              {&TDEDT_Vozvrat_Perem}  + "," +
              {&TDEDT_Ras_Object}  + "," +
              {&TDEDT_Pri_Object} ) = 0  and
              ((old-doc.status_ = {&wayb}    and ub.trn-doc.flag_ = true ))
    then do:
      var-ok-assort-pol = true .
            { gbl/hold-doc.i
              ub.trn-doc.doc-code
              v-is-hold
            }
         if v-is-hold then do:
            v-event-code = substitute("mf_&1-" ,ub.trn-doc.ext-doc-type ) .
         end.
         else do:
            v-event-code = substitute("&1-" ,ub.trn-doc.ext-doc-type ) .
         end.
        { gbl/goassizt.i
          v-event-code
          buf_goods.gds-code
          ub.trn-doc.obj-type
          ub.trn-doc.obj-code
          "if (g#news and not v-not-close-news) then false else true"
          var-ok-assort-pol
          var-mess-assort-pol
        }
       if var-ok-assort-pol = false then do:
          if not g#news then do:
             undo, return error var-mess-assort-pol .
          end.
       end.

    end.
    /* Проверка мин остатка в ассортиментной матрице */
   
    if ub.trn-doc.status_ = {&fact} then do:
      if v-min-ass-exist = false then do:
       { str/ch-amin.i
         ub.trn-doc.obj-type
         ub.trn-doc.obj-code
         buf_goods.gds-code
         "if g#news or g#auto then false else true"
         v-min-ass-exist
         }
         end.
    end.

    /* определяется корневой признак шкалы */
    { gbl/rootnode.i
      buf_goods.artic
      buf_goods.prod-type
      buf_goods.prod-code
      v-root-node
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении корневого признака товара" skip
        "Документ" ub.trn-doc.doc-code skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if ub.trn-doc.doc-type <> "рас" then do:
    /* тип товара должен соответствовать типу документа */
    if (ub.trn-doc.office and buf_goods.gds-type <> {&gds-office})
    or (not ub.trn-doc.office and buf_goods.gds-type <> {&gds-goods})
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильный тип: товар / услуги" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Тип документа, ub.trn-doc.office" ub.trn-doc.office skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "Тип товара, buf_goods.gds-type" buf_goods.gds-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    end.
    /* проверяем, что заданы фактическое количество и количество по документу */
    if buf_doc-line.doc-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задано количество по документу" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        buf_goods.gds-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_doc-line.fact-qnty = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задано фактическое количество" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        buf_goods.gds-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_doc-line.price-base = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задана базовая учетная цена " skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "buf_doc-line.price-base" buf_doc-line.price-base skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    if buf_doc-line.price-rubl = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В строке документа не задана {&abbr_rublevaya} учетная цена" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
        "buf_doc-line.price-rubl" buf_doc-line.price-rubl skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    define variable v-process-goods as logical   no-undo .

    if  ub.trn-doc.status_      =  {&fact}
    then do:
      assign
        v-process-goods = true
      .
      if  ub.trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
      and ub.trn-doc.closed       = true
      and loc#side-active = true
      then do:
        /* здесь перечислены условия, когда не нужно обрабатывать партии */
        assign
          v-process-goods = false
        .
      end.
    end.
    else do:
      assign
        v-process-goods = false
      .
    end.

    /* ---------------------- Обработка статуса ФАКТ ---------------------------- */
    
    if v-process-goods
    then do:
      if ub.trn-doc.doc-type = {&income} and loc#in-ov
      then do:
        /* устанавливается признак того, что товар необходимо переоценить */
        define variable l-in-ov as logical no-undo .

        { gbl/gdsobjat.i
          buf_doc-line.obj-type
          buf_doc-line.obj-code
          buf_doc-line.artic
          buf_doc-line.prod-type
          buf_doc-line.prod-code
          "'in-ov=true'"
          l-in-ov
          no-error
        }
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно установить признак in-ov" skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.

      if buf_goods.gds-type = {&gds-goods}
      then do:
        /* {&work} с партиями только для товаров */
        /*---------------------------------------------------------------------*/
        /* Проверяются или устанавливаются веса для таможенных накладных       */
        /* Данная процедура должна вызываться до создания документов */
        /* на основании текущего документа внутренних перемещений (до trndocmv.p) */
        /*---------------------------------------------------------------------*/
        /* В таможне для внутреннего прихода должны быть установлены кол-во мест и вес брутто
          товара в каждой строке, в остальных проставляться из последней линии по данному товару
        */
        run cust_prc in this-procedure
          (buffer ub.trn-doc
          ,buffer buf_doc-line
          ,input  l-is-custm
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры cust_prc" skip
              "Документ" ub.trn-doc.doc-code skip
              error-status :get-message(1) skip
              return-value skip
            view-as alert-box error .
          end.
          undo, return error return-value .
        end.

        /* обновляются партии свободных и расходных зон */
        /* партии, привязанных к документу переводятся в архивные */
        run partcopy-update-parts in this-procedure
          (input buf_doc-line.doc-code  /* p-doc-code  */
          ,input buf_doc-line.obj-type  /* p-obj-type  */
          ,input buf_doc-line.obj-code  /* p-obj-code  */
          ,input buf_doc-line.artic     /* p-artic     */
          ,input buf_doc-line.prod-type /* p-prod-type */
          ,input buf_doc-line.prod-code /* p-prod-code */
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры partcopy-update-parts" skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        /* расчет фактической учетной цены
            buf_doc-line.price-base buf_doc-line.price-rubl
            buf_doc-line.transport-base buf_doc-line.transport-rubl
            buf_doc-line.other-base buf_doc-line.other-rubl
        */
        if not g#news and not v-not-close-news
        then do:
          if  ub.trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh}
          and ub.trn-doc.ext-doc-type <> {&TDEDT_Pri_Prvo}
          then do:
            run partcopy-update-doc-line-tot-fact
              (input buf_doc-line.doc-code  /* p-doc-code  */
              ,input buf_doc-line.artic     /* p-artic     */
              ,input buf_doc-line.prod-type /* p-prod-type */
              ,input buf_doc-line.prod-code /* p-prod-code */
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры partcopy-update-doc-line-tot-fact" skip
                "Документ" ub.trn-doc.doc-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end.
        end.
      end. /* if buf_goods.gds-type = {&gds-goods}  */

      /* в любой накладной содержатся только терминальные признаки
        для товара без признаков имеется только один корневой признак

        обрабатываются все признаки строки
      */
      for each buf_gds-dtl
        where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
          and buf_gds-dtl.artic     = buf_doc-line.artic
          and buf_gds-dtl.prod-type = buf_doc-line.prod-type
          and buf_gds-dtl.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :
        assign
          num_gds = num_gds + 1
        .

        /* Расчет текущих продажных цен */
        if not g#news and not v-not-close-news
        then do:
          /* определяется текущая продажная цена признака */
          define variable v-prt-b-code like ub.bar-code.b-code no-undo .

          { gbl/gdsbcode.i
            buf_goods.gds-code
            buf_gds-dtl.prt-code
            v-prt-b-code
            no-error
          }
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при определении бар-кода признака" skip
              "Документ" ub.trn-doc.doc-code skip
              "Код товара" buf_goods.gds-code  skip
              "Код признака" buf_gds-dtl.prt-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.

          define variable v-doc-num    like ub.price-list.doc-num    no-undo .
          define variable v-price-sale like ub.price-list.price-sale no-undo .
          define variable v-road-tax   like ub.price-list.road-tax   no-undo .
          define variable v-excise     like ub.price-list.excise     no-undo .

          if buf_doc-line.is-parts = yes 
          or can-find (first buf_gds-obj
                   where buf_gds-obj.gds-code  = buf_goods.gds-code
                     and buf_gds-obj.obj-type  = ub.trn-doc.obj-type
                     and buf_gds-obj.obj-code  = ub.trn-doc.obj-code
                     and buf_gds-obj.cash-parts = true)
          then do:
              for each buf_parts no-lock
              where buf_parts.out-code  = buf_doc-line.doc-code
                and buf_parts.artic     = buf_doc-line.artic
                and buf_parts.prod-type = buf_doc-line.prod-type
                and buf_parts.prod-code = buf_doc-line.prod-code
              :
              find first buf_bar-code no-lock
                   where buf_bar-code.gds-code  = buf_goods.gds-code
                     and buf_bar-code.in-code   = buf_parts.in-code
                     and buf_bar-code.part-code = buf_parts.part-code
                     no-error .
                { gbl/bcodeprc.i
                  buf_parts.obj-type
                  buf_parts.obj-code
                  buf_bar-code.b-code
                  0
                  ub.trn-doc.fact-order
                  v-doc-num
                  v-price-sale
                  v-road-tax
                  v-excise
                  no-error }
                  if error-status :error
                  then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      "Ошибка при определении цены партии" skip
                      "Документ" ub.trn-doc.doc-code skip
                      "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
                      "Код товара" buf_goods.gds-code skip
                      "Бар-код партии" buf_bar-code.b-code skip
                      error-status :get-message(1) skip
                      return-value skip
                      view-as alert-box error .
                    undo, return error return-value .
                  end.
                  assign v-varsum = v-varsum + v-price-sale * buf_parts.fact-qnty.
              end.
              assign v-price-sale = v-varsum / buf_gds-dtl.fact-qnty .
          end.
          else do:
            { gbl/bcodeprc.i
              ub.trn-doc.obj-type
              ub.trn-doc.obj-code
              v-prt-b-code
              0
              ub.trn-doc.fact-order
              v-doc-num
              v-price-sale
              v-road-tax
              v-excise
              no-error
            }
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении цены бар-кода" skip
                "Документ" ub.trn-doc.doc-code skip
                "Объект" ub.trn-doc.obj-type ub.trn-doc.obj-code skip
                "Код товара" buf_goods.gds-code skip
                "Бар-код" v-prt-b-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error return-value .
            end.

          end.
          /* если текущая продажная цена не задана */
          /* полагаем ее равной нулю */
          if v-price-sale = ?
          then do:
            assign
              v-price-sale = 0
              v-road-tax   = 0
              v-excise     = 0
            .
          end.
          assign
            buf_gds-dtl.cur-base = v-price-sale
          .

          define variable v-curr-r-b as character no-undo .

          { gbl/curr-r-b.i
            v-curr-r-b
          }

          if v-curr-r-b = {&r-b-base}
          then do:
            if buf_gds-dtl.cur-base <> buf_gds-dtl.price-base
            then do:
              assign
                buf_gds-dtl.ov = yes
                ub.trn-doc.ov = yes
              .
            end.
            else do:
              assign
                buf_gds-dtl.ov = no
              .
            end.
          end.
          else do:
            if buf_gds-dtl.cur-base <> buf_gds-dtl.price-rubl
            then do:
              assign
                buf_gds-dtl.ov = yes
                ub.trn-doc.ov = yes
              .
            end.
            else do:
              assign
                buf_gds-dtl.ov = no
              .
            end.
          end.
        end.
      end.

      run trndocgs in this-procedure
        (input buf_doc-line.doc-code  /* p-doc-code      */
        ,input buf_doc-line.artic     /* p-artic         */
        ,input buf_doc-line.prod-type /* p-prod-type     */
        ,input buf_doc-line.prod-code /* p-prod-code     */
        ,input v-root-node           /* p-root-node     */
        ,input g#news                /* p-news          */
        ,input true                  /* p-trn-doc-close */
        ,input true                  /* p-update-host   */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при обработке архивов по строке" skip
          "Документ" buf_doc-line.doc-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          "Логический номер документа" buf_doc-line.fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure . /* process-line */


procedure init-local-vars :

  do
  on error undo, return error return-value
  :
    if ub.trn-doc.obj-type = {&stock}
    then do:
      find first ub.store no-lock
        where ub.store.obj-code = ub.trn-doc.obj-code
        .
      assign
        loc#obj-active  = ub.store.active
        loc#in-ov = ub.store.in-ov
      .
    end.
    else do:
             
        
      find first ub.shop no-lock
        where ub.shop.obj-code = ub.trn-doc.obj-code
        .
      assign
        loc#obj-active  = yes
        loc#in-ov = ub.shop.in-ov
      .
    end.
  end.
end procedure.



procedure update-archive-parts-on-fact-close :

  do
  on error undo, return error return-value
  :
    /* запись информации в архивные партии из документа */
    for each buf_doc-line
      where buf_doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      for each buf_parts
        where buf_parts.out-code  = ub.trn-doc.doc-code
          and buf_parts.obj-type  = ub.trn-doc.obj-type
          and buf_parts.obj-code  = ub.trn-doc.obj-code
          and buf_parts.artic     = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
      on error undo, return error return-value
      :
        /* для архивных партий записываем дату и фактический номер
            документа, к которому она принадлежит
           а также записываем тип документа, к которому она принадлежит
          */
        assign
          buf_parts.fact-num  = ub.trn-doc.fact-num
          buf_parts.fact-date = ub.trn-doc.fact-date
          buf_parts.doc-type  = ub.trn-doc.doc-type
        .
      end.
    end.

  end.

end procedure. /* update-archive-parts-on-fact-close */


procedure show-action :
  do
  on error undo, return error return-value
  :
    define input parameter p-action as character no-undo .

    assign
      v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
      v-current-action = p-action
    .
    display
      v-current-time v-current-action
      with frame a.
  end.
end procedure. /* show-action */


procedure process-inquiry :

  do
  on error undo, return error return-value
  :
    /* проверим, что не осталось "зависших" резервов */
    run show-action in this-procedure
      (input "Поиск не снятых резервов"
      ).
    for each buf_parts no-lock
      where buf_parts.out-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
      message
        vss-workfile vss-revision vss-description skip
        "Найдены не снятые резервы" skip
        "Документ" ub.trn-doc.doc-code skip
        "Расширенный тип документа" ub.trn-doc.ext-doc-type skip
        "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
        "Присвоение статуса запрос невозможно" skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* обработка внутреннего приходного запроса находится в файле callnews.p */
    if  g#news
    and g#db-num            = 0
    and ub.trn-doc.status_  = {&inquiry}
    and ub.trn-doc.flag_    = true
    and ub.trn-doc.doc-type = {&income}
    and ub.trn-doc.internal = true
    then do:
      run trg/trn-docv.p (input ub.trn-doc.doc-code , output p-error , output v-message ) .
      if p-error = true then do:
        undo, return error v-message .
      end.
      run show-action in this-procedure
        (input "Отправка документа в новости"
        ).
      run str/callnews.p
        (input "trn-doc"
        ,input (buffer ub.trn-doc:handle)
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать ub.trn-doc для отправки в новости" skip
          "Документ" ub.trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    /* отправка запроса */
    if  g#news = false
    and (ub.trn-doc.status_ = {&inquiry}
         and ub.trn-doc.flag_ = true
        )
    then do:
      run show-action in this-procedure
        (input "Отправка запроса в новости"
        ).
      run str/callnews.p
        (input "trn-doc"
        ,input (buffer ub.trn-doc:handle)
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать trn-doc для отправки в новости" skip
          "Документ" ub.trn-doc.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* process-inquiry */




procedure update-doc-sum :

  define input  parameter p-doc-code   as character no-undo .
  define input  parameter p-fact-order as decimal   no-undo .

  define buffer buf_trn-doc-sum  for ub.trn-doc-sum.
  define buffer buf_doc-line-sum for ub.doc-line-sum.

  do
  on error undo, return error return-value
  :
    for each buf_trn-doc-sum exclusive-lock
      where buf_trn-doc-sum.doc-code = p-doc-code
    on error undo, return error return-value
    :
      assign
        buf_trn-doc-sum.fact-order = p-fact-order
      .
    end.

    for each buf_doc-line-sum exclusive-lock
      where buf_doc-line-sum.doc-code = p-doc-code
    on error undo, return error return-value
    :
      assign
        buf_doc-line-sum.fact-order = p-fact-order
      .
    end.
  end.

end procedure. /* update-doc-sum */


procedure check-close-back-date :

  do
  on error undo, return error return-value
  :
  /*
    for each buf_doc-line
      where buf_doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error return-value
    :
    end.
    */
  end.

end procedure. /* check-close-back-date */


procedure trn-doc-cmd-chance-h-fo :
define input  parameter p-doc-code as character no-undo .
  do
  on error undo, return error return-value
  :
    if  not g#news  and g#db-num <> 0 then do:
        run trg/cmd-trnf.p ( input p-doc-code , "fo", "0") no-error .
        if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "cmd-trnf.p"
          view-as alert-box error
        .
        return error return-value .
        end.
    end.
  end.

end procedure. /* trn-doc-cmd-chance-h-fo */

procedure trn-doc-cmd-chance-h-factur :
define input  parameter p-doc-code as character no-undo .
  do
  on error undo, return error return-value
  :
    if  not g#news  and g#db-num <> 0 then do:
        run trg/cmd-trnf.p ( input p-doc-code , "factur", "0") no-error .
        if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "cmd-trnf.p"
          view-as alert-box error
        .
        return error return-value .
        end.
    end.
  end.

end procedure. /* trn-doc-cmd-chance-h-fo */

procedure create-price-cash-parts :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-artic    as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .

define variable v-value  as decimal   no-undo .
define variable v-doc-num    like ub.price-list.doc-num    no-undo .
define variable v-price-sale like ub.price-list.price-sale no-undo .
define variable v-road-tax   like ub.price-list.road-tax   no-undo .
define variable v-excise     like ub.price-list.excise     no-undo .
define variable v-b-code as integer   no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .

define buffer buf_parts   for ub.parts  .
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-price-target as character no-undo .
define variable v-price-target-type as character no-undo .



  do
  on error undo, return error return-value
  :
find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = p-doc-code no-error .

    for each buf_parts no-lock where
             buf_parts.out-code  = p-doc-code  and
             buf_parts.obj-type  = buf_trn-doc.obj-type  and
             buf_parts.obj-code  = buf_trn-doc.obj-code  and
             buf_parts.artic     = p-artic     and
             buf_parts.prod-type = p-prod-type and
             buf_parts.prod-code = p-prod-code :

            run lineattr-value-parts (
                 input p-doc-code
                ,input p-gds-code
                ,input buf_parts.part-code
                ,input buf_parts.in-code
                ,input {&lineattr-parts_price-sale}
                ,output v-value ) .
          if v-value = 0 then do:
            { gbl/partbcod.i
              buf_parts
              v-b-code
              no-error }
              if error-status :error  or v-b-code = 0 then return error "no-bar-code-parts".
              v-obj-type = buf_trn-doc.obj-type .
              v-obj-code = buf_trn-doc.obj-code .

               if buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} then do:
              /* для внутреннего прихода */
                  { str/tdat-val.i
                    buf_trn-doc.doc-code
                    {&trdcattr-price-target}
                    v-price-target
                    v-price-target-type }
                    if v-price-target <> "yes"  then do:
                       v-obj-type = buf_trn-doc.cli-type .
                       v-obj-code = buf_trn-doc.cli-code .
                    end.
                 end.
            { gbl/bcodeprc.i
              v-obj-type
              v-obj-code
              v-b-code
              0
              0
              v-doc-num
              v-price-sale
              v-road-tax
              v-excise
              }

            run lineattr-write-parts (
                input p-doc-code
                ,input p-gds-code
                ,input buf_parts.part-code
                ,input buf_parts.in-code
                ,input {&lineattr-parts_price-sale}
                ,input v-price-sale
                ) no-error .
          end.
  end.
  end.

end procedure. /* create-price-cash-parts */