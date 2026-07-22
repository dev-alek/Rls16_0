block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Библиотека процедур работы со сверками":U.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#libbcrcn as handle no-undo .
  define new global shared variable g#lib-rvs as handle no-undo.
  define temp-table tt-param no-undo
    field strfrfile as character
    field strasi    as character
    field flddb     as character
    index pi        as primary   unique strfrfile
    index asi strasi.
  define temp-table tt-param-pump no-undo
    field strfrfile as character
    field meaning   as character
    index pi        as primary   unique strfrfile.
  define temp-table tt-meas no-undo like ub.place
    field measure-qnty like ub.rvs-line.measure-qnty
    field brutto-qnty like ub.rvs-line.brutto-qnty
    field measure-cli-qnty like ub.rvs-line.measure-cli-qnty
    field brutto-cli-qnty like ub.rvs-line.brutto-cli-qnty
    field density like ub.rvs-line.density
    field temperature like ub.rvs-line.temperature
    field level-total like ub.rvs-line.level-total
    field level-petrol like ub.rvs-line.level-petrol
    field level-water like ub.rvs-line.level-water
    field temp-layer1 like ub.rvs-line.temp-layer1
    field temp-layer2 like ub.rvs-line.temp-layer2
    field temp-layer3 like ub.rvs-line.temp-layer3
    field measure-tc-qnty like ub.rvs-line.measure-tc-qnty
    field brutto-tc-qnty like ub.rvs-line.brutto-tc-qnty
    field meas-vol-oil   as logical initial no
    field meas-vol-water as logical initial no
    field water-qnty     like ub.rvs-line.measure-qnty
    field vapor-density like ub.rvs-line.density
    field vapor-pressure as decimal format ">>9.9<":U
    field log-brutto as logical
    field temp-not-null as logical
    field t1-not-null as logical
    field t2-not-null as logical
    field t3-not-null as logical
    field is-error    as logical
    index pi        as primary   loc1.
  define temp-table tt-meas-file no-undo like tt-meas.
  define temp-table tt-pump-nozzle no-undo like ub.pump-nozzle
    field gds-code    like ub.goods.gds-code
    field meas-el-cnt like ub.rvs-line-pump.meas-el-cnt
    field meas-am-cnt like ub.rvs-line-pump.meas-am-cnt
    field grade       as   character
    field meas-cf-cnt like ub.rvs-line-pump.meas-cf-cnt.
  define temp-table tt-pump-nozzle-file no-undo like tt-pump-nozzle.
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
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function objExists return character
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
function SearchFile return character
(input  ifile as character):
   return objExists(ifile,?).
end.
function SearchPFile return character
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
define temp-table tt-place no-undo
  field loc1          as character  label "№ резервуара"
  field locint        as integer    label "№ резервуара"           init ?
  field pl-code       as integer    label "Код резервуара"
  field gds-code      as integer    label "Код продукта"
  field gds-name      as character  label "НАИМЕНОВАНИЕ ПРОДУКТА"
  field level-total   as decimal    label "Общий уровень (см)"
  field level-water   as decimal    label "Уровень воды (см)"
  field total-vol     as decimal    label "Общий объем (л)"
  field avrg-temp     as decimal    label "Средняя Т"
  field t1            as decimal    label "T1"
  field t2            as decimal    label "T2"
  field t3            as decimal    label "T3"
  field density       as decimal    label "Плотность (кг/л)"
  field mass          as decimal    label "Масса (кг)"
  field vapor-density as decimal    label "Плотность СУГ (кг/л)"
  field vapor-pressure as decimal   label "Давление СУГ (мПа)"
  field volume_water  as decimal
  field is-error      as logical
  field error-message as character
  index pi as unique
    loc1
  index locint as primary locint loc1
.
define stream str-file.
procedure readfiletxt:
   define input  parameter i_File-Name   as character no-undo.
   define output parameter Otext as longchar no-undo.
   define variable v_string-tmp as character no-undo.
   if searchfile(i_File-Name) eq ?
   then
      return.
   input  stream str-file from  value (i_File-Name)   .
   repeat :
      import stream str-file unformatted v_string-tmp.
      Otext = Otext + v_string-tmp + chr(10).
   end.
   input  stream str-file close.
end procedure.
procedure readrevisetxt:
   define input  parameter i_Str         as Longchar no-undo.
   define input  parameter i_StartString as character no-undo.
   define input  parameter i_comment     as character no-undo.
   define variable v_string-tmp          as character no-undo.
   define variable v-bh                  as handle  no-undo .
   define variable v-fh                  as handle  no-undo .
   define variable vi                    as integer no-undo.
   for each tt-place:
      tt-place.is-error       = yes.
   end.
   rpt:
   do vi = 1 to num-entries(i_Str,chr(10)) :
      v_string-tmp = entry(vi, i_Str,chr(10)).
      if index( v_string-tmp, i_comment ) > 0
      then do:
         v_string-tmp = substring( v_string-tmp, 1, index( v_string-tmp, i_comment ) - 1 ).
      end.
      if v_string-tmp = '':U
      then
         next rpt .
      if index( v_string-tmp, i_StartString ) > 0
      then do:
         find first tt-place where tt-place.loc1 = trim( entry( 2, v_string-tmp, '=' ) ) no-error .
         if not available tt-place
         then do :
           create tt-place .
           assign tt-place.loc1 = trim( entry( 2, v_string-tmp, '=' ) )
                  tt-place.locint   = int(tt-place.loc1)
           no-error .
         end.
         assign
             tt-place.t1             = ?
             tt-place.t2             = ?
             tt-place.t3             = ?
             tt-place.level-total    = ?
             tt-place.level-water    = ?
             tt-place.total-vol      = ?
             tt-place.avrg-temp      = ?
             tt-place.density        = ?
             tt-place.mass           = ?
             tt-place.vapor-density  = ?
             tt-place.vapor-pressure = ?
             tt-place.volume_water   = ?
             tt-place.is-error       = no
             tt-place.error-message  = ?
         .
      end.
      else do:
         if not available tt-place
         then
            next rpt .
         find first tt-param where tt-param.strfrfile = trim( entry( 1, v_string-tmp, '=' ) ) no-error.
         if available tt-param
         then do:
            v-bh = buffer tt-place:handle.
            assign
               v-fh                = v-bh:buffer-field( tt-param.strasi )
               v-fh:buffer-value() = decimal( trim( entry( 2, v_string-tmp, '=' ) ) )
            no-error.
            if (tt-param.flddb = "temperature"
             or tt-param.flddb = "water-qnty")
            and trim( entry( 2, v_string-tmp, '=' ) ) = "-"
            then do :
              assign
                 v-fh:buffer-value() = ?
              no-error.
            end .
         end.
         else do:
            run gbl/fileapnd.p
                  ( 'revis.err'
                  ,
               if trim( entry( 1, v_string-tmp, '=' ) ) = "ERROR"
               then
                  substitute("&1 &2  Ошибка: &3 &4", string(today),string(time, "HH:MM:SS"),  trim( entry( 2, v_string-tmp, '=' ) ), chr(13) + chr(10))
               else
                  substitute("&1 &2  Неизвестный параметр: &3 &4", string(today),string(time, "HH:MM:SS"), trim( entry( 1, v_string-tmp, '=' ) ), chr(13) + chr(10))
               ,input 10
             ) no-error .
         end.
      end.
   end.
   for each tt-place:
      tt-place.vapor-pressure = tt-place.vapor-pressure / 1000.
   end.
end procedure.
procedure get-from-struna :
  define input  parameter i-log-file-name as character no-undo.
  define input  parameter i-obj-code as integer no-undo.
  define variable v-comstring as character no-undo .
  define variable v_File-Name as character no-undo .
  define variable v_command as character no-undo .
  define variable v-comment     as character no-undo.
  define variable v-StartString as character no-undo.
  define variable Vrevis        as longchar no-undo.
  define variable vi as integer no-undo.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crtt-rvs in g#lib-rvs ( input-output table tt-param ,
                            output       v-comstring ,
                            output       v-comment ,
                            output       v-StartString ) no-error .
    if error-status :error then do:
      return error substitute( 'Ошибка при установке параметров для считывания данных с резервуаров.&1&2&1&3'
                            , chr(10)
                            , error-status :get-message( 1 )
                            , return-value ) .
    end.
   v_File-Name = searchfile('revis.txt').
   if v_File-Name ne ?
   then do:
      block-del-file:
      do vi = 1 to 5:
         os-delete value( v_File-Name ) .
         v_File-Name = searchfile('revis.txt').
         if v_File-Name eq ?
         then
            leave block-del-file.
     end.
   end.
   if v_File-Name ne ?
   then
      return error 'Файл revis.txt заблокирован удалите файл и попробуйте еще раз. ' + v_File-Name .
   if    v-comstring = '':U
      or v-comstring = ?
   then do:
      return error 'Не задан парам. comstr в секции revision ini файла.' .
   end.
   v_File-Name = "wrevis" + string(random(1000000,9999999)) + ".tmp".
   if searchfile(v_File-Name) ne ?
   then do :
      v_File-Name = "wrevis" + string(random(1000000,9999999)) + ".tmp".
      if searchfile(v_File-Name) ne ?
      then do :
        os-delete value(searchfile(v_File-Name)) no-error .
      end.
      if searchfile(v_File-Name) ne ?
      then
        return error "Удалите все файлы wrevis*.tmp".
   end.
   assign
      v_command = substitute( "&1 &2 &3 &4", v-comstring, string(0), v_File-Name, i-obj-code)
   .
   os-command silent value( v_command ) .
   if searchfile(v_File-Name) ne ?
   then
      run readfiletxt (v_File-Name, output Vrevis).
   run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Запрос &3&4", string(today),string(time, "HH:MM:SS"), v_command, chr(13) + chr(10))
          ,input 10
          ) no-error .
   if searchfile( v_File-Name ) = ? then do:
      run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("Файл с прибора не получен. &1",  chr(13) + chr(10))
          ,input 10
          ) no-error .
      return error 'Файл с прибора не получен.' .
  end.
  else do:
      v_File-Name  = searchfile( v_File-Name ) .
  end.
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Данные &3", string(today),string(time, "HH:MM:SS"), chr(13) + chr(10))
          ,input 10
          ) no-error .
  os-append value(v_File-Name) value(i-log-file-name).
  os-rename value( v_File-Name ) 'revis.txt'.
  os-delete value( v_File-Name ) .
  run gbl/fileapnd.p
          ( i-log-file-name
          , chr(13) + chr(10)
          ,input 10
          ) no-error .
  run readrevisetxt (Vrevis,v-StartString,v-comment).
end procedure .
procedure get-from-ifsf :
   define input  parameter i-log-file-name as character no-undo.
   define input  parameter i-asi-ip        as character no-undo.
   define input  parameter i-asi-port      as character no-undo.
  define variable v_command     as   character     no-undo.
  define variable v-log     as logical no-undo .
  define variable v-bytes   as integer no-undo .
  define variable v-out-data as character no-undo .
  define variable v-line-str as character no-undo .
  define variable ii        as integer no-undo .
  define variable str       as character no-undo .
  define variable str1      as character no-undo .
  define variable str2      as character no-undo .
  define variable hSocket   as handle no-undo .
  define variable mDataIn   as memptr no-undo .
  define variable mDataout  as memptr no-undo .
  define variable cmd       as character no-undo .
  define variable connStr   as character no-undo .
  define variable v-attr-type   as character no-undo.
  define variable v-comstring   as character no-undo.
  define variable v-comment     as character no-undo.
  define variable v-StartString as character no-undo.
  define variable Vrevis        as longchar no-undo.
  define variable vi as integer no-undo.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crtt-rvs in g#lib-rvs ( input-output table tt-param ,
                            output       v-comstring ,
                            output       v-comment ,
                            output       v-StartString ) no-error .
    if error-status :error then do:
      return error substitute( 'Ошибка при установке параметров для считывания данных с резервуаров.&1&2&1&3'
                            , chr(10)
                            , error-status :get-message( 1 )
                            , return-value ) .
    end.
  cmd = 'KOI8-R 1 0 1' + chr(10) .
  set-size(mDataIn) = 0 .
  set-size(mDataIn) = length(cmd , "RAW":U) + 1 .
  put-string(mDataIn,1) = cmd .
  find first sys-ctrl no-lock.
  if i-asi-ip eq ? or i-asi-ip eq ""
  then
     run db-attr-value(sys-ctrl.db,"AsiIp",output i-asi-ip,output v-attr-type).
  if i-asi-port eq ? or i-asi-port eq ""
  then
     run db-attr-value(sys-ctrl.db,"AsiPort",output i-asi-port,output v-attr-type).
  create socket hSocket .
  connStr = '-H ' + i-asi-ip + ' -S ' + i-asi-port .
  hSocket:connect(connStr) no-error.
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Запрос  connStr='-H &3  -S &4 '  cmd='KOI8-R 1 0 1'&5", string(today),string(time, "HH:MM:SS"),i-asi-ip,i-asi-port, chr(13) + chr(10))
          ,input 10
          ) no-error .
  if hSocket:connected() = false
  then do :
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу подключиться к IFSF серверу." , chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу подключиться к IFSF серверу." .
  end.
  hSocket:set-socket-option('TCP-NODELAY', 'true').
  hSocket:set-socket-option('SO-KEEPALIVE', 'true').
  hSocket:set-socket-option('SO-REUSEADDR', 'true').
  v-log = hSocket:write(mDataIn, 1, get-size(mDataIn)) no-error.
  if v-log = false or error-status:get-message(1) <> ''
  then do:
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу отправить команду на IFSF сервер.", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу отправить команду на IFSF сервер." .
  end.
  run sleep (1000) .
  set-size(mDataOut) = 0 .
  v-bytes = hSocket:get-bytes-available() .
  set-size(mDataOut) = v-bytes + 1 .
  v-log = hSocket:read(mDataOut, 1, v-bytes, 2) no-error.
  if v-log = false or error-status:get-message(1) <> ''
  then do:
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу прочитать ответ от IFSF сервера.", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу прочитать ответ от IFSF сервера." .
  end.
  v-out-data = get-string(mDataOut,1) .
  if v-out-data = ""
  then do :
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Не могу получить данные от IFSF сервера.", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error "Не могу получить данные от IFSF сервера." .
  end.
  if index(v-out-data, "Bad Request") > 0
  then do :
    hSocket:disconnect() no-error.
    run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2 &3 &4", string(today),string(time, "HH:MM:SS"), "Bad Request", chr(13) + chr(10))
          ,input 10
          ) no-error .
    return error v-out-data .
  end.
  hSocket:disconnect() no-error.
  delete object hSocket.
  set-size(mDataIn) = 0.
  set-size(mDataOut)   = 0.
  run gbl/fileapnd.p
          ( i-log-file-name
          ,substitute("&1 &2  Данные &3", string(today),string(time, "HH:MM:SS"), chr(13) + chr(10))
          ,input 10
          ) no-error .
   run gbl/fileapnd.p
          ( i-log-file-name
          , v-out-data
          ,input 10
          ) no-error .
   run gbl/fileapnd.p
          ( i-log-file-name
          , chr(13) + chr(10)
          ,input 10
          ) no-error .
  output to "revis.ifsf" .
  do vi = 1 to num-entries(v-out-data, chr(10)) :
    put unformatted entry(vi, v-out-data, chr(10)) skip .
  end.
  output close.
  run readrevisetxt (v-out-data,v-StartString,v-comment).
end procedure .
procedure parse-xml :
  define input parameter iStr as longchar .
  define variable hDoc              as handle     no-undo .
  define variable hRoot             as handle     no-undo .
  for each tt-place:
      tt-place.is-error       = yes.
  end.
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF hRoot.
  hDoc:LOAD("longchar",iStr,FALSE).
  hDoc:GET-DOCUMENT-ELEMENT(hRoot).
  RUN GetChildren(hRoot, 1).
  DELETE OBJECT hDoc.
  DELETE OBJECT hRoot.
end procedure .
PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText    AS HANDLE NO-UNDO.
define variable client   as character no-undo.
define variable good                as logical   no-undo .
define variable v-asi-error-code    as integer   no-undo initial 0 .
define variable v-asi-error-message as character no-undo .
CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .
REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    hNoderef:GET-CHILD(hText, 1) no-error .
    IF hNoderef:NAME = "ErrNum"
    then do :
      v-asi-error-code = integer(hText:node-value) no-error .
    end .
    IF hNoderef:NAME = "ErrMsg"
    then do :
      v-asi-error-message = hText:node-value no-error .
      if     v-asi-error-code > 0
         and v-asi-error-code ne 2
      then do :
        assign
          tt-place.t1             = ?
          tt-place.t2             = ?
          tt-place.t3             = ?
          tt-place.level-total    = ?
          tt-place.level-water    = ?
          tt-place.total-vol      = ?
          tt-place.avrg-temp      = ?
          tt-place.density        = ?
          tt-place.mass           = ?
          tt-place.vapor-density  = ?
          tt-place.vapor-pressure = ?
          tt-place.volume_water   = ?
          tt-place.is-error       = true
          tt-place.error-message  = v-asi-error-message
        .
      end .
    end .
    IF hNoderef:NAME = "Tank"
    then do :
      find first tt-place where tt-place.loc1 = hText:node-value no-error .
      if not available tt-place
      then do :
        create tt-place .
        assign tt-place.loc1     = hText:node-value
               tt-place.locint   = int(tt-place.loc1)
        no-error .
      end.
      assign
          v-asi-error-code        = 0
          tt-place.t1             = ?
          tt-place.t2             = ?
          tt-place.t3             = ?
          tt-place.level-total    = ?
          tt-place.level-water    = ?
          tt-place.total-vol      = ?
          tt-place.avrg-temp      = ?
          tt-place.density        = ?
          tt-place.mass           = ?
          tt-place.vapor-density  = ?
          tt-place.vapor-pressure = ?
          tt-place.volume_water   = ?
          tt-place.is-error       = no
          tt-place.error-message  = ?
      .
    end.
    if    v-asi-error-code = 0
       or v-asi-error-code = 2
    then do :
      IF hNoderef:NAME = "LevelTotal" then assign tt-place.level-total = decimal(hText:node-value) / 10 no-error .
      IF hNoderef:NAME = "LevelWater" then assign tt-place.level-water = decimal(hText:node-value) / 10 no-error .
      IF hNoderef:NAME = "Temperature" then assign tt-place.avrg-temp = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Density" then assign tt-place.density = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VolumeTotal" then assign tt-place.total-vol = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "MassTotal" then assign tt-place.mass = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VaporDensity" then assign tt-place.vapor-density = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "VaporPressure" then assign tt-place.vapor-pressure = decimal(hText:node-value) / 1000 no-error .
      IF hNoderef:NAME = "Temperature1" then assign tt-place.t1 = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Temperature2" then assign tt-place.t2 = decimal(hText:node-value) no-error .
      IF hNoderef:NAME = "Temperature3" then assign tt-place.t3 = decimal(hText:node-value) no-error .
    end .
    RUN GetChildren(hNoderef, (level + 1)).
END.
DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
function MM6 returns logical
  (
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt6"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 56
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(26, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(27, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(28, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(29, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM7 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt7"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM13 returns logical
 (
  input Mpokr as decimal,
  input Rprov as decimal,
  input Vdisp as decimal,
  input CoverFloatingHeight as decimal,
  input H as decimal,
  input H_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input P0 as decimal,
  input Pv as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input ToolType as integer,
  input DeltaOtn_K as decimal,
  input DeadZone_Reservoir as decimal,
  input A_Reservoir as decimal,
  input A_LevelMeasurementTool as decimal,
  input ToolAutomationLevel_H as integer,
  input ToolAutomationLevel_H_Water as integer,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_H_CalcType as integer,
  input DeltaAbs_H_Water_CalcType as integer,
  input DeltaAbs_H as decimal,
  input DeltaAbs_H_Water as decimal,
  input DeltaAbs_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total as decimal,
  output V_water as decimal,
  output DeltaV as decimal,
  output V_product as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output DeltaOtn_Vm as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output VolumetricExpansion as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt13"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 61
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", Mpokr).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Rprov).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Vdisp).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", CoverFloatingHeight).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", P0).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(19, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeadZone_Reservoir).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", A_LevelMeasurementTool).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", DeltaAbs_H_CalcType).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", DeltaAbs_H_Water_CalcType).
  hCall:SET-PARAMETER(30, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(31, "DOUBLE", "INPUT", DeltaAbs_H_Water).
  hCall:SET-PARAMETER(32, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(33, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(34, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(35, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(36, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(37, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(38, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(39, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(40, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", V_total).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", V_water).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", V_product).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(50, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(51, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", DeltaOtn_Vm).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(60, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(61, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM14 returns logical
  (
  input M1 as decimal,
  input M2 as decimal,
  input H1 as decimal,
  input H2 as decimal,
  input H1_water as decimal,
  input H2_water as decimal,
  input CalibrationTable as character,
  input CalibrationBelt as character,
  input Tv1 as decimal,
  input Tv2 as decimal,
  input Tr1 as decimal,
  input Tr2 as decimal,
  input R1 as decimal,
  input R2 as decimal,
  input ToolType1 as integer,
  input ToolType2 as integer,
  input DeltaOtn_K as decimal,
  input OperDirection as integer,
  input ToolAutomationLevel_H1 as integer,
  input ToolAutomationLevel_H2 as integer,
  input ToolAutomationLevel_H_Water1 as integer,
  input ToolAutomationLevel_H_Water2 as integer,
  input ToolAutomationLevel_R1 as integer,
  input ToolAutomationLevel_R2 as integer,
  input ToolAutomationLevel_Tv1 as integer,
  input ToolAutomationLevel_Tv2 as integer,
  input ToolAutomationLevel_Tr1 as integer,
  input ToolAutomationLevel_Tr2 as integer,
  input DeltaAbs_H_CalcType1 as integer,
  input DeltaAbs_H_CalcType2 as integer,
  input DeltaAbs_H_Water_CalcType1 as integer,
  input DeltaAbs_H_Water_CalcType2 as integer,
  input DeltaAbs_H1 as decimal,
  input DeltaAbs_H2 as decimal,
  input DeltaAbs_H_Water1 as decimal,
  input DeltaAbs_H_Water2 as decimal,
  input DeltaAbs_R1 as decimal,
  input DeltaAbs_R2 as decimal,
  input DeltaAbs_Tv1 as decimal,
  input DeltaAbs_Tv2 as decimal,
  input DeltaAbs_Tr1 as decimal,
  input DeltaAbs_Tr2 as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output V_total1 as decimal,
  output V_total2 as decimal,
  output V_water1 as decimal,
  output V_water2 as decimal,
  output Delta_V1 as decimal,
  output Delta_V2 as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt14"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 59
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", M1).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M2).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", H1).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", H2).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", H1_water).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", H2_water).
  hCall:SET-PARAMETER(10, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(11, "CHARACTER", "INPUT", CalibrationBelt).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tv1).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Tv2).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Tr1).
  hCall:SET-PARAMETER(15, "DOUBLE", "INPUT", Tr2).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", R1).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", R2).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolType1).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolType2).
  hCall:SET-PARAMETER(20, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", OperDirection).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", ToolAutomationLevel_H1).
  hCall:SET-PARAMETER(23, "LONG", "INPUT", ToolAutomationLevel_H2).
  hCall:SET-PARAMETER(24, "LONG", "INPUT", ToolAutomationLevel_H_Water1).
  hCall:SET-PARAMETER(25, "LONG", "INPUT", ToolAutomationLevel_H_Water2).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", ToolAutomationLevel_R1).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", ToolAutomationLevel_R2).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", ToolAutomationLevel_Tv1).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", ToolAutomationLevel_Tv2).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", ToolAutomationLevel_Tr1).
  hCall:SET-PARAMETER(31, "LONG", "INPUT", ToolAutomationLevel_Tr2).
  hCall:SET-PARAMETER(32, "LONG", "INPUT", DeltaAbs_H_CalcType1).
  hCall:SET-PARAMETER(33, "LONG", "INPUT", DeltaAbs_H_CalcType2).
  hCall:SET-PARAMETER(34, "LONG", "INPUT", DeltaAbs_H_Water_CalcType1).
  hCall:SET-PARAMETER(35, "LONG", "INPUT", DeltaAbs_H_Water_CalcType2).
  hCall:SET-PARAMETER(36, "DOUBLE", "INPUT", DeltaAbs_H1).
  hCall:SET-PARAMETER(37, "DOUBLE", "INPUT", DeltaAbs_H2).
  hCall:SET-PARAMETER(38, "DOUBLE", "INPUT", DeltaAbs_H_Water1).
  hCall:SET-PARAMETER(39, "DOUBLE", "INPUT", DeltaAbs_H_Water2).
  hCall:SET-PARAMETER(40, "DOUBLE", "INPUT", DeltaAbs_R1).
  hCall:SET-PARAMETER(41, "DOUBLE", "INPUT", DeltaAbs_R2).
  hCall:SET-PARAMETER(42, "DOUBLE", "INPUT", DeltaAbs_Tv1).
  hCall:SET-PARAMETER(43, "DOUBLE", "INPUT", DeltaAbs_Tv2).
  hCall:SET-PARAMETER(44, "DOUBLE", "INPUT", DeltaAbs_Tr1).
  hCall:SET-PARAMETER(45, "DOUBLE", "INPUT", DeltaAbs_Tr2).
  hCall:SET-PARAMETER(46, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(47, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(48, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(49, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(50, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(51, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(52, "DOUBLE", "OUTPUT", V_total1).
  hCall:SET-PARAMETER(53, "DOUBLE", "OUTPUT", V_total2).
  hCall:SET-PARAMETER(54, "DOUBLE", "OUTPUT", V_water1).
  hCall:SET-PARAMETER(55, "DOUBLE", "OUTPUT", V_water2).
  hCall:SET-PARAMETER(56, "DOUBLE", "OUTPUT", Delta_V1).
  hCall:SET-PARAMETER(57, "DOUBLE", "OUTPUT", Delta_V2).
  hCall:SET-PARAMETER(58, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(59, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM26A returns logical
  (
  input Type as integer,
  input Diameter as decimal,
  input Length as decimal,
  input Width as decimal,
  input Circumference as decimal,
  input Wall as decimal,
  output Area as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt26A"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 12
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", Type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", Diameter).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", Length).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", Width).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", Circumference).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Wall).
  hCall:SET-PARAMETER(10, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(11, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(12, "DOUBLE", "OUTPUT", Area).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM31N returns logical
  (
  input V_real as decimal,
  input DeltaCorrectionType as integer,
  input CalibrationTable as character,
  input DeltaH as decimal,
  input NeckArea as decimal,
  input Tv as decimal,
  input Tr as decimal,
  input R as decimal,
  input Tcy as decimal,
  input Pr as decimal,
  input Pv as decimal,
  input ToolType as integer,
  input A_Reservoir as decimal,
  input DeltaOtn_V as decimal,
  input ToolAutomationLevel_R as integer,
  input ToolAutomationLevel_Tv as integer,
  input ToolAutomationLevel_Tr as integer,
  input DeltaAbs_R as decimal,
  input DeltaOtn_R as decimal,
  input DeltaAbs_Tv as decimal,
  input DeltaAbs_Tr as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output DeltaV_GT as decimal,
  output DeltaV as decimal,
  output Vcy as decimal,
  output Rcy as decimal,
  output Rcy20 as decimal,
  output V as decimal,
  output CTL_base_alt as decimal,
  output CPL_base_alt as decimal,
  output CTPL_base_alt as decimal,
  output Fp_base_alt as decimal,
  output CTL_obs_base as decimal,
  output CPL_obs_base as decimal,
  output CTPL_obs_base as decimal,
  output Fp_obs_base as decimal,
  output VolumetricExpansion as decimal,
  output Rv as decimal,
  output DeltaOtn_Vcy as decimal,
  output M as decimal,
  output DeltaOtn_M as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt31N"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 49
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", V_real).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", DeltaCorrectionType).
  hCall:SET-PARAMETER(6, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", DeltaH).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", NeckArea).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", Tv).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", Tr).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", Tcy).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", Pr).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", Pv).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_V).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", ToolAutomationLevel_R).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", ToolAutomationLevel_Tv).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", ToolAutomationLevel_Tr).
  hCall:SET-PARAMETER(21, "DOUBLE", "INPUT", DeltaAbs_R).
  hCall:SET-PARAMETER(22, "DOUBLE", "INPUT", DeltaOtn_R).
  hCall:SET-PARAMETER(23, "DOUBLE", "INPUT", DeltaAbs_Tv).
  hCall:SET-PARAMETER(24, "DOUBLE", "INPUT", DeltaAbs_Tr).
  hCall:SET-PARAMETER(25, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(26, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(27, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(28, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(29, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(30, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", DeltaV_GT).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaV).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", Vcy).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", Rcy).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", Rcy20).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", V).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", CTL_base_alt).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", CPL_base_alt).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", CTPL_base_alt).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", Fp_base_alt).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", CTL_obs_base).
  hCall:SET-PARAMETER(42, "DOUBLE", "OUTPUT", CPL_obs_base).
  hCall:SET-PARAMETER(43, "DOUBLE", "OUTPUT", CTPL_obs_base).
  hCall:SET-PARAMETER(44, "DOUBLE", "OUTPUT", Fp_obs_base).
  hCall:SET-PARAMETER(45, "DOUBLE", "OUTPUT", VolumetricExpansion).
  hCall:SET-PARAMETER(46, "DOUBLE", "OUTPUT", Rv).
  hCall:SET-PARAMETER(47, "DOUBLE", "OUTPUT", DeltaOtn_Vcy).
  hCall:SET-PARAMETER(48, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(49, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM53 returns logical
  (
  input H as decimal,
  input CalibrationTable as character,
  input T as decimal,
  input R_liquid as decimal,
  input R_gas as decimal,
  input A_Reservoir as decimal,
  input DeltaOtn_K as decimal,
  input DeltaOtn_K_full as decimal,
  input DeltaAbs_H as decimal,
  input DeltaAbs_R_liquid as decimal,
  input DeltaAbs_R_gas as decimal,
  input Use_DeltaOtn_R_liquid_IN as integer,
  input DeltaOtn_R_liquid_IN as decimal,
  input DeltaOtn_N as decimal,
  input Round_M as integer,
  input Round_T as integer,
  input Round_R as integer,
  output C_HN as decimal,
  output C_HN_delta as decimal,
  output C_full as decimal,
  output V_liquid as decimal,
  output V_gas as decimal,
  output M_liquid as decimal,
  output M_gas as decimal,
  output M as decimal,
  output Kf as decimal,
  output DeltaOtn_H as decimal,
  output DeltaOtn_R_liquid as decimal,
  output DeltaOtn_R_gas as decimal,
  output DeltaOtn_M_liquid as decimal,
  output DeltaOtn_M_gas as decimal,
  output DeltaOtn_M as decimal,
  output H_min_liquid as decimal,
  output H_min as decimal,
  output A as decimal,
  output B as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt53"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 41
  .
  if DeltaOtn_R_liquid_IN = 0.42
  then
    DeltaOtn_R_liquid_IN = DeltaOtn_R_liquid_IN - 0.0000000001
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "CHARACTER", "INPUT", CalibrationTable).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "DOUBLE", "INPUT", R_liquid).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", R_gas).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", A_Reservoir).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", DeltaOtn_K).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", DeltaOtn_K_full).
  hCall:SET-PARAMETER(12, "DOUBLE", "INPUT", DeltaAbs_H).
  hCall:SET-PARAMETER(13, "DOUBLE", "INPUT", DeltaAbs_R_liquid).
  hCall:SET-PARAMETER(14, "DOUBLE", "INPUT", DeltaAbs_R_gas).
  hCall:SET-PARAMETER(15, "SHORT", "INPUT", Use_DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(16, "DOUBLE", "INPUT", DeltaOtn_R_liquid_IN).
  hCall:SET-PARAMETER(17, "DOUBLE", "INPUT", DeltaOtn_N).
  hCall:SET-PARAMETER(18, "LONG", "INPUT", Round_M).
  hCall:SET-PARAMETER(19, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(20, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(21, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(22, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(23, "DOUBLE", "OUTPUT", C_HN).
  hCall:SET-PARAMETER(24, "DOUBLE", "OUTPUT", C_HN_delta).
  hCall:SET-PARAMETER(25, "DOUBLE", "OUTPUT", C_full).
  hCall:SET-PARAMETER(26, "DOUBLE", "OUTPUT", V_liquid).
  hCall:SET-PARAMETER(27, "DOUBLE", "OUTPUT", V_gas).
  hCall:SET-PARAMETER(28, "DOUBLE", "OUTPUT", M_liquid).
  hCall:SET-PARAMETER(29, "DOUBLE", "OUTPUT", M_gas).
  hCall:SET-PARAMETER(30, "DOUBLE", "OUTPUT", M).
  hCall:SET-PARAMETER(31, "DOUBLE", "OUTPUT", Kf).
  hCall:SET-PARAMETER(32, "DOUBLE", "OUTPUT", DeltaOtn_H).
  hCall:SET-PARAMETER(33, "DOUBLE", "OUTPUT", DeltaOtn_R_liquid).
  hCall:SET-PARAMETER(34, "DOUBLE", "OUTPUT", DeltaOtn_R_gas).
  hCall:SET-PARAMETER(35, "DOUBLE", "OUTPUT", DeltaOtn_M_liquid).
  hCall:SET-PARAMETER(36, "DOUBLE", "OUTPUT", DeltaOtn_M_gas).
  hCall:SET-PARAMETER(37, "DOUBLE", "OUTPUT", DeltaOtn_M).
  hCall:SET-PARAMETER(38, "DOUBLE", "OUTPUT", H_min_liquid).
  hCall:SET-PARAMETER(39, "DOUBLE", "OUTPUT", H_min).
  hCall:SET-PARAMETER(40, "DOUBLE", "OUTPUT", A).
  hCall:SET-PARAMETER(41, "DOUBLE", "OUTPUT", B).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM55 returns logical
  (
  input R15 as decimal,
  input T as decimal,
  input Round_R as integer,
  input Round_T as integer,
  output R as decimal,
  output CTL as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt55"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 11
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", R15).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(8, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(9, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(10, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(11, "DOUBLE", "OUTPUT", CTL).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM56 returns logical
  (
  input M_type as integer,
  input M as decimal extent 16,
  input T as decimal,
  input P_type as integer,
  input P_extra as decimal,
  input P_atmosphere as decimal,
  input M_pseudo as decimal,
  input R_pseudo as decimal,
  input Round_T as integer,
  input Round_R as integer,
  output R as decimal,
  output P_vapor as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt56"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 17
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "LONG", "INPUT", M_type).
  hCall:SET-PARAMETER(5, "DOUBLE", "INPUT", M).
  hCall:SET-PARAMETER(6, "DOUBLE", "INPUT", T).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", P_type).
  hCall:SET-PARAMETER(8, "DOUBLE", "INPUT", P_extra).
  hCall:SET-PARAMETER(9, "DOUBLE", "INPUT", P_atmosphere).
  hCall:SET-PARAMETER(10, "DOUBLE", "INPUT", M_pseudo).
  hCall:SET-PARAMETER(11, "DOUBLE", "INPUT", R_pseudo).
  hCall:SET-PARAMETER(12, "LONG", "INPUT", Round_T).
  hCall:SET-PARAMETER(13, "LONG", "INPUT", Round_R).
  hCall:SET-PARAMETER(14, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(15, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(16, "DOUBLE", "OUTPUT", R).
  hCall:SET-PARAMETER(17, "DOUBLE", "OUTPUT", P_vapor).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function MM57 returns logical
  (
  input H as decimal,
  input ToolType as integer,
  output DeltaAbs_H as decimal,
  output Err as character,
  output Wrn as character,
  output DllVersion as character
  )
:
  define variable libName as character no-undo .
  define variable hCall   AS handle    no-undo .
  define variable mErr as memptr no-undo .
  define variable mWrn as memptr no-undo .
  define variable mDllVersion as memptr no-undo .
  SET-SIZE(mErr) = 1024 .
  SET-SIZE(mWrn) = 1024 .
  SET-SIZE(mDllVersion) = 20 .
  libName = search("exe/MM.dll") .
  create call hCall.
  assign
    hCall:CALL-NAME      = "MethodCt57"
    hCall:LIBRARY        = libName
    hCall:CALL-TYPE      = DLL-CALL-TYPE
    hCall:NUM-PARAMETERS = 8
  .
  hCall:SET-PARAMETER(1, "Memptr", "OUTPUT", mErr).
  hCall:SET-PARAMETER(2, "Memptr", "OUTPUT", mWrn).
  hCall:SET-PARAMETER(3, "Memptr", "OUTPUT", mDllVersion).
  hCall:SET-PARAMETER(4, "DOUBLE", "INPUT", H).
  hCall:SET-PARAMETER(5, "LONG", "INPUT", ToolType).
  hCall:SET-PARAMETER(6, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(7, "LONG", "INPUT", 1024).
  hCall:SET-PARAMETER(8, "DOUBLE", "OUTPUT", DeltaAbs_H).
  hCall:INVOKE( ).
  Err = get-string(mErr, 1, 1024) .
  Wrn = get-string(mWrn, 1, 1024) .
  DllVersion = get-string(mDllVersion, 1, 20) .
  delete object hCall.
end .
function getCalibrationBelt returns character
  (
  input iObjType as character,
  input iObjCode as integer,
  input iPlCode  as integer,
  input iLevelNP as decimal,
  input iLevelWater as decimal
  )
:
  define variable vCalibBelt      as  character         no-undo.
  define buffer   buf_pl-level-mm for ub.pl-level-mm.
  for each buf_pl-level-mm where
           buf_pl-level-mm.obj-type = iObjType
       and buf_pl-level-mm.obj-code = iObjCode
       and buf_pl-level-mm.pl-code  = iPlCode
       and ((buf_pl-level-mm.min-level <= iLevelNP and buf_pl-level-mm.max-level >= iLevelNP) or
            (buf_pl-level-mm.min-level <= iLevelWater and buf_pl-level-mm.max-level >= iLevelWater))
      no-lock
      break by buf_pl-level-mm.zone by buf_pl-level-mm.level:
    if first-of(buf_pl-level-mm.zone) then do:
      vCalibBelt = substitute("&1&2;&3=",vCalibBelt, buf_pl-level-mm.min-level,buf_pl-level-mm.max-level).
    end.
    vCalibBelt = substitute("&1&2&3",vCalibBelt, if buf_pl-level-mm.level = 1 then "" else ";", trim(string(buf_pl-level-mm.capacity / 1000, ">>>>>9.999"))).
    if last-of(buf_pl-level-mm.zone) and not last(buf_pl-level-mm.zone) then
      vCalibBelt = substitute("&1&2",vCalibBelt, chr(10)).
  end.
  return vCalibBelt.
end.
define  shared temp-table tt-susp-chk no-undo like ub.susp-chk .
define stream str-err.
define stream str-log.
define stream outstream.
define stream sinp .
define VARIABLE ii as integer no-undo .
    DEFINE VARIABLE rdc-value AS CHARACTER NO-UNDO INITIAL ?.
    DEFINE VARIABLE rdc-type  AS CHARACTER NO-UNDO INITIAL ?.
if valid-handle( g#lib-rvs ) and
   g#lib-rvs <> this-procedure :handle and
   g#lib-rvs :get-signature( 'lib-rvs_place-sh':U ) <> ''
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          'Попытка повторной загрузки библиотеки для работы со сверками' skip( 0 )
          g#lib-rvs                      skip( 0 )
          g#lib-rvs      :type           skip( 0 )
          g#lib-rvs      :file-name      skip( 0 )
          valid-handle( g#lib-rvs      ) skip( 0 )
          this-procedure :handle         skip( 0 )
          this-procedure :type           skip( 0 )
          this-procedure :file-name      skip( 0 )
          valid-handle( this-procedure ) skip( 1 )
  view-as alert-box error.
  undo, return error.
end.
else do:
  assign
    g#lib-rvs = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-rvs", g#lib-rvs).
  delete object gbl-hndllibObj.
end.
RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", NO, OUTPUT rdc-value, OUTPUT rdc-type) NO-ERROR.
if this-procedure :persistent <> yes then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          'Ошибка запуска библиотеки' program-name( 1 ) skip( 0 )
          'Попытка запустить ее как обычную процедуру.' skip( 1 )
  view-as alert-box error.
end.
on delete of this-procedure do:
  assign
    g#lib-rvs = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-rvs", g#lib-rvs).
  delete object gbl-hndllibObj.
end.
procedure lib-rvs_place-sh :
  define input parameter p-obj-type   like ub.place.obj-type     no-undo.
  define input parameter p-obj-code   like ub.place.obj-code     no-undo.
  define input parameter p-rvs-code   like ub.rvs-doc.rvs-code   no-undo.
  define input parameter p-rvs-type   like ub.rvs-doc.rvs-type   no-undo.
  define input parameter p-prev-code  like ub.rvs-doc.rvs-code   no-undo.
  define input parameter p-shift-date like ub.rvs-doc.shift-date no-undo.
  define input parameter p-shift-num  like ub.rvs-doc.shift-num  no-undo.
  define input parameter p-rvs-full   like ub.rvs-doc.is-full       no-undo.
  define buffer buf_place  for ub.place.
  define buffer buf_pl-gds for ub.pl-gds.
  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  tr:
  do transaction
  on error  undo tr, return error substitute( "&1 (place-sh). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo tr, return error substitute( "&1 (place-sh). stop", vss-workfile )
  on endkey undo tr, return error substitute( "&1 (place-sh). endkey", vss-workfile )
  :
    for each buf_place  no-lock
      where buf_place.obj-type = p-obj-type
        and buf_place.obj-code = p-obj-code
        and buf_place.status_  = ""
      ,each buf_pl-gds no-lock
      where buf_pl-gds.obj-type = buf_place.obj-type
        and buf_pl-gds.obj-code = buf_place.obj-code
        and buf_pl-gds.pl-code  = buf_place.pl-code
    on error undo, return error return-value
    :
      IF CAN-FIND( FIRST doc-attr
      WHERE doc-attr.doc-code  = p-rvs-code
        AND doc-attr.attr-code = "rvs-auto":U
        AND doc-attr.attr-value = "Yes":U and  p-rvs-full = yes and buf_place.is-meas = no
      NO-LOCK)
      THEN next.
      run gds-attr-value in this-procedure
        ( input  buf_pl-gds.gds-code
         ,input  'ptrl-without-rvs':U
         ,output v-attr-value
         ,output v-attr-type
        ) .
      if lookup(v-attr-value, 'true,yes':u) = 0 then do:
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslin in g#lib-rvs ( input p-obj-type ,
                      input p-obj-code ,
                      input p-rvs-code ,
                      input p-rvs-type ,
                      input buf_pl-gds.pl-code ,
                      input buf_pl-gds.gds-code ,
                      input p-prev-code ,
                      input p-shift-date ,
                      input p-shift-num ) no-error .
        if error-status :error then do:
          undo tr, return error substitute( 'Ошибка из процедуры lib-rvs_crrvslin.&1&2&1&3'
                                          , chr(10)
                                          , error-status :get-message( 1 )
                                          , return-value ) .
        end.
      end.
    end.
  end.
  return .
end procedure.
procedure lib-rvs_meas-plc :
  define input        parameter           p-obj-type like ub.place.obj-type no-undo.
  define input        parameter           p-obj-code like ub.place.obj-code no-undo.
  define input-output parameter table for tt-meas.
  define buffer bf_place     for ub.place.
  define buffer bf_place-err for ub.place.
  define buffer bf_goods     for ub.goods.
  for each tt-meas :
    delete tt-meas .
  end.
  for each bf_place no-lock where
           bf_place.obj-type = p-obj-type and
           bf_place.obj-code = p-obj-code and
           bf_place.is-meas  = yes and
           bf_place.status_ = ""
  :
    if trim( bf_place.loc1 ) = '':U or
             bf_place.loc1   = ?
    then do:
      return error substitute( 'В измеряемом резервуаре &1 задан неверный локальный номер "&2".'
                             , bf_place.pl-code
                             , bf_place.loc1 ) .
    end.
    find first bf_place-err no-lock
      where bf_place-err.obj-type =  bf_place.obj-type
        and bf_place-err.obj-code =  bf_place.obj-code
        and bf_place-err.is-meas  =  yes
        and bf_place-err.loc1     =  bf_place.loc1
        and recid( bf_place-err ) <> recid( bf_place )
        and bf_place-err.status_ = ""
      no-error.
    if available bf_place-err then do:
      return error substitute( 'В измеряемом резервуаре &1 задан локальный номер &2, установленный также в резервуаре &3.'
                             , bf_place.pl-code
                             , bf_place.loc1
                             , bf_place-err.pl-code ) .
    end.
    create tt-meas.
    assign
           tt-meas.obj-type = p-obj-type
           tt-meas.obj-code = p-obj-code
           tt-meas.pl-code  = bf_place.pl-code
           tt-meas.loc1 = bf_place.loc1
    .
  end.
  return .
end procedure.
procedure lib-rvs_fall-plc :
  define input parameter p-obj-type like ub.rvs-doc.obj-type no-undo.
  define input parameter p-obj-code like ub.rvs-doc.obj-code no-undo.
  define input parameter p-rvs-code like ub.rvs-doc.rvs-code no-undo.
  define input parameter p-is-full  as   logical             no-undo.
  define buffer bf_place  for ub.place.
  define buffer bf_r-line for ub.rvs-line.
  define buffer buf_doc-attr     for ub.doc-attr .
  define variable v-auto    as logical      no-undo.
  IF CAN-FIND( FIRST buf_doc-attr
      WHERE buf_doc-attr.doc-code  = p-rvs-code
        AND buf_doc-attr.attr-code = "rvs-auto":U
        AND buf_doc-attr.attr-value = "Yes":U
      NO-LOCK)
  THEN DO:
     assign
         v-auto = true
     .
  END.
  tr:
  do transaction on error undo, return error
                 on stop  undo, return error
                 on quit  undo, return error :
    for  each bf_r-line where
              bf_r-line.rvs-code = p-rvs-code and
              bf_r-line.obj-type = p-obj-type and
              bf_r-line.obj-code = p-obj-code
      , first bf_place    where
              bf_place.obj-type = bf_r-line.obj-type and
              bf_place.obj-code = bf_r-line.obj-code and
              bf_place.pl-code  = bf_r-line.pl-code and
              bf_place.status_  = ""
    :
      IF bf_place.is-meas  = yes THEN DO:
      if p-is-full <> yes then do:
        find first tt-meas where
                   tt-meas.obj-type = p-obj-type       and
                   tt-meas.obj-code = p-obj-code       and
                   tt-meas.pl-code  = bf_place.pl-code no-error .
        if not available tt-meas then do:
          next .
        end.
      end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1plc in g#lib-rvs ( input              bf_r-line.obj-type ,
                      input              bf_r-line.obj-code ,
                      input              bf_r-line.pl-code ,
                      input              recid( bf_r-line ) ,
                      input              bf_r-line.rvs-prev-code ,
                      input-output table tt-meas ) no-error .
      if error-status :error then do:
        undo tr, return error substitute( 'Ошибка при заполнении данных.&1&2&1&3'
                                        , chr(10)
                                        , error-status :get-message( 1 )
                                        , return-value ) .
      end.
      END.
      ELSE DO:
         IF v-auto THEN DO:
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill2plc in g#lib-rvs ( input              bf_r-line.obj-type ,
                      input              bf_r-line.obj-code ,
                      input              bf_r-line.pl-code ,
                      input              recid( bf_r-line ) ,
                      input              bf_r-line.rvs-prev-code ,
                      input-output table tt-meas ) no-error .
            if error-status :error then do:
            undo tr, return error substitute( 'Ошибка при заполнении данных из документов.&1&2&1&3'
                                             , chr(10)
                                             , error-status :get-message( 1 )
                                             , return-value ).
            end.
         END.
      END.
    end.
  end.
  return .
end procedure.
procedure lib-rvs_pump-sh :
  define input parameter p-obj-type         like ub.place.obj-type     no-undo.
  define input parameter p-obj-code         like ub.place.obj-code     no-undo.
  define input parameter p-rvs-code         like ub.rvs-doc.rvs-code   no-undo.
  define input parameter p-rvs-type         like ub.rvs-doc.rvs-type   no-undo.
  define input parameter p-prev-rvs-code    like ub.rvs-doc.rvs-code   no-undo.
  define input parameter p-prev-icnt-code   like ub.icnt-doc.doc-code  no-undo.
  define input parameter p-shift-date       like ub.rvs-doc.shift-date no-undo.
  define input parameter p-shift-num        like ub.rvs-doc.shift-num  no-undo.
  define input parameter p-qst_icnt-gds-all as   logical               no-undo.
  define input parameter p-message-on       as   logical               no-undo.
  define buffer buf_rvs-line for ub.rvs-line.
  tr:
  do transaction
  on error undo tr, return error return-value
  :
    for each buf_rvs-line
      where buf_rvs-line.rvs-code = p-rvs-code
        and buf_rvs-line.obj-type = p-obj-type
        and buf_rvs-line.obj-code = p-obj-code
    on error undo tr, return error return-value
    :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crrvslnp in g#lib-rvs ( input  p-obj-type ,
                      input  p-obj-code ,
                      input  p-rvs-code ,
                      input  p-rvs-type ,
                      input  buf_rvs-line.pl-code ,
                      input  buf_rvs-line.gds-code ,
                      input  p-qst_icnt-gds-all ,
                      input  p-prev-rvs-code ,
                      input  p-shift-date ,
                      input p-shift-num ,
                      input p-prev-icnt-code ,
                      input p-message-on ) no-error .
      if error-status :error then do:
        undo tr, return error substitute( 'Ошибка при создании строки данных по ТРК.&1&2&1&3'
                                        , chr(10)
                                        , error-status :get-message( 1 )
                                        , return-value ) .
      end.
    end.
  end.
  return .
end procedure.
procedure lib-rvs_measpmnz :
  define input        parameter           p-obj-type     like ub.pump-nozzle.obj-type no-undo.
  define input        parameter           p-obj-code     like ub.pump-nozzle.obj-code no-undo.
  define input-output parameter table for tt-pump-nozzle.
  define buffer bf_pump-nozzle    for ub.pump-nozzle.
  define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer bf_pl-gds         for ub.pl-gds.
  for each tt-pump-nozzle :
    delete tt-pump-nozzle .
  end.
  for each bf_pump-nozzle where
           bf_pump-nozzle.obj-type = p-obj-type and
           bf_pump-nozzle.obj-code = p-obj-code and
           bf_pump-nozzle.is-meas  = yes
  :
    find first bf_pl-pump-nozzle no-lock where
               bf_pl-pump-nozzle.obj-type    = bf_pump-nozzle.obj-type    and
               bf_pl-pump-nozzle.obj-code    = bf_pump-nozzle.obj-code    and
               bf_pl-pump-nozzle.pump-code   = bf_pump-nozzle.pump-code   and
               bf_pl-pump-nozzle.nozzle-code = bf_pump-nozzle.nozzle-code no-error .
    if available bf_pl-pump-nozzle then do:
      find first bf_pl-gds no-lock where
                 bf_pl-gds.obj-type = bf_pl-pump-nozzle.obj-type and
                 bf_pl-gds.obj-code = bf_pl-pump-nozzle.obj-code and
                 bf_pl-gds.pl-code  = bf_pl-pump-nozzle.pl-code  no-error .
      if available bf_pl-gds then do:
        create tt-pump-nozzle.
        assign
               tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
               tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
               tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
               tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
               tt-pump-nozzle.gds-code    = bf_pl-gds.gds-code
        .
      end.
    end.
  end.
  return .
end procedure.
procedure lib-rvs_rvs-pump :
  define input        parameter           p-parent-proc       as   widget-handle             no-undo.
  define input        parameter           p-obj-type          like ub.rvs-line-pump.obj-type no-undo.
  define input        parameter           p-obj-code          like ub.rvs-line-pump.obj-code no-undo.
  define input        parameter           p-rvs-code          like ub.rvs-line-pump.rvs-code no-undo.
  define input        parameter           p-cur-pump          as   logical                   no-undo.
  define input-output parameter table for tt-pump-nozzle-file.
  define input-output parameter table for tt-pump-nozzle.
  define buffer bf_pump-nozzle   for ub.pump-nozzle.
  define buffer bf_rvs-line-pump for ub.rvs-line-pump.
  define variable v-msg as character no-undo initial "":U .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              p-parent-proc ,
                      input              p-obj-type ,
                      input              p-obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              p-cur-pump ,
                      input              no ,
                      input              no) no-error .
  if error-status :error then do:
    return error return-value .
  end.
  assign
    v-msg = return-value
  .
  tr:
  do transaction
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop  undo, return error substitute( "&1. stop", vss-workfile )
  on quit  undo, return error substitute( "&1. quit", vss-workfile )
  :
    for each bf_rvs-line-pump
      where bf_rvs-line-pump.rvs-code = p-rvs-code
        and bf_rvs-line-pump.obj-type = p-obj-type
        and bf_rvs-line-pump.obj-code = p-obj-code
      ,first bf_pump-nozzle
      where bf_pump-nozzle.obj-type    = bf_rvs-line-pump.obj-type
        and bf_pump-nozzle.obj-code    = bf_rvs-line-pump.obj-code
        and bf_pump-nozzle.pump-code   = bf_rvs-line-pump.pump-code
        and bf_pump-nozzle.nozzle-code = bf_rvs-line-pump.nozzle-code
        and bf_pump-nozzle.is-meas     = yes
    on error undo tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_fill1pmp in g#lib-rvs ( input       recid( bf_rvs-line-pump ) ,
                      input table tt-pump-nozzle ) no-error .
      if error-status :error then do:
        undo tr, return error 'Ошибка при сохранении данных в строку счетчиков ТРК ' + return-value + ' .' .
      end.
    end.
  end.
  return v-msg .
end procedure.
procedure lib-rvs_crttpmnz :
  define input        parameter           p-obj-type     like ub.pump-nozzle.obj-type    no-undo.
  define input        parameter           p-obj-code     like ub.pump-nozzle.obj-code    no-undo.
  define input        parameter           p-pump-code    like ub.pump-nozzle.pump-code   no-undo.
  define input        parameter           p-nozzle-code  like ub.pump-nozzle.nozzle-code no-undo.
  define input-output parameter table for tt-pump-nozzle.
  define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer bf_pl-gds         for ub.pl-gds.
  find first bf_pl-pump-nozzle no-lock where
             bf_pl-pump-nozzle.obj-type    = p-obj-type    and
             bf_pl-pump-nozzle.obj-code    = p-obj-code    and
             bf_pl-pump-nozzle.pump-code   = p-pump-code   and
             bf_pl-pump-nozzle.nozzle-code = p-nozzle-code no-error .
  if available bf_pl-pump-nozzle then do:
    find first bf_pl-gds no-lock where
               bf_pl-gds.obj-type = bf_pl-pump-nozzle.obj-type and
               bf_pl-gds.obj-code = bf_pl-pump-nozzle.obj-code and
               bf_pl-gds.pl-code  = bf_pl-pump-nozzle.pl-code  no-error .
    if available bf_pl-gds then do:
      create tt-pump-nozzle.
      assign
             tt-pump-nozzle.obj-type    = bf_pl-pump-nozzle.obj-type
             tt-pump-nozzle.obj-code    = bf_pl-pump-nozzle.obj-code
             tt-pump-nozzle.pump-code   = bf_pl-pump-nozzle.pump-code
             tt-pump-nozzle.nozzle-code = bf_pl-pump-nozzle.nozzle-code
             tt-pump-nozzle.gds-code    = bf_pl-gds.gds-code
      .
    end.
  end.
  return .
end procedure.
procedure lib-rvs_fill1pmp :
  define input parameter           p-rec_rvs-line-pump as recid no-undo.
  define input parameter table for tt-pump-nozzle.
  define buffer start_icnt-line     for ub.icnt-line.
  define buffer start_rvs-line-pump for ub.rvs-line-pump.
  define buffer fill_rvs-line       for ub.rvs-line.
  define buffer fill_rvs-line-pump  for ub.rvs-line-pump.
  define buffer bf_goods            for ub.goods.
  find first fill_rvs-line-pump where
      recid( fill_rvs-line-pump ) = p-rec_rvs-line-pump no-error .
  if not available fill_rvs-line-pump then do:
    return error substitute( 'Неверные параметры переданы процедуре lib-rvs_fill1pmp. '
                           + 'Не найдена запись rvs-line-pump c recid: &1 .'
                           , p-rec_rvs-line-pump ) .
  end.
  find first tt-pump-nozzle where
             tt-pump-nozzle.obj-type    = fill_rvs-line-pump.obj-type    and
             tt-pump-nozzle.obj-code    = fill_rvs-line-pump.obj-code    and
             tt-pump-nozzle.pump-code   = fill_rvs-line-pump.pump-code   and
             tt-pump-nozzle.nozzle-code = fill_rvs-line-pump.nozzle-code no-error .
  find first fill_rvs-line no-lock where
             fill_rvs-line.rvs-code = fill_rvs-line-pump.rvs-code and
             fill_rvs-line.obj-type = fill_rvs-line-pump.obj-type and
             fill_rvs-line.obj-code = fill_rvs-line-pump.obj-code and
             fill_rvs-line.pl-code  = fill_rvs-line-pump.pl-code  .
  find first bf_goods no-lock where
             bf_goods.gds-code = fill_rvs-line.gds-code .
  if not available tt-pump-nozzle then do:
    return error substitute( 'Ошибка. Со счетчиков не получены данные по ТРК &1 пистолету &2 '
                           + 'через который продается топливо &3 &4 &5 &6.'
                           , fill_rvs-line-pump.pump-code
                           , fill_rvs-line-pump.nozzle-code
                           , bf_goods.artic
                           , bf_goods.prod-type
                           , bf_goods.prod-code
                           , bf_goods.gds-name ) .
  end.
  assign
    fill_rvs-line-pump.meas-el-cnt  = tt-pump-nozzle.meas-el-cnt
    fill_rvs-line-pump.meas-am-cnt  = tt-pump-nozzle.meas-am-cnt
    fill_rvs-line-pump.meas-cf-cnt  = tt-pump-nozzle.meas-cf-cnt
    fill_rvs-line-pump.state-el-cnt = fill_rvs-line-pump.meas-el-cnt
    fill_rvs-line-pump.state-am-cnt = fill_rvs-line-pump.meas-am-cnt
    fill_rvs-line-pump.state-cf-cnt = fill_rvs-line-pump.meas-cf-cnt
  .
  if fill_rvs-line-pump.icnt-code <> ? then do:
    find first start_icnt-line no-lock where
               start_icnt-line.doc-code    = fill_rvs-line-pump.icnt-code   and
               start_icnt-line.obj-type    = fill_rvs-line-pump.obj-type    and
               start_icnt-line.obj-code    = fill_rvs-line-pump.obj-code    and
               start_icnt-line.pump-code   = fill_rvs-line-pump.pump-code   and
               start_icnt-line.nozzle-code = fill_rvs-line-pump.nozzle-code .
    assign
      fill_rvs-line-pump.meas-mh-cnt  = fill_rvs-line-pump.meas-el-cnt - start_icnt-line.state-el-cnt
                                                                       + start_icnt-line.state-mh-cnt
      fill_rvs-line-pump.state-mh-cnt = fill_rvs-line-pump.meas-mh-cnt
    .
  end.
  if fill_rvs-line-pump.rvs-prev-code <> ? then do:
    find first start_rvs-line-pump no-lock where
               start_rvs-line-pump.rvs-code    = fill_rvs-line-pump.rvs-prev-code and
               start_rvs-line-pump.obj-type    = fill_rvs-line-pump.obj-type      and
               start_rvs-line-pump.obj-code    = fill_rvs-line-pump.obj-code      and
               start_rvs-line-pump.pl-code     = fill_rvs-line-pump.pl-code       and
               start_rvs-line-pump.gds-code    = fill_rvs-line-pump.gds-code      and
               start_rvs-line-pump.pump-code   = fill_rvs-line-pump.pump-code     and
               start_rvs-line-pump.nozzle-code = fill_rvs-line-pump.nozzle-code   .
    assign
      fill_rvs-line-pump.meas-mh-qnty  = fill_rvs-line-pump.meas-mh-cnt  - start_rvs-line-pump.meas-mh-cnt
      fill_rvs-line-pump.meas-am-qnty  = fill_rvs-line-pump.meas-am-cnt  - start_rvs-line-pump.meas-am-cnt
      fill_rvs-line-pump.meas-cf-qnty  = fill_rvs-line-pump.meas-cf-cnt  - start_rvs-line-pump.meas-cf-cnt
      fill_rvs-line-pump.state-mh-qnty = fill_rvs-line-pump.state-mh-cnt - start_rvs-line-pump.state-mh-cnt
      fill_rvs-line-pump.state-am-qnty = fill_rvs-line-pump.state-am-cnt - start_rvs-line-pump.state-am-cnt
      fill_rvs-line-pump.state-cf-qnty = fill_rvs-line-pump.state-cf-cnt - start_rvs-line-pump.state-cf-cnt
    .
  end.
  return .
end procedure.
procedure lib-rvs_crrvslin :
  define input parameter p-obj-type                 like ub.rvs-doc.obj-type     no-undo.
  define input parameter p-obj-code                 like ub.rvs-doc.obj-code     no-undo.
  define input parameter p-rvs-code                 like ub.rvs-doc.rvs-code     no-undo.
  define input parameter p-rvs-type                 like ub.rvs-doc.rvs-type     no-undo.
  define input parameter p-pl-code                  like ub.pl-gds.pl-code       no-undo.
  define input parameter p-gds-code                 like ub.pl-gds.gds-code      no-undo.
  define input parameter p-prev_rvs-code            like ub.rvs-doc.rvs-code     no-undo.
  define input parameter p-cur_shift-obj_shift-date like ub.shift-obj.shift-date no-undo.
  define input parameter p-cur_shift-obj_shift-num  like ub.shift-obj.shift-num  no-undo.
  define buffer bf_prev_rvs-line for ub.rvs-line.
  define buffer prev_rvs-line    for ub.rvs-line.
  define buffer buf_goods        for ub.goods .
  define buffer buf_rvs-line     for ub.rvs-line.
  define buffer buf_rvs-doc      for ub.rvs-doc.
  define buffer contr_rvs-doc    for ub.rvs-doc.
  define buffer crl_prev_rvs-doc for ub.rvs-doc.
  define buffer buf_place        for ub.place.
  define variable c-value as character no-undo.
  define variable c-type as character no-undo.
  define variable is-vir as logical no-undo.
  define variable v-value as character no-undo.
  define variable v-ok as logical no-undo.
  do on error undo, return error return-value :
    if p-prev_rvs-code <> ? then do:
      find first crl_prev_rvs-doc no-lock
        where crl_prev_rvs-doc.rvs-code = p-prev_rvs-code
      .
    end.
    define variable varis-petrol   as logical no-undo.
    define variable varis-pieces   as logical no-undo.
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
    .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
    if error-status :error then do:
      return error 'Ошибка при вызове программы is-petrl.i ' + return-value .
    end.
    if varis-petrol <> yes
      or varis-pieces =  yes
    then do:
      return 'Товар не является жидким топливом' .
    end.
    if p-rvs-type = 'проверка':U
    then do :
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        (input  p-gds-code
        ,input  'fuel-type':U
        ,output c-value
        ,output c-type)
      no-error.
      if c-value = 'lgas':U
      or c-value = 'metan':U
      or c-value = 'propan':U
      then do :
        return substitute('GAS! Проверка корректности работы АСИ в резервуаре НП возможна только по резервуарам с НП. Выбранный резервуар с типом топлива &1 не может быть добавлен в документ!', c-value).
      end .
      find first buf_place no-lock  where buf_place.obj-type = p-obj-type
                                      and buf_place.obj-code = p-obj-code
                                      and buf_place.pl-code  = p-pl-code
                                      no-error .
      if not available buf_place
      then do :
        return error return-value .
      end .
      if not buf_place.is-meas
      then do :
        return substitute('NMS! Проверка корректности работы АСИ в резервуаре НП возможна только по измеряемым резервуарам. Выбранный резервуар &1 неизмеряемый и не может быть добавлен в документ!', p-pl-code).
      end .
      run placelib_get-attr(input "place-virtual"
                       ,input buf_place.obj-code
                       ,input buf_place.obj-type
                       ,input buf_place.pl-code
                       ,output v-value
                       ,output v-ok) no-error.
      is-vir = if (v-ok and logical(v-value)) then true else false.
      if is-vir
      then do :
        return substitute('VIR! Проверка корректности работы АСИ в резервуаре НП не возможна по виртуальным резервуарам. Выбранный резервуар &1 виртуальный и не может быть добавлен в документ!', p-pl-code).
      end .
      find first buf_rvs-line no-lock
        where buf_rvs-line.rvs-code = p-rvs-code
          and buf_rvs-line.obj-type = p-obj-type
          and buf_rvs-line.obj-code = p-obj-code
          and buf_rvs-line.pl-code  = p-pl-code
          and buf_rvs-line.gds-code = p-gds-code
      no-error .
      if not available buf_rvs-line
      then do :
        create buf_rvs-line.
        assign
          buf_rvs-line.rvs-code      = p-rvs-code
          buf_rvs-line.obj-type      = p-obj-type
          buf_rvs-line.obj-code      = p-obj-code
          buf_rvs-line.pl-code       = p-pl-code
          buf_rvs-line.gds-code      = p-gds-code
          buf_rvs-line.rvs-prev-code = ?
          buf_rvs-line.measure-qnty = ?
          buf_rvs-line.brutto-qnty = ?
          buf_rvs-line.measure-cli-qnty = ?
          buf_rvs-line.brutto-cli-qnty = ?
          buf_rvs-line.density = ?
          buf_rvs-line.temperature = ?
          buf_rvs-line.level-total = ?
          buf_rvs-line.level-petrol = ?
          buf_rvs-line.level-water = ?
          buf_rvs-line.temp-layer1 = ?
          buf_rvs-line.temp-layer2 = ?
          buf_rvs-line.temp-layer3 = ?
          buf_rvs-line.measure-tc-qnty = ?
          buf_rvs-line.brutto-tc-qnty = ?
          buf_rvs-line.state-measure-qnty = ?
          buf_rvs-line.state-brutto-qnty = ?
          buf_rvs-line.state-measure-cli-qnty = ?
          buf_rvs-line.state-brutto-cli-qnty = ?
          buf_rvs-line.state-density = ?
          buf_rvs-line.state-temperature = ?
          buf_rvs-line.state-level-total = ?
          buf_rvs-line.state-level-petrol = ?
          buf_rvs-line.state-level-water = ?
          buf_rvs-line.state-temp-layer1 = ?
          buf_rvs-line.state-temp-layer2 = ?
          buf_rvs-line.state-temp-layer3 = ?
          buf_rvs-line.state-measure-tc-qnty = ?
          buf_rvs-line.state-brutto-tc-qnty = ?
          buf_rvs-line.add-qnty       = ?
          buf_rvs-line.state-add-qnty = ?
        .
      end .
      return .
    end .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input p-obj-type
  , input p-obj-code
  ) .
    find first buf_rvs-line no-lock
      where buf_rvs-line.rvs-code = p-rvs-code
        and buf_rvs-line.obj-type = p-obj-type
        and buf_rvs-line.obj-code = p-obj-code
        and buf_rvs-line.pl-code  = p-pl-code
        and buf_rvs-line.gds-code = p-gds-code
      no-error .
    if not available buf_rvs-line then do:
      if available prev_rvs-line then do:
        release prev_rvs-line .
      end.
      if available crl_prev_rvs-doc then do:
        find first prev_rvs-line no-lock
          where prev_rvs-line.rvs-code = crl_prev_rvs-doc.rvs-code
            and prev_rvs-line.obj-type = p-obj-type
            and prev_rvs-line.obj-code = p-obj-code
            and prev_rvs-line.pl-code  = p-pl-code
            and prev_rvs-line.gds-code = p-gds-code
          no-error .
      end.
      if not available prev_rvs-line then do:
        prev:
        for each contr_rvs-doc no-lock
          where contr_rvs-doc.obj-type   = p-obj-type
            and contr_rvs-doc.obj-code   = p-obj-code
            and contr_rvs-doc.shift-date = p-cur_shift-obj_shift-date
            and contr_rvs-doc.shift-num  = p-cur_shift-obj_shift-num
            and contr_rvs-doc.status_    = 'факт':U
            and contr_rvs-doc.rvs-type  <> 'проверка':U
          by contr_rvs-doc.fact-order
        on error undo, return error return-value
        :
          find first prev_rvs-line no-lock
            where prev_rvs-line.rvs-code = contr_rvs-doc.rvs-code
              and prev_rvs-line.obj-type = p-obj-type
              and prev_rvs-line.obj-code = p-obj-code
              and prev_rvs-line.pl-code  = p-pl-code
              and prev_rvs-line.gds-code = p-gds-code
            no-error .
          if available prev_rvs-line then do:
            leave prev .
          end.
        end.
        if not available prev_rvs-line
          and p-rvs-type = 'смена':U
        then do:
          return error substitute( 'На объекте &1 &2 для резервуара &3 в котором находится топливо &4'
                                   + 'нет сверки по смене за прошлую смену и нет ни одной контрольной сверки за текущую смену.'
                                   ,p-obj-type
                                   ,p-obj-code
                                   ,p-pl-code
                                   ,p-gds-code
                                  ) .
        end.
      end.
      create buf_rvs-line.
      assign
        buf_rvs-line.rvs-code      = p-rvs-code
        buf_rvs-line.obj-type      = p-obj-type
        buf_rvs-line.obj-code      = p-obj-code
        buf_rvs-line.pl-code       = p-pl-code
        buf_rvs-line.gds-code      = p-gds-code
        buf_rvs-line.rvs-prev-code = ( if available prev_rvs-line then prev_rvs-line.rvs-code else ? )
        buf_rvs-line.measure-qnty = ?
        buf_rvs-line.brutto-qnty = ?
        buf_rvs-line.measure-cli-qnty = ?
        buf_rvs-line.brutto-cli-qnty = ?
        buf_rvs-line.density = ?
        buf_rvs-line.temperature = ?
        buf_rvs-line.level-total = ?
        buf_rvs-line.level-petrol = ?
        buf_rvs-line.level-water = ?
        buf_rvs-line.temp-layer1 = ?
        buf_rvs-line.temp-layer2 = ?
        buf_rvs-line.temp-layer3 = ?
        buf_rvs-line.measure-tc-qnty = ?
        buf_rvs-line.brutto-tc-qnty = ?
        buf_rvs-line.state-measure-qnty = ?
        buf_rvs-line.state-brutto-qnty = ?
        buf_rvs-line.state-measure-cli-qnty = ?
        buf_rvs-line.state-brutto-cli-qnty = ?
        buf_rvs-line.state-density = ?
        buf_rvs-line.state-temperature = ?
        buf_rvs-line.state-level-total = ?
        buf_rvs-line.state-level-petrol = ?
        buf_rvs-line.state-level-water = ?
        buf_rvs-line.state-temp-layer1 = ?
        buf_rvs-line.state-temp-layer2 = ?
        buf_rvs-line.state-temp-layer3 = ?
        buf_rvs-line.state-measure-tc-qnty = ?
        buf_rvs-line.state-brutto-tc-qnty = ?
      .
      find first buf_place no-lock  where buf_place.obj-type = p-obj-type
                                    and buf_place.obj-code = p-obj-code
                                    and buf_place.pl-code  = p-pl-code
                                    no-error .
      if available buf_place
      then do :
        assign
          buf_rvs-line.add-qnty       = buf_place.add-qnty
          buf_rvs-line.state-add-qnty = buf_place.add-qnty
        .
      end.
      if buf_goods.unit-base = buf_goods.unit-cli then do:
        assign
          buf_rvs-line.state-density = 1.0
        .
      end.
      assign
        buf_rvs-line.system-qnty          = 0.00
        buf_rvs-line.system-cli-qnty      = 0.00
        buf_rvs-line.orig-system-cli-qnty = buf_rvs-line.system-cli-qnty
        buf_rvs-line.orig-system-qnty     = buf_rvs-line.system-qnty
      .
      end.
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
             and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
             and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
             and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
             and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
             and rvs-line-attr.attr-code = "input-type-p" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = buf_rvs-line.obj-code
          rvs-line-attr.obj-type  = buf_rvs-line.obj-type
          rvs-line-attr.gds-code  = buf_rvs-line.gds-code
          rvs-line-attr.pl-code   = buf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "input-type-p"
          rvs-line-attr.attr-value = ''
        .
      end.
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
             and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
             and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
             and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
             and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
             and rvs-line-attr.attr-code = "input-type-t" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = buf_rvs-line.obj-code
          rvs-line-attr.obj-type  = buf_rvs-line.obj-type
          rvs-line-attr.gds-code  = buf_rvs-line.gds-code
          rvs-line-attr.pl-code   = buf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "input-type-t"
          rvs-line-attr.attr-value = ''
        .
      end.
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
             and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
             and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
             and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
             and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
             and rvs-line-attr.attr-code = "input-type-l" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = buf_rvs-line.obj-code
          rvs-line-attr.obj-type  = buf_rvs-line.obj-type
          rvs-line-attr.gds-code  = buf_rvs-line.gds-code
          rvs-line-attr.pl-code   = buf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "input-type-l"
          rvs-line-attr.attr-value = ''
        .
      end.
      release rvs-line-attr .
  end.
  return .
end procedure.
procedure lib-rvs_crrvslnp :
  define input parameter p-obj-type                 like ub.rvs-doc.obj-type     no-undo.
  define input parameter p-obj-code                 like ub.rvs-doc.obj-code     no-undo.
  define input parameter p-rvs-code                 like ub.rvs-line.rvs-code    no-undo.
  define input parameter p-rvs-type                 like ub.rvs-doc.rvs-type     no-undo.
  define input parameter p-pl-code                  like ub.rvs-line.pl-code     no-undo.
  define input parameter p-gds-code                 like ub.rvs-line.gds-code    no-undo.
  define input parameter p-quest_icnt-goods         as   logical                 no-undo.
  define input parameter p-prev_rvs-code            like ub.rvs-doc.rvs-code     no-undo.
  define input parameter p-cur_shift-obj_shift-date like ub.shift-obj.shift-date no-undo.
  define input parameter p-cur_shift-obj_shift-num  like ub.shift-obj.shift-num  no-undo.
  define input parameter p-prev_icnt-code           like ub.icnt-doc.doc-code    no-undo.
  define input parameter p-message-on               as   logical                 no-undo.
  define variable is-vir as logical no-undo.
  define variable v-value as character no-undo.
  define variable v-ok as logical no-undo.
  do
  on error  undo, return error substitute( "&1(lib-rvs_crrvslnp). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1(lib-rvs_crrvslnp). stop", vss-workfile )
  on endkey undo, return error substitute( "&1(lib-rvs_crrvslnp). endkey", vss-workfile )
  :
    define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer contr_rvs-doc      for ub.rvs-doc.
    define buffer buf_rvs-line       for ub.rvs-line.
    define buffer buf_rvs-line-pump  for ub.rvs-line-pump.
    define buffer prev-contr_rvs-doc for ub.rvs-doc.
    define buffer prev_rvs-line-pump for ub.rvs-line-pump.
    define buffer other-line-pump    for ub.rvs-line-pump.
    define buffer prev_icnt-line     for ub.icnt-line.
    define buffer bf_pump-nozzle     for ub.pump-nozzle.
    define buffer bf_goods           for ub.goods.
    define buffer icnt-goods         for ub.goods.
    define buffer crl_prev_rvs-doc   for ub.rvs-doc.
    define buffer crl_prev_icnt-doc  for ub.icnt-doc.
    define variable varnoeqgds as logical no-undo.
    define variable g-log      as logical no-undo.
    if p-prev_rvs-code <> ? then do:
      find first crl_prev_rvs-doc no-lock
        where crl_prev_rvs-doc.rvs-code = p-prev_rvs-code
      .
    end.
    if p-prev_icnt-code <> ? then do:
      find first crl_prev_icnt-doc no-lock
        where crl_prev_icnt-doc.doc-code = p-prev_icnt-code
      .
    end.
    tr:
    do transaction
    on error  undo tr, return error substitute( "&1 (crrvslnp). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo tr, return error substitute( "&1 (crrvslnp). stop", vss-workfile )
    on endkey undo tr, return error substitute( "&1 (crrvslnp). endkey", vss-workfile )
    :
      for each buf_pl-pump-nozzle
        where buf_pl-pump-nozzle.obj-type = p-obj-type
          and buf_pl-pump-nozzle.obj-code = p-obj-code
          and buf_pl-pump-nozzle.pl-code  = p-pl-code
      on error undo, return error return-value
      :
        find first buf_rvs-line no-lock
          where buf_rvs-line.rvs-code = p-rvs-code
            and buf_rvs-line.obj-type = buf_pl-pump-nozzle.obj-type
            and buf_rvs-line.obj-code = buf_pl-pump-nozzle.obj-code
            and buf_rvs-line.pl-code  = buf_pl-pump-nozzle.pl-code
            and buf_rvs-line.gds-code = p-gds-code
          no-error .
        if not available buf_rvs-line then do:
          next.
        end.
        find first buf_rvs-line-pump
          where buf_rvs-line-pump.rvs-code    = p-rvs-code
            and buf_rvs-line-pump.obj-type    = p-obj-type
            and buf_rvs-line-pump.obj-code    = p-obj-code
            and buf_rvs-line-pump.pl-code     = p-pl-code
            and buf_rvs-line-pump.gds-code    = p-gds-code
            and buf_rvs-line-pump.pump-code   = buf_pl-pump-nozzle.pump-code
            and buf_rvs-line-pump.nozzle-code = buf_pl-pump-nozzle.nozzle-code
          no-error .
        if not available buf_rvs-line-pump then do:
          if available prev_rvs-line-pump then do:
            release prev_rvs-line-pump .
          end.
          if available crl_prev_rvs-doc then do:
            find first prev_rvs-line-pump no-lock
              where prev_rvs-line-pump.rvs-code    = crl_prev_rvs-doc.rvs-code
                and prev_rvs-line-pump.obj-type    = p-obj-type
                and prev_rvs-line-pump.obj-code    = p-obj-code
                and prev_rvs-line-pump.pl-code     = p-pl-code
                and prev_rvs-line-pump.gds-code    = p-gds-code
                and prev_rvs-line-pump.pump-code   = buf_pl-pump-nozzle.pump-code
                and prev_rvs-line-pump.nozzle-code = buf_pl-pump-nozzle.nozzle-code
              no-error .
          end.
          if not available prev_rvs-line-pump then do:
            prev:
            for each contr_rvs-doc no-lock where
                     contr_rvs-doc.obj-type   = p-obj-type                 and
                     contr_rvs-doc.obj-code   = p-obj-code                 and
                     contr_rvs-doc.shift-date = p-cur_shift-obj_shift-date and
                     contr_rvs-doc.shift-num  = p-cur_shift-obj_shift-num  and
                     contr_rvs-doc.status_    = 'факт':U                    and
                     contr_rvs-doc.rvs-type  <> 'проверка':U
            :
              find first prev_rvs-line-pump no-lock
                where prev_rvs-line-pump.rvs-code    = contr_rvs-doc.rvs-code
                  and prev_rvs-line-pump.obj-type    = p-obj-type
                  and prev_rvs-line-pump.obj-code    = p-obj-code
                  and prev_rvs-line-pump.pl-code     = p-pl-code
                  and prev_rvs-line-pump.gds-code    = p-gds-code
                  and prev_rvs-line-pump.pump-code   = buf_pl-pump-nozzle.pump-code
                  and prev_rvs-line-pump.nozzle-code = buf_pl-pump-nozzle.nozzle-code
                no-error .
              if available prev_rvs-line-pump then do:
                leave prev .
              end.
            end.
            if not available prev_rvs-line-pump and
               p-rvs-type = 'смена':U
            then do:
              find first bf_goods no-lock where
                         bf_goods.gds-code = p-gds-code .
              undo tr, return error
              substitute( 'На объекте &1 &2 для резервуара &3 в котором находится топливо &4 &5 &6 &7 ТРК &8 '
                        + 'пистолет &9 нет сверки по смене за прошлую смену и нет ни одной контрольной сверки '
                        + 'за текущую смену.'
                        , p-obj-type
                        , p-obj-code
                        , p-pl-code
                        , bf_goods.artic
                        , bf_goods.prod-type
                        , bf_goods.prod-code
                        , bf_goods.gds-name
                        , buf_pl-pump-nozzle.pump-code
                        , buf_pl-pump-nozzle.nozzle-code ) .
            end.
          end.
          find first bf_pump-nozzle no-lock where
                     bf_pump-nozzle.obj-type    = buf_pl-pump-nozzle.obj-type    and
                     bf_pump-nozzle.obj-code    = buf_pl-pump-nozzle.obj-code    and
                     bf_pump-nozzle.pump-code   = buf_pl-pump-nozzle.pump-code   and
                     bf_pump-nozzle.nozzle-code = buf_pl-pump-nozzle.nozzle-code .
          if bf_pump-nozzle.is-meas = yes then do:
            find first bf_goods no-lock where
                       bf_goods.gds-code = p-gds-code .
            if available crl_prev_icnt-doc then do:
              find first prev_icnt-line no-lock where
                         prev_icnt-line.doc-code    = crl_prev_icnt-doc.doc-code and
                         prev_icnt-line.obj-type    = bf_pump-nozzle.obj-type    and
                         prev_icnt-line.obj-code    = bf_pump-nozzle.obj-code    and
                         prev_icnt-line.pump-code   = bf_pump-nozzle.pump-code   and
                         prev_icnt-line.nozzle-code = bf_pump-nozzle.nozzle-code no-error .
              if not available prev_icnt-line then do:
                 undo tr, return error substitute( 'Нет инвентаризации счетчика ТРК на ТРК &1 пистолет &2 через который '
                                                 + 'сейчас наливается бензин &3 &4 &5 &6'
                                                 , bf_pump-nozzle.pump-code
                                                 , bf_pump-nozzle.nozzle-code
                                                 , bf_goods.artic
                                                 , bf_goods.prod-type
                                                 , bf_goods.prod-code
                                                 , bf_goods.gds-name ) .
              end.
              if prev_icnt-line.gds-code <> bf_goods.gds-code then do:
                assign
                  varnoeqgds = yes
                .
                if available prev_rvs-line-pump then do:
                   find first prev-contr_rvs-doc no-lock where
                              prev-contr_rvs-doc.rvs-code = prev_rvs-line-pump.rvs-code .
                   if prev-contr_rvs-doc.fact-order > crl_prev_icnt-doc.fact-order then do:
                     assign
                       varnoeqgds = no
                     .
                   end.
                end.
                if varnoeqgds = yes then do:
                  if prev_icnt-line.gds-code <> ? then do:
                    find first icnt-goods no-lock where
                               icnt-goods.gds-code = prev_icnt-line.gds-code .
                  end.
                  else do:
                    if p-quest_icnt-goods = no then do:
                      assign
                        varnoeqgds = no
                      .
                    end.
                  end.
                  if varnoeqgds = yes then do:
                    if p-quest_icnt-goods = no then do:
                      undo tr, return error
                      substitute( 'Несоответствие по товару, продающемуся через пистолет ТРК. В данный момент '
                                + 'реализуется товар &1 &2 &3 &4 . Во время инвентаризации через пистолет &5 ТРК &6 '
                                + 'реализовывался товар &7 &8 &9 .'
                                , bf_goods.artic
                                , bf_goods.prod-type
                                , bf_goods.prod-code
                                , bf_goods.gds-name
                                , buf_pl-pump-nozzle.nozzle-code
                                , buf_pl-pump-nozzle.pump-code
                                , icnt-goods.artic
                                , icnt-goods.prod-type
                                , icnt-goods.prod-code ) .
                    end.
                    else do:
                      if p-message-on = yes then do:
                        assign
                          g-log = no
                        .
                        message 'Несоответствие по товару, продающемуся через пистолет ТРК.' skip
                                'В данный момент реализуется товар '
                                bf_goods.artic ' ' bf_goods.prod-type ' ' bf_goods.prod-code ' .' skip
                                'Во время инвентаризации через пистолет ' buf_pl-pump-nozzle.nozzle-code ' ТРК ' buf_pl-pump-nozzle.pump-code
                                ( if prev_icnt-line.gds-code <> ? then 'реализовывался товар ' +
                                                                       icnt-goods.artic               + ' ' +
                                                                       icnt-goods.prod-type           + ' ' +
                                                                       string( icnt-goods.prod-code ) + ' ' +
                                                                       icnt-goods.gds-name            + ' .'
                                                                 else 'товар не продавался.' )
                                'Будем делать сверку?'
                        view-as alert-box question buttons yes-no update g-log.
                        if g-log <> yes then do:
                          undo tr, return error return-value .
                        end.
                      end.
                    end.
                  end.
                end.
              end.
            end.
            else do:
              undo tr, return error substitute( 'ТРК &1 &2 &3 &4 измеряется прибором. '
                                              + 'Должен быть документ инвентаризации счетчиков ТРК.'
                                              , bf_pump-nozzle.obj-type
                                              , bf_pump-nozzle.obj-code
                                              , bf_pump-nozzle.pump-code
                                              , bf_pump-nozzle.nozzle-code ) .
            end.
          end.
          create buf_rvs-line-pump.
          assign
            buf_rvs-line-pump.rvs-code      = p-rvs-code
            buf_rvs-line-pump.obj-type      = p-obj-type
            buf_rvs-line-pump.obj-code      = p-obj-code
            buf_rvs-line-pump.pl-code       = p-pl-code
            buf_rvs-line-pump.gds-code      = p-gds-code
            buf_rvs-line-pump.pump-code     = buf_pl-pump-nozzle.pump-code
            buf_rvs-line-pump.nozzle-code   = buf_pl-pump-nozzle.nozzle-code
            buf_rvs-line-pump.rvs-prev-code = ( if available prev_rvs-line-pump then prev_rvs-line-pump.rvs-code else ? )
            buf_rvs-line-pump.icnt-code     = ( if available prev_icnt-line     then prev_icnt-line.doc-code     else ? )
            buf_rvs-line-pump.meas-el-cnt   = ?
            buf_rvs-line-pump.meas-am-cnt   = ?
            buf_rvs-line-pump.meas-cf-cnt   = ?
            buf_rvs-line-pump.meas-mh-cnt   = ?
            buf_rvs-line-pump.meas-am-qnty  = ?
            buf_rvs-line-pump.meas-cf-qnty  = ?
            buf_rvs-line-pump.meas-mh-qnty  = ?
            buf_rvs-line-pump.state-el-cnt  = ?
            buf_rvs-line-pump.state-am-cnt  = ?
            buf_rvs-line-pump.state-cf-cnt  = ?
            buf_rvs-line-pump.state-mh-cnt  = ?
            buf_rvs-line-pump.state-am-qnty = ?
            buf_rvs-line-pump.state-cf-qnty = ?
            buf_rvs-line-pump.state-mh-qnty = ?
          .
          find first other-line-pump no-lock
            where other-line-pump.rvs-code    = buf_rvs-line-pump.rvs-code
              and other-line-pump.obj-type    = buf_rvs-line-pump.obj-type
              and other-line-pump.obj-code    = buf_rvs-line-pump.obj-code
              and other-line-pump.gds-code    = buf_rvs-line-pump.gds-code
              and other-line-pump.pump-code   = buf_rvs-line-pump.pump-code
              and other-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code
          no-error .
          if available other-line-pump then do:
            assign
              buf_rvs-line-pump.state-am-cnt  = other-line-pump.state-am-cnt
              buf_rvs-line-pump.state-am-qnty = other-line-pump.state-am-qnty
              buf_rvs-line-pump.state-cf-cnt  = other-line-pump.state-cf-cnt
              buf_rvs-line-pump.state-cf-qnty = other-line-pump.state-cf-qnty
              buf_rvs-line-pump.state-el-cnt  = other-line-pump.state-el-cnt
              buf_rvs-line-pump.state-mh-cnt  = other-line-pump.state-mh-cnt
              buf_rvs-line-pump.state-mh-qnty = other-line-pump.state-mh-qnty
            .
          end.
          run placelib_get-attr(input "place-virtual"
                           ,input buf_rvs-line-pump.obj-code
                           ,input buf_rvs-line-pump.obj-type
                           ,input buf_rvs-line-pump.pl-code
                           ,output v-value
                           ,output v-ok) no-error.
          is-vir = if (v-ok and logical(v-value)) then true else false.
          if is-vir then
            assign
            buf_rvs-line-pump.meas-el-cnt   = 0
            buf_rvs-line-pump.meas-am-cnt   = 0
            buf_rvs-line-pump.meas-cf-cnt   = 0
            buf_rvs-line-pump.meas-mh-cnt   = 0
            buf_rvs-line-pump.meas-am-qnty  = 0
            buf_rvs-line-pump.meas-cf-qnty  = 0
            buf_rvs-line-pump.meas-mh-qnty  = 0
            buf_rvs-line-pump.state-el-cnt  = 0
            buf_rvs-line-pump.state-am-cnt  = 0
            buf_rvs-line-pump.state-cf-cnt  = 0
            buf_rvs-line-pump.state-mh-cnt  = 0
            buf_rvs-line-pump.state-am-qnty = 0
            buf_rvs-line-pump.state-cf-qnty = 0
            buf_rvs-line-pump.state-mh-qnty = 0
            .
        end.
      end.
    end.
  end.
  return .
end procedure.
define variable is_FatalError as   logical       no-undo.
procedure lib-rvs_rvsplace :
  define input        parameter           p-obj-type   like ub.rvs-doc.obj-type no-undo.
  define input        parameter           p-obj-code   like ub.rvs-doc.obj-code no-undo.
  define input        parameter           p-one-place  as   logical             no-undo.
  define input        parameter           p-read-cur   as   integer             no-undo.
  define input        parameter           p-message-on as   logical             no-undo.
  define input        parameter           p-no-waitfram as   logical             no-undo.
  define input-output parameter table for tt-meas-file.
  define input-output parameter table for tt-meas.
  define buffer bf_pl-level     for ub.pl-level.
  define buffer bf-nxt_pl-level for ub.pl-level.
  do
  on error  undo, return error substitute( "&1(lib-rvs_rvsplace). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1(lib-rvs_rvsplace). stop", vss-workfile )
  on endkey undo, return error substitute( "&1(lib-rvs_rvsplace). endkey", vss-workfile )
  :
    define variable v-value       as character no-undo.
    define variable v-ok          as logical   no-undo.
    define variable pl-twice-code as character no-undo.
    is_FatalError = no.
    define variable anl-loc       like ub.place.loc1 no-undo.
    define variable v_string-tmp  as   character     no-undo.
    define variable v_command     as   character     no-undo.
    define variable v_File-Name   as   character     no-undo.
    define variable v-err-file-name as character     no-undo .
    define variable v-log-file-name as character     no-undo .
    define variable j_num         as   integer       no-undo.
    define variable v_DirFilervs  as   character     no-undo.
    define variable l_log         as   logical       no-undo.
    define variable vartarirvalue as   character     no-undo.
    define variable vartarirtype  as   character     no-undo.
    define variable varlevel-sm   as   integer       no-undo.
    define variable Vrevis        as   longchar      no-undo.
    define variable v-reviserr    as   character     no-undo.
    define variable is-com-tanks  as   logical       no-undo init no .
      define variable tt-level-water     as integer no-undo.
      define variable tt-level-water-dec as decimal no-undo.
      define variable v-water-qnty       as decimal no-undo .
      define variable v-bh               as handle  no-undo .
      define variable v-fh               as handle  no-undo .
      define buffer bf-water-nxt_pl-level for pl-level.
      define variable varlevel-sm-water as decimal no-undo.
      define buffer bf_place for ub.place.
      define buffer buf_place for ub.place .
      define buffer buf_pl-gds for ub.pl-gds .
    run gbl/conf-rd.p ("tarir", "", "", 0, "", "", "", no, output vartarirvalue, output vartarirtype) no-error.
    define variable v_comstring   as   character     no-undo.
    define variable v_comment     as   character     no-undo.
    define variable v_StartString as   character     no-undo.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crtt-rvs in g#lib-rvs ( input-output table tt-param ,
                            output       v_comstring ,
                            output       v_comment ,
                            output       v_StartString ) no-error .
    if error-status :error then do:
      return error substitute( 'Ошибка при установке параметров для считывания данных с резервуаров.&1&2&1&3'
                            , chr(10)
                            , error-status :get-message( 1 )
                            , return-value ) .
    end.
    for each tt-meas-file :
      delete tt-meas-file .
    end.
    for each tt-place:
      delete tt-place.
    end.
    if p-one-place = yes then do:
      find first tt-meas no-error .
      if not available tt-meas then do:
        return error 'Ошибка. Данные по резервуару не найдены (возможно, не были считаны).' .
      end.
      find first bf_place no-lock
        where bf_place.obj-type = tt-meas.obj-type
          and bf_place.obj-code = tt-meas.obj-code
          and bf_place.pl-code  = tt-meas.pl-code
          and bf_place.status_ = ""
        no-error.
      assign
        anl-loc = trim( bf_place.loc1 )
      .
      run placelib_get-attr  ( input "place-twice-code"
                              ,input bf_place.obj-code
                              ,input bf_place.obj-type
                              ,input bf_place.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok
      and trim(v-value)  > ""
      then do :
        pl-twice-code = trim(v-value) .
        anl-loc = anl-loc + "," + pl-twice-code .
      end .
      run placelib_get-attr  ( input "place-com-tanks"
                              ,input bf_place.obj-code
                              ,input bf_place.obj-type
                              ,input bf_place.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      if v-ok
      and v-value > ""
      then do :
        do ii = 1 to num-entries(v-value) :
          find first bf_place no-lock
          where bf_place.obj-type = tt-meas.obj-type
            and bf_place.obj-code = tt-meas.obj-code
            and bf_place.loc1     = entry(ii, v-value)
            and bf_place.status_ = ""
          no-error.
          if available bf_place
          and bf_place.is-meas
          then do :
            anl-loc = anl-loc + "," + bf_place.loc1 .
          end .
        end .
        is-com-tanks = yes .
      end .
    end.
    else do:
      assign
        anl-loc = '0':U
      .
    end.
    v-log-file-name = substitute('&1rvs.log', ibs.th.gbl.gbl-inipar:logDir) .
    v-err-file-name = './rvs-err.log' .
    case p-read-cur :
      when 0
      then do :
        get-key-value section 'revision'
                      key     'dirflrvs'
                      value   v_DirFilervs.
        if v_DirFilervs = '':U
          or v_DirFilervs = ?
        then do:
          assign
            v_DirFilervs = '.':U
          .
        end.
        system-dialog get-file v_File-Name
          initial-dir v_DirFilervs
          title 'Выберите файл с данными из резервуаров'
          update l_log.
        if l_log <> yes then do:
          return error .
        end.
        run readfiletxt (v_File-Name, output Vrevis).
        run readrevisetxt (Vrevis,v_StartString,v_comment).
      end.
      when 1
      then do :
        run get-from-struna (v-log-file-name,p-obj-code )no-error.
        if error-status:error
        then do :
          return error return-value .
        end.
      end.
      when 2
      then do :
        run str/getAsiDataAgent.p (input anl-loc, input p-no-waitfram, output table tt-place ) no-error.
        if error-status:error
        then do :
          return error return-value + error-status:get-message (1).
        end.
      end.
      when 3
      then do :
        run get-from-ifsf (v-log-file-name,?,? )no-error.
        if error-status:error
        then do :
          return error return-value .
        end.
      end.
    end case .
    v-reviserr = "revis" + string(random(0,9)) + ".err" .
    if searchfile(v-reviserr) ne ?
    then do :
      v-reviserr = "revis" + string(random(0,9)) + ".err" .
      if searchfile(v-reviserr) ne ?
      then do :
        os-delete value(searchfile(v-reviserr)) no-error .
      end .
    end .
    output stream str-err to value(v-reviserr) .
    run creatett-meas-file(p-obj-type, p-obj-code).
      _recalc:
      for each tt-meas-file where not tt-meas-file.is-error
          on error undo, return error return-value
          :
          if not tt-meas-file.meas-vol-water then tt-meas-file.water-qnty = ? .
          if tt-meas-file.pl-code <> 0
          then do :
            find first buf_place no-lock where buf_place.obj-type = p-obj-type
                                           and buf_place.obj-code = p-obj-code
                                           and buf_place.pl-code  = tt-meas-file.pl-code
                                           and buf_place.is-meas  = yes
                                           no-error .
          end.
          else do :
            twice-code:
            for each  buf_place where buf_place.obj-code = p-obj-code
                                  and buf_place.obj-type = p-obj-type
                                  and buf_place.is-meas  = yes :
                run placelib_get-attr  ( input "place-twice-code"
                    ,input p-obj-code
                    ,input p-obj-type
                    ,input buf_place.pl-code
                    ,output v-value
                    ,output v-ok      ) no-error.
                if v-ok then pl-twice-code = v-value .
                if num-entries(pl-twice-code) > 1
                then do :
                  do ii = 1 to num-entries(pl-twice-code) :
                    if trim( entry( ii, pl-twice-code ) ) = trim( tt-meas-file.loc1 )
                    then do :
                      leave twice-code.
                    end.
                  end.
                end.
                else do :
                  if trim(pl-twice-code) =  trim( tt-meas-file.loc1 ) then leave twice-code.
                end.
                pl-twice-code = "" .
            end.
          end.
          if available buf_place
          then do :
            find first buf_pl-gds no-lock where buf_pl-gds.obj-type     = buf_place.obj-type
                                            and buf_pl-gds.obj-code     = buf_place.obj-code
                                            and buf_pl-gds.pl-code      = buf_place.pl-code
                                            and buf_pl-gds.status_      = 'тек':U
                                            no-error .
            if available buf_pl-gds
            and is-sug(buf_pl-gds.gds-code)
            then do :
              if tt-meas-file.level-petrol  = 0 and
                 tt-meas-file.level-total  <> 0 then do:
                assign
                  tt-meas-file.level-petrol = tt-meas-file.level-total - (if tt-meas-file.level-water <> ? then tt-meas-file.level-water else 0) .
              end.
              next _recalc.
            end .
          end.
          define variable place-asi-sertif  as logical no-undo.
          place-asi-sertif = no .
          run placelib_get-attr  ( input "place-asi-sertif"
                                ,input p-obj-code
                                ,input p-obj-type
                                ,input tt-meas-file.pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
          if v-ok then place-asi-sertif = logical(v-value) .
          if tt-meas-file.meas-vol-oil   = no and
              vartarirvalue = "yes"
              and tt-meas-file.log-brutto = no
              then
          do:
              if tt-meas-file.level-total = ? then
              do:
                  assign
                      is_FatalError = yes
                      .
                  put stream str-err unformatted
                    substitute("&2 Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара &1 не задан уровень в резервуаре."
                      , tt-meas-file.loc1
                      , cur-time-string-sec()
                     ) skip.
              end.
              else
              do:
                  assign
                      varlevel-sm = trunc (tt-meas-file.level-total, 0).
                  find first bf_pl-level where bf_pl-level.obj-type = tt-meas-file.obj-type and
                      bf_pl-level.obj-code = tt-meas-file.obj-code and
                      bf_pl-level.pl-code  = tt-meas-file.pl-code  and
                      bf_pl-level.pl-level = varlevel-sm           no-error.
                  if not available bf_pl-level then
                  do:
                      if tt-meas-file.pl-code <> 0 then
                      do:
                          assign
                              is_FatalError = yes
                              .
                          put stream str-err unformatted
                            substitute("&3 Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара &1 не задан объем для уровня &2"
                            , tt-meas-file.loc1
                            , varlevel-sm
                            , cur-time-string-sec()
                            ) skip.
                      end.
                  end.
                  else
                  do:
                      if varlevel-sm = tt-meas-file.level-total then
                      do:
                          assign
                              tt-meas-file.brutto-qnty      = bf_pl-level.pl-qnty
                              tt-meas-file.brutto-cli-qnty  = tt-meas-file.density * tt-meas-file.brutto-qnty
                              tt-meas-file.measure-qnty     = tt-meas-file.brutto-qnty
                              tt-meas-file.measure-cli-qnty = tt-meas-file.measure-qnty * tt-meas-file.density
                              .
                      end.
                      else
                      do:
                          assign
                              varlevel-sm = varlevel-sm + 1.
                          find first bf-nxt_pl-level where bf-nxt_pl-level.obj-type = tt-meas-file.obj-type and
                              bf-nxt_pl-level.obj-code = tt-meas-file.obj-code and
                              bf-nxt_pl-level.pl-code  = tt-meas-file.pl-code  and
                              bf-nxt_pl-level.pl-level  = varlevel-sm           no-error.
                          if not available bf-nxt_pl-level then
                          do:
                              assign
                                  is_FatalError = yes
                                  .
                              put stream str-err unformatted
                                substitute("&4 Вычисляем объем резервуаров через градуировочные таблицы. Для резервуара &1 не задан объем для уровня &2 измерение &3"
                                , tt-meas-file.loc1
                                , varlevel-sm
                                , tt-meas-file.level-total
                                , cur-time-string-sec()
                                ) skip.
                          end.
                          else
                          do:
                              assign
                                  tt-meas-file.brutto-qnty      = bf_pl-level.pl-qnty + (bf-nxt_pl-level.pl-qnty - bf_pl-level.pl-qnty) * (tt-meas-file.level-total - trunc(tt-meas-file.level-total, 0))
                                  tt-meas-file.brutto-cli-qnty  = tt-meas-file.density * tt-meas-file.brutto-qnty
                                  tt-meas-file.measure-qnty     = tt-meas-file.brutto-qnty
                                  tt-meas-file.measure-cli-qnty = tt-meas-file.measure-qnty * tt-meas-file.density.
                          end.
                      end.
                      if  tt-meas-file.meas-vol-water = no  and tt-meas-file.level-water <> 0  then
                      do:
                          find first bf-nxt_pl-level where bf-nxt_pl-level.obj-type = tt-meas-file.obj-type and
                              bf-nxt_pl-level.obj-code = tt-meas-file.obj-code and
                              bf-nxt_pl-level.pl-code  = tt-meas-file.pl-code  and
                              bf-nxt_pl-level.pl-level  =    tt-meas-file.level-water    no-error.
                          if  not available bf-nxt_pl-level then
                          do:
                              assign
                                  varlevel-sm-water = tt-meas-file.level-water + 1.
                              for each  bf-water-nxt_pl-level where bf-water-nxt_pl-level.obj-type = tt-meas-file.obj-type and
                                  bf-water-nxt_pl-level.obj-code = tt-meas-file.obj-code and
                                  bf-water-nxt_pl-level.pl-code  = tt-meas-file.pl-code  and
                                  bf-water-nxt_pl-level.pl-level  <  varlevel-sm-water   and
                                  bf-water-nxt_pl-level.pl-level > tt-meas-file.level-water - 1 no-lock  :
                                  v-water-qnty = abs (  abs (v-water-qnty )  -  bf-water-nxt_pl-level.pl-qnty / 10 )  .
                                  if  bf-water-nxt_pl-level.pl-level > tt-meas-file.level-water - 1 and bf-water-nxt_pl-level.pl-level < tt-meas-file.level-water then
                                  do:
                                      tt-level-water =  bf-water-nxt_pl-level.pl-qnty.
                                      tt-level-water-dec = tt-meas-file.level-water - bf-water-nxt_pl-level.pl-level .
                                  end.
                              end.
                              tt-meas-file.water-qnty =  tt-level-water +  tt-level-water-dec *  v-water-qnty * 10  .
                          end.
                          else
                          do:
                              assign
                                  tt-meas-file.water-qnty = bf-nxt_pl-level.pl-qnty  .
                          end.
                      end.
                  end.
              end.
          end.
        if vartarirvalue = "no" or vartarirvalue = "" then
        do:
          if tt-meas-file.log-brutto = yes
          and tt-meas-file.density > 0
          and tt-meas-file.density < 1
          then
          do:
              if place-asi-sertif
              then do :
                assign
                  tt-meas-file.measure-qnty = tt-meas-file.measure-cli-qnty / tt-meas-file.density
                .
              end.
              else
              if tt-meas-file.brutto-qnty <> 0 or tt-meas-file.brutto-qnty <> ? then
              do:
                assign
                  tt-meas-file.density         = tt-meas-file.measure-cli-qnty / tt-meas-file.brutto-qnty
                  tt-meas-file.measure-qnty    = tt-meas-file.brutto-qnty
                  tt-meas-file.brutto-cli-qnty = tt-meas-file.density * tt-meas-file.brutto-qnty
                  .
              end.
              else
              do:
                put stream str-err unformatted
                  'Не заданы объем и плотность'  skip .
              end.
          end.
        end.
        if tt-meas-file.level-petrol  = 0 and
           tt-meas-file.level-total  <> 0 then do:
          assign
            tt-meas-file.level-petrol = tt-meas-file.level-total - (if tt-meas-file.level-water <> ? then tt-meas-file.level-water else 0) .
        end.
        if tt-meas-file.meas-vol-oil   = no
            and tt-meas-file.meas-vol-water = no
            then
        do:
            if tt-meas-file.density <> 0 and
                tt-meas-file.density <> ?
                then
            do:
                if ( tt-meas-file.brutto-cli-qnty =  0   or
                    tt-meas-file.brutto-cli-qnty =  ? ) and
                    tt-meas-file.brutto-qnty     <> 0   and
                    tt-meas-file.brutto-qnty     <> ?
                    then
                do:
                    assign
                        tt-meas-file.brutto-cli-qnty = tt-meas-file.density * tt-meas-file.brutto-qnty
                        .
                end.
                if ( tt-meas-file.brutto-qnty     =  0   or
                    tt-meas-file.brutto-qnty     =  ? ) and
                    tt-meas-file.brutto-cli-qnty <> 0   and
                    tt-meas-file.brutto-cli-qnty <> ?
                    then
                do:
                    assign
                        tt-meas-file.brutto-qnty = tt-meas-file.brutto-cli-qnty / tt-meas-file.density
                        .
                end.
            end.
            else
            do:
            end.
            if tt-meas-file.density > 0
            and tt-meas-file.density < 1
            and tt-meas-file.density <> ?
            then do :
              if tt-meas-file.log-brutto
              then do :
                tt-meas-file.measure-qnty = tt-meas-file.measure-cli-qnty / tt-meas-file.density .
              end.
              else do :
                assign
                  tt-meas-file.measure-qnty = tt-meas-file.brutto-qnty -  (if tt-meas-file.water-qnty <> ? then tt-meas-file.water-qnty else 0)
                  tt-meas-file.measure-cli-qnty = tt-meas-file.measure-qnty * tt-meas-file.density
                .
              end.
            end .
        end.
        else
        do:
            if tt-meas-file.meas-vol-oil = no then
            do:
                assign
                    tt-meas-file.measure-qnty = tt-meas-file.brutto-qnty - (if tt-meas-file.water-qnty <> ? then tt-meas-file.water-qnty else 0)
                    .
            end.
            if tt-meas-file.density > 0
            and tt-meas-file.density < 1
            and tt-meas-file.density <> ?
            then do :
              if tt-meas-file.log-brutto
              then do :
                tt-meas-file.measure-qnty = tt-meas-file.measure-cli-qnty / tt-meas-file.density .
              end.
              else do :
                assign
                  tt-meas-file.measure-cli-qnty = tt-meas-file.measure-qnty * tt-meas-file.density
                .
              end.
            end .
        end.
      if tt-meas-file.meas-vol-water and tt-meas-file.level-water  = 0 and abs(tt-meas-file.brutto-cli-qnty - tt-meas-file.measure-cli-qnty) <= 0.1 then tt-meas-file.brutto-cli-qnty = tt-meas-file.measure-cli-qnty.
    end.
    for each tt-meas
    on error undo, return error return-value
    :
      find first tt-meas-file where
                tt-meas-file.obj-type = tt-meas.obj-type and
                tt-meas-file.obj-code = tt-meas.obj-code and
                tt-meas-file.pl-code  = tt-meas.pl-code  no-error .
      if not available tt-meas-file then do:
        if p-one-place = ? then do:
          delete tt-meas.
          next.
        end.
        else do:
          if not is-com-tanks
          then do :
            assign
              is_FatalError = yes
            .
          end .
          put stream str-err unformatted substitute( 'Не получены данные по резервуару &1 .'
                                                     , tt-meas.pl-code ) skip .
          if is-com-tanks
          then do :
            if p-message-on
            then do :
              message substitute( 'Не получены данные по резервуару &1 .', tt-meas.pl-code ) view-as alert-box .
            end .
            delete tt-meas.
            next.
          end .
        end.
      end.
    end.
    for each tt-meas-file
    on error undo, return error return-value
    :
      find first tt-meas where
                tt-meas.obj-type = tt-meas-file.obj-type and
                tt-meas.obj-code = tt-meas-file.obj-code and
                tt-meas.pl-code  = tt-meas-file.pl-code  and
                tt-meas.loc1     = tt-meas-file.loc1 no-error .
      if not available tt-meas then do:
          if tt-meas-file.loc1 <> "" and tt-meas-file.pl-code = 0  then
          do:
              create tt-meas .
              assign
                  tt-meas.obj-type = tt-meas-file.obj-type
                  tt-meas.obj-code = tt-meas-file.obj-code
                  tt-meas.loc1     = tt-meas-file.loc1 no-error.
          end.
          else
          do:
              if p-one-place = ? then
              do:
          assign
            is_FatalError = yes
          .
        end.
        put stream str-err unformatted
          substitute( '&2 Получены данные по резервуару &1 по которому нет запроса.'
                     , tt-meas-file.pl-code
                     , cur-time-string-sec()
                      ) skip .
      end.
      end.
    end.
    output stream str-err close.
    output to value(v-err-file-name) append.
    put unformatted string(today) ' ' string(time, "HH:MM:SS") skip .
    output close .
    OS-APPEND value(v-reviserr) value(v-err-file-name).
    if is_FatalError = yes then do:
      return error 'При считывании данных с резервуаров произошли ошибки НЕПОЗВОЛЯЮЩИЕ ЗАГРУЗИТЬ ДАННЫЕ.' .
    end.
    for  each tt-meas,
      first tt-meas-file
      where tt-meas-file.obj-type = tt-meas.obj-type
        and tt-meas-file.obj-code = tt-meas.obj-code
        and ((tt-meas-file.pl-code  = tt-meas.pl-code
        and tt-meas.pl-code <> 0) or tt-meas-file.loc1 = tt-meas.loc1)
    on error undo, return error return-value
    :
      if tt-meas-file.is-error
      then do :
        assign
          tt-meas.measure-qnty     = ?
          tt-meas.brutto-qnty      = ?
          tt-meas.measure-cli-qnty = ?
          tt-meas.brutto-cli-qnty  = ?
          tt-meas.density          = ?
          tt-meas.temperature      = ?
          tt-meas.level-total      = ?
          tt-meas.level-petrol     = ?
          tt-meas.level-water      = ?
          tt-meas.temp-layer1      = ?
          tt-meas.temp-layer2      = ?
          tt-meas.temp-layer3      = ?
          tt-meas.measure-tc-qnty  = ?
          tt-meas.brutto-tc-qnty   = ?
          tt-meas.vapor-density    = ?
          tt-meas.vapor-pressure   = ?
          tt-meas.water-qnty       = ?
          tt-meas.is-error         = yes
        .
      end .
      else do :
        assign
          tt-meas.measure-qnty     = tt-meas-file.measure-qnty
          tt-meas.brutto-qnty      = tt-meas-file.brutto-qnty
          tt-meas.measure-cli-qnty = tt-meas-file.measure-cli-qnty
          tt-meas.brutto-cli-qnty  = tt-meas-file.brutto-cli-qnty
          tt-meas.density          = tt-meas-file.density
          tt-meas.temperature      = (if tt-meas-file.temp-not-null then tt-meas-file.temperature else ?)
          tt-meas.level-total      = tt-meas-file.level-total
          tt-meas.level-petrol     = tt-meas-file.level-petrol
          tt-meas.level-water      = tt-meas-file.level-water
          tt-meas.temp-layer1      = (if tt-meas-file.t1-not-null then tt-meas-file.temp-layer1 else ?)
          tt-meas.temp-layer2      = (if tt-meas-file.t2-not-null then tt-meas-file.temp-layer2 else ?)
          tt-meas.temp-layer3      = (if tt-meas-file.t3-not-null then tt-meas-file.temp-layer3 else ?)
          tt-meas.measure-tc-qnty  = tt-meas-file.measure-tc-qnty
          tt-meas.brutto-tc-qnty   = tt-meas-file.brutto-tc-qnty
          tt-meas.vapor-density    = tt-meas-file.vapor-density
          tt-meas.vapor-pressure   = tt-meas-file.vapor-pressure
          tt-meas.water-qnty       = tt-meas-file.water-qnty
          tt-meas.is-error         = no
        .
      end .
    end.
end.
  return .
  finally:
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1rvs-err.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(v-err-file-name) value(v-save-file-name).
  end finally .
end procedure.
procedure lib-rvs_fill1plc :
  define input        parameter           p-obj-type  like ub.rvs-line.obj-type no-undo.
  define input        parameter           p-obj-code  like ub.rvs-line.obj-code no-undo.
  define input        parameter           p-pl-code   like ub.rvs-line.pl-code  no-undo.
  define input        parameter           p-rec-line  as   recid                no-undo.
  define input        parameter           p-prev-code like ub.rvs-doc.rvs-code  no-undo.
  define input-output parameter table for tt-meas.
    DEFINE VARIABLE rdc-dnstvalue AS CHARACTER NO-UNDO INITIAL ?.
    DEFINE VARIABLE rdc-dnsttype  AS CHARACTER NO-UNDO INITIAL ?.
  define variable varnum-rsrv  as integer   no-undo.
  define variable v-code            as character no-undo.
  define variable ii                as integer   no-undo.
  define variable v-value           as character no-undo.
  define variable v-ok              as logical   no-undo.
  define variable  p-prev-rvs-date  as logical no-undo.
  define variable v-vid-ok  as logical   no-undo .
  define variable v-vid-mes as character no-undo .
  define variable v-vid-action as integer    no-undo .
  define variable v-vid-param  as longchar   no-undo .
  define variable v-mm         as com-handle.
  define variable v-proc       as character  no-undo.
  define variable v-mm57       as com-handle.
  define variable Tv as decimal no-undo .
  define variable Tr as decimal no-undo .
  define variable R  as decimal no-undo .
  define variable place-type        as integer no-undo.
  define variable place-SI          as integer no-undo.
  define variable place-diameter    as decimal no-undo.
  define variable place-ratio-error as decimal no-undo.
  define variable place-asi-sertif  as logical no-undo.
  define variable dens-prov         as decimal no-undo format "9.9999999999":U.
  define variable pl-twice-code as character no-undo.
  define variable CalibTable        as character no-undo initial "".
  define variable CalibBelt         as character no-undo initial "".
  define variable ToolType          as integer no-undo.
  define variable LevelToolType          as integer no-undo.
  define variable A_LevelMeasurementTool  as decimal no-undo.
  define variable DeltaAbs_H              as decimal no-undo.
  define variable DeltaAbs_H_Water        as decimal no-undo.
  define variable DeltaAbs_R              as decimal no-undo.
  define variable DeltaAbs_R_liquid          as decimal no-undo.
  define variable DeltaAbs_R_Gas    as decimal no-undo.
  define variable DeltaAbs_Tv             as decimal no-undo.
  define variable DeltaAbs_Tr             as decimal no-undo.
  define variable DeltaOtn_N              as decimal no-undo init 0.05 .
  define variable DeltaOtn_K              as decimal no-undo.
  define variable DeltaOtn_K_Full         as decimal no-undo.
  define variable A_Reservoir             as decimal no-undo init 0.0000125 .
  define variable DeadZone_Reservoir      as decimal no-undo.
  define variable DeltaOtn_H              as decimal no-undo.
  define variable DeltaOtn_H_Water        as decimal no-undo.
  define variable DeltaOtn_R              as decimal no-undo.
  define variable ToolAutomationLevel_H   as integer no-undo.
  define variable ToolAutomationLevel_H_Water as integer no-undo.
  define variable ToolAutomationLevel_R   as integer no-undo.
  define variable ToolAutomationLevel_Tv  as integer no-undo.
  define variable ToolAutomationLevel_Tr  as integer no-undo.
  define variable DeltaAbs_H_CalcType     as integer no-undo.
  define variable DeltaAbs_H_Water_CalcType as integer no-undo.
  define variable Use_DeltaOtn_R_liquid_IN  as logical no-undo.
  define variable DeltaOtn_R_liquid_IN    as decimal no-undo.
  define variable temp-for-pomi           as integer no-undo.
  define variable temp-izm-vol            as decimal no-undo init ? .
  define variable izmer-density           as decimal no-undo init ? .
  define variable error-string            as character no-undo.
  define variable v-mm-density            as decimal no-undo.
  define variable v-POkMI-result          as character no-undo.
  define variable v-POkMI-result-attr     as character no-undo.
  define variable v-POkMI-warnings        as character no-undo.
  define variable v-pokmi-dll-version     as character no-undo .
  define variable place-ponton            as logical no-undo .
  define variable place-ponton-mass       as decimal no-undo .
  define variable place-ponton-height     as decimal no-undo .
  define variable DeltaV1                 as decimal no-undo .
  define variable DeltaV2                 as decimal no-undo .
  define variable WaterDeltaV1            as decimal no-undo .
  define variable WaterDeltaV2            as decimal no-undo .
  define variable DeltaVSugFull           as decimal no-undo .
  define variable pl-rvd-dens as logical no-undo .
  define variable pl-rvd-lvl as logical no-undo .
  define variable pl-rvd-temp as logical no-undo .
  define variable pl-dens-sr-izm    as integer no-undo .
  define variable pl-level-sr-izm   as integer no-undo .
  define variable pl-temp-sr-izm    as integer no-undo .
  define variable v-full-name as character no-undo .
  define variabl v-file-name as character no-undo.
  define buffer crl_prev_rvs-doc for ub.rvs-doc.
  define buffer prev_rvs-line    for ub.rvs-line.
  define buffer prev_rvs-line-attr    for ub.rvs-line-attr.
  define buffer bf_goods         for ub.goods.
  define buffer bf_gds-obj       for ub.gds-obj.
  define buffer bf-prev_doc-line for ub.doc-line.
  define buffer bf-prev_inv-line for ub.inv-line.
  define buffer bf-prp_goods     for ub.goods.
  define buffer bf-prp_pl-gds    for ub.pl-gds.
  define buffer bf_rvs-line      for ub.rvs-line.
  define buffer buf_sr-izmerenia for ub.sr-izmerenia .
  define buffer buf_doc-attr     for ub.doc-attr.
  define buffer bf_place         for ub.place .
  define buffer buf_tt-meas      for tt-meas .
  define buffer water1_pl-level  for ub.pl-level .
  define buffer water2_pl-level  for ub.pl-level .
  define buffer total1_pl-level  for ub.pl-level .
  define buffer total2_pl-level  for ub.pl-level .
  define buffer buf_pl-level-attr for ub.pl-level-attr .
  define buffer sug1_pl-level  for ub.pl-level .
  define buffer sug2_pl-level  for ub.pl-level .
  define buffer full_pl-level  for ub.pl-level .
  define buffer full2_pl-level  for ub.pl-level .
  define buffer buf_doc-pl for ub.doc-pl .
  define buffer buf_rvs-doc for ub.rvs-doc .
  define buffer buf_doc-pl-attr for ub.doc-pl-attr .
  define buffer buf_place for ub.place .
  define buffer buf_trn-doc  for ub.trn-doc.
  define variable v-free-vol  as decimal   no-undo .
  define variable v-doc-volume as decimal no-undo .
  define variable  v-cardif as integer no-undo.
  define variable v-delta-mas-qnty as decimal no-undo.
  define variable v-is-olddens as logical no-undo init no .
  define variable twice-num   as integer no-undo.
  define variable twice-place-data as character no-undo .
  define variable sug-density as decimal no-undo .
  define variable sug-water-qnty as decimal no-undo .
  define variable vapor-density as decimal no-undo .
  define variable state-vapor-density as decimal no-undo .
  define variable vapor-pressure as decimal no-undo .
  define variable state-vapor-pressure as decimal no-undo .
  define variable sug-volume as decimal no-undo .
  define variable sug-pf-volume as decimal no-undo .
  define variable is-main-tank as logical no-undo .
  define variable v-prev-temp as logical no-undo .
  define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].
  define variable vErr as character no-undo .
  define variable vWrn as character no-undo .
  define variable vDllVersion as character no-undo .
  define variable V_total      as decimal no-undo .
  define variable V_water      as decimal no-undo .
  define variable DeltaV       as decimal no-undo .
  define variable Vcy          as decimal no-undo .
  define variable Rcy          as decimal no-undo .
  define variable V_product    as decimal no-undo .
  define variable V            as decimal no-undo .
  define variable Rv           as decimal no-undo .
  define variable M            as decimal no-undo .
  define variable CTL_base_alt as decimal no-undo .
  define variable CPL_base_alt as decimal no-undo .
  define variable CTPL_base_alt as decimal no-undo .
  define variable Fp_base_alt  as decimal no-undo .
  define variable CTL_obs_base as decimal no-undo .
  define variable CPL_obs_base as decimal no-undo .
  define variable CTPL_obs_base as decimal no-undo .
  define variable Fp_obs_base  as decimal no-undo .
  define variable DeltaOtn_Vcy as decimal no-undo .
  define variable DeltaOtn_Vm  as decimal no-undo .
  define variable DeltaOtn_M   as decimal no-undo .
  define variable VolumetricExpansion as decimal no-undo .
  define variable C_HN              as decimal no-undo .
  define variable C_HN_delta        as decimal no-undo .
  define variable C_full            as decimal no-undo .
  define variable V_liquid          as decimal no-undo .
  define variable V_gas             as decimal no-undo .
  define variable M_liquid          as decimal no-undo .
  define variable M_gas             as decimal no-undo .
  define variable Kf                as decimal no-undo .
  define variable DeltaOtn_R_liquid as decimal no-undo .
  define variable DeltaOtn_R_gas    as decimal no-undo .
  define variable DeltaOtn_M_liquid as decimal no-undo .
  define variable DeltaOtn_M_gas    as decimal no-undo .
  define variable H_min_liquid      as decimal no-undo .
  define variable H_min             as decimal no-undo .
  define variable A                 as decimal no-undo .
  define variable B                 as decimal no-undo .
  find first bf_rvs-line exclusive-lock
    where recid( bf_rvs-line ) = p-rec-line
  .
  find first tt-meas
    where tt-meas.obj-type = p-obj-type
      and tt-meas.obj-code = p-obj-code
      and tt-meas.pl-code  = p-pl-code
    no-error.
  if not available tt-meas then do:
    return error substitute( 'Ошибка. С приборов не получены данные по резервуару &1 .'
                           , p-pl-code ) .
  end.
  if tt-meas.is-error then do:
    return error substitute( 'Ошибка. С приборов не получены данные по резервуару &1 .'
                           , p-pl-code ) .
  end.
    find first tt-meas-file
    where tt-meas-file.obj-type = tt-meas.obj-type
      and tt-meas-file.obj-code = tt-meas.obj-code
      and tt-meas-file.pl-code  = tt-meas.pl-code
    no-error.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input p-obj-type
  , input p-obj-code
  ) .
  find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-code = bf_rvs-line.rvs-code .
  if buf_rvs-doc.rvs-type = 'проверка':U
  then do :
    assign
      bf_rvs-line.measure-qnty           = tt-meas.measure-qnty
      bf_rvs-line.brutto-qnty            = tt-meas.brutto-qnty
      bf_rvs-line.measure-cli-qnty       = tt-meas.measure-cli-qnty
      bf_rvs-line.brutto-cli-qnty        = tt-meas.brutto-cli-qnty
      bf_rvs-line.level-total            = tt-meas.level-total
      bf_rvs-line.level-petrol           = tt-meas.level-petrol
      bf_rvs-line.level-water            = tt-meas.level-water
      bf_rvs-line.temp-layer1            = tt-meas.temp-layer1
      bf_rvs-line.temp-layer2            = tt-meas.temp-layer2
      bf_rvs-line.temp-layer3            = tt-meas.temp-layer3
      bf_rvs-line.measure-tc-qnty        = tt-meas.measure-tc-qnty
      bf_rvs-line.brutto-tc-qnty         = tt-meas.brutto-tc-qnty
      bf_rvs-line.temperature            = tt-meas.temperature
      bf_rvs-line.density                = if tt-meas.density > 0 then tt-meas.density else  bf_rvs-line.state-density
      bf_rvs-line.brutto-cli-qnty        = if bf_rvs-line.brutto-cli-qnty <> 0 then bf_rvs-line.brutto-cli-qnty else bf_rvs-line.brutto-qnty * bf_rvs-line.density
      bf_rvs-line.measure-cli-qnty       = if bf_rvs-line.measure-cli-qnty <> 0 then bf_rvs-line.measure-cli-qnty else bf_rvs-line.measure-qnty * bf_rvs-line.density
      bf_rvs-line.state-level-total = 0
      bf_rvs-line.state-level-water = 0
      bf_rvs-line.state-density = 0
      bf_rvs-line.state-temperature = ?
    .
    if tt-meas.water-qnty <> ?
    then do :
      find first rvs-line-attr exclusive-lock
           where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
             and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
             and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
             and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
             and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
             and rvs-line-attr.attr-code = "measure-water-qnty" no-error.
      if not available rvs-line-attr then do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = bf_rvs-line.obj-code
          rvs-line-attr.obj-type  = bf_rvs-line.obj-type
          rvs-line-attr.gds-code  = bf_rvs-line.gds-code
          rvs-line-attr.pl-code   = bf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "measure-water-qnty"
        .
      end.
      rvs-line-attr.attr-value = string(tt-meas.water-qnty) .
    end .
    return .
  end .
  assign
    bf_rvs-line.measure-qnty           = tt-meas.measure-qnty
    bf_rvs-line.brutto-qnty            = tt-meas.brutto-qnty
    bf_rvs-line.measure-cli-qnty       = tt-meas.measure-cli-qnty
    bf_rvs-line.brutto-cli-qnty        = tt-meas.brutto-cli-qnty
    bf_rvs-line.level-total            = tt-meas.level-total
    bf_rvs-line.level-petrol           = tt-meas.level-petrol
    bf_rvs-line.level-water            = tt-meas.level-water
    bf_rvs-line.temp-layer1            = tt-meas.temp-layer1
    bf_rvs-line.temp-layer2            = tt-meas.temp-layer2
    bf_rvs-line.temp-layer3            = tt-meas.temp-layer3
    bf_rvs-line.measure-tc-qnty        = tt-meas.measure-tc-qnty
    bf_rvs-line.brutto-tc-qnty         = tt-meas.brutto-tc-qnty
    bf_rvs-line.state-measure-qnty     = bf_rvs-line.measure-qnty
    bf_rvs-line.state-brutto-qnty      = bf_rvs-line.brutto-qnty
    bf_rvs-line.state-level-total      = bf_rvs-line.level-total
    bf_rvs-line.state-level-petrol     = bf_rvs-line.level-petrol
    bf_rvs-line.state-level-water      = bf_rvs-line.level-water
    bf_rvs-line.state-temp-layer1      = bf_rvs-line.temp-layer1
    bf_rvs-line.state-temp-layer2      = bf_rvs-line.temp-layer2
    bf_rvs-line.state-temp-layer3      = bf_rvs-line.temp-layer3
    bf_rvs-line.state-measure-tc-qnty  = bf_rvs-line.measure-tc-qnty
    bf_rvs-line.state-brutto-tc-qnty   = bf_rvs-line.brutto-tc-qnty
  .
  if tt-meas.water-qnty <> ?
  then do :
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
           and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
           and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
           and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
           and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
           and rvs-line-attr.attr-code = "measure-water-qnty" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = bf_rvs-line.obj-code
        rvs-line-attr.obj-type  = bf_rvs-line.obj-type
        rvs-line-attr.gds-code  = bf_rvs-line.gds-code
        rvs-line-attr.pl-code   = bf_rvs-line.pl-code
        rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
        rvs-line-attr.attr-code = "measure-water-qnty"
      .
    end.
    rvs-line-attr.attr-value = string(tt-meas.water-qnty) .
  end .
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
         and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
         and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
         and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
         and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-p" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = bf_rvs-line.obj-code
      rvs-line-attr.obj-type  = bf_rvs-line.obj-type
      rvs-line-attr.gds-code  = bf_rvs-line.gds-code
      rvs-line-attr.pl-code   = bf_rvs-line.pl-code
      rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-p"
    .
  end.
  rvs-line-attr.attr-value = 'а' .
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
         and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
         and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
         and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
         and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-t" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = bf_rvs-line.obj-code
      rvs-line-attr.obj-type  = bf_rvs-line.obj-type
      rvs-line-attr.gds-code  = bf_rvs-line.gds-code
      rvs-line-attr.pl-code   = bf_rvs-line.pl-code
      rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-t"
    .
  end.
  rvs-line-attr.attr-value = 'а' .
  find first rvs-line-attr exclusive-lock
       where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
         and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
         and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
         and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
         and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
         and rvs-line-attr.attr-code = "input-type-l" no-error.
  if not available rvs-line-attr then do :
    create rvs-line-attr.
    assign
      rvs-line-attr.obj-code  = bf_rvs-line.obj-code
      rvs-line-attr.obj-type  = bf_rvs-line.obj-type
      rvs-line-attr.gds-code  = bf_rvs-line.gds-code
      rvs-line-attr.pl-code   = bf_rvs-line.pl-code
      rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
      rvs-line-attr.attr-code = "input-type-l"
    .
  end.
  rvs-line-attr.attr-value = 'а' .
place-asi-sertif = no .
run placelib_get-attr  ( input "place-asi-sertif"
                      ,input p-obj-code
                      ,input p-obj-type
                      ,input p-pl-code
                      ,output v-value
                      ,output v-ok      ) no-error.
if v-ok then place-asi-sertif = logical(v-value) .
if ptrlprop-olddens = true
then do:
  if tt-meas.density = 0 then do:
    assign
      tt-meas.density                    = bf_rvs-line.state-density
    .
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
           and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
           and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
           and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
           and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-olddens" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = bf_rvs-line.obj-code
        rvs-line-attr.obj-type  = bf_rvs-line.obj-type
        rvs-line-attr.gds-code  = bf_rvs-line.gds-code
        rvs-line-attr.pl-code   = bf_rvs-line.pl-code
        rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
        rvs-line-attr.attr-code = "is-olddens"
      .
    end.
    rvs-line-attr.attr-value = 'yes' .
  end.
  else do :
    find first rvs-line-attr exclusive-lock
         where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
           and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
           and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
           and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
           and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
           and rvs-line-attr.attr-code = "is-olddens" no-error.
    if not available rvs-line-attr then do :
      create rvs-line-attr.
      assign
        rvs-line-attr.obj-code  = bf_rvs-line.obj-code
        rvs-line-attr.obj-type  = bf_rvs-line.obj-type
        rvs-line-attr.gds-code  = bf_rvs-line.gds-code
        rvs-line-attr.pl-code   = bf_rvs-line.pl-code
        rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
        rvs-line-attr.attr-code = "is-olddens"
      .
    end.
    rvs-line-attr.attr-value = 'no' .
  end.
 end.
  assign
    sug-density = tt-meas.density
    vapor-density = tt-meas.vapor-density
    state-vapor-density = tt-meas.vapor-density
    vapor-pressure = tt-meas.vapor-pressure
    state-vapor-pressure = tt-meas.vapor-pressure
    sug-water-qnty = tt-meas.water-qnty
  .
  if is-sug(bf_rvs-line.gds-code)
  then do :
    assign
      bf_rvs-line.temperature            = tt-meas.temperature
      bf_rvs-line.state-temperature      = bf_rvs-line.temperature
      bf_rvs-line.density                = tt-meas.density
      bf_rvs-line.state-density          = if bf_rvs-line.density > 0 then bf_rvs-line.density else bf_rvs-line.state-density
    .
    if bf_rvs-line.level-petrol = 0
    or bf_rvs-line.level-petrol = ?
    then do :
      bf_rvs-line.level-petrol = bf_rvs-line.level-total - (if bf_rvs-line.level-water <> ? then bf_rvs-line.level-water else 0) .
    end .
    assign
      bf_rvs-line.measure-qnty           = tt-meas.brutto-qnty
      bf_rvs-line.measure-tc-qnty        = bf_rvs-line.measure-qnty
      bf_rvs-line.brutto-qnty            = tt-meas.brutto-qnty + bf_rvs-line.add-qnty
      bf_rvs-line.measure-cli-qnty       = tt-meas.brutto-cli-qnty
      bf_rvs-line.brutto-cli-qnty        = tt-meas.brutto-cli-qnty + (bf_rvs-line.add-qnty * bf_rvs-line.density)
    .
    assign
      bf_rvs-line.state-level-petrol      = bf_rvs-line.level-petrol
      bf_rvs-line.state-level-total       = bf_rvs-line.level-total
      bf_rvs-line.state-brutto-cli-qnty   = bf_rvs-line.brutto-cli-qnty
      bf_rvs-line.state-measure-cli-qnty  = bf_rvs-line.measure-cli-qnty
      bf_rvs-line.state-measure-qnty      = bf_rvs-line.measure-qnty
      bf_rvs-line.state-brutto-qnty       = bf_rvs-line.brutto-qnty
      bf_rvs-line.state-measure-tc-qnty   = bf_rvs-line.measure-tc-qnty
    .
  end .
  else do :
    assign
      bf_rvs-line.temperature            = tt-meas.temperature
      bf_rvs-line.state-temperature      = bf_rvs-line.temperature
      bf_rvs-line.density                = if tt-meas.density > 0 then tt-meas.density else  bf_rvs-line.state-density
      bf_rvs-line.brutto-cli-qnty        = if bf_rvs-line.brutto-cli-qnty <> 0 then bf_rvs-line.brutto-cli-qnty else bf_rvs-line.brutto-qnty * bf_rvs-line.density
      bf_rvs-line.measure-cli-qnty       = if bf_rvs-line.measure-cli-qnty <> 0 then bf_rvs-line.measure-cli-qnty else bf_rvs-line.measure-qnty * bf_rvs-line.density
      bf_rvs-line.state-density          = if bf_rvs-line.density > 0 then bf_rvs-line.density else bf_rvs-line.state-density
      bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.state-measure-qnty * bf_rvs-line.state-density
      bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.state-brutto-qnty  * bf_rvs-line.state-density
    .
    find first rvs-line-attr exclusive-lock
        where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
          and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
          and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
          and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
          and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
          and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
    if available rvs-line-attr
    then do :
      rvs-line-attr.attr-value = string(?) .
    end .
  end .
    run placelib_get-attr  ( input "place-twice-code"
        ,input p-obj-code
        ,input p-obj-type
        ,input p-pl-code
        ,output v-value
        ,output v-ok      ) no-error.
    if v-ok then pl-twice-code = v-value .
    if pl-twice-code <> "" then
    do:
        if is-sug(bf_rvs-line.gds-code)
        then do :
          find first place no-lock where place.obj-type = p-obj-type
                                     and place.obj-code = p-obj-code
                                     and place.pl-code  = p-pl-code
                                     no-error .
          if tt-meas.measure-qnty = 0 then tt-meas.measure-qnty = tt-meas.brutto-qnty .
          if tt-meas.measure-cli-qnty = 0 then tt-meas.measure-cli-qnty = tt-meas.brutto-cli-qnty .
          twice-place-data = "Резервуар " + (if available place then place.loc1 else tt-meas.loc1) + chr(10) +
                             "Объем СУГ:       " + string(tt-meas.measure-qnty) + chr(10) +
                             "Общий объем:     " + string(tt-meas.brutto-qnty) + chr(10) +
                             "Масса СУГ:       " + string(tt-meas.measure-cli-qnty) + chr(10) +
                             "Общая масса:     " + string(tt-meas.brutto-cli-qnty) + chr(10) +
                             "Плотность:       " + string(tt-meas.density, ">>>9.9<<<") + chr(10) +
                             "Температура:     " + (if tt-meas.temperature = ? then "?" else string(tt-meas.temperature)) + chr(10) +
                             "Общий уровень:   " + string(tt-meas.level-total) + chr(10) +
                             "Уровень СУГ:     " + string(tt-meas.level-petrol) + chr(10) +
                             "Уровень воды:    " + string(tt-meas.level-water) + chr(10) +
                             "Вода:            " + (if tt-meas.water-qnty = ? then "?" else string(tt-meas.water-qnty)) + chr(10) +
                             "Плотность ПФ:    " + string(tt-meas.vapor-density, ">>>9.9<<<") + chr(10) +
                             "Давление:        " + string(tt-meas.vapor-pressure, ">>>9.9<<<")
                             .
          find first rvs-line-attr exclusive-lock
                where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "twice-place-data" no-error.
          if available rvs-line-attr then do :
            rvs-line-attr.attr-value = twice-place-data .
          end.
          else do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code = "twice-place-data"
              rvs-line-attr.attr-value = twice-place-data
            .
          end.
        end.
        if num-entries(pl-twice-code) > 1
        then do :
          twice-num = 1 .
          do ii = 1 to num-entries(pl-twice-code) :
            find first buf_tt-meas
              where buf_tt-meas.obj-type = p-obj-type
              and buf_tt-meas.obj-code = p-obj-code
              and buf_tt-meas.loc1  = entry(ii, pl-twice-code)
              no-error.
            if available buf_tt-meas
            then do :
              twice-num = twice-num + 1 .
              if is-sug(bf_rvs-line.gds-code)
              then do :
                assign
                 sug-density = sug-density + buf_tt-meas.density
                   vapor-density = vapor-density + buf_tt-meas.vapor-density
                   vapor-pressure = vapor-pressure + buf_tt-meas.vapor-pressure
                   state-vapor-density = state-vapor-density + buf_tt-meas.vapor-density
                 state-vapor-pressure = state-vapor-pressure + buf_tt-meas.vapor-pressure
                   sug-water-qnty = sug-water-qnty + buf_tt-meas.water-qnty
                  .
                if buf_tt-meas.measure-qnty = 0 then buf_tt-meas.measure-qnty = buf_tt-meas.brutto-qnty .
                if buf_tt-meas.measure-cli-qnty = 0 then buf_tt-meas.measure-cli-qnty = buf_tt-meas.brutto-cli-qnty .
                twice-place-data = "Резервуар " + buf_tt-meas.loc1 + chr(10) +
                                   "Объем СУГ:       " + string(buf_tt-meas.measure-qnty) + chr(10) +
                                   "Общий объем:     " + string(buf_tt-meas.brutto-qnty) + chr(10) +
                                   "Масса СУГ:       " + string(buf_tt-meas.measure-cli-qnty) + chr(10) +
                                   "Общая масса:     " + string(buf_tt-meas.brutto-cli-qnty) + chr(10) +
                                   "Плотность:       " + string(buf_tt-meas.density, ">>>9.9<<<") + chr(10) +
                                   "Температура:     " + (if buf_tt-meas.temperature = ? then "?" else string(buf_tt-meas.temperature)) + chr(10) +
                                   "Общий уровень:   " + string(buf_tt-meas.level-total) + chr(10) +
                                   "Уровень СУГ:     " + string(buf_tt-meas.level-petrol) + chr(10) +
                                   "Уровень воды:    " + string(buf_tt-meas.level-water) + chr(10) +
                                   "Вода:            " + (if tt-meas.water-qnty = ? then "?" else string(tt-meas.water-qnty)) + chr(10) +
                                   "Плотность ПФ:    " + string(buf_tt-meas.vapor-density, ">>>9.9<<<") + chr(10) +
                                   "Давление:        " + string(buf_tt-meas.vapor-pressure , ">>>9.9<<<")
                                   .
                find first rvs-line-attr exclusive-lock
                      where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                        and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                        and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                        and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                        and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                        and rvs-line-attr.attr-code = "twice-place-data" no-error.
                if available rvs-line-attr then do :
                  rvs-line-attr.attr-value = rvs-line-attr.attr-value + chr(10) + chr(10) + twice-place-data .
                end.
                else do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                    rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                    rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                    rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                    rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                    rvs-line-attr.attr-code = "twice-place-data"
                    rvs-line-attr.attr-value = twice-place-data
                  .
                end.
              end.
                  if not is-sug(bf_rvs-line.gds-code)
                  then do :
                  if place-asi-sertif then
                  do:
                  assign
                      bf_rvs-line.measure-qnty           = bf_rvs-line.measure-qnty + buf_tt-meas.measure-qnty
                      bf_rvs-line.brutto-qnty            = bf_rvs-line.brutto-qnty + buf_tt-meas.brutto-qnty
                      bf_rvs-line.measure-cli-qnty       = bf_rvs-line.measure-cli-qnty + (if buf_tt-meas.measure-cli-qnty <> 0 then buf_tt-meas.measure-cli-qnty else buf_tt-meas.measure-qnty * buf_tt-meas.density)
                      bf_rvs-line.brutto-cli-qnty        = bf_rvs-line.brutto-cli-qnty  + (if buf_tt-meas.brutto-cli-qnty <> 0 then buf_tt-meas.brutto-cli-qnty else buf_tt-meas.brutto-qnty * buf_tt-meas.density)
                      bf_rvs-line.temperature            = (bf_rvs-line.temperature + buf_tt-meas.temperature)
                      bf_rvs-line.level-total            = (bf_rvs-line.level-total + buf_tt-meas.level-total)
                      bf_rvs-line.level-petrol           = (bf_rvs-line.level-petrol + buf_tt-meas.level-petrol)
                      bf_rvs-line.level-water            = (bf_rvs-line.level-water + buf_tt-meas.level-water)
                      bf_rvs-line.temp-layer1            = (bf_rvs-line.temp-layer1 + buf_tt-meas.temp-layer1)
                      bf_rvs-line.temp-layer2            = (bf_rvs-line.temp-layer2  + buf_tt-meas.temp-layer2)
                      bf_rvs-line.temp-layer3            = (bf_rvs-line.temp-layer3 +  buf_tt-meas.temp-layer3)
                      bf_rvs-line.measure-tc-qnty        = bf_rvs-line.measure-tc-qnty  + buf_tt-meas.measure-tc-qnty
                      bf_rvs-line.brutto-tc-qnty         = bf_rvs-line.brutto-tc-qnty +  buf_tt-meas.brutto-tc-qnty
                  .
                end.
                else do :
                  assign
                      bf_rvs-line.measure-cli-qnty       = (bf_rvs-line.measure-qnty * bf_rvs-line.density) + (buf_tt-meas.measure-qnty * buf_tt-meas.density)
                      bf_rvs-line.brutto-cli-qnty        = (bf_rvs-line.brutto-qnty * bf_rvs-line.density)  + (buf_tt-meas.brutto-qnty * buf_tt-meas.density)
                      bf_rvs-line.measure-qnty           = bf_rvs-line.measure-qnty + buf_tt-meas.measure-qnty
                      bf_rvs-line.brutto-qnty            = bf_rvs-line.brutto-qnty + buf_tt-meas.brutto-qnty
                      bf_rvs-line.temperature            = (bf_rvs-line.temperature + buf_tt-meas.temperature)
                      bf_rvs-line.level-total            = (bf_rvs-line.level-total + buf_tt-meas.level-total)
                      bf_rvs-line.level-petrol           = (bf_rvs-line.level-petrol + buf_tt-meas.level-petrol)
                      bf_rvs-line.level-water            = (bf_rvs-line.level-water + buf_tt-meas.level-water)
                      bf_rvs-line.temp-layer1            = (bf_rvs-line.temp-layer1 + buf_tt-meas.temp-layer1)
                      bf_rvs-line.temp-layer2            = (bf_rvs-line.temp-layer2  + buf_tt-meas.temp-layer2)
                      bf_rvs-line.temp-layer3            = (bf_rvs-line.temp-layer3 +  buf_tt-meas.temp-layer3)
                      bf_rvs-line.measure-tc-qnty        = bf_rvs-line.measure-tc-qnty  + buf_tt-meas.measure-tc-qnty
                      bf_rvs-line.brutto-tc-qnty         = bf_rvs-line.brutto-tc-qnty +  buf_tt-meas.brutto-tc-qnty
                    .
                end.
              end.
              else do :
                assign
                  bf_rvs-line.measure-qnty           = bf_rvs-line.measure-qnty + buf_tt-meas.brutto-qnty
                  bf_rvs-line.brutto-qnty            = bf_rvs-line.brutto-qnty + buf_tt-meas.brutto-qnty
                  bf_rvs-line.measure-cli-qnty       = bf_rvs-line.measure-cli-qnty + buf_tt-meas.brutto-cli-qnty
                  bf_rvs-line.brutto-cli-qnty        = bf_rvs-line.brutto-cli-qnty  + buf_tt-meas.brutto-cli-qnty
                  bf_rvs-line.temperature            = (bf_rvs-line.temperature + buf_tt-meas.temperature)
                  bf_rvs-line.level-total            = (bf_rvs-line.level-total + buf_tt-meas.level-total)
                  bf_rvs-line.level-petrol           = (bf_rvs-line.level-petrol + buf_tt-meas.level-petrol)
                  bf_rvs-line.level-water            = (bf_rvs-line.level-water + buf_tt-meas.level-water)
                  bf_rvs-line.temp-layer1            = (bf_rvs-line.temp-layer1 + buf_tt-meas.temp-layer1)
                  bf_rvs-line.temp-layer2            = (bf_rvs-line.temp-layer2  + buf_tt-meas.temp-layer2)
                  bf_rvs-line.temp-layer3            = (bf_rvs-line.temp-layer3 +  buf_tt-meas.temp-layer3)
                  bf_rvs-line.measure-tc-qnty        = bf_rvs-line.measure-tc-qnty  + buf_tt-meas.measure-tc-qnty
                  bf_rvs-line.brutto-tc-qnty         = bf_rvs-line.brutto-tc-qnty +  buf_tt-meas.brutto-tc-qnty
                .
              end.
            end.
          end.
          assign
           sug-density = sug-density / twice-num
           vapor-density = vapor-density / twice-num
           vapor-pressure = vapor-pressure / twice-num
           state-vapor-density = state-vapor-density / twice-num
           state-vapor-pressure = state-vapor-pressure / twice-num
          .
          assign
            bf_rvs-line.temperature            = bf_rvs-line.temperature / twice-num
            bf_rvs-line.temp-layer1            = bf_rvs-line.temp-layer1 / twice-num
            bf_rvs-line.temp-layer2            = bf_rvs-line.temp-layer2 / twice-num
            bf_rvs-line.temp-layer3            = bf_rvs-line.temp-layer3 / twice-num
            bf_rvs-line.density                = bf_rvs-line.brutto-cli-qnty / bf_rvs-line.brutto-qnty
            bf_rvs-line.state-temperature      = bf_rvs-line.temperature
            bf_rvs-line.state-measure-qnty     = bf_rvs-line.measure-qnty
            bf_rvs-line.state-brutto-qnty      = bf_rvs-line.brutto-qnty
            bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.measure-cli-qnty
            bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.brutto-cli-qnty
            bf_rvs-line.state-density          = bf_rvs-line.density
            bf_rvs-line.state-level-total      = bf_rvs-line.level-total
            bf_rvs-line.state-level-petrol     = bf_rvs-line.level-petrol
            bf_rvs-line.state-level-water      = bf_rvs-line.level-water
            bf_rvs-line.state-temp-layer1      = bf_rvs-line.temp-layer1
            bf_rvs-line.state-temp-layer2      = bf_rvs-line.temp-layer2
            bf_rvs-line.state-temp-layer3      = bf_rvs-line.temp-layer3
            bf_rvs-line.state-measure-tc-qnty  = bf_rvs-line.measure-tc-qnty
            bf_rvs-line.state-brutto-tc-qnty   = bf_rvs-line.brutto-tc-qnty
          .
          if is-sug(bf_rvs-line.gds-code)
          then do :
            assign
              bf_rvs-line.density       = sug-density
              bf_rvs-line.state-density = bf_rvs-line.density
            .
          end.
        end.
        else do :
          find first buf_tt-meas
              where buf_tt-meas.obj-type = p-obj-type
              and buf_tt-meas.obj-code = p-obj-code
              and buf_tt-meas.loc1  = pl-twice-code
              no-error.
          if available buf_tt-meas then
          do:
            if is-sug(bf_rvs-line.gds-code)
            then do :
              assign
               sug-density = sug-density + buf_tt-meas.density
               vapor-density = vapor-density + buf_tt-meas.vapor-density
               vapor-pressure = vapor-pressure + buf_tt-meas.vapor-pressure
               state-vapor-density = state-vapor-density + buf_tt-meas.vapor-density
               state-vapor-pressure = state-vapor-pressure + buf_tt-meas.vapor-pressure
               sug-water-qnty = sug-water-qnty + buf_tt-meas.water-qnty
              .
              if buf_tt-meas.measure-qnty = 0 then buf_tt-meas.measure-qnty = buf_tt-meas.brutto-qnty .
              if buf_tt-meas.measure-cli-qnty = 0 then buf_tt-meas.measure-cli-qnty = buf_tt-meas.brutto-cli-qnty .
              twice-place-data = "Резервуар " + buf_tt-meas.loc1 + chr(10) +
                                 "Объем СУГ:       " + string(buf_tt-meas.measure-qnty) + chr(10) +
                                 "Общий объем:     " + string(buf_tt-meas.brutto-qnty) + chr(10) +
                                 "Масса СУГ:       " + string(buf_tt-meas.measure-cli-qnty) + chr(10) +
                                 "Общая масса:     " + string(buf_tt-meas.brutto-cli-qnty) + chr(10) +
                                 "Плотность:       " + string(buf_tt-meas.density, ">>>9.9<<<") + chr(10) +
                                 "Температура:     " + (if buf_tt-meas.temperature = ? then "?" else string(buf_tt-meas.temperature)) + chr(10) +
                                 "Общий уровень:   " + string(buf_tt-meas.level-total) + chr(10) +
                                 "Уровень СУГ:     " + string(buf_tt-meas.level-petrol) + chr(10) +
                                 "Уровень воды:    " + string(buf_tt-meas.level-water) + chr(10) +
                                 "Вода:            " + (if tt-meas.water-qnty = ? then "?" else string(tt-meas.water-qnty)) + chr(10) +
                                 "Плотность ПФ:    " + string(buf_tt-meas.vapor-density, ">>>9.9<<<") + chr(10) +
                                 "Давление:        " + string(buf_tt-meas.vapor-pressure , ">>>9.9<<<")
                                 .
              find first rvs-line-attr exclusive-lock
                    where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                      and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                      and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                      and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                      and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                      and rvs-line-attr.attr-code = "twice-place-data" no-error.
              if available rvs-line-attr then do :
                rvs-line-attr.attr-value = rvs-line-attr.attr-value + chr(10) + chr(10) + twice-place-data .
              end.
              else do :
                create rvs-line-attr.
                assign
                  rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                  rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                  rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                  rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                  rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                  rvs-line-attr.attr-code = "twice-place-data"
                  rvs-line-attr.attr-value = twice-place-data
                .
              end.
              assign
               sug-density = sug-density / 2
               vapor-density = vapor-density / 2
               vapor-pressure = vapor-pressure / 2
               state-vapor-density = state-vapor-density / 2
               state-vapor-pressure = state-vapor-pressure / 2
              .
            end.
            if not is-sug(bf_rvs-line.gds-code)
            then do :
                  if place-asi-sertif then
                  do:
                    assign
                      bf_rvs-line.measure-qnty           = bf_rvs-line.measure-qnty + buf_tt-meas.measure-qnty
                      bf_rvs-line.density                = (((bf_rvs-line.brutto-qnty * bf_rvs-line.density) * bf_rvs-line.density) + ((buf_tt-meas.brutto-qnty * buf_tt-meas.density) * buf_tt-meas.density)) / ((bf_rvs-line.brutto-qnty * bf_rvs-line.density) + (buf_tt-meas.brutto-qnty * buf_tt-meas.density))
                      bf_rvs-line.brutto-qnty            = bf_rvs-line.brutto-qnty + buf_tt-meas.brutto-qnty
                      bf_rvs-line.measure-cli-qnty       = bf_rvs-line.measure-cli-qnty + (if buf_tt-meas.measure-cli-qnty <> 0 then buf_tt-meas.measure-cli-qnty else buf_tt-meas.measure-qnty * buf_tt-meas.density)
                      bf_rvs-line.brutto-cli-qnty        = bf_rvs-line.brutto-cli-qnty  + (if buf_tt-meas.brutto-cli-qnty <> 0 then buf_tt-meas.brutto-cli-qnty else buf_tt-meas.brutto-qnty * buf_tt-meas.density)
                      bf_rvs-line.temperature            = (bf_rvs-line.temperature + buf_tt-meas.temperature) / 2
                      bf_rvs-line.state-temperature      = bf_rvs-line.temperature
                      bf_rvs-line.level-total            = (bf_rvs-line.level-total + buf_tt-meas.level-total)
                      bf_rvs-line.level-petrol           = (bf_rvs-line.level-petrol + buf_tt-meas.level-petrol)
                      bf_rvs-line.level-water            = (bf_rvs-line.level-water + buf_tt-meas.level-water)
                      bf_rvs-line.temp-layer1            = (bf_rvs-line.temp-layer1 + buf_tt-meas.temp-layer1) / 2
                      bf_rvs-line.temp-layer2            = (bf_rvs-line.temp-layer2  + buf_tt-meas.temp-layer2) / 2
                      bf_rvs-line.temp-layer3            = (bf_rvs-line.temp-layer3 +  buf_tt-meas.temp-layer3) / 2
                      bf_rvs-line.measure-tc-qnty        = bf_rvs-line.measure-tc-qnty  + buf_tt-meas.measure-tc-qnty
                      bf_rvs-line.brutto-tc-qnty         = bf_rvs-line.brutto-tc-qnty +  buf_tt-meas.brutto-tc-qnty
                      bf_rvs-line.state-measure-qnty     = bf_rvs-line.measure-qnty
                      bf_rvs-line.state-brutto-qnty      = bf_rvs-line.brutto-qnty
                      bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.measure-cli-qnty
                      bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.brutto-cli-qnty
                      bf_rvs-line.state-density          = bf_rvs-line.density
                      bf_rvs-line.state-level-total      = bf_rvs-line.level-total
                      bf_rvs-line.state-level-petrol     = bf_rvs-line.level-petrol
                      bf_rvs-line.state-level-water      = bf_rvs-line.level-water
                      bf_rvs-line.state-temp-layer1      = bf_rvs-line.temp-layer1
                      bf_rvs-line.state-temp-layer2      = bf_rvs-line.temp-layer2
                      bf_rvs-line.state-temp-layer3      = bf_rvs-line.temp-layer3
                      bf_rvs-line.state-measure-tc-qnty  = bf_rvs-line.measure-tc-qnty
                      bf_rvs-line.state-brutto-tc-qnty   = bf_rvs-line.brutto-tc-qnty
                      .
                  end.
                  else
                  do:
                      assign
                      bf_rvs-line.measure-cli-qnty       = (bf_rvs-line.measure-qnty * bf_rvs-line.density) + (buf_tt-meas.measure-qnty * buf_tt-meas.density)
                      bf_rvs-line.brutto-cli-qnty        = (bf_rvs-line.brutto-qnty * bf_rvs-line.density)  + (buf_tt-meas.brutto-qnty * buf_tt-meas.density)
                      bf_rvs-line.measure-qnty           = bf_rvs-line.measure-qnty + buf_tt-meas.measure-qnty
                      bf_rvs-line.density                = (((bf_rvs-line.brutto-qnty * bf_rvs-line.density) * bf_rvs-line.density) + ((buf_tt-meas.brutto-qnty * buf_tt-meas.density) * buf_tt-meas.density)) / ((bf_rvs-line.brutto-qnty * bf_rvs-line.density) + (buf_tt-meas.brutto-qnty * buf_tt-meas.density))
                      bf_rvs-line.brutto-qnty            = bf_rvs-line.brutto-qnty + buf_tt-meas.brutto-qnty
                      bf_rvs-line.temperature            = (bf_rvs-line.temperature + buf_tt-meas.temperature) / 2
                      bf_rvs-line.state-temperature      = bf_rvs-line.temperature
                      bf_rvs-line.level-total            = (bf_rvs-line.level-total + buf_tt-meas.level-total)
                      bf_rvs-line.level-petrol           = (bf_rvs-line.level-petrol + buf_tt-meas.level-petrol)
                      bf_rvs-line.level-water            = (bf_rvs-line.level-water + buf_tt-meas.level-water)
                      bf_rvs-line.temp-layer1            = (bf_rvs-line.temp-layer1 + buf_tt-meas.temp-layer1) / 2
                      bf_rvs-line.temp-layer2            = (bf_rvs-line.temp-layer2  + buf_tt-meas.temp-layer2) / 2
                      bf_rvs-line.temp-layer3            = (bf_rvs-line.temp-layer3 +  buf_tt-meas.temp-layer3) / 2
                      bf_rvs-line.measure-tc-qnty        = bf_rvs-line.measure-tc-qnty  + buf_tt-meas.measure-tc-qnty
                      bf_rvs-line.brutto-tc-qnty         = bf_rvs-line.brutto-tc-qnty +  buf_tt-meas.brutto-tc-qnty
                      bf_rvs-line.state-measure-qnty     = bf_rvs-line.measure-qnty
                      bf_rvs-line.state-brutto-qnty      = bf_rvs-line.brutto-qnty
                      bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.measure-cli-qnty
                      bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.brutto-cli-qnty
                      bf_rvs-line.state-density          = bf_rvs-line.density
                      bf_rvs-line.state-level-total      = bf_rvs-line.level-total
                      bf_rvs-line.state-level-petrol     = bf_rvs-line.level-petrol
                      bf_rvs-line.state-level-water      = bf_rvs-line.level-water
                      bf_rvs-line.state-temp-layer1      = bf_rvs-line.temp-layer1
                      bf_rvs-line.state-temp-layer2      = bf_rvs-line.temp-layer2
                      bf_rvs-line.state-temp-layer3      = bf_rvs-line.temp-layer3
                      bf_rvs-line.state-measure-tc-qnty  = bf_rvs-line.measure-tc-qnty
                      bf_rvs-line.state-brutto-tc-qnty   = bf_rvs-line.brutto-tc-qnty
                      .
                  end.
                end .
                  else do :
                    assign
                  bf_rvs-line.measure-qnty           = bf_rvs-line.measure-qnty + buf_tt-meas.brutto-qnty
                  bf_rvs-line.brutto-qnty            = bf_rvs-line.brutto-qnty + buf_tt-meas.brutto-qnty
                  bf_rvs-line.measure-cli-qnty       = bf_rvs-line.measure-cli-qnty + buf_tt-meas.brutto-cli-qnty
                  bf_rvs-line.brutto-cli-qnty        = bf_rvs-line.brutto-cli-qnty  + buf_tt-meas.brutto-cli-qnty
                  bf_rvs-line.density                = sug-density
                  bf_rvs-line.temperature            = (bf_rvs-line.temperature + buf_tt-meas.temperature) / 2
                  bf_rvs-line.state-temperature      = bf_rvs-line.temperature
                  bf_rvs-line.level-total            = (bf_rvs-line.level-total + buf_tt-meas.level-total)
                  bf_rvs-line.level-petrol           = (bf_rvs-line.level-petrol + buf_tt-meas.level-petrol)
                  bf_rvs-line.level-water            = (bf_rvs-line.level-water + buf_tt-meas.level-water)
                  bf_rvs-line.temp-layer1            = (bf_rvs-line.temp-layer1 + buf_tt-meas.temp-layer1) / 2
                  bf_rvs-line.temp-layer2            = (bf_rvs-line.temp-layer2  + buf_tt-meas.temp-layer2) / 2
                  bf_rvs-line.temp-layer3            = (bf_rvs-line.temp-layer3 +  buf_tt-meas.temp-layer3) / 2
                  bf_rvs-line.measure-tc-qnty        = bf_rvs-line.measure-tc-qnty  + buf_tt-meas.measure-tc-qnty
                  bf_rvs-line.brutto-tc-qnty         = bf_rvs-line.brutto-tc-qnty +  buf_tt-meas.brutto-tc-qnty
                  bf_rvs-line.state-measure-qnty     = bf_rvs-line.measure-qnty
                  bf_rvs-line.state-brutto-qnty      = bf_rvs-line.brutto-qnty
                  bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.measure-cli-qnty
                  bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.brutto-cli-qnty
                  bf_rvs-line.state-density          = bf_rvs-line.density
                  bf_rvs-line.state-level-total      = bf_rvs-line.level-total
                  bf_rvs-line.state-level-petrol     = bf_rvs-line.level-petrol
                  bf_rvs-line.state-level-water      = bf_rvs-line.level-water
                  bf_rvs-line.state-temp-layer1      = bf_rvs-line.temp-layer1
                  bf_rvs-line.state-temp-layer2      = bf_rvs-line.temp-layer2
                  bf_rvs-line.state-temp-layer3      = bf_rvs-line.temp-layer3
                  bf_rvs-line.state-measure-tc-qnty  = bf_rvs-line.measure-tc-qnty
                  bf_rvs-line.state-brutto-tc-qnty   = bf_rvs-line.brutto-tc-qnty
              .
              assign
                bf_rvs-line.density       = sug-density
                bf_rvs-line.state-density = bf_rvs-line.density
              .
              find first place no-lock where place.obj-type = p-obj-type
                                         and place.obj-code = p-obj-code
                                         and place.pl-code  = p-pl-code
                                         .
            end.
          end.
        end.
    end.
    define variable v-lvl-qnty as decimal no-undo.
    v-delta-mas-qnty = 0.
    v-lvl-qnty = 0 .
    find first rvs-line-attr exclusive-lock
        where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
        and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
        and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
        and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
        and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
        and rvs-line-attr.attr-code = "delta-mass-qnty" no-error.
    if not available rvs-line-attr then
    do :
        create rvs-line-attr.
        assign
            rvs-line-attr.obj-code   = bf_rvs-line.obj-code
            rvs-line-attr.obj-type   = bf_rvs-line.obj-type
            rvs-line-attr.gds-code   = bf_rvs-line.gds-code
            rvs-line-attr.pl-code    = bf_rvs-line.pl-code
            rvs-line-attr.rvs-code   = bf_rvs-line.rvs-code
            rvs-line-attr.attr-code  = "delta-mass-qnty"
        .
    end.
    if bf_rvs-line.state-measure-cli-qnty > 200000 then rvs-line-attr.attr-value = "0.5" . else rvs-line-attr.attr-value = "0.65".
    IF ( bf_rvs-line.state-density <= 0 or bf_rvs-line.state-density > 1 or bf_rvs-line.state-density = ? )
    or ( bf_rvs-line.state-temperature = ? )
    or ( is-sug(bf_rvs-line.gds-code) and (vapor-density = ? or vapor-density = 0 or vapor-density > 1 ) )
    THEN DO:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input p-obj-type
  , input p-obj-code
  ) .
        IF ptrlprop-olddens = true
        THEN
        DO:
            p-prev-rvs-date = NO.
            FIND FIRST rvs-doc WHERE rvs-doc.rvs-code = bf_rvs-line.rvs-code NO-LOCK NO-ERROR.
            prev: FOR EACH crl_prev_rvs-doc NO-LOCK
                WHERE crl_prev_rvs-doc.obj-type   = p-obj-type
                AND crl_prev_rvs-doc.obj-code   = p-obj-code
                AND crl_prev_rvs-doc.shift-date = rvs-doc.shift-date
                AND crl_prev_rvs-doc.shift-num  = rvs-doc.shift-num
                AND crl_prev_rvs-doc.status_    = 'факт':U
                AND crl_prev_rvs-doc.rvs-type  <> 'проверка':U
                BY crl_prev_rvs-doc.fact-order DESC
                ON ERROR UNDO, RETURN ERROR RETURN-VALUE
                :
                FIND LAST prev_rvs-line NO-LOCK
                    WHERE prev_rvs-line.rvs-code = crl_prev_rvs-doc.rvs-code
                    AND prev_rvs-line.obj-type = p-obj-type
                    AND prev_rvs-line.obj-code = p-obj-code
                    AND prev_rvs-line.pl-code  =  bf_rvs-line.pl-code
                    AND prev_rvs-line.gds-code = bf_rvs-line.gds-code
                    NO-ERROR .
                IF AVAILABLE prev_rvs-line THEN
                DO:
                    v-prev-temp = no .
                    if bf_rvs-line.state-density > 1 or bf_rvs-line.state-density = ? or bf_rvs-line.state-density = 0 then
                    do:
                        if bf_rvs-line.state-temperature <> ?
                        then do :
                          find first rvs-line-attr exclusive-lock
                             where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                               and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                               and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                               and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                               and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                               and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
                          if not available rvs-line-attr then do :
                            create rvs-line-attr.
                            assign
                              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                              rvs-line-attr.attr-code = "temp-izm-vol"
                            .
                          end.
                          rvs-line-attr.attr-value = string(bf_rvs-line.state-temperature) .
                        end .
                        find first prev_rvs-line-attr no-lock
                             where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                               and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                               and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                               and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                               and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                               and prev_rvs-line-attr.attr-code = "mi-dnst" no-error.
                        if available prev_rvs-line-attr
                        then do :
                          find first rvs-line-attr exclusive-lock
                             where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                               and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                               and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                               and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                               and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                               and rvs-line-attr.attr-code = "mi-dnst" no-error.
                          if not available rvs-line-attr then do :
                            create rvs-line-attr.
                            assign
                              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                              rvs-line-attr.attr-code = "mi-dnst"
                            .
                          end.
                          rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                          for first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = integer(prev_rvs-line-attr.attr-value)
                                                               and buf_sr-izmerenia.sr-type-izm = 1
                                                               :
                            bf_rvs-line.state-temperature = prev_rvs-line.state-temperature.
                            bf_rvs-line.temperature  = prev_rvs-line.temperature.
                            v-prev-temp = yes .
                          end .
                        end .
                        bf_rvs-line.state-density = prev_rvs-line.state-density .
                        bf_rvs-line.density = prev_rvs-line.density .
                        p-prev-rvs-date = YES.
                        find first prev_rvs-line-attr no-lock
                             where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                               and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                               and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                               and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                               and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                               and prev_rvs-line-attr.attr-code = "izmer-density" no-error.
                        if available prev_rvs-line-attr
                        then do :
                          find first rvs-line-attr exclusive-lock
                             where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                               and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                               and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                               and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                               and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                               and rvs-line-attr.attr-code = "izmer-density" no-error.
                          if not available rvs-line-attr then do :
                            create rvs-line-attr.
                            assign
                              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                              rvs-line-attr.attr-code = "izmer-density"
                            .
                          end.
                          rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                        end .
                        find first rvs-line-attr exclusive-lock
                             where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                               and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                               and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                               and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                               and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                               and rvs-line-attr.attr-code = "is-olddens" no-error.
                        if not available rvs-line-attr then do :
                          create rvs-line-attr.
                          assign
                            rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                            rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                            rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                            rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                            rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                            rvs-line-attr.attr-code = "is-olddens"
                          .
                        end.
                        rvs-line-attr.attr-value = 'yes' .
                        v-is-olddens = yes .
                    end.
                    if tt-meas.temperature = ?
                    or v-prev-temp
                    then do:
                        if not v-prev-temp
                        then do :
                          bf_rvs-line.state-temperature = prev_rvs-line.state-temperature.
                          bf_rvs-line.temperature  = prev_rvs-line.temperature.
                          p-prev-rvs-date = YES.
                        end .
                        if tt-meas.temperature = ?
                        then do :
                          find first prev_rvs-line-attr no-lock
                               where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                 and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                 and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                 and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                 and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                 and prev_rvs-line-attr.attr-code = "temp-izm-vol" no-error.
                          if available prev_rvs-line-attr
                          then do :
                            find first rvs-line-attr exclusive-lock
                               where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                 and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                 and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                 and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                 and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                 and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
                            if not available rvs-line-attr then do :
                              create rvs-line-attr.
                              assign
                                rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                rvs-line-attr.attr-code = "temp-izm-vol"
                              .
                            end.
                            rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                          end .
                          find first prev_rvs-line-attr no-lock
                               where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                 and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                 and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                 and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                 and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                 and prev_rvs-line-attr.attr-code = "mi-tmp" no-error.
                          if available prev_rvs-line-attr
                          then do :
                            find first rvs-line-attr exclusive-lock
                               where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                 and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                 and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                 and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                 and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                 and rvs-line-attr.attr-code = "mi-tmp" no-error.
                            if not available rvs-line-attr then do :
                              create rvs-line-attr.
                              assign
                                rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                rvs-line-attr.attr-code = "mi-tmp"
                              .
                            end.
                            rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                          end .
                        end .
                    end.
                    if bf_rvs-line.temperature = ? then
                    do:
                        bf_rvs-line.temperature  = prev_rvs-line.temperature.
                    end.
                    if bf_rvs-line.temperature = ? then
                    do:
                        bf_rvs-line.temperature  = bf_rvs-line.state-temperature.
                    end.
                    if vapor-density = ? or vapor-density = 0 or vapor-density > 1
                    then do :
                      find first prev_rvs-line-attr no-lock
                           where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                             and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                             and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                             and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                             and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                             and prev_rvs-line-attr.attr-code = "state-dens-pf-sug" no-error .
                      if available prev_rvs-line-attr
                      then do :
                        state-vapor-density = decimal(prev_rvs-line-attr.attr-value) no-error .
                        find first rvs-line-attr exclusive-lock
                           where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                             and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                             and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                             and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                             and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                             and rvs-line-attr.attr-code = "state-dens-pf-sug" no-error.
                        if not available rvs-line-attr then do :
                          create rvs-line-attr.
                          assign
                            rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                            rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                            rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                            rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                            rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                            rvs-line-attr.attr-code = "state-dens-pf-sug"
                          .
                        end.
                        rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                      end .
                      find first prev_rvs-line-attr no-lock
                           where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                             and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                             and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                             and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                             and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                             and prev_rvs-line-attr.attr-code = "dens-pf-sug" no-error.
                      if available prev_rvs-line-attr
                      then do :
                        vapor-density = decimal(prev_rvs-line-attr.attr-value) no-error .
                        find first rvs-line-attr exclusive-lock
                           where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                             and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                             and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                             and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                             and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                             and rvs-line-attr.attr-code = "dens-pf-sug" no-error.
                        if not available rvs-line-attr then do :
                          create rvs-line-attr.
                          assign
                            rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                            rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                            rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                            rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                            rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                            rvs-line-attr.attr-code = "dens-pf-sug"
                          .
                        end.
                        rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                      end .
                    end .
                    LEAVE prev .
                END.
            END.
            IF   p-prev-rvs-date = NO THEN
            DO :
                FIND FIRST crl_prev_rvs-doc NO-LOCK WHERE
                    crl_prev_rvs-doc.rvs-code = p-prev-code NO-ERROR .
                IF AVAILABLE crl_prev_rvs-doc THEN
                DO:
                    FIND FIRST prev_rvs-line NO-LOCK WHERE
                        prev_rvs-line.rvs-code = crl_prev_rvs-doc.rvs-code AND
                        prev_rvs-line.obj-type = bf_rvs-line.obj-type      AND
                        prev_rvs-line.obj-code = bf_rvs-line.obj-code      AND
                        prev_rvs-line.pl-code  = bf_rvs-line.pl-code       AND
                        prev_rvs-line.gds-code = bf_rvs-line.gds-code      NO-ERROR .
                    IF AVAILABLE prev_rvs-line THEN
                    DO:
                        v-prev-temp = no .
                        if bf_rvs-line.state-density > 1 or bf_rvs-line.state-density = ? or bf_rvs-line.state-density = 0 then
                        do:
                            if bf_rvs-line.state-temperature <> ?
                            then do :
                              find first rvs-line-attr exclusive-lock
                                 where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                   and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                   and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                   and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                   and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                   and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
                              if not available rvs-line-attr then do :
                                create rvs-line-attr.
                                assign
                                  rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                  rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                  rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                  rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                  rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                  rvs-line-attr.attr-code = "temp-izm-vol"
                                .
                              end.
                              rvs-line-attr.attr-value = string(bf_rvs-line.state-temperature) .
                            end .
                            find first prev_rvs-line-attr no-lock
                                 where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                   and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                   and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                   and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                   and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                   and prev_rvs-line-attr.attr-code = "mi-dnst" no-error.
                            if available prev_rvs-line-attr
                            then do :
                              find first rvs-line-attr exclusive-lock
                                 where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                   and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                   and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                   and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                   and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                   and rvs-line-attr.attr-code = "mi-dnst" no-error.
                              if not available rvs-line-attr then do :
                                create rvs-line-attr.
                                assign
                                  rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                  rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                  rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                  rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                  rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                  rvs-line-attr.attr-code = "mi-dnst"
                                .
                              end.
                              rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                              for first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = integer(prev_rvs-line-attr.attr-value)
                                                                   and buf_sr-izmerenia.sr-type-izm = 1
                                                                   :
                                bf_rvs-line.state-temperature = prev_rvs-line.state-temperature.
                                bf_rvs-line.temperature  = prev_rvs-line.temperature.
                                v-prev-temp = yes .
                              end .
                            end .
                            ASSIGN
                                bf_rvs-line.density           = prev_rvs-line.density
                                bf_rvs-line.state-density     = prev_rvs-line.state-density
                            .
                            find first prev_rvs-line-attr no-lock
                                 where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                   and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                   and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                   and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                   and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                   and prev_rvs-line-attr.attr-code = "izmer-density" no-error.
                            if available prev_rvs-line-attr
                            then do :
                              find first rvs-line-attr exclusive-lock
                                 where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                   and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                   and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                   and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                   and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                   and rvs-line-attr.attr-code = "izmer-density" no-error.
                              if not available rvs-line-attr then do :
                                create rvs-line-attr.
                                assign
                                  rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                  rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                  rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                  rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                  rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                  rvs-line-attr.attr-code = "izmer-density"
                                .
                              end.
                              rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                            end .
                            find first rvs-line-attr exclusive-lock
                                 where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                   and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                   and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                   and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                   and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                   and rvs-line-attr.attr-code = "is-olddens" no-error.
                            if not available rvs-line-attr then do :
                              create rvs-line-attr.
                              assign
                                rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                rvs-line-attr.attr-code = "is-olddens"
                              .
                            end.
                            rvs-line-attr.attr-value = 'yes' .
                            v-is-olddens = yes .
                        END.
                        if tt-meas.temperature = ?
                        or v-prev-temp
                        then do:
                            if not v-prev-temp
                            then do :
                              bf_rvs-line.temperature            = prev_rvs-line.temperature.
                              bf_rvs-line.state-temperature      = prev_rvs-line.state-temperature.
                            end .
                            if tt-meas.temperature = ?
                            then do :
                              find first prev_rvs-line-attr no-lock
                                   where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                     and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                     and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                     and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                     and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                     and prev_rvs-line-attr.attr-code = "temp-izm-vol" no-error.
                              if available prev_rvs-line-attr
                              then do :
                                find first rvs-line-attr exclusive-lock
                                   where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                     and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                     and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                     and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                     and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                     and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
                                if not available rvs-line-attr then do :
                                  create rvs-line-attr.
                                  assign
                                    rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                    rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                    rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                    rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                    rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                    rvs-line-attr.attr-code = "temp-izm-vol"
                                  .
                                end.
                                rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                              end .
                              find first prev_rvs-line-attr no-lock
                                   where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                     and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                     and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                     and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                     and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                     and prev_rvs-line-attr.attr-code = "mi-tmp" no-error.
                              if available prev_rvs-line-attr
                              then do :
                                find first rvs-line-attr exclusive-lock
                                   where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                     and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                     and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                     and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                     and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                     and rvs-line-attr.attr-code = "mi-tmp" no-error.
                                if not available rvs-line-attr then do :
                                  create rvs-line-attr.
                                  assign
                                    rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                    rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                    rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                    rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                    rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                    rvs-line-attr.attr-code = "mi-tmp"
                                  .
                                end.
                                rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                              end .
                            end .
                        END.
                        if vapor-density = ? or vapor-density = 0 or vapor-density > 1
                        then do :
                          find first prev_rvs-line-attr no-lock
                               where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                 and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                 and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                 and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                 and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                 and prev_rvs-line-attr.attr-code = "state-dens-pf-sug" no-error .
                          if available prev_rvs-line-attr
                          then do :
                            state-vapor-density = decimal(prev_rvs-line-attr.attr-value) no-error .
                            find first rvs-line-attr exclusive-lock
                               where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                 and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                 and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                 and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                 and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                 and rvs-line-attr.attr-code = "state-dens-pf-sug" no-error.
                            if not available rvs-line-attr then do :
                              create rvs-line-attr.
                              assign
                                rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                rvs-line-attr.attr-code = "state-dens-pf-sug"
                              .
                            end.
                            rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                          end .
                          find first prev_rvs-line-attr no-lock
                               where prev_rvs-line-attr.obj-code  = prev_rvs-line.obj-code
                                 and prev_rvs-line-attr.obj-type  = prev_rvs-line.obj-type
                                 and prev_rvs-line-attr.gds-code  = prev_rvs-line.gds-code
                                 and prev_rvs-line-attr.pl-code   = prev_rvs-line.pl-code
                                 and prev_rvs-line-attr.rvs-code  = prev_rvs-line.rvs-code
                                 and prev_rvs-line-attr.attr-code = "dens-pf-sug" no-error.
                          if available prev_rvs-line-attr
                          then do :
                            vapor-density = decimal(prev_rvs-line-attr.attr-value) no-error .
                            find first rvs-line-attr exclusive-lock
                               where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                 and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                 and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                 and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                 and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                 and rvs-line-attr.attr-code = "dens-pf-sug" no-error.
                            if not available rvs-line-attr then do :
                              create rvs-line-attr.
                              assign
                                rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                                rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                                rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                                rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                                rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                                rvs-line-attr.attr-code = "dens-pf-sug"
                              .
                            end.
                            rvs-line-attr.attr-value = prev_rvs-line-attr.attr-value .
                          end .
                        end .
                        if not is-sug(bf_rvs-line.gds-code)
                        then do :
                          ASSIGN
                            bf_rvs-line.measure-cli-qnty       = bf_rvs-line.measure-qnty       * bf_rvs-line.density
                            bf_rvs-line.brutto-cli-qnty        = bf_rvs-line.brutto-qnty        * bf_rvs-line.density
                            bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.state-measure-qnty * bf_rvs-line.density
                            bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.state-brutto-qnty  * bf_rvs-line.density
                          .
                        end .
                    END.
                END.
            END.
            if not is-sug(bf_rvs-line.gds-code)
            then do :
              if bf_rvs-line.measure-qnty = 0 or bf_rvs-line.measure-qnty = ? then bf_rvs-line.measure-qnty = bf_rvs-line.measure-cli-qnty / bf_rvs-line.density .
              if bf_rvs-line.measure-qnty = 0 or bf_rvs-line.measure-qnty = ? then bf_rvs-line.measure-qnty = tt-meas.brutto-qnty .
              if bf_rvs-line.measure-qnty > tt-meas.brutto-qnty then bf_rvs-line.measure-qnty = tt-meas.brutto-qnty .
            end .
        END.
    END.
    if is-sug(bf_rvs-line.gds-code)
    then do :
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              and rvs-line-attr.attr-code = "sug-water-qnty" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(sug-water-qnty) .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = bf_rvs-line.obj-code
          rvs-line-attr.obj-type  = bf_rvs-line.obj-type
          rvs-line-attr.gds-code  = bf_rvs-line.gds-code
          rvs-line-attr.pl-code   = bf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "sug-water-qnty"
          rvs-line-attr.attr-value = string(sug-water-qnty)
        .
      end.
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              and rvs-line-attr.attr-code = "dens-pf-sug" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(vapor-density) .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = bf_rvs-line.obj-code
          rvs-line-attr.obj-type  = bf_rvs-line.obj-type
          rvs-line-attr.gds-code  = bf_rvs-line.gds-code
          rvs-line-attr.pl-code   = bf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "dens-pf-sug"
          rvs-line-attr.attr-value = string(vapor-density)
        .
      end.
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              and rvs-line-attr.attr-code = "state-dens-pf-sug" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(state-vapor-density) .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = bf_rvs-line.obj-code
          rvs-line-attr.obj-type  = bf_rvs-line.obj-type
          rvs-line-attr.gds-code  = bf_rvs-line.gds-code
          rvs-line-attr.pl-code   = bf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "state-dens-pf-sug"
          rvs-line-attr.attr-value = string(state-vapor-density)
        .
      end.
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              and rvs-line-attr.attr-code = "pressure-sug" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(vapor-pressure ) .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = bf_rvs-line.obj-code
          rvs-line-attr.obj-type  = bf_rvs-line.obj-type
          rvs-line-attr.gds-code  = bf_rvs-line.gds-code
          rvs-line-attr.pl-code   = bf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "pressure-sug"
          rvs-line-attr.attr-value = string(vapor-pressure )
        .
      end.
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              and rvs-line-attr.attr-code = "state-pressure-sug" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(state-vapor-pressure) .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = bf_rvs-line.obj-code
          rvs-line-attr.obj-type  = bf_rvs-line.obj-type
          rvs-line-attr.gds-code  = bf_rvs-line.gds-code
          rvs-line-attr.pl-code   = bf_rvs-line.pl-code
          rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
          rvs-line-attr.attr-code = "state-pressure-sug"
          rvs-line-attr.attr-value = string(state-vapor-pressure)
        .
      end.
      find last full_pl-level no-lock
          where full_pl-level.pl-code  = bf_rvs-line.pl-code
            and full_pl-level.obj-code = bf_rvs-line.obj-code
            and full_pl-level.obj-type = bf_rvs-line.obj-type
            no-error .
      if available full_pl-level
      and full_pl-level.pl-qnty >= bf_rvs-line.measure-qnty
      then do :
        if bf_rvs-line.measure-qnty > 0
        then do :
          sug-pf-volume = full_pl-level.pl-qnty - bf_rvs-line.measure-qnty .
        end .
        else do :
          sug-volume = (bf_rvs-line.measure-cli-qnty - (full_pl-level.pl-qnty * vapor-density)) / (bf_rvs-line.density - vapor-density) .
          bf_rvs-line.measure-qnty = sug-volume .
          bf_rvs-line.state-measure-qnty = sug-volume .
          sug-pf-volume = (bf_rvs-line.measure-cli-qnty - (full_pl-level.pl-qnty * bf_rvs-line.density)) / (bf_rvs-line.density - vapor-density) .
        end .
        find first rvs-line-attr exclusive-lock
              where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                and rvs-line-attr.attr-code = "vol-pf-sug" no-error.
        if available rvs-line-attr then do :
          rvs-line-attr.attr-value = string(sug-pf-volume) .
        end.
        else do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            rvs-line-attr.attr-code = "vol-pf-sug"
            rvs-line-attr.attr-value = string(sug-pf-volume)
          .
        end.
        find first rvs-line-attr exclusive-lock
              where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                and rvs-line-attr.attr-code = "state-vol-pf-sug" no-error.
        if available rvs-line-attr then do :
          rvs-line-attr.attr-value = string(sug-pf-volume) .
        end.
        else do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            rvs-line-attr.attr-code = "state-vol-pf-sug"
            rvs-line-attr.attr-value = string(sug-pf-volume)
          .
        end.
      end .
    end.
FIND FIRST tt-meas-file WHERE tt-meas-file.pl-code =  tt-meas.pl-code NO-LOCK NO-ERROR.
IF available tt-meas-file
THEN DO:
  RUN gbl/conf-rd.p ("rdc-dnst", "", "", 0, "", "", "", NO, OUTPUT rdc-dnstvalue, OUTPUT rdc-dnsttype) NO-ERROR.
  IF rdc-dnstvalue = "pomi-rn"
  and bf_rvs-line.state-level-total > 0
  then do :
    _trpomi :
    do on error undo, return error :
      do ii = 1 to num-entries('place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u,','):
        v-code = entry(ii,'place-type,place-SI,place-diameter,dead-balance,water-level,dens-prov,place-virtual,place-twice-code,place-sert-urov,place-local,place-error-mass,place-asi-sertif,place-rvd-dnsty,place-rvd-lvl,place-rvd-tmp,place-SI-dens,place-SI-level,place-SI-temp,place-passp-num,place-passp-type,place-dead-high,place-temp-coef,disable-water-alarm,disable-level-alarm,place-ponton,place-ponton-mass,place-ponton-height,place-com-vessel,place-com-tanks,place-is-main,place-gate-valve,place-gate-valve-tanks,place-auto-gate-valve':u) .
        run placelib_get-attr  ( input v-code
                                ,input p-obj-code
                                ,input p-obj-type
                                ,input p-pl-code
                                ,output v-value
                                ,output v-ok      ) no-error.
        case v-code :
          when "place-type" then do :
            if v-ok then place-type = integer(v-value) .
          end.
          when "place-SI" then do :
            if v-ok then place-si = integer(v-value) .
          end.
          when "place-diameter" then do :
            if v-ok then place-diameter = decimal(v-value) .
          end.
          when "dens-prov" then do :
            if v-ok then dens-prov = decimal(v-value) .
          end.
          when "place-dead-high" then do :
            if v-ok then DeadZone_Reservoir = decimal(v-value) .
          end.
          when "place-rvd-dnsty" then do :
            if v-ok then pl-rvd-dens = logical(v-value) .
          end.
          when "place-rvd-lvl" then do :
            if v-ok then pl-rvd-lvl = logical(v-value) .
          end.
          when "place-rvd-tmp" then do :
            if v-ok then pl-rvd-temp = logical(v-value) .
          end.
          when "place-SI-temp" then do :
            if v-ok then pl-temp-sr-izm = integer(v-value) .
          end.
          when "place-SI-dens" then do :
            if v-ok then pl-dens-sr-izm = integer(v-value) .
          end.
          when "place-SI-level" then do :
            if v-ok then pl-level-sr-izm = integer(v-value) .
          end.
          when "place-ponton" then do :
            if v-ok then place-ponton = logical(v-value) .
          end.
          when "place-ponton-mass" then do :
            if v-ok then place-ponton-mass = decimal(v-value) .
          end.
          when "place-ponton-height" then do :
            if v-ok then place-ponton-height = decimal(v-value) .
          end.
        end case.
      end.
      if bf_rvs-line.state-temperature = ?
      then do :
        find first bf_goods no-lock where bf_goods.gds-code = bf_rvs-line.gds-code no-error .
        find first bf_place no-lock where bf_place.pl-code = bf_rvs-line.pl-code no-error .
        undo _trpomi, return error substitute( 'Для резервуара &1 (&2 &3) не определено значение температуры для передачи в библиотеку ПОкМИ. Создание сверки не возможно.'
                                             ,(if available bf_place then bf_place.loc1 else "?")
                                             ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                                             ,(if available bf_goods then bf_goods.gds-name else "?") ) .
      end .
      if is-sug(bf_rvs-line.gds-code)
      then do :
        find last sug1_pl-level no-lock
            where sug1_pl-level.pl-code  = bf_rvs-line.pl-code
              and sug1_pl-level.obj-code = bf_rvs-line.obj-code
              and sug1_pl-level.obj-type = bf_rvs-line.obj-type
              and sug1_pl-level.pl-level <= bf_rvs-line.state-level-total
              no-error .
        if not available sug1_pl-level
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_rvs-line.gds-code no-error .
          find first bf_place no-lock where bf_place.pl-code = bf_rvs-line.pl-code no-error .
          undo _trpomi, return error substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Создание сверки не возможно.'
                                               ,(if available bf_place then bf_place.loc1 else "?")
                                               ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                                               ,(if available bf_goods then bf_goods.gds-name else "?") ) .
        end .
        DeltaOtn_K = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = sug1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = sug1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = sug1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "tarir-delta"
                                              :
          DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) .
        end .
        if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .
        DeltaV1 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = sug1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = sug1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = sug1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :
          DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
        end .
        find first sug2_pl-level no-lock
            where sug2_pl-level.pl-code  = bf_rvs-line.pl-code
              and sug2_pl-level.obj-code = bf_rvs-line.obj-code
              and sug2_pl-level.obj-type = bf_rvs-line.obj-type
              and sug2_pl-level.pl-level > bf_rvs-line.state-level-total
              no-error .
        if not available sug2_pl-level
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_rvs-line.gds-code no-error .
          find first bf_place no-lock where bf_place.pl-code = bf_rvs-line.pl-code no-error .
          undo _trpomi, return error substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Создание сверки не возможно.'
                                               ,(if available bf_place then bf_place.loc1 else "?")
                                               ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                                               ,(if available bf_goods then bf_goods.gds-name else "?") ) .
        end .
        DeltaV2 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = sug2_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = sug2_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = sug2_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = sug2_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :
          DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
        end .
        find last full_pl-level no-lock
            where full_pl-level.pl-code  = bf_rvs-line.pl-code
              and full_pl-level.obj-code = bf_rvs-line.obj-code
              and full_pl-level.obj-type = bf_rvs-line.obj-type
              no-error .
        if not available full_pl-level
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_rvs-line.gds-code no-error .
          find first bf_place no-lock where bf_place.pl-code = bf_rvs-line.pl-code no-error .
          undo _trpomi, return error substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Создание сверки не возможно.'
                                               ,(if available bf_place then bf_place.loc1 else "?")
                                               ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                                               ,(if available bf_goods then bf_goods.gds-name else "?") ) .
        end .
        DeltaOtn_K_Full = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = full_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = full_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = full_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = full_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "tarir-delta"
                                              :
          DeltaOtn_K_Full = decimal(buf_pl-level-attr.attr-value) .
        end .
        if DeltaOtn_K_Full = ?
        or DeltaOtn_K_Full = 0
        then do :
          for each full2_pl-level no-lock
             where full2_pl-level.pl-code  = bf_rvs-line.pl-code
               and full2_pl-level.obj-code = bf_rvs-line.obj-code
               and full2_pl-level.obj-type = bf_rvs-line.obj-type
               by full2_pl-level.pl-level desc
          :
            for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = full2_pl-level.pl-code
                                                  and buf_pl-level-attr.obj-code = full2_pl-level.obj-code
                                                  and buf_pl-level-attr.obj-type = full2_pl-level.obj-type
                                                  and buf_pl-level-attr.pl-level = full2_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "tarir-delta"
                                                  :
              DeltaOtn_K_Full = decimal(buf_pl-level-attr.attr-value) .
            end .
            if DeltaOtn_K_Full > 0 then leave .
          end .
        end .
        if DeltaOtn_K_Full = ?
        or DeltaOtn_K_Full = 0
        then do :
          if place-type = 1
          then DeltaOtn_K_Full = 0.2 .
          else DeltaOtn_K_Full = 0.25 .
        end .
        DeltaVSugFull = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = full_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = full_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = full_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = full_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :
          DeltaVSugFull = decimal(buf_pl-level-attr.attr-value) no-error .
        end .
        CalibTable = Substitute("&1=&2", sug1_pl-level.pl-level, (sug1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + chr(10) .
        CalibTable = CalibTable + Substitute("&1=&2", sug2_pl-level.pl-level, (sug2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") + chr(10) .
        CalibTable = CalibTable + Substitute("&1=&2", full_pl-level.pl-level, (full_pl-level.pl-qnty / 1000)) + (if DeltaVSugFull > 0 then ("=" + trim(string(DeltaVSugFull, ">>9.9999"))) else "") .
      end .
      else do :
        if bf_rvs-line.state-level-water > 0
        then do :
          find last water1_pl-level no-lock where water1_pl-level.pl-code  = bf_rvs-line.pl-code
                                              and water1_pl-level.obj-code = bf_rvs-line.obj-code
                                              and water1_pl-level.obj-type = bf_rvs-line.obj-type
                                              and water1_pl-level.pl-level <= bf_rvs-line.state-level-water
                                              no-error .
          if available water1_pl-level
          then do :
            WaterDeltaV1 = ? .
            for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                                  and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                                  and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                                  and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "deltaV"
                                                  :
              WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
            end .
          end .
          if available water1_pl-level
          and water1_pl-level.pl-level <> bf_rvs-line.state-level-water
          then do :
            find first water2_pl-level no-lock where water2_pl-level.pl-code  = bf_rvs-line.pl-code
                                                and water2_pl-level.obj-code = bf_rvs-line.obj-code
                                                and water2_pl-level.obj-type = bf_rvs-line.obj-type
                                                and water2_pl-level.pl-level >= bf_rvs-line.state-level-water
                                                no-error .
            if available water2_pl-level
            then do :
              WaterDeltaV2 = ? .
              for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                    and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                    and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                    and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                    and buf_pl-level-attr.attr-code = "deltaV"
                                                    :
                WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
              end .
            end .
          end .
        end .
        find last total1_pl-level no-lock where total1_pl-level.pl-code  = bf_rvs-line.pl-code
                                            and total1_pl-level.obj-code = bf_rvs-line.obj-code
                                            and total1_pl-level.obj-type = bf_rvs-line.obj-type
                                            and total1_pl-level.pl-level <= bf_rvs-line.state-level-total
                                            no-error .
        if not available total1_pl-level
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_rvs-line.gds-code no-error .
          find first bf_place no-lock where bf_place.pl-code = bf_rvs-line.pl-code no-error .
          undo _trpomi, return error substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Создание сверки не возможно.'
                                               ,(if available bf_place then bf_place.loc1 else "?")
                                               ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                                               ,(if available bf_goods then bf_goods.gds-name else "?") ) .
        end .
        DeltaOtn_K = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "tarir-delta"
                                              :
          DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) .
        end .
        if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .
        DeltaV1 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :
          DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error .
        end .
        find first total2_pl-level no-lock where total2_pl-level.pl-code  = bf_rvs-line.pl-code
                                            and total2_pl-level.obj-code = bf_rvs-line.obj-code
                                            and total2_pl-level.obj-type = bf_rvs-line.obj-type
                                            and total2_pl-level.pl-level > bf_rvs-line.state-level-total
                                            no-error .
        if not available total2_pl-level
        then do :
          find first bf_goods no-lock where bf_goods.gds-code = bf_rvs-line.gds-code no-error .
          find first bf_place no-lock where bf_place.pl-code = bf_rvs-line.pl-code no-error .
          undo _trpomi, return error substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Создание сверки не возможно.'
                                               ,(if available bf_place then bf_place.loc1 else "?")
                                               ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                                               ,(if available bf_goods then bf_goods.gds-name else "?") ) .
        end .
        DeltaV2 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :
          DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error .
        end .
        if available water1_pl-level
        then do :
          CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + chr(10) .
        end .
        if available water2_pl-level
        then do :
          CalibTable = CalibTable + Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + chr(10) .
        end .
        CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + chr(10) .
        CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") .
        CalibBelt = getCalibrationBelt(
            bf_rvs-line.obj-type,
            bf_rvs-line.obj-code,
            bf_rvs-line.pl-code,
            bf_rvs-line.state-level-total,
            if bf_rvs-line.state-level-water <> ? then bf_rvs-line.state-level-water else 0
        ).
      end .
      define buffer dens_sr-izmerenia for sr-izmerenia .
      define buffer temp_sr-izmerenia for sr-izmerenia .
      define buffer level_sr-izmerenia for sr-izmerenia .
      find first bf_place no-lock where bf_place.pl-code = p-pl-code no-error .
      find first sr-izmerenia no-lock where sr-izmerenia.node-code = place-si no-error.
      if error-status :error or not available sr-izmerenia then do :
        find first bf_goods no-lock where bf_goods.gds-code = bf_rvs-line.gds-code no-error .
        undo _trpomi, return error substitute( 'Для резервуара &1 (&2) не указано основное средство измерения. Создание сверки не возможно.'
                                             ,(if available bf_place then bf_place.loc1 else "?")
                                             ,(if available bf_goods then bf_goods.gds-name else "?") ) .
      end.
      else do :
        assign
          ToolType               = sr-izmerenia.sr-type-id
          LevelToolType          = sr-izmerenia.sr-type-level-measuring
          A_LevelMeasurementTool = sr-izmerenia.sr-temp-line
          ToolAutomationLevel_H  = vAutomationDegree[sr-izmerenia.sr-type-izm + 1]
          ToolAutomationLevel_H_Water = vAutomationDegree[sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_H             = sr-izmerenia.sr-abs-err-neft-water
          DeltaAbs_H_Water       = sr-izmerenia.sr-abs-err-water
          ToolAutomationLevel_R  = vAutomationDegree[sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_R             = sr-izmerenia.sr-abs-err-dens
          ToolAutomationLevel_Tv = vAutomationDegree[sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_Tv            = sr-izmerenia.sr-abs-err-temp-vol
          ToolAutomationLevel_Tr = vAutomationDegree[sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_Tr            = sr-izmerenia.sr-abs-err-temp-dens
          DeltaOtn_N             = 0.05
          DeltaOtn_H             = sr-izmerenia.sr-relative-err-neft-water
          DeltaOtn_H_Water       = sr-izmerenia.sr-relative-err-water
          DeltaOtn_R             = sr-izmerenia.sr-relative-err-dens
          DeltaAbs_R_liquid         = sr-izmerenia.sr-abs-err-dens-lgas-liquid
          DeltaAbs_R_Gas   = sr-izmerenia.sr-abs-err-dens-lgas-vapor
          DeltaAbs_H_CalcType    = sr-izmerenia.sr-type-level-measuring + 1
          DeltaAbs_H_Water_CalcType = sr-izmerenia.sr-type-level-measuring + 1
          Use_DeltaOtn_R_liquid_IN  = sr-izmerenia.sr-relative-err-dens-lgas-liquid <> ?
          DeltaOtn_R_liquid_IN      = sr-izmerenia.sr-relative-err-dens-lgas-liquid
        .
      end.
      if is-sug(bf_rvs-line.gds-code)
      then do :
        find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            and rvs-line-attr.attr-code = "delta-mass-qnty" no-error.
        if available rvs-line-attr then
        do :
          if sr-izmerenia.sr-otnos > 0.65 then rvs-line-attr.attr-value = "0.65". else rvs-line-attr.attr-value = string(sr-izmerenia.sr-otnos)  .
        end.
        else
        do :
          create rvs-line-attr.
          assign
              rvs-line-attr.obj-code   = bf_rvs-line.obj-code
              rvs-line-attr.obj-type   = bf_rvs-line.obj-type
              rvs-line-attr.gds-code   = bf_rvs-line.gds-code
              rvs-line-attr.pl-code    = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code   = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code  = "delta-mass-qnty"
          .
          if sr-izmerenia.sr-otnos > 0.65 then rvs-line-attr.attr-value = "0.65". else rvs-line-attr.attr-value = string(sr-izmerenia.sr-otnos)  .
        end.
      end .
      if v-is-olddens
      then do :
        find first rvs-line-attr no-lock
              where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                and rvs-line-attr.attr-code = "mi-dnst" no-error.
        if available rvs-line-attr
        then do :
          pl-dens-sr-izm = integer(rvs-line-attr.attr-value) .
        end .
        else do :
          pl-dens-sr-izm = 0 .
        end .
        if pl-dens-sr-izm > 0
        and pl-dens-sr-izm <> place-si
        then do :
          find first dens_sr-izmerenia no-lock where dens_sr-izmerenia.node-code = pl-dens-sr-izm no-error.
          if not available dens_sr-izmerenia then do :
            undo _trpomi, return error substitute( 'Не найдено средство измерения с кодом &1', pl-dens-sr-izm )  .
          end.
          else do :
            assign
              ToolType               = dens_sr-izmerenia.sr-type-id
              DeltaAbs_R             = dens_sr-izmerenia.sr-abs-err-dens
              DeltaOtn_R             = dens_sr-izmerenia.sr-relative-err-dens
              ToolAutomationLevel_R  = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
            .
          end.
        end .
        find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            and rvs-line-attr.attr-code = "mi-tmp" no-error.
        if available rvs-line-attr
        then do :
          pl-temp-sr-izm = integer(rvs-line-attr.attr-value) .
        end .
        else do :
          pl-temp-sr-izm = 0 .
        end .
        if pl-temp-sr-izm > 0
        and pl-temp-sr-izm <> place-si
        then do :
          find first temp_sr-izmerenia no-lock where temp_sr-izmerenia.node-code = pl-temp-sr-izm no-error.
          if not available temp_sr-izmerenia then do :
            undo _trpomi, return error substitute( 'Не найдено средство измерения с кодом &1', pl-temp-sr-izm ) .
          end.
          else do :
            assign
              DeltaAbs_Tv            = temp_sr-izmerenia.sr-abs-err-temp-vol
              DeltaAbs_Tr            = temp_sr-izmerenia.sr-abs-err-temp-dens
              ToolAutomationLevel_Tv = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
              ToolAutomationLevel_Tr = vAutomationDegree[temp_sr-izmerenia.sr-type-izm + 1]
            .
          end.
        end .
      end .
      if available dens_sr-izmerenia
      and dens_sr-izmerenia.sr-type-izm = 3
      and dens_sr-izmerenia.sr-temperature
      then do :
        DeltaAbs_Tr = dens_sr-izmerenia.sr-abs-err-temp-dens .
        ToolAutomationLevel_Tr = vAutomationDegree[dens_sr-izmerenia.sr-type-izm + 1].
      end .
      if DeltaAbs_H       = ? then DeltaAbs_H = 0 .
      if DeltaAbs_H_Water = ? then DeltaAbs_H_Water = 0 .
      if DeltaAbs_R       = ? then DeltaAbs_R = 0 .
      if DeltaAbs_Tv      = ? then DeltaAbs_Tv = 0 .
      if DeltaAbs_Tr      = ? then DeltaAbs_Tr = 0 .
      if DeltaOtn_N       = ? then DeltaOtn_N = 0 .
      if DeltaOtn_H       = ? then DeltaOtn_H = 0 .
      if DeltaOtn_H_Water = ? then DeltaOtn_H_Water = 0 .
      if DeltaOtn_R       = ? then DeltaOtn_R = 0 .
      if DeltaAbs_R_liquid   = ? then DeltaAbs_R_liquid = 0 .
      if DeltaAbs_R_Gas = ? then DeltaAbs_R_Gas = 0 .
      if LevelToolType    = ? then LevelToolType = 0 .
      if ToolType         = ? then ToolType = 0 .
      if A_LevelMeasurementTool      = ? then A_LevelMeasurementTool = 0 .
      if ToolAutomationLevel_Tr      = ? then ToolAutomationLevel_Tr =0.
      if ToolAutomationLevel_H       = ? then ToolAutomationLevel_H = 0.
      if ToolAutomationLevel_H_Water = ? then ToolAutomationLevel_H_Water = 0.
      if ToolAutomationLevel_Tv      = ? then ToolAutomationLevel_Tv = 0.
      if ToolAutomationLevel_R       = ? then ToolAutomationLevel_R = 0.
      if DeltaAbs_H_CalcType         = ? then DeltaAbs_H_CalcType = 0.
      if DeltaAbs_H_Water_CalcType   = ? then DeltaAbs_H_Water_CalcType = 0.
      if Use_DeltaOtn_R_liquid_IN = ? then Use_DeltaOtn_R_liquid_IN = false.
      if DeltaOtn_R_liquid_IN     = ? then DeltaOtn_R_liquid_IN = 0.
      if bf_rvs-line.level-water = 0
      then do :
        ToolAutomationLevel_H_Water = 3 .
        DeltaAbs_H_Water_CalcType = 1 .
        DeltaAbs_H_Water = 0 .
        DeltaOtn_H_Water = 0 .
      end .
      if LevelToolType > 0
      and not is-sug(bf_rvs-line.gds-code)
      then do :
        MM57
          (input bf_rvs-line.state-level-total * 10,
           input LevelToolType,
           output DeltaAbs_H,
           output vErr,
           output vWrn,
           output vDllVersion)
        .
        OUTPUT stream outstream to value ("pomi.log") append.
        PUT STREAM outstream unformatted
                    "    " SKIP
                    "    " SKIP
                    cur-time-string()           FORMAT "x(16)"    SKIP
                    'Процедура             "CMethodOfMetering57"'       SKIP
                    'Версия dll: '            vDllVersion   skip
                    'CODE_PL                = ' bf_rvs-line.pl-code                           SKIP
                    'H                      = ' bf_rvs-line.state-level-total * 10                  SKIP
                    'ToolType               = ' LevelToolType                                      SKIP
                        SKIP SKIP
        .
        output stream outstream close.
        if trim(vErr) > "" then do :
          output stream outstream to value ("pomi.log")  append.
          put stream outstream vErr format "X(1024)" skip.
          output stream outstream close.
          message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
          undo _trpomi, return error substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) .
        end.
        else do :
          OUTPUT stream outstream to value ("pomi.log")  append.
          PUT STREAM outstream unformatted
              "DeltaAbs_H = " DeltaAbs_H  SKIP
          .
          OUTPUT stream outstream close.
        end .
      end .
      find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
      if available rvs-line-attr then do :
        temp-izm-vol = decimal(rvs-line-attr.attr-value) .
      end.
      else do :
        temp-izm-vol = ? .
      end.
      if bf_rvs-line.state-density > 0
      and not v-is-olddens
      then do :
        find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              and rvs-line-attr.attr-code = "izmer-density" no-error.
        if available rvs-line-attr
        then do :
          rvs-line-attr.attr-value = string(bf_rvs-line.state-density) .
        end .
      end .
      find first rvs-line-attr no-lock
          where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            and rvs-line-attr.attr-code = "izmer-density" no-error.
      if available rvs-line-attr then do :
        izmer-density = decimal(rvs-line-attr.attr-value) .
      end.
      else do :
        izmer-density = ? .
      end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input bf_rvs-line.obj-type
  , input bf_rvs-line.obj-code
  ) .
      if not error-status :error then do:
        if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                      else temp-for-pomi = 20 .
      end.
      if is-sug(bf_rvs-line.gds-code)
      then do :
        v-proc = "CMethodOfMetering53" .
        MM53
          (input bf_rvs-line.level-total * 10,
           input CalibTable,
           input bf_rvs-line.state-temperature,
           input round(bf_rvs-line.state-density * 1000,1),
           input round(if state-vapor-density <> ? then (state-vapor-density * 1000) else (vapor-density * 1000),1),
           input A_Reservoir,
           input DeltaOtn_K,
           input DeltaOtn_K_Full,
           input DeltaAbs_H,
           input DeltaAbs_R_liquid,
           input DeltaAbs_R_gas,
           input (if Use_DeltaOtn_R_liquid_IN then -1 else 0),
           input DeltaOtn_R_liquid_IN,
           input DeltaOtn_N,
           input 1,
           input 2,
           input 2,
           output C_HN,
           output C_HN_delta,
           output C_full,
           output V_liquid,
           output V_gas,
           output M_liquid,
           output M_gas,
           output M,
           output Kf,
           output DeltaOtn_H,
           output DeltaOtn_R_liquid,
           output DeltaOtn_R_gas,
           output DeltaOtn_M_liquid,
           output DeltaOtn_M_gas,
           output DeltaOtn_M,
           output H_min_liquid,
           output H_min,
           output A,
           output B,
           output vErr,
           output vWrn,
           output vDllVersion)
        no-error .
      end .
      else do :
        if place-type = 1 then do :
          v-proc = "CMethodOfMetering13" .
          MM13
            (input 0.0,
             input 0.0,
             input 0.0,
             input 0.0,
             input bf_rvs-line.state-level-total * 10,
             input (if bf_rvs-line.state-level-water <> ? then bf_rvs-line.state-level-water * 10 else 0.0),
             input CalibTable,
             input CalibBelt,
             input 0.0,
             input 0.0,
             input (if temp-izm-vol <> ? then temp-izm-vol else bf_rvs-line.state-temperature),
             input bf_rvs-line.state-temperature,
             input (if izmer-density <> ? then izmer-density * 1000 else bf_rvs-line.state-density * 1000 ),
             input temp-for-pomi,
             input ToolType,
             input DeltaOtn_K,
             input DeadZone_Reservoir,
             input A_Reservoir,
             input A_LevelMeasurementTool,
             input ToolAutomationLevel_H,
             input ToolAutomationLevel_H_Water,
             input ToolAutomationLevel_R,
             input ToolAutomationLevel_Tv,
             input ToolAutomationLevel_Tr,
             input DeltaAbs_H_CalcType,
             input DeltaAbs_H_Water_CalcType,
             input DeltaAbs_H,
             input DeltaAbs_H_Water,
             input DeltaAbs_R,
             input DeltaAbs_Tv,
             input DeltaAbs_Tr,
             input DeltaOtn_N,
             input 1,
             input 2,
             input 2,
             output V_total,
             output V_water,
             output DeltaV,
             output V_product,
             output Vcy,
             output Rcy,
             output V,
             output CTL_base_alt,
             output CPL_base_alt,
             output CTPL_base_alt,
             output Fp_base_alt,
             output CTL_obs_base,
             output CPL_obs_base,
             output CTPL_obs_base,
             output Fp_obs_base,
             output Rv,
             output DeltaOtn_Vcy,
             output DeltaOtn_Vm,
             output M,
             output DeltaOtn_M,
             output VolumetricExpansion,
             output vErr,
             output vWrn,
             output vDllVersion)
          no-error .
        end.
        else do :
          v-proc = "CMethodOfMetering6" .
          MM6
            (input bf_rvs-line.state-level-total * 10,
             input (if bf_rvs-line.state-level-water <> ? then bf_rvs-line.state-level-water * 10 else 0.0),
             input CalibTable,
             input CalibBelt,
             input 0.0,
             input (if temp-izm-vol <> ? then temp-izm-vol else bf_rvs-line.state-temperature),
             input bf_rvs-line.state-temperature,
             input (if izmer-density <> ? then izmer-density * 1000 else bf_rvs-line.state-density * 1000 ),
             input temp-for-pomi,
             input ToolType,
             input DeltaOtn_K,
             input DeadZone_Reservoir,
             input A_Reservoir,
             input A_LevelMeasurementTool,
             input ToolAutomationLevel_H,
             input ToolAutomationLevel_H_Water,
             input ToolAutomationLevel_R,
             input ToolAutomationLevel_Tv,
             input ToolAutomationLevel_Tr,
             input DeltaAbs_H_CalcType,
             input DeltaAbs_H_Water_CalcType,
             input DeltaAbs_H,
             input DeltaAbs_H_Water,
             input DeltaAbs_R,
             input DeltaAbs_Tv,
             input DeltaAbs_Tr,
             input DeltaOtn_N,
             input 1,
             input 2,
             input 2,
             output V_total,
             output V_water,
             output DeltaV,
             output V_product,
             output Vcy,
             output Rcy,
             output V,
             output CTL_base_alt,
             output CPL_base_alt,
             output CTPL_base_alt,
             output Fp_base_alt,
             output CTL_obs_base,
             output CPL_obs_base,
             output CTPL_obs_base,
             output Fp_obs_base,
             output Rv,
             output DeltaOtn_Vcy,
             output DeltaOtn_Vm,
             output M,
             output DeltaOtn_M,
             output VolumetricExpansion,
             output vErr,
             output vWrn,
             output vDllVersion)
          no-error .
        end.
      end .
      if is-sug(bf_rvs-line.gds-code)
      then do :
        OUTPUT stream outstream to value ("pomi.log") append.
        PUT STREAM outstream  unformatted
          "    " SKIP
          "    " SKIP
          cur-time-string()           FORMAT "x(16)"    SKIP
          'Процедура   "'              v-proc       '"'           FORMAT "x(128)"        SKIP
          'Версия dll: '              vDllVersion                                SKIP
          'CODE_PL                = ' bf_rvs-line.pl-code                                SKIP
          'H                      = ' bf_rvs-line.level-total * 10            SKIP
          'CalibrationTable       = ' CalibTable                              SKIP
          'T                      = ' bf_rvs-line.state-temperature           SKIP
          'R_liquid               = ' trim(string(bf_rvs-line.state-density * 1000, ">>>9.9<"))  SKIP
          'R_gas                  = ' trim(string((if state-vapor-density <> ? then (state-vapor-density * 1000) else (vapor-density * 1000)), ">>>9.9<"))  SKIP
          'A_Reservoir            = ' A_Reservoir                                   SKIP
          'DeltaOtn_K             = ' DeltaOtn_K                                    SKIP
          'DeltaOtn_K_Full        = ' DeltaOtn_K_Full                               SKIP
          'DeltaAbs_H             = ' DeltaAbs_H                                    SKIP
          'DeltaAbs_R_liquid      = ' DeltaAbs_R_liquid                             SKIP
          'DeltaAbs_R_gas         = ' DeltaAbs_R_gas                                SKIP
          'DeltaOtn_N             = ' DeltaOtn_N                                    SKIP
          'Use_DeltaOtn_R_liquid_IN = ' Use_DeltaOtn_R_liquid_IN                    SKIP
          'DeltaOtn_R_liquid_IN     = ' DeltaOtn_R_liquid_IN                        SKIP
          'Round_M                = ' 1                                             SKIP
          'Round_T                = ' 2                                             SKIP
          'Round_R                = ' 2                                             SKIP
        .
        output stream outstream close.
        if C_HN = 0 then
        do:
          error-string = substitute("~nРезервуар: &1.~n", bf_place.loc1) + "Ошибка входного параметра CalibrationTable. Библеотека ПОкМИ вернула C_HN = 0." .
          output stream outstream to value ("pomi.log")  append.
          put stream outstream error-string skip.
          output stream outstream close.
          undo _trpomi, return error substitute('Ошибка входных параметров в библиотеку ПОкМИ.~n &1',error-string).
        end.
        if trim(vErr) > "" then do :
          error-string = substitute("~nРезервуар: &1.~n", if avail bf_place then bf_place.loc1 else "")
                       + replace(vErr,";0x","~n0x") .
          output stream outstream to value ("pomi.log")  append.
          put stream outstream error-string format "X(1024)" skip.
          output stream outstream close.
          undo _trpomi, return error substitute('Ошибка работы библиотеки ПОкМИ &1',error-string) .
        end.
        if tt-meas-file.log-brutto = no
        or pl-rvd-lvl
        or pl-rvd-dens
        or pl-rvd-temp
        then do :
          find first rvs-line-attr exclusive-lock
              where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              and rvs-line-attr.attr-code = "delta-mass-qnty" no-error.
          if available rvs-line-attr then
          do :
            if M > 200000 then rvs-line-attr.attr-value = "0.5" . else rvs-line-attr.attr-value = "0.65".
          end.
          else
          do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code   = bf_rvs-line.obj-code
              rvs-line-attr.obj-type   = bf_rvs-line.obj-type
              rvs-line-attr.gds-code   = bf_rvs-line.gds-code
              rvs-line-attr.pl-code    = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code   = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code  = "delta-mass-qnty"
            .
            if M > 200000 then rvs-line-attr.attr-value = "0.5". else rvs-line-attr.attr-value = "0.65"  .
          end.
          ASSIGN
            bf_rvs-line.state-measure-tc-qnty  = V_liquid * 1000
            bf_rvs-line.state-measure-qnty  = V_liquid * 1000
            bf_rvs-line.state-measure-cli-qnty = M
            bf_rvs-line.state-brutto-qnty = bf_rvs-line.state-measure-qnty + tt-meas-file.water-qnty
            bf_rvs-line.state-brutto-cli-qnty = bf_rvs-line.state-measure-cli-qnty + tt-meas-file.water-qnty
          .
          if bf_rvs-line.state-brutto-qnty = ? then bf_rvs-line.state-brutto-qnty = bf_rvs-line.state-measure-qnty .
          if bf_rvs-line.state-brutto-cli-qnty = ? then bf_rvs-line.state-brutto-cli-qnty = bf_rvs-line.state-measure-cli-qnty .
          find first rvs-line-attr exclusive-lock
               where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                 and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                 and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                 and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                 and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                 and rvs-line-attr.attr-code = "state-vol-pf-sug" no-error.
          if not available rvs-line-attr then do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code = "state-vol-pf-sug"
              rvs-line-attr.attr-value = string(V_Gas * 1000)
            .
          end.
          else do :
            rvs-line-attr.attr-value = string(V_Gas * 1000) .
          end.
        end .
        output stream outstream to value ("pomi.log")  append.
        put stream outstream unformatted
          "C_HN              = " C_HN    skip
          "C_HN_delta        = " C_HN_delta          skip
          "C_full            = " C_full SKIP
          "V_liquid          = " V_liquid  SKIP
          "V_gas             = " V_gas   SKIP
          "M_liquid          = " M_liquid  SKIP
          "M_gas             = " M_gas  SKIP
          "M                 = " M   SKIP
          "Kf                = " Kf  SKIP
          "DeltaOtn_H        = " DeltaOtn_H SKIP
          "DeltaOtn_R_liquid = " DeltaOtn_R_liquid  SKIP
          "DeltaOtn_R_gas    = " DeltaOtn_R_gas  SKIP
          "DeltaOtn_M_liquid = " DeltaOtn_M_liquid SKIP
          "DeltaOtn_M_gas    = " DeltaOtn_M_gas  SKIP
          "DeltaOtn_M        = " DeltaOtn_M  SKIP
          "H_min_liquid      = " H_min_liquid  SKIP
          "H_min             = " H_min  SKIP
          "A                 = " A  SKIP
          "B                 = " B  SKIP
          "Warnings          = " vWrn SKIP
        .
        output stream outstream close.
        assign
          v-POkMI-result-attr =
            "Общая масса СУГ, кг: " + string(M, "->>,>>>,>>9.9":U) + chr(10) +
            "Относительная погрешность измерения массы СУГ, %: "  + string(DeltaOtn_M, ">>>>>>>9.99") + chr(10) +
            "Объем ЖФ СУГ, л: " + string((V_liquid * 1000), "->>,>>>,>>9":U) + chr(10) +
            "Объем ПФ СУГ, л: " + string((V_gas * 1000), "->>,>>>,>>9":U) + chr(10)
        .
        find first rvs-line-attr exclusive-lock
              where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                and rvs-line-attr.attr-code = "POkMI-result" no-error.
        if available rvs-line-attr then do :
          rvs-line-attr.attr-value = v-POkMI-result-attr .
        end.
        else do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            rvs-line-attr.attr-code = "POkMI-result"
            rvs-line-attr.attr-value = v-POkMI-result-attr
          .
        end.
        find first rvs-line-attr exclusive-lock
              where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                and rvs-line-attr.attr-code = "POkMI-warnings" no-error.
        if available rvs-line-attr then do :
          rvs-line-attr.attr-value = vWrn .
        end.
        else do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = bf_rvs-line.obj-code
            rvs-line-attr.obj-type  = bf_rvs-line.obj-type
            rvs-line-attr.gds-code  = bf_rvs-line.gds-code
            rvs-line-attr.pl-code   = bf_rvs-line.pl-code
            rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
            rvs-line-attr.attr-code = "POkMI-warnings"
            rvs-line-attr.attr-value = vWrn
          .
        end.
        output stream outstream close.
      end .
      else do :
        OUTPUT stream outstream to value ("pomi.log") append.
        PUT STREAM outstream unformatted
          "    " SKIP
          "    " SKIP
          cur-time-string()           FORMAT "x(16)"    SKIP
          'Процедура   "'              v-proc       '"'           FORMAT "x(128)"   SKIP
          'Версия dll: '              vDllVersion                           SKIP
          'CODE_PL                     = ' bf_rvs-line.pl-code                      SKIP
          'H                           = ' bf_rvs-line.state-level-total * 10 SKIP
          'H_water                     = ' (if bf_rvs-line.state-level-water <> ? then bf_rvs-line.state-level-water * 10 else 0.0) SKIP
          'CalibrationTable            = ' CalibTable                    SKIP
          'CalibrationBelt             = ' CalibBelt                    SKIP
          'ToolAutomationLevel_H       = ' ToolAutomationLevel_H     SKIP
          'ToolAutomationLevel_H_Water = ' ToolAutomationLevel_H_Water    SKIP
          'ToolAutomationLevel_R       = ' ToolAutomationLevel_R     SKIP
          'ToolAutomationLevel_Tv      = ' ToolAutomationLevel_Tv    SKIP
          'ToolAutomationLevel_Tr      = ' ToolAutomationLevel_Tr    SKIP
          'DeltaAbs_H_CalcType         = ' DeltaAbs_H_CalcType       SKIP
          'DeltaAbs_H_Water_CalcType   = ' DeltaAbs_H_Water_CalcType SKIP
          'Tv                          = ' if temp-izm-vol <> ? then temp-izm-vol else bf_rvs-line.state-temperature  SKIP
          'Tr                          = ' bf_rvs-line.state-temperature SKIP
          'R                           = ' trim(string(if izmer-density <> ? then ( izmer-density * 1000 ) else ( bf_rvs-line.state-density * 1000 ), ">>>9.9<"))  SKIP
          'Tcy                         = ' temp-for-pomi                       SKIP
          'ToolType                    = ' ToolType                            SKIP
          'DeadZone_Reservoir          = ' DeadZone_Reservoir                  SKIP
          'DeltaOtn_K                  = ' DeltaOtn_K                          SKIP
          'A_Reservoir                 = ' A_Reservoir                         SKIP
          'A_LevelMeasurementTool      = ' A_LevelMeasurementTool              skip
          'DeltaAbs_H                  = ' DeltaAbs_H                          SKIP
          'DeltaAbs_H_Water            = ' DeltaAbs_H_Water                    SKIP
          'DeltaAbs_R                  = ' DeltaAbs_R                          SKIP
          'DeltaAbs_Tv                 = ' DeltaAbs_Tv                         SKIP
          'DeltaAbs_Tr                 = ' DeltaAbs_Tr                         SKIP
          'DeltaOtn_N                  = ' DeltaOtn_N                          SKIP
          'Round_M                     = ' 1                                   SKIP
          'Round_T                     = ' 2                                   SKIP
          'Round_R                     = ' 2                                   SKIP
        .
        if place-type = 1
        and place-ponton
        then do :
          put stream outstream unformatted
            "Rprov                  = " 0.0 skip
            "Mpokr                  = " 0.0 skip
            "Vdisp                  = " 0.0 skip
            "CoverFloatingHeight    = " 0.0 skip
          .
        end.
        output stream outstream close.
        if trim(vErr) > "" then do :
          error-string = substitute("~nРезервуар: &1.~n", if avail bf_place then bf_place.loc1 else "")
                       + replace(vErr,";0x","~n0x") .
          output stream outstream to value ("pomi.log")  append.
          put stream outstream error-string format "X(1024)" skip.
          output stream outstream close.
          undo _trpomi, return error substitute('Ошибка работы библиотеки ПОкМИ &1',error-string) .
        end.
        else do :
          v-mm-density = Rcy / 1000 .
          find first rvs-line-attr exclusive-lock
                where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "meas-calc-qnty" no-error.
          if available rvs-line-attr then do :
            rvs-line-attr.attr-value = string(Vcy * 1000) .
          end.
          else do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code = "meas-calc-qnty"
              rvs-line-attr.attr-value = string(Vcy * 1000)
            .
          end.
          find first rvs-line-attr exclusive-lock
                where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "meas-calc-dens" no-error.
          if available rvs-line-attr then do :
            rvs-line-attr.attr-value = string ( v-mm-density ) .
          end.
          else do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code = "meas-calc-dens"
              rvs-line-attr.attr-value = string ( v-mm-density )
            .
          end.
          if izmer-density = ?
          then do :
            find first rvs-line-attr exclusive-lock
                  where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                    and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                    and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                    and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                    and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                    and rvs-line-attr.attr-code = "izmer-density" no-error.
            if available rvs-line-attr then do :
              rvs-line-attr.attr-value = string(bf_rvs-line.density) .
            end.
            else do :
              create rvs-line-attr.
              assign
                rvs-line-attr.obj-code   = bf_rvs-line.obj-code
                rvs-line-attr.obj-type   = bf_rvs-line.obj-type
                rvs-line-attr.gds-code   = bf_rvs-line.gds-code
                rvs-line-attr.pl-code    = bf_rvs-line.pl-code
                rvs-line-attr.rvs-code   = bf_rvs-line.rvs-code
                rvs-line-attr.attr-code  = "izmer-density"
                rvs-line-attr.attr-value = string(bf_rvs-line.density)
              .
            END.
          end .
          if temp-izm-vol = ?
          then do :
            find first rvs-line-attr exclusive-lock
                  where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                    and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                    and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                    and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                    and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                    and rvs-line-attr.attr-code = "temp-izm-vol" no-error.
            if available rvs-line-attr then do :
              rvs-line-attr.attr-value = string(bf_rvs-line.temperature) .
            end.
            else do :
              create rvs-line-attr.
              assign
                rvs-line-attr.obj-code   = bf_rvs-line.obj-code
                rvs-line-attr.obj-type   = bf_rvs-line.obj-type
                rvs-line-attr.gds-code   = bf_rvs-line.gds-code
                rvs-line-attr.pl-code    = bf_rvs-line.pl-code
                rvs-line-attr.rvs-code   = bf_rvs-line.rvs-code
                rvs-line-attr.attr-code  = "temp-izm-vol"
                rvs-line-attr.attr-value = string(bf_rvs-line.temperature)
              .
            END.
          end .
          if tt-meas-file.log-brutto = no
          or pl-rvd-lvl
          or pl-rvd-dens
          or pl-rvd-temp
          then do :
            find first rvs-line-attr exclusive-lock
                where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                and rvs-line-attr.attr-code = "delta-mass-qnty" no-error.
            if available rvs-line-attr then
            do :
              if M > 200000 then rvs-line-attr.attr-value = "0.5" . else rvs-line-attr.attr-value = "0.65".
            end.
            else
            do :
              create rvs-line-attr.
              assign
                rvs-line-attr.obj-code   = bf_rvs-line.obj-code
                rvs-line-attr.obj-type   = bf_rvs-line.obj-type
                rvs-line-attr.gds-code   = bf_rvs-line.gds-code
                rvs-line-attr.pl-code    = bf_rvs-line.pl-code
                rvs-line-attr.rvs-code   = bf_rvs-line.rvs-code
                rvs-line-attr.attr-code  = "delta-mass-qnty"
              .
              if M > 200000 then rvs-line-attr.attr-value = "0.5" . else rvs-line-attr.attr-value = "0.65".
            end.
            assign
              tt-meas-file.water-qnty            = V_water * 1000
              bf_rvs-line.state-measure-qnty     = V * 1000
              bf_rvs-line.state-measure-cli-qnty = M
              bf_rvs-line.state-brutto-qnty      = bf_rvs-line.state-measure-qnty  + tt-meas-file.water-qnty
              bf_rvs-line.state-density          = Rv / 1000
              bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.state-measure-cli-qnty + tt-meas-file.water-qnty
            .
          end .
          find first rvs-line-attr exclusive-lock
                where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "pokmi-water-qnty" no-error.
          if available rvs-line-attr then do :
            rvs-line-attr.attr-value = string(V_water * 1000) .
          end.
          else do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code   = bf_rvs-line.obj-code
              rvs-line-attr.obj-type   = bf_rvs-line.obj-type
              rvs-line-attr.gds-code   = bf_rvs-line.gds-code
              rvs-line-attr.pl-code    = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code   = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code  = "pokmi-water-qnty"
              rvs-line-attr.attr-value = string(V_water * 1000)
            .
          END.
          assign
            v-POkMI-result =
              "V_total             = " + string(V_total)       + chr(10) +
              "V_water             = " + string(V_water)       + chr(10) +
              "DeltaV              = " + string(DeltaV)         + chr(10) +
              "Vcy                 = " + string(Vcy)           + chr(10) +
              "Rcy                 = " + string(Rcy)            + chr(10) +
              "V_product           = " + string(V_product)      + chr(10) +
              "V                   = " + string(V)              + chr(10) +
              "Rv                  = " + string(Rv)               + chr(10) +
              "M                   = " + string(M)                 + chr(10) +
              "CTL_base_alt        = " + string(CTL_base_alt)  + chr(10) +
              "CPL_base_alt        = " + string(CPL_base_alt)  + chr(10) +
              "CTPL_base_alt       = " + string(CTPL_base_alt)  + chr(10) +
              "Fp_base_alt         = " + string(Fp_base_alt)   + chr(10) +
              "CTL_obs_base        = " + string(CTL_obs_base)  + chr(10) +
              "CPL_obs_base        = " + string(CPL_obs_base)  + chr(10) +
              "CTPL_obs_base       = " + string(CTPL_obs_base)  + chr(10) +
              "Fp_obs_base         = " + string(Fp_obs_base)   + chr(10) +
              "DeltaOtn_Vcy        = " + string(DeltaOtn_Vcy)  + chr(10) +
              "DeltaOtn_Vm         = " + string(DeltaOtn_Vm)   + chr(10) +
              "DeltaOtn_M          = " + string(DeltaOtn_M)       + chr(10) +
              "VolumetricExpansion = " + string(VolumetricExpansion) + chr(10) +
              "Warnings            = " + vWrn
          .
          OUTPUT stream outstream to value ("pomi.log")  append.
          PUT STREAM outstream unformatted v-POkMI-result skip .
          OUTPUT stream outstream close.
          assign
            v-POkMI-result-attr =
              "Масса НП, кг: " + string(M, "->>,>>>,>>9.9":U) + chr(10) +
              "Относительная погрешность измерения массы нефтепродукта, %: "  + string(DeltaOtn_M, "->>,>>9.99":U) + chr(10) +
              "Плотность, приведенная к стандартным условиям, г/см3: " + string((Rcy / 1000), "9.9999":U) + chr(10) +
              "Объем, приведенный к стандартным условиям, л: " + string((Vcy * 1000), "->>,>>>,>>9":U) + chr(10) +
              "Объем НП при температуре его измерения, л: " + string((V * 1000), "->>,>>>,>>9":U) + chr(10) +
              "Объем воды, л: " + string((V_water * 1000), "->>,>>>,>>9":U)
            v-POkMI-warnings = vWrn
          .
          find first rvs-line-attr exclusive-lock
                where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "POkMI-result" no-error.
          if available rvs-line-attr then do :
            rvs-line-attr.attr-value = v-POkMI-result-attr .
          end.
          else do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code = "POkMI-result"
              rvs-line-attr.attr-value = v-POkMI-result-attr
            .
          end.
          find first rvs-line-attr exclusive-lock
                where rvs-line-attr.obj-code  = bf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = bf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = bf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = bf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "POkMI-warnings" no-error.
          if available rvs-line-attr then do :
            rvs-line-attr.attr-value = v-POkMI-warnings .
          end.
          else do :
            create rvs-line-attr.
            assign
              rvs-line-attr.obj-code  = bf_rvs-line.obj-code
              rvs-line-attr.obj-type  = bf_rvs-line.obj-type
              rvs-line-attr.gds-code  = bf_rvs-line.gds-code
              rvs-line-attr.pl-code   = bf_rvs-line.pl-code
              rvs-line-attr.rvs-code  = bf_rvs-line.rvs-code
              rvs-line-attr.attr-code = "POkMI-warnings"
              rvs-line-attr.attr-value = v-POkMI-warnings
            .
          end.
        end .
        release rvs-line-attr no-error .
      END.
    END.
  END.
END.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input p-obj-type
  , input p-obj-code
  ) .
    define variable v-calc-free-vol as logical no-undo init no .
    define variable v-sec-num as character no-undo init "" .
    if (is-sug(bf_rvs-line.gds-code) and ptrlprop-calc-free-vol-sug)
    or (not is-sug(bf_rvs-line.gds-code) and ptrlprop-calc-free-vol)
    then do :
      v-calc-free-vol = yes .
    end .
    find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-code = bf_rvs-line.rvs-code .
    if buf_rvs-doc.rvs-type = 'перед_док':U
    then do :
      if v-calc-free-vol then do:
      define variable infoSectionsTotal as class ibs.th.str.InfoSectionsTotal no-undo.
      define variable iisec as integer no-undo .
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_rvs-doc.out-code no-error .
      if available buf_trn-doc
      and buf_trn-doc.reason-code = 98
      then do : end .
      else do :
        v-doc-volume = 0 .
        find first buf_place no-lock where buf_place.obj-code = bf_rvs-line.obj-code
                                       and buf_place.obj-type = bf_rvs-line.obj-type
                                       and buf_place.pl-code  = bf_rvs-line.pl-code
                                       no-error.
        if is-sug(bf_rvs-line.gds-code)
        then do :
          is-main-tank = no .
          run placelib_get-attr  ( input "place-com-tanks"
                                  ,input buf_place.obj-code
                                  ,input buf_place.obj-type
                                  ,input buf_place.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input "place-is-main"
                                    ,input buf_place.obj-code
                                    ,input buf_place.obj-type
                                    ,input buf_place.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok
            and v-value > ""
            and logical(v-value)
            then do :
              is-main-tank = yes .
            end .
          end .
          else do :
            is-main-tank = yes .
          end .
          if is-main-tank
          then do :
            find first buf_doc-pl no-lock where buf_doc-pl.obj-type   = bf_rvs-line.obj-type
                                            and buf_doc-pl.obj-code   = bf_rvs-line.obj-code
                                            and buf_doc-pl.gds-code   = bf_rvs-line.gds-code
                                            and buf_doc-pl.pl-code    = bf_rvs-line.pl-code
                                            and buf_doc-pl.out-code   = buf_rvs-doc.out-code
                                            no-error .
            if not available buf_doc-pl
            then do :
              message "В накладной для товара " string(bf_rvs-line.gds-code) " нет распределения по местам хранения! Невозможно произвести расчет свободной ёмкости в резервуаре." view-as alert-box .
            end .
            else do :
              v-doc-volume = buf_doc-pl.fact-qnty .
            end .
          end .
        end .
        else do :
          infoSectionsTotal = new ibs.th.str.InfoSectionsTotal(buf_trn-doc.doc-code, bf_rvs-line.gds-code, 'ПРОСМОТР':U).
          if num-entries(bf_rvs-line.rvs-code, "-") = 3
          then do :
            v-sec-num = entry(2, bf_rvs-line.rvs-code, "-") .
          end .
          sect_ :
          do iisec = 1 to infoSectionsTotal:SectionNum :
            infoSectionsTotal:GetInfoSectionProp (iisec).
            if infoSectionsTotal:InfoSectionCurr:ListTank <> buf_place.loc1
            then
              next sect_ .
            if v-sec-num <> ""
            and v-sec-num <> infoSectionsTotal:InfoSectionCurr:SectionName
            then
              next sect_ .
            if infoSectionsTotal:InfoSectionCurr:DocVolume > 0
            then do :
              v-doc-volume = v-doc-volume + infoSectionsTotal:InfoSectionCurr:DocVolume .
            end .
            else do :
              v-doc-volume = v-doc-volume + infoSectionsTotal:InfoSectionCurr:DocQnty .
            end .
          end .
        end .
        if v-doc-volume > 0
        then do :
          if is-sug(bf_rvs-line.gds-code)
          then do :
            assign v-free-vol = 0.85 * buf_place.max-qnty - bf_rvs-line.state-measure-tc-qnty .
          end .
          else do :
            assign v-free-vol = 0.95 * buf_place.max-qnty - bf_rvs-line.state-brutto-qnty .
          end .
          if v-free-vol >= v-doc-volume
          then do :
            find first buf_doc-pl-attr exclusive-lock
                where buf_doc-pl-attr.obj-code  = bf_rvs-line.obj-code
                  and buf_doc-pl-attr.obj-type  = bf_rvs-line.obj-type
                  and buf_doc-pl-attr.gds-code  = bf_rvs-line.gds-code
                  and buf_doc-pl-attr.pl-code   = bf_rvs-line.pl-code
                  and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
                  and buf_doc-pl-attr.attr-code = "free-vol-exceed" no-error.
            if available buf_doc-pl-attr then
            do :
              buf_doc-pl-attr.attr-value = string(no)  .
            end.
            else
            do :
              create buf_doc-pl-attr.
              assign
                buf_doc-pl-attr.obj-code   = bf_rvs-line.obj-code
                buf_doc-pl-attr.obj-type   = bf_rvs-line.obj-type
                buf_doc-pl-attr.gds-code   = bf_rvs-line.gds-code
                buf_doc-pl-attr.pl-code    = bf_rvs-line.pl-code
                buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
                buf_doc-pl-attr.attr-code  = "free-vol-exceed"
                buf_doc-pl-attr.attr-value = string(no)
              .
            end.
          end .
          else do :
            run ref/message_volue.w(input string(round(v-doc-volume, 0)),
            input buf_place.loc1,
            input string(round(v-free-vol, 0)),
            input true) no-error .
            find first buf_doc-pl-attr exclusive-lock
                where buf_doc-pl-attr.obj-code  = bf_rvs-line.obj-code
                  and buf_doc-pl-attr.obj-type  = bf_rvs-line.obj-type
                  and buf_doc-pl-attr.gds-code  = bf_rvs-line.gds-code
                  and buf_doc-pl-attr.pl-code   = bf_rvs-line.pl-code
                  and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
                  and buf_doc-pl-attr.attr-code = "free-vol-exceed" no-error.
            if available buf_doc-pl-attr then
            do :
              buf_doc-pl-attr.attr-value = string(yes)  .
            end.
            else
            do :
              create buf_doc-pl-attr.
              assign
                buf_doc-pl-attr.obj-code   = bf_rvs-line.obj-code
                buf_doc-pl-attr.obj-type   = bf_rvs-line.obj-type
                buf_doc-pl-attr.gds-code   = bf_rvs-line.gds-code
                buf_doc-pl-attr.pl-code    = bf_rvs-line.pl-code
                buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
                buf_doc-pl-attr.attr-code  = "free-vol-exceed"
                buf_doc-pl-attr.attr-value = string(yes)
              .
            end.
          end .
        end .
      end .
    end .
      end.
      if buf_rvs-doc.rvs-type = 'после_док':U then
      do:
          find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_rvs-doc.out-code no-error .
          if available buf_trn-doc
            and buf_trn-doc.reason-code = 98
            then
          do :
          end .
          else
          do :
            v-doc-volume = 0 .
            find first buf_place no-lock where buf_place.obj-code = bf_rvs-line.obj-code
              and buf_place.obj-type = bf_rvs-line.obj-type
              and buf_place.pl-code  = bf_rvs-line.pl-code
              no-error.
            v-doc-volume = v-doc-volume + bf_rvs-line.state-brutto-qnty .
            if v-doc-volume > 0
              then
            do :
              if is-sug(bf_rvs-line.gds-code)
                then
              do :
                assign
                  v-free-vol = 0.85 * buf_place.max-qnty .
              end .
              else
              do :
                assign
                  v-free-vol = 0.95 * buf_place.max-qnty .
              end .
            end.
          end.
        if v-free-vol < v-doc-volume then
        do :
             find first buf_doc-pl-attr exclusive-lock
                where buf_doc-pl-attr.obj-code  = bf_rvs-line.obj-code
                and buf_doc-pl-attr.obj-type  = bf_rvs-line.obj-type
                and buf_doc-pl-attr.gds-code  = bf_rvs-line.gds-code
                and buf_doc-pl-attr.pl-code   = bf_rvs-line.pl-code
                and buf_doc-pl-attr.out-code  = buf_rvs-doc.out-code
                and buf_doc-pl-attr.attr-code = "free-vol-exceed-after" no-error.
              if available (buf_doc-pl-attr) then
              buf_doc-pl-attr.attr-value = string(yes)  .
              else
              do :
                create buf_doc-pl-attr.
                assign
                  buf_doc-pl-attr.obj-code   = bf_rvs-line.obj-code
                  buf_doc-pl-attr.obj-type   = bf_rvs-line.obj-type
                  buf_doc-pl-attr.gds-code   = bf_rvs-line.gds-code
                  buf_doc-pl-attr.pl-code    = bf_rvs-line.pl-code
                  buf_doc-pl-attr.out-code   = buf_rvs-doc.out-code
                  buf_doc-pl-attr.attr-code  = "free-vol-exceed-after"
                  buf_doc-pl-attr.attr-value = string(yes)
                  .
              end.
          end.
    end.
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
    define variable v-shift-date like ub.shift-obj.shift-date no-undo .
    define variable v-shift-num  like ub.shift-obj.shift-num no-undo .
    define variable v-shift-name like ub.shift-obj.shift-name no-undo.
    define variable v-person     as character no-undo.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  bf_rvs-line.obj-type
  ,input  bf_rvs-line.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
    for first  ub.rvs-doc no-lock
        where ub.rvs-doc.rvs-code = bf_rvs-line.rvs-code :
      v-vid-action = 56 .
      v-vid-param =
           "Initiator=" + v-initiator + chr(4) +
          "SHOP_NUM=" + string(ub.rvs-doc.obj-code) + chr(4) +
          "DocType=" + string(ub.rvs-doc.rvs-type) + chr(4) +
          "DocNum=" + string(ub.rvs-doc.rvs-code) + chr(4) +
           "SHIFT_NUM_DOC=" + (if string(ub.rvs-doc.shift-num) = ? then '' else string(ub.rvs-doc.shift-num)) + (if string(ub.rvs-doc.shift-date) = ? then '' else string(ub.rvs-doc.shift-date, "99999999")) + chr(4) +
           "SHIFT_NUM=" + (if string(v-shift-num) = ? then '' else string(v-shift-num)) + (if string(v-shift-date) = ? then '' else string(v-shift-date, "99999999")) + chr(4) +
          "PlCode=" + string(bf_rvs-line.pl-code) + chr(4) +
          "Temperature=" + string(bf_rvs-line.state-temperature) + chr(4) +
          "StateDensity=" + string( bf_rvs-line.state-density) + chr(4) +
          "StateMeasureQnty=" + string(  bf_rvs-line.state-measure-qnty  ) + chr(4) +
          "StateBruttoQnty=" +  string(bf_rvs-line.state-brutto-qnty ) + chr(4) +
          "StateMeasureCliQnty=" + string(bf_rvs-line.state-measure-cli-qnty)  + chr(4) +
          "StateBruttoCliQnty=" + string(bf_rvs-line.state-brutto-cli-qnty ) +  chr(4) +
          "StateLevelTotal=" + string(  bf_rvs-line.state-level-total) +  chr(4) +
          "StateLevelPetrol=" + string(  bf_rvs-line.state-level-petrol  ) +  chr(4) +
          "StateLevelWater=" + string(  bf_rvs-line.state-level-water    ) +  chr(4) +
          "StateMeasureTcQnty=" + string(  bf_rvs-line.state-measure-tc-qnty  ) +   chr(4) +
          "StateBruttoTcQnty=" + string(   bf_rvs-line.state-brutto-tc-qnty ) +   chr(4) +
          "RESULT=" + string( 0 ) + chr(4) +
          "Description="  no-error.
      run trg/userlog.p (
          input 'create':U
          , input 'rvs-doc':U
          , input ( buffer ub.rvs-doc :handle )
          , input v-vid-action
          , input v-vid-param
          ) no-error.
      if error-status :error
      then do:
        return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
              , chr(10)
              , vss-workfile
              , return-value
              , error-status :get-message ( 1 ) ).
      end.
    end.
  RETURN .
END PROCEDURE.
procedure lib-rvs_fill2plc :
  define input        parameter           p-obj-type  like ub.rvs-line.obj-type no-undo.
  define input        parameter           p-obj-code  like ub.rvs-line.obj-code no-undo.
  define input        parameter           p-pl-code   like ub.rvs-line.pl-code  no-undo.
  define input        parameter           p-rec-line  as   recid                no-undo.
  define input        parameter           p-prev-code like ub.rvs-doc.rvs-code  no-undo.
  define input-output parameter table for tt-meas.
define variable p-prev-rvs-date as logical no-undo.
  define variable olddensvalue as character no-undo initial ?.
  define variable olddenstype  as character no-undo initial ?.
  define variable varnum-rsrv  as integer   no-undo.
  define buffer crl_prev_rvs-doc  for ub.rvs-doc.
  define buffer prev_rvs-line     for ub.rvs-line.
  define buffer bf_goods          for ub.goods.
  define buffer bf_gds-obj        for ub.gds-obj.
  define buffer bf-prev_doc-line  for ub.doc-line.
  define buffer bf-prev_inv-line  for ub.inv-line.
  define buffer bf-prp_goods      for ub.goods.
  define buffer bf-prp_pl-gds     for ub.pl-gds.
  define buffer bf_rvs-line       for ub.rvs-line.
  define buffer buf_doc-line-attr for ub.doc-line-attr .
  define variable v-qnty    as decimal      no-undo.
  find first bf_rvs-line
    where recid( bf_rvs-line ) = p-rec-line
  .
  find first buf_doc-line-attr
    where buf_doc-line-attr.doc-code   = bf_rvs-line.rvs-code
      and buf_doc-line-attr.gds-code   = bf_rvs-line.gds-code
      and buf_doc-line-attr.attr-code  = substitute("rvs-&1",bf_rvs-line.pl-code)
    no-error.
  if not available buf_doc-line-attr then do:
    return error substitute ( 'Ошибка. Данные по документам не заполнены по месту хранения &1.', p-pl-code ).
  end.
  else do:
    assign
      v-qnty = decimal(entry(1, buf_doc-line-attr.attr-value, chr(4)))
    .
  end.
  assign
    bf_rvs-line.state-measure-qnty     = v-qnty
    bf_rvs-line.state-measure-tc-qnty  = v-qnty
  .
    find first crl_prev_rvs-doc no-lock
      where crl_prev_rvs-doc.rvs-code = p-prev-code
      no-error.
    if available crl_prev_rvs-doc then do:
      find first prev_rvs-line no-lock where
                 prev_rvs-line.rvs-code = crl_prev_rvs-doc.rvs-code and
                 prev_rvs-line.obj-type = bf_rvs-line.obj-type      and
                 prev_rvs-line.obj-code = bf_rvs-line.obj-code      and
                 prev_rvs-line.pl-code  = bf_rvs-line.pl-code       and
                 prev_rvs-line.gds-code = bf_rvs-line.gds-code      no-error.
      if available prev_rvs-line then do:
        assign
          bf_rvs-line.state-level-water      = prev_rvs-line.state-level-water
          bf_rvs-line.state-density          = prev_rvs-line.state-density
          bf_rvs-line.state-brutto-qnty      = bf_rvs-line.state-measure-qnty + ( prev_rvs-line.state-brutto-qnty - prev_rvs-line.state-measure-qnty )
          bf_rvs-line.state-brutto-tc-qnty  = bf_rvs-line.state-brutto-qnty
          bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.state-measure-qnty * bf_rvs-line.state-density
          bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.state-brutto-qnty  * bf_rvs-line.state-density
        .
        find first bf_goods   no-lock where
                   bf_goods.gds-code    = bf_rvs-line.gds-code.
        find first bf_gds-obj no-lock where
                   bf_gds-obj.obj-type  = bf_rvs-line.obj-type and
                   bf_gds-obj.obj-code  = bf_rvs-line.obj-code and
                   bf_gds-obj.artic     = bf_goods.artic       and
                   bf_gds-obj.prod-code = bf_goods.prod-code   and
                   bf_gds-obj.prod-code = bf_goods.prod-code   no-error.
        if available bf_gds-obj then do:
          if bf_gds-obj.fact-qnty <> 0 then do:
            find last bf-prev_doc-line no-lock where
                      bf-prev_doc-line.obj-type   = bf_rvs-line.obj-type and
                      bf-prev_doc-line.obj-code   = bf_rvs-line.obj-code and
                      bf-prev_doc-line.prod-type  = bf_goods.prod-type   and
                      bf-prev_doc-line.prod-code  = bf_goods.prod-code   and
                      bf-prev_doc-line.artic      = bf_goods.artic       and
                      bf-prev_doc-line.status_    = 'факт':U              and
                      bf-prev_doc-line.fact-order > 0                    use-index fact-order no-error.
            if available bf-prev_doc-line then do:
              find first bf-prev_inv-line no-lock where
                         bf-prev_inv-line.doc-code  = bf-prev_doc-line.doc-code  and
                         bf-prev_inv-line.artic     = bf-prev_doc-line.artic     and
                         bf-prev_inv-line.prod-code = bf-prev_doc-line.prod-code and
                         bf-prev_inv-line.prod-type = bf-prev_doc-line.prod-type no-error.
              if available bf-prev_inv-line then do:
                assign
                  bf_rvs-line.system-cli-qnty = bf_rvs-line.system-qnty * bf-prev_inv-line.after-cli-qnty
                                                                        / bf_gds-obj.fact-qnty
                .
              end.
            end.
            else do:
              assign
                bf_rvs-line.system-cli-qnty = 0.00
              .
            end.
          end.
          else do:
            find last bf-prev_doc-line no-lock where
                      bf-prev_doc-line.obj-type   = bf_rvs-line.obj-type and
                      bf-prev_doc-line.obj-code   = bf_rvs-line.obj-code and
                      bf-prev_doc-line.prod-type  = bf_goods.prod-type   and
                      bf-prev_doc-line.prod-code  = bf_goods.prod-code   and
                      bf-prev_doc-line.artic      = bf_goods.artic       and
                      bf-prev_doc-line.status_    = 'факт':U              and
                      bf-prev_doc-line.fact-order > 0                    use-index fact-order no-error.
            if available bf-prev_doc-line then do:
              find first bf-prev_inv-line no-lock where
                         bf-prev_inv-line.doc-code  = bf-prev_doc-line.doc-code  and
                         bf-prev_inv-line.artic     = bf-prev_doc-line.artic     and
                         bf-prev_inv-line.prod-code = bf-prev_doc-line.prod-code and
                         bf-prev_inv-line.prod-type = bf-prev_doc-line.prod-type no-error.
              if available bf-prev_inv-line then do:
                find first bf-prp_goods no-lock where
                           bf-prp_goods.artic     = bf-prev_inv-line.artic     and
                           bf-prp_goods.prod-type = bf-prev_inv-line.prod-type and
                           bf-prp_goods.prod-code = bf-prev_inv-line.prod-code .
                assign
                  varnum-rsrv = 0
                .
                for each bf-prp_pl-gds no-lock where
                         bf-prp_pl-gds.gds-code = bf-prp_goods.gds-code and
                         bf-prp_pl-gds.obj-type = bf_rvs-line.obj-type  and
                         bf-prp_pl-gds.obj-code = bf_rvs-line.obj-code
                on error undo, return error return-value
                :
                  assign
                    varnum-rsrv = varnum-rsrv + 1
                  .
                end.
                assign
                  bf_rvs-line.system-cli-qnty = bf-prev_inv-line.after-cli-qnty / varnum-rsrv
                .
              end.
            end.
            else do:
              assign
                bf_rvs-line.system-cli-qnty = 0.00
              .
            end.
          end.
        end.
        else do:
          assign
            bf_rvs-line.system-cli-qnty = 0.00
          .
        end.
      end.
    end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input p-obj-type
  , input p-obj-code
  ) .
        IF ptrlprop-olddens = true
        and not is-sug(bf_rvs-line.gds-code)
        THEN
        DO:
            p-prev-rvs-date = NO.
            FIND FIRST rvs-doc WHERE rvs-doc.rvs-code = bf_rvs-line.rvs-code NO-LOCK NO-ERROR.
            prev: FOR EACH crl_prev_rvs-doc NO-LOCK
                WHERE crl_prev_rvs-doc.obj-type   = p-obj-type
                AND crl_prev_rvs-doc.obj-code   = p-obj-code
                AND crl_prev_rvs-doc.shift-date = rvs-doc.shift-date
                AND crl_prev_rvs-doc.shift-num  = rvs-doc.shift-num
                AND crl_prev_rvs-doc.status_    = 'факт':U
                AND crl_prev_rvs-doc.rvs-type  <> 'проверка':U
                BY crl_prev_rvs-doc.fact-order DESC
                ON ERROR UNDO, RETURN ERROR RETURN-VALUE
                :
                IF CAN-FIND( FIRST doc-attr
                    WHERE doc-attr.doc-code  = crl_prev_rvs-doc.rvs-code
                    AND doc-attr.attr-code = "rvs-auto":U
                    AND doc-attr.attr-value = "Yes":U
                    NO-LOCK)
                    THEN next prev.
                FIND LAST prev_rvs-line NO-LOCK
                    WHERE prev_rvs-line.rvs-code = crl_prev_rvs-doc.rvs-code
                    AND prev_rvs-line.obj-type = p-obj-type
                    AND prev_rvs-line.obj-code = p-obj-code
                    AND prev_rvs-line.pl-code  =  bf_rvs-line.pl-code
                    AND prev_rvs-line.gds-code = bf_rvs-line.gds-code
                    NO-ERROR .
                IF AVAILABLE prev_rvs-line THEN
                DO:
                    bf_rvs-line.state-density = prev_rvs-line.state-density.
                    bf_rvs-line.state-temperature = prev_rvs-line.state-temperature.
                    p-prev-rvs-date = YES.
                    LEAVE prev .
                END.
            END.
            IF   p-prev-rvs-date = NO THEN
            DO :
                FIND FIRST crl_prev_rvs-doc NO-LOCK WHERE
                    crl_prev_rvs-doc.rvs-code = p-prev-code NO-ERROR .
                IF AVAILABLE crl_prev_rvs-doc THEN
                DO:
                    FIND FIRST prev_rvs-line NO-LOCK WHERE
                        prev_rvs-line.rvs-code = crl_prev_rvs-doc.rvs-code AND
                        prev_rvs-line.obj-type = bf_rvs-line.obj-type      AND
                        prev_rvs-line.obj-code = bf_rvs-line.obj-code      AND
                        prev_rvs-line.pl-code  = bf_rvs-line.pl-code       AND
                        prev_rvs-line.gds-code = bf_rvs-line.gds-code      NO-ERROR .
                    IF AVAILABLE prev_rvs-line THEN
                    DO:
                        ASSIGN
                            bf_rvs-line.state-temperature = prev_rvs-line.state-temperature
                            bf_rvs-line.density                = prev_rvs-line.state-density
                            bf_rvs-line.state-density          = prev_rvs-line.state-density
                            bf_rvs-line.measure-cli-qnty       = bf_rvs-line.measure-qnty       * bf_rvs-line.density
                            bf_rvs-line.brutto-cli-qnty        = bf_rvs-line.brutto-qnty        * bf_rvs-line.density
                            bf_rvs-line.state-measure-cli-qnty = bf_rvs-line.state-measure-qnty * bf_rvs-line.density
                            bf_rvs-line.state-brutto-cli-qnty  = bf_rvs-line.state-brutto-qnty  * bf_rvs-line.density
                            .
                    END.
                END.
            END.
        END.
  return .
end procedure.
procedure lib-rvs_rvs-full :
  define input parameter p-rvs-code like ub.rvs-doc.rvs-code no-undo.
  define variable l_rvs-is-full as logical no-undo initial yes.
  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define buffer bf_place    for ub.place.
  define buffer bf_pl-gds   for ub.pl-gds.
  define buffer bf_rvs-doc  for ub.rvs-doc.
  define buffer bf_rvs-line for ub.rvs-line.
  tr:
  do
  on error undo tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop  undo tr, return error substitute( "&1 (stop).", vss-workfile )
  on quit  undo tr, return error substitute( "&1 (quit).", vss-workfile )
  :
    find first bf_rvs-doc exclusive-lock
      where bf_rvs-doc.rvs-code = p-rvs-code
      no-error.
    if not available bf_rvs-doc then do:
      undo tr, return error substitute( 'lib-rvs_rvs-full: не найдена сверка "&1"', p-rvs-code ).
    end.
    for each bf_place  no-lock
      where bf_place.obj-type = bf_rvs-doc.obj-type
        and bf_place.obj-code = bf_rvs-doc.obj-code
      ,each bf_pl-gds no-lock
      where bf_pl-gds.obj-type = bf_place.obj-type
        and bf_pl-gds.obj-code = bf_place.obj-code
        and bf_pl-gds.pl-code  = bf_place.pl-code
    on error undo tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    :
      run gds-attr-value in this-procedure
        ( input  bf_pl-gds.gds-code
         ,input  'ptrl-without-rvs':U
         ,output v-attr-value
         ,output v-attr-type
        ) .
      if lookup(v-attr-value, 'true,yes':u) = 0 then do:
        find first bf_rvs-line no-lock
          where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
            and bf_rvs-line.obj-type = bf_pl-gds.obj-type
            and bf_rvs-line.obj-code = bf_pl-gds.obj-code
            and bf_rvs-line.pl-code  = bf_pl-gds.pl-code
            and bf_rvs-line.gds-code = bf_pl-gds.gds-code
          no-error.
        if not available bf_rvs-line then do:
          assign
            l_rvs-is-full = no
          .
          leave .
        end.
      end.
    end.
    if l_rvs-is-full = yes then do:
      assign
        bf_rvs-doc.is-full = yes
      .
    end.
  end.
  return .
end procedure.
procedure lib-rvs_rvsclose :
  define input  parameter parparentproc as widget-handle no-undo.
  define input  parameter p-rec-rvs-doc as recid   no-undo.
  define input  parameter p-message-on  as logical no-undo.
  define buffer rc_rvs-doc  for ub.rvs-doc.
  define buffer bef-rvs-doc for ub.rvs-doc.
  define buffer bf_trn-doc  for ub.trn-doc.
  define variable varchk-prs  as character no-undo.
  define variable v_data-type as character no-undo.
  define variable g-log       as logical   no-undo.
  define variable v-chk-act   as character no-undo .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
  run get-userid in parparentproc ( output v-cntxt-userid).
  run get-db-num in parparentproc ( output v-cntxt-db-num).
  do
  on error undo, return error substitute( "lib-rvs_rvsclose: &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  :
    find first rc_rvs-doc
      where recid( rc_rvs-doc ) = p-rec-rvs-doc
    .
    if rc_rvs-doc.rvs-type <> 'перед_док':U
      and rc_rvs-doc.rvs-type <> 'после_док':U
    then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
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
        if thbjattr_thbj-attr.prop-code = 'chk-prs' then varchk-prs = string(thbjattr_thbj-attr.property-value-logical,"yes/no") .
      end.
      empty temp-table thbjattr_thbj-attr.
      if varchk-prs <> 'no' then do:
        if not can-find( ub.clients no-lock where
                         ub.clients.obj-type = 'чел':U and
                         ub.clients.obj-code = rc_rvs-doc.boss )
        then do:
          return error 'Не указан или неправильный менеджер.' .
        end.
        if not can-find( ub.clients no-lock where
                         ub.clients.obj-type = 'чел':U and
                         ub.clients.obj-code = rc_rvs-doc.agnt )
        then do:
          return error 'Не указан или неправильный исполнитель.' .
        end.
      end.
    end.
    case rc_rvs-doc.rvs-type :
      when 'перед_док':U
      or when 'после_док':U
      then do:
        assign
          v-chk-act = 'actn_rvs-on-doc_fact':U
        .
      end.
      when 'смена':U
      then do:
        assign
          v-chk-act = 'actn_rvs-shift_fact':U
        .
      end.
      when 'контроль':U
      then do:
        assign
          v-chk-act = 'actn_rvs-control_fact':U
        .
      end.
      when 'проверка':U
      then do:
        assign
          v-chk-act = 'no-ckeck':U
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип документа сверки" skip
          "Тип документа сверки" rc_rvs-doc.rvs-type skip
          "Код документа сверки" rc_rvs-doc.rvs-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    if not g#auto
    and v-chk-act <> 'no-ckeck':U
    then do:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  v-chk-act
    ,input  'object':U
    ,input  rc_rvs-doc.host-code
    ,input  rc_rvs-doc.obj-type
    ,input  rc_rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  p-message-on
    ,output g-log
    )  .
end.
      if g-log <> yes then do:
        return error substitute( 'У Вас недостаточно прав для выполнения данного действия:&5'
                               + '"закрытие сверки типа <<&1>> на факт" на объекте: &2 &3.&5'
                               + '&4&5'
                               + 'Обратитесь к администратору.'
                               , rc_rvs-doc.rvs-type
                               , rc_rvs-doc.obj-type
                               , rc_rvs-doc.obj-code
                               , return-value
                               , chr(10) ) .
      end.
    end.
    tr:
    do transaction
    on error   undo tr, return error return-value
    on end-key undo tr, return error return-value
    :
      run gbl/chk-date.p
        ( input rc_rvs-doc.obj-type
        , input rc_rvs-doc.obj-code
        , input rc_rvs-doc.fact-date
        , input rc_rvs-doc.fact-time
        , input rc_rvs-doc.shift-date
        , input rc_rvs-doc.shift-num
        , input p-message-on
        ) no-error .
      if error-status :error then do:
        undo tr, return error substitute( 'lib-rvs_rvsclose: Ошибка при установке даты в документе (rvs-doc)&1&2.', chr(10), return-value ) .
      end.
      if rc_rvs-doc.rvs-type = 'смена':U
        and rc_rvs-doc.status_  = 'разрешен':U
      then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_rvschtrn in g#lib-trn3
  (  input rc_rvs-doc.obj-type
  ,  input rc_rvs-doc.obj-code
  ,  input rc_rvs-doc.shift-date
  ,  input rc_rvs-doc.shift-num
  ,  input rc_rvs-doc.rvs-code
  ,  input no
  ,  input yes
  , output g-log
  )        no-error
.
        if error-status :error then do:
          undo tr, return error 'lib-rvs_rvsclose: Ошибка поиска незакрытых документов. '  + return-value .
        end.
        if g-log <> no then do:
          undo tr, return error 'lib-rvs_rvsclose: Невозможно создать сверку. ' + return-value .
        end.
      end.
      if rc_rvs-doc.rvs-type <> 'проверка':U
      then do :
        define variable v-ok    as logical      no-undo.
        run str/rvs-attr.p
          ( input rc_rvs-doc.rvs-code
          , input rc_rvs-doc.obj-type
          , input rc_rvs-doc.obj-code
          , output v-ok
          ) no-error.
        if error-status :error
          or v-ok = false
        then do:
        end.
      end .
      run str/rvs-stat.p
        ( input parparentproc
         ,input recid( rc_rvs-doc )
         ,input 'close':U
        )  .
      if error-status :error then do:
        undo tr, return error substitute( 'lib-rvs_rvsclose: Ошибка при изменении статуса&1&2.', chr(10), return-value ) .
      end.
      release rc_rvs-doc no-error.
      if error-status:error then    undo tr, return error  return-value .
      find first rc_rvs-doc where recid( rc_rvs-doc ) = p-rec-rvs-doc .
      if rc_rvs-doc.rvs-type = 'смена':U
        and rc_rvs-doc.status_  = 'факт':U
      then do:
        run gbl/sht-clos.p
          ( input parparentproc
           ,input rc_rvs-doc.obj-type
           ,input rc_rvs-doc.obj-code
           ,input false
           ,input (if p-message-on = true then false else true )
          ) no-error .
          for each tt-susp-chk:
          end.
        if error-status :error then do:
          undo tr, return error 'Ошибка при закрытии смены. ' + return-value .
        end.
      end.
    end.
  end.
  return .
end procedure.
PROCEDURE get-userid :
do
on error undo, return error
:
define output parameter p-userid  as character    no-undo.
    assign
        p-userid = g#userid
    .
end.
END PROCEDURE.
procedure get-db-num:
  define output parameter pDbNum as integer no-undo.
  pDbNum = g#db-num.
end.
procedure lib-rvs_crtt-rvs :
  define input-output parameter table for tt-param.
  define       output parameter           p-comstring   as character no-undo initial ?.
  define       output parameter           p-comment     as character no-undo initial ?.
  define       output parameter           p-StartString as character no-undo initial ?.
  define variable rvsvalue       as character no-undo initial ?.
  define variable rvstype        as character no-undo initial ?.
  define variable StrFrFile-list as character no-undo initial '':U.
  define variable StrFrAsi-list  as character no-undo initial '':U.
  define variable FldDb-list     as character no-undo initial '':U.
  define variable jj             as integer   no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'revision'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output rvsvalue
  ,output rvstype
  ) no-error .
  assign
    rvsvalue       = trim( rvsvalue )
    StrFrFile-list = "level_total" + ",level_water" + ",level_oil-"     + ",t1"          + ",t2"          + ",t3"          + ",temperature" + ",density" + ",volume_total" + ",volume_total_tc" + ",mass_total"      + ",volume_oil"   + ",volume_water" + ",vapor_density" + ",vapor_pressure"
    StrFrASi-list  = "level-total" + ",level-water" + ",level-total-"    + ",t1"          + ",t2"          + ",t3"          + ",avrg-temp"   + ",density" + ",total-vol"    + ",volume_total_tc" + ",mass"            + ",volume_oil"   + ",volume_water" + ",vapor-density" + ",vapor-pressure"
    FldDb-list     = "level-total" + ",level-water" + ",level-petrol"   + ",temp-layer1" + ",temp-layer2" + ",temp-layer3" + ",temperature" + ",density" + ",brutto-qnty"  + ",brutto-qnty-tc"  + ",brutto-cli-qnty" + ",measure-qnty" + ",water-qnty"   + ",vapor-density" + ",vapor-pressure"
  .
  if rvsvalue = ? then do:
    assign
      rvsvalue = 'struna'
    .
  end.
  get-key-value section 'revision'
                key     'comstr'
                value   p-comstring.
    case rvsvalue :
      when 'struna'     or
      when 'vedee-root'
      then do:
        for each tt-param :
          delete tt-param .
        end.
        assign
          p-comment     = '#'
          p-StartString = 'tank'
        .
        do jj = 1 to min( num-entries( StrFrFile-list ), num-entries( FldDb-list ), num-entries(StrFrASi-list)) :
          create tt-param.
          assign
                 tt-param.strfrfile = entry( jj, StrFrFile-list )
                 tt-param.strasi    = entry( jj, StrFrASi-list )
                 tt-param.flddb     = entry( jj, FldDb-list     )
          .
        end.
      end.
      otherwise do:
        return error 'Неизвестный тип прибора в параметре revision.' .
      end.
    end case.
  return .
end procedure.
procedure lib-rvs_crtt-pmp :
  define input-output parameter table for tt-param-pump.
  define variable StrFrFile-list as character no-undo initial 'PUMP,NZL,VOL,VAL,GRADE,CNT,STATUS':U.
  define variable jj             as integer   no-undo.
    for each tt-param-pump :
      delete tt-param-pump .
    end.
    do jj = 1 to num-entries( StrFrFile-list ) :
      create tt-param-pump.
      assign
             tt-param-pump.strfrfile = entry( jj, StrFrFile-list )
      .
    end.
  return .
end procedure.
define temp-table tt-User no-undo
       field usr as character
       field pwd as character
    index usr usr.
define variable vss-revision19    as character no-undo init "$Revision:$":U .
define variable vss-author19      as character no-undo init "$Author:$":U .
define variable vss-date19        as character no-undo init "$Date:$":U .
define variable vss-workfile19    as character no-undo init "$Workfile:$":U .
define variable vss-archive19     as character no-undo init "$Archive:$":U .
define variable vss-description19 as character no-undo init "Работа С сокетом".
procedure PutMesAsunc:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext, yes)  .
end.
procedure PutMesAsuncNoTime:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext,no)  .
end.
procedure PutStatAsunc:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no) .
     run
    PutMesAsunc (itext).
end.
procedure PutStatAsuncNoTime:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no)  .
     run
    PutMesAsuncNoTime (itext).
end.
procedure PutStatAsuncAdd:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,yes)  .
end.
procedure PutFileLogAsunc:
    define input  parameter IFile as character no-undo.
    Publish "PutFileLogAsunc" (ifile)  .
end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable mHSocket       as handle      no-undo.
define variable mWebRespHead   as longchar    no-undo.
define variable mWebResp       as longchar    no-undo.
define variable mWebRespMptr   as memptr      no-undo.
define variable OerrMsg        as character   no-undo.
define variable mFileLogSocet  as character   no-undo.
define variable mReturnHttp    as logical     no-undo.
define variable mAddTimeOut    as logical     no-undo init yes.
define variable mSocetBegTime  as datetime-tz no-undo.
define variable mSocetEndTime  as dec         no-undo.
define variable mWriteRespFile as character   no-undo.
define variable mTypeResponse  as character   no-undo init "POST".
publish "getSocetLog" (output mFileLogSocet).
if
   (   mFileLogSocet eq ""
    or mFileLogSocet eq ?)
   and session:debug-alert
then
   mFileLogSocet = "socet.log".
procedure ConectSocet:
   define input  parameter iHost       as character no-undo.
   define input  parameter iPort       as character no-undo.
   define input  parameter iUrl        as character no-undo.
   define input  parameter iPostData   as longchar  no-undo.
   define input  parameter iReturnType as character no-undo.
   define input  parameter iTimeOut    as decimal   no-undo.
   define input  parameter iSilent     as logical   no-undo.
   define input  parameter iTextWait   as character no-undo.
   mWaitFramTextBeg = iTextWait.
   run SendReqSocet (iHost, iPort, iUrl, iPostData, iReturnType, 'getResponse').
   if OerrMsg eq ""
   then
      run waitrespsocet (iTimeOut, iSilent, iTextWait).
   mSocetEndTime = (now - mSocetBegTime) / 1000.
end.
procedure SendReqSocet:
   define input  parameter iHost            as character no-undo.
   define input  parameter iPort            as character no-undo.
   define input  parameter iUrl             as character no-undo.
   define input  parameter iPostData        as longchar  no-undo.
   define input  parameter iReturnType      as character no-undo.
   define input  parameter iProcGetResponse as character no-undo.
   mSocetBegTime = now.
   run writeLogSocet in this-procedure (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   assign
      mWebResp         = ""
      mWebResphead     = ""
      OerrMsg          = ""
      mReturnHttp      = iReturnType eq "xml" or iReturnType eq "http" or iReturnType eq "yes"
      iProcGetResponse = "getResponse"  when iProcGetResponse eq ? or iProcGetResponse eq ""
   .
   define variable vPostData as longchar                       no-undo.
   if    iHost eq ""
      or iHost eq ?
   then do:
      oErrMsg = substitute("Не задан host &1 или port &2.", ihost ,iport).
      run writeLogSocet in this-procedure (oErrMsg).
      return oErrMsg.
   end.
   run waitfram-show (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   create socket mHSocket.
   mHSocket:connect('-H ' + iHost + ' -S ' + iPort) no-error.
   if mHSocket:connected() = false
   then do:
      run waitfram-hide .
      oErrMsg = substitute( "Не удалось установить соединение: &1" , error-status:get-message(1)).
      run writeLogSocet in this-procedure (oErrMsg).
      delete object mHSocket.
      return oErrMsg.
   end.
   run waitfram-show ("Отправка данных").
   mHSocket:set-read-response-procedure(iProcGetResponse).
   run PostRequest (
    input iUrl,
    input iHost + ":" + iPort,
    input iPostData
    ).
    run waitfram-hide .
end.
procedure WaitRespSocet:
   define input  parameter iTimeOut   as decimal   no-undo.
   define input  parameter iSilent    as logical   no-undo.
   define input  parameter iTextWait  as character no-undo.
   if    not valid-handle (mHSocket )
   then do:
      run writeLogSocet in this-procedure (substitute("Потерян объект соединения")).
      return "End connected".
   end.
   if mHSocket:connected() = false
   then do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespSocet")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   mWaitFramView = if iSilent ne yes then yes else no.
   mWaitFramTextBeg = iTextWait.
   mWaitFramTimeOut = iTimeOut.
   mWaitFramTextEnd = "".
   mWaitFramStop = no.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 300.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при уcтановке соодинения",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Ожидаем ответ TimeOut &1 сек.",iTimeOut )).
   subscribe   to "WaitFramStop" anywhere run-procedure "WaitRespTestStop".
   run WaitFramWaitFor(1).
   unsubscribe "WaitFramStop".
   if mWaitFramStopUser
   then do:
      OerrMsg = substitute("Операция прервана пользователем." ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   else if mWaitFramStopTimeOut
   then do:
      OerrMsg = substitute("Привышено время ожидания &1 сек. Ответ не получен.",iTimeOut ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   run waitfram-hide .
   mHSocket:disconnect() no-error.
   delete object mHSocket.
end.
procedure WaitRespTestStop:
   if mWaitFramStopTimeOut
   then
      return.
   if     (mWebResp ne ""
       and mWebResp ne ?)
   then do:
      mWaitFramStop = yes.
      return.
   end.
   else if mHSocket:connected() = false
   then do:
      mWaitFramStop = yes.
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespTestStop")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   wait-for read-response of mHSocket pause 0.001.
end.
procedure PostRequest:
   define input parameter iPostUrl  as char.
   define input parameter iPostHost as char.
   define input parameter iPostData as longchar.
   define variable vCRequest      as longchar.
   define variable vMRequest       as memptr.
   if iPostUrl ne ?
   then do:
      vCRequest =substitute(
      '&5 /&2 HTTP/1.1&1'                                   +
      'Host: &4&1'                                           +
      'User-Agent: Apache-HttpClient/4.1.1 (java 1.5)&1'    +
      'Accept: */*&1' +
      'Content-Type: text/xml&1'               +
      'Content-Length: &3&1'                                  +
      '&1'
      ,
      chr(13) + chr(10),
      iPostUrl,
      length(iPostData),
      iPostHost,
      mTypeResponse) + iPostData.
   end.
   else
      vCRequest = iPostData.
   run writeLogSocet in this-procedure (substitute("Отправляем запрос &1.",chr(13) + chr(10) )).
   run writeLogSocet in this-procedure (vCRequest).
   SET-SIZE(vMRequest)            = 0.
   SET-SIZE(vMRequest)            = length(vCRequest) + 1.
   SET-BYTE-ORDER(vMRequest)      = big-endian.
   PUT-STRING(vMRequest,1)        = vCRequest .
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure ("Соединение было разорвано другой стороной getResponse").
      oErrMsg = "Not connected".
      delete object mHSocket no-error.
      return oErrMsg.
   end.
   mHSocket:write(vMRequest, 1, length(vCRequest)).
   run writeLogSocet in this-procedure ("Запрос отправлен.").
end procedure.
function hex-to-int returns integer (
  input p-hex-code  as character  ).
  define variable v-int-code as integer   no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-digit    as integer   no-undo .
  define variable v-letter   as character no-undo .
  do v-ind = 1 to length(p-hex-code)
  :
    assign
      v-letter = caps(substring(p-hex-code, v-ind, 1))
    .
    assign
      v-digit = index('123456789ABCDEF':u, v-letter)
    .
    assign
      v-int-code = v-int-code * 16 + v-digit
    .
  end.
  return v-int-code .
end function .
procedure getResponse:
   define variable vFlagTag     as logical          no-undo init no.
   define variable vResponse    as memptr           no-undo.
   define variable vCnt         as int64            no-undo.
   define variable vMessage     as longchar         no-undo.
   define variable v-cont-length as int64 no-undo.
   define variable vi           as integer no-undo.
   define variable v-hd-line    as character no-undo.
   define variable level        as integer no-undo initial 2.
   repeat while program-name(level) <> ?:
     if program-name(level) = program-name(1) then do:
       run writeLogSocet in this-procedure (substitute("Повторный вызов getResponse.")).
       return "".
     end.
     level = level + 1.
   end.
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной getResponse")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 1000.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при получении ответа",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Получаем ответ")).
   mWaitFramTextEnd = "Получаем ответ".
   define variable vWaitProcEvent as logical no-undo.
   vWaitProcEvent = mWaitProcEvent.
   mWaitProcEvent = no.
   run WaitFramRunPause (?).
   define variable vByte as int64 no-undo.
   define variable vNextMese as int64 no-undo init 100000.
   define variable VFlag as logical no-undo init ? .
   mWaitFramStop = no.
   mWaitFramStopTimeOut = no.
   block-wait:
   do while mHSocket:get-bytes-available() > 0:
      VFlag = no.
      define variable vNumByte as integer no-undo.
      vNumByte =   mHSocket:get-bytes-available().
      if vNumByte > 30000 then vNumByte = 30000.
      SET-SIZE(vResponse) = vNumByte + 1.
      SET-BYTE-ORDER(vResponse) = big-endian.
      mHSocket:read(vResponse,1,vNumByte).
      vMessage = vMessage + GET-STRING(vResponse,1).
      if  mReturnHTTp
      then do:
         vCnt = index(vMessage,chr(13) + chr(10) + chr(13) + chr(10)).
         if vCnt > 0
         then do:
            mReturnHttp = no.
            mWebResphead = substring (vMessage,1,vCnt).
            vMessage     = substring (vMessage,vCnt + 4).
            mWebResphead = replace (mWebResphead,";",chr(13) + chr(10)).
            do vi = 1 to num-entries(mWebResphead,chr(13) + chr(10)):
               v-hd-line = trim(entry(vi,mWebResphead,chr(13) + chr(10))).
               if  v-hd-line  begins "Content-Length"  then  do:
                  v-cont-length = INT(trim(substring(v-hd-line,16,length(v-hd-line)))).
               end.
               else if v-hd-line  begins "Transfer-Encoding"
               then do :
                  define variable vChunked as logical no-undo.
                  vchunked = index(v-hd-line,"chunked",19) > 0.
               end.
            end.
         end.
      end.
      vByte = vByte + vNumByte.
      SET-SIZE(vResponse) = 0.
      if v-cont-length > 0 and length (vMessage) >= v-cont-length
      then
         leave block-wait.
      if not mHSocket:get-bytes-available() > 0
      then do:
         VFlag = yes.
         run WaitFramRunPause (?).
         run gbl/pause.p (1000) .
      end.
      else if vByte > vNextMese
      then do:
         vNextMese = vNextMese + 100000.
         mWaitFramTextEnd = substitute ("Получаем ответ прочитано &1 байт ",vByte) .
         run WaitFramRunPause (?).
      end.
      if mWaitFramStopTimeOut
      then do:
         mWebResp = "".
         leave block-wait.
      end.
   end.
   if VFlag ne false
   then
      run writeLogSocet in this-procedure (substitute ("Завершена обработка &1",If VFlag eq  yes then " 0 байт за последнию секунду" else " пустой ответ(((")).
   mWaitFramStop = yes.
   run writeLogSocet         in this-procedure ("Получен ответ").
   run writeLogSocetOnlyText in this-procedure (mWebResphead).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2&1&2",chr(13) , chr(10) )).
   run writeLogSocetOnlyText in this-procedure (vMessage).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   mHSocket:disconnect() no-error.
   if v-cont-length > 0
   then
      mWebResp = substring (vMessage,1,v-cont-length).
   else if vChunked
   then do:
      define variable vByteCopy as int64 no-undo init 1.
      Block-Copy:
      do while length(vMessage) > 0:
         vByteCopy = 1.
         vCnt = index (vMessage,chr(13) + chr(10)) - 1.
         vByteCopy = vByteCopy +  vCnt + 2.
         v-cont-length = hex-to-int(string(substring (vMessage,1,vCnt))).
         if v-cont-length eq 0
         then
            leave Block-copy.
         mWebResp = mWebResp + substring (vMessage,vByteCopy,  v-cont-length).
         vByteCopy = vByteCopy + v-cont-length + 2.
         vMessage = substring  (vMessage,vByteCopy).
      end.
      run writeLogSocet         in this-procedure ("Заголовок").
      run writeLogSocetOnlyText in this-procedure (mWebResphead).
      run writeLogSocet         in this-procedure ("Тело ответа").
      run writeLogSocetOnlyText in this-procedure (mWebResp).
     run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   end.
   else
      mWebResp = vMessage.
   mWaitProcEvent = vWaitProcEvent.
   mSocetEndTime = (now - mSocetBegTime) / 1000.
   copy-lob mWebResp to mWebRespMptr.
   if     mWriteRespFile ne ""
      and mWriteRespFile ne ?
   then
        run gbl/fileapnd.p
             ( mWriteRespFile
             , mWebResp + chr(13) + chr(10)
             ,input 10
             ) no-error .
end procedure.
procedure writeLogSocet:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute("&1 &2 ", string(today), string(time, "HH:MM:SS"))
          ,input 10
          ) no-error .
      run writeLogSocetOnlyText(itext).
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute(" &1&2", chr(13) , chr(10))
          ,input 10
          ) no-error .
   end.
end.
procedure writeLogSocetOnlyText:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      if length(itext) > 32000
      then
         copy-lob
   from object itext
   to file mFileLogSocet append
   no-error
   .
      else
      run gbl/fileapnd.p
          ( mFileLogSocet
          , string(itext)
          ,input 10
          ) no-error .
   end.
end.
procedure Disconect:
   mHSocket:disconnect() no-error.
   delete object mHSocket no-error.
end.
procedure getpump:
   define input  parameter ilogfile    as character no-undo.
   define input  parameter iobjtype    as character no-undo.
   define input  parameter iobjcode    as integer no-undo.
   define input  parameter imessageon  as logical no-undo.
   define input  parameter inowaitfram as logical no-undo.
   define output parameter Opump       as longchar no-undo.
   define variable vadr as character no-undo.
   define variable vport as character no-undo.
   define variable vtext as character no-undo.
   define variable old-BM as logical no-undo .
   old-BM = mBatchMode .
      vport = "4000".
   define variable vFlag   as logical no-undo.
   define variable vFlagOk as logical no-undo.
   mFileLogSocet = ilogfile.
    define variable vuser as character no-undo.
    define variable vuserobj as ibs.th.file.asyncparam no-undo.
    define variable vPassobj as ibs.th.file.asyncparam no-undo.
    define buffer buf_cash-desk for ub.cash-desk .
    vuserobj =  new ibs.th.file.asyncparam("user").
    vpassobj =  new ibs.th.file.asyncparam("pass").
    run utl/getuserpwdauto.p(input vuserobj, input vpassobj) no-error.
    if not error-status:error
    then do:
       vuser =  vuserobj:valueParam.
    end.
    else do:
       run utl/getuserpwd.p(input vuserobj, input vpassobj) no-error.
       if not error-status:error
       then do:
          vuser =  vuserobj:valueParam.
       end.
    end.
    delete object vuserobj.
    delete object vpassobj.
   define variable vnoActivCash as logical no-undo.
   block-cash:
   for each buf_cash-desk  where buf_cash-desk.db-num   = g#db-num
                             and buf_cash-desk.obj-code = iobjcode
                             and buf_cash-desk.is-del = no
   no-lock
   by buf_cash-desk.db-num
   by buf_cash-desk.is-del
   by buf_cash-desk.cash-on descending
   by buf_cash-desk.pos-type descending
   by buf_cash-desk.cash-num
      :
      if     not vnoActivCash
         and not buf_cash-desk.cash-on
      then do:
         vnoActivCash = yes.
         run gbl/fileapnd.p
          ( ilogfile
          , substitute("&1 &2 Нет включенных касс переходим к выключенным пользователь &3 &4", string(today),string(time, "HH:MM:SS"),vuser,chr(13) + chr(10))
          ,input 10
          ) no-error .
      end.
      vadr = entry(1,
                   (if num-entries(buf_cash-desk.addr-path, chr(4)) > 1
                    then  entry(2, buf_cash-desk.addr-path, chr(4))
                    else buf_cash-desk.addr-path
                    )
                  ,":").
      if vadr eq ""
      then
         next block-cash.
      vFlag = yes.
      run gbl/fileapnd.p
          ( ilogfile
          , substitute("&1 &2 Отправка команды &3 на кассу № &4 (&5:&6) Пользователь &7 &8", string(today),string(time, "HH:MM:SS"),"pumpread",cash-desk.cash-num,vadr,vport ,vuser,chr(13) + chr(10))
          ,input 10
          ) no-error .
      if inowaitfram
      then do :
        mBatchMode = yes .
      end .
      run ConectSocet (vadr,
                       vport,
                       ?,
                       "pumpread" + chr(13) + chr(10),
                       "text",
                       30,
                       yes ,
                       "Получение данных по ТРК. ") no-error.
      if     not error-status:error
         and length(mWebResp) > 0
         and index(mWebResp," PUMP=") > 0
      then do:
         run gbl/fileapnd.p
          ( ilogfile
          , substitute("&1 &2 Ответ:&4&3&4", string(today),string(time, "HH:MM:SS"),mWebResp ,chr(13) + chr(10))
          ,input 10
          ) no-error .
         vFlagOk = yes.
         leave block-cash.
      end.
      else
         run gbl/fileapnd.p
          ( ilogfile
          , substitute('&1 &2 Результат: &3 "&4" &5', string(today),string(time, "HH:MM:SS"),OerrMsg,mWebResp ,chr(13) + chr(10))
          ,input 10
          ) no-error .
   end.
   mBatchMode = old-BM .
   mFileLogSocet = "".
   if not vFlag
   then do:
      vtext = substitute("Нет включеных касс по БД &1 Объект &2&3 &4 ", g#db-num, "маг", iobjcode ,chr(13) + chr(10)).
      run gbl/fileapnd.p
          ( ilogfile
          , substitute("&1 &2 &3", string(today),string(time, "HH:MM:SS"),vtext)
          ,input 10
          ) no-error .
      return error vtext.
   end.
   else if not vFlagOk
   then
      return error "На момент приема данных по счетчикам ТРК нет связи ни с одной из касс.".
   else
      Opump = mWebResp.
end.
procedure lib-rvs_anls-pmp :
  define input        parameter           p-parent-proc       as   widget-handle       no-undo.
  define input        parameter           p-obj-type          like ub.rvs-doc.obj-type no-undo.
  define input        parameter           p-obj-code          like ub.rvs-doc.obj-code no-undo.
  define input        parameter           p-check-goods       as   logical             no-undo.
  define input-output parameter table for tt-pump-nozzle-file.
  define input-output parameter table for tt-pump-nozzle.
  define input        parameter           p-read-cur          as   logical             no-undo.
  define input        parameter           p-message-on        as   logical             no-undo.
  define input        parameter           p-no-waitfram       as   logical             no-undo.
  define variable j_pump-code   like ub.pump-nozzle.pump-code   no-undo.
  define variable j_nozzle-code like ub.pump-nozzle.nozzle-code no-undo.
  define variable j_gds-code    like ub.goods.gds-code          no-undo.
  define variable is_Error      as   logical                    no-undo initial no.
  define variable is_FatalError as   logical                    no-undo initial no.
  define variable vi as integer no-undo.
  define variable v_File-Name   as character no-undo.
  define variable v_File-Err    as character no-undo.
  define variable v_command     as character no-undo.
  define variable v_String-Temp as character no-undo.
  define variable v_String      as character no-undo.
  define variable v_Prefix      as character no-undo.
  define variable v_Param       as character no-undo.
  define variable v_String-Tail as character no-undo.
  define variable j_Space       as integer   no-undo.
  define variable j_b-code      like ub.bar-code.b-code        no-undo.
  define variable d_rate        like ub.bar-code.cli-base-rate no-undo.
  define variable conf-par      as   character                 no-undo.
  define variable par-type      as   character                 no-undo.
  define variable v_result      as   character                 no-undo.
  define variable v_type-bc     as   character                 no-undo.
  define variable d_weight      as   decimal                   no-undo.
  define variable v_DirFilePump as   character                 no-undo.
  define variable j_num         as   integer                   no-undo.
  define variable l_log         as   logical                   no-undo.
  define variable v_CommandPump as   character                 no-undo initial ?.
  define variable vPump as longchar no-undo.
  define buffer bf_goods      for ub.goods.
  define buffer bf_goods-file for ub.goods.
  define buffer bf_bar-code   for ub.bar-code.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type21 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type21
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type21 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type21
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_crtt-pmp in g#lib-rvs ( input-output table tt-param-pump  ) no-error .
  if error-status :error then do:
    return error substitute( 'Ошибка при установке параметров для считывания данных с ТРК.&1&2&1&3'
                           , chr(10)
                           , error-status :get-message( 1 )
                           , return-value ) .
  end.
  if p-read-cur = ? then do:
    if p-message-on = no then do:
      assign
        p-read-cur = yes
      .
    end.
    else do:
      run gbl/d-askw.w
        (  input 'Выбор источника данных с информацией по ТРК'
        ,  input 'Будем читать текущие данные с ТРК или возьмем данные из файла?'
        ,  input '|^'
        ,  input 'Текущие данные|Из файлов|Отмена'
        ,  input 'Запускается программа для обращения к датчикам ТРК|'
        +        'Берутся уже сохраненные данные из файла|Ничего не делаем'
        ,  input 1
        ,  input 3
        , output j_num
        ) .
      case j_num :
        when 3 then do:
          return error .
        end.
        when 2 then do:
          assign
            p-read-cur = no
          .
        end.
        when 1 then do:
          assign
            p-read-cur = yes
          .
        end.
      end case.
    end.
  end.
  if     objSrv:SystemSetting:pumpfile ne ?
     and objSrv:SystemSetting:pumpfile ne ""
     and search(objSrv:SystemSetting:pumpfile) ne ?
  then do:
     assign
        v_File-Name = search(objSrv:SystemSetting:pumpfile)
        v_File-Err  = substitute('&1pump.err', ibs.th.gbl.gbl-inipar:logDir) .
     .
     run readfiletxt(v_File-Name,output vPump).
  end.
  else if p-read-cur = yes then do:
    assign
      v_File-Name = './pump.txt'
      v_File-Err  = substitute('&1pump.err', ibs.th.gbl.gbl-inipar:logDir) .
    .
    output to value(v_File-Err) .
    output close.
    run getpump(v_File-Err, p-obj-type, p-obj-code, p-message-on, p-no-waitfram, output vPump) no-error.
    if error-status:error
    then
       return error substitute ("&1 Повторите попытку или обратитесь в техническую поддержку.",return-value).
  end.
  else do:
    v_DirFilePump = ibs.th.gbl.gbl-inipar:dirflpmp .
    if v_DirFilePump = '':U or
       v_DirFilePump = ?
    then do:
      assign
        v_DirFilePump = ' .'
      .
    end.
    system-dialog get-file v_File-Name
      initial-dir v_DirFilePump
      title       'Выберите файл с данными по ТРК'
      update      l_log.
    if l_log <> yes then do:
      return error .
    end.
    v_File-Err  = substitute("&1.err":U,  entry(1, v_File-Name, '.':U)) .
    output to value (v_File-Err).
    output close.
    run readfiletxt(v_File-Name,output vPump).
  end.
          define variable vErrortext as character no-undo.
  define variable verrorlist as character no-undo.
      for each tt-pump-nozzle-file :
    delete tt-pump-nozzle-file .
  end.
  main-cycle:
  do vi = 1 to num-entries(vPump,chr(10)) :
     v_String-Temp = entry(vi,vPump,chr(10)).
    if trim( v_String-Temp ) = '':U then do:
      next main-cycle .
    end.
    if substring( v_String-Temp, 1, 3 ) <> '212' then do:
      next main-cycle .
    end.
    assign
      v_Prefix =       substring( v_String-Temp, 1, 4 )
      v_String = trim( substring( v_String-Temp, 5    ) )
    .
    for each tt-param-pump :
      assign
             tt-param-pump.meaning = ? .
    end.
    assign
      v_String-Tail = v_String
    .
    do while v_String-Tail <> '':U :
      assign
        j_Space = index( v_String-Tail, ' ':U )
      .
      if j_Space = 0 then do:
        assign
          v_Param       = trim( v_String-Tail )
          v_String-Tail = '':U
        .
      end.
      else do:
        assign
          v_Param       = trim( substring( v_String-Tail, 1, j_Space - 1 ) )
          v_String-Tail = trim( substring( v_String-Tail,    j_Space     ) )
        .
      end.
      find first tt-param-pump where
                 tt-param-pump.strfrfile = trim( entry( 1, v_Param, '=' ) ) no-error .
      if not available tt-param-pump then do:
         vErrorText = 'Обнаружен неизвестный параметр'.
        if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
        output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText ': ' v_Param ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
      end.
      else do:
        assign
          tt-param-pump.meaning = trim( entry( 2, v_Param, '=' ) )
        .
      end.
    end.
    find first tt-param-pump where
               tt-param-pump.strfrfile = 'PUMP' .
    if       tt-param-pump.meaning   = ?    or
       trim( tt-param-pump.meaning ) = '':U
    then do:
      vErrorText = 'Неизвестный код ТРК'.
      if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
      output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText ': ' tt-param-pump.meaning ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .                     next main-cycle.
    end.
    assign
      j_pump-code = integer( tt-param-pump.meaning )
    .
    find first tt-param-pump where
               tt-param-pump.strfrfile = 'NZL' .
    if       tt-param-pump.meaning   = ?    or
       trim( tt-param-pump.meaning ) = '':U
    then do:
      vErrorText = 'Неизвестный код пистолета ТРК'.
      if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
      output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText ': ' tt-param-pump.meaning ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .                     next main-cycle.
    end.
    assign
      j_nozzle-code = integer( tt-param-pump.meaning )
    .
    find first tt-param-pump where
               tt-param-pump.strfrfile = 'STATUS' .
    if integer( tt-param-pump.meaning ) <> 0 then do:
     vErrorText = if integer(tt-param-pump.meaning) eq 10
                   then "При получении данных со счетчиков ТРК возникла ошибка status 10 Не могу прочитать обьем"
                   else if integer(tt-param-pump.meaning) eq 20
                   then "При получении данных со счетчиков ТРК возникла ошибка status 20 Не могу прочитать колличество"
                   else if integer(tt-param-pump.meaning) eq 40
                   then "При получении данных со счетчиков ТРК возникла ошибка status 40 Не могу прочитать колличество транзакций"
                   else if integer(tt-param-pump.meaning) eq 70
                   then "При получении данных со счетчиков ТРК возникла ошибка несоответствия ТРК-ПИСТОЛЕТ-ТОПЛИВО либо отсутствует связь с одной или более ТРК."
                   else if integer(tt-param-pump.meaning) eq 73
                   then "Не удалось получить данные по счетчикам ТРК. Необходима проверка состояния/связи с ТРК."
                   else if integer(tt-param-pump.meaning) eq 3
                   then "При получении данных со счетчиков ТРК возникла ошибка несоответствия ТРК-ПИСТОЛЕТ-ТОПЛИВО. Возможна некорректная привязка топлива к пистолету на стороне кассы."
                   else 'Ошибка при чтении данных с ТРК(статус из поля status) ' + string(tt-param-pump.meaning).
      if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
      output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .                     next main-cycle.
    end.
    find first tt-param-pump where
               tt-param-pump.strfrfile = 'GRADE' .
    if       tt-param-pump.meaning   = ?    or
       trim( tt-param-pump.meaning ) = '':U
    then do:
      if p-check-goods = yes then do:
       vErrorText = 'Неизвестный топливный код товара '.
      if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
      output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText ': ' tt-param-pump.meaning ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .                     next main-cycle.
      end.
      else do:
        assign
          j_gds-code = ?
        .
        vErrorText = 'Неизвестный топливный код товара'.
        if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
        output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText  ': ' tt-param-pump.meaning ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
      end.
    end.
    else do:
      if integer( tt-param-pump.meaning ) = 0 then do:
        assign
          j_gds-code = ?
        .
      end.
      else do:
        assign
          j_b-code = ?
          d_rate   = ?
        .
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  p-parent-proc
,input  tt-param-pump.meaning
,input  ?
,input  p-obj-type
,input  p-obj-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output v_result
,output v_type-bc
,output d_weight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
        if error-status :error then do:
          if p-message-on = yes then do:
            return error 'Ошибка при разборе бар-кода' .
          end.
          else do:
            message 'Ошибка при разборе бар-кода' view-as alert-box.
            return error .
          end.
        end.
        if not available ub.bar-code then do:
          assign
            j_b-code = ?
          .
        end.
        else do:
          assign
            j_b-code = ub.bar-code.b-code
            d_rate   = ub.bar-code.cli-base-rate
          .
        end.
        if j_b-code = ? then do:
          if p-check-goods = yes then do:
            vErrorText = 'Невозможно определить основной бар-код по топливному коду'.
            if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
            output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText  ': ' tt-param-pump.meaning
            ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .                     next main-cycle.
          end.
          else do:
            assign
              j_gds-code = ?
            .
            vErrorText = 'Невозможно определить основной бар-код по топливному коду'.
            if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
            output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' vErrorText ': ' tt-param-pump.meaning
            ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
          end.
        end.
        else do:
          if d_rate <> 1.00 then do:
            vErrorText = 'Некорректный курс основного бар-кода'.
            if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
            output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' '
              'Замечание(cтрока обработана) . Некорректный курс: ' d_rate ' основного бар-кода: ' j_b-code
            ' в строке: ' v_String-Temp                     skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
          end.
          find first bf_bar-code no-lock
            where bf_bar-code.b-code = j_b-code
            .
          find first bf_goods no-lock
            where bf_goods.gds-code  = bf_bar-code.gds-code
            .
          assign
            j_gds-code = bf_goods.gds-code
          .
        end.
      end.
    end.
    create tt-pump-nozzle-file.
    assign
           tt-pump-nozzle-file.obj-type    = p-obj-type
           tt-pump-nozzle-file.obj-code    = p-obj-code
           tt-pump-nozzle-file.pump-code   = j_pump-code
           tt-pump-nozzle-file.nozzle-code = j_nozzle-code
           tt-pump-nozzle-file.gds-code    = j_gds-code
    .
    find first tt-param-pump where
               tt-param-pump.strfrfile = 'VOL' .
    assign
      tt-pump-nozzle-file.meas-el-cnt = decimal( tt-param-pump.meaning )
    no-error .
    if error-status:error
    then do :
      find first tt-pump-nozzle where
               tt-pump-nozzle.obj-type    = tt-pump-nozzle-file.obj-type    and
               tt-pump-nozzle.obj-code    = tt-pump-nozzle-file.obj-code    and
               tt-pump-nozzle.pump-code   = tt-pump-nozzle-file.pump-code   and
               tt-pump-nozzle.nozzle-code = tt-pump-nozzle-file.nozzle-code no-error .
      if not available tt-pump-nozzle
      then do:
        delete tt-pump-nozzle-file .
        next main-cycle .
      end .
      else do :
        return error return-value .
      end .
    end .
    find first tt-param-pump where
               tt-param-pump.strfrfile = 'VAL' .
    assign
      tt-pump-nozzle-file.meas-am-cnt = decimal( tt-param-pump.meaning )
    no-error .
    if error-status:error
    then do :
      find first tt-pump-nozzle where
               tt-pump-nozzle.obj-type    = tt-pump-nozzle-file.obj-type    and
               tt-pump-nozzle.obj-code    = tt-pump-nozzle-file.obj-code    and
               tt-pump-nozzle.pump-code   = tt-pump-nozzle-file.pump-code   and
               tt-pump-nozzle.nozzle-code = tt-pump-nozzle-file.nozzle-code no-error .
      if not available tt-pump-nozzle
      then do:
        delete tt-pump-nozzle-file .
        next main-cycle .
      end .
      else do :
        return error return-value .
      end .
    end .
    find first tt-param-pump where
               tt-param-pump.strfrfile = 'CNT' .
    assign
      tt-pump-nozzle-file.meas-cf-cnt = decimal( tt-param-pump.meaning )
    no-error .
    if error-status:error
    then do :
      find first tt-pump-nozzle where
               tt-pump-nozzle.obj-type    = tt-pump-nozzle-file.obj-type    and
               tt-pump-nozzle.obj-code    = tt-pump-nozzle-file.obj-code    and
               tt-pump-nozzle.pump-code   = tt-pump-nozzle-file.pump-code   and
               tt-pump-nozzle.nozzle-code = tt-pump-nozzle-file.nozzle-code no-error .
      if not available tt-pump-nozzle
      then do:
        delete tt-pump-nozzle-file .
        next main-cycle .
      end .
      else do :
        return error return-value .
      end .
    end .
  end.
  for each tt-pump-nozzle-file :
    find first tt-pump-nozzle where
               tt-pump-nozzle.obj-type    = tt-pump-nozzle-file.obj-type    and
               tt-pump-nozzle.obj-code    = tt-pump-nozzle-file.obj-code    and
               tt-pump-nozzle.pump-code   = tt-pump-nozzle-file.pump-code   and
               tt-pump-nozzle.nozzle-code = tt-pump-nozzle-file.nozzle-code no-error .
    if not available tt-pump-nozzle then do:
      vErrorText = 'Нет связки ТРК и пистолета в конфигурации объекта '.
      if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
      output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' '
              'Замечание(cтрока обработана) . ' vErrorText
        'Из файла получены данные по ТРК ' + string( tt-pump-nozzle-file.pump-code   ) +
        ' и пистолету '                    + string( tt-pump-nozzle-file.nozzle-code ) +
        ' на объекте '                     +         tt-pump-nozzle-file.obj-type      + ' ':U
                                           + string( tt-pump-nozzle-file.obj-code    ) +
        ' которого нет в конфигурации.'
      skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
      delete tt-pump-nozzle-file.
    end.
    else do:
      if tt-pump-nozzle-file.gds-code <> tt-pump-nozzle.gds-code then do:
        if tt-pump-nozzle-file.gds-code <> ? then do:
          find first bf_goods-file no-lock where
                     bf_goods-file.gds-code = tt-pump-nozzle-file.gds-code .
        end.
        if tt-pump-nozzle.gds-code <> ? then do:
          find first bf_goods no-lock where
                     bf_goods.gds-code = tt-pump-nozzle.gds-code .
        end.
        vErrorText = 'Данные по ТРК и пистолету не правильная конфигурация' .
        if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
        output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' '
          'Из файла получены данные по ТРК ' + string( tt-pump-nozzle-file.pump-code   ) +
          ' пистолету '                      + string( tt-pump-nozzle-file.nozzle-code ) +
          ( if tt-pump-nozzle-file.gds-code = ? then ' c неопределенным кодом товара'
                                                else ' товар ' +
                                               string( bf_goods-file.artic             ) + ' ':U +
                                               string( bf_goods-file.prod-type         ) + ' ':U +
                                               string( bf_goods-file.prod-code         ) )       +
          ' на объекте '                     + string( tt-pump-nozzle-file.obj-type    ) + ' ':U +
                                               string( tt-pump-nozzle-file.obj-code    ) +
          ' для которых не совпадает конфигурация товара по системе: '                   +
          ( if tt-pump-nozzle.gds-code = ? then ' по системе нет связи с товаром '
                                           else ' товар ' +
                                               string( bf_goods.artic                  ) + ' ':U +
                                               string( bf_goods.prod-type              ) + ' ':U +
                                               string( bf_goods.prod-code              ) )
        skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
        if p-check-goods = yes then do:
          assign
            is_FatalError = yes
          .
        end.
      end.
    end.
  end.
  for each tt-pump-nozzle :
    find first tt-pump-nozzle-file where
               tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
               tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
               tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
               tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code no-error .
    if not available tt-pump-nozzle-file then do:
      assign
        is_FatalError = yes
      .
      vErrorText = 'Не по всем ТРК и пистолетам получены данные' .
      if lookup (vErrortext,vErrorList,chr(4)) eq 0 then vErrorList = vErrorList + chr(4) + vErrorText.
      output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' '
        'Не получены данные по ТРК ' + string( tt-pump-nozzle.pump-code   ) +
        ' и пистолету '             + string( tt-pump-nozzle.nozzle-code ) +
        ' на объекте '              +         tt-pump-nozzle.obj-type      +
        ' ':U                       + string( tt-pump-nozzle.obj-code    ) +
        ' по конфигурации.'
      skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
    end.
  end.
  if is_FatalError = yes then do:
    if session:debug-alert
    then do:
       output stream str-err to value( v_File-Err ) append.                    put stream str-err unformatted cur-time-string-sec() ' ' "Ошибки при данном запросе :" replace(vErrorList,chr(4),chr(13) + chr(10)) "<<<<"
       skip .                     output stream str-err close.                    assign                       is_Error = yes                     .
    end.
    define variable Vtext as character no-undo.
    Vtext =
                 (if num-entries(vErrorList,chr(4)) > 3 then "" else replace(vErrorList,chr(4),chr(13) + chr(10)) + chr(13) + chr(10)) +
                 (if session:debug-alert
                  then 'Log-файл с описанием ошибок ' + v_File-Err + "."
                  else '' )+ 'Повторите попытку или обратитесь в техническую поддержку.'
                 .
    if p-message-on = ?
    then do :
      return .
    end .
    else do :
      return error vtext.
    end .
  end.
  for each tt-pump-nozzle :
    find first tt-pump-nozzle-file where
               tt-pump-nozzle-file.obj-type    = tt-pump-nozzle.obj-type    and
               tt-pump-nozzle-file.obj-code    = tt-pump-nozzle.obj-code    and
               tt-pump-nozzle-file.pump-code   = tt-pump-nozzle.pump-code   and
               tt-pump-nozzle-file.nozzle-code = tt-pump-nozzle.nozzle-code .
    assign
      tt-pump-nozzle.meas-el-cnt = tt-pump-nozzle-file.meas-el-cnt
      tt-pump-nozzle.meas-am-cnt = tt-pump-nozzle-file.meas-am-cnt
      tt-pump-nozzle.meas-cf-cnt = tt-pump-nozzle-file.meas-cf-cnt
    .
  end.
  if is_Error = yes then do:
    return 'Во время загрузки файла были ошибки. Log-файл с описанием ошибок ' + v_File-Err + ' .' +
           'Сверка создана, но не содержит полной информации. Обратитесь в техподдержку для закрытия сверки или для включения измерения по связке, в случае исправности ТРК.' .
  end.
  return .
end procedure.
procedure lib-rvs_rvsclchd :
  define input parameter p-rec-rvs-doc as recid   no-undo.
  define input parameter p-recalc-line as logical no-undo.
  define buffer bf_rvs-doc  for ub.rvs-doc.
  define buffer bf_rvs-line for ub.rvs-line.
  tr:
  do transaction
  on error undo tr, return error
  on stop  undo tr, return error
  on quit  undo tr, return error
  :
    find first bf_rvs-doc
      where recid( bf_rvs-doc ) = p-rec-rvs-doc
    .
    for each bf_rvs-line
      where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
        and bf_rvs-line.obj-type = bf_rvs-doc.obj-type
        and bf_rvs-line.obj-code = bf_rvs-doc.obj-code
    on error undo, return error return-value
    :
      if p-recalc-line = yes then do:
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclcln in g#lib-rvs ( input recid( bf_rvs-line ) ) no-error .
         if error-status :error then do:
           undo tr, return error substitute( 'Ошибка при расчете строки (место: &2, код товара: &3) сверки "&1".&4&5&4&6'
                                           , bf_rvs-doc.rvs-code
                                           , bf_rvs-line.pl-code
                                           , bf_rvs-line.gds-code
                                           , chr(10)
                                           , error-status :get-message( 1 )
                                           , return-value ) .
         end.
      end.
      accumulate
        bf_rvs-line.measure-qnty ( total )
        bf_rvs-line.brutto-qnty ( total )
        bf_rvs-line.measure-cli-qnty ( total )
        bf_rvs-line.brutto-cli-qnty ( total )
        bf_rvs-line.level-total ( total )
        bf_rvs-line.level-petrol ( total )
        bf_rvs-line.level-water ( total )
        bf_rvs-line.state-measure-qnty ( total )
        bf_rvs-line.state-brutto-qnty ( total )
        bf_rvs-line.state-measure-cli-qnty ( total )
        bf_rvs-line.state-brutto-cli-qnty ( total )
        bf_rvs-line.state-level-total ( total )
        bf_rvs-line.state-level-petrol ( total )
        bf_rvs-line.state-level-water ( total )
        bf_rvs-line.meas-am-qnty ( total )
        bf_rvs-line.meas-mh-qnty ( total )
        bf_rvs-line.meas-cf-qnty ( total )
        bf_rvs-line.state-am-qnty ( total )
        bf_rvs-line.state-cf-qnty ( total )
        bf_rvs-line.state-mh-qnty ( total )
        bf_rvs-line.system-qnty ( total )
        bf_rvs-line.system-cli-qnty ( total )
        bf_rvs-line.add-qnty ( total )
        bf_rvs-line.state-add-qnty ( total )
        bf_rvs-line.system-cli-avrg-qnty ( total )
        bf_rvs-line.measure-tc-qnty ( total )
        bf_rvs-line.brutto-tc-qnty ( total )
      .
    end.
    assign
       bf_rvs-doc.measure-qnty = ( accum total bf_rvs-line.measure-qnty )
       bf_rvs-doc.brutto-qnty = ( accum total bf_rvs-line.brutto-qnty )
       bf_rvs-doc.measure-cli-qnty = ( accum total bf_rvs-line.measure-cli-qnty )
       bf_rvs-doc.brutto-cli-qnty = ( accum total bf_rvs-line.brutto-cli-qnty )
       bf_rvs-doc.level-total = ( accum total bf_rvs-line.level-total )
       bf_rvs-doc.level-petrol = ( accum total bf_rvs-line.level-petrol )
       bf_rvs-doc.level-water = ( accum total bf_rvs-line.level-water )
       bf_rvs-doc.state-measure-qnty = ( accum total bf_rvs-line.state-measure-qnty )
       bf_rvs-doc.state-brutto-qnty = ( accum total bf_rvs-line.state-brutto-qnty )
       bf_rvs-doc.state-measure-cli-qnty = ( accum total bf_rvs-line.state-measure-cli-qnty )
       bf_rvs-doc.state-brutto-cli-qnty = ( accum total bf_rvs-line.state-brutto-cli-qnty )
       bf_rvs-doc.state-level-total = ( accum total bf_rvs-line.state-level-total )
       bf_rvs-doc.state-level-petrol = ( accum total bf_rvs-line.state-level-petrol )
       bf_rvs-doc.state-level-water = ( accum total bf_rvs-line.state-level-water )
       bf_rvs-doc.meas-am-qnty = ( accum total bf_rvs-line.meas-am-qnty )
       bf_rvs-doc.meas-mh-qnty = ( accum total bf_rvs-line.meas-mh-qnty )
       bf_rvs-doc.meas-cf-qnty = ( accum total bf_rvs-line.meas-cf-qnty )
       bf_rvs-doc.state-am-qnty = ( accum total bf_rvs-line.state-am-qnty )
       bf_rvs-doc.state-cf-qnty = ( accum total bf_rvs-line.state-cf-qnty )
       bf_rvs-doc.state-mh-qnty = ( accum total bf_rvs-line.state-mh-qnty )
       bf_rvs-doc.system-qnty = ( accum total bf_rvs-line.system-qnty )
       bf_rvs-doc.system-cli-qnty = ( accum total bf_rvs-line.system-cli-qnty )
       bf_rvs-doc.add-qnty = ( accum total bf_rvs-line.add-qnty )
       bf_rvs-doc.state-add-qnty = ( accum total bf_rvs-line.state-add-qnty )
       bf_rvs-doc.system-cli-avrg-qnty = ( accum total bf_rvs-line.system-cli-avrg-qnty )
       bf_rvs-doc.measure-tc-qnty = ( accum total bf_rvs-line.measure-tc-qnty )
       bf_rvs-doc.brutto-tc-qnty = ( accum total bf_rvs-line.brutto-tc-qnty )
    .
  end.
  return .
end procedure.
procedure lib-rvs_rvsclcln :
  define input parameter p-rec-id as recid no-undo.
  define buffer bf_rvs-line      for ub.rvs-line.
  define buffer bf_rvs-line-pump for ub.rvs-line-pump.
  define buffer bf_goods for ub.goods.
  find first bf_rvs-line
    where recid( bf_rvs-line ) = p-rec-id
  .
  for each bf_rvs-line-pump
    where bf_rvs-line-pump.rvs-code = bf_rvs-line.rvs-code
      and bf_rvs-line-pump.obj-type = bf_rvs-line.obj-type
      and bf_rvs-line-pump.obj-code = bf_rvs-line.obj-code
      and bf_rvs-line-pump.pl-code  = bf_rvs-line.pl-code
      and bf_rvs-line-pump.gds-code = bf_rvs-line.gds-code
  on error undo, return error return-value
  :
    accumulate
      bf_rvs-line-pump.meas-am-qnty ( total )
      bf_rvs-line-pump.meas-cf-qnty ( total )
      bf_rvs-line-pump.meas-mh-qnty ( total )
      bf_rvs-line-pump.state-am-qnty ( total )
      bf_rvs-line-pump.state-cf-qnty ( total )
      bf_rvs-line-pump.state-mh-qnty ( total )
    .
  end.
  assign
    bf_rvs-line.meas-am-qnty = ( accum total bf_rvs-line-pump.meas-am-qnty )
    bf_rvs-line.meas-cf-qnty = ( accum total bf_rvs-line-pump.meas-cf-qnty )
    bf_rvs-line.meas-mh-qnty = ( accum total bf_rvs-line-pump.meas-mh-qnty )
    bf_rvs-line.state-am-qnty = ( accum total bf_rvs-line-pump.state-am-qnty )
    bf_rvs-line.state-cf-qnty = ( accum total bf_rvs-line-pump.state-cf-qnty )
    bf_rvs-line.state-mh-qnty = ( accum total bf_rvs-line-pump.state-mh-qnty )
  .
  define variable is-vir as logical no-undo.
  define variable v-value as character no-undo.
  define variable v-ok as logical no-undo.
  run placelib_get-attr(input "place-virtual"
                       ,input bf_rvs-line.obj-code
                       ,input bf_rvs-line.obj-type
                       ,input bf_rvs-line.pl-code
                       ,output v-value
                       ,output v-ok) no-error.
  is-vir = if (v-ok and logical(v-value)) then true else false.
  if is-vir then do:
    if bf_rvs-line.system-cli-qnty <> 0 and bf_rvs-line.system-qnty <> 0 then
        bf_rvs-line.state-density = bf_rvs-line.system-cli-qnty / (bf_rvs-line.system-qnty).
    else do:
      find first bf_goods where bf_goods.gds-code = bf_rvs-line.gds-code no-lock.
      bf_rvs-line.state-density = 1 / bf_goods.cli-base-rate.
    end.
  end.
  return .
end procedure.
procedure lib-rvs_hstc-rvs :
  define parameter buffer buf_rvs-doc for  ub.rvs-doc .
  define input  parameter p-action    like ub.c-rvs-doc.action no-undo.
  define input  parameter p-out-code  like ub.rvs-doc.out-code no-undo.
  define input  parameter parchip-num as   integer             no-undo.
  do
  on error undo, return error substitute( "&1 (hstc-rvs). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  :
    define buffer buf_doc-attr        for ub.doc-attr.
    define buffer buf_c-doc-attr      for ub.c-doc-attr.
    define buffer buf_rvs-line        for ub.rvs-line.
    define buffer buf_rvs-line-pump   for ub.rvs-line-pump.
    define buffer buf_c-rvs-doc       for ub.c-rvs-doc.
    define buffer buf_c-rvs-line      for ub.c-rvs-line.
    define buffer buf_c-rvs-line-pump for ub.c-rvs-line-pump.
    define variable v-date        as   date                    no-undo .
    define variable v-time        as   integer                 no-undo .
    define variable v-shift-on    as   logical                 no-undo .
    define variable v-shift-date  like ub.shift-obj.shift-date no-undo .
    define variable v-shift-num   like ub.shift-obj.shift-num  no-undo .
    define variable v-shift-name  like ub.shift-obj.shift-name no-undo.
    if not available buf_rvs-doc then do:
      undo, return error substitute( "&1 (hstc-rvs). Ошибка задания входных параметров. Отсутствует запись сверки по которой создается история", vss-workfile ) .
    end.
    if parchip-num = ?
      or parchip-num = 0
    then do:
      undo, return error substitute( "&1 (hstc-rvs). Ошибка задания входных параметров. Не указан номер щепки (chip-num)", vss-workfile ) .
    end.
    find first buf_c-rvs-doc no-lock
      where buf_c-rvs-doc.rvs-code = buf_rvs-doc.rvs-code
        and buf_c-rvs-doc.chip-num = parchip-num
      no-error .
    if available buf_c-rvs-doc then do:
      return.
    end.
    run cur-time in this-procedure
      ( output v-date
       ,output v-time
      ).
    assign
      v-shift-date = ?
      v-shift-num  = ?
      v-shift-name = ?
    .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_rvs-doc.obj-type
  ,input  buf_rvs-doc.obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  )  .
    if v-shift-on = yes then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_rvs-doc.obj-type
  ,input  buf_rvs-doc.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
    end.
    create buf_c-rvs-doc.
    buffer-copy buf_rvs-doc to buf_c-rvs-doc
      assign
        buf_c-rvs-doc.action           = p-action
        buf_c-rvs-doc.chip-num         = parchip-num
        buf_c-rvs-doc.corr-doc-code    = p-out-code
        buf_c-rvs-doc.corr-date        = v-date
        buf_c-rvs-doc.corr-time        = v-time
        buf_c-rvs-doc.corr-shift-date  = v-shift-date
        buf_c-rvs-doc.corr-shift-num   = v-shift-num
        buf_c-rvs-doc.corr-shift-name  = v-shift-name
        buf_c-rvs-doc.corr-user-name   = g#userid
        buf_c-rvs-doc.corr-user-db-num = g#db-num
    .
    for each buf_doc-attr
      where buf_doc-attr.doc-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      create buf_c-doc-attr.
      buffer-copy buf_doc-attr to buf_c-doc-attr
        assign
          buf_c-doc-attr.chip-num         = buf_c-rvs-doc.chip-num
          buf_c-doc-attr.corr-user-name   = buf_c-rvs-doc.corr-user-name
          buf_c-doc-attr.corr-user-db-num = buf_c-rvs-doc.corr-user-db-num
      .
    end.
    for each buf_rvs-line
      where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
    on error undo, return error return-value
    :
      create buf_c-rvs-line.
      buffer-copy buf_rvs-line to buf_c-rvs-line
        assign
          buf_c-rvs-line.chip-num         = buf_c-rvs-doc.chip-num
          buf_c-rvs-line.corr-user-db-num = buf_c-rvs-doc.corr-user-db-num
      .
    end.
    for each buf_rvs-line-pump where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code :
      create buf_c-rvs-line-pump.
      buffer-copy buf_rvs-line-pump to buf_c-rvs-line-pump
        assign
          buf_c-rvs-line-pump.chip-num         = buf_c-rvs-doc.chip-num
          buf_c-rvs-line-pump.corr-user-db-num = buf_c-rvs-doc.corr-user-db-num
      .
    end.
  end.
  return .
end procedure.
procedure creatett-meas-file:
   define input  parameter i-obj-type as character no-undo.
   define input  parameter i-obj-code as integer no-undo.
   define variable v-bhasi               as handle  no-undo .
   define variable v-fhasi               as handle  no-undo .
   define variable v-bh                as handle  no-undo .
   define variable v-fh                as handle  no-undo .
   define variable pl-twice-code       as character no-undo.
   define variable v-value             as character no-undo.
   define variable v-ok                as logical   no-undo.
   define variable vi                  as integer no-undo.
   define buffer bf_place for ub.place.
   block-Place:
   for each tt-place where not tt-place.is-error :
      pl-twice-code = "" .
      find first bf_place no-lock
         where bf_place.obj-type = i-obj-type
           and bf_place.obj-code = i-obj-code
           and bf_place.loc1     = tt-place.loc1
           and bf_place.status_ <> 'удал':U
      no-error.
      if not available bf_place
      then do:
         twice-code:
         for each  place where place.obj-code = i-obj-code
                           and place.obj-type = i-obj-type
                           and place.is-meas = yes
         no-lock:
            run placelib_get-attr  ( input "place-twice-code"
                                    ,input i-obj-code
                                    ,input i-obj-type
                                    ,input place.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok
            then
               pl-twice-code = v-value .
            if num-entries(pl-twice-code) > 1
            then do :
               do ii = 1 to num-entries(pl-twice-code) :
                  if trim( entry( ii, pl-twice-code ) ) = tt-place.loc1
                  then do :
                     pl-twice-code = trim( entry( ii, pl-twice-code ) ) .
                     leave twice-code.
                  end.
               end.
            end.
            else do :
               if pl-twice-code =  tt-place.loc1
               then
                  leave twice-code.
            end.
            pl-twice-code = "" .
         end.
         if pl-twice-code = ""
         then do:
            put stream str-err unformatted substitute( 'Не найден резервуар по системе с локальным кодом(коорд1) &1 .'
                                                      , tt-place.loc1 ) skip .
            next block-Place .
         end.
      end.
      if     pl-twice-code = ""
         and available bf_place
      then do:
         if bf_place.is-meas = no
         then do:
            put stream str-err unformatted substitute( 'Получены данные с приборов по резервуару &1 '
                      + 'с локальным кодом(коорд1) &2, определенного в системе как '
                      + 'неизмеряемый.'
                      , bf_place.pl-code
                      , tt-place.loc1 ) skip .
            next block-Place .
         end.
      end.
      if   pl-twice-code = ""
      then do:
         create tt-meas-file.
         assign
            tt-meas-file.obj-type = i-obj-type
            tt-meas-file.obj-code = i-obj-code
            tt-meas-file.pl-code  = bf_place.pl-code
            tt-meas-file.loc1     = bf_place.loc1
         .
      end.
      else do:
         create tt-meas-file.
         assign
            tt-meas-file.obj-type = i-obj-type
            tt-meas-file.obj-code = i-obj-code
            tt-meas-file.loc1     = pl-twice-code
         .
      end.
      v-bhasi = buffer tt-place:handle.
      v-bh = buffer tt-meas-file:handle.
      block-field:
      do vi = 1 to v-bhasi:num-fields:
         v-fhasi = v-bhasi:buffer-field(vi).
         find first tt-param where tt-param.strasi = v-fhasi:name no-error.
         if available tt-param
         then do:
            assign
               v-fh                = v-bh:buffer-field( tt-param.flddb )
               v-fh:buffer-value() = decimal( v-fhasi:buffer-value() )
            no-error.
            if error-status:error
            then
               next block-field.
            if v-fh:buffer-value() ne ?
            then do:
            if tt-param.strfrfile = 'temperature':U   then do:
              assign
                tt-meas-file.temp-not-null   = yes
              .
            end.
            if tt-param.strfrfile = 'temp-layer1':U   then do:
              assign
                tt-meas-file.t1-not-null   = yes
              .
            end.
            if tt-param.strfrfile = 'temp-layer2':U   then do:
              assign
                tt-meas-file.t2-not-null   = yes
              .
            end.
            if tt-param.strfrfile = 'temp-layer3':U   then do:
              assign
                tt-meas-file.t3-not-null   = yes
              .
            end.
            if tt-param.strfrfile = 'volume_oil':U   then do:
              assign
                tt-meas-file.meas-vol-oil   = yes
              .
            end.
            if tt-param.strfrfile = 'volume_water':U then do:
              assign
                tt-meas-file.meas-vol-water = yes
              .
            end.
            if tt-param.strfrfile = 'mass_total':U
            then do:
               if tt-meas-file.pl-code <> 0
               then do:
                  run placelib_get-attr  ( input "place-asi-sertif"
                                          ,input i-obj-code
                                          ,input i-obj-type
                                          ,input tt-meas-file.pl-code
                                          ,output v-value
                                          ,output v-ok      ) no-error.
               end.
               else do:
                  run placelib_get-attr  ( input "place-asi-sertif"
                                          ,input i-obj-code
                                          ,input i-obj-type
                                          ,input place.pl-code
                                          ,output v-value
                                          ,output v-ok      ) no-error.
               end.
               if v-ok and v-value = "yes"
               then do:
                  if     trim( v-fh:buffer-value() )  <> "-"
                     and trim( v-fh:buffer-value() )  <> ""
                  then do:
                     assign
                        tt-meas-file.log-brutto       = yes
                        tt-meas-file.measure-cli-qnty = decimal( trim( v-fh:buffer-value() ) )
                     .
                  end.
               end.
            end.
            end.
         end.
         else do:
         end .
      end.
   end.
end procedure.
PROCEDURE Sleep EXTERNAL "kernel32.DLL":
  DEFINE INPUT PARAMETER intMilliseconds AS LONG.
END PROCEDURE.
