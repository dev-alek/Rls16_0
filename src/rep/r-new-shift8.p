block-level on error undo, throw.
/*
$Revision: fcd3c45be6b6, 3657, test $
$Author: VSpiridonov $
$Date: 2024/01/25 16:33:07 $
$Workfile: r-new-shift8.p $
$Archive: rep/r-new-shift8.p $
8 часть сменного отчета
Автор: 
Дата создания: 20/05/2022
Creation date: 20/05/2022
*/

DEFINE INPUT PARAMETER parparentproc      AS widget-handle NO-UNDO .
DEFINE INPUT PARAMETER p-obj-type         LIKE ub.trn-doc.obj-type NO-UNDO. /* объект*/ 
DEFINE INPUT PARAMETER p-obj-code         LIKE ub.trn-doc.obj-code NO-UNDO.
DEFINE INPUT PARAMETER tog-82             AS logical   NO-UNDO .            /*с частичным возвратом или без */
DEFINE INPUT PARAMETER v-report-name-html AS CHARACTER  NO-UNDO . 
DEFINE INPUT PARAMETER v-report-result    AS logical  NO-UNDO . 

def var vss-revision    AS character NO-UNDO init "$Revision: fcd3c45be6b6, 3657, test $":U .
def var vss-author      AS character NO-UNDO init "$Author: VSpiridonov $":U .
def var vss-date        AS character NO-UNDO init "$Date: 2024/01/25 16:33:07 $":U .
def var vss-workfile    AS character NO-UNDO init "$Workfile: r-new-shift8.p $":U .
def var vss-archive     AS character NO-UNDO init "$Archive: rep/r-new-shift8.p $":U .
def var vss-description AS character NO-UNDO init "8 часть сменного отчета".

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

DEFINE BUFFER buf_clients for ub.clients .
DEFINE BUFFER buf_chk-gds-pay FOR ub.chk-gds-pay.
DEFINE VARIABLE v-file-name-rep-htm AS character NO-UNDO.
DEFINE VARIABLE var-report-num      AS INT       NO-UNDO.

DEFINE VARIABLE FLG                 AS CHARACTER NO-UNDO.
DEFINE VARIABLE produkt             AS CHARACTER NO-UNDO.
DEFINE VARIABLE npp                 AS INTEGER   NO-UNDO.
define variable is-petrol           as logical   no-undo .
define variable is-pieces           as logical   no-undo .
define variable handmade            as character no-undo.  /* добавлен вручную */
define variable gds_chk             as int       no-undo.        /* код товара*/
define variable v-src-sum           as decimal   no-undo.  /* сумма чека со скидкой */

DEF    VAR      kol-ch              AS DECIMAL   NO-UNDO.
DEF    VAR      sum-ch              AS DECIMAL   NO-UNDO.
DEF    VAR      kol-ost             AS DECIMAL   NO-UNDO.
DEF    VAR      sum-ost             AS DECIMAL   NO-UNDO.
DEF    VAR      kol-itog            AS DECIMAL   NO-UNDO.
DEF    VAR      sum-itog            AS DECIMAL   NO-UNDO.

DEFINE TEMP-TABLE tt-chk NO-UNDO
   FIELD doc-code  LIKE chk-doc.doc-code     /* Номер  */
   FIELD chk-num   LIKE chk-doc.chk-num      /* Номер чека */
   FIELD chk-z     LIKE chk-doc.z-number     /* Номер z отчета*/
   FIELD trk       LIKE chk-gds.pump         /* Номер ТРК  */
   FIELD qnt-chk   AS DECIMAL                 /* количество */
   FIELD price-chk AS DECIMAL                 /* цена */
   FIELD sum-chk   AS DECIMAL                 /* сумма */
   FIELD th        AS CHAR                    /* создан в ТН */
   FIELD flag      AS CHAR                    /* 0-возв. (не подх. ни к одному из 4-х других) 1-Част. возвр. 2-Полн. по ном.чека 3-Част.по ном. чека 4-Полн.по транз. */
   FIELD type-fuel AS CHAR                    /* Тип топлива	 */
   FIELD produkt   AS CHAR                    /* наименование товара	 */	
   FIELD is-petrol AS logical                 /* топливо или нет  */	
   FIELD npp       AS INT                     /* номер по порядку */	
   FIELD b-code    LIKE chk-gds.b-code       /* баркод */	
   FIELD is-code   LIKE chk-gds.src-code     /* исходный код товара */	
   INDEX pi AS UNIQUE PRIMARY doc-code chk-num chk-z npp
   .         
	

FOR EACH chk-doc WHERE 
         chk-doc.obj-type = p-obj-type 
     AND chk-doc.obj-code = p-obj-code 
     AND chk-doc.shift-date >= x-Date-Start 
     AND chk-doc.shift-date <= x-Date-End 
     AND chk-type = 6 
    no-lock by chk-doc.shift-date:
   npp = 0. 
   handmade = '-'. 
  if ub.chk-doc.shift-date = x-date-Start and ub.chk-doc.shift-num < x-Shift-Start then next .
  if ub.chk-doc.shift-date = x-date-End   and ub.chk-doc.shift-num > x-Shift-End then next .

			
   FIND FIRST chk-doc-attr WHERE chk-doc-attr.attr-code = 'CHFlag1' AND chk-doc-attr.doc-code = chk-doc.doc-code  NO-LOCK NO-error.
   IF ERROR-STATUS:ERROR THEN  FLG = '0' .
    
   if AVAILABLE chk-doc-attr then FLG = chk-doc-attr.attr-value.
						
   FOR EACH  chk-gds WHERE chk-gds.doc-code = chk-doc.doc-code  NO-LOCK:    
      npp = npp + 1.
			
      FIND FIRST bar-code WHERE bar-code.b-code eq chk-gds.b-code  NO-LOCK NO-ERROR.
      IF AVAILABLE bar-code THEN  gds_chk = bar-code.gds-code.
			
      FIND FIRST goods WHERE gds_chk eq goods.gds-code  NO-LOCK NO-ERROR.
      IF AVAILABLE goods THEN 
      DO: 
         produkt = TRIM(goods.gds-name). 
         { str/is-petrl.i goods.artic goods.prod-type goods.prod-code is-petrol is-pieces	no-error }
      END.
			
      /* признак ручного чека */
      FIND FIRST c-chk-doc WHERE c-chk-doc.doc-code = chk-doc.doc-code AND c-chk-doc.is-add = yes NO-LOCK NO-ERROR.
      IF AVAILABLE c-chk-doc THEN handmade = '+'. 

			
      find first bar-code where bar-code.b-code eq chk-gds.b-code no-lock no-error.
      IF AVAILABLE bar-code THEN  gds_chk = bar-code.gds-code.
      
      v-src-sum = 0.
      for each  buf_chk-gds-pay no-lock where 
                buf_chk-gds-pay.doc-code = chk-gds.doc-code                
            and buf_chk-gds-pay.line-num = chk-gds.line-num 
      :
          v-src-sum = v-src-sum + buf_chk-gds-pay.tot-r-b. 
      end.    
      if v-src-sum = 0 then v-src-sum = chk-gds.src-sum.    

      CREATE tt-chk.
 
      ASSIGN
         tt-chk.doc-code  = chk-doc.doc-code
         tt-chk.chk-num   = chk-doc.chk-num
         tt-chk.chk-z     = chk-doc.z-number
         tt-chk.trk       = chk-gds.pump
         tt-chk.qnt-chk   = chk-gds.doc-qnty 
         tt-chk.price-chk = chk-gds.price-base
         tt-chk.sum-chk   = v-src-sum
         tt-chk.flag      = FLG
         tt-chk.npp       = npp
         tt-chk.type-fuel = produkt
         tt-chk.is-petrol = is-petrol
         tt-chk.th        = handmade
         tt-chk.b-code    = chk-gds.b-code 
         tt-chk.is-code   = chk-gds.src-code
         .
   END.
END.	
  
DEFINE VARIABLE varhost-code        LIKE ub.trn-doc.host-code NO-UNDO.
DEFINE VARIABLE v-host-name         AS character NO-UNDO. /*название фирмы*/
DEFINE VARIABLE v-obj-name          AS character NO-UNDO. /*АЗС*/

DEFINE VARIABLE var-prev-shift-date LIKE ub.shift-obj.shift-date NO-UNDO.
DEFINE VARIABLE var-prev-shift-num  LIKE ub.shift-obj.shift-num NO-UNDO.
DEFINE VARIABLE var-shift-staff     LIKE ub.shift-staff.name NO-UNDO. 



/* { gbl/hostcode.i p-obj-type p-obj-code varhost-code} */
/*run get-report-name in parParentProc ( output var-report-num  ). */
/* v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(var-report-num) + ".html". */
/* Создаём временные файлы. */
 
/* def var v-first-time AS int NO-UNDO.
def var v-first-date AS date NO-UNDO.
def var v-last-date AS date NO-UNDO.
def var v-last-time AS int NO-UNDO.   
*/
 
DEFINE STREAM OutStr-html. 
/*output to value(v-report-name-html). */
output close.  

if v-report-result = yes then output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
if v-report-result = no then output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/. 
/*                                          */
/*   PUT STREAM OutStr-html UNFORMATTED     */
/*      '<tr class="set_columns">' skip     */
/*      '<td style="width:250px"></td>' skip*/
/*      '<td style="width:150px"></td>' skip*/
/*      '<td style="width:100px"></td>' skip*/
/*      '<td style="width:50px"></td>' skip */
/*      '<td style="width:150px"></td>' skip*/
/*      '<td style="width:100px"></td>' skip*/
/*      '<td style="width:50px"></td>' skip */
/*      '<td style="width:100px"></td>' skip*/
/*      '<td style="width:100px"></td>' skip*/
/*      '<td style="width:100px"></td>' skip*/
/*      '<td style="width:100px"></td>' skip*/
/*      '</tr>' skip                        */
/*               '</thead>' skip            */
/*      .                                   */
/*OUTPUT STREAM OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.*/

/*  MESSAGE   v-report-result VIEW-AS ALERT-BOX.   */
 
 
/*PUT STREAM OutStr-html UNFORMATTED('<!DOCTYPE HTML><html><head><meta charset="UTF-8"/><!-- Стили документа -->*/
/*                <style>                                                                                       */
/*                     table ~{                                                                                 */
/*                         border-collapse: collapse;                                                           */
/*                     ~}                                                                                       */
/*                     tbody td, th ~{                                                                          */
/*                         border: 1px solid black;                                                             */
/*                         border-collapse: collapse;                                                           */
/*                   height: 14px;                                                                              */
/*                     ~}                                                                                       */
/*                </style></head><body>').                                                                      */


/* заголовок таблица с частичными возвратами */		
IF tog-82 THEN 
DO:
   PUT STREAM OutStr-html UNFORMATTED
      '<tbody>' skip /* Здесь начинается таблица отчета */
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th rowspan="1" colspan="11" style="text-align: center;">Чеки возврата по топливу</th>' skip
      '</tr>' skip
      '<tr >' skip
      '<th rowspan="2" style="text-align: center;">Тип топлива</th>' skip
      '<th colspan="3" style="text-align: center;">Частичные</th>' skip
      '<th colspan="3" style="text-align: center;">Остальные</th>' skip
      '<th rowspan="2" style="text-align: center;">Номер чека</th>' skip
      '<th rowspan="2" style="text-align: center;">Создан в ТН</th>' skip
      '<th rowspan="2" style="text-align: center;">Цена за л.</th>' skip
      '<th rowspan="2" style="text-align: center;">Сумма по чеку</th>' skip
      '</tr>' skip
      '<tr >' skip
      '<th style="text-align: center;">ТРК</th>' skip
      '<th colspan="2" style="text-align: center;">Кол-во, л.</th>' skip
      '<th style="text-align: center;">ТРК</th>' skip
      '<th colspan="2" style="text-align: center;">Кол-во, л.</th>' skip
      '</tr>' skip
      .

   FOR EACH tt-chk
       group by tt-chk.doc-code:
      
      if tt-chk.is-petrol THEN 
      do:                          /* если топливо       */ 
         if tt-chk.flag = "1" THEN 
         do:                     /* частичные возвраты */
            if first-of(tt-chk.doc-code)
            then kol-ch = kol-ch + 1.
            sum-ch = sum-ch + tt-chk.sum-chk.
            PUT STREAM OutStr-html UNFORMATTED 
               '<tr>' skip
               '<td text_wrap="true" style="text-align:left;">' + string(tt-chk.type-fuel) + '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.trk) + '</td>' skip
               '<td colspan="2" text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(tt-chk.qnt-chk),"->>>>>>>>9.99") + '</td>' skip
               '<td>'    '</td>' skip
               '<td colspan="2">'    '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.chk-num) + ':' + string(tt-chk.chk-z) + '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.th) + '</td>' skip 
               '<td text_wrap="true" style="text-align:right;">' string(tt-chk.price-chk,"->>>>>>>>9.99") + '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' string(ABSOLUTE(tt-chk.sum-chk),"->>>>>>>>9.99") + '</td>' skip
               '</tr>' skip.
         END.
	
         ELSE IF tt-chk.flag = "2" OR tt-chk.flag = "4" OR tt-chk.flag = "3" OR tt-chk.flag = "0"  THEN 
            DO:
               if first-of(tt-chk.doc-code)
               then kol-ost = kol-ost + 1.
               sum-ost = sum-ost + tt-chk.sum-chk.
               PUT STREAM OutStr-html UNFORMATTED 
                  '<tr>' skip
                  '<td text_wrap="true" style="text-align:left;">' + string(tt-chk.type-fuel) + '</td>' skip
                  '<td>'  '</td>' skip
                  '<td colspan="2">'  '</td>' skip
                  '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.trk) + '</td>' skip
                  '<td colspan="2" text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(tt-chk.qnt-chk)) + '</td>' skip
                  '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.chk-num) + ':' + string(tt-chk.chk-z) + '</td>' skip
                  '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.th) + '</td>' skip
                  '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.price-chk,"->>>>>>>>9.99") + '</td>' skip
                  '<td text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(tt-chk.sum-chk),"->>>>>>>>9.99") + '</td>' skip
                  '</tr>' skip.
            end.
      END.   
   END.

   kol-itog = kol-ost + kol-ch.
   sum-itog = sum-ost + sum-ch.

   PUT STREAM OutStr-html UNFORMATTED 
      '<tr>' skip
      '<th rowspan="2" style="text-align: left;">Итого по количеству:</th>' skip
      '<th colspan="2" style="text-align: left; border-right: 0px solid black;">Общее количество частичных:</th>' skip
      '<th style="text-align: right; border-left: 0px solid black;">' + string(kol-ch) + '</th>' skip
      '<th colspan="2" style="text-align: left; border-right: 0px solid black;">Общее количество остальных:</th>' skip
      '<th style="text-align: right; border-left: 0px solid black;">' + string(kol-ost) + '</th>' skip
      '</tr>' skip
      '<tr>' skip
      '<th colspan="4" style="text-align: left; border-right: 0px solid black;">По всем:</th>' skip
      '<th colspan="2" style="text-align: right; border-left: 0px solid black;">' + string(kol-itog) + '</th>' skip
      '</tr>' skip
      '<tr>' skip
      '<th rowspan="2" style="text-align: left;">Итого по сумме: </th>' skip
      '<th colspan="2" style="text-align: left; border-right: 0px solid black;">Сумма по частичным:</th>' skip
      '<th style="text-align: right; border-left: 0px solid black;" >' + string(ABSOLUTE(sum-ch),"->>>>>>>>9.99") + '</th>' skip
      '<th colspan="2" style="text-align: left; border-right: 0px solid black;">Сумма по остальным:</th>' skip
      '<th style="text-align: right; border-left: 0px solid black;">' + string(ABSOLUTE(sum-ost),"->>>>>>>>9.99") + '</th>' skip
      '</tr>' skip
      '<tr>' skip
      '<th colspan="4" style="text-align: left; border-right: 0px solid black;">По всем:</th>' skip
      '<th colspan="2" style="text-align: right; border-left: 0px solid black;">' + string(ABSOLUTE(sum-itog),"->>>>>>>>9.99") + '</th>' skip
      '</tr>' skip 
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th colspan="7" style="text-align: center; height: 30px; border: 0px solid black" ></th>' skip
      '</tr>' skip
      .

   /* Чеки возврата по сопутствующему товару */

   PUT STREAM OutStr-html UNFORMATTED
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th rowspan="1" colspan="11" style="text-align: center;" >Чеки возврата по сопутствующему товару</th>' skip
      '</tr>' skip
      '<tr>' skip
      '<th style="text-align: center;">Товар</th>' skip
      '<th style="text-align: center;">Бар-код товара</th>' skip
      '<th colspan="2" style="text-align: center;">Исходный код товара</th>' skip
      '<th style="text-align: center;">Номер чека</th>' skip
      '<th colspan="2" style="text-align: center;">Количество</th>' skip
      '<th colspan="2" style="text-align: center;">Создан в ТН</th>' skip
      '<th colspan="2" style="text-align: center;">Сумма</th>' skip
      '</tr>'.

   kol-itog = 0.
   sum-itog = 0.

   FOR EACH tt-chk:
      if not tt-chk.is-petrol THEN 
      do:
         kol-itog = kol-itog + 1.
         sum-itog = sum-itog + tt-chk.sum-chk.
         PUT STREAM OutStr-html UNFORMATTED 
            '<tr>' skip
            '<td text_wrap="true" >' + string(tt-chk.type-fuel) + '</td>' skip
            '<td text_wrap="true" style="text-align: right;">' + string(tt-chk.b-code) + '</td>' skip
            '<td colspan="2" text_wrap="true" style="text-align: right;">' + string(tt-chk.is-code) + '</td>' skip
            '<td text_wrap="true" style="text-align: right;">' + string(tt-chk.chk-num) + ':' + string(tt-chk.chk-z) + '</td>' skip
            '<td colspan="2" text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(tt-chk.qnt-chk)) + '</td>' skip
            '<td colspan="2" text_wrap="true" style="text-align:right;">' + string(tt-chk.th) + '</td>' skip
            '<td text_wrap="true" colspan="2" style="text-align:right;">' + string(ABSOLUTE(tt-chk.sum-chk),"->>>>>>>>9.99") + '</td>' skip
            '</tr>' skip.
      END.   
   END.

   PUT STREAM OutStr-html UNFORMATTED
      '<tr>' skip
      '<th style="text-align: left;" >Итог:</th>' skip
      '<th colspan="6"  style="text-align:right;"> ' + string(kol-itog) + ' </th>' skip
      '<th colspan="2" style="text-align: center;">Общая сумма:</th>' skip
      '<th colspan="2" style="text-align:right;"> ' + string(ABSOLUTE(sum-itog),"->>>>>>>>9.99") + ' </th>' skip
      '</tr>' skip
      '</tbody>' skip.

END.


IF NOT tog-82 THEN 
DO:   /* без частичных возвратов */ 

   PUT STREAM OutStr-html UNFORMATTED 
      '<tbody>' skip /* Здесь начинается таблица отчета */
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th rowspan="1" colspan="11" style="text-align: center;" >Чеки возврата по топливу</th>' skip
      '</tr>' skip
      '<tr >' skip
      '<th rowspan="2" style="text-align: center;">Тип топлива</th>' skip
      '<th colspan="6" style="text-align: center;">Остальные</th>' skip
      '<th rowspan="2" style="text-align: center;">Номер чека</th>' skip
      '<th rowspan="2" style="text-align: center;">Создан в ТН</th>' skip
      '<th rowspan="2" style="text-align: center;">Цена за л.</th>' skip
      '<th rowspan="2" style="text-align: center;">Сумма по чеку</th>' skip
      '</tr>' skip
      '<tr>' skip
      '<th colspan="3" style="text-align: center;">ТРК</th>' skip
      '<th colspan="3" style="text-align: center;">Кол-во, л.</th>' skip
      '</tr>' skip.

   FOR EACH tt-chk:

      if tt-chk.is-petrol THEN 
      do:  /* если топливо       */ 
         IF tt-chk.flag = "2" OR tt-chk.flag = "4" OR tt-chk.flag = "3" OR tt-chk.flag = "0"  THEN 
         DO:
            kol-ost = kol-ost + 1.
            sum-ost = sum-ost + tt-chk.sum-chk.
            PUT STREAM OutStr-html UNFORMATTED 
               '<tr>' skip
               '<td text_wrap="true" style="text-align:left;">' + string(tt-chk.type-fuel) + '</td>' skip
               '<td colspan="3" text_wrap="true" style="text-align:right;">' + string(tt-chk.trk) + '</td>' skip
               '<td colspan="3" text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(tt-chk.qnt-chk)) + '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.chk-num) + ':' + string(tt-chk.chk-z) + '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.th) + '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.price-chk,"->>>>>>>>9.99") + '</td>' skip
               '<td text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(tt-chk.sum-chk),"->>>>>>>>9.99") + '</td>' skip
               '</tr>' skip.
         END.
      END.   
   END.

   kol-itog = kol-ost + kol-ch.
   sum-itog = sum-ost + sum-ch.

   PUT STREAM OutStr-html UNFORMATTED 
      '<tr>' skip
      '<th style="text-align: left;" >Итого по количеству:</th>' skip
      '<th colspan="4" style="text-align: left;">Общее количество остальных:</th>' skip
      '<th colspan="2" style="text-align: right;">' + string(kol-ost) + '</th>' skip
      '</tr>' skip

      '<tr>' skip
      '<th style="text-align: left;" >Итого по сумме: </th>' skip
      '<th colspan="4" style="text-align: left;">Сумма по остальным:</th>' skip
      '<th colspan="2" style="text-align: right;">' + string(ABSOLUTE(sum-ost),"->>>>>>>>9.99") + '</th>' skip
      '</tr>' skip
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th colspan="7" style="text-align: center; height:30px; border: 0px solid black" ></th>' skip
      '</tr>' skip.                   
   /* Чеки возврата по сопутствующему товару */

   PUT STREAM OutStr-html 
      '<tr>' skip /* Первые строки – шапка таблицы с тэгами tr */
      '<th colspan="11" style="text-align: center;" >Чеки возврата по сопутствующему товару</th>' skip
      '</tr>' skip
      '<tr >' skip
      '<th style="text-align: center;">Товар</th>' skip
      '<th colspan="2" style="text-align: center;">Бар-код товара</th>' skip
      '<th colspan="2" style="text-align: center;">Исходный код товара</th>' skip
      '<th colspan="3" style="text-align: center;">Номер чека</th>' skip
      '<th style="text-align: center;">Количество</th>' skip
      '<th style="text-align: center;">Создан в ТН</th>' skip
      '<th style="text-align: center;">Сумма</th>' skip
      '</tr>' skip.

   kol-itog = 0.
   sum-itog = 0.

   FOR EACH tt-chk:
      if not tt-chk.is-petrol THEN 
      do:
         kol-itog = kol-itog + 1.
         sum-itog = sum-itog + tt-chk.sum-chk.
         PUT STREAM OutStr-html UNFORMATTED 
            '<tr>' skip
            '<td text_wrap="true">' + string(tt-chk.type-fuel) + '</td>' skip
            '<td colspan="2" text_wrap="true" style="text-align: right;">' + string(tt-chk.b-code) + '</td>' skip
            '<td colspan="2" text_wrap="true" style="text-align: right;">' + string(tt-chk.is-code) + '</td>' skip
            '<td colspan="3" text_wrap="true" style="text-align: right;">' + string(tt-chk.chk-num) + ':' + string(tt-chk.chk-z) + '</td>' skip
            '<td text_wrap="true" style="text-align:right;">' + string(ABSOLUTE(tt-chk.qnt-chk)) + '</td>' skip
            '<td text_wrap="true" style="text-align:right;">' + string(tt-chk.th) + '</td>' skip
            '<td text_wrap="true" style="text-align:right;">' + string( ABSOLUTE(tt-chk.sum-chk),"->>>>>>>>9.99") + '</td>' skip
            '</tr>' skip.
      END.   
   END.

   PUT STREAM OutStr-html UNFORMATTED
      '<tr>' skip
      '<th style="text-align: left;" >Итог:</th>' skip
      '<th colspan="2" style="text-align:right;"> ' + string(kol-itog) + ' </th>' skip
      '<th colspan="2" style="text-align: left;">Общая сумма:</th>' skip
      '<th colspan="3" style="text-align:right;"> ' + string(ABSOLUTE(sum-itog),"->>>>>>>>9.99") + ' </th>' skip
      '</tr>' skip
      '</tbody>' skip .
END.

empty temp-table tt-chk.
if error-status:error then
do:
   message return-value view-as alert-box.
   return .
end.


