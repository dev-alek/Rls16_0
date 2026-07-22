block-level on error undo, throw.
/*
$Revision: 9c0a3724b62e, 3232, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:29 $
$Workfile: r-preal.p $
$Archive: rep/r-preal.p $
Отчет по анализу длительности пересменка (Простой реализации до первого чека)
Автор: 
Дата создания: 20/12/2014
Creation date: 20/12/2014
*/

define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo. /*объект*/
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter porog-zn as INTEGER    no-undo .
define input parameter type-pos as character   no-undo .
define input parameter t-shift  as logical    no-undo .

def var vss-revision    as character no-undo init "$Revision: 9c0a3724b62e, 3232, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: 2022/12/27 12:54:29 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-preal.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-preal.p $":U .
def var vss-description as character no-undo init "Отчет по анализу длительности пересменка (Простой реализации до первого чека)".

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

FUNCTION format-etime RETURNS CHARACTER
   (INPUT p-etime AS INT64)
   :
   define variable v-datetime as character no-undo .
   define variable v-col-date as integer   no-undo .

   if p-etime = ? 
      then 
   do:
      return " " .
   end.
   /* assign
      p-etime = p-etime / 1000
    . */
   if p-etime >= 86400 then 
   do:
      v-col-date = int(p-etime / 86400) .

      if p-etime - (v-col-date * 86400) < 0 then 
      do:
         if (v-col-date - 1) > 0 then 
            v-datetime = string((v-col-date - 1),">>>>>>>>>9") + "дн." + string( 86400 + p-etime - ((v-col-date - 1) * 86400), 'HH:MM:SS') .
      end.
      else
         v-datetime = string((v-col-date),">>>>>>>>>9") + "дн." + string(( p-etime - (v-col-date) * 86400), 'HH:MM:SS') .
   end.
   else 
   do:
      v-datetime = string( p-etime, 'HH:MM:SS') .
   end.

   return v-datetime .

END FUNCTION.

FUNCTION qnty-dif-int RETURNS INTEGER
   (input p-date-End as date,
   input p-time-end as integer,
   INPUT p-date-Start AS date,
   input p-time-Start as integer) :

   define variable v-datetime as integer no-undo .
   define variable v-col-date as integer no-undo .
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

FUNCTION qnty-dif RETURNS CHARACTER
   (input p-date-End as date,
   input p-time-end as integer,
   INPUT p-date-Start AS date,
   input p-time-Start as integer) :
   define variable v-datetime as character no-undo .
   define variable v-col-date as integer   no-undo .
   if (p-time-end - p-time-Start) < 0 then 
   do:
      v-datetime = string(p-date-end - p-date-start - 1) + " " +
         string((86400 + (p-time-end - p-time-Start)),"HH:MM:SS") .
   end.
   else 
   do:
      v-datetime = string(p-date-end - p-date-start) + " " +
         string((p-time-end - p-time-Start),"HH:MM:SS") .
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
   '<body orientation="landscape" name = "Отчет по пересменкам" fit_to_page="true">' skip
   '<table>' skip  /* таблица, в которой содержится весь отчет */
   '<thead>' skip
                      
   '<tr class="set_columns">' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:250px"></td>' skip
   '<td style="width:250px"></td>' skip
   '<td style="width:250px"></td>' skip
   '<td style="width:200px"></td>' skip
   '<td style="width:200px"></td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="7"></td>' skip
   '</tr>' skip

   '<tr style="height:30px;">' skip  
   '<td colspan="1"> </td>' skip
   '<td colspan="6" style="font-weight:bold;"><b> Анализ длительности пересменки ( Простой реализации до первого чека ) </b></td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="1"></td>' skip
   '<td colspan="6"></td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="1"> Фирма: </td>' skip
   '<td colspan="6">' + string(v-host-name) + '</td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="1" > Период: </td>' skip
   '<td colspan="6" > ' + string(x-Date-Start, "99.99.9999") + ' - ' + string(X-date-End, "99.99.9999") + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1" > Фильтры: </td>' skip
   '<td colspan="6" >' + string(filtr) + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="1" > Порог: </td>' skip
   '<td colspan="6" >' + format-etime(porog-zn * 60) + '</td>' skip
   '</tr>' skip

   '<tr>' skip
   '<td colspan="1" > Типы касс: </td>' skip
   '<td colspan="6" >' + Type-kassa(type-pos) + '</td>' skip
   '</tr>' skip
   '<tr>' skip
   '<td colspan="7"></td>' skip
   '</tr>' skip          
   '</thead>' skip
   '<tbody>' skip  /* Здесь начинается таблица отчета */
   '<tr bgcolor="#C6E0B4">' skip /* Первые строки – шапка таблицы с тэгами tr */
   '<th bgcolor="#C6E0B4" rowspan="2" style="text-align: center;">Наименование объекта</th>' skip
   '<th bgcolor="#C6E0B4" rowspan="2" style="text-align: center;">Дата/Номер смены</th>' skip
   '<th bgcolor="#C6E0B4" rowspan="2" colspan="5"  style="text-align: center;">Простой реализации на АЗК/АЗС</th>' skip
   '</tr>' skip
   '<tr>' skip
   '</tr>' skip
   '<tr bgcolor="#C6E0B4">' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Номер кассы</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Тип кассы</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Старший смены</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Дата/время последнего чека продажи</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Дата/время первого чека продажи</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Время простоя реализации</th>' skip
   '<th bgcolor="#C6E0B4" style="text-align: center;">Время превышения установленного порога простоя реализации</th>' skip
   '</tr>' skip
   .

DEFINE TEMP-TABLE tt-peresmen NO-UNDO
   FIELD ob-type      LIKE chk-doc.obj-type      /* тип объекта */
   FIELD kod-azs      like chk-doc.obj-code      /* код объекта */
   FIELD name-azs     as character                
   FIELD kassa        LIKE chk-doc.pay-desk      /* касса */
   FIELD kassir       like chk-doc.cashier       /* кассир */
   FIELD kassir2      like chk-doc.cashier-psn-code /* кассир */
   FIELD shift-num    like chk-doc.shift-num     /* номер смены */
   FIELD shift-date   like chk-doc.shift-date    /*дата смены */
   FIELD chk-date-beg like chk-doc.shift-date    /*дата смены */
   FIELD chk-date-end like chk-doc.shift-date    /*дата смены */
   FIELD chk-time-beg like chk-doc.chk-time      /* начало пересменки */
   FIELD chk-time-end like chk-doc.chk-time      /* конец пересменки */
   FIELD peresm-date  as date      /*дата пересменки */
   FIELD peresm-num   as integer      /*номер пересменки */
   FIELD time-p       AS INT                      /* длительность */
   FIELD npp          AS INT                      /* номер пересменки */
   FIELD shift-name   like chk-doc.shift-name    /* номер смены */
   FIELD flg          AS INT                      
   field more         as character    
   field chk-num-beg  like chk-doc.doc-code
   field chk-num-end  like chk-doc.doc-code
   INDEX pi AS UNIQUE PRIMARY kod-azs kassa peresm-date npp    
   .         

DEFINE TEMP-TABLE tt-period NO-UNDO
   FIELD obj-type       LIKE chk-doc.obj-type      /* тип объекта */
   FIELD obj-code       like chk-doc.obj-code      /* код объекта */
   FIELD obj-name       as character                
   FIELD shift-num-beg  like chk-doc.shift-num     /* номер смены */
   FIELD shift-date-beg like chk-doc.shift-date    /*дата смены */
   FIELD shift-num-end  like chk-doc.shift-num     /* номер смены */
   FIELD shift-date-end like chk-doc.shift-date    /*дата смены */
   FIELD npp            AS INT                      /* номер пересменки */
   FIELD flg            AS INT      
   FIELD shift-date     as date      /*дата пересменки */
   FIELD shift-num      as integer      /*номер пересменки */          
   INDEX pi AS UNIQUE PRIMARY npp obj-type obj-code
   . 
   
DEFINE TEMP-TABLE tt-tr NO-UNDO 
   FIELD npp       AS INT         /* номер строки */ 
   FIELD td_1      as character   /* значения внутри тега TD */              
   FIELD td_2      as character                
   FIELD td_3      as character                
   FIELD td_4_date as date               
   FIELD td_5_date as date
   FIELD td_4_time as integer                
   FIELD td_5_time as integer 
   FIELD td_6      as integer                
   FIELD td_7      as integer
   field td_8_date as date
   field td_8_num  as integer
   field td_9      as character           
   INDEX pi AS UNIQUE PRIMARY npp 
   .         

define variable smena_old         as CHARACTER no-undo. 
define variable kassa_old         as INTEGER   no-undo. 		
define variable kod-azs_old       as INTEGER   no-undo. 		
define variable shift-date_old    as DATE      no-undo. 		
DEFINE VARIABLE nom_p             as int       init 0 NO-UNDO.

DEFINE VARIABLE time-p-all        AS INT       NO-UNDO.		
DEFINE VARIABLE time-kas          AS INT       NO-UNDO init 0.		
DEFINE VARIABLE time-azs          AS INT       NO-UNDO init 0.
DEFINE VARIABLE time-azs-all      AS INT       NO-UNDO init 0.     		

DEFINE VARIABLE kassir1           AS int       NO-UNDO init 0.
DEFINE VARIABLE kod-azs2          AS int       NO-UNDO init 0.
DEFINE VARIABLE name-azs2         AS CHARACTER NO-UNDO.
DEFINE VARIABLE manager           AS CHARACTER NO-UNDO.    /* Старший смены */
DEFINE VARIABLE date_it           AS DATE      NO-UNDO.
DEFINE VARIABLE ch-1              AS int       NO-UNDO init 1.		
DEFINE VARIABLE ch-2              AS int       NO-UNDO init 0.		

DEFINE VARIABLE kol-prev          AS int       NO-UNDO init 0.		    /* количество превышений */
DEFINE VARIABLE kol-prev-all      AS int       NO-UNDO init 0.         /* количество превышений */
DEFINE VARIABLE kol-prev-kassa    AS int       NO-UNDO init 0.	/* количество превышений по кассе */
DEFINE VARIABLE kol-prev-azs      AS int       NO-UNDO init 0.		/* количество превышений  по АЗС */
DEFINE VARIABLE kol-prev-azs-all  AS int       NO-UNDO init 0.     /* количество превышений  по АЗС */

DEFINE VARIABLE kol-per           AS int       NO-UNDO init 0.		    /* количество превышений */
DEFINE VARIABLE kol-per-kassa     AS int       NO-UNDO init 0.	/* количество превышений по кассе */
DEFINE VARIABLE kol-per-azs       AS int       NO-UNDO init 0.		/* количество превышений  по АЗС */
DEFINE VARIABLE kol-per-azs-all   AS int       NO-UNDO init 0.     /* количество превышений  по АЗС */

DEFINE VARIABLE time-prev-kassa   AS int       NO-UNDO init 0.	/* время превышений*/	
DEFINE VARIABLE time-prev-azs     AS int       NO-UNDO init 0.	/* время превышений*/	
DEFINE VARIABLE time-prev-azs-all AS int       NO-UNDO init 0.  /* время превышений*/
DEFINE VARIABLE time-prev         AS int       NO-UNDO init 0.	/* время превышений*/	

DEFINE VARIABLE time-pr-sv        AS int       NO-UNDO init 0.	/* среднее время превышений*/
DEFINE VARIABLE time-pr-sv-all    AS int       NO-UNDO init 0.  /* среднее время превышений*/

DEFINE VARIABLE prm-1             AS int       NO-UNDO .
DEFINE VARIABLE prm-1-all         AS int       NO-UNDO .
DEFINE VARIABLE prm-2             AS int       NO-UNDO .
DEFINE VARIABLE prm-3             AS int       NO-UNDO .
DEFINE VARIABLE prm-4             AS int       NO-UNDO .
DEFINE VARIABLE prm-4-all         AS int       NO-UNDO .
define variable v-date            as date      no-undo .
define variable shift-date-start  as date      no-undo .
define variable shift-num-start   as integer   no-undo .
define variable v-date-obj        as date      no-undo .
define buffer buf_shift-obj   for ub.shift-obj .
define buffer bf_shift-obj    for ub.shift-obj .
define buffer buf_tt-tr       for tt-tr .
define buffer buf_tt-peresmen for tt-peresmen .

FOR EACH obj-list  NO-LOCK:
   if x-tog-shift then 
   do:
      for last ub.shift-obj no-lock where ub.shift-obj.obj-code = obj-list.obj-code and
         ub.shift-obj.obj-type = obj-list.obj-type and
         (ub.shift-obj.shift-date < x-Date-Start or 
         (ub.shift-obj.shift-date = x-Date-Start and ub.shift-obj.shift-num < x-Shift-Start)):
         create tt-period .
         assign
            tt-period.obj-code       = ub.shift-obj.obj-code
            tt-period.obj-type       = ub.shift-obj.obj-type
            tt-period.obj-name       = obj-list.obj-name
            tt-period.shift-date-beg = ub.shift-obj.shift-date
            tt-period.shift-num-beg  = ub.shift-obj.shift-num
            .
      end.
      if not available (tt-period) then 
      do:
         create tt-period .
         assign
            tt-period.obj-code = obj-list.obj-code
            tt-period.obj-type = obj-list.obj-type
            tt-period.obj-name = obj-list.obj-name
            .
      end.
         
      for each ub.shift-obj no-lock where ub.shift-obj.obj-code = tt-period.obj-code and
         ub.shift-obj.obj-type = tt-period.obj-type and
         ub.shift-obj.shift-date >= tt-period.shift-date-beg and 
         ub.shift-obj.shift-date <= x-Date-End:
         if ub.shift-obj.shift-date = tt-period.shift-date-beg and ub.shift-obj.shift-num <= tt-period.shift-num-beg then next .
         if ub.shift-obj.shift-date = x-date-End   and ub.shift-obj.shift-num > x-Shift-End then next .
         nom_p = nom_p + 1 .
         assign
            tt-period.shift-date-end = ub.shift-obj.shift-date
            tt-period.shift-num-end  = ub.shift-obj.shift-num
            tt-period.shift-num      = tt-period.shift-num-end
            tt-period.shift-date     = tt-period.shift-date-end
            tt-period.npp            = nom_p
            tt-period.flg            = 1
            .
         create tt-period .
         assign
            tt-period.obj-code       = ub.shift-obj.obj-code
            tt-period.obj-type       = ub.shift-obj.obj-type
            tt-period.obj-name       = obj-list.obj-name
            tt-period.shift-date-beg = ub.shift-obj.shift-date
            tt-period.shift-num-beg  = ub.shift-obj.shift-num
            .
      end.
           
   end.
   else 
   do:
      /* Ищем первую открытую смену */
      for first buf_shift-obj no-lock where buf_shift-obj.obj-code = obj-list.obj-code and
         buf_shift-obj.obj-type = obj-list.obj-type and
         buf_shift-obj.shift-date >= x-Date-Start:
         /* Ищем предыдущую смену */
         for last ub.shift-obj no-lock where ub.shift-obj.obj-code = buf_shift-obj.obj-code and
            ub.shift-obj.obj-type = buf_shift-obj.obj-type and
            (ub.shift-obj.shift-date < buf_shift-obj.shift-date or 
            (ub.shift-obj.shift-date = buf_shift-obj.shift-date and ub.shift-obj.shift-num < buf_shift-obj.shift-num)):
  
            create tt-period .
            assign
               tt-period.obj-code       = ub.shift-obj.obj-code
               tt-period.obj-type       = ub.shift-obj.obj-type
               tt-period.obj-name       = obj-list.obj-name
               tt-period.shift-date-beg = ub.shift-obj.shift-date
               tt-period.shift-num-beg  = ub.shift-obj.shift-num
               .
         end.         
      end.

      if not available (tt-period) then 
      do:
         create tt-period .
         assign
            tt-period.obj-code = obj-list.obj-code
            tt-period.obj-type = obj-list.obj-type
            tt-period.obj-name = obj-list.obj-name
            .
      end.

      for each ub.shift-obj no-lock where ub.shift-obj.obj-code = tt-period.obj-code and
         ub.shift-obj.obj-type = tt-period.obj-type and
         ub.shift-obj.shift-date >= tt-period.shift-date-beg and 
         ub.shift-obj.shift-date <= x-Date-End:
         if ub.shift-obj.shift-date = tt-period.shift-date-beg and ub.shift-obj.shift-num <= tt-period.shift-num-beg then next .
/*         if ub.shift-obj.shift-date = x-date-End   and ub.shift-obj.shift-num > x-Shift-End then next .*/
         nom_p = nom_p + 1 .
         assign
            tt-period.shift-date-end = ub.shift-obj.shift-date
            tt-period.shift-num-end  = ub.shift-obj.shift-num
            tt-period.shift-num      = tt-period.shift-num-end
            tt-period.shift-date     = tt-period.shift-date-end
            tt-period.npp            = nom_p
            tt-period.flg            = 1
            .
         create tt-period .
         assign
            tt-period.obj-code       = ub.shift-obj.obj-code
            tt-period.obj-type       = ub.shift-obj.obj-type
            tt-period.obj-name       = obj-list.obj-name
            tt-period.shift-date-beg = ub.shift-obj.shift-date
            tt-period.shift-num-beg  = ub.shift-obj.shift-num
            .
      end.
   end.
end.

if type-pos = "Все" then 
do:
   type-pos = "IBM-XML,Autotank" .
end.

nom_p = 0 .

FOR EACH tt-period where tt-period.flg = 1 BREAK BY tt-period.obj-code BY tt-period.npp:   
   for each ub.cash-desk no-lock where ub.cash-desk.obj-code = tt-period.obj-code:
      if lookup (string(cash-desk.pos-type),type-pos,",") = 0 then next .
      /* последний чек продажи перед закрытием смены */
      FIND LAST chk-doc WHERE  chk-doc.chk-type = 1   
         and chk-doc.obj-code = tt-period.obj-code
         AND chk-doc.shift-date = tt-period.shift-date-beg
         and chk-doc.shift-num = tt-period.shift-num-beg
         AND chk-doc.pay-desk = ub.cash-desk.cash-num no-lock no-error.
      IF AVAILABLE chk-doc THEN 
      do: 
         CREATE tt-peresmen.
         ASSIGN
            tt-peresmen.kod-azs      = chk-doc.obj-code
            tt-peresmen.kassa        = chk-doc.pay-desk
            tt-peresmen.chk-time-beg = chk-doc.chk-time
            tt-peresmen.chk-date-beg = chk-doc.chk-date
            tt-peresmen.shift-num    = chk-doc.shift-num
            tt-peresmen.shift-date   = chk-doc.shift-date
            tt-peresmen.chk-num-beg  = chk-doc.doc-code
            tt-peresmen.peresm-date  = chk-doc.shift-date
            tt-peresmen.peresm-num   = chk-doc.shift-num
            . 
      END.
      else 
      do:
         FIND LAST chk-doc WHERE  chk-doc.chk-type = 1   
            and chk-doc.obj-code = tt-period.obj-code
            AND chk-doc.pay-desk = ub.cash-desk.cash-num
            AND ((chk-doc.shift-date = tt-period.shift-date-beg
            and chk-doc.shift-num < tt-period.shift-num-beg) or 
            (chk-doc.shift-date < tt-period.shift-date-beg and
            chk-doc.shift-date > tt-period.shift-date-beg - 30))
            no-lock no-error.
         IF AVAILABLE chk-doc THEN 
         do: 
            CREATE tt-peresmen.
            ASSIGN
               tt-peresmen.kod-azs      = chk-doc.obj-code
               tt-peresmen.kassa        = chk-doc.pay-desk
               tt-peresmen.chk-time-beg = chk-doc.chk-time
               tt-peresmen.chk-date-beg = chk-doc.chk-date
               tt-peresmen.shift-num    = chk-doc.shift-num
               tt-peresmen.shift-date   = chk-doc.shift-date
               tt-peresmen.chk-num-beg  = chk-doc.doc-code
               tt-peresmen.peresm-date  = chk-doc.shift-date
               tt-peresmen.peresm-num   = chk-doc.shift-num
               . 
         end.
         else 
         do:
            CREATE tt-peresmen.
            ASSIGN
               tt-peresmen.kod-azs     = tt-period.obj-code
               tt-peresmen.kassa       = ub.cash-desk.cash-num
               tt-peresmen.peresm-date = tt-period.shift-date-beg
               tt-peresmen.peresm-num  = tt-period.shift-num-beg
               . 
         end.         
      end.
      FIND FIRST chk-doc WHERE  chk-doc.chk-type = 1 
         AND chk-doc.obj-code = tt-period.obj-code
         AND chk-doc.shift-date = tt-period.shift-date-end
         AND chk-doc.pay-desk = ub.cash-desk.cash-num 
         AND chk-doc.shift-num = tt-period.shift-num-end
         no-lock no-error.
      IF AVAILABLE chk-doc THEN 
      do: 
         nom_p = nom_p + 1.
         ASSIGN
            tt-peresmen.chk-time-end = chk-doc.chk-time
            tt-peresmen.chk-date-end = chk-doc.chk-date
            tt-peresmen.shift-num    = chk-doc.shift-num
            tt-peresmen.npp          = nom_p
            tt-peresmen.name-azs     = tt-period.obj-name
            tt-peresmen.kassir       = chk-doc.cashier
            tt-peresmen.kassir2      = chk-doc.cashier-psn-code
            tt-peresmen.shift-date   = chk-doc.shift-date
            tt-peresmen.chk-num-end  = chk-doc.doc-code
            tt-peresmen.flg          = 1
            .
         if tt-peresmen.kod-azs = 0 then 
            ASSIGN
               tt-peresmen.kod-azs = chk-doc.obj-code
               tt-peresmen.kassa   = chk-doc.pay-desk
               .    
         tt-peresmen.time-p = qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg).
      END.    
      else delete tt-peresmen .
   end.
end.
define variable v-obj as logical no-undo .
for each obj-list:
   v-obj = false .
for each tt-period NO-LOCK where tt-period.flg = 1 and tt-period.obj-code = obj-list.obj-code and
      tt-period.obj-type = obj-list.obj-type BREAK BY tt-period.obj-code BY tt-period.npp:
   for each tt-peresmen where tt-peresmen.shift-date = tt-period.shift-date and
      tt-peresmen.shift-num = tt-period.shift-num and
      tt-peresmen.kod-azs = tt-period.obj-code and
      tt-peresmen.flg = 1: 
      /* Старший смены */
      FIND FIRST shift-staff WHERE tt-peresmen.kod-azs = shift-staff.obj-code
         AND shift-staff.staff-role = yes 
         AND shift-staff.shift-date = tt-peresmen.shift-date
         and shift-staff.shift-num = tt-peresmen.shift-num
         no-lock no-error.
      IF AVAILABLE shift-staff THEN manager = shift-staff.name. 
      else 
      do:
         FIND FIRST shift-staff WHERE tt-peresmen.kod-azs = shift-staff.obj-code
            AND shift-staff.shift-date = tt-peresmen.shift-date
            and shift-staff.shift-num = tt-peresmen.shift-num
            no-lock no-error.
         IF AVAILABLE shift-staff THEN manager = shift-staff.name.       
      end.
      /* тип кассы */
      FIND FIRST cash-desk WHERE cash-desk.obj-code =  tt-peresmen.kod-azs  
         AND cash-desk.cash-num = tt-peresmen.kassa no-lock no-error.


      time-p-all = time-p-all + tt-peresmen.time-p.
      time-kas = time-kas + tt-peresmen.time-p.
      /* time-azs = time-azs + tt-peresmen.time-p. */
      ch-1 = ch-1 + 1.

      /* kol-per-azs = kol-per-azs + 1. */

      if qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg) > porog-zn * 60  then 
      do: 
      
            kol-prev-kassa = kol-prev-kassa + 1 .
            kol-prev-azs = kol-prev-azs + 1 .
            time-prev = time-prev + qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg) - porog-zn * 60 .
         /*      time-prev-azs = time-prev-azs  + qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg) - porog-zn * 60  .*/
         end.
         if tt-peresmen.chk-date-beg <> ? then kol-prev = kol-prev + 1. 
         def var td7 as int. /* время превышения порога длительности пересменка */
         if (qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg))  <=  porog-zn * 60   then  td7 = 0.   
         else  td7 = (qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg)) - porog-zn * 60 .

         CREATE tt-tr.
         ASSIGN
            tt-tr.td_1      = STRING(tt-peresmen.kassa)
            tt-tr.td_2      = Type-kassa(cash-desk.pos-type)
            tt-tr.td_3      = manager
            tt-tr.td_4_date = tt-peresmen.chk-date-beg
            tt-tr.td_5_date = tt-peresmen.chk-date-end
            tt-tr.td_4_time = tt-peresmen.chk-time-beg
            tt-tr.td_5_time = tt-peresmen.chk-time-end
            tt-tr.td_6      = qnty-dif-int(tt-peresmen.chk-date-end, tt-peresmen.chk-time-end, tt-peresmen.chk-date-beg, tt-peresmen.chk-time-beg)
            tt-tr.td_7      = td7
            tt-tr.td_8_date = tt-period.shift-date
            tt-tr.td_8_num  = tt-period.shift-num
            tt-tr.npp       = ch-1
            .

         kassir1 = tt-peresmen.kassir.
         kod-azs2 = tt-peresmen.kod-azs.
         name-azs2 = tt-peresmen.name-azs.
         manager = ''.
      end.
      find FIRST tt-tr where tt-tr.npp >= 0 and tt-tr.td_8_date = tt-period.shift-date and 
         tt-tr.td_8_num = tt-period.shift-num no-error. /* печать итога по дате если не пустые значения */
      if AVAILABLE tt-tr then 
      do:  
         v-obj = true .
         RUN itog_date.
      end.

   END.
   if v-obj then 
      RUN itog_azs .

end.
output close .
RUN itog_azs-all.

  
/* итог по отчету */
put stream OutStr-html unformatted          
   /* '<tr>' skip
            '<td>ИТОГО:</td><td></td><td></td><td></td><td></td><td></td>' skip
            '</td><td style="text-align:center;">' 
string(time-p-all, "HH:MM") '</td>' skip
         '</tr>' skip */
   '</table>'skip
   .
put stream OutStr-html unformatted 
   '</body></html> 'skip.

PROCEDURE itog_date:
   CREATE tt-tr.
   ASSIGN
      tt-tr.npp       = 0
      tt-tr.td_1      = name-azs2
      tt-tr.td_9      = string(tt-period.shift-date-end,"99.99.9999") + "/" + string(tt-period.shift-num-end) 
      tt-tr.td_8_date = tt-period.shift-date-end
      tt-tr.td_8_num  = tt-period.shift-num-end
      .

   /* Дата последнего и первого чека */
   for each buf_tt-tr where buf_tt-tr.td_8_date = tt-tr.td_8_date and
      buf_tt-tr.td_8_num = tt-tr.td_8_num and buf_tt-tr.npp <> 0 by buf_tt-tr.npp:
      if datetime(tt-tr.td_4_date, tt-tr.td_4_time) < datetime(buf_tt-tr.td_4_date, buf_tt-tr.td_4_time) or
         tt-tr.td_4_date = ? then 
         assign
            tt-tr.td_4_date = buf_tt-tr.td_4_date 
            tt-tr.td_4_time = buf_tt-tr.td_4_time
            .
      if datetime(tt-tr.td_5_date, tt-tr.td_5_time) > datetime(buf_tt-tr.td_5_date, buf_tt-tr.td_5_time) or
         tt-tr.td_5_date = ? then
         assign
            tt-tr.td_5_date = buf_tt-tr.td_5_date 
            tt-tr.td_5_time = buf_tt-tr.td_5_time
            .
   end.

   assign
      tt-tr.td_6 = qnty-dif-int(tt-tr.td_5_date, tt-tr.td_5_time, tt-tr.td_4_date, tt-tr.td_4_time).
   if tt-tr.td_6 > porog-zn * 60 then
      tt-tr.td_7 = tt-tr.td_6 - porog-zn * 60 . 
      .
  if tt-tr.td_6 <> ? then 
  do:
    kol-per-azs = kol-per-azs + 1.                 
    time-azs = time-azs + tt-tr.td_6.
    time-prev-azs = time-prev-azs  + tt-tr.td_7 .
  end.
   find first tt-tr where tt-tr.npp <> 0 and tt-tr.td_7 <> 0 and tt-tr.td_7 <> ? no-error .
   if available (tt-tr) or not t-shift then do:
   FOR EACH tt-tr no-lock:
      if tt-tr.npp = 0 then 
      do:	
         put stream OutStr-html unformatted 
            '<tr bgcolor="#F8CBAD">' skip
            '<td bgcolor="#F8CBAD" style="text-align:center;">' tt-tr.td_1 '</td>' SKIP                      
            '<td bgcolor="#F8CBAD" style="text-align:right;">' string(tt-tr.td_9) '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:center;">' tt-tr.td_3 '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' (if tt-tr.td_4_date <> ? then string(tt-tr.td_4_date, "99.99.9999") + " " + format-etime(tt-tr.td_4_time) else "") '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' (if tt-tr.td_5_date <> ? then string(tt-tr.td_5_date, "99.99.9999") + " " + format-etime(tt-tr.td_5_time) else "") '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' format-etime(tt-tr.td_6) '</td>' skip
            '<td bgcolor="#F8CBAD" style="text-align:right;">' format-etime(tt-tr.td_7) '</td>' skip 
            '</tr>' skip
            . 
      end.
      else if tt-tr.npp <> 0 and ((tt-tr.td_7 <> 0 and tt-tr.td_7 <> ?) or not t-shift) then 
         do:	
            put stream OutStr-html unformatted 
               '<tr 'if tt-tr.td_7 <> 0 and tt-tr.td_7 <> ? then 'bgcolor="#FF2400">' else 'bgcolor="#FFFFFF">' skip
               '<td style="text-align:center;">' tt-tr.td_1 '</td>' SKIP                      
               '<td style="text-align:left;">' tt-tr.td_2 '</td>' skip
               '<td style="text-align:center;">' tt-tr.td_3 '</td>' skip
               '<td style="text-align:right;">' (if tt-tr.td_4_date <> ? then string(tt-tr.td_4_date, "99.99.9999") + " " + format-etime(tt-tr.td_4_time) else "") '</td>' skip
               '<td style="text-align:right;">' (if tt-tr.td_5_date <> ? then string(tt-tr.td_5_date, "99.99.9999") + " " + format-etime(tt-tr.td_5_time) else "") '</td>' skip
               '<td style="text-align:right;">' format-etime(tt-tr.td_6) '</td>' skip
               '<td style="text-align:right;">' format-etime(tt-tr.td_7) '</td>' skip 
               '</tr>' skip
               . 
         end. 
   end.
   end.
   EMPTY TEMP-TABLE tt-tr.  
END PROCEDURE.


PROCEDURE itog_azs:

   if time-prev-azs > 0 then time-pr-sv = time-prev-azs / kol-prev-azs.  /* средняя длительность простоя с превышением  */
   if kol-per-azs <> 0 then prm-1 = time-azs / kol-per-azs .            /* средняя длительность пересменка  */
   if kol-prev > 0 then prm-4 = kol-prev-azs / kol-prev * 100 .

   put stream OutStr-html unformatted 
      '<tr>' skip
      '<th style="text-align:center;" rowspan="2">' 'Итого по: ' '</th>' SKIP                      
      '<th bgcolor="#F8CBAD" style="text-align:center;" rowspan="2" >' name-azs2 '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя длительность простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Количество случаев с превышением порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Общая длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя  длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Процент случаев простоя с превышением порогового значения от общего  кол-ва простоев' '</th>' skip
      '</tr>' skip

      '<tr >' skip
      '<td style="text-align:center;">' format-etime(prm-1) '</td>' skip
      '<td style="text-align:center;">' kol-prev-azs '</td>' skip
      '<td style="text-align:center;">' format-etime(if time-prev-azs > 0 then time-prev-azs else 0) '</td>' skip  
      '<td style="text-align:center;">' format-etime(time-pr-sv) '</td>' skip
      '<td style="text-align:center;">' + string(prm-4) + "%" + '</td>' skip 
      '</tr>' skip
      . 

   assign
      time-prev-azs-all = time-prev-azs-all + time-prev-azs
      kol-per-azs-all   = kol-per-azs-all + kol-per-azs
      time-azs-all      = time-azs-all + time-azs
      kol-prev-azs-all  = kol-prev-azs-all + kol-prev-azs
      kol-prev-all      = kol-prev-all + kol-prev
      .
   assign
      kol-prev-azs  = 0
      kol-per-azs   = 0
      time-azs      = 0
      kol-prev      = 0
      time-prev-azs = 0 
      time-pr-sv    = 0 
      prm-1         = 0 
      prm-4         = 0
      .
END PROCEDURE.

PROCEDURE itog_azs-all:

   if time-prev-azs-all > 0 then time-pr-sv-all = time-prev-azs-all / kol-prev-azs-all.  /* средняя длительность простоя с превышением  */
   if kol-per-azs-all <> 0 then prm-1-all = time-azs-all / kol-per-azs-all .            /* средняя длительность пересменка  */
   if kol-prev-all > 0 then prm-4-all = kol-prev-azs-all / kol-prev-all * 100 .

   put stream OutStr-html unformatted 
      '<tr>' skip
      '<th style="text-align:center;" rowspan="2">' 'Итого по: ' '</th>' SKIP                      
      '<th bgcolor="#F8CBAD" style="text-align:center;" rowspan="2" > Все объекты </th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя длительность простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Количество случаев с превышением порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Общая длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Средняя  длительность превышения порога простоя' '</th>' skip
      '<th bgcolor="#C6E0B4" style="text-align:center;">' 'Процент случаев простоя с превышением порогового значения от общего  кол-ва простоев' '</th>' skip
      '</tr>' skip

      '<tr >' skip
      '<td style="text-align:center;">' format-etime(prm-1-all) '</td>' skip
      '<td style="text-align:center;">' kol-prev-azs-all '</td>' skip
      '<td style="text-align:center;">' format-etime(if time-prev-azs-all > 0 then time-prev-azs-all else 0) '</td>' skip  
      '<td style="text-align:center;">' format-etime(time-pr-sv-all) '</td>' skip
      '<td style="text-align:center;">' + string(prm-4-all) + "%" + '</td>' skip 
      '</tr>' skip
      . 

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


