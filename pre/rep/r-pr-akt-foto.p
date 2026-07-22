block-level on error undo, throw.
define input parameter parparentproc     as handle           no-undo.
define input parameter rec_id            as recid            no-undo.
define input parameter p-doc-type        as character        no-undo.
define input parameter p-price-celection as integer          no-undo.
define input parameter p-print-null-qnty as logical          no-undo.
define input parameter p-sort-by-group   as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: a8e2cf75ddf6, 2506, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июл 08 17:09:06 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-pr-akt-foto.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-pr-akt-foto.p $":U .
define variable vss-description as character no-undo init "Печать акта и протокола переоценки".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
def buffer old-list    for price-list.
def buffer buf_clients for clients.
def shared var      sort-gr              as logical no-undo.
define variable v-dircode1 as character no-undo .
define variable v-dircode2           as character no-undo .
define variable v-tthd          as handle     no-undo.
define variable v-picture as character no-undo.
define VARIABLE vPar-val             as character no-undo .
define VARIABLE vPar-type            as character no-undo .
define VARIABLE v-ph-dir             as character no-undo .
define VARIABLE v-path-db-num        as character no-undo .
define VARIABLE v-from-db-num        as character no-undo .
define variable v-param-types        as character no-undo.
define variable v-value-char         as character no-undo.
define variable v-val-date           as date      no-undo.
define variable v-val-decimal        as decimal   no-undo.
define variable v-val-integer        as integer   no-undo.
define variable v-val-logical        as logical   no-undo.
define variable Path-To-Dir-Pictures as character no-undo .
define variable v-value              as character no-undo.
define variable v-type               as character no-undo.
    define variable v-kol as integer.
    define variable v-procent as decimal.
def        var      v-old-sum            as decimal no-undo.
def        var      v-new-sum            as decimal no-undo.
def        var      v-del-sum            as decimal no-undo.
def        var      v-up-fact            as decimal no-undo.
def        var      propis               as char    no-undo.
def        var      abbr                 as char    no-undo.
def        var      v-single-line        as char    no-undo.
def        var      v-b-code             as char    no-undo.
def        var      v-line-counter       as int     no-undo.
def        var      v-good-line-counter  as int     no-undo.
define     variable p-procent            as decimal.
def        var      sym1                 as char    init ":" no-undo.
def        var      sym2                 as char    init ":" no-undo.
def        var      sym3                 as char    init ":" no-undo.
def        var      sym4                 as char    init ":" no-undo.
def        var      sym5                 as char    init ":" no-undo.
def        var      sym6                 as char    init ":" no-undo.
def        var      sym7                 as char    init ":" no-undo.
def        var      sym8                 as char    init ":" no-undo.
def        var      sym9                 as char    init ":" no-undo.
def        var      sym10                as char    init ":" no-undo.
def        var      Log-Res1             as logical no-undo.
def        var      v-print-cost-price   as logical no-undo.
define     variable akt                  as char.
define     variable prik                 as char.
def        var      v-shift-down         as logical init yes no-undo.
def        var      v-print-group        as logical init yes no-undo.
define variable  v-price-sale as decimal.
define variable   v-gds-price-sale as decimal.
define variable v-price-sum-list as decimal.
define variable v-price-sum-last as decimal.
def        var      v-price-doc-doc-num  like price-doc.doc-num no-undo.
def        var      v-price-doc-doc-date like price-doc.doc-date no-undo.
define variable p-number as integer init 0.
def        var      v-main-price-sale    like price-list.price-sale no-undo.
define     variable g#report-num         as integer no-undo.
define     variable g#quest-print        as logical no-undo.
define     variable g#log                as logical no-undo.
define     variable v-rb-is-base         as logical no-undo.
define stream outstr-html.
def stream AktStr .
define variable v-report-name-html  as char.
define variable v-full-path-RepView as char.
function fnc-DD-MM-YYYY returns character
    (input p-dat-date as date) forward.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character) forward.
run get-full-path-RepViewer(output v-full-path-RepView).
run get-report-num in parParentProc(output g#report-num).
run get-quest-print in parparentproc (
    output g#quest-print
).
run define-full-path-Report(input g#report-num, output v-report-name-html).
run create-file(v-report-name-html).
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
find first price-doc no-lock
    where recid(price-doc) = rec_id .
if not available price-doc
    then
do:
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
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output Log-Res1
    )  .
end.
if ( price-doc.status_ = 'акт':U )
    or Log-Res1
    then
do:
    if  p-price-celection = 2
        then
    do:
        assign
            v-print-cost-price = TRUE .
    end.
    else
    do:
        assign
            v-print-cost-price = FALSE .
    end.
end.
find    trn-doc no-lock
    where trn-doc.doc-code = price-doc.doc-num
    no-error.
do:
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8'.
    put stream OutStr-html unformatted
        "<!DOCTYPE HTML>" skip
        ' <html>' skip
        '  <head>' skip
        '   <meta charset="utf-8">' skip
        '    <style type="text/css">' skip
        '      table ' + chr(123) + ' border-collapse: collapse; font-size: 9pt; table-layout: fixed; width: 1157px; padding: 14px; ' + chr(125) skip
        '      td ' + chr(123) ' border: 1px black ridge; word-wrap:break-word; ' + chr(125) skip
        '      htm' skip
        '      .rotate ' + chr(123) skip
        '        -webkit-transform: rotate(-90deg);' skip
        '        -moz-transform: rotate(-90deg);' skip
        '        -ms-transform: rotate(-90deg);' skip
        '        -o-transform: rotate(-90deg);' skip
        '        transform: rotate(-90deg);' skip
        '        -webkit-transform-origin: 50% 50%;' skip
        '        -moz-transform-origin: 50% 50%;' skip
        '        -ms-transform-origin: 50% 50%;' skip
        '        -o-transform-origin: 50% 50%;' skip
        '        transform-origin: 50% 50%;' skip
        '        filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);' skip
        '          ' + chr(125) skip
        '            th' + ' ' + chr(123) skip
        '            border: 1px black solid;' skip
        '            word-wrap: break-word;' skip
        '          ' + chr(125) skip
        '   </style>' skip
        '  </head>' skip
        .
end.
    put stream OutStr-html unformatted
        ' <body>' skip
        '   <table name="Лист1" fit_to_page="true" orientation="landscape" outline_below="false">' skip
        '     <thead>' skip
        '       <tr class="set_columns">' skip
        '         <td style="width: 80px; border: none;"></td>' skip
        '         <td style="width: 80px; border: none;"></td>' skip
        '         <td style="width: 200px; border: none;"></td>' skip
        '         <td style="width: 200px; border: none;"></td>' skip
          '         <td style="width: 80px; border: none;"></td>' skip
        '         <td style="width: 80px; border: none;"></td>' skip
        '         <td style="width: 80px; border: none;"></td>' skip
        '         <td style="width: 78px; border: none;"></td>' skip
        '         <td style="width: 78px; border: none;"></td>' skip
        '         <td style="width: 78px; border: none;"></td>' skip
        '         <td style="width: 78px; border: none;"></td>' skip
        '       </tr>' skip
        .
    do:
        find    buf_clients no-lock
            where buf_clients.obj-type = 'орг':U
            and buf_clients.obj-code = price-doc.host-code
            .
        put stream OutStr-html unformatted
            '       <tr>' skip
            '         <td colspan="10" style="border: none; height: 14px;  text-align: center; font-size: 10pt; font-weight: bold">' +   buf_clients.obj-name  + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            '<tr>' skip
            '         <td colspan="10" style="border: none; height: 14px;  text-align: center; font-size: 10pt; font-weight: bold">   А К Т  переоценки  по  остаткам   '
            +  ( if available trn-doc then string( "по документу N " + trn-doc.doc-code )
            else " " ) + "  в  " + clients.obj-name  +    '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            '       <tr>' skip
            '         <td colspan="10" style="border: none; height: 14px;  text-align: left; font-size: 10pt; font-weight: bold">Номер ' + price-doc.doc-num
            "  от  " + fnc-DD-MM-YYYY(price-doc.doc-date )   + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            '       <tr>' skip
            '         <td colspan="10" style="border: none; height: 14px;  text-align: left; font-size: 10pt; font-weight: bold">Дата печати: ' +   fnc-DD-MM-YYYY(today )   + '</td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '         <td style="border: none"></td>' skip
            '</tr>' skip
            '     </thead>' skip
            .
    end.
    if  v-print-cost-price = no then
    do:
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 60px;">' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Код</th>' skip
            '         <th     style="background-color:#ffffcc; text-align: center">Артикул</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Название товара</th>' skip
                        '         <th  style="background-color:#ffffcc; text-align: center">Фото товара</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Количество</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Старая продажная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Старая сумма продажной цены</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая продажная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая сумма продажной цены</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Процент разницы</th>' skip
            '</tr>' skip
            .
        output stream OutStr-html close.
    end.
    else
    do:
        put stream OutStr-html unformatted
            '     <tbody>' skip
            '       <tr style="height: 60px;">' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Код</th>' skip
            '         <th     style="background-color:#ffffcc; text-align: center">Артикул</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Название товара</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Фото товара</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Количество</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Последняя учетная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Сумма учетных цен</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая продажная цена</th>' skip
            '         <th  style="background-color:#ffffcc; text-align: center">Новая сумма продажной цены</th>' skip
            '         <th   style="background-color:#ffffcc; text-align: center">Процент разницы</th>' skip
            '</tr>' skip
            .
        output stream OutStr-html close.
    end.
    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8'.
    if p-sort-by-group = yes
        then
    do:
        for each price-list no-lock
            where price-list.doc-num = price-doc.doc-num
            , each goods no-lock
            where goods.artic     = price-list.artic
            and goods.prod-type = price-list.prod-type
            and goods.prod-code = price-list.prod-code
            break by goods.grp-name by goods.artic descending
            :
            assign
                v-print-group = (if first-of (goods.grp-name) then yes else no)
                .
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            find first bar-code no-lock
                 where bar-code.b-code = price-list.b-code
            .
            if bar-code.unit-cli = goods.unit-base
            then do:
                assign
                    v-code-is-main = yes
                .
            end.
            else do:
                assign
                    v-code-is-main = no
                .
            end.
            if not (v-code-is-main = yes)
            then do:
                assign
                    v-not-main-unit-cli       = bar-code.unit-cli
                    v-not-main-cli-base-rate  = bar-code.cli-base-rate
                    v-not-main-b-code         = bar-code.b-code
                .
            end.
            find first gds-prt no-lock
                 where gds-prt.node-code = bar-code.node-code
            .
            assign
              v-gds-prt-node-name =
              ( if gds-prt.upper-code = goods.prt-root
                then if bar-code.in-code = ''
                    then goods.gds-name
                    else bar-code.in-code + '    ' + bar-code.part-code
                else
                        '    ' + gds-prt.f-name
              )
            .
            run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Определили имя товара со шкалой ( "
                                                + dtm-char(v-gds-prt-node-name)
                                                + " )").
            find first gds-obj no-lock
                 where gds-obj.obj-type  = price-list.obj-type
                   and gds-obj.obj-code  = price-list.obj-code
                   and gds-obj.prod-type = price-list.prod-type
                   and gds-obj.prod-code = price-list.prod-code
                   and gds-obj.artic     = price-list.artic
            no-error.
            if available gds-obj
            then do:
                assign
                    v-gds-obj-last-price = ( if v-rb-is-base = yes then gds-obj.last-base else gds-obj.last-rubl )
                .
                if v-gds-obj-last-price = ?
                then do:
                    assign
                        v-gds-obj-last-price = 0
                    .
                end.
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Нашли товар ( "
                                + string(gds-obj.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Определили цену закупки ( "
                                + dtm-char(string(v-gds-obj-last-price)) + " )"
                                                    ).
            end.
            else do:
                assign
                    v-gds-obj-last-price = 0
                .
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Не нашли товара ( "
                                + string(price-list.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Назначили цену закупки ( 0 )"
                                                    ).
            end.
            find first gds-prt no-lock
                 where gds-prt.upper-code = goods.prt-root
            .
            assign
                v-gds-prt-node-code = gds-prt.node-code
            .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  price-list.obj-type
  ,input  price-list.obj-code
  ,input  price-list.b-code
  ,input  0
  ,input  price-list.fact-order
  ,output v-price-list-doc-num
  ,output v-price-list-price-sale
  ,output v-price-list-road-tax
  ,output v-price-list-excise
  )  .
            if v-price-list-price-sale = ?
            then do:
                assign
                    v-price-list-price-sale = 0
                .
            end.
            if v-price-list-road-tax = ?
            then do:
                assign
                    v-price-list-road-tax = 0
                .
            end.
            assign
                v-price-list-price-sale_old = v-price-list-price-sale
            .
            run writelog in this-procedure (log-file-name, 4,
                                                        "R-AKT.i   Определили продажную цену из прайс-листа ( "
                                                        + dtm-char(string(v-price-list-price-sale)) + " )"
                                                ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  bar-code.node-code
  ,output v-price-list-b-code
  )  .
            find first bar-code no-lock
                 where bar-code.b-code = v-price-list-b-code
            .
            accumulate bar-code.b-code ( count ) .
            if v-code-is-main = yes
                then
            do:
                accumulate ( ( price-list.price-sale - v-price-list-price-sale_old ) * price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                    ( price-list.doc-qnty * price-list.price-sale ) (total)
                    ( price-list.doc-qnty * v-gds-obj-last-price ) (total) .
                run print-line-fact in this-procedure.
            end.
        end.
    end.
    else
    do:
        for each price-list no-lock
            where price-list.doc-num = price-doc.doc-num
            , each goods no-lock
            where goods.artic     = price-list.artic
            and goods.prod-type = price-list.prod-type
            and goods.prod-code = price-list.prod-code
            break by goods.artic descending
            :
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
            find first bar-code no-lock
                 where bar-code.b-code = price-list.b-code
            .
            if bar-code.unit-cli = goods.unit-base
            then do:
                assign
                    v-code-is-main = yes
                .
            end.
            else do:
                assign
                    v-code-is-main = no
                .
            end.
            if not (v-code-is-main = yes)
            then do:
                assign
                    v-not-main-unit-cli       = bar-code.unit-cli
                    v-not-main-cli-base-rate  = bar-code.cli-base-rate
                    v-not-main-b-code         = bar-code.b-code
                .
            end.
            find first gds-prt no-lock
                 where gds-prt.node-code = bar-code.node-code
            .
            assign
              v-gds-prt-node-name =
              ( if gds-prt.upper-code = goods.prt-root
                then if bar-code.in-code = ''
                    then goods.gds-name
                    else bar-code.in-code + '    ' + bar-code.part-code
                else
                        '    ' + gds-prt.f-name
              )
            .
            run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Определили имя товара со шкалой ( "
                                                + dtm-char(v-gds-prt-node-name)
                                                + " )").
            find first gds-obj no-lock
                 where gds-obj.obj-type  = price-list.obj-type
                   and gds-obj.obj-code  = price-list.obj-code
                   and gds-obj.prod-type = price-list.prod-type
                   and gds-obj.prod-code = price-list.prod-code
                   and gds-obj.artic     = price-list.artic
            no-error.
            if available gds-obj
            then do:
                assign
                    v-gds-obj-last-price = ( if v-rb-is-base = yes then gds-obj.last-base else gds-obj.last-rubl )
                .
                if v-gds-obj-last-price = ?
                then do:
                    assign
                        v-gds-obj-last-price = 0
                    .
                end.
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Нашли товар ( "
                                + string(gds-obj.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Определили цену закупки ( "
                                + dtm-char(string(v-gds-obj-last-price)) + " )"
                                                    ).
            end.
            else do:
                assign
                    v-gds-obj-last-price = 0
                .
                run writelog in this-procedure (log-file-name, 4, "R-AKT.i   Не нашли товара ( "
                                + string(price-list.artic) + " )" + " на объекте ( "
                                + price-list.obj-type + string(price-list.obj-code) + " ). Назначили цену закупки ( 0 )"
                                                    ).
            end.
            find first gds-prt no-lock
                 where gds-prt.upper-code = goods.prt-root
            .
            assign
                v-gds-prt-node-code = gds-prt.node-code
            .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  price-list.obj-type
  ,input  price-list.obj-code
  ,input  price-list.b-code
  ,input  0
  ,input  price-list.fact-order
  ,output v-price-list-doc-num
  ,output v-price-list-price-sale
  ,output v-price-list-road-tax
  ,output v-price-list-excise
  )  .
            if v-price-list-price-sale = ?
            then do:
                assign
                    v-price-list-price-sale = 0
                .
            end.
            if v-price-list-road-tax = ?
            then do:
                assign
                    v-price-list-road-tax = 0
                .
            end.
            assign
                v-price-list-price-sale_old = v-price-list-price-sale
            .
            run writelog in this-procedure (log-file-name, 4,
                                                        "R-AKT.i   Определили продажную цену из прайс-листа ( "
                                                        + dtm-char(string(v-price-list-price-sale)) + " )"
                                                ).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  bar-code.node-code
  ,output v-price-list-b-code
  )  .
            find first bar-code no-lock
                 where bar-code.b-code = v-price-list-b-code
            .
            accumulate bar-code.b-code ( count ) .
            if v-code-is-main = yes
                then
            do:
                accumulate ( ( price-list.price-sale - v-price-list-price-sale_old ) * price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty ) (total)
                    ( price-list.doc-qnty * v-price-list-price-sale_old ) (total)
                    ( price-list.doc-qnty * price-list.price-sale ) (total)
                    ( price-list.doc-qnty * v-gds-obj-last-price ) (total) .
                run print-line-fact in this-procedure.
            end.
        end.
    end.
do:
    put stream OutStr-html unformatted
        '</tbody>' skip
        '</body>'
        .
end.
if v-print-cost-price = no then
    assign v-procent =   (v-new-sum - v-old-sum) / v-old-sum * 100.
else
    assign v-procent =   (v-old-sum - v-new-sum) / v-new-sum * 100.
if v-print-cost-price = no then
do:
         if v-rb-is-base = yes
        then do:
            run rep/wp.p (
                  input parparentproc
                , input absolute( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) )
                , output propis
                , output abbr
            ) .
        end.
        else do:
            run rep/wp-rub.p (
                  input absolute( accum total ( ( price-list.price-sale - v-price-list-price-sale_old) * price-list.doc-qnty) )
                , output propis
                , output abbr
            ) .
            end.
    do:
        put stream OutStr-html unformatted
            '<body>'
            '<thead>'
            '       <tr >' skip
            '         <td colspan = "2 " style="display: yes; text-align:  right "></td>'  skip
            '         <td style="display: yes; text-align:  right "> Итого: </td>' skip
                        '         <td style="display: yes; text-align:  right "> </td>' skip
            '         <td style="display: yes; text-align:  right ">'  + if      v-kol   <> ?  then fnc-convert-dot-to-colon(   v-kol  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
            '         <td style="display: yes; text-align:  right "></td>' skip
            '         <td style="display: yes; text-align:  right ">'  + if     v-old-sum  <> ?  then fnc-convert-dot-to-colon( v-old-sum , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
            '         <td style="display: yes; text-align:  right "> </td>' skip
            '         <td style="display: yes; text-align:  right ">'  + if    v-new-sum   <> ?  then fnc-convert-dot-to-colon(  v-new-sum   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
            '         <td style="display: yes; text-align:  right ">'  + if     v-procent   <> ?  then fnc-convert-dot-to-colon(   v-procent  , "->>>>>>>9.9") + '</td>' else "?" + '</td>' skip
            '       </tr>' skip
            '       <tr >' skip
            '         <td colspan="10" style="border: none"></td>' skip
            '       </tr>' skip
            '       <tr >' skip
            '         <td colspan="3" style="border: none; height: 14px;  text-align: right; font-size: 10pt; font-weight: bold">Сумма переоценки: </td>' skip
            '         <td colspan = "7" STYLE="border: none; border-bottom: 1px solid black;   text-align: center">'  + propis + '</td>' skip
            '       </tr>' skip
            .
    end.
end.
else
do:
    put stream OutStr-html unformatted
        '<body>'
        '<thead>'
        '       <tr >' skip
        '         <td colspan = "3 " style="display: yes; border: 1px solid black ; text-align:  left; font-size: 10pt; font-weight: bold "> Итого: </td>' skip
        '         <td style="display: yes; text-align:  right; border: 1px solid black ; font-weight: bold ">'  + if      v-kol   <> ?  then fnc-convert-dot-to-colon(   v-kol  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
        '         <td style="display: yes; text-align:  right ; border: 1px solid black"></td>' skip
        '         <td style="display: yes; text-align:  right;  border: 1px solid black; font-weight: bold ">'  + if     v-old-sum  <> ?  then fnc-convert-dot-to-colon( v-old-sum , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
        '         <td style="display: yes; text-align:  right; border: 1px solid black "> </td>' skip
        '         <td style="display: yes; text-align:  right; border: 1px solid black; font-weight: bold ">'  + if    v-new-sum   <> ?  then fnc-convert-dot-to-colon(  v-new-sum   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
        '         <td style="display: yes; text-align:  right; border: 1px solid black; font-weight: bold ">'  + if     v-procent   <> ?  then fnc-convert-dot-to-colon(   v-procent  , "->>>>>>>9.9") + '</td>' else "?" + '</td>' skip
        '       </tr>' skip
        '       <tr >' skip
        '         <td colspan="9" style="border: none"></td>' skip
        '       </tr>' skip
        .
end.
do:
    put stream OutStr-html unformatted
           '       <tr >' skip
        '         <td colspan="10" style="border: none"></td>' skip
        '       </tr>' skip
        '       <tr >' skip
        '         <td colspan="2" style="border: none; height: 14px;  text-align: right; font-size: 10pt; font-weight: bold">Председатель комиссии: </td>' skip
        '         <td style="border: none; border-bottom: 1px solid black"></td>' skip
        '         <td style="border: none; border-bottom: 1px solid black"></td>' skip
        '         <td style="border: none"></td>' skip
        '         <td colspan="2" style="border: none; height: 14px;  text-align: left; font-size: 10pt; font-weight: bold">Главный бухгалтер:</td>' skip
        '         <td style="border: none; border-bottom: 1px solid black"></td>' skip
        '         <td style="border: none; border-bottom: 1px solid black"></td>' skip
        '       </tr>' skip
        .
end.
do:
    put stream OutStr-html unformatted
        '</thead>'
        '   </table>' skip
        '  </body>' skip
        ' </html>' skip
        .
    output stream OutStr-html close.
end.
procedure print-line-fact:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ph-dir':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  NO
  ,output vPar-val
  ,output vPar-type
  ) no-error .
     if vPar-val = "" then vPar-Val = "C:\temp". else vPar-Val = vPar-Val.
      run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
      delete object v-tthd.
         run gds-attr-value in this-procedure (
        input goods.gds-code
        ,input "image-list"
        ,output v-value
        ,output v-type) no-error.
      if v-value <> "" then
      do:
        if v-val-integer = 1 then
        do:
          Path-To-Dir-Pictures = vPar-val + "\gds\".
        end.
        else
        do:
          Path-To-Dir-Pictures = vPar-val + "\" + string(goods.gds-code).
        end.
      end.
    if v-value > '' then  do:
    v-picture =  substitute("&1\&2" ,Path-To-Dir-Pictures, entry(1,v-value) ) .
    end.
    else do:
    v-picture  = "".
    end.
    if not can-find( first gds-prt where gds-prt.upper-code = v-gds-prt-node-code )
        then
    do:
        if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty = yes )
            then
        do:
            if v-print-cost-price
                then
            do:
                v-price-sum-list =   ( price-list.doc-qnty * v-gds-obj-last-price ) .
                v-price-sum-last =    ( price-list.doc-qnty * price-list.price-sale ).
                p-procent  = ( price-list.price-sale - v-gds-obj-last-price ) / v-gds-obj-last-price * 100.
                v-old-sum = v-old-sum +  v-price-sum-list.
                v-new-sum = v-new-sum + v-price-sum-last.
                v-kol = v-kol +  price-list.doc-qnty .
                run writelog in this-procedure (log-file-name, 4, "Включена печать по учетным ценам").
                if p-sort-by-group = yes
                    then
                do:
                if v-print-group = yes then do:
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                        '         <td colspan="10" style="border: none; height: 14px;  text-align: left; font-size: 10pt; font-weight: bold">' +  goods.grp-name  + '</td>' skip
                        '</tr>' skip
                            .
                    end.
                    put stream OutStr-html unformatted
                        '       <tr level="2">' skip
                        '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                        '         <td style="display: yes; text-align:  right ">'  +        goods.gds-name + '</td>' skip
                           '<td>' skip
                        '<img src="' + v-picture + '"; alt="HTML5 Icon"  align="right" style="height:128px;  "/>'
                        ' </td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '       </tr>' skip
                        .
                end.
                else
                do:
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                        '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                        '         <td style="display: yes; text-align:  right ">'  +        goods.gds-name + '</td>' skip
                           '<td>'
                        '<img src="' + v-picture + '"; alt="HTML5 Icon" align="right" style="height:128px;  "/>'
                        ' </td>' skip
                                             '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '       </tr>' skip
                        .
                end.
            end.
            else
            do:
                  v-price-sum-last =    ( price-list.doc-qnty * price-list.price-sale )   .
                v-price-sum-list =    ( price-list.doc-qnty * v-price-list-price-sale_old ).
                p-procent  = ( price-list.price-sale - v-price-list-price-sale_old ) / v-price-list-price-sale_old * 100.
                v-old-sum = v-old-sum +  v-price-sum-list.
                v-new-sum = v-new-sum + v-price-sum-last.
                v-kol = v-kol +  price-list.doc-qnty .
                if p-sort-by-group = yes
                    then
                do:
                    if v-print-group = yes then
                    do:
                        put stream OutStr-html unformatted
                            '       <tr level="1">' skip
                            '         <td colspan="10" style="border: none; height: 14px;  text-align: left; font-size: 10pt; font-weight: bold">' +  goods.grp-name  + '</td>' skip
                            '</tr>' skip
                            .
                    end.
                    put stream OutStr-html unformatted
                        '       <tr level="2">' skip
                        '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                        '         <td style="display: yes; text-align:  right ">'  +        goods.gds-name + '</td>' skip
                        '<td>'
                        '<img src="' + v-picture + '" alt="HTML5 Icon" style="height:128px;  "/>'
                        ' </td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     v-price-list-price-sale_old   <> ?  then fnc-convert-dot-to-colon(  v-price-list-price-sale_old  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '       </tr>' skip
                        .
                end.
                else
                do:
                    put stream OutStr-html unformatted
                        '       <tr level="1">' skip
                        '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                        '         <td style="display: yes; text-align:  right ">'  +        goods.gds-name + '</td>' skip
                  '<td>'
                        '<img src="' + v-picture + '" alt="HTML5 Icon" style="height:128px;  "/>'
                        ' </td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     v-price-list-price-sale_old   <> ?  then fnc-convert-dot-to-colon(  v-price-list-price-sale_old  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                        '       </tr>' skip
                        .
                end.
            end.
        end.
    end.
    else
    do:
        if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty )
            then
        do:
            if v-print-cost-price = yes
                then
            do:
                v-price-sum-list =   ( price-list.doc-qnty * v-gds-obj-last-price ) .
                v-price-sum-last =   ( price-list.doc-qnty * price-list.price-sale ).
                p-procent  = ( price-list.price-sale - v-gds-obj-last-price ) / v-gds-obj-last-price * 100.
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                    '         <td style="display: yes; text-align:  right ">'  +        goods.gds-name + '</td>' skip
                       '<td>'
                        '<img src="' + v-picture + '" alt="HTML5 Icon" style="height:128px;  "/>'
                        ' </td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                    .
            end.
            else
            do:
                put stream OutStr-html unformatted
                    '       <tr level="1">' skip
                    '         <td style="display: yes; text-align: center ">'  + if goods.gds-code  <> ?  then fnc-convert-dot-to-colon( goods.gds-code , "->>>>>>>9") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  +  price-list.artic   + '</td>'  skip
                    '         <td style="display: yes; text-align:  right ">'  +        goods.gds-name + '</td>' skip
              '<td>'
                        '<img src="' + v-picture + '" alt="HTML5 Icon" style="height:128px;  "/>'
                        ' </td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if      price-list.doc-qnty  <> ?  then fnc-convert-dot-to-colon( price-list.doc-qnty , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if     price-list.price-sale   <> ?  then fnc-convert-dot-to-colon(  price-list.price-sale  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-list   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-list   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if    v-gds-obj-last-price   <> ?  then fnc-convert-dot-to-colon(  v-gds-obj-last-price   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if    v-price-sum-last   <> ?  then fnc-convert-dot-to-colon(  v-price-sum-last   , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '         <td style="display: yes; text-align:  right ">'  + if     p-procent   <> ?  then fnc-convert-dot-to-colon(   p-procent  , "->>>>>>>9.99") + '</td>' else "?" + '</td>' skip
                    '       </tr>' skip
                    .
            end.
        end.
    end.
end procedure.
run search-full-path-Report(input v-report-name-html).
run Report-Viewer(input v-full-path-RepView, input v-report-name-html).
 function fnc-DD-MM-YYYY returns character
(input p-dat-date as date):
    define variable result as character no-undo.
    define variable p-str-date as character no-undo.
    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").
        return p-str-date.
end function.
function fnc-convert-dot-to-colon returns character
    (input p-data as decimal, input p-accur as character):
    define variable result       as character no-undo.
    define variable v-str-result as character no-undo.
    p-data = round(p-data, 2).
    v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    return v-str-result.
end function.
procedure create-file:
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.
end procedure.
procedure search-full-path-Report:
    define input parameter p-file-name as character no-undo.
    if search(p-file-name) = ? then
    do:
        message "Не найден файл отчёта: " p-file-name view-as alert-box error.
    end.
    else
    do:
        p-file-name = search(p-file-name).
    end.
end procedure.
procedure define-full-path-Report:
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.
    p-file-name-rep-htm = session:temp-directory + "rpt" + string(p-rep-num) + ".html".
end procedure.
procedure Report-Viewer:
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.
    os-command no-wait value(p-full-path-RepView + " true " + search(p-file-name-rep-htm)).
end procedure.
procedure get-full-path-RepViewer:
    define output parameter p-fill-path-RepView as character no-undo.
    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.
