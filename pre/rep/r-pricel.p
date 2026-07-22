block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-pricel.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-pricel.p $":U .
def var vss-description as character no-undo init "Печать Прайс-листа".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
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
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-prt no-undo
field b-code     like  ub.bar-code.b-code
field prt-code   like  ub.prt-obj.prt-code
field fact-qnty  like  ub.prt-obj.fact-qnty
field free-qnty  like  ub.prt-obj.free-qnty
field price-sale like  ub.prt-obj.price-sale
index by-b-code b-code
index by-prt-code prt-code
.
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output base-code
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable num#col# as integer no-undo .
define variable var-1 as integer no-undo .
define variable var-2 as integer no-undo .
define stream  macr_excel .
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define input parameter  i         as  int      no-undo.
define input parameter  P_Type    as  int      no-undo.
define input parameter  SortType  as  char     no-undo.
define input parameter  No-Prt    as  log      no-undo.
def  var OnlyPrices    as      logical  no-undo.
def  var t_grp-name  like gds-list.grp-name  no-undo.
def  var t_unit-name like ub.units.long-name    no-undo.
def  var Rubl_Coeff as decimal  no-undo.
def var price       as decimal  format ">>>>>>>>9.99"   no-undo.
def var roz-price   as decimal    no-undo.
def var qnty        as decimal    no-undo.
def var WaitQnty    as decimal    no-undo.
def var Log-Res      as      log     no-undo.
def var tb-code      as      char    no-undo.
def var Line         as      char    no-undo.
def var CurrItem     as      char    no-undo.
def var ObjName      as      char    no-undo.
def var AA        as       char      no-undo.
def var JJ        as       integer   no-undo.
def var CurrPrinterName as  char     no-undo.
define variable v-today as date      no-undo.
def stream PL .
def stream Title_ .
DEFINE FRAME FullPriceList-Val
    sym1 column-label ":!:!:" format "X(1)" space(0)
    tb-code column-label " Код! ! " format "x(10)" space(0)
    sym2 column-label ":!:!:" format "X(1)" space(0)
    gds-list.artic column-label " Артикул! ! " FORMAT "X(16)" space(0)
    sym3 column-label ":!:!:" format "X(1)" space(0)
    gds-list.gds-name column-label " Наименование! ! "  FORMAT "X(47)" space(0)
    sym4 column-label ":!:!:" format "X(1)" space(0)
    ub.clients.obj-name column-label " Производитель! ! " FORMAT "X(16)" space(0)
    sym5 column-label ":!:!:" format "X(1)" space(0)
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)" space(0)
    sym6 column-label ":!:!:" format "X(1)" space(0)
    price   column-label "Цена за ед.!(Б.вал.)! " format ">>>>>>>>9.99" space(0)
    sym7 column-label ":!:!:" format "X(1)" space(0)
    qnty column-label " Свободно   ! ! " format "->>>>>>9.<<<" space(0)
    sym8 column-label ":!:!:" format "X(1)" space(0)
    WaitQnty column-label " Ожидается! ! " format "->>>>9.<<<" space(0)
    sym9 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width 235 down stream-io.
DEFINE FRAME FullPriceList-Rubl
    sym1 column-label ":!:!:" format "X(1)" space(0)
    tb-code column-label " Код! ! " format "x(10)" space(0)
    sym2 column-label ":!:!:" format "X(1)" space(0)
    gds-list.artic column-label " Артикул! ! " FORMAT "X(16)" space(0)
    sym3 column-label ":!:!:" format "X(1)" space(0)
    gds-list.gds-name column-label " Наименование! ! "    FORMAT "X(49)"    space(0)
    sym4 column-label ":!:!:" format "X(1)" space(0)
    ub.clients.obj-name column-label " Производитель! ! " FORMAT "X(16)" space(0)
    sym5 column-label ":!:!:" format "X(1)" space(0)
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)" space(0)
    sym6 column-label ":!:!:" format "X(1)" space(0)
    price  column-label "Цена!за ед.!(РУБ)"  format ">>>>>>9.99" space(0)
    sym7 column-label ":!:!:" format "X(1)" space(0)
    qnty column-label " Свободно   ! ! " format "->>>>>>9.<<<" space(0)
    sym8 column-label ":!:!:" format "X(1)" space(0)
    WaitQnty column-label " Ожидается! ! " format "->>>>9.<<<" space(0)
    sym9 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width 235 down stream-io.
DEFINE FRAME ReducedPriceList-Val
    sym1 column-label ":!:!:" format "X(1)"
    tb-code column-label "Код ! ! " format "x(10)"
    sym2 column-label ":!:!:" format "X(1)"
    gds-list.artic column-label "Артикул! ! " FORMAT "X(16)"
    sym3 column-label ":!:!:" format "X(1)"
    gds-list.gds-name column-label "Наименование! ! " FORMAT "X(50)"
    sym4 column-label ":!:!:" format "X(1)"
    ub.clients.obj-name column-label "Производитель! ! " FORMAT "X(22)"
    sym5 column-label ":!:!:" format "X(1)"
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)"
    sym6 column-label ":!:!:" format "X(1)"
    price  column-label "Цена за ед.!(Б.вал.)! "   format ">>>>>>>>>>>9.99"
    sym7 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width 235 down stream-io.
DEFINE FRAME ReducedPriceList-Rubl
    sym1 column-label ":!:!:" format "X(1)"
    tb-code column-label "Код ! ! " format "x(10)"
    sym2 column-label ":!:!:" format "X(1)"
    gds-list.artic column-label "Артикул! ! " FORMAT "X(16)"
    sym3 column-label ":!:!:" format "X(1)"
    gds-list.gds-name column-label "Наименование! ! " FORMAT "X(50)"
    sym4 column-label ":!:!:" format "X(1)"
    ub.clients.obj-name column-label "Производитель! ! " FORMAT "X(22)"
    sym5 column-label ":!:!:" format "X(1)"
    t_unit-name column-label "Ед.!изм.! " FORMAT "X(4)"
    sym6 column-label ":!:!:" format "X(1)"
    price  column-label "Цена!за ед.!(РУБ)"  format ">>>>>>>>>>>9.99"
    sym7 column-label ":!:!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 120 PAGE-NUMBER( PL )  FORMAT ">>>>9" SKIP
            Line format "x(136)" AT 1
    with width 235 down stream-io.
DEFINE FRAME PL-Title
    AA   format "X(120)"
    JJ   format ">>>>9"
    with width 160 down stream-io NO-LABELS no-box .
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_price-list_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output log-res
    )  .
end.
if not Log-Res then
    return "NO".
 run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = 1    .
    num#str# = 0 .
if session:set-wait-state("COMPILER") then.
if i = 0 OR P_Type = 0 then
    return.
if session:set-wait-state("COMPILER") then.
Line = fill("-", 232).
OnlyPrices = ( if i = 1 then no else yes ) .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
run proc-cur-rate( input v-cntxt-obj-type, input v-cntxt-obj-code, output Rubl_Coeff ).
FIND ub.clients where v-cntxt-obj-type = ub.clients.obj-type
                      and v-cntxt-obj-code = ub.clients.obj-code no-lock no-error.
ObjName = ub.clients.obj-name .
RUN waitfram-show( 'Подождите ...' ).
if session:set-wait-state("COMPILER") then.
output stream PL to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
output stream Title_ to value( string( session:temp-directory +
                                 "plt" + string( g#report-num ) ) ) page-size value(ReportPageHeight) .
FORM HEADER
        Line format "x(136)" AT 1 SKIP
    with FRAME BottomFrame width 160 PAGE-BOTTOM no-labels no-box.
VIEW stream PL      FRAME BottomFrame .
if SortType = "По группам товаров ( и артикулу )" then
    do:
        FORM HEADER
            cur-time-print() AT 5 format "X(35)"
                "Страница " AT 100 PAGE-NUMBER( Title_ )  FORMAT ">>>>9" SKIP(2)
            ObjName AT 55 format "X(50)" SKIP(2)
            "О Г Л А В Л Е Н И Е"  AT 50 SKIP(3)
            with FRAME TopFrame width 160 PAGE-TOP no-labels no-box.
        VIEW stream Title_  FRAME TopFrame .
    end.
PUT stream Title_ cur-time-print() AT 5 format "X(35)" SKIP(2)
            ObjName AT 55 format "X(50)" SKIP(2)
            "П Р А Й С - Л И С Т" format "X(30)" AT 50 SKIP(3) .
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( String("        П Р А Й С - Л И С Т")  , num#str# , num#col#  ) .
  run macr_cell_format
  ( 14    ,
    true  ,
    false   ,
    ? ,
    1 ,
    1 ,
    2 ,
    1 ) .
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( String( ObjName + " " + cur-time-print())  , num#str# , num#col#  ) .
  num#str# = num#str# + 1.
  run macr_excel_char_with_format(  "Код"               , num#str# , 1  ) .
  run macr_excel_char_with_format(  "Артикул"           , num#str# , 2  ) .
  run macr_excel_char_with_format(   "Наименование"     , num#str# , 3  ) .
  run macr_excel_char_with_format(   "Производитель"    , num#str# , 4  ) .
  run macr_excel_char_with_format(   "Ед. изм."         , num#str# , 5  ) .
  if P_Type = 2
     then  run macr_excel_char_with_format(   "Цена за ед. (РУБ)"    , num#str# , 6  ) .
     else  run macr_excel_char_with_format(   "Цена за ед. (Б.вал.)"    , num#str# , 6  ) .
  if not OnlyPrices  then do:
     num#col# = 8 .
     run macr_excel_char_with_format(   "Свободно"    , num#str# , 7  ) .
     run macr_excel_char_with_format(   "Ожидается"    , num#str# , 8  ) .
     run macr_cell_format
      ( 10    ,
        true  ,
        false   ,
        34 ,
        3 ,
        7 ,
        3 ,
        8 ) .
  end.
  else num#col# = 6 .
  run macr_cell_format
  ( 10    ,
    true  ,
    false   ,
    34 ,
    3 ,
    1 ,
    3 ,
    6 ) .
    run macr_cell_size ( 10 , ? , num#str# , 1 , ?, ? ) .
    run macr_cell_size ( 10 , ? , num#str# , 2 , ?, ? ) .
    run macr_cell_size ( 20 , ? , num#str# , 3 , ?, ? ) .
    run macr_cell_size ( 20 , ? , num#str# , 4 , ?, ? ) .
    run macr_cell_size ( 5 , ? , num#str# , 5 , ?, ? ) .
    run macr_cell_size ( 10 , ? , num#str# , 6 , ?, ? ) .
    run macr_cell_size ( 10 , ? , num#str# , 7 , ?, ? ) .
    run macr_cell_size ( 11 , ? , num#str# , 8 , ?, ? ) .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + chr(10)  +
        'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + chr(10) +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + chr(10)
       .
t_grp-name = "" .
CASE SortType :
    when "По группам товаров ( и артикулу )" then
        do:
            FOR EACH gds-list BREAK BY gds-list.grp-name BY gds-list.artic :
                FIND ub.clients WHERE ub.clients.obj-type = gds-list.prod-type
                                                   AND ub.clients.obj-code = gds-list.prod-code NO-LOCK .
                run make-temp-table ( input gds-list.gds-code ,
                                      input v-cntxt-obj-type ,
                                      input v-cntxt-obj-code ) .
                RUN prtprice( gds-list.gds-name, gds-list.prt-root , gds-list.gds-code ,gds-list.unit-base ) .
                ACCUMULATE gds-list.artic (COUNT) .
                if ( ( ( ACCUM COUNT gds-list.artic )  modulo 50 ) = 0 ) AND
                           ( ( ACCUM COUNT gds-list.artic ) >= 50 ) then
                    RUN waitfram-show( "Обработано наименований : " +
                                                string( ACCUM COUNT gds-list.artic ) ) .
            END.
            HIDE stream Title_ FRAME TopFrame .
        end.
    when "Только по артикулу" then
        FOR EACH gds-list BREAK BY gds-list.artic :
            FIND ub.clients WHERE ub.clients.obj-type = gds-list.prod-type
                                               AND ub.clients.obj-code = gds-list.prod-code NO-LOCK.
            run make-temp-table ( input gds-list.gds-code ,
                                      input v-cntxt-obj-type ,
                                      input v-cntxt-obj-code ) .
            RUN prtprice( gds-list.gds-name, gds-list.prt-root  , gds-list.gds-code ,gds-list.unit-base ) .
            ACCUMULATE gds-list.artic (COUNT) .
            if ( ( ( ACCUM COUNT gds-list.artic )  modulo 50 ) = 0 ) AND
                       ( ( ACCUM COUNT gds-list.artic ) >= 50 ) then
                RUN waitfram-show( "Обработано наименований : " +
                                            string( ACCUM COUNT gds-list.artic ) ) .
        END.
END CASE .
HIDE stream PL FRAME BottomFrame .
PUT stream PL Line format "x(136)" SKIP .
output stream Title_ CLOSE .
output stream PL CLOSE .
Output stream Macr_Excel  close .
RUN waitfram-hide.
    run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind)
      ,input v-file-name
      ) .
    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3,4,5"
        ) .
  run end-proc .
define variable vss-include-info20 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_price-list-to-file_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output log-res
    )  .
end.
if not Log-Res then
    run rep/pl-prn.w (4 ,g#report-num) .
else
    run rep/pl-prn.w (0,g#report-num) .
procedure proc-cur-rate :
  do
  on error undo, return error return-value
  :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter Rubl_Coeff as decimal   no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
run cur-time in this-procedure ( output v-today, output v-time).
        FIND LAST ub.curr-accnt WHERE ub.curr-accnt.curr-code = v-base-code
                                                 AND ub.curr-accnt.exch-date <= v-today
                                                 NO-LOCK NO-ERROR .
        FIND LAST ub.curr-shop WHERE ub.curr-shop.curr-code = v-base-code
                                                 AND ub.curr-shop.obj-code = p-obj-code
                                                 AND ub.curr-shop.obj-type = p-obj-type
                                                 USE-INDEX pi NO-LOCK NO-ERROR .
        if p-obj-type = 'маг':U then
            do:
                if not available ub.curr-shop then
                    do:
                        bell.
                        message "Нет ни одного МАГАЗИННОГО курса базовой валюты к рублям.".
                        Rubl_Coeff = 1.
                    end.
                else
                    Rubl_Coeff = ub.curr-shop.exch-rate / ub.curr-shop.exch-scale.
            end.
        else
            do:
                if not available ub.curr-accnt then
                    do:
                        bell.
                        message "Нет ни одного курса ММВБ базовой валюты к рублям.".
                        return.
                    end.
                else
                    Rubl_Coeff = ub.curr-accnt.exch-rate / ub.curr-accnt.exch-scale.
            end.
  end.
end procedure.
PROCEDURE prtprice :
def input parameter tr   as character no-undo .
def input parameter node as integer  no-undo  .
define input parameter pp-gds-code like ub.goods.gds-code no-undo .
define input parameter pp-unit-base like ub.goods.unit-base no-undo .
def buffer b-gds-prt for ub.gds-prt .
def var gds_name as char no-undo.
assign gds_name = tr .
    FOR EACH b-gds-prt WHERE b-gds-prt.upper-code = node no-lock :
    find  first temp-prt where temp-prt.prt-code = b-gds-prt.node-code no-error .
    if not available temp-prt then next.
    run price-qnty .
                if ( OnlyPrices ) OR ( qnty <> 0 OR WaitQnty <> 0 ) then
                    do:
                        if NOT b-gds-prt.root then
                            tr = gds_name + '\' + b-gds-prt.node-name.
                        if ( t_grp-name <> gds-list.grp-name ) AND
                           lookup( "По группам товаров ( и артикулу )", SortType ) > 0 then
                            do:
                                if t_grp-name <> "" then
                                    if OnlyPrices then
                                        if P_Type = 2 then
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Rubl .
                                        else
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Val .
                                    else
                                        if P_Type = 2 then
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Rubl .
                                        else
                                            UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Val .
                                DO i = 1 to num-entries( right-trim(gds-list.grp-name, chr(47)), chr(47) ) :
                                    if OnlyPrices then
                                        if P_Type = 2 then
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + chr(47) + entry( i, gds-list.grp-name, chr(47) ) )
                                                        @ gds-list.gds-name
                                                    sym7 with FRAME ReducedPriceList-Rubl .
                                                DOWN stream PL 1 with FRAME ReducedPriceList-Rubl .
                                                run gr-ex.
                                            end.
                                        else
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + chr(47) + entry( i, gds-list.grp-name, chr(47) ) )
                                                        @ gds-list.gds-name
                                                    sym7 with FRAME ReducedPriceList-Val .
                                                DOWN stream PL 1 with FRAME ReducedPriceList-Val .
                                                run gr-ex.
                                            end.
                                    else
                                        if P_Type = 2 then
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + chr(47) + entry( i, gds-list.grp-name, chr(47) ) )
                                                        @ gds-list.gds-name
                                                    sym9 with FRAME FullPriceList-Rubl .
                                                DOWN stream PL 1 with FRAME FullPriceList-Rubl .
                                                run gr-ex.
                                            end.
                                        else
                                            do:
                                                DISPLAY stream PL sym1
                                                    string( fill( " " , i * 2 ) + chr(47) + entry( i, gds-list.grp-name, chr(47) ) )
                                                        @ gds-list.gds-name
                                                    sym9 with FRAME FullPriceList-Val .
                                                DOWN stream PL 1 with FRAME FullPriceList-Val .
                                                run gr-ex.
                                            end.
                                END .
                                if OnlyPrices then
                                    if P_Type = 2 then
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Rubl .
                                    else
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME ReducedPriceList-Val .
                                else
                                    if P_Type = 2 then
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Rubl .
                                    else
                                        UNDERLINE stream PL gds-list.gds-name
                                            with FRAME FullPriceList-Val .
                            end.
                        if OnlyPrices then
                            if P_Type = 2 then
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6
                                    (if price = 0 or price = ? then "        ----" else string(price, ">>>>>9.99" ) ) format "x(9)" @ price
                                    sym7 with FRAME ReducedPriceList-Rubl .
                                DOWN    stream PL   1   with FRAME ReducedPriceList-Rubl .
                                run ex-str1 (tr).
                            end.
                            else
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>>>9.99" ) ) format "x(12)" @ price
                                    sym7 with FRAME ReducedPriceList-Val .
                                DOWN    stream PL   1   with FRAME ReducedPriceList-Val .
                                run ex-str1 (tr).
                            end.
                        else
                            if P_Type = 2 then
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>9.99" ) ) format "x(9)" @ price
                                    sym7 qnty   when qnty <> 0
                                    sym8 WaitQnty   when WaitQnty <> 0
                                    sym9
                                    with FRAME FullPriceList-Rubl .
                                DOWN    stream PL   1 with FRAME FullPriceList-Rubl .
                                run ex-str2 (tr).
                            end.
                            else
                            do:
                                DISPLAY stream PL
                                    sym1 trim( string( temp-prt.b-code ) ) @ tb-code
                                    sym2 gds-list.artic
                                    sym3 tr @ gds-list.gds-name
                                    sym4 ub.clients.obj-name
                                    sym5 gds-list.unit-base @ t_unit-name
                                    sym6 (if price = 0 or price = ? then "        ----" else string(price, ">>>>>>>>9.99" ) ) format "x(12)" @ price
                                    sym7 qnty   when qnty <> 0
                                    sym8 WaitQnty   when WaitQnty <> 0
                                    sym9
                                    with FRAME FullPriceList-Val .
                                DOWN    stream PL   1 with FRAME FullPriceList-Val .
                                run ex-str2 (tr).
                            end.
                        if ( t_grp-name <> gds-list.grp-name ) AND
                           lookup( "По группам товаров ( и артикулу )", SortType ) > 0 then
                            do:
                                CurrItem = "" .
                                DO i = 1 to num-entries( right-trim(gds-list.grp-name, chr(47)), chr(47) ):
                                    CurrItem = entry( i, t_grp-name , chr(47) ) NO-ERROR .
                                    if ( error-status:error ) OR
                                       ( CurrItem <> entry( i, gds-list.grp-name, chr(47) ) ) then
                                        do:
                                            DISPLAY stream Title_
                                                    string( fill( " " , i * 10 ) + string( if i = 1 then "  " else "\ " ) +
                                                        entry( i, gds-list.grp-name, chr(47) ) + " " +
                                                        fill( "." , 120 - ( i * 10 ) - 5 -
                                                        length( entry( i, gds-list.grp-name, chr(47) ) ) ) ) @ AA
                                                    PAGE-NUMBER( PL )  @ JJ
                                                    with frame PL-Title .
                                            DOWN stream Title_ 1 with FRAME PL-Title .
                                        end.
                                END .
                                t_grp-name = gds-list.grp-name .
                            end.
                    end.
        if NOT No-Prt then do:
           RUN prtprice( tr, b-gds-prt.node-code, gds-list.gds-code, gds-list.unit-base).
        end.
    END.
END PROCEDURE .
PROCEDURE price-qnty :
    if temp-prt.price-sale <> ? then
        do:
            if var-report-r-b = "base" then
                assign price = ( if P_Type = 2
                                    then (temp-prt.price-sale * Rubl_Coeff )    else temp-prt.price-sale ) .
            else do:
                if base-code = 0 then do:
                assign price = ( if P_Type = 2
                                   then temp-prt.price-sale
                                   else ( temp-prt.price-sale / Rubl_Coeff )   )
                                   .
                                   end.
                else do:
                assign price = ( if P_Type = 2
                                   then ( temp-prt.price-sale )
                                   else  temp-prt.price-sale / Rubl_Coeff   ).
                                   end.
           end.
       end.
    else
        price = 0 .
  assign
      price = round(price ,2)
      qnty     = temp-prt.free-qnty
      Waitqnty =  0
      .
END PROCEDURE .
procedure new-tmp-page :
 do
 on error undo, return error return-value
 :
    if   num#str#  >= 63000 then do:
        Output stream Macr_Excel  close .
        run paramls-write in this-procedure
          (input "file"
          ,input string(v-ind)
          ,input v-file-name
          ) .
        run gbl/_tmpfile.p ("wb", ".txt", output v-file-name) .
        output stream  Macr_Excel to value(v-file-name) .
        v-ind = v-ind + 1 .
        num#str# = 0 .
        run proc-print-header.
    end.
 end.
end procedure.
procedure gr-ex :
 do
 on error undo, return error return-value
 :
num#str# = num#str# + 1.
num#col# = 1 + i .
run macr_excel_char_with_format( string( fill( " " , i * 2 ) + chr(47) + entry( i, gds-list.grp-name, chr(47) ) )  , num#str# , num#col#  ) .
run macr_cell_format
( 10    ,
true  ,
true  ,
?    ,
num#str# ,
num#col# ,
num#str# ,
num#col# ) .
 end.
end procedure.
procedure ex-str1 :
define input parameter tr as character no-undo .
 do
 on error undo, return error return-value
 :
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( trim( string( temp-prt.b-code ) ), num#str# , num#col#  ) .
  num#col# = 2.
  run macr_excel_char_with_format( trim( string( gds-list.artic ) ), num#str# , num#col#  ) .
  num#col# = 3.
  run macr_excel_char_with_format( tr , num#str# , num#col#  ) .
  num#col# = 4.
  run macr_excel_char_with_format( ub.clients.obj-name, num#str# , num#col#  ) .
  num#col# = 5.
  run macr_excel_char_with_format( gds-list.unit-base, num#str# , num#col#  ) .
  num#col# = 6.
  if price = 0 or price = ? then run macr_excel_char_with_format( "---", num#str# , num#col#  ) .
                            else  run macr_excel_dec ( price     , num#str# , num#col#   ) .
 end.
end procedure.
procedure ex-str2 :
 define input parameter tr as character no-undo .
 do
 on error undo, return error return-value
 :
  num#str# = num#str# + 1.
  num#col# = 1.
  run macr_excel_char_with_format( trim( string( temp-prt.b-code ) ), num#str# , num#col#  ) .
  num#col# = 2.
  run macr_excel_char_with_format( trim( string( gds-list.artic ) ), num#str# , num#col#  ) .
  num#col# = 3.
  run macr_excel_char_with_format( tr , num#str# , num#col#  ) .
  num#col# = 4.
  run macr_excel_char_with_format( ub.clients.obj-name, num#str# , num#col#  ) .
  num#col# = 5.
  run macr_excel_char_with_format( gds-list.unit-base, num#str# , num#col#  ) .
  num#col# = 6.
  if price = 0 or price = ? then run macr_excel_char_with_format( "---", num#str# , num#col#  ) .
                            else  run macr_excel_dec ( price     , num#str# , num#col#   ) .
  num#col# = 7.
  run macr_excel_dec ( qnty    , num#str# , num#col#   ) .
  num#col# = 8.
  if waitqnty = 0 or waitqnty = ?
      then run macr_excel_char_with_format( "" , num#str# , num#col#  ) .
      else run macr_excel_dec ( waitqnty    , num#str# , num#col#   ) .
 end.
end procedure.
def var vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure make-temp-table :
 do
 on error undo, return error return-value
 :
define input parameter p-gds-code like ub.goods.gds-code   no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define buffer l_goods for ub.goods       .
define buffer l_bar-code for ub.bar-code .
define buffer l_prt-obj  for ub.prt-obj  .
for each temp-prt : delete temp-prt. end.
find first  l_goods where l_goods.gds-code = p-gds-code no-lock .
for each l_bar-code where
        l_bar-code.gds-code    = p-gds-code and
        l_bar-code.in-code     = ""         and
        l_bar-code.part-code   = ""         and
        l_bar-code.unit-cli    = l_goods.unit-base   no-lock :
        create temp-prt .
        assign
          temp-prt.b-code     = l_bar-code.b-code
          temp-prt.prt-code   = l_bar-code.node-code
        .
     find first l_prt-obj  where
                l_prt-obj.artic     = l_goods.artic    and
                l_prt-obj.prod-code = l_goods.prod-code  and
                l_prt-obj.prod-type = l_goods.prod-type  and
                l_prt-obj.obj-code  = p-obj-code         and
                l_prt-obj.obj-type  = p-obj-type         and
                l_prt-obj.prt-code  = l_bar-code.node-code
                use-index pi NO-LOCK NO-ERROR .
        if available l_prt-obj then do:
            assign
              temp-prt.fact-qnty   = l_prt-obj.fact-qnty
              temp-prt.free-qnty   = l_prt-obj.free-qnty
              temp-prt.price-sale  = l_prt-obj.price-sale
            .
        end.
        else do:
          delete temp-prt .
        end.
 end.
 end.
end procedure.
def var vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure macr_excel_char :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_char_with_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted 'format.number("@")' + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_cell_format :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val    as character no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-format as character no-undo .
 if p-val = ? then p-val = "" .
    put stream macr_excel unformatted
          substitute('select("r&1c&2")', p-row , p-col ) + chr(10) .
    put stream macr_excel unformatted substitute('format.number("&1")', p-format) + chr(10) .
    put stream macr_excel unformatted
          substitute('formula(&3,"r&1c&2")', p-row , p-col , format-excel-text-macr ( p-val) ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_sum :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .
 define input parameter  p-row1 as integer no-undo .
 define input parameter  p-col1 as integer no-undo .
 define input parameter  p-row2 as integer no-undo .
 define input parameter  p-col2 as integer no-undo .
    put stream macr_excel unformatted
          substitute('formula("=sum(r&3c&4:r&5c&6)","r&1c&2")', p-row , p-col , p-row1 , p-col1 ,p-row2 , p-col2 ) + chr(10)  .
 end.
end procedure.
procedure macr_excel_dec :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
  if p-val = ? then p-val =  "" .
   put  stream macr_excel unformatted
        substitute('formula(&3,"r&1c&2")', p-row , p-col ,  p-val )  + chr(10) .
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
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) + chr(10) .
  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color ) + chr(10)  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font(,&1,&2,&3)' , p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) + chr(10) .
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
procedure proc-print-header :
 do
 on error undo, return error return-value
 :
   find first sheetf .
     sheetf.excel-row-heder =  num-entries( c-str ,chr(10)) + 1.
     sheetf.excel-row-title =  num-entries( sheetf.excel-column-lable , chr(10) ).
     var-1 =  num#str# .
     repeat c-c = 1 to sheetf.excel-row-title :
     num#str# = num#str# + 1 .
     p-var = num-entries( entry (c-c, sheetf.excel-column-lable, chr(10)) , chr(44) ) .
     do c-i = 1 to p-var :
        str--1 = entry( c-i, entry (c-c,sheetf.excel-column-lable, chr(10)) , chr(44)) .
        str--2 = integer(entry( c-i, sheetf.sizes )) .
        num#col# = c-i .
        run macr_excel_char_with_format ( str--1  , num#str# , num#col#  ) .
        run macr_cell_size ( str--2 , ? , num#str# , num#col# , ?, ? ) .
     end.
    c-i = 0.
    end.
    run macr_cell_format (
        10       ,
        true     ,
        false    ,
        35       ,
        var-1 + 1,
        1        ,
        num#str# ,
        num#col# )
        .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , var-1 + 1 , 1 , num#str# ,  num#col# ) + chr(10)  +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + chr(10)
       .
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
