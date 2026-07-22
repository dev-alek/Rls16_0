block-level on error undo, throw.
define input parameter parparentproc     as handle           no-undo.
define input parameter rec_id            as recid            no-undo.
define input parameter p-doc-type        as character        no-undo.
define input parameter p-price-celection as integer          no-undo.
define input parameter p-print-null-qnty as logical          no-undo.
define input parameter p-sort-by-group   as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ord.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ord.p $":U .
define variable vss-description as character no-undo init "Печать акта о переоценке".
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    assign
        log-file-name = 'r-akt.log'
    .
    if log-file-name <> "":U
    then do:
        if search( 'r-akt.log' ) = ?
        then do:
            output to value( 'r-akt.log' ).
            output close.
        end.
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
    def var v-price-list-doc-num            like price-list.doc-num     no-undo.
    def var v-price-list-price-sale         like price-list.price-sale  no-undo.
    def var v-price-list-price-sale_old     like price-list.price-sale  no-undo.
    def var v-price-list-road-tax           like price-list.road-tax    no-undo.
    def var v-price-list-excise             like price-list.excise      no-undo.
    def var v-price-list-b-code             like bar-code.b-code        no-undo.
    def var v-gds-obj-last-price            like gds-obj.last-rubl      no-undo.
    def var v-gds-prt-node-code             like gds-prt.node-code      no-undo.
    def var v-gds-prt-node-name             like gds-prt.node-name      no-undo.
    def var v-code-is-main                  as logical                  no-undo.
    def var v-not-main-unit-cli             like bar-code.unit-cli      no-undo.
    def var v-not-main-cli-base-rate        like bar-code.cli-base-rate no-undo.
    def var v-not-main-b-code               like bar-code.cli-base-rate no-undo.
    def var v-taxname                       as char                     no-undo.
    def var v-tax                           as decimal  init 0          no-undo.
    def var v-tax-sum                       as decimal  init 0          no-undo.
    def var v-tax-parts-qnty                as decimal  init 0          no-undo.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do
on error undo, return error
:
def buffer buf_clients for clients.
def var v-single-line       as char    no-undo.
def var sym1  as char init "|"   no-undo.
def var sym2  as char init "|"   no-undo.
def var sym3  as char init "|"    no-undo.
def var sym4  as char init "|"   no-undo.
def var sym5  as char init "|"    no-undo.
def var sym6  as char init "|"    no-undo.
def var sym7  as char init "|"    no-undo.
def var sym8  as char init "|"    no-undo.
def var sym9  as char init "|"    no-undo.
def var sym10 as char init "|"    no-undo.
def var sym11  as char init "|"    no-undo.
def var sym12  as char init "|"    no-undo.
def var sym13  as char init "|"    no-undo.
def var sym14  as char init "|"    no-undo.
def var sum_before as decimal no-undo.
def var sum_after as decimal no-undo.
def var ucenka as decimal no-undo.
def var doocenka as decimal no-undo.
def var comments as char init "" no-undo.
def var string_counter as int init 0  no-undo.
def var serial_num as char init "" no-undo.
def var end_sum_before as decimal init 0 no-undo.
def var end_sum_after as decimal init 0 no-undo.
def var end_sum_ucenka as decimal init 0 no-undo.
def var end_sum_doocenka as decimal init 0 no-undo.
def var firm_name as char no-undo.
def stream AktStr .
def stream moreAtkStr.
def var Log-Resym1                as logical          no-undo.
def var v-price-doc-doc-num          like price-doc.doc-num     no-undo.
def var v-price-doc-doc-date         like price-doc.doc-date    no-undo.
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable v-rb-is-base        as logical      no-undo.
define frame Akt-Cost
      sym1                            no-label format "X(1)"             space(0)
      string_counter                  no-label format "99999"            space(0)
      sym2                            no-label format "X(1)"             space(0)
      goods.okdp                      no-label format "X(9)"             space(0)
      sym3                            no-label format "X(1)"             space(0)
      goods.gds-name                  no-label format "X(42)"            space(0)
      sym4                            no-label format "X(1)"             space(0)
      serial_num                      no-label format "X(6)"             space(0)
      sym5                            no-label format "X(1)"             space(0)
      goods.unit-base                 no-label format "x(7)"             space(0)
      sym6                            no-label format "X(1)"             space(0)
      price-list.doc-qnty             no-label format "->>>>>>>>9.<<"    space(0)
      sym7                            no-label format "X(1)"             space(0)
      price-list.price-prev           no-label format "->>,>>>,>>9.99"   space(0)
      sym8                            no-label format "X(1)"             space(0)
      sum_before                      no-label format "->>,>>>,>>9.99"   space(0)
      sym9                            no-label format "X(1)"             space(0)
      price-list.price-sale           no-label format "->>,>>>,>>9.99"   space(0)
      sym10                           no-label format "X(1)"             space(0)
      sum_after                       no-label format "->>,>>>,>>9.99"   space(0)
      sym11                           no-label format "X(1)"             space(0)
      ucenka                          no-label format "->,>>>,>>9.99"    space(0)
      sym12                           no-label format "X(1)"             space(0)
      doocenka                        no-label format "->>,>>>,>>9.99"   space(0)
      sym13                           no-label format "X(1)"             space(0)
      comments                        no-label format "X(10)"            space(0)
      sym14                           no-label format "X(1)"             space(0)
      header
        "+-----+---------+------------------------------------------+------+-------+-----------+-----------------------------------------------------------+----------------------------+----------+" skip
        "|     |         |                                          |      |       |           |               Стоимость, руб. , коп.                      |                            |          |" skip
        "|  N  |   Код   |                                          |      |       |           +-----------------------------+-----------------------------+                            |          |" skip
        "|     |         |            Наименование товара           |Серия |Ед.изм.|Количество |        До переоценки        |       После переоценки      |          Разница           |Примечание|" skip
        "| п/п |   ОКДП  |                                          |      |       |           +--------------+--------------+--------------+--------------+-------------+--------------|          |" skip
        "|     |         |                                          |      |       |           |     Цена     |    Сумма     |     Цена     |    Сумма     |   Уценка    |   Дооценка   |          |" skip
        "+-----+---------+------------------------------------------+------+-------+-----------+--------------+--------------+--------------+--------------+-------------+--------------+----------+" skip
      with width 187 down stream-io no-box no-underline no-labels .
if session :set-wait-state( "compiler" ) then.
run get-report-num in parparentproc (
    output g#report-num
).
run get-quest-print in parparentproc (
    output g#quest-print
).
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
find first price-doc no-lock
      where recid(price-doc) = rec_id .
if not available price-doc
then do:
    bell.
    message 'Порушена табличка "price-doc"(r-akt.p).'.
    return error.
end.
assign
    v-price-doc-doc-num  = price-doc.doc-num
    v-price-doc-doc-date = price-doc.doc-date
.
find    clients no-lock
  where clients.obj-code = price-doc.obj-code
    and clients.obj-type = price-doc.obj-type
.
if not available clients then
do:
    bell.
    message 'Порушена табличка "clients" (r-akt.p).'.
    return error.
end.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue-cast_print':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output Log-Resym1
    )  .
end.
assign
    v-single-line = fill("-", 197)
.
output stream AktStr to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size 62 .
find    buf_clients no-lock
  where buf_clients.obj-type = 'орг':U
    and buf_clients.obj-code = price-doc.host-code
no-error.
if available buf_clients
then do:
    assign  firm_name = buf_clients.obj-name.
end.
put stream AktStr
    "БНФ №ТОРГ-7.1" at 175 skip
    "Наименование организации : " firm_name format "x(42)"   skip
    "Подразделение : " clients.obj-name skip
    skip
.
put stream AktStr
    "АКТ" at 93 skip
    "О ПЕРЕОЦЕНКЕ ТОВАРОВ" at 84 skip
    "от '__' ____________ 20__ г." at 81 skip
    skip
.
put stream AktStr
chr(10)
chr(10)
    "Комиссия в составе: председатель ____________________________, члены комиссии _____________________________________________" at 37 skip
    "                                 (должность)       (Ф.И.О)                         (должность)             (Ф.И.О.)        " at 37 skip
    chr(10)
    "на основании _____________________________ произвела переоценку товара по ___________________ ценам" at 44 skip
.
        for each price-list no-lock
           where price-list.doc-num = price-doc.doc-num
          , each goods no-lock
           where goods.artic     = price-list.artic
             and goods.prod-type = price-list.prod-type
             and goods.prod-code = price-list.prod-code
        break by goods.grp-name by goods.artic descending
        :
             string_counter = string_counter + 1.
             sum_before = price-list.price-prev * price-list.doc-qnty.
             sum_after = price-list.price-sale * price-list.doc-qnty.
             if price-list.price-prev > price-list.price-sale then do:
                 ucenka = -(price-list.price-prev - price-list.price-sale).
                 doocenka = 0.
                 end_sum_ucenka = end_sum_ucenka + ucenka.
             end.
             else do:
                 doocenka = price-list.price-sale - price-list.price-prev.
                 end_sum_doocenka = end_sum_doocenka + doocenka.
                 ucenka = 0.
             end.
             end_sum_before = end_sum_before + sum_before.
             end_sum_after = end_sum_after + sum_after.
             display stream AktStr
             sym1 string_counter sym2 goods.okdp sym3 goods.gds-name sym4 serial_num sym5 goods.unit-base sym6 price-list.doc-qnty sym7
             price-list.price-prev sym8 sum_before sym9 price-list.price-sale sym10 sum_after sym11 ucenka sym12 doocenka sym13 comments sym14
             with frame Akt-Cost.
        end.
       put stream aktstr
         "+-----------------------------------------------------------------+-------+-----------+--------------+--------------------------------------------+-------------+--------------+----------+" skip
         "|                                                          Итого :|    X  |     X     |       X      |"  end_sum_before format "->>,>>>,>>9.99"  "|      X       |" end_sum_after format "->>,>>>,>>9.99" "|" end_sum_ucenka format "->,>>>,>>9.99" "|"   end_sum_doocenka format "->>,>>>,>>9.99" "|          |" skip
         "+-----------------------------------------------------------------+-------+-----------+--------------+--------------+--------------+--------------+-------------+--------------+----------+" skip
       .
    put stream AktStr skip(5)
               "  Председатель комиссии :   ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "skip
               "          Члены комиссии: "skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "skip
               skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "
               skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "
               skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      " skip
               "Материально ответственное" skip
               "                   лицо :"skip
               "                            ___________  _____________  ____________________"skip
               "                            (должность)    (подпись)          (Ф.И.О.)      "
               skip .
output stream AktStr close.
if session :set-wait-state( "" ) then.
if g#quest-print = false
then do:
  run adecomm/_osprint.p ( ?, string( session:temp-directory + "rpt" + string( g#report-num ) ),
                                      7, (if 4 >= 8 then 2 else 0), 0, 0,
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
