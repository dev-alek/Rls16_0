block-level on error undo, throw.
def input parameter x-base-type  like ub.currency.curr-abbr no-undo.
def input parameter x-base-code  like ub.currency.curr-code no-undo.
def input-output  parameter c-nn             as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-artic        as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-b-code       as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-gds-name     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-qnty         as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-cost-sum     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-sale-sum     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-sale-other   as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-crsa-sum     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-qnty-all     as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-cost-sum-all as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-sale-sum-all as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-crsa-sum-all as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-qnty-o       as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-cost-sum-o   as WIDGET-HANDLE no-undo .
def input-output  parameter c-f-crsa-sum-o   as WIDGET-HANDLE no-undo .
define input parameter   tPrintRubl    as log no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared variable gdsgrp_recids      as character no-undo.
define   shared variable fin-schet-recid    as character no-undo.
define   shared variable v-d-report-handle  as handle    no-undo .
define   shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define   shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define   shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define   shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  .
 end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable sym1  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym2  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym3  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym4  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym5  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym6  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym7  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym8  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym9  as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym10 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym11 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym12 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym13 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym14 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym15 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym16 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym17 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym18 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym19 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym20 as character no-undo format "x(1)":U initial ":":U column-label ":!:".
define variable sym21 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym22 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym23 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym24 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym25 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym26 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable sym27 as character no-undo format "x(1)":u initial ":":u column-label ":!:".
define variable temp1 as integer   no-undo.
define variable div# as char no-undo.
define variable fr as logical no-undo .
define variable fr0 as logical no-undo .
define variable tmp#stroka as character no-undo .
define variable tmp#stroka0 as character no-undo .
define variable v-bar-code    like ub.bar-code.b-code no-undo  .
define variable s-bar-code   as character format "x(9)" no-undo .
define temp-table tmp-gds no-undo
  field id as integer
  field name      as character  format "x(256)"
  field f-name    as character  format "x(256)"
  field node-code as integer
  field lvl       as integer
 index pi id
.
define variable NEW-vat        like ub.doc-line.vat-pc    no-undo.
define variable LAST-vat       like ub.doc-line.vat-pc    no-undo.
define variable  var-vat-pc    like ub.doc-line.vat-pc    no-undo.
define variable g-ll as integer no-undo .
define variable id as integer no-undo .
define temp-table temp-gds-list no-undo
  field gds-code  like ub.goods.gds-code
  field prod-code like ub.goods.prod-code
  field grp-name  like ub.goods.grp-name
  field gds-name  like ub.goods.gds-name
  field artic     like ub.goods.artic
  field vat-pc    as decimal
   index pi is primary unique gds-code ascending
   index i1 artic     ascending
   index i2 prod-code ascending
   index i3 grp-name  ascending
   index i33 gds-name  ascending
   index i4 vat-pc    ascending
   index i5 prod-code grp-name   ascending
   index i6 grp-name  prod-code   ascending
   .
define variable sum_1     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable sum_2     as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b1-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable b2-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bi-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_1  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
define variable bo-sum_2  as   decimal  format "->>>>>>>>>>>9.<<<" no-undo.
def  stream  OutStream .
define shared  variable l-col-type   as character no-undo .
define shared  variable l-col-pos    as integer no-undo .
define shared  variable l-row-pos    as integer no-undo init 1.
define shared  variable l-col-len    as integer no-undo .
define shared  variable l-col-format as character no-undo .
define shared  variable l-col-lable  as character no-undo .
define shared variable t-1 as character initial "||||"
     view-as editor
     size 1 by 6 no-undo.
DEFINE shared FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") ) AT 110 format "X(16)" SKIP
     WITH 300 DOWN stream-io
         NO-UNDERLINE use-text NO-BOX no-label
         AT COL 1 ROW 1
         SIZE 300 BY 35  .
DEFINE shared FRAME zapas
   with width 300 down stream-io use-text NO-BOX no-label.
  define shared variable ed1 as handle .
  define shared variable s1 as handle .
  define shared variable sf1 as handle .
  define shared variable l-1 as handle .
  define shared variable ll-1 as handle .
  define shared variable ed2 as handle .
  define shared variable s2 as handle .
  define shared variable sf2 as handle .
  define shared variable l-2 as handle .
  define shared variable ll-2 as handle .
  define shared variable ed3 as handle .
  define shared variable s3 as handle .
  define shared variable sf3 as handle .
  define shared variable l-3 as handle .
  define shared variable ll-3 as handle .
  define shared variable ed4 as handle .
  define shared variable s4 as handle .
  define shared variable sf4 as handle .
  define shared variable l-4 as handle .
  define shared variable ll-4 as handle .
  define shared variable ed5 as handle .
  define shared variable s5 as handle .
  define shared variable sf5 as handle .
  define shared variable l-5 as handle .
  define shared variable ll-5 as handle .
  define shared variable ed6 as handle .
  define shared variable s6 as handle .
  define shared variable sf6 as handle .
  define shared variable l-6 as handle .
  define shared variable ll-6 as handle .
  define shared variable ed7 as handle .
  define shared variable s7 as handle .
  define shared variable sf7 as handle .
  define shared variable l-7 as handle .
  define shared variable ll-7 as handle .
  define shared variable ed8 as handle .
  define shared variable s8 as handle .
  define shared variable sf8 as handle .
  define shared variable l-8 as handle .
  define shared variable ll-8 as handle .
  define shared variable ed9 as handle .
  define shared variable s9 as handle .
  define shared variable sf9 as handle .
  define shared variable l-9 as handle .
  define shared variable ll-9 as handle .
  define shared variable ed10 as handle .
  define shared variable s10 as handle .
  define shared variable sf10 as handle .
  define shared variable l-10 as handle .
  define shared variable ll-10 as handle .
  define shared variable ed11 as handle .
  define shared variable s11 as handle .
  define shared variable sf11 as handle .
  define shared variable l-11 as handle .
  define shared variable ll-11 as handle .
  define shared variable ed12 as handle .
  define shared variable s12 as handle .
  define shared variable sf12 as handle .
  define shared variable l-12 as handle .
  define shared variable ll-12 as handle .
  define shared variable ed13 as handle .
  define shared variable s13 as handle .
  define shared variable sf13 as handle .
  define shared variable l-13 as handle .
  define shared variable ll-13 as handle .
  define shared variable ed14 as handle .
  define shared variable s14 as handle .
  define shared variable sf14 as handle .
  define shared variable l-14 as handle .
  define shared variable ll-14 as handle .
  define shared variable ed15 as handle .
  define shared variable s15 as handle .
  define shared variable sf15 as handle .
  define shared variable l-15 as handle .
  define shared variable ll-15 as handle .
  define variable ed16 as handle .
  define variable s16 as handle .
  define variable ll-16 as handle .
  define variable ed17 as handle .
  define variable s17 as handle .
  define variable ll-17 as handle .
  define variable ed18 as handle .
  define variable s18 as handle .
  define variable ll-18 as handle .
  define variable ed19 as handle .
  define variable s19 as handle .
  define variable ll-19 as handle .
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-row-pos = 3.
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=6  l-col-format= "X(6)"         l-col-lable="N/N"                      .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[1] = true then DO:
        CREATE EDITOR LL-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-nn IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf1 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format= "X(10)"        l-col-lable="Код"                      .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[2] = true then DO:
        CREATE EDITOR LL-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-b-code IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf2 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"        l-col-lable="Артикул"                  .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[3] = true then DO:
        CREATE EDITOR LL-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-artic IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf3 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="CHARACTER" l-col-len=25 l-col-format= "X(25)"        l-col-lable="Название товара"          .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[4] = true then DO:
        CREATE EDITOR LL-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-gds-name IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf4 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество "           .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[5] = true then DO:
        CREATE EDITOR LL-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-qnty IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf5 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[6] = true then DO:
        CREATE EDITOR LL-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-cost-sum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf6 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в ценах документа" .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[7] = true then DO:
        CREATE EDITOR LL-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-sale-sum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf7 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=10 l-col-format="->>>>>>>9.<<"  l-col-lable="В т.ч. скидка"      .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[8] = true then DO:
        CREATE EDITOR LL-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-sale-other IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf8 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[9] = true then DO:
        CREATE EDITOR LL-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-crsa-sum IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf9 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество"            .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[10] = true then DO:
        CREATE EDITOR LL-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-qnty-all IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf10 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в учетных ценах"   .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[11] = true then DO:
        CREATE EDITOR LL-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-cost-sum-all IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf11 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[12] = true then DO:
        CREATE EDITOR LL-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-crsa-sum-all IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf12 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<" l-col-lable="Количество "           .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[13] = true then DO:
        CREATE EDITOR LL-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-qnty-o IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf13 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"    l-col-lable="Сумма в учетных ценах" .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[14] = true then DO:
        CREATE EDITOR LL-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-cost-sum-o IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf14 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>>>9.<<"  l-col-lable="Сумма в продажных ценах" .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[15] = true then DO:
        CREATE EDITOR LL-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-crsa-sum-o IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf15 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            ROW = 1
            Screen-value = ":"
            WIDTH-CHARS = 1
            COLUMN = l-col-pos + l-col-len
         .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End .
l-row-pos = 1.
l-col-pos = 1.
Assign l-col-type="CHARACTER"
       l-col-len= -1 +
                  (if  c-nn         <> ? then  c-nn:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-b-code   <> ? then  c-f-b-code:WIDTH-CHARS  + 1     Else 0 ) +
                  (if  c-f-artic    <> ? then  c-f-artic:WIDTH-CHARS  + 1      Else 0 ) +
                  (if  c-f-gds-name <> ? then  c-f-gds-name:WIDTH-CHARS + 1    Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Товар"                .
  if l-col-len > 0 then DO:
        CREATE EDITOR LL-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty       <> ? then  c-f-qnty:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum   <> ? then  c-f-cost-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-sum   <> ? then  c-f-sale-sum:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-sale-other <> ? then  c-f-sale-other:WIDTH-CHARS + 1  Else 0 ) +
                  (if  c-f-crsa-sum   <> ? then  c-f-crsa-sum:WIDTH-CHARS + 1    Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Оборот (выборочно)"   .
  if l-col-len > 0 then DO:
        CREATE EDITOR LL-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty-all     <> ? then  c-f-qnty-all:WIDTH-CHARS  + 1       Else 0 ) +
                  (if  c-f-cost-sum-all <> ? then  c-f-cost-sum-all:WIDTH-CHARS + 1    Else 0 ) +
                  (if  c-f-crsa-sum-all <> ? then  c-f-crsa-sum-all:WIDTH-CHARS + 1    Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Весь оборот за период".
  if l-col-len > 0 then DO:
        CREATE EDITOR LL-18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s18 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
Assign l-col-type="CHARACTER"
       l-col-len=  -1 +
                  (if  c-f-qnty-o     <> ? then  c-f-qnty-o:WIDTH-CHARS  + 1   Else 0 ) +
                  (if  c-f-cost-sum-o <> ? then  c-f-cost-sum-o:WIDTH-CHARS  + 1     Else 0 ) +
                  (if  c-f-crsa-sum-o <> ? then  c-f-crsa-sum-o:WIDTH-CHARS  + 1   Else 0 )
       l-col-format= "X(" + string(l-col-len) + ")"  l-col-lable= "Остатки"              .
  if l-col-len > 0 then DO:
        CREATE EDITOR LL-19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = fill(" ",Integer((l-col-len - LENGTH(trim(l-col-lable))) / 2))  + l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s19 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 3
        .
           End.
        l-col-pos =  l-col-pos + l-col-len + 1.
   End.
