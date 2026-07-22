block-level on error undo, throw.
define input  parameter p-imp-handle as handle    no-undo .
define input  parameter rec-full     as character no-undo.
define input  parameter p-counter    as integer   no-undo .
define input  parameter db-src       like ub.db.db-num no-undo.
define variable vss-revision    as character no-undo init "$Revision: d3f7ea4aa09e, 3307, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-cmd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/imp-cmd.p $":U .
define variable vss-description as character no-undo init "Обработка входящих команд".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,rec-full,db-src)
    .
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
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, chr(10) ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) ).
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) )
    .
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
define  shared variable nws-exch-dir as character no-undo .
define  shared variable nws-heap-dir as character no-undo .
define variable err-mess as character no-undo .
define temp-table t-pck-conf no-undo
  field db-num-dst      as integer
  field db-num-src      as integer
  field pack-num        as integer
  field total-recs      as integer
  field sys-key         as character
  field src_db-key      as character
  field dst_db-key      as character
  field ver-num         as character
  field prev-crc        as character
  field actual-date     as date
  field actual-time-int as integer
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE shared TEMP-TABLE cash-txn no-undo
FIELD tax-code like ub.tax.tax-code
FIELD tax-name like ub.tax.tax-name
FIELD news-action as logical
index pi IS UNIQUE PRIMARY tax-code.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table cash-txr no-undo
  field tax-code    like ub.tax.tax-code
  field rate-code   like ub.tax-rate.rate-code
  field host-code   like ub.sysconf.host-code
  field obj-type    like ub.clients.obj-type
  field obj-code    like ub.clients.obj-code
  field tax-type    like ub.tax.tax-type
  field status_     like ub.tax-rate-value.status_
  field rate-value  as decimal
  field rc          as recid
  field crf         as integer
  field news-action as logical
  index pi is unique primary tax-code host-code obj-type obj-code status_ rc
  index crf-i  crf host-code obj-type obj-code rc
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dc-list-hist no-undo
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  shared temp-table pbc-list no-undo like ub.prod-bc
                        field rc as recid
                        field del as  logical
                        index rci is unique rc del
                        index gds-code-i b-code del
                        index ibc-on-type bc-on-type
                        .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  shared temp-table bc-list no-undo like ub.bar-code
                        field del as  logical
                        index bc is unique b-code del
                        index gds-code-i gds-code del.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes13 as character no-undo .
    define variable v-param-type13 as character no-undo .
    define variable v-value-character13 as INTEGER no-undo .
    define variable v-value-date13 as date no-undo .
    define variable v-value-decimal13 as decimal no-undo .
    define variable v-value-integer13 AS integer no-undo .
    define variable v-value-logical13 AS LOGICAL no-undo .
    define variable v-tth13 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character13
        ,output v-value-date13
        ,output v-value-decimal13
        ,output v-value-integer13
        ,output v-value-logical13
        ,output v-param-type13
        ,INPUT-OUTPUT table-handle v-tth13
        ) no-error .
    if error-status :error then do:
      delete object v-tth13.
      v-mes13 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes13.
    end.
    delete object v-tth13.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer13)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess14 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess14
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info16 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info16, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info16, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info16, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info16, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info16 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info16, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info16 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info16, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info16, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info16, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info16, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info16, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info16, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info16 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info16 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info16, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info16, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info16, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info16 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info16 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info16, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info16, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure db-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
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
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
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
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
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
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-loc-counter as integer no-undo .
define variable v-counter-visible as logical no-undo .
define variable v-view-log as logical no-undo .
define stream auto2dia.
PROCEDURE write-log-and-file :
do
on error undo, return error
:
  define input parameter p-tab-position   as integer   no-undo.
  define input parameter p-file-name      as character no-undo .
  define input parameter p-log-level      as integer   no-undo .
  define input parameter p-log-string     AS CHARacter NO-UNDO.
  define variable v-jj as integer   no-undo .
  run write-to-screen in this-procedure( input ( fill( chr(32), p-tab-position) + p-log-string)) .
  if p-file-name <> '':U then do:
    do v-jj = 1 to num-entries(p-file-name, chr(1)):
      run  auto2dia-writefile in this-procedure (
                                      input entry(v-jj, p-file-name, chr(1))
                                      ,input p-log-level
                                      ,input (p-log-string + chr(10))
                                    ) no-error .
    end.
  end.
  if writelogvalue eq "AsyncProc"
  then
     run write-to-log in this-procedure( p-log-string) .
end.
END PROCEDURE.
PROCEDURE get-title :
do
on error undo, return error
:
define output parameter p-title     as character    no-undo.
end.
END PROCEDURE.
PROCEDURE set-title :
do
on error undo, return error
:
define input parameter p-title     as character    no-undo.
run write-to-log in this-procedure( input ( fill( chr(32), 15) + p-title)) .
end.
END PROCEDURE.
PROCEDURE get-counter-value :
do
on error undo, return error
:
define output parameter p-counter     as integer    no-undo.
    assign
    p-counter  = v-loc-counter
    .
end.
END PROCEDURE.
PROCEDURE set-counter-value :
do
on error undo, return error
:
define input parameter p-counter     as integer    no-undo.
    assign
    v-loc-counter = p-counter
    .
end.
END PROCEDURE.
PROCEDURE show-counter :
do
on error undo, return error
:
    assign
    v-counter-visible = true
    .
    process events.
end.
END PROCEDURE.
PROCEDURE hide-counter :
do
on error undo, return error
:
    assign
    v-counter-visible = false
    .
    run hide-message in auto-window-h .
    process events.
end.
END PROCEDURE.
PROCEDURE write-counter :
do
on error undo, return error
:
define input parameter p-counter-string     as character    no-undo.
if v-counter-visible then
run write-message in auto-window-h ( input p-counter-string) .
process events.
end.
END PROCEDURE.
PROCEDURE get-stop-state :
do
on error undo, return error
:
define output parameter p-stop-state    as logical      no-undo.
end.
END PROCEDURE.
PROCEDURE set-view-log :
do
on error undo, return error
:
define input parameter p-view-log     as logical    no-undo.
    assign
    v-view-log = p-view-log
    .
end.
END PROCEDURE.
PROCEDURE get-view-log :
do
on error undo, return error
:
define output parameter p-view-log     as logical    no-undo.
    assign
    p-view-log = v-view-log
    .
end.
END PROCEDURE.
PROCEDURE write-log :
do
on error undo, return error
:
define input parameter p-tab-position   as integer      no-undo.
define input parameter p-log-string     as character    no-undo.
run write-to-log in this-procedure( input ( fill( chr(32), 1  * p-tab-position)  +
                                    (IF p-log-string = "&Line" THEN FILL("-", 80)
                                    ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                                    ELSE p-log-string))).
end.
END PROCEDURE.
procedure writelog :
do
on error undo, return error
:
define input parameter p-file-name AS CHAR     NO-UNDO.
define input parameter p-log-level AS INTEGER  NO-UNDO.
define input parameter p-log-string  AS CHAR     NO-UNDO.
  if p-file-name <> "" then
  run  auto2dia-Writefile in this-procedure (
                                    input p-file-name
                                  ,input p-log-level
                                  ,input p-log-string
                                ) no-error .
   process events.
end.
end procedure.
PROCEDURE auto2dia-writefile:
  define input parameter sFileName AS CHAR     NO-UNDO.
  define input parameter iLogLevel AS INTEGER  NO-UNDO.
  define input parameter sToWrite  AS CHAR     NO-UNDO.
  define variable v-SlashPos  as integer no-undo .
  define variable v-lDirName  as character no-undo .
  define variable v-lDirName2 as character no-undo .
  v-SlashPos  = maximum (  r-index(sFileName, "\"),  r-index(sFileName, "/")  ) .
  v-lDirName  = if v-SlashPos > 0 then substring (sFileName, 1, v-SlashPos - 1) else "".
  FILE-INFO:FILE-NAME = v-lDirName .
  v-lDirName2 = FILE-INFO:FULL-PATHNAME .
  if v-lDirName2 <> ? then do :
OUTPUT STREAM auto2dia TO VALUE(sFileName) APPEND.
    PUT STREAM auto2dia UNFORMATTED chr(10).
    PUT STREAM auto2dia UNFORMATTED (IF (iLogLevel = 0 OR sToWrite = "&DLine"
                                      OR sToWrite = "&Line") THEN "" ELSE
                                      cur-time-string-sec() + " ").
    PUT STREAM auto2dia UNFORMATTED
            (IF sToWrite = "&Line" THEN FILL("-", 80)
             ELSE IF sToWrite = "&DLine" THEN FILL("=", 80)
             ELSE sToWrite).
OUTPUT STREAM auto2dia CLOSE.
  end .
END PROCEDURE.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
  define new global shared variable g#lib-rvs as handle no-undo.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_clients for ub.clients.
  define buffer buf_shop for ub.shop.
  define buffer buf_dis-card for ub.dis-card.
  define buffer buf_db for ub.db .
  define buffer buf_db-rec-attr for ub.db-rec-attr .
  define buffer buf_goods for ub.goods.
  define buffer buf_gds-obj for ub.gds-obj .
  define buffer buf_esys-route for ub.esys-route .
  DEFINE VARIABLE var-rate-value like ub.tax-rate-value.rate-value no-undo .
  define variable i-f-name        as character no-undo.
  define variable i-par as character no-undo .
  define variable v-error-message as character no-undo.
  define variable v-curr-date as date    no-undo.
  define variable v-curr-time as integer no-undo .
  define variable v-step      as integer no-undo .
  define variable v-type           as character no-undo .
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
  define variable v-key-rec        as character no-undo .
  define variable v-tbl-row        as rowid     no-undo .
  define variable v-tbl-name       as character no-undo .
  define variable v-uniq-gate-rec  as character no-undo .
  define variable jj as integer no-undo .
  define variable v-dop1 as character no-undo .
  define variable v-dop2 as character no-undo .
  define variable v-chip-num like ub.c-trn-doc.chip-num no-undo .
  define variable v-action       as character no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-parameters   as character no-undo .
  define variable v-doc-code     as character no-undo .
  define variable v-host-code    as integer   no-undo .
  define variable v-db-num       as integer   no-undo .
  define variable v-obj-type     as character no-undo .
  define variable v-obj-code     as integer   no-undo .
  define variable v-artic        as character no-undo .
  define variable v-prod-type    as character no-undo .
  define variable v-prod-code    as integer   no-undo .
  define variable v-on-line-rest as decimal   no-undo .
  define variable v-cash-parts   as logical   no-undo .
  define variable v-insalepr     as integer   no-undo .
  define variable p-stop         as logical   no-undo .
  define variable v-factur-date like ub.trn-doc.factur-date .
  define variable v-cr-factur   like ub.trn-doc.cr-factur   .
  define variable v-need-factur like ub.trn-doc.need-factur .
  define variable v-nws-to-cd as integer no-undo .
  DEFINE VARIABLE v-prn-doc-code as character no-undo .
  define variable v-last-pack as integer   no-undo .
  define variable v-attr-code as character no-undo.
  case entry(1,rec-full,chr(1)):
    when "command" then do:
      case entry(2,rec-full,chr(1)):
        when 'goods':U then do:
          case entry(3,rec-full,chr(1)) :
            when "ren-gds-code":U then do:
              run utl/ren-gdsc.p
                ( integer( entry( 4, rec-full, chr(1) ) )
                 ,integer( entry( 5, rec-full, chr(1) ) )
                ) no-error.
              if error-status :error then do:
                run write-to-log in this-procedure
                  (input "Не удалось заменить gds-code существовавшего товара " + entry( 4, rec-full, chr(1) )
                        + " на " + entry( 5, rec-full, chr(1) ) + "." + chr(10)
                        + return-value + chr(10) + error-status:get-message(1) + chr(10) + rec-full
                  ).
                return error.
              end.
            end.
            otherwise do:
              run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
              return error.
            end.
          end case.
        end.
        when "message-to-log":U then do:
          run write-to-log( substitute( "<MESSAGE> &1", entry(3,rec-full,chr(1)) ) ).
        end.
        when "inquiry-two-commit":U then do:
          assign
            v-action       = entry(3,rec-full,chr(1))
            v-uniq-key-rec = entry(4,rec-full,chr(1))
            v-parameters   = entry(5,rec-full,chr(1))
          .
          run write-to-log( substitute( "Получен запрос из БД &1 на выполнение операции &2 над записью &3"
                                        ,g#news-source-db
                                        ,v-action
                                        ,v-uniq-key-rec
                                      )
                          ).
          run nws/db-rec.p
            ( input v-action
             ,input v-uniq-key-rec
             ,input v-parameters
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (inquiry-two-commit). &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message( 1 ) ) ).
            return error.
          end.
          if return-value <> "":U then do:
            run write-to-log( substitute( "Ошибка при выполнении операции &1 над записью &2&3&4"
                                          ,v-action
                                          ,v-uniq-key-rec
                                          ,chr(10)
                                          ,return-value
                                         )
                            ).
          end.
          else do:
            run write-to-log( substitute( "Начинается выполнение операции &1 над записью &2"
                                          ,v-action
                                          ,v-uniq-key-rec
                                        )
                            ).
          end.
        end.
        when "two-commit":U then do:
          run nws/dbreccmd.p
            ( input g#news-source-db
             ,input rec-full
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (two-commit). &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message( 1 ) ) ).
            return error.
          end.
        end.
        when "after-two-commit":U then do:
          run nws/dbrecaft.p
            ( input g#news-source-db
             ,input rec-full
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (after-two-commit). &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message( 1 ) ) ).
            return error.
          end.
        end.
        when "get-inf-dbs":U then do:
          if g#db-num = 0 then do:
            for each buf_db no-lock
            on error undo, return error substitute( "&1 &2", return-value, error-status :get-message(1) )
            :
              run str/callnews.p
                ( input 'db':U
                 ,input (buffer buf_db:handle)
                ) .
            end.
          end.
        end.
        when "fill-contract":U then do:
          run utl/fill-cnt.p
            ( input integer(entry(3,rec-full,chr(1)))
             ,input entry(4,rec-full,chr(1))
            )  no-error .
          if error-status :error then do:
            run write-to-log( vss-workfile + chr(32) + "Ошибка при привязке партий и складских документов к договору поставщика на удаленке !"  ).
            return error.
          end.
        end.
        when "place-attr":U then do:
          run utl/fill-pl-attr.p
            ( input entry(3,rec-full,chr(1))
             ,input integer(entry(4,rec-full,chr(1)))
             ,input integer(entry(5,rec-full,chr(1)))
             ,input entry(6,rec-full,chr(1))
             ,input entry(7,rec-full,chr(1))
            )  no-error .
          if error-status :error then do:
            run write-to-log( vss-workfile + chr(32) + "Ошибка при установке атрибута резервуара на удаленке !"  ).
            return error.
          end.
        end.
        when "fin-ob-factur-date":U then do:
          assign v-doc-code    = entry(3,rec-full,chr(1)) no-error .
          assign v-host-code   = int(entry(4,rec-full,chr(1))) no-error .
          assign v-factur-date = date(entry(5,rec-full,chr(1))) no-error .
          assign v-cr-factur   = logical(entry(6,rec-full,chr(1))) no-error .
          assign v-need-factur = int(entry(7,rec-full,chr(1))) no-error .
          define buffer buf_fin-ob for ub.fin-ob .
          find first buf_fin-ob exclusive-lock where buf_fin-ob.doc-code = v-doc-code and buf_fin-ob.host-code = v-host-code  no-error .
          if available buf_fin-ob then do:
            assign
              buf_fin-ob.factur-date = v-factur-date
              buf_fin-ob.cr-factur   = v-cr-factur
              buf_fin-ob.need-factur = v-need-factur
            .
          end.
        end.
        when "fin-doc-factur-date":U then do:
          assign v-doc-code    = entry(3,rec-full,chr(1)) no-error .
          assign v-host-code   = int(entry(4,rec-full,chr(1))) no-error .
          assign v-factur-date = date(entry(5,rec-full,chr(1))) no-error .
          assign v-cr-factur   = logical(entry(6,rec-full,chr(1))) no-error .
          assign v-need-factur = int(entry(7,rec-full,chr(1))) no-error .
          define buffer buf_fin-doc for ub.fin-doc .
          find first buf_fin-doc exclusive-lock where buf_fin-doc.fin-doc-code = int(v-doc-code) and buf_fin-doc.host-code = v-host-code  no-error .
          if available buf_fin-doc then do:
            assign
              buf_fin-doc.factur-date = v-factur-date
              buf_fin-doc.cr-factur   = v-cr-factur
              buf_fin-doc.need-factur = v-need-factur
            .
          end.
        end.
        when "fin-doc-prn-doc":U then do:
          assign v-doc-code    = entry(3,rec-full,chr(1)) no-error .
          assign v-host-code   = int(entry(4,rec-full,chr(1))) no-error .
          assign v-prn-doc-code = entry(5,rec-full,chr(1)) no-error .
          define buffer bf_fin-doc for ub.fin-doc .
          find first bf_fin-doc exclusive-lock where bf_fin-doc.fin-doc-code = int(v-doc-code) and bf_fin-doc.host-code = v-host-code  no-error .
          if available bf_fin-doc then do:
            assign
              bf_fin-doc.prn-doc-code = v-prn-doc-code
            .
          end.
        end.
        when "open-factur":U then do:
          assign v-doc-code = entry(3,rec-full,chr(1)) no-error .
          assign v-db-num   = int(entry(4,rec-full,chr(1))) no-error .
          define buffer buf_schet-fact-doc for ub.schet-fact-doc .
          find first buf_schet-fact-doc exclusive-lock where buf_schet-fact-doc.doc-code = v-doc-code and buf_schet-fact-doc.db-num = v-db-num no-error .
          if available buf_schet-fact-doc then do:
            assign
              buf_schet-fact-doc.status_ = 'новый':U
              buf_schet-fact-doc.fact-date = ?
            .
          end.
        end.
        when "run-file":U then do:
          define variable rf-ii as integer no-undo .
          assign
          i-f-name = entry(3,rec-full,chr(1))
          i-par = substr(rec-full, index(rec-full, chr(1)) + 1)
          i-par = substr(i-par, index(i-par, chr(1)) + 1)
          i-par = substr(i-par, index(i-par, chr(1)) + 1)
          .
          do rf-ii = 1 to 5:
            i-par = (if r-index(i-par, chr(1))  > 1
                    then  substr(i-par, 1, r-index(i-par, chr(1)) - 1)
                    else i-par)
            .
          end.
          if search(i-f-name) <> ?
          or search(entry(1, i-f-name, '.') + '.r') <> ?
          then do:
            run value(i-f-name)
              ( INPUT auto-window-h
               ,INPUT this-procedure
               ,INPUT this-procedure
               ,input i-par
              ) no-error .
            if error-status :error then do:
               run write-to-log( substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message( 1 ) ) ).
            end.
          end.
        end.
        when "parts":u
        then do:
          case entry(3,rec-full,chr(1))
          :
            when "last-date":u
            then do:
              run trg/partolas.p
                (input  entry(4,rec-full,chr(1))
                ,input  integer(entry(5,rec-full,chr(1)))
                ,input  entry(6,rec-full,chr(1))
                ,input  integer(entry(7,rec-full,chr(1)))
                ,input  entry(8,rec-full,chr(1))
                ,input  date(entry(9,rec-full,chr(1)))
                ) .
            end.
            when "alc-attr":u
            then do:
              run trg/partps.p ( input integer(entry(4,rec-full,chr(1)))
                               , input entry(5,rec-full,chr(1))
                               , if num-entries (rec-full,chr(1)) = 15 then entry(15,rec-full,chr(1)) else ?
                               , input entry(6,rec-full,chr(1))
                               , input integer(entry(7,rec-full,chr(1)))
                               , input integer(entry(8,rec-full,chr(1)))
                               , input date(entry(9,rec-full,chr(1)))
                               , input entry(10,rec-full,chr(1))
                               , input entry(11,rec-full,chr(1))
                               , input entry(12,rec-full,chr(1))
                               , input entry(13,rec-full,chr(1))
                               , input entry(14,rec-full,chr(1))
                               ) no-error .
              if error-status :error then do:
                run write-to-log( substitute( "&1(partps.p). &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message( 1 ) ) ).
                return error.
              end.
            end.
            otherwise do:
              run write-to-log( substitute("команда parts: неизвестное значение &1", entry(3,rec-full,chr(1))) ).
              return error.
            end.
          end case .
        end.
        when "bush":U then do:
          assign
            v-uniq-gate-rec = entry( num-entries( rec-full, chr(1) ) - 4, rec-full, chr(1) )
          .
          run nws/imp-bush.p
            ( input p-imp-handle
             ,input entry( 3, rec-full, chr(1) )
             ,input v-uniq-gate-rec
             ,input p-counter
             ,input g#news-source-db
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (bush). &2&3&4", vss-workfile, return-value, chr(10), error-status:get-message( 1 ) ) ).
            return error.
          end.
        end.
        when "rename-last-pack-for-esys":U then do:
          assign
            v-key-rec   = entry( 3, rec-full, chr(1) )
            v-last-pack = integer( entry( 4, rec-full, chr(1) ) )
          .
          run gen-row-keyr in this-procedure
            ( input  v-key-rec
             ,input ?
             ,input "ub":U
             ,input ?
             ,input share-lock
             ,output v-tbl-row
             ,output v-tbl-name
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (rename-last-pack-for-esys). Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                                          ,vss-workfile
                                          ,v-key-rec
                                          ,chr(10)
                                          ,return-value
                                          ,error-status :get-message ( 1 )
                                        )
                            ).
            return error .
          end.
          find first buf_esys-route exclusive-lock
            where rowid( buf_esys-route ) = v-tbl-row
            no-error .
          if available buf_esys-route then do:
            assign
              buf_esys-route.esr-last-pack = v-last-pack
            .
          end.
        end.
        when "create" then do:
          case entry(3, rec-full, chr(1)):
            when "code-range" then do:
              run cre-loc-sc-code-range ( input entry(4, rec-full, chr(1))
                                         ,input (if num-entries(rec-full, chr(1)) > 4
                                                then entry(5, rec-full, chr(1))
                                                else '')
                                                ).
            end.
            when "on-line-rest":U then do:
              assign
                v-obj-type     = entry(4,rec-full,chr(1))
                v-obj-code     = integer(entry(5,rec-full,chr(1)))
                v-artic        = entry(6,rec-full,chr(1))
                v-prod-type    = entry(7,rec-full,chr(1))
                v-prod-code    = integer(entry(8,rec-full,chr(1)))
                v-on-line-rest = decimal(entry(9,rec-full,chr(1)))
              .
              find first buf_gds-obj exclusive-lock
                where buf_gds-obj.obj-type  = v-obj-type
                  and buf_gds-obj.obj-code  = v-obj-code
                  and buf_gds-obj.artic     = v-artic
                  and buf_gds-obj.prod-type = v-prod-type
                  and buf_gds-obj.prod-code = v-prod-code
                no-error .
              if available buf_gds-obj then do:
                assign
                  buf_gds-obj.on-line-rest = v-on-line-rest
                .
              end.
            end.
            when "cash-parts":U then do:
              assign
                v-obj-type     = entry(4,rec-full,chr(1))
                v-obj-code     = integer(entry(5,rec-full,chr(1)))
                v-artic        = entry(6,rec-full,chr(1))
                v-prod-type    = entry(7,rec-full,chr(1))
                v-prod-code    = integer(entry(8,rec-full,chr(1)))
                v-cash-parts    = logical(entry(9,rec-full,chr(1)))
              .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,buffer buf_gds-obj
  ) no-error .
                if error-status:error then do:
                  run write-to-log( substitute("команда cash-parts: не удалось создать gds-obj&1&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value
                                   )).
                end.
                  find first buf_gds-obj exclusive-lock
                    where buf_gds-obj.obj-type  = v-obj-type
                      and buf_gds-obj.obj-code  = v-obj-code
                      and buf_gds-obj.artic     = v-artic
                      and buf_gds-obj.prod-type = v-prod-type
                      and buf_gds-obj.prod-code = v-prod-code
                     .
              if buf_gds-obj.cash-parts <> v-cash-parts then do:
                  assign
                    buf_gds-obj.cash-parts = v-cash-parts
                  .
                end.
              end.
            when "insalepr":U then do:
              define variable conf-par as character no-undo.
              define variable mode-erprn as logical no-undo.
              define variable par-type as character no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-erpRN'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  NO
  ,output conf-par
  ,output par-type
  ) no-error .
              if not error-status:error and conf-par = "yes":u then mode-erprn = yes.
              else mode-erprn = no.
              if mode-erprn
              then do:
                return.
              end.
              assign
                v-obj-type     = entry(4,rec-full,chr(1))
                v-obj-code     = integer(entry(5,rec-full,chr(1)))
                v-artic        = entry(6,rec-full,chr(1))
                v-prod-type    = entry(7,rec-full,chr(1))
                v-prod-code    = integer(entry(8,rec-full,chr(1)))
                v-insalepr    = integer(entry(9,rec-full,chr(1)))
              .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  v-artic
  ,input  v-prod-type
  ,input  v-prod-code
  ,buffer buf_gds-obj
  ) no-error .
                if error-status:error then do:
                  run write-to-log( substitute("команда insalepr: не удалось создать gds-obj&1&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value
                                   )).
                end.
                  find first buf_gds-obj exclusive-lock
                    where buf_gds-obj.obj-type  = v-obj-type
                      and buf_gds-obj.obj-code  = v-obj-code
                      and buf_gds-obj.artic     = v-artic
                      and buf_gds-obj.prod-type = v-prod-type
                      and buf_gds-obj.prod-code = v-prod-code
                     .
              if buf_gds-obj.insalepr <> v-insalepr then do:
                  assign
                    buf_gds-obj.insalepr = v-insalepr
                  .
                end.
              end.
            otherwise do:
              run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
              return error.
            end.
          end case.
        end.
        when "delete":U then do:
          assign
            v-key-rec = entry( 3, rec-full, chr(1) )
          .
          run gen-row-keyr in this-procedure
            ( input  v-key-rec
             ,input ?
             ,input "ub":U
             ,input ?
             ,input share-lock
             ,output v-tbl-row
             ,output v-tbl-name
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "&1 (delete). Ошибка при поиске записи по уникальному ключу &2.&3&4&3&5"
                                          ,vss-workfile
                                          ,v-key-rec
                                          ,chr(10)
                                          ,return-value
                                          ,error-status :get-message ( 1 )
                                        )
                            ).
            return error .
          end.
          case v-tbl-name :
            when 'tax':U then do:
                find first ub.tax
                  where rowid( ub.tax ) =  v-tbl-row
                  no-error
                .
                if available ub.tax then do:
                  if ub.tax.to-cashdesk = yes then do:
                    create cash-txn.
                    assign
                      cash-txn.tax-code = ub.tax.tax-code
                      cash-txn.tax-name = ub.tax.tax-name
                      cash-txn.news-action = yes
                      .
                  end.
                  delete ub.tax.
                end.
            end.
            when 'trn-doc':U then do:
              find first ub.trn-doc
                where rowid( ub.trn-doc ) = v-tbl-row
                no-error .
              if available ub.trn-doc then do:
                if ub.trn-doc.status_ = 'факт':U then do:
                  assign
                    ub.trn-doc.is-del = true
                  .
                  run trg/trndocdl.p
                    ( input ub.trn-doc.doc-code
                     ,input dynamic-next-value('s-corr-chip':U, 'ub':U)
                    ) no-error .
                  if error-status :error then do:
                    run write-to-log( substitute("Ошибка при удалении складского документа &2&1&3", chr(10), ub.trn-doc.doc-code, return-value ) ).
                    return error.
                  end.
                end.
                else do:
                  run trg/nwstdrs.p
                    (input ub.trn-doc.doc-code
                    ,input false
                    ) .
                end.
                run trg/prtobrem.p
                  (input true
                  ,input ub.trn-doc.doc-code
                  ,input true
                  ) .
                for each ub.parts
                  where ub.parts.out-code = ub.trn-doc.doc-code
                on error undo, return error
                :
                  delete ub.parts.
                end.
                delete ub.trn-doc.
              end.
            end.
            when 'fin-doc':U then do:
              find first ub.fin-doc
                where rowid( ub.fin-doc ) = v-tbl-row
                no-error .
              if available ub.fin-doc then do:
                run trg/findocdl.p (
                                input auto-window-h
                               ,input ub.fin-doc.host-code
                               ,input ub.fin-doc.fin-doc-code
                               ,input ?
                               ,input yes
                              ).
              end.
            end.
            when 'bar-code':U then do:
              find first ub.bar-code
                where rowid( ub.bar-code ) = v-tbl-row
                no-error.
              if available ub.bar-code then do:
                find first bc-list where bc-list.b-code = ub.bar-code.b-code and bc-list.del = yes no-error.
                if not avail bc-list then do:
                  create bc-list.
                  buffer-copy ub.bar-code to bc-list
                  assign
                    bc-list.del = yes
                    .
                end.
                delete ub.bar-code.
              end.
            end.
            when 'bar-code-attr':U then do:
              find first ub.bar-code-attr
                where rowid( ub.bar-code-attr ) = v-tbl-row
                no-error.
              if available ub.bar-code-attr then do:
                find first buf_goods no-lock where
                            buf_goods.gds-code = ub.bar-code-attr.gds-code no-error .
                find first gds-list where gds-list.gds-code = ub.bar-code-attr.gds-code no-error.
                if not avail gds-list then do:
                  create gds-list.
                  buffer-copy buf_goods to gds-list
                    .
                  release gds-list.
                end.
                delete ub.bar-code-attr.
              end.
            end.
            when 'bar-code-obj-attr':U then do:
              find first ub.bar-code-obj-attr
                where rowid( ub.bar-code-obj-attr ) = v-tbl-row
                no-error.
              if available ub.bar-code-obj-attr then do:
                find first buf_goods no-lock where
                            buf_goods.gds-code = ub.bar-code-obj-attr.gds-code no-error .
                find first gds-list where gds-list.gds-code = ub.bar-code-obj-attr.gds-code no-error.
                if not avail gds-list then do:
                  create gds-list.
                  buffer-copy buf_goods to gds-list
                    .
                  release gds-list.
                end.
                delete ub.bar-code-obj-attr.
              end.
            end.
            when 'dis-card-property':U then do:
              find first ub.dis-card-property
                where rowid( ub.dis-card-property ) = v-tbl-row
                no-error.
              if available ub.dis-card-property then do:
                find first buf_dis-card no-lock where
                            buf_dis-card.d-card = ub.dis-card-property.d-card no-error .
                if avail buf_dis-card
                  AND (ub.dis-card-property.obj-type = "":U
                       OR (ub.dis-card-property.obj-type = 'маг':U
                           AND
                           can-find(buf_clients where
                                    buf_clients.obj-type = ub.dis-card-property.obj-type
                                    AND buf_clients.obj-code = ub.dis-card-property.obj-code
                                    and buf_clients.db-num = g#db-num)
                          )
                      )
                then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  buf_dis-card.d-card
  ,input  0
  ,input  'nws-to-cd'
  ,output v-nws-to-cd
  ) no-error .
                    if v-nws-to-cd >= 0
                    and not can-find( dc-list where dc-list.d-card = buf_dis-card.d-card) then do:
                      create dc-list.
                      buffer-copy buf_dis-card to dc-list.
                    end.
                end.
                delete ub.dis-card-property.
              end.
            end.
            when 'gds-obj-attr':U then do:
              find first ub.gds-obj-attr
                where rowid( ub.gds-obj-attr ) = v-tbl-row
                no-error.
              if available ub.gds-obj-attr then do:
                if ub.gds-obj-attr.obj-type = 'маг':U and
                  CAN-find( first buf_clients no-lock where
                            buf_clients.obj-type = ub.gds-obj-attr.obj-type
                        AND buf_clients.obj-code = ub.gds-obj-attr.obj-code
                        AND buf_clients.db-num = g#db-num ) then do:
                  find first buf_goods no-lock where
                              buf_goods.gds-code = ub.gds-obj-attr.gds-code no-error .
                  if available buf_goods then do:
                    run gdsoattr-name in this-procedure (
                                                          input  ub.gds-obj-attr.attr-code
                                                        ,output v-type
                                                        ,output v-format
                                                        ,output v-label
                                                        ,output v-user-can-edit
                                                        ,output v-output-display
                                                        ,output v-other
                                                        ) .
                    _do-gds-obj-attr:
                    do jj = 1 to num-entries(v-other, chr(47)):
                      assign
                      v-dop1 = entry(1, entry(jj, v-other, chr(47)), '=':U)
                      .
                      if v-dop1 = "cd":U then do:
                        find first gds-list where
                                  gds-list.gds-code = ub.gds-obj-attr.gds-code   no-error .
                        if not avail gds-list then do:
                          create gds-list.
                          buffer-copy buf_goods to gds-list.
                          release gds-list.
                        end.
                        LEAVE _do-gds-obj-attr.
                      end.
                    end.
                  end.
                end.
                delete ub.gds-obj-attr.
              end.
            end.
            when 'dis-gds-rule':U then do:
              find first ub.dis-gds-rule
                where rowid( ub.dis-gds-rule ) = v-tbl-row
                no-error.
              if available ub.dis-gds-rule
              and lookup(ub.dis-gds-rule.pos-type, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U) > 0
              then do:
                if (ub.dis-gds-rule.obj-type = 'маг':U and
                  CAN-find( first buf_clients no-lock where
                            buf_clients.obj-type = ub.dis-gds-rule.obj-type
                        AND buf_clients.obj-code = ub.dis-gds-rule.obj-code
                        AND buf_clients.db-num = g#db-num ))
                or ub.dis-gds-rule.obj-type = '':U
                or (ub.dis-gds-rule.obj-type = 'орг':U and
                  CAN-find( first buf_clients no-lock where
                            buf_clients.obj-type = 'маг':U
                        AND buf_clients.host-code = ub.dis-gds-rule.obj-code
                        AND buf_clients.db-num = g#db-num ))
                then do:
                  find first buf_goods no-lock where
                              buf_goods.gds-code = ub.dis-gds-rule.gds-code no-error .
                  if available buf_goods then do:
                    find first gds-list where
                              gds-list.gds-code = ub.dis-gds-rule.gds-code   no-error .
                    if not avail gds-list then do:
                      create gds-list.
                      buffer-copy buf_goods to gds-list.
                      release gds-list.
                    end.
                  end.
                end.
              end.
              if available ub.dis-gds-rule then do:
                delete ub.dis-gds-rule.
              end.
            end.
            when 'inkas':U then do:
              find first ub.inkas
                where rowid( ub.inkas ) = v-tbl-row
                no-error.
              if available ub.inkas then do:
                run str/delfsale.p
                  ( input auto-window-h
                    ,input this-procedure
                    ,input this-procedure
                    ,input ub.inkas.inkas-code
                  ) no-error .
                if error-status :error then do:
                  run write-to-log(substitute("Не могу удалить продажу &1", ub.inkas.inkas-code) ).
                  return error.
                end.
              end.
            end.
            when 'prod-bc':U then do:
              find first ub.prod-bc
                where rowid( ub.prod-bc ) = v-tbl-row
                no-error.
              if available ub.prod-bc then do:
                  assign ub.prod-bc.bc-on = no.
                  find first pbc-list where pbc-list.rc = recid(ub.prod-bc) no-error.
                  if not avail pbc-list then do:
                    create pbc-list.
                    buffer-copy ub.prod-bc to pbc-list
                      assign
                        pbc-list.rc = recid(ub.prod-bc)
                      .
                    release pbc-list .
                end.
                delete ub.prod-bc.
              end.
            end.
            when 'prod-bc-attr':U then do:
               find first ub.prod-bc-attr
                where rowid( ub.prod-bc-attr ) = v-tbl-row
                no-error.
               if available ub.prod-bc-attr then do:
                  find first ub.prod-bc where ub.prod-bc.b-code eq ub.prod-bc-attr.b-code
                                          and ub.prod-bc.b-str  eq ub.prod-bc-attr.b-str
                  no-lock no-error.
                  find first ub.bar-code where ub.bar-code.b-code eq ub.prod-bc-attr.b-code
                  no-lock no-error.
                  if     avail prod-bc
                     and avail bar-code
                  then
                     run fill-pbc-list in p-imp-handle (
                                                        input recid(prod-bc)
                                                      , input bar-code.gds-code
                                                      , input prod-bc.b-code
                                                      , input prod-bc.b-str
                                                      , input prod-bc.bc-on
                                                      , input (if    bar-code.stts = 99
                                                                  or prod-bc.bc-on = no
                                                                  or bar-code.stts_ = 79
                                                               then yes
                                                               else no)
                                                                 ).
                delete ub.prod-bc-attr.
              end.
            end.
            when 'goods-attr':U then do:
               find first ub.goods-attr
                  where rowid( ub.goods-attr ) = v-tbl-row
               no-error.
               if available ub.goods-attr then do:
                                   if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
                    ( input  goods-attr.attr-code
                     ,output v-type
                     ,output v-format
                     ,output v-label
                     ,output v-user-can-edit
                     ,output v-output-display
                     ,output v-other
                   ) .
                   _do:
                   do jj = 1 to num-entries(v-other, chr(47)):
                      assign
                        v-dop1 = entry(1, entry(jj, v-other, chr(47)), '=':U)
                      .
                      if v-dop1 = "cd":U then do:
                          run fill-g-list in p-imp-handle ( input goods-attr.gds-code
                                                           ,input ""
                                                           ,input 0
                                                          ).
                          LEAVE _do.
                      end.
                  end.
                  delete ub.goods-attr.
               end.
            end.
            when 'fin-code-cor-acc':U then do:
              find first ub.fin-code-cor-acc
                where rowid( ub.fin-code-cor-acc ) = v-tbl-row
                no-error.
              if available ub.fin-code-cor-acc then do:
                delete ub.fin-code-cor-acc.
              end.
            end.
            when 'tax-rate-gds':U then do:
              find first ub.tax-rate-gds
                where rowid( ub.tax-rate-gds ) = v-tbl-row
                no-error.
              if available ub.tax-rate-gds then do:
                find buf_goods where buf_goods.gds-code = ub.tax-rate-gds.gds-code
                                no-lock no-error.
                if available buf_goods then do:
                  if not can-find(gds-list where gds-list.artic     = buf_goods.artic
                                              and gds-list.prod-type = buf_goods.prod-type
                                              and gds-list.prod-code = buf_goods.prod-code
                                            no-lock)
                  then do:
                    create gds-list.
                    buffer-copy buf_goods to gds-list.
                    release gds-list.
                  end.
                end.
                delete ub.tax-rate-gds.
              end.
            end.
            when 'tax-rate':U then do:
                find first ub.tax-rate
                  where rowid( ub.tax-rate ) = v-tbl-row
                  no-error.
                if available ub.tax-rate then do:
                  find ub.tax where ub.tax.tax-code = ub.tax-rate.tax-code no-lock no-error.
                  if ub.tax.to-cashdesk = yes then do:
                    for each buf_clients No-LOCK WHERE
                            buf_clients.obj-type = 'маг':U AND
                            buf_clients.db-num = g#db-num,
                        first buf_shop No-LOCK WHERE
                              buf_shop.obj-code = buf_clients.obj-code
                    on error undo, return error
                    :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(ub.tax-rate)
  ,input  0
  ,input  0
  ,input  ?
  ,input  buf_shop.host-code
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output var-rate-value
  ) no-error .
                          if not error-status:error then do:
                            create cash-txr.
                            assign
                            cash-txr.tax-code    = ub.tax.tax-code
                            cash-txr.rate-code   = ub.tax-rate.rate-code
                            cash-txr.tax-type    = ub.tax.tax-type
                            cash-txr.host-code   = buf_shop.host-code
                            cash-txr.obj-type    = buf_clients.obj-type
                            cash-txr.obj-code    = buf_clients.obj-code
                            cash-txr.crf         = ub.tax-rate.rate-code
                            cash-txr.rc          = recid(ub.tax-rate)
                            cash-txr.news-action = yes
                            cash-txr.status_     = ub.tax-rate.status_
                            cash-txr.rate-value  = var-rate-value
                            .
                          end.
                    end.
                  end.
                  delete ub.tax-rate.
                end.
            end.
            when 'tax-rate-value':U then do:
              find first ub.tax-rate-value
                where rowid( ub.tax-rate-value ) = v-tbl-row
                no-error.
              if available ub.tax-rate-value and ub.tax-rate-value.fact-date <= today then do:
                find ub.tax where ub.tax.tax-code = ub.tax-rate-value.tax-code no-lock no-error.
                if ub.tax.to-cashdesk = yes then do:
                    create cash-txr.
                    assign
                      cash-txr.tax-code    = ub.tax.tax-code
                      cash-txr.rate-code   = ub.tax-rate-value.rate-code
                      cash-txr.host-code   = ub.tax-rate-value.host-code
                      cash-txr.obj-type    = ub.tax-rate-value.obj-type
                      cash-txr.obj-code    = ub.tax-rate-value.obj-code
                      cash-txr.tax-type    = ub.tax.tax-type
                      cash-txr.rate-value  = ub.tax-rate-value.rate-value
                      cash-txr.crf         = integer(ub.tax-rate-value.fact-date)
                      cash-txr.rc          = recid(ub.tax-rate-value)
                      cash-txr.status_     = 'тек':U
                      cash-txr.news-action = no
                      .
                end.
                delete ub.tax-rate-value.
              end.
            end.
            when 'wth-doc':U then do:
              find first ub.wth-doc
                where rowid( ub.wth-doc ) = v-tbl-row
                no-error.
              if available ub.wth-doc then do:
                run trg/wthdocdl.p
                  (input ub.wth-doc.doc-code
                  ,input ?
                  ,'':U
                  ,output v-chip-num
                  ) no-error .
                if error-status :error then do:
                  run write-to-log(substitute("Не могу удалить документ МЦ &1. &2", ub.wth-doc.doc-code,return-value + error-status:get-message(1)) ).
                  return error.
                end.
              end.
            end.
            when 'ord-doc':U then do:
              find first ub.ord-doc
                where rowid( ub.ord-doc ) = v-tbl-row
                no-error.
              if available ub.ord-doc then do:
                run trg/orddocdl.p
                  (input ub.ord-doc.doc-code
                  ,input ?
                  ,output v-chip-num
                  ) no-error .
                if error-status :error then do:
                  run write-to-log in this-procedure (substitute("Не могу удалить заказ &1", ub.ord-doc.doc-code) ).
                  return error.
                end.
              end.
            end.
            when 'dis-rule':U then do:
              find first ub.dis-rule
              where rowid(ub.dis-rule) = v-tbl-row
              no-error .
              if available ub.dis-rule then do:
                define variable v-rule-num like ub.dis-rule.rule-num no-undo .
                define variable v-rule-num-2 like ub.dis-rule.rule-num no-undo .
                define buffer buf_dis-rule for ub.dis-rule.
                v-rule-num = ub.dis-rule.rule-num.
                for each buf_dis-rule where buf_dis-rule.upper-rule-num = ub.dis-rule.rule-num
                on error undo, return error substitute("Не могу удалить ПРАВИЛО СКИДОК &1", v-rule-num-2) :
                  v-rule-num-2 = buf_dis-rule.rule-num.
                  delete buf_dis-rule.
                end.
                delete ub.dis-rule no-error .
                if error-status:error then do:
                  run write-to-log(substitute("Не могу удалить ПРАВИЛО СКИДОК &1", v-rule-num) ).
                  return error.
                end.
              end.
            end.
            when 'dis-time-rule':U then do:
              find first ub.dis-time-rule
              where rowid(ub.dis-time-rule) = v-tbl-row
              no-error .
              define buffer buf_dis-time-rule for ub.dis-time-rule.
              if available ub.dis-time-rule then do:
                for each buf_dis-time-rule where buf_dis-time-rule.upper-time-rule-num = ub.dis-time-rule.time-rule-num
                on error undo, return error:
                  delete buf_dis-time-rule.
                end.
                delete ub.dis-time-rule no-error .
                if error-status:error then do:
                  run write-to-log(substitute("Не могу удалить РАСПИСАНИЕ &1", ub.dis-time-rule.time-rule-num) ).
                  return error.
                end.
              end.
            end.
            when 'ext-file':U then do:
              define buffer locked_ext-file for ub.ext-file.
              find first locked_Ext-file no-lock where
                     rowid(locked_Ext-file) = v-tbl-row no-error.
              if available locked_ext-file then do:
                run adm/extf-del.p (
                                     buffer locked_ext-file
                                   , input no
                                   , (if lookup("auto" , locked_ext-file.status_) > 0
                                      and locked_ext-file.file-type = locked_ext-file.file-name
                                      then "auto"
                                      else '':U)) no-error.
                if error-status:error then do:
                  run write-to-log(substitute("Не могу удалить зарегистрированный файл &1:&2&3"
                                           , locked_ext-file.file-num
                                           , chr(10)
                                           , return-value
                                           ) ).
                  return error.
                end.
              end.
            end.
            when 'fin-statement':U then do:
              find first ub.fin-statement
                where rowid( ub.fin-statement ) = v-tbl-row
                no-error .
              if available ub.fin-statement then do:
              end.
            end.
            when 'rvs-doc':U then do:
              find first ub.rvs-doc
                where rowid( ub.rvs-doc ) = v-tbl-row
                no-error .
              if available ub.rvs-doc then do:
                if ub.rvs-doc.rvs-type <> 'перед_док':U
                  and ub.rvs-doc.status_ <> 'новый':U
                  and ub.rvs-doc.status_ <> 'факт':U
                then do:
                  run trg/lock-rvs.p
                    ( input ub.rvs-doc.rvs-code
                    ,input "assign-rvs-on=false":U
                    ,input ub.rvs-doc.rvs-code
                    ,input false
                    ) no-error .
                  if error-status:error then do:
                    run write-to-log(substitute("Не удалось снять блокировку по документу сверки &1", ub.rvs-doc.rvs-code, chr(10), return-value ) ).
                    return error.
                  end.
                end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_hstc-rvs in g#lib-rvs
( buffer ub.rvs-doc
 ,input integer('99':U)
 ,input ub.rvs-doc.rvs-code
 ,input dynamic-next-value('s-corr-chip':U,'ub':U)
) no-error.
                if error-status :error then do:
                  undo, return error return-value.
                end.
                assign
                  ub.rvs-doc.is-del = true
                .
                delete ub.rvs-doc .
              end.
            end.
            when 'config':U then do:
              find first ub.config
                where rowid( ub.config ) = v-tbl-row
                no-error .
              if available ub.config then do:
                assign
                  ub.config.stts = -1
                .
                delete ub.config .
              end.
            end.
             when 'PromoAttr':U then
                do:
                   find first ub.PromoAttr
                      where rowid( ub.PromoAttr ) = v-tbl-row
                      no-error.
                   if available ub.PromoAttr then
                   do:
                         run fill-PromoAttr in p-imp-handle (
                            input ub.PromoAttr.attr-value
                            , input ub.PromoAttr.p-key
                            , input ub.PromoAttr.attr-code
                            , input ub.PromoAttr.tablename
                            ).
                      delete ub.PromoAttr.
                   end.
                end.
            when 'clients-attr':U then do:
              find first ub.clients-attr
                where rowid( ub.clients-attr ) = v-tbl-row
                no-error .
              if avail ub.clients-attr then
                 assign
                    v-attr-code = ub.clients-attr.attr-code
                    v-obj-type  = ub.clients-attr.obj-type
                    v-obj-code  = ub.clients-attr.obj-code
                    .
              else
                 assign
                    v-attr-code = ""
                    v-obj-type  = ""
                    v-obj-code  = 0
                    .
              run nws/del-rec.p
                ( input v-key-rec
                 ,input false
                ) no-error .
              if error-status :error then do:
                run write-to-log( substitute( "&1&2&3&2&4", vss-workfile, chr(10), return-value, error-status:get-message( 1 ) ) ).
                return error.
              end.
              if v-attr-code = "envd" then do:
                 for each tax-rate-attr where
                          tax-rate-attr.attr-code = v-attr-code
                 no-lock,
                     each tax-rate-gds where
                          tax-rate-gds.tax-code  = tax-rate-attr.tax-code
                      and tax-rate-gds.rate-code = tax-rate-attr.rate-code
                      and tax-rate-gds.fact-date <= today
                 no-lock:
                    run fill-g-list in p-imp-handle (tax-rate-gds.gds-code,
                                                     v-obj-type,
                                                     v-obj-code).
                 end.
              end.
            end.
            when 'Code':U then
            do:
               find first ub.code
                      where rowid( ub.code ) = v-tbl-row
                no-error.
                if available ub.code then
                do:
                   run fill-code in p-imp-handle (ub.code.parent,
                                                  ub.code.code).
                   delete ub.code.
               end.
            end.
            when 'db':U
            or when 'db-attr':U
            or when 'alc-sale-lic':U
            or when 'alc-sale-lic-attr':U
            or when 'alc-sale-lic-type':U
            or when 'alc-supp-lic':U
            or when 'alc-supp-lic-attr':U
            or when 'alc-supp-lic-type':U
            or when 'alc-type':U
            or when 'alc-type-attr':U
            or when 'alc-type-gds':U
            or when 'arh-fin-doc-an':U
            or when 'arh-fin-doc-an-nal':U
            or when 'arh-fin-doc-contr-schet':U
            or when 'arh-fin-doc-contr-schet-nal':U
            or when 'arh-fin-doc-contr-schet-tax':U
            or when 'arh-fin-doc-c-schet-tax-nal':U
            or when 'arh-fin-doc-schet':U
            or when 'arh-fin-doc-schet-nal':U
            or when 'arh-fin-doc-schet-tax':U
            or when 'arh-fin-doc-contr-schet-obj':U
            or when 'arh-fin-doc-contr-s-nal-obj':U
            or when 'arh-fin-doc-contr-s-tax-obj':U
            or when 'arh-fin-doc-c-s-tax-nal-obj':U
            or when 'arh-fin-doc-schet-obj':U
            or when 'arh-fin-doc-schet-nal-obj':U
            or when 'arh-fin-doc-schet-tax-nal':U
            or when 'arh-fin-ob-contr':U
            or when 'arh-trn-doc-contract':U
            or when 'contract-specif':U
            or when 'cash-desk-attr':U
            or when 'cli-grp':U
            or when 'cash-desk':U
            or when 'cash-pay-attr':U
            or when 'cd-trans':U
            or when 'dis-card-mask':U
            or when 'dis-card-type':U
            or when 'dis-card-type-attr':U
            or when 'fbr-doc':U
            or when 'fbr-prn':U
            or when 'fbr-gds-grp':U
            or when 'fbr-gds-grp-attr':U
            or when 'fbr-gds-obj':U
            or when 'fbr-prn-gds':U
            or when 'fbr-prn-grp':U
            or when 'goods-attr':U
            or when 'gds-season':U
            or when 'gds-season-attr':U
            or when 'gds-grp-attr':U
            or when 'gds-grp':U
            or when 'gds-grp-obj':U
            or when 'gds-grp-obj-attr':U
            or when 'gds-host-attr':U
            or when 'icnt-doc':U
            or when 'nozzle':U
            or when 'pl-gds':U
            or when 'pl-gds-pump':U
            or when 'pl-pump-nozzle':U
            or when 'pl-pump':U
            or when 'pl-level':U
            or when 'pl-level-mm':U
            or when 'place':U
            or when 'pump-nozzle':U
            or when 'recipe-gds':U
            or when 'recipe':U
            or when 's-coeff':U
            or when 'season':U
            or when 'season-attr':U
            or when 'sert-join':U
            or when 'sert':U
            or when 'shift-obj':U
            or when 'sr-izmerenia':U
            or when 'sum-grp':U
            or when 'sum-grp-obj':U
            or when 'tax-rate-gds-grp':U
            or when 'tax-rate-attr':U
            or when 'tax-units':U
            or when 'varianty-delivery-gds-obj':U
            or when 'wealth':U
            or when 'wth-par':U
            or when 'wth-place':U
            or when 'wth-ser':U
            or when 'wth-ser-attr':U
            or when 'wth-gds':U
            or when 'wth-gds-attr':U
            or when 'scales':U
            or when 'scales-gds':U
            or when 'scales-grp':U
            or when 'scales-attr':U
            or when 'fin-connect':U
            or when 'factur-connect':U
            or when 'ext-artic':U
            or when 'ext-artic-attr':U
            or when 'place-io':U
            or when 'c-place-io':U
            or when 'point-io':U
            or when 'c-point-io':U
            or when 'price-all':U
            or when 'prod-bc-db':U
            or when 'schedule':U
            or when 'schedule-attr':U
            or when 'action-post':U
            or when 'action-post-host':U
            or when 'action-post-obj':U
            or when 'action-post-role':U
            or when 'action-post-user-login':U
            or when 'action-role':U
            or when 'action-role-item':U
            or when 'action-role-item-gds':U
            or when 'action-role-item-gds-grp':U
            or when 'user-account':U
            or when 'user-host':U
            or when 'user-login':U
            or when 'user-login-action-item':U
            or when 'user-login-action-role':U
            or when 'user-login-attr':U
            or when 'user-menu-group':U
            or when 'user-obj':U
            or when 'hist-nws-option':U
            or when 'schet-fact-doc':U
            or when 'profile-by-profile':U
            or when 'prop-ref-call':U
            or when 'prop-ref':U
            or when 'prop-head':U
            or when 'prop-map':U
            or when 'prop-script':U
            or when 'pscript-ruleset':U
            or when 'prop-ruleset':U
            or when 'ruleset':U
            or when 'rule-by-set':U
            or when 'rule-profile':U
            or when 'rp-rule-param':U
            or when 'rule-by-profile':U
            or when 'rule-script':U
            or when 'rule-i-script':U
            or when 'ruledict':U
            or when 'ruledict-param':U
            or when 'rule':U
            or when 'rp-by-call':U
            or when 'rule-by-call':U
            or when 'rule-call-param':U
            or when 'dis-grp-rule':U
            or when 'dis-some-rule':U
            or when 'dis-cp-rule':U
            or when 'dis-dc-rule':U
            or when 'dis-thbj-rule':U
            or when 'dis-cfg-rule':U
            or when 'drt-prop':U
            or when 'cd-plu':U
            or when 'cd-clu':U
            or when 'cd-dlu':U
            or when 'cd-grp':U
            or when 'ext-classif':U
            or when 'ext-classif-attr':U
            or when 'pl-gds-attr':U
            or when 'nozzle-attr':U
            or when 'place-attr':U
            or when 'pump-attr':U
            or when 'some-lk':U
            or when 'who-lk':U
            or when 'thbj-attr':U
            or when 'staff':U
            or when 'custom-labels':U
            or when 'grp-obj-price':U
            or when 'clob-bind':U
            or when 'clob-data':U
            or when 'blob-bind':U
            or when 'blob-data':U
            or when 'add-doc':U
            or when 'esys-pck-sent':U
            or when 'esys-pck-rcvd':U
            or when 'ext-system-attr':U
            or when 'esys-route':U
            or when 'trn-reason':U
            or when 'trn-reason-host':U
            or when 'trn-reason-obj':U
            or when 'egais-gds':U
            or when 'egais-clients':U
            or when 'layout':U
            or when 'layout-attr':U
            or when 'layout-elem':U
            or when 'wi-mode':U
            or when 'cd-events':U
            or when 'cd-events-attr':U
            or when 'cd-video-link':U
            or when 'cd-video-link-attr':U
            or when 'cd-event-log':U
            or when 'cd-event-log-attr':U
            or when 'ord-chain':U
            or when 'assortment-matrix-attr':U
            or when 'gds-obj-prop-attr':U
            or when 'rule-process':U
            or when 'dis-gds-rule-attr':U
            or when 'auto-tank-attr':U
            or when 'vsd':U
            or when 'gds-mercury':U
            or when 'c-vsd':U
            or when 'c-gds-mercury':U
            or when 'vsd-attr':U
            or when 'gds-mercury-attr':U
            or when 'units-attr':U
            or when 'OperServ':U
            or when 'OperServAttr':U
            or when 'CashBook':U
            or when 'CashBookAttr':U
            or when 'CashBookRule':U
            or when 'CashBookRuleAttr':U
            or when 'devisPC':U
            or when 'devisPC-attr':U
            or when 'utd':U
            or when 'marking-lines':U
            or when 'promo-schedule':U
            or when 'promo-schedule-week':U
            or when 'PromoAction':U
            or when 'PromoAttr':U
            or when 'PromoCriterion':U
            or when 'PromoGoods':U
            or when 'PromoGift':U
            or when 'PromoObject':U
            or when 'Cash-param-hist':U
            then do:
              run nws/del-rec.p
                ( input v-key-rec
                 ,input false
                ) no-error .
              if error-status :error then do:
                run write-to-log( substitute( "&1&2&3&2&4", vss-workfile, chr(10), return-value, error-status:get-message( 1 ) ) ).
                return error.
              end.
            end.
            when 'ext-system':U then do:
              find first ub.ext-system no-lock where
                        rowid(ub.ext-system) = v-tbl-row no-error.
              if available ub.ext-system
              and ub.ext-system.esys-type > integer('0':U) then do:
                run bge/extsyss3.p ( input yes
                                    ,input recid(ub.ext-system)) no-error.
              end.
              else do:
                run nws/del-rec.p
                  ( input v-key-rec
                  ,input false
                  ) no-error .
              end.
              if error-status :error then do:
                run write-to-log( substitute( "&1&2&3&2&4", vss-workfile, chr(10), return-value, error-status:get-message( 1 ) ) ).
                return error.
              end.
            end.
            otherwise do:
              run write-to-log ( substitute( "&1. Нет обработки команды на удаление для таблицы &2", vss-workfile, v-tbl-name ) ).
              return error.
            end.
          end case.
        end.
        when "cut-doc":U then do:
          p-stop  = false .
          run gbl/btprcver.p ( output p-stop ) no-error .
          if error-status :error then do:
            run write-to-log ( substitute( "Ошибка при проверке отложенных заданий расчета переоценок &1&2&1&3", chr(10), return-value, error-status :get-message(1) ) ).
            return error.
          end.
          if p-stop  then do:
            run write-to-log ( substitute( "Обнаружены отложенные задания расчета переоценок . &1 ПЕРЕСЧИТАЙТЕ АРХИВ !!!", chr(10) )).
            return error.
          end.
          run db-attr-write in this-procedure
            ( input g#db-num
             ,input 'cut-date':U
             ,input entry(3,rec-full,chr(1))
            ) no-error .
          if error-status :error then do:
            run write-to-log ( substitute( "Ошибка при записи даты усечения документов&1&2&1&3", chr(10), return-value, error-status :get-message(1) ) ).
            return error.
          end.
          run db-attr-write in this-procedure
            ( input g#db-num
             ,input 'cut-fin-date':U
             ,input entry(4,rec-full,chr(1))
            ) no-error .
          if error-status :error then do:
            run write-to-log( substitute( "Ошибка при записи даты усечения документов&1&2&1&3", chr(10), return-value, error-status :get-message(1) ) ).
            return error.
          end.
        end.
        when "delete-object":U then do:
          run utl/del-obj.p
            (input entry(3,rec-full,chr(1)) + chr(44) + entry(4,rec-full,chr(1))
            ,input no
            ,input ""
            ,input ""
            ) .
        end.
        when "r-file" then do:
        end.
        otherwise do:
          run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
          return error.
        end.
      end case.
    end.
    when "get-seq" then do:
        case entry(2, rec-full, chr(1)):
          when "s-sclc-code" then do:
            run nws/cr-route.p ( input 'send-cmd':U
                           ,input "put-seq" + chr(1) + "s-sclc-code" + chr(1)
                                  + string( current-value( s-sclc-code, ub ) ) + chr(1) + string( g#db-num )
                           ,input ?
                           ,input "0":U
                          ).
          end.
          otherwise do:
            run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
            return error.
          end.
        end case.
    end.
    when "dlcr" then do:
      run nws/dlcr.p ( entry(2, rec-full, chr(1)), entry(3, rec-full, chr(1)) ) no-error.
      if error-status:error then do:
        run write-to-log( "ошибка при работе утилиты dlcr" ).
        return error.
      end.
    end.
    when "put-seq" then do:
        case entry(2, rec-full, chr(1)):
          when "s-sclc-code" then do:
            create ub.rep .
            assign
              ub.rep.doc-num = -27091997
              ub.rep.gr      = integer( entry(4, rec-full, chr(1)) )
              ub.rep.num     = integer( entry(3, rec-full, chr(1)) )
            .
          end.
          otherwise do:
            run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
            return error.
          end.
        end case.
    end.
    otherwise do:
      run write-to-log(substitute( "&1. Отсутствует обработка команды &2", vss-workfile, rec-full ) ).
      return error.
    end.
  end case.
end.
