block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сменный отчет лист 10 

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
define input parameter v-report-name-html as character     no-undo .
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

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
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
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_cash-pay  for ub.cash-pay.
define buffer bf_t-10      for t-10 .
define buffer buf_goods    for goods .
/*переменные для вывода отчета в HTML*/
define stream Out-Stream.
define stream OutStr-html.
define variable v-counter    as integer      no-undo.

define variable pol1  as character no-undo .
define variable pol2  as character no-undo .
define variable pol3  as character no-undo .
define variable pol4  as character no-undo .
define variable pol5  as decimal   no-undo .
define variable pol6  as decimal   no-undo .
define variable pol7  as decimal   no-undo .
define variable pol8  as decimal   no-undo.
define variable v-sum-promo as decimal   no-undo.
define variable v-sum-promo-d as decimal   no-undo.

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
            
            /* ищем спец. скидку по промо НП */
            v-sum-promo = 0.               
            for each buf_chk-gds-attr no-lock where                 
                     buf_chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code   
                 and buf_chk-gds-attr.line-num  = buf_chk-gds-pay.line-num                                                    
                 and buf_chk-gds-attr.attr-code = "CSPromoSum"
               :
               v-sum-promo = v-sum-promo + dec(buf_chk-gds-attr.attr-value) no-error.
            end.
            
            assign  
                t-10.sum-netto = t-10.sum-netto + buf_chk-gds-pay.tot-r-b  /* сумма нетто */
                t-10.qnty = t-10.qnty + buf_chk-gds-pay.eff-doc-qnty
                t-10.sum-brutto = t-10.sum-brutto + buf_chk-gds.src-sum * (buf_chk-gds-pay.eff-doc-qnty /  buf_chk-gds.doc-qnty) + v-sum-promo
                /* t-10.sum-brutto = t-10.sum-brutto + buf_chk-gds.src-sum . */
                bf_t-10.sum-netto = bf_t-10.sum-netto + buf_chk-gds-pay.tot-r-b  /* сумма нетто */
                bf_t-10.qnty = bf_t-10.qnty + buf_chk-gds-pay.eff-doc-qnty
                bf_t-10.sum-brutto = bf_t-10.sum-brutto + buf_chk-gds.src-sum * (buf_chk-gds-pay.eff-doc-qnty /  buf_chk-gds.doc-qnty) 
                .

           for each buf_chk-discnt no-lock where (buf_chk-discnt.doc-code       = buf_chk-gds-pay.doc-code
                                              and buf_chk-discnt.object-line-num = buf_chk-gds-pay.line-num
                                              and buf_chk-discnt.record-type     = 0
                                              and not can-find(first buf_chk-discnt2 no-lock 
                                                               where buf_chk-discnt2.doc-code = buf_chk-gds-pay.doc-code
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
                      t-10.pay-code = buf_chk-gds-pay.pay-code 
                      t-10.discnt-type = buf_chk-discnt.discnt-type 
                      t-10.discnt-name = entry(lookup(string(buf_chk-discnt.discnt-type),{&discnt-type-list}), {&discnt-type-list-full} ) 
                      .
                      for first  buf_cash-pay fields (obj-name) where buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code no-lock:
                          t-10.pay-name = buf_cash-pay.obj-name.
                      end.     /* */    
              end.

              v-sum-promo-d = if buf_chk-discnt.promo-id > "" then v-sum-promo else 0.
              
              assign
                  t-10.sum-netto = t-10.sum-netto + buf_chk-gds-pay.tot-r-b  /* сумма нетто */
                  t-10.qnty = t-10.qnty + buf_chk-gds-pay.eff-doc-qnty
                  t-10.sum-brutto = t-10.sum-brutto + buf_chk-discnt.object-sum + v-sum-promo-d
                  /*t-10.discount-sum = t-10.discount-sum + buf_chk-discnt.discnt-value-abs. */
                  t-10.discount-sum = t-10.discount-sum + (buf_chk-discnt.discnt-value-abs * buf_chk-gds-pay.eff-doc-qnty /  buf_chk-gds.doc-qnty) + v-sum-promo-d
                  /*  делаем запись без скидки */
                  bf_t-10.sum-netto = bf_t-10.sum-netto - buf_chk-gds-pay.tot-r-b  /* сумма нетто */
                  bf_t-10.qnty = bf_t-10.qnty - buf_chk-gds-pay.eff-doc-qnty
                  bf_t-10.sum-brutto = bf_t-10.sum-brutto - buf_chk-discnt.object-sum
                  .
             if bf_t-10.qnty < 0 then 
             assign     
                bf_t-10.sum-netto = 0  /* сумма нетто */
                bf_t-10.qnty = 0
                bf_t-10.sum-brutto = 0
                .
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
/*шапка таблицы HTML*/
         
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
          '<tbody> <!-- Здесь начинается таблица отчета -->
            <tr>
                <th style="text-align: center;">Топливо</th>
                <th style="text-align: center;">Код</th>
                <th style="text-align: center;">Тип оплаты</th>
                <th style="text-align: center;">Тип скидки</th>
                <th style="text-align: center;">Кол-во (лт)</th>
                <th style="text-align: center;">Сумма брутто</th>
                <th style="text-align: center;">Скидка</th>
                <th style="text-align: center;">Сумма нетто</th>
            </tr>
            <tr>
                <th style="text-align: center;">10.1</th>
                <th style="text-align: center;">10.2</th>
                <th style="text-align: center;">10.3</th>
                <th style="text-align: center;">10.4</th>
                <th style="text-align: center;">10.5</th>
                <th style="text-align: center;">10.6</th>
                <th style="text-align: center;">10.7</th>
                <th style="text-align: center;">10.8</th>
            </tr>
            '

            , chr(123), chr(125)
        ).

   for each  bf_t-10
      /* break by bf_t-10.gds-code */
       :
         assign
            pol1  =  bf_t-10.gds-name
            pol2  =  string(bf_t-10.gds-code)
            pol3  = bf_t-10.pay-name
            pol4  = bf_t-10.discnt-name
            pol5  = bf_t-10.qnty
            pol6  = round(bf_t-10.sum-brutto,2)
            pol7  = round(bf_t-10.discount-sum,2)
            pol8  = round(bf_t-10.sum-netto,2).
            
          put stream OutStr-html unformatted
            substitute (
            '  <tr>
                    <td text_wrap="true">&1</td>
                    <td>&2</td>
                    <td text_wrap="true">&3</td>
                    <td text_wrap="true">&4</td>
                    <td style="text-align: right;">&5</td>
                    <td style="text-align: right;">&6</td>
                    <td style="text-align: right;">&7</td>
                    <td style="text-align: right;">&8</td>
                </tr>'
            ,
            pol1,
            pol2,
            pol3,
            pol4,
            string(pol5,"->>>>>>>>>>>9.99"),
            string(pol6,"->>>>>>>>>>>9.99"),
            string(pol7,"->>>>>>>>>>>9.99"),
            string(pol8,"->>>>>>>>>>>9.99")
            ).            
   end. /* each  bf_t-10 */
END.
     output stream OutStr-html close.
     output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
     put stream OutStr-html unformatted                                                                     
        substitute (
        '
        </tbody>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
       ).                                                                                                    
      output stream OutStr-html close.