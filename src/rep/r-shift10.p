block-level on error undo, throw.
/*

$Revision: a8f7c80f242a, 1738, rls $
$Author: druban $
$Date: Sat Dec 29 17:15:50 2018 +0300 $
$Workfile: r-shift10.p $
$Archive: rep/r-shift10.p $

Сменный отчет лист 10 сбор данных

Автор: Белоусов Илья Александрович
Дата создания: 12/17/07
Author: Ilia Belousov
Creation date: 12/17/07

Input:

Output:

*/

define input parameter parparentproc      as widget-handle no-undo .
define input parameter p-parent-handle    as handle        no-undo .
define input parameter p-log-handle       as handle        no-undo .
define input parameter p-cont-handle      as handle        no-undo .
define input parameter p-rebh             as handle        no-undo .
define input parameter p-report-id        as character     no-undo .
define input parameter p-xsd-file         as character     no-undo .
define input parameter p-log-file-name    as character     no-undo .
define input parameter p-batch            as integer       no-undo .
define input parameter p-codex-id         as integer       no-undo .
define input parameter p-ruleset-id       as integer       no-undo .
DEFINE INPUT PARAMETER p-obj-type         like ub.shift-obj.obj-type    no-undo.
DEFINE INPUT PARAMETER p-obj-code         like ub.shift-obj.obj-code    no-undo.
DEFINE INPUT PARAMETER p-shift-date-start like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-start  like ub.shift-obj.shift-num   no-undo.
DEFINE INPUT PARAMETER p-shift-date-end   like ub.shift-obj.shift-date  no-undo.
DEFINE INPUT PARAMETER p-shift-num-end    like ub.shift-obj.shift-num   no-undo.

define variable vss-revision    as character no-undo init "$Revision: a8f7c80f242a, 1738, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Sat Dec 29 17:15:50 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shift10.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-shift10.p $":U .
define variable vss-description as character no-undo init "Сменный отчет лист 10 сбор данных".


define   shared stream  PrnLibStream.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ rep/icm-10df.i }
{ gbl/waitfram.i }
{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift10 }

&scop display-message ~
   if p-batch > 0 then do: ~
     run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~). ~
   end. ~
   else do: ~
      run write-to-log in p-log-handle ( input ~{&my-message~}). ~
   end



define buffer buf_chk-doc  for ub.chk-doc .
define buffer buf_chk-gds-pay  for ub.chk-gds-pay.
define buffer buf_chk-discnt  for ub.chk-discnt .
define buffer buf_chk-discnt2  for ub.chk-discnt .
define buffer buf_chk-gds  for ub.chk-gds.
define buffer buf_cash-pay  for ub.cash-pay.
define buffer bf_t-10      for t-10 .
define buffer buf_goods    for goods .

define variable v-counter    as integer      no-undo.

define variable pol1  as character no-undo .
define variable pol2  as character no-undo .
define variable pol3  as character no-undo .
define variable pol4  as character no-undo .
define variable pol5  as decimal   no-undo .
define variable pol6  as decimal   no-undo .
define variable pol7  as decimal   no-undo .
define variable pol8  as decimal   no-undo.

&scop All-sym sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8
&scop All-Pol pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8

do
on error undo, return error
:

   /* расчет */
   for each  bf_t-10:
      delete bf_t-10.
   end.
 for each units no-lock where
      lookup( {&petrolium}, units.type) > 0,
  each buf_goods fields(unit-base gds-code gds-name) no-lock where
        buf_goods.unit-base = units.unit-name  , first bar-code no-lock where bar-code.gds-code  = buf_goods.gds-code
        :
      _shift-chk:
      for each buf_chk-gds-pay no-lock where buf_chk-gds-pay.b-code = bar-code.b-code  and
          buf_chk-gds-pay.obj-type = p-obj-type AND
          buf_chk-gds-pay.obj-code = p-obj-code AND
          (
          buf_chk-gds-pay.shift-date >= p-shift-date-start AND
          buf_chk-gds-pay.shift-date <= p-shift-date-end) :
          IF ( buf_chk-gds-pay.shift-date = p-shift-date-start
          AND  buf_chk-gds-pay.shift-num  < p-shift-num-start)

          OR ( buf_chk-gds-pay.shift-date = p-shift-date-end
          AND  buf_chk-gds-pay.shift-num  > p-shift-num-end)
          THEN dO:
            NEXT _shift-chk.
          END.
          for first buf_chk-gds where buf_chk-gds.doc-code =  buf_chk-gds-pay.doc-code
                                 and  buf_chk-gds.line-num =  buf_chk-gds-pay.line-num no-lock:
                                 /*Создаем запись по оплате целиком*/
           find first t-10 where t-10.gds-code = buf_goods.gds-code
                              and t-10.pay-code = buf_chk-gds-pay.pay-code
                              and t-10.discnt-type = -99
            no-lock no-error.
           find first bf_t-10 where bf_t-10.gds-code = buf_goods.gds-code
                              and bf_t-10.pay-code = buf_chk-gds-pay.pay-code
                              and bf_t-10.discnt-type = 0
            no-lock no-error.

            if not available t-10 then do:
              create t-10.
              assign  t-10.gds-code = buf_goods.gds-code
                     t-10.gds-name = buf_goods.gds-name
                    t-10.pay-code = buf_chk-gds-pay.pay-code
                    t-10.discnt-type = -99 .
                    for first  buf_cash-pay fields (obj-name) where buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code no-lock:
                        t-10.pay-name = buf_cash-pay.obj-name.
                    end.     /* */
                    t-10.discnt-name = 'Итого' .

              create bf_t-10.
              assign  bf_t-10.gds-code = buf_goods.gds-code
                    bf_t-10.gds-name = buf_goods.gds-name
                    bf_t-10.pay-code = buf_chk-gds-pay.pay-code
                    bf_t-10.discnt-type = 0 .
                    for first  buf_cash-pay fields (obj-name) where buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code no-lock:
                        bf_t-10.pay-name = buf_cash-pay.obj-name.
                    end.     /* */
                    bf_t-10.discnt-name = 'Без скидки'   .
            end.
            t-10.sum-netto = t-10.sum-netto + buf_chk-gds-pay.tot-r-b.  /* сумма нетто */
            t-10.qnty = t-10.qnty + buf_chk-gds-pay.eff-doc-qnty.
            t-10.sum-brutto = t-10.sum-brutto + buf_chk-gds.src-sum * (buf_chk-gds-pay.eff-doc-qnty /  buf_chk-gds.doc-qnty) .
            /* t-10.sum-brutto = t-10.sum-brutto + buf_chk-gds.src-sum . */
            bf_t-10.sum-netto = bf_t-10.sum-netto + buf_chk-gds-pay.tot-r-b.  /* сумма нетто */
            bf_t-10.qnty = bf_t-10.qnty + buf_chk-gds-pay.eff-doc-qnty.
            bf_t-10.sum-brutto = bf_t-10.sum-brutto + buf_chk-gds.src-sum * (buf_chk-gds-pay.eff-doc-qnty /  buf_chk-gds.doc-qnty) .

            for each buf_chk-discnt no-lock where (buf_chk-discnt.doc-code       = buf_chk-gds-pay.doc-code
                                              and buf_chk-discnt.object-line-num = buf_chk-gds-pay.line-num
                                              and buf_chk-discnt.record-type     = 0
                                              and not can-find(buf_chk-discnt2 where buf_chk-discnt2.doc-code        = buf_chk-gds-pay.doc-code
                                                                                 and buf_chk-discnt2.object-line-num = buf_chk-gds-pay.line-num
                                                                                 and buf_chk-discnt2.record-type     = 1)
                                              )
                                              or
                                              (   buf_chk-discnt.doc-code        = buf_chk-gds-pay.doc-code
                                              and buf_chk-discnt.object-line-num = buf_chk-gds-pay.line-num
                                              and buf_chk-discnt.record-type     = 1
                                              )                                  
            :

              find first t-10 where t-10.gds-code = buf_goods.gds-code
                                and t-10.pay-code = buf_chk-gds-pay.pay-code
                                and t-10.discnt-type = buf_chk-discnt.discnt-type
              no-lock no-error.
              if not available t-10 then do:
              create t-10.
                assign  t-10.gds-code = buf_goods.gds-code
                      t-10.gds-name = buf_goods.gds-name
                      t-10.pay-code = buf_chk-gds-pay.pay-code .
                      t-10.discnt-type = buf_chk-discnt.discnt-type .
                      t-10.discnt-name = entry(lookup(string(buf_chk-discnt.discnt-type),{&discnt-type-list}), {&discnt-type-list-full} ) .
                      for first  buf_cash-pay fields (obj-name) where buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code no-lock:
                          t-10.pay-name = buf_cash-pay.obj-name.
                      end.     /* */
    /*                 message  t-10.discnt-name skip lookup(string(buf_chk-discnt.discnt-type),{&discnt-type-list}) skip   entry(lookup(string(buf_chk-discnt.discnt-type),{&discnt-type-list}), {&discnt-type-list-full} )
                      view-as alert-box. */
              end.
              t-10.sum-netto = t-10.sum-netto + buf_chk-gds-pay.tot-r-b.  /* сумма нетто */
              t-10.qnty = t-10.qnty + buf_chk-gds-pay.eff-doc-qnty.
              t-10.sum-brutto = t-10.sum-brutto + buf_chk-discnt.object-sum.
              /*t-10.discount-sum = t-10.discount-sum + buf_chk-discnt.discnt-value-abs. */
              t-10.discount-sum = t-10.discount-sum + (buf_chk-discnt.discnt-value-abs * buf_chk-gds-pay.eff-doc-qnty /  buf_chk-gds.doc-qnty).
              /*  делаем запись без скидки */
              bf_t-10.sum-netto = bf_t-10.sum-netto - buf_chk-gds-pay.tot-r-b.  /* сумма нетто */
              bf_t-10.qnty = bf_t-10.qnty - buf_chk-gds-pay.eff-doc-qnty.
              bf_t-10.sum-brutto = bf_t-10.sum-brutto - buf_chk-discnt.object-sum.


             /* message      buf_chk-gds-pay.eff-doc-qnty    buf_chk-gds.doc-qnty    buf_chk-discnt.discnt-value-abs view-as alert-box.  */
            end.
          end.
      end.

   END.
      for each t-10 where t-10.discnt-type = -99:
        t-10.discount-sum =  round(t-10.sum-brutto - t-10.sum-netto,2).
      end.
      /* Если по палтежу нет никаких скидок, удалим запись "Без скидок" */
      for each t-10 where t-10.discnt-type = 0:
        if not can-find(first bf_t-10 where bf_t-10.gds-code = t-10.gds-code
                              and bf_t-10.pay-code = t-10.pay-code
                              and bf_t-10.discnt-type > 0
                        )
        then delete t-10.
      end.

   /* печать */
   DEFINE FRAME FRAME-10
      pol1  column-label "10.1":C30    format "x(30)" space(0)
      sym1  column-label ":"           format "x(1)"  space(0)
      pol2  column-label "10.2":C15    format "x(15)" space(0)
      sym2  column-label ":"           format "x(1)"  space(0)
      pol3  column-label "10.3":C15    format "x(15)" space(0)
      sym3  column-label ":"           format "x(1)"  space(0)
      pol4  column-label "10.4":C15    format "x(15)" space(0)
      sym4  column-label ":"           format "x(1)"  space(0)
      pol5  column-label "10.5":C15    format "->>>,>>>,>>9.99" space(0)
      sym5  column-label ":"           format "x(1)"  space(0)
      pol6  column-label "10.6":C15    format "->>>,>>>,>>9.99" space(0)
      sym6  column-label ":"           format "x(1)"  space(0)
      pol7  column-label "10.7":C15    format "->>>,>>>,>>9.99" space(0)
      sym7  column-label ":"           format "x(1)"  space(0)
      pol8  column-label "10.8":C15    format "->>>,>>>,>>9.99" space(0)
      sym8  column-label ":"           format "x(1)"  space(0)
   with width {&DOS_CW_2} down stream-io use-text NO-BOX.

   FORM HEADER
   {&Header-Text10}
   with FRAME TopFrame width {&DOS_CW_2} PAGE-Top NO-LABELS NO-BOX .
   VIEW STREAM PrnLibStream FRAME TOpFrame .

   for each  bf_t-10
      /* break by bf_t-10.gds-code */
       :

      run on-same-page in this-procedure ({&bottom-height} + 1) .

         assign
            pol1  =  bf_t-10.gds-name
            pol2  =  string(bf_t-10.gds-code)
            pol3  = bf_t-10.pay-name
            pol4  = bf_t-10.discnt-name
            pol5  = bf_t-10.qnty
            pol6  = round(bf_t-10.sum-brutto,2)
            pol7  = round(bf_t-10.discount-sum,2)
            pol8  = round(bf_t-10.sum-netto,2)
      /*      pol7  = bf_t-10.doc-qnty
            pol8  = bf_t-10.delta */
         .

/*      else do:
         assign
            pol1  = "":U
            pol2  = STRING(bf_t-10.pump-code, ">>>>>>>9")
            pol3  = STRING(bf_t-10.nozzle-code, ">>>>>>>9")
            pol4  = bf_t-10.start-mh-qnty
            pol5  = bf_t-10.end-mh-qnty
            pol6  = bf_t-10.meas-qnty
            pol7  = bf_t-10.doc-qnty
            pol8  = bf_t-10.delta
         .
      end.*/

      DISPLAY Stream PrnLibStream
          {&All-sym}
          {&All-pol}
      WITH FRAME Frame-10.
      down stream PrnLibStream with frame FRAME-10.

      {&PutExcel}
         pol1   {&tabulation}
         pol2   {&tabulation}
         pol3   {&tabulation}
         pol4   {&tabulation}
         pol5   {&tabulation}
         pol6   {&tabulation}
         pol7   {&tabulation}
         pol8   {&tabulation}
      SKIP.
     /*
      accumulate bf_t-10.start-mh-qnty  (Total by bf_t-10.gds-code).
      accumulate bf_t-10.end-mh-qnty    (Total by bf_t-10.gds-code).
      accumulate bf_t-10.meas-qnty      (Total by bf_t-10.gds-code).
      accumulate bf_t-10.doc-qnty       (Total by bf_t-10.gds-code).
      accumulate bf_t-10.delta          (Total by bf_t-10.gds-code).
      accumulate bf_t-10.cancell-qnty   (Total by bf_t-10.gds-code).
      accumulate bf_t-10.overflow-qnty  (Total by bf_t-10.gds-code).
      accumulate bf_t-10.trans-qnty     (Total by bf_t-10.gds-code).

      IF last-of (bf_t-10.gds-code) THEN DO:
         assign*
            pol1  = SUBSTITUTE("Всего по &1", bf_t-10.gds-name)
            pol2  = ""
            pol3  = ""
            pol4  = accum Total by bf_t-10.gds-code bf_t-10.start-mh-qnty
            pol5  = accum Total by bf_t-10.gds-code bf_t-10.end-mh-qnty
            pol6  = accum Total by bf_t-10.gds-code bf_t-10.meas-qnty
            pol7  = accum Total by bf_t-10.gds-code bf_t-10.doc-qnty
            pol8  = accum Total by bf_t-10.gds-code bf_t-10.delta
         .
         underline stream PrnLibStream
            {&All-sym}
            {&All-Pol}
         with frame FRAME-10.
         down stream PrnLibStream with frame FRAME-10.
         DISPLAY Stream PrnLibStream
            {&All-sym}
            {&All-pol}
         WITH FRAME FRAME-10.
         down stream PrnLibStream with frame FRAME-10.
         underline stream PrnLibStream
            {&All-sym}
            {&All-Pol}
         with frame FRAME-10.
         down stream PrnLibStream with frame FRAME-10.

         {&PutExcel}
            pol1   {&tabulation}
            pol2   {&tabulation}
            pol3   {&tabulation}
            pol4   {&tabulation}
            pol5   {&tabulation}
            pol6   {&tabulation}
            pol7   {&tabulation}
            pol8   {&tabulation}
         SKIP.
      END.
      */
   end. /* each  bf_t-10 */
END.
