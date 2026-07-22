define input parameter parparentproc    as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт карточек товаров".
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_goods no-undo
    field rec-no            as integer
    field gds-code          as integer
    field artic             as character
    field prod-code         as integer
    field grp-code          as integer
    field unit-base         as character
    field unit-base-type    as character
    field gds-type          as character
    field gds-name          as character
    field engl-name         as character
    field VAT-pc            as decimal
    field SLT-pc            as decimal
    field deadline          as integer
    index pi is primary unique rec-no
    index gc gds-code
.
define temp-table temp_tax no-undo
    field tax-code      as integer
    field rate-code     as integer
    field rate-value    as decimal
    index pi is unique primary tax-code rate-code rate-value
    index rv rate-value
.
define temp-table temp_gds-grp no-undo
    field rec-no        as integer
    field node-code     as integer
    field upper-code    as integer
    field node-name     as character
    index pi is primary unique rec-no
    index nc node-code
    index uc upper-code
.
define temp-table temp_clients no-undo
    field rec-no    as integer
    field obj-code  as integer
    field obj-name  as character
    field address   as character
    field phone     as character
    field fax       as character
    field director  as character
    field email     as character
    field okonh     as character
    field okpo      as character
    field inn       as character
    field kpp       as character
    field ps        as character
    index pi is primary unique rec-no
.
define temp-table temp_bar-codes no-undo
    field rec-no    as integer
    field gds-code  as integer
    field b-str     as character
    index pi is primary unique rec-no
    index gc gds-code b-str
.
define variable v-impgds-last-rec-no        as integer      no-undo.
define variable v-impgds-repeated-records   as integer      no-undo.
define variable v-impgds-existed-records    as integer      no-undo.
define variable v-impgds-error-records      as integer      no-undo.
define stream impgds-in.
define stream impgds-err.
define stream impgds-log.
procedure impgds-write-log :
define input parameter p-tab-position   as integer          no-undo.
define input parameter p-log-text       as character        no-undo.
do
on error undo, return error
:
    put stream impgds-log unformatted
        skip
    .
    if p-tab-position <> 0
    then do:
        put stream impgds-log unformatted
            cur-time-string-sec()
        .
        put stream impgds-log unformatted
            space( p-tab-position * 4 )
        .
    end.
    put stream impgds-log unformatted
        p-log-text
    .
end.
end procedure.
procedure impgds-write-error :
define input parameter p-tab-position   as integer          no-undo.
define input parameter p-err-text       as character        no-undo.
do
on error undo, return error
:
    output stream impgds-err to "impgds.err" append .
    put stream impgds-err unformatted
        chr(10)
    .
    if p-tab-position <> 0
    then do:
        put stream impgds-err unformatted
            cur-time-string-sec()
        .
        put stream impgds-err unformatted
            space( p-tab-position * 4 )
        .
    end.
    put stream impgds-err unformatted
        p-err-text
    .
    output stream impgds-err close.
end.
end procedure.
procedure impgds-write-edt :
define input parameter p-edt-handle     as handle           no-undo.
define input parameter p-log-level      as integer          no-undo.
define input parameter p-output-string  as character        no-undo.
do
on error undo, return error
:
    if valid-handle ( p-edt-handle )
    then do:
        p-edt-handle :move-to-eof().
        p-edt-handle :insert-string(
            if( p-log-level = 0
                or p-output-string = "&DLine"
                or p-output-string = "&Line" )
            then ""
            else cur-time-string-sec() + " " ).
        p-edt-handle :insert-string(
            if p-output-string = "&Line"
            then fill( "-", 80 )
            else if p-output-string = "&DLine"
                 then fill( "=", 80 )
                 else fill( " ", p-log-level ) + p-output-string ).
        p-edt-handle :insert-string( chr(10) ).
    end.
    process events.
end.
end procedure.
procedure impgds-write-cnt :
define input parameter p-cnt-handle     as handle           no-undo.
define input parameter p-output-string  as character        no-undo.
do
on error undo, return error
:
    if valid-handle( p-cnt-handle )
    then do:
        assign p-cnt-handle :screen-value = p-output-string.
    end.
    process events.
end.
end procedure.
procedure impgds-assign-integer :
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-file-line-num      as integer          no-undo.
define input parameter p-field-name         as character        no-undo.
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-integer    as integer          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        run impgds-write-error in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-log in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 0
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        undo, return error.
    end.
end.
end procedure.
procedure impgds-assign-decimal :
define input parameter p-log-handle         as handle           no-undo.
define input parameter p-file-line-num      as integer          no-undo.
define input parameter p-field-name         as character        no-undo.
define input parameter p-input-string       as character        no-undo.
define output parameter p-output-decimal    as decimal          no-undo.
do
on error undo, return error
:
    assign
        p-output-decimal = decimal( p-input-string )
    no-error.
    if error-status :error
    then do:
        run impgds-write-error in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-log in this-procedure (
              input 1
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 0
            , input substitute( "Ошибка преобразования поля в десятичный тип. Строка &1. Поле &2. Значение '&3'"
                                , p-file-line-num
                                , p-field-name
                                , p-input-string
                              )
        ).
        undo, return error.
    end.
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function is-numeral return logical
  (input p-string   as character ,
   input char-avail as character) :
  define variable p-replace-string as character no-undo .
  define variable log-result       as logical  no-undo .
  if p-string = ? then
    return false .
  p-replace-string = p-string.
  if lookup ("*", char-avail) > 0 then
      p-replace-string = replace (p-replace-string, '*', '9').
  if lookup ("digit", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, '0', '9')
      p-replace-string = replace (p-replace-string, '1', '9')
      p-replace-string = replace (p-replace-string, '2', '9')
      p-replace-string = replace (p-replace-string, '3', '9')
      p-replace-string = replace (p-replace-string, '4', '9')
      p-replace-string = replace (p-replace-string, '5', '9')
      p-replace-string = replace (p-replace-string, '6', '9')
      p-replace-string = replace (p-replace-string, '7', '9')
      p-replace-string = replace (p-replace-string, '8', '9')
      .
  else
     p-replace-string = replace (p-replace-string, '9', chr(15))
      .
  if lookup ("letter", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, 'A', '9')
      p-replace-string = replace (p-replace-string, 'B', '9')
      p-replace-string = replace (p-replace-string, 'C', '9')
      p-replace-string = replace (p-replace-string, 'D', '9')
      p-replace-string = replace (p-replace-string, 'E', '9')
      p-replace-string = replace (p-replace-string, 'F', '9')
      p-replace-string = replace (p-replace-string, 'G', '9')
      p-replace-string = replace (p-replace-string, 'H', '9')
      p-replace-string = replace (p-replace-string, 'I', '9')
      p-replace-string = replace (p-replace-string, 'J', '9')
      p-replace-string = replace (p-replace-string, 'K', '9')
      p-replace-string = replace (p-replace-string, 'L', '9')
      p-replace-string = replace (p-replace-string, 'M', '9')
      p-replace-string = replace (p-replace-string, 'N', '9')
      p-replace-string = replace (p-replace-string, 'O', '9')
      p-replace-string = replace (p-replace-string, 'P', '9')
      p-replace-string = replace (p-replace-string, 'Q', '9')
      p-replace-string = replace (p-replace-string, 'R', '9')
      p-replace-string = replace (p-replace-string, 'S', '9')
      p-replace-string = replace (p-replace-string, 'T', '9')
      p-replace-string = replace (p-replace-string, 'U', '9')
      p-replace-string = replace (p-replace-string, 'V', '9')
      p-replace-string = replace (p-replace-string, 'W', '9')
      p-replace-string = replace (p-replace-string, 'X', '9')
      p-replace-string = replace (p-replace-string, 'Y', '9')
      p-replace-string = replace (p-replace-string, 'Z', '9')
      p-replace-string = replace (p-replace-string, '_', '9')
      .
  return p-replace-string = fill ('9', length (p-string)).
end.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
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
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
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
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
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
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
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
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
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
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
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
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-store-type    as character    no-undo.
define variable v-store-code    as integer      no-undo.
define variable v-host-code     as integer      no-undo.
define variable v-db-num        as integer      no-undo.
define variable v-today         as date         no-undo.
define variable v-time          as integer      no-undo.
define variable dif-pdbc as logical no-undo initial no.
define variable pbc-veto  as logical no-undo.
define variable v-impgds-last-rate-code    as integer      no-undo.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON bt-import
     LABEL "&Импорт"
     SIZE 10 BY 1.
DEFINE BUTTON bt-read
     LABEL "&Чтение"
     SIZE 10 BY 1.
DEFINE VARIABLE ed-log AS CHARACTER
     VIEW-AS EDITOR LARGE
     SIZE 97.88 BY 19.79
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE fi-log AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 97.75 BY .79
     FGCOLOR 9  NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     bt-read AT ROW 1 COL 11
     bt-import AT ROW 1 COL 21
     b-help AT ROW 1 COL 89 WIDGET-ID 2
     ed-log AT ROW 3.21 COL 1.13 NO-LABEL
     fi-log AT ROW 2.29 COL 1.38 NO-LABEL
     SPACE(0.74) SKIP(20.54)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт товаров".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    apply "WINDOW-CLOSE" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF bt-import IN FRAME Dialog-Frame
DO:
    output stream impgds-log to "impgds.log" append .
    disable
        bt-import
    with frame Dialog-Frame .
    run import-data in this-procedure (
          input fi-log :handle in frame Dialog-Frame
        , input ed-log :handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    output stream impgds-log close.
END.
ON CHOOSE OF bt-read IN FRAME Dialog-Frame
DO:
    define variable v-import-available    as logical      no-undo.
    output stream impgds-log to "impgds.log" .
    run read-data in this-procedure (
          input fi-log :handle in frame Dialog-Frame
        , input ed-log :handle
        , output v-import-available
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения данных."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    output stream impgds-log close.
    if v-import-available = yes
    then do:
        enable
            bt-import
        with frame Dialog-Frame .
    end.
    else do:
        message
            "Были ошибки при проверке считанных данных."
            skip(1)
            skip "Импорт невозможен."
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-fields in this-procedure .
  RUN enable_UI.
  disable all with frame Dialog-Frame .
  run init-enable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-gds :
define input parameter p-gds-code       as character        no-undo.
define input parameter p-gds-name       as character        no-undo.
define output parameter p-have-error    as logical          no-undo.
define output parameter p-error-text    as character        no-undo.
    define variable v-temp-integer    as integer      no-undo.
do
on error undo, return error
:
    if p-gds-name = ""
    then do:
        assign
            p-have-error = yes
            p-error-text = "Название товара пусто."
        .
    end.
    if index( p-gds-name, chr(34)) > 0
    and r-index( p-gds-name, chr(34) ) = index( p-gds-name, chr(34) )
    then do:
        assign
            p-have-error = yes
            p-error-text = "Название товара содержит непарную кавычку."
        .
    end.
    assign
        v-temp-integer = integer( p-gds-code )
    no-error.
    if error-status :error
    then do:
        assign
            p-have-error = yes
            p-error-text = "Код товара не может быть преобразован в число."
        .
    end.
    else do:
        if v-temp-integer <= 0
        then do:
            assign
                p-have-error = yes
                p-error-text = "Код товара меньше или равен 0."
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY ed-log fi-log
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-read bt-import b-help ed-log fi-log
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE import-barcodes-for-goods :
define input parameter p-temp-goods-gds-code  as integer        no-undo.
define input parameter p-temp-goods-unit-cli  as character      no-undo.
define input parameter p-gds-prt-node-code    as integer        no-undo.
    define variable v-is-new    as logical      no-undo.
    define variable l-is-weight as logical no-undo .
    define variable l-is-pgweight as logical no-undo .
    define variable l-is-petrolium as logical no-undo .
    define buffer buf_bar-code          for ub.bar-code.
    define buffer buf_temp_bar-codes    for temp_bar-codes.
    define buffer buf_prod-bc           for ub.prod-bc.
    define buffer buf_goods             for ub.goods.
do
for buf_bar-code
  , buf_temp_bar-codes
  , buf_prod-bc
  , buf_goods
on error undo, return error
:
    find first buf_bar-code no-lock
         where buf_bar-code.b-code   = p-temp-goods-gds-code
    no-error.
    if not available buf_bar-code
    then do:
        find first buf_goods no-lock
             where buf_goods.gds-code = p-temp-goods-gds-code
        .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  p-temp-goods-gds-code
  ,input  p-gds-prt-node-code
  ,input  ''
  ,input  ''
  ,input  buf_goods.unit-cli
  ,input  buf_goods.cli-base-rate
  ,output v-is-new
  ,buffer buf_bar-code
  )  .
    end.
    _buf_temp-bar-codes:
    for each buf_temp_bar-codes
       where buf_temp_bar-codes.gds-code = p-temp-goods-gds-code
    :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_temp_bar-codes.b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'weight=request':u
  ,output l-is-weight
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_temp_bar-codes.b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'pgweight=request':u
  ,output l-is-pgweight
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbctv in g#library
  (input buf_temp_bar-codes.b-str
  ,input  buf_bar-code.unit-cli
  ,input  buf_goods.unit-base
  ,input  'petrolium=request':u
  ,output l-is-petrolium
  )  .
        if (l-is-weight
        or l-is-pgweight
        or l-is-petrolium
        ) then do:
          next _buf_temp-bar-codes.
        end.
        find first buf_prod-bc no-lock
             where buf_prod-bc.b-code   = p-temp-goods-gds-code
               and buf_prod-bc.b-str    = buf_temp_bar-codes.b-str
        no-error.
        if not available buf_prod-bc
        then do:
          define variable v-b-str as character no-undo .
          define variable rid as recid no-undo .
          v-b-str = buf_temp_bar-codes.b-str.
          rid = ?.
          run trg/prod-bc1.p (
                              input  parparentproc
                              ,input yes
                              ,input dif-pdbc
                              ,input pbc-veto
                              ,input no
                              ,input ''
                              ,input ""
                              ,buffer buf_goods
                              ,input p-temp-goods-gds-code
                              ,input-output v-b-str
                              ,output rid
                              ) no-error.
         if error-status :error
         then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Fatal err: Ошибка при сохраненеии ДопБК: &1 для товара:&2&3"
                                    , buf_temp_bar-codes.b-str
                                    , error-status:get-message(1)
                                    , return-value
                                  )
            ).
         end.
         else if rid = ? then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "No-fatal err: Не удалось сохранить ДОпБК: &1 для товара: &2"
                                    , buf_temp_bar-codes.b-str
                                    , return-value
                                  )
            ).
         end.
        end.
        else do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "No-fatal err: Дополнительный бар-код: &1 для товара: &2 уже есть."
                                    , buf_temp_bar-codes.b-str
                                    , p-temp-goods-gds-code
                                  )
            ).
        end.
    end.
end.
END PROCEDURE.
PROCEDURE import-clients :
    define input parameter p-cnt-handle as handle           no-undo.
    define variable v-group-code    as integer      no-undo.
    define variable v-clients-recid as recid        no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_clients       for ub.clients.
    define buffer buf_temp_clients  for temp_clients.
    define buffer buf_firm          for ub.firm.
do
for buf_clients
  , buf_temp_clients
  , buf_firm
on error undo, return error
:
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-name = 'Внешние':U
    no-error.
    if error-status :error
    then do:
        message
            substitute( "Не найдена группа клиентов '&2'.&1Импорт контрагентов невозможен."
                        , chr(10)
                        , 'Внешние':U
                      )
        view-as alert-box error
        title "Импорт товаров из Trade в Trade House"
        .
        undo, return error.
    end.
    else do:
        assign
            v-group-code = buf_cli-grp.node-code
        .
    end.
    for each buf_temp_clients
    on error undo, return error
    :
        find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = buf_temp_clients.obj-code
        no-error.
        if not available buf_clients
        then do:
            run ref/firm1.p (
                  input parparentproc
                , input-output v-clients-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input "":U
                , input no
                , input ( - abs(buf_temp_clients.obj-code))
                , input 0
                , input buf_temp_clients.obj-name
                , input "":U
                , input buf_temp_clients.ps
                , input v-group-code
                , input substring( buf_temp_clients.address, 1, 50 )
                        + substring( buf_temp_clients.address, 101, 50 )
                        + substring( buf_temp_clients.address, 151 )
                , input substring( buf_temp_clients.address, 51, 50 )
                , input "":U
                , input "":U
                , input buf_temp_clients.director
                , input buf_temp_clients.email
                , input "":U
                , input buf_temp_clients.fax
                , input "":U
                , input "":U
                , input buf_temp_clients.inn
                , input no
                , input no
                , input buf_temp_clients.kpp
                , input buf_temp_clients.okonh
                , input buf_temp_clients.okpo
                , input "":U
                , input "":U
                , input buf_temp_clients.phone
                , input "":U
                , input "":U
                , input "":U
                , input "":U
                , input 0
                , input 0
                , input "":U
                , input 0
                , input no
                , input no
            ).
        end.
        else do:
            undo, return error
                    substitute( "Err: Попытка повторного импорта объекта: &1 &2"
                                , buf_clients.obj-code
                                , buf_clients.obj-name )
            .
        end.
        if buf_temp_clients.obj-code < 9999990
        and current-value( s-fmgb-code, ub ) < buf_temp_clients.obj-code
        then do:
            assign
                current-value( s-fmgb-code, ub ) = buf_temp_clients.obj-code
            .
        end.
        run impgds-write-cnt in this-procedure (
              input p-cnt-handle
            , input substitute( "Импортирован объект: &1 &2 &3"
                                , 'орг':U
                                , buf_temp_clients.obj-code
                                , buf_temp_clients.obj-name )
        ).
    end.
end.
END PROCEDURE.
PROCEDURE import-data :
define input parameter p-cnt-handle     as handle           no-undo.
define input parameter p-log-handle     as handle           no-undo.
do
on error undo, return error
:
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт контрагентов..."
    ).
    run import-clients  in this-procedure (
        input p-cnt-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта контрагентов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт контрагентов завершен."
    ).
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт групп товаров..."
    ).
    run import-gds-grp  in this-procedure (
        input p-cnt-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта групп товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт групп товаров завершен."
    ).
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт карточек товаров..."
    ).
    run import-goods in this-procedure (
        input p-cnt-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт карточек товаров завершен."
    ).
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
end.
END PROCEDURE.
PROCEDURE import-gds-grp :
    define input parameter p-cnt-handle as handle           no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_gds-grp      for temp_gds-grp.
do
for buf_gds-grp
  , buf_temp_gds-grp
on error undo, return error
:
    for each buf_temp_gds-grp
    by buf_temp_gds-grp.upper-code
    on error undo, return error
    :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_temp_gds-grp.node-code
        no-error.
        if not available buf_gds-grp
        then do:
            run utl/impgrptx.p (
                  input 'ДОБАВЛЕНИЕ':U
                , input buf_temp_gds-grp.node-code
                , input buf_temp_gds-grp.upper-code
                , input buf_temp_gds-grp.node-name
                , input v-host-code
                , input v-store-type
                , input v-store-code
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания группы товаров."
                    skip(1)
                    skip "Код группы:" buf_temp_gds-grp.node-code
                    skip "Имя группы:" buf_temp_gds-grp.node-name
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            else do:
                if current-value( s-gds-grp, ub ) < buf_temp_gds-grp.node-code
                then do:
                    assign
                        current-value( s-gds-grp, ub ) = buf_temp_gds-grp.node-code
                    .
                end.
                run impgds-write-cnt in this-procedure (
                      input p-cnt-handle
                    , input substitute( "Импортирована группа: &1 &2"
                                        , buf_temp_gds-grp.node-code
                                        , buf_temp_gds-grp.node-name )
                ).
            end.
        end.
        else do:
            undo, return error
                    substitute( "Err: Попытка повторного импорта группы: &1 &2"
                                , buf_temp_gds-grp.node-code
                                , buf_temp_gds-grp.node-name )
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE import-goods :
define input parameter p-cnt-handle     as handle           no-undo.
    define variable v-goods-parameter-dif-nam1  as logical      init yes    no-undo.
    define variable v-goods-parameter-dif-nam2  as logical      init no     no-undo.
    define variable v-par-value                 as character                no-undo.
    define variable v-par-type                  as character                no-undo.
    define variable v-vat-rate-code             as integer                  no-undo.
    define variable v-slt-rate-code             as integer                  no-undo.
    define variable v-goods-recid               as recid                    no-undo.
    define variable v-gds-code                  as integer                  no-undo.
    define variable v-last-gds-code             as integer                  no-undo.
    define variable v-tax-rate-recid            as recid                    no-undo.
    define variable v-tax-rate-value-recid      as recid                    no-undo.
    define variable v-goods-unit-cli            as character                no-undo.
    define variable v-param-type                as character                no-undo.
    define variable v-value-character           as character                no-undo.
    define variable v-value-date                as date                     no-undo.
    define variable v-value-decimal             as decimal                  no-undo.
    define variable v-value-integer             as INTEGER                  no-undo.
    define variable v-value-logical             AS LOGICAL                  no-undo.
    define variable v-tth                       as handle                   no-undo.
    define buffer buf_goods         for ub.goods.
    define buffer buf_units         for ub.units.
    define buffer buf_temp_goods    for temp_goods.
    define buffer buf_gds-prt       for ub.gds-prt.
    define buffer buf_temp_tax      for temp_tax.
do
for buf_goods
  , buf_units
  , buf_temp_goods
  , buf_gds-prt
  , buf_temp_tax
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
    for each buf_temp_goods
    by buf_temp_goods.gds-code descending
    :
        assign
            v-last-gds-code = buf_temp_goods.gds-code
        .
        leave.
    end.
    if v-last-gds-code >= current-value( s-bcgb-code, ub )
    then do:
        assign
            current-value( s-bcgb-code, ub ) = v-last-gds-code + 1
        .
    end.
    import-goods:
    for each buf_temp_goods
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_goods.gds-code
        no-error.
        if available buf_goods
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Невозможно создать товар с кодом, который есть у товара в БД: &1"
                        , buf_temp_goods.gds-code )
            ).
            next import-goods.
        end.
        find first buf_units no-lock
             where buf_units.unit-name = buf_temp_goods.unit-base
        .
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-name = '_Пустая шкала':U
        no-error.
        if not available buf_gds-prt
        then do:
            undo, return error "import-product: Не найден код пустой шкалы для товара." + chr(10) + return-value.
        end.
        run adm/shattri.p (
            input "get":U
            ,input  '':U
            ,input  0
            ,input  'gds-ref':U
            ,input  'dif-nam1':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-goods-parameter-dif-nam1
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error.
        delete object v-tth.
        run adm/shattri.p (
            input "get":U
            ,input  '':U
            ,input  0
            ,input  'gds-ref':U
            ,input  'dif-nam2':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-goods-parameter-dif-nam2
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error.
        delete object v-tth.
        find first buf_temp_tax
             where buf_temp_tax.tax-code   = integer( '1':U )
               and buf_temp_tax.rate-value = buf_temp_goods.VAT-pc
        no-error.
        if not available buf_temp_tax
        then do:
            assign
                v-impgds-last-rate-code = v-impgds-last-rate-code + 1
            .
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = integer( '1':U )
                buf_temp_tax.rate-value     = buf_temp_goods.VAT-pc
                buf_temp_tax.rate-code      = v-impgds-last-rate-code
            .
            run ref/taxrati1.p (
                  input-output v-tax-rate-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input yes
                , input integer( '1':U )
                , input v-impgds-last-rate-code
                , input substitute( "НДС &1", buf_temp_goods.VAT-pc  )
                , input 'тек':U
            ) no-error .
            if error-status :error
            then do:
                run impgds-write-log in this-procedure (
                      input 1
                    , input substitute( "Fatal err: Ошибка при сохраненеии ставки налога для товара.&1&2&1&3"
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                      )
            ).
            end.
            run ref/taxvali1.p (
                  input-output v-tax-rate-value-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input yes
                , input integer( '1':U )
                , input v-impgds-last-rate-code
                , input buf_temp_tax.rate-value
                , input v-today
                , input 0
                , input "":U
                , input 0
                , input 'тек':U
            ).
        end.
        assign
            v-vat-rate-code = buf_temp_tax.rate-code
        .
        find first buf_temp_tax
             where buf_temp_tax.tax-code   = integer( '2':U )
               and buf_temp_tax.rate-value = buf_temp_goods.SLT-pc
        no-error.
        if not available buf_temp_tax
        then do:
            assign
                v-impgds-last-rate-code = v-impgds-last-rate-code + 1
            .
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = integer( '2':U )
                buf_temp_tax.rate-value     = buf_temp_goods.SLT-pc
                buf_temp_tax.rate-code      = v-impgds-last-rate-code
            .
            run ref/taxrati1.p (
                  input-output v-tax-rate-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input yes
                , input integer( '2':U )
                , input v-impgds-last-rate-code
                , input substitute( "НП &1", buf_temp_goods.SLT-pc  )
                , input 'тек':U
            ) no-error .
            if error-status :error
            then do:
                run impgds-write-log in this-procedure (
                      input 1
                    , input substitute( "Fatal err: Ошибка при сохраненеии ставки налога для товара.&1&2&1&3"
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                      )
            ).
            end.
            run ref/taxvali1.p (
                  input-output v-tax-rate-value-recid
                , input 'ДОБАВЛЕНИЕ':U
                , input yes
                , input integer( '2':U )
                , input v-impgds-last-rate-code
                , input buf_temp_tax.rate-value
                , input v-today
                , input 0
                , input "":U
                , input 0
                , input 'тек':U
            ).
        end.
        assign
            v-slt-rate-code = buf_temp_tax.rate-code
        .
        run utl/impgdstx.p (
              input 'ДОБАВЛЕНИЕ':U
            , input v-vat-rate-code
            , input v-slt-rate-code
            , input no
            , input 0
            , input no
            , input yes
            , input no
            , input yes
            , input v-host-code
            , input v-store-type
            , input v-store-code
            , input yes
            , input 0
            , input buf_temp_goods.gds-code
            , input buf_temp_goods.artic
            , input 'орг':U
            , input buf_temp_goods.prod-code
            , input buf_gds-prt.node-code
            , input buf_temp_goods.grp-code
            , input buf_temp_goods.gds-name
            , input ""
            , input buf_temp_goods.engl-name
            , input buf_temp_goods.gds-name
            , input replace( replace( buf_temp_goods.gds-name, chr( 39 ), "" ), chr( 34 ), "" )
            , input "XX":U
            , input buf_units.unit-name
            , input buf_units.unit-name
            , input 0.0
            , input 0.0
            , input 1
            , input 1
            , input 0
            , input 0
            , input 'Группа':U
            , input 0
            , input no
            , input 0
            , input 0
            , input ""
            , input ""
            , input ""
            , input ""
            , input ""
            , input ""
            , input 0
            , input ""
            , input 0.0
            , input 0
            , input 0
            , input ""
            , input ""
            , input ""
            , input 0
            , input ""
            , input no
            , input no
            , input no
            , input no
            , input "no"
            , input v-goods-parameter-dif-nam1
            , input v-goods-parameter-dif-nam2
            , input no
            , input 2
            , input-output v-goods-recid
            , output v-gds-code
        ) no-error .
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка создания карточки товара."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                    trim(error-status :get-message(4))
                    trim(error-status :get-message(5))
            view-as alert-box error.
            undo, return error "Err: Ошибка создания товара в базе данных."
                                + chr(10) + "Код товара: " + string( buf_temp_goods.gds-code )
                                + chr(10) + trim(error-status :get-message(1))
                                + chr(10) + return-value
            .
        end.
        assign
            v-goods-unit-cli = ( if buf_temp_goods.unit-base = 'лт':U
                                 then 'кгт':U
                                 else buf_temp_goods.unit-base )
        .
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-name = '_Пустая шкала':U
        no-error.
        if error-status :error
        then do:
            message
                "Err: Не найден корневой узел для шкалы товаров. Импорт товаров невозможен."
            view-as alert-box.
            undo, return error.
        end.
        run import-barcodes-for-goods in this-procedure (
              input buf_temp_goods.gds-code
            , input v-goods-unit-cli
            , input buf_gds-prt.node-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error "Err: Ошибка при создании бар-кодов для товара: "
                        + " " + string( buf_temp_goods.gds-code )
                        + " " + string( buf_temp_goods.gds-name )
                        + chr(10)
            .
        end.
        else do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "OK: Товар &1. Бар-коды созданы."
                                    , buf_temp_goods.gds-code
                                  )
            ).
        end.
        run impgds-write-cnt in this-procedure (
              input p-cnt-handle
            , input substitute( "Импортирован товар: &1 &2", buf_temp_goods.gds-code, buf_temp_goods.gds-name )
        ).
    end.
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input substitute( " ":U )
    ).
if session :set-wait-state( "" ) then.
  run adm/restseqr.p
      ( input "rest-no-msg":U
       ,input "":U
       ,input yes
    ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
end.
END PROCEDURE.
PROCEDURE init-enable :
do
on error undo, return error
:
    enable
        b-exit
        bt-read
        ed-log
    with frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE init-fields :
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.
do
on error undo, return error
:
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
        v-store-type = v-cntxt-obj-type
        v-store-code = v-cntxt-obj-code
    .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-store-type
  ,input  v-store-code
  ,output v-host-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
  run adm/shattri.p (
      input "get":U
      ,input  '':U
      ,input  0
      ,input  'gds-ref':U
      ,input  'dif-pdbc':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output dif-pdbc
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error.
  delete object v-tth.
  run adm/shattri.p (
      input "get":U
      ,input  '':U
      ,input  0
      ,input  'gds-ref':U
      ,input  'dif-pdbc':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output pbc-veto
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error.
  delete object v-tth.
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
end.
END PROCEDURE.
PROCEDURE read-bcodes-file :
    define variable v-gds-code      as character    no-undo.
    define variable v-b-str         as character    no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define buffer buf_temp_bar-codes    for temp_bar-codes.
    define buffer buf_prod-bc           for ub.prod-bc.
do
for buf_temp_bar-codes
  , buf_prod-bc
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение бар-кодов из файла &1"
                        , "bcode.txt" )
    ).
    input stream impgds-in from "bcode.txt" .
    import-clients-string:
    repeat
    :
        assign
            v-gds-code      = "":U
            v-b-str         = "":U
        .
        import stream impgds-in
            v-gds-code
            v-b-str
        .
        if v-gds-code = "":U
        then do:
            next import-clients-string.
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no + 1
            , input "gds-code":U
            , input v-gds-code
            , output v-temp-integer
        ).
        find first buf_temp_bar-codes no-lock
             where buf_temp_bar-codes.gds-code = v-temp-integer
               and buf_temp_bar-codes.b-str    = v-b-str
        no-error.
        if available buf_temp_bar-codes
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение бар-кода &2 для товара с кодом &1", v-temp-integer, v-b-str )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-clients-string.
        end.
        find first buf_prod-bc no-lock
             where buf_prod-bc.b-code   = v-temp-integer
               and buf_prod-bc.b-str    = v-b-str
        no-error.
        if available buf_prod-bc
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение бар-кода &2, который есть у товара &1 в БД."
                        , v-temp-integer, v-b-str )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-clients-string.
        end.
        create buf_temp_bar-codes.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_bar-codes.rec-no           = v-impgds-last-rec-no
            buf_temp_bar-codes.gds-code         = v-temp-integer
            buf_temp_bar-codes.b-str            = v-b-str
        .
    end.
    input stream impgds-in close.
if session :set-wait-state( "" ) then.
end.
END PROCEDURE.
PROCEDURE read-clients-file :
    define variable v-obj-code      as character    no-undo.
    define variable v-obj-name      as character    no-undo.
    define variable v-address       as character    no-undo.
    define variable v-phone         as character    no-undo.
    define variable v-fax           as character    no-undo.
    define variable v-director      as character    no-undo.
    define variable v-email         as character    no-undo.
    define variable v-okonh         as character    no-undo.
    define variable v-okpo          as character    no-undo.
    define variable v-inn           as character    no-undo.
    define variable v-kpp           as character    no-undo.
    define variable v-ps            as character    no-undo.
    define variable v-temp-integer     as integer      no-undo.
    define buffer buf_temp_clients  for temp_clients.
    define buffer buf_clients       for ub.clients.
do
for buf_temp_clients
  , buf_clients
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение контрагентов из файла &1"
                        , "client.txt" )
    ).
    input stream impgds-in from "client.txt" .
    import-clients-string:
    repeat
    :
        assign
            v-obj-code      = "":U
            v-obj-name      = "":U
        .
        import stream impgds-in
            v-obj-code
            v-obj-name
            v-address
            v-phone
            v-fax
            v-director
            v-email
            v-okonh
            v-okpo
            v-inn
            v-kpp
            v-ps
        .
        if v-obj-code = "":U
        then do:
            next import-clients-string.
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no + 1
            , input "obj-code":U
            , input v-obj-code
            , output v-temp-integer
        ).
        find first buf_temp_clients
             where buf_temp_clients.obj-code = v-temp-integer
        no-error.
        if available buf_temp_clients
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение объекта с кодом &1", v-temp-integer )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-clients-string.
        end.
        find first buf_clients no-lock
             where buf_clients.obj-type = 'орг':U
               and buf_clients.obj-code = v-temp-integer
        no-error.
        if available buf_clients
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение объекта с кодом, который есть у объекта в БД: &1"
                        , v-temp-integer )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-clients-string.
        end.
        create buf_temp_clients.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_clients.rec-no           = v-impgds-last-rec-no
            buf_temp_clients.obj-code         = v-temp-integer
            buf_temp_clients.obj-name         = v-obj-name
            buf_temp_clients.address          = v-address
            buf_temp_clients.phone            = v-phone
            buf_temp_clients.fax              = v-fax
            buf_temp_clients.director         = v-director
            buf_temp_clients.email            = v-email
            buf_temp_clients.okonh            = v-okonh
            buf_temp_clients.okpo             = v-okpo
            buf_temp_clients.inn              = v-inn
            buf_temp_clients.kpp              = v-kpp
            buf_temp_clients.ps               = v-ps
        .
    end.
    input stream impgds-in close.
if session :set-wait-state( "" ) then.
end.
END PROCEDURE.
PROCEDURE read-data :
define input parameter p-cnt-handle         as handle           no-undo.
define input parameter p-log-handle         as handle           no-undo.
define output parameter p-import-available  as logical          no-undo.
do
on error undo, return error
:
    define variable v-data-have-error    as logical      no-undo.
    assign
        v-data-have-error = no
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Чтение данных для импорта."
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input substitute( "Лог-файл:      &1", "impgds.log" )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input substitute( "Файл ошибок:   &1", "impgds.err" )
    ).
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла контрагентов &1...", "client.txt"  )
    ).
    disable
        bt-read
    with frame Dialog-Frame .
    run read-clients-file in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла контрагентов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла контрагентов завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 контрагентов (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 контрагентов, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 контрагентов с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла групп товаров &1...", "group.txt"  )
    ).
    run read-gds-grp-file in this-procedure (
        input p-log-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла групп товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла групп товаров завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 групп товаров (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 групп товаров, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 групп товаров с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input "Чтение таблицы налогов из базы данных..."
    ).
    run read-tax-in-base in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения ставок налогов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input "Чтение таблицы налогов из базы данных завершено."
    ).
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла товаров &1...", "good.txt"  )
    ).
    run read-goods-file in this-procedure (
          input p-cnt-handle
        , input p-log-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла товаров завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 кодов товаров (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 кодов товаров, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 товаров с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла бар-кодов &1...", "bcode.txt"  )
    ).
    run read-bcodes-file in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла бар-кодов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла бар-кодов завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 бар-кодов (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 бар-кодов, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 бар-кодов с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
    if v-data-have-error = no
    then do:
        assign
            p-import-available = yes
        .
    end.
end.
END PROCEDURE.
PROCEDURE read-gds-grp-file :
define input parameter p-edt-handle     as handle           no-undo.
    define variable v-node-code       as character    no-undo.
    define variable v-upper-code      as character    no-undo.
    define variable v-node-name       as character    no-undo.
    define variable v-temp-integer     as integer      no-undo.
    define variable v-temp-decimal     as decimal      no-undo.
    define variable v-error-message    as character    no-undo.
    define buffer buf_temp_gds-grp  for temp_gds-grp.
    define buffer buf_gds-grp       for ub.gds-grp.
do
for buf_temp_gds-grp
  , buf_gds-grp
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение групп товаров из файла &1"
                        , "group.txt" )
    ).
    input stream impgds-in from "group.txt" .
    import-gds-grp-string:
    repeat
    :
        assign
            v-node-code      = "":U
            v-upper-code     = "":U
            v-node-name      = "":U
        .
        import stream impgds-in
            v-node-code
            v-upper-code
            v-node-name
        .
        if v-node-code = "":U
        then do:
            next import-gds-grp-string.
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no + 1
            , input "node-code":U
            , input v-node-code
            , output v-temp-integer
        ).
        find first buf_temp_gds-grp no-lock
             where buf_temp_gds-grp.node-code = v-temp-integer
        no-error.
        if available buf_temp_gds-grp
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение группы товара с кодом &1", v-temp-integer )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-gds-grp-string.
        end.
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-temp-integer
        no-error.
        if available buf_gds-grp
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение группы товара с кодом, который есть у группы в БД: &1"
                        , v-temp-integer )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-gds-grp-string.
        end.
        create buf_temp_gds-grp.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_gds-grp.rec-no           = v-impgds-last-rec-no
            buf_temp_gds-grp.node-code        = v-temp-integer
            buf_temp_gds-grp.node-name        = v-node-name
        .
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no + 1
            , input "upper-code":U
            , input v-upper-code
            , output buf_temp_gds-grp.upper-code
        ).
        run grplib-analyze-grp-name in this-procedure (
              input v-node-name
            , input buf_temp_gds-grp.upper-code
            , output v-error-message
        ).
        if v-error-message <> "":U
        then do:
            run impgds-write-error in this-procedure (
                  input 1
                , input substitute( "Ошибка в имени группы товара &1: &2", buf_temp_gds-grp.node-code, v-error-message )
            ).
            run impgds-write-edt in this-procedure (
                  input ed-log :handle in frame Dialog-Frame
                , input 1
                , input substitute( "Ошибка в имени группы &1: &2", buf_temp_gds-grp.node-code, v-error-message )
            ).
            assign
                v-impgds-error-records  = v-impgds-error-records + 1
            .
        end.
    end.
    input stream impgds-in close.
if session :set-wait-state( "" ) then.
end.
END PROCEDURE.
PROCEDURE read-goods-file :
define input parameter p-cnt-handle     as handle           no-undo.
define input parameter p-log-handle     as handle           no-undo.
    define variable v-gds-code          as character   no-undo.
    define variable v-artic             as character   no-undo.
    define variable v-prod-code         as character   no-undo.
    define variable v-grp-code          as character   no-undo.
    define variable v-unit-base         as character   no-undo.
    define variable v-unit-base-type    as character   no-undo.
    define variable v-gds-type          as character   no-undo.
    define variable v-gds-name          as character   no-undo.
    define variable v-engl-name         as character   no-undo.
    define variable v-VAT-pc            as character   no-undo.
    define variable v-SLT-pc            as character   no-undo.
    define variable v-deadline          as character   no-undo.
    define variable v-have-error        as logical      no-undo.
    define variable v-error-message     as character    no-undo.
    define variable v-temp-integer      as integer      no-undo.
    define variable v-temp-decimal      as decimal      no-undo.
    define buffer buf_temp_goods        for temp_goods.
    define buffer buf_rep_temp_goods    for temp_goods.
    define buffer buf_goods             for ub.goods.
do
for buf_temp_goods
  , buf_rep_temp_goods
  , buf_goods
on error undo, return error
:
if session :set-wait-state( "compiler" ) then.
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение товаров из файла &1"
                        , "good.txt" )
    ).
    input stream impgds-in from "good.txt" .
    import-goods-string:
    repeat
    :
        assign
            v-gds-code       = "":U
            v-artic          = "":U
            v-prod-code      = "":U
            v-grp-code       = "":U
            v-unit-base      = "":U
            v-unit-base-type = "":U
            v-gds-type       = "":U
            v-gds-name       = "":U
            v-engl-name      = "":U
            v-VAT-pc         = "":U
            v-SLT-pc         = "":U
            v-deadline       = "":U
        .
        import stream impgds-in
            v-gds-code
            v-artic
            v-prod-code
            v-grp-code
            v-unit-base
            v-unit-base-type
            v-gds-type
            v-gds-name
            v-engl-name
            v-VAT-pc
            v-SLT-pc
            v-deadline
        .
        if v-gds-code = "":U
        then do:
            next import-goods-string.
        end.
        run check-gds in this-procedure (
              input v-gds-code
            , input v-gds-name
            , output v-have-error
            , output v-error-message
        ).
        if v-have-error = yes
        then do:
            run impgds-write-error in this-procedure (
                  input 1
                , input substitute( "Не прошла проверка товара с кодом &1. &2" , v-gds-code, v-error-message )
            ).
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "*** Ошибка: Не прошла проверка товара с кодом &1. &2" , v-gds-code, v-error-message )
            ).
            run impgds-write-edt in this-procedure (
                  input ed-log :handle in frame Dialog-Frame
                , input 1
                , input substitute( "Ошибка товара &1. &2" , v-gds-code, v-error-message )
            ).
            assign
                v-impgds-error-records  = v-impgds-error-records + 1
            .
        end.
        if v-artic = "":U
        then do:
            assign
                v-artic = v-gds-code
            .
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no + 1
            , input "gds-code":U
            , input v-gds-code
            , output v-temp-integer
        ).
        find first buf_temp_goods no-lock
             where buf_temp_goods.gds-code = v-temp-integer
        no-error.
        if available buf_temp_goods
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение товара с кодом &1", v-temp-integer )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-goods-string.
        end.
        find first buf_goods no-lock
             where buf_goods.gds-code = v-temp-integer
        no-error.
        if available buf_goods
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение товара с кодом, который есть у товара в БД: &1"
                        , v-temp-integer )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-goods-string.
        end.
        create buf_temp_goods.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_goods.rec-no           = v-impgds-last-rec-no
            buf_temp_goods.gds-code         = v-temp-integer
            buf_temp_goods.artic            = v-artic
        .
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no + 1
            , input "prod-code":U
            , input v-prod-code
            , output buf_temp_goods.prod-code
        ).
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no + 1
            , input "grp-code":U
            , input v-grp-code
            , output buf_temp_goods.grp-code
        ).
        assign
            buf_temp_goods.unit-base        = v-unit-base
            buf_temp_goods.unit-base-type   = v-unit-base-type
            buf_temp_goods.gds-type         = v-gds-type
            buf_temp_goods.gds-name         = v-gds-name
            buf_temp_goods.engl-name        = v-engl-name
        .
        run impgds-assign-decimal in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no
            , input "VAT-pc":U
            , input v-VAT-pc
            , output buf_temp_goods.VAT-pc
        ).
        run impgds-assign-decimal in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no
            , input "SLT-pc":U
            , input v-SLT-pc
            , output buf_temp_goods.SLT-pc
        ).
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame Dialog-Frame
            , input v-impgds-last-rec-no
            , input "deadline":U
            , input v-deadline
            , output buf_temp_goods.deadline
        ).
        run impgds-write-cnt in this-procedure (
              input p-cnt-handle
            , input substitute( "Считан товар: &1 &2", buf_temp_goods.gds-code, buf_temp_goods.gds-name )
        ).
    end.
    input stream impgds-in close.
if session :set-wait-state( "" ) then.
end.
END PROCEDURE.
PROCEDURE read-tax-in-base :
    define variable v-tax-value    as decimal      no-undo.
    define buffer buf_tax-rate-value    for ub.tax-rate-value.
    define buffer buf_temp_tax          for temp_tax.
do
for buf_tax-rate-value
  , buf_temp_tax
on error undo, return error
:
    for each buf_temp_tax
    :
        delete buf_temp_tax.
    end.
    tax-rate-value-string:
    for each buf_tax-rate-value
       where buf_tax-rate-value.tax-code = integer( '1':U )
    :
        if buf_tax-rate-value.status_ <> 'тек':U
        then do:
            if v-impgds-last-rate-code < buf_tax-rate-value.rate-code
            then do:
                assign
                    v-impgds-last-rate-code = buf_tax-rate-value.rate-code
                .
            end.
            next tax-rate-value-string.
        end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(buf_tax-rate-value)
  ,input  buf_tax-rate-value.tax-code
  ,input  buf_tax-rate-value.rate-code
  ,input  ?
  ,input  0
  ,input  ''
  ,input  0
  ,output v-tax-value
  )  .
        find first buf_temp_tax
             where buf_temp_tax.tax-code            = buf_tax-rate-value.tax-code
               and buf_temp_tax.rate-code           = buf_tax-rate-value.rate-code
               and buf_tax-rate-value.rate-value    = v-tax-value
        no-error.
        if not available buf_temp_tax
        then do:
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = buf_tax-rate-value.tax-code
                buf_temp_tax.rate-code      = buf_tax-rate-value.rate-code
                buf_temp_tax.rate-value     = v-tax-value
            .
            if v-impgds-last-rate-code < buf_tax-rate-value.rate-code
            then do:
                assign
                    v-impgds-last-rate-code = buf_tax-rate-value.rate-code
                .
            end.
        end.
    end.
    for each buf_tax-rate-value
       where buf_tax-rate-value.tax-code = integer( '2':U )
    :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(buf_tax-rate-value)
  ,input  buf_tax-rate-value.tax-code
  ,input  buf_tax-rate-value.rate-code
  ,input  ?
  ,input  0
  ,input  ''
  ,input  0
  ,output v-tax-value
  )  .
        find first buf_temp_tax
             where buf_temp_tax.tax-code            = buf_tax-rate-value.tax-code
               and buf_temp_tax.rate-code           = buf_tax-rate-value.rate-code
               and buf_tax-rate-value.rate-value    = v-tax-value
        no-error.
        if not available buf_temp_tax
        then do:
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = buf_tax-rate-value.tax-code
                buf_temp_tax.rate-code      = buf_tax-rate-value.rate-code
                buf_temp_tax.rate-value     = v-tax-value
            .
        end.
    end.
end.
END PROCEDURE.
