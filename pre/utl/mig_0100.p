block-level on error undo, throw.
using Ibs.Th.Gbl.ProgressBar.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mig_0100.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mig_0100.p $":U .
define variable vss-description as character no-undo init "Модификация таблиц о МПЛ".
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
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .
define input parameter p-db-num         as integer   no-undo .
define input parameter p-cli-code       as integer   no-undo .
define input parameter log-file-name   as character  no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prg-bar_progress-bar  as class ProgressBar  no-undo .
  procedure prg-bar_new-progress-bar :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      run prg-bar_delete-progress-bar in this-procedure .
    end.
    v-prg-bar_progress-bar = new progressbar( p-min , p-max ).
  end.
  end procedure.
  procedure prg-bar_delete-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      delete object v-prg-bar_progress-bar.
      assign
        v-prg-bar_progress-bar = ?
      .
    end.
  end.
  end procedure.
  procedure prg-bar_show-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :show-bar() .
    end.
  end.
  end procedure.
  procedure prg-bar_increment-progress-bar :
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      v-prg-bar_progress-bar :increment() .
    end.
  end.
  end procedure.
  procedure prg-bar_title-progress-bar :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
      assign
        v-prg-bar_progress-bar :frame-title = p-str
      .
    end.
  end.
  end procedure.
  procedure prg-bar_stepto-progress-bar :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if v-prg-bar_progress-bar <> ?
    then do:
        v-prg-bar_progress-bar :stepto( p-val ) .
    end.
  end.
  end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prg-bar_cb-handle     as handle             no-undo .
  procedure prg-bar_init-cb-handle :
    define input  parameter p-cb-handle as handle    no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle( p-cb-handle )
    then do:
      assign
        v-prg-bar_cb-handle = p-cb-handle
      .
    end.
    else do:
      assign
        v-prg-bar_cb-handle = ?
      .
    end.
  end.
  end procedure.
  procedure prg-bar_new :
    define input  parameter p-min as int64   no-undo .
    define input  parameter p-max as int64   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_new-progress-bar in v-prg-bar_cb-handle ( input p-min , input p-max ).
    end.
  end.
  end procedure.
  procedure prg-bar_delete :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_delete-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.
  procedure prg-bar_show :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_show-progress-bar in v-prg-bar_cb-handle .
    end.
  end.
  end procedure.
  procedure prg-bar_increment :
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_increment-progress-bar in v-prg-bar_cb-handle.
    end.
  end.
  end procedure.
  procedure prg-bar_title :
    define input  parameter p-str as character no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_title-progress-bar in v-prg-bar_cb-handle ( input p-str ) .
    end.
  end.
  end procedure.
  procedure prg-bar_stepto :
    define input  parameter p-val as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(v-prg-bar_cb-handle)
    then do:
      run prg-bar_stepto-progress-bar in v-prg-bar_cb-handle ( input p-val ) .
    end.
  end.
  end procedure.
define variable v-progress-bar as class ProgressBar no-undo .
run prg-bar_init-cb-handle in this-procedure ( this-procedure ) .
define variable v-tot-rec as int64   no-undo .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Множественные прайс-листы") ).
on write  of ub.price-list-type   override do: end .
on write  of ub.grp-obj-price     override do: end .
on delete of ub.price-list-type-attr override do: end .
on delete of ub.price-list-type-cash-pay override do: end .
on delete of ub.price-list-type-cassa override do: end .
on delete of ub.price-list-type-gds-grp override do: end .
on delete of ub.price-list-type-pay-type override do: end .
on delete of ub.price-doc-forming-attr   override do: end .
on delete of ub.price-doc-forming-gds    override do: end .
on delete of ub.price-all                override do: end .
on delete of ub.price-doc-forming        override do: end .
on delete of ub.price-list-type override do: end .
on delete of ub.grp-obj-price override do: end .
  do
  on error undo, return error return-value
  :
  v-tot-rec = 0 .
  for each ub.grp-obj-price no-lock  :
    v-tot-rec = v-tot-rec + 1.
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-rec).
  run prg-bar_title in this-procedure ( input "Удаление чужих множественных прайс листов...":U).
  run prg-bar_show in this-procedure .
  for each ub.grp-obj-price exclusive-lock :
      run prg-bar_increment in this-procedure .
      run metod-gop-obj (
          0 ,
          ub.grp-obj-price.gop-id ,
          ub.grp-obj-price.gop-db-num  ) .
      if not can-find(first x_obj-group)  then do:
         for each ub.price-list-type exclusive-lock where
                  ( ub.price-list-type.gop-id     = ub.grp-obj-price.gop-id and
                    ub.price-list-type.gop-db-num = ub.grp-obj-price.gop-db-num ) or
                  ( ub.price-list-type.gop-id-for-calc-turnover     = ub.grp-obj-price.gop-id and
                    ub.price-list-type.gop-db-num-for-calc-turnover = ub.grp-obj-price.gop-db-num ) :
            for each  ub.price-list-type-attr exclusive-lock where
                      ub.price-list-type-attr.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-attr.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-attr.
            end.
            for each  ub.price-list-type-cash-pay exclusive-lock where
                      ub.price-list-type-cash-pay.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-cash-pay.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-cash-pay.
            end.
            for each  ub.price-list-type-cassa exclusive-lock where
                      ub.price-list-type-cassa.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-cassa.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-cassa.
            end.
            for each  ub.price-list-type-gds-grp exclusive-lock where
                      ub.price-list-type-gds-grp.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-gds-grp.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-gds-grp.
            end.
            for each  ub.price-list-type-pay-type exclusive-lock where
                      ub.price-list-type-pay-type.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-list-type-pay-type.plt-id     = ub.price-list-type.plt-id
                      :
                      delete ub.price-list-type-pay-type.
            end.
            for each ub.price-doc-forming exclusive-lock where
                      ub.price-doc-forming.plt-db-num = ub.price-list-type.plt-db-num    and
                      ub.price-doc-forming.plt-id     = ub.price-list-type.plt-id
                      :
            for each ub.price-doc-forming-attr exclusive-lock where
                    ub.price-doc-forming-attr.pdf-db        = ub.price-doc-forming.pdf-db      and
                    ub.price-doc-forming-attr.pdf-id        = ub.price-doc-forming.pdf-id      and
                    ub.price-doc-forming-attr.plt-db-num    = ub.price-doc-forming.plt-db-num  and
                    ub.price-doc-forming-attr.plt-id        = ub.price-doc-forming.plt-id
                    :
                    delete ub.price-doc-forming-attr.
            end.
            for each ub.price-doc-forming-gds exclusive-lock where
                     ub.price-doc-forming-gds.plt-db-num    = ub.price-doc-forming.plt-db-num  and
                     ub.price-doc-forming-gds.plt-id        = ub.price-doc-forming.plt-id      and
                     ub.price-doc-forming-gds.pdf-db        = ub.price-doc-forming.pdf-db      and
                     ub.price-doc-forming-gds.pdf-id        = ub.price-doc-forming.pdf-id
                    :
                    delete ub.price-doc-forming-gds.
            end.
            for each ub.price-all exclusive-lock where
                    ub.price-all.pdf-db        = ub.price-doc-forming.pdf-db      and
                    ub.price-all.pdf-id        = ub.price-doc-forming.pdf-id      and
                    ub.price-all.plt-db-num    = ub.price-doc-forming.plt-db-num  and
                    ub.price-all.plt-id        = ub.price-doc-forming.plt-id
                    :
                    delete ub.price-all.
            end.
               delete ub.price-doc-forming.
            end.
            delete ub.price-list-type.
         end.
         for each ub.host-grp-obj-price  exclusive-lock where
                  ub.host-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id and
                  ub.host-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num :
              delete ub.host-grp-obj-price.
         end.
         for each ub.db-grp-obj-price  exclusive-lock where
                  ub.db-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id and
                  ub.db-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num :
              delete ub.db-grp-obj-price.
         end.
         for each ub.obj-grp-obj-price  exclusive-lock where
                  ub.obj-grp-obj-price.gop-id     = ub.grp-obj-price.gop-id and
                  ub.obj-grp-obj-price.gop-db-num = ub.grp-obj-price.gop-db-num :
              delete ub.obj-grp-obj-price.
         end.
         delete ub.grp-obj-price.
      end.
  end.
  run prg-bar_delete-progress-bar in this-procedure .
  end.
