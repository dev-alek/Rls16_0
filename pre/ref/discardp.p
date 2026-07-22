block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-frame-title as character no-undo .
define input  parameter p-pravo       as logical   no-undo .
define input  parameter p-rs-val      as character no-undo .
define input  parameter p-host-code-obj like ub.sysconf.host-code no-undo .
define input  parameter p-obj-type      like ub.clients.obj-type  no-undo .
define input  parameter p-obj-code      like ub.clients.obj-code  no-undo .
define parameter buffer X_dis-card    for ub.dis-card  .
define input  parameter p-qh as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: discardp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/discardp.p $":U .
define variable vss-description as character no-undo init "Печать из справочника ДК".
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
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
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
define new shared temp-table gds-list no-undo like ub.goods
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
define  new shared  temp-table gds-list-hist no-undo
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
new shared
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
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
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
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
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
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-d-pcnt RETURNS CHARACTER
  ( buffer loc-dis-card for ub.dis-card,
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-d-v as decimal) :
define variable v-node-code as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.
find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = loc-dis-card.type
      and buf_dis-card-type.emitent-host-code = loc-dis-card.emitent-host-code
      and buf_dis-card-type.host-code = 0
      and buf_dis-card-type.obj-type = '':U
      and buf_dis-card-type.obj-code = 0 no-error.
if available buf_dis-card-type then do:
  case p-discnt-role:
    when 'def-pcnt':U  then do:
      assign
      v-node-code = 1.
    end.
    when 'def-cash-pcnt':U then do:
      assign
      v-node-code = 2.
    end.
    when 'def-categ':U then do:
      assign
      v-node-code = 3.
    end.
  end.
  if buf_dis-card-type.d-pcnt-byshop then do:
   find first buf_dis-card-property no-lock where
             buf_dis-card-property.d-card = loc-dis-card.d-card
         and buf_dis-card-property.dtm-code = 26
         and buf_dis-card-property.host-code = parhost-code
         and buf_dis-card-property.obj-type = parobj-type
         and buf_dis-card-property.obj-code = parobj-code
         and buf_dis-card-property.node-code = v-node-code no-error.
   if available buf_dis-card-property then do:
     if p-discnt-role = 'def-categ':U then do:
       assign
       loc-d-v = buf_dis-card-property.property-value-integer.
     end.
     else do:
       assign
       loc-d-v = buf_dis-card-property.property-value-decimal.
     end.
   end.
    if loc-d-v = ? then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = loc-dis-card.d-card
            and buf_dis-card-property.dtm-code = 26
            and buf_dis-card-property.host-code = parhost-code
            and buf_dis-card-property.obj-type = ''
            and buf_dis-card-property.obj-code = 0
            and buf_dis-card-property.node-code = v-node-code no-error.
      if available buf_dis-card-property then do:
        if p-discnt-role = 'def-categ':U then do:
          assign
          loc-d-v = buf_dis-card-property.property-value-integer.
        end.
        else do:
          assign
          loc-d-v = buf_dis-card-property.property-value-decimal.
        end.
      end.
    end.
    if loc-d-v = ? then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  loc-dis-card.type
  ,input  loC-dis-card.emitent-host-code
  ,input  parhost-code
  ,input  ''
  ,input  0
  ,input  p-discnt-role
  ,output loc-d-v
  ) no-error .
    end.
    if loc-d-v = ? then do:
      case p-discnt-role:
        when 'def-categ':U then do:
          loc-d-v = loc-dis-card.category.
        end.
        when 'def-pcnt':U then do:
          loc-d-v = loc-dis-card.d-pcnt.
        end.
        when 'def-cash-pcnt':U then do:
          loc-d-v = loc-dis-card.cash-d-pcnt.
        end.
      end case.
    end.
    if p-discnt-role = 'def-categ':U then do:
      return substitute("(i) &1", string(loc-d-v, ">>>9")).
    end.
    else do:
      return substitute("(i) &1", string(loc-d-v, "->9.99%")).
    end.
  end.
end.
else do:
 return "ОШИБКА-НЕТ ТИПА".
end.
case p-discnt-role:
  when 'def-categ':U then do:
     loc-d-v = loc-dis-card.category.
     return string(loc-d-v, ">>>9").
  end.
  when 'def-pcnt':U then do:
    loc-d-v = loc-dis-card.d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
  when 'def-cash-pcnt':U then do:
    loc-d-v = loc-dis-card.cash-d-pcnt.
    return string(loc-d-v, "->9.99%").
  end.
end case.
END FUNCTION.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable num-chk as integer no-undo.
define variable gds-sum as decimal no-undo.
define variable disc-sum as decimal no-undo.
define variable netto-sum as decimal no-undo.
define variable pay-sum as decimal no-undo.
define variable credit-sum as decimal no-undo.
define variable saldo-sum as decimal no-undo.
define variable gds-sum-ch as char no-undo.
define variable disc-sum-ch as char no-undo.
define variable netto-sum-ch as char no-undo.
define variable pay-sum-ch as char no-undo.
define variable credit-sum-ch as char no-undo.
define variable pravo as logical no-undo.
define variable smart-pravo as logical no-undo .
FUNCTION get-cli-name RETURNS CHARACTER
  (  input p-cli-type as character, input p-cli-code as integer ) :
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where buf_clients.obj-type = p-cli-type
and buf_clients.obj-code = p-cli-code no-error.
if available buf_clients then return buf_clients.obj-name.
RETURN (p-cli-type + string(p-cli-code)).
END FUNCTION.
FUNCTION Get-num-chk RETURNS CHARACTER(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-card for ub.dis-card
                                     , input p-db-num as integer
                                     ):
DEFINE variable num-chk-ch as char no-undo.
define variable loc-smart-pravo as logical no-undo .
define buffer buf_dis-host for ub.dis-host.
define buffer buf_hist-nws-option for ub.hist-nws-option.
  if NOT p-pravo then do:
      assign
      num-chk = 0
      gds-sum-ch = ""
      disc-sum-ch = ""
      netto-sum-ch = ""
      pay-sum-ch = ""
      credit-sum-ch = ""
      .
      return "Нет прав".
  end.
  IF not avail buf_dis-card then do:
      assign
      num-chk = 0
      gds-sum-ch = ""
      disc-sum-ch = ""
      netto-sum-ch = ""
      pay-sum-ch = ""
      credit-sum-ch = ""
      .
      return "".
  end.
  assign
  num-chk = 0
  gds-sum = 0
  disc-sum = 0
  netto-sum = 0
  pay-sum = 0
  credit-sum = 0
  .
  if p-db-num > 0 then do:
    find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = 'dis-host':U
      and buf_hist-nws-option.host-code = buf_dis-card.emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = buf_dis-card.type
      and buf_hist-nws-option.subject-group = 'c-dc-hist':U NO-ERROR.
    if available buf_hist-nws-option
    and buf_hist-nws-option.smart-nws >= 0 then loc-smart-pravo = yes.
    if loc-smart-pravo then do:
      assign
      num-chk = ?
      gds-sum = ?
      disc-sum = ?
      netto-sum = ?
      pay-sum = ?
      credit-sum = ?
      .
      return "".
    end.
  end.
  find first buf_Dis-host no-lock where
            buf_dis-host.host-code = buf_Dis-card.emitent-host-code
        and buf_dis-host.d-card = buf_Dis-card.d-card
        and buf_Dis-host.dt-code = 0 no-error.
  if not available buf_Dis-host then return "".
  IF RS-val = 'rubl':U then do:
    assign
    num-chk = buf_dis-host.num-chk
    gds-sum = buf_dis-host.gds-tot-rubl
    disc-sum = buf_dis-host.gds-dis-rubl
    netto-sum = gds-sum - disc-sum
    pay-sum = buf_dis-host.pay-tot-rubl
    credit-sum = netto-sum - pay-sum
    saldo-sum = buf_dis-card.saldo-rubl.
  end.
  else do:
    assign
    num-chk = buf_dis-host.num-chk
    gds-sum = buf_dis-host.gds-tot-base
    disc-sum = buf_dis-host.gds-dis-base
    netto-sum = gds-sum - disc-sum
    pay-sum = buf_dis-host.pay-tot-base
    credit-sum = netto-sum - pay-sum
    saldo-sum = buf_dis-card.saldo-base.
  end.
  assign
  gds-sum-ch = string(gds-sum, "->>>,>>>,>>9.99")
  disc-sum-ch = string(disc-sum, "->>>,>>>,>>9.99")
  netto-sum-ch = string(netto-sum, "->>>,>>>,>>9.99")
  pay-sum-ch = string(pay-sum, "->>>,>>>,>>9.99")
  num-chk-ch = string(num-chk, "->>>>>>>9")
  credit-sum-ch = string(credit-sum, "->>>,>>>,>>9.99")
  .
  RETURN num-chk-ch.
END FUNCTION.
FUNCTION Get-num-chk-l RETURNS integer(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-num-chk as integer
                                     , input p-type as character
                                     , input p-emitent-host-code as integer
                                     , input p-db-num as integer
                                     ):
define buffer buf_hist-nws-option for ub.hist-nws-option.
  smart-pravo = no.
  if NOT p-pravo then do:
    return 0.
  end.
  if p-db-num > 0 then do:
    find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = 'dis-host':U
      and buf_hist-nws-option.host-code = p-emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = p-type
      and buf_hist-nws-option.subject-group = 'c-dc-hist':U NO-ERROR.
    if available buf_hist-nws-option
    and buf_hist-nws-option.smart-nws >= 0 then smart-pravo = yes.
    else smart-pravo = no.
  end.
  if smart-pravo then return ?.
  return p-num-chk.
end FUNCTION.
FUNCTION Get-gds-sum-l RETURNS decimal(
                                       input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return p-gds-tot-rubl.
  else
  return p-gds-tot-base.
end FUNCTION.
FUNCTION Get-disc-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return p-gds-dis-rubl.
  else
  return p-gds-dis-base.
end FUNCTION.
FUNCTION Get-netto-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return (p-gds-tot-rubl - p-gds-dis-rubl).
  else
  return (p-gds-tot-base - p-gds-dis-base).
end FUNCTION.
FUNCTION Get-pay-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-host for ub.dis-host):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return buf_dis-host.pay-tot-rubl.
  else
  return buf_dis-host.pay-tot-base.
end FUNCTION.
FUNCTION Get-credit-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal
                                     , input p-pay-tot-rubl as decimal
                                     , input p-pay-tot-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return (p-gds-tot-rubl - p-gds-dis-rubl - p-pay-tot-rubl).
  else
  return (p-gds-tot-base - p-gds-dis-base - p-pay-tot-base).
end FUNCTION.
FUNCTION Get-saldo-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-card for ub.dis-card):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = 'rubl':U then
  return buf_dis-card.saldo-rubl.
  else
  return buf_dis-card.saldo-base.
end FUNCTION.
define variable g#report-num as integer   no-undo .
procedure OpenForExcel :
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txl":U ) .
   if Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) + ".txt":U ) ) .
      assign
         v-excel-file = string( session:temp-directory + "rpt" + string( g#report-num ) )
         number-list = 1
      .
      if make-excel-com
      then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
         create "Excel.Application" ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            num#str#  = 0.
            v-ch#excelApplication  = ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            Make-Excel-com = false .
            Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
procedure CloseForExcel :
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".frm":U ) .
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable Line                    as char         no-undo.
define variable cli-attr                 as char         no-undo.
define variable ii                  as integer   no-undo.
define variable StartRowid as rowid  no-undo extent 18.
define variable for-type as char no-undo.
define variable for-status as char no-undo.
define variable dop-num-chk as integer no-undo.
define variable dop-gds-sum as decimal no-undo.
define variable dop-disc-sum as decimal no-undo.
define variable dop-netto-sum as decimal no-undo.
define variable dop-pay-sum as decimal no-undo.
define variable dop-credit-sum as decimal no-undo.
define variable dop-saldo-sum as decimal no-undo.
define variable for-d-pcnt as character no-undo.
define variable loc-d-pcnt like ub.dis-card.d-pcnt no-undo .
define variable cli-name like ub.clients.obj-name no-undo .
define variable v-ii as integer   no-undo .
DEFINE FRAME List
X_dis-card.d-card column-label "Карта" format "X(16)"
for-d-pcnt column-label "% скидки" format "X(11)"
X_dis-card.d-pcnt column-label "% ск-ки!на объ." format "->9.99%":u
X_dis-card.category column-label "Катег" format "9999"
cli-attr column-label "Клиент" format "X(12)"
cli-name column-label "Название (ФИО)" format "x(32)"
X_dis-card.issue-code COLUMN-LABEL "Выдал!маг-н"
X_dis-card.issue-date COLUMN-LABEL "Дата" format "99/99/9999"
X_dis-card.valid-date COLUMN-LABEL "Оконч" format "99/99/9999"
for-type column-LABEL "Тип!карты" format "X(8)"
X_dis-card.credit-card column-label "Кред" format "да/нет"
for-status column-LABEL "Ста!тус" format "X(5)"
X_dis-card.emitent-host-code COLUMn-LABEL "Код!фирмы"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") ) AT 56 format "X(15)" SKIP
Line format "x(136)" AT 1
with width 136 down use-text stream-io no-box .
DEFINE FRAME List-pravo
X_dis-card.d-card column-label "Карта" format "X(16)"
for-d-pcnt column-label "% скидки" format "X(11)"
X_dis-card.d-pcnt column-label "% ск-ки!на объ." format "->9.99%":u
X_dis-card.category column-label "Катег" format "9999"
cli-attr column-label "Клиент" format "X(12)"
cli-name column-label "Название (ФИО)" format "x(32)"
X_dis-card.issue-code COLUMN-LABEL "Выдал!маг-н"
X_dis-card.issue-date COLUMN-LABEL "Дата" format "99/99/9999"
X_dis-card.valid-date COLUMN-LABEL "Оконч" format "99/99/9999"
for-type column-LABEL "Тип!карты" format "X(6)"
X_dis-card.credit-card COLUMn-label "Кред" format "да/нет"
for-status column-LABEL "Ста!тус" format "X(5)"
X_dis-card.emitent-host-code COLUMn-LABEL "Код!фирмы"
num-chk column-label "Кол-во!чеков" format "->>>>>>>9 "
gds-sum column-label "Сумма покупок!брутто" format "->>>,>>>,>>9.99"
disc-sum column-label "Скидка" format "->>>,>>>,>>9.99"
netto-sum column-label "Сумма покупок!нетто" format "->>>,>>>,>>9.99"
credit-sum column-label "Сумма в кредит" format "->>>,>>>,>>9.99"
saldo-sum column-label "Сальдо" format "->>>,>>>,>>9.99"
HEADER
cur-time-print() AT 5 format "X(35)"
string( "Страница " + string( PAGE-NUMBER( PrnLibStream ) , ">>>>9") )  AT 56 format "X(15)" SKIP
Line format "x(231)" AT 1
with width 232 down use-text stream-io no-box .
if p-qh:num-results = 0 then do:
  message
  "Список  П У С Т !" skip
  view-as alert-box information .
  return error .
end.
if session:set-wait-state( "compiler" ) then .
Line = fill( "-" , (if p-pravo then 231 else 136 )).
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
do v-ii = 1 to p-qh:num-buffers:
 StartRowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid .
end.
DO WHILE available X_dis-card :
  p-qh:GET-prev(NO-LOCK) .
END.
p-qh:GET-next ( NO-LOCK ).
assign
ii = 0
Make-excel = yes
reportname = p-frame-title.
if p-pravo then do:
  assign
  sheetf.Excel-COlumn-Lable = "Карта" + chr(44) +
                              "% скидки"  + chr(44) +
                              "% скидки на объ-те" + chr(44) +
                              "Категория ДК" + chr(44) +
                              "Клиент" + chr(44) +
                              "Название (ФИО)" + chr(44) +
                              "Выдал маг-н" + chr(44) +
                              "Дата выдачи" + chr(44) +
                              "Дата оконч" + chr(44) +
                              "Тип карты" + chr(44) +
                              "Кредит" + chr(44) +
                              "Статус" + chr(44) +
                              "Код фирмы" + chr(44) +
                              "Кол-во чеков" + chr(44) +
                              "Сумма покупок брутто" + chr(44) +
                              "Скидка" + chr(44) +
                              "Сумма покупок нетто" + chr(44) +
                              "Сумма в кредит"  + chr(44) +
                              "Сальдо"
  sheetf.Sizes = "19,11,7,4,12,35,5,10,10,8,3,5,5,8,15,15,15,15,15"
  sheetf.colformat = "1=0;8=dd/mm/yyyy" + chr(4) + "1=@"
  .
end.
else do:
  assign
  sheetf.Excel-COlumn-Lable = "Карта" + chr(44) +
                              "% скидки"  + chr(44) +
                              "% скидки на объ-те" + chr(44) +
                              "Категория ДК" + chr(44) +
                              "Клиент" + chr(44) +
                              "Название (ФИО)" + chr(44) +
                              "Выдал маг-н" + chr(44) +
                              "Дата выдачи" + chr(44) +
                              "Дата оконч" + chr(44) +
                              "Тип карты" + chr(44) +
                              "Кредит" + chr(44) +
                              "Статус" + chr(44) +
                              "Код фирмы"
   sheetf.Sizes = "19,11,7,4,12,35,5,10,10,8,3,5,5"
   sheetf.colformat = "1=0;8=dd/mm/yyyy" + chr(4) + "1=@"
   .
end.
run get-report-num in parparentproc(output g#report-num).
RUN OpenForExcel in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input (if p-pravo then 43 else 62)
                                            ,input yes
                                            ,input no
                                            ).
if p-pravo then do:
  FORM HEADER
  Line format "X(136)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME CliBottomFramep width 160 PAGE-BOTTOM NO-LABELS no-box.
end.
else do:
  FORM HEADER
  Line format "X(231)" SKIP
  "Продолжение - на следующей странице" AT 30 SKIP
  with FRAME CliBottomFrame width 232 PAGE-BOTTOM NO-LABELS no-box.
end.
run rep/extitle.p (1).
if p-pravo then do:
  VIEW stream PrnLibStream FRAME CliBottomFramep .
end.
else do:
  VIEW stream PrnLibStream FRAME CliBottomFrame .
end.
PUT stream PrnLibStream space(20)
p-frame-title format "X(100)" SKIP(2) .
if p-pravo then do:
  FORM with frame List-pravo .
end.
else do:
  FORM with frame List .
end.
DO WHILE available X_dis-card :
  if p-pravo then
  num-chk = integer(get-num-chk(input p-rs-val, input p-pravo, buffer X_dis-card , input v-cntxt-db-num)).
  assign
  dop-num-chk = dop-num-chk + num-chk
  dop-gds-sum = dop-gds-sum + gds-sum
  dop-disc-sum = dop-disc-sum + disc-sum
  dop-netto-sum = dop-gds-sum - dop-disc-sum
  dop-pay-sum = dop-pay-sum + pay-sum
  dop-credit-sum = dop-netto-sum - dop-pay-sum
  dop-saldo-sum = dop-saldo-sum + saldo-sum
  .
  for-d-pcnt = get-d-pcnt(buffer X_dis-card
                         ,input p-host-code-obj
                         ,input p-obj-type
                         ,input p-obj-code
                         ,input 'def-pcnt':U
                         ,output loc-d-pcnt).
  if p-pravo then do:
    DISPLAY stream PrnLibStream
    X_dis-card.d-card
    for-d-pcnt
    loc-d-pcnt @ X_dis-card.d-pcnt
    X_dis-card.category
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) ) @ cli-attr
    get-cli-name(X_dis-card.cli-type,  X_dis-card.cli-code) @ cli-name
    X_dis-card.issue-code
    X_dis-card.issue-date
    X_dis-card.valid-date
    X_dis-card.type @ for-type
    X_dis-card.credit-card
    X_dis-card.status_ @ for-status
    X_dis-card.emitent-host-code
    num-chk
    gds-sum
    disc-sum
    netto-sum
    credit-sum
    saldo-sum
    with frame List-pravo .
    DOWN stream PrnLibStream
    1 with frame List-pravo .
    if Make-Excel then  put   stream ForExcel unformatted
    X_dis-card.d-card                                                        CHR(9)
    for-d-pcnt                                                               CHR(9)
    loc-d-pcnt                                                               CHR(9)
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) )          CHR(9)
    get-cli-name(X_dis-card.cli-type, X_dis-card.cli-code)                   CHR(9)
    X_dis-card.issue-code                                                    CHR(9)
    X_dis-card.issue-date                                                    CHR(9)
    X_dis-card.type                                                          CHR(9)
    X_dis-card.credit-card                                                   CHR(9)
    X_dis-card.status_                                                       CHR(9)
    X_dis-card.emitent-host-code                                             CHR(9)
    num-chk                                                                  CHR(9)
    gds-sum                                                                  CHR(9)
    disc-sum                                                                 CHR(9)
    netto-sum                                                                CHR(9)
    credit-sum                                                               CHR(9)
    saldo-sum
    skip.
  end.
  else do:
    DISPLAY  stream PrnLibStream
    X_dis-card.d-card
    for-d-pcnt
    loc-d-pcnt @ X_dis-card.d-pcnt
    X_dis-card.category
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) ) @ cli-attr
    get-cli-name(X_dis-card.cli-type, X_dis-card.cli-code)  @ cli-name
    X_dis-card.issue-code
    X_dis-card.issue-date
    X_dis-card.valid-date
    X_dis-card.type @ for-type
    X_dis-card.credit-card
    X_dis-card.status_ @ for-status
    X_dis-card.emitent-host-code
    with frame List .
    DOWN stream PrnLibStream 1
    with frame List .
    if Make-Excel then  put   stream ForExcel unformatted
    X_dis-card.d-card                                                        CHR(9)
    for-d-pcnt                                                               CHR(9)
    loc-d-pcnt                                                               CHR(9)
    X_dis-card.category                                                      CHR(9)
    ( X_dis-card.cli-type + " " +  STRING ( X_dis-card.cli-code ) )          CHR(9)
    get-cli-name(X_dis-card.cli-type, X_dis-card.cli-code)                   CHR(9)
    X_dis-card.issue-code                                                    CHR(9)
    X_dis-card.issue-date                                                    CHR(9)
    X_dis-card.type                                                          CHR(9)
    X_dis-card.credit-card                                                   CHR(9)
    X_dis-card.status_                                                       CHR(9)
    X_dis-card.emitent-host-code
    skip.
  end.
  ii =  ii + 1 .
  if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
  run waitfram-show in this-procedure ( "Просмотрено строк : " + string( ii ) ) .
  p-qh:GET-next (no-lock) .
END.
if p-pravo then do:
  UNDERLINE stream PrnLibStream
  X_dis-card.d-card
  for-d-pcnt
  X_dis-card.d-pcnt
  X_dis-card.category
  cli-attr
  cli-name
  X_dis-card.issue-code
  X_dis-card.issue-date
  X_dis-card.valid-date
  for-type
  for-status
  X_dis-card.emitent-host-code
  num-chk
  gds-sum
  disc-sum
  netto-sum
  credit-sum
  saldo-sum
  with frame List-pravo .
  DISPLAY stream PrnLibStream
  substitute("Итого &1 карт", ii) @ X_dis-card.d-card
  dop-num-chk @ num-chk
  dop-gds-sum  @ gds-sum
  dop-disc-sum @ disc-sum
  dop-netto-sum @ netto-sum
  dop-credit-sum @ credit-sum
  dop-saldo-sum @ saldo-sum
  with frame List-pravo .
  if Make-Excel then  put   stream ForExcel unformatted
  skip
  substitute("Итого &1 карт", ii)                                     CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
                                                                      CHR(9)
  dop-num-chk                                                         CHR(9)
  dop-gds-sum                                                         CHR(9)
  dop-disc-sum                                                        CHR(9)
  dop-netto-sum                                                       CHR(9)
  dop-credit-sum                                                      CHR(9)
  dop-saldo-sum
  skip.
end.
run waitfram-hide in this-procedure .
if p-pravo then do:
  PUT stream PrnLibStream Line format "X(231)" SKIP.
  HIDE stream PrnLibStream FRAME CliBottomFramep .
end.
else do:
  PUT stream PrnLibStream Line format "X(136)" SKIP.
  HIDE stream PrnLibStream FRAME CliBottomFrame .
end.
output stream PrnLibStream close .
if Make-Excel then output stream ForExcel close.
run prn-lib-prn-file in this-procedure (
                                           input parparentproc
                                          ,input (if p-pravo then 1 else 8)
                                          ).
p-qh:reposition-to-rowid( StartRowid ) no-error .
