block-level on error undo, throw.
define input parameter x-base-type  like ub.currency.curr-abbr no-undo.
define input parameter x-base-code  like ub.currency.curr-code no-undo.
define input parameter CostSum      as log no-undo.
define input parameter DispUpFact   as log no-undo  .
define input parameter Serv     as log no-undo.
define input parameter RetServ  as log no-undo.
define input parameter NullPer  as log no-undo.
define input parameter CalcRest as log no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реестр документов".
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
define new global shared variable g#trdcalib as handle no-undo.
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-log as logical   no-undo .
define variable sliv# as log init true no-undo.
define variable F-fact-date      as char no-undo.
define variable F-qnty           as char no-undo.
define variable F-VAT_pc         as char no-undo.
define variable F-SLT_pc         as char no-undo.
define variable F-doc-code       as char no-undo.
define variable F-cli-name       as char no-undo.
define variable F-SumWithNDS     as char no-undo.
define variable F-SumWithoutNDS  as char no-undo.
define variable F-discnt-sum     as char no-undo.
define variable F-ov-sum         as char no-undo.
define variable F-sale-sum       as char no-undo.
define variable F-VAT-Sum        as char no-undo.
define variable F-SLT-sum        as char no-undo.
define variable  v-col-1 as integer no-undo .
define variable  v-col-2 as integer no-undo .
define variable  v-col-3 as integer no-undo .
define variable  v-col-4 as integer no-undo .
define variable  ff like ub.stk-tot.Fact-order init 0 no-undo.
define variable     fact-date            as date no-undo.
define variable     doc-code             as char no-undo.
define variable     cli-name             as char no-undo.
define variable     qnty                 as decimal format "->>>,>>>,>>9.999" no-undo.
define variable     SumWithNDS           as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithoutNDS        as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     discnt-sum           as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     ov-sum               as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     sale-sum             as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     VAT_pc               as decimal format "->9.99"           no-undo.
define variable     VAT-Sum              as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SLT_pc               as decimal format "->9.99"           no-undo.
define variable     SLT-sum              as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithNDS-coast     as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithoutNDS-coast  as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     VAT-Sum-coast        as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SLT-sum-coast        as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithNDS-disp      as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     SumWithoutNDS-disp   as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable     sale-sum-ot          as decimal format "->>>,>>>,>>9.99"  no-undo.
define variable  Fact-order-1-C like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-1-P like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-1   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity1      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast1         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat1     like ub.stk-tot.sum-rubl   no-undo.
define variable  Fact-order-2-C like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-2-P like ub.stk-tot.Fact-order no-undo.
define variable  Fact-order-2   like ub.stk-tot.Fact-order no-undo.
define variable  Quantity2      like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast2         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat2     like ub.stk-tot.sum-rubl   no-undo.
define variable  Quantity    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-VAT   like ub.stk-tot.vat-rubl   no-undo.
define variable  Quantity3    like ub.stk-tot.fact-qnty  no-undo.
define variable  Coast5       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast6       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat5       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat6       like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast3         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast4         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat3         like ub.stk-tot.sum-rubl   no-undo.
define variable  Coast-vat4         like ub.stk-tot.sum-rubl   no-undo.
define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str NO-UNDO.
define variable  tPrintRubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.
define  stream  OutStream .
define variable    ObjName           as char no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.
define variable Coast_R1  as decimal no-undo .
define variable VAT_R1    as decimal no-undo .
define variable Coast_R2  as decimal no-undo .
define variable VAT_R2    as decimal no-undo .
define variable Coast_R3  as decimal no-undo .
define variable VAT_R3    as decimal no-undo .
define variable Coast_R4  as decimal no-undo .
define variable VAT_R4    as decimal no-undo .
define variable Coast_V1  as decimal no-undo .
define variable VAT_V1    as decimal no-undo .
define variable Coast_V2  as decimal no-undo .
define variable VAT_V2    as decimal no-undo .
define variable Coast_V3  as decimal no-undo .
define variable VAT_V3    as decimal no-undo .
define variable Coast_V4  as decimal no-undo .
define variable VAT_V4    as decimal no-undo .
define variable xTog-obj as logical no-undo .
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
define variable   v-vat_sum    as   decimal format "->>>,>>>,>>9.99" no-undo.
define variable   v-vat_sum_f  as   decimal format "->>>,>>>,>>>.<<" no-undo.
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
define buffer b-stk-tot for ub.stk-tot .
define work-table tmp#taxvat no-undo
field type       like ub.ot-tot.sum-type
field pc         as char
field sum        like ub.ot-tot.vat-base
field sum_full   like ub.ot-tot.sum-base
.
define work-table tmp#taxslt no-undo
field type       like ub.ot-tot.sum-type
field pc         as char
field sum        like ub.ot-tot.vat-base
field sum_full   like ub.ot-tot.sum-base
.
define work-table acc#taxvat no-undo
field type      like ub.ot-tot.sum-type
field pc        as char
field sum       like ub.ot-tot.vat-base
field sum_full  like ub.ot-tot.sum-base
.
define work-table acc#taxslt no-undo
field type      like ub.ot-tot.sum-type
field pc        as char
field sum       like ub.ot-tot.vat-base
field sum_full  like ub.ot-tot.sum-base
.
define temp-table tmp-doc no-undo
field  doc-code      as character
field  ext-doc-type  as character
field  nn as integer
index pi as primary  doc-code
index ind2 nn  doc-code
.
define buffer crsa-ot-tot     for ub.ot-tot.
define buffer cost-ot-tot-inv for ub.ot-tot.
define buffer sale-ot-tot-inv for ub.ot-tot.
DEFINE FRAME DocsRep
    sym1 column-label ":!:" format "X(1)" space(0)
    F-fact-date column-label "Дата!закрытия" format "x(10)" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    f-doc-code column-label "Номер!документа" format "X(10)" space(0)
    sym3 column-label ":!:" format "X(1)" space(0)
    f-cli-name column-label "Контрагент! " format "X(28)" space(0)
    sym4 column-label ":!:" format "X(1)" space(0)
    F-qnty column-label "Количество! " format  "x(15)" space(0)
    sym5 column-label ":!:" format "X(1)" space(0)
    f-SumWithNDS column-label "Сумма!с НДС" format "->>>,>>>,>>9.99" space(0)
    sym6 column-label ":!:" format "X(1)" space(0)
    f-SumWithoutNDS column-label "Сумма!без НДС" format "->>>,>>>,>>9.99" space(0)
    sym7 column-label ":!:" format "X(1)" space(0)
    f-discnt-sum column-label "Сумма!скидки" format "->>>,>>>,>>9.99" space(0)
    sym8 column-label ":!:" format "X(1)" space(0)
    f-ov-sum column-label "Сумма авт.!переоценки" format "->>>,>>>,>>9.99" space(0)
    sym9 column-label ":!:" format "X(1)" space(0)
    f-sale-sum column-label "Сумма!прод. цен" format "->>>,>>>,>>9.99" space(0)
    sym10 column-label ":!:" format "X(1)" space(0)
    F-VAT_pc column-label "Ставка!НДС" format "x(6)" space(0)
    sym11 column-label ":!:" format "X(1)" space(0)
    f-VAT-Sum column-label "Сумма!НДС" format "->>,>>>,>>9.99" space(0)
    sym12 column-label ":!:" format "X(1)" space(0)
    F-SLT_pc column-label "Ставка!НП" format "x(6)" space(0)
    sym13 column-label ":!:" format "X(1)" space(0)
    f-SLT-sum column-label "Сумма налога!с продаж" format "->>,>>>,>>9.99" space(0)
    sym14 column-label ":!:" format "X(1)" space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Реестр документов (товарный отчет) ") AT 50 format "X(35)"
        string( "цены и суммы указаны в " + (if tPrintRubl then "РУБ" else x-base-type ) ) AT 90 format "X(27)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9" ) ) AT 155 format "X(15)" SKIP
        Line format "X(194)" AT 1
    with width 232 down stream-io use-text NO-BOX.
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
assign v-account = ( if integer( 50 ) = 0 then 100 else integer( 50 ) ).
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
     assign
        i=0
        startdate     = x-date-start
        enddate       = x-date-end
        PayType       = x-SET_PAY_TYPE
        xTog-obj      = true
        ValType       = IF (PayType = 1) Then 0  else x-SET_val_TYPE.
        run report-execute.
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
   curr-rep = (if tPrintRubl then "РУБ" else x-base-type ) .
   NO-PRISE = true .
  if var-report-r-b = "rubl"  then do:
    if  x-base-code <> 0 and valtype = 2  then no-prise = false  .
  end.
  else do:
   if  x-base-code <> 0 and valtype = 1  then no-prise = false  .
  end.
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  FORM with FRAME DocsRep .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(194)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
   Line = fill("-", 194).
   run calcitog in this-procedure.
   run print-header in this-procedure.
   run foreach in this-procedure.
  HIDE stream OutStream FRAME BottomFrame .
  run print-footer in this-procedure.
  HIDE STREAM OutStream FRAME DocsRep .
  Output stream OutStream close.
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
   PUT stream OutStream  string( v-cntxt-host-name-obj)
         AT 50 format "X(85)" SKIP(2)
         "Р Е Е С Т Р   Д О К У М Е Н Т О В  " +
         "( Т О В А Р Н Ы Й   О Т Ч Е Т )"
         AT 35  format "X(100)" skip.
     Repeat i = 1 to NUM-ENTRIES(STR1,chr(10)) :
        PUT stream OutStream  Entry(i,STR1,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR2,chr(10)) :
        PUT stream OutStream  Entry(i,STR2,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR3,chr(10)) :
        PUT stream OutStream  Entry(i,STR3,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(STR4,chr(10)) :
        PUT stream OutStream  Entry(i,STR4,chr(10))  AT 1 format "X(160)" SKIP.
     End.
     Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
        PUT stream OutStream  Entry(i,ReportHeader,chr(10))  AT 1 format "X(160)" SKIP.
     End.
    i=0.
if CalcRest then
    do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "1" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity1, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast1 , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast1 - Coast-vat1  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast1, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
IF PayType = 2 OR PayType = 0  then do :
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
    PUT STREAM OutStream
    SPACE(23)
    string( "НДС в  УЧЕТНЫХ ценах: " +
                trim( string( Coast-vat1, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                curr-rep
              ) format "x(72)"
    SKIP.
end.
ELSE PUT STREAM OutStream
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
            trim( string( Coast-vat1, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
SKIP.
.
        if NO-PRISE THEN DO:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PUT STREAM OutStream
SPACE(23)
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast3, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
              trim( string( Coast-vat3, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
  .
           End.
    end.
   END PROCEDURE.
PROCEDURE Print-Footer :
  run on-same-page in this-procedure (input (13 + v-col-3 + v-col-4 )) .
    Quantity = Quantity2 - Quantity1.
    Coast = Coast2 - Coast1 .
    Coast-vat = Coast-vat2 - Coast-vat1 .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE " " :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity , "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info22 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast  , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast  - Coast-vat   ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
IF PayType = 2 OR PayType = 0  then do :
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
    PUT STREAM OutStream
    SPACE(23)
    string( "НДС в  УЧЕТНЫХ ценах: " +
                trim( string( Coast-vat , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                curr-rep
              ) format "x(72)"
    SKIP.
end.
ELSE PUT STREAM OutStream
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
            trim( string( Coast-vat , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
SKIP.
.
     Coast = Coast4 - Coast3 .
     Coast-vat = Coast-vat4 - Coast-vat3 .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PUT STREAM OutStream
SPACE(23)
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
              trim( string( Coast-vat , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
  .
if CalcRest then
    do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE "2" :
WHEN  "1" then
TEMPSTR =  string( "Остаток на начало периода (" + string( startdate, "99/99/9999" ) + ")" )   .
WHEN "2" then
TEMPSTR = string( "Остаток на конец периода (" + string( enddate, "99/99/9999" ) + ")" )  .
OTHERWISE
TEMPSTR =string( "Оборот с " + string( startdate, "99/99/9999" ) + " по " + string( enddate, "99/99/9999" ) )  .
end CASE.
PUT STREAM OutStream
SKIP
SPACE(5)
TEMPSTR format "x(72)"
SKIP
SPACE(32) string( "Количество: " + trim( string( Quantity2, "->>>,>>>,>>9.<<<" ) ) ) format "x(72)"
SKIP.
IF PayType = 2 OR PayType = 0  then do:
define variable vss-include-info26 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
PUT STREAM OutStream
SPACE(23) string( "Cумма   УЧЕТНЫХ  цен: " +
            trim( string( Coast2 , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
PUT STREAM OutStream
SPACE(23) string( "Cумма УЧЕТНЫХ цен без НДС: " +
     trim( string( (Coast2 - Coast-vat2  ) , "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
     curr-rep
     ) format "x(72)"
     SKIP.
end.
Else   PUT STREAM OutStream
SPACE(23) string(  "Cумма ПРОДАЖНЫХ цен: " +
            trim( string( Coast2, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
          SKIP.
IF PayType = 2 OR PayType = 0  then do :
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
if  v-log = true  then
    PUT STREAM OutStream
    SPACE(23)
    string( "НДС в  УЧЕТНЫХ ценах: " +
                trim( string( Coast-vat2, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
                curr-rep
              ) format "x(72)"
    SKIP.
end.
ELSE PUT STREAM OutStream
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
            trim( string( Coast-vat2, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
            curr-rep
          ) format "x(72)"
SKIP.
.
        if NO-PRISE THEN DO:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PUT STREAM OutStream
SPACE(23)
string( "Cумма ПРОДАЖНЫХ цен: " +
              trim( string( Coast4, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
SPACE(23)
string( "НДС в ПРОДАЖНЫХ ценах: " +
              trim( string( Coast-vat4, "->>>,>>>,>>>,>>>,>>9.99" ) ) + " " +
              curr-rep
            ) format "x(72)"
  SKIP
  .
           End.
    end.
PUT STREAM OutStream " " SKIP(3)
    SPACE(20) "Заведующий __________________"   format "X(32)"
    SPACE(20) "Ст. продавец __________________" format "X(32)"
    SPACE(20) "Бухгалтер __________________"    format "X(32)"
    SKIP .
   run on-same-page in this-procedure (input (13 + v-col-1 + v-col-2 )) .
   END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream
        sym1
        f-fact-date
        sym2
        f-doc-code
        sym3
        f-cli-name
        sym4
        f-qnty
        sym5
        f-SumWithNDS
        sym6
        f-SumWithoutNDS
        sym7
        f-discnt-sum
        sym8
        f-ov-sum
        sym9
        f-sale-sum
        sym10
        f-VAT_pc
        sym11
        f-VAT-Sum
        sym12
        f-SLT_pc
        sym13
        f-SLT-sum
        sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
        END PROCEDURE.
PROCEDURE P-LINE :
UNDERLINE stream OutStream
        sym3
        f-cli-name
        sym4
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
        END PROCEDURE.
PROCEDURE CalcItog :
    Assign
      Coast1        = 0
      Coast-vat1    = 0
      Coast2        = 0
      Coast-vat2    = 0
      Coast3        = 0
      Coast-vat3    = 0
      Coast4        = 0
      Coast-vat4    = 0
   .
   define buffer buf_obj-list for obj-list.
   find first buf_obj-list no-error .
    run ostatok  in this-procedure (
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input 'cost':U   ,
        input '##,##':U,
        input false   ,
        output  Quantity1   ,
        output  Coast_R1    ,
        output  Coast_V1    ,
        output  VAT_R1      ,
        output  VAT_V1      ,
        output  Fact-order-1-C ).
    run ostatok  in this-procedure(
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  ,x-TOG-Shift,
        input x-date-start - 1 ,
        input date('')      , x-Shift-Start,x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input false ,
        output  Quantity1  ,
        output  Coast_R3   ,
        output  Coast_V3   ,
        output  VAT_R3     ,
        output  VAT_V3     ,
        output  Fact-order-1-P ).
        Fact-order-1 = Fact-order-1-P .
    run ostatok  in this-procedure (
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start,x-Shift-End,
        input 'cost':U   ,
        input '##,##':U,
        input false ,
        output  Quantity2  ,
        output  Coast_R2   ,
        output  Coast_V2   ,
        output  VAT_R2     ,
        output  VAT_V2     ,
        output  Fact-order-2-C ).
    run ostatok  in this-procedure (
        input buf_obj-list.obj-code  ,
        input buf_obj-list.obj-type  , x-TOG-Shift,
        input x-date-start  ,
        input x-date-end    , x-Shift-Start , x-Shift-End,
        input 'crsa':U   ,
        input '##,##':U,
        input false      ,
        output  Quantity2  ,
        output  Coast_R4   ,
        output  Coast_V4   ,
        output  VAT_R4     ,
        output  VAT_V4     ,
        output  Fact-order-2-P ).
        Fact-order-2 = Fact-order-2-P .
    Assign
      Coast1        =  if tPrintRubl then Coast_R1 else  Coast_V1
      Coast-vat1    =  if tPrintRubl then VAT_R1   else  VAT_V1
      Coast2        =  if tPrintRubl then Coast_R2 else  Coast_V2
      Coast-vat2    =  if tPrintRubl then VAT_R2   else  VAT_V2
      Coast3        =  if tPrintRubl then Coast_R3 else  Coast_V3
      Coast-vat3    =  if tPrintRubl then VAT_R3   else  VAT_V3
      Coast4        =  if tPrintRubl then Coast_R4 else  Coast_V4
      Coast-vat4    =  if tPrintRubl then VAT_R4   else  VAT_V4
      .
END PROCEDURE.
PROCEDURE foreach :
  run pre-foreach-intmove.
  If sliv# Then run pre-foreach.
  for each tdedt where tdedt.id  <> 'rs':U + ',' + 'es':U  no-lock :
      if tdedt.id = 'ot':U Then find-str = 'crsa':U + ','.
                                      Else find-str = temp-find-str.
      for each obj-list ,
          each  ub.ot-tot no-lock where
                ub.ot-tot.obj-type     = obj-list.obj-type
            and ub.ot-tot.obj-code     = obj-list.obj-code
            and ub.ot-tot.ext-doc-type = tdedt.id
            and ub.ot-tot.fact-order   >  fact-order-1
            and ub.ot-tot.fact-order   <= fact-order-2
            and lookup  (ub.ot-tot.sum-type  , find-str ) <> 0
            and can-find (first tmp-doc where tmp-doc.doc-code = ub.ot-tot.doc-code) = false
            break by ub.ot-tot.ext-doc-type
                  by ub.ot-tot.fact-order
                  by ub.ot-tot.doc-code
                  :
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  ii = ii + 1.
IF ( ii modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              ii @ RecordsDone
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
  Find ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
  if avail ub.trn-doc then do:
                    Assign
                      fact-date      = ub.trn-doc.fact-date
                      doc-code       = ub.ot-tot.doc-code
                      cli-name       = ub.trn-doc.cli-name
                      .
                    end.
 else do:
 Assign
      fact-date      = ?
      doc-code       = ub.ot-tot.doc-code
      cli-name       = ""
      qnty           = 0
      .
      end.
      IF ub.ot-tot.sum-type = 'crsa':U  THEN DO:
              If  ub.ot-tot.ext-doc-type = 'ot':U then DO:
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.
                  Assign
                    fact-date      = If ub.ot-tot.ext-doc-type <> 'ot':U then  ub.trn-doc.fact-date Else (If Available ub.price-doc THEN ub.price-doc.fact-date ELSE date(''))
                    doc-code       = ub.ot-tot.doc-code
                    cli-name       = If ub.ot-tot.ext-doc-type <> 'ot':U then ub.trn-doc.cli-name Else ""
                    qnty           = ub.ot-tot.fact-qnty
                    Sale-sum-ot   = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.
                    Accumulate Sale-sum-ot (TOTAL) .
              End.
            if  ub.ot-tot.ext-doc-type = 'vt':U then do :
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                              Assign
                                  fact-date      = ub.trn-doc.fact-date
                                  doc-code       = ub.ot-tot.doc-code
                                  cli-name       = ub.trn-doc.cli-name
                                  qnty           = ub.ot-tot.fact-qnty
                                  .
                if not can-find
                (first cost-ot-tot-inv where
                       cost-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       cost-ot-tot-inv.sum-type = 'cost':U no-lock )
                        Then
                        Assign
                          SumWithNDS-coast    = 0
                          VAT-Sum-coast       = 0
                          SLT-sum-coast       = 0
                          SumWithoutNDS-coast = 0
                        .
                if not can-find
                (first sale-ot-tot-inv where
                       sale-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       sale-ot-tot-inv.sum-type = 'sale':U no-lock )
                        Then
                        Assign
                          discnt-sum   =      0
                          ov-sum       =      0
                          VAT-Sum      =      0
                          SLT-sum      =      0
                          SumWithoutNDS =     0
                          SumWithNDS    =     0
                          .
            End.
      End.
      IF ub.ot-tot.sum-type = 'sale':U  THEN DO:
          Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              If  ub.ot-tot.ext-doc-type = 'ot':U then
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.
          Assign
          fact-date      = If ub.ot-tot.ext-doc-type <> 'ot':U then  ub.trn-doc.fact-date Else (If Available ub.price-doc then ub.price-doc.fact-date ELSE date(''))
          doc-code       = ub.ot-tot.doc-code
          cli-name       = If ub.ot-tot.ext-doc-type <> 'ot':U then ub.trn-doc.cli-name Else " "
          qnty           = ub.ot-tot.fact-qnty
          SumWithNDS     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.
          iF SumWithNDS = ? tHEN SumWithNDS = 0.
          If not Available ub.trn-doc Then
             Assign    discnt-sum     = 0
                       ov-sum         = 0.
          discnt-sum     = if tPrintRubl then ub.ot-tot.other-rubl
                                         else ub.ot-tot.other-base .
           iF discnt-sum = ? tHEN discnt-sum = 0.
           if ub.ot-tot.ext-doc-type = 'vt':U THEN discnt-sum = 0.
          Assign
          VAT_pc         = 0
          VAT-Sum        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT_pc         = 0
          SLT-sum        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base.
          iF VAT-Sum = ? tHEN VAT-Sum = 0.
          iF SLT-sum = ? tHEN slt-Sum = 0.
          SumWithoutNDS  = SumWithNDS - VAT-Sum.
            FIND LAST crsa-ot-tot where
                crsa-ot-tot.doc-code = ub.ot-tot.doc-code   and
                crsa-ot-tot.sum-type = 'crsa':U    and
                crsa-ot-tot.cat-id   = ub.ot-tot.cat-id  no-lock use-index pi.
                if available crsa-ot-tot then
                sale-sum       = if tPrintRubl then crsa-ot-tot.sum-rubl else crsa-ot-tot.sum-base .
                Else sale-sum  = 0.
                ov-sum =  sale-sum - ( SumWithNDS +  discnt-sum ).
          Accumulate sale-sum     (TOTAL) .
          Accumulate qnty         (TOTAL) .
          Accumulate SumWithNDS   (TOTAL) .
          Accumulate discnt-sum   (TOTAL) .
          Accumulate ov-sum       (TOTAL) .
          Accumulate VAT-Sum      (TOTAL) .
          Accumulate SLT-sum      (TOTAL) .
          Accumulate SumWithoutNDS  (TOTAL) .
       End.
      IF ub.ot-tot.sum-type = 'cost':U  THEN DO:
          Assign
          SumWithNDS-coast     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base
          VAT-Sum-coast        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT-sum-coast        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base
          SumWithoutNDS-coast  = SumWithNDS-coast - VAT-Sum-coast.
          if fact-date = date('') and ub.ot-tot.ext-doc-type <> 'ot':U then do:
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                                    Assign
                                        fact-date      = ub.trn-doc.fact-date
                                        doc-code       = ub.ot-tot.doc-code
                                        cli-name       = ub.trn-doc.cli-name
                                        .
          end.
          Accumulate SumWithNDS-coast          (TOTAL) .
          Accumulate VAT-Sum-coast             (TOTAL) .
          Accumulate SLT-sum-coast             (TOTAL) .
          Accumulate SumWithoutNDS-coast       (TOTAL) .
       End.
     IF ub.ot-tot.sum-type BEGINS 'cost':U and ub.ot-tot.sum-type <> 'cost':U Then DO:
            IF CostSum Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                 Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
              End.
          End.
     IF ub.ot-tot.sum-type BEGINS 'sale':U and ub.ot-tot.sum-type <> 'sale':U Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                 Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
     End.
      IF ub.ot-tot.sum-type BEGINS 'crsa':U and ub.ot-tot.sum-type <> 'crsa':U Then DO:
                IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                  Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
      End.
          if first-of ( ub.ot-tot.ext-doc-type ) then  run break-h-1.
          if last-of ( ub.ot-tot.doc-code ) then do:
              if (ub.ot-tot.sum-type     =  'crsa':U  and
                 not (ub.ot-tot.ext-doc-type = 'vt':U ))
                 then do:
                    run break-ot.
                    if ub.ot-tot.ext-doc-type = 'ap':U and costsum then run break-cost.
                 end.
                 else do:
                    run break-1str.
                    if available ub.trn-doc then do:
                      if (absolute(ub.trn-doc.fact-qnty) - absolute(ub.trn-doc.doc-qnty) <> 0)
                          and ub.ot-tot.ext-doc-type <> 'vt':U
                          then run break-akt.
                      end.
                    if costsum then run break-cost.
                    run break-2str.
                    if dispupfact then run break-disp .
                 end.
             run erase-var.
          end.
          if last-of ( ub.ot-tot.ext-doc-type ) then do:
              qnty               = accum total       qnty                       .
              sumwithnds         = accum total       sumwithnds                 .
              discnt-sum         = accum total       discnt-sum                 .
              ov-sum             = accum total       ov-sum                     .
              vat-sum            = accum total       vat-sum                    .
              slt-sum            = accum total       slt-sum                    .
              sumwithoutnds      = accum total       sumwithoutnds              .
              sumwithnds-coast   = accum total       sumwithnds-coast           .
              vat-sum-coast      = accum total       vat-sum-coast              .
              slt-sum-coast      = accum total       slt-sum-coast              .
              sumwithoutnds-coast= accum total       sumwithoutnds-coast        .
              sale-sum-ot        = accum total       sale-sum-ot                .
              sale-sum           = (accum total       sale-sum   )  + sale-sum-ot  .
for each tmp#taxvat : delete tmp#taxvat. end.
for each acc#taxvat :
  create tmp#taxvat.
  assign tmp#taxvat.type   = acc#taxvat.type
        tmp#taxvat.pc      = acc#taxvat.pc
        tmp#taxvat.sum     = acc#taxvat.sum.
end.
i = acc-i.
for each tmp#taxslt : delete tmp#taxslt. end.
for each acc#taxslt :
  create tmp#taxslt.
  assign tmp#taxslt.type   = acc#taxslt.type
        tmp#taxslt.pc      = acc#taxslt.pc
        tmp#taxslt.sum     = acc#taxslt.sum.
end.
j = acc-j.
             run break-f-1.
             End.
      end.
  end.
  If sliv#  Then run runkassa in this-procedure.
  run run-intmove.
END PROCEDURE.
PROCEDURE Break-H-1 :
Display stream OutStream
    sym1
    sym2
    sym3
    CAPS (tdedt.name)  @ F-cli-name
    sym4
    sym5
    sym6
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
    sym14
    with FRAME DocsRep .
    DOWN stream  OutStream 1 with FRAME DocsRep.
END PROCEDURE.
PROCEDURE Break-F-1 :
 run u-line.
 Assign
   fact-date = date('')
   doc-code  = ''
   cli-name  = "ИТОГО " +  tdedt.name .
   run break-1str.
   if costsum then run break-cost.
 run break-2str.
 if dispupfact then run break-disp .
 run u-line.
 run erase-var1.
 run erase-var.
END PROCEDURE.
PROCEDURE Break-1str :
Display stream OutStream
    sym1
    fact-date format "99/99/9999" @ f-fact-date
    sym2
    doc-code @ f-doc-code
    sym3
    cli-name @ f-cli-name
    sym4
    qnty format "->>>>>>>9.999"   @ F-qnty
     sym5
     sym6
     sym7
     sym8
     sym9
     sym10
     sym11
     sym12
     sym13
     sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
END PROCEDURE.
PROCEDURE Break-ot :
if NOT (NOT NullPer And sale-sum-ot = 0 And VAT-Sum = 0 and VAT-Sum-coast = 0) THEN DO:
Display stream OutStream
    sym1
    fact-date format "99/99/9999" @ f-fact-date
    sym2
    doc-code @ f-doc-code
    sym3
    cli-name @ f-cli-name
    sym4
    qnty format "->>>>>>>9.999"   @ F-qnty
    sym5
    sym6
    sym7
    sym8
    sym9
    sale-sum-ot @ F-sale-sum
    sym10
    sym11
    sym12
    sym13
    sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
 End .
END PROCEDURE.
PROCEDURE Break-2str :
  define variable str-inv  as character initial "" no-undo .
  define variable str-inv1 as character initial "" no-undo .
  define buffer buf_doc-attr for ub.doc-attr.
  str-inv1 = "".
  If Available ub.trn-doc then do:
    if not(cli-name begins "ИТОГО") then do:
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = 'nids':U
      no-error .
      if avail buf_doc-attr then assign  str-inv1 = buf_doc-attr.attr-value .
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = 'dids':U
      no-error .
      if avail buf_doc-attr then assign  str-inv1 =  str-inv1  +  ( if  buf_doc-attr.attr-value <> ? and buf_doc-attr.attr-value <> ""  then (  " от " + buf_doc-attr.attr-value ) else " " ).
      if trim(str-inv1) <> "" then assign str-inv = "Основ. " .
    end.
  end.
  Display stream OutStream
    sym1
    sym2    str-inv                           @ f-doc-code
    sym3    str-inv1                          @ f-cli-name
    sym4    "По документу"                    @ f-qnty
    sym5    SumWithNDS                        @ F-SumWithNDS
    sym6    SumWithoutNDS                     @ f-SumWithoutNDS
    sym7    discnt-sum                        @ f-discnt-sum
    sym8    ov-sum  when ( NO-PRISE = true )  @ f-ov-sum
    sym9    sale-sum                          @ f-sale-sum
    sym10   "итого"                           @ f-VAT_PC
    sym11   VAT-Sum                           @ f-vat-sum
    sym12
    sym13   SLT-sum                           @ f-slt-sum
    sym14
  with FRAME DocsRep .
  DOWN stream  OutStream 1 with FRAME DocsRep.
  str-inv1 = "" .
  If Available ub.trn-doc then do:
    if not(cli-name begins "ИТОГО") then do:
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = 'ndog':U
      no-error .
      if avail buf_doc-attr then assign  str-inv1 = buf_doc-attr.attr-value .
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code  = ub.trn-doc.doc-code
          and buf_doc-attr.attr-code = 'ddog':U
      no-error .
      if avail buf_doc-attr then assign  str-inv1 =  str-inv1  +  ( if  buf_doc-attr.attr-value <> ? and buf_doc-attr.attr-value <> ""  then (  " от " + buf_doc-attr.attr-value ) else " " ).
          if trim(str-inv1) <> "" then assign str-inv = "Договор " .
    end.
  end.
  if trim(str-inv1) <> "" then do:
      display stream outstream
        sym1
        sym2    str-inv                           @ f-doc-code
        sym3    str-inv1                          @ f-cli-name
        sym4
        sym5
        sym6
        sym7
        sym8
        sym9
        sym10
        sym11
        sym12
        sym13
        sym14
      with frame docsrep .
      down stream  outstream 1 with frame docsrep.
  end.
END PROCEDURE.
PROCEDURE Break-cost :
Display stream OutStream
    sym1
    sym2
    sym3
    sym4
    "Учет" @ F-qnty
    sym5
    SumWithNDS-coast    @  f-SumWithNDS
    sym6
    SumWithoutNDS-coast @ F-SumWithoutNDS
    sym7
    sym8
    sym9
    sym10
    "итого"            @ f-vat_PC
    sym11
    VAT-Sum-coast      @ f-VAT-Sum
    sym12
    space(6)
    sym13
    SLT-sum-coast      @ f-slt-sum
    sym14
    with FRAME DocsRep .
    DOWN stream  OutStream 1 with FRAME DocsRep.
END PROCEDURE.
PROCEDURE Break-Akt :
 tmpact = ABSOLUTE (If Available  ub.trn-doc then ub.trn-doc.doc-qnty else 0 )
         - ABSOLUTE (If Available ub.trn-doc then  ub.trn-doc.fact-qnty else 0).
Display stream OutStream
    sym1
    sym2
    sym3
    "Акт несоответствия" @ f-cli-name
    sym4
    tmpact @ f-qnty
    sym5
    sym6
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
    sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
END PROCEDURE.
PROCEDURE Break-disp :
  Assign
  SumWithNDS-disp     = sale-sum - SumWithoutNDS-coast
  SumWithoutNDS-disp  = SumWithNDS - VAT-Sum - SLT-Sum - SumWithoutNDS-coast.
Display stream OutStream
    sym1
    sym2
    sym3
    sym4
    "Наценка" @ f-qnty
    sym5
    SumWithNDS-disp   @ f-SumWithNDS
    sym6
    SumWithoutNDS-disp @ f-SumWithoutNDS
    sym7
    sym8
    sym9
    sym10
    sym11
    sym12
    sym13
    sym14
        with FRAME DocsRep .
        DOWN stream  OutStream 1 with FRAME DocsRep.
END PROCEDURE.
PROCEDURE Erase-var :
  Assign
     qnty                  = 0
     SumWithNDS            = 0
     SumWithoutNDS         = 0
     discnt-sum            = 0
     ov-sum                = 0
     sale-sum              = 0
     sale-sum-ot           = 0
     VAT_pc                = 0
     VAT-Sum               = 0
     SLT_pc                = 0
     SLT-sum               = 0
     SumWithNDS-coast      = 0
     SumWithoutNDS-coast   = 0
     VAT-Sum-coast         = 0
     SLT-sum-coast         = 0
     SumWithNDS-disp       = 0
     SumWithoutNDS-disp    = 0
      .
END PROCEDURE.
PROCEDURE pre-foreach :
  if can-find (first tdedt where tdedt.id = 'rs':U) AND
     can-find (first tdedt where tdedt.id = 'es':U)  Then  DO:
     Find  First tdedt where tdedt.id = 'rs':U no-error.
     delete tdedt no-error.
     Find  First tdedt where tdedt.id = 'es':U no-error.
     delete tdedt no-error.
     create tdedt.
     Assign  tdedt.id   = 'rs':U + ',' + 'es':U
             tdedt.name = 'касса' .
  End.
 find-str = 'crsa':U + ',' + 'sale':U + ',' +
       if CostSum Then
             'cost':U + ','
             Else "".
 temp-find-str = find-str.
END PROCEDURE.
PROCEDURE erase-var1 :
  acc-i=0.
  acc-J=0.
  For each acc#taxSLT : delete acc#taxSLT . End.
  For each acc#taxVAt : delete acc#taxVAT . End.
END PROCEDURE.
procedure runkassa :
  find-str = temp-find-str.
    for each obj-list ,
       each ub.ot-tot where
               ub.ot-tot.obj-type = obj-list.obj-type
          and  ub.ot-tot.obj-code = obj-list.obj-code
          and  ub.ot-tot.fact-order >  fact-order-1
          and  ub.ot-tot.fact-order <= fact-order-2
          and  lookup (ub.ot-tot.sum-type  , find-str ) <> 0
          and  (ub.ot-tot.ext-doc-type = 'rs':U
          or    ub.ot-tot.ext-doc-type = 'es':U) no-lock,
                first tdedt where tdedt.id  = 'rs':U + ',' + 'es':U  no-lock
                            break by tdedt.id
                                  by ub.ot-tot.fact-order
                                  by ub.ot-tot.doc-code
                                  :
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  ii = ii + 1.
IF ( ii modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              ii @ RecordsDone
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
  Find ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
  if avail ub.trn-doc then do:
                    Assign
                      fact-date      = ub.trn-doc.fact-date
                      doc-code       = ub.ot-tot.doc-code
                      cli-name       = ub.trn-doc.cli-name
                      .
                    end.
 else do:
 Assign
      fact-date      = ?
      doc-code       = ub.ot-tot.doc-code
      cli-name       = ""
      qnty           = 0
      .
      end.
      IF ub.ot-tot.sum-type = 'crsa':U  THEN DO:
              If  ub.ot-tot.ext-doc-type = 'ot':U then DO:
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.
                  Assign
                    fact-date      = If ub.ot-tot.ext-doc-type <> 'ot':U then  ub.trn-doc.fact-date Else (If Available ub.price-doc THEN ub.price-doc.fact-date ELSE date(''))
                    doc-code       = ub.ot-tot.doc-code
                    cli-name       = If ub.ot-tot.ext-doc-type <> 'ot':U then ub.trn-doc.cli-name Else ""
                    qnty           = ub.ot-tot.fact-qnty
                    Sale-sum-ot   = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.
                    Accumulate Sale-sum-ot (TOTAL) .
              End.
            if  ub.ot-tot.ext-doc-type = 'vt':U then do :
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                              Assign
                                  fact-date      = ub.trn-doc.fact-date
                                  doc-code       = ub.ot-tot.doc-code
                                  cli-name       = ub.trn-doc.cli-name
                                  qnty           = ub.ot-tot.fact-qnty
                                  .
                if not can-find
                (first cost-ot-tot-inv where
                       cost-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       cost-ot-tot-inv.sum-type = 'cost':U no-lock )
                        Then
                        Assign
                          SumWithNDS-coast    = 0
                          VAT-Sum-coast       = 0
                          SLT-sum-coast       = 0
                          SumWithoutNDS-coast = 0
                        .
                if not can-find
                (first sale-ot-tot-inv where
                       sale-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       sale-ot-tot-inv.sum-type = 'sale':U no-lock )
                        Then
                        Assign
                          discnt-sum   =      0
                          ov-sum       =      0
                          VAT-Sum      =      0
                          SLT-sum      =      0
                          SumWithoutNDS =     0
                          SumWithNDS    =     0
                          .
            End.
      End.
      IF ub.ot-tot.sum-type = 'sale':U  THEN DO:
          Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              If  ub.ot-tot.ext-doc-type = 'ot':U then
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.
          Assign
          fact-date      = If ub.ot-tot.ext-doc-type <> 'ot':U then  ub.trn-doc.fact-date Else (If Available ub.price-doc then ub.price-doc.fact-date ELSE date(''))
          doc-code       = ub.ot-tot.doc-code
          cli-name       = If ub.ot-tot.ext-doc-type <> 'ot':U then ub.trn-doc.cli-name Else " "
          qnty           = ub.ot-tot.fact-qnty
          SumWithNDS     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.
          iF SumWithNDS = ? tHEN SumWithNDS = 0.
          If not Available ub.trn-doc Then
             Assign    discnt-sum     = 0
                       ov-sum         = 0.
          discnt-sum     = if tPrintRubl then ub.ot-tot.other-rubl
                                         else ub.ot-tot.other-base .
           iF discnt-sum = ? tHEN discnt-sum = 0.
           if ub.ot-tot.ext-doc-type = 'vt':U THEN discnt-sum = 0.
          Assign
          VAT_pc         = 0
          VAT-Sum        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT_pc         = 0
          SLT-sum        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base.
          iF VAT-Sum = ? tHEN VAT-Sum = 0.
          iF SLT-sum = ? tHEN slt-Sum = 0.
          SumWithoutNDS  = SumWithNDS - VAT-Sum.
            FIND LAST crsa-ot-tot where
                crsa-ot-tot.doc-code = ub.ot-tot.doc-code   and
                crsa-ot-tot.sum-type = 'crsa':U    and
                crsa-ot-tot.cat-id   = ub.ot-tot.cat-id  no-lock use-index pi.
                if available crsa-ot-tot then
                sale-sum       = if tPrintRubl then crsa-ot-tot.sum-rubl else crsa-ot-tot.sum-base .
                Else sale-sum  = 0.
                ov-sum =  sale-sum - ( SumWithNDS +  discnt-sum ).
          Accumulate sale-sum     (TOTAL) .
          Accumulate qnty         (TOTAL) .
          Accumulate SumWithNDS   (TOTAL) .
          Accumulate discnt-sum   (TOTAL) .
          Accumulate ov-sum       (TOTAL) .
          Accumulate VAT-Sum      (TOTAL) .
          Accumulate SLT-sum      (TOTAL) .
          Accumulate SumWithoutNDS  (TOTAL) .
       End.
      IF ub.ot-tot.sum-type = 'cost':U  THEN DO:
          Assign
          SumWithNDS-coast     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base
          VAT-Sum-coast        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT-sum-coast        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base
          SumWithoutNDS-coast  = SumWithNDS-coast - VAT-Sum-coast.
          if fact-date = date('') and ub.ot-tot.ext-doc-type <> 'ot':U then do:
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                                    Assign
                                        fact-date      = ub.trn-doc.fact-date
                                        doc-code       = ub.ot-tot.doc-code
                                        cli-name       = ub.trn-doc.cli-name
                                        .
          end.
          Accumulate SumWithNDS-coast          (TOTAL) .
          Accumulate VAT-Sum-coast             (TOTAL) .
          Accumulate SLT-sum-coast             (TOTAL) .
          Accumulate SumWithoutNDS-coast       (TOTAL) .
       End.
     IF ub.ot-tot.sum-type BEGINS 'cost':U and ub.ot-tot.sum-type <> 'cost':U Then DO:
            IF CostSum Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                 Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
              End.
          End.
     IF ub.ot-tot.sum-type BEGINS 'sale':U and ub.ot-tot.sum-type <> 'sale':U Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                 Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
     End.
      IF ub.ot-tot.sum-type BEGINS 'crsa':U and ub.ot-tot.sum-type <> 'crsa':U Then DO:
                IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                  Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
      End.
          if first-of ( tdedt.id ) then  run break-h-1.
          if last-of ( ub.ot-tot.doc-code ) then do:
              if (ub.ot-tot.sum-type     =  'crsa':U  and
                 not (ub.ot-tot.ext-doc-type = 'vt':U ))
                 then do:
                    run break-ot.
                    if ub.ot-tot.ext-doc-type = 'ap':U and costsum then run break-cost.
                 end.
                 else do:
                    run break-1str.
                    if available ub.trn-doc then do:
                      if (absolute(ub.trn-doc.fact-qnty) - absolute(ub.trn-doc.doc-qnty) <> 0)
                          and ub.ot-tot.ext-doc-type <> 'vt':U
                          then run break-akt.
                      end.
                    if costsum then run break-cost.
                    run break-2str.
                    if dispupfact then run break-disp .
                 end.
             run erase-var.
          end.
          if last-of ( tdedt.id ) then do:
              qnty               = accum total       qnty                       .
              sumwithnds         = accum total       sumwithnds                 .
              discnt-sum         = accum total       discnt-sum                 .
              ov-sum             = accum total       ov-sum                     .
              vat-sum            = accum total       vat-sum                    .
              slt-sum            = accum total       slt-sum                    .
              sumwithoutnds      = accum total       sumwithoutnds              .
              sumwithnds-coast   = accum total       sumwithnds-coast           .
              vat-sum-coast      = accum total       vat-sum-coast              .
              slt-sum-coast      = accum total       slt-sum-coast              .
              sumwithoutnds-coast= accum total       sumwithoutnds-coast        .
              sale-sum-ot        = accum total       sale-sum-ot                .
              sale-sum           = (accum total       sale-sum   )  + sale-sum-ot  .
for each tmp#taxvat : delete tmp#taxvat. end.
for each acc#taxvat :
  create tmp#taxvat.
  assign tmp#taxvat.type   = acc#taxvat.type
        tmp#taxvat.pc      = acc#taxvat.pc
        tmp#taxvat.sum     = acc#taxvat.sum.
end.
i = acc-i.
for each tmp#taxslt : delete tmp#taxslt. end.
for each acc#taxslt :
  create tmp#taxslt.
  assign tmp#taxslt.type   = acc#taxslt.type
        tmp#taxslt.pc      = acc#taxslt.pc
        tmp#taxslt.sum     = acc#taxslt.sum.
end.
j = acc-j.
             run break-f-1.
             End.
      end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then do:
    return .
  end.
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.
end procedure.
procedure pre-foreach-intmove :
  do
  on error undo, return error return-value
  :
define buffer pri_trn-doc  for ub.trn-doc.
define buffer Vz_trn-doc   for ub.trn-doc.
define buffer buf_ot-tot   for ub.ot-tot.
define buffer buf_obj-list for obj-list.
define variable v-nn as integer   no-undo .
v-nn = 0.
  if not ( can-find (first tdedt where tdedt.id = 'iv':U )  and
           can-find (first tdedt where tdedt.id = 'ev':U ) and
           can-find (first tdedt where tdedt.id = 'rv':U) ) then return.
      for each obj-list ,
          each  buf_ot-tot no-lock where
                buf_ot-tot.obj-type      = obj-list.obj-type
            and buf_ot-tot.obj-code      = obj-list.obj-code
            and buf_ot-tot.ext-doc-type  = 'ev':U
            and buf_ot-tot.fact-order   >  fact-order-1
            and buf_ot-tot.fact-order   <= fact-order-2
            and buf_ot-tot.sum-type      = 'crsa':U
            :
                find first  Pri_trn-doc no-lock where
                            Pri_trn-doc.ext-doc-type =  'iv':U
                        and Pri_trn-doc.out-code     = buf_ot-tot.doc-code
                        and Pri_trn-doc.status_      = 'факт':U
                        and Pri_trn-doc.fact-order   >  fact-order-1
                        and Pri_trn-doc.fact-order   <= fact-order-2 no-error .
                        if available   Pri_trn-doc  and
                           can-find (first buf_obj-list where
                           Pri_trn-doc.fact-qnty <> 0 and
                           Pri_trn-doc.obj-type      = buf_obj-list.obj-type and
                           Pri_trn-doc.obj-code      = buf_obj-list.obj-code   ) then do:
                           v-nn = v-nn + 1.
                           create tmp-doc.
                           assign
                              tmp-doc.doc-code =  buf_ot-tot.doc-code
                              tmp-doc.ext-doc-type =  'ev':U
                              tmp-doc.nn = v-nn
                           .
                           create tmp-doc.
                           assign
                              tmp-doc.doc-code =  Pri_trn-doc.doc-code
                              tmp-doc.ext-doc-type =  'iv':U
                              tmp-doc.nn = v-nn
                           .
                            find first  Vz_trn-doc no-lock where
                                        Vz_trn-doc.ext-doc-type =  'rv':U
                                    and Vz_trn-doc.out-code     = Pri_trn-doc.doc-code
                                    and Vz_trn-doc.status_      = 'факт':U
                                    and Vz_trn-doc.fact-order   >  fact-order-1
                                    and Vz_trn-doc.fact-order   <= fact-order-2 no-error .
                                    if available   vz_trn-doc then do:
                                        create tmp-doc.
                                        assign
                                            tmp-doc.doc-code =  vz_trn-doc.doc-code
                                            tmp-doc.ext-doc-type =  'rv':U
                                            tmp-doc.nn = v-nn
                                        .
                                    end.
                        end.
      end.
  end.
end procedure.
procedure run-intmove :
  do
  on error undo, return error return-value
  :
  create tdedt.
  assign
    tdedt.name = "ВНУТРЕННЕЕ ПЕРЕМЕЩЕНИЕ"
    tdedt.id =    'iv':U + "," +
                  'ev':U   + "," +
                  'rv':U
  .
       for each  tmp-doc ,
        each ub.ot-tot no-lock where
             ub.ot-tot.doc-code = tmp-doc.doc-code and
             lookup ( ub.ot-tot.sum-type  , find-str ) <> 0
             break
                   by tdedt.id
                   by tmp-doc.nn
                   by ub.ot-tot.fact-order
                   by ub.ot-tot.doc-code :
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  ii = ii + 1.
IF ( ii modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              ii @ RecordsDone
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
  Find ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
  if avail ub.trn-doc then do:
                    Assign
                      fact-date      = ub.trn-doc.fact-date
                      doc-code       = ub.ot-tot.doc-code
                      cli-name       = ub.trn-doc.cli-name
                      .
                    end.
 else do:
 Assign
      fact-date      = ?
      doc-code       = ub.ot-tot.doc-code
      cli-name       = ""
      qnty           = 0
      .
      end.
      IF ub.ot-tot.sum-type = 'crsa':U  THEN DO:
              If  ub.ot-tot.ext-doc-type = 'ot':U then DO:
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.
                  Assign
                    fact-date      = If ub.ot-tot.ext-doc-type <> 'ot':U then  ub.trn-doc.fact-date Else (If Available ub.price-doc THEN ub.price-doc.fact-date ELSE date(''))
                    doc-code       = ub.ot-tot.doc-code
                    cli-name       = If ub.ot-tot.ext-doc-type <> 'ot':U then ub.trn-doc.cli-name Else ""
                    qnty           = ub.ot-tot.fact-qnty
                    Sale-sum-ot   = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.
                    Accumulate Sale-sum-ot (TOTAL) .
              End.
            if  ub.ot-tot.ext-doc-type = 'vt':U then do :
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                              Assign
                                  fact-date      = ub.trn-doc.fact-date
                                  doc-code       = ub.ot-tot.doc-code
                                  cli-name       = ub.trn-doc.cli-name
                                  qnty           = ub.ot-tot.fact-qnty
                                  .
                if not can-find
                (first cost-ot-tot-inv where
                       cost-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       cost-ot-tot-inv.sum-type = 'cost':U no-lock )
                        Then
                        Assign
                          SumWithNDS-coast    = 0
                          VAT-Sum-coast       = 0
                          SLT-sum-coast       = 0
                          SumWithoutNDS-coast = 0
                        .
                if not can-find
                (first sale-ot-tot-inv where
                       sale-ot-tot-inv.doc-code = ub.ot-tot.doc-code and
                       sale-ot-tot-inv.sum-type = 'sale':U no-lock )
                        Then
                        Assign
                          discnt-sum   =      0
                          ov-sum       =      0
                          VAT-Sum      =      0
                          SLT-sum      =      0
                          SumWithoutNDS =     0
                          SumWithNDS    =     0
                          .
            End.
      End.
      IF ub.ot-tot.sum-type = 'sale':U  THEN DO:
          Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              If  ub.ot-tot.ext-doc-type = 'ot':U then
                  Find Last ub.price-doc where ub.price-doc.doc-num = ub.ot-tot.doc-code no-lock no-error.
          Assign
          fact-date      = If ub.ot-tot.ext-doc-type <> 'ot':U then  ub.trn-doc.fact-date Else (If Available ub.price-doc then ub.price-doc.fact-date ELSE date(''))
          doc-code       = ub.ot-tot.doc-code
          cli-name       = If ub.ot-tot.ext-doc-type <> 'ot':U then ub.trn-doc.cli-name Else " "
          qnty           = ub.ot-tot.fact-qnty
          SumWithNDS     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base.
          iF SumWithNDS = ? tHEN SumWithNDS = 0.
          If not Available ub.trn-doc Then
             Assign    discnt-sum     = 0
                       ov-sum         = 0.
          discnt-sum     = if tPrintRubl then ub.ot-tot.other-rubl
                                         else ub.ot-tot.other-base .
           iF discnt-sum = ? tHEN discnt-sum = 0.
           if ub.ot-tot.ext-doc-type = 'vt':U THEN discnt-sum = 0.
          Assign
          VAT_pc         = 0
          VAT-Sum        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT_pc         = 0
          SLT-sum        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base.
          iF VAT-Sum = ? tHEN VAT-Sum = 0.
          iF SLT-sum = ? tHEN slt-Sum = 0.
          SumWithoutNDS  = SumWithNDS - VAT-Sum.
            FIND LAST crsa-ot-tot where
                crsa-ot-tot.doc-code = ub.ot-tot.doc-code   and
                crsa-ot-tot.sum-type = 'crsa':U    and
                crsa-ot-tot.cat-id   = ub.ot-tot.cat-id  no-lock use-index pi.
                if available crsa-ot-tot then
                sale-sum       = if tPrintRubl then crsa-ot-tot.sum-rubl else crsa-ot-tot.sum-base .
                Else sale-sum  = 0.
                ov-sum =  sale-sum - ( SumWithNDS +  discnt-sum ).
          Accumulate sale-sum     (TOTAL) .
          Accumulate qnty         (TOTAL) .
          Accumulate SumWithNDS   (TOTAL) .
          Accumulate discnt-sum   (TOTAL) .
          Accumulate ov-sum       (TOTAL) .
          Accumulate VAT-Sum      (TOTAL) .
          Accumulate SLT-sum      (TOTAL) .
          Accumulate SumWithoutNDS  (TOTAL) .
       End.
      IF ub.ot-tot.sum-type = 'cost':U  THEN DO:
          Assign
          SumWithNDS-coast     = if tPrintRubl then ub.ot-tot.sum-rubl else ub.ot-tot.sum-base
          VAT-Sum-coast        = if tPrintRubl then ub.ot-tot.VAT-rubl else ub.ot-tot.VAT-base
          SLT-sum-coast        = if tPrintRubl then ub.ot-tot.SLT-rubl else ub.ot-tot.SLT-base
          SumWithoutNDS-coast  = SumWithNDS-coast - VAT-Sum-coast.
          if fact-date = date('') and ub.ot-tot.ext-doc-type <> 'ot':U then do:
              Find Last ub.trn-doc where ub.trn-doc.doc-code = ub.ot-tot.doc-code no-lock no-error.
              if avail ub.trn-doc then
                                    Assign
                                        fact-date      = ub.trn-doc.fact-date
                                        doc-code       = ub.ot-tot.doc-code
                                        cli-name       = ub.trn-doc.cli-name
                                        .
          end.
          Accumulate SumWithNDS-coast          (TOTAL) .
          Accumulate VAT-Sum-coast             (TOTAL) .
          Accumulate SLT-sum-coast             (TOTAL) .
          Accumulate SumWithoutNDS-coast       (TOTAL) .
       End.
     IF ub.ot-tot.sum-type BEGINS 'cost':U and ub.ot-tot.sum-type <> 'cost':U Then DO:
            IF CostSum Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                 Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
              End.
          End.
     IF ub.ot-tot.sum-type BEGINS 'sale':U and ub.ot-tot.sum-type <> 'sale':U Then DO:
              IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                 Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
     End.
      IF ub.ot-tot.sum-type BEGINS 'crsa':U and ub.ot-tot.sum-type <> 'crsa':U Then DO:
                IF entry (2 , ub.ot-tot.cat-id) = '##':U Then DO:
create tmp#taxVAT.
assign tmp#taxVAT.type    = ot-tot.sum-type
      tmp#taxVAT.pc      = entry (1 , ot-tot.cat-id)
      tmp#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
      tmp#taxVAT.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
i = i + 1.
find first acc#taxVAT where acc#taxVAT.pc   = tmp#taxVAT.pc
                        and acc#taxVAT.type = tmp#taxVAT.type
                        no-error.
if available acc#taxVAT then
  assign  acc#taxVAT.sum     = acc#taxVAT.sum + (if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base).
  else do:
      create acc#taxVAT.
      assign acc#taxVAT.type    = ot-tot.sum-type
              acc#taxVAT.pc      = entry (1 , ot-tot.cat-id)
              acc#taxVAT.sum     = if tprintrubl then ot-tot.VAT-rubl else ot-tot.VAT-base
              acc#taxVAT.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-i = acc-i + 1.
  end.
   End.
                  Else DO:
create tmp#taxslt.
assign tmp#taxslt.type    = ot-tot.sum-type
      tmp#taxslt.pc      = entry (2 , ot-tot.cat-id)
      tmp#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
      tmp#taxslt.sum_full     = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base
      .
j = j + 1.
find first acc#taxslt where acc#taxslt.pc   = tmp#taxslt.pc
                        and acc#taxslt.type = tmp#taxslt.type
                        no-error.
if available acc#taxslt then
  assign  acc#taxslt.sum     = acc#taxslt.sum + (if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base).
  else do:
      create acc#taxslt.
      assign acc#taxslt.type    = ot-tot.sum-type
              acc#taxslt.pc      = entry (2 , ot-tot.cat-id)
              acc#taxslt.sum     = if tprintrubl then ot-tot.slt-rubl else ot-tot.slt-base
              acc#taxslt.sum_full = if tprintrubl then ot-tot.sum-rubl else ot-tot.sum-base.
          acc-j = acc-j + 1.
  end.
  End.
      End.
          if first-of ( tdedt.id ) then  run break-h-1.
          if last-of ( ub.ot-tot.doc-code ) then do:
              if (ub.ot-tot.sum-type     =  'crsa':U  and
                 not (ub.ot-tot.ext-doc-type = 'vt':U ))
                 then do:
                    run break-ot.
                    if ub.ot-tot.ext-doc-type = 'ap':U and costsum then run break-cost.
                 end.
                 else do:
                    run break-1str.
                    if available ub.trn-doc then do:
                      if (absolute(ub.trn-doc.fact-qnty) - absolute(ub.trn-doc.doc-qnty) <> 0)
                          and ub.ot-tot.ext-doc-type <> 'vt':U
                          then run break-akt.
                      end.
                    if costsum then run break-cost.
                    run break-2str.
                    if dispupfact then run break-disp .
                 end.
             run erase-var.
          end.
          if last-of ( tdedt.id ) then do:
              qnty               = accum total       qnty                       .
              sumwithnds         = accum total       sumwithnds                 .
              discnt-sum         = accum total       discnt-sum                 .
              ov-sum             = accum total       ov-sum                     .
              vat-sum            = accum total       vat-sum                    .
              slt-sum            = accum total       slt-sum                    .
              sumwithoutnds      = accum total       sumwithoutnds              .
              sumwithnds-coast   = accum total       sumwithnds-coast           .
              vat-sum-coast      = accum total       vat-sum-coast              .
              slt-sum-coast      = accum total       slt-sum-coast              .
              sumwithoutnds-coast= accum total       sumwithoutnds-coast        .
              sale-sum-ot        = accum total       sale-sum-ot                .
              sale-sum           = (accum total       sale-sum   )  + sale-sum-ot  .
for each tmp#taxvat : delete tmp#taxvat. end.
for each acc#taxvat :
  create tmp#taxvat.
  assign tmp#taxvat.type   = acc#taxvat.type
        tmp#taxvat.pc      = acc#taxvat.pc
        tmp#taxvat.sum     = acc#taxvat.sum.
end.
i = acc-i.
for each tmp#taxslt : delete tmp#taxslt. end.
for each acc#taxslt :
  create tmp#taxslt.
  assign tmp#taxslt.type   = acc#taxslt.type
        tmp#taxslt.pc      = acc#taxslt.pc
        tmp#taxslt.sum     = acc#taxslt.sum.
end.
j = acc-j.
             run break-f-1.
             End.
        end.
  end.
end procedure.
