block-level on error undo, throw.
define input parameter parparentproc        as widget-handle    no-undo.
define input parameter p-fbrhist-handle     as widget-handle    no-undo.
define input parameter p-kitchen-type       as character        no-undo.
define input parameter p-kitchen-code       as integer          no-undo.
define input parameter p-res-type           as character        no-undo.
define input parameter p-res-code           as integer          no-undo.
define input parameter p-income-trn-doc-code as character       no-undo.
define input parameter p-sale-doc-code      as character        no-undo.
define input parameter p-kitchen-rest       as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr2sale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr2sale.p $":U .
define variable vss-description as character no-undo init "Создание документа внутреннего перемещения для блюд с кухни в ресторан".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp_gds-list no-undo like ub.goods
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
define    temp-table temp_gds-list-hist no-undo
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
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure fbrrsrv-rsrv-goods :
define input parameter p-parent-proc            as handle                   no-undo.
define input parameter p-goods-recid            as recid                    no-undo.
define input parameter p-doc-line-recid         as recid                    no-undo.
define input parameter p-required-qnty          like doc-line.doc-qnty      no-undo.
define input parameter p-set-price              as logical                  no-undo.
define input parameter p-price                  as decimal                  no-undo.
define input parameter p-rsrv-by-parts          as logical                  no-undo.
define input parameter p-income-trn-doc-code    as character                no-undo.
define output parameter p-rsrv-qnty             like doc-line.doc-qnty      no-undo.
    define variable v-parts-rsrv-qnty       as decimal      no-undo.
    define variable v-sum-parts-rsrv-qnty   as decimal      no-undo.
    define variable v-r-b-is-base           as logical      no-undo.
    define variable v-cost-base             as decimal      no-undo.
    define variable v-cost-rubl             as decimal      no-undo.
    define variable v-parts-parameter       as character    no-undo.
    define variable v-parts-found           as logical      no-undo.
    define variable v-price-base            as decimal      no-undo.
    define variable v-price-rubl            as decimal      no-undo.
    define variable v-yesno                 as logical      no-undo.
    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_parts         for parts.
do
for buf_goods
  , buf_gds-prt
  , buf_gds-dtl
  , buf_trn-doc
  , buf_doc-line
  , buf_parts
on error undo, return error
:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-r-b-is-base
  )  .
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = buf_doc-line.doc-code
    .
    assign
        buf_trn-doc.print-rubl = ( if v-r-b-is-base = yes then no else yes )
    .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input buf_trn-doc.obj-code
   ,input buf_trn-doc.obj-type
   ,input buf_trn-doc.doc-code
   ,input buf_goods.artic
   ,input buf_goods.prod-code
   ,input buf_goods.prod-type
   ,input buf_gds-prt.node-code
   ,input yes
  ) no-error .
    if error-status:error
    then do:
        message
            "Ошибка при создании признака."
            skip return-value
        view-as alert-box error.
    end.
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
    .
    if p-set-price = yes
    then do:
        if v-r-b-is-base = yes
        then do:
            assign
                buf_gds-dtl.price-base = p-price
                buf_gds-dtl.price-rubl = p-price * buf_trn-doc.base-rate / buf_trn-doc.base-scale
            .
        end.
        else do:
            assign
                buf_gds-dtl.price-rubl = p-price
                buf_gds-dtl.price-base = p-price / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            .
        end.
    end.
    else do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(buf_gds-dtl)
  , input no
  , input ?
  ) no-error.
        if error-status:error
        then do:
            message
                "Ошибка при назначении цены признака."
                skip return-value
            view-as alert-box error.
        end.
        if v-r-b-is-base = yes
        then do:
            assign
                buf_gds-dtl.price-rubl = buf_gds-dtl.price-base * buf_trn-doc.base-rate / buf_trn-doc.base-scale
                buf_gds-dtl.price-base = buf_gds-dtl.price-base
            .
        end.
        else do:
            assign
                buf_gds-dtl.price-rubl = buf_gds-dtl.price-rubl
                buf_gds-dtl.price-base = buf_gds-dtl.price-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            .
        end.
    end.
    assign
        buf_trn-doc.status_ = 'накл':U
        buf_trn-doc.flag_   = no
    .
    assign
        buf_gds-dtl.ov  = yes
        v-cost-base     = buf_doc-line.price-base
        v-cost-rubl     = buf_doc-line.price-rubl
        p-rsrv-qnty     = round( p-required-qnty, 3 )
    .
    if p-rsrv-by-parts = yes
    then do:
        assign
            v-parts-found           = no
            v-sum-parts-rsrv-qnty   = 0
        .
        if p-income-trn-doc-code <> ""
        then do:
            for each buf_parts no-lock
               where buf_parts.obj-type  = buf_doc-line.obj-type
                 and buf_parts.obj-code  = buf_doc-line.obj-code
                 and buf_parts.prod-type = buf_doc-line.prod-type
                 and buf_parts.prod-code = buf_doc-line.prod-code
                 and buf_parts.artic     = buf_doc-line.artic
                 and buf_parts.in-code   = p-income-trn-doc-code
                 and buf_parts.out-code  = p-income-trn-doc-code
            on error undo, return error return-value
            :
                assign
                    v-parts-found     = yes
                    v-parts-parameter = 'reserv':U
                                + ",":U + 'no-message':U
                                + ",":U + 'rsrv-single-part':U
                                + ",":U + 'rsrv-in-code':U   + "=":U + str-encode ( buf_parts.in-code  ,  "", ",=":U )
                                + ",":U + 'rsrv-part-code':U + "=":U + str-encode ( buf_parts.part-code,  "", ",=":U )
                .
                assign
                    v-parts-rsrv-qnty = ( if p-rsrv-qnty < buf_parts.fact-qnty then p-rsrv-qnty else buf_parts.fact-qnty )
                .
                run trg/rsrv-dtl.p (
                      input p-parent-proc
                    , input v-parts-parameter
                    , buffer buf_gds-dtl
                    , input-output v-parts-rsrv-qnty
                    , input-output v-cost-base
                    , input-output v-cost-rubl
                    , input -1
                    , input ""
                ) no-error.
                if error-status:error
                then do:
                    undo, return error return-value.
                end.
                if v-cost-base <= 0
                or v-cost-rubl <= 0
                then do:
                    undo, return error substitute("Неправильные цены резервирования:&1&2&3&1БАЗ.ВАЛ.:&4&1Артикул:&5"
                                                  ,chr(10)
                                                  ,"РУБЛИ:   "
                                                  ,v-cost-rubl
                                                  ,v-cost-base
                                                  ,buf_doc-line.artic).
                    .
                end.
                assign
                    v-sum-parts-rsrv-qnty = v-sum-parts-rsrv-qnty + v-parts-rsrv-qnty
                    p-rsrv-qnty           = p-rsrv-qnty           - v-parts-rsrv-qnty
                .
            end.
        end.
        if p-rsrv-qnty > 0
        then do:
            run trg/rsrv-dtl.p (
                  input p-parent-proc
                , input 'reserv':U
                        + ",":U + 'no-message':U
                        + ",":U + 'negative-check':U + '=':U + '1':U
                , buffer buf_gds-dtl
                , input-output p-rsrv-qnty
                , input-output v-cost-base
                , input-output v-cost-rubl
                , input -1
                , input ""
            ) no-error.
            if error-status:error
            then do:
                undo, return error return-value.
            end.
            if v-cost-base <= 0
            or v-cost-rubl <= 0
            then do:
                undo, return error substitute("Неправильные цены резервирования:&1&2&3&1БАЗ.ВАЛ.:&4&1Артикул:&5"
                                              ,chr(10)
                                              ,"РУБЛИ:   "
                                              ,v-cost-rubl
                                              ,v-cost-base
                                              ,buf_doc-line.artic).
            end.
        end.
        assign
            p-rsrv-qnty = p-rsrv-qnty + v-sum-parts-rsrv-qnty
        .
    end.
    else do:
        run trg/rsrv-dtl.p (
              input p-parent-proc
            , input 'reserv':U
                    + ",":U + 'no-message':U
                    + ",":U + 'negative-check':U + '=':U + '1':U
            , buffer buf_gds-dtl
            , input-output p-rsrv-qnty
            , input-output v-cost-base
            , input-output v-cost-rubl
            , input -1
            , input ""
        ) no-error.
        if error-status:error
        then do:
            undo, return error return-value.
        end.
        if v-cost-base <= 0
        or v-cost-rubl <= 0
        then do:
          undo, return error substitute("Неправильные цены резервирования:&1&2&3&1БАЗ.ВАЛ.:&4&1Артикул:&5"
                                        ,chr(10)
                                        ,"РУБЛИ:   "
                                        ,v-cost-rubl
                                        ,v-cost-base
                                        ,buf_doc-line.artic).
        end.
    end.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info8 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info8 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info8 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info8 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure fbrrest-get-free-qnty :
do
on error undo, return error
:
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
define input parameter p-gds-code       as integer              no-undo.
define input parameter p-autofbr        as logical              no-undo.
define output parameter p-avail-qnty    as decimal              no-undo.
    define variable v-req-qnty  like ub.fbr-line.fact-qnty no-undo.
    define variable v-free-qnty as decimal       no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_gds-obj       for ub.gds-obj.
    define buffer buf_temp-parts    for temp-parts.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    assign
        p-avail-qnty = 0
    .
    run partslib-init-temp-parts in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_goods.artic
        , input buf_goods.prod-type
        , input buf_goods.prod-code
    ).
    assign
        v-free-qnty = 0
    .
    for each buf_temp-parts
    on error undo, return error
    :
        if buf_temp-parts.qnty > 0
        then do:
            assign
                v-free-qnty = v-free-qnty + buf_temp-parts.free-qnty
            .
        end.
    end.
    assign
        p-avail-qnty = ( if v-free-qnty > 0 then v-free-qnty else 0 )
    .
end.
end procedure.
procedure fbrrest-get-catering-object :
do
on error undo, return error
:
define input parameter p-obj-code            as integer      no-undo.
define output parameter p-catering-obj-type  as character    no-undo.
define output parameter p-catering-obj-code  as integer      no-undo.
    define buffer buf_shop              for ub.shop.
    find first buf_shop no-lock
         where buf_shop.obj-code = p-obj-code
    .
    assign
        p-catering-obj-type = buf_shop.kitchen-store-type
        p-catering-obj-code = buf_shop.kitchen-store-code
    .
end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable v-cntxt-db-num as integer no-undo .
define variable v-cntxt-userid as character no-undo .
    define variable v-trn-doc-code          as character    no-undo.
    define variable v-trn-doc-wrkr          as integer      no-undo.
    define variable v-trn-doc-boss          as integer      no-undo.
    define variable v-trn-doc-agnt          as integer      no-undo.
    define variable v-today                 as date         no-undo.
    define variable v-time                  as integer      no-undo.
    define variable v-host-code             as integer      no-undo.
    define variable v-base-code             as integer      no-undo.
    define variable v-host-name             as character    no-undo.
    define variable v-down-pay              as integer      no-undo.
    define variable v-sum-base              as decimal      no-undo.
    define variable v-sum-rubl              as decimal      no-undo.
    define variable v-sum-vat-base          as decimal      no-undo.
    define variable v-sum-vat-rubl          as decimal      no-undo.
    define variable v-goods-is-not-office   as logical      no-undo.
    define variable v-restaurant-free-qnty  as decimal      no-undo.
    define variable v-need-qnty             as decimal      no-undo.
    define variable v-rb-is-base            as logical      no-undo.
    define buffer buf_goods             for goods.
    define buffer buf_doc-fbr-gds       for doc-fbr-gds.
    define buffer buf_curr-accnt        for curr-accnt.
    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_sale_trn-doc      for trn-doc.
    define buffer buf_income_trn-doc    for trn-doc.
    define buffer buf_sale-doc          for ub.sale-doc.
do
for buf_goods
  , buf_doc-fbr-gds
  , buf_curr-accnt
  , buf_trn-doc
  , buf_sale_trn-doc
  , buf_income_trn-doc
  , buf_sale-doc
on error undo, return error
:
    run get-db-num in parparentproc ( output v-cntxt-db-num).
    run get-userid in parparentproc ( output v-cntxt-userid).
    if p-kitchen-type = p-res-type
    and p-kitchen-code = p-res-code
    then do:
        undo, return .
    end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
    run doc-code in this-procedure (
          input "main"
        , input p-kitchen-type
        , input p-kitchen-code
        , input ""
        , output v-trn-doc-code
    ).
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-kitchen-type
  ,input  p-kitchen-code
  ,output v-host-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-kitchen-type
  ,input  p-kitchen-code
  ,output v-today
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  p-kitchen-type
  ,input  p-kitchen-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
          and buf_curr-accnt.exch-date <= v-today
    use-index pi no-error.
    if not available buf_curr-accnt
    then do:
        message
            "На дату" v-today "неизвестен курс базовой валюты."
        view-as alert-box error.
        undo, return error.
    end.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdnpay in g#library
  (input  p-kitchen-type
  ,input  p-kitchen-code
  ,output v-down-pay
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input buf_curr-accnt.exch-rate
,input buf_curr-accnt.exch-scale
,input p-res-code
,input p-res-type
,input v-host-name
,input v-cntxt-db-num
,input v-cntxt-userid
,input 'процент':U
,input v-trn-doc-code
,input v-today
,input 'рас':U
,input no
,input v-host-code
,input yes
,input p-kitchen-code
,input p-kitchen-type
,input no
,input v-down-pay
,input ' '
,input no
,input 'без':U
,input 'накл':U
,input 'в т. ч.':U
,input 'ev':U
,input 1
) no-error
.
    if error-status:error
    then do:
        message
            "Ошибка при создании складского документа."
        view-as alert-box error.
        undo, return error.
    end.
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = v-trn-doc-code
    .
    assign
        buf_trn-doc.print-rubl  = ( if v-rb-is-base = yes then no else yes )
        buf_trn-doc.exch-rate   = 1
        buf_trn-doc.exch-scale  = 1
        buf_trn-doc.exch-code   = 0
        buf_trn-doc.exch-date   = v-today
        buf_trn-doc.out-code    = p-sale-doc-code
    .
    find first buf_sale_trn-doc no-lock
         where buf_sale_trn-doc.doc-code = p-sale-doc-code
    no-error.
    if available buf_sale_trn-doc
    then do:
        assign
            buf_trn-doc.agnt        = buf_sale_trn-doc.agnt
            buf_trn-doc.boss        = buf_sale_trn-doc.boss
            buf_trn-doc.wrkr        = buf_sale_trn-doc.wrkr
        .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf_trn-doc.doc-code ,
                       input 'fbrauto':U ,
                       input 'yes':U ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Не удалось записать флаг автопроизводства"
            skip "в атрибут документа"
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box warning.
    end.
    define variable v-need-moving    as logical      no-undo.
    assign
        v-need-moving = no
    .
    create-lines:
    for each buf_sale-doc where
             buf_sale-doc.inkas-code = p-sale-doc-code
         and buf_sale-doc.fbrsale = yes,
        each buf_doc-fbr-gds no-lock
       where buf_doc-fbr-gds.obj-type     = p-res-type
         and buf_doc-fbr-gds.obj-code     = p-res-code
         and buf_doc-fbr-gds.fbr-obj-type = p-kitchen-type
         and buf_doc-fbr-gds.fbr-obj-code = p-kitchen-code
         and buf_doc-fbr-gds.out-code     = buf_sale-doc.doc-code
    on error undo, return error
    :
        if p-kitchen-rest = yes
        then do:
            run fbrrest-get-free-qnty in this-procedure (
                  input p-res-type
                , input p-res-code
                , input buf_doc-fbr-gds.gds-code
                , input no
                , output v-restaurant-free-qnty
            ).
        end.
        else do:
            assign
                v-restaurant-free-qnty  = 0
            .
        end.
        assign
            v-need-qnty = buf_doc-fbr-gds.fact-qnty - v-restaurant-free-qnty
        .
        if v-need-qnty <= 0
        then do:
            undo create-lines, next create-lines.
        end.
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_doc-fbr-gds.gds-code
        .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-is-not-office
  )  .
        if v-goods-is-not-office = yes
        then do:
            run create-doc-line in this-procedure (
                  input buf_trn-doc.doc-code
                , input buf_doc-fbr-gds.gds-code
                , input v-need-qnty
                , output v-sum-base
                , output v-sum-rubl
                , output v-sum-vat-base
                , output v-sum-vat-rubl
            ).
            if v-sum-base       = ?
            or v-sum-rubl       = ?
            or v-sum-vat-base   = ?
            or v-sum-vat-rubl   = ?
            or v-sum-base       = 0
            or v-sum-rubl       = 0
            then do:
                message
                    skip "Не удалось определить учетную цену"
                    skip "товара на объекте."
                    skip (1)
                    skip "Товар: " buf_goods.artic buf_goods.gds-name
                    skip "Объект (кухня): " buf_trn-doc.obj-type buf_trn-doc.obj-code
                    skip "Сумма в руб"    v-sum-rubl
                    skip "Сумма НДС"       v-sum-vat-rubl
                view-as alert-box error.
                undo, return error .
            end.
            assign
                v-need-moving = yes
            .
        end.
    end.
    if v-need-moving = no
    then do:
        delete buf_trn-doc.
    end.
    else do:
        define variable v-was-gds-moving    as logical        no-undo.
        run str/trn-stat.p  (
              input parparentproc
            , input this-procedure
            , input '<закрытие документа>':U
            , input buf_trn-doc.doc-code
            , input no
            , input v-cntxt-db-num
            , input no
            , input 0
            , input 0
            , input ""
            , input yes
            , output v-was-gds-moving
            , output table temp_gds-list
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
                skip "Документ номер:" buf_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        run str/trn-stat.p  (
            input parparentproc
            , input this-procedure
            , input '<закрытие документа>':U
            , input buf_trn-doc.doc-code
            , input no
            , input v-cntxt-db-num
            , input no
            , input 0
            , input 0
            , input ""
            , input yes
            , output v-was-gds-moving
            , output table temp_gds-list
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
                skip "Документ номер:" buf_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        run str/trn-stat.p  (
            input parparentproc
            , input this-procedure
            , input '<закрытие документа>':U
            , input buf_trn-doc.doc-code
            , input no
            , input v-cntxt-db-num
            , input no
            , input 0
            , input 0
            , input ""
            , input yes
            , output v-was-gds-moving
            , output table temp_gds-list
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
                skip "Документ номер:" buf_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        assign
            v-trn-doc-code = buf_trn-doc.doc-code
            v-trn-doc-boss = buf_trn-doc.boss
            v-trn-doc-agnt = buf_trn-doc.agnt
            v-trn-doc-wrkr = buf_trn-doc.wrkr
        .
        release buf_trn-doc.
        find first buf_income_trn-doc no-lock
            where buf_income_trn-doc.out-code = v-trn-doc-code
        .
        run str/trn-stat.p  (
            input parparentproc
            , input this-procedure
            , input '<закрытие документа>':U
            , input buf_income_trn-doc.doc-code
            , input no
            , input v-cntxt-db-num
            , input no
            , input 0
            , input 0
            , input ""
            , input yes
            , output v-was-gds-moving
            , output table temp_gds-list
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при закрытии документа внутреннего перемещения."
                skip(1)
                skip "Объект:" buf_income_trn-doc.obj-type buf_income_trn-doc.obj-code
                skip "Документ номер:" buf_income_trn-doc.doc-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
        find first buf_income_trn-doc exclusive-lock
             where buf_income_trn-doc.out-code = v-trn-doc-code
        .
        assign
            buf_income_trn-doc.boss = v-trn-doc-boss
            buf_income_trn-doc.agnt = v-trn-doc-agnt
            buf_income_trn-doc.wrkr = v-trn-doc-wrkr
        .
    end.
end.
procedure create-doc-line :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-qnty           as decimal      no-undo.
define output parameter p-sum-base      as decimal      no-undo .
define output parameter p-sum-rubl      as decimal      no-undo .
define output parameter p-sum-vat-base  as decimal      no-undo .
define output parameter p-sum-vat-rubl  as decimal      no-undo .
    define variable v-required-qnty     as decimal        no-undo.
    define variable v-reserved-qnty     as decimal        no-undo.
    define variable v-today             as date           no-undo.
    define variable v-time              as integer        no-undo.
    define variable v-sum-base          as decimal        no-undo.
    define variable v-sum-rubl          as decimal        no-undo.
    define variable v-vat-base          as decimal        no-undo.
    define variable v-vat-rubl          as decimal        no-undo.
    define variable v-vat-pc            as decimal        no-undo.
    define variable v-host-code         as integer        no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_goods         for goods.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_gds-prt       for gds-prt.
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-doc-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    create buf_doc-line.
    assign
        buf_doc-line.artic         = buf_goods.artic
        buf_doc-line.prod-type     = buf_goods.prod-type
        buf_doc-line.prod-code     = buf_goods.prod-code
        buf_doc-line.obj-type      = buf_trn-doc.obj-type
        buf_doc-line.obj-code      = buf_trn-doc.obj-code
        buf_doc-line.doc-code      = buf_trn-doc.doc-code
        buf_doc-line.prt-ok        = yes
        buf_doc-line.prt-root      = buf_goods.prt-root
        buf_doc-line.status_       = buf_trn-doc.status_
        buf_doc-line.doc-qnty      = 0
        buf_doc-line.cli-base-rate = 1
        v-required-qnty            = round( p-qnty, 3 )
        v-reserved-qnty            = 0
    .
    run fbrrsrv-rsrv-goods in this-procedure (
          input parparentproc
        , input recid( buf_goods )
        , input recid( buf_doc-line )
        , input v-required-qnty
        , input no
        , input 0
        , input yes
        , input p-income-trn-doc-code
        , output v-reserved-qnty
    ) no-error.
    if error-status :error
    then do:
        if error-status :get-message(1) <> ""
        or return-value <> "user-interrupt":U
        then do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка резервирования товара."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
        end.
        undo, return error return-value.
    end.
    if v-required-qnty <> v-reserved-qnty
    then do:
        message
        "Невозможно зарезервировать товар."
        skip(1)
        skip "Товар:" buf_goods.artic buf_goods.gds-name
        skip "Объект:" buf_trn-doc.obj-type buf_trn-doc.obj-code
        skip "Количество:" v-required-qnty
        skip "Доступно количество:" v-reserved-qnty
        view-as alert-box error.
        undo, return error .
    end.
    run str/fbrcost.p (
          input recid( buf_doc-line )
        , input -1
        , input v-required-qnty
        , output v-sum-base
        , output v-sum-rubl
        , output v-vat-base
        , output v-vat-rubl
        , output v-vat-pc
      ) .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-vat-pc
  )  .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
    .
    assign
        buf_doc-line.doc-qnty   = v-reserved-qnty
        buf_doc-line.fact-qnty  = v-reserved-qnty
        buf_gds-dtl.doc-qnty    = v-reserved-qnty
        buf_gds-dtl.fact-qnty   = v-reserved-qnty
        p-sum-base              = v-sum-base - v-vat-base
        p-sum-rubl              = v-sum-rubl - v-vat-rubl
        p-sum-vat-base          = v-vat-base
        p-sum-vat-rubl          = v-vat-rubl
    .
    assign
        buf_doc-line.price-cli  = v-sum-rubl / v-reserved-qnty
        buf_doc-line.price-base = v-sum-base / v-reserved-qnty
        buf_doc-line.price-rubl = v-sum-rubl / v-reserved-qnty
        buf_doc-line.VAT-pc     = v-vat-pc
    .
end.
end procedure.
