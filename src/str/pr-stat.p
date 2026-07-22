block-level on error undo, throw.
/*

$Revision: b896e8303830, 47, rls $
$Author: ASMorozov $
$Date: Mon Jun 09 14:49:49 2014 +0400 $
$Workfile: pr-stat.p $
$Archive: str/pr-stat.p $

Перевод статусов переоценки по графу

Автор: Чернова Светлана Александровна
Дата создания: 09/15/05
Author: Svetlana Chernova
Creation date: 09/15/05

p-mode - переход, выполняемый по графу
   act       - обкоцанный статус АКТ (без проведения по всем проверкам и статусам )
   close     - переход к следующему статусу  - простое закрытие
   close-act - переход к статусу акт без каких-либо подтверждений
               но с выполнением всех обычных проверок

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-mode        as character no-undo .               /* Выполняемый переход по графу */
define input parameter price-doc-num like ub.price-doc.doc-num no-undo .  /* номер переоценки          */
define input parameter trn-doc-code  as character no-undo .               /* может быть = ?            */
define input parameter p-ask-q       as logical   no-undo .               /* нет - задавать вопросы     */
define input parameter p-do          as logical   no-undo .               /* оптим или пессим закрытие */
define buffer buf-price-doc     for ub.price-doc .
/* для передачи информации в s e n d - p r l . p */
define variable varfact-date  like buf-price-doc.fact-date  no-undo.
define variable varfact-time  like buf-price-doc.fact-time  no-undo.
define variable varshift-date like buf-price-doc.shift-date no-undo.
define variable varshift-num  like buf-price-doc.shift-num  no-undo.
define variable varshift-name like buf-price-doc.shift-name no-undo.
define variable p-par as logical no-undo .
define variable conf-par     as char no-undo.    /* для чтения параметра конфигурации */
define variable par-type     as char no-undo.    /* тип параметра конфигурации */

define variable l-ok as logical      no-undo .
define variable v-name-tax as character no-undo .
define buffer other_price-list for ub.price-list.
define variable p-new-status_ like ub.price-doc.status_ no-undo .

define variable vss-revision    as character no-undo init "$Revision: b896e8303830, 47, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 09 14:49:49 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-stat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-stat.p $":U .
define variable vss-description as character no-undo init "Перевод статусов переоценки по графу".
define variable tt-price-sale as decimal no-undo.
define variable v-text-mess as character no-undo .
define variable tt-price-prodwihvat as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-prod-vat         as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable v-str as character no-undo .

{ cmp/vssrevis.i "substitute('&1|&2',p-mode,price-doc-num)" }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ str/lib-trn.i  }
{ ref/grpobj.i   }
{ ref/gdsoattr.i }
{ gbl/tax-name.i }
{ str/pr-lattr.i }
{ trg/check-bc.i }
{ str/alt-calc.i func-befor }
{ str/alt-calc.i func }
{ str/alt-calc.i proc " " " "  no-prcreate-new-price-doc}
{ str/alt-calc.i ver-pr-discn }
{ str/alt-calc.i check-alc-min-price }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ gbl/key-rec.i }
{ gbl/thbjattr.i }

do
on error undo, return error return-value
:

define variable curr-db-num as integer   no-undo .
{ gbl/curdbnum.i curr-db-num }

  { gbl/getcntxt.i get }

  find first buf-price-doc no-lock
    where buf-price-doc.doc-num = price-doc-num
    no-error .
  if not available buf-price-doc
  then do:
    v-text-mess = substitute ( "Невозможно найти переоценку с номером &1 " , price-doc-num ) .

    if p-ask-q = false then
    message
      vss-workfile vss-revision vss-description skip
      v-text-mess
      view-as alert-box error .
    undo, return error v-text-mess .
  end.
  ASSIGN
    varfact-date  = buf-price-doc.fact-date
    varfact-time  = buf-price-doc.fact-time
    varshift-date = buf-price-doc.shift-date
    varshift-num  = buf-price-doc.shift-num
    varshift-name = buf-price-doc.shift-name
    .

  if  buf-price-doc.status_ <> {&g___new}
  and buf-price-doc.status_ <> {&order}
  and buf-price-doc.status_ <> {&permitted}
  and buf-price-doc.status_ <> {&act-overvalue}
  then do:
    v-text-mess  = substitute("Недопустимый исходный статус документа переоценки  &1  Статус &2 " ,  buf-price-doc.doc-num ,    buf-price-doc.status_     ) .
    if p-ask-q = false then
    message
      vss-workfile vss-revision vss-description skip
      v-text-mess
      view-as alert-box .
    undo, return error v-text-mess.
  end.

  if p-mode = "act"
  then do:
      do transaction :
        run str/pr-tot.p (input buf-price-doc.doc-num) no-error.
            run gbl/chk-date.p
              (input buf-price-doc.obj-type
              ,input buf-price-doc.obj-code
              ,input varfact-date
              ,input varfact-time
              ,input varshift-date
              ,input varshift-num
              ,input no
              ) no-error.
            if error-status :error
            then do:
              run gbl/factdate.p
                 (input        buf-price-doc.obj-type,
                  input        buf-price-doc.obj-code,
                  input-output varfact-date,
                  input-output varfact-time,
                  input-output varshift-date,
                  input-output varshift-num,
                  input-output varshift-name,
                  input        no) no-error.
              if error-status :error
              then do:
                  if p-ask-q = false then
                    message substitute(" Ошибка при установке фактической даты переоценки.111 &1 &2" , return-value , error-status :get-message(1) )
                    view-as alert-box.
                  undo, return error substitute(" Ошибка при установке фактической даты переоценки.134 &1 &2" , return-value , error-status :get-message(1) ).
              end.
              run ver-date-period
               ( input varfact-date
                ) no-error .
                if error-status :error then do:
                    if p-ask-q = false then
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      ""
                      view-as alert-box error
                    .
                    undo, return error return-value .
                end.
            end.
        assign
          buf-price-doc.fact-date  = varfact-date
          buf-price-doc.fact-time  = varfact-time
          buf-price-doc.shift-date = varshift-date
          buf-price-doc.shift-num  = varshift-num
          buf-price-doc.shift-name = varshift-name
          buf-price-doc.status_    = {&act-overvalue}
          buf-price-doc.out-code   = trn-doc-code
          .
        /* Изменение ДЕН таблицы */
        run update-den-price-all in this-procedure .
      end.
      return. /* --- ВСЕ ---- */
  end.
  if p-mode = "close"
  then do:
    case buf-price-doc.status_ :
      when {&g___new}
      then do:
        { gbl/chk-actg.i
          curr-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_overvalue_order':U
          {&cntxt-object}
          buf-price-doc.host-code
          buf-price-doc.obj-type
          buf-price-doc.obj-code
          0
          0
          0
          true
          l-ok
        }
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.

      run chec-par in this-procedure (output p-par , input buf-price-doc.host-code, input buf-price-doc.obj-type,input buf-price-doc.obj-code ) no-error .
      If p-par <> true
      then do:
         undo,return error return-value .
      end.

      run str/pr-notls.p (buf-price-doc.doc-num). /* проверяем, не потеряны ли цены */

        { gbl/chk-actg.i
          curr-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_overvalue_preparation':U
          {&cntxt-object}
          buf-price-doc.host-code
          buf-price-doc.obj-type
          buf-price-doc.obj-code
          0
          0
          0
          true
          l-ok
        }
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.

        run proc-d-pcnt in this-procedure (input price-doc-num , output l-ok ) .
        if l-ok = true  then do:
          /* ??? */
        end.
        assign
          l-ok = false
        .
        assign
          p-new-status_ = {&order}
        .
      end.
      when {&order}
      then do:
        /* начать переоценку можно только в базе данных, которому принадлежит объект
          по которому делается переоценка */
        run check-the-same-object in this-procedure
          (output l-ok
          ).
        if l-ok <> true
        then do:
          if p-ask-q = false then
          message
            "Начать переоценку можно только в базе данных, которая содержит объект переоценки." skip
            view-as alert-box .
          undo, return error "Начать переоценку можно только в базе данных, которая содержит объект переоценки.".
        end.

        { gbl/chk-actg.i
          curr-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_overvalue_permission':U
          {&cntxt-object}
          buf-price-doc.host-code
          buf-price-doc.obj-type
          buf-price-doc.obj-code
          0
          0
          0
          true
          l-ok
        }
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.
        assign
          l-ok = false
        .
        if p-ask-q = false
        then do:
            message
              "Начать переоценку на" buf-price-doc.obj-type buf-price-doc.obj-code skip
              "по приказу №" buf-price-doc.doc-num  "и заблокировать продажу ?" skip
              "Вы уверены ?" skip
              view-as alert-box question buttons OK-Cancel update l-ok.
            if l-ok <> true
            then do:
              undo, return error return-value .
            end.
        end.
        assign
          p-new-status_ = {&permitted}
        .

      end.
      when {&permitted}
      then do:
        run check-the-same-object in this-procedure
          (output l-ok
          ).
        if l-ok <> true
        then do:
          if p-ask-q = false then
          message
            "Закрыть акт переоценки можно только в базе данных," skip
            "которая содержит объект переоценки." skip
            view-as alert-box .
          undo, return error "Закрыть акт переоценки можно только в базе данных, которая содержит объект переоценки." .
        end.

        { gbl/chk-actg.i
          curr-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_overvalue_fact':U
          {&cntxt-object}
          buf-price-doc.host-code
          buf-price-doc.obj-type
          buf-price-doc.obj-code
          0
          0
          0
          true
          l-ok
        }
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.
        assign
          l-ok = false
        .
        if p-ask-q = false
        then do:
            message
              "Закрыть акт переоценки №" buf-price-doc.doc-num skip (2)
              "Вы уверены ?" skip (2)
              "Акт переоценки означает,"
              "что с этого момента действуют новые продажные цены."
              view-as alert-box question buttons OK-Cancel update l-ok.
            if l-ok <> true
            then do:
              undo, return error return-value .
            end.
        end.
        run chec-par in this-procedure (output p-par,
                        input buf-price-doc.host-code ,
                        input buf-price-doc.obj-type ,
                        input buf-price-doc.obj-code  ) no-error .
        If p-par <> true
        then do:
          undo, return error return-value .
        end.

        run gbl/chk-date.p
          (input buf-price-doc.obj-type
          ,input buf-price-doc.obj-code
          ,input varfact-date
          ,input varfact-time
          ,input varshift-date
          ,input varshift-num
          ,input no
          ) no-error.
        if error-status :error
        then do:
          run gbl/factdate.p (input    buf-price-doc.obj-type,
                          input        buf-price-doc.obj-code,
                          input-output varfact-date,
                          input-output varfact-time,
                          input-output varshift-date,
                          input-output varshift-num,
                          input-output varshift-name,
                          input        no) no-error.
          if error-status :error
          then do:
              if p-ask-q = false then
                message substitute(" Ошибка при установке фактической даты переоценки.2 &1 &2 " , return-value , error-status :get-message(1) )
                view-as alert-box.
              undo, return error substitute(" Ошибка при установке фактической даты переоценки.3 &1 &2" , return-value , error-status :get-message(1) ).
          end.
          run ver-date-period
            ( input varfact-date
            ) no-error .
            if error-status :error then do:
                if p-ask-q = false then
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  ""
                  view-as alert-box error
                .
                undo, return error return-value .
            end.

        end.
        run proc-cost-price-fact in this-procedure no-error .
          if error-status :error
          then do:
              if p-ask-q = false then
                  message "Ошибка при установке текущей учетной цены."
                  view-as alert-box.
              undo, return error "Ошибка при установке текущей учетной цены.".
          end.

        assign
          p-new-status_ = {&act-overvalue}
        .
      end.
      when {&act-overvalue}
      then do:
        if p-ask-q = false then
        message
          "Акт переоценки уже закрыт. Закрытие невозможно."
          view-as alert-box error .
        undo, return error "Акт переоценки уже закрыт. Закрытие невозможно." .
      end.
    end.
  end.

  if p-mode = "close-act"
  then do:
    run check-the-same-object in this-procedure
      (output l-ok
      ).
    if l-ok <> true
    then do:
      if p-ask-q = false then
          message
            "Начать переоценку можно только в базе данных," skip
            "которая содержит объект переоценки." skip
            view-as alert-box .
      undo, return error  "Начать переоценку можно только в базе данных, которая содержит объект переоценки." .
    end.

    { gbl/chk-actg.i
      curr-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_overvalue_fact':U
      {&cntxt-object}
      buf-price-doc.host-code
      buf-price-doc.obj-type
      buf-price-doc.obj-code
      0
      0
      0
      true
      l-ok
    }
    if l-ok <> true
    then do:
      undo, return error return-value .
    end.

    if buf-price-doc.status_ = {&g___new}
    then do:

      run chec-par in this-procedure
         ( output p-par, input buf-price-doc.host-code, input buf-price-doc.obj-type,input buf-price-doc.obj-code ) no-error .
      If p-par <> true
      then do:
       undo,return error return-value .
      end.


      do transaction
      on error undo, return error return-value
      :
        /* удаляем строчки с неопределенной ценой */
        for each ub.price-list where
                ub.price-list.doc-num = buf-price-doc.doc-num
        on error undo, return error return-value
        :
          /* скидка может быть равна ? только в неосновных ценах - она в них так специально
            инициируется */
          if ub.price-list.price-sale = ? or
            ( ub.price-list.d-pcnt = ?  and ub.price-list.main-price = true )
          then do:
            /* не задан способ округления - если есть для неопределенной
              основной хоть одна зависимая неосновная - будет откачено */
            run del-pr-list in this-procedure
                             (input ub.price-list.b-code,
                              input ub.price-list.doc-num,
                              input ?,  /* round-method */
                              input ?   /* round-base   */ ) no-error.
            if error-status :error
            then do:
              undo, return error return-value .
            end.
          end.
        end.
        /* проверяем, не потеряны ли цены */
        run str/pr-notls.p (buf-price-doc.doc-num).
      end.
    end.

    if buf-price-doc.status_ = {&act-overvalue}
    then do:
      if p-ask-q = false then
      message
        "Акт переоценки уже закрыт. Закрытие невозможно."
        view-as alert-box error .
      undo, return error "Акт переоценки уже закрыт. Закрытие невозможно.".
    end.
    run gbl/chk-date.p
      (input buf-price-doc.obj-type
      ,input buf-price-doc.obj-code
      ,input varfact-date
      ,input varfact-time
      ,input varshift-date
      ,input varshift-num
      ,input no
      ) no-error .
    if error-status :error
    then do:
      run gbl/factdate.p (input        buf-price-doc.obj-type,
                      input        buf-price-doc.obj-code,
                      input-output varfact-date,
                      input-output varfact-time,
                      input-output varshift-date,
                      input-output varshift-num,
                      input-output varshift-name,
                      input no ) no-error.
      if error-status :error
      then do:
          if p-ask-q = false then
          message substitute(" Ошибка при установке фактической даты переоценки.4 &1 &2" , return-value , error-status :get-message(1) )
          view-as alert-box.
          undo, return error substitute(" Ошибка при установке фактической даты переоценки.5 &1 &2" , return-value , error-status :get-message(1) ) .
      end.
      run ver-date-period
        ( input varfact-date
        ) no-error .
        if error-status :error then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
            undo, return error return-value .
        end.

    end.
    run proc-cost-price-fact in this-procedure no-error .
      if error-status :error
      then do:
          if p-ask-q = false then
          message "Ошибка при установке средней учетной цены"
          view-as alert-box.
          undo, return error "Ошибка при установке средней учетной цены".
      end.

    if can-find (first ub.price-list where
                      ub.price-list.doc-num = buf-price-doc.doc-num)
    then do:
      /* если не осталось строк после удаления неопределеннных, не меняем статус,
        чтоб не мешать последующему удалению переоценки */
      assign
        p-new-status_ = {&act-overvalue}
        .
    end.
  end.


  /* проверяем наличие чеков на товары, которые входят в нашу переоценку */
  if (p-mode = "close" and p-new-status_ = {&act-overvalue})
  or (p-mode = "close-act" )
  then do:
    run str/pr-cash.p
      (input parparentproc
      ,input p-new-status_
      ,input buf-price-doc.doc-num
      ,input buf-price-doc.obj-type
      ,input buf-price-doc.obj-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.

  run waitfram-show in this-procedure ("Ждите...").
  main-block :
  do transaction
  on error undo main-block, return error return-value
  :
    find current buf-price-doc exclusive-lock .

    /* действия, выполняемые для перехода {&g___new} -> {&order} */
    if (p-mode = "close"     and buf-price-doc.status_ = {&g___new} )
    or (p-mode = "close-act" and buf-price-doc.status_ = {&g___new} )
    then do:

      run chec-par in this-procedure (output p-par, input buf-price-doc.host-code, input buf-price-doc.obj-type,input buf-price-doc.obj-code ) no-error .
      If p-par <> true
      then do:
         undo,return error return-value .
      end.
    /* проверка на превышение процента наценки */
    /*------------------*/
      run ver-pr-discn in this-procedure
         ( input  p-mode ,
           input  buf-price-doc.doc-num ,
           input  trn-doc-code ,
           output l-ok ) no-error .
      if error-status :error
      then do:
          if p-ask-q = false then
             message "Ошибка при проверке процента наценки!" skip
                      return-value
                      view-as alert-box error .
          undo main-block, return error substitute("Ошибка при проверке процента наценки! &1 &2" , error-status :get-message(1) , return-value  ) .
      end.
      if l-ok <> false
      then do:
        undo, return error return-value .
      end.
    /* проверка на превышение цены алкогольной продукции */
    if par-alcohol <> "" and logical(par-alcohol) = true then do:
      run check-alc-min-price in this-procedure
         ( input  buf-price-doc.doc-num ,
           output l-ok ) no-error .
      if error-status :error
      then do:
          if p-ask-q = false then
             message "Ошибка при проверке цены алкогольной продукции!" skip
                      return-value
                      view-as alert-box error .
          undo main-block, return error substitute("Ошибка при проверке цены алкогольной продукции! &1 &2" , error-status :get-message(1) , return-value  ) .
      end.
      if l-ok <> false
      then do:
        undo, return error return-value .
      end.
    end.
    /*------------------*/
      for each ub.price-list
        where ub.price-list.doc-num = buf-price-doc.doc-num
      on error undo main-block, return error return-value
      :
        find first ub.goods no-lock
          where ub.goods.artic     = ub.price-list.artic
            and ub.goods.prod-type = ub.price-list.prod-type
            and ub.goods.prod-code = ub.price-list.prod-code
          no-error .
        if not available ub.goods
        then do:
          v-text-mess = substitute(" Не найден товар Переоценка  &1 Артикул &2 &3 &4 " , ub.price-list.doc-num , ub.price-list.artic, ub.price-list.prod-type, ub.price-list.prod-code ) .
          if p-ask-q = false then
          message
            vss-workfile vss-revision vss-description skip
            "Не найден товар" skip
            "Переоценка" ub.price-list.doc-num skip
            "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
            view-as alert-box error .
          undo, return error v-text-mess.
        end.

        if ub.price-list.price-sale = ?
        then do:
          if p-ask-q = false then
          message
            "В приказе переоценки есть строки с незаполненной ценой."
            "Закрытие невозможно."
            view-as alert-box error .
          undo main-block, return error "В приказе переоценки есть строки с незаполненной ценой.".
        end.
        if par-pr-rdc-q = "yes"
        then do:
          define variable v-price-base like ub.gds-obj.price-base no-undo .
          define variable v-price-rubl like ub.gds-obj.price-rubl no-undo .
          define variable v-tax-road-base like ub.gds-obj.price-base no-undo .
          define variable v-tax-road-rubl like ub.gds-obj.price-rubl no-undo .
          run trg/gdsavrg.p
            (input  {&pr-calc-costobj}   /* p-price-type */
            ,input  ub.price-list.obj-type  /* p-obj-type   */
            ,input  ub.price-list.obj-code  /* p-obj-code   */
            ,input  0                    /* p-host-code  */
            ,input  ub.price-list.artic     /* p-artic      */
            ,input  ub.price-list.prod-type /* p-prod-type  */
            ,input  ub.price-list.prod-code /* p-prod-code  */
            ,output v-price-base         /* p-price-base */
            ,output v-price-rubl         /* p-price-rubl */
            ,output v-tax-road-base      /* p-price-base */
            ,output v-tax-road-rubl      /* p-price-rubl */

            ).

          if
          (    var-pr-r-b = "rubl"
          and v-price-rubl <> ?
          and v-price-rubl > ub.price-list.price-sale
          )
          or
          (   var-pr-r-b = "base"
          and v-price-base <> ?
          and v-price-base > ub.price-list.price-sale
          )

          then do:
            assign
              l-ok = true
            .
            v-text-mess = substitute( "УЧЕТНАЯ цена для : &1 &2 БОЛЬШЕ, чем цена ПРОДАЖИ по закрываемому документу - &3 ", ub.price-list.artic , ub.goods.gds-name , ub.price-list.price-sale) .
            if p-ask-q = false
            then do:
                message
                  "УЧЕТНАЯ цена для :" ub.price-list.artic ub.goods.gds-name
                  "БОЛЬШЕ, чем цена ПРОДАЖИ по закрываемому документу -" ub.price-list.price-sale
                  view-as alert-box question buttons OK-Cancel update l-ok.
                if l-ok <> true
                then do:
                  undo main-block, return error v-text-mess .
                end.
            end.
            else do:
              if p-do = false
              then do:
                undo main-block, return error v-text-mess .
              end.
            end.
          end.
        end.

        /* Проверка стоимость стеклопосуды не больше продажной цены */
            if ub.price-list.price-sale < ub.price-list.road-tax
            then do:
              run tax-name in this-procedure (input {&road-tax} ,output v-name-tax ).
              if p-ask-q = false then
              message
                "Значение компоненты цены '" v-name-tax "' БОЛЬШЕ, чем цена по закрываемому документу" skip
                "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
                "Артикул" ub.price-list.artic ub.goods.gds-name skip
                "Бар-код" ub.price-list.b-code skip
                v-name-tax ub.price-list.road-tax skip
                "Новая продажная цена:" ub.price-list.price-sale skip (2)
                view-as alert-box error.
                undo main-block, return error substitute(" Значение компоненты цены  &1  БОЛЬШЕ, чем цена по закрываемому документу ( Объект &2&3 Артикул &4 &5  Бар-код &6 ДОП.КОМП=&7 Новая продажная цена=&8 )" ,
                  v-name-tax ,
                  ub.price-list.obj-type ,
                  ub.price-list.obj-code ,
                  ub.price-list.artic    ,
                  ub.goods.gds-name      ,
                  ub.price-list.b-code   ,
                  ub.price-list.road-tax ,
                  ub.price-list.price-sale ) .
              end.

        /* ищем предыдущую цену товара по текущему объекту */

        define variable v-doc-num    like ub.price-list.doc-num    no-undo .
        define variable v-price-sale like ub.price-list.price-sale no-undo .
        define variable v-road-tax   like ub.price-list.road-tax   no-undo .
        define variable v-excise     like ub.price-list.excise     no-undo .

        { gbl/bcodeprc.i
          ub.price-list.obj-type
          ub.price-list.obj-code
          ub.price-list.b-code
          0
          0
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
        }
        if v-doc-num <> ?
        then do:
          if v-price-sale > ub.price-list.price-sale
          then do:
            if par-pr-rdc-q = "yes"
            then do:
              assign
                l-ok = true
              .
              if p-ask-q = false
              then do:
                  message
                    "Предыдущая цена БОЛЬШЕ, чем по закрываемому документу" skip
                    "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
                    "Артикул" ub.price-list.artic ub.goods.gds-name skip
                    "Бар-код" ub.price-list.b-code skip
                    "Цена по предыдущему документу №" v-doc-num skip
                    v-price-sale skip
                    "Новая цена:" skip
                    ub.price-list.price-sale skip (2)
                    "ЦЕНА СНИЖЕНА ?" skip
                    view-as alert-box question buttons OK-Cancel update l-ok.
                  if l-ok <> true
                  then do:
                    undo main-block, return error return-value .
                  end.
              end.
              else do:
                if p-do = false
                then do:
                   undo main-block, return error "Предыдущая цена БОЛЬШЕ, чем по закрываемому документу".
                end.
              end.
            end.
          end.
        end.
        if available ub.price-list
        then do:
          accumulate ub.price-list.artic (count).
        end.
      end.

      run str/pr-tot.p (input buf-price-doc.doc-num) no-error.
      if error-status :error
      then do:
        undo main-block, return error return-value .
      end.

      if (accum count ub.price-list.artic) = 0
      then do:
        if p-mode <> "close-act"  and buf-price-doc.status_ <> {&permitted}
        then do:
          if p-ask-q = false then
          message
            "В документе нет ни одной строки. Удаляем документ."
            view-as alert-box .
        end.

        if  p-mode = "close"  and buf-price-doc.status_ <> {&permitted}
        then do:
            delete buf-price-doc.
            return . /* --->>>--- */
        end.
        if  p-mode = "close-act"  and buf-price-doc.status_ <> {&permitted}
        then do:
            return . /* --->>>--- */
        end.

      end.
    end.

    /* действия, выполняемые для перехода {&order} -> {&permitted} */
    if (p-mode = "close"     and buf-price-doc.status_ = {&order} )
    or (p-mode = "close-act" and
        (buf-price-doc.status_ = {&g___new}
          or buf-price-doc.status_ = {&order}
        )
      )
    then do:

      for each ub.price-list no-lock
        where ub.price-list.doc-num    = buf-price-doc.doc-num
          and ub.price-list.main-price = true
      on error undo main-block, return error return-value
      :
        define variable l-ov-on as logical no-undo .
        { gbl/gdsobjat.i
          ub.price-list.obj-type
          ub.price-list.obj-code
          ub.price-list.artic
          ub.price-list.prod-type
          ub.price-list.prod-code
          "'ov-on=request:exclusive'"
          l-ov-on
          no-error
        }
        if error-status :error
        then do:
          if p-ask-q = false then
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка получения признака товара на объекте" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo main-block, return error "Ошибка получения признака товара на объекте".
        end.

        if l-ov-on
        then do:
          { gbl/gdsobjat.i
            ub.price-list.obj-type
            ub.price-list.obj-code
            ub.price-list.artic
            ub.price-list.prod-type
            ub.price-list.prod-code
            "'ov-on=message'"
            l-ov-on
            no-error
          }
          if error-status :error
          then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка поиска включенной переоценки" skip
              "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
              "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo main-block, return error "Ошибка поиска включенной переоценки" .
          end.
          undo main-block, return error return-value .
        end.
      end.

      if buf-price-doc.obj-type = {&shop}
      then do:
        /* запрещена переоценка без блокировки касс */
        find ub.shop no-lock
          where ub.shop.obj-code = buf-price-doc.obj-code
          .
        if ub.shop.pr-cash = false
        then do:
          /* производим блокировку товаров на кассах */

          run str/diallog.w
                      ( parparentproc
                      , this-procedure
                      , 'str/send-prl.p':U
                      , ("D":U + {&delim-par} + buf-price-doc.doc-num + {&delim-par}  + string(buf-price-doc.obj-code))
                      , yes /*p-auto-go*/
                      , '':U
                      , 'Блокировка товаров переоценки на кассах') no-error .

          if error-status :error
          then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка удаления товаров с кассы" skip
              error-status :get-message(1) skip
              return-value  skip
              "При выполнении send-prl.p "
              view-as alert-box error .
            undo main-block, return error "Ошибка удаления товаров с кассы".
          end.
        end.
      end.
    end.

    /* действия, выполняемые для перехода {&permitted} -> {&act-overvalue} */

    if (p-mode = "close"     and buf-price-doc.status_ = {&permitted}  )
    or (p-mode = "close-act" and
        (buf-price-doc.status_ = {&g___new}
          or buf-price-doc.status_ = {&order}
          or buf-price-doc.status_ = {&permitted}
        )
      )
    then do:
      /* захватываем товары на объекте */

      run trg/lockprdc.p (buf-price-doc.doc-num).

      /* перерасчет документа должен стоять до удаления строк с нулевыми  */
      /* количествами, потому что в нем подставляются истинные количества */
      run str/pr-tot.p ( input buf-price-doc.doc-num) no-error.
      if error-status :error
      then do:
        undo main-block, return error return-value .
      end.

      for each ub.price-list
        where ub.price-list.doc-num = buf-price-doc.doc-num
      on error undo main-block, return error return-value
      :
        find ub.goods no-lock
          where ub.goods.artic     = ub.price-list.artic
            and ub.goods.prod-type = ub.price-list.prod-type
            and ub.goods.prod-code = ub.price-list.prod-code
          .
          /*Налоги*/
              /* НДС */
              { gbl/pftxvalg.i    ub.goods.gds-code
                {&vat-tax-code}
                ?
                buf-price-doc.host-code
                buf-price-doc.obj-type
                buf-price-doc.obj-code
                ub.price-list.vat-pc
                no-error }
                if error-status :error or ub.price-list.vat-pc = ?
                then do:
                    if p-mode = "close" and  p-ask-q = false
                    then do:
                      message
                        "Проверьте налоги  у товара  - код: " ub.goods.gds-code skip
                         error-status :get-message(1) skip
                         return-value
                         view-as alert-box .
                    end.
                  undo main-block, return error substitute(" Ошибка НДС - код: &1 &2 &3" , ub.goods.gds-code , error-status :get-message(1), return-value   ) .
                end.

              /* slt */
              { gbl/pftxvalg.i    ub.goods.gds-code
                              {&slt-tax-code}
                              ?
                              buf-price-doc.host-code
                              buf-price-doc.obj-type
                              buf-price-doc.obj-code
                              ub.price-list.slt-pc
                              no-error }

        if error-status :error or ub.price-list.slt-pc = ?
        then do:
            if p-mode = "close" and  p-ask-q = false
            then do:
              message
                "Проверьте налог НСП у товара  - код: " ub.goods.gds-code   view-as alert-box .
            end.
           undo main-block, return error "Ошибка НСП".
        end.



        if  ub.price-list.doc-qnty = 0
        and ub.price-list.main-price = true
        and ub.goods.gds-type = {&gds-goods}
        then do:

          if par-pr-abs-d = "yes"
          and ( trn-doc-code = "" or trn-doc-code = ? ) /* созданные вручную переоценки */
          then do:
          if can-find( first other_price-list no-lock where /* есть спеццены и дополнит */
                        other_price-list.doc-num    = ub.price-list.doc-num   and
                        other_price-list.artic      = ub.price-list.artic     and
                        other_price-list.prod-code  = ub.price-list.prod-code and
                        other_price-list.prod-type  = ub.price-list.prod-type and
                        other_price-list.main-price = false ) then next.
            run del-pr-list in this-procedure
                           (input ub.price-list.b-code,
                            input ub.price-list.doc-num,
                            input ? ,
                            input ?) no-error.

            if error-status :error
            then do:
              undo main-block, return error return-value .
            end.

          end.
        end.

        if available ub.price-list
        then do:
          accumulate ub.price-list.artic (count).
        end.
      end.

      /* Изменение ДЕН таблицы */
      run update-den-price-all in this-procedure .

      if (accum count ub.price-list.artic) = 0
      then do:
        if p-mode = "close" and buf-price-doc.status_ <> {&permitted}
        then do:
          if p-ask-q = false then
          message
            "В документе нет ни одной строки. Удаляем документ."  buf-price-doc.status_
            view-as alert-box .
        end.
        if  p-mode = "close"  and buf-price-doc.status_ <> {&permitted}
        then do:
            delete buf-price-doc.
            return . /* --->>>--- */
        end.
        if  p-mode = "close-act"  and buf-price-doc.status_ <> {&permitted}
        then do:
            return . /* --->>>--- */
        end.

      end.
      else do:
        if buf-price-doc.obj-type = {&shop}
        then do:
          /* пересылка товаров на кассы с контролем */
          run str/diallog.w
                      (parparentproc
                      , this-procedure
                      , 'str/send-prl.p':U
                      , ("U":U + {&delim-par} + buf-price-doc.doc-num + {&delim-par}  + string(buf-price-doc.obj-code))
                      , yes /*p-auto-go*/
                      , '':U
                      , 'Пересылка новых цен товаров переоценки на кассы') no-error .

          if error-status :error
          then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка отправки товаров на кассу" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo main-block, return error "Ошибка отправки товаров на кассу".
          end.
        end.


        if substring (buf-price-doc.PS, 1, 1) = "@"
        then do:
          assign
            buf-price-doc.PS = buf-price-doc.PS + {&new-line}
                    + "Строк в акте : " + string ((accum count ub.price-list.artic), ">>>>>9")
          .
        end.
      end.
    end.

    assign
      buf-price-doc.fact-date  = varfact-date
      buf-price-doc.fact-time  = varfact-time
      buf-price-doc.shift-date = varshift-date
      buf-price-doc.shift-num  = varshift-num
      buf-price-doc.shift-name = varshift-name
      buf-price-doc.status_    = p-new-status_
    .


    /* определении текущего курса */

    { gbl/baserate.i
      buf-price-doc.host-code
      buf-price-doc.fact-date
      buf-price-doc.base-rate
      buf-price-doc.base-scale
      no-error
    }
    if error-status :error
    then do:
      if p-ask-q = false then
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущего курса в переоценке " skip
        "Код фирмы" buf-price-doc.host-code skip
        "Дата" buf-price-doc.fact-date skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error "Ошибка при определении текущего курса в переоценке " . /* --->>>--- */
    end.

  /* Сработает тригер */
  release buf-price-doc no-error .
  if error-status :error then do:
     undo main-block, return error return-value .
  end.

  find first buf-price-doc no-lock
    where buf-price-doc.doc-num = price-doc-num
    no-error .
    if buf-price-doc.status_ = {&act-overvalue} then do:
        run str/pdfdiscl.p ( Parparentproc , price-doc-num ) no-error .
        if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "из pdfdiscl"
              view-as alert-box error
            .
            undo main-block, return error substitute("Ошибка при закрытии порожденных ДНЦ &1 по переоценке &2 ." ,return-value , price-doc-num) .
        end.
    end.
    /* выводим сообщения об успешном переходе к новому статусу */
    if p-mode = "close"
    then do:
      case buf-price-doc.status_ :
        when {&permitted}
        then do:
          if p-ask-q = false then
          message "Переоценка включена.".
          if buf-price-doc.obj-type = {&shop}
          then do:
            if p-ask-q = false then
            message
              "Рекомендуется принять чеки," skip
              "закрыть отчеты о продажах" skip
              "и после этого закрывать переоценку." skip
              view-as alert-box information .
          end.
        end.
      end.
    end.
    define buffer buf_thbj-attr for ub.thbj-attr.
    define variable v-uniq-key-rec as character no-undo .
    find first buf_thbj-attr no-lock where
              buf_thbj-attr.upper-prop-code = {&attr-rum}
          and buf_thbj-attr.prop-code = {&attr-rum_edoc}
          and buf_thbj-attr.obj-type = ''
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.property-value-logical = yes
          no-error.
    if available buf_thbj-attr then do:
      run gen-key-rec in this-procedure (
                                        input  {&table_thbj-attr}
                                      ,input (buffer buf_thbj-attr:handle)
                                      ,output v-uniq-key-rec).
      run str/edocrum.p
        (
        input parparentproc
        ,input this-procedure:handle
        ,input p-log-handle
        ,input {&edoc-proc_batchwork-routing_price-doc}
        ,input 0 /*p-profile-id*/
        ,input 18 /*p-codex-id*/
        ,input 10 /*p-ruleset-id*/
        ,input curr-db-num        /*current-db-num*/
        ,input v-uniq-key-rec
        ,input ( buf-price-doc.doc-num + {&delim-par} + '')
        ,input yes /*p-save*/
        ) no-error .
      if error-status:error then do:
        undo main-block, return error substitute("Ошибка при маршрутизации переоценки во внешнюю систему:&1&2&1&3"
                                                 , {&new-line}
                                                 , error-status:get-message(1)
                                                 , return-value) . /* --->>>--- */
      end.
    end.
    define variable varok as logical no-undo.
    run check-the-same-object (output varok).
    if buf-price-doc.obj-type = {&shop} and
        can-find (first ub.scales no-lock where ub.scales.db-num = curr-db-num ) and  varok
    then do:
      run send-to-scales(INPUT int(recid(buf-price-doc))) no-error.
      if error-status:error then
        undo main-block, return error subst("Ошибка при отправке на весы - &1", return-value).
    end.
  end.
  run waitfram-hide in this-procedure .
end.



procedure check-the-same-object :
  define output parameter p-ok as logical no-undo .

  find first ub.clients no-lock
    where ub.clients.obj-type = buf-price-doc.obj-type
      and ub.clients.obj-code = buf-price-doc.obj-code
    .

  assign
    p-ok = (ub.clients.db-num = curr-db-num )
  .
end procedure. /* check-the-same-object */


procedure proc-cost-price-fact :
 do
 on error undo, return error return-value
 :
/* запись средней учетной цены на объекте на момент закрытия переоценки до АКТ */

define variable v-total-avrg-base  as decimal no-undo .
define variable v-total-avrg-rubl  as decimal no-undo .
define variable v-total-avrg-qnty  as decimal no-undo .
define buffer buf_parts for ub.parts.
define buffer buf_price-list for ub.price-list.

define variable p-price-base as decimal no-undo .
define variable p-price-rubl as decimal no-undo .


for each buf_price-list no-lock
    where buf_price-list.doc-num = buf-price-doc.doc-num
on error undo, return error return-value
:

      for each buf_parts no-lock
        where  buf_parts.obj-type  = buf-price-doc.obj-type
          and buf_parts.obj-code   = buf-price-doc.obj-code
          and buf_parts.artic      = buf_price-list.artic
          and buf_parts.prod-type  = buf_price-list.prod-type
          and buf_parts.prod-code  = buf_price-list.prod-code
          and ( buf_parts.out-code  = {&free-code}  or
                buf_parts.out-code  = buf-price-doc.doc-num
          )
      on error undo, return error return-value
      :

        assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.
      if v-total-avrg-qnty > 0
      then do:
        assign
          p-price-base = ( v-total-avrg-base / v-total-avrg-qnty )
          p-price-rubl = ( v-total-avrg-rubl / v-total-avrg-qnty )
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.

 define variable p-attr-value as character no-undo .
 if var-pr-r-b = "rubl" then
    p-attr-value = string ( p-price-rubl ) .
    else
    p-attr-value = string ( p-price-base ) .

  run create-price-list-attr in this-procedure (
    {&cost-price-fact}    ,
    p-attr-value          ,
    buf_price-list.b-code ,
    buf-price-doc.doc-num ,
    ""
    ) .

end. /* for each */

 end. /* do */
end procedure. /* proc-cost-price-fact */

procedure proc-d-pcnt :
define input  parameter p-doc-code as character no-undo .
define output parameter v-rez as logical   no-undo  .
  do
  on error undo, return error return-value
  :

define buffer bb_price-list for ub.price-list  .
v-rez = false .
/*    for each bb_price-list no-lock
      where bb_price-list.doc-num    = p-doc-code and
            bb_price-list.d-pcnt     = ? and
            bb_price-list.main-price =  false
    on error undo, return error return-value
    :
       v-rez = true .
       leave.
    end.
*/
  end.

end procedure. /* proc-d-pcnt */

procedure update-den-price-all :
define buffer buf_price-all for ub.price-all  .
  do
  on error undo, return error return-value
  :

  for each ub.price-list  where ub.price-list.doc-num = buf-price-doc.doc-num
  on error undo , return error return-value
  :
    find ub.goods no-lock
      where ub.goods.artic     = ub.price-list.artic
        and ub.goods.prod-type = ub.price-list.prod-type
        and ub.goods.prod-code = ub.price-list.prod-code
      .
        find first buf_price-all exclusive-lock where
                  buf_price-all.obj-type = buf-price-doc.obj-type and
                  buf_price-all.obj-code = buf-price-doc.obj-code and
                  buf_price-all.main-indication = {&bef-mpl-main} and
                  buf_price-all.plt-id       = buf-price-doc.plt-id   and
                  buf_price-all.plt-db-num   = buf-price-doc.plt-db-num and
                  buf_price-all.pdf-id       = buf-price-doc.pdf-id     and
                  buf_price-all.pdf-db       = buf-price-doc.pdf-db     and
                  buf_price-all.gds-code     = ub.goods.gds-code and
                  buf_price-all.b-code       = ub.price-list.b-code no-error .
                  if available buf_price-all
                  then do:
                    assign
                      buf_price-all.out-code    = buf-price-doc.doc-num
                      buf_price-all.last-pr     = true
                      buf_price-all.status_     = {&act-overvalue}
                    .
                  end.
       end.

  end.

end procedure. /* update-den-price-all */


procedure ver-date-period :

define input  parameter  p-fact-date as date   no-undo .
define variable v-value-character   as character no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .

  do
  on error undo, return error return-value
  :
  /* проверяем дату закрытого периода */
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.

  run adm/shattri.p (
      input "get":U
      ,input buf-price-doc.obj-type
      ,input buf-price-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "date-close-period"
      ,output v-value-character
      ,output v-date-close-period
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
          if  p-fact-date < v-date-close-period
          then do:
            return error substitute(
              "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
              Дата закрытия документа &3 &2
              Дата закрытия периода &4
              Объект &5 &6     " ,
              buf-price-doc.doc-num  ,
              {&new-line}  ,
              string ( p-fact-date        , "99/99/9999") ,
              string ( v-date-close-period, "99/99/9999") ,
              buf-price-doc.obj-type ,
              buf-price-doc.obj-code
              ) .
          end.
      end.

  end.

end procedure. /* ver-date-period */

/* отправка на весы */
procedure send-to-scales:
    define input parameter p-price-doc-recid as integer no-undo.
    
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    
    define buffer buf_price-doc for ub.price-doc.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_goods for ub.goods.
    
    v-tth = buffer thbjattr_thbj-attr:table-handle .

    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
       input "get":U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  {&attr-scale-inf}
      ,input  {&attr-scale-inf_noauto-scls} /*p-param-code*/
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , INPUT-OUTPUT table-handle v-tth
      ) no-error .
    IF error-status:error then do:
        message
        substitute("Ошибка при получении настроек, необъодимых для работы весов НА ОБЪЕКТЕ &1&2:&3&4 &5"
                , v-cntxt-obj-type
                , v-cntxt-obj-code
                , {&new-line}
                , error-status:get-message(1)
                , return-value )
        view-as alert-box error .
        undo, return error .
    end.
    
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid.

    { str/add-scal.i parparentproc buf_price-doc.obj-type buf_price-doc.obj-code buf_price-doc.doc-num {&overvalue} this-procedure no-error }
    if error-status :error
    then do:
      return error "Ошибка при обновлении информации на весах " + return-value . /* --->>>--- */
    end.
    
    /* если запрет отправки на весы или переоценка не закрыта на АКТ */
    if v-value-logical OR p-mode = 'close' then return.
    
    run str/diallog.w
      ( input parparentproc
      , input this-procedure
      , input "ref/sendscal.p":U
      , input (buf_price-doc.obj-type + {&delim-par} + string(buf_price-doc.obj-code) + {&delim-par} + {&question-mark} + {&delim-par} +
               "changed":U + {&delim-par} + '' + {&delim-par} + "current":U + {&delim-par} + string(0))
      , input no /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка изменений на весы")
      ) no-error.
      
end procedure. /* send-to-scales */
