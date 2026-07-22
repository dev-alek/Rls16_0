block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.inkas OLD old-inkas .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись inkas".
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
    assign
      p-vss-parameters = substitute('&1|&2', ub.inkas.inkas-code, ub.inkas.status_)
    .
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
procedure write-inkas-history :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.inkas.host-code no-undo .
define input parameter p-obj-type like ub.inkas.obj-type no-undo .
define input parameter p-obj-code like ub.inkas.obj-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-message as character no-undo .
define variable varobj-date as date no-undo .
define variable varshift-date as date no-undo .
define variable varshift-num as integer no-undo .
define variable v-shift-name as character no-undo.
define variable l-shift-on as logical no-undo .
define variable varshift-name as character no-undo .
define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_c-inkas-pay for ub.c-inkas-pay.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output varobj-date
  ) no-error .
  if error-status :error
  or varobj-date = ?
  then do:
   v-message = substitute("Нет текущей даты на объекте продажи &1 &2&3&4&5 &6"
                , buf_inkas.inkas-code
                , p-obj-type
                , p-obj-code
                , chr(10)
                , error-status:get-message(1)
                , return-value
                ).
    undo, return error v-message.
  end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
  end.
  else do:
    assign
      varshift-date = ?
      varshift-num  = ?
    .
  end.
    create buf_c-inkas.
    buffer-copy buf_inkas to buf_c-inkas
    assign
    buf_c-inkas.inkas-code         = p-inkas-code
    buf_c-inkas.obj-type           = p-obj-type
    buf_c-inkas.obj-code           = p-obj-code
    buf_c-inkas.host-code          = p-host-code
    buf_c-inkas.chip-num           = next-value (s-corr-chip, ub)
    buf_c-inkas.corr-time          = v-time
    buf_c-inkas.corr-user-name     = g#userid
    buf_c-inkas.real-corr-date     = v-date
    buf_c-inkas.corr-date          = varobj-date
    buf_c-inkas.corr-shift-date    = varshift-date
    buf_c-inkas.corr-shift-num     = varshift-num
    buf_c-inkas.corr-shift-name    = varshift-name
    buf_c-inkas.corr-user-db-num   = g#db-num
    .
    release buf_c-inkas.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable conf-par        as character no-undo .
define variable par-type        as character no-undo .
define variable v-creating-hist as logical   no-undo .
define variable v-cmp           as character no-undo .
define variable varshift-name   as character no-undo .
define variable v-attr-value    as character no-undo .
define variable v-attr-type     as character no-undo .
define variable v-send          as logical   no-undo .
define buffer buf_sysconf  for ub.sysconf .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_trn-doc  for ub.trn-doc.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if not g#news
        then
    do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.inkas.user-db-num
  ,output ub.inkas.user-name
  ,output ub.inkas.sys-date
  ,output ub.inkas.sys-time
  ,output ub.inkas.sys-time-int
  )  .
    end.
    if  not new ub.inkas
        and (old-inkas.status_ = 'факт':U or old-inkas.status_ = 'запрос':U)
        and ub.inkas.status_  <> old-inkas.status_ then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Изменение статуса продажи невозможно" skip
            "Продажа" ub.inkas.inkas-code skip
            "Продажа закрыта до статуса" 'факт':U skip
            "Нельзя изменить статус продажи на" ub.inkas.status_ skip
            view-as alert-box error .
        undo main-block, return error.
    end.
    if not g#news then
    do:
        buffer-compare old-INKAS
            to ub.inkas
            case-sensitive
            save result in v-cmp
            .
        if v-cmp <> "":U
            and (lookup('status_':U, v-cmp) > 0
            or
            lookup('sale-filter':U, v-cmp) > 0
            or
            lookup('is-auto-born':U, v-cmp) > 0
            or
            lookup('is-auto-close':U, v-cmp) > 0
            or
            lookup('is-auto-get':U, v-cmp) > 0
            or
            lookup('is-auto-rsrv':U, v-cmp) > 0
            or
            lookup('doc-date':U, v-cmp) > 0
            or
            lookup('fact-date':U, v-cmp) > 0
            or
            lookup('flag_':U, v-cmp) > 0
            or
            lookup('shift-date':U, v-cmp) > 0
            or
            lookup('shift-num':U, v-cmp) > 0
            or
            lookup('shift-name':U, v-cmp) > 0
            or
            lookup('acc-date':U, v-cmp) > 0
            or
            lookup('user-name':U, v-cmp) > 0
            )
            then
        do:
            assign
                v-creating-hist = yes
                .
            run write-inkas-history in this-procedure (buffer old-INKAS
                ,ub.inkas.inkas-code
                ,ub.inkas.host-code
                ,ub.inkas.obj-type
                ,ub.inkas.obj-code).
        end.
    end.
    if old-inkas.status_ = ub.inkas.status_ then
    do:
        return .
    end.
    if  not g#news
        and ub.inkas.status_ = 'запрос':U
        then
    do:
        assign
            v-send = no
            .
        define buffer buf_Sale-doc for ub.sale-doc.
        _trn-doc:
        for each buf_sale-doc no-lock where
            buf_sale-doc.inkas-code = ub.inkas.inkas-code,
            first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_Sale-doc.doc-code
            or buf_trn-doc.out-code = ub.inkas.inkas-code
            on error
            undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ):
            if buf_trn-doc.ext-doc-type = 'es':U
                or buf_trn-doc.ext-doc-type = 'rs':U
                or buf_sale-doc.order > 0
                then
            do:
                v-send = yes.
            end.
            if v-send then
            do:
                run str/callnews.p (
                    input 'trn-doc':U
                    ,input (buffer buf_trn-doc:handle)
                    ) no-error .
                if error-status :error then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Невозможно маршрутизировать запрос для продажи для отправки в новости" skip
                        "Документ" buf_trn-doc.doc-code skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo, return error .
                end.
            end.
        end.
    end.
    if  not g#news
        and (ub.inkas.status_ = 'факт':U
        or
        ub.inkas.status_ = 'запрос':U)
        then
    do:
        run str/callnews.p
            (input 'inkas':U
            ,input (buffer ub.inkas:handle)
            ) no-error .
        if error-status :error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Невозможно маршрутизировать inkas для отправки в новости" skip
                "Документ" ub.inkas.inkas-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    run trg/userlog.p (
        input 'create':U
        , input 'inkas':U
        , input ( buffer ub.inkas :handle )
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
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'update':U
            , input 'inkas':U
            , input ( buffer ub.inkas:handle )
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_inkas':U
  ,input  buffer old-inkas:handle
  ,input  buffer ub.inkas:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
        then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , chr(10)
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
end.
