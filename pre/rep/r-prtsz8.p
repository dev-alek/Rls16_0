block-level on error undo, throw.
DEFINE TEMP-TABLE tt-season NO-UNDO LIKE season.
define input parameter x-store-code like clients.obj-code no-undo.
define input parameter x-store-type like clients.obj-type no-undo.
define input parameter x-base-type  like currency.curr-abbr no-undo.
define input parameter x-base-code  like currency.curr-code no-undo.
define input parameter classify  as int no-undo.
define input parameter p-zero as logical no-undo .
define input parameter p-zero-ost as logical no-undo .
define input parameter Itog as logical no-undo .
define input parameter p-tog-obj as logical   no-undo .
define input PARAMETER TABLE FOR tt-season .
define input parameter p-prizn      as  character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запасы по признакам".
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
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  x-Date-End
  ,input  v-cntxt-host-code-obj
  ,input  p-obj-type
  ,input  p-obj-code
  ,output i-vat-pc
  ) no-error .
if error-status :error then return 0 .
else return i-vat-pc.
end function .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pl-gds no-undo   like ub.pl-gds .
define temp-table temp-prt-obj no-undo   field prt-code         like ub.prt-obj.prt-code     field price-sale       like ub.prt-obj.price-sale   field fact-qnty        like ub.prt-obj.fact-qnty    field price-list-qnty  like ub.prt-obj.fact-qnty    field is-term          as logical   field prt-obj-recid    as recid     field price-list-recid as recid     index xpk is primary unique prt-code   index xie1 is-term .
procedure prdoclib-process-goods :
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define input  parameter p-artic             as character no-undo .
  define input  parameter p-prod-type         as character no-undo .
  define input  parameter p-prod-code         as integer   no-undo .
  define input  parameter p-check-price-list  as logical   no-undo .
  define input  parameter p-check-price-parts as logical   no-undo .
  define input  parameter p-doc-num           as character no-undo .
  define input  parameter p-fact-date         as date      no-undo .
  define input  parameter p-corr-user-db-num  as integer   no-undo .
  define input  parameter p-corr-user-name    as character no-undo .
  define input  parameter p-corr-date         as date      no-undo .
  define input  parameter p-corr-time         as integer   no-undo .
  define input  parameter p-corr-time-str     as character no-undo .
  define output parameter p-gds-obj-fact-qnty as decimal   no-undo .
  define variable vss-description as character no-undo initial "prdoclib-process-goods-01: обработка продажных цен товара".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_price-list   for ub.price-list .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-gds-code             like ub.goods.gds-code    no-undo .
  define variable v-root-node            like ub.prt-obj.prt-code  no-undo .
  define variable v-root-b-code          like ub.bar-code.b-code   no-undo .
  define variable v-total-term-fact-qnty like ub.prt-obj.fact-qnty no-undo .
  define variable v-total-fact-sale      like ub.gds-obj.fact-sale no-undo .
  define variable v-doc-num     like ub.price-list.doc-num    no-undo .
  define variable v-price-sale  like ub.price-list.price-sale no-undo .
  define variable v-road-tax    like ub.price-list.road-tax   no-undo .
  define variable v-excise      like ub.price-list.excise     no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  v-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при начале товародвижения товара на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find current buf_gds-obj  exclusive-lock .
    find current buf_prt-obj  exclusive-lock .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  v-root-node
  ,output v-root-b-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при определении цены признака на объекте" skip
        "Объект"     p-obj-type p-obj-code  skip
        "Бар-код"    v-root-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-price-sale
      ) .
    find first buf_price-list no-lock
      where buf_price-list.doc-num    = v-doc-num
        and buf_price-list.price-type = ""
        and buf_price-list.b-code     = v-root-b-code
      .
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.price-sale       = v-price-sale
      buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
      buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
    .
    define variable l-empty-scale as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при определении атрибута шкалы" skip
        "Код признака" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-total-term-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    if l-empty-scale = true
    then do:
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error return-value
      :
        if buf_price-list.doc-qnty <> ? and p-check-price-parts
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "Ошибка при закрытии переоценки" skip
            "Для неосновного бар-кода товара с пустой шкалой" skip
            "указано количество отличное от ?" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Количество" buf_price-list.doc-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    if l-empty-scale = false
    then do:
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" v-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if  available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" v-doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error .
          end.
          next .
        end.
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_price-list.b-code
          no-error .
        if not available buf_bar-code
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" v-doc-num skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.in-code <> ""
        or buf_bar-code.part-code <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "В переоценке задан бар-код партии" skip
            "Данная версия системы не рассчитана на работу со специальными ценами по партиям" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код ПН" buf_bar-code.in-code buf_bar-code.part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.node-code <> v-root-node
        then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_bar-code.node-code
  ,buffer buf_prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Невозможно найти prt-obj" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          run prdoclib-create-temp-prt-obj in this-procedure
            (input  v-price-sale
            ,buffer buf_prt-obj
            ,buffer buf_temp-prt-obj
            ).
          assign
            buf_temp-prt-obj.price-sale       = buf_price-list.price-sale
            buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
            buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
          .
        end.
      end.
      for each buf_temp-prt-obj
        where buf_temp-prt-obj.is-term = true
      :
        if buf_temp-prt-obj.price-list-recid <> ?
        then do:
          assign
            v-total-term-fact-qnty = v-total-term-fact-qnty
                                  + buf_temp-prt-obj.fact-qnty
            v-total-fact-sale = v-total-fact-sale
                              + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
          .
        end.
        if p-check-price-list = true
        then do:
          if buf_temp-prt-obj.price-list-recid = ?
          or buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.price-list-qnty
          then do:
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при закрытии переоценки" skip
              "Несовпадают текущие количества по признаку" skip
              "и количество признака в переоценке" skip
              "Переоценка" v-doc-num skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Код признака" buf_temp-prt-obj.prt-code skip
              "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
              "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
              "Корень шкалы товара" v-root-node skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                  - v-total-term-fact-qnty
    .
    if p-check-price-list = true
    then do:
      if buf_temp-prt-obj.fact-qnty <> buf_temp-prt-obj.price-list-qnty and p-check-price-parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при закрытии переоценки" skip
          "Несовпадают текущие количества по корневому признаку" skip
          "и количество признака в переоценке" skip
          "Переоценка" v-doc-num skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
          "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      v-total-fact-sale = v-total-fact-sale
                        + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
    .
    if v-total-fact-sale = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при вычислении суммы в продажных ценах" skip
        "Получено неопределенное значение" skip
        "Переоценка" v-doc-num skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код признака" buf_temp-prt-obj.prt-code skip
        "Сумма в продажных ценах" v-total-fact-sale skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-old-fact-qnty     as decimal   no-undo .
    define variable v-old-fact-cli-qnty as decimal   no-undo .
    define variable v-old-fact-base     as decimal   no-undo .
    define variable v-old-fact-rubl     as decimal   no-undo .
    define variable v-old-fact-sale     as decimal   no-undo .
    assign
      v-old-fact-qnty     = buf_gds-obj.fact-qnty
      v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
      v-old-fact-base     = buf_gds-obj.fact-base
      v-old-fact-rubl     = buf_gds-obj.fact-rubl
      v-old-fact-sale     = buf_gds-obj.fact-sale
    .
    assign
      buf_gds-obj.price-sale = v-price-sale
      buf_gds-obj.fact-sale  = v-total-fact-sale
    .
    define variable v-corr-date as date      no-undo .
    define variable v-corr-time as integer   no-undo .
    run cur-time in this-procedure
      (output v-corr-date
      ,output v-corr-time
      ) .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  'close':U
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'price-doc':U
  ,input  p-doc-num
  ,input  p-fact-date
  ,input  p-corr-user-db-num
  ,input  p-corr-user-name
  ,input  p-corr-date
  ,input  p-corr-time
  ,input  p-corr-time-str
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании истории по товару на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-obj-fact-qnty = buf_gds-obj.fact-qnty
    .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > p-fact-date then do:
  assign
    buf_gds-obj.first-doc  = p-fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < p-fact-date then do:
  assign
    buf_gds-obj.last-doc   = p-fact-date
  .
end.
    for each buf_temp-prt-obj
    ,first buf_prt-obj exclusive-lock
      where recid(buf_prt-obj) = buf_temp-prt-obj.prt-obj-recid
    on error undo, return error return-value
    :
      assign
        buf_prt-obj.price-sale = buf_temp-prt-obj.price-sale
      .
    end.
  end.
end procedure.
procedure prdoclib-clear-temp-prt-obj :
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
  end.
end procedure.
procedure prdoclib-create-temp-prt-obj :
  define input parameter  p-root-price-sale like ub.price-list.price-sale no-undo .
  define parameter buffer buf_prt-obj       for ub.prt-obj .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = buf_prt-obj.prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = buf_prt-obj.fact-qnty
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = recid(buf_prt-obj)
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = p-root-price-sale
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-temp-prt-obj-by-prt-root :
  define input parameter  p-prt-code like ub.prt-obj.prt-code no-undo .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = p-prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = p-prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = 0
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = ?
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = 0
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-init-temp-prt-obj :
  define input parameter p-obj-type        like ub.prt-obj.obj-type  no-undo .
  define input parameter p-obj-code        like ub.prt-obj.obj-code  no-undo .
  define input parameter p-artic           like ub.prt-obj.artic     no-undo .
  define input parameter p-prod-type       like ub.prt-obj.prod-type no-undo .
  define input parameter p-prod-code       like ub.prt-obj.prod-code no-undo .
  define input parameter p-root-price-sale like ub.prt-obj.price-sale no-undo .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-prt-obj in this-procedure .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
    on error undo, return error return-value
    :
      run prdoclib-create-temp-prt-obj in this-procedure
        (input  p-root-price-sale
        ,buffer buf_prt-obj
        ,buffer buf_temp-prt-obj
        ).
    end.
  end.
end procedure.
procedure prdoclib-calc-fact-sale :
  define input  parameter p-price-list-recid   as recid     no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_main_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_goods           for ub.goods .
  define buffer buf_gds-obj         for ub.gds-obj .
  define buffer buf_bar-code        for ub.bar-code .
  define variable l-empty-scale   as logical   no-undo .
  do
  on error undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )
  on stop undo, return error substitute(" stop &1 &2" , return-value , error-status :get-message(1)  )
  on end-key undo, return error substitute(" end-key &1 &2" , return-value , error-status :get-message(1)  )
  :
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )   .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )  .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_main_price-list.artic
        and buf_goods.prod-type = buf_main_price-list.prod-type
        and buf_goods.prod-code = buf_main_price-list.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Не найден товар" skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_main_price-list.artic
  ,input  buf_main_price-list.prod-type
  ,input  buf_main_price-list.prod-code
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        'empty-scale=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
    find first buf_gds-obj no-lock
      where buf_gds-obj.gds-code = buf_goods.gds-code
        and buf_gds-obj.obj-type = buf_main_price-list.obj-type
        and buf_gds-obj.obj-code = buf_main_price-list.obj-code
      no-error .
      if not available buf_gds-obj then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error then do:
           undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
      end.
    define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
    define variable price-base-with-tax-sale-prl    as decimal   no-undo .
    define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
    define variable price-base-without-tax-sale-prl as decimal   no-undo .
    define variable vat-base-sale-prl               as decimal   no-undo .
    define variable vat-rubl-sale-prl               as decimal   no-undo .
    define variable vat-base-buyer-prl              as decimal   no-undo .
    define variable vat-rubl-buyer-prl              as decimal   no-undo .
    define variable slt-base-sale-prl               as decimal   no-undo .
    define variable slt-rubl-sale-prl               as decimal   no-undo .
    define variable road-tax-base-sale-prl          as decimal   no-undo .
    define variable road-tax-rubl-sale-prl          as decimal   no-undo .
    define variable excise-base-sale-prl            as decimal   no-undo .
    define variable excise-rubl-sale-prl            as decimal   no-undo .
    define variable discnt-base-sale-prl            as decimal   no-undo .
    define variable discnt-rubl-sale-prl            as decimal   no-undo .
    if buf_main_price-list.doc-qnty <> 0
    then do:
      run prl-vat in this-procedure
        (input  recid(buf_main_price-list)
        ,output price-rubl-with-tax-sale-prl
        ,output price-base-with-tax-sale-prl
        ,output price-rubl-without-tax-sale-prl
        ,output price-base-without-tax-sale-prl
        ,output vat-base-sale-prl
        ,output vat-rubl-sale-prl
        ,output vat-base-buyer-prl
        ,output vat-rubl-buyer-prl
        ,output slt-base-sale-prl
        ,output slt-rubl-sale-prl
        ,output road-tax-base-sale-prl
        ,output road-tax-rubl-sale-prl
        ,output excise-base-sale-prl
        ,output excise-rubl-sale-prl
        ,output discnt-base-sale-prl
        ,output discnt-rubl-sale-prl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при вызове процеды prl-vat" skip
          "Документ" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
    end.
    else do:
      assign
        price-rubl-with-tax-sale-prl    = 0
        price-base-with-tax-sale-prl    = 0
        price-rubl-without-tax-sale-prl = 0
        price-base-without-tax-sale-prl = 0
        vat-base-sale-prl               = 0
        vat-rubl-sale-prl               = 0
        vat-base-buyer-prl              = 0
        vat-rubl-buyer-prl              = 0
        slt-base-sale-prl               = 0
        slt-rubl-sale-prl               = 0
        road-tax-base-sale-prl          = 0
        road-tax-rubl-sale-prl          = 0
        excise-base-sale-prl            = 0
        excise-rubl-sale-prl            = 0
        discnt-base-sale-prl            = 0
        discnt-rubl-sale-prl            = 0
      .
    end.
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-base-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-base-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
    else do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-rubl-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-rubl-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  buf_goods.gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
      for each buf_price-list no-lock
        where buf_price-list.doc-num    = buf_main_price-list.doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = buf_main_price-list.artic
          and buf_price-list.prod-type  = buf_main_price-list.prod-type
          and buf_price-list.prod-code  = buf_main_price-list.prod-code
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" buf_main_price-list.doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
          next .
        end.
        if not can-find
          (first buf_bar-code
          where buf_bar-code.b-code = buf_price-list.b-code
          )
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" buf_price-list.doc-num skip
            "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
        if buf_price-list.doc-qnty <> 0
        then do:
          run prl-vat in this-procedure
            (input  recid(buf_price-list)
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info16 skip
              "Ошибка при вызове процеды prl-vat" skip
              "Документ" buf_price-list.doc-num skip
              "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
            price-rubl-without-tax-sale-prl = 0
            price-base-without-tax-sale-prl = 0
            vat-base-sale-prl               = 0
            vat-rubl-sale-prl               = 0
            vat-base-buyer-prl              = 0
            vat-rubl-buyer-prl              = 0
            slt-base-sale-prl               = 0
            slt-rubl-sale-prl               = 0
            road-tax-base-sale-prl          = 0
            road-tax-rubl-sale-prl          = 0
            excise-base-sale-prl            = 0
            excise-rubl-sale-prl            = 0
            discnt-base-sale-prl            = 0
            discnt-rubl-sale-prl            = 0
          .
        end.
        if v-curr-r-b = 'base':U
        then do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-base-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-base-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-base-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-base-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-base-sale-prl * buf_price-list.doc-qnty
          .
        end.
        else do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-rubl-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-rubl-sale-prl * buf_price-list.doc-qnty
          .
        end.
      end.
  end.
end procedure.
procedure prdoclib-calc-prc :
  define input  parameter p-price-doc-recid as   recid                  no-undo.
  define input  parameter p-cons-pay        as   integer                no-undo.
  define output parameter p-ov-cons         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-prch         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-prch     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-prch     like ub.doc-line.price-base no-undo.
  do
  on error undo, return error return-value
  :
    define buffer buf_price-doc       for ub.price-doc .
    define buffer buf_price-list      for ub.price-list .
    define buffer buf_parts           for ub.parts .
    define variable v-ov-qnty     as decimal   no-undo .
    define variable v-ov-base     as decimal   no-undo .
    define variable v-ov-VAT-base as decimal   no-undo .
    define variable v-ov-SLT-base as decimal   no-undo .
    define variable v-cons-qnty   as decimal   no-undo .
    define variable v-prch-qnty   as decimal   no-undo .
    define variable v-cons-mult   as decimal   no-undo .
    define variable v-prch-mult   as decimal   no-undo .
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ переоценки" skip
        "Код записи (recid)" p-price-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error return-value
    :
      run prdoclib-calc-ov
        (input recid(buf_price-list)
        ,output v-ov-qnty
        ,output v-ov-base
        ,output v-ov-VAT-base
        ,output v-ov-SLT-base
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info16 skip
            "Ошибка при вызове процедуры prdoclib-calc-ov" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        v-cons-qnty = 0
        v-prch-qnty = 0
      .
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_price-list.doc-num
          and buf_parts.obj-type  = buf_price-list.obj-type
          and buf_parts.obj-code  = buf_price-list.obj-code
          and buf_parts.artic     = buf_price-list.artic
          and buf_parts.prod-type = buf_price-list.prod-type
          and buf_parts.prod-code = buf_price-list.prod-code
      on error undo, return error return-value
      :
        if buf_parts.pay-code = p-cons-pay
        then do:
          assign
            v-cons-qnty = v-cons-qnty + buf_parts.fact-qnty
          .
        end.
        else do:
          assign
            v-prch-qnty = v-prch-qnty + buf_parts.fact-qnty
          .
        end.
      end.
      if (v-cons-qnty + v-prch-qnty) = 0
      then do:
        assign
          v-cons-mult = 0
          v-prch-mult = 1
        .
      end.
      else do:
        assign
          v-cons-mult = v-cons-qnty / (v-cons-qnty + v-prch-qnty)
          v-prch-mult = v-prch-qnty / (v-cons-qnty + v-prch-qnty)
        .
      end.
      assign
        p-ov-cons     = p-ov-cons     + v-ov-base     * v-cons-mult
        p-ov-VAT-cons = p-ov-VAT-cons + v-ov-VAT-base * v-cons-mult
        p-ov-SLT-cons = p-ov-SLT-cons + v-ov-SLT-base * v-cons-mult
        p-ov-prch     = p-ov-prch     + v-ov-base     * v-prch-mult
        p-ov-VAT-prch = p-ov-VAT-prch + v-ov-VAT-base * v-prch-mult
        p-ov-SLT-prch = p-ov-SLT-prch + v-ov-SLT-base * v-prch-mult
      .
    end.
  end.
end procedure.
procedure prdoclib-calc-ov :
  define input  parameter p-price-list-recid as recid     no-undo .
  define output parameter p-fact-qnty        as decimal   no-undo .
  define output parameter p-ov-base          as decimal   no-undo .
  define output parameter p-ov-VAT-base      as decimal   no-undo .
  define output parameter p-ov-SLT-base      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_main_price-list    for ub.price-list .
    define buffer buf_prev_price-list    for ub.price-list .
    define buffer buf_special_price-list for ub.price-list .
    define buffer buf_goods              for ub.goods .
    define variable v-fact-qnty             like ub.doc-line.price-base no-undo.
    define variable v-cur-base              like ub.doc-line.price-base no-undo.
    define variable v-cur-VAT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-SLT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-road-tax-base     like ub.doc-line.price-base no-undo.
    define variable v-cur-excise-base       like ub.doc-line.price-base no-undo.
    define variable v-prev-price-list-recid as   recid                  no-undo.
    define variable v-prev-cli-base-rate    like ub.goods.cli-base-rate no-undo.
    define variable v-prev-fact-qnty        like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-base         like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-VAT-base     like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-SLT-base     like ub.doc-line.price-base no-undo.
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-calc-fact-sale in this-procedure
      (input  recid(buf_main_price-list)
      ,output v-fact-qnty
      ,output v-cur-base
      ,output v-cur-VAT-base
      ,output v-cur-SLT-base
      ,output v-cur-road-tax-base
      ,output v-cur-excise-base
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при расчете сумм переоценки." skip
        "Документ переоценки" buf_main_price-list.doc-num skip
        "Товар" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.fact-order
  ,output v-prev-price-list-recid
  ,output v-prev-cli-base-rate
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при поиске предыдущей переоценки." skip
        "Документ переоценки " buf_main_price-list.doc-num skip
        "Товар " buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-prev-price-list-recid <> ?
    then do:
      find first buf_prev_price-list no-lock
        where recid(buf_prev_price-list) = v-prev-price-list-recid
        .
      find first buf_special_price-list no-lock
        where buf_special_price-list.doc-num    = buf_prev_price-list.doc-num
          and buf_special_price-list.main-price = false
          and buf_special_price-list.artic      = buf_prev_price-list.artic
          and buf_special_price-list.prod-type  = buf_prev_price-list.prod-type
          and buf_special_price-list.prod-code  = buf_prev_price-list.prod-code
          and buf_special_price-list.doc-qnty   <> ?
        no-error .
      if available buf_special_price-list
      then do:
        message
          "Товар имеет специальные цены на признаки" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_main_price-list.artic
          and buf_goods.prod-type = buf_main_price-list.prod-type
          and buf_goods.prod-code = buf_main_price-list.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Не найден товар" skip
          "Переоценка" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      if buf_prev_price-list.vat-pc = ?
      or buf_prev_price-list.slt-pc = ?
      then do:
        message
          "В переоценке не заданы налоги товара" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          "НДС" buf_prev_price-list.vat-pc skip
          "НП" buf_prev_price-list.slt-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable v-prev-cur-SLT-pc as decimal no-undo .
      assign
        v-prev-cur-SLT-pc   = buf_prev_price-list.price-sale * buf_prev_price-list.slt-pc / (100 + buf_prev_price-list.slt-pc)
      .
      assign
        v-prev-cur-base     = v-fact-qnty * buf_prev_price-list.price-sale
        v-prev-cur-VAT-base = v-fact-qnty
                            * (buf_prev_price-list.price-sale - v-prev-cur-SLT-pc)
                            * buf_prev_price-list.vat-pc / (100 + buf_prev_price-list.vat-pc)
        v-prev-cur-SLT-base = v-fact-qnty * v-prev-cur-SLT-pc
      .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
    else do:
      assign
        v-prev-cur-base     = 0
        v-prev-cur-VAT-base = 0
        v-prev-cur-SLT-base = 0
        .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-total-gds-dtl-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input 0
      ) .
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.is-term <> true
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,output v-total-gds-dtl-qnty
        ) .
    end.
  end.
end procedure.
procedure prdoclib-process-document :
  define input  parameter p-doc-code           as character no-undo .
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define output parameter p-total-gds-dtl-qnty as decimal   no-undo .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-gds-dtl-qnty = 0
    .
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      define variable v-term-node as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output v-term-node
  )  .
      run prdoclib-temp-prt-obj-by-prt-root in this-procedure
        (input  v-term-node
        ,buffer buf_temp-prt-obj
        ) .
      if buf_temp-prt-obj.is-term <> true then do:
        undo, return error substitute("Документ ссылается на нетерминальный признак. Код признака &1"
                                     ,buf_gds-dtl.prt-code
                                     ) .
      end.
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.fact-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        + buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        + buf_gds-dtl.fact-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.doc-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.doc-qnty
          .
        end.
        otherwise do:
          undo, return error substitute("Неизвестный тип документа &1"
                                       ,buf_trn-doc.doc-type
                                       ) .
        end.
      end.
    end.
  end.
end procedure.
procedure prdoclib-prc-pl-document :
  define input  parameter p-doc-code              as character no-undo .
  define input  parameter p-obj-type              as character no-undo .
  define input  parameter p-obj-code              as integer   no-undo .
  define input  parameter p-gds-code              as integer   no-undo .
  define output parameter p-total-pl-gds-qnty     as decimal   no-undo .
  define output parameter p-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-pl       for ub.doc-pl .
    define buffer buf_temp-pl-gds for temp-pl-gds .
    define variable v-sign as decimal   no-undo .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Товар" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-pl-gds-qnty     = 0
      p-total-pl-gds-cli-qnty = 0
    .
    for each buf_doc-pl no-lock
      where buf_doc-pl.out-code  = p-doc-code
        and buf_doc-pl.gds-code  = p-gds-code
    on error undo, return error return-value
    :
      find first buf_temp-pl-gds
        where buf_temp-pl-gds.obj-type = buf_trn-doc.obj-type
          and buf_temp-pl-gds.obj-code = buf_trn-doc.obj-code
          and buf_temp-pl-gds.pl-code  = buf_doc-pl.pl-code
        .
      case buf_trn-doc.doc-type :
        when 'при':U
        or when 'возврат':U
        or when 'инв':U
        then do:
          assign
            v-sign = -1.0
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-sign = 1.0
          .
        end.
        otherwise do:
          undo, return error substitute("(prdoclib-prc-pl-document) Неизвестный тип документа &1", buf_trn-doc.doc-type ) .
        end.
      end case.
      assign
        p-total-pl-gds-qnty           = p-total-pl-gds-qnty           + buf_doc-pl.fact-qnty     * v-sign
        p-total-pl-gds-cli-qnty       = p-total-pl-gds-cli-qnty       + buf_doc-pl.cli-fact-qnty * v-sign
        buf_temp-pl-gds.fact-qnty     = buf_temp-pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-sign
        buf_temp-pl-gds.cli-fact-qnty = buf_temp-pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-sign
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-date :
  define input parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-date  as date      no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-date: определение остатков по признакам на конец дня".
  do
  on error undo, return error return-value
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-prt-obj-by-date-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info16 skip
        "Ошибка при вызове метода prdoclib-init-prt-obj-by-date-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure prdoclib-calc-temp-fact-sale :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-day-end-fact-order as decimal   no-undo .
  define input  parameter p-curr-r-b           as character no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-prt-b-code        like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo .
  define variable parrecid-prl        as recid     no-undo .
  define variable v-fact-qnty         as decimal   no-undo .
  define variable v-cur-base          as decimal   no-undo .
  define variable v-cur-VAT-base      as decimal   no-undo .
  define variable v-cur-SLT-base      as decimal   no-undo .
  define variable v-cur-road-tax-base as decimal   no-undo .
  define variable v-cur-excise-base   as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
  define variable price-base-with-tax-sale-prl    as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
  define variable price-base-without-tax-sale-prl as decimal   no-undo .
  define variable vat-base-sale-prl               as decimal   no-undo .
  define variable vat-rubl-sale-prl               as decimal   no-undo .
  define variable vat-base-buyer-prl              as decimal   no-undo .
  define variable vat-rubl-buyer-prl              as decimal   no-undo .
  define variable slt-base-sale-prl               as decimal   no-undo .
  define variable slt-rubl-sale-prl               as decimal   no-undo .
  define variable road-tax-base-sale-prl          as decimal   no-undo .
  define variable road-tax-rubl-sale-prl          as decimal   no-undo .
  define variable excise-base-sale-prl            as decimal   no-undo .
  define variable excise-rubl-sale-prl            as decimal   no-undo .
  define variable discnt-base-sale-prl            as decimal   no-undo .
  define variable discnt-rubl-sale-prl            as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj no-lock
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара"   p-gds-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  p-day-end-fact-order
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении цены бар-кода" skip
          "Объект" p-obj-type p-obj-code skip
          "Бар-код" v-prt-b-code skip
          "fact-order" p-day-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ?
      then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            "Указатель на запись переоценки" parrecid-prl skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.
      assign
        v-fact-qnty         = v-fact-qnty
                            + buf_temp-prt-obj.fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = 'base':U
                                then price-base-with-tax-sale-prl
                                else price-rubl-with-tax-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = 'base':U
                                then vat-base-sale-prl
                                else vat-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = 'base':U
                                then slt-base-sale-prl
                                else slt-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = 'base':U
                                then road-tax-base-sale-prl
                                else road-tax-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = 'base':U
                                then excise-base-sale-prl
                                else excise-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
      .
    end.
    assign
      p-fact-qnty         = v-fact-qnty
      p-cur-base          = v-cur-base
      p-cur-VAT-base      = v-cur-VAT-base
      p-cur-SLT-base      = v-cur-SLT-base
      p-cur-road-tax-base = v-cur-road-tax-base
      p-cur-excise-base   = v-cur-excise-base
    .
  end.
end procedure.
procedure prdoclib-clear-temp-pl-gds :
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-pl-gds
    on error undo, return error return-value
    :
      delete buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-temp-pl-gds :
  define input parameter p-obj-type        like ub.pl-gds.obj-type  no-undo .
  define input parameter p-obj-code        like ub.pl-gds.obj-code  no-undo .
  define input parameter p-gds-code        like ub.pl-gds.gds-code  no-undo .
  define buffer buf_pl-gds      for ub.pl-gds .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-pl-gds in this-procedure .
    for each buf_pl-gds
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-pl-gds .
      buffer-copy buf_pl-gds to buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-pl-gds-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-pl-gds-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_doc-line    for ub.doc-line .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define variable v-total-pl-gds-qnty     as decimal   no-undo .
  define variable v-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info16 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    run prdoclib-init-temp-pl-gds in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input buf_goods.gds-code
      ) .
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-prc-pl-document in this-procedure
        ( input  buf_doc-line.doc-code
         ,input  p-obj-type
         ,input  p-obj-code
         ,input  buf_goods.gds-code
         ,output v-total-pl-gds-qnty
         ,output v-total-pl-gds-cli-qnty
        ) .
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prl-vat:
  define input parameter parrecid as recid no-undo.
    define output parameter price-rubl-with-tax-saleprl    like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-with-tax-saleprl    like ub.doc-line.price-base no-undo.
    define output parameter price-rubl-without-tax-saleprl like ub.doc-line.price-rubl no-undo.
    define output parameter price-base-without-tax-saleprl like ub.doc-line.price-base no-undo.
    define output parameter vat-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter vat-base-buyerprl              like ub.doc-line.price-base no-undo.
    define output parameter vat-rubl-buyerprl              like ub.doc-line.price-rubl no-undo.
    define output parameter slt-base-saleprl               like ub.doc-line.price-base no-undo.
    define output parameter slt-rubl-saleprl               like ub.doc-line.price-rubl no-undo.
    define output parameter road-tax-base-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter road-tax-rubl-saleprl          like ub.doc-line.road-tax   no-undo.
    define output parameter excise-base-saleprl            like ub.doc-line.price-base no-undo.
    define output parameter excise-rubl-saleprl            like ub.doc-line.price-rubl no-undo.
    define output parameter discnt-base-saleprl            like ub.gds-dtl.discnt-base no-undo.
    define output parameter discnt-rubl-saleprl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlprl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlprl for ub.gds-dtl.
    define buffer out-vatp_partsprl       for ub.parts.
    define buffer out-vatp_sysconfprl     for ub.sysconf.
    define buffer out-vatp_doc-lineprl    for ub.doc-line.
    define buffer out-vatp_goodsprl       for ub.goods.
    define buffer out-vatp_trn-docprl     for ub.trn-doc.
    define buffer out-vatp_doc-attrprl    for ub.doc-attr.
    define variable varprice-base-consprl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-consprl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typeprl         as   character                           no-undo.
    define variable varfrm-cnsvprl              as   character                           no-undo.
    define variable varroot-nodeprl             as   integer                             no-undo.
    define variable varempty-scaleprl           as   logical                             no-undo.
    define variable varis-cons-parts-haveprl    as   logical                             no-undo.
    define variable varsum-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpprl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpprl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpprl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpprl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntyprl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlprl        as   logical                             no-undo.
    define variable varcurprlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurprldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbprl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltprl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-docoprl  for ub.trn-doc .
    define buffer   in-vatp-partsoprl    for ub.parts   .
    define buffer   in-vatp-docoprl      for ub.trn-doc .
    define buffer   in-vatp-goodsoprl    for ub.goods   .
    define buffer   in-vatp-sysconfoprl  for ub.sysconf .
    define buffer   in-vatp_doc-attroprl for ub.doc-attr.
    define variable in-vatp-have-vat-sltoprl       as   logical initial yes    no-undo.
    define variable vat-pc-locoprl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprboprl                  as   character              no-undo.
    define variable slt-pc-locoprl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateoprl              as   decimal                no-undo.
    define variable price-rubl-with-tax-locoprl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-locoprl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-locoprl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-locoprl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-locoprl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-locoprl  like ub.doc-line.price-base no-undo.
    define variable vat-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-locoprl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-locoprl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-locoprl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-locoprl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-locoprl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-locoprl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-locoprl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-locoprl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-locoprl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-locoprl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-locoprl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-locoprl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdoprl             as   character              no-undo.
    define variable varinvatp-typeoprl             as   character              no-undo.
  define buffer bf_price-list for ub.price-list.
  define buffer bf_goods      for ub.goods.
  define buffer bf_sysconf    for ub.sysconf.
  define buffer bf_parts      for ub.parts.
  define variable varbase-rate   like ub.trn-doc.base-rate     no-undo.
  define variable varbase-scale  like ub.trn-doc.base-scale    no-undo.
  define variable varroad-tax    like ub.price-list.road-tax   no-undo.
  define variable varexcise      like ub.price-list.excise     no-undo.
  define variable varvat-pc      like ub.doc-line.vat-pc       no-undo.
  define variable varslt-pc      like ub.doc-line.slt-pc       no-undo.
  define variable varprice-base  like ub.price-list.price-sale no-undo.
  define variable varprice-rubl  like ub.price-list.price-sale no-undo.
  define variable vardiscnt-base like ub.price-list.price-sale no-undo.
  define variable vardiscnt-rubl like ub.price-list.price-sale no-undo.
  define variable v-host-code    like ub.sysconf.host-code     no-undo.
  define variable vardoc-num     like ub.price-list.doc-num    no-undo.
  define variable vardoc-code    like ub.price-list.doc-num    no-undo.
  define variable varobj-type    like ub.price-list.obj-type   no-undo.
  define variable varobj-code    like ub.price-list.obj-code   no-undo.
  define variable varartic       like ub.price-list.artic      no-undo.
  define variable varprod-type   like ub.price-list.prod-type  no-undo.
  define variable varprod-code   like ub.price-list.prod-code  no-undo.
  define variable varfact-qnty   like ub.price-list.doc-qnty   no-undo.
  define variable varcons-vat-pc like ub.doc-line.vat-pc       no-undo.
  define variable varext-doc-type like ub.trn-doc.ext-doc-type no-undo.
  define variable vardoc-qnty     like ub.price-list.doc-qnty no-undo.
  define variable vardoc-type     as   character              no-undo.
  do
  on error undo, return error "Ошибка при вызове процедуры prl-vat."
  :
    find first bf_price-list no-lock
      where recid(bf_price-list) = parrecid
      no-error .
    if not available bf_price-list
    then do:
      return error "Ошибка во входящих параметрах prl-vat.i" .
    end.
    find first bf_goods no-lock
      where bf_goods.artic     = bf_price-list.artic
        and bf_goods.prod-type = bf_price-list.prod-type
        and bf_goods.prod-code = bf_price-list.prod-code
      no-error .
    if not available bf_goods
    then do:
      undo, return error substitute("Не найден товар &1 &2 &3 для переоценки с кодом &4",bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code,parrecid).
    end.
    assign
      varvat-pc = bf_price-list.vat-pc
      varslt-pc = bf_price-list.slt-pc
    .
    if varvat-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НДС",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    if varslt-pc = ?
    then do:
      undo, return error substitute("В переоценке &1 для товара &2 &3 &4 не задан НП",bf_price-list.doc-num,bf_price-list.artic,bf_price-list.prod-type,bf_price-list.prod-code).
    end.
    assign
      varbase-rate   = 1
      varbase-scale  = 1
      varroad-tax    = bf_price-list.road-tax
      varexcise      = bf_price-list.excise
      varprice-base  = bf_price-list.price-sale
      varprice-rubl  = bf_price-list.price-sale
      vardiscnt-base = 0
      vardiscnt-rubl = 0
    .
    assign
      varfact-qnty = 0
    .
    for each bf_parts no-lock
      where bf_parts.out-code   = bf_price-list.doc-num
        and bf_parts.obj-type   = bf_price-list.obj-type
        and bf_parts.obj-code   = bf_price-list.obj-code
        and bf_parts.artic      = bf_price-list.artic
        and bf_parts.prod-type  = bf_price-list.prod-type
        and bf_parts.prod-code  = bf_price-list.prod-code
    :
      assign
        varfact-qnty = varfact-qnty + bf_parts.fact-qnty
      .
    end.
    assign
      vardoc-num   = bf_price-list.doc-num
      vardoc-code  = bf_price-list.doc-num
      varobj-type  = bf_price-list.obj-type
      varobj-code  = bf_price-list.obj-code
      varartic     = bf_price-list.artic
      varprod-type = bf_price-list.prod-type
      varprod-code = bf_price-list.prod-code
      vardoc-qnty  = varfact-qnty
      varext-doc-type = 'ot':U
    .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  bf_price-list.obj-type
  ,input  bf_price-list.obj-code
  ,output v-host-code
  )  .
    find first bf_sysconf no-lock
      where bf_sysconf.host-code = v-host-code
      .
    if bf_sysconf.cons-vat-pc = ?
    then do:
      return error "Не задан консигнационный НДС по фирме." .
    end.
    else do:
      assign
        varcons-vat-pc = bf_sysconf.cons-vat-pc
      .
    end.
if varext-doc-type = 'ot':U or
   varext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltprl = yes.
end.
else do:
  find first out-vatp_doc-attrprl no-lock
    where out-vatp_doc-attrprl.doc-code  = vardoc-code
      and out-vatp_doc-attrprl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrprl then do:
    assign
      out-vatp-have-vat-sltprl = yes.
  end.
  else do:
     out-vatp-have-vat-sltprl = no.
  end.
end.
find first out-vatp_goodsprl where out-vatp_goodsprl.artic     = varartic     and
                                   out-vatp_goodsprl.prod-type = varprod-type and
                                   out-vatp_goodsprl.prod-code = varprod-code no-lock.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  varartic
  ,input  varprod-type
  ,input  varprod-code
  ,output varroot-nodeprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" varartic varprod-type varprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodeprl
  ,input  'empty-scale=request'
  ,output varempty-scaleprl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" varartic varprod-type varprod-code skip
    "Признак" varroot-nodeprl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbprl
  )  .
if varoutvprbprl = "base":u then do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-saleprl    =  (if varroad-tax = ? then 0 else varroad-tax / varbase-rate * varbase-scale)
    excise-base-saleprl      =  (if varexcise   = ? then 0 else varexcise   / varbase-rate * varbase-scale)
  .
end.
if varoutvprbprl = "rubl":u then do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * 1)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-saleprl    = (if varroad-tax = ? then 0 else varroad-tax * varbase-rate / varbase-scale)
    excise-rubl-saleprl      = (if varexcise   = ? then 0 else varexcise   * varbase-rate / varbase-scale) .
end.
assign
  varis-cons-parts-haveprl =  no.
assign
  varfact-qntyprl       = 0
  varcons-qntyprl       = 0
  varprice-base-consprl = 0
  varprice-rubl-consprl = 0.
find first out-vatp_doc-lineprl where
           out-vatp_doc-lineprl.doc-code   = vardoc-num
       and out-vatp_doc-lineprl.artic      = varartic
       and out-vatp_doc-lineprl.prod-type  = varprod-type
       and out-vatp_doc-lineprl.prod-code  = varprod-code no-lock no-error.
if available out-vatp_doc-lineprl           and
  (out-vatp_doc-lineprl.status_ = 'запрос':U or out-vatp_goodsprl.gds-type = 'у':U) then do:
  assign
    varfact-qntyprl = out-vatp_doc-lineprl.fact-qnty.
end.
else do:
  for each out-vatp_partsprl where out-vatp_partsprl.out-code   = vardoc-num
                               and out-vatp_partsprl.obj-type   = varobj-type
                               and out-vatp_partsprl.obj-code   = varobj-code
                               and out-vatp_partsprl.artic      = varartic
                               and out-vatp_partsprl.prod-type  = varprod-type
                               and out-vatp_partsprl.prod-code  = varprod-code no-lock :
    if out-vatp_partsprl.purch-code = 2 then do:
assign
  price-rubl-with-tax-locoprl = out-vatp_partsprl.price-rubl
  price-base-with-tax-locoprl = out-vatp_partsprl.price-base
.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprboprl
  )  .
  if out-vatp_partsprl.out-code = 'free-zone':U     or
     out-vatp_partsprl.out-code = 'out-zone':U   or
     out-vatp_partsprl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltoprl = yes.
  end.
  else do:
    find first in-vatp_doc-attroprl no-lock
      where in-vatp_doc-attroprl.doc-code  = out-vatp_partsprl.out-code
        and in-vatp_doc-attroprl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attroprl then do:
      assign
        in-vatp-have-vat-sltoprl = yes.
    end.
    else do:
         in-vatp-have-vat-sltoprl = no.
    end.
  end.
  assign
   price-cli-with-tax-locoprl = out-vatp_partsprl.price-cli
   cli-base-rateoprl          = out-vatp_partsprl.cli-base-rate.
  ASSIGN   road-tax-base-locoprl  = (if out-vatp_partsprl.road-tax-base  = ? then 0 else out-vatp_partsprl.road-tax-base)
           road-tax-rubl-locoprl  = (if out-vatp_partsprl.road-tax-rubl  = ? then 0 else out-vatp_partsprl.road-tax-rubl).
  ASSIGN  transport-base-locoprl = (if out-vatp_partsprl.transport-base = ? then 0 else out-vatp_partsprl.transport-base)
          transport-rubl-locoprl = (if out-vatp_partsprl.transport-rubl = ? then 0 else out-vatp_partsprl.transport-rubl)
          other-base-locoprl     = (if out-vatp_partsprl.other-base     = ? then 0 else out-vatp_partsprl.other-base)
          other-rubl-locoprl     = (if out-vatp_partsprl.other-rubl     = ? then 0 else out-vatp_partsprl.other-rubl)
          vat-pc-locoprl         = (if out-vatp_partsprl.vat-pc         = ? then 0 else out-vatp_partsprl.vat-pc)
          slt-pc-locoprl         = (if out-vatp_partsprl.slt-pc         = ? then 0 else out-vatp_partsprl.slt-pc).
          ASSIGN   slt-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-base-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-base-with-tax-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
    ASSIGN   slt-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl)))                           * slt-pc-locoprl / (100 + slt-pc-locoprl))                        vat-rubl-locoprl    = (if in-vatp-have-vat-sltoprl = no then 0 else (price-rubl-with-tax-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))) * (1 - slt-pc-locoprl / (100 + slt-pc-locoprl)) * vat-pc-locoprl / (100 + vat-pc-locoprl)).
  assign
    exch-rate-cli-locoprl = (out-vatp_partsprl.price-rubl - transport-rubl-locoprl - other-rubl-locoprl - road-tax-rubl-locoprl - (if out-vatp_partsprl.vat-type <> 'в т. ч.':U then vat-rubl-locoprl else 0) - (if out-vatp_partsprl.slt-type <> 'в т. ч.':U then slt-rubl-locoprl else 0)) / out-vatp_partsprl.price-cli .
  assign
    slt-cli-locoprl        = slt-rubl-locoprl       / exch-rate-cli-locoprl
    vat-cli-locoprl        = vat-rubl-locoprl       / exch-rate-cli-locoprl
    road-tax-cli-locoprl   = road-tax-rubl-locoprl  / exch-rate-cli-locoprl
    transport-cli-locoprl  = 0
    other-cli-locoprl      = 0
  .
ASSIGN
          price-base-without-tax-locoprl = price-base-with-tax-locoprl - vat-base-locoprl - slt-base-locoprl - ((if road-tax-base-locoprl  = ? then 0 else road-tax-base-locoprl) + (if transport-base-locoprl = ? then 0 else transport-base-locoprl) + (if other-base-locoprl = ? then 0 else other-base-locoprl))
    price-rubl-without-tax-locoprl = price-rubl-with-tax-locoprl - vat-rubl-locoprl - slt-rubl-locoprl - ((if road-tax-rubl-locoprl  = ? then 0 else road-tax-rubl-locoprl) + (if transport-rubl-locoprl = ? then 0 else transport-rubl-locoprl) + (if other-rubl-locoprl = ? then 0 else other-rubl-locoprl))
.
      assign
        varprice-base-consprl = varprice-base-consprl + (price-base-with-tax-locoprl - (if road-tax-base-locoprl = ? then 0 else road-tax-base-locoprl))* out-vatp_partsprl.fact-qnty
        varprice-rubl-consprl = varprice-rubl-consprl + (price-rubl-with-tax-locoprl - (if road-tax-rubl-locoprl = ? then 0 else road-tax-rubl-locoprl))* out-vatp_partsprl.fact-qnty.
      assign
        varis-cons-parts-haveprl = yes
        varcons-qntyprl          = varcons-qntyprl + out-vatp_partsprl.fact-qnty.
    end.
    assign
      varfact-qntyprl = varfact-qntyprl + out-vatp_partsprl.fact-qnty.
  end.
end.
assign
  varprice-base-consprl = varprice-base-consprl / varcons-qntyprl
  varprice-rubl-consprl = varprice-rubl-consprl / varcons-qntyprl.
if varprice-base-consprl = ? then do:
  assign
    varprice-base-consprl = 0.
end.
if varprice-rubl-consprl = ? then do:
  assign
    varprice-rubl-consprl = 0.
end.
assign
    slt-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-base-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-base-saleprl            = vardiscnt-base
  price-base-with-tax-saleprl    = (varprice-base - vardiscnt-base)
    slt-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc)
  vat-rubl-buyerprl              = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc)
  discnt-rubl-saleprl            = vardiscnt-rubl
  price-rubl-with-tax-saleprl    = (varprice-rubl - vardiscnt-rubl)
  .
if vardoc-type = 'инв':U then do:
  assign
    varfact-qntyprl = vardoc-qnty.
end.
else do:
  assign
    varfact-qntyprl = varfact-qnty.
end.
if varis-cons-parts-haveprl = no then do:
  assign
        vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc)
        vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc).
end.
else do:
  if vardoc-type = 'инв':U then do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * vardoc-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl) * varvat-pc / (100 + varvat-pc) * vardoc-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
  else do:
    assign
            vat-base-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-base-saleprl - varprice-base-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-base - vardiscnt-base) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-base - vardiscnt-base                - road-tax-base-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-base-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
            vat-rubl-saleprl               = (if out-vatp-have-vat-sltprl = no then 0 else (((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - road-tax-rubl-saleprl - varprice-rubl-consprl) * varcons-vat-pc / (100 + varcons-vat-pc) * varfact-qnty * varcons-qntyprl / varfact-qntyprl + ((varprice-rubl - vardiscnt-rubl) - (if out-vatp-have-vat-sltprl = no then 0 else varprice-rubl - vardiscnt-rubl                - road-tax-rubl-saleprl) * varSLT-pc / (100 + varSLT-pc) - varprice-rubl-consprl) * varvat-pc / (100 + varvat-pc) * varfact-qnty * (varfact-qntyprl - varcons-qntyprl) / varfact-qntyprl) / varfact-qntyprl)
     .
  end.
end.
assign
price-base-without-tax-saleprl = price-base-with-tax-saleprl - vat-base-saleprl - slt-base-saleprl - road-tax-base-saleprl
price-rubl-without-tax-saleprl = price-rubl-with-tax-saleprl - vat-rubl-saleprl - slt-rubl-saleprl - road-tax-rubl-saleprl.
  end.
end procedure.
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
define buffer clients-p for clients .
define buffer alt-ot-line for ot-line .
define buffer crsa-ot-line for ot-line .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_prt-obj for ub.prt-obj  .
define temp-table sl-obj-list no-undo like ub.clients .
define buffer buf_sl-obj-list for sl-obj-list .
define buffer buf_parts for ub.parts  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buff_doc-line for ub.doc-line  .
define buffer bufd_doc-line for ub.doc-line  .
define buffer buf_gds-dtl for ub.gds-dtl  .
define buffer bufd_gds-dtl for ub.gds-dtl  .
define buffer bufi_gds-dtl for ub.gds-dtl  .
define buffer bufi_trn-doc for ub.trn-doc  .
define variable  F-fact-date as char no-undo.
define variable tot-v-sale-sum as decimal no-undo init 0.
define variable tot-v-cost-sum as decimal no-undo init 0.
define temp-table t-trn-doc no-undo
field doc-code as character
index pi doc-code
.
define temp-table temp_gds-dtl no-undo like ub.gds-dtl
field cost-sum as decimal
field sale-sum as decimal
index pi doc-code
artic
prod-type
prod-code
prt-code
.
define variable  Fact-order-1 like stk-tot.Fact-order no-undo.
define variable  Quantity1    like stk-tot.fact-qnty  no-undo.
define variable  Coast1       like stk-tot.sum-rubl   no-undo.
define variable  Coast_R1       like stk-tot.sum-rubl   no-undo.
define variable  Coast_V1       like stk-tot.sum-rubl   no-undo.
define variable  VAT_R1         like stk-tot.sum-rubl   no-undo.
define variable  VAT_V1         like stk-tot.sum-rubl   no-undo.
define variable  SLT_R1         like stk-tot.sum-rubl   no-undo.
define variable  SLT_V1         like stk-tot.sum-rubl   no-undo.
define variable  Coast_R2       like stk-tot.sum-rubl   no-undo.
define variable  Coast_V2       like stk-tot.sum-rubl   no-undo.
define variable  VAT_R2         like stk-tot.sum-rubl   no-undo.
define variable  VAT_V2         like stk-tot.sum-rubl   no-undo.
define variable  Fact-order-2 like stk-tot.Fact-order no-undo.
define variable  Quantity2    like stk-tot.fact-qnty  no-undo.
define variable  Coast2       like stk-tot.sum-rubl   no-undo.
define variable  Quantity    like stk-tot.fact-qnty  no-undo.
define variable  Coast       like stk-tot.sum-rubl   no-undo.
define variable  Quantity3    like stk-tot.fact-qnty  no-undo.
define variable  Coast5       like stk-tot.sum-rubl   no-undo.
define variable  Coast6       like stk-tot.sum-rubl   no-undo.
define variable  Coast3         like stk-tot.sum-rubl   no-undo.
define variable  Coast4         like stk-tot.sum-rubl   no-undo.
define variable  find-str       as char no-undo.
define variable  temp-find-str  like find-str NO-UNDO.
define variable  tPrintRubl    as log no-undo .
define variable  startdate     as date no-undo.
define variable  enddate       as date no-undo.
define variable xTog-obj as logical no-undo .
define  stream  OutStream .
define variable    ObjName           as char no-undo.
define variable    PayType           as   integer no-undo.
define variable    ValType           as   integer no-undo.
define variable    Line              as  char     no-undo.
define variable v-var as character no-undo .
define variable tot_tqnty as decimal format "->>>,>>>,>>9.99" no-undo.
define variable break_group as logical no-undo init true.
define variable break_group1 as logical no-undo init true.
define variable    iI        as   integer no-undo.
define variable    i         as   integer no-undo .
define variable    j         as   integer no-undo.
define variable    K         as   integer no-undo.
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
define variable  Prtroot        like gds-prt.node-code no-undo.
define variable v-prizn as character no-undo.
v-prizn = p-prizn.
define variable    nn              as character no-undo .
define variable    f-artic         as character no-undo .
define variable    f-b-code        as character no-undo .
define variable    f-gds-name      as character no-undo .
define variable    f-prt-name      as character no-undo .
define variable    f-qnty          as decimal no-undo .
define variable    f-cost-sum      as decimal no-undo .
define variable    f-sale-sum      as decimal no-undo .
define variable    f-cost-pr      as decimal no-undo .
define variable    f-sale-pr      as decimal no-undo .
define variable    f-sale-other    as decimal no-undo .
define variable    f-free-qnty     as decimal no-undo .
define variable    f-wait-qnty     as decimal no-undo .
define variable f-rez-qnty    as decimal   no-undo .
define variable f-rez-cost    as decimal   no-undo .
define variable f-rez-sale    as decimal   no-undo .
define variable f-rez-cost-pr as decimal   no-undo .
define variable    c-nn             as WIDGET-HANDLE no-undo .
define variable    c-f-artic        as WIDGET-HANDLE no-undo .
define variable    c-f-b-code       as WIDGET-HANDLE no-undo .
define variable    c-f-gds-name     as WIDGET-HANDLE no-undo .
define variable    c-f-prt-name     as WIDGET-HANDLE no-undo .
define variable    c-f-qnty         as WIDGET-HANDLE no-undo .
define variable    c-f-cost-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-sum     as WIDGET-HANDLE no-undo .
define variable    c-f-cost-pr     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-pr     as WIDGET-HANDLE no-undo .
define variable    c-f-sale-other   as WIDGET-HANDLE no-undo .
define variable    c-f-free-qnty    as WIDGET-HANDLE no-undo .
define variable    c-f-wait-qnty    as WIDGET-HANDLE no-undo .
define variable c-f-rez-qnty    as WIDGET-HANDLE no-undo .
define variable c-f-rez-cost    as WIDGET-HANDLE no-undo .
define variable c-f-rez-sale    as WIDGET-HANDLE no-undo .
define variable c-f-rez-cost-pr as WIDGET-HANDLE no-undo .
define variable    p-qnty          as decimal no-undo .
define variable    p-cost-sum      as decimal no-undo .
define variable    p-sale-sum      as decimal no-undo .
define variable    p-cost-pr      as decimal no-undo .
define variable    p-sale-pr      as decimal no-undo .
define variable    p-sale-other    as decimal no-undo .
define variable    p-free-qnty     as decimal no-undo .
define variable    p-wait-qnty         as decimal no-undo .
define variable p-rez-qnty    as decimal no-undo .
define variable p-rez-cost    as decimal no-undo .
define variable p-rez-sale    as decimal no-undo .
define variable p-rez-cost-pr as decimal no-undo .
define variable    l1f-artic       as character no-undo .
define variable    l1f-b-code      as character no-undo .
define variable    l1f-gds-name    as character no-undo .
define variable    l1f-prt-name    as character no-undo .
define variable    l1f-qnty        as character no-undo .
define variable    l1f-cost-sum    as character no-undo .
define variable    l1f-sale-sum    as character no-undo .
define variable    l1f-cost-pr    as character no-undo .
define variable    l1f-sale-pr    as character no-undo .
define variable    l1f-sale-other  as character no-undo .
define variable    l1f-free-qnty    as character no-undo .
define variable    l1f-wait-qnty    as character no-undo .
define variable l1f-rez-qnty    as character no-undo .
define variable l1f-rez-cost    as character no-undo .
define variable l1f-rez-cost-pr    as character no-undo .
define variable l1f-rez-sale    as character no-undo .
define variable    l2f-artic         as character no-undo .
define variable    l2f-b-code        as character no-undo .
define variable    l2f-gds-name      as character no-undo .
define variable    l2f-prt-name      as character no-undo .
define variable    l2f-qnty          as character no-undo .
define variable    l2f-cost-sum      as character no-undo .
define variable    l2f-sale-sum      as character no-undo .
define variable    l2f-cost-pr      as character no-undo .
define variable    l2f-sale-pr      as character no-undo .
define variable l2f-rez-qnty    as character no-undo .
define variable l2f-rez-cost    as character no-undo .
define variable l2f-rez-sale    as character no-undo .
define variable    l2f-sale-other    as character no-undo .
define variable    l2f-free-qnty     as character no-undo .
define variable    l2f-wait-qnty      as character no-undo .
define variable l2f-rez-cost-pr    as character no-undo .
define variable    ff-f-qnty         as decimal no-undo .
define variable    ff-f-cost-sum     as decimal no-undo .
define variable    ff-f-sale-sum     as decimal no-undo .
define variable ff-f-rez-qnty    as decimal no-undo .
define variable ff-f-rez-cost    as decimal no-undo .
define variable ff-f-rez-sale    as decimal no-undo .
define variable    ff-f-sale-other   as decimal no-undo .
define variable    ff-f-free-qnty    as decimal no-undo .
define variable    ff-f-wait-qnty    as decimal no-undo .
define variable    tf-f-qnty        as decimal no-undo .
define variable    tf-f-cost-sum    as decimal no-undo .
define variable    tf-f-sale-sum     as decimal no-undo .
define variable    tf-f-sale-other   as decimal no-undo .
define variable    tf-f-free-qnty    as decimal no-undo .
define variable    tf-f-wait-qnty    as decimal no-undo .
define variable tf-f-rez-qnty    as decimal no-undo .
define variable tf-f-rez-cost    as decimal no-undo .
define variable tf-f-rez-sale    as decimal no-undo .
define variable x-time as integer no-undo .
define variable fix-doc-code  like ot-tot.doc-code no-undo .
define variable v-price-sale as decimal no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
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
x-Date-End     = x-date-alone.
x-Date-Start   = x-date-alone.
xTog-obj =  p-tog-obj .
if p-tog-obj = false then do:
    for each obj-list :
        create sl-obj-list .
        buffer-copy obj-list to sl-obj-list .
    end.
end.
run cur-time in this-procedure ( output v-today
                               , output x-time
                               ).
find last ot-tot  no-lock use-index pi no-error .
if available ot-tot then fix-doc-code = ot-tot.doc-code.
                 else fix-doc-code = "".
CREATE WIDGET-POOL "My-pool" PERSISTENT no-error .
l-row-pos = 1.
l-col-pos = 1.
Assign l-col-type="CHARACTER" l-col-len=9  l-col-format="X(9)"               l-col-lable="N/N"                      .
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
Assign l-col-type="CHARACTER" l-col-len=10 l-col-format="X(10)"              l-col-lable="Код"                      .
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
Assign l-col-type="CHARACTER" l-col-len=16 l-col-format="X(16)"              l-col-lable="Артикул"                  .
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
Assign l-col-type="CHARACTER" l-col-len=40 l-col-format="X(40)"              l-col-lable="Название товара"          .
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
Assign l-col-type="CHARACTER" l-col-len=20 l-col-format="X(20)"              l-col-lable="Признак"                  .
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
        CREATE FILL-IN C-f-prt-name IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Количество "              .
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Учетная цена"            .
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
        CREATE FILL-IN C-f-cost-pr IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Сумма в учетных ценах"    .
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Продажная цена"           .
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
        CREATE FILL-IN C-f-sale-pr IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="Сумма в продажных ценах"  .
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>9.99"    l-col-lable="% наценки"                .
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Свободное количество"     .
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
        CREATE FILL-IN C-f-free-qnty IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Ожидаемое Количество"     .
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
        CREATE FILL-IN C-f-wait-qnty IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Резерв Количество"        .
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
        CREATE FILL-IN C-f-rez-qnty IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Сумма в учетных ценах"    .
  def var ed15 as handle .
  def var s15 as handle .
  def var sf15 as handle .
  def var l-15 as handle .
  def var ll-15 as handle .
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
        CREATE FILL-IN C-f-rez-cost IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Сумма в ценах докум."     .
  def var ed16 as handle .
  def var s16 as handle .
  def var sf16 as handle .
  def var l-16 as handle .
  def var ll-16 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[16] = true then DO:
        CREATE EDITOR LL-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-rez-sale IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s16 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf16 IN WIDGET-POOL "My-pool"
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
Assign l-col-type="DECIMAL"   l-col-len=15 l-col-format="->>>>>>>>>>>>9.<<<" l-col-lable="Учетная цена резерва"     .
  def var ed17 as handle .
  def var s17 as handle .
  def var sf17 as handle .
  def var l-17 as handle .
  def var ll-17 as handle .
  if l-row-pos = 0 then l-row-pos = 1.
  if use-column[17] = true then DO:
        CREATE EDITOR LL-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR ed17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW =  l-row-pos + 1
            COLUMN = l-col-pos
            screen-value = l-col-lable
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE EDITOR L-17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos + 3
            COLUMN = l-col-pos
            screen-value = Fill("-", l-col-len)
            WIDTH-CHARS = l-col-len
            HEIGHT-CHARS = 3
        .
        CREATE FILL-IN C-f-rez-cost-pr IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME zapas:HANDLE
            DATA-TYPE = l-col-type
            FORMAT = l-col-format
            ROW = 1
            WIDTH-CHARS = l-col-len
            COLUMN = l-col-pos
        .
         if  (l-col-pos + l-col-len) <= 320 THEN DO:
        CREATE EDITOR s17 IN WIDGET-POOL "My-pool"
          ASSIGN
            FRAME = FRAME top-Frame:HANDLE
            ROW = l-row-pos
            COLUMN = (l-col-pos + l-col-len)
            screen-value = "::::"
            WIDTH-CHARS = 1
            HEIGHT-CHARS = 5
        .
        CREATE EDITOR sf17 IN WIDGET-POOL "My-pool"
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
  find first clients no-lock where
              clients.obj-type = x-store-type   and
              clients.obj-code = x-store-code
              no-error.
  if available clients then  objname = clients.obj-name.
                       else  objname = "объект не определен".
     assign
        i=0
        startdate     = x-date-start
        enddate       = x-date-end
        v-var         = string("no-today")
        paytype       = x-set_pay_type
        valtype       = if (paytype = 1) then 0  else x-set_val_type.
        Find first gds-prt where gds-prt.node-name = '_Пустая шкала':U no-lock no-error.
        If available  gds-prt then   Prtroot = gds-prt.prt-root.
                              Else   Prtroot = 0.
        run report-execute in this-procedure.
PROCEDURE report-execute :
  If (ValType=0 and x-base-code=0)  Or ValType=1
                                then   assign tPrintRubl = yes .
                                else   assign tPrintRubl = no .
   NO-PRISE = true .
  if  var-report-r-b = "rubl"  Then
    if  x-base-code <> 0 and ValType = 2  then NO-PRISE = false  .
  else
    if  x-base-code <> 0 and ValType = 1  then NO-PRISE = false  .
  If ReportPageHeight = 0 then ReportPageHeight = 43 .
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  FORM with FRAME Zapas .
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
form header
  line format "x(198)" at 1 skip
  "Продолжение - на следующей странице" at 30 skip
  with frame bottomframe width 232 page-bottom no-labels no-box .
view stream outstream frame bottomframe .
   Line = fill("-", 198).
  Run CalcItog in this-procedure.
  Run Print-Header in this-procedure.
  if p-tog-obj = true then do:
    CAse classify :
      when 1 then do:
      end.
      when 2 then do:
      end.
      when 3 then do:
      end.
      when 4 then do:
      end.
      when 5 then do:
        Run Foreach5 in this-procedure.
      end.
      when 6 then do:
        Run Foreach6 in this-procedure.
      end.
      when 7 then do:
        Run Foreach7 in this-procedure.
      end.
    End case.
  end.
  else do:
    case classify :
      when 1 then do:
      end.
      when 2 then do:
      end.
      when 3 then do:
      end.
      when 4 then do:
      end.
      end case.
 end.
  HIDE stream OutStream FRAME BottomFrame .
  Run  Print-footer in this-procedure.
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
   PUT stream OutStream  string(v-cntxt-host-name-obj +  " , " + x-store-type  +  " " + ObjName)
         AT 50 format "X(85)" SKIP(2)
         REPORTNAME
         AT 35  format "X(100)" skip.
     PUT stream OutStream   "на "  + string(x-date-start,"99/99/9999") +
         " время " +  string(x-time,"HH:MM:SS")  AT 35 format "X(160)" SKIP.
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
    run rep/extitle.p (1) .
    display STREAM OutStream     with frame top-Frame .
   END PROCEDURE.
PROCEDURE Print-Footer :
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  PUT STREAM OutStream UNFORMATTED " Печать закончена : " + string(v-time,"HH:MM:SS") SKIP.
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
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(ff) .
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
  if c-f-prt-name <>  ?  then do :
    c-f-prt-name:screen-value = string(ff) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string(ff)  .
End.
if c-f-cost-pr <>  ?  then do :
Assign
    l1f-cost-pr  = c-f-cost-pr:DATA-TYPE
    l2f-cost-pr  = c-f-cost-pr:FORMAT
    c-f-cost-pr:DATA-TYPE = "CHARACTER"
    c-f-cost-pr:FORMAT    = "x(" + string(C-f-cost-pr:WIDTH-CHARS) + ")"
    c-f-cost-pr:screen-value = string(ff)  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string(ff)  .
End.
if c-f-sale-pr <>  ?  then do :
Assign
    l1f-sale-pr  = c-f-sale-pr:DATA-TYPE
    l2f-sale-pr  = c-f-sale-pr:FORMAT
    c-f-sale-pr:DATA-TYPE = "CHARACTER"
    c-f-sale-pr:FORMAT    = "x(" + string(C-f-sale-pr:WIDTH-CHARS) + ")"
    c-f-sale-pr:screen-value = string(ff)  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string(ff)  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string(ff)  .
End.
if c-f-free-qnty <>  ?  then do :
Assign
    l1f-free-qnty  = c-f-free-qnty:DATA-TYPE
    l2f-free-qnty  = c-f-free-qnty:FORMAT
    c-f-free-qnty:DATA-TYPE = "CHARACTER"
    c-f-free-qnty:FORMAT    = "x(" + string(C-f-free-qnty:WIDTH-CHARS) + ")"
    c-f-free-qnty:screen-value = string(ff)  .
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    l1f-wait-qnty  = c-f-wait-qnty:DATA-TYPE
    l2f-wait-qnty  = c-f-wait-qnty:FORMAT
    c-f-wait-qnty:DATA-TYPE = "CHARACTER"
    c-f-wait-qnty:FORMAT    = "x(" + string(C-f-wait-qnty:WIDTH-CHARS) + ")"
    c-f-wait-qnty:screen-value = string(ff)  .
End.
if c-f-rez-qnty <>  ?  then do :
Assign
    l1f-rez-qnty  = c-f-rez-qnty:DATA-TYPE
    l2f-rez-qnty  = c-f-rez-qnty:FORMAT
    c-f-rez-qnty:DATA-TYPE = "CHARACTER"
    c-f-rez-qnty:FORMAT    = "x(" + string(C-f-rez-qnty:WIDTH-CHARS) + ")"
    c-f-rez-qnty:screen-value = string(ff)  .
End.
if c-f-rez-cost <>  ?  then do :
Assign
    l1f-rez-cost  = c-f-rez-cost:DATA-TYPE
    l2f-rez-cost  = c-f-rez-cost:FORMAT
    c-f-rez-cost:DATA-TYPE = "CHARACTER"
    c-f-rez-cost:FORMAT    = "x(" + string(C-f-rez-cost:WIDTH-CHARS) + ")"
    c-f-rez-cost:screen-value = string(ff)  .
End.
if c-f-rez-sale <>  ?  then do :
Assign
    l1f-rez-sale  = c-f-rez-sale:DATA-TYPE
    l2f-rez-sale  = c-f-rez-sale:FORMAT
    c-f-rez-sale:DATA-TYPE = "CHARACTER"
    c-f-rez-sale:FORMAT    = "x(" + string(C-f-rez-sale:WIDTH-CHARS) + ")"
    c-f-rez-sale:screen-value = string(ff)  .
End.
if c-f-rez-cost-pr <>  ?  then do :
Assign
    l1f-rez-cost-pr  = c-f-rez-cost-pr:DATA-TYPE
    l2f-rez-cost-pr  = c-f-rez-cost-pr:FORMAT
    c-f-rez-cost-pr:DATA-TYPE = "CHARACTER"
    c-f-rez-cost-pr:FORMAT    = "x(" + string(C-f-rez-cost-pr:WIDTH-CHARS) + ")"
    c-f-rez-cost-pr:screen-value = string(ff)  .
End.
  Display stream OutStream  with FRAME Zapas no-error .
  DOWN stream OutStream  with FRAME Zapas .
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
if c-f-cost-pr <>  ?  then do :
Assign
    c-f-cost-pr:DATA-TYPE = l1f-cost-pr
    c-f-cost-pr:FORMAT    = l2f-cost-pr.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-sale-pr <>  ?  then do :
Assign
    c-f-sale-pr:DATA-TYPE = l1f-sale-pr
    c-f-sale-pr:FORMAT    = l2f-sale-pr.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-free-qnty <>  ?  then do :
Assign
    c-f-free-qnty:DATA-TYPE = l1f-free-qnty
    c-f-free-qnty:FORMAT    = l2f-free-qnty.
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    c-f-wait-qnty:DATA-TYPE = l1f-wait-qnty
    c-f-wait-qnty:FORMAT    = l2f-wait-qnty.
End.
if c-f-rez-qnty <>  ?  then do :
Assign
    c-f-rez-qnty:DATA-TYPE = l1f-rez-qnty
    c-f-rez-qnty:FORMAT    = l2f-rez-qnty.
End.
if c-f-rez-cost <>  ?  then do :
Assign
    c-f-rez-cost:DATA-TYPE = l1f-rez-cost
    c-f-rez-cost:FORMAT    = l2f-rez-cost.
End.
if c-f-rez-sale <>  ?  then do :
Assign
    c-f-rez-sale:DATA-TYPE = l1f-rez-sale
    c-f-rez-sale:FORMAT    = l2f-rez-sale.
End.
if c-f-rez-cost-pr <>  ?  then do :
Assign
    c-f-rez-cost-pr:DATA-TYPE = l1f-rez-cost-pr
    c-f-rez-cost-pr:FORMAT    = l2f-rez-cost-pr.
End.
End.
END PROCEDURE.
PROCEDURE CalcItog :
run ostatok  in this-procedure (
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
    Quantity1  = 0.
    Coast_R1   = 0.
    Coast_V1   = 0.
    VAT_R1     = 0.
    VAT_V1     = 0.
run ostatok  in this-procedure (
    input x-store-code  ,
    input x-store-type  , x-TOG-Shift,
    input x-date-start ,
    input x-date-end   , x-Shift-Start,x-Shift-End,
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
procedure foreach5 :
  for each obj-list no-lock with FRAME Zapas :
          if NOT( classify = 1 and Itog = true) then dO:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
if c-f-cost-pr <>  ?  then do :
Assign
    l1f-cost-pr  = c-f-cost-pr:DATA-TYPE
    l2f-cost-pr  = c-f-cost-pr:FORMAT
    c-f-cost-pr:DATA-TYPE = "CHARACTER"
    c-f-cost-pr:FORMAT    = "x(" + string(C-f-cost-pr:WIDTH-CHARS) + ")"
    c-f-cost-pr:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-sale-pr <>  ?  then do :
Assign
    l1f-sale-pr  = c-f-sale-pr:DATA-TYPE
    l2f-sale-pr  = c-f-sale-pr:FORMAT
    c-f-sale-pr:DATA-TYPE = "CHARACTER"
    c-f-sale-pr:FORMAT    = "x(" + string(C-f-sale-pr:WIDTH-CHARS) + ")"
    c-f-sale-pr:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-free-qnty <>  ?  then do :
Assign
    l1f-free-qnty  = c-f-free-qnty:DATA-TYPE
    l2f-free-qnty  = c-f-free-qnty:FORMAT
    c-f-free-qnty:DATA-TYPE = "CHARACTER"
    c-f-free-qnty:FORMAT    = "x(" + string(C-f-free-qnty:WIDTH-CHARS) + ")"
    c-f-free-qnty:screen-value = string('')  .
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    l1f-wait-qnty  = c-f-wait-qnty:DATA-TYPE
    l2f-wait-qnty  = c-f-wait-qnty:FORMAT
    c-f-wait-qnty:DATA-TYPE = "CHARACTER"
    c-f-wait-qnty:FORMAT    = "x(" + string(C-f-wait-qnty:WIDTH-CHARS) + ")"
    c-f-wait-qnty:screen-value = string('')  .
End.
              Display stream OutStream no-error .
              DOWN stream OutStream .
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
if c-f-cost-pr <>  ?  then do :
Assign
    c-f-cost-pr:DATA-TYPE = l1f-cost-pr
    c-f-cost-pr:FORMAT    = l2f-cost-pr.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-sale-pr <>  ?  then do :
Assign
    c-f-sale-pr:DATA-TYPE = l1f-sale-pr
    c-f-sale-pr:FORMAT    = l2f-sale-pr.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-free-qnty <>  ?  then do :
Assign
    c-f-free-qnty:DATA-TYPE = l1f-free-qnty
    c-f-free-qnty:FORMAT    = l2f-free-qnty.
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    c-f-wait-qnty:DATA-TYPE = l1f-wait-qnty
    c-f-wait-qnty:FORMAT    = l2f-wait-qnty.
End.
              if Make-Excel then  put   stream ForExcel unformatted  obj-list.obj-name chr(10).
          end.
          n-nn = 0.
          n-no = n-no + 1 .
      for each tt-season no-lock with FRAME Zapas:
          if not ("no-classify" = "no-classify" and itog = true ) then do:
              put stream outstream tt-season.sea-name  at 1 format "x(160)" skip.  down stream outstream .
              if Make-Excel then  put   stream ForExcel unformatted tt-season.sea-name chr(10) .
          end.
              for each ub.gds-season no-lock where
                       ub.gds-season.db-num   = tt-season.db-num  and
                       ub.gds-season.sea-code = tt-season.sea-code ,
                  each ub.gds-obj no-lock where
                       ub.gds-obj.gds-code    = ub.gds-season.gds-code and
                       ub.gds-obj.obj-code    = obj-list.obj-code and
                       ub.gds-obj.obj-type    = obj-list.obj-type ,
                  each ub.goods no-lock where
                       ub.goods.gds-code    = ub.gds-season.gds-code and
                       ub.goods.gds-type   = 'т':U
                ,
                  each gds-list where
                      gds-list.gds-code = ub.gds-season.gds-code
                                  break
                                      by (ub.gds-season.gds-code ) by ub.goods.grp-name
                                      with FRAME Zapas :
                                    n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
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
                                    IF first-of(ub.gds-season.gds-code) then DO:
                                      assign
                                        f-qnty         = 0
                                        f-cost-sum     = 0
                                        f-sale-sum     = 0
                                        f-sale-other   = 0
                                        f-free-qnty    = 0
                                        f-wait-qnty    = 0
                                        .
                                    End.
                      if last-of(ub.gds-season.gds-code) then DO:
                                        IF v-var = "no-today" then DO:
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
                                                        input   0                 ,
                                                        INPUT   fact-order-2      ,
                                                        input   'crsa':U       ,
                                                        input   '##,##':U    ,
                                                        input   yes      ,
                                                        output  Quantity1   ,
                                                        output  Coast_R1  ,
                                                        output  Coast_V1  ,
                                                        output  VAT_R1    ,
                                                        output  VAT_V1    ,
                                                        output  SLT_R1    ,
                                                        output  SLT_V1     ).
                                                    Assign
                                                        f-qnty       = Quantity1
                                                        f-sale-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-sale-pr    = if f-qnty = 0 then 0 else  f-sale-sum  / f-qnty
                                                        .
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
                                                        input   0                 ,
                                                        INPUT   fact-order-2      ,
                                                        input   'cost':U       ,
                                                        input   '##,##':U    ,
                                                        input   yes      ,
                                                        output  Quantity1   ,
                                                        output  Coast_R1  ,
                                                        output  Coast_V1  ,
                                                        output  VAT_R1    ,
                                                        output  VAT_V1    ,
                                                        output  SLT_R1    ,
                                                        output  SLT_V1    ).
                                                    Assign
                                                        f-cost-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-cost-pr   = if Quantity1 = 0 then 0 else f-cost-sum / Quantity1
                                                        .
                                        end.
                                        else do:
                                                    Assign
                                                        f-qnty       = ub.gds-obj.fact-qnty
                                                        f-cost-sum   = determined(ub.gds-obj.fact-base)
                                                        f-sale-sum   = ub.gds-obj.fact-sale
                                                        f-free-qnty  = ub.gds-obj.free-qnty
                                                        f-cost-pr   = if f-qnty = 0 then 0 else f-cost-sum / f-qnty
                                                        f-sale-pr   = if f-qnty = 0 then 0 else f-sale-sum / f-qnty
                                                        .
                                        end.
                                    f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
                                    if c-f-wait-qnty <> ? Then DO :
                                      for each ub.trn-doc no-lock  where
                                          ub.trn-doc.obj-code        = obj-list.obj-code and
                                          ub.trn-doc.obj-type        = obj-list.obj-type and
                                          ub.trn-doc.status_         = 'накл':U           and
                                          ub.trn-doc.flag_           = true              and
                                          ub.trn-doc.Fact-order      <= fact-order-2     and
                                          ub.trn-doc.ext-doc-type    = 'ie':U :
                                          for each ub.doc-line no-lock where
                                              ub.doc-line.doc-code   = ub.trn-doc.doc-code   and
                                              ub.doc-line.artic      = ub.goods.artic        and
                                              ub.doc-line.prod-code  = ub.goods.prod-code    and
                                              ub.doc-line.prod-type  = ub.goods.prod-type    :
                                                  Assign
                                                    f-wait-qnty   = f-wait-qnty     + ub.doc-line.fact-qnty.
                                          end.
                                      End.
                                    End.
                                  if itog = false and
                                      not(f-qnty         = 0 and
                                          f-cost-sum     = 0 and
                                          f-sale-sum     = 0 and
                                          f-sale-other   = 0 and
                                          f-free-qnty    = 0 and
                                          f-wait-qnty    = 0  )
                                      Then DO:
                                          n-nn = n-nn + 1 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.gds-obj.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(ub.goods.gds-name) .
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
  if c-f-cost-pr <>  ?  then do :
    c-f-cost-pr:screen-value = string(f-cost-pr) .
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
  if c-f-sale-pr <>  ?  then do :
    c-f-sale-pr:screen-value = string(f-sale-pr) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                                          display stream OutStream  no-error .
                                          DOWN stream OutStream .
                                          if Make-Excel then  put   stream ForExcel unformatted
                                          string(n-nn)                      CHR(9)
                                          v-bar-code                        CHR(9)
                                          ub.gds-obj.artic                     CHR(9)
                                          ub.goods.gds-name                    CHR(9)
                                                                            CHR(9)
                                          excel-qnty(f-qnty        )        CHR(9)
                                          excel-sum (f-cost-pr     )        CHR(9)
                                          excel-sum (f-cost-sum    )        CHR(9)
                                          excel-sum (f-sale-pr     )        CHR(9)
                                          excel-sum (f-sale-sum    )        CHR(9)
                                          excel-sum (f-sale-other  )        CHR(9)
                                          excel-sum (f-free-qnty   )        CHR(9)
                                          excel-sum (f-wait-qnty   )        CHR(9)
                                          chr(10) .
                                          Run Display-prt in this-procedure  .
                                  End.
                                    accumulate f-qnty           (TOTAL ) .
                                    accumulate f-cost-sum       (TOTAL ) .
                                    accumulate f-sale-sum       (TOTAL ) .
                                    accumulate f-sale-other     (TOTAL ) .
                                    accumulate f-free-qnty      (TOTAL ) .
                                    accumulate f-wait-qnty      (TOTAL ) .
                                      Assign
                                        f-qnty          = 0
                                        f-cost-sum      = 0
                                        f-sale-sum      = 0
                                        f-sale-other    = 0
                                        f-free-qnty     = 0
                                        f-wait-qnty     = 0
                                      .
                                End.
                      End.
        run u-line in this-procedure.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string('коллекция') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(tt-season.sea-name) .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        Display stream OutStream no-error.
        DOWN stream OutStream .
        run u-line in this-procedure.
        if Make-Excel then  put   stream ForExcel unformatted
                "ИТОГО"                         CHR(9)
                "коллекция"                    CHR(9)
                tt-season.sea-name               CHR(9)  CHR(9)  CHR(9)
                excel-qnty(accum TOTAL f-qnty           )  CHR(9)
                CHR(9)
                excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
                CHR(9)
                excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
                excel-sum (accum TOTAL f-sale-other    )   CHR(9)
                excel-sum (accum TOTAL f-free-qnty     )   CHR(9)
                excel-sum (accum TOTAL f-wait-qnty     )   CHR(9)
                chr(10) .
      end.
      run u-line in this-procedure.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string('по объекту') .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        Display stream OutStream no-error.
        DOWN stream OutStream .
        run u-line in this-procedure.
        if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объекту"                    CHR(9)
          obj-list.obj-name               CHR(9)  CHR(9)  CHR(9)
          excel-qnty(accum TOTAL f-qnty           )  CHR(9)
          CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
          CHR(9)
          excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other    )   CHR(9)
          excel-sum (accum TOTAL f-free-qnty     )   CHR(9)
          excel-sum (accum TOTAL f-wait-qnty     )   CHR(9)
          chr(10) .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line in this-procedure.
         if Make-Excel then  put   stream ForExcel unformatted
         "ИТОГО"                       CHR(9)
         "ПО ВСЕМ ОБЬЕКТАМ"            CHR(9) CHR(9) CHR(9)  CHR(9)
         excel-qnty(accum TOTAL f-qnty           )   CHR(9)
         CHR(9)
         excel-sum (accum TOTAL f-cost-sum       )   CHR(9)
         CHR(9)
         excel-sum (accum TOTAL f-sale-sum       )   CHR(9)
         excel-sum (accum TOTAL f-sale-other     )   CHR(9)
         excel-sum (accum TOTAL f-free-qnty      )   CHR(9)
         excel-sum (accum TOTAL f-wait-qnty      )   CHR(9)
         chr(10) .
    End.
end procedure.
procedure foreach6 :
  for each obj-list no-lock with FRAME Zapas :
          if NOT( classify = 1 and Itog = true) then dO:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
if c-f-cost-pr <>  ?  then do :
Assign
    l1f-cost-pr  = c-f-cost-pr:DATA-TYPE
    l2f-cost-pr  = c-f-cost-pr:FORMAT
    c-f-cost-pr:DATA-TYPE = "CHARACTER"
    c-f-cost-pr:FORMAT    = "x(" + string(C-f-cost-pr:WIDTH-CHARS) + ")"
    c-f-cost-pr:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-sale-pr <>  ?  then do :
Assign
    l1f-sale-pr  = c-f-sale-pr:DATA-TYPE
    l2f-sale-pr  = c-f-sale-pr:FORMAT
    c-f-sale-pr:DATA-TYPE = "CHARACTER"
    c-f-sale-pr:FORMAT    = "x(" + string(C-f-sale-pr:WIDTH-CHARS) + ")"
    c-f-sale-pr:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-free-qnty <>  ?  then do :
Assign
    l1f-free-qnty  = c-f-free-qnty:DATA-TYPE
    l2f-free-qnty  = c-f-free-qnty:FORMAT
    c-f-free-qnty:DATA-TYPE = "CHARACTER"
    c-f-free-qnty:FORMAT    = "x(" + string(C-f-free-qnty:WIDTH-CHARS) + ")"
    c-f-free-qnty:screen-value = string('')  .
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    l1f-wait-qnty  = c-f-wait-qnty:DATA-TYPE
    l2f-wait-qnty  = c-f-wait-qnty:FORMAT
    c-f-wait-qnty:DATA-TYPE = "CHARACTER"
    c-f-wait-qnty:FORMAT    = "x(" + string(C-f-wait-qnty:WIDTH-CHARS) + ")"
    c-f-wait-qnty:screen-value = string('')  .
End.
              Display stream OutStream no-error .
              DOWN stream OutStream .
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
if c-f-cost-pr <>  ?  then do :
Assign
    c-f-cost-pr:DATA-TYPE = l1f-cost-pr
    c-f-cost-pr:FORMAT    = l2f-cost-pr.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-sale-pr <>  ?  then do :
Assign
    c-f-sale-pr:DATA-TYPE = l1f-sale-pr
    c-f-sale-pr:FORMAT    = l2f-sale-pr.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-free-qnty <>  ?  then do :
Assign
    c-f-free-qnty:DATA-TYPE = l1f-free-qnty
    c-f-free-qnty:FORMAT    = l2f-free-qnty.
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    c-f-wait-qnty:DATA-TYPE = l1f-wait-qnty
    c-f-wait-qnty:FORMAT    = l2f-wait-qnty.
End.
              if Make-Excel then  put   stream ForExcel unformatted  obj-list.obj-name chr(10).
          end.
          n-nn = 0.
          n-no = n-no + 1 .
      for each tt-season no-lock with FRAME Zapas:
          if not ("grp-goods" = "no-classify" and itog = true ) then do:
              put stream outstream tt-season.sea-name  at 1 format "x(160)" skip.  down stream outstream .
              if Make-Excel then  put   stream ForExcel unformatted tt-season.sea-name chr(10) .
          end.
              for each ub.gds-season no-lock where
                       ub.gds-season.db-num   = tt-season.db-num  and
                       ub.gds-season.sea-code = tt-season.sea-code ,
                  each ub.gds-obj no-lock where
                       ub.gds-obj.gds-code    = ub.gds-season.gds-code and
                       ub.gds-obj.obj-code    = obj-list.obj-code and
                       ub.gds-obj.obj-type    = obj-list.obj-type ,
                  each ub.goods no-lock where
                       ub.goods.gds-code    = ub.gds-season.gds-code and
                       ub.goods.gds-type   = 'т':U
                ,
                  each gds-list where
                      gds-list.gds-code = ub.gds-season.gds-code
                                  break
                                      by ub.goods.grp-name by (ub.gds-season.gds-code)
                                      with FRAME Zapas :
                                    n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
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
                                    IF first-of(ub.gds-season.gds-code) then DO:
                                      assign
                                        f-qnty         = 0
                                        f-cost-sum     = 0
                                        f-sale-sum     = 0
                                        f-sale-other   = 0
                                        f-free-qnty    = 0
                                        f-wait-qnty    = 0
                                        .
                                    End.
                                if first-of(ub.goods.grp-name) then  DO:
                                  var-client = ub.goods.grp-name.
                                        if  Itog = false Then do:
                                          PUT stream OutStream  ub.goods.grp-name  AT 1 format "X(160)" SKIP. DOWN stream OutStream .
                                          if Make-Excel then  put   stream ForExcel unformatted ub.goods.grp-name chr(10) .
                                        End.
                                End.
                      if last-of(ub.gds-season.gds-code) then DO:
                                        IF v-var = "no-today" then DO:
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
                                                        input   0                 ,
                                                        INPUT   fact-order-2      ,
                                                        input   'crsa':U       ,
                                                        input   '##,##':U    ,
                                                        input   yes      ,
                                                        output  Quantity1   ,
                                                        output  Coast_R1  ,
                                                        output  Coast_V1  ,
                                                        output  VAT_R1    ,
                                                        output  VAT_V1    ,
                                                        output  SLT_R1    ,
                                                        output  SLT_V1     ).
                                                    Assign
                                                        f-qnty       = Quantity1
                                                        f-sale-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-sale-pr    = if f-qnty = 0 then 0 else  f-sale-sum  / f-qnty
                                                        .
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
                                                        input   0                 ,
                                                        INPUT   fact-order-2      ,
                                                        input   'cost':U       ,
                                                        input   '##,##':U    ,
                                                        input   yes      ,
                                                        output  Quantity1   ,
                                                        output  Coast_R1  ,
                                                        output  Coast_V1  ,
                                                        output  VAT_R1    ,
                                                        output  VAT_V1    ,
                                                        output  SLT_R1    ,
                                                        output  SLT_V1    ).
                                                    Assign
                                                        f-cost-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-cost-pr   = if Quantity1 = 0 then 0 else f-cost-sum / Quantity1
                                                        .
                                        end.
                                        else do:
                                                    Assign
                                                        f-qnty       = ub.gds-obj.fact-qnty
                                                        f-cost-sum   = determined(ub.gds-obj.fact-base)
                                                        f-sale-sum   = ub.gds-obj.fact-sale
                                                        f-free-qnty  = ub.gds-obj.free-qnty
                                                        f-cost-pr   = if f-qnty = 0 then 0 else f-cost-sum / f-qnty
                                                        f-sale-pr   = if f-qnty = 0 then 0 else f-sale-sum / f-qnty
                                                        .
                                        end.
                                    f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
                                    if c-f-wait-qnty <> ? Then DO :
                                      for each ub.trn-doc no-lock  where
                                          ub.trn-doc.obj-code        = obj-list.obj-code and
                                          ub.trn-doc.obj-type        = obj-list.obj-type and
                                          ub.trn-doc.status_         = 'накл':U           and
                                          ub.trn-doc.flag_           = true              and
                                          ub.trn-doc.Fact-order      <= fact-order-2     and
                                          ub.trn-doc.ext-doc-type    = 'ie':U :
                                          for each ub.doc-line no-lock where
                                              ub.doc-line.doc-code   = ub.trn-doc.doc-code   and
                                              ub.doc-line.artic      = ub.goods.artic        and
                                              ub.doc-line.prod-code  = ub.goods.prod-code    and
                                              ub.doc-line.prod-type  = ub.goods.prod-type    :
                                                  Assign
                                                    f-wait-qnty   = f-wait-qnty     + ub.doc-line.fact-qnty.
                                          end.
                                      End.
                                    End.
                                  if itog = false and
                                      not(f-qnty         = 0 and
                                          f-cost-sum     = 0 and
                                          f-sale-sum     = 0 and
                                          f-sale-other   = 0 and
                                          f-free-qnty    = 0 and
                                          f-wait-qnty    = 0  )
                                      Then DO:
                                          n-nn = n-nn + 1 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.gds-obj.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(ub.goods.gds-name) .
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
  if c-f-cost-pr <>  ?  then do :
    c-f-cost-pr:screen-value = string(f-cost-pr) .
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
  if c-f-sale-pr <>  ?  then do :
    c-f-sale-pr:screen-value = string(f-sale-pr) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                                          display stream OutStream  no-error .
                                          DOWN stream OutStream .
                                          if Make-Excel then  put   stream ForExcel unformatted
                                          string(n-nn)                      CHR(9)
                                          v-bar-code                        CHR(9)
                                          ub.gds-obj.artic                     CHR(9)
                                          ub.goods.gds-name                    CHR(9)
                                                                            CHR(9)
                                          excel-qnty(f-qnty        )        CHR(9)
                                          excel-sum (f-cost-pr     )        CHR(9)
                                          excel-sum (f-cost-sum    )        CHR(9)
                                          excel-sum (f-sale-pr     )        CHR(9)
                                          excel-sum (f-sale-sum    )        CHR(9)
                                          excel-sum (f-sale-other  )        CHR(9)
                                          excel-sum (f-free-qnty   )        CHR(9)
                                          excel-sum (f-wait-qnty   )        CHR(9)
                                          chr(10) .
                                          Run Display-prt in this-procedure  .
                                  End.
                                    accumulate f-qnty           (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-cost-sum       (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-sale-sum       (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-sale-other     (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-free-qnty      (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-wait-qnty      (TOTAL  by ub.goods.grp-name ) .
                                      Assign
                                        f-qnty          = 0
                                        f-cost-sum      = 0
                                        f-sale-sum      = 0
                                        f-sale-other    = 0
                                        f-free-qnty     = 0
                                        f-wait-qnty     = 0
                                      .
                                End.
                                if last-of(ub.goods.grp-name)  then do :
                                  f-artic = 'по группе ' .
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
    c-f-gds-name:screen-value = string(var-client) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by ub.goods.grp-name  f-qnty    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by ub.goods.grp-name  f-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL by ub.goods.grp-name  f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by ub.goods.grp-name  f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL by ub.goods.grp-name  f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL by ub.goods.grp-name  f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                                    Display stream OutStream  no-error .
                                    DOWN stream OutStream .
                                    if Make-Excel then  put   stream ForExcel unformatted
                                    "Итого"                                              CHR(9)
                                    'по группе '                                                   CHR(9)
                                    var-client                                           CHR(9) CHR(9)  CHR(9)
                                    excel-qnty(accum TOTAL by ub.goods.grp-name  f-qnty           )    CHR(9)
                                    CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-cost-sum       )   CHR(9)
                                    CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-sale-sum       )   CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-sale-other     )   CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-free-qnty      )   CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-wait-qnty      )   CHR(9)
                                    chr(10) .
                                End.
                      End.
        run u-line in this-procedure.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string('коллекция') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(tt-season.sea-name) .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        Display stream OutStream no-error.
        DOWN stream OutStream .
        run u-line in this-procedure.
        if Make-Excel then  put   stream ForExcel unformatted
                "ИТОГО"                         CHR(9)
                "коллекция"                    CHR(9)
                tt-season.sea-name               CHR(9)  CHR(9)  CHR(9)
                excel-qnty(accum TOTAL f-qnty           )  CHR(9)
                CHR(9)
                excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
                CHR(9)
                excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
                excel-sum (accum TOTAL f-sale-other    )   CHR(9)
                excel-sum (accum TOTAL f-free-qnty     )   CHR(9)
                excel-sum (accum TOTAL f-wait-qnty     )   CHR(9)
                chr(10) .
      end.
      run u-line in this-procedure.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string('по объекту') .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        Display stream OutStream no-error.
        DOWN stream OutStream .
        run u-line in this-procedure.
        if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объекту"                    CHR(9)
          obj-list.obj-name               CHR(9)  CHR(9)  CHR(9)
          excel-qnty(accum TOTAL f-qnty           )  CHR(9)
          CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
          CHR(9)
          excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other    )   CHR(9)
          excel-sum (accum TOTAL f-free-qnty     )   CHR(9)
          excel-sum (accum TOTAL f-wait-qnty     )   CHR(9)
          chr(10) .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line in this-procedure.
         if Make-Excel then  put   stream ForExcel unformatted
         "ИТОГО"                       CHR(9)
         "ПО ВСЕМ ОБЬЕКТАМ"            CHR(9) CHR(9) CHR(9)  CHR(9)
         excel-qnty(accum TOTAL f-qnty           )   CHR(9)
         CHR(9)
         excel-sum (accum TOTAL f-cost-sum       )   CHR(9)
         CHR(9)
         excel-sum (accum TOTAL f-sale-sum       )   CHR(9)
         excel-sum (accum TOTAL f-sale-other     )   CHR(9)
         excel-sum (accum TOTAL f-free-qnty      )   CHR(9)
         excel-sum (accum TOTAL f-wait-qnty      )   CHR(9)
         chr(10) .
    End.
end procedure.
procedure foreach7 :
  for each obj-list no-lock with FRAME Zapas :
          if NOT( classify = 1 and Itog = true) then dO:
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(obj-list.obj-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
if c-f-qnty <>  ?  then do :
Assign
    l1f-qnty  = c-f-qnty:DATA-TYPE
    l2f-qnty  = c-f-qnty:FORMAT
    c-f-qnty:DATA-TYPE = "CHARACTER"
    c-f-qnty:FORMAT    = "x(" + string(C-f-qnty:WIDTH-CHARS) + ")"
    c-f-qnty:screen-value = string('')  .
End.
if c-f-cost-pr <>  ?  then do :
Assign
    l1f-cost-pr  = c-f-cost-pr:DATA-TYPE
    l2f-cost-pr  = c-f-cost-pr:FORMAT
    c-f-cost-pr:DATA-TYPE = "CHARACTER"
    c-f-cost-pr:FORMAT    = "x(" + string(C-f-cost-pr:WIDTH-CHARS) + ")"
    c-f-cost-pr:screen-value = string('')  .
End.
if c-f-cost-sum <>  ?  then do :
Assign
    l1f-cost-sum  = c-f-cost-sum:DATA-TYPE
    l2f-cost-sum  = c-f-cost-sum:FORMAT
    c-f-cost-sum:DATA-TYPE = "CHARACTER"
    c-f-cost-sum:FORMAT    = "x(" + string(C-f-cost-sum:WIDTH-CHARS) + ")"
    c-f-cost-sum:screen-value = string('')  .
End.
if c-f-sale-pr <>  ?  then do :
Assign
    l1f-sale-pr  = c-f-sale-pr:DATA-TYPE
    l2f-sale-pr  = c-f-sale-pr:FORMAT
    c-f-sale-pr:DATA-TYPE = "CHARACTER"
    c-f-sale-pr:FORMAT    = "x(" + string(C-f-sale-pr:WIDTH-CHARS) + ")"
    c-f-sale-pr:screen-value = string('')  .
End.
if c-f-sale-sum <>  ?  then do :
Assign
    l1f-sale-sum  = c-f-sale-sum:DATA-TYPE
    l2f-sale-sum  = c-f-sale-sum:FORMAT
    c-f-sale-sum:DATA-TYPE = "CHARACTER"
    c-f-sale-sum:FORMAT    = "x(" + string(C-f-sale-sum:WIDTH-CHARS) + ")"
    c-f-sale-sum:screen-value = string('')  .
End.
if c-f-sale-other <>  ?  then do :
Assign
    l1f-sale-other  = c-f-sale-other:DATA-TYPE
    l2f-sale-other  = c-f-sale-other:FORMAT
    c-f-sale-other:DATA-TYPE = "CHARACTER"
    c-f-sale-other:FORMAT    = "x(" + string(C-f-sale-other:WIDTH-CHARS) + ")"
    c-f-sale-other:screen-value = string('')  .
End.
if c-f-free-qnty <>  ?  then do :
Assign
    l1f-free-qnty  = c-f-free-qnty:DATA-TYPE
    l2f-free-qnty  = c-f-free-qnty:FORMAT
    c-f-free-qnty:DATA-TYPE = "CHARACTER"
    c-f-free-qnty:FORMAT    = "x(" + string(C-f-free-qnty:WIDTH-CHARS) + ")"
    c-f-free-qnty:screen-value = string('')  .
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    l1f-wait-qnty  = c-f-wait-qnty:DATA-TYPE
    l2f-wait-qnty  = c-f-wait-qnty:FORMAT
    c-f-wait-qnty:DATA-TYPE = "CHARACTER"
    c-f-wait-qnty:FORMAT    = "x(" + string(C-f-wait-qnty:WIDTH-CHARS) + ")"
    c-f-wait-qnty:screen-value = string('')  .
End.
              Display stream OutStream no-error .
              DOWN stream OutStream .
if c-f-qnty <>  ?  then do :
Assign
    c-f-qnty:DATA-TYPE = l1f-qnty
    c-f-qnty:FORMAT    = l2f-qnty.
End.
if c-f-cost-pr <>  ?  then do :
Assign
    c-f-cost-pr:DATA-TYPE = l1f-cost-pr
    c-f-cost-pr:FORMAT    = l2f-cost-pr.
End.
if c-f-cost-sum <>  ?  then do :
Assign
    c-f-cost-sum:DATA-TYPE = l1f-cost-sum
    c-f-cost-sum:FORMAT    = l2f-cost-sum.
End.
if c-f-sale-pr <>  ?  then do :
Assign
    c-f-sale-pr:DATA-TYPE = l1f-sale-pr
    c-f-sale-pr:FORMAT    = l2f-sale-pr.
End.
if c-f-sale-sum <>  ?  then do :
Assign
    c-f-sale-sum:DATA-TYPE = l1f-sale-sum
    c-f-sale-sum:FORMAT    = l2f-sale-sum.
End.
if c-f-sale-other <>  ?  then do :
Assign
    c-f-sale-other:DATA-TYPE = l1f-sale-other
    c-f-sale-other:FORMAT    = l2f-sale-other.
End.
if c-f-free-qnty <>  ?  then do :
Assign
    c-f-free-qnty:DATA-TYPE = l1f-free-qnty
    c-f-free-qnty:FORMAT    = l2f-free-qnty.
End.
if c-f-wait-qnty <>  ?  then do :
Assign
    c-f-wait-qnty:DATA-TYPE = l1f-wait-qnty
    c-f-wait-qnty:FORMAT    = l2f-wait-qnty.
End.
              if Make-Excel then  put   stream ForExcel unformatted  obj-list.obj-name chr(10).
          end.
          n-nn = 0.
          n-no = n-no + 1 .
           for each tt-season ,
                  each ub.gds-season no-lock where
                       ub.gds-season.sea-code = tt-season.sea-code and
                       ub.gds-season.db-num = tt-season.db-num ,
                  each ub.gds-obj no-lock where
                       ub.gds-obj.gds-code    = ub.gds-season.gds-code and
                       ub.gds-obj.obj-code    = obj-list.obj-code and
                       ub.gds-obj.obj-type    = obj-list.obj-type ,
                  each ub.goods no-lock where
                       ub.goods.gds-code    = ub.gds-season.gds-code and
                       ub.goods.gds-type   = 'т':U
                ,
                  each gds-list where
                      gds-list.gds-code = ub.gds-season.gds-code
                                  break
                                      by ub.goods.grp-name
                                      by ub.gds-season.db-num
                                      by ub.gds-season.sea-code
                                      by ub.gds-season.gds-code
                                      with FRAME Zapas :
                                  n-nm = n-nm + 1.
IF ( n-nm modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              n-nm @ RecordsDone
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
                                    IF first-of(gds-season.gds-code) then DO:
                                      assign
                                        f-qnty         = 0
                                        f-cost-sum     = 0
                                        f-sale-sum     = 0
                                        f-sale-other   = 0
                                        f-free-qnty    = 0
                                        f-wait-qnty    = 0
                                        .
                                    End.
                                if first-of(ub.goods.grp-name) then  DO:
                                  var-client = ub.goods.grp-name.
                                  PUT stream OutStream  ub.goods.grp-name  AT 1 format "X(160)" SKIP. DOWN stream OutStream .
                                  if Make-Excel then  put   stream ForExcel unformatted ub.goods.grp-name chr(10) .
                                End.
                                if first-of(gds-season.sea-code) then  DO:
                                  var-client = tt-season.sea-name.
                                        if  Itog = false Then do:
                                          PUT stream OutStream  tt-season.sea-name  AT 10 format "X(160)" SKIP. DOWN stream OutStream .
                                          if Make-Excel then  put   stream ForExcel unformatted CHR(9) tt-season.sea-name chr(10) .
                                        End.
                                End.
                      if last-of(gds-season.gds-code) then DO:
                                        IF v-var = "no-today" then DO:
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
                                                        input   0                 ,
                                                        INPUT   fact-order-2      ,
                                                        input   'crsa':U       ,
                                                        input   '##,##':U    ,
                                                        input   yes      ,
                                                        output  Quantity1   ,
                                                        output  Coast_R1  ,
                                                        output  Coast_V1  ,
                                                        output  VAT_R1    ,
                                                        output  VAT_V1    ,
                                                        output  SLT_R1    ,
                                                        output  SLT_V1     ).
                                                    Assign
                                                        f-qnty       = Quantity1
                                                        f-sale-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-sale-pr    = if f-qnty = 0  then 0 else f-sale-sum / f-qnty
                                                        .
                                                      RUN ost-line in this-procedure
                                                      (input   ub.gds-obj.obj-code  ,
                                                        input   ub.gds-obj.obj-type  ,
                                                        INPUT   ub.gds-obj.artic     ,
                                                        INPUT   ub.gds-obj.prod-code ,
                                                        INPUT   ub.gds-obj.prod-type ,
                                                        input   0                 ,
                                                        INPUT   fact-order-2      ,
                                                        input   'cost':U       ,
                                                        input   '##,##':U    ,
                                                        input   yes      ,
                                                        output  Quantity1   ,
                                                        output  Coast_R1  ,
                                                        output  Coast_V1  ,
                                                        output  VAT_R1    ,
                                                        output  VAT_V1    ,
                                                        output  SLT_R1    ,
                                                        output  SLT_V1    ).
                                                    Assign
                                                        f-cost-sum   = if tprintrubl then Coast_R1 else Coast_V1
                                                        f-cost-pr    = if Quantity1 = 0 then 0 else f-cost-sum / Quantity1
                                                        .
                                        end.
                                        else do:
                                                    Assign
                                                        f-qnty       = ub.gds-obj.fact-qnty
                                                        f-cost-sum   = determined(gds-obj.fact-base)
                                                        f-sale-sum   = ub.gds-obj.fact-sale
                                                        f-free-qnty  = ub.gds-obj.free-qnty
                                                        f-cost-pr    = if f-qnty = 0 then 0 else f-cost-sum / f-qnty
                                                        f-sale-pr    = if f-qnty = 0 then 0 else f-sale-sum / f-qnty
                                                     .
                                        end.
                                    f-sale-other = 100 * determined((f-sale-sum - f-cost-sum) / f-cost-sum).
                                    if c-f-wait-qnty <> ? Then DO :
                                      for each ub.trn-doc no-lock  where
                                          ub.trn-doc.obj-code        = obj-list.obj-code and
                                          ub.trn-doc.obj-type        = obj-list.obj-type and
                                          ub.trn-doc.status_         = 'накл':U           and
                                          ub.trn-doc.flag_           = true              and
                                          ub.trn-doc.Fact-order      <= fact-order-2     and
                                          ub.trn-doc.ext-doc-type    = 'ie':U :
                                          for each ub.doc-line no-lock where
                                              ub.doc-line.doc-code   = ub.trn-doc.doc-code   and
                                              ub.doc-line.artic      = ub.goods.artic        and
                                              ub.doc-line.prod-code  = ub.goods.prod-code    and
                                              ub.doc-line.prod-type  = ub.goods.prod-type    :
                                                  Assign
                                                    f-wait-qnty   = f-wait-qnty     + ub.doc-line.fact-qnty.
                                          end.
                                      End.
                                    End.
                                  if itog = false and
                                      not(f-qnty         = 0 and
                                          f-cost-sum     = 0 and
                                          f-sale-sum     = 0 and
                                          f-sale-other   = 0 and
                                          f-free-qnty    = 0 and
                                          f-wait-qnty    = 0  )
                                      Then DO:
                                          n-nn = n-nn + 1 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ub.goods.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string(string(n-nn)) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string(ub.gds-obj.artic) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(ub.goods.gds-name) .
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
  if c-f-cost-pr <>  ?  then do :
    c-f-cost-pr:screen-value = string(f-cost-pr) .
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
  if c-f-sale-pr <>  ?  then do :
    c-f-sale-pr:screen-value = string(f-sale-pr) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                                          display stream OutStream  no-error .
                                          DOWN stream OutStream .
                                          if Make-Excel then  put   stream ForExcel unformatted
                                          string(n-nn)                      CHR(9)
                                          v-bar-code                        CHR(9)
                                          ub.gds-obj.artic                     CHR(9)
                                          ub.goods.gds-name                    CHR(9)
                                                                            CHR(9)
                                          excel-qnty(f-qnty        )        CHR(9)
                                          excel-sum (f-cost-pr     )        CHR(9)
                                          excel-sum (f-cost-sum    )        CHR(9)
                                          excel-sum (f-sale-pr     )        CHR(9)
                                          excel-sum (f-sale-sum    )        CHR(9)
                                          excel-sum (f-sale-other  )        CHR(9)
                                          excel-sum (f-free-qnty   )        CHR(9)
                                          excel-sum (f-wait-qnty   )        CHR(9)
                                          chr(10) .
                                          Run Display-prt in this-procedure  .
                                  End.
                                    accumulate f-qnty           (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-cost-sum       (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-sale-sum       (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-sale-other     (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-free-qnty      (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-wait-qnty      (TOTAL  by ub.goods.grp-name ) .
                                    accumulate f-qnty           (TOTAL  by  ub.gds-season.sea-code) .
                                    accumulate f-cost-sum       (TOTAL  by  ub.gds-season.sea-code) .
                                    accumulate f-sale-sum       (TOTAL  by  ub.gds-season.sea-code) .
                                    accumulate f-sale-other     (TOTAL  by  ub.gds-season.sea-code) .
                                    accumulate f-free-qnty      (TOTAL  by  ub.gds-season.sea-code) .
                                    accumulate f-wait-qnty      (TOTAL  by  ub.gds-season.sea-code) .
                                      Assign
                                        f-qnty          = 0
                                        f-cost-sum      = 0
                                        f-sale-sum      = 0
                                        f-sale-other    = 0
                                        f-free-qnty     = 0
                                        f-wait-qnty     = 0
                                      .
                                End.
                                if last-of(gds-season.sea-code)  then do :
                                  if itog = false then run u-line in this-procedure.
                                  f-artic = "коллекция" .
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
    c-f-gds-name:screen-value = string(tt-season.sea-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by ub.gds-season.sea-code f-qnty      ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by ub.gds-season.sea-code f-cost-sum  ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL by ub.gds-season.sea-code f-sale-sum  ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by ub.gds-season.sea-code f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL by ub.gds-season.sea-code f-free-qnty ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL by ub.gds-season.sea-code f-wait-qnty ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                                    Display stream OutStream  no-error .
                                    DOWN stream OutStream .
                                    if Make-Excel then  put   stream ForExcel unformatted
                                    "Итого"                                              CHR(9)
                                    "коллекци "                                          CHR(9)
                                    tt-season.sea-name                                         CHR(9) CHR(9) CHR(9)
                                    excel-qnty(accum TOTAL by ub.gds-season.sea-code  f-qnty           )    CHR(9)
                                    CHR(9)
                                    excel-sum (accum TOTAL by ub.gds-season.sea-code  f-cost-sum       )   CHR(9)
                                    CHR(9)
                                    excel-sum (accum TOTAL by ub.gds-season.sea-code  f-sale-sum       )   CHR(9)
                                    excel-sum (accum TOTAL by ub.gds-season.sea-code  f-sale-other     )   CHR(9)
                                    excel-sum (accum TOTAL by ub.gds-season.sea-code  f-free-qnty      )   CHR(9)
                                    excel-sum (accum TOTAL by ub.gds-season.sea-code  f-wait-qnty      )   CHR(9)
                                    chr(10) .
                                    if itog = false then    run u-line in this-procedure.
                                End.
                                if last-of(ub.goods.grp-name)  then do :
                                  f-artic = "по группе" .
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('Итого') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('по группе') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-gds-name <>  ?  then do :
    c-f-gds-name:screen-value = string(ub.goods.grp-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(accum TOTAL by ub.goods.grp-name  f-qnty    ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL by ub.goods.grp-name  f-cost-sum ) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(accum TOTAL by ub.goods.grp-name  f-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL by ub.goods.grp-name  f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL by ub.goods.grp-name  f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL by ub.goods.grp-name  f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
                                    Display stream OutStream  no-error .
                                    DOWN stream OutStream .
                                    if Make-Excel then  put   stream ForExcel unformatted
                                    "Итого"                                              CHR(9)
                                    "по группе"                                             CHR(9)
                                    ub.goods.grp-name                                           CHR(9) CHR(9) CHR(9)
                                    excel-qnty(accum TOTAL by ub.goods.grp-name  f-qnty           )    CHR(9)
                                    CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-cost-sum       )   CHR(9)
                                    CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-sale-sum       )   CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-sale-other     )   CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-free-qnty      )   CHR(9)
                                    excel-sum (accum TOTAL by ub.goods.grp-name  f-wait-qnty      )   CHR(9)
                                    chr(10) .
                                    run u-line in this-procedure.
                                End.
      end.
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('ИТОГО') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string('по объекту') .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        Display stream OutStream no-error.
        DOWN stream OutStream .
        run u-line in this-procedure.
        if Make-Excel then  put   stream ForExcel unformatted
          "ИТОГО"                         CHR(9)
          "по объекту"                    CHR(9)
          obj-list.obj-name               CHR(9)  CHR(9)  CHR(9)
          excel-qnty(accum TOTAL f-qnty           )  CHR(9)
          CHR(9)
          excel-sum (accum TOTAL f-cost-sum       )  CHR(9)
          CHR(9)
          excel-sum (accum TOTAL f-sale-sum       )  CHR(9)
          excel-sum (accum TOTAL f-sale-other    )   CHR(9)
          excel-sum (accum TOTAL f-free-qnty     )   CHR(9)
          excel-sum (accum TOTAL f-wait-qnty     )   CHR(9)
          chr(10) .
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
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(accum TOTAL f-cost-sum) .
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
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(accum TOTAL f-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(accum TOTAL f-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(accum TOTAL f-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
        dIsplay stream OutStream with FRAME Zapas no-error .
        DOWN stream OutStream with FRAME Zapas.
      run u-line in this-procedure.
         if Make-Excel then  put   stream ForExcel unformatted
         "ИТОГО"                       CHR(9)
         "ПО ВСЕМ ОБЬЕКТАМ"            CHR(9) CHR(9) CHR(9)  CHR(9)
         excel-qnty(accum TOTAL f-qnty           )   CHR(9)
         CHR(9)
         excel-sum (accum TOTAL f-cost-sum       )   CHR(9)
         CHR(9)
         excel-sum (accum TOTAL f-sale-sum       )   CHR(9)
         excel-sum (accum TOTAL f-sale-other     )   CHR(9)
         excel-sum (accum TOTAL f-free-qnty      )   CHR(9)
         excel-sum (accum TOTAL f-wait-qnty      )   CHR(9)
         chr(10) .
    End.
end procedure.
procedure display-prt :
define variable pr-cursor as integer no-undo init 0.
define variable go-work   as logical no-undo init no.
define variable v-tmp-prt like gds-prt.node-code init -1.
IF goods.prt-root <> Prtroot Then DO:
    If v-var = "no-today"  then do:
run  prdoclib-init-prt-obj-by-factord in this-procedure
( input gds-obj.obj-type  ,
  input gds-obj.obj-code  ,
  input gds-obj.artic     ,
  input gds-obj.prod-type ,
  input gds-obj.prod-code ,
  input fact-order-2 ,
  input false ) .
    end.
  for each prt-obj where
      prt-obj.artic     = goods.artic     and
      prt-obj.prod-type = goods.prod-type and
      prt-obj.prod-code = goods.prod-code and
      prt-obj.obj-code  = obj-list.obj-code and
      prt-obj.obj-type  = obj-list.obj-type and
      prt-obj.is-term   =  true no-lock
      BREAK BY prt-obj.prt-code with FRAME Zapas :
      pr-cursor = 0.
      go-work = false.
      if v-prizn = "" then do:
        go-work = true.
      end.
      else do:
          do while pr-cursor < num-entries(v-prizn,","):
              pr-cursor = pr-cursor + 1.
              if entry(pr-cursor,v-prizn,",") <> "" then do:
                  if integer(entry(pr-cursor,v-prizn,",")) = prt-obj.prt-code then do:
                      pr-cursor = num-entries(v-prizn,",").
                      go-work = true.
                  end.
              end.
          end.
      end.
      if go-work then do:
          if v-var <> "no-today" then do:
              Assign
                p-qnty      = p-qnty       + prt-obj.fact-qnty
                p-free-qnty = p-free-qnty  + prt-obj.free-qnty
                p-sale-sum  = p-sale-sum   + prt-obj.fact-qnty * prt-obj.price-sale
                p-sale-pr   = if p-qnty = 0 then 0 else p-sale-sum / p-qnty
                .
          End.
          IF last-of(prt-obj.prt-code) THEN DO:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-obj.gds-code
  ,input  prt-obj.prt-code
  ,output v-bar-code
  )  .
              if v-var = "no-today" then do:
                find first temp-prt-obj no-lock
                     where temp-prt-obj.prt-obj-recid   = recid (prt-obj) no-error .
                     if avail temp-prt-obj then do :
                        run  calc-price-sale-for-prt in this-procedure  (output v-price-sale) .
                        Assign
                          p-qnty      = temp-prt-obj.fact-qnty
                          p-free-qnty = 0
                          p-sale-sum  = temp-prt-obj.fact-qnty * v-price-sale
                          p-sale-pr   = if p-qnty = 0 then 0 else p-sale-sum / p-qnty
                          .
                      End.
                      Else
                        Assign
                          p-qnty      = 0
                          p-free-qnty = 0
                          p-sale-sum  = 0   .
              End.
        FIND first gds-prt  where gds-prt.node-code = prt-obj.prt-code NO-LOCK no-error .
        if c-f-wait-qnty <> ? Then DO :
          for each trn-doc no-lock  where
              trn-doc.obj-code        = obj-list.obj-code and
              trn-doc.obj-type        = obj-list.obj-type and
              trn-doc.status_         = 'накл':U           and
              trn-doc.flag_           = true              and
              trn-doc.ext-doc-type    = 'ie':U :
              for each gds-dtl no-lock where
                  gds-dtl.doc-code   = trn-doc.doc-code   and
                  gds-dtl.artic      = goods.artic        and
                  gds-dtl.prod-code  = goods.prod-code    and
                  gds-dtl.prod-type  = goods.prod-type    and
                  gds-dtl.prt-code   = prt-obj.prt-code   and
                  gds-dtl.obj-code   = obj-list.obj-code  and
                  gds-dtl.obj-type   = obj-list.obj-type :
                  Assign
                  p-wait-qnty   = p-wait-qnty     + gds-dtl.fact-qnty.
              end.
          End.
        End.
        if ( f-rez-qnty <> ? or
            f-rez-cost <> ? or
            f-rez-sale <> ? ) and  v-var <> "no-today"
        then do:
              for each temp_gds-dtl where
                        temp_gds-dtl.prt-code   = prt-obj.prt-code  :
                  assign
                    p-rez-qnty = p-rez-qnty  + temp_gds-dtl.doc-qnty
                    p-rez-cost = p-rez-cost  + temp_gds-dtl.cost-sum
                    p-rez-sale = p-rez-sale  + temp_gds-dtl.sale-sum
                    p-rez-cost-pr = ( if p-rez-qnty = 0 then 0 else p-rez-cost / p-rez-qnty )
                  .
              end.
        end.
        Assign
        p-cost-sum     = determined( f-cost-sum * p-qnty  / f-qnty)
        p-sale-other   = 100 * determined((p-sale-sum - p-cost-sum) / p-cost-sum)
        p-cost-pr      = if p-qnty = 0 then 0 else p-cost-sum   / p-qnty
        .
        if not (p-zero = false  and
             (p-qnty        =  0  and
              p-cost-sum    =  0  and
              p-sale-sum    =  0  and
              p-sale-other  =  0  and
              p-free-qnty   =  0  and
                  p-wait-qnty  = 0  ) ) then do:
  if c-nn <>  ?  then do :
    c-nn:screen-value = string('') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-artic <>  ?  then do :
    c-f-artic:screen-value = string('') .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-b-code <>  ?  then do :
    c-f-b-code:screen-value = string(string(v-bar-code,'999999999')) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-prt-name <>  ?  then do :
    c-f-prt-name:screen-value = string(gds-prt.f-name) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-qnty <>  ?  then do :
    c-f-qnty:screen-value = string(p-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-pr <>  ?  then do :
    c-f-cost-pr:screen-value = string(p-cost-pr) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-cost-sum <>  ?  then do :
    c-f-cost-sum:screen-value = string(p-cost-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-pr <>  ?  then do :
    c-f-sale-pr:screen-value = string(p-sale-pr) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-sum <>  ?  then do :
    c-f-sale-sum:screen-value = string(p-sale-sum) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-sale-other <>  ?  then do :
    c-f-sale-other:screen-value = string(p-sale-other) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-free-qnty <>  ?  then do :
    c-f-free-qnty:screen-value = string(p-free-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-wait-qnty <>  ?  then do :
    c-f-wait-qnty:screen-value = string(p-wait-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-rez-qnty <>  ?  then do :
    c-f-rez-qnty:screen-value = string(p-rez-qnty) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-rez-cost <>  ?  then do :
    c-f-rez-cost:screen-value = string(p-rez-cost) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-rez-sale <>  ?  then do :
    c-f-rez-sale:screen-value = string(p-rez-sale) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
  if c-f-rez-cost-pr <>  ?  then do :
    c-f-rez-cost-pr:screen-value = string(p-rez-cost-pr) .
    IF ( line-counter( OutStream )  modulo page-size( OutStream ) = 0 ) AND
        ( line-counter( OutStream ) >= page-size( OutStream ) )          then DO:
        display STREAM OutStream    with frame top-frame .
    End.
  End.
            Display stream OutStream no-error.
            DOWN stream OutStream .
            if Make-Excel then  put   stream ForExcel unformatted
            CHR(9)
            string(v-bar-code,"999999999") CHR(9)
                         CHR(9)
                         CHR(9)
             gds-prt.f-name                    CHR(9)
             excel-qnty(p-qnty)                            CHR(9)
             excel-sum(p-cost-pr)                        CHR(9)
             excel-sum(p-cost-sum)                        CHR(9)
             excel-sum(p-sale-pr)                        CHR(9)
             excel-sum(p-sale-sum)                        CHR(9)
             excel-sum(p-sale-other)                      CHR(9)
             excel-sum(p-free-qnty)                       CHR(9)
            excel-sum(p-wait-qnty)   CHR(9)
            excel-sum(p-rez-qnty   ) CHR(9)
            excel-sum(p-rez-cost   ) CHR(9)
            excel-sum(p-rez-sale   ) CHR(9)
            excel-sum(p-rez-cost-pr) CHR(9)
            chr(10) .
        End.
        Assign
          p-qnty        =  0
          p-cost-sum    =  0
          p-sale-sum    =  0
          p-sale-other  =  0
          p-free-qnty   =  0
          p-wait-qnty   =  0
          p-rez-qnty     = 0
          p-rez-cost     = 0
          p-rez-sale     = 0
          p-rez-cost-pr  = 0
          .
    End.
  End.
  end.
End.
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
procedure ost-line :
  define input  parameter x-store-code like ub.clients.obj-code    no-undo .
  define input  parameter x-store-type like ub.clients.obj-type    no-undo .
  define input  parameter x-artic      like ub.stk-line.artic      no-undo .
  define input  parameter x-prod-code  like ub.stk-line.prod-code  no-undo .
  define input  parameter x-prod-type  like ub.stk-line.prod-type  no-undo .
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order no-undo .
  define input  parameter x-sum-type   like ub.stk-line.sum-type   no-undo .
  define input  parameter x-cat-id     like ub.stk-line.cat-id     no-undo .
  define input  parameter xtog-obj     as logical no-undo .
  define output parameter quantity     like ub.stk-line.fact-qnty  no-undo .
  define output parameter coast_r      like ub.stk-line.sum-rubl   no-undo .
  define output parameter coast_v      like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter vat_v        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_r        like ub.stk-line.sum-rubl   no-undo .
  define output parameter slt_v        like ub.stk-line.sum-rubl   no-undo .
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
    find last buff-stk-line no-lock
      where buff-stk-line.obj-type   = buff-obj-list.obj-type
        and buff-stk-line.obj-code   = buff-obj-list.obj-code
        and buff-stk-line.artic      = x-artic
        and buff-stk-line.prod-type  = x-prod-type
        and buff-stk-line.prod-code  = x-prod-code
        and buff-stk-line.sum-type   = x-sum-type
        and buff-stk-line.cat-id     = '##,##':U
        and buff-stk-line.fact-order <= x-fact-order
        and buff-stk-line.shift-num  = 0
      use-index category
      no-error .
    if available buff-stk-line then do:
      assign
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
      .
    end.
   end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-lineother-tax :
  define input  parameter x-store-code like ub.clients.obj-code      no-undo.
  define input  parameter x-store-type like ub.clients.obj-type      no-undo.
  define input  parameter x-artic      like ub.stk-line.artic        no-undo.
  define input  parameter x-prod-code  like ub.stk-line.prod-code    no-undo.
  define input  parameter x-prod-type  like ub.stk-line.prod-type    no-undo.
  define input  parameter x-tog-shift  as logical no-undo .
  define input  parameter x-fact-order like ub.stk-line.fact-order   no-undo.
  define input  parameter x-sum-type   like ub.stk-line.sum-type     no-undo.
  define input  parameter x-type-id    like ub.stk-line.cat-id       no-undo.
  define input  parameter xTog-obj     as logical no-undo .
  define output parameter Quantity     like ub.stk-line.fact-qnty   no-undo.
  define output parameter Coast_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter Coast_V      like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter VAT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_R        like ub.stk-line.sum-rubl    no-undo.
  define output parameter SLT_V        like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_R      like ub.stk-line.sum-rubl    no-undo.
  define output parameter other_V      like ub.stk-line.sum-rubl    no-undo.
  define buffer buff-obj-list  for obj-list .
  define buffer buff-stk-line  for ub.stk-line .
  assign
    Quantity = 0
    Coast_R  = 0
    Coast_V  = 0
    VAT_R    = 0
    VAT_V    = 0
    SLT_R    = 0
    SLT_V    = 0
    other_R  = 0
    other_V  = 0
  .
  if  x-tog-shift = false then do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
    find last buff-stk-line no-lock
      where buff-stk-line.obj-type   = buff-obj-list.obj-type
        and buff-stk-line.obj-code   = buff-obj-list.obj-code
        and buff-stk-line.artic      = x-artic
        and buff-stk-line.prod-type  = x-prod-type
        and buff-stk-line.prod-code  = x-prod-code
        and buff-stk-line.sum-type   = x-sum-type
        and buff-stk-line.cat-id     = '##,##':U
        and buff-stk-line.fact-order <= x-fact-order
        and buff-stk-line.shift-num  = 0
      use-index category
      no-error .
    if available buff-stk-line then do:
      assign
        Quantity = Quantity + buff-stk-line.fact-qnty
        Coast_R  = Coast_R  + buff-stk-line.sum-rubl
        Coast_V  = Coast_V  + buff-stk-line.sum-base
        VAT_R    = VAT_R    + buff-stk-line.VAT-rubl
        VAT_V    = VAT_V    + buff-stk-line.VAT-base
        SLT_R    = SLT_R    + buff-stk-line.SLT-rubl
        SLT_V    = SLT_V    + buff-stk-line.SLT-base
        other_R  = other_R  + buff-stk-line.other-rubl
        other_V  = other_V  + buff-stk-line.other-base
      .
    end.
 end.
  end.
  else do:
    for each buff-obj-list no-lock
      where xtog-obj = false
         or (buff-obj-list.obj-type = x-store-type
            and buff-obj-list.obj-code = x-store-code
            )
    on error undo, return error
    :
      find last buff-stk-line no-lock
        where buff-stk-line.obj-type   = buff-obj-list.obj-type
          and buff-stk-line.obj-code   = buff-obj-list.obj-code
          and buff-stk-line.artic      = x-artic
          and buff-stk-line.prod-type  = x-prod-type
          and buff-stk-line.prod-code  = x-prod-code
          and buff-stk-line.sum-type   = x-sum-type
          and buff-stk-line.cat-id     = '##,##':U
          and buff-stk-line.fact-order <= x-fact-order
          and buff-stk-line.shift-num  > 0
        use-index category
        no-error .
      if available buff-stk-line then do:
        assign
          Quantity = Quantity +  buff-stk-line.fact-qnty
          Coast_R  = Coast_R  +  buff-stk-line.sum-rubl
          Coast_V  = Coast_V  +  buff-stk-line.sum-base
          VAT_R    = VAT_R    +  buff-stk-line.VAT-rubl
          VAT_V    = VAT_V    +  buff-stk-line.VAT-base
          SLT_R    = SLT_R    +  buff-stk-line.SLT-rubl
          SLT_V    = SLT_V    +  buff-stk-line.SLT-base
          other_R = other_R   +  buff-stk-line.other-rubl
          other_V = other_V   +  buff-stk-line.other-base
        .
      end.
    end.
  end.
end procedure.
procedure ost-line-kg :
  define  input parameter p-obj-code    like ub.stk-line.obj-code   no-undo .
  define  input parameter p-obj-type    like ub.stk-line.obj-type   no-undo .
  define  input parameter p-artic       like ub.stk-line.artic      no-undo .
  define  input parameter p-prod-code   like ub.stk-line.prod-code  no-undo .
  define  input parameter p-prod-type   like ub.stk-line.prod-type  no-undo .
  define  input parameter p-fact-order  like ub.stk-line.fact-order no-undo .
  define output parameter p-quantity-kg like ub.stk-line.fact-qnty  no-undo initial 0.00 .
  define buffer buff-obj-list  for obj-list .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inv-line for ub.inv-line .
  do
  on error undo, return error
  :
    for each buf_doc-line no-lock where
             buf_doc-line.obj-type    = p-obj-type   and
             buf_doc-line.obj-code    = p-obj-code   and
             buf_doc-line.prod-type   = p-prod-type  and
             buf_doc-line.prod-code   = p-prod-code  and
             buf_doc-line.artic       = p-artic      and
             buf_doc-line.status_     = 'факт':U      and
             buf_doc-line.fact-order <= p-fact-order
          by buf_doc-line.fact-order    descending
    :
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error .
      if available buf_inv-line
      then do:
        if buf_inv-line.after-cli-qnty <> ?
        then do:
          assign
            p-quantity-kg = buf_inv-line.after-cli-qnty
          .
          leave .
        end.
      end.
    end.
    if p-quantity-kg = ?
    then do:
      assign
        p-quantity-kg = 0
      .
    end.
  end.
end procedure.
procedure calc-price-sale-for-prt :
define output parameter v-cur-base as decimal no-undo .
define variable v-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
define var parrecid-prl as recid no-undo .
    define  variable price-rubl-with-tax-sale-prl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale-prl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale-prl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale-prl like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale-prl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale-prl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer-prl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer-prl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale-prl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale-prl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale-prl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale-prl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale-prl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale-prl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale-prl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale-prl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl-prl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl-prl for ub.gds-dtl.
    define buffer out-vatp_parts-prl       for ub.parts.
    define buffer out-vatp_sysconf-prl     for ub.sysconf.
    define buffer out-vatp_doc-line-prl    for ub.doc-line.
    define buffer out-vatp_goods-prl       for ub.goods.
    define buffer out-vatp_trn-doc-prl     for ub.trn-doc.
    define buffer out-vatp_doc-attr-prl    for ub.doc-attr.
    define variable varprice-base-cons-prl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons-prl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type-prl         as   character                           no-undo.
    define variable varfrm-cnsv-prl              as   character                           no-undo.
    define variable varroot-node-prl             as   integer                             no-undo.
    define variable varempty-scale-prl           as   logical                             no-undo.
    define variable varis-cons-parts-have-prl    as   logical                             no-undo.
    define variable varsum-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp-prl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp-prl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp-prl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp-prl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp-prl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp-prl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty-prl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty-prl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl-prl        as   logical                             no-undo.
    define variable varcur-prlprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-prlprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcur-prldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcur-prldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb-prl               as   character                           no-undo.
    define variable out-vatp-have-vat-slt-prl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco-prl  for ub.trn-doc .
    define buffer   in-vatp-partso-prl    for ub.parts   .
    define buffer   in-vatp-doco-prl      for ub.trn-doc .
    define buffer   in-vatp-goodso-prl    for ub.goods   .
    define buffer   in-vatp-sysconfo-prl  for ub.sysconf .
    define buffer   in-vatp_doc-attro-prl for ub.doc-attr.
    define variable in-vatp-have-vat-slto-prl       as   logical initial yes    no-undo.
    define variable vat-pc-loco-prl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo-prl                  as   character              no-undo.
    define variable slt-pc-loco-prl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo-prl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco-prl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco-prl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco-prl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco-prl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco-prl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco-prl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco-prl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco-prl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco-prl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco-prl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco-prl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco-prl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco-prl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco-prl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco-prl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco-prl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco-prl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco-prl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco-prl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco-prl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco-prl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco-prl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo-prl             as   character              no-undo.
    define variable varinvatp-typeo-prl             as   character              no-undo.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  gds-obj.obj-type
  ,input  gds-obj.obj-code
  ,input  v-bar-code
  ,input  0
  ,input  fact-order-2
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка при определении цены бар-кода" skip
                  "Объект" gds-obj.obj-type gds-obj.obj-code skip
                  "Бар-код" v-bar-code skip
                  "fact-order" fact-order-2 skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
              end.
        if parrecid-prl <> ? then do:
          run prl-vat in this-procedure
            (input  parrecid-prl
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
                if error-status :error then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    "Ошибка при вызове процеды prl-vat" skip
                    "Документ" ub.doc-line.doc-code skip
                    "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
                    error-status :get-message(1) skip
                    return-value skip
                    view-as alert-box error .
                end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
          .
        end.
  assign
    v-cur-base = price-base-with-tax-sale-prl
  .
end procedure.
