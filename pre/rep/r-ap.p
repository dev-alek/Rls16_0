block-level on error undo, throw.
define input parameter parParentProc  as widget-handle no-undo.
define input parameter p-recipe-recid as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ap.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ap.p $":U .
define variable vss-description as character no-undo init "АКТ проработки".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
do
on error undo, return error return-value
:
define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_recipe for ub.recipe .
define buffer buf_recipe-develop for ub.recipe-develop.
define variable   sort-name   as logical no-undo.
define variable   sort-gr     as logical no-undo.
define variable   print-graft as logical no-undo.
define variable   summ as decimal no-undo .
define variable   fact-order-1 as decimal no-undo .
define variable   fact-order-2 as decimal no-undo .
sort-gr     = true  .
sort-name   = false .
print-graft = true  .
define variable sort-group as logical   no-undo .
if sort-gr
    then assign sort-group = yes .
    else assign sort-group = no .
define variable name-raz as character no-undo .
define variable temp-doc-code  as character no-undo .
define variable temp-sum-fact  as decimal   no-undo .
define variable temp-fact-date as date      no-undo .
define variable temp-sum-cost  as decimal   no-undo .
define variable sum-crsa  as decimal   no-undo .
define variable sum-cost  as decimal   no-undo .
define temp-table temp-str no-undo
field n           as INT format ">>>>9"
field gds-name     as char format "X(25)"
field gds-code     as integer  format ">>>>>>>>9"
field artic         as character
field prod-type     as character
field prod-code     as int
field EDIZM         as character
field BRUTTO        as decimal  format ">>>>>9.<<<"
field NETTO         as decimal  format ">>>>>9.<<<"
field BRUTTO1        as decimal  format ">>>>>9.<<<"
field NETTO1         as decimal  format ">>>>>9.<<<"
field BRUTTO2        as decimal  format ">>>>>9.<<<"
field NETTO2         as decimal  format ">>>>>9.<<<"
field BRUTTO3        as decimal  format ">>>>>9.<<<"
field NETTO3         as decimal  format ">>>>>9.<<<"
index pi  gds-code  n
.
define stream  OutStream  .
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define variable n-recipe-code  as character no-undo .
define variable n-porc as integer no-undo .
define variable num-re as character no-undo .
define variable qnt-delta as decimal no-undo .
define buffer buf_clients for  ub.clients .
define buffer This_Object for  ub.clients .
define variable qnty as decimal   no-undo .
define variable sum  as decimal   no-undo .
define variable crsa-rubl-start    as decimal no-undo .
define variable crsa-base-start    as decimal no-undo .
define variable cost-rubl-start    as decimal no-undo .
define variable cost-base-start    as decimal no-undo .
define variable crsa-rubl-end      as decimal no-undo .
define variable crsa-base-end      as decimal no-undo .
define variable cost-rubl-end      as decimal no-undo .
define variable cost-base-end      as decimal no-undo .
define variable num-ln as integer   no-undo .
define variable FullNameGds as character no-undo .
define variable gds-str as char no-undo.
define variable gds-str1 as char no-undo.
define variable gds-str2 as char no-undo.
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .
define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.
define variable     Lines_Counter as   int  init 0  no-undo.
define variable     Tmp_Counter   as   int  init 0  no-undo.
define variable     tdoc-date     like fbr-pln.doc-date no-undo.
define variable     tdoc-code     like fbr-pln.doc-code no-undo.
define variable  abbr              as  char no-undo.
define variable  pp-a              as  char no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .
define variable vv8 as character no-undo .
define variable vv9 as character no-undo .
define variable vv10 as character no-undo .
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
define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .
DEFINE FRAME plan-menu
    sym1                format "X(1)"        space(0)
    temp-str.n          format ">>>>>>>9"        space(0)
    sym2                format "X(1)"        space(0)
    temp-str.gds-name   format "X(25)"       space(0)
    Sym3                format "X(1)"        space(0)
    temp-str.edizm      format "X(7)"        space(0)
    Sym4                format "X(1)"        space(0)
    temp-str.brutto1    format ">>>>>9.<<"    space(0)
    Sym5                format "X(1)"        space(0)
    temp-str.netto1     format ">>>>>9.<<"   space(0)
    Sym6                format "X(1)"        space(0)
    temp-str.brutto2    format ">>>>>9.<<"   space(0)
    Sym7                format "X(1)"        space(0)
    temp-str.netto2     format ">>>>>9.<<"    space(0)
    Sym8                format "X(1)"        space(0)
    temp-str.brutto3    format ">>>>>9.<<"   space(0)
    Sym9                format "X(1)"        space(0)
    temp-str.netto3     format ">>>>>9.<<"    space(0)
    Sym10               format "X(1)"        space(0)
    temp-str.brutto     format ">>>>>9.<<"   space(0)
    Sym11               format "X(1)"        space(0)
    temp-str.netto      format ">>>>>9.<<"    space(0)
    Sym12               format "X(1)"        space(0)
  HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    Line format "X(150)" AT 1
    with width 180 down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.
  if session:set-wait-state("compiler") then.
output STREAM OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
  define variable v-prn0 as character no-undo .
  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .
define variable v-is-base as logical no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-is-base
  )  .
if v-is-base = true then do:
    assign    PP-a = "баз.вал" .
end.
else do:
   assign     PP-a = "руб".
end.
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
v-ind = 0    .
FORM with frame plan-menu .
vv0 = "+--------+-------------------------+----------------------------------------------------------------------+-------------------+" .
vv1 = ":   №    :         Продукт         : Ед.изм. : Брутто1 : Нетто1  : Брутто2 : Нетто2  :  Брутто3 : Нетто3  : Брутто  : Нетто   :" .
vv2 = "+--------+-------------------------+---------+---------+---------+---------+---------+----------+---------+---------+---------+" .
vv3 = ":   1    :             2           :    3    :    4    :   5     :   6     :    7    :    8     :    9    :   10    :   11    :" .
vv4 = "+--------+-------------------------+---------+---------+---------+---------+---------+----------+---------+---------+---------+" .
define variable v-gds-name    as character no-undo .
define variable v-recipe-code as character no-undo .
define variable v-recipe-N    as character no-undo .
define variable v-obj-type    as character no-undo .
define variable v-obj-code    as integer   no-undo .
find first buf_recipe no-lock where recid(buf_recipe)  = p-recipe-recid.
  assign
    v-obj-type    = buf_recipe.obj-type
    v-obj-code    = buf_recipe.obj-code
    v-gds-name    = buf_recipe.recipe-name
    v-recipe-code = buf_recipe.recipe-code
    v-recipe-n    = buf_recipe.recipe-ref-num
    .
  if v-obj-code = 0 then
  assign
    v-obj-type =  v-cntxt-obj-type
    v-obj-code =  v-cntxt-obj-code
  .
  find this_object  where this_object.obj-type = v-obj-type  and
                          this_object.obj-code = v-obj-code  no-lock .
  find clients      where clients.obj-type     = 'орг':U      and
                          clients.obj-code     = v-cntxt-host-code-obj no-lock .
  run PrintTitul in this-procedure .
  for each temp-str
      on error undo, return error :
      delete temp-str .
  end.
  run make-tt  in this-procedure .
    for each temp-str :
         run print-line .
    end.
  run print-all-itog in this-procedure .
  run on-same-page in this-procedure (input 4) .
  run PrintPodval in this-procedure .
HIDE STREAM OutStream FRAME plan-menu .
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
 define variable v-user-action as character no-undo .
 define variable v-printed as logical   no-undo .
 define variable DisabledOptions as integer   no-undo .
 DisabledOptions = 8 .
 run gbl/prnfilen.w
   (input  ""
   ,input  DisabledOptions
   ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
   ,input  7
   ,output v-user-action
   ,output v-printed
   ) .
end.
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
    .
  if line-counter( OutStream ) + 2 > page-size( OutStream ) then page stream OutStream.
  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .
  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .
  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.
PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)"     space(0)
   num-ln            format ">>>>>>>9" space(0)
    sym2                format "X(1)"     space(0)
    temp-str.gds-name   format "X(25)"    space(0)
    Sym3                format "X(1)"     space(0)
    temp-str.edizm      format "X(9)"     space(0)
    Sym4                format "X(1)"     space(0)
    string(temp-str.brutto1)  format  "x(9)"  space(0)
    Sym5               format "X(1)" space(0)
    string(temp-str.netto1  )  format  "x(9)"  space(0)
    Sym6               format "X(1)" space(0)
    string(temp-str.brutto2)  format  "x(9)"  space(0)
    Sym7               format "X(1)" space(0)
    string(temp-str.netto2 )  format  "x(9)"  space(0)
    Sym8               format "X(1)" space(0)
    string(temp-str.brutto3)  format  "x(10)"  space(0)
    Sym9               format "X(1)" space(0)
    string(temp-str.netto3 )  format  "x(9)"  space(0)
    Sym10              format "X(1)" space(0)
    string(temp-str.brutto )  format  "x(9)"  space(0)
    Sym11              format "X(1)" space(0)
    string(temp-str.netto )  format  "x(9)"  space(0)
    Sym12              format "X(1)" space(0)
    skip
.
  end.
end procedure.
procedure print-all-itog :
end procedure.
procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .
PUT STREAM OutStream UNFORMATTED
                                                                                               skip
space(1) string( CAPS(     clients.obj-name ))                                                 skip
space(1) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )    skip
space(1)                                                                                       skip
.
PUT STREAM OutStream
skip "Название рецепта : " + CAPS( buf_recipe.recipe-name )                                    format "x(120)"
skip "Номер рецепта    : " +  string( buf_recipe.recipe-code)                                   format "x(60)"
skip "Номер блюда по сборнику рецептур : " + string ( buf_recipe.recipe-ref-num )             format "x(60)"
skip
.
 PUT STREAM OutStream UNFORMATTED
    space(50) string( " АКТ ПРОРАБОТКИ "   )           skip
                      "УТВЕРЖДАЮ"              format "X(9)"  AT 120  skip
                      "______________________" format "X(20)" AT 120  skip
                      "______________________" format "X(20)" AT 120 "/___________________/"
                      "подпись"                               AT 120 "            расшифровка подписи"
                      skip
      .
 PUT STREAM OutStream UNFORMATTED
     "Дата составления " + cur-time-date()   at 120 skip   .
PUT STREAM OutStream
  vv0 format "x(180)" skip
  vv1 format "x(180)"  skip
  vv2 format "x(180)"  skip
  vv3 format "x(180)"  skip
  vv4 format "x(180)"  skip
  .
define variable v-red   as integer no-undo .
define variable v-green as integer no-undo .
define variable v-blue  as integer no-undo .
v-red   = 16.
v-green = 48.
v-blue  = 15.
  end.
end procedure.
procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .
  PUT  STREAM OutStream
        Line format "X(127)" AT 1 skip (2)
      " Заведующий производством _______________________ " skip
      " Калькуляцию составил     _______________________ " skip
      .
  end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure.
procedure make-tt :
  do
  on error undo, return error return-value
  :
  define buffer buf_goods for ub.goods .
  define buffer buf_units for ub.units .
define variable iii as integer no-undo .
define variable v-max-col as integer init 3 no-undo .
define variable v-i-col as integer init 0 no-undo .
for each buf_recipe-develop no-lock where
         buf_recipe-develop.recipe-code = buf_recipe.recipe-code break by buf_recipe-develop.doc-code
    on error undo, return error :
    iii = iii + 1.
     if first-of (buf_recipe-develop.doc-code) then do:
        v-i-col = v-i-col + 1 .
        if v-i-col >= 4 then return.
     end.
        find first temp-str where
              temp-str.gds-code  = buf_recipe-develop.gds-code  no-error .
         if not available temp-str then do:
            find first buf_goods no-lock where
                       buf_goods.gds-code  = buf_recipe-develop.gds-code .
             create temp-str.
             assign
                temp-str.n = iii
                temp-str.gds-code = buf_recipe-develop.gds-code
                temp-str.gds-name = buf_goods.gds-name
                temp-str.edizm    = buf_goods.unit-base
             .
         end.
         case v-i-col :
          when 1 then do:
              temp-str.brutto1 = buf_recipe-develop.brutto-qnty .
              temp-str.netto1  = buf_recipe-develop.qnty .
          end.
          when 2 then do:
              temp-str.brutto2 = buf_recipe-develop.brutto-qnty .
              temp-str.netto2  = buf_recipe-develop.qnty .
          end.
          when 3 then do:
              temp-str.brutto3 = buf_recipe-develop.brutto-qnty .
              temp-str.netto3  = buf_recipe-develop.qnty .
          end.
         end case.
        if v-i-col = 3 then do:
          temp-str.brutto = round ( (temp-str.brutto1 + temp-str.brutto2 + temp-str.brutto3) / 3 , 3 ).
          temp-str.netto  = round( (temp-str.netto1  + temp-str.netto2  + temp-str.netto3 ) / 3 , 3 ).
        end.
end.
  if v-i-col < 3 then do:
    message "Для печати формы необходимо наличие трех Актов проработки !!! "
    view-as alert-box information .
    return error .
  end.
  end.
 end procedure.
