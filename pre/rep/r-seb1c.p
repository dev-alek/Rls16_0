block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Бензиновый отчет по себестоимости".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable var-report-r-b as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
 do
 on error undo, return error return-value
 :
define temp-table temp_dbflib_field no-undo
    field col-num           as integer
    field field-name        as character    format "x(32)"
    field data-type         as character
    field field-decimals    as integer
    field dbfield-name      as character    format "x(11)"
    field field-handle      as handle
    field field-length      as integer      format ">>>9"
    index field-name        is primary unique
        field-name
    index col_
        col-num
.
define temp-table temp_dbflib_data no-undo
    field col-num           as integer
    field record-number as integer
    field field-name    as character
    field data-value    as character
    index pi is primary unique
        record-number
        field-name
    index col_
        col-num
.
define variable v-dbflib-reclength      as integer      no-undo.
define variable v-field-amount          as integer      no-undo.
define stream dbf-stream.
define temp-table tt-seb no-undo
  field   DATAS           as date
  field   NAMEA           as character
  field   AZS             as character
  field   KODVO           as character
  field   NAMET           as character
  field   TOVAR           as character
  field   SUMMA           as decimal decimals 2
  field   NAMEP           as character
  field   POLUCH          as character
  field   chk-qnty        as decimal
  index pi as primary unique
    DATAS AZS KODVO TOVAR POLUCH
.
define buffer buf_tt-seb for tt-seb .
define buffer buf2_tt-seb for tt-seb .
define temp-table tt-fbr no-undo
  field comp-gds-code     as integer
  field ingr-gds-code     as integer
  field ingr-gds-name     as character
  field comp-qnty         as decimal
  field inqr-qnty         as decimal
  index pi as primary unique
    comp-gds-code ingr-gds-code
.
def buffer buf_clients for ub.clients .
def buffer This_Object for ub.clients .
def buffer buf_goods   for ub.goods .
def var i as int no-undo.
define variable paris-petrolium as   logical            no-undo.
define variable paris-pieces    as   logical            no-undo.
define temp-table tt-gds-list no-undo like ub.goods.
run waitfram-show ( "Ждите..." ) .
for each tt-gds-list : delete tt-gds-list. end.
for each buf_goods no-lock where buf_goods.gds-type = "т" :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output paris-petrolium
  , output paris-pieces
  ) .
      if paris-petrolium
      then do :
      end.
      else do :
          create tt-gds-list.
          BUFFER-COPY buf_goods TO tt-gds-list.
      end.
end.
empty temp-table tt-seb .
for each obj-list :
  run rep/rpychk0.p ( input "r-shftc2"
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input ?
                        ,input ?
                        ,input X-date-Start
                        ,input x-Date-End
                        ,input 1
                        ,input 999
                        ,input ?
                        ).
  run make-tt.
end.
run dbflib-init in this-procedure.
run dbflib-add-field in this-procedure (
                          input 1
                        , input "DATAS"
                        , input 8
                        , input "date":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 2
                        , input "NAMEA"
                        , input 100
                        , input "character":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 3
                        , input "AZS"
                        , input 25
                        , input "character":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 4
                        , input "KODVO"
                        , input 10
                        , input "character":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 5
                        , input "NAMET"
                        , input 100
                        , input "character":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 6
                        , input "TOVAR"
                        , input 25
                        , input "character":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 7
                        , input "SUMMA"
                        , input 15
                        , input "decimal":U
                        , input 2
                    ).
run dbflib-add-field in this-procedure (
                          input 8
                        , input "NAMEP"
                        , input 100
                        , input "character":U
                        , input 0
                    ).
run dbflib-add-field in this-procedure (
                          input 9
                        , input "POLUCH"
                        , input 25
                        , input "character":U
                        , input 0
                    ).
i = 0 .
for each tt-seb no-lock where tt-seb.KODVO <> "spi-prvo" break by tt-seb.DATAS by tt-seb.AZS by tt-seb.KODVO by tt-seb.TOVAR :
  find first buf_goods no-lock where buf_goods.gds-code = integer(tt-seb.TOVAR) .
  find first obj-list no-lock where obj-list.obj-name = tt-seb.NAMEA .
  find first ub.recipe no-lock where
             ub.recipe.prod-type = buf_goods.prod-type
         and ub.recipe.prod-code = buf_goods.prod-code
         and ub.recipe.artic     = buf_goods.artic
         and
           (
           ( ub.recipe.obj-type  = obj-list.obj-type
         and ub.recipe.obj-code  = obj-list.obj-code
           )
          or
           ( ub.recipe.obj-type  = "":U
         and ub.recipe.obj-code  = 0
           )
           )
         no-error.
  if available ub.recipe then next .
  i = i + 1.
  run dbflib-add-data in this-procedure (
                          input 1
                        , input i
                        , input "DATAS"
                        , input string(tt-seb.DATAS)
                    ).
  run dbflib-add-data in this-procedure (
                          input 2
                        , input i
                        , input "NAMEA"
                        , input tt-seb.NAMEA
                    ).
  run dbflib-add-data in this-procedure (
                          input 3
                        , input i
                        , input "AZS"
                        , input tt-seb.AZS
                    ).
  run dbflib-add-data in this-procedure (
                          input 4
                        , input i
                        , input "KODVO"
                        , input tt-seb.KODVO
                    ).
  run dbflib-add-data in this-procedure (
                          input 5
                        , input i
                        , input "NAMET"
                        , input tt-seb.NAMET
                    ).
  run dbflib-add-data in this-procedure (
                          input 6
                        , input i
                        , input "TOVAR"
                        , input tt-seb.TOVAR
                    ).
  run dbflib-add-data in this-procedure (
                          input 7
                        , input i
                        , input "SUMMA"
                        , input string(tt-seb.SUMMA)
                    ).
  run dbflib-add-data in this-procedure (
                          input 8
                        , input i
                        , input "NAMEP"
                        , input tt-seb.NAMEP
                    ).
  run dbflib-add-data in this-procedure (
                          input 9
                        , input i
                        , input "POLUCH"
                        , input tt-seb.POLUCH
                    ).
end.
run dbflib-write-dbf in this-procedure (
    input "sebestst.dbf":U
  , input i
) no-error.
if error-status :error
then do:
    message
             vss-workfile vss-revision vss-description
        skip(1)
        skip "Ошибка записи файла формата dbf."
        skip return-value
        skip trim( error-status :get-message( 1 ) )
             trim( error-status :get-message( 2 ) )
             trim( error-status :get-message( 3 ) )
    view-as alert-box error.
    undo, return error.
end.
run waitfram-hide .
message "Готово! Данные выгружены в файл sebestst.dbf в рабочую папку." view-as alert-box .
end.
procedure make-tt :
  do
  on error undo, return error return-value
  :
  define buffer buf_shift-obj for ub.shift-obj.
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf2_doc-line for ub.doc-line.
  define buffer buf_chk-doc for ub.chk-doc.
  define buffer buf_chk-gds for ub.chk-gds.
  define buffer buf_chk-gds-pay for ub.chk-gds-pay.
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_fbr-doc for ub.fbr-doc .
  define buffer buf_comp_fbr-line for ub.fbr-line.
  define buffer buf_ingr_fbr-line for ub.fbr-line.
  define buffer buf_ot-line for ub.ot-line .
  define variable v-pay-code as character no-undo .
  define variable v-vat-pc as decimal no-undo .
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   'факт':U
                                 and  buf_trn-doc.ext-doc-type  =   'es':U,
  each buf_chk-doc no-lock where buf_chk-doc.out-code = buf_trn-doc.doc-code,
  each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code,
  each buf_chk-gds-pay no-lock where buf_chk-gds-pay.doc-code = buf_chk-gds.doc-code
                                 and buf_chk-gds-pay.line-num = buf_chk-gds.line-num
                                 and buf_chk-gds-pay.b-code   = buf_chk-gds.b-code,
  first buf_bar-code no-lock where buf_bar-code.b-code  = buf_chk-gds-pay.b-code,
  first tt-gds-list no-lock where tt-gds-list.gds-code = buf_bar-code.gds-code:
    if trim(buf_chk-doc.d-card) > ""
    then do :
      if buf_chk-gds-pay.pay-code = 1 then v-pay-code = "Т001" .
      else
      if buf_chk-gds-pay.pay-code = 2975 then v-pay-code = "Т002" .
      else
      v-pay-code = string(buf_chk-gds-pay.pay-code, "9999") .
      if v-pay-code = "Т001" and buf_chk-gds-pay.tot-r-b <= 0.01 then v-pay-code = string(buf_chk-gds-pay.pay-code, "9999") .
    end.
    else do :
      v-pay-code = string(buf_chk-gds-pay.pay-code, "9999") .
    end.
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = v-pay-code
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = v-pay-code
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = ""
        tt-seb.NAMEP = ""
      .
    end.
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_chk-gds-pay.eff-doc-qnty .
    find first buf_doc-line no-lock where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                                      and buf_doc-line.artic      = tt-gds-list.artic
                                      and buf_doc-line.prod-type  = tt-gds-list.prod-type
                                      and buf_doc-line.prod-code  = tt-gds-list.prod-code
                                      no-error .
    if available buf_doc-line
    then do :
      find last buf_ot-line where  buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                    buf_ot-line.artic        =  buf_doc-line.artic                and
                                    buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                    buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                    buf_ot-line.obj-code     =  obj-list.obj-code      and
                                    buf_ot-line.obj-type     =  obj-list.obj-type      and
                                    buf_ot-line.sum-type     = 'cost':U use-index pi no-lock no-error.
      assign
        v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0
        tt-seb.SUMMA = tt-seb.SUMMA + (buf_chk-gds-pay.eff-doc-qnty * buf_doc-line.price-rubl / (1 + v-vat-pc))
      .
    end.
  end.
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   'факт':U
                                 and  buf_trn-doc.ext-doc-type  =   'ev':U,
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = "9999"
                                       and  tt-seb.POLUCH = string(buf_trn-doc.cli-code, "99999999999")
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = "9999"
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = string(buf_trn-doc.cli-code, "99999999999")
        tt-seb.NAMEP = buf_trn-doc.cli-name
      .
    end.
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_doc-line.fact-qnty .
    find last  buf_ot-line where buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                  buf_ot-line.artic        =  buf_doc-line.artic                and
                                  buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                  buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                  buf_ot-line.obj-code     =  obj-list.obj-code      and
                                  buf_ot-line.obj-type     =  obj-list.obj-type      and
                                  buf_ot-line.sum-type     = 'cost':U use-index pi no-lock no-error.
    assign
      v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0
      tt-seb.SUMMA = tt-seb.SUMMA + (buf_doc-line.fact-qnty * buf_doc-line.price-rubl / (1 + v-vat-pc))
    .
  end.
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   'факт':U
                                 and  buf_trn-doc.ext-doc-type  =   'we':U,
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = "9998"
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = "9998"
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = ""
        tt-seb.NAMEP = ""
      .
    end.
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_doc-line.fact-qnty .
    find last buf_ot-line where  buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                  buf_ot-line.artic        =  buf_doc-line.artic                and
                                  buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                  buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                  buf_ot-line.obj-code     =  obj-list.obj-code      and
                                  buf_ot-line.obj-type     =  obj-list.obj-type      and
                                  buf_ot-line.sum-type     = 'cost':U use-index pi no-lock no-error.
    assign
      v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0
      tt-seb.SUMMA = tt-seb.SUMMA + (buf_doc-line.fact-qnty * buf_doc-line.price-rubl /(1 + v-vat-pc))
    .
  end.
  for each buf_fbr-doc no-lock where  buf_fbr-doc.shift-date    >=  x-Date-Start
                                 and  buf_fbr-doc.shift-date    <=  x-Date-End
                                 and  buf_fbr-doc.obj-type      =   obj-list.obj-type
                                 and  buf_fbr-doc.obj-code      =   obj-list.obj-code
                                 and  buf_fbr-doc.status_       =   'факт':U:
    for each buf_comp_fbr-line no-lock where buf_comp_fbr-line.doc-code = buf_fbr-doc.doc-code
                                         and buf_comp_fbr-line.is-comp = yes,
    first buf_goods of buf_comp_fbr-line:
      for each buf_ingr_fbr-line no-lock where buf_ingr_fbr-line.doc-code = buf_fbr-doc.doc-code
                                           and buf_ingr_fbr-line.is-comp = no
                                           and buf_ingr_fbr-line.recipe-code = buf_comp_fbr-line.recipe-code,
      first tt-gds-list no-lock where tt-gds-list.artic     = buf_ingr_fbr-line.artic
                                  and tt-gds-list.prod-type = buf_ingr_fbr-line.prod-type
                                  and tt-gds-list.prod-code = buf_ingr_fbr-line.prod-code :
        find first tt-fbr no-lock where tt-fbr.comp-gds-code = buf_goods.gds-code
                                    and tt-fbr.ingr-gds-code = tt-gds-list.gds-code
                                    no-error .
        if not available tt-fbr
        then do :
          create tt-fbr .
          assign
            tt-fbr.comp-gds-code = buf_goods.gds-code
            tt-fbr.ingr-gds-code = tt-gds-list.gds-code
            tt-fbr.ingr-gds-name = tt-gds-list.gds-name
          .
        end.
        assign
          tt-fbr.comp-qnty = tt-fbr.comp-qnty + buf_comp_fbr-line.fact-qnty
          tt-fbr.inqr-qnty = tt-fbr.inqr-qnty + buf_ingr_fbr-line.fact-qnty
        .
      end.
    end.
  end.
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   'факт':U
                                 and  buf_trn-doc.ext-doc-type  =   'wm':U,
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:
    find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                       and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
                                       and  tt-seb.KODVO = "spi-prvo"
                                       no-error .
    if not available tt-seb
    then do :
      create tt-seb.
      assign
        tt-seb.DATAS = x-Date-End
        tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
        tt-seb.TOVAR = string(tt-gds-list.gds-code, "99999999999")
        tt-seb.KODVO = "spi-prvo"
        tt-seb.NAMEA = obj-list.obj-name
        tt-seb.NAMET = tt-gds-list.gds-name
        tt-seb.POLUCH = ""
        tt-seb.NAMEP = ""
      .
    end.
    assign tt-seb.chk-qnty = tt-seb.chk-qnty + buf_doc-line.fact-qnty .
    find last buf_ot-line where  buf_ot-line.doc-code    = buf_trn-doc.doc-code       and
                                  buf_ot-line.artic        =  buf_doc-line.artic                and
                                  buf_ot-line.prod-code    =  buf_doc-line.prod-code            and
                                  buf_ot-line.prod-type    =  buf_doc-line.prod-type            and
                                  buf_ot-line.obj-code     =  obj-list.obj-code      and
                                  buf_ot-line.obj-type     =  obj-list.obj-type      and
                                  buf_ot-line.sum-type     = 'cost':U use-index pi no-lock no-error.
    assign
      v-vat-pc = if available buf_ot-line then (buf_ot-line.vat-rubl / (buf_ot-line.sum-rubl - buf_ot-line.vat-rubl)) else 0
      tt-seb.SUMMA = tt-seb.SUMMA + (buf_doc-line.fact-qnty * buf_doc-line.price-rubl / (1 + v-vat-pc))
    .
  end.
  for each buf_trn-doc no-lock where  buf_trn-doc.shift-date    >=  x-Date-Start
                                 and  buf_trn-doc.shift-date    <=  x-Date-End
                                 and  buf_trn-doc.obj-type      =   obj-list.obj-type
                                 and  buf_trn-doc.obj-code      =   obj-list.obj-code
                                 and  buf_trn-doc.status_       =   'факт':U
                                 and  buf_trn-doc.ext-doc-type  =   'vp':U,
  each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
                              and buf_doc-line.fact-qnty < 0,
  first tt-gds-list no-lock where tt-gds-list.artic     = buf_doc-line.artic
                              and tt-gds-list.prod-type = buf_doc-line.prod-type
                              and tt-gds-list.prod-code = buf_doc-line.prod-code:
    find first ub.recipe no-lock where
               ub.recipe.prod-type = buf_doc-line.prod-type
           and ub.recipe.prod-code = buf_doc-line.prod-code
           and ub.recipe.artic     = buf_doc-line.artic
           and
             (
             ( ub.recipe.obj-type  = obj-list.obj-type
           and ub.recipe.obj-code  = obj-list.obj-code
             )
            or
             ( ub.recipe.obj-type  = "":U
           and ub.recipe.obj-code  = 0
             )
             )
           no-error.
    if available ub.recipe
    then do :
      find first ub.parts-root no-lock where ub.parts-root.doc-code = buf_trn-doc.doc-code
                                         and ub.parts-root.orig-gds-code = tt-gds-list.gds-code
                                         no-error .
      if available ub.parts-root
      then do :
        for each buf_tt-seb exclusive-lock where buf_tt-seb.DATAS = x-Date-End
                                             and buf_tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                             and buf_tt-seb.TOVAR = string(ub.parts-root.orig-gds-code, "99999999999") :
          find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                             and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                             and  tt-seb.TOVAR = string(ub.parts-root.gds-code, "99999999999")
                                             and  tt-seb.KODVO = buf_tt-seb.KODVO
                                             no-error .
          if available tt-seb
          then do :
            find first ub.goods no-lock where ub.goods.gds-code = ub.parts-root.gds-code .
            find first buf2_doc-line no-lock where buf2_doc-line.doc-code   = buf_doc-line.doc-code
                                               and buf2_doc-line.artic      = ub.goods.artic
                                               and buf2_doc-line.prod-type  = ub.goods.prod-type
                                               and buf2_doc-line.prod-code  = ub.goods.prod-code
                                               and buf2_doc-line.fact-qnty >= 0
                                               no-error .
            if available buf2_doc-line
            then do :
              find first ub.parts no-lock where ub.parts.artic      = buf2_doc-line.artic
                                            and ub.parts.prod-type  = buf2_doc-line.prod-type
                                            and ub.parts.prod-code  = buf2_doc-line.prod-code
                                            and ub.parts.in-code    = buf_trn-doc.doc-code
                                            and ub.parts.out-code   = 'out-zone':U
                                            no-error .
              if available ub.parts
              then do :
                assign
                  buf_tt-seb.chk-qnty = buf_tt-seb.chk-qnty + ((abs(buf_doc-line.fact-qnty) / buf2_doc-line.fact-qnty) * ub.parts.fact-qnty)
                  buf_tt-seb.SUMMA = buf_tt-seb.SUMMA + (tt-seb.SUMMA * (ub.parts.fact-qnty / tt-seb.chk-qnty))
                  tt-seb.chk-qnty = tt-seb.chk-qnty - ub.parts.fact-qnty
                  tt-seb.SUMMA = tt-seb.SUMMA - (tt-seb.SUMMA * (ub.parts.fact-qnty / tt-seb.chk-qnty))
                .
              end .
            end .
          end .
        end .
      end .
    end .
  end .
  for each buf_tt-seb no-lock where buf_tt-seb.KODVO <> "spi-prvo" :
    for each tt-fbr no-lock where tt-fbr.comp-gds-code = integer(buf_tt-seb.TOVAR) :
      find first tt-seb exclusive-lock where  tt-seb.DATAS = x-Date-End
                                         and  tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                         and  tt-seb.TOVAR = string(tt-fbr.ingr-gds-code, "99999999999")
                                         and  tt-seb.KODVO = buf_tt-seb.KODVO
                                         no-error .
      if not available tt-seb
      then do :
        create tt-seb.
        assign
          tt-seb.DATAS = x-Date-End
          tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
          tt-seb.TOVAR = string(tt-fbr.ingr-gds-code, "99999999999")
          tt-seb.KODVO = buf_tt-seb.KODVO
          tt-seb.NAMEA = obj-list.obj-name
          tt-seb.NAMET = tt-fbr.ingr-gds-name
          tt-seb.POLUCH = ""
          tt-seb.NAMEP = ""
        .
      end .
      find first buf2_tt-seb no-lock where  buf2_tt-seb.DATAS = x-Date-End
                                       and  buf2_tt-seb.AZS   = string(obj-list.obj-code, "99999999999")
                                       and  buf2_tt-seb.TOVAR = string(tt-fbr.ingr-gds-code, "99999999999")
                                       and  buf2_tt-seb.KODVO = "spi-prvo"
                                       no-error .
      if available buf2_tt-seb
      then do :
        assign
          tt-seb.SUMMA = tt-seb.SUMMA + (buf2_tt-seb.SUMMA * buf_tt-seb.chk-qnty / buf2_tt-seb.chk-qnty * (tt-fbr.inqr-qnty / tt-fbr.comp-qnty))
        .
      end.
    end.
  end.
  end.
end procedure.
procedure make-dbf :
  define input parameter p-tt-hndl as handle .
end.
procedure dbflib-write-dbf :
define input parameter p-filename       as character        no-undo.
define input parameter p-record-amount  as integer          no-undo.
    define variable v-date          as date         no-undo.
    define variable v-string-value  as character    no-undo.
    define variable raw-value       as raw          no-undo.
    define variable v-record-count  as integer      no-undo.
    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
on error undo, return error
:
    output stream dbf-stream to value( p-filename ) binary convert target 'IBM866'.
    put stream dbf-stream
        control "~003":U
    .
    run dbflib-makebinary (
          input year( today ) - 2000
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
        month( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input day( today )
        , input 1
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input p-record-amount
        , input 4
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input ( 32 + 32 * v-field-amount + 1 )
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    run dbflib-makebinary (
          input v-dbflib-reclength + 1
        , input 2
        , output raw-value
    ).
    put stream dbf-stream control raw-value.
    put stream dbf-stream control null( 20 ).
    for each buf_temp_dbflib_field use-index col_
    :
        put stream dbf-stream control
            buf_temp_dbflib_field.dbfield-name
            null( 11 - length( buf_temp_dbflib_field.dbfield-name ) )
        .
        case buf_temp_dbflib_field.data-type:
            when "character":U
            then do:
                put stream dbf-stream "C".
            end.
            when "integer":U
            or when "decimal"
            then do:
                put stream dbf-stream "N".
            end.
            when "logical":U
            then do:
                put stream dbf-stream "L".
            end.
            when "date":U
            then do:
                put stream dbf-stream "D".
            end.
            otherwise do:
                undo, return error substitute("Unknown field type for &1: &2",
                                                buf_temp_dbflib_field.field-handle:name,
                                                buf_temp_dbflib_field.data-type).
            end.
        end case.
        put stream dbf-stream control
            null( 4 )
            chr( buf_temp_dbflib_field.field-length )
        .
        if buf_temp_dbflib_field.field-decimals = 0
        then do:
            put stream dbf-stream control null.
        end.
        else do:
            put stream dbf-stream control
                chr( buf_temp_dbflib_field.field-decimals )
            .
        end.
        put stream dbf-stream control
            null(2)
            chr(1)
            null(11)
       .
    end.
    put stream dbf-stream control
        chr(13)
    .
    do v-record-count = 1 to p-record-amount
    on error undo, return error
    :
        for each buf_temp_dbflib_data
           where buf_temp_dbflib_data.record-number = v-record-count use-index col_
        :
            put stream dbf-stream
                " "
            .
            find first buf_temp_dbflib_field
            where buf_temp_dbflib_field.field-name = buf_temp_dbflib_data.field-name
            no-error.
            if available buf_temp_dbflib_field
            then do:
                case buf_temp_dbflib_field.data-type
                :
                    when "logical":U
                    then do:
                        put stream dbf-stream unformatted
                            ( if buf_temp_dbflib_data.data-value = "yes":U
                            then "T":U
                            else "F":U )
                        .
                    end.
                    when "date":U
                    then do:
                        assign
                            v-date = date( buf_temp_dbflib_data.data-value )
                        .
                        put stream dbf-stream unformatted
                            year( v-date )
                            month( v-date ) format "99"
                            day( v-date ) format "99"
                        .
                    end.
                    when "decimal":U
                    or when "integer":U
                    then do:
                        if session:numeric-format = "EUROPEAN":U
                        then do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ), ".":U, "":U )
                                v-string-value = replace( v-string-value, ",":U, ".":U )
                            .
                        end.
                        else do:
                            assign
                                v-string-value = replace( string( buf_temp_dbflib_data.data-value ),",","")
                            .
                        end.
                        put stream dbf-stream unformatted
                            v-string-value
                            fill( " ":U, buf_temp_dbflib_field.field-length - 1 - length( v-string-value ) )
                        .
                    end.
                    otherwise do:
                        put stream dbf-stream unformatted
                            string( buf_temp_dbflib_data.data-value )
                            fill( " ", buf_temp_dbflib_field.field-length - 1 - length( string( buf_temp_dbflib_data.data-value ) ) )
                        .
                    end.
                end case.
            end.
        end.
    end.
    output stream dbf-stream close.
end.
end procedure.
PROCEDURE dbflib-makebinary:
define input parameter anumm#     as integer      no-undo.
define input parameter abyte#     as integer      no-undo.
define output parameter raw-value as raw          no-undo.
    define variable acoun#    as integer      no-undo.
do
on error undo, return error
:
    assign
        length( raw-value ) = abyte#
    .
    if anumm# <0
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": This routine works for positive integers only."
            skip "Received value of" anumm# "is invalid."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    if anumm# > 0
    and anumm# modulo anumm# / EXP( anumm#, abyte#) > 256
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip ": received number" anumm#
            skip "does not fit in" abyte# "bytes."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error
        title "Conversion to binary".
        undo, return error .
    end.
    do acoun# = abyte# to 1 by -1
    on error undo, return error
    :
        put-byte( raw-value, acoun# ) = int( truncate( anumm# / EXP( 256, acoun# - 1 ), 0 ) ).
        if anumm# ne 0
        then do:
            assign
                anumm# = anumm# modulo EXP( 256, acoun# - 1 )
            .
        end.
    end.
end.
END PROCEDURE.
procedure dbflib-init :
    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
    define buffer buf_temp_dbflib_data     for temp_dbflib_data.
do
for buf_temp_dbflib_field
  , buf_temp_dbflib_data
:
    empty temp-table buf_temp_dbflib_field.
    empty temp-table buf_temp_dbflib_data.
    assign
        v-dbflib-reclength = 0
        v-field-amount     = 0
    .
end.
end procedure.
procedure dbflib-add-field :
define input parameter p-col-num        as integer          no-undo.
define input parameter p-field-name     as character        no-undo.
define input parameter p-field-length   as integer          no-undo.
define input parameter p-data-type      as character        no-undo.
define input parameter p-field-decimals as integer          no-undo.
    define buffer buf_temp_dbflib_field    for temp_dbflib_field.
do
for buf_temp_dbflib_field
on error undo, return error
:
    find first buf_temp_dbflib_field
         where buf_temp_dbflib_field.field-name       = p-field-name
    no-error.
    if not available buf_temp_dbflib_field
    then do:
        create buf_temp_dbflib_field.
        assign
            buf_temp_dbflib_field.col-num          = p-col-num
            buf_temp_dbflib_field.field-name       = p-field-name
            buf_temp_dbflib_field.field-length     = p-field-length
            buf_temp_dbflib_field.data-type        = p-data-type
            buf_temp_dbflib_field.field-decimals   = p-field-decimals
            buf_temp_dbflib_field.dbfield-name     = caps( replace( substring( p-field-name, 1, 11 ), "-":U, "_":U ) )
            v-dbflib-reclength                     = v-dbflib-reclength + buf_temp_dbflib_field.field-length
            v-field-amount                         = v-field-amount + 1
        .
    end.
end.
end procedure.
procedure dbflib-add-data :
define input parameter p-col-num        as integer          no-undo.
define input parameter p-record-number  as integer          no-undo.
define input parameter p-field-name     as character        no-undo.
define input parameter p-data-value     as character        no-undo.
    define buffer buf_temp_dbflib_data      for temp_dbflib_data.
do
for buf_temp_dbflib_data
on error undo, return error
:
    find first buf_temp_dbflib_data
         where buf_temp_dbflib_data.record-number  = p-record-number
           and buf_temp_dbflib_data.field-name     = p-field-name
    no-error.
    if not available buf_temp_dbflib_data
    then do:
        create buf_temp_dbflib_data.
        assign
            buf_temp_dbflib_data.col-num        = p-col-num
            buf_temp_dbflib_data.record-number  = p-record-number
            buf_temp_dbflib_data.field-name     = p-field-name
            buf_temp_dbflib_data.data-value     = p-data-value
        .
    end.
end.
end procedure.
