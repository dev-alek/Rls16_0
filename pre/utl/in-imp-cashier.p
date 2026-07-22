block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: in-imp-cashier.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/in-imp-cashier.p $":U .
define variable vss-description as character no-undo init "импорт клиентов из excel".
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define input parameter parparentproc     as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable my-seek1 as integer.
define variable my-seek2 as integer.
define variable my-mess as char.
  define stream InStream.
define stream logstream .
DEFINE VARIABLE chExcelApplication AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook         AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet        AS COM-HANDLE no-undo .
define variable ss                 as character  no-undo.
define variable cod-fiz            as integer    no-undo.
define variable num-BD             as integer    no-undo.
define variable code-cashier       as integer    no-undo.
define variable password           as character  no-undo.
define buffer buf_staff for staff.
define variable v-date-start   as date      no-undo.
define variable v-date-end     as date      no-undo.
define variable p-rid          as recid     no-undo.
define variable v-work-place   as character no-undo.
define variable v-time         as integer   no-undo.
define variable v-today        as date      no-undo.
define variable v-level        as character no-undo.
define variable v-host-code    as integer   no-undo.
define variable v-obj-type     as character no-undo.
define variable v-obj-code     as integer   no-undo.
define variable num-rec        as integer   no-undo.
define variable num-rec-ok     as integer   no-undo.
define variable file-name as character no-undo.
define variable ff             as character no-undo.
define variable var-name-sheet as character no-undo .
chworkbook = chexcelapplication:activeworkbook no-error.
define variable log-file-name                as character      no-undo init "imp-cashier.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
file-name   =  p-parameter no-error.
if error-status:error then
do:
    run write-log-and-file in p-log-handle (
        input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка входных параметров &1:&2&3&4"
        , p-parameter
        , chr(10)
        , error-status:get-message(1)
        , return-value
        )).
    assign
        v-view-log = yes.
    .
end.
run gbl/filename.p (
                 input  file-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
    chworkbook = chexcelapplication:activeworkbook no-error.
    run ex-file in this-procedure   (v-full-path, false) .
    chworkbook   = chexcelapplication:activeworkbook no-error.
    chworksheet  = chexcelapplication:sheets:item(1):select  no-error.
    chworksheet  = chexcelapplication:sheets:item(1) no-error.
run import-proc in this-procedure  no-error .
if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "import-proc"
        view-as alert-box error
        .
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.
procedure import-proc:
    define variable ii           as integer   no-undo.
    define variable t            as char      no-undo.
    define variable type-clients as char      no-undo.
    define variable code-clients as char      no-undo.
    define variable name-clients as char      no-undo.
    define variable n-entry      as char      no-undo extent 40.
    define variable alf          as character no-undo.
    define variable nen          as integer   no-undo .
    run cur-time in this-procedure ( output v-today, output v-time).
    ii = 1 .
    _stroka:
    REPEAT ON ERROR UNDO, leave:
       ss = "".
        ii = ii  + 1.
        T = string(ii) .
        if chWorkSheet:Range ('A' + T):Value  = ? then leave _stroka.
        num-rec = num-rec + 1.
        nen = 1 .
        alf = "a,b,c,d,e".
        mass: do nen = 1 to 5:
            n-entry[nen] = chWorkSheet:Range ( entry(nen, alf, ",") + T) :value.
            if  n-entry[nen] = ? then   n-entry[nen]  = "" .
            ss = ss +   n-entry[nen] + ";".
        end.
        cod-fiz     = integer( entry(1, ss , ";")) no-error.
        num-BD    = integer(entry(2, ss ,";")) no-error.
        code-cashier = integer(entry(3, ss ,";")) no-error.
        password = entry(4 , ss ,";") no-error.
        if LENGTH(string(code-cashier)) > 3 then do:
            my-mess =     substitute("Код кассира превышает 3 символа"
                , 'C':U
                , chr(10)
                , error-status:get-message(1)
                , return-value ) .
            run err-write in this-procedure ( input-output my-mess , v-obj-code , v-obj-type  ).
            .
            next  _stroka.
        end.
        find first clients where clients.obj-code = cod-fiz and clients.obj-type = 'чел':U no-lock no-error.
        v-work-place = string(num-BD , '99999').
        assign
            v-level      = 'db':U
            v-host-code  = 0
            v-obj-type   = '':U
            v-obj-code   = 0
            v-date-start = v-today + 1
            v-date-end   = 12/31/9999
            .
        run ref/staff01.p (
            input-output p-rid
            ,input 'ДОБАВЛЕНИЕ':U
            ,input no
            ,input 'C':U
            ,input code-cashier
            ,input clients.obj-code
            ,input v-level
            ,input v-date-start
            ,input v-date-end
            ,input num-BD
            ,input v-host-code
            ,input v-obj-type
            ,input v-obj-code
            ,input v-work-place
            ,input password) no-error .
        if error-status:error then
        do:
            my-mess =     substitute("Ошибка при сохранении записи &1&2&3&2&4"
                , 'C':U
                , chr(10)
                , error-status:get-message(1)
                , return-value ) .
            run err-write in this-procedure ( input-output my-mess , v-obj-code , v-obj-type  ).
            .
        end.
        else
        do:
            num-rec-ok = num-rec-ok + 1 .
        end.
        next  _stroka.
    end.
end procedure.
run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт кассиров из файла &1 завершен: из &2 записей успешно закачано &3&4&5"
    , file-name
    , num-rec
    , num-rec-ok
    , chr(10) )
    ).
.
input stream InStream close.
PROCEDURE ex-file :
    define input parameter ff as character no-undo .
    define input parameter ex as logical no-undo .
    if ex = false then
    do:
        create "excel.application" chexcelapplication connect no-error.
        if error-status:error then
        do:
            create "excel.application" chexcelapplication no-error.
           if error-status :error then
           do:
              message
                 "Ошибка при запуске Excel" skip
                 error-status :get-message(1) skip
                 view-as alert-box error .
              undo, return error .
           end.
        end.
        if ff = ""  then
        do:
            chworkbook   = chexcelapplication:workbooks:add( ).
        end.
        else
        do:
            chworkbook   = chexcelapplication:workbooks:open( ff ).
        end.
    end.
    chworksheet  = chexcelapplication:sheets:item (1).
END PROCEDURE.
PROCEDURE err-write:
    DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
    define input parameter p-obj-code as integer no-undo.
    define input parameter p-obj-type as char no-undo.
    seek STREAM Instream to my-seek1.
    import stream InStream .
    run write-log-and-file in p-log-handle (
        input 1
        , input log-file-name
        , input 1
        , input mess + chr(10) + p-obj-type + "   " + string(p-obj-code)  ).
    assign
        v-view-log = yes.
    mess = "".
    seek STREAM Instream to my-seek2.
END PROCEDURE.
