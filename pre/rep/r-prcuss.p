block-level on error undo, throw.
define input  parameter p-par1 as character no-undo .
define input  parameter v-curr-code as integer   no-undo .
define input  parameter v-clas as character no-undo .
define input  parameter v-sort as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: caa5562b367b, 1893, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 07 16:26:45 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-prcuss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-prcuss.p $":U .
define variable vss-description as character no-undo init "Отчет Отчет по прайс-листам".
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
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
define variable v-curr-abbr  as character no-undo .
define variable v-Reportname as character no-undo .
define variable v-strline    as character no-undo init "---".
define variable v-type as integer   no-undo .
define variable v-fact-order as decimal   no-undo .
define variable new-curr-code as integer   no-undo .
define variable f-price-roz as logical no-undo.
run factord-end-day in this-procedure
   (input x-date-alone ,
    output v-fact-order) .
 define buffer buf_buyer-group for ub.buyer-group  .
v-Reportname = "О Т Ч Е Т  П О  П Р А Й С - Л И С Т А М"  .
define stream  OutStream  .
define stream  macr_excel .
define variable v-file-name as character no-undo .
define variable v-ind       as integer   no-undo .
define variable num#col#    as integer no-undo .
define variable C-c    as integer no-undo .
define variable C-str  as character no-undo .
define variable str--1 as character Format "x(60)" no-undo.
define variable str--2 as integer no-undo .
define variable C-i    as integer no-undo .
define variable p-var  as integer no-undo .
define variable var-1  as integer no-undo .
define variable var-2  as integer no-undo .
define buffer this_object for  ub.clients .
define variable num-ln as integer   no-undo .
define variable i as integer no-undo.
define variable j as integer no-undo.
define variable Counter1 as integer init 0  no-undo .
define variable LineBuf       as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.
define variable     Lines_Counter as   integer  init 0  no-undo.
define variable     Tmp_Counter   as   integer  init 0  no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .
define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_goods for ub.goods  .
define temp-table temp-header no-undo
field id as integer
field bgr-id  as integer
field bgr-db-num   as integer
field name    as character
index pi
 bgr-id
 bgr-db-num
.
define temp-table temp-price no-undo
field plt-id     as int
field plt-db-num as int
field b-code   as integer
field gds-code as integer
field id as decimal
field price-sale as decimal
.
define temp-table temp-pdf no-undo
field gds-code  as integer
field grp-code  as integer
field prod-typecode as char
field artic     as char
field unit-cli  as char
field price-roz as decimal
field gds-name  as char
field grp-name  as char
field prod-name as char
field b-code as integer
field prior  as integer
field date1  as date
field date2  as date
field plt-id     as int
field plt-db-num as int
field nul        as int
index pi
b-code
prior
plt-id
plt-db-num
index pi2
gds-code
prior
plt-id
plt-db-num
index pi3
artic
prior
plt-id
plt-db-num
index pi4
gds-name
prior
plt-id
plt-db-num
.
define variable v-kol-price as integer   no-undo .
DEFINE FRAME plan-menu
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    UndLine format "X(80)" AT 1
    with width 235 down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.
  if session:set-wait-state("compiler") then.
output STREAM OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(ReportPageHeight) .
  define variable v-prn0 as character no-undo .
  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .
define variable v-is-base as logical no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-is-base
  )  .
if v-is-base = true then do:
end.
else do:
end.
v-ind = 0    .
run make-header in this-procedure ( output v-kol-price ).
FORM with frame plan-menu .
    num#str# = 0 .
    for each obj-list:
      Output stream Macr_Excel  close .
      run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
      output stream macr_excel to value(v-file-name) .
      run make-tt in this-procedure (obj-list.obj-type , obj-list.obj-code) .
      v-ind = v-ind + 1.
      find clients      where clients.obj-type = 'орг':U                and
                              clients.obj-code = v-cntxt-host-code-obj no-lock .
      run PrintTitul in this-procedure .
define variable p-sort-pole as character no-undo .
define variable p-sort-pole2 as character no-undo .
define variable p-sort-pole-a as character no-undo .
define variable p-query-prepare as character no-undo .
define variable p-table-name as character no-undo .
p-table-name = "temp-pdf" .
case v-sort :
  when "sort-code":U  then do:
    p-sort-pole-a = "temp-pdf.b-code" .
  end.
  when "sort-artic":U then do:
      p-sort-pole-a = "temp-pdf.artic" .
  end.
  when "sort-name":U then do:
      p-sort-pole-a = "temp-pdf.gds-name" .
  end.
end case.
case v-clas:
    when "no-classify":U then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 " , p-sort-pole-a ).
       p-sort-pole   = "nul" .
       p-sort-pole2  = "nul" .
    end.
    when "prod":U        then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 " , "temp-pdf.prod-typecode" , p-sort-pole-a).
       p-sort-pole   = "prod-typecode" .
       p-sort-pole2  = "nul" .
    end.
    when "grp-goods":U   then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 " , "temp-pdf.grp-code" , p-sort-pole-a).
       p-sort-pole   = "grp-code" .
       p-sort-pole2  = "nul" .
    end.
    when "prod/grp-goods":U then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 by &3 " , "temp-pdf.prod-typecode" , "temp-pdf.grp-code" , p-sort-pole-a) .
       p-sort-pole   = "prod-typecode" .
       p-sort-pole2  = "grp-code" .
    end.
    when "grp-goods/prod":U then do:
       p-query-prepare  = substitute( "for each temp-pdf by &1 by &2 by &3 " , "temp-pdf.grp-code" , "temp-pdf.prod-typecode" , p-sort-pole-a) .
       p-sort-pole   = "grp-code" .
       p-sort-pole2  = "prod-typecode" .
    end.
end case.
     run din-tt-go (
          p-table-name    ,
          P-query-prepare ,
          p-sort-pole ,
          p-sort-pole2
          ).
      run print-all-itog in this-procedure .
      run on-same-page in this-procedure (input 1) .
      run PrintPodval in this-procedure .
      run paramls-write in this-procedure
      (input "file"
      ,input string(v-ind) + obj-list.obj-name
      ,input v-file-name
      ) .
      page stream OutStream .
    end.
HIDE STREAM OutStream FRAME plan-menu.
HIDE stream OutStream FRAME BottomFrame .
HIDE stream OutStream FRAME BottomFrame2 .
output stream OutStream CLOSE .
Output stream Macr_Excel  close .
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3"
        ) .
  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  run end-proc in this-procedure .
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
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
procedure print-line :
do on error undo, return error return-value :
define input  parameter p-recid as recid no-undo .
define buffer buf_temp-pdf for temp-pdf  .
find first buf_temp-pdf where recid(buf_temp-pdf) = p-recid no-error .
define variable  p-code       as character no-undo .
define variable  p-artic      as character no-undo .
define variable  p-name       as character no-undo .
define variable  p-prod-name  as character no-undo .
define variable  p-unit-cli   as character no-undo .
define variable  p-plt-id     as decimal   no-undo .
define variable  p-price-roz  as decimal   no-undo .
p-code      = string(buf_temp-pdf.b-code) .
p-artic     = buf_temp-pdf.artic   .
p-name      = buf_temp-pdf.gds-name .
p-prod-name = buf_temp-pdf.prod-name .
p-unit-cli  = buf_temp-pdf.unit-cli .
p-plt-id    = buf_temp-pdf.plt-id .
p-price-roz = buf_temp-pdf.price-roz .
  assign
     Lines_Counter = Lines_Counter + 1
    .
  if line-counter( OutStream ) + 2 > page-size( OutStream ) then do:
     run p-line in this-procedure.
     page stream OutStream.
     PUT STREAM OutStream UNFORMATTED
         string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 100 format "X(13)" SKIP .
     run print-1 in this-procedure.
     end.
  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .
  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .
  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.
define variable ii as integer   no-undo .
define variable v-price-sale as decimal   no-undo .
    num#col# = 1.
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure(p-code      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(p-artic     , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(p-name      , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(p-prod-name , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(p-unit-cli  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char in this-procedure(p-plt-id    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    if p-price-roz = 0 or p-price-roz = ?
    then do:
      PUT STREAM OutStream UNFORMATTED
          sym1                format "X(1)" space(0)
          p-code              format "X(10)" space(0)
          sym2                format "X(1)" space(0)
          p-artic             format "X(16)" space(0)
          sym3                format "X(1)" space(0)
          p-name              format "X(30)" space(0)
          sym4                format "X(1)" space(0)
          p-prod-name         format "X(30)" space(0)
          sym5                format "X(1)" space(0)
          p-unit-cli          format "X(7)" space(0)
          sym6                format "X(1)" space(0)
          p-plt-id            format ">>>>>>9"   space(0)
          sym7                format "X(1)" space(0)
          v-strline           format "x(17)" space(0)
      .
      run macr_excel_char in this-procedure(v-strline, num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
      assign
        f-price-roz = true
      .
    end.
    else do:
      PUT STREAM OutStream UNFORMATTED
          sym1                format "X(1)" space(0)
          p-code              format "X(10)" space(0)
          sym2                format "X(1)" space(0)
          p-artic             format "X(16)" space(0)
          sym3                format "X(1)" space(0)
          p-name              format "X(30)" space(0)
          sym4                format "X(1)" space(0)
          p-prod-name         format "X(30)" space(0)
          sym5                format "X(1)" space(0)
          p-unit-cli          format "X(7)" space(0)
          sym6                format "X(1)" space(0)
          p-plt-id            format ">>>>>>9"   space(0)
          sym7                format "X(1)" space(0)
          p-price-roz         format ">>>>>>>>>>>>>9.99" space(0)
      .
      run macr_excel_dec in this-procedure(p-price-roz, num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
      assign
        f-price-roz = false
      .
    end.
      repeat ii = 1 to v-kol-price :
        find first  temp-price where
                    temp-price.plt-id     = buf_temp-pdf.plt-id     and
                    temp-price.plt-db-num = buf_temp-pdf.plt-db-num and
                    temp-price.gds-code = int(p-code) and
                    temp-price.id = ii no-error .
                    if available temp-price then  v-price-sale = temp-price.price-sale .
                                            else v-price-sale = 0 .
        put stream outstream unformatted
            sym1                                        format "x(1)"  space(0)
            .
        if v-price-sale = 0 or v-price-sale = ?
        then do:
          put stream outstream unformatted
              v-strline                                   format "x(19)" space(0)
              .
          run macr_excel_char in this-procedure( v-strline , num#str# , num#col# ) .
        end.
        else do:
          put stream outstream unformatted
          v-price-sale         format ">>>>>>>>>>>>>>>9.99" space(0)
              .
          run macr_excel_dec in this-procedure( v-price-sale , num#str# , num#col# ) .
          if f-price-roz then do:
            run macr_cell_format in this-procedure
            ( ?     ,
              ?     ,
              ?     ,
              38    ,
              num#str# ,
              num#col# ,
              ?        ,
              ?        ) .
          end.
        end.
                assign  num#col# = num#col# + 1 .
      end.
    PUT STREAM OutStream UNFORMATTED skip.
end.
end procedure.
procedure print-all-itog :
end procedure.
procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .
  define variable ii as integer   no-undo .
if v-curr-code = ? then
   find first ub.currency no-lock where ub.currency.curr-code = new-curr-code no-error .
else find first ub.currency no-lock where ub.currency.curr-code = v-curr-code no-error .
 if available ub.currency then v-curr-abbr = ub.currency.curr-abbr .
PUT STREAM OutStream UNFORMATTED
space(0)
   v-ReportNAme skip
   "Отчет сформирован: " + cur-time-date() skip
   "На дату:  "  + string (x-date-alone, "99/99/9999") skip
   "Детализация цен:  "  + if entry (1, p-par1) = "bgl" then "По группам покупателей" else "По покупателям" skip
   "Валюта: " + v-curr-abbr skip
      .
  define variable i as integer no-undo .
  Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
    PUT STREAM OutStream UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(90)" SKIP.
  End.
    num#str# = 1.
    num#col# = 1.
    run macr_cell_format in this-procedure
    ( 14    ,
      true  ,
      false ,
      ?     ,
      1     ,
      1     ,
      num#str# ,
      num#col# ) .
    run macr_excel_char in this-procedure( v-Reportname , num#str# , num#col#   ) .
    num#str# = num#str# + 2.
    run macr_cell_format in this-procedure
    ( 10    ,
      false ,
      false ,
      ?     ,
      num#str# ,
      num#col# ,
      ?     ,
      ?     ) .
    run macr_excel_char in this-procedure( "Отчет сформирован: " + cur-time-date() , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_cell_format in this-procedure
    ( 10    ,
      false ,
      false ,
      ?     ,
      num#str# ,
      num#col# ,
      ?     ,
      ?     ) .
    run macr_excel_char in this-procedure("Детализация цен:  "  + if entry (1, p-par1) = "bgl" then "По группам покупателей" else "По покупателям" , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_cell_format in this-procedure
    ( 10    ,
      true  ,
      true  ,
      ?     ,
      num#str# ,
      num#col# ,
      ?     ,
      ?     ) .
    run macr_excel_char in this-procedure("На дату:  "  + string (x-date-alone, "99/99/9999")  , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_cell_format in this-procedure
    ( 10    ,
      false ,
      false ,
      ?     ,
      num#str# ,
      num#col# ,
      ?     ,
      ?     ) .
    run macr_excel_char in this-procedure("Валюта:  " + v-curr-abbr   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char in this-procedure("Код"  , num#str# , num#col#   ) .    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char in this-procedure("Артикул"  , num#str# , num#col#   ) .  run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char in this-procedure("Наименование"  , num#str# , num#col#   ) . run macr_cell_size ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char in this-procedure("Производитель"  , num#str# , num#col#   ) . run macr_cell_size ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char in this-procedure("Ед.изм."  , num#str# , num#col#   ) . run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char in this-procedure("Код ТПЛ"  , num#str# , num#col#   ) . run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7.
    run macr_excel_char in this-procedure("Цена за ед."  , num#str# , num#col#   ) . run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    repeat ii = 1 to num#col# :
      run macr_cell_format in this-procedure
      ( 10    ,
        true  ,
        false ,
        34    ,
        num#str# ,
        ii       ,
        ?        ,
        ?        ) .
    end.
    run print-1 in this-procedure .
    repeat ii = 1 to v-kol-price :
      find first  temp-header where temp-header.id = ii no-error .
      num#col# = num#col# + 1.
      run macr_excel_char in this-procedure( temp-header.name , num#str# , num#col#   ) .
      run macr_cell_format in this-procedure
      ( 10    ,
        true  ,
        false ,
        34    ,
        num#str# ,
        num#col# ,
        ?        ,
        ?        ) .
    end.
    put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  num#col# ) + chr(10)  +
       'BORDER( 2 , 2 , 2 , 2 , 2 , ,0,0,0,0,0) '  + chr(10) +
       'ALIGNMENT(3 , , 4 , 4 ,)'  + chr(10)
       .
    put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' , num#str# , 1 , num#str# ,  3 ) + chr(10)  +
       'BORDER( 2, , , , , , , , , , ) '  + chr(10) .
  end.
end procedure.
procedure PrintPodval :
  do on error undo, return error return-value  :
  define variable pp as integer no-undo .
  define variable rr as integer no-undo .
    run p-line in this-procedure.
  end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    run p-line in this-procedure.
    page stream OutStream .
    end.
end procedure.
procedure print-1 :
define variable ii as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run p-line in this-procedure.
    PUT STREAM OutStream UNFORMATTED  ":Код"  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  ":Артикул"  format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  ":Наименование"  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  ":Производитель"  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  ":Ед.изм."  format "X(8)" .
    PUT STREAM OutStream UNFORMATTED  ":Код ТПЛ:"  format "X(8)" .
    PUT STREAM OutStream UNFORMATTED  ":Цена за ед. руб."  format "X(18)" .
      repeat ii = 1 to v-kol-price :
        find first  temp-header where temp-header.id = ii no-error .
        put stream outstream unformatted   ":" + string(temp-header.name)    format "x(20)" space(0)  .
      end.
    put stream outstream unformatted skip .
    run p-line in this-procedure.
  end.
end procedure.
procedure p-line :
define variable ii as integer   no-undo .
  do
  on error undo, return error return-value
  :
    PUT STREAM OutStream UNFORMATTED  fill("-",11)  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",17)  format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",8)  format "X(8)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",8)  format "X(8)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",18)  format "X(18)" .
      repeat ii = 1 to v-kol-price :
        put stream outstream unformatted   fill("-",21)  format "x(21)" space(0)  .
      end.
    PUT STREAM OutStream UNFORMATTED  skip .
  end.
end procedure.
procedure make-header :
define output parameter ii as integer   no-undo  .
  do
  on error undo, return error return-value
  :
    define variable ix as integer   no-undo  .
    define buffer buf_clients for ub.clients .
    define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group .
    ii = 0 .
    if entry (1, p-par1) = "bgl"
    then do:
      repeat ix = 2 to num-entries (p-par1) :
        for buf_buyer-group no-lock where recid (buf_buyer-group) = int (entry (ix, p-par1) )
                  :
            ii = ii + 1.
            create  temp-header.
            assign
              temp-header.id     = ii
              temp-header.name   = buf_buyer-group.name
              temp-header.bgr-id     = buf_buyer-group.bgr-id
              temp-header.bgr-db-num = buf_buyer-group.bgr-db-num
            .
        end.
      end.
    end.
    else do:
      repeat ix = 2 to num-entries (p-par1) :
        for buf_clients no-lock where recid (buf_clients) = int (entry (ix, p-par1) )
                  :
            find first buf_buyer-in-buyer-group no-lock
              where buf_clients.obj-code = buf_buyer-in-buyer-group.bbg-obj-code
              and buf_clients.obj-type = buf_buyer-in-buyer-group.bbg-obj-type
              and buf_buyer-in-buyer-group.stts <> 1 no-error
            .
            find first buf_buyer-group no-lock
              where buf_buyer-group.bgr-id = buf_buyer-in-buyer-group.bgr-id
              and buf_buyer-group.bgr-db-num = buf_buyer-in-buyer-group.bgr-db-num
              and buf_buyer-group.stts <> 1 no-error
            .
            if available buf_buyer-group
            then do:
              ii = ii + 1.
              create  temp-header.
              assign
                temp-header.id     = ii
                temp-header.name   = buf_clients.obj-name
                temp-header.bgr-id     = buf_buyer-group.bgr-id
                temp-header.bgr-db-num = buf_buyer-group.bgr-db-num
              .
            end.
        end.
      end.
    end.
  end.
end procedure.
procedure make-tt :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_clients  for ub.clients  .
define variable v-i as integer   no-undo .
  do
  on error undo, return error return-value
  :
  define buffer buf_price-all for ub.price-all.
  v-i = 0.
  for each temp-price : delete temp-price. end.
  for each temp-pdf   : delete temp-pdf  . end.
  case x-SelectGood :
    when 1 then do:
      for each temp-header no-lock,
          each buf_price-all no-lock where
              (buf_price-all.obj-type = p-obj-type and
              buf_price-all.obj-code = p-obj-code and
              buf_price-all.bgr-id > 0 and
              (( buf_price-all.fact-order-sys-from = 0 ) or (buf_price-all.fact-order-sys-from <= v-fact-order)) and
              (( buf_price-all.fact-order-sys-to = 0 )   or (buf_price-all.fact-order-sys-to >= v-fact-order)) and
              (( v-curr-code = ?) or (buf_price-all.curr-code = v-curr-code ))) and
              (temp-header.bgr-id        = buf_price-all.bgr-id and
              temp-header.bgr-db-num    = buf_price-all.bgr-db-num)
              by buf_price-all.fact-order desc :
              if buf_price-all.bgr-id <> 0 then do:
                find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
                find first buf_goods    no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error .
                find first buf_clients  no-lock where buf_clients.obj-type = buf_goods.prod-type and
                                                      buf_clients.obj-code = buf_goods.prod-code no-error.
                  v-i = v-i + 1.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 gp-fact-order = v-fact-order .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(buf_goods.gds-name)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(buf_goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
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
                new-curr-code = buf_price-all.curr-code.
                create temp-price .
                assign
                    temp-price.b-code     = buf_price-all.b-code
                    temp-price.gds-code   = buf_bar-code.gds-code
                    temp-price.id         = temp-header.id
                    temp-price.price-sale = buf_price-all.price-sale
                    temp-price.plt-id     = buf_price-all.plt-id
                    temp-price.plt-db-num = buf_price-all.plt-db-num
                .
                find first temp-pdf where
                          temp-pdf.b-code     = buf_price-all.b-code     and
                          temp-pdf.plt-id     = buf_price-all.plt-id     and
                          temp-pdf.plt-db-num = buf_price-all.plt-db-num  no-error .
                if not available temp-pdf then do:
                    create temp-pdf.
                    assign
                        temp-pdf.gds-code   = buf_bar-code.gds-code
                        temp-pdf.prior      = buf_price-all.plt-priority
                        temp-pdf.date1      = buf_price-all.start-date
                        temp-pdf.date2      = buf_price-all.end-date
                        temp-pdf.b-code     = buf_price-all.b-code
                        temp-pdf.plt-id     = buf_price-all.plt-id
                        temp-pdf.plt-db-num = buf_price-all.plt-db-num
                        temp-pdf.gds-name   = buf_goods.gds-name
                        temp-pdf.unit-cli   = buf_goods.unit-cli
                        temp-pdf.price-roz  = gp-price-sale
                        temp-pdf.artic      = buf_goods.artic
                        temp-pdf.prod-typecode  = buf_goods.prod-type + string(buf_goods.prod-code)
                        temp-pdf.prod-name  = buf_clients.obj-name
                        temp-pdf.grp-code   = buf_goods.grp-code
                        temp-pdf.grp-name   = buf_goods.grp-name
                    .
                end.
              end.
      end.
    end.
    when 2 then do:
      for each tmp#grp no-lock ,
          each buf_goods  where
                  buf_goods.grp-code  = tmp#grp.node-code no-lock :
        for each buf_bar-code no-lock where buf_goods.gds-code = buf_bar-code.gds-code :
          for each temp-header no-lock,
              each buf_price-all no-lock where
                  (buf_price-all.obj-type = p-obj-type and
                  buf_price-all.obj-code = p-obj-code and
                  buf_price-all.bgr-id > 0 and
                  (( buf_price-all.fact-order-sys-from = 0 ) or (buf_price-all.fact-order-sys-from <= v-fact-order)) and
                  (( buf_price-all.fact-order-sys-to = 0 )   or (buf_price-all.fact-order-sys-to >= v-fact-order)) and
                  (( v-curr-code = ?) or (buf_price-all.curr-code = v-curr-code ))) and
                  (temp-header.bgr-id        = buf_price-all.bgr-id and
                  temp-header.bgr-db-num    = buf_price-all.bgr-db-num) and
                  buf_bar-code.b-code = buf_price-all.b-code
                  by buf_price-all.fact-order desc :
                  if buf_price-all.bgr-id <> 0 then do:
                    find first buf_clients  no-lock where buf_clients.obj-type = buf_goods.prod-type and
                                                          buf_clients.obj-code = buf_goods.prod-code no-error.
                      v-i = v-i + 1.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 gp-fact-order = v-fact-order .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(buf_goods.gds-name)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(buf_goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
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
                    new-curr-code = buf_price-all.curr-code.
                    create temp-price .
                    assign
                        temp-price.b-code     = buf_price-all.b-code
                        temp-price.gds-code   = buf_bar-code.gds-code
                        temp-price.id         = temp-header.id
                        temp-price.price-sale = buf_price-all.price-sale
                        temp-price.plt-id     = buf_price-all.plt-id
                        temp-price.plt-db-num = buf_price-all.plt-db-num
                    .
                    find first temp-pdf where
                              temp-pdf.b-code     = buf_price-all.b-code     and
                              temp-pdf.plt-id     = buf_price-all.plt-id     and
                              temp-pdf.plt-db-num = buf_price-all.plt-db-num  no-error .
                    if not available temp-pdf then do:
                        create temp-pdf.
                        assign
                            temp-pdf.gds-code   = buf_bar-code.gds-code
                            temp-pdf.prior      = buf_price-all.plt-priority
                            temp-pdf.date1      = buf_price-all.start-date
                            temp-pdf.date2      = buf_price-all.end-date
                            temp-pdf.b-code     = buf_price-all.b-code
                            temp-pdf.plt-id     = buf_price-all.plt-id
                            temp-pdf.plt-db-num = buf_price-all.plt-db-num
                            temp-pdf.gds-name   = buf_goods.gds-name
                            temp-pdf.unit-cli   = buf_goods.unit-cli
                            temp-pdf.price-roz  = gp-price-sale
                            temp-pdf.artic      = buf_goods.artic
                            temp-pdf.prod-typecode  = buf_goods.prod-type + string(buf_goods.prod-code)
                            temp-pdf.prod-name  = buf_clients.obj-name
                            temp-pdf.grp-code   = buf_goods.grp-code
                            temp-pdf.grp-name   = buf_goods.grp-name
                        .
                    end.
                  end.
          end.
        end.
      end.
    end.
    when 3 then do:
      for each g#cli :
        for each temp-header no-lock,
            each buf_price-all no-lock where
                (buf_price-all.obj-type = p-obj-type and
                buf_price-all.obj-code = p-obj-code and
                buf_price-all.bgr-id > 0 and
                (( buf_price-all.fact-order-sys-from = 0 ) or (buf_price-all.fact-order-sys-from <= v-fact-order)) and
                (( buf_price-all.fact-order-sys-to = 0 )   or (buf_price-all.fact-order-sys-to >= v-fact-order)) and
                (( v-curr-code = ?) or (buf_price-all.curr-code = v-curr-code ))) and
                              (temp-header.bgr-id        = buf_price-all.bgr-id and
                              temp-header.bgr-db-num    = buf_price-all.bgr-db-num)
                by buf_price-all.fact-order desc :
                if buf_price-all.bgr-id <> 0 then do:
                  find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
                  find first buf_goods    no-lock
                    where buf_goods.gds-code = buf_bar-code.gds-code and
                          buf_goods.prod-code = g#cli.obj-code  and buf_goods.prod-type = g#cli.obj-type
                    no-error .
                  if not available buf_goods then next.
                  find first buf_clients  no-lock where buf_clients.obj-type = buf_goods.prod-type and
                                                        buf_clients.obj-code = buf_goods.prod-code no-error.
                    v-i = v-i + 1.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 gp-fact-order = v-fact-order .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(buf_goods.gds-name)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(buf_goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
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
                  new-curr-code = buf_price-all.curr-code.
                  create temp-price .
                  assign
                      temp-price.b-code     = buf_price-all.b-code
                      temp-price.gds-code   = buf_bar-code.gds-code
                      temp-price.id         = temp-header.id
                      temp-price.price-sale = buf_price-all.price-sale
                      temp-price.plt-id     = buf_price-all.plt-id
                      temp-price.plt-db-num = buf_price-all.plt-db-num
                  .
                  find first temp-pdf where
                            temp-pdf.b-code     = buf_price-all.b-code     and
                            temp-pdf.plt-id     = buf_price-all.plt-id     and
                            temp-pdf.plt-db-num = buf_price-all.plt-db-num  no-error .
                  if not available temp-pdf then do:
                      create temp-pdf.
                      assign
                          temp-pdf.gds-code   = buf_bar-code.gds-code
                          temp-pdf.prior      = buf_price-all.plt-priority
                          temp-pdf.date1      = buf_price-all.start-date
                          temp-pdf.date2      = buf_price-all.end-date
                          temp-pdf.b-code     = buf_price-all.b-code
                          temp-pdf.plt-id     = buf_price-all.plt-id
                          temp-pdf.plt-db-num = buf_price-all.plt-db-num
                          temp-pdf.gds-name   = buf_goods.gds-name
                          temp-pdf.unit-cli   = buf_goods.unit-cli
                          temp-pdf.price-roz  = gp-price-sale
                          temp-pdf.artic      = buf_goods.artic
                          temp-pdf.prod-typecode  = buf_goods.prod-type + string(buf_goods.prod-code)
                          temp-pdf.prod-name  = buf_clients.obj-name
                          temp-pdf.grp-code   = buf_goods.grp-code
                          temp-pdf.grp-name   = buf_goods.grp-name
                      .
                  end.
                end.
        end.
      end.
    end.
    when 4 then do:
      for each temp-header no-lock,
          each buf_price-all no-lock where
              (buf_price-all.obj-type = p-obj-type and
              buf_price-all.obj-code = p-obj-code and
              buf_price-all.bgr-id > 0 and
              (( buf_price-all.fact-order-sys-from = 0 ) or (buf_price-all.fact-order-sys-from <= v-fact-order)) and
              (( buf_price-all.fact-order-sys-to = 0 )   or (buf_price-all.fact-order-sys-to >= v-fact-order)) and
              (( v-curr-code = ?) or (buf_price-all.curr-code = v-curr-code ))) and
                            (temp-header.bgr-id        = buf_price-all.bgr-id and
                            temp-header.bgr-db-num    = buf_price-all.bgr-db-num)
              by buf_price-all.fact-order desc :
              if buf_price-all.bgr-id <> 0 then do:
                find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
                find first buf_goods    no-lock
                  where buf_goods.gds-code = buf_bar-code.gds-code
                  no-error .
                find first gds-list no-lock where buf_goods.gds-code = gds-list.gds-code no-error .
                if not available gds-list then next.
                find first buf_clients  no-lock where buf_clients.obj-type = buf_goods.prod-type and
                                                      buf_clients.obj-code = buf_goods.prod-code no-error.
                  v-i = v-i + 1.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 gp-fact-order = v-fact-order .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(buf_goods.gds-name)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(buf_goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
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
                new-curr-code = buf_price-all.curr-code.
                create temp-price .
                assign
                    temp-price.b-code     = buf_price-all.b-code
                    temp-price.gds-code   = buf_bar-code.gds-code
                    temp-price.id         = temp-header.id
                    temp-price.price-sale = buf_price-all.price-sale
                    temp-price.plt-id     = buf_price-all.plt-id
                    temp-price.plt-db-num = buf_price-all.plt-db-num
                .
                find first temp-pdf where
                          temp-pdf.b-code     = buf_price-all.b-code     and
                          temp-pdf.plt-id     = buf_price-all.plt-id     and
                          temp-pdf.plt-db-num = buf_price-all.plt-db-num  no-error .
                if not available temp-pdf then do:
                    create temp-pdf.
                    assign
                        temp-pdf.gds-code   = buf_bar-code.gds-code
                        temp-pdf.prior      = buf_price-all.plt-priority
                        temp-pdf.date1      = buf_price-all.start-date
                        temp-pdf.date2      = buf_price-all.end-date
                        temp-pdf.b-code     = buf_price-all.b-code
                        temp-pdf.plt-id     = buf_price-all.plt-id
                        temp-pdf.plt-db-num = buf_price-all.plt-db-num
                        temp-pdf.gds-name   = buf_goods.gds-name
                        temp-pdf.unit-cli   = buf_goods.unit-cli
                        temp-pdf.price-roz  = gp-price-sale
                        temp-pdf.artic      = buf_goods.artic
                        temp-pdf.prod-typecode  = buf_goods.prod-type + string(buf_goods.prod-code)
                        temp-pdf.prod-name  = buf_clients.obj-name
                        temp-pdf.grp-code   = buf_goods.grp-code
                        temp-pdf.grp-name   = buf_goods.grp-name
                    .
                end.
              end.
      end.
    end.
    when 5 then do:
      for each temp-header no-lock,
          each buf_price-all no-lock where
              (buf_price-all.obj-type = p-obj-type and
              buf_price-all.obj-code = p-obj-code and
              buf_price-all.bgr-id > 0 and
              (( buf_price-all.fact-order-sys-from = 0 ) or (buf_price-all.fact-order-sys-from <= v-fact-order)) and
              (( buf_price-all.fact-order-sys-to = 0 )   or (buf_price-all.fact-order-sys-to >= v-fact-order)) and
              (( v-curr-code = ?) or (buf_price-all.curr-code = v-curr-code ))) and
                            (temp-header.bgr-id        = buf_price-all.bgr-id and
                            temp-header.bgr-db-num    = buf_price-all.bgr-db-num)
              by buf_price-all.fact-order desc :
              if buf_price-all.bgr-id <> 0 then do:
                find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
                find first buf_goods    no-lock
                  where buf_goods.gds-code = buf_bar-code.gds-code
                  no-error .
                find first gds-list no-lock where buf_goods.gds-code = gds-list.gds-code no-error .
                if not available gds-list then next.
                find first buf_clients  no-lock where buf_clients.obj-type = buf_goods.prod-type and
                                                      buf_clients.obj-code = buf_goods.prod-code no-error.
                  v-i = v-i + 1.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 gp-fact-order = v-fact-order .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(buf_goods.gds-name)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(buf_goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
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
                new-curr-code = buf_price-all.curr-code.
                create temp-price .
                assign
                    temp-price.b-code     = buf_price-all.b-code
                    temp-price.gds-code   = buf_bar-code.gds-code
                    temp-price.id         = temp-header.id
                    temp-price.price-sale = buf_price-all.price-sale
                    temp-price.plt-id     = buf_price-all.plt-id
                    temp-price.plt-db-num = buf_price-all.plt-db-num
                .
                find first temp-pdf where
                          temp-pdf.b-code     = buf_price-all.b-code     and
                          temp-pdf.plt-id     = buf_price-all.plt-id     and
                          temp-pdf.plt-db-num = buf_price-all.plt-db-num  no-error .
                if not available temp-pdf then do:
                    create temp-pdf.
                    assign
                        temp-pdf.gds-code   = buf_bar-code.gds-code
                        temp-pdf.prior      = buf_price-all.plt-priority
                        temp-pdf.date1      = buf_price-all.start-date
                        temp-pdf.date2      = buf_price-all.end-date
                        temp-pdf.b-code     = buf_price-all.b-code
                        temp-pdf.plt-id     = buf_price-all.plt-id
                        temp-pdf.plt-db-num = buf_price-all.plt-db-num
                        temp-pdf.gds-name   = buf_goods.gds-name
                        temp-pdf.unit-cli   = buf_goods.unit-cli
                        temp-pdf.price-roz  = gp-price-sale
                        temp-pdf.artic      = buf_goods.artic
                        temp-pdf.prod-typecode  = buf_goods.prod-type + string(buf_goods.prod-code)
                        temp-pdf.prod-name  = buf_clients.obj-name
                        temp-pdf.grp-code   = buf_goods.grp-code
                        temp-pdf.grp-name   = buf_goods.grp-name
                    .
                end.
              end.
      end.
    end.
    when 7 then do:
      for each temp-header no-lock,
          each buf_price-all no-lock where
              (buf_price-all.obj-type = p-obj-type and
              buf_price-all.obj-code = p-obj-code and
              buf_price-all.bgr-id > 0 and
              (( buf_price-all.fact-order-sys-from = 0 ) or (buf_price-all.fact-order-sys-from <= v-fact-order)) and
              (( buf_price-all.fact-order-sys-to = 0 )   or (buf_price-all.fact-order-sys-to >= v-fact-order)) and
              (( v-curr-code = ?) or (buf_price-all.curr-code = v-curr-code ))) and
                            (temp-header.bgr-id        = buf_price-all.bgr-id and
                            temp-header.bgr-db-num    = buf_price-all.bgr-db-num)
              by buf_price-all.fact-order desc :
              if buf_price-all.bgr-id <> 0 then do:
                find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
                find first buf_goods    no-lock
                  where buf_goods.gds-code = buf_bar-code.gds-code
                  no-error .
                find first tmp#grp no-lock where buf_goods.grp-code  = tmp#grp.node-code no-error .
                find first g#cli no-lock where buf_goods.prod-code = g#cli.obj-code and buf_goods.prod-type = g#cli.obj-type no-error .
                if not available tmp#grp or not available g#cli then next.
                find first buf_clients  no-lock where buf_clients.obj-type = buf_goods.prod-type and
                                                      buf_clients.obj-code = buf_goods.prod-code no-error.
                  v-i = v-i + 1.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 gp-fact-order = v-fact-order .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  buf_bar-code.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  p-obj-type
  ,input  p-obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
IF ( v-i modulo v-account = 0 )  then DO:
 Assign
    v-kol-spice = (50 - LENGTH(buf_goods.gds-name)) / 2
    RecordsString = fill(' ',v-kol-spice) + string(buf_goods.gds-name)
    .
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              v-i @ RecordsDone
              RecordsString   @ RecordsString
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
                new-curr-code = buf_price-all.curr-code.
                create temp-price .
                assign
                    temp-price.b-code     = buf_price-all.b-code
                    temp-price.gds-code   = buf_bar-code.gds-code
                    temp-price.id         = temp-header.id
                    temp-price.price-sale = buf_price-all.price-sale
                    temp-price.plt-id     = buf_price-all.plt-id
                    temp-price.plt-db-num = buf_price-all.plt-db-num
                .
                find first temp-pdf where
                          temp-pdf.b-code     = buf_price-all.b-code     and
                          temp-pdf.plt-id     = buf_price-all.plt-id     and
                          temp-pdf.plt-db-num = buf_price-all.plt-db-num  no-error .
                if not available temp-pdf then do:
                    create temp-pdf.
                    assign
                        temp-pdf.gds-code   = buf_bar-code.gds-code
                        temp-pdf.prior      = buf_price-all.plt-priority
                        temp-pdf.date1      = buf_price-all.start-date
                        temp-pdf.date2      = buf_price-all.end-date
                        temp-pdf.b-code     = buf_price-all.b-code
                        temp-pdf.plt-id     = buf_price-all.plt-id
                        temp-pdf.plt-db-num = buf_price-all.plt-db-num
                        temp-pdf.gds-name   = buf_goods.gds-name
                        temp-pdf.unit-cli   = buf_goods.unit-cli
                        temp-pdf.price-roz  = gp-price-sale
                        temp-pdf.artic      = buf_goods.artic
                        temp-pdf.prod-typecode  = buf_goods.prod-type + string(buf_goods.prod-code)
                        temp-pdf.prod-name  = buf_clients.obj-name
                        temp-pdf.grp-code   = buf_goods.grp-code
                        temp-pdf.grp-name   = buf_goods.grp-name
                    .
                end.
              end.
      end.
    end.
  end case.
end.
end procedure.
procedure din-tt-go :
define input  parameter p-table-name    as character no-undo .
define input  parameter P-query-prepare as character no-undo .
define input  parameter p-sort-pole  as character no-undo .
define input  parameter p-sort-pole2 as character no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable old-sort-pole as character no-undo .
define variable new-sort-pole as character no-undo .
define variable old-sort-pole2 as character no-undo .
define variable new-sort-pole2 as character no-undo .
  do
  on error undo, return error return-value
  :
    create buffer bh for table p-table-name.
    create query qh.
      qh:set-buffers (bh).
      qh:query-prepare (p-query-prepare).
      qh:query-open ().
      qh:get-first ().
      if bh:available <> true then do:
         qh:query-close() .
         delete object qh.
         delete object bh.
         return.
       end.
       old-sort-pole  = bh:buffer-field ( p-sort-pole  ):buffer-value .
       old-sort-pole2 = bh:buffer-field ( p-sort-pole2 ):buffer-value .
       run print-grp-header  ( bh:recid , old-sort-pole ) .
       run print-grp-header2 ( bh:recid , old-sort-pole2 ) .
      do while qh:query-off-end = false :
          new-sort-pole  = bh:buffer-field ( p-sort-pole ):buffer-value .
          new-sort-pole2 = bh:buffer-field ( p-sort-pole2):buffer-value .
          if old-sort-pole <> new-sort-pole then do:
            run print-grp-header ( bh:recid , new-sort-pole ) .
          end.
              if old-sort-pole2 <> new-sort-pole2 or old-sort-pole <> new-sort-pole
              then do:
                run print-grp-header2 ( bh:recid , new-sort-pole2 ) .
              end.
          run print-line ( bh:recid ) .
          qh:get-next().
          old-sort-pole  = new-sort-pole.
          old-sort-pole2 = new-sort-pole2.
      end.
    qh:query-close() .
    delete object qh.
    delete object bh.
  end.
end procedure.
procedure print-grp-header :
define input  parameter p-recid as recid no-undo .
define input  parameter p-sort-pole as character no-undo .
define buffer buf_temp-pdf for temp-pdf  .
define variable v-name as character no-undo .
define variable v-val as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_temp-pdf where recid(buf_temp-pdf) = p-recid no-error .
    case v-clas:
        when "no-classify":U then do:
            return.
        end.
        when "prod":U        then do:
          v-name = "По производителю " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.prod-name .
          else      v-val = p-sort-pole.
        end.
        when "grp-goods":U   then do:
          if available buf_temp-pdf then v-val = buf_temp-pdf.grp-name .
          else      v-val = p-sort-pole.
        end.
        when "prod/grp-goods":U then do:
          v-name = "По производителю " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.prod-name .
          else      v-val = p-sort-pole.
        end.
        when "grp-goods/prod":U then do:
          v-name = "По группе " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.grp-name .
          else      v-val = p-sort-pole.
        end.
    end case.
    put stream outstream unformatted  ( v-name + v-val ) at 1 skip .
    num#col# = 2 .
    num#str# = num#str# + 1 .
    run macr_cell_format in this-procedure
        ( 10    ,
          true  ,
          false ,
          ?     ,
          num#str# ,
          num#col# ,
          num#str# ,
          num#col# ) .
    run macr_excel_char in this-procedure( v-name + v-val  , num#str# , num#col#   ) .
  end.
end procedure.
procedure print-grp-header2 :
define input  parameter p-recid as recid no-undo .
define input  parameter p-sort-pole as character no-undo .
define buffer buf_temp-pdf for temp-pdf  .
define variable v-name as character no-undo .
define variable v-val as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_temp-pdf where recid(buf_temp-pdf) = p-recid no-error .
    case v-clas:
        when "no-classify":U then do:
            return.
        end.
        when "prod":U        then do:
           return.
        end.
        when "grp-goods":U   then do:
           return.
        end.
        when "prod/grp-goods":U then do:
          v-name = "По группе " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.grp-name .
                                    else v-val = p-sort-pole.
        end.
        when "grp-goods/prod":U then do:
          v-name = "По производителю " .
          if available buf_temp-pdf then v-val = buf_temp-pdf.prod-name .
                                    else v-val = p-sort-pole.
        end.
    end case.
    put stream outstream unformatted  ( v-name + v-val ) at 10 skip .
    num#col# = 2 .
    num#str# = num#str# + 1 .
    run macr_cell_format in this-procedure
        ( 10    ,
          true  ,
          false ,
          ?     ,
          num#str# ,
          num#col# ,
          num#str# ,
          num#col# ) .
    run macr_excel_char in this-procedure ( v-name + v-val  , num#str# , num#col# ) .
  end.
end procedure.
def var vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
