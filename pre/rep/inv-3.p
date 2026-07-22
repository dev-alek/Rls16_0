block-level on error undo, throw.
do
on error undo, return error
:
  define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
  define input parameter rec_id             as recid.
  define input parameter rep-tipe           as character no-undo.
  define input parameter p-grp              as character no-undo.
  define input parameter print-graft        as logical          no-undo.
  define variable vss-revision    as character no-undo initial "$Revision: ea50b6f7ec06, 1082, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
  define variable vss-date        as character no-undo initial "$Date: Thu Oct 12 16:33:09 2017 +0300 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: inv-3.p $":U .
  define variable vss-archive     as character no-undo initial "$Archive: rep/inv-3.p $":U .
  define variable vss-description as character no-undo initial "Формы по инвентаризации ".
  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).
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
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-fmtcli-name          as character    no-undo.
define variable v-fmtcli-engl-name     as character    no-undo.
define variable v-fmtcli-addres        as character    no-undo.
define variable v-fmtcli-post-addres   as character    no-undo.
define variable v-fmtcli-full-addres   as character    no-undo.
define variable v-fmtcli-phone         as character    no-undo.
define variable v-fmtcli-inn           as character    no-undo.
define variable v-fmtcli-kpp           as character    no-undo.
define variable v-fmtcli-okpo          as character    no-undo.
define variable v-fmtcli-country       as character    no-undo.
define variable v-fmtcli-city          as character    no-undo.
define variable v-fmtcli-index         as character    no-undo.
define variable v-fmtcli-schet-exists  as logical      no-undo.
define variable v-fmtcli-bank-exists   as logical      no-undo.
define variable v-fmtcli-bank-r-schet  as character    no-undo.
define variable v-fmtcli-bank-c-schet  as character    no-undo.
define variable v-fmtcli-bank-bik      as character    no-undo.
define variable v-fmtcli-bank-name     as character    no-undo.
define variable v-fmtcli-bank-addres   as character    no-undo.
define variable v-fmtcli-bank-city     as character    no-undo.
procedure fmtcli-get-bank :
define input parameter p-host-code      as integer          no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-curr-code      as integer          no-undo.
    define buffer buf_fin-schet     for ub.fin-schet.
    define buffer buf_fin-bank      for ub.fin-bank.
do
for buf_fin-schet
  , buf_fin-bank
on error undo, return error
:
    assign
        v-fmtcli-schet-exists       = no
        v-fmtcli-bank-exists        = no
        v-fmtcli-bank-r-schet       = "":U
        v-fmtcli-bank-c-schet       = "":U
        v-fmtcli-bank-bik           = "":U
        v-fmtcli-bank-name          = "":U
        v-fmtcli-bank-addres        = "":U
        v-fmtcli-bank-city          = "":U
    .
    search-for-schet:
    for each buf_fin-schet no-lock
       where buf_fin-schet.host-code = p-host-code
         and buf_fin-schet.cli-type  = p-obj-type
         and buf_fin-schet.cli-code  = p-obj-code
         and buf_fin-schet.curr-code = p-curr-code
    on error undo, return error
    :
        if buf_fin-schet.status_   = 'удал':U
        then do:
        end.
        else do:
            assign
                v-fmtcli-schet-exists   = yes
                v-fmtcli-bank-r-schet   = trim( buf_fin-schet.r-schet )
                v-fmtcli-bank-c-schet   = trim( buf_fin-schet.c-schet )
            .
            find first buf_fin-bank no-lock
                 where buf_fin-bank.host-code = p-host-code
                   and buf_fin-bank.code-bank = buf_fin-schet.code-bank
            no-error.
            if available buf_fin-bank
            then do:
                assign
                    v-fmtcli-bank-exists      = yes
                    v-fmtcli-bank-bik         = trim( buf_fin-bank.bik )
                    v-fmtcli-bank-name        = trim( buf_fin-bank.bank-name )
                    v-fmtcli-bank-addres      = trim(buf_fin-bank.addres)
                    v-fmtcli-bank-city      = trim(buf_fin-bank.bank-city)
                .
            end.
            else do:
                assign
                    v-fmtcli-bank-exists    = no
                    v-fmtcli-bank-bik       = "":U
                    v-fmtcli-bank-name      = "":U
                    v-fmtcli-bank-addres    = "":U
                    v-fmtcli-bank-city      = "":U
                .
            end.
            leave search-for-schet.
        end.
    end.
end.
end procedure.
procedure fmtcli-get-client :
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
    define variable v-temp-fmtcli-address      as character     no-undo.
    define variable v-num-country-city    as integer      no-undo.
    define buffer buf_clients   for ub.clients.
    define buffer buf_firm      for ub.firm.
    define buffer buf_store     for ub.store.
    define buffer buf_shop      for ub.shop.
    define buffer buf_person    for ub.person.
do
for buf_clients
  , buf_firm
  , buf_store
  , buf_shop
  , buf_person
on error undo, return error
:
    assign
        v-fmtcli-name           = "":U
        v-fmtcli-addres         = "":U
        v-fmtcli-post-addres    = "":U
        v-fmtcli-full-addres    = "":U
        v-fmtcli-phone          = "":U
        v-fmtcli-inn            = "":U
        v-fmtcli-kpp            = "":U
        v-fmtcli-okpo           = "":U
        v-fmtcli-city           = "":U
        v-fmtcli-index          = "":U
        v-fmtcli-country        = "":U
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    assign
        v-fmtcli-name = buf_clients.obj-name
    .
    case buf_clients.obj-type:
       when 'орг':U
       then do:
            find first buf_firm no-lock
                 where buf_firm.firm-code = buf_clients.obj-code
                 no-error
            .
            if available buf_firm
            then do:
                assign
                    v-num-country-city = num-entries( buf_firm.city )
                    v-fmtcli-engl-name = buf_firm.engl-name
                .
                if v-num-country-city > 0
                then do:
                    assign
                        v-fmtcli-country    = trim( entry( 1, buf_firm.city ) )
                    .
                end.
                if v-num-country-city > 1
                then do:
                    assign
                        v-fmtcli-city       = trim( entry( 2, buf_firm.city ) )
                    .
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input IF buf_firm.ind = 0 THEN "" ELSE string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-full-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-country
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input v-fmtcli-city
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input string( buf_firm.ind )
                    , input ", ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.addres1, 1, 50 )
                    , input buf_firm.addres2
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-temp-fmtcli-address
                    , input substring( buf_firm.addres1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-temp-fmtcli-address
                ).
                assign
                    v-fmtcli-addres = v-temp-fmtcli-address
                .
                if buf_firm.addres1 <> ?
                then do:
                    run fmtcli-concatenate-strings in this-procedure (
                          input v-fmtcli-full-addres
                        , input v-fmtcli-addres
                        , input ", ":U
                        , input 0
                        , output v-fmtcli-full-addres
                    ).
                end.
                run fmtcli-concatenate-strings in this-procedure (
                      input substring( buf_firm.post-addr1, 1, 50 )
                    , input buf_firm.post-addr2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 51, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-post-addres
                    , input substring( buf_firm.post-addr1, 101, 50 )
                    , input " ":U
                    , input 50
                    , output v-fmtcli-post-addres
                ).
                assign
                    v-fmtcli-phone         = buf_firm.phone
                    v-fmtcli-inn           = buf_firm.inn
                    v-fmtcli-kpp           = buf_firm.kpp
                    v-fmtcli-okpo          = buf_firm.okpo
                    v-fmtcli-index         = string( buf_firm.ind )
                .
            end.
       end.
       when 'маг':U
       then do:
            find first buf_shop no-lock
                 where buf_shop.obj-code = buf_clients.obj-code
            .
            if available buf_shop
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_shop.addres1
                    , input buf_shop.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-post-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_shop.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'скл':U
       then do:
            find first buf_store no-lock
                 where buf_store.obj-code = buf_clients.obj-code
            .
            if available buf_store
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input buf_store.addres1
                    , input buf_store.addres2
                    , input " ":U
                    , input 50
                    , output v-fmtcli-addres
                ).
                assign
                    v-fmtcli-full-addres = v-fmtcli-addres
                    v-fmtcli-phone       = buf_store.phone
                    v-fmtcli-inn         = "":U
                    v-fmtcli-kpp         = "":U
                    v-fmtcli-okpo        = "":U
                    v-fmtcli-city        = "":U
                    v-fmtcli-index       = "":U
                .
            end.
       end.
       when 'чел':U
       then do:
            find first buf_person no-lock
                 where buf_person.psn-code = buf_clients.obj-code
            .
            if available buf_person
            then do:
                run fmtcli-concatenate-strings in this-procedure (
                      input ( if buf_person.ind = 0 or buf_person.ind = ?
                              then "":U
                              else string( buf_person.ind, "999999")
                              )
                    , input buf_person.city
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-addres = buf_person.address
                .
                run fmtcli-concatenate-strings in this-procedure (
                      input v-fmtcli-full-addres
                    , input v-fmtcli-addres
                    , input ", ":U
                    , input 0
                    , output v-fmtcli-full-addres
                ).
                assign
                    v-fmtcli-phone     = buf_person.phone1
                    v-fmtcli-inn       = buf_person.inn
                    v-fmtcli-kpp       = buf_person.kpp
                    v-fmtcli-okpo      = buf_person.okpo
                    v-fmtcli-city      = buf_person.city
                    v-fmtcli-index     = string( buf_person.ind )
                .
            end.
       end.
    end case.
end.
end procedure.
procedure fmtcli-concatenate-strings :
define input parameter p-string-1       as character        no-undo.
define input parameter p-string-2       as character        no-undo.
define input parameter p-delimiter      as character        no-undo.
define input parameter p-length         as integer          no-undo.
define output parameter p-out-string    as character        no-undo.
do
on error undo, return error
:
    assign
        p-out-string = ( if p-string-1 = ?
                         then "":U
                         else trim( p-string-1 ) )
    .
    assign
        p-out-string = p-out-string
                     + ( if p-out-string = "":U
                         or length( p-out-string ) = p-length
                         or p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else p-delimiter )
                     + ( if p-string-2 = ?
                         or trim( p-string-2 ) = "":U
                         then "":U
                         else trim( p-string-2 ) )
    .
end.
end procedure.
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-torgconf-ext-doc-type as character    no-undo.
define variable v-torgconf-outdate   as logical  init no    no-undo.
define variable v-torgconf-outnum    as logical  init no    no-undo.
define variable v-torgconf-outprim   as logical  init no    no-undo.
define variable v-torgconf-outdisc   as logical  init no    no-undo.
define variable v-torgconf-outsubs   as logical  init no    no-undo.
define variable v-torgconf-outrecv   as logical  init no    no-undo.
define variable v-torgconf-outegrp   as logical  init no    no-undo.
define variable v-torgconf-outt12    as logical  init no    no-undo.
define variable v-torgconf-outappr   as logical  init no    no-undo.
define variable v-torgconf-outrubl   as logical  init no    no-undo.
define variable v-torgconf-outhold   as logical  init no    no-undo.
define variable v-torgconf-outobj    as logical  init no    no-undo.
define variable v-torgconf-outexlst  as logical  init no    no-undo.
define variable v-torgconf-outexpas  as character  init no    no-undo.
define variable v-torgconf-outprncd  as logical  init no    no-undo.
define variable v-torgconf-outares   as logical  init no    no-undo.
define variable v-torgconf-outsend   as logical  init no    no-undo.
define variable v-torgconf-outasend  as logical  init no    no-undo.
define variable v-torgconf-outprops  as logical  init no    no-undo.
define variable v-torgconf-outogr    as character no-undo.
define variable v-torgconf-outR      as character no-undo.
define variable v-torgconf-outB      as character no-undo.
define variable v-torgconf-outC      as character no-undo.
define variable v-torgconf-outssdoc  as character init "":U no-undo.
define variable v-torgconf-self-host-code           as integer      no-undo.
define variable v-torgconf-self-host-type           as character    INITIAL 'орг':U  no-undo.
define variable v-torgconf-self-host-name           as character    no-undo.
define variable v-torgconf-self-host-engl-name           as character    no-undo.
define variable v-torgconf-self-host-addres         as character    no-undo.
define variable v-torgconf-self-host-post-addres    as character    no-undo.
define variable v-torgconf-self-host-phone          as character    no-undo.
define variable v-torgconf-self-host-inn            as character    no-undo.
define variable v-torgconf-self-host-kpp            as character    no-undo.
define variable v-torgconf-self-host-okpo           as character    no-undo.
define variable v-torgconf-self-host-egrip-date     as character    no-undo.
define variable v-torgconf-self-host-egrip-num      as character    no-undo.
define variable v-torgconf-sup-host-code            as integer      no-undo.
define variable v-torgconf-sup-host-type            as character  INITIAL 'орг':U  no-undo.
define variable v-torgconf-sup-host-name            as character    no-undo.
define variable v-torgconf-sup-host-engl-name            as character    no-undo.
define variable v-torgconf-sup-host-addres          as character    no-undo.
define variable v-torgconf-sup-host-post-addres     as character    no-undo.
define variable v-torgconf-sup-host-phone           as character    no-undo.
define variable v-torgconf-sup-host-inn             as character    no-undo.
define variable v-torgconf-sup-host-kpp             as character    no-undo.
define variable v-torgconf-sup-host-okpo            as character    no-undo.
define variable v-torgconf-sup-host-egrip-date      as character    no-undo.
define variable v-torgconf-sup-host-egrip-num       as character    no-undo.
define variable v-torgconf-temp-post-addres         as character    no-undo.
define variable v-torgconf-self-obj-type            as character    no-undo.
define variable v-torgconf-self-obj-code            as integer      no-undo.
define variable v-torgconf-self-obj-name            as character    no-undo.
define variable v-torgconf-self-obj-engl-name            as character    no-undo.
define variable v-torgconf-self-obj-addres          as character    no-undo.
define variable v-torgconf-self-obj-phone           as character    no-undo.
define variable v-torgconf-self-obj-inn             as character    no-undo.
define variable v-torgconf-self-obj-okpo            as character    no-undo.
define variable v-torgconf-sup-obj-type             as character    no-undo.
define variable v-torgconf-sup-obj-code             as integer      no-undo.
define variable v-torgconf-sup-obj-name             as character    no-undo.
define variable v-torgconf-sup-obj-engl-name             as character    no-undo.
define variable v-torgconf-sup-obj-addres           as character    no-undo.
define variable v-torgconf-sup-obj-phone            as character    no-undo.
define variable v-torgconf-sup-obj-inn              as character    no-undo.
define variable v-torgconf-sup-obj-okpo             as character    no-undo.
define variable v-torgconf-self-schet-exists        as logical      no-undo.
define variable v-torgconf-self-bank-exists         as logical      no-undo.
define variable v-torgconf-self-bank-r-schet        as character    no-undo.
define variable v-torgconf-self-bank-c-schet        as character    no-undo.
define variable v-torgconf-self-bank-bik            as character    no-undo.
define variable v-torgconf-self-bank-name           as character    no-undo.
define variable v-torgconf-self-bank-addres         as character    no-undo.
define variable v-torgconf-self-bank-city           as character    no-undo.
define variable v-torgconf-sup-schet-exists         as logical      no-undo.
define variable v-torgconf-sup-bank-exists          as logical      no-undo.
define variable v-torgconf-sup-bank-r-schet         as character    no-undo.
define variable v-torgconf-sup-bank-c-schet         as character    no-undo.
define variable v-torgconf-sup-bank-bik             as character    no-undo.
define variable v-torgconf-sup-bank-name            as character    no-undo.
define variable v-torgconf-sup-bank-addres          as character    no-undo.
define variable v-torgconf-sup-bank-city            as character    no-undo.
define variable v-torgconf-cli-type             as character    no-undo.
define variable v-torgconf-cli-code             as integer      no-undo.
define variable v-torgconf-cli-name             as character    no-undo.
define variable v-torgconf-cli-engl-name        as character    no-undo.
define variable v-torgconf-cli-addres           as character    no-undo.
define variable v-torgconf-cli-post-addres      as character    no-undo.
define variable v-torgconf-cli-phone            as character    no-undo.
define variable v-torgconf-cli-inn              as character    no-undo.
define variable v-torgconf-cli-kpp              as character    no-undo.
define variable v-torgconf-cli-okpo             as character    no-undo.
define variable v-torgconf-ship-type             as character    no-undo.
define variable v-torgconf-ship-code             as integer      no-undo.
define variable v-torgconf-ship-name             as character    no-undo.
define variable v-torgconf-ship-engl-name        as character    no-undo.
define variable v-torgconf-ship-addres           as character    no-undo.
define variable v-torgconf-ship-post-addres      as character    no-undo.
define variable v-torgconf-ship-phone            as character    no-undo.
define variable v-torgconf-ship-inn              as character    no-undo.
define variable v-torgconf-ship-kpp              as character    no-undo.
define variable v-torgconf-ship-okpo             as character    no-undo.
define variable v-torgconf-cli-schet-exists     as logical      no-undo.
define variable v-torgconf-cli-bank-exists      as logical      no-undo.
define variable v-torgconf-cli-bank-r-schet     as character    no-undo.
define variable v-torgconf-cli-bank-c-schet     as character    no-undo.
define variable v-torgconf-cli-bank-bik         as character    no-undo.
define variable v-torgconf-cli-bank-name        as character    no-undo.
define variable v-torgconf-cli-bank-addres      as character    no-undo.
define variable v-torgconf-cli-bank-city        as character    no-undo.
define variable v-torgconf-ship-schet-exists     as logical      no-undo.
define variable v-torgconf-ship-bank-exists      as logical      no-undo.
define variable v-torgconf-ship-bank-r-schet     as character    no-undo.
define variable v-torgconf-ship-bank-c-schet     as character    no-undo.
define variable v-torgconf-ship-bank-bik         as character    no-undo.
define variable v-torgconf-ship-bank-name        as character    no-undo.
define variable v-torgconf-ship-bank-addres      as character    no-undo.
define variable v-torgconf-ship-bank-city        as character    no-undo.
define variable v-torgconf-doc-code             as character    no-undo.
define variable v-torgconf-doc-date             as character    no-undo.
define variable v-torgconf-client-from          as character    no-undo.
define variable v-torgconf-organization         as character    no-undo.
define variable v-torgconf-organization-code    as character    no-undo.
define variable v-torgconf-organization-type    as character    no-undo.
define variable v-torgconf-okpo                 as character    no-undo.
define variable v-torgconf-cargo-to-name        as character    no-undo.
define variable v-torgconf-cargo-to-okpo        as character    no-undo.
define variable v-torgconf-cargo-to-addres      as character    no-undo.
define variable v-torgconf-cargo-to-value       as character    no-undo.
define variable v-torgconf-torg12-cargo-label   as character    no-undo.
define variable v-torgconf-torg12-cargo-string  as character    no-undo.
define variable v-torgconf-torg12-cargo-value   as character    no-undo.
define variable v-torgconf-torg12-cargo-okpo    as character    no-undo.
define variable v-torgconf-torg12-cargo-code    as character    no-undo.
define variable v-torgconf-torg12-cargo-type    as character    no-undo.
define variable v-torgconf-cargo-from-name      as character    no-undo.
define variable v-torgconf-cargo-from-okpo      as character    no-undo.
define variable v-torgconf-cargo-from-addres    as character    no-undo.
define variable v-torgconf-cargo-from-label     as character    no-undo.
define variable v-torgconf-cargo-from-value     as character    no-undo.
define variable v-torgconf-cargo-from-sf-value  as character    no-undo.
define variable v-torgconf-cargo-from-string    as character    no-undo.
define variable v-torgconf-supplier             as character    no-undo.
define variable v-torgconf-suppi                as character    no-undo.
define variable v-torgconf-saler                as character    no-undo.
define variable v-torgconf-sal                  as character    no-undo.
define variable v-torgconf-consignee            as character    no-undo.
define variable v-torgconf-cons                 as character    no-undo.
define variable v-torgconf-supplier-okpo        as character    no-undo.
define variable v-torgconf-saler-okpo           as character    no-undo.
define variable v-torgconf-consignee-okpo       as character    no-undo.
define variable v-torgconf-supplier-code        as character    no-undo.
define variable v-torgconf-saler-code           as character    no-undo.
define variable v-torgconf-consignee-code       as character    no-undo.
define variable v-torgconf-supplier-type        as character    no-undo.
define variable v-torgconf-saler-type           as character    no-undo.
define variable v-torgconf-consignee-type       as character    no-undo.
define variable v-torgconf-supplier-name        as character    no-undo.
define variable v-torgconf-supplier-engl-name   as character    no-undo.
define variable v-torgconf-saler-name           as character    no-undo.
define variable v-torgconf-consignee-name       as character    no-undo.
define variable v-torgconf-supplier-addr        as character    no-undo.
define variable v-torgconf-saler-addr           as character    no-undo.
define variable v-torgconf-consignee-addr       as character    no-undo.
define variable v-torgconf-supplier-inn         as character    no-undo.
define variable v-torgconf-saler-inn            as character    no-undo.
define variable v-torgconf-consignee-inn        as character    no-undo.
define variable v-torgconf-supplier-kpp         as character    no-undo.
define variable v-torgconf-saler-kpp            as character    no-undo.
define variable v-torgconf-consignee-kpp        as character    no-undo.
define variable v-torgconf-plat-rasch-doc       as character    no-undo.
define variable v-torgconf-main-boss            as character    no-undo.
define variable v-torgconf-main-buh             as character    no-undo.
define variable v-torgconf-reason               as character    no-undo.
define variable v-torgconf-sf-buyer-name        as character    no-undo.
define variable v-torgconf-sf-buyer-code        as character    no-undo.
define variable v-torgconf-sf-buyer-type        as character    no-undo.
define variable v-torgconf-sf-buyer-addr        as character    no-undo.
define variable v-torgconf-wth-cargo-to         as character    no-undo.
define variable p-torgconf-date-warrant         as date      no-undo.
define variable p-torgconf-N-warrant            as character no-undo.
define variable p-torgconf-accept-fname         as character no-undo.
define variable p-torgconf-accept-position      as character no-undo.
define variable p-torgconf-t_pass-fname         as character no-undo.
define variable p-torgconf-t_pass-position      as character no-undo.
define variable p-torgconf-nfindoc              as character no-undo.
define variable p-torgconf-ndovwho              as character no-undo.
define variable p-torgconf-ddog                 as date      no-undo.
define variable p-torgconf-ndog                 as character no-undo.
define variable v-torgconf-vdoc-code            as character no-undo.
define variable v-doc-code-attr                 as character no-undo.
define variable v-torgconf-doc-date-attr        as character no-undo.
define variable v-torgconf-vdoc-date            as character no-undo.
define variable v-torgconf-main-boss-post       as character no-undo.
define variable v-torgconf-ogr-name             as character no-undo.
define variable v-torgconf-ogr-post             as character no-undo.
define variable v-name                          as character    no-undo.
define variable v-form-name    as character    no-undo.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = 'ИЗМЕНЕНИЕ':U then "b-sel":U else "":U
               ,input v-cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE if p-mode = 'ИЗМЕНЕНИЕ':U then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.
  end.
end procedure.
  define new global shared variable g#wthcalib as handle no-undo.
procedure torgconf-read :
do
on error undo, return error
:
    define input parameter p-form-name  as character    no-undo.
    define input parameter p-host-code  as integer      no-undo.
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.
    define variable v-outdate   as character     no-undo.
    define variable v-outares   as character     no-undo.
    define variable v-outsend   as character     no-undo.
    define variable v-outasend  as character     no-undo.
    define variable v-outprops  as character     no-undo.
    define variable v-outnum    as character     no-undo.
    define variable v-outprim   as character     no-undo.
    define variable v-outdisc   as character     no-undo.
    define variable v-outsubs   as character     no-undo.
    define variable v-outrecv   as character     no-undo.
    define variable v-outegrp   as character     no-undo.
    define variable v-outt12    as character     no-undo.
    define variable v-outappr   as character     no-undo.
    define variable v-outrubl   as character     no-undo.
    define variable v-outhold   as character     no-undo.
    define variable v-outobj    as character     no-undo.
    define variable v-outexlst  as character     no-undo.
    define variable v-outprncd  as character     no-undo.
    define variable v-par-type  as character     no-undo.
    define variable v-outogr    as character     no-undo.
    define variable v-outR      as character     no-undo.
    define variable v-outB      as character     no-undo.
    define variable v-outC      as character     no-undo.
    assign
        v-torgconf-outdate  = no
        v-torgconf-outnum   = no
        v-torgconf-outprim  = no
        v-torgconf-outdisc  = no
        v-torgconf-outsubs  = no
        v-torgconf-outrecv  = no
        v-torgconf-outegrp  = no
        v-torgconf-outt12   = no
        v-torgconf-outappr  = no
        v-torgconf-outrubl  = no
        v-torgconf-outhold  = no
        v-torgconf-outobj   = no
        v-torgconf-outexlst = no
        v-torgconf-outexpas = "":U
        v-torgconf-outprncd = yes
        v-torgconf-outares  = no
        v-torgconf-outsend  = no
        v-torgconf-outasend  = no
        v-torgconf-outprops  = no
        v-form-name          = p-form-name
    .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'prt-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'outprncd':U then v-outprncd =  string(thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'outrecv':U  then v-outrecv  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outprops':U then v-outprops =  thbjattr_thbj-attr.property-value-character .
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input p-obj-type
  ,input p-obj-code
  ,input 'prt-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'outdate':U  then v-outdate  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outares':U  then v-outares  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outnum':U   then v-outnum   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outprim':U  then v-outprim  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outdisc':U  then v-outdisc  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outsubs':U  then v-outsubs  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outegrp':U  then v-outegrp  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outt12':U   then v-outt12   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outappr':U  then v-outappr  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outrubl':U  then v-outrubl  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outhold':U  then v-outhold  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outobj':U   then v-outobj   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outsend':U  then v-outsend  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outasend':U then v-outasend =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outogr':U   then v-torgconf-outogr   =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outR':U     then v-torgconf-outR     =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outB':U     then v-torgconf-outB     =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outssdoc':U then v-torgconf-outssdoc =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'outC':U     then v-torgconf-outC     =  thbjattr_thbj-attr.property-value-character .
end.
    run gbl/conf-rd.p ("outexpas", "":U, "":U, 0, "":U, "":U, "":U, no, output v-torgconf-outexpas, output v-par-type) no-error.
    if error-status :error
    then do:
        assign
            v-torgconf-outexpas = "":U
        .
    end.
    assign
        v-torgconf-outprncd = ( v-outprncd = "yes":U )
    .
    if p-form-name <> ""
    and p-form-name <> ?
    then do:
        run gbl/conf-rd.p ("outexlst" , p-host-code, p-obj-type, p-obj-code, "", "", "", no, output v-outexlst , output v-par-type) no-error.
        if error-status :error
        then do:
            assign
                v-outexlst           = ""
            .
        end.
        if lookup( p-form-name, v-outdate ) <> 0
        then do:
            assign
                v-torgconf-outdate  = yes
            .
        end.
        if lookup( p-form-name, v-outares ) <> 0
        then do:
            assign
                v-torgconf-outares  = yes
            .
        end.
        if lookup( p-form-name, v-outnum  ) <> 0
        then do:
            assign
                v-torgconf-outnum   = yes
            .
        end.
        if lookup( p-form-name, v-outprim ) <> 0
        then do:
            assign
                v-torgconf-outprim  = yes
            .
        end.
        if lookup( p-form-name, v-outdisc ) <> 0
        then do:
            assign
                v-torgconf-outdisc  = yes
            .
        end.
        if lookup( p-form-name, v-outsubs ) <> 0
        then do:
            assign
                v-torgconf-outsubs  = yes
            .
        end.
        if lookup( p-form-name, v-outrecv ) <> 0
        then do:
            assign
                v-torgconf-outrecv  = yes
            .
        end.
        if lookup( p-form-name, v-outegrp ) <> 0
        then do:
            assign
                v-torgconf-outegrp  = yes
            .
        end.
        if lookup( p-form-name, v-outt12  ) <> 0
        then do:
            assign
                v-torgconf-outt12   = yes
            .
        end.
        if lookup( p-form-name, v-outappr  ) <> 0
        then do:
            assign
                v-torgconf-outappr   = yes
            .
        end.
        if lookup( p-form-name, v-outrubl  ) <> 0
        then do:
            assign
                v-torgconf-outrubl   = yes
            .
        end.
        if lookup( p-form-name, v-outhold  ) <> 0
        then do:
            assign
                v-torgconf-outhold   = yes
            .
        end.
        if lookup( p-form-name, v-outobj   ) <> 0
        then do:
            assign
                v-torgconf-outobj    = yes
            .
        end.
        if lookup( p-form-name, v-outsend   ) <> 0
        then do:
            assign
                v-torgconf-outsend    = yes
            .
        end.
        if lookup( p-form-name, v-outasend   ) <> 0
        then do:
            assign
                v-torgconf-outasend    = yes
            .
        end.
        if lookup( p-form-name, v-outprops   ) <> 0
        then do:
            assign
                v-torgconf-outprops    = yes
            .
        end.
        if lookup( p-form-name, v-outexlst ) <> 0
        then do:
            assign
                v-torgconf-outexlst  = yes
            .
        end.
     assign
      v-name = p-form-name.
end.
end.
end procedure.
procedure torgconf-get-self-param :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-par-type     as character    no-undo.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message(1))
:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    if v-torgconf-outhold = yes
    then do:
        run torgconf-get-holdfirm-code in this-procedure (
              input p-obj-type
            , input p-obj-code
            , output v-torgconf-self-host-code
        ).
        if v-torgconf-self-host-code = 0
        then do:
            return error.
        end.
    end.
    else do:
        assign
            v-torgconf-self-host-code = v-host-code
        .
    end.
    if v-torgconf-self-host-code = 0
    then do:
        assign
            v-torgconf-self-host-name           = "":U
            v-torgconf-self-host-addres         = "":U
            v-torgconf-self-host-post-addres    = "":U
            v-torgconf-self-host-phone          = "":U
            v-torgconf-self-host-inn            = "":U
            v-torgconf-self-host-kpp            = "":U
            v-torgconf-self-host-okpo           = "":U
            v-torgconf-self-host-egrip-date     = "":U
            v-torgconf-self-host-egrip-num      = "":U
        .
    end.
    else do:
        run fmtcli-get-client in this-procedure (
              input 'орг':U
            , input v-torgconf-self-host-code
        ).
        assign
            v-torgconf-self-host-name        = v-fmtcli-name
            v-torgconf-self-host-engl-name   = v-fmtcli-engl-name
            v-torgconf-self-host-addres      = v-fmtcli-full-addres
            v-torgconf-self-host-post-addres = v-fmtcli-post-addres
            v-torgconf-self-host-phone       = v-fmtcli-phone
            v-torgconf-self-host-inn         = v-fmtcli-inn
            v-torgconf-self-host-kpp         = v-fmtcli-kpp
            v-torgconf-self-host-okpo        = v-fmtcli-okpo
        .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'egrip-date':U
            , output v-torgconf-self-host-egrip-date
            , output v-par-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'egrip-num':U
            , output v-torgconf-self-host-egrip-num
            , output v-par-type
        ).
        run fmtcli-get-bank in this-procedure (
              input v-host-code
            , input 'орг':U
            , input v-torgconf-self-host-code
            , input p-curr-code
        ).
    end.
    assign
        v-torgconf-self-schet-exists = v-fmtcli-schet-exists
        v-torgconf-self-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-self-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-self-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-self-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-self-bank-name    = v-fmtcli-bank-name
        v-torgconf-self-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-self-bank-city    = v-fmtcli-bank-city
    .
    assign
        v-torgconf-self-obj-type = p-obj-type
        v-torgconf-self-obj-code = p-obj-code
    .
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-self-obj-name       = v-fmtcli-name
        v-torgconf-self-obj-engl-name  = v-fmtcli-engl-name
        v-torgconf-self-obj-addres     = v-fmtcli-full-addres
        v-torgconf-temp-post-addres    = v-fmtcli-post-addres
        v-torgconf-self-obj-phone      = v-fmtcli-phone
        v-torgconf-self-obj-inn        = v-fmtcli-inn
        v-torgconf-self-obj-okpo       = v-fmtcli-okpo
    .
end.
end procedure.
procedure torgconf-get-recepient-param :
define input parameter torgconfdoc-code   as character                  no-undo.
define output parameter v-code-rec        as integer                    no-undo .
define output parameter v-type-rec        as character                  no-undo initial 'C':U.
define output parameter v-codefirm-rec    as integer                    no-undo .
define output parameter v-curcode-rec     as integer                    no-undo .
     define variable  v-recipient-code  as character                  no-undo .
     define variable  v-recipient       like ub.doc-attr.attr-value   no-undo.
     define variable  v-trdcattr-type   as character                  no-undo initial 'C':U.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input torgconfdoc-code ,
                        input 'Recipient':U ,
                       output v-recipient-code ,
                       output v-trdcattr-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " torgconfdoc-code skip
      "Атрибут: " 'Recipient':U skip
      "Значение: " v-recipient skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  assign
    v-recipient  = v-recipient-code
    v-type-rec = substring(v-recipient-code,1,3)
    v-code-rec  = int(substring(v-recipient-code,4,15))
    no-error
  .
  if v-type-rec = ? then v-type-rec = "" .
  if v-code-rec  = ? then v-code-rec  =  0 .
  end procedure.
procedure torgconf-get-wthrecepient-param :
define input parameter torgconfdoc-code   as character                  no-undo.
define output parameter v-code-rec        as integer                    no-undo .
define output parameter v-type-rec        as character                  no-undo initial 'C':U.
define output parameter v-codefirm-rec    as integer                    no-undo .
define output parameter v-curcode-rec     as integer                    no-undo .
     define variable  v-recipient-code  as character                  no-undo .
     define variable  v-recipient       like ub.doc-attr.attr-value   no-undo.
     define variable  v-trdcattr-type   as character                  no-undo initial 'C':U.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input torgconfdoc-code ,
                        input 'wthconsignee':U ,
                       output v-recipient-code ,
                       output v-trdcattr-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " torgconfdoc-code skip
      "Атрибут: " 'wthconsignee':U skip
      "Значение: " v-recipient skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  assign
    v-recipient  = v-recipient-code
    v-type-rec = substring(v-recipient-code,1,3)
    v-code-rec  = int(substring(v-recipient-code,4,15))
    no-error
  .
  if v-type-rec = ? then v-type-rec = "" .
  if v-code-rec  = ? then v-code-rec  =  0 .
  end procedure.
procedure torgconf-get-warrant:
define input parameter p-torgconfdoc-code           as character                  no-undo.
    define variable p-torgconf-date-type            as character no-undo.
    define variable p-torgconf-N-type               as character no-undo.
    define variable p-torgconf-accept-n-type        as character no-undo.
    define variable p-torgconf-accept-p-type        as character no-undo.
    define variable p-torgconf-nfindoc-type         as character no-undo.
    define variable p-torgconf-ndovwho-type         as character no-undo.
    define variable p-torgconf-ndog-type            as character no-undo.
    define variable p-torgconf-dfindoc-type         as date      no-undo.
    define variable p-torgconf-ddog-type            as date      no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ddov':U ,
                       output p-torgconf-date-warrant ,
                       output p-torgconf-date-type ) no-error .
     if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ddov':U skip
      "Значение: " p-torgconf-date-warrant skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ndov':U ,
                       output p-torgconf-N-warrant ,
                       output p-torgconf-N-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ndov':U skip
      "Значение: " p-torgconf-N-warrant skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_accept-fname':U ,
                       output p-torgconf-accept-fname ,
                       output p-torgconf-accept-n-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_accept-fname':U skip
      "Значение: " p-torgconf-accept-fname skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_accept-position':U ,
                       output p-torgconf-accept-position ,
                       output p-torgconf-accept-p-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_accept-position':U skip
      "Значение: " p-torgconf-accept-position skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_pass-fname':U ,
                       output p-torgconf-t_pass-fname ,
                       output p-torgconf-accept-n-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_pass-fname':U skip
      "Значение: " p-torgconf-t_pass-fname skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 't_pass-position':U ,
                       output p-torgconf-t_pass-position ,
                       output p-torgconf-accept-p-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 't_pass-position':U skip
      "Значение: " p-torgconf-t_pass-position skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-torgconfdoc-code ,
                        input 'ndovwho':U ,
                       output p-torgconf-ndovwho ,
                       output p-torgconf-ndovwho-type ) no-error .
    if error-status :error then do:
     message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры tdat-val":U skip
      "Документ: " p-torgconfdoc-code skip
      "Атрибут: " 'ndovwho':U skip
      "Значение: " p-torgconf-ndovwho skip
      trim( error-status :get-message (1) ) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value.
    end.
  end procedure.
procedure torgconf-get-warrant-wth:
define input parameter p-torgconfdoc-code           as character                  no-undo.
    define variable p-torgconf-ndovwho-type         as character no-undo.
    define variable p-torgconf-accept-n-type        as character no-undo.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-torgconfdoc-code ,
                        input 'wthproxy':U ,
                       output p-torgconf-ndovwho ,
                       output p-torgconf-ndovwho-type ) no-error .
      if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры tdat-val":U skip
         "Документ: " p-torgconfdoc-code skip
         "Атрибут: " 'wthproxy':U skip
         "Значение: " p-torgconf-ndovwho skip
         trim( error-status :get-message (1) ) skip
         return-value skip
         view-as alert-box error.
      undo, return error return-value.
      end.
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-torgconfdoc-code ,
                        input 'wthreceiver':U ,
                       output p-torgconf-accept-fname ,
                       output p-torgconf-accept-n-type ) no-error .
      if error-status :error then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры tdat-val":U skip
         "Документ: " p-torgconfdoc-code skip
         "Атрибут: " 't_accept-fname':U skip
         "Значение: " p-torgconf-accept-fname skip
         trim( error-status :get-message (1) ) skip
         return-value skip
         view-as alert-box error.
      undo, return error return-value.
      end.
  end procedure.
procedure torgconf-get-sup-param :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
    define variable v-par-type     as character    no-undo.
do
on error undo, return error
:
    assign
       v-torgconf-sup-host-code = v-host-code
    .
    if v-torgconf-sup-host-code = 0
    then do:
        assign
            v-torgconf-sup-host-name           = "":U
            v-torgconf-sup-host-addres         = "":U
            v-torgconf-sup-host-post-addres    = "":U
            v-torgconf-sup-host-phone          = "":U
            v-torgconf-sup-host-inn            = "":U
            v-torgconf-sup-host-kpp            = "":U
            v-torgconf-sup-host-okpo           = "":U
            v-torgconf-sup-host-egrip-date     = "":U
            v-torgconf-sup-host-egrip-num      = "":U
        .
    end.
    else do:
        run fmtcli-get-client in this-procedure (
              input 'орг':U
            , input v-torgconf-sup-host-code
        ).
        assign
            v-torgconf-sup-host-name        = v-fmtcli-name
            v-torgconf-sup-host-engl-name   = v-fmtcli-engl-name
            v-torgconf-sup-host-addres      = v-fmtcli-full-addres
            v-torgconf-sup-host-post-addres = v-fmtcli-post-addres
            v-torgconf-sup-host-phone       = v-fmtcli-phone
            v-torgconf-sup-host-inn         = v-fmtcli-inn
            v-torgconf-sup-host-kpp         = v-fmtcli-kpp
            v-torgconf-sup-host-okpo        = v-fmtcli-okpo
        .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-sup-host-code
            , input 'egrip-date':U
            , output v-torgconf-sup-host-egrip-date
            , output v-par-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-sup-host-code
            , input 'egrip-num':U
            , output v-torgconf-sup-host-egrip-num
            , output v-par-type
        ).
        run fmtcli-get-bank in this-procedure (
              input v-host-code
            , input 'орг':U
            , input v-torgconf-sup-host-code
            , input p-curr-code
        ).
    end.
    assign
        v-torgconf-sup-schet-exists = v-fmtcli-schet-exists
        v-torgconf-sup-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-sup-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-sup-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-sup-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-sup-bank-name    = v-fmtcli-bank-name
        v-torgconf-sup-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-sup-bank-city    = v-fmtcli-bank-city
    .
    assign
        v-torgconf-sup-obj-type = p-obj-type
        v-torgconf-sup-obj-code = p-obj-code
    .
    if trim(p-obj-type) <> ""
    and p-obj-code <> 0
    then do:
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-sup-obj-name        = v-fmtcli-name
        v-torgconf-sup-obj-engl-name   = v-fmtcli-engl-name
        v-torgconf-sup-obj-addres      = v-fmtcli-full-addres
        v-torgconf-temp-post-addres    = v-fmtcli-post-addres
        v-torgconf-sup-obj-phone       = v-fmtcli-phone
        v-torgconf-sup-obj-inn         = v-fmtcli-inn
        v-torgconf-sup-obj-okpo        = v-fmtcli-okpo
    .
   end.
   end.
end procedure.
procedure torgconf-get-cli-param :
define input parameter p-host-obj-code      as integer          no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-torgconf-cli-type = p-obj-type
        v-torgconf-cli-code = p-obj-code
    .
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-cli-name         = trim( v-fmtcli-name          )
        v-torgconf-cli-engl-name    = trim( v-fmtcli-engl-name          )
        v-torgconf-cli-addres       = trim( v-fmtcli-full-addres   )
        v-torgconf-cli-post-addres  = trim( v-fmtcli-post-addres   )
        v-torgconf-cli-phone        = trim( v-fmtcli-phone         )
        v-torgconf-cli-inn          = trim( v-fmtcli-inn           )
        v-torgconf-cli-kpp          = trim( v-fmtcli-kpp           )
        v-torgconf-cli-okpo         = trim( v-fmtcli-okpo          )
    .
   run fmtcli-get-bank in this-procedure (
          input p-host-obj-code
        , input p-obj-type
        , input p-obj-code
        , input p-curr-code
    ).
    assign
        v-torgconf-cli-schet-exists = v-fmtcli-schet-exists
        v-torgconf-cli-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-cli-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-cli-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-cli-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-cli-bank-name    = v-fmtcli-bank-name
        v-torgconf-cli-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-cli-bank-city    = v-fmtcli-bank-city
    .
end.
end procedure.
procedure torgconf-get-ship-param :
define input parameter p-host-obj-code      as integer          no-undo.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-curr-code          as integer          no-undo.
    define variable v-host-code    as integer      no-undo.
do
on error undo, return error
:
    assign
        v-torgconf-ship-type = p-obj-type
        v-torgconf-ship-code = p-obj-code
    .
    if trim(p-obj-type) = ""
    and p-obj-code = 0
    then do:
    assign
        v-torgconf-ship-name         = "":U
        v-torgconf-ship-addres       = "":U
        v-torgconf-ship-post-addres  = "":U
        v-torgconf-ship-phone        = "":U
        v-torgconf-ship-inn          = "":U
        v-torgconf-ship-kpp          = "":U
        v-torgconf-ship-okpo         = "":U
    .
    end.
    else do:
    run fmtcli-get-client in this-procedure (
          input p-obj-type
        , input p-obj-code
    ).
    assign
        v-torgconf-ship-name         = trim( v-fmtcli-name          )
        v-torgconf-ship-engl-name    = trim( v-fmtcli-engl-name          )
        v-torgconf-ship-addres       = trim( v-fmtcli-full-addres   )
        v-torgconf-ship-post-addres  = trim( v-fmtcli-post-addres   )
        v-torgconf-ship-phone        = trim( v-fmtcli-phone         )
        v-torgconf-ship-inn          = trim( v-fmtcli-inn           )
        v-torgconf-ship-kpp          = trim( v-fmtcli-kpp           )
        v-torgconf-ship-okpo         = trim( v-fmtcli-okpo          )
    .
    end.
        run fmtcli-get-bank in this-procedure (
          input p-host-obj-code
        , input p-obj-type
        , input p-obj-code
        , input p-curr-code
    ).
    assign
        v-torgconf-ship-schet-exists = v-fmtcli-schet-exists
        v-torgconf-ship-bank-exists  = v-fmtcli-bank-exists
        v-torgconf-ship-bank-r-schet = v-fmtcli-bank-r-schet
        v-torgconf-ship-bank-c-schet = v-fmtcli-bank-c-schet
        v-torgconf-ship-bank-bik     = v-fmtcli-bank-bik
        v-torgconf-ship-bank-name    = v-fmtcli-bank-name
        v-torgconf-ship-bank-addres  = v-fmtcli-bank-addres
        v-torgconf-ship-bank-city    = v-fmtcli-bank-city
    .
end.
end procedure.
procedure torgconf-get-holdfirm-code :
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define output parameter p-firm-code as integer          no-undo.
    define variable v-firm-code-str     as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define buffer buf_clients       for ub.clients.
do
for buf_clients
on error undo, return error
:
    run gbl/clntat-v.p (
          input p-obj-type
        , input p-obj-code
        , input 'holdfirm-code':U
        , output v-firm-code-str
        , output v-par-type
    ).
    assign
        p-firm-code = integer( v-firm-code-str )
    no-error.
    if error-status :error
    then do:
        message
            "Неверно задан код фирмы для печати накладных."
        view-as alert-box warning.
        assign
            p-firm-code = 0
        .
    end.
    else do:
        find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = p-firm-code
        no-error.
        if not available buf_clients
        then do:
            message
                "Включен параметр 'Список печатных форм, для которых должна быть задана фирма для печати накладных' (outhold)" skip
                "Не найдена фирма по заданному коду фирмы для печати накладных."
            view-as alert-box warning.
            assign
                p-firm-code = 0
            .
        end.
    end.
end.
end procedure.
procedure torgconf-get-post-head:
define input  parameter p-obj-type             as character        no-undo.
define input  parameter p-obj-code             as integer          no-undo.
define output parameter p-torgconf-post-head   as character        no-undo.
   define variable v-host-code         as integer      no-undo.
   define buffer buf_sysconf     for ub.sysconf.
     assign
      p-torgconf-post-head  = ""
     .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
   find first buf_sysconf no-lock
   where buf_sysconf.host-code = v-host-code
   no-error.
   if available buf_sysconf
   then do:
      assign
         p-torgconf-post-head = buf_sysconf.head-position
      .
   end.
end procedure.
procedure torgconf-get-storekeeper:
define input  parameter p-wrkr                   as integer          no-undo.
define output parameter p-torgconf-wrkr-name     as character        no-undo.
define output parameter p-torgconf-post          as character        no-undo.
   define buffer buf_sysconf     for ub.sysconf.
   define buffer buf_person      for ub.person.
   define buffer buf_shop        for ub.shop .
   define buffer buf_store       for ub.store .
   if v-torgconf-outC = "no_print"
   then do:
      assign p-torgconf-post = ""
             p-torgconf-wrkr-name = ""
             .
   end.
   if v-torgconf-outC = "clad_doc"
   then do:
      run rep/get-psn.p
            (input  p-wrkr
            ,output p-torgconf-wrkr-name
            ) .
      find first buf_person no-lock
      where buf_person.psn-code = p-wrkr
      no-error.
      if available buf_person
      then do:
        p-torgconf-post = buf_person.position.
      end.
      if p-torgconf-post = "?":U then p-torgconf-post = "".
      if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
   end.
   if v-torgconf-outC = "clad_obj"
   then do:
      CASE v-torgconf-self-obj-type:
      WHEN 'маг':U
      THEN DO:
         find first buf_shop no-lock
         where buf_shop.obj-code = v-torgconf-self-obj-code
         .
         assign
            p-torgconf-wrkr-name = buf_shop.store-man
            p-torgconf-post = ""
         .
         if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
      END.
      WHEN 'скл':U
      THEN DO:
         find first buf_store no-lock
         where buf_store.obj-code = v-torgconf-self-obj-code
         .
         assign
            p-torgconf-wrkr-name = buf_store.store-man
            p-torgconf-post = ""
         .
         if p-torgconf-wrkr-name = "?":U then p-torgconf-wrkr-name = "".
      END.
      OTHERWISE DO:
         assign
            p-torgconf-post = "":U
            p-torgconf-wrkr-name = "":U
         .
      END.
      END CASE.
   end.
 end procedure.
procedure torgconf-get-form-header :
define input parameter p-for-inverse    as logical          no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-print-doc      as logical          no-undo.
define input parameter p-doc-date       as date             no-undo.
define input parameter p-fact-date      as date             no-undo.
define input parameter p-doc-type       as character        no-undo.
define input parameter p-status_        as character        no-undo.
define input parameter p-reverse        as logical          no-undo.
define input parameter p-sf-par         as logical          no-undo.
    define variable v-attr-type         as character    no-undo.
    define variable v-doc-code-standard as logical      no-undo.
    define variable v-doc-date-standard as logical      no-undo.
    define variable v-par-consignee-addres  as character    no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-dcode-attr        as character    no-undo.
    define variable v-ddate-attr        as character    no-undo.
    define variable v-doc-date          as character    no-undo.
    define variable v-doc-code          as character    no-undo.
    define variable v-par-type          as character    no-undo.
    define variable v-attr              as character    no-undo.
    define buffer buf_firm          for ub.firm .
    define buffer buf_clients       for ub.clients .
    define buffer buf_sysconf       for ub.sysconf .
    define buffer buf_shop          for ub.shop .
    define buffer buf_store         for ub.store .
    define buffer buf_person        for ub.person .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_wth-doc       for ub.wth-doc .
    do
for buf_firm
  , buf_clients
  , buf_sysconf
  , buf_shop
  , buf_trn-doc
  , buf_person
  , buf_wth-doc
on error undo, return error
:
    if p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    then do:
        assign
            v-torgconf-supplier         = substitute( "&1&2&3&4&5", v-torgconf-cli-name, ( if v-torgconf-cli-addres = "":U then "":U else ", " ),
                                          v-torgconf-cli-addres, ( if v-torgconf-cli-phone = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-suppi            = substitute( "&1&2&3&4&5", v-torgconf-cli-name, ( if v-torgconf-cli-addres = "":U then "":U else ", " ),
                                          v-torgconf-cli-addres, ( if v-torgconf-cli-phone = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-saler            = substitute( "&1&2&3&4&5", v-torgconf-self-host-name, ( if v-torgconf-self-host-addres = "":U then "":U else ", " ),
                                          v-torgconf-self-host-addres, ( if v-torgconf-self-host-phone = "":U then "":U else ", " ),v-torgconf-self-host-phone )
            v-torgconf-consignee        = substitute( "&1&2&3&4&5", v-torgconf-sup-host-name, ( if v-torgconf-sup-host-addres = "":U then "":U else ", " ),
                                          v-torgconf-sup-host-addres, ( if v-torgconf-sup-host-phone = "":U then "":U else ", " ), v-torgconf-sup-host-phone  )
            v-torgconf-supplier-okpo    = v-torgconf-cli-okpo
            v-torgconf-saler-okpo       = v-torgconf-self-host-okpo
            v-torgconf-consignee-okpo   = v-torgconf-sup-host-okpo
            v-torgconf-supplier-code    = substitute( "&1", v-torgconf-cli-code         )
            v-torgconf-supplier-type    = v-torgconf-cli-type
            v-torgconf-saler-code       = substitute( "&1", v-torgconf-self-host-code   )
            v-torgconf-saler-type       = v-torgconf-self-host-type
            v-torgconf-consignee-code   = substitute( "&1", v-torgconf-sup-host-code   )
            v-torgconf-consignee-type   = v-torgconf-sup-host-type
            v-torgconf-supplier-name    = substitute( "&1", v-torgconf-cli-name         )
            v-torgconf-saler-name       = substitute( "&1", v-torgconf-self-host-name   )
            v-torgconf-consignee-name   = substitute( "&1", v-torgconf-sup-host-name   )
            v-torgconf-supplier-addr    = substitute( "&1", v-torgconf-cli-addres       )
            v-torgconf-saler-addr       = substitute( "&1", v-torgconf-self-host-addres )
            v-torgconf-consignee-addr   = substitute( "&1", v-torgconf-sup-host-addres )
            v-torgconf-supplier-inn     = substitute( "&1", v-torgconf-cli-inn          )
            v-torgconf-supplier-engl-name     = substitute( "&1", v-torgconf-cli-engl-name          )
            v-torgconf-saler-inn        = substitute( "&1", v-torgconf-self-host-inn    )
            v-torgconf-consignee-inn    = substitute( "&1", v-torgconf-sup-host-inn    )
            v-torgconf-supplier-kpp     = substitute( "&1", v-torgconf-cli-kpp          )
            v-torgconf-saler-kpp        = substitute( "&1", v-torgconf-self-host-kpp    )
            v-torgconf-consignee-kpp    = substitute( "&1", v-torgconf-sup-host-kpp    )
        .
        if v-torgconf-cli-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-supplier = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
                v-torgconf-suppi = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
            .
            if v-torgconf-cli-bank-exists = yes
            then do:
                assign
                    v-torgconf-supplier = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    ,(if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                   v-torgconf-suppi = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    ,(if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                .
            end.
        end.
        if v-torgconf-self-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-saler = v-torgconf-saler
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-self-bank-r-schet
                                , v-torgconf-self-bank-c-schet
                                )
            .
            if v-torgconf-self-bank-exists = yes
            then do:
                assign
                    v-torgconf-saler = v-torgconf-saler
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-self-bank-bik
                                    , v-torgconf-self-bank-name
                                    , v-torgconf-self-bank-addres
                                    )
                .
            end.
        end.
        if v-torgconf-sup-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-consignee = v-torgconf-consignee
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-sup-bank-r-schet
                                , v-torgconf-sup-bank-c-schet
                                )
            .
          if v-torgconf-sup-bank-exists = yes
           then do:
             assign
                v-torgconf-consignee = v-torgconf-consignee
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-sup-bank-bik
                                    , v-torgconf-sup-bank-name
                                    , v-torgconf-sup-bank-addres
                                    )
                .
            end.
        end.
   if v-torgconf-outares = yes  AND v-form-name  = "torg12":U
   then do:
       assign
         v-torgconf-supplier = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                                , v-torgconf-cli-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-cli-code )
                                                      else "":U )
                                                , v-torgconf-cli-post-addres
                                                , v-torgconf-cli-phone
                                                , ( if v-torgconf-cli-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-cli-bank-r-schet
                                                            , v-torgconf-cli-bank-c-schet
                                                            , v-torgconf-cli-bank-bik
                                                            , v-torgconf-cli-bank-name
                                                            , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
    v-torgconf-suppi = substitute(  "&1&2&3 &4 &5&6"
                                     , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                     , v-torgconf-cli-name
                                     , ( if v-torgconf-outprncd = yes
                                         then substitute( " (&1)", v-torgconf-cli-code )
                                         else "":U )
                                     , v-torgconf-cli-addres
                                     , v-torgconf-cli-phone
                                     , ( if v-torgconf-cli-bank-r-schet <> "":U
                                         AND v-form-name                  = "torg12":U
                                         then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-cli-bank-r-schet
                                                        , v-torgconf-cli-bank-c-schet
                                                        , v-torgconf-cli-bank-bik
                                                        , v-torgconf-cli-bank-name
                                                        , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) ))
                                                else "":U )
                                     ).
    end.
    else do:
    v-torgconf-suppi = substitute(  "&1&2&3 &4 &5&6"
                                     , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                     , v-torgconf-self-host-name
                                     , ( if v-torgconf-outprncd = yes
                                         then substitute( " (&1)", v-torgconf-self-host-code )
                                         else "":U )
                                     , v-torgconf-self-host-addres
                                     , v-torgconf-self-host-phone
                                     , ( if v-torgconf-self-bank-r-schet <> "":U
                                         AND v-form-name                  = "torg12":U
                                         then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        ).
      if v-torgconf-outares = yes
      and p-reverse = no
      then do:
         assign
            v-par-consignee-addres = v-torgconf-ship-post-addres
         .
      end.
      if v-torgconf-outares = no
      and p-reverse = no
      then do:
         assign
            v-par-consignee-addres = v-torgconf-ship-addres
         .
      end.
      if p-reverse = yes
      then do:
          assign
            v-par-consignee-addres = v-torgconf-ship-addres
          .
      end.
        assign
            v-torgconf-supplier         = substitute( "&1&2&3&4&5", v-torgconf-self-host-name, ( if v-torgconf-self-host-addres = "":U then "":U else ", " ), v-torgconf-self-host-addres,
                                          ( if v-torgconf-self-host-phone = "":U then "":U else ", " ), v-torgconf-self-host-phone )
            v-torgconf-saler            = substitute( "&1&2&3&4&5", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres,
                                          ( if v-torgconf-cli-phone       = "":U then "":U else ", " ), v-torgconf-cli-phone )
            v-torgconf-consignee        = substitute( "&1&2&3&4&5", v-torgconf-ship-name      , ( if v-par-consignee-addres   = "":U then "":U else ", " ), v-par-consignee-addres,
                                           ( if v-torgconf-ship-phone   = "":U then "":U else ", " ), v-torgconf-ship-phone)
            v-torgconf-supplier-okpo    = v-torgconf-self-host-okpo
            v-torgconf-saler-okpo       = v-torgconf-cli-okpo
            v-torgconf-consignee-okpo   = v-torgconf-ship-okpo
            v-torgconf-supplier-code    = substitute( "&1", v-torgconf-self-host-code   )
            v-torgconf-supplier-code    = v-torgconf-self-host-type
            v-torgconf-saler-code       = substitute( "&1", v-torgconf-cli-code         )
            v-torgconf-saler-type       = v-torgconf-cli-type
            v-torgconf-consignee-code   = substitute( "&1", v-torgconf-ship-code         )
            v-torgconf-consignee-type   = v-torgconf-ship-type
            v-torgconf-supplier-name    = substitute( "&1", v-torgconf-self-host-name   )
            v-torgconf-saler-name       = substitute( "&1", v-torgconf-cli-name         )
            v-torgconf-consignee-name   = substitute( "&1", v-torgconf-ship-name         )
            v-torgconf-supplier-addr    = substitute( "&1", v-torgconf-self-host-addres )
            v-torgconf-saler-addr       = substitute( "&1", v-torgconf-cli-addres       )
            v-torgconf-consignee-addr   = substitute( "&1", v-par-consignee-addres                )
            v-torgconf-supplier-inn     = substitute( "&1", v-torgconf-self-host-inn    )
            v-torgconf-supplier-engl-name     = substitute( "&1", v-torgconf-self-host-engl-name    )
            v-torgconf-saler-inn        = substitute( "&1", v-torgconf-cli-inn          )
            v-torgconf-consignee-inn    = substitute( "&1", v-torgconf-ship-inn          )
            v-torgconf-supplier-kpp     = substitute( "&1", v-torgconf-self-host-kpp    )
            v-torgconf-saler-kpp        = substitute( "&1", v-torgconf-cli-kpp          )
            v-torgconf-consignee-kpp    = substitute( "&1", v-torgconf-ship-kpp          )
            v-torgconf-sf-buyer-name    = v-torgconf-consignee-name
            v-torgconf-sf-buyer-code    = v-torgconf-consignee-code
            v-torgconf-sf-buyer-type    = v-torgconf-consignee-type
            v-torgconf-sf-buyer-addr    = v-torgconf-consignee-addr
        .
        if v-torgconf-self-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-supplier = v-torgconf-supplier
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-self-bank-r-schet
                                , v-torgconf-self-bank-c-schet
                                )
            .
            if v-torgconf-self-bank-exists = yes
            then do:
                assign
                    v-torgconf-supplier = v-torgconf-supplier
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-self-bank-bik
                                    , v-torgconf-self-bank-name
                                    , v-torgconf-self-bank-addres
                                    )
                .
            end.
        end.
        if v-torgconf-cli-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-saler = v-torgconf-saler
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-cli-bank-r-schet
                                , v-torgconf-cli-bank-c-schet
                                )
            .
            if v-torgconf-cli-bank-exists = yes
            then do:
                assign
                    v-torgconf-saler = v-torgconf-saler
                        + substitute( " БИК &1 в &2 &3"
                                    , v-torgconf-cli-bank-bik
                                    , v-torgconf-cli-bank-name
                                    , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                    )
                .
            end.
        end.
        if v-torgconf-ship-schet-exists = yes
        AND v-form-name                  = "torg12":U
        then do:
            assign
                v-torgconf-consignee = v-torgconf-consignee
                    + substitute( ", р/с &1 к/с &2"
                                , v-torgconf-ship-bank-r-schet
                                , v-torgconf-ship-bank-c-schet
                                )
            .
            if v-torgconf-ship-bank-exists = yes
            then do:
                assign
                    v-torgconf-consignee = v-torgconf-consignee
                        + substitute( " БИК &1 в &2  &3"
                                    , v-torgconf-ship-bank-bik
                                    , v-torgconf-ship-bank-name
                                    , (if v-torgconf-ship-bank-city = "":U then "":U else ( "г. " + v-torgconf-ship-bank-city) )
                                    )
                .
            end.
        end.
   if p-reverse = yes
      then do:
       if  v-torgconf-outares = yes then v-torgconf-saler = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-post-addres       = "":U then "":U else ", " ), v-torgconf-cli-post-addres       )
         .
       else v-torgconf-saler = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres       ) .
              if v-torgconf-cli-schet-exists = yes
              AND v-form-name                  = "torg12":U
                  then do:
                        assign
                           v-torgconf-saler = v-torgconf-saler
                              + substitute( ", р/с &1 к/с &2"
                                          , v-torgconf-cli-bank-r-schet
                                          , v-torgconf-cli-bank-c-schet
                                          )
            .
            if v-torgconf-cli-bank-exists = yes
            AND v-form-name                  = "torg12":U
               then do:
                  assign
                     v-torgconf-saler = v-torgconf-saler
                           + substitute( " БИК &1 в &2  &3"
                                       , v-torgconf-cli-bank-bik
                                       , v-torgconf-cli-bank-name
                                       , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                       )
                  .
            end.
        end.
        v-torgconf-saler-name = v-torgconf-cli-name .
        v-torgconf-saler-okpo = v-torgconf-cli-okpo.
   end.
    if trim(v-torgconf-consignee) = ""
    and v-torgconf-outares = yes
    and p-reverse = no
    then do:
      assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-post-addres       = "":U then "":U else ", " ), v-torgconf-cli-post-addres)
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
    if trim(v-torgconf-consignee) = ""
    and v-torgconf-outares = no
    and p-reverse = no
    then do:
    assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres)
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
    if trim(v-torgconf-consignee) = ""
    and    p-reverse = yes
    then do:
      assign
      v-torgconf-consignee = substitute( "&1&2&3", v-torgconf-cli-name      , ( if v-torgconf-cli-addres       = "":U then "":U else ", " ), v-torgconf-cli-addres)
      v-torgconf-sf-buyer-name    = v-torgconf-cli-name
      v-torgconf-sf-buyer-code    = string(v-torgconf-cli-code)
      v-torgconf-sf-buyer-type    = v-torgconf-cli-type
      v-torgconf-sf-buyer-addr    = v-torgconf-cli-addres
      .
         if v-torgconf-cli-schet-exists = yes
         AND v-form-name                  = "torg12":U
            then do:
                  assign
                     v-torgconf-consignee = v-torgconf-consignee
                        + substitute( ", р/с &1 к/с &2"
                                    , v-torgconf-cli-bank-r-schet
                                    , v-torgconf-cli-bank-c-schet
                                    )
                  .
                  if v-torgconf-cli-bank-exists = yes
                  then do:
                     assign
                        v-torgconf-consignee = v-torgconf-consignee
                              + substitute( " БИК &1 в &2 &3"
                                          , v-torgconf-cli-bank-bik
                                          , v-torgconf-cli-bank-name
                                          , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )
                                          )
                     .
                  end.
            end.
    end.
   end.
    if p-for-inverse = yes
    or p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    then do:
        assign
            v-torgconf-cargo-from-name      = v-torgconf-cli-name
            v-torgconf-cargo-from-okpo      = v-torgconf-cli-okpo
            v-torgconf-cargo-from-addres    = v-torgconf-cli-addres
            v-torgconf-cargo-to-name        = v-torgconf-self-host-name
            v-torgconf-cargo-to-okpo        = v-torgconf-self-host-okpo
            v-torgconf-cargo-to-addres      = v-torgconf-self-host-post-addres
        .
        if v-torgconf-outares then v-torgconf-cargo-from-addres    = v-torgconf-cli-post-addres  .
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'cargo-to':U
            , output v-torgconf-cargo-to-value
            , output v-attr-type
        ).
        run gbl/clntat-v.p (
              input v-torgconf-cli-type
            , input v-torgconf-cli-code
            , input 'cargo-from':U
            , output v-torgconf-cargo-from-value
            , output v-attr-type
        ).
        assign
            v-torgconf-cargo-from-sf-value = v-torgconf-cargo-from-value
        .
        if v-torgconf-cargo-to-value = "":U
        then do:
            if v-torgconf-ext-doc-type = 'pz':U
            OR v-torgconf-outobj = TRUE
            then do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-obj-addres
                                                    , v-torgconf-self-obj-phone
                                                    )
                .
            end.
            else if v-torgconf-outasend = yes then do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-host-post-addres
                                                    , v-torgconf-self-host-phone
                                                    )
                .
            end.
            else do:
                assign
                    v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                    then substitute( " (&1)", v-torgconf-self-host-code )
                                                    else "":U )
                                                    , v-torgconf-self-host-addres
                                                    , v-torgconf-self-host-phone
                                                    )
                .
            end.
        end.
        if v-torgconf-cargo-from-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-value = substitute( "&1&2 &3 &4"
                                                , v-torgconf-cli-name
                                                , ( if v-torgconf-outprncd = yes
                                                  then substitute( " (&1)", v-torgconf-cli-code )
                                                  else "":U )
                                                , v-torgconf-cargo-from-addres
                                                , v-torgconf-cli-phone
                                                )
            .
        end.
        if v-torgconf-cargo-from-sf-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-sf-value  = v-torgconf-cargo-from-name
                                                    + "  ":U
                                                    + v-torgconf-cargo-from-addres
            .
        end.
    end.
    else do:
        if v-torgconf-outsend then do:
        assign
            v-torgconf-cargo-from-name      = v-torgconf-self-obj-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-obj-addres
        .
        end.
        else if v-torgconf-outobj then assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-obj-addres
        .
        else if v-torgconf-outasend then assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-host-post-addres
        .
        else  assign
            v-torgconf-cargo-from-name      = v-torgconf-self-host-name
            v-torgconf-cargo-from-addres    = v-torgconf-self-host-addres
        .
        assign
            v-torgconf-cargo-from-okpo      = v-torgconf-self-host-okpo
            v-torgconf-cargo-to-name        = v-torgconf-cli-name
            v-torgconf-cargo-to-okpo        = v-torgconf-cli-okpo
            v-torgconf-cargo-to-addres      = v-torgconf-cli-post-addres
        .
        run gbl/clntat-v.p (
              input v-torgconf-cli-type
            , input v-torgconf-cli-code
            , input 'cargo-to':U
            , output v-torgconf-cargo-to-value
            , output v-attr-type
        ).
        run gbl/clntat-v.p (
              input 'орг':U
            , input v-torgconf-self-host-code
            , input 'cargo-from':U
            , output v-torgconf-cargo-from-value
            , output v-attr-type
        ).
        assign
            v-torgconf-cargo-from-sf-value = v-torgconf-cargo-from-value
        .
        if v-torgconf-cargo-to-value = "":U
        then do:
            assign
                v-torgconf-cargo-to-value   = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-cli-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-cli-code )
                                                      else "":U )
                                                    , v-torgconf-cli-post-addres
                                                    , v-torgconf-cli-phone
                                                    )
            .
        end.
        if v-torgconf-cargo-from-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-value = substitute( "&1&2 &3 &4"
                                                    , v-torgconf-self-host-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                    , v-torgconf-self-host-post-addres
                                                    , v-torgconf-self-host-phone
                                                    )
            .
        end.
        if v-torgconf-cargo-from-sf-value = "":U
        then do:
            assign
                v-torgconf-cargo-from-sf-value  = v-torgconf-cargo-from-name
                                                    + "  ":U
                                                    +  v-torgconf-cargo-from-addres
            .
        end.
    end.
    if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
    then do:
        assign
            v-torgconf-wth-cargo-to = "":U
        .
        run gbl/wthat-v.p (
              input p-doc-code
            , input 'wthconsignee':U
            , output v-torgconf-wth-cargo-to
            , output v-attr-type
        ).
        assign
            v-torgconf-wth-cargo-to = trim( v-torgconf-wth-cargo-to )
        .
        if v-torgconf-wth-cargo-to <> "":U
        then do:
            run fmtcli-get-client in this-procedure (
                  input substring( v-torgconf-wth-cargo-to, 1, 3  )
                , input integer( trim( substring( v-torgconf-wth-cargo-to, 4 ) ) )
            ).
            assign
                v-torgconf-cargo-to-value = substitute( "&1&2 &3 &4"
                                                    , v-fmtcli-name
                                                    , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", trim( substring( v-torgconf-wth-cargo-to, 4 ) ) )
                                                      else "":U )
                                                    , v-fmtcli-full-addres
                                                    , v-fmtcli-phone
                                                    )
            .
        end.
    end.
    if ( p-doc-type = 'при':U
    or p-doc-type = 'возврат':U )
    then do:
      if v-torgconf-outares = yes
      THEN DO:
         assign
            v-torgconf-torg12-cargo-value   = v-torgconf-supplier
            v-torgconf-torg12-cargo-code    = v-torgconf-supplier-code
            v-torgconf-torg12-cargo-type    = v-torgconf-supplier-type
            v-torgconf-torg12-cargo-type    = v-torgconf-supplier-okpo
         .
      END.
      ELSE DO:
         case v-form-name:
         WHEN "torg12":U
         THEN DO:
            assign
               v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                            , v-torgconf-supplier
                                                            , v-torgconf-supplier-inn
                                                            , v-torgconf-supplier-kpp
                                                            )
               v-torgconf-torg12-cargo-code    = v-torgconf-supplier-code
               v-torgconf-torg12-cargo-type    = v-torgconf-supplier-type
            .
         END.
         END CASE.
      END.
    end.
    else do:
      IF v-form-name = "torg12":U
      THEN DO:
         assign
            v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                         , v-torgconf-consignee
                                                         , v-torgconf-consignee-inn
                                                         , v-torgconf-consignee-kpp
                                                         )
            v-torgconf-torg12-cargo-code    = v-torgconf-consignee-code
            v-torgconf-torg12-cargo-type    = v-torgconf-consignee-type
            v-torgconf-torg12-cargo-okpo    = v-torgconf-consignee-okpo
         .
      END.
      ELSE DO:
         assign
            v-torgconf-torg12-cargo-value   = v-torgconf-consignee
            v-torgconf-torg12-cargo-code    = v-torgconf-consignee-code
            v-torgconf-torg12-cargo-type    = v-torgconf-consignee-type
         .
      END.
    end.
   assign
         v-torgconf-cons = v-torgconf-consignee
         v-torgconf-sal  = v-torgconf-saler
   .
   if p-reverse = yes
      then do:
              assign                v-torgconf-torg12-cargo-value   = SUBSTITUTE( "&1 ИНН &2 КПП &3"
                                                         , v-torgconf-saler
                                                         , v-torgconf-saler-inn
                                                         , v-torgconf-saler-kpp
                                                         )
            v-torgconf-torg12-cargo-code    = v-torgconf-saler-code
            v-torgconf-torg12-cargo-type    = v-torgconf-saler-type
            v-torgconf-torg12-cargo-okpo    = v-torgconf-saler-okpo
            v-torgconf-saler      = v-torgconf-cons
            v-torgconf-consignee  = v-torgconf-sal
            v-torgconf-saler-name = v-torgconf-sf-buyer-name
            v-torgconf-saler-code = v-torgconf-sf-buyer-code
            v-torgconf-saler-type = v-torgconf-sf-buyer-type
            v-torgconf-saler-addr = v-torgconf-sf-buyer-addr
            v-torgconf-saler-okpo = v-torgconf-consignee-okpo
            v-torgconf-saler-inn = v-torgconf-consignee-inn
            v-torgconf-saler-kpp = v-torgconf-consignee-kpp
      .
      end.
   if ( p-doc-type = 'при':U
   or p-doc-type = 'возврат':U )
   and not p-for-inverse
   and v-torgconf-ext-doc-type <> 're':U
   and v-torgconf-ext-doc-type <> 'pz':U
      then do:
         assign
            v-torgconf-torg12-cargo-label   = "Грузоотправитель"
            v-torgconf-torg12-cargo-okpo    = v-torgconf-cargo-from-okpo
            v-torgconf-torg12-cargo-string  = v-torgconf-torg12-cargo-label + ": ":U + v-torgconf-torg12-cargo-value
         .
      end.
      else do:
         assign
            v-torgconf-torg12-cargo-label   = "Грузополучатель"
            v-torgconf-torg12-cargo-string  = v-torgconf-torg12-cargo-label + ": ":U + v-torgconf-torg12-cargo-value
         .
      end.
    if v-torgconf-ext-doc-type = 're':U
    or v-torgconf-ext-doc-type = 'pz':U
    then do:
      assign
         v-torgconf-organization = v-torgconf-supplier
         v-torgconf-organization-code = v-torgconf-supplier-code
         v-torgconf-organization-type = v-torgconf-supplier-type
      .
    end.
    else do:
        if p-for-inverse = yes
        then do:
            assign
                v-torgconf-organization-code = substitute( "&1", v-torgconf-cli-code)
                v-torgconf-organization-type = v-torgconf-cli-type
                v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-cli-inn, v-torgconf-cli-kpp) ELSE "":U
                                            , v-torgconf-cli-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-cli-code )
                                                else "":U )
                                            , v-torgconf-cli-addres
                                            , v-torgconf-cli-phone
                                            , ( if v-torgconf-cli-bank-r-schet <> "":U
                                              AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-cli-bank-r-schet
                                                        , v-torgconf-cli-bank-c-schet
                                                        , v-torgconf-cli-bank-bik
                                                        , v-torgconf-cli-bank-name
                                                        , (if v-torgconf-cli-bank-city = "":U then "":U else ( "г. " + v-torgconf-cli-bank-city) )     )
                                                else "":U )
                                        )
                v-torgconf-okpo         = v-torgconf-cli-okpo
            .
        end.
        else do:
            assign
                v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
                v-torgconf-organization-type = v-torgconf-self-host-type
                v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-host-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-host-addres
                                            , v-torgconf-self-host-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
                v-torgconf-okpo         = v-torgconf-self-host-okpo
            .
        end.
    end.
    assign
        v-torgconf-client-from = ( if p-doc-type = 'при':U
                                   or v-torgconf-ext-doc-type = 're':U
                                   or v-torgconf-ext-doc-type = 'pz':U
                                   then " ":U
                                   else substitute( "&1&2"
                                            , v-torgconf-self-obj-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-obj-code  )
                                                else "":U ) ) )
    .
if   v-torgconf-outsend = no
and (  p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    )
and (  v-torgconf-ext-doc-type <> 're':U
    or v-torgconf-ext-doc-type <> 'pz':U
    )
then do:
   if v-torgconf-outobj = yes
   then do:
       assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-obj-addres
                                                , v-torgconf-self-obj-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                  AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
   else do:
      if v-torgconf-outasend = no
      then do:
      assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
      end.
      else do:
      assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-post-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
      end.
   end.
end.
if  v-torgconf-outsend = yes
and (  p-doc-type = 'при':U
    or p-doc-type = 'возврат':U
    )
and ( v-torgconf-ext-doc-type <> 're':U
    or v-torgconf-ext-doc-type <> 'pz':U
    )
then do:
      assign
      v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
      v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                             , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                             , v-torgconf-self-obj-name
                                             , ( if v-torgconf-outprncd = yes
                                                   then substitute( " (&1)", v-torgconf-self-obj-code )
                                                   else "":U )
                                             , v-torgconf-self-obj-addres
                                             , v-torgconf-self-obj-phone
                                             , ( if v-torgconf-self-bank-r-schet <> "":U
                                                   AND v-form-name                  = "torg12":U
                                                   then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                         , v-torgconf-self-bank-r-schet
                                                         , v-torgconf-self-bank-c-schet
                                                         , v-torgconf-self-bank-bik
                                                         , v-torgconf-self-bank-name
                                                         , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                   else "":U )
                                          )
      .
end.
   if( p-doc-type <> 'при':U
   or  p-doc-type <> 'возврат':U )
   and v-torgconf-outsend  = no
   and v-torgconf-outasend = yes
   and v-torgconf-outobj   = no
   then do:
       assign
         v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
         v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                                , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                                , v-torgconf-self-host-name
                                                , ( if v-torgconf-outprncd = yes
                                                      then substitute( " (&1)", v-torgconf-self-host-code )
                                                      else "":U )
                                                , v-torgconf-self-host-post-addres
                                                , v-torgconf-self-host-phone
                                                , ( if v-torgconf-self-bank-r-schet <> "":U
                                                    AND v-form-name                  = "torg12":U
                                                      then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                            , v-torgconf-self-bank-r-schet
                                                            , v-torgconf-self-bank-c-schet
                                                            , v-torgconf-self-bank-bik
                                                            , v-torgconf-self-bank-name
                                                            , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                      else "":U )
                                             )
      .
   end.
   if ( not ( ( p-doc-type = 'при':U
             or p-doc-type = 'возврат':U )
               ))
    and v-torgconf-outsend = yes
    then do:
      assign
          v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
          v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-obj-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-obj-addres
                                            , v-torgconf-self-obj-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
          v-torgconf-client-from = ""
      .
    end.
    if ( not ( ( p-doc-type = 'при':U
             or p-doc-type = 'возврат':U )
     ))
    and v-torgconf-outsend = no
    and v-torgconf-outobj  = yes
    then do:
        assign
          v-torgconf-organization-code = substitute( "&1", v-torgconf-self-host-code)
          v-torgconf-organization = substitute(  "&1&2&3 &4 &5&6"
                                            , IF v-form-name = "torg12":U THEN SUBSTITUTE("ИНН &1 КПП &2 ", v-torgconf-self-host-inn, v-torgconf-self-host-kpp) ELSE "":U
                                            , v-torgconf-self-host-name
                                            , ( if v-torgconf-outprncd = yes
                                                then substitute( " (&1)", v-torgconf-self-host-code )
                                                else "":U )
                                            , v-torgconf-self-obj-addres
                                            , v-torgconf-self-obj-phone
                                            , ( if v-torgconf-self-bank-r-schet <> "":U
                                                AND v-form-name                  = "torg12":U
                                                then substitute( ", р/с &1 к/с &2, БИК &3 в &4, &5"
                                                        , v-torgconf-self-bank-r-schet
                                                        , v-torgconf-self-bank-c-schet
                                                        , v-torgconf-self-bank-bik
                                                        , v-torgconf-self-bank-name
                                                        , (if v-torgconf-self-bank-city = "":U then "":U else ( "г. " + v-torgconf-self-bank-city) )     )
                                                else "":U )
                                        )
        .
    end.
    if v-torgconf-outnum = yes
    then do:
        assign
            v-torgconf-doc-code = "          "
        .
    end.
    else do:
        if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
        then do:
            run gbl/wthat-v.p (
                  input p-doc-code
                , input 'wthnsf':U
                , output v-torgconf-doc-code
                , output v-attr-type
            ).
            assign
                v-doc-code-standard = ( trim( v-torgconf-doc-code ) = "":U )
            .
        end.
        else do:
            assign
                v-doc-code-standard = yes
            .
        end.
        if v-doc-code-standard = yes
        then do:
            run gbl/trdcat-v.p (
                input p-doc-code
                , input 'print-num':U
                , output v-torgconf-doc-code
                , output v-attr-type
            ).
            if v-torgconf-doc-code = "":U
            then do:
                if p-for-inverse = yes
                then do:
                    if p-doc-type = 'при':U
                    then do:
                        assign
                            v-torgconf-doc-code = entry( 1, p-doc-code, "=":U )
                        no-error.
                    end.
                    else do:
                        assign
                            v-torgconf-doc-code = entry( 1, p-doc-code, "-":U )
                        no-error.
                    end.
                    define variable v-doc-code-integer    as integer      no-undo.
                    assign
                        v-doc-code-integer = integer( v-torgconf-doc-code )
                    no-error.
                    if error-status :error
                    then do:
                        assign
                            v-doc-code-integer = 0
                        .
                    end.
                    if v-torgconf-doc-code = ""
                    then do:
                        assign v-torgconf-doc-code = substr( p-doc-code, 1, 2 )
                                            + string( month( p-doc-date ),  "99" )
                                            + string( day( p-doc-date ),    "99" )
                        .
                    end.
                    else do:
                        assign v-torgconf-doc-code = string( month( p-doc-date ), ">9" )
                                            + trim( string( day( p-doc-date ), ">9" ) )
                                            + string( v-doc-code-integer )
                        .
                    end.
                end.
                else do:
                    assign
                        v-torgconf-doc-code = p-doc-code
                    .
                end.
            end.
        end.
    end.
    if v-torgconf-outnum = yes
    then do:
        assign
            v-torgconf-vdoc-code = " "
        .
    end.
    else do:
      assign
         v-torgconf-vdoc-code = p-doc-code
      .
      if p-doc-type = 'при':U
      then do:
         run gbl/trdcat-v.p (
                    input p-doc-code
                  , input 'nids':U
                  , output v-doc-code-attr
                  , output v-attr-type
               ).
      end.
      if  p-doc-type =  'рас':U
      or  p-doc-type =  'возврат':U
      then do:
         run gbl/trdcat-v.p (
                    input p-doc-code
                  , input 'print-num':U
                  , output v-doc-code-attr
                  , output v-attr-type
               ).
      end.
      if trim(v-doc-code-attr) <> ""
      then do:
         assign
            v-torgconf-vdoc-code = v-doc-code-attr
         .
      end.
    end.
    if v-torgconf-outdate = yes
    then do:
        assign
         v-torgconf-doc-date =  "          "
         v-torgconf-vdoc-date = "          "
        .
    end.
    else do:
        if lookup( v-torgconf-ext-doc-type, 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u ) <> 0
        then do:
            run gbl/wthat-v.p (
                  input p-doc-code
                , input 'wthdsf':U
                , output v-torgconf-doc-date
                , output v-attr-type
            ).
            assign
                v-doc-date-standard = ( trim( v-torgconf-doc-date ) = "":U )
            .
        end.
        else do:
            assign
                v-doc-date-standard = yes
            .
        end.
        if v-doc-date-standard = yes
        then do:
            assign v-torgconf-doc-date =  ( if p-status_ <> 'факт':U
                                            or p-print-doc = yes
                                            then string( p-doc-date, "99/99/9999" )
                                            else string( p-fact-date, "99/99/9999" )
                                        )
            .
        end.
        assign v-torgconf-vdoc-date = ( if p-status_ <> 'факт':U
                                          then string( p-doc-date, "99/99/9999" )
                                          else string( p-fact-date, "99/99/9999" )
                                      )
        .
        if p-doc-type = 'при':U
           then do:
              run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'dids':U
                , output v-torgconf-doc-date-attr
                , output v-attr-type
             ).
           end.
        if trim(v-torgconf-doc-date-attr) <> ""
        then do:
            assign v-torgconf-vdoc-date = v-torgconf-doc-date-attr
            .
        end.
    end.
   if  v-name <> 'wthtrg12'
   and v-name <> 'wthfct'
   and v-name <> 'wthm11'
   then do:
    run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'NFinDoc':U
                , output v-dcode-attr
                , output v-par-type
            ) no-error.
    if error-status :error
    then do:
        assign v-dcode-attr = "".
    end.
    run gbl/trdcat-v.p (
                  input p-doc-code
                , input 'DFinDoc':U
                , output v-ddate-attr
                , output v-par-type
            ) no-error.
    if error-status :error
    then do:
        assign v-ddate-attr = "".
    end.
   end.
   else do:
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-doc-code ,
                        input 'wthpaydoc':U ,
                       output v-attr ,
                       output v-attr-type )  .
   end.
    case v-torgconf-outssdoc
    :
     when "nacl":U
     then do:
         if  v-name <> 'wthtrg12'
         and v-name <> 'wthfct'
         and v-name <> 'wthm11'
         then do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2 &3"
                                                , if trim(v-dcode-attr) = "" then v-torgconf-doc-code else v-dcode-attr
                                                , if trim(v-ddate-attr) = "" then v-torgconf-doc-date else v-ddate-attr
                                                , ( if p-status_ <> 'факт':U
                                                   then string( "(" + caps( p-status_ ) + ")" )
                                                   else "":U )
                                             )
            .
         end.
         else do:
         if trim(v-attr) = ""
         then do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2 &3",
                                                        v-torgconf-doc-code,
                                                        v-torgconf-doc-date,
                                                         ( if p-status_ <> 'факт':U then string( "(" + caps( p-status_ ) + ")" ) else "":U )
                                                        )
            .
         end.
         else do:
            assign
               v-torgconf-plat-rasch-doc = v-attr.
         end.
         end.
     end.
     otherwise do:
         if  v-name <> 'wthtrg12'
         and v-name <> 'wthfct'
         and v-name <> 'wthm11'
         then do:
            IF v-dcode-attr <> "":U
            OR v-ddate-attr <> "":U
            THEN
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1 от &2"
                                                   , if trim(v-dcode-attr) = "" then "" else v-dcode-attr
                                                   , if trim(v-ddate-attr) = "" then "" else v-ddate-attr
                                                )
            .
         end.
         else do:
            assign
               v-torgconf-plat-rasch-doc   = substitute( "&1", if trim(v-attr) = "" then "" else v-attr)
            .
         end.
     end.
    end case.
   if v-torgconf-outB = "no_print"
   then do:
      assign v-torgconf-main-buh = "".
   end.
   if v-torgconf-outB = "glbuh_firm"
   then do:
         if v-torgconf-self-host-code = 0
         then do:
         end.
         else do:
            find first buf_sysconf no-lock
               where buf_sysconf.host-code = v-torgconf-self-host-code
            .
            assign
               v-torgconf-main-buh  = buf_sysconf.snr-accnt
            .
         end.
   end.
   if v-torgconf-outB = "buh_obj"
   then do:
      CASE v-torgconf-self-obj-type:
      WHEN 'маг':U
      THEN DO:
         find first buf_shop no-lock
         where buf_shop.obj-code = v-torgconf-self-obj-code
         .
         assign
            v-torgconf-main-buh  = entry(1,buf_shop.acct,"|")
         .
      END.
      WHEN 'скл':U
      THEN DO:
         find first buf_store no-lock
         where buf_store.obj-code = v-torgconf-self-obj-code
         .
         assign
            v-torgconf-main-buh  = buf_store.store-man
         .
      END.
      OTHERWISE DO:
         assign
            v-torgconf-main-buh  = "":U
         .
      END.
      END CASE.
   end.
   if v-torgconf-outR = "no_print"
      then do:
         assign
            v-torgconf-main-boss = ""
            v-torgconf-main-boss-post = ""
         .
      end.
   if v-torgconf-outR = "ruk_firm"
      then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-torgconf-self-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-main-boss-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
         and buf_clients.obj-code = v-torgconf-self-host-code
         .
         find first buf_firm no-lock
         where buf_firm.firm-code = buf_clients.obj-code
         no-error.
         if available buf_firm
         then do:
            assign
               v-torgconf-main-boss = buf_firm.director
            .
         end.
      end.
   if v-torgconf-outR = "dir_obj"
      then do:
         CASE v-torgconf-self-obj-type:
         WHEN 'маг':U
         THEN DO:
            find first buf_shop no-lock
            where buf_shop.obj-code = v-torgconf-self-obj-code
            .
            assign
               v-torgconf-main-boss = buf_shop.director
               v-torgconf-main-boss-post = "Директор"
            .
         END.
         WHEN 'скл':U
         THEN DO:
            find first buf_store no-lock
            where buf_store.obj-code = v-torgconf-self-obj-code
            .
            assign
               v-torgconf-main-boss = buf_store.store-boss
               v-torgconf-main-boss-post = "Директор"
            .
         END.
         OTHERWISE DO:
            assign
               v-torgconf-main-boss       = "":U
               v-torgconf-main-boss-post  = "":U
            .
         END.
         END CASE.
      end.
   if  v-name <> 'wthtrg12':U
   and v-name <> 'wthfct':U
   and v-name <> 'wthm11':U
   then do:
    find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if available buf_trn-doc
      then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
      end.
    if v-torgconf-outogr = "no_print"
      then do:
         assign
            v-torgconf-ogr-name = ""
            v-torgconf-ogr-post = ""
         .
      end.
   if v-torgconf-outogr  = "ruk_firm"
         then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = v-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-ogr-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = v-host-code
         .
         find first buf_firm no-lock
             where buf_firm.firm-code = buf_clients.obj-code
         .
         assign
             v-torgconf-ogr-name = buf_firm.director
         .
      end.
      if v-torgconf-outogr = "dir_obj"
         then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
            CASE buf_trn-doc.obj-type:
            WHEN 'маг':U
            THEN DO:
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            WHEN 'скл':U
            THEN DO:
               find first buf_store no-lock
               where buf_store.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_store.store-boss
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            OTHERWISE DO:
               assign
                  v-torgconf-ogr-name = "":U
                  v-torgconf-ogr-post = "":U
               .
            END.
            END CASE.
         end.
   if v-torgconf-outogr = "manag_doc"
      then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
         if available buf_trn-doc
         then do:
            run rep/get-psn.p
            (input buf_trn-doc.boss
            ,output v-torgconf-ogr-name
            ) .
         end.
         find first buf_person no-lock
         where buf_person.psn-code = buf_trn-doc.boss
         no-error.
         if available buf_person
         then do:
            v-torgconf-ogr-post = buf_person.position.
         end.
         if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
         if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
      end.
   end.
   else do:
   find first buf_wth-doc no-lock
      where buf_wth-doc.doc-code = p-doc-code
      no-error.
      if available buf_wth-doc
         then do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output v-host-code
  )  .
         end.
      if v-torgconf-outogr = "no_print"
         then do:
            assign
               v-torgconf-ogr-name = ""
               v-torgconf-ogr-post = ""
            .
         end.
      if v-torgconf-outogr  = "ruk_firm"
            then do:
            find first buf_sysconf no-lock
            where buf_sysconf.host-code = v-host-code
            no-error.
            if available buf_sysconf
            then do:
               assign
                  v-torgconf-ogr-post = buf_sysconf.head-position
               .
            end.
            find first buf_clients no-lock
               where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = v-host-code
            .
            find first buf_firm no-lock
               where buf_firm.firm-code = buf_clients.obj-code
            .
            assign
               v-torgconf-ogr-name = buf_firm.director
            .
         end.
         if v-torgconf-outogr = "dir_obj"
            then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_wth-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            end.
      if v-torgconf-outogr = "manag_doc"
         then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
            if available buf_wth-doc
            then do:
               run rep/get-psn.p
               (input buf_wth-doc.deliver
               ,output v-torgconf-ogr-name
               ) .
            end.
            find first buf_person no-lock
            where buf_person.psn-code = buf_wth-doc.deliver
            no-error.
            if available buf_person
            then do:
               v-torgconf-ogr-post = buf_person.position.
            end.
            if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
            if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
         end.
   end.
end.
end procedure.
procedure torgconf-get-outogr-param:
    define input parameter p-form-name  as character    no-undo.
    define input parameter p-host-code  as integer      no-undo.
    define input parameter p-obj-type   as character    no-undo.
    define input parameter p-obj-code   as integer      no-undo.
    define input parameter p-doc-code   as character      no-undo.
    define buffer buf_firm          for ub.firm .
    define buffer buf_clients       for ub.clients .
    define buffer buf_sysconf       for ub.sysconf .
    define buffer buf_shop          for ub.shop .
    define buffer buf_store         for ub.store .
    define buffer buf_person        for ub.person .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_wth-doc       for ub.wth-doc .
   if  p-form-name <> 'wthtrg12':U
   and p-form-name <> 'wthfct':U
   and p-form-name <> 'wthm11':U
   then do:
    find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error.
    if v-torgconf-outogr = "no_print"
      then do:
         assign
            v-torgconf-ogr-name = ""
            v-torgconf-ogr-post = ""
         .
      end.
   if v-torgconf-outogr  = "ruk_firm"
         then do:
         find first buf_sysconf no-lock
         where buf_sysconf.host-code = p-host-code
         no-error.
         if available buf_sysconf
         then do:
            assign
               v-torgconf-ogr-post = buf_sysconf.head-position
            .
         end.
         find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = p-host-code
         .
         find first buf_firm no-lock
             where buf_firm.firm-code = buf_clients.obj-code
         .
         assign
             v-torgconf-ogr-name = buf_firm.director
         .
      end.
      if v-torgconf-outogr = "dir_obj"
         then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
            CASE buf_trn-doc.obj-type:
            WHEN 'маг':U
            THEN DO:
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            WHEN 'скл':U
            THEN DO:
               find first buf_store no-lock
               where buf_store.obj-code = buf_trn-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_store.store-boss
                  v-torgconf-ogr-post = "Директор"
               .
            END.
            OTHERWISE DO:
               assign
                  v-torgconf-ogr-name = "":U
                  v-torgconf-ogr-post = "":U
               .
            END.
            END CASE.
         end.
   if v-torgconf-outogr = "manag_doc"
      then do:
         find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
         no-error.
         if available buf_trn-doc
         then do:
            run rep/get-psn.p
            (input buf_trn-doc.boss
            ,output v-torgconf-ogr-name
            ) .
         end.
         find first buf_person no-lock
         where buf_person.psn-code = buf_trn-doc.boss
         no-error.
         if available buf_person
         then do:
            v-torgconf-ogr-post = buf_person.position.
         end.
         if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
         if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
      end.
   end.
   else do:
   find first buf_wth-doc no-lock
      where buf_wth-doc.doc-code = p-doc-code
      no-error.
      if v-torgconf-outogr = "no_print"
         then do:
            assign
               v-torgconf-ogr-name = ""
               v-torgconf-ogr-post = ""
            .
         end.
      if v-torgconf-outogr  = "ruk_firm"
            then do:
            find first buf_sysconf no-lock
            where buf_sysconf.host-code = p-host-code
            no-error.
            if available buf_sysconf
            then do:
               assign
                  v-torgconf-ogr-post = buf_sysconf.head-position
               .
            end.
            find first buf_clients no-lock
               where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = p-host-code
            .
            find first buf_firm no-lock
               where buf_firm.firm-code = buf_clients.obj-code
            .
            assign
               v-torgconf-ogr-name = buf_firm.director
            .
         end.
         if v-torgconf-outogr = "dir_obj"
            then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
               find first buf_shop no-lock
               where buf_shop.obj-code = buf_wth-doc.obj-code
               .
               assign
                  v-torgconf-ogr-name = buf_shop.director
                  v-torgconf-ogr-post = "Директор"
               .
            end.
      if v-torgconf-outogr = "manag_doc"
         then do:
            find first buf_wth-doc no-lock
            where buf_wth-doc.doc-code = p-doc-code
            no-error.
            if available buf_wth-doc
            then do:
               run rep/get-psn.p
               (input buf_wth-doc.deliver
               ,output v-torgconf-ogr-name
               ) .
            end.
            find first buf_person no-lock
            where buf_person.psn-code = buf_wth-doc.deliver
            no-error.
            if available buf_person
            then do:
               v-torgconf-ogr-post = buf_person.position.
            end.
            if v-torgconf-ogr-name = "?":U then v-torgconf-ogr-name = "".
            if v-torgconf-ogr-post = ? then  v-torgconf-ogr-post = "".
         end.
   end.
end.
procedure torgconf-get-reason  :
define input parameter  p-doc-code       as character        no-undo.
define input parameter  p-reason-code    as integer          no-undo .
define input parameter  p-doc-type       as character        no-undo.
    if p-reason-code > 0
    then do:
        define buffer buf_trn-reason for ub.trn-reason.
        find first buf_trn-reason no-lock where buf_trn-reason.reason-code = p-reason-code no-error .
        if available buf_trn-reason then assign v-torgconf-reason =  buf_trn-reason.reason-name .
    end.
    else do:
        if p-doc-type = 'при':U
        then  do:
            define variable v-attr-type     as character    no-undo.
            define variable v-attr-value    as character    no-undo.
            run gbl/trdcat-v.p (input p-doc-code,input 'nids':U,output v-attr-value,output v-attr-type) .
            assign v-torgconf-reason = v-attr-value .
            run gbl/trdcat-v.p (input p-doc-code,input 'dids':U,output v-attr-value,output v-attr-type) .
            assign v-torgconf-reason = v-torgconf-reason + " от " + v-attr-value .
        end.
    end.
end procedure.
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-param no-undo   field param-code     as character   field param-sub-code as character   field param-value    as character   index xpk is primary unique param-code param-sub-code   .
procedure paramls-clear :
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    for each buf_temp-param
    on error undo, return error
    :
      delete buf_temp-param .
    end.
  end.
end procedure.
procedure paramls-write :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
      .
    end.
    assign
      buf_temp-param.param-value = p-value
    .
  end.
end procedure.
procedure paramls-read :
  define input  parameter p-code          as character no-undo .
  define input  parameter p-sub-code      as character no-undo .
  define input  parameter p-default-value as character no-undo .
  define output parameter p-value         as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
      where buf_temp-param.param-code     = p-code
        and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if available buf_temp-param then do:
      assign
        p-value = buf_temp-param.param-value
      .
    end.
    else do:
      assign
        p-value = p-default-value
      .
    end.
  end.
end procedure.
procedure paramls-append :
  define input  parameter p-code     as character no-undo .
  define input  parameter p-sub-code as character no-undo .
  define input  parameter p-value    as character no-undo .
  define buffer buf_temp-param for temp-param .
  do
  on error undo, return error return-value
  :
    find first buf_temp-param
         where buf_temp-param.param-code     = p-code
           and buf_temp-param.param-sub-code = p-sub-code
      no-error .
    if not available buf_temp-param then do:
      create buf_temp-param .
      assign
        buf_temp-param.param-code     = p-code
        buf_temp-param.param-sub-code = p-sub-code
        buf_temp-param.param-value    = p-value
      .
    end.
    else do:
        assign
            buf_temp-param.param-value = buf_temp-param.param-value + ",":U + p-value
        .
    end.
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define variable vss-include-info23 as character format "X(65)" no-undo
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
  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).
  define variable g#log as logical   no-undo .
  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).
  define shared variable sort-name   as logical no-undo.
  define shared variable sort-gr     as logical no-undo.
  define shared variable CostPrice   as logical no-undo .
  define shared variable PrintScale  as logical no-undo .
  define shared variable no-vat      as logical no-undo .
  define variable v-sys-key  as character no-undo .
  define variable v-par-type as character no-undo .
  define variable skod as logical   no-undo .
  define variable v-classify      as character  no-undo .
  define variable v-tog-level     as logical    no-undo .
  define variable v-var-level     as integer    no-undo .
  define variable p-ok            as logical    no-undo .
  define variable full-grp-name   as character  no-undo .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
  define variable v-sort-prod         as character         no-undo.
  if p-grp = "yes" then assign v-sort-prod = "no" .
  else do:
    if p-grp = "prod" then assign v-sort-prod = "yes" .
    else do:
      run gbl/conf-rd.p ("sort-prd", "", "", 0, "", "", "", no, output v-sort-prod, output v-par-type) no-error.
      if error-status :error then assign v-sort-prod = "no" .
    end.
  end.
  .
  if p-grp = "yes":U then do :
   run rep/inv3-grp.w (input parparentproc, output v-classify, output v-tog-level, output v-var-level, output p-ok ) .
   if p-ok ne true then do :
     return no-apply .
   end.
  end.
  if sort-name = no then message "Сортировать по коду? (При ответе 'нет' сортировка по артикулу)."  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE skod.
  define variable sort-group as logical   no-undo .
  if sort-gr or p-grp = "yes" then assign sort-group = yes .
  else                             assign sort-group = no .
  DEFINE temp-table temp-str no-undo
    field   grp-name          as character
    field   gds-name          as character
    field   gds-code          as integer
    field   artic             as character
    field   prod-type         as character
    field   prod-code         as integer
    field   b-code            as character
    field   tb-code           as character
    field   OKEI              as integer
    field   unit-base         as character
    field   empty-scale       as logical
    field   Price-after       as decimal
    field   a-qnty            as decimal
    field   aa-qnty           as decimal
    field   a-qnty1           as decimal
    field   a-stoim           as decimal
    field   aa-stoim          as decimal
    field   price-befor       as decimal
    field   price             as decimal
    field   b-qnty            as decimal
    field   bb-stoim          as decimal
    field   b-qnty1           as decimal
    field   b-stoim           as decimal
    field   bb-price          as decimal
    field   ubl               as decimal
    field   inv-peresort-qnty as decimal
    field   schet             as character
    INDEX pi  IS PRIMARY   artic prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
    INDEX pi3              tb-code
  .
  define stream Out-Stream.
  define buffer buf_clients      for ub.clients .
  define buffer This_Object      for ub.clients .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_goods        for ub.goods .
  define buffer buf_doc-line-sum for ub.doc-line-sum .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_gds-prt      for ub.gds-prt .
  define buffer bf_doc-attr      for ub.doc-attr .
  define buffer buf_gds-grp      for ub.gds-grp .
  define variable qnty as decimal   no-undo .
  define variable sum  as decimal   no-undo .
  define variable is-after      as logical initial yes no-undo .
  define variable is-after-cli  as logical initial yes no-undo .
  define variable is-wastage    as logical initial yes no-undo .
  define variable is-general    as logical initial yes no-undo .
  define variable v-root-node   as integer   no-undo .
  define variable num-ln as integer   no-undo .
  define variable sum-a-qnty   as decimal initial 0  no-undo .
  define variable sum-b-qnty   as decimal initial 0  no-undo .
  define variable sum-a-qnty1  as decimal initial 0  no-undo .
  define variable sum-b-qnty1  as decimal initial 0  no-undo .
  define variable sum-a-stoim  as decimal initial 0  no-undo .
  define variable sum-b-stoim  as decimal initial 0  no-undo .
  define variable sum-ubl      as decimal initial 0  no-undo .
  define variable sum1-a-qnty  as decimal initial 0  no-undo .
  define variable sum1-b-qnty  as decimal initial 0  no-undo .
  define variable sum1-a-qnty1 as decimal initial 0  no-undo .
  define variable sum1-b-qnty1 as decimal initial 0  no-undo .
  define variable sum1-a-stoim as decimal initial 0  no-undo .
  define variable sum1-b-stoim as decimal initial 0  no-undo .
  define variable sum1-ubl     as decimal initial 0  no-undo .
  define variable sum2-a-qnty  as decimal initial 0  no-undo .
  define variable sum2-b-qnty  as decimal initial 0  no-undo .
  define variable sum2-a-qnty1 as decimal initial 0  no-undo .
  define variable sum2-b-qnty1 as decimal initial 0  no-undo .
  define variable sum2-a-stoim as decimal initial 0  no-undo .
  define variable sum2-b-stoim as decimal initial 0  no-undo .
  define variable sum2-ubl     as decimal initial 0  no-undo .
  define variable v-line-price          as decimal      no-undo.
  define variable v-line-price-before   as decimal      no-undo.
  define variable v-line-price-after    as decimal      no-undo.
  define variable p-type                as character    no-undo.
  define variable FullNameGds as character no-undo .
  define variable gds-str as character no-undo.
  define variable gds-str1 as character no-undo.
  define variable gds-str2 as character no-undo.
  define variable i as integer no-undo.
  define variable j as integer no-undo.
  define variable Counter1 as integer initial 0  no-undo .
  define variable LineBuf    as character no-undo.
  define variable Line       as character no-undo.
  define variable UndLine    as character no-undo.
  define variable Lines_Counter as   integer  initial 0  no-undo.
  define variable Tmp_Counter   as   integer  initial 0  no-undo.
  define variable tdoc-date     like ub.trn-doc.doc-date no-undo.
  define variable tdoc-code     like ub.trn-doc.doc-code no-undo.
  define variable PgQnty            as  decimal no-undo.
  define variable PgQnty-v          as  decimal no-undo.
  define variable PgSum             as  decimal no-undo.
  define variable PgQnty-b          as  decimal no-undo.
  define variable PgQnty-b-v        as  decimal no-undo.
  define variable PgSum-b           as  decimal no-undo.
  define variable PgNPP             as  integer no-undo.
  define variable UBL-v      as decimal   no-undo .
  define variable b-code     as integer   no-undo .
  define variable PropisQnty        as  character no-undo.
  define variable PropisSumall      as  character no-undo.
  define variable Propiscount       as  character no-undo.
  define variable abbr              as  character no-undo.
  define variable pp                as  character no-undo.
  define variable sym1  as character initial ":"   no-undo.
  define variable sym2  as character initial ":"   no-undo.
  define variable sym3  as character initial ":"   no-undo.
  define variable sym4  as character initial ":"   no-undo.
  define variable sym5  as character initial ":"   no-undo.
  define variable sym6  as character initial ":"   no-undo.
  define variable sym7  as character initial ":"   no-undo.
  define variable sym8  as character initial ":"   no-undo.
  define variable sym9  as character initial ":"   no-undo.
  define variable sym10 as character initial ":"   no-undo.
  define variable sym11 as character initial ":"   no-undo.
  define variable sym12 as character initial ":"   no-undo.
  define variable sym13 as character initial ":"   no-undo.
  define variable sym14 as character initial ":"   no-undo.
  define variable sym15 as character initial ":"   no-undo.
  define variable sym16 as character initial ":"   no-undo.
  define variable sym17 as character initial ":"   no-undo.
  define variable sym18 as character initial ":"   no-undo.
  FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
    define variable pr as character no-undo .
    run rep/wp-qnty.p ( input p-dec, output Pr ).
    RETURN ( Pr ) .
  END FUNCTION.
  FUNCTION f-wp-sum returns character ( INPUT p-dec as decimal ) :
    define variable pr as character no-undo .
    if PrintRubl = yes then do: run rep/wp-rub.p (                      input p-dec, output pr, output abbr ). end.
                       else do: run rep/wp.p     ( input parParentProc, input p-dec, output Pr, output abbr ). end.
    RETURN ( Pr ).
  END FUNCTION.
  DEFINE FRAME invent
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C7 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C25 format "X(24)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C50 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Код товара! ! ! ! ":C15 format "X(14)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!-------!Код    !по!ОКЕИ":C7 format ">>>>" space(0)
        sym6 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!-------!Наим!енов!ание":C7 format "X(6)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price-befor COLUMN-LABEL " ! Цена ! ! ! ":C13 format "->>>>>9.99" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Фактическое !наличие!-------------------------!Количество ! ":C25 format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "По данным! бухгалтерского учета!--------------------------!Количество ! ":C26 format "->>>>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp) AT 150 format "X(29)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 180 format "X(13)" SKIP
        UndLine format "X(185)" AT 1
        with width 232 down stream-io use-text NO-BOX.
DEFINE FRAME sl
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Код товара! ! ! ! ":C13 format "X(13)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код ! по !ОКЕИ" format ">>>>" space(0)
        sym6 column-label         " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Излишек!Количество! ! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-stoim COLUMN-LABEL "Излишек!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "Недостача!Количество! ! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-stoim COLUMN-LABEL "Недостача!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.UBL COLUMN-LABEL "Списано!в пределах!норм!естественной!убыли":C13 format "->>>>>>>>>.<<" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Сличительная ведомость N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 130 format "X(29)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 160 format "X(13)" SKIP
        UndLine format "X(162)" AT 1
        with width 232 down stream-io use-text NO-BOX.
DEFINE FRAME sl-gold
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Проба! ! ! ! " format "X(3)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код ! по !ОКЕИ" format ">>>>" space(0)
        sym6 column-label         " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Изл!-------------!Количество !осн.ед.изм ! " format "->>>>>>>9.<<<" space(0)
        sym8 column-label "и!-!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty1 COLUMN-LABEL "шек          !-------------!Количество ! ! " format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-stoim COLUMN-LABEL "Излишек!Сумма! ! ! ":C16 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "         Недос!--------------!Количество!осн.ед.изм! ":C14 format "->>>>>>>9.<<<" space(0)
        sym11 column-label "т!-!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty1 COLUMN-LABEL "ача         !------------!Количество! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-stoim COLUMN-LABEL "Недостача!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.UBL COLUMN-LABEL   "Списано   !норм ес! !------------!осн.ед.изм":R12 format "->>>>>>>>>.<<" space(0)
        sym15 column-label         "в!т! !-!:" format "X(1)" space(0)
        UBL-v COLUMN-LABEL "   пределах!ественной!убыли!------------! ":L12 format "->>>>>>>>>.<<" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Сличительная ведомость N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 130 format "X(29)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 160 format "X(13)" SKIP
        UndLine format "X(196)" AT 1
        with width 232 down stream-io use-text NO-BOX.
  FIND buf_trn-doc WHERE recid(buf_trn-doc) = rec_id NO-LOCK .
  assign
    tdoc-date = (if buf_trn-doc.status_ <> 'факт':U then buf_trn-doc.doc-date else buf_trn-doc.fact-date)
    tdoc-code = buf_trn-doc.doc-code
  .
  define variable v-host-code as integer   no-undo .
  define variable v-curr-code as integer   no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
  if printRubl = yes
  then do:
      assign
          v-curr-code = 0
      .
  end.
  else do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-curr-code
  )  .
  end.
define variable vss-include-info27 as character format "X(65)" no-undo
initial "@(#)$Workfile: inv3xl.i $ $Revision: aea5316774be, 0, rls $".
define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character
    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field num          as integer
    field name         as character
    field gdscode      as character
    field EI           as character
    field OKEI         as character
    field price        as character
    field qntyFact     as character
    field sumFact      as character
    field qntyBuh      as character
    field sumBuh       as character
    index pi is primary unique xl-line-id
.
define variable v-inv3xl-current-data-row     as integer      no-undo.
define variable v-inv3xl-cell-file-name       as character    no-undo.
define variable v-inv3xl-data-file-name       as character    no-undo.
procedure inv3xl-init :
    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-inv3xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-inv3xl-data-file-name
    ).
    output stream excel-line to value( v-inv3xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-inv3xl-cell-file-name
    ).
    output stream excel-cell to value( v-inv3xl-cell-file-name ).
    if v-curr-code = 0 then do :
       run inv3xl-write-cell-data in this-procedure (
             input "valutCode":U
           , input 0
       ).
    end.
    else do :
       run inv3xl-write-cell-data in this-procedure (
             input "valutCode":U
           , input 1
       ).
    end.
    run inv3xl-write-cell-data in this-procedure (
          input "columnList":U
        , input "num,name,gdscode,EI,OKEI,price,qntyFact,sumFact,qntyBuh,sumBuh":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "columnType":U
        , input "I,S,I,S,S,C,D,C,D,C":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "columnAmount":U
        , input "10":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "subtotalList":U
        , input "num,qntyFact,qntyBuh":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "subtotalType":U
        , input "C,S,S,S,S":U
    ).
    run inv3xl-write-cell-data in this-procedure (
          input "subtotalAmount":U
        , input "5":U
    ).
    run inv3xl-write-cell-data in this-procedure (
        input "subtotalPropisList":U
        , input "num,qntyFact":U
    ).
    run inv3xl-write-cell-data in this-procedure (
        input "subtotalPropisAmount":U
        , input "3":U
    ).
end.
end procedure.
procedure inv3xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/i3_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-inv3xl-cell-file-name.
        export v-inv3xl-data-file-name.
    output close.
end.
end procedure.
procedure inv3xl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.
    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        CHR(9)   buf_temp_cell-data.data-value
        chr(10)
    .
end.
end procedure.
procedure inv3xl-write-line-data :
define input parameter p-num        as integer          no-undo.
define input parameter p-name       as character        no-undo.
define input parameter p-gdscode    as character        no-undo.
define input parameter p-EI         as character        no-undo.
define input parameter p-OKEI       as character        no-undo.
define input parameter p-price      as character        no-undo.
define input parameter p-qntyFact   as character        no-undo.
define input parameter p-sumFact    as character        no-undo.
define input parameter p-qntyBuh    as character        no-undo.
define input parameter p-sumBuh     as character        no-undo.
    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:
    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-inv3xl-current-data-row = v-inv3xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = "LD":U
        buf_temp_line-data.xl-line-id   = v-inv3xl-current-data-row
        buf_temp_line-data.num       = p-num
        buf_temp_line-data.name      = p-name
        buf_temp_line-data.gdscode   = p-gdscode
        buf_temp_line-data.EI        = p-EI
        buf_temp_line-data.OKEI      = p-OKEI
        buf_temp_line-data.price     = p-price
        buf_temp_line-data.qntyFact  = p-qntyFact
        buf_temp_line-data.sumFact   = p-sumFact
        buf_temp_line-data.qntyBuh   = p-qntyBuh
        buf_temp_line-data.sumBuh    = p-sumBuh
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        CHR(9)   ( if buf_temp_line-data.num = 0 then "":U else string( buf_temp_line-data.num ) )
        CHR(9)   buf_temp_line-data.name
        CHR(9)   buf_temp_line-data.gdscode
        CHR(9)   buf_temp_line-data.EI
        CHR(9)   buf_temp_line-data.OKEI
        CHR(9)   buf_temp_line-data.price
        CHR(9)   buf_temp_line-data.qntyFact
        CHR(9)   buf_temp_line-data.sumFact
        CHR(9)   buf_temp_line-data.qntyBuh
        CHR(9)   buf_temp_line-data.sumBuh
        chr(10)
    .
end.
end procedure.
procedure inv3xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.
    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.
    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/i3_97.xlt" )
        v-vb-file-name          = search( "exe/t_97.bas")
    .
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input "template":U
        , input "template-file-name":U
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input "template":U
        , input "vb-file-name":U
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-header-filename":U
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input "data":U
        , input "data-filename":U
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure.
  run torgconf-get-self-param in this-procedure (
        input buf_trn-doc.obj-type
      , input buf_trn-doc.obj-code
      , input v-curr-code
  ) no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip "Ошибка чтения параметров объекта документа."
      skip return-value
      skip trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
      view-as alert-box warning.
  end.
  run Check-Doc-Sum in this-procedure no-error  .
  if error-status :error then return error .
  if rep-tipe <> "sl" and PrintScale = true THEN DO:
    message "Инвентаризационная опись не проводится с разбиением по признакам !" view-as alert-box . PrintScale = false .
  End.
output STREAM Out-Stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  if rep-tipe begins "invent"
  and p-grp = "no"
  then do:
      run inv3xl-init in this-procedure .
  end.
  define variable v-prn0 as character no-undo .
  run gbl/conf-rd.p ("invprn0", "", "", 0, "", "", "", no, output v-prn0, output v-par-type) no-error.
  if error-status:error then v-prn0 = 'yes' .
  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .
  if  CostPrice then DO:
    if no-vat = no then do:
      IF PrintRubl THEN Assign PP = "Учетные цены ".
      Else Assign PP = "Учетные цены (б.в.)" .
    end.
    else do:
      IF PrintRubl THEN Assign PP = "Учетные цены без НДС ".
      Else Assign PP = "Учетные цены без НДС (б.в.)" .
    end.
  End.
  Else DO:
    IF PrintRubl THEN Assign PP = "Цены док-та".
    Else Assign PP = "Цены док-та (б.в.)" .
  End.
  FIND This_Object  WHERE This_Object.obj-type = buf_trn-doc.obj-type AND This_Object.obj-code = buf_trn-doc.obj-code  NO-LOCK.
  FIND clients      WHERE clients.obj-type     = 'орг':U           AND clients.obj-code     = buf_trn-doc.host-code NO-LOCK.
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 25 ) = 0 then 100 else integer( 25 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
  find first buf_goods no-lock where
             buf_goods.prod-type = buf_doc-line.prod-type and
             buf_goods.prod-code = buf_doc-line.prod-code and
             buf_goods.artic     = buf_doc-line.artic     no-error.
  find first ub.units no-lock where ub.units.unit-name = buf_goods.unit-base no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output b-code
  ) no-error .
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при определении бар-кода товара"     skip
            "Артикул товара:" buf_goods.artic            skip
            "Производитель:"  buf_goods.prod-type buf_goods.prod-code skip
            error-status :get-message( 1 ) skip
            error-status :get-message( 2 ) skip
            return-value                   skip( 1 )
    view-as alert-box error.
  end.
  assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
  if p-grp = "yes":U then do :
  find first buf_gds-grp where buf_gds-grp.node-code = buf_goods.grp-code no-error .
      run grplib-get-full-name in this-procedure
      (  input buf_gds-grp.node-code
      , output full-grp-name
      ) .
  case v-classify :
    when "no-classify":U
    then do:
      if buf_gds-grp.lvl-num = 1 then do :
        create temp-str.
        assign temp-str.b-code     = string( b-code )
              temp-str.grp-name    = buf_gds-grp.node-name
              temp-str.artic       = buf_goods.artic
              temp-str.prod-type   = buf_goods.prod-type
              temp-str.prod-code   = buf_goods.prod-code
              temp-str.gds-code    = buf_goods.gds-code
              temp-str.OKEI        = units.OKEI
              temp-str.unit-base   = buf_goods.unit-base
              temp-str.tb-code     = buf_goods.sort
              temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
      if buf_gds-grp.lvl-num > 1 and buf_gds-grp.upper-code ne 0 then do :
          run no-classify in this-procedure ( input buf_gds-grp.upper-code, output full-grp-name ) no-error .
          create temp-str.
          assign temp-str.b-code   = string( b-code )
              temp-str.grp-name    = full-grp-name
              temp-str.artic       = buf_goods.artic
              temp-str.prod-type   = buf_goods.prod-type
              temp-str.prod-code   = buf_goods.prod-code
              temp-str.gds-code    = buf_goods.gds-code
              temp-str.OKEI        = units.OKEI
              temp-str.unit-base   = buf_goods.unit-base
              temp-str.tb-code     = buf_goods.sort
              temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
    end.
    when "n-level":U
    then do:
        if   buf_gds-grp.lvl-num = v-var-level
        or ( buf_gds-grp.lvl-num <  v-var-level and buf_gds-grp.is-term  = yes )
          then do :
              create temp-str.
              assign temp-str.b-code = string( b-code )
                temp-str.grp-name    = full-grp-name
                temp-str.artic       = buf_goods.artic
                temp-str.prod-type   = buf_goods.prod-type
                temp-str.prod-code   = buf_goods.prod-code
                temp-str.gds-code    = buf_goods.gds-code
                temp-str.OKEI        = units.OKEI
                temp-str.unit-base   = buf_goods.unit-base
                temp-str.tb-code     = buf_goods.sort
                temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
        else do:
          run n-level in this-procedure ( input buf_gds-grp.upper-code, input v-var-level, output full-grp-name ) no-error .
              create temp-str.
              assign temp-str.b-code = string( b-code )
                temp-str.grp-name    = full-grp-name
                temp-str.artic       = buf_goods.artic
                temp-str.prod-type   = buf_goods.prod-type
                temp-str.prod-code   = buf_goods.prod-code
                temp-str.gds-code    = buf_goods.gds-code
                temp-str.OKEI        = units.OKEI
                temp-str.unit-base   = buf_goods.unit-base
                temp-str.tb-code     = buf_goods.sort
                temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
              .
        end.
    end.
    when "t-level":U
    then do:
        if buf_gds-grp.is-term = true
        then do :
          create temp-str.
          assign temp-str.b-code = string( b-code )
            temp-str.grp-name    = buf_gds-grp.node-name
            temp-str.artic       = buf_goods.artic
            temp-str.prod-type   = buf_goods.prod-type
            temp-str.prod-code   = buf_goods.prod-code
            temp-str.gds-code    = buf_goods.gds-code
            temp-str.OKEI        = units.OKEI
            temp-str.unit-base   = buf_goods.unit-base
            temp-str.tb-code     = buf_goods.sort
            temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
          .
        end.
        else do:
            run t-level in this-procedure ( input buf_gds-grp.node-code, output full-grp-name ) no-error .
            create temp-str.
            assign temp-str.b-code = string( b-code )
              temp-str.grp-name    = full-grp-name
              temp-str.artic       = buf_goods.artic
              temp-str.prod-type   = buf_goods.prod-type
              temp-str.prod-code   = buf_goods.prod-code
              temp-str.gds-code    = buf_goods.gds-code
              temp-str.OKEI        = units.OKEI
              temp-str.unit-base   = buf_goods.unit-base
              temp-str.tb-code     = buf_goods.sort
              temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
          .
        end.
    end.
  end case.
end.
else do :
  create temp-str.
  assign temp-str.b-code      = string( b-code )
         temp-str.grp-name    = buf_goods.grp-name
         temp-str.artic       = buf_goods.artic
         temp-str.prod-type   = buf_goods.prod-type
         temp-str.prod-code   = buf_goods.prod-code
         temp-str.gds-code    = buf_goods.gds-code
         temp-str.OKEI        = units.OKEI
         temp-str.unit-base   = buf_goods.unit-base
         temp-str.tb-code     = buf_goods.sort
         temp-str.inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
         .
end.
  if rep-tipe = "invent-gold" or rep-tipe = "sl-gold" then do:
    assign temp-str.gds-name = trim( buf_goods.gds-name ) + " ":U + trim( buf_goods.PS ).
  end.
  else do:
    assign temp-str.gds-name = ( if g#gds-engl = yes then buf_goods.engl-name else buf_goods.gds-name ).
  end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output temp-str.empty-scale
  )  .
  if rep-tipe begins "invent" then do:
    find first buf_doc-line-sum no-lock where
               buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
               buf_doc-line-sum.gds-code = buf_goods.gds-code    and
               buf_doc-line-sum.sum-type = 'bd':U     no-error.
    if costprice = yes then do:
      if no-vat = no then do:
        if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-rubl. end.
                           else do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-base. end.
      end.
      else do:
        if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                           else do: assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
      end.
    end.
    else do:
      if PrintRubl = yes then do: assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-rubl. end.
                         else do: assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-base. end.
    end.
    assign temp-str.b-qnty      = buf_doc-line-sum.fact-qnty
           temp-str.price-befor = temp-str.b-stoim / temp-str.b-qnty.
    if temp-str.price-befor = ? then do: assign temp-str.price-befor = 0. end.
    if rep-tipe = "invent-gold" then do:
      find first buf_doc-line-sum no-lock where
                 buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                 buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                 buf_doc-line-sum.sum-type = 'bcd':U no-error.
      if available buf_doc-line-sum then do: assign temp-str.b-qnty1 = buf_doc-line-sum.fact-qnty. end.
    end.
    if is-after = yes then do:
      find first buf_doc-line-sum no-lock where
                 buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                 buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                 buf_doc-line-sum.sum-type = 'ad':U      no-error.
      if costprice = yes then do:
        if no-vat = no then do:
          if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-rubl. end.
                             else do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-base. end.
        end.
        else do:
          if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                             else do: assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
        end.
      end.
      else do:
        if PrintRubl = yes then do: assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-rubl. end.
                           else do: assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-base. end.
      end.
      assign temp-str.a-qnty      = buf_doc-line-sum.fact-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty.
    end.
    else do:
      if costprice = yes then do:
        if PrintRubl = yes then do: assign sum = buf_doc-line.price-rubl * buf_doc-line.fact-qnty. end.
                           else do: assign sum = buf_doc-line.price-base * buf_doc-line.fact-qnty. end.
      end.
      else do:
        assign sum = 0.
        for each buf_gds-dtl no-lock where
                 buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
                 buf_gds-dtl.artic     = buf_doc-line.artic     and
                 buf_gds-dtl.prod-type = buf_doc-line.prod-type and
                 buf_gds-dtl.prod-code = buf_doc-line.prod-code :
          if PrintRubl = yes then do: assign sum = sum + buf_gds-dtl.price-rubl * buf_gds-dtl.doc-qnty. end.
                             else do: assign sum = sum + buf_gds-dtl.price-base * buf_gds-dtl.doc-qnty. end.
        end.
      end.
      assign temp-str.a-stoim     = temp-str.b-stoim + sum
             temp-str.a-qnty      = temp-str.b-qnty  + buf_doc-line.fact-qnty
             temp-str.price-after = temp-str.a-stoim / temp-str.a-qnty.
    end.
    if temp-str.price-after = ? then do: assign temp-str.price-after = 0. end.
    if rep-tipe = "invent-gold" then do:
      if is-after-cli = yes then do:
        find first buf_doc-line-sum no-lock where
                   buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                   buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                   buf_doc-line-sum.sum-type = 'acd':U  no-error.
        if available buf_doc-line-sum then do: assign temp-str.a-qnty1 = buf_doc-line-sum.fact-qnty. end.
      end.
      else do:
        assign temp-str.a-qnty1 = temp-str.b-qnty1 + buf_doc-line.cli-qnty.
      end.
    end.
    if v-prn0 = "no" then do:
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 and temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then do:
        delete temp-str.
      end.
    end.
  end.
  else do:
    if costprice = yes then do:
      if is-general = yes then do:
        find first buf_doc-line-sum no-lock where
                   buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                   buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                   buf_doc-line-sum.sum-type = 'gen':U    no-error.
        if no-vat = no then do:
          if PrintRubl = yes then do: assign sum = buf_doc-line-sum.cost-sum-rubl. end.
                             else do: assign sum = buf_doc-line-sum.cost-sum-base. end.
        end.
        else do:
          if PrintRubl = yes then do: assign sum = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl. end.
                             else do: assign sum = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base. end.
        end.
      end.
      else do:
        if PrintRubl = yes then do: assign sum = buf_doc-line.price-rubl * buf_doc-line.fact-qnty. end.
                           else do: assign sum = buf_doc-line.price-base * buf_doc-line.fact-qnty. end.
      end.
    end.
    else do:
      assign sum = 0.
      for each buf_gds-dtl no-lock where
               buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
               buf_gds-dtl.artic     = buf_doc-line.artic     and
               buf_gds-dtl.prod-type = buf_doc-line.prod-type and
               buf_gds-dtl.prod-code = buf_doc-line.prod-code :
        if PrintRubl = yes then do: assign sum = sum + buf_gds-dtl.price-rubl * buf_gds-dtl.doc-qnty. end.
                           else do: assign sum = sum + buf_gds-dtl.price-base * buf_gds-dtl.doc-qnty. end.
      end.
    end.
    assign qnty = buf_doc-line.fact-qnty.
    if sum >= 0 then do:
      assign temp-str.a-qnty      = qnty
             temp-str.a-stoim     = sum
             temp-str.a-qnty1     = buf_doc-line.cli-qnty
             temp-str.ubl         = 0.
      if temp-str.a-qnty = 0 and temp-str.a-stoim = 0 then do: delete temp-str. end.
    end.
    else do:
      assign temp-str.b-qnty      = - qnty
             temp-str.b-stoim     = - sum
             temp-str.b-qnty1     = - buf_doc-line.cli-qnty
             temp-str.ubl         = 0
             sum                  = - sum.
      if is-wastage = yes then do:
        find first buf_doc-line-sum no-lock where
                   buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                   buf_doc-line-sum.gds-code = buf_goods.gds-code    and
                   buf_doc-line-sum.sum-type = 'wst':U    no-error.
        if available buf_doc-line-sum then do:
          if costprice = yes then do:
            if PrintRubl = yes then do: assign temp-str.ubl = buf_doc-line-sum.cost-sum-rubl. end.
                               else do: assign temp-str.ubl = buf_doc-line-sum.cost-sum-base. end.
          end.
          else do:
            if PrintRubl = yes then do: assign temp-str.ubl = buf_doc-line-sum.sale-sum-rubl. end.
                               else do: assign temp-str.ubl = buf_doc-line-sum.sale-sum-base. end.
          end.
          if sum < temp-str.ubl then do: assign temp-str.ubl = sum. end.
        end.
      end.
      if temp-str.b-qnty = 0 and temp-str.b-stoim = 0 then do: delete temp-str. end.
    end.
  end.
end.
procedure t-level :
  define input parameter  p-node-code like ub.gds-grp.node-code no-undo .
  define output parameter p-node-name as character              no-undo .
  define variable         v-is-term   as logical                no-undo .
  define buffer loc-gds-grp for ub.gds-grp .
  v-is-term = false .
  repeat while v-is-term = false :
      find first loc-gds-grp where loc-gds-grp.upper-code = p-node-code no-error .
      run grplib-get-full-name in this-procedure
        (  input loc-gds-grp.node-code
        , output p-node-name
        ) .
        assign
          p-node-code = loc-gds-grp.node-code
          v-is-term = loc-gds-grp.is-term
        .
    end.
end procedure.
 procedure n-level :
  define input  parameter p-upper-code like ub.gds-grp.upper-code no-undo .
  define input  parameter p-lvl-num    as   integer               no-undo .
  define output parameter p-node-name  as   character             no-undo .
  define variable        v-lvl-num     as   integer               no-undo .
  define variable loc-grp-name         as   character             no-undo .
  define buffer loc-gds-grp for ub.gds-grp .
  v-lvl-num = 0 .
    repeat while p-lvl-num <> v-lvl-num :
      find first loc-gds-grp where loc-gds-grp.node-code = p-upper-code no-error .
      run grplib-get-full-name in this-procedure
        (  input loc-gds-grp.node-code
        , output p-node-name
        ) .
      assign
        v-lvl-num    = loc-gds-grp.lvl-num
        p-upper-code = loc-gds-grp.upper-code
      .
    end.
end procedure.
 procedure no-classify :
  define input    parameter p-node-code like ub.gds-grp.node-code no-undo .
  define output   parameter p-grp-name  as character              no-undo .
  define variable           v-lvl-num   like ub.gds-grp.lvl-num   no-undo .
  define buffer loc-gds-grp for ub.gds-grp .
  v-lvl-num = 0 .
  repeat while v-lvl-num ne 1 :
      find first loc-gds-grp where loc-gds-grp.node-code = p-node-code no-error .
      assign
          p-node-code = loc-gds-grp.upper-code
          v-lvl-num   = loc-gds-grp.lvl-num
          p-grp-name  = loc-gds-grp.node-name
      .
  end.
end procedure.
  run PrintTitul in this-procedure .
  if rep-tipe = "invent" THEN  DO:
    FORM with frame invent .    FORM HEADER
      LineBuf format "X(185)" SKIP
      String("        " + "                " + "              " + String(PgQnty ,  "->>>>>>>>>9.<<<" ) + sym8 + "       "+
             String(PgQnty-b,  "->>>>>>>>>>>>9.<<<" ) + sym5 )  at 100 Format "x(90)" skip
      "Итого по странице : " skip
      "а) количество порядковых номеров " + string(PgNPP) + " (" + f-wp-qnty (decimal(PgNPP)) + ")" format "X(185)" AT 18  skip
      "б) общее количество единиц фактически " + string(PgQnty) + " (" + f-wp-qnty (decimal(PgQnty)) + ")"  format "X(185)" AT 18  SKIP
      "Вкладной лист к форме № ИНВ-3 №  " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") format "x(170)" AT 30 SKIP
    with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW stream Out-Stream FRAME BottomFrame .
  End.
  if rep-tipe = "invent-gold" THEN DO:
    FORM with frame invent-gold .
    FORM HEADER
      LineBuf format "X(194)" SKIP
      String(sym1 + String(PgQnty ,  "->>>>>>>>>9.<<<" ) + String(PgQnty-v ,  "->>>>>>>>>9.<<<" ) + sym2 + String(PgSum , "->>>>>>>>>>9.99"   ) +
             sym6 + "           " + sym3 + String(PgQnty-b,   "->>>>>>>>9.<<<" ) + String(PgQnty-b-v, "->>>>>>>>9.<<<" ) +
             sym4 + String(PgSum-b , "->>>>>>>>>>>>>9.99"   ) + sym5)  at 100 Format "x(98)"       skip
      "Итого по странице : " skip
      "а) количество порядковых номеров " + string(PgNPP) + " (" + f-wp-qnty (decimal(PgNPP)) + ")" format "X(194)" AT 18  skip
      "б) общее количество единиц фактически " + string(PgQnty) + " (" + f-wp-qnty (decimal(PgQnty)) + ")"  format "X(194)" AT 18  SKIP
      "Вкладной лист к форме № ИНВ-3 №  " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") format "x(170)" AT 30 SKIP
    with FRAME BottomFrame2 width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW stream Out-Stream FRAME BottomFrame2 .
  end.
  if rep-tipe begins "invent" THEN DO:
    PUT stream Out-Stream SPACE(35) string ("Инвентаризационная опись N " + tdoc-code ) format "x(50)" SKIP
      SPACE(10) string (string (This_Object.obj-type , "X(3)") + ": " + trim(This_Object.obj-name) ) format "x(50)"
      string ("дата инвентаризации : " + string (tdoc-date, "99.99.9999") ) format "x(50)" SKIP.
  End.
  if rep-tipe = "sl" THEN  FORM with frame sl .
  if rep-tipe = "sl-gold" THEN  FORM with frame sl-gold .
  if v-sort-prod = "yes" then do:
    if sort-group = yes then do:
      for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by temp-str.grp-name by if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic ) :
        if first-of( temp-str.prod-code) then run print-prod in this-procedure .
        if p-grp <> "prod" and first-of( temp-str.grp-name)  then run print-grp in this-procedure .
        run print-line in this-procedure .
        if p-grp <> "prod" and last-of( temp-str.grp-name)   then run print-grp-itog in this-procedure .
        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .
      end.
    end.
    else do:
      for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic ) :
        if p-grp <> "prod" and first-of( temp-str.prod-code) then run print-prod in this-procedure .
        run print-line in this-procedure .
        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .
      end.
    end.
  end.
  else do:
    if sort-group = yes then do:
      for each temp-str no-lock break by temp-str.grp-name by if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic ) :
        if p-grp = "no" and first-of( temp-str.grp-name) then run print-grp in this-procedure .
        run print-line in this-procedure .
        if last-of( temp-str.grp-name) then  run print-grp-itog in this-procedure .
      end.
    end.
    else do:
      for each temp-str no-lock break by if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic ) :
        run print-line in this-procedure .
      end.
    end.
  end.
  run print-all-itog in this-procedure .
  run on-same-page in this-procedure (input 14) .
  run PrintPodval in this-procedure .
  output stream Out-Stream CLOSE .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-close in this-procedure .
    end.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 8 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
procedure print-grp :
  do  on error undo, return error return-value  :
    case rep-tipe :
      when "invent" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "X(185)"  skip  .
      End.
      when "invent-gold" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent-gold .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "X(194)"  skip  .
      End.
      when  "sl"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "X(162)"  skip  .
      End.
      when  "sl-gold"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl-gold .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT "X(196)"  skip  .
      End.
    End.
  end.
end procedure.
procedure print-prod :
  do  on error undo, return error return-value  :
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-str.prod-type
        and buf_clients.obj-code = temp-str.prod-code
    .
    if p-grp <> "prod" then do:
      case rep-tipe :
        when "invent" THEN DO:
          DOWN stream Out-Stream 1 with FRAME invent .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT "X(185)"  skip  .
        End.
        when "invent-gold" THEN DO:
          DOWN stream Out-Stream 1 with FRAME invent-gold .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT "X(194)"  skip  .
        End.
        when  "sl"  THEN DO:
          DOWN stream Out-Stream 1 with FRAME sl .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT "X(162)"  skip  .
        End.
        when  "sl-gold"  THEN DO:
          DOWN stream Out-Stream 1 with FRAME sl-gold .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT "X(196)"  skip  .
        End.
      End.
    End.
  end.
end procedure.
procedure print-line :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent"      THEN DO:
define variable vss-include-info30 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
    sum1-ubl      = sum1-ubl      + temp-str.ubl
    sum2-a-qnty   = sum2-a-qnty   + temp-str.a-qnty
    sum2-b-qnty   = sum2-b-qnty   + temp-str.b-qnty
    sum2-a-qnty1  = sum2-a-qnty1  + temp-str.a-qnty1
    sum2-b-qnty1  = sum2-b-qnty1  + temp-str.b-qnty1
    sum2-a-stoim  = sum2-a-stoim  + temp-str.a-stoim
    sum2-b-stoim  = sum2-b-stoim  + temp-str.b-stoim
    sum2-ubl      = sum2-ubl      + temp-str.ubl
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if temp-str.aa-qnty <> 0 then do:
    if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7     temp-str.price-befor
    sym8     temp-str.b-qnty @ temp-str.a-qnty
    sym9    temp-str.b-qnty
    sym10  with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7     temp-str.price-befor
    sym8     temp-str.aa-qnty @ temp-str.a-qnty
    sym9    0.00 @ temp-str.b-qnty
    sym10  with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.bb-price
            , input temp-str.b-qnty
            , input temp-str.bb-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price
            , input temp-str.aa-qnty
            , input temp-str.aa-stoim
            , input 0.00
            , input 0.00
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame invent .
      DOWN STREAM Out-Stream 1 with FRAME invent .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
          sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME invent .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(185)" SKIP.
end.
end.
else do:
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7    temp-str.price-befor
    sym8    temp-str.a-qnty
    sym9     temp-str.a-stoim
    sym9    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym10  with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price-after
            , input temp-str.a-qnty
            , input temp-str.a-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame invent .
      DOWN STREAM Out-Stream 1 with FRAME invent .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
              sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME invent.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME invent .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(185)" SKIP.
end.
end.
   End.
      when "invent-gold" THEN DO:
define variable vss-include-info31 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
    sum1-ubl      = sum1-ubl      + temp-str.ubl
    sum2-a-qnty   = sum2-a-qnty   + temp-str.a-qnty
    sum2-b-qnty   = sum2-b-qnty   + temp-str.b-qnty
    sum2-a-qnty1  = sum2-a-qnty1  + temp-str.a-qnty1
    sum2-b-qnty1  = sum2-b-qnty1  + temp-str.b-qnty1
    sum2-a-stoim  = sum2-a-stoim  + temp-str.a-stoim
    sum2-b-stoim  = sum2-b-stoim  + temp-str.b-stoim
    sum2-ubl      = sum2-ubl      + temp-str.ubl
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if temp-str.aa-qnty <> 0 then do:
    if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7     temp-str.price-befor
    sym8     temp-str.b-qnty @ temp-str.a-qnty
    sym9    temp-str.b-qnty
    sym10  with FRAME invent-gold.
  DOWN stream Out-Stream 1 with FRAME invent-gold .
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7     temp-str.price-befor
    sym8     temp-str.aa-qnty @ temp-str.a-qnty
    sym9    0.00 @ temp-str.b-qnty
    sym10  with FRAME invent-gold.
  DOWN stream Out-Stream 1 with FRAME invent-gold .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.bb-price
            , input temp-str.b-qnty
            , input temp-str.bb-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price
            , input temp-str.aa-qnty
            , input temp-str.aa-stoim
            , input 0.00
            , input 0.00
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame invent-gold .
      DOWN STREAM Out-Stream 1 with FRAME invent-gold .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
          sym10
        with FRAME invent-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME invent-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME invent-gold .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(194)" SKIP.
end.
end.
else do:
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7    temp-str.price-befor
    sym8    temp-str.a-qnty
    sym9     temp-str.a-stoim
    sym9    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym10  with FRAME invent-gold.
  DOWN stream Out-Stream 1 with FRAME invent-gold .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price-after
            , input temp-str.a-qnty
            , input temp-str.a-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame invent-gold .
      DOWN STREAM Out-Stream 1 with FRAME invent-gold .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
              sym10
        with FRAME invent-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME invent-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME invent-gold .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(194)" SKIP.
end.
end.
   End.
      when  "sl"         THEN DO:
define variable vss-include-info32 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
    sum1-ubl      = sum1-ubl      + temp-str.ubl
    sum2-a-qnty   = sum2-a-qnty   + temp-str.a-qnty
    sum2-b-qnty   = sum2-b-qnty   + temp-str.b-qnty
    sum2-a-qnty1  = sum2-a-qnty1  + temp-str.a-qnty1
    sum2-b-qnty1  = sum2-b-qnty1  + temp-str.b-qnty1
    sum2-a-stoim  = sum2-a-stoim  + temp-str.a-stoim
    sum2-b-stoim  = sum2-b-stoim  + temp-str.b-stoim
    sum2-ubl      = sum2-ubl      + temp-str.ubl
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if temp-str.aa-qnty <> 0 then do:
    if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym9    temp-str.b-qnty
    sym10  with FRAME sl.
  DOWN stream Out-Stream 1 with FRAME sl .
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym9    0.00 @ temp-str.b-qnty
    sym10  with FRAME sl.
  DOWN stream Out-Stream 1 with FRAME sl .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.bb-price
            , input temp-str.b-qnty
            , input temp-str.bb-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price
            , input temp-str.aa-qnty
            , input temp-str.aa-stoim
            , input 0.00
            , input 0.00
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame sl .
      DOWN STREAM Out-Stream 1 with FRAME sl .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
          sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME sl .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(162)" SKIP.
end.
end.
else do:
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym7  temp-str.a-qnty
    sym14 temp-str.UBL
    sym9     temp-str.a-stoim
    sym9    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym10  with FRAME sl.
  DOWN stream Out-Stream 1 with FRAME sl .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price-after
            , input temp-str.a-qnty
            , input temp-str.a-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame sl .
      DOWN STREAM Out-Stream 1 with FRAME sl .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
              sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME sl.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME sl .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(162)" SKIP.
end.
end.
   End.
      when  "sl-gold"    THEN DO:
define variable vss-include-info33 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  assign Lines_Counter = Lines_Counter + 1  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  if line-counter( Out-Stream ) < Tmp_Counter then
    assign PgNPP = 0  PgQnty = 0 PgSum = 0 PgQnty-b = 0 PgSum-b  = 0  PgQnty-v = 0  PgQnty-b-v = 0 .
  assign
    Tmp_Counter  = line-counter( Out-Stream )
    PgNPP        = PgNPP      + 1
    PgQnty       = PgQnty     + temp-str.a-qnty
    PgQnty-b     = PgQnty-b   + temp-str.b-qnty
    PgQnty-v     = PgQnty-v   + temp-str.a-qnty1
    PgQnty-b-v   = PgQnty-b-v + temp-str.b-qnty1
    PgSum        = PgSum      + temp-str.a-stoim
    PgSum-b      = PgSum-b    + temp-str.b-stoim
    num-ln = num-ln + 1
    sum-a-qnty    = sum-a-qnty    + temp-str.a-qnty
    sum-b-qnty    = sum-b-qnty    + temp-str.b-qnty
    sum-a-qnty1   = sum-a-qnty1   + temp-str.a-qnty1
    sum-b-qnty1   = sum-b-qnty1   + temp-str.b-qnty1
    sum-a-stoim   = sum-a-stoim   + temp-str.a-stoim
    sum-b-stoim   = sum-b-stoim   + temp-str.b-stoim
    sum-ubl       = sum-ubl       + temp-str.ubl
    sum1-a-qnty   = sum1-a-qnty   + temp-str.a-qnty
    sum1-b-qnty   = sum1-b-qnty   + temp-str.b-qnty
    sum1-a-qnty1  = sum1-a-qnty1  + temp-str.a-qnty1
    sum1-b-qnty1  = sum1-b-qnty1  + temp-str.b-qnty1
    sum1-a-stoim  = sum1-a-stoim  + temp-str.a-stoim
    sum1-b-stoim  = sum1-b-stoim  + temp-str.b-stoim
    sum1-ubl      = sum1-ubl      + temp-str.ubl
    sum2-a-qnty   = sum2-a-qnty   + temp-str.a-qnty
    sum2-b-qnty   = sum2-b-qnty   + temp-str.b-qnty
    sum2-a-qnty1  = sum2-a-qnty1  + temp-str.a-qnty1
    sum2-b-qnty1  = sum2-b-qnty1  + temp-str.b-qnty1
    sum2-a-stoim  = sum2-a-stoim  + temp-str.a-stoim
    sum2-b-stoim  = sum2-b-stoim  + temp-str.b-stoim
    sum2-ubl      = sum2-ubl      + temp-str.ubl
  .
  FullNameGds = temp-str.gds-name .
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
  assign j = 0.
  DO WHILE gds-str2 <> "" :
    assign gds-str = gds-str2.
    gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
    assign j = j + 1.
  END.
  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.
  gds-str1 = breakstr(FullNameGds, 40, input-output  gds-str1, input-output gds-str2).
if temp-str.aa-qnty <> 0 then do:
    if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym8 sym11  sym15 UBL-v
    temp-str.a-qnty1 temp-str.b-qnty1
    sym7     temp-str.price-befor
    sym8     temp-str.b-qnty @ temp-str.a-qnty
    sym9    temp-str.b-qnty
    sym10  with FRAME sl-gold.
  DOWN stream Out-Stream 1 with FRAME sl-gold .
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym8 sym11  sym15 UBL-v
    temp-str.a-qnty1 temp-str.b-qnty1
    sym7     temp-str.price-befor
    sym8     temp-str.aa-qnty @ temp-str.a-qnty
    sym9    0.00 @ temp-str.b-qnty
    sym10  with FRAME sl-gold.
  DOWN stream Out-Stream 1 with FRAME sl-gold .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.bb-price
            , input temp-str.b-qnty
            , input temp-str.bb-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price
            , input temp-str.aa-qnty
            , input temp-str.aa-stoim
            , input 0.00
            , input 0.00
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame sl-gold .
      DOWN STREAM Out-Stream 1 with FRAME sl-gold .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
          sym10
        with FRAME sl-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME sl-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME sl-gold .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(196)" SKIP.
end.
end.
else do:
if p-grp = "no" then do:
  display stream Out-Stream
    sym1     num-ln @ Lines_Counter
    sym2     temp-str.artic
    sym3     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then gds-str1         else temp-str.gds-name) @ temp-str.gds-name
    sym4     (if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then temp-str.tb-code else temp-str.b-code)   @ temp-str.b-code
    sym5     temp-str.OKEI
    sym6     temp-str.unit-base
    sym14 temp-str.UBL
    sym8 sym11  sym15 UBL-v
    temp-str.a-qnty1 temp-str.b-qnty1
    sym7    temp-str.price-befor
    sym8    temp-str.a-qnty
    sym9     temp-str.a-stoim
    sym9    temp-str.b-qnty
    sym12    temp-str.b-stoim
    sym10  with FRAME sl-gold.
  DOWN stream Out-Stream 1 with FRAME sl-gold .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-line-data in this-procedure (
            input num-ln
            , input temp-str.artic + " ":U
                + ( if rep-tipe = "invent-gold"
                    or rep-tipe = "sl-gold"
                    then gds-str1
                    else temp-str.gds-name )
            , input string( if rep-tipe = "invent-gold"
                            or rep-tipe = "sl-gold"
                            then temp-str.tb-code
                            else temp-str.b-code )
            , input temp-str.unit-base
            , input temp-str.OKEI
            , input temp-str.Price-after
            , input temp-str.a-qnty
            , input temp-str.a-stoim
            , input temp-str.b-qnty
            , input temp-str.b-stoim
        ).
    end.
  if rep-tipe = "invent-gold" OR rep-tipe = "sl-gold" then DO:
    DO WHILE gds-str2 <> "" :
      assign gds-str = gds-str2.
      gds-str1 = breakstr(gds-str, 40, input-output gds-str1, input-output gds-str2).
      DISPLAY STREAM Out-Stream gds-str1 @ temp-str.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym10  with frame sl-gold .
      DOWN STREAM Out-Stream 1 with FRAME sl-gold .
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input gds-str1
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
            ).
        end.
    END.
  END.
  if PrintScale and temp-str.empty-scale = no THEN DO :
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
        and buf_gds-dtl.artic     = temp-str.artic
        and buf_gds-dtl.prod-type = temp-str.prod-type
        and buf_gds-dtl.prod-code = temp-str.prod-code
      :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  temp-str.gds-code
  ,input  buf_gds-dtl.prt-code
  ,output b-code
  ) no-error .
      if error-status :error then do:
        message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода признака" skip  "Код товара" temp-str.gds-code skip  "Код признака" buf_gds-dtl.prt-code skip
        view-as alert-box error .
      end.
      find first buf_gds-prt where buf_gds-prt.node-code  = buf_gds-dtl.prt-code no-lock no-error .
      assign qnty = buf_gds-dtl.doc-qnty .
      if not CostPrice then do:
        if PrintRubl then assign sum = buf_gds-dtl.price-rubl .
        else              assign sum = buf_gds-dtl.price-base .
      end.
      else assign sum = if temp-str.a-stoim <> 0  or temp-str.a-qnty <> 0 then temp-str.a-stoim / temp-str.a-qnty else temp-str.b-stoim / temp-str.b-qnty .
      if qnty >= 0 then do:
        display stream Out-Stream
          sym1     sym2     sym3     ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.a-qnty
              sym10
        with FRAME sl-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( "  /":U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
                , input "":U
                , input "":U
            ).
        end.
      end.
      else do:
        assign qnty = - qnty .
        display stream Out-Stream
          sym1     sym2     sym3  ('  /'+ buf_gds-prt.f-name)  @ temp-str.gds-name
          sym4     if rep-tipe = "sl-gold" then "" else string(b-code) @ temp-str.b-code
          sym5     sym6
          sym7     qnty @ temp-str.b-qnty
               sym10
        with FRAME sl-gold.
        if rep-tipe begins "invent"
        and p-grp = "no"
        then do:
            run inv3xl-write-line-data in this-procedure (
                  input 0
                , input ( '  /':U + buf_gds-prt.f-name )
                , input ( if rep-tipe = "sl-gold":U
                          then "":U
                          else string( b-code ) )
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input string( qnty )
                , input string( sum * qnty )
            ).
        end.
      end.
      DOWN stream Out-Stream 1 with FRAME sl-gold .
    end.
  end.
  if print-graft = false THEN  Put stream Out-Stream LineBuf format "X(196)" SKIP.
end.
end.
   End.
    End CASE.
  end.
end procedure.
procedure print-grp-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10  sym8
          sum-a-qnty   @ temp-str.a-qnty
          sum-b-qnty   @ temp-str.b-qnty
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(185)" SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13
          sym14 sum-ubl @ temp-str.UBL
          sum-a-qnty   @ temp-str.a-qnty
          sum-a-stoim  @ temp-str.a-stoim
          sum-b-qnty   @ temp-str.b-qnty
          sum-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(162)" SKIP.
      End.
    End.
    assign
      sum-a-qnty  = 0
      sum-b-qnty  = 0
      sum-a-qnty1 = 0
      sum-b-qnty1 = 0
      sum-a-stoim = 0
      sum-b-stoim = 0
      sum-ubl     = 0
    .
  end.
end procedure.
procedure print-prod-itog :
  do on error undo, return error return-value :
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-str.prod-type
        and buf_clients.obj-code = temp-str.prod-code
    .
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym9   sym10  sym8
          sum2-a-qnty   @ temp-str.a-qnty
          sum2-b-qnty   @ temp-str.b-qnty
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(185)" SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum2-ubl     @ temp-str.UBL
          sum2-a-qnty   @ temp-str.a-qnty
          sum2-a-stoim  @ temp-str.a-stoim
          sum2-b-qnty   @ temp-str.b-qnty
          sum2-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = false THEN Put stream Out-Stream LineBuf format "X(162)" SKIP.
      End.
    End.
    assign
      sum2-a-qnty  = 0
      sum2-b-qnty  = 0
      sum2-a-qnty1 = 0
      sum2-b-qnty1 = 0
      sum2-a-stoim = 0
      sum2-b-stoim = 0
      sum2-ubl     = 0
    .
  end.
end procedure.
procedure print-all-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10  sym8
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-b-qnty   @ temp-str.b-qnty
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        Put stream Out-Stream LineBuf format "X(185)" SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
          sum1-ubl      @ temp-str.ubl
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        Put stream Out-Stream LineBuf format "X(162)" SKIP.
      End.
    End.
  end.
end procedure.
procedure PrintTitul :
    define variable v-organization  as character    no-undo.
    define variable v-object        as character    no-undo.
do
on error undo, return error return-value  :
    case clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
    define variable v-outprncd    as character no-undo.
    define variable v-par-type    as character no-undo.
    define variable v-buh-sum-str as character no-undo .
    define variable v-buh-sum     as decimal   no-undo .
    define variable v-str         as character no-undo .
    define variable v-abbr-str    as character no-undo .
    define variable v-doc-date    as character no-undo .
    define variable v-fact-date   as character no-undo .
    define variable v-frame-str   as character no-undo .
    define variable v-prikaz-num  as character no-undo .
    define variable v-prikaz-date as character no-undo .
    run gbl/conf-rd.p ("outprncd", "":U, "":U, 0, "":U, "":U, "":U, no, output v-outprncd, output v-par-type) no-error.
    if v-outprncd = "yes" then
    do:
      assign
        v-organization = string( "ИНН " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")" + t-addres + t-phone)
        v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )
      .
    end.
    else do:
      assign
        v-organization = string( "ИНН " + t-inn + " " + CAPS( clients.obj-name ) + t-addres + t-phone)
        v-object       =  CAPS( This_Object.obj-name )
      .
    end.
    assign
      v-buh-sum-str = 'К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы в бухгалтерию и все товарно-материальные ценности, поступившие на мою ( нашу ) отвественность, оприходованы, а выбывшие списаны в расход.'
    .
    if v-doc-date = ""
    then do:
      for each temp-str
      :
        assign
          v-buh-sum = v-buh-sum + temp-str.b-stoim
        .
      end.
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input v-buh-sum, output v-str, output v-abbr-str ). end.
                         else do: run rep/wp.p     ( input parParentProc, input v-buh-sum, output v-str, output v-abbr-str ). end.
      assign
        v-buh-sum-str = v-buh-sum-str + " Остаток товара на начало инвентаризации составляет сумму: " + v-str
        v-object      = v-object + ", " + v-torgconf-self-obj-addres
      .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-inv-date':U ,
                       output v-doc-date ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-prikaz-number':U ,
                       output v-prikaz-num ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-prikaz-date':U ,
                       output v-prikaz-date ,
                       output p-type ) no-error .
    v-prikaz-date = replace(v-prikaz-date,".","") .
    v-doc-date = replace(v-doc-date,".","") .
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-cell-data in this-procedure (
            input "h_organization":U
            , input v-organization
        ).
        run inv3xl-write-cell-data in this-procedure (
            input "h_object":U
            , input v-object
        ).
        run inv3xl-write-cell-data in this-procedure (
            input "h_docCode":U
            , input tdoc-code
        ).
        run inv3xl-write-cell-data in this-procedure (
            input "h_docDate":U
            , input string( tdoc-date, "99/99/9999")
        ).
          run inv3xl-write-cell-data in this-procedure (
              input "h_tbl_prikaz_num":U
              , input string(v-prikaz-num)
          ).
          run inv3xl-write-cell-data in this-procedure (
              input "h_tbl_prikaz_date":U
              , input string( v-prikaz-date, "99/99/9999")
          ).
          run inv3xl-write-cell-data in this-procedure (
              input "h_tbl_startDate":U
              , input string( if v-doc-date <> "" then string(v-doc-date, "99/99/9999") else string(buf_trn-doc.doc-date, "99/99/9999"))
          ).
        run inv3xl-write-cell-data in this-procedure (
            input "h_tbl_endDate":U
            , input ( if buf_trn-doc.status_ = 'факт':U then string( tdoc-date, "99/99/9999") else "":U )
        ).
    end.
    if v-doc-date = ""
    then do:
      assign
        v-doc-date = string(buf_trn-doc.doc-date,"99999999")
        v-frame-str = "в расход."
      .
    end.
    if rep-tipe begins "invent"
    then do:
      PUT STREAM Out-Stream
        space(3) "Унифицированная форма N ИНВ-3" format "X(30)"  at 169 skip
        space(3) "Утверждена постановлением Госкомстата РФ" format "X(40)"  at 158 skip
        space(3) "от 18 августа 1998 г. N 88" format "X(26)"  at 172 skip
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 'код':U AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317004" "|" AT 198 skip
        space(5) v-organization format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) v-object format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 v-prikaz-num "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 v-prikaz-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 v-doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180  tdoc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(54) string( "ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> 'факт':U then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(79) Line format "X(33)" skip
        space(54) "товарно-материальных ценностей" format "X(30)" skip(1)
        space(5) UndLine format "X(191)" " ," skip
        space(52) "вид товарно-материальных ценностей" format "X(34)" skip(1)
        space(5) string( "находящиеся " + UndLine ) format "X(193)" skip
        space(52) "в собственности организации, полученные для переработки" format "X(55)" skip(2)
        space(60) "РАСПИСКА" format "X(8)" skip(2)
        space(10) "К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы" format "X(188)" skip
        space(5) "в бухгалтерию и все  товарно-материальные ценности,  поступившие  на  мою (нашу) ответственность,  оприходованы,  а выбывшие  списаны" format "X(193)" SKIP
        space(5) v-frame-str format "X(193)" SKIP(1)
        space(5) "Материально ответственное (ые) лицо (а): " format "X(41)"
                       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        space(5) "Произведено снятие фактических остатков ценностей по состоянию на <<       >> _________________        г." format "X(193)" SKIP(4)
      .
    end.
    else do:
    PUT STREAM Out-Stream
        space(3) "Унифицированная форма N ИНВ-19" format "X(30)"  at 168 skip
        space(3) "Утверждена постановлением Госкомстата РФ" format "X(40)"  at 158 skip
        space(3) "от 18 августа 1998 г. N 88" format "X(26)"  at 172 skip
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 'код':U AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317017" "|" AT 198 skip
        space(5) v-organization format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) v-object format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 v-prikaz-num "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 buf_trn-doc.doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180
                       (if buf_trn-doc.status_ <> 'факт':U then tdoc-date else ?) format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(56) string( "СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> 'факт':U then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(79) Line format "X(33)" skip
        space(40) "результатов инвентаризации товарно-материальных ценностей" format "X(130)" skip(2)
        space(52) "Проведена инвентаризация фактического наличия ценностей, находящихся на ответственном хранении" format "X(134)" skip(3)
         UndLine format "X(25)" AT 10 UndLine format "X(90)" at 50 SKIP
        "должность" format "X(25)" AT 10 "фамилия,имя,отчество" format "X(50)"   AT 50 SKIP(1)
        UndLine format "X(25)" AT 10 UndLine format "X(90)" at 50 SKIP
        "должность" format "X(25)" AT 10 "фамилия,имя,отчество" format "X(50)"  AT 50 SKIP(1)
        space(5) "По состоянию на <<       >> _________________        г." format "X(193)" SKIP(2)
        space(5) "При инвентаризации установлено следующее :" SKIP
      .
    end.
    PAGE stream Out-Stream.
end.
end procedure.
procedure PrintPodval :
  do on error undo, return error return-value  :
    run rep/wp-qnty.p ( num-ln , output PropisCount).
    if PropisCount = '' Then PropisCount = 'Ноль'.
    if rep-tipe begins "invent"  THEN DO:
      define variable v-pos-agent as character no-undo .
      define variable v-fio-agent as character no-undo .
      define variable v-pos-player1 as character no-undo .
      define variable v-fio-player1 as character no-undo .
      define variable v-pos-player2 as character no-undo .
      define variable v-fio-player2 as character no-undo .
      define variable v-pos-player3 as character no-undo .
      define variable v-fio-player3 as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-agent':U ,
                       output v-fio-agent ,
                       output p-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-agent':U ,
                       output v-pos-agent ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player1':U ,
                       output v-fio-player1 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player1':U ,
                       output v-pos-player1 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player2':U ,
                       output v-fio-player2 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player2':U ,
                       output v-pos-player2 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-fio-player3':U ,
                       output v-fio-player3 ,
                       output p-type ) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdatinv-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-pos-player3':U ,
                       output v-pos-player3 ,
                       output p-type ) no-error .
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_fio_agent":U
        , input v-fio-agent
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_pos_agent":U
        , input v-pos-agent
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_fio_player1":U
        , input v-fio-player1
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_pos_player1":U
        , input v-pos-player1
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_fio_player2":U
        , input v-fio-player2
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_pos_player2":U
        , input v-pos-player2
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_fio_player3":U
        , input v-fio-player3
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_pos_player3":U
        , input v-pos-player3
        ).
      PAGE stream Out-Stream.
      HIDE stream Out-Stream FRAME BottomFrame .
      HIDE stream Out-Stream FRAME BottomFrame2 .
      run rep/wp-qnty.p ( sum1-a-qnty , output PropisQnty).
      if PropisQnty = '' Then PropisQnty = 'Ноль'.
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input sum1-a-stoim, output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input sum1-a-stoim, output PropisSumall, output abbr ). end.
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-cell-data in this-procedure (
              input "f_itNumStr":U
            , input PropisCount
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "f_itQntyFactStr":U
            , input PropisQnty
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "it_qntyFact":U
            , input string( sum1-a-qnty )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "it_qntyBuh":U
            , input string( sum1-b-qnty )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "it_sumBuh":U
            , input string( sum1-b-stoim )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_pos_agent":U
            , input string( v-pos-agent )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_fio_agent":U
            , input string( v-fio-agent )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_pos_player1":U
            , input string( v-pos-player1 )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_fio_player1":U
            , input string( v-fio-player1 )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_pos_player2":U
            , input string( v-pos-player2 )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_fio_player2":U
            , input string( v-fio-player2 )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_pos_player3":U
            , input string( v-pos-player3 )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input "itp_s_fio_player3":U
            , input string( v-fio-player3 )
        ).
    end.
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_num":U
        , input string( PropisCount )
        ).
      run inv3xl-write-cell-data in this-procedure (
        input "itp_s_qntyFact":U
        , input string( PropisQnty )
        ).
      PUT  STREAM Out-Stream
              "Итого по описи :" Skip
                "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
                "б) общее количество единиц фактически: " + string( sum1-a-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
              "   Все цены, подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей проверены." SKIP
              "Председатель комиссии:: " format "X(25)" AT 10 SKIP
              string(v-pos-agent) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-agent) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "Состав комиссии: " format "X(25)" AT 10 SKIP
              string(v-pos-player1) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-player1) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              string(v-pos-player2) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-player2) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              string(v-pos-player3) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-player3) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 skip .
      if PgNPP = 0 then
      do:
        PUT  STREAM Out-Stream
          "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № 0 по № " + string(PgNPP) format "x(179)" skip.
      end.
      else
      do:
        PUT  STREAM Out-Stream
          "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № 1 по № " + string(PgNPP) format "x(179)" skip.
      end.
       PUT  STREAM Out-Stream
                 "комиссией проверены в натуре в моем (нашем) личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной " SKIP
          "комиссии не имею (не имеем). Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." SKIP(1)
              "   Лицо(а), ответственное(ые) за сохранность товарно-материальных ценностей : " SKIP(1)
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "<<       >> _________________        г. "   SKIP(1)
              "Указанные в настоящей описи данные и расчеты проверил"
                  LineBuf format "X(25)" AT 10 LineBuf format "X(25)"   AT 40 LineBuf format "X(50)"               AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "<<       >> _________________        г. " SKIP
      .
    End.
    ELSE DO:
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
      run rep/wp-qnty.p ( (sum1-a-qnty - sum1-b-qnty), output PropisQnty).
      if PropisQnty  = '' Then PropisQnty = 'Ноль'.
      PUT  STREAM Out-Stream
           "Итого по ведомости :" Skip
           "а) количество порядковых номеров: " + string(num-ln) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
           "б) общее количество единиц (излишки - недостача): " + string( sum1-a-qnty - sum1-b-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
           "в) на сумму (излишки - недостача) : " + trim(string((sum1-a-stoim - sum1-b-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + PropisSumall + ")"  format "x(179)"    at 18 SKIP(1)
           "С результатами сличения ознакомлен : "  Skip "        Бухгалтер" LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1) "Материально ответственное(ые)  лицо(а)"  Skip
           LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
           LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1)
      .
    End.
  end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure.
procedure Check-Doc-Sum :
  do  on error undo, return error return-value  :
    define variable v-attr-value as character no-undo .
    define variable v-attr-type as character no-undo .
    define variable ask as logical   no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if buf_trn-doc.status_ = 'факт':U then do:
      case rep-tipe:
        when "invent" then do:
          if lookup( 'bd':U, v-attr-value ) = 0 or
             lookup( 'ad':U, v-attr-value ) = 0  then run utl/uaddsum.p (buf_trn-doc.doc-code, no, no, no) no-error  .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        end.
        when "invent-gold" THEN DO:
          if lookup( 'bd':U, v-attr-value ) = 0 or
             lookup( 'ad':U, v-attr-value ) = 0  or
             lookup( 'bcd':U, v-attr-value ) = 0  or
             lookup( 'acd':U, v-attr-value ) = 0 then run utl/uaddsum.p (buf_trn-doc.doc-code, yes, no, yes) no-error .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        End.
        when  "sl"  or when  "sl-gold" THEN DO:
          if lookup( 'gen':U, v-attr-value ) = 0 or
             lookup( 'wst':U, v-attr-value ) = 0  then run utl/uaddsum.p (buf_trn-doc.doc-code, yes, yes, no) no-error .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        End.
      End.
    end.
    else
      case rep-tipe:
        when "invent" or when "invent-gold" then do:
          if lookup( 'bd':U, v-attr-value ) = 0 then do:
            message "Не рассчитаны данные до начала инвентаризации!" view-as alert-box.
            undo, return error .
          end.
          if lookup( 'ad':U, v-attr-value ) = 0  then do:
            if no-vat then do:
              message "Не рассчитаны данные после инвентаризации!" view-as alert-box.
              undo, return error .
            end.
            else assign is-after = no .
          end.
          if rep-tipe = "invent-gold" then do:
            if lookup( 'bcd':U, v-attr-value ) = 0 then do:
              message "Не рассчитано кол-во в един. изм. поставщика до начала инвентаризации!" view-as alert-box.
              undo, return error .
            end.
            if lookup( 'acd':U, v-attr-value ) = 0 then assign is-after-cli = no .
          end.
        End.
        when  "sl"  or when  "sl-gold" THEN DO:
          if lookup( 'wst':U, v-attr-value ) = 0  then do:
            message "Не рассчитаны нормы естественной убыли! Напечатать документ без их учета?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE ask.
            if ask then assign is-wastage = no .
            else undo, return error .
          end.
          if lookup( 'gen':U, v-attr-value ) = 0 then assign is-general = no .
        End.
      End.
  end.
end procedure.
