block-level on error undo, throw.
/*
$Revision: e8ddcb64563b, 3202, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:28 $
$Workfile: r-schk.p $
$Archive: rep/r-schk.p $
Отчет по всем сухим чекам продажи и возврата с топливом
Автор: 
Дата создания: 
Creation date: 
*/

def var vss-revision as character no-undo init "$Revision: e8ddcb64563b, 3202, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-schk.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-schk.p $":U .
def var vss-description as character no-undo init "Отчет по всем сухим чекам продажи и возврата с топливом".

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-page1.i     }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ gbl/lastdate.i    }
{ gbl/cur-time.i    }
{ gbl/waitfram.i }
{ gbl/sys-time.i }   
{ ref/chk-type-desc.i }   
{ str/lib-trn.i }   
{cmp/str-glbl.i}
{ref/gds-attr.i}
{ str/is-gas.i }
{ ref/grplibfn.i }
define buffer buf_clients        for ub.clients .
define buffer previous-shift-obj for ub.shift-obj. 

define variable v-file-name-rep-htm as character no-undo.
define variable v-gds               as character no-undo.

define variable var-report-num      as int       no-undo.

define variable gds_chk             as int       no-undo.
define variable gds_chk1            as character no-undo.
define variable produkt             as character no-undo.
define variable t-chk-chr           as character no-undo.     /* тип чека тхт*/
define variable time-chk-chr        as character no-undo.  /* время чека txt */
define variable kassir-chr          as character no-undo. 
define variable trnz-chr            as character no-undo. 
define variable kd-tv               as character no-undo.       /*код товара */
define variable vCHFlag1            as character no-undo.    /*признак сухого чека    */
define variable vCHMgrKey           as character no-undo.   /*ключ оператора*/
define variable vozvrtrn            as character no-undo.    /*возврат по транзакции */

define variable opl-chr             as character no-undo.     /*тип оплаты*/
define variable opl-sum             as character no-undo.     /*сумма по типу опл*/

define variable o-qnt-chk           as DECIMAL   no-undo.     /* Всего сухих чеков по объекту */
define variable o-qnt-pchk          as int       no-undo.        /* Всего сухих чеков продажи по объекту */
define variable o-qnt-vchk          as int       no-undo.        /* Всего сухих чеков возврата по объекту */
define variable o-sum-ob            as DECIMAL   no-undo.      /* Сумма по обороту по объекту */
define variable o-sum-it            as DECIMAL   no-undo.     /* Итоговая сумма по объекту */

define variable qnt-chk             as int       no-undo.       /* Всего сухих чеков */
define variable qnt-pchk            as int       no-undo.      /* Всего сухих чеков покупки */
define variable qnt-vchk            as int       no-undo.      /* Всего сухих чеков возврата */

define variable qnt-vschk-all       as int       no-undo.  /* Всего сухих чеков возврата*/
define variable qnt-vcchk-all       as int       no-undo.  /* Всего чеков частично возврата */
define variable qnt-vnchk-all       as int       no-undo.  /* Всего возвратов по номеру чека */ 
define variable qnt-vpchk-all       as int       no-undo.  /* Всего возвратов полных по транзакции */ 

define variable o-qnt-vschk-all     as int       no-undo.  /* Всего сухих чеков возврата по объекту*/
define variable o-qnt-vcchk-all     as int       no-undo.  /* Всего чеков частично возврата  по объекту*/
define variable o-qnt-vnchk-all     as int       no-undo.  /* Всего возвратов по номеру чека  по объекту*/ 
define variable o-qnt-vpchk-all     as int       no-undo.  /* Всего возвратов полных по транзакции  по объекту*/ 

define variable pr-qnt-vp           as int       no-undo.    /* % чеков возврата к общему количеству чеков продажи */
define variable pr-qnt-co           as int       no-undo.    /* % чеков частичного возврата к общему */
define variable pr-qnt-pvov         as int       no-undo.  /* % всех возвратов по номеру полных  к общему колву возврата*/
define variable pr-qnt-suhob        as int       no-undo. /* % всех сухих возвратов  к общему колву возврата*/
define variable pr-qnt-ostv         as int       no-undo.  /* % остальных  возвратов  к общему колву возврата*/
define variable pr-qnt-ostp         as int       no-undo.  /* % остальных  возвратов  к общему колву продаж*/

define variable sum-ob              as DECIMAL   no-undo.        /* Сумма по обороту */
define variable sum-it              as DECIMAL   no-undo.        /* Итоговая сумма */

define variable varhost-code        like ub.trn-doc.host-code no-undo.
define variable v-host-name         as character no-undo. /*название фирмы*/
define variable v-obj-name          as character no-undo. /*АЗС*/

define variable var-prev-shift-date like ub.shift-obj.shift-date no-undo.
define variable var-prev-shift-num  like ub.shift-obj.shift-num no-undo.
define variable var-shift-staff     like ub.shift-staff.name no-undo.
define variable v-period            as character no-undo .

define temp-table tt-goods no-undo like ub.goods
   field b-code as integer.

/* procedure create-tt-goods : */
define buffer buf_goods   for ub.goods.
define buffer buf_cli-gds for ub.cli-gds.
define variable v-gds-counter   as integer   no-undo.
define variable is-petrol       as logical   no-undo .
define variable is-pieces       as logical   no-undo .

define variable v-curr-grp-name as character no-undo .
define variable v-host-code     like ub.clients.host-code no-undo .
do on error undo, return error return-value:
   empty temp-table tt-goods.
   case x-SelectGood:
      when {&g-all} then 
         do: /* все товары */
            v-gds = 'Все'.
            for each buf_goods no-lock where
               buf_goods.stts = 0:
               { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
               if is-petrol = yes 
                  and not is-gas(buf_goods.gds-code)   then 
               do: 
                  create tt-goods.
                  buffer-copy buf_goods to tt-goods.
                  find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                  IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.
                  v-gds-counter = v-gds-counter + 1.

               END.
            end.
         end.
      when {&g-grp} then 
         do: /* товары по группам  */
            v-gds = 'Группы товаров'.
            for each tmp#grp no-lock:
               run grplib-get-full-name in this-procedure(input tmp#grp.node-code, output v-curr-grp-name).
               for each buf_goods no-lock where buf_goods.grp-name begins v-curr-grp-name:
                  { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
                  if is-petrol = yes 
                     and not is-gas(buf_goods.gds-code)   then 
                  do:                  
                     find first tt-goods no-lock
                        where tt-goods.artic = buf_goods.artic
                        and tt-goods.prod-type = buf_goods.prod-type
                        and tt-goods.prod-code = buf_goods.prod-code no-error.
                     if not available tt-goods then 
                     do:
                        create tt-goods.
                        buffer-copy buf_goods to tt-goods.
                        find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                        IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.
                        v-gds-counter = v-gds-counter + 1.
                     end.
                  end.
               end.
            end.
         end.
      when {&g-prod} then 
         do: /* товары по производителю */
            v-gds = 'Производители'.
            for each buf_goods no-lock
               where buf_goods.stts = 0 ,
               each buf_cli-gds no-lock
               where buf_cli-gds.prod-type = buf_goods.prod-type
               and buf_cli-gds.prod-code = buf_goods.prod-code
               and buf_cli-gds.artic = buf_goods.artic,
               first g#cli where g#cli.obj-type = buf_cli-gds.cli-type
               and g#cli.obj-code = buf_cli-gds.cli-code:
               { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
               if is-petrol = yes 
                  and not is-gas(buf_goods.gds-code)   then 
               do:
                  find first tt-goods no-lock
                     where tt-goods.prod-type = buf_goods.prod-type
                     and tt-goods.prod-code = buf_goods.prod-code
                     and tt-goods.artic = buf_goods.artic no-error.
                  if not available tt-goods then 
                  do:
                     create tt-goods.
                     buffer-copy buf_goods to tt-goods no-error.
                     find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                     IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.
                     v-gds-counter = v-gds-counter + 1.
                  end.
               end.
            end.
         end.
      when {&g-choice} or 
      when {&g-one} then 
         do: /* товары выборочно */

            v-gds = 'Выборочно'.
            for each gds-list:
               find first buf_goods no-lock
                  where buf_goods.gds-code = gds-list.gds-code no-error.
               if available buf_goods then 
               do:
                  { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
                  if is-petrol = yes 
                     and not is-gas(buf_goods.gds-code)   then 
                  do:                   
                     create tt-goods.
                     buffer-copy buf_goods to tt-goods.
                     find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                     IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.

                     v-gds-counter = v-gds-counter + 1.
                  end.
               end.
            end.
         end.
      when {&g-grp-prod} then 
         do: /* группа и производитель */
            v-gds = 'Группы товаров и Производители'.
            for each tmp#grp no-lock:
               run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
               for each buf_goods no-lock where buf_goods.grp-name begins v-curr-grp-name:
                  { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
                  if is-petrol = yes 
                     and not is-gas(buf_goods.gds-code)   then 
                  do: 
                     find first tt-goods no-lock
                        where tt-goods.artic = buf_goods.artic
                        and tt-goods.prod-type = buf_goods.prod-type
                        and tt-goods.prod-code = buf_goods.prod-code no-error.
                     if not available tt-goods then 
                     do:
                        create tt-goods.
                        buffer-copy buf_goods to tt-goods no-error.
                        find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                        IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.
                        v-gds-counter = v-gds-counter + 1.
                     end.
                  end.
               end.
            end.
            for each buf_goods no-lock
               where buf_goods.stts = 0,
               each buf_cli-gds no-lock
               where buf_cli-gds.prod-type = buf_goods.prod-type
               and buf_cli-gds.prod-code = buf_goods.prod-code
               and buf_cli-gds.artic = buf_goods.artic,
               first g#cli where g#cli.obj-type = buf_cli-gds.cli-type
               and g#cli.obj-code = buf_cli-gds.cli-code:
               { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
               if is-petrol = yes 
                  and not is-gas(buf_goods.gds-code)   then 
               do: 
                  find first tt-goods no-lock
                     where tt-goods.prod-type = buf_goods.prod-type
                     and tt-goods.prod-code = buf_goods.prod-code
                     and tt-goods.artic = buf_goods.artic no-error.
                  if not available tt-goods then 
                  do:
                     create tt-goods.
                     buffer-copy buf_goods to tt-goods no-error.
                     find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
                     IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.
                     v-gds-counter = v-gds-counter + 1.
                  end.
               end.
            end.
         end.
   end case.
end.
/* end procedure. */ /* create-tt-goods */

/* { gbl/hostcode.i parobj-type parobj-code varhost-code} */

/*Своя фирма*/
find first buf_clients no-lock where buf_clients.obj-type = {&cmp} NO-ERROR.
assign
   v-host-name = buf_clients.obj-name
   .


FIND FIRST tt-goods no-lock no-error .
IF NOT AVAILABLE tt-goods THEN 
DO:
   MESSAGE ' Не выбран товар ! Будет использован фильр по умолчанию: Все виды топлива, кроме КПГ ! '  VIEW-AS ALERT-BOX . 
   
   /* заполнение табл для фильтра по умолчанию */  
   for each buf_goods no-lock:
      { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code is-petrol is-pieces no-error }
      if is-petrol = yes 
         and not is-gas(buf_goods.gds-code)   then 
      do: 
         create tt-goods.
         buffer-copy buf_goods to tt-goods.
         find first bar-code where bar-code.gds-code eq buf_goods.gds-code no-lock no-error.
         IF AVAILABLE bar-code THEN  tt-goods.b-code = bar-code.b-code.
         v-gds-counter = v-gds-counter + 1.

      END.
   end.

END.


/* return error. */

DEFINE VARIABLE spis_obj as char no-undo.
FOR EACH obj-list NO-LOCK:
   spis_obj = spis_obj + ' ' + obj-list.obj-name.
END.

define stream OutStr-html.
run get-report-num in my-handle ( output var-report-num ). 
v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(var-report-num) + ".html".

/* Создаём временные файлы. */

output to value(v-file-name-rep-htm).
output close.
   
/*Шапка*/
def var v-first-time as int  no-undo.
def var v-first-date as date no-undo.
def var v-last-date  as date no-undo.
def var v-last-time  as int  no-undo.   

output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.

put stream OutStr-html unformatted
{ rep/htmlhead.i }
   .
      /*      v-period = "c №" + string(x-Shift-Start) + " " + string(x-Date-Start, "99.99.9999") + ' по №' + string(x-Shift-End) + " " + string(X-date-End, "99.99.9999") .*/
      v-period = "с " + string(x-Date-Start, "99.99.9999") + ' по ' + string(X-date-End, "99.99.9999") .
      run shapka .
FOR EACH obj-list NO-LOCK:         

   if X-tog-shift then 
   do:
      /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
      run rep/rpychk0.p ( input "r-shftc2"
         ,input obj-list.obj-type
         ,input obj-list.obj-code
         ,input ? /*p-date-from*/
         ,input ? /*p-date-to*/
         ,input X-date-start /*p-shift-date-from*/
         ,input X-date-end /*p-shift-date-to*/
         ,input X-shift-start /*X-shift-start*/
         ,input X-shift-end /*X-shift-end*/
         ,input ? /*p-inkas-code*/
         ).
      
      FOR EACH ub.chk-doc where ub.chk-doc.obj-code = obj-list.obj-code 
         and ub.chk-doc.shift-date >= X-date-Start 
         and ub.chk-doc.shift-date <= x-Date-End  
         and (ub.chk-doc.chk-type = 1 or ub.chk-doc.chk-type = 6) 
         and ub.chk-doc.out-code <> ? NO-LOCK:
         if ub.chk-doc.shift-date = X-date-Start and ub.chk-doc.shift-num < X-Shift-Start then next .
         if ub.chk-doc.shift-date = X-date-End   and ub.chk-doc.shift-num > X-Shift-End then next .
         run proc-report .
      end.      
   end.
   else 
   do:
      /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
      run rep/rpychk0.p ( input "r-date"
         ,input obj-list.obj-type
         ,input obj-list.obj-code
         ,input ? /*p-date-from*/
         ,input ? /*p-date-to*/
         ,input X-date-start /*p-shift-date-from*/
         ,input X-date-end /*p-shift-date-to*/
         ,input ? /*X-shift-start*/
         ,input ? /*X-shift-end*/
         ,input ? /*p-inkas-code*/
         ).    
                                                    
      FOR EACH chk-doc where chk-doc.obj-code = obj-list.obj-code 
         and chk-doc.chk-date >= x-Date-Start 
         and chk-doc.chk-date <= x-Date-End  
         and (chk-doc.chk-type = 1 or chk-doc.chk-type = 6) 
         and chk-doc.out-code <> ? NO-LOCK:
         run proc-report .   
      end.
   end.   
   run itog .
end.

procedure shapka:
   put stream OutStr-html unformatted
      '<body>' skip
      /*Первая таблица*/
      '<TABLE name="Отчет по сухим чекам"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
      .

   put stream OutStr-html unformatted
      '<tr class="set_columns">' skip
      '<td style="width:200px"></td>' skip
      '<td style="width:160px"></td>' skip
      '<td style="width:130px"></td>' skip
      '<td style="width:60px"></td>' skip
      '<td style="width:180px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:180px"></td>' skip
      '<td style="width:80px"></td>' skip
      '<td style="width:130px"></td>' skip
      '<td style="width:100px"></td>' skip
      '<td style="width:150px"></td>' skip
      '<td style="width:75px"></td>' skip
      '<td style="width:65px"></td>' skip
      '<td style="width:80px"></td>' skip
      '<td style="width:85px"></td>' skip
      '<td style="width:85px"></td>' skip
      '<td style="width:85px"></td>' skip
      '<td style="width:120px"></td>' skip
      '<td style="width:100px"></td>' skip
      '</tr>' skip
      .   
   put stream OutStr-html unformatted                        
      '<tr><td colspan="19">' + string(v-host-name) + '</td></tr>' skip
      '<tr><td colspan="19" style="text-align:left;">За период ' + v-period + '</td></tr>' skip
      '<tr><td colspan="19" style="text-align:left;">Выбор объекта:</td></tr>' skip
      '<tr><td colspan="19" style="text-align:left;">' + string(spis_obj) + '</td></tr>' skip
      '<tr><td colspan="19" style="text-align:left;">Дата формирования ' + string(now,"99.99.99 HH:MM:SS") + ' </td></tr>' skip
      '<tr><td colspan="19"  style="font-size:14px;font-weight:bold;">Отчет по всем сухим чекам продажи и возврата с топливом</td></tr>' skip
      '<tr><td colspan="5" style="font-size:11px; text-align: left;"></td>' skip
      '<td colspan="14"></td></tr>' skip
      '</thead>' skip
      
      '<tbody>' skip /* Здесь начинается таблица отчета */
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th style="text-align: center;">ПНПО</th>' skip
      '<th style="text-align: center;">Наименование объекта</th>' skip
      '<th style="text-align: center;">Номер кассы</th>' skip
      '<th style="text-align: center;">Смена</th>' skip
      '<th style="text-align: center;">Дата смены</th>' skip
      '<th style="text-align: center;">Тип чека</th>' skip
      '<th style="text-align: center;">Номер чека</th>' skip
      '<th style="text-align: center;">Создан в ТН</th>' skip
      '<th style="text-align: center;">Дата чека</th>' skip
      '<th style="text-align: center;">Время чека</th>' skip
      '<th style="text-align: center;">Продукт</th>'skip
      '<th style="text-align: center;">ТРК</th>' skip
      '<th style="text-align: center;">Пистолет</th>' skip
      '<th style="text-align: center;">Кол-во, л.</th>' skip
      '<th style="text-align: center;">Цена за ед.</th>' skip
      '<th style="text-align: center;">Сумма по чеку</th>' skip
      '<th style="text-align: center;">Сумма по типу оплаты</th>' skip
      '<th style="text-align: center;">Тип оплаты</th>' skip
      '<th style="text-align: center;">ФИО кассира</th>' skip
      '</tr>' skip
      .   
end procedure .

procedure proc-report:
   define variable handmade as character no-undo.  /* добавлен вручную */
   handmade = '-'. 
   FIND FIRST c-chk-doc WHERE c-chk-doc.doc-code = chk-doc.doc-code AND c-chk-doc.is-add = yes NO-LOCK NO-ERROR.
   IF AVAILABLE c-chk-doc THEN handmade = '+'. 

   FOR EACH  chk-gds where chk-gds.doc-code = chk-doc.doc-code no-lock:
      if chk-doc.chk-type = 1 and chk-gds.pass-gds <> 1 then next .
      if chk-doc.chk-type = 6 then do:
      find first chk-doc-attr where chk-doc-attr.doc-code = chk-doc.doc-code
         and chk-doc-attr.attr-code = 'CHFlag1' no-lock no-error.
      IF not AVAILABLE chk-doc-attr or chk-doc-attr.attr-value <> '0' THEN next .
      end.   
        
      find first tt-goods where tt-goods.b-code = chk-gds.b-code no-error .                   /*сухой чек*/
      if not available (tt-goods) then next .
      produkt = ''.
      time-chk-chr = ''.

      /* название товара */
      produkt = TRIM(tt-goods.gds-name).

      /* кассир */
      find first person where person.psn-code = chk-doc.cashier-psn-code no-lock no-error.
      IF AVAILABLE person THEN  kassir-chr = person.name1 + ' ' + person.name2 + ' '. 
      find first clients where person.psn-code = clients.obj-code and clients.obj-type = 'чел' no-lock no-error.
      IF AVAILABLE clients THEN kassir-chr = kassir-chr + clients.obj-name.
      
      /* тип платежа*/
      /* find first chk-pay where chk-pay.doc-code = chk-doc.doc-code no-lock no-error.
      IF AVAILABLE chk-pay THEN DO:
        opl-sum = tot-sum.
        find first cash-pay where cash-pay.cdpay-code = chk-pay.pay-code no-lock no-error.
        IF AVAILABLE cash-pay THEN opl-chr = cash-pay.obj-name.
      END. */
      /* IF chk-gds.time-oper <> ? THEN time-chk-chr = string(chk-gds.time-oper, "HH:MM").    */     /* время чека */

      time-chk-chr = string(chk-doc.chk-time, "HH:MM").
  
 
      t-chk-chr = ENTRY(LOOKUP(string(chk-doc.chk-type), {&CHK_CODE_LIST}),{&CHK_NAME_LIST}).  /* тип чека txt*/

      /* FOR EACH gds-list where gds-list.gds-code = goods.gds-code NO-LOCK:                       код товара из группы*/                      
                        
      o-qnt-chk = o-qnt-chk + 1.
      IF chk-doc.chk-type = 1 THEN o-qnt-pchk = o-qnt-pchk + 1. /* продажа */
      IF chk-doc.chk-type = 6 THEN o-qnt-vchk = o-qnt-vchk + 1. /* возврат */
      o-sum-ob = o-sum-ob + ABSOLUTE(chk-doc.tot-doc).         
      /* o-sum-ob = o-sum-ob + chk-gds.src-sum.          */ 
      o-sum-it = o-sum-it + chk-doc.tot-doc .
         
      opl-chr = ''.
      opl-sum = ''.
      /*                                                                         */
      /*            opl-sum =  string(ABSOLUTE(chk-gds.src-sum),"->>>>>>>>9.99").*/
      for EACH  chk-gds-pay where chk-gds-pay.doc-code = chk-gds.doc-code and chk-gds-pay.b-code = chk-gds.b-code no-lock :
         /* MESSAGE chk-pay.tot-sum VIEW-AS ALERT-BOX. */
         find first cash-pay where cash-pay.cdpay-code = chk-gds-pay.pay-code no-lock no-error.
         IF AVAILABLE cash-pay THEN opl-chr = cash-pay.obj-name.

         put stream OutStr-html unformatted 
            '<tr>' skip
            '<td text_wrap="true">' + v-host-name + '</td>' skip
            '<td text_wrap="true">' + obj-list.obj-name + '</td>' skip                            /*наименование объекта*/
            '<td text_wrap="true" style="text-align:center;">' + string(chk-doc.pay-desk) + '</td>' skip                             /* касса */
            '<td text_wrap="true" style="text-align:center;">' + chk-doc.shift-name + '</td>' skip                           /* смена */
            '<td text_wrap="true" style="text-align:center;">' + string(chk-doc.shift-date) + '</td>' skip                            /* дата смены */
            '<td text_wrap="true" style="text-align:center;">' + t-chk-chr + '</td>' skip                                     /* тип чека */
            '<td text_wrap="true" style="text-align:center;">' + string(chk-doc.chk-num) + ':' + string(chk-doc.z-number) + '</td>' skip          /* номер чека */
            '<td text_wrap="true" style="text-align:center;">' + handmade + '</td>' skip
            '<td text_wrap="true" style="text-align:center;">' + string(chk-gds.chk-date) + '</td>' skip                               /* дата чека */
            '<td text_wrap="true" style="text-align:center;">' + time-chk-chr + '</td>' skip                                    /* время чека */
            '<td text_wrap="true">' + SUBSTRING(produkt,1,50) + '</td>' skip                        /* наим.товара */
            '<td text_wrap="true" style="text-align:center;">' + string(chk-gds.pump) + '</td>' skip                                   /* ТРК */
            '<td text_wrap="true" style="text-align:center;">' + string(chk-gds.nozzle-code) + '</td>' skip                             /* пистолет */
            '<td text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(chk-gds.doc-qnty),"->>>>>>>>9.99") + '</td>' skip 
            '<td text_wrap="true" style="text-align:center;">' + string(chk-gds.price-base,"->>>>>>>>9.99") + '</td>' skip
            '<td text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(chk-gds.src-sum),"->>>>>>>>9.99") + '</td>' skip
            '<td text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(chk-gds-pay.tot-r-b),"->>>>>>>>9.99") + '</td>' skip
            '<td text_wrap="true">' + opl-chr + '</td>' skip                                         /*тип оплаты */
            '<td text_wrap="true">' + kassir-chr + '</td>' skip                                      /* кассир*/
            '</tr>' skip
            .
      end.
   END.
   
end PROCEDURE.
procedure itog:
   /* Итоги по объекту */
   if o-qnt-chk > 0 then 
   do:
      put stream OutStr-html unformatted 
         '<tr>' skip
         '<td style="font-weight:bold;">Итог по:</td>' skip
         '<td style="font-weight:bold;">' + obj-list.obj-name + '</td>' skip
         '<td style="font-weight:bold;">Всего сухих чеков:</td>' skip
         '<td style="font-weight:bold; text-align:center;">' + string(o-qnt-chk) + '</td>' skip
         '<td style="font-weight:bold;">Всего сухих чеков продажи:</td>' skip
         '<td style="text-align:center; font-weight:bold;">' + string(o-qnt-pchk) + '</td>' skip
         '<td style="font-weight:bold;">Всего сухих чеков возврата:</td>' skip
         '<td style="text-align:center; font-weight:bold;">' + string(o-qnt-vchk) + '</td>' skip
         '<td style="font-weight:bold;">Сумма по обороту:</td>' skip
         '<td style="text-align:center; font-weight:bold;">' + string(o-sum-ob,"->>>>>>>>9.99") + '</td>' skip
         '<td style="font-weight:bold;">Итоговая сумма:</td>' skip
         '<td style="font-weight:bold; text-align:center;">' + string(o-sum-it,"->>>>>>>>9.99") + '</td>' skip
         '<td></td>' skip
         '<td></td>' skip
         '<td></td>' skip
         '<td></td>' skip
         '<td></td>' skip
         '<td></td>' skip
         '<td></td>' skip
         '</tr>' skip
         .
   end.
   
   qnt-chk = qnt-chk + o-qnt-chk.
   qnt-pchk = qnt-pchk + o-qnt-pchk.
   qnt-vchk = qnt-vchk + o-qnt-vchk.
   sum-it = sum-it + o-sum-it.
   sum-ob = sum-ob + o-sum-ob.

   o-qnt-chk = 0.
   o-qnt-pchk = 0.
   o-qnt-vchk = 0.
   o-sum-it = 0.
   o-sum-ob = 0.
end procedure .
/* итог по отчету */
put stream OutStr-html unformatted          
   '<tr>' skip
   '<td style="font-weight:bold;">Итог по:</td>' skip
   '<td style="font-weight:bold;">Все объекты</td>' skip
   '<td style="font-weight:bold;">Всего сухих чеков:</td>' skip
   '<td style="text-align:center; font-weight:bold;">' + string(qnt-chk) + '</td>' skip
   '<td style="font-weight:bold;">Всего сухих чеков продажи:</td>' skip
   '<td style="text-align:center; font-weight:bold;">' + string(qnt-pchk) + '</td>' skip
   '<td style="font-weight:bold;">Всего сухих чеков возврата:</td>' skip
   '<td style="text-align:center; font-weight:bold;">' + string(qnt-vchk) + '</td>' skip
   '<td style="font-weight:bold;">Сумма по обороту:</td>' skip
   '<td style="text-align:center; font-weight:bold;">' + string(sum-ob,"->>>>>>>>9.99") + '</td>' skip
   '<td style="font-weight:bold;">Итоговая сумма:</td>' skip
   '<td style="text-align:center; font-weight:bold;">' + string(sum-it,"->>>>>>>>9.99") + '</td>' skip
   '<td></td>' skip
   '<td></td>' skip
   '<td></td>' skip
   '<td></td>' skip
   '<td></td>' skip
   '<td></td>' skip
   '<td></td>' skip
   '</tr>' skip
   .


put stream OutStr-html unformatted
   substitute (' 
</tbody> 
</table> 
</body> 
</html> 
 ').
      
output stream OutStr-html close.   
      
run prn-lib-reportviewer in this-procedure (
   input my-handle
   ,input v-file-name-rep-htm
   ,input "" 
   ) no-error.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.

