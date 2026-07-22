/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека процедур для печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/17/03
Author: Bakhtadze Natalya
Creation date: 10/17/03

*/

&if defined(prn-lib_i) = 0 &then
&glob prn-lib_i

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "" &then
  &scoped-define PrnLibStream PrnLibStream
&else
  &scoped-define PrnLibStream {2}
&endif

define {1} stream {&PrnLibStream}.


procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .

  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .

  do
    on error undo, return error
    :
    
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).

    /* Проверка на пустой файл */
    { gbl/filenmln.i v-report-name 2 v-exist }

    if NOT v-exist then 
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.

    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .

    /* возвращаем признак того, была ли напечатана форма */
    if v-printed then 
    do:
      return "YES" .
    end.
    else 
    do:
      return "NO" .
    end.
  end. /*doe*/

end procedure. /* prn-lib-prn-file */

procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .


  define variable v-report-name as character no-undo .

  do
    on error undo, return error
    :

    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).

    if p-is-stream then 
    do:
      if p-append then 
      do:
        output stream {&PrnLibStream} to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then 
      do:
        output stream {&PrnLibStream} to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then 
    do:
      if p-append then 
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then 
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.

end procedure. /* prn-lib-open-stream */


procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .


  define variable glog as logical no-undo .

  do
    on error undo, return error
    :

    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then 
    do:
      if p-is-append then 
      do:
        OUTPUT stream {&PrnLibStream} TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else 
      do:
        OUTPUT stream {&PrnLibStream} TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else 
    do:
      if p-is-append then 
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else 
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.

end procedure. /* prn-lib-open-exp */

procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.   
  define output parameter p-report-name as character no-undo .

   &if defined(DF_NAME) = 0 &then
   &global-define DF_Name        "rpt"
   &endif
   
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name({&DF_Name}).
end procedure. /* prn-lib-get-report-name */


procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure. /* prn-lib-reportviewer-report-name */

procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
    
  run adm/shattri.p (
    input "get":U
    ,input  "" /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-report-glob}
    ,input  {&attr-report-glob_rep-excel} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) /*no-error*/ .
  if rep-excel then v-excel = "TRUE" . /* защита для отчетов в excel*/
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + {&delim-par} + "EXCEL:" + v-excel .   
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param). 
   

end procedure. /* prn-lib-reportviewer */
&endif

/* $Workfile$ e n d */