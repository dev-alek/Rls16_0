block-level on error undo, throw.
define input parameter x-store-code like ub.clients.obj-code no-undo.
define input parameter x-store-type like ub.clients.obj-type no-undo.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter Itog      as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Оборотная ведомость (без остатков)".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-font no-undo
  field fontnum  as integer
  field fontname as character
  field fontsize as character
  field fonttype as character
  field font-h   as integer
  field font-w   as integer
  field v-row    as integer
  field v-col    as integer
  field v-row-lans as integer
  field v-col-lans as integer
index pi fontnum
.
procedure get-font-ini :
  do
  on error undo, return error return-value
  :
define variable ii as integer   no-undo .
define variable v-font7 as character no-undo .
define variable v-font as character no-undo .
define variable loc-name as character no-undo .
define variable loc-size as character no-undo .
define variable loc-type as character no-undo .
define variable old_H as integer   no-undo .
define variable old_w as integer   no-undo .
define variable old-row  as integer   no-undo .
define variable old-col  as integer   no-undo .
define variable old-row-lans  as integer   no-undo .
define variable old-col-lans  as integer   no-undo .
define variable vv as integer   no-undo .
empty temp-table temp-font.
  GET-KEY-VALUE SECTION "fonts" KEY "font7" VALUE v-font7 .
    case num-entries (v-font7) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 ) + "," +  entry ( 4 , v-font7 )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = entry ( 3 , v-font7 )
          .
      end.
      when 2 then  do:
          assign
            loc-name = entry ( 1 , v-font7 )
            loc-size = entry ( 2 , v-font7 )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font7 ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = 7
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
    temp-font.v-row    = 62
    temp-font.v-col    = 136
    temp-font.v-row-lans = 43
    temp-font.v-col-lans = 198
  .
  repeat ii = 16 to 100 :
    get-key-value section 'fonts' key 'font' + string(ii)   value v-font  .
    if v-font = "" or v-font = ? then leave.
    case num-entries (v-font) :
      when 4 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font ) + "," +  entry ( 4 , v-font )
          .
      end.
      when 3 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = entry ( 3 , v-font )
          .
      end.
      when 2 then do:
          assign
            loc-name = entry ( 1 , v-font )
            loc-size = entry ( 2 , v-font )
            loc-type = ""
          .
      end.
      when 1 then do:
          assign
            loc-name = trim(entry ( 1 , v-font ))
            loc-size = ""
            loc-type = ""
          .
      end.
    end case.
  create temp-font.
  assign
    temp-font.fontnum  = ii
    temp-font.fontname = trim(loc-name)
    temp-font.fontsize = trim(loc-size)
    temp-font.fonttype = trim(loc-type)
  .
  end.
    for each temp-font :
       vv = integer(entry(2,temp-font.fontsize, "=" )) no-error .
       if  vv = ? then vv =  0 .
        run rep/exfont.p (
          input   temp-font.fontname ,
          input   vv ,
          input   temp-font.fonttype ,
          output  temp-font.font-h   ,
          output  temp-font.font-w   )
        .
    end.
find first temp-font where  temp-font.fontnum  = 7  .
old_H = temp-font.font-H .
old_w = temp-font.font-W .
old-row = temp-font.v-row .
old-col = temp-font.v-col .
old-row-lans = temp-font.v-row-lans .
old-col-lans = temp-font.v-col-lans .
    for each temp-font where
             temp-font.fontnum  <> 7 :
        assign
            temp-font.v-row    = old_H * old-row / temp-font.font-h
            temp-font.v-col    = old_W * old-col / temp-font.font-W
            temp-font.v-row-lans    = old_H * old-row-lans / temp-font.font-h
            temp-font.v-col-lans    = old_W * old-col-lans / temp-font.font-W
        .
    end.
  end.
end procedure.
PROCEDURE How-name :
define input  parameter h as integer no-undo .
define input  parameter w as integer no-undo .
define output parameter n as character  no-undo .
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.
define variable Strim-W  as integer   no-undo init 278.
run define-a4-size (
     input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).
If w >= 1 and w <= A4port-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A4-port":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4port-W and w <= A4lans-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "A4-lans":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > A4lans-W and w <= Strim-W Then DO:
  If h >= 1  and h <= A4lans-H Then n = "to-file":U.
  If h > A4lans-H  and h <= A4port-H Then n = "A3-lans":U.
  If h > A4port-H              Then n = "to-file":U.
End.
If w > Strim-W Then DO:
   n = "to-file":U.
End.
END PROCEDURE.
PROCEDURE define-a4-size :
define input  parameter p-ReportFontNum as integer   no-undo .
define output parameter A4port-H as integer   no-undo .
define output parameter A4port-W as integer   no-undo .
define output parameter A4lans-H as integer   no-undo .
define output parameter A4lans-W as integer   no-undo .
if not can-find (first temp-font ) then do:
   run get-font-ini .
end.
find first temp-font where temp-font.fontnum = p-ReportFontNum no-error .
if available temp-font then do:
assign
  A4port-H = temp-font.v-row
  A4port-W = temp-font.v-col
  A4lans-H = temp-font.v-row-lans
  A4lans-W = temp-font.v-col-lans
.
end.
else do:
assign
  A4port-H = 63
  A4port-W = 136
  A4lans-H = 43
  A4lans-W = 198
.
end.
END PROCEDURE.
define buffer clients-p for ub.clients .
define buffer alt-ot-line for ub.ot-line .
define buffer crsa-ot-line for ub.ot-line .
define buffer goods   for ub.goods  .
define buffer gds-obj for ub.gds-obj  .
define buffer clients for ub.clients  .
define work-table wt no-undo
field doc-code like ub.ot-line.doc-code
.
define buffer buf-tdedt for tdedt  .
define variable     F-fact-date      as char no-undo.
define variable  Fact-order-1 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R1       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like ub.stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Fact-order-2 like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2       like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast5       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast6       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast3         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4         like ub.stk-tot.sum-rubl   no-undo.
define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str NO-UNDO.
define variable  tPrintRubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.
define variable xTog-obj as logical no-undo init false  .
define stream  OutStream .
define variable    ObjName           as char no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.
define variable tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable    iI        as   integer no-undo.
define variable    i         as   integer no-undo .
define variable    j         as   integer no-undo.
define variable    K         as   integer no-undo.
define variable    acc-i     as   integer no-undo .
define variable    acc-j     as   integer no-undo.
define variable   v-vat_pc   as   char no-undo.
define variable   v-vat_sum  as   decimal format "->>>,>>>,>>9.99" no-undo.
define variable   v-slt_pc   as   char no-undo.
define variable   v-slt_sum  as   decimal format "->>>,>>>,>>9.99" no-undo.
define variable tmpact as decimal format "->>>>>>>>9.999" no-undo.
define variable stat     as log no-undo .
define variable InpError as log no-undo .
define variable rid-list as character no-undo .
define variable curr-rep as char no-undo.
define variable listtd as char no-undo.
define variable NO-PRISE as logical no-undo  init true .
define variable Discnt-base# as decimal init 0  no-undo .
define variable n-nn as integer init 0 no-undo .
define variable n-nm as integer init 0 no-undo .
define variable n-no as integer init 0 no-undo .
define variable var-client as character no-undo .
define variable  nn                as character no-undo .
define variable    f-artic         as character no-undo .
define variable    f-gds-name      as character no-undo .
define variable    f-qnty          as decimal no-undo .
define variable    f-qnty1         as decimal no-undo .
define variable    f-qnty2         as decimal no-undo .
define variable    f-cost-sum      as decimal  no-undo .
define variable    f-cost-vat      as decimal no-undo .
define variable    f-cost-sum-novat as decimal no-undo .
define variable    f-sale-sum       as decimal no-undo .
define variable    f-sale-other     as decimal no-undo .
define variable    f-sale-vat       as decimal no-undo .
define variable    f-sale-slt       as decimal no-undo .
define variable    f-disc           as decimal no-undo .
define variable    f-disc-prc       as decimal no-undo .
define variable    f-crsa-sum       as decimal no-undo .
define variable    f-crsa-sum1      as decimal no-undo .
define variable    f-crsa-sum2      as decimal no-undo .
define variable    c-nn               as WIDGET-HANDLE no-undo .
define variable    c-f-artic          as WIDGET-HANDLE no-undo .
define variable    c-f-gds-name       as WIDGET-HANDLE no-undo .
define variable    c-f-qnty           as WIDGET-HANDLE no-undo .
define variable    c-f-qnty1          as WIDGET-HANDLE no-undo .
define variable    c-f-qnty2          as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum       as WIDGET-HANDLE no-undo .
define variable    c-f-cost-vat       as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum-novat as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum       as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-vat       as WIDGET-HANDLE no-undo .
define variable    c-f-sale-slt       as WIDGET-HANDLE no-undo .
define variable    c-f-disc           as WIDGET-HANDLE no-undo .
define variable    c-f-disc-prc       as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum       as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum1      as WIDGET-HANDLE no-undo .
define variable    c-f-crsa-sum2      as WIDGET-HANDLE no-undo .
define variable    l1f-artic         as character no-undo .
define variable    l1f-gds-name      as character no-undo .
define variable    l1f-qnty          as character no-undo .
define variable    l1f-qnty1         as character no-undo .
define variable    l1f-qnty2         as character no-undo .
define variable    l1f-cost-sum      as character no-undo .
define variable    l1f-cost-vat      as character no-undo .
define variable    l1f-cost-sum-novat as character no-undo .
define variable    l1f-sale-sum       as character no-undo .
define variable    l1f-sale-other     as character no-undo .
define variable    l1f-sale-vat       as character no-undo .
define variable    l1f-sale-slt       as character no-undo .
define variable    l1f-disc           as character no-undo .
define variable    l1f-disc-prc       as character no-undo .
define variable    l1f-crsa-sum       as character no-undo .
define variable    l1f-crsa-sum1      as character no-undo .
define variable    l1f-crsa-sum2      as character no-undo .
define variable    l2f-artic         as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-qnty          as character no-undo .
define variable    l2f-qnty1         as character no-undo .
define variable    l2f-qnty2         as character no-undo .
define variable    l2f-cost-sum      as character no-undo .
define variable    l2f-cost-vat      as character no-undo .
define variable    l2f-cost-sum-novat as character no-undo .
define variable    l2f-sale-sum       as character no-undo .
define variable    l2f-sale-other     as character no-undo .
define variable    l2f-sale-vat       as character no-undo .
define variable    l2f-sale-slt       as character no-undo .
define variable    l2f-disc           as character no-undo .
define variable    l2f-disc-prc       as character no-undo .
define variable    l2f-crsa-sum       as character no-undo .
define variable    l2f-crsa-sum1      as character no-undo .
define variable    l2f-crsa-sum2      as character no-undo .
define variable    ff-qnty         as decimal no-undo .
define variable    ff-cost-sum     as decimal no-undo .
define variable    ff-cost-vat     as decimal no-undo .
define variable    ff-cost-sum-novat as decimal no-undo .
define variable    ff-sale-sum       as decimal no-undo .
define variable    ff-sale-other     as decimal no-undo .
define variable    ff-sale-vat       as decimal no-undo .
define variable    ff-sale-slt       as decimal no-undo .
define variable    ff-disc           as decimal no-undo .
define variable    ff-disc-prc       as decimal no-undo .
define variable    ff-crsa-sum       as decimal no-undo .
define variable    tf-qnty         as decimal no-undo .
define variable    tf-cost-sum     as decimal no-undo .
define variable    tf-cost-vat     as decimal no-undo .
define variable    tf-cost-sum-novat as decimal no-undo .
define variable    tf-sale-sum       as decimal no-undo .
define variable    tf-sale-other     as decimal no-undo .
define variable    tf-sale-vat       as decimal no-undo .
define variable    tf-sale-slt       as decimal no-undo .
define variable    tf-disc           as decimal no-undo .
define variable    tf-disc-prc       as decimal no-undo .
define variable    tf-crsa-sum       as decimal no-undo .
define variable L1 as character no-undo .
define variable L2 as character no-undo .
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
assign v-account = ( if integer( 100 ) = 0 then 100 else integer( 100 ) ).
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
def  var l-col-type         as character no-undo .
def  var l-col-pos          as integer no-undo .
def  var l-row-pos           as integer no-undo init 1.
def  var l-col-len          as integer no-undo .
def  var l-col-format       as character no-undo .
def  var l-col-lable        as character no-undo .
DEFINE VARIABLE t-1 AS CHARACTER INITIAL "||||"
     VIEW-AS EDITOR
     SIZE 1 BY 4 NO-UNDO.
DEFINE FRAME top-frame
    t-1       AT ROW 1 COL 1 no-label
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") ) AT 110 format "X(16)" SKIP
     WITH 300 DOWN stream-io
         NO-UNDERLINE use-text NO-BOX no-label
         AT COL 1 ROW 1
         SIZE 300 BY 35  .
DEFINE FRAME zapas
   with width 300 down stream-io use-text NO-BOX no-label.
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=6  l-col-format= "X(6)"         l-col-lable="N/N"                      .
  def var ed1 as handle .
  def var s1 as handle .
  def var sf1 as handle .
  def var l-1 as handle .
  def var ll-1 as handle .
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
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format= "X(16)"        l-col-lable="Артикул"                  .
  def var ed2 as handle .
  def var s2 as handle .
  def var sf2 as handle .
  def var l-2 as handle .
  def var ll-2 as handle .
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
Assign l-col-type="CHARACTER" l-col-len=32 l-col-format= "X(32)"        l-col-lable="Название товара"          .
  def var ed3 as handle .
  def var s3 as handle .
  def var sf3 as handle .
  def var l-3 as handle .
  def var ll-3 as handle .
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
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>>>9.<<<"  l-col-lable="Количество "          .
  def var ed4 as handle .
  def var s4 as handle .
  def var sf4 as handle .
  def var l-4 as handle .
  def var ll-4 as handle .
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
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Учетные цены с НДС"    .
  def var ed5 as handle .
  def var s5 as handle .
  def var sf5 as handle .
  def var l-5 as handle .
  def var ll-5 as handle .
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
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="НДС от учетной цены"   .
  def var ed6 as handle .
  def var s6 as handle .
  def var sf6 as handle .
  def var l-6 as handle .
  def var ll-6 as handle .
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
        CREATE FILL-IN C-f-cost-vat IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Учетные цены  без НДС ".
  def var ed7 as handle .
  def var s7 as handle .
  def var sf7 as handle .
  def var l-7 as handle .
  def var ll-7 as handle .
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
        CREATE FILL-IN C-f-cost-sum-novat IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Цены документа"        .
  def var ed8 as handle .
  def var s8 as handle .
  def var sf8 as handle .
  def var l-8 as handle .
  def var ll-8 as handle .
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
Assign l-col-type="DECIMAL" l-col-len=10 l-col-format="->>>>>>9.99"  l-col-lable="В т.ч. скидки"         .
  def var ed9 as handle .
  def var s9 as handle .
  def var sf9 as handle .
  def var l-9 as handle .
  def var ll-9 as handle .
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
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="НДС от цены документа" .
  def var ed10 as handle .
  def var s10 as handle .
  def var sf10 as handle .
  def var l-10 as handle .
  def var ll-10 as handle .
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
        CREATE FILL-IN C-f-sale-vat IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="НП от цены документа"  .
  def var ed11 as handle .
  def var s11 as handle .
  def var sf11 as handle .
  def var l-11 as handle .
  def var ll-11 as handle .
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
        CREATE FILL-IN C-f-sale-slt IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL" l-col-len=12 l-col-format="->>>>>>>9.99"  l-col-lable="Наценка "              .
  def var ed12 as handle .
  def var s12 as handle .
  def var sf12 as handle .
  def var l-12 as handle .
  def var ll-12 as handle .
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
        CREATE FILL-IN C-f-disc IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL" l-col-len=7 l-col-format="->>>>9.<<"  l-col-lable="% торг. наценки"   .
  def var ed13 as handle .
  def var s13 as handle .
  def var sf13 as handle .
  def var l-13 as handle .
  def var ll-13 as handle .
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
        CREATE FILL-IN C-f-disc-prc IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL" l-col-len=13 l-col-format="->>>>>>>>9.99"  l-col-lable="Сумма продажных цен"   .
  def var ed14 as handle .
  def var s14 as handle .
  def var sf14 as handle .
  def var l-14 as handle .
  def var ll-14 as handle .
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
   FIND first ub.clients where x-store-type = ub.clients.obj-type AND
            x-store-code = ub.clients.obj-code no-lock no-error.
           If available ub.clients then  ObjName = ub.clients.obj-name.
                                         else  ObjName="объект не определен".
     assign
        i             = 0
        startdate     = x-date-start
        enddate       = x-date-end
        PayType       = x-SET_PAY_TYPE
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        run report-execute.
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
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
   NO-PRISE = true .
  if var-report-r-b = "rubl"  Then do:
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
   end.
  else do:
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .
  end .
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  FORM with FRAME Zapas .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(198)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
   Line = fill("-", 198).
  run CalcItog in this-procedure.
  run Print-Header in this-procedure.
  CAse classify :
    when 1 then do:
      run Foreach1 in this-procedure.
    end.
    when 2 then do:
      run Foreach2 in this-procedure.
    end.
    when 3 then do:
      run Foreach3 in this-procedure.
    end.
    when 4 then do:
      run Foreach4 in this-procedure.
    end.
    when 5 then do:
      run Foreach5 in this-procedure.
    end.
  End case.
  HIDE stream OutStream FRAME BottomFrame .
  run  Print-footer in this-procedure.
  HIDE STREAM OutStream FRAME Zapas .
  HIDE   STREAM OutStream FRAME top-Frame .
  DELETE WIDGET-POOL "My-pool".
  Output stream OutStream close.
  if Make-Excel then output stream ForExcel close.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .
  run gbl/prnfilen.w
    (input  ""
    ,input  DisabledOptions
    ,input  string(session :temp-directory) + "rpt" + string( g#report-num )
    ,input  ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
END PROCEDURE.
PROCEDURE print-header :
   PUT stream OutStream  string( v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 10 format "X(85)" SKIP(2)
         REPORTNAME
         AT 10  format "X(100)" skip.
     Repeat i = 1 to NUM-ENTRIES(STR1,chr(10)) :
        PUT stream OutStream  Entry(i,STR1,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR2,chr(10)) :
        PUT stream OutStream  Entry(i,STR2,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR3,chr(10)) :
        PUT stream OutStream  Entry(i,STR3,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR4,chr(10)) :
        PUT stream OutStream  Entry(i,STR4,chr(10))  AT 1 format "X(100)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
        PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(100)" SKIP.
     End.
    i=0.
    run rep/extitle.p (1) .
  display STREAM OutStream     with frame top-Frame .
   END PROCEDURE.
PROCEDURE Print-Footer :
  run on-same-page in this-procedure (input 1) .
PUT STREAM OutStream " " SKIP(3)
     SKIP .
   run on-same-page in this-procedure (input 1) .
   END PROCEDURE.
PROCEDURE U-LINE :
define variable ff as character no-undo .
if itog = false
Then do:
ff = fill("-",40).
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-crsa-sum <>  ?  then do :
Assign
    l1f-crsa-sum  = c-f-crsa-sum:DATA-TYPE
    l2f-crsa-sum  = c-f-crsa-sum:FORMAT
    c-f-crsa-sum:DATA-TYPE = "CHARACTER"
    c-f-crsa-sum:FORMAT    = "x(" + string(C-f-crsa-sum:WIDTH-CHARS) + ")"
    c-f-crsa-sum:screen-value = string(ff)  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string(ff)  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string(ff)  .
End.
if c-f-cost-vat <>  ?  then do :
Assign
    l1f-cost-vat  = c-f-cost-vat:DATA-TYPE
    l2f-cost-vat  = c-f-cost-vat:FORMAT
    c-f-cost-vat:DATA-TYPE = "CHARACTER"
    c-f-cost-vat:FORMAT    = "x(" + string(C-f-cost-vat:WIDTH-CHARS) + ")"
    c-f-cost-vat:screen-value = string(ff)  .
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    l1f-cost-sum-novat  = c-f-cost-sum-novat:DATA-TYPE
    l2f-cost-sum-novat  = c-f-cost-sum-novat:FORMAT
    c-f-cost-sum-novat:DATA-TYPE = "CHARACTER"
    c-f-cost-sum-novat:FORMAT    = "x(" + string(C-f-cost-sum-novat:WIDTH-CHARS) + ")"
    c-f-cost-sum-novat:screen-value = string(ff)  .
End.
if c-f-sale-vat <>  ?  then do :
Assign
    l1f-sale-vat  = c-f-sale-vat:DATA-TYPE
    l2f-sale-vat  = c-f-sale-vat:FORMAT
    c-f-sale-vat:DATA-TYPE = "CHARACTER"
    c-f-sale-vat:FORMAT    = "x(" + string(C-f-sale-vat:WIDTH-CHARS) + ")"
    c-f-sale-vat:screen-value = string(ff)  .
End.
if c-f-sale-slt <>  ?  then do :
Assign
    l1f-sale-slt  = c-f-sale-slt:DATA-TYPE
    l2f-sale-slt  = c-f-sale-slt:FORMAT
    c-f-sale-slt:DATA-TYPE = "CHARACTER"
    c-f-sale-slt:FORMAT    = "x(" + string(C-f-sale-slt:WIDTH-CHARS) + ")"
    c-f-sale-slt:screen-value = string(ff)  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string(ff)  .
End.
if c-f-disc <>  ?  then do :
Assign
    l1f-disc  = c-f-disc:DATA-TYPE
    l2f-disc  = c-f-disc:FORMAT
    c-f-disc:DATA-TYPE = "CHARACTER"
    c-f-disc:FORMAT    = "x(" + string(C-f-disc:WIDTH-CHARS) + ")"
    c-f-disc:screen-value = string(ff)  .
End.
if c-f-disc-prc <>  ?  then do :
Assign
    l1f-disc-prc  = c-f-disc-prc:DATA-TYPE
    l2f-disc-prc  = c-f-disc-prc:FORMAT
    c-f-disc-prc:DATA-TYPE = "CHARACTER"
    c-f-disc-prc:FORMAT    = "x(" + string(C-f-disc-prc:WIDTH-CHARS) + ")"
    c-f-disc-prc:screen-value = string(ff)  .
End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string(ff)  .
End.
  Display stream OutStream  with FRAME Zapas no-error .
  DOWN stream OutStream  with FRAME Zapas .
if c-f-crsa-sum <>  ?  then do :
Assign
    c-f-crsa-sum:DATA-TYPE = l1f-crsa-sum
    c-f-crsa-sum:FORMAT    = l2f-crsa-sum.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-cost-vat <>  ?  then do :
Assign
    c-f-cost-vat:DATA-TYPE = l1f-cost-vat
    c-f-cost-vat:FORMAT    = l2f-cost-vat.
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    c-f-cost-sum-novat:DATA-TYPE = l1f-cost-sum-novat
    c-f-cost-sum-novat:FORMAT    = l2f-cost-sum-novat.
End.
if c-f-sale-vat <>  ?  then do :
Assign
    c-f-sale-vat:DATA-TYPE = l1f-sale-vat
    c-f-sale-vat:FORMAT    = l2f-sale-vat.
End.
if c-f-sale-slt <>  ?  then do :
Assign
    c-f-sale-slt:DATA-TYPE = l1f-sale-slt
    c-f-sale-slt:FORMAT    = l2f-sale-slt.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-disc <>  ?  then do :
Assign
    c-f-disc:DATA-TYPE = l1f-disc
    c-f-disc:FORMAT    = l2f-disc.
End.
if c-f-disc-prc <>  ?  then do :
Assign
    c-f-disc-prc:DATA-TYPE = l1f-disc-prc
    c-f-disc-prc:FORMAT    = l2f-disc-prc.
End.
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
End.
END PROCEDURE.
PROCEDURE CalcItog :
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-1 ).
    run ostatok (
        input x-store-code  ,
        input x-store-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input xTog-obj ,
        output  Quantity1  ,
        output  Coast_R1   ,
        output  Coast_V1   ,
        output  VAT_R1     ,
        output  VAT_V1     ,
        output  Fact-order-2 ).
          Quantity1  = 0.
          Coast_R1   = 0.
          Coast_V1   = 0.
          VAT_R1     = 0.
          VAT_V1     = 0.
END PROCEDURE.
PROCEDURE foreach1 :
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
  for each obj-list no-lock with FRAME Zapas :
    if NOT( classify = 1 and Itog = true) then dO:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-crsa-sum <>  ?  then do :
Assign
    l1f-crsa-sum  = c-f-crsa-sum:DATA-TYPE
    l2f-crsa-sum  = c-f-crsa-sum:FORMAT
    c-f-crsa-sum:DATA-TYPE = "CHARACTER"
    c-f-crsa-sum:FORMAT    = "x(" + string(C-f-crsa-sum:WIDTH-CHARS) + ")"
    c-f-crsa-sum:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-cost-vat <>  ?  then do :
Assign
    l1f-cost-vat  = c-f-cost-vat:DATA-TYPE
    l2f-cost-vat  = c-f-cost-vat:FORMAT
    c-f-cost-vat:DATA-TYPE = "CHARACTER"
    c-f-cost-vat:FORMAT    = "x(" + string(C-f-cost-vat:WIDTH-CHARS) + ")"
    c-f-cost-vat:screen-value = string('')  .
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    l1f-cost-sum-novat  = c-f-cost-sum-novat:DATA-TYPE
    l2f-cost-sum-novat  = c-f-cost-sum-novat:FORMAT
    c-f-cost-sum-novat:DATA-TYPE = "CHARACTER"
    c-f-cost-sum-novat:FORMAT    = "x(" + string(C-f-cost-sum-novat:WIDTH-CHARS) + ")"
    c-f-cost-sum-novat:screen-value = string('')  .
End.
if c-f-sale-vat <>  ?  then do :
Assign
    l1f-sale-vat  = c-f-sale-vat:DATA-TYPE
    l2f-sale-vat  = c-f-sale-vat:FORMAT
    c-f-sale-vat:DATA-TYPE = "CHARACTER"
    c-f-sale-vat:FORMAT    = "x(" + string(C-f-sale-vat:WIDTH-CHARS) + ")"
    c-f-sale-vat:screen-value = string('')  .
End.
if c-f-sale-slt <>  ?  then do :
Assign
    l1f-sale-slt  = c-f-sale-slt:DATA-TYPE
    l2f-sale-slt  = c-f-sale-slt:FORMAT
    c-f-sale-slt:DATA-TYPE = "CHARACTER"
    c-f-sale-slt:FORMAT    = "x(" + string(C-f-sale-slt:WIDTH-CHARS) + ")"
    c-f-sale-slt:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-disc <>  ?  then do :
Assign
    l1f-disc  = c-f-disc:DATA-TYPE
    l2f-disc  = c-f-disc:FORMAT
    c-f-disc:DATA-TYPE = "CHARACTER"
    c-f-disc:FORMAT    = "x(" + string(C-f-disc:WIDTH-CHARS) + ")"
    c-f-disc:screen-value = string('')  .
End.
if c-f-disc-prc <>  ?  then do :
Assign
    l1f-disc-prc  = c-f-disc-prc:DATA-TYPE
    l2f-disc-prc  = c-f-disc-prc:FORMAT
    c-f-disc-prc:DATA-TYPE = "CHARACTER"
    c-f-disc-prc:FORMAT    = "x(" + string(C-f-disc-prc:WIDTH-CHARS) + ")"
    c-f-disc-prc:screen-value = string('')  .
End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
if c-f-crsa-sum <>  ?  then do :
Assign
    c-f-crsa-sum:DATA-TYPE = l1f-crsa-sum
    c-f-crsa-sum:FORMAT    = l2f-crsa-sum.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-cost-vat <>  ?  then do :
Assign
    c-f-cost-vat:DATA-TYPE = l1f-cost-vat
    c-f-cost-vat:FORMAT    = l2f-cost-vat.
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    c-f-cost-sum-novat:DATA-TYPE = l1f-cost-sum-novat
    c-f-cost-sum-novat:FORMAT    = l2f-cost-sum-novat.
End.
if c-f-sale-vat <>  ?  then do :
Assign
    c-f-sale-vat:DATA-TYPE = l1f-sale-vat
    c-f-sale-vat:FORMAT    = l2f-sale-vat.
End.
if c-f-sale-slt <>  ?  then do :
Assign
    c-f-sale-slt:DATA-TYPE = l1f-sale-slt
    c-f-sale-slt:FORMAT    = l2f-sale-slt.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-disc <>  ?  then do :
Assign
    c-f-disc:DATA-TYPE = l1f-disc
    c-f-disc:FORMAT    = l2f-disc.
End.
if c-f-disc-prc <>  ?  then do :
Assign
    c-f-disc-prc:DATA-TYPE = l1f-disc-prc
    c-f-disc-prc:FORMAT    = l2f-disc-prc.
End.
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
   if Make-Excel then  put   stream ForExcel unformatted  obj-list.obj-name chr(10).
   End.
          n-nn = 0.
          n-no = n-no + 1 .
 For Each ub.ot-line where
          ub.ot-line.fact-order <= fact-order-2 and
          ub.ot-line.fact-order >= fact-order-1 and
          ub.ot-line.obj-code    = obj-list.obj-code and
          ub.ot-line.obj-type    = obj-list.obj-type  no-lock ,
          First tdedt where ub.ot-line.ext-doc-type   = tdedt.id  no-lock
            break
                by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
                by ub.ot-line.prod-type By ub.ot-line.prod-code by ub.ot-line.artic
                by ub.ot-line.sum-type
                with FRAME Zapas :
          accumulate ub.ot-line.fact-qnty  (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.sum-base    (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.vat-base   (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.slt-base   (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.other-base (TOTAL BY ub.ot-line.sum-type ).
          if last-of(ub.ot-line.sum-type) then DO :
          Case  ub.ot-line.sum-type :
              when 'cost':U then do:
                f-cost-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-cost-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
              end.
              when 'sale':U then do:
                 f-sale-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                 f-sale-other = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.other-base .
                 f-sale-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
                 f-sale-slt = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.slt-base .
              end.
              when  'crsa':U then do:
                f-crsa-sum1 = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-qnty1 = accum TOTAL BY  ub.ot-line.sum-type ub.ot-line.fact-qnty.
              end.
              when 'cssr':U then do:
                f-cost-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-cost-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
              end.
              when 'sasr':U then do:
                 f-sale-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                 f-sale-other = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.other-base .
                 f-sale-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
                 f-sale-slt = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.slt-base .
              end.
              when 'cgsr':U then do:
                f-crsa-sum2 = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-qnty2 = accum TOTAL BY  ub.ot-line.sum-type ub.ot-line.fact-qnty.
              end.
          End case.
          f-qnty = f-qnty2 + f-qnty1.
          f-crsa-sum = f-crsa-sum2 + f-crsa-sum1.
          End.
          if last-of(ub.ot-line.artic) then DO:
             n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
             find first goods where  ub.ot-line.prod-type = goods.prod-type and
                                       ub.ot-line.prod-code = goods.prod-code and
                                       ub.ot-line.artic     = goods.artic no-lock no-error .
             f-cost-sum-novat = f-cost-sum - f-cost-vat .
             f-disc = f-sale-sum - f-sale-vat - f-sale-slt - f-cost-sum-novat.
             f-disc-prc = (f-disc / f-cost-sum-novat * 100)  .
             if itog = false
                AND NOT (f-qnty=0 and f-crsa-sum =0  and f-sale-sum =0  and  f-cost-sum =0  and  f-disc =0  )
                Then DO:
                n-nn = n-nn + 1.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.ot-line.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(goods.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc-prc <>  ?  then do :
    c-f-disc-prc:screen-value = string(f-disc-prc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                    display stream OutStream  no-error .
                    DOWN stream OutStream .
                    if Make-Excel then  put   stream ForExcel unformatted
                     string(n-nn)     CHR(9)
                     (ub.ot-line.artic)    CHR(9)
                     goods.gds-name   CHR(9)
                     excel-qnty(f-qnty)           CHR(9)
                     excel-sum (f-cost-sum)       CHR(9)
                     excel-sum (f-cost-vat)       CHR(9)
                     excel-sum (f-cost-sum-novat) CHR(9)
                     excel-sum (f-sale-sum)       CHR(9)
                     excel-sum (f-sale-other)     CHR(9)
                     excel-sum (f-sale-vat)       CHR(9)
                     excel-sum (f-sale-slt)       CHR(9)
                     excel-sum (f-disc)           CHR(9)
                     excel-qnty(f-disc-prc)       CHR(9)
                     excel-sum (f-crsa-sum)       chr(10) .
             End.
              accumulate f-qnty           (TOTAL ) .
              accumulate f-crsa-sum       (TOTAL ) .
              accumulate f-sale-sum       (TOTAL ) .
              accumulate f-cost-sum       (TOTAL ) .
              accumulate f-cost-vat       (TOTAL ) .
              accumulate f-sale-vat       (TOTAL ) .
              accumulate f-sale-slt       (TOTAL ) .
              accumulate f-sale-other     (TOTAL ) .
              accumulate f-disc           (TOTAL ) .
              accumulate f-cost-sum-novat (TOTAL ) .
                Assign
                  f-qnty           = 0
                  f-crsa-sum       = 0
                  f-qnty1           = 0
                  f-crsa-sum1       = 0
                  f-qnty2           = 0
                  f-crsa-sum2       = 0
                  f-sale-sum       = 0
                  f-cost-sum       = 0
                  f-cost-vat       = 0
                  f-cost-sum-novat = 0
                  f-sale-vat       = 0
                  f-sale-slt       = 0
                  f-sale-other     = 0
                  f-disc           = 0
                  f-disc-prc       = 0
                 .
          End.
 End.
 run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объекту') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream no-error.
  DOWN stream OutStream .
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объекту"                    CHR(9)
          obj-list.obj-name               CHR(9)
          excel-qnty(accum TOTAL f-qnty           )   CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )   CHR(9)
          excel-sum (accum TOTAL f-cost-vat       )   CHR(9)
          excel-sum (accum TOTAL f-cost-sum-novat )   CHR(9)
          excel-sum (accum TOTAL f-sale-sum      )    CHR(9)
          excel-sum (accum TOTAL f-sale-other    )    CHR(9)
          excel-sum (accum TOTAL f-sale-vat      )    CHR(9)
          excel-sum (accum TOTAL f-sale-slt      )    CHR(9)
          excel-sum (accum TOTAL f-disc         )     CHR(9) CHR(9)
          excel-sum (accum TOTAL f-crsa-sum      )    chr(10) .
End.
   if n-no > 1 then do:
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('ПО ВСЕМ ОБЬЕКТАМ') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line.
         if Make-Excel then  put   stream ForExcel unformatted
         "ИТОГО"                       CHR(9)
         "ПО ВСЕМ ОБЬЕКТАМ"            CHR(9)
         excel-qnty(accum TOTAL f-qnty        )    CHR(9)
         excel-sum (accum TOTAL f-cost-sum    )    CHR(9)
         excel-sum (accum TOTAL f-cost-vat    )    CHR(9)
         excel-sum (accum TOTAL f-cost-sum-novat ) CHR(9)
         excel-sum (accum TOTAL f-sale-sum       ) CHR(9)
         excel-sum (accum TOTAL f-sale-other    )  CHR(9)
         excel-sum (accum TOTAL f-sale-vat      )  CHR(9)
         excel-sum (accum TOTAL f-sale-slt      )  CHR(9)
         excel-sum (accum TOTAL f-disc          )  CHR(9) CHR(9)
         excel-sum (accum TOTAL f-crsa-sum      )  chr(10) .
    End.
END PROCEDURE.
PROCEDURE foreach2 :
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
  for each obj-list no-lock with FRAME Zapas :
    if NOT( classify = 1 and Itog = true) then dO:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-crsa-sum <>  ?  then do :
Assign
    l1f-crsa-sum  = c-f-crsa-sum:DATA-TYPE
    l2f-crsa-sum  = c-f-crsa-sum:FORMAT
    c-f-crsa-sum:DATA-TYPE = "CHARACTER"
    c-f-crsa-sum:FORMAT    = "x(" + string(C-f-crsa-sum:WIDTH-CHARS) + ")"
    c-f-crsa-sum:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-cost-vat <>  ?  then do :
Assign
    l1f-cost-vat  = c-f-cost-vat:DATA-TYPE
    l2f-cost-vat  = c-f-cost-vat:FORMAT
    c-f-cost-vat:DATA-TYPE = "CHARACTER"
    c-f-cost-vat:FORMAT    = "x(" + string(C-f-cost-vat:WIDTH-CHARS) + ")"
    c-f-cost-vat:screen-value = string('')  .
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    l1f-cost-sum-novat  = c-f-cost-sum-novat:DATA-TYPE
    l2f-cost-sum-novat  = c-f-cost-sum-novat:FORMAT
    c-f-cost-sum-novat:DATA-TYPE = "CHARACTER"
    c-f-cost-sum-novat:FORMAT    = "x(" + string(C-f-cost-sum-novat:WIDTH-CHARS) + ")"
    c-f-cost-sum-novat:screen-value = string('')  .
End.
if c-f-sale-vat <>  ?  then do :
Assign
    l1f-sale-vat  = c-f-sale-vat:DATA-TYPE
    l2f-sale-vat  = c-f-sale-vat:FORMAT
    c-f-sale-vat:DATA-TYPE = "CHARACTER"
    c-f-sale-vat:FORMAT    = "x(" + string(C-f-sale-vat:WIDTH-CHARS) + ")"
    c-f-sale-vat:screen-value = string('')  .
End.
if c-f-sale-slt <>  ?  then do :
Assign
    l1f-sale-slt  = c-f-sale-slt:DATA-TYPE
    l2f-sale-slt  = c-f-sale-slt:FORMAT
    c-f-sale-slt:DATA-TYPE = "CHARACTER"
    c-f-sale-slt:FORMAT    = "x(" + string(C-f-sale-slt:WIDTH-CHARS) + ")"
    c-f-sale-slt:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-disc <>  ?  then do :
Assign
    l1f-disc  = c-f-disc:DATA-TYPE
    l2f-disc  = c-f-disc:FORMAT
    c-f-disc:DATA-TYPE = "CHARACTER"
    c-f-disc:FORMAT    = "x(" + string(C-f-disc:WIDTH-CHARS) + ")"
    c-f-disc:screen-value = string('')  .
End.
if c-f-disc-prc <>  ?  then do :
Assign
    l1f-disc-prc  = c-f-disc-prc:DATA-TYPE
    l2f-disc-prc  = c-f-disc-prc:FORMAT
    c-f-disc-prc:DATA-TYPE = "CHARACTER"
    c-f-disc-prc:FORMAT    = "x(" + string(C-f-disc-prc:WIDTH-CHARS) + ")"
    c-f-disc-prc:screen-value = string('')  .
End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
if c-f-crsa-sum <>  ?  then do :
Assign
    c-f-crsa-sum:DATA-TYPE = l1f-crsa-sum
    c-f-crsa-sum:FORMAT    = l2f-crsa-sum.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-cost-vat <>  ?  then do :
Assign
    c-f-cost-vat:DATA-TYPE = l1f-cost-vat
    c-f-cost-vat:FORMAT    = l2f-cost-vat.
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    c-f-cost-sum-novat:DATA-TYPE = l1f-cost-sum-novat
    c-f-cost-sum-novat:FORMAT    = l2f-cost-sum-novat.
End.
if c-f-sale-vat <>  ?  then do :
Assign
    c-f-sale-vat:DATA-TYPE = l1f-sale-vat
    c-f-sale-vat:FORMAT    = l2f-sale-vat.
End.
if c-f-sale-slt <>  ?  then do :
Assign
    c-f-sale-slt:DATA-TYPE = l1f-sale-slt
    c-f-sale-slt:FORMAT    = l2f-sale-slt.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-disc <>  ?  then do :
Assign
    c-f-disc:DATA-TYPE = l1f-disc
    c-f-disc:FORMAT    = l2f-disc.
End.
if c-f-disc-prc <>  ?  then do :
Assign
    c-f-disc-prc:DATA-TYPE = l1f-disc-prc
    c-f-disc-prc:FORMAT    = l2f-disc-prc.
End.
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
   if Make-Excel then  put   stream ForExcel unformatted  obj-list.obj-name chr(10).
   End.
          n-nn = 0.
          n-no = n-no + 1 .
 For Each ub.ot-line where
          ub.ot-line.fact-order <= fact-order-2 and
          ub.ot-line.fact-order >= fact-order-1 and
          ub.ot-line.obj-code    = obj-list.obj-code and
          ub.ot-line.obj-type    = obj-list.obj-type  no-lock ,
          First tdedt where ub.ot-line.ext-doc-type   = tdedt.id  no-lock
            break
                by ub.ot-line.prod-type By ub.ot-line.prod-code by ub.ot-line.artic
                by ub.ot-line.sum-type
                with FRAME Zapas :
          accumulate ub.ot-line.fact-qnty  (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.sum-base    (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.vat-base   (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.slt-base   (TOTAL BY ub.ot-line.sum-type ).
          accumulate ub.ot-line.other-base (TOTAL BY ub.ot-line.sum-type ).
          if first-of(ub.ot-line.prod-code)  and classify = 2 then DO:
              FIND FIRST clients-p where  ub.ot-line.prod-type = clients-p.obj-type AND
                                          ub.ot-line.prod-code = clients-p.obj-code no-lock no-error.
               if avail clients-p then var-client = Clients-p.obj-name.
                  if  Itog = false Then do:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(var-client) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                    Display stream OutStream .
                    DOWN stream OutStream .
                    if Make-Excel then  put   stream ForExcel unformatted var-client chr(10) .
                  End.
          End.
          if last-of(ub.ot-line.sum-type) then DO :
          Case  ub.ot-line.sum-type :
              when 'cost':U then do:
                f-cost-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-cost-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
              end.
              when 'sale':U then do:
                 f-sale-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                 f-sale-other = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.other-base .
                 f-sale-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
                 f-sale-slt = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.slt-base .
              end.
              when  'crsa':U then do:
                f-crsa-sum1 = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-qnty1 = accum TOTAL BY  ub.ot-line.sum-type ub.ot-line.fact-qnty.
              end.
              when 'cssr':U then do:
                f-cost-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-cost-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
              end.
              when 'sasr':U then do:
                 f-sale-sum = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                 f-sale-other = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.other-base .
                 f-sale-vat = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.vat-base .
                 f-sale-slt = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.slt-base .
              end.
              when 'cgsr':U then do:
                f-crsa-sum2 = accum TOTAL BY ub.ot-line.sum-type ub.ot-line.sum-base .
                f-qnty2 = accum TOTAL BY  ub.ot-line.sum-type ub.ot-line.fact-qnty.
              end.
          End case.
          f-qnty = f-qnty2 + f-qnty1.
          f-crsa-sum = f-crsa-sum2 + f-crsa-sum1.
          End.
          if last-of(ub.ot-line.artic) then DO:
             n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
             find first goods where  ub.ot-line.prod-type = goods.prod-type and
                                       ub.ot-line.prod-code = goods.prod-code and
                                       ub.ot-line.artic     = goods.artic no-lock no-error .
             f-cost-sum-novat = f-cost-sum - f-cost-vat .
             f-disc = f-sale-sum - f-sale-vat - f-sale-slt - f-cost-sum-novat.
             f-disc-prc = (f-disc / f-cost-sum-novat * 100)  .
             if itog = false
                AND NOT (f-qnty=0 and f-crsa-sum =0  and f-sale-sum =0  and  f-cost-sum =0  and  f-disc =0  )
                Then DO:
                n-nn = n-nn + 1.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.ot-line.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(goods.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc-prc <>  ?  then do :
    c-f-disc-prc:screen-value = string(f-disc-prc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                    display stream OutStream  no-error .
                    DOWN stream OutStream .
                    if Make-Excel then  put   stream ForExcel unformatted
                     string(n-nn)     CHR(9)
                     (ub.ot-line.artic)    CHR(9)
                     goods.gds-name   CHR(9)
                     excel-qnty(f-qnty)           CHR(9)
                     excel-sum (f-cost-sum)       CHR(9)
                     excel-sum (f-cost-vat)       CHR(9)
                     excel-sum (f-cost-sum-novat) CHR(9)
                     excel-sum (f-sale-sum)       CHR(9)
                     excel-sum (f-sale-other)     CHR(9)
                     excel-sum (f-sale-vat)       CHR(9)
                     excel-sum (f-sale-slt)       CHR(9)
                     excel-sum (f-disc)           CHR(9)
                     excel-qnty(f-disc-prc)       CHR(9)
                     excel-sum (f-crsa-sum)       chr(10) .
             End.
              accumulate f-qnty           (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-crsa-sum       (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-sale-sum       (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-cost-sum       (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-cost-vat       (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-sale-vat       (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-sale-slt       (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-sale-other     (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-disc           (TOTAL by ub.ot-line.prod-code ) .
              accumulate f-cost-sum-novat (TOTAL by ub.ot-line.prod-code ) .
                   if last-of(ub.ot-line.prod-code) and classify = 2 then do:
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по произв.') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(var-client) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL by ub.ot-line.prod-code f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                       Display stream OutStream  no-error .
                       DOWN stream OutStream .
                       if Make-Excel then  put   stream ForExcel unformatted
                        "Итого"                                              CHR(9)
                        "по произв."
                        var-client                                           CHR(9)
                        excel-qnty(accum TOTAL by ub.ot-line.prod-code f-qnty          )    CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-cost-sum       )   CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-cost-vat       )   CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-cost-sum-novat )   CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-sum       )   CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-other     )   CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-vat       )   CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-sale-slt       )   CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code f-disc           )   CHR(9) CHR(9)
                        excel-sum (accum TOTAL by ub.ot-line.prod-code  f-crsa-sum      )   chr(10) .
                   End.
                Assign
                  f-qnty           = 0
                  f-crsa-sum       = 0
                  f-qnty1           = 0
                  f-crsa-sum1       = 0
                  f-qnty2           = 0
                  f-crsa-sum2       = 0
                  f-sale-sum       = 0
                  f-cost-sum       = 0
                  f-cost-vat       = 0
                  f-cost-sum-novat = 0
                  f-sale-vat       = 0
                  f-sale-slt       = 0
                  f-sale-other     = 0
                  f-disc           = 0
                  f-disc-prc       = 0
                 .
          End.
 End.
 run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объекту') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream no-error.
  DOWN stream OutStream .
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объекту"                    CHR(9)
          obj-list.obj-name               CHR(9)
          excel-qnty(accum TOTAL f-qnty           )   CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )   CHR(9)
          excel-sum (accum TOTAL f-cost-vat       )   CHR(9)
          excel-sum (accum TOTAL f-cost-sum-novat )   CHR(9)
          excel-sum (accum TOTAL f-sale-sum      )    CHR(9)
          excel-sum (accum TOTAL f-sale-other    )    CHR(9)
          excel-sum (accum TOTAL f-sale-vat      )    CHR(9)
          excel-sum (accum TOTAL f-sale-slt      )    CHR(9)
          excel-sum (accum TOTAL f-disc         )     CHR(9) CHR(9)
          excel-sum (accum TOTAL f-crsa-sum      )    chr(10) .
End.
   if n-no > 1 then do:
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('ПО ВСЕМ ОБЬЕКТАМ') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line.
         if Make-Excel then  put   stream ForExcel unformatted
         "ИТОГО"                       CHR(9)
         "ПО ВСЕМ ОБЬЕКТАМ"            CHR(9)
         excel-qnty(accum TOTAL f-qnty        )    CHR(9)
         excel-sum (accum TOTAL f-cost-sum    )    CHR(9)
         excel-sum (accum TOTAL f-cost-vat    )    CHR(9)
         excel-sum (accum TOTAL f-cost-sum-novat ) CHR(9)
         excel-sum (accum TOTAL f-sale-sum       ) CHR(9)
         excel-sum (accum TOTAL f-sale-other    )  CHR(9)
         excel-sum (accum TOTAL f-sale-vat      )  CHR(9)
         excel-sum (accum TOTAL f-sale-slt      )  CHR(9)
         excel-sum (accum TOTAL f-disc          )  CHR(9) CHR(9)
         excel-sum (accum TOTAL f-crsa-sum      )  chr(10) .
    End.
END PROCEDURE.
PROCEDURE foreach3 :
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
   Assign
    ff-qnty           = 0
    ff-crsa-sum       = 0
    ff-sale-sum       = 0
    ff-cost-sum       = 0
    ff-cost-vat       = 0
    ff-cost-sum-novat = 0
    ff-sale-vat       = 0
    ff-sale-slt       = 0
    ff-sale-other     = 0
    ff-disc           = 0
    ff-disc-prc       = 0
    .
  For each obj-list no-lock break by obj-list.obj-type by obj-list.obj-code
   with FRAME Zapas :
      if NOT (itog = true and classify = 1) Then DO :
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-crsa-sum <>  ?  then do :
Assign
    l1f-crsa-sum  = c-f-crsa-sum:DATA-TYPE
    l2f-crsa-sum  = c-f-crsa-sum:FORMAT
    c-f-crsa-sum:DATA-TYPE = "CHARACTER"
    c-f-crsa-sum:FORMAT    = "x(" + string(C-f-crsa-sum:WIDTH-CHARS) + ")"
    c-f-crsa-sum:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-cost-vat <>  ?  then do :
Assign
    l1f-cost-vat  = c-f-cost-vat:DATA-TYPE
    l2f-cost-vat  = c-f-cost-vat:FORMAT
    c-f-cost-vat:DATA-TYPE = "CHARACTER"
    c-f-cost-vat:FORMAT    = "x(" + string(C-f-cost-vat:WIDTH-CHARS) + ")"
    c-f-cost-vat:screen-value = string('')  .
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    l1f-cost-sum-novat  = c-f-cost-sum-novat:DATA-TYPE
    l2f-cost-sum-novat  = c-f-cost-sum-novat:FORMAT
    c-f-cost-sum-novat:DATA-TYPE = "CHARACTER"
    c-f-cost-sum-novat:FORMAT    = "x(" + string(C-f-cost-sum-novat:WIDTH-CHARS) + ")"
    c-f-cost-sum-novat:screen-value = string('')  .
End.
if c-f-sale-vat <>  ?  then do :
Assign
    l1f-sale-vat  = c-f-sale-vat:DATA-TYPE
    l2f-sale-vat  = c-f-sale-vat:FORMAT
    c-f-sale-vat:DATA-TYPE = "CHARACTER"
    c-f-sale-vat:FORMAT    = "x(" + string(C-f-sale-vat:WIDTH-CHARS) + ")"
    c-f-sale-vat:screen-value = string('')  .
End.
if c-f-sale-slt <>  ?  then do :
Assign
    l1f-sale-slt  = c-f-sale-slt:DATA-TYPE
    l2f-sale-slt  = c-f-sale-slt:FORMAT
    c-f-sale-slt:DATA-TYPE = "CHARACTER"
    c-f-sale-slt:FORMAT    = "x(" + string(C-f-sale-slt:WIDTH-CHARS) + ")"
    c-f-sale-slt:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-disc <>  ?  then do :
Assign
    l1f-disc  = c-f-disc:DATA-TYPE
    l2f-disc  = c-f-disc:FORMAT
    c-f-disc:DATA-TYPE = "CHARACTER"
    c-f-disc:FORMAT    = "x(" + string(C-f-disc:WIDTH-CHARS) + ")"
    c-f-disc:screen-value = string('')  .
End.
if c-f-disc-prc <>  ?  then do :
Assign
    l1f-disc-prc  = c-f-disc-prc:DATA-TYPE
    l2f-disc-prc  = c-f-disc-prc:FORMAT
    c-f-disc-prc:DATA-TYPE = "CHARACTER"
    c-f-disc-prc:FORMAT    = "x(" + string(C-f-disc-prc:WIDTH-CHARS) + ")"
    c-f-disc-prc:screen-value = string('')  .
End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
if c-f-crsa-sum <>  ?  then do :
Assign
    c-f-crsa-sum:DATA-TYPE = l1f-crsa-sum
    c-f-crsa-sum:FORMAT    = l2f-crsa-sum.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-cost-vat <>  ?  then do :
Assign
    c-f-cost-vat:DATA-TYPE = l1f-cost-vat
    c-f-cost-vat:FORMAT    = l2f-cost-vat.
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    c-f-cost-sum-novat:DATA-TYPE = l1f-cost-sum-novat
    c-f-cost-sum-novat:FORMAT    = l2f-cost-sum-novat.
End.
if c-f-sale-vat <>  ?  then do :
Assign
    c-f-sale-vat:DATA-TYPE = l1f-sale-vat
    c-f-sale-vat:FORMAT    = l2f-sale-vat.
End.
if c-f-sale-slt <>  ?  then do :
Assign
    c-f-sale-slt:DATA-TYPE = l1f-sale-slt
    c-f-sale-slt:FORMAT    = l2f-sale-slt.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-disc <>  ?  then do :
Assign
    c-f-disc:DATA-TYPE = l1f-disc
    c-f-disc:FORMAT    = l2f-disc.
End.
if c-f-disc-prc <>  ?  then do :
Assign
    c-f-disc-prc:DATA-TYPE = l1f-disc-prc
    c-f-disc-prc:FORMAT    = l2f-disc-prc.
End.
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
      End.
          n-nn = 0.
          n-no = n-no + 1 .
 For Each ub.ot-line where
          ub.ot-line.fact-order <= fact-order-2 and
          ub.ot-line.fact-order >= fact-order-1 and
          ub.ot-line.obj-code    = obj-list.obj-code and
          ub.ot-line.obj-type    = obj-list.obj-type and
          (
          ub.ot-line.sum-type    = string('cost':U) + String('v':U)
          OR
          ub.ot-line.sum-type    =
           'cssr':U
          )
          no-lock ,
          First tdedt where ub.ot-line.ext-doc-type   = tdedt.id  no-lock
            break
                by   entry(1,ub.ot-line.cat-id)
                by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
                by ub.ot-line.prod-type By ub.ot-line.prod-code by ub.ot-line.artic
                with FRAME Zapas :
            accumulate ub.ot-line.fact-qnty     (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.sum-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.vat-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.slt-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.other-base     (TOTAL by  ub.ot-line.artic ) .
      if first-of( entry(1,ub.ot-line.cat-id) ) then DO:
       for each wt share-lock : delete wt. end.
                  if  Itog = false Then do:
                      f-artic  =  "Ставка НДС"  .
                      f-gds-name =  entry(1,ub.ot-line.cat-id) + '%' .
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(f-gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                       Display stream OutStream .
                       DOWN stream OutStream .
                       if Make-Excel then  put   stream ForExcel unformatted
                              "Ставка НДС"  CHR(9)
                               entry(1,ub.ot-line.cat-id) + "%"  chr(10) .
                  End.
      End.
      Create WT.
      Assign WT.doc-code = ub.ot-line.doc-code.
      if last-of(ub.ot-line.artic) then DO:
                n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
                find first goods where  ub.ot-line.prod-type = goods.prod-type and
                                        ub.ot-line.prod-code = goods.prod-code and
                                        ub.ot-line.artic     = goods.artic no-lock no-error .
               f-qnty       = accum  TOTAL by  ub.ot-line.artic ub.ot-line.fact-qnty  .
               f-cost-sum   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.sum-base   .
               f-cost-vat   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.vat-base   .
                f-crsa-sum = 0.
                For each crsa-ot-line where
                    crsa-ot-line.fact-order >= fact-order-1 and
                    crsa-ot-line.fact-order <= fact-order-2 and
                    crsa-ot-line.obj-code    = ub.ot-line.obj-code and
                    crsa-ot-line.obj-type    = ub.ot-line.obj-type and
                    crsa-ot-line.prod-type   = ub.ot-line.prod-type and
                    crsa-ot-line.prod-code   = ub.ot-line.prod-code and
                    crsa-ot-line.artic       = ub.ot-line.artic and
                    (crsa-ot-line.sum-type    = 'crsa':U OR
                    crsa-ot-line.sum-type    = 'cgsr':U )
                    no-lock ,
                       First buf-tdedt where  buf-tdedt.id = crsa-ot-line.ext-doc-type  no-lock,
                       first wt where wt.doc-code = crsa-ot-line.doc-code
                    no-lock :
                  f-crsa-sum   = f-crsa-sum + crsa-ot-line.sum-base   .
                End.
                f-sale-sum   = 0 .
                f-sale-vat   = 0 .
                f-sale-slt   = 0 .
                f-sale-other = 0 .
                For each alt-ot-line where
                    alt-ot-line.fact-order >= fact-order-1 and
                    alt-ot-line.fact-order <= fact-order-2 and
                    alt-ot-line.obj-code    = ub.ot-line.obj-code and
                    alt-ot-line.obj-type    = ub.ot-line.obj-type and
                    alt-ot-line.prod-type   = ub.ot-line.prod-type and
                    alt-ot-line.prod-code   = ub.ot-line.prod-code and
                    alt-ot-line.artic       = ub.ot-line.artic and
                    alt-ot-line.sum-type    = 'sale':U
                    no-lock ,
                       First buf-tdedt where alt-ot-line.ext-doc-type   = buf-tdedt.id  no-lock,
                       first wt where wt.doc-code = alt-ot-line.doc-code
                    no-lock :
                      f-sale-sum   = f-sale-sum    + alt-ot-line.sum-base   .
                      f-sale-vat   = f-sale-vat    + alt-ot-line.vat-base   .
                      f-sale-slt   = f-sale-slt    + alt-ot-line.slt-base   .
                      f-sale-other = f-sale-other  + alt-ot-line.other-base .
                    End.
                f-cost-sum-novat = f-cost-sum - f-cost-vat .
                f-disc = f-sale-sum - f-sale-vat - f-sale-slt - f-cost-sum-novat.
                f-disc-prc = (f-disc / f-cost-sum-novat * 100)  .
              if itog = false
                 AND NOT (f-qnty=0 and f-crsa-sum =0  and f-sale-sum =0  and  f-cost-sum =0  and  f-disc =0  )
                 Then DO:
                 n-nn = n-nn + 1.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.ot-line.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(goods.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc-prc <>  ?  then do :
    c-f-disc-prc:screen-value = string(f-disc-prc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                  display stream OutStream  no-error .
                  DOWN stream OutStream .
                  if Make-Excel then  put   stream ForExcel unformatted
                        string(n-nn)     CHR(9)
                        (ub.ot-line.artic)    CHR(9)
                        goods.gds-name   CHR(9)
                        excel-qnty(f-qnty        )   CHR(9)
                        excel-sum (f-cost-sum     )  CHR(9)
                        excel-sum (f-cost-vat     )  CHR(9)
                        excel-sum (f-cost-sum-novat) CHR(9)
                        excel-sum (f-sale-sum      ) CHR(9)
                        excel-sum (f-sale-other    ) CHR(9)
                        excel-sum (f-sale-vat      ) CHR(9)
                        excel-sum (f-sale-slt      ) CHR(9)
                        excel-sum (f-disc          ) CHR(9)
                        excel-sum (f-disc-prc      ) CHR(9)
                        excel-sum(f-crsa-sum     )  chr(10).
                    End.
            accumulate f-qnty           (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-crsa-sum       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-sum       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-cost-sum       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-cost-vat       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-vat       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-slt       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-other     (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-disc           (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-cost-sum-novat (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
           End.
           if last-of( entry(1,ub.ot-line.cat-id) ) then do:
                    f-artic    = "по ставке НДС"  .
                    f-gds-name =  entry(1,ub.ot-line.cat-id) + "%" .
                       tf-qnty          =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-qnty          .
                       tf-crsa-sum      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-crsa-sum      .
                       tf-sale-sum      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-sum      .
                       tf-cost-sum      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum      .
                       tf-cost-vat      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-vat      .
                       tf-cost-sum-novat=accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum-novat.
                       tf-sale-vat     =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-vat      .
                       tf-sale-slt      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-slt      .
                       tf-sale-other    =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-other    .
                       tf-disc          =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-disc          .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(f-gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(tf-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(tf-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(tf-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(tf-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(tf-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(tf-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(tf-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(tf-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(tf-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(tf-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                    Display stream OutStream  no-error  .
                    DOWN stream OutStream .
                        if Make-Excel then  put   stream ForExcel unformatted                                                                                                       CHR(9)
                        "Итого"                                                                                                       CHR(9)
                        "по ставке НДС"  CHR(9)
                         entry(1,ub.ot-line.cat-id) + "%"                             CHR(9)
                        excel-qnty(accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-qnty          )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-vat      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum-novat)  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-sum      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-other    )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-vat      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-slt      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-disc          )  CHR(9) CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-crsa-sum      )  chr(10).
                      Assign
                       ff-qnty           = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-qnty
                       ff-crsa-sum       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-crsa-sum
                       ff-sale-sum       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-sum
                       ff-cost-sum       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-cost-sum
                       ff-cost-vat       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-cost-vat
                       ff-cost-sum-novat = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-cost-sum-novat
                       ff-sale-vat       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-vat
                       ff-sale-slt       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-slt
                       ff-sale-other     = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-other
                       ff-disc           = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-disc
                       .
              accumulate ff-qnty           (TOTAL by obj-list.obj-code) .
              accumulate ff-crsa-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-slt       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-other     (TOTAL by obj-list.obj-code) .
              accumulate ff-disc           (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum-novat (TOTAL by obj-list.obj-code) .
            End.
                Assign
                  f-qnty           = 0
                  f-crsa-sum       = 0
                  f-sale-sum       = 0
                  f-cost-sum       = 0
                  f-cost-vat       = 0
                  f-cost-sum-novat = 0
                  f-sale-vat       = 0
                  f-sale-slt       = 0
                  f-sale-other     = 0
                  f-disc           = 0
                  f-disc-prc       = 0
                 .
 End.
   run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объекту') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by obj-list.obj-code ff-qnty     ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-crsa-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-vat ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-vat      ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-slt      ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-other    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL by obj-list.obj-code ff-disc          ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                                             CHR(9)
          "по объекту"                                        CHR(9)
          obj-list.obj-name                                   CHR(9)
          excel-qnty(accum TOTAL by obj-list.obj-code ff-qnty          )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-vat      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum-novat)  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-sum      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-other    )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-vat      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-slt      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-disc          )  CHR(9)   CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-crsa-sum      )  chr(10).
End.
 if n-no > 1 then do:
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('ПО ВСЕМ ОБЬЕКТАМ') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL  ff-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL  ff-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL  ff-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL  ff-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL  ff-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL  ff-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL  ff-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL  ff-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL  ff-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL  ff-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream
          with FRAME Zapas no-error .
          DOWN stream OutStream with FRAME Zapas.
          if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                            CHR(9)
          "ПО ВСЕМ ОБЬЕКТАМ"                 CHR(9)
          excel-qnty(accum TOTAL  ff-qnty            )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-sum        )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-vat        )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-sum-novat  )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-sum        )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-other      )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-vat        )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-slt        )   CHR(9)
          excel-sum (accum TOTAL  ff-disc            )   CHR(9) CHR(9)
          excel-sum (accum TOTAL  ff-crsa-sum        )   chr(10).
         run u-line.
  End.
END PROCEDURE.
PROCEDURE foreach4 :
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
   Assign
    ff-qnty           = 0
    ff-crsa-sum       = 0
    ff-sale-sum       = 0
    ff-cost-sum       = 0
    ff-cost-vat       = 0
    ff-cost-sum-novat = 0
    ff-sale-vat       = 0
    ff-sale-slt       = 0
    ff-sale-other     = 0
    ff-disc           = 0
    ff-disc-prc       = 0
    .
  For each obj-list no-lock break by obj-list.obj-type by obj-list.obj-code
   with FRAME Zapas :
      if NOT (itog = true and classify = 1) Then DO :
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-crsa-sum <>  ?  then do :
Assign
    l1f-crsa-sum  = c-f-crsa-sum:DATA-TYPE
    l2f-crsa-sum  = c-f-crsa-sum:FORMAT
    c-f-crsa-sum:DATA-TYPE = "CHARACTER"
    c-f-crsa-sum:FORMAT    = "x(" + string(C-f-crsa-sum:WIDTH-CHARS) + ")"
    c-f-crsa-sum:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-cost-vat <>  ?  then do :
Assign
    l1f-cost-vat  = c-f-cost-vat:DATA-TYPE
    l2f-cost-vat  = c-f-cost-vat:FORMAT
    c-f-cost-vat:DATA-TYPE = "CHARACTER"
    c-f-cost-vat:FORMAT    = "x(" + string(C-f-cost-vat:WIDTH-CHARS) + ")"
    c-f-cost-vat:screen-value = string('')  .
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    l1f-cost-sum-novat  = c-f-cost-sum-novat:DATA-TYPE
    l2f-cost-sum-novat  = c-f-cost-sum-novat:FORMAT
    c-f-cost-sum-novat:DATA-TYPE = "CHARACTER"
    c-f-cost-sum-novat:FORMAT    = "x(" + string(C-f-cost-sum-novat:WIDTH-CHARS) + ")"
    c-f-cost-sum-novat:screen-value = string('')  .
End.
if c-f-sale-vat <>  ?  then do :
Assign
    l1f-sale-vat  = c-f-sale-vat:DATA-TYPE
    l2f-sale-vat  = c-f-sale-vat:FORMAT
    c-f-sale-vat:DATA-TYPE = "CHARACTER"
    c-f-sale-vat:FORMAT    = "x(" + string(C-f-sale-vat:WIDTH-CHARS) + ")"
    c-f-sale-vat:screen-value = string('')  .
End.
if c-f-sale-slt <>  ?  then do :
Assign
    l1f-sale-slt  = c-f-sale-slt:DATA-TYPE
    l2f-sale-slt  = c-f-sale-slt:FORMAT
    c-f-sale-slt:DATA-TYPE = "CHARACTER"
    c-f-sale-slt:FORMAT    = "x(" + string(C-f-sale-slt:WIDTH-CHARS) + ")"
    c-f-sale-slt:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-disc <>  ?  then do :
Assign
    l1f-disc  = c-f-disc:DATA-TYPE
    l2f-disc  = c-f-disc:FORMAT
    c-f-disc:DATA-TYPE = "CHARACTER"
    c-f-disc:FORMAT    = "x(" + string(C-f-disc:WIDTH-CHARS) + ")"
    c-f-disc:screen-value = string('')  .
End.
if c-f-disc-prc <>  ?  then do :
Assign
    l1f-disc-prc  = c-f-disc-prc:DATA-TYPE
    l2f-disc-prc  = c-f-disc-prc:FORMAT
    c-f-disc-prc:DATA-TYPE = "CHARACTER"
    c-f-disc-prc:FORMAT    = "x(" + string(C-f-disc-prc:WIDTH-CHARS) + ")"
    c-f-disc-prc:screen-value = string('')  .
End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
if c-f-crsa-sum <>  ?  then do :
Assign
    c-f-crsa-sum:DATA-TYPE = l1f-crsa-sum
    c-f-crsa-sum:FORMAT    = l2f-crsa-sum.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-cost-vat <>  ?  then do :
Assign
    c-f-cost-vat:DATA-TYPE = l1f-cost-vat
    c-f-cost-vat:FORMAT    = l2f-cost-vat.
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    c-f-cost-sum-novat:DATA-TYPE = l1f-cost-sum-novat
    c-f-cost-sum-novat:FORMAT    = l2f-cost-sum-novat.
End.
if c-f-sale-vat <>  ?  then do :
Assign
    c-f-sale-vat:DATA-TYPE = l1f-sale-vat
    c-f-sale-vat:FORMAT    = l2f-sale-vat.
End.
if c-f-sale-slt <>  ?  then do :
Assign
    c-f-sale-slt:DATA-TYPE = l1f-sale-slt
    c-f-sale-slt:FORMAT    = l2f-sale-slt.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-disc <>  ?  then do :
Assign
    c-f-disc:DATA-TYPE = l1f-disc
    c-f-disc:FORMAT    = l2f-disc.
End.
if c-f-disc-prc <>  ?  then do :
Assign
    c-f-disc-prc:DATA-TYPE = l1f-disc-prc
    c-f-disc-prc:FORMAT    = l2f-disc-prc.
End.
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
      End.
          n-nn = 0.
          n-no = n-no + 1 .
 For Each ub.ot-line where
          ub.ot-line.fact-order <= fact-order-2 and
          ub.ot-line.fact-order >= fact-order-1 and
          ub.ot-line.obj-code    = obj-list.obj-code and
          ub.ot-line.obj-type    = obj-list.obj-type and
          (
          ub.ot-line.sum-type    = string('sale':U) + String('')
          OR
          ub.ot-line.sum-type    =
           'sasr':U + String('')
          )
          no-lock ,
          First tdedt where ub.ot-line.ext-doc-type   = tdedt.id  no-lock
            break
                by   entry(1,ub.ot-line.cat-id)
                by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
                by ub.ot-line.prod-type By ub.ot-line.prod-code by ub.ot-line.artic
                with FRAME Zapas :
            accumulate ub.ot-line.fact-qnty     (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.sum-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.vat-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.slt-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.other-base     (TOTAL by  ub.ot-line.artic ) .
      if first-of( entry(1,ub.ot-line.cat-id) ) then DO:
       for each wt share-lock : delete wt. end.
                  if  Itog = false Then do:
                      f-artic  =  "Ставка НДС"  .
                      f-gds-name =  entry(1,ub.ot-line.cat-id) + '%' .
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(f-gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                       Display stream OutStream .
                       DOWN stream OutStream .
                       if Make-Excel then  put   stream ForExcel unformatted
                              "Ставка НДС"  CHR(9)
                               entry(1,ub.ot-line.cat-id) + "%"  chr(10) .
                  End.
      End.
      Create WT.
      Assign WT.doc-code = ub.ot-line.doc-code.
      if last-of(ub.ot-line.artic) then DO:
                n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
                find first goods where  ub.ot-line.prod-type = goods.prod-type and
                                        ub.ot-line.prod-code = goods.prod-code and
                                        ub.ot-line.artic     = goods.artic no-lock no-error .
               f-qnty       = accum  TOTAL by  ub.ot-line.artic ub.ot-line.fact-qnty  .
               f-sale-sum   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.sum-base   .
               f-sale-vat   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.vat-base   .
               f-sale-slt   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.slt-base   .
               f-sale-other = accum  TOTAL by  ub.ot-line.artic ub.ot-line.other-base .
                f-crsa-sum = 0.
                For each crsa-ot-line where
                    crsa-ot-line.fact-order >= fact-order-1 and
                    crsa-ot-line.fact-order <= fact-order-2 and
                    crsa-ot-line.obj-code    = ub.ot-line.obj-code and
                    crsa-ot-line.obj-type    = ub.ot-line.obj-type and
                    crsa-ot-line.prod-type   = ub.ot-line.prod-type and
                    crsa-ot-line.prod-code   = ub.ot-line.prod-code and
                    crsa-ot-line.artic       = ub.ot-line.artic and
                    (crsa-ot-line.sum-type    = 'crsa':U OR
                    crsa-ot-line.sum-type    = 'cgsr':U )
                    no-lock ,
                       First buf-tdedt where  buf-tdedt.id = crsa-ot-line.ext-doc-type  no-lock,
                       first wt where wt.doc-code = crsa-ot-line.doc-code
                    no-lock :
                  f-crsa-sum   = f-crsa-sum + crsa-ot-line.sum-base   .
                End.
                f-cost-sum   = 0 .
                f-cost-vat   = 0 .
                For each alt-ot-line where
                    alt-ot-line.fact-order >= fact-order-1 and
                    alt-ot-line.fact-order <= fact-order-2 and
                    alt-ot-line.obj-code    = ub.ot-line.obj-code and
                    alt-ot-line.obj-type    = ub.ot-line.obj-type and
                    alt-ot-line.prod-type   = ub.ot-line.prod-type and
                    alt-ot-line.prod-code   = ub.ot-line.prod-code and
                    alt-ot-line.artic       = ub.ot-line.artic and
                    alt-ot-line.sum-type    = 'cost':U
                    no-lock ,
                       First buf-tdedt where alt-ot-line.ext-doc-type   = buf-tdedt.id  no-lock,
                       first wt where wt.doc-code = alt-ot-line.doc-code
                    no-lock :
                      f-cost-sum   = f-cost-sum + alt-ot-line.sum-base   .
                      f-cost-vat   = f-cost-vat + alt-ot-line.vat-base   .
                    End.
                f-cost-sum-novat = f-cost-sum - f-cost-vat .
                f-disc = f-sale-sum - f-sale-vat - f-sale-slt - f-cost-sum-novat.
                f-disc-prc = (f-disc / f-cost-sum-novat * 100)  .
              if itog = false
                 AND NOT (f-qnty=0 and f-crsa-sum =0  and f-sale-sum =0  and  f-cost-sum =0  and  f-disc =0  )
                 Then DO:
                 n-nn = n-nn + 1.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.ot-line.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(goods.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc-prc <>  ?  then do :
    c-f-disc-prc:screen-value = string(f-disc-prc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                  display stream OutStream  no-error .
                  DOWN stream OutStream .
                  if Make-Excel then  put   stream ForExcel unformatted
                        string(n-nn)     CHR(9)
                        (ub.ot-line.artic)    CHR(9)
                        goods.gds-name   CHR(9)
                        excel-qnty(f-qnty        )   CHR(9)
                        excel-sum (f-cost-sum     )  CHR(9)
                        excel-sum (f-cost-vat     )  CHR(9)
                        excel-sum (f-cost-sum-novat) CHR(9)
                        excel-sum (f-sale-sum      ) CHR(9)
                        excel-sum (f-sale-other    ) CHR(9)
                        excel-sum (f-sale-vat      ) CHR(9)
                        excel-sum (f-sale-slt      ) CHR(9)
                        excel-sum (f-disc          ) CHR(9)
                        excel-sum (f-disc-prc      ) CHR(9)
                        excel-sum(f-crsa-sum     )  chr(10).
                    End.
            accumulate f-qnty           (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-crsa-sum       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-sum       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-cost-sum       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-cost-vat       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-vat       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-slt       (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-sale-other     (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-disc           (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
            accumulate f-cost-sum-novat (TOTAL  by   entry(1,ub.ot-line.cat-id) ) .
           End.
           if last-of( entry(1,ub.ot-line.cat-id) ) then do:
                    f-artic    = "по ставке НДС"  .
                    f-gds-name =  entry(1,ub.ot-line.cat-id) + "%" .
                       tf-qnty          =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-qnty          .
                       tf-crsa-sum      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-crsa-sum      .
                       tf-sale-sum      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-sum      .
                       tf-cost-sum      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum      .
                       tf-cost-vat      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-vat      .
                       tf-cost-sum-novat=accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum-novat.
                       tf-sale-vat     =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-vat      .
                       tf-sale-slt      =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-slt      .
                       tf-sale-other    =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-other    .
                       tf-disc          =accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-disc          .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(f-gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(tf-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(tf-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(tf-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(tf-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(tf-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(tf-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(tf-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(tf-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(tf-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(tf-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                    Display stream OutStream  no-error  .
                    DOWN stream OutStream .
                        if Make-Excel then  put   stream ForExcel unformatted                                                                                                       CHR(9)
                        "Итого"                                                                                                       CHR(9)
                        "по ставке НДС"  CHR(9)
                         entry(1,ub.ot-line.cat-id) + "%"                             CHR(9)
                        excel-qnty(accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-qnty          )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-vat      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-cost-sum-novat)  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-sum      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-other    )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-vat      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-sale-slt      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-disc          )  CHR(9) CHR(9)
                        excel-sum (accum TOTAL  by   entry(1,ub.ot-line.cat-id) f-crsa-sum      )  chr(10).
                      Assign
                       ff-qnty           = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-qnty
                       ff-crsa-sum       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-crsa-sum
                       ff-sale-sum       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-sum
                       ff-cost-sum       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-cost-sum
                       ff-cost-vat       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-cost-vat
                       ff-cost-sum-novat = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-cost-sum-novat
                       ff-sale-vat       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-vat
                       ff-sale-slt       = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-slt
                       ff-sale-other     = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-sale-other
                       ff-disc           = accum TOTAL by   entry(1,ub.ot-line.cat-id) f-disc
                       .
              accumulate ff-qnty           (TOTAL by obj-list.obj-code) .
              accumulate ff-crsa-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-slt       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-other     (TOTAL by obj-list.obj-code) .
              accumulate ff-disc           (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum-novat (TOTAL by obj-list.obj-code) .
            End.
                Assign
                  f-qnty           = 0
                  f-crsa-sum       = 0
                  f-sale-sum       = 0
                  f-cost-sum       = 0
                  f-cost-vat       = 0
                  f-cost-sum-novat = 0
                  f-sale-vat       = 0
                  f-sale-slt       = 0
                  f-sale-other     = 0
                  f-disc           = 0
                  f-disc-prc       = 0
                 .
 End.
   run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объекту') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by obj-list.obj-code ff-qnty     ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-crsa-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-vat ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-vat      ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-slt      ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-other    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL by obj-list.obj-code ff-disc          ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                                             CHR(9)
          "по объекту"                                        CHR(9)
          obj-list.obj-name                                   CHR(9)
          excel-qnty(accum TOTAL by obj-list.obj-code ff-qnty          )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-vat      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum-novat)  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-sum      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-other    )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-vat      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-slt      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-disc          )  CHR(9)   CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-crsa-sum      )  chr(10).
End.
 if n-no > 1 then do:
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('ПО ВСЕМ ОБЬЕКТАМ') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL  ff-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL  ff-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL  ff-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL  ff-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL  ff-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL  ff-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL  ff-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL  ff-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL  ff-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL  ff-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream
          with FRAME Zapas no-error .
          DOWN stream OutStream with FRAME Zapas.
          if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                            CHR(9)
          "ПО ВСЕМ ОБЬЕКТАМ"                 CHR(9)
          excel-qnty(accum TOTAL  ff-qnty            )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-sum        )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-vat        )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-sum-novat  )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-sum        )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-other      )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-vat        )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-slt        )   CHR(9)
          excel-sum (accum TOTAL  ff-disc            )   CHR(9) CHR(9)
          excel-sum (accum TOTAL  ff-crsa-sum        )   chr(10).
         run u-line.
  End.
END PROCEDURE.
PROCEDURE foreach5 :
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
   Assign
    ff-qnty           = 0
    ff-crsa-sum       = 0
    ff-sale-sum       = 0
    ff-cost-sum       = 0
    ff-cost-vat       = 0
    ff-cost-sum-novat = 0
    ff-sale-vat       = 0
    ff-sale-slt       = 0
    ff-sale-other     = 0
    ff-disc           = 0
    ff-disc-prc       = 0
    .
  For each obj-list no-lock break by obj-list.obj-type by obj-list.obj-code
   with FRAME Zapas :
      if NOT (itog = true and classify = 1) Then DO :
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-crsa-sum <>  ?  then do :
Assign
    l1f-crsa-sum  = c-f-crsa-sum:DATA-TYPE
    l2f-crsa-sum  = c-f-crsa-sum:FORMAT
    c-f-crsa-sum:DATA-TYPE = "CHARACTER"
    c-f-crsa-sum:FORMAT    = "x(" + string(C-f-crsa-sum:WIDTH-CHARS) + ")"
    c-f-crsa-sum:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-cost-vat <>  ?  then do :
Assign
    l1f-cost-vat  = c-f-cost-vat:DATA-TYPE
    l2f-cost-vat  = c-f-cost-vat:FORMAT
    c-f-cost-vat:DATA-TYPE = "CHARACTER"
    c-f-cost-vat:FORMAT    = "x(" + string(C-f-cost-vat:WIDTH-CHARS) + ")"
    c-f-cost-vat:screen-value = string('')  .
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    l1f-cost-sum-novat  = c-f-cost-sum-novat:DATA-TYPE
    l2f-cost-sum-novat  = c-f-cost-sum-novat:FORMAT
    c-f-cost-sum-novat:DATA-TYPE = "CHARACTER"
    c-f-cost-sum-novat:FORMAT    = "x(" + string(C-f-cost-sum-novat:WIDTH-CHARS) + ")"
    c-f-cost-sum-novat:screen-value = string('')  .
End.
if c-f-sale-vat <>  ?  then do :
Assign
    l1f-sale-vat  = c-f-sale-vat:DATA-TYPE
    l2f-sale-vat  = c-f-sale-vat:FORMAT
    c-f-sale-vat:DATA-TYPE = "CHARACTER"
    c-f-sale-vat:FORMAT    = "x(" + string(C-f-sale-vat:WIDTH-CHARS) + ")"
    c-f-sale-vat:screen-value = string('')  .
End.
if c-f-sale-slt <>  ?  then do :
Assign
    l1f-sale-slt  = c-f-sale-slt:DATA-TYPE
    l2f-sale-slt  = c-f-sale-slt:FORMAT
    c-f-sale-slt:DATA-TYPE = "CHARACTER"
    c-f-sale-slt:FORMAT    = "x(" + string(C-f-sale-slt:WIDTH-CHARS) + ")"
    c-f-sale-slt:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-disc <>  ?  then do :
Assign
    l1f-disc  = c-f-disc:DATA-TYPE
    l2f-disc  = c-f-disc:FORMAT
    c-f-disc:DATA-TYPE = "CHARACTER"
    c-f-disc:FORMAT    = "x(" + string(C-f-disc:WIDTH-CHARS) + ")"
    c-f-disc:screen-value = string('')  .
End.
if c-f-disc-prc <>  ?  then do :
Assign
    l1f-disc-prc  = c-f-disc-prc:DATA-TYPE
    l2f-disc-prc  = c-f-disc-prc:FORMAT
    c-f-disc-prc:DATA-TYPE = "CHARACTER"
    c-f-disc-prc:FORMAT    = "x(" + string(C-f-disc-prc:WIDTH-CHARS) + ")"
    c-f-disc-prc:screen-value = string('')  .
End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
if c-f-crsa-sum <>  ?  then do :
Assign
    c-f-crsa-sum:DATA-TYPE = l1f-crsa-sum
    c-f-crsa-sum:FORMAT    = l2f-crsa-sum.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-cost-vat <>  ?  then do :
Assign
    c-f-cost-vat:DATA-TYPE = l1f-cost-vat
    c-f-cost-vat:FORMAT    = l2f-cost-vat.
End.
if c-f-cost-sum-novat <>  ?  then do :
Assign
    c-f-cost-sum-novat:DATA-TYPE = l1f-cost-sum-novat
    c-f-cost-sum-novat:FORMAT    = l2f-cost-sum-novat.
End.
if c-f-sale-vat <>  ?  then do :
Assign
    c-f-sale-vat:DATA-TYPE = l1f-sale-vat
    c-f-sale-vat:FORMAT    = l2f-sale-vat.
End.
if c-f-sale-slt <>  ?  then do :
Assign
    c-f-sale-slt:DATA-TYPE = l1f-sale-slt
    c-f-sale-slt:FORMAT    = l2f-sale-slt.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-disc <>  ?  then do :
Assign
    c-f-disc:DATA-TYPE = l1f-disc
    c-f-disc:FORMAT    = l2f-disc.
End.
if c-f-disc-prc <>  ?  then do :
Assign
    c-f-disc-prc:DATA-TYPE = l1f-disc-prc
    c-f-disc-prc:FORMAT    = l2f-disc-prc.
End.
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
      End.
          n-nn = 0.
          n-no = n-no + 1 .
 For Each ub.ot-line where
          ub.ot-line.fact-order <= fact-order-2 and
          ub.ot-line.fact-order >= fact-order-1 and
          ub.ot-line.obj-code    = obj-list.obj-code and
          ub.ot-line.obj-type    = obj-list.obj-type and
          (
          ub.ot-line.sum-type    = string('sale':U) + String('')
          OR
          ub.ot-line.sum-type    =
           'sasr':U + String('')
          )
          no-lock ,
          First tdedt where ub.ot-line.ext-doc-type   = tdedt.id  no-lock
            break
                by   entry(2,ub.ot-line.cat-id)
                by ( ub.ot-line.artic + ub.ot-line.prod-type + string ( ub.ot-line.prod-code ))
                by ub.ot-line.prod-type By ub.ot-line.prod-code by ub.ot-line.artic
                with FRAME Zapas :
            accumulate ub.ot-line.fact-qnty     (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.sum-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.vat-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.slt-base       (TOTAL by  ub.ot-line.artic ) .
            accumulate ub.ot-line.other-base     (TOTAL by  ub.ot-line.artic ) .
      if first-of( entry(2,ub.ot-line.cat-id) ) then DO:
       for each wt share-lock : delete wt. end.
                  if  Itog = false Then do:
                      f-artic  =   "Ставка НсП" .
                      f-gds-name =  entry(2,ub.ot-line.cat-id) + '%' .
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(f-gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                       Display stream OutStream .
                       DOWN stream OutStream .
                       if Make-Excel then  put   stream ForExcel unformatted
                               "Ставка НсП" CHR(9)
                               entry(2,ub.ot-line.cat-id) + "%"  chr(10) .
                  End.
      End.
      Create WT.
      Assign WT.doc-code = ub.ot-line.doc-code.
      if last-of(ub.ot-line.artic) then DO:
                n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(reportname)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(reportname)
    .
 Assign
    v-kol-spice = (50 - LENGTH(objname)) / 2
    RecordsString2 = fill(' ',v-kol-spice) + string(objname)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
              RecordsString   @ RecordsString
              RecordsString2  @ RecordsString2
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
                find first goods where  ub.ot-line.prod-type = goods.prod-type and
                                        ub.ot-line.prod-code = goods.prod-code and
                                        ub.ot-line.artic     = goods.artic no-lock no-error .
               f-qnty       = accum  TOTAL by  ub.ot-line.artic ub.ot-line.fact-qnty  .
               f-sale-sum   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.sum-base   .
               f-sale-vat   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.vat-base   .
               f-sale-slt   = accum  TOTAL by  ub.ot-line.artic ub.ot-line.slt-base   .
               f-sale-other = accum  TOTAL by  ub.ot-line.artic ub.ot-line.other-base .
                f-crsa-sum = 0.
                For each crsa-ot-line where
                    crsa-ot-line.fact-order >= fact-order-1 and
                    crsa-ot-line.fact-order <= fact-order-2 and
                    crsa-ot-line.obj-code    = ub.ot-line.obj-code and
                    crsa-ot-line.obj-type    = ub.ot-line.obj-type and
                    crsa-ot-line.prod-type   = ub.ot-line.prod-type and
                    crsa-ot-line.prod-code   = ub.ot-line.prod-code and
                    crsa-ot-line.artic       = ub.ot-line.artic and
                    (crsa-ot-line.sum-type    = 'crsa':U OR
                    crsa-ot-line.sum-type    = 'cgsr':U )
                    no-lock ,
                       First buf-tdedt where  buf-tdedt.id = crsa-ot-line.ext-doc-type  no-lock,
                       first wt where wt.doc-code = crsa-ot-line.doc-code
                    no-lock :
                  f-crsa-sum   = f-crsa-sum + crsa-ot-line.sum-base   .
                End.
                f-cost-sum   = 0 .
                f-cost-vat   = 0 .
                For each alt-ot-line where
                    alt-ot-line.fact-order >= fact-order-1 and
                    alt-ot-line.fact-order <= fact-order-2 and
                    alt-ot-line.obj-code    = ub.ot-line.obj-code and
                    alt-ot-line.obj-type    = ub.ot-line.obj-type and
                    alt-ot-line.prod-type   = ub.ot-line.prod-type and
                    alt-ot-line.prod-code   = ub.ot-line.prod-code and
                    alt-ot-line.artic       = ub.ot-line.artic and
                    alt-ot-line.sum-type    = 'cost':U
                    no-lock ,
                       First buf-tdedt where alt-ot-line.ext-doc-type   = buf-tdedt.id  no-lock,
                       first wt where wt.doc-code = alt-ot-line.doc-code
                    no-lock :
                      f-cost-sum   = f-cost-sum + alt-ot-line.sum-base   .
                      f-cost-vat   = f-cost-vat + alt-ot-line.vat-base   .
                    End.
                f-cost-sum-novat = f-cost-sum - f-cost-vat .
                f-disc = f-sale-sum - f-sale-vat - f-sale-slt - f-cost-sum-novat.
                f-disc-prc = (f-disc / f-cost-sum-novat * 100)  .
              if itog = false
                 AND NOT (f-qnty=0 and f-crsa-sum =0  and f-sale-sum =0  and  f-cost-sum =0  and  f-disc =0  )
                 Then DO:
                 n-nn = n-nn + 1.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.ot-line.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(goods.gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(f-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(f-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(f-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(f-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(f-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(f-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(f-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(f-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc-prc <>  ?  then do :
    c-f-disc-prc:screen-value = string(f-disc-prc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                  display stream OutStream  no-error .
                  DOWN stream OutStream .
                  if Make-Excel then  put   stream ForExcel unformatted
                        string(n-nn)     CHR(9)
                        (ub.ot-line.artic)    CHR(9)
                        goods.gds-name   CHR(9)
                        excel-qnty(f-qnty        )   CHR(9)
                        excel-sum (f-cost-sum     )  CHR(9)
                        excel-sum (f-cost-vat     )  CHR(9)
                        excel-sum (f-cost-sum-novat) CHR(9)
                        excel-sum (f-sale-sum      ) CHR(9)
                        excel-sum (f-sale-other    ) CHR(9)
                        excel-sum (f-sale-vat      ) CHR(9)
                        excel-sum (f-sale-slt      ) CHR(9)
                        excel-sum (f-disc          ) CHR(9)
                        excel-sum (f-disc-prc      ) CHR(9)
                        excel-sum(f-crsa-sum     )  chr(10).
                    End.
            accumulate f-qnty           (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-crsa-sum       (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-sale-sum       (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-cost-sum       (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-cost-vat       (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-sale-vat       (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-sale-slt       (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-sale-other     (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-disc           (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
            accumulate f-cost-sum-novat (TOTAL  by   entry(2,ub.ot-line.cat-id) ) .
           End.
           if last-of( entry(2,ub.ot-line.cat-id) ) then do:
                    f-artic    =  "по ставке НсП" .
                    f-gds-name =  entry(2,ub.ot-line.cat-id) + "%" .
                       tf-qnty          =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-qnty          .
                       tf-crsa-sum      =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-crsa-sum      .
                       tf-sale-sum      =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-sum      .
                       tf-cost-sum      =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-cost-sum      .
                       tf-cost-vat      =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-cost-vat      .
                       tf-cost-sum-novat=accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-cost-sum-novat.
                       tf-sale-vat     =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-vat      .
                       tf-sale-slt      =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-slt      .
                       tf-sale-other    =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-other    .
                       tf-disc          =accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-disc          .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(f-artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(f-gds-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(tf-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(tf-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(tf-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(tf-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(tf-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(tf-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(tf-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(tf-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(tf-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(tf-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                    Display stream OutStream  no-error  .
                    DOWN stream OutStream .
                        if Make-Excel then  put   stream ForExcel unformatted                                                                                                       CHR(9)
                        "Итого"                                                                                                       CHR(9)
                         "по ставке НсП" CHR(9)
                         entry(2,ub.ot-line.cat-id) + "%"                             CHR(9)
                        excel-qnty(accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-qnty          )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-cost-sum      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-cost-vat      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-cost-sum-novat)  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-sum      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-other    )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-vat      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-sale-slt      )  CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-disc          )  CHR(9) CHR(9)
                        excel-sum (accum TOTAL  by   entry(2,ub.ot-line.cat-id) f-crsa-sum      )  chr(10).
                      Assign
                       ff-qnty           = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-qnty
                       ff-crsa-sum       = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-crsa-sum
                       ff-sale-sum       = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-sale-sum
                       ff-cost-sum       = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-cost-sum
                       ff-cost-vat       = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-cost-vat
                       ff-cost-sum-novat = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-cost-sum-novat
                       ff-sale-vat       = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-sale-vat
                       ff-sale-slt       = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-sale-slt
                       ff-sale-other     = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-sale-other
                       ff-disc           = accum TOTAL by   entry(2,ub.ot-line.cat-id) f-disc
                       .
              accumulate ff-qnty           (TOTAL by obj-list.obj-code) .
              accumulate ff-crsa-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum       (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-vat       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-slt       (TOTAL by obj-list.obj-code) .
              accumulate ff-sale-other     (TOTAL by obj-list.obj-code) .
              accumulate ff-disc           (TOTAL by obj-list.obj-code) .
              accumulate ff-cost-sum-novat (TOTAL by obj-list.obj-code) .
            End.
                Assign
                  f-qnty           = 0
                  f-crsa-sum       = 0
                  f-sale-sum       = 0
                  f-cost-sum       = 0
                  f-cost-vat       = 0
                  f-cost-sum-novat = 0
                  f-sale-vat       = 0
                  f-sale-slt       = 0
                  f-sale-other     = 0
                  f-disc           = 0
                  f-disc-prc       = 0
                 .
 End.
   run u-line.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по объекту') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by obj-list.obj-code ff-qnty     ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-crsa-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-vat ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL by obj-list.obj-code ff-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-vat      ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-slt      ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by obj-list.obj-code ff-sale-other    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL by obj-list.obj-code ff-disc          ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream no-error .
  DOWN stream OutStream .
  run u-line.
  if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                                             CHR(9)
          "по объекту"                                        CHR(9)
          obj-list.obj-name                                   CHR(9)
          excel-qnty(accum TOTAL by obj-list.obj-code ff-qnty          )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-vat      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-cost-sum-novat)  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-sum      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-other    )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-vat      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-sale-slt      )  CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-disc          )  CHR(9)   CHR(9)
          excel-sum (accum TOTAL by obj-list.obj-code ff-crsa-sum      )  chr(10).
End.
 if n-no > 1 then do:
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('ПО ВСЕМ ОБЬЕКТАМ') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL  ff-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-crsa-sum <>  ?  then do :
    c-f-crsa-sum:screen-value = string(accum TOTAL  ff-crsa-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL  ff-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL  ff-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-vat <>  ?  then do :
    c-f-cost-vat:screen-value = string(accum TOTAL  ff-cost-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum-novat <>  ?  then do :
    c-f-cost-sum-novat:screen-value = string(accum TOTAL  ff-cost-sum-novat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-vat <>  ?  then do :
    c-f-sale-vat:screen-value = string(accum TOTAL  ff-sale-vat) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-slt <>  ?  then do :
    c-f-sale-slt:screen-value = string(accum TOTAL  ff-sale-slt) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL  ff-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-disc <>  ?  then do :
    c-f-disc:screen-value = string(accum TOTAL  ff-disc) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  Display stream OutStream
          with FRAME Zapas no-error .
          DOWN stream OutStream with FRAME Zapas.
          if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                            CHR(9)
          "ПО ВСЕМ ОБЬЕКТАМ"                 CHR(9)
          excel-qnty(accum TOTAL  ff-qnty            )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-sum        )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-vat        )   CHR(9)
          excel-sum (accum TOTAL  ff-cost-sum-novat  )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-sum        )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-other      )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-vat        )   CHR(9)
          excel-sum (accum TOTAL  ff-sale-slt        )   CHR(9)
          excel-sum (accum TOTAL  ff-disc            )   CHR(9) CHR(9)
          excel-sum (accum TOTAL  ff-crsa-sum        )   chr(10).
         run u-line.
  End.
END PROCEDURE.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then do:
    return .
  end.
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.
end procedure.
PROCEDURE ostatok :
def input parameter x-store-code  like ub.clients.obj-code    no-undo.
def input parameter x-store-type  like ub.clients.obj-type    no-undo.
def input parameter x-tog-shift   as   logical             no-undo.
def input parameter x-date-start  like ub.stk-tot.Fact-date   no-undo.
def input parameter x-date-end    like ub.stk-tot.Fact-date   no-undo.
def input parameter x-shift-start as integer               no-undo.
def input parameter x-shift-end   as integer               no-undo.
def input parameter x-sum-type    like ub.stk-tot.sum-type    no-undo.
def input parameter x-cat-id      like ub.stk-tot.cat-id      no-undo.
def input parameter xTog-obj   as log no-undo.
def output parameter Quantity    like ub.stk-tot.fact-qnty   no-undo.
def output parameter Coast_R     like ub.stk-tot.sum-rubl    no-undo.
def output parameter Coast_V     like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_R       like ub.stk-tot.sum-rubl    no-undo.
def output parameter VAT_V       like ub.stk-tot.sum-rubl    no-undo.
def output parameter Fact-order  like ub.stk-tot.Fact-order  no-undo.
def var              Fact-order#   like ub.stk-tot.Fact-order  no-undo.
def var              Fact-orderS   as char  no-undo.
def var x-date-start-t  like ub.stk-tot.shift-date   no-undo.
   Assign
      Fact-order   = 0
      Quantity     = 0
      Coast_R      = 0
      Coast_V      = 0
      VAT_R        = 0
      VAT_V        = 0 .
 x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
   Fact-order = 0 .
   for each obj-list
       where  ( not xtog-obj or
              ( x-store-type = obj-list.obj-type and x-store-code = obj-list.obj-code ))
              no-lock :
      if  x-tog-shift = false then do:
                       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
                            ub.stk-tot.Fact-date <=  x-date-start
                            and ub.stk-tot.shift-num = 0
                            USE-INDEX fact-date no-lock no-error .
           if Available ub.stk-tot THEN  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
      End.
      Else  DO :
          find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
           (ub.stk-tot.shift-date  = x-date-start-t and
            ub.stk-tot.shift-num  < x-shift-start or
            ub.stk-tot.shift-date  < x-date-start-t  )
            and ub.stk-tot.shift-num  > 0
            USE-INDEX Shift-num no-lock no-error .
         If Available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
        END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  WHERE
     (NOT xTog-obj OR (x-store-type = obj-list.obj-type AND x-store-code = obj-list.obj-code))
      no-lock :
   IF  x-TOG-Shift = False Then DO:
       find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            ub.stk-tot.Fact-date <= x-date-end
            and ub.stk-tot.shift-num = 0
            USE-INDEX fact-date no-lock no-error.
       if available ub.stk-tot then  Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
   END.
   Else DO:
        find last ub.stk-tot where ub.stk-tot.obj-type = obj-list.obj-type and                             ub.stk-tot.obj-code = obj-list.obj-code and                             ub.stk-tot.sum-type = x-sum-type and                             ub.stk-tot.cat-id   = x-cat-id   and
            (ub.stk-tot.shift-date  = x-date-end and
            ub.stk-tot.shift-num  <= x-shift-end or
            ub.stk-tot.shift-date  < x-date-end       ) and
            ub.stk-tot.shift-num   > 0      use-index shift-num no-lock no-error.
            if Available ub.stk-tot THEN Assign                           Quantity     = Quantity   + ub.stk-tot.fact-qnty                           Coast_R      = Coast_R    + ub.stk-tot.sum-rubl                           Coast_V      = Coast_V    + ub.stk-tot.sum-base                           VAT_R        = VAT_R      + ub.stk-tot.VAT-rubl                           VAT_V        = VAT_V      + ub.stk-tot.VAT-base                           Fact-order#  = ub.stk-tot.Fact-order.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
