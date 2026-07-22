block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo .
define input parameter p-trn-doc-recid      as recid            no-undo .
define input parameter p-alldocs-handle     as character           no-undo .
define input parameter p-current-doc-only   as logical          no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: zeroinv.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/zeroinv.p $":U .
def var vss-description as character no-undo init "Пустографка".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
DEFINE BUFFER t-doc FOR trn-doc.
define shared variable  sort-name    as logical  no-undo.
define shared variable  sort-gr      as logical  no-undo.
define buffer buf_doc-line  for doc-line.
define buffer buf_trn-doc   for trn-doc.
define variable v-lines-counter     as int no-undo.
define variable v-br-docs-query     as handle    no-undo .
define variable v-t-doc-handle      as handle    no-undo .
define variable v-curr-query-rowid  as rowid     no-undo .
def temp-table temp_goods no-undo
    field obj-type      as character
    field obj-code      as integer
    field gds-code      as integer
    field artic         as character
    field prod-type     as character
    field prod-code     as integer
    field gds-name      as character
    field full-grp-name as character
    index byart is primary unique artic prod-type prod-code
    index byname gds-name artic
    index bygrp full-grp-name
.
define stream OutStream.
define variable v-fact-qnty     as decimal      init 0  no-undo.
define variable v-line-string   as character            no-undo.
define variable v-doc-string    as character            no-undo.
define variable v-bar-code      as integer              no-undo.
define variable v-dif           as char                 no-undo.
define variable v-str           as char                 no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define buffer buf_goods     for goods.
 DEFINE FRAME zapas
        v-lines-counter     column-label "№"            format ">>>>>>>9":C             space(0)
        sym1                column-label ":"            format "x(1)"                   space(0)
        GOODS.GDS-CODE      column-label "Код"          format ">>>>>>>>9"              space(0)
        sym2                column-label ":"            format "x(1)"                   space(0)
        Goods.artic         column-label "Артикул"      format "X(16)"                  space(0)
        sym3                column-label ":"            format "x(1)"                   space(0)
        Goods.gds-name      column-label "Наименование" format "X(30)"  space(0)
        sym4                column-label ":"            format "x(1)"                   space(0)
        Goods.unit-base     column-label "ед.изм"       format "X(6)"                   space(0)
        sym5                column-label ":"            format "x(1)"                   space(0)
        Gds-obj.fact-qnty   column-label "Кол-во уч."   format "->>>>>9.<<<"            space(0)
        sym6                column-label ":"            format "x(1)"                   space(0)
        bar-code.b-code     column-label "Бар-код"       format ">>>>>>>>>>>>>>>9":L16   space(0)
        sym7                column-label ":"            format "x(1)"                   space(0)
        Gds-obj.price-sale  column-label "Розн. цена"   format "->>>>>>>>9.<<"          space(0)
        sym8                column-label ":"            format "x(1)"                   space(0)
        v-fact-qnty         column-label "Факт. кол-во" format "->>>>>>>>>>"            space(0)
    HEADER
        cur-time-print()                                                        at 5    format "X(35)"
        string( "Объект " + string( v-cntxt-obj-type) + " " + string( v-cntxt-obj-code) )   at 48   format "X(13)"
        v-doc-string                                                            at 67   format "X(40)"
        string( "Страница " + string( PAGE-NUMBER( OutStream ), ">>>>>>9") )    at 111  format "X(17)"
    skip
        v-line-string  format "X(126)"  with width 136 down stream-io use-text NO-BOX.
     run rep/zeroinvd.w ( output v-dif ) no-error.
    if error-status :error then do:
      assign
        v-dif = "all"
      .
    end.
if session :set-wait-state( "compiler" ) then.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in p-mainmenu-handle
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
output stream OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
    case v-dif:
      when "all" then do:
        assign
          v-str = ""
        .
      end.
      when "shortage" then do:
        assign
          v-str = " (НЕДОСТАЧА)"
        .
      end.
      when "surplus" then do:
        assign
          v-str = " (ИЗЛИШКИ)"
        .
      end.
      when "coincidence" then do:
        assign
          v-str = " (СОВПАДЕНИЕ)"
        .
      end.
      when "zero-remainder" then do:
        assign
          v-str = " (НУЛЕВОЙ ОСТАТОК)"
        .
      end.
      otherwise do:
        assign
          v-str = ""
        .
      end.
    end case.
    put stream OutStream
        string( "СПИСОК ТОВАРОВ" + v-str ) AT 50 format "X(85)"
    skip(2).
    form with frame zapas .
    assign
        v-line-string = fill("-", 129)
    .
    form header
        v-line-string format "X(129)" at 1 skip
        "Продолжение - на следующей странице" at 30 skip
        with frame BottomFrame width 136 page-bottom no-labels no-box .
    view stream OutStream frame BottomFrame .
if p-current-doc-only = yes
then do:
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    .
    assign
        v-doc-string = "По документу N " + buf_trn-doc.doc-code + " от " + string( buf_trn-doc.doc-date, "99/99/9999" )
    .
    case v-dif:
      when "all" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
        :
          find first temp_goods              where temp_goods.artic     = buf_doc-line.artic                and temp_goods.prod-type = buf_doc-line.prod-type                and temp_goods.prod-code = buf_doc-line.prod-code         no-error.         if not available temp_goods         then do:             find first buf_goods no-lock                  where buf_goods.artic      = buf_doc-line.artic                    and buf_goods.prod-type  = buf_doc-line.prod-type                    and buf_goods.prod-code  = buf_doc-line.prod-code             no-error.             create temp_goods no-error.             assign                 temp_goods.obj-type         = buf_doc-line.obj-type                 temp_goods.obj-code         = buf_doc-line.obj-code                 temp_goods.artic            = buf_doc-line.artic                 temp_goods.prod-type        = buf_doc-line.prod-type                 temp_goods.prod-code        = buf_doc-line.prod-code                 temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )                 temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )                 temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )                 no-error.         end.
        end.
      end.
      when "shortage" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.fact-qnty < 0
        :
          find first temp_goods              where temp_goods.artic     = buf_doc-line.artic                and temp_goods.prod-type = buf_doc-line.prod-type                and temp_goods.prod-code = buf_doc-line.prod-code         no-error.         if not available temp_goods         then do:             find first buf_goods no-lock                  where buf_goods.artic      = buf_doc-line.artic                    and buf_goods.prod-type  = buf_doc-line.prod-type                    and buf_goods.prod-code  = buf_doc-line.prod-code             no-error.             create temp_goods no-error.             assign                 temp_goods.obj-type         = buf_doc-line.obj-type                 temp_goods.obj-code         = buf_doc-line.obj-code                 temp_goods.artic            = buf_doc-line.artic                 temp_goods.prod-type        = buf_doc-line.prod-type                 temp_goods.prod-code        = buf_doc-line.prod-code                 temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )                 temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )                 temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )                 no-error.         end.
        end.
      end.
      when "surplus" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.fact-qnty > 0
        :
          find first temp_goods              where temp_goods.artic     = buf_doc-line.artic                and temp_goods.prod-type = buf_doc-line.prod-type                and temp_goods.prod-code = buf_doc-line.prod-code         no-error.         if not available temp_goods         then do:             find first buf_goods no-lock                  where buf_goods.artic      = buf_doc-line.artic                    and buf_goods.prod-type  = buf_doc-line.prod-type                    and buf_goods.prod-code  = buf_doc-line.prod-code             no-error.             create temp_goods no-error.             assign                 temp_goods.obj-type         = buf_doc-line.obj-type                 temp_goods.obj-code         = buf_doc-line.obj-code                 temp_goods.artic            = buf_doc-line.artic                 temp_goods.prod-type        = buf_doc-line.prod-type                 temp_goods.prod-code        = buf_doc-line.prod-code                 temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )                 temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )                 temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )                 no-error.         end.
        end.
      end.
      when "coincidence" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.fact-qnty = 0
        :
          find first temp_goods              where temp_goods.artic     = buf_doc-line.artic                and temp_goods.prod-type = buf_doc-line.prod-type                and temp_goods.prod-code = buf_doc-line.prod-code         no-error.         if not available temp_goods         then do:             find first buf_goods no-lock                  where buf_goods.artic      = buf_doc-line.artic                    and buf_goods.prod-type  = buf_doc-line.prod-type                    and buf_goods.prod-code  = buf_doc-line.prod-code             no-error.             create temp_goods no-error.             assign                 temp_goods.obj-type         = buf_doc-line.obj-type                 temp_goods.obj-code         = buf_doc-line.obj-code                 temp_goods.artic            = buf_doc-line.artic                 temp_goods.prod-type        = buf_doc-line.prod-type                 temp_goods.prod-code        = buf_doc-line.prod-code                 temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )                 temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )                 temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )                 no-error.         end.
        end.
      end.
      when "zero-remainder" then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
          and buf_doc-line.doc-qnty = 0
          and buf_doc-line.cli-qnty = 0
        :
          find first temp_goods              where temp_goods.artic     = buf_doc-line.artic                and temp_goods.prod-type = buf_doc-line.prod-type                and temp_goods.prod-code = buf_doc-line.prod-code         no-error.         if not available temp_goods         then do:             find first buf_goods no-lock                  where buf_goods.artic      = buf_doc-line.artic                    and buf_goods.prod-type  = buf_doc-line.prod-type                    and buf_goods.prod-code  = buf_doc-line.prod-code             no-error.             create temp_goods no-error.             assign                 temp_goods.obj-type         = buf_doc-line.obj-type                 temp_goods.obj-code         = buf_doc-line.obj-code                 temp_goods.artic            = buf_doc-line.artic                 temp_goods.prod-type        = buf_doc-line.prod-type                 temp_goods.prod-code        = buf_doc-line.prod-code                 temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )                 temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )                 temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )                 no-error.         end.
        end.
      end.
      otherwise do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code =  buf_trn-doc.doc-code
        :
          find first temp_goods              where temp_goods.artic     = buf_doc-line.artic                and temp_goods.prod-type = buf_doc-line.prod-type                and temp_goods.prod-code = buf_doc-line.prod-code         no-error.         if not available temp_goods         then do:             find first buf_goods no-lock                  where buf_goods.artic      = buf_doc-line.artic                    and buf_goods.prod-type  = buf_doc-line.prod-type                    and buf_goods.prod-code  = buf_doc-line.prod-code             no-error.             create temp_goods no-error.             assign                 temp_goods.obj-type         = buf_doc-line.obj-type                 temp_goods.obj-code         = buf_doc-line.obj-code                 temp_goods.artic            = buf_doc-line.artic                 temp_goods.prod-type        = buf_doc-line.prod-type                 temp_goods.prod-code        = buf_doc-line.prod-code                 temp_goods.gds-code         = ( if available buf_goods then buf_goods.gds-code else 0 )                 temp_goods.gds-name         = ( if available buf_goods then buf_goods.gds-name else "" )                 temp_goods.full-grp-name    = ( if available buf_goods then trim( buf_goods.grp-name," /\" ) else "" )                 no-error.         end.
        end.
      end.
    end case.
end.
else do:
    run get-doc-handles in this-procedure ( output v-br-docs-query ).
    assign
        v-doc-string        = ""
        v-t-doc-handle      = v-br-docs-query :get-buffer-handle()
        v-curr-query-rowid  = v-t-doc-handle :rowid
    .
    v-br-docs-query :get-first().
    do while not v-br-docs-query :query-off-end :
      find first t-doc no-lock
        where rowid(t-doc) = v-t-doc-handle :rowid
      no-error .
      if not available t-doc then do:
        message
          "Не найдена запись из списка документов"
        view-as alert-box error.
        return error .
      end.
      case v-dif:
        when "all" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
          :
              find first temp_goods                  where temp_goods.artic     = buf_doc-line.artic                    and temp_goods.prod-type = buf_doc-line.prod-type                    and temp_goods.prod-code = buf_doc-line.prod-code             no-error.             if not available temp_goods             then do:                 find first buf_goods no-lock                      where buf_goods.artic      = buf_doc-line.artic                        and buf_goods.prod-type  = buf_doc-line.prod-type                        and buf_goods.prod-code  = buf_doc-line.prod-code                 .                 create temp_goods no-error.                 assign                     temp_goods.artic      = buf_doc-line.artic                     temp_goods.obj-code   = buf_doc-line.obj-code                     temp_goods.obj-type   = buf_doc-line.obj-type                     temp_goods.prod-code  = buf_doc-line.prod-code                     temp_goods.prod-type  = buf_doc-line.prod-type                     temp_goods.gds-code   = buf_goods.gds-code                     temp_goods.gds-name   = buf_goods.gds-name                 no-error.             end.
          end.
        end.
        when "shortage" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.fact-qnty < 0
          :
              find first temp_goods                  where temp_goods.artic     = buf_doc-line.artic                    and temp_goods.prod-type = buf_doc-line.prod-type                    and temp_goods.prod-code = buf_doc-line.prod-code             no-error.             if not available temp_goods             then do:                 find first buf_goods no-lock                      where buf_goods.artic      = buf_doc-line.artic                        and buf_goods.prod-type  = buf_doc-line.prod-type                        and buf_goods.prod-code  = buf_doc-line.prod-code                 .                 create temp_goods no-error.                 assign                     temp_goods.artic      = buf_doc-line.artic                     temp_goods.obj-code   = buf_doc-line.obj-code                     temp_goods.obj-type   = buf_doc-line.obj-type                     temp_goods.prod-code  = buf_doc-line.prod-code                     temp_goods.prod-type  = buf_doc-line.prod-type                     temp_goods.gds-code   = buf_goods.gds-code                     temp_goods.gds-name   = buf_goods.gds-name                 no-error.             end.
          end.
        end.
        when "surplus" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.fact-qnty > 0
          :
              find first temp_goods                  where temp_goods.artic     = buf_doc-line.artic                    and temp_goods.prod-type = buf_doc-line.prod-type                    and temp_goods.prod-code = buf_doc-line.prod-code             no-error.             if not available temp_goods             then do:                 find first buf_goods no-lock                      where buf_goods.artic      = buf_doc-line.artic                        and buf_goods.prod-type  = buf_doc-line.prod-type                        and buf_goods.prod-code  = buf_doc-line.prod-code                 .                 create temp_goods no-error.                 assign                     temp_goods.artic      = buf_doc-line.artic                     temp_goods.obj-code   = buf_doc-line.obj-code                     temp_goods.obj-type   = buf_doc-line.obj-type                     temp_goods.prod-code  = buf_doc-line.prod-code                     temp_goods.prod-type  = buf_doc-line.prod-type                     temp_goods.gds-code   = buf_goods.gds-code                     temp_goods.gds-name   = buf_goods.gds-name                 no-error.             end.
          end.
        end.
        when "coincidence" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.fact-qnty = 0
          :
              find first temp_goods                  where temp_goods.artic     = buf_doc-line.artic                    and temp_goods.prod-type = buf_doc-line.prod-type                    and temp_goods.prod-code = buf_doc-line.prod-code             no-error.             if not available temp_goods             then do:                 find first buf_goods no-lock                      where buf_goods.artic      = buf_doc-line.artic                        and buf_goods.prod-type  = buf_doc-line.prod-type                        and buf_goods.prod-code  = buf_doc-line.prod-code                 .                 create temp_goods no-error.                 assign                     temp_goods.artic      = buf_doc-line.artic                     temp_goods.obj-code   = buf_doc-line.obj-code                     temp_goods.obj-type   = buf_doc-line.obj-type                     temp_goods.prod-code  = buf_doc-line.prod-code                     temp_goods.prod-type  = buf_doc-line.prod-type                     temp_goods.gds-code   = buf_goods.gds-code                     temp_goods.gds-name   = buf_goods.gds-name                 no-error.             end.
          end.
        end.
        when "zero-remainder" then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
            and buf_doc-line.doc-qnty = 0
            and buf_doc-line.cli-qnty = 0
          :
              find first temp_goods                  where temp_goods.artic     = buf_doc-line.artic                    and temp_goods.prod-type = buf_doc-line.prod-type                    and temp_goods.prod-code = buf_doc-line.prod-code             no-error.             if not available temp_goods             then do:                 find first buf_goods no-lock                      where buf_goods.artic      = buf_doc-line.artic                        and buf_goods.prod-type  = buf_doc-line.prod-type                        and buf_goods.prod-code  = buf_doc-line.prod-code                 .                 create temp_goods no-error.                 assign                     temp_goods.artic      = buf_doc-line.artic                     temp_goods.obj-code   = buf_doc-line.obj-code                     temp_goods.obj-type   = buf_doc-line.obj-type                     temp_goods.prod-code  = buf_doc-line.prod-code                     temp_goods.prod-type  = buf_doc-line.prod-type                     temp_goods.gds-code   = buf_goods.gds-code                     temp_goods.gds-name   = buf_goods.gds-name                 no-error.             end.
          end.
        end.
        otherwise do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code =  t-doc.doc-code
          :
              find first temp_goods                  where temp_goods.artic     = buf_doc-line.artic                    and temp_goods.prod-type = buf_doc-line.prod-type                    and temp_goods.prod-code = buf_doc-line.prod-code             no-error.             if not available temp_goods             then do:                 find first buf_goods no-lock                      where buf_goods.artic      = buf_doc-line.artic                        and buf_goods.prod-type  = buf_doc-line.prod-type                        and buf_goods.prod-code  = buf_doc-line.prod-code                 .                 create temp_goods no-error.                 assign                     temp_goods.artic      = buf_doc-line.artic                     temp_goods.obj-code   = buf_doc-line.obj-code                     temp_goods.obj-type   = buf_doc-line.obj-type                     temp_goods.prod-code  = buf_doc-line.prod-code                     temp_goods.prod-type  = buf_doc-line.prod-type                     temp_goods.gds-code   = buf_goods.gds-code                     temp_goods.gds-name   = buf_goods.gds-name                 no-error.             end.
          end.
        end.
      end case.
      v-br-docs-query :get-next().
    end.
    v-br-docs-query :reposition-to-rowid( v-curr-query-rowid ) .
end.
if sort-gr = yes
then do:
    if sort-name = no
    then do:
        for each temp_goods
        break by temp_goods.full-grp-name
              by temp_goods.artic
              by temp_goods.prod-type
              by temp_goods.prod-code
        :
            if first-of( temp_goods.full-grp-name )
            then do:
                run print-group-line in this-procedure (
                    input temp_goods.full-grp-name
                ).
            end.
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.
    else do:
        for each temp_goods
        break by temp_goods.full-grp-name
              by temp_goods.gds-name
        :
            if first-of( temp_goods.full-grp-name )
            then do:
                run print-group-line in this-procedure (
                    input temp_goods.full-grp-name
                ).
            end.
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.
end.
else do:
    if sort-name = no
    then do:
        for each temp_goods
        use-index byart
        :
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.
    else do:
        for each temp_goods
        use-index byname
        :
            run print-line in this-procedure (
                  input temp_goods.artic
                , input temp_goods.prod-type
                , input temp_goods.prod-code
            ).
        end.
    end.
end.
HIDE   stream OutStream FRAME BottomFrame .
HIDE   STREAM OutStream FRAME ZAPAS .
Output stream OutStream close.
if session :set-wait-state( "" ) then.
find first temp_goods no-lock no-error.
if available temp_goods then
do:
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 0 >= 8 then 2 else 0), 0, 0,
                                      OUTPUT g#log ).
end.
else do:
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + " " +
      string( session:temp-directory) +  "$" + string( g#report-num )
              ) .
  os-command silent
    value( "COPY /b " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl" + " + " +
      string( session:temp-directory) + "rpt" + string( g#report-num ) + ".txl" + " " +
      string( session:temp-directory) +  "$" + string( g#report-num ) + ".txl"
              ) .
end.
end.
else do:
  message "Товаров удовлетворяющих условию не найдено!" view-as alert-box.
end.
procedure print-line :
do
on error undo, return error
:
define input parameter p-artic      as character    no-undo.
define input parameter p-prod-type  as character    no-undo.
define input parameter p-prod-code  as integer      no-undo.
    define variable v-gds-name-1    as character    no-undo.
    define variable v-gds-name-2    as character    no-undo.
    define buffer buf_temp_goods       for temp_goods.
    find first buf_temp_goods
         where buf_temp_goods.artic     = p-artic
           and buf_temp_goods.prod-type = p-prod-type
           and buf_temp_goods.prod-code = p-prod-code
    .
    find first goods
         where goods.artic      = buf_temp_goods.artic
           and goods.prod-type  = buf_temp_goods.prod-type
           and goods.prod-code  = buf_temp_goods.prod-code
    no-error.
    if available goods
    then do:
        assign
            v-lines-counter = v-lines-counter + 1
        .
If Integer(50) = 0 Then Temp1  = 100  .
                      Else Temp1 = Integer(50) .
     IF ( v-lines-counter modulo Temp1 = 0 ) AND ( v-lines-counter >= Temp1 ) then
         RUN waitfram-show( "Обработано строк : " + string( v-lines-counter )) .
        find first gds-obj no-lock
             where gds-obj.gds-code = goods.gds-code
               and gds-obj.obj-type = v-cntxt-obj-type
               and gds-obj.obj-code = v-cntxt-obj-code
        no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  ?
  ,output v-bar-code
  )  .
        run split-string in this-procedure (
              input goods.gds-name
            , input 30
            , output v-gds-name-1
            , output v-gds-name-2
        ).
        display stream OutStream
            Sym1  Sym2 Sym3 Sym4 Sym5  Sym6 Sym7  Sym8
            v-lines-counter
            goods.gds-code
            goods.artic
            v-gds-name-1        @ goods.gds-name
            goods.unit-base
            gds-obj.fact-qnty   when ( available gds-obj and ( available( t-doc ) and ( t-doc.status_ <>  'накл':U and t-doc.status_ <>  'новый':U ) ) )
            gds-obj.price-sale  when available gds-obj
            string( v-bar-code ) format "X(16)" @ bar-code.b-code
        with frame zapas.
        down stream  OutStream 1 with frame zapas.
        for each bar-code no-lock
           where bar-code.gds-code = goods.gds-code
             and bar-code.in-code = ""
             and bar-code.part-code = ""
        :
            for each prod-bc no-lock
               where prod-bc.b-code = bar-code.b-code
            :
                display stream OutStream
                    Sym1  Sym2 Sym3 Sym4 Sym5  Sym6 Sym7  Sym8
                    trim( prod-bc.b-str ) format "X(16)"    @ bar-code.b-code
                    v-gds-name-2  when  v-gds-name-2 <> ""  @ goods.gds-name
                with frame zapas .
                down stream  OutStream 1 with frame zapas.
                assign
                    v-gds-name-2 = ""
                .
            end.
        end.
        if v-gds-name-2 <> ""
        then do:
            display stream OutStream
                Sym1  Sym2 Sym3 Sym4 Sym5  Sym6 Sym7  Sym8
                v-gds-name-2        @ goods.gds-name
            with frame zapas.
            down stream  OutStream 1 with frame zapas.
        end.
        underline stream OutStream
            Sym1  Sym2 Sym3 Sym4 Sym5  Sym6  Sym7  Sym8
            v-lines-counter
            goods.gds-code
            goods.artic
            goods.unit-base
            goods.gds-name
            bar-code.b-code
            v-fact-qnty
            gds-obj.fact-qnty
            gds-obj.price-sale
        with frame zapas .
        down stream  OutStream 1 with frame zapas.
    end.
end.
end procedure.
procedure print-group-line :
define input parameter p-full-grp-name  as character        no-undo.
do
on error undo, return error
:
    if line-counter( OutStream ) + 5 > page-size( OutStream )
    then do:
        page stream outstream.
    end.
    if v-lines-counter <> 0
    then do:
        down stream outstream 1 with frame zapas .
        put stream outstream
            skip (1)
        .
    end.
    else do:
        down stream outstream 1 with frame zapas .
    end.
    put stream outstream
            ": Группа: "
            p-full-grp-name format "X(100)"
            ":"
        skip v-line-string  format "X(126)"
    .
end.
end procedure.
procedure split-string :
define input parameter p-source-string  as character        no-undo.
define input parameter p-split-length   as integer          no-undo.
define output parameter p-string-1      as character        no-undo.
define output parameter p-string-2      as character        no-undo.
do
on error undo, return error
:
    define variable v-space-pos    as integer      no-undo.
    if length( p-source-string ) <= p-split-length
    then do:
        assign
            p-string-1 = p-source-string
        .
    end.
    else do:
        assign
            v-space-pos = r-index( p-source-string, " ":U, p-split-length )
        .
        if v-space-pos = 0
        then do:
            assign
                p-string-1 = substring( p-source-string, 1, p-split-length )
                p-string-2 = trim( substring( p-source-string, p-split-length, p-split-length ) )
            .
        end.
        else do:
            assign
                p-string-1 = substring( p-source-string, 1, v-space-pos )
                p-string-2 = trim( substring( p-source-string, v-space-pos, p-split-length ) )
            .
        end.
    end.
end.
end procedure.
procedure get-doc-handles :
  define output parameter p-browse-query-handle  as handle    no-undo .
  define variable v-alldocs-handle as handle    no-undo .
do
on error undo, return error return-value
:
  assign
    v-alldocs-handle = widget-handle(p-alldocs-handle)
  .
  if valid-handle(v-alldocs-handle)
    and v-alldocs-handle :get-signature("get-browse-query-handle") <> ""
  then do:
    run get-browse-query-handle  in v-alldocs-handle ( output p-browse-query-handle  ).
  end.
end.
end procedure.
