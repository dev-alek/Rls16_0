block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-fbr-gds-grp-recid  as  recid no-undo.
define input parameter p-print-option       as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-gdsggr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-gdsggr.p $":U .
define variable vss-description as character no-undo init "Список групп блюд".
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
define new shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define new shared variable RepPathName        as character no-undo .
define new shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrglib_grp no-undo
    field sel           as character
    field full-name     as character
    field out-code      as integer
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field name          as character
    field level         as integer
    field mark          as character
    field obj-type      as character
    field obj-code      as integer
    field global-code   as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index nc is unique obj-type obj-code node-code
    index sl obj-type obj-code sel
    index uc obj-type obj-code upper-code
.
define temp-table temp_fbrglib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field obj-type      as character
    field obj-code      as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index lv obj-type obj-code level
    index it obj-type obj-code is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as integer
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure fbrglib-get-sort-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-obj-type
           and buf_fbr-gds-grp.obj-code  = p-obj-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if not available buf_fbr-gds-grp
    then do:
        undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while true
    on error undo, return error "fbrglib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_fbr-gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_fbr-gds-grp.upper-code
        .
        if buf_fbr-gds-grp.upper-code = 1
        then do:
            leave.
        end.
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
procedure fbrglib-get-full-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    if p-node-code = 1
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 1
        .
        do while true
        on error undo, return error "fbrglib-get-full-name: Ошибка составления полного имени группы"
        :
            assign
                p-full-name  = buf_fbr-gds-grp.node-name
                            + (if p-full-name <> "" then chr(47) else "")
                            + p-full-name
                v-upper-code = buf_fbr-gds-grp.upper-code
            .
            if buf_fbr-gds-grp.upper-code = 1
            then do:
                leave.
            end.
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = v-upper-code
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-node-code".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
procedure fbrglib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.upper-code = 0
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_fbr-gds-grp.node-code
        .
    end.
end.
end procedure.
procedure fbrglib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-obj-type     as character    no-undo.
define input parameter p-obj-code     as integer      no-undo.
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define variable v-node-name     as character      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run fbrglib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "fbrglib-find-grp-by-full-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_fbrglib_found-grp
    :
        delete temp_fbrglib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            assign
                v-node-name = entry( v-counter, p-search-name, chr(2) )
            .
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type   = p-obj-type
                   and buf_fbr-gds-grp.obj-code   = p-obj-code
                   and buf_fbr-gds-grp.upper-code = v-upper-code
                   and buf_fbr-gds-grp.node-name  = v-node-name
            no-error .
            if not available buf_fbr-gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(47) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_fbr-gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_fbr-gds-grp.node-name
                    v-upper-code = buf_fbr-gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name = v-full-name + chr(47)
                        temp_fbrglib_found-grp.sort-name = v-sort-name
                        temp_fbrglib_found-grp.node-code = v-upper-code
                        temp_fbrglib_found-grp.level     = v-counter
                        temp_fbrglib_found-grp.obj-type  = p-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-obj-code
                    .
                end.
            end.
        end.
        else do:
            for each buf_fbr-gds-grp no-lock
               where buf_fbr-gds-grp.obj-type   = p-obj-type
                 and buf_fbr-gds-grp.obj-code   = p-obj-code
                 and buf_fbr-gds-grp.upper-code = v-upper-code
                 and buf_fbr-gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_fbr-gds-grp.node-name
                    temp_fbrglib_found-grp.node-code = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.level     = v-level
                    temp_fbrglib_found-grp.obj-type  = p-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-obj-code
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_fbrglib_found-grp
                :
                    delete temp_fbrglib_found-grp.
                end.
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-full-name
    ).
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_fbr-gds-grp no-lock
           where buf_fbr-gds-grp.obj-type   = p-start-obj-type
             and buf_fbr-gds-grp.obj-code   = p-start-obj-code
             and buf_fbr-gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run fbrglib-is-terminal in this-procedure (
                  input buf_fbr-gds-grp.obj-type
                , input buf_fbr-gds-grp.obj-code
                , input buf_fbr-gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.is-terminal = yes
                    temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_fbr-gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                        temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                        temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                        temp_fbrglib_found-grp.is-terminal = no
                        temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-expand-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-start-name as character    no-undo.
define output parameter p-end-name  as character    no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_fbrglib_found-grp     for temp_fbrglib_found-grp.
    run fbrglib-find-grp-by-full-name in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-start-name
        , input no
    ) no-error.
    run fbrglib-get-max-substring in this-procedure (
           input p-obj-type
        ,  input p-obj-code
        ,  input length( p-start-name )
        , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_fbrglib_found-grp
             where temp_fbrglib_found-grp.full-name = p-end-name
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                     no-error.
        if available temp_fbrglib_found-grp
        then do:
            find first buf_temp_fbrglib_found-grp
                 where buf_temp_fbrglib_found-grp.full-name begins p-end-name
                   and recid( buf_temp_fbrglib_found-grp ) <> recid( temp_fbrglib_found-grp )
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
            no-error.
            if not available buf_temp_fbrglib_found-grp
            then do:
                run fbrglib-is-terminal in this-procedure (
                      input p-obj-type
                    , input p-obj-code
                    , input temp_fbrglib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-get-max-substring :
do
on error undo, return error
:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_fbrglib_found-grp  where
                   temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
        no-error.
        if not available temp_fbrglib_found-grp
        then do:
            undo, return error "fbrglib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_fbrglib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "fbrglib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_fbrglib_found-grp
                where temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_fbrglib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure fbrglib-is-terminal :
do
on error undo, return error "Ошибка процедуры fbrglib-is-terminal"
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type   = p-obj-type
           and buf_fbr-gds-grp.obj-code   = p-obj-code
           and buf_fbr-gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure fbrglib-have-goods :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-node-code          as integer      no-undo.
define output parameter p-have-fbr-gds-obj  as logical      no-undo.
    define buffer buf_fbr-gds-obj         for ub.fbr-gds-obj.
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type     = p-obj-type
           and buf_fbr-gds-obj.obj-code     = p-obj-code
           and buf_fbr-gds-obj.fbr-grp-code = p-node-code
    no-error .
    if available buf_fbr-gds-obj
    then do:
        assign
            p-have-fbr-gds-obj = yes
        .
    end.
    else do:
        assign
            p-have-fbr-gds-obj = no
        .
    end.
end.
end procedure.
procedure fbrglib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    search-grp:
    for each buf_fbr-gds-grp no-lock
        where buf_fbr-gds-grp.obj-type  = p-start-obj-type
          and buf_fbr-gds-grp.obj-code  = p-start-obj-code
          and buf_fbr-gds-grp.node-code > p-start-code
    :
        if index( buf_fbr-gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_fbr-gds-grp.node-code
                v-found      = yes
            .
            run fbrglib-get-full-name in this-procedure (
                  input p-start-obj-type
                , input p-start-obj-code
                , input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "fbrglib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure fbrglib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "fbrglib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
        end.
        if length( v-full-name ) + 1 + length( p-grp-name ) > 120
        then do:
            assign
                p-error-message = 'Полное название группы не может содержать более 120 символов.'
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-delete-grp :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-deleted   as logical      no-undo.
    define variable v-have-goods    as logical        no-undo.
    define variable v-yesno         as logical        no-undo.
    define variable v-upper-code    as integer        no-undo.
    define variable v-root-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj           for ub.fbr-gds-obj.
    define buffer buf_second_fbr-gds-grp    for ub.fbr-gds-grp.
    run fbrglib-get-root-code in this-procedure (
        output v-root-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "Не найден корневой узел." + chr(10) + return-value.
    end.
    if p-node-code = v-root-code
    then do:
        message
            "Корневую группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.upper-code   = p-node-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            "Не терминальную группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.node-code    = p-node-code
    .
    assign
        v-upper-code = buf_fbr-gds-grp.upper-code
    .
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ).
    if v-have-goods = yes
    then do:
        find first buf_second_fbr-gds-grp no-lock
             where buf_second_fbr-gds-grp.obj-type      = buf_fbr-gds-grp.obj-type
               and buf_second_fbr-gds-grp.obj-code      = buf_fbr-gds-grp.obj-code
               and buf_second_fbr-gds-grp.upper-code    = buf_fbr-gds-grp.upper-code
               and recid( buf_second_fbr-gds-grp )      <> recid( buf_fbr-gds-grp )
        no-error.
        if available buf_second_fbr-gds-grp
        then do:
            message
                "В группе есть товары,"
                skip "которые нельзя перенести в родительскую группу,"
                skip "потому что у родительской группы есть еще одна подгруппа."
                skip(1)
                skip "Перенесите товары в другую группу"
                skip "или удалите все остальные подгруппы родительской группы."
            view-as alert-box error.
            assign
                p-deleted = no
            .
            undo, return.
        end.
        message
            "В группе есть товары."
            skip "После удаления группы"
            skip "все ее товары будут привязаны"
            skip "к ее родительской группе."
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                for each buf_fbr-gds-obj exclusive-lock
                   where buf_fbr-gds-obj.obj-type     = p-obj-type
                     and buf_fbr-gds-obj.obj-code     = p-obj-code
                     and buf_fbr-gds-obj.fbr-grp-code = p-node-code
                on error undo, return error
                :
                    assign
                        buf_fbr-gds-obj.fbr-grp-code = v-upper-code
                    .
                end.
            end.
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error .
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
    else do:
        message
            "Имя группы: " buf_fbr-gds-grp.node-name
            "Код группы: " buf_fbr-gds-grp.node-code
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error.
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-add-grp :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define input parameter p-interface      as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-out-code       as integer      no-undo.
define input parameter p-global-code    as integer      no-undo.
define output parameter p-new-node-code as integer      no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-have-goods    as logical  no-undo.
    define variable v-host-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer bf_fbr-gds-grp        for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.upper-code = p-node-code
          AND buf_fbr-gds-grp.obj-type   = p-obj-type
          AND buf_fbr-gds-grp.obj-code   = p-obj-code
          AND buf_fbr-gds-grp.node-name  = p-node-name no-error .
    if available buf_fbr-gds-grp then do:
        if p-node-code <> 1 then do:
          find first buf_fbr-gds-grp no-lock where
                    buf_fbr-gds-grp.node-code = p-node-code
                AND buf_fbr-gds-grp.obj-type   = p-obj-type
                AND buf_fbr-gds-grp.obj-code   = p-obj-code  .
        end.
                message
        "Для объекта" p-obj-type p-obj-code
        "уже есть группа блюд" p-node-name "в подгруппе" (if p-node-code = 1 then "БЛЮДА" else buf_Fbr-gds-grp.node-name)
        view-as alert-box error .
        undo, return error .
    end.
    do transaction
    on error undo, return error
    :
        create buf_fbr-gds-grp.
        assign
            buf_fbr-gds-grp.node-code   = next-value( s-gds-grp, ub )
            p-new-node-code             = buf_fbr-gds-grp.node-code
            buf_fbr-gds-grp.upper-code  = p-node-code
            buf_fbr-gds-grp.host-code   = v-host-code
            buf_fbr-gds-grp.obj-type    = p-obj-type
            buf_fbr-gds-grp.obj-code    = p-obj-code
            buf_fbr-gds-grp.node-name    = ""
            buf_fbr-gds-grp.out-code    = 0
        .
        if p-interface then do:
          run ref/fbrggrpd.w (
                input parparentproc
              , input 'ИЗМЕНЕНИЕ':U
              , input p-obj-type
              , input p-obj-code
              , input buf_fbr-gds-grp.node-code
              , input buf_fbr-gds-grp.upper-code
              , input buf_fbr-gds-grp.node-name
              , input buf_fbr-gds-grp.out-code
              , output buf_fbr-gds-grp.node-name
              , output buf_fbr-gds-grp.out-code
              , output p-cancel
          ).
          if p-cancel = yes
          then do:
              delete buf_fbr-gds-grp.
              undo, return.
          end.
        end.
        else do:
          find first bf_fbr-gds-grp no-lock
              where bf_fbr-gds-grp.obj-type   = p-obj-type
                and bf_fbr-gds-grp.obj-code   = p-obj-code
                and bf_fbr-gds-grp.out-code   = p-out-code
          no-error.
          assign
          buf_fbr-gds-grp.node-name    = p-node-name
          buf_fbr-gds-grp.global-code  = p-global-code
          buf_fbr-gds-grp.out-code     = (if available bf_fbr-gds-grp then 0 else p-out-code)
          .
        end.
        if v-have-goods = yes
        then do:
            for each buf_fbr-gds-obj exclusive-lock
               where buf_fbr-gds-obj.obj-type      = p-obj-type
                 and buf_fbr-gds-obj.obj-code      = p-obj-code
                 and buf_fbr-gds-obj.fbr-grp-code  = p-node-code
            on error undo, return error
            :
                assign
                    buf_fbr-gds-obj.fbr-grp-code = p-new-node-code
                .
            end.
        end.
    end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
do
on error undo, return error
:
define temp-table temp_goods no-undo
    field gds-code  as integer
    field artic     as character
    field prod-type as character
    field prod-code as integer
    field full-grp-name  as character
    field gds-name  as character
    index pi    is primary unique gds-code
    index apc   is unique artic prod-type prod-code
    index grp full-grp-name
.
define variable grp-path    like clients.grp-name  no-undo.
define variable v-line              as character         no-undo.
define variable v-status            as character         no-undo.
define variable v-node-name         as character         no-undo.
define variable v-start-node-name   as character     no-undo.
define variable v-is-terminal       as logical       no-undo.
define variable sym1 as character  init ":"   no-undo.
define variable sym2 as character  init ":"   no-undo.
define variable sym3 as character  init ":"   no-undo.
define variable sym4 as character  init ":"   no-undo.
define variable i           as integer no-undo .
define variable v-gds-name  as character      no-undo.
define variable v-artic     as character      no-undo.
define buffer buf_start_fbr-gds-grp for fbr-gds-grp.
define buffer buf_fbr-gds-grp       for fbr-gds-grp.
define buffer buf_fbr-gds-obj       for fbr-gds-obj.
define buffer buf_goods             for goods.
define frame GdsListRpt
    sym1 column-label ":" format "x(1)"
    v-gds-name column-label "Наименование" format "x(50)"
    sym2 column-label ":" format "x(1)"
    v-artic column-label "Артикул" format "x(16)"
    sym3 column-label ":" format "x(1)"
    v-status column-label "Статус" format "x(5)"
    sym4 column-label ":" format "x(1)"
    header
        cur-time-print() at 5 format "X(35)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream )  , ">>>>9") ) at 54 format "X(17)" skip
        v-line format "X(82)" at 1
with width 235 down stream-io use-text .
define frame frmgrp
    v-node-name   format "X(130)"
    with width 160 down stream-io use-text no-labels no-box .
find first buf_start_fbr-gds-grp no-lock
     where recid( buf_start_fbr-gds-grp ) = p-fbr-gds-grp-recid
.
run fbrglib-get-full-name in this-procedure(
      input p-obj-type
    , input p-obj-code
    , input buf_start_fbr-gds-grp.node-code
    , output grp-path
).
if session :set-wait-state( "compiler" ) then.
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
assign
    v-line = fill( "-", 82 )
.
put stream PrnLibStream space(20) "СПИСОК  ГРУПП  БЛЮД." format "x(30)" skip(1).
form header
    v-line format "X(82)"
    skip "Продолжение - на следующей странице" at 30
    skip
with frame GdsBottomframe
width 235
page-bottom
no-labels
no-box
.
run fbrglib-find-all-subgroup in this-procedure (
      input p-obj-type
    , input p-obj-code
    , input buf_start_fbr-gds-grp.node-code
    , input no
).
if p-print-option = "terminal":U
then do:
    view stream PrnLibStream frame gdsbottomframe .
    run fbrglib-is-terminal in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input buf_start_fbr-gds-grp.node-code
        , output v-is-terminal
    ).
    if v-is-terminal = yes then do:
        put stream PrnLibStream
            space(2) string( "Группа: " + grp-path ) format "X(80)"
            skip
            v-line format "X(82)"
            skip
        .
        view stream PrnLibStream frame GdsListRpt.
        for each buf_fbr-gds-obj no-lock
           where buf_fbr-gds-obj.obj-type       = p-obj-type
             and buf_fbr-gds-obj.obj-code       = p-obj-code
             and buf_fbr-gds-obj.fbr-grp-code   = buf_start_fbr-gds-grp.node-code
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_fbr-gds-obj.gds-code
            .
            assign
                v-gds-name = buf_goods.gds-name
                v-artic    = buf_goods.artic
            .
            display stream PrnLibStream
                sym1 v-gds-name
                sym2 v-artic
                sym3 "УДАЛЕН" when buf_goods.stts <> 0      @ v-status
                sym4
            with frame GdsListRpt.
            down stream PrnLibStream 1 with frame GdsListRpt .
        end.
        put stream PrnLibStream
            v-line format "X(82)"
            skip
        .
    end.
    for each temp_fbrglib_found-grp
       where temp_fbrglib_found-grp.is-terminal = yes
    :
        down stream PrnLibStream 1 with frame GdsListRpt .
        put stream PrnLibStream
            space(2) string( "Группа: " + temp_fbrglib_found-grp.full-name ) format "X(80)"
            skip
            v-line format "X(82)"
            skip
        .
        for each buf_fbr-gds-obj no-lock
           where buf_fbr-gds-obj.obj-type       = p-obj-type
             and buf_fbr-gds-obj.obj-code       = p-obj-code
             and buf_fbr-gds-obj.fbr-grp-code   = temp_fbrglib_found-grp.node-code
        on error undo, return error
        :
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_fbr-gds-obj.gds-code
            .
            assign
                v-gds-name = buf_goods.gds-name
                v-artic    = buf_goods.artic
            .
            display stream PrnLibStream
                sym1 v-gds-name
                sym2 v-artic
                sym3 "УДАЛЕН" when buf_goods.stts <> 0      @ v-status
                sym4
            with frame GdsListRpt.
            down stream PrnLibStream 1 with frame GdsListRpt .
        end.
        put stream PrnLibStream
            v-line format "X(82)"
            skip
        .
    end.
    hide stream PrnLibStream frame GdsBottomframe .
    put stream PrnLibStream v-line format "X(82)" skip.
end.
else do:
    form with frame frmgrp .
    display stream PrnLibStream
    grp-path @ v-node-name
    with frame frmgrp .
    down stream PrnLibStream 1 with frame frmgrp .
    for each temp_fbrglib_found-grp
    :
        display stream PrnLibStream
            temp_fbrglib_found-grp.full-name     @ v-node-name
        with frame frmgrp .
        down stream PrnLibStream 1 with frame frmgrp .
    end.
    hide stream PrnLibStream frame GdsBottomframe .
end.
if session :set-wait-state( "" ) then.
output stream PrnLibStream close.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
end.
