block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: salevzak.p $
$Archive: str/salevzak.p $

ОТЧЕТ ПО ЗАРЕЗЕРВИРОВАННЫМ ПАРТИЯМ ПРОДАЖИ ПО ВАРИАНТАМ ЗАКУПКИ
по незакрытой и по закрытой продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/20/03
Author: Bakhtadze Natalya
Creation date: 11/20/03

*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-mode         as character no-undo . /*print or export or work*/
define output parameter p-frame-width as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salevzak.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salevzak.p $":U .
define variable vss-description as character no-undo init "ОТЧЕТ ПО ЗАРЕЗЕРВИРОВАННЫМ ПАРТИЯМ ПРОДАЖИ ПО ВАРИАНТАМ ЗАКУПКИ".

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }

define variable v-curr-r-b as character no-undo .
define variable v-r-b-abbr as character no-undo .
define variable var-sale-sum      as decimal no-undo .
define variable v-z-number like ub.chk-doc.z-number no-undo .
define variable v-pay-desk like ub.chk-doc.pay-desk no-undo .
define variable v-rec-list as character no-undo .
define variable v-density as decimal no-undo.


define buffer buf_inkas for ub.inkas .
define buffer buf_shop for ub.shop.
define buffer buf_clients for ub.clients.
define buffer buf_trn-doc for ub.trn-doc.

{ cmp/salevzak.i "NEW SHARED" }
{ rep/real3tmp.i repzak }
{ rep/realg3df.i "NEW SHARED" treal-3 repzak }
{ rep/realg3cr.i treal-3 repzak }

main-block:
do
on error undo, return error
:
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if p-mode = "work" then do:
    do transaction
    on error undo main-block, return error
    :
      find first buf_inkas exclusive-lock where
                  buf_inkas.inkas-code = p-inkas-code no-wait no-error .
      IF NOT AVAILABLE buf_inkas
      AND NOT LOCKED buf_inkas THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Неправильный выбор кассового отчета."
        view-as alert-box WARNING .
        UNDO main-block, RETURN ERROR.
      END.
      IF LOCKED buf_inkas THEN DO:
          MESSAGE
          SUBSTITUTE("В настоящее время занята запись ОТЧЕТА ПРОДАЖИ &1"
                    , p-inkas-code
                    )
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
      END.
    end.
  end.
  else do:
    find first buf_inkas no-lock where
                buf_inkas.inkas-code = p-inkas-code no-error .
    if NOT available buf_inkas then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильный выбор кассового отчета."
      view-as alert-box WARNING .
      return error .
    end.
  end.
  { gbl/r-b-abbr.i
   buf_inkas.host-code
   v-r-b-abbr }
  find first buf_shop no-lock where
            buf_shop.obj-code = buf_inkas.obj-code no-error .
  if not available buf_shop then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден объекта для кассового отчета." p-inkas-code
    view-as alert-box WARNING .
    return error .
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = {&shop}
        AND buf_clients.obj-code = buf_shop.obj-code no-error .
  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_inkas.inkas-code.

  /*проверим что все товары  ПО РАСХОДУ зарезервированы*/
  IF  can-find (first ub.gds-dtl no-lock where
                        ub.gds-dtl.doc-code = buf_trn-doc.doc-code
                    AND ub.gds-dtl.doc-qnty <> ub.gds-dtl.fact-qnty USE-INDEX pi)

  then do:
    message
    "Не все товары в расходной части продажи зарезервированы" skip
    "Печать отчета невозможна"
    view-as alert-box ERROR.
    return .
  end.
  run cre-sj in this-procedure (
                                 input v-curr-r-b
                               , buf_inkas.inkas-code
                               , input 0
                               , input "":U  /*p-artic*/
                               , input "":U  /*pprod-type*/
                               , input 0     /*pprod-code*/
                               , input ?     /*p-is-out*/
                               , input ?    /*p-doc-line-rec*/
                               /*для всех doc-lin*/  ).
  run process-inkas in this-procedure (buffer buf_inkas, (if p-mode <> "export" then yes else no), output v-z-number, output v-pay-desk).
  CASE p-mode:
    when  "print" then do:
      run process-two-tables in this-procedure (0, ?) /*все*/ .
      run proc-print in this-procedure .
    end.
    when "work" then do:
      run process-two-tables in this-procedure (0, ?).
      run str/salevzaw.w (
                       input parparentproc
                      ,buffer buf_inkas
                      ,input this-procedure
                      ,input (if buf_Inkas.status_ <> {&fact} then {&update} else {&lookup}) /*p-mode*/
                      ,input "":U /*bttn*/
                      ,input-output v-rec-list
                      ) no-error .
    end.
    when  "export" then do:
      run proc-export in this-procedure(buffer buf_inkas, input v-z-number, input v-pay-desk) .
    end.
  END CASE.
end. /*doe*/

procedure cre-sj :
define input parameter p-curr-r-b as character no-undo .
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-gds-code   like ub.goods.gds-code no-undo.
define input parameter p-artic      like ub.goods.artic no-undo.
define input parameter p-prod-type  like ub.goods.prod-type no-undo.
define input parameter p-prod-code  like ub.goods.prod-code no-undo.
define input parameter p-is-out     as logical              no-undo .
define input parameter p-doc-line-rec as recid no-undo.


define variable v-b-code like ub.bar-code.b-code no-undo .
define variable v-price-sale      like ub.price-list.price-sale no-undo.
define variable v-price-sale-calc like ub.price-list.price-sale no-undo.
define variable v-price-base      like ub.price-list.price-sale no-undo.
define variable v-price-rubl      like ub.price-list.price-sale no-undo.
define variable v-price-flag       as logical no-undo .
define variable sale_sum_r-b     as decimal no-undo .
define variable v-price-netto    as decimal no-undo .
define variable my-accum          as integer no-undo .
define variable v-var-purch       as integer no-undo .
define variable v-is-out          as logical no-undo .

define buffer buf_trn for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_parts for ub.parts.
define buffer buf_goods for ub.goods.
define buffer buf_sj-goods for sj-goods.
define buffer sj-goods0 for sj-goods.
define buffer sj-goods00 for sj-goods.
define buffer sj-goods01v for sj-goods.
define buffer sj-goods02v for sj-goods.
define buffer sj-goods01r for sj-goods.
define buffer sj-goods02r for sj-goods.

define buffer buf_clients for ub.clients.
&scop sign (if v-is-out then 1 else - 1)

  do
  on error undo, return error
  :
    find first buf_trn no-lock where
              buf_trn.doc-code = p-inkas-code no-error .
    if not available buf_trn then do:
      undo, return error substitute("Не найдена расходная часть для кассового отчета &1", p-inkas-code).
    end.
    if p-gds-code = 0 then do:
      for each sj-goods:
        delete sj-goods.
      end.
      create sj-goods00.
      assign
      sj-goods00.gds-code = 0
      sj-goods00.var-purch = 0
      sj-goods00.prod-type = "":U
      sj-goods00.prod-code = 0
      sj-goods00.artic     = "":U
      sj-goods00.gds-name = "ИТОГО по всем вариантам закупки"
      sj-goods00.is-out  = ?
      .

      create sj-goods01r.
      assign
      sj-goods01r.gds-code = 0
      sj-goods01r.var-purch = 1
      sj-goods01r.prod-type = "":U
      sj-goods01r.prod-code = 0
      sj-goods01r.artic     = "":U
      sj-goods01r.is-out    = yes
      sj-goods01r.gds-name = "Итого по варианту закупки 1"
      sj-goods01r.prod-name = "по расходам"
      .
      create sj-goods01v.
      assign
      sj-goods01v.gds-code = 0
      sj-goods01v.var-purch = 1
      sj-goods01v.prod-type = "":U
      sj-goods01v.prod-code = 0
      sj-goods01v.artic     = "":U
      sj-goods01v.is-out    = no
      sj-goods01v.gds-name = "Итого по варианту закупки 1"
      sj-goods01v.prod-name = "по возвратам"
      .
      create sj-goods02r.
      assign
      sj-goods02r.gds-code = 0
      sj-goods02r.var-purch = 2
      sj-goods02r.prod-type = "":U
      sj-goods02r.prod-code = 0
      sj-goods02r.artic     = "":U
      sj-goods02r.is-out    = yes
      sj-goods02r.gds-name = "Итого по варианту закупки 2"
      sj-goods02r.prod-name = "по расходам"
      .
      create sj-goods02v.
      assign
      sj-goods02v.gds-code = 0
      sj-goods02v.var-purch = 2
      sj-goods02v.prod-type = "":U
      sj-goods02v.prod-code = 0
      sj-goods02v.artic     = "":U
      sj-goods02v.is-out    = no
      sj-goods02v.gds-name = "Итого по варианту закупки 2"
      sj-goods02v.prod-name = "по возвратам"
      .
    end.
    else do:
      find first sj-goods00 where
              sj-goods00.gds-code = 0
          AND sj-goods00.var-purch = 0
          AND sj-goods00.is-out  = ?
          AND sj-goods00.supp-type = "":U
          AND sj-goods00.supp-code = 0
      .

      find  first sj-goods01r where
              sj-goods01r.gds-code = 0
          AND sj-goods01r.var-purch = 1
          AND sj-goods01r.is-out    = yes
          AND sj-goods01r.supp-type = "":U
          AND sj-goods01r.supp-code = 0
      .

      find first sj-goods01v where
              sj-goods01v.gds-code = 0
          AND sj-goods01v.var-purch = 1
          AND sj-goods01v.supp-type = "":U
          AND sj-goods01v.supp-code = 0
          AND sj-goods01v.is-out    = no
              .

      find first sj-goods02r where
              sj-goods02r.gds-code = 0
         AND  sj-goods02r.var-purch = 2
         AND  sj-goods02r.supp-type = "":U
         AND  sj-goods02r.supp-code = 0
         AND  sj-goods02r.is-out    = yes
      .

      find first sj-goods02v where
              sj-goods02v.gds-code = 0
         AND  sj-goods02v.var-purch = 2
         AND  sj-goods02v.supp-type = "":U
         AND  sj-goods02v.supp-code = 0
         AND  sj-goods02v.is-out    = no
              .

      for each buf_sj-goods where
             buf_sj-goods.gds-code = p-gds-code
         AND buf_sj-goods.is-out   = p-is-out:
       for each sj-goods no-lock where
               sj-goods.gds-code = 0
           and (sj-goods.is-out = ? or sj-goods.is-out = p-is-out )
           and (sj-goods.var-purch = 0 or sj-goods.var-purch = buf_sj-goods.var-purch)
           :
         assign
         sj-goods.qnty = sj-goods.qnty - buf_sj-goods.qnty
         sj-goods.sale-sum = sj-goods.sale-sum - buf_sj-goods.sale-sum
         sj-goods.rest-qnty = sj-goods.rest-qnty
         .
       end.
       delete buf_sj-goods.
      end.
      for each treal-3 where
              treal-3.gds-code = p-gds-code
         AND  treal-3.gds-code = p-gds-code
         AND treal-3.is-out = p-is-out:
         assign
         treal-3.rest-qnty = treal-3.qnty1
         .
      end.
    end.

    run waitfram-show in this-procedure ("Ждите..." ).
    for each buf_doc-line no-lock where
             (p-doc-line-rec = ? and
             (buf_doc-line.doc-code = buf_trn.doc-code
             or
             buf_doc-line.doc-code = buf_trn.out-code))
             or recid(buf_doc-line) = p-doc-line-rec
             :
      assign
      v-is-out = (buf_doc-line.doc-code = buf_trn-doc.doc-code).
      find first buf_goods no-lock where
                buf_goods.artic = buf_doc-line.artic
            AND buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code no-error .
      if not available buf_goods then do:
      end.
      find first buf_clients no-lock where
                buf_Clients.obj-type = buf_doc-line.prod-type
            AND buf_Clients.obj-code = buf_doc-line.prod-code no-error .
      if not available buf_clients then do:
      end.

      my-accum = my-accum + 1.
      IF my-accum MODULO 50  = 0 then do:
          run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " строк накладных ").
      end.
      assign
      sale_sum_r-b  = 0
      v-price-flag  = ?
      .
      FOR EACH buf_gds-dtl No-LOCK WHERE
              buf_gds-dtl.doc-code = buf_doc-line.doc-code AND
              buf_gds-dtl.artic = buf_doc-line.artic AND
              buf_gds-dtl.prod-type = buf_doc-line.prod-type AND
              buf_gds-dtl.prod-code = buf_doc-line.prod-code:
        assign
        v-price-netto =  (If p-curr-r-b = {&r-b-rubl}
                          then (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
                          else (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
                          )

        v-price-flag  = (if v-price-flag = ? or v-price-flag = yes
                         then (v-price-flag = ?
                              or
                              (v-price-sale = v-price-netto)
                              )
                         else v-price-flag)
        v-price-sale   = (if v-price-flag = yes or v-price-flag = yes
                         then v-price-netto
                         else v-price-sale)
        sale_sum_r-b = sale_sum_r-b + {&sign} * v-price-netto * buf_gds-dtl.fact-qnty
        .
      END.
      assign
      v-price-sale-calc  = sale_sum_r-b / buf_doc-line.fact-qnty
      .
      assign
      sj-goods00.sale-sum  = sj-goods00.sale-sum  + sale_sum_r-b
      sj-goods00.qnty      = sj-goods00.qnty + {&sign} * buf_Doc-line.fact-qnty
      sj-goods00.rest-qnty = sj-goods00.qnty
      .
      /*
      create sj-goods0.
      assign
      sj-goods0.gds-code = buf_goods.gds-code
      sj-goods0.gds-name = buf_goods.gds-name
      sj-goods0.var-purch = 0
      sj-goods0.prod-type = buf_doc-line.prod-type
      sj-goods0.prod-code = buf_doc-line.prod-code
      sj-goods0.prod-name = buf_clients.obj-name
      sj-goods0.artic     = buf_doc-line.artic
      sj-goods0.sale-sum  = sale_sum_r-b
      sj-goods0.qnty          = buf_Doc-line.fact-qnty
      sj-goods0.price-flag    = v-price-flag
      sj-goods0.price-sale = (if v-price-flag
                              then v-price-sale
                              else ?)
      .
      */

      FOR EACH buf_parts NO-LOCK WHERE
              buf_parts.artic = buf_doc-line.artic AND
              buf_parts.prod-type = buf_doc-line.prod-type AND
              buf_parts.prod-code = buf_doc-line.prod-code AND
              buf_parts.out-code = buf_doc-line.doc-code AND
              buf_parts.obj-type = buf_doc-line.obj-type AND
              buf_parts.obj-code = buf_doc-line.obj-code:
        CASE buf_parts.purch-code:
          when integer({&old-consignation-code}) then do:
            assign
            v-var-purch = 2.
            find first sj-goods where
                      sj-goods.gds-code = buf_goods.gds-code
                  AND sj-goods.is-out   = v-is-out
                  AND sj-goods.var-purch = 2
                  and sj-goods.supp-type = buf_parts.supp-type
                  and sj-goods.supp-code = buf_parts.supp-code  no-error.
          end.
          otherwise do:
            assign
            v-var-purch = 1.
            find first sj-goods where
                      sj-goods.gds-code = buf_goods.gds-code
                  AND sj-goods.is-out   =  v-is-out
                  AND sj-goods.var-purch = 1
                  and sj-goods.supp-type = buf_parts.supp-type
                  and sj-goods.supp-code = buf_parts.supp-code  no-error.
          end.
        END CASE.
        if not available sj-goods then do:
          create sj-goods.
          assign
          sj-goods.gds-code = buf_goods.gds-code
          sj-goods.is-out   = v-is-out
          sj-goods.gds-name = buf_goods.gds-name
          sj-goods.prod-name = buf_clients.obj-name
          sj-goods.var-purch = v-var-purch
          sj-goods.prod-type = buf_doc-line.prod-type
          sj-goods.prod-code = buf_doc-line.prod-code
          sj-goods.artic     = buf_doc-line.artic
          sj-goods.price-flag    = not v-price-flag
          sj-goods.price-sale = (if v-price-flag
                                 then v-price-sale
                                 else ?)
          sj-goods.supp-type = (if sj-goods.supp-type = "":U
                                then buf_parts.supp-type
                                else sj-goods.supp-type)
          sj-goods.supp-code = (if sj-goods.supp-code = 0
                                then buf_parts.supp-code
                                else sj-goods.supp-code)
          sj-goods.supp-flag = (if sj-goods.supp-flag = yes
                                then (sj-goods.supp-type = buf_parts.supp-type
                                      and
                                      sj-goods.supp-code = buf_parts.supp-code)
                                else sj-goods.supp-flag)
          .
        end.
        assign
        sj-goods.qnty          = sj-goods.qnty + {&sign} * buf_parts.qnty
        sj-goods.rest-qnty     = sj-goods.qnty
        sj-goods.sale-sum      = sale_sum_r-b / buf_doc-line.fact-qnty * abs(sj-goods.qnty)
        .
        if v-is-out then do:
          if v-var-purch = 1 then do:
            assign
            sj-goods01r.sale-sum = sj-goods01r.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods01r.qnty     = sj-goods01r.qnty + {&sign} * buf_parts.qnty
            .
          end.
          else do:
            assign
            sj-goods02r.sale-sum = sj-goods02r.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods02r.qnty     = sj-goods02r.qnty + {&sign} * buf_parts.qnty
            .
          end.
        end.
        else do:
          if v-var-purch = 1 then do:
            assign
            sj-goods01v.sale-sum = sj-goods01v.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods01v.qnty     = sj-goods01v.qnty + {&sign} * buf_parts.qnty
            .
          end.
          else do:
            assign
            sj-goods02v.sale-sum = sj-goods02v.sale-sum  +
                                   sale_sum_r-b / buf_doc-line.fact-qnty * buf_parts.qnty
            sj-goods02v.qnty     = sj-goods02v.qnty + {&sign} * buf_parts.qnty
            .
          end.
        end.
      end. /*for each buf_parts*/
    end. /*for each buf_doc-line*/
    release sj-goods00.
    run waitfram-hide in this-procedure .
  end.

end procedure. /* cre-sj */

procedure process-inkas :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-without-src-code as logical no-undo .
define output parameter p-z-number   like ub.chk-doc.z-number no-undo .
define output parameter p-pay-desk  like ub.chk-doc.pay-desk no-undo .

define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .

define variable p-by-pay-desk as logical no-undo .
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-one-curr-code as logical no-undo .
define variable v-flag as logical no-undo .

define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_goods   for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define variable v-ret-doc-code like ub.trn-doc.doc-code no-undo .

{ rep/r-paychk.i defvar repzak }


do
on error undo, return error
:

{ gbl/curr-r-b.i
  v-curr-r-b
}


  { gbl/basecode.i buf_inkas.host-code v-base-code }
  if v-curr-r-b = {&r-b-base} or
  v-base-code = 0 then pychk_NO-exch = yes.
  else pychk_No-exch = no.
  if v-curr-r-b = {&r-b-rubl} or
  v-base-code = 0 then pychk_NO-exch-rubl = yes.
  else pychk_No-exch-rubl = no.
  assign
  v-curr-code = (if v-curr-code = ? then v-base-code else v-curr-code)
  v-one-curr-code = (if v-base-code = v-curr-code then yes else no)
  .
  pychk_without-src-code = p-without-src-code.
  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_inkas.inkas-code .
  find first buf_ret-doc no-lock where
            buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
  if available buf_ret-doc then
  assign
  v-ret-doc-code = buf_ret-doc.doc-code
  .

  assign
  pychk_sheet3 = yes /*товары - все пишем в товары не различая еще на топливо и услуги*/
  .
  for each treal-3:
    delete treal-3.
  end.
  v-flag = ?.

  for each temp-chk-gds:
    delete temp-chk-gds.
  end.

    _chk-doc:
  FOR EACH ub.chk-doc No-LOCK WHERE
          ub.chk-doc.obj-type = buf_inkas.obj-type AND
          ub.chk-doc.obj-code = buf_inkas.obj-code AND
          ub.chk-doc.out-code = buf_inkas.inkas-code,
    EACH ub.chk-pay NO-LOCK WHERE
            ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY CHK-pay.DOC-CODE
      BY CHK-pay.LINE-NUM:
    if v-flag = ? then do:
      assign
      p-z-number  = chk-doc.z-number
      p-pay-desk = chk-doc.pay-desk
      v-flag = no
      .
    end.
    if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
    if (chk-doc.z-number <> p-z-number
    or chk-doc.pay-desk <> p-pay-desk)
    and not v-flag
    then do:
      message
      substitute("В Вашей продаже &1 обнаружены чеки по разным Z-отчетам или разным кассам", buf_inkas.inkas-code) skip
      "ЭКСПОРТ БУДЕТ НЕПРАВИЛЬНЫМ" SKIP
      "Продолжать формирование экспорта?"
      view-as alert-box question buttons yes-no update v-flag.
      if not v-flag then  return error .
    end.

    { rep/r-paychk.i repzak }
  END.
end.

end procedure. /* process-inkas */


procedure process-two-tables :
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-is-out   as logical no-undo .

define variable v-is-out-int     as integer no-undo .

&scop sign (if sj-goods.is-out then 1 else (- 1)) *
&scop create-item ~
      create sj-print.                                                 ~
      buffer-copy sj-goods                                             ~
      except sj-goods.qnty                                             ~
      to sj-print                                                      ~
      assign                                                           ~
      sj-print.qnty = ~{&sign~} min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty))       ~
      sj-print.is-cash = treal-3.is-pay                                ~
      sj-print.sale-sum = (if sj-print.qnty = sj-goods.qnty            ~
                           then sj-goods.sale-sum                      ~
                           else (if sj-goods.price-flag               ~
                                  then sj-goods.price-sale             ~
                                  else sj-goods.sale-sum / sj-goods.qnty) * sj-print.qnty  ~
                          )

  do
  on error undo, return error
  :

  run waitfram-show in this-procedure ("Ждите...").
  v-is-out-int = (if p-is-out then 1 else - 1).
  if p-gds-code = 0 then do:
    for each sj-print:
      delete sj-print.
    end.
  end.
  else do:
    for each sj-print where
          sj-print.gds-code = p-gds-code
      AND sj-print.is-out = p-is-out :
      delete sj-print.
    end.
  end.
  _cycle:
  for each sj-goods where
          sj-goods.gds-code > 0
       AND (p-gds-code = 0 or sj-goods.gds-code = p-gds-code)
       and (p-is-out = ? or sj-goods.is-out = p-is-out)
       and sj-goods.var-purch > 0,
  each treal-3 where
      treal-3.is-out   = sj-goods.is-out
  AND treal-3.gds-code = sj-goods.gds-code
  break
  by sj-goods.is-out
  by sj-goods.gds-code
  by sj-goods.var-purch
  by sj-goods.sale-sum descending
  by treal-3.is-out
  by treal-3.gds-code
  by treal-3.is-pay descending:
    if sj-goods.rest-qnty = 0
    or treal-3.rest-qnty = 0 then NEXT _cycle.
    if sj-goods.rest-qnty = treal-3.rest-qnty then do:

      {&create-item}.
      assign
      treal-3.rest-qnty = 0
      sj-goods.rest-qnty = 0
      .
      /*delete sj-goods.
      delete treal-3.*/
      next _cycle.
    end.
    if abs(sj-goods.rest-qnty) < abs(treal-3.rest-qnty) then do:
      {&create-item}.
      assign
      treal-3.rest-qnty = {&sign} (abs(treal-3.rest-qnty) - abs(sj-goods.rest-qnty))
      sj-goods.rest-qnty = 0
      .
      /*delete sj-goods.*/
      next _cycle.
    end.
    if abs(sj-goods.rest-qnty) > abs(treal-3.rest-qnty) then do:
      {&create-item}.
      assign
      sj-goods.rest-qnty = {&sign} (abs(sj-goods.rest-qnty) - abs(treal-3.rest-qnty))
      treal-3.rest-qnty = 0
      .
      /*delete treal-3.*/
      next _cycle.
    end.
  end.
  run waitfram-hide in this-procedure .
  /*
  output to sj-goods.txt.
  for each sj-goods:
    export sj-goods.
  end.
  output close.
  output to treal-3.txt.
  for each treal-3:
    export treal-3.
  end.
  output close.
  output to sj-print.txt.
  for each sj-print:
    export sj-print.
  end.
  output close.
  */

  end.

end procedure. /* process-two-tables */

procedure proc-print :
define variable v-supp as character no-undo .
define variable v-supp-name as character no-undo .
define variable date_string as character no-undo.
define variable v-header-base-curr as character no-undo .
DEFINE VARIABLE Line                as character                    no-undo .
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo .
define variable g#log as logical no-undo .
define variable v-is-out-border as logical no-undo .
define variable v-is-out-border-2 as logical no-undo .

define buffer sj-goods00 for sj-goods.

DEFINE FRAME Purch-frame
sj-print.gds-code     column-label "Код товара"
sj-print.gds-name     column-label "Название товара" format "X(30)"
sj-print.price-sale   column-label "Цена нетто"
sj-print.price-flag   column-label "При!вед"            format "+/"
sj-print.is-cash      column-label "Нал"                format "+/"
sj-print.qnty         column-label "Количество"
sj-print.sale-sum     column-label "Сумма нетто"
sj-print.artic        column-label "Артикул"
sj-print.prod-name    column-label "Производитель"   format "X(30)"
v-supp                column-label "Поставщик"       format "X(12)"
v-supp-name           column-label "Поставщик-название" format "X(30)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

&scop underline-FRAME ~
  UNDERLINE stream PrnLibStream  ~
  sj-print.gds-code              ~
  sj-print.artic                 ~
  sj-print.gds-name              ~
  sj-print.prod-name             ~
  v-supp                         ~
  v-supp-name                    ~
  sj-print.price-sale            ~
  sj-print.qnty                  ~
  sj-print.sale-sum              ~
  with frame Purch-Frame

&SCOP DISPLAY-TOTALS                                      ~
      display stream PrnLibStream                         ~
      sj-goods.gds-name  @ sj-print.gds-name              ~
      sj-goods.prod-name @ sj-print.prod-name             ~
      sj-goods.qnty      @ sj-print.qnty                  ~
      sj-goods.sale-sum  @ sj-print.sale-sum              ~
      with frame Purch-Frame.                             ~
      DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame


  do
  on error undo, return error
  :
  date_string = cur-time-print() .
  if v-curr-r-b = {&r-b-base} then do:
    assign
    v-header-base-curr = string( "( Б.Вал. - " + caps( v-r-b-abbr ) + " )" )
    .
  end.
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
  PUT  STREAM PrnLibStream
  SPACE(25) ( substitute("Отчет по зарезервированным партиям продажи &1 по вариантам закупки", buf_inkas.inkas-code) )
  format "x(90)" SKIP(2) .
  Line = fill("-", 198).
  FORM HEADER
  string(Line, "X(198)") AT 1 SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW  STREAM PrnLibStream FRAME BottomFrame .

  FORM with FRAME Purch-frame .

  run waitfram-show in this-procedure ("Ждите...").
  find first sj-goods00 no-lock where
            sj-goods00.gds-code = 0
         and sj-goods00.var-purch = 0 .

  display stream PrnLibStream
  "Вариант закупки 1" @ sj-print.qnty
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  assign
  v-is-out-border = yes
  v-is-out-border-2 = yes
  .
  for each sj-print no-lock where
         sj-print.gds-code > 0
     and sj-print.var-purch = 1
  break
  by sj-print.is-out descending
  by sj-print.var-purch
  by sj-print.sale-sum descending
   :
    if first-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        display stream PrnLibStream
        "РАСХОД" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
      else do:
        display stream PrnLibStream
        "ВОЗВРАТ" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = sj-print.supp-type
          AND buf_clients.obj-code = sj-print.supp-code no-error .
    Display STREAM PrnLibStream
    sj-print.gds-code
    sj-print.artic
    sj-print.gds-name
    sj-print.prod-name
    (sj-print.supp-type + string(sj-print.supp-code)) @ v-supp
    (if available buf_clients then buf_clients.obj-name else "":U) @ v-supp-name
    (if sj-print.price-flag
    then sj-print.price-sale
    else sj-print.sale-sum / sj-print.qnty) @ sj-print.price-sale
    sj-print.price-flag @ sj-print.price-flag
    sj-print.is-cash
    sj-print.qnty
    sj-print.sale-sum
    with FRAME Purch-Frame .
    DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
    if last-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              and sj-goods.is-out   =  yes
              and sj-goods.var-purch = 1 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        {&underline-FRAME}.
        {&DISPLAY-TOTALS}.
        {&underline-FRAME}.
      end.
      if not sj-print.is-out then do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              AND SJ-GOODS.IS-OUT  = NO
              and sj-goods.var-purch = 1 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        {&underline-FRAME}.
        {&DISPLAY-TOTALS}.
        {&underline-FRAME}.
      end.
    end.
  END.
  display stream PrnLibStream
  "Итого по варианту закупки 1 в %" @ sj-print.gds-name
  string(var-sale-sum / sj-goods00.sale-sum * 100, "->>9.999%") @ sj-print.sale-sum
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  assign
  var-sale-sum = 0
  .
  put stream PrnLibStream unformatted string(Line, "X(198)") skip.
  display stream PrnLibStream
  "Вариант закупки 2" @ sj-print.qnty
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  for each sj-print no-lock where
         sj-print.gds-code > 0
     and sj-print.var-purch = 2
  break
  by sj-print.is-out descending
  by sj-print.var-purch
  by sj-print.sale-sum descending
  :
    if first-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        display stream PrnLibStream
        "РАСХОД" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
      else do:
        display stream PrnLibStream
        "ВОЗВРАТ" @ sj-print.qnty
        with frame Purch-Frame.
        DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
      end.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = sj-print.supp-type
          AND buf_clients.obj-code = sj-print.supp-code no-error .
    Display STREAM PrnLibStream
    sj-print.gds-code
    sj-print.artic
    sj-print.gds-name
    sj-print.prod-name
    (sj-print.supp-type + string(sj-print.supp-code)) @ v-supp
    (if available buf_clients then buf_clients.obj-name else "":U) @ v-supp-name
    (if not sj-print.price-flag
    then sj-print.price-sale
    else sj-print.sale-sum / sj-print.qnty) @ sj-print.price-sale
    sj-print.price-flag @ sj-print.price-flag
    sj-print.is-cash
    sj-print.qnty
    sj-print.sale-sum
    with FRAME Purch-Frame .
    DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
    if last-of(sj-print.is-out) then do:
      if sj-print.is-out then do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              and sj-goods.is-out   =  yes
              and sj-goods.var-purch = 2 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        {&underline-FRAME}.
        {&DISPLAY-TOTALS}.
        {&underline-FRAME}.
      end.
      else do:
        find first sj-goods no-lock where
                  sj-goods.gds-code = 0
              and sj-goods.is-out = no
              and sj-goods.var-purch = 2 .
        assign
        var-sale-sum = var-sale-sum + sj-goods.sale-sum
        .
        {&underline-FRAME}.
        {&DISPLAY-TOTALS}.
        {&underline-FRAME}.
      end.
    end.
  END.
  display stream PrnLibStream
  "Итого по варианту закупки 2 в %" @ sj-print.gds-name
  string(var-sale-sum / sj-goods00.sale-sum * 100, "->>9.999%") @ sj-print.sale-sum
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  {&underline-FRAME}.
  display stream PrnLibStream
  "ИТОГО ПО ВСЕМ ВАРИАНТАМ ЗАКУПКИ" @ sj-print.gds-name
  sj-goods00.sale-sum  @ sj-print.sale-sum
  with frame Purch-Frame.
  DOWN STREAM PrnLibStream 1 with FRAME Purch-Frame.
  HIDE  STREAM PrnLibStream FRAME BottomFrame .
  HIDE  STREAM PrnLibStream FRAME Chk-List.
  output STREAM PrnLibStream CLOSE.
  run get-report-num  in parParentProc(output g#report-num).
  run get-quest-print in parParentProc(output g#quest-print).
  { rep/q-print.i 8 }

  end.

end procedure. /* proc-print */

procedure proc-export :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-z-number   like ub.chk-doc.z-number no-undo .
define input parameter p-pay-desk  like ub.chk-doc.pay-desk no-undo .


define variable v-short-file-name as character no-undo .
define variable v-file-name         as character no-undo .
define variable v-full-path         as character no-undo .
define variable v-path              as character no-undo .
define variable v-file-name-no-ext  as character no-undo .
define variable v-file-name-ext     as character no-undo .
define variable ii                  as integer no-undo .
define variable v-is-out-int        as integer no-undo .
define variable v-full-path-two     as character no-undo .

&scop sign v-is-out-int *

&scop export-item ~
      if sj-goods.var-purch = 2 and treal-3.is-pay then do:  ~
        put stream PrnLibStream unformatted ~
        treal-3.src-code {&comma-char} ~{&sign~} min(abs(treal-3.rest-qnty), abs(sj-goods.rest-qnty)) {&space-char} . ~
      end

  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ("Ждите...").

    do ii = 1 to 2:
      assign
      v-short-file-name = {&shop} + string(buf_inkas.obj-code) + "_"  +
                          "kassa":U + string(p-pay-desk) + "_" +
                          "z":U + string(p-z-number) + "_" +
                          (if ii = 1 then "v" else "r") + ".txt".
      v-is-out-int = if ii = 1 then (- 1) else 1.
      output stream PrnLibStream to value(v-short-file-name).
      _cycle:
      for each sj-goods where
              sj-goods.gds-code > 0
          and sj-goods.var-purch > 0
          and sj-goods.is-out = (if ii = 1 then no else yes) ,
      each treal-3 where
          treal-3.is-out   = sj-goods.is-out
      AND treal-3.gds-code = sj-goods.gds-code
      break
      by sj-goods.is-out
      by sj-goods.gds-code
      by sj-goods.var-purch
      by sj-goods.sale-sum descending
      by treal-3.is-out
      by treal-3.gds-code
      by treal-3.is-pay descending
      by treal-3.src-code:
        if sj-goods.rest-qnty = 0
        or treal-3.rest-qnty = 0 then next _cycle.
        if sj-goods.rest-qnty = treal-3.rest-qnty then do:
          {&export-item}.
          assign
          sj-goods.rest-qnty = 0
          treal-3.rest-qnty = 0
          .
          next _cycle.
        end.
        if abs(sj-goods.rest-qnty) < abs(treal-3.rest-qnty) then do:
          {&export-item}.
          assign
          treal-3.rest-qnty = {&sign} (abs(treal-3.rest-qnty) - abs(sj-goods.rest-qnty))
          sj-goods.rest-qnty = 0
          .
          next _cycle.
        end.
        if abs(sj-goods.rest-qnty) > abs(treal-3.rest-qnty) then do:
          {&export-item}.
          assign
          sj-goods.rest-qnty = {&sign} (abs(sj-goods.rest-qnty) - abs(treal-3.rest-qnty))
          treal-3.rest-qnty = 0
          .
          next _cycle.
        end.
      end.
      put stream PrnLibStream unformatted skip.
      output STREAM PrnLibStream CLOSE.
      run gbl/filename.p
        (input  v-short-file-name
        ,output v-full-path
        ,output v-path
        ,output v-file-name
        ,output v-file-name-no-ext
        ,output v-file-name-ext
        ) no-error  .
      if error-status :error
      then do:
        message
        "Не найден файл экспорта" v-short-file-name
        view-as alert-box .
      end.
      v-full-path-two = v-full-path-two + {&new-line} + v-full-path.
    end. /*do ii*/
    run waitfram-hide in this-procedure .
    message
    "Экспорт завершен" skip
    "Файл(-ы) экспорта" v-full-path-two
    view-as alert-box.
  end.

end procedure. /* proc-export */