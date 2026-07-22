block-level on error undo, throw.
/*
$Revision: 6557e99634e7, 3192, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:28 $
$Workfile: r-klkkm.p $
$Archive: rep/r-klkkm.p $
Количество работающих ККМ на АЗК/АЗС за период
Автор: 
Дата создания: 20/12/2014
Creation date: 20/12/2014
*/
define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo. /*объект*/
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter type-pos     as character    no-undo .

def var vss-revision    as character no-undo init "$Revision: 6557e99634e7, 3192, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-klkkm.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-klkkm.p $":U .
def var vss-description as character no-undo init "Количество работающих ККМ на АЗК/АЗС за период".

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

define buffer buf_clients         for ub.clients .
define variable v-file-name-rep-htm as character no-undo.
define variable var-report-num as int no-undo.
define variable time-chk-chr as character no-undo. /* время чека txt */
define variable kassir-chr as character no-undo. 
define variable varhost-code  like ub.trn-doc.host-code  no-undo.
define variable v-host-name   as character               no-undo. /*название фирмы*/
define variable v-obj-name    as character               no-undo. /*АЗС*/
define variable var-prev-shift-date like ub.shift-obj.shift-date no-undo.
define variable var-prev-shift-num like ub.shift-obj.shift-num   no-undo.
define variable var-shift-staff   like ub.shift-staff.name       no-undo.
define stream OutStr-html.

define variable porog-zn as int     no-undo. 
define variable v-close  as logical no-undo .
FUNCTION format-etime RETURNS CHARACTER
   (INPUT p-etime AS INT64)
   :
   define variable v-datetime as character no-undo .
   define variable v-col-date as integer   no-undo .
   if p-etime = ?
      then 
   do:
      v-datetime = " " .
   end.
   /* assign
      p-etime = p-etime / 1000
    . */
   if p-etime >= 86400 then 
   do:
      v-col-date = int(p-etime / 86400) .

      if p-etime - (v-col-date * 86400) < 0 then do:
         if (v-col-date - 1) > 0 then 
      v-datetime = string((v-col-date - 1),">>>>>>>>>9") + "дн." + string( 86400 + p-etime - ((v-col-date - 1) * 86400), 'HH:MM:SS') .
      end.
      else
      v-datetime = string((v-col-date),">>>>>>>>>9") + "дн." + string(( p-etime - (v-col-date) * 86400), 'HH:MM:SS') .
   end.
   else 
   do:
      if p-etime = 0 then v-datetime = "" .
      else v-datetime = string( p-etime, 'HH:MM:SS') .
   end.
   

   return v-datetime .

END FUNCTION.

FUNCTION Type-kassa RETURNS CHARACTER
   (INPUT p-kassa AS character)
   :
   if p-kassa = ""
      then 
   do:
      return " " .
   end.
   case p-kassa:
      when "Все" then 
         return "Все" .
      when "IBM-XML" then 
         return "ППО UniFO-L" .
      when "Autotank" then 
         return "АСУ Заправщик" .

   end case .   

END FUNCTION.

FUNCTION qnty-dif-int RETURNS INTEGER
   (input p-date-End as date,
   input p-time-end as integer,
   INPUT p-date-Start AS date,
   input p-time-Start as integer) :

   define variable v-datetime as integer no-undo .
   define variable v-col-date as integer   no-undo .
   if (p-time-end - p-time-Start) < 0 then 
   do:
      v-datetime = integer(p-date-end - p-date-start - 1) * 86400  + ( 86400 + p-time-end - p-time-Start) .
   end.
   else 
   do:
      v-datetime = (p-date-end - p-date-start) * 86400 + (p-time-end - p-time-Start) .
   end.
   if v-datetime < 0 then v-datetime = 0 .
   return v-datetime .

END FUNCTION.

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

run get-report-num in parParentProc (
   output var-report-num
   ).
v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(var-report-num) + ".html".
/* Создаём временные файлы. */
output to value(v-file-name-rep-htm).
output close.
/* ******************** */
/* Шапка */
def var v-first-time as int       no-undo.
def var v-first-date as date      no-undo.
def var v-last-date  as date      no-undo.
def var v-last-time  as int       no-undo.   
 
def var filtr        as character no-undo.   
   
FOR EACH obj-list  NO-LOCK:    
   filtr = filtr + " " + obj-list.obj-name.
END. 
   
output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.
put stream OutStr-html unformatted
{ rep/htmlhead.i }
   .
put stream OutStr-html unformatted
   '<body>' skip
   '<table orientation="landscape" name = "Количество работающих ККМ" fit_to_page="true">' skip  /* таблица, в которой содержится весь отчет */
   '<thead>' skip  /* Шапка отчета */
   /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
   '<tr class="set_columns">' skip
   '<td style="width:260px"></td>' skip
   '<td style="width:180px"></td>' skip
   '<td style="width:180px"></td>' skip
   '<td style="width:180px"></td>' skip
   '<td style="width:100px"></td>' skip
   '<td style="width:250px"></td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="6"></td>' skip
   '</tr>' skip

   '<tr >' skip  
   '<td colspan="1"></td>' skip
   '<td colspan="5" style="font-size:16px;font-weight:bold;" >Количество работающих ККМ на АЗК/АЗС за период</td>' skip
   '</tr>' skip    

   '<tr>' skip  
   '<td colspan="1" style="border-bottom: 1px solid black; font-size:14px;" >Фирма:</td>' skip
   '<td colspan="5" style="border-bottom: 1px solid black; font-size:14px;" >' + string(v-host-name) + '</td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="6" style="font-size:16px;font-weight:bold;">  </td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="1" >Период:</td>' skip
   '<td colspan="5" >' string(x-Date-Start, "99.99.9999") + '-' + string(X-date-End, "99.99.9999") + '</td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="1" > Фильтры: ' + filtr + ' </td>' skip
   '<td colspan="5" > </td>' skip
   '</tr>' skip

   '<tr>' skip  
   '<td colspan="1" > Типы касс </td>' skip
   '<td colspan="5" > ' + Type-kassa(type-pos) + ' </td>' skip
   '</tr>' skip          

   '</thead>' skip
   '<tbody>' skip /* Здесь начинается таблица отчета */

   '<tr bgcolor="#C6E0B4">' skip
   /* Первые строки – шапка таблицы с тэгами tr */
   '<th rowspan="1" style="text-align: center;"> АЗК </th>' skip
   '<th rowspan="1" colspan="3" style="text-align: center;"> Длительность </th>' skip
   '<th rowspan="1" style="text-align: center;"> Количество касс </th>' skip
   '<th rowspan="1" style="text-align: center;"> Максимальное количество работающих касс за период отчета </th>' skip
   '</tr>' skip

   '<tr bgcolor="#C6E0B4">' skip
   '<td style="text-align: center;"> </td>' skip
   '<td style="text-align: center;"> с </td>' skip
   '<td style="text-align: center;"> по </td>' skip
   '<td style="text-align: center;"> всего </td>' skip
   '<td style="text-align: center;"> </td>' skip
   '<td style="text-align: center;"> </td>' skip
   '</tr>' skip
   .
 
DEFINE TEMP-TABLE tt-chk NO-UNDO
   FIELD ob-type  LIKE chk-doc.obj-type        /* тип объекта */
   FIELD ob-code  LIKE chk-doc.obj-code        /* код объекта */
   FIELD kassa    LIKE chk-doc.pay-desk        /* касса */
   FIELD smena    LIKE chk-doc.src-shift-name  /* смена */
   FIELD chk-date LIKE chk-doc.chk-date        /* дата */
   FIELD chk-time LIKE chk-doc.chk-time        
   FIELD chk-type LIKE chk-doc.chk-type
   field chk-num  like chk-doc.chk-num
   INDEX pi AS UNIQUE PRIMARY ob-code kassa chk-date chk-time
   .         
 
DEFINE TEMP-TABLE tt-period NO-UNDO
   FIELD ob-type    LIKE chk-doc.obj-type        /* тип объекта */
   FIELD ob-code    LIKE chk-doc.obj-code        /* код объекта */
   FIELD kassa      LIKE chk-doc.pay-desk        /* касса */
   FIELD smena      as integer  /* смена */
   FIELD date-beg   LIKE chk-doc.chk-date        /* дата */
   FIELD date-end   LIKE chk-doc.chk-date        /* дата */    
   FIELD time-beg   LIKE chk-doc.chk-time        
   FIELD time-end   LIKE chk-doc.chk-time    
   field qnty-kassa as integer
   FIELD FLG        AS INT   
   INDEX pi AS UNIQUE PRIMARY ob-code kassa date-beg time-beg date-end time-end
   .         
 
DEFINE TEMP-TABLE tt-tr NO-UNDO 
   FIELD npp       AS INT        /* номер строки */ 
   FIELD td_1      as character  /* значения внутри тега TD */              
   FIELD td_2_date as date    
   field td_2_time as integer           
   FIELD td_3_date as date
   field td_3_time as integer                
   FIELD td_4      as integer                
   FIELD td_5      as character                
   FIELD td_6      as character    
   field obj-code  as integer
   field obj-type  as character            
   INDEX pi AS UNIQUE PRIMARY npp obj-code obj-type 
   .   

define temp-table tt-tr-time like tt-tr .

define buffer buf_tt-chk for tt-chk .
define variable chk-sale       as character no-undo .
define variable old-shift-date as date      no-undo init ?.
define variable old-shift-num  as integer   no-undo init 0.
define variable old-time       as integer   no-undo .
define variable pay-desk       as character no-undo .
define variable v-date         as date      no-undo .
define variable nnn            as integer   no-undo .

define buffer previous-shift-obj for ub.shift-obj .
define buffer previous-rvs-doc   for ub.rvs-doc .

FOR EACH obj-list  NO-LOCK:  
   /* Смотрим по сменам */   
   if x-tog-shift then 
   do:
      nnn = 0 .
      for each ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and
         ub.shift-obj.obj-type = obj-list.obj-type and
         ub.shift-obj.shift-date >= x-Date-Start and
         ub.shift-obj.shift-date <= x-Date-End:
         if ub.shift-obj.shift-date = X-date-Start and ub.shift-obj.shift-num < X-Shift-Start then next .
         if ub.shift-obj.shift-date = X-date-End   and ub.shift-obj.shift-num > X-Shift-End then next .

         chk-sale = "" .
         for each chk-doc where chk-doc.shift-date = shift-obj.shift-date and
            chk-doc.shift-num = ub.shift-obj.shift-num and 
            chk-doc.obj-code = ub.shift-obj.obj-code and
            chk-doc.obj-type = ub.shift-obj.obj-type and
            chk-doc.chk-type = 1:
            /* тип кассы */
            FIND FIRST cash-desk WHERE cash-desk.obj-code = chk-doc.obj-code AND cash-desk.cash-num = chk-doc.pay-desk no-lock no-error.            
            IF   cash-desk.pos-type  =  type-pos OR  type-pos = 'Все' THEN 
            DO: 
               if lookup (string(chk-doc.pay-desk),chk-sale,";") = 0 then 
                  chk-sale = chk-sale + ";" + string(chk-doc.pay-desk) .

            end.
         end.

         chk-sale = trim(chk-sale,";") .

         if old-shift-date = ? and old-shift-num = 0 then 
         do:
            /* Первый проход */
            find last previous-shift-obj share-lock
               where previous-shift-obj.obj-type = obj-list.obj-type
               and previous-shift-obj.obj-code = obj-list.obj-code
               and (( previous-shift-obj.shift-date = ub.shift-obj.shift-date
               and previous-shift-obj.shift-num < ub.shift-obj.shift-num
               )
               or previous-shift-obj.shift-date < ub.shift-obj.shift-date
               )
               use-index pi no-error.
            if available previous-shift-obj then 
            do:
               find first previous-rvs-doc no-lock
                  where previous-rvs-doc.obj-type = obj-list.obj-type
                  and previous-rvs-doc.obj-code   = obj-list.obj-code
                  and previous-rvs-doc.shift-date = previous-shift-obj.shift-date
                  and previous-rvs-doc.shift-num  = previous-shift-obj.shift-num
                  and previous-rvs-doc.status_    = {&fact}
                  and previous-rvs-doc.rvs-type   = {&rvs-shift}
                  no-error.
               if available (previous-rvs-doc) then 
               do:
                  assign
                     old-shift-date = previous-rvs-doc.fact-date
                     old-shift-num  = previous-rvs-doc.shift-num
                     old-time       = previous-rvs-doc.fact-time
                     .
               end.
            end.
         end.
         nnn = nnn + 1 .
         create tt-period .
         assign
            tt-period.date-beg   = old-shift-date
            tt-period.time-beg   = old-time
            tt-period.ob-code    = obj-list.obj-code
            tt-period.ob-type    = obj-list.obj-type
            tt-period.qnty-kassa = num-entries(chk-sale,";")
            tt-period.smena      = nnn
            .               
         find first ub.rvs-doc no-lock
            where ub.rvs-doc.obj-type = obj-list.obj-type
            and ub.rvs-doc.obj-code   = obj-list.obj-code
            and ub.rvs-doc.shift-date = ub.shift-obj.shift-date
            and ub.rvs-doc.shift-num  = ub.shift-obj.shift-num
            and ub.rvs-doc.status_    = {&fact}
            and ub.rvs-doc.rvs-type   = {&rvs-shift}
            no-error.
         if available (ub.rvs-doc) then 
         do:
            assign
               old-shift-date = ub.rvs-doc.fact-date
               old-shift-num  = ub.rvs-doc.shift-num
               old-time       = ub.rvs-doc.fact-time
               .
            assign
               tt-period.date-end = ub.rvs-doc.fact-date
               tt-period.time-end = ub.rvs-doc.fact-time
               .
         end.
      end.
      for last ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and
         ub.shift-obj.obj-type = obj-list.obj-type and
         ub.shift-obj.shift-date = x-Date-End and
         ub.shift-obj.shift-num = x-Shift-End:
         if ub.shift-obj.status_ = {&sht-closed} then 
         do:
            v-close = true .
         end.

      end.
   end.
   /* Смотрим по датам */   
   else
   do:
         nnn = 0 .
         for each ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and
            ub.shift-obj.obj-type = obj-list.obj-type and
            ub.shift-obj.open-date >= x-Date-Start and
            ub.shift-obj.close-date <= x-Date-End:

            chk-sale = "" .
            for each chk-doc where chk-doc.shift-date = shift-obj.shift-date and
               chk-doc.shift-num = ub.shift-obj.shift-num and 
               chk-doc.obj-code = ub.shift-obj.obj-code and
               chk-doc.obj-type = ub.shift-obj.obj-type and
               chk-doc.chk-type = 1:
               /* тип кассы */
               FIND FIRST cash-desk WHERE cash-desk.obj-code = chk-doc.obj-code AND cash-desk.cash-num = chk-doc.pay-desk no-lock no-error.            
               IF   cash-desk.pos-type  =  type-pos OR  type-pos = 'Все' THEN 
               DO: 
                  if lookup (string(chk-doc.pay-desk),chk-sale,";") = 0 then 
                     chk-sale = chk-sale + ";" + string(chk-doc.pay-desk) .

               end.
            end.

            chk-sale = trim(chk-sale,";") .

            if old-shift-date = ? and old-shift-num = 0 then 
            do:
               /* Первый проход */
               find last previous-shift-obj share-lock
                  where previous-shift-obj.obj-type = obj-list.obj-type
                  and previous-shift-obj.obj-code = obj-list.obj-code
                  and (( previous-shift-obj.shift-date = ub.shift-obj.shift-date
                  and previous-shift-obj.shift-num < ub.shift-obj.shift-num
                  )
                  or previous-shift-obj.shift-date < ub.shift-obj.shift-date
                  )
                  use-index pi no-error.
               if available previous-shift-obj then 
               do:
                  find first previous-rvs-doc no-lock
                     where previous-rvs-doc.obj-type = obj-list.obj-type
                     and previous-rvs-doc.obj-code   = obj-list.obj-code
                     and previous-rvs-doc.shift-date = previous-shift-obj.shift-date
                     and previous-rvs-doc.shift-num  = previous-shift-obj.shift-num
                     and previous-rvs-doc.status_    = {&fact}
                     and previous-rvs-doc.rvs-type   = {&rvs-shift}
                     no-error.
                  if available (previous-rvs-doc) then 
                  do:
                     assign
                        old-shift-date = previous-rvs-doc.fact-date
                        old-shift-num  = previous-rvs-doc.shift-num
                        old-time       = previous-rvs-doc.fact-time
                        .
                  end.
               end.
            end.
            nnn = nnn + 1 .
            create tt-period .
            assign
               tt-period.date-beg   = old-shift-date
               tt-period.time-beg   = old-time
               tt-period.ob-code    = obj-list.obj-code
               tt-period.ob-type    = obj-list.obj-type
               tt-period.qnty-kassa = num-entries(chk-sale,";")
               tt-period.smena      = nnn
               .               
            find first ub.rvs-doc no-lock
               where ub.rvs-doc.obj-type = obj-list.obj-type
               and ub.rvs-doc.obj-code   = obj-list.obj-code
               and ub.rvs-doc.shift-date = ub.shift-obj.shift-date
               and ub.rvs-doc.shift-num  = ub.shift-obj.shift-num
               and ub.rvs-doc.status_    = {&fact}
               and ub.rvs-doc.rvs-type   = {&rvs-shift}
               no-error.
            if available (ub.rvs-doc) then 
            do:
               assign
                  old-shift-date = ub.rvs-doc.fact-date
                  old-shift-num  = ub.rvs-doc.shift-num
                  old-time       = ub.rvs-doc.fact-time
                  .
               assign
                  tt-period.date-end = ub.rvs-doc.fact-date
                  tt-period.time-end = ub.rvs-doc.fact-time
                  .
            end.
         end.
         for last ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and
            ub.shift-obj.obj-type = obj-list.obj-type and
            ub.shift-obj.close-date = x-Date-End:
            if ub.shift-obj.status_ = {&sht-closed} then 
            do:
               v-close = true .
            end.
         end.
      end.
   
   run proc-report .
end.

/*      FOR EACH chk-doc WHERE chk-doc.obj-code = obj-list.obj-code                                                                    */
/*         AND chk-doc.shift-date <= x-Date-End                                                                                        */
/*         AND chk-doc.shift-date >= x-Date-Start                                                                                      */
/*         AND (chk-doc.chk-type = 13 OR chk-doc.chk-type = 40 or chk-doc.chk-type = 1)                                                */
/*         NO-LOCK :                                                                                                                   */
/*         if ub.chk-doc.shift-date = X-date-Start and ub.chk-doc.shift-num < X-Shift-Start then next .                                */
/*         if ub.chk-doc.shift-date = X-date-End   and ub.chk-doc.shift-num > X-Shift-End then next .                                  */
/*                                                                                                                                     */
/*         /* тип кассы */                                                                                                             */
/*         FIND FIRST cash-desk WHERE cash-desk.obj-code = chk-doc.obj-code AND cash-desk.cash-num = chk-doc.pay-desk no-lock no-error.*/
/*         IF   cash-desk.pos-type  =  type-pos OR  type-pos = 'Все' THEN                                                              */
/*         DO:                                                                                                                         */
/*            CREATE tt-chk.                                                                                                           */
/*            ASSIGN                                                                                                                   */
/*               tt-chk.ob-code  = chk-doc.obj-code                                                                                    */
/*               tt-chk.ob-type  = chk-doc.obj-type                                                                                    */
/*               tt-chk.kassa    = chk-doc.pay-desk                                                                                    */
/*               tt-chk.chk-date = chk-doc.chk-date                                                                                    */
/*               tt-chk.chk-time = chk-doc.chk-time                                                                                    */
/*               tt-chk.smena    = chk-doc.src-shift-name                                                                              */
/*               tt-chk.chk-type = chk-doc.chk-type                                                                                    */
/*               .                                                                                                                     */
/*         END.                                                                                                                        */
/*      END.                                                                                                                           */
/*   end.                                                                                                                              */
/*   else                                                                                                                              */
/*   do:                                                                                                                               */
/*      FOR EACH chk-doc WHERE chk-doc.obj-code = obj-list.obj-code                                                                    */
/*         AND chk-doc.chk-date <= x-Date-End                                                                                          */
/*         AND chk-doc.chk-date >= x-Date-Start                                                                                        */
/*         and (chk-doc.chk-type = 13 OR chk-doc.chk-type = 40 or chk-doc.chk-type = 1)                                                */
/*         NO-LOCK :                                                                                                                   */
/*         /* тип кассы */                                                                                                             */
/*         FIND FIRST cash-desk WHERE cash-desk.obj-code = chk-doc.obj-code AND cash-desk.cash-num = chk-doc.pay-desk no-lock no-error.*/
/*         IF   cash-desk.pos-type  =  type-pos OR  type-pos = 'Все' THEN                                                              */
/*         DO:                                                                                                                         */
/*            CREATE tt-chk.                                                                                                           */
/*            ASSIGN                                                                                                                   */
/*               tt-chk.ob-code  = chk-doc.obj-code                                                                                    */
/*               tt-chk.ob-type  = chk-doc.obj-type                                                                                    */
/*               tt-chk.kassa    = chk-doc.pay-desk                                                                                    */
/*               tt-chk.chk-date = chk-doc.chk-date                                                                                    */
/*               tt-chk.chk-time = chk-doc.chk-time                                                                                    */
/*               tt-chk.smena    = chk-doc.src-shift-name                                                                              */
/*               tt-chk.chk-type = chk-doc.chk-type                                                                                    */
/*               tt-chk.chk-num  = chk-doc.chk-num                                                                                     */
/*               .                                                                                                                     */
/*         END.                                                                                                                        */
/*      END.                                                                                                                           */
/*   end.                                                                                                                              */
/*END.                                                                                                                                 */
/*                                                                                                                                     */
/*FOR EACH tt-chk NO-LOCK :                                                                                                            */
/*   /* начало периода работы кассы */                                                                                                 */
/*   IF tt-chk.chk-type = 40 THEN                                                                                                      */
/*   DO:                                                                                                                               */
/*      CREATE tt-period.                                                                                                              */
/*      ASSIGN                                                                                                                         */
/*         tt-period.ob-code  = tt-chk.ob-code                                                                                         */
/*         tt-period.kassa    = tt-chk.kassa                                                                                           */
/*         tt-period.date-beg = tt-chk.chk-date                                                                                        */
/*         tt-period.time-beg = tt-chk.chk-time                                                                                        */
/*         tt-period.smena    = tt-chk.smena                                                                                           */
/*         .                                                                                                                           */
/*   END.                                                                                                                              */
/*   /* конец периода работы кассы */                                                                                                  */
/*   ELSE IF tt-chk.chk-type = 13 AND AVAILABLE(tt-period)                                                                             */
/*         AND tt-period.ob-code = tt-chk.ob-code                                                                                      */
/*         AND tt-period.kassa = tt-chk.kassa                                                                                          */
/*         AND tt-period.smena = tt-chk.smena                                                                                          */
/*         AND ((tt-period.date-beg = tt-chk.chk-date AND tt-period.time-beg < tt-chk.chk-time)                                        */
/*         OR ( tt-period.date-beg < tt-chk.chk-date AND tt-period.time-beg > tt-chk.chk-time))                                        */
/*         THEN                                                                                                                        */
/*      DO:                                                                                                                            */
/*         ASSIGN                                                                                                                      */
/*            tt-period.date-end = tt-chk.chk-date                                                                                     */
/*            tt-period.time-end = tt-chk.chk-time                                                                                     */
/*            FLG                = 1                                                                                                   */
/*            .                                                                                                                        */
/*      END.                                                                                                                           */
/*END.                                                                                                                                 */

DEFINE VARIABLE kol-kass   AS INTEGER   NO-UNDO.
DEFINE VARIABLE kass       AS INTEGER   NO-UNDO.
DEFINE VARIABLE kol-kass2  AS INTEGER   NO-UNDO.
DEFINE VARIABLE beg-p-date AS DATE      NO-UNDO.
DEFINE VARIABLE end-p-date AS DATE      NO-UNDO.
DEFINE VARIABLE beg-p-time AS INTEGER   NO-UNDO.
DEFINE VARIABLE end-p-time AS INTEGER   NO-UNDO.
DEFINE VARIABLE dl-time    AS INT64     NO-UNDO.

DEFINE VARIABLE ch-l       AS INTEGER   NO-UNDO INITIAL 0.
DEFINE VARIABLE ch-2       AS INTEGER   NO-UNDO INITIAL 0 .
DEFINE VARIABLE nach-txt   AS CHARACTER NO-UNDO .
DEFINE VARIABLE nach-txt2  AS CHARACTER NO-UNDO .

procedure proc-report:                        
   FOR EACH tt-period no-lock where tt-period.ob-code = obj-list.obj-code and tt-period.ob-type = obj-list.obj-type break by tt-period.smena:
      if ch-l = 0 then 
      do:
         /*Первая запись*/
         ch-l = ch-l + 1.
         create tt-tr .
         ASSIGN
            tt-tr.td_2_date = tt-period.date-beg
            tt-tr.td_2_time = tt-period.time-beg
            tt-tr.td_5      = STRING(tt-period.qnty-kassa)
            tt-tr.npp       = ch-l
            tt-tr.obj-code  = tt-period.ob-code
            tt-tr.obj-type  = tt-period.ob-type
            .
         kol-kass2 = tt-period.qnty-kassa .
         kol-kass = tt-period.qnty-kassa .
         end-p-date = tt-period.date-end .
         end-p-time = tt-period.time-end .

      end.
      else 
      do:
         if kol-kass <> tt-period.qnty-kassa then 
         do:
            find first tt-tr where tt-tr.npp = ch-l no-error .
            if available (tt-tr) then 
            do:
               assign
                  tt-tr.td_3_date = end-p-date
                  tt-tr.td_3_time = end-p-time
                  tt-tr.td_4      = qnty-dif-int(tt-tr.td_3_date, tt-tr.td_3_time, tt-tr.td_2_date, tt-tr.td_2_time)
                  .
            end.

            ch-l = ch-l + 1.
            create tt-tr .
            ASSIGN
               tt-tr.td_2_date = tt-period.date-beg
               tt-tr.td_2_time = tt-period.time-beg
               tt-tr.td_5      = STRING(tt-period.qnty-kassa)
               tt-tr.npp       = ch-l
               tt-tr.obj-code  = tt-period.ob-code
               tt-tr.obj-type  = tt-period.ob-type
               .
            if kol-kass2 <= tt-period.qnty-kassa then kol-kass2 = tt-period.qnty-kassa . /* общее кол-во касс */

            kol-kass = tt-period.qnty-kassa .
            end-p-date = tt-period.date-end .
            end-p-time = tt-period.time-end .

         end.
         else 
         do:
            end-p-date = tt-period.date-end .
            end-p-time = tt-period.time-end .
         end.

      end.
      if last-of (tt-period.smena) then 
      do:
         if v-close = true and available(tt-tr) then 
         do:
            assign
               tt-tr.td_3_date = tt-period.date-end
               tt-tr.td_3_time = tt-period.time-end
               tt-tr.td_4      = qnty-dif-int(tt-tr.td_3_date, tt-tr.td_3_time, tt-tr.td_2_date, tt-tr.td_2_time)
               .
         end .
      end.
      
   end.

   /*      FIND FIRST buf_tt-chk WHERE buf_tt-chk.chk-date = tt-chk.chk-date AND buf_tt-chk.chk-time > tt-chk.chk-time NO-ERROR.                                                                                                                                       */
   /*      IF AVAILABLE  buf_tt-chk THEN                                                                                                                                                                                                                               */
   /*      DO:                                                                                                                                                                                                                                                         */
   /*         end-p-date = buf_tt-chk.chk-date.                                                                                                                                                                                                                        */
   /*         end-p-time = buf_tt-chk.chk-time.                                                                                                                                                                                                                        */
   /*      END.                                                                                                                                                                                                                                                        */
   /*                                                                                                                                                                                                                                                                  */
   /*      kol-kass = 0.                                                                                                                                                                                                                                               */
   /*      FOR EACH tt-period WHERE tt-chk.chk-date >= tt-period.date-beg                                                                                                                                                                                              */
   /*         AND tt-chk.chk-time >= tt-period.time-beg                                                                                                                                                                                                                */
   /*         AND tt-chk.chk-date <= tt-period.date-end                                                                                                                                                                                                                */
   /*         AND tt-chk.chk-time <= tt-period.time-end                                                                                                                                                                                                                */
   /*         NO-LOCK:                                                                                                                                                                                                                                                 */
   /*                                                                                                                                                                                                                                                                  */
   /*         kol-kass = kol-kass + 1 .                                                                                                                                                                                                                                */
   /*         IF kol-kass2 <= kol-kass THEN  kol-kass2 = kol-kass.                                                                                                                                                                                                     */
   /*                                                                                                                                                                                                                                                                  */
   /*         beg-p-date = tt-period.date-beg.                                                                                                                                                                                                                         */
   /*         beg-p-time = tt-period.time-beg.                                                                                                                                                                                                                         */
   /*      END.                                                                                                                                                                                                                                                        */
   /*                                                                                                                                                                                                                                                                  */
   /*      dl-time = DATETIME(end-p-date, end-p-time) - DATETIME(tt-chk.chk-date, tt-chk.chk-time) .                                                                                                                                                                   */
   /*                                                                                                                                                                                                                                                                  */
   /*      ch-l = ch-l + 1.                                                                                                                                                                                                                                            */
   /*                                                                                                                                                                                                                                                                  */
   /*      CREATE tt-tr.                                                                                                                                                                                                                                               */
   /*      ASSIGN                                                                                                                                                                                                                                                      */
   /*         tt-tr.td_2_date = tt-chk.chk-date                                                                                                                                                                                                                        */
   /*         tt-tr.td_2_time = tt-chk.chk-time                                                                                                                                                                                                                        */
   /*         tt-tr.td_3_date = end-p-date                                                                                                                                                                                                                             */
   /*         tt-tr.td_3_time = end-p-time                                                                                                                                                                                                                             */
   /*         tt-tr.td_5      = STRING(kol-kass)                                                                                                                                                                                                                       */
   /*         tt-tr.npp       = ch-l                                                                                                                                                                                                                                   */
   /*         .                                                                                                                                                                                                                                                        */
   /*                                                                                                                                                                                                                                                                  */
   /*      ch-2 = kol-kass.                                                                                                                                                                                                                                            */
   /*      nach-txt = STRING(tt-chk.chk-date, "99.99.9999") + ' ' + string(tt-chk.chk-time, "HH:MM").                                                                                                                                                                  */
   /*                                                                                                                                                                                                                                                                  */
   /*   END.                                                                                                                                                                                                                                                           */
   /*                                                                                                                                                                                                                                                                  */
   /*   define variable chk-qnty     as integer no-undo .                                                                                                                                                                                                              */
   /*   define variable end-chk-date as date    no-undo init ?.                                                                                                                                                                                                        */
   /*   define variable end-chk-time as integer no-undo init 0.                                                                                                                                                                                                        */
   /*                                                                                                                                                                                                                                                                  */
   /*   for each tt-tr where integer(tt-tr.td_5) > 0:                                                                                                                                                                                                                  */
   /*      if chk-qnty = 0 then                                                                                                                                                                                                                                        */
   /*      do:                                                                                                                                                                                                                                                         */
   /*         if can-find (first tt-chk where tt-chk.ob-code = obj-list.obj-code and tt-chk.ob-type = obj-list.obj-type and                                                                                                                                            */
   /*            tt-chk.chk-type = 1 and tt-chk.chk-date >= tt-tr.td_2_date and tt-chk.chk-time >= tt-tr.td_2_time and                                                                                                                                                 */
   /*            tt-chk.chk-date <= tt-tr.td_3_date and tt-chk.chk-time <= tt-tr.td_3_time) then                                                                                                                                                                       */
   /*         do:                                                                                                                                                                                                                                                      */
   /*            create tt-tr-time .                                                                                                                                                                                                                                   */
   /*            assign                                                                                                                                                                                                                                                */
   /*               tt-tr-time.npp       = tt-tr.npp                                                                                                                                                                                                                   */
   /*               tt-tr-time.td_1      = tt-tr.td_1                                                                                                                                                                                                                  */
   /*               tt-tr-time.td_2_date = tt-tr.td_2_date                                                                                                                                                                                                             */
   /*               tt-tr-time.td_2_time = tt-tr.td_2_time                                                                                                                                                                                                             */
   /*               tt-tr-time.td_5      = tt-tr.td_5                                                                                                                                                                                                                  */
   /*               .                                                                                                                                                                                                                                                  */
   /*            chk-qnty = integer(tt-tr.td_5).                                                                                                                                                                                                                       */
   /*            end-chk-date = tt-tr.td_3_date .                                                                                                                                                                                                                      */
   /*            end-chk-time = tt-tr.td_3_time .                                                                                                                                                                                                                      */
   /*         end.                                                                                                                                                                                                                                                     */
   /*      end.                                                                                                                                                                                                                                                        */
   /*      else                                                                                                                                                                                                                                                        */
   /*      do:                                                                                                                                                                                                                                                         */
   /*         end-chk-date = tt-tr.td_3_date .                                                                                                                                                                                                                         */
   /*         end-chk-time = tt-tr.td_3_time .                                                                                                                                                                                                                         */
   /*         if chk-qnty <> integer(tt-tr.td_5) then                                                                                                                                                                                                                  */
   /*         do:                                                                                                                                                                                                                                                      */
   /*            find last tt-tr-time no-error .                                                                                                                                                                                                                       */
   /*            if available (tt-tr-time) then                                                                                                                                                                                                                        */
   /*            do:                                                                                                                                                                                                                                                   */
   /*               assign                                                                                                                                                                                                                                             */
   /*                  tt-tr-time.td_3_date = tt-tr.td_3_date                                                                                                                                                                                                          */
   /*                  tt-tr-time.td_3_time = tt-tr.td_3_time                                                                                                                                                                                                          */
   /*                  tt-tr-time.td_4      = string(tt-tr-time.td_3_date - tt-tr-time.td_2_date) + " дн. " + string(SUBSTRING( (format-etime(tt-tr-time.td_3_time - tt-tr-time.td_2_time)),(LENGTH(format-etime(tt-tr-time.td_3_time - tt-tr-time.td_2_time)) - 8 ) ))*/
   /*                  .                                                                                                                                                                                                                                               */
   /*               chk-qnty = 0 .                                                                                                                                                                                                                                     */
   /*            end.                                                                                                                                                                                                                                                  */
   /*         end.                                                                                                                                                                                                                                                     */
   /*      end.                                                                                                                                                                                                                                                        */
   /*   end.                                                                                                                                                                                                                                                           */

   CREATE tt-tr.
   ASSIGN
      tt-tr.npp  = 0
      tt-tr.td_1 = obj-list.obj-name
      tt-tr.td_6 = STRING(kol-kass2)
      .
   kol-kass2 = 0 .
   kol-kass = 0 .
   RUN itog_azs.

end procedure .

put stream OutStr-html unformatted 
   '</tbody> 'skip
   '</table>'skip
   ' </body>'skip
   ' </html> 'skip.
 
PROCEDURE itog_azs:

   FOR EACH tt-tr NO-LOCK:
      if tt-tr.npp = 0 then 
      do:   
         put stream OutStr-html unformatted 
            '<tr bgcolor="#F8CBAD">' skip
            '<td style="text-align:center;">' tt-tr.td_1 '</td>' skip
            '<td style="text-align:center;">' '</td>' skip
            '<td style="text-align:center;">' '</td>' skip
            '<td style="text-align:center;">' format-etime(tt-tr.td_4) '</td>' skip
            '<td style="text-align:center;">' tt-tr.td_5 '</td>' skip
            '<td style="text-align:center;">' tt-tr.td_6 '</td>' skip
            '</tr>' skip
            . 
      end.
      else if tt-tr.npp <> 0 then 
         do:
            put stream OutStr-html unformatted
               '<tr >' skip
               '<td style="text-align:center;">' tt-tr.td_1 '</td>' skip
               '<td style="text-align:center;">' STRING(tt-tr.td_2_date, "99.99.9999") + ' ' + format-etime(tt-tr.td_2_time) '</td>' skip
               '<td style="text-align:center;">' if tt-tr.td_3_date <> ? then (STRING(tt-tr.td_3_date, "99.99.9999") + ' ' + format-etime(tt-tr.td_3_time)) else "" '</td>' skip
               '<td style="text-align:center;">' format-etime(tt-tr.td_4) '</td>' skip
               '<td style="text-align:center;">' if tt-tr.td_3_date <> ? then tt-tr.td_5 else "" '</td>' skip
               '<td style="text-align:center;">' tt-tr.td_6 '</td>' skip       
               '</tr>' skip
               . 
         end. 
   end.

   EMPTY TEMP-TABLE tt-tr.

END PROCEDURE.

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
    
    
