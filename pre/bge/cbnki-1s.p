block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-file-name as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik      no-undo .
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo .
define input parameter p-adresat   as character no-undo .
define input parameter p-do-create as logical no-undo .
define input parameter p-create-no-th as logical no-undo .
define input parameter p-encoding  as character no-undo .
define input parameter p-rs-hsch   as integer no-undo .
define input-output parameter p-view-log       as logical no-undo .
define output parameter p-count as integer no-undo .
define output parameter p-processed as integer no-undo .
define output parameter p-created as integer no-undo .
define output parameter p-count-statement as integer no-undo .
define output parameter p-processed-statement as integer no-undo .
define output parameter p-created-statement as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cbnki-1s.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cbnki-1s.p $":U .
define variable vss-description as character no-undo init "Разбор файла системы КЛИЕНТ-БАНК формата 1s".
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
define SHARED temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.
DEFINE SHARED TEMP-TABLE temp_hfin-schet NO-UNDO LIKE ub.fin-schet
.
DEFINE SHARED TEMP-TABLE temp_cfin-schet NO-UNDO LIKE ub.fin-schet
.
define temp-table temp-bik no-undo
field host-code like ub.sysconf.host-code
field code-bank like ub.fin-bank.code-bank
field bik       like ub.fin-bank.bik
field f_name    as character
field o_name    as character
field d-count    as integer
field adresat as character
index pi is unique primary
host-code
bik
.
procedure init-host-list :
define input parameter p-host-list as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_obj-list for temp_obj-list.
  do
  on error undo, return error
  :
  for each buf_temp_obj-list
  :
      delete buf_temp_obj-list.
  end.
  do v-counter = 1 to num-entries( p-host-list ) / 2
  :
      create buf_temp_obj-list.
      assign
          buf_temp_obj-list.obj-type = entry( 2 * v-counter - 1,  p-host-list )
          buf_temp_obj-list.obj-code = integer( entry( 2 * v-counter,      p-host-list ) )
      .
  end.
  end.
end procedure.
procedure fill-hfin-schet :
define input parameter p-hfin-schet as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_hfin-schet for temp_hfin-schet.
  do
  on error undo, return error return-value
  :
      for each buf_temp_hfin-schet
      :
          delete buf_temp_hfin-schet.
      end.
      do v-counter = 1 to num-entries( p-hfin-schet ) / 6
      :
          create buf_temp_hfin-schet.
          assign
          buf_temp_hfin-schet.host-code = integer( entry( 6 * v-counter - 5,      p-hfin-schet ) )
          buf_temp_hfin-schet.r-schet = entry( 6 * v-counter - 4,  p-hfin-schet )
          buf_temp_hfin-schet.cli-type =  entry( 6 * v-counter - 3,      p-hfin-schet )
          buf_temp_hfin-schet.cli-code = integer( entry( 6 * v-counter - 2,      p-hfin-schet ) )
          buf_temp_hfin-schet.code-bank = integer( entry( 6 * v-counter - 1,      p-hfin-schet ) )
          buf_temp_hfin-schet.code-schet = integer( entry( 6 * v-counter,      p-hfin-schet ) )
          .
      end.
  end.
end procedure.
procedure fill-cfin-schet :
define input parameter p-cfin-schet as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_cfin-schet for temp_cfin-schet.
  do
  on error undo, return error return-value
  :
      for each buf_temp_cfin-schet
      :
          delete buf_temp_cfin-schet.
      end.
      do v-counter = 1 to num-entries( p-cfin-schet ) / 6
      :
          create buf_temp_cfin-schet.
          assign
          buf_temp_cfin-schet.host-code = integer( entry( 6 * v-counter - 5,      p-cfin-schet ) )
          buf_temp_cfin-schet.r-schet = entry( 6 * v-counter - 4,  p-cfin-schet )
          buf_temp_cfin-schet.cli-type =  entry( 6 * v-counter - 3,      p-cfin-schet )
          buf_temp_cfin-schet.cli-code = integer( entry( 6 * v-counter - 2,      p-cfin-schet ) )
          buf_temp_cfin-schet.code-bank = integer( entry( 6 * v-counter - 1,      p-cfin-schet ) )
          buf_temp_cfin-schet.code-schet = integer( entry( 6 * v-counter,      p-cfin-schet ) )
          .
      end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp_hfields no-undo
field order_ as integer
field label_ as character
field name_ as character
field value_ as character init ?
field imported    as logical
field readed      as logical
field subject     as character
index pi is primary
name_
index ilab
label_
index ii
imported
index ir
readed
index isubject subject
.
procedure create-TEMP-hfields  :
define input parameter p-mode as character no-undo .
  do
  on error undo, return error
  :
define variable ii as integer no-undo .
define variable h-init-doc as character  extent 116 init
[
    'Дата='                           , 'doc-date'
   ,'Номер='                          , 'prn-doc-code'
   ,'Сумма='                          , 'sum-doc'
   ,'Плательщик='                     , 'payer-inn/payer-name'
   ,'Плательщик1='                    , 'payer-name'
   ,'Плательщик2='                    , 'payer-r-schet'
   ,'Плательщик3='                    , 'payer-bank-name'
   ,'Плательщик4='                    , 'payer-bank-city'
   ,'ПлательщикСчет='                 , 'payer-r-schet'
   ,'ПлательщикИНН='                  , 'payer-INN'
   ,'ПлательщикКПП='                  , 'payer-kpp'
   ,'ПлательщикРасчСчет='             , 'payer-r-schet'
   ,'ПлательщикБИК='                  , 'payer-bik'
   ,'ПлательщикКорСчет='              , 'payer-c-schet'
   ,'ПлательщикБанк1='                , 'payer-bank-name'
   ,'ПлательщикБанк2='                , 'payer-bank-city'
   ,'Получатель='                     , 'receiver-inn/receiver-name'
   ,'Получатель1='                    , 'receiver-name'
   ,'Получатель2='                    , 'receiver-r-schet'
   ,'Получатель3='                    , 'receiver-bank-name'
   ,'Получатель4='                    , 'receiver-bank-city'
   ,'ПолучательСчет='                 , 'receiver-r-schet'
   ,'ПолучательИНН='                  , 'receiver-INN'
   ,'ПолучательКПП='                  , 'receiver-kpp'
   ,'ПолучательРасчСчет='             , 'receiver-r-schet'
   ,'ПолучательБИК='                  , 'receiver-bik'
   ,'ПолучательКорСчет='              , 'receiver-c-schet'
   ,'ПолучательБанк1='                , 'receiver-bank-name'
   ,'ПолучательБанк2='                , 'receiver-bank-city'
   ,'СтатусСоставителя='              , 'stat-pl'
   ,'ПоказательКБК='                  , 'f104'
   ,'ПоказательОснования='            , 'f106'
   ,'ОКАТО='                          , 'f105'
   ,'ПоказательПериода='              , 'f107'
   ,'ПоказательНомера='               , 'f108'
   ,'ПоказательДаты='                 , 'f109'
   ,'ПоказательТипа='                 , 'f110'
   ,'НазначениеПлатежа='              , 'naznach-plat/'
   ,'ВидПлатежа='                     , 'vid-plat'
   ,'ВидОплаты='                      , 'vid-opl'
   ,'Очередность='                    , 'ocher-pl'
   ,'СрокПлатежа='                    , 'srok-pl'
   ,'СекцияДокумент='                 , 'fin-ext-doc-type/'
   ,'ДатаСписано='                    , 'fact-date'
   ,'ДатаПоступило='                  , 'fact-date'
   ,''                                , 'receiver-type'
   ,''                                , 'receiver-code'
   ,''                                , 'receiver-code-schet'
   ,''                                , 'payer-type'
   ,''                                , 'payer-code'
   ,''                                , 'payer-code-schet'
   ,''                                , 'fin-ext-doc-type'
   ,''                                , 'fin-doc-type'
   ,''                                , 'host-code'
   ,''                                , 'curr-code'
   ,'КвитанцияДата'                   , 'cvitdate'
   ,'КвитанцияВремя'                  , 'cvitname'
   ,'КвитанцияСодержание'             , 'cvitcont'
                                   ] no-undo.
define variable h-init-statement as character  extent 40 init
[
    'ДатаНачала='                     , 'start-date'
   ,'ДатаКонца='                      , 'end-date'
   ,'РасчСчет='                       , 'r-schet'
   ,'НачальныйОстаток='               , 'start-sum-doc'
   ,'КонечныйОстаток='                , 'end-sum-doc'
   ,'ВсегоПоступило='                 , 'in-sum-doc'
   ,'ВсегоСписано='                   , 'out-sum-doc'
   ,'СекцияРасчСчет='                 , 'fins-ext-doc-type/'
   ,''                                , 'fins-ext-doc-type'
   ,''                                , 'fins-doc-type'
   ,''                                , 'host-code'
   ,''                                , 'curr-code'
   ,''                                , 'code-schet'
   ,''                                , 'code-bank'
   ,''                                , 'cli-name'
   ,''                                , 'bank-name'
   ,''                                , 'bank-city'
   ,''                                , 'cl-bank'
   ,''                                , 'bik'
   ,'ДатаСоздания='                   , 'bank-date'
                                   ] no-undo.
    for each temp_hfields:
      delete temp_hfields.
    end.
    do ii = 1 to (if p-mode = 'exp' then 42 else 58):
      create temp_hfields.
      assign
      temp_hfields.order_ = ii
      temp_hfields.label_ = h-init-doc[ii * 2 - 1]
      temp_hfields.name_ = h-init-doc[ii * 2]
      temp_hfields.subject = 'fin-doc':U
      .
    end.
    do ii = 1 to (if p-mode = 'exp' then 0 else 20):
      create temp_hfields.
      assign
      temp_hfields.order_ = ii
      temp_hfields.label_ = h-init-statement[ii * 2 - 1]
      temp_hfields.name_ = h-init-statement[ii * 2]
      temp_hfields.subject = 'fin-statement':U
      .
    end.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure write-fin-doc-attr-proc :
define parameter buffer buf_fin-doc-attr for ub.fin-doc-attr.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
  do
  on error undo, return error
  :
    if not available buf_fin-doc-attr then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определен атрибут платежа" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-fin-doc-attr.
    buffer-copy buf_fin-doc-attr to buf_c-fin-doc-attr
    assign
    buf_c-fin-doc-attr.chip-num           = next-value (s-corr-chip, ub)
    buf_c-fin-doc-attr.corr-time          = v-time
    buf_c-fin-doc-attr.corr-user-db-num   = g#db-num
    buf_c-fin-doc-attr.corr-user-name     = g#userid
    buf_c-fin-doc-attr.corr-date          = v-date
    .
    release buf_c-fin-doc-attr.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-b-code :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter p-b-code  like ub.bar-code.b-code       no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
  :
    define buffer buf_thbj-attr     for ub.thbj-attr .
    define buffer buf_sys-ctrl   for ub.sys-ctrl .
    define buffer buf_code-range for ub.code-range .
    define variable l-code         as   integer              no-undo .
    define variable v-db-num       like ub.db.db-num         no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then do:
      message
        "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    run get-next-seq( input  type-code,
                      output l-code
                    ).
    find first buf_sys-ctrl no-lock.
    if type-code = 'sclc':U
    or type-code = 'pglc':U
    then do:
      assign
        v-db-num = 0
      .
    end.
    else do:
      assign
        v-db-num = buf_sys-ctrl.db-num
      .
    end.
    find first buf_code-range no-lock
      where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
      use-index stts
      no-error .
    if available buf_code-range
       and l-code <= buf_code-range.last-code
       and l-code >= buf_code-range.first-code then do:
      assign
        p-b-code = l-code
      .
    end.
    else do:
      if available buf_code-range
         and l-code < buf_code-range.last-code then do:
        message
          substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
          "Обратитесь к администратору системы."
          view-as alert-box error .
        undo, return error "sequence":U .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_thbj-attr exclusive-lock
          where buf_thbj-attr.upper-prop-code = 'code-range':U
            and buf_thbj-attr.prop-code = cfg-param-code
            and buf_thbj-attr.obj-type   = 'БД':U
            and buf_thbj-attr.obj-code   = v-db-num
          no-error .
        if not available buf_thbj-attr then do:
          find first buf_thbj-attr exclusive-lock
            where buf_thbj-attr.upper-prop-code = 'code-range':U
              and buf_thbj-attr.prop-code = cfg-param-code
              and buf_thbj-attr.obj-type   = ''
              and buf_thbj-attr.obj-code   = 0
            no-error .
          if not available buf_thbj-attr then do:
            if not locked buf_thbj-attr then do:
              message
                substitute( "Отсутствует параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
                "Обратитесь к администратору системы."
                view-as alert-box error .
            end.
            undo, return error "config":U .
          end.
        end.
        run get-next-seq( input type-code,
                          output l-code
                        ).
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
            and buf_code-range.range-type = type-code
            and buf_code-range.stts       = "a"
          use-index stts
          no-error .
        if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then do:
          assign
            p-b-code = l-code
          .
        end.
        else do:
          if available buf_code-range then do:
            assign
              buf_code-range.stts = "u"
            .
          end.
          find first buf_code-range
            where buf_code-range.db-num     = v-db-num
              and buf_code-range.range-type = type-code
              and buf_code-range.stts       = "f"
            use-index stts
            no-error .
          if not available buf_code-range then do:
            message
              substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
              "Обратитесь к администратору системы"
              view-as alert-box error .
            undo, return error "code-range":U .
          end.
          assign
            buf_code-range.stts           = "a"
          .
          if buf_code-range.first-code = 1 then do:
            run set-seq-cr( input type-code,
                            input buf_code-range.first-code
                          ).
            assign
              p-b-code = 1
            .
          end.
          else do:
            run set-seq-cr( input type-code,
                            input ( buf_code-range.first-code - 1 )
                          ).
            run get-next-seq( input type-code,
                              output p-b-code
                            ).
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure get-next-seq :
  define input  parameter type-code like ub.code-range.range-type no-undo .
  define output parameter next-seq  as   integer                  no-undo .
  do
  on error  undo, return error substitute( "&1 (get-next-seq). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-next-seq). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-next-seq). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  end.
end procedure.
procedure set-seq-cr :
  define input parameter type-code like ub.code-range.range-type no-undo .
  define input parameter set-val   like ub.code-range.first-code no-undo .
  do
  on error  undo, return error substitute( "&1 (set-seq-cr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-seq-cr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-seq-cr). endkey", vss-workfile )
  :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
  end.
end procedure.
procedure new-bcod-gen-code-range :
  do
  on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
  :
    define input parameter p-db-num  like ub.db.db-num             no-undo .
    define input parameter type-code like ub.code-range.range-type no-undo .
    define buffer buf_code-range      for ub.code-range .
    define buffer last_code-range     for ub.code-range .
    define buffer last-1_code-range   for ub.code-range .
    define buffer last-2_code-range   for ub.code-range .
    define buffer last-3_code-range   for ub.code-range .
    define buffer buf_sys-ctrl        for ub.sys-ctrl .
    define variable conf-par       as character no-undo .
    define variable par-type       as character no-undo .
    define variable cfg-param-code like ub.thbj-attr.prop-code no-undo .
    define variable v-cre-cdrg as logical   no-undo .
    define variable v-cre-str  as character no-undo .
    define variable v-cr1      as integer no-undo .
    define variable v-cr2      as integer no-undo .
    define variable v-cr3      as integer no-undo .
    define variable v-cmax     as integer no-undo .
    find first buf_sys-ctrl no-lock .
    if buf_sys-ctrl.db-num <> 0 and type-code <> 'cagb':U then do:
      undo, return error substitute("&1 &2 &3&4Диапазоны кодов можно создавать только в ГБД&4База данных &5"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    , p-db-num
                                   ).
    end.
    run trg/getpcode.p ( input  type-code
                   ,output cfg-param-code
                  ).
    for each buf_code-range
      where buf_code-range.db-num     = -1
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "f"
    by buf_code-range.first-code
    on error  undo, return error substitute( "&1 (new-bcod-gen-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (new-bcod-gen-code-range). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (new-bcod-gen-code-range). endkey", vss-workfile )
    :
      assign
        buf_code-range.db-num = p-db-num
      .
      return .
    end.
    assign
      v-cre-cdrg = TRUE
    .
    case type-code:
      when 'sclc':U
      or when 'scgb':U
      or when 'pglc':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sclc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'scgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'pglc':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
        if last_code-range.last-code + 1 > 99999 then do:
          assign
            v-cre-cdrg = FALSE
          .
        end.
      end.
      when 'bcgb':U
      or when 'sslc':U
      or when 'ssgb':U
      then do:
        find last last-1_code-range no-lock
          where last-1_code-range.range-type = 'sslc':U
          no-error .
        if available last-1_code-range then do:
          v-cr1 = last-1_code-range.last-code.
        end.
        find last last-2_code-range no-lock
          where last-2_code-range.range-type = 'bcgb':U
          no-error .
        if available last-2_code-range then do:
          v-cr2 = last-2_code-range.last-code.
          end.
        find last last-3_code-range no-lock
          where last-3_code-range.range-type = 'ssgb':U
          no-error .
        if available last-3_code-range then do:
          v-cr3 = last-3_code-range.last-code.
        end.
        v-cmax = maximum(v-cr1, v-cr2, v-cr3)
        .
        if v-cmax = v-cr1  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-1_code-range )
              .
          end.
        if v-cmax = v-cr2  then do:
            find last last_code-range no-lock
              where recid( last_code-range ) = recid( last-2_code-range )
              .
          end.
        if v-cmax = v-cr3  then do:
          find last last_code-range no-lock
            where recid( last_code-range ) = recid( last-3_code-range )
            .
        end.
      end.
      otherwise do:
        find last last_code-range no-lock
          where last_code-range.range-type = type-code
          no-error .
      end.
    end case.
    if not available last_code-range then do:
      undo, return error substitute("&1 &2 &3&4В БД нет ни одного диапазона с типом &5&4Не была проведена инициализация диапазонов!"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    , chr(10)
                                    , type-code
                                   ) .
    end.
    define variable v-mes9 as character no-undo .
    define variable v-param-type9 as character no-undo .
    define variable v-value-character9 as INTEGER no-undo .
    define variable v-value-date9 as date no-undo .
    define variable v-value-decimal9 as decimal no-undo .
    define variable v-value-integer9 AS integer no-undo .
    define variable v-value-logical9 AS LOGICAL no-undo .
    define variable v-tth9 as handle no-undo .
    run adm/shattri.p (
        input "get":U
        ,input  'БД':U
        ,input  p-db-num
        ,input  'code-range':U
        ,input  cfg-param-code
        ,output v-value-character9
        ,output v-value-date9
        ,output v-value-decimal9
        ,output v-value-integer9
        ,output v-value-logical9
        ,output v-param-type9
        ,INPUT-OUTPUT table-handle v-tth9
        ) no-error .
    if error-status :error then do:
      delete object v-tth9.
      v-mes9 = substitute("Ошибка при получении размера диапазона собственных глобальных кодов&2&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value ).
      undo, return error v-mes9.
    end.
    delete object v-tth9.
    if v-cre-cdrg = TRUE then do:
      create buf_code-range .
      assign
        buf_code-range.db-num     = p-db-num
        buf_code-range.range-type = type-code
        buf_code-range.stts       = "f"
        buf_code-range.first-code = last_code-range.last-code + 1
        buf_code-range.last-code  = last_code-range.last-code + integer(v-value-integer9)
        v-cre-str = "Свободный диапазон успешно создан"
      .
    end.
    else do:
      assign
        v-cre-str = "Нет возможности создать свободный диапазон." + chr(10)
                    + substitute( "Превышен предел диапазонов c типом &1", type-code )
      .
    end.
  end.
  return v-cre-str .
end procedure.
procedure gen-new-code-range-if-neces :
  define input parameter v-db-num           like ub.db.db-num             no-undo .
  define input parameter v-range-type       like ub.code-range.range-type no-undo .
  define input parameter v-cur-code         as   integer                  no-undo .
  define input parameter v-g#news           as   logical                  no-undo .
  define input parameter v-g#db-num         like ub.db.db-num             no-undo .
  define input parameter v-g#news-source-db like ub.db.db-num             no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (gen-new-code-range-if-neces). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-new-code-range-if-neces). endkey", vss-workfile )
  :
    define variable l-code-range-exist as logical   no-undo init false .
    define variable v-db-for-send      as character no-undo .
    define buffer buf_code-range  for ub.code-range .
    define buffer buf1_code-range for ub.code-range .
    define buffer buf_db          for ub.db .
    find first buf_code-range
      where buf_code-range.range-type = v-range-type
        and buf_code-range.last-code >= v-cur-code
      use-index last-codei
      no-error .
    if
    (
       available buf_code-range
       and
      (buf_code-range.db-num = v-db-num
        and
      buf_code-range.first-code <= v-cur-code
      )
    or
      (
        v-range-type = 'drgb':U
        AND
        v-cur-code = 0
      )
   )
   then do:
      assign
        l-code-range-exist = true
      .
      if v-g#news
      and buf_code-range.stts = "f" then do:
        assign
          buf_code-range.stts = "u"
        .
      end.
    end.
    if not l-code-range-exist
       and v-g#news-source-db <> 0
    then do:
      undo, return error substitute("&1 &2 &3&4Отсутствует диапазон кодов для БД &5 Тип диапазона кодов &6 Код &7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,v-db-num
                                    ,v-range-type
                                    ,v-cur-code
                                   ).
    end.
    if (not l-code-range-exist
        or ( v-cur-code >= int( (buf_code-range.first-code + buf_code-range.last-code) / 2 ) )
       )
    and ( not can-find (first buf1_code-range no-lock
                        where buf1_code-range.db-num = v-db-num
                          and buf1_code-range.range-type = v-range-type
                          and buf1_code-range.stts = "f"
                       )
        )
    then do:
      if v-g#db-num = 0 then do:
        run new-bcod-gen-code-range in this-procedure
          (input v-db-num,
           input v-range-type
          ) no-error .
        if error-status :error then do:
          undo, return error substitute("Ошибка при создании нового свободного диапазона &1 Тип диапазона кодов &2 Код &3:&4&5 &6"
                                        , substitute("&1 &2 &3", vss-workfile, vss-revision, vss-description)
                                        ,v-db-num
                                        ,v-range-type
                                        ,v-cur-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value
                                       ).
        end.
      end.
      else do:
        if v-range-type = 'sclc':U
        or v-range-type = 'pglc':U
        then do:
          assign
            v-db-for-send = "":U
          .
          if v-g#db-num = 0 then do:
            for each buf_db no-lock
              where buf_db.db-num > 0
                and buf_db.db-num <> v-g#news-source-db
            on error  undo, return error substitute( "&1 (gen-new-code-range-if-neces). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
            :
              assign
                v-db-for-send = v-db-for-send + chr(1) + string( buf_db.db-num )
              .
            end.
            assign
              v-db-for-send = right-trim( v-db-for-send, chr(1) )
            .
          end.
          else do:
            if not v-g#news then do:
              assign
                v-db-for-send = "0":U
              .
            end.
          end.
          run nws/cr-route.p ( input 'send-cmd':U
                        ,input ("command":U + chr(1) + "create":U + chr(1) +
                               "code-range":U + chr(1) +
                               (if v-range-type = 'sclc':U
                                then string( current-value(s-sclc-code, ub))
                                else string( current-value(s-pglc-code, ub))
                                ) + chr(1) +
                                v-range-type)
                        ,input ?
                        ,input v-db-for-send
                        ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure cre-loc-sc-code-range :
  define input parameter v-cur-code as integer no-undo .
define input parameter p-cdrg-type as character no-undo .
  do
  on error  undo, return error substitute( "&1 (cre-loc-sc-code-range). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (cre-loc-sc-code-range). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (cre-loc-sc-code-range). endkey", vss-workfile )
  :
    define buffer buf_code-range for ub.code-range .
    find first buf_code-range
         where buf_code-range.range-type = p-cdrg-type
           and buf_code-range.first-code >= v-cur-code
         no-error .
    if not available buf_code-range then do:
      run new-bcod-gen-code-range in this-procedure
        ( input 0,
          input p-cdrg-type
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "Ошибка при создании нового свободного диапазона локальных весовых или штучных кодов&1"
                                       + "Код &2&1&3 &4"
                                      , chr(10)
                                      , v-cur-code
                                      , error-status:get-message(1)
                                      , return-value
                                     ) .
      end.
    end.
  end.
end procedure.
procedure mark-used-if-need :
define input parameter p-cur-code as integer no-undo .
define input parameter p-range-type like ub.code-range.range-type no-undo .
define input parameter p-db-num like ub.code-range.db-num no-undo .
  do
  on error  undo, return error substitute( "&1 (mark-used-if-need). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (mark-used-if-need). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (mark-used-if-need). endkey", vss-workfile )
  :
    DEFINE VARIABLE v-db-num like ub.code-range.db-num no-undo .
    define buffer buf_code-range for ub.code-range .
    assign
    v-db-num = if p-range-type = 'sclc':U
               then 0
               else p-db-num
    .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer locK-batchprocess10 for ub.batchprocess.
run gbl/lock-prc.p
    (input 'lscc':U
    ,input 0
    ,input 0
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input (
            ",,,Вкл/выкл лок. вес. кодов"
           )
    ,input true
    ,buffer lock-batchprocess10
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент идет процесс вкл/выкл лок. вес. кодов" skip
      view-as alert-box error .
    undo, return error .
  end.
    find first buf_code-range
         where buf_code-range.range-type = p-range-type
           and buf_code-range.first-code >= p-cur-code
           and buf_code-range.last-code <= p-cur-code
           and buf_code-range.db-num = v-db-num
         no-error .
    if not available buf_code-range then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании поиске диапазона" skip
        "База данных" p-db-num skip
        "Код" p-cur-code skip
        "Тип" p-range-type
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_code-range.stts = "f":U then do:
      assign
      buf_code-range.stts = "u":U
      .
    end.
  end.
end procedure.
FUNCTION cbnki-period-to-String returns character(input  p-date1 as date, input p-date2 as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date1), "9999":U) + chr(47) +
             string(Month(p-date1), "99":U) + chr(47) +
             string(DAY(p-date1), "99":U) + '-':U +
             string(YEAR(p-date2), "9999":U) + chr(47) +
             string(Month(p-date2), "99":U) + chr(47) +
             string(DAY(p-date2), "99":U).
return v-date-str.
END FUNCTION.
define variable log-file-name as character no-undo init "ext-cbnk.log".
define variable sss as character no-undo .
define variable var-file-line-num as integer no-undo .
define variable ii as integer no-undo .
define variable n-entry as character no-undo extent 2.
define variable v-count as integer no-undo .
define variable gbl-type as character no-undo .
define variable gbl-schet as character no-undo .
DEFINE VARIABLE accept-types               as   character no-undo init "Платежное поручение".
define variable exist as logical no-undo init yes.
define variable exist-statement as logical no-undo init yes.
define variable in-doc as integer no-undo .
define variable in-statement as integer no-undo .
define variable v-version-TH as character no-undo .
define variable v-exchange-file as logical no-undo .
define variable v-crit-err   as logical no-undo .
define variable v-seq as integer no-undo .
define variable v-seq-statement as integer no-undo .
define variable v-bank-date-chr as character no-undo .
define stream PrnLibStream.
define temp-table tt-1s-fin-doc no-undo like ub.fin-doc
field fin-doc-code-th as integer
.
define temp-table tt-th-fin-doc no-undo like ub.fin-doc.
define temp-table tt-1s-fin-statement no-undo like ub.fin-statement.
define temp-table tt-th-fin-statement no-undo like ub.fin-statement.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
do
on error undo, return error
:
  for each tt-1s-fin-doc:
    delete tt-1s-fin-doc.
  end.
  for each tt-th-fin-doc:
    delete tt-th-fin-doc.
  end.
  if p-encoding = 'WIndows-1251' then do:
    input stream PRnLibStream from value( p-file-name ).
  end.
  else do:
    input stream PRnLibStream from value( p-file-name ) convert source p-encoding.
  end.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("&3Чтение файла импорта &1 Отправитель &2&3" +                               "Банк с БИК &4"                                                            ,  p-file-name                                                             , p-adresat                                                                , chr(10)                                                            , p-bik   )).
  _repeat:
  REPEAT :
  _line:
  DO TRANSACTION:
    import stream PrnLibStream unformatted sss.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if var-file-line-num modulo 50 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", p-file-name, var-file-line-num)).
    end.
    if sss = "" or sss = ? then do:
        assign
        n-entry[1] = ""
        n-entry[2] = ""
        .
        leave _line.
    end.
    assign
    n-entry[1] = entry(1, sss, "=")
    n-entry[2] = (if num-entries(sss, '=':U) > 1
                  then substring(sss, length(n-entry[1]) + 2)
                  else '':U)
    .
  END.
  DO TRANSACTION :
    if n-entry[2] = 'Windows'
    or n-entry[2] = 'DOS' then do:
      if (n-entry[2] = 'Windows'
      and p-encoding <> 'WIndows-1251'
      )
      or (n-entry[2] = 'DOS'
      and p-encoding <> 'ibm866') then do:
          input stream PrnLibStream close.
          p-view-log = yes.
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неверно выбрана кодировка: выбрана &1,&2а в импортируемом файле &3&2Файл &4"                          , (if p-encoding = 'Windows-1251' then 'Windows' else 'DOS')                                                 , chr(10)                                                                                              , n-entry[2]                                                                                                 , p-file-name                                             )).
          return.
      end.
    end.
    CASE n-entry[1]:
      when '1CClientBankExchange' then do:
        assign
        v-exchange-file = yes
        .
      end.
      when 'КонецФайла' then do:
        if in-doc > 0 then do:
          assign
          v-crit-err = yes
          p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Метка <КонецФайла> в середине секции документа:&1Импорт прерван&1"                              , chr(10)                                                                                          )).
          return.
        end.
      end.
      when ''
      or
      when 'КонецДокумента'
      then do:
        run proc-end-doc in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"                              , chr(10)                                                                                                  , error-status:get-message(1)                                                                                    , return-value                                   )).
            return.
          end.
          else do:
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input return-value).
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end.
      when 'ДатаСоздания' then do:
        assign
        v-bank-date-chr = n-entry[2]
        .
      end.
      when 'Получатель' then do:
        if in-doc = 0 then do:
          run gbl/getvers.p (output v-version-TH).
          v-version-TH = substitute('IBS TH &1', v-version-TH).
          if n-entry[2] <> v-version-TH then do:
            input stream PrnLibStream close.
              p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неверный получатель: &1&2, ожидалось &3&2Файл &4"                              , n-entry[2]                                                     , chr(10)                                                                                                  , v-version-TH                                                                                                     , p-file-name                                             )).
              return.
          end.
        end.
      end.
      when 'Отправитель' then do:
        if n-entry[2] <> p-adresat then do:
          input stream PrnLibStream close.
            p-view-log = yes.
            run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неверный отправитель: &1&2, ожидалось &3&2Файл &4"                            , n-entry[2]                                                   , chr(10)                                                                                                , p-adresat                                                                                                    , p-file-name                                             )).
            return.
        end.
      end.
      when 'ВерсияФормата' then do:
        if n-entry[2] <> '1.01' then do:
           input stream PrnLibStream close.
            p-view-log = yes.
            run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неверная версия формата: &1&2, ожидалось &3&2Файл &4"                            , n-entry[2]                                                   , chr(10)                                                                                                , '1.01'                                                                                        , p-file-name                                             )).
            return.
        end.
      end.
      when 'СекцияДокумент' then  do:
        if not v-exchange-file then do:
           input stream PrnLibStream close.
            p-view-log = yes.
            run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input "!!!Отсутствует признак файла обмена (1CClientBankExchange)").
            return.
        end.
        run proc-end-gen in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"                              , chr(10)                                                                                                  , error-status:get-message(1)                                                                                    , return-value                                   )).
            return.
          end.
          else do:
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input return-value).
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
        run proc-00-doc in this-procedure no-error .
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end.
      when 'РасчСчет' then  do:
        assign
        gbl-schet = n-entry[2].
      end.
      when 'СекцияРасчСчет' then  do:
        if not v-exchange-file then do:
           input stream PrnLibStream close.
            p-view-log = yes.
            run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input "!!!Отсутствует признак файла обмена (1CClientBankExchange)").
            return.
        end.
        run proc-end-gen in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"                              , chr(10)                                                                                                  , error-status:get-message(1)                                                                                    , return-value                                   )).
            return.
          end.
          else do:
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input return-value).
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
        run proc-00-statement in this-procedure no-error .
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end.
      when 'КонецРасчСчет' then  do:
        run proc-end-statement in this-procedure no-error .
        if error-status:error  then do:
          v-crit-err = yes.
          if (return-value = '':U or
          return-value = 'error')
          then do:
            input stream PrnLibStream close.
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"                              , chr(10)                                                                                                  , error-status:get-message(1)                                                                                    , return-value                                   )).
            return.
          end.
          else do:
            p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input return-value).
          end.
        end.
        if return-value = 'error' then do:
          input stream PrnLibStream close.
          return.
        end.
      end.
      otherwise do:
        find first temp_hfields where
                    temp_hfields.label_ = (n-entry[1] + '=':U) no-error.
          if available temp_hfields then do:
            if (not exist and temp_hfields.subject = 'fin-doc':U)
            or (not exist-statement and temp_hfields.subject = 'fin-statement':U)
            then do:
              if in-doc > 0
              and in-statement = 0
              then do:
                assign
                TEMP_hfields.value_ = n-entry[2]
                temp_hfields.readed = yes
                .
              end.
              if in-statement > 0
              and in-doc = 0
              then do:
                assign
                TEMP_hfields.value_ = n-entry[2]
                temp_hfields.readed = yes
                .
              end.
              if in-doc = 0
              and in-statement = 0 then do:
                assign
                in-doc = 0
                in-statement = 0
                exist = yes
                exist-statement = yes
                p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Поле &1 вне секции документа или секции выписки пл счету&2Файл &3 строка &4"                            , temp_hfields.label_                                                               , chr(10)                                                                     , p-file-name                                                                       , var-file-line-num                     )).
                input stream PrnLibStream close.
                return.
              end.
            end.
          end.
          else do:
            if in-doc > 0 then do:
              p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неизвестное поле <&1> при импорте документа&2Файл &3"                              , n-entry[1]                                                                          , chr(10)                                                                       , p-file-name                                                                         , var-file-line-num)).
            end.
            if in-statement > 0 then do:
              p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неизвестное поле <&1> при импорте выписки&2Файл &3"                              , n-entry[1]                                                                          , chr(10)                                                                       , p-file-name                                                                         , var-file-line-num)).
            end.
          end.
        end.
      END CASE .
    END.
  END .
  DO TRANSACTION:
    run proc-end-gen in this-procedure no-error .
    if error-status:error  then do:
      v-crit-err = yes.
      if (return-value = '':U or
      return-value = 'error')
      then do:
        input stream PrnLibStream close.
        p-view-log = yes.
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Ошибки при чтении файла:&1&2 &3&1Импорт прерван&1"                          , chr(10)                                                                                              , error-status:get-message(1)                                                                                , return-value                                   )).
        return.
      end.
      else do:
        p-view-log = yes.
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input return-value).
      end.
    end.
    if return-value = 'error' then do:
      input stream PrnLibStream close.
      return.
    end.
  END.
  assign
  error-status:error = false.
  input stream PrnLibStream close.
end.
run show-counter in p-log-handle .
run write-counter in p-log-handle ('':U).
if not v-crit-err then do:
  run proc-write-out in this-procedure no-error.
  if error-status:error then do:
    run hide-counter in p-log-handle.
              p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Ошибка при обработке импортируемых документов&1&2 &3&1&4&1"                              , chr(10)                                                                       , error-status:get-message(1)                                                         , return-value                                                                        , 'все импортированные изменения НЕ будут сохранены'               )).
    assign
    p-processed = 0
    p-created = 0
    .
  end.
end.
procedure proc-00-doc:
  do
  on error undo, return error
  :
    assign
    gbl-type = n-entry[2]
    p-count = p-count + 1
    .
    if can-do(accept-types,  gbl-type ) then do:
      for each temp_hfields where temp_hfields.subject = 'fin-doc':U:
        assign
        temp_hfields.value_ = ?
        temp_hfields.imported = no
        temp_hfields.readed = no
        .
      end.
      find first temp_hfields where
                temp_hfields.subject = 'fin-doc':U
            and temp_hfields.label_ = (n-entry[1] + '=':U).
      assign
      TEMP_hfields.value_ = n-entry[2]
      TEMP_hfields.readed = yes
      .
      assign
      in-doc = var-file-line-num
      exist = no
      .
    end.
    else do:
      assign
      exist = yes
      .
      return.
    end.
  end.
end procedure.
procedure proc-00-statement:
define variable gbl-r-schet as character no-undo .
  do
  on error undo, return error
  :
    assign
    gbl-r-schet = n-entry[2]
    p-count-statement = p-count-statement + 1
    .
    if p-rs-hsch = 2 then do:
      find first temp_hfin-schet no-lock where
              temp_hfin-schet.host-code = p-host-code
          AND temp_hfin-schet.r-schet = gbl-r-schet no-error .
      if not available temp_hfin-schet then do:
        assign
        exist-statement = yes.
        return.
      end.
    end.
    else do :
      for each temp_hfields where temp_hfields.subject = 'fin-statement':U:
        assign
        temp_hfields.value_ = ?
        temp_hfields.imported = no
        temp_hfields.readed = no
        .
      end.
      find first temp_hfields where
                temp_hfields.subject = 'fin-statement':U
            and temp_hfields.label_ = ('РасчСчет' + '=':U)  .
      assign
      TEMP_hfields.value_ = gbl-schet
      TEMP_hfields.readed = yes
      .
      find first temp_hfields where
                temp_hfields.subject = 'fin-statement':U
            and temp_hfields.label_ = ('ДатаСоздания' + '=':U) .
      assign
      TEMP_hfields.value_ = v-bank-date-chr
      TEMP_hfields.readed = yes
      .
      find first temp_hfields where
                temp_hfields.subject = 'fin-statement':U
            and temp_hfields.label_ = (n-entry[1] + '=':U).
      assign
      TEMP_hfields.value_ = n-entry[2]
      TEMP_hfields.readed = yes
      .
      assign
      in-statement = var-file-line-num
      exist-statement = no
      .
    end.
  end.
end procedure.
procedure proc-end-gen :
  do
  on error undo, return error
  :
    if in-doc > 0 then do:
      run proc-end-doc in this-procedure .
    end.
    if in-statement > 0 then do:
      run proc-end-statement in this-procedure .
    end.
  end.
end procedure.
procedure proc-end-doc :
define variable h-buffer as handle no-undo .
define variable h-field as handle no-undo .
define variable ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-dop2 as character no-undo .
define variable v-inn as integer no-undo .
define variable v-skip as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_temp_hfields for temp_hfields.
define buffer find_first-fin-bank for ub.fin-bank.
define buffer receiver-firm for ub.firm.
define buffer receiver-person for ub.person.
define buffer payer-firm for ub.firm.
define buffer payer-person for ub.person.
  _main:
  do
  on error undo _main, return error
  :
    if in-doc = 0 or exist then return.
    assign
    in-doc = 0
    exist  = yes
    .
    find first temp_hfields no-lock where
              temp_hfields.subject = 'fin-doc':U
          and temp_Hfields.name_ = 'fact-date'
          AND temp_Hfields.readed = yes
              no-error.
    if not available temp_hfields then do:
                  run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Отсутствует обязательный реквизит платежа <ДатаСписано>(<ДатаПоступило>)&1Файл &2 строка НАЧАЛА ДОКУМЕНТА &3"                             , chr(10)                                                                      , p-file-name                                                                        , var-file-line-num                                        )).
           p-view-log = yes.
           assign
           in-doc = 0
           exist = yes.
           return "error".
     end.
     create tt-1s-fin-doc.
     assign
     tt-1s-fin-doc.status_ = 'факт':U.
     assign
     tt-1s-fin-doc.fin-doc-code = - (v-seq + 1)
     v-seq = v-seq + 1
     .
     assign
     h-buffer = buffer tt-1s-fin-doc:handle
     .
     do ii = 1 to h-buffer:num-fields:
       assign
       h-field = h-buffer:buffer-field(ii)
       .
       find first temp_hfields no-lock where
                 temp_hfields.subject = 'fin-doc':U
             and temp_hfields.name_ = h-field:name
             AND temp_hfields.readed = yes  no-error.
       if available temp_hfields then do:
         CASE h-field:data-type:
           when 'date' then do:
              assign
              h-field:buffer-value = date(temp_hfields.value_)
              no-error .
           end.
           when 'integer' then do:
              assign
              h-field:buffer-value = integer(temp_hfields.value_)
              no-error .
           end.
          when 'decimal' then do:
              assign
              h-field:buffer-value = decimal(temp_hfields.value_)
              no-error .
           end.
           when 'logical' then do:
              assign
              h-field:buffer-value = logical(temp_hfields.value_)
              no-error .
           end.
           when 'character' then do:
             assign
             h-field:buffer-value = temp_hfields.value_
             .
           end.
           otherwise do:
             error-status:error = no.
           end.
         END CASE.
         if error-status:error then do:
                  run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неверное значение поля &1: &5&2Файл &3 строка НАЧАЛА ДОКУМЕНТА &4"                             , temp_hfields.label_                                                                , chr(10)                                                                      , p-file-name                                                                        , var-file-line-num                                                                  , temp_hfields.value_                      )).
           p-view-log = yes.
           delete tt-1s-fin-doc.
           assign
           in-doc = 0
           exist = yes.
           return "error".
         end.
         assign
         temp_Hfields.imported = yes.
      end.
    end.
    for each temp_hfields where
              temp_hfields.imported = no
          AND temp_hfields.readed = yes
          and temp_hfields.subject = 'fin-doc':U
          :
       CASE temp_hfields.name_ :
        when 'fin-ext-doc-type/' then do:
          CASE temp_hfields.value_ :
            when 'Платежное поручение' then do:
              for each find_first-fin-bank where
                      find_first-fin-bank.host-code = p-host-code
                  AND find_first-fin-bank.bik       = p-bik
                  AND find_first-fin-bank.status_   = 'тек':U,
                  first buf_fin-schet no-lock where
                        buf_fin-schet.host-code = find_first-fin-bank.host-code
                    and buf_fin-schet.code-bank = find_first-fin-bank.code-bank
                    AND buf_fin-schet.r-schet =  tt-1s-fin-doc.payer-r-schet
                    and buf_fin-schet.status_ = 'тек':U
                    and buf_fin-schet.cli-type = 'орг':U
                    and buf_fin-schet.cli-code = find_first-fin-bank.host-code:
                LEAVE.
              end.
              if available buf_fin-schet then do:
                assign
                tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                tt-1s-fin-doc.fin-doc-type = 'рпп':U
                tt-1s-fin-doc.host-code    = p-host-code
                tt-1s-fin-doc.payer-type = 'орг':U
                tt-1s-fin-doc.payer-code = buf_fin-schet.cli-code
                tt-1s-fin-doc.payer-code-schet = buf_fin-schet.code-schet
                tt-1s-fin-doc.curr-code = buf_fin-schet.curr-code
                .
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'payer-type' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'payer-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'payer-code-bank' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'payer-code-schet' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'curr-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                if p-rs-hsch = 2 then do:
                  find first temp_hfin-schet no-lock where
                          temp_hfin-schet.host-code = tt-1s-fin-doc.host-code
                      AND temp_hfin-schet.code-schet = tt-1s-fin-doc.payer-code-schet no-error .
                  if not available temp_hfin-schet then do:
                    assign
                    v-skip = yes.
                  end.
                end.
                if not v-skip then do:
                  find first buf_fin-bank no-lock where
                            buf_Fin-bank.host-code = tt-1s-fin-doc.host-code
                        AND buf_Fin-bank.bik = tt-1s-fin-doc.receiver-bik
                        AND buf_Fin-bank.cor-acc = tt-1s-fin-doc.receiver-c-schet
                        and buf_fin-bank.status_ = 'тек':U no-error.
                  if not available buf_fin-bank then do:
                    v-mess = substitute("!!!Не найден в БД (или удален) банк ПОЛУЧАТЕЛЯ&1 - БИК &2&1Коррсчет &3"
                                       , chr(10)
                                       , tt-1s-fin-doc.receiver-bik
                                       , tt-1s-fin-doc.receiver-c-schet
                                       ).
                    undo _main, return error v-mess.
                  end.
                  for each buf_fin-schet no-lock where
                          buf_fin-schet.host-code = tt-1s-fin-doc.host-code
                      AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
                      AND buf_fin-schet.r-schet =  tt-1s-fin-doc.receiver-r-schet
                      AND buf_fin-schet.status_ = 'тек':U:
                    if buf_fin-schet.cli-type = 'орг':U then do:
                      find first receiver-firm no-lock where
                              receiver-firm.firm-code = buf_fin-schet.cli-code
                          and receiver-firm.inn = tt-1s-fin-doc.receiver-inn no-error.
                      if available receiver-firm then leave.
                    end.
                    if buf_fin-schet.cli-type = 'чел':U then do:
                      find first receiver-person no-lock where
                             receiver-person.psn-code = buf_fin-schet.cli-code
                          and receiver-person.inn = tt-1s-fin-doc.receiver-inn no-error.
                      if available receiver-person then leave.
                    end.
                  end.
                  if not available buf_fin-schet then do:
                    assign
                    v-mess =  substitute("!!!Не найден в БД (или удален) счет ПОЛУЧАТЕЛЯ&1 банк с БИК &2 (вн код &3),&1р/с &4, ИНН &5 "
                                       , chr(10)
                                       , tt-1s-fin-doc.receiver-bik
                                       , buf_fin-bank.code-bank
                                       , tt-1s-fin-doc.receiver-r-schet
                                       , tt-1s-fin-doc.receiver-inn
                                       ).
                    undo _main, return error v-mess.
                  end.
                  assign
                  tt-1s-fin-doc.receiver-code-schet = buf_fin-schet.code-schet
                  tt-1s-fin-doc.receiver-type = buf_fin-schet.cli-type
                  tt-1s-fin-doc.receiver-code = buf_fin-schet.cli-code
                  .
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'receiver-code-schet' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'receiver-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'receiver-type' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                end.
              end.
              else do:
                for each find_first-fin-bank where
                        find_first-fin-bank.host-code = p-host-code
                    AND find_first-fin-bank.bik       = p-bik
                    AND find_first-fin-bank.status_   = 'тек':U,
                    first buf_fin-schet no-lock where
                          buf_fin-schet.host-code = find_first-fin-bank.host-code
                      and buf_fin-schet.code-bank = find_first-fin-bank.code-bank
                      AND buf_fin-schet.r-schet =  tt-1s-fin-doc.receiver-r-schet
                      and buf_fin-schet.status_ = 'тек':U
                      and buf_fin-schet.cli-type = 'орг':U
                      and buf_fin-schet.cli-code = find_first-fin-bank.host-code:
                  LEAVE.
                end.
                if available buf_fin-schet then do:
                  assign
                  tt-1s-fin-doc.fin-ext-doc-type = 'ппп':U
                  tt-1s-fin-doc.fin-doc-type = 'ппп':U
                  tt-1s-fin-doc.host-code    = p-host-code
                  tt-1s-fin-doc.receiver-type = 'орг':U
                  tt-1s-fin-doc.receiver-code = buf_fin-schet.cli-code
                  tt-1s-fin-doc.receiver-code-schet = buf_fin-schet.code-schet
                  tt-1s-fin-doc.curr-code = buf_fin-schet.curr-code
                  .
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'receiver-type' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'receiver-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'receiver-code-schet' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'curr-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                end.
                else do:
                  assign
                  v-seq = v-seq + 1
                  v-mess = substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +
                              'счета ПЛАТЕЛЬЩИКА И ПОЛУЧАТЕЛЯ отсутствуют в БД'
                            , tt-1s-fin-doc.prn-doc-code
                            , p-host-code
                            , chr(10)
                            , tt-1s-fin-doc.payer-name
                            , tt-1s-fin-doc.receiver-name                                  ).
                  assign
                  v-crit-err = yes.
                  undo _main, return error v-mess.
                end.
                if p-rs-hsch = 2 then do:
                  find first temp_hfin-schet no-lock where
                          temp_hfin-schet.host-code = tt-1s-fin-doc.host-code
                      AND temp_hfin-schet.code-schet = tt-1s-fin-doc.receiver-code-schet no-error .
                  if not available temp_hfin-schet then do:
                    assign
                    v-skip = yes.
                  end.
                end.
                if not v-skip then do:
                  find first buf_fin-bank no-lock where
                            buf_Fin-bank.host-code = tt-1s-fin-doc.host-code
                        AND buf_Fin-bank.bik = tt-1s-fin-doc.payer-bik
                        AND buf_fin-bank.status_ = 'тек':U
                        AND buf_fin-bank.cor-acc = tt-1s-fin-doc.payer-c-schet  no-error.
                  if not available buf_fin-bank then do:
                    v-mess = substitute("!!!Не найден (или удален) в БД банк ПЛАТЕЛЬЩИКА&1 - БИК &2&1Коррсчет &3"
                                       , chr(10)
                                       , tt-1s-fin-doc.payer-bik
                                       , tt-1s-fin-doc.payer-c-schet
                                       ).
                    undo _main, return error v-mess.
                  end.
                  for each buf_fin-schet no-lock where
                          buf_fin-schet.host-code = tt-1s-fin-doc.host-code
                      AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
                      AND buf_fin-schet.r-schet =  tt-1s-fin-doc.payer-r-schet
                      AND buf_fin-schet.status_ = 'тек':U :
                    if buf_fin-schet.cli-type = 'орг':U then do:
                      find first payer-firm no-lock where
                              payer-firm.firm-code = buf_fin-schet.cli-code
                          and payer-firm.inn = tt-1s-fin-doc.payer-inn no-error.
                      if available payer-firm then leave.
                    end.
                    if buf_fin-schet.cli-type = 'чел':U then do:
                      find first payer-person no-lock where
                             payer-person.psn-code = buf_fin-schet.cli-code
                          and payer-person.inn = tt-1s-fin-doc.payer-inn no-error.
                      if available payer-person then leave.
                    end.
                  end.
                  if not available buf_fin-schet then do:
                    assign
                    v-mess =  substitute("!!!Не найден в БД (или удален) счет ПЛАТЕЛЬЩИКА&1 банк с БИК &2 (вн код &3),&1р/с &4, ИНН &5 "
                                       , chr(10)
                                       , tt-1s-fin-doc.payer-bik
                                       , buf_fin-bank.code-bank
                                       , tt-1s-fin-doc.payer-r-schet
                                       , tt-1s-fin-doc.payer-inn
                                       ).
                    undo _main, return error v-mess.
                  end.
                  assign
                  tt-1s-fin-doc.payer-code-schet = buf_fin-schet.code-schet
                  tt-1s-fin-doc.payer-type = buf_fin-schet.cli-type
                  tt-1s-fin-doc.payer-code = buf_fin-schet.cli-code
                  .
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'payer-code-schet' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'payer-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'payer-type' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                end.
              end.
            end.
          END CASE.
          if v-skip = yes then do:
            v-mess = substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +
                              'счет ПЛАТЕЛЬЩИКА(ПОЛУЧАТЕЛЯ) НЕ ВЫБРАН для импорта - пропускаем'
                            , tt-1s-fin-doc.prn-doc-code
                            , p-host-code
                            , chr(10)
                            , tt-1s-fin-doc.payer-name
                            , tt-1s-fin-doc.receiver-name                                  ).
              delete tt-1s-fin-doc.
            return.
          end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'fin-ext-doc-type/' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'fin-doc-type' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'host-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
        end.
        when 'payer-inn/payer-name' then do:
          if tt-1s-fin-doc.payer-inn = ? then do:
            assign
            v-inn = index(temp_hfields.value_, ' ИНН ')
            .
            if v-inn = 0 then do:
              assign
              v-inn = index(temp_hfields.value_, 'ИНН ')
              .
            end.
            if v-inn <> 0 then do:
              assign
              v-dop = substring(temp_hfields.value_, v-inn + 1).
              _ii:
              do ii = 1 to num-entries(v-dop, chr(32) ):
                v-dop2 = substring(v-dop, length(entry(ii, v-dop, chr(32) ))  + 2).
                if entry(ii, v-dop, chr(32) ) <> '':U then do:
                  assign
                  tt-1s-fin-doc.payer-inn = entry(ii, v-dop, chr(32) )
                  tt-1s-fin-doc.payer-name = (if tt-1s-fin-doc.payer-name = '':U then trim(v-dop2) else tt-1s-fin-doc.payer-name)
                  .
                  leave _ii.
                end.
              end.
            end.
          end.
        end.
        when 'receiver-inn/receiver-name' then do:
          if tt-1s-fin-doc.receiver-inn = ? then do:
            assign
            v-inn = index(temp_hfields.value_, ' ИНН ')
            .
            if v-inn = 0 then do:
              assign
              v-inn = index(temp_hfields.value_, 'ИНН ')
              .
            end.
            if v-inn <> 0 then do:
              assign
              v-dop = substring(temp_hfields.value_, v-inn + 1).
              _ii:
              do ii = 1 to num-entries(v-dop, chr(32) ):
                v-dop2 = substring(v-dop, length(entry(ii, v-dop, chr(32) ))  + 2).
                if entry(ii, v-dop, chr(32) ) <> '':U then do:
                  assign
                  tt-1s-fin-doc.receiver-inn = entry(ii, v-dop, chr(32) )
                  tt-1s-fin-doc.receiver-name = (if tt-1s-fin-doc.receiver-name = '':U then trim(v-dop2) else tt-1s-fin-doc.receiver-name)
                  .
                  leave _ii.
                end.
              end.
            end.
          end.
        end.
        when 'naznach-plat/' then do:
          tt-1s-fin-doc.naznach-plat = temp_hfields.value_
          .
                find first buf_temp_hfields where buf_temp_hfields.subject = 'fin-doc':U                                                          and buf_temp_hfields.name_ = 'naznach-plat/' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
        end.
        otherwise do:
          error-status:error = no.
        end.
      END CASE.
    end.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Импорт БИК &1 Фирма &2: считано документов &3"
                                    , p-bik
                                    , p-host-code
                                    , p-count)).
    assign
    in-doc = 0
    exist  = yes
    .
  end.
end procedure.
procedure proc-end-statement:
define variable h-buffer as handle no-undo .
define variable h-field as handle no-undo .
define variable ii as integer no-undo .
define variable v-skip as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_clients for ub.clients.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_temp_hfields for temp_hfields.
define buffer find_first-fin-bank for ub.fin-bank.
  _main:
  do
  on error undo _main, return error
  :
    if in-statement = 0
    or exist-statement then return.
    assign
    in-statement = 0
    exist-statement  = yes
    .
    find first temp_hfields no-lock where
              temp_hfields.subject = 'fin-statement':U
          and temp_Hfields.name_ = 'start-date'
          AND temp_Hfields.readed = yes
              no-error.
    if not available temp_hfields then do:
                  run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Отсутствует обязательный реквизит выписки <ДатаНачала>&1Файл &2 строка НАЧАЛА ВЫПИСКИ &3"                             , chr(10)                                                                      , p-file-name                                                                        , var-file-line-num                                        )).
           p-view-log = yes.
           assign
           in-doc = 0
           exist = yes.
           return "error".
     end.
    find first temp_hfields no-lock where
              temp_hfields.subject = 'fin-statement':U
          and temp_Hfields.name_ = 'end-date'
          AND temp_Hfields.readed = yes
              no-error.
    if not available temp_hfields then do:
                  run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Отсутствует обязательный реквизит выписки <ДатаКонца>&1Файл &2 строка НАЧАЛА ВЫПИСКИ &3"                             , chr(10)                                                                      , p-file-name                                                                        , var-file-line-num                                        )).
           p-view-log = yes.
           assign
           in-doc = 0
           exist = yes.
           return "error".
     end.
     create tt-1s-fin-statement.
     assign
     tt-1s-fin-statement.sttm-code = v-seq-statement + 1
     v-seq-statement = v-seq-statement + 1
     .
     assign
     h-buffer = buffer tt-1s-fin-statement:handle
     .
     do ii = 1 to h-buffer:num-fields:
       assign
       h-field = h-buffer:buffer-field(ii)
       .
       find first temp_hfields no-lock where
                 temp_hfields.subject = 'fin-statement':U
             and temp_hfields.name_ = h-field:name
             AND temp_hfields.readed = yes  no-error.
       if available temp_hfields then do:
         CASE h-field:data-type:
           when 'date' then do:
              assign
              h-field:buffer-value = date(temp_hfields.value_)
              no-error .
           end.
           when 'integer' then do:
              assign
              h-field:buffer-value = integer(temp_hfields.value_)
              no-error .
           end.
          when 'decimal' then do:
              assign
              h-field:buffer-value = decimal(temp_hfields.value_)
              no-error .
           end.
           when 'logical' then do:
              assign
              h-field:buffer-value = logical(temp_hfields.value_)
              no-error .
           end.
           when 'character' then do:
             assign
             h-field:buffer-value = temp_hfields.value_
             .
           end.
           otherwise do:
             error-status:error = no.
           end.
         END CASE.
         if error-status:error then do:
                  run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Неверное значение поля &1: &5&2Файл &3 строка НАЧАЛА ВЫПИСКИ &4"                             , temp_hfields.label_                                                                , chr(10)                                                                      , p-file-name                                                                        , var-file-line-num                                                                  , temp_hfields.value_                      )).
           p-view-log = yes.
           delete tt-1s-fin-statement.
           assign
           in-doc = 0
           exist = yes.
           return "error".
         end.
         assign
         temp_Hfields.imported = yes.
      end.
    end.
    for each temp_hfields where
              temp_hfields.subject = 'fin-statement':U
          and temp_hfields.imported = no
          AND temp_hfields.readed = yes :
       CASE temp_hfields.name_ :
        when 'fins-ext-doc-type/' then do:
          for each find_first-fin-bank where
                  find_first-fin-bank.host-code = p-host-code
              AND find_first-fin-bank.bik       = p-bik
              AND find_first-fin-bank.status_   = 'тек':U,
              first buf_fin-schet no-lock where
                    buf_fin-schet.host-code = find_first-fin-bank.host-code
                and buf_fin-schet.code-bank = find_first-fin-bank.code-bank
                AND buf_fin-schet.r-schet =  tt-1s-fin-statement.r-schet
                and buf_fin-schet.status_ = 'тек':U
                and buf_fin-schet.cli-type = 'орг':U
                and buf_fin-schet.cli-code = find_first-fin-bank.host-code:
            LEAVE.
          end.
          if available buf_fin-schet then do:
            find first buf_clients no-lock where
                      buf_clients.obj-type = 'орг':U
                 and  buf_clients.obj-code = p-host-code.
            assign
            tt-1s-fin-statement.fins-ext-doc-type = 'стд':U
            tt-1s-fin-statement.fins-doc-type = 'стд':U
            tt-1s-fin-statement.host-code    = p-host-code
            tt-1s-fin-statement.code-schet = buf_fin-schet.code-schet
            tt-1s-fin-statement.c-schet = buf_fin-schet.c-schet
            tt-1s-fin-statement.cl-bank = '1s':U
            tt-1s-fin-statement.code-bank = buf_fin-schet.code-bank
            tt-1s-fin-statement.curr-code = buf_fin-schet.curr-code
            tt-1s-fin-statement.bank-name = find_first-fin-bank.bank-name
            tt-1s-fin-statement.bank-city = find_first-fin-bank.bank-city
            tt-1s-fin-statement.bik = find_first-fin-bank.bik
            tt-1s-fin-statement.status_ = 'новый':U
            tt-1s-fin-statement.cli-name = buf_clients.obj-name
            .
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'start-date' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'end-date' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'start-sum-doc' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'end-sum-doc' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'in-sum-doc' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'out-sum-doc' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'r-schet' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'code-schet' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'cli-name' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'bank-name' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'bank-city' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'code-bank' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'cl-bank' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'bik' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
            if p-rs-hsch = 2 then do:
              find first temp_hfin-schet no-lock where
                      temp_hfin-schet.host-code = tt-1s-fin-statement.host-code
                  AND temp_hfin-schet.code-schet = tt-1s-fin-statement.code-schet no-error .
              if not available temp_hfin-schet then do:
                assign
                v-skip = yes.
              end.
            end.
            if not v-skip then do:
              find first buf_Clients no-lock where
                        buf_clients.obj-type = 'орг':U
                    and buf_clients.obj-code = p-host-code no-error.
              if not available buf_clients then do:
                v-mess = substitute("!!!Не найден в БД ДЕРЖАТЕЛЬ СЧЕТА &1&2 - БИК &3&1Коррсчет &4"
                                    , tt-1s-fin-statement.r-schet
                                    , chr(10)
                                    , tt-1s-fin-statement.bik
                                    , tt-1s-fin-statement.c-schet
                                    ).
                undo _main, return error v-mess.
              end.
              assign
              tt-1s-fin-statement.cli-name = buf_clients.obj-name
              .
            end.
          end.
          else do:
            assign
            v-seq-statement = v-seq-statement + 1
            v-mess = substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5:&3"  +
                        'счет для ВЫПИСКИ отсутствует в БД'
                      , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)
                      , p-host-code
                      , chr(10)
                      , tt-1s-fin-statement.r-schet
                      , tt-1s-fin-statement.bik       ).
            assign
            v-crit-err = yes.
            undo _main, return error v-mess.
          end.
          if v-skip = yes then do:
            v-mess = substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5"  +
                              'счет НЕ ВЫБРАН для импорта - пропускаем'
                            , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)
                            , p-host-code
                            , chr(10)
                            , tt-1s-fin-statement.r-schet
                            , tt-1s-fin-statement.bik                                  ).
              delete tt-1s-fin-statement.
            return.
          end.
                find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'fins-ext-doc-type/' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'fins-doc-type' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
                find first buf_temp_hfields where  buf_temp_hfields.subject = 'fin-statement':U                                                      and buf_temp_hfields.name_ = 'host-code' no-error.                       if available buf_temp_hfields then do:                                                                    assign                                                                                             buf_temp_hfields.imported = yes.                                                                     end.
        end.
        otherwise do:
          error-status:error = no.
        end.
      END CASE.
    end.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Импорт БИК &1 Фирма &2: считано выписок &3"
                                    , p-bik
                                    , p-host-code
                                    , p-count-statement)).
    assign
    in-statement = 0
    exist-statement  = yes
    .
  end.
end procedure.
procedure proc-write-out :
define variable v-do as logical no-undo .
define variable h-buffer as handle no-undo .
define variable h-field as handle no-undo .
define variable h-1s-buffer as handle no-undo .
define variable h-1s-field as handle no-undo .
define variable v-date like ub.fin-doc.fact-date no-undo .
define variable v-result as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable v-create as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-do-bank as logical no-undo .
define variable v-do-fact as logical no-undo .
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_fin-statement for ub.fin-statement.
  _main:
  do  transaction
  on error undo, return error return-value
  :
    _tt-1s-fin-doc:
    for each tt-1s-fin-doc
    on error undo _main, return error
    :
      assign
      v-do = no
      v-create = no
      .
      find first buf_fin-doc where
                buf_fin-doc.prn-doc-code = tt-1s-fin-doc.prn-doc-code
            AND  buf_fin-doc.host-code = p-host-code
            AND  buf_fin-doc.doc-date = tt-1s-fin-doc.doc-date
            AND  buf_fin-doc.fin-ext-doc-type = tt-1s-fin-doc.fin-ext-doc-type
            AND  buf_fin-doc.payer-r-schet = tt-1s-fin-doc.payer-r-schet
            AND  buf_fin-doc.receiver-r-schet = tt-1s-fin-doc.receiver-r-schet no-error .
      v-do = no.
      if available buf_fin-doc then do:
        if buf_fin-doc.status_ = 'банк':U
        and tt-1s-fin-doc.fact-date <> ?
        then do:
          assign
          v-do = yes
          .
        end.
        else do:
            if tt-1s-fin-doc.fact-date = ? then do:
              assign
              v-do = no.
            end.
            else do:
                      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +                                'находится в статусе &6, закрыть на факт НЕВОЗМОЖНО'                                                 , tt-1s-fin-doc.prn-doc-code                                                             , p-host-code                                                                         , chr(10)                                                                       , buf_fin-doc.payer-name                                                              , buf_fin-doc.receiver-name                                                           , buf_fin-doc.status_)).
              p-view-log = yes.
              undo _main, return error .
            end.
        end.
      end.
      else do:
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +                                'отсутствует в БД&6'                                                 , tt-1s-fin-doc.prn-doc-code                                                             , p-host-code                                                                         , chr(10)                                                                       , tt-1s-fin-doc.payer-name                                                              , tt-1s-fin-doc.receiver-name                                                            , (if p-do-create then ' согласно настройкам он будет создан' else '')  )).
        if p-do-create then do:
           assign
           v-create = yes
           v-do = no
           .
        end.
        else do:
          NEXT _tt-1s-fin-doc.
        end.
      end.
      if v-do or v-create then do:
        create tt-th-fin-doc.
        assign
        tt-th-fin-doc.stat-pl = ''
        tt-th-fin-doc.ocher-pl = "6":U
        .
        assign
        h-buffer = buffer tt-th-Fin-doc:handle
        h-1s-buffer = buffer tt-1s-Fin-doc:handle
        .
        if not v-create then
        buffer-copy buf_fin-doc to tt-th-fin-doc.
        _tt:
        for each temp_hfields where
                temp_hfields.imported = yes
            and temp_hfields.subject = 'fin-doc':U:
          if tt-1s-fin-doc.fin-EXT-doc-type = 'ппп':U then do:
             if lookup(temp_hfields.name_ , 'stat-pl,f104,f105,f106,f107,f108,f109,f110':U) > 0
             then next _tt.
          end.
          if index(temp_hfields.name , chr(47)) > 0 then do:
            CASE temp_hfields.name:
              when 'payer-INN/payer-name':U
              then do:
                assign
                tt-th-fin-doc.payer-inn = tt-1s-fin-doc.payer-inn
                .
                next _tt.
              end.
              when 'receiver-INN/receiver-name':U
              then do:
                assign
                tt-th-fin-doc.receiver-inn = tt-1s-fin-doc.receiver-inn
                .
                next _tt.
              end.
              otherwise do:
                h-field = h-buffer:buffer-field(entry(1, temp_hfields.name_, chr(47))).
                h-1s-field = h-1s-buffer:buffer-field(entry(1, temp_hfields.name_, chr(47))).
              end.
            END CASE.
          end.
          else do:
            h-field = h-buffer:buffer-field(temp_hfields.name_).
            h-1s-field = h-1s-buffer:buffer-field(temp_hfields.name_).
            if h-field:name = 'fact-date' then NEXT _tt.
          end.
          assign
          h-field:buffer-value = h-1s-field:buffer-value
          .
        end.
        if not v-create then do:
          v-result = '':U.
          buffer-compare tt-th-fin-doc to buf_fin-doc
          save result in v-result.
          if v-result <> '':U then do:
            assign
            v-doc-rec = recid(buf_fin-doc).
              run ref/findoc0.p (
            input-output v-doc-rec
                  ,input ('ИЗМЕНЕНИЕ':U + chr(4) + 'cl-bank')
                  ,input yes
                  ,input tt-th-fin-doc.host-code            ,input tt-th-fin-doc.fin-doc-code         ,input tt-th-fin-doc.an-uchet-code        ,input tt-th-fin-doc.an-uchet-value       ,input tt-th-fin-doc.base-rate            ,input tt-th-fin-doc.base-scale           ,input tt-th-fin-doc.cel-nazn-code        ,input tt-th-fin-doc.cel-nazn-value       ,input tt-th-fin-doc.contract-code        ,input tt-th-fin-doc.contract-curr        ,input tt-th-fin-doc.contract-rate        ,input tt-th-fin-doc.contract-scale       ,input tt-th-fin-doc.cor-acc              ,input tt-th-fin-doc.cor-acc-value        ,input tt-th-fin-doc.cor-acc1             ,input tt-th-fin-doc.cor-acc1-value       ,input tt-th-fin-doc.curr-code            ,input tt-th-fin-doc.doc-date             ,input tt-th-fin-doc.shift-date           ,input tt-th-fin-doc.shift-num            ,input tt-th-fin-doc.shift-name           ,input tt-th-fin-doc.enclosure            ,input tt-th-fin-doc.exch-rate            ,input tt-th-fin-doc.exch-scale           ,input tt-th-fin-doc.f104                 ,input tt-th-fin-doc.f105                 ,input tt-th-fin-doc.f106                 ,input tt-th-fin-doc.f107                 ,input tt-th-fin-doc.f108                 ,input tt-th-fin-doc.f109                 ,input tt-th-fin-doc.f110                 ,input tt-th-fin-doc.f22                  ,input tt-th-fin-doc.f23                  ,input tt-th-fin-doc.fact-date            ,input tt-th-fin-doc.fin-doc-type         ,input tt-th-fin-doc.fin-ext-doc-type     ,input tt-th-fin-doc.in-doc-code          ,input tt-th-fin-doc.in-host-code         ,input tt-th-fin-doc.including            ,input tt-th-fin-doc.nazn-pl              ,input tt-th-fin-doc.naznach-plat         ,input tt-th-fin-doc.ocher-pl             ,input tt-th-fin-doc.out-doc-code         ,input tt-th-fin-doc.out-host-code        ,input tt-th-fin-doc.pay-date             ,input tt-th-fin-doc.payer-bank-name      ,input tt-th-fin-doc.payer-bank-city      ,input tt-th-fin-doc.payer-bik            ,input tt-th-fin-doc.payer-c-schet        ,input tt-th-fin-doc.payer-code           ,input tt-th-fin-doc.payer-code-schet     ,input tt-th-fin-doc.payer-dop1           ,input tt-th-fin-doc.payer-dop2           ,input tt-th-fin-doc.payer-inn            ,input tt-th-fin-doc.payer-kpp            ,input tt-th-fin-doc.payer-name           ,input tt-th-fin-doc.payer-okpo           ,input tt-th-fin-doc.payer-passport      ,input tt-th-fin-doc.payer-r-schet        ,input tt-th-fin-doc.payer-type           ,input tt-th-fin-doc.perm-date            ,input tt-th-fin-doc.prn-doc-code         ,input tt-th-fin-doc.PS                   ,input tt-th-fin-doc.receiver-bank-name   ,input tt-th-fin-doc.receiver-bank-city   ,input tt-th-fin-doc.receiver-bik         ,input tt-th-fin-doc.receiver-c-schet     ,input tt-th-fin-doc.receiver-code        ,input tt-th-fin-doc.receiver-code-schet  ,input tt-th-fin-doc.receiver-dop1        ,input tt-th-fin-doc.receiver-dop2        ,input tt-th-fin-doc.receiver-inn         ,input tt-th-fin-doc.receiver-kpp         ,input tt-th-fin-doc.receiver-name        ,input tt-th-fin-doc.receiver-okpo        ,input tt-th-fin-doc.receiver-passport    ,input tt-th-fin-doc.receiver-r-schet     ,input tt-th-fin-doc.receiver-type        ,input tt-th-fin-doc.srok-pl              ,input tt-th-fin-doc.stat-pl              ,input tt-th-fin-doc.str-podr-code        ,input tt-th-fin-doc.str-podr-type        ,input tt-th-fin-doc.str-podr-name        ,input tt-th-fin-doc.sum-base             ,input tt-th-fin-doc.sum-doc              ,input tt-th-fin-doc.sum-rubl             ,input tt-th-fin-doc.sum-contr            ,input tt-th-fin-doc.trn-doc-code         ,input tt-th-fin-doc.vid-opl              ,input tt-th-fin-doc.vid-plat
                  ,input tt-th-fin-doc.con-sum-rubl         ,input tt-th-fin-doc.con-sum-base         ,input tt-th-fin-doc.con-sum-doc          ,input tt-th-fin-doc.con-sum-contr        ,input tt-th-fin-doc.con-stat             ,input tt-th-fin-doc.payer-sign1                ,input tt-th-fin-doc.payer-sign2                ,input tt-th-fin-doc.payer-sign3                ,input tt-th-fin-doc.payer-sign4                ,input tt-th-fin-doc.receiver-sign1                ,input tt-th-fin-doc.receiver-sign2                ,input tt-th-fin-doc.receiver-sign3                ,input tt-th-fin-doc.receiver-sign4                ,input tt-th-fin-doc.obj-type                   ,input tt-th-fin-doc.obj-code                   ,input tt-th-fin-doc.doc-author                 ,input tt-th-fin-doc.fact-author                ,input tt-th-fin-doc.CashBookId
                  ,input table tt0-fin-doc-tax
                  ,input table tt0-fin-doc-attr
                  ,input no
                  ,input table tt0-payment
            ) no-error.
            if error-status:error then do:
              p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +                                  'ОШИБКА ПРИ ОБНОВЛЕНИИ ДОКУМЕНТА изменениями из системы КЛИЕНТ-БАНК&3:&6 &7'                                                   , tt-1s-fin-doc.prn-doc-code                                                               , p-host-code                                                                           , chr(10)                                                                         , tt-1s-fin-doc.payer-name                                                                , tt-1s-fin-doc.receiver-name                                                              , error-status:get-message(1)                                                             , return-value   )).
              undo _main, return error .
            end.
          end.
        end.
      end.
      if v-create then do:
        run proc-create-fin-doc in this-procedure ( buffer tt-th-fin-doc
                                                   ,buffer tt-1s-fin-doc
                                                   ) no-error .
        if error-status:error then do:
          p-view-log = yes.
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +                                'ОШИБКА ПРИ  СОЗДАНИИ ДОКУМЕНТА:&3&6 &7'                                                 , tt-1s-fin-doc.prn-doc-code                                                             , p-host-code                                                                         , chr(10)                                                                       , tt-1s-fin-doc.payer-name                                                              , tt-1s-fin-doc.receiver-name                                                            , error-status:get-message(1)                                                           , return-value   )).
          undo _main, return error .
        end.
      end.
      if v-do then do:
        assign
        v-date = tt-1s-fin-doc.fact-date
        .
        run trg/findstat.p (
                         input parparentproc
                        ,input buf_fin-doc.host-code
                        ,input buf_fin-doc.fin-doc-code
                        ,input '<закрытие документа>':U
                        ,input 'cl-bank'
                        ,input 'факт':U
                        ,input-output v-date
                        ,input yes
                                      ) no-error .
        if error-status:error then do:
              run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +                                  'ОШИБКА ПРИ ЗАКРЫТИИ ДОКУМЕНТА НА ФАКТ:&3&6&3&7'                                                   , tt-1s-fin-doc.prn-doc-code                                                               , p-host-code                                                                           , chr(10)                                                                         , tt-1s-fin-doc.payer-name                                                                , tt-1s-fin-doc.receiver-name                                                              , error-status:get-message(1)                                                             , return-value   )).
            undo _main, return error .
        end.
        assign
        tt-1s-fin-doc.status_ = 'факт':U
        tt-th-fin-doc.status_ = 'факт':U
        .
      end.
      if available buf_fin-doc then do:
        tt-1s-fin-doc.fin-doc-code-th = buf_fin-doc.fin-doc-code.
      end.
      assign
      p-processed = p-processed + 1
      .
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Импорт: БИК &1 Фирма &2: ОБРАБОТАНО документов &3"
                                      , p-bik
                                      , p-host-code
                                      , p-processed)).
    end.
    _tt-1s-fin-statement:
    for each tt-1s-fin-statement
    on error undo _main, return error
    :
      assign
      v-do = no
      v-create = no
      .
      find first buf_fin-statement where
                 buf_fin-statement.host-code = p-host-code
            AND  buf_fin-statement.start-date = tt-1s-fin-statement.start-date
            AND  buf_fin-statement.end-date = tt-1s-fin-statement.end-date
            AND  buf_fin-statement.fins-ext-doc-type = tt-1s-fin-statement.fins-ext-doc-type
            AND  buf_fin-statement.code-bank = tt-1s-fin-statement.code-bank
            AND  buf_fin-statement.code-schet = tt-1s-fin-statement.code-schet
            no-error .
      assign
      v-do-bank = no
      v-do-fact = no
      .
      if available buf_fin-statement then do:
        v-doc-rec = recid(buf_fin-statement).
        if buf_fin-statement.status_ = 'банк':U
        then do:
          assign
          v-do-fact = yes
          .
        end.
        else do:
          if buf_fin-statement.status_ = 'новый':U and tt-1s-fin-statement.bank-date <> ? then do:
            assign
            v-do-bank = yes.
          end.
          else do:
                          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5&3"  +                                      'находится в статусе &6, закрыть на банк НЕВОЗМОЖНО'                                , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)                               , p-host-code                                                                         , chr(10)                                                                       , buf_fin-statement.r-schet                                                           , buf_fin-statement.bik                                                               , buf_fin-statement.status_)).
              p-view-log = yes.
              undo _main, return error .
          end.
        end.
      end.
      else do:
        assign
        v-create = yes
        v-do-fact = yes
        v-do-bank = yes
        .
      end.
      if not v-create then do:
        run proc-insert-statement-lines in this-procedure ( (buffer buf_Fin-statement:handle) ).
        buffer-copy buf_fin-statement to tt-th-fin-statement.
      end.
      if v-do-bank or v-do-fact or v-create then do:
        create tt-th-fin-statement.
        assign
        h-buffer = buffer tt-th-fin-statement:handle
        h-1s-buffer = buffer tt-1s-fin-statement:handle
        .
        _tt:
        for each temp_hfields where
                temp_hfields.imported = yes
            and temp_hfields.subject = 'fin-statement':U:
          if temp_hfields.name_ = 'fins-ext-doc-type/' then NEXT _tt.
          h-field = h-buffer:buffer-field(temp_hfields.name_).
          if h-field:name = 'fact-date' then NEXT _tt.
          if h-field:name = 'bank-date' then NEXT _tt.
          h-1s-field = h-1s-buffer:buffer-field(temp_hfields.name_).
          assign
          h-field:buffer-value = h-1s-field:buffer-value
          .
        end.
        if not v-create then do:
          v-result = ''.
          buffer-compare tt-th-fin-statement
          using num-docs start-sum-doc end-sum-doc in-sum-doc out-sum-doc
          to buf_fin-statement
          save result in v-result.
          if v-result <> '':U then do:
            assign
            v-doc-rec = recid(buf_fin-statement).
              define variable v-lines-exist as logical no-undo .
            run ref/finsttm0.p
                            (input yes
                            ,input-output v-doc-rec
                            ,input       ('ИЗМЕНЕНИЕ':U + chr(4) + 'cl-bank')
                            ,input '1s':U
                            ,input tt-th-fin-statement.host-code            ,input tt-th-fin-statement.sttm-code            ,input tt-th-fin-statement.curr-code            ,input tt-th-fin-statement.doc-date             ,input tt-th-fin-statement.bank-date            ,input tt-th-fin-statement.fact-date            ,input tt-th-fin-statement.fins-doc-type        ,input tt-th-fin-statement.fins-ext-doc-type    ,input tt-th-fin-statement.code-bank            ,input tt-th-fin-statement.bank-name            ,input tt-th-fin-statement.bank-city            ,input tt-th-fin-statement.bik                  ,input tt-th-fin-statement.code-schet           ,input tt-th-fin-statement.r-schet              ,input tt-th-fin-statement.c-schet              ,input tt-th-fin-statement.cli-name             ,input tt-th-fin-statement.prn-doc-code         ,input tt-th-fin-statement.PS                   ,input tt-th-fin-statement.sum-doc              ,input tt-th-fin-statement.start-sum-doc-th     ,input tt-th-fin-statement.start-sum-doc        ,input tt-th-fin-statement.in-sum-doc           ,input tt-th-fin-statement.out-sum-doc          ,input tt-th-fin-statement.end-sum-doc          ,input tt-th-fin-statement.num-docs             ,input tt-th-fin-statement.start-date           ,input tt-th-fin-statement.end-date
                            ,input 'новый':U
                            ,input v-lines-exist
                            ) no-error .
            if error-status:error then do:
              p-view-log = yes.
                run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Выписка &1 фирма &2&3Счет &4 БИК &5&3"  +                                  'ОШИБКА ПРИ ОБНОВЛЕНИИ выписки изменениями из системы КЛИЕНТ-БАНК&3:&6 &7'                               , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)                               , p-host-code                                                                           , chr(10)                                                                         , tt-1s-fin-statement.r-schet                                                                , tt-1s-fin-statement.bik                                                              , error-status:get-message(1)                                                             , return-value   )).
              undo _main, return error .
            end.
          end.
        end.
      end.
      if v-create then do:
        run proc-create-fin-statement in this-procedure ( buffer tt-th-fin-statement) no-error .
        if error-status:error then do:
          p-view-log = yes.
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Выписка &1 фирма &2&3Счета &4 БИК &5&3"  +                                'ОШИБКА ПРИ  СОЗДАНИИ ВЫПИСКИ:&3&6 &7'                                                 , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)                             , p-host-code                                                                          , chr(10)                                                                        , tt-1s-fin-statement.r-schet                                                          , tt-1s-fin-statement.BIK                                                              , error-status:get-message(1)                                                           , return-value   )).
          undo _main, return error .
        end.
        find first buf_Fin-statement no-lock where
                  buf_fin-statement.host-code = p-host-code
              and buf_fin-statement.sttm-code = tt-th-fin-statement.sttm-code.
        run proc-insert-statement-lines in this-procedure ( (buffer buf_Fin-statement:handle) ).
      end.
      if buf_fin-statement.num-docs = buf_fin-statement.num-docs-th
      and buf_fin-statement.start-sum-doc = buf_fin-statement.start-sum-doc-th
      and buf_fin-statement.end-sum-doc = buf_fin-statement.end-sum-doc-th
      and buf_fin-statement.in-sum-doc = buf_fin-statement.in-sum-doc-th
      and buf_fin-statement.out-sum-doc = buf_fin-statement.out-sum-doc-th
      and buf_fin-statement.sum-doc = buf_fin-statement.sum-doc-th then do:
        if buf_fin-statement.status_ = 'новый':U then do:
          run trg/finsstat.p (
                          input buf_fin-statement.host-code
                          ,input buf_fin-statement.sttm-code
                          ,input '<закрытие документа>':U
                          ,input '1s':U
                          ,input 'банк':U
                          ,input-output tt-1s-fin-statement.bank-date
                          ,input yes
                                        ) no-error .
          if error-status:error then do:
                  run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Выписка &1 фирма &2&3Счета &4 БИК &5&3"  +                                    'ОШИБКА ПРИ ЗАКРЫТИИ ВЫПИСКИ НА БАНК&3:&6 &7'                                    , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)                                 , p-host-code                                                                      , chr(10)                                                                    , tt-1s-fin-statement.r-schet                                                      , tt-1s-fin-statement.bik                                                          , error-status:get-message(1)                                                      , return-value   )).
              undo _main, return error .
          end.
        end.
        if buf_fin-statement.status_ = 'банк':U then do:
          run cur-time in this-procedure(output v-today, output v-time).
          assign
          v-date = v-today
          .
          run trg/finsstat.p (
                          input buf_fin-statement.host-code
                          ,input buf_fin-statement.sttm-code
                          ,input '<закрытие документа>':U
                          ,input '1s':U
                          ,input 'факт':U
                          ,input-output v-date
                          ,input yes
                                        ) no-error .
          if error-status:error then do:
                  run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Выписка &1 фирма &2&3Счета &4 БИК &5&3"  +                                    'ОШИБКА ПРИ ЗАКРЫТИИ ВЫПИСКИ НА ФАКТ&3:&6 &7'                                    , cbnki-period-to-String(tt-1s-fin-statement.start-date, tt-1s-fin-statement.end-date)                                 , p-host-code                                                                      , chr(10)                                                                    , tt-1s-fin-statement.r-schet                                                      , tt-1s-fin-statement.bik                                                          , error-status:get-message(1)                                                      , return-value   )).
              undo _main, return error .
          end.
        end.
      end.
      assign
      p-processed-statement = p-processed-statement + 1
      .
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Импорт: БИК &1 Фирма &2: ОБРАБОТАНО выписок &3"
                                      , p-bik
                                      , p-host-code
                                      , p-processed-statement)).
    end.
  end.
end procedure.
procedure proc-create-fin-doc :
define parameter buffer buf_tt-th-fin-doc for tt-th-fin-doc.
define parameter buffer buf_tt-1s-fin-doc for tt-1s-fin-doc.
define variable v-doc-rec as recid no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo.
define variable v-contract-rate like ub.fin-doc.exch-rate no-undo.
define variable v-contract-scale like ub.fin-doc.exch-scale no-undo.
define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-mess as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-fd-code as integer no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_firm for ub.firm.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_fin-doc for ub.fin-doc.
define buffer receiver-firm for ub.firm.
define buffer receiver-person for ub.person.
define buffer payer-firm for ub.firm.
define buffer payer-person for ub.person.
  do
  on error undo, return error
  :
    run gen-b-code in this-procedure ( input 'fdgb':U
                                     , output v-fd-code) no-error .
    if error-status:error then do:
      undo, return error substitute("Ошибка при генерации внутреннего номера фин. док-та:&1&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value ).
    end.
    assign
    buf_tt-th-fin-doc.contract-curr = 0
    buf_tt-th-fin-doc.base-rate = 1
    buf_tt-th-fin-doc.base-scale = 1
    buf_tt-th-fin-doc.exch-rate = 1
    buf_tt-th-fin-doc.exch-scale = 1
    buf_tt-th-fin-doc.contract-rate = 1
    buf_tt-th-fin-doc.contract-scale = 1
    buf_tt-th-fin-doc.obj-type      = '':U
    buf_tt-th-fin-doc.obj-code      = 0
    buf_tt-th-fin-doc.contract-code = 0
    buf_tt-th-fin-doc.fin-doc-code  = v-fd-code
    buf_tt-th-fin-doc.status_       = 'новый':U
    buf_tt-th-fin-doc.user-db-num-doc = g#db-num
    buf_tt-th-fin-doc.user-name-doc = g#userid
    buf_tt-th-fin-doc.doc-author    = '1s':U
    .
    CASE buf_tt-th-fin-doc.fin-ext-doc-type:
      when 'рпп':U then do:
        find first buf_sysconf where
                  buf_sysconf.host-code = buf_tt-th-fin-doc.payer-code.
        v-base-code = buf_sysconf.base-code.
        find first buf_firm where
                  buf_firm.firm-code = buf_tt-th-fin-doc.payer-code
        .
        assign
        buf_tt-th-fin-doc.payer-sign1  = buf_firm.director
        buf_tt-th-fin-doc.payer-sign2  = buf_sysconf.snr-accnt
        buf_tt-th-fin-doc.host-code    = buf_tt-th-fin-doc.payer-code
        .
        if buf_tt-th-fin-doc.payer-code <> p-host-code then do:
          undo, return error substitute("!!!В файле для фирмы &1 обнаружена платежка фирмы &2"
                                        ,p-host-code
                                        ,buf_tt-th-fin-doc.payer-code).
        end.
        find first buf_fin-bank no-lock where
                  buf_Fin-bank.host-code = buf_tt-th-fin-doc.host-code
              AND buf_Fin-bank.bik = buf_tt-th-fin-doc.receiver-bik
              AND buf_Fin-bank.cor-acc = buf_tt-th-fin-doc.receiver-c-schet no-error.
        if not available buf_fin-bank then do:
          assign
          v-mess = substitute("!!!Не найден в БД (или удален) банк ПОЛУЧАТЕЛЯ&1 - БИК &2&1Коррсчет &3"
                              , chr(10)
                              , buf_tt-th-fin-doc.receiver-bik
                              , buf_tt-th-fin-doc.receiver-c-schet
                              ).
          undo, return error v-mess.
        end.
        if buf_fin-bank.status_ <> 'тек':U then do:
          undo, return error substitute("!!!банк ПОЛУЧАТЕЛЯ БИК &1 имеет статус", buf_fin-bank.status_).
        end.
        for each buf_fin-schet no-lock where
                buf_fin-schet.host-code = buf_tt-th-fin-doc.host-code
            AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
            AND buf_fin-schet.r-schet =  buf_tt-th-fin-doc.receiver-r-schet
            AND buf_fin-schet.status_ =  'тек':U :
          if buf_fin-schet.cli-type = 'орг':U then do:
            find first receiver-firm no-lock where
                    receiver-firm.firm-code = buf_fin-schet.cli-code
                and receiver-firm.inn = tt-1s-fin-doc.receiver-inn no-error.
            if available receiver-firm then leave.
          end.
          if buf_fin-schet.cli-type = 'чел':U then do:
            find first receiver-person no-lock where
                    receiver-person.psn-code = buf_fin-schet.cli-code
                and receiver-person.inn = tt-1s-fin-doc.receiver-inn no-error.
            if available receiver-person then leave.
          end.
        end.
        if not available buf_fin-schet then do:
          assign
          v-mess =  substitute("!!!Не найден в БД (или удален) счет ПОЛУЧАТЕЛЯ&1 банк с БИК &2 (вн код &3),&1р/с &4, ИНН &5"
                    , chr(10)
                    , buf_tt-th-fin-doc.receiver-bik
                    , buf_fin-bank.code-bank
                    , buf_tt-th-fin-doc.receiver-r-schet
                    , buf_tt-th-fin-doc.receiver-inn
                    ).
          undo, return error v-mess.
        end.
        assign
        buf_tt-th-fin-doc.receiver-code-schet = buf_fin-schet.code-schet
        buf_tt-th-fin-doc.receiver-c-schet = buf_fin-schet.c-schet
        buf_tt-th-fin-doc.receiver-type = buf_fin-schet.cli-type
        buf_tt-th-fin-doc.receiver-code = buf_fin-schet.cli-code
        buf_tt-th-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-out
        buf_tt-th-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-out
        buf_tt-th-fin-doc.cor-acc       = buf_sysconf.cor-acc-out
        .
      end.
      when 'ппп':U then do:
        find first buf_sysconf where
                  buf_sysconf.host-code = buf_tt-th-fin-doc.receiver-code.
        v-base-code = buf_sysconf.base-code.
        buf_tt-th-fin-doc.host-code     = buf_tt-th-fin-doc.receiver-code.
        if buf_tt-th-fin-doc.receiver-code <> p-host-code then do:
          undo, return error substitute("!!!В файле для фирмы &1 обнаружена платежка фирмы &2"
                                        ,p-host-code
                                        ,buf_tt-th-fin-doc.receiver-code).
        end.
        find first buf_fin-bank no-lock where
                  buf_Fin-bank.host-code = buf_tt-th-fin-doc.host-code
              AND buf_Fin-bank.bik = buf_tt-th-fin-doc.payer-bik
              AND buf_Fin-bank.cor-acc = buf_tt-th-fin-doc.payer-c-schet  no-error.
        if not available buf_fin-bank then do:
          assign
          v-mess = substitute("!!!Не найден в БД (или удален) банк ПЛАТЕЛЬЩИКА&1 - БИК &2&1Коррсчет &3"
                              , chr(10)
                              , buf_tt-th-fin-doc.payer-bik
                              , buf_tt-th-fin-doc.payer-c-schet
                              ).
          undo, return error v-mess.
        end.
        if buf_fin-bank.status_ <> 'тек':U then do:
          undo, return error substitute("!!!банк ПЛАТЕЛЬЩИКА БИК &1 имеет статус", buf_fin-bank.status_).
        end.
        for each buf_fin-schet no-lock where
                buf_fin-schet.host-code = buf_tt-th-fin-doc.host-code
            AND buf_fin-schet.code-bank =  buf_fin-bank.code-bank
            AND buf_fin-schet.r-schet =  buf_tt-th-fin-doc.payer-r-schet
            AND buf_fin-schet.status_ = 'тек':U :
          if buf_fin-schet.cli-type = 'орг':U then do:
            find first payer-firm no-lock where
                    payer-firm.firm-code = buf_fin-schet.cli-code
                and payer-firm.inn = tt-1s-fin-doc.payer-inn no-error.
            if available payer-firm then leave.
          end.
          if buf_fin-schet.cli-type = 'чел':U then do:
            find first payer-person no-lock where
                    payer-person.psn-code = buf_fin-schet.cli-code
                and payer-person.inn = tt-1s-fin-doc.payer-inn no-error.
            if available payer-person then leave.
          end.
        end.
        if not available buf_fin-schet then do:
          assign
          v-mess =  substitute("!!!Не найден в БД (или удален) счет ПЛАТЕЛЬЩИКА&1 банк с БИК &2 (вн код &3),&1р/с &4, ИНН &5"
                    , chr(10)
                    , buf_tt-th-fin-doc.payer-bik
                    , buf_fin-bank.code-bank
                    , buf_tt-th-fin-doc.payer-r-schet
                    , buf_tt-th-fin-doc.payer-inn
                    ).
          undo, return error v-mess.
        end.
        assign
        buf_tt-th-fin-doc.payer-code-schet = buf_fin-schet.code-schet
        buf_tt-th-fin-doc.payer-c-schet = buf_fin-schet.c-schet
        buf_tt-th-fin-doc.payer-type = buf_fin-schet.cli-type
        buf_tt-th-fin-doc.payer-code = buf_fin-schet.cli-code
        buf_tt-th-fin-doc.cel-nazn-code = buf_sysconf.cel-nazn-code-in
        buf_tt-th-fin-doc.an-uchet-code = buf_sysconf.an-uchet-code-in
        buf_tt-th-fin-doc.cor-acc       = buf_sysconf.cor-acc-in
        .
      end.
    END CASE.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  buf_tt-th-fin-doc.host-code
  ,input  buf_tt-th-fin-doc.doc-date
  ,output buf_tt-th-fin-doc.base-rate
  ,output buf_tt-th-fin-doc.base-scale
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_tt-th-fin-doc.curr-code
  ,input  buf_tt-th-fin-doc.doc-date
  ,output buf_tt-th-fin-doc.exch-rate
  ,output buf_tt-th-fin-doc.exch-scale
  ,output v-curr-abbr
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_tt-th-fin-doc.contract-curr
  ,input  buf_tt-th-fin-doc.doc-date
  ,output buf_tt-th-fin-doc.contract-rate
  ,output buf_tt-th-fin-doc.contract-scale
  ,output v-curr-abbr
  )  .
    CASE buf_tt-th-fin-doc.curr-code:
      when 0 then do:
        assign
        buf_tt-th-fin-doc.sum-rubl = buf_tt-th-fin-doc.sum-doc
        buf_tt-th-fin-doc.sum-base = buf_tt-th-fin-doc.sum-doc / buf_tt-th-fin-doc.base-rate * buf_tt-th-fin-doc.base-scale
        buf_tt-th-fin-doc.sum-contr = (if buf_tt-th-fin-doc.contract-curr = 0                                                       then buf_tt-th-fin-doc.sum-rubl                                                       else buf_tt-th-fin-doc.sum-rubl / (buf_tt-th-fin-doc.contract-rate / buf_tt-th-fin-doc.contract-scale)                                                     )
        .
      end.
      when v-base-code then do:
        assign
        buf_tt-th-fin-doc.sum-rubl = buf_tt-th-fin-doc.sum-doc * buf_tt-th-fin-doc.exch-rate / buf_tt-th-fin-doc.exch-scale
        buf_tt-th-fin-doc.sum-base = buf_tt-th-fin-doc.sum-rubl / buf_tt-th-fin-doc.base-rate * buf_tt-th-fin-doc.base-scale
        buf_tt-th-fin-doc.sum-contr = (if buf_tt-th-fin-doc.contract-curr = 0                                                       then buf_tt-th-fin-doc.sum-rubl                                                       else buf_tt-th-fin-doc.sum-rubl / (buf_tt-th-fin-doc.contract-rate / buf_tt-th-fin-doc.contract-scale)                                                     )
        .
      end.
      otherwise do:
        assign
        buf_tt-th-fin-doc.sum-rubl = buf_tt-th-fin-doc.sum-doc * buf_tt-th-fin-doc.exch-rate / buf_tt-th-fin-doc.exch-scale
        buf_tt-th-fin-doc.sum-base = buf_tt-th-fin-doc.sum-rubl / buf_tt-th-fin-doc.base-rate * buf_tt-th-fin-doc.base-scale
        buf_tt-th-fin-doc.sum-contr = (if buf_tt-th-fin-doc.contract-curr = 0                                                       then buf_tt-th-fin-doc.sum-rubl                                                       else buf_tt-th-fin-doc.sum-rubl / (buf_tt-th-fin-doc.contract-rate / buf_tt-th-fin-doc.contract-scale)                                                     )
        .
      end.
    END CASE.
    if buf_tt-th-fin-doc.cor-acc <> 0 then do:
      find first buf_fin-code-cor-acc no-lock where
                buf_fin-code-cor-acc.host-code = p-host-code
            AND buf_fin-code-cor-acc.fin-code = buf_tt-th-fin-doc.cor-acc .
      assign
      buf_tt-th-fin-doc.cor-acc-value = buf_fin-code-cor-acc.code-value
      .
    end.
    if buf_tt-th-fin-doc.cor-acc1 <> 0 then do:
      find first buf_fin-code-cor-acc no-lock where
                buf_fin-code-cor-acc.host-code = p-host-code
            AND buf_fin-code-cor-acc.fin-code = buf_tt-th-fin-doc.cor-acc1.
      assign
      buf_tt-th-fin-doc.cor-acc1-value = buf_fin-code-cor-acc.code-value
      .
    end.
    if buf_tt-th-fin-doc.AN-UCHET-CODE <> 0 then do:
      find first buf_fin-code-AN-UCHET no-lock where
                buf_fin-code-an-uchet.host-code = p-host-code
            AND buf_fin-code-an-uchet.fin-code = buf_tt-th-fin-doc.an-uchet-code.
      assign
      buf_tt-th-fin-doc.an-uchet-value = buf_fin-code-an-uchet.code-value
      .
    end.
    if buf_tt-th-fin-doc.cel-nazn-code <> 0 then do:
        find first buf_fin-code-cel-nazn no-lock where
                  buf_fin-code-cel-nazn.host-code = p-host-code
              AND buf_fin-code-cel-nazn.fin-code = buf_tt-th-fin-doc.cel-nazn-code.
       assign
       buf_tt-th-fin-doc.cel-nazn-value = buf_fin-code-cel-nazn.code-value
       .
    end.
    run proc-create-default-tax  in this-procedure (buffer buf_tt-th-fin-doc).
    assign
    v-doc-rec = ?.
    run ref/findoc0.p (
    input-output v-doc-rec
          ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'cl-bank')
          ,input yes
          ,input buf_tt-th-fin-doc.host-code            ,input buf_tt-th-fin-doc.fin-doc-code         ,input buf_tt-th-fin-doc.an-uchet-code        ,input buf_tt-th-fin-doc.an-uchet-value       ,input buf_tt-th-fin-doc.base-rate            ,input buf_tt-th-fin-doc.base-scale           ,input buf_tt-th-fin-doc.cel-nazn-code        ,input buf_tt-th-fin-doc.cel-nazn-value       ,input buf_tt-th-fin-doc.contract-code        ,input buf_tt-th-fin-doc.contract-curr        ,input buf_tt-th-fin-doc.contract-rate        ,input buf_tt-th-fin-doc.contract-scale       ,input buf_tt-th-fin-doc.cor-acc              ,input buf_tt-th-fin-doc.cor-acc-value        ,input buf_tt-th-fin-doc.cor-acc1             ,input buf_tt-th-fin-doc.cor-acc1-value       ,input buf_tt-th-fin-doc.curr-code            ,input buf_tt-th-fin-doc.doc-date             ,input buf_tt-th-fin-doc.shift-date           ,input buf_tt-th-fin-doc.shift-num            ,input buf_tt-th-fin-doc.shift-name           ,input buf_tt-th-fin-doc.enclosure            ,input buf_tt-th-fin-doc.exch-rate            ,input buf_tt-th-fin-doc.exch-scale           ,input buf_tt-th-fin-doc.f104                 ,input buf_tt-th-fin-doc.f105                 ,input buf_tt-th-fin-doc.f106                 ,input buf_tt-th-fin-doc.f107                 ,input buf_tt-th-fin-doc.f108                 ,input buf_tt-th-fin-doc.f109                 ,input buf_tt-th-fin-doc.f110                 ,input buf_tt-th-fin-doc.f22                  ,input buf_tt-th-fin-doc.f23                  ,input buf_tt-th-fin-doc.fact-date            ,input buf_tt-th-fin-doc.fin-doc-type         ,input buf_tt-th-fin-doc.fin-ext-doc-type     ,input buf_tt-th-fin-doc.in-doc-code          ,input buf_tt-th-fin-doc.in-host-code         ,input buf_tt-th-fin-doc.including            ,input buf_tt-th-fin-doc.nazn-pl              ,input buf_tt-th-fin-doc.naznach-plat         ,input buf_tt-th-fin-doc.ocher-pl             ,input buf_tt-th-fin-doc.out-doc-code         ,input buf_tt-th-fin-doc.out-host-code        ,input buf_tt-th-fin-doc.pay-date             ,input buf_tt-th-fin-doc.payer-bank-name      ,input buf_tt-th-fin-doc.payer-bank-city      ,input buf_tt-th-fin-doc.payer-bik            ,input buf_tt-th-fin-doc.payer-c-schet        ,input buf_tt-th-fin-doc.payer-code           ,input buf_tt-th-fin-doc.payer-code-schet     ,input buf_tt-th-fin-doc.payer-dop1           ,input buf_tt-th-fin-doc.payer-dop2           ,input buf_tt-th-fin-doc.payer-inn            ,input buf_tt-th-fin-doc.payer-kpp            ,input buf_tt-th-fin-doc.payer-name           ,input buf_tt-th-fin-doc.payer-okpo           ,input buf_tt-th-fin-doc.payer-passport      ,input buf_tt-th-fin-doc.payer-r-schet        ,input buf_tt-th-fin-doc.payer-type           ,input buf_tt-th-fin-doc.perm-date            ,input buf_tt-th-fin-doc.prn-doc-code         ,input buf_tt-th-fin-doc.PS                   ,input buf_tt-th-fin-doc.receiver-bank-name   ,input buf_tt-th-fin-doc.receiver-bank-city   ,input buf_tt-th-fin-doc.receiver-bik         ,input buf_tt-th-fin-doc.receiver-c-schet     ,input buf_tt-th-fin-doc.receiver-code        ,input buf_tt-th-fin-doc.receiver-code-schet  ,input buf_tt-th-fin-doc.receiver-dop1        ,input buf_tt-th-fin-doc.receiver-dop2        ,input buf_tt-th-fin-doc.receiver-inn         ,input buf_tt-th-fin-doc.receiver-kpp         ,input buf_tt-th-fin-doc.receiver-name        ,input buf_tt-th-fin-doc.receiver-okpo        ,input buf_tt-th-fin-doc.receiver-passport    ,input buf_tt-th-fin-doc.receiver-r-schet     ,input buf_tt-th-fin-doc.receiver-type        ,input buf_tt-th-fin-doc.srok-pl              ,input buf_tt-th-fin-doc.stat-pl              ,input buf_tt-th-fin-doc.str-podr-code        ,input buf_tt-th-fin-doc.str-podr-type        ,input buf_tt-th-fin-doc.str-podr-name        ,input buf_tt-th-fin-doc.sum-base             ,input buf_tt-th-fin-doc.sum-doc              ,input buf_tt-th-fin-doc.sum-rubl             ,input buf_tt-th-fin-doc.sum-contr            ,input buf_tt-th-fin-doc.trn-doc-code         ,input buf_tt-th-fin-doc.vid-opl              ,input buf_tt-th-fin-doc.vid-plat
          ,input buf_tt-th-fin-doc.con-sum-rubl         ,input buf_tt-th-fin-doc.con-sum-base         ,input buf_tt-th-fin-doc.con-sum-doc          ,input buf_tt-th-fin-doc.con-sum-contr        ,input buf_tt-th-fin-doc.con-stat             ,input buf_tt-th-fin-doc.payer-sign1                ,input buf_tt-th-fin-doc.payer-sign2                ,input buf_tt-th-fin-doc.payer-sign3                ,input buf_tt-th-fin-doc.payer-sign4                ,input buf_tt-th-fin-doc.receiver-sign1                ,input buf_tt-th-fin-doc.receiver-sign2                ,input buf_tt-th-fin-doc.receiver-sign3                ,input buf_tt-th-fin-doc.receiver-sign4                ,input buf_tt-th-fin-doc.obj-type                   ,input buf_tt-th-fin-doc.obj-code                   ,input buf_tt-th-fin-doc.doc-author                 ,input buf_tt-th-fin-doc.fact-author                ,input buf_tt-th-fin-doc.CashBookId
          ,input table tt0-fin-doc-tax
          ,input table tt0-fin-doc-attr
          ,input no
          ,input table tt0-payment
    ) no-error.
    if error-status:error then do:
      undo, return error return-value .
    end.
    else do:
      find first buf_fin-doc no-lock where recid(buf_fin-doc) = v-doc-rec.
      assign
      buf_tt-1s-fin-doc.fin-doc-code-th = buf_fin-doc.fin-doc-code.
      assign
      p-created = p-created + 1
      .
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    run trg/findstat.p (
                     input parparentproc
                    ,input buf_fin-doc.host-code
                    ,input buf_fin-doc.fin-doc-code
                    ,input '<закрытие документа>':U
                    ,input 'cl-bank'
                    ,input 'разрешен':U
                    ,input-output v-today
                    ,input yes
                                  ) no-error .
    if error-status:error then do:
        run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +                              'ОШИБКА ПРИ ЗАКРЫТИИ СОЗДАННОГО ДОКУМЕНТА ДО СТАТУСА РАЗРЕШЕН:&3&6&3&7'                                               , buf_tt-1s-fin-doc.prn-doc-code                                                           , p-host-code                                                                       , chr(10)                                                                     , buf_tt-1s-fin-doc.payer-name                                                            , buf_tt-1s-fin-doc.receiver-name                                                          , error-status:get-message(1)                                                         , return-value   )).
        undo, return error .
    end.
    assign
    buf_tt-1s-fin-doc.status_ = 'разрешен':U
    buf_tt-1s-fin-doc.perm-date = v-today
    buf_tt-th-fin-doc.status_ = 'разрешен':U
    buf_tt-th-fin-doc.perm-date = v-today
    .
    run cur-time in this-procedure(output v-today, output v-time).
    run trg/findstat.p (
                     input parparentproc
                    ,input buf_fin-doc.host-code
                    ,input buf_fin-doc.fin-doc-code
                    ,input '<закрытие документа>':U
                    ,input 'cl-bank'
                    ,input 'банк':U
                    ,input-output v-today
                    ,input yes
                                  ) no-error .
    if error-status:error then do:
        run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Документ &1 фирма &2&3Плательщик &4&3Получатель &5&3"  +                              'ОШИБКА ПРИ ЗАКРЫТИИ СОЗДАННОГО ДОКУМЕНТА ДО СТАТУСА БАНК:&3&6&3&7'                                               , buf_tt-1s-fin-doc.prn-doc-code                                                           , p-host-code                                                                       , chr(10)                                                                     , buf_tt-1s-fin-doc.payer-name                                                            , buf_tt-1s-fin-doc.receiver-name                                                          , error-status:get-message(1)                                                         , return-value   )).
        undo, return error .
    end.
    assign
    buf_tt-1s-fin-doc.status_ = 'банк':U
    buf_tt-1s-fin-doc.pay-date = v-today
    buf_tt-th-fin-doc.status_ = 'банк':U
    buf_tt-th-fin-doc.pay-date = v-today
    .
  end.
end procedure.
procedure proc-create-default-tax :
define parameter buffer buf_tt-fin-doc for tt-th-fin-doc.
  do
  on error undo, return error
  :
      find tt0-fin-doc-tax where
                tt0-fin-doc-tax.fin-doc-code = buf_tt-fin-doc.fin-doc-code
          AND tt0-fin-doc-tax.host-code = buf_tt-fin-doc.host-code no-error .
      if not avail tt0-fin-doc-tax
      and not AMBIGUOUS tt0-fin-doc-tax
      then do:
        create tt0-fin-doc-tax.
      end.
      if AMBIGUOUS tt0-fin-doc-tax then return.
      assign
      tt0-fin-doc-tax.fin-doc-code = buf_tt-fin-doc.fin-doc-code
      tt0-fin-doc-tax.host-code = buf_tt-fin-doc.host-code
      tt0-fin-doc-tax.line-num  = 1
      tt0-fin-doc-tax.slt-pc    = 0
      tt0-fin-doc-tax.sum-line-doc = buf_tt-fin-doc.sum-doc
      tt0-fin-doc-tax.sum-slt-line-doc = 0
      tt0-fin-doc-tax.sum-vat-line-doc = 0
      tt0-fin-doc-tax.vat-pc           = 0
      tt0-fin-doc-tax.with-slt         = no
      tt0-fin-doc-tax.with-vat         = no
      tt0-fin-doc-tax.sum-line-doc     = buf_tt-fin-doc.sum-doc
      .
      release tt0-fin-doc-tax.
  end.
end procedure.
procedure proc-insert-statement-lines :
define input parameter p-bh as handle no-undo .
define variable v-host-code as integer no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .
define variable v-mess as character no-undo .
define variable v-ii as integer no-undo .
define variable v-status_ as character no-undo .
define buffer buf_tt-1s-fin-doc for tt-1s-fin-doc.
define buffer buf_tt-th-fin-doc for tt-th-fin-doc.
define buffer buf_fin-doc for ub.fin-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-host-code = p-bh:buffer-field("host-code"):buffer-value
  v-start-date = p-bh:buffer-field("start-date"):buffer-value
  v-end-date = p-bh:buffer-field("end-date"):buffer-value
  .
  do v-ii = 1 to 2:
    if v-ii = 1 then v-status_ = 'факт':U.
    if v-ii = 2 then v-status_ = 'банк':U.
    _line:
    for each buf_tt-1s-fin-doc no-lock where
          buf_tt-1s-fin-doc.host-code = v-host-code
      and  buf_tt-1s-fin-doc.status_ = v-status_
      and  buf_tt-1s-fin-doc.fact-date >= v-start-date
      and  buf_tt-1s-fin-doc.fact-date <= v-end-date
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if  not (buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
      and  buf_tt-1s-fin-doc.payer-code-schet = p-bh:buffer-field("code-schet"):buffer-value)
      and  not (buf_tt-1s-fin-doc.fin-ext-doc-type = 'ппп':U
      and buf_tt-1s-fin-doc.receiver-code-schet = p-bh:buffer-field("code-schet"):buffer-value)  then next _line.
      find first buf_tt-th-fin-doc no-lock where
                buf_tt-th-fin-doc.host-code = p-host-code
            and buf_tt-th-fin-doc.fin-doc-code = buf_tt-1s-fin-doc.fin-doc-code-th no-error.
      if not available buf_tt-th-fin-doc
      and p-create-no-th then do:
        define variable v-line-rec as recid no-undo .
        run ref/finsttml.p (
                      INPUT NO
                      ,INPUT-OUTPUT v-line-rec
                      ,INPUT 'ДОБАВЛЕНИЕ':U
                      ,INPUT p-bh:buffer-field("host-code"):buffer-value
                      ,INPUT p-bh:buffer-field("sttm-code"):buffer-value
                      ,INPUT 0
                      ,INPUT buf_tt-1s-fin-doc.pay-date
                      ,INPUT buf_tt-1s-fin-doc.prn-doc-code
                      ,INPUT buf_tt-1s-fin-doc.fin-ext-doc-type
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-bik
                             else buf_tt-1s-fin-doc.payer-bik)
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-bank-name
                             else buf_tt-1s-fin-doc.payer-bank-name)
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-bank-city
                             else buf_tt-1s-fin-doc.payer-bank-city)
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-c-schet
                             else buf_tt-1s-fin-doc.payer-c-schet )
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-r-schet
                             else buf_tt-1s-fin-doc.payer-r-schet )
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-name
                             else buf_tt-1s-fin-doc.payer-name )
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-inn
                             else buf_tt-1s-fin-doc.payer-inn )
                      ,input (if buf_tt-1s-fin-doc.fin-ext-doc-type = 'рпп':U
                             then buf_tt-1s-fin-doc.receiver-kpp
                             else buf_tt-1s-fin-doc.payer-kpp )
                      ,INPUT buf_tt-1s-fin-doc.sum-doc
                      ,INPUT '1s':U
                      ,input buf_tt-1s-fin-doc.naznach-plat
                        )
            no-error.
        if error-status:error then do:
          v-mess = substitute("Ошибка при включении в выписку импортированного платежа&1" +
                              "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                              ,chr(10)
                              ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                              ,p-bh:buffer-field("hostcode"):buffer-value
                              ,p-bh:buffer-field("r-schet"):buffer-value
                              ,p-bh:buffer-field("bik"):buffer-value)  +
                   substitute("Документ &1&2&3&2&4"
                              , buf_tt-1s-fin-doc.prn-doc-code
                              ,chr(10)
                              , error-status:get-message(1)
                              , return-value )   .
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input v-mess).
          undo _line, next _line.
        end.
      end.
      else do:
        find first buf_fin-doc no-lock where
                  buf_fin-doc.host-code = v-host-code
              and buf_fin-doc.fin-doc-code = buf_tt-th-fin-doc.fin-doc-code no-error.
        if not available buf_fin-doc then do:
        end.
        if buf_fin-doc.sttm-code = 0 then do:
          run ref/finsttml.p (
                         INPUT NO
                        ,INPUT-OUTPUT v-line-rec
                        ,INPUT 'ДОБАВЛЕНИЕ':U
                        ,INPUT p-bh:buffer-field("host-code"):buffer-value
                        ,INPUT p-bh:buffer-field("sttm-code"):buffer-value
                        ,INPUT buf_tt-th-fin-doc.fin-doc-code
                        ,INPUT buf_tt-th-fin-doc.pay-date
                        ,INPUT buf_tt-th-fin-doc.prn-doc-code
                        ,INPUT buf_tt-th-fin-doc.fin-ext-doc-type
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-bik
                              else buf_fin-doc.payer-bik)
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-bank-name
                              else buf_fin-doc.payer-bank-name)
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-bank-city
                              else buf_fin-doc.payer-bank-city)
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-c-schet
                              else buf_fin-doc.payer-c-schet )
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-r-schet
                              else buf_fin-doc.payer-r-schet )
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-name
                              else buf_fin-doc.payer-name )
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-inn
                              else buf_fin-doc.payer-inn )
                        ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                              then buf_fin-doc.receiver-kpp
                              else buf_fin-doc.payer-kpp )
                        ,INPUT buf_tt-th-fin-doc.sum-doc
                        ,INPUT '1s':U
                        ,input buf_tt-th-fin-doc.ps
                          )
              no-error.
          if error-status:error then do:
            v-mess = substitute("Ошибка при включении в выписку импортированного платежа&1" +
                                "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                                ,chr(10)
                                ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                                ,p-bh:buffer-field("hostcode"):buffer-value
                                ,p-bh:buffer-field("r-schet"):buffer-value
                                ,p-bh:buffer-field("bik"):buffer-value) +
                    substitute("Документ &1&2&3&2&4"
                                , buf_tt-1s-fin-doc.prn-doc-code
                                ,chr(10)
                                , error-status:get-message(1)
                                , return-value ).
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input v-mess).
            undo _line, next _line.
          end.
        end.
        else do:
          if  buf_fin-doc.sttm-code = p-bh:buffer-field("sttm-code"):buffer-value then do:
            next _line.
          end.
          else do:
            v-mess = substitute("Не удалось включить в выписку импортированный платеж&1" +
                                "&1Платеж уже привязан к другой выписке" +
                                "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                                ,chr(10)
                                ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                                ,p-bh:buffer-field("hostcode"):buffer-value
                                ,p-bh:buffer-field("r-schet"):buffer-value
                                ,p-bh:buffer-field("bik"):buffer-value) +
                    substitute("Документ &1&2&3&2&4"
                                , buf_tt-1s-fin-doc.prn-doc-code
                                ,chr(10)
                                , error-status:get-message(1)
                                , return-value ).
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input v-mess).
            undo _line, next _line.
          end.
        end.
      end.
    end.
  end.
  _line2:
  for each buf_fin-doc no-lock where
        buf_fin-doc.host-code = v-host-code
    and  buf_fin-doc.status_ = 'факт':U
    and  buf_fin-doc.fact-date >= v-start-date
    and  buf_fin-doc.fact-date <= v-end-date
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if  not (buf_fin-doc.fin-ext-doc-type = 'рпп':U
    and  buf_fin-doc.payer-code-schet = p-bh:buffer-field("code-schet"):buffer-value)
    and  not (buf_fin-doc.fin-ext-doc-type = 'ппп':U
    and buf_fin-doc.receiver-code-schet = p-bh:buffer-field("code-schet"):buffer-value)  then next _line2.
    if buf_fin-doc.sttm-code = 0 then do:
      run ref/finsttml.p (
                      INPUT NO
                    ,INPUT-OUTPUT v-line-rec
                    ,INPUT 'ДОБАВЛЕНИЕ':U
                    ,INPUT p-bh:buffer-field("host-code"):buffer-value
                    ,INPUT p-bh:buffer-field("sttm-code"):buffer-value
                    ,INPUT buf_fin-doc.fin-doc-code
                    ,INPUT buf_fin-doc.pay-date
                    ,INPUT buf_fin-doc.prn-doc-code
                    ,INPUT buf_fin-doc.fin-ext-doc-type
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-bik
                          else buf_fin-doc.payer-bik)
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-bank-name
                          else buf_fin-doc.payer-bank-name)
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-bank-city
                          else buf_fin-doc.payer-bank-city)
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-c-schet
                          else buf_fin-doc.payer-c-schet )
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-r-schet
                          else buf_fin-doc.payer-r-schet )
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-name
                          else buf_fin-doc.payer-name )
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-inn
                          else buf_fin-doc.payer-inn )
                    ,input (if buf_fin-doc.fin-ext-doc-type = 'рпп':U
                          then buf_fin-doc.receiver-kpp
                          else buf_fin-doc.payer-kpp )
                    ,INPUT buf_fin-doc.sum-doc
                    ,INPUT '1s':U
                    ,input buf_fin-doc.ps
                      )
          no-error.
      if error-status:error then do:
        v-mess = substitute("Ошибка при включении платежа в выписку&1" +
                            "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                            ,chr(10)
                            ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                            ,p-bh:buffer-field("hostcode"):buffer-value
                            ,p-bh:buffer-field("r-schet"):buffer-value
                            ,p-bh:buffer-field("bik"):buffer-value) +
                substitute("Документ &1&2&3&2&4"
                            , buf_tt-1s-fin-doc.prn-doc-code
                            ,chr(10)
                            , error-status:get-message(1)
                            , return-value ).
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input v-mess).
        undo _line2, next _line2.
      end.
    end.
    else do:
      if  buf_fin-doc.sttm-code = p-bh:buffer-field("sttm-code"):buffer-value then do:
        next _line2.
      end.
      else do:
        v-mess = substitute("Не удалось включить платеж в выписку&1" +
                            "&1Платеж уже привязан к другой выписке" +
                            "Выписка &2 Фирма &3&1Счет &4 БИК &5&1"
                            ,chr(10)
                            ,cbnki-period-to-String(p-bh:buffer-field("start-date"):buffer-value, p-bh:buffer-field("end-date"):buffer-value)
                            ,p-bh:buffer-field("hostcode"):buffer-value
                            ,p-bh:buffer-field("r-schet"):buffer-value
                            ,p-bh:buffer-field("bik"):buffer-value) +
                substitute("Документ &1&2&3&2&4"
                            , buf_tt-1s-fin-doc.prn-doc-code
                            ,chr(10)
                            , error-status:get-message(1)
                            , return-value ).
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input v-mess).
        undo _line2, next _line2.
      end.
    end.
  end.
end.
end procedure.
procedure proc-create-fin-statement :
define parameter buffer buf_tt-th-fin-statement for tt-th-fin-statement.
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_fin-statement for ub.fin-statement.
  do
  on error undo, return error
  :
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    buf_tt-th-fin-statement.prn-doc-code = cbnki-period-to-String(tt-th-fin-statement.start-date
                                                                  ,tt-th-fin-statement.end-date)
    buf_tt-th-fin-statement.status_      = 'новый':U
    buf_tt-th-fin-statement.doc-date     = v-today
    buf_tt-th-fin-statement.sum-doc      = buf_tt-th-fin-statement.in-sum-doc - buf_tt-th-fin-statement.out-sum-doc
    buf_tt-th-fin-statement.fins-ext-doc-type = 'стд':U
    .
 run ref/finsttm0.p
                 (input yes
                 ,input-output v-doc-rec
                 ,input  'ДОБАВЛЕНИЕ':U
                 ,input  '1s':U
                 ,input buf_tt-th-fin-statement.host-code            ,input buf_tt-th-fin-statement.sttm-code            ,input buf_tt-th-fin-statement.curr-code            ,input buf_tt-th-fin-statement.doc-date             ,input buf_tt-th-fin-statement.bank-date            ,input buf_tt-th-fin-statement.fact-date            ,input buf_tt-th-fin-statement.fins-doc-type        ,input buf_tt-th-fin-statement.fins-ext-doc-type    ,input buf_tt-th-fin-statement.code-bank            ,input buf_tt-th-fin-statement.bank-name            ,input buf_tt-th-fin-statement.bank-city            ,input buf_tt-th-fin-statement.bik                  ,input buf_tt-th-fin-statement.code-schet           ,input buf_tt-th-fin-statement.r-schet              ,input buf_tt-th-fin-statement.c-schet              ,input buf_tt-th-fin-statement.cli-name             ,input buf_tt-th-fin-statement.prn-doc-code         ,input buf_tt-th-fin-statement.PS                   ,input buf_tt-th-fin-statement.sum-doc              ,input buf_tt-th-fin-statement.start-sum-doc-th     ,input buf_tt-th-fin-statement.start-sum-doc        ,input buf_tt-th-fin-statement.in-sum-doc           ,input buf_tt-th-fin-statement.out-sum-doc          ,input buf_tt-th-fin-statement.end-sum-doc          ,input buf_tt-th-fin-statement.num-docs             ,input buf_tt-th-fin-statement.start-date           ,input buf_tt-th-fin-statement.end-date
                 ,input buf_tt-th-fin-statement.status_
                 ,input no
                 ) no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
    else do:
      assign
      p-created-statement = p-created-statement + 1
      .
      find first buf_fin-statement no-lock where
                recid(buf_fin-statement) = v-doc-rec.
      assign
      buf_tt-th-fin-statement.sttm-code = buf_fin-statement.sttm-code
      .
    end.
  end.
end procedure.
