using Progress.Lang.*.
using ibs.th.ref.sobj.sSchet from propath.
using ibs.th.ref.sobj.userhist from propath.
block-level on error undo, throw.
class ibs.th.ref.sobj.dReportTrg:
   define public variable  parParentProc   as widget-handle no-undo.
   define public variable  procname        as character no-undo .
   define public variable  namereport      as character no-undo .
   define public variable  param-date      as integer   no-undo .
   define public variable  param-goods     as character no-undo .
   define public variable  param-obj       as character no-undo .
   define public variable  param-pay       as character no-undo .
   define public variable  param-pay-hide  as character no-undo .
   define public variable  param-alon      as logical   no-undo .
   define public variable  d-report-handle as widget-handle no-undo.
   define stream ForExcel.
   define stream str-export.
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private logical cur-time (output p-today as date,
                                 output p-time  as integer ):
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
method private character  cur-time-date ()
:
  return string(today, '99/99/9999':U) .
end.
method private decimal cur-time-mjd ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
method private integer cur-time-get-ending-index
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
method private character cur-time-mjd-to-date(
  input  i-mjd-diff as decimal
,output  o-Date     as date
,output  o-Time     as integer):
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
method private character cur-time-mjd-to-string
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
method private character cur-time-string ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
method private character cur-time-string-sec ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
method private character cur-time-custom
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
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
method private character cur-time-print ()
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  cur-time
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
method private datetime cur-time-datetime ()
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
method private character cur-time-string-msec ()
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
   define public variable mUserframe as ibs.th.ref.sobj.sUserFrame no-undo.
   define public variable mShift    as class ibs.th.ref.sobj.sShift no-undo.
   define public variable mGoods    as class ibs.th.ref.sobj.sGoods no-undo.
   define public variable mObj      as class ibs.th.ref.sobj.sobj no-undo.
   define public variable mSchet    as class ibs.th.ref.sobj.sSchet no-undo.
   define public variable mCurrency as class ibs.th.ref.sobj.sCurrency no-undo.
   define public variable mCustomer as class ibs.th.ref.sobj.sCustomer no-undo.
   define public variable mFormat   as class ibs.th.ref.sobj.sFormat no-undo.
   define public variable mListF   as class ibs.th.ref.sobj.slistf no-undo.
   define variable mParamObj  as class ibs.th.ref.sobj.sParamObj  no-undo.
   define variable mParamForm as class ibs.th.ref.sobj.sParamForm no-undo.
   define variable mType      as class ibs.th.ref.sobj.stype      no-undo.
   define variable userhist      as class ibs.th.ref.sobj.userhist      no-undo.
   define public property mDReport as class ibs.th.ref.sobj.dreport no-undo
   get.
   set(iarg as  class ibs.th.ref.sobj.dreport):
      assign
         mDReport   = iarg.
         mUserframe = mDReport:mUserframe.
         mUserframe:paramobj = mParamObj.
         mUserframe:paramForm = mParamForm.
         mShift     = mDReport:mShift.
         mShift:paramobj = mParamObj.
         mShift:paramForm = mParamForm.
         mShift:stype     = mtype.
         mShift:mtrgGLb   = this-object.
         mGoods     = mDReport:mGoods.
         mGoods:paramobj = mParamObj.
         mGoods:paramForm = mParamForm.
         mGoods:stype     = mtype.
         mGoods:mtrgGLb   = this-object.
         mObj           = mDReport:mObj.
         mObj:paramobj  = mParamObj.
         mObj:paramForm = mParamForm.
         mObj:stype     = mtype.
         mObj:mtrgGLb   = this-object.
         mSchet     = mDReport:mSchet.
         mSchet:paramobj  = mParamObj.
         mSchet:paramForm = mParamForm.
         mSchet:stype     = mtype.
         mSchet:mtrgGLb   = this-object.
         mCurrency  = mDReport:mCurrency.
         mCurrency:paramobj  = mParamObj.
         mCurrency:paramForm = mParamForm.
         mCurrency:stype     = mtype.
         mCurrency:mtrgGLb   = this-object.
         mCustomer  = mDReport:mCustomer.
         mCustomer:paramobj  = mParamObj.
         mCustomer:paramForm = mParamForm.
         mCustomer:stype     = mtype.
         mCustomer:mtrgGLb   = this-object.
         mListF     = mDReport:mListF.
   end.
   define public variable  temp-param-obj-type     as character    no-undo .
   define public variable  temp-param-schet-mode     as character    no-undo .
   define public variable  all-object     as logical    no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   define public property  param-universal as character
   get.   set.
method public void OpenForExcel():
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( mParamObj:my-g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( mParamObj:my-g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( mParamObj:my-g#report-num ) + ".txl":U ) .
   if mParamObj:Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( mParamObj:my-g#report-num ) + ".txt":U ) ) .
      assign
         mParamObj:v-excel-file = string( session:temp-directory + "rpt" + string( mParamObj:my-g#report-num ) )
         mParamObj:number-list = 1
      .
      if mParamObj:make-excel-com
      then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(mParamObj:ch#WorkSheet) then
RELEASE OBJECT mParamObj:ch#WorkSheet no-error.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(mParamObj:ch#Workbook) then
RELEASE OBJECT mParamObj:ch#Workbook no-error.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(mParamObj:ch#ExcelApplication) then
RELEASE OBJECT mParamObj:ch#ExcelApplication no-error.
         create "Excel.Application" mParamObj:ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" mParamObj:ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            mParamObj:num#str#  = 0.
            v-ch#excelApplication  = mParamObj:ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            mParamObj:ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            mParamObj:ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = mParamObj:ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            mParamObj:Make-Excel-com = false .
            mParamObj:Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( mParamObj:my-g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( mParamObj:my-g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
method public void CloseForExcel():
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if mParamObj:Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( mParamObj:my-g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( mParamObj:my-g#report-num ) + ".frm":U ) .
      vsheet-num = mParamObj:sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( mParamObj:my-g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(mParamObj:ch#WorkSheet) then
RELEASE OBJECT mParamObj:ch#WorkSheet no-error.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(mParamObj:ch#Workbook) then
RELEASE OBJECT mParamObj:ch#Workbook no-error.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(mParamObj:ch#ExcelApplication) then
RELEASE OBJECT mParamObj:ch#ExcelApplication no-error.
   end.
end.
   constructor public dReportTrg (  ):
      super ().
      mParamObj  = new ibs.th.ref.sobj.sParamObj().
      mParamForm = new ibs.th.ref.sobj.sParamForm().
      mType      = new ibs.th.ref.sobj.stype ().
   end constructor.
   destructor public dReportTrg ( ):
      delete object mParamObj  no-error.
      delete object mParamForm no-error.
      delete object mtype      no-error.
   end destructor.
   method public logical canselForm():
      return mDReport:canselForm().
   end.
   method public void local-apply-layout():
      mShift:local-apply-layout(mParamObj).
      mGoods:local-apply-layout(mParamObj).
      mObj:local-apply-layout(mParamObj).
      mCurrency:local-apply-layout(mParamObj).
      mCustomer:local-apply-layout(mParamObj).
      mSchet:local-apply-layout(mParamObj).
      if mparamobj:params-only-mode  = 'ПРОСМОТР':U then do:
         mDReport:togexcel:enabled = no.
         mDReport:toglisthist:enabled = no.
      end.
   end.
   method public void Assign-frame(  ):
      mShift:Assign-frame(  ).
      mParamObj:Make-Excel =  mDReport:TogExcel:checked .
      mParamObj:Print-List-Hist = mDReport:TogListHist:checked .
      mGoods:Assign-frame().
      mObj:Assign-frame().
      mCurrency:Assign-frame().
      mCustomer:Assign-frame().
      mSchet:Assign-frame().
      return.
   end method.
method private void local-pre-initialize ():
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .
  define variable v-ok    as logical   no-undo .
   cur-time  (output v-today
             ,output v-time
             ).
   if mParamForm:init-date-start = date("") or mParamForm:init-date-start = ? then mParamForm:init-date-start  = v-today .
   if mParamForm:init-date-end = date("") or mParamForm:init-date-end = ? then  mParamForm:init-date-end    = v-today .
   if mParamForm:init-date-alone = date("") or mParamForm:init-date-alone = ? then  mParamForm:init-date-alone  = v-today.
   if mParamForm:init-shift-alone = ? then mParamForm:init-shift-alone = 0 .
   if mParamForm:init-shift-start = ? then mParamForm:init-shift-start = 0 .
   if mParamForm:init-shift-end   = ? then mParamForm:init-shift-end   = 0 .
end.
method public void SetVar
(
):
   define variable customer-yes as logical init false no-undo .
   define variable customer-name as character init "" no-undo .
   define variable customer-type as character init "" no-undo .
   define variable schet-yes  as logical init false no-undo .
   define variable schet-name as character init "" no-undo .
   define variable schet-hide as character init "" no-undo .
   define variable schet-init as character init "" no-undo .
   define variable ed_date-ref as character no-undo .
   define variable Jv as integer no-undo.
   define variable v-ii as integer no-undo .
   define variable plase-cost as integer no-undo .
   define variable plase-crsa as integer no-undo .
   define variable plase-sale as integer no-undo .
   define variable radio-period as character   no-undo .
   define variable v-nn3 as integer no-undo.
   param-universal = param-universal + ",".
   temp-param-obj-type  = "".
   all-object = false .
   mParamObj:parParentProc = parParentProc.
   assign temp-param-schet-mode = 'фирма':U .
   v-nn3 = num-entries(param-universal).
   repeat Jv = 1 to v-nn3:
      case entry(Jv,param-universal ) :
        when  "all":U or
        when  "shop":U or
        when  "stok":U then temp-param-obj-type    =  entry(Jv,param-universal ).
        when   string(1)             then mParamObj:Make-Excel       = true.
        when   string(9)         then mParamObj:Make-Excel-com   = true.
        when   string(12)           then mParamForm:Verify-Arc-aht   = true.
        when   string(2)            then mParamForm:Verify-Arc-ot    = true.
        when   string(3)           then mParamForm:Verify-Arc-stk   = true.
        when   string(8)          then mParamForm:Verify-Arc-supp  = true.
        when   string(11)          then mParamForm:Verify-Arc-hold  = true.
        when   string(24)        then mParamForm:Verify-Arc-strong  = true.
        when   string(4)            then mParamForm:Verify-send-check = true.
        when   string(5)             then mParamObj:Show-Crsa = true.
        when   string(6)             then mParamObj:show-cost = true.
        when   string(7)             then mParamObj:show-sale = true.
        when   string(10)         then mParamForm:format-folder = true.
        when  string(13)          then customer-yes = true.
        when  string(14)             then schet-yes = true.
        when  string(15)   then schet-hide = schet-hide + string( 1   ) + "," .
        when  string(16)       then schet-hide = schet-hide + string( 2       ) + "," .
        when  string(17)     then schet-hide = schet-hide + string( 3     ) + "," .
        when  string(18)        then schet-hide = schet-hide + string( 4        ) + "," .
        when  string(19)       then schet-hide = schet-hide + string( 5       ) + "," .
        when  string(20)    then schet-hide = schet-hide + string( 6    ) + "," .
        when  string(21) then schet-hide = schet-hide + string( 7 ) + "," .
        when  "X-OWN-CMP":U then temp-param-schet-mode = "company-host":U .
        when  string(22)    then mParamObj:Print-List-Hist   = true.
        when  string(23)            then mParamForm:verify-arc-fin    = true.
    end case.
   if trim(entry(Jv,param-universal)) begins "name-sale" then  mParamForm:name-sale-price = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "X-DATE-START"      then  mParamForm:init-DATE-START  = date(entry(2,entry(Jv,param-universal ),"="))  .
   if caps(trim(entry(Jv,param-universal))) begins "X-DATE-END"        then  mParamForm:init-DATE-END    = date(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-DATE-ALONE"      then  mParamForm:init-DATE-ALONE  = date(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-SHIFT-ALONE"     then  mParamForm:init-Shift-ALONE = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-SHIFT-START"     then  mParamForm:init-Shift-Start = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-SHIFT-END"       then  mParamForm:init-Shift-End   = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-CUSTOMER-NAME"   then  customer-name    = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "X-CUSTOMER-TYPE"   then  customer-type    = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "X-SCHET-NAME"      then  schet-name       = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "X-SCHET-INIT"      then  schet-init       = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "X-SET_PAY_TYPE"    then  mParamForm:init-SET_PAY_TYPE = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "X-SET_VAL_TYPE"    then  mParamForm:init-SET_VAL_TYPE = int(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "ED_DATE-REF="      then  ed_date-ref       = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "parent-handle="    then  mParamObj:parent-handle     = widget-handle(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "all-object"        then  mParamForm:all-object        = true  .
   if caps(trim(entry(Jv,param-universal))) begins "params-only="      then  mParamForm:params-only       = logical(entry(2,entry(Jv,param-universal ),"=")) .
   if caps(trim(entry(Jv,param-universal))) begins "params-only-mode=" then  mParamObj:params-only-mode  = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "call="             then  mParamObj:place-call        = entry(2,entry(Jv,param-universal ),"=") .
   if caps(trim(entry(Jv,param-universal))) begins "radio-period="     then  radio-period      = entry(2,entry(Jv,param-universal ),"=") .
 end.
    mDReport:TogExcel:checked =mParamObj:Make-Excel  .
    mDReport:TogListHist:checked = mParamObj:Print-List-Hist  .
      local-pre-initialize ().
      if mParamForm:params-only then do:
         if     mParamObj:params-only-mode  = "'ПРОСМОТР':U"
            or  mParamObj:params-only-mode  =  'ПРОСМОТР':U
         then do:
            mParamObj:params-only-mode  = 'ПРОСМОТР':U.
            mDReport:params-only-mode_lookup(yes).
         end.
         else
            mDReport:params-only-mode_lookup(no).
      end.
      if customer-yes = true then do:
         if trim(customer-name) = "" then mParamForm:temp-param-customer =  "Выбор контрагента" .
                                     else mParamForm:temp-param-customer =  customer-name .
         mParamForm:temp-param-customer-type =  customer-type .
      end.
      else
         assign
            mParamForm:temp-param-customer =  ""
            mParamForm:temp-param-customer-type =  ""
         .
      if schet-yes = true then do:
         if trim(schet-name) = "" then mParamForm:temp-param-schet =  "Выбор счета" .
                                  else mParamForm:temp-param-schet =  schet-name .
         mParamForm:temp-param-schet-hide =  schet-hide .
         mParamForm:temp-param-schet-init =  schet-init .
      end.
      else do:
         assign
            mParamForm:temp-param-schet =  ""
            mParamForm:temp-param-schet-hide = ""
            mParamForm:temp-param-schet-init = ""
         .
      end.
      if ed_date-ref <> '':U
      then do:
         do v-ii = 1 to num-entries(ed_date-ref, ';'):
            if entry(1, entry(v-ii, ed_date-ref, ';'), chr(3)) = 'X-DATE-START':U
            then
               mParamForm:ref_date-start = entry(2, entry(v-ii, ed_date-ref, ';'), chr(3)).
            if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-END':U
            then
               mParamForm:ref_date-end = entry(2, entry(v-ii, ed_date-ref, ';'), chr(3)).
            if entry(v-ii, ed_date-ref, ';') begins 'X-DATE-ALONE':U
            then
               mParamForm:ref_date-alone = entry(2, entry(v-ii, ed_date-ref, ';'), chr(3)).
         end.
      end.
      mParamForm:temp-param-date     = param-date .
      mParamForm:temp-param-goods    = param-goods.
      mParamForm:temp-param-obj      = param-obj.
      mParamForm:temp-param-pay      = param-pay.
      mParamForm:temp-param-pay-hide = param-pay-hide.
      mParamForm:temp-param-alon     = param-alon.
      if mParamForm:temp-param-date = 9
      then do:
         mParamForm:temp-param-date-type-period = radio-period.
         if    mParamForm:temp-param-date-type-period = ?
            or mParamForm:temp-param-date-type-period = ""
         then
            mParamForm:temp-param-date-type-period = 'yesterday':U.
      end.
      mParamForm:temp-str =  mParamObj:ReportHeader.
      define variable vLog as logical no-undo.
      vLog= true .
      if    mParamObj:show-cost = true
         or lookup( "" , mParamForm:temp-param-pay ) > 0
      then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  mParamObj:my-cntxt-db-num
    ,input  mParamObj:my-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-cost':U
    ,input  'object':U
    ,input  mParamObj:my-cntxt-host-code-obj
    ,input  mParamObj:my-cntxt-obj-type
    ,input  mParamObj:my-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output vLog
    )  .
end.
         if not vlog
         then do:
            assign
               mParamObj:show-cost  = false
               plase-cost = index (mParamForm:temp-param-Pay , "" )
               substring(mParamForm:temp-param-Pay,plase-cost) = "0"
            no-error .
         end.
      end.
      if    mParamObj:show-crsa = true
         or lookup( "" , mParamForm:temp-param-pay ) > 0
      then do:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  mParamObj:my-cntxt-db-num
    ,input  mParamObj:my-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-crsa':U
    ,input  'object':U
    ,input  mParamObj:my-cntxt-host-code-obj
    ,input  mParamObj:my-cntxt-obj-type
    ,input  mParamObj:my-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output vlog
    )  .
end.
         if not vlog
         then do:
            assign
               mParamObj:show-crsa  = false
               plase-crsa = index (mParamForm:temp-param-pay , "" )
               substring(mParamForm:temp-param-pay,plase-crsa) = "0"
            no-error.
         end.
      end.
      if    mParamObj:show-sale = true
         or lookup( "" , mParamForm:temp-param-pay ) > 0
      then do:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  mParamObj:my-cntxt-db-num
    ,input  mParamObj:my-cntxt-userid
    ,input  0
    ,input  'actn_reports_lookup-sale':U
    ,input  'object':U
    ,input  mParamObj:my-cntxt-host-code-obj
    ,input  mParamObj:my-cntxt-obj-type
    ,input  mParamObj:my-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  no
    ,output vlog
    )  .
end.
         if not vlog
         then do:
            assign
               mParamObj:show-sale  = false
               plase-sale = index (mParamForm:temp-param-pay , "" )
               substring(mParamForm:temp-param-pay,plase-sale) = "0"
            no-error .
         end.
      end.
      initilize-page-3 () .
      define variable vObjVis as logical no-undo.
      define variable vCurrVis as logical no-undo.
      define variable vCustVis as logical no-undo.
      define variable vShctvis as logical no-undo.
      define variable vshftVis as logical no-undo.
      define variable vGoodVis as logical no-undo.
      Vobjvis = mParamForm:temp-param-obj ne "".
      vCurrVis = mParamForm:temp-param-pay ne "" or  mParamForm:temp-param-pay-hide ne "".
      vCustVis = mparamform:temp-param-customer ne "".
      vShctvis = mParamForm:temp-param-schet ne "".
      vshftVis = mparamForm:temp-param-date ne 0.
      vGoodVis = mparamForm:temp-param-goods ne "".
      mObj:visible      = Vobjvis.
      mCurrency:visible = vCurrVis .
      mCustomer:visible = vCustVis.
      mSchet:visible    = vShctvis.
      mShift:visible    =  vshftVis.
      mGoods:visible    =  vGoodVis.
      mdreport:splitContainer5:Panel2Collapsed = not vCurrVis.
      mdreport:splitContainer3:Panel2Collapsed = not vShctvis.
      mdreport:splitContainer1:Panel2Collapsed = not vCustVis.
      mdreport:splitContainer2:Panel1Collapsed = not vGoodVis.
      if not vshftVis and not vCurrVis
      then do:
         mdreport:splitContainer5:visible = no.
         mdreport:splitContainer1:Dock = System.Windows.Forms.DockStyle:fill.
      end.
end method .
method private void  initilize-page-3 ():
   define variable temp-str- as character no-undo .
   define variable temp-i as integer no-undo .
   define variable  l-ind as integer no-undo .
   define variable v-nn as integer no-undo.
   define variable v-nn2 as integer no-undo.
   find first ubflt.usr-flt no-lock where
         ubflt.usr-flt.user-name  = mParamObj:my-cntxt-userid and
         ubflt.usr-flt.call-point = mParamObj:ReportProc  no-error .
   if available ubflt.usr-flt
   then  do:
      v-nn = num-entries( ubflt.usr-flt.list_) .
      repeat l-ind = 1 to v-nn :
         if entry(1,entry(l-ind, ubflt.usr-flt.list_),"=")  = "ReportPageHeight":U
         then do:
            mParamObj:ReportPageHeight = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
            if error-status :error  then message "qq1" .
         end.
         if entry(1,entry(l-ind,ubflt.usr-flt.list_),"=")  = "ReportPageWidth":U
         then do:
            mParamObj:ReportPageWidth = integer(entry(2,entry(l-ind, ubflt.usr-flt.list_),"=")) no-error .
            if error-status :error  then message "qq2" .
         end.
         if entry(1,entry(l-ind, ubflt.usr-flt.list_ ),"=")  = "Use-Column":U
         then do :
            temp-str- = entry( 2 , entry(l-ind, ubflt.usr-flt.list_)  ,"=" ) no-error .
            if error-status :error  then message "qq3" .
            v-nn2 = num-entries ( temp-str- , ";") .
            repeat temp-i = 1 to v-nn2:
               if temp-i <= 50
               then
                  mParamObj:use-column[temp-i] = ( if trim(entry(temp-i,temp-str-,";")) = "true" then true else false) .
            end.
         end.
      end.
   end.
   else
      assign
         mParamObj:ReportPageHeight = 0
         mParamObj:ReportPageWidth  = 0
      .
    mDReport:mlistf:op-br() no-error.
end method.
   method public void FormRun () :
      FormRun(procname).
   end method.
   method public void FormRun (iClass as character) :
      mDReport = new ibs.th.ref.sobj.dreport (input iClass, input this-object).
      local-initialize ().
      wait-for System.Windows.Forms.Application:Run ( mDReport ) .
      define variable v-err-msg as character no-undo .
      catch exAppErrors as class Progress.Lang.AppError :
         v-err-msg = exAppErrors:ReturnValue .
         if v-err-msg > "" then . else do :
            v-err-msg = exAppErrors:GetMessage(1) .
            if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\sobj\dreporttrg.cls" .
         end .
         message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
      end catch .
      catch exProErrors as class Progress.Lang.ProError :
         v-err-msg = exProErrors:GetMessage(1) .
         if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\sobj\dreporttrg.cls" .
         message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
      end catch .
      catch exAnyErrors as class Progress.Lang.Error:
         v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\sobj\dreporttrg.cls " + exAnyErrors:GetMessage(1).
         message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
      end catch .
      finally:
         if valid-object(mDReport) then delete object mDReport no-error .
      end finally.
   end method .
   method public void blbt
   ():
      AssignParam().
      Assign-frame().
      if not param-alon
      then do:
         mUserframe:my-var().
      end.
      define variable mform as class ibs.th.ref.sobj.rprev no-undo.
      mform = new ibs.th.ref.sobj.rprev ().
      mform:ParamObj = mParamObj.
      wait-for mform:ShowDialog() .
      define variable v-err-msg as character no-undo .
      catch exAppErrors as class Progress.Lang.AppError :
         v-err-msg = exAppErrors:ReturnValue .
         if v-err-msg > "" then . else do :
            v-err-msg = exAppErrors:GetMessage(1) .
            if v-err-msg > "" then . else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\sobj\dreporttrg.cls" .
         end .
         message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
      end catch .
      catch exProErrors as class Progress.Lang.ProError :
         v-err-msg = exProErrors:GetMessage(1) .
         if v-err-msg > "" then . else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\sobj\dreporttrg.cls" .
         message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
      end catch .
      catch exAnyErrors as class Progress.Lang.Error:
         v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\sobj\dreporttrg.cls " + exAnyErrors:GetMessage(1).
         message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
      end catch .
      finally:
         if valid-object(mform) then delete object mform no-error .
      end finally.
   end.
   method public void bOk    ():
      if mparamform:params-only
      then do:
         proc-save-param-RUM() no-error.
         if error-status :error
         then do:
            return .
         end.
      end.
      else do:
         run trg/userlog.p (
             input "report":U
           , input namereport + chr(3) + procname
           , input ?
           , input ?
           , input ""
          ) no-error.
          if error-status :error
          then do:
              message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
          end.
         print-report() no-error .
         if error-status :error
         then do:
            return .
         end.
         return no-apply .
      end.
   end method.
   method private void local-initialize-s ():
   local-apply-layout().
   Assign-frame().
      mobj:local-initialize(mparamobj).
      mCurrency:local-initialize(mparamobj).
      mSchet:local-initialize(mparamobj).
      if mparamobj:Make-Excel
      then do:
         mDReport:TOGExcel:checked = true .
         mDReport:TOGExcel:Enabled = no.
         mDReport:TOGExcel:visible = yes.
      end.
      else do:
         mDReport:TOGExcel:Enabled = no.
         mDReport:TOGExcel:visible = no.
      end.
      if mparamobj:Print-List-Hist
      then do:
         mDReport:TOGListhist:checked = true .
         mDReport:TOGListhist:Enabled = yes.
         mDReport:TOGListhist:visible = yes.
      end.
      else do:
         mDReport:TOGListhist:Enabled = no.
         mDReport:TOGListhist:visible = no.
      end.
   end method.
method private void local-initialize ():
   define variable par-type  as character no-undo .
   define variable p-actuate as logical   no-undo .
   define variable vreport-num as integer  no-undo.
   run get-report-num   in parParentProc(output vreport-num).
   mParamObj:my-g#report-num = vreport-num.
   mParamObj:my-handle = parParentProc.
   setVar().
   local-initialize-s().
   assign
      mParamObj:ReportName = if mUserframe:namereport ne "" then mUserframe:namereport else  namereport
      mParamObj:ReportProc = if mUserframe:procname   ne "" then mUserframe:procname   else  procname
   .
   mDReport:Text  = trim(namereport).
   if mParamForm:params-only then do:
      if mParamObj:params-only-mode  = 'ПРОСМОТР':U then do:
         mDReport:Text  = substitute("Просмотр ПАРАМЕТРОВ отчета:  &1" ,  trim( mParamObj:ReportName ) ) .
      end.
      else do:
         mDReport:Text  = substitute("Задание ПАРАМЕТРОВ отчета:  &1" ,  trim( mParamObj:ReportName ) ) .
      end.
   end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'report-glob':U
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
      if thbjattr_thbj-attr.prop-code = 'actuate'  then p-actuate   = thbjattr_thbj-attr.property-value-logical .
   end.
   if p-actuate
   then do:
      if param-Alon = false
      then do:
          make-btn    ().
      end.
   end.
   if mParamForm:params-only  then do:
      mUserframe:my-params ( input "get" ) no-error .
      local-apply-layout ().
  end.
end .
method private void make-btn ():
 do
 on error undo, return error return-value
 :
   mDReport:b_ach:Visible = mUserframe:report-to-ach (yes).
  end.
end .
METHOD public void my_select():
AssignParam ().
Assign-frame().
end.
method private void AssignParam ():
   define variable vtext as character no-undo.
   vtext = mShift:AssignParam() no-error.
   if error-status :error
   then do:
      undo, return error vtext .
   end.
   vtext = mObj:AssignParam() no-error.
   if error-status :error
   then do:
      undo, return error vtext .
   end.
   vtext = mGoods:AssignParam() no-error.
   if error-status :error
   then do:
      undo, return error vtext .
   end.
   mparamObj:make-6-gds-list().
end.
define temp-table param-to-export no-undo
field param-code     as character
field param-sub-code as character
field param-type     as character
field param-value    as character
field param-comment  as character
index pi is unique primary  param-code     param-sub-code
.
method public void make-ach ():
   do
   on error undo, return error return-value
   :
      mUserframe:my-var().
      AssignParam().
      mUserframe:report-to-ach (no ) .
      mParamObj:get-param-to-export(output table param-to-export ).
      if error-status :error = true then return error .
      define variable exp-name as character no-undo .
      run gbl/_tmpfile.p ( "t", ".par", output exp-name) .
      output STREAM str-export TO  VALUE(exp-name).
      for each param-to-export :
         export stream str-export param-to-export .
      end.
      output STREAM str-export CLOSE.
      define variable res as integer no-undo .
      define variable name-exe as character no-undo .
      assign
         file-info:file-name = "exe/run-act.bat".
         name-exe = file-info:full-pathname
      no-error .
      if error-status :error then return error .
      run gbl/syn.p ( input name-exe , input  exp-name , input  "Запуск " + name-exe , output res ).
      if  res > 0
      then do:
         message  "Ошибка  при выполнении команды в ОС "  res .
      end.
   end.
end method.
method private void  return-var () :
  mListF:Save-table() no-error.
  mFormat:get-var() no-error.
  mUserframe:my-var() no-error.
end method.
method private void select-page(inum as integer ):
end.
method private void proc-save-param-RUM () :
  AssignParam().
  Assign-frame().
   if param-alon = false
   then do:
      initilize-page-3 () .
      return-var () .
      if   (   mParamObj:reportpageheight = 0
            or mParamObj:reportpagewidth = 0
            )
         and mParamForm:format-folder
      then do:
         select-page(3) .
         undo, return error return-value .
      end.
   end.
   mUserframe:my-var () no-error.
   if error-status:error then
   do:
      case return-value:
         when 'First-page':U then  do:
            return error.
         end.
         when 'Second-page':U then  do:
            message "Проверьте правильность заполнения формы!".
            select-page ( 2 ).
            return  error .
         end.
         when 'format-page' then do:
            message "Необходимо сходить на закладку <Формат...> !".
            select-page ( 3 ).
            return error.
         end.
         otherwise  do:
            message "Необходимо сходить на закладку <Продолжение...> !".
            select-page ( 2 ).
            return error.
         end.
      end case.
   end.
   mUserframe:my-params ( input "set" ) no-error .
   if error-status:error then
   do:
      case return-value:
         when 'First-page':U then  do:
            return error.
         end.
         when 'Second-page':U then  do:
            message "Проверьте правильность заполнения формы!".
            select-page ( 2 ).
            return  error .
         end.
         when 'format-page' then do:
            message "Необходимо сходить на закладку <Формат...> !".
            select-page ( 3 ).
            return error.
         end.
         otherwise  do:
            message "Необходимо сходить на закладку <Продолжение...> !".
            select-page ( 2 ).
            return error.
         end.
      end case.
   end.
end method.
method private void print-report ():
   define variable choice             as logical   no-undo .
   define variable v-total-archive-ok as logical   no-undo .
   define variable v-archive-ok       as logical init true  no-undo .
   define variable v-comment          as character no-undo .
   define variable v-can-print        as logical   no-undo .
   define variable temp-date      as date no-undo.
   define variable temp-shift     as integer no-undo .
   define variable v-date-start as date      no-undo .
   define variable v-date-end   as date      no-undo .
   define variable spis-obj     as character no-undo .
   AssignParam()  .
   Assign-frame().
   v-total-archive-ok = true.
   if mParamForm:verify-arc-fin = true
   then do:
      define variable p-status       as integer   no-undo .
      define variable p-cut-date     as date      no-undo .
      define variable p-cut-fin-date as date      no-undo .
run cutd-db in ibs.th.gbl.gbl-hndllib:g#library
  (input  mParamObj:my-cntxt-db-num
  ,output p-status
  ,output p-cut-date
  ,output p-cut-fin-date
  ) no-error .
      if param-date = 1
      then do:
         assign
            v-date-start = mParamObj:x-date-alone
            v-date-end   = mParamObj:x-date-alone
        .
      end.
      else do:
        assign
          v-date-start = mParamObj:x-date-start
          v-date-end   = mParamObj:x-date-end
        .
      end.
      if p-cut-date <> ? and ( v-date-start < p-cut-date  or v-date-end < p-cut-date)
      then do:
         message
            "ВНИМАНИЕ!" skip
            "БД была обрезана на " string(p-cut-fin-date, "99/99/9999")  skip
            "Данные в отчете будут не корректны." skip
            "Продолжить формирование отчета?" skip
         view-as alert-box question
            buttons yes-no
            title "Финансовые архивы"
            update choice .
         if choice = false
         then do:
            assign
               v-total-archive-ok = false
            .
            undo, return error return-value .
         end.
         else do:
            if param-date = 1
            then do:
               v-date-end = p-cut-fin-date .
            end .
            else do:
               v-date-start = p-cut-fin-date .
               v-date-end   = p-cut-fin-date .
            end.
            v-total-archive-ok = true .
         end.
      end.
   end.
   if mParamForm:verify-arc-hold = true
   then do:
      if param-date = 1
      then do:
         assign
            temp-date = mParamObj:x-date-alone
         .
      end.
      else do:
         TEMP-DATE = mParamObj:x-Date-End .
      end.
      run trg/bt_hold.p
         (input  temp-date
         ,input  true
         ,input  mParamObj:my-cntxt-db-num
         ,input  mParamObj:my-cntxt-userid
         ) no-error .
      if error-status :error
      then do:
         message
            "ВНИМАНИЕ!" skip
            "Межфирменные архивы" skip
            return-value skip
            "Данные по выбранному периоду могут быть неполными или некорректными."
            "Продолжить формирование отчета?" skip
         view-as alert-box question buttons yes-no update choice .
         if choice = false
         then do:
            v-total-archive-ok = false.
         end.
         else do:
            v-total-archive-ok = true.
         end.
      end.
   end.
   if    mParamForm:verify-arc-ot   = true
      or mParamForm:verify-arc-stk  = true
      or mParamForm:verify-arc-aht  = true
      or mParamForm:verify-arc-supp = true
   then do:
      if    mParamForm:verify-arc-ot = true
        and mParamForm:verify-arc-stk <> true
      then do:
         mParamForm:verify-arc-stk = true.
      end.
      spis-obj = "" .
      v-total-archive-ok  = true .
      mParamObj:get-obj-list(output table  obj-list).
      for each obj-list no-lock :
         if param-date = 1
         then do:
            assign
               v-date-start = mParamObj:x-date-alone
               v-date-end   = mParamObj:x-date-alone
            .
         end.
         else do:
            assign
               v-date-start = mParamObj:x-date-start
               v-date-end   = mParamObj:x-date-end
            .
         end.
         run rep/chk-ahz.p
            (input        obj-list.obj-type
            ,input        obj-list.obj-code
            ,input        mParamForm:verify-arc-ot
            ,input        mParamForm:verify-arc-stk
            ,input        mParamForm:verify-arc-supp
            ,input        mParamForm:verify-arc-aht
            ,input        true
            ,input        mParamObj:my-cntxt-db-num
            ,input        mParamObj:my-cntxt-userid
            ,input-output v-date-start
            ,input-output v-date-end
            ,output       v-archive-ok
            ,output       v-comment
            ,output       v-can-print
         ) .
         if v-archive-ok = false
         then do:
            if     v-can-print = false
               or  mParamForm:verify-arc-strong  = true
            then do:
               message
                  "ВНИМАНИЕ !!!" skip
                  "Отчет не может быть сформирован!" skip
                  "На запрошенную дату нет архивов или они сжаты" skip
                  v-comment skip
               view-as alert-box information .
               select-page (1).
               undo, return error return-value .
            end.
            else do:
               assign
                  v-total-archive-ok = false
                  spis-obj =  spis-obj + substitute("&1&2," , obj-list.obj-type , obj-list.obj-code)
               .
            end.
         end.
      end.
      spis-obj = trim(spis-obj, ',') .
      if v-total-archive-ok = false
      then do:
         define variable v-period-description as character no-undo .
         if param-date = 1
         then do:
            assign
               v-period-description = substitute("на конец дня &1"
                                           ,string(mParamObj:x-date-end, '99/99/9999':u)
                                           )
            .
         end.
         else do:
            assign
               v-period-description = substitute("с начала дня &1 по конец дня &2"
                                           ,string(mParamObj:x-date-start, '99/99/9999':u)
                                           ,string(mParamObj:x-date-end,   '99/99/9999':u)
                                           )
            .
         end.
         message
            "ВНИМАНИЕ!" skip
            v-comment skip
            spis-obj skip
            "" skip
            "Данные по выбранному периоду" v-period-description "могут быть неполными или некорректными." skip
            "Продолжить формирование отчета?" skip
         view-as alert-box question buttons yes-no update choice .
         if choice = false
         then do:
            v-archive-ok = false.
            return.
         end.
         else do:
            v-total-archive-ok = true.
         end.
      end.
   end.
   if v-total-archive-ok = true
   then do:
      if param-alon = false
      then do:
         initilize-page-3 ().
         return-var () .
         if    (mParamObj:reportpageheight = 0  or mParamObj:reportpagewidth = 0)
            and mParamForm:format-folder
         then do:
            select-page (3) no-error .
            undo, return error return-value .
         end.
      end.
      mUserframe:my-var () no-error.
      if error-status:error
      then do:
         case return-value:
            when 'First-page':U
            then  do:
               return .
            end.
            when 'Second-page':U then  do:
                message "Проверьте правильность заполнения формы!".
                select-page ( 2 ).
                return.
            end.
            when 'format-page' then do:
               message "Необходимо сходить на закладку <Формат...> !".
               select-page( 3 ).
               return no-apply.
            end.
            otherwise  do:
               message "Необходимо сходить на закладку <Продолжение...> !".
               select-page  ( 2 ).
               return no-apply.
            end.
         end case.
      end.
   end.
   if v-archive-ok = false and
        (  mParamForm:verify-arc-ot   = true
        or mParamForm:verify-arc-stk  = true
        or mParamForm:verify-arc-aht  = true
        or mParamForm:verify-arc-supp = true )
   then do:
      assign
         mParamObj:reportheader = mParamObj:reportheader + chr(10)
                     + "Архивы рассчитаны не полностью. Информация в отчете может быть неполной или некорректной."
                     + chr(10) +
                     (if spis-obj <> "" then substitute("Не корректная информация об архивах на объектах: &1" ,spis-obj ) else "")
      .
   end.
   mParamObj:d-report-handle = d-report-handle .
   if param-Alon
   then do:
      openforexcel () .
      if num-entries (trim(procname), " " ) > 1
      then do:
         define variable p-proc-par1 as character no-undo .
         define variable p-proc-par2 as character no-undo .
         assign
            p-proc-par1 = entry(1, procname, " ")
            p-proc-par2 = entry(2, procname, " ")
         .
         run value ( p-proc-par1 )
            (input p-proc-par2,
             input mparamObj ).
      end.
      else do:
         run value ( procname ) (input mparamObj).
      end.
      CloseForExcel () .
   end.
   else do:
      mUserframe:my-report () no-error .
      if error-status:error
      then do:
         case return-value:
            when 'First-page':U
            then  do:
               return .
            end.
            when 'Second-page':U then  do:
                message "Проверьте правильность заполнения формы!".
                select-page ( 2 ).
                return.
            end.
            when 'format-page' then do:
               message "Необходимо сходить на закладку <Формат...> !".
               select-page( 3 ).
               return no-apply.
            end.
            otherwise  do:
               message "Необходимо сходить на закладку <Продолжение...> !".
               select-page  ( 2 ).
               return no-apply.
            end.
         end case.
      end.
      CloseForExcel().
   end.
   run prg-bar_delete-progress-bar in mParamObj:d-report-handle .
   mParamObj:d-report-handle = ? .
end .
   method public void VALUE-CHANGED_TOG-Excel(iTogExcel as logical)
   :
      mParamObj:Make-Excel = iTogExcel.
      new-state ( "TOG-EXCEL ="  + String(iTogExcel)).
   end.
   method public void  VALUE-CHANGED_TOG-list-hist(iTog-list-hist as logical)
   :
      mParamObj:print-list-hist = iTog-list-hist.
      new-state ("TOG-list-hist ="  + String(iTog-list-hist)).
   end.
   method private void new-state(istate as character ):
   end.
   method public void setparam(
         iparParentProc  as handle,
         iprocname       as character ,
         inamereport     as character ,
         iparam-date     as integer   ,
         iparam-goods    as character ,
         iparam-obj      as character ,
         iparam-pay      as character ,
         iparam-pay-hide as character ,
         iparam-universal as character ,
         iparam-alon     as logical    ):
      assign
         parParentProc     = iparParentProc
         procname          = iprocname
         namereport        = inamereport
         param-date        = iparam-date
         param-goods       = iparam-goods
         param-obj         = iparam-obj
         param-pay         = iparam-pay
         param-pay-hide    = iparam-pay-hide
         param-universal   = iparam-universal
         param-alon        = iparam-alon
      .
   end.
end class.
