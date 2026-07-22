block-level on error undo, throw.
define input parameter x-store-code like ub.clients.obj-code   no-undo.
define input parameter x-store-type like ub.clients.obj-type   no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define  shared temp-table X-init_obj-list no-undo
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in my-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable vv-exch-rate  as decimal   no-undo .
define variable vv-exch-scale as decimal   no-undo .
define variable v-cntxt-host-name-obj as character no-undo .
if v-cntxt-level = 'object':U then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-cntxt-host-code-obj
  ,output v-cntxt-host-name-obj
  )  .
end.
if v-cntxt-level = 'firm':U then do:
  find first ub.clients no-lock where
             ub.clients.obj-type = 'орг':U and
             ub.clients.obj-code = v-cntxt-host-code-obj no-error .
if error-status :error then v-cntxt-host-name-obj = ? .
   else v-cntxt-host-name-obj = ub.clients.obj-name.
end.
if v-cntxt-level = 'object':U
or v-cntxt-level = 'firm':U
then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  base-code
  ,input  today
  ,output vv-exch-rate
  ,output vv-exch-scale
  ,output base-type
  )  .
end.
run get-report-num in my-handle ( output g#report-num ).
run get-gds-engl in my-handle ( output g#gds-engl ) .
dEF   shared  VAR    Select-Good   as   integer   no-undo.
DEF   shared  VAR    RetClassify   as   char      no-undo.
DEF   shared  VAR    RetSortType   as   char      no-undo.
DEF   shared  VAR    Sums-Only     as   logical   no-undo.
def   shared  var    Fact-order-1  like ub.stk-tot.Fact-order no-undo.
def   shared  var    Fact-order-2  like ub.stk-tot.Fact-order no-undo.
def   shared  var    Cli-art       as character no-undo .
def   shared  var    date1Rash     as date no-undo .
def   shared  var    date2Rash     as date no-undo .
def   shared  var    PostName      as character no-undo .
def   shared  var    xtogobj       as logical no-undo .
def   shared  var    t-in          as logical no-undo .
def   shared  var    RADIO-Anal    as logical no-undo .
def   shared  var    RADPost       as logical no-undo .
def   shared  var    ShowCliPrice  as logical no-undo .
def   shared  var    ShowParts     as logical no-undo .
def   shared  var    ShowCost      as log no-undo.
def   shared  var    ShowSale      as log no-undo.
def   shared  var    Show-Negativ  as log no-undo.
def   shared  var    Show-zero-ost as log no-undo.
DEF   shared  VAR    PayType       as   integer no-undo.
DEF   shared  VAR    Type-stor     as   integer no-undo.
DEF   shared  VAR    xLavel        as   integer no-undo.
def SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.
define temp-table temp-t-post-stk-line no-undo like ub.stk-supp-line
field gds-code          like ub.goods.gds-code
field goods-grp-name    like ub.goods.grp-name
field clients-grp-name  like ub.clients.grp-name
field clients-obj-name like  ub.clients.obj-name
field prod-cli-obj-type like ub.clients.obj-type
field prod-cli-obj-code like ub.clients.obj-code
field prod-cli-obj-name like ub.clients.obj-name
field unit-base         like ub.goods.unit-base
field prt-root          like ub.goods.prt-root
field gds-type          like ub.goods.gds-type
field gds-name          like ub.goods.gds-name
field cont-num          like ub.contract.contract-code
INDEX  pi is UNIQUE  PRIMARY
   obj-type ASCENDING
   obj-code ASCENDING
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING
INDEX pi1
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING
INDEX pi2
   goods-grp-name
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING
INDEX pi3
   clients-grp-name
   cli-type ASCENDING
   cli-code ASCENDING
   artic    ASCENDING
   prod-type  ASCENDING
   prod-code  ASCENDING
   fact-order ASCENDING
INDEX articren
   prod-type ASCENDING
   prod-code ASCENDING
   artic     ASCENDING
   obj-type  ASCENDING
   obj-code  ASCENDING
INDEX fact-order
   obj-type ASCENDING
   obj-code ASCENDING
   fact-order ASCENDING
.
def   shared   var gds-zap-unit-base     like ub.goods.unit-base    no-undo.
def   shared   var gds-zap-prt-root      like ub.goods.prt-root     no-undo .
def   shared   var gds-zap-gds-name      like ub.goods.gds-name     no-undo .
def   shared   var gds-zap-prod-type     like ub.goods.prod-type    no-undo .
def   shared   var gds-zap-prod-code     like ub.goods.prod-code    no-undo .
def   shared   var gds-zap-artic         like ub.goods.artic        no-undo .
def   shared   var gds-post-artic        like ub.ext-artic.ext-artic  no-undo .
def   shared   var gds-zap-b-code        like ub.bar-code.b-code    no-undo .
def   shared   var gds-type              as char no-undo.
def   shared   var gds-zap-type          like ub.goods.gds-type    no-undo .
def   shared   var gds-zap-grp-name      like ub.goods.grp-name    no-undo .
def   shared   var gds-zap-prod-name     like ub.clients.obj-name  no-undo .
def   shared   var gds-zap-price-base    like ub.stk-tot.sum-base  no-undo.
def   shared   var gds-zap-stoim-base    like ub.stk-tot.sum-base  no-undo.
def   shared   var gds-zap-qnty          like ub.stk-tot.fact-qnty no-undo.
def   shared   var gds-zap-Nds           like ub.stk-tot.sum-base  no-undo.
def   shared   var gds-zap-Np            like ub.stk-tot.sum-base  no-undo.
def   shared   var pos-cli-type          like ub.clients.obj-type  no-undo.
def   shared   var pos-cli-code          like ub.clients.obj-code  no-undo.
def   shared   var pos-cli-grp-name      like ub.clients.grp-name  no-undo.
def   shared   var ObjName           as   char  no-undo.
def   shared   var tPrintRubl        as   log   no-undo.
DEF   shared   VAR    Line           as   char        no-undo.
DEF   shared   VAR    old-name       as   char        no-undo.
DEF   shared   VAR    old-n          as   log init true  no-undo.
DEF   shared   VAR    i              as integer init 0  no-undo .
DEF   shared   VAR    Null-fact-order    as decimal init 0  no-undo .
def   shared   stream  OutStream.
def   shared  buffer temp-post-stk-line for  ub.stk-supp-line.
def   shared  buffer temp2-post-stk-line for  ub.stk-supp-line.
def   shared  buffer a-post-stk-line for  ub.stk-supp-line.
def   shared  buffer post-stk-line   for  ub.stk-supp-line.
def   shared  buffer prod-cli        for  ub.clients.
def   shared  buffer post-ot-line    for  ub.ot-supp-line.
def   shared  var    Fact-order-3  like ub.stk-tot.Fact-order no-undo.
def   shared  var    Fact-order-4  like ub.stk-tot.Fact-order no-undo.
def   shared   var F-bonus           as   char  no-undo.
def   shared   var F-price-sale      as   char  no-undo.
def   shared   var F-kassa           as   char  no-undo.
def   shared   var F-bonus-dohod     as   char  no-undo.
def   shared   var F-nacenka         as   char  no-undo.
def   shared  var    v-bonus            as decimal EXTENT 10 format ">>9.99"       no-undo.
def   shared  var    v-price-sale       as decimal EXTENT 10 format ">>>>>>>>9.99" no-undo.
def   shared  var    v-kassa            as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def   shared  var    v-bonus-dohod      as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def   shared  var    v-nacenka          as decimal EXTENT 10 format "->>9.99"       no-undo.
def   shared  var    s-kassa            as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def   shared  var    s-bonus-dohod      as decimal EXTENT 10 format "->>>>>>>>9.99" no-undo.
def   shared  var    s-nacenka          as decimal EXTENT 10 format "->>9.99"       no-undo.
def   shared  var    v-last-page        as integer                                 no-undo.
define  shared temp-table tmp-itog no-undo
field tmp-gds-code           like ub.goods.gds-code
field tmp-artic              like ub.goods.artic
field tmp-gds-name           like ub.goods.gds-name
field tmp-goods-grp-name     like ub.goods.grp-name
field tmp-clients-grp-name   like ub.clients.grp-name
field tmp-fact-order         like ub.stk-tot.Fact-order
field tmp-prod-type          like ub.goods.prod-type
field tmp-prod-code          like ub.goods.prod-code
field tmp-cli-type           like obj-list.obj-type
field tmp-cli-code           like obj-list.obj-code
field tmp-prod-cli-obj-name  like ub.clients.obj-name
field tmp-prod-cli-obj-type  like ub.clients.obj-type
field tmp-prod-cli-obj-code  like ub.clients.obj-code
field bn-col                 as   integer
field bonus                  as   decimal  format ">>9.99"
field sum-kassa              as   decimal  format "->>>>>>>>9.99"
field sum-bonus-dohod        as   decimal  format "->>>>>>>>9.99"
field sum-nacenka            as   decimal  format "->>9.99"
.
define  shared temp-table tmp-cli-gds no-undo
field p-prih              as   decimal  EXTENT 10
field p-rash              as   decimal  EXTENT 10
field p-kassa             as   decimal  EXTENT 10
field p-Inv               as   decimal  EXTENT 10
field p-spis              as   decimal  EXTENT 10
field p-vzvr              as   decimal  EXTENT 10
field p-vzvr-post         as   decimal  EXTENT 10
field cli-code            like obj-list.obj-code
field cli-type            like obj-list.obj-type
field Name                as   character
field obj-code            like obj-list.obj-code
field obj-type            like obj-list.obj-type
.
DEFINE  shared FRAME zapas
        sym1             column-label  ":!:"                            format "x(1)"          space(0)
        gds-zap-b-code   column-label  "Код! !":C10                                            space(0)
        sym2             column-label  ":!:"                            format "x(1)"          space(0)
        gds-zap-artic    column-label  "Артикул! !":C16                 format "X(16)"         space(0)
        sym3             column-label  ":!:"                            format "x(1)"          space(0)
        gds-zap-gds-name column-label  "Название товара! !":C37         format "X(37)"         space(0)
        sym4             column-label  ":!:"                            format "x(1)"          space(0)
        F-bonus          column-label  "Значение!бонуса":C16            format "x(16)"         space(0)
        sym5             column-label  ":!:"                            format "x(1)"          space(0)
        F-price-sale     column-label  "Последняя цена!прихода":C16     format "x(16)"         space(0)
        sym6             column-label  ":!:"                            format "x(1)"          space(0)
        F-kassa          column-label  "Касса!Продажа-возврат":C16      format "x(16)"         space(0)
        sym7             column-label  ":!:"                            format "x(1)"          space(0)
        F-bonus-dohod    column-label  "Валовой!доход от бонуса":C16    format "x(16)"         space(0)
        sym8             column-label  ":!:"                            format "x(1)"          space(0)
        F-nacenka        column-label  "Фактический!% наценки":C16      format "x(16)"         space(0)
        sym9             column-label  ":!:"                            format "x(1)"          space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" ( "РУБ" )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 130 format "X(53)" SKIP
        Line format "X(152)" AT 1
   with width 232 down stream-io use-text NO-BOX.
procedure create-temp-t-post-stk-line :
    define variable str  as char      format "X(60)" no-undo.
    define variable str2 as char      no-undo.
    define variable v-r  as character no-undo init "" .
    define variable i#i  as int       no-undo.
 do
 on error undo, return error return-value
 :
 if available ub.goods and
    available ub.clients and
    available prod-cli then do:
  create temp-t-post-stk-line .
  BUFFER-COPY post-stk-line  TO temp-t-post-stk-line
  assign
    temp-t-post-stk-line.goods-grp-name    = ub.goods.grp-name
    temp-t-post-stk-line.gds-code          = ub.goods.gds-code
    temp-t-post-stk-line.unit-base         = ub.goods.unit-base
    temp-t-post-stk-line.prt-root          = ub.goods.prt-root
    temp-t-post-stk-line.gds-type          = ub.goods.gds-type
    temp-t-post-stk-line.gds-name          = if g#gds-engl then ub.goods.engl-name else ub.goods.gds-name
    temp-t-post-stk-line.clients-grp-name  = ub.clients.grp-name
    temp-t-post-stk-line.clients-obj-name  = ub.clients.obj-name
    temp-t-post-stk-line.prod-cli-obj-name = prod-cli.obj-name
    temp-t-post-stk-line.prod-cli-obj-code = prod-cli.obj-code
    temp-t-post-stk-line.prod-cli-obj-type = prod-cli.obj-type
  .
            if xlavel > 0 then
            do:
                repeat i#i =1 to xlavel:
                    if i#i =1 then str   = entry(1,ub.goods.grp-name, chr(47)) .
                    else
                    do:
                        str2 = entry(i#i,ub.goods.grp-name, chr(47)) no-error.
                        if not error-status:error  and str2 <> "":u then
                            str = str +  chr(47) +  entry(i#i,ub.goods.grp-name, chr(47)) no-error .
                    end.
                end.
                if str <> ? then
                do:
                    temp-t-post-stk-line.goods-grp-name = str + chr(47) .
                end.
            end.
            else
            do :
                temp-t-post-stk-line.goods-grp-name = ub.goods.grp-name.
            end.
        end.
 end.
end procedure.
function excel-format-dec-to-char returns char (input p-dec as decimal ).
  if num-entries(string(p-dec), '.') = 2
    then return( entry(1, string(p-dec), '.') + v-delim + entry(2, string(p-dec), '.')) .
    else return( string(p-dec)) .
end function.
function format-point-to-comma returns char (input orig as char ) .
define variable rtext as character no-undo .
define variable strt as integer no-undo .
define variable leng as integer no-undo .
assign rtext = orig .
repeat:
  strt =  index(rtext,'.').
  if strt = 0 then leave.
  leng = 1.
  substring(rtext,strt,leng,"character") = v-delim .
end.
return rtext.
end function.
function format-excel-text returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substr( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '="'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '="'  + ch  + '"' .
    end.
  return start-text.
end.
function excel-sum returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,2)))) .
end function.
function excel-qnty returns char (input p-dec as decimal ).
  return(format-excel-text(excel-format-dec-to-char(round(p-dec,3)))) .
end function.
function format-excel-text-macr returns char ( input start-text as char ) :
def var  i    as int no-undo.
def var  ch   as char no-undo.
def var  n    as int no-undo.
def var  ipos as int no-undo.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
  n = num-entries(trim(start-text), chr(13)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(13)).
    if ipos > 0 then
      substring( start-text, ipos, 1 ) = ' '.
  end.
  if index( start-text, '"' ) = 0 then
    start-text =  '"'   + trim( start-text) + '"'   .
    else do:
      n = num-entries(trim(start-text), '"') - 1.
      do i = 1 to n :
        ch = ch + entry(i,trim(start-text), '"' ) + '""'.
      end.
      ch = ch + entry(num-entries(trim(start-text), '"'),trim(start-text), '"' ).
      start-text = '"'  + ch  + '"' .
    end.
  n = num-entries(trim(start-text), chr(10)) - 1 .
  do i = 1 to n :
    ipos = index( start-text, chr(10)).
    if ipos > 0 then
      substring( start-text, ipos , 1 ) = ' '.
  end.
    if num-entries(trim(start-text), chr(10)) > 1 then  message num-entries(trim(start-text), chr(10)) start-text.
  return start-text.
end.
FUNCTION n-lavel RETURNS char (INPUT grp-name as char, INPUT lavel# as int ).
define variable  str  as char format "X(60)"  no-undo.
define variable  str2 as char no-undo.
define variable v-r as character no-undo init "" .
define variable  i#i as int no-undo.
STR = "".
repeat i#i =1 to lavel#:
    if i#i =1 then str   = entry(1,grp-name, chr(47)) .
    else do:
        str2 = entry(i#i,grp-name, chr(47)) no-error.
        if not error-status:error  and str2 <> "":u then
               str = str +  chr(47) +  entry(i#i,grp-name, chr(47)) no-error .
        end.
end.
if str <> ? then do:
v-r = str + chr(47) .
end.
RETURN v-r .
END FUNCTION.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define variable ii like i init 0 no-undo .
define variable t#cat-id like stk-line.cat-id no-undo .
define variable t#Sum-type like stk-line.Sum-type no-undo .
define variable t#kol-rec-obj like i init 0  no-undo .
if Show-Negativ then null-fact-order = 0 .
   else  null-fact-order = fact-order-1 .
for each obj-list no-lock :
  t#kol-rec-obj = t#kol-rec-obj + 1.
End.
case type-stor  :
  when 1 then  do:
    Assign
      t#cat-id   = '##':U
      t#sum-type = 'cost':U  .
  end.
  when 2 then do:
    Assign
      t#cat-id   = 'prch':U
      t#sum-type = 'cost':U + 'p':U .
  end.
  when 3 then do:
    Assign
      t#cat-id   = 'cacc':U
      t#sum-type = 'cost':U + 'p':U .
  end.
  when 4 then do:
    Assign
      t#cat-id   = 'stor':U
      t#sum-type = 'cost':U + 'p':U .
  end.
  when 5 then do:
    Assign
      t#cat-id   = 'cons':U
      t#sum-type = 'cost':U + 'p':U .
  end.
End case.
if xTogobj = false  then DO:
  Case Select-Good :
    when 1   then    RUN Run1-0.
    when 2   then    run run2-0.
    when 3  then    run run3-0.
    otherwise do:
        run run45-0.
    end.
  End case.
End.
Else do:
  Case Select-Good :
    when 1  then    RUN Run1.
    when 2  then    run run2.
    when 3 then    run run3.
    otherwise do:
      run run45.
    end.
  End case.
End.
procedure run1 :
CASE RetClassify :
  when "no-classify":U then  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  End.
  when "grp-goods":U  then     DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
    End.
    Else DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
    End.
  End.
  when "prod":U then  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')  )  Then DO : run print-header (1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') )  then do : run print-footer ( 1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  End.
  when "post":U  then       DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.clients-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.clients-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
    End.
    Else DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
    End.
  End.
  when "post/grp-goods":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.clients-grp-name ). end.
               if first-of( temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (2, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  Then DO : run print-footer ( 2 ,temp-t-post-stk-line.goods-grp-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.clients-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
  when "grp-goods/post":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
               if first-of( temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (2, temp-t-post-stk-line.clients-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  Then DO : run print-footer ( 2 ,temp-t-post-stk-line.clients-grp-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
End case.
End procedure.
procedure run2 :
CASE RetClassify :
  when "no-classify":U  then   DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
  when "grp-goods":U then      DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
    END.
    ELSE  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
  .
    END.
  End.
  when "prod":U then  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')  )  Then DO : run print-header (1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') )  then do : run print-footer ( 1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  End.
  when "post":U  then          DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.clients-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.clients-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
    End.
    ELSE  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
  .
    End.
  End.
  when "post/grp-goods":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.clients-grp-name ). end.
               if first-of( temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (2, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  Then DO : run print-footer ( 2 ,temp-t-post-stk-line.goods-grp-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.clients-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
  when "grp-goods/post":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
               if first-of( temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (2, temp-t-post-stk-line.clients-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  Then DO : run print-footer ( 2 ,temp-t-post-stk-line.clients-grp-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
End case.
End procedure.
procedure run3 :
CASE RetClassify :
  when "no-classify":U  then   DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
  when "grp-goods":U then      DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
    End.
    ELSE  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
  .
    End.
  End.
  when "prod":U then  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')  )  Then DO : run print-header (1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') )  then do : run print-footer ( 1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  End.
  when "post":U  then          DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.clients-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.clients-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
    End.
    ELSE  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
  .
    End.
  End.
  when "post/grp-goods":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.clients-grp-name ). end.
               if first-of( temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (2, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  Then DO : run print-footer ( 2 ,temp-t-post-stk-line.goods-grp-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.clients-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
  when "grp-goods/post":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
               if first-of( temp-t-post-stk-line.clients-grp-name  )  Then DO : run print-header (2, temp-t-post-stk-line.clients-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.clients-grp-name )  Then DO : run print-footer ( 2 ,temp-t-post-stk-line.clients-grp-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
End case.
End procedure.
procedure run45 :
CASE RetClassify :
  when "no-classify":U  then   DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
  when "prod":U then  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')')  )  Then DO : run print-header (1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') )  then do : run print-footer ( 1, (temp-t-post-stk-line.prod-cli-obj-name + ' ('+ temp-t-post-stk-line.prod-cli-obj-type + ' ' + string(temp-t-post-stk-line.prod-cli-obj-code) + ')') ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  End.
  when "grp-goods":U then      DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
    End.
    ELSE  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.goods-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
  .
    End.
  End.
  when "post":U  then          DO:
    if xLavel = 0 THEN  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))  )  Then DO : run print-header (1, (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) )  then do : run print-footer ( 1, (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
    End.
    ELSE  DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.clients-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
                      if old-name <> (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))
                                Then DO :
                                if old-n = false then DO: run print-footer (1, old-name ). old-n = true . end.
                                run print-header (1, (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel)) ). old-n = false. end.
                                Assign old-name = (n-lavel(temp-t-post-stk-line.clients-grp-name,xLavel))  .
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
 run print-footer ( 1, old-name ).
  .
    End.
  End.
  when "post/grp-goods":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))
                      By temp-t-post-stk-line.goods-grp-name
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))  )  Then DO : run print-header (1, (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ). end.
               if first-of( temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (2, temp-t-post-stk-line.goods-grp-name ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  Then DO : run print-footer ( 2 ,temp-t-post-stk-line.goods-grp-name). end.
              if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) )  then do : run print-footer ( 1, (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
  when "grp-goods/post":U then DO:
       For each obj-list no-lock :
          find first sheetf where entry(3, sheetf.colformat, chr(4))  = obj-list.obj-name no-error.
          if available sheetf then do:
            run rep/extitle.p ( input sheetf.sheet-num ).
            assign
            Sheetf.Bas-Params = obj-list.obj-name
            .
          end.
         for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
         if t#kol-rec-obj > 1 THEN run print-header (1, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
          For each post-stk-line  no-lock where
                                            post-stk-line.obj-type = obj-list.obj-type and
                                            post-stk-line.obj-code = obj-list.obj-code and
                                            post-stk-line.fact-order >= null-fact-order   and
                                            post-stk-line.fact-order <= fact-order-2   and
                                            post-stk-line.sum-type    = 'cost':U    and
                                            post-stk-line.cat-id      = '##':U
                                            and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                                            ,
                 each ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                                            :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available  temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          For each temp-t-post-stk-line no-lock   ,
                 Last temp-post-stk-line  where
                      temp-post-stk-line.fact-order <= fact-order-2   and
                      temp-post-stk-line.cat-id     =  t#cat-id      and
                      temp-post-stk-line.Sum-type   =  t#sum-type    and
                      temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                      temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                      temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                      temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                      temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code and
                      temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type  and
                      temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                      no-lock
                      on error undo , next
                      break
                      BY
                          temp-t-post-stk-line.goods-grp-name
                      By (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))
                      By ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                      By temp-t-post-stk-line.artic
                      By ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                      By Temp-t-post-stk-line.Fact-order
                     :
               if first-of(  temp-t-post-stk-line.goods-grp-name  )  Then DO : run print-header (1, temp-t-post-stk-line.goods-grp-name ). end.
               if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))  )  Then DO : run print-header (2, (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ). end.
              if NOT(Sums-Only = true ) then DO:
                  if first-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-header ( 3,temp-t-post-stk-line.clients-obj-name). end.
              End.
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                         run display-line .
                                    End.
                  if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) Then DO : run print-footer ( 3 , temp-t-post-stk-line.clients-obj-name). end.
              if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) )  Then DO : run print-footer ( 2 ,(temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code))). end.
              if last-of( temp-t-post-stk-line.goods-grp-name )  then do : run print-footer ( 1, temp-t-post-stk-line.goods-grp-name ). end.
          End.
         if t#kol-rec-obj > 1 THEN run print-footer ( 0, '(' + obj-list.obj-type + ' ' + trim(string(obj-list.obj-code)) + ') ' + obj-list.obj-name).
        if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
        .
       End.
  .
  End.
End case.
End procedure.
procedure Print-Header :
define input parameter N as integer no-undo .
define input parameter Name as char no-undo .
PUT stream  OutStream  UNFORMATTED trim(Name) AT ((N - 1) * 10 ) format "x(100)" skip.
if Make-Excel then  put   stream ForExcel unformatted fill(" " + CHR(9), N - 1) trim(Name) skip.
END PROCEDURE.
procedure run1-0 :
       for each obj-list no-lock :
          for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
          for each post-stk-line  no-lock where
                  post-stk-line.obj-type = obj-list.obj-type and
                  post-stk-line.obj-code = obj-list.obj-code and
                  post-stk-line.fact-order >= null-fact-order   and
                  post-stk-line.fact-order <= fact-order-2   and
                  post-stk-line.sum-type    = 'cost':U    and
                  post-stk-line.cat-id      = '##':U
                  and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                      :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          for each temp-t-post-stk-line no-lock   ,
                 last temp-post-stk-line  where
                                            temp-post-stk-line.fact-order <=  fact-order-2 and
                                            temp-post-stk-line.cat-id     =  t#cat-id                         and
                                            temp-post-stk-line.sum-type   =  t#sum-type                       and
                                            temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                                            temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                                            temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                                            temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                                            temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code    and
                                            temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type    and
                                            temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                                            no-lock
                                            break
                                            by ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                                            by ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                                            by temp-t-post-stk-line.fact-order :
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                       run display-line .
                                    end.
                                    if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) then do :
                                       run tmp-create (temp-t-post-stk-line.cli-code,
                                                       temp-t-post-stk-line.cli-type,
                                                       temp-t-post-stk-line.clients-obj-name,
                                                       obj-list.obj-code,
                                                       obj-list.obj-type ) .
                                       run tmp-clear.
                                    end.
          end.
       end.
       for each tmp-cli-gds no-lock
           break
           by tmp-cli-gds.name
           by (tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) :
           if first-of(tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) then run tmp-clear.
            run tmp-assign.
           if last-of((tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code))) then do:
               run print-footer ( 3 ,tmp-cli-gds.name).
           end.
       end.
End procedure.
procedure run2-0 :
       for each obj-list no-lock :
          for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
          for each post-stk-line  no-lock where
                  post-stk-line.obj-type = obj-list.obj-type and
                  post-stk-line.obj-code = obj-list.obj-code and
                  post-stk-line.fact-order >= null-fact-order   and
                  post-stk-line.fact-order <= fact-order-2   and
                  post-stk-line.sum-type    = 'cost':U    and
                  post-stk-line.cat-id      = '##':U
                  and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                  ,
                 each ub.goods no-lock where
                      ub.goods.artic     = post-stk-line.artic     and
                      ub.goods.prod-type = post-stk-line.prod-type and
                      ub.goods.prod-code = post-stk-line.prod-code and  can-find(first Tmp#grp where  ub.goods.grp-name begins Tmp#grp.grp-name ) = TRUE
                      :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          for each temp-t-post-stk-line no-lock   ,
                 last temp-post-stk-line  where
                                            temp-post-stk-line.fact-order <=  fact-order-2 and
                                            temp-post-stk-line.cat-id     =  t#cat-id                         and
                                            temp-post-stk-line.sum-type   =  t#sum-type                       and
                                            temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                                            temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                                            temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                                            temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                                            temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code    and
                                            temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type    and
                                            temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                                            no-lock
                                            break
                                            by ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                                            by ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                                            by temp-t-post-stk-line.fact-order :
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                       run display-line .
                                    end.
                                    if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) then do :
                                       run tmp-create (temp-t-post-stk-line.cli-code,
                                                       temp-t-post-stk-line.cli-type,
                                                       temp-t-post-stk-line.clients-obj-name,
                                                       obj-list.obj-code,
                                                       obj-list.obj-type ) .
                                       run tmp-clear.
                                    end.
          end.
       end.
       for each tmp-cli-gds no-lock
           break
           by tmp-cli-gds.name
           by (tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) :
           if first-of(tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) then run tmp-clear.
            run tmp-assign.
           if last-of((tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code))) then do:
               run print-footer ( 3 ,tmp-cli-gds.name).
           end.
       end.
End procedure.
procedure run3-0 :
       for each obj-list no-lock :
          for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
          for each post-stk-line  no-lock where
                  post-stk-line.obj-type = obj-list.obj-type and
                  post-stk-line.obj-code = obj-list.obj-code and
                  post-stk-line.fact-order >= null-fact-order   and
                  post-stk-line.fact-order <= fact-order-2   and
                  post-stk-line.sum-type    = 'cost':U    and
                  post-stk-line.cat-id      = '##':U
                  and  can-find(first G#cli where  post-stk-line.prod-type = G#cli.obj-type and  post-stk-line.prod-code = G#cli.obj-code ) = TRUE
                  and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                      :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available temp-t-post-stk-line then do:
                      find first  ub.goods no-lock where
                                            ub.goods.artic     = post-stk-line.artic     and
                                            ub.goods.prod-type = post-stk-line.prod-type and
                                            ub.goods.prod-code = post-stk-line.prod-code no-error .
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          for each temp-t-post-stk-line no-lock   ,
                 last temp-post-stk-line  where
                                            temp-post-stk-line.fact-order <=  fact-order-2 and
                                            temp-post-stk-line.cat-id     =  t#cat-id                         and
                                            temp-post-stk-line.sum-type   =  t#sum-type                       and
                                            temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                                            temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                                            temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                                            temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                                            temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code    and
                                            temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type    and
                                            temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                                            no-lock
                                            break
                                            by ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                                            by ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                                            by temp-t-post-stk-line.fact-order :
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                       run display-line .
                                    end.
                                    if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) then do :
                                       run tmp-create (temp-t-post-stk-line.cli-code,
                                                       temp-t-post-stk-line.cli-type,
                                                       temp-t-post-stk-line.clients-obj-name,
                                                       obj-list.obj-code,
                                                       obj-list.obj-type ) .
                                       run tmp-clear.
                                    end.
          end.
       end.
       for each tmp-cli-gds no-lock
           break
           by tmp-cli-gds.name
           by (tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) :
           if first-of(tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) then run tmp-clear.
            run tmp-assign.
           if last-of((tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code))) then do:
               run print-footer ( 3 ,tmp-cli-gds.name).
           end.
       end.
End procedure.
procedure run45-0 :
       for each obj-list no-lock :
          for each temp-t-post-stk-line : delete temp-t-post-stk-line. end.
          for each post-stk-line  no-lock where
                  post-stk-line.obj-type = obj-list.obj-type and
                  post-stk-line.obj-code = obj-list.obj-code and
                  post-stk-line.fact-order >= null-fact-order   and
                  post-stk-line.fact-order <= fact-order-2   and
                  post-stk-line.sum-type    = 'cost':U    and
                  post-stk-line.cat-id      = '##':U
                  and can-find(first g#post  where  post-stk-line.cli-type = g#post.obj-type and  post-stk-line.cli-code = g#post.obj-code ) = TRUE
                  ,
                 each ub.goods no-lock where
                      ub.goods.artic     = post-stk-line.artic     and
                      ub.goods.prod-type = post-stk-line.prod-type and
                      ub.goods.prod-code = post-stk-line.prod-code  and  can-find(first gds-list where  ub.goods.gds-code = gds-list.gds-code ) = TRUE
                      :
                 find first  temp-t-post-stk-line where
                   temp-t-post-stk-line.cli-type  = post-stk-line.cli-type  and
                   temp-t-post-stk-line.cli-code  = post-stk-line.cli-code   and
                   temp-t-post-stk-line.artic     = post-stk-line.artic     and
                   temp-t-post-stk-line.prod-type = post-stk-line.prod-type and
                   temp-t-post-stk-line.prod-code = post-stk-line.prod-code no-lock no-error .
                   if not available temp-t-post-stk-line then do:
                      find first  prod-cli no-lock  where
                                                prod-cli.obj-type = post-stk-line.prod-type and
                                                prod-cli.obj-code = post-stk-line.prod-code
                                                no-error .
                      find first  ub.clients  no-lock  where
                                                ub.clients.obj-type = post-stk-line.cli-type and
                                                ub.clients.obj-code = post-stk-line.cli-code no-error .
                        run create-temp-t-post-stk-line .
                 end.
                 else do:
                         assign
                           temp-t-post-stk-line.fact-order = post-stk-line.fact-order  .
                         .
                 end.
          end.
          for each temp-t-post-stk-line no-lock   ,
                 last temp-post-stk-line  where
                                            temp-post-stk-line.fact-order <=  fact-order-2 and
                                            temp-post-stk-line.cat-id     =  t#cat-id                         and
                                            temp-post-stk-line.sum-type   =  t#sum-type                       and
                                            temp-post-stk-line.artic      =  temp-t-post-stk-line.artic       and
                                            temp-post-stk-line.prod-type  =  temp-t-post-stk-line.prod-type   and
                                            temp-post-stk-line.prod-code  =  temp-t-post-stk-line.prod-code   and
                                            temp-post-stk-line.obj-type   =  temp-t-post-stk-line.obj-type    and
                                            temp-post-stk-line.obj-code   =  temp-t-post-stk-line.obj-code    and
                                            temp-post-stk-line.cli-type   =  temp-t-post-stk-line.cli-type    and
                                            temp-post-stk-line.cli-code   =  temp-t-post-stk-line.cli-code
                                            no-lock
                                            break
                                            by ((temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)))
                                            by ((temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)))
                                            by temp-t-post-stk-line.fact-order :
                                    if first-of( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-start. end .
                                    if last-of ( (temp-t-post-stk-line.artic + temp-t-post-stk-line.prod-type + string(temp-t-post-stk-line.prod-code)) ) then do : run goods-end.
                                       run display-line .
                                    end.
                                    if last-of( (temp-t-post-stk-line.cli-type + string(temp-t-post-stk-line.cli-code)) ) then do :
                                       run tmp-create (temp-t-post-stk-line.cli-code,
                                                       temp-t-post-stk-line.cli-type,
                                                       temp-t-post-stk-line.clients-obj-name,
                                                       obj-list.obj-code,
                                                       obj-list.obj-type ) .
                                       run tmp-clear.
                                    end.
          end.
       end.
       for each tmp-cli-gds no-lock
           break
           by tmp-cli-gds.name
           by (tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) :
           if first-of(tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code)) then run tmp-clear.
            run tmp-assign.
           if last-of((tmp-cli-gds.cli-type + string(tmp-cli-gds.cli-code))) then do:
               run print-footer ( 3 ,tmp-cli-gds.name).
           end.
       end.
End procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_contract-specif for ub.contract-specif.
define input parameter x-cont-code like contract.contract-code no-undo.
PROCEDURE Goods-start :
END PROCEDURE.
PROCEDURE Goods-end :
END PROCEDURE.
PROCEDURE display-line :
find first ub.contract-specif no-lock where
  ub.contract-specif.contract-num = x-cont-code                    and
  ub.contract-specif.gds-code     = temp-t-post-stk-line.gds-code  and
  ub.contract-specif.gds-name     = temp-t-post-stk-line.gds-name  and
  ub.contract-specif.artic        = temp-t-post-stk-line.artic     and
  ub.contract-specif.prod-type    = temp-t-post-stk-line.prod-type and
  ub.contract-specif.prod-code    = temp-t-post-stk-line.prod-code no-error.
if available ub.contract-specif then do :
      i = i + 1.
If Integer(10) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(10) .
     IF ( i modulo Temp1 = 0 ) AND ( i >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( i )) .
    run clear-item.
    assign
      gds-zap-gds-name   = temp-t-post-stk-line.gds-name
      gds-zap-unit-base  = temp-t-post-stk-line.unit-base
      gds-zap-prt-root   = temp-t-post-stk-line.prt-root
      gds-zap-prod-type  = temp-t-post-stk-line.prod-type
      gds-zap-prod-code  = temp-t-post-stk-line.prod-code
      gds-zap-artic      = temp-t-post-stk-line.artic
      gds-zap-grp-name   = temp-t-post-stk-line.Goods-grp-name
      gds-zap-b-code     = temp-t-post-stk-line.gds-code
      gds-zap-type       = temp-t-post-stk-line.gds-type
      pos-cli-type       = temp-t-post-stk-line.Cli-type
      pos-cli-code       = temp-t-post-stk-line.Cli-code
      pos-cli-grp-name   = temp-t-post-stk-line.Clients-grp-name.
    run ob-line
    (temp-t-post-stk-line.obj-code    ,
      temp-t-post-stk-line.obj-type    ,
      temp-t-post-stk-line.cli-code    ,
      temp-t-post-stk-line.cli-type    ,
      temp-t-post-stk-line.artic       ,
      temp-t-post-stk-line.prod-code   ,
      temp-t-post-stk-line.prod-type   ,
      temp-t-post-stk-line.gds-code    ,
      ub.contract-specif.host-code     ,
      Fact-order-1     ,
      Fact-order-2     ,
      t#sum-type       ,
      t#cat-id         ,
      ""               ,
      yes) .
    run display-str1.
    run clear-item   in this-procedure .
end.
END PROCEDURE.
PROCEDURE display-str1  :
run di-qnty  ( "", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,"","").
run clear-item in this-procedure .
END PROCEDURE.
PROCEDURE p-line :
 underline stream outstream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9
  gds-zap-b-code
  gds-zap-artic
  gds-zap-gds-name
  F-bonus
  F-price-sale
  F-kassa
  F-bonus-dohod
  F-nacenka
  with FRAME ZAPAS.
  DOWN stream   OutStream 1 with FRAME ZAPAS .
END PROCEDURE.
PROCEDURE Di :
END PROCEDURE.
PROCEDURE Di-qnty :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
CASE CAPS ( p7) :
 WHEN  ""  Then DO :
              DISPLAY stream  OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9
                p3               @ gds-zap-b-code
                p4               @ gds-zap-artic
                p5               @ gds-zap-gds-name
                v-bonus[1]       @  F-bonus
                v-price-sale[1]  @  F-price-sale
                v-kassa[1]       @  F-kassa
                v-bonus-dohod[1] @  F-bonus-dohod
                v-nacenka[1]     @  F-nacenka
                with FRAME ZAPAS .
    if Make-Excel then  put   stream ForExcel unformatted p3 CHR(9)
                p4 CHR(9)
                p5 CHR(9)
                v-bonus       [1] FORMAT ">>9.99"        +  CHR(9)
                v-price-sale  [1] FORMAT ">>>>>>>>9.99"  +  CHR(9)
                v-kassa       [1] FORMAT "->>>>>>>>9.99" +  CHR(9)
                v-bonus-dohod [1] FORMAT "->>>>>>>>9.99"  +  CHR(9)
                v-nacenka     [1] FORMAT "->>9.99"
                chr(10).
 End.
End case.
DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
PROCEDURE Print-Footer :
define input parameter Nx as integer no-undo .
define input parameter Name as char no-undo .
run p-line.
END PROCEDURE.
PROCEDURE Clear-item :
define var kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   v-bonus        [kk]  = 0
   v-price-sale   [kk]  = 0
   v-kassa        [kk]  = 0
   v-bonus-dohod  [kk]  = 0
   v-nacenka      [kk]  = 0
   s-kassa        [kk]  = 0
   s-bonus-dohod  [kk]  = 0
   s-nacenka      [kk]  = 0
   .
 End.
END PROCEDURE.
PROCEDURE ob-line :
define input  parameter x-store-code     like ub.clients.obj-code                no-undo.
define input  parameter x-store-type     like ub.clients.obj-type                no-undo.
define input  parameter x-cli-code       like ub.clients.obj-code                no-undo.
define input  parameter x-cli-type       like ub.clients.obj-type                no-undo.
define INPUT  parameter x-artic          like post-ot-line.artic              no-undo.
define INPUT  parameter x-prod-code      like post-ot-line.prod-code          no-undo.
define INPUT  parameter x-prod-type      like post-ot-line.prod-type          no-undo.
define input  parameter x-b-code         like temp-t-post-stk-line.gds-code   no-undo.
define input  parameter x-host-code      like ub.contract-specif.host-code    no-undo.
define INPUT  parameter x-Fact-order-1   like post-ot-line.Fact-order         no-undo.
define INPUT  parameter x-Fact-order-2   like post-ot-line.Fact-order         no-undo.
define input  parameter x-sum-type       like post-ot-line.sum-type           no-undo.
define input  parameter x-cat-id         like post-ot-line.cat-id             no-undo.
define input  parameter x-ext-doc-type   like post-ot-line.ext-doc-type       no-undo.
define input  parameter xTog-obj           as logical                         no-undo.
define        variable  bonus              as decimal                         no-undo.
define        variable  num-cont           as decimal                         no-undo.
define        variable  v-doc-num          as character                       no-undo.
define        variable  price-sale         as decimal                         no-undo.
define        variable  v-road-tax         as decimal                         no-undo.
define        variable  v-excise           as decimal                         no-undo.
FOR each post-ot-line where
        post-ot-line.artic        = x-artic
  and   post-ot-line.fact-order  <= x-fact-order-2
  and   post-ot-line.fact-order  >= x-fact-order-1
  and   post-ot-line.obj-code     = x-store-code
  and   post-ot-line.obj-type     = x-store-type
  and   post-ot-line.prod-code    = x-prod-code
  and   post-ot-line.prod-type    = x-prod-type
  and   post-ot-line.cli-code     = x-cli-code
  and   post-ot-line.cli-type     = x-cli-type
  and   post-ot-line.sum-type     = 'sale':U
  and   post-ot-line.cat-id       = x-cat-id
          no-lock :
  CASE post-ot-line.ext-doc-type:
   WHEN       'es':U  OR
   WHEN       'rs':U
   THEN  DO :
    ASSIGN v-kassa[1] = v-kassa[1] - post-ot-line.sum-rubl
           v-kassa[2] = v-kassa[2] - post-ot-line.fact-qnty
          .
   End.
  End CASE.
END.
FOR each post-ot-line where
        post-ot-line.artic        = x-artic
  and   post-ot-line.fact-order  <= x-fact-order-2
  and   post-ot-line.fact-order  >= x-fact-order-1
  and   post-ot-line.obj-code     = x-store-code
  and   post-ot-line.obj-type     = x-store-type
  and   post-ot-line.prod-code    = x-prod-code
  and   post-ot-line.prod-type    = x-prod-type
  and   post-ot-line.cli-code     = x-cli-code
  and   post-ot-line.cli-type     = x-cli-type
  and   post-ot-line.sum-type     = 'cost':U
  and   post-ot-line.cat-id       = x-cat-id
          no-lock :
  CASE post-ot-line.ext-doc-type:
   WHEN       'es':U  OR
   WHEN       'rs':U
   THEN  DO :
    ASSIGN
    v-kassa[3] = v-kassa[3] - post-ot-line.sum-rubl.
   End.
  End CASE.
END.
run read-bonus in this-procedure
  (input x-cont-code
  ,input x-host-code
  ,input x-b-code
  ,output bonus )
  .
v-bonus[1] = bonus.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x-store-type
  ,input  x-store-code
  ,input  x-b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output price-sale
  ,output v-road-tax
  ,output v-excise
  )  .
v-price-sale[1] = price-sale.
assign
  v-bonus-dohod[1] = ( v-price-sale[1] * v-kassa[2] ) * v-bonus[1] / 100
  v-nacenka[1] = ( v-kassa[1] - v-kassa[3] ) / v-kassa[1] * 100
  s-kassa[1] =  s-kassa[1] + v-kassa[1]
  s-bonus-dohod[1] =  s-bonus-dohod[1] + v-bonus-dohod[1]
  s-nacenka[1] = s-nacenka[1] + v-nacenka[1]
  .
find first tmp-itog where tmp-gds-code = x-b-code no-error.
if not available tmp-itog then do :
  create tmp-itog.
   assign
    tmp-itog.tmp-gds-code             = x-b-code
    tmp-itog.tmp-artic                = x-artic
    tmp-itog.tmp-gds-name             = temp-t-post-stk-line.gds-name
    tmp-itog.tmp-goods-grp-name       = temp-t-post-stk-line.goods-grp-name
    tmp-itog.tmp-clients-grp-name     = temp-t-post-stk-line.clients-grp-name
    tmp-itog.tmp-fact-order           = temp-t-post-stk-line.fact-order
    tmp-itog.tmp-prod-type            = temp-t-post-stk-line.prod-type
    tmp-itog.tmp-prod-code            = temp-t-post-stk-line.prod-code
    tmp-itog.tmp-cli-type             = temp-t-post-stk-line.cli-type
    tmp-itog.tmp-cli-code             = temp-t-post-stk-line.cli-code
    tmp-itog.tmp-prod-cli-obj-name    = temp-t-post-stk-line.prod-cli-obj-name
    tmp-itog.tmp-prod-cli-obj-type    = temp-t-post-stk-line.prod-cli-obj-type
    tmp-itog.tmp-prod-cli-obj-code    = temp-t-post-stk-line.prod-cli-obj-code
    tmp-itog.bn-col                   = 1
    tmp-itog.bonus                    = v-bonus[1]
    tmp-itog.sum-kassa                = s-kassa[1]
    tmp-itog.sum-bonus-dohod          = s-bonus-dohod[1]
    tmp-itog.sum-nacenka              = s-nacenka[1]
    .
end.
else do :
   assign
    tmp-itog.bn-col          = tmp-itog.bn-col + 1
    tmp-itog.sum-kassa       = tmp-itog.sum-kassa + s-kassa[1]
    tmp-itog.sum-bonus-dohod = tmp-itog.sum-bonus-dohod + s-bonus-dohod[1]
    tmp-itog.sum-nacenka     = tmp-itog.sum-nacenka + s-nacenka[1]
    .
end.
END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9
  gds-zap-b-code
  gds-zap-artic
  gds-zap-gds-name
  F-bonus
  F-price-sale
  F-kassa
  F-bonus-dohod
  F-nacenka
  with FRAME ZAPAS .
  DOWN stream   OutStream 1 with FRAME ZAPAS.
END PROCEDURE.
PROCEDURE display-str :
DISPLAY stream  OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9
                tmp-itog.tmp-gds-code @  gds-zap-b-code
                tmp-itog.tmp-artic    @  gds-zap-artic
                tmp-itog.tmp-gds-name @  gds-zap-gds-name
                v-bonus[2]            @  F-bonus
                "----------------"    @  F-price-sale
                s-kassa[2]            @  F-kassa
                s-bonus-dohod[2]      @  F-bonus-dohod
                s-nacenka[2]          @  F-nacenka
                with FRAME ZAPAS .
                DOWN stream   OutStream 1 with FRAME ZAPAS.
  if Make-Excel then  put   stream ForExcel unformatted   tmp-itog.tmp-gds-code   CHR(9)
                tmp-itog.tmp-artic      CHR(9)
                tmp-itog.tmp-gds-name   CHR(9)
                v-bonus       [2] FORMAT ">>9.99"        +  CHR(9)
                s-kassa       [2] FORMAT "->>>>>>>>9.99"  +  CHR(9)
                s-bonus-dohod [2] FORMAT "->>>>>>>>9.99"  +  CHR(9)
                s-nacenka     [2] FORMAT "->>9.99"        +  CHR(9)
                chr(10).
END PROCEDURE.
PROCEDURE Goods-start-O :
END PROCEDURE.
PROCEDURE Goods-end-O :
END PROCEDURE.
Procedure Tmp-create :
END PROCEDURE.
Procedure Tmp-clear :
END PROCEDURE.
Procedure Tmp-assign :
END PROCEDURE.
