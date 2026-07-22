block-level on error undo, throw.
define input parameter p-have-correct    as character          no-undo.
on write    of fbr-line override do: end.
on delete   of fbr-line override do: end.
on write    of fbr-doc  override do: end.
on delete   of fbr-doc  override do: end.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrcorr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fbrcorr.p $":U .
define variable vss-description as character no-undo init "Проверка и правка документа производства".
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
define stream log-stream.
    define variable v-doc-code    as character    no-undo.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_fbr-doc
  , buf_fbr-line
on error undo, return error return-value
:
if session :set-wait-state( "compiler" ) then.
    run write-log in this-procedure (
          input 0
        , input "&DLine":U
    ).
    run write-log in this-procedure (
          input 0
        , input ( if p-have-correct = "delete":U then "Корректировка " else "Проверка " ) + "документов производства."
    ).
    test-fbr-line:
    for each buf_fbr-line exclusive-lock
    on error undo, return error
    :
        assign
            v-doc-code = buf_fbr-line.doc-code
        .
        find first buf_fbr-doc exclusive-lock
             where buf_fbr-doc.doc-code = v-doc-code
        no-error no-wait.
        if not available buf_fbr-doc
        then do:
            if locked buf_fbr-doc
            then do:
                run write-log in this-procedure (
                      input 1
                    , input substitute( "*** Документ производства '&1' заблокирован. Проверка строк невозможна."
                                        , v-doc-code )
                ).
                undo test-fbr-line, next test-fbr-line.
            end.
            else do:
                if p-have-correct = "delete":U
                then do:
                    delete buf_fbr-line.
                end.
                run write-log in this-procedure (
                      input 1
                    , input substitute( "&1далена строка документа производства '&2'. Не найдена шапка документа."
                                        , ( if p-have-correct = "delete":U then "У" else "Должна быть у" )
                                        , v-doc-code )
                ).
            end.
        end.
    end.
    run test-by-trn-docs in this-procedure .
if session :set-wait-state( "" ) then.
    message
        ( if p-have-correct = "delete":U then "Корректировка " else "Проверка " ) "документов производства завершена."
        skip "Результат выведен в файл fbrcorr.txt"
        skip "в рабочем каталоге TradeHouse."
    view-as alert-box information
    title ( if p-have-correct = "delete":U then "Корректировка " else "Проверка " ) + "документов производства".
    run write-log in this-procedure (
          input 0
        , input "&DLine":U
    ).
end.
procedure test-by-trn-docs :
    define variable v-have-trn-doc  as logical      no-undo.
    define variable v-doc-code      as character    no-undo.
    define variable v-doc-code-eq   as character    no-undo.
    define variable v-doc-code-as   as character    no-undo.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_trn-doc
  , buf_fbr-doc
  , buf_fbr-line
on error undo, return error
:
    test-fbr-doc:
    for each buf_fbr-doc exclusive-lock
    on error undo, return error
    :
        assign
            v-doc-code      = buf_fbr-doc.doc-code
            v-doc-code-eq   = replace( v-doc-code, "-":U, "=":U )
            v-doc-code-as   = replace( v-doc-code, "-":U, "*":U )
            v-have-trn-doc  = yes
        .
        if buf_fbr-doc.status_ = 'факт':U
        then do:
            find first buf_trn-doc exclusive-lock
                 where buf_trn-doc.doc-code = v-doc-code
            no-error no-wait.
            if available buf_trn-doc
            then do:
                assign
                    v-have-trn-doc = yes
                .
            end.
            else do:
                if locked buf_trn-doc
                then do:
                    run write-log in this-procedure (
                          input 1
                        , input substitute( "*** Документ списания по производству '&1' заблокирован. Проверка соответствующего документа производства невозможна."
                                            , v-doc-code )
                    ).
                    undo test-fbr-doc, next test-fbr-doc.
                end.
                else do:
                    assign
                        v-have-trn-doc = no
                    .
                end.
            end.
            if v-have-trn-doc = no
            then do:
                find first buf_trn-doc exclusive-lock
                     where buf_trn-doc.doc-code = v-doc-code-eq
                no-error no-wait.
                if available buf_trn-doc
                then do:
                    assign
                        v-have-trn-doc = yes
                    .
                end.
                else do:
                    if locked buf_trn-doc
                    then do:
                        run write-log in this-procedure (
                              input 1
                            , input substitute( "*** Документ прихода по производству '&1' заблокирован. Проверка соответствующего документа производства невозможна."
                                                , v-doc-code )
                        ).
                        undo test-fbr-doc, next test-fbr-doc.
                    end.
                    else do:
                        assign
                            v-have-trn-doc = no
                        .
                    end.
                end.
            end.
            if v-have-trn-doc = no
            then do:
                find first buf_trn-doc exclusive-lock
                     where buf_trn-doc.doc-code = v-doc-code-as
                no-error no-wait.
                if available buf_trn-doc
                then do:
                    assign
                        v-have-trn-doc = yes
                    .
                end.
                else do:
                    if locked buf_trn-doc
                    then do:
                        run write-log in this-procedure (
                              input 1
                            , input substitute( "*** Документ прихода по производству '&1' заблокирован. Проверка соответствующего документа производства невозможна."
                                                , v-doc-code )
                        ).
                        undo test-fbr-doc, next test-fbr-doc.
                    end.
                    else do:
                        assign
                            v-have-trn-doc = no
                        .
                    end.
                end.
            end.
            if v-have-trn-doc = no
            then do:
                run write-log in this-procedure (
                      input 1
                    , input substitute( "&1далён документ производства в статусе 'факт' номер '&2': документ не образует ни одного складского документа."
                                        , ( if p-have-correct = "delete":U then "У" else "Должен быть у" )
                                        , v-doc-code )
                ).
                if p-have-correct = "delete":U
                then do:
                    for each buf_fbr-line exclusive-lock
                       where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
                    :
                        delete buf_fbr-line.
                    end.
                    delete buf_fbr-doc.
                end.
            end.
        end.
    end.
end.
end procedure.
procedure write-log :
define input parameter p-log-level  as integer      no-undo.
define input parameter p-out-string as character    no-undo.
do
on error undo, return error
:
    output stream log-stream to value( "fbrcorr.txt":U ) append.
    put stream log-stream unformatted
        chr(10)
    .
    put stream log-stream unformatted
        ( if p-log-level = 0
          or p-out-string = "&DLine":U
          or p-out-string = "&Line":U
          then "":U
          else cur-time-string-sec() + fill( " ":U, p-log-level * 2 ) )
    .
    put stream log-stream unformatted
        ( if p-out-string = "&Line":U
          then fill( "-":U, 80 )
          else if p-out-string = "&DLine":U
               then fill( "=":U, 80 )
               else p-out-string )
    .
    output stream log-stream close.
end.
end procedure.
