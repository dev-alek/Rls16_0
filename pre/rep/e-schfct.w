CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Журнал регистрации полученных счетов фактур" .
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "X(65)" no-undo
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable g#report-num as integer   no-undo .
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
 define stream macr_excel .
 define variable v-file-name as character no-undo .
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
      put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) skip  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .
 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 assign
   ss = string( Round( p-val, p-typ) )
 .
 put  stream macr_excel unformatted
      substitute('formula(&3,"r&1c&2")', p-row , p-col , ss ) skip  .
 end.
END procedure.
procedure macr_excel_date :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("dd/mm/yy")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val ) + chr(10)  .
 end.
end procedure.
procedure macr_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) skip .
 end.
end procedure.
procedure macr_cell_bordur :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  put  stream macr_excel unformatted
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  skip
       'ALIGNMENT(3 , , 4 , 4 ,)'   skip
       .
 end.
end procedure.
procedure macr_cell_merge :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
 do
 on error undo, return error return-value
 :
  if p-row-2 = ?
  then do:
    assign
      p-row-2 = p-row
    .
  end.
  if p-col-2 = ?
  then do:
    assign
      p-col-2 = p-col
    .
  end.
  put stream macr_excel unformatted
    substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) chr(10)
    'border(1,1,1,1,1,,0,0,0,0,0)':u chr(10)
    'alignment(7,true,2,4)':u chr(10)
    .
 end.
end procedure.
procedure macr_cell_size :
 do
 on error undo, return error return-value
 :
 define input parameter  p-w   as integer   no-undo .
 define input parameter  p-l   as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  if p-w = ? then    p-w = 0 .
  if p-l = ? then    p-l = 0 .
 define variable s-w as character no-undo .
 define variable s-l as character no-undo .
 if p-w = 0 then s-w = "" .
            else s-w = string(p-w)  .
 if p-l = 0 then s-l = "" .
            else s-l = string(p-l)  .
put  stream macr_excel unformatted
     substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 )  skip .
put  stream macr_excel unformatted
     substitute('COLUMN.WIDTH(&1,,,,)' , s-w  )  skip.
put  stream macr_excel unformatted
     'FORMAT.TEXT(2,2,0,,,,,)'  skip.
 end.
end procedure.
procedure end-proc :
 do
 on error undo, return error return-value
 :
  v-file-name = ( string( session:temp-directory + "rpt" + string( g#report-num ) ) + ".t-t").
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.
 end.
end procedure.
define new shared temp-table tt-title no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-code is   primary unique purch-code
.
define new shared temp-table d-supp no-undo
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp       is   primary unique supp-type supp-code purch-code
  index i2                                                 purch-code
.
define new shared temp-table d-supp-grp no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field purch-code like ub.parts.purch-code
  field grp-code   like ub.goods.grp-code
  field purch-name as   character
  field supp-name  like ub.clients.obj-name
  field grp-name   like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp       is   primary unique supp-type supp-code purch-code grp-code
  index i2                                                 purch-code
.
define new shared temp-table d-slt-vat no-undo
  field vat-pc  like ub.doc-line.vat-pc
  field slt-pc  like ub.doc-line.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define new shared temp-table d-slt-vat-cons no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define new shared temp-table d-slt-vat-cons-grp no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define new shared temp-table d-supp-slts-vats-cons no-undo
  field supp-type  like ub.parts.supp-type
  field supp-code  like ub.parts.supp-code
  field supp-name  like ub.clients.obj-name
  field vat-pc     like ub.parts.vat-pc
  field slt-pc     like ub.parts.slt-pc
  field purch-code like ub.parts.purch-code
  field purch-name as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index pi         is   primary   unique supp-type supp-code vat-pc slt-pc purch-code
.
define new shared temp-table d-slts-vats no-undo
  field vat-pc  like ub.parts.vat-pc
  field slt-pc  like ub.parts.slt-pc
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt is   primary unique vat-pc slt-pc
.
define new shared temp-table d-slts-vats-cons no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code
.
define new shared temp-table d-slts-vats-cons-grp no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary   unique vat-pc slt-pc purch-code grp-code
.
define new shared temp-table tt-title-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index purch-findoc  is   primary unique contract-code purch-code
.
define new shared temp-table d-supp-fin no-undo
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp          is   primary unique contract-code supp-type supp-code purch-code
  index i2                                purch-code
.
define new shared temp-table d-supp-grp-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field supp-name     like ub.clients.obj-name
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index supp          is   primary unique contract-code supp-type supp-code purch-code grp-code
  index i2                                purch-code
.
define new shared temp-table d-slt-vat-cons-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define new shared temp-table d-slt-vat-cons-grp-fin no-undo
  field vat-pc        like ub.doc-line.vat-pc
  field slt-pc        like ub.doc-line.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field grp-code      like ub.goods.grp-code
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.
define new shared temp-table d-supp-slts-vats-cons-fin no-undo
  field supp-type     like ub.parts.supp-type
  field supp-code     like ub.parts.supp-code
  field supp-name     like ub.clients.obj-name
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index pi            is   primary unique contract-code supp-type supp-code vat-pc slt-pc purch-code
.
define new shared temp-table d-slts-vats-cons-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field purch-name    as   character
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code
.
define new shared temp-table d-slts-vats-cons-grp-fin no-undo
  field vat-pc        like ub.parts.vat-pc
  field slt-pc        like ub.parts.slt-pc
  field purch-code    like ub.parts.purch-code
  field grp-code      like ub.goods.grp-code
  field purch-name    as   character
  field grp-name      like ub.gds-grp.node-name
  field contract-code like ub.fin-doc.contract-code
  field fact-qnty           like ub.doc-line.price-rubl                        field acc-base            like ub.doc-line.price-rubl                        field acc-rubl            like ub.doc-line.price-rubl                        field acc-vat-base        like ub.doc-line.price-rubl                        field acc-vat-rubl        like ub.doc-line.price-rubl                        field acc-slt-base        like ub.doc-line.price-rubl                        field acc-slt-rubl        like ub.doc-line.price-rubl                        field acc-road-tax-base   like ub.doc-line.price-rubl                        field acc-road-tax-rubl   like ub.doc-line.price-rubl                        field acc-excise-base     like ub.doc-line.price-rubl                        field acc-excise-rubl     like ub.doc-line.price-rubl                        field acc-transport-base  like ub.doc-line.price-rubl                        field acc-transport-rubl  like ub.doc-line.price-rubl                        field acc-other-base      like ub.doc-line.price-rubl                        field acc-other-rubl      like ub.doc-line.price-rubl                        field pay-base            like ub.doc-line.price-rubl                        field pay-rubl            like ub.doc-line.price-rubl                        field no-vat-base         like ub.doc-line.price-rubl                        field no-vat-rubl         like ub.doc-line.price-rubl                        field vat-base            like ub.doc-line.price-rubl                        field vat-rubl            like ub.doc-line.price-rubl                        field vat-base-buyer      like ub.doc-line.price-rubl                        field vat-rubl-buyer      like ub.doc-line.price-rubl                        field slt-base            like ub.doc-line.price-rubl                        field slt-rubl            like ub.doc-line.price-rubl                        field road-tax            like ub.doc-line.price-rubl                        field excise              like ub.doc-line.price-rubl                        field sale-base           like ub.doc-line.price-rubl                        field sale-rubl           like ub.doc-line.price-rubl                        field sale-vat-base       like ub.doc-line.price-rubl                        field sale-vat-rubl       like ub.doc-line.price-rubl                        field sale-vat-buyer-base like ub.doc-line.price-rubl                        field sale-vat-buyer-rubl like ub.doc-line.price-rubl                        field sale-slt-base       like ub.doc-line.price-rubl                        field sale-slt-rubl       like ub.doc-line.price-rubl                        field sale-road-tax-base  like ub.doc-line.price-rubl                        field sale-road-tax-rubl  like ub.doc-line.price-rubl                        field sale-excise-base    like ub.doc-line.price-rubl                        field sale-excise-rubl    like ub.doc-line.price-rubl                        field ov-base             like ub.doc-line.price-rubl                        field ov-vat              like ub.doc-line.price-rubl
  index vat-slt-purch is   primary unique contract-code vat-pc slt-pc purch-code grp-code
.
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
DEFINE VARIABLE parParentProc AS WIDGET-HANDLE NO-UNDO.
ASSIGN
  parParentProc = my-handle
.
define temp-table temp-doc-list no-undo
  field doc-code    as character
  field supp-vat-pc as decimal
  field supp-slt-pc as decimal
  field fact-order  as decimal
  field scf-code    as character
  field scf-date    as date
  field supp-name   as character
  field inn         as character
  field no-vat-rubl as decimal
  field vat-rubl    as decimal
  field acc-rubl    as decimal
  index xpk is primary unique doc-code supp-vat-pc supp-slt-pc
  index xie1 fact-order doc-code supp-vat-pc supp-slt-pc
  .
DEFINE VARIABLE SelectDocument AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "1",
"Кроме межфирменных", "2",
"Межфирменные", "3"
     SIZE 42.63 BY 2.38
     FGCOLOR 0  NO-UNDO.
DEFINE RECTANGLE RECT-cashiers
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 44.5 BY 4.25.
DEFINE FRAME F-Main
     SelectDocument AT ROW 2.83 COL 2.38 NO-LABEL
     "Документы :" VIEW-AS TEXT
          SIZE 12 BY .92 AT ROW 1.5 COL 2
          FGCOLOR 4
     RECT-cashiers AT ROW 1.25 COL 1.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 56.88 BY 11.83.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
    ASSIGN adm-object-hdl = FRAME F-Main:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartObject~`':U +
     'FRAME~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Layout,Hide-on-Init~`':U +
     '~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE RECT-cashiers SelectDocument WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-cashiers SelectDocument WITH FRAME F-Main.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
        DEFINE VARIABLE parent-hdl AS HANDLE NO-UNDO.
        IF adm-object-hdl:TYPE = "WINDOW":U THEN
        DO:
          IF p-row = 0 THEN p-row =
            (SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2.
          IF p-col = 0 THEN p-col =
            (SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2.
        END.
        ELSE IF adm-object-hdl:TYPE = "DIALOG-BOX":U THEN
        DO:
          parent-hdl = adm-object-hdl:PARENT.
          IF p-row = 0 THEN p-row =
            ((SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2) -
              parent-hdl:ROW.
          IF p-col = 0 THEN p-col =
            ((SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2) -
              parent-hdl:COL.
        END.
        IF p-row GE 0 AND p-row < 1 THEN p-row = 1.
        IF p-col GE 0 AND p-col < 1 THEN p-col = 1.
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
RUN set-attribute-list ("CURRENT-PAGE=0,ADM-OBJECT-HANDLE=":U +
    STRING(adm-object-hdl)).
PAUSE 0 BEFORE-HIDE.
PROCEDURE adm-change-page :
  RUN broker-change-page IN adm-broker-hdl (INPUT THIS-PROCEDURE) NO-ERROR.
  END PROCEDURE.
PROCEDURE delete-page :
  DEFINE INPUT PARAMETER p-page# AS INTEGER NO-UNDO.
  RUN broker-delete-page IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-page#).
  END PROCEDURE.
PROCEDURE init-object :
  DEFINE INPUT PARAMETER  p-proc-name   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER  p-parent-hdl  AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER  p-attr-list   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-proc-hdl    AS HANDLE    NO-UNDO.
  RUN broker-init-object IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-proc-name, INPUT p-parent-hdl,
       INPUT p-attr-list, OUTPUT p-proc-hdl) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE init-pages :
  DEFINE INPUT PARAMETER p-page-list      AS CHARACTER NO-UNDO.
  RUN broker-init-pages IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page-list) NO-ERROR.
  END PROCEDURE.
PROCEDURE select-page :
  DEFINE INPUT PARAMETER p-page#     AS INTEGER   NO-UNDO.
  RUN broker-select-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#) NO-ERROR.
  END PROCEDURE.
PROCEDURE view-page :
  DEFINE INPUT PARAMETER p-page#      AS INTEGER   NO-UNDO.
  RUN broker-view-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#).
  END PROCEDURE.
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
run get-report-num in parParentProc
  (output g#report-num
  ).
PROCEDURE adm-create-objects :
END PROCEDURE.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
RUN notify IN THIS-PROCEDURE ('row-available':U).
END PROCEDURE.
PROCEDURE check-new-page :
  define input  parameter p-address-num-lines as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if line-counter ( PrnLibStream ) + p-address-num-lines > 42
    then do:
      page stream PrnLibStream .
      put stream PrnLibStream
        cur-time-print() at 5 format "x(35)"
        "Страница " at 100 page-number(PrnLibStream) at 115 format ">>>9" skip
        .
      put stream PrnLibStream
        '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
        ':       1        :       2        :    3     :                    4                     :        5        :        7        :  8   :     9           :       12        :   10   :  11   :':u format "X(185)" skip
        '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
        .
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY SelectDocument
      WITH FRAME F-Main.
  ENABLE RECT-cashiers SelectDocument
      WITH FRAME F-Main.
END PROCEDURE.
PROCEDURE My-Report :
run My-Var in this-procedure .
run PrintProc in this-procedure .
END PROCEDURE.
PROCEDURE My-var :
assign
  frame F-Main SelectDocument
.
assign
  STR-obj-type = ''
  STR-obj-code = ''
  STR-obj-name = ''
  STR-obj      = ''
.
for each obj-list no-lock
:
  assign
    STR-obj-type = STR-obj-type + obj-list.obj-type + ','
    STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
    STR-obj-name = STR-obj-name + obj-list.obj-name + ','
    STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
  .
end.
assign
  ReportName   = "Журнал регистрации полученных счетов-фактур"
  ReportHeader = "Документы : " +
                   radio-label(string(SelectDocument), SelectDocument:radio-buttons) + chr(10)
.
END PROCEDURE.
PROCEDURE print-excel-header :
  define input  parameter p-host-code as integer   no-undo .
  define input-output parameter p-excel-line as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run macr_excel_char in this-procedure
      (input  format-excel-text(ReportName)
      ,input  p-excel-line
      ,input  1
      ) .
    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(ReportHeader)
      ,input  p-excel-line
      ,input  1
      ) .
    run fmtcli-get-client in this-procedure
      (input  'орг':U
      ,input  p-host-code
      ) .
    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(str1 + " по организации " + v-fmtcli-name )
      ,input  p-excel-line
      ,input  1
      ) .
    define variable v-str-num-entries   as integer   no-undo .
    define variable v-str-entry         as integer   no-undo .
    define variable v-str-text          as character no-undo .
    define variable v-sub-start         as integer   no-undo .
    define variable v-num-lines         as integer   no-undo .
    define variable v-start-length-list as character no-undo .
    define variable v-cur-line          as integer   no-undo .
    assign
      v-str-num-entries = num-entries(str4, chr(10))
    .
    do v-str-entry = 1 to v-str-num-entries
    :
      assign
        v-str-text = entry(v-str-entry, str4, chr(10))
      .
      run split-string in this-procedure
        (input  v-str-text
        ,input  60
        ,output v-num-lines
        ,output v-start-length-list
        ) .
      do v-cur-line = 1 to v-num-lines
      :
        assign
          p-excel-line = p-excel-line + 1
        .
        run macr_excel_char in this-procedure
          (input
            format-excel-text
            ( substring
              (v-str-text
              ,integer
                (entry
                  (v-cur-line * 2 - 1
                  ,v-start-length-list
                  ,chr(44)
                  )
                )
              ,integer
                (entry
                  (v-cur-line * 2
                  ,v-start-length-list
                  ,chr(44)
                  )
                )
              )
            )
          ,input  p-excel-line
          ,input  1
          ) .
      end.
    end.
    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(cur-time-print())
      ,input  p-excel-line
      ,input  1
      ) .
  end.
END PROCEDURE.
PROCEDURE PrintProc :
  define buffer buf_temp-doc-list for temp-doc-list .
  define buffer buf_obj-list      for obj-list .
  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_clients       for ub.clients .
  define variable v-select-document as logical   no-undo .
  define variable v-is-hold         as logical   no-undo .
  define variable v-scf-code        as character no-undo .
  define variable v-scf-date        as date      no-undo .
  define variable v-scf-date-str    as character no-undo .
  define variable v-parameter-type  as character no-undo .
  define buffer buf_d-slts-vats for d-slts-vats .
  do
  on error undo, return error return-value
  :
    define variable v-host-code as integer   no-undo .
    define variable v-first-obj-type  as character no-undo .
    define variable v-first-obj-code  as integer   no-undo .
    define variable v-other-host-code as integer   no-undo .
    find first buf_obj-list
      no-error .
    if available buf_obj-list
    then do:
      assign
        v-first-obj-type = buf_obj-list.obj-type
        v-first-obj-code = buf_obj-list.obj-code
      .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,output v-host-code
  )  .
    end.
    else do:
      message
        "Не выбран объект" skip
        view-as alert-box error .
      return .
    end.
    for each buf_obj-list
    on error undo, return error return-value
    :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_obj-list.obj-type
  ,input  buf_obj-list.obj-code
  ,output v-other-host-code
  )  .
      if v-other-host-code <> v-host-code
      then do:
        message
          "Нельзя задавать объекты, принадлежащие разным фирмам" skip
          "Объект, принадлежащий одной фирме"
            v-first-obj-type v-first-obj-code skip
          "Объект, принадлежащий другой фирме"
            buf_obj-list.obj-type buf_obj-list.obj-code skip
          view-as alert-box error .
        return .
      end.
    end.
    for each buf_temp-doc-list
    on error undo, return error return-value
    :
      delete buf_temp-doc-list .
    end.
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
    define variable v-total-doc as integer   no-undo .
    for each buf_obj-list
    on error undo, return error return-value
    :
    find first G#CUSTOMER no-error .
      if not available G#CUSTOMER then do :
          for each buf_clients no-lock :
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each buf_trn-doc no-lock
where buf_trn-doc.obj-type  = buf_obj-list.obj-type
  and buf_trn-doc.obj-code  = buf_obj-list.obj-code
  and buf_trn-doc.cli-type  = buf_clients.obj-type
  and buf_trn-doc.cli-code  = buf_clients.obj-code
  and buf_trn-doc.fact-date >= X-date-start
  and buf_trn-doc.fact-date <= X-date-end
  and buf_trn-doc.ext-doc-type = 'ie':U
on error undo, return error return-value
:
    assign
      v-total-doc = v-total-doc + 1
    .
IF ( v-total-doc modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-total-doc @ RecordsDone
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
    assign
      v-select-document = false
    .
    case SelectDocument
    :
      when '1':u
      then do:
        assign
          v-select-document = true
        .
      end.
      when '2':u
      then do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            v-select-document = false
          .
        end.
        else do:
          assign
            v-select-document = true
          .
        end.
      end.
      when '3':u
      then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            v-select-document = true
          .
        end.
        else do:
          assign
            v-select-document = false
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение переменной SelectDocument" skip
          "SelectDocument" SelectDocument skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    if  v-select-document = true
    then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nsf':U ,
                       output v-scf-code ,
                       output v-parameter-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dsf':U ,
                       output v-scf-date-str ,
                       output v-parameter-type )  .
      assign
        v-scf-date = date(v-scf-date-str)
      .
      run fmtcli-get-client in this-procedure
        (input  buf_trn-doc.cli-type
        ,input  buf_trn-doc.cli-code
        ) .
      if v-scf-code <> ""
      or v-scf-date <> ?
      then do:
        for each buf_d-slts-vats
        on error undo, return error return-value
        :
          delete buf_d-slts-vats .
        end.
        run str/calc-sup.p
          (input  recid(buf_trn-doc)
          ,input  'd-slts-vats'
          ,input  yes
          ,input  ?
          ,input  yes
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры calc-sup.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        for each buf_d-slts-vats
        on error undo, return error return-value
        :
          create buf_temp-doc-list .
          assign
            buf_temp-doc-list.doc-code    = buf_trn-doc.doc-code
            buf_temp-doc-list.supp-vat-pc = buf_d-slts-vats.vat-pc
            buf_temp-doc-list.supp-slt-pc = buf_d-slts-vats.slt-pc
            buf_temp-doc-list.fact-order  = buf_trn-doc.fact-order
            buf_temp-doc-list.scf-code    = v-scf-code
            buf_temp-doc-list.scf-date    = date(v-scf-date-str)
            buf_temp-doc-list.supp-name   = v-fmtcli-name
                                          + (if v-fmtcli-name <> "" then " " else "")
                                          + v-fmtcli-addres
            buf_temp-doc-list.inn         = v-fmtcli-inn
            buf_temp-doc-list.no-vat-rubl = buf_d-slts-vats.no-vat-rubl
            buf_temp-doc-list.vat-rubl    = buf_d-slts-vats.vat-rubl
            buf_temp-doc-list.acc-rubl    = buf_d-slts-vats.acc-rubl
          .
        end.
      end.
    end.
  end.
          end.
      end.
      else do :
          for each G#CUSTOMER no-lock :
define variable vss-include-info21 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
for each buf_trn-doc no-lock
where buf_trn-doc.obj-type  = buf_obj-list.obj-type
  and buf_trn-doc.obj-code  = buf_obj-list.obj-code
  and buf_trn-doc.cli-type  = G#CUSTOMER.obj-type
  and buf_trn-doc.cli-code  = G#CUSTOMER.obj-code
  and buf_trn-doc.fact-date >= X-date-start
  and buf_trn-doc.fact-date <= X-date-end
  and buf_trn-doc.ext-doc-type = 'ie':U
on error undo, return error return-value
:
    assign
      v-total-doc = v-total-doc + 1
    .
IF ( v-total-doc modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-total-doc @ RecordsDone
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
    assign
      v-select-document = false
    .
    case SelectDocument
    :
      when '1':u
      then do:
        assign
          v-select-document = true
        .
      end.
      when '2':u
      then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            v-select-document = false
          .
        end.
        else do:
          assign
            v-select-document = true
          .
        end.
      end.
      when '3':u
      then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            v-select-document = true
          .
        end.
        else do:
          assign
            v-select-document = false
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Внутренняя ошибка" skip
          "Неизвестное значение переменной SelectDocument" skip
          "SelectDocument" SelectDocument skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    if  v-select-document = true
    then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nsf':U ,
                       output v-scf-code ,
                       output v-parameter-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dsf':U ,
                       output v-scf-date-str ,
                       output v-parameter-type )  .
      assign
        v-scf-date = date(v-scf-date-str)
      .
      run fmtcli-get-client in this-procedure
        (input  buf_trn-doc.cli-type
        ,input  buf_trn-doc.cli-code
        ) .
      if v-scf-code <> ""
      or v-scf-date <> ?
      then do:
        for each buf_d-slts-vats
        on error undo, return error return-value
        :
          delete buf_d-slts-vats .
        end.
        run str/calc-sup.p
          (input  recid(buf_trn-doc)
          ,input  'd-slts-vats'
          ,input  yes
          ,input  ?
          ,input  yes
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры calc-sup.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        for each buf_d-slts-vats
        on error undo, return error return-value
        :
          create buf_temp-doc-list .
          assign
            buf_temp-doc-list.doc-code    = buf_trn-doc.doc-code
            buf_temp-doc-list.supp-vat-pc = buf_d-slts-vats.vat-pc
            buf_temp-doc-list.supp-slt-pc = buf_d-slts-vats.slt-pc
            buf_temp-doc-list.fact-order  = buf_trn-doc.fact-order
            buf_temp-doc-list.scf-code    = v-scf-code
            buf_temp-doc-list.scf-date    = date(v-scf-date-str)
            buf_temp-doc-list.supp-name   = v-fmtcli-name
                                          + (if v-fmtcli-name <> "" then " " else "")
                                          + v-fmtcli-addres
            buf_temp-doc-list.inn         = v-fmtcli-inn
            buf_temp-doc-list.no-vat-rubl = buf_d-slts-vats.no-vat-rubl
            buf_temp-doc-list.vat-rubl    = buf_d-slts-vats.vat-rubl
            buf_temp-doc-list.acc-rubl    = buf_d-slts-vats.acc-rubl
          .
        end.
      end.
    end.
  end.
          end.
      end.
    end.
    run prn-lib-open-stream in this-procedure ( input my-handle, input 43, input yes, input no ).
    assign
      v-total-doc = 0
    .
IF ( v-total-doc modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-total-doc @ RecordsDone
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
    define variable v-file-name-ind as integer   no-undo .
    assign
      make-excel      = yes
      v-file-name     = string(session :temp-directory) + "rpt" + string( g#report-num ) + ".txt"
      v-file-name-ind = 1
    .
    output stream macr_excel to value(v-file-name) .
    define variable v-excel-line  as integer   no-undo .
    define variable v-excel-sheet as integer   no-undo .
    define variable v-line        as character no-undo .
    assign
      v-excel-line  = 1
      v-excel-sheet = 1
    .
    assign
      v-line = fill('-', 185)
    .
    form header
      v-line format "x(185)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame bottomframe width 186 page-bottom no-labels no-box
      .
    view stream PrnLibStream frame bottomframe .
    put stream PrnLibStream
      caps(ReportName) format "X(185)" skip
      ReportHeader format "X(185)" skip
      .
    run fmtcli-get-client in this-procedure
      (input  'орг':U
      ,input  v-host-code
      ) .
    put stream PrnLibStream
      str1 + " по организации " + v-fmtcli-name format "X(185)" skip
      .
    define variable v-str-num-entries as integer   no-undo .
    define variable v-str-entry       as integer   no-undo .
    define variable v-str-text        as character no-undo .
    define variable v-sub-start       as integer   no-undo .
    assign
      v-str-num-entries = num-entries(str4, chr(10))
    .
    do v-str-entry = 1 to v-str-num-entries
    :
      assign
        v-str-text = entry(v-str-entry, str4, chr(10))
      .
      do v-sub-start = 1 to length(v-str-text) by 60
      :
        put stream PrnLibStream
          substring(v-str-text, v-sub-start, 60) format "X(185)" skip
          .
      end.
    end.
    put stream PrnLibStream
      cur-time-print() at 5 format "x(35)"
      "Страница " at 100 page-number(PrnLibStream) at 115 format ">>>9" skip
      .
    put stream PrnLibStream
      '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
      ': N п/п          : N счета-фактуры: Дата     : Наименование поставщика                  : ИНН             : Стоимость       :       НДС              : Всего стоимость :      Акциз     :':u format "X(185)" skip
      ':                :                : выписки  :                                          : поставщика      : поставки        :------:-----------------: рублей          :--------:-------:':u format "X(185)" skip
      ':                :                : счета-   :                                          :                 : без НДС (рублей):Ставка:  Сумма          :                 : Ставка : Сумма :':u format "X(185)" skip
      ':                :                : фактуры  :                                          :                 :                 :      :                 :                 :        :       :':u format "X(185)" skip
      '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
      ':       1        :       2        :    3     :                    4                     :        5        :        7        :  8   :     9           :       12        :   10   :  11   :':u format "X(185)" skip
      '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
      .
    run print-excel-header in this-procedure
      (input         v-host-code
      ,input-output  v-excel-line
      ) .
    run setup-excel-sheet in this-procedure
      (input-output  v-excel-line
      ) .
    run macr_cell_format in this-procedure
      (input 18
      ,input true
      ,input false
      ,input ?
      ,input 1
      ,input 1
      ,input ?
      ,input ?
      ) .
    define variable v-total-no-vat-rubl as decimal   no-undo .
    define variable v-total-vat-rubl    as decimal   no-undo .
    define variable v-total-acc-rubl    as decimal   no-undo .
    assign
      v-total-no-vat-rubl = 0
      v-total-vat-rubl    = 0
      v-total-acc-rubl    = 0
    .
    for each buf_temp-doc-list
    by buf_temp-doc-list.fact-order
    on error undo, return error return-value
    :
      assign
        v-total-no-vat-rubl = v-total-no-vat-rubl + buf_temp-doc-list.no-vat-rubl
        v-total-vat-rubl    = v-total-vat-rubl    + buf_temp-doc-list.vat-rubl
        v-total-acc-rubl    = v-total-acc-rubl    + buf_temp-doc-list.acc-rubl
      .
      assign
        v-total-doc = v-total-doc + 1
      .
      assign
        v-excel-line = v-excel-line + 1
      .
IF ( v-total-doc modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-total-doc @ RecordsDone
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
      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.doc-code)
        ,input  v-excel-line
        ,input  1
        ) .
      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.scf-code)
        ,input  v-excel-line
        ,input  2
        ) .
      if buf_temp-doc-list.scf-date <> ?
      then do:
        run macr_excel_date in this-procedure
          (input  buf_temp-doc-list.scf-date - date(1, 1, 1900) + 2
          ,input  v-excel-line
          ,input  3
          ) .
      end.
      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.supp-name)
        ,input  v-excel-line
        ,input  4
        ) .
      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.inn)
        ,input  v-excel-line
        ,input  5
        ) .
      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.no-vat-rubl
        ,input  v-excel-line
        ,input  6
        ,input  2
        ) .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 6 , v-excel-line, 6 ) + chr(10)
        'format.number("#,##0.00")':u + chr(10)
        .
      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.supp-vat-pc
        ,input  v-excel-line
        ,input  7
        ,input  2
        ) .
      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.vat-rubl
        ,input  v-excel-line
        ,input  8
        ,input  2
        ) .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 8 , v-excel-line, 8 ) + chr(10)
        'format.number("#,##0.00")':u + chr(10)
        .
      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.acc-rubl
        ,input  v-excel-line
        ,input  9
        ,input  2
        ) .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 9 , v-excel-line, 9 ) + chr(10)
        'format.number("#,##0.00")':u + chr(10)
        .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 1 , v-excel-line, 11 ) + chr(10)
        'alignment(,,1,,)':u + chr(10)
        'border(4,4,4,4,4,,,,,,)':u + chr(10)
        .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 4 , v-excel-line, 4 ) + chr(10)
        'alignment(,true,,,)':u + chr(10)
        .
      if v-excel-line > 30000
      then do:
        put stream macr_excel unformatted
          'select("r1c1")':u + chr(10)
          .
        output stream macr_excel close .
        run paramls-write in this-procedure
          (input  "file"
          ,input  string(v-file-name-ind)
          ,input  v-file-name
          ) .
        assign
          v-file-name-ind = v-file-name-ind + 1
          v-excel-line    = 1
        .
        assign
          v-file-name = string(session :temp-directory) + "rpt" + string( g#report-num )  + "_" + string(v-file-name-ind) + ".txt"
        .
        output stream macr_excel to value(v-file-name) .
        run setup-excel-sheet in this-procedure
          (input-output  v-excel-line
          ) .
      end.
      define variable v-address-num-lines as integer   no-undo .
      define variable v-start-length-list as character no-undo .
      define variable v-address-line      as integer   no-undo .
      run split-string in this-procedure
        (input  buf_temp-doc-list.supp-name
        ,input  40
        ,output v-address-num-lines
        ,output v-start-length-list
        ) .
      run check-new-page in this-procedure
        (input  v-address-num-lines
        ) .
      do v-address-line = 1 to v-address-num-lines
      :
        if v-address-line = 1
        then do:
          put stream PrnLibStream
            ": " format "x(2)"
            buf_temp-doc-list.doc-code    format "x(14)"
            " : "                         format "x(3)"
            buf_temp-doc-list.scf-code    format "x(14)"
            " : "                         format "x(3)"
            buf_temp-doc-list.scf-date    format "99.99.99"
            " : "                         format "x(3)"
            substring(buf_temp-doc-list.supp-name
                     ,integer(entry(v-address-line * 2 - 1,v-start-length-list,chr(44)))
                     ,integer(entry(v-address-line * 2,v-start-length-list,chr(44)))
                     ) format "x(40)"
            " : "                         format "x(3)"
            buf_temp-doc-list.inn         format "x(15)"
            " : "                         format "x(3)"
            buf_temp-doc-list.no-vat-rubl format "->>>,>>>,>>>.99"
            " : "                         format "x(3)"
            buf_temp-doc-list.supp-vat-pc format ">>9.<<"
            " : "                         format "x(3)"
            buf_temp-doc-list.vat-rubl    format "->>>,>>>,>>>.99"
            " : "                         format "x(3)"
            buf_temp-doc-list.acc-rubl    format "->>>,>>>,>>>.99"
            " : "                         format "x(3)"
            " "        format "x(6)"
            " : "                         format "x(3)"
            " "         format "x(5)"
            " :"                          format "x(2)"
            skip
            .
        end.
        else do:
          put stream PrnLibStream
            ": " format "x(2)"
            " "                           format "x(14)"
            " : "                         format "x(3)"
            " "                           format "x(14)"
            " : "                         format "x(3)"
            " "                           format "x(8)"
            " : "                         format "x(3)"
            substring(buf_temp-doc-list.supp-name
                     ,integer(entry(v-address-line * 2 - 1,v-start-length-list,chr(44)))
                     ,integer(entry(v-address-line * 2,v-start-length-list,chr(44)))
                     ) format "x(40)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " "                           format "x(4)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " "        format "x(6)"
            " : "                         format "x(3)"
            " "         format "x(5)"
            " :"                          format "x(2)"
            skip
            .
        end.
      end.
    end.
    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("ИТОГО:")
      ,input  v-excel-line
      ,input  5
      ) .
    run macr_cell_format in this-procedure
      (input 8
      ,input true
      ,input false
      ,input ?
      ,input v-excel-line
      ,input 5
      ,input ?
      ,input ?
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 1 , v-excel-line, 6 ) + chr(10)
      'border(1,,,,,,,,,,)':u + chr(10)
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 7 , v-excel-line, 7 ) + chr(10)
      'border(1,,,,,,,,,,)':u + chr(10)
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 8 , v-excel-line, 8 ) + chr(10)
      'border(1,,,,,,,,,,)':u + chr(10)
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 9 , v-excel-line, 9 ) + chr(10)
      'border(1,,,,,,,,,,)':u + chr(10)
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 10 , v-excel-line, 10 ) + chr(10)
      'border(1,,,,,,,,,,)':u + chr(10)
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 11 , v-excel-line, 11 ) + chr(10)
      'border(1,,,,,,,,,,)':u + chr(10)
      .
    run macr_excel_sum in this-procedure
      (input  v-total-no-vat-rubl
      ,input  v-excel-line
      ,input  6
      ,input  2
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 6 , v-excel-line, 6 ) + chr(10)
      'format.number("#,##0.00")':u + chr(10)
      .
    run macr_excel_sum in this-procedure
      (input  v-total-vat-rubl
      ,input  v-excel-line
      ,input  8
      ,input  2
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 8 , v-excel-line, 8 ) + chr(10)
      'format.number("#,##0.00")':u + chr(10)
      .
    run macr_excel_sum in this-procedure
      (input  v-total-acc-rubl
      ,input  v-excel-line
      ,input  9
      ,input  2
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 9 , v-excel-line, 9 ) + chr(10)
      'format.number("#,##0.00")':u + chr(10)
      .
    define buffer buf_sysconf for ub.sysconf .
    define buffer buf_firm    for ub.firm .
    define variable v-glav-buh  as character no-undo .
    define variable v-director  as character no-undo .
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if available buf_sysconf
    then do:
      assign
        v-glav-buh = buf_sysconf.snr-accnt
      .
    end.
    else do:
      assign
        v-glav-buh = ""
      .
    end.
    find first buf_firm no-lock
      where buf_firm.firm-code = v-host-code
      no-error .
    if available buf_firm
    then do:
      assign
        v-director = buf_firm.director
      .
    end.
    else do:
      assign
        v-director = ""
      .
    end.
    assign
      v-excel-line = v-excel-line + 3
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Руководитель организации (физическое лицо):")
      ,input  v-excel-line
      ,input  1
      ) .
    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(v-director)
      ,input  v-excel-line
      ,input  1
      ) .
    run macr_cell_format in this-procedure
      (input 8
      ,input false
      ,input true
      ,input ?
      ,input v-excel-line
      ,input 1
      ,input ?
      ,input ?
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")':u, v-excel-line, 1, v-excel-line, 4) + chr(10)
      'row.height(20,,,)':u + chr(10)
      'border(,,,,1,,,,,,)':u + chr(10)
      .
    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Ф.И.О., подпись")
      ,input  v-excel-line
      ,input  2
      ) .
    run macr_cell_format in this-procedure
      (input 7
      ,input false
      ,input true
      ,input ?
      ,input v-excel-line
      ,input 2
      ,input ?
      ,input ?
      ) .
    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("М.П.")
      ,input  v-excel-line
      ,input  4
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")':u, v-excel-line, 4, v-excel-line, 4) + chr(10)
      'alignment(3,,,,,,,)':u + chr(10)
      .
    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Главный бухгалтер организации:")
      ,input  v-excel-line
      ,input  1
      ) .
    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(v-glav-buh)
      ,input  v-excel-line
      ,input  1
      ) .
    run macr_cell_format in this-procedure
      (input 8
      ,input false
      ,input true
      ,input ?
      ,input v-excel-line
      ,input 1
      ,input ?
      ,input ?
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")':u, v-excel-line, 1, v-excel-line, 4) + chr(10)
      'row.height(20,,,)':u + chr(10)
      'border(,,,,1,,,,,,)':u + chr(10)
      .
    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Ф.И.О., подпись")
      ,input  v-excel-line
      ,input  2
      ) .
    run macr_cell_format in this-procedure
      (input 7
      ,input false
      ,input true
      ,input ?
      ,input v-excel-line
      ,input 2
      ,input ?
      ,input ?
      ) .
    put stream macr_excel unformatted
      'select("r1c1")':u + chr(10)
      .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    output stream macr_excel close .
    run paramls-write in this-procedure
      (input  "file"
      ,input  string(v-file-name-ind)
      ,input  v-file-name
      ) .
    run end-proc in this-procedure .
    run check-new-page in this-procedure
      (input  9
      ) .
    hide stream PrnLibStream frame bottomframe .
    put stream PrnLibStream
      v-line format "X(185)" skip .
    put stream PrnLibStream
      ": " format "x(2)"
      " "                           format "x(14)"
      " : "                         format "x(3)"
      " "                           format "x(14)"
      " : "                         format "x(3)"
      " "                           format "x(8)"
      " : "                         format "x(3)"
      " "                           format "x(40)"
      " : "                         format "x(3)"
      "          ИТОГО"             format "x(15)"
      " : "                         format "x(3)"
      v-total-no-vat-rubl           format "->>>,>>>,>>>.99"
      " : "                         format "x(3)"
      " "                           format "x(4)"
      " : "                         format "x(3)"
      v-total-vat-rubl              format "->>>,>>>,>>>.99"
      " : "                         format "x(3)"
      v-total-acc-rubl              format "->>>,>>>,>>>.99"
      " : "                         format "x(3)"
      " "        format "x(6)"
      " : "                         format "x(3)"
      " "         format "x(5)"
      " :"                          format "x(2)"
      skip
      .
    put stream PrnLibStream
      v-line format "X(185)" skip .
    put stream PrnLibStream
      "Руководитель организации (физическое лицо):" skip .
    put stream PrnLibStream
      v-director + fill('_', 60) format "X(60)" skip .
    put stream PrnLibStream
      "                        Ф.И.О., подпись                  М.П." skip .
    put stream PrnLibStream
      "Главный бухгалтер организации" skip .
    put stream PrnLibStream
      v-glav-buh + fill('_', 60) format "X(60)" skip .
    put stream PrnLibStream
      "                        Ф.И.О., подпись" skip .
    output stream PrnLibStream close .
   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   define variable DisabledOptions as integer   no-undo .
   define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w
         ( input  ""
         , input  8
         , input  string(session :temp-directory) + "rpt" + string( g#report-num )
         , input  ReportFontNum
         , output v-user-action
         , output v-printed
         ) .
   os-delete value( string( session:temp-directory ) + "rpt" + string( g#report-num ) + ".txl" )  .
  end.
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE setup-excel-sheet :
  define input-output parameter p-excel-line as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-excel-line = p-excel-line + 1
    .
    put stream macr_excel unformatted
      'select("c1:c11")':u + chr(10)
      'format.font(,8,,)':u + chr(10)
      .
    put stream macr_excel unformatted
      'page.setup(,,0.4,0.4,0.4,0.4,,,,,,,80,,,,,,,,)':u + chr(10)
      substitute('set.print.titles("r&1:r&2",)':u, p-excel-line, p-excel-line + 2) + chr(10)
      .
    run macr_cell_size in this-procedure
      (input  8.5
      ,input  ?
      ,input  1
      ,input  1
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  8.5
      ,input  ?
      ,input  1
      ,input  2
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  6.5
      ,input  ?
      ,input  1
      ,input  3
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  23
      ,input  ?
      ,input  1
      ,input  4
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  13
      ,input  ?
      ,input  1
      ,input  5
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  10
      ,input  ?
      ,input  1
      ,input  6
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  5.5
      ,input  ?
      ,input  1
      ,input  7
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  5.5
      ,input  ?
      ,input  1
      ,input  10
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_size in this-procedure
      (input  5.5
      ,input  ?
      ,input  1
      ,input  11
      ,input  ?
      ,input  ?
      ) .
    run macr_cell_format in this-procedure
      (input  8
      ,input  false
      ,input  false
      ,input  ?
      ,input  p-excel-line
      ,input  1
      ,input  p-excel-line
      ,input  11
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("N п/п")
      ,input  p-excel-line
      ,input  1
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  1
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("N счета-фактуры")
      ,input  p-excel-line
      ,input  2
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  2
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Дата выписки счета-фактуры")
      ,input  p-excel-line
      ,input  3
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  3
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Наименование поставщика")
      ,input  p-excel-line
      ,input  4
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  4
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("ИНН поставщика")
      ,input  p-excel-line
      ,input  5
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  5
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Стоимость поставки без НДС, рублей")
      ,input  p-excel-line
      ,input  6
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  6
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("НДС")
      ,input  p-excel-line
      ,input  7
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  7
      ,input  p-excel-line
      ,input  8
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Всего стоимость (рублей)")
      ,input  p-excel-line
      ,input  9
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  9
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Акциз")
      ,input  p-excel-line
      ,input  10
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  10
      ,input  p-excel-line
      ,input  11
      ) .
    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_cell_format in this-procedure
      (input  8
      ,input  false
      ,input  false
      ,input  ?
      ,input  p-excel-line
      ,input  1
      ,input  p-excel-line
      ,input  11
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  1
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  1
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  2
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  2
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  3
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  3
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  4
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  4
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  5
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  5
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  6
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  6
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Ставка")
      ,input  p-excel-line
      ,input  7
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  7
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Сумма")
      ,input  p-excel-line
      ,input  8
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  8
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  9
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  9
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Ставка")
      ,input  p-excel-line
      ,input  10
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  10
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Сумма")
      ,input  p-excel-line
      ,input  11
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  11
      ,input  ?
      ,input  ?
      ) .
    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_cell_format in this-procedure
      (input  8
      ,input  false
      ,input  true
      ,input  ?
      ,input  p-excel-line
      ,input  1
      ,input  p-excel-line
      ,input  11
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("1")
      ,input  p-excel-line
      ,input  1
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  1
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("2")
      ,input  p-excel-line
      ,input  2
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  2
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("3")
      ,input  p-excel-line
      ,input  3
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  3
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("4")
      ,input  p-excel-line
      ,input  4
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  4
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("5")
      ,input  p-excel-line
      ,input  5
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  5
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("7")
      ,input  p-excel-line
      ,input  6
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  6
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("8")
      ,input  p-excel-line
      ,input  7
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  7
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("9")
      ,input  p-excel-line
      ,input  8
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  8
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("12")
      ,input  p-excel-line
      ,input  9
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  9
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("10")
      ,input  p-excel-line
      ,input  10
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  10
      ,input  ?
      ,input  ?
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("11")
      ,input  p-excel-line
      ,input  11
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line
      ,input  11
      ,input  ?
      ,input  ?
      ) .
  end.
END PROCEDURE.
PROCEDURE split-string :
  define input  parameter p-split-string      as character no-undo .
  define input  parameter p-split-length      as integer   no-undo .
  define output parameter p-address-num-lines as integer   no-undo .
  define output parameter p-start-length-list as character no-undo .
  define variable v-ind as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-ind = 1
      p-address-num-lines = 0
    .
    do while true
    :
      if v-ind + p-split-length > length(p-split-string)
      then do:
        assign
          p-address-num-lines = p-address-num-lines + 1
          p-start-length-list = p-start-length-list
                              + (if p-start-length-list <> "" then ',':u else '':u)
                              + string(v-ind)
                              + chr(44)
                              + string(length(p-split-string) - v-ind + 1)
        .
        leave .
      end.
      else do:
        define variable v-space-index as integer   no-undo .
        assign
          v-space-index = r-index(substring(p-split-string, v-ind, p-split-length), " ")
        .
        if v-space-index = 0
        then do:
          assign
            v-space-index = r-index(substring(p-split-string, v-ind, p-split-length), ",")
          .
        end.
        if v-space-index = 0
        then do:
          assign
            v-space-index = p-split-length
          .
        end.
        assign
          p-address-num-lines = p-address-num-lines + 1
          p-start-length-list = p-start-length-list
                              + (if p-start-length-list <> "" then ',':u else '':u)
                              + string(v-ind)
                              + chr(44)
                              + string(v-space-index)
        .
        assign
          v-ind = v-ind + v-space-index
        .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
