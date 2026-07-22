block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: tpsirsrv.p $
$Archive: str/tpsirsrv.p $

Резервирование/разрезервирование ЧУЖИХ товаров в продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/03/04
Author: Bakhtadze Natalya
Creation date: 12/03/04

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-auto           as integer no-undo .
define input parameter V-CURR-R-B       as character no-undo .
define input parameter p-inkas-code  like ub.inkas.inkas-code no-undo .
define input parameter p-host-code   like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type    like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code    like ub.trn-doc.obj-code  no-undo .
define input parameter p-artic       like ub.doc-line.artic    no-undo .
define input parameter p-prod-type   like ub.doc-line.prod-type    no-undo .
define input parameter p-prod-code   like ub.doc-line.prod-code    no-undo .
define input parameter p-prt-code   like ub.gds-dtl.prt-code    no-undo .

define input parameter p-rz       as logical no-undo . /*yes резервирует no снимает*/
/*title окна резервирования*/
define input parameter p-title    as character no-undo .
/*это продолжение счетчика начатого в salersrv.i*/
define input-output parameter p-num_rec_res as integer no-undo .
/*это счетчик попыток резервирования только ЧУЖИХ ТОВАРОВ*/
define output parameter p-num_rec_other as integer no-undo .
/*это счетчик УДАЧНЫХ попыток резервирования только ЧУЖИХ ТОВАРОВ*/
define output parameter p-num_rec_other_res as integer no-undo .
/*здесь только документ расхода продажи  - ведь возварт мы обратно не возвращаем*/
define parameter buffer buf_trn-doc for ub.trn-doc.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tpsirsrv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/tpsirsrv.p $":U .
define variable vss-description as character no-undo init "Резервирование/разрезервирование ЧУЖИХ товаров в продаже".
{ cmp/vssrevis.i }


{ cmp/trg-def.i }
{ gbl/clntattr.i }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ str/trdcalib.i }
{ str/lib-def.i }
{ str/tpsidoc.i SHARED  proc }
{ cmp/library.i }
{ str/lib-trn.i }
{ str/get-pr.i def }
{ str/saledoc.i }

define variable v-base-code                 like ub.sysconf.base-code no-undo .
define variable v-alias-type-price          as character no-undo .
define variable v-doc-code                  like ub.trn-doc.doc-code no-undo .
define variable v-prop-host-code            like ub.sysconf.host-code no-undo .
define variable v-prop-base-code            like ub.sysconf.base-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-price-obj-type            like ub.trn-doc.obj-type no-undo .
define variable v-price-obj-code            like ub.trn-doc.obj-code no-undo .
define variable v-sys-today                 as date no-undo .
define variable v-base-rate                 like ub.curr-accnt.exch-rate no-undo .
define variable v-base-scale                like ub.curr-accnt.exch-scale no-undo .
define variable v-exch-rate                 like ub.curr-accnt.exch-rate no-undo .
define variable v-exch-scale                like ub.curr-accnt.exch-scale no-undo .
define variable v-curr-abbr                 as character no-undo .
define variable v-attr-value                as character no-undo .
define variable v-attr-type                 as character no-undo .

define variable l-shift-on                  as logical no-undo init no.
define variable v-shift-date                like ub.shift-obj.shift-date no-undo.
define variable v-shift-num                 like ub.shift-obj.shift-num no-undo.
define variable v-shift-name                as   character no-undo.
define variable v-out-pay                   like ub.shop.out-pay no-undo .
define variable v-purch-code                like ub.trn-doc.purch-code no-undo .
define variable v-purch-name                as character no-undo .
define variable v-curr-code                 like ub.contract.curr-code no-undo .
define variable v-contract-code             like ub.trn-doc.contract-code no-undo .
define variable v-gds-code                  like ub.goods.gds-code  no-undo .
define variable v-mes                       as character no-undo .
define variable v-ps                        as character no-undo .
define variable v-discnt-type               as character no-undo .
define variable prev-doc-code               like ub.trn-doc.doc-code no-undo .
define variable v-num_rec-res-exist         as integer no-undo .
define variable v-current-doc-code          as character no-undo .


define buffer buf_bar-code for ub.bar-code.
define buffer buf_Clients for ub.clients.
define buffer buf_shop    for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_contract for ub.contract.
define buffer buf_prop_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer bufi_gds-dtl  for ub.gds-dtl.
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_tt0-doc-line for tt0-doc-line.
define buffer prev_sale-doc for ub.sale-doc.
define buffer buf_sale-doc for ub.sale-doc.
define temp-table tt0-one-doc-line no-undo like lib-trn_ret-line.
define temp-table tt0-one-gds-dtl  no-undo like ub.gds-dtl.
/*!!!!!!!!!!!!!!!!ВНИМАНИЕ!!!!!!!!!!!!!!!*/
/*в doc-qnty - лежит количество зарезервированное для нас в чужом документе*/
/*в fact-qnty -
перед передачей  СУСЛОВУ лежит количество необходимое для резервирования*/


define temp-table tt0-one-parts    no-undo like ub.parts.


_main:
do
on error undo, return error return-value :

  find first buf_clients no-lock where
            buf_clients.obj-type = p-obj-type
        AND buf_clients.obj-code = p-obj-code.

    { gbl/basecode.i p-host-code v-base-code }
  /*кусок сортировки и создания в случае необходимости расходных документах на объектах владельцах товара*/
  _doc-line:
  for each tt0-doc-line where
          tt0-doc-line.doc-code = "":U,
      each tt0-gds-dtl where
          tt0-gds-dtl.obj-type = tt0-doc-line.obj-type
      AND tt0-gds-dtl.obj-code = tt0-doc-line.obj-code
      AND tt0-gds-dtl.prod-type = tt0-doc-line.prod-type
      AND tt0-gds-dtl.prod-code = tt0-doc-line.prod-code
      AND tt0-gds-dtl.artic     = tt0-doc-line.artic
      break
      by tt0-doc-line.obj-type
      by tt0-doc-line.obj-code
      :
    if p-artic = '':U
    or (tt0-doc-line.artic = p-artic
          and tt0-doc-line.prod-type = p-prod-type
          and tt0-doc-line.prod-code = p-prod-code)
          then do:

      run write-tt0-info in this-procedure (
                                            input tt0-doc-line.artic
                                          ,input tt0-doc-line.prod-type
                                          ,input tt0-doc-line.prod-code
                                          ,input tt0-gds-dtl.prt-code
                                          ,input tt0-doc-line.obj-type
                                          ,input tt0-doc-line.obj-code
                                          ,input tt0-doc-line.doc-code
                                          ,input yes /*from-tpsi*/
                                          ,input ?
                                          ,input ?
                                          ,input ?
                                          ,input ?
                                          ,input tt0-gds-dtl.doc-qnty
                                          ,input (if p-rz then (tt0-gds-dtl.doc-qnty - tt0-gds-dtl.fact-qnty)
                                                  else ( - tt0-gds-dtl.doc-qnty)
                                                  )
                                          ,input tt0-gds-dtl.doc-qnty
                                          ,input '':u).
      if p-num_rec_other modulo  10 = 0 then do:
        assign
        v-mes = substitute("&1 ЧУЖИХ товаров - обработано строк &2 успешно &3"
                                                              , p-title
                                                              , p-num_rec_other
                                                              , p-num_rec_other_res
                                                              ).
        if p-auto = 0 then
        run waitfram-show in this-procedure (input v-mes).
        else
        run write-counter in p-log-handle (input v-mes).
      end.
      assign
      p-num_rec_other = p-num_rec_other + 1 .
    end.
    if first-of(tt0-doc-line.obj-code) then do:
      { gbl/hostcode.i tt0-doc-line.obj-type tt0-doc-line.obj-code v-prop-host-code  }
      { gbl/basecode.i v-prop-host-code v-prop-base-code }
      run get-alias-type-price-obj  in this-procedure (
     /*получени етипа цены перемещения и объекта для взятия цены для пары ОБЪЕКТ ПРОДАЖИ - ОБЪЕКТ ПЕРЕМЕЩЕНИЯ*/
                                                          input p-host-code
                                                          ,input p-obj-type
                                                          ,input p-obj-code
                                                          ,input v-prop-host-code
                                                          ,input tt0-doc-line.obj-type
                                                          ,input tt0-doc-line.obj-code
                                                          ,output v-ext-doc-type
                                                          ,output v-alias-type-price
                                                          ,output v-price-obj-type
                                                          ,output v-price-obj-code) no-error .
      if error-status:error then do:

        undo _main, return error substitute("Ошибка при получении типа цены и объекта цены для перемещения с &1&2 на &3&4:&5&6 &7"
                                , p-obj-type
                                , p-obj-code
                                , tt0-doc-line.obj-type
                                , tt0-doc-line.obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).

      end.
      /*создание расходного документа*/
      CASE tt0-doc-line.obj-type:
        when {&shop} then do:
          find first buf_shop no-lock where
                    buf_shop.obj-code = tt0-doc-line.obj-code no-error .
          if not available buf_shop then
          undo _main, return error substitute("Не найден &1&2 (ОБЪЕКТ для перемещения ЧУЖИХ товаров для &2&3)"
                                    , tt0-doc-line.obj-type
                                    , tt0-doc-line.obj-code
                                    , p-obj-type
                                    , p-obj-code
                                    ).
          assign
          v-out-pay = buf_shop.out-pay.
        end.
        when {&stock} then do:
          find first buf_store no-lock where
                    buf_store.obj-code = tt0-doc-line.obj-code no-error .
          if not available buf_store then
          undo _main, return error substitute("Не найден &1&2 (ОБЪЕКТ для перемещения ЧУЖИХ товаров для &2&3)"
                                    , tt0-doc-line.obj-type
                                    , tt0-doc-line.obj-code
                                    , p-obj-type
                                    , p-obj-code
                                    ).
          assign
          v-out-pay = buf_store.out-pay.
        end.
      END CASE.
      if p-host-code <> v-prop-host-code then do:
      /*ищем ДОГОВОР ПЕРЕМЕЩЕНИЯ ТОВАРА ДРУГОЙ ФИРМОЙ*/
        find first buf_contract no-lock where
                  buf_contract.host-code = p-host-code
              AND buf_contract.cli-type = {&cmp}
              AND buf_contract.cli-code = v-prop-host-code
              AND buf_contract.status_ = {&current-contr}
              AND buf_contract.contract-type = {&contr-tpsi} no-error .
        if available buf_contract then do:
          run get-purch-contract in this-procedure (
                                                      input buf_contract.host-code
                                                     ,input buf_contract.contract-code
                                                     ,output v-purch-code
                                                     ,output v-purch-name) no-error .
          if error-status:error then do:
            undo _main, return error substitute("Ошибка при определении типа приобретения для документа межфирменного перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                          , tt0-doc-line.obj-type
                                          , tt0-doc-line.obj-code
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value
                                          ).
          end. /* if error-status:error then do:*/
          assign
          v-curr-code = buf_contract.curr-code
          v-contract-code = buf_contract.contract-code
          .
        end. /*if available buf_contract then do:*/
        else do:
          assign
          v-purch-code = integer({&repayment-code})
          v-curr-code = 0
          v-contract-code = 0
          .
        end. /*if NOT available buf_contract then do:*/
      end. /*if p-host-code <> v-prop-host-code then do: - МЕЖФИРМА*/
      else do: /*ВНУТРЕННИЙ РАСХОД*/
        assign
        v-purch-code = integer({&repayment-code})
        v-curr-code = v-base-code
        v-contract-code = 0
        .
      end.  /*ВНУТРЕННИЙ РАСХОД*/
      { gbl/objat.i tt0-doc-line.obj-type tt0-doc-line.obj-code "'shift-on=request'" l-shift-on no-error }
      if error-status:error then do:
        undo _main, return error substitute("Ошибка при определении параметра СМЕННАЯ РАБОТА на объекте для документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                      , tt0-doc-line.obj-type
                                      , tt0-doc-line.obj-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).

      end.
      if l-shift-on then do:
        { gbl/curshift.i tt0-doc-line.obj-type tt0-doc-line.obj-code v-shift-date v-shift-num v-shift-name no-error }
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при определении ДАТЫ И НОМЕРА СМЕНЫ на объекте для документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).

        end.
      end. /*if l-shift-on then do:*/
      { gbl/curobjdt.i tt0-doc-line.obj-type tt0-doc-line.obj-code v-sys-today no-error }
      if error-status:error then do:
        undo _main, return error substitute("Ошибка при определении даты на объекте для документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                      , tt0-doc-line.obj-type
                                      , tt0-doc-line.obj-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).

      end.
      /*ищем base-rate*/
      { gbl/baserate.i v-prop-host-code v-sys-today v-base-rate v-base-scale no-error }
      if error-status:error then do:
        undo _main, return error substitute("Ошибка при определении курса базовой валюты для документа перемещения ЧУЖИХ товаров с &1&2 на даут &3:&4&5&6"
                                      , tt0-doc-line.obj-type
                                      , tt0-doc-line.obj-code
                                      , string(v-sys-today, "99/99/9999")
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value
                                      ).

      end.
      if v-curr-code <> 0
      and v-curr-code <> v-base-code
      then do:
        /*ищем exch-rate*/
        { gbl/exchrate.i v-curr-code v-sys-today v-exch-rate v-exch-scale v-curr-abbr no-error }
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при определении курса валюты &1 для документа перемещения ЧУЖИХ товаров с &2&3 на дату &4:&5&6&7"
                                        , v-curr-code
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , string(v-sys-today, "99/99/9999")
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value

                                        ).
        end.
      end. /*if v-curr-code <> 0*/
      else do:
        if v-curr-code = 0 then do:
          assign
          v-exch-rate = 1
          v-exch-scale = 1
          .
        end.
        else do:
          assign
          v-exch-rate = v-base-rate
          v-exch-scale = v-base-scale
          .
        end.
      end. /*if NOT v-curr-code <> 0*/
      find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.tpsidoc = yes
            and buf_sale-doc.host-code  = v-prop-host-code
            and buf_sale-doc.obj-type   = tt0-gds-dtl.obj-type
            and buf_sale-doc.obj-code   = tt0-gds-dtl.obj-code no-error.
      if available buf_sale-doc then do:
        find first ub.sale-doc where recid(ub.sale-doc) = recid(buf_sale-doc).
        find first buf_prop_trn-doc where
                  buf_prop_trn-doc.doc-code = buf_sale-doc.doc-code no-error .
        if not available buf_prop_trn-doc then do:
          delete buf_sale-doc.
        end.
      end.
      if not available buf_prop_trn-doc then  do:
        run doc-code in this-procedure
         (input "main",
          input tt0-doc-line.obj-type,
          input tt0-doc-line.obj-code,
          input ?,
          output v-doc-code ) no-error.
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при генерации номера документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        assign
        v-ps =  '':U
        v-discnt-type = (if v-alias-type-price = {&alias-type-price-sale-doc} then {&row} else {&percent})
        .
        { str/crtrndoc.i
        ?
        ?
        v-base-rate
        v-base-scale
        "(if tt0-doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh} then p-host-code else p-obj-code)"
        "(if tt0-doc-line.ext-doc-type = {&TDEDT_Ras_Vnesh} then {&cmp} else p-obj-type)"
        buf_clients.obj-name
        g#db-num
        g#userid
        v-discnt-type
        v-doc-code
        v-sys-today
        {&expense}
        no
        v-prop-host-code
        "(if v-prop-host-code = p-host-code then yes else no)"
        tt0-doc-line.obj-code
        tt0-doc-line.obj-type
        no
        v-out-pay
        v-ps
        no
        {&without-SLT}
        {&doc-froze}
        ~{&inc-VAT~}
        tt0-doc-line.ext-doc-type
        v-purch-code
        no-error
        }
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при создании документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        find first buf_prop_trn-doc where
                  buf_prop_trn-doc.doc-code = v-doc-code no-error .
        if error-status:error then do:
          undo _main, return error substitute("Ошибка при создании документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                        , tt0-doc-line.obj-type
                                        , tt0-doc-line.obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
        end.
        assign
        buf_prop_trn-doc.exch-code = v-curr-code
        buf_prop_trn-doc.exch-rate = v-exch-rate
        buf_prop_trn-doc.exch-scale = v-exch-scale
        buf_prop_trn-doc.shift-date = if l-shift-on then v-shift-date else ?
        buf_prop_trn-doc.shift-num = if l-shift-on then v-shift-num else 0
        buf_prop_trn-doc.shift-name = if l-shift-on then v-shift-name else ""
        buf_prop_trn-doc.out-code  = buf_trn-doc.doc-code
        .
        if v-prop-host-code <> p-host-code then
        assign
        buf_prop_trn-doc.hold-obj-type = p-obj-type
        buf_prop_trn-doc.hold-obj-code = p-obj-code
        buf_prop_trn-doc.hold-doc-code-child  = "hold":u
        buf_prop_trn-doc.hold-doc-code-parent = "hold":u.
        buf_prop_trn-doc.contract-code = v-contract-code
        .
        /*сделаем запись в sale-doc*/
        run saledoc-create  in this-procedure (
                                                 input p-inkas-code
                                                ,input p-host-code
                                                ,input p-obj-type
                                                ,input p-obj-code
                                                ,input entry(lookup(buf_prop_trn-doc.ext-doc-type, {&tpsi-ext-doc-types}), {&tpsi-doc-kinds})                                              /*p-doc-kind*/
                                                ,input buf_prop_trn-doc.office
                                                ,input yes /*p-tpsidoc*/
                                                ,input v-alias-type-price /*p-alias-type-price*/
                                                ,input v-price-obj-type /*p-price-obj-type*/
                                                ,input v-price-obj-code /*p-price-obj-type*/
                                                ,buffer buf_prop_trn-doc ) no-error .
        if error-status:error then do:
          undo _main, return error substitute("Ошибка записи данных автодокумента вида &5 для продажи &4 в таблицу связанных документов по продажу:&1&2 &3"
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        , p-inkas-code
                                        , entry(lookup(buf_prop_trn-doc.ext-doc-type, {&tpsi-ext-doc-types}), {&tpsi-doc-kinds})
                                        ).
        end.
      end.
      assign
      v-current-doc-code = buf_prop_trn-doc.doc-code
      .
    end. /*if first-of tt-doc-line.doc-code*/

    /*КОНЕЦ СОЗДАНИЯ ШАПКИ РАСХОДА ДЛЯ ТЕХ TT У КОТОРЫХ НЕ БЫЛО ШАПКИ*/

    if p-artic = '':U
    or (tt0-doc-line.artic = p-artic
          and tt0-doc-line.prod-type = p-prod-type
          and tt0-doc-line.prod-code = p-prod-code)
          then do:
      /*блок заполнения цены gds-dtl*/
      /*найдем gds-code*/
      { gbl/gds-code.i tt0-doc-line.artic tt0-doc-line.prod-type tt0-doc-line.prod-code v-gds-code }
      CASE sale-doc.alias-type-price:
        when {&alias-type-price-cost}  then do:
          /*согалсно указаниям Суслова - если перемещение по учетной цене - то перед copy-ret заполняем нулями*/
          assign
          tt0-gds-dtl.price-rubl = 0
          tt0-gds-dtl.price-base = 0
          tt0-doc-line.road-tax  = 0
          tt0-doc-line.excise    = 0
          tt0-gds-dtl.doc-code   = v-current-doc-code
          tt0-doc-line.doc-code  = v-current-doc-code
          .
        end.
        when {&alias-type-price-sale-doc}  then do:
          /*согласно указаниям Суслова - если перемещение по цене док-та продажи и скидку мберем*/
          assign
          tt0-gds-dtl.ov         = yes
          tt0-gds-dtl.doc-code   = v-current-doc-code
          tt0-doc-line.doc-code  = v-current-doc-code
          .
        end.
        otherwise do:
          { str/get-pr.i calc
            v-price-obj-type
            v-price-obj-code
            v-gds-code
            tt0-gds-dtl.prt-code
            " run write-tt0-info in this-procedure (                                                          ~
                                                    input tt0-doc-line.artic                                  ~
                                                  ,input tt0-doc-line.prod-type                               ~
                                                  ,input tt0-doc-line.prod-code                               ~
                                                  ,input tt0-gds-dtl.prt-code                                 ~
                                                  ,input tt0-doc-line.obj-type                                ~
                                                  ,input tt0-doc-line.obj-code                                ~
                                                  ,input tt0-doc-line.doc-code                                ~
                                                  ,input yes                                                  ~
                                                  ,input ?                                                    ~
                                                  ,input ?                                                    ~
                                                  ,input ?                                                    ~
                                                  ,input ?                                                    ~
                                                  ,input tt0-gds-dtl.doc-qnty                                 ~
                                                  ,input (tt0-gds-dtl.doc-qnty - tt0-gds-dtl.fact-qnty)       ~
                                                  ,input tt0-gds-dtl.doc-qnty                                 ~
                                                  ,input substitute('товар &1: ошибка при определении цены товара на объекте &2&3:&4&5 &6', V-gds-code, v-price-obj-type, v-price-obj-code,  {&new-line}, error-status:get-message(1), return-value )). ~
          next _doc-line. "
          }
          assign
          tt0-gds-dtl.price-rubl = (if v-curr-r-b = {&r-b-rubl}
                                    then gp-price-sale
                                    else gp-price-sale * v-base-rate / v-base-scale)

          tt0-gds-dtl.price-base = (if v-curr-r-b = {&r-b-base}
                                    then gp-price-sale
                                    else gp-price-sale / (v-base-rate / v-base-scale))
          tt0-doc-line.road-tax    = gp-road-tax
          tt0-doc-line.excise      = gp-excise
          tt0-gds-dtl.doc-code   = v-current-doc-code
          tt0-doc-line.doc-code  = v-current-doc-code
          tt0-gds-dtl.ov         = yes
          .
        end.
      END CASE.
    end.
  end. /*for each tt0-doc-line no-lock where*/
  /*теперь есть и шапки и временные таблицы - пропихнем в них количество!!!!!!!!*/

  /*заказываем резервирование факт кол*/
  define variable v-rsrv-fact-qnty                      as logical no-undo init yes.
  /*заказываем резервирование хоть что нибудь*/
  define variable v-all-qnty                            as logical no-undo .
  /*заказываем  фиксация цен исходного документа */
  define variable v-fix-price                           as logical no-undo init yes .
  /*заказываем резервирование по партиям*/
  define variable v-use-parts                           as logical no-undo .
  _tpsi-doc:
  for each ub.sale-doc no-lock where
           ub.sale-doc.inkas-code = p-inkas-code
       and ub.sale-doc.tpsidoc = yes,
      first buf_prop_trn-doc where
            buf_prop_trn-doc.doc-code = ub.sale-doc.doc-code,
      first buf_sysconf no-lock where
           buf_sysconf.host-code = ub.sale-doc.host-code :
    /*пихнем процедуру СУСЛОВА!!!!!!!!!!!*/
  /*после копирования в них просталвются новые количества*/
  /*если parrsrv-fact-qnty = yes*/
  /*в fact-qnty - то то осталось дорезервировать*/
  /*в doc-qnty то что стоит в скопированной накладной в doc-qnty*/
  /*если parrsrv-fact-qnty = yes*/
  /*в doc-qnty - точ то осталось дорезервировать*/
  /*в fact-qnty то что стоит в скопированной накладной в fact-qnty*/

     /*проверим надо ли нам резервировать по данному документу - так ка может быть мы сюда поали резервируя НЕ ВСЕ ТОВАРЫ*/
     /* а определенный товар - на каком то другом объекте*/
    if p-artic <> "":U then do:
      find first buf_tt0-doc-line no-lock where
                (buf_tt0-doc-line.doc-code = sale-doc.doc-code
           AND  buf_tt0-doc-line.artic = p-artic
           AND  buf_tt0-doc-line.prod-type = p-prod-type
           AND  buf_tt0-doc-line.prod-code = p-prod-code)
        or     (buf_tt0-doc-line.obj-type = sale-doc.obj-type
           and  buf_tt0-doc-line.obj-code = sale-doc.obj-code
           AND  buf_tt0-doc-line.artic = p-artic
           AND  buf_tt0-doc-line.prod-type = p-prod-type
           AND  buf_tt0-doc-line.prod-code = p-prod-code)
              no-error .
      if not available buf_tt0-doc-line then NEXT _tpsi-doc.
    end.
    assign
    buf_prop_trn-doc.status_ = {&wayb}
    buf_prop_trn-doc.flag_  = no
    .
    if p-artic = '':U then do:
      { str/copy-ret.i
      parparentproc
      sale-doc.doc-code
      buf_trn-doc.doc-type
      buf_trn-doc.status_
      buf_trn-doc.internal
      buf_trn-doc.cli-type
      buf_trn-doc.cli-code
      buf_trn-doc.discnt-type
      buf_trn-doc.tot-calc
      buf_trn-doc.discnt-pc
      buf_trn-doc.agnt
      buf_trn-doc.boss
      buf_trn-doc.wrkr
      buf_trn-doc.base-rate
      buf_trn-doc.base-scale
      buf_trn-doc.exch-code
      buf_trn-doc.vat-type
      buf_prop_trn-doc.doc-code
      no
      buf_prop_trn-doc.discnt-pc
      buf_prop_trn-doc.agnt
      buf_prop_trn-doc.boss
      buf_prop_trn-doc.wrkr
      buf_prop_trn-doc.base-rate
      buf_prop_trn-doc.base-scale
      buf_sysconf.cash-pay
      buf_sysconf.base-code
      tt0-doc-line
      tt0-gds-dtl
      tt0-parts
      v-use-parts
      v-all-qnty
      v-fix-price
      v-rsrv-fact-qnty
      no-error }
    end.
    else do:
      /*чтобы сделать copy-ret по одному товару - надо сделать новые таблицы*/
      for each tt0-one-doc-line:
        delete tt0-one-doc-line.
      end.
      for each tt0-one-gds-dtl:
        delete tt0-one-gds-dtl.
      end.
      for each tt0-one-parts:
        delete tt0-one-parts.
      end.

      for each tt0-gds-dtl where
             tt0-gds-dtl.artic = p-artic
         and tt0-gds-dtl.prod-type = tt0-gds-dtl.prod-type
         and tt0-gds-dtl.prod-code = tt0-gds-dtl.prod-code
         and tt0-gds-dtl.prt-code = tt0-gds-dtl.prt-code:
         create tt0-one-gds-dtl.
         buffer-copy tt0-gds-dtl to tt0-one-gds-dtl.
         leave.
      end.
      for each tt0-doc-line where
             tt0-doc-line.artic = p-artic
         and tt0-doc-line.prod-type = tt0-doc-line.prod-type
         and tt0-doc-line.prod-code = tt0-doc-line.prod-code:
         create tt0-one-doc-line.
         buffer-copy tt0-doc-line
         except doc-qnty fact-qnty cli-qnty
         to tt0-one-doc-line.
         buffer-copy tt0-gds-dtl using  doc-qnty fact-qnty
         to tt0-one-doc-line.
      end.
      { str/copy-ret.i
      parparentproc
      sale-doc.doc-code
      buf_trn-doc.doc-type
      buf_trn-doc.status_
      buf_trn-doc.internal
      buf_trn-doc.cli-type
      buf_trn-doc.cli-code
      buf_trn-doc.discnt-type
      buf_trn-doc.tot-calc
      buf_trn-doc.discnt-pc
      buf_trn-doc.agnt
      buf_trn-doc.boss
      buf_trn-doc.wrkr
      buf_trn-doc.base-rate
      buf_trn-doc.base-scale
      buf_trn-doc.exch-code
      buf_trn-doc.vat-type
      buf_prop_trn-doc.doc-code
      no
      buf_prop_trn-doc.discnt-pc
      buf_prop_trn-doc.agnt
      buf_prop_trn-doc.boss
      buf_prop_trn-doc.wrkr
      buf_prop_trn-doc.base-rate
      buf_prop_trn-doc.base-scale
      buf_sysconf.cash-pay
      buf_sysconf.base-code
      tt0-one-doc-line
      tt0-one-gds-dtl
      tt0-one-parts
      v-use-parts
      v-all-qnty
      v-fix-price
      v-rsrv-fact-qnty
      no-error }
      for each tt0-one-doc-line,
         first tt0-doc-line where
              tt0-doc-line.artic = tt0-one-doc-line.artic
          and tt0-doc-line.prod-type = tt0-one-doc-line.prod-type
          and tt0-doc-line.prod-code = tt0-one-doc-line.prod-code:
         buffer-copy tt0-one-doc-line
         except doc-qnty fact-qnty cli-qnty
         to tt0-doc-line.
         /*в этот момент в tt0-gds-dtl qnty лежит столько сколько лежал в tt0-doc-line qnty ДО copy-ret*/
         assign
         tt0-doc-line.doc-qnty = tt0-doc-line.doc-qnty - tt0-gds-dtl.doc-qnty + tt0-one-doc-line.doc-qnty
         /*новое               = старое по всем признакам - старое по одному признаку + новое по одному признаку*/
         tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty - tt0-gds-dtl.fact-qnty + tt0-one-doc-line.doc-qnty
         .
      end.
      for each tt0-one-gds-dtl,
         first tt0-gds-dtl where
              tt0-gds-dtl.artic = tt0-one-gds-dtl.artic
          and tt0-gds-dtl.prod-type = tt0-one-gds-dtl.prod-type
          and tt0-gds-dtl.prt-code = tt0-one-gds-dtl.prt-code:
        buffer-copy
        tt0-one-gds-dtl using doc-qnty fact-qnty
        to tt0-gds-dtl.
      end.
    end.
    if error-status:error then do:
      for each tt0-info no-lock where
              tt0-info.doc-code = '':U,
          first buf_tt0-doc-line  where
                buf_tt0-doc-line.doc-code = sale-doc.doc-code
            and buf_tt0-doc-line.artic = tt0-info.artic
            and buf_tt0-doc-line.prod-type = tt0-info.prod-type
            and buf_tt0-doc-line.prod-code = tt0-info.prod-code
      break
      by tt0-info.artic
      by tt0-info.prod-type
      by tt0-info.prod-code:
        if first-of (tt0-info.prod-code) then do:
          if p-artic <> ""
          and not (tt0-info.artic = p-artic
              and tt0-info.prod-type = p-prod-type
              and tt0-info.prod-code = p-prod-code )
          then next.
          assign
          buf_tt0-doc-line.doc-code = ''.
        end.
      end.
      for each tt0-info where
              tt0-info.doc-code = '':U,
          first tt0-gds-dtl  where
                tt0-gds-dtl.doc-code = sale-doc.doc-code
            and tt0-gds-dtl.artic = tt0-info.artic
            and tt0-gds-dtl.prod-type = tt0-info.prod-type
            and tt0-gds-dtl.prod-code = tt0-info.prod-code
            and tt0-gds-dtl.prt-code  = tt0-info.prt-code
      break
      by tt0-info.artic
      by tt0-info.prod-type
      by tt0-info.prod-code:
        if p-artic = ""
        or (tt0-gds-dtl.artic = p-artic
            and tt0-gds-dtl.prod-type = p-prod-type
            and tt0-gds-dtl.prod-code = p-prod-code
            and tt0-gds-dtl.prt-code = p-prt-code ) then do:
          assign
          tt0-gds-dtl.doc-code = ''
          tt0-info.error-message =  substitute("Ошибка при копировании линий в документ перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                      , sale-doc.obj-type
                                      , sale-doc.obj-code
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value)
          .
        end.
      end.
      if p-artic <> "":U then
      undo _tpsi-doc, return error substitute("Ошибка при копировании линий в документ перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                    , sale-doc.obj-type
                                    , sale-doc.obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
      else do:
        undo _tpsi-doc, NEXT _tpsi-doc.
      end.
    end.
    assign
    buf_prop_trn-doc.status_ = {&doc-froze}
    buf_prop_trn-doc.flag_  = no
    .
    case sale-doc.alias-type-price :
      when {&alias-type-price-cost}  then do:
        /*перемещение должно происходить по учетной цене */
        /*слова суслова - для этого надо по всем gds-dtl приравнять gds-dtl.price-rubl и gds-dtl.price-base
        соответствующим doc-line.price-rubl doc-line.price=base
        */
        for each buf_doc-line no-lock where
                buf_doc-line.doc-code = buf_prop_trn-doc.doc-code,
            each buf_gds-dtl WHERE
                buf_gds-dtl.doc-code = buf_prop_trn-doc.doc-code
            AND buf_gds-dtl.doc-code = buf_prop_trn-doc.doc-code:
        if p-artic <> '':u
        and not (buf_gds-dtl.artic = p-artic
            and buf_gds-dtl.prod-type = p-prod-type
            and buf_gds-dtl.prod-code = p-prod-code
            and buf_gds-dtl.prt-code = p-prt-code )
        then next.
        assign
        buf_gds-dtl.price-base       = buf_doc-line.price-base
        buf_gds-dtl.price-rubl       = buf_doc-line.price-rubl
        .
        END. /*      for each buf_doc-line no-lock where*/
      end. /*if sale-doc.alias-type-price = {&alias-type-price-cost}  then do:*/
      when {&alias-type-price-sale-doc} then do:
        for each buf_gds-dtl where
                buf_gds-dtl.doc-code = buf_prop_trn-doc.doc-code,
            first bufi_gds-dtl WHERE
                bufi_gds-dtl.doc-code = buf_trn-doc.doc-code
            AND bufi_gds-dtl.artic = buf_gds-dtl.artic
            AND bufi_gds-dtl.prod-type = buf_gds-dtl.prod-type
            AND bufi_gds-dtl.prod-code = buf_gds-dtl.prod-code
            AND bufi_gds-dtl.prt-code = buf_gds-dtl.prt-code :
          if p-artic <> '':u
          and not (buf_gds-dtl.artic = p-artic
              and buf_gds-dtl.prod-type = p-prod-type
              and buf_gds-dtl.prod-code = p-prod-code
              and buf_gds-dtl.prt-code = p-prt-code )
          then next.
          assign
          buf_gds-dtl.price-base  = bufi_gds-dtl.price-base
          buf_gds-dtl.price-rubl  = bufi_gds-dtl.price-rubl
          buf_gds-dtl.discnt-base = bufi_gds-dtl.discnt-base
          buf_gds-dtl.discnt-rubl = bufi_gds-dtl.discnt-rubl
          buf_gds-dtl.discnt-type = no
          buf_gds-dtl.discnt-pc   = buf_gds-dtl.discnt-rubl * 100 / buf_gds-dtl.price-rubl

          .
        END. /*      for each buf_doc-line no-lock where*/
      end. /*{&alias-type-price-sale-doc} t*/
    END CASE.
    run gbl/calc-trn.p (input parparentproc, input recid(buf_prop_trn-doc)) no-error .
    if error-status:error then do:
      undo _tpsi-doc, return error substitute("Ошибка при расчете шапки документа перемещения ЧУЖИХ товаров с &1&2:&3&4&5"
                                    , sale-doc.obj-type
                                    , sale-doc.obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
    end.
  end. /*конец цикла непосредственного копирования на чужой объект*/

  /*установим количество удачно зарезервированных*/
  prev-doc-code = '':U.
  for each  sale-doc where
          sale-doc.inkas-code = p-inkas-code:
    assign
    sale-doc.tot-dtl = 0
    .
    for each tt0-gds-dtl no-lock where
        tt0-gds-dtl.doc-code = sale-doc.doc-code:
      sale-doc.tot-dtl = sale-doc.tot-dtl + 1.
      if tt0-gds-dtl.fact-qnty = 0 then do:
        find first tt0-info where
            tt0-info.artic = tt0-gds-dtl.artic
        and tt0-info.prod-type = tt0-gds-dtl.prod-type
        and tt0-info.prod-code = tt0-gds-dtl.prod-code
        and tt0-info.prt-code = tt0-gds-dtl.prt-code no-error .
      end.
      else do:
        if available tt0-info then release tt0-info.
      end.
      if tt0-gds-dtl.fact-qnty = 0
      and (available tt0-info and tt0-info.o-was-res <> tt0-gds-dtl.doc-qnty)
      then do:
        if p-artic = "":U
        or (tt0-gds-dtl.artic = p-artic
          and
          tt0-gds-dtl.prod-type = p-prod-type
          AND
          tt0-gds-dtl.prod-code = p-prod-code
          AND
          tt0-gds-dtl.prt-code = p-prt-code
          )
        then
        assign
        p-num_rec_other_res = p-num_rec_other_res + 1
        p-num_rec_res = p-num_rec_res + 1
        .
      end.
    end.
    find first buf_prop_trn-doc where
           buf_prop_trn-doc.doc-code = sale-doc.doc-code.
    find first prev_sale-doc where prev_sale-doc.doc-code = sale-doc.doc-code.
    assign
    buf_prop_trn-doc.ps = set-tpsi-doc-ps(buffer prev_sale-doc)
    prev_sale-doc.ps = buf_prop_trn-doc.ps
    .
  end.
  /*
  p-num_rec_res = p-num_rec_res - v-num_rec-res-exist.
  */
  if p-auto = 0 then
  run waitfram-hide in this-procedure .
  else
  run hide-counter in p-log-handle.
end. /*doe*/

procedure get-purch-contract :
define input parameter p-host-code              like ub.sysconf.host-code no-undo .
define input parameter p-contract-code          like ub.contract.contract-code no-undo .
define output parameter p-purch-code            like ub.trn-doc.purch-code no-undo .
define output parameter p-purch-name            as character no-undo .
define buffer bf_contract for ub.contract.
do on error undo, return error return-value :
  find first bf_contract where bf_contract.host-code     = p-host-code     and
                               bf_contract.contract-code = p-contract-code no-lock.
  /*Меняем тип приобретения по документу, исходя из данных по договору*/
  if lookup (bf_contract.contract-type, {&contr-purch-repayment}) > 0 then do:
    &scop purchase-code {&repayment-code}
    assign
      p-purch-name = {&purchase-codes-name}.
  end.
  else do:
    if lookup (bf_contract.contract-type, {&contr-purch-consignation}) > 0 then do:
      &scop purchase-code {&consignation-code}
      assign
        p-purch-name = {&purchase-codes-name}.
    end.
    else do:
      if lookup (bf_contract.contract-type, {&contr-purch-resp-store}) > 0 then do:
        &scop purchase-code {&responsible-storage-code}
        assign
          p-purch-name = {&purchase-codes-name}.
      end.
      else do:
        return error substitute("Нельзя определить по договору &1 (фирма &2) с типом &3 тип приобретения"
                                , bf_contract.contract-prn-code
                                , p-host-code
                                , bf_contract.contract-type ).
      end.
    end.
  end.
  assign
  p-purch-code = lookup (p-purch-name, {&purchase-codes-full}).
end. /*DOE*/
end procedure.