block-level on error undo, throw.
/*

$Revision: 18022dc3b171, 1949, rls $
$Author: SSlivenko $
$Date: Fri Jul 26 11:38:58 2019 +0300 $
$Workfile: excl-chk.p $
$Archive: str/excl-chk.p $

Исключение чека из незакрытой продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/02/05
Author: Bakhtadze Natalya
Creation date: 10/02/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-r-b as character no-undo .
define parameter buffer X_chk-doc for ub.chk-doc.
define variable vss-revision    as character no-undo init "$Revision: 18022dc3b171, 1949, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:38:58 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: excl-chk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/excl-chk.p $":U .
define variable vss-description as character no-undo init "Исключение чека из незакрытой продажи".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i }
{ str/clc-exc.i }
{ str/findtank.i }
{ str/t-gds.i def excl-chk }
{ gbl/waitfram.i }
/*поскольку сюда попадаем только из продажи то можем звять определение шареной таблицы для ТПСИ док-тов*/
{ str/lib-def.i }
{ str/trdcalib.i }
{ str/inkas-ps.i }
{ str/tpsidoc.i "shared" proc }
{ str/saledoc.i }
{ ref/gdsoattr.i }
{ gbl/tpsi-gds.i }
{ str/inc-salf.i }
{ str/lib-trn.i }
{ ref/gds-attr.i }

&glob display-message  run waitfram-show in this-procedure (~{&MY-MESSAGE~} )

&glob display-message-laud  MESSAGE ~{&MY-MESSAGE~}

&glob display-count-message run waitfram-show in this-procedure (input ~{&MY-count-MESSAGE~} )

&glob hide-count-message  run waitfram-hide in this-procedure

define buffer for-gds for ub.chk-gds.
define buffer for2-gds for ub.chk-gds.
define buffer for-doc for ub.chk-doc.
define buffer buf-bar for ub.bar-code.
/*вспомогательная*/
define variable temp-qnty like ub.gds-dtl.fact-qnty no-undo .
/*кол-во чеков в продаже*/
define variable chk-amount as integer.
/*кол-во строк чеков в продаже*/
define variable gds-amount as integer.
/*кол-во товаров в продаже расход*/
define variable line-out as integer.
/*кол-во признаков в продаже расход*/
define variable dtl-out as integer.
/*кол-во товаров в продаже возврат*/
define variable line-ret as integer.
/*кол-во признаков в продаже возврат*/
define variable dtl-ret as integer.
/*кол-во нф  + техпролив чеков в продаже*/
define variable nf-chk-amount as integer.
/*кол-во нф чеков в продаже*/
define variable nff-chk-amount as integer.
/*кол-во строк нф чеков в продаже*/
define variable nf-gds-amount as integer.
define variable add-nf-amount as integer   no-undo .
define variable add-NF-gds-amount as integer   no-undo .
define variable num_resv as integer no-undo.
/*количество зарезервированных позиций*/
define variable num_resv_res as integer no-undo.
/*количество удачно зарезервированных позиций*/



/*чек расход или возврат*/
define variable KIND-TO-RESERV as character no-undo .
define variable KIND-TO-RESERV-GDS as character no-undo .
define variable office-TO-RESERV as character no-undo .
define variable office-TO-RESERV-GDS as character no-undo .
define variable docs-to-reserv as integer no-undo .    /*количество документов для резеривирования ЧЕКА вобщем*/
define variable docs-to-reserv-gds as integer no-undo . /*количество документов для резеривирования строки*/
define variable v-add as logical no-undo .
define variable dtrg as integer no-undo . /*счетчик документов по которым резервируем одну строку временной таблицы*/

/*кол-во полож или отриц*/
define variable posit as logical no-undo.
define variable negat as logical no-undo.
/*количество резервируемых позиций*/
define variable v-curr-r-b as character no-undo .

/*общие определения для резервирования в продаже и исключения чеков - */
{ str/salersrv.i def }
define variable two-units-parts as logical no-undo .
define variable deleted-d as logical no-undo.
define variable deleted-g as logical no-undo.
define variable zero-gds-dtl as logical no-undo.
define variable found as logical no-undo.
/*откуда брать цены в накладную - из чека или из прайс-листа*/
define variable prcl-spl as logical no-undo init no.
/*фактор дор налога*/
define variable factorrt as decimal no-undo.
define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable par-type as char no-undo.
define variable for-price as decimal no-undo.
define variable for-excise as decimal no-undo.
define variable autofbr as logical no-undo .
/*должен быть нет потому что при снятии резервов все равно ничего нек проверяем*/

/*recid записи с которой надо снять - поставить резервы */
define variable rdoc-line as recid no-undo.
/*какую единичную запись резервируем расход или возврат*/
define variable r-or-v as character no-undo.
/*кодл скл места*/
define variable plcode like ub.doc-pl.pl-code no-undo.
define variable pumpcode like ub.doc-pl-pump.pump-code no-undo.
define variable dopf as decimal no-undo.
/*тип выручки*/
DEFINE VARIABLE var-doc-type like ub.inkas-pay-desk.doc-type no-undo .
define variable v-discnt-r-b like ub.gds-dtl.discnt-rubl no-undo .
define variable v-price-r-b like ub.gds-dtl.price-rubl no-undo .
define variable v-is-tpsi-obj as logical no-undo .
define variable v-run-tpsi    as logical no-undo .
define variable v-real-qnty like ub.inkas.qnty no-undo .
define variable v-base-rate like ub.trn-doc.base-rate no-undo .
define variable v-base-scale like ub.trn-doc.base-scale no-undo .
define variable v-cash-pay-attr as character no-undo.
define variable cli-type-to-reserv as character no-undo.
define variable cli-code-to-reserv as integer no-undo.

define variable par-alcohol as character no-undo .

define variable v-mark as character no-undo .
define variable v-mark-list as character no-undo .
define variable mark-ii as integer  no-undo .

define variable v-host-code like ub.sysconf.host-code no-undo .
define variable p-filter-rus as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-discnt for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer dop_trn-doc for ub.trn-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf0_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.

/*определение процедуры резервирования/снятия резервов*/

{ str/salersrv.i " " excl-chk }

do
on error undo, return error return-value
:

  /*если r-qnty = ? то снимаются ВСЕ резервы по строке а нам это и надо*/
  assign
  r-qnty = ?.
  rsrv-title = substitute("Снятие резервов со всех товаров чека &1. Строк ", X_chk-doc.doc-code)
  .

  FIND FIRST ub.inkas WHERE ub.inkas.inkas-code = X_chk-doc.out-code NO-LOCK NO-ERROR.
  if not avail ub.inkas then do:
      message
      substitute("Ошибка! Чек &1 привязан к отсутствующему отчету о продаже!", X_chk-doc.doc-code)
      view-as alert-box ERROR.
      return error.
  end.

  { gbl/hostcode.i ub.inkas.obj-type ub.inkas.obj-code v-host-code }
  run get-inkas-ps in this-procedure (
                                        buffer inkas
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output p-filter-rus
                                      ).
  FIND FIRST buf0_trn-doc exclusive-lock WHERE
           buf0_trn-doc.doc-code = X_chk-doc.out-code no-wait NO-ERROR.
  if not avail buf0_trn-doc then do:
      message
      substitute("Не найдена или не занята накладная &1!", X_chk-doc.out-code)  view-as alert-box ERROR.
      undo, return error.
  end.
  assign
  v-base-rate = buf0_trn-doc.base-rate
  v-base-scale = buf0_trn-doc.base-scale
  .


  { gbl/curr-r-b.i
    v-curr-r-b
  }

  docs-to-reserv = get-inc-sal(string(X_chk-doc.chk-type)
                              , input X_chk-doc.netto
                              , input yes
                              , input X_chk-doc.office
                              , input ?
                              , output v-add
                              , output office-to-reserv
                              , output kind-to-reserv
                              , output add-nf-amount
                              ).
                              
  v-cash-pay-attr = "".
  cli-type-to-reserv = "".
  cli-code-to-reserv = 0.
  
  if X_chk-doc.chk-type = integer({&rcpt-tech-refuell}) then do:
  
      for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
          
          find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                       and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                       and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
          
          if not available(buf_cash-pay-attr) then next.
          
          v-cash-pay-attr = buf_cash-pay-attr.attr-value.
          
          case entry(1, v-cash-pay-attr, ','):
          
              when {&sale-add-write-off} then do: /* Списание */
                  v-add = no.
                  docs-to-reserv = 1.
                  office-to-reserv = {&gds-goods}.
                  kind-to-reserv = entry(1, v-cash-pay-attr, ','). /* {&sale-add-write-off} */
                  cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                  cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
              end.
              
              when {&sale-add-tech-refuell} then do: /* Техпролив */
                  cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                  cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
              end.
              
              when {&sale-add-vir-res} then do: /* Перемещение в вирт.рез. */
                  kind-to-reserv = {&sale-add-vir-res}. /* {&sale-add-write-off} */
                  cli-type-to-reserv = entry(2, v-cash-pay-attr, ',').
                  cli-code-to-reserv = int(entry(3, v-cash-pay-attr, ',')).
              end.
              
              when 'none' then do:
                  docs-to-reserv = 0.
                  kind-to-reserv = 'none'.
              end. /* не создавать */
              
          end case.
          
      end. /* for each buf_chk-pay */
  
  end. /* if X_chk-doc.doc-type */                            

  /*проверим на ТПСИ*/
  assign
  v-is-tpsi-obj = can-find(first tpsi_sale-doc no-lock where
                                tpsi_sale-doc.inkas-code = X_chk-doc.out-code
                            and tpsi_sale-doc.tpsidoc = yes).

  { gbl/getsect.i run "''" 0 {&attr-nakl_par} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'factorrt' then factorrt = thbjattr_thbj-attr.property-value-integer .
  end.

  /*найдем параметр - откуда брать цены на товар в накладную - из чека или из прайс-листа*/
  /*по умолчанию из чека*/

  run adm/shattri.p (
      input "get":U
      ,input  inkas.obj-type
      ,input  inkas.obj-code
      ,input  {&attr-autosale}
      ,input  {&attr-autosale_prcl-spl} /*p-param-code*/
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF not error-status:error then
  assign
  prcl-spl = v-value-logical.
  delete object v-tth.

  btltaxcd = integer({&road-tax-code}).
  for each buf_sale-doc where
          buf_Sale-doc.inkas-code = inkas.inkas-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    buf_sale-doc.chk-doc-code = '':U.
  end.
  /*создание временной таблицы по товарам чека*/
  _chk-gds:
  for each buf_chk-gds NO-LOCK WHERE buf_chk-gds.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1) :
      /*очистим!!*/
    assign
    docs-to-reserv-gds = 0
    kind-to-reserv-gds = '':U
    office-to-reserv-gds = '':U
    add-nf-gds-amount  = 0
    v-add = no
    .
    if buf_chk-gds.doc-qnty = 0 then do:
      gds-amount = gds-amount  - 1.
      nf-gds-amount = nf-gds-amount + (if lookup(string(X_chk-doc.chk-type) ,{&no-docum-receipt-codes}) > 0
                                        then - 1
                                        else 0).
      next _chk-gds.
    end.
    docs-to-reserv-gds = get-inc-sal(string(X_chk-doc.chk-type)
                                , input X_chk-doc.netto
                                , input no
                                , input entry(1, buf_chk-gds.line-type, {&delim-par})
                                , input string(BUF_CHK-GDS.WRITE-OFF-CODE)
                                , output v-add
                                , output office-to-reserv-gds
                                , output kind-to-reserv-GDS
                                , output add-nf-gds-amount
                                ).
    
    if X_chk-doc.chk-type = integer({&rcpt-tech-refuell}) then do:
    
        for each buf_chk-pay where buf_chk-pay.doc-code = X_chk-doc.doc-code no-lock:
            
            find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                                         and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
                                         and buf_cash-pay-attr.attr-code = "dop-doc" no-lock no-error.
            
            if not available(buf_cash-pay-attr) then next.
            
            v-cash-pay-attr = buf_cash-pay-attr.attr-value.
            
            case entry(1, v-cash-pay-attr, ','):
                when {&sale-add-vir-res} then do: /* Перемещение в вирт.рез. */
                    assign
                    kind-to-reserv-gds = {&sale-add-vir-res}
                    docs-to-reserv-gds = 1
                    v-add = no
                    office-TO-RESERV-GDS = 'т'.
                end.
                when 'none' then do:
                    assign
                    kind-to-reserv-gds = 'none'
                    docs-to-reserv-gds = 0
                    v-add = no
                    office-TO-RESERV-GDS = 'т'.
                end.
             end case.       
        end. /* for each buf_chk-pay */
    
    end. /* if X_chk-doc.doc-type */                            
                                
    gds-amount = gds-amount - 1.
    nf-gds-amount = nf-gds-amount  - add-nf-gds-amount.
    assign
    office-to-reserv-gds = (if v-add
                          then (office-to-reserv + (if kind-to-reserv-gds = '':u
                                                  then '':u
                                                  else {&comma-char}) +
                               office-to-reserv-gds)
                         else  office-to-reserv-gds)
    kind-to-reserv-gds = (if v-add
                          then (kind-to-reserv + (if kind-to-reserv-gds = '':u
                                                  then '':u
                                                  else {&comma-char}) +
                               kind-to-reserv-gds)
                         else  kind-to-reserv-gds)
    docs-to-reserv-gds = (if v-add
                          then (docs-to-reserv  + docs-to-reserv-gds)
                          else docs-to-reserv-gds)
    .
    if docs-to-reserv-gds <> 0 then dO:
      FIND FIRST ub.bar-code No-LOCK WHERE
                ub.bar-code.b-code = buf_chk-gds.b-code No-ERROR.
      IF NOT AVAIL bar-code then do:
        message
        substitute("Ошибки в строке чека &1 - товар с кодом &2 отсутствует в базе!"
                   , X_chk-doc.doc-code
                   , buf_chk-gds.b-code)
        view-as alert-box ERROR.
        run waitfram-hide in this-procedure .
        undo, return error.
      END.
      FIND FIRST ub.goods NO-LOCK WHERE
                  ub.goods.gds-code = ub.bar-code.gds-code NO-ERROR.
      FIND FIRST ub.units No-LOCK WHERE
                  ub.units.unit-name = ub.goods.unit-base NO-ERROR.
      IF NOT AVAIL(goods) then do:
        message "Не найден товар!" view-as alert-box ERROR.
        run waitfram-hide in this-procedure .
        undo, return error.
      end.
      IF NOT AVAIL(ub.units) then do:
        message "Не найдена единица измерения!" view-as alert-box ERROR.
        run waitfram-hide in this-procedure .
        undo, return error.
      end. /*not avail goods*/
      if can-find(first ub.tax-units where
                        ub.tax-units.tax-code = btltaxcd AND
                        LOOKUP(ub.tax-units.type, units.type) > 0 ) then  do:
        assign
        bottle = yes.
      end.
      else do:
        bottle = no.
      end.
      _dtrg-gds:
      do dtrg = 1 to docs-to-reserv-gds:
        if entry(dtrg, office-to-reserv-gds) <> entry(1, buf_chk-gds.line-type, {&delim-par}) then next _dtrg-gds.
        find first buf_sale-doc where
                  buf_Sale-doc.inkas-code = inkas.inkas-code
              and buf_sale-doc.doc-kind = entry(dtrg, kind-to-reserv-gds)
              and buf_sale-doc.chr-office = entry(dtrg, office-to-reserv-gds)
              .
        if dtrg <= docs-to-reserv
        and X_chk-doc.doc-code <> buf_sale-doc.chk-doc-code then do:
          assign
          buf_sale-doc.chk-doc-code = X_chk-doc.doc-code
          buf_sale-doc.chk-amount = buf_sale-doc.chk-amount - 1
          .
        end.
        find first buf_doc-line nO-lock where
                  buf_doc-line.doc-code = buf_sale-doc.doc-code
             AND  buf_doc-line.artic = goods.artic
             AND  buf_doc-line.prod-type = goods.prod-type
             AND  buf_doc-line.prod-code = goods.prod-code No-ERROR.
        if not avail buf_doc-line then NEXT.
        FIND FIRST buf_gds-dtl WHERE
                  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
             AND  buf_gds-dtl.artic = goods.artic
             AND  buf_gds-dtl.prod-code = goods.prod-code
             AND  buf_gds-dtl.prod-type = goods.prod-type
             AND  buf_gds-dtl.prt-code = bar-code.node-code NO-ERROR.
        if not avail buf_gds-dtl then NEXT.
        for-price = 0.
        assign
        plcode = ?
        cashplace = no.
        if buf_chk-gds.pump > 0 then do:
          if buf_chk-gds.pl-code <> 0
          and buf_chk-gds.pl-code <> ? then do:
            plcode = buf_chk-gds.pl-code.
          end.
          else do:
            run findtank in this-procedure
                            (input  inkas.obj-type,
                              input  inkas.obj-code,
                              input  buf_chk-gds.pump,
                              input  buf_chk-gds.nozzle-code,
                              input  buf_chk-gds.pl-code,
                              input  goods.gds-code,
                              output plcode         ) no-error.
          end.
          assign
          pumpcode = buf_chk-gds.pump.
          if plcode <> ? then do:
            FIND FIRST ub.doc-pl No-LOCK WHERE
                      ub.doc-pl.gds-code = ub.goods.gds-code
                 AND  ub.doc-pl.out-code = buf_sale-doc.doc-code NO-ERROR.
            IF AVAIL ub.doc-pl
            then
            cashplace = yes .
            else cashplace = no.
          end.
        end.
        else pumpcode = 0.
        if not cashplace then do:
          two-units-parts = no.
          IF lookup({&twounit}, ub.units.type) > 0 then do:
          FIND FIRST ub.doc-prts No-LOCK WHERE
                    ub.doc-prts.gds-code = ub.goods.gds-code
               AND  ub.doc-prts.out-code = buf_sale-doc.doc-code
               AND  ub.doc-prts.fact-qnty = abs(buf_chk-gds.doc-qnty) NO-ERROR.
             assign
             two-units-parts = yes.
          end.
          else do:
          FIND FIRST ub.doc-prts No-LOCK WHERE
                    ub.doc-prts.b-code = buf_chk-gds.b-code
                AND ub.doc-prts.out-code = buf_sale-doc.doc-code NO-ERROR.
          end.
          IF ub.bar-code.in-code <> "" OR AVAIL ub.doc-prts
          then cashparts = yes.
          else cashparts = no.
          release doc-prts.
        end.
        else cashparts = no.
        if NOT two-units-parts then
        find first t-gds WHERE
                  t-gds.doc-code = buf_sale-doc.doc-code
             AND  t-gds.b-code = buf_chk-gds.b-code
             AND  t-gds.artic = ub.goods.artic
             AND  t-gds.prod-type = ub.goods.prod-type
             AND  t-gds.prod-code = ub.goods.prod-code
             AND  t-gds.node-code = ub.bar-code.node-code
             AND  t-gds.pl-code = plcode
             AND  t-gds.pump = pumpcode
             AND  t-gds.fbr-obj-type = buf_chk-gds.depart-type
             AND  t-gds.fbr-obj-code = buf_chk-gds.depart-code NO-ERROR.
        IF NOT AVAIL t-gds oR two-units-parts then do:
          /*найдем цену которая будет на данном товаре в накладной после исключения чека*/
          if not prcl-spl then do:
            IF avail buf_gds-dtl
            AND ((p-curr-r-b = {&r-b-base} and buf_gds-dtl.price-base <> buf_chk-gds.price-base )
                OR
                (p-curr-r-b = {&r-b-rubl} and buf_gds-dtl.price-rubl <> buf_chk-gds.price-base )
                )
            then  for-price = (if p-curr-r-b = {&r-b-base}
                              then buf_gds-dtl.price-base
                              else buf_gds-dtl.price-rubl)
                              .
            else do:
              if cashparts then dO:
                FOR EACH buf-bar No-LOCK WHERE
                        buf-bar.gds-code = goods.gds-code,
                    EACH for-gds NO-LOCK where
                        for-gds.b-code = buf-bar.b-code AND
                        for-gds.out-code = X_chk-doc.out-code AND
                        NOT for-gds.doc-code = X_chk-doc.doc-code
                        BY for-gds.doc-code DESCENDING:
                  if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 AND
                    (for-gds.price-base + for-gds.price-service) = 0 AND
                    can-find(first for2-gds WHERE
                                    for2-gds.b-code = buf_chk-gds.b-code AND
                                    for2-gds.out-code = buf_chk-gds.out-code AND
                                    for2-gds.doc-code <> buf_chk-gds.doc-code AND
                                    for2-gds.doc-code <> for-gds.doc-code)
                  then NEXT.
                  LEAVE.
                END.
                if avail for-gds then
                for-price = for-gds.price-base.
              end.
              else do:
                FOR each for-gds no-lock where
                                for-gds.out-code = X_chk-doc.out-code and
                                for-gds.b-code = bar-code.b-code AND
                                NOT for-gds.doc-code = X_chk-doc.doc-code
                        BY  for-gds.doc-code DESCENDING:
                            if (buf_chk-gds.price-base + buf_chk-gds.price-service) > 0 AND
                              (for-gds.price-base + for-gds.price-service) = 0 AND
                              can-find(first for2-gds WHERE
                                              for2-gds.b-code = buf_chk-gds.b-code AND
                                              for2-gds.out-code = buf_chk-gds.out-code AND
                                              for2-gds.doc-code <> buf_chk-gds.doc-code AND
                                              for2-gds.doc-code <> for-gds.doc-code)
                              then NEXT.
                  LEAVE.
                END.
                if avail for-gds then
                for-price = for-gds.price-base.
              end.
            end.
          end. /*IF not prcl-spl*/
          if not avail t-gds OR (LOOKUP({&twounit}, units.type) > 0 ) then do:
            create t-gds.
            assign
            t-gds.doc-code = buf_sale-doc.doc-code
            t-gds.b-code = buf_chk-gds.b-code
            t-gds.gds-code = goods.gds-code
            t-gds.artic = goods.artic
            t-gds.prod-type = goods.prod-type
            t-gds.prod-code = goods.prod-code
            t-gds.unit-base = goods.unit-base
            t-gds.cashparts = cashparts
            t-gds.cashplace = cashplace
            t-gds.pl-code  = plcode
            t-gds.density = buf_chk-gds.density
            t-gds.pump = pumpcode
            t-gds.fbr-obj-type = buf_chk-gds.depart-type
            t-gds.fbr-obj-code = buf_chk-gds.depart-code
            t-gds.doc-qnty = 0
            t-gds.price-service = buf_chk-gds.price-service
            t-gds.node-code = bar-code.node-code
            t-gds.new-price = for-price
            t-gds.rdoc-line = recid(buf_doc-line)
            t-gds.rgds-dtl = recid(buf_gds-dtl)
            t-gds.type = units.type
            t-gds.grc = (if LOOKUP({&twounit}, units.type) > 0 then recid(buf_chk-gds) else ?)
            t-gds.marks = ''
            .
          end.
          if t-gds.pump > 0
          and (t-gds.density = ? or t-gds.density = 0) then do:
            /*исключение чеков из продажи созданной в 14*/
            message substitute("Чек &1 Бар-код &2 ТРК &3&4Не удается определить плотность топлива в танке&4&5&4Чек не будет закачан в продажу"
                            , X_chk-doc.doc-code
                            , t-gds.b-code
                            , t-gds.pump
                            , {&new-line}
                            , return-value
                            )
            view-as alert-box error .
            run waitfram-hide in this-procedure .
            undo, return error.
          end.
        end.
        assign
        t-gds.doc-qnty = t-gds.doc-qnty + buf_chk-gds.doc-qnty
        t-gds.num-lines = t-gds.num-lines + 1
        t-gds.price-base = buf_chk-gds.price-base + buf_chk-gds.price-service
        t-gds.discnt = (if buf_sale-doc.doc-type = {&write-off} then 0 else buf_chk-gds.discnt)
        t-gds.price-sum = t-gds.price-sum + (buf_chk-gds.price-base + buf_chk-gds.price-service ) * buf_chk-gds.doc-qnty
        t-gds.discnt-sum  = t-gds.discnt-sum +
                            (if buf_sale-doc.doc-type = {&write-off}
                            then 0
                            else buf_chk-gds.discnt * buf_chk-gds.doc-qnty)
        t-gds.road-sum = t-gds.road-sum + buf_chk-gds.road-tax * buf_chk-gds.doc-qnty
        .
        run gds-attr-value(
                t-gds.gds-code,
                {&attr-mark},
                output par-alcohol,
                output par-type
          ).
        if par-alcohol = "yes" then do :
            find first chk-gds-attr no-lock where chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                              and chk-gds-attr.line-num = buf_chk-gds.line-num
                                              and chk-gds-attr.attr-code = "mark-code"
                                              no-error .
            if available chk-gds-attr
/*                and not t-gds.marks matches ("*" + chk-gds-attr.attr-value + "*")*/
            then do :
              t-gds.marks = t-gds.marks + (if t-gds.marks = '' then '' else ',') + chk-gds-attr.attr-value .  
            end.  
            release chk-gds-attr no-error .
        end.
      end. /*do gtrg = 1 to num-docs-to*/
    end. /*if docs-to-reserv <> 0*/
    release t-gds.
  END. /*for each buf_chk-gds*/
  for each tt0-info:
    delete tt0-info.
  end.
  /*снятие резервов*/
  f-del:
  DO on ERROR undo, return error
  on STOP undo, return error :
    if docs-to-reserv > 0 then do:
      run waitfram-show in this-procedure ( substitute("Снимаю резервы со всех товаров чека &1...", X_chk-doc.doc-code)).
    _main:
      FOR EACH t-gds NO-LOCK,
          first buf_sale-doc where
               buf_sale-doc.inkas-code = inkas.inkas-code
           and buf_sale-doc.doc-code = t-gds.doc-code,
          first buf_trn-doc where
               buf_trn-doc.doc-code = buf_sale-doc.doc-code
    on ERROR undo f-del, return error
    on STOP undo f-del, return error :
        if t-gds.doc-qnty = 0 then nEXt.
        assign
        buf_sale-doc.gds-amount = buf_sale-doc.gds-amount - t-gds.num-lines.
        /*главный ЦИКЛ*/
        assign
        r-artic =      "":U
        r-prod-type = "":U
        r-prod-code = 0
        r-prt-code = 0
        rdoc-line = t-gds.rdoc-line
        rgds-dtl = t-gds.rgds-dtl
        r-b-code = /*if cashparts then t-gds.b-code else*/ ?
        r-doc-prts-qnty = ?
        r-or-v = buf_sale-doc.doc-kind
        cashparts = t-gds.cashparts
        r-qnty = ?
        cashplace = t-gds.cashplace
        r-pl-code = t-gds.pl-code
        .
        FIND FIRST buf_doc-line WHERE recid(buf_doc-line) = t-gds.rdoc-line No-ERROR.
        run gds-attr-value(
                t-gds.gds-code,
                {&attr-mark},
                output par-alcohol,
                output par-type
            ).
        if t-gds.marks <> '' and par-alcohol = "yes"
        then do :
            find first doc-line-attr exclusive-lock where doc-line-attr.doc-code = buf_doc-line.doc-code
                                                      and doc-line-attr.gds-code = t-gds.gds-code
                                                      and doc-line-attr.attr-code = 'mark-code'
                                                      no-error.
            if available doc-line-attr
            then do :
              do mark-ii = 1 to num-entries(doc-line-attr.attr-value) :
                v-mark = entry(mark-ii, doc-line-attr.attr-value) .
                if not can-do(t-gds.marks, v-mark)
                then v-mark-list = v-mark-list + (if v-mark-list = '' then '' else ',') + v-mark .
              end.
              doc-line-attr.attr-value = v-mark-list .
            end.
        end.
        run  RSRV-line in this-procedure (
                       input buf_sale-doc.dir /*расход или возврат или списание*/
                      ,input no /*p-auto-fbr*/
                      ,input no /*резервирование чужих на своем объекте - толькок во время закрыти расхода*/
                      ,input no /*p-auto-fbr-on*/
                      ,input v-is-tpsi-obj
                      ,input no /*на снятии неважно нужно ли резервировать остатки чужих товаров*/
                      ,input no /*снятие резерв*/
                      ,input t-gds.gds-code
                      ,input t-gds.node-code
                      ,output v-run-tpsi
                      ,buffer buf_doc-line
                      ,buffer buf_trn-doc
                      ,buffer buf_sale-doc
                      ) no-error.
        if error-status:error then do:
          run waitfram-hide in this-procedure .
          undo f-del, return error substitute("Ошибка при снятии резервов товаров чека &1:&2&3 &4"
                                    , X_chk-doc.doc-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
        end. /*error-status*/
        if v-is-tpsi-obj
        and v-run-tpsi
        and buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass}
        then do:
          run str/tpsirsrv.p (
                           input parparentproc
                          ,input this-procedure /*p-parent-handle  */
                          ,input ? /*p-log-handle*/
                          ,input 0 /*p-auto*/
                          ,input v-curr-r-b
                          ,input inkas.inkas-code
                          ,input inkas.host-code
                          ,input inkas.obj-type
                          ,input inkas.obj-code
                          ,input r-artic
                          ,input r-prod-type
                          ,input r-prod-code
                          ,input r-prt-code
                          ,input no
                          /*title окна резервирования*/
                          ,input "Снятие резеров ЧУЖИХ товаров. Расход. Строк " /*p-title*/
                          /*это продолжение счетчика начатого в salersrv.i*/
                          ,input-output num_rec_res
                          /*это счетчик попыток резервирования только ЧУЖИХ ТОВАРОВ*/
                          ,output num_rec_other
                          /*это счетчик УДАЧНЫХ попыток резервирования только ЧУЖИХ ТОВАРОВ*/
                          ,output num_rec_other_res
                          /*здесь только документ расхода продажи  - ведь возварт мы обратно не возвращаем*/
                          ,buffer buf_trn-doc
                        ) no-error .
          if error-status:error then do:
            return error substitute("Ошибка при снятии резервов ЧУЖИХ товаров:&1&2 &3"
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value ).
          end.
          assign
          num_resv = num_resv + num_rec
          num_resv_res = num_resv_res + num_rec_res
          num_rec = 0
          num_rec_res = 0
          .
        end.
      END. /*цикл по снятию резервов с товаров чека*/
      if num_resv > num_resv_res then do:
        run waitfram-hide in this-procedure .
        undo f-del, return error.
      end. /*num_rec >  num_rec_res*/

      run waitfram-show in this-procedure ( substitute("Пересчитываю выручку после исключения чека &1...", X_chk-doc.doc-code)).
      var-doc-type = (if X_chk-doc.netto >= 0 then {&income} else {&expense}).
      FOR  EACH buf_chk-pay WHERE
                buf_chk-pay.doc-code = X_chk-doc.doc-code
      BREAK
      BY buf_chk-pay.doc-code
      BY buf_chk-pay.pay-code
      BY buf_chk-pay.curr-code :
        ACCUMULATE
        buf_chk-pay.tot-sum ( SUB-TOTAL BY buf_chk-pay.curr-code )
        buf_chk-pay.tot-base ( SUB-TOTAL BY buf_chk-pay.curr-code )
        buf_chk-pay.tot-rubl ( SUB-TOTAL BY buf_chk-pay.curr-code )
        .
        find first buf_inkas-pay-wth where
                  buf_inkas-pay-wth.inkas-code = X_chk-doc.out-code
              and buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
              and buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
              and buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
              and buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
              and buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
              and buf_inkas-pay-wth.cashier = X_chk-doc.cashier
              and buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type no-error.
        if not available  buf_inkas-pay-wth then do:
          create buf_inkas-pay-wth.
          assign
          buf_inkas-pay-wth.inkas-code = X_chk-doc.out-code
          buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
          buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
          buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
          buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
          buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
          buf_inkas-pay-wth.cashier = X_chk-doc.cashier
          buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type
          buf_inkas-pay-wth.par-val = buf_chk-pay.par-val
          .
        end.
        assign
        buf_inkas-pay-wth.tot-sum = buf_inkas-pay-wth.tot-sum - buf_chk-pay.tot-sum
        buf_inkas-pay-wth.tot-base = buf_inkas-pay-wth.tot-base - buf_chk-pay.tot-base
        buf_inkas-pay-wth.tot-rubl = buf_inkas-pay-wth.tot-rubl - buf_chk-pay.tot-rubl
        buf_inkas-pay-wth.doc-qnty = buf_inkas-pay-wth.doc-qnty - buf_chk-pay.doc-qnty
        buf_inkas-pay-wth.tot-lines = buf_inkas-pay-wth.tot-lines - 1
        .
        if buf_inkas-pay-wth.tot-sum = 0 then delete buf_inkas-pay-wth.

        if last-of( buf_chk-pay.curr-code ) then  do:
          FIND buf_inkas-pay WHERE
              buf_inkas-pay.inkas-code = X_chk-doc.out-code AND
              buf_inkas-pay.pay-code = buf_chk-pay.pay-code AND
              buf_inkas-pay.curr-code = buf_chk-pay.curr-code NO-ERROR.
          if NOT available buf_inkas-pay then do:
            CREATE buf_inkas-pay.
            assign
            buf_inkas-pay.inkas-code = X_chk-doc.out-code
            buf_inkas-pay.pay-code = buf_chk-pay.pay-code
            buf_inkas-pay.curr-code = buf_chk-pay.curr-code
            buf_inkas-pay.tot-sum = 0
            buf_inkas-pay.tot-base = 0
            buf_inkas-pay.tot-rubl = 0
            .
          end.
          var-doc-type = (if X_chk-doc.netto >= 0 then {&income} else {&expense}).
          FIND FIRST buf_inkas-pay-desk WHERE
                    buf_inkas-pay-desk.inkas-code = X_chk-doc.out-code AND
                    buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code AND
                    buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code AND
                    buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk AND
                    buf_inkas-pay-desk.doc-type = var-doc-type AND
                    buf_inkas-pay-desk.cashier = X_chk-doc.cashier
                    NO-ERROR.
          if NOT available buf_inkas-pay then do:
            CREATE buf_inkas-pay.
            assign
            buf_inkas-pay.inkas-code = X_chk-doc.out-code
            buf_inkas-pay.pay-code = buf_chk-pay.pay-code
            buf_inkas-pay.curr-code = buf_chk-pay.curr-code
            buf_inkas-pay.tot-sum = 0
            buf_inkas-pay.tot-base = 0
            buf_inkas-pay.tot-rubl = 0
            .
          end.
          if NOT available buf_inkas-pay-desk then do:
            CREATE buf_inkas-pay-desk.
            assign
            buf_inkas-pay-desk.inkas-code = X_chk-doc.out-code
            buf_inkas-pay-desk.pay-code = buf_chk-pay.pay-code
            buf_inkas-pay-desk.curr-code = buf_chk-pay.curr-code
            buf_inkas-pay-desk.pay-desk = X_chk-doc.pay-desk
            buf_inkas-pay-desk.cashier = X_chk-doc.cashier
            buf_inkas-pay-desk.tot-sum = 0
            buf_inkas-pay-desk.tot-base = 0
            buf_inkas-pay-desk.tot-rubl = 0
            buf_inkas-pay-desk.doc-type = var-doc-type
            .
          end.
          assign
              buf_inkas-pay.tot-sum = buf_inkas-pay.tot-sum -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-sum )
              buf_inkas-pay.tot-base = buf_inkas-pay.tot-base -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-base )
              buf_inkas-pay.tot-rubl = buf_inkas-pay.tot-rubl -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-rubl )
              buf_inkas-pay-desk.tot-sum = buf_inkas-pay-desk.tot-sum -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-sum )
              buf_inkas-pay-desk.tot-base = buf_inkas-pay-desk.tot-base -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-base )
              buf_inkas-pay-desk.tot-rubl = buf_inkas-pay-desk.tot-rubl -
                  ( ACCUM SUB-TOTAL BY buf_chk-pay.curr-code buf_chk-pay.tot-rubl ) .

          if buf_inkas-pay.tot-sum = 0 then delete buf_inkas-pay.
          if buf_inkas-pay-desk.tot-sum = 0 then delete buf_inkas-pay-desk.
        end.  /*        if last-of( buf_chk-pay.curr-code )*/
      buf_chk-pay.out-code = ? .
    END. /*конец обработки оплат*/
    /*обработка товаров*/
    run waitfram-show in this-procedure ( substitute("Пересчитываю строки накладных после исключения чека &1...", X_chk-doc.doc-code)).
    FOR EACH t-gds ,
        first buf_sale-doc where
              buf_sale-doc.inkas-code = inkas.inkas-code
          and buf_sale-doc.doc-code = t-gds.doc-code,
        FIRST buf_doc-line WHERE
            buf_doc-line.doc-code = t-gds.doc-code
        AND buf_doc-line.artic = t-gds.artic
        AND buf_doc-line.prod-code = t-gds.prod-code
        AND buf_doc-line.prod-type = t-gds.prod-type
    break
    by t-gds.doc-code
    by t-gds.gds-code
    by t-gds.node-code
    by t-gds.b-code
    by t-gds.pl-code
    by t-gds.pump
    by t-gds.fbr-obj-type
    by t-gds.fbr-obj-code
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      if t-gds.cashplace then do:
        FIND FIRST ub.doc-pl WHERE
                  ub.doc-pl.pl-code = t-gds.pl-code
              AND ub.doc-pl.gds-code = t-gds.gds-code
              AND ub.doc-pl.out-code = buf_sale-doc.doc-code NO-ERROR.
        IF avail ub.doc-pl
        then do:
          assign
          ub.doc-pl.fact-qnty = ub.doc-pl.fact-qnty - abs(t-gds.doc-qnty)
          ub.doc-pl.cli-fact-qnty = ub.doc-pl.cli-fact-qnty - t-gds.density * abs(t-gds.doc-qnty)
          .
          if ub.doc-pl.fact-qnty = 0 then delete doc-pl.
          find first ub.doc-pl-pump where
                    ub.doc-pl-pump.pl-code = ub.doc-pl.pl-code
                AND ub.doc-pl-pump.gds-code = ub.doc-pl.gds-code
                AND ub.doc-pl-pump.pump-code = t-gds.pump
                AND ub.doc-pl-pump.out-code = buf_sale-doc.doc-code No-ERROR.
          IF avail ub.doc-pl-pump then do:
              ub.doc-pl-pump.fact-qnty = ub.doc-pl-pump.fact-qnty - abs(t-gds.doc-qnty).
              if ub.doc-pl-pump.fact-qnty = 0 then delete ub.doc-pl-pump.
          end.
        end.
      end.
      else do:
        if t-gds.cashparts then do:
          IF LOOKUP({&twounit}, t-gds.type) > 0 then
          FIND FIRST ub.doc-prts WHERE
                      ub.doc-prts.gds-code = t-gds.gds-code
                 AND  ub.doc-prts.out-code = buf_sale-doc.doc-code
                 AND  ub.doc-prts.fact-qnty = abs(t-gds.doc-qnty) NO-ERROR.
          else
          FIND FIRST ub.doc-prts WHERE
                     ub.doc-prts.b-code = t-gds.b-code
                 AND ub.doc-prts.out-code = buf_sale-doc.doc-code NO-ERROR.

        END.
        IF avail ub.doc-prts
        then do:
          ub.doc-prts.fact-qnty = ub.doc-prts.fact-qnty - abs(t-gds.doc-qnty).
          if ub.doc-prts.fact-qnty = 0 then delete doc-prts.
        end.
      end.
      if NOT (t-gds.fbr-obj-type = "":U
                    and
                    t-gds.fbr-obj-code = 0) then do:
        find first ub.doc-fbr-gds where
                  ub.doc-fbr-gds.fbr-obj-type = t-gds.fbr-obj-type
              AND ub.doc-fbr-gds.fbr-obj-code= t-gds.fbr-obj-code
              AND ub.doc-fbr-gds.gds-code = t-gds.gds-code
              AND ub.doc-fbr-gds.out-code = (if buf_sale-doc.doc-kind = {&TDEDT_VOZVRAT_Vnesh_KASS} then replace(buf_sale-doc.doc-code, "=", "-") else buf_sale-doc.doc-code) NO-ERROR.
        IF avail ub.doc-fbr-gds then do:
          ub.doc-fbr-gds.fact-qnty = ub.doc-fbr-gds.fact-qnty - t-gds.doc-qnty.
          if ub.doc-fbr-gds.fact-qnty = 0 then delete ub.doc-fbr-gds.
        end.
      end.
      FIND FIRST buf_gds-dtl WHERE
                  buf_gds-dtl.doc-code = t-gds.doc-code AND
                  buf_gds-dtl.artic = t-gds.artic AND
                  buf_gds-dtl.prod-code = t-gds.prod-code AND
                  buf_gds-dtl.prod-type = t-gds.prod-type AND
                  buf_gds-dtl.prt-code = t-gds.node-code NO-ERROR.
      /*buf_gds-dtl может отсутствовавть например в случае такого расклада
      Партия 1: 1 шт
      Партия 2: 1 шт
      Партия 2: -2 шт
      после первой строки она сотрется!

      */
      if t-gds.pump > 0 then do:
        define variable v-qnty as decimal no-undo .
        define variable v-cli-qnty as decimal no-undo .
        if available doc-pl then release doc-pl.
        assign
        v-qnty     = 0.0
        v-cli-qnty = 0.0
        .
        for each ub.doc-pl no-lock where
                ub.doc-pl.out-code = t-gds.doc-code
            and ub.doc-pl.gds-code = t-gds.gds-code:
          assign
          v-qnty     = v-qnty + ub.doc-pl.fact-qnty
          v-cli-qnty = v-cli-qnty + ub.doc-pl.cli-fact-qnty
          .
        end.
        assign
        buf_doc-line.fact-density = v-cli-qnty / v-qnty
        buf_doc-line.doc-density = buf_doc-line.fact-density
        .
      end.
      assign
      buf_doc-line.fact-qnty = buf_doc-line.fact-qnty - abs( t-gds.doc-qnty )
      buf_sale-doc.fact-qnty = buf_sale-doc.fact-qnty  -  abs( t-gds.doc-qnty )
      v-real-qnty = v-real-qnty +
                    (if buf_sale-doc.in-inkas
                    then abs( t-gds.doc-qnty ) *
                    (if lookup(buf_sale-doc.ext-doc-type, {&TDEDT_incorrect_sign}) > 0 then - 1 else 1)
                    else 0)
      temp-qnty = buf_gds-dtl.fact-qnty - abs( t-gds.doc-qnty )
      .
      if temp-qnty = 0 then do:
        deleted-g = yes.
        if buf_doc-line.fact-qnty = 0 then deleted-d = yes.
        else deleted-d = no.
      end.
      else assign
      deleted-d = no
      deleted-g = no.
      if prcl-spl then do:
        if available buf_gds-dtl then do:
        for-price = (if p-curr-r-b = {&r-b-base}
                    then buf_gds-dtl.price-base
                    else buf_gds-dtl.price-rubl)
                    .
      end.
      else do:
          for-price = 0.
        end.
      end.
      else do:
        assign
        for-price = t-gds.new-price
        .
      end.

  &scop discnt-r-b (if p-curr-r-b = {&r-b-base} then buf_gds-dtl.discnt-base else buf_gds-dtl.discnt-rubl)
  &scop price-r-b  (if p-curr-r-b = {&r-b-base} then buf_gds-dtl.price-base else buf_gds-dtl.price-rubl)

      if not deleted-g then do:
          /*если после удаления данной строки чека кол-во по признаку не равно 0 то пересчитаем*/

  /*формула Назаркиной*/
        assign
        v-discnt-r-b =
        (
        for-price *( buf_gds-dtl.fact-qnty -  abs(t-gds.doc-qnty) )
        -
        ({&price-r-b} - {&discnt-r-b}) * buf_gds-dtl.fact-qnty
        +
        abs(t-gds.price-sum - t-gds.discnt-sum)
        ) / ( buf_gds-dtl.fact-qnty -  abs(t-gds.doc-qnty ))
        v-price-r-b = for-price
        buf_gds-dtl.fact-qnty = buf_gds-dtl.fact-qnty - abs( t-gds.doc-qnty )
        buf_gds-dtl.price-base = if p-curr-r-b = {&r-b-rubl}
                              then  v-price-r-b / v-base-rate * v-base-scale
                              else v-price-r-b
        buf_gds-dtl.discnt-base = if p-curr-r-b = {&r-b-rubl}
                              then v-discnt-r-b / v-base-rate * v-base-scale
                              else v-discnt-r-b
        buf_gds-dtl.price-rubl = if p-curr-r-b = {&r-b-base}
                              then v-price-r-b * v-base-rate / v-base-scale
                              else v-price-r-b
        buf_gds-dtl.discnt-rubl = if p-curr-r-b = {&r-b-base}
                              then v-discnt-r-b * v-base-rate / v-base-scale
                              else v-discnt-r-b
        buf_doc-line.road-tax = (if buf_doc-line.road-tax > 0 then
                                        (buf_doc-line.road-tax * (buf_doc-line.fact-qnty + abs(t-gds.doc-qnty) ) -
                                        abs(t-gds.road-sum )
                                        ) / (buf_doc-line.fact-qnty )
                                                else 0)
        .
      end.   /*not deleted*/
      if last-of(t-gds.node-code) then do:
        if deleted-g then do:
          if available buf_gds-dtl then do:
          delete buf_gds-dtl no-error.
          if error-status:error then undo f-del, return error.
          buf_sale-doc.tot-dtl = buf_sale-doc.tot-dtl - 1.
        end.
        end.
      end. /*last-of t-gds.b-code*/
      if last-of(t-gds.gds-code) then do:
        if deleted-d then do:
          delete buf_doc-line no-error.
          if error-status:error then undo f-del, return error.
          buf_sale-doc.tot-lines = buf_sale-doc.tot-lines - 1.
        end.
      end.
    END. /*for each t-gds*/
  end. /*if doc-to-reserv > 0*/
  else do:
    FOR  EACH buf_chk-pay WHERE
              buf_chk-pay.doc-code = X_chk-doc.doc-code:
      buf_chk-pay.out-code = ? .
    end.
  end.
  run waitfram-show in this-procedure ( substitute("Освобождаю чек &1...", X_chk-doc.doc-code)).
  FOR EACH buf_chk-gds where buf_chk-gds.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
      assign
      buf_chk-gds.out-code = ?
      buf_chk-gds.line-type = entry(1, buf_chk-gds.line-type, {&delim-par})
     .
  END.
  FOR EACH buf_chk-discnt where buf_chk-discnt.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
      buf_chk-discnt.out-code = ?.
  END.
  FOR EACH buf_chk-doc-attr where buf_chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
      buf_chk-doc-attr.out-code = ?.
  END.
  FOR EACH buf_chk-gds-pay where buf_chk-gds-pay.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
     delete buf_chk-gds-pay.
  END.
  /*история*/
  for each buf_c-chk-doc where
          buf_c-chk-doc.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1) :
    assign
    buf_c-chk-doc.out-code = ?
    .
  end.
  for each buf_c-chk-gds where
          buf_c-chk-gds.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1) :
    assign
    buf_c-chk-gds.out-code = ?
    .
  end.
  for each buf_c-chk-discnt where
          buf_c-chk-discnt.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1) :
    assign
    buf_c-chk-discnt.out-code = ?
    .
  end.
  for each buf_c-chk-pay where
          buf_c-chk-pay.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1)
          :
    assign
    buf_c-chk-pay.out-code = ?
    .
  end.
  for each buf_c-chk-doc-attr where
          buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
          :
    assign
    buf_c-chk-doc-attr.out-code = ?
    .
  end.
  run waitfram-show in this-procedure ( substitute("Пересчитываю общие суммы по накладным после исключения чека &1...", X_chk-doc.doc-code)).
  assign
  inkas.tot-doc = inkas.tot-doc - (if docs-to-reserv > 0 then X_chk-doc.tot-doc else 0)
  inkas.discnt = inkas.discnt  -  (if docs-to-reserv > 0 then  X_chk-doc.discnt else 0)
  inkas.netto = inkas.netto -  (if docs-to-reserv > 0 then X_chk-doc.netto else 0)
  inkas.sub-discnt = inkas.sub-discnt -  X_chk-doc.sub-discnt
  inkas.num-chk = inkas.num-chk  - 1
  inkas.num-chk-nf = inkas.num-chk-nf - (if docs-to-reserv > 0 then 0 else 1)
  inkas.qnty = inkas.qnty -  v-real-qnty
  chk-amount = chk-amount - 1
  nf-chk-amount = nf-chk-amount - add-nf-amount
  .
  assign
  dtl-out = 0
  line-out = 0
  dtl-ret = 0
  line-ret = 0
  .
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = inkas.inkas-code,
      first dop_trn-doc where dop_trn-doc.doc-code = buf_sale-doc.doc-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
    if buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_KASS} then do:
      assign
      dtl-out = dtl-out + buf_sale-doc.tot-dtl
      line-out = line-out + buf_sale-doc.tot-lines
      .
    end.
    if buf_sale-doc.doc-kind = {&TDEDT_VOZVRAT_Vnesh_KASS} then do:
      assign
      dtl-ret = dtl-ret + buf_sale-doc.tot-dtl
      line-ret = line-ret + buf_sale-doc.tot-lines
      .
    end.
    assign
    dop_trn-doc.fact-qnty = buf_sale-doc.fact-qnty
    dop_trn-doc.tot-lines = buf_sale-doc.tot-lines
    buf_sale-doc.filled = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0
    .
    dop_trn-doc.ps = set-sale-doc-ps(buffer buf_sale-doc)
    .
    if not buf_sale-doc.filled
    and buf_sale-doc.doc-kind <> {&TDEDT_Ras_Vnesh_Kass} then do:
      if buf_sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
        assign
        buf0_trn-doc.out-code = '':U.
      end.
      delete dop_trn-doc.
      delete buf_sale-doc.
    end.
  end.
  /*колв-о чеков и строк чеков считается ВМЕСТЕ С petrol!*/
  assign
  inkas.PS = set-inkas-ps(input inkas.ps
                        , input chk-amount
                        , input gds-amount
                        , input line-out
                        , input dtl-out
                        , input line-ret
                        , input dtl-ret
                        , input nf-chk-amount
                        , input nf-gds-amount
                        , input p-filter-rus
                        )
  inkas.num-chk-nff = nff-chk-amount
  .
  X_chk-doc.out-code = ? .
  run waitfram-hide in this-procedure .
END. /*DO TRANSACTION*/
end.