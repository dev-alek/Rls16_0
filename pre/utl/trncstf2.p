block-level on error undo, throw.
define input  parameter parparentproc   as   handle               no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trncstf2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trncstf2.p $":U .
define variable vss-description as character no-undo init "Обновление информации о ГТД партий зарезервированных за документом".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_parts   for ub.parts   .
define variable lok             as logical no-undo .
define variable v-lookup-ind    as integer no-undo .
define variable v-update-ind    as integer no-undo .
define variable v-error-ind     as integer no-undo .
define variable v-today         as date    no-undo.
define variable v-time          as integer no-undo.
define variable loc-ref-list as character no-undo .
define variable v-doc-rec    as integer   no-undo .
do
on error undo, return error
:
  run str/all-docs.w
    (input  parparentproc ,
      input v-cntxt-host-code-obj,
      input v-cntxt-obj-type,
      input v-cntxt-obj-code
    ,input  'выбор':U
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  ?
    ,input  "b-sel":U
    ,input  ?
    ,input  ?
    ,input  ?
    ,output loc-ref-list
    ) .
  assign
    v-doc-rec = integer(entry (1, loc-ref-list)).
  find trn-doc no-lock
    where recid (trn-doc) = v-doc-rec
    no-error .
  if available trn-doc then do:
    message
      "Проставить ГТД во все партии документа" ub.trn-doc.doc-code skip
      "на основании ГТД партий приходных документов." skip
      "Продолжить?" skip
      view-as alert-box question buttons ok-cancel update lok .
    if lok <> true then do:
      return .
    end.
    output to trncstf2.txt append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export
      "update_cst-code_in_trn-doc"
      string(v-today, "99/99/9999")
      string(v-time, "HH:MM")
      ub.trn-doc.doc-code
      .
    output close .
    do transaction
    on error undo, return error
    :
      for each ub.parts exclusive-lock
        where ub.parts.out-code = ub.trn-doc.doc-code
      on error undo, return error
      :
        assign
          v-lookup-ind = v-lookup-ind + 1
        .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = ub.parts.in-code
          no-error .
        if available buf_trn-doc then do:
          find first buf_parts no-lock
            where buf_parts.obj-type  = buf_trn-doc.obj-type
              and buf_parts.obj-code  = buf_trn-doc.obj-code
              and buf_parts.artic     = ub.parts.artic
              and buf_parts.prod-type = ub.parts.prod-type
              and buf_parts.prod-code = ub.parts.prod-code
              and buf_parts.in-code   = ub.parts.in-code
              and buf_parts.out-code  = ub.parts.in-code
              and buf_parts.part-code = ub.parts.part-code
            no-error .
          if available buf_parts then do:
            if ub.parts.cst-code <> buf_parts.cst-code then do:
              assign
                v-update-ind = v-update-ind + 1
              .
              output to trncstf2.fix append .
              run cur-time in this-procedure ( output v-today
                                             , output v-time
                                             ).
              export
                string(v-today, "99/99/9999")
                string(v-time, "HH:MM")
                "update_parts_old-cst-code_new-cst-code"
                ub.parts.cst-code buf_parts.cst-code
                .
              export ub.parts .
              output close .
              assign
                ub.parts.cst-code = buf_parts.cst-code
              .
            end.
          end.
          else do:
            assign
              v-error-ind = v-error-ind + 1
            .
            output to trncstf2.err append .
            run cur-time in this-procedure ( output v-today
                                           , output v-time
                                           ).
            export
              "income_parts_not_found"
              string(v-today, "99/99/9999")
              string(v-time, "HH:MM")
              ub.parts.in-code
              ub.parts.part-code
              .
            export ub.parts .
            output close .
          end.
        end.
        else do:
          assign
            v-error-ind = v-error-ind + 1
          .
          output to trncstf2.err append .
          run cur-time in this-procedure ( output v-today
                                         , output v-time
                                         ).
          export
            "income_trn-doc_not_found"
            string(v-today, "99/99/9999")
            string(v-time, "HH:MM")
            ub.parts.in-code
            .
          export ub.parts .
          output close .
        end.
      end.
    end.
    if v-error-ind = 0 then do:
      message
        "Документ" ub.trn-doc.doc-code skip
        "Просмотр ГТД в партиях документа закончен." skip
        "Просмотрено партий" v-lookup-ind skip
        "Исправлено ГТД " v-update-ind skip
        view-as alert-box information .
    end.
    else do:
      message
        "Документ" ub.trn-doc.doc-code skip
        "Просмотр ГТД в партиях документа закончен." skip
        "Просмотрено партий" v-lookup-ind skip
        "Исправлено ГТД " v-update-ind skip
        "Ошибок" v-error-ind skip
        "Полный список ошибок в файле trncstf2.err" skip
        view-as alert-box error .
    end.
  end.
end.
