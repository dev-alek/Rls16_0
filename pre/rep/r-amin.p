block-level on error undo, throw.
define input parameter p-all-gds as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-amin.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-amin.p $":U .
define variable vss-description as character no-undo init "Ассортиментный минимум по текущему объекту".
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
define temp-table temp-index_name-value no-undo
field name-key  as character
field value-key as character
index pi name-key
.
define temp-table temp-sub-index_name no-undo
field name-key  as character
field nn as integer
index pi nn
.
procedure def-hash :
  do
  on error undo, return error return-value
  :
  define input  parameter p-full-string as character no-undo .
  define output parameter p-possb-keep-string as logical   no-undo .
  define output parameter p-string            as character no-undo .
  define output parameter p-hash-string       as character no-undo .
    p-full-string = trim( p-full-string ) .
    if length (p-full-string ) > 150 then do:
    assign
      p-possb-keep-string =  false
      p-string            =  substring(p-full-string,1,150)
      p-hash-string       =  encode(p-full-string)
    .
    end.
    else do:
    assign
      p-possb-keep-string =  true
      p-string            =  p-full-string
      p-hash-string       =  encode(p-full-string)
    .
    end.
  end.
end procedure.
procedure find-from-hash :
  do
  on error undo, return error return-value
  :
define input  parameter  p-full-string            as character no-undo .
define input  parameter  p-table-name             as character no-undo .
define input  parameter  p-field-possb-keep-name  as character no-undo .
define input  parameter  p-field-string-name      as character no-undo .
define input  parameter  p-field-hash-string-name as character no-undo .
define input  parameter  p-sub-table-name         as character no-undo .
define output parameter  p-recid                  as recid     no-undo .
define variable v-possb-keep-string as logical   no-undo .
define variable v-string            as character no-undo .
define variable v-hash-string       as character no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
run def-hash in this-procedure (input  p-full-string ,
              output v-possb-keep-string ,
              output v-string            ,
              output v-hash-string
              ).
p-recid = ? .
create buffer bh for table p-table-name.
create query qh.
   v-query-prepare =
    "for each " + p-table-name + " no-lock where "
    + p-field-possb-keep-name   + " = "  + string(v-possb-keep-string) + " and "
    + p-field-string-name       + " = '" + v-string            + "' and "
    + p-field-hash-string-name  + " = '" + v-hash-string       + "'"
    .
if v-possb-keep-string = true then do:
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
end.
else do:
message false "анализ hash" .
  qh:set-buffers(bh).
  qh:query-prepare(v-query-prepare).
  qh:query-open.
  qh:get-first.
  p-recid = bh:recid.
  repeat :
    qh:get-next.
    if bh:available then do:
       qh:get-first.
       run ver-sub-table in this-procedure (
           input  p-full-string ,
           input  p-table-name ,
           input  p-sub-table-name ,
           input  bh:recid  ,
           output p-rez
           ).
       if p-rez = true  then do:
          p-recid = bh:recid .
          leave.
       end.
       else do:
         next.
       end.
    end.
    leave.
  end.
end.
delete widget bh.
delete widget qh.
  end.
end procedure.
procedure ver-sub-table :
  do
  on error undo, return error return-value
  :
define input  parameter p-full-string as character no-undo .
define input  parameter p-name-table as character no-undo .
define input  parameter p-sub-name-table as character no-undo .
define input  parameter p-recid as recid no-undo .
define output parameter p-ok as logical   no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
for each temp-index_name-value : delete temp-index_name-value . end.
for each temp-sub-index_name : delete temp-sub-index_name . end.
    create buffer bh for table p-name-table.
    create query qh.
    v-query-prepare = "for each " + p-name-table + " no-lock where recid(" + p-name-table + ") = " + string ( p-recid ) .
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
define variable v-inf-ind AS CHAR NO-UNDO.
define variable v-name-pi as character no-undo .
define variable v-num-fl-inkey as integer   no-undo .
define variable v-num-fl       as integer   no-undo .
define variable j as integer   no-undo .
v-name-pi = bh:PRIMARY .
v-inf-ind = "1".
i = 0.
DO while ( v-inf-ind <> ? )
    on error undo, return error:
    i = i + 1 .
    v-inf-ind = bh:INDEX-INFORMATION(i) .
    if v-inf-ind = ? then leave.
    if entry( 1 , v-inf-ind ) = v-name-pi then do:
       v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
       v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
      if v-num-fl-inkey >= 1 then do:
          do j = 5 to v-num-fl  by 2 :
              create temp-index_name-value .
              assign
                temp-index_name-value.name-key  = entry( j , v-inf-ind )
                temp-index_name-value.value-key = bh:BUFFER-FIELD(entry( j , v-inf-ind )):BUFFER-VALUE
              .
          end.
       end.
    end.
END.
define variable qh-sub as widget-handle no-undo .
define variable bh-sub as widget-handle no-undo .
    create buffer bh-sub for table p-sub-name-table.
    create query qh-sub.
define variable k as integer   no-undo init 0 .
    v-query-prepare = "for each " + p-sub-name-table + " no-lock where " .
    for each temp-index_name-value :
        v-query-prepare = v-query-prepare  + p-sub-name-table + "." + temp-index_name-value.name-key +
                      " = " + temp-index_name-value.value-key + " and " .
    end.
    v-query-prepare = v-query-prepare + " true = true " .
    qh-sub:set-buffers(bh-sub).
    qh-sub:query-prepare(v-query-prepare).
    qh-sub:query-open.
      v-name-pi = bh-sub:PRIMARY .
      v-inf-ind = "1".
      i = 0.
      DO while ( v-inf-ind <> ? )
          on error undo, return error:
          i = i + 1 .
          v-inf-ind = bh-sub:INDEX-INFORMATION(i) .
          if v-inf-ind = ? then leave.
          if entry( 1 , v-inf-ind ) = v-name-pi then do:
            v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
            v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
            if v-num-fl-inkey >= 1 then do:
                do j = 5 to v-num-fl  by 2 :
                    if not can-find (first temp-index_name-value  where temp-index_name-value.name-key =  entry( j , v-inf-ind )) then do:
                        create temp-sub-index_name .
                        assign
                          temp-sub-index_name.name-key  = entry( j , v-inf-ind )
                          temp-sub-index_name.nn  = j
                        .
                    end.
                end.
            end.
          end.
      END.
      define variable v-qw as character no-undo .
      v-qw = "".
      qh-sub:GET-first.
      DO WHILE (bh-sub:AVAILABLE):
        for each temp-sub-index_name :
            v-qw = v-qw + string(bh-sub:BUFFER-FIELD(temp-sub-index_name.name-key):BUFFER-VALUE) .
        end.
        v-qw = v-qw + ",".
        qh-sub:GET-NEXT.
      END.
      p-ok = false .
      if trim(p-full-string, ",")  =  trim (v-qw, ",") then p-ok = true  .
    delete widget bh-sub.
    delete widget qh-sub.
    delete widget bh.
    delete widget qh.
  end.
end procedure.
PROCEDURE update-rang-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-a as decimal   no-undo .
define input  parameter p-b as decimal   no-undo .
define input  parameter p-c as decimal   no-undo .
define input  parameter p-d as decimal   no-undo .
define input  parameter p-e as decimal   no-undo .
define input  parameter p-f as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-abc-def     for ub.rang-abc-def.
define buffer buf_rang-abc-def-obj for ub.rang-abc-def-obj.
find first buf_rang-abc-def exclusive-lock where recid(buf_rang-abc-def) = p-recid no-error .
if not available buf_rang-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-abc-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-abc-def.raad-id
      p-db = buf_rang-abc-def.db-num
      p-hash-string-obj       = buf_rang-abc-def.raad-hash-string-obj
      p-possb-keep-string-obj = buf_rang-abc-def.raad-possb-keep-string-obj
      p-string-obj            = buf_rang-abc-def.raad-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-abc-def.raad-hash-string-obj       = p-hash-string-obj
          buf_rang-abc-def.raad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-abc-def.raad-string-obj            = p-string-obj
          buf_rang-abc-def.raad-a                     = p-a
          buf_rang-abc-def.raad-b                     = p-b
          buf_rang-abc-def.raad-c                     = p-c
          buf_rang-abc-def.raad-d                     = p-d
          buf_rang-abc-def.raad-e                     = p-e
          buf_rang-abc-def.raad-f                     = p-f
          buf_rang-abc-def.raad-id                    = p-id
          buf_rang-abc-def.raad-date                  = v-date
          buf_rang-abc-def.raad-db-num                = g#db-num
          buf_rang-abc-def.db-num                     = p-db
          buf_rang-abc-def.raad-time                  = v-time
          buf_rang-abc-def.raad-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-abc-def-obj exclusive-lock where
            buf_rang-abc-def-obj.raad-id = buf_rang-abc-def.raad-id and
            buf_rang-abc-def-obj.db-num  = buf_rang-abc-def.db-num :
            delete buf_rang-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-abc-def-obj.
  assign
    buf_rang-abc-def-obj.raad-id  = buf_rang-abc-def.raad-id
    buf_rang-abc-def-obj.db-num   = buf_rang-abc-def.db-num
    buf_rang-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-abc-def .
END PROCEDURE.
PROCEDURE update-rang-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-x as decimal   no-undo .
define input  parameter p-y as decimal   no-undo .
define input  parameter p-z as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-xyz-def     for ub.rang-xyz-def.
define buffer buf_rang-xyz-def-obj for ub.rang-xyz-def-obj.
find first buf_rang-xyz-def exclusive-lock where recid(buf_rang-xyz-def) = p-recid no-error .
if not available buf_rang-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-xyz-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-xyz-def.raxd-id
      p-db = buf_rang-xyz-def.db-num
      p-hash-string-obj       = buf_rang-xyz-def.raxd-hash-string-obj
      p-possb-keep-string-obj = buf_rang-xyz-def.raxd-possb-keep-string-obj
      p-string-obj            = buf_rang-xyz-def.raxd-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-xyz-def.raxd-hash-string-obj       = p-hash-string-obj
          buf_rang-xyz-def.raxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-xyz-def.raxd-string-obj            = p-string-obj
          buf_rang-xyz-def.raxd-x                     = p-x
          buf_rang-xyz-def.raxd-y                     = p-y
          buf_rang-xyz-def.raxd-z                     = p-z
          buf_rang-xyz-def.raxd-id                    = p-id
          buf_rang-xyz-def.raxd-date                  = v-date
          buf_rang-xyz-def.raxd-db-num                = g#db-num
          buf_rang-xyz-def.db-num                     = p-db
          buf_rang-xyz-def.raxd-time                  = v-time
          buf_rang-xyz-def.raxd-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-xyz-def-obj exclusive-lock where
            buf_rang-xyz-def-obj.raxd-id = buf_rang-xyz-def.raxd-id and
            buf_rang-xyz-def-obj.db-num  = buf_rang-xyz-def.db-num :
            delete buf_rang-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-xyz-def-obj.
  assign
    buf_rang-xyz-def-obj.raxd-id  = buf_rang-xyz-def.raxd-id
    buf_rang-xyz-def-obj.db-num   = buf_rang-xyz-def.db-num
    buf_rang-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-xyz-def     for ub.doc-xyz-def.
define buffer buf_doc-xyz-def-obj for ub.doc-xyz-def-obj.
define buffer buf_doc-xyz-def-doc for ub.doc-xyz-def-doc.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash in this-procedure  (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-xyz-def exclusive-lock where recid(buf_doc-xyz-def) = p-recid no-error .
if not available buf_doc-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-xyz-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-xyz-def.doxd-id
      p-db = buf_doc-xyz-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-xyz-def.doxd-hash-string-obj       = p-hash-string-obj
          buf_doc-xyz-def.doxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-xyz-def.doxd-string-obj            = p-string-obj
          buf_doc-xyz-def.doxd-hash-string-doc       = p-hash-string-doc
          buf_doc-xyz-def.doxd-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-xyz-def.doxd-string-doc            = p-string-doc
          buf_doc-xyz-def.doxd-id                    = p-id
          buf_doc-xyz-def.doxd-date                  = v-date
          buf_doc-xyz-def.doxd-db-num                = g#db-num
          buf_doc-xyz-def.doxd-time                  = v-time
          buf_doc-xyz-def.doxd-who                   = g#userid
          buf_doc-xyz-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-xyz-def-doc exclusive-lock where
            buf_doc-xyz-def-doc.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-doc.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-doc.
   end.
   for each buf_doc-xyz-def-obj exclusive-lock where
            buf_doc-xyz-def-obj.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-obj.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-obj.
  assign
    buf_doc-xyz-def-obj.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-obj.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-doc.
  assign
    buf_doc-xyz-def-doc.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-doc.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-doc.dxdd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-abc-def     for ub.doc-abc-def.
define buffer buf_doc-abc-def-obj for ub.doc-abc-def-obj.
define buffer buf_doc-abc-def-doc for ub.doc-abc-def-doc.
    run def-hash  in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash  in this-procedure (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-abc-def exclusive-lock where recid(buf_doc-abc-def) = p-recid no-error .
if not available buf_doc-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-abc-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-abc-def.doad-id
      p-db = buf_doc-abc-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-abc-def.doad-hash-string-obj       = p-hash-string-obj
          buf_doc-abc-def.doad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-abc-def.doad-string-obj            = p-string-obj
          buf_doc-abc-def.doad-hash-string-doc       = p-hash-string-doc
          buf_doc-abc-def.doad-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-abc-def.doad-string-doc            = p-string-doc
          buf_doc-abc-def.doad-id                    = p-id
          buf_doc-abc-def.doad-date                  = v-date
          buf_doc-abc-def.doad-db-num                = g#db-num
          buf_doc-abc-def.doad-time                  = v-time
          buf_doc-abc-def.doad-who                   = g#userid
          buf_doc-abc-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-abc-def-doc exclusive-lock where
            buf_doc-abc-def-doc.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-doc.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-doc.
   end.
   for each buf_doc-abc-def-obj exclusive-lock where
            buf_doc-abc-def-obj.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-obj.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-obj.
  assign
    buf_doc-abc-def-obj.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-obj.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-doc.
  assign
    buf_doc-abc-def-doc.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-doc.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-doc.dadd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-abc-def .
END PROCEDURE.
PROCEDURE find-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-abc-id   as integer   no-undo .
define output parameter p-db-num   as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      find first buf_abc-analysis-obj no-lock where
                buf_abc-analysis-obj.obj-type = p-obj-type and
                buf_abc-analysis-obj.obj-code = p-obj-code and
                buf_abc-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_abc-analysis-obj then do:
                    p-abc-id = buf_abc-analysis-obj.abc-id .
                    p-db-num = buf_abc-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0.
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      find first buf_xyz-analysis-obj no-lock where
                buf_xyz-analysis-obj.obj-type = p-obj-type and
                buf_xyz-analysis-obj.obj-code = p-obj-code and
                buf_xyz-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_xyz-analysis-obj then do:
                    p-abc-id = buf_xyz-analysis-obj.xyz-id .
                    p-db-num = buf_xyz-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0 .
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  return .
end.
END PROCEDURE.
procedure save-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-db-num   as integer   no-undo .
define input  parameter p-abc-id   as integer   no-undo .
define output parameter v-log      as logical   no-undo .
  do
  on error undo, return error return-value
  :
  v-log = true .
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-obj          for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      for each buf_abc-obj no-lock where
               buf_abc-obj.abc-id = p-abc-id and
               buf_abc-obj.db-num = p-db-num :
            define variable v-exist    as logical   no-undo init false .
            define variable v-list-anal as character no-undo init ""    .
            for each  buf_abc-analysis-obj no-lock where
                      not (buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num) and
                      buf_abc-analysis-obj.is-def   = true   and
                      buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                      buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_abc-analysis-obj.abc-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_abc-obj.obj-type
                buf_abc-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_abc-analysis-obj exclusive-lock where
                              buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                              buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code :
                      if ( buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num ) then
                              buf_abc-analysis-obj.is-def   = true .
                      else buf_abc-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_abc-analysis-obj exclusive-lock where
                        buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                        buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code and
                        buf_abc-analysis-obj.abc-id = p-abc-id and
                        buf_abc-analysis-obj.db-num = p-db-num
                        :
                  buf_abc-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-obj          for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      for each buf_xyz-obj no-lock where
               buf_xyz-obj.xyz-id = p-abc-id and
               buf_xyz-obj.db-num = p-db-num :
            v-exist = false .
            v-list-anal = ""    .
            for each  buf_xyz-analysis-obj no-lock where
                      not (buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num) and
                      buf_xyz-analysis-obj.is-def   = true   and
                      buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                      buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_xyz-analysis-obj.xyz-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_xyz-obj.obj-type
                buf_xyz-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_xyz-analysis-obj exclusive-lock where
                              buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                              buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code :
                      if ( buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num ) then
                              buf_xyz-analysis-obj.is-def   = true .
                      else buf_xyz-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_xyz-analysis-obj exclusive-lock where
                        buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                        buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code and
                        buf_xyz-analysis-obj.xyz-id = p-abc-id and
                        buf_xyz-analysis-obj.db-num = p-db-num
                        :
                  buf_xyz-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
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
define variable  parParentProc  AS WIDGET-HANDLE NO-UNDO.
define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
parParentProc = my-HANDLE  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
define variable parhost-code as integer   no-undo .
parhost-code = g#host-code.
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
define buffer This_Object for  ub.clients .
define variable num-ln as integer   no-undo .
define variable i as int no-undo.
define variable j as int no-undo.
define variable Counter1 as integer init 0  no-undo .
define variable LineBuf    as char    no-undo.
define variable Line       as char    no-undo.
define variable UndLine    as char    no-undo.
define variable Lines_Counter as   int  init 0  no-undo.
define variable Tmp_Counter   as   int  init 0  no-undo.
define variable vv0 as character no-undo .
define variable vv1 as character no-undo .
define variable vv2 as character no-undo .
define variable vv3 as character no-undo .
define variable vv4 as character no-undo .
define variable vv5 as character no-undo .
define variable vv6 as character no-undo .
define variable vv7 as character no-undo .
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
define variable t-1 as character no-undo .
define variable t-2 as character no-undo .
define variable t-3 as character no-undo .
define variable t-4 as character no-undo .
define variable t-5 as character no-undo .
DEFINE FRAME plan-menu
    HEADER
    string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 80 format "X(13)" SKIP
    UndLine format "X(80)" AT 1
    with width 235 down stream-io use-text NO-UNDERLINE  NO-BOX no-labels.
  if session:set-wait-state("compiler") then.
 ReportPageHeight = 43.
 ReportPageWidth = 198.
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-is-base
  )  .
if v-is-base = true then do:
end.
else do:
end.
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
v-ind = 0    .
FORM with frame plan-menu .
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .
define buffer buf_gds-obj      for ub.gds-obj .
define buffer buf_goods for ub.goods  .
define buffer buf_xyz-analysis-goods for ub.xyz-analysis-goods  .
define buffer buf_abc-analysis-goods for ub.abc-analysis-goods  .
define buffer buf_abc-analysis-gds-obj for ub.abc-analysis-gds-obj  .
define variable v-abc-id as integer   no-undo .
define variable v-xyz-id as integer   no-undo .
define variable v-db-num as integer   no-undo .
define variable v-db-num-xyz as integer   no-undo .
define variable v-abc as character no-undo .
define variable v-xyz as character no-undo .
define variable v-temp as decimal   no-undo .
define variable v-qnty  as decimal   no-undo .
define variable v-price as decimal   no-undo .
define variable v-ord-qnty as decimal   no-undo .
define variable v-min-qnty as decimal no-undo.
find buf_clients      where buf_clients.obj-type     = 'орг':U                and buf_clients.obj-code      = g#host-code no-lock .
find obj_clients      where obj_clients.obj-type     = store-type            and obj_clients.obj-code      = store-code no-lock .
run find-def-analysis-obj (
   input  "abc"
 , input  store-type
 , input  store-code
 , output v-abc-id
 , output v-db-num   ).
run find-def-analysis-obj (
   input  "xyz"
 , input  store-type
 , input  store-code
 , output v-xyz-id
 , output v-db-num-xyz   ).
  run PrintTitul in this-procedure .
  for each buf_gds-obj-prop no-lock where
           buf_gds-obj-prop.obj-type = store-type and
           buf_gds-obj-prop.obj-code = store-code and
           buf_gds-obj-prop.gdop-assort-min = true
           :
    find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj-prop.gds-code no-error .
    case x-SelectGood :
        when 1  then do:
                            end.
        when 3 then do:
                             find first  G#cli no-lock
                             where G#cli.obj-type = buf_goods.prod-type
                               and G#cli.obj-code = buf_goods.prod-code no-error.
                             if not available  G#cli then next.
                            end .
        when 2  then do:
                             find first tmp#grp no-lock
                             where tmp#grp.node-code = buf_goods.grp-code no-error.
                             if not available tmp#grp then next.
                            end.
        otherwise do:
                    find first gds-list no-lock
                    where buf_goods.artic     = gds-list.artic
                      and buf_goods.prod-type = gds-list.prod-type
                      and buf_goods.prod-code = gds-list.prod-code  no-error.
                      if not available  gds-list then next.
                  end.
    end case.
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = buf_gds-obj-prop.gds-code and
               buf_gds-obj.obj-code = buf_gds-obj-prop.obj-code and
               buf_gds-obj.obj-type = buf_gds-obj-prop.obj-type no-error .
               if available buf_gds-obj then do:
                 v-qnty  = buf_gds-obj.fact-qnty.
                 v-price = buf_gds-obj.price-sale.
                 v-min-qnty = buf_gds-obj-prop.gdop-min-stock.
               end.
               else do:
                 v-qnty  = 0.
                 v-price = 0.
                 v-min-qnty = 0.
               end.
    find first buf_abc-analysis-goods no-lock where
               buf_abc-analysis-goods.abc-id = v-abc-id and
               buf_abc-analysis-goods.db-num = v-db-num and
               buf_abc-analysis-goods.gds-code = buf_gds-obj-prop.gds-code no-error .
               if available buf_abc-analysis-goods
                  then do:
                     assign v-abc = buf_abc-analysis-goods.abcg-abc .
                      find first buf_abc-analysis-gds-obj no-lock where
                                buf_abc-analysis-gds-obj.obj-type = buf_gds-obj-prop.obj-type and
                                buf_abc-analysis-gds-obj.obj-code = buf_gds-obj-prop.obj-code and
                                buf_abc-analysis-gds-obj.abc-id = v-abc-id and
                                buf_abc-analysis-gds-obj.db-num = v-db-num and
                                buf_abc-analysis-gds-obj.gds-code = buf_gds-obj-prop.gds-code no-error .
                                if available buf_abc-analysis-gds-obj then v-temp = buf_abc-analysis-gds-obj.abog-temp-sale-goods .
                                                                      else v-temp = 0.
                  end.
                  else do:
                    assign
                      v-abc = ""
                      v-temp = 0
                    .
                  end.
    find first buf_xyz-analysis-goods no-lock where
               buf_xyz-analysis-goods.xyz-id = v-xyz-id and
               buf_xyz-analysis-goods.db-num = v-db-num-xyz and
               buf_xyz-analysis-goods.gds-code = buf_gds-obj-prop.gds-code no-error .
               if available buf_xyz-analysis-goods
                  then v-xyz = buf_xyz-analysis-goods.xyzg-xyz .
                  else v-xyz = "" .
      run def-order (
       input   buf_gds-obj-prop.obj-type
      ,input   buf_gds-obj-prop.obj-code
      ,input   buf_goods.artic
      ,input   buf_goods.prod-type
      ,input   buf_goods.prod-code
      ,output  v-ord-qnty  ).
    if p-all-gds = false then do :
      if v-qnty < v-min-qnty then do :
        run print-line in this-procedure .
      end.
    end.
    else do :
     run print-line in this-procedure .
    end.
  end.
  run print-all-itog in this-procedure .
  run on-same-page in this-procedure (input 3) .
  run PrintPodval in this-procedure .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .
     page stream OutStream .
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
        ,input "2,3,4"
        ) .
  run end-proc in this-procedure .
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
    ,input ReportFontNum
    ,output v-user-action
    ,output v-printed
    ) .
procedure print-line :
  do on error undo, return error return-value :
  assign
     Lines_Counter = Lines_Counter + 1
    .
  if line-counter( OutStream ) + 2 > page-size( OutStream ) then do:
     page stream OutStream.
     PUT STREAM OutStream UNFORMATTED
         string( "Лист " + string( PAGE-NUMBER(OutStream) , ">>>>9") ) AT 100 format "X(13)" SKIP .
     run print-1 in this-procedure .
     end.
  if line-counter( OutStream ) < Tmp_Counter then
    assign
    .
  assign
    Tmp_Counter  = line-counter( OutStream )
    num-ln = num-ln + 1
  .
  if line-counter( OutStream ) + j > page-size( OutStream ) then  PAGE STREAM OutStream.
PUT STREAM OutStream UNFORMATTED
    sym1                format "X(1)" space(0)
    string(buf_goods.gds-code)    format "X(10)" space(0)
    sym2                format "X(1)" space(0)
    string(buf_goods.artic)    format "X(16)" space(0)
    sym3                format "X(1)" space(0)
    string(buf_goods.gds-name)    format "X(30)" space(0)
    sym4                format "X(1)" space(0)
    string(buf_goods.unit-base)    format "X(3)" space(0)
    sym5                format "X(1)" space(0)
    string(v-price)               format "X(14)" space(0)
    sym6                format "X(1)" space(0)
    string(v-qnty)                format "X(14)" space(0)
    sym7                format "X(1)" space(0)
    string(v-min-qnty)            format "X(14)" space(0)
    sym8                format "X(1)" space(0)
    string(v-ord-qnty)            format "X(14)" space(0)
    sym9                format "X(1)" space(0)
    string(v-temp)                format "X(11)" space(0)
    sym10                format "X(1)" space(0)
    buf_gds-obj-prop.gdop-igt     format "X(19)" space(0)
    sym11               format "X(1)" space(0)
    v-ABC                         format "X(3)" space(0)
    sym12               format "X(1)" space(0)
    v-XYZ                         format "X(3)" space(0)
    sym13               format "X(1)" space(0)
      skip
  .
    num#col# = 1.
    num#str# = num#str# + 1.
    run macr_excel_char (buf_goods.gds-code  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_goods.artic  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_goods.gds-name  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_goods.unit-base  , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-price               , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-qnty                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-min-qnty            , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-ord-qnty            , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_dec (v-temp                , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (buf_gds-obj-prop.gdop-igt, num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (v-ABC                    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
    run macr_excel_char (v-XYZ                    , num#str# , num#col#   ) . assign    num#col# = num#col# + 1 .
  end.
end procedure.
procedure print-all-itog :
   run prn-line in this-procedure .
end procedure.
procedure PrintTitul :
  do  on error undo, return error return-value  :
  define variable cc as integer no-undo .
  define variable tt as integer no-undo .
  define variable pp as integer no-undo .
PUT STREAM OutStream UNFORMATTED
space(1)
   ReportNAme skip
   "на объекте "  obj_clients.obj-name skip
   "по фирме "  buf_clients.obj-name skip
   "Дата составления " + cur-time-date()  skip
      .
  define variable i as integer no-undo .
  Repeat i = 1 to NUM-ENTRIES(ReportHeader,chr(10)) :
    PUT STREAM OutStream UNFORMATTED  Entry(i,ReportHeader,chr(10))  AT 1 format "X(90)" SKIP.
  End.
    num#str# = 1.
    num#col# = 1.
    run macr_excel_char ( Reportname , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "на объекте " + CAPS( obj_clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( "по фирме "   + CAPS( buf_clients.obj-name)   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ( ReportHeader , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ("Дата составления " + cur-time-date()   , num#str# , num#col#   ) .
    num#str# = num#str# + 1.
    run macr_excel_char ("Код"  , num#str# , num#col#   ) .    run macr_cell_size ( 10 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 2.
    run macr_excel_char ("Артикул"  , num#str# , num#col#   ) .    run macr_cell_size ( 16 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 3.
    run macr_excel_char ("Наименование"  , num#str# , num#col#   ) .  run macr_cell_size ( 30 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 4.
    run macr_excel_char ("Ед.Изм"  , num#str# , num#col#   ) . run macr_cell_size ( 7 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 5.
    run macr_excel_char ("Цена товара на объекте"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 6.
    run macr_excel_char ("Остаток товара на объекте"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 7.
    run macr_excel_char ("Минимальный остаток"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 8.
    run macr_excel_char ("Ожидается"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 9.
    run macr_excel_char ("Темп (ABC)"  , num#str# , num#col#   ) . run macr_cell_size ( 15 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 10.
    run macr_excel_char ("ИЖТ"  , num#str# , num#col#   ) . run macr_cell_size ( 24 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 11.
    run macr_excel_char ("ABC"  , num#str# , num#col#   ) . run macr_cell_size ( 4 , ? , num#str# , num#col# , ?, ? ) .
    num#col# = 12.
    run macr_excel_char ("XYZ"  , num#str# , num#col#   ) . run macr_cell_size ( 4 , ? , num#str# , num#col# , ?, ? ) .
  run print-1 in this-procedure .
    run macr_cell_format in this-procedure
    ( 10    ,
      true  ,
      false  ,
      ?    ,
      1 ,
      1 ,
      num#str# ,
      num#col# ) .
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
  end.
end procedure.
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then return .
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then  page stream OutStream .
end procedure.
procedure print-1 :
  do
  on error undo, return error return-value
  :
    run prn-line in this-procedure .
    PUT STREAM OutStream UNFORMATTED  ":Код"  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  ":Артикул"       format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  ":Наименование"  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  ":Е.И"           format "X(4)" .
    PUT STREAM OutStream UNFORMATTED ":Цена товара"    format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Остаток"        format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Мин.остаток"    format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Ожидается"      format "X(15)" .
    PUT STREAM OutStream UNFORMATTED ":Темп (ABC)"    format "X(12)" .
    PUT STREAM OutStream UNFORMATTED ":ИЖТ"            format "X(20)" .
    PUT STREAM OutStream UNFORMATTED ":ABC"            format "X(4)" .
    PUT STREAM OutStream UNFORMATTED ":XYZ:"           format "X(5)" .
    PUT STREAM OutStream UNFORMATTED  skip .
    run prn-line in this-procedure .
  end.
end procedure.
procedure prn-line :
  do
  on error undo, return error return-value
  :
    PUT STREAM OutStream UNFORMATTED  fill("-",11)  AT 1 format "X(11)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",17)  format "X(17)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",31)  format "X(31)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",4)   format "X(4)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",15)  format "X(15)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",12)  format "X(12)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",20)  format "X(20)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",4)  format "X(4)" .
    PUT STREAM OutStream UNFORMATTED  fill("-",5)   format "X(5)" .
    PUT STREAM OutStream UNFORMATTED  skip .
  end.
end procedure.
procedure def-order :
define input  parameter p-obj-type  as character no-undo .
define input  parameter p-obj-code  as integer   no-undo .
define input  parameter p-artic     as char   no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define output parameter v-qnty       as decimal   no-undo .
  do
  on error undo, return error return-value
  :
define buffer buf-ord-line for ub.ord-line.
define buffer buf-ord-doc  for ub.ord-doc.
      for each buf-ord-line no-lock where
              buf-ord-line.artic              =   p-artic     and
              buf-ord-line.prod-type          =   p-prod-type and
              buf-ord-line.prod-code          =   p-prod-code and
              buf-ord-line.obj-type          =   p-obj-type and
              buf-ord-line.obj-code          =   p-obj-code
              ,
          first buf-ord-doc no-lock where
                buf-ord-doc.doc-code          =   buf-ord-line.doc-code and
                buf-ord-doc.status_           <>   'факт':U    and
                buf-ord-doc.status_           <>   'новый':U
                :
                  v-qnty =  v-qnty + buf-ord-line.qnty .
      end.
  end.
end procedure.
def var vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
