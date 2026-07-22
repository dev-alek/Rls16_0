block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obpsd1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obpsd1.p $":U .
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
define input parameter x-store-code like clients.obj-code   no-undo.
define input parameter x-store-type like clients.obj-type   no-undo.
define input parameter x-base-type  like currency.curr-abbr no-undo.
define input parameter x-base-code  like currency.curr-code no-undo.
define input parameter x-type-itog as integer no-undo .
define input parameter xshowgoods as logical no-undo .
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
def SHARED temp-table g#post-f NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    field grp-code like ub.clients.grp-code
    field grp-name like ub.clients.grp-name
    field lvl-num like  ub.cli-grp.lvl-num
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code
    INDEX p1  obj-name
    .
def   shared   var F-prih            as   char  no-undo.
def   shared   var F-rash            as   char  no-undo.
def   shared   var F-kassa           as   char  no-undo.
def   shared   var F-Inv             as   char  no-undo.
def   shared   var F-spis            as   char  no-undo.
def   shared   var F-vzvr            as   char  no-undo.
def   shared   var F-vzvr-post       as   char  no-undo.
def   shared   var F-ostatok-start   as   char  no-undo.
def   shared   var F-ostatok-End     as   char  no-undo.
def   shared  var ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var Inv2              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var spis              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-spis               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var p-vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define  shared temp-table tmp-cli-gds no-undo
field p-ostatok-start     as   decimal  EXTENT 10
field p-ostatok-End       as   decimal  EXTENT 10
field p-prih              as   decimal  EXTENT 10
field p-rash              as   decimal  EXTENT 10
field p-kassa             as   decimal  EXTENT 10
field p-Inv               as   decimal  EXTENT 10
field p-spis              as   decimal  EXTENT 10
field p-vzvr              as   decimal  EXTENT 10
field p-vzvr-post         as   decimal  EXTENT 10
field cli-code            like obj-list.obj-code
field cli-type            like obj-list.obj-type
field Name                as character
field obj-code            like obj-list.obj-code
field obj-type            like obj-list.obj-type
.
def   shared  var o-ostatok-start     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-ostatok-End       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-prih              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-rash              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-kassa             as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-Inv               as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-spis              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-vzvr              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def   shared  var o-vzvr-post         as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B1-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var B2-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-prih                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-rash                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-kassa                    as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-Inv                      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-spis                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-vzvr                     as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-vzvr-post                as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-ostatok-start            as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
def  shared var Bi-ostatok-End              as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
DEFINE  shared FRAME zapas
        gds-zap-b-code column-label  "Код!  ":C10 space(0)
        sym1 column-label ":!:" format "x(1)"       space(0)
        gds-zap-artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym2 column-label ":!:" format "x(1)"                         space(0)
        gds-zap-gds-name column-label "Название товара!  ":C30 format "X(30)" space(0)
        sym3 column-label ":!:" format "x(1)"                                 space(0)
        gds-zap-unit-base column-label "Ед.!изм" format "X(3)"                space(0)
        sym4 column-label ":!:" format "x(1)"                                 space(0)
        gds-type column-label "Тип!данных":C6 format "X(6)"                  space(0)
        sym5 column-label ":!:" format "x(1)" space(0)
        F-ostatok-start     column-label "Остаток!на начало":C13 format "x(13)"           space(0)
        sym6 column-label ":!:" format "x(1)" space(0)
        F-Prih       column-label "Приход!  ":C13     Format "x(13)"     space(0)
        sym7 column-label ":!:" format "x(1)" space(0)
        F-Rash       column-label "Расход!  ":C13  Format "x(13)"   space(0)
        sym8 column-label ":!:" format "x(1)" space(0)
        F-kassa             column-label "Касса!  ":C13  Format "x(13)"   space(0)
        sym9  column-label ":!:" format "x(1)" space(0)
        F-Inv               column-label "Инвента-!ризация ":C13  Format "x(13)"   space(0)
        sym10 column-label ":!:" format "x(1)" space(0)
        F-spis               column-label "Списание! ":C13  Format "x(13)"   space(0)
        sym11 column-label ":!:" format "x(1)" space(0)
        F-vzvr             column-label "Внешний!возврат":C13  Format "x(13)"   space(0)
        sym12  column-label ":!:" format "x(1)" space(0)
        F-vzvr-post         column-label "Возврат!поставщику":C13  Format "x(13)"   space(0)
        sym13 column-label ":!:" format "x(1)" space(0)
        F-ostatok-end     column-label "Остаток!на конец":C13 format "x(13)"           space(0)
    HEADER
        cur-time-print() AT 5 format "X(35)"
        "Цены указаны в" (if tPrintRubl then "РУБ" else x-base-type )
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>9") ) AT 147 format "X(53)" SKIP
        Line format "X(194)" AT 1
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
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function func-get-name-from-ext-type   returns char
  ( p-ext-type as character   ,
    p-caps     as logical ).
define variable v-ext-name as character no-undo .
run get-name-from-ext-type in this-procedure (
    input p-ext-type  ,
    input p-caps  ,
    output v-ext-name )
    no-error .
    if error-status :error then do:
       assign
         v-ext-name = p-ext-type
       .
    end.
 return (v-ext-name) .
end.
procedure get-name-from-ext-type :
 do
 on error undo, return error return-value
 :
define input  parameter p-ext-type as character no-undo .
define input  parameter p-caps     as logical no-undo   .
define output parameter p-ext-name as character no-undo .
define variable v-num as integer no-undo .
  if lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) = 0 then do :
    message
      vss-include-info15 skip
      "Неправильно задано значение входящего параметра! "
      "Нет такого типа документов " p-ext-type
      view-as alert-box error .
      undo, return error .
  end.
  v-num      = lookup ( p-ext-type , 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ) .
  p-ext-name = entry  ( v-num , 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) .
  if p-caps  = true then do :
     p-ext-name = caps(substring(p-ext-name,1,1) ) + substring(p-ext-name, 2 , length (p-ext-name) - 1 ) .
  end .
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable full-prih       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-rash       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-kassa      as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-Inv2       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-Inv        as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-spis       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-vzvr       as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable full-vzvr-post  as   decimal EXTENT 10 Format "->>>>>>>>>9.<<<" no-undo.
define variable ii like i init 0 no-undo .
define buffer buf_parts for parts.
define temp-table temp_oborot_parts no-undo like parts
field ext-doc-type as character
field sum-rubl as decimal
field vat-rubl as decimal
field sum-base as decimal
field vat-base as decimal
.
define temp-table temp_oborot_parts-2 no-undo like parts
field ext-doc-type as character
field sum-rubl as decimal
field vat-rubl as decimal
field sum-base as decimal
field vat-base as decimal
.
define temp-table temp-null no-undo like temp-t-post-stk-line.
define variable p-first as logical no-undo .
p-first = true .
if cli-art = "yes" then do:
 gds-zap-artic:label in frame zapas = "Арт.Постав."  .
end.
case RetClassify :
      when "no-classify":U then do:
        for each g#post-f :
            run one-post in this-procedure .
            run run1 in this-procedure .
        end.
      end.
    when "post":U then do:
      run run2 in this-procedure .
    end.
    when "post/grp-goods":U then do:
      run run2 in this-procedure .
    end.
end case.
if xtogobj =  true then do:
   find first obj-list.
    if available obj-list then do:
      run print-footer in this-procedure  ( 0 , obj-list.obj-name ).
      run clear-itemo- in this-procedure .
    end.
end.
procedure one-post :
 do
 on error undo, return error return-value
 :
  run waitfram-show in this-procedure  (g#post-f.obj-name) .
  for each obj-list :
    for each buf_parts no-lock where
        buf_parts.host-code = v-cntxt-host-code-obj      and
        buf_parts.obj-code = obj-list.obj-code and
        buf_parts.obj-type = obj-list.obj-type and
        buf_parts.supp-type = g#post-f.obj-type  and
        buf_parts.supp-code = g#post-f.obj-code  and
        buf_parts.status_   = true             and
        buf_parts.fact-date >= x-date-start    and
        buf_parts.fact-date <= x-date-end
    :
        if type-stor <> 1 then do:
           if buf_parts.purch-code <>  type-stor - 1 then next.
        end.
      find first goods no-lock where goods.artic      = buf_parts.artic     and
                                     goods.prod-type = buf_parts.prod-type and
                                     goods.prod-code = buf_parts.prod-code no-error .
        if not available goods then next.
        find first trn-doc no-lock where
              trn-doc.doc-code     = buf_parts.out-code
               no-error .
        if not available trn-doc then next.
        create temp_oborot_parts.
        BUFFER-COPY buf_parts  to temp_oborot_parts
            assign
              temp_oborot_parts.ext-doc-type = trn-doc.ext-doc-type
              temp_oborot_parts.sum-rubl = buf_parts.fact-qnty * buf_parts.price-rubl
              temp_oborot_parts.sum-base = buf_parts.fact-qnty * buf_parts.price-base
            .
        find first temp-t-post-stk-line where
                   temp-t-post-stk-line.artic     = temp_oborot_parts.artic     and
                   temp-t-post-stk-line.prod-type = temp_oborot_parts.prod-type and
                   temp-t-post-stk-line.prod-code = temp_oborot_parts.prod-code  no-error .
                   if not available temp-t-post-stk-line then do:
                      create temp-t-post-stk-line.
                      assign
                        temp-t-post-stk-line.artic     = temp_oborot_parts.artic
                        temp-t-post-stk-line.prod-type = temp_oborot_parts.prod-type
                        temp-t-post-stk-line.prod-code = temp_oborot_parts.prod-code
                        temp-t-post-stk-line.gds-name  = goods.gds-name
                        temp-t-post-stk-line.unit-base = goods.unit-base
                        temp-t-post-stk-line.prt-root  = 0
                        temp-t-post-stk-line.Goods-grp-name   = goods.grp-name
                        temp-t-post-stk-line.gds-code         = goods.gds-code
                        temp-t-post-stk-line.gds-type         = goods.gds-type
                        temp-t-post-stk-line.Cli-type         = g#post-f.obj-type
                        temp-t-post-stk-line.Cli-code         = g#post-f.obj-code
                        temp-t-post-stk-line.Clients-grp-name = g#post-f.obj-name
                      .
                   end.
    end.
  end.
 end.
end procedure.
procedure Print-Header :
define input parameter N as integer no-undo .
define input parameter Name as char no-undo .
    PUT stream  OutStream  UNFORMATTED trim(Name) AT ((N - 1) * 10 ) format "x(100)" skip.
    if Make-Excel then  put   stream ForExcel unformatted fill(" " + CHR(9), N - 1) trim(Name) skip.
END PROCEDURE.
PROCEDURE display-line :
  i = i + 1.
If Integer(10) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(10) .
     IF ( i modulo Temp1 = 0 ) AND ( i >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( i )) .
  run clear-item  in this-procedure .
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
          if cli-art = "yes" then do:
              gds-post-artic     = "" .
              find first ub.ext-artic no-lock where
                      ub.ext-artic.gds-code = temp-t-post-stk-line.gds-code and
                      ub.ext-artic.cli-type = temp-t-post-stk-line.Cli-type and
                      ub.ext-artic.cli-code = temp-t-post-stk-line.Cli-code and
                      ub.ext-artic.status_   =  'тек':U no-error .
              if available ub.ext-artic then do:
                    assign
                      gds-post-artic     = ub.ext-artic.ext-artic
                    .
              end.
             gds-zap-artic = gds-post-artic .
          end.
run ob-line in this-procedure
      ( INPUT temp-t-post-stk-line.artic     ,
        INPUT temp-t-post-stk-line.prod-code ,
        INPUT temp-t-post-stk-line.prod-type  ).
run ost-line in this-procedure
      ( INPUT temp-t-post-stk-line.artic     ,
        INPUT temp-t-post-stk-line.prod-code ,
        INPUT temp-t-post-stk-line.prod-type  ) .
         run calc-sub-itog in this-procedure (0).
         run calc-sub-itog in this-procedure (6).
       if  not ( (ostatok-start[1] = 0  and
                 prih         [1] = 0  and
                 rash         [1] = 0  and
                 kassa        [1] = 0  and
                 inv          [1] = 0  and
                 vzvr         [1] = 0  and
                 spis         [1] = 0  and
                 vzvr-post    [1] = 0  and
                 ostatok-end  [1] = 0)) then do:
         IF NOT Sums-Only then DO:
            run display-str1 in this-procedure .
            run clear-item in this-procedure .
         End.
       End.
  END PROCEDURE.
PROCEDURE display-str1  :
      run di-qnty ("кол-во", 1, gds-zap-b-code,gds-zap-artic,gds-zap-gds-name,gds-zap-unit-base,"").
         if show-cost then do : run di ( "учет." , 2, "","","","","" ).  end.
         if xshowgoods then do : run di ( "в пути", 7, "","","","","" ).  end.
      run clear-item.
 END PROCEDURE.
PROCEDURE Di :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then do:
if  not (
   (b1-ostatok-start[1] = 0  and
    b1-Prih         [1] = 0  AND
    b1-RAsh         [1] = 0  AND
    b1-KAssa        [1] = 0  AND
    b1-Inv          [1] = 0  AND
    b1-vzvr         [1] = 0  AND
    b1-spis         [1] = 0  AND
    b1-vzvr-post    [1] = 0  AND
    b1-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                b1-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                b1-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                b1-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                b1-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                b1-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                b1-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                b1-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                b1-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                b1-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
  end.
   WHEN "B2":U  Then do:
if  not (
   (b2-ostatok-start[1] = 0  and
    b2-Prih         [1] = 0  AND
    b2-RAsh         [1] = 0  AND
    b2-KAssa        [1] = 0  AND
    b2-Inv          [1] = 0  AND
    b2-vzvr         [1] = 0  AND
    b2-spis         [1] = 0  AND
    b2-vzvr-post    [1] = 0  AND
    b2-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                b2-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                b2-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                b2-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                b2-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                b2-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                b2-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                b2-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                b2-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                b2-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
  end.
   WHEN "BI":U Then do:
if  not (
   (bi-ostatok-start[1] = 0  and
    bi-Prih         [1] = 0  AND
    bi-RAsh         [1] = 0  AND
    bi-KAssa        [1] = 0  AND
    bi-Inv          [1] = 0  AND
    bi-vzvr         [1] = 0  AND
    bi-spis         [1] = 0  AND
    bi-vzvr-post    [1] = 0  AND
    bi-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                bi-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                bi-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                bi-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                bi-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                bi-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                bi-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                bi-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                bi-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                bi-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
  end.
   WHEN "P":U Then do:
if  not (
   (p-ostatok-start[1] = 0  and
    p-Prih         [1] = 0  AND
    p-RAsh         [1] = 0  AND
    p-KAssa        [1] = 0  AND
    p-Inv          [1] = 0  AND
    p-vzvr         [1] = 0  AND
    p-spis         [1] = 0  AND
    p-vzvr-post    [1] = 0  AND
    p-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                p-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                p-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                p-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                p-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                p-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                p-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                p-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                p-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                p-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
  end.
   WHEN "O"  Then     DO :
if  not (
   (o-ostatok-start[1] = 0  and
    o-Prih         [1] = 0  AND
    o-RAsh         [1] = 0  AND
    o-KAssa        [1] = 0  AND
    o-Inv          [1] = 0  AND
    o-vzvr         [1] = 0  AND
    o-spis         [1] = 0  AND
    o-vzvr-post    [1] = 0  AND
    o-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                o-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                o-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                o-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                o-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                o-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                o-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                o-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                o-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                o-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
     End.
   WHEN ""  Then DO:
if  not (
   (ostatok-start[1] = 0  and
    Prih         [1] = 0  AND
    RAsh         [1] = 0  AND
    KAssa        [1] = 0  AND
    Inv          [1] = 0  AND
    vzvr         [1] = 0  AND
    spis         [1] = 0  AND
    vzvr-post    [1] = 0  AND
    Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
     End.
   End case.
 END PROCEDURE.
PROCEDURE Di-qnty :
define input parameter p1 as char no-undo.
define input parameter p2 as int no-undo.
define input parameter p3 as char no-undo.
define input parameter p4 as char no-undo.
define input parameter p5 as char no-undo.
define input parameter p6 as char no-undo.
define input parameter p7 as char no-undo.
 CASE CAPS(p7) :
   WHEN "B1":U  Then DO :
if  not (
   (b1-ostatok-start[1] = 0  and
    b1-Prih         [1] = 0  AND
    b1-RAsh         [1] = 0  AND
    b1-KAssa        [1] = 0  AND
    b1-Inv          [1] = 0  AND
    b1-vzvr         [1] = 0  AND
    b1-spis         [1] = 0  AND
    b1-vzvr-post    [1] = 0  AND
    b1-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                b1-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                b1-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                b1-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                b1-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                b1-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                b1-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                b1-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                b1-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                b1-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
if  not (
   (b1-ostatok-start[1] = 0  and
    b1-Prih         [1] = 0  AND
    b1-RAsh         [1] = 0  AND
    b1-KAssa        [1] = 0  AND
    b1-Inv          [1] = 0  AND
    b1-vzvr         [1] = 0  AND
    b1-spis         [1] = 0  AND
    b1-vzvr-post    [1] = 0  AND
    b1-Ostatok-end  [1] = 0)) then DO:
    if Make-Excel then  put   stream ForExcel unformatted p3 CHR(9)
                p4 CHR(9)
                p5 CHR(9)
                p6 CHR(9)
                   ( excel-qnty(b1-ostatok-start[1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-ostatok-start[2]) +  CHR(9))   else ("")
if Show-sale  then  ( "" +                              CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(b1-ostatok-start[7]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-Prih         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-Prih         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b1-Prih         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-RAsh         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-RAsh         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b1-RAsh         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-KAssa        [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-KAssa        [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b1-KAssa        [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-Inv          [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-Inv          [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b1-Inv          [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-spis         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-spis         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b1-spis         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-vzvr         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-vzvr         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b1-vzvr         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-vzvr-post    [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-vzvr-post    [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b1-vzvr-post    [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b1-Ostatok-end  [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b1-Ostatok-end  [2]) +  CHR(9))   else ("")
if Show-sale  then  (  "" +                             CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(b1-ostatok-end[7]) +  CHR(9))   else ("")
   chr(10).
end.
                End.
   WHEN "B2":U  Then DO :
if  not (
   (b2-ostatok-start[1] = 0  and
    b2-Prih         [1] = 0  AND
    b2-RAsh         [1] = 0  AND
    b2-KAssa        [1] = 0  AND
    b2-Inv          [1] = 0  AND
    b2-vzvr         [1] = 0  AND
    b2-spis         [1] = 0  AND
    b2-vzvr-post    [1] = 0  AND
    b2-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                b2-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                b2-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                b2-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                b2-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                b2-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                b2-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                b2-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                b2-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                b2-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
if  not (
   (b2-ostatok-start[1] = 0  and
    b2-Prih         [1] = 0  AND
    b2-RAsh         [1] = 0  AND
    b2-KAssa        [1] = 0  AND
    b2-Inv          [1] = 0  AND
    b2-vzvr         [1] = 0  AND
    b2-spis         [1] = 0  AND
    b2-vzvr-post    [1] = 0  AND
    b2-Ostatok-end  [1] = 0)) then DO:
    if Make-Excel then  put   stream ForExcel unformatted p3 CHR(9)
                p4 CHR(9)
                p5 CHR(9)
                p6 CHR(9)
                   ( excel-qnty(b2-ostatok-start[1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-ostatok-start[2]) +  CHR(9))   else ("")
if Show-sale  then  ( "" +                              CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(b2-ostatok-start[7]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-Prih         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-Prih         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b2-Prih         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-RAsh         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-RAsh         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b2-RAsh         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-KAssa        [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-KAssa        [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b2-KAssa        [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-Inv          [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-Inv          [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b2-Inv          [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-spis         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-spis         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b2-spis         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-vzvr         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-vzvr         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b2-vzvr         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-vzvr-post    [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-vzvr-post    [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(b2-vzvr-post    [8]) +  CHR(9))   else ("")
                   ( excel-qnty(b2-Ostatok-end  [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(b2-Ostatok-end  [2]) +  CHR(9))   else ("")
if Show-sale  then  (  "" +                             CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(b2-ostatok-end[7]) +  CHR(9))   else ("")
   chr(10).
end.
             End.
   WHEN "BI":U Then  DO :
if  not (
   (bi-ostatok-start[1] = 0  and
    bi-Prih         [1] = 0  AND
    bi-RAsh         [1] = 0  AND
    bi-KAssa        [1] = 0  AND
    bi-Inv          [1] = 0  AND
    bi-vzvr         [1] = 0  AND
    bi-spis         [1] = 0  AND
    bi-vzvr-post    [1] = 0  AND
    bi-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                bi-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                bi-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                bi-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                bi-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                bi-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                bi-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                bi-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                bi-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                bi-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
if  not (
   (bi-ostatok-start[1] = 0  and
    bi-Prih         [1] = 0  AND
    bi-RAsh         [1] = 0  AND
    bi-KAssa        [1] = 0  AND
    bi-Inv          [1] = 0  AND
    bi-vzvr         [1] = 0  AND
    bi-spis         [1] = 0  AND
    bi-vzvr-post    [1] = 0  AND
    bi-Ostatok-end  [1] = 0)) then DO:
    if Make-Excel then  put   stream ForExcel unformatted p3 CHR(9)
                p4 CHR(9)
                p5 CHR(9)
                p6 CHR(9)
                   ( excel-qnty(bi-ostatok-start[1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-ostatok-start[2]) +  CHR(9))   else ("")
if Show-sale  then  ( "" +                              CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(bi-ostatok-start[7]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-Prih         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-Prih         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(bi-Prih         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-RAsh         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-RAsh         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(bi-RAsh         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-KAssa        [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-KAssa        [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(bi-KAssa        [8]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-Inv          [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-Inv          [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(bi-Inv          [8]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-spis         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-spis         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(bi-spis         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-vzvr         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-vzvr         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(bi-vzvr         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-vzvr-post    [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-vzvr-post    [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(bi-vzvr-post    [8]) +  CHR(9))   else ("")
                   ( excel-qnty(bi-Ostatok-end  [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(bi-Ostatok-end  [2]) +  CHR(9))   else ("")
if Show-sale  then  (  "" +                             CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(bi-ostatok-end[7]) +  CHR(9))   else ("")
   chr(10).
end.
             End.
   WHEN ""  Then     DO :
if  not (
   (ostatok-start[1] = 0  and
    Prih         [1] = 0  AND
    RAsh         [1] = 0  AND
    KAssa        [1] = 0  AND
    Inv          [1] = 0  AND
    vzvr         [1] = 0  AND
    spis         [1] = 0  AND
    vzvr-post    [1] = 0  AND
    Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
if  not (
   (ostatok-start[1] = 0  and
    Prih         [1] = 0  AND
    RAsh         [1] = 0  AND
    KAssa        [1] = 0  AND
    Inv          [1] = 0  AND
    vzvr         [1] = 0  AND
    spis         [1] = 0  AND
    vzvr-post    [1] = 0  AND
    Ostatok-end  [1] = 0)) then DO:
    if Make-Excel then  put   stream ForExcel unformatted p3 CHR(9)
                p4 CHR(9)
                p5 CHR(9)
                p6 CHR(9)
                   ( excel-qnty(ostatok-start[1]) +  CHR(9))
if Show-cost  then  ( excel-sum(ostatok-start[2]) +  CHR(9))   else ("")
if Show-sale  then  ( "" +                              CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(ostatok-start[7]) +  CHR(9))   else ("")
                   ( excel-qnty(Prih         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(Prih         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(Prih         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(RAsh         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(RAsh         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(RAsh         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(KAssa        [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(KAssa        [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(KAssa        [8]) +  CHR(9))   else ("")
                   ( excel-qnty(Inv          [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(Inv          [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(Inv          [8]) +  CHR(9))   else ("")
                   ( excel-qnty(spis         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(spis         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(spis         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(vzvr         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(vzvr         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(vzvr         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(vzvr-post    [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(vzvr-post    [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(vzvr-post    [8]) +  CHR(9))   else ("")
                   ( excel-qnty(Ostatok-end  [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(Ostatok-end  [2]) +  CHR(9))   else ("")
if Show-sale  then  (  "" +                             CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(ostatok-end[7]) +  CHR(9))   else ("")
   chr(10).
end.
              End.
   WHEN "P"  Then     DO :
if  not (
   (p-ostatok-start[1] = 0  and
    p-Prih         [1] = 0  AND
    p-RAsh         [1] = 0  AND
    p-KAssa        [1] = 0  AND
    p-Inv          [1] = 0  AND
    p-vzvr         [1] = 0  AND
    p-spis         [1] = 0  AND
    p-vzvr-post    [1] = 0  AND
    p-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                p-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                p-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                p-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                p-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                p-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                p-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                p-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                p-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                p-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
if  not (
   (p-ostatok-start[1] = 0  and
    p-Prih         [1] = 0  AND
    p-RAsh         [1] = 0  AND
    p-KAssa        [1] = 0  AND
    p-Inv          [1] = 0  AND
    p-vzvr         [1] = 0  AND
    p-spis         [1] = 0  AND
    p-vzvr-post    [1] = 0  AND
    p-Ostatok-end  [1] = 0)) then DO:
    if Make-Excel then  put   stream ForExcel unformatted p3 CHR(9)
                p4 CHR(9)
                p5 CHR(9)
                p6 CHR(9)
                   ( excel-qnty(p-ostatok-start[1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-ostatok-start[2]) +  CHR(9))   else ("")
if Show-sale  then  ( "" +                              CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(p-ostatok-start[7]) +  CHR(9))   else ("")
                   ( excel-qnty(p-Prih         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-Prih         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(p-Prih         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(p-RAsh         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-RAsh         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(p-RAsh         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(p-KAssa        [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-KAssa        [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(p-KAssa        [8]) +  CHR(9))   else ("")
                   ( excel-qnty(p-Inv          [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-Inv          [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(p-Inv          [8]) +  CHR(9))   else ("")
                   ( excel-qnty(p-spis         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-spis         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(p-spis         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(p-vzvr         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-vzvr         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(p-vzvr         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(p-vzvr-post    [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-vzvr-post    [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(p-vzvr-post    [8]) +  CHR(9))   else ("")
                   ( excel-qnty(p-Ostatok-end  [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(p-Ostatok-end  [2]) +  CHR(9))   else ("")
if Show-sale  then  (  "" +                             CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(p-ostatok-end[7]) +  CHR(9))   else ("")
   chr(10).
end.
              End.
   WHEN "O"  Then     DO :
if  not (
   (o-ostatok-start[1] = 0  and
    o-Prih         [1] = 0  AND
    o-RAsh         [1] = 0  AND
    o-KAssa        [1] = 0  AND
    o-Inv          [1] = 0  AND
    o-vzvr         [1] = 0  AND
    o-spis         [1] = 0  AND
    o-vzvr-post    [1] = 0  AND
    o-Ostatok-end  [1] = 0)) then DO:
             DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
                p3 @ gds-zap-b-code
                p4 @ gds-zap-artic
                p5 @ gds-zap-gds-name
                p6 @ gds-zap-unit-base
                p1 @ gds-type
                o-ostatok-start[p2] when ( NOT( Show-SAle = true and p2 = 8 )) @  F-ostatok-start
                o-Prih         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Prih
                o-RAsh         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-RAsh
                o-KAssa        [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-KAssa
                o-Inv          [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-Inv
                o-spis         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-spis
                o-vzvr         [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr
                o-vzvr-post    [p2] when ( NOT( xShowgoods = true and p2 = 7 )) @  F-vzvr-post
                o-Ostatok-end  [p2] when ( NOT( Show-SAle = true and p2 = 8 ))  @  F-Ostatok-end
               with FRAME ZAPAS .
               DOWN stream   OutStream 1 with FRAME ZAPAS.
end.
if  not (
   (o-ostatok-start[1] = 0  and
    o-Prih         [1] = 0  AND
    o-RAsh         [1] = 0  AND
    o-KAssa        [1] = 0  AND
    o-Inv          [1] = 0  AND
    o-vzvr         [1] = 0  AND
    o-spis         [1] = 0  AND
    o-vzvr-post    [1] = 0  AND
    o-Ostatok-end  [1] = 0)) then DO:
    if Make-Excel then  put   stream ForExcel unformatted p3 CHR(9)
                p4 CHR(9)
                p5 CHR(9)
                p6 CHR(9)
                   ( excel-qnty(o-ostatok-start[1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-ostatok-start[2]) +  CHR(9))   else ("")
if Show-sale  then  ( "" +                              CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(o-ostatok-start[7]) +  CHR(9))   else ("")
                   ( excel-qnty(o-Prih         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-Prih         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(o-Prih         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(o-RAsh         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-RAsh         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(o-RAsh         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(o-KAssa        [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-KAssa        [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(o-KAssa        [8]) +  CHR(9))   else ("")
                   ( excel-qnty(o-Inv          [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-Inv          [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(o-Inv          [8]) +  CHR(9))   else ("")
                   ( excel-qnty(o-spis         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-spis         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(o-spis         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(o-vzvr         [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-vzvr         [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(o-vzvr         [8]) +  CHR(9))   else ("")
                   ( excel-qnty(o-vzvr-post    [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-vzvr-post    [2]) +  CHR(9))   else ("")
if Show-sale  then  ( excel-sum(o-vzvr-post    [8]) +  CHR(9))   else ("")
                   ( excel-qnty(o-Ostatok-end  [1]) +  CHR(9))
if Show-cost  then  ( excel-sum(o-Ostatok-end  [2]) +  CHR(9))   else ("")
if Show-sale  then  (  "" +                             CHR(9))   else ("")
if xShowgoods then  ( excel-qnty(o-ostatok-end[7]) +  CHR(9))   else ("")
   chr(10).
end.
              End.
    End case.
 END PROCEDURE.
procedure Print-Footer :
define input parameter Nx as integer no-undo .
define input parameter Name as char no-undo .
    if Nx = 1 Then DO:
         run di-qnty  in this-procedure ("кол-во", 1,"","Итого по : ",trim(name),"","b1").
         if show-cost then do : run di  in this-procedure ( "учет." , 2, "","","","","b1" ).  end.
         if xshowgoods then do : run di in this-procedure  ( "в пути", 7, "","","","","b1" ).  end.
         if not sums-only then run u-line in this-procedure .
         run clear-itemb1- in this-procedure .
         End.
 if Nx = 2 Then DO:
         run di-qnty ("кол-во", 1,"","","Итого по : " + trim(name),"","b2").
         if show-cost then do : run di ( "учет." , 2, "","","","","b2" ).  end.
         if xshowgoods then do : run di ( "в пути", 8, "","","","","b2" ).  end.
         if not sums-only then run u-line.
         run clear-itemb2-.
        End.
 if nx = 3 then do:
    if  not ((p-ostatok-start[1] = 0  and
              p-prih         [1] = 0  and
              p-rash         [1] = 0  and
              p-kassa        [1] = 0  and
              p-inv          [1] = 0  and
              p-vzvr         [1] = 0  and
              p-vzvr-post    [1] = 0  and
              p-ostatok-end  [1] = 0)) then do:
        if not sums-only then run u-line.
        run di-qnty ("кол-во", 1,"","Итого по пост-ку" , trim(name),"","p").
        if show-cost then do : run di ( "учет." , 2, "","","","","p" ).  end.
        if xShowGoods then do : run di ( "в пути", 7, "","","","","p" ).  end.
        if not sums-only then run u-line.
      end.
      run clear-itemp- in this-procedure .
 End.
 if Nx = 0 Then DO:
         run di-qnty ("кол-во", 1,"","Итого  объект: " , trim(name),"","o").
         if show-cost then do : run di ( "учет." , 2, "","","","","o" ).  end.
         if xshowgoods then do : run di ( "в пути", 8, "","","","","o" ).  end.
         if not sums-only then run u-line.
         run clear-itemo-.
          End.
 END PROCEDURE.
PROCEDURE Clear-item :
define variable kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
    prih             [kk]  = 0
    rash             [kk]  = 0
    kassa            [kk]  = 0
    spis             [kk]  = 0
    Inv              [kk]  = 0
    Inv2             [kk]  = 0
    vzvr             [kk]  = 0
    vzvr-post        [kk]  = 0
    full-prih             [kk]  = 0
    full-rash             [kk]  = 0
    full-kassa            [kk]  = 0
    full-spis             [kk]  = 0
    full-Inv              [kk]  = 0
    full-Inv2             [kk]  = 0
    full-vzvr             [kk]  = 0
    full-vzvr-post        [kk]  = 0
    ostatok-start         [kk]  = 0
    ostatok-end           [kk]  = 0
     .
       End.
 END PROCEDURE.
PROCEDURE Clear-itemb1- :
define variable kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   b1-prih             [kk]  = 0
   b1-rash             [kk]  = 0
   b1-kassa            [kk]  = 0
   b1-spis             [kk]  = 0
   b1-Inv              [kk]  = 0
   b1-vzvr             [kk]  = 0
   b1-vzvr-post        [kk]  = 0
   b1-ostatok-end      [kk]  = 0
   b1-ostatok-start    [kk]  = 0
   .
       End.
 END PROCEDURE.
PROCEDURE Clear-itemb2- :
define variable kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   b2-prih             [kk]  = 0
   b2-rash             [kk]  = 0
   b2-kassa            [kk]  = 0
   b2-spis             [kk]  = 0
   b2-Inv              [kk]  = 0
   b2-vzvr             [kk]  = 0
   b2-vzvr-post        [kk]  = 0
   b2-ostatok-end      [kk]  = 0
   b2-ostatok-start    [kk]  = 0
   .
   End.
 END PROCEDURE.
PROCEDURE Clear-itemp- :
define variable kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   p-prih             [kk]  = 0
   p-rash             [kk]  = 0
   p-kassa            [kk]  = 0
   p-spis             [kk]  = 0
   p-Inv              [kk]  = 0
   p-vzvr             [kk]  = 0
   p-vzvr-post        [kk]  = 0
   p-ostatok-end      [kk]  = 0
   p-ostatok-start    [kk]  = 0
   .
   End.
 END PROCEDURE.
PROCEDURE Clear-itemo- :
define variable kk as int no-undo.
 REPEAT kk = 1 to 9:
 Assign
   o-prih             [kk]  = 0
   o-rash             [kk]  = 0
   o-kassa            [kk]  = 0
   o-Spis             [kk]  = 0
   o-Inv              [kk]  = 0
   o-vzvr             [kk]  = 0
   o-vzvr-post        [kk]  = 0
   o-ostatok-end      [kk]  = 0
   o-ostatok-start    [kk]  = 0
   .
   End.
 END PROCEDURE.
PROCEDURE ob-line :
define INPUT  parameter x-artic          like goods.artic        no-undo.
define INPUT  parameter x-prod-code      like goods.prod-code    no-undo.
define INPUT  parameter x-prod-type      like goods.prod-type    no-undo.
     FOR each temp_oborot_parts where
              temp_oborot_parts.artic        = x-artic
        AND   temp_oborot_parts.prod-code    = x-prod-code
        AND   temp_oborot_parts.prod-type    = x-prod-type
               no-lock :
        CASE temp_oborot_parts.ext-doc-type:
             WHEN        'iv':U      OR
             WHEN        'rv':U  OR
             WHEN        'im':U     THEN     DO:
           if t-in then
           ASSIGN prih[1 ]   = prih[1 ]   +  temp_oborot_parts.fact-qnty
                  prih[2 ]   = prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  prih[3 ]   = prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-prih[1 ]   = full-prih[1 ]   +  temp_oborot_parts.fact-qnty
                  full-prih[2 ]   = full-prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-prih[3 ]   = full-prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
              end.
             WHEN        'ie':U   THEN     DO:
           ASSIGN prih[1 ]   = prih[1 ]   +  temp_oborot_parts.fact-qnty
                  prih[2 ]   = prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  prih[3 ]   = prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-prih[1 ]   = full-prih[1 ]   +  temp_oborot_parts.fact-qnty
                  full-prih[2 ]   = full-prih[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-prih[3 ]   = full-prih[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
             WHEN        're':U  THEN DO:
           ASSIGN vzvr[1 ]   = vzvr[1 ]   +  temp_oborot_parts.fact-qnty
                  vzvr[2 ]   = vzvr[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  vzvr[3 ]   = vzvr[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-vzvr[1 ]   = full-vzvr[1 ]   +  temp_oborot_parts.fact-qnty
                  full-vzvr[2 ]   = full-vzvr[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-vzvr[3 ]   = full-vzvr[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
             WHEN       'ep':U  THEN DO:
           ASSIGN vzvr-post[1 ]   = vzvr-post[1 ]   +  temp_oborot_parts.fact-qnty
                  vzvr-post[2 ]   = vzvr-post[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  vzvr-post[3 ]   = vzvr-post[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-vzvr-post[1 ]   = full-vzvr-post[1 ]   +  temp_oborot_parts.fact-qnty
                  full-vzvr-post[2 ]   = full-vzvr-post[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-vzvr-post[3 ]   = full-vzvr-post[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
             WHEN       'ee':U          THEN  DO:
             ASSIGN rash[1 ]   = rash[1 ]   +  temp_oborot_parts.fact-qnty
                    rash[2 ]   = rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                    rash[3 ]   = rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                    .
             ASSIGN full-rash[1 ]   = full-rash[1 ]   +  temp_oborot_parts.fact-qnty
                    full-rash[2 ]   = full-rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                    full-rash[3 ]   = full-rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                    .
                 End.
             WHEN       'ev':U       OR
             WHEN       'em':U        THEN  DO:
           if t-in then
           ASSIGN rash[1 ]   = rash[1 ]   +  temp_oborot_parts.fact-qnty
                  rash[2 ]   = rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  rash[3 ]   = rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-rash[1 ]   = full-rash[1 ]   +  temp_oborot_parts.fact-qnty
                  full-rash[2 ]   = full-rash[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-rash[3 ]   = full-rash[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
             WHEN       'es':U  then
           ASSIGN kassa[1 ]   = kassa[1 ]   +  temp_oborot_parts.fact-qnty
                  kassa[2 ]   = kassa[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  kassa[3 ]   = kassa[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  full-kassa[1 ]   = full-kassa[1 ]   +  temp_oborot_parts.fact-qnty
                  full-kassa[2 ]   = full-kassa[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-kassa[3 ]   = full-kassa[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
             WHEN       'rs':U THEN  DO:
           ASSIGN kassa[1 ]   = kassa[1 ]   -  temp_oborot_parts.fact-qnty
                  kassa[2 ]   = kassa[2 ]   -  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  kassa[3 ]   = kassa[3 ]   -  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-kassa[1 ]   = full-kassa[1 ]   -  temp_oborot_parts.fact-qnty
                  full-kassa[2 ]   = full-kassa[2 ]   -  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-kassa[3 ]   = full-kassa[3 ]   -  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
             WHEN       'vt':U               or
             WHEN       'mp':U  or
             WHEN       'vp':U          then do:
                ASSIGN  INV[1 ]   = INV[1 ]   +  temp_oborot_parts.fact-qnty
                        Inv[2 ]   = Inv[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                        Inv[3 ]   = Inv[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                        INV2[1 ]   = INV2[1 ]   +  temp_oborot_parts.fact-qnty
                        INV2[2 ]   = INV2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                        full-INV2[1 ]   = full-INV2[1 ]   +  temp_oborot_parts.fact-qnty
                        full-INV2[2 ]   = full-INV2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                        .
             end.
             WHEN       'pc':U      THEN  DO:
           ASSIGN INV[1 ]   = INV[1 ]   +  temp_oborot_parts.fact-qnty
                  Inv[2 ]   = Inv[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  Inv[3 ]   = Inv[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
           when 'ap':U  then do:
              ASSIGN
                  Inv[2 ]   = Inv[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  Inv2[2 ]   = Inv2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-INV2[2 ]   = full-INV2[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  .
           end.
             WHEN       'we':U       THEN  DO:
           ASSIGN spis[1 ]   = spis[1 ]   +  temp_oborot_parts.fact-qnty
                  spis[2 ]   = spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  spis[3 ]   = spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-spis[1 ]   = full-spis[1 ]   +  temp_oborot_parts.fact-qnty
                  full-spis[2 ]   = full-spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-spis[3 ]   = full-spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
             WHEN       'wm':U       THEN  DO:
           if t-in then
           ASSIGN spis[1 ]   = spis[1 ]   +  temp_oborot_parts.fact-qnty
                  spis[2 ]   = spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  spis[3 ]   = spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
           ASSIGN full-spis[1 ]   = full-spis[1 ]   +  temp_oborot_parts.fact-qnty
                  full-spis[2 ]   = full-spis[2 ]   +  if tprintrubl then temp_oborot_parts.sum-rubl else temp_oborot_parts.sum-base
                  full-spis[3 ]   = full-spis[3 ]   +  if tprintrubl then temp_oborot_parts.vat-rubl else temp_oborot_parts.vat-base
                  .
                 End.
          End CASE.
   End.
END PROCEDURE.
procedure ost-line :
 do
 on error undo, return error return-value
 :
define INPUT  parameter x-artic          like goods.artic        no-undo.
define INPUT  parameter x-prod-code      like goods.prod-code    no-undo.
define INPUT  parameter x-prod-type      like goods.prod-type    no-undo.
 define variable ostatok-today as decimal EXTENT 10  no-undo .
 ostatok-today[1] = 0 .
 ostatok-today[2] = 0 .
 define buffer ost_parts for parts .
 for each obj-list :
    for each ost_parts no-lock where
        ost_parts.artic     = x-artic             and
        ost_parts.prod-type = x-prod-type         and
        ost_parts.prod-code = x-prod-code         and
        ost_parts.host-code = v-cntxt-host-code-obj         and
        ost_parts.supp-type = g#post-f.obj-type     and
        ost_parts.supp-code = g#post-f.obj-code     and
        ost_parts.status_   =  false              and
        ost_parts.obj-type  =  obj-list.obj-type  and
        ost_parts.obj-code  =  obj-list.obj-code  and
        ost_parts.in-code   <> ost_parts.out-code and
        ost_parts.rsrv-free = true    :
        if type-stor <> 1 then do:
           if ost_parts.purch-code <>  type-stor - 1 then next.
        end.
        if ost_parts.out-code = 'free-zone':U then do:
           ostatok-today[1] = ostatok-today[1] + ost_parts.fact-qnty .
           ostatok-today[2] = ostatok-today[2] + ost_parts.fact-qnty  * (if tprintrubl  = true then ost_parts.price-rubl else ost_parts.price-base).
        end.
        else do:
            ostatok-today[1] = ostatok-today[1] + abs(ost_parts.fact-qnty) .
            ostatok-today[2] = ostatok-today[2] + abs(ost_parts.fact-qnty) * (if tprintrubl  = true then ost_parts.price-rubl else ost_parts.price-base) .
        end.
    end.
  end.
 define variable oborot1  as decimal no-undo .
 define variable oborot12 as decimal no-undo .
 define variable oborot2  as decimal no-undo .
 define variable oborot22 as decimal no-undo .
 assign
  oborot1  = 0
  oborot12 = 0
  oborot2  = 0
  oborot22 = 0
  .
  if type-stor <> 1 then do:
      assign
        oborot1  = full-prih[1] - full-rash[1] - full-kassa[1] - full-vzvr-post[1] + full-vzvr[1] - full-spis[1] + inv[1]
        oborot12 = full-prih[2] - full-rash[2] - full-kassa[2] - full-vzvr-post[2] + full-vzvr[2] - full-spis[2] + inv[2]
      .
  end.
  else
    assign
        oborot1  = full-prih[1] - full-rash[1] - full-kassa[1] - full-vzvr-post[1] + full-vzvr[1] - full-spis[1] + full-inv2[1]
        oborot12 = full-prih[2] - full-rash[2] - full-kassa[2] - full-vzvr-post[2] + full-vzvr[2] - full-spis[2] + full-inv2[2]
    .
 if x-date-start = today then  do:
    ostatok-end  [1]  = ostatok-today [1].
    ostatok-end  [2]  = ostatok-today [2].
    ostatok-start[1]  = ostatok-today [1] .
    ostatok-start[2]  = ostatok-today [2] .
    end.
 if x-date-end   = today then do:
    ostatok-end  [1]    = ostatok-today [1] .
    ostatok-end  [2]    = ostatok-today [2] .
    ostatok-start[1]    = ostatok-today [1]  - oborot1 .
    ostatok-start[2]    = ostatok-today [2]  - oborot12 .
    end.
 if x-date-end   < today then do:
   oborot2  = 0 .
   oborot22 = 0 .
    run ob-line2 in this-procedure ( input x-artic     ,
                  input x-prod-code ,
                  input x-prod-type ,
                  input x-date-end + 1 ,
                  input today   ,
                  output oborot2 ,
                  output oborot22
                    ) .
    ostatok-end  [1]    = ostatok-today [1] - oborot2 .
    ostatok-end  [2]    = ostatok-today [2] - oborot22 .
    ostatok-start[1]    = ostatok-today [1] - (oborot1 + oborot2)  .
    ostatok-start[2]    = ostatok-today [2] - (oborot12 + oborot22)  .
 end.
  if xShowGoods Then DO :
      run goods-way in this-procedure (
        input x-artic     ,
        input x-prod-code ,
        input x-prod-type ,
        input 1 ,
        output ostatok-start  [7] ) .
      run goods-way in this-procedure (
        input x-artic     ,
        input x-prod-code ,
        input x-prod-type ,
        input 2 ,
        output ostatok-end  [7] ) .
  end.
 end.
end procedure.
PROCEDURE Calc-Sub-itog :
define input parameter tt as int no-undo.
define variable b as int no-undo.
repeat b = 1 to 3 :
  Assign
  B1-Prih[b + TT]    = B1-Prih[b + TT]    +  Prih[b + TT]
  B2-Prih[b + TT]    = B2-Prih[b + TT]    +  Prih[b + TT]
  Bi-Prih[b + TT]    = Bi-Prih[b + TT]    +  Prih[b + TT]
  p-Prih[b + TT]     = p-Prih[b + TT]    +  Prih[b + TT]
  o-Prih[b + TT]     = o-Prih[b + TT]    +  Prih[b + TT]
  B1-RAsh[b + TT]    = B1-RAsh[b + TT]    +  RAsh[b + TT]
  B2-RAsh[b + TT]    = B2-RAsh[b + TT]    +  RAsh[b + TT]
  Bi-RAsh[b + TT]    = Bi-RAsh[b + TT]    +  RAsh[b + TT]
  p-RAsh[b + TT]    = p-RAsh[b + TT]    +  RAsh[b + TT]
  o-RAsh[b + TT]    = o-RAsh[b + TT]    +  RAsh[b + TT]
  B1-KAssa[b + TT]    = B1-KAssa[b + TT]    +  KAssa[b + TT]
  B2-kassa[b + TT]    = B2-kassa[b + TT]    +  kassa[b + TT]
  Bi-kassa[b + TT]     = Bi-kassa[b + TT]     +  kassa[b + TT]
  p-kassa[b + TT]      = p-kassa[b + TT]      +  kassa[b + TT]
  o-kassa[b + TT]      = o-kassa[b + TT]      +  kassa[b + TT]
  B1-Inv[b + TT]    = B1-Inv[b + TT]    +  Inv[b + TT]
  B2-Inv[b + TT]    = B2-Inv[b + TT]    +  Inv[b + TT]
  Bi-Inv[b + TT]    = Bi-Inv[b + TT]    +  Inv[b + TT]
  p-Inv[b + TT]    = p-Inv[b + TT]    +  Inv[b + TT]
  o-Inv[b + TT]    = o-Inv[b + TT]    +  Inv[b + TT]
  B1-spis[b + TT]    = B1-spis[b + TT]    +  spis[b + TT]
  B2-spis[b + TT]    = B2-spis[b + TT]    +  spis[b + TT]
  Bi-spis[b + TT]    = Bi-spis[b + TT]    +  spis[b + TT]
   p-spis[b + TT]    =  p-spis[b + TT]    +  spis[b + TT]
   o-spis[b + TT]    =  o-spis[b + TT]    +  spis[b + TT]
  B1-vzvr[b + TT]    = B1-vzvr[b + TT]    + vzvr[b + TT]
  B2-vzvr[b + TT]    = B2-vzvr[b + TT]    + vzvr[b + TT]
  Bi-vzvr[b + TT]    = Bi-vzvr[b + TT]    + vzvr[b + TT]
  p-vzvr[b + TT]    = p-vzvr[b + TT]    + vzvr[b + TT]
  o-vzvr[b + TT]    = o-vzvr[b + TT]    + vzvr[b + TT]
  B1-vzvr-post[b + TT]    = B1-vzvr-post[b + TT]    + vzvr-post[b + TT]
  B2-vzvr-post[b + TT]    = B2-vzvr-post[b + TT]    + vzvr-post[b + TT]
  Bi-vzvr-post[b + TT]    = Bi-vzvr-post[b + TT]    + vzvr-post[b + TT]
  p-vzvr-post[b + TT]    = p-vzvr-post[b + TT]    + vzvr-post[b + TT]
  o-vzvr-post[b + TT]    = o-vzvr-post[b + TT]    + vzvr-post[b + TT]
  B1-ostatok-start[b + TT]    = B1-ostatok-start[b + TT]    + ostatok-start[b + TT]
  B2-ostatok-start[b + TT]    = B2-ostatok-start[b + TT]    + ostatok-start[b + TT]
  Bi-ostatok-start[b + TT]    = Bi-ostatok-start[b + TT]    + ostatok-start[b + TT]
  p-ostatok-start[b + TT]    = p-ostatok-start[b + TT]    + ostatok-start[b + TT]
  o-ostatok-start[b + TT]    = o-ostatok-start[b + TT]    + ostatok-start[b + TT]
  B1-ostatok-end[b + TT]    = B1-ostatok-end[b + TT]    + ostatok-end[b + TT]
  B2-ostatok-end[b + TT]    = B2-ostatok-end[b + TT]    + ostatok-end[b + TT]
  Bi-ostatok-end[b + TT]    = Bi-ostatok-end[b + TT]    + ostatok-end[b + TT]
  p-ostatok-end[b + TT]    = p-ostatok-end[b + TT]    + ostatok-end[b + TT]
  o-ostatok-end[b + TT]    = o-ostatok-end[b + TT]    + ostatok-end[b + TT]
.
End.
END PROCEDURE.
PROCEDURE U-LINE :
UNDERLINE stream OutStream  sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13
        gds-zap-b-code
        gds-zap-artic
        gds-zap-gds-name
        gds-zap-unit-base
        gds-type
        F-ostatok-start
        F-Prih
        F-Rash
        F-KAssa
        F-Inv
        F-spis
        F-vzvr
        F-vzvr-post
        F-ostatok-end
        with FRAME ZAPAS .
        DOWN stream   OutStream 1 with FRAME ZAPAS.
        END PROCEDURE.
procedure display-part :
 do
 on error undo, return error return-value
 :
 define variable t-str as character no-undo .
 define variable t-str-tp as character no-undo .
 run get-name-from-ext-type in this-procedure  (
      input  temp_oborot_parts.ext-doc-type ,
      input  false                          ,
      output t-str                          )
      .
 t-str-tp  = entry (lookup (string(temp_oborot_parts.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U) .
   DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
    string(temp_oborot_parts.fact-date,"99/99/99")  @ gds-zap-b-code
    string(temp_oborot_parts.in-code  + if temp_oborot_parts.part-code <> ""  then ( "/" + temp_oborot_parts.part-code) else " ")  @ gds-zap-artic
    temp_oborot_parts.out-code + " " + t-str  @ gds-zap-gds-name
    "---"      @ gds-zap-unit-base
    t-str-tp   @ gds-type
    string(temp_oborot_parts.fact-qnty,"->>>>>>>>9.99") @ F-ostatok-start
    string(temp_oborot_parts.obj-code) +  " " + temp_oborot_parts.obj-type @ F-prih
    with FRAME ZAPAS .
    DOWN stream OutStream 1 with FRAME ZAPAS.
  if Make-Excel then  put   stream ForExcel unformatted
    "от " + string(temp_oborot_parts.fact-date,"99.99.99")  CHR(9)
    string(temp_oborot_parts.in-code  + if temp_oborot_parts.part-code <> ""  then ( "/" + temp_oborot_parts.part-code) else " ")  CHR(9)
    temp_oborot_parts.out-code + " " + t-str                                                                                       CHR(9)
    t-str-tp   CHR(9)
    string(temp_oborot_parts.fact-qnty,"->>>>>>>>9.99") CHR(9)
    string(temp_oborot_parts.obj-code) +  " " + temp_oborot_parts.obj-type  CHR(9)
   chr(10).
 end.
end procedure.
procedure ob-line2 :
 do
 on error undo, return error return-value
 :
define input parameter  x-artic     as character no-undo .
define input parameter  x-prod-code as integer no-undo .
define input parameter  x-prod-type as character no-undo .
define input parameter  p-date-1 as date no-undo .
define input parameter  p-date-2  as date no-undo .
define output parameter proc-oborot  as decimal no-undo .
define output parameter proc-oborot-2 as decimal no-undo .
proc-oborot   = 0 .
proc-oborot-2 = 0 .
define buffer buf-2_temp_oborot_parts for temp_oborot_parts-2.
define buffer buf_parts2 for parts.
for each buf-2_temp_oborot_parts : delete buf-2_temp_oborot_parts. end.
  for each obj-list :
    for each buf_parts2 no-lock where
        buf_parts2.host-code = v-cntxt-host-code-obj        and
        buf_parts2.obj-code  = obj-list.obj-code  and
        buf_parts2.obj-type  = obj-list.obj-type  and
        buf_parts2.supp-type = g#post-f.obj-type  and
        buf_parts2.supp-code = g#post-f.obj-code  and
        buf_parts2.status_   = true               and
        buf_parts2.artic        = x-artic         and
        buf_parts2.prod-code    = x-prod-code     and
        buf_parts2.prod-type    = x-prod-type     and
        buf_parts2.fact-date >= p-date-1          and
        buf_parts2.fact-date <= p-date-2
    :
        find first trn-doc no-lock where trn-doc.doc-code     = buf_parts2.out-code   no-error .
            if not available trn-doc then next.
        create buf-2_temp_oborot_parts.
        BUFFER-COPY buf_parts2  to buf-2_temp_oborot_parts
            assign
              buf-2_temp_oborot_parts.ext-doc-type = trn-doc.ext-doc-type.
     end.
     end.
     FOR each buf-2_temp_oborot_parts no-lock :
        if type-stor <> 1 then do:
           if buf-2_temp_oborot_parts.purch-code <>  type-stor - 1 then next.
        end.
        CASE buf-2_temp_oborot_parts.ext-doc-type:
             WHEN        'iv':U      OR
             WHEN        'rv':U  OR
             WHEN        'im':U     THEN     DO:
           ASSIGN proc-oborot   = proc-oborot  +  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .
                 End.
             WHEN        'vt':U       or
             WHEN        'ie':U or
             WHEN        'vp':U  THEN     DO:
           ASSIGN proc-oborot   = proc-oborot   +  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .
                 End.
             WHEN        're':U  THEN DO:
           ASSIGN proc-oborot   = proc-oborot  +  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .
                 End.
             WHEN       'ep':U  THEN DO:
           ASSIGN proc-oborot   = proc-oborot  -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base) .
                 End.
             WHEN       'ee':U          THEN  DO:
             ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                    .
                 End.
             WHEN       'ev':U       OR
             WHEN       'em':U        THEN  DO:
           ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .
                 End.
             WHEN       'es':U  then
                     ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                            proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                            .
             WHEN       'rs':U THEN
                      ASSIGN proc-oborot   = proc-oborot   +  buf-2_temp_oborot_parts.fact-qnty
                             proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                             .
             WHEN       'we':U       THEN  DO:
           ASSIGN proc-oborot  = proc-oborot  -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  -  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .
                 End.
             WHEN       'wm':U       THEN  DO:
           ASSIGN proc-oborot   = proc-oborot   -  buf-2_temp_oborot_parts.fact-qnty
                  proc-oborot-2   = proc-oborot-2  - buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .
                 End.
             WHEN       'pc':U       THEN  DO:
             if type-stor <> 1 then do:
                 ASSIGN proc-oborot  = proc-oborot  +  buf-2_temp_oborot_parts.fact-qnty
                        proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .
                 End.
              end.
             WHEN       'ap':U       THEN  DO:
                 ASSIGN
                   proc-oborot-2   = proc-oborot-2  +  buf-2_temp_oborot_parts.fact-qnty  * (if tprintrubl  = true then buf-2_temp_oborot_parts.price-rubl else buf-2_temp_oborot_parts.price-base)
                  .
              end.
          End CASE.
   End.
 end.
end procedure.
procedure dobor :
 do
 on error undo, return error return-value
 :
 define buffer buf1_parts for parts.
 for each obj-list :
    for each buf1_parts no-lock where
        buf1_parts.host-code = v-cntxt-host-code-obj         and
        buf1_parts.supp-type = g#post-f.obj-type     and
        buf1_parts.supp-code = g#post-f.obj-code     and
        buf1_parts.status_   =  false              and
        buf1_parts.obj-type  =  obj-list.obj-type  and
        buf1_parts.obj-code  =  obj-list.obj-code  and
        buf1_parts.in-code   <> buf1_parts.out-code and
        buf1_parts.rsrv-free = true    :
        if type-stor <> 1 then do:
           if buf1_parts.purch-code <>  type-stor - 1 then next.
        end.
        if not can-find ( first temp-t-post-stk-line where
                                  temp-t-post-stk-line.artic     = buf1_parts.artic     and
                                  temp-t-post-stk-line.prod-type = buf1_parts.prod-type and
                                  temp-t-post-stk-line.prod-code = buf1_parts.prod-code
                                  ) and
             not can-find ( first temp-null where
                                  temp-null.artic     = buf1_parts.artic     and
                                  temp-null.prod-type = buf1_parts.prod-type and
                                  temp-null.prod-code = buf1_parts.prod-code
                                  )
                   then do:
                      find first goods no-lock where goods.artic    = buf1_parts.artic     and
                                                    goods.prod-type = buf1_parts.prod-type and
                                                    goods.prod-code = buf1_parts.prod-code no-error .
                      if not available goods then next.
                      create temp-null.
                      assign
                        temp-null.artic     = buf1_parts.artic
                        temp-null.prod-type = buf1_parts.prod-type
                        temp-null.prod-code = buf1_parts.prod-code
                        temp-null.gds-name  = goods.gds-name
                        temp-null.unit-base = goods.unit-base
                        temp-null.prt-root  = 0
                        temp-null.Goods-grp-name   = goods.grp-name
                        temp-null.gds-code         = goods.gds-code
                        temp-null.gds-type         = goods.gds-type
                        temp-null.Cli-type         = g#post-f.obj-type
                        temp-null.Cli-code         = g#post-f.obj-code
                        temp-null.Clients-grp-name = g#post-f.obj-name
                      .
                     end.
    end.
end.
run super-dobor in this-procedure .
for each temp-null :
   run clear-item in this-procedure .
   run ost-line in this-procedure  (
   temp-null.artic    ,
   temp-null.prod-code,
   temp-null.prod-type  )  .
   run calc-sub-itog (0).
   run calc-sub-itog (6).
      if x-type-itog <> 1 then do:
        gds-post-artic =  temp-null.artic .
        if Show-Negativ = true then do:
              gds-post-artic = "".
              find first ub.ext-artic no-lock where
                      ub.ext-artic.gds-code = temp-null.gds-code and
                      ub.ext-artic.cli-type = temp-null.Cli-type and
                      ub.ext-artic.cli-code = temp-null.Cli-code and
                      ub.ext-artic.status_   =  'тек':U no-error .
              if available ub.ext-artic then do:
                    assign
                      gds-post-artic     = ub.ext-artic.ext-artic
                    .
        end.
         run di-qnty ("кол-во", 1, temp-null.gds-code,gds-post-artic,temp-null.gds-name,temp-null.unit-base,"").
         if show-cost then do : run di ( "учет." , 2, "","","","","" ).  end.
         if xshowgoods then do : run di ( "в пути" , 7, "","","","","" ).  end.
        end.
      end.
  run clear-item in this-procedure .
end.
 end.
end procedure.
procedure goods-way :
 do
 on error undo, return error return-value
 :
define input  parameter x-artic          like goods.artic        no-undo.
define input  parameter x-prod-code      like goods.prod-code    no-undo.
define input  parameter x-prod-type      like goods.prod-type    no-undo.
define input parameter x-date as integer no-undo .
define output parameter x-qnty as decimal no-undo .
define buffer way_parts for parts.
define buffer way_trn-doc for trn-doc.
define buffer way_doc-line for doc-line.
x-qnty = 0 .
if x-date = 1 then do:
      for each obj-list :
            for each way_doc-line no-lock where
                      way_doc-line.obj-type   = obj-list.obj-type       and
                      way_doc-line.obj-code   = obj-list.obj-code       and
                      way_doc-line.prod-type  = x-prod-type             and
                      way_doc-line.prod-code  = x-prod-code             and
                      way_doc-line.artic       = x-artic                and
                      way_doc-line.ext-doc-type  = 'iv':U   and
                      way_doc-line.status_     = 'факт':U                and
                      way_doc-line.fact-order  > fact-order-1
                      :
                      if can-find (first way_trn-doc no-lock  where
                              way_trn-doc.doc-code  = way_doc-line.doc-code and
                              way_trn-doc.fact-date > way_trn-doc.doc-date  and
                              way_trn-doc.doc-date  < x-date-start )
                              then do:
                                for each way_parts no-lock where
                                      way_parts.out-code = way_doc-line.doc-code   and
                                      way_parts.supp-type = g#post-f.obj-type   and
                                      way_parts.supp-code = g#post-f.obj-code   and
                                      way_parts.obj-type = way_doc-line.obj-type   and
                                      way_parts.obj-code = way_doc-line.obj-code   and
                                      way_parts.prod-type  = way_doc-line.prod-type   and
                                      way_parts.prod-code  = way_doc-line.prod-code   and
                                      way_parts.artic      = way_doc-line.artic     and
                                      way_parts.status_    = true
                                      :
                                      x-qnty = x-qnty + way_parts.fact-qnty.
                                end.
                      end.
            end.
            for each way_doc-line no-lock where
                way_doc-line.obj-type   = obj-list.obj-type                and
                way_doc-line.obj-code   = obj-list.obj-code                and
                way_doc-line.prod-type  = x-prod-type                      and
                way_doc-line.prod-code  = x-prod-code                      and
                way_doc-line.artic       = x-artic                         and
                way_doc-line.ext-doc-type  = 'rv':U        and
                way_doc-line.status_     = 'факт':U                         and
                way_doc-line.fact-order  > fact-order-1
                :
                if can-find (first way_trn-doc no-lock  where
                      way_trn-doc.doc-code  = way_doc-line.doc-code and
                      way_trn-doc.fact-date >= way_trn-doc.doc-date  and
                      way_trn-doc.doc-date  < x-date-start
                      ) then do:
                          for each way_parts no-lock where
                              way_parts.out-code = way_doc-line.doc-code   and
                              way_parts.supp-type = g#post-f.obj-type   and
                              way_parts.supp-code = g#post-f.obj-code   and
                              way_parts.obj-type = way_doc-line.obj-type   and
                              way_parts.obj-code = way_doc-line.obj-code   and
                              way_parts.prod-type  = way_doc-line.prod-type   and
                              way_parts.prod-code  = way_doc-line.prod-code   and
                              way_parts.artic      = way_doc-line.artic     and
                              way_parts.status_    = true
                              :
                              x-qnty = x-qnty - way_parts.fact-qnty.
                          end.
                      end.
            end.
            for each way_trn-doc no-lock  where
                    (way_trn-doc.host-code = v-cntxt-host-code-obj     and
                    way_trn-doc.status_ = 'накл':U            and
                    way_trn-doc.fact-order = 0               and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = 'при':U         and
                    way_trn-doc.doc-date  < x-date-start     and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = 'iv':U)
                      or
                    (way_trn-doc.host-code = v-cntxt-host-code-obj      and
                    way_trn-doc.status_ = 'накл':U            and
                    way_trn-doc.fact-order = 0               and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = 'возврат':U         and
                    way_trn-doc.doc-date  < x-date-start     and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = 'rv':U )
                    :
                      if can-find ( first  way_doc-line no-lock where
                          way_doc-line.doc-code   = way_trn-doc.doc-code   and
                          way_doc-line.prod-type  = x-prod-type            and
                          way_doc-line.prod-code  = x-prod-code            and
                          way_doc-line.artic       = x-artic ) then do:
                            for each way_parts no-lock where
                                      way_parts.out-code   = way_trn-doc.doc-code   and
                                      way_parts.supp-type  = g#post-f.obj-type   and
                                      way_parts.supp-code  = g#post-f.obj-code   and
                                      way_parts.obj-type   = way_trn-doc.obj-type   and
                                      way_parts.obj-code   = way_trn-doc.obj-code   and
                                      way_parts.prod-type  = x-prod-type   and
                                      way_parts.prod-code  = x-prod-code   and
                                      way_parts.artic      = x-artic     and
                                      way_parts.status_    = false
                                      :
                                      if way_trn-doc.ext-doc-type  = 'iv':U then
                                          x-qnty = x-qnty + way_parts.fact-qnty.
                                      else
                                          x-qnty = x-qnty - way_parts.fact-qnty.
                                      end.
                            end.
                      end.
      end.
end.
else do:
   if x-date-end < today then do:
      for each obj-list :
            for each way_trn-doc no-lock  where
                    (way_trn-doc.host-code = v-cntxt-host-code-obj     and
                    way_trn-doc.status_ = 'факт':U            and
                    way_trn-doc.fact-order > fact-order-2    and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = 'при':U         and
                    way_trn-doc.doc-date  <= x-date-end      and
                    way_trn-doc.fact-date  > x-date-end      and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = 'iv':U)
                      or
                    (way_trn-doc.host-code = v-cntxt-host-code-obj      and
                    way_trn-doc.status_ = 'факт':U            and
                    way_trn-doc.fact-order > fact-order-2    and
                    way_trn-doc.internal = true              and
                    way_trn-doc.doc-type = 'возврат':U         and
                    way_trn-doc.doc-date  <= x-date-end      and
                    way_trn-doc.fact-date  > x-date-end      and
                    way_trn-doc.obj-type = obj-list.obj-type and
                    way_trn-doc.obj-code = obj-list.obj-code and
                    way_trn-doc.ext-doc-type  = 'rv':U )
                    :
                    if can-find( first  way_doc-line no-lock where
                        way_doc-line.doc-code   = way_trn-doc.doc-code   and
                        way_doc-line.prod-type  = x-prod-type            and
                        way_doc-line.prod-code  = x-prod-code            and
                        way_doc-line.artic       = x-artic  )
                        then do:
                          for each way_parts no-lock where
                                    way_parts.out-code   = way_trn-doc.doc-code   and
                                    way_parts.supp-type  = g#post-f.obj-type   and
                                    way_parts.supp-code  = g#post-f.obj-code   and
                                    way_parts.obj-type   = obj-list.obj-type   and
                                    way_parts.obj-code   = obj-list.obj-code   and
                                    way_parts.prod-type  = x-prod-type   and
                                    way_parts.prod-code  = x-prod-code   and
                                    way_parts.artic      = x-artic     and
                                    way_parts.status_    = true
                                    :
                                    if way_trn-doc.ext-doc-type  = 'iv':U then
                                        x-qnty = x-qnty + way_parts.fact-qnty.
                                    else
                                        x-qnty = x-qnty - way_parts.fact-qnty.
                                    end.
                          end.
                    end.
      end.
   end.
   if x-date-end <= today then do:
      for each obj-list :
            for each way_trn-doc no-lock  where
                      (way_trn-doc.host-code = v-cntxt-host-code-obj     and
                      way_trn-doc.status_ = 'накл':U            and
                      way_trn-doc.fact-order = 0               and
                      way_trn-doc.internal = true              and
                      way_trn-doc.doc-type = 'при':U         and
                      way_trn-doc.doc-date  <= x-date-end       and
                      way_trn-doc.obj-type = obj-list.obj-type and
                      way_trn-doc.obj-code = obj-list.obj-code and
                      way_trn-doc.ext-doc-type  = 'iv':U)
                        or
                      (way_trn-doc.host-code = v-cntxt-host-code-obj      and
                      way_trn-doc.status_ = 'накл':U            and
                      way_trn-doc.fact-order = 0               and
                      way_trn-doc.internal = true              and
                      way_trn-doc.doc-type = 'возврат':U         and
                      way_trn-doc.doc-date  <= x-date-end       and
                      way_trn-doc.obj-type = obj-list.obj-type and
                      way_trn-doc.obj-code = obj-list.obj-code and
                      way_trn-doc.ext-doc-type  = 'rv':U )
                      :
                        if can-find (first  way_doc-line no-lock where
                            way_doc-line.doc-code   = way_trn-doc.doc-code   and
                            way_doc-line.prod-type  = x-prod-type            and
                            way_doc-line.prod-code  = x-prod-code            and
                            way_doc-line.artic       = x-artic ) then do:
                              for each way_parts no-lock where
                                        way_parts.out-code   = way_trn-doc.doc-code   and
                                        way_parts.supp-type  = g#post-f.obj-type   and
                                        way_parts.supp-code  = g#post-f.obj-code   and
                                        way_parts.obj-type   = obj-list.obj-type   and
                                        way_parts.obj-code   = obj-list.obj-code   and
                                        way_parts.prod-type  = x-prod-type   and
                                        way_parts.prod-code  = x-prod-code   and
                                        way_parts.artic      = x-artic     and
                                        way_parts.status_    = false
                                        :
                                        if way_trn-doc.ext-doc-type  = 'iv':U then
                                            x-qnty = x-qnty + way_parts.fact-qnty.
                                        else
                                            x-qnty = x-qnty - way_parts.fact-qnty.
                                        end.
                              end.
                        end.
      end.
    end.
end.
 end.
end procedure.
procedure clear-tt :
 do
 on error undo, return error return-value
 :
  for each temp-t-post-stk-line :
      delete  temp-t-post-stk-line.
  end.
  for each temp_oborot_parts :
      delete temp_oborot_parts.
  end.
  for each temp_oborot_parts-2 :
      delete temp_oborot_parts-2.
  end.
  for each temp-null :
      delete temp-null.
  end.
 end.
end procedure.
procedure first-line-p :
 do
 on error undo, return error return-value
 :
    if x-type-itog = 3  and p-first = true  then DO:
      DISPLAY stream  OutStream sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym11 sym12 sym13
        "Дата"          @ gds-zap-b-code
        "Номер партии"  @ gds-zap-artic
          "Документ"     @ gds-zap-gds-name
          " "            @ gds-zap-unit-base
        "Тип пр"        @ gds-type
        "Кол-во партии" @ F-ostatok-start
        "Объект"        @ F-prih
        with FRAME ZAPAS .
        DOWN stream OutStream 1 with FRAME ZAPAS.
        run u-line in this-procedure .
        p-first = false  .
    end.
 end.
end procedure.
procedure run1 :
 do
 on error undo, return error return-value
 :
  run clear-itemp-  in this-procedure .
    if x-type-itog = 1 then do:
      for each temp-t-post-stk-line :
            run ob-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .
            run ost-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .
            run calc-sub-itog in this-procedure  (0).
            run calc-sub-itog in this-procedure  (6).
            run clear-item in this-procedure .
      end.
      run dobor in this-procedure .
    end.
  if x-type-itog <> 1 then DO:
    if can-find ( first temp-t-post-stk-line ) then do:
           run first-line-p in this-procedure .
           run print-header in this-procedure ( 3 , g#post-f.obj-name) .
     end.
      for each temp-t-post-stk-line :
          run display-line in this-procedure .
              if x-type-itog = 3 then do :
                  for each temp_oborot_parts where
                      temp_oborot_parts.artic     = temp-t-post-stk-line.artic      and
                      temp_oborot_parts.prod-type = temp-t-post-stk-line.prod-type  and
                      temp_oborot_parts.prod-code = temp-t-post-stk-line.prod-code
                  :
                      run display-part in this-procedure .
                  end.
              end.
      end.
      run dobor in this-procedure .
  end.
  run print-footer in this-procedure ( 3 , g#post-f.obj-name ).
  run clear-tt in this-procedure .
 end.
end procedure.
procedure run2 :
 do
 on error undo, return error return-value
 :
define variable ng as character no-undo .
define variable v-new as character no-undo .
define variable v-old as character no-undo .
define variable ff as logical   no-undo .
v-old = "" .
ff = true .
  if  xLavel > 0 then  do:
      for each g#post-f
               break by g#post-f.grp-name
               :
        ng = n-lavel (g#post-f.grp-name ,  xLavel )  .
        v-new = n-lavel (g#post-f.grp-name ,  xLavel )  .
        if v-new <> v-old and ff = true   then do:
          run print-header ( 1 , ng ).
          ff = false .
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if v-new <> v-old and ff = false then do:
            run print-footer in this-procedure ( 1 , ng ).
            run clear-itemb1-  in this-procedure .
            ff = true .
        end.
        v-old = n-lavel (g#post-f.grp-name,xLavel ).
      end.
  end.
  else do:
      for each g#post-f break by g#post-f.grp-name :
        if first-of(g#post-f.grp-name) then do:
           run print-header in this-procedure ( 1 , g#post-f.grp-name ).
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if last-of(g#post-f.grp-name) then do:
           run print-footer in this-procedure ( 1 , g#post-f.grp-name ).
           run clear-itemb1-  in this-procedure .
        end.
      end.
  end.
 end.
end procedure.
procedure run3 :
do
on error undo, return error return-value
:
define variable ng as character no-undo .
define variable v-new as character no-undo .
define variable v-old as character no-undo .
define variable ff as logical   no-undo .
v-old = "" .
ff = true .
  if  xLavel > 0 then  do:
      for each g#post-f break by g#post-f.grp-name  :
        v-new = n-lavel (g#post-f.grp-name ,  xLavel )  .
        ng = n-lavel (g#post-f.grp-name ,  xLavel )  .
        if v-new <> v-old and ff = true then do:
           run Print-Header  in this-procedure ( 1 , ng ).
           ff = false .
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if v-new <> v-old and ff = false  then do:
            run print-footer in this-procedure ( 1 , ng ).
            run clear-itemb1- in this-procedure .
            ff = true .
        end.
        v-old = n-lavel (g#post-f.grp-name ,  xLavel )  .
      end.
  end.
  else do:
      for each g#post-f break by g#post-f.grp-name :
        if first-of(g#post-f.grp-name) then do:
           run print-header in this-procedure  ( 1 , g#post-f.grp-name ).
        end.
        run one-post in this-procedure .
        run run1 in this-procedure .
        if last-of(g#post-f.grp-name) then do:
           run print-footer in this-procedure ( 1 , g#post-f.grp-name ).
           run clear-itemb1-  in this-procedure .
        end.
      end.
  end.
 end.
end procedure.
procedure run1-grp :
 do
 on error undo, return error return-value
 :
  run Clear-itemp-  in this-procedure .
    if x-type-itog = 1 then do:
      for each temp-t-post-stk-line :
            run ob-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .
            run ost-line in this-procedure
                  ( INPUT temp-t-post-stk-line.artic     ,
                    INPUT temp-t-post-stk-line.prod-code ,
                    INPUT temp-t-post-stk-line.prod-type  ) .
            run Calc-Sub-itog  in this-procedure (0).
            run Calc-Sub-itog  in this-procedure (6).
            run Clear-item in this-procedure .
      end.
      run dobor in this-procedure .
    end.
  if x-type-itog <> 1 then DO:
    if can-find ( first temp-t-post-stk-line ) then do:
           run first-line-p in this-procedure .
           Run Print-Header in this-procedure ( 3 , g#post-f.obj-name) .
     end.
      for each temp-t-post-stk-line :
          run display-line in this-procedure .
              if x-type-itog = 3 then do :
                  for each temp_oborot_parts where
                      temp_oborot_parts.artic     = temp-t-post-stk-line.artic      and
                      temp_oborot_parts.prod-type = temp-t-post-stk-line.prod-type  and
                      temp_oborot_parts.prod-code = temp-t-post-stk-line.prod-code
                  :
                      run display-part in this-procedure .
                  end.
              end.
      end.
      run dobor in this-procedure .
  end.
  run print-footer in this-procedure ( 3 , g#post-f.obj-name ).
  run clear-tt in this-procedure .
 end.
end procedure.
procedure super-dobor :
 do
 on error undo, return error return-value
 :
 define buffer buf1_parts for parts.
 if x-date-end >= today then return.
  for each obj-list :
    for each buf1_parts no-lock where
        buf1_parts.host-code = v-cntxt-host-code-obj         and
        buf1_parts.supp-type = g#post-f.obj-type   and
        buf1_parts.supp-code = g#post-f.obj-code   and
        buf1_parts.status_   =  true               and
        buf1_parts.obj-type  =  obj-list.obj-type  and
        buf1_parts.obj-code  =  obj-list.obj-code  and
        buf1_parts.fact-date >= x-date-start      :
        if type-stor <> 1 then do:
           if buf1_parts.purch-code <>  type-stor - 1 then next.
        end.
        if not can-find ( first temp-t-post-stk-line where
                                  temp-t-post-stk-line.artic     = buf1_parts.artic     and
                                  temp-t-post-stk-line.prod-type = buf1_parts.prod-type and
                                  temp-t-post-stk-line.prod-code = buf1_parts.prod-code
                                  ) and
             not can-find ( first temp-null where
                                  temp-null.artic     = buf1_parts.artic     and
                                  temp-null.prod-type = buf1_parts.prod-type and
                                  temp-null.prod-code = buf1_parts.prod-code
                                  )
                   then do:
                      find first goods no-lock where goods.artic    = buf1_parts.artic     and
                                                    goods.prod-type = buf1_parts.prod-type and
                                                    goods.prod-code = buf1_parts.prod-code no-error .
                      if not available goods then next.
                      create temp-null.
                      assign
                        temp-null.artic     = buf1_parts.artic
                        temp-null.prod-type = buf1_parts.prod-type
                        temp-null.prod-code = buf1_parts.prod-code
                        temp-null.gds-name  = goods.gds-name
                        temp-null.unit-base = goods.unit-base
                        temp-null.prt-root  = 0
                        temp-null.Goods-grp-name   = goods.grp-name
                        temp-null.gds-code         = goods.gds-code
                        temp-null.gds-type         = goods.gds-type
                        temp-null.Cli-type         = g#post-f.obj-type
                        temp-null.Cli-code         = g#post-f.obj-code
                        temp-null.Clients-grp-name = g#post-f.obj-name
                      .
                     end.
    end.
  end.
 end.
end procedure.
