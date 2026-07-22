block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-mat1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-mat1.p $":U .
define variable vss-description as character no-undo init "Общая процедура для изменений и добавлений товара в Ассортиментную матрицу".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-ind1 :
main-block:
  do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
define input-output parameter p-doc-rec  as recid no-undo.
define input  parameter p-gds-code                   like  ub.gds-obj-prop.gds-code no-undo.
define input  parameter p-obj-type                   like  ub.gds-obj-prop.obj-type no-undo.
define input  parameter p-obj-code                   like  ub.gds-obj-prop.obj-code no-undo.
define input  parameter p-gdop-igt                   like  ub.gds-obj-prop.gdop-igt no-undo.
define input  parameter p-gdop-assort-min            like  ub.gds-obj-prop.gdop-assort-min  no-undo.
define input  parameter p-gdop-min-stock             like  ub.gds-obj-prop.gdop-min-stock   no-undo.
define input  parameter p-grop-level-always-presence like  ub.gds-obj-prop.grop-level-always-presence  no-undo.
define input  parameter p-grop-max-stock             like  ub.gds-obj-prop.grop-max-stock              no-undo.
define input  parameter p-grop-min-order             like  ub.gds-obj-prop.grop-min-order              no-undo.
define buffer bufs_gds-obj-prop for ub.gds-obj-prop.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
run cur-time in this-procedure(output v-date, output v-time).
  find first bufs_gds-obj-prop exclusive-lock where
            bufs_gds-obj-prop.gds-code          = p-gds-code   and
            bufs_gds-obj-prop.obj-type          = p-obj-type   and
            bufs_gds-obj-prop.obj-code          = p-obj-code  no-error .
    if not available bufs_gds-obj-prop then do:
        create bufs_gds-obj-prop.
        assign
            bufs_gds-obj-prop.gds-code           = p-gds-code
            bufs_gds-obj-prop.grop-date-update   = v-date
            bufs_gds-obj-prop.grop-time-update   = v-time
            bufs_gds-obj-prop.grop-db-num-update = v-db-num
            bufs_gds-obj-prop.obj-type           = p-obj-type
            bufs_gds-obj-prop.obj-code           = p-obj-code
        no-error .
        if error-status :error then message "Ошибка при создании записи" error-status :error error-status :get-message(1) .
    end.
if  p-gdop-igt                     <> ? then    bufs_gds-obj-prop.gdop-igt                   = p-gdop-igt.
if  p-gdop-assort-min              <> ? then    bufs_gds-obj-prop.gdop-assort-min            = p-gdop-assort-min.
if  p-gdop-min-stock               <> ? then    bufs_gds-obj-prop.gdop-min-stock             = p-gdop-min-stock  .
if  p-grop-level-always-presence   <> ? then    bufs_gds-obj-prop.grop-level-always-presence = p-grop-level-always-presence.
if  p-grop-max-stock               <> ? then    bufs_gds-obj-prop.grop-max-stock             = p-grop-max-stock           .
if  p-grop-min-order               <> ? then    bufs_gds-obj-prop.grop-min-order             = p-grop-min-order           .
      p-doc-rec = recid(bufs_gds-obj-prop)    .
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ass-grp-gds-code-yes :
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-id         as integer   no-undo .
define input  parameter p-db-num     as integer   no-undo .
define output parameter p-ask        as logical   no-undo .
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define buffer buf_goods   for ub.goods  .
define buffer buf_gds-grp for ub.gds-grp  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .
define variable v-grp-qnty as integer   no-undo .
define variable v-grp-lim as integer   no-undo .
  do
  on error undo, return error return-value
  :
p-ask = ? .
find first  ub.assortment-matrix no-lock where
            ub.assortment-matrix.asmt-id  = p-id and
            ub.assortment-matrix.db-num   = p-db-num and
            ub.assortment-matrix.asmt-type =  'Шаблон':U
            no-error .
if available ub.assortment-matrix then do:
  p-ask = true .
  return .
end.
find first buf_gds-obj-prop no-lock where
          buf_gds-obj-prop.gds-code = p-gds-code and
          buf_gds-obj-prop.obj-type = ub.assortment-matrix.obj-type and
          buf_gds-obj-prop.obj-code = ub.assortment-matrix.obj-code and
          buf_gds-obj-prop.gdop-igt = 'На вывод из ассортимента':U no-error .
if available buf_gds-obj-prop then do:
  p-ask = true .
  return .
end.
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code .
find first buf_gds-grp-obj-attr no-lock where
           buf_gds-grp-obj-attr.attr-code = 'LimAssMat':U and
           buf_gds-grp-obj-attr.obj-type  = string(p-id) and
           buf_gds-grp-obj-attr.obj-code  = p-db-num and
           buf_gds-grp-obj-attr.host-code = 0 and
           buf_gds-grp-obj-attr.node-code = p-node-code no-error .
if error-status :error then do:
  p-ask = true .
  return .
end.
if buf_gds-grp-obj-attr.attr-value  = "0" then do:
  p-ask = false  .
  return .
end.
  if buf_gds-grp-obj-attr.attr-value  = "" or
    buf_gds-grp-obj-attr.attr-value  = ?  or
    buf_gds-grp-obj-attr.attr-value  = "?" then do:
    find first buf_gds-grp no-lock where
                buf_gds-grp.node-code = p-node-code no-error .
      if available buf_gds-grp  then do:
          if buf_gds-grp.upper-code = 0 then do:
              p-ask = true .
              return .
          end.
          else do:
              run ass-grp-gds-code-yes (
                 input   p-gds-code
                ,input   buf_gds-grp.upper-code
                ,input   p-id
                ,input   p-db-num
                ,output  p-ask
                ).
              if p-ask <> ? then return .
        end.
      end.
  end.
  else do:
    v-grp-lim = int (buf_gds-grp-obj-attr.attr-value) no-error  .
    if v-grp-lim > 0 then do:
        v-grp-qnty = 0 .
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = 'QntyAssMat':U and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
                   buf1_gds-grp-obj-attr.obj-code  = p-db-num and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = p-node-code no-error .
        if available buf1_gds-grp-obj-attr then do:
          v-grp-qnty = int(buf1_gds-grp-obj-attr.attr-value) .
        end.
        if v-grp-lim >= v-grp-qnty + 1 then p-ask = true .
        else p-ask = false .
        return .
    end.
  end.
  end.
end procedure.
procedure recalc-gds-assgrp :
define input  parameter p-action     as character no-undo .
define input  parameter p-gds-code  as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-id         as integer   no-undo .
define input  parameter p-db-num     as integer   no-undo .
define buffer buf_gds-grp for ub.gds-grp  .
define buffer curr_gds-grp for ub.gds-grp  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .
define variable kk as character no-undo .
  do
  on error undo, return error return-value
  :
find first  ub.assortment-matrix no-lock where
            ub.assortment-matrix.asmt-id  = p-id and
            ub.assortment-matrix.db-num   = p-db-num and
            ub.assortment-matrix.asmt-type =  'Шаблон':U
            no-error .
    if available ub.assortment-matrix then do:
      return .
    end.
    find first buf_gds-obj-prop no-lock where
               buf_gds-obj-prop.gds-code = p-gds-code and
               buf_gds-obj-prop.obj-type = ub.assortment-matrix.obj-type and
               buf_gds-obj-prop.obj-code = ub.assortment-matrix.obj-code and
               buf_gds-obj-prop.gdop-igt = 'На вывод из ассортимента':U
               no-error .
    if available buf_gds-obj-prop then do:
      if p-action <> '--' then  do:
         return .
      end.
    end.
    find first buf1_gds-grp-obj-attr exclusive-lock where
               buf1_gds-grp-obj-attr.attr-code = 'QntyAssMat':U and
               buf1_gds-grp-obj-attr.obj-type  = string(p-id) and
               buf1_gds-grp-obj-attr.obj-code  = p-db-num and
               buf1_gds-grp-obj-attr.host-code = 0 and
               buf1_gds-grp-obj-attr.node-code = p-node-code
               no-error .
    if available buf1_gds-grp-obj-attr then do:
       if p-action = '+' then  do:
          kk = string( int( buf1_gds-grp-obj-attr.attr-value ) + 1 ).
       end.
       else do:
          kk = string( int( buf1_gds-grp-obj-attr.attr-value ) - 1 ).
       end.
       buf1_gds-grp-obj-attr.attr-value = kk .
    end.
    else do:
        if p-action = '+' then  do:
            create buf1_gds-grp-obj-attr .
              assign
                buf1_gds-grp-obj-attr.attr-code  = 'QntyAssMat':U
                buf1_gds-grp-obj-attr.obj-type   = string(p-id)
                buf1_gds-grp-obj-attr.obj-code   = p-db-num
                buf1_gds-grp-obj-attr.host-code  = 0
                buf1_gds-grp-obj-attr.node-code  = p-node-code
                buf1_gds-grp-obj-attr.attr-value = "1"
              .
        end.
    end.
   FIND FIRST curr_gds-grp WHERE
              curr_gds-grp.node-code = p-node-code
        NO-LOCK NO-ERROR.
   if AVAILABLE curr_gds-grp AND curr_gds-grp.upper-code > 0 then do:
      run recalc-gds-assgrp (p-action ,p-gds-code , curr_gds-grp.upper-code,p-id,p-db-num ) .
   end.
  end.
end procedure.
define new global shared variable g#lib-Matrix  as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-longchar-asstro  as longchar no-undo .
define temp-table temp-goods no-undo
  field gds-code as integer
  field status_  as integer
  index pi gds-code
.
PROCEDURE translate-to-other :
define input  parameter p-asmt-id as integer   no-undo .
define input  parameter p-db-num  as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-recid as recid no-undo .
define buffer Oth_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .
define buffer bufs_gds-obj-prop for ub.gds-obj-prop  .
  find first  sh_assortment-matrix no-lock where
              sh_assortment-matrix.asmt-id = p-asmt-id and
              sh_assortment-matrix.db-num  = p-db-num  and
              sh_assortment-matrix.asmt-status = 0 and
              sh_assortment-matrix.asmt-type = 'Шаблон':U no-error .
if not available sh_assortment-matrix then return .
define variable v-doc-rec as recid no-undo .
define variable v-gds-prop-recid as recid no-undo .
define variable v-stt as integer   no-undo .
v-longchar-asstro = "".
   run waitfram-show in this-procedure  ("Передача изменений в связанные матрицы ... " ) .
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = 'Объект':U ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = 'RootShablon':U and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , p-asmt-id, p-db-num,chr(4))
            :
        run waitfram-show in this-procedure ( substitute(" Передаю изменения в Матрицу: &1" ,obj_assortment-matrix.asmt-name )) .
        for each temp-goods :
           if temp-goods.status_ = 0 then do:
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = temp-goods.gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if not available Oth_assortment-matrix-goods then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output v-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input ub.assortment-matrix-attr.asmt-id
 ,input ub.assortment-matrix-attr.db-num
 ,input temp-goods.gds-code
 ,input ''
  ) no-error .
                        if error-status :error then do:
                          v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                          next.
                        end.
                    end.
              end.
              else do:
                v-stt = 1.
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = temp-goods.gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if available Oth_assortment-matrix-goods then do:
                        v-recid = recid(Oth_assortment-matrix-goods).
                        find first bufs_gds-obj-prop exclusive-lock where
                                   bufs_gds-obj-prop.gds-code = Oth_assortment-matrix-goods.gds-code   and
                                   bufs_gds-obj-prop.obj-type = Oth_assortment-matrix-goods.obj-type   and
                                   bufs_gds-obj-prop.obj-code = Oth_assortment-matrix-goods.obj-code  no-error .
                        if not available bufs_gds-obj-prop
                          or not (bufs_gds-obj-prop.gdop-igt = 'Пусто':U or
                                  bufs_gds-obj-prop.gdop-igt = 'На вывод из ассортимента':U ) then do:
                        v-longchar-asstro = v-longchar-asstro +
                        substitute("Принудительная смена ИЖТ_ товара &1  на ПУСТО на объекте &2&3&4" ,
                            Oth_assortment-matrix-goods.gds-code ,
                            Oth_assortment-matrix-goods.obj-type ,
                            Oth_assortment-matrix-goods.obj-code ,
                            chr(10)) .
                        run gds-ind1
                            (input-output v-gds-prop-recid
                            ,Oth_assortment-matrix-goods.gds-code
                            ,Oth_assortment-matrix-goods.obj-type
                            ,Oth_assortment-matrix-goods.obj-code
                            ,'Пусто':U
                            ,?
                            ,?
                            ,?
                            ,?
                            ,?
                            ) no-error  .
                          end.
                          if not error-status :error then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input v-recid
 ,input-output v-stt
 ,input no
  ) no-error .
                                if error-status :error then do:
                                   v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                                end.
                           end.
                           else do:
                              v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                           end.
                    end.
               end.
        end.
   end.
   run waitfram-hide in this-procedure.
end.
END PROCEDURE.
PROCEDURE translate-to-other-gds :
define input  parameter p-asmt-id  as integer   no-undo .
define input  parameter p-db-num   as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-status_  as integer   no-undo .
  do
  on error undo, return error return-value
  :
define buffer Oth_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer obj_assortment-matrix for ub.assortment-matrix  .
define buffer sh_assortment-matrix for ub.assortment-matrix  .
define buffer bufs_gds-obj-prop for ub.gds-obj-prop  .
  find first  sh_assortment-matrix no-lock where
              sh_assortment-matrix.asmt-id = p-asmt-id and
              sh_assortment-matrix.db-num  = p-db-num  and
              sh_assortment-matrix.asmt-status = 0 and
              sh_assortment-matrix.asmt-type = 'Шаблон':U no-error .
if not available sh_assortment-matrix then return .
define variable v-doc-rec as recid no-undo .
define variable v-gds-prop-recid as recid no-undo .
define variable v-stt as integer   no-undo .
define variable v-recid as recid no-undo .
 v-longchar-asstro = "" .
   for each obj_assortment-matrix no-lock where
            obj_assortment-matrix.asmt-status = 0 and
            obj_assortment-matrix.asmt-type = 'Объект':U ,
      first ub.assortment-matrix-attr no-lock where
            ub.assortment-matrix-attr.asmt-id    = obj_assortment-matrix.asmt-id and
            ub.assortment-matrix-attr.db-num     = obj_assortment-matrix.db-num and
            ub.assortment-matrix-attr.attr-code  = 'RootShablon':U and
            ub.assortment-matrix-attr.attr-value = substitute("&1&3&2" , p-asmt-id, p-db-num,chr(4))
            :
           if p-status_ = 0 then do:
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = p-gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if not available Oth_assortment-matrix-goods then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat1 in g#lib-Matrix
 (input this-procedure
 ,input-output v-doc-rec
 ,input 'ДОБАВЛЕНИЕ':U
 ,input ub.assortment-matrix-attr.asmt-id
 ,input ub.assortment-matrix-attr.db-num
 ,input p-gds-code
 ,input ''
  ) no-error .
                        if error-status :error then do:
                           v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                           next.
                        end.
                    end.
              end.
              else do:
                v-stt = 1.
                find first Oth_assortment-matrix-goods no-lock where
                            Oth_assortment-matrix-goods.asmt-id  = ub.assortment-matrix-attr.asmt-id and
                            Oth_assortment-matrix-goods.db-num   = ub.assortment-matrix-attr.db-num  and
                            Oth_assortment-matrix-goods.gds-code = p-gds-code and
                            Oth_assortment-matrix-goods.asmg-status = 0 no-error .
                    if available Oth_assortment-matrix-goods then do:
                        v-recid = recid(Oth_assortment-matrix-goods) .
                        find first bufs_gds-obj-prop exclusive-lock where
                                   bufs_gds-obj-prop.gds-code = Oth_assortment-matrix-goods.gds-code   and
                                   bufs_gds-obj-prop.obj-type = Oth_assortment-matrix-goods.obj-type   and
                                   bufs_gds-obj-prop.obj-code = Oth_assortment-matrix-goods.obj-code  no-error .
                        if not available bufs_gds-obj-prop
                          or not (bufs_gds-obj-prop.gdop-igt = 'Пусто':U or
                                  bufs_gds-obj-prop.gdop-igt = 'На вывод из ассортимента':U ) then do:
                        v-longchar-asstro = v-longchar-asstro +
                        substitute("Принудительная смена ИЖТ. товара &1  на ПУСТО на объекте &2&3&4" ,
                            Oth_assortment-matrix-goods.gds-code ,
                            Oth_assortment-matrix-goods.obj-type ,
                            Oth_assortment-matrix-goods.obj-code ,
                            chr(10)) .
                        run gds-ind1
                            (input-output v-gds-prop-recid
                            ,Oth_assortment-matrix-goods.gds-code
                            ,Oth_assortment-matrix-goods.obj-type
                            ,Oth_assortment-matrix-goods.obj-code
                            ,'Пусто':U
                            ,?
                            ,?
                            ,?
                            ,?
                            ,?
                            ) no-error  .
                           end.
                           if not error-status :error then do:
if (valid-handle(g#lib-Matrix) <> true) then do:   run ref/gds-mat1.p persistent no-error .   if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do:     message       "Error starting library.p" skip       g#lib-Matrix skip       g#lib-Matrix :type skip       g#lib-Matrix :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run main_gds-mat2 in g#lib-Matrix
 (input this-procedure
 ,input v-recid
 ,input-output v-stt
 ,input no
  ) no-error .
                                if error-status :error then do:
                                   v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                                end.
                           end.
                           else do:
                             v-longchar-asstro = v-longchar-asstro + return-value + chr(10) .
                           end.
                    end.
               end.
   end.
end.
END PROCEDURE.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable p-ask as logical   no-undo .
DEFINE VARIABLE l_Is-Fin_This-Procedure            as LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE l_Is-Add-no-gds_This-Procedure     as LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE c_Error_This-Procedure             as CHARACTER  NO-UNDO INITIAL "".
define stream LogStream.
if valid-handle (g#lib-Matrix)
and g#lib-Matrix <> this-procedure :handle
and g#lib-Matrix :get-signature('lib-Matrix_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#lib-Matrix skip
    g#lib-Matrix :type skip
    g#lib-Matrix :file-name skip
    valid-handle(g#lib-Matrix) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#lib-Matrix = this-procedure :handle
  .
end.
if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.
RUN Set_Variable_This-Procedure IN THIS-PROCEDURE.
on delete of this-procedure do:
  assign
    g#lib-Matrix = ?
  .
end.
procedure lib-Matrix_testproc :
end.
FUNCTION Is-Goods-in-Cont-Spec RETURN LOGICAL(
         INPUT p-iGds-Code as INTEGER
         ):
   DEFINE BUFFER Spec FOR ub.Contract-Specif.
   RETURN (CAN-FIND (FIRST Spec WHERE Spec.Gds-code = p-iGds-Code NO-LOCK)).
END FUNCTION.
PROCEDURE Set_Variable_This-Procedure:
   DEFINE VARIABLE is-finvalue   as CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE is-fintype    as CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE v-Db-Num      as INTEGER   NO-UNDO INITIAL 0.
   ASSIGN
      l_Is-Fin_This-Procedure         = FALSE
      l_Is-Add-no-gds_This-Procedure  = FALSE
      c_Error_This-Procedure          = ""
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-finvalue
  ,output is-fintype
  ) no-error .
   ASSIGN
      l_Is-Fin_This-Procedure =  LOGICAL(is-finvalue)
      NO-ERROR.
   if ERROR-STATUS:ERROR THEN DO:
   END.
   if l_Is-Fin_This-Procedure THEN DO:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-db-num
    ,input  g#userid
    ,input  0
    ,input  'actn_assort-matr_add-no-gds':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output l_Is-Add-no-gds_This-Procedure
    )  .
end.
      if NOT l_Is-Add-no-gds_This-Procedure  THEN DO:
         ASSIGN
            c_Error_This-Procedure = RETURN-VALUE.
      END.
   END.
   RETURN.
END PROCEDURE.
procedure main_gds-mat1 :
define input  parameter p-handle as handle no-undo .
define input-output parameter p-doc-rec   as recid no-undo.
define input parameter p-mode             as character no-undo .
define input parameter p-id               like ub.assortment-matrix.asmt-id   no-undo .
define input parameter p-db-num           like ub.assortment-matrix.db-num    no-undo .
define input parameter p-gds-code         like ub.assortment-matrix-goods.gds-code  no-undo .
define input parameter p-des              like ub.assortment-matrix-goods.asmg-des  no-undo .
  do
  on error undo, return error return-value
  :
if p-mode <> 'ДОБАВЛЕНИЕ':U AND p-mode <> 'ИЗМЕНЕНИЕ':U  then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_assortment-matrix for ub.assortment-matrix .
define buffer new_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer old_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf_goods for ub.goods  .
define variable v-flaf as logical   no-undo .
v-flaf = false .
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
find first buf_assortment-matrix no-lock where
           buf_assortment-matrix.asmt-id =  p-id       and
           buf_assortment-matrix.db-num  =  p-db-num no-error .
           if error-status :error then return error error-status :get-message(1)  .
run cur-time in this-procedure(output v-date, output v-time).
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
     if l_Is-Fin_This-Procedure
        AND (NOT Is-Goods-in-Cont-Spec(p-gds-code))
        AND (l_Is-Add-no-gds_This-Procedure <> TRUE )
        THEN DO:
        RETURN ERROR c_Error_This-Procedure + chr(10) + "Код товара (gds-code)=" + STRING(p-gds-code).
     END.
  find first new_assortment-matrix-goods exclusive-lock where
             new_assortment-matrix-goods.gds-code           = p-gds-code and
             new_assortment-matrix-goods.asmt-id            = p-id       and
             new_assortment-matrix-goods.db-num             = p-db-num
             no-error .
        if available new_assortment-matrix-goods then do:
            if new_assortment-matrix-goods.asmg-status  = 0 then p-mode = 'ИЗМЕНЕНИЕ':U .
            else do:
                run ass-grp-gds-code-yes (
                    input  p-gds-code   ,
                    input  buf_goods.grp-code ,
                    input  p-id         ,
                    input  p-db-num     ,
                    output p-ask        ) no-error .
                    if error-status :error  or p-ask = false  then do:
                        return error substitute ( "Нельзя добавлять товар &1 &2 в Ассортиментную матрицу &3(&4) из-за ограничения по ассортименту в группе &5 &6 " ,buf_goods.gds-code  , buf_goods.gds-name , p-id ,p-db-num , return-value , chr(10) ).
                    end.
            end.
            assign
              new_assortment-matrix-goods.asmg-date-update   = v-date
              new_assortment-matrix-goods.asmg-db-num-update = g#db-num
              new_assortment-matrix-goods.asmg-status        = 0
              new_assortment-matrix-goods.asmg-time-update   = v-time
              new_assortment-matrix-goods.asmg-who-update    = g#userid
              new_assortment-matrix-goods.asmt-id            = p-id
              .
        end.
        else do:
            run  ass-grp-gds-code-yes (
                input  p-gds-code   ,
                input  buf_goods.grp-code ,
                input  p-id         ,
                input  p-db-num     ,
                output p-ask        ) no-error .
                if error-status :error  or p-ask = false  then do:
                    return error substitute (
                    "Нельзя добавлять товар &1 &2 в Ассортиментную матрицу &3(&4) из-за ограничения по ассортименту в группе &5&6", buf_goods.gds-code  ,buf_goods.gds-name  , p-id ,p-db-num , return-value , chr(10)  ).
                end.
            create ub.assortment-matrix-goods.
            assign
              ub.assortment-matrix-goods.asmg-date-create   = v-date
              ub.assortment-matrix-goods.asmg-date-update   = v-date
              ub.assortment-matrix-goods.asmg-db-num-create = g#db-num
              ub.assortment-matrix-goods.asmg-db-num-update = g#db-num
              ub.assortment-matrix-goods.asmg-status        = 0
              ub.assortment-matrix-goods.asmg-time-create   = v-time
              ub.assortment-matrix-goods.asmg-time-update   = v-time
              ub.assortment-matrix-goods.asmg-who-create    = g#userid
              ub.assortment-matrix-goods.asmg-who-update    = g#userid
              ub.assortment-matrix-goods.asmt-id            = p-id
              ub.assortment-matrix-goods.db-num             = p-db-num
              ub.assortment-matrix-goods.gds-code           = p-gds-code
              ub.assortment-matrix-goods.asmg-des           = p-des
              .
              FIND FIRST  new_assortment-matrix-goods exclusive-lock  where
                  new_assortment-matrix-goods.asmt-id  = p-id and
                  new_assortment-matrix-goods.db-num   = p-db-num   no-error .
        end.
        p-doc-rec = recid(new_assortment-matrix-goods)   .
  end.
  else do:
    FIND FIRST  new_assortment-matrix-goods exclusive-lock where
         recid (new_assortment-matrix-goods) = p-doc-rec No-ERROR.
    if not available new_assortment-matrix-goods then do:
       message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись - p-doc-rec" p-doc-rec
        view-as alert-box error .
        undo, return error '':u.
    end.
    if new_assortment-matrix-goods.asmt-id <> p-id
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Для уже имеющейся записи нельзя изменить"
        "внутренний код" skip
        view-as alert-box ERROR.
        undo, return error '':U.
    end.
    if new_assortment-matrix-goods.asmg-status <> 0 then v-flaf = true .
  end.
  assign
    new_assortment-matrix-goods.asmg-des    = p-des
    new_assortment-matrix-goods.asmg-status = 0
  .
  if v-flaf or p-mode = 'ДОБАВЛЕНИЕ':U then do:
  end.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    run chg-izt-proc
    ( p-gds-code,
      buffer buf_assortment-matrix )
      no-error .
      if error-status :error then do:
      end.
end.
  define variable v-econom as logical   no-undo .
  v-econom = false .
  run econom-mode in p-handle  (output v-econom ) no-error .
  if not v-econom  then do:
     run translate-to-other-gds (
          p-id       ,
          p-db-num   ,
          p-gds-code ,
          0 ) .
       if v-longchar-asstro <> "" then do:
         run correct-message in p-handle  (input v-longchar-asstro ) no-error .
         v-longchar-asstro =  "".
       end.
  end.
end procedure.
procedure chg-izt-proc :
define input     parameter p-gds-code                   as integer   no-undo .
define parameter buffer buf_assortment-matrix for ub.assortment-matrix .
define buffer buf_goods for ub.goods.
define variable v-gds-prop-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
  if buf_assortment-matrix.obj-type <> "" and buf_assortment-matrix.obj-type <> ? then do:
        run gds-ind1
            ( input-output v-gds-prop-recid
            ,  p-gds-code
            ,  buf_assortment-matrix.obj-type
            ,  buf_assortment-matrix.obj-code
            , 'Новинка':U
            , ?
            , ?
            , ?
            , ?
            , ?
            )  no-error .
            if error-status :error then do:
                message vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value
                  skip "Ошибка внутр. процедуры gds-ind1"
                  view-as alert-box error .
            end.
  end.
  end.
end procedure.
procedure main_gds-mat2 :
  define input parameter p-handle as handle no-undo .
  define input parameter p-recid  as recid  no-undo.
  define input-output parameter p-asmg-status like ub.assortment-matrix-goods.asmg-status no-undo .
  define input parameter p-mess as logical   no-undo .
  do
  on error undo, return error return-value
  :
define buffer bf-assortment-matrix-goods for ub.assortment-matrix-goods.
define variable loc#log as logical no-undo .
define variable choice as logical no-undo .
define variable v-old-asmg-status like ub.assortment-matrix-goods.asmg-status no-undo .
define variable v-db-num as integer   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define buffer buf_goods for ub.goods  .
define variable v-gds-code as integer   no-undo .
define variable v-id       as integer   no-undo .
define variable v-db-num1  as integer   no-undo .
find first bf-assortment-matrix-goods exclusive-lock where
           recid(bf-assortment-matrix-goods) = p-recid.
  v-id       = bf-assortment-matrix-goods.asmt-id .
  v-db-num1   = bf-assortment-matrix-goods.db-num  .
find first buf_goods no-lock where buf_goods.gds-code = bf-assortment-matrix-goods.gds-code no-error .
 v-gds-code  = buf_goods.gds-code .
 choice = true .
define buffer buf_assortment-matrix for ub.assortment-matrix .
find first buf_assortment-matrix no-lock where
           buf_assortment-matrix.asmt-id =  bf-assortment-matrix-goods.asmt-id and
           buf_assortment-matrix.db-num  =  bf-assortment-matrix-goods.db-num
           no-error .
           if error-status :error then return error error-status :get-message(1)  .
v-old-asmg-status = bf-assortment-matrix-goods.asmg-status.
if p-asmg-status = ? then do:
  CASE v-old-asmg-status:
    when integer('0':U) then do:
      assign
      p-asmg-status = integer('1':U).
    end.
    when integer('1':U) then do:
      assign
      p-asmg-status = integer('0':U).
    end.
  END CASE.
end.
CASE p-asmg-status:
  WHEN integer('0':U) then do:
    if integer('0':U) = bf-assortment-matrix-goods.asmg-status  then do:
      if p-mess then message "Запись уже имеет статус ТЕКУЩИЙ!"
                              view-as alert-box ERROR.
      p-asmg-status = ?.
      return error.
    end.
    else do:
      if p-mess then do:
          message  "Запись уже удалена - восстановить?"
                   view-as alert-box QUestion buttons YEs-no update choice.
       end.
    end.
  end.
  WHEN integer('1':U) then do:
    if integer('1':U) = bf-assortment-matrix-goods.asmg-status  then do:
      if p-mess then message "Запись уже имеет статус УДАЛЕН!"
                              view-as alert-box ERROR.
      p-asmg-status = ?.
      return error.
    end.
    else do:
      if p-mess then  do:
          message  "Удалить строку в  Ассортиментной матрице?"
                   view-as alert-box QUestion buttons yes-no update choice.
       end.
    end.
  end.
END CASE.
if p-asmg-status  = 0 then do:
    define variable p-ask as logical   no-undo .
    run ass-grp-gds-code-yes (
        input  buf_goods.gds-code ,
        input  buf_goods.grp-code ,
        input  v-id          ,
        input  v-db-num1     ,
        output p-ask        ) no-error .
        if error-status :error  or p-ask = false  then do:
          message substitute("Нельзя добавлять товар &1 &2 в Ассортиментную матрицу  &4(&5) из-за ограничения по ассортименту в группе &3", buf_goods.gds-code  ,buf_goods.gds-name , return-value ,
            v-id ,  v-db-num1 ) skip
            return-value skip error-status :get-message(1)
            view-as alert-box information .
            undo , return error substitute("Нельзя добавлять товар &1 &2 в Ассортиментную матрицу  &4(&5) из-за ограничения по ассортименту в группе &3 &6", buf_goods.gds-code  ,buf_goods.gds-name , return-value ,
                                          v-id ,  v-db-num1 , chr(10) ) .
        end.
end.
define variable p-ok as logical no-undo .
 define variable v-err-str as character no-undo .
 v-err-str = "" .
if choice then do:
   if integer('1':U) = p-asmg-status  then do:
      run chg-izt-proc2 (
          buffer buf_assortment-matrix ,
          buffer bf-assortment-matrix-goods ,
          output p-ok ) .
      if p-ok =  false then do:
          assign
            bf-assortment-matrix-goods.asmg-status = p-asmg-status
            v-err-str = ""
          .
      end.
      else do:
         v-err-str =  substitute("НЕ УДАЛИЛИ из матрицы, так как сработало правило в событие <УДАЛЕНИЕ товара из матрицы>  &1" , "" ) .
      end.
   end.
   else do:
      assign
        bf-assortment-matrix-goods.asmg-status = p-asmg-status
      .
    end.
end.
  release bf-assortment-matrix-goods no-error .
  if error-status:error then do:
    p-asmg-status = ?.
    message
    "Ошибка при сохранении записи Ассортиментной Матрицы" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo , return error .
  end.
  define variable v-econom as logical   no-undo .
  v-econom = false .
  run econom-mode in p-handle  (output v-econom ) no-error .
  if not v-econom  then do:
     run translate-to-other-gds (
          v-id       ,
          v-db-num   ,
          v-gds-code ,
          p-asmg-status ) no-error .
       if v-longchar-asstro <> "" or v-err-str <> "" then do:
           run correct-message in p-handle  (input v-longchar-asstro + " " + v-err-str) no-error .
       end.
  end.
return v-err-str .
end.
end procedure.
procedure chg-izt-proc2 :
define parameter buffer buf_assortment-matrix for ub.assortment-matrix .
define parameter buffer bf-assortment-matrix-goods for ub.assortment-matrix-goods .
define output parameter choice2 as logical   no-undo  .
  do
  on error undo, return error return-value
  :
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .
define variable v-amin  as logical   no-undo .
define variable v-izt   as character no-undo .
define variable v-gdop-min-stock                as decimal   no-undo .
define variable v-grop-max-stock                as decimal   no-undo .
define variable v-grop-level-always-presence    as decimal   no-undo .
define variable v-grop-min-order                as decimal   no-undo .
define variable p-old  as character no-undo .
define variable p-new  as character no-undo .
define variable v-gds-prop-recid as recid no-undo .
define variable v-event-code as character no-undo .
define variable v-izt-new    as logical   no-undo .
define variable v-izt-com    as logical   no-undo .
define variable v-izt-del    as logical   no-undo .
define variable v-izt-spec   as logical   no-undo .
define variable v-izt-empty  as logical   no-undo .
choice2 = false .
  if buf_assortment-matrix.obj-type <> "" and buf_assortment-matrix.obj-type <> ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjpr in g#library
  (input  buf_assortment-matrix.obj-type
  ,input  buf_assortment-matrix.obj-code
  ,input  ?
  ,input  ?
  ,input  ?
  ,input  bf-assortment-matrix-goods.gds-code
  ,output v-amin
  ,output v-izt
  ,output v-gdop-min-stock
  ,output v-grop-max-stock
  ,output v-grop-level-always-presence
  ,output v-grop-min-order
  )  .
      find first buf_goods no-lock where
                 buf_goods.gds-code = bf-assortment-matrix-goods.gds-code no-error .
                 if not available buf_goods then return error error-status :get-message(1) .
      find first buf_gds-obj no-lock where
                 buf_gds-obj.gds-code = bf-assortment-matrix-goods.gds-code and
                 buf_gds-obj.obj-type = buf_assortment-matrix.obj-type and
                 buf_gds-obj.obj-code = buf_assortment-matrix.obj-code
                 no-error .
         if available buf_gds-obj and buf_gds-obj.fact-qnty <> 0 then do:
             v-event-code = 'delete-matr-rest':U .
         end.
         else do:
            v-event-code = 'delete-matr-norest':U .
         end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run iztrul in g#library2
  (input  v-event-code
  ,output v-izt-new
  ,output v-izt-com
  ,output v-izt-del
  ,output v-izt-spec
  ,output v-izt-empty
  )  .
      case v-izt :
      when 'На вывод из ассортимента':U
      then do:
        choice2 = true .
        if v-izt-del = false then  choice2 = true  .
                             else  choice2 = false .
        if choice2 = true  then do:
        if v-amin = true then do:
            message "У товара " buf_goods.artic  buf_goods.gds-name skip
                      "ИЖТ = " v-izt skip
            substitute ("Остаток товара на  &1 &2 = &3" , buf_gds-obj.obj-type , buf_gds-obj.obj-code , buf_gds-obj.fact-qnty )
            skip
            if v-amin = true then "входит в Ассортиментный минимум" else ""
            skip
            "Оставляем его в Ассортиментной матрице ? "
            view-as alert-box question buttons yes-no update choice2 .
        end.
        end.
      end.
      when "" or when ? or when 'Пусто':U
      then do:
        if v-izt-empty = false then   choice2 = true .
                               else   choice2 = false .
      end.
      otherwise do:
          message "Удалить можно только тоавары с ИЖТ" 'На вывод из ассортимента':U skip
            buf_goods.artic buf_goods.gds-name "пропускаем"
            view-as alert-box information .
            choice2 = true.
      end.
      end case.
      if choice2 = false then do:
          p-old = 'На вывод из ассортимента':U    .
          p-new = 'Пусто':U  .
        find first buf_gds-obj-prop no-lock  where
                   buf_gds-obj-prop.gds-code = buf_goods.gds-code and
                   buf_gds-obj-prop.obj-code = buf_assortment-matrix.obj-code and
                   buf_gds-obj-prop.obj-type = buf_assortment-matrix.obj-type no-error .
           if not available buf_gds-obj-prop then
           do:
               run gds-ind1
                ( input-output v-gds-prop-recid
                , bf-assortment-matrix-goods.gds-code
                , buf_assortment-matrix.obj-type
                , buf_assortment-matrix.obj-code
                , p-new
                , ?
                , ?
                , ?
                , ?
                , ?
                )   .
              end.
              else do:
                  if buf_gds-obj-prop.gdop-igt = p-old then do:
                      run gds-ind1
                          (input-output v-gds-prop-recid
                          ,buf_gds-obj-prop.gds-code
                          ,buf_gds-obj-prop.obj-type
                          ,buf_gds-obj-prop.obj-code
                          ,p-new
                          ,?
                          ,?
                          ,?
                          ,?
                          ,?
                          )  .
                  end.
              end.
      end.
  end.
  end.
end procedure.
procedure clear-longmess :
  do
  on error undo, return error return-value
  :
    v-longchar-asstro = "".
  end.
end procedure.
