/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тела  процедур тестов по итогам по ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/29/05
Author: Bakhtadze Natalya
Creation date: 03/29/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

CASE test-number:
  when 1 then do:
/*блок просчета по накладным*/
&scop sign par-sign *
&if "{1}" = "all" OR "{1}" = "ALL" &then
_chk-doc:
    for each buf_chk-doc no-lock where
            buf_chk-doc.obj-type = p-obj-type
        AND buf_chk-doc.obj-code = p-obj-code
        and buf_chk-doc.d-card   > "":U  ,
        first buf_dis-card NO-LOCK where
            buf_dis-card.d-card = buf_chk-doc.d-card
         AND buf_dis-card.emitent-host-code = dctype
        break by buf_chk-doc.obj-type
              by buf_chk-doc.obj-code
              by buf_chk-doc.d-card:

&else
_chk-doc:
    FOR EACH buf_dis-card NO-LOCK where
            buf_dis-card.d-card = f-d-card,
        EACH buf_shop no-lock,
        EACH buf_chk-doc NO-LOCK where
            buf_chk-doc.obj-type = {&shop} AND
            buf_chk-doc.obj-code = buf_shop.obj-code AND
            buf_chk-doc.d-card = buf_dis-card.d-card
        break by buf_chk-doc.obj-type
              by buf_chk-doc.obj-code
              by buf_chk-doc.d-card:
&endif
        ii = ii + 1.
        if ii MOD 100 = 0 then
        run waitfram-show in this-procedure ("Обработано " + string(ii) + " чеков по дисконтным картам").

        IF FIRST-OF(buf_chk-doc.obj-code) then do:
&if "{1}" = "all" OR "{1}" = "ALL" &then
          find first buf_shop no-lock where
                    buf_shop.obj-code = buf_chk-doc.obj-code No-ERROR.
          if not avail buf_shop then do:
            run waitfram-hide in this-procedure .
            message "Не найдена запись о магазине номер " buf_chk-doc.obj-code view-as alert-box
            ERROR.
            return.
          end.
&endif
          find first buf_sysconf where
                      buf_sysconf.host-code = buf_shop.host-code no-lock No-ERROR.
          if not avail buf_sysconf then do:
            run waitfram-hide in this-procedure .
            message "Не найдена запись о фирме номер " buf_shop.host-code
            view-as alert-box
            ERROR.
            return.
          end.
          find first buf_Cash-pay no-lock where
                  buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
          { gbl/conf-rd.i
            "'iscredit'"
            0
            "''"
            0
            "''"
            "''"
            "''"
            no
            conf-par
            par-type
            no-error
          }
          if error-status:error
          or not available buf_cash-pay
          or buf_cash-pay.is-credit = no
          or conf-par <> "yes"
          then do:
            assign
            cre-pay = 0
            .
          end.
          else do:
            assign
            cre-pay = buf_sysconf.credit-pay
            .
          end.
          assign
          v-base-code = buf_sysconf.base-code
          .
        end. /*IF FIRST-OF(buf_chk-doc.obj-code) then do:*/
        if buf_chk-doc.out-code = ? then next.
        if LOOKUP(string(buf_chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then NEXT.
        FIND FIRST buf_inkas No-LOCK WHERE
                    buf_inkas.inkas-code = buf_chk-doc.out-code No-ERROR.
        if not avail buf_inkas then next.
        find first temp-inkas no-lock where
                  temp-inkas.inkas-code = buf_Inkas.inkas-code no-error .
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = buf_inkas.inkas-code no-error .
        if not available buf_trn-doc then do:

        end.
        find first buf_ret-doc no-lock where
                  buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
        if not available buf_ret-doc then do:

        end.
        if available buf_inkas
        and buf_inkas.status_ = {&fact}
        and buf_inkas.obj-type = {&shop}
        and not available temp-inkas
        then do:
          create temp-inkas.
          assign
          temp-inkas.inkas-code = buf_inkas.inkas-code
          rabota = yes.
        end.
        else do:
          rabota = no.
        end.
        if rabota then do:
            run waitfram-show in this-procedure ("Обработка отчета о продаже " + buf_inkas.inkas-code).
          par-sign = 1.
          &if "{1}" = "all" OR "{1}" = "ALL" &then
          { str/saledc.i   }
          &else
          { str/saledc.i   obj }
          &endif
        end.
      /*END. /*for each buf_chk-doc*/*/
    END. /*for each buf_dis-card*/
    /*блок просчета по накладным*/
    &scop sign  par-direction * par-sign *
&if "{1}" = "all" OR "{1}" = "ALL" &then
    for each buf_Dis-obj no-lock where
            buf_dis-obj.obj-type = p-obj-type
        AND buf_dis-obj.obj-code = p-obj-code
        and buf_dis-obj.dt-code = 0,
       first buf_dis-card no-lock where
            buf_dis-card.d-card = buf_dis-obj.d-card
    by buf_dis-obj.d-card
    by buf_dis-obj.dt-code
    by buf_dis-obj.obj-type
    by buf_dis-obj.obj-code:
      for each bf_trn-doc no-lock where
        bf_trn-doc.obj-type = p-obj-type
    AND bf_trn-doc.obj-code = p-obj-code
    AND bf_trn-doc.cli-type = buf_dis-card.cli-type
    AND bf_trn-doc.cli-code = buf_dis-card.cli-code:
&else
    for each buf_Dis-obj no-lock where
            buf_dis-obj.d-card = f-d-card
        and buf_dis-obj.dt-code = 0,
       first buf_dis-card no-lock where
            buf_dis-card.d-card = buf_dis-obj.d-card
    by buf_dis-obj.d-card
    by buf_dis-obj.dt-code
    by buf_dis-obj.obj-type
    by buf_dis-obj.obj-code:
      for each bf_trn-doc no-lock where
          bf_trn-doc.obj-type = buf_dis-obj.obj-type
      AND bf_trn-doc.obj-code = buf_dis-obj.obj-code
      AND bf_trn-doc.cli-type = buf_dis-card.cli-type
      AND bf_trn-doc.cli-code = buf_dis-card.cli-code:
&endif
      run waitfram-show in this-procedure ( substitute( "Обработка накладных по карте &1", buf_dis-obj.d-card )).
      if bf_trn-doc.d-card <> "":U then do:
        find first temp-d-card where
                  temp-d-card.d-card = bf_trn-doc.d-card
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
              AND temp-d-card.obj-type = bf_trn-doc.obj-type
              AND temp-d-card.obj-code = bf_trn-doc.obj-code
&endif
              no-error .
        if not available temp-d-card then do:
          create temp-d-card.
          assign
          temp-d-card.d-card            = buf_dis-card.d-card
          temp-d-card.card-num          = buf_dis-card.card-num
          temp-d-card.emitent-host-code = buf_dis-card.emitent-host-code
          temp-d-card.type              = buf_dis-card.type
          temp-d-card.cli-type          = buf_dis-card.cli-type
          temp-d-card.cli-code          = buf_dis-card.cli-code
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
          temp-d-card.obj-type = bf_trn-doc.obj-type
          temp-d-card.obj-code = bf_trn-doc.obj-code
&endif
          .
        end.
        assign
        p-doc-code = bf_trn-doc.doc-code
        .
        assign
        p-sign = 1
        p-direction =  if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                      then -1
                      else  1
        par-sign = 1
        par-direction =  if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                      then -1
                      else  1
        .
        { str/trndc.i test }
      end. /*  if bf_trn-doc.d-card <> "":U then do:*/
      end.
    end.
    /*конец блока просчета по накладным*/
    /*блок печати*/
    for each temp-d-card
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
    where temp-d-card.d-card = f-d-card
&endif
    break
    by temp-d-card.d-card
    by temp-d-card.obj-type
    by temp-d-card.obj-code:
      run waitfram-show in this-procedure ( substitute( "Окончательная обработка результатов и вывод в файл - карта &1", temp-d-card.d-card )).
&if "{1}" = "all" OR "{1}" = "ALL" &then
      FIND FIRST buf_dis-obj No-LOCK WHERE
                  buf_dis-obj.d-card = temp-d-card.d-card
             AND  buf_dis-obj.obj-type = temp-d-card.obj-type
             AND  buf_dis-obj.obj-code = temp-d-card.obj-code
             AND  buf_dis-obj.dt-code = 0  No-ERROR.
      IF NOT AVAIL buf_dis-obj then do:
&endif
        assign
        do-obj-code = temp-d-card.obj-code
        do-chk-num = 0
        do-gds-sum-rubl = 0
        do-disc-sum-rubl = 0
        do-pay-sum-rubl = 0
        do-gds-sum-base = 0
        do-disc-sum-base = 0
        do-pay-sum-base = 0
        .
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
      For each buf_dis-obj No-LOCK WHERE
                  buf_dis-obj.d-card = temp-d-card.d-card
              AND buf_dis-obj.dt-code = 0
              and buf_dis-obj.obj-type = temp-d-card.obj-type
              and buf_dis-obj.obj-code = temp-d-card.obj-code:

&Endif
&if "{1}" = "all" OR "{1}" = "ALL" &then
      end.
      else do:
&endif
        assign
        do-obj-code      = buf_dis-obj.obj-code
        do-chk-num       = buf_dis-obj.num-chk
        do-gds-sum-rubl  = buf_dis-obj.gds-tot-rubl - buf_dis-obj.sum-tot-rubl
        do-disc-sum-rubl = buf_dis-obj.gds-dis-rubl - buf_dis-obj.sum-dis-rubl
        do-pay-sum-rubl  = buf_dis-obj.pay-tot-rubl
        do-gds-sum-base  = buf_dis-obj.gds-tot-base - buf_dis-obj.sum-tot-base
        do-disc-sum-base = buf_dis-obj.gds-dis-base - buf_dis-obj.sum-dis-base
        do-pay-sum-base  = buf_dis-obj.pay-tot-base
        .
      end.
      if p-view-mode = 1
      or (do-chk-num <> temp-d-card.num-chk
      OR do-gds-sum-rubl <> temp-d-card.gds-tot-rubl
      OR do-disc-sum-rubl <> temp-d-card.gds-dis-rubl
      OR do-pay-sum-rubl <> temp-d-card.pay-tot-rubl
      OR do-gds-sum-base <> temp-d-card.gds-tot-base
      OR do-disc-sum-base <> temp-d-card.gds-dis-base
      OR do-pay-sum-base <> temp-d-card.pay-tot-base)
      then
      PUT STREAM TEST UNFORMATTED
      temp-d-card.d-card format "X(16)" space(1)
      do-obj-code format ">>>>9" space(1)
      do-chk-num format ">>>>>>>>>9" space(1)
      do-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-gds-sum-base format "->>>,>>>,>>9.99" space(1)
      do-disc-sum-base format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-base format "->>>,>>>,>>9.99" skip(0)
      "По чекам  и накладным"  format "X(22)" space(1)
      temp-d-card.num-chk  format ">>>>>>>>>9" space(1)
      temp-d-card.gds-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-dis-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-tot-base format "->>>,>>>,>>9.99" space(1)
      temp-d-card.gds-dis-base format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
      skip(0)
      .
    end.
    /*конец блока печати*/
  end. /*when 1*/
  when 6 then do:
    run gbl/get-per.w (
                    output v-ok
                   ,input-output x_start-date
                   ,input-output x_end-date
                                      ) no-error .
    if not v-ok then return.

/*блок просчета по продажам*/
&scop sign par-sign *
    for each buf_sysconf,
       each buf_inkas no-lock where
            buf_Inkas.host-code = buf_sysconf.host-code
&if "{1}" = "all" OR "{1}" = "ALL" &then
        AND buf_Inkas.obj-type = p-obj-type
        AND buf_Inkas.obj-code = p-obj-code
&endif
        AND buf_Inkas.doc-date >= x_start-date
        AND buf_Inkas.doc-date <= x_end-date
        AND buf_Inkas.status_ = {&fact}
    break
    by buf_inkas.obj-type
    by buf_inkas.obj-code
    :
      IF FIRST-OF(buf_inkas.obj-code) then do:
        find first buf_shop no-lock where
                  buf_shop.obj-code = buf_inkas.obj-code No-ERROR.
        if not avail buf_shop then do:
          run waitfram-hide in this-procedure .
          message "Не найдена запись о магазине номер " buf_inkas.obj-code view-as alert-box
          ERROR.
          return.
        end.
        find first buf_Cash-pay no-lock where
                buf_cash-pay.cdpay-code = buf_sysconf.credit-pay no-error.
        { gbl/conf-rd.i
          "'iscredit'"
          0
          "''"
          0
          "''"
          "''"
          "''"
          no
          conf-par
          par-type
          no-error
        }
        if error-status:error
        or not available buf_cash-pay
        or buf_cash-pay.is-credit = no
        or conf-par <> "yes"
        then do:
          assign
          cre-pay = 0
          .
        end.
        else do:
          assign
          cre-pay = buf_sysconf.credit-pay
          .
        end.
        assign
        v-base-code = buf_sysconf.base-code
        .
      end. /*IF FIRST-OF(buf_inkas.obj-code) then do:*/
      find first temp-inkas no-lock where
                temp-inkas.inkas-code = buf_Inkas.inkas-code no-error .
      find first buf_trn-doc no-lock where
                buf_trn-doc.doc-code = buf_inkas.inkas-code no-error .
      if not available buf_trn-doc
      or buf_trn-doc.status_ = {&inquiry}
      then do:
        nExt .
      end.
      find first buf_ret-doc no-lock where
                buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
      if not available buf_ret-doc then do:
        nExt .
      end.
      ii = ii + 1.
      run waitfram-show in this-procedure ("Обработано " + string(ii) + " продаж").
      for each temp-d-card:
        delete temp-d-card.
      end.
      for each vchk-pay:
        delete vchk-pay.
      end.
      run waitfram-show in this-procedure ("Обработка отчета о продаже " + buf_inkas.inkas-code).
      par-sign = 1.
      { str/saledc.i   obj }


&if "{1}" = "all" OR "{1}" = "ALL" &then
      FOR EACH buf_dis-card NO-LOCK where
              buf_dis-card.emitent-host-code = dctype,

&else
      FOR EACH buf_dis-card NO-LOCK where
              buf_dis-card.emitent-host-code = dctype AND
              buf_dis-card.d-card = f-d-card,
&endif
        first temp-d-card no-lock where
            temp-d-card.d-card = buf_dis-card.d-card:
        assign
        p-pay-sum-rubl = 0
        p-pay-sum-base = 0
        .
        for each buf_payment no-lock where
                  buf_payment.host-code = buf_Inkas.host-code
              AND  buf_payment.d-card = temp-d-card.d-card
              and  buf_payment.status_ = {&fact}
              and  buf_payment.source-type = {&pmnt-cash-desk}
              and  buf_payment.source-ref = buf_inkas.inkas-code :
          assign
          p-pay-sum-rubl = p-pay-sum-rubl + buf_payment.tot-rubl
          p-pay-sum-base = p-pay-sum-base + buf_payment.tot-base
          .
        end.
        if p-view-mode = 1
        or (p-pay-sum-base <> temp-d-card.pay-tot-base
        or p-pay-sum-rubl <> temp-d-card.pay-tot-rubl) then
        PUT STREAM TEST UNFORMATTED
        temp-d-card.d-card format "X(16)" space(1)
        buf_inkas.inkas-code space(1)
        temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
        temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
        p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
        p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
        (temp-d-card.pay-tot-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
        (temp-d-card.pay-tot-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
        SKIP.
      END. /*for each buf_dis-card*/
    end. /*for each buf_inkas*/
    /*блок просчета по накладным*/
    &scop sign  par-direction * par-sign *
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
    find first buf_Dis-card where buf_Dis-card.d-card = f-d-card no-error .
    if available buf_Dis-card then do:
&endif

    for each buf_sysconf no-lock,
        each bf_trn-doc no-lock where
            bf_trn-doc.host-code = buf_sysconf.host-code
&if "{1}" = "all" OR "{1}" = "ALL" &then
        AND bf_trn-doc.obj-type = p-obj-type
        AND bf_trn-doc.obj-code = p-obj-code
&else
        AND bf_trn-doc.cli-type = buf_Dis-card.cli-type
        AND bf_trn-doc.cli-code = buf_Dis-card.cli-code

&endif
        AND bf_trn-doc.doc-date >= X_start-date
        AND bf_trn-doc.doc-date <= X_end-date:
      if bf_trn-doc.status_ <> {&fact} then NEXT.
      if bf_trn-doc.d-card = "":U then NEXT.
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
      if bf_trn-doc.d-card <> f-d-card then NEXT.
&endif
      if bf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} then NEXT.

&if "{1}" = "all" OR "{1}" = "ALL" &then
      if not can-find(first buf_dis-card NO-LOCK where
              buf_dis-card.emitent-host-code = dctype ) then NEXT.
&else
&endif
      for each temp-d-card:
        delete temp-d-card.
      end.
      for each vchk-pay:
        delete vchk-pay.
      end.
      create temp-d-card.
      assign
      temp-d-card.d-card            = bf_trn-doc.d-card
      temp-d-card.card-num          = temp-d-card.card-num
      temp-d-card.emitent-host-code = temp-d-card.emitent-host-code
      temp-d-card.type              = temp-d-card.type
      temp-d-card.cli-type          = temp-d-card.cli-type
      temp-d-card.cli-code          = temp-d-card.cli-code
      .
      assign
      p-doc-code = bf_trn-doc.doc-code
      .
      assign
      par-sign = 1
      par-direction =  if bf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}
                    then -1
                    else  1.
      { str/trndc.i test }
      assign
      p-pay-sum-rubl = 0
      p-pay-sum-base = 0
      .
      find first buf_payment no-lock where
                buf_payment.host-code = bf_trn-doc.host-code
          AND  buf_payment.d-card = temp-d-card.d-card
          and  buf_payment.status_ = {&fact}
          and  buf_payment.source-type = {&pmnt-trn-doc}
          and  buf_payment.source-ref = bf_trn-doc.doc-code  no-error .
      if available buf_payment then
      assign
      p-pay-sum-rubl = buf_payment.tot-rubl
      p-pay-sum-base = buf_payment.tot-base
      .
      if p-view-mode = 1
      OR (p-pay-sum-base <> temp-d-card.pay-tot-base
      or p-pay-sum-rubl <> temp-d-card.pay-tot-rubl) then
      PUT STREAM TEST UNFORMATTED
      temp-d-card.d-card format "X(16)" space(1)
      bf_trn-doc.doc-code space(1)
      temp-d-card.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
      temp-d-card.pay-tot-base format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
      (temp-d-card.pay-tot-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
      (temp-d-card.pay-tot-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    end. /*    for each buf_sysconf no-lock,*/
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
      end. /*if available buf_dis-card*/
&endif
    /*конец блока по накладным*/
  end.
  when 3 then do:
    FOR EACH ub.dis-host no-LOCK
&if "{1}" = "all" OR "{1}" = "ALL" &then
      WHERE ub.dis-host.host-code = v-host-code
&else
      WHERE ub.dis-host.d-card =  f-d-card
&endif
      AND ub.dis-host.host-code > 0
      and ub.dis-host.dt-code = 0
      BREAK
      by ub.dis-host.d-card
      by ub.dis-host.dt-code
      by ub.dis-host.host-code:
        assign
        do-chk-num = 0
        do-gds-sum-rubl = 0
        do-disc-sum-rubl = 0
        do-pay-sum-rubl = 0
        do-gds-sum-base = 0
        do-disc-sum-base = 0
        do-pay-sum-base = 0
        dh-chk-num = 0
        dh-gds-sum-rubl = 0
        dh-disc-sum-rubl = 0
        dh-pay-sum-rubl = 0
        dh-gds-sum-base = 0
        dh-disc-sum-base = 0
        dh-pay-sum-base = 0
        p-pay-sum-rubl = 0
        p-pay-sum-base = 0
        dh-chk-num = dis-host.num-chk
        dh-gds-sum-rubl = dis-host.gds-tot-rubl
        dh-disc-sum-rubl = dis-host.gds-dis-rubl
        dh-pay-sum-rubl = dis-host.pay-tot-rubl
        dh-gds-sum-base = dis-host.gds-tot-base
        dh-disc-sum-base =  dis-host.gds-dis-base
        dh-pay-sum-base = dis-host.pay-tot-base
        .
        FOR EACH ub.payment no-lock where
                 ub.payment.host-code = ub.dis-host.host-code AND
                 ub.payment.d-card = ub.dis-host.d-card and
                 ub.payment.status_ = {&fact}:
        if ub.payment.source-type = {&pmnt-cash-desk}
        or ub.payment.source-type = {&pmnt-trn-doc} then next.

        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      FOR  EACH ub.dis-obj no-lock where
             ub.dis-obj.host-code = ub.dis-host.host-code
         and ub.dis-obj.dt-code    = ub.dis-host.dt-code
         and ub.dis-obj.d-card   = ub.dis-host.d-card
&if "{1}" = "all" OR "{1}" = "ALL" &then
         AND ub.dis-obj.obj-type = p-obj-type
         AND ub.dis-obj.obj-code = p-obj-code
&else
&endif
         :
      ii = ii + 1.
      if ii MOD 100 = 0 then
      run waitfram-show in this-procedure ("Обработано " + string(ii) + " итогов по дисконтным картам на объекте").

      assign
      do-chk-num = do-chk-num + ub.dis-obj.num-chk
      do-gds-sum-rubl = do-gds-sum-rubl + ub.dis-obj.gds-tot-rubl + ub.dis-obj.sum-tot-rubl
      do-disc-sum-rubl = do-disc-sum-rubl + ub.dis-obj.gds-dis-rubl + ub.dis-obj.sum-dis-rubl
      do-pay-sum-rubl = do-pay-sum-rubl + ub.dis-obj.pay-tot-rubl
      do-gds-sum-base = do-gds-sum-base + ub.dis-obj.gds-tot-base + ub.dis-obj.sum-tot-base
      do-disc-sum-base = do-disc-sum-base + ub.dis-obj.gds-dis-base + ub.dis-obj.sum-dis-base
      do-pay-sum-base = do-pay-sum-base + ub.dis-obj.pay-tot-base
      .
    END. /*for each dis-obj*/
    IF p-view-mode = 1
    or (abs(dh-pay-sum-rubl - (do-pay-sum-rubl + p-pay-sum-rubl)) > 0.005
    OR abs(dh-pay-sum-base - (do-pay-sum-base + p-pay-sum-base)) > 0.005)
    then
    PUT STREAM TEST UNFORMATTED
    dis-host.d-card format "X(16)" space(1)
    dis-host.host-code format "999999999" space(3)
    do-chk-num format "999999999" space(1)
    do-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-gds-sum-base format "->>>,>>>,>>9.99" space(1)
    do-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-disc-sum-base format "->>>,>>>,>>9.99" space(1)
    do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
    do-pay-sum-base format "->>>,>>>,>>9.99" space(1)
    p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(6)
    p-pay-sum-base  format "->>>,>>>,>>9.99" space(6)
    dh-chk-num format "999999999" space(1)
    dh-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-gds-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-disc-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-base format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-rubl - (do-pay-sum-rubl + p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
    dh-pay-sum-base - (do-pay-sum-base + p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
    skip.
  END. /*for each dis-host*/
end.
when 4 then do: /*кассовые платежи + накладные - итоги по объектам*/
  FOR EACH ub.dis-obj No-LOCK
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
     WHERE ub.dis-obj.d-card =  f-d-card
&endif
  BREAK
  by ub.dis-obj.host-code
  by ub.dis-obj.d-card:
    ii = ii + 1.
    if ii MOD 100 = 0 then
    run waitfram-show in this-procedure ("Обработано " + string(ii) + " итогов по дисконтным картам на объекте").
    IF FIRST-of(ub.dis-obj.d-card) then do:
      assign
      p-pay-sum-rubl = 0
      p-pay-sum-base = 0
      do-pay-sum-rubl = 0
      do-pay-sum-base = 0
      .
    END.
    if ub.dis-obj.dt-code = 0 then dO:
      assign
      do-pay-sum-rubl = do-pay-sum-rubl + ub.dis-obj.pay-tot-rubl
      do-pay-sum-base = do-pay-sum-base + ub.dis-obj.pay-tot-base
      .
    end.
    IF LAST-OF(ub.dis-obj.d-card) then do:
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, {&delim-par}) and
              ub.payment.status_ = {&fact} and
              ub.payment.source-type = {&pmnt-cash-desk}:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + if ub.payment.tot-rubl = ? then 0 else ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + if ub.payment.tot-base = ? then 0 else ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, dis-obj.d-card, {&delim-par}) and
              ub.payment.status_ = {&fact} and
              ub.payment.source-type = {&pmnt-cash-desk} + {&comma-char} + "data-import" /*суммы то останутся!!*/ :
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + if ub.payment.tot-rubl = ? then 0 else ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + if ub.payment.tot-base = ? then 0 else ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, {&delim-par}) and
              ub.payment.status_ = {&fact} and
              ub.payment.source-type = {&pmnt-trn-doc}:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.
      FOR EACH ub.payment no-lock where
              ub.payment.host-code = ub.dis-obj.host-code AND
              ub.payment.d-card = entry(1, ub.dis-obj.d-card, {&delim-par}) and
              ub.payment.status_ = {&fact} and
              ub.payment.source-type = {&pmnt-trn-doc} + {&comma-char} + "data-import":U:
        ASSIGN
        p-pay-sum-rubl = p-pay-sum-rubl + ub.payment.tot-rubl
        p-pay-sum-base = p-pay-sum-base + ub.payment.tot-base
        .
      end.


      if p-view-mode = 1
      or ((do-pay-sum-rubl - p-pay-sum-rubl) <> 0
      or (do-pay-sum-base - p-pay-sum-base) <> 0) then
      PUT STREAM TEST UNFORMATTED
      ub.dis-obj.d-card format "X(16)" space(1)
      do-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      do-pay-sum-base format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-rubl  format "->>>,>>>,>>9.99" space(1)
      p-pay-sum-base  format "->>>,>>>,>>9.99" space(1)
      (do-pay-sum-rubl - p-pay-sum-rubl) format "->>>,>>>,>>9.99" space(1)
      (do-pay-sum-base - p-pay-sum-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    END. /*IF LAST-OF(dis-obj.d-card) then do:*/
  end.
END. /*when 4*/
WHEN 5 then do:
  FOR EACH ub.dis-card No-LOCK
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
     WHERE ub.dis-card.d-card =  f-d-card
&endif

  BREAK
  by ub.dis-card.d-card:
    ii = ii + 1.
    if ii MOD 100 = 0 then
    run waitfram-show in this-procedure ("Обработано " + string(ii) + " дисконтных карт").
    IF FIRST-of(dis-card.d-card) then do:
      assign
      dh-gds-sum-rubl = 0
      dh-disc-sum-rubl = 0
      dh-pay-sum-rubl = 0
      dh-gds-sum-base = 0
      dh-disc-sum-base = 0
      dh-pay-sum-base = 0
      .
      FOR EACH ub.dis-host No-LOCK
         WHERE ub.dis-host.d-card = ub.dis-card.d-card
             and ub.dis-host.host-code > 0
             and ub.dis-host.dt-code = 0
      break
      by ub.dis-host.host-code:
        assign
        dh-gds-sum-rubl = dh-gds-sum-rubl + dis-host.gds-tot-rubl
        dh-disc-sum-rubl = dh-disc-sum-rubl + dis-host.gds-dis-rubl
        dh-pay-sum-rubl = dh-pay-sum-rubl + dis-host.pay-tot-rubl
        dh-gds-sum-base = dh-gds-sum-base + dis-host.gds-tot-base
        dh-disc-sum-base = dh-disc-sum-base + dis-host.gds-dis-base
        dh-pay-sum-base = dh-pay-sum-base + dis-host.pay-tot-base
        .
        if dis-card.emitent-host-code = 0 and
        (abs((dis-host.gds-tot-rubl - dis-host.gds-dis-rubl) - dis-host.pay-tot-rubl ) > 0.001 OR
          abs((dis-host.gds-tot-base - dis-host.gds-dis-base) - dis-host.pay-tot-base) > 0.001
        ) then do:
          PUT stream test unformatted
          dis-card.d-card format "X(16)" space(1)
          dis-host.host-code format "999999999" space(3)
          dis-host.gds-tot-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-tot-base format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-dis-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.gds-dis-base format "->>>,>>>,>>9.99" space(1)
          dis-host.pay-tot-rubl format "->>>,>>>,>>9.99" space(1)
          dis-host.pay-tot-base format "->>>,>>>,>>9.99" space(3)
          ((dis-host.gds-tot-rubl - dis-host.gds-dis-rubl) - dis-host.pay-tot-rubl) format "->>>,>>>,>>9.99" space(1)
          ((dis-host.gds-tot-base - dis-host.gds-dis-base) - dis-host.pay-tot-base) format "->>>,>>>,>>9.99" space(1)
          "ОШИБКА глобкарта" format "X(15)" space(1)
          "!ненулевое сальдо" format "X(15)" space(3)
          SKIP.
        end.
      END.
      if p-view-mode = 1
      or (((dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl -  dis-card.saldo-rubl) <> 0
      OR ((dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base -  dis-card.saldo-base) <> 0)
      then
      PUT stream test unformatted
      dis-card.d-card format "X(16)" space(1)
      dis-card.emitent-host-code format "999999999" space(3)
      dh-gds-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-gds-sum-base format "->>>,>>>,>>9.99" space(1)
      dh-disc-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-disc-sum-base format "->>>,>>>,>>9.99" space(1)
      dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      dh-pay-sum-base format "->>>,>>>,>>9.99" space(3)
      (dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl format "->>>,>>>,>>9.99" space(1)
      (dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base format "->>>,>>>,>>9.99" space(1)
      dis-card.saldo-rubl format "->>>,>>>,>>9.99" space(1)
      dis-card.saldo-base format "->>>,>>>,>>9.99" space(3)
      ((dh-gds-sum-rubl - dh-disc-sum-rubl) - dh-pay-sum-rubl -  dis-card.saldo-rubl) format "->>>,>>>,>>9.99" space(1)
      ((dh-gds-sum-BASE - dh-disc-sum-base) - dh-pay-sum-base -  dis-card.saldo-base) format "->>>,>>>,>>9.99" space(1)
      SKIP.
    END. /*if first-of (d-card)*/
  END. /* FOR EACH dis-card No-LOCK*/
END. /*when 5*/
when 7 then do:
  FOR EACH buf_dis-card No-LOCK where
    buf_Dis-card.emitent-host-code = dctype
&if "{1}" = "all" OR "{1}" = "ALL" &then
&else
     AND buf_dis-card.d-card =  f-d-card
&endif,
   first buf_dis-card-type no-lock where
        buf_dis-card-type.type = buf_dis-card.type
    AND buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code

  :
      /*todo*/
      if NOT new-d-pcnt = old-d-pcnt
      or p-view-mode = 1 then do:
        PUT stream test unformatted
        buf_dis-card.d-card format "X(16)" space(1)
        buf_dis-card.type   format "X(8)" space(1)
        for-sum format "->>>,>>>,>>9.99" space(1)
        buf_dis-card.d-pcnt format "->,>>9.99" space(1)
        new-d-pcnt          format "->,>>9.99" space(1)
        skip.
      end.
    END. /*for each dis-card*/
  end.
 when 8 then do:
  run ref/proprefs.w (
                   input parparentproc
                  ,input 'b-sel'
                  ,input "dis-tot"
                  ,input 5
                  ,input '':U
                  ,input '':U /*p-call-id*/
                  ,input-output  v-ref-list) no-error.
  if error-status:error or v-ref-list = '':u then do:
    return.
  end.
  find first buf_prop-ref no-lock where
           recid(buf_prop-ref) = integer(v-ref-list).
  assign
  v-dt-code = buf_prop-ref.dt-code
  v-sum-id =  buf_prop-ref.sum-id
  .
  assign
  v-date-from =  date(entry(1, buf_prop-ref.sum-id, "-"))
  v-date-to =  date(entry(2, buf_prop-ref.sum-id, "-"))
  .
  PUT stream test unformatted
  substitute("Идентификатор частного итога &1 Доп.идентификатор &2"
              ,v-sum-id
              ,buf_prop-ref.caller_id
              ) skip.

  FOR EACH buf_dis-card No-LOCK where
&if "{1}" = "all" OR "{1}" = "ALL" &then
     true
&else
     buf_dis-card.d-card =  f-d-card
&endif
     :
&if "{1}" = "all" OR "{1}" = "ALL" &then
     for each buf_clients no-lock where
            buf_clients.obj-type = {&shop}
       and buf_clients.obj-code = p-obj-code
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
&else
     for each buf_clients no-lock where
            buf_clients.obj-type = {&shop}
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
&endif
      assign
      v-chk-num = 0
      v-netto-sum = 0.
        _buf_chk-doc:
        for each buf_chk-doc no-lock where
          buf_chk-doc.d-card = buf_dis-card.d-card
          and buf_chk-doc.obj-type = buf_clients.obj-type
          and buf_chk-doc.obj-code = buf_clients.obj-code
          and buf_chk-doc.chk-date >= v-date-from
          and buf_chk-doc.chk-date <= v-date-to
          :
          assign
          v-chk-num = v-chk-num  + 1
          v-netto-sum  = v-netto-sum + buf_chk-doc.netto
          .
        end.
      find first buf_dis-obj no-lock where
                buf_dis-obj.obj-type = buf_clients.obj-type
            and buf_dis-obj.obj-code = buf_clients.obj-code
            and buf_dis-obj.d-card = buf_dis-card.d-card
            and buf_dis-obj.dt-code = v-dt-code no-error .
      if not available buf_dis-obj then do:
        assign
        v-chk-num-do = 0
        v-netto-sum-do = 0
        .
      end.
      else do:
        assign
        v-chk-num-do = buf_dis-obj.num-chk
        v-netto-sum-do = (if v-curr-r-b = {&r-b-rubl}
                       then (buf_dis-obj.gds-tot-rubl - buf_dis-obj.gds-dis-rubl)
                       else (buf_dis-obj.gds-tot-base - buf_dis-obj.gds-dis-base)
                       )
        .
      end.
      if v-chk-num <> v-chk-num-do
      or p-view-mode = 1
      then do:
          PUT stream test unformatted
          string(p-obj-type + string(buf_clients.obj-code), "X(20)") space(1)
          buf_dis-card.d-card format "X(16)" space(1)
          v-chk-num   format ">>>>>>>>>" space(10)
          v-chk-num-do   format ">>>>>>>>>" space(10)
          v-netto-sum    format ">>>,>>>,>>>,>>9.999" space(1)
          v-netto-sum-do format ">>>,>>>,>>>,>>9.999" space(1)
          skip.
      end.
    end.
  end. /*FOR EACH buf_dis-card No-LOCK where*/
end.
  when 99 then do:
    FOR EACH buf_dis-card No-LOCK where
    buf_Dis-card.emitent-host-code = dctype
&if "{1}" <> "all" and "{1}" <> "ALL" &then
&else
   AND buf_dis-card.d-card =  f-d-card
&endif
     :
      v-chk-num = 0.
&if "{1}" = "all" OR "{1}" = "ALL" &then
     for each buf_clients no-lock where
            buf_clients.obj-type = {&shop}
       and buf_clients.obj-code = p-obj-code
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
&else
     for each buf_clients no-lock where
            buf_clients.obj-type = {&shop}
       and  (v-cntxt-db-num = 0 or buf_clients.db-num = v-cntxt-db-num):
&endif
      for each buf_chk-doc no-lock where
        buf_chk-doc.d-card = buf_dis-card.d-card
        and buf_chk-doc.obj-type = buf_clients.obj-type
        and buf_chk-doc.obj-code = buf_clients.obj-code:
        assign
        v-chk-num = v-chk-num  + 1
        .
      end.
        find first buf_dis-obj no-lock where
                  buf_dis-obj.obj-type = buf_clients.obj-type
              and buf_dis-obj.obj-code = buf_clients.obj-code
              and buf_dis-obj.d-card = buf_dis-card.d-card
              and buf_dis-obj.dt-code = 0  no-error .
        if not available buf_dis-obj then do:
          assign
          v-chk-num-do = 0.
        end.
        else do:
          assign
          v-chk-num-do = buf_dis-obj.num-chk.
        end.
        if v-chk-num <> v-chk-num-do
        or p-view-mode = 1
        then do:
          PUT stream test unformatted
          string(buf_clients.obj-type + string(buf_clients.obj-code), "X(20)") space(1)
          buf_dis-card.d-card format "X(16)" space(1)
          v-chk-num   format ">>>>>>>>>" space(10)
          v-chk-num-do   format ">>>>>>>>>" space(10)
          skip.
        end.
      end.
    end.
  end.
END CASE.

/* $Workfile$   E n d */