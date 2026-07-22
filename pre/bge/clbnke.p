block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
define variable p-auto                  as integer      no-undo.
define variable p-curr-host-code        as integer      no-undo.
define variable p-rs-1                  as integer      no-undo.
define variable p-rs-hsch               as integer      no-undo.
define variable p-rs-csch               as integer      no-undo.
define variable p-format                as character    no-undo.
define variable p-encoding              as character    no-undo.
define variable p-date-from             as date         no-undo.
define variable p-date-to               as date         no-undo.
define variable p-doc-type-list         as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: cb1b05444cdf, 212, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:12:07 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clbnke.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/clbnke.p $":U .
define variable vss-description as character no-undo init "ЭКСПОРТ в систему КЛИЕНТ-БАНК".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp_hfields no-undo
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
     if buf_fin-doc-attr.attr-value = p-attr-value then do:
       run write-fin-doc-attr-proc  in this-procedure (buffer buf_fin-doc-attr ).
     end.
     else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
     end.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
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
define variable v-input-error as logical no-undo .
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable v-date-range as character no-undo .
define variable log-file-name as character no-undo init 'ext-cbnk.log'.
define stream PrnLibStream.
if num-entries(p-parameter, chr(4)) <> 4
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 3"
                             , num-entries(p-parameter, chr(4))).
  .
end.
else do:
  if num-entries(entry(2, p-parameter, chr(4))) <> 9
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 2-ом ENTRY составного параметре - &1, должно быть 9"
                              , num-entries(entry(1, p-parameter, chr(4)))).
    .
  end.
  if num-entries(entry(3, p-parameter, chr(4))) <> 5
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 3-ом ENTRY составного параметре - &1, должно быть 5"
                              , num-entries(entry(2, p-parameter, chr(4)))).
    .
  end.
  assign
  p-auto = integer(entry(1, p-parameter, chr(4)) )
  p-format  = entry( 1, entry(2, p-parameter, chr(4)) )
  p-encoding  = entry( 2, entry(2, p-parameter, chr(4)) )
  p-rs-1 = integer( entry( 3, entry(2, p-parameter, chr(4))) )
  p-curr-host-code = integer(entry(4, entry(2, p-parameter, chr(4))))
  p-rs-hsch = integer( entry( 6, entry(2, p-parameter, chr(4)) ) )
  p-rs-csch = integer( entry( 7, entry(2, p-parameter, chr(4)) ) )
  v-date-range = entry(3, p-parameter, chr(4))
  p-doc-type-list = entry(4, p-parameter, chr(4))
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
end.
if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  return.
end.
if p-rs-1 <> 1
and p-rs-1 <> 2 then do:
  v-esm = substitute("Неизвестное значение параметра выбора фирмы:&1", p-rs-1).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  return.
end.
if p-rs-1 <> 2
and (p-rs-hsch <> 1
     or
     p-rs-csch <> 1)
then do:
  v-esm = substitute("Несопоставимые значения параметра выбора фирмы (&1)" +
                     " и параметра выбора счетов фирмы (&2)" +
                     " и/или параметра выбора счетов контрагента (&3)"
                     , p-rs-1
                     , p-rs-hsch
                     , p-rs-csch
                     ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , chr(10)
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  return.
end.
run analyze-date-range in this-procedure (
    input v-date-range
    , output p-date-from
    , output p-date-to
) no-error.
if error-status :error
or p-date-from  = ?
or p-date-to    = ?
then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute( "Ошибка входных параметров:Не удалось определить интервал дат для выгрузки.&1&2 &3"
                                    , chr(10)
                                    , return-value
                                    , error-status :get-message( 1 )
                                )
                                         ).
  assign
  v-view-log = yes.
  return.
end.
CASE p-format:
  when '1s':U then do:
     run proc-main-1s in this-procedure no-error .
  end.
END CASE.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при экспорте данных в систему КЛИЕНТ-БАНК в формате&1&2&3 &4"
                         , entry (lookup (p-format, '1s':U) + 1, ',' + '1С':U)
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе Экспорта в систему КЛИЕНТ-БАНК  произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action7   as character no-undo .
  define variable v-printed7       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе Экспорта в систему КЛИЕНТ-БАНК  произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'ext-cbnk.log')
    ,input  7
    ,output v-user-action7
    ,output v-printed7
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
 .
  return "error":U.
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе Экспорта в систему КЛИЕНТ-БАНК  произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action9   as character no-undo .
  define variable v-printed9       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе Экспорта в систему КЛИЕНТ-БАНК  произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'ext-cbnk.log')
    ,input  7
    ,output v-user-action9
    ,output v-printed9
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
 .
procedure proc-main-1s :
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-doc for ub.fin-doc.
define variable v-count as integer no-undo .
define variable ii as integer no-undo .
  do
  on error undo, return error return-value
  :
    run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("Экспорт документов в систему КЛИЕНТ-БАНК по формату &1", entry (lookup (p-format, '1s':U) + 1, ',' + '1С':U))).
    if p-rs-1 = 1 then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Фирмы: Все")).
    end.
    else do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Фирмы:")).
      for each temp_obj-list no-lock:
                      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     &1&2", temp_obj-list.obj-type, temp_obj-list.obj-code)).
      end.
    end.
    if p-rs-hsch = 1 then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Счета фирм: Все")).
    end.
    else do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Счета фирм:")).
      for each temp_hfin-schet no-lock:
                      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input SUBSTITUTE("&1 &2&3 &4/&5",                                          temp_hfin-schet.r-schet                                        ,temp_hfin-schet.cli-type                                       ,temp_hfin-schet.cli-code                                       ,temp_hfin-schet.code-bank                                      ,temp_hfin-schet.code-schet)).
      end.
    end.
    if p-rs-csch = 1 then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Счета контрагентов: Все")).
    end.
    else do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Счета контрагентов:")).
      for each temp_cfin-schet no-lock:
                      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input SUBSTITUTE("&1 &2&3 &4/&5",                                          temp_cfin-schet.r-schet                                        ,temp_cfin-schet.cli-type                                       ,temp_cfin-schet.cli-code                                       ,temp_cfin-schet.code-bank                                      ,temp_cfin-schet.code-schet)).
      end.
    end.
    run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Типы документов:")).
     do ii = 1 to num-entries(p-doc-type-list):
    run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("&1", entry (lookup (entry(ii, p-doc-type-list), 'пко,рко,ппп,рпп,апп,апр,':U), 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,апп,апр':U) )).
     end.
    run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Интервал дат: с &1 по &2", string(p-date-from, "99/99/9999"), string(p-date-to, "99/99/9999"))).
    run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Кодировка: &1",  if p-encoding = "windows-1251" then 'Windows' else 'DOS')).
     _buf_sysconf:
     for each buf_sysconf  no-lock:
       if p-rs-1 = 2 then do:
         find first temp_obj-list no-lock where
                    temp_obj-list.obj-type = 'орг':U
                AND temp_obj-list.obj-code = buf_sysconf.host-code no-error .
         if not available temp_obj-list then next _buf_sysconf.
       end.
       do ii = 1 to num-entries(p-doc-type-list):
        _buf_fin-doc:
        for each buf_fin-doc no-lock where
                buf_fin-doc.host-code = buf_sysconf.host-code
            AND  buf_fin-doc.fin-ext-doc-type = entry(ii, p-doc-type-list)
            and status_ = 'банк':U
            and buf_fin-doc.doc-date >= p-date-from
            AND buf_fin-doc.doc-date <= p-date-to:
          if p-rs-hsch = 2  then do:
            find first temp_hfin-schet no-lock where
                      temp_hfin-schet.host-code = buf_sysconf.host-code
                  AND temp_hfin-schet.code-schet = buf_fin-doc.payer-code-schet no-error.
            if not available temp_hfin-schet then next _buf_fin-doc.
          end.
          if p-rs-csch = 2  then do:
            find first temp_cfin-schet no-lock where
                      temp_cfin-schet.host-code = buf_sysconf.host-code
                  AND temp_cfin-schet.code-schet = buf_fin-doc.receiver-code-schet no-error.
            if not available temp_cfin-schet then next _buf_fin-doc.
          end.
          find first temp-bik where
                    temp-bik.host-code = buf_fin-doc.host-code
                AND temp-bik.bik = buf_fin-doc.payer-bik no-error.
          if not available temp-bik then do:
            run export-header-1s in this-procedure (
                                                    input buf_fin-doc.host-code
                                                  , input buf_fin-doc.payer-bik
                                                    ) no-error .
            if error-status:error then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input  substitute( "!!!Ошибка записи заголовка файла для выгрузки в формате &1&2 Фирма &3 Банк с БИК &4&2&5 &6&2" +
                                       "!!!Финдокументы по фирме &3 БИК &4 экспортироваться не будут!"
                                                , entry (lookup (p-format, '1s':U) + 1, ',' + '1С':U)
                                                , chr(10)
                                                , buf_fin-doc.host-code
                                                , buf_fin-doc.payer-bik
                                                , return-value
                                                , error-status :get-message( 1 )
                                            )
                                                    ).
              assign
              v-view-log = yes.
            end.
          end.
          find first temp-bik where
                    temp-bik.host-code = buf_fin-doc.host-code
                AND temp-bik.bik = buf_fin-doc.payer-bik no-error.
          if not available temp-bik
          or temp-bik.f_name = '':U then next _buf_fin-doc.
          CASE buf_fin-doc.fin-ext-doc-type:
            when 'рпп':U then do:
              run export-fin-doc-ec-1s in this-procedure (
                                                        buffer buf_fin-doc
                                                      , input temp-bik.f_name
                                                      , input temp-bik.adresat
                                                      ) no-error .
            end.
          END CASE.
          if error-status:error then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input  substitute( "Ошибка экспорта финдокумента &5 при выгрузке в формате &1&2&3 &4"
                                                , entry (lookup (p-format, '1s':U) + 1, ',' + '1С':U)
                                                , chr(10)
                                                , return-value
                                                , error-status :get-message( 1 )
                                                , buf_fin-doc.prn-doc-code
                                            )
                                                    ).
            assign
            v-view-log = yes.
            NEXT _buf_fin-doc.
          end.
          else do:
            assign
            v-count = v-count + 1
            temp-bik.d-count = temp-bik.d-count + 1
            .
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Экспорт БИК &1 Фирма &2: экспортировано документов &3"
                                            , temp-bik.bik
                                            , temp-bik.host-code
                                            , temp-bik.d-count)).
          end.
        end.
      end.
    end.
    ii = 0.
    for each temp-bik no-lock:
      if temp-bik.f_name = '':U then next.
      run export-footer-1s in this-procedure (
                                              input temp-bik.host-code
                                            , input temp-bik.bik
                                            , input temp-bik.f_name
                                            , input temp-bik.o_name
                                            , input temp-bik.d-count).
      assign
      ii = 1.
    end.
    if ii = 0 then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input "!!!Не удалось экспортировать финдокументы или найдено ни одного финдокумента для экспорта").
    end.
  end.
end procedure.
procedure export-header-1s :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik no-undo .
define variable loc-in_ as character no-undo .
define variable loc-spl as character no-undo .
define variable loc-sav as character no-undo .
define variable loc-out as character no-undo .
define variable loc-adresat as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable ii as integer no-undo .
define variable v-doc-type-1s as character no-undo .
define variable v-version as character no-undo .
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_temp_hfin-schet for temp_hfin-schet.
define buffer find_first-fin-bank for ub.fin-bank.
  do
  on error undo, return error
  :
    find first buf_fin-bank no-lock where
                buf_fin-bank.host-code = p-host-code
            AND buf_fin-bank.bik = p-bik.
    create temp-bik.
    assign
    temp-bik.host-code = p-host-code
    temp-bik.bik       = p-bik
    .
    run bge/cbnkinis.p (
                         input parparentproc
                       , input p-format
                       , input p-bik
                       , input p-host-code
                       , input "send":U
                       , output loc-out
                       , output LOC-in_
                       , output LOC-spl
                       , output LOC-sav
                       , output loc-adresat
                       )  no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Не удалось получить настройки для системы КЛИЕНТ-БАНК формата &1 для БИК &2 фирма &3 из ini-файла:&4&5 &6"
                              , p-format
                              , p-bik
                              , p-host-code
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value)).
      assign
      v-view-log = yes.
      undo,  return error.
    end.
    assign
    temp-bik.f_name = substitute("&1&2\&3.dat", loc-out, loc-spl, substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 ), '.dat')
    temp-bik.o_name = substitute("&1&2\&3", loc-out, loc-spl , '1C_to_KL.txt')
    temp-bik.adresat = loc-adresat
    .
    if p-encoding <> 'windows-1251' then do:
      output stream PrnLibStream
      to value(  temp-bik.f_name ) convert target p-encoding.
    end.
    else do:
      output stream PrnLibStream
      to value(  temp-bik.f_name ) .
    end.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    run gbl/getvers.p (output v-version).
    v-version = substitute('IBS TH &1', v-version).
    put stream PrnLibStream unformatted
    '1CClientBankExchange' skip
    'ВерсияФормата=1.01'   skip
    'Кодировка=' (if p-encoding = 'windows-1251' then 'Windows':U else 'DOS') skip
    'Отправитель=' v-version skip
    'Получатель=' loc-adresat skip
    'ДатаСоздания=' string(v-today, "99/99/9999") skip
    'ВремяСоздания=' string(v-time, "HH:MM:SS") skip
    'ДатаНачала=' string(p-date-from, "99/99/9999") skip
    'ДатаКонца=' string(p-date-to, "99/99/9999") skip
    .
    _buf_fin-schet:
    FOR EACH find_first-fin-bank no-lock where
            find_first-fin-bank.host-code = p-host-code
        AND find_first-fin-bank.bik       = p-bik
        AND find_first-fin-bank.status_   = 'тек':U,
       each buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
       AND  buf_fin-schet.code-bank = find_first-fin-bank.code-bank
       AND  buf_fin-schet.status_       = 'тек':U:
      if p-rs-csch = 2 then do:
          find first buf_temp_hfin-schet no-lock where
                    buf_temp_hfin-schet.host-code = buf_fin-schet.host-code
                AND buf_temp_hfin-schet.code-schet = buf_fin-schet.code-schet no-error.
          if not available buf_temp_hfin-schet then next _buf_fin-schet.
      end.
      put stream PrnLibStream unformatted
      'РасчСчет='  buf_fin-schet.r-schet skip
      .
    end.
    do ii = 1 to num-entries(p-doc-type-list):
      CASE entry(ii, p-doc-type-list):
        when 'рпп':U then do:
          v-doc-type-1s =  'Платежное поручение'.
        end.
      END CASE.
      put stream PrnLibStream unformatted
      'Документ='  v-doc-type-1s skip.
      .
    end.
    output stream PrnLibStream close.
  end.
end procedure.
procedure export-fin-doc-ec-1s :
define parameter buffer buf_fin-doc for ub.fin-doc.
define input parameter p-f_name as character no-undo .
define input parameter p-adresat as character no-undo .
define variable h_fin-doc as handle no-undo .
define variable h_field as handle no-undo .
define buffer locked_fin-doc for ub.fin-doc.
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_rfin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_rfin-schet for ub.fin-schet.
  do
  on error undo, return error
  :
    find first locked_fin-doc where
               recid(locked_fin-doc) = recid(buf_fin-doc).
    if p-encoding <> 'windows-1251' then do:
      output stream PrnLibStream
      to value(  p-f_name ) convert target p-encoding append.
    end.
    else do:
      output stream PrnLibStream
      to value(  p-f_name ) append.
    end.
    find first buf_fin-schet no-lock where
              buf_fin-schet.host-code = buf_fin-doc.host-code
          AND buf_fin-schet.code-schet = buf_fin-doc.payer-code-schet .
    if buf_fin-schet.status_ <> 'тек':U then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Финдокумент &1 (фирма &2)&3Счет Плательщика имеет статус &4&3Экспорт невозможен"                             , buf_fin-doc.prn-doc-code                                                                                       , buf_fin-doc.host-code                                                                                          , chr(10)                                                                                                  ,buf_fin-schet.status_                                                                )).
      output stream PrnLibStream close.
      return.
    end.
    find first buf_fin-bank no-lock where
              buf_fin-bank.host-code = buf_fin-doc.host-code
          AND buf_fin-bank.code-bank = buf_fin-schet.code-bank .
    if buf_fin-bank.status_ <> 'тек':U then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Финдокумент &1 (фирма &2)&3Банк Плательщика имеет статус &4&3Экспорт невозможен"                             , buf_fin-doc.prn-doc-code                                                                                       , buf_fin-doc.host-code                                                                                          , chr(10)                                                                                                  ,buf_fin-bank.status_                                                                )).
      output stream PrnLibStream close.
      return.
    end.
    find first buf_rfin-schet no-lock where
              buf_rfin-schet.host-code = buf_fin-doc.host-code
          AND buf_rfin-schet.code-schet = buf_fin-doc.receiver-code-schet .
    if buf_rfin-schet.status_ <> 'тек':U then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Финдокумент &1 (фирма &2)&3Счет Получателя имеет статус &4&3Экспорт невозможен"                              , buf_fin-doc.prn-doc-code                                                                                       , buf_fin-doc.host-code                                                                                          , chr(10)                                                                                                  ,buf_rfin-schet.status_                                                                )).
      output stream PrnLibStream close.
      return.
    end.
    find first buf_rfin-bank no-lock where
              buf_rfin-bank.host-code = buf_fin-doc.host-code
          AND buf_rfin-bank.code-bank = buf_rfin-schet.code-bank .
    if buf_fin-bank.status_ <> 'тек':U then do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Финдокумент &1 (фирма &2)&3Банк Получателя имеет статус &4&3Экспорт невозможен"                             , buf_fin-doc.prn-doc-code                                                                                       , buf_fin-doc.host-code                                                                                          , chr(10)                                                                                                  ,buf_rfin-bank.status_                                                                )).
      output stream PrnLibStream close.
      return.
    end.
    assign
    h_fin-doc = buffer locked_fin-doc:handle
    .
    find first temp_hfields no-lock no-error.
    if not available temp_hfields then do:
      run create-temp-hfields in this-procedure ('exp').
    end.
    put stream PrnLibStream unformatted
    'СекцияДокумент=Платежное поручение' skip.
    for each temp_hfields by temp_hfields.order_:
      CASE temp_hfields.name_:
        when 'doc-date' then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_ string(h_fin-doc:buffer-field(temp_hfields.name_):buffer-value, "99.99.9999") skip
          .
        end.
        when 'sum-doc' then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_ trim(string(h_fin-doc:buffer-field(temp_hfields.name_):buffer-value, ">>>>>>>>>>>>9.99")) skip
          .
        end.
        when "payer-inn/payer-name"
        OR
        WHEN "RECEIVER-inn/RECEIVER-name"
        then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_
          substitute("ИНН &1 &2"
                      ,h_fin-doc:buffer-field(entry(1, temp_hfields.name_, chr(47))):buffer-value
                      ,h_fin-doc:buffer-field(entry(2, temp_hfields.name_, chr(47))):buffer-value
                    )
          skip
          .
        end.
        when 'naznach-plat/' then do:
          put stream PrnLibStream unformatted
          temp_hfields.label_
          replace(h_fin-doc:buffer-field(entry(1, temp_hfields.name_, chr(47))):buffer-value, '@', '')
          skip.
        end.
        otherwise do:
          if h_fin-doc:buffer-field(temp_hfields.name_):data-type = 'date':U then do:
            put stream PrnLibStream unformatted
            temp_hfields.label_ string(h_fin-doc:buffer-field(temp_hfields.name_):buffer-value, "99.99.9999") skip
            .
          end.
          else do:
            put stream PrnLibStream unformatted
            temp_hfields.label_ h_fin-doc:buffer-field(temp_hfields.name_):buffer-value skip
            .
          end.
        end.
      END CASE.
    end.
    put stream PrnLibStream unformatted
    'КонецДокумента' skip.
    output stream PRnLibStream close.
    assign
    locked_fin-doc.pay-author = p-adresat.
  end.
end procedure.
procedure export-footer-1s :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik      no-undo .
define input parameter p-f_name    as character no-undo .
define input parameter p-o_name    as character no-undo .
define input parameter p-count     as integer no-undo .
define variable v-os-err as integer no-undo .
define variable v-os-err-name as character no-undo .
  do
  on error undo, return error
  :
    if p-encoding <> 'windows-1251' then do:
      output stream PrnLibStream
      to value(  p-f_name ) convert target p-encoding append.
    end.
    else do:
      output stream PrnLibStream
      to value(  p-f_name ) append.
    end.
    put stream PrnLibStream unformatted
    'КонецФайла'
    skip.
    output stream PRnLibStream close.
    OS-RENAME value(p-f_name ) value(p-o_name).
    assign
    v-os-err = os-error.
    if v-os-err <> 0 then do:
      if v-os-err <> 10 then do:
       run gbl/os-errnm.p (v-os-err, output v-os-err-name).
      end.
       run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("БИК &1 Фирма &2&4 - файл экспорта &3:&4экспортировано документов: &5&4" +                              "!!!Не удалось сохранить файл с именем &6:&4&7"                      ,p-bik                                                                                     ,p-host-code                                                                               ,p-f_name                                                                                  ,chr(10)                                                                              ,p-count                                                                                   ,p-o_name                                                                                  ,(if v-os-err = 10 then 'Возможно не был перемещен файл, полученный в предудыщем сеансе экспорта' else v-os-err-name ))).
    end.
    else do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("БИК &1 Фирма &2&4 - файл экспорта &3:&4экспортировано документов: &5"                      ,p-bik                                                                                     ,p-host-code                                                                               ,p-o_name                                                                                  ,chr(10)                                                                              ,p-count)).
    end.
  end.
end procedure.
procedure analyze-date-range :
do
on error undo, return error
:
define input parameter p-date-range  as character    no-undo.
define output parameter p-date-from  as date         no-undo.
define output parameter p-date-to    as date         no-undo.
    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.
    define variable v-days-ago      as integer       no-undo.
    define variable v-days-amount   as integer       no-undo.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    case entry( 1, p-date-range )
    :
        when "0"
        then do:
            assign
                v-days-ago    = integer( entry( 3, p-date-range ) )
                v-days-amount = integer( entry( 2, p-date-range ) )
            .
            assign
                p-date-from = v-today - v-days-ago
                p-date-to   = v-today - v-days-ago + v-days-amount
            .
            if p-date-to > v-today
            then do:
                assign
                  p-date-to = v-today
                .
            end.
        end.
        when "1"
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = v-today
            .
        end.
        when "2"
        then do:
            assign
                p-date-from = date( entry( 4, p-date-range ) )
                p-date-to   = date( entry( 5, p-date-range ) )
            .
        end.
        otherwise do:
            assign
                p-date-from = ?
                p-date-to   = ?
            .
        end.
    end case.
end.
end procedure.
