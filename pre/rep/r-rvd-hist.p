block-level on error undo, throw.
define input parameter p-inv-RVD as logical no-undo .
define variable vss-revision    as character no-undo initial "$Revision: 05d5ec57b83c, 3284, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/03/29 08:47:58 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-RVD-hist.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-RVD-hist.p $":U .
define variable vss-description as character no-undo initial "Запускалка отчета r-inptl.p":U .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared stream PrnLibStream.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable is-petrol   as logical   no-undo.
define variable is-pieces   as logical   no-undo.
define variable store-name as character no-undo.
define variable v-count as integer initial 0  no-undo .
define variable v-full-path-RepView as character no-undo.
define variable v-file-name-rep-htm as character no-undo.
define variable g#report-num        as integer   no-undo.
define variable v-report-name       as character no-undo.
define variable v-azk-list          as character no-undo .
define variable v-org-list          as character no-undo .
define variable v-period            as character no-undo .
define variable v-legend1           as character no-undo .
define variable v-legend2           as character no-undo .
define variable v-legend3           as character no-undo .
define variable x-Time-Start        as integer   no-undo init -1 .
define variable x-Time-End          as integer   no-undo init -1 .
define stream OutStr-html.
define buffer bf-gds-list for gds-list .
define buffer buf_clients for ub.clients .
define buffer buf_goods for ub.goods .
define buffer buf_units for ub.units  .
define buffer buf_shift-obj for ub.shift-obj .
define BUFFER bf_c-user-log for ub.c-user-log .
define temp-table tt-report no-undo
  field firm-name     as character
  field obj-type      as character
  field obj-code      as integer
  field host-code     as integer
  field obj-name      as character
  field pl-code       as integer
  field loc1          as character
  field pl-name       as character
  field gds-code      as integer
  field gds-name      as character
  field corr-dt       as character
  field corr-date     as date
  field corr-time     as int64
  field corr-par      as character
  field rvd-reason    as character
  field pl-state      as character
  field corr-period   as character
  field temp-state    as character
  field dens-state    as character
  field level-state   as character
  field shift-num     as character
  field ITSM-num      as character
  field executor      as character
  field initiator     as character
.
if not can-find( first obj-list ) then do:
  message "Вы не выбрали объект." view-as alert-box error.
  return.
end.
find first obj-list.
if not can-find( first gds-list )
then do:
  for each buf_units no-lock where
        lookup( 'топ':U, buf_units.type) > 0,
    each buf_goods no-lock where
          buf_goods.unit-base = buf_units.unit-name
          :
    create gds-list.
    buffer-copy buf_goods to  gds-list .
  end.
end.
find first gds-list.
for each bf-gds-list :
  find first ub.goods no-lock where
              ub.goods.artic     = bf-gds-list.artic     and
              ub.goods.prod-type = bf-gds-list.prod-type and
              ub.goods.prod-code = bf-gds-list.prod-code no-error.
  if not available ub.goods then do: next. end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
  if error-status :error
    or is-petrol <> yes
    or is-pieces <> no
  then do:
    message
      substitute("Отчет может быть запущен только для топливного товара") skip
      view-as alert-box error .
    return .
  end.
end.
if x-TOG-Shift
then do :
  for each obj-list no-lock :
    find last buf_shift-obj no-lock where buf_shift-obj.obj-type = obj-list.obj-type
                                      and buf_shift-obj.obj-code = obj-list.obj-code
                                      and buf_shift-obj.shift-date <= x-Date-End
                                      and buf_shift-obj.shift-num <= x-Shift-End
                                      no-error .
    if available buf_shift-obj
    then do :
      if buf_shift-obj.close-date = ?
      then do :
        x-Date-End = today .
        x-Time-End = time .
      end .
      else do :
        if buf_shift-obj.close-date >= x-Date-End
        then do :
          if (buf_shift-obj.close-date = x-Date-End and buf_shift-obj.close-time > x-Time-End)
          or buf_shift-obj.close-date > x-Date-End
          then x-Time-End = buf_shift-obj.close-time .
          x-Date-End = buf_shift-obj.close-date .
        end .
      end .
    end .
    find first buf_shift-obj no-lock where buf_shift-obj.obj-type = obj-list.obj-type
                                       and buf_shift-obj.obj-code = obj-list.obj-code
                                       and buf_shift-obj.shift-date = x-Date-Start
                                       and buf_shift-obj.shift-num >= x-Shift-Start
                                       no-error .
    if available buf_shift-obj
    then do :
      if x-Time-Start = -1
      then x-Time-Start = buf_shift-obj.open-time .
      if buf_shift-obj.open-time < x-Time-Start
      then x-Time-Start = buf_shift-obj.open-time .
    end .
  end .
end .
if x-TOG-Shift
then do :
  v-period = "Смены с " + string(x-Shift-Start) +
             " по " + string(x-Shift-End) + chr(10) +
             "За период с " + string(x-Date-Start) +
             " по " + string(x-Date-End)
             .
end .
else do :
  v-period = "За период с " + string(x-Date-Start) +
             " по " + string(x-Date-End)
             .
end .
v-legend1 = "А – автоматический ввод данных; Р – ручной ввод данных; ПА – полуавтоматический ввод данных;" .
v-legend2 = "Расшифровка для столбца 9 - Указывается режим измерения для резервуара после его изменения - А: Если в системе установлен маркер «Измеряется приборами» и РВД по параметрам отключен;   Р: Если в системе не установлен маркер «Измеряется приборами или в системе установлен маркер «Измеряется приборами», но разрешение РВД установлено для всех трех параметров» ПА: Если в системе установлен маркер «Измеряется приборами», но разрешение РВД установлено для одного или двух параметров" .
v-legend3 = "Расшифровка для столбцов 7,11,12,13 - 7: Указывается режим измерения в который переводится параметр/параметры (А или Р); 11,12,13: Указывается режим измерения для параметров после его изменения (А или Р)" .
run waitfram-show in this-procedure ( "ЖДИТЕ... Формирование отчёта") .
run make-rep .
run print-rep .
run waitfram-hide in this-procedure .
procedure make-rep :
  define variable v-shift-num as integer no-undo .
  define variable v-shift-date as date no-undo .
  define variable v-obj-type  as character no-undo .
  define variable v-obj-code  as integer no-undo .
  define variable v-pl-code   as integer no-undo .
  define variable v-rvd-reason-code as character no-undo .
  define variable v-host-code as integer no-undo .
  define variable v-RVD-on    as logical no-undo .
  define variable v-RVD-params as character no-undo .
  define variable v-RVD-dens  as logical no-undo .
  define variable v-RVD-temp  as logical no-undo .
  define variable v-RVD-level as logical no-undo .
  define variable v-date1 as date no-undo .
  define variable v-date2 as date no-undo .
  define variable v-date-diff as integer no-undo .
  define variable v-time1 as integer no-undo .
  define variable v-time2 as integer no-undo .
  define variable v-time-diff as integer no-undo .
  define variable v-is-meas as logical no-undo .
  define variable v-found-next as logical no-undo .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_ext-classif for ub.ext-classif .
  define buffer buf_place for ub.place .
  define buffer buf_goods for ub.goods .
  define buffer buf_user-account for ub.user-account .
  define buffer buf_c-user-log for ub.c-user-log .
  define buffer buf_clients for ub.clients .
  define buffer buf2_clients for ub.clients .
  empty temp-table tt-report .
  v-org-list = "" .
  v-azk-list = "" .
  for each buf_clients no-lock,
  first obj-list no-lock where obj-list.obj-type = buf_clients.obj-type
                           and obj-list.obj-code = buf_clients.obj-code
                           break by buf_clients.host-code
                           :
    if first-of(buf_clients.host-code)
    then do :
      for first buf2_clients no-lock where buf2_clients.obj-type = 'орг':U
                                       and buf2_clients.obj-code = buf_clients.host-code
                                       :
        v-org-list = v-org-list + buf2_clients.obj-name + ", " .
      end .
    end .
    v-azk-list = v-azk-list + buf_clients.obj-name + ", " .
  end .
  v-org-list = trim(v-org-list, ", ") .
  v-azk-list = trim(v-azk-list, ", ") .
  user-log_ :
  for each bf_c-user-log no-lock where bf_c-user-log.corr-date >= x-Date-Start
                                   and bf_c-user-log.corr-date <= x-Date-End
                                   and bf_c-user-log.head-table = 'rvd-reasons':U
                                   break by bf_c-user-log.corr-date by bf_c-user-log.corr-time
                                   :
    if not p-inv-RVD
    and num-entries(bf_c-user-log.head-table-key, chr(6)) = 23
    and entry(15, bf_c-user-log.head-table-key, chr(6)) > ""
    then next user-log_ .
    v-obj-type = entry(1, bf_c-user-log.head-table-key, chr(6)) .
    v-obj-code = integer(entry(2, bf_c-user-log.head-table-key, chr(6))) .
    if not can-find( first obj-list where obj-list.obj-type = v-obj-type and obj-list.obj-code = v-obj-code )
    then next user-log_ .
    v-shift-date = date(entry(3, bf_c-user-log.head-table-key, chr(6))) .
    v-shift-num = integer(entry(4, bf_c-user-log.head-table-key, chr(6))) .
    if x-TOG-Shift
    then do :
      if v-shift-num = 0
      then do :
        if v-shift-date < x-Date-Start
        or v-shift-date > x-Date-end
        then next user-log_ .
      end .
      else do :
        if (v-shift-date = x-Date-Start
        and v-shift-num < x-Shift-Start)
        or v-shift-date < x-Date-Start
        then next user-log_ .
        if (v-shift-date = x-Date-End
        and v-shift-num > x-Shift-End)
        or v-shift-date > x-Date-end
        then next user-log_ .
      end .
      if x-Time-End >= 0
      then do :
        if bf_c-user-log.corr-date = x-Date-end
        and bf_c-user-log.corr-time > (x-Time-End + 59)
        then next user-log_ .
      end .
      if x-Time-Start >= 0
      then do :
        if bf_c-user-log.corr-date = x-Date-Start
        and bf_c-user-log.corr-time < x-Time-Start
        then next user-log_ .
      end .
    end .
    v-pl-code = integer(entry(5, bf_c-user-log.head-table-key, chr(6))) .
    find first buf_pl-gds no-lock where buf_pl-gds.obj-type = v-obj-type
                                    and buf_pl-gds.obj-code = v-obj-code
                                    and buf_pl-gds.pl-code  = v-pl-code
                                    no-error .
    if not available buf_pl-gds
    then next user-log_ .
    if not can-find( first gds-list where gds-list.gds-code = buf_pl-gds.gds-code )
    then next user-log_ .
    v-rvd-reason-code = entry(8, bf_c-user-log.head-table-key, chr(6)) .
    find first buf_ext-classif no-lock where buf_ext-classif.CharKey_One = v-rvd-reason-code
                                         and buf_ext-classif.classif-subject = 'rvd-reason':U
                                         and buf_ext-classif.classif-name = 'rvd-reason':U
                                         no-error .
    if not available buf_ext-classif
    then next user-log_ .
    v-RVD-params = entry(6, bf_c-user-log.head-table-key, chr(6)) .
    v-RVD-on = logical(entry(7, bf_c-user-log.head-table-key, chr(6))) .
    v-RVD-temp = logical(entry(11, bf_c-user-log.head-table-key, chr(6))) .
    v-RVD-dens = logical(entry(12, bf_c-user-log.head-table-key, chr(6))) .
    v-RVD-level = logical(entry(13, bf_c-user-log.head-table-key, chr(6))) .
    if num-entries(bf_c-user-log.head-table-key, chr(6)) > 13
    then
      v-is-meas = logical(entry(14, bf_c-user-log.head-table-key, chr(6))) .
    create tt-report .
    assign
      tt-report.obj-type    = v-obj-type
      tt-report.obj-code    = v-obj-code
      tt-report.pl-code     = v-pl-code
      tt-report.gds-code    = buf_pl-gds.gds-code
      tt-report.rvd-reason  = buf_ext-classif.CharKey_Two
      tt-report.corr-date   = bf_c-user-log.corr-date
      tt-report.corr-time   = bf_c-user-log.corr-time
      tt-report.corr-dt     = string(bf_c-user-log.corr-date, "99.99.9999") + " " + string(bf_c-user-log.corr-time, "hh:mm")
      tt-report.corr-dt     = replace(tt-report.corr-dt, ":", "-")
      tt-report.shift-num   = string(v-shift-num)
      tt-report.ITSM-num    = entry(9, bf_c-user-log.head-table-key, chr(6))
      tt-report.initiator   = entry(10, bf_c-user-log.head-table-key, chr(6))
      tt-report.temp-state  = if v-RVD-temp then "Р" else "А"
      tt-report.dens-state  = if v-RVD-dens then "Р" else "А"
      tt-report.level-state = if v-RVD-level then "Р" else "А"
    .
    for first buf_user-account no-lock where buf_user-account.user-id = bf_c-user-log.corr-user-name :
      assign tt-report.executor = buf_user-account.nik .
    end .
    for first buf_clients no-lock where buf_clients.obj-type = v-obj-type
                                    and buf_clients.obj-code = v-obj-code
                                    :
      assign
        v-host-code = buf_clients.host-code
        tt-report.obj-name = buf_clients.obj-name
        tt-report.host-code = v-host-code
      .
    end .
    for first buf_clients no-lock where buf_clients.obj-type = 'орг':U
                                    and buf_clients.obj-code = v-host-code
                                    :
      assign tt-report.firm-name = buf_clients.obj-name .
    end .
    for first buf_place no-lock where buf_place.obj-type = v-obj-type
                                  and buf_place.obj-code = v-obj-code
                                  and buf_place.pl-code  = v-pl-code
                                  :
      assign
        tt-report.pl-name = buf_place.pl-name
        tt-report.loc1    = buf_place.loc1
      .
    end .
    for first buf_goods no-lock where buf_goods.gds-code = tt-report.gds-code :
      assign tt-report.gds-name = buf_goods.gds-name .
    end .
    if can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р" else "А" .
    end .
    else
    if can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and not can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Температура, Плотность)" else "А(Температура, Плотность)" .
    end .
    else
    if can-do(v-RVD-params, 'p')
    and not can-do(v-RVD-params, 'T')
    and not can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Плотность)" else "А(Плотность)" .
    end .
    else
    if can-do(v-RVD-params, 'p')
    and not can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Уровень, Плотность)" else "А(Уровень, Плотность)" .
    end .
    else
    if not can-do(v-RVD-params, 'p')
    and not can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Уровень)" else "А(Уровень)" .
    end .
    else
    if not can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Уровень, Температура)" else "А(Уровень, Температура)" .
    end .
    else
    if not can-do(v-RVD-params, 'p')
    and can-do(v-RVD-params, 'T')
    and not can-do(v-RVD-params, 'l')
    then do :
      assign tt-report.corr-par = if v-RVD-on then "Р(Температура)" else "А(Температура)" .
    end .
    if (v-RVD-dens
    and v-RVD-level
    and v-RVD-temp)
    or
    (not v-is-meas)
    then do :
      assign tt-report.pl-state = "Р" .
    end .
    else
    if not v-RVD-dens
    and not v-RVD-level
    and not v-RVD-temp
    then do :
      assign tt-report.pl-state = "А" .
    end .
    else
    if v-RVD-dens
    and v-RVD-level
    and not v-RVD-temp
    then do :
      assign tt-report.pl-state = "ПА(Уровень, Плотность)" .
    end .
    else
    if v-RVD-dens
    and not v-RVD-level
    and v-RVD-temp
    then do :
      assign tt-report.pl-state = "ПА(Температура, Плотность)" .
    end .
    else
    if not v-RVD-dens
    and v-RVD-level
    and v-RVD-temp
    then do :
      assign tt-report.pl-state = "ПА(Уровень, Температура)" .
    end .
    else
    if v-RVD-dens
    and not v-RVD-level
    and not v-RVD-temp
    then do :
      assign tt-report.pl-state = "ПА(Плотность)" .
    end .
    else
    if not v-RVD-dens
    and v-RVD-level
    and not v-RVD-temp
    then do :
      assign tt-report.pl-state = "ПА(Уровень)" .
    end .
    else
    if not v-RVD-dens
    and not v-RVD-level
    and v-RVD-temp
    then do :
      assign tt-report.pl-state = "ПА(Температура)" .
    end .
    if num-entries(bf_c-user-log.head-table-key, chr(6)) = 23
    and entry(15, bf_c-user-log.head-table-key, chr(6)) > ""
    then do :
      assign tt-report.corr-period = "0" .
    end .
    else do :
      v-found-next = false .
      v-date1 = bf_c-user-log.corr-date .
      v-time1 = bf_c-user-log.corr-time .
      find-next_ :
      for each buf_c-user-log no-lock where buf_c-user-log.head-table = 'rvd-reasons':U
                                        and (buf_c-user-log.corr-date > bf_c-user-log.corr-date
                                          or (buf_c-user-log.corr-date = bf_c-user-log.corr-date
                                          and buf_c-user-log.corr-time > bf_c-user-log.corr-time))
                                          break by buf_c-user-log.corr-date by buf_c-user-log.corr-time
                                          :
        if num-entries(buf_c-user-log.head-table-key, chr(6)) = 23
        and entry(15, buf_c-user-log.head-table-key, chr(6)) > ""
        then next find-next_ .
        if v-obj-type = entry(1, buf_c-user-log.head-table-key, chr(6))
        and v-obj-code = integer(entry(2, buf_c-user-log.head-table-key, chr(6)))
        and v-pl-code = integer(entry(5, buf_c-user-log.head-table-key, chr(6)))
        then do :
          v-date2 = buf_c-user-log.corr-date .
          v-time2 = buf_c-user-log.corr-time .
          v-found-next = true .
          leave find-next_ .
        end .
      end .
      if not v-found-next
      then do :
        v-date2 = today .
        v-time2 = time .
      end .
      v-date-diff = v-date2 - v-date1 .
      v-time-diff = v-time2 - v-time1 .
      if v-time-diff < 0
      then do :
        v-date-diff = v-date-diff - 1 .
        v-time-diff = v-time-diff + 86400 .
      end .
      assign tt-report.corr-period = string(v-date-diff) + "д. " + string(v-time-diff, "hh:mm:ss") .
    end .
  end .
end procedure .
procedure print-rep :
  run gbl/getrpnum.p (output g#report-num).
  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).
  run create-file(v-file-name-rep-htm).
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
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 90px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 85px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 65px; border: none;"></td>' skip
      '<td style="width: 60px; border: none;"></td>' skip
      '<td style="width: 75px; border: none;"></td>' skip
      '<td style="width: 80px; border: none;"></td>' skip
      '<td style="width: 70px; border: none;"></td>' skip
      '</tr>' skip
  .
  put stream OutStr-html unformatted
      '<tr>' skip
      '<td colspan="17" style="text-align: left; font-weight:bold;"></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Отчет "История изменения режима ввода данных по резервуарам"</td>' skip
      '<td colspan="11" style="text-align: left;;">' + v-legend1 + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Организация: ' + v-org-list + '</td>' skip
      '<td colspan="11" style="text-align: left;">' + v-legend2 + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Выбор Объекта: ' + v-azk-list + '</td>' skip
      '<td colspan="11" style="text-align: left;">' + v-legend3 + '</td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">' + v-period + '</td>' skip
      '<td colspan="11" style="text-align: left;"><br></td>' skip
      '</tr>' skip
      '<tr>' skip
      '<td colspan="6" style="text-align: left; font-weight:bold;">Дата печати: ' + string(today) + ' Время: ' + string(time, "hh:mm:ss") + '</td>' skip
      '<td colspan="11" style="text-align: left;"><br></td>' skip
      '</tr>' skip
      '</thead>' skip
  .
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">ПНПО</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Наименование объекта (АЗК/АЗС)</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Номер резервуара</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Наименование резервуара</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Наименование НП в резервуаре на момент изменения режима</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Дата/время изменения режима</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Изменяемый параметр</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Причина перевода на РВД</th>' skip
      '         <th colspan="5" style="text-align: center; font-weight:bold; background-color: silver;">Состояние резервуара после изменения режима</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Смена</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Номер заявки ITSM/Номер приказа о проведении инвентаризации</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Исполнитель заявки</th>' skip
      '         <th rowspan="2" style="text-align: center; font-weight:bold; background-color: silver;">Инициатор заявки/Сотрудник Инв. Комиссии</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Резервуар</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Длительность состояния по резервуару</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Температура</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Плотность</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Уровень</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">2</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">3</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">4</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">5</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">6</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">7</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">8</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">9</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">10</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">11</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">12</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">13</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">14</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">15</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">16</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">17</th>' skip
      '       </tr>' skip
  .
  for each tt-report break by tt-report.host-code
                           by tt-report.obj-code
                           by tt-report.pl-code
                           by tt-report.corr-date
                           by tt-report.corr-time
                           :
    put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center;">' + tt-report.firm-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.obj-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.loc1 + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.pl-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.gds-name + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.corr-dt + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.corr-par + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.rvd-reason + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.pl-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.corr-period + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.temp-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.dens-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.level-state + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.shift-num + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.ITSM-num + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.executor + '</th>' skip
      '         <th style="text-align: center;">' + tt-report.initiator + '</th>' skip
      '       </tr>' skip
    .
  end .
  put stream OutStr-html unformatted
      '     </tbody>' skip
      '   </table>' skip
      '  </body>' skip
      ' </html>' skip
      .
  output stream OutStr-html close.
  run prn-lib-reportviewer-report-name in this-procedure (
      input this-procedure
      ,input v-file-name-rep-htm
      ) no-error.
  if error-status:error then
  do:
      message return-value view-as alert-box.
      return .
  end.
end procedure .
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
PROCEDURE write-to-log :
define input param p-str as char no-undo.
do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.
end.
END PROCEDURE.
