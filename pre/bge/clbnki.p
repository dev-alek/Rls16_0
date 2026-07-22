block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
define variable p-auto                  as integer      no-undo.
define variable p-curr-host-code        as integer      no-undo.
define variable p-format                as character    no-undo.
define variable p-encoding              as character    no-undo.
define variable p-rs-1                  as integer      no-undo.
define variable p-rs-hsch               as integer      no-undo.
define variable p-create                as logical no-undo .
define variable p-no-th-create          as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: cb1b05444cdf, 212, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jun 30 11:12:07 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clbnki.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/clbnki.p $":U .
define variable vss-description as character no-undo init "ИМПОРТ из системы КЛИЕНТ-БАНК".
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
define NEW shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define NEW shared variable RepPathName        as character no-undo .
define NEW shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp_hfields no-undo
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
define variable v-input-error as logical no-undo .
define variable v-view-log as logical no-undo .
define variable v-esm as character no-undo .
define variable log-file-name as character no-undo init 'ext-cbnk.log'.
if num-entries(p-parameter, chr(4)) <> 4
then do:
  assign
  v-input-error = yes
  v-esm         = substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 4"
                             , num-entries(p-parameter, chr(4))).
  .
end.
else do:
  if num-entries(entry(2, p-parameter, chr(4))) <> 9
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 2-ом ENTRY составного параметре - &1, должно быть 9"
                              , num-entries(entry(2, p-parameter, chr(4)))).
    .
  end.
  if num-entries(entry(3, p-parameter, chr(4))) <> 5
  then do:
    assign
    v-input-error = yes
    v-esm         = substitute("Неверное количество ENTRY в 3-ом ENTRY составного параметре - &1, должно быть 5"
                              , num-entries(entry(3, p-parameter, chr(4)))).
    .
  end.
  assign
  p-auto = integer(entry(1, p-parameter, chr(4)) )
  p-format  = entry( 1, entry(2, p-parameter, chr(4)) )
  p-encoding  = entry( 2, entry(2, p-parameter, chr(4)) )
  p-rs-1 = integer( entry( 3, entry(2, p-parameter, chr(4))) )
  p-curr-host-code = integer(entry(4, entry(2, p-parameter, chr(4))))
  p-rs-hsch = integer( entry( 6, entry(2, p-parameter, chr(4)) ) )
  p-create  = logical( entry( 8, entry(2, p-parameter, chr(4)) ) )
  p-no-th-create  = (if num-entries(entry(2, p-parameter, chr(4))) > 8
                     and p-create = no
                     then logical( entry( 9, entry(2, p-parameter, chr(4)) ) )
                     else no)
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
and p-rs-hsch <> 1
then do:
  v-esm = substitute("Несопоставимые значения параметра выбора фирмы (&1)" +
                     " и параметра выбора счетов фирмы (&2)"
                     , p-rs-1
                     , p-rs-hsch
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
run proc-main in this-procedure no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при импорте данных из системы КЛИЕНТ-БАНК в формате&1&2&3 &4"
                         , entry (lookup (p-format, '1s':U) + 1, ',' + '1С':U)
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе Импорта из системы КЛИЕНТ-БАНК  произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action8   as character no-undo .
  define variable v-printed8       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе Импорта из системы КЛИЕНТ-БАНК  произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'ext-cbnk.log')
    ,input  7
    ,output v-user-action8
    ,output v-printed8
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  substitute('!!!В процессе Импорта из системы КЛИЕНТ-БАНК  произошли ошибки!!!')  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action10   as character no-undo .
  define variable v-printed10       as logical   no-undo .
  run gbl/prnfilen.w
    (input  (substitute('!!!В процессе Импорта из системы КЛИЕНТ-БАНК  произошли ошибки!!!'))
    ,input  0
    ,input  (string("./":U) + 'ext-cbnk.log')
    ,input  7
    ,output v-user-action10
    ,output v-printed10
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
procedure proc-main :
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-bank for ub.fin-bank.
define variable ii as integer no-undo .
define variable v-count as integer no-undo .
define variable v-processed as integer no-undo .
define variable v-created as integer no-undo .
define variable v-count-statement as integer no-undo .
define variable v-processed-statement as integer no-undo .
define variable v-created-statement as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
  do
  on error undo, return error return-value
  :
    run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("Импорт документов из системы КЛИЕНТ-БАНК по формату &1", entry (lookup (p-format, '1s':U) + 1, ',' + '1С':U))).
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
    run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("     Кодировка: &1",  if p-encoding = "windows-1251" then 'Windows' else 'DOS')).
     _buf_sysconf:
     for each buf_sysconf  no-lock:
       if p-rs-1 = 2 then do:
         find first temp_obj-list no-lock where
                    temp_obj-list.obj-type = 'орг':U
                AND temp_obj-list.obj-code = buf_sysconf.host-code no-error .
         if not available temp_obj-list then next _buf_sysconf.
       end.
       _buf_fin-schet:
       for each buf_Fin-schet no-lock where
               buf_fin-schet.host-code = buf_sysconf.host-code
           AND buf_fin-schet.cli-type  = 'орг':U
           AND buf_fin-schet.cli-code  = buf_sysconf.host-code
           and buf_fin-schet.status_   = 'тек':U:
          if p-rs-hsch = 2  then do:
            find first temp_hfin-schet no-lock where
                      temp_hfin-schet.host-code = buf_sysconf.host-code
                  AND temp_hfin-schet.code-schet = buf_fin-schet.code-schet
                  AND temp_hfin-schet.code-bank = buf_fin-schet.code-bank  no-error.
            if not available temp_hfin-schet then next _buf_fin-schet.
          end.
          else do:
          end.
          find first buf_fin-bank no-lock where
                    buf_fin-bank.host-code = buf_sysconf.host-code
                AND buf_fin-bank.code-bank = buf_fin-schet.code-bank.
          find first temp-bik where
                    temp-bik.host-code = buf_sysconf.host-code
                AND temp-bik.bik       = buf_fin-bank.bik no-error.
          if not available temp-bik then do:
             run get-inis-from-bik-host in this-procedure (
                                                           input buf_sysconf.host-code
                                                          ,input buf_fin-bank.bik
                                                          ,input buf_fin-bank.code-bank) no-error .
             if error-status:error then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input  substitute( "!!!Ошибка получения пути к файлу импорта для загрузки в формате &1&2 Фирма &3 Банк с БИК &4&2&5 &6&2" +
                                       "!!!Финдокументы по фирме &3 БИК &4 импортироваться не будут!"
                                                , entry (lookup (p-format, '1s':U) + 1, ',' + '1С':U)
                                                , chr(10)
                                                , buf_fin-bank.host-code
                                                , buf_fin-bank.bik
                                                , return-value
                                                , error-status :get-message( 1 )
                                            )
                                                    ).
              assign
              v-view-log = yes.
             end.
          end.
          find first temp-bik where
                    temp-bik.host-code = buf_sysconf.host-code
                AND temp-bik.bik       = buf_fin-bank.bik no-error.
          if not available temp-bik
          or temp-bik.o_name = '':u then next _buf_fin-schet.
       end.
     end.
    _temp-bik:
    for each temp-bik:
      run gbl/filename.p (
                      input temp-bik.o_name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Отсутствует файл &1 для импорта&2банк с БИК &3 фирма &4"                           ,temp-bik.o_name                                                                           ,chr(10)                                                                             ,temp-bik.bik                                                                              ,temp-bik.host-code)).
        delete temp-bik.
        assign
        v-view-log = yes.
        next _temp-bik.
      end.
      CASE p-format:
        when '1s':U then do:
          find first temp_hfields no-lock no-error.
          if not available temp_hfields then do:
            run create-temp-hfields in this-procedure ('imp').
          end.
          run bge/cbnki-1s.p (
                           input parparentproc
                          ,input p-log-handle
                          ,input temp-bik.o_name
                          ,input temp-bik.host-code
                          ,input temp-bik.bik
                          ,input temp-bik.code-bank
                          ,input temp-bik.adresat
                          ,input p-create
                          ,input p-no-th-create
                          ,input p-encoding
                          ,input p-rs-hsch
                          ,input-output v-view-log
                          ,output v-count
                          ,output v-processed
                          ,output v-created
                          ,output v-count-statement
                          ,output v-processed-statement
                          ,output v-created-statement
                          ) no-error .
        end.
      END CASE.
      if error-status:error then do:
          run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("!!!Ошибка при импорта данных по финдокументам:&1БИК &2 фирма &3&1&4 &5"                           , chr(10)                                                                                   , temp-bik.bik                                                                                    , temp-bik.host-code                                                                              , error-status:get-message(1)                                                                     , return-value )).
        assign
        v-view-log = yes.
      end.
      else do:
      run write-log-and-file in p-log-handle (                                                                                               input 1                                                                                    , input log-file-name                                                                        , input 1                                                                                    , input substitute("БИК &1 Фирма &2&4 - файл импорта &3:&4" +                                                        "в файле &8 документов&4" +                                                                         "обработано документов: &5&4" +                                                                   "в т.ч. создано в статусе &6 - &7&4"                                                         ,temp-bik.bik                                                                                     ,temp-bik.host-code                                                                               ,temp-bik.o_name                                                                                  ,chr(10)                                                                                    ,v-processed                                                                                      ,'новый':U                                                                                     ,v-created                                                                                        ,v-count  )  +                                                                                substitute("в файле &5 выписок&1" +                                                                         "обработано выписок: &2&1" +                                                                   "в т.ч. создано в статусе &3 - &4&1"                                                         ,chr(10)                                                                                    ,v-processed-statement                                                                            ,'новый':U                                                                                     ,v-created-statement                                                                              ,v-count-statement )).
      end.
      os-append value( temp-bik.o_name ) value( temp-bik.f_name) .
      if os-error = 0 then
      os-delete value( temp-bik.o_name ) .
    end.
  end.
end procedure.
procedure get-inis-from-bik-host :
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-bik       like ub.fin-bank.bik no-undo .
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo .
define variable loc-in_ as character no-undo .
define variable loc-spl as character no-undo .
define variable loc-sav as character no-undo .
define variable loc-out as character no-undo .
define variable loc-adresat as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable ii as integer no-undo .
define variable v-doc-type-1s as character no-undo .
define buffer buf_fin-bank for ub.fin-bank.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_temp_hfin-schet for temp_hfin-schet.
  do
  on error undo, return error
  :
    create temp-bik.
    assign
    temp-bik.host-code = p-host-code
    temp-bik.code-bank = p-code-bank
    temp-bik.bik       = p-bik
    .
    run bge/cbnkinis.p (
                         input parparentproc
                       , input p-format
                       , input p-bik
                       , input p-host-code
                       , input "get":U
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
      return error.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    temp-bik.f_name = substitute("&1&2\&3_&4_&5.spl"
                               ,loc-in_
                               ,loc-sav
                               ,string(day(v-today), "99")
                               ,string(month(v-today), "99")
                               ,string(year(v-today) modulo 100, "99")
                               )
    temp-bik.o_name = substitute("&1&2\&3", loc-in_, loc-spl , 'KL_to_1C.txt')
    temp-bik.adresat = loc-adresat
    .
  end.
end procedure.
