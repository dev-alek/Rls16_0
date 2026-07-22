CREATE WIDGET-POOL.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Журнал продаж" .
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
define variable var-report-r-b as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table sj-goods no-undo
field obj-attr     as   char
field b-code like ub.bar-code.b-code format "9999999999999"
field saleman-chr as   character
field artic     like ub.goods.artic
field name   like ub.goods.gds-name format "x(30)"
field grp-code          like ub.goods.grp-code
field grp-name          like ub.goods.grp-code
field prod-name   like ub.clients.obj-name
field node-code like ub.gds-prt.node-code
field node-name like ub.gds-prt.node-name
field twounit as decimal
field two-type as logical
field alt-type as logical
INDEX p1 IS PRIMARY   obj-attr ASCENDING
INDEX p2              obj-attr artic ASCENDING
INDEX p3              obj-attr prod-name ASCENDING
INDEX p4              obj-attr b-code saleman-chr ASCENDING
INDEX p6              obj-attr grp-name prod-name
INDEX p7              grp-code
.
define NEW SHARED temp-table sj-adv no-undo
field obj-attr     as   char
field b-code like ub.bar-code.b-code format "9999999999999"
field saleman-chr as    character
field price    like ub.chk-gds.price-base
field discnt  like ub.chk-gds.discnt
field qnty     like ub.chk-gds.doc-qnty
field qnty-2     like ub.chk-gds.doc-qnty
field qnty-3    like ub.chk-gds.doc-qnty
field dop-rowid as rowid
field brutto-sum   as   decimal
field discnt-sum  like ub.chk-gds.discnt
field netto-sum    as   decimal
field brutto-sum-r   as   decimal
field netto-sum-r    as   decimal
field num-lines as integer
field num-docs as integer
INDEX pi  IS PRIMARY   obj-attr b-code saleman-chr price discnt dop-rowid ASCENDING
.
define NEW SHARED temp-table sj-tots no-undo
field obj-attr     as   char
field grp-code          like ub.goods.grp-code
field grp-name          like ub.goods.grp-code
field prod-name   like ub.clients.obj-name
field saleman-chr as    character
field qnty     like ub.chk-gds.doc-qnty
field qnty-2   like ub.chk-gds.doc-qnty
field qnty-3   like ub.chk-gds.doc-qnty
field brutto-sum   as   decimal
field discnt-sum  like ub.chk-gds.discnt
field netto-sum    as   decimal
field brutto-sum-r   as   decimal
field netto-sum-r    as   decimal
field num-lines as integer
field num-docs as integer
INDEX pi  IS PRIMARY   obj-attr ASCENDING
INDEX p1                        prod-name ASCENDING
INDEX p2                        grp-name  ASCENDING
INDEX p3                        grp-code
.
define NEW SHARED temp-table sj-grp no-undo
field grp-code like ub.goods.grp-code
field grp-name like ub.goods.grp-name
field grp-code-alpha like ub.goods.grp-code
INDEX pi grp-code
INDEX iname  grp-name
INDEX grp-code-alpha grp-code-alpha
.
define NEW SHARED temp-table sj-salesman no-undo
field seller like ub.person.seller
field psn-code like ub.person.psn-code
field sal-chr as character
index pi is unique primary seller psn-code
index ichr sal-chr
index ipsn psn-code
.
FUNCTION get-grp-name returns character( input p-grp-code-alpha as integer):
define buffer buf_sj-grp for sj-grp.
  find first buf_sj-grp no-lock where
            buf_sj-grp.grp-code-alpha = p-grp-code-alpha no-error.
  if available buf_sj-grp then do:
    return buf_sj-grp.grp-name .
  end.
  return "!!!Неизвестное имя группы!!!".
END FUNCTION.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED variable    cashdesc-num    AS    INTEGER         no-undo.
DEFINE NEW SHARED variable    saleman-num     AS    INTEGER         no-undo.
DEFINE NEW SHARED    variable prodtot_flag       AS    LOGICAL      no-undo.
DEFINE NEW SHARED    variable grouptot_flag     AS    LOGICAL       no-undo.
DEFINE NEW SHARED    variable OneLinePrinted  AS    LOGICAL     no-undo.
DEFINE NEW SHARED    variable my-Set_val_TYPE AS INTEGER No-undo.
DEFINE NEW SHARED    variable Rs-sort-str as character no-undo.
DEFINE NEW SHARED    variable Rs-by-str as character no-undo.
DEFINE NEW SHARED    variable Rs-cass-str as character no-undo.
DEFINE NEW SHARED    variable cas-num-str as character no-undo.
DEFINE NEW SHARED    variable rs-saleman-str as character no-undo.
DEFINE NEW SHARED    variable saleman-str as character no-undo.
DEFINE NEW SHARED    variable v-num-chk as integer no-undo.
define Shared variable cas-shft as logical no-undo init no.
define shared variable call-point as char no-undo.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED stream PrnLibStream.
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define NEW SHARED variable Line                as      char    no-undo.
define NEW SHARED variable cash_string     as      char    no-undo.
define NEW SHARED variable sale_string     as      char    no-undo.
define NEW SHARED variable date_string     as      char    no-undo.
define NEW SHARED variable NotInc as log no-undo.
define NEW SHARED variable namebuf1     as      char    no-undo.
define NEW SHARED variable namebuf2     as      char    no-undo.
define NEW SHARED variable prodbuf1     as      char    no-undo.
define NEW SHARED variable prodbuf2     as      char    no-undo.
define NEW SHARED variable stat as logical no-undo.
define NEW SHARED variable pcnt  as   decimal  no-undo .
define NEW SHARED variable SHBySalers as logical no-undo.
define NEW SHARED variable Shrs-seller-cashier as character no-undo .
define NEW SHARED variable SHRS-BY as integer no-undo.
define NEW SHARED variable SHt-twounit as logical no-undo.
define NEW SHARED variable SHRS-SOrt as character no-undo.
define NEW SHARED variable SHOnly_tot as logical no-undo.
define variable counter as integer no-undo .
define variable v-seller-cashier-1 as character no-undo .
assign
v-seller-cashier-1 = (if shrs-seller-cashier = "seller"
                      then "Итого прод-ц "
                      else "Итого кассир ").
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lhistprex-print-gds-list-hist-excel :
define input parameter p-text  as logical no-undo .
define input parameter p-excel as logical no-undo .
define input parameter p-sheet-num as integer no-undo .
define buffer buf_lh-sheetf for sheetf.
define buffer buf_gds-list-hist for gds-list-hist.
  do
  on error undo, return error
  :
    find first buf_gds-list-hist no-lock where buf_gds-list-hist.id = 0 no-error .
    if p-excel then do:
      if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.
      FInd first buf_lh-Sheetf where
                buf_lh-Sheetf.sheet-num = p-sheet-num No-ERROR.
      if not avail buf_lh-sheetf then
      create buf_lh-sheetf.
      assign
      buf_lh-Sheetf.Sheet-num = 2
      buf_lh-sheetf.Excel-Column-Lable =  "№ п/п,Действие,Записей,итого,Множество"
      buf_lh-sheetf.sizes = "9,9,9,12,155"
      .
      run rep/extitlee.p (input p-sheet-num
                    , input  substitute("История создания списка &1 &2"
                                ,
''
                                ,(if available buf_gds-list-hist
                                then buf_gds-list-hist.des
                                else "БЕЗЫМЯННЫЙ"))
                    ) .
    end.
    if p-text then do:
      Page stream PrnLibStream.
      PUT  STREAM PrnLibStream unformatted
      SPACE(25) substitute("История создания списка &1 &2"
                          , ''
                          ,(if available buf_gds-list-hist
                          then buf_gds-list-hist.des
                          else "БЕЗЫМЯННЫЙ")) skip(0)
      space(25) cur-time-print() skip(1)
      .
      put stream PrnLibStream unformatted
      string("№", "X(9)") chr(32)
      string("Действие", "X(9)") chr(32)
      string("записей", "X(9)") chr(32)
      string(" = итого", "X(12)") chr(32)
      (if page-size(PrnLibStream) > 43
      then string("Множество", "X(" + string(136 - 43) + ")")
      else string("Множество", "X(" + string(198 - 43) + ")")
      )
      skip(0)
      fill('-':U, 9) chr(32)
      fill('-':U, 9) chr(32)
      fill('-':U, 9) chr(32)
      fill('-':U, 12) chr(32)
      (if page-size(PrnLibStream) > 43
      then fill('-':U, 136 - 43)
      else fill('-':U, 198 - 43))
      skip(0)
      .
    end.
    for each buf_gds-list-hist where buf_gds-list-hist.id > 0
    by buf_gds-list-hist.id
    :
      if p-text then do:
        put stream PrnLibStream unformatted
        (if buf_gds-list-hist.line = 0
        then string(buf_gds-list-hist.id, ">>>>>>>>9")
        else fill(chr(32) , 9)
        )  chr(32)
        (if buf_gds-list-hist.item_ <> '':U
        then string(buf_gds-list-hist.hist-mode, "X(8)")
        else fill( chr(32), 8)) chr(32)
        string(buf_gds-list-hist.num-add, ">>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
        string(buf_gds-list-hist.num-recs, ">>>>>>>>9")  chr(32)
        (if page-size(PrnLibStream) > 43
        then string(buf_gds-list-hist.des, "X(" + string(136 - 43) + ")")
        else string(buf_gds-list-hist.des, "X(" + string(198 - 43) + ")"))
        skip.
      end.
      if p-excel then do:
        if Make-Excel then  put   stream ForExcel unformatted
        (if buf_gds-list-hist.line = 0
        then string(buf_gds-list-hist.id, ">>>>>>>>9")
        else '':U)
        CHR(9)
        (if buf_gds-list-hist.item_ <> '':U
        then buf_gds-list-hist.hist-mode
        else '':U)  CHR(9)
        (if buf_gds-list-hist.item_ <> '':U
        then string(buf_gds-list-hist.num-add, "->>>>>>>>9")
        else '':U)  CHR(9)
        (if buf_gds-list-hist.item_ <> '':U
        then string(buf_gds-list-hist.num-recs, ">>>>>>>>9")
        else '':U)  CHR(9)
        buf_gds-list-hist.des
        skip.
      end.
    end.
  end.
end procedure.
define temp-table param-to-export no-undo
field param-code     as character
field param-sub-code as character
field param-type     as character
field param-value    as character
field param-comment  as character
index pi is unique primary  param-code     param-sub-code
.
procedure create-param-to-export :
 do
 on error undo, return error return-value
 :
 define input parameter p1 as character no-undo .
 define input parameter p2 as character no-undo .
 define input parameter p3 as character no-undo .
 define input parameter p4 as character no-undo .
 define input parameter p5 as character no-undo .
  create  param-to-export.
  assign
     param-to-export.param-code     =  p1
     param-to-export.param-sub-code =  p2
     param-to-export.param-type     =  p3
     param-to-export.param-value    =  p4
     param-to-export.param-comment  =  p5
  .
 end.
end procedure.
DEFINE VARiable    ii         AS    INTEGER         no-undo.
DEFINE VARiable   sale-list   as character no-undo .
define variable v-frame-width as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define variable parparentproc as widget-handle no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE VARIABLE Cas-Num AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "N"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.
DEFINE VARIABLE RS-by AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Без товаров", 0,
"Без классификации", 1,
"Группы товаров/Производитель", 2,
"Производитель/Группы товаров", 3
     SIZE 31.75 BY 3.13 NO-UNDO.
DEFINE VARIABLE RS-cass AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all":U,
"Выборочно", "selective":U
     SIZE 14.75 BY 1.79 NO-UNDO.
DEFINE VARIABLE RS-saleman AS CHARACTER INITIAL "all"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "all":U,
"Выборочно", "selective":U
     SIZE 14.75 BY 1.79 NO-UNDO.
DEFINE VARIABLE RS-seller-cashier AS CHARACTER INITIAL "Seller"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Продавцы", "Seller",
"Кассиры", "Cashier"
     SIZE 31.5 BY 1 NO-UNDO.
DEFINE VARIABLE RS-sort AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по коду", "barcode":U,
"по артикулу", "Article":U
     SIZE 16.13 BY 1.63 NO-UNDO.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.5 BY 3.46.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.5 BY 3.46.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.38 BY 11.21.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.88 BY 7.17.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.38 BY 1.63.
DEFINE RECTANGLE RECT-detail
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 35.38 BY 7.58.
DEFINE VARIABLE ByPrice AS LOGICAL INITIAL no
     LABEL "По скидке"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE BySalers AS LOGICAL INITIAL no
     LABEL "По продавцам/По кассирам"
     VIEW-AS TOGGLE-BOX
     SIZE 32.38 BY 1 NO-UNDO.
DEFINE VARIABLE Only_Tot AS LOGICAL INITIAL no
     LABEL "Только итоги"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-twounit AS LOGICAL INITIAL no
     LABEL "В двух ед. изм."
     VIEW-AS TOGGLE-BOX
     SIZE 19.63 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE Tot_Groups AS LOGICAL INITIAL no
     LABEL "По группам"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE Tot_Producers AS LOGICAL INITIAL no
     LABEL "По производителям"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.
DEFINE FRAME F-Main
     RS-by AT ROW 2.71 COL 4.25 NO-LABEL
     Tot_Groups AT ROW 4.71 COL 40.38
     Tot_Producers AT ROW 6.04 COL 40.25
     RS-sort AT ROW 6.88 COL 4.25 NO-LABEL
     BySalers AT ROW 7.33 COL 40.13
     RS-seller-cashier AT ROW 8.5 COL 40 NO-LABEL
     Only_Tot AT ROW 10 COL 40.13
     RS-saleman AT ROW 10.08 COL 4.25 NO-LABEL
     ByPrice AT ROW 11.25 COL 40.13
     T-twounit AT ROW 13 COL 39.88
     RS-cass AT ROW 13.58 COL 4 NO-LABEL
     Cas-Num AT ROW 14.21 COL 28.5 COLON-ALIGNED
     "Сортировка" VIEW-AS TEXT
          SIZE 26.88 BY .92 AT ROW 5.88 COL 4.13
          FGCOLOR 4
     "Кассы" VIEW-AS TEXT
          SIZE 21.38 BY 1 AT ROW 12.58 COL 4
          FGCOLOR 4
     "Продавцы/Кассиры" VIEW-AS TEXT
          SIZE 21.38 BY 1 AT ROW 9.08 COL 4.25
          FGCOLOR 4
     "Детализация" VIEW-AS TEXT
          SIZE 19.25 BY .83 AT ROW 1.42 COL 40
          FGCOLOR 4
     "Итоги" VIEW-AS TEXT
          SIZE 7.88 BY 1 AT ROW 3.29 COL 45.75
          FGCOLOR 4
     "Классификация" VIEW-AS TEXT
          SIZE 27.88 BY 1 AT ROW 1.42 COL 4.25
          FGCOLOR 4
     RECT-5 AT ROW 1.21 COL 38.63
     RECT-7 AT ROW 12.71 COL 38.63
     RECT-6 AT ROW 2.83 COL 39.63
     RECT-4 AT ROW 8.88 COL 2.25
     RECT-3 AT ROW 12.38 COL 2.25
     RECT-detail AT ROW 1.13 COL 2.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 73 BY 15.13.
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
    DISABLE RECT-5 RECT-7 RECT-6 RECT-4 RECT-3 RECT-detail RS-by BySalers RS-seller-cashier RS-saleman ByPrice RS-cass WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-5 RECT-7 RECT-6 RECT-4 RECT-3 RECT-detail RS-by BySalers RS-seller-cashier RS-saleman ByPrice RS-cass WITH FRAME F-Main.
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
ASSIGN
       Cas-Num:HIDDEN IN FRAME F-Main           = TRUE.
ASSIGN
       T-twounit:HIDDEN IN FRAME F-Main           = TRUE.
ON VALUE-CHANGED OF RS-by IN FRAME F-Main
DO:
    if lookup( Rs-by:screen-value,
                    "3,1" ) > 0 then
    enable RS-sort with frame F-Main.
    else disable RS-Sort with frame F-Main.
    if lookup( Rs-By:screen-value, "1,0" ) > 0 then do:
        assign
        Tot_Groups = FALSE
        Tot_Producers = FALSE
        ONly_tot = FALSE .
        display Tot_Groups Tot_Producers ONly_tot WITH frame F-Main.
        disable Tot_Groups Tot_Producers ONly_tot WITH frame F-Main.
   end.
   else
   enable Tot_Groups Tot_Producers ONly_tot WITH frame F-Main.
END.
ON VALUE-CHANGED OF RS-cass IN FRAME F-Main
DO:
assign RS-Cass.
if RS-cass = "all":U then do:
    assign cas-num = 0.
    display cas-num with frame F-Main.
    disable cas-num with frame F-Main.
    HIDE cas-num in frame F-Main.
end.
else do:
   enable cas-num with frame F-Main.
   display cas-num with frame F-Main.
   apply "entry" to Cas-Num in frame F-Main.
end.
END.
ON VALUE-CHANGED OF RS-saleman IN FRAME F-Main
DO:
define variable v-seller-code as integer no-undo .
define buffer buf_staff for ub.staff.
assign RS-Saleman .
if RS-Saleman = "selective":U then do:
  sale-list = "" .
  if rs-seller-cashier = "seller" then do:
    run ref/staffs.w (
                   input my-handle
                  ,input "b-sel,b-mark"
                  ,input 'S':U
                  ,input (if v-cntxt-db-num = 0 then ? else v-cntxt-db-num)
                  ,input 0
                  ,output sale-list ) .
  end.
  else do:
    run ref/staffs.w (
                    input my-handle
                   ,input "b-sel,b-mark"
                   ,input 'C':U
                   ,input (if v-cntxt-db-num = 0 then ? else v-cntxt-db-num)
                   ,input 0
                   ,output sale-list ) .
  end.
  if sale-list = "" then do:
    assign
    BySalers = FALSE
    sale-list = ""
    Rs-Saleman = "all":U .
    DISPLAY BySalers RS-Saleman with frame F-Main .
  end.
  else do:
    for each sj-salesman:
      delete sj-salesman.
    end.
    assign
    BySalers = TRUE
    .
    DISPLAY BySalers with frame F-Main .
    DO ii = 1 to num-entries( sale-list ) :
      FIND FIRST buf_staff WHERE
            recid( buf_staff ) = integer( entry( ii, sale-list ) ) NO-LOCK .
      create sj-salesman.
      assign
      sj-salesman.seller =   buf_staff.staff-code
      sj-salesman.psn-code = buf_staff.psn-code
      sj-salesman.sal-chr = string(buf_staff.staff-code) + chr(4) + string(buf_staff.psn-code)
      .
      release sj-salesman.
    END .
  end.
end.
else do:
  assign
  sale-list = ""
  saleman-num = 0.
  for each sj-salesman:
    delete sj-salesman.
  end.
  DISPLAY BySalers with frame F-Main .
end.
END.
ON VALUE-CHANGED OF RS-seller-cashier IN FRAME F-Main
DO:
  ASSIGN
  RS-seller-cashier.
  CASE RS-saleman:
    when "selective" then do:
      assign
      Rs-Saleman = "all":U
      .
      DISPLAY
      RS-Saleman
      with frame F-Main .
    end.
    when "all" then do:
    end.
  END CASE.
END.
if not this-procedure :persistent
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при запуске процедуры" skip
    "Данную процедуру следует запускать только с параметром persistent" skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE no-benq.
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_chk-doc for ub.chk-doc.
FOR EACH obj-list WHERE
        obj-list.obj-type = 'маг':U NO-LOCK :
  CASE X-Radio-Task > 1 :
    WHEN YES THEN DO:
      FOR EACH buf_chk-doc NO-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              (
                buf_chk-doc.shift-date >= X-date-start AND
                buf_chk-doc.shift-date <= X-date-end)
                AND
                (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        IF X-Radio-Task = 3 AND
        ((buf_chk-doc.shift-date = X-date-start AND buf_chk-doc.shift-num < X-shift-Start) OR
          (buf_chk-doc.shift-date = X-date-end AND  buf_chk-doc.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_chk-doc.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
    END.
    WHEN NO THEN DO:
      FOR EACH buf_chk-doc NO-LOCK WHERE
            buf_chk-doc.obj-type = obj-list.obj-type AND
            buf_chk-doc.obj-code = obj-list.obj-code AND
            buf_chk-doc.chk-date >= X-date-start AND
            buf_chk-doc.chk-date <= X-date-end   AND
            (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        found = yes.
        return.
      END.
     END.
   END CASE.
 END.
END PROCEDURE.
PROCEDURE no-benqi.
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_inkas for ub.inkas.
FOR EACH obj-list WHERE
      obj-list.obj-type = 'маг':U NO-LOCK :
  CASE X-Radio-Task > 1 :
    WHEN YES THEN DO:
      FOR EACH buf_chk-doc No-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              (
                buf_chk-doc.shift-date >= X-date-start AND
                buf_chk-doc.shift-date <= X-date-end)
                AND
                buf_Chk-doc.out-code = ? AND
                (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        IF X-Radio-Task = 3 AND
        ((buf_chk-doc.shift-date = X-date-start AND buf_chk-doc.shift-num < X-shift-Start) OR
          (buf_chk-doc.shift-date = X-date-end AND  buf_chk-doc.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_chk-doc.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
      FOR EACH buf_inkas No-LOCK WHERE
                buf_inkas.obj-type = obj-list.obj-type AND
                buf_inkas.obj-code = obj-list.obj-code AND
                (
                buf_inkas.shift-date >= X-date-start AND
                buf_inkas.shift-date <= X-date-end):
        if buf_inkas.status_ = 'факт':U
        or buf_inkas.status_ = 'запрос':U then next.
        IF X-Radio-Task = 3 AND
        ((buf_inkas.shift-date = X-date-start AND buf_inkas.shift-num < X-shift-Start) OR
          (buf_inkas.shift-date = X-date-end AND  buf_inkas.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_inkas.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
    END.
    WHEN NO THEN DO:
      FOR EACH buf_chk-doc NO-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              buf_chk-doc.chk-date >= X-date-start AND
              buf_chk-doc.chk-date <= X-date-end   AND
              buf_Chk-doc.out-code = ? AND
              (IF cas-num > 0 then buf_chk-doc.pay-desk = cas-num ELSE TRUE):
        found = yes.
        return.
      END.
      FOR EACH buf_inkas NO-LOCK WHERE
              buf_inkas.obj-type = obj-list.obj-type AND
              buf_inkas.obj-code = obj-list.obj-code AND
              buf_inkas.doc-date >= X-date-start AND
              buf_inkas.doc-date <= X-date-end :
        if buf_inkas.status_ = 'факт':U
        or buf_inkas.status_ = 'запрос':U then next.
        found = yes.
        return.
      END.
    END.
  END CASE.
END.
END PROCEDURE.
PROCEDURE no-benq-i.
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_inkas for ub.inkas.
CASE X-Radio-Task > 1:
  WHEN YES then do:
    FOR EACH obj-list WHERE
            obj-list.obj-type = 'маг':U NO-LOCK :
      FOR EACH buf_inkas NO-LOCK WHERE
              buf_inkas.obj-type = obj-list.obj-type AND
              buf_inkas.obj-code = obj-list.obj-code AND
              buf_inkas.status_ = 'факт':U AND
              (
              buf_inkas.shift-date >= X-date-start AND
              buf_inkas.shift-date <= X-date-end):
        IF X-Radio-Task = 3 AND
        ((buf_inkas.shift-date = X-date-start AND buf_inkas.shift-num < X-shift-Start) OR
          (buf_inkas.shift-date = X-date-end AND  buf_inkas.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_inkas.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
  END.
  END.
  WHEN NO THEN DO:
    FOR EACH obj-list WHERE
            obj-list.obj-type = 'маг':U NO-LOCK :
      FOR EACH buf_inkas NO-LOCK WHERE
              buf_inkas.obj-type = obj-list.obj-type AND
              buf_inkas.obj-code = obj-list.obj-code AND
              buf_inkas.status_ = 'факт':U AND
              buf_inkas.doc-date >= X-date-start AND
              buf_inkas.doc-date <= X-date-end :
         found = yes.
         return.
      END.
    END.
  END.
END CASE.
END PROCEDURE.
PROCEDURE no-benq-i-office.
DEFINE OUTPUT PARAMETER found as logical init no.
define buffer buf_sale-doc for ub.sale-doc.
CASE X-Radio-Task > 1:
  WHEN YES then do:
    FOR EACH obj-list WHERE
            obj-list.obj-type = 'маг':U NO-LOCK :
      FOR EACH buf_sale-doc NO-LOCK WHERE
               buf_Sale-doc.obj-type = obj-list.obj-type
           AND buf_sale-doc.obj-code = obj-list.obj-code
           AND buf_sale-doc.status_ = 'факт':U
           AND buf_sale-doc.chr-office = 'у':U
           AND (
              buf_sale-doc.shift-date >= X-date-start
              AND
              buf_sale-doc.shift-date <= X-date-end):
        IF X-Radio-Task = 3 AND
        ((buf_sale-doc.shift-date = X-date-start AND buf_sale-doc.shift-num < X-shift-Start) OR
          (buf_sale-doc.shift-date = X-date-end AND  buf_sale-doc.shift-num > X-shift-End) ) THEN NEXT.
        IF X-Radio-Task = 4 AND
        (buf_sale-doc.shift-num <> X-shift-Alone ) THEN NEXT.
        found = yes.
        return.
      END.
    END.
  END.
  WHEN NO THEN DO:
    FOR EACH obj-list WHERE
            obj-list.obj-type = 'маг':U NO-LOCK :
      FOR EACH buf_sale-doc NO-LOCK WHERE
              buf_sale-doc.obj-type = obj-list.obj-type
         AND  buf_sale-doc.obj-code = obj-list.obj-code
         AND  buf_sale-doc.status_ = 'факт':U
         AND  buf_sale-doc.chr-office = 'у':U
         AND  buf_sale-doc.doc-date >= X-date-start
         AND  buf_sale-doc.doc-date <= X-date-end :
        found = yes.
        return.
      END.
    END.
  END.
END CASE.
END PROCEDURE.
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
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-by Tot_Groups Tot_Producers RS-sort BySalers RS-seller-cashier
          Only_Tot RS-saleman ByPrice RS-cass
      WITH FRAME F-Main.
  ENABLE RECT-5 RECT-7 RECT-6 RECT-4 RECT-3 RECT-detail RS-by BySalers
         RS-seller-cashier RS-saleman ByPrice RS-cass
      WITH FRAME F-Main.
END PROCEDURE.
PROCEDURE ini-from-selobj :
define variable num-obj-list as integer no-undo.
CASE X-SelectObject :
    when "текущий" then do:
        enable rs-cass with frame F-Main.
    end.
    when "все" then do:
        assign cas-num  = 0
        rs-cass = "all":U.
        display rs-cass with frame F-Main.
        disable rs-cass with frame F-Main.
        Hide cas-num in frame F-Main.
    end.
    when "выборочно" then do:
        for each obj-list no-lock:
            num-obj-list = num-obj-list + 1.
            if num-obj-list > 1 then leave.
        end.
        if num-obj-list > 1 then do:
        assign cas-num  = 0
        rs-cass = "all":U.
        display rs-cass cas-num with frame F-Main.
        disable rs-cass with frame F-Main.
        Hide cas-num in frame F-Main.
    end.
end.
END CASE.
END PROCEDURE.
PROCEDURE local-initialize :
 parparentproc = my-handle.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
    run ini-from-selobj in this-procedure .
    run next_enable in this-procedure .
END PROCEDURE.
PROCEDURE MainProc :
run rep/e-sj1.p ( input my-handle, output v-frame-width) no-error.
if error-status:error then return error.
END PROCEDURE.
PROCEDURE MainProc-t :
run rep/e-sj2.p ( input my-handle, output v-frame-width) no-error.
if error-status:error then return error.
END PROCEDURE.
PROCEDURE MainProc_d :
 run rep/e-sj3.p ( input my-handle, output v-frame-width) no-error.
 if error-status:error then return error.
END PROCEDURE.
PROCEDURE MainProc_D-t :
run rep/e-sj4.p ( input my-handle, output v-frame-width) no-error.
if error-status:error then return error.
END PROCEDURE.
PROCEDURE Main_Circle :
date_string = cur-time-print() .
if cashdesc-num = 10000 then
cash_string = "КАССЫ            :  В С Е.".
else
cash_string = "КАССА            :  " + string(cashdesc-num, ">>>>>9") + ".".
assign
cash_string = cash_string + fill(" ", 31) + "Итоги по группам        :  " +
                       (if grouptot_flag then "ДА." else "НЕТ.")
sale_string = string("Продавцы: " + rs-saleman-str + " "  + saleman-str , "x(57)" )  +
"Итоги по производителям :  " + ( if prodtot_flag then "ДА." else "НЕТ." ).
run waitfram-show in this-procedure ( input "Подождите ..." ).
run rep/e-sj-cr.p (
                input this-procedure
                ,input v-curr-r-b
                ,input X-date-start
                ,input X-date-end
                ,input X-shift-start
                ,input X-shift-end
                ,input X-shift-Alone
                ,input X-selectGood
                ,input X-Radio-Task
                ,input rs-seller-cashier
                ,input BySalers
                ,input t-twounit
                ,input ", обработано чеков :"
                ,input (X-Radio-Task > 1)
                ,input (if cashdesc-num = 10000
                       then -1
                       else cashdesc-num)
                )
            .
run waitfram-hide in this-procedure .
Line = fill("-", 250).
if v-curr-r-b = 'base':U then do:
  if my-Set_Val_Type = 3 or t-twounit then do:
    run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input 43
                                                ,input yes
                                                ,input no
                                                ).
  end.
  else do:
    run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input 62
                                                ,input yes
                                                ,input no
                                                ).
  end.
end.
else do:
  if  t-twounit then do:
      run prn-lib-open-stream  in this-procedure (
                                                  input my-handle
                                                  ,input 43
                                                  ,input yes
                                                  ,input no
                                                  ).
  end.
  else do:
    run prn-lib-open-stream  in this-procedure (
                                                input my-handle
                                                ,input 62
                                                ,input yes
                                                ,input no
                                                ).
  end.
end.
run value(if t-twounit then "MainProc-t" else "MainProc").
output STREAM PrnLibStream CLOSE.
OneLinePrinted = False .
END PROCEDURE.
PROCEDURE Main_Circle_d :
date_string = cur-time-print() .
if cashdesc-num = 10000 then
cash_string = "КАССЫ            :  В С Е.".
else
cash_string = "КАССА            :  " + string(cashdesc-num, ">>>>>9") + ".".
assign
cash_string = cash_string + fill(" ", 31) + "Итоги по группам        :  " +
              (if grouptot_flag then "ДА." else "НЕТ.")
sale_string = string("Продавцы: " + rs-saleman-str + " "  + saleman-str , "x(57)" ) +
"Итоги по производителям :  " + ( if prodtot_flag then "ДА." else "НЕТ." ).
run waitfram-show in this-procedure (  input "Подождите ..." ).
run rep/e-sj-crd.p (
                input this-procedure
                ,input v-curr-r-b
                ,input X-date-start
                ,input X-date-end
                ,input X-shift-start
                ,input X-shift-end
                ,input X-shift-Alone
                ,input X-selectGood
                ,input X-Radio-Task
                ,input rs-seller-cashier
                ,input BySalers
                ,input t-twounit
                ,input ", обработано чеков :"
                ,input (X-Radio-Task > 1)
                ,input (if cashdesc-num = 10000
                       then -1
                       else cashdesc-num)
                )
    .
run waitfram-hide in this-procedure .
Line = fill("-", 250).
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
run value(if t-twounit then "MainProc_D-t" else "MainProc_D").
output STREAM PrnLibStream CLOSE.
OneLinePrinted = False .
END PROCEDURE.
PROCEDURE My-report :
Run My-var in this-procedure .
FOR EACH sj-goods :
    delete sj-goods .
END .
FOR EACH sj-adv :
    delete sj-adv .
END .
FOR EACH sj-tots :
    delete sj-tots .
END .
FOR EACH sj-grp :
    delete sj-grp .
END .
if ByPrice then run Main_Circle_d in this-procedure .
else
run Main_Circle in this-procedure .
if v-frame-width <= 198 then do:
  run prn-lib-prn-file in this-procedure ( input my-handle, input (if v-frame-width <= 136 then 0 else 8)) .
end.
else do:
  run prn-lib-prn-file in this-procedure ( input my-handle, input (if v-frame-width <= 232 then 9 else 20)) .
end.
END PROCEDURE.
PROCEDURE My-var :
assign
frame F-Main Rs-Sort
frame F-Main Rs-By
frame F-Main Rs-Cass
frame F-Main Cas-num
frame F-Main Rs-Saleman
frame F-Main ByPrice
frame F-Main BySalers
frame F-Main Only_Tot
frame F-Main Tot_Groups
frame F-Main Tot_Producers
frame F-Main T-twounit
frame F-Main RS-seller-cashier
.
assign
cashdesc-num = if RS-Cass:screen-value = "all":U
               then 10000 else integer(Cas-Num:screen-value)
prodtot_flag = ( if ( Tot_Producers:screen-value = "yes" AND
                      Tot_Producers:sensitive = yes ) then TRUE else FALSE )
grouptot_flag = ( if ( Tot_Groups:screen-value = "yes" AND
                       Tot_Groups:sensitive = yes ) then TRUE else FALSE )
.
assign
ShBySAlers = BySAlers
Shrs-seller-cashier = rs-seller-cashier
SHRs-BY = RS-BY
SHt-twounit = t-twounit
SHRS-SOrt = RS-SOrt
SHOnly_tot = Only_Tot
.
if RS-Saleman = "all":U then
saleman-num = 10000 .
else do:
  assign
  saleman-num = - 1.
  saleman-str
  .
  for each sj-salesman:
    if saleman-num >= 0 then do:
      saleman-num = -1 .
      leave.
    end.
    assign
    saleman-num = sj-salesman.seller
    saleman-str = saleman-str + (if saleman-str = '':u then '':U else chr(44)) + string(sj-salesman.seller)
    .
  end.
end.
assign
my-Set_val_TYPE = if x-SET_val_TYPE = 0 then 2 else x-SET_val_TYPE.
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.
For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
assign
Rs-sort-str =  radio-label(string(rs-sort), rs-sort:radio-buttons)
Rs-by-str =   radio-label(string(rs-by), rs-by:radio-buttons)
Rs-cass-str = radio-label(string(rs-cass), rs-cass:radio-buttons)
cas-num-str =   (IF cas-num > 0 then ("Касса N: " + String(cas-num)) else "")
rs-saleman-str = radio-label(string(rs-saleman), rs-saleman:radio-buttons)
saleman-str =   (IF saleman-num > 0 and saleman-num < 10000
                 then ((if rs-seller-cashier = "seller"
                        then "Продавец N: "
                        else "Кассир   N: ") + String(saleman-num))
                 else "")
ReportHeader =  "Классификация: " + rs-by-str + chr(10) +
                (if Rs-sort:sensitive in frame F-Main
                 then
                 ("Сортировка: " + Rs-sort-str)
                 else ""
                 ) + chr(10) +
                  "Кассы: " + rs-cass-str  + chr(10) +
                cas-num-str + chr(10) +
                (if rs-seller-cashier = "seller"
                 then "Продавцы: "
                 else "Кассиры") +
                 rs-saleman-str + chr(10) +
                saleman-str + chr(10) +
                (if Only_tot
                 then ("Только итоги"  + chr(10))
                 else "") +
                 (if ByPrice OR BySalers OR Tot_Groups OR Tot_Producers
                 then ("Итоги: " +
                       (if ByPrice then (Byprice:label + " ") else "") +
                       (if BySalers
                        then ((IF rs-seller-cashier = "seller"
                              THEN ENTRY(1, BySalers:label, chr(47))
                              ELSE ENTRY(2, BySalers:label, chr(47)))
                                         + " ")
                        else "") +
                       (if Tot_groups then (Tot_Groups:label + " ") else "") +
                       (if Tot_Producers then (Tot_Producers:label + " ") else "")
                      )
                 else ""
                ).
END PROCEDURE.
PROCEDURE NExt_enable :
if LOOKUP('2ед':U, call-point) > 0 then do:
    assign
    t-twounit = yes.
    DISPLAY
    t-twounit with frame F-Main.
    ENABLE
    t-twounit with frame F-Main.
end.
END PROCEDURE.
PROCEDURE report-to-ach :
 do
 on error undo, return error return-value
 :
 DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR param-to-export .
  for each  param-to-export : delete  param-to-export. end.
define variable cconnect as character no-undo .
define variable user-name as character no-undo .
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  v-cntxt-userid
  ,output user-name
  )  .
 get-key-value section "rep-sets" key "conpar" value cconnect .
define variable v-base-key as character no-undo .
run gbl/base-key.p
   (output v-base-key
  ) .
  run create-param-to-export  in this-procedure
  ( input 'base-key'  ,
   input ''  ,
   input 'character'  ,
   input v-base-key  ,
   input 'ключ' )
 .
  run create-param-to-export  in this-procedure
  ( input 'db-connect'  ,
   input ''  ,
   input 'character'  ,
   input cconnect  ,
   input 'строка коннекта к БД' )
 .
  run create-param-to-export  in this-procedure
  ( input 'report-code'  ,
   input ''  ,
   input 'character'  ,
   input ReportProc  ,
   input 'уникальный код отчета' )
 .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name like ub.clients.obj-name no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
  run create-param-to-export  in this-procedure
  ( input 'firm-name'  ,
   input ''  ,
   input 'character'  ,
   input v-host-name  ,
   input 'имя фирмы' )
 .
  run create-param-to-export  in this-procedure
  ( input 'firm-code'  ,
   input ''  ,
   input 'integer'  ,
   input string(v-cntxt-host-code-obj)  ,
   input 'код фирмы' )
 .
  run create-param-to-export  in this-procedure
  ( input 'user-name'  ,
   input ''  ,
   input 'character'  ,
   input user-name  ,
   input 'имя пользователя' )
 .
  run create-param-to-export  in this-procedure
  ( input 'store-type'  ,
   input ''  ,
   input 'character'  ,
   input v-cntxt-obj-type  ,
   input 'текущий объект - тип'  )
 .
  run create-param-to-export  in this-procedure
  ( input 'store-code'  ,
   input ''  ,
   input 'integer'  ,
   input string(v-cntxt-obj-code)  ,
   input 'текущий объект - код' )
 .
  run create-param-to-export  in this-procedure
  ( input 'date-start'  ,
   input ''  ,
   input 'data'  ,
   input string(x-date-start,'99/99/9999')  ,
   input 'дата начала интервала'  )
 .
  run create-param-to-export  in this-procedure
  ( input 'date-end'  ,
   input ''  ,
   input 'data'  ,
   input string(x-date-end,'99/99/9999')  ,
   input 'дата конца интервала' )
 .
  run create-param-to-export  in this-procedure
  ( input 'user-id'  ,
   input ''  ,
   input 'character'  ,
   input v-cntxt-userid  ,
   input 'код пользователя' )
 .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
          buf_currency.curr-code = v-base-code.
  run create-param-to-export  in this-procedure
  ( input 'base-type'  ,
   input ''  ,
   input 'character'  ,
   input string(buf_currency.curr-abbr)  ,
   input 'тип базовой валюты' )
 .
  run create-param-to-export  in this-procedure
  ( input 'base-code'  ,
   input ''  ,
   input 'integer'  ,
   input string(v-base-code)  ,
   input 'код базовой валюты' )
 .
if Show-Crsa or Show-Cost or Show-Sale then do:
  run create-param-to-export  in this-procedure
  ( input 'crsa'  ,
   input ''  ,
   input 'logical'  ,
   input string(show-Crsa,'yes/no')  ,
   input '  продажные цены' )
 .
  run create-param-to-export  in this-procedure
  ( input 'cost'  ,
   input ''  ,
   input 'logical'  ,
   input string(show-cost,'yes/no')  ,
   input '  учетные цены' )
 .
  run create-param-to-export  in this-procedure
  ( input 'sale'  ,
   input ''  ,
   input 'logical'  ,
   input string(show-sale,'yes/no')  ,
   input '  цены документа' )
 .
end.
else do:
  run create-param-to-export  in this-procedure
  ( input 'set-pay-type'  ,
   input ''  ,
   input 'integer'  ,
   input string(x-set_pay_type)  ,
   input 'тип цены Продажные цены=1 Учетные цены=2 Цены документа=3 ' )
 .
end.
  run create-param-to-export  in this-procedure
  ( input 'rubl-val'  ,
   input ''  ,
   input 'integer'  ,
   input string(x-SET_val_TYPE)  ,
   input 'печатать в рублях или валюте руб=1  вал=2  обе=3 ' )
 .
  run create-param-to-export  in this-procedure
  ( input 'reportname'  ,
   input ''  ,
   input 'character'  ,
   input reportname  ,
   input 'название отчета' )
 .
  run create-param-to-export  in this-procedure
  ( input 'select-good'  ,
   input ''  ,
   input 'integer'  ,
   input string(x-selectgood)  ,
   input 'тип выбора товара all=1 grp=2 prod=3 choice=4 one=5 grp-prod=6' )
 .
 define variable ii as integer no-undo .
 define variable ii-name as character no-undo .
 define variable ii-1 as integer no-undo .
 define variable ii-name-1 as character no-undo .
  define variable ii-2 as integer no-undo .
 define variable ii-name-2 as character no-undo .
 define variable ii-3 as integer no-undo .
 define variable ii-name-3 as character no-undo .
 if x-selectgood = 1     Or
    x-selectgood = 2     Or
    x-selectgood = 3    Or
    x-selectgood = 4  then do:
 ii = 0.
      for each gds-list :
        ii = ii + 1 .
        if ii = 1 then ii-name = "список товаров - содержит gds-code  (уникальный ключ товара)" .
                  else ii-name = "" .
  run create-param-to-export  in this-procedure
  ( input 'gds-list'  ,
   input string(ii)  ,
   input 'integer'  ,
   input string(gds-list.gds-code)  ,
   input ii-name )
 .
      end.
 end.
 if x-selectgood = 2 then do:
 ii-2 = 0.
      for each tmp#grp :
        ii-2 = ii-2 + 1 .
        if ii-2 = 1 then ii-name-2 = "список товаров - содержит  <node-code#grp-name>  (уникальный ключ списка групп)" .
                  else ii-name-2 = "" .
  run create-param-to-export  in this-procedure
  ( input 'tmp#grp'  ,
   input string(ii-2)  ,
   input 'integer character '  ,
   input string(tmp#grp.node-code) + '#' +  (tmp#grp.grp-name)  ,
   input ii-name-2 )
 .
      end.
 end.
 if x-selectgood = 3 then do:
 ii-3 = 0.
      for each g#cli :
        ii-3 = ii-3 + 1 .
        if ii-3 = 1 then ii-name-3 = "список товаров - содержит  <node-code#grp-name>  (уникальный ключ списка производителе)" .
                    else ii-name-3 = "" .
  run create-param-to-export  in this-procedure
  ( input 'g#cli'  ,
   input string(ii-3)  ,
   input 'character integer'  ,
   input g#cli.obj-type + '#' + string(g#cli.obj-code)  ,
   input ii-name-3 )
 .
      end.
 end.
  run create-param-to-export  in this-procedure
  ( input 'select-object'  ,
   input ''  ,
   input 'character'  ,
   input x-selectobject  ,
   input 'тип выбора объекта   -currency -choice -firm -все' )
 .
 ii-1 = 0.
  for each obj-list :
    ii-1 = ii-1 + 1 .
    if ii-1 = 1 then ii-name-1 = "список объектов - содержит <obj-type#obj-code>  (уникальный ключ clients)" .
              else ii-name-1 = "" .
  run create-param-to-export  in this-procedure
  ( input 'obj-list'  ,
   input string(ii-1)  ,
   input 'character integer'  ,
   input obj-list.obj-type + '#' + string (obj-list.obj-code)  ,
   input ii-name-1 )
 .
  end.
  run create-param-to-export  in this-procedure
  ( input 'rs-sort'                             ,
   input ''                                    ,
   input 'character'                           ,
   input Rs-Sort:screen-value in frame F-Main   ,
   input 'сортировка' )
 .
  run create-param-to-export  in this-procedure
  ( input 'rs-by'                             ,
   input ''                                    ,
   input 'character'                           ,
   input lc( radio-label(string(rs-by), rs-by:radio-buttons in frame F-Main))  ,
   input 'классификация' )
 .
  run create-param-to-export  in this-procedure
  ( input 'rs-saleman'                             ,
   input ''                                    ,
   input 'character'                           ,
   input Rs-Saleman:screen-value in frame F-Main   ,
   input 'выбор прадовцов' )
 .
  run create-param-to-export  in this-procedure
  ( input 'rs-cass'                             ,
   input ''                                    ,
   input 'character'                           ,
   input Rs-cass:screen-value in frame F-Main   ,
   input 'выбор касс' )
 .
  run create-param-to-export  in this-procedure
  ( input 'cas-num'                             ,
   input ''                                    ,
   input 'integer'                             ,
   input cas-num:screen-value in frame F-Main   ,
   input 'номер кассы' )
 .
  run create-param-to-export  in this-procedure
  ( input 'tot_groups'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(Tot_Groups,'yes/no')              ,
   input Tot_Groups:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'tot_producers'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(Tot_Producers,'yes/no')              ,
   input Tot_Producers:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'by_salers'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(BySalers,'yes/no')              ,
   input BySalers:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'only_tot'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(Only_Tot,'yes/no')              ,
   input Only_Tot:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 'by_price'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(ByPrice,'yes/no')              ,
   input ByPrice:label in frame F-Main )
 .
  run create-param-to-export  in this-procedure
  ( input 't-twounit'                             ,
   input ''                               ,
   input 'logical'                        ,
   input string(T-twounit,'yes/no')              ,
   input T-twounit:label in frame F-Main )
 .
  end.
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  CASE p-state:
    WHEN "link-changed" then do:
        run ini-from-selobj in this-procedure .
    end.
  END CASE.
END PROCEDURE.
