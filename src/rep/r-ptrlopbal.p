block-level on error undo, throw.
/*

$Revision: 20e2b075d76d, 1062, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:34:13 2017 +0300 $
$Workfile: r-ptrlopbal.p $
$Archive: rep/r-ptrlopbal.p $

Контрольно-накопительная ведомость учета излишек и недостач НП

Автор: Гридчина Полина Дмитриевна
Дата создания: 20/12/2014
Author: Polina Gridchina
Creation date: 20/12/2014

*/

define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo. /*объект*/
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter p-tog-with-tot-day as logical            no-undo .

def var vss-revision    as character no-undo init "$Revision: 20e2b075d76d, 1062, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Fri Oct 06 18:34:13 2017 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-ptrlopbal.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-ptrlopbal.p $":U .
def var vss-description as character no-undo init "Контрольно-накопительная ведомость учета излишек и недостач НП".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-page1.i     }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ gbl/lastdate.i    }
{ gbl/cur-time.i    }
{ gbl/waitfram.i }



define buffer previous-rvs-doc    for ub.rvs-doc.
define buffer buf_rvs-doc         for ub.rvs-doc .
define buffer bef-rvs-line        for ub.rvs-line.
define buffer buf_rvs-line        for ub.rvs-line .
define buffer start-date-rvs-doc  for ub.rvs-doc.
define buffer end-date-rvs-doc    for ub.rvs-doc.
define buffer start-date-rvs-line for ub.rvs-line.
define buffer end-date-rvs-line   for ub.rvs-line.
define buffer bef-doc-rvs-doc     for ub.rvs-doc.
define buffer aft-doc-rvs-doc     for ub.rvs-doc.
define buffer bef-doc-rvs-line    for ub.rvs-line.
define buffer aft-doc-rvs-line    for ub.rvs-line.
define buffer buf_doc-pl          for ub.doc-pl .
define buffer buf_goods           for ub.goods .
define buffer buf_clients         for ub.clients .
define buffer previous-shift-obj  for ub.shift-obj.
define buffer buf_icnt-doc for ub.icnt-doc .
define buffer buf_icnt-line for ub.icnt-line .

define variable v-file-name-rep-htm as character no-undo.
define variable var-report-num as int no-undo.


define variable varhost-code  like ub.trn-doc.host-code     no-undo.
define variable v-host-name   as character               no-undo. /*название фирмы*/
define variable v-obj-name    as character               no-undo. /*АЗС*/
define variable v-header-name as character               no-undo.
define variable v-print-time  as character               no-undo.
define variable v-count       as   integer               no-undo .
define variable var-prev-shift-date like ub.shift-obj.shift-date no-undo.
define variable var-prev-shift-num like ub.shift-obj.shift-num   no-undo.
define variable var-shift-staff   like ub.shift-staff.name       no-undo.
define variable v-fill-path-RepView as character no-undo.

define stream OutStr-html.


DEFINE TEMP-TABLE tt-rep NO-UNDO
    FIELD shift-date            like ub.trn-doc.shift-date
    FIELD shift-num             like ub.trn-doc.shift-num
    FIELD time-start            like ub.shift-obj.open-time
    FIELD time-end              like ub.shift-obj.close-time
    FIELD date-end              like ub.shift-obj.close-date
    FIELD gds-code              like ub.goods.gds-code
    FIELD pl-code               LIKE ub.doc-pl.pl-code
    FIELD goods-name            LIKE ub.goods.gds-name
    FIELD rest_start_measure-kg LIKE ub.rvs-line.state-measure-qnty
    FIELD rest_start_book-kg    LIKE ub.rvs-line.system-qnty /* расчет. остаток на начло кг*/
    FIELD rest_start_measure-l  LIKE ub.rvs-line.state-measure-qnty
    FIELD rest_start_book-l     LIKE ub.rvs-line.system-qnty /* расчет. остаток на начло лт*/
    FIELD wayb_fact-kg          LIKE ub.trn-doc.cli-qnty /* приход кг*/
    FIELD wayb_fact-l           LIKE ub.trn-doc.fact-qnty /* приход лт*/
    FIELD exp-kg                LIKE ub.trn-doc.cli-qnty  /* расход кг*/
    FIELD exp-l                 LIKE ub.trn-doc.fact-qnty  /* расход лт*/
    FIELD rest_end_measure-kg   LIKE ub.rvs-line.state-measure-cli-qnty /* факт остаток на конец кг*/
    FIELD rest_end_book-kg      LIKE ub.rvs-line.system-qnty /* расчет. остаток на конец кг*/
    FIELD rest_end_measure-l    LIKE ub.rvs-line.state-measure-qnty /* факт остаток на конец лт*/
    FIELD rest_end_book-l       LIKE ub.rvs-line.system-qnty /* расчет. остаток на конец лт*/
    FIELD rest_end_balans-kg    LIKE ub.rvs-line.state-measure-cli-qnty  /* результат кг */
    FIELD rest_end_balans-l     LIKE ub.rvs-line.system-qnty /* результат лт */
    field state-el-cnt          like icnt-line.state-el-cnt
    field state-mh-cnt          like icnt-line.state-mh-cnt
    FIELD err-kg                LIKE ub.rvs-line.state-measure-qnty  /* погрешность кг*/
    FIELD err-l                 LIKE ub.rvs-line.system-qnty
    FIELD staff                 like ub.shift-staff.name
    FIELD place_loc1            like ub.place.loc1
    field density               like ub.rvs-line.density
    INDEX pi AS UNIQUE PRIMARY gds-code pl-code shift-date shift-num 
 .

define variable var-gds-rest_start_measure-kg  LIKE ub.rvs-line.state-measure-qnty  no-undo.
define variable var-gds-rest_start_book-kg     LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-rest_start_measure-l   LIKE ub.rvs-line.state-measure-qnty no-undo.
define variable var-gds-rest_start_book-l      LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-wayb_fact-kg           LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-gds-wayb_fact-l            LIKE ub.trn-doc.fact-qnty no-undo.
define variable var-gds-exp-kg                 LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-gds-exp-l                  LIKE ub.trn-doc.fact-qnty no-undo.
define variable var-gds-rest_end_measure-kg   LIKE ub.rvs-line.state-measure-cli-qnty no-undo.
define variable var-gds-rest_end_book-kg      LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-rest_end_measure-l    LIKE ub.rvs-line.state-measure-qnty no-undo.
define variable var-gds-rest_end_book-l       LIKE ub.rvs-line.system-qnty no-undo.
define variable var-gds-rest_end_balans-kg    LIKE ub.rvs-line.state-measure-cli-qnty no-undo.
define variable var-gds-rest_end_balans-l     LIKE ub.rvs-line.system-qnty no-undo.

define variable var-pl-rest_start_measure-kg  LIKE ub.rvs-line.state-measure-qnty  no-undo.
define variable var-pl-rest_start_book-kg     LIKE ub.rvs-line.system-qnty no-undo.
define variable var-pl-rest_start_measure-l   LIKE ub.rvs-line.state-measure-qnty no-undo.
define variable var-pl-rest_start_book-l      LIKE ub.rvs-line.system-qnty no-undo.
define variable var-pl-wayb_fact-kg           LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-pl-wayb_fact-l            LIKE ub.trn-doc.fact-qnty no-undo.
define variable var-pl-exp-kg                 LIKE ub.trn-doc.cli-qnty no-undo.
define variable var-pl-exp-l                  LIKE ub.trn-doc.fact-qnty no-undo.




if not can-find(first gds-list) then do:
  message
    "Не заданы товары для формирования опреративного баланса."
    view-as alert-box error.
  return.
end.



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
            if available previous-shift-obj then do:
                var-prev-shift-num = previous-shift-obj.shift-num.
                var-prev-shift-date = previous-shift-obj.shift-date.
            end.    

    for each ub.shift-obj  no-lock
    where ub.shift-obj.obj-code   =  parobj-code
      and ub.shift-obj.obj-type   =  parobj-type
      and ub.shift-obj.shift-date >= X-date-Start
      and ub.shift-obj.shift-date <= X-date-End
        :
        if ub.shift-obj.shift-date = X-date-Start and ub.shift-obj.shift-num < X-Shift-Start then next .
        if ub.shift-obj.shift-date = X-date-End   and ub.shift-obj.shift-num > X-Shift-End then next .
        var-shift-staff  = ''.
        for first ub.shift-staff where
         ub.shift-staff.shift-num = ub.shift-obj.shift-num 
         and ub.shift-staff.shift-date = ub.shift-obj.shift-date
         and ub.shift-staff.obj-type = ub.shift-obj.obj-type 
         and ub.shift-staff.obj-code = ub.shift-obj.obj-code
         and ub.shift-staff.staff-role = yes no-lock:
             var-shift-staff = ub.shift-staff.name.
        end.     
        
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.obj-type   = parobj-type
          and buf_rvs-doc.obj-code   = parobj-code
          and buf_rvs-doc.shift-date = ub.shift-obj.shift-date
          and buf_rvs-doc.shift-num  = ub.shift-obj.shift-num
          and buf_rvs-doc.status_    = {&fact}
          and buf_rvs-doc.rvs-type   = {&rvs-shift}
          no-error.
        if not available buf_rvs-doc then next.  
          for each buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code no-lock, first gds-list where gds-list.gds-code = buf_rvs-line.gds-code no-lock,
          first ub.goods no-lock where ub.goods.gds-code = buf_rvs-line.gds-code  :
              create tt-rep.
              assign
              tt-rep.shift-date   = ub.shift-obj.shift-date
              tt-rep.shift-num    = ub.shift-obj.shift-num
              tt-rep.gds-code    = buf_rvs-line.gds-code
              tt-rep.goods-name    = goods.gds-name
              tt-rep.pl-code     = buf_rvs-line.pl-code
              tt-rep.place_loc1  = string(buf_rvs-line.pl-code)
              tt-rep.rest_end_measure-kg  =  buf_rvs-line.state-measure-cli-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
              tt-rep.rest_end_book-kg    = buf_rvs-line.system-cli-qnty
              tt-rep.rest_end_measure-l  =  buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty
              tt-rep.rest_end_book-l     = buf_rvs-line.system-qnty
              tt-rep.rest_end_balans-kg  = tt-rep.rest_end_measure-kg - tt-rep.rest_end_book-kg 
              tt-rep.rest_end_balans-l   = tt-rep.rest_end_measure-l - tt-rep.rest_end_book-l
              tt-rep.staff               = var-shift-staff
              tt-rep.time-start          = ub.shift-obj.open-time
              tt-rep.time-end            = ub.shift-obj.close-time
              tt-rep.date-end            = ub.shift-obj.close-date
              .    

   
              for first ub.place no-lock
                where ub.place.obj-code = parobj-code
                  and ub.place.obj-type = parobj-type
                  and ub.place.pl-code  = tt-rep.pl-code
                 :
                 if ub.place.loc1 > ''  then assign
                 tt-rep.place_loc1 = ub.place.loc1
                .
              end. /*if available ub.place*/                        
          end. /* for each buf-rvs-line */
              
          for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = {&fact}
                and ub.trn-doc.doc-type   = {&income}
            on error undo, return error return-value
            :                   
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,                              
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
        
                assign
                  tt-rep.wayb_fact-l = tt-rep.wayb_fact-l + ub.doc-pl.fact-qnty
                  tt-rep.wayb_fact-kg = tt-rep.wayb_fact-kg + ub.doc-pl.cli-fact-qnty
                  tt-rep.density = tt-rep.wayb_fact-kg / tt-rep.wayb_fact-l 
                .
              end. /* for each doc-line where  */
            end. /* for each ub.trn-doc where  */
                        
                        
            for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = {&fact}
                and ub.trn-doc.doc-type   = {&expense}
            on error undo, return error return-value
            :                   
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,                              
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
        
                assign
                  tt-rep.exp-l = tt-rep.exp-l + ub.doc-pl.fact-qnty
                  tt-rep.exp-kg = tt-rep.exp-kg + ub.doc-pl.cli-fact-qnty
                .
           
              end. /* for each doc-line where  */
              
            end. /* for each ub.trn-doc where  */   
                        for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = {&fact}
                and ub.trn-doc.doc-type   = {&return}
            on error undo, return error return-value
            :                   
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,                              
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
        
                assign
                  tt-rep.exp-l = tt-rep.exp-l - ub.doc-pl.fact-qnty
                  tt-rep.exp-kg = tt-rep.exp-kg - ub.doc-pl.cli-fact-qnty
                .
           
              end. /* for each doc-line where  */
              
            end. /* for each ub.trn-doc where  */   
            
                        for each ub.trn-doc no-lock
              where ub.trn-doc.obj-type   = ub.shift-obj.obj-type
                and ub.trn-doc.obj-code   = ub.shift-obj.obj-code
                and ub.trn-doc.shift-date = ub.shift-obj.shift-date
                and ub.trn-doc.shift-num  = ub.shift-obj.shift-num
                and ub.trn-doc.status_    = {&fact}
                and ub.trn-doc.doc-type   = {&write-off}
            on error undo, return error return-value
            :                   
              for each ub.doc-pl no-lock
                where ub.doc-pl.out-code = ub.trn-doc.doc-code,                              
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                  and tt-rep.shift-num    = ub.shift-obj.shift-num
                  and tt-rep.gds-code    = ub.doc-pl.gds-code
                  and tt-rep.pl-code     = ub.doc-pl.pl-code
              on error undo, return error return-value
              :
        
                assign
                  tt-rep.exp-l = tt-rep.exp-l + ub.doc-pl.fact-qnty
                  tt-rep.exp-kg = tt-rep.exp-kg + ub.doc-pl.cli-fact-qnty
                .
             
              end. /* for each doc-line where  */
            end. /* for each ub.trn-doc where  */ 
                        
                                   
            for first previous-rvs-doc no-lock
                  where previous-rvs-doc.obj-type = parobj-type
                  and previous-rvs-doc.obj-code   = parobj-code
                  and previous-rvs-doc.shift-date = var-prev-shift-date
                  and previous-rvs-doc.shift-num  = var-prev-shift-num
                  and previous-rvs-doc.status_    = {&fact}
                  and previous-rvs-doc.rvs-type   = {&rvs-shift},
                  each buf_rvs-line where buf_rvs-line.rvs-code = previous-rvs-doc.rvs-code no-lock,
                  first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                              and tt-rep.shift-num    = ub.shift-obj.shift-num
                              and tt-rep.gds-code    = buf_rvs-line.gds-code
                              and tt-rep.pl-code     = buf_rvs-line.pl-code
                  
                  : 
                  assign
                     tt-rep.rest_start_book-kg       = buf_rvs-line.system-cli-qnty
                     tt-rep.rest_start_book-l       = buf_rvs-line.system-qnty
                     .                  
             end.     
    
             for each buf_icnt-doc no-lock
              where buf_icnt-doc.obj-type     = parobj-type
                and buf_icnt-doc.obj-code     = parobj-code
                and buf_icnt-doc.doc-type     = {&icnt-err}
                and buf_icnt-doc.ext-doc-type = {&TDEICNT_Err-meas}
                and buf_icnt-doc.status_      = {&fact}                
                and buf_icnt-doc.shift-num = ub.shift-obj.shift-num
                and buf_icnt-doc.shift-date = ub.shift-obj.shift-date
            on error undo, return error return-value
            :
              for each buf_icnt-line no-lock
                where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
                  and buf_icnt-line.obj-code = buf_icnt-doc.obj-code
                  and buf_icnt-line.obj-type = buf_icnt-doc.obj-type:
                  find first ub.pl-gds-pump where ub.pl-gds-pump.obj-code = buf_icnt-line.obj-code
                                            and ub.pl-gds-pump.obj-type = buf_icnt-line.obj-type
                                            and ub.pl-gds-pump.pump-code = buf_icnt-line.pump-code
                                            and ub.pl-gds-pump.status_ <> {&blocked-status}
                                            and ub.pl-gds-pump.gds-code = buf_icnt-line.gds-code no-error .
                    if not AVAILABLE ub.pl-gds-pump then do:
                       find first ub.pl-gds-pump where ub.pl-gds-pump.obj-code = buf_icnt-line.obj-code
                                            and ub.pl-gds-pump.obj-type = buf_icnt-line.obj-type
                                            and ub.pl-gds-pump.pump-code = buf_icnt-line.pump-code
                                            and ub.pl-gds-pump.gds-code = buf_icnt-line.gds-code no-error .
                    end.                                                   
/*                  first ub.pl-pump-nozzle where ub.pl-pump-nozzle.nozzle-code = buf_icnt-line.nozzle-code */
/*                                            and ub.pl-pump-nozzle.obj-code = ub.pl-gds-pump.obj-code      */
/*                                            and ub.pl-pump-nozzle.obj-type = ub.pl-gds-pump.obj-type      */
/*                                            and ub.pl-pump-nozzle.pump-code = ub.pl-pump-nozzle.pump-code,*/

               find first tt-rep where tt-rep.shift-date   = ub.shift-obj.shift-date
                              and tt-rep.shift-num    = ub.shift-obj.shift-num
                              and tt-rep.gds-code    = buf_icnt-line.gds-code
                              and tt-rep.pl-code     = ub.pl-gds-pump.pl-code
              no-error .
                if AVAILABLE tt-rep then do:
                 assign
                     tt-rep.state-el-cnt       = buf_icnt-line.state-el-cnt
                     tt-rep.state-mh-cnt       = buf_icnt-line.state-mh-cnt
                     tt-rep.err-l = tt-rep.err-l + (tt-rep.state-el-cnt - tt-rep.state-mh-cnt)
                     tt-rep.err-kg = tt-rep.err-l * tt-rep.density
                     .
                 end.                      
              end.
            end.

            var-prev-shift-num = ub.shift-obj.shift-num.
            var-prev-shift-date = ub.shift-obj.shift-date.
    end. /* for each shift-obj */ 
    
    run get-report-num in parParentProc (
    output var-report-num
        ).

        v-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(var-report-num) + ".html".
        /* Создаём временные файлы. */
/*            output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ).*/
/*            output close.                                                                               */
/*            output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".html" /*".txl"*/ ).*/
/*            output close.                                                                                                  */
/*            output to value(string(session:temp-directory + v-file-name-rep-htm)).*/
            output to value(v-file-name-rep-htm).
            output close.
        /* ******************** */

        if search("exe\ReportViewer\reportviewer.exe") <> ? then
            do:
                v-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
            end.
        else
            do:
                message "Не найдена программа просмотра отчёта!" view-as alert-box error.
            end.
    
      /*Шапка*/
 def var v-first-time as int no-undo.
 def var v-first-date as date no-undo.
 def var v-last-date as date no-undo.
 def var v-last-time as int no-undo.   
   
      for first tt-rep by tt-rep.shift-date by tt-rep.shift-num :
          v-first-date = tt-rep.shift-date.
          v-first-time = tt-rep.time-start.
      end.     
     for last tt-rep by tt-rep.shift-date by tt-rep.shift-num :
          v-last-date = tt-rep.date-end.
          v-last-time = tt-rep.time-end.
      end.  
      output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' /*no-convert*/.
      put stream OutStr-html unformatted
        substitute ('
        <!DOCTYPE HTML>
              <html>
                <head>
                <meta charset="UTF-8">
                    <!-- Стили документа -->
                <style>
                     table ~{
                         border-collapse: collapse; 
                     ~}
                     tbody td, th ~{
                         border: 1px solid black;
                         border-collapse: collapse;
                   height: 14px;
                     ~}
            
                </style>
                </head>
                  <body>
                    <table orientation="landscape" name="Контр.накопит. ведомость" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                      <thead>  <!-- Шапка отчета -->
                      <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                        <tr class="set_columns">
                          <td style="width:50px"></td>
                          <td style="width:85px"></td>
                          <td style="width:85px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:50px"></td>
                          <td style="width:60px"></td>
                          <td style="width:136px"></td>
                        </tr>
                      <tr>
                        <td colspan="20"></td>
                      </tr>
                      <tr style="height:30px;">  
                        <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                        <td colspan="15"></td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                        <td colspan="15"></td>
                      </tr>
                      <tr>
                        <td colspan="20" style="font-size:16px;font-weight:bold; text-align: center;">Контрольно-накопительная ведомость учета излишек и недостач нефтепродуктов по  &2</td>
                      </tr>
                      <tr>
                        <td colspan="20" style="text-align:center;"> за период с &3 по &4</td>
                      </tr>
                      <tr>
                        <td colspan="20"></td>
                      </tr>          
                    </thead>
            
                
              <tbody> <!-- Здесь начинается таблица отчета -->
                    <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->
                    <th rowspan="3" style="text-align: center;">Номер сменного отчета</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Дата, время (дд.мм.гг чч:мм)</th>
                    <th rowspan="3" style="text-align: center;">Номер резервуара</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Расчетный остаток на начало смены</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Поступило за смену</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Расход за смену</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Фактический остаток на конец смены</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Расчетный остаток на конец смены</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Результат ("+" - излишки, "-" - недостача)</th>
                    <th rowspan="2" colspan="2" style="text-align: center;">Погрешность ТРК по резервуару за смену</th>
                    <th rowspan="3" style="text-align: center;">Подпись</th>
                    <th rowspan="3" style="text-align: center;">Инициалы, Фамилия</th>
                </tr>
                <tr>
                </tr>
                <tr>
                    <th style="text-align: center;">начала смены</th>
                    <th style="text-align: center;">окончания смены</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                    <th style="text-align: center;">л</th>
                    <th style="text-align: center;">кг</th>
                </tr>
                <tr>
                    <th style="text-align: center;">1</th>
                    <th style="text-align: center;">2</th>
                    <th style="text-align: center;">3</th>
                    <th style="text-align: center;">4</th>
                    <th style="text-align: center;">5</th>
                    <th style="text-align: center;">6</th>
                    <th style="text-align: center;">7</th>
                    <th style="text-align: center;">8</th>
                    <th style="text-align: center;">9</th>
                    <th style="text-align: center;">10</th>
                    <th style="text-align: center;">11</th>
                    <th style="text-align: center;">12</th>
                    <th style="text-align: center;">13</th>
                    <th style="text-align: center;">14</th>
                    <th style="text-align: center;">15</th>
                    <th style="text-align: center;">16</th>
                    <th style="text-align: center;">17</th>
                    <th style="text-align: center;">18</th>
                    <th style="text-align: center;">19</th>
                    <th style="text-align: center;">20</th>
                </tr>'
                ,
                string(v-host-name),
                string(v-obj-name),
                string(v-first-date, "99.99.9999") + ' ' + string(v-first-time,"HH:MM") ,
                string(v-last-date, "99.99.9999") + ' ' + string(v-last-time,"HH:MM")
        ).
        
            
        for each tt-rep break by tt-rep.gds-code by tt-rep.pl-code on error undo, return error return-value:
            if first-of(tt-rep.gds-code) then do:
              
                
                /* Обнуляем счетчики для товара */
                ASSIGN 
                var-gds-rest_start_measure-kg  = 0
                var-gds-rest_start_book-kg     = 0 
                var-gds-rest_start_measure-l   = 0 
                var-gds-rest_start_book-l      = 0 
                var-gds-wayb_fact-kg           = 0 
                var-gds-wayb_fact-l            = 0 
                var-gds-exp-kg                 = 0 
                var-gds-exp-l                  = 0 
                var-gds-rest_end_measure-kg   = 0 
                var-gds-rest_end_book-kg      = 0 
                var-gds-rest_end_measure-l    = 0
                var-gds-rest_end_book-l       = 0
                var-gds-rest_end_balans-kg    = 0 
                var-gds-rest_end_balans-l     = 0 
                .
           
            
              /* Печатаем первую строку по товару */
              
              put stream OutStr-html unformatted
                substitute ('
                        <tr> <!-- Затем идёт наполнение таблицы -->
                            <th colspan="3" style="text-align:right;">Вид, марка нефтепродукта:</th>
                            <th colspan="17" style="text-align:left;">&1</th>
                        </tr>'
                ,
                tt-rep.goods-name
                ).
              
              
       end.   /* first-of(tt-rep.gds-code)  */ 

            
            if first-of(tt-rep.pl-code) then do:
                /* Печатаем первую строку по резевуару*/
                
                /* Обнуляем счетчики для резервуара */
                ASSIGN 
                var-pl-rest_start_book-kg  = tt-rep.rest_start_book-kg            
                var-pl-rest_start_book-l      = tt-rep.rest_start_book-l
                var-pl-wayb_fact-kg           = 0 
                var-pl-wayb_fact-l            = 0 
                var-pl-exp-kg                 = 0 
                var-pl-exp-l                  = 0 
                .
                
                put stream OutStr-html unformatted
                substitute ('
                        <tr>
                            <th colspan="3" style="text-align:right;">Резервуар:</th>
                            <th colspan="17" style="text-align:left;">&1</th>
                        </tr>'
                ,
                tt-rep.place_loc1
                ).    
                        
 
                
            end.    /* first-of(tt-rep.pl-code) */
            
            assign 
            var-pl-wayb_fact-kg = var-pl-wayb_fact-kg + tt-rep.wayb_fact-kg
            var-pl-wayb_fact-l = var-pl-wayb_fact-l + tt-rep.wayb_fact-l
            var-pl-exp-kg = var-pl-exp-kg + tt-rep.exp-kg
            var-pl-exp-l = var-pl-exp-l + tt-rep.exp-l
            .
                put stream OutStr-html unformatted
                substitute ('
                        <tr> 
                        <td style="text-align:center;"></td>
                        <td style="text-align:center;">&1</td>
                        <td style="text-align:center;">&2</td>
                        <td style="text-align:center;">&3</td>
                        <td style="text-align:right;">&4</td>
                        <td style="text-align:right;">&5</td>
                        <td style="text-align:right;">&6</td>
                        <td style="text-align:right;">&7</td>'
                ,
                string(tt-rep.shift-date, "99.99.9999") + ' ' + string (tt-rep.time-start,"hh:mm"),
                string(tt-rep.date-end, "99.99.9999") + ' ' + string (tt-rep.time-end,"hh:mm"),
                tt-rep.place_loc1,
                string(tt-rep.rest_start_book-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.rest_start_book-kg,"->>>>>>>>>>>9.99"),
                string(tt-rep.wayb_fact-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.wayb_fact-kg,"->>>>>>>>>>>9.99")
                ).    
                        
                put stream OutStr-html unformatted
                substitute ('
                        <td style="text-align:right;">&1</td>
                        <td style="text-align:right;">&2</td>
                        <td style="text-align:right;">&3</td>
                        <td style="text-align:right;">&4</td>
                        <td style="text-align:right;">&5</td>
                        <td style="text-align:right;">&6</td>
                        <td style="text-align:right;">&7</td>
                        <td style="text-align:right;">&8</td>
                        <td style="text-align:right;">&9</td>
                '
                ,
                string(tt-rep.exp-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.exp-kg,"->>>>>>>>>>>9.99"),
                if tt-rep.rest_end_measure-l <> ? then string(tt-rep.rest_end_measure-l,"->>>>>>>>>>>9.99") else '', 
                if tt-rep.rest_end_measure-kg <> ? then string(tt-rep.rest_end_measure-kg,"->>>>>>>>>>>9.99") else '', 
                string(tt-rep.rest_end_book-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.rest_end_book-kg,"->>>>>>>>>>>9.99"),
                if tt-rep.rest_end_balans-l <> ? then string(tt-rep.rest_end_balans-l,"->>>>>>>>>>>9.99") else '',
                if tt-rep.rest_end_balans-kg <> ? then string(tt-rep.rest_end_balans-kg,"->>>>>>>>>>>9.99") else '',
                string(tt-rep.err-l,"->>>>>>>>>>>9.99")
                ).
                    
        
        
                    
               put stream OutStr-html unformatted
                substitute ('
                        <td style="text-align:right;">&1</td>
                        <td style="text-align:center;"></td>
                        <td style="text-align:left;">&2</td>
                        </tr>
                        '
                ,
                string(tt-rep.err-kg,"->>>>>>>>>>>9.99"),
                tt-rep.staff
                ).                       
            if last-of(tt-rep.pl-code) then do:
                /* Печатаем последнюю строку по резевуару. Для остатков на конец берем данные по последней смене. Остаток на начло и обороты из переменных*/
                
                /* И накручиваем счетчики по товару */
               ASSIGN 
                
                var-gds-rest_start_book-kg     = var-gds-rest_start_book-kg + var-pl-rest_start_book-kg                  
                var-gds-rest_start_book-l      = var-gds-rest_start_book-l + var-pl-rest_start_book-l
                var-gds-wayb_fact-kg           = var-gds-wayb_fact-kg + var-pl-wayb_fact-kg 
                var-gds-wayb_fact-l           = var-gds-wayb_fact-l + var-pl-wayb_fact-l 
                var-gds-exp-kg           = var-gds-exp-kg + var-pl-exp-kg 
                var-gds-exp-l           = var-gds-exp-l + var-pl-exp-l
                var-gds-rest_end_measure-kg   = var-gds-rest_end_measure-kg + tt-rep.rest_end_measure-kg
                var-gds-rest_end_book-kg      =  var-gds-rest_end_book-kg + tt-rep.rest_end_book-kg
                var-gds-rest_end_measure-l    =  var-gds-rest_end_measure-l + tt-rep.rest_end_measure-l
                var-gds-rest_end_book-l       = var-gds-rest_end_book-l + tt-rep.rest_end_book-l
                var-gds-rest_end_balans-kg    = var-gds-rest_end_balans-kg + tt-rep.rest_end_balans-kg 
                var-gds-rest_end_balans-l     = var-gds-rest_end_balans-l + tt-rep.rest_end_balans-l 
                .


      put stream OutStr-html unformatted
        substitute ('
                <tr> 
                <th colspan="3" style="text-align:center">Итого по резервуару номер:</th>
                <th style="text-align:center;">&1</th>
                <th style="text-align:right;">&2</th>
                <th style="text-align:right;">&3</th>
                <th style="text-align:right;">&4</th>
                <th style="text-align:right;">&5</th>
                <th style="text-align:right;">&6</th>
                <th style="text-align:right;">&7</th>
               '
        ,
        /*итого по резервуару*/
        tt-rep.place_loc1,
        string(var-pl-rest_start_book-l,"->>>>>>>>>>>9.99"),
        string(var-pl-rest_start_book-kg,"->>>>>>>>>>>9.99"),
        string(var-pl-wayb_fact-l,"->>>>>>>>>>>9.99"),
        string(var-pl-wayb_fact-kg,"->>>>>>>>>>>9.99"),
        string(var-pl-exp-l,"->>>>>>>>>>>9.99"),
        string(var-pl-exp-kg,"->>>>>>>>>>>9.99")
        ).
          
                put stream OutStr-html unformatted
                substitute ('
                        <th style="text-align:right;">&1</th>
                        <th style="text-align:right;">&2</th>
                        <th style="text-align:right;">&3</th>
                        <th style="text-align:right;">&4</th>
                        <th style="text-align:right;">&5</th>
                        <th style="text-align:right;">&6</th>
                        <th style="text-align:right;">&7</th>
                        <th style="text-align:right;">&8</th>
                        <th colspan="2" style="text-align:center;"></th>
                        </tr>
                        '
                ,
                if tt-rep.rest_end_measure-l <> ? then string(tt-rep.rest_end_measure-l,"->>>>>>>>>>>9.99") else '', 
                if tt-rep.rest_end_measure-kg <> ? then string(tt-rep.rest_end_measure-kg,"->>>>>>>>>>>9.99") else '', 
                string(tt-rep.rest_end_book-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.rest_end_book-kg,"->>>>>>>>>>>9.99"),
                if tt-rep.rest_end_balans-l <> ? then string(tt-rep.rest_end_balans-l,"->>>>>>>>>>>9.99") else '',
                if tt-rep.rest_end_balans-kg <> ? then string(tt-rep.rest_end_balans-kg,"->>>>>>>>>>>9.99") else '',
                string(tt-rep.err-l,"->>>>>>>>>>>9.99"),
                string(tt-rep.err-kg,"->>>>>>>>>>>9.99")
                ).
                
      


       
       
            end.  /* last-of(tt-rep.pl-code) */
            if LAST-of(tt-rep.gds-code) then do:
                /* Печатаем ИТОГИ по товару */
                
               /*
                ASSIGN 
                var-gds-rest_start_measure-kg  = 0
                var-gds-rest_start_book-kg     = 0 
                var-gds-rest_start_measure-l   = 0 
                var-gds-rest_start_book-l      = 0 
                var-gds-wayb_fact-kg           = 0 
                var-gds-wayb_fact-l            = 0 
                var-gds-exp-kg                 = 0 
                var-gds-exp-l                  = 0 
                var-gds-rest_end_measure-kg   = 0 
                var-gds-rest_end_book-kg      = 0 
                var-gds-rest_end_measure-l    = 0
                var-gds-rest_end_book-l       = 0
                var-gds-rest_end_balans-kg    = 0 
                var-gds-rest_end_balans-l     = 0 
                .
                */


      put stream OutStr-html unformatted
        substitute ('
                <tr> 
                <th colspan="3" style="text-align:center;">Итого по виду, марке нефтепродукта:</th>
                <th style="text-align:center;">&1</th>
                <th style="text-align:right;">&2</th>
                <th style="text-align:right;">&3</th>
                <th style="text-align:right;">&4</th>
                <th style="text-align:right;">&5</th>
                <th style="text-align:right;">&6</th>
                <th style="text-align:right;">&7</th>
                <th style="text-align:right;">&8</th>
                <th style="text-align:right;">&9</th>
                '
        ,
        /*итого по виду, марке нефтепродукта*/
        '',
        string(var-gds-rest_start_book-l,"->>>>>>>>>>>9.99"),
        string(var-gds-rest_start_book-kg,"->>>>>>>>>>>9.99"),
        string(var-gds-wayb_fact-l,"->>>>>>>>>>>9.99"),
        string(var-gds-wayb_fact-kg,"->>>>>>>>>>>9.99"),
        string(var-gds-exp-l,"->>>>>>>>>>>9.99"),
        string(var-gds-exp-kg,"->>>>>>>>>>>9.99"),
        if var-gds-rest_end_measure-l <> ? then string(var-gds-rest_end_measure-l,"->>>>>>>>>>>9.99") else '',
        if var-gds-rest_end_measure-kg <> ? then string(var-gds-rest_end_measure-kg,"->>>>>>>>>>>9.99") else ''
        ).
       
      
      

      put stream OutStr-html unformatted
        substitute ('
                <th style="text-align:right;">&1</th>
                <th style="text-align:right;">&2</th>
                <th style="text-align:right;">&3</th>
                <th style="text-align:right;">&4</th>
                <th style="text-align:right;">&5</th>
                <th style="text-align:right;">&6</th>
                <th colspan="2" style="text-align:center;"></th>
                </tr>
          '
        ,
        string(var-gds-rest_end_book-l,"->>>>>>>>>>>9.99"),
        string(var-gds-rest_end_book-kg,"->>>>>>>>>>>9.99"),
        if var-gds-rest_end_balans-l <> ? then string(var-gds-rest_end_balans-l,"->>>>>>>>>>>9.99") else '',
        if var-gds-rest_end_balans-kg <> ? then string(var-gds-rest_end_balans-kg,"->>>>>>>>>>>9.99") else '',
        string(tt-rep.err-l,"->>>>>>>>>>>9.99"),           
        string(tt-rep.err-kg,"->>>>>>>>>>>9.99")
        ).
    
            
                
            end.  /* LAST-of(tt-rep.gds-code)  */

        end.
   put stream OutStr-html unformatted
        substitute ('
            
             
            </table>
            </body>
            </html>
            '
            ).
      
  output stream OutStr-html close.   
      
 

    
  run prn-lib-reportviewer-report-name in this-procedure (
                                                          input parParentProc
                                                          ,input v-file-name-rep-htm
                                                          ).
