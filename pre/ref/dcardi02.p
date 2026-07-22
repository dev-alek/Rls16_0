block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-recid as recid no-undo.
define input parameter p-silent                       as logical no-undo .
define input parameter p-has-right-to-restore         as logical no-undo .
define input parameter p-mode2    as character no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input-output parameter par-status_ as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcardi02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcardi02.p $":U .
define variable vss-description as character no-undo init "Изменение статуса дисконтной карты".
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
procedure discardh_write-dis-card-proc  :
define parameter buffer buf_dis-card for ub.dis-card .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card for ub.c-dis-card.
  do
  on error undo, return error
  :
    if not available buf_dis-card then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена ДК" skip
        view-as alert-box error .
      undo, return error .
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-card.
    buffer-copy buf_dis-card to buf_c-dis-card
    assign
    buf_c-dis-card.d-card             = buf_dis-card.d-card
    buf_c-dis-card.card-num           = buf_dis-card.card-num
    buf_c-dis-card.chip-num           = next-value (s-dc-chip, ub)
    buf_c-dis-card.corr-time          = v-time
    buf_c-dis-card.corr-user-db-num   = g#db-num
    buf_c-dis-card.corr-user-name     = (if g#news
                                         then (chr(4) +  'СПН':U)
                                         else (if g#esys
                                               then (chr(4) +  'ВС':U)
                                               else g#userid
                                              )
                                         )
    buf_c-dis-card.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-card to buf_c-dc-hist
    assign
    buf_c-dc-hist.action =  integer('2':U)
    buf_c-dc-hist.subject = 'dis-card':U
    buf_c-dc-hist.host-code =  buf_dis-card.emitent-host-code
    buf_c-dc-hist.is-news = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref = p-source-ref
    .
    if not ( g#db-num > 0 )
    or (g#news
        and ( g#db-num > 0 )
        and buf_c-dis-card.corr-user-name = (chr(4) +  'СПН':U)
        )
    then do:
      run str/callnews.p
        (input 'c-dis-card':U
        ,input (buffer buf_c-dis-card:handle)
        ).
      run str/callnews.p
        (input 'c-dc-hist':U
        ,input (buffer buf_c-dc-hist:handle)
        ).
    end.
  end.
end procedure.
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
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-dis-card for ub.dis-card.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-status_ like ub.dis-card.status_ no-undo .
define variable v-mess as character no-undo .
define variable v-dop-d-card as character no-undo .
define variable ii as integer no-undo .
define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.
define buffer buf_dis-card for ub.dis-card.
_main:
do
on error undo, return error return-value
:
FIND FIRST bf-dis-card exclusive-lock WHERE
           recid(bf-dis-card) = par-recid No-ERROR.
if not avail bf-dis-card then return error.
if bf-dis-card.status_ = 'неисп':U
or bf-dis-card.status_ = 'смкли':U then do:
  v-mess = substitute("Нельзя изменять карту в статусе &1", bf-dis-card.status_).
  run err-mess in this-procedure ( input-output v-mess).
end.
varold-status_ = bf-dis-card.status_.
IF 'удал':U =  bf-dis-card.status_ then do:
    if par-status_ = 'удал':U then do:
       return.
    end.
    if not p-has-right-to-restore then do:
      v-mess = substitute("У Вас нет прав на изменение статуса удаленной карты!").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
    find first buf_dis-card no-lock where
              buf_dis-card.sourced-card = bf-dis-card.d-card no-error.
    if available buf_Dis-card then do:
      v-mess = substitute("К данной карте имеется перевыпущенная карта - восстановление запрещено").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
end.
CASE par-status_:
  WHEN 'тек':U then do:
    if 'тек':U = bf-dis-card.status_  then do:
      v-mess = substitute("Карта уже имеет статус ТЕКУЩИЙ!").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
    else do:
      assign
      v-dop-d-card = left-trim(bf-dis-card.d-card, "0") .
      DO II = 1  to (19 - length(v-dop-d-card)) + 1:
        if can-find(first ub.dis-card no-lock where
                        ub.dis-card.d-card = v-dop-d-card
                        and ub.dis-card.status_ <> 'удал':U
                        and ub.dis-card.d-card <> bf-dis-card.d-card
                        ) then do:
          assign
          v-mess = substitute("Уже есть глобальная НЕУДАЛЕННАЯ дисконтная карта&1 с номером &2 - совпадает с &3 с точностью до лидирующих нулей"
                      , (if bf-dis-card.emitent-host-code = 0
                        then "":U
                        else substitute(" на фирме &1", bf-dis-card.emitent-host-code))
                        ,v-dop-d-card
                        ,bf-dis-card.d-card
                        ).
          run err-mess in this-procedure ( input-output v-mess).
          par-status_ = "":U.
          undo _main, return error (if p-silent then v-mess else '':U).
        end.
        assign
        v-dop-d-card = "0" + v-dop-d-card
        .
      end.
      assign
       choice = yes.
    end.
  end.
  WHEN 'блок':U then do:
    if 'блок':U = bf-dis-card.status_   then do:
      v-mess = substitute("Карта уже блокирована!").
      run err-mess in this-procedure ( input-output v-mess).
      par-status_ = "".
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
    else do:
      if not p-silent then do:
        choice = FALSE .
        message "На блокированной карте не будут автоматически пересчитываться скидки." skip
                "Продолжить ?"
        view-as alert-box WARNING
        buttons OK-Cancel update choice .
      end.
      else do:
        choice = yes.
      end.
    end.
  end.
  WHEN 'удал':U then do:
   if not p-silent then do:
      choice = FALSE .
      message substitute("ВЫ уверены, что хотите удалить карту &1?&2"
                         , bf-dis-card.d-card
                         , chr(10)
                        )
      view-as alert-box WARNING
      buttons OK-Cancel update choice .
    end.
    else do:
      choice = yes.
    end.
  end.
END CASE.
if not choice then do:
  v-mess = substitute("Отмена пользователем при изменении статуса ДИСКОНТНОЙ КАРТЫ").
  run err-mess( input-output v-mess).
  undo _main, return error (if p-silent then v-mess else '':U).
end.
if choice then do:
  run ref/dcardi01.p (
                 input parparentproc
                ,input this-procedure
                ,input ?
                ,input ?
                ,input no
                ,input-output par-recid
                ,input 'ИЗМЕНЕНИЕ':U
                ,input p-mode2
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input bf-dis-card.d-card
                ,input bf-dis-card.emitent-host-code
                ,input bf-dis-card.cli-type
                ,input bf-dis-card.cli-code
                ,input par-status_ + chr(4) + string(if p-has-right-to-restore then yes else no)
                ,input bf-dis-card.type
                ,input bf-dis-card.d-pcnt
                ,input bf-dis-card.cash-d-pcnt
                ,input bf-dis-card.category
                ,input bf-dis-card.d-pcnt-method
                ,input bf-dis-card.credit-card
                ,input bf-dis-card.lim-kr
                ,input bf-dis-card.debet-card
                ,input bf-dis-card.staff-card
                ,input bf-dis-card.issue-date
                ,input bf-dis-card.issue-code
                ,input bf-dis-card.valid-from
                ,input bf-dis-card.valid-date
                ,input bf-dis-card.sourced-card
                ,input bf-dis-card.cli-message
                ,input bf-dis-card.mask-card
                ,input bf-dis-card.main-card
                ,input bf-dis-card.is-subsid
                ,INPUT no
                ,INPUT table tt0-dis-card-property
                 ) no-error .
end.
if error-status:error then do:
  v-mess = substitute("Ошибка при удалении ДИСКОНТНОЙ КАРТЫ&1&2&3&4"
                           ,error-status:get-message(1)
                           , chr(10)
                           ,return-value
                           ,chr(10)).
  run err-mess in this-procedure ( input-output v-mess).
  undo _main, return error (if p-silent then v-mess else '':U).
end.
par-status_ = "".
end.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("Карта №&1: эмитент: &2 тип: &3&4&5"
                           , bf-dis-card.d-card
                           , bf-dis-card.emitent-host-code
                           , bf-dis-card.type
                           , chr(10)
                           , p-mess
                           ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
