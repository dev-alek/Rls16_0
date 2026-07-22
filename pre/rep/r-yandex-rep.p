block-level on error undo, throw.
define variable vss-revision as character no-undo initial "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-yandex-rep.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-yandex-rep.p $":U .
define variable vss-description as character no-undo initial "Отчет по невалидным маркам".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
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
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
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
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
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
end procedure.
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
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
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
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
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
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character, input p-num as integer) forward.
function fnc-convert-dot-to-colon returns character
(input p-data as decimal, input p-accur as character, input p-num as integer):
    define variable result as character no-undo.
    define variable v-str-result as character no-undo.
    if p-data = ? then p-data = 0 .
    p-data = round(p-data, p-num).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
END FUNCTION.
define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input parameter p-cd-pay-recid     as character no-undo .
define input parameter p-rep-type         as integer no-undo .
define input parameter p-file             as character no-undo .
define input parameter p-RRN              as character no-undo .
define buffer buf_clients   for ub.clients .
define buffer buf_goods     for ub.goods .
define buffer buf_obj-list  for obj-list.
define buffer buf_gds-list  for gds-list.
define buffer buf_cash-pay  for ub.cash-pay .
define buffer buf_shift-obj for ub.shift-obj .
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable g#report-num        as integer   no-undo.
define variable v-report-name       as character no-undo.
define variable v-azk-list          as character no-undo .
define variable v-period            as character no-undo .
define variable v-color             as character no-undo .
define stream str-marks .
define stream OutStr-html.
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date) forward.
function fnc-obj-name returns character
    (input p-obj-code as integer, input p-obj-type as character) forward.
find first buf_cash-pay no-lock where recid(buf_cash-pay) = integer(p-cd-pay-recid) .
define temp-table tt-trans
    field azk      as character
    field qnty     as decimal
    field summ     as decimal
    field dt       as datetime
    field RRN      as character
    field transID  as character
    field gds-name as character
    field taken    as logical
    index pi as primary
    azk RRN
    .
define temp-table tt-rep
    field obj-type     as character
    field obj-code     as integer
    field obj-name     as character
    field gds-name     as character
    field shift-date   as date
    field shift-num    as integer
    field RRN-TH       as character
    field RRN-RN       as character
    field transID      as character
    field qnty-TH      as decimal
    field summ-TH      as decimal
    field qnty-RN-cart as decimal
    field summ-RN-cart as decimal
    field qnty-yandex  as decimal
    field summ-yandex  as decimal
    field dt-TH        as date
    field time-TH      as character
    field dt-RN-cart   as datetime
    field dt-yandex    as datetime
    field azk          as character
    index pi as primary
    obj-type obj-code RRN-TH
    .
define temp-table tt-itog
    field qnty-del     as integer
    field qnty-TH      as integer
    field qnty-RN      as integer
    field qnty-only-TH as integer
    .
define temp-table tt-obj
    field obj-type     like ub.clients.obj-type
    field obj-code     like ub.clients.obj-code
    field obj-name     like ub.clients.obj-name
    field qnty-TH      as decimal
    field summ-TH      as decimal
    field qnty-RN-cart as decimal
    field summ-RN-cart as decimal
    field qnty-yandex  as decimal
    field summ-yandex  as decimal
    index pi as primary
    obj-type obj-code
    .
define temp-table tt-shift
    field obj-type     as character
    field obj-code     as integer
    field shift-date   as date
    field shift-num    as integer
    field qnty-TH      as decimal
    field summ-TH      as decimal
    field qnty-RN-cart as decimal
    field summ-RN-cart as decimal
    field qnty-yandex  as decimal
    field summ-yandex  as decimal
    .
run waitfram-show in this-procedure ( "ЖДИТЕ... Обработка файла транзакций") .
if p-rep-type = 1
    then
do :
    run imp-RN-cart .
end .
if p-rep-type = 2
    then
do :
    run imp-yandex .
end .
run waitfram-hide in this-procedure .
run waitfram-show in this-procedure ( "ЖДИТЕ... Сборка данных для отчёта") .
run make-rep .
run waitfram-hide in this-procedure .
if x-TOG-Shift
    then
do :
    v-period = ("С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) + ", смена № "  + string(X-Shift-Start) +
        " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) + ", смена № " + string(X-Shift-End))
        .
end .
else
do :
    v-period = ("С " + fnc-DD-MM-YYYY(date(string(X-Date-Start,"99/99/9999"))) +
        " по " + fnc-DD-MM-YYYY(date(string(X-Date-End,"99/99/9999"))) )
        .
end .
for each obj-list :
    v-azk-list = v-azk-list + obj-list.obj-name + ", " .
end .
v-azk-list = trim(v-azk-list) .
v-azk-list = trim(v-azk-list, ",") .
if p-rep-type = 1
    then
do :
    run my-rep-ul in this-procedure .
end .
if p-rep-type = 2
    then
do :
    run my-rep-fl in this-procedure .
end .
procedure make-rep :
    define buffer buf_chk-gds-pay  for ub.chk-gds-pay .
    define buffer buf_chk-pay-attr for ub.chk-pay-attr .
    define buffer buf_chk-doc      for ub.chk-doc .
    define buffer buf_chk-gds      for ub.chk-gds .
    define buffer buf_goods        for ub.goods .
    define variable v-RRN  as character no-undo .
    define variable v-date as date      no-undo .
    define variable v-time as integer   no-undo .
    empty TEMP-TABLE tt-itog .
    create tt-itog .
    if p-RRN > ""
        then
    do :
        find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "CPDOC"
            and buf_chk-pay-attr.attr-value = p-RRN
            no-error .
        if not available buf_chk-pay-attr
            then
        do :
            find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "CPDOC"
                and int64(buf_chk-pay-attr.attr-value) = int64(p-RRN)
                no-error .
        end .
        if not available buf_chk-pay-attr
            then
        do :
            find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "RRN"
                and buf_chk-pay-attr.attr-value = p-RRN
                no-error .
        end .
        if not available buf_chk-pay-attr
            then
        do :
            find first buf_chk-pay-attr no-lock where buf_chk-pay-attr.attr-code = "RRN"
                and int64(buf_chk-pay-attr.attr-value) = int64(p-RRN)
                no-error .
        end .
        find first tt-trans exclusive-lock where tt-trans.RRN > ""
            and int64(tt-trans.RRN) = int64(p-RRN)
            and not tt-trans.taken
            no-error .
        if available buf_chk-pay-attr
            then
        do :
            for first buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-pay-attr.doc-code
                and buf_chk-gds-pay.cpline-num = buf_chk-pay-attr.line-num,
                first bar-code no-lock where bar-code.b-code = buf_chk-gds-pay.b-code,
                first buf_goods no-lock where buf_goods.gds-code = bar-code.gds-code
                :
                create tt-rep .
                assign
                    tt-rep.obj-type   = buf_chk-gds-pay.obj-type
                    tt-rep.obj-code   = buf_chk-gds-pay.obj-code
                    tt-rep.gds-name   = buf_goods.gds-name
                    tt-rep.qnty-TH    = buf_chk-gds-pay.eff-doc-qnty
                    tt-rep.summ-TH    = buf_chk-gds-pay.tot-r-b
                    tt-rep.dt-TH      = buf_chk-gds-pay.chk-date
                    tt-rep.time-TH    = string(truncate (buf_chk-gds-pay.chk-time / 3600, 0)) + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 60,"99") + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 360,"99")
                    tt-rep.shift-date = buf_chk-gds-pay.shift-date
                    tt-rep.shift-num  = buf_chk-gds-pay.shift-num
                    tt-rep.RRN-TH     = p-RRN
                    .
                    tt-rep.obj-name   = fnc-obj-name(buf_chk-gds-pay.obj-code, buf_chk-gds-pay.obj-type) .
                if available tt-trans
                    then
                do :
                    assign
                        tt-rep.dt-RN-cart   = tt-trans.dt
                        tt-rep.qnty-RN-cart = tt-trans.qnty
                        tt-rep.summ-RN-cart = tt-trans.summ
                        tt-rep.RRN-RN       = tt-trans.RRN
                        tt-rep.transID      = tt-trans.transID
                        tt-rep.azk          = tt-trans.azk
                        tt-trans.taken      = true
                        tt-itog.qnty-TH     = tt-itog.qnty-TH + 1
                        .
                    if tt-rep.qnty-RN-cart <> tt-rep.qnty-TH or tt-rep.summ-RN-cart <> round(tt-rep.summ-TH,2) then tt-itog.qnty-del = tt-itog.qnty-del + 1 .
                end .
                else tt-itog.qnty-only-TH = tt-itog.qnty-only-TH + 1 .
            end .
        end .
        else
        do :
            if available tt-trans
                then
            do :
                create tt-rep .
                assign
                    tt-rep.azk          = tt-trans.azk
                    tt-rep.gds-name     = tt-trans.gds-name
                    tt-rep.dt-RN-cart   = tt-trans.dt
                    tt-rep.qnty-RN-cart = tt-trans.qnty
                    tt-rep.summ-RN-cart = tt-trans.summ
                    tt-rep.RRN-RN       = tt-trans.RRN
                    tt-rep.transID      = tt-trans.transID
                    tt-trans.taken      = true
                    tt-itog.qnty-RN     = tt-itog.qnty-RN + 1
                    .
            end .
        end .
        return .
    end .
    for each obj-list
      :
      if x-TOG-Shift
      then do :
        if can-find(first ub.chk-doc where
            ub.chk-doc.obj-type = obj-list.obj-type and
            ub.chk-doc.obj-code = obj-list.obj-code and
            ub.chk-doc.shift-date >= X-date-Start and
            ub.chk-doc.shift-date <= X-date-End and
            ub.chk-doc.out-code > "" )
        then do:
          run rep/rpychk0.p ( input "r-shftc2"
              ,input obj-list.obj-type
              ,input obj-list.obj-code
              ,input ?
              ,input ?
              ,input X-date-Start
              ,input x-Date-End
              ,input x-Shift-Start
              ,input x-Shift-End
              ,input ?
              ).
        end .
      end .
      else do :
        if can-find(first ub.chk-doc where
            ub.chk-doc.obj-type = obj-list.obj-type and
            ub.chk-doc.obj-code = obj-list.obj-code and
            ub.chk-doc.chk-date >= X-date-Start and
            ub.chk-doc.chk-date <= X-date-End and
            ub.chk-doc.out-code > "" )
        then do:
          run rep/rpychk0.p ( input "r-shftc2"
              ,input obj-list.obj-type
              ,input obj-list.obj-code
              ,input x-date-Start
              ,input x-Date-End
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ,input ?
              ).
        end .
      end .
    end .
    for each units no-lock where
        lookup( 'топ':U, units.type) > 0,
        each buf_goods no-lock where
        buf_goods.unit-base = units.unit-name  , first bar-code no-lock where bar-code.gds-code  = buf_goods.gds-code
        :
        obj_:
        for each obj-list
            :
            if x-TOG-Shift
                then
            do :
                if can-find(first ub.chk-doc where
                    ub.chk-doc.obj-type = obj-list.obj-type and
                    ub.chk-doc.obj-code = obj-list.obj-code and
                    ub.chk-doc.shift-date >= X-date-Start and
                    ub.chk-doc.shift-date <= X-date-End and
                    ub.chk-doc.out-code > "" )
                    then
                do:
                    for each buf_chk-gds-pay no-lock where  buf_chk-gds-pay.b-code = bar-code.b-code  and
                        buf_chk-gds-pay.obj-type = obj-list.obj-type and
                        buf_chk-gds-pay.obj-code = obj-list.obj-code and
                        (
                        buf_chk-gds-pay.shift-date >= X-date-start and
                        buf_chk-gds-pay.shift-date <= X-date-end) :
                        if ((buf_chk-gds-pay.shift-date = x-date-Start and buf_chk-gds-pay.shift-num < X-shift-start)
                            or (buf_chk-gds-pay.shift-date = x-date-End and  buf_chk-gds-pay.shift-num > X-shift-end) )
                            then next.
                        if not (buf_chk-gds-pay.pay-code = buf_cash-pay.cdpay-code
                            and buf_chk-gds-pay.curr-code = buf_cash-pay.curr-code)
                            then next .
                        v-RRN = '' .
                        for first buf_chk-pay-attr no-lock
                            where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code
                            and buf_chk-pay-attr.attr-code = "CPDOC"
                            and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num  :
                            v-RRN = buf_chk-pay-attr.attr-value .
                        end.
                        if v-RRN = ''
                            then
                        do:
                            for first buf_chk-pay-attr no-lock
                                where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code
                                and buf_chk-pay-attr.attr-code = "RRN"
                                and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num:
                                v-RRN = buf_chk-pay-attr.attr-value .
                            end.
                        end.
                        find first tt-trans exclusive-lock where  tt-trans.RRN > ""
                            and int64(tt-trans.RRN) = int64(v-RRN)
                            and not tt-trans.taken
                            no-error .
                        create tt-rep .
                        assign
                            tt-rep.obj-type   = obj-list.obj-type
                            tt-rep.obj-code   = obj-list.obj-code
                            tt-rep.obj-name   = obj-list.obj-name
                            tt-rep.gds-name   = buf_goods.gds-name
                            tt-rep.qnty-TH    = buf_chk-gds-pay.eff-doc-qnty
                            tt-rep.summ-TH    = buf_chk-gds-pay.tot-r-b
                            tt-rep.dt-TH      = buf_chk-gds-pay.chk-date
                    tt-rep.time-TH    = string(truncate (buf_chk-gds-pay.chk-time / 3600, 0)) + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 60,"99") + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 360,"99")
                            tt-rep.shift-date = buf_chk-gds-pay.shift-date
                            tt-rep.shift-num  = buf_chk-gds-pay.shift-num
                            tt-rep.RRN-TH     = v-RRN
                            .
                        if available tt-trans
                            then
                        do :
                            assign
                                tt-rep.dt-RN-cart   = tt-trans.dt
                                tt-rep.qnty-RN-cart = tt-trans.qnty
                                tt-rep.summ-RN-cart = tt-trans.summ
                                tt-rep.RRN-RN       = tt-trans.RRN
                                tt-rep.transID      = tt-trans.transID
                                tt-rep.azk          = tt-trans.azk
                                tt-trans.taken      = true
                                tt-itog.qnty-TH     = tt-itog.qnty-TH + 1
                                .
                            if tt-rep.qnty-RN-cart <> tt-rep.qnty-TH or tt-rep.summ-RN-cart <> round(tt-rep.summ-TH,2) then tt-itog.qnty-del = tt-itog.qnty-del + 1 .
                        end .
                        else tt-itog.qnty-only-TH = tt-itog.qnty-only-TH + 1 .
                        release tt-rep .
                    end.
                end .
            end .
            else
            do :
                if can-find(first ub.chk-doc where
                    ub.chk-doc.obj-type = obj-list.obj-type and
                    ub.chk-doc.obj-code = obj-list.obj-code and
                    ub.chk-doc.chk-date >= X-date-Start and
                    ub.chk-doc.chk-date <= X-date-End and
                    ub.chk-doc.out-code > "" )
                    then
                do:
                    for each buf_chk-gds-pay no-lock where  buf_chk-gds-pay.b-code = bar-code.b-code  and
                        buf_chk-gds-pay.obj-type = obj-list.obj-type and
                        buf_chk-gds-pay.obj-code = obj-list.obj-code and
                        (
                        buf_chk-gds-pay.chk-date >= X-date-start and
                        buf_chk-gds-pay.chk-date <= X-date-end) :
                        if not (buf_chk-gds-pay.pay-code = buf_cash-pay.cdpay-code
                            and buf_chk-gds-pay.curr-code = buf_cash-pay.curr-code)
                            then next .
                        v-RRN = '' .
                        for first buf_chk-pay-attr no-lock
                            where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code
                            and buf_chk-pay-attr.attr-code = "CPDOC"
                            and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num  :
                            v-RRN = buf_chk-pay-attr.attr-value .
                        end.
                        if v-RRN = ''
                            then
                        do:
                            for first buf_chk-pay-attr no-lock
                                where buf_chk-pay-attr.doc-code = buf_chk-gds-pay.doc-code
                                and buf_chk-pay-attr.attr-code = "RRN"
                                and buf_chk-pay-attr.line-num = buf_chk-gds-pay.cpline-num:
                                v-RRN = buf_chk-pay-attr.attr-value .
                            end.
                        end.
                        find first tt-trans exclusive-lock where tt-trans.RRN > ""
                            and int64(tt-trans.RRN) = int64(v-RRN)
                            and not tt-trans.taken
                            no-error .
                        create tt-rep .
                        assign
                            tt-rep.obj-type   = obj-list.obj-type
                            tt-rep.obj-code   = obj-list.obj-code
                            tt-rep.obj-name   = obj-list.obj-name
                            tt-rep.gds-name   = buf_goods.gds-name
                            tt-rep.qnty-TH    = buf_chk-gds-pay.eff-doc-qnty
                            tt-rep.summ-TH    = buf_chk-gds-pay.tot-r-b
                            tt-rep.dt-TH      = buf_chk-gds-pay.chk-date
                            tt-rep.time-TH    = string(truncate (buf_chk-gds-pay.chk-time / 3600, 0)) + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 60,"99") + ":" + string((buf_chk-gds-pay.chk-time modulo 3600) / 360,"99")
                            tt-rep.shift-date = buf_chk-gds-pay.shift-date
                            tt-rep.shift-num  = buf_chk-gds-pay.shift-num
                            tt-rep.RRN-TH     = v-RRN
                            .
                        if available tt-trans
                            then
                        do :
                            assign
                                tt-rep.dt-RN-cart   = tt-trans.dt
                                tt-rep.qnty-RN-cart = tt-trans.qnty
                                tt-rep.summ-RN-cart = tt-trans.summ
                                tt-rep.RRN-RN       = tt-trans.RRN
                                tt-rep.transID      = tt-trans.transID
                                tt-rep.azk          = tt-trans.azk
                                tt-trans.taken      = true
                                tt-itog.qnty-TH     = tt-itog.qnty-TH + 1
                                .
                            if tt-rep.qnty-RN-cart <> tt-rep.qnty-TH or tt-rep.summ-RN-cart <> round(tt-rep.summ-TH,2) then tt-itog.qnty-del = tt-itog.qnty-del + 1 .
                        end .
                        else tt-itog.qnty-only-TH = tt-itog.qnty-only-TH + 1 .
                        release tt-rep .
                    end.
                end .
            end .
        end .
    end .
    for each tt-trans exclusive-lock where not tt-trans.taken :
        create tt-rep .
        assign
            tt-rep.azk          = tt-trans.azk
            tt-rep.gds-name     = tt-trans.gds-name
            tt-rep.dt-RN-cart   = tt-trans.dt
            tt-rep.qnty-RN-cart = tt-trans.qnty
            tt-rep.summ-RN-cart = tt-trans.summ
            tt-rep.RRN-RN       = tt-trans.RRN
            tt-rep.transID      = tt-trans.transID
            tt-trans.taken      = true
            .
        tt-itog.qnty-RN     = tt-itog.qnty-RN + 1
            .
        release tt-rep .
    end .
    for each tt-rep break by tt-rep.obj-type
        by tt-rep.obj-code
        by tt-rep.shift-date
        by tt-rep.shift-num
        :
        if first-of(tt-rep.obj-type)
            or first-of(tt-rep.obj-code)
            then
        do :
            create tt-obj .
            assign
                tt-obj.obj-type = tt-rep.obj-type
                tt-obj.obj-code = tt-rep.obj-code
                .
            for first obj-list no-lock where obj-list.obj-type = tt-rep.obj-type
                and obj-list.obj-code = tt-rep.obj-code
                :
                assign
                    tt-obj.obj-name = obj-list.obj-name .
            end .
        end .
        if first-of(tt-rep.shift-date)
            or first-of(tt-rep.shift-num)
            then
        do :
            create tt-shift .
            assign
                tt-shift.obj-type   = tt-rep.obj-type
                tt-shift.obj-code   = tt-rep.obj-code
                tt-shift.shift-date = tt-rep.shift-date
                tt-shift.shift-num  = tt-rep.shift-num
                .
        end .
        assign
            tt-obj.qnty-TH      = tt-obj.qnty-TH      + tt-rep.qnty-TH
            tt-obj.summ-TH      = tt-obj.summ-TH      + tt-rep.summ-TH
            tt-obj.qnty-RN-cart = tt-obj.qnty-RN-cart + tt-rep.qnty-RN-cart
            tt-obj.summ-RN-cart = tt-obj.summ-RN-cart + tt-rep.summ-RN-cart
            tt-obj.qnty-yandex  = tt-obj.qnty-yandex  + tt-rep.qnty-yandex
            tt-obj.summ-yandex  = tt-obj.summ-yandex  + tt-rep.summ-yandex
            .
        assign
            tt-shift.qnty-TH      = tt-shift.qnty-TH      + tt-rep.qnty-TH
            tt-shift.summ-TH      = tt-shift.summ-TH      + tt-rep.summ-TH
            tt-shift.qnty-RN-cart = tt-shift.qnty-RN-cart + tt-rep.qnty-RN-cart
            tt-shift.summ-RN-cart = tt-shift.summ-RN-cart + tt-rep.summ-RN-cart
            tt-shift.qnty-yandex  = tt-shift.qnty-yandex  + tt-rep.qnty-yandex
            tt-shift.summ-yandex  = tt-shift.summ-yandex  + tt-rep.summ-yandex
            .
        if last-of(tt-rep.obj-type)
            or last-of(tt-rep.obj-code)
            then
        do :
            release tt-obj .
        end .
        if last-of(tt-rep.shift-date)
            or last-of(tt-rep.shift-num)
            then
        do :
            release tt-shift .
        end .
    end .
end procedure .
procedure imp-RN-cart :
    DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO.
    DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO.
    DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO.
    DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO.
    DEFINE VARIABLE vLine             AS INTEGER          NO-UNDO.
    DEFINE VARIABLE vChLine           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vCh               AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vNoLine           AS INTEGER          NO-UNDO.
    define variable v-num             as character        no-undo .
    define variable v-azk             as character        no-undo .
    define variable v-summ            as character        no-undo .
    define variable v-qnty            as character        no-undo .
    define variable v-dt              as character        no-undo .
    define variable v-RRN             as character        no-undo .
    define variable v-transID         as character        no-undo .
    define variable v-gds-name        as character        no-undo .
    CREATE "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
    ASSIGN
        mExcelApplication:DisplayAlerts = NO
        mWorkbook                       = mExcelApplication:WorkBooks:Add(p-file)
        mWorkSheet                      = mWorkbook:Sheets:Item(1)
        .
    loopbl:
    do vLine = 1 to 1000000:
        ASSIGN
            vChLine    = STRING(vLine)
            v-azk      = ''
            v-summ     = ''
            v-qnty     = ''
            v-dt       = ''
            v-RRN      = ''
            v-transID  = ''
            v-gds-name = ''
            .
        v-RRN = mWorkSheet:Range("P" + vChLine):FORMULA NO-ERROR.
        if v-RRN = ? then v-RRN = mWorkSheet:Range("P" + vChLine):VALUE NO-ERROR.
        if p-RRN > ""
            then
        do :
            if int64(p-RRN) <> int64(v-RRN) then next loopbl .
        end .
        v-num = mWorkSheet:Range("A" + vChLine):FORMULA NO-ERROR.
        if v-num = ? then v-num = mWorkSheet:Range("A" + vChLine):VALUE NO-ERROR.
        integer(v-num) no-error .
        if error-status:error then next loopbl .
        v-azk = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR.
        if v-azk = ? then v-azk = mWorkSheet:Range("C" + vChLine):VALUE NO-ERROR.
        v-summ = mWorkSheet:Range("M" + vChLine):FORMULA NO-ERROR.
        if v-summ = ? then v-summ = mWorkSheet:Range("M" + vChLine):VALUE NO-ERROR.
        v-summ = replace(v-summ, ",", ".") .
        decimal(v-summ) no-error .
        if error-status:error then next loopbl .
        v-qnty = mWorkSheet:Range("K" + vChLine):FORMULA NO-ERROR.
        if v-qnty = ? then v-qnty = mWorkSheet:Range("K" + vChLine):VALUE NO-ERROR.
        v-qnty = replace(v-qnty, ",", ".") .
        v-dt = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.
        if v-dt = ? then v-dt = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.
        v-transID = mWorkSheet:Range("H" + vChLine):FORMULA NO-ERROR.
        if v-transID = ? then v-transID = mWorkSheet:Range("H" + vChLine):VALUE NO-ERROR.
        v-gds-name = mWorkSheet:Range("J" + vChLine):VALUE NO-ERROR.
        if v-gds-name = ? then v-gds-name = mWorkSheet:Range("J" + vChLine):FORMULA NO-ERROR.
        if length(v-azk) > 0
            or length(v-summ) > 0
            or length(v-qnty) > 0
            or length(v-dt) > 0
            or length(v-RRN) > 0
            or length(v-transID) > 0
            or length(v-gds-name) > 0
            then
        do :
            vNoLine = 0 .
        end.
        else
        do :
            vNoLine = vNoLine + 1.
            IF vNoLine > mMaxNoLine THEN LEAVE loopbl.
            ELSE NEXT loopbl.
        end.
        create tt-trans .
        tt-trans.azk       = v-azk .
        tt-trans.qnty      = decimal(v-qnty) .
        tt-trans.summ      = decimal(v-summ) .
        tt-trans.dt        = datetime(v-dt) .
        tt-trans.RRN       = trim(v-RRN) .
        tt-trans.transID   = trim(v-transID) .
        tt-trans.gds-name  = v-gds-name .
        tt-trans.taken     = false .
        release tt-trans .
    end.
end procedure .
procedure imp-yandex :
    DEFINE VARIABLE mExcelApplication AS COMPONENT-HANDLE NO-UNDO.
    DEFINE VARIABLE mWorkBook         AS COMPONENT-HANDLE NO-UNDO.
    DEFINE VARIABLE mWorkSheet        AS COMPONENT-HANDLE NO-UNDO.
    DEFINE VARIABLE mMaxNoLine        AS INTEGER          INITIAL 10 NO-UNDO.
    DEFINE VARIABLE vLine             AS INTEGER          NO-UNDO.
    DEFINE VARIABLE vChLine           AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vCh               AS CHARACTER        NO-UNDO.
    DEFINE VARIABLE vNoLine           AS INTEGER          NO-UNDO.
    define variable v-num             as character        no-undo .
    define variable v-azk             as character        no-undo .
    define variable v-summ            as character        no-undo .
    define variable v-qnty            as character        no-undo .
    define variable v-dt              as character        no-undo .
    define variable v-RRN             as character        no-undo .
    define variable v-transID         as character        no-undo .
    define variable v-gds-name        as character        no-undo .
    define variable v-date            as character        no-undo .
    define variable v-time            as character        no-undo .
    CREATE "Excel.Application":U mExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
    ASSIGN
        mExcelApplication:DisplayAlerts = NO
        mWorkbook                       = mExcelApplication:WorkBooks:Add(p-file)
        mWorkSheet                      = mWorkbook:Sheets:Item(1)
        .
    loopbl:
    do vLine = 1 to 1000000:
        ASSIGN
            vChLine    = STRING(vLine)
            v-azk      = ''
            v-summ     = ''
            v-qnty     = ''
            v-dt       = ''
            v-RRN      = ''
            v-transID  = ''
            v-gds-name = ''
            .
        v-RRN = mWorkSheet:Range("P" + vChLine):FORMULA NO-ERROR.
        if v-RRN = ? then v-RRN = mWorkSheet:Range("P" + vChLine):VALUE NO-ERROR.
        if p-RRN > ""
            then
        do :
            if int64(p-RRN) <> int64(v-RRN) then next loopbl .
        end .
        v-azk = mWorkSheet:Range("B" + vChLine):VALUE NO-ERROR.
        if v-azk = ? then v-azk = mWorkSheet:Range("C" + vChLine):FORMULA NO-ERROR.
        v-summ = mWorkSheet:Range("M" + vChLine):FORMULA NO-ERROR.
        if v-summ = ? then v-summ = mWorkSheet:Range("M" + vChLine):VALUE NO-ERROR.
        v-summ = replace(v-summ, ",", ".") .
        decimal(v-summ) no-error .
        if error-status:error then next loopbl .
        v-qnty = mWorkSheet:Range("K" + vChLine):FORMULA NO-ERROR.
        if v-qnty = ? then v-qnty = mWorkSheet:Range("K" + vChLine):VALUE NO-ERROR.
        v-qnty = replace(v-qnty, ",", ".") .
        v-date = mWorkSheet:Range("E" + vChLine):VALUE NO-ERROR.
        if v-date = ? then v-date = mWorkSheet:Range("E" + vChLine):FORMULA NO-ERROR.
        v-time = mWorkSheet:Range("F" + vChLine):FORMULA NO-ERROR.
        if v-time = ? then v-time = mWorkSheet:Range("F" + vChLine):VALUE NO-ERROR.
        v-dt = v-date + "  " + v-time .
        v-dt = trim(v-dt) .
        v-transID = mWorkSheet:Range("H" + vChLine):FORMULA NO-ERROR.
        if v-transID = ? then v-transID = mWorkSheet:Range("H" + vChLine):VALUE NO-ERROR.
        v-gds-name = mWorkSheet:Range("N" + vChLine):VALUE NO-ERROR.
        if v-gds-name = ? then v-gds-name = mWorkSheet:Range("N" + vChLine):FORMULA NO-ERROR.
        if length(v-azk) > 0
            or length(v-summ) > 0
            or length(v-qnty) > 0
            or length(v-dt) > 0
            or length(v-RRN) > 0
            or length(v-transID) > 0
            or length(v-gds-name) > 0
            then
        do :
            vNoLine = 0 .
        end.
        else
        do :
            vNoLine = vNoLine + 1.
            IF vNoLine > mMaxNoLine THEN LEAVE loopbl.
            ELSE NEXT loopbl.
        end.
        create tt-trans .
        tt-trans.azk       = v-azk .
        tt-trans.qnty      = decimal(v-qnty) .
        tt-trans.summ      = decimal(v-summ) .
        tt-trans.dt        = datetime(v-dt) .
        tt-trans.RRN       = trim(v-RRN) .
        tt-trans.transID   = trim(v-transID) .
        tt-trans.gds-name  = v-gds-name .
        tt-trans.taken     = false .
        release tt-trans .
    end.
end procedure .
procedure my-rep-ul :
    run get-full-path-RepViewer(output v-full-path-RepView).
    run get-report-num in parParentProc(output g#report-num).
    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
    run create-file(v-file-name-rep-htm).
    run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
        '      tbody, td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
    put stream OutStr-html unformatted
        '<body>' skip
        '<table name="Лист1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 140px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;"></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="13" style="text-align: center; font-weight:bold;">Отчет по сверке продаж по Юр. Лицам по ' + v-azk-list + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;">Параметры: ' + v-period + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="13" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip
        '</thead>' skip
        .
    put stream OutStr-html unformatted
        '     <tbody>' skip
        '       <tr>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Номенклатура</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение литры</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение сумма</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN РН-Карт</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (РН-Карт)</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (ГБД)</th>' skip
        '       </tr>' skip
        .
    if p-RRN = ""
        then
    do :
        for each tt-obj by tt-obj.obj-name desc:
            if not trim(tt-obj.obj-name) = ""
                then
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="text-align: left; background-color: yellow;">' + tt-obj.obj-name + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '       </tr>' skip
                    .
            if tt-obj.obj-name = ""
                then
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td colspan = "13" style="text-align: left; font-weight: normal; background-color: yellow;">Расхождения</td>' skip
                    '       </tr>' skip
                    .
            for each tt-shift where tt-shift.obj-type = tt-obj.obj-type
                and tt-shift.obj-code = tt-obj.obj-code
                :
                if tt-shift.shift-date <> ?
                    then
                    put stream OutStr-html unformatted
                        '       <tr level="2">' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: yellow;">  Смена №' + string(tt-shift.shift-num) + ' от ' + string(tt-shift.shift-date) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '       </tr>' skip
                        .
                for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
                    and tt-rep.obj-code   = tt-shift.obj-code
                    and tt-rep.shift-date = tt-shift.shift-date
                    and tt-rep.shift-num  = tt-shift.shift-num
                    :
                        if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
                    else v-color = "white" .
                    put stream OutStr-html unformatted
                        '       <tr level="3">' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + "    " + tt-rep.gds-name + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                        '       </tr>' skip
                        .
                end .
            end .
        end .
    end.
    else
    do :
        for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
            and tt-rep.obj-code   = tt-shift.obj-code
            and tt-rep.shift-date = tt-shift.shift-date
            and tt-rep.shift-num  = tt-shift.shift-num
            :
                if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
                    else v-color = "white" .
            put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + "    " + tt-rep.gds-name + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                '       </tr>' skip
                .
        end .
    end .
    for first tt-itog:
        put stream OutStr-html unformatted
            '       <tfoot>' skip
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">Всего транзакций: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-TH + tt-itog.qnty-only-TH + tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">из них с расхождением: </td>' skip
            '       <td style="text-align: right; font-weight: normal"></td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только из ГБД: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-only-TH) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только РН-кард: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">по суммам и кол-ву: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-del) + '</td>' skip
            '       <td colspan = "8"></td>' skip
            '       </tr>' skip
            '       </tfoot>' skip
            .
    end .
    put stream OutStr-html unformatted
        '     </tbody>' skip
        '   </table>' skip
        '  </body>' skip
        ' </html>' skip
        .
    output stream OutStr-html close.
    run waitfram-hide in this-procedure .
    run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-htm
        ).
end procedure .
procedure my-rep-fl :
    run get-full-path-RepViewer(output v-full-path-RepView).
    run get-report-num in parParentProc(output g#report-num).
    run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
    run create-file(v-file-name-rep-htm).
    run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .
    output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 500px; padding: 3px; ' + chr(125) skip
        '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
        '      htm' skip
        '      .rotate ' + chr(123) skip
        '        -webkit-transform: rotate(-90deg);' skip
        '        -moz-transform: rotate(-90deg);' skip
        '        -ms-transform: rotate(-90deg);' skip
        '        -o-transform: rotate(-90deg);' skip
        '        transform: rotate(-90deg);' skip
        '        -webkit-transform-origin: 50% 50%;' skip
        '        -moz-transform-origin: 50% 50%;' skip
        '        -ms-transform-origin: 50% 50%;' skip
        '        -o-transform-origin: 50% 50%;' skip
        '        transform-origin: 50% 50%;' skip
        '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
        '          ' + chr(125) skip
        '            th' + ' ' + chr(123) skip
        '            border: 1px black solid;' skip
        '            word-wrap: break-word;' skip
        '          ' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
    put stream OutStr-html unformatted
        '<body>' skip
        '<table name="Лист1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
        '<thead>' skip
        .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
        '<td style="width: 140px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 120px; border: none;"></td>' skip
        '<td style="width: 120px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 200px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '<td style="width: 90px; border: none;"></td>' skip
        '</tr>' skip
        .
    put stream OutStr-html unformatted
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;"></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="14" style="text-align: center; font-weight:bold;">Отчет по сверке продаж по Физ. Лицам по ' + v-azk-list + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;">Параметры: ' + v-period + '</td>' skip
        '</tr>' skip
        '<tr>' skip
        '<td colspan="14" style="text-align: left; font-weight:bold;"><br></td>' skip
        '</tr>' skip
        '</thead>' skip
        .
    put stream OutStr-html unformatted
        '     <tbody>' skip
        '       <tr>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px; width: 140px;">Номенклатура</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Литры Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Сумма Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение литры</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расхождение сумма</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата Яндекс (московск. время)</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">RRN ГБД</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">ID Яндекс</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (Яндекс)</th>' skip
        '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС (ГБД)</th>' skip
        '       </tr>' skip
        .
    if p-RRN = ""
        then
    do :
        for each tt-obj by tt-obj.obj-name desc:
            if not trim(tt-obj.obj-name) = ""
                then
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td style="text-align: left; font-weight: normal; background-color: yellow;">' + tt-obj.obj-name + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-obj.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.qnty-TH - tt-obj.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-obj.summ-TH - tt-obj.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                    '       </tr>' skip
                    .
            if tt-obj.obj-name = ""
                then
                put stream OutStr-html unformatted
                    '       <tr>' skip
                    '         <td colspan = "14" style="text-align: left; font-weight: normal; background-color: yellow;">Расхождения</td>' skip
                    '       </tr>' skip
                    .
            for each tt-shift where tt-shift.obj-type = tt-obj.obj-type
                and tt-shift.obj-code = tt-obj.obj-code
                :
                if tt-shift.shift-date <> ?
                    then
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: yellow;">  Смена №' + string(tt-shift.shift-num) + ' от ' + string(tt-shift.shift-date) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-TH,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon(tt-shift.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.qnty-TH - tt-shift.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td  num="0.00" val="' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: yellow;">' + fnc-convert-dot-to-colon((tt-shift.summ-TH - tt-shift.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: yellow;"><br></td>' skip
                        '       </tr>' skip
                        .
                for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
                    and tt-rep.obj-code   = tt-shift.obj-code
                    and tt-rep.shift-date = tt-shift.shift-date
                    and tt-rep.shift-num  = tt-shift.shift-num
                    :
                    if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
                    else v-color = "white" .
                    put stream OutStr-html unformatted
                        '       <tr>' skip
                        '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + "    " + tt-rep.gds-name + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.transID + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                        '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                        '       </tr>' skip
                        .
                end .
            end .
        end .
    end.
    else
    do :
        for each tt-rep where tt-rep.obj-type   = tt-shift.obj-type
            and tt-rep.obj-code   = tt-shift.obj-code
            and tt-rep.shift-date = tt-shift.shift-date
            and tt-rep.shift-num  = tt-shift.shift-num
            :
            if tt-rep.qnty-TH <> tt-rep.qnty-RN-cart or round(tt-rep.summ-TH,2) <> tt-rep.summ-RN-cart then v-color = "#FFB6C1" .
            else v-color = "white" .
            put stream OutStr-html unformatted
                '       <tr level="1">' skip
                '         <td style="text-align: left; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.gds-name + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-TH = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-TH,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.qnty-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.qnty-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.summ-RN-cart = 0 then " " else fnc-convert-dot-to-colon(tt-rep.summ-RN-cart,"->>>>>>>>>>>>>9.99",2)) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.qnty-TH - tt-rep.qnty-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td num="0.00" val="' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + fnc-convert-dot-to-colon((tt-rep.summ-TH - tt-rep.summ-RN-cart),"->>>>>>>>>>>>>9.99",2) + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-TH <> ? then string(tt-rep.dt-TH,"99.99.9999") + " " + tt-rep.time-TH else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + (if tt-rep.dt-RN-cart <> ? then string(tt-rep.dt-RN-cart, "99.99.9999 HH:MM:SS") else " ") + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-RN + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.RRN-TH + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.transID + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + tt-rep.azk + '</td>' skip
                '         <td style="text-align: right; font-weight: normal; background-color: ' + v-color + ';">' + string(tt-rep.obj-name) + '</td>' skip
                '       </tr>' skip
                .
        end .
    end .
    for first tt-itog:
        put stream OutStr-html unformatted
            '       <tfoot>' skip
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">Всего транзакций: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-TH + tt-itog.qnty-only-TH + tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "1"></td>' skip
            '       <td colspan = "4" style="text-align: left; font-weight: normal">из них с расхождением: </td>' skip
            '       <td style="text-align: right; font-weight: normal"></td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только из ГБД: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-only-TH) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">только Яндекс: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-RN) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip
            '       <tr>' skip
            '       <td colspan = "2"></td>' skip
            '       <td colspan = "3" style="text-align: left; font-weight: normal">по суммам и кол-ву: </td>' skip
            '       <td style="text-align: right; font-weight: normal">' + string(tt-itog.qnty-del) + '</td>' skip
            '       <td colspan = "9"></td>' skip
            '       </tr>' skip
            '       </tfoot>' skip
            .
    end .
    put stream OutStr-html unformatted
        '     </tbody>' skip
        '   </table>' skip
        '  </body>' skip
        ' </html>' skip
        .
    output stream OutStr-html close.
    output stream OutStr-html close.
    run waitfram-hide in this-procedure .
    run prn-lib-reportviewer-report-name in this-procedure (
        input THIS-PROCEDURE
        ,input v-file-name-rep-htm
        ).
end procedure .
procedure get-full-path-RepViewer:
    define output parameter p-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure search-full-path-Report:
    define input parameter p-file-name as character no-undo.
    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).
end procedure.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date):
    define variable result     as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
    return p-str-date.
end function.
 function fnc-obj-name returns character
    (input p-obj-code as integer, input p-obj-type as character):
    define variable result     as character no-undo.
    define variable p-obj-name as character no-undo.
    define buffer buf_clients for ub.clients .
    for first buf_clients no-lock where buf_clients.obj-code = p-obj-code
                                    and buf_clients.obj-type = p-obj-type:
    p-obj-name = buf_clients.obj-name.
    end.
    return p-obj-name.
end function.
