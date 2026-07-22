block-level on error undo, throw.
/*
$Revision: e8ddcb64563b, 3202, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:28 $
$Workfile: r-schk2.p $
$Archive: rep/r-schk2.p $
Отчет по всем возвратным операциям
Автор: 
Дата создания: 20/12/2014
Creation date: 20/12/2014
*/

define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo. /*объект*/
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter p-tog-with-tot-day as logical            no-undo .

def var vss-revision    as character no-undo init "$Revision: e8ddcb64563b, 3202, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-schk2.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-schk2.p $":U .
def var vss-description as character no-undo init "Отчет по всем возвратным операциям".

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
{ str/lib-trn.i }   
{ ref/chk-type-desc.i } 
{ref/gds-attr.i}  
{ str/is-gas.i }
{ ref/grplibfn.i }

define temp-table tt-chk-doc like ub.chk-doc
   field vozvrat          as logical
   field vozvrat_part     as logical
   field vozvrat_full     as logical
   field vozvrat_full_num as logical
   field vozvrat_dry      as logical
   field vozvrat_part_num as logical
   .

define buffer buf_clients        for ub.clients .
define buffer previous-shift-obj for ub.shift-obj. 
define variable v-file-name-rep-htm    as character no-undo.
define variable var-report-num         as int       no-undo.
define variable gds_chk                as int       no-undo.
define variable produkt                as character no-undo.
define variable time-chk-chr           as character no-undo.   /* время чека txt */
define variable kassir-chr             as character no-undo. 
define variable trnz-chr               as character no-undo. 
define variable opl-chr                as character no-undo.   /*тип оплаты*/
define variable opl-sum                as character no-undo.   /*сумма по типу опл*/
define variable kd-tv                  as character no-undo.   /*код товара */
define variable vCHFlag1               as character no-undo.        
define variable suhoi                  as character no-undo.   /*признак сухого чека    */
define variable vCHMgrKey              as character no-undo.   /*ключ оператора*/
define variable vozvrtrn               as character no-undo.   /*возврат по транзакции */
define variable o-qnt-chk              as int       no-undo.         /* Всего сухих чеков по объекту */
define variable o-qnt-pchk             as int       no-undo.         /* Всего сухих чеков продажи по объекту */
define variable o-qnt-vchk             as int       no-undo.         /* Всего сухих чеков возврата по объекту */
define variable o-sum-ob               as DECIMAL   no-undo.     /* Сумма по обороту по объекту */
define variable o-sum-it               as DECIMAL   no-undo.     /* Итоговая сумма по объекту */

define variable qnt-chk                as int       no-undo.      /* Всего сухих чеков */
define variable qnt-pchk               as int       no-undo.      /* Всего сухих чеков покупки */
define variable qnt-vchk               as int       no-undo.      /* Всего сухих чеков возврата */

define variable qnt-vschk-all          as int       no-undo.  /* Всего сухих чеков возврата*/
define variable qnt-vcchk-all          as int       no-undo.  /* Всего чеков частично возврата */
define variable qnt-vcchk-num-all      as int       no-undo.  /* Всего чеков частично возврата по номеру */
define variable qnt-vnchk-all          as int       no-undo.  /* Всего возвратов по номеру чека */ 
define variable qnt-vpchk-all          as int       no-undo.  /* Всего возвратов полных по транзакции */ 

define variable o-qnt-vschk-all        as int       no-undo.  /* Всего сухих чеков возврата по объекту*/
define variable o-qnt-vcchk-all        as int       no-undo.  /* Всего чеков частично возврата  по объекту*/
define variable o-qnt-vnchk-all        as int       no-undo.  /* Всего возвратов по номеру чека  по объекту*/ 
define variable o-qnt-vpchk-all        as int       no-undo.  /* Всего возвратов полных по транзакции  по объекту*/ 

define variable pr-qnt-vp              as int       no-undo.    /* % чеков возврата к общему количеству чеков продажи */
define variable pr-qnt-co              as int       no-undo.    /* % чеков частичного возврата к общему */
define variable pr-qnt-pvov            as int       no-undo.    /* % всех возвратов по номеру полных  к общему колву возврата*/
define variable pr-qnt-suhob           as int       no-undo.    /* % всех сухих возвратов  к общему колву возврата*/
define variable pr-qnt-ostv            as int       no-undo.    /* % остальных  возвратов  к общему колву возврата*/
define variable pr-qnt-ostp            as int       no-undo.    /* % остальных  возвратов  к общему колву продаж*/

define variable itog-o-qnt-chk         as int       no-undo.         /* Всего сухих чеков по объекту */
define variable itog-o-qnt-pchk        as int       no-undo.         /* Всего сухих чеков продажи по объекту */
define variable itog-o-qnt-vchk        as int       no-undo.         /* Всего сухих чеков возврата по объекту */
define variable itog-o-sum-ob          as DECIMAL   no-undo.     /* Сумма по обороту по объекту */
define variable itog-o-sum-it          as DECIMAL   no-undo.     /* Итоговая сумма по объекту */

define variable itog-qnt-chk           as int       no-undo.      /* Всего сухих чеков */
define variable itog-qnt-pchk          as int       no-undo.      /* Всего сухих чеков покупки */
define variable itog-qnt-vchk          as int       no-undo.      /* Всего сухих чеков возврата */

define variable itog-qnt-vschk-all     as int       no-undo.  /* Всего сухих чеков возврата*/
define variable itog-qnt-vcchk-all     as int       no-undo.  /* Всего чеков частично возврата */
define variable itog-qnt-vcchk-num-all as int       no-undo.  /* Всего чеков частично возврата по номеру */
define variable itog-qnt-vnchk-all     as int       no-undo.  /* Всего возвратов по номеру чека */ 
define variable itog-qnt-vpchk-all     as int       no-undo.  /* Всего возвратов полных по транзакции */ 

define variable itog-o-qnt-vschk-all   as int       no-undo.  /* Всего сухих чеков возврата по объекту*/
define variable itog-o-qnt-vcchk-all   as int       no-undo.  /* Всего чеков частично возврата  по объекту*/
define variable itog-o-qnt-vnchk-all   as int       no-undo.  /* Всего возвратов по номеру чека  по объекту*/ 
define variable itog-o-qnt-vpchk-all   as int       no-undo.  /* Всего возвратов полных по транзакции  по объекту*/ 

define variable itog-pr-qnt-vp         as int       no-undo.    /* % чеков возврата к общему количеству чеков продажи */
define variable itog-pr-qnt-co         as int       no-undo.    /* % чеков частичного возврата к общему */
define variable itog-pr-qnt-pvov       as int       no-undo.    /* % всех возвратов по номеру полных  к общему колву возврата*/
define variable itog-pr-qnt-suhob      as int       no-undo.    /* % всех сухих возвратов  к общему колву возврата*/
define variable itog-pr-qnt-ostv       as int       no-undo.    /* % остальных  возвратов  к общему колву возврата*/
define variable itog-pr-qnt-ostp       as int       no-undo.    /* % остальных  возвратов  к общему колву продаж*/
/* define variable sum-ob       as int no-undo.    */ /* Сумма по обороту */
/* define variable sum-it       as int no-undo.    */ /* Итоговая сумма   */

define variable varhost-code           like ub.trn-doc.host-code no-undo.
define variable v-host-name            as character no-undo. /*название фирмы*/
define variable v-obj-name             as character no-undo. /*АЗС*/

define variable var-prev-shift-date    like ub.shift-obj.shift-date no-undo.
define variable var-prev-shift-num     like ub.shift-obj.shift-num no-undo.
define variable var-shift-staff        like ub.shift-staff.name no-undo.

define variable is-petrol              as logical   no-undo .
define variable is-pieces              as logical   no-undo .

define stream OutStr-html.

/*АЗС*/

find first buf_clients no-lock
   where buf_clients.obj-type = parobj-type
   and buf_clients.obj-code = parobj-code
   .
assign
   v-obj-name = buf_clients.obj-name
   .

{ gbl/hostcode.i parobj-type parobj-code varhost-code}

/*Своя фирма*/
find first buf_clients no-lock
   where buf_clients.obj-type = {&cmp}
   and buf_clients.obj-code = varhost-code
   .
assign
   v-host-name = buf_clients.obj-name
   .

find last previous-shift-obj share-lock
   where previous-shift-obj.obj-type = parobj-type
   and previous-shift-obj.obj-code = parobj-code
   and (( previous-shift-obj.shift-date = X-date-Start
   and previous-shift-obj.shift-num < X-Shift-Start
   )
   or previous-shift-obj.shift-date < X-date-Start
   )
   use-index pi no-error.
if available previous-shift-obj then 
do:
   var-prev-shift-num = previous-shift-obj.shift-num.
   var-prev-shift-date = previous-shift-obj.shift-date.
end.    

    
run get-report-num in parParentProc (
   output var-report-num
   ).

v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(var-report-num) + ".html".
/* Создаём временные файлы. */
output to value(v-file-name-rep-htm).
output close.
/* ******************** */
   
/*Шапка*/
def var v-first-time as int  no-undo.
def var v-first-date as date no-undo.
def var v-last-date  as date no-undo.
def var v-last-time  as int  no-undo.   

output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.


define temp-table tt-goods no-undo like ub.goods.

/* procedure create-tt-goods : */
define variable v-gds as character no-undo.
define buffer buf_goods   for ub.goods.
define buffer buf_cli-gds for ub.cli-gds.
define variable v-gds-counter   as integer   no-undo.

define variable v-curr-grp-name as character no-undo .
define variable v-host-code     like ub.clients.host-code no-undo .
do on error undo, return error return-value:
   empty temp-table tt-goods.

   case x-SelectGood:
      when {&g-all} then 
         do: /* все товары */
            v-gds = 'Все'.
            for each buf_goods no-lock
               where buf_goods.stts = 0:
               create tt-goods.
               buffer-copy buf_goods to tt-goods.
               v-gds-counter = v-gds-counter + 1.
            end.
         end.
      when {&g-grp} then 
         do: /* товары по группам  */
            v-gds = 'По группам товаров'.
            for each tmp#grp no-lock:
               run grplib-get-full-name in this-procedure(input tmp#grp.node-code, output v-curr-grp-name).
               v-gds = v-gds + ": " + v-curr-grp-name .
               for each buf_goods no-lock where buf_goods.grp-name begins v-curr-grp-name:
                  find first tt-goods no-lock
                     where tt-goods.artic = buf_goods.artic
                     and tt-goods.prod-type = buf_goods.prod-type
                     and tt-goods.prod-code = buf_goods.prod-code no-error.
                  if not available tt-goods then 
                  do:
                     create tt-goods.
                     buffer-copy buf_goods to tt-goods.
                     v-gds-counter = v-gds-counter + 1.
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
               find first tt-goods no-lock
                  where tt-goods.prod-type = buf_goods.prod-type
                  and tt-goods.prod-code = buf_goods.prod-code
                  and tt-goods.artic = buf_goods.artic no-error.
               if not available tt-goods then 
               do:
                  create tt-goods.
                  buffer-copy buf_goods to tt-goods no-error.
                  v-gds-counter = v-gds-counter + 1.
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
                  create tt-goods.
                  buffer-copy buf_goods to tt-goods.
                  v-gds-counter = v-gds-counter + 1.
               end.
            end.
         end.
      when {&g-grp-prod} then 
         do: /* группа и производитель */
            v-gds = 'Группы товаров и Производители'.
            for each tmp#grp no-lock:
               run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
               for each buf_goods no-lock where buf_goods.grp-name begins v-curr-grp-name:
                  find first tt-goods no-lock
                     where tt-goods.artic = buf_goods.artic
                     and tt-goods.prod-type = buf_goods.prod-type
                     and tt-goods.prod-code = buf_goods.prod-code no-error.
                  if not available tt-goods then 
                  do:
                     create tt-goods.
                     buffer-copy buf_goods to tt-goods no-error.
                     v-gds-counter = v-gds-counter + 1.
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
               find first tt-goods no-lock
                  where tt-goods.prod-type = buf_goods.prod-type
                  and tt-goods.prod-code = buf_goods.prod-code
                  and tt-goods.artic = buf_goods.artic no-error.
               if not available tt-goods then 
               do:
                  create tt-goods.
                  buffer-copy buf_goods to tt-goods no-error.
                  v-gds-counter = v-gds-counter + 1.
               end.
            end.
         end.
   end case.
end.
/* end procedure. */ /* create-tt-goods */


/* Отчет по всем возвратным операциям */

FIND FIRST tt-goods no-lock no-error .
IF NOT AVAILABLE tt-goods THEN 
DO:
   MESSAGE 'Не выбрана группа товаров!' VIEW-AS ALERT-BOX error. 
   return error.
END.

put stream OutStr-html unformatted 
{ rep/htmlhead.i }

'<body orientation = "landscape" name = " Отчет по всем возвратным операциям  " fit_to_page="true">'.

put stream OutStr-html unformatted
   '<table>' skip  /* таблица, в которой содержится весь отчет */
   '<thead>' skip  /* Шапка отчета */
   /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
   '<tr class="set_columns">' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:130px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:80px"></td>' skip
   '<td style="width:90px"></td>' skip
   '<td style="width:90px"></td>' skip
   '<td style="width:80px"></td>' skip
   '<td style="width:160px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:180px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:120px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:60px"></td>' skip
   '<td style="width:120px"></td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="8" style="text-align: left;">' + string(v-host-name) + '</td>' skip
   '<td colspan="12">«Частичный возврат» - это: </td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="8" style="text-align:left;"> За период с ' + string(x-Date-Start, "99.99.9999") + ' по ' + string(X-date-End, "99.99.9999") + '</td>' skip
   '<td colspan="12">«Частичный возврат» - возврат, который был проведен на недолитое топливо по транзакции на АРМ Кассира</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="8" style="text-align:left;">Выбор объекта: </td>' skip
   '<td colspan="12">«Остальные возвраты» - это:</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="8" style="text-align:left;">' + string(v-obj-name) + '</td>' skip
   '<td colspan="12">«Полный по номеру чека» - полный возврат, который был проведен по номеру чека на АРМ Кассира</td>' skip
   '</tr>' skip
   '<tr>' skip

   '<td colspan="8" style="text-align:left;">' + v-gds + '</td>' skip
   '<td colspan="12">«Частичный по номеру чека» - частичный возврат, который был проведен по номеру чека на АРМ Кассира</td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="8" style="text-align:left;"></td>' skip
   '<td colspan="12">«Полный по транзакции» - полный возврат, который был проведен по транзакции на АРМ Кассира</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="8" style="text-align:left;"></td>' skip
   '<td colspan="12">«Сухой чек, проведенный на АРМ Кассира» - сухой возврат, который был проведен на АРМ Кассира</td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="8" style="text-align:left;">Дата формирования: ' + string(now,"99.99.99 HH:MM:SS") + '</td>' skip
   '<td colspan="12"></td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="8" style="font-size:18px;font-weight:bold; text-align: left;">Отчет по всем возвратным операциям </td>' skip
   '<td colspan="12"></td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="8" ></td>' skip
   '<td colspan="12"></td>' skip
   '</tr>' skip

   '</thead>' skip

   '<tbody>' skip  /* Здесь начинается таблица отчета */
   '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
   '<th rowspan="1" style="text-align: center;">ПНПО</th>' skip
   '<th rowspan="1" style="text-align: center;">Наименование объекта</th>' skip
   '<th rowspan="1" style="text-align: center;"> Номер кассы </th>' skip
   '<th rowspan="1" style="text-align: center;"> Смена </th>' skip
   '<th rowspan="1" style="text-align: center;">Дата смены</th>' skip
   '<th rowspan="1" style="text-align: center;">Номер чека возврата</th>' skip
   '<th rowspan="1" style="text-align: center;">Дата чека возврата</th>' skip
   '<th rowspan="1" style="text-align: center;">Время чека возврата</th>' skip
   '<th rowspan="1" style="text-align: center;">Товар в чеке возврата</th>' skip
   '<th rowspan="1" style="text-align: center;">Код товара	</th>' skip
   '<th rowspan="1" style="text-align: center;">Кол-во в чеке возврата, л.</th>' skip
   '<th rowspan="1" style="text-align: center;">Сумма в чеке возврата</th>' skip
   '<th rowspan="1" style="text-align: center;">Сумма по типу оплаты</th>' skip
   '<th rowspan="1" style="text-align: center;">Тип оплаты</th>' skip
   '<th rowspan="1" style="text-align: center;">Номер транзакции в чеке возврата</th>' skip
   '<th rowspan="1" style="text-align: center;">Возврат по транзакции</th>' skip
   '<th rowspan="1" style="text-align: center;">Номер прямого чека</th>' skip
   '<th rowspan="1" style="text-align: center;">Признак сухого чека на ККМ</th>' skip
   '<th rowspan="1" style="text-align: center;">С ключем +/ без ключа -</th>' skip
   '<th rowspan="1" style="text-align: center;">ФИО кассира</th>' skip
   '</tr>' skip .


FOR EACH obj-list  NO-LOCK:                       
   qnt-vchk  = 0.
   if x-tog-shift then 
   do:
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
         if ub.chk-doc.chk-type = 1 then qnt-pchk = qnt-pchk + 1 .
         run proc-report .
      end.       
   end.
   else 
   do:
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
         and chk-date >= x-Date-Start 
         and chk-date <= x-Date-End 
         and (chk-doc.chk-type = 1 or chk-doc.chk-type = 6) 
         and chk-doc.out-code <> ? NO-LOCK:
         if ub.chk-doc.chk-type = 1 then qnt-pchk = qnt-pchk + 1 .
         run proc-report .
      end.
   end.     

   /* Итоги по объекту  ---*/
   for each tt-chk-doc where tt-chk-doc.obj-code = obj-list.obj-code and tt-chk-doc.obj-type = obj-list.obj-type:
      if tt-chk-doc.vozvrat then o-qnt-chk = o-qnt-chk + 1 . /* общее кол-во возвратов */
      if tt-chk-doc.vozvrat_part then qnt-vcchk-all = qnt-vcchk-all + 1 . /* частичный возврат */
      if tt-chk-doc.vozvrat_part_num then qnt-vcchk-num-all = qnt-vcchk-num-all + 1 . /* частичный возврат по номеру */
      if tt-chk-doc.vozvrat_full_num then qnt-vnchk-all = qnt-vnchk-all + 1 . /* Полный возврат по номеру чека */
      if tt-chk-doc.vozvrat_dry then qnt-vchk = qnt-vchk + 1 . /* сухой чек */
      if tt-chk-doc.vozvrat_full then qnt-vpchk-all = qnt-vpchk-all + 1 . /* Полный по транзакции */
   end.

   pr-qnt-vp = ( o-qnt-chk / qnt-pchk ) * 100 . 
   pr-qnt-co = ((qnt-vcchk-all) / o-qnt-chk ) * 100 .
   pr-qnt-pvov = ((qnt-vnchk-all + qnt-vcchk-num-all + qnt-vpchk-all) / o-qnt-chk ) * 100 .
   pr-qnt-suhob = qnt-vchk / o-qnt-chk * 100 .
   pr-qnt-ostv = ((qnt-vnchk-all + qnt-vcchk-num-all + qnt-vpchk-all + qnt-vchk) / o-qnt-chk) * 100 .
   pr-qnt-ostp = ((qnt-vnchk-all + qnt-vcchk-num-all + qnt-vpchk-all + qnt-vchk) / qnt-pchk) * 100 .

   IF o-qnt-chk > 0 THEN 
   DO:
      put stream OutStr-html unformatted 
         '<tr>' skip
         '<th><b>Итог по кол-ву:</b></th>' 
         '<th>' obj-list.obj-name '</th>' skip
         '<th style="text-align:center;"> Всего чеков возврата: </th>' skip
         '<th style="text-align:center;">' o-qnt-chk  '</th>' skip
         '<th style="text-align:center;"> Всего чеков с частичным возвратом: </th>' skip
         '<th style="text-align:center;">' qnt-vcchk-all '</th>'skip
         '<th style="text-align:center;"> Всего возвратов по номеру чека/полных по транзакции:</th>' skip
         '<th>' qnt-vnchk-all + qnt-vcchk-num-all + qnt-vpchk-all '</th>' skip
         '<th style="text-align:center;"> Всего сухих чеков возврата: </th>' skip
         '<th style="text-align:center;">' qnt-vchk '</th>' skip
         '<td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> ' skip
         '</tr>' skip

         /* Итого по соотношению */
         '<tr>' skip
         '<th><b>Итого по соотношению:</b></th>' skip
         '<th>' obj-list.obj-name '</th>' skip
         '<th style="text-align:center;"> % чеков возврата к общему количеству чеков продажи:</th>' skip    
         '<th style="text-align:center;">' pr-qnt-vp '%' '</th>' skip
         '<th> % частичного возврата к общему количеству чеков возврата: </th>' skip
         '<th style="text-align:center;">' pr-qnt-co '%' '</th>' skip
         '<th style="text-align:center;">% остальных чеков  возврата к общему количеству чеков возврата:</th>' skip
         '<th style="text-align:center;">' pr-qnt-ostv '%' '</th>' skip
         '<th>% остальных чеков  возврата к общему количеству чеков продажи: </th>' skip
         '<th style="text-align:center;">' pr-qnt-ostp '%' '</th>' skip
         '<th>% всех возвратов по номеру чека/полных по транзакции к общему кол-ву чеков возврата:</th>' skip
         '<th style="text-align:center;">' pr-qnt-pvov '%' '</th>' skip
         '<th>% всех сухих чеков возврата к общему кол-ву чеков возврата</th>' skip
         '<th style="text-align:center;">' pr-qnt-suhob '%' '</th>' skip
         '<td></td><td></td><td></td><td></td><td></td><td></td>' skip
         '</tr>' skip.
  
   END.
   assign
      itog-o-qnt-chk         = itog-o-qnt-chk + o-qnt-chk
      itog-qnt-vchk          = itog-qnt-vchk + qnt-vchk
      itog-qnt-vnchk-all     = itog-qnt-vnchk-all + qnt-vnchk-all
      itog-qnt-vcchk-num-all = itog-qnt-vcchk-num-all + qnt-vcchk-num-all 
      itog-qnt-vpchk-all     = itog-qnt-vpchk-all + qnt-vpchk-all
      itog-qnt-vcchk-all     = itog-qnt-vcchk-all + qnt-vcchk-all
      itog-o-qnt-pchk        = itog-o-qnt-pchk + o-qnt-pchk
      itog-o-qnt-vchk        = itog-o-qnt-vchk + o-qnt-vchk
      itog-qnt-pchk          = itog-qnt-pchk + qnt-pchk
      . 
   assign
      o-qnt-chk         = 0
      qnt-vchk          = 0 
      qnt-vnchk-all     = 0
      qnt-vcchk-num-all = 0
      qnt-vpchk-all     = 0 
      qnt-vcchk-all     = 0
      o-qnt-pchk        = 0
      o-qnt-vchk        = 0
      qnt-pchk          = 0 
      .
END. 

itog-pr-qnt-vp = ( itog-o-qnt-chk / itog-qnt-pchk ) * 100 . 
itog-pr-qnt-co = ((itog-qnt-vcchk-all) / itog-o-qnt-chk ) * 100 .
itog-pr-qnt-pvov = ((itog-qnt-vnchk-all + itog-qnt-vcchk-num-all + itog-qnt-vpchk-all) / itog-o-qnt-chk ) * 100 .
itog-pr-qnt-suhob = itog-qnt-vchk / itog-o-qnt-chk * 100 .
itog-pr-qnt-ostv = ((itog-qnt-vnchk-all + itog-qnt-vcchk-num-all + itog-qnt-vpchk-all + itog-qnt-vchk) / itog-o-qnt-chk) * 100 .
itog-pr-qnt-ostp = ((itog-qnt-vnchk-all + itog-qnt-vcchk-num-all + itog-qnt-vpchk-all + itog-qnt-vchk) / itog-qnt-pchk) * 100 .

IF itog-o-qnt-chk > 0 THEN 
DO:
   put stream OutStr-html unformatted 
      '<tr>' skip
      '<th><b>Итог по кол-ву:</b></th>' 
      '<th>Все объекты</th>' skip
      '<th style="text-align:center;"> Всего чеков возврата: </th>' skip
      '<th style="text-align:center;">' itog-o-qnt-chk  '</th>' skip
      '<th style="text-align:center;"> Всего чеков с частичным возвратом: </th>' skip
      '<th style="text-align:center;">' itog-qnt-vcchk-all '</th>'skip
      '<th style="text-align:center;"> Всего возвратов по номеру чека/полных по транзакции:</th>' skip
      '<th>' itog-qnt-vnchk-all + itog-qnt-vcchk-num-all + itog-qnt-vpchk-all '</th>' skip
      '<th style="text-align:center;"> Всего сухих чеков возврата: </th>' skip
      '<th style="text-align:center;">' itog-qnt-vchk '</th>' skip
      '<td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> <td></td> ' skip
      '</tr>' skip

      /* Итого по соотношению */
      '<tr>' skip
      '<th><b>Итого по соотношению:</b></th>' skip
      '<th>Все объекты</th>' skip
      '<th style="text-align:center;"> % чеков возврата к общему количеству чеков продажи:</th>' skip    
      '<th style="text-align:center;">' itog-pr-qnt-vp '%' '</th>' skip
      '<th> % частичного возврата к общему количеству чеков возврата: </th>' skip
      '<th style="text-align:center;">' itog-pr-qnt-co '%' '</th>' skip
      '<th style="text-align:center;">% остальных чеков  возврата к общему количеству чеков возврата:</th>' skip
      '<th style="text-align:center;">' itog-pr-qnt-ostv '%' '</th>' skip
      '<th>% остальных чеков  возврата к общему количеству чеков продажи: </th>' skip
      '<th style="text-align:center;">' itog-pr-qnt-ostp '%' '</th>' skip
      '<th>% всех возвратов по номеру чека/полных по транзакции к общему кол-ву чеков возврата:</th>' skip
      '<th style="text-align:center;">' itog-pr-qnt-pvov '%' '</th>' skip
      '<th>% всех сухих чеков возврата к общему кол-ву чеков возврата</th>' skip
      '<th style="text-align:center;">' itog-pr-qnt-suhob '%' '</th>' skip
      '<td></td><td></td><td></td><td></td><td></td><td></td>' skip
      '</tr>' skip.
  
END.
    
procedure proc-report:
   FOR EACH chk-gds where chk-gds.doc-code = chk-doc.doc-code AND chk-doc.chk-type = 6 NO-LOCK:
      produkt = ''.
      time-chk-chr = ''.
      gds_chk = 0.
      /* opl-sum = ''. */

      /* наименование по баркоду */
      find first bar-code where bar-code.b-code eq chk-gds.b-code no-lock no-error.
      IF AVAILABLE bar-code THEN  gds_chk = bar-code.gds-code.
      find first goods where gds_chk eq goods.gds-code no-lock no-error.
      if not available (goods) then next .

      find first tt-goods where tt-goods.gds-code = goods.gds-code no-error .
      if not available (tt-goods) then next .
      produkt = TRIM(tt-goods.gds-name).
      /* код товара */
      if p-tog-with-tot-day = no  then kd-tv = string(chk-gds.b-code) .
      if p-tog-with-tot-day = yes then kd-tv = chk-gds.src-code .

      /* фио кассира */
      find first person where person.psn-code = chk-doc.cashier-psn-code no-lock no-error.
      IF AVAILABLE person THEN  kassir-chr = person.name1 + ' ' + person.name2 + ' '. /* кассир */
      find first clients where person.psn-code = clients.obj-code and clients.obj-type = 'чел' no-lock no-error.
      IF AVAILABLE clients THEN kassir-chr = kassir-chr + clients.obj-name.
      trnz-chr = "" .
      vozvrtrn = '-' .
      /* id чека */
      find first chk-doc-attr where chk-doc-attr.attr-code = 'CheckId' and chk-doc-attr.doc-code = chk-doc.doc-code no-lock no-error.
      IF AVAILABLE chk-doc-attr THEN 
      DO: 
         find first tran-fuel  where  tran-fuel.uuid-cheq eq chk-doc-attr.attr-value no-lock no-error.
         IF AVAILABLE tran-fuel then 
         assign
         trnz-chr = string(tran-fuel.tran-num)
         vozvrtrn = '+' .   
         
      END.


      time-chk-chr = string(chk-gds.time-oper, "HH:MM").    /* время чека */

      /*      /* сухие чеки */                                                                                    */
      /*      suhoi = '-'.                                                                                        */
      /*      if chk-gds.pass-gds = 1 then                                                                        */
      /*      do:                                                                                                 */
      /*      { str/is-petrl.i tt-goods.artic tt-goods.prod-type tt-goods.prod-code is-petrol is-pieces no-error }*/
      /*         if is-petrol = yes                                                                               */
      /*            and not is-gas(tt-goods.gds-code)   then                                                      */
      /*         do:                                                                                              */
      /*            find first tt-chk-doc where tt-chk-doc.doc-code = chk-doc.doc-code no-error .                 */
      /*            if not available (tt-chk-doc) then                                                            */
      /*            do:                                                                                           */
      /*               create tt-chk-doc.                                                                         */
      /*               buffer-copy chk-doc to tt-chk-doc .                                                        */
      /*            end.                                                                                          */
      /*            tt-chk-doc.vozvrat_dry = true .                                                               */
      /*            suhoi = '+'.                                                                                  */
      /*         end.                                                                                             */
      /*      end.                                                                                                */
      find first tt-chk-doc where tt-chk-doc.doc-code = chk-doc.doc-code no-error .
      if not available (tt-chk-doc) then 
      do:
         create tt-chk-doc.
         buffer-copy chk-doc to tt-chk-doc .
      end.
      tt-chk-doc.vozvrat = true .
      IF chk-doc.chk-type = 1 THEN o-qnt-pchk = o-qnt-pchk + 1.
      IF chk-doc.chk-type = 6 THEN o-qnt-vchk = o-qnt-vchk + 1.

      /* типы возвратов  */
      find first chk-doc-attr where chk-doc-attr.doc-code = chk-doc.doc-code
         and chk-doc-attr.attr-code = 'CHFlag1' no-lock no-error.
      IF AVAILABLE chk-doc-attr THEN 
      DO:
         suhoi = "-" .
/*         vozvrtrn = '-' .*/
         if chk-doc-attr.attr-value = '0' then vCHFlag1 = 'Свободный возврат' .
         else if chk-doc-attr.attr-value = '1' then vCHFlag1 = 'Частичный возврат' .
            else if chk-doc-attr.attr-value = '2' then vCHFlag1 = 'Полный возврат по номеру чека' .
               else if chk-doc-attr.attr-value = '3' then vCHFlag1 = 'Частичный возврат по номеру чека'.
                  else if chk-doc-attr.attr-value = '4' then vCHFlag1 = 'возврат полностью не пролитого топлива' .
         if chk-doc-attr.attr-value = '0' then 
         do:
            /*сухой чек*/
            find first tt-chk-doc where tt-chk-doc.doc-code = chk-doc.doc-code no-error .
            if not available (tt-chk-doc) then 
            do:
               create tt-chk-doc.
               buffer-copy chk-doc to tt-chk-doc .
            end.
            tt-chk-doc.vozvrat_dry = true .  
/*            vozvrtrn = '-' .*/
            suhoi = '+'.              
         end.
         if chk-doc-attr.attr-value = '1' then 
         do:
            /*частичный возврат*/
            find first tt-chk-doc where tt-chk-doc.doc-code = chk-doc.doc-code no-error .
            if not available (tt-chk-doc) then 
            do:
               create tt-chk-doc.
               buffer-copy chk-doc to tt-chk-doc .
            end.
            tt-chk-doc.vozvrat_part = true .  
/*            vozvrtrn = '+' .*/
         end.
         else if chk-doc-attr.attr-value = '2' then 
            do:
               /*полный возврат*/
               find first tt-chk-doc where tt-chk-doc.doc-code = chk-doc.doc-code no-error .
               if not available (tt-chk-doc) then 
               do:
                  create tt-chk-doc.
                  buffer-copy chk-doc to tt-chk-doc .
               end.
               tt-chk-doc.vozvrat_full_num = true . 
/*               vozvrtrn = '-' .*/
            end.
            else if chk-doc-attr.attr-value = '3' then 
               do:
                  /*полный возврат*/
                  find first tt-chk-doc where tt-chk-doc.doc-code = chk-doc.doc-code no-error .
                  if not available (tt-chk-doc) then 
                  do:
                     create tt-chk-doc.
                     buffer-copy chk-doc to tt-chk-doc .
                  end.
                  tt-chk-doc.vozvrat_part_num = true .   
/*                  vozvrtrn = '-' .*/
               end.                           
               else if chk-doc-attr.attr-value = '4' then 
                  do:
                     /*полный возврат*/
                     find first tt-chk-doc where tt-chk-doc.doc-code = chk-doc.doc-code no-error .
                     if not available (tt-chk-doc) then 
                     do:
                        create tt-chk-doc.
                        buffer-copy chk-doc to tt-chk-doc .
                     end.
                     tt-chk-doc.vozvrat_full = true .   
/*                     vozvrtrn = '+' .*/
                  end.
      /*         if chk-doc-attr.attr-value = '1' then  vozvrtrn = '+' .       /*возврат по транзакции*/*/
      /*         else if chk-doc-attr.attr-value <> '1' then  vozvrtrn = '-' . /*возврат по транзакции*/*/
      END.

      /* с ключем без ключа   */
      find first chk-doc-attr where chk-doc-attr.doc-code = chk-doc.doc-code
         and chk-doc-attr.attr-code = 'CHMgrKey' no-lock no-error.
      IF AVAILABLE chk-doc-attr THEN 
      DO: 
         if chk-doc-attr.attr-value = '0' then vCHMgrKey = '-'. 
         else if chk-doc-attr.attr-value = '1' then vCHMgrKey = '+'.
      END.

      /*тип платежа*/
      opl-chr = ''.
      for EACH  chk-gds-pay where chk-gds-pay.doc-code = chk-gds.doc-code 
                           /* and chk-gds-pay.b-code = chk-gds.b-code*/
                              and chk-gds-pay.line-num = chk-gds.line-num 
      no-lock :
         /* MESSAGE chk-pay.tot-sum VIEW-AS ALERT-BOX. */
         find first cash-pay where cash-pay.cdpay-code = chk-gds-pay.pay-code no-lock no-error.
         IF AVAILABLE cash-pay THEN opl-chr = cash-pay.obj-name.
      
         put stream OutStr-html unformatted 
            '<tr>' skip
            '<td text_wrap="true">' v-host-name       '</td>' skip
            '<td text_wrap="true">' obj-list.obj-name '</td>' skip
            '<td text_wrap="true" style="text-align:center;">' chk-doc.pay-desk   '</td>' skip  /*касса*/
            '<td text_wrap="true" style="text-align:center;">' chk-doc.shift-name '</td>' skip  /*смена*/
            '<td text_wrap="true" style="text-align:center;">' chk-doc.shift-date '</td>' skip  /*дата смены*/
            '<td text_wrap="true" style="text-align:center;">' chk-doc.chk-num ': ' chk-doc.z-number '</td>' skip    /*номер чека возврата*/
            '<td text_wrap="true" style="text-align:center;">' chk-gds.chk-date '</td>' skip    /*дата чека возврата*/
            /*'<td style="text-align:center;">' chk-gds.time-oper '</td>' skip  */  /* время чека */
            '<td text_wrap="true" style="text-align:center;">' string(chk-doc.chk-time, "HH:MM") '</td>' skip   /* время чека */
            '<td text_wrap="true">' SUBSTRING(produkt,1,50)   '</td>' skip                              /*товар в чеке возврата*/
            '<td text_wrap="true">' kd-tv   '</td>' skip                                                /* код товара */        
            '<td text_wrap="true" style="text-align:center;">' string(ABSOLUTE(chk-gds.doc-qnty),"->>>>>>>>9.99") '</td>' skip  /*количество*/
            '<td text_wrap="true" style="text-align:center;">' string(ABSOLUTE(chk-gds.src-sum),"->>>>>>>>9.99")  '</td>' skip  /*Сумма в чеке */
            '<td text_wrap="true" style="text-align:center;">' + string(ABSOLUTE(chk-gds-pay.tot-r-b),"->>>>>>>>9.99") + '</td>' skip                  /*Сумма по типу оплаты*/
            '<td text_wrap="true">'                            opl-chr    '</td>' skip                  /*тип оплаты*/
            '<td text_wrap="true" style="text-align:center;">' trnz-chr   '</td>' skip                  /*транзакция */
            '<td text_wrap="true" style="text-align:center;">' vozvrtrn   '</td>' skip                  /*возврат по транзакции*/
            '<td text_wrap="true" style="text-align:center;">' chk-doc.doc-num2   '</td>' skip                  /*номер прямого чека*/
            '<td text_wrap="true" style="text-align:center;">' suhoi      '</td>' skip                  /* признак сухого */
            '<td text_wrap="true" style="text-align:center;">' vCHMgrKey  '</td>' skip                  /* ключ оператора*/
            '<td text_wrap="true" >'                            kassir-chr '</td>' skip                  /* кассир*/
            '</tr>' skip .
      END.
      opl-sum = ''.
      opl-chr = ''.
   END.
end.


put stream OutStr-html unformatted
   substitute (' </tbody></table> </body> </html>  ').
      
output stream OutStr-html close.   
      
run prn-lib-reportviewer in this-procedure (
   input parparentproc
   ,input v-file-name-rep-htm
   ,input "" 
   ) no-error.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.

