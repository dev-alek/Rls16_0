block-level on error undo, throw.
define parameter buffer buf_chk-doc for ub.chk-doc.
define input parameter p-validate    as logical no-undo .
define input parameter p-add         as logical no-undo .
define input parameter p-del         as logical no-undo .
define input-output parameter p-chip-num like ub.c-chk-doc.chip-num no-undo .
define output parameter p-is-update as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: d765e193a656, 1242, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2018/02/26 16:31:29 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-doch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: trg/chk-doch.p $":U .
define variable vss-description as character no-undo init "Запись истории для таблицы chk-doc".
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
define variable v-create   as logical no-undo .
define variable v-is-equal as logical no-undo .
define variable v-date     as date    no-undo.
define variable v-time     as integer no-undo.
define buffer buf_c-chk-doc      for ub.c-chk-doc.
define buffer buf_c-chk-gds      for ub.c-chk-gds.
define buffer buf_c-chk-pay      for ub.c-chk-pay.
define buffer buf_c-chk-discnt   for ub.c-chk-discnt.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_c-marking-chk  for ub.c-marking-chk.
define buffer last_c-chk-doc     for ub.c-chk-doc.
define buffer buf_chk-gds        for ub.chk-gds.
define buffer buf_chk-pay        for ub.chk-pay.
define buffer buf_chk-discnt     for ub.chk-discnt.
define buffer buf_chk-doc-attr   for ub.chk-doc-attr.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_chk-pay-attr for ub.chk-pay-attr.
define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
define buffer buf_marking-chk for marking-chk.
_main:
do
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):
    if p-validate = no
        or p-add
        or p-del
        then
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        if p-chip-num > 0 then
        do:
            find first buf_c-chk-doc where
                buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-doc.chip-num = p-chip-num no-error .
        end.
        if not available buf_c-chk-doc then
        do:
            find last last_c-chk-doc no-lock where
                last_c-chk-doc.doc-code = buf_chk-doc.doc-code no-error .
            if available last_c-chk-doc then
            do:
                assign
                    p-chip-num = last_c-chk-doc.chip-num + 1
                    .
            end.
            else
            do:
                assign
                    p-chip-num = 1
                    .
            end.
            create buf_c-chk-doc.
            assign
                buf_c-chk-doc.doc-code         = buf_chk-doc.doc-code
                buf_c-chk-doc.chip-num         = p-chip-num
                buf_c-chk-doc.corr-user-db-num = g#db-num
                buf_c-chk-doc.corr-user-name   = g#userid
                buf_c-chk-doc.corr-time        = v-time
                buf_c-chk-doc.corr-date        = v-date
                buf_c-chk-doc.is-del           = p-del
                buf_c-chk-doc.is-add           = (if available last_c-chk-doc
                                      then last_c-chk-doc.is-add
                                      else p-add)
                v-create                       = yes
                .
            if p-add then
            do:
                run trg/userlog.p (
                    input 'create':U
                    , input 'c-chk-doc':U
                    , input ( buffer buf_c-chk-doc :handle )
                    , input ?
                    , input ""
                    ) no-error.
                if error-status :error
                    then
                do:
                    undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , chr(10)
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                end.
            end.
            if p-del then
            do:
                run trg/userlog.p (
                    input 'delete':U
                    , input 'c-chk-doc':U
                    , input ( buffer buf_c-chk-doc :handle )
                    , input ?
                    , input ""
                    ) no-error.
                if error-status :error
                    then
                do:
                    undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , chr(10)
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                end.
            end.
        end.
        else
        do:
            assign
                buf_c-chk-doc.corr-user-db-num = g#db-num
                buf_c-chk-doc.corr-user-name   = g#userid
                buf_c-chk-doc.corr-time        = v-time
                buf_c-chk-doc.corr-date        = v-date
                buf_c-chk-doc.is-del           = p-del
                buf_c-chk-doc.is-add           = p-add
                .
        end.
        buffer-copy buf_chk-doc
            except doc-code PS
            to buf_c-chk-doc.
        if not v-create then
        do:
            for each buf_c-chk-gds where
                buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-gds.chip-num = p-chip-num:
                delete buf_c-chk-gds.
            END.
            for each buf_c-chk-pay where
                buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-pay.chip-num = p-chip-num:
                delete buf_c-chk-pay.
            END.
            for each buf_c-chk-discnt where
                buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-discnt.chip-num = p-chip-num
                :
                delete buf_c-chk-discnt.
            END.
            for each buf_c-chk-doc-attr where
                buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-doc-attr.chip-num = p-chip-num:
                delete buf_c-chk-doc-attr.
            END.
            for each buf_c-marking-chk where
                buf_c-marking-chk.doc-code = buf_chk-doc.doc-code
                AND buf_c-marking-chk.chip-num = p-chip-num:
                delete buf_c-marking-chk.
            END.
        end.
        for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
            create buf_c-chk-gds.
            buffer-copy buf_chk-gds
                to buf_c-chk-gds
                assign
                buf_c-chk-gds.chip-num = p-chip-num
                buf_c-chk-gds.corr-user-db-num = g#db-num
                .
        end.
        for each buf_chk-pay no-lock where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
            create buf_c-chk-pay.
            buffer-copy buf_chk-pay
                to buf_c-chk-pay
                assign
                buf_c-chk-pay.chip-num = p-chip-num
                buf_c-chk-pay.corr-user-db-num = g#db-num
                .
        end.
        for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
            create buf_c-chk-discnt.
            buffer-copy buf_chk-discnt
                to buf_c-chk-discnt
                assign
                buf_c-chk-discnt.chip-num = p-chip-num
                buf_c-chk-discnt.corr-user-db-num = g#db-num
                .
        end.
        for each buf_chk-doc-attr no-lock where
            buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
            on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
            create buf_c-chk-doc-attr.
            buffer-copy buf_chk-doc-attr
                to buf_c-chk-doc-attr
                assign
                buf_c-chk-doc-attr.chip-num = p-chip-num
                buf_c-chk-doc-attr.corr-user-db-num = g#db-num
                .
        end.
        for each buf_marking-chk no-lock where
                 buf_marking-chk.doc-code = buf_chk-doc.doc-code
                 on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
                 find first buf_c-marking-chk where
                            buf_c-marking-chk.doc-code = buf_chk-doc.doc-code
                        AND buf_c-marking-chk.chip-num = p-chip-num no-error.
                 if not available buf_c-marking-chk then do:
                    create buf_c-marking-chk.
                    buffer-copy buf_marking-chk
                    to buf_c-marking-chk
                    assign
                    buf_c-marking-chk.chip-num = p-chip-num
                    buf_c-marking-chk.corr-user-db-num = g#db-num
                    .
                 end.
        end.
    for each buf_chk-gds-attr no-lock where
            buf_chk-gds-attr.doc-code = buf_chk-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      create buf_c-chk-doc-attr.
      buffer-copy buf_chk-gds-attr
      to buf_c-chk-doc-attr
      assign
      buf_c-chk-doc-attr.attr-code = "gds=" + string(buf_chk-gds-attr.line-num) + chr(4) + buf_chk-gds-attr.attr-code
      buf_c-chk-doc-attr.chip-num = p-chip-num
      buf_c-chk-doc-attr.corr-user-db-num = g#db-num
      .
    end.
    for each buf_chk-pay-attr no-lock where
            buf_chk-pay-attr.doc-code = buf_chk-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      create buf_c-chk-doc-attr.
      buffer-copy buf_chk-pay-attr
      to buf_c-chk-doc-attr
      assign
      buf_c-chk-doc-attr.attr-code = "pay=" + string(buf_chk-pay-attr.line-num) + chr(4) + buf_chk-pay-attr.attr-code
      buf_c-chk-doc-attr.chip-num = p-chip-num
      buf_c-chk-doc-attr.corr-user-db-num = g#db-num
      .
    end.
    for each buf_chk-discnt-attr no-lock where
            buf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code
    on error undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)):
      create buf_c-chk-doc-attr.
      buffer-copy buf_chk-discnt-attr
      to buf_c-chk-doc-attr
      assign
      buf_c-chk-doc-attr.attr-code = "discnt=" + string(buf_chk-discnt-attr.line-num)
                                   + chr(3) + string(buf_chk-discnt-attr.record-type)
                                   + chr(3) + string(buf_chk-discnt-attr.discnt-id)
                                   + chr(3) + string(buf_chk-discnt-attr.object-line-num)
                                   + chr(4) + buf_chk-discnt-attr.attr-code
      buf_c-chk-doc-attr.chip-num = p-chip-num
      buf_c-chk-doc-attr.corr-user-db-num = g#db-num
      .
    end.
         if p-del
            and ( g#db-num > 0 )
            then
        do:
            run str/callnews.p
                (input 'c-chk-doc':U
                ,input (buffer buf_c-chk-doc:handle)
                ) no-error .
        end.
    end.
    else
    do:
        find first buf_c-chk-doc where
            buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-doc.chip-num = p-chip-num .
        buffer-compare
            buf_c-chk-doc
            EXCEPT PS
            to buf_chk-doc
            case-sensitive
            save result in v-is-equal
            .
        if not v-is-equal then
        do:
            assign
                p-is-update = yes
                .
            return.
        end.
        for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code:
            find first buf_c-chk-gds no-lock where
                buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-gds.chip-num = p-chip-num
                AND buf_c-chk-gds.line-num = buf_chk-gds.line-num no-error .
            if not avail buf_c-chk-gds then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-gds to buf_chk-gds
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_chk-pay no-lock where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code:
            find first buf_c-chk-pay no-lock where
                buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-pay.chip-num = p-chip-num
                AND buf_c-chk-pay.line-num = buf_chk-pay.line-num no-error .
            if not avail buf_c-chk-pay then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-pay to buf_chk-pay
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            AND buf_chk-discnt.record-type < 2
            :
            find first buf_c-chk-discnt no-lock where
                buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-discnt.chip-num = p-chip-num
                AND buf_c-chk-discnt.line-num = buf_chk-discnt.line-num
                AND buf_c-chk-discnt.discnt-id = buf_chk-discnt.discnt-id
                AND buf_c-chk-discnt.object-line-num = buf_chk-discnt.object-line-num
                AND buf_c-chk-discnt.record-type     = buf_chk-discnt.record-type
                no-error .
            if not avail buf_c-chk-discnt then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-discnt to buf_chk-discnt
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
            AND buf_chk-discnt.record-type >= 4
            and buf_chk-discnt.record-type <= 5
            :
            find first buf_c-chk-discnt no-lock where
                buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-discnt.chip-num = p-chip-num
                AND buf_c-chk-discnt.line-num = buf_chk-discnt.line-num
                AND buf_c-chk-discnt.discnt-id = buf_chk-discnt.discnt-id
                AND buf_c-chk-discnt.object-line-num = buf_chk-discnt.object-line-num
                AND buf_c-chk-discnt.record-type     = buf_chk-discnt.record-type
                no-error .
            if not avail buf_c-chk-discnt then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-discnt to buf_chk-discnt
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_chk-doc-attr no-lock where
            buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code:
            find first buf_c-chk-doc-attr no-lock where
                buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
                AND buf_c-chk-doc-attr.chip-num = p-chip-num
                AND buf_c-chk-doc-attr.attr-code = buf_chk-doc-attr.attr-code no-error .
            if not avail buf_c-chk-doc-attr then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
            buffer-compare
                buf_c-chk-doc-attr to buf_chk-doc-attr
                case-sensitive
                save result in v-is-equal
                .
            if not v-is-equal then
            do:
                assign
                    p-is-update = yes
                    .
                return.
            end.
        end.
        for each buf_c-chk-gds where
            buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-gds.chip-num = p-chip-num:
            delete buf_c-chk-gds.
        end.
        for each buf_c-chk-pay where
            buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-pay.chip-num = p-chip-num:
            delete buf_c-chk-pay.
        end.
        for each buf_c-chk-discnt where
            buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-discnt.chip-num = p-chip-num:
            delete buf_c-chk-discnt.
        end.
        for each buf_c-chk-doc-attr where
            buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
            AND buf_c-chk-doc-attr.chip-num = p-chip-num:
            delete buf_c-chk-doc-attr.
        end.
        for each buf_c-marking-chk where
            buf_c-marking-chk.doc-code = buf_chk-doc.doc-code
            AND buf_c-marking-chk.chip-num = p-chip-num:
            delete buf_c-marking-chk.
        END.
        delete buf_c-chk-doc.
    end.
end.
