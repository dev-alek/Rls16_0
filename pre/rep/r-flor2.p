block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-flor2.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-flor2.p $":U .
define variable vss-description as character no-undo initial "Форма документов заказ для флористов форма № 2":U .
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
    def var t-addres        like ub.firm.addres1   no-undo.
    def var t-phone         like ub.firm.phone     no-undo.
    def var t-inn           like ub.firm.inn       no-undo.
    def var t-okpo          like ub.firm.okpo      no-undo.
    def var t-temp-address  like ub.firm.addres1   no-undo.
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
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure lineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value =  buf_doc-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure lineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.doc-line-attr.attr-value no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code = p-gds-code
        buf_doc-line-attr.attr-code = p-code
      .
    end.
    assign
      buf_doc-line-attr.attr-value = p-value
    .
     release buf_doc-line-attr.
  end.
end procedure.
procedure lineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error .
    if  available buf_doc-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure lineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-fillin_width   as integer   no-undo .
    def var v-fillin_height  as integer   no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run lineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'parts_price-sale':U then do:     assign     p-label          = "Продажная цена партии"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Продажная цена партии"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'fl_gds-code':U then do:     assign     p-label          = "Количество по букету"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Количество по букету"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'old_other-ras':U then do:     assign     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Первым способом из ПН Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'new_other-ras':U then do:     assign     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = " Способом из ДопРасх Сумма дополнительных расходов по строке rubl base"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'flora_ps':U then do:     assign     p-label          = "Описание не товарной позиции"     p-type           = 'C':U      p-format         = "x(70)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Описание не товарной позиции"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'country-code':U then do:     assign     p-label          = "Страна"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Страна"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'add-line-cli':U then do:     assign     p-label          = "Курс . шкала . сумма . НДС "     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 12     p-fillin_height  = 1     p-label          = "Курс . шкала . сумма . НДС "     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'corr-price-sale':U then do:     assign     p-label          = "Продажная цена в строке ПН"     p-type           = 'C':U      p-format         = "x(100)"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Продажная цена в строке ПН"     p-user-can-edit  = false     p-output-display = false     p-other          = '':u      .   end.
            when 'reason-code':U then do:     assign     p-label          = "Причина отклонения"     p-type           = 'I':U      p-format         = "->>>>>>>>9"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Причина отклонения"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prod':U then do:     assign     p-label          = "Цена производителя Без НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя Без НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
            when 'price-prodvat':U then do:     assign     p-label          = "Цена производителя c НДС"     p-type           = 'D':U      p-format         = ">>>>>>>>9.99"     p-fillin_width   = 10     p-fillin_height  = 1     p-label          = "Цена производителя c НДС"     p-user-can-edit  = true     p-output-display = true     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки документа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure lineattr-value-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value    as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(44)  + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
procedure lineattr-delete-flora-gds :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input parameter p-bk-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error NO-WAIT.
    if not available buf_doc-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_doc-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure lineattr-delete-flora-all :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    for each buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code begins 'fl_gds-code':U + chr(44) + string(p-prt-code)  + chr(44)
     :
      delete buf_doc-line-attr.
    end.
 end.
end procedure.
procedure lineattr-exist-flora-gds :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-prt-code    as integer   no-undo .
    define input  parameter p-bk-gds-code like  ub.doc-line-attr.gds-code   no-undo .
    define output parameter p-exist as logical   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    p-exist = false .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'fl_gds-code':U  + chr(44) + string(p-prt-code)  + chr(44) + string(p-bk-gds-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
       p-exist = true
      .
    end.
  end.
end procedure.
procedure lineattr-write-add-line-cli :
define input  parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input  parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input  parameter p-cli-type      as character no-undo .
define input  parameter p-cli-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-exch-code     as integer   no-undo .
define input  parameter p-exch-rate     as decimal   no-undo .
define input  parameter p-exch-scale    as integer   no-undo .
define input  parameter p-sum-cli       as decimal   no-undo .
define input  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = 'add-line-cli':U  +
                                      chr(4) + p-cli-type +
                                      chr(4) + string(p-cli-code) +
                                      chr(4) + string(p-contract-code) +
                                      chr(4) + string(p-host-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value =
      string(p-exch-code)  + chr(4) +
      string(p-exch-rate)  + chr(4) +
      string(p-exch-scale) + chr(4) +
      string(p-sum-cli)    + chr(4) +
      string(p-sum-vat)
      .
  end.
end procedure.
procedure lineattr-value-add-line-cli :
define input   parameter p-doc-code      like  ub.doc-line-attr.doc-code   no-undo .
define input   parameter p-gds-code      like  ub.doc-line-attr.gds-code   no-undo .
define input   parameter p-cli-type      as character no-undo .
define input   parameter p-cli-code      as integer   no-undo .
define input   parameter p-contract-code as integer   no-undo .
define input   parameter p-host-code     as integer   no-undo .
define output  parameter p-exch-code     as integer   no-undo .
define output  parameter p-exch-rate     as decimal   no-undo .
define output  parameter p-exch-scale    as integer   no-undo .
define output  parameter p-sum-cli       as decimal   no-undo .
define output  parameter p-sum-vat       as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
  do
  on error undo, return error return-value
  :
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = 'add-line-cli':U +
                                          chr(4) + p-cli-type +
                                          chr(4) + string(p-cli-code) +
                                          chr(4) + string(p-contract-code) +
                                          chr(4) + string(p-host-code)
      no-error .
    if available buf_doc-line-attr then do:
     assign
        p-exch-code  = integer ( entry (1 , buf_doc-line-attr.attr-value,  chr(4) ))
        p-exch-rate  = decimal ( entry (2 , buf_doc-line-attr.attr-value, chr(4) ))
        p-exch-scale = integer ( entry (3 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-cli    = decimal ( entry (4 , buf_doc-line-attr.attr-value, chr(4) ))
        p-sum-vat    = decimal ( entry (5 , buf_doc-line-attr.attr-value, chr(4) ))
       .
     end.
  end.
end procedure.
function lineattr-get-reason returns character ( buffer local-doc-line for ub.doc-line ) :
  define variable v-code as character no-undo .
  define variable v-type as character no-undo .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  local-doc-line.artic
  ,input  local-doc-line.prod-type
  ,input  local-doc-line.prod-code
  ,output v-gds-code
  )  .
  run lineattr-value (
      input   local-doc-line.doc-code ,
      input   v-gds-code              ,
      input   'reason-code':U ,
      output  v-code                  ,
      output  v-type ) .
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = integer ( v-code ) no-error.
  if not available ub.trn-reason then do:
     return "" .
  end.
  else do:
     return ub.trn-reason.reason-name .
  end.
end function.
procedure lineattr-value-parts :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code    like  ub.doc-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code    like  ub.doc-line-attr.gds-code   no-undo .
    define input  parameter p-part-code   as character no-undo .
    define input  parameter p_in-code     as character no-undo .
    define input  parameter p-code        like  ub.doc-line-attr.attr-code  no-undo .
    define output parameter p-value       as    decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr no-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code  + chr(4) + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if avail buf_doc-line-attr then do:
      assign
        p-value = decimal( buf_doc-line-attr.attr-value)
      .
    end.
    else do:
      assign
        p-value = 0
      .
    end.
  end.
end procedure.
procedure lineattr-write-parts :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.doc-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.doc-line-attr.gds-code   no-undo .
    define input parameter p-part-code  as character no-undo .
    define input parameter p_in-code    as character no-undo .
    define input parameter p-code       like ub.doc-line-attr.attr-code  no-undo .
    define input parameter p-value      as decimal   no-undo .
    define buffer buf_doc-line-attr for ub.doc-line-attr .
    find first buf_doc-line-attr exclusive-lock
      where buf_doc-line-attr.doc-code  = p-doc-code
        and buf_doc-line-attr.gds-code  = p-gds-code
        and buf_doc-line-attr.attr-code = p-code + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      no-error .
    if not available buf_doc-line-attr then do:
      create buf_doc-line-attr .
      assign
        buf_doc-line-attr.doc-code  = p-doc-code
        buf_doc-line-attr.gds-code  = p-gds-code
        buf_doc-line-attr.attr-code = p-code  + chr(4)  + trim(p-part-code)  + chr(4) + trim(p_in-code)
      .
    end.
    assign
      buf_doc-line-attr.attr-value = string( p-value )
    .
  end.
end procedure.
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.
define stream OutStream.
define stream  macr_excel .
define variable    NAme1   as character no-undo .
define variable    Adres1 as character no-undo .
define variable    NAme2   as character no-undo .
define variable    Adres2  as character no-undo .
define variable    Adres3  as character no-undo .
define variable v-time      as character no-undo .
define     variable     PrintScale      as   logical     no-undo.
define     variable     CostPrice      as   logical     no-undo.
define buffer This_Object for  ub.clients .
define buffer gds-prt-1 for  ub.gds-prt .
define buffer bar-code-1 for ub.bar-code .
define variable LineBuf       as character    no-undo.
define variable Line       as character    no-undo.
define variable UndLine    as character    no-undo.
define variable     Lines_Counter as   integer  initial 0  no-undo.
define variable     Tmp_Counter   as   integer  initial 0  no-undo.
define variable     tdoc-date     like ub.trn-doc.doc-date no-undo.
define variable     tdoc-code     like ub.trn-doc.doc-code no-undo.
define variable  Control_sUM       as  decimal no-undo.
define variable  Control_Qnty      as  decimal no-undo.
define variable  PgQnty            as  decimal no-undo.
define variable  PgSum             as  decimal no-undo.
define variable  PgQnty-b          as  decimal no-undo.
define variable  PgSum-b           as  decimal no-undo.
define variable  SQnty             as  decimal no-undo.
define variable  SSum              as  decimal no-undo.
define variable  SQnty-b           as  decimal no-undo.
define variable  SSum-b            as  decimal no-undo.
define variable  PropisQnty        as  character no-undo.
define variable  PropisSum         as  character no-undo.
define variable  PropisQnty-b      as  character no-undo.
define variable  PropisSum-b       as  character no-undo.
define variable B-Sum1 as decimal no-undo .
define variable B-Sum as decimal no-undo .
define variable B-Sum-qnty as decimal no-undo .
define variable B-adress like ub.firm.addres1 no-undo .
define variable B-phone  like ub.firm.phone no-undo .
define variable  Propiscount       as  character no-undo.
define variable  PropiscountP      as  character no-undo.
define variable  abbr              as  character no-undo.
define variable pp as character no-undo .
define variable tt    as integer no-undo.
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
define variable  v-ord_date   as character no-undo .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable store-type      as character    no-undo.
define variable store-code      as integer      no-undo.
define variable v-itoggo      as character no-undo .
DEFINE FRAME sl
       HEADER
        string( cur-time-print() ) AT 5 format "X(35)"
        string( "Заказ N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 90 format "X(19)"
        string( " Лист " + string( PAGE-NUMBER(OutStream) , ">>9") ) format "X(13)" SKIP
        UndLine format "X(136)" AT 1
        with width 136 down stream-io use-text NO-BOX.
define buffer nakl_trn-doc for ub.trn-doc.
define buffer buf_trn-doc for ub.trn-doc.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
    store-type = v-cntxt-obj-type
    store-code = v-cntxt-obj-code
.
FIND nakl_trn-doc WHERE recid(nakl_trn-doc) = p-recid NO-LOCK .
find first  buf_trn-doc no-lock where buf_trn-doc.doc-code = nakl_trn-doc.out-code no-error .
if error-status :error then return .
assign
    tdoc-date = buf_trn-doc.doc-date
    tdoc-code = nakl_trn-doc.doc-code .
define variable  v-ord_time   as character no-undo .
define variable  v-dchek      as character no-undo .
define variable  v-befpay     as character no-undo .
define variable  v-ord_nchek  as character no-undo .
define variable  v-deliv      as character no-undo .
define variable  v-sumwrk     as character no-undo .
define variable  v-ord_adr    as character no-undo .
define variable  v-ord_hwo    as character no-undo .
define variable  v-type       as character no-undo .
define variable  v-postdchek  as character no-undo .
define variable  v-postpay    as character no-undo .
define variable  v-postNchek  as character no-undo .
define variable  v-ord_phone  as character no-undo .
define variable  v-ord_dl     as character no-undo .
define variable v-ord_contact as character no-undo .
v-ord_date = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '0rsrv-date':U ,
                       output v-ord_date ,
                       output v-type )  .
v-ord_time = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '1ord_time':U ,
                       output v-ord_time ,
                       output v-type )  .
v-dchek = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '4dchek':U ,
                       output v-dchek ,
                       output v-type )  .
v-befpay = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '2befpay':U ,
                       output v-befpay ,
                       output v-type )  .
v-ord_nchek = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '3ord_Nchek':U ,
                       output v-ord_nchek ,
                       output v-type )  .
v-deliv = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '5deliv':U ,
                       output v-deliv ,
                       output v-type )  .
v-sumwrk = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '6sumwrk':U ,
                       output v-sumwrk ,
                       output v-type )  .
v-ord_adr = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '8ord_adr':U ,
                       output v-ord_adr ,
                       output v-type )  .
v-ord_hwo = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '9ord_hwo':U ,
                       output v-ord_hwo ,
                       output v-type )  .
v-postdchek = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '3postdchek':U ,
                       output v-postdchek ,
                       output v-type )  .
v-postpay = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '1postpay':U ,
                       output v-postpay ,
                       output v-type )  .
v-postNchek = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '2postNchek':U ,
                       output v-postNchek ,
                       output v-type )  .
v-ord_phone = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '21ord_phone':U ,
                       output v-ord_phone ,
                       output v-type )  .
v-ord_dl = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '4ord_dl':U ,
                       output v-ord_dl ,
                       output v-type )  .
v-ord_contact = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input '22ord_contact':U ,
                       output v-ord_contact ,
                       output v-type )  .
v-itoggo = "" .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input nakl_trn-doc.doc-code ,
                        input 'discnt-stop':U ,
                       output v-itoggo ,
                       output v-type )  .
if session :set-wait-state( "compiler" ) then.
output STREAM OutStream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(62) .
assign
  Line    = fill("-", 136)
  UndLine = fill("_", 136)
  LineBuf = fill("_", 136) .
    Output stream Macr_Excel  close .
    num#str# = 0 .
    run gbl/_tmpfile.p ( "wb", ".txt", output v-file-name) .
    output stream macr_excel to value(v-file-name)   .
    v-ind = v-ind + 1.
if buf_trn-doc.exch-code = 0 then
    assign
        PrintRubl = true
        pp = "руб"
    .
else do:
   FIND ub.currency NO-LOCK WHERE ub.currency.curr-code = buf_trn-doc.exch-code.
   assign
        PrintRubl = false
        pp = ub.currency.curr-abbr
        .
        end.
.
run waitfram-show ( 'Подождите ...' ) .
FIND This_Object  WHERE This_Object.obj-type = store-type
                    AND This_Object.obj-code = store-code NO-LOCK.
FIND ub.clients  WHERE ub.clients.obj-type = 'орг':U
                AND ub.clients.obj-code = buf_trn-doc.host-code NO-LOCK.
Case buf_trn-doc.cli-type :
    when  'орг':U then do :
        FIND ub.firm  WHERE ub.firm.firm-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.firm.addres1
          b-phone  = ub.firm.phone .
        end.
    when  'чел':U then do :
        FIND ub.person  WHERE ub.person.psn-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.person.address
          b-phone  = ub.person.phone1 .
        end.
    when  'маг':U then do :
        FIND ub.shop  WHERE ub.shop.obj-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.shop.addres1
          b-phone  = ub.shop.phone .
        end.
    when  'скл':U then do :
        FIND ub.store  WHERE ub.store.obj-code = buf_trn-doc.cli-code NO-LOCK.
        Assign
          B-adress = ub.store.addres1
          b-phone  = ub.store.phone .
        end.
 End case.
define variable v-manag    as character no-undo initial "".
define variable v-type-pay as character no-undo initial "".
define buffer mn_clients for ub.clients.
find first mn_clients no-lock where mn_clients.obj-code = buf_trn-doc.boss and
                                    mn_clients.obj-type = 'чел':U no-error .
if available mn_clients then v-manag  = mn_clients.obj-name.
find first ub.pay-type no-lock where ub.pay-type.obj-code = buf_trn-doc.pay-code no-error .
if available ub.pay-type then v-type-pay  = ub.pay-type.obj-name.
define buffer cl_clients for  ub.clients.
FIND cl_clients  WHERE cl_clients.obj-type = buf_trn-doc.cli-type
                   AND cl_clients.obj-code = buf_trn-doc.cli-code NO-LOCK.
    case clients.obj-type:
       when 'орг':U
       then do:
            FIND ub.firm WHERE ub.firm.firm-code = clients.obj-code NO-LOCK .
            if available ub.firm
            then do:
                assign
                    t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
                    t-addres = t-addres
                        + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
                            then ""
                            else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) )
                          )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                        + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( ", " + trim( ub.firm.addres2 ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
                    t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else ", " )
                        + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
                    t-phone = ub.firm.phone
                    t-inn   = ub.firm.inn
                    t-okpo  = ub.firm.okpo
                .
            end.
       end.
       when 'маг':U
       then do:
            FIND ub.shop WHERE ub.shop.obj-code = clients.obj-code NO-LOCK .
            if available ub.shop
            then do:
                assign
                    t-addres = ( if trim( shop.addres1 ) <> "" then ( trim( shop.addres1 ) ) else "" )
                            + ( if trim( shop.addres2 ) <> "" then ( ", " + trim( shop.addres2 ) ) else "" )
                    t-phone = shop.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'скл':U
       then do:
            FIND ub.store WHERE ub.store.obj-code = clients.obj-code NO-LOCK .
            if available ub.store
            then do:
                assign
                    t-addres = ( if trim( ub.store.addres1 ) <> "" then ( trim( ub.store.addres1 ) ) else "" )
                            + ( if trim( ub.store.addres2 ) <> "" then ( ", " + trim( ub.store.addres2 ) ) else "" )
                    t-phone = ub.store.phone
                    t-inn = ""
                    t-okpo = ""
                .
            end.
       end.
       when 'чел':U
       then do:
            find ub.person where ub.person.psn-code = clients.obj-code no-lock .
            if available ub.person
            then do:
                assign
                    t-addres = ( if ub.person.ind <> 0 and ub.person.ind <> ? then string( ub.person.ind ) else "" )
                                + ( if  ub.person.city <> ? and trim(ub.person.city) <> "" then ( ", " + trim( ub.person.city ) ) else "" )
                                + ( if  ub.person.address <> ? and trim(ub.person.address) <> "" then ( ", " + trim( ub.person.address ) ) else "" )
                    t-phone = ub.person.phone1
                    t-inn = ub.person.inn
                    t-okpo = ub.person.okpo
                .
            end.
       end.
    end case.
assign
  t-addres = ( if ub.firm.ind = 0 or ub.firm.ind = ? then "" else string( ub.firm.ind ) )
  t-addres = t-addres
      + ( if ub.firm.city = ? or trim(ub.firm.city) = ""
          then ""
          else ( (if t-addres = "" then "" else ", ") + trim( ub.firm.city ) + ", ")
        )
  t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 1, 50 ) ) )
  t-addres = t-addres
      + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
      + ( if  ub.firm.addres2 = ? or trim(ub.firm.addres2) = "" then "" else ( trim( ub.firm.addres2 ) ) )
  t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 51, 50 ) ) )
  t-addres = t-addres + ( if t-addres = "" or t-temp-address = "" then "" else "" )
      + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
  t-temp-address = ( if ub.firm.addres1 = ? then "" else trim( substring( ub.firm.addres1, 101, 50 ) ) )
  t-addres = t-addres   + ( if t-temp-address = "" then "" else ( trim( t-temp-address ) ) )
.
  Assign
   NAme1   = "ИНН " + t-inn + " " + CAPS( ub.clients.obj-name )
   NAme2   = cl_clients.obj-name
   Adres1  = t-addres + "  " + t-phone
   Adres2  = b-adress + "  " + b-phone
   .
  Adres1  = " Адрес: " + t-addres + "  тел. " + t-phone .
PUT STREAM OutStream
    space(90) "Бланк заказа № 2"     format "X(100)"       skip
    space(0) string( Name1  )   format "X(110)" skip
    space(0) string( CAPS( This_Object.obj-name )  + Adres1 ) format "X(100)" skip(1)
    space(50) Line format "X(33)" skip
    space(30) string( "З А К А З ") format "x(10)"
            " | " at 50
              ( string( tdoc-code , "X(16)" ) + " | "
              + string( tdoc-date , "99/99/9999" )
          + " | "  + (if buf_trn-doc.status_ <> 'факт':U then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else ""))
                  format "X(50)" skip
                space(50) Line format "X(33)" skip
    space(0) "Срок исполнения  :" v-ord_date format "X(100)" skip
    space(0) "Время исполнения :" v-ord_time format "X(100)"  skip
    space(0) "Заказчик         :" + name2  format "X(59)"
     "Телефон:"        +   b-phone format "X(20)"  at 62  skip
    space(0) "Номер клиента или клиентской карты  :" + string(cl_clients.obj-code) format "X(60)" skip
    space(0) "Контактное лицо  :" + v-ord_contact format "X(59)"
     "Телефон:"        +  v-ord_phone format "X(60)"  at 62  skip
    space(0) "Менеджер по заказам :" v-manag      format "X(60)"
             "Дата составления заказа :" + string( buf_trn-doc.doc-date , "99/99/9999" ) format "X(40)" at 62 skip
    space(0) "Оплата              "                format "X(100)"  skip
    space(0) "Вид                 :" v-type-pay    format "X(100)"  skip
    space(0) "Валюта              :" + pp   format "X(50)" skip
             "Предоплата " + v-befpay      format "X(50)"
             "Доплата "     + v-postpay      at 62        format "X(50)"  skip
             "Чек № " + v-ord_nchek + " от " + v-dchek                 format "X(50)"
             "Чек № " + v-postNchek + " от " + v-postdchek            at 62 format "X(50)"  skip (1)
    space(0) "Доставка "  + ( if v-ord_dl = "yes"  then "ДА" else "НЕТ")       format "X(100)"  skip
    space(0) "Куда                 :" v-ord_adr format "X(100)"  skip
    space(0) "Кому                 :" v-ord_hwo format "X(100)"  skip
    space(0) "Стоимость доставки   :" v-deliv  format "X(100)"  skip
    space(0) "Наценка за работу    %" v-sumwrk format "X(100)"  skip
    space(0) "Скидка клиента       %" + string(nakl_trn-doc.discnt-pc) format "X(100)"  skip(1)
    .
num#str# = 1.    num#col# = 1.    run macr_excel_char ("Бланк заказа № 2"                                                          , num#str# , num#col#   ) .
num#str# = 1.    num#col# = 6.    run macr_excel_char (cur-time-print()                                           , num#str# , num#col#   ) .
num#str# = 2.    num#col# = 1.    run macr_excel_char (string( Name1  )                                          , num#str# , num#col#   ) .
num#str# = 3.    num#col# = 1.    run macr_excel_char (substring(string( CAPS( This_Object.obj-name )  + Adres1 ) ,1,80)                           , num#str# , num#col#   ) .
num#str# = 4.    num#col# = 1.    run macr_excel_char (substring(string( CAPS( This_Object.obj-name )  + Adres1 ) ,81,255 )                           , num#str# , num#col#   ) .
run macr_cell_format ( 9 , false  , false, ?, num#str#, num#col#, num#str#, num#col# ).
num#str# = 5.    num#col# = 2.    run macr_excel_char ( string( "ЗАКАЗ № ") +  tdoc-code                                           , num#str# , num#col#   ) .
run macr_cell_format ( 15 , true , false, ?, num#str#, num#col#, num#str#, num#col# ).
num#str# = 6.    num#col# = 1.    run macr_excel_char ("Срок исполнения  :"                                                        , num#str# , num#col#   ) .
num#str# = 7.    num#col# = 1.    run macr_excel_char ( '="' + v-ord_date + '"'                                , num#str# , num#col#   ) .
run macr_cell_format ( 10 , true , false, ?, num#str#, num#col#, num#str#, num#col# ).
num#str# = 8.    num#col# = 1.    run macr_excel_char ("Время :" + v-ord_time                                           , num#str# , num#col#   ) .
run macr_cell_format ( 10 , true , false, ?, num#str#, num#col#, num#str#, num#col# ).
num#str# = 9.    num#col# = 1.    run macr_excel_char ("Заказчик :"                                                                , num#str# , num#col#   ) .
num#str# = 10.    num#col# = 1.    run macr_excel_char ( name2                                                                      , num#str# , num#col#   ) .
run macr_cell_format ( 10 , true , false, ?, num#str#, num#col#, num#str#, num#col# ).
num#str# = 10.    num#col# = 5.    run macr_excel_char ("Тел:"  + b-phone                                                           , num#str# , num#col#   ) .
num#str# = 11.  num#col# = 1.    run macr_excel_char ("Номер клиента или клиентской карты  :" + string(cl_clients.obj-code) + " " + string(nakl_trn-doc.d-card)  , num#str# , num#col#   ) .
num#str# = 12.  num#col# = 1.    run macr_excel_char ("Контактное лицо  :"                                                        , num#str# , num#col#   ) .
num#str# = 13.  num#col# = 1.    run macr_excel_char ( v-ord_contact                                                              , num#str# , num#col#   ) .
num#str# = 13.  num#col# = 5.    run macr_excel_char ("Телефон:" +  v-ord_phone                                                   , num#str# , num#col#   ) .
num#str# = 14.  num#col# = 1.    run macr_excel_char ("Менеджер по заказам :"                                                     , num#str# , num#col#   ) .
num#str# = 15.  num#col# = 1.    run macr_excel_char ( v-manag                                                                    , num#str# , num#col#   ) .
num#str# = 14.  num#col# = 5.    run macr_excel_char ("Дата составления заказа :" + string( nakl_trn-doc.doc-date , "99/99/9999" )     , num#str# , num#col#   ) .
num#str# = 16.  num#col# = 1.    run macr_excel_char ("Оплата              "                                                      , num#str# , num#col#   ) .
num#str# = 17.  num#col# = 1.    run macr_excel_char ("Вид :" + v-type-pay                                        , num#str# , num#col#   ) .
num#str# = 18.  num#col# = 1.    run macr_excel_char ("Валюта :" + pp                                                , num#str# , num#col#   ) .
num#str# = 18.  num#col# = 5.    run macr_excel_char ("Предоплата " + v-befpay                                                    , num#str# , num#col#   ) .
num#str# = 19.  num#col# = 5.    run macr_excel_char ("Чек № " + v-ord_nchek + " от " + v-dchek                                   , num#str# , num#col#   ) .
num#str# = 21.  num#col# = 1.    run macr_excel_char ("Доставка "  + ( if v-ord_dl = "yes"  then "ДА" else "НЕТ")                 , num#str# , num#col#   ) .
run macr_cell_format ( 10 , true , false, ?, num#str#, num#col#, num#str#, num#col# ).
num#str# = 22.  num#col# = 1.    run macr_excel_char ("Куда                 :" + substring(v-ord_adr,1,50 )                          , num#str# , num#col#   ) .
if length(v-ord_adr) > 50 then do:
  num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char (substring(v-ord_adr,51,50 )                          , num#str# , num#col#   ) .
end.
if length(v-ord_adr) > 100 then do:
  num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char (substring(v-ord_adr,101,50 )                         , num#str# , num#col#   ) .
end.
if length(v-ord_adr) > 150 then do:
  num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char (substring(v-ord_adr,151,50 )                          , num#str# , num#col#   ) .
end.
if length(v-ord_adr) > 200 then do:
  num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char (substring(v-ord_adr,201,50 )                         , num#str# , num#col#   ) .
end.
num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char ("Кому                 :" + v-ord_hwo                                          , num#str# , num#col#   ) .
num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char ("Стоимость доставки   :" + v-deliv                                            , num#str# , num#col#   ) .
num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char ("Наценка за работу    %" + v-sumwrk                                           , num#str# , num#col#   ) .
num#str# = num#str# + 1 .  num#col# = 1.    run macr_excel_char ("Скидка клиента       %" + string(nakl_trn-doc.discnt-pc)                        , num#str# , num#col#   ) .
  put  stream macr_excel unformatted
       substitute('select("r&1c&2:r&3c&4 ")' ,  5 , 1 , num#str# ,  9 ) + chr(10)  +
        'BORDER( 1     , 0    , 0   , 0  , 0     ,      ,0,0,0,0,0) '  + chr(10)
       .
define buffer buf_goods for ub.goods.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define variable v-str as integer   no-undo .
define variable pos-start as integer   no-undo initial 1 .
define variable v-i as integer   no-undo .
define variable v-all-sum as decimal   no-undo .
define variable v-sum as decimal   no-undo .
for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
find first buf_goods no-lock
     where buf_goods.artic      = buf_doc-line.artic
       and buf_goods.prod-type  = buf_doc-line.prod-type
       and buf_goods.prod-code  = buf_doc-line.prod-code .
    put stream outstream
        space(30) caps(buf_goods.gds-name)    format "x(100)"       skip
        "Описание:" skip .
    num#str# = num#str# + 1.  num#col# = 2 .
    run macr_excel_char (caps(buf_goods.gds-name), num#str# , num#col# ) .
    run macr_cell_format ( 15 , true , false, ?, num#str#, num#col#, num#str#, num#col# ) .
    num#str# = num#str# + 1.  num#col# = 1 .
    run macr_excel_char ("Описание:", num#str# , num#col# ) .
    find first buf_doc-line-attr no-lock where
            buf_doc-line-attr.doc-code = buf_doc-line.doc-code
        and buf_doc-line-attr.gds-code = buf_goods.gds-code
        and buf_doc-line-attr.attr-code = 'flora_ps':U no-error .
      if available buf_doc-line-attr then do:
    pos-start = 1 .
    v-str = integer(length (buf_doc-line-attr.attr-value) / 80 ) + 1.
       repeat v-i = 1 to v-str :
         put stream outstream    substring (buf_doc-line-attr.attr-value , pos-start, 80) format "x(80)"  skip.
        num#str# = num#str# + 1.  num#col# = 1.
        run macr_excel_char (substring (buf_doc-line-attr.attr-value , pos-start, 80), num#str# , num#col# ).
        pos-start = pos-start + 80 .
       end.
    end.
    run sost in this-procedure (input buf_goods.gds-code , output v-sum) .
    v-all-sum = v-all-sum  + v-sum .
end.
define variable v-proc as decimal   no-undo .
define variable v-procs as decimal   no-undo .
define variable v-proci as decimal   no-undo .
v-proc =  decimal (v-sumwrk) no-error .
if error-status :error then v-proc = 0.
v-procs = v-proc * v-all-sum / 100 .
v-proci = v-procS  + v-all-sum     .
 run on-same-page in this-procedure (input 5) .
 HIDE stream OutStream FRAME BottomFrame .
 PUT  STREAM OutStream
 "---------------------------------------" format "X(100)" skip
 "Итого со скидкой :" + string(v-all-sum , ">>>>>>>>>9.99")    format "X(100)" skip
 "Наценка          :" + string(v-procs, ">>>>>>>>>9.99")       format "X(100)"skip
 "ИТОГО С УЧЕТОМ НАЦЕНКИ :" + string(v-proci, ">>>>>>>>>9.99")  format "X(100)"skip
 "ИТОГО С УЧЕТОМ ДОСТАВКИ :" + string(v-proci + decimal(v-deliv), ">>>>>>>>>9.99")  format "X(100)"skip(2)
 "Заказ распечатан : " + cur-time-string () format "X(100)"    Skip
            .
if nakl_trn-doc.status_ = 'факт':U then do:
num#str# = num#str# + 1.
num#col# = 1.
 num#str# = num#str# + 1.  run macr_excel_char ( "Итого с учетом наценки  :" + string( nakl_trn-doc.tot-sale - decimal(v-deliv), ">>>>>>>>>9.99")    , num#str# , num#col# ).
 num#str# = num#str# + 1.  run macr_excel_char ( "Скидка клиента          :" + string( nakl_trn-doc.discnt-rubl, ">>>>>>>>>9.99")                    , num#str# , num#col# ).
 num#str# = num#str# + 1.  run macr_excel_char ( "Стоимость доставки      :" + v-deliv                                                               , num#str# , num#col#   ) .
 num#str# = num#str# + 1.  run macr_excel_char ( "ИТОГО ПО ЗАКАЗУ         :" + string(round( decimal (v-itoggo),2 ))                       , num#str# , num#col# ).
end.
else do:
num#str# = num#str# + 1.
num#col# = 1.
 num#str# = num#str# + 1.  run macr_excel_char ( "Итого со скидкой :" + string(v-all-sum , ">>>>>>>>>9.99")                                , num#str# , num#col# ).
 num#str# = num#str# + 1.  run macr_excel_char ( "Наценка :" + string(v-procs, ">>>>>>>>>9.99")                                   , num#str# , num#col# ).
 num#str# = num#str# + 1.  run macr_excel_char ( "ИТОГО С УЧЕТОМ НАЦЕНКИ :" + string(v-proci, ">>>>>>>>>9.99")                             , num#str# , num#col# ).
 num#str# = num#str# + 1.  run macr_excel_char ( "Стоимость доставки      :" + v-deliv                                            , num#str# , num#col#   ) .
 num#str# = num#str# + 1.  run macr_excel_char ( "ИТОГО ПО ЗАКАЗУ :" + string(round( decimal (v-itoggo),2 ))         , num#str# , num#col# ).
end.
output stream OutStream CLOSE .
run waitfram-hide .
  run paramls-write in this-procedure
    (input "file"
    ,input string(v-ind)
    ,input v-file-name
    ) .
run end-proc in this-procedure .
Output stream Macr_Excel  close .
    run paramls-write in this-procedure
        (input "charcol"
        ,input ""
        ,input "1,2,3,4,5"
        ) .
define variable v-user-action as character no-undo .
define variable v-printed     as logical   no-undo .
 make-excel = true      .
 make-excel-com = false  .
run rep/runexcel.p ( v-file-name).
PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( OutStream ) then do:
    return .
  end.
  if line-counter( OutStream ) + p-line-number > page-size( OutStream ) then do:
    page stream OutStream .
  end.
end procedure.
procedure sost :
  do
  on error undo, return error return-value
  :
define input  parameter p-bk-gds-code as integer   no-undo .
define output parameter v-all-sum as decimal   no-undo .
define variable v-cost as decimal   no-undo .
define variable v-dis as decimal   no-undo .
v-all-sum = 0 .
define variable v-qnty       as    decimal   no-undo .
define variable v-exist as logical   no-undo .
put stream outstream    "Составляющие:"  format "x(100)"  skip.
     num#str# = num#str# + 1.
     num#col# = 1. run macr_excel_char ("Составляющие:", num#str# , num#col# ).
for each buf_gds-dtl no-lock where buf_gds-dtl.doc-code = nakl_trn-doc.doc-code :
    find first buf_goods no-lock
        where buf_goods.artic      = buf_gds-dtl.artic
          and buf_goods.prod-type  = buf_gds-dtl.prod-type
          and buf_goods.prod-code  = buf_gds-dtl.prod-code .
run lineattr-exist-flora-gds in this-procedure (
    input  buf_gds-dtl.doc-code    ,
    input  buf_goods.gds-code      ,
    input  buf_gds-dtl.prt-code    ,
    input  p-bk-gds-code           ,
    output v-exist                 ).
if v-exist = false then next.
run lineattr-value-flora-gds    (
    input  buf_gds-dtl.doc-code    ,
    input  buf_goods.gds-code      ,
    input  buf_gds-dtl.prt-code    ,
    input  p-bk-gds-code           ,
    input  'fl_gds-code':U ,
    output v-qnty                      ).
    if v-qnty < 0 then next.
    find first ub.gds-prt where ub.gds-prt.node-code = buf_gds-dtl.prt-code no-error .
    if buf_trn-doc.exch-code = 0 then  assign
                                         v-cost = buf_gds-dtl.price-rubl
                                         v-dis  = buf_gds-dtl.discnt-rubl * v-qnty
                                         .
                                 else
                                        assign
                                          v-cost = buf_gds-dtl.price-base
                                          v-dis  = buf_gds-dtl.discnt-base * v-qnty
                                        .
    put stream outstream  unformatted
    buf_goods.artic at 1
    caps(buf_goods.gds-name) + "-" + ub.gds-prt.f-name    format "x(50)"     at 11
    "кол-во: " + string (v-qnty, ">>>>>9.99")     at 70
    "по цене " + string (v-cost, ">>>>>9.99")     at 90
    skip.
     num#str# = num#str# + 1.
     num#col# = 1. run macr_excel_char (buf_goods.artic, num#str# , num#col# ).
     num#col# = 2. run macr_excel_char (caps(buf_goods.gds-name) + "-" + ub.gds-prt.f-name, num#str# , num#col# ).
     num#col# = 6. run macr_excel_char ("кол-во: ", num#str# , num#col# ).
     num#col# = 7. run macr_excel_dec (  v-qnty , num#str# , num#col# ).
     num#col# = 8. run macr_excel_char ("по цене: ", num#str# , num#col# ).
     num#col# = 9. run macr_excel_dec (  round(v-cost,2) , num#str# , num#col# ).
    v-all-sum =  v-all-sum + ( v-qnty * v-cost ) - v-dis .
end.
  end.
end procedure.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
