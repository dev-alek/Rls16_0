block-level on error undo, throw.
define input parameter  p-db-num                like  ub.c-scales.db-num             no-undo .
define input parameter  p-scales-num              like  ub.c-scales.scales-num           no-undo .
define input parameter  p-attr-code             like  ub.c-scales.attr-code          no-undo .
define input parameter  p-corr-user-db-num      like  ub.c-scales.corr-user-db-num   no-undo .
define input parameter  p-chip-num              like  ub.c-scales.chip-num           no-undo .
define input parameter  p-subject               like  ub.c-scales.subject            no-undo .
define input parameter p-action   like ub.c-cli-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cscalv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cscalv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории весов".
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
procedure scl-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-label = "Веса и коды тары"     p-type = 'C':U      p-format = "X(32)"     p-label = "Веса и коды тары"     p-user-can-edit  = yes     p-output-display = true     p-other = 'scl=TIGER,MIRA,TIGER2,TIGER-SPCT2/spr=scl-attr-tare-weight':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут весов" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure scl-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-tooltip = "Веса и коды тары"     p-label = "Веса и коды тары" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут весов" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure scl-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num   like ub.scales-attr.db-num        no-undo .
    define input  parameter p-scales-num like ub.scales-attr.scales-num      no-undo .
    define input  parameter p-code     like ub.scales-attr.attr-code      no-undo .
    define output parameter p-value    like ub.scales-attr.attr-value    no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr no-lock
      where buf_scales-attr.db-num    = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if avail buf_scales-attr then do:
      assign
        p-value =  buf_scales-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure scl-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define input parameter p-value    like ub.scales-attr.attr-value no-undo .
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if not available buf_scales-attr then do:
      create buf_scales-attr .
      assign
        buf_scales-attr.db-num    = p-db-num
        buf_scales-attr.scales-num  = p-scales-num
        buf_scales-attr.attr-code = p-code
      .
    end.
    assign
      buf_scales-attr.attr-value = p-value
    .
    release buf_scales-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure scl-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error .
    if  available buf_scales-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure scl-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.scales-attr.db-num     no-undo .
    define input parameter p-scales-num like ub.scales-attr.scales-num   no-undo .
    define input parameter p-code     like ub.scales-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_scales-attr for ub.scales-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run scl-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_scales-attr exclusive-lock
      where buf_scales-attr.db-num  = p-db-num
        and buf_scales-attr.scales-num  = p-scales-num
        and buf_scales-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_scales-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_scales-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure scl-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-news = yes.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure scl-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'tare-weight':U then do:     assign     p-hist = yes.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-scales for ub.c-scales.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
if p-action = integer('99':U) then return.
find first buf_c-scales no-lock where
          buf_c-scales.db-num   = p-db-num
      AND buf_c-scales.scales-num = p-scales-num
      AND buf_c-scales.chip-num = p-chip-num
      AND buf_c-scales.corr-user-db-num = p-corr-user-db-num   no-error .
if not available buf_c-scales then do:
  return error .
end.
CASE p-subject:
  when 'scales':U or when "":U then do:
    run scales-proc in this-procedure(output p-description) no-error .
  end.
  when 'scales-attr':U then do:
    run scales-attr-proc in this-procedure(output p-description) no-error .
  end.
  when 'scales-grp':U then do:
    run scales-grp-proc in this-procedure(output p-description) no-error .
  end.
  when 'scales-gds':U then do:
    run scales-gds-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure scales-proc :
define output parameter p-description as character no-undo .
define buffer current_c-scales for ub.c-scales  .
  do
  on error undo, return error
  :
    find first current_c-scales no-lock where
               current_c-scales.db-num   = p-db-num
           AND current_c-scales.scales-num = p-scales-num
           AND current_c-scales.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales.chip-num = p-chip-num
           no-error .
    if not avail current_c-scales then do:
       v-mess = "Неверная ссылка на c-scales в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "address" + chr(4) + "Адрес" + chr(4) + "" + chr(8)
 + "master" + chr(4) + "Главные весы" + chr(4) + "" + chr(8)
 + "max-gds" + chr(4) + "Максимальная номенклатура" + chr(4) + "" + chr(8)
 + "max-plu" + chr(4) + "Макс. PLU в тек.момент" + chr(4) + "" + chr(8)
 + "unit-base" + chr(4) + "Ед.изм" + chr(4) + "" + chr(8)
 + "scales-type" + chr(4) + "Тип" + chr(4) + "" + chr(8)
 + "scales-name" + chr(4) + "Название" + chr(4) + "" + chr(8)
 + "scales-num" + chr(4) + "Номер весов" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "БД" + chr(4) + "" + chr(8)
 + "remote" + chr(4) + "Удаленные" + chr(4) + "" + chr(8)
 + "to-send" + chr(4) + "Требуют обновления" + chr(4) + "" + chr(8)
 + "tot-gds" + chr(4) + "Кол-во PLU" + chr(4) + ""
   .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer('1':U))
                                            ,input  (buf_c-scales.action = integer('99':U))
                                            ,input  buffer current_c-scales:handle
                                            ,input  'scales':U
                                            ,input  "address,master,max-gds,unit-base,scales-type,scales-name,scales-num,db-num,remote,to-send,tot-gds"
                                            ,input  v-label-param).
end.
end procedure.
procedure scales-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-scales-attr for ub.c-scales-attr  .
  do
  on error undo, return error
  :
    find first current_c-scales-attr no-lock where
               current_c-scales-attr.db-num   = p-db-num
           AND current_c-scales-attr.scales-num = p-scales-num
           AND current_c-scales-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales-attr.chip-num = p-chip-num
           AND current_c-scales-attr.attr-code  = buf_c-scales.attr-code
           no-error .
    if not avail current_c-scales-attr then do:
       v-mess = "Неверная ссылка на c-scales-attr в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
    run scl-attr-tooltip in this-procedure (
                input  current_c-scales-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "" + chr(8)
 + "scales-num" + chr(4) + "Номер весов" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "БД" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer('1':U))
                                            ,input  (buf_c-scales.action = integer('99':U))
                                            ,input  buffer current_c-scales-attr:handle
                                            ,input  'scales-attr':U
                                            ,input  "attr-value,scales-num,db-num"
                                            ,input  v-label-param).
end.
end procedure.
procedure scales-grp-proc :
define output parameter p-description as character no-undo .
define buffer current_c-scales-grp for ub.c-scales-grp  .
  do
  on error undo, return error
  :
    find first current_c-scales-grp no-lock where
               current_c-scales-grp.db-num   = p-db-num
           AND current_c-scales-grp.scales-num = p-scales-num
           AND current_c-scales-grp.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales-grp.chip-num = p-chip-num
           AND current_c-scales-grp.node-code  = buf_c-scales.node-code
           no-error .
    if not avail current_c-scales-grp then do:
       v-mess = "Неверная ссылка на c-scales-grp в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "node-code" + chr(4) + "Код группы" + chr(4) + "" + chr(8)
 + "scales-num" + chr(4) + "Номер весов" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "БД" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer('1':U))
                                            ,input  (buf_c-scales.action = integer('99':U))
                                            ,input  buffer current_c-scales-grp:handle
                                            ,input  'scales-grp':U
                                            ,input  "node-code,scales-num,db-num"
                                            ,input  v-label-param).
end.
end procedure.
procedure scales-gds-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .
define buffer current_scales-gds for ub.scales-gds  .
define buffer current_c-scales-gds for ub.c-scales-gds  .
define buffer new_c-scales-gds for ub.c-scales-gds  .
  do
  on error undo, return error
  :
    find first current_c-scales-gds no-lock where
               current_c-scales-gds.db-num   = p-db-num
           AND current_c-scales-gds.scales-num = p-scales-num
           AND current_c-scales-gds.corr-user-db-num = p-corr-user-db-num
           AND current_c-scales-gds.chip-num = p-chip-num
           AND current_c-scales-gds.PLU-code  = buf_c-scales.PLU-code
           no-error .
    if not avail current_c-scales-gds then do:
       v-mess = "Неверная ссылка на c-scales-gds в таблице c-scales".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "b-code" + chr(4) + "Бар-код" + chr(4) + "" + chr(8)
 + "db-num" + chr(4) + "Номер БД" + chr(4) + "" + chr(8)
 + "deadline" + chr(4) + "Срок хранения" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "PLU-code" + chr(4) + "Код PLU" + chr(4) + "" + chr(8)
 + "scales-num" + chr(4) + "Номер весов" + chr(4) + "" + chr(8)
 + "to-del" + chr(4) + "Удаление с весов" + chr(4) + "" + chr(8)
 + "to-send" + chr(4) + "Требует обновления" + chr(4) + "" + chr(8)
 + "wt-cart" + chr(4) + "Вес упаковки" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-scales.action = integer('1':U))
                                            ,input  (buf_c-scales.action = integer('99':U))
                                            ,input  buffer current_c-scales-gds:handle
                                            ,input  'scales-gds':U
                                            ,input  "b-code,db-num,deadline,obj-code,obj-type,PLU-code,scales-num,to-del,to-send,wt-cart"
                                            ,input  v-label-param).
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("История весов  БД&1 весы №2: щепка &3 Предмет изменений &4&5&6"
                        ,p-db-num
                        ,p-scales-num
                        ,p-chip-num
                        ,p-subject
                        ,chr(10)
                        ,p-mess
                        ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
