/* block-level on error undo, throw. */
&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История пользователя 

Автор: Шкляр Елена
Дата создания: 04/04/08
Author: Shklyar Elena
Creation date: 04/04/08

Input:

Output:

*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo .
define input parameter Date-Start  as date           no-undo .
define input parameter Date-End    as date           no-undo .
/* define input parameter p-user-id        as character        no-undo . */
/* define input parameter p-obj-list       as character        no-undo . */
{rep/tt-user.i} 
define input parameter table for tt-user-account BIND. 
define input parameter table for tt-objects BIND.  



/*input  table  tt-user-account BY-REFERENCE.*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "История пользователя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/library.i  }
{ gbl/key-rec.i  }
{ cmp/showinf.i  }
{ cmp/tblfname.i }
{ gbl/prn-lib.i }
{ rep/html-conv.i }


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-unique-key Dialog-Frame 
FUNCTION get-unique-key RETURNS CHARACTER
  ( p-head-table as character,
  p-unique-key-rec as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

define BUFFER bf_c-user-log for ub.c-user-log .
define variable v-user-table-name as character no-undo .
define variable v-user-table      as character no-undo .
define variable v-table           as character no-undo .

define temp-table tt-usr-hist like ub.c-user-log 
  field time_     as character
  field name-bd   as character
  field user-name as character
  field table_    as character
  field info_     as character
  INDEX p1 corr-user-db-num corr-user-name table_.

define variable v-usrlg-ush-key as integer no-undo.
define variable v-usrlg-usl-key as integer no-undo.
define stream out-stream.
define stream OutStr-html.

define variable p-report-id             as integer   no-undo .
define variable v-report-name-html      as CHARACTER no-undo .
define variable v-report-name-html-list as CHARACTER no-undo .

run get-report-num in parParentProc (
  output p-report-id
  ).

v-report-name-html-list = session:temp-directory + {&DF_Name} + string(p-report-id) + "_hist" + ".html". /*формирование имя файла для часть1*/        


/*do on error undo, leave : */

for each bf_c-user-log no-lock where bf_c-user-log.corr-date >= Date-Start
  and bf_c-user-log.corr-date <= Date-End by bf_c-user-log.head-table  :

  v-table = bf_c-user-log.head-table .

  if v-table begins "c-" and v-table <> {&table_c-usr-hist} and v-table <> {&table_c-plc-hist} then 
  do:
    v-user-table = replace(v-table,"c-","").
  end.
  else v-user-table = v-table .    
  { gbl/tblnmusr.i
                    v-user-table
                    v-user-table-name
                  }
/*   message '*' bf_c-user-log.corr-user-db-num view-as alert-box. */
  create tt-usr-hist .
  assign
    tt-usr-hist.corr-date        = bf_c-user-log.corr-date
    tt-usr-hist.corr-time        = bf_c-user-log.corr-time
    tt-usr-hist.time_            = string(truncate (bf_c-user-log.corr-time / 3600, 0)) + ":" + string((bf_c-user-log.corr-time modulo 3600) / 60,"99")  + ":" + string((bf_c-user-log.corr-time modulo 3600) / 360,"99") 
    tt-usr-hist.corr-user-db-num = bf_c-user-log.corr-user-db-num
    tt-usr-hist.corr-user-name   = bf_c-user-log.corr-user-name   
    tt-usr-hist.head-table       = v-user-table-name               
    tt-usr-hist.des              = bf_c-user-log.des                
    tt-usr-hist.table_           = v-user-table                     
    tt-usr-hist.uniq-key-rec     = get-unique-key(bf_c-user-log.head-table,bf_c-user-log.uniq-key-rec)
    tt-usr-hist.name-bd = if bf_c-user-log.corr-user-db-num = 0 then "ГБД" 
                           else if bf_c-user-log.corr-user-db-num = ? then "Неизвестная БД"
                           else "АЗК " + string (bf_c-user-log.corr-user-db-num).
  
  for first ub.user-account no-lock where ub.user-account.user-id = bf_c-user-log.corr-user-name :
    tt-usr-hist.user-name = ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name .
  end .    

  
  
  if bf_c-user-log.head-table = 'schedule':U
  then do :

    assign
      tt-usr-hist.des           = "Изменение расписания автоматического задания"
      tt-usr-hist.head-table    = entry(5, bf_c-user-log.head-table-key, {&delim-cmd}) 
      tt-usr-hist.uniq-key-rec  = entry(4, bf_c-user-log.des, ";")
    .


    if entry(5, bf_c-user-log.head-table-key, {&delim-cmd}) = {&btpr-type-autofree}
    then 
      tt-usr-hist.head-table = tt-usr-hist.head-table + " - " + entry(6, bf_c-user-log.head-table-key, {&delim-cmd})
    .

    if entry(15, bf_c-user-log.head-table-key, {&delim-cmd}) = "del"
    then
      tt-usr-hist.des = "Удаление расписания автоматического задания"
    .
end.  

end. /* do on error undo, leave : */



/* if p-obj-list <> "-1" and p-obj-list <> "" then 
do:
  for each tt-usr-hist:
    if lookup (tt-usr-hist.table_, p-obj-list, ",") = 0 then 
    do:
      delete tt-usr-hist .
    end.  
  end.
end.    
 if p-user-id <> "" and p-user-id <> "-1" then 
do:
  for each tt-usr-hist:
    if lookup (tt-usr-hist.corr-user-name, p-user-id, ",") = 0 then 
    do:
      delete tt-usr-hist .
    end.  
  end.  

end.    */

do:

  for each tt-usr-hist:
    find first tt-user-account where tt-user-account.user-id_ = tt-usr-hist.corr-user-name no-error.
        if not AVAILABLE tt-user-account then 
         do:
            delete tt-usr-hist .
         end.  
  end.

end.    

do:
  for each tt-usr-hist:

  find first tt-objects where tt-objects.table_ = tt-usr-hist.table_ no-error.
        if not AVAILABLE tt-objects  then 
        do:
          delete tt-usr-hist .
        end.  
  end.

end.     


/*   if not can-find(first tt-usr-hist) 
      then do:
/*        return-value = "Нет данных для отчета". */
        return error return-value .
    end. */
            
run PROC-print-list in this-procedure.


PROCEDURE proc-print-list :

  define buffer buf_c-user-log for ub.c-user-log .
  do
    on error undo, return error
    :
            
    /*вызов процедуры печати шапки отчета*/      
    output stream OutStr-html to value(v-report-name-html-list) convert target 'UTF-8'.
    put stream OutStr-html unformatted
      "<!DOCTYPE HTML>" skip
      ' <html>' skip
      '  <head>' skip
      '   <meta charset="utf-8">' skip
      '    <style type="text/css">' skip
                        
      '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
      '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
      '      tbody td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
      '   </style>' skip
      '  </head>' skip
      .

    put stream OutStr-html unformatted
      '<body>' skip
      '<TABLE name="1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
      .
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td style="width: 80px;"></td>' skip
      '<td style="width: 70px;"></td>' skip
      '<td style="width: 40px;"></td>' skip
      '<td style="width: 50px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 50px;"></td>' skip
      '<td style="width: 200px;"></td>' skip
      '<td style="width: 100px;"></td>' skip
      '<td style="width: 200px;"></td>' skip
      '</tr>' skip
      .
                        
 
    put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="9" style="text-align: center;">История действий пользователя за период с ' + string(date-start,"99.99.99") + ' по ' + string(date-end,"99.99.99") + ' </td>' skip
      '</tr>' skip   
      '</thead>' skip .

    put stream OutStr-html unformatted
      '<tbody>' skip
      '<TR>' skip
      '<TD text_wrap="true" style="text-align: center;">Дата события</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Время события</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">БД</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Наз. БД</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Пользователь</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">ID польз.</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Описание</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Объект</TD>' skip
      '<TD text_wrap="true" style="text-align: center;">Информация</TD>' skip
      '</TR>'skip       
      .
    
    FOR EACH tt-usr-hist NO-LOCK 
      by tt-usr-hist.corr-user-db-num 
      by tt-usr-hist.corr-date
      by tt-usr-hist.corr-time:
                    
      put stream OutStr-html unformatted
        '<TR>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-usr-hist.corr-date,"99.99.9999") + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + tt-usr-hist.time_ + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + string(tt-usr-hist.corr-user-db-num) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + tt-usr-hist.name-bd + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + tt-usr-hist.user-name + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + STRING(tt-usr-hist.corr-user-name) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + STRING(tt-usr-hist.des) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + STRING(tt-usr-hist.head-table) + '</TD>' skip
        '<TD text_wrap="true" style="text-align: center;">' + if tt-usr-hist.uniq-key-rec <> ? then  STRING(tt-usr-hist.uniq-key-rec) + '</TD>' else " " + '</TD>' skip
        '</TR>'skip                       
        .  
    end.    


    output stream OutStr-html close.   



    /*вызов программы печати*/ 
    run prn-lib-reportviewer-report-name in this-procedure (
      input parParentProc
      ,input v-report-name-html-list
      ).

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-unique-key Dialog-Frame 
FUNCTION get-unique-key RETURNS CHARACTER
  ( p-head-table as character,
  p-unique-key-rec as character ) :
  /*------------------------------------------------------------------------------
    Purpose:
      Notes:
  ------------------------------------------------------------------------------*/
  DEFINE variable v-unique-key-string AS CHARACTER NO-UNDO.
  if p-unique-key-rec begins 'report':U 
    or p-unique-key-rec begins 'utl':U  
    or p-head-table begins 'run-proc':U  
    or p-head-table begins 'run_proc':U
    or p-unique-key-rec begins 'prtdoc:':U
    then return p-unique-key-rec.
  run get-unique-key-proc in this-procedure (
    input p-unique-key-rec
    , output v-unique-key-string
    ).
  RETURN v-unique-key-string.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-unique-key-proc Dialog-Frame
PROCEDURE get-unique-key-proc :
  /*------------------------------------------------------------------------------
        Purpose:
        Parameters:  <none>
        Notes:
      ------------------------------------------------------------------------------*/
  DEFINE INPUT  PARAMETER p-unique-key-rec    AS CHARACTER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-unique-key-string AS CHARACTER   NO-UNDO.

  define variable v-field-list       as character no-undo.
  define variable v-field-value-list as character no-undo.
  do
    on error undo, return error
    :
    run gen-key-fv in this-procedure (
      input p-unique-key-rec
      , output v-field-list
      , output v-field-value-list
      ).
    assign
      p-unique-key-string = replace( v-field-value-list, {&delim-key}, ",":U )
      .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
