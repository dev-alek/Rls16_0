define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT  PARAMETER Action      AS CHARACTER            NO-UNDO.
DEFINE INPUT  PARAMETER DocType AS CHARACTER            NO-UNDO.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define   shared variable     lbc-path                     as  char        no-undo.
define   shared variable     lbc-tmp                      as  char        no-undo.
define  shared variable TicketName  as character   init ""    no-undo.
define  shared variable ScalePrice    as decimal init 0     no-undo.
define  shared variable TitleCP    as character   init ""    no-undo.
define  shared variable TicketType    as character   init ""    no-undo.
define  shared variable BCodeType    as character   init ""    no-undo.
define  shared variable UnitName    as character   init ""    no-undo.
define  shared variable TickOnN       as logical   init no   no-undo.
define  shared variable TickOnW       as logical   init no   no-undo.
define  shared variable TickOnS         as logical  init no    no-undo.
define  shared variable OnlyChgPr    as logical     init no    no-undo.
define  shared variable QntyType     as character   init ""    no-undo.
define  shared variable PriceType    as character   init ""    no-undo.
define  shared variable tick-w       as logical     init no    no-undo.
define  shared variable TickPS       as character   init ""    no-undo.
define   shared variable     GdsName   as character   no-undo.
define   shared variable     curr-date                      as  date      no-undo.
define   shared variable     curr-rate                      as  decimal      no-undo.
define   shared variable     bc-type   as character   no-undo.
define   shared variable     obj_name  as character   no-undo.
define   shared variable     list-sort      as character no-undo .
define variable Artic as char no-undo.
define variable i-art as int no-undo.
define variable i as int no-undo.
define variable pr-doc-rubl like ub.price-list.price-sale no-undo.
define variable pr-doc-rb like ub.price-list.price-sale no-undo.
define variable pr-doc-rubl-old like ub.price-list.price-sale no-undo.
define variable pr-doc-rb-old like ub.price-list.price-sale no-undo.
define variable upper as integer no-undo.
define variable nakl-qnty like ub.gds-dtl.fact-qnty no-undo.
define variable list-qnty like ub.gds-dtl.fact-qnty no-undo.
define variable rootnode_code as integer no-undo.
define variable tmp-var as char no-undo.
define variable type-par as char no-undo.
def   shared var bc-frmt as character no-undo .
def   shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str2  as character no-undo.
  define variable tmp-num2  as character no-undo.
  define variable i2        as integer   no-undo.
  define variable sum2      as integer   no-undo.
  define variable len-code2 as integer   no-undo.
  define variable varcont2  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont2 = yes then do:
    if integer( substring( tmp-str2, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str2, length( bc-pfx ) + 1, length( tmp-str2 ) - length( bc-pfx ) )
        len-code2    = length( full-b-code )
      .
      define variable v-sum-char2 as character no-undo .
      assign
        sum2 = 0
      .
      do i2 = 1 to len-code2 by 2
      :
        assign
          v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
        .
        if v-sum-char2 < "0"
        or v-sum-char2 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum2 = sum2 + integer(v-sum-char2)
        .
      end.
      if varcont2 = yes then do:
        assign
          sum2 = sum2 * 3
        .
        do i2 = 2 to len-code2 by 2
        :
          assign
            v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
          .
          if v-sum-char2 < "0"
          or v-sum-char2 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum2 = sum2 + integer(v-sum-char2)
          .
        end.
        if varcont2 = yes then do:
           if sum2 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum2 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
def   shared var pl-frmt as character no-undo .
def   shared var pl-pfx  as character no-undo .
def var pl-par-type as character no-undo .
PROCEDURE gen-pl:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str3  as character no-undo.
  define variable tmp-num3  as character no-undo.
  define variable i3        as integer   no-undo.
  define variable sum3      as integer   no-undo.
  define variable len-code3 as integer   no-undo.
  define variable varcont3  as logical   initial yes no-undo.
  CASE pl-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str3 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str3 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " pl-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont3 = yes then do:
    if integer( substring( tmp-str3, 1, length( pl-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = pl-pfx + substring( tmp-str3, length( pl-pfx ) + 1, length( tmp-str3 ) - length( pl-pfx ) )
        len-code3    = length( full-b-code )
      .
      define variable v-sum-char3 as character no-undo .
      assign
        sum3 = 0
      .
      do i3 = 1 to len-code3 by 2
      :
        assign
          v-sum-char3 = substr(full-b-code, len-code3 - i3 + 1, 1)
        .
        if v-sum-char3 < "0"
        or v-sum-char3 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum3 = sum3 + integer(v-sum-char3)
        .
      end.
      if varcont3 = yes then do:
        assign
          sum3 = sum3 * 3
        .
        do i3 = 2 to len-code3 by 2
        :
          assign
            v-sum-char3 = substr(full-b-code, len-code3 - i3 + 1, 1)
          .
          if v-sum-char3 < "0"
          or v-sum-char3 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum3 = sum3 + integer(v-sum-char3)
          .
        end.
        if varcont3 = yes then do:
           if sum3 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum3 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable v-cntxp-doc-prt as logical no-undo .
define buffer new-prn_shop for ub.shop.
define buffer new-prn_store for ub.store.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output tmp-var
  ,output type-par
  ) no-error .
case p-obj-type :
  when 'скл':U then do:
    find first new-prn_store where new-prn_store.obj-code = p-obj-code no-lock.
    assign
      v-cntxp-doc-prt         = (tmp-var = "yes") and new-prn_store.doc-prt
      .
  end.
  when 'маг':U then do:
    find first new-prn_shop where new-prn_shop.obj-code = p-obj-code no-lock.
    assign
      v-cntxp-doc-prt         = (tmp-var = "yes") and new-prn_shop.doc-prt
      .
  end.
end case.
define variable curr_cass as dec no-undo.
define variable dob-curr as char no-undo.
define variable Term_Node as logical no-undo.
define variable ListProdBc as char no-undo.
define variable counter as int init 1 no-undo.
define variable Rubl_Coeff as decimal init 0 no-undo.
define variable v-doc-code as character initial "":U no-undo .
define variable v-part-code as character initial "":U no-undo .
define variable v-promo-code as character no-undo .
define variable v-ActionId as int64 no-undo .
define variable v-db-num as integer no-undo .
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable ini-par as character no-undo.
define variable s       as character no-undo.
define variable v-today as date      no-undo.
define variable v-rb-is-base as logical no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable base-type as character no-undo .
define buffer buf_rep_currency for ub.currency.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sel AUTO-GO DEFAULT
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-unit DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.
DEFINE VARIABLE CurrTicket AS CHARACTER FORMAT "X(256)":U INITIAL "Не печатать"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Не печатать"
     DROP-DOWN-LIST
     SIZE 27 BY 1 NO-UNDO.
DEFINE VARIABLE f-tick-ps AS CHARACTER FORMAT "X(8)":U
     LABEL "PS"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE rate AS DECIMAL FORMAT "->>,>>9.99<<":U INITIAL 0
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE unit-type AS CHARACTER FORMAT "X(3)":U INITIAL "шт"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE bcode-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Основной бар-код", "main",
"Бар-код партии", "part",
"Неосн. бар-код", "subs"
     SIZE 19.5 BY 3 NO-UNDO.
DEFINE VARIABLE List-Sort-Type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По коду", "1",
"По артикулу", "2",
"В порядке ввода", "3"
     SIZE 26 BY 2.67 NO-UNDO.
DEFINE VARIABLE price-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "текущий прайс-лист", "price",
"цена документа", "doc",
"прайс-лист на дату документа", "doc-pr"
     SIZE 31.38 BY 2.63 NO-UNDO.
DEFINE VARIABLE qnty-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "по одному на товар", "один",
"по остаткам на объекте", "остаток",
"по кол-ву из списка", "список",
"по документу", "документ"
     SIZE 31 BY 4.17 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.25 BY 5.42.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.25 BY 5.5.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 4.75.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 2.5.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 3.67.
DEFINE RECTANGLE RECT-Sort
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 29 BY 4.13.
DEFINE VARIABLE OnlyChgPrice AS LOGICAL INITIAL no
     LABEL "только с измен. ценой"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.
DEFINE VARIABLE TickOnNulSale AS LOGICAL INITIAL no
     LABEL "в т.ч. с нулевыми ценами"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .83 NO-UNDO.
DEFINE VARIABLE TickOnSign AS LOGICAL INITIAL no
     LABEL "детально (по признакам)"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.
DEFINE VARIABLE TickOnWieght AS LOGICAL INITIAL no
     LABEL "в т.ч. на весовой товар"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.
DEFINE FRAME Tickets
     b-sel AT ROW 1 COL 2
     b-help AT ROW 1 COL 54
     qnty-type AT ROW 3.33 COL 32 NO-LABEL
     CurrTicket AT ROW 3.5 COL 3 NO-LABEL
     bcode-type AT ROW 5.17 COL 3 NO-LABEL
     unit-type AT ROW 7.17 COL 21.5 COLON-ALIGNED NO-LABEL
     b-unit AT ROW 7.17 COL 27.5
     TickOnWieght AT ROW 9 COL 3
     price-type AT ROW 9.04 COL 32 NO-LABEL
     TickOnNulSale AT ROW 10 COL 3
     TickOnSign AT ROW 11 COL 3
     rate AT ROW 11.83 COL 37.5 COLON-ALIGNED
     OnlyChgPrice AT ROW 12 COL 3 WIDGET-ID 2
     List-Sort-Type AT ROW 14.42 COL 3.75 NO-LABEL
     f-tick-ps AT ROW 15 COL 41.5 COLON-ALIGNED
     "Тип ценника (этикетки)" VIEW-AS TEXT
          SIZE 24 BY .67 AT ROW 2.67 COL 5
     "Количества" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 2.67 COL 39.5
     "Цены" VIEW-AS TEXT
          SIZE 6 BY .67 AT ROW 8.08 COL 41.63
     "Сортировка" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 13.54 COL 7.63
     RECT-3 AT ROW 8.5 COL 2
     RECT-Sort AT ROW 13.25 COL 2
     RECT-4 AT ROW 2.33 COL 2
     RECT-5 AT ROW 4.83 COL 2
     RECT-1 AT ROW 2.33 COL 31
     RECT-2 AT ROW 7.75 COL 31
     SPACE(1.24) SKIP(4.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-sel.
ASSIGN
       FRAME Tickets:SCROLLABLE       = FALSE
       FRAME Tickets:HIDDEN           = TRUE.
ASSIGN
       b-unit:HIDDEN IN FRAME Tickets           = TRUE.
ASSIGN
       unit-type:HIDDEN IN FRAME Tickets           = TRUE.
ON WINDOW-CLOSE OF FRAME Tickets
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-sel IN FRAME Tickets
DO:
  assign
    CurrTicket
    TickOnWieght
    TickOnSign
    TickOnNulSale
    qnty-type
    price-type
    unit-type
    bcode-type
    rate
    List-Sort-Type
    f-tick-ps
    OnlyChgPrice
    .
  assign
    TickOnN   = TickOnNulSale
    TickOnW   = TickOnWieght
    TickOnS   = TickOnSign
    QntyType  = qnty-type
    PriceType = price-type
    UnitName  = unit-type
    BCodeType = bcode-type
    curr-rate = rate
    List-sort = List-Sort-TYpe
    TickPS    = f-tick-ps
    OnlyChgPr = OnlyChgPrice
    .
  if CurrTicket <> "Не печатать" then
      do:
          DO i = 1 TO 1000:
              assign s = string( "Ticket" + trim( string( i, ">>>9" ) ) ).
              GET-KEY-VALUE SECTION "REP-SETS" KEY s VALUE ini-par.
              if entry( 1, ini-par, "#" ) = CurrTicket then
                  LEAVE.
          END.
          assign
              TicketName = entry( 2, ini-par, "#" )
              ScalePrice = decimal( entry( 3, ini-par, "#" ) )
              TicketType = entry( 4, ini-par, "#" )
              .
      end.
  else
      assign TicketName = "".
END.
ON CHOOSE OF b-unit IN FRAME Tickets
DO:
    def var unit-rec as recid no-undo.
    run ref/units.w ( input parparentproc, input yes, output unit-rec ).
    if unit-rec = ? then
        do:
            apply "entry" to unit-type in frame Tickets.
            return no-apply.
        end.
    FIND ub.units WHERE recid (ub.units) = unit-rec NO-LOCK.
    assign unit-type = ub.units.unit-name.
    DISPLAY unit-type with frame Tickets.
END.
ON VALUE-CHANGED OF bcode-type IN FRAME Tickets
DO:
    assign bcode-type.
    assign TickOnSign = no.
    DISPLAY TickOnSign WITH FRAME Tickets.
    if bcode-type <> "part" AND v-cntxp-doc-prt AND Action <> "BCODE" AND Action <> "LIST" and Action <> "PROD-BC" then
        ENABLE TickOnSign WITH FRAME Tickets.
    else
        DISABLE TickOnSign WITH FRAME Tickets.
    if bcode-type = "main" AND (Action = "SCALES" OR tick-w) then
        assign TickOnWieght = yes.
    else
        assign TickOnWieght = no.
    DISPLAY TickOnWieght WITH FRAME Tickets.
    if bcode-type = "main" AND Action = "ALL" then
        ENABLE TickOnWieght WITH FRAME Tickets.
    else
        DISABLE TickOnWieght WITH FRAME Tickets.
    CASE bcode-type:
      WHEN "main" THEN do:
        if qnty-type:enable ( "по остаткам на объекте" ) then.
        if Action = "DOCUMENT" then do:
          if qnty-type:enable ( "по документу" )  then.
          if price-type:enable ( "цена документа" )  then.
          if price-type:enable ( "прайс-лист на дату документа" )  then.
        end.
        else do:
          if qnty-type:disable ( "по документу" )  then.
          if price-type:disable ( "цена документа" )  then.
          if price-type:disable ( "прайс-лист на дату документа" )  then.
        end.
        if Action = "LIST" then do:
          if qnty-type:enable ( "по кол-ву из списка" )  then.
        end.
        else do:
          if qnty-type:disable ( "по кол-ву из списка" )  then.
        end.
        DISABLE unit-type b-unit WITH FRAME Tickets.
        HIDE unit-type b-unit IN FRAME Tickets.
      end.
      WHEN "part" THEN do:
        if qnty-type:enable ( "по остаткам на объекте" )  then.
        if qnty-type:disable ( "по кол-ву из списка" )  then.
        if price-type:disable ( "цена документа" )  then.
        if price-type:disable ( "прайс-лист на дату документа" )  then.
        if Action = "DOCUMENT" then  do:
          if qnty-type:enable ( "по документу" )  then.
        end.
        else do:
          if qnty-type:disable ( "по документу" )  then.
        end.
        DISABLE unit-type b-unit WITH FRAME Tickets.
        HIDE unit-type b-unit IN FRAME Tickets.
      end.
      WHEN "subs" THEN do:
        if qnty-type:disable ( "по остаткам на объекте" )  then.
        if Action = "DOCUMENT" then do:
          if qnty-type:enable ( "по документу" )  then.
        end.
        else do:
          if qnty-type:disable ( "по документу" )  then.
        end.
        if price-type:disable ( "цена документа" )  then.
        if price-type:disable ( "прайс-лист на дату документа" )  then.
        ENABLE unit-type b-unit WITH FRAME Tickets.
      end.
    END CASE.
    if doctype = "bb-list" then do:
      hide
      TickOnSign
      in frame Tickets .
    end.
END.
ON VALUE-CHANGED OF price-type IN FRAME Tickets
DO:
  assign price-type .
  if v-rb-is-base = true
     and v-base-code <> 0
     and DocType <> "price"
  then do:
    if price-type = "doc" or price-type = "doc-pr" then do:
      HIDE rate IN FRAME Tickets.
    end.
    else do:
      ENABLE rate WITH FRAME Tickets.
    end.
  end.
END.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Tickets:PARENT eq ?
THEN FRAME Tickets:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Tickets
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
on choose of b-help in frame Tickets
do:
  apply "help":u to frame Tickets .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Tickets:width - 0.3
                fh            = frame Tickets:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
  find first buf_rep_currency no-lock
    where buf_rep_currency.curr-code = v-base-code
    no-error .
    if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
                else base-type = "б.в." .
  DO i = 1 TO 1000:
      assign s = string( "Ticket" + trim( string( i, ">>>9" ) ) ).
      GET-KEY-VALUE SECTION "REP-SETS" KEY s VALUE ini-par.
      if ini-par = ? then
          LEAVE.
      else
          if CurrTicket:ADD-LAST( entry( 1, ini-par, "#" ) ) then.
  END.
  if v-rb-is-base = true
    and v-base-code <> 0
  then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-today
  )  .
    run proc-cur-rate( input p-obj-type, input p-obj-code, output Rubl_Coeff ).
    assign
      rate = Rubl_Coeff
    .
  end.
  assign
    List-Sort-Type:radio-buttons = "По коду"         + chr(44) + "b-code":U + chr(44) +
                                   "По артикулу"     + chr(44) + "artic":U +   chr(44) +
                                   "По наименованию" + chr(44) + "gds-name":U + chr(44) +
                                   "В порядке ввода" + chr(44) + "order-num":U
  .
  RUN enable_UI.
  if v-rb-is-base = true then do:
    if v-base-code = 0 OR (Action = "DOCUMENT" AND DocType <> "price" AND price-type = "doc" AND price-type = "doc-pr")
    then do:
      HIDE rate IN FRAME Tickets.
    end.
  end.
  else do:
    HIDE rate IN FRAME Tickets.
  end.
  if doctype = "bb-list" then do:
    assign
      qnty-type = "список"
      TickOnSign = yes
    .
    display
      qnty-type
      with frame Tickets
      .
    hide
    bcode-type
    in frame Tickets .
  end.
  if action <> "DOCUMENT"
    or ( action = "DOCUMENT":U
         and doctype <> "price":U
       )
  then do:
    disable
      OnlyChgPrice
      with frame Tickets .
  end.
  if action = "PROD-BC" then do:
    DISABLE
    List-Sort-Type
    with frame Tickets.
    if DocType = "main" then do:
      if bcode-type:disable ( "Бар-код партии" )  then.
      if bcode-type:disable ( "Неосн. бар-код" )  then.
    end.
    if DocType = "part" then do:
      if bcode-type:disable ( "Основной бар-код" )  then.
      if bcode-type:disable ( "Неосн. бар-код" )  then.
    end.
    if DocType = "subs" then do:
      if bcode-type:disable ( "Бар-код партии" )  then.
      if bcode-type:disable ( "Основной бар-код" )  then.
    end.
  end.
  else do:
    if Action <> "DOCUMENT"
    AND Action <> "LIST"
    AND Action <> "ALL" then  do:
      if bcode-type:disable ( "Бар-код партии" )  then.
      if bcode-type:disable ( "Неосн. бар-код" )  then.
    end.
  end.
  APPLY "VALUE-CHANGED" TO bcode-type IN FRAME Tickets.
  WAIT-FOR GO OF FRAME Tickets.
END.
RUN disable_UI.
PROCEDURE cust :
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Tickets.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY qnty-type CurrTicket bcode-type TickOnWieght price-type TickOnNulSale
          rate List-Sort-Type f-tick-ps
      WITH FRAME Tickets.
  ENABLE b-sel b-help RECT-3 RECT-Sort RECT-4 RECT-5 RECT-1 RECT-2 qnty-type
         CurrTicket bcode-type price-type TickOnNulSale rate OnlyChgPrice
         List-Sort-Type f-tick-ps
      WITH FRAME Tickets.
  VIEW FRAME Tickets.
END PROCEDURE.
