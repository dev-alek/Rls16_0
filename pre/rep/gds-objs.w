define input parameter parparentproc  as widget-handle no-undo.
define input parameter pp-artic     like ub.prt-obj.artic     no-undo.
define input parameter pp-prod-type like ub.prt-obj.prod-type no-undo.
define input parameter pp-prod-code like ub.prt-obj.prod-code no-undo.
define input parameter pp-host-code like ub.prt-obj.host-code no-undo.
define input parameter pp-node-code like ub.gds-prt.node-code no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Остатки по признаку по всем объектам текущей фирмы или всех фирм".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info1 as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$".
define temp-table temp_prt-obj no-undo
  field artic       like ub.prt-obj.artic
  field obj-type    like ub.prt-obj.obj-type
  field obj-code    like ub.prt-obj.obj-code
  field host-code   like ub.prt-obj.host-code
  field obj-name    like ub.clients.obj-name
  field qnty        like ub.prt-obj.fact-qnty
  field free-qnty   like ub.prt-obj.free-qnty
  field price       like ub.prt-obj.price-sale
  field fact-qty-kg like ub.prt-obj.fact-qnty
  field free-qty-kg like ub.prt-obj.free-qnty
  field price-kg    like ub.prt-obj.price-sale
  field sdate       like ub.trn-doc.fact-date
  field stime       as   character
  field stime-int   as   integer
  field db-num      like ub.db.db-num
  field db-name     like ub.db.db-name
  index pi          is   unique primary           obj-type obj-code
  index ie1                             host-code obj-type obj-code
.
procedure fill-temp_prt-obj :
  define input  parameter p-artic       as character no-undo .
  define input  parameter p-prod-type   as character no-undo .
  define input  parameter p-prod-code   as integer   no-undo .
  define input  parameter p-host-code   as integer   no-undo .
  define input  parameter p-node        as integer   no-undo .
  define input  parameter p-firm-global as character no-undo .
  define input  parameter p-is-ptrl     as logical   no-undo .
  define output parameter p-total-fact  as decimal   no-undo .
  define output parameter p-total-sum   as decimal   no-undo .
  define output parameter p-fact-kg     as decimal   no-undo .
  do on error undo, return error return-value :
    define buffer buf_temp_prt-obj for temp_prt-obj .
    define buffer buf_prt-obj      for ub.prt-obj .
    define buffer buf_clients      for ub.clients .
    define buffer buf_db           for ub.db .
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_db-status    for ub.db-status .
    for each buf_temp_prt-obj on error undo, return error return-value :
      delete buf_temp_prt-obj .
    end.
    if p-firm-global = "firm" then do:
      for each buf_prt-obj no-lock where
               buf_prt-obj.artic     = p-artic     and
               buf_prt-obj.prod-type = p-prod-type and
               buf_prt-obj.prod-code = p-prod-code and
               buf_prt-obj.prt-code  = p-node      and
               buf_prt-obj.host-code = p-host-code on error undo, return error return-value :
        find buf_temp_prt-obj no-lock where
             buf_temp_prt-obj.artic    = buf_prt-obj.artic    and
             buf_temp_prt-obj.obj-type = buf_prt-obj.obj-type and
             buf_temp_prt-obj.obj-code = buf_prt-obj.obj-code no-error .
        if not available buf_temp_prt-obj then do:
          create buf_temp_prt-obj.
          assign buf_temp_prt-obj.artic     = buf_prt-obj.artic
                 buf_temp_prt-obj.obj-type  = buf_prt-obj.obj-type
                 buf_temp_prt-obj.obj-code  = buf_prt-obj.obj-code
                 buf_temp_prt-obj.host-code = p-host-code
                 buf_temp_prt-obj.qnty      = buf_prt-obj.fact-qnty
                 buf_temp_prt-obj.free-qnty = buf_prt-obj.free-qnty
                 buf_temp_prt-obj.price     = buf_prt-obj.price-sale
                 buf_temp_prt-obj.obj-name  = ?
                 buf_temp_prt-obj.sdate     = ?
                 buf_temp_prt-obj.stime     = ?
                 buf_temp_prt-obj.stime-int = ?
                 buf_temp_prt-obj.db-num    = ?
                 buf_temp_prt-obj.db-name   = ?
          .
        if p-is-ptrl = yes then do:
          run get-weight-qty in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.free-qty-kg,
                                                 output buf_temp_prt-obj.fact-qty-kg  ) no-error.
          if error-status :error then do: undo, return error return-value. end.
          run get-weight-prc in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.price-kg     ) no-error.
          if error-status :error then do: undo, return error return-value. end.
        end.
        end.
      end.
    end.
    else do:
      for each buf_prt-obj no-lock where
               buf_prt-obj.artic     = p-artic     and
               buf_prt-obj.prod-type = p-prod-type and
               buf_prt-obj.prod-code = p-prod-code and
               buf_prt-obj.prt-code  = p-node      on error undo, return error return-value :
        find buf_temp_prt-obj no-lock where
             buf_temp_prt-obj.artic    = buf_prt-obj.artic    and
             buf_temp_prt-obj.obj-type = buf_prt-obj.obj-type and
             buf_temp_prt-obj.obj-code = buf_prt-obj.obj-code no-error .
        if not available buf_temp_prt-obj then do:
          create buf_temp_prt-obj.
          assign buf_temp_prt-obj.artic     = buf_prt-obj.artic
                 buf_temp_prt-obj.obj-type  = buf_prt-obj.obj-type
                 buf_temp_prt-obj.obj-code  = buf_prt-obj.obj-code
                 buf_temp_prt-obj.host-code = ?
                 buf_temp_prt-obj.qnty      = buf_prt-obj.fact-qnty
                 buf_temp_prt-obj.free-qnty = buf_prt-obj.free-qnty
                 buf_temp_prt-obj.price     = buf_prt-obj.price-sale
                 buf_temp_prt-obj.obj-name  = ?
                 buf_temp_prt-obj.sdate     = ?
                 buf_temp_prt-obj.stime     = ?
                 buf_temp_prt-obj.stime-int = ?
                 buf_temp_prt-obj.db-num    = ?
                 buf_temp_prt-obj.db-name   = ?
          .
        if p-is-ptrl = yes then do:
          run get-weight-qty in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.free-qty-kg,
                                                 output buf_temp_prt-obj.fact-qty-kg  ) no-error.
          if error-status :error then do: undo, return error return-value. end.
          run get-weight-prc in this-procedure ( buffer buf_prt-obj,
                                                 output buf_temp_prt-obj.price-kg     ) no-error.
          if error-status :error then do: undo, return error return-value. end.
        end.
        end.
      end.
    end.
    assign
      p-total-fact = 0
      p-total-sum  = 0
    .
    for each buf_temp_prt-obj on error undo, return error return-value :
      assign
        p-total-fact = p-total-fact + buf_temp_prt-obj.qnty
        p-total-sum  = p-total-sum  + buf_temp_prt-obj.qnty        * buf_temp_prt-obj.price
        p-fact-kg    = p-fact-kg    + buf_temp_prt-obj.fact-qty-kg
      .
      find first buf_clients no-lock where
                 buf_clients.obj-type = buf_temp_prt-obj.obj-type and
                 buf_clients.obj-code = buf_temp_prt-obj.obj-code no-error .
      if available buf_clients then do:
        assign
          buf_temp_prt-obj.db-num   = buf_clients.db-num
          buf_temp_prt-obj.obj-name = buf_clients.obj-name
        .
      end.
      find first buf_db no-lock where buf_db.db-num = buf_temp_prt-obj.db-num no-error.
      if available buf_db then do:
        assign
          buf_temp_prt-obj.db-num  = buf_db.db-num
          buf_temp_prt-obj.db-name = buf_db.db-name
        .
      end.
      if buf_temp_prt-obj.db-num = g#db-num then do:
        run cur-time in this-procedure ( output buf_temp_prt-obj.sdate, output buf_temp_prt-obj.stime-int ) .
      end.
      else do:
        find first buf_db-status no-lock where buf_db-status.db-num = buf_temp_prt-obj.db-num no-error .
        if available buf_db-status then do:
          assign
            buf_temp_prt-obj.sdate     = buf_db-status.stock-date
            buf_temp_prt-obj.stime-int = buf_db-status.stock-time
          .
        end.
      end.
      if buf_temp_prt-obj.stime-int <> ? then do:
        assign
          buf_temp_prt-obj.stime = string( buf_temp_prt-obj.stime-int, 'HH:MM:SS':U )
        .
      end.
    end.
  end.
end procedure.
  procedure get-weight-qty :
    define        parameter buffer loc-prt-obj   for ub.prt-obj.
    define output parameter        p-free-qty-kg as  decimal no-undo initial 0.0.
    define output parameter        p-fact-qty-kg as  decimal no-undo initial 0.0.
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_inv-line for ub.inv-line.
    do on error undo, return error return-value :
      if available loc-prt-obj then do:
        for each buf_doc-line no-lock where
                 buf_doc-line.obj-type   = loc-prt-obj.obj-type  and
                 buf_doc-line.obj-code   = loc-prt-obj.obj-code  and
                 buf_doc-line.prod-type  = loc-prt-obj.prod-type and
                 buf_doc-line.prod-code  = loc-prt-obj.prod-code and
                 buf_doc-line.artic      = loc-prt-obj.artic     and
                 buf_doc-line.status_    = 'факт':U               and
                 buf_doc-line.fact-order > 0                     use-index fact-order
              by buf_doc-line.fact-order   descending :
          find first buf_inv-line no-lock where
                     buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                     buf_inv-line.artic     = buf_doc-line.artic     and
                     buf_inv-line.prod-code = buf_doc-line.prod-code and
                     buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
          if available buf_inv-line then do:
            assign p-fact-qty-kg = ( if buf_inv-line.after-cli-qnty = ? then 0.0 else buf_inv-line.after-cli-qnty ).
            if loc-prt-obj.free-qnty <> ? and loc-prt-obj.fact-qnty <> ? and loc-prt-obj.fact-qnty <> 0.0 then do:
              assign p-free-qty-kg = loc-prt-obj.free-qnty / loc-prt-obj.fact-qnty * p-fact-qty-kg.
            end.
            leave.
          end.
        end.
      end.
    end.
  end procedure.
  procedure get-weight-prc :
    define        parameter buffer loc-prt-obj  for ub.prt-obj.
    define output parameter        p-price-sale as  decimal no-undo initial 0.0.
    define variable is-base as logical no-undo.
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_inv-line for ub.inv-line.
    do on error undo, return error return-value :
      if available loc-prt-obj then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output is-base
  ) no-error .
        if error-status :error then do: return error return-value. end.
        for each buf_doc-line no-lock where
                 buf_doc-line.obj-type   = loc-prt-obj.obj-type  and
                 buf_doc-line.obj-code   = loc-prt-obj.obj-code  and
                 buf_doc-line.prod-type  = loc-prt-obj.prod-type and
                 buf_doc-line.prod-code  = loc-prt-obj.prod-code and
                 buf_doc-line.artic      = loc-prt-obj.artic     and
                 buf_doc-line.status_    = 'факт':U               and
                 buf_doc-line.fact-order > 0                     use-index fact-order
              by buf_doc-line.fact-order   descending :
          find first buf_inv-line no-lock where
                     buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                     buf_inv-line.artic     = buf_doc-line.artic     and
                     buf_inv-line.prod-code = buf_doc-line.prod-code and
                     buf_inv-line.prod-type = buf_doc-line.prod-type no-error.
          if available buf_inv-line then do:
            assign p-price-sale = ( if is-base = yes then buf_inv-line.wast-base else buf_inv-line.wast-rubl ).
            leave.
          end.
        end.
      end.
    end.
  end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-is-ptrl     as character no-undo.
define variable v-data-type   as character no-undo.
define variable is-petrol     as logical   no-undo initial ?.
define variable is-pieces     as logical   no-undo initial ?.
define variable is-kg-visible as logical   no-undo initial ?.
define buffer buf_temp_prt-obj for temp_prt-obj .
define buffer buf_goods        for ub.goods .
define buffer buf_gds-prt      for ub.gds-prt .
define variable p-need as decimal   no-undo .
function f-on-line return decimal (buffer buf_temp_prt-obj for temp_prt-obj).
define variable v-value      as character no-undo .
define variable v-type       as character no-undo .
define variable v-obj-db-num as integer   no-undo .
define buffer bf_gds-obj for ub.gds-obj  .
define buffer buf_db     for ub.db .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_temp_prt-obj.obj-type
  ,input  buf_temp_prt-obj.obj-code
  ,output v-obj-db-num
  )  .
find first bf_gds-obj where
          bf_gds-obj.obj-type = buf_temp_prt-obj.obj-type and
          bf_gds-obj.obj-code = buf_temp_prt-obj.obj-code and
          bf_gds-obj.gds-code = buf_goods.gds-code
          no-error .
find first buf_db no-lock where
           buf_db.db-num = v-obj-db-num
           .
if v-obj-db-num = g#db-num then do:
   if available bf_gds-obj then
       return bf_gds-obj.free-qnty .
   else
       return ? .
end.
else do:
   if available bf_gds-obj
     and buf_db.on-line-rest = true
   then
       return bf_gds-obj.on-line-rest .
   else
       return ? .
end.
end function.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1 TOOLTIP "Выход из экрана"
     BGCOLOR 8 .
DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 98 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FI-Filter-Label AS CHARACTER FORMAT "X(256)":U INITIAL "Фильтр:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67 NO-UNDO.
DEFINE VARIABLE firm-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 87.5 BY 1 TOOLTIP "Название фирмы, к которой относится объект"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE total-fact AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Количество по объектам"
     VIEW-AS FILL-IN
     SIZE 16.88 BY 1 TOOLTIP "Общее количество на всех объектах фирмы (всех фирм)"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE total-sum AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма по объектам в ценах продажи"
     VIEW-AS FILL-IN
     SIZE 16.88 BY 1 TOOLTIP "Остаток товара по всем объектам фирмы (фирм) в ценах продажи"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE ed_izm AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE total-fact-kg AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0
     LABEL "Количество по объектам"
     VIEW-AS FILL-IN
     SIZE 16.88 BY 1 TOOLTIP "Общее количество (кг) на всех объектах фирмы (всех фирм)"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-firm-global AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "&Фирма", "firm",
"&Глобально", "global"
     SIZE 16.5 BY 2.00 TOOLTIP "Остатки по объектам текущей фирмы или по всем фирмам"
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 77.50 BY 2.79.
DEFINE QUERY br-prt-obj FOR
      buf_temp_prt-obj SCROLLING.
DEFINE BROWSE br-prt-obj
  QUERY br-prt-obj NO-LOCK DISPLAY
      (buf_temp_prt-obj.obj-type + " " + string (buf_temp_prt-obj.obj-code, "99999"))
                                   column-label "Объект"           format "x(9)":U
      buf_temp_prt-obj.obj-name    column-label "Название объекта" format "x(25)":U
      f-on-line( buffer buf_temp_prt-obj ) @ p-need  column-label "On-line Ост."   format "->,>>>,>>9.<<<":U
      buf_temp_prt-obj.qnty        column-label "Количество"
      buf_temp_prt-obj.free-qnty   column-label "Свободно"
      buf_temp_prt-obj.price       column-label "Цена"             format ">,>>>,>>9.99":U
      buf_temp_prt-obj.fact-qty-kg column-label "Кол-во, кг"
      buf_temp_prt-obj.free-qty-kg column-label "Свободно, кг"
      buf_temp_prt-obj.price-kg    column-label "Цена за кг"       format ">,>>>,>>9.99":U
      buf_temp_prt-obj.sdate       column-label "Дата"             format "99/99/9999":U
      buf_temp_prt-obj.stime       column-label "Время"            format "x(8)":U
      buf_temp_prt-obj.db-num                                      format ">>9":U
      buf_temp_prt-obj.db-name                                     format "x(40)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.25.
DEFINE FRAME d-gds-objs
     b-quit          AT ROW  1.25 COL  1.00
     b-help          AT ROW  1.25 COL 11.00
     total-fact      AT ROW  1.67 COL 56.50 COLON-ALIGNED
     total-fact-kg   AT ROW  1.67 COL 74.50 COLON-ALIGNED NO-LABEL
     ed_izm          AT ROW  1.67 COL 92.00 COLON-ALIGNED NO-LABEL
     total-sum       AT ROW  2.67 COL 56.50 COLON-ALIGNED
     rs-firm-global  AT ROW  2.42 COL  2.00               NO-LABEL
     fi-description  AT ROW  5.25 COL  1.00               NO-LABEL
     br-prt-obj  AT ROW  6.54 COL  1.00
     firm-name       AT ROW 20.13 COL  7.50 COLON-ALIGNED
     FI-Filter-Label AT ROW  4.50 COL  1.75               NO-LABEL
     RECT-1          AT ROW  1.25 COL 21.38 SPACE( 0.98 ) SKIP( 16.78 )
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
     TITLE "Остатки по признаку" CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-gds-objs:SCROLLABLE       = FALSE
       FRAME d-gds-objs:HIDDEN           = TRUE.
ASSIGN
       br-prt-obj:NUM-LOCKED-COLUMNS IN FRAME d-gds-objs     = 1.
ON WINDOW-CLOSE OF FRAME d-gds-objs
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF br-prt-obj IN FRAME d-gds-objs
DO:
  define buffer host-b for ub.clients.
  if not available buf_temp_prt-obj then do: return no-apply. end.
  if buf_temp_prt-obj.obj-type = 'скл':U then do:
    find ub.store no-lock where ub.store.obj-code = buf_temp_prt-obj.obj-code.
    find host-b   no-lock where
         host-b.obj-type = 'орг':U and
         host-b.obj-code = ub.store.host-code.
  end.
  else do:
    find ub.shop no-lock where ub.shop.obj-code = buf_temp_prt-obj.obj-code.
    find host-b  no-lock where
         host-b.obj-type = 'орг':U and
         host-b.obj-code = ub.shop.host-code.
  end.
  assign  firm-name = host-b.obj-name.
  display firm-name with frame d-gds-objs.
END.
ON VALUE-CHANGED OF rs-firm-global IN FRAME d-gds-objs
DO:
  define variable is-glob as logical no-undo.
  assign rs-firm-global.
  if rs-firm-global = "global"
  then do:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_documents_all':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output is-glob
    )  .
end.
    if is-glob = no then do: assign rs-firm-global = "firm". end.
  end.
  run UI-on in this-procedure .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-gds-objs:PARENT eq ?
THEN FRAME d-gds-objs:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-gds-objs
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
on choose of b-help in frame d-gds-objs
do:
  apply "help":u to frame d-gds-objs .
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
                v-frame-width = frame d-gds-objs:width - 0.3
                fh            = frame d-gds-objs:first-child
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-gds-objs :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-gds-objs :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-gds-objs :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-gds-objs :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-gds-objs :height = v-frame-height
          .
          if frame d-gds-objs :scrollable = true
          then do:
            assign
              frame d-gds-objs :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-gds-objs :scrollable = true
          then do:
            assign
              frame d-gds-objs :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-gds-objs :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame d-gds-objs :height
      v-frame-virtual-height = frame d-gds-objs :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-gds-objs :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-gds-objs
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-gds-objs :scrollable = true
      then do:
        assign
          frame d-gds-objs :virtual-height = frame d-gds-objs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-gds-objs :height = frame d-gds-objs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-gds-objs :height = frame d-gds-objs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-gds-objs :scrollable = true
      then do:
        assign
          frame d-gds-objs :virtual-height = frame d-gds-objs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame d-gds-objs :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame d-gds-objs :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame d-gds-objs :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-gds-objs :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame d-gds-objs :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-gds-objs :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame d-gds-objs :width = v-frame-width
          .
          if frame d-gds-objs :scrollable = true
          then do:
            assign
              frame d-gds-objs :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-gds-objs :scrollable = true
          then do:
            assign
              frame d-gds-objs :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-gds-objs :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame d-gds-objs :width
      v-frame-virtual-width = frame d-gds-objs :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame d-gds-objs :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame d-gds-objs
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-gds-objs :scrollable = true
      then do:
        assign
          frame d-gds-objs :virtual-width = frame d-gds-objs :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-gds-objs :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame d-gds-objs :width = frame d-gds-objs :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-gds-objs :scrollable = true
      then do:
        assign
          frame d-gds-objs :virtual-width = frame d-gds-objs :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame d-gds-objs :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame d-gds-objs :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-gds-objs
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-gds-objs :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-gds-objs :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-gds-objs :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-gds-objs :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame d-gds-objs
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame d-gds-objs :height
      v-col-delta = v-new-col - frame d-gds-objs :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame d-gds-objs :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-gds-objs :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-gds-objs :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-gds-objs :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame d-gds-objs :width
      v-diasize-current-frame-height = frame d-gds-objs :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame d-gds-objs
    :
      assign
        v-diasize-orig-frame-height = frame d-gds-objs :height
        v-diasize-orig-frame-width  = frame d-gds-objs :width
        v-diasize-browse-handle     = browse br-prt-obj :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-gds-objs :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-prt-obj :SET-REPOSITIONED-ROW(8, "CONDITIONAL") .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame d-gds-objs anywhere
do:
  run UI-on in this-procedure .
    apply "VALUE-CHANGED" to br-prt-obj.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
    v-is-ptrl = ?
    is-petrol = ?
    is-pieces = ?
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-ptrl
  ,output v-data-type
  ) no-error .
  if error-status :error or v-data-type <> "L" or lookup( v-is-ptrl, "yes,no" ) = 0 then do: assign v-is-ptrl = "no". end.
  if v-is-ptrl = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input pp-artic
  ,  input pp-prod-type
  ,  input pp-prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if not error-status :error and is-petrol = yes and is-pieces = no then do:
      assign
        is-kg-visible = yes
      .
    end.
  end.
  if is-kg-visible <> yes then do:
    assign
      buf_temp_prt-obj.fact-qty-kg :visible in browse br-prt-obj = no
      buf_temp_prt-obj.free-qty-kg :visible in browse br-prt-obj = no
      buf_temp_prt-obj.price-kg    :visible in browse br-prt-obj = no
    .
    assign
      total-fact-kg :hidden in frame d-gds-objs = no
      ed_izm        :hidden in frame d-gds-objs = no
    .
  end.
  find first buf_goods no-lock where
             buf_goods.artic     = pp-artic     and
             buf_goods.prod-type = pp-prod-type and
             buf_goods.prod-code = pp-prod-code .
  if pp-node-code <> -1 then do:
    find first buf_gds-prt no-lock where buf_gds-prt.node-code = pp-node-code.
  end.
  assign
    rs-firm-global = 'firm':u
    ed_izm         = buf_goods.unit-cli
  .
  run UI-on in this-procedure .
  WAIT-FOR GO OF FRAME d-gds-objs FOCUS b-quit.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-gds-objs NO-PAUSE.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY total-fact total-sum rs-firm-global fi-description firm-name
          FI-Filter-Label
      WITH FRAME d-gds-objs.
  ENABLE b-quit b-help RECT-1 rs-firm-global br-prt-obj FI-Filter-Label
      WITH FRAME d-gds-objs.
  VIEW FRAME d-gds-objs.
  run UI-on in this-procedure .
END PROCEDURE.
PROCEDURE UI-on :
  define variable v-db-num    as integer no-undo.
  define variable v-root-node as integer no-undo.
  define buffer buf_db for ub.db .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  pp-artic
  ,input  pp-prod-type
  ,input  pp-prod-code
  ,output v-root-node
  ) no-error .
  if error-status :error then do:
    message vss-workfile vss-revision vss-description   skip
            "Ошибка при определении корневого признака" skip
    view-as alert-box error .
    undo, return error .
  end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  if v-db-num <> 0 then do:
    find first buf_db no-lock where buf_db.db-num = v-db-num no-error .
    if not available buf_db then do:
      message vss-workfile vss-revision vss-description skip
              "Ошибка при поиске базы данных" skip
              "База данных" v-db-num skip
      view-as alert-box error .
      undo, return error return-value .
    end.
    p-need:visible in browse br-prt-obj = false  .
    if buf_db.remote-stock = true then do:
      assign
        fi-description = "Приём информации об остатках из других БД включён."
      .
    end.
    else do:
      assign
        fi-description = "Приём информации об остатках из других БД выключен. Информация об остатках является устаревшей."
      .
    end.
  end.
  else do:
    p-need:visible in browse br-prt-obj = true   .
    assign
      fi-description = "Приём информации об остатках из других БД включён."
    .
  end.
  run waitfram-show     in this-procedure (  input "Считывание остатков" ) .
  run fill-temp_prt-obj in this-procedure (  input pp-artic,
                                             input pp-prod-type,
                                             input pp-prod-code,
                                             input pp-host-code,
                                             input ( if pp-node-code = -1 then v-root-node else pp-node-code ),
                                             input rs-firm-global,
                                             input is-kg-visible,
                                            output total-fact,
                                            output total-sum,
                                            output total-fact-kg                                             ) .
  run waitfram-hide     in this-procedure .
  display
    total-fact
    total-fact-kg  when is-kg-visible = yes
    ed_izm         when is-kg-visible = yes
    rs-firm-global
    total-sum
    fi-description
  with frame d-gds-objs .
  enable
    b-quit
    b-help
    br-prt-obj
    rs-firm-global
  with frame d-gds-objs .
  view frame d-gds-objs.
  if rs-firm-global = "firm" then do:
    assign frame d-gds-objs :title = 'Остатки по объектам текущей фирмы.'.
    OPEN QUERY br-prt-obj FOR EACH buf_temp_prt-obj NO-LOCK BY buf_temp_prt-obj.qnty DESCENDING.
  end.
  else do:
    assign frame d-gds-objs :title = 'Остатки по объектам всех фирм.'.
    OPEN QUERY br-prt-obj FOR EACH buf_temp_prt-obj NO-LOCK BY buf_temp_prt-obj.qnty DESCENDING.
  end.
  apply "VALUE-CHANGED":U to browse br-prt-obj.
  if pp-node-code = -1 then do:
    assign frame d-gds-objs :title = frame d-gds-objs :title + '   Артикул : ' + buf_goods.artic +
                                        '    ' + buf_goods.gds-name.
  end.
  else do:
    assign frame d-gds-objs :title = frame d-gds-objs :title + '   Артикул : ' + buf_goods.artic +
                                        '    Признак : ' + buf_gds-prt.f-name + '    ' + buf_goods.gds-name.
  end.
END PROCEDURE.
