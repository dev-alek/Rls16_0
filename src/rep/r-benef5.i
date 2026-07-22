/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать отчета о выручке  BreakByGoods

Автор: Молотков Сергей Михайлович
Дата создания: 05/09/17
Author: Molotkov Sergey
Creation date: 05/09/17

*/
/*

Структура отчёта

shop1
  наличные rub
  товар1
  товар2
  товар3
  наличные usd
  товар1
  товар2
  товар3
средн.чек = 
итого     =

shop2
  наличные rub
  товар1
  товар2
  товар3
  наличные usd
  товар1
  товар2
  товар3
средн.чек = 
итого     =

итого по всем = 
итого наличные =  

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*{ rep/r-bentt.i "new shared" } 28/V-2019 */
{ rep/r-bentt.i  }

DEFINE VARIABLE sale-price-type as character   no-undo .
DEFINE VARIABLE found           as logical init yes no-undo.
DEFINE VARIABLE NotInc          as logical     no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE DatePrinted     as      logical     no-undo.
DEFINE VARIABLE sym1 as char init ":"   no-undo.
DEFINE VARIABLE sym2 as char init ":"   no-undo.
DEFINE VARIABLE sym3 as char init ":"   no-undo.
DEFINE VARIABLE sym4 as char init ":"   no-undo.
DEFINE VARIABLE sym5 as char init ":"   no-undo.
DEFINE VARIABLE sym6 as char init ":"   no-undo.
DEFINE VARIABLE sym7 as char init ":"   no-undo.
DEFINE VARIABLE sym8 as char init ":"   no-undo.

DEFINE VARIABLE ObjAmount    as      integer no-undo.
DEFINE VARIABLE ChkAmount    as      integer no-undo.
DEFINE VARIABLE AllDay-BaseSum as decimal no-undo .
DEFINE VARIABLE AllDay-RublSum as decimal no-undo .


{ rep/e-nobenq.i } 
/*
{ rep/e-nobenq.i } 06/IX-2018 - не используется
                   проверка наличия чеков в запрошенном периоде встроена в цикл обработки чеков
*/

define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}

/* по одному магазину за все дни: */
define variable acc-day-base as decimal no-undo . /* сумма по chk-pay.tot-base */
define variable acc-day-rubl as decimal no-undo . /* сумма по chk-pay.tot-rubl */
define variable acc-day-cnt  as integer no-undo . /* кол-во чеков */
define variable acc-day-nf   as integer no-undo . /* кол-во чеков нефискальных */
define variable acc-curr-rubl as decimal no-undo . /* сумма по виду платежа и валюте за подразделение */

define variable v-report-name       as character no-undo .
define variable v-file-name-rep-htm as character no-undo .
define variable v-vsex-cas          as character no-undo .
define variable v-avg-chk           as decimal decimals  2 no-undo .

define variable v-algo-num   as character no-undo. /* актуальный номер алгоритма распределения оплат по товарам в чеке */
define variable acc-count-ln as integer no-undo . /* кол-во чеков для отображения в хронометраже */
define variable v-is-sub-count as logical no-undo. /* true: вычесть чек из общего количества как нефискальный */
/* define variable v-is-sub-pay   as logical no-undo .  true: вычесть оплату чека как нефискального 15/IV-2019 вычитается через sub-count */
define variable v-pay-name   as character no-undo . /* наименование вида оплаты */
define variable v-curr-name  as character no-undo . /* наименование валюты */
define variable v-gds-code   as integer no-undo . /* код товара */
define variable v-grp-code0  as integer no-undo . /* код группы товара, и выше */
define variable v-grp-code   as integer no-undo . /* код группы товара, и выше */
define variable v-upr-code   as integer no-undo . /* код выше группы товара */
define variable v-prt-root   as integer no-undo . /* код корневой группы товара */
define variable v-upr-stack  as character no-undo . /* стек вложенности товара */
define variable v-def-list   as character no-undo . /* список обработанных кодов группы */
define variable v-gds-name   as character no-undo . /* наименование товара */
define variable v-grp-name   as character no-undo . /* наименование группы */
define variable v-obj-name   as character no-undo . /* наименование магазина */
define variable v-level      as integer no-undo . /* уровень вложенности групп для вывода в html */
define variable v-level5     as integer no-undo . /* уровень вложенности групп для вывода в html */
define variable v-has-up-lvl as logical no-undo . /* true - есть группа вышестоящего уровня */
define variable v-chk-count  as integer no-undo . /* локальное кол-во чеков */
define variable v-pcnt       as decimal decimals 2 no-undo . /* доля в выручек, % */
define variable v-skip-line  as logical no-undo . /* true: пропустить запись */
define variable v-tot-r-b as decimal no-undo .

define buffer buf-chk-doc     for ub.chk-doc .
define buffer buf-chk-gds     for ub.chk-gds .
define buffer buf-chk-pay     for ub.chk-pay .
define buffer buf-chk-gds-pay for ub.chk-gds-pay .
define buffer buf-cash-pay for ub.cash-pay .
define buffer buf-currency for ub.currency .
define buffer buf-bar-code for ub.bar-code .
define buffer buf-goods    for ub.goods .
define buffer buf-gds-grp  for ub.gds-grp .
define buffer buf-clients  for ub.clients .
define buffer tt-grp-sum4  for tt-grp-sum .
define buffer tt-grp-sum5  for tt-grp-sum .
define buffer tt-grp-sum6  for tt-grp-sum .
define buffer buf2_help-chk for help-chk .
define query qben-chk-count for ben-chk-count .

define stream OutStr-html.

{ gbl/cur-time.i }
{ gbl/prn-lib.i   }
{ rep/html-conv.i }

/* ----------------------------------------------------------------------*/
procedure grp-agregator private :
/* Обходит дерево tt-grp-sum и
   1) возвращает наверх сумму по дочерним узлам,
   2) собирает количество чеков по текущему узлу.
*/  
define input  parameter p-obj-code   as integer no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-pay-code   as integer no-undo .
define input  parameter p-curr-code  as integer no-undo .
define input  parameter p-upper-code as integer no-undo . /* код родительской группы */
define output parameter p-tot-r-b    as decimal no-undo . /* сумма за себя и за подчинённые */
define variable v-tot-r-b as decimal no-undo .
define buffer buf_tt-grp-sum for tt-grp-sum .
define buffer buf_help-chk   for help-chk .
define buffer buf2_help-chk  for help-chk .

  p-tot-r-b = 0 .
  for each buf_tt-grp-sum where buf_tt-grp-sum.obj-code   = p-obj-code
                            and buf_tt-grp-sum.pay-code   = p-pay-code
                            and buf_tt-grp-sum.curr-code  = p-curr-code
                            and buf_tt-grp-sum.upper-code = p-upper-code
                            and buf_tt-grp-sum.obj-type   = p-obj-type :
    if buf_tt-grp-sum.grp-lvl = 1 then do :
      /* конечная группа:
         - прописать свои чеки в вышестоящую группу;
         - вернуть сумму за себя.
      */
      v-tot-r-b = buf_tt-grp-sum.tot-r-b .
    end .
    else do :
      /* вышестоящая группа:
         - прописать свои чеки в вышестоящую группу;
         - вернуть сумму за себя и за подчинённые.
      */
      run grp-agregator in this-procedure
      ( buf_tt-grp-sum.obj-code
      , buf_tt-grp-sum.obj-type
      , buf_tt-grp-sum.pay-code
      , buf_tt-grp-sum.curr-code
      , buf_tt-grp-sum.def-code
      , output v-tot-r-b
      ) .
      buf_tt-grp-sum.tot-r-b = v-tot-r-b .
    end .
    p-tot-r-b = p-tot-r-b + v-tot-r-b .

    /* все чеки, которые к этой группе привязаны, транслируем на вышестоящую, без повторов */
    for each buf_help-chk where buf_help-chk.obj-code  = buf_tt-grp-sum.obj-code
                            and buf_help-chk.pay-code  = buf_tt-grp-sum.pay-code
                            and buf_help-chk.curr-code = buf_tt-grp-sum.curr-code
                            and buf_help-chk.group-chk = buf_tt-grp-sum.def-code :
      buf_tt-grp-sum.chk-cnt-all = buf_tt-grp-sum.chk-cnt-all + 1.
      /* каждый doc-code текущей товарной группы пытаемся приложить к товарной группе вышестоящего уровня */
      if buf_tt-grp-sum.upper-code > 0 then do:
        if not can-find (first buf2_help-chk where buf2_help-chk.obj-code  = buf_tt-grp-sum.obj-code
                                               and buf2_help-chk.pay-code  = buf_tt-grp-sum.pay-code
                                               and buf2_help-chk.curr-code = buf_tt-grp-sum.curr-code
                                               and buf2_help-chk.doc-code  = buf_help-chk.doc-code
                                               and buf2_help-chk.group-chk = buf_tt-grp-sum.upper-code) then do:
          create buf2_help-chk. /* каждый doc-code, в котором участвовала группа, содержащая просматривемую подгруппу товара */
          assign             
            buf2_help-chk.obj-code  = buf_tt-grp-sum.obj-code
            buf2_help-chk.pay-code  = buf_tt-grp-sum.pay-code
            buf2_help-chk.curr-code = buf_tt-grp-sum.curr-code
            buf2_help-chk.doc-code  = buf_help-chk.doc-code
            buf2_help-chk.group-chk = buf_tt-grp-sum.upper-code
          .
        end.
      end.
      delete buf_help-chk.
    end. /* end_of for_each buf_help-chk */
    
  end . /* end_of buf_tt-grp-sum */
  
end procedure . /* end_of grp-agregator */  
/* ----------------------------------------------------------------------*/

&global-define  no-benefits    "Не было никакой выручки на выбранных объектах ~
в течение заданного Вами периода времени."

empty temp-table all-days_sum .
empty temp-table ben-chk-count .
empty temp-table help-chk .
empty temp-table tt-gds-sum .
empty temp-table tt-grp-sum .


run no-benq(output found).
if not found then do:
  message {&no-benefits} view-as alert-box information .
  return.
end.


run rep/GetAlgoNum.p (output v-algo-num).
assign
  AllDay-RublSum = 0
  AllDay-BaseSum = 0
  ChkAmount = 0
  acc-count-ln = 0
.
FOR EACH obj-list WHERE obj-list.obj-type = {&shop} NO-LOCK :
  run waitfram-show in this-procedure ( obj-list.obj-type + string(obj-list.obj-code) +
                                        ", отнесение оплат к товарам чека" ) .

  /* доразмазывание chk-pay по chk-gds-pay согласно актуальному algo-num */ 
  CASE X-radio-Task :
    when 1 then do: /* 1 - календарные даты */
      run rep/rpychk0.p (input "r-autocu" /* выборка chk-doc по chk-doc.chk-date */ 
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input x-date-start /*p-date-from*/
                        ,input x-date-end   /*p-date-to*/
                        ,input ?            /*p-shift-date-from*/
                        ,input ?            /*p-shift-date-to*/
                        ,input 0            /*p-shift-num-start*/
                        ,input 99           /*p-shift-num-end*/
                        ,input ?            /*p-inkas-code*/
                        ) no-error.
      if error-status:error then . /* - не существенно; положить в лог процесса */
    end. /* end_of календарные даты */
    when 2 then do: /* 2 - сменные сутки */
      run rep/rpychk0.p (input "r-shft3f" /* выборка chk-doc по chk-doc.shift-date без отсечения по out-code */ 
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?            /*p-date-from*/
                        ,input ?            /*p-date-to*/
                        ,input x-date-start /*p-shift-date-from*/
                        ,input x-date-end   /*p-shift-date-to*/
                        ,input 0            /*p-shift-num-start*/
                        ,input 99           /*p-shift-num-end*/
                        ,input ?            /*p-inkas-code*/
                        ) no-error.
      if error-status:error then . /* - не существенно; положить в лог процесса */
    end. /* end_of сменные сутки */
    when 3 then do: /* 3 - сменные сутки и порядок */
      run rep/rpychk0.p (input "r-shft3f" /* выборка chk-doc по chk-doc.shift-date без отсечения по out-code */ 
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?            /*p-date-from*/
                        ,input ?            /*p-date-to*/
                        ,input x-date-start  /*p-shift-date-from*/
                        ,input x-date-end    /*p-shift-date-to*/
                        ,input X-shift-Start /*p-shift-num-start*/
                        ,input X-shift-Start /*p-shift-num-end*/
                        ,input ?            /*p-inkas-code*/
                        ) no-error.
      if error-status:error then . /* - не существенно; положить в лог процесса */
    end. /* end_of сменные сутки и порядок */
    when 4 then do: /* 4 - по сменам */
      run rep/rpychk0.p (input "r-ptrsp2" /* выборка chk-doc по равенству chk-doc.shift-date + chk-doc.shift-num */ 
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?            /*p-date-from*/
                        ,input ?            /*p-date-to*/
                        ,input x-date-start  /*p-shift-date-from*/
                        ,input ?             /*p-shift-date-to*/
                        ,input X-shift-Alone /*p-shift-num-start*/
                        ,input 99            /*p-shift-num-end*/
                        ,input ?            /*p-inkas-code*/
                        ) no-error.
      if error-status:error then . /* - не существенно; положить в лог процесса */
    end. /* end_of по сменам */
    otherwise .  
  END CASE. /* end_of case_X-radio-Task */

  assign
    acc-day-base = 0
    acc-day-rubl = 0
    acc-day-cnt = 0
    acc-day-nf  = 0
  .
  CASE X-radio-Task :
    when 1 then do: /* 1 - календарные даты */
    
      FOR EACH buf-chk-doc NO-LOCK WHERE
               buf-chk-doc.obj-type = obj-list.obj-type AND
               buf-chk-doc.obj-code = obj-list.obj-code AND
               buf-chk-doc.chk-date >= x-date-start AND
               buf-chk-doc.chk-date <= x-date-end AND
              (IF cas-num > 0 then buf-chk-doc.pay-desk = cas-num else TRUE):
        do: /* хронометраж */
          acc-count-ln = acc-count-ln + 1.
          if ( acc-count-ln modulo 25 ) = 0 then
            run waitfram-show in this-procedure ( obj-list.obj-type + string(obj-list.obj-code) +
                                                  ", обработано строк чеков : " + string(acc-count-ln) ) .
        end.
                
&if "{1}" = "time" &then
          v-skip-line =
          (
             T-time AND
             NOT can-find (FIRST times WHERE times.time1 <= buf-chk-doc.chk-time
                                         AND times.time2 >= buf-chk-doc.chk-time)
          ) .
&else 
          v-skip-line = false .
&endif
        if not v-skip-line then do :
          v-is-sub-count = (  lookup(string(buf-chk-doc.chk-type), {&no-sale-receipt-codes}) > 0  ).
          if not v-is-sub-count then do :
            { rep/e-bcrbng.i  }
          end .
        end .
      END. /* end_of for_each buf-chk-doc */
      
    end. /* end_of календарные даты */
    otherwise do: /* 2 - Сменные сутки, 3 - Сменные сутки и порядок, 4 - По сменам */
    
      FOR EACH buf-chk-doc NO-LOCK WHERE
               buf-chk-doc.obj-type = obj-list.obj-type AND
               buf-chk-doc.obj-code = obj-list.obj-code AND
               buf-chk-doc.shift-date >= x-date-start AND
               buf-chk-doc.shift-date <= x-date-end AND
              (IF cas-num > 0 then buf-chk-doc.pay-desk = cas-num else TRUE):
        do: /* хронометраж */
          acc-count-ln = acc-count-ln + 1.
          if ( acc-count-ln modulo 25 ) = 0 then
            run waitfram-show in this-procedure ( obj-list.obj-type + string(obj-list.obj-code) +
                                                  ", обработано строк чеков : " + string(acc-count-ln) ) .
        end.
        
          v-skip-line = (
             X-Radio-task = 3 AND
            ((buf-chk-doc.shift-date = X-date-start AND buf-chk-doc.shift-num < X-shift-Start) OR
             (buf-chk-doc.shift-date = X-date-end   AND buf-chk-doc.shift-num > X-shift-End))        
          ) OR (
             X-radio-task = 4 AND
             (buf-chk-doc.shift-num <> X-shift-Alone)
&if "{1}" = "time" &then
          ) OR (
             T-time AND
             NOT can-find (FIRST times WHERE times.time1 <= buf-chk-doc.chk-time
                                         AND times.time2 >= buf-chk-doc.chk-time)
&endif
          ) .
        
        if not v-skip-line then do :
          v-is-sub-count = (  lookup(string(buf-chk-doc.chk-type), {&no-sale-receipt-codes}) > 0  ).
          if not v-is-sub-count then do :
            { rep/e-bcrbng.i  }
          end .
        end .
      END. /* end_of for_each buf-chk-doc */
      
    end. /* end_of сменные сутки */
  END CASE. /* end_of case_X-radio-Task */
   
  CREATE all-days_sum .
  assign
    all-days_sum.obj-type = obj-list.obj-type
    all-days_sum.obj-code = obj-list.obj-code
    all-days_sum.tot-base = acc-day-base
    all-days_sum.tot-rubl = acc-day-rubl
    all-days_sum.tot-r-b = (if v-curr-r-b = {&r-b-rubl} then acc-day-rubl
                                                        else acc-day-base)
    all-days_sum.chk-cnt-all  = acc-day-cnt
    all-days_sum.chk-cnt-nf   = acc-day-nf
  .
  assign
    AllDay-RublSum = AllDay-RublSum + acc-day-rubl
    AllDay-BaseSum = AllDay-BaseSum + acc-day-base
    ChkAmount      = ChkAmount + (all-days_sum.chk-cnt-all - all-days_sum.chk-cnt-nf)
  .
END. /*FOR EACH OBJ-LIST*/


/* дозаполнить:
   1) привязать собранные b-code к gds-code;
   2) добавить наименование магазина, вида оплаты и наименование валюты; 
   3) заполнить таблицу с классификацией товаров, попавших в отчёт.
*/
run waitfram-show in this-procedure ("сведение штрих-кодов к товарам" ) .
for each tt-gds-sum break by tt-gds-sum.b-code:
  if first-of (tt-gds-sum.b-code) then do:
    find first buf-bar-code no-lock where buf-bar-code.b-code = tt-gds-sum.b-code no-error.
    v-gds-code = if available buf-bar-code then buf-bar-code.gds-code else 0.
  end.
  tt-gds-sum.gds-code = v-gds-code.
end.

/* здесь все бар-коды сворачиваются до уровня своих товаров (в разрезе валюты-видаоплаты-магазина),
   товары создают свою иерархию групп,
   суммы складываются от товаров до верхней группы.
   По валютам и по видам оплаты суммы не складываются. */
for each tt-gds-sum break by tt-gds-sum.obj-code
                          by tt-gds-sum.pay-code
                          by tt-gds-sum.curr-code
                          by tt-gds-sum.gds-code:
  if first-of (tt-gds-sum.obj-code) then do:
    FIND FIRST buf-clients no-lock
         WHERE buf-clients.obj-type = tt-gds-sum.obj-type
           AND buf-clients.obj-code = tt-gds-sum.obj-code no-error .
    v-obj-name = if available buf-clients then buf-clients.obj-name else "".
  end.
  if first-of (tt-gds-sum.pay-code) then do:
    FIND FIRST buf-cash-pay no-lock
         WHERE buf-cash-pay.cdpay-code = tt-gds-sum.pay-code
           AND buf-cash-pay.curr-code  = tt-gds-sum.curr-code NO-ERROR.
    v-pay-name = if available buf-cash-pay then buf-cash-pay.obj-name else "Неопознанная оплата".            
  end.
  if first-of (tt-gds-sum.curr-code) then do:
    FIND FIRST buf-currency no-lock
         WHERE buf-currency.curr-code = tt-gds-sum.curr-code NO-ERROR.
    v-curr-name = if available buf-currency then buf-currency.curr-name else "Неопознанная валюта".
  end.
  if first-of (tt-gds-sum.gds-code) then do:
    run waitfram-show in this-procedure ("подсчёт количества чеков по группам: товар " + string(tt-gds-sum.gds-code)) .
    find first buf-goods no-lock where buf-goods.gds-code = tt-gds-sum.gds-code no-error.
    if available buf-goods then assign
      v-gds-name = buf-goods.gds-name
      v-grp-code = buf-goods.grp-code
    .
    else assign
      v-gds-name = ""
      v-grp-code = 0
    .
    /* терминальная группа товара */
    find first tt-grp-sum4 where tt-grp-sum4.obj-code = tt-gds-sum.obj-code
                             and tt-grp-sum4.obj-type = tt-gds-sum.obj-type
                             and tt-grp-sum4.pay-code = tt-gds-sum.pay-code
                             and tt-grp-sum4.curr-code = tt-gds-sum.curr-code
                             and tt-grp-sum4.def-code = v-grp-code no-error.
    if not available tt-grp-sum4 then do:
      find first buf-gds-grp no-lock where buf-gds-grp.node-code = v-grp-code no-error.
      if available buf-gds-grp then assign
        v-grp-name = buf-gds-grp.node-name
        v-upr-code = buf-gds-grp.upper-code
      .
      else assign
        v-grp-name = ""
        v-upr-code = 0
      .
      create tt-grp-sum4.
      assign
        tt-grp-sum4.obj-type  = tt-gds-sum.obj-type
        tt-grp-sum4.obj-code  = tt-gds-sum.obj-code
        tt-grp-sum4.obj-name  = v-obj-name
        tt-grp-sum4.pay-code  = tt-gds-sum.pay-code
        tt-grp-sum4.pay-name  = v-pay-name
        tt-grp-sum4.curr-code = tt-gds-sum.curr-code
        tt-grp-sum4.curr-name = v-curr-name
        tt-grp-sum4.is-group  = true
        tt-grp-sum4.upper-code = v-upr-code
        tt-grp-sum4.grp-lvl    = 1
        tt-grp-sum4.def-code   = v-grp-code
        tt-grp-sum4.def-name   = v-grp-name
        tt-grp-sum4.def-level = 0
        tt-grp-sum4.tot-r-b     = 0
        tt-grp-sum4.chk-cnt-all = 0
        tt-grp-sum4.chk-cnt-nf  = 0
      .
    end.
    /* здесь сам товар */
    create tt-grp-sum.
    assign
      tt-grp-sum.obj-type  = tt-gds-sum.obj-type
      tt-grp-sum.obj-code  = tt-gds-sum.obj-code
      tt-grp-sum.obj-name  = v-obj-name
      tt-grp-sum.pay-code  = tt-gds-sum.pay-code
      tt-grp-sum.pay-name  = v-pay-name
      tt-grp-sum.curr-code = tt-gds-sum.curr-code
      tt-grp-sum.curr-name = v-curr-name
      tt-grp-sum.is-group  = false
      tt-grp-sum.upper-code = v-grp-code 
      tt-grp-sum.grp-lvl    = 0
      tt-grp-sum.def-code   = tt-gds-sum.gds-code
      tt-grp-sum.def-name   = v-gds-name
      tt-grp-sum.def-level = 0
      tt-grp-sum.tot-r-b     = 0
      tt-grp-sum.chk-cnt-all = 0
      tt-grp-sum.chk-cnt-nf  = 0
    .
  end.
  
  /* в одном чеке может присутствовать несколько товаров, т.е. будет несколько записей с одним doc-code;
     нам нужно количество записей, в которых doc-code не повторяется */
  /* количество чеков с товарами каждой группы суммируется независимо в таблицу help-chk */
  v-chk-count = 0.
  for each ben-chk-count
     where ben-chk-count.obj-type  = tt-gds-sum.obj-type
       and ben-chk-count.obj-code  = tt-gds-sum.obj-code
       and ben-chk-count.b-code    = tt-gds-sum.b-code
       and ben-chk-count.pay-code  = tt-gds-sum.pay-code
       and ben-chk-count.curr-code = tt-gds-sum.curr-code
  break by ben-chk-count.doc-code:
    if first-of (ben-chk-count.doc-code) then do:
      v-chk-count = v-chk-count + 1. /* - в скольких чеках участвовал один баркод товара */
      if not can-find (first help-chk where help-chk.obj-code = tt-gds-sum.obj-code
                                        and help-chk.pay-code = tt-gds-sum.pay-code
                                        and help-chk.curr-code = tt-gds-sum.curr-code
                                        and help-chk.doc-code  = ben-chk-count.doc-code
                                        and help-chk.group-chk = v-grp-code) then do:
        create help-chk. /* каждый doc-code, в котором участвовала группа, содержащая просматривемый баркод товара */
        assign
          help-chk.obj-code  = tt-gds-sum.obj-code
          help-chk.pay-code  = tt-gds-sum.pay-code
          help-chk.curr-code = tt-gds-sum.curr-code
          help-chk.doc-code  = ben-chk-count.doc-code
          help-chk.group-chk = v-grp-code
        .
      end.
    end.  
  end.

  assign
    tt-grp-sum4.tot-r-b    = tt-grp-sum4.tot-r-b    + tt-gds-sum.tot-r-b
    tt-grp-sum.tot-r-b     = tt-grp-sum.tot-r-b     + tt-gds-sum.tot-r-b
    tt-grp-sum.chk-cnt-all = tt-grp-sum.chk-cnt-all + v-chk-count 
    tt-grp-sum.chk-cnt-nf  = tt-grp-sum.chk-cnt-nf  + 0
  .
end. /* end_of for_each tt-gds-sum */                            
                

/* Дорасвставлять количества чеков по группам:
   "в скольки чеках присутствовали товары этой группы?"
   (не равно сумме количества чеков, в которых присутствовал каждый из товаров этой группы)
*/

/* отдельно построить дерево:
   - собрать вышестоящие группы,
   - поднять разновложенных родителей до максимально верхнего уровня 
   отдельно, уже по дереву, собрать суммы и привязать к ним чеки.
   Иначе при разной глубине вложенности (например 408->1 и 1118->203->1) группа верхнего уровня
   будет посчитана давжды, либо группа вложенного уровня при определённой очерёдности обхода будет потеряна. */
run waitfram-show in this-procedure ("добавление вышестоящих групп") .
v-level = 0.
repeat:
  assign
    v-level = v-level + 1 /* протестировано на уровнях 1 и 2 */
    v-has-up-lvl = false
  . 
  for each tt-grp-sum where tt-grp-sum.grp-lvl = v-level
                        and tt-grp-sum.upper-code > 0 : 
    /* вышестоящая группа */
    find first tt-grp-sum4 where tt-grp-sum4.obj-code = tt-grp-sum.obj-code
                             and tt-grp-sum4.pay-code = tt-grp-sum.pay-code
                             and tt-grp-sum4.curr-code = tt-grp-sum.curr-code
                             and tt-grp-sum4.def-code = tt-grp-sum.upper-code
                             and tt-grp-sum4.obj-type = tt-grp-sum.obj-type no-error.
    if available tt-grp-sum4 then do:
      v-level5 = v-level + 1.
      if tt-grp-sum4.grp-lvl < v-level5 then do:
        /* здесь разновложенные родители вытягиваются до максимально верхнего уровня:
           пока tt-grp-sum6 валидна:
             tt-grp-sum6.grp-lvl = level5;
             найти родителя tt-grp-sum6;
             увеличить level5;
           end .
        */
        find first tt-grp-sum6 where rowid(tt-grp-sum6) = rowid(tt-grp-sum4) no-error.
        repeat while available tt-grp-sum6:
          /* для первой итерации tt-grp-sum4.grp-lvl = v-level5;
             для последующих итераций это (родитель_N от tt-grp-sum4).grp-lvl = v-level5 + N;
             начиная со второй итерации grp-lvl присваивается только если grp-lvl < v-level5
          */
          if tt-grp-sum6.grp-lvl < v-level5 then tt-grp-sum6.grp-lvl = v-level5.
          /* далее tt-grp-sum5 ставится на текущую строку, чтобы от неё спозиционировать tt-grp-sum6 */
          find first tt-grp-sum5 where rowid(tt-grp-sum5) = rowid(tt-grp-sum6) no-error.
          if tt-grp-sum5.upper-code > 0 then do:
            v-level5 = v-level5 + 1.
            find first tt-grp-sum6 where tt-grp-sum6.obj-code = tt-grp-sum5.obj-code
                                     and tt-grp-sum6.pay-code = tt-grp-sum5.pay-code
                                     and tt-grp-sum6.curr-code = tt-grp-sum5.curr-code
                                     and tt-grp-sum6.def-code = tt-grp-sum5.upper-code
                                     and tt-grp-sum6.obj-type = tt-grp-sum5.obj-type no-error.
          end.
          else leave.  
        end. /* end_of repeat available tt-grp-sum6 */
      end. /* end_of tt-grp-sum4.grp-lvl < v-level5 */ 
    end. /* end_of available tt-grp-sum4 */
    else do:
      v-has-up-lvl = true.
      find first buf-gds-grp no-lock where buf-gds-grp.node-code = tt-grp-sum.upper-code no-error.
      if available buf-gds-grp then assign
        v-grp-name = buf-gds-grp.node-name
        v-upr-code = buf-gds-grp.upper-code
      .
      else assign
        v-grp-name = ""
        v-upr-code = 0
      .
      create tt-grp-sum4.
      assign
        tt-grp-sum4.obj-type  = tt-grp-sum.obj-type
        tt-grp-sum4.obj-code  = tt-grp-sum.obj-code
        tt-grp-sum4.obj-name  = tt-grp-sum.obj-name
        tt-grp-sum4.pay-code  = tt-grp-sum.pay-code
        tt-grp-sum4.pay-name  = tt-grp-sum.pay-name
        tt-grp-sum4.curr-code = tt-grp-sum.curr-code
        tt-grp-sum4.curr-name = tt-grp-sum.curr-name
        tt-grp-sum4.is-group  = true
        tt-grp-sum4.upper-code = v-upr-code
        tt-grp-sum4.grp-lvl    = v-level + 1
        tt-grp-sum4.def-code   = tt-grp-sum.upper-code
        tt-grp-sum4.def-name   = v-grp-name
        tt-grp-sum4.def-level = 0
        tt-grp-sum4.tot-r-b     = 0
        tt-grp-sum4.chk-cnt-all = 0
        tt-grp-sum4.chk-cnt-nf  = 0
      .
    end.
  end. /* end_of for_each tt-grp-sum */
  if not v-has-up-lvl then leave.
end.

  for each tt-grp-sum where tt-grp-sum.upper-code = 0 :
    run grp-agregator in this-procedure
    ( tt-grp-sum.obj-code
    , tt-grp-sum.obj-type
    , tt-grp-sum.pay-code
    , tt-grp-sum.curr-code
    , tt-grp-sum.upper-code
    , output v-tot-r-b
    ) .
    tt-grp-sum.tot-r-b = v-tot-r-b .
    for each help-chk where help-chk.obj-code = tt-grp-sum.obj-code
                        and help-chk.pay-code = tt-grp-sum.pay-code
                        and help-chk.curr-code = tt-grp-sum.curr-code
                        and help-chk.group-chk = tt-grp-sum.def-code :
      tt-grp-sum.chk-cnt-all = tt-grp-sum.chk-cnt-all + 1.
      delete help-chk.
    end.
  end .    


      
/* сумма по виду оплаты */
define work-table w-pay-sum no-undo
  field obj-code  as integer
  field pay-code  as integer
  field curr-code as integer
  field tot-r-b   as decimal decimals 10
.

/* суммы по видам оплат после того, как закончено сложение корневых групп */
for each tt-grp-sum where tt-grp-sum.upper-code = 0
break by tt-grp-sum.obj-code
      by tt-grp-sum.pay-code
      by tt-grp-sum.curr-code:
  if first-of (tt-grp-sum.curr-code) then do:        
    create w-pay-sum.
    assign
      w-pay-sum.obj-code  = tt-grp-sum.obj-code
      w-pay-sum.pay-code  = tt-grp-sum.pay-code
      w-pay-sum.curr-code = tt-grp-sum.curr-code
      w-pay-sum.tot-r-b   = 0
    .
  end.
  w-pay-sum.tot-r-b = w-pay-sum.tot-r-b + tt-grp-sum.tot-r-b.
end.



  run waitfram-show in this-procedure ("вывод на печать") .
  run waitfram-hide in this-procedure .
  run prn-lib-get-report-name in this-procedure ( input parParentProc, output v-report-name ).
  assign
    v-file-name-rep-htm = v-report-name + ".html"
    v-vsex-cas = IF cas-num = 0 then "ВСЕХ КАСС" ELSE ("КАССЫ " + string(cas-num))
    v-avg-chk  = if ChkAmount > 0 then round(                  
      (if v-curr-r-b = {&r-b-rubl} then AllDay-RublSum else AllDay-BaseSum)  /  ChkAmount
                                             , 2 ) else 0 
    date_string     = cur-time-print()
    sale-price-type = if v-curr-r-b = {&r-b-base} then
      &if "{1}" = "rubl" &then "{&abbr_rubley}" &else base-type &endif
                                                  else "{&abbr_rubley}"
    ObjAmount = 0
  .
&if "{2}" = "time" &then
  v-times = "" .
  IF T-time then
    FOR EACH times No-LOCK :
      v-times = v-times + times + {&space-char} .
    END .
&endif

define variable v-str4   as character no-undo . /* сокращенный вариант str4 */
define variable v-count4 as integer no-undo.

  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
do: /* заголовок html-файла и заголовок таблицы */
  /* str4 содержит перечень объектов, по которым сформирован отчёт;
     выводим столько, сколько поместится в 115 симовлов */
  if length(str4) > 115 then do:
    v-str4 = entry(1, str4, {&new-line}).
    do v-count4 = 2 to num-entries(str4, {&new-line}) while length(v-str4) < 115:
      v-str4 = v-str4 + {&new-line} + entry(v-count4, str4, {&new-line}).
    end. 
    v-str4 = v-str4 + {&new-line} + "...".
  end.
  else v-str4 = str4.  
  put stream OutStr-html unformatted
    "<!DOCTYPE HTML>" skip
    '<html>' skip
    '<head>' skip
    '  <meta charset="utf-8">' skip
    '  <style type="text/css">' skip
    '      table ~{border-collapse: collapse~;~}' skip
    '      tbody td, th ~{border: 1px solid black~; height: 14px~;~}' skip
    '      tbody td:nth-child(3), tbody td:nth-child(4), tbody td:nth-child(5) ~{text-align: right~; padding-right: 4px~;~}' skip
    '      tbody tr[level="1"] td ~{font-weight: bold~;~}' skip
    '      tbody tr[level="3"] td:nth-child(1) ~{padding-left: 30px~;~}' skip
    '      tbody tr[level="4"] td:nth-child(1) ~{padding-left: 40px~;~}' skip
    '      tbody tr[level="5"] td ~{display: none~;~}' skip
    '      tbody tr[level="5"] td:nth-child(1) ~{padding-left: 50px~;~}' skip
    '      tbody tr[level="6"] td ~{display: none~;~}' skip
    '      tbody tr[level="6"] td:nth-child(1) ~{padding-left: 60px~;~}' skip
    '      tbody tr[level="7"] td ~{display: none~;~}' skip
    '      tbody tr[level="7"] td:nth-child(1) ~{padding-left: 70px~;~}' skip
    '      tbody tr[level="8"] td ~{display: none~;~}' skip
    '      tbody tr[level="8"] td:nth-child(1) ~{padding-left: 80px~;~}' skip
    '      tfoot td ~{height: 14px~;~}' skip
    '      .sumtotal ~{text-align: right~; padding-right: 4px~;~}' skip
    '  </style>' skip
    '</head>' skip
    '<body>' skip
    '<TABLE name="exp' + string(day(x-date-start), "99") + 'g" fit_to_page="true" orientation="portrait" repeat_rows="1:4" outline_below="false">' skip
    /* Не отображать "0" в числовых ячейках: <table hide_zero="true"> */
    /* Направление раскрытия групп: по умолчанию группы раскрываются вниз. Чтобы это поменять: <table outline_below="true"> */    
    '<thead>' skip
    
    /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
    /* row 1 */
    '  <tr class="set_columns">' skip
    '    <td style="width: 103px;"></td>' skip /* код вида оплаты, код группы, код товара */
    '    <td style="width: 336px;"></td>' skip /* наименование вида оплаты, группы, товара */
    '    <td style="width: 93px;"></td>' skip /* tot-r-b */
    '    <td style="width: 49px;"></td>' skip /* benefits.pcnt     "% от суммы" format "->>>>9.99%" */
    '    <td style="width: 41px;"></td>' skip /* chk-cnt-all - chk-cnt-nf  "кол-во фискальных чеков" format ">>>>9" */
    '  </tr>' skip


    /* Теперь шапка таблицы */
    /* row 2 */
    '  <tr>' skip
    '    <td colspan="5">' + date_string + '</td>' skip
    '  </tr>' skip
    /* row 3 */
    '  <tr>' skip
    '    <td colspan="5">ОТЧЕТ  О  ВЫРУЧКЕ ' + str1 + '<br />' skip
         v-str4 + '<br />( сформирован по ВСЕМ ЧЕКАМ '
         + (IF NotInc then v-vsex-cas + ", включая невошедшие в отчеты о продажах" else v-vsex-cas)
         + ' )'
         + '<br />' skip
         substitute("( всего чеков : &1, в среднем &2 &3 / чек )",  ChkAmount,  v-avg-chk,  sale-price-type  )
  .
&if "{2}" = "time" &then
  IF T-time then put stream OutStr-html unformatted '<br />' skip 'Выборочно по времени: ' + v-times .
&endif
  put stream OutStr-html unformatted
         '</td>' skip
    '  </tr>' skip
    '</thead>' skip
    
    /* Здесь начинается таблица отчета */
    '<tbody>' skip
    
    /* Первые строки – шапка табоицы с тэгами th */
    /* row 4 */
    '  <tr>' skip
    '    <th>Код</th>' skip
    '    <th>Наименование</th>' skip
    '    <th>Сумма в ' (if v-curr-r-b = {&r-b-base} then 'Б.Вал.' else '{&abbr_rublyah}') '</th>' skip
    '    <th>~% от суммы</th>' skip
    '    <th>Кол-во фиск. чеков</th>' skip
    '  </tr>' skip    
  .
end. /* end_of заголовок html-файла и заголовок таблицы */  


define work-table w-upr-stack no-undo
  field flevel   as integer
  field def-code as integer
  field tot-r-b  as decimal decimals 2
.

FOR EACH obj-list WHERE obj-list.obj-type = {&shop},
    EACH all-days_sum WHERE
          all-days_sum.obj-type = obj-list.obj-type AND
          all-days_sum.obj-code = obj-list.obj-code
BREAK BY obj-list.obj-type
      BY obj-list.obj-code :
  ACCUMULATE
    all-days_sum.tot-base ( TOTAL )
    all-days_sum.tot-rubl ( TOTAL )
    all-days_sum.tot-r-b ( TOTAL )
    all-days_sum.chk-cnt-all ( TOTAL )
    all-days_sum.chk-cnt-nf  ( TOTAL )
  .
  ObjAmount = ObjAmount + 1.

  for each tt-grp-sum
     where tt-grp-sum.obj-code = obj-list.obj-code
       and tt-grp-sum.obj-type = obj-list.obj-type
       and tt-grp-sum.upper-code = 0
  break by tt-grp-sum.pay-code
        by tt-grp-sum.curr-code
        by tt-grp-sum.def-code:
          
    if first( tt-grp-sum.pay-code ) then do:
      /* итог по одному магазину за весь период */
      put stream OutStr-html unformatted
        '  <tr level="1">'
        '<td>' + tt-grp-sum.obj-type + '</td>'
        '<td>' + tt-grp-sum.obj-name + '</td>'
        substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(all-days_sum.tot-r-b,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        substitute(  '<td num="0" val="&1">&1</td>',  all-days_sum.chk-cnt-all - all-days_sum.chk-cnt-nf  )
        '</tr>' skip
      .
    end.

    if first-of(tt-grp-sum.curr-code) then do:
      /* итог по виду платежа с каждой из валют */
      find first w-pay-sum where w-pay-sum.obj-code  = tt-grp-sum.obj-code
                             and w-pay-sum.pay-code  = tt-grp-sum.pay-code
                             and w-pay-sum.curr-code = tt-grp-sum.curr-code no-error.
      v-pcnt = if available w-pay-sum then round( w-pay-sum.tot-r-b / all-days_sum.tot-r-b * 100 , 2 ) else 0.
      put stream OutStr-html unformatted
        '  <tr level="2">'
        '<td></td>'
        '<td style="padding-left: 10px">' + tt-grp-sum.pay-name + '</td>'
        '<td></td>'
        substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(v-pcnt,"->>9.99",2)  )
        '<td></td>'
        '</tr>' skip
      .
    end.           
           
    /* все баркоды одного товара в пределах вида платежа в пределах валюты:
       - tt-grp-sum создаётся только на группы и товары;
       - пройти верхний уровень групп и вложения по каждой группе
    */
    v-level = 3.
    v-pcnt = round( tt-grp-sum.tot-r-b / all-days_sum.tot-r-b * 100 , 2 ) .
    put stream OutStr-html unformatted
      substitute('  <tr level="&1">', v-level)
      substitute('<td>&1</td>', tt-grp-sum.def-code)
      '<td>' + tt-grp-sum.def-name + '</td>'
      substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(tt-grp-sum.tot-r-b,"->>>>>>>>>>>9.99",2)  )
      substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(v-pcnt,"->>9.99",2)  )
      substitute(  '<td num="0" val="&1">&1</td>',  tt-grp-sum.chk-cnt-all - tt-grp-sum.chk-cnt-nf  )
      '</tr>' skip
    .

    
    /* далее - рекурсия дочерних элементов внутри tt-grp-sum.def-name;
       реализована циклом, чтобы не втаскивать в инклюд рекурсивный вызов */
    create w-upr-stack.
    assign
      w-upr-stack.flevel   = v-level
      w-upr-stack.def-code = tt-grp-sum.def-code
      w-upr-stack.tot-r-b  = tt-grp-sum.tot-r-b
    .
    repeat:
      find first tt-grp-sum4 use-index dc
           where tt-grp-sum4.obj-code = obj-list.obj-code
             and tt-grp-sum4.obj-type = obj-list.obj-type
             and tt-grp-sum4.pay-code = tt-grp-sum.pay-code
             and tt-grp-sum4.curr-code = tt-grp-sum.curr-code
             and tt-grp-sum4.upper-code = w-upr-stack.def-code no-error.
      if available tt-grp-sum4 then do:
        v-pcnt = round( tt-grp-sum4.tot-r-b / all-days_sum.tot-r-b * 100 , 2 ) .
        put stream OutStr-html unformatted
          /* Excel: можно создать структуру, включающую до восьми уровней, по одному для каждой группы */
          substitute('  <tr level="&1">',  minimum(w-upr-stack.flevel + 1, 8)  )
          substitute('<td>&1</td>',  tt-grp-sum4.def-code)
          '<td>' + tt-grp-sum4.def-name + '</td>'
          substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(tt-grp-sum4.tot-r-b,"->>>>>>>>>>>9.99",2)  )
          substitute(  '<td num="0.00" val="&1">&1</td>',  fnc-convert-dot-to-colon(v-pcnt,"->>9.99",2)  )
          substitute(  '<td num="0" val="&1">&1</td>',  tt-grp-sum4.chk-cnt-all - tt-grp-sum4.chk-cnt-nf  )
          '</tr>' skip
        .
        if tt-grp-sum4.is-group then do:
          v-level = w-upr-stack.flevel + 1.
          create w-upr-stack.
          assign
            w-upr-stack.flevel   = v-level
            w-upr-stack.def-code = tt-grp-sum4.def-code
            w-upr-stack.tot-r-b  = tt-grp-sum4.tot-r-b
          .
        end.
        delete tt-grp-sum4.
      end.
      else do:
        v-level = w-upr-stack.flevel - 1.
        if v-level < 3 then leave.
        delete w-upr-stack.
        find first w-upr-stack where w-upr-stack.flevel = v-level.
      end.
    end. /* end_of repeat */
  end. /* end_of for_each tt-grp-sum */
  

  /* итого по всем магазинам */
  if last( obj-list.obj-code ) AND ( ObjAmount > 1 ) then do:
    put stream OutStr-html unformatted
      '  <tr level="1"><td colspan="2">ИТОГО по всем</td>'
      substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM TOTAL all-days_sum.tot-r-b,"->>>>>>>>>>>9.99",2)  )
      '<td></td>'
      substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',
                   (ACCUM TOTAL all-days_sum.chk-cnt-all) - (ACCUM TOTAL all-days_sum.chk-cnt-nf)
                )
      '</tr>' skip
    .
  end.
END.    /* FOR EACH obj-list ... */

/* для нескольких магазинов разбивка выручки по видам оплат */
if  ObjAmount > 1  then do:
  for each tt-gds-sum break by tt-gds-sum.pay-code:
    ACCUMULATE
      tt-gds-sum.tot-r-b  ( SUB-TOTAL BY tt-gds-sum.pay-code )
    .
    if last-of( tt-gds-sum.pay-code ) AND
       ( ACCUM SUB-TOTAL BY tt-gds-sum.pay-code tt-gds-sum.tot-r-b ) <> 0 then do:
      /* в одном чеке может присутствовать несколько товаров, т.е. будет несколько записей с одним doc-code;
         нам нужно количество записей, в которых doc-code не повторяется */
      v-chk-count = 0.
      for each ben-chk-count
         where ben-chk-count.pay-code = tt-gds-sum.pay-code
      break by ben-chk-count.doc-code:
        if first-of (ben-chk-count.doc-code) then v-chk-count = v-chk-count + 1.
      end.
      
      /* прощё ещё раз найти pay-name, чем тащить его от бар-кодов во всех записях tt-gds-sum */
      FIND FIRST buf-cash-pay no-lock
           WHERE buf-cash-pay.cdpay-code = tt-gds-sum.pay-code
             AND buf-cash-pay.curr-code  = tt-gds-sum.curr-code NO-ERROR.
      v-pay-name = if available buf-cash-pay then buf-cash-pay.obj-name else "Неопознанная оплата".            
    
      put stream OutStr-html unformatted
        substitute(  '  <tr level="2"><td colspan="2">/итого по &1</td>',  v-pay-name  ) 
        substitute(  '<td num="0.00" val="&1" class="sumtotal">&1</td>',  fnc-convert-dot-to-colon(ACCUM SUB-TOTAL BY tt-gds-sum.pay-code tt-gds-sum.tot-r-b,"->>>>>>>>>>>9.99",2)  )
        '<td></td>'
        substitute(  '<td num="0" val="&1" class="sumtotal">&1</td>',  v-chk-count  )
        '</tr>' skip
      .
    end.
  end.
end.


put stream OutStr-html unformatted
  '</tbody>' skip
  '<tfoot>' skip
.

/* для одного магазина блок с подписями ответственных лиц */
if  ObjAmount < 2 then do:
  put stream OutStr-html unformatted
    '  <tr><td colspan="5"><br /></td></tr>' skip
    '  <tr><td colspan="2">Директор _______________</td><td colspan="3">Старший продавец ______________</td></tr>' skip
    '  <tr><td colspan="5"><br /></td></tr>' skip
    '  <tr><td colspan="2">Бухгалтер ______________</td><td colspan="3">Кассир ________________________</td></tr>' skip
  .
end.

put stream OutStr-html unformatted
  '</tfoot>' skip
  '</table>' skip
  '</body>' skip
  '</html>' skip
.
output stream OutStr-html close.
run prn-lib-reportviewer in this-procedure (
    input this-procedure
    ,input v-file-name-rep-htm
    ,input "" 
    ) no-error.
if error-status:error then
do:
    message return-value view-as alert-box.
    return .
end.     


/* $Workfile$ e n d */