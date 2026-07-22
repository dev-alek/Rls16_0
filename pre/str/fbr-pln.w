define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-list-procedure as handle           no-undo.
define input parameter p-mode           as character        no-undo.
define input parameter p-doc-code       as character        no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-userid         as character        no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Интерфейс плана-меню или счет-заказа.":U .
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure fbrpln-create-line :
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-fbr-obj-type   as character    no-undo.
define input parameter p-fbr-obj-code   as integer      no-undo.
define input parameter p-silence        as logical      no-undo.
define input parameter p-qnty           as decimal      no-undo.
    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_goods         for goods.
do
for buf_fbr-pln
  , buf_fbr-pln-line
  , buf_goods
on error undo, return error
:
    find first buf_fbr-pln no-lock
         where buf_fbr-pln.doc-code = p-doc-code
    .
    if buf_fbr-pln.status_ <> 'новый':U
    then do:
        if p-silence = no
        then do:
            message
                skip "Добавить строки можно только"
                skip "в документ в статусе 'новый'"
            view-as alert-box error.
        end.
        undo, return error .
    end.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    if p-recipe-code <> ""
    and p-fbr-obj-type = ""
    and p-fbr-obj-code = 0
    then do:
        if p-silence = no
        then do:
            message
                skip "Не задан объект для производства товара с рецептом."
                skip "Товар: " buf_goods.artic buf_goods.gds-name
                skip(1)
                skip "Товар не может быть включен в план-меню."
            view-as alert-box error.
        end.
        undo, return error .
    end.
    do transaction
    on error undo, return error
    :
        create buf_fbr-pln-line.
        assign
            buf_fbr-pln-line.doc-code       = p-doc-code
            buf_fbr-pln-line.gds-code       = p-gds-code
            buf_fbr-pln-line.recipe-code    = p-recipe-code
            buf_fbr-pln-line.obj-type       = buf_fbr-pln.obj-type
            buf_fbr-pln-line.obj-code       = buf_fbr-pln.obj-code
            buf_fbr-pln-line.doc-type       = buf_fbr-pln.doc-type
            buf_fbr-pln-line.fact-qnty      = p-qnty
            buf_fbr-pln-line.artic          = buf_goods.artic
            buf_fbr-pln-line.prod-type      = buf_goods.prod-type
            buf_fbr-pln-line.prod-code      = buf_goods.prod-code
            buf_fbr-pln-line.fbr-obj-type   = p-fbr-obj-type
            buf_fbr-pln-line.fbr-obj-code   = p-fbr-obj-code
            buf_fbr-pln-line.status_        = buf_fbr-pln.status_
        .
    end.
end.
end procedure.
procedure fbrpln-create-doc :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-doc-type   as character    no-undo.
define input parameter p-db-remote  as logical          no-undo.
define input parameter p-userid     as character        no-undo.
define output parameter p-doc-code  as character    no-undo.
    define variable v-today     as date           no-undo.
    define variable v-time      as integer        no-undo.
    define variable v-host-code as integer        no-undo.
    define variable v-doc-code  as character      no-undo.
    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_fbr-pln
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    run fbrpln-doc-code (
          input p-obj-type
        , input p-obj-code
        , input p-db-remote
        , output v-doc-code
    ).
    create buf_fbr-pln.
    assign
        buf_fbr-pln.doc-code        = v-doc-code
        buf_fbr-pln.doc-type        = p-doc-type
        buf_fbr-pln.obj-type        = p-obj-type
        buf_fbr-pln.obj-code        = p-obj-code
        buf_fbr-pln.doc-date        = v-today
        buf_fbr-pln.creid           = p-userid
        buf_fbr-pln.PS              = ""
        buf_fbr-pln.fact-date       = ?
        buf_fbr-pln.fact-time       = ?
        buf_fbr-pln.fact-num        = 0
        buf_fbr-pln.fact-order      = 0
        buf_fbr-pln.host-code       = v-host-code
        buf_fbr-pln.status_         = 'новый':U
        buf_fbr-pln.sys-date        = v-today
        buf_fbr-pln.sys-time-int    = v-time
        buf_fbr-pln.sys-time        = string( v-time, "HH:MM:SS" )
        buf_fbr-pln.user-name       = p-userid
    .
    assign
        p-doc-code = buf_fbr-pln.doc-code
    .
end.
end procedure.
procedure fbrpln-create-fbr-doc :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-pln-doc-code   as character        no-undo.
define input parameter p-db-remote      as logical          no-undo.
define input parameter p-userid         as character        no-undo.
define output parameter p-doc-code      as character        no-undo.
    define variable v-today         as date             no-undo.
    define variable v-host-code     as integer          no-undo.
    define variable v-base-code     as integer          no-undo.
    define buffer buf_curr-accnt    for curr-accnt.
    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_curr-accnt
  , buf_fbr-doc
  , buf_fbr-pln
on error undo, return error
:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-today
  )  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
          and buf_curr-accnt.exch-date <= v-today
    use-index pi
    no-error.
    if not available buf_curr-accnt
    then do:
        message
            "На дату" v-today "неизвестен курс базовой валюты."
        view-as alert-box error.
        undo, return error.
    end.
    run doc-code in this-procedure (
          input  "main"
        , input  p-obj-type
        , input  p-obj-code
        , input  ?
        , output p-doc-code
    ) no-error.
    if error-status:error
    then do:
        message
            "Ошибка при генерации номера документа производства."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
        view-as alert-box error.
        return error.
    end.
    run trg/chkdocnm.p (
          input p-doc-code
        , input "fbr-doc"
        , input "?"
    ) no-error.
    if error-status:error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip "Ошибка при проверке номера для нового документа."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    create buf_fbr-doc.
    assign
        buf_fbr-doc.doc-code  = p-doc-code
        buf_fbr-doc.creid     = p-userid
        buf_fbr-doc.doc-date  = v-today
        buf_fbr-doc.doc-type  = 'производство':U
        buf_fbr-doc.host-code = v-host-code
        buf_fbr-doc.obj-type  = p-obj-type
        buf_fbr-doc.obj-code  = p-obj-code
        buf_fbr-doc.PS        = "@"
        buf_fbr-doc.status_   = 'новый':U
        buf_fbr-doc.out-code  = p-pln-doc-code
    .
end.
end procedure.
procedure fbrpln-doc-code :
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-db-remote  as logical      no-undo.
define output parameter p-doc-code  as character    no-undo.
do
on error undo, return error
:
    if p-db-remote = yes
    then do:
        assign
            p-doc-code = trim( string( next-value( s-fbr-doc, ub ), ">>>>>>>>>9" ) )
                        + "-"
                        + trim( string( p-obj-code, ">>>>9" ) )
                        + substring( p-obj-type, ( if g#language = "RUS" then 1 else 2 ), 1 )
        .
    end.
    else do:
        assign
            p-doc-code = trim( string( next-value( s-fbr-doc, ub ) ) ) + "-"
        .
    end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure fbrattr-write :
  define input parameter p-doc-type       as character        no-undo.
  define input parameter p-doc-code       as character        no-undo.
  define input parameter p-attr-code      as character        no-undo.
  define input parameter p-attr-value     as character        no-undo.
  do
  on error undo, return error
  :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input substitute('&1-&2',p-doc-type,p-doc-code) ,
                       input p-attr-code ,
                       input p-attr-value )  .
  end.
end procedure.
procedure fbrattr-value :
  define  input parameter p-doc-type      as character        no-undo.
  define  input parameter p-doc-code      as character        no-undo.
  define  input parameter p-attr-code     as character        no-undo.
  define output parameter p-attr-value    as character        no-undo.
  define variable v-par-value     as character    no-undo.
  define variable v-par-type      as character    no-undo.
  define buffer buf_clients       for ub.clients.
  do
  for buf_clients
  on error undo, return error
  :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input substitute('&1-&2',p-doc-type,p-doc-code) ,
                        input p-attr-code ,
                       output p-attr-value ,
                       output v-par-type )  .
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
    define variable v-fbr-pln-history-level     as integer      no-undo.
    define variable v-fbr-pln-hst-upper-code    as integer      no-undo.
    define variable v-fbr-pln-fbroperator-code  as integer      no-undo.
    define variable gds-rec                     as recid        no-undo.
    define buffer buf_init_fbr-pln       for fbr-pln.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON bt-billord
     LABEL "Заказ"
     SIZE 10 BY 1.
DEFINE BUTTON bt-fbr-docs
     LABEL "Произв"
     SIZE 10 BY 1.
DEFINE BUTTON bt-next
     LABEL ">>"
     SIZE 4 BY 1.
DEFINE BUTTON bt-prev
     LABEL "<<"
     SIZE 4 BY 1.
DEFINE VARIABLE fi-customer AS CHARACTER FORMAT "X(256)":U
     LABEL "Заказчик"
     VIEW-AS FILL-IN
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE fi-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-fact-date AS DATE FORMAT "99/99/9999":U
     LABEL "Факт"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-guest-amount AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Кол. гостей"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE fi-object AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-wrkr AS CHARACTER FORMAT "X(256)":U
     LABEL "Исполнитель"
     VIEW-AS FILL-IN
     SIZE 35 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY br-table FOR
      fbr-pln-line,
      goods SCROLLING.
DEFINE BROWSE br-table
  QUERY br-table NO-LOCK DISPLAY
      fbr-pln-line.artic FORMAT "X(16)":U
      fbr-pln-line.gds-code FORMAT "999999999":U
      goods.gds-name FORMAT "X(35)":U
      fbr-pln-line.recipe-code COLUMN-LABEL "Рецепт" FORMAT "X(8)":U
      fbr-pln-line.fact-qnty FORMAT "->>,>>>,>>9.<<<":U
      fbr-pln-line.fbr-obj-type COLUMN-LABEL "Тип" FORMAT "X(3)":U
      fbr-pln-line.fbr-obj-code COLUMN-LABEL "Код" FORMAT ">>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 15.67.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1.5
     bt-prev AT ROW 1 COL 11.5
     bt-next AT ROW 1 COL 15.5
     bt-fbr-docs AT ROW 1 COL 19.5
     b-help AT ROW 1.21 COL 88.63
     fi-object AT ROW 2.58 COL 12.88 COLON-ALIGNED
     bt-billord AT ROW 2.58 COL 69
     fi-date AT ROW 3.71 COL 12.88 COLON-ALIGNED
     fi-fact-date AT ROW 3.71 COL 33.75 COLON-ALIGNED
     fi-customer AT ROW 3.71 COL 67 COLON-ALIGNED
     fi-wrkr AT ROW 4.79 COL 12.88 COLON-ALIGNED
     fi-guest-amount AT ROW 4.79 COL 67 COLON-ALIGNED
     b-wrkr AT ROW 4.83 COL 50.5
     br-table AT ROW 6.38 COL 1.63
     b-add AT ROW 22.21 COL 2.38
     b-lkp AT ROW 22.21 COL 12.38
     b-chg AT ROW 22.21 COL 22.38
     b-del AT ROW 22.21 COL 32.38
     SPACE(56.59) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ план-меню".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
    run add-doc in this-procedure (
          input p-doc-code
        , output p-doc-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка добавления в план-меню или счет-заказ."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    OPEN QUERY br-table FOR EACH fbr-pln-line       WHERE fbr-pln-line.doc-code = p-doc-code NO-LOCK,       EACH goods WHERE goods.gds-code = fbr-pln-line.gds-code NO-LOCK     BY fbr-pln-line.line-num.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
    define variable v-focused-row       as integer      no-undo.
    define variable v-repositioned-row  as integer      no-undo.
    define variable v-cancel            as logical      no-undo.
    define variable v-cancel-cycle      as logical      no-undo.
    if available fbr-pln-line
    then do:
        assign
            v-focused-row      = br-table :focused-row in frame Dialog-Frame.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run change-doc in this-procedure (
              input fbr-pln-line.doc-code
            , input fbr-pln-line.gds-code
            , input fbr-pln-line.recipe-code
            , input fbr-pln-line.fbr-obj-type
            , input fbr-pln-line.fbr-obj-code
            , input fbr-pln-line.fact-qnty
            , output v-cancel
            , output v-cancel-cycle
        ).
        OPEN QUERY br-table FOR EACH fbr-pln-line       WHERE fbr-pln-line.doc-code = p-doc-code NO-LOCK,       EACH goods WHERE goods.gds-code = fbr-pln-line.gds-code NO-LOCK     BY fbr-pln-line.line-num.
        br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dialog-Frame.
        reposition br-table to row v-repositioned-row.
    end.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
    define variable v-deleted    as logical        no-undo.
    define variable v-focused-row       as integer  no-undo.
    define variable v-repositioned-row  as integer  no-undo.
    if available fbr-pln-line
    then do:
        assign
            v-focused-row      = br-table :focused-row in frame Dialog-Frame.
            v-repositioned-row = current-result-row( "br-table" )
        .
        run delete-doc in this-procedure (
              input fbr-pln-line.doc-code
            , input fbr-pln-line.gds-code
            , input fbr-pln-line.recipe-code
            , output v-deleted
        ).
        if v-deleted = yes
        then do:
            OPEN QUERY br-table FOR EACH fbr-pln-line       WHERE fbr-pln-line.doc-code = p-doc-code NO-LOCK,       EACH goods WHERE goods.gds-code = fbr-pln-line.gds-code NO-LOCK     BY fbr-pln-line.line-num.
            br-table :set-repositioned-row( v-focused-row, "ALWAYS" ) in frame Dialog-Frame.
            reposition br-table to row v-repositioned-row.
        end.
    end.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
    define variable v-have-error     as logical        no-undo.
    define variable v-error-text     as character      no-undo.
    assign
        fi-customer
        fi-guest-amount
    .
    run check-fbr-pln in this-procedure (
          output v-have-error
        , output v-error-text
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка проверки введенных данных."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-have-error
    then do:
        message
            "Ошибка введенных данных документа."
            skip(1)
            skip v-error-text
            skip(1)
            "Исправьте неверные данные."
        view-as alert-box error.
        undo, return no-apply .
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U
    or p-mode = 'ДОБАВЛЕНИЕ':U
    then do:
        run assign-data-for-exit in this-procedure (
              input fi-customer
            , input fi-guest-amount
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка записи введенных данных."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return no-apply .
        end.
    end.
    apply "GO" TO FRAME Dialog-Frame .
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
or mouse-select-dblclick of br-table in frame dialog-frame
DO:
    if available fbr-pln-line
    then do:
        run view-doc in this-procedure (
              input fbr-pln-line.doc-code
            , input fbr-pln-line.gds-code
            , input fbr-pln-line.recipe-code
            , input fbr-pln-line.fbr-obj-type
            , input fbr-pln-line.fbr-obj-code
            , input fbr-pln-line.fact-qnty
        ).
    end.
END.
ON CHOOSE OF b-wrkr IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    run select-fbroperator in this-procedure (
        output fi-wrkr
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка выбора оператора документа план-меню."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    display
        fi-wrkr
    with frame Dialog-Frame.
END.
ON CHOOSE OF bt-billord IN FRAME Dialog-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    if fi-customer :sensitive = yes
    and fi-customer :screen-value = ""
    and fi-guest-amount :screen-value = "0"
    then do:
        assign
            fi-customer     :sensitive     = no
            fi-guest-amount :sensitive = no
        .
    end.
    else do:
        assign
            fi-customer     :sensitive     = yes
            fi-guest-amount :sensitive = yes
        .
        apply "entry" to fi-customer.
    end.
END.
ON CHOOSE OF bt-fbr-docs IN FRAME Dialog-Frame
DO:
    run str/fbrplndf.w (
          input parparentproc
        , input p-doc-code
        , input p-obj-type
        , input p-obj-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка списка документов производства."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF bt-next IN FRAME Dialog-Frame
DO:
    run go-to-doc in this-procedure (
        input 'next':U
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка перехода к следующей записи."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
ON CHOOSE OF bt-prev IN FRAME Dialog-Frame
DO:
    run go-to-doc in this-procedure (
        input 'prev':U
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка перехода к предыдущей записи."
            skip return-value
            skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-table :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-table in frame Dialog-Frame.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run init-fields in this-procedure.
    RUN enable_UI.
    run ui-disable-all in this-procedure.
    run ui-enable in this-procedure.
    apply "entry" to br-table.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-doc :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define output parameter p-out-doc-code  as character    no-undo.
    define variable v-artic             as character      no-undo.
    define variable v-goods-recid-list  as character      no-undo.
    define variable v-counter           as integer        no-undo.
    define variable v-goods-recid       as recid          no-undo.
    define variable v-recipe-recid-list as character      no-undo.
    define variable v-recipe-code       as character      no-undo.
    define variable v-qnty              as decimal        no-undo.
    define variable v-host-code         as integer        no-undo.
    define variable v-yesno             as logical        no-undo.
    define variable v-add-goods         as logical        no-undo.
    define variable v-cancel            as logical        no-undo.
    define variable v-cancel-cycle      as logical        no-undo.
    define variable v-upper-code        as integer      no-undo.
    define buffer buf_goods         for goods.
    define buffer buf_recipe        for recipe.
    define buffer buf_fbr-gds-obj   for fbr-gds-obj.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    if p-doc-code = ""
    then do:
        run fbrpln-create-doc in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input 'план-меню':U
            , input ( v-cntxt-db-num <> 0 )
            , input v-cntxt-userid
            , output p-doc-code
        ).
        find first buf_init_fbr-pln no-lock
             where buf_init_fbr-pln.doc-code = p-doc-code
        .
        assign
            frame Dialog-Frame :title = substitute( "Документ план-меню N &1 от &2", buf_init_fbr-pln.doc-code, buf_init_fbr-pln.doc-date )
        .
        run fbrhist-write in p-list-procedure (
              input v-cntxt-userid
            , input buf_init_fbr-pln.obj-type
            , input buf_init_fbr-pln.obj-code
            , input 'соз_док':U
            , input 1
            , input "add-doc"
            , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
            , input p-doc-code
            , input 'план-меню':U
            , input 'новый':U
            , input no
            , input ""
            , input ""
            , input 0
            , input ""
            , input 0
            , input ""
            , input no
        ).
    end.
    assign
        p-out-doc-code = p-doc-code
    .
    run str/chs-gds.w (
          input parparentproc
        , input p-obj-type
        , input p-obj-code
        , input '':U
        , input '':U
        , input "План-меню: " + string( p-doc-code )
        , input 'объект':U
        , input ?
        , input ?
        , input ?
        , input ?
        , input-output v-artic
        , output v-goods-recid-list
    ) .
    run fbrhist-write in p-list-procedure (
          input v-cntxt-userid
        , input buf_init_fbr-pln.obj-type
        , input buf_init_fbr-pln.obj-code
        , input 'доб_тов':U
        , input 3
        , input "add-doc"
        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
        , input p-doc-code
        , input 'план-меню':U
        , input 'новый':U
        , input no
        , input ""
        , input ""
        , input 0
        , input ""
        , input 0
        , input substitute( "Выбрано &1 товаров для добавления в план-меню.", num-entries( v-goods-recid-list ) )
        , input no
    ).
    if v-goods-recid-list <> ''
    then do:
        assign
            v-counter   = 1
        .
        cycle-by-goods:
        do
        while v-counter <= num-entries ( v-goods-recid-list )
        :
            assign
                v-goods-recid   = integer( entry ( v-counter, v-goods-recid-list ) )
                v-counter       = v-counter + 1
            .
            find first buf_goods no-lock
                 where recid( buf_goods ) = v-goods-recid
            .
            find first buf_fbr-pln-line no-lock
                 where buf_fbr-pln-line.doc-code    = p-doc-code
                   and buf_fbr-pln-line.artic       = buf_goods.artic
                   and buf_fbr-pln-line.prod-type   = buf_goods.prod-type
                   and buf_fbr-pln-line.prod-code   = buf_goods.prod-code
            no-error.
            if available buf_fbr-pln-line
            then do:
                message
                    skip "Товар уже включен в план-меню."
                    skip "Товар: " buf_goods.artic buf_goods.gds-name
                view-as alert-box error.
                next cycle-by-goods.
            end.
            transaction-block:
            do transaction
            on error undo, return error
            :
                find first buf_recipe no-lock
                     where buf_recipe.obj-type  = p-obj-type
                       and buf_recipe.obj-code  = p-obj-code
                       and buf_recipe.artic     = buf_goods.artic
                       and buf_recipe.prod-type = buf_goods.prod-type
                       and buf_recipe.prod-code = buf_goods.prod-code
                no-error.
                if not available buf_recipe
                then do:
                    find first buf_recipe no-lock
                         where buf_recipe.obj-type  = ""
                           and buf_recipe.obj-code  = 0
                           and buf_recipe.artic     = buf_goods.artic
                           and buf_recipe.prod-type = buf_goods.prod-type
                           and buf_recipe.prod-code = buf_goods.prod-code
                    no-error.
                end.
                if available buf_recipe
                then do:
                    find first buf_fbr-gds-obj no-lock
                         where buf_fbr-gds-obj.obj-type = p-obj-type
                           and buf_fbr-gds-obj.obj-code = p-obj-code
                           and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
                    no-error.
                    if not available buf_fbr-gds-obj
                    or ( buf_fbr-gds-obj.fbr-obj-type = ""
                       and buf_fbr-gds-obj.fbr-obj-code = 0 )
                    then do:
                        message
                            skip "Не задан объект для производства товара с рецептом."
                            skip "Товар: " buf_goods.artic buf_goods.gds-name
                            skip(1)
                            skip "Товар не может быть включен в план-меню."
                            skip(1)
                            skip "Необходимо определить атрибуты товара для ресторана."
                        view-as alert-box error.
                        run fbrhist-write in p-list-procedure (
                              input v-cntxt-userid
                            , input buf_init_fbr-pln.obj-type
                            , input buf_init_fbr-pln.obj-code
                            , input 'чт_справ':U
                            , input 2
                            , input "add-doc"
                            , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                            , input p-doc-code
                            , input 'план-меню':U
                            , input 'новый':U
                            , input no
                            , input ""
                            , input ""
                            , input buf_goods.gds-code
                            , input ""
                            , input 0
                            , input "Не задан объект для производства товара с рецептом (атрибут товара на ресторане)."
                            , input yes
                        ).
                        undo transaction-block, next cycle-by-goods.
                    end.
                    assign
                        v-add-goods = no
                    .
                    do while v-add-goods = no
                    :
                        run ref/rcp-all.w (
                              input parparentproc
                            , input "b-add,b-sel"
                            , input 'все':U
                            , input recid( buf_goods )
                            , input p-obj-type
                            , input p-obj-code
                            , output v-recipe-recid-list
                        ) no-error.
                        if error-status :error
                        or v-recipe-recid-list = ""
                        then do:
                            message
                                "Отменить добавление товара?"
                                skip(1)
                                skip "Товар:" buf_goods.artic buf_goods.gds-name
                                skip(1)
                                skip "Yes - отменить добавление текущего товара"
                                skip "No  - отменить добавление всех товаров списка"
                                skip "Cancel - вернуться к выбору рецепта"
                            view-as alert-box question
                            buttons yes-no-cancel
                            title "Отмена"
                            update v-yesno
                            .
                            case v-yesno
                            :
                                when yes
                                then do:
                                    run fbrhist-write in p-list-procedure (
                                          input v-cntxt-userid
                                        , input buf_init_fbr-pln.obj-type
                                        , input buf_init_fbr-pln.obj-code
                                        , input 'выбор':U
                                        , input 2
                                        , input "add-doc"
                                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                                        , input p-doc-code
                                        , input 'план-меню':U
                                        , input 'новый':U
                                        , input no
                                        , input ""
                                        , input ""
                                        , input buf_goods.gds-code
                                        , input ""
                                        , input 0
                                        , input "Отменено добавление товара списка."
                                        , input no
                                    ).
                                    undo transaction-block, next cycle-by-goods.
                                end.
                                when no
                                then do:
                                    run fbrhist-write in p-list-procedure (
                                          input v-cntxt-userid
                                        , input buf_init_fbr-pln.obj-type
                                        , input buf_init_fbr-pln.obj-code
                                        , input 'выбор':U
                                        , input 2
                                        , input "add-doc"
                                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                                        , input p-doc-code
                                        , input 'план-меню':U
                                        , input 'новый':U
                                        , input no
                                        , input ""
                                        , input ""
                                        , input buf_goods.gds-code
                                        , input ""
                                        , input 0
                                        , input "Отменено добавление всех товаров, выбранных в списке."
                                        , input no
                                    ).
                                    undo transaction-block, leave cycle-by-goods.
                                end.
                            end case.
                        end.
                        else do:
                            assign
                                v-add-goods = yes
                            .
                        end.
                    end.
                    find first buf_recipe no-lock
                         where recid( buf_recipe ) = integer( entry( 1, v-recipe-recid-list ) )
                    .
                    run fbrpln-create-line in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input buf_recipe.recipe-code
                        , input buf_fbr-gds-obj.fbr-obj-type
                        , input buf_fbr-gds-obj.fbr-obj-code
                        , input no
                        , input v-qnty
                    ).
                    run fbrhist-write in p-list-procedure (
                          input v-cntxt-userid
                        , input buf_init_fbr-pln.obj-type
                        , input buf_init_fbr-pln.obj-code
                        , input 'соз_стр':U
                        , input 2
                        , input "add-doc"
                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                        , input p-doc-code
                        , input 'план-меню':U
                        , input 'новый':U
                        , input no
                        , input buf_recipe.recipe-code
                        , input buf_recipe.recipe-type
                        , input buf_goods.gds-code
                        , input ""
                        , input v-qnty
                        , input ""
                        , input no
                    ).
                    run change-doc in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input buf_recipe.recipe-code
                        , input ""
                        , input 0
                        , input 0
                        , output v-cancel
                        , output v-cancel-cycle
                    ).
                    if v-cancel-cycle = yes
                    then do:
                        undo transaction-block, leave cycle-by-goods.
                    end.
                    if v-cancel = yes
                    then do:
                        undo transaction-block, next cycle-by-goods.
                    end.
                end.
                else do:
                    run fbrpln-create-line in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input ""
                        , input ""
                        , input 0
                        , input no
                        , input v-qnty
                    ).
                    run fbrhist-write in p-list-procedure (
                          input v-cntxt-userid
                        , input buf_init_fbr-pln.obj-type
                        , input buf_init_fbr-pln.obj-code
                        , input 'соз_стр':U
                        , input 2
                        , input "add-doc"
                        , input "doc-code:" + p-doc-code + ",out-doc-code:" + p-out-doc-code
                        , input p-doc-code
                        , input 'план-меню':U
                        , input 'новый':U
                        , input no
                        , input ""
                        , input ""
                        , input buf_goods.gds-code
                        , input ""
                        , input v-qnty
                        , input ""
                        , input no
                    ).
                    run change-doc in this-procedure (
                          input p-doc-code
                        , input buf_goods.gds-code
                        , input ""
                        , input ""
                        , input 0
                        , input 0
                        , output v-cancel
                        , output v-cancel-cycle
                    ).
                    if v-cancel-cycle = yes
                    then do:
                        undo transaction-block, leave cycle-by-goods.
                    end.
                    if v-cancel = yes
                    then do:
                        undo transaction-block, next cycle-by-goods.
                    end.
                end.
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE assign-data-for-exit :
define input parameter p-customer       as character    no-undo.
define input parameter p-guest-amount   as integer      no-undo.
    define buffer buf_fbr-pln       for fbr-pln.
do
for buf_fbr-pln
on error undo, return error
:
    find first buf_fbr-pln exclusive-lock
         where buf_fbr-pln.doc-code = p-doc-code
    no-error.
    if available buf_fbr-pln
    then do:
        assign
            buf_fbr-pln.customer     = p-customer
            buf_fbr-pln.guest-amount = p-guest-amount
        .
        run fbrattr-write in this-procedure (
              input 'fbr-pln':U
            , input p-doc-code
            , input 'fbroperator':U
            , input string( v-fbr-pln-fbroperator-code )
        ) no-error.
        run str/fbrattrw.p (
              input p-doc-code
            , input 'fbroperator':U
            , input string( v-fbr-pln-fbroperator-code )
        ) no-error.
        if error-status :error
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip(1)
                skip "Не удалось записать оператора производства."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box warning.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE change-doc :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-fact-qnty      as decimal      no-undo.
define output parameter p-cancel        as logical      no-undo.
define output parameter p-cancel-cycle  as logical      no-undo.
    define variable v-new-obj-type      as character    no-undo.
    define variable v-new-obj-code      as integer      no-undo.
    define variable v-new-recipe-code   as character    no-undo.
    define variable v-new-fact-qnty     as decimal      no-undo.
    define variable v-log-string        as character    no-undo.
    define variable v-upper-code        as integer      no-undo.
    define buffer buf_fbr-pln-line      for fbr-pln-line.
    run str/fbrplnd.w (
          input parparentproc
        , input 'ИЗМЕНЕНИЕ':U
        , input p-doc-code
        , input p-gds-code
        , input p-recipe-code
        , input p-obj-type
        , input p-obj-code
        , input p-fact-qnty
        , output v-new-recipe-code
        , output v-new-obj-type
        , output v-new-obj-code
        , output v-new-fact-qnty
        , output p-cancel
        , output p-cancel-cycle
    ).
    if p-cancel = no
    and ( v-new-recipe-code <> p-recipe-code
         or v-new-obj-type  <> p-obj-type
         or v-new-obj-code  <> p-obj-code
         or v-new-fact-qnty <> p-fact-qnty
        )
    then do:
        assign
            v-log-string = substitute( "Изменения в строке: &1 &2 &3"
                , ( if v-new-recipe-code <> p-recipe-code then substitute( "Рецепт:&1|&2", p-recipe-code, v-new-recipe-code ) else "" )
                , ( if v-new-obj-type <> p-obj-type or v-new-obj-code <> p-obj-code then substitute( "Объект:&1&2|&3&4", p-obj-type, p-obj-code, v-new-obj-type, v-new-obj-code ) else "" )
                , ( if v-new-fact-qnty <> p-fact-qnty then substitute( "Количество:&1|&2", p-fact-qnty, v-new-fact-qnty ) else "" ) )
        .
        do transaction
        on error undo, return error
        :
            find first buf_fbr-pln-line exclusive-lock
                 where buf_fbr-pln-line.doc-code    = p-doc-code
                   and buf_fbr-pln-line.gds-code    = p-gds-code
                   and buf_fbr-pln-line.recipe-code = p-recipe-code
            .
            assign
                buf_fbr-pln-line.recipe-code    = v-new-recipe-code
                buf_fbr-pln-line.fbr-obj-type   = v-new-obj-type
                buf_fbr-pln-line.fbr-obj-code   = v-new-obj-code
                buf_fbr-pln-line.fact-qnty      = v-new-fact-qnty
            .
        end.
        run fbrhist-write in p-list-procedure (
              input v-cntxt-userid
            , input buf_fbr-pln-line.obj-type
            , input buf_fbr-pln-line.obj-code
            , input 'изм_стр':U
            , input 2
            , input "change-doc"
            , input substitute( "doc-code:&1,gds-code:&2,recipe-code:&3,obj-type:&4,obj-code:&5,fact-qnty:&6"
                                , p-doc-code
                                , p-gds-code
                                , p-recipe-code
                                , p-obj-type
                                , p-obj-code
                                , p-fact-qnty )
            , input p-doc-code
            , input 'план-меню':U
            , input ""
            , input no
            , input v-new-recipe-code
            , input ""
            , input buf_fbr-pln-line.gds-code
            , input ""
            , input v-new-fact-qnty
            , input v-log-string
            , input no
        ).
    end.
end.
END PROCEDURE.
PROCEDURE check-fbr-pln :
define output parameter p-bad-data      as logical      no-undo.
define output parameter p-error-text    as character    no-undo.
    define variable v-hst-upper-code    as integer      no-undo.
    define buffer buf_fbr-pln       for fbr-pln.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
do
for buf_fbr-pln
  , buf_fbr-pln-line
on error undo, return error
:
    find first buf_fbr-pln-line no-lock
         where buf_fbr-pln-line.doc-code = p-doc-code
    no-error.
    if not available buf_fbr-pln-line
    then do:
        assign
            p-bad-data   = no
        .
        do transaction
        on error undo, return error
        :
            find first buf_fbr-pln exclusive-lock
                 where buf_fbr-pln.doc-code = p-doc-code
            no-error.
            if available buf_fbr-pln
            then do:
                message
                    "В документе нет ни одной строки."
                    skip(1)
                    skip "Поэтому документ удаляется."
                view-as alert-box information.
                delete buf_fbr-pln.
                run fbrhist-write in p-list-procedure (
                      input v-cntxt-userid
                    , input p-obj-type
                    , input p-obj-code
                    , input 'удл_док':U
                    , input 1
                    , input "check-fbr-pln"
                    , input ""
                    , input p-doc-code
                    , input 'план-меню':U
                    , input ""
                    , input no
                    , input ""
                    , input ""
                    , input 0
                    , input ""
                    , input 0
                    , input "Удаление пустого документа"
                    , input no
                ).
            end.
        end.
    end.
end.
END PROCEDURE.
PROCEDURE delete-doc :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define output parameter p-deleted       as logical      no-undo.
    define variable v-yesno         as logical      no-undo.
    define variable v-upper-code    as integer      no-undo.
    define buffer buf_fbr-pln-line  for fbr-pln-line.
    define buffer buf_goods         for goods.
    find first buf_fbr-pln-line exclusive-lock
         where buf_fbr-pln-line.doc-code    = p-doc-code
           and buf_fbr-pln-line.gds-code    = p-gds-code
           and buf_fbr-pln-line.recipe-code = p-recipe-code
    .
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    message
             "Товар строки: " chr(9) buf_goods.artic buf_goods.gds-name
        skip "Рецепт: " chr(9) chr(9) buf_fbr-pln-line.recipe-code
        skip(1)
        skip "Удалить строку документа?"
    view-as alert-box question
    buttons yes-no
    title "Удаление строки документа"
    update v-yesno
    .
    if v-yesno = yes
    then do:
        delete buf_fbr-pln-line.
        assign
            p-deleted = yes
        .
        run fbrhist-write in p-list-procedure (
              input v-cntxt-userid
            , input p-obj-type
            , input p-obj-code
            , input 'удл_стр':U
            , input 2
            , input "delete-doc"
            , input substitute( "doc-code:&1,gds-code:&2,recipe-code:&3"
                                , p-doc-code
                                , p-gds-code
                                , p-recipe-code   )
            , input p-doc-code
            , input 'план-меню':U
            , input ""
            , input no
            , input p-recipe-code
            , input ""
            , input p-gds-code
            , input ""
            , input 0
            , input ""
            , input no
        ).
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-object fi-date fi-fact-date fi-customer fi-wrkr fi-guest-amount
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-fbr-docs b-help bt-billord b-wrkr br-table b-add b-lkp b-chg
         b-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-table FOR EACH fbr-pln-line       WHERE fbr-pln-line.doc-code = p-doc-code NO-LOCK,       EACH goods WHERE goods.gds-code = fbr-pln-line.gds-code NO-LOCK     BY fbr-pln-line.line-num.
END PROCEDURE.
PROCEDURE go-to-doc :
define input parameter p-direction as character  no-undo.
do
on error undo, return error
:
    run local-open-query in p-list-procedure.
    run reposition-to-recid in p-list-procedure (
        input recid( buf_init_fbr-pln )
    ).
    run reposition-query in p-list-procedure (
          input p-direction
        , output p-doc-code
    ).
    if p-doc-code = 'first':U
    then do:
        message
            "Это первый документ списка"
        view-as alert-box information.
    end.
    if p-doc-code = 'last':U
    then do:
        message
            "Это последний документ списка"
        view-as alert-box information.
    end.
    if p-doc-code <> ""
    and p-doc-code <> 'first':U
    and p-doc-code <> 'last':U
    then do:
        run local-open-query in this-procedure.
        run init-fields in this-procedure.
        run ui-disable-all in this-procedure.
        run ui-enable in this-procedure.
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    case p-mode
    :
        when 'ДОБАВЛЕНИЕ':U
        then do:
            define variable v-obj-date    as date        no-undo.
            define variable v-userid      as character      no-undo.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output fi-date
  )  .
            assign
                fi-object       = substitute( "&1 &2", p-obj-type, p-obj-code )
                p-doc-code      = ""
            .
        end.
        when 'ИЗМЕНЕНИЕ':U
        or when 'ПРОСМОТР':U
        then do:
            define variable v-fbroperator-string    as character    no-undo.
            if p-mode = 'ИЗМЕНЕНИЕ':U
            then do:
                run lock-fbr-pln in this-procedure (
                      input p-doc-code
                    , buffer buf_init_fbr-pln
                ).
            end.
            else do:
                find first buf_init_fbr-pln no-lock
                     where buf_init_fbr-pln.doc-code = p-doc-code
                .
            end.
            assign
                fi-object       = substitute( "&1 &2", buf_init_fbr-pln.obj-type, buf_init_fbr-pln.obj-code )
                fi-date         = buf_init_fbr-pln.doc-date
                fi-fact-date    = buf_init_fbr-pln.fact-date
                fi-customer     = buf_init_fbr-pln.customer
                fi-guest-amount = buf_init_fbr-pln.guest-amount
            .
            run fbrattr-value in this-procedure (
                  input 'fbr-pln':U
                , input buf_init_fbr-pln.doc-code
                , input 'fbroperator':U
                , output v-fbroperator-string
            ) no-error.
            if error-status :error
            then do:
                message
                        vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка определения оператора план-меню."
                    skip(1)
                    skip "Выберите ответственного за операции план-меню."
                    skip return-value
                    skip trim(error-status :get-message(1))
                        trim(error-status :get-message(2))
                        trim(error-status :get-message(3))
                view-as alert-box warning.
                assign
                    v-fbr-pln-fbroperator-code = 0
                .
            end.
            assign
                v-fbr-pln-fbroperator-code = integer( v-fbroperator-string )
            no-error.
            if error-status :error
            then do:
                assign
                    v-fbr-pln-fbroperator-code = 0
                .
            end.
            else do:
                define buffer buf_clients       for clients.
                find first buf_clients no-lock
                     where buf_clients.obj-type = 'чел':U
                       and buf_clients.obj-code = v-fbr-pln-fbroperator-code
                no-error.
                if not available buf_clients
                then do:
                    assign
                        v-fbr-pln-fbroperator-code = 0
                    .
                end.
                else do:
                    assign
                        fi-wrkr = buf_clients.obj-name
                    .
                end.
            end.
        end.
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip "Неизвестный режим для документа."
                skip "Код документа:" p-doc-code
                skip "Режим просмотра/редактирования:" p-mode
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end case.
    if available buf_init_fbr-pln
    then do:
        assign
            frame Dialog-Frame :title = substitute( "Документ план-меню N &1 от &2", buf_init_fbr-pln.doc-code, buf_init_fbr-pln.doc-date )
        .
    end.
end.
END PROCEDURE.
PROCEDURE local-open-query :
do
on error undo, return error
:
    OPEN QUERY br-table FOR EACH fbr-pln-line       WHERE fbr-pln-line.doc-code = p-doc-code NO-LOCK,       EACH goods WHERE goods.gds-code = fbr-pln-line.gds-code NO-LOCK     BY fbr-pln-line.line-num.
end.
END PROCEDURE.
PROCEDURE lock-fbr-pln :
define input parameter p-doc-code   as character    no-undo.
define parameter buffer buf_fbr-pln        for fbr-pln.
do transaction
on error undo, return error
:
    find first buf_fbr-pln exclusive-lock
         where buf_fbr-pln.doc-code = p-doc-code
    no-wait
    no-error.
    if not available buf_fbr-pln
    then do:
        if locked buf_fbr-pln
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip "Запись документа захвачена другим процессом."
                skip
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
        end.
        else do:
            message
                vss-workfile vss-revision vss-description
                skip "Внутренняя ошибка при блокировании ресурса"
                skip "Отсутствует запись о блокировке ресурса"
            view-as alert-box error.
        end.
        undo, return error .
    end.
end.
END PROCEDURE.
PROCEDURE select-fbroperator :
define output parameter p-obj-fbroperator   as character        no-undo.
    define variable v-fbroperator       as integer      no-undo.
    define variable v-clients-recid-int as integer      no-undo.
    define variable v-clients-recid     as recid        no-undo.
    define variable v-recid-list        as character    no-undo.
    define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
    if v-fbr-pln-fbroperator-code <> 0
    then do:
        find first buf_clients no-lock
             where buf_clients.obj-type = 'чел':U
               and buf_clients.obj-code = v-fbr-pln-fbroperator-code
        no-error.
        if available buf_clients
        then do:
            assign
                v-clients-recid = recid( buf_clients )
            .
        end.
    end.
    run ref/cli-all.w (
          input parparentproc
        , input "b-sel":U
        , input 'чел':U
        , input 'все':U
        , input 'текущие':U
        , input v-clients-recid
        , input ",,,,,,NO,,":U
        , input "":U
        , output v-recid-list
    ).
    assign
        v-clients-recid-int = integer( v-recid-list )
    no-error.
    if error-status :error
    then do:
        assign
            v-fbr-pln-fbroperator-code = 0
            p-obj-fbroperator          = "":U
        .
    end.
    else do:
        find first buf_clients no-lock
             where recid( buf_clients ) = v-clients-recid-int
        no-error.
        if not available buf_clients
        then do:
            assign
                v-fbr-pln-fbroperator-code = 0
                p-obj-fbroperator          = "":U
            .
        end.
        else do:
            assign
                v-fbr-pln-fbroperator-code = buf_clients.obj-code
                p-obj-fbroperator          = buf_clients.obj-name
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE ui-disable-all :
END PROCEDURE.
PROCEDURE ui-enable :
    define variable v-current-db-num    as integer        no-undo.
    define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
    find first buf_clients no-lock
         where buf_clients.obj-type = p-obj-type
           and buf_clients.obj-code = p-obj-code
    .
    case p-mode
    :
        when 'ДОБАВЛЕНИЕ':U
        then do:
            if v-current-db-num = buf_clients.db-num
            then do:
                enable
                    b-add
                    b-lkp
                    b-chg
                    b-del
                    b-wrkr
                    bt-billord
                with frame Dialog-Frame.
            end.
        end.
        when 'ИЗМЕНЕНИЕ':U
        then do:
            if v-current-db-num = buf_clients.db-num
            then do:
                enable
                    b-add
                    b-lkp
                    b-chg
                    b-del
                    b-wrkr
                    bt-billord
                with frame Dialog-Frame.
                if fi-customer <> ""
                or fi-guest-amount <> 0
                then do:
                    assign
                        fi-customer     :sensitive = yes
                        fi-guest-amount :sensitive = yes
                    .
                end.
            end.
        end.
        when 'ПРОСМОТР':U
        then do:
            find first buf_init_fbr-pln no-lock
                 where buf_init_fbr-pln.doc-code = p-doc-code
            no-error.
            if available buf_init_fbr-pln
            then do:
                disable
                    b-add
                    b-chg
                    b-del
                    b-wrkr
                    bt-billord
                with frame Dialog-Frame.
                enable
                    bt-prev
                    bt-next
                with frame Dialog-Frame.
                assign
                    fi-object       = substitute( "&1 &2", buf_init_fbr-pln.obj-type, buf_init_fbr-pln.obj-code )
                    fi-date         = buf_init_fbr-pln.doc-date
                    fi-fact-date    = buf_init_fbr-pln.fact-date
                    fi-customer     = buf_init_fbr-pln.customer
                    fi-guest-amount = buf_init_fbr-pln.guest-amount
                .
                display
                    fi-object
                    fi-date
                    fi-fact-date
                    fi-customer
                    fi-guest-amount
                with frame Dialog-Frame.
            end.
            else do:
                message
                         vss-workfile vss-revision vss-description
                    skip "Не удалось найти запись документа."
                    skip(1)
                    skip "Номер документа:" p-doc-code
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        otherwise do:
            message
                     vss-workfile vss-revision vss-description
                skip "Неизвестный режим для документа."
                skip "Код документа:" p-doc-code
                skip "Режим просмотра/редактирования:" p-mode
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE view-doc :
do
on error undo, return error
:
define input parameter p-doc-code       as character    no-undo.
define input parameter p-gds-code       as integer      no-undo.
define input parameter p-recipe-code    as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-fact-qnty      as decimal      no-undo.
    define variable v-new-recipe-code   as character      no-undo.
    define variable v-new-obj-type      as character      no-undo.
    define variable v-new-obj-code      as integer        no-undo.
    define variable v-new-fact-qnty     as decimal        no-undo.
    define variable v-cancel            as logical        no-undo.
    define variable v-cancel-cycle      as logical        no-undo.
    run str/fbrplnd.w (
          input parparentproc
        , input 'ПРОСМОТР':U
        , input p-doc-code
        , input p-gds-code
        , input p-recipe-code
        , input p-obj-type
        , input p-obj-code
        , input p-fact-qnty
        , output v-new-recipe-code
        , output v-new-obj-type
        , output v-new-obj-code
        , output v-new-fact-qnty
        , output v-cancel
        , output v-cancel-cycle
    ).
end.
END PROCEDURE.
