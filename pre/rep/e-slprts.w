CREATE WIDGET-POOL.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Печать Партии товара по документам".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION IsEngFrm RETURNS Logical  ( INPUT p-str as char) :
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE v-int as integer no-undo .
DEFINE VARIABLE v-char as character no-undo .
DEFINE VARIABLE v-dec as decimal no-undo .
if p-str begins '0':U then return yes.
if index(p-str, "E":U ) = 0 then return no.
if index(p-str, "+":U ) = 0
AND index(p-str, "-":U ) = 0 then return no.
assign
v-dec = decimal(entry(1, p-str, "E":U))
no-error .
if error-status:error then return no.
assign
v-int = integer(entry(2, p-str, "E":U))
no-error .
if error-status:error then return no.
assign
v-char = entry(2, p-str, "E":U)
.
if (substr(v-char, 1, 1) = "+":U and index(v-char, "-":U) = 0 )
OR
(substr(v-char, 1, 1) = "-":U and index(v-char, "+":U) = 0 )
then return yes.
END FUNCTION.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "X(65)" no-undo
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  NEW SHARED  temp-table doc-list-hist no-undo
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lhistprex-print-doc-list-hist-excel :
define input parameter p-text  as logical no-undo .
define input parameter p-excel as logical no-undo .
define input parameter p-sheet-num as integer no-undo .
define buffer buf_lh-sheetf for sheetf.
define buffer buf_doc-list-hist for doc-list-hist.
  do
  on error undo, return error
  :
    find first buf_doc-list-hist no-lock where buf_doc-list-hist.id = 0 no-error .
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
                                ,(if available buf_doc-list-hist
                                then buf_doc-list-hist.des
                                else "БЕЗЫМЯННЫЙ"))
                    ) .
    end.
    if p-text then do:
      Page stream PrnLibStream.
      PUT  STREAM PrnLibStream unformatted
      SPACE(25) substitute("История создания списка &1 &2"
                          , ''
                          ,(if available buf_doc-list-hist
                          then buf_doc-list-hist.des
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
    for each buf_doc-list-hist where buf_doc-list-hist.id > 0
    by buf_doc-list-hist.id
    :
      if p-text then do:
        put stream PrnLibStream unformatted
        (if buf_doc-list-hist.line = 0
        then string(buf_doc-list-hist.id, ">>>>>>>>9")
        else fill(chr(32) , 9)
        )  chr(32)
        (if buf_doc-list-hist.item_ <> '':U
        then string(buf_doc-list-hist.hist-mode, "X(8)")
        else fill( chr(32), 8)) chr(32)
        string(buf_doc-list-hist.num-add, ">>>>>>>>9") chr(32) chr(32) chr(32) chr(32)
        string(buf_doc-list-hist.num-recs, ">>>>>>>>9")  chr(32)
        (if page-size(PrnLibStream) > 43
        then string(buf_doc-list-hist.des, "X(" + string(136 - 43) + ")")
        else string(buf_doc-list-hist.des, "X(" + string(198 - 43) + ")"))
        skip.
      end.
      if p-excel then do:
        if Make-Excel then  put   stream ForExcel unformatted
        (if buf_doc-list-hist.line = 0
        then string(buf_doc-list-hist.id, ">>>>>>>>9")
        else '':U)
        CHR(9)
        (if buf_doc-list-hist.item_ <> '':U
        then buf_doc-list-hist.hist-mode
        else '':U)  CHR(9)
        (if buf_doc-list-hist.item_ <> '':U
        then string(buf_doc-list-hist.num-add, "->>>>>>>>9")
        else '':U)  CHR(9)
        (if buf_doc-list-hist.item_ <> '':U
        then string(buf_doc-list-hist.num-recs, ">>>>>>>>9")
        else '':U)  CHR(9)
        buf_doc-list-hist.des
        skip.
      end.
    end.
  end.
end procedure.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
def temp-table sj-goods no-undo
field b-code like ub.bar-code.b-code format "9999999999999"
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field gds-name   like ub.goods.gds-name format "x(30)"
field grp-name   like ub.goods.grp-name
field unit like ub.goods.unit-base
field struct  like ub.goods.struct
field cst-code like ub.parts.cst-code
field qnty              as   decimal
field uchet-sum-rubl   as decimal
field uchet-sum-base   as decimal
field sale-sum-rubl as decimal
field sale-sum-base as decimal
field VAT-pc       like ub.doc-line.VAT-pc
field SLT-pc       like ub.doc-line.SLT-pc
field VAT-supp      like ub.parts.VAT-pc
field SLT-supp like ub.parts.SLT-pc
field prt-root like ub.goods.prt-root
field is-prt as logical init no
field supp-type like ub.parts.supp-type
field supp-code like ub.parts.supp-code
field purch-code as integer
field pay-code as integer
field uchet-price-base like ub.parts.price-base
field uchet-price-rubl like ub.parts.price-base
field uchet-sum-base-without-tax like ub.parts.price-base
field uchet-sum-rubl-without-tax like ub.parts.price-base
field in-code like ub.parts.in-code
field fact-date like ub.parts.fact-date
field price-base  as decimal
field price-rubl  as decimal
field arch-date as date format "99/99/9999"
field obj-type like ub.parts.obj-type
field obj-code like ub.parts.obj-code
field is-out_ as integer
INDEX p1 IS PRIMARY
prod-type
prod-code
artic
supp-type
supp-code
SLT-pc
VAT-pc
VAT-supp
SLT-supp
purch-code
pay-code
in-code
obj-type
obj-code
.
DEFINE TEMP-TABLE d-slt-vat no-undo
              FIELD SLT-pc like ub.doc-line.SLT-pc
              FIELD VAT-pc like ub.doc-line.VAT-pc
              field VAT-supp      like ub.parts.VAT-pc
              field SLT-supp      like ub.parts.VAT-pc
              field uchet-sum-rubl   as decimal
              field uchet-sum-base   as decimal
              field sale-sum-rubl as decimal
              field sale-sum-base as decimal
              field supp-type like ub.parts.supp-type
              field supp-code like ub.parts.supp-code
              field purch-code as integer
              field pay-code as integer
              INDEX p1 IS PRIMARY supp-type supp-code SLT-pc VAT-pc VAT-supp SLT-supp purch-code pay-code ASCENDING .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
def var date_string     as      char    no-undo.
def var sale-stoim as decimal no-undo .
def var prt-qnty as decimal no-undo .
def var odoc-prt like ub.shop.doc-prt.
def buffer supplier for ub.clients.
def var ocons-pay like ub.sysconf.purch-code no-undo.
def var ocons-pay-2 like ub.sysconf.purch-code no-undo.
def var real-code like ub.sysconf.sale-code no-undo.
def var real-type like ub.sysconf.sale-type no-undo.
def buffer ret-doc for ub.trn-doc.
def buffer for-doc for ub.trn-doc.
def var doc-num like ub.trn-doc.doc-code.
define variable v-doc-type like ub.trn-doc.doc-type no-undo .
define variable v-internal like ub.trn-doc.internal no-undo .
def var my-accum as integer no-undo.
def var is-out as integer no-undo.
def var method as char no-undo.
def var for-title as char no-undo.
def var sale_sum_base as decimal no-undo.
def var sale_sum_rubl as decimal no-undo.
def var v-vat-pc        like ub.doc-line.vat-pc    no-undo.
def var v-slt-pc        like ub.doc-line.slt-pc    no-undo.
def var v-host-code     like ub.sysconf.host-code  no-undo.
DEFINE VARIABLE F-one AS CHARACTER FORMAT "X(256)":U
     LABEL "N накл."
     VIEW-AS FILL-IN
     SIZE 22.13 BY 1 NO-UNDO.
DEFINE VARIABLE RS-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Розница", "Sale":U,
"Расходные накладные", "RAS":U,
"Возвратные накладные", "VOZ":U,
"Расходные и возвратные накладные", "RAS+VOZ":U,
"Накладные списания", "SPI":U,
"Все", "ALL":U,
"СПИСОК док-тов(расход и возврат)", "LIST":U,
"Накладная N", "ONE":U
     SIZE 36.25 BY 4.54 NO-UNDO.
DEFINE RECTANGLE RECT-method
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.38 BY 6.33.
DEFINE RECTANGLE RECT-supp
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.38 BY 8.58.
DEFINE VARIABLE T-cons AS LOGICAL INITIAL no
     LABEL "Разделять конс. и выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-GTD AS LOGICAL INITIAL no
     LABEL "ГТД"
     VIEW-AS TOGGLE-BOX
     SIZE 36.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-parts AS LOGICAL INITIAL no
     LABEL "Каждую партию отдельной строкой"
     VIEW-AS TOGGLE-BOX
     SIZE 36.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-sostav AS LOGICAL INITIAL no
     LABEL "Состав сырья"
     VIEW-AS TOGGLE-BOX
     SIZE 36.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-split AS LOGICAL INITIAL no
     LABEL "Разделять расход/возврат"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-supp AS LOGICAL INITIAL no
     LABEL "Указывать поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 22.88 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE FRAME F-Main
     T-supp AT ROW 1.46 COL 4.13
     T-cons AT ROW 3 COL 3.88
     T-parts AT ROW 4.42 COL 3.88
     T-GTD AT ROW 5.54 COL 6.5
     T-sostav AT ROW 6.83 COL 4
     T-split AT ROW 8.29 COL 3.75
     RS-method AT ROW 10.21 COL 14.38 NO-LABEL
     F-one AT ROW 14.96 COL 12.5 COLON-ALIGNED
     "расчета" VIEW-AS TEXT
          SIZE 10.38 BY 1 AT ROW 11.21 COL 3
          FGCOLOR 4
     "Источник" VIEW-AS TEXT
          SIZE 10.25 BY .83 AT ROW 10.29 COL 3.25
          FGCOLOR 4
     RECT-method AT ROW 9.96 COL 2.25
     RECT-supp AT ROW 1.17 COL 2.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 53.38 BY 15.54.
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
    DISABLE RECT-method RECT-supp T-supp T-cons T-parts T-sostav T-split RS-method WITH FRAME F-Main.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN RECT-method RECT-supp T-supp T-cons T-parts T-sostav T-split RS-method WITH FRAME F-Main.
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
ON VALUE-CHANGED OF RS-method IN FRAME F-Main
DO:
  assign RS-METHOD.
  IF RS-METHOD = "ONE" then
  ENABLE
  f-ONE
  WITH FRAME F-Main.
  ELSE
  HIDE
  f-ONE
  IN FRAME F-Main.
  if rs-method = "LIST":U then do:
    run str/doc-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
  end.
END.
ON VALUE-CHANGED OF T-parts IN FRAME F-Main
DO:
 assign
  T-parts.
  if T-parts then do:
    assign
    T-cons = yes
    T-supp = yes
    .
    ENABLE T-GTD
        with frame F-Main.
    DISPLAY
    T-cons
    T-supp
    WITH FRAME F-Main.
  end.
  else do:
    assign
    T-GTD = no
    .
    DISPLAY
    T-GTD
    WITH FRAME F-Main.
    DISABLE T-GTD
        with frame F-Main.
  end.
END.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE cr-sj-goods :
DEFINE VARIABLE         v-parts-VAt-pc  like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-parts-SLT-pc  like ub.parts-attr.SLT-pc           no-undo .
DEFINE VARIABLE         v-supp-type     like ub.parts-attr.supp-type        no-undo .
DEFINE VARIABLE         v-supp-code     like ub.parts-attr.supp-code        no-undo .
DEFINE VARIABLE         v-purch-code    like ub.parts-attr.purch-code       no-undo .
define variable         v-pay-code      like ub.parts.pay-code              no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-fact-date     like ub.parts-attr.fact-date        no-undo .
DEFINE VARIABLE         v-obj-type      like ub.parts.obj-type              no-undo .
DEFINE VARIABLE         v-obj-code      like ub.parts.obj-code              no-undo .
DEFINE VARIABLE         v-cst-code      like ub.parts.cst-code              no-undo .
DEFINE VARIABLE         v-is-attr       as logical no-undo .
define variable         v-is-primary    as logical no-undo .
define variable         v-grp-name      as character no-undo .
define buffer buf_parts-attr for ub.parts-attr.
define buffer buf_pay-type  for ub.pay-type.
define buffer bf-in_parts-attr for ub.parts-attr.
define buffer buf_trn-stp for ub.trn-doc.
define buffer buf_parts-stp for ub.parts.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FOR each ub.doc-line NO-LOCk WHERE
        ub.doc-line.doc-code = doc-num:
  my-accum = my-accum + 1.
  IF my-accum MODULO 50  = 0 then do:
      run waitfram-show in this-procedure ("Обработано " + string(my-accum) + " строк накладных ").
  end.
  assign
  sale_sum_base = 0
  sale_sum_rubl = 0
  .
  FOR EACH ub.gds-dtl No-LOCK WHERE
          ub.gds-dtl.doc-code = ub.doc-line.doc-code AND
          ub.gds-dtl.artic = ub.doc-line.artic AND
          ub.gds-dtl.prod-type = ub.doc-line.prod-type AND
          ub.gds-dtl.prod-code = ub.doc-line.prod-code:
    assign
    sale_sum_base = sale_sum_base + (ub.gds-dtl.price-base - ub.gds-dtl.discnt-base) * ub.gds-dtl.fact-qnty
    sale_sum_rubl = sale_sum_rubl + (ub.gds-dtl.price-rubl - ub.gds-dtl.discnt-rubl) * ub.gds-dtl.fact-qnty
    .
  END.
  FIND FIRST ub.gds-obj  No-LOCK  WHERE
            ub.gds-obj.artic = ub.doc-line.artic AND
            ub.gds-obj.prod-type = ub.doc-line.prod-type AND
            ub.gds-obj.prod-code = ub.doc-line.prod-code AND
            ub.gds-obj.obj-type = obj-list.obj-type AND
            ub.gds-obj.obj-code = obj-list.obj-code No-ERROR.
  FOR EACH ub.parts NO-LOCK WHERE
          ub.parts.artic = ub.doc-line.artic AND
          ub.parts.prod-type = ub.doc-line.prod-type AND
          ub.parts.prod-code = ub.doc-line.prod-code AND
          ub.parts.out-code = doc-num AND
          ub.parts.obj-type = ub.doc-line.obj-type AND
          ub.parts.obj-code = ub.doc-line.obj-code:
    assign
    v-is-primary = no
    .
    find first buf_parts-attr no-lock where
              buf_parts-attr.in-code  = ub.parts.in-code
         AND  buf_parts-attr.gds-code = ub.gds-obj.gds-code
         AND buf_parts-attr.part-code = ub.parts.part-code no-error .
    if available buf_parts-attr then do:
      if v-doc-type = 'рас':U
      and v-internal = no then do:
        find first buf_trn-stp no-lock where
                  buf_trn-stp.out-code = doc-num
              AND buf_trn-stp.ext-doc-type = 'pc':U no-error.
        if available buf_trn-stp  and buf_parts-attr.in-code = buf_trn-stp.doc-code then do:
          find first buf_parts-stp no-lock where
                    buf_parts-stp.obj-type = ub.parts.obj-type
                AND buf_parts-stp.obj-code = ub.parts.obj-code
                AND buf_parts-stp.artic    = ub.parts.artic
                AND buf_parts-stp.prod-type    = ub.parts.prod-type
                AND buf_parts-stp.prod-code   = ub.parts.prod-code
                AND buf_parts-stp.in-code    = buf_trn-stp.doc-code
                AND buf_parts-stp.out-code    = buf_trn-stp.doc-code
                AND buf_parts-stp.part-code    = parts.part-code no-error.
          if available buf_parts-stp then do:
            find first bf-in_parts-attr no-lock where
                bf-in_parts-attr.in-code   = buf_parts-attr.income-in-code   AND
                bf-in_parts-attr.gds-code  = ub.gds-obj.gds-code              AND
                bf-in_parts-attr.part-code = buf_parts-attr.income-part-code NO-ERROR.
            if available bf-in_parts-attr then do:
              assign
              v-is-primary = yes
              .
              assign
              v-is-attr      = yes
              v-parts-VAt-pc = bf-in_parts-attr.vat-pc
              v-parts-SLT-pc = bf-in_parts-attr.SLT-pc
              v-supp-type = bf-in_parts-attr.supp-type
              v-supp-code = bf-in_parts-attr.supp-code
              v-purch-code = (IF parts.purch-code = integer('1':U)
                              AND bf-in_parts-attr.purch-code = integer('4':U)
                              then integer('3':U)
                              else  bf-in_parts-attr.purch-code
                            )
              v-pay-code  = bf-in_parts-attr.pay-code
              v-in-code = bf-in_parts-attr.income-in-code
              v-fact-date = bf-in_parts-attr.fact-date
              v-obj-type =  parts.obj-type
              v-obj-code =  parts.obj-code
              v-cst-code = bf-in_parts-attr.cst-code
              .
            end.
          end.
        end.
        if not v-is-primary then do:
          assign
          v-is-attr      = yes
          v-parts-VAt-pc = buf_parts-attr.vat-pc
          v-parts-SLT-pc = buf_parts-attr.SLT-pc
          v-supp-type = buf_parts-attr.supp-type
          v-supp-code = buf_parts-attr.supp-code
          v-purch-code = buf_parts-attr.purch-code
          v-pay-code  = buf_parts-attr.pay-code
          v-in-code = buf_parts-attr.in-code
          v-fact-date = (if buf_parts-attr.in-code = buf_parts-attr.income-in-code
                          then buf_parts-attr.fact-date
                          else ?)
          v-obj-type =  ub.parts.obj-type
          v-obj-code =  ub.parts.obj-code
          v-cst-code = buf_parts-attr.cst-code
          .
          if v-fact-date = ? then do:
            if T-parts then do:
              FIND FIRST ub.trn-doc No-LOCK WHERE
                          ub.trn-doc.doc-code = v-in-code No-ERROR.
            end.
            if avail ub.trn-doc then do:
              assign
              v-fact-date = ub.trn-doc.fact-date
              .
            end.
          end.
        end.
      end.
      if NOT (v-doc-type = 'рас':U and v-internal = no)
      or not available bf-in_parts-attr
      then do:
        assign
        v-is-attr      = yes
        v-parts-VAt-pc = buf_parts-attr.vat-pc
        v-parts-SLT-pc = buf_parts-attr.SLT-pc
        v-supp-type = buf_parts-attr.supp-type
        v-supp-code = buf_parts-attr.supp-code
        v-purch-code = buf_parts-attr.purch-code
        v-pay-code  = buf_parts-attr.pay-code
        v-in-code = buf_parts-attr.income-in-code
        v-fact-date = buf_parts-attr.fact-date
        v-obj-type =  ub.parts.obj-type
        v-obj-code =  ub.parts.obj-code
        v-cst-code = buf_parts-attr.cst-code
        .
      end.
    end.
    else do:
      assign
      v-is-attr      = no
      v-parts-VAt-pc = ub.parts.vat-pc
      v-parts-SLT-pc = ub.parts.SLT-pc
      v-supp-type = ub.parts.supp-type
      v-supp-code = ub.parts.supp-code
      v-purch-code = ub.parts.purch-code
      v-pay-code  = ub.parts.pay-code
      v-in-code = ub.parts.in-code
      v-fact-date = ?
      v-obj-type =  ub.parts.obj-type
      v-obj-code =  ub.parts.obj-code
      v-cst-code = ub.parts.cst-code
      .
      if T-parts then do:
        FIND FIRST ub.trn-doc No-LOCK WHERE
                    ub.trn-doc.doc-code = ub.parts.in-code No-ERROR.
      end.
      if avail ub.trn-doc then do:
        assign
        v-fact-date = ub.trn-doc.fact-date
        .
      end.
    end.
    release bf-in_parts-attr.
    IF NOT T-parts then do:
      IF T-supp then do:
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.doc-line.artic
              AND sj-goods.prod-type = ub.doc-line.prod-type
              AND sj-goods.prod-code = ub.doc-line.prod-code
              AND sj-goods.VAT-supp = v-parts-VAT-pc
              AND sj-goods.SLT-supp = v-parts-SLT-pc
              AND sj-goods.supp-type = v-supp-type
              AND sj-goods.supp-code = v-supp-code
              AND (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                  and
                  sj-goods.pay-code = v-pay-code)
                  )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
      end.
      ELSE do:
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.doc-line.artic
              AND sj-goods.prod-type = ub.doc-line.prod-type
              AND sj-goods.prod-code = ub.doc-line.prod-code
              AND sj-goods.VAT-supp = v-parts-VAT-pc
              AND sj-goods.SLT-supp = v-parts-SLT-pc
              AND (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                  and
                  sj-goods.pay-code = v-pay-code)
                  )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
      end.
    END.
    else do:
      IF T-supp then do:
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.doc-line.artic
              AND sj-goods.prod-type = ub.doc-line.prod-type
              AND sj-goods.prod-code = ub.doc-line.prod-code
              AND sj-goods.VAT-supp = v-parts-VAT-pc
              AND sj-goods.SLT-supp = v-parts-SLT-pc
              AND sj-goods.supp-type = v-supp-type
              AND sj-goods.supp-code = v-supp-code
              AND sj-goods.in-code = v-in-code
              AND (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                  and
                  sj-goods.pay-code = v-pay-code)
                  )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
      end.
      ELSE do:
        FIND FIRST sj-goods WHERE
                   sj-goods.artic = ub.doc-line.artic
              AND  sj-goods.prod-type = ub.doc-line.prod-type
              AND  sj-goods.prod-code = ub.doc-line.prod-code
              AND  sj-goods.VAT-supp = v-parts-VAT-pc
              AND  sj-goods.SLT-supp = v-parts-SLT-pc
              AND  sj-goods.in-code = v-in-code
              AND   (NOT T-cons OR
                     (sj-goods.purch-code = v-purch-code
                     and
                     sj-goods.pay-code = v-pay-code)
                    )
              AND sj-goods.obj-type = for-doc.obj-type
              AND sj-goods.obj-code = for-doc.obj-code
                  No-error.
        end.
      end.
      if not avail sj-goods
      OR
      (T-split
        AND
      sj-goods.is-out_ <> is-out) then do:
        FIND FIRST ub.goods No-LOCK WHERE
                    ub.goods.artic = ub.doc-line.artic AND
                    ub.goods.prod-type = ub.doc-line.prod-type AND
                    ub.goods.prod-code = ub.doc-line.prod-code No-ERROR.
        FIND ub.gds-prt where
            ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
        FIND FIRST ub.bar-code No-LOCK WHERE
                  ub.bar-code.gds-code = ub.goods.gds-code AND
                  ub.bar-code.in-code = "" AND
                  ub.bar-code.part-code = "" AND
                  ub.bar-code.node-code =  ub.gds-prt.node-code AND
                  ub.bar-code.unit-cli = ub.goods.unit-base NO-ERROR.
        create sj-goods.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-vat-pc
  ) no-error .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-slt-pc
  ) no-error .
        run grplib-get-full-name in this-procedure (
                                                     input goods.grp-code
                                                    ,output v-grp-name) no-error .
        if error-status:error then do:
          v-grp-name = "!!!!НЕИЗВЕСТНАЯ ГРУППА".
        end.
        assign
        sj-goods.artic = ub.goods.artic
        sj-goods.prod-type = ub.goods.prod-type
        sj-goods.prod-code = ub.goods.prod-code
        sj-goods.b-code = ub.bar-code.b-code
        sj-goods.VAT-PC = v-vat-pc
        sj-goods.SLT-pc = v-slt-pc
        sj-goods.unit = ub.goods.unit-base
        sj-goods.struct = ub.goods.struct
        sj-goods.cst-code = v-cst-code
        sj-goods.is-prt = ub.gds-prt.node-name <> '_Пустая шкала':U
        sj-goods.prt-root = ub.goods.prt-root
        sj-goods.gds-name = REPLACE(ub.goods.gds-name, " ", "_")
        sj-goods.grp-name = ub.goods.grp-name
        sj-goods.VAT-supp = v-parts-VAT-pc
        sj-goods.SLT-supp = v-parts-SLT-pc
        sj-goods.supp-type = IF T-supp OR T-parts then v-supp-type else ""
        sj-goods.supp-code = IF T-supp OR T-parts then v-supp-code else 0
        sj-goods.purch-code = IF T-cons or T-parts
                            then v-purch-code
                            else sj-goods.purch-code
        sj-goods.pay-code = IF T-cons or T-parts
                            then v-pay-code
                            else sj-goods.pay-code
        sj-goods.in-code = if T-parts then v-in-code else ""
        sj-goods.fact-date = if T-parts then v-fact-date else ?
        sj-goods.arch-date = if T-parts then v-fact-date else ?
        sj-goods.obj-code = if T-parts then v-obj-code else ?
        sj-goods.obj-type = if T-parts then v-obj-type else ?
        sj-goods.is-out_ = is-out
        .
      END.
assign
  price-rubl-with-tax-loc = parts.price-rubl
  price-base-with-tax-loc = parts.price-base
.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if parts.out-code = 'free-zone':U     or
     parts.out-code = 'out-zone':U   or
     parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = parts.price-cli
   cli-base-rate          = parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if parts.road-tax-base  = ? then 0 else parts.road-tax-base)
           road-tax-rubl-loc  = (if parts.road-tax-rubl  = ? then 0 else parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if parts.transport-base = ? then 0 else parts.transport-base)
          transport-rubl-loc = (if parts.transport-rubl = ? then 0 else parts.transport-rubl)
          other-base-loc     = (if parts.other-base     = ? then 0 else parts.other-base)
          other-rubl-loc     = (if parts.other-rubl     = ? then 0 else parts.other-rubl)
          vat-pc-loc         = (if parts.vat-pc         = ? then 0 else parts.vat-pc)
          slt-pc-loc         = (if parts.slt-pc         = ? then 0 else parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
      prt-qnty =  is-out * ub.parts.fact-qnty
      sj-goods.qnty = sj-goods.qnty +  prt-qnty
      sj-goods.sale-sum-base = sj-goods.sale-sum-base + sale_sum_base / doc-line.fact-qnty  * prt-qnty
      sj-goods.sale-sum-rubl = sj-goods.sale-sum-rubl + sale_sum_rubl / doc-line.fact-qnty * prt-qnty
      sj-goods.uchet-price-base = if T-parts then ub.parts.price-base else 0
      sj-goods.uchet-price-rubl = if T-parts then ub.parts.price-rubl else 0
      sj-goods.uchet-sum-base = sj-goods.uchet-sum-base + ub.parts.price-base * prt-qnty
      sj-goods.uchet-sum-rubl = sj-goods.uchet-sum-rubl + ub.parts.price-rubl * prt-qnty
      sj-goods.uchet-sum-base-without-tax = sj-goods.uchet-sum-base-without-tax +
                                            (price-base-with-tax-loc - slt-base-loc - vat-base-loc) * prt-qnty
      sj-goods.uchet-sum-rubl-without-tax = sj-goods.uchet-sum-rubl-without-tax +
                                            (price-rubl-with-tax-loc  - slt-rubl-loc - vat-rubl-loc) * prt-qnty
      .
  END.
END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-supp T-cons T-parts T-GTD T-sostav T-split RS-method F-one
      WITH FRAME F-Main.
  ENABLE RECT-method RECT-supp T-supp T-cons T-parts T-sostav T-split RS-method
      WITH FRAME F-Main.
END PROCEDURE.
PROCEDURE My-report :
DEFINE VARIABLE         v-supplier      like ub.clients.obj-name            no-undo .
DEFINE VARIABLE         v-producer      like ub.clients.obj-name            no-undo .
define buffer buf_pay-type for ub.pay-type  .
run My-var.
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'report-firm':U
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
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.
assign
date_string = cur-time-print() .
run waitfram-show in this-procedure ( input "Подождите ..." ).
FOR EACH sj-goods :
    delete sj-goods.
END .
FOR EACH d-slt-vat :
    delete d-slt-vat .
END .
if not can-find(first obj-list) then do:
  run waitfram-hide in this-procedure .
  message
  "Не выбрано ни одного объекта по текущей фирме!"
  view-as alert-box WARNING.
  return.
end.
my-accum = 0.
FOR EACH obj-list NO-LOCK:
    IF obj-list.obj-type = 'маг':U then do:
        FIND FIRST ub.shop NO-LOCK WHERE ub.shop.obj-code = obj-list.obj-code no-error.
        FIND FIRST ub.Sysconf No-LOCK WHERE ub.sysconf.host-code = ub.shop.host-code No-ERROR.
        assign
        odoc-prt = ub.shop.doc-prt
        ocons-pay = integer('2':U)
        ocons-pay-2 = integer('4':U)
        real-code = ub.sysconf.sale-code
        real-type = ub.sysconf.sale-type
        .
    end.
    else do:
        FIND FIRST ub.store NO-LOCK WHERE ub.store.obj-code = obj-list.obj-code no-error.
        FIND FIRST ub.Sysconf No-LOCK WHERE ub.sysconf.host-code = ub.store.host-code No-ERROR.
        assign
        odoc-prt = ub.store.doc-prt
        ocons-pay = integer('2':U)
        ocons-pay-2 = integer('4':U)
        real-code = ub.sysconf.sale-code
        real-type = ub.sysconf.sale-type
        .
    end.
    CASE Rs-method:
    WHEN "SALE":U then do:
    if obj-list.obj-type = 'скл':U then NEXT.
    FOR EACH ub.inkas no-LOCK where
            ub.inkas.doc-date >= X-date-start
        AND ub.inkas.doc-date <= X-date-end
        AND ub.inkas.obj-type = obj-list.obj-type
        AND ub.inkas.obj-code = obj-list.obj-code
        AND   ub.inkas.status_ = 'факт':U,
       each buf_sale-doc  no-lock where
            buf_sale-doc.inkas-code = ub.inkas.inkas-code
        and buf_sale-doc.in-inkas = yes
        and buf_sale-doc.chr-office = 'т':U:
        assign
        doc-num = buf_sale-doc.doc-code
        v-doc-type = buf_sale-doc.doc-type
        v-internal = buf_sale-doc.internal
        is-out = buf_sale-doc.dir
        .
        run cr-sj-goods in this-procedure.
      END.
      FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
              for-doc.obj-code = obj-list.obj-code AND
              for-doc.internal = no AND
              for-doc.doc-date >= X-date-start AND
              for-doc.doc-date <= X-date-end AND
              for-doc.doc-type  =  'возврат':U AND
              for-doc.status_ = 'факт':U AND
              for-doc.ext-doc-type = 're':U:
        if NOT (for-doc.cli-code = real-code and for-doc.cli-type = real-type) then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = - 1
        .
        run cr-sj-goods in this-procedure.
      END.
      FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
              for-doc.obj-code = obj-list.obj-code AND
              for-doc.internal = no AND
              for-doc.doc-date >= X-date-start AND
              for-doc.doc-date <= X-date-end AND
              for-doc.doc-type  =  'рас':U AND
              for-doc.status_ = 'факт':U AND
              for-doc.ext-doc-type = 'ee':U:
        if NOT (for-doc.cli-code = real-code and for-doc.cli-type = real-type) then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
      END.
    END.
    WHEN "RAS":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  'рас':U AND
                for-doc.status_ = 'факт':U:
        if for-doc.ext-doc-type = 'es':U
          or for-doc.ext-doc-type = 'ep':U
          or for-doc.office
        then do:
          next.
        end.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "VOZ":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  'возврат':U AND
                for-doc.status_ = 'факт':U:
        if for-doc.ext-doc-type = 'rs':U
        OR for-doc.office
        then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = - 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "RAS+VOZ":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  'рас':U AND
                for-doc.status_ = 'факт':U:
        if for-doc.ext-doc-type = 'es':U
          or for-doc.ext-doc-type = 'ep':U
          or for-doc.office
        then do:
          next.
        end.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
        END.
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  'возврат':U AND
                for-doc.status_ = 'факт':U:
        if for-doc.ext-doc-type = 'rs':U
        OR for-doc.office
        then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = - 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "SPI":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  'спи':U AND
                for-doc.status_ = 'факт':U:
        if for-doc.office
        then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "ALL":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.status_ = 'факт':U:
        if for-doc.doc-type = 'инв':U
          or for-doc.doc-type = 'спи':U
          or for-doc.doc-type = 'при':U
          or for-doc.ext-doc-type = 'ep':U
          or for-doc.office
        then do:
          next.
        end.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = if for-doc.doc-type = 'рас':U then 1 else -1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "ONE":U then do:
        FOR EACH for-doc No-LOCK WHERE for-doc.doc-code = f-one:
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = if for-doc.doc-type = 'рас':U then 1 else -1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "LIST":U then do:
      _doc-list:
      for each doc-list no-lock where
               doc-list.obj-type = obj-list.obj-type
           AND doc-list.obj-code = obj-list.obj-code,
         first for-doc No-LOCK WHERE for-doc.doc-code = doc-list.doc-code:
        if doc-list.doc-type <> 'рас':U
        and doc-list.doc-type <> 'возврат':U then next _doc-list.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = if for-doc.doc-type = 'рас':U then 1 else -1
        .
        run cr-sj-goods in this-procedure.
      END.
    END.
    END CASE.
END.
run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input 62
                                            ,input yes
                                            ,input no
                                            ).
run waitfram-show in this-procedure ("Ждите...").
PUT stream PrnLibStream UNFORMATTED
("Партии товара" +
(if Rs-method <> "ONE"
then (", реализованного с " +
string( X-date-start, "99/99/9999" ) + " по " + string(X-date-end, "99/99/9999") + ".")
else "") )     format "x(110)" SKIP(1).
PUT stream PrnLibStream ("Источник расчета: "  + for-title) format "X(60)" SKIP(0).
PUT stream PrnLibStream string("По объектам: "  )
    format "X(20)" SKIP.
FOR EACH obj-list :
FIND FIRST ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                                  ub.clients.obj-code = obj-list.obj-code NO-LOCK .
PUT stream PrnLibStream UNFORMATTED ub.clients.obj-name  ", ".
END.
PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)" SKIP.
PUT stream PrnLibStream " " SKIP(1) .
PUT stream PrnLibStream UNFORMATTED
"Тип_производителя" p-XL-delim
"Код_производителя"  p-XL-delim
"Производитель"  p-XL-delim
"Артикул" p-XL-delim
"Бар-код" p-XL-delim
"Название" p-XL-delim
"Ед.изм" p-XL-delim
(if T-sostav
then ("Состав сырья" + p-XL-delim)
else "":U)
"НДС" p-XL-delim
"НП" p-XL-delim
(IF T-supp then
("Тип_поставщика" + p-XL-delim + "Код_поставщика" + p-XL-delim + "Поставщик" + p-XL-delim)
else "")
(IF T-cons then
("Консигнационный_товар" + p-XL-delim)
else "")
(IF T-cons or T-parts
then
("Тип оплаты"  + p-XL-delim)
else "":U)
"НДС_поставщ" p-XL-delim
"НП_поставщ" p-XL-delim
(IF T-GTD then
("ГТД" + p-XL-delim)
else "")
(if T-parts
then ("Учетн.цена_с НДС_НП_баз.вал." + p-XL-delim +
         "Учетн.цена_с НДС_НП_рубли" + p-XL-delim +
         "N_прих.док-та" + p-XL-delim +
         "Дата_приходного_док-та" + p-XL-delim)
else ""
)
"Реализованное_количество" p-XL-delim
"Сумма_учет_цен_баз.вал" p-XL-delim
"Сумма_учет_цен_баз.вал_без_НДС_НП" p-XL-delim
"Сумма_учет_цен_рубли" p-XL-delim
"Сумма_учет_цен_рубли_без_НДС_НП" p-XL-delim
"Сумма_продаж_цен_баз.вал" p-XL-delim
"Сумма_продаж_цен_рубли" p-XL-delim
(if T-parts
then
("Тип_объекта" + p-XL-delim +
"Код_объекта" + p-XL-delim +
"Факт.дата_партии" + p-XL-delim)
else "") +
"Группа товара"
SKIP(0).
run rep/extitle.p (1).
FOR EACH sj-goods NO-LOCK use-index p1
    break by sj-goods.prod-type
          by sj-goods.prod-code
          by sj-goods.supp-type
          BY sj-goods.supp-code:
    IF FIRST-OF(sj-goods.supp-code) then do:
        FIND FIRST supplier NO-LOCK WHERE
                   supplier.obj-type = sj-goods.supp-type AND
                   supplier.obj-code = sj-goods.supp-code NO-ERROR.
       assign
       v-supplier = (if available supplier
                     then supplier.obj-name
                     else "":U)
       .
    end.
    IF FIRST-OF(sj-goods.prod-code) then do:
        FIND FIRST clients NO-LOCK WHERE
                   clients.obj-type = sj-goods.prod-type AND
                   clients.obj-code = sj-goods.prod-code NO-ERROR.
       assign
       v-producer = (if available clients
                     then clients.obj-name
                     else "":U)
       .
    end.
if T-cons or T-parts then
find first buf_pay-type no-lock where
          buf_pay-type.obj-code = sj-goods.pay-code no-error .
    PUT stream PrnLibStream UNFORMATTED
    sj-goods.prod-type p-XL-delim
    sj-goods.prod-code p-XL-delim
    REPLACE(v-producer, " ", "_") p-XL-delim
    sj-goods.artic p-XL-delim
    sj-goods.b-code p-XL-delim
    sj-goods.gds-name p-XL-delim
    sj-goods.unit p-XL-delim
    (if T-sostav
    then (sj-goods.struct + p-XL-delim)
    else "":U)
    sj-goods.VAT-pc p-XL-delim
    sj-goods.SLT-pc p-XL-delim
    (IF T-supp then
    (sj-goods.SUPP-type + p-XL-delim +
    string(sj-goods.SUPP-code) + p-XL-delim +
    REPLACE(v-supplier, " ", "_") + p-XL-delim
    )
    ELSE "")
    (IF T-cons then
    (entry (lookup (string(sj-goods.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U) + p-XL-delim)
    ELSE "")
    (IF T-cons or T-parts
    then
    (if available buf_pay-type
    then (buf_pay-type.obj-name + p-XL-delim)
    else p-XL-delim)
    ELSE "":U
    )
    sj-goods.VAT-supp p-XL-delim
    sj-goods.SLT-supp p-XL-delim
    (if T-GTD
     then
     (sj-goods.cst-code + p-XL-delim)
     else "":U
     )
    (if T-parts
    then (
     (if sj-goods.uchet-price-base <> ?
      then string(sj-goods.uchet-price-base)
      else "":U)  +  p-XL-delim +
     (if sj-goods.uchet-price-rubl <> ?
      then string(sj-goods.uchet-price-rubl)
      else "":U)  +  p-XL-delim +
      (if sj-goods.in-code <> ?
       then sj-goods.in-code
       else "":U) + p-XL-delim +
     (if sj-goods.fact-date = ?
       then "":U
       else string(sj-goods.fact-date, "99/99/9999")) + p-XL-delim
        )
     else ""
     )
    sj-goods.qnty p-XL-delim
    sj-goods.uchet-sum-base p-XL-delim
    sj-goods.uchet-sum-base-without-tax  p-XL-delim
    sj-goods.uchet-sum-rubl p-XL-delim
    sj-goods.uchet-sum-rubl-without-tax p-XL-delim
    sj-goods.sale-sum-base p-XL-delim
    sj-goods.sale-sum-rubl p-XL-delim
    (if T-parts
    then (
     sj-goods.obj-type + p-XL-delim +
     string(sj-goods.obj-code, "99999") + p-XL-delim +
     (if sj-goods.arch-date = ?
     then "":U
     else string(sj-goods.arch-date, "99/99/9999")) + p-XL-delim
          )
    else "")
    sj-goods.grp-name
    SKIP(0).
    if Make-Excel then  put   stream ForExcel unformatted
    sj-goods.prod-type CHR(9)
    sj-goods.prod-code CHR(9)
    REPLACE(v-producer, " ", "_") CHR(9)
    (chr(4) + sj-goods.artic)  CHR(9)
    sj-goods.b-code CHR(9)
    sj-goods.gds-name CHR(9)
    sj-goods.unit CHR(9)
    (if T-sostav
     then (sj-goods.struct + CHR(9))
     else "")
    sj-goods.VAT-pc CHR(9)
    sj-goods.SLT-pc CHR(9)
    (IF T-supp then
    (sj-goods.SUPP-type + CHR(9) +
    string(sj-goods.SUPP-code) + CHR(9) +
    REPLACE(v-SUPPLIER, " ", "_") + CHR(9)
    )
    ELSE "")
    (IF T-cons then
    (entry (lookup (string(sj-goods.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U) + CHR(9))
    ELSE "")
    (IF T-cons or T-parts
    then
    (if available buf_pay-type
    then (buf_pay-type.obj-name + CHR(9))
    else CHR(9))
    ELSE "":U
    )
    sj-goods.VAT-supp CHR(9)
    sj-goods.SLT-supp CHR(9)
    (if T-GTD
     then (sj-goods.cst-code + CHR(9))
     else "":U
     )
     (if T-parts
     then (
           (if sj-goods.uchet-price-base <> ?
            then string(sj-goods.uchet-price-base)
            else "":U)  +  CHR(9) +
           (if sj-goods.uchet-price-rubl <> ?
            then string(sj-goods.uchet-price-rubl)
            else "":U)  +  CHR(9) +
            (if sj-goods.in-code <> ?
            then sj-goods.in-code
            else "":U) + CHR(9) +
           (if sj-goods.fact-date = ?
            then "":U
            else string(sj-goods.fact-date, "99/99/9999")) + CHR(9)
           )
     else ""
     )
    sj-goods.qnty CHR(9)
    sj-goods.uchet-sum-base CHR(9)
    sj-goods.uchet-sum-base-without-tax  CHR(9)
    sj-goods.uchet-sum-rubl CHR(9)
    sj-goods.uchet-sum-rubl-without-tax CHR(9)
    sj-goods.sale-sum-base CHR(9)
    sj-goods.sale-sum-rubl CHR(9)
    (if T-parts
     then
     (sj-goods.obj-type + CHR(9) +
     string(sj-goods.obj-code, "99999") + CHR(9) +
      (if sj-goods.arch-date = ?
      then '':U
      else string(sj-goods.arch-date, "99/99/9999")) + CHR(9))
     else ""
    ) CHR(9)
    sj-goods.grp-name
    SKIP(0).
END.
if Print-List-hist
and rs-method = "LIST" then do:
  run lhistprex-print-doc-list-hist-excel  in this-procedure (input yes, input yes, 2).
end.
output stream PrnLibStream CLOSE .
if Make-Excel then output stream ForExcel close.
assign
sheetf.colformat = sheetf.colformat + chr(4) + "4=@"
.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 11
                                          ).
END PROCEDURE.
PROCEDURE My-var :
DEFINE VARIABLE vnum-t-cons as integer no-undo .
DEFINE VARIABLE vnum-t-parts as integer no-undo .
DEFINE VARIABLE vnum-t-supp as integer no-undo .
DEFINE VARIABLE vnum-t-sostav as integer no-undo .
DEFINE VARIABLE vnum-t-GTD as integer no-undo .
assign
frame F-Main RS-method
frame F-Main T-cons
frame F-Main T-parts
frame F-Main T-supp
frame F-Main F-one
frame F-Main T-sostav
frame F-Main T-GTD
frame F-Main T-split
.
for-title = radio-label(string(RS-method), Rs-method:radio-buttons).
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.
assign
vnum-t-cons = (IF T-cons then (1  + if T-parts then 1 else 0) else 0)
vnum-t-parts = (IF T-parts then 7 else 0)
vnum-t-supp = (IF T-supp then 3 else 0)
vnum-t-sostav = (IF T-sostav then 1 else 0)
vnum-t-gtd = (IF t-gtd then 1 else 0)
sheetf.colformat = (if t-parts
                   then
                   ("4=0;":U +
                   string(7 + vnum-T-sostav + 2 + vnum-T-supp + vnum-t-cons + vnum-t-gtd + 2 + 4) + "=dd/mm/yyyy":U + ";":U +
                   string(7 + vnum-T-sostav + 2 + vnum-T-supp + vnum-t-cons + vnum-t-gtd + 2 + 7 + vnum-t-parts) + "=dd/mm/yyyy":U
                   )
                   else "4=0":U)
sheetf.Excel-Column-Lable =
"Тип_производителя" + chr(44) +
"Код_производителя" +  chr(44) +
"Производитель" +  chr(44) +
"Артикул" + chr(44) +
"Бар-код" + chr(44) +
"Название" + chr(44) +
"Ед.изм" + chr(44) +
(if T-sostav
then ("Состав_сырья" + chr(44))
else "":U) +
"НДС" + chr(44) +
"НП" + chr(44) +
(IF T-supp then
("Тип_поставщика" + chr(44) + "Код_поставщика" + chr(44) + "Поставщик" + chr(44) )
else "") +
(IF T-cons then
("Консигнационный_товар" + chr(44) )
else "")  +
(IF T-cons or T-parts then
("Вид_оплаты" + chr(44) )
else "")  +
"НДС_поставщ" + chr(44) +
"НП_поставщ" + chr(44) +
(IF T-GTD then
("ГТД" + chr(44) )
else "")  +
(if T-parts
then ("Учетн.цена_с НДС_НП_баз.вал." + chr(44) +
         "Учетн.цена_с НДС_НП_рубли" + chr(44) +
         "N_прих.док-та" + chr(44) +
         "Дата_приходного_док-та" + chr(44))
else ""
) +
"Реализованное_количество" + chr(44) +
"Сумма_учет_цен_баз.вал" + chr(44) +
"Сумма_учет_цен_баз.вал_без_НДС_НП" + chr(44) +
"Сумма_учет_цен_рубли" + chr(44) +
"Сумма_учет_цен_рубли_без_НДС_НП" + chr(44) +
"Сумма_продаж_цен_баз.вал" + chr(44) +
"Сумма_продаж_цен_рубли" + chr(44) +
(if T-parts
then
("Тип_объекта" + chr(44) +
"Код_объекта" + chr(44) +
"Факт.дата_партии" + chr(44))
else "") + chr(44) +
"Группа товара"
sheetf.Sizes =
"3" + chr(44) +
"9" +  chr(44) +
"40" +  chr(44) +
"16" + chr(44) +
"9" + chr(44) +
"45" + chr(44) +
"3" + chr(44) +
(if T-sostav
then ("50" + chr(44))
else "":U) +
"5" + chr(44) +
"5" + chr(44) +
(IF T-supp then
("3" + chr(44) + "9" + chr(44) + "40" + chr(44) )
else "") +
(IF T-cons then
("12" + chr(44) )
else "")  +
(IF T-cons or T-parts then
("12" + chr(44) )
else "")  +
"5" + chr(44) +
"5" + chr(44) +
(IF T-GTD then
("26" + chr(44))
else "") +
(if T-parts
then ("15" + chr(44) +
         "15" + chr(44) +
         "14" + chr(44) +
         "10" + chr(44))
else ""
) +
"15" + chr(44) +
"15" + chr(44) +
"15" + chr(44) +
"15" + chr(44) +
"15" + chr(44) +
"15" + chr(44) +
"15" + chr(44) +
(if T-parts
then
("3" + chr(44) +
"9" + chr(44) +
"10" + chr(44))
else "") + chr(44) +
"60"
str2 = " "
.
For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
assign
str1 =     (if Rs-method <> "ONE"
                then str1
                else "" )
ReportNAme = "Партии товаров по документам "
ReportHeader =  "Источник расчета: " + for-title +
                            (if Rs-method <> "ONE"
                            then ""
                            else (" " + F-one) ) + chr(10) +
                            (if T-cons
                             then "Разделять консигнацию и выкуп "
                             else "Не разделять консигнацию и выкуп ") + chr(10) +
                            (if T-supp
                             then "Указывать поставщика "
                             else "Не указывать поставщика ") + chr(10) +
                            (if T-parts
                             then "Каждую партию отдельной строкой"
                            else "") + chr(10) +
                            ( if T-sostav
                              then "Указывать состав сырья"
                              else "":U) + chr(10) +
                            ( if T-split
                              then "Разделять расход/возврат"
                              else "":U) + chr(10) +
                            ( if T-GTD
                              then "Указывать ГТД"
                              else "":U)
                            .
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
