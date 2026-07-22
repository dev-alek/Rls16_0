DEFINE BUFFER buf_host FOR ub.clients.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER ink-doc FOR ub.inkas.
DEFINE BUFFER X_trn-doc FOR ub.trn-doc.
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input parameter par-mode as character no-undo .
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input-output param p-rid-list    as  char no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список продаж".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
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
define new shared temp-table gds-list no-undo like ub.goods
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
define  new shared  temp-table gds-list-hist no-undo
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
new shared
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
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
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
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
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
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
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
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function breakstr returns character ( input        for-name    as character,
                                      input        line-length as integer,
                                      input-output line1       as character,
                                      input-output line2       as character ) :
  define variable ii as integer no-undo.
  if length( for-name ) > line-length then do:
    assign ii    = 1
           line1 = "":u
           line2 = "":u.
    if length( entry( ii, for-name , " ":u ) ) > line-length then do:
      assign line1 =       substring( for-name, 1, line-length     )
             line2 = trim( substring( for-name,    line-length + 1 ) ).
    end.                                                     else do:
      do while length( line1 + entry( ii, for-name, " ":u ) ) < ( line-length + 1 ) :
        assign line1 = line1 + entry( ii, for-name, " ":u ) + " ":u
               ii    = ii    + 1.
        if length( entry( ii, for-name, " ":u ) ) > line-length then do:
          assign line1 = line1 + substring( for-name, length( line1 ), line-length - length( line1 ) + 1 ).
        end.
      end.
      assign line2 = trim( substring( for-name, length( line1 ) ) ).
    end.
  end.                                else do:
    assign line1 = for-name
           line2 = "":u.
  end.
  return ( line1 ).
end function.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table dtl-rests-mark no-undo
field artic like ub.gds-dtl.artic
field prod-type like ub.gds-dtl.prod-type
field prod-code like ub.gds-dtl.prod-code
index   pi  is primary
artic
prod-type
prod-code
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define NEW SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define NEW SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define NEW SHARED temp-table tt0-parts    no-undo like ub.parts.
define NEW SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
FUNCTION set-tpsi-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
assign
v-PS = substitute('@&1 для закрытия продажи &2 на &3&4&5товаров &6&5признаков &7'
                  , entry (lookup (buf_sale-doc.ext-doc-type, 'ee,ev,ie,es,iv':U), 'Межфирм.расход по ТПСИ,Внутр.расход по ТПСИ,Межфирм.приход по ТПСИ,Внутр.приход по ТПСИ':U)
                  , buf_sale-doc.out-code
                  , buf_sale-doc.obj-type
                  , buf_sale-doc.obj-code
                  , chr(4)
                  , buf_sale-doc.tot-lines
                  , buf_sale-doc.tot-dtl
                  ).
return v-Ps.
END FUNCTION.
procedure create-tt0-doc-line-gds-dtl :
define input parameter p-proprietor-obj-type like ub.trn-doc.obj-type no-undo .
define input parameter p-proprietor-obj-code like ub.trn-doc.obj-code no-undo .
define input parameter p-ext-doc-type        as character no-undo .
define input parameter p-doc-code            like ub.trn-doc.doc-code no-undo .
define input parameter p-artic               like ub.gds-dtl.artic no-undo .
define input parameter p-prod-type           like ub.gds-dtl.prod-type no-undo .
define input parameter p-prod-code           like ub.gds-dtl.prod-code no-undo .
define input parameter p-prt-code            like ub.gds-dtl.prt-code  no-undo .
define input parameter p-fact-qnty           like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-was-gds-dtl-doc-qnty  like ub.gds-dtl.fact-qnty no-undo .
define output parameter p-gds-dtl-fact-qnty  like ub.gds-dtl.fact-qnty no-undo .
define parameter buffer b-doc-line           for ub.doc-line.
define parameter buffer b-gds-dtl            for ub.gds-dtl.
define parameter buffer buf_sale-doc for ub.sale-doc.
define variable old-qnty like ub.doc-line.fact-qnty no-undo .
define buffer other_doc-line for ub.doc-line.
define buffer other_gds-dtl for ub.gds-dtl.
  do
  on error undo, return error return-value
  :
    find first tt0-doc-line where
              tt0-doc-line.obj-type = p-proprietor-obj-type
          AND tt0-doc-line.obj-code = p-proprietor-obj-code
          AND tt0-doc-line.prod-type = p-prod-type
          AND tt0-doc-line.prod-code = p-prod-code
          AND tt0-doc-line.artic     = p-artic
          AND tt0-doc-line.ext-doc-type = p-ext-doc-type
          AND tt0-doc-line.status_      = 'нередакт':U no-error .
    if not available tt0-doc-line then do:
      create tt0-doc-line.
      buffer-copy b-doc-line
      except
      obj-type obj-code doc-code status_ ext-doc-type doc-qnty fact-qnty
      to tt0-doc-line
      assign
      tt0-doc-line.status_ = 'нередакт':U
      tt0-doc-line.ext-doc-type = p-ext-doc-type
      tt0-doc-line.obj-type = p-proprietor-obj-type
      tt0-doc-line.obj-code = p-proprietor-obj-code
      tt0-doc-line.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
      find first other_doc-line no-lock where
              other_doc-line.doc-code = p-doc-code
          AND  other_doc-line.artic    = p-artic
          AND  other_doc-line.prod-type = p-prod-type
          AND  other_doc-line.prod-code = p-prod-code no-error .
      if available other_doc-line then do:
        find first buf_sale-doc where buf_sale-doc.doc-code = other_doc-line.doc-code.
        assign
        tt0-doc-line.doc-qnty = other_doc-line.doc-qnty
        .
      end.
      else do:
        assign
        tt0-doc-line.doc-code = '':U
        .
      end.
    end.
    find first tt0-gds-dtl where
            tt0-gds-dtl.obj-type = p-proprietor-obj-type
        AND tt0-gds-dtl.obj-code = p-proprietor-obj-code
        AND tt0-gds-dtl.prod-type = p-prod-type
        AND tt0-gds-dtl.prod-code = p-prod-code
        AND tt0-gds-dtl.artic     = p-artic
        AND tt0-gds-dtl.prt-code  = p-prt-code  no-error .
    if not available tt0-gds-dtl then do:
      create tt0-gds-dtl.
      buffer-copy b-gds-dtl
      except
      obj-type obj-code doc-code doc-qnty fact-qnty
      to tt0-gds-dtl
      assign
      tt0-gds-dtl.obj-type = p-proprietor-obj-type
      tt0-gds-dtl.obj-code = p-proprietor-obj-code
      tt0-gds-dtl.doc-code = p-doc-code
      .
    end.
    if p-doc-code <> "":U then do:
        find first other_gds-dtl no-lock where
                other_gds-dtl.doc-code = p-doc-code
            AND  other_gds-dtl.artic    = p-artic
            AND  other_gds-dtl.prod-type    = p-prod-type
            AND  other_gds-dtl.prod-code    = p-prod-code
            AND  other_gds-dtl.prt-code    = p-prt-code no-error .
        if available other_gds-dtl then do:
          assign
          tt0-gds-dtl.doc-qnty = other_gds-dtl.doc-qnty
          .
        end.
        else do:
          assign
          tt0-gds-dtl.doc-code = '':U
          .
        end.
    end.
    assign
    old-qnty = tt0-gds-dtl.doc-qnty
    tt0-gds-dtl.fact-qnty = (if p-fact-qnty = ? then (- old-qnty) else (p-fact-qnty - tt0-gds-dtl.doc-qnty))
    tt0-doc-line.fact-qnty = tt0-doc-line.fact-qnty + (if p-fact-qnty = ? then (- old-qnty) else p-fact-qnty)
    p-gds-dtl-fact-qnty = tt0-gds-dtl.fact-qnty
    p-was-gds-dtl-doc-qnty = tt0-gds-dtl.doc-qnty
    .
  end.
end procedure.
procedure fill-tt-tpsi-table :
define input parameter p-doc-code  like ub.trn-doc.doc-code  no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type  no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code  no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-ext-doc-type              like ub.trn-doc.ext-doc-type no-undo .
define variable v-gds-dtl-fact-qnty         like ub.gds-dtl.fact-qnty no-undo .
define variable v-was-gds-dtl-fact-qnty     like ub.gds-dtl.fact-qnty no-undo .
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
  do
  on error undo, return error
  :
    _doc-line:
    for each buf_Doc-line no-lock where
          buf_doc-line.doc-code = p-doc-code,
      first buf_goods no-lock where
          buf_goods.artic = buf_doc-line.artic
     AND  buf_goods.prod-type  = buf_doc-line.prod-type
     AND  buf_goods.prod-code  = buf_doc-line.prod-code,
        each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_doc-line.doc-code
      AND  buf_gds-dtl.artic    = buf_doc-line.artic
      AND  buf_gds-dtl.prod-type = buf_doc-line.prod-type
      AND  buf_gds-dtl.prod-code = buf_doc-line.prod-code:
      assign
      v-ext-doc-type = "":U.
      run tpsi-preselect-gds-proprietor in this-procedure (
                                                  input buf_goods.gds-code
                                                ,input g#db-num
                                                ,output v-proprietor-host-code
                                                ,output v-proprietor-obj-type
                                                ,output v-proprietor-obj-code ) no-error .
      if v-proprietor-host-code = p-host-code then do:
        assign
        v-ext-doc-type = 'ev':U .
      end.
      else do:
        assign
        v-ext-doc-type =  'ee':U .
      end.
      if  (v-proprietor-obj-type = p-obj-type
      AND v-proprietor-obj-code = p-obj-code)
      OR (v-proprietor-obj-type = "":U
      AND v-proprietor-obj-code = 0)
      OR v-proprietor-obj-code = ?
      then next _doc-line.
      find first buf_sale-doc no-lock where
                buf_sale-doc.inkas-code = p-doc-code
           AND buf_sale-doc.obj-type = v-proprietor-obj-type
           AND buf_sale-doc.obj-code = v-proprietor-obj-code
           AND buf_sale-doc.ext-doc-type = v-ext-doc-type
           no-error .
      run create-tt0-doc-line-gds-dtl  in this-procedure (
                                                           input v-proprietor-obj-type
                                                          ,input v-proprietor-obj-code
                                                          ,input v-ext-doc-type
                                                          ,input (if available buf_sale-doc then buf_sale-doc.doc-code else "":U)
                                                          ,input buf_doc-line.artic
                                                          ,input buf_Doc-line.prod-type
                                                          ,input buf_doc-line.prod-code
                                                          ,input buf_gds-dtl.prt-code
                                                          ,input 0
                                                          ,output v-was-gds-dtl-fact-qnty
                                                          ,output v-gds-dtl-fact-qnty
                                                          ,buffer buf_doc-line
                                                          ,buffer buf_gds-dtl
                                                          ,buffer buf_sale-doc
                                                        ).
    end.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure get-alias-type-price-obj :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-prop-host-code like ub.sysconf.host-code no-undo .
define input parameter p-prop-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-prop-obj-code  like ub.clients.obj-code no-undo .
define output parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define output parameter p-alias-type-price as character no-undo .
define output parameter p-price-obj-type like ub.clients.obj-type no-undo .
define output parameter p-price-obj-code like ub.clients.obj-code no-undo .
define variable v-mediat-obj-type           like ub.trn-doc.obj-type no-undo .
define variable v-mediat-obj-code           like ub.trn-doc.obj-code no-undo .
define variable v-mediat-objf               as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_trn-doc for ub.trn-doc.
  _main:
  do
  on error undo, return error return-value
  :
    run adm/shattri.p (
      input "get":U
      ,input  p-prop-obj-type
      ,input  p-prop-obj-code
      ,input  'alias-tpsi':U
      ,input  '':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
    if error-status:error
    then do:
      undo _main, return error substitute("Не удалось определить настройки МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    find first thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = p-prop-obj-type
          and thbjattr_thbj-attr.obj-code = p-prop-obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
          and thbjattr_thbj-attr.prop-code = 'alias-type-price':U no-error.
    if not available thbjattr_thbj-attr
    or thbjattr_thbj-attr.property-value-integer = 0 then do:
      undo _main, return error substitute("Не задано значение атрибута ТИП ЦЕНЫ МЕЖФИРМЕННОГО ИЛИ ВНУТРЕННЕГО ПЕРЕМЕЩЕНИЯ ЧУЖИХ ТОВАРОВ для &1&2"
                              , p-prop-obj-type
                              , p-prop-obj-code).
    end.
    assign
    p-alias-type-price = string(thbjattr_thbj-attr.property-value-integer).
    if p-prop-host-code = p-host-code
    and (p-alias-type-price = '':U
    or   p-alias-type-price <> '5':U)
    then  do:
      assign
      p-ext-doc-type = 'ev':U
      p-price-obj-type = p-obj-type
      p-price-obj-code = p-obj-code
      p-alias-type-price = '3':U
      .
    end.
    else do:
      if p-prop-host-code = p-host-code  then do:
        assign
        p-ext-doc-type = 'ev':U
        p-price-obj-type = p-obj-type
        p-price-obj-code = p-obj-code
        .
      end.
      else do:
        assign
        p-ext-doc-type = 'ee':U.
        assign
        v-mediat-obj-type = "":U
        v-mediat-obj-code = 0
        v-mediat-objf = "":U
        .
        if p-alias-type-price = '4':U then do:
          find first thbjattr_thbj-attr where
                    thbjattr_thbj-attr.obj-type = p-prop-obj-type
                and thbjattr_thbj-attr.obj-code = p-prop-obj-code
                and thbjattr_thbj-attr.upper-prop-code = 'alias-tpsi':U
                and thbjattr_thbj-attr.prop-code = 'alias-object-price':U no-error.
          if not available thbjattr_thbj-attr
          or thbjattr_thbj-attr.property-value-character = "":U then do:
            undo _main, return error substitute("Не найден объект-посредник для межфирменного перемещения ЧУЖИХ товаров с &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
          assign
          v-mediat-objf     = thbjattr_thbj-attr.property-value-character
          v-mediat-obj-type = entry(1, v-mediat-objf)
          v-mediat-obj-code = integer(entry(2, v-mediat-objf))
          no-error
          .
          if error-status:error then do:
            undo _main, return error substitute("Неверный формат атрибута ОБЪЕКТ-ПОСРЕДНИК для межфирменного перемещения ЧУЖИХ товаров для &1&2"
                                    , p-prop-obj-type
                                    , p-prop-obj-code).
          end.
        end.
        CASE p-alias-type-price:
          when '1':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '2':U then do:
            assign
            p-price-obj-type = p-prop-obj-type
            p-price-obj-code = p-prop-obj-code
            .
          end.
          when '3':U
          or
          when '5':U
          then do:
            assign
            p-price-obj-type = p-obj-type
            p-price-obj-code = p-obj-code
            .
          end.
          when '4':U then do:
            assign
            p-price-obj-type = v-mediat-obj-type
            p-price-obj-code = v-mediat-obj-code
            .
          end.
        END CASE.
      end.
    end.
  end.
end procedure.
procedure write-tt0-info:
define input parameter p-artic as character no-undo .
define input parameter p-prod-type as character no-undo .
define input parameter p-prod-code as integer no-undo .
define input parameter p-prt-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-from-tpsi as logical no-undo .
define input parameter p-all-qnty as decimal no-undo .
define input parameter p-was-res as decimal no-undo .
define input parameter p-to-res as decimal no-undo .
define input parameter p-is-res as decimal no-undo .
define input parameter p-o-was-res as decimal no-undo .
define input parameter p-o-to-res as decimal no-undo .
define input parameter p-o-is-res as decimal no-undo .
define input parameter p-mess   as character no-undo .
define buffer buf_tt0-info for tt0-info.
  do
  on error undo, return error return-value
  :
    find first buf_tt0-info where
             buf_tt0-info.artic = p-artic
         and buf_tt0-info.prod-type = p-prod-type
         and buf_tt0-info.prod-code = p-prod-code
         and buf_tt0-info.prt-code = p-prt-code
         no-error .
    if not available buf_tt0-info then do:
      create buf_tt0-info.
      assign
      buf_tt0-info.artic = p-artic
      buf_tt0-info.prod-type = p-prod-type
      buf_tt0-info.prod-code = p-prod-code
      buf_tt0-info.prt-code  = p-prt-code
      buf_tt0-info.obj-type  = p-obj-type
      buf_tt0-info.obj-code  = p-obj-code
      buf_tt0-info.a-to-res  = ?
      buf_tt0-info.to-res    = ?
      buf_tt0-info.was-res   = ?
      buf_tt0-info.o-was-res = ?
      buf_tt0-info.o-to-res  = ?
      buf_tt0-info.o-is-res  = ?
      buf_tt0-info.is-res    = ?
      .
    end.
    assign
    buf_tt0-info.a-to-res  =
                              (if buf_tt0-info.a-to-res <> ?
                              and p-all-qnty = ?
                              then buf_tt0-info.a-to-res
                              else p-all-qnty)
    buf_tt0-info.was-res   = (if buf_tt0-info.was-res <> ?
                              and p-was-res = ?
                              then buf_tt0-info.was-res
                              else p-was-res)
    buf_tt0-info.to-res    = (if buf_tt0-info.to-res <> ?
                              and p-to-res = ?
                              then buf_tt0-info.to-res
                              else p-to-res)
    buf_tt0-info.is-res    = (if buf_tt0-info.is-res <> ?
                              and p-is-res = ?
                              then buf_tt0-info.is-res
                              else p-is-res)
    buf_tt0-info.o-was-res   = (if buf_tt0-info.o-was-res <> ?
                              and p-o-was-res = ?
                              then buf_tt0-info.o-was-res
                              else p-o-was-res)
    buf_tt0-info.o-to-res    = (if buf_tt0-info.o-to-res <> ?
                              and p-o-to-res = ?
                              then buf_tt0-info.o-to-res
                              else p-o-to-res)
    buf_tt0-info.o-is-res    = (if buf_tt0-info.o-is-res <> ?
                              and p-o-is-res = ?
                              then buf_tt0-info.o-is-res
                              else p-o-is-res)
    .
    assign
    buf_tt0-info.doc-code  = p-doc-code
    buf_tt0-info.error-message   = p-mess
    .
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
function shift-name-no-err return char (
                                        buffer loc-ink-doc for ub.ink-doc
 ).
define variable varshift-name as character no-undo.
define variable varshift-name-num as character no-undo.
  varshift-name = loc-ink-doc.shift-name.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnme in g#lib-trn3 ( input  loc-ink-doc.obj-type,
                       input  loc-ink-doc.obj-code,
                       input  loc-ink-doc.shift-date,
                       input  loc-ink-doc.shift-num,
                       input-output varshift-name,
                       output varshift-name-num
                       ) no-error .
  if error-status:error then do:
    return "":u.
  end.
  return varshift-name-num.
end function.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable filter-label as character no-undo init "Продажи " .
define variable filter-label0 as character no-undo init "Продажи " .
define variable filter-point0 as character no-undo init "salelist" .
define variable filter-point as character no-undo init "salelist".
define variable sort-column-name as character no-undo .
DEFINE VARIABLE varhost-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE varhost-name like ub.clients.obj-name no-undo .
define variable cas-shft as logical no-undo init no.
define variable print-type as char init "" no-undo.
define variable ptwounit as logical no-undo init yes .
define variable export-option as character no-undo.
define variable v-doc-rec as recid no-undo .
DEFINE NEW SHARED VARIABLE br-handle as handle no-undo.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-curr-r-b AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-is-fbr-obj AS LOGICAL NO-UNDO INIT ?.
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO INIT ?.
DEFINE VARIABLE hist-option as character no-undo.
define variable next-prev  as character no-undo .
define variable add-option as character no-undo .
define variable tpsi-mode as integer no-undo .
define variable l-shift-on as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-vid-action      as integer   no-undo .
define variable v-vid-param       as longchar  no-undo .
define variable varobj-shift-date as date      no-undo.
define variable varobj-shift-num  as integer   no-undo.
define variable varobj-shift-name as character no-undo.
define variable v-mess            as character no-undo.
define buffer bf_clients for ub.clients.
define buffer buf_trn-doc for ub.trn-doc.
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
DEFINE MENU m-print
       MENU-ITEM m-list         LABEL "Список продаж"
       MENU-ITEM m-one          LABEL "Продажа"       .
DEFINE MENU MENU-B-add
       MENU-ITEM m_sale         LABEL "Продажа"
       MENU-ITEM m_inquiry      LABEL "Продажа-запрос".
DEFINE MENU MENU-B-export
       MENU-ITEM m_gen-3        LABEL "Проводки (внеш.)".
DEFINE BUTTON B-add
     LABEL "&Добав."
     SIZE 10 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Измен."
     SIZE 10 BY 1.
DEFINE BUTTON B-chk
     LABEL "Ч&еки"
     SIZE 10 BY 1.
DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-export
     LABEL "Генерац&."
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON B-Open
     LABEL "&Открыть"
     SIZE 10 BY 1.
DEFINE BUTTON B-print
     LABEL "Выполнить/Пе&чать"
     SIZE 20 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE VARIABLE ED-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.75
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE num-chk AS INTEGER FORMAT "->>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 16.13 BY .67 NO-UNDO.
DEFINE VARIABLE qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
      VIEW-AS TEXT
     SIZE 16.13 BY .67 NO-UNDO.
DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)":U
     LABEL "номеру"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999":U
     LABEL "дате"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE sch-fact AS DATE FORMAT "99/99/9999":U
     LABEL "дате факт"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.
DEFINE VARIABLE shop-name AS CHARACTER FORMAT "X(25)":U
      VIEW-AS TEXT
     SIZE 27 BY .67 NO-UNDO.
DEFINE QUERY BR-docs FOR ink-doc SCROLLING.
DEFINE BROWSE BR-docs
  QUERY BR-docs NO-LOCK DISPLAY
      mark-string( recid(ink-doc), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      ink-doc.inkas-code FORMAT "X(14)":U
      ink-doc.doc-date FORMAT "99/99/9999":U
      ink-doc.fact-date FORMAT "99/99/9999":U
      ink-doc.shift-date COLUMN-LABEL "Дата смены!(учета)" FORMAT "99/99/9999":U
      shift-name-no-err(BUFFER ink-doc) COLUMN-LABEL "N см." FORMAT "X(6)":U
      ink-doc.netto COLUMN-LABEL "Нетто" FORMAT "->>>,>>>,>>>,>>9.99":U
      ink-doc.tot-doc COLUMN-LABEL "Сумма товарная" FORMAT "->>>,>>>,>>>,>>9.99":U
      ink-doc.discnt FORMAT "->,>>>,>>>,>>9.99":U
      ink-doc.sub-discnt COLUMN-LABEL "Списания" FORMAT "->>>,>>>,>>9.99":U
      ink-doc.qnty COLUMN-LABEL "Кол-во товаров" FORMAT "->>,>>>,>>9.<<<":U
      (ink-doc.discnt / ink-doc.tot-doc * 100) COLUMN-LABEL "%" FORMAT "->>>>>9.9":U
      ink-doc.num-chk FORMAT ">>>,>>9":U COLUMN-LABEL "Чеков"
      ink-doc.num-chk-nf FORMAT ">>>,>>9":U COLUMN-LABEL "Чеков!нд"
      ink-doc.status_ FORMAT "X(8)":U
      ink-doc.flag_ COLUMN-LABEL "ОК" FORMAT "+/":U
      ink-doc.is-auto-born COLUMN-LABEL "Авто!созд" FORMAT "+/":U
      ink-doc.is-auto-get COLUMN-LABEL "Авто!чеки" FORMAT "+/":U
      ink-doc.is-auto-rsrv COLUMN-LABEL "Авто!резерв" FORMAT "+/":U
      ink-doc.is-auto-close COLUMN-LABEL "Авто!закр" FORMAT "+/":U
      ink-doc.auto-comp COLUMN-LABEL "Ком!пенс" FORMAT "+/":U
      ink-doc.AUTO-fbr  COLUMN-LABEL "Авто!пр-во" FORMAT "+/":U
      ink-doc.rest-dish COLUMN-LABEL "Ост-ки!блюд" FORMAT "+/":U
      ink-doc.rest-ingr COLUMN-LABEL "Ост-ки!ингр" FORMAT "+/":U
      ink-doc.auto-tpsi COLUMN-LABEL "ТПСИ" FORMAT "+/":U
      ink-doc.rest-tpsi COLUMN-LABEL "Ост-ки!ТПСИ" FORMAT "+/":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.63 BY 15.42.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 21
     B-export AT ROW 1 COL 31
     B-chk AT ROW 1 COL 41
     B-print AT ROW 1 COL 51
     B-sch AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-add AT ROW 2 COL 21
     b-lkp AT ROW 2 COL 31
     B-chg AT ROW 2 COL 41
     B-del AT ROW 2 COL 51
     B-close AT ROW 2 COL 61
     B-Open AT ROW 2 COL 71
     BR-docs AT ROW 3 COL 1
     ED-notes AT ROW 18.58 COL 1 NO-LABEL
     sch-code AT ROW 22.58 COL 17.63 COLON-ALIGNED
     sch-date AT ROW 22.58 COL 40.75 COLON-ALIGNED
     sch-fact AT ROW 22.58 COL 65.63 COLON-ALIGNED
     mark-num AT ROW 1 COL 14 NO-LABEL
     qnty AT ROW 21.5 COL 52.63 COLON-ALIGNED NO-LABEL
     shop-name AT ROW 21.5 COL 69.88 COLON-ALIGNED NO-LABEL
     num-chk AT ROW 21.58 COL 15.63 COLON-ALIGNED NO-LABEL
     "количество товара" VIEW-AS TEXT
          SIZE 19.5 BY .88 AT ROW 21.46 COL 34.5
     "число чеков" VIEW-AS TEXT
          SIZE 16 BY .88 AT ROW 21.46 COL 1.38
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 22.58 COL 1.5
          FGCOLOR 4
     SPACE(88.25) SKIP(0.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Продажи"
         DEFAULT-BUTTON b-lkp CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.
ASSIGN
       B-export:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-export:HANDLE.
ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.
ON END-ERROR OF FRAME Dialog-Frame
OR ENDKEY OF FRAME Dialog-Frame DO:
  run gbl/markqwa.p (
                input b-mark:sensitive
               ,input v-rid-list
                ) no-error.
    if error-status:error then return no-apply.
END.
ON GO OF FRAME Dialog-Frame
DO:
  p-rid-list = v-rid-list.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
or Right-Mouse-CLICK OF b-add IN FRAME Dialog-Frame
DO:
 IF tpsi-mode = 2
 and add-option = '':U THEN DO:
     run gbl/pop-up.p ( INPUT SELF:HANDLE, INPUT NO) NO-ERROR.
     IF add-option = '':U THEN RETURN NO-APPLY.
  END.
  run proc-b-add IN THIS-PROCEDURE ( INPUT (if tpsi-mode = 2 then add-option else 'касс':U)) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  define variable v-inkas-code as character no-undo .
  IF NOT AVAILABLE ink-doc THEN RETURN NO-APPLY.
  assign
  v-doc-rec = recid(ink-doc).
  v-inkas-code = ink-doc.inkas-code.
  run str/cre-sale.p ( INPUT parparentproc
                      ,INPUT parobj-type
                      ,INPUT parobj-code
                      ,INPUT 'ИЗМЕНЕНИЕ':U
                      ,input '':U
                      ,input '':U
                      ,INPUT-output v-inkas-code
                      ,INPUT '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
    message
    substitute("Ошибка при редактировании продажи:&1&2 &3", chr(10), error-status:get-message(1) , return-value )
    view-as alert-box ERROR .
    return no-apply.
  end.
RUn openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
reposition br-docs to recid v-doc-rec no-error.
APPLY "VALUE-CHANGED" to BR-docs.
END.
ON CHOOSE OF B-chk IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE rid-list as character no-undo .
define variable loc#log as logical no-undo.
def buffer t-clients for ub.clients.
if available ink-doc THEN  do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
loc#log = yes.
FIND FIRST t-clients NO-LOCK WHERE
                    t-clients.obj-code = ink-doc.obj-code AND
                    t-clients.obj-type = ink-doc.obj-type
    No-ERROR.
IF t-clients.db-num <> ub.db.db-num and ub.db.db-num <> 0 then do:
    if YES then
    message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
    "в базе данных N " ub.db.db-num
    view-as alert-box.
    loc#log = no.
end.
else if ub.db.db-num = 0 AND t-clients.db-num <> ub.db.db-num then do:
    FIND FIRST db No-LOCK WHERE db.db-num = t-clients.db-num No-ERROR.
    if NOT db.send-check then do:
        if YES then
        message "Нельзя получить информацию по чекам объекта "  ink-doc.obj-code ink-doc.obj-type
        "в базе данных N " ub.db.db-num
        view-as alert-box.
        loc#log = no.
    end.
end.
    if NOT loc#log then return no-apply.
    run str/chk-docs.w (
                     input parparentproc
                    ,input '':U
                    ,input 'продажа':U
                    ,input ?
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input '':U
                    ,input 0
                    ,input  ?
                    ,input  ?
                    ,input 0
                    ,output rid-list) no-error.
end.
apply "entry" to br-docs.
END.
ON CHOOSE OF B-close IN FRAME Dialog-Frame
DO:
 IF NOT AVAILABLE ink-doc THEN RETURN NO-APPLY.
 define variable v-close-type as integer no-undo .
 define variable v-status_ like ub.inkas.status_ no-undo .
 define variable v-flag_ like ub.trn-doc.flag_ no-undo .
 define variable v-ask-message as character no-undo .
 define buffer buf_trn-doc for ub.trn-doc.
 find first buf_trn-doc where
           buf_trn-doc.doc-code = ink-doc.inkas-code.
 run str/salegraf.p (
                input ink-doc.inkas-code
               ,input '<закрытие документа>':U
               ,input buf_trn-doc.status_
               ,input buf_trn-doc.flag_
               ,output v-status_
               ,output v-flag_
               ,output v-ask-message) no-error .
  if error-status:error then do:
    message
    error-status:get-message(1)  skip
    return-value
    view-as alert-box error .
    return no-apply.
  end.
  run gbl/d-askw.w
    (input "Вопрос"
    ,input substitute("Закрыть ОТЧЕТ О ПРОДАЖЕ &1&2" +
                      "Дата учета &3&2" +
                      "Ожидаемая факт дата &4"
                     , ink-doc.inkas-code
                     , chr(10)
                     , string(ink-doc.shift-date, '99/99/9999':u)
                     , string(ink-doc.fact-date, '99/99/9999':u)
                     )
    ,input "|^"
    ,input (if v-status_ = 'факт':U
            then ("Факт" + '|':u + "Отмена" )
            else (v-status_ + string(v-flag_, "+/") + '|':u
          + "Факт" + '|':u
          + "Отмена" )
            )
    ,input (if v-status_ = 'факт':U
            then ("Окончательное закрытие без последующего редактирования|"
                  + "Отмена действия")
            else (
                 v-ask-message + "|"
                  + "Окончательное закрытие без последующего редактирования|"
                  + "Отмена действия")
           )
    ,input 1
    ,input (if v-status_ = 'факт':U
            then 2
            else 3)
    ,output v-close-type
    ).
 if (v-status_ = 'факт':U
 and v-close-type = 2)
 or v-close-type = 3 then do:
   return no-apply.
 end.
 run proc-close IN THIS-PROCEDURE ( input yes, input (if v-status_ = 'факт':U then 2 else v-close-type), input v-status_, input v-flag_) NO-ERROR.
 IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
or Right-Mouse-CLICK OF b-del IN FRAME Dialog-Frame
DO:
  define variable v-ok as logical   no-undo .
  define variable v-parameter as character no-undo .
  define variable ri as recid no-undo .
  define variable v-normal-call as logical no-undo .
  define variable v-inkas-code as character no-undo .
  if not available ink-doc then return no-apply.
  if par-mode = 'новый':U then .
  else do:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_sale_del-sale-fact':U
    ,input  'object':U
    ,input  ink-doc.host-code
    ,input  ink-doc.obj-type
    ,input  ink-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
    if not v-ok then return no-apply .
  end .
  assign
    v-inkas-code  = ink-doc.inkas-code
    v-normal-call = can-do("CHOOSE,ENTER":U, last-event:label)
    v-ok = false
  .
  message
  "Удалить продажу №" v-inkas-code skip(0)
  (if par-mode = 'новый':U and not v-normal-call then "С одновременным форсированным снятием резервов" else '':U) skip(0)
  "Продолжить?" skip(0)
  view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true then do:
    return no-apply .
  end.
  ri = recid(ink-doc).
  IF par-mode = 'новый':U THEN DO:
    assign
    v-parameter = string(1)                 + chr(4) +
                  ink-doc.obj-type          + chr(4) +
                  string(ink-doc.obj-code)  + chr(4) +
                  string(not v-normal-call) + chr(4) +
                  v-inkas-code.
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/del-sale.p":U + chr(4) +
                "1":U  + chr(4) +
                "1":U + chr(4) +
                "1":U)
        , input v-parameter
        , input no
        , input "":U
        , input substitute("Удаление продажи &1 &2&3", Ink-doc.inkas-code, ink-doc.obj-type, ink-doc.obj-code)
    ) no-error.
    if error-status:error
    and return-value <> "error"
    and return-value <> ""
    then do:
      message
      substitute("&1 &2"
                , error-status:get-message(1)
                , return-value )
      view-as alert-box error .
      return no-apply .
    end.
    if return-value = "error":U then do:
      return no-apply .
    end.
    else do:
      run Openbr in this-procedure ( input yes, input no, input '':U).
      reposition br-docs to recid ri no-error.
    end.
  END.
  ELSE DO:
    v-parameter = ink-doc.inkas-code.
      find first buf_trn-doc no-lock where
        buf_trn-doc.doc-code = ink-doc.inkas-code no-error.
      if available (buf_trn-doc)
      then do:
        find first bf_clients no-lock where bf_clients.obj-type = 'чел':U and  bf_clients.obj-code = buf_trn-doc.boss no-error.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  inkas.obj-type
  ,input  inkas.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  ) no-error .
        v-vid-param = "Initiator=" + "User" + chr(4) +
                      "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + chr(4) +
                      "SHOP_NUM=" + string(ink-doc.obj-code) + chr(4) +
                      "Contractor=" + buf_trn-doc.cli-name + chr(4) +
                      "DocNum=" + string(ink-doc.inkas-code) + chr(4) +
                      "FactDate=" + (if string(ink-doc.fact-date) = ? then '' else string(ink-doc.fact-date)) + chr(4) +
                      "DocType=" + "Продажа" + chr(4) +
                      "SHIFT_NUM_DOC=" + (if string(ink-doc.shift-num) = ? then '' else string(ink-doc.shift-num)) + (if string(ink-doc.shift-date) = ? then '' else string(ink-doc.shift-date, "99999999")) + chr(4) +
                      "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + chr(4) +
                      "Status=" + string(ink-doc.status_) no-error.
    end.
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/delfsale.p":U + chr(4) +
                "1":U  + chr(4) +
                "1":U + chr(4) +
                "1":U)
        , input v-parameter
        , input no
        , input "":U
        , input substitute("Удаление продажи &1 &2&3, закрытой до статуса факт", Ink-doc.inkas-code, ink-doc.obj-type, ink-doc.obj-code)
    ) no-error.
    if error-status:error
    and return-value <> "error"
    and return-value <> ""
    then do:
      v-mess = substitute("&1 &2"
                , error-status:get-message(1)
                , return-value ).
      if v-vid-param <> "" or v-vid-param <> ?
      then do:
        v-vid-param = v-vid-param + chr(4)+ "RESULT=" + string( 1 ) + chr(4) + "Description=" + v-mess.
        v-vid-action = 59 .
        run trg/userlog.p (
              input 'delete_err':U
            , input 'inkas':U
            , input ( buffer ink-doc:handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      end.
      message
        v-mess
      view-as alert-box error .
      return no-apply .
    end.
    if return-value = "error":U then do:
      v-mess = substitute("&1 &2"
                , error-status:get-message(1)
                , return-value ).
      if v-vid-param <> "" or v-vid-param <> ?
      then do:
        v-vid-param = v-vid-param + chr(4)+ "RESULT=" + string( 1 ) + chr(4) + "Description=" + v-mess.
        v-vid-action = 59 .
        run trg/userlog.p (
              input 'delete_err':U
            , input 'inkas':U
            , input ( buffer ink-doc:handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      end.
      return no-apply .
    end.
    else do:
      if v-vid-param <> "" or v-vid-param <> ?
      then do:
        find last ub.c-inkas no-lock where ub.c-inkas.inkas-code = v-parameter and ub.c-inkas.corr-user-db-num = v-cntxt-db-num no-error.
        v-vid-param = v-vid-param + chr(4)+ "RESULT=" + string( 0 ) + chr(4) + "Description=".
        v-vid-action = 59 .
        run trg/userlog.p (
              input 'delete':U
            , input 'c-inkas':U
            , input ( buffer ub.c-inkas:handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      end.
      run Openbr in this-procedure ( input yes, input no, input '':U).
      reposition br-docs to recid ri no-error.
    end.
  END.
  APPLY "VALUE-CHANGED" to BR-docs.
  apply "ENTRY" to br-docs.
END.
ON CHOOSE OF B-export IN FRAME Dialog-Frame
DO:
if not avail ink-doc then return no-apply.
  if export-option = '':U then do:
        run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if export-option = '':U then return no-apply.
  run proc-b-export in this-procedure ( input export-option) no-error.
  if error-status:error then do:
    export-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-docs.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
 if not available ink-doc then return no-apply.
  run proc-b-hist in this-procedure no-error.
  if error-status:error then do:
    hist-option = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-docs.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
define variable v-handle as handle no-undo .
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_sale_lookup':U
    ,input  'object':U
    ,input  ink-doc.host-code
    ,input  ink-doc.obj-type
    ,input  ink-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
 if NOT glog then  return no-apply.
   assign
   next-prev = '':U.
   v-handle = this-procedure :handle.
  DO WHILE next-prev = '':U:
    if NOT available ink-doc then do:
        message "Неправильный выбор кассового отчета."
                        view-as alert-box WARNING .
        return no-apply.
    end.
    run str/sale.w ( input parparentproc
                    , input 'ПРОСМОТР':U
                    , input-output v-doc-rec
                    , input-output v-handle
                    , input-output next-prev
                    , buffer ink-doc
                    ).
  end.
  apply "entry" to br-docs in frame Dialog-Frame.
  apply "iteration-changed" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
  if available ink-doc then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid32 as character no-undo .
define variable v-num-entry32 as integer   no-undo .
assign
  v-str-recid32 = trim( string( recid( ink-doc ) , "->>>>>>>>>>>9":U ) )
  v-num-entry32 = lookup( v-str-recid32 , v-rid-list )
.
if v-num-entry32 > 0 then do:
  assign
    entry( v-num-entry32, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid32
  .
end.
    glog = br-docs:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        glog = br-docs:select-next-row ().
        apply "iteration-changed" to br-docs in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-docs in frame Dialog-Frame.
END.
ON CHOOSE OF B-Open IN FRAME Dialog-Frame
DO:
 IF NOT AVAILABLE ink-doc THEN RETURN NO-APPLY.
 define variable v-close-type as integer no-undo .
 define variable v-status_ like ub.inkas.status_ no-undo .
 define variable v-flag_ like ub.trn-doc.flag_ no-undo .
 define variable v-ask-message as character no-undo .
 define buffer buf_trn-doc for ub.trn-doc.
 find first buf_trn-doc where
           buf_trn-doc.doc-code = ink-doc.inkas-code.
 run str/salegraf.p (
                input ink-doc.inkas-code
               ,input '<открытие документа>':U
               ,input buf_trn-doc.status_
               ,input buf_trn-doc.flag_
               ,output v-status_
               ,output v-flag_
               ,output v-ask-message) no-error .
  if error-status:error then do:
    message
    error-status:get-message(1)  skip
    return-value
    view-as alert-box error .
    return no-apply.
  end.
  run gbl/d-askw.w
    (input "Вопрос"
    ,input substitute("Открыть ОТЧЕТ О ПРОДАЖЕ &1&2" +
                      "Дата учета &3&2" +
                      "Ожидаемая факт дата &4"
                     , ink-doc.inkas-code
                     , chr(10)
                     , string(ink-doc.shift-date, '99/99/9999':u)
                     , string(ink-doc.fact-date, '99/99/9999':u)
                     )
    ,input "|^"
    ,input (v-status_ + string(v-flag_, "+/-") + '|':u
          + "Отмена" )
    ,input v-ask-message + "|"
        + "Отмена действия"
    ,input 1
    ,input 2
    ,output v-close-type
    ).
 if v-close-type = 2 then return no-apply.
 run proc-close IN THIS-PROCEDURE ( input no, input v-close-type, input v-status_, input v-flag_) NO-ERROR.
 IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  if not avail ink-doc then return no-apply.
  if print-type = '':U then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-type = '':U then return no-apply.
  run proc-b-print in this-procedure ( input print-type) no-error.
  if error-status:error then do:
    print-type = '':U.
    return no-apply.
  end.
  APPLY "ENTRY" to br-docs.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
   if ( available ink-doc ) AND ( v-rid-list = ""
   or
   b-mark:sensitive = no
   ) then
    v-rid-list = string( recid( ink-doc ) ) .
END.
ON ANY-PRINTABLE OF BR-docs IN FRAME Dialog-Frame
DO:
  sch-code:screen-value = sch-code:screen-value + last-event:label.
    apply "entry" to sch-code in frame Dialog-Frame.
apply "end" to sch-code in frame Dialog-Frame.
END.
ON DELETE-CHARACTER OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
END.
ON INSERT-MODE OF BR-docs IN FRAME Dialog-Frame
DO:
  if b-mark:sensitive in frame Dialog-Frame then
  APPLY "CHOOSE" to b-mark.
    else do:
      if b-sel:sensitive in frame Dialog-Frame then
      APPLY "CHOOSE" to b-sel.
    end.
END.
ON RETURN OF BR-docs IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME Dialog-Frame DO:
  apply "choose" to b-lkp in frame Dialog-Frame.
    return no-apply.
END.
ON VALUE-CHANGED OF BR-docs IN FRAME Dialog-Frame
DO:
define buffer buf_clients for ub.clients.
  if available ink-doc then do:
    assign
    num-chk = ink-doc.num-chk
    qnty = ink-doc.qnty
    ed-notes = replace(ink-doc.PS, chr(4), chr(32)).
    FIND FIRST buf_clients where
                          buf_clients.obj-type = ink-doc.obj-type AND
                 buf_clients.obj-code = ink-doc.obj-code NO-LOCK NO-ERROR.
    IF avail buf_clients then assign
    shop-name = buf_clients.obj-name.
    else shop-name = string(ink-doc.obj-code).
    display
    ed-notes
    num-chk
    qnty
    shop-name when (par-mode <> 'объект':U and par-mode <> 'новый':U)
    with frame Dialog-Frame .
   end.
   else do:
      ed-notes:screen-value = '':U.
      display
      '':U @ num-chk
      '':U @ qnty
      '':U shop-name
      with frame Dialog-Frame .
   end.
END.
ON LEAVE OF ED-notes IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF MENU-ITEM m-list
DO:
  assign
  print-type = 'LIST':U.
  APPLY "CHOOSE" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-one
DO:
   assign
  print-type = 'ONE':U.
  APPLY "CHOOSE" to b-print in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_gen-3
DO:
export-option = "m_gen-3".
run proc-b-export in this-procedure ( input export-option) no-error.
if error-status:error then do:
  export-option = '':U.
  return no-apply.
end.
END.
ON CHOOSE OF MENU-ITEM m_inquiry
DO:
    ASSIGN
  add-option = 'запрос':U.
  run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF MENU-ITEM m_sale
DO:
    ASSIGN
  add-option = 'касс':U.
  run proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CTRL-J OF sch-code IN FRAME Dialog-Frame
DO:
   run proc-find-code in this-procedure ( input yes, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-code IN FRAME Dialog-Frame
DO:
   run proc-find-code in this-procedure ( input no, input frame Dialog-Frame sch-code) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-date IN FRAME Dialog-Frame
DO:
   run proc-find-date in this-procedure ( input yes, input frame Dialog-Frame sch-date, "doc-date") no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-date IN FRAME Dialog-Frame
DO:
    run proc-find-date in this-procedure ( input no, input frame Dialog-Frame sch-date, "doc-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON CTRL-J OF sch-fact IN FRAME Dialog-Frame
DO:
   run proc-find-date in this-procedure ( input yes, input frame Dialog-Frame sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-fact IN FRAME Dialog-Frame
DO:
  run proc-find-date in this-procedure ( input no, input frame Dialog-Frame sch-fact, "fact-date":U) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-docs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of sch-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of sch-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of sch-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of sch-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of sch-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date37
    MENU-ITEM m-ed-date37-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date37-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date37-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date37-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date37 :HANDLE
      sch-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle37 as handle no-undo .
  assign
    v-label-handle37 = sch-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle37)
  then do:
    if v-label-handle37 :tooltip = ""
    or v-label-handle37 :tooltip = ?
    then do:
      assign
        v-label-handle37 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date37-1 in menu m-ed-date37 DO:
    apply "ctrl-b":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date37-2 in menu m-ed-date37 DO:
    apply "ctrl-d":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date37-3 in menu m-ed-date37 DO:
    apply "ctrl-e":U to sch-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date37-4 in menu m-ed-date37 DO:
    apply "ctrl-f":U to sch-date in frame Dialog-Frame .
  END.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of sch-fact in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of sch-fact in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of sch-fact in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of sch-fact in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of sch-fact in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of sch-fact in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date39
    MENU-ITEM m-ed-date39-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date39-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date39-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date39-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if sch-fact :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      sch-fact :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date39 :HANDLE
      sch-fact :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle39 as handle no-undo .
  assign
    v-label-handle39 = sch-fact :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle39)
  then do:
    if v-label-handle39 :tooltip = ""
    or v-label-handle39 :tooltip = ?
    then do:
      assign
        v-label-handle39 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date39-1 in menu m-ed-date39 DO:
    apply "ctrl-b":U to sch-fact in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date39-2 in menu m-ed-date39 DO:
    apply "ctrl-d":U to sch-fact in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date39-3 in menu m-ed-date39 DO:
    apply "ctrl-e":U to sch-fact in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date39-4 in menu m-ed-date39 DO:
    apply "ctrl-f":U to sch-fact in frame Dialog-Frame .
  END.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info42 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info43 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info44 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE PrintListProc.
define input parameter p-curr-r-b as character no-undo .
define input parameter p-base-type as character no-undo .
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable accum-count as integer.
define variable accum-tot-doc as decimal.
define variable accum-discnt as decima.
define variable accum-sub-discnt as decimal.
define variable accum-netto as decimal.
define variable accum-qnty as decimal.
define variable accum-num-chk as integer.
define variable for-pcnt as decimal.
DEFINE VARIABLE jj as integer no-undo .
define variable v-header-base-curr as character no-undo .
define variable v-flag as logical no-undo .
define variable v-shift-name-num as character no-undo.
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define buffer buf_trn-doc for ub.trn-doc.
if p-curr-r-b = 'base':U and p-base-type <> '':U then do:
  assign
  v-header-base-curr = string( "( Б.Вал. - " + caps( p-base-type ) + " )" )
  .
end.
DEFINE FRAME Chk-List
ink-doc.office       column-label "У" format "+/-"
ink-doc.inkas-code FORMAT "X(12)"
ink-doc.doc-date FORMAT "99/99/9999"
ink-doc.fact-date COLUMN-LABEL "Факт.дата" FORMAT "99/99/9999"
ink-doc.netto COLUMN-LABEL "Нетто" FORMAT "->>>,>>>,>>>,>>9.99"
ink-doc.tot-doc COLUMN-LABEL "Сумма_товар."
ink-doc.discnt FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка_общ"
for-pcnt COLUMN-LABEL "%" FORMAT "->>>9.9"
ink-doc.sub-discnt FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Списания"
ink-doc.qnty COLUMN-LABEL "Кол_товара"
ink-doc.num-chk FORMAT ">>>,>>9" COLUMN-LABEL "Кол._чеков"
ink-doc.shift-date COLUMn-LABEL "Дата_смены"
v-shift-name-num COLUmn-LABEL "№ см." FORMAT "X(6)"
ink-doc.obj-code FORMAT "99999" COLUMn-LABEL "Маг-н"
ink-doc.status_ FORMAT "X(8)":U
v-flag COLUMN-LABEL "ОК" FORMAT "+/":U
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr        format "X(20)" AT 42
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>9" SKIP
Line format "X(177)" AT 1
    with width 232 down stream-io use-text    .
Line = fill("-", 177).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
        Line format "X(177)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
FORM with FRAME Chk-List  .
run waitfram-show in this-procedure ("Ждите...").
GET next br-docs.
jj = 0 .
DO WHILE available ink-doc :
  find first buf_trn-doc no-lock where
              buf_trn-doc.doc-code = ink-doc.inkas-code no-error.
  Display STREAM PrnLibStream
  ink-doc.office
  ink-doc.inkas-code
  ink-doc.doc-date
  ink-doc.fact-date
  ink-doc.netto
  ink-doc.tot-doc
  ink-doc.discnt
  (ink-doc.discnt / ink-doc.tot-doc * 100) @ for-pcnt
  ink-doc.sub-discnt
  ink-doc.qnty
  ink-doc.num-chk
  ink-doc.shift-date
  shift-name-no-err(buffer ink-doc) @ v-shift-name-num
  ink-doc.obj-code
  ink-doc.status_
  (if available buf_trn-doc then buf_trn-doc.flag else ?) @ v-flag
  with FRAME Chk-List .
  DOWN STREAM PrnLibStream 1 with FRAME CHk-List  .
  assign
  accum-count = accum-count + 1
  accum-tot-doc = accum-tot-doc + ink-doc.tot-doc
  accum-discnt = accum-discnt + ink-doc.discnt
  accum-sub-discnt = accum-sub-discnt + ink-doc.sub-discnt
  accum-netto = accum-netto + ink-doc.netto
  accum-qnty = accum-qnty + ink-doc.qnty
  accum-num-chk = accum-num-chk + ink-doc.num-chk.
  GET next br-docs.
END.
UNDERLINE  STREAM PrnLibStream
ink-doc.office
ink-doc.inkas-code
ink-doc.doc-date
ink-doc.fact-date
ink-doc.netto
ink-doc.tot-doc
ink-doc.discnt
for-pcnt
ink-doc.sub-discnt
ink-doc.qnty
ink-doc.num-chk
ink-doc.shift-date
v-shift-name-num
ink-doc.obj-code
ink-doc.status_
v-flag
with FRAME Chk-List .
DISPLAY STREAM PrnLibStream
"ИТОГО " @ ink-doc.inkas-code
string(accum-count) @ ink-doc.doc-date
"отчетов" @ ink-doc.fact-date
accum-netto @ ink-doc.netto
accum-tot-doc @ ink-doc.tot-doc
accum-discnt @ ink-doc.discnt
(accum-discnt / accum-tot-doc * 100) @ for-pcnt
accum-sub-discnt @ ink-doc.sub-discnt
accum-qnty @ ink-doc.qnty
accum-num-chk @ ink-doc.num-chk
with frame Chk-List.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Chk-List.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-docs :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  RUN reopen-query IN THIS-PROCEDURE.
    apply "VALUE-CHANGED" to BR-docs.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  v-rid-list = p-rid-list.
  FIND FIRST ub.sys-ctrl NO-LOCK.
  if avail sys-ctrl then do:
    FIND FIRST db no-LOCK where
              db.db-num = sys-ctrl.db-num NO-ERROR.
    if not avail db then do:
      message "Отсутствует запись о БД (db)"
      view-as alert-box ERROR.
      return error.
    end.
  END.
  FIND FIRST buf_obj No-LOCK WHERE
                  buf_obj.obj-type = parobj-type and
                  buf_obj.obj-code = parobj-code No-ERROR.
  if not avail buf_obj then do:
      message vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова parobj-type и/или parobj-code"
      parobj-type parobj-code
      view-as alert-box ERROR.
      return.
  end.
CASE par-mode:
   WHEN 'все':U        THEN DO:
    END.
    WHEN 'фирма':U or
    when 'bge-run' then dO:
        FIND FIRST ub.sysconf No-LOCK WHERE
                          ub.sysconf.host-code = parhost-code No-ERROR.
        if not avail ub.sysconf then do:
            message vss-workfile vss-revision vss-description skip
                       "Неверное значение параметра вызова parhost-code" parhost-code
            view-as alert-box ERROR.
            return.
        end.
        find first buf_host no-lock where
                   buf_host.obj-type = 'орг':U
               AND buf_host.obj-code = parhost-code.
        assign varhost-name = buf_host.obj-name.
    END.
    WHEN 'объект':U or
    WHEN 'новый':U OR
    when 'bge-run'  or
    when "object-all" OR
    when 'запрос':U
    then dO:
        FIND FIRST buf_obj No-LOCK WHERE
                        buf_obj.obj-type = parobj-type and
                        buf_obj.obj-code = parobj-code No-ERROR.
        if not avail buf_obj then do:
            message vss-workfile vss-revision vss-description skip
            view-as alert-box ERROR.
            return.
        end.
    end.
    otherwise do:
        message vss-workfile vss-revision vss-description skip
        "Неверный вызов - par-mode=" par-mode
        view-as alert-box ERROR.
        return.
    end.
  end CASE.
  if par-mode = 'объект':U or
  par-mode = 'bge-run' or
  par-mode = 'новый':U   or
  par-mode = 'запрос':U
  then dO:
    run get-params in this-procedure ( input parobj-type, input parobj-code) .
  end.
  if v-rid-list <> "":U then do:
    assign
    v-doc-rec = integer(entry(1, v-rid-list))
    .
  end.
  run MyEnable IN THIS-PROCEDURE .
  RUn openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
Hide mark-num in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ED-notes sch-code sch-date sch-fact mark-num qnty shop-name num-chk
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-export B-chk B-print B-sch B-hist B-Help B-add
         b-lkp B-chg B-del B-close B-Open BR-docs ED-notes sch-code sch-date
         sch-fact mark-num qnty shop-name num-chk
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Get-params :
define input parameter locparobj-type like ub.clients.obj-type no-undo.
define input parameter locparobj-code like ub.clients.obj-code no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
find first ub.shop No-LOCK WHERE
ub.shop.obj-code = locparobj-code No-ERROR.
if not available ub.shop then return.
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  locparobj-type
    ,input  locparobj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF error-status:error then do:
  message
  substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , locparobj-type
            , locparobj-code
            , chr(10)
            , error-status:get-message(1)
            , return-value )
  view-as alert-box error .
  return error.
end.
cas-shft = v-value-logical.
ASSIGN
v-is-fbr-obj = ub.shop.is-catering.
run gbl/tpsi-obj.p (
              input locparobj-type
            , input locparobj-code
            , output v-is-tpsi-obj) no-error .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  locparobj-type
  ,input  locparobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
END PROCEDURE.
PROCEDURE MyEnable :
define variable main-tpsi as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
br-docs:num-locked-columns in frame Dialog-Frame = 7.
ASSIGN
v-tab-order = "b-quit,b-mark,b-sel,b-export,b-chk,b-sch,b-print,b-hist,b-help," +
              "b-add,b-lkp,b-chg,b-del,b-close,b-open,br-docs,sch-code,sch-date,sch-fact".
ASSIGN
b-print:MENU-MOUSE in frame Dialog-Frame = 1
b-export:MENU-MOUSE = 1
b-hist:MENU-MOUSE in frame Dialog-Frame = 1
.
IF v-is-tpsi-obj
AND par-mode = 'новый':U
and lookup("b-add":U, bttns) > 0  THEN DO:
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  run adm/shattri.p (
      input "get":U
      ,input  parobj-type
      ,input  parobj-code
      ,input  'autosale':U
      ,input  "":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
    message
    substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , parobj-type
              , parobj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )
    view-as alert-box error .
    return error.
  end.
  for each  thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = parobj-type
        and thbjattr_thbj-attr.obj-code = parobj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
  case thbjattr_thbj-attr.prop-code:
    when 'tpsi-mode':U then do:
      assign
      tpsi-mode = thbjattr_thbj-attr.property-value-integer.
    end.
    when 'main-tpsi':U then do:
      assign
      main-tpsi = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
  end.
  if tpsi-mode = 2 then do:
   ASSIGN
   b-add:MENU-MOUSE = 1.
  end.
  assign
  menu-item m_inquiry:sensitive in menu menu-b-add = main-tpsi
  .
END.
ELSE DO:
   add-option = 'касс':U.
   b-add:popup-menu = ?.
END.
DISPLAY
ED-notes
sch-code
sch-date
sch-fact
qnty
shop-name when (par-mode <> 'объект':U and par-mode <> 'новый':U)
num-chk
WITH FRAME Dialog-Frame.
IF par-mode = 'bge-run' THEN b-export :LABEL = "&Экспорт".
ENABLE
b-quit
B-mark when lookup("b-mark":U, bttns) > 0
B-sel when lookup("b-sel":U, bttns) > 0
b-add WHEN (par-mode = 'новый':U and lookup("b-add":U, bttns) > 0 )
b-chg WHEN (par-mode = 'новый':U and lookup("b-add":U, bttns) > 0 )
b-close WHEN (par-mode = 'новый':U and lookup("b-add":U, bttns) > 0 )
b-open WHEN (par-mode = 'новый':U and lookup("b-add":U, bttns) > 0 )
b-lkp
b-del when ((par-mode = 'новый':U and lookup("b-add":U, bttns) > 0 )
            or
            (par-mode <> 'новый':U and ub.db.db-num = buf_obj.db-num)
            )
B-export when lookup("b-export":U, bttns) > 0 or lookup("prov":U, bttns) > 0
B-chk
B-sch
B-print
B-hist
B-Help
BR-docs
ED-notes
sch-code
sch-date
sch-fact
mark-num
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF par-mode = 'новый':U THEN DO:
    DISABLE
    b-export
   with FRAME Dialog-Frame.
END.
IF NOT v-is-fbr-obj = YES THEN DO:
    ASSIGN
    ink-doc.AUTO-fbr:VISIBLE IN BROWSE br-docs = NO
    ink-doc.rest-dish:VISIBLE IN BROWSE br-docs = NO
    ink-doc.rest-ingr:VISIBLE IN BROWSE br-docs = NO
    .
END.
IF NOT v-is-tpsi-obj = YES THEN DO:
    ASSIGN
    ink-doc.AUTO-tpsi:VISIBLE IN BROWSE br-docs = NO
    ink-doc.rest-tpsi:VISIBLE IN BROWSE br-docs = NO
    .
END.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Продажи".
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .
case sort-column-name :
when "" then do:
assign
  sort-column-phrase = ""
.
end.
otherwise do:
assign
  sort-column-phrase = "by " + sort-column-name
.
end.
end case.
define variable l-open-query as logical   no-undo .
filter-point = filter-point0 + par-mode.
CASE par-mode :
WHEN 'все':U        THEN DO:
  assign
  filter-label = substitute("&1", filter-label0)
  .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-56  as logical   no-undo .
define variable  l-filter-open-56    as logical   .
define variable  flt-rec-56       as recid     no-undo .
define variable  filter-name-56      as character no-undo .
define variable  where-phrase-56     as character no-undo .
define variable  sort-phrase-56      as character no-undo .
define variable  where-phrase-rus-56 as character no-undo .
define variable  sort-phrase-rus-56  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-56
  ,output filter-name-56
  ,output where-phrase-56
  ,output sort-phrase-56
  ,output where-phrase-rus-56
  ,output sort-phrase-rus-56
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-56
      ) no-error .
  assign
    l-filter-open-56 = false
  .
  if flt-rec-56 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-56 as character no-undo .
    define variable  parameter-3-56 as character no-undo .
    define variable  parameter-4-56 as character no-undo .
    define variable  parameter-5-56 as character no-undo .
    define variable  parameter-6-56 as character no-undo .
    define variable  parameter-7-56 as character no-undo .
      assign
      parameter-3-56 =
                              "FOR EACH ink-doc"
      parameter-4-56 =
        (
          if (" ink-doc.status_ = 'факт':U " + " " + where-phrase-56) <> ""
          then " ink-doc.status_ = 'факт':U " + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + "")
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-56 =
          (" ink-doc.status_ = 'факт':U " + " " + where-phrase-56 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
                          )
      .
      assign
        l-filter-open-56 = true
      .
    end.
    if l-filter-open-56 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-56 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where  ink-doc.status_ = 'факт':U
       USE-INDEX host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-4-56 =
        "where ":u + " ink-doc.status_ = 'факт':U " + " ":u + where-phrase-56 + " ":u + p-find-condition + " " + ""
      parameter-5-56 = " USE-INDEX host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-56 = (if p-find-next then "true":u else "false":u )
      parameter-3-56 =  "FOR EACH ink-doc"
      parameter-4-56 =
        (
          if (" ink-doc.status_ = 'факт':U " + " " + where-phrase-56) <> ""
          then " ink-doc.status_ = 'факт':U " + " " + where-phrase-56
          else "true"
        )
      parameter-5-56 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-56 = if sort-phrase-56 = ''
                           then
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-56
        )
      parameter-7-56 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-56)
                          ,input no-lock
                          ,input parameter-3-56
                          ,input parameter-4-56
                          ,input parameter-5-56
                          ,input parameter-6-56
                          ,input parameter-7-56
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN 'фирма':U    THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + substitute(" Фирма: &1", varhost-name)
    .
  end.
  filter-label = substitute("&1 Одна фирма", filter-label0)
  .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-58  as logical   no-undo .
define variable  l-filter-open-58    as logical   .
define variable  flt-rec-58       as recid     no-undo .
define variable  filter-name-58      as character no-undo .
define variable  where-phrase-58     as character no-undo .
define variable  sort-phrase-58      as character no-undo .
define variable  where-phrase-rus-58 as character no-undo .
define variable  sort-phrase-rus-58  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-58
  ,output filter-name-58
  ,output where-phrase-58
  ,output sort-phrase-58
  ,output where-phrase-rus-58
  ,output sort-phrase-rus-58
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-58
      ) no-error .
  assign
    l-filter-open-58 = false
  .
  if flt-rec-58 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-58 as character no-undo .
    define variable  parameter-3-58 as character no-undo .
    define variable  parameter-4-58 as character no-undo .
    define variable  parameter-5-58 as character no-undo .
    define variable  parameter-6-58 as character no-undo .
    define variable  parameter-7-58 as character no-undo .
      assign
      parameter-3-58 =
                              "FOR EACH ink-doc"
      parameter-4-58 =
        (
          if (" ink-doc.host-code = parhost-code AND                                         ink-doc.status_ = 'факт':U                                     " + " " + where-phrase-58) <> ""
          then  substitute('ink-doc.host-code = &1 AND                                         ink-doc.status_ = &2&3&2 ', parhost-code, chr(34), 'факт':U)  + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + "")
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-58 =
          (" ink-doc.host-code = parhost-code AND                                         ink-doc.status_ = 'факт':U                                     " + " " + where-phrase-58 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-58
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ,input parameter-6-58
                          ,input parameter-7-58
                          )
      .
      assign
        l-filter-open-58 = true
      .
    end.
    if l-filter-open-58 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-58 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where  ink-doc.host-code = parhost-code AND                                         ink-doc.status_ = 'факт':U
       USE-INDEX host-date
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-4-58 =
        "where ":u +  substitute('ink-doc.host-code = &1 AND                                         ink-doc.status_ = &2&3&2 ', parhost-code, chr(34), 'факт':U)  + " ":u + where-phrase-58 + " ":u + p-find-condition + " " + ""
      parameter-5-58 = " USE-INDEX host-date "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-58 = (if p-find-next then "true":u else "false":u )
      parameter-3-58 =  "FOR EACH ink-doc"
      parameter-4-58 =
        (
          if (" ink-doc.host-code = parhost-code AND                                         ink-doc.status_ = 'факт':U                                     " + " " + where-phrase-58) <> ""
          then  substitute('ink-doc.host-code = &1 AND                                         ink-doc.status_ = &2&3&2 ', parhost-code, chr(34), 'факт':U)  + " " + where-phrase-58
          else "true"
        )
      parameter-5-58 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-58 = if sort-phrase-58 = ''
                           then
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX host-date " +
          " " + sort-column-phrase +
        " " + sort-phrase-58
        )
      parameter-7-58 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-58)
                          ,input no-lock
                          ,input parameter-3-58
                          ,input parameter-4-58
                          ,input parameter-5-58
                          ,input parameter-6-58
                          ,input parameter-7-58
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN 'объект':U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + substitute(" Закрытые - Объект: &1&2", parobj-type, parobj-code).
   end.
    filter-label = substitute("&1 Один объект, закрытые", filter-label0)
    .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-60  as logical   no-undo .
define variable  l-filter-open-60    as logical   .
define variable  flt-rec-60       as recid     no-undo .
define variable  filter-name-60      as character no-undo .
define variable  where-phrase-60     as character no-undo .
define variable  sort-phrase-60      as character no-undo .
define variable  where-phrase-rus-60 as character no-undo .
define variable  sort-phrase-rus-60  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-60
  ,output filter-name-60
  ,output where-phrase-60
  ,output sort-phrase-60
  ,output where-phrase-rus-60
  ,output sort-phrase-rus-60
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-60
      ) no-error .
  assign
    l-filter-open-60 = false
  .
  if flt-rec-60 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-60 as character no-undo .
    define variable  parameter-3-60 as character no-undo .
    define variable  parameter-4-60 as character no-undo .
    define variable  parameter-5-60 as character no-undo .
    define variable  parameter-6-60 as character no-undo .
    define variable  parameter-7-60 as character no-undo .
      assign
      parameter-3-60 =
                              "FOR EACH ink-doc"
      parameter-4-60 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'факт':U                         " + " " + where-phrase-60) <> ""
          then  substitute('ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&4&1 ', chr(34), parobj-type, parobj-code , 'факт':U)   + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + "")
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-60 =
          ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'факт':U                         " + " " + where-phrase-60 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-60
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ,input parameter-6-60
                          ,input parameter-7-60
                          )
      .
      assign
        l-filter-open-60 = true
      .
    end.
    if l-filter-open-60 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-60 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where        ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'факт':U
       USE-INDEX obj-stat
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-4-60 =
        "where ":u +  substitute('ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&4&1 ', chr(34), parobj-type, parobj-code , 'факт':U)   + " ":u + where-phrase-60 + " ":u + p-find-condition + " " + ""
      parameter-5-60 = " USE-INDEX obj-stat "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-60 = (if p-find-next then "true":u else "false":u )
      parameter-3-60 =  "FOR EACH ink-doc"
      parameter-4-60 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'факт':U                         " + " " + where-phrase-60) <> ""
          then  substitute('ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&4&1 ', chr(34), parobj-type, parobj-code , 'факт':U)   + " " + where-phrase-60
          else "true"
        )
      parameter-5-60 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-60 = if sort-phrase-60 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-60
        )
      parameter-7-60 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-60)
                          ,input no-lock
                          ,input parameter-3-60
                          ,input parameter-4-60
                          ,input parameter-5-60
                          ,input parameter-6-60
                          ,input parameter-7-60
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN 'новый':U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + substitute(" Незакрытые - Объект: &1&2", parobj-type, parobj-code).
  end.
    filter-label = substitute("&1 Один объект, незакрытые", filter-label0)
    .
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-62  as logical   no-undo .
define variable  l-filter-open-62    as logical   .
define variable  flt-rec-62       as recid     no-undo .
define variable  filter-name-62      as character no-undo .
define variable  where-phrase-62     as character no-undo .
define variable  sort-phrase-62      as character no-undo .
define variable  where-phrase-rus-62 as character no-undo .
define variable  sort-phrase-rus-62  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-62
  ,output filter-name-62
  ,output where-phrase-62
  ,output sort-phrase-62
  ,output where-phrase-rus-62
  ,output sort-phrase-rus-62
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-62
      ) no-error .
  assign
    l-filter-open-62 = false
  .
  if flt-rec-62 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-62 as character no-undo .
    define variable  parameter-3-62 as character no-undo .
    define variable  parameter-4-62 as character no-undo .
    define variable  parameter-5-62 as character no-undo .
    define variable  parameter-6-62 as character no-undo .
    define variable  parameter-7-62 as character no-undo .
      assign
      parameter-3-62 =
                              "FOR EACH ink-doc"
      parameter-4-62 =
        (
          if ("       ((ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'новый':U) or       (ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'нередакт':U))                         " + " " + where-phrase-62) <> ""
          then  substitute('((ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&4&1) or       (ink-doc.obj-type  = &1&2&1 AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&5&1)) ', chr(34), parobj-type, parobj-code , 'новый':U, 'нередакт':U)  + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "")
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-62 =
          ("       ((ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'новый':U) or       (ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'нередакт':U))                         " + " " + where-phrase-62 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-62
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ,input parameter-6-62
                          ,input parameter-7-62
                          )
      .
      assign
        l-filter-open-62 = true
      .
    end.
    if l-filter-open-62 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-62 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where        ((ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'новый':U) or       (ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'нередакт':U))
       USE-INDEX obj-stat
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-4-62 =
        "where ":u +  substitute('((ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&4&1) or       (ink-doc.obj-type  = &1&2&1 AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&5&1)) ', chr(34), parobj-type, parobj-code , 'новый':U, 'нередакт':U)  + " ":u + where-phrase-62 + " ":u + p-find-condition + " " + ""
      parameter-5-62 = " USE-INDEX obj-stat "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-62 = (if p-find-next then "true":u else "false":u )
      parameter-3-62 =  "FOR EACH ink-doc"
      parameter-4-62 =
        (
          if ("       ((ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'новый':U) or       (ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'нередакт':U))                         " + " " + where-phrase-62) <> ""
          then  substitute('((ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&4&1) or       (ink-doc.obj-type  = &1&2&1 AND       ink-doc.obj-code  = &3 AND       ink-doc.status_   = &1&5&1)) ', chr(34), parobj-type, parobj-code , 'новый':U, 'нередакт':U)  + " " + where-phrase-62
          else "true"
        )
      parameter-5-62 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-62 = if sort-phrase-62 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-62
        )
      parameter-7-62 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-62)
                          ,input no-lock
                          ,input parameter-3-62
                          ,input parameter-4-62
                          ,input parameter-5-62
                          ,input parameter-6-62
                          ,input parameter-7-62
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN 'запрос':U THEN DO:
  if p-open-query then do:
    ASSIGN
    frame Dialog-Frame:TITLE = title0 + substitute(" Закрытые запросы по продаже - Объект: &1&2", parobj-type, parobj-code).
  end.
    filter-label = substitute("&1 Один объект, закрытые запросы", filter-label0)
    .
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-64  as logical   no-undo .
define variable  l-filter-open-64    as logical   .
define variable  flt-rec-64       as recid     no-undo .
define variable  filter-name-64      as character no-undo .
define variable  where-phrase-64     as character no-undo .
define variable  sort-phrase-64      as character no-undo .
define variable  where-phrase-rus-64 as character no-undo .
define variable  sort-phrase-rus-64  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-64
  ,output filter-name-64
  ,output where-phrase-64
  ,output sort-phrase-64
  ,output where-phrase-rus-64
  ,output sort-phrase-rus-64
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-64
      ) no-error .
  assign
    l-filter-open-64 = false
  .
  if flt-rec-64 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-64 as character no-undo .
    define variable  parameter-3-64 as character no-undo .
    define variable  parameter-4-64 as character no-undo .
    define variable  parameter-5-64 as character no-undo .
    define variable  parameter-6-64 as character no-undo .
    define variable  parameter-7-64 as character no-undo .
      assign
      parameter-3-64 =
                              "FOR EACH ink-doc"
      parameter-4-64 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'запрос':U                         " + " " + where-phrase-64) <> ""
          then  substitute('ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3  AND       ink-doc.status_   = &1&4&1 ', chr(34), parobj-type, parobj-code, 'запрос':U)  + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + "")
      parameter-6-64 = if sort-phrase-64 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-64
        )
      parameter-7-64 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-64 =
          ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'запрос':U                         " + " " + where-phrase-64 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-64
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ,input parameter-6-64
                          ,input parameter-7-64
                          )
      .
      assign
        l-filter-open-64 = true
      .
    end.
    if l-filter-open-64 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-64 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where        ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'запрос':U
       USE-INDEX obj-stat
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-64 = (if p-find-next then "true":u else "false":u )
      parameter-4-64 =
        "where ":u +  substitute('ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3  AND       ink-doc.status_   = &1&4&1 ', chr(34), parobj-type, parobj-code, 'запрос':U)  + " ":u + where-phrase-64 + " ":u + p-find-condition + " " + ""
      parameter-5-64 = " USE-INDEX obj-stat "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-64)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-64 = (if p-find-next then "true":u else "false":u )
      parameter-3-64 =  "FOR EACH ink-doc"
      parameter-4-64 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_   = 'запрос':U                         " + " " + where-phrase-64) <> ""
          then  substitute('ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3  AND       ink-doc.status_   = &1&4&1 ', chr(34), parobj-type, parobj-code, 'запрос':U)  + " " + where-phrase-64
          else "true"
        )
      parameter-5-64 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-64 = if sort-phrase-64 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-64
        )
      parameter-7-64 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-64)
                          ,input no-lock
                          ,input parameter-3-64
                          ,input parameter-4-64
                          ,input parameter-5-64
                          ,input parameter-6-64
                          ,input parameter-7-64
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN "object-all" THEN DO:
if p-open-query then do:
  ASSIGN
  frame Dialog-Frame:TITLE = title0 + substitute(" Объект - все: &1&2", parobj-type, parobj-code).
end.
filter-label = substitute("&1 Один объект", filter-label0)
.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-66  as logical   no-undo .
define variable  l-filter-open-66    as logical   .
define variable  flt-rec-66       as recid     no-undo .
define variable  filter-name-66      as character no-undo .
define variable  where-phrase-66     as character no-undo .
define variable  sort-phrase-66      as character no-undo .
define variable  where-phrase-rus-66 as character no-undo .
define variable  sort-phrase-rus-66  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-66
  ,output filter-name-66
  ,output where-phrase-66
  ,output sort-phrase-66
  ,output where-phrase-rus-66
  ,output sort-phrase-rus-66
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-66
      ) no-error .
  assign
    l-filter-open-66 = false
  .
  if flt-rec-66 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-66 as character no-undo .
    define variable  parameter-3-66 as character no-undo .
    define variable  parameter-4-66 as character no-undo .
    define variable  parameter-5-66 as character no-undo .
    define variable  parameter-6-66 as character no-undo .
    define variable  parameter-7-66 as character no-undo .
      assign
      parameter-3-66 =
                              "FOR EACH ink-doc"
      parameter-4-66 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code                         " + " " + where-phrase-66) <> ""
          then  substitute(' ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)   + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "")
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-66 =
          ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code                         " + " " + where-phrase-66 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
                          )
      .
      assign
        l-filter-open-66 = true
      .
    end.
    if l-filter-open-66 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-66 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where        ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code
       USE-INDEX obj-stat
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-4-66 =
        "where ":u +  substitute(' ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)   + " ":u + where-phrase-66 + " ":u + p-find-condition + " " + ""
      parameter-5-66 = " USE-INDEX obj-stat "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-3-66 =  "FOR EACH ink-doc"
      parameter-4-66 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code                         " + " " + where-phrase-66) <> ""
          then  substitute(' ink-doc.obj-type  = &1&2&1  AND       ink-doc.obj-code  = &3 ', chr(34), parobj-type, parobj-code)   + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX obj-stat " +
          " " + sort-column-phrase +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN 'bge-run' THEN DO:
if p-open-query then do:
  ASSIGN frame Dialog-Frame:TITLE = substitute("Продажи без проводок Объект: &1&2", parobj-type, parobj-code).
end.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-68  as logical   no-undo .
define variable  l-filter-open-68    as logical   .
define variable  flt-rec-68       as recid     no-undo .
define variable  filter-name-68      as character no-undo .
define variable  where-phrase-68     as character no-undo .
define variable  sort-phrase-68      as character no-undo .
define variable  where-phrase-rus-68 as character no-undo .
define variable  sort-phrase-rus-68  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-68
  ,output filter-name-68
  ,output where-phrase-68
  ,output sort-phrase-68
  ,output where-phrase-rus-68
  ,output sort-phrase-rus-68
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-68
      ) no-error .
  assign
    l-filter-open-68 = false
  .
  if flt-rec-68 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-68 as character no-undo .
    define variable  parameter-3-68 as character no-undo .
    define variable  parameter-4-68 as character no-undo .
    define variable  parameter-5-68 as character no-undo .
    define variable  parameter-6-68 as character no-undo .
    define variable  parameter-7-68 as character no-undo .
      assign
      parameter-3-68 =
                              "FOR EACH ink-doc"
      parameter-4-68 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_ = 'факт':U AND       ink-doc.bge-date = ?                   " + " " + where-phrase-68) <> ""
          then  substitute('ink-doc.obj-type  = &1&2&1 AND       ink-doc.obj-code  = &3  AND       ink-doc.status_ = &1&4&1 AND       ink-doc.bge-date = ? ', chr(34), parobj-type , parobj-code, 'факт':U)  + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "")
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + " USE-INDEX bge-obj " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX bge-obj " +
          " " + sort-column-phrase +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-68 =
          ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_ = 'факт':U AND       ink-doc.bge-date = ?                   " + " " + where-phrase-68 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
                          )
      .
      assign
        l-filter-open-68 = true
      .
    end.
    if l-filter-open-68 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-68 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where        ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_ = 'факт':U AND       ink-doc.bge-date = ?
       USE-INDEX bge-obj
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-4-68 =
        "where ":u +  substitute('ink-doc.obj-type  = &1&2&1 AND       ink-doc.obj-code  = &3  AND       ink-doc.status_ = &1&4&1 AND       ink-doc.bge-date = ? ', chr(34), parobj-type , parobj-code, 'факт':U)  + " ":u + where-phrase-68 + " ":u + p-find-condition + " " + ""
      parameter-5-68 = " USE-INDEX bge-obj "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-3-68 =  "FOR EACH ink-doc"
      parameter-4-68 =
        (
          if ("       ink-doc.obj-type  = parobj-type  AND       ink-doc.obj-code  = parobj-code  AND       ink-doc.status_ = 'факт':U AND       ink-doc.bge-date = ?                   " + " " + where-phrase-68) <> ""
          then  substitute('ink-doc.obj-type  = &1&2&1 AND       ink-doc.obj-code  = &3  AND       ink-doc.status_ = &1&4&1 AND       ink-doc.bge-date = ? ', chr(34), parobj-type , parobj-code, 'факт':U)  + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + " USE-INDEX bge-obj " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX bge-obj " +
          " " + sort-column-phrase +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
WHEN 'bge-run-host'    THEN DO:
  if p-open-query then do:
    ASSIGN frame Dialog-Frame:TITLE = substitute("Продажи без проводок Фирма: &1", varhost-name).
  end.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-70  as logical   no-undo .
define variable  l-filter-open-70    as logical   .
define variable  flt-rec-70       as recid     no-undo .
define variable  filter-name-70      as character no-undo .
define variable  where-phrase-70     as character no-undo .
define variable  sort-phrase-70      as character no-undo .
define variable  where-phrase-rus-70 as character no-undo .
define variable  sort-phrase-rus-70  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-70
  ,output filter-name-70
  ,output where-phrase-70
  ,output sort-phrase-70
  ,output where-phrase-rus-70
  ,output sort-phrase-rus-70
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-70
      ) no-error .
  assign
    l-filter-open-70 = false
  .
  if flt-rec-70 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-70 as character no-undo .
    define variable  parameter-3-70 as character no-undo .
    define variable  parameter-4-70 as character no-undo .
    define variable  parameter-5-70 as character no-undo .
    define variable  parameter-6-70 as character no-undo .
    define variable  parameter-7-70 as character no-undo .
      assign
      parameter-3-70 =
                              "FOR EACH ink-doc"
      parameter-4-70 =
        (
          if (" ink-doc.host-code = parhost-code AND                       ink-doc.status_ = 'факт':U AND                       ink-doc.bge-date = ?                                     " + " " + where-phrase-70) <> ""
          then  substitute('ink-doc.host-code = &1 AND                       ink-doc.status_ = &1&3&1 AND                       ink-doc.bge-date = ? ', parhost-code, chr(34), 'факт':U)  + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "")
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + " USE-INDEX bge-host  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX bge-host  " +
          " " + sort-column-phrase +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-70 =
          (" ink-doc.host-code = parhost-code AND                       ink-doc.status_ = 'факт':U AND                       ink-doc.bge-date = ?                                     " + " " + where-phrase-70 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
                          )
      .
      assign
        l-filter-open-70 = true
      .
    end.
    if l-filter-open-70 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-70 = false then do:
    OPEN QUERY br-docs FOR EACH ink-doc
      where  ink-doc.host-code = parhost-code AND                       ink-doc.status_ = 'факт':U AND                       ink-doc.bge-date = ?
       USE-INDEX bge-host
      indexed-reposition
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( ink-doc )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-docs:handle:get-buffer-handle(1) = (buffer ink-doc:handle) then do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-4-70 =
        "where ":u +  substitute('ink-doc.host-code = &1 AND                       ink-doc.status_ = &1&3&1 AND                       ink-doc.bge-date = ? ', parhost-code, chr(34), 'факт':U)  + " ":u + where-phrase-70 + " ":u + p-find-condition + " " + ""
      parameter-5-70 = " USE-INDEX bge-host  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input rowid(ink-doc)
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input (buffer ink-doc:handle)
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-3-70 =  "FOR EACH ink-doc"
      parameter-4-70 =
        (
          if (" ink-doc.host-code = parhost-code AND                       ink-doc.status_ = 'факт':U AND                       ink-doc.bge-date = ?                                     " + " " + where-phrase-70) <> ""
          then  substitute('ink-doc.host-code = &1 AND                       ink-doc.status_ = &1&3&1 AND                       ink-doc.bge-date = ? ', parhost-code, chr(34), 'факт':U)  + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + " USE-INDEX bge-host  " +
          " " + sort-column-phrase +
        " " + "  "
        )
                           else
        (
        " " + " USE-INDEX bge-host  " +
          " " + sort-column-phrase +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-docs:handle
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END.
END CASE.
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-docs in frame Dialog-Frame.
APPLY "ENTRY" TO br-docs.
END PROCEDURE.
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define variable v-normal-call as logical no-undo .
define variable v-inkas-code as character no-undo .
CASE p-mode:
  WHEN 'касс':U THEN DO:
    v-normal-call = can-do("CHOOSE,ENTER":U, last-event:label) .
    if not v-normal-call
    and not l-shift-on then return no-apply.
    run str/cre-sale.p (
                      INPUT parparentproc
                    , INPUT parobj-type
                    , INPUT parobj-code
                    , INPUT 'ДОБАВЛЕНИЕ':U
                    , input '':U
                    , input (if not v-normal-call and l-shift-on
                             then  'ВЫБОР':U
                             else '':U)
                    , INPUT-output v-inkas-code
                    , INPUT 'касс':U ) no-error .
    if error-status:error then do:
      if return-value <> "cancell":U then do:
        message
        substitute("Ошибка при создании продажи:&1&2 &3", chr(10), error-status:get-message(1) , return-value )
        view-as alert-box .
        return no-apply.
      end.
    end.
  END.
  WHEN 'запрос':U  THEN DO:
     add-option = ''.
     run str/cre-sale.p (
                      INPUT parparentproc
                    , INPUT parobj-type
                    , INPUT parobj-code
                    , INPUT 'ДОБАВЛЕНИЕ':U
                    , input '':U
                    , input '':U
                    , INPUT-output v-inkas-code
                    , INPUT 'запрос':U ) no-error .
     if error-status:error then do:
       if return-value <> "cancell":U then do:
        message
        substitute("Ошибка при создании запроса продажи:&1&2 &3", chr(10), error-status:get-message(1) , return-value )
        view-as alert-box .
        return no-apply.
       end.
     end.
  END.
END CASE.
RUn openbr IN THIS-PROCEDURE ( INPUT yes, INPUT no, INPUT '':U).
APPLY "VALUE-CHANGED" to BR-docs IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-export :
define input parameter loc-option as character no-undo.
define variable glog as logical no-undo .
if loc-option = "":U then return error.
CASE loc-option :
    when "m_gen-3":u
    then do:
      ASSIGN
      glog = ERROR-STATUS :ERROR.
      APPLY "ENTRY":U TO br-docs IN FRAME Dialog-Frame.
      IF glog = yes THEN DO:
        RETURN NO-APPLY.
      END.
      IF LOOKUP( par-mode, 'bge-run' + chr(44) + 'bge-run-host' ) > 0 THEN DO:
        RUn openbr in this-procedure ( input yes, input no, input '':U ).
      end.
    end.
END CASE.
END PROCEDURE.
PROCEDURE proc-b-hist :
define variable varrid-list as character no-undo .
if not  available ink-doc THEN return error.
    run str/salclist.w (
                    input parparentproc
                   ,input '':U
                   ,input 'one':U
                   ,input ink-doc.inkas-code
                   ,input ink-doc.host-code
                   ,input ink-doc.obj-type
                   ,input ink-doc.obj-code
                   ,input-output varrid-list    ) no-error .
apply "entry" to br-docs in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-print :
DEFINE INPUT PARAMETER loc-option as character no-undo.
DEFINE VARIABLE v-frame-width as integer no-undo .
if loc-option = '':U then return error.
CASE loc-option:
when 'ONE':U then do:
    print-type = "".
    run rep/sale-prn.p (  input parparentproc
                    ,input recid(ink-doc)
                    ,input ?).
    print-type = "".
end.
when 'LIST':U then do:
  print-type = "".
  define variable v-curr-r-b as character no-undo .
  define variable v-base-type like ub.currency.curr-abbr no-undo .
  define variable v-base-code like ub.currency.curr-code no-undo .
  define buffer buf_currency for ub.currency.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if v-curr-r-b = 'base':U then do:
    if par-mode = 'все':U then do:
    end.
    else do:
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  parhost-code
  ,output v-base-code
  )  .
      find first buf_currency where
              buf_currency.curr-code = v-base-code.
      assign
      v-base-type = buf_currency.curr-abbr.
    end.
  end.
  v-doc-rec = recid( ink-doc ).
  DO WHILE available ink-doc :
    GET prev br-docs.
  END.
  run PrintListProc in this-procedure ( input v-curr-r-b, input v-base-type) no-error.
  reposition br-docs to recid v-doc-rec no-error.
  apply "entry" to br-docs in frame Dialog-Frame.
end.
end case.
loc-option = ''.
END PROCEDURE.
PROCEDURE proc-b-sch :
define variable l-shift-on as logical no-undo .
define variable cas-shft as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
tbl = 'inkas'
join-tbl = 'ink-doc'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('inkas-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('doc-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
CASE par-mode:
  WHEN  'все':U
  or
  when 'фирма':U
  THEN DO:
    run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type*obj-code*shift-date*shift-num'
                                      , 'Объект/Дата смены/№ смены'
                                      , ('sht' + chr(4) +
                                         '':U + chr(4) +
                                         string(0) + chr(4) +
                                         'no'),
    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  end.
  otherwise do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  'маг':U
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if not l-shift-on then do:
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.
      assign
      v-tth = buffer thbjattr_thbj-attr:table-handle .
      run adm/shattri.p (
           input "get":U
          ,input  parobj-type
          ,input  parobj-code
          ,input  'get-chk':U
          ,input  'cas-shft':U
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
      IF error-status:error then do:
        message
        substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
                  , parobj-type
                  , parobj-code
                  , chr(10)
                  , error-status:get-message(1)
                  , return-value )
        view-as alert-box error .
        return error.
      end.
      assign
      cas-shft = v-value-logical.
    end.
    if l-shift-on
    or cas-shft then do:
      run fltfield-add in this-procedure('shift-date*shift-num'
                                        , 'Дата смены/№ смены'
                                        , ('sht' + chr(4) +
                                          parobj-type + chr(4) +
                                          string(parobj-code) + chr(4) +
                                          (if l-shift-on then 'yes' else 'no')),
      input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    end.
  END.
END CASE.
run fltfield-add in this-procedure('shift-date', '', 'Дата смены(учета)',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок Смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ Смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('acc-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('num-chk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('qnty', 'Кол-во', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('status_', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Услуги(для <старых> продаж)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('host-code', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name', 'Посл.изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
  ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
  ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
run gbl/filter.w (
                 INPUT parparentproc
               , INPUT (filter-point + chr(4) +
                        filter-label + chr(4)  + string(yes))
               , INPUT tbl
               , INPUT join-tbl
               , INPUT fld
               , INPUT lab
               , INPUT spr
               , INPUT dim ).
run OpenBr  in this-procedure ( input yes, input no, input '':U).
END.
END PROCEDURE.
PROCEDURE proc-close :
define input parameter p-direction as logical no-undo .
define input parameter p-close-type as integer no-undo .
define input parameter p-status_ like ub.inkas.status_ no-undo .
define input parameter p-flag_   like ub.trn-doc.flag_ no-undo .
DEFINE VARIABLE compensed AS LOGICAL NO-UNDO.
DEFINE VARIABLE auto-comp AS LOGICAL NO-UNDO.
DEFINE VARIABLE autofbr AS LOGICAL NO-UNDO.
DEFINE VARIABLE one-curs AS LOGICAL NO-UNDO.
DEFINE VARIABLE restdish AS LOGICAL NO-UNDO.
DEFINE VARIABLE restingr AS LOGICAL NO-UNDO.
DEFINE VARIABLE resttpsi AS LOGICAL NO-UNDO.
define variable neg-tpsi-weight as logical no-undo .
define variable neg-tpsi-oper as logical no-undo .
define variable neg-tpsi-qnty as decimal no-undo .
define variable close-in-rfsl as integer no-undo .
define variable pay-gds-algo as character no-undo .
DEFINE VARIABLE v-is-tpsi-obj AS LOGICAL NO-UNDO.
define variable v-loc-rec as recid no-undo .
define variable v-parameter as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
DEFINE BUFFER buf_shop FOR ub.shop.
v-loc-rec = recid(ink-doc).
CASE p-close-type:
  when 1 then do:
    run str/salestat.p (
                        input parparentproc
                      , input ink-doc.inkas-code
                      , input (if p-direction then '<закрытие документа>':U else '<открытие документа>':U)
                      , input p-status_
                      , input p-flag_
                      , input no  ) no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при переводе статуса продажи &1:&2&3 &4"
                 , ink-doc.inkas-code
                 , chr(10)
                 , error-status:get-message(1)
                 , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    run Openbr in this-procedure ( input yes, input no, input '':U).
  end.
  when 2 then do:
    FIND FIRST buf_shop NO-LOCK WHERE
              buf_shop.obj-code = ink-doc.obj-code .
    run gbl/tpsi-obj.p ( input ink-doc.obj-type, input ink-doc.obj-code, output v-is-tpsi-obj) no-error .
    v-tth = buffer thbjattr_thbj-attr:table-handle .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
        input "get":U
        ,input  ink-doc.obj-type
        ,input  ink-doc.obj-code
        ,input  'autosale':U
        ,input  "":U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF error-status:error then do:
      message
      substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , ink-doc.obj-type
              , ink-doc.obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    for each  thbjattr_thbj-attr where
              thbjattr_thbj-attr.obj-type = ink-doc.obj-type
          and thbjattr_thbj-attr.obj-code = ink-doc.obj-code
          and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      case thbjattr_thbj-attr.prop-code:
        when 'autocomp':U then do:
          auto-comp = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'autofbr':U then do:
          autofbr = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'one-curs':U then do:
          one-curs = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'restdish':U then do:
          restdish = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'restingr':U then do:
          restingr = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'resttpsi':U then do:
          resttpsi = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'neg-tpsi-weight':U then do:
          neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'neg-tpsi-oper':U then do:
          neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
        end.
        when 'neg-tpsi-qnty':U then do:
          neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
        end.
        when 'close-in-rfsl':U then do:
          close-in-rfsl = thbjattr_thbj-attr.property-value-integer.
        end.
        when 'pay-gds-algo':U then do:
          pay-gds-algo = thbjattr_thbj-attr.property-value-character.
        end.
      end case.
      assign
      restdish = restdish and autofbr
      restingr = restingr and autofbr
      resttpsi = resttpsi and v-is-tpsi-obj
      .
    end.
    assign
    v-parameter =     v-curr-r-b                      + chr(4) +
                      ink-doc.inkas-code              + chr(4) +
                    string(1)              + chr(4) +
                    string(YES)        + chr(4) +
                    string(no)     + chr(4) +
                    string(auto-comp)                + chr(4) +
                    string(autofbr)                  + chr(4) +
                    string(one-curs)                 + chr(4) +
                    string(buf_shop.is-catering)     + chr(4) +
                    string(v-is-tpsi-obj)            + chr(4) +
                    string(restdish)                 + chr(4) +
                    string(restingr)                 + chr(4) +
                    string(resttpsi)                 + chr(4) +
                    string(neg-tpsi-weight)          + chr(4) +
                    string(neg-tpsi-qnty)            + chr(4) +
                    string(neg-tpsi-oper)            + chr(4) +
                    string(close-in-rfsl)            + chr(4) +
                    pay-gds-algo
    .
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/saleclos.p":U + chr(4) +
                "1":U  + chr(4) +
                "1":U + chr(4) +
                "1":U)
        , input v-parameter
        , input no
        , input "":U
        , input substitute("Закрытие продажи &1 &2&3", Ink-doc.inkas-code, ink-doc.obj-type, ink-doc.obj-code)
    ) no-error.
    if error-status:error
    and return-value <> "error"
    then do:
      message
      substitute("&1 &2"
                , error-status:get-message(1)
                , return-value )
      view-as alert-box error .
      return error .
    end.
    if return-value = "error":U then do:
      return error .
    end.
    else do:
      run Openbr in this-procedure ( input yes, input no, input '':U).
    end.
  end.
END CASE.
reposition br-docs to recid v-loc-rec no-error.
apply "entry" to br-docs in frame Dialog-Frame .
Apply "value-changed" to br-docs in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE Proc-find-code :
define input parameter par-next as logical no-undo.
define input parameter pardoc-code like ub.inkas.inkas-code no-undo.
display
"  /  /":U @ sch-date
"  /  /":U @ sch-fact
with frame Dialog-Frame.
assign
pardoc-code = chr(34) + pardoc-code + chr(34).
run OpenBr in this-procedure
  (input false
  ,input par-next
  ,input substitute("and ink-doc.inkas-code   begins &1 "
    , pardoc-code)
  ).
apply "entry":u to sch-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-date :
define input parameter par-next as logical no-undo.
define input parameter par-date like ub.inkas.doc-date no-undo.
define input parameter parwhat-date as character no-undo.
define variable var-datechr as character no-undo.
display
'':U @ sch-code
with frame Dialog-Frame.
assign
var-datechr = string(day(par-date)) + chr(47) +
              string(month(par-date)) + chr(47) +
              string(year(par-date)).
case parwhat-date:
  when "doc-date":U then do:
    display
    "  /  /":U @ sch-fact
    with frame Dialog-Frame.
    run OpenBr in this-procedure
    (input false
    ,input par-next
    ,input substitute("and ink-doc.doc-date = &1 "
      , var-datechr)
    ).
    apply "entry":u to sch-date in frame Dialog-Frame.
  end.
  when "fact-date":U then do:
    display
    "  /  /":U @ sch-date
    with frame Dialog-Frame.
    run OpenBr in this-procedure
      (input false
      ,input par-next
      ,input substitute("and ink-doc.fact-date = &1 "
      , var-datechr)
      ).
    apply "entry":u to sch-fact in frame Dialog-Frame.
  end.
END.
END PROCEDURE.
PROCEDURE reopen-query :
if available ink-doc then v-doc-rec = recid(ink-doc).
run OpenBr in this-procedure ( input  yes, input no, input '':U).
reposition br-docs to recid v-doc-rec no-error.
END PROCEDURE.
PROCEDURE reposition-inkas :
define input  parameter p-direction   as character no-undo .
define output parameter p-inkas-recid as recid no-undo .
  case p-direction :
    when "first":U
    then do:
      get first br-docs.
    end.
    when "last":U
    then do:
      get last br-docs.
    end.
    when "prev":U
    then do:
      get prev br-docs.
      if not available ink-doc then do:
        message
        "Это первый документ списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next br-docs.
      if not available ink-doc then do:
        message
        "Это последний документ списка"
        view-as alert-box.
      end.
    end.
  end case .
  assign
  p-inkas-recid = recid(ink-doc)
  .
  run reposition-query in this-procedure
    (input p-inkas-recid
    ).
END PROCEDURE.
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .
  if p-recid <> ?
  then do:
    reposition br-docs to recid p-recid no-error.
  end.
  do with frame Dialog-Frame:
    apply "entry":u to browse BR-docs .
    apply "VALUE-CHANGED":u to browse BR-docs .
  end.
END PROCEDURE.
