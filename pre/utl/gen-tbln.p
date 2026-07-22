block-level on error undo, throw.
define input         parameter gen-dir       as character no-undo .
define input-output  parameter gen-file-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gen-tbln.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gen-tbln.p $":U .
define variable vss-description as character no-undo init "Генерация include-файлов по имени таблицы".
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
define temp-table tt-file no-undo
field pre-prefix as character
field pre-def as character
field file-label as character
field line-num as integer
index pi is unique primary line-num
index imain pre-def.
do
on error undo, return error
:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  define variable tn      as character no-undo.
  define variable tn-f    as character no-undo .
  define variable v-line-num as integer no-undo .
  define stream NameStream.
  define frame ddd
    fl as character format "x(14)"  label "Таблица" at row 1.5  col 17 colon-aligned
    with view-as dialog-box side-labels three-d
    title "Генерация файлов " + program-name(1)
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if trim( gen-dir ) = "":U then do:
  assign
    gen-dir = ".":U
  .
end.
assign
  file-info:file-name = gen-dir
.
if file-info :full-pathname = ""
or file-info :full-pathname = ?  then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Уазанный каталог (&1) не найден!", gen-dir ) skip
    view-as alert-box error .
  undo, return error .
end.
assign
  gen-dir = file-info:full-pathname + "/":U
.
  run gbl/dir-cre.p ( input gen-dir + "cmp":U ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании каталога &1", gen-dir + "cmp":U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error.
  end.
  view frame ddd.
  assign
    gen-file-list = gen-file-list + "," + "cmp/tbl-name.i":U
  .
  output stream NameStream to value( gen-dir + "cmp/tbl-name.i" ).
  run cur-time in this-procedure ( output v-today
                                  ,output v-time
                                 ).
  put stream NameStream unformatted
    '/*':U + chr(10)
    + chr(10)
    + '$':U + 'Revision: ':U + '$':U + chr(10)
    + '$':U + 'Author: ':U + '$':U + chr(10)
    + '$':U + 'Date: ':U + '$':U + chr(10)
    + '$':U + 'Workfile: ':U + '$':U + chr(10)
    + '$':U + 'Archive: ':U + '$':U + chr(10)
    + chr(10)
    + "Глобальные определения имен таблиц" + chr(10)
    + chr(10)
    + 'Автор: Перваков Михаил Сергеевич':U + chr(10)
    + 'Дата создания: 04/05/06':U + chr(10)
    + 'Author: Mikhail Pervakov':U + chr(10)
    + 'Creation date: 04/05/06':U + chr(10)
    + chr(10)
    + "Файл автоматически создается процедурой " + program-name(1) + chr(10)
    + chr(10)
    + '*/':U + chr(10)
    + chr(10)
  .
  for each ub._File no-lock
    where ub._File._Hidden = false
  by ub._File._File-Name
  :
    assign
      tn = ub._file._file-name
    .
    display
      tn @ fl
      with frame ddd
    .
    put stream NameStream unformatted "&glob table_" + tn + " '" + tn + "':U"
      + chr(10)
      .
  end.
  put stream NameStream unformatted
    chr(47) + chr(42) + ' ':U + chr(36) + 'Workfile: ':U + chr(36) + ' e n d ':U + chr(42) + chr(47) + chr(10)
    + chr(10)
  .
  OUTPUT STREAM NameStream close.
  assign
    gen-file-list = gen-file-list + "," + "cmp/tblbname.i":U
  .
  output stream NameStream to value( gen-dir + "cmp/tblbname.i" ).
  run cur-time in this-procedure ( output v-today
                                  ,output v-time
                                 ).
  put stream NameStream unformatted
    '/*':U + chr(10)
    + chr(10)
    + '$':U + 'Revision: ':U + '$':U + chr(10)
    + '$':U + 'Author: ':U + '$':U + chr(10)
    + '$':U + 'Date: ':U + '$':U + chr(10)
    + '$':U + 'Workfile: ':U + '$':U + chr(10)
    + '$':U + 'Archive: ':U + '$':U + chr(10)
    + chr(10)
    + "Глобальные определения имен таблиц" + chr(10)
    + chr(10)
    + 'Автор: Бахтадзе Наталья Викторовна':U + chr(10)
    + 'Дата создания: 01/29/07':U + chr(10)
    + 'Author: Bakhtadze Natalya':U + chr(10)
    + 'Creation date: 01/29/07':U + chr(10)
    + chr(10)
    + "Файл автоматически создается процедурой " + program-name(1) + chr(10)
    + chr(10)
    + '*/':U + chr(10)
    + chr(10)
  .
  for each ub._File no-lock
    where ub._File._Hidden = false
  by ub._File._File-Name
  :
    assign
      tn = ub._file._file-name
    .
    display
      tn @ fl
      with frame ddd
    .
    put stream NameStream unformatted "&glob bef-table_" + tn + " " + tn
      + chr(10)
      .
  end.
  put stream NameStream unformatted
    chr(47) + chr(42) + ' ':U + chr(36) + 'Workfile: ':U + chr(36) + ' e n d ':U + chr(42) + chr(47) + chr(10)
    + chr(10)
  .
  OUTPUT STREAM NameStream close.
  define variable v-path                    as character                no-undo .
  DEFINE VARIABLE v-full-path               as character                no-undo .
  DEFINE VARIABLE v-file-name               as character                no-undo .
  DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
  DEFINE VARIABLE v-file-name-ext           as character                no-undo .
  run gbl/filename.p (
                  input 'cmp/tbluname.i'
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  input stream Namestream from value(v-full-path) .
  repeat:
    create tt-file.
     assign tt-file.line-num = v-line-num + 1
     v-line-num = v-line-num + 1.
    import stream namestream tt-file except line-num.
    assign
    tt-file.file-label = trim(tt-file.file-label, chr(39))
    tt-file.file-label = trim(tt-file.file-label, chr(34))
    tt-file.file-label = trim(tt-file.file-label, chr(39))
    .
  end.
  input stream Namestream close.
  assign
    gen-file-list = gen-file-list + "," + "cmp/tblfname.i":U
  .
  output stream NameStream to value( gen-dir + "cmp/tblfname.i" ).
  run cur-time in this-procedure ( output v-today
                                  ,output v-time
                                 ).
  put stream NameStream unformatted
    '/*':U + chr(10)
    + chr(10)
    + '$':U + 'Revision: ':U + '$':U + chr(10)
    + '$':U + 'Author: ':U + '$':U + chr(10)
    + '$':U + 'Date: ':U + '$':U + chr(10)
    + '$':U + 'Workfile: ':U + '$':U + chr(10)
    + '$':U + 'Archive: ':U + '$':U + chr(10)
    + chr(10)
    + "Глобальные определения имен таблиц" + chr(10)
    + chr(10)
    + 'Автор: Бахтадзе Наталья Викторовна':U + chr(10)
    + 'Дата создания: 01/29/07':U + chr(10)
    + 'Author: Bakhtadze Natalya':U + chr(10)
    + 'Creation date: 01/29/07':U + chr(10)
    + chr(10)
    + "Файл автоматически создается процедурой " + program-name(1) + chr(10)
    + chr(10)
    + '*/':U + chr(10)
    + chr(10)
  .
  for each ub._File no-lock
    where ub._File._Hidden = false
  by ub._File._File-Name
  :
    assign
      tn = ub._file._file-name
    .
    find first tt-file no-lock where
          tt-file.pre-prefix = "&glob"
      and tt-file.pre-def = ("table_" + tn + "-full") no-error.
    if not available tt-file then do:
      if ub._file._file-label = ?
      or ub._file._file-label = '':U
      then do:
        assign
        tn-f = ub._file._file-name.
      end.
      else do:
        assign
        tn-f = ub._file._file-label.
      end.
    end.
    else do:
      assign
      tn-f = tt-file.file-label.
    end.
    display
      tn @ fl
      with frame ddd
    .
    put stream NameStream unformatted "&glob bef-table_" + tn + "-full " + tn-f
      + chr(10)
      .
    put stream NameStream unformatted "&glob table_" + tn + "-full '~{&bef-table_" + tn + "-full~}':U"
      + chr(10)
      .
  end.
  put stream NameStream unformatted
    chr(47) + chr(42) + ' ':U + chr(36) + 'Workfile: ':U + chr(36) + ' e n d ':U + chr(42) + chr(47) + chr(10)
    + chr(10)
  .
  OUTPUT STREAM NameStream close.
  hide frame ddd no-pause.
end.
RETURN.
