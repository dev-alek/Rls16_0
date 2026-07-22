block-level on error undo, throw.
define input  parameter p-action as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: checkcnf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/checkcnf.p $":U .
define variable vss-description as character no-undo init "Проверка наличия обязательных параметров, а так же загрузка любых параметров конфигурации системы".
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
define new shared temp-table cnf no-undo
    field param-code    as character   format "x(8)"        column-label "Код"                               field param-type    as character                        column-label "Тип"                               field param-value   as character   format "x(250)"      column-label "Значение"                          field param-encoded as character                        column-label "Кодированное значение"             field host-code     as integer                          column-label "Фирма"                             field obj-type      as character                        column-label "Тип объекта"                       field obj-code      as integer     format ">>>>>>"      column-label "Код объекта"                       field conf-type     as character                        column-label "Кодировка"                         field beg-date      as date                             column-label "Начало действия параметра"         field end-date      as date                             column-label "Окончание действия параметра"      field db-num        as integer     format ">>>>>"       column-label "БД"                                field stts          as integer                          column-label "Статус"
    field db-key        as character   format "x(12)"       column-label "Ключ БД"
    field param-PS      as character   format "x(40)"       column-label "PS"
    field param-name    as character   format "x(30)"       column-label "Название"
    field is-changed    as logical initial false            column-label "Изменен"
    field NotUsed       as logical initial False            column-label "Выключен"
    field ErrorExist    as integer initial 0  format ">>"   column-label "Уровень ошибки"
    index pi
      is unique
      param-code
      host-code
      obj-type
      obj-code
      beg-date
      end-date
      db-num
    index db-num
      db-num
    index db-key
      db-key
    index par-name
      is word-index
      param-name
    index par-value
      is word-index
      param-value
 .
def new shared temp-table log-table no-undo
    field stroka       as character format "x(256)".
def new shared variable err-level as integer no-undo.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table cnf-struct no-undo
  field param-code    as character
  field param-type    as character
  field data-type     as character
  field param-name    as character
  field attach-type   as character
  field list-value    as character
  field default-value as character
  field PS            as character
  field param-group   as character
  field user-resp     as character
  index by-code is unique param-code
.
define temp-table t_cnf-struct no-undo like cnf-struct .
define stream TxtStream.
define stream temp-stream .
function coding-user-resp returns character
  ( input p-param-code as character
   ,input p-user-resp  as character
  )
:
  return encode( p-param-code + p-user-resp ) .
end function.
function decoding-user-resp returns character
  ( input p-param-code as character
   ,input p-code-usr   as character
  )
:
  define variable v-ind         as integer   no-undo .
  define variable v-user-list   as character no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-user-resp   as character no-undo .
  assign
    v-user-list   = "Бахтадзе,Булгаков,Белоусов,Гюнтнер,Исаков,Перваков,Суслов,Уханов,Чернова,Кочетков,Степанов,Хныкин,Гридчина,Шальнев,Сливенко,Харитонов,Кирюхин,Морозов"
    v-num-entries = num-entries( v-user-list )
    v-user-resp   = "":U
  .
  block_do:
  do v-ind = 1 to v-num-entries :
    if encode( p-param-code + entry( v-ind, v-user-list ) ) = p-code-usr then do:
      assign
        v-user-resp = entry( v-ind, v-user-list )
      .
      leave block_do.
    end.
  end.
  if v-user-resp = "":U then do:
    message
      vss-include-info1 skip
      substitute( "Невозможно распознать ответственного за параметр <&1>!",  p-param-code) skip
      substitute( "Возможно его нет в списке." ) skip
      view-as alert-box error
    .
    return "unknown":U.
  end.
  else do:
    return v-user-resp .
  end.
end function.
function sum-enc returns character (str as character, num-rev as integer).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      if rev_incl_i <= num-rev
        or rev_incl_l - rev_incl_i < num-rev
      then do:
        assign
          rev_incl_s = rev_incl_s + substr(str, rev_incl_l - rev_incl_i + 1, 1)
        .
      end.
      else do:
        assign
          rev_incl_s = rev_incl_s + substr(str, rev_incl_i, 1)
        .
      end.
   end.
   return rev_incl_s.
end.
procedure check-cfg :
  define input-output parameter p-param-code    as character no-undo .
  define input-output parameter p-param-type    as character no-undo .
  define input-output parameter p-data-type     as character no-undo .
  define input-output parameter p-param-name    as character no-undo .
  define input-output parameter p-attach-type   as character no-undo .
  define input-output parameter p-list-value    as character no-undo .
  define input-output parameter p-default-value as character no-undo .
  define input-output parameter p-param-PS      as character no-undo .
  define input-output parameter p-param-group   as character no-undo .
  define input-output parameter p-user-resp     as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info1 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info1 )
  :
    define variable v-ind as character no-undo .
    assign
      p-param-code    = trim( p-param-code )
      p-param-type    = trim( p-param-type )
      p-data-type     = trim( p-data-type )
      p-param-name    = trim( p-param-name )
      p-attach-type   = trim( p-attach-type )
      p-list-value    = trim( p-list-value )
      p-default-value = trim( p-default-value )
      p-param-PS      = trim( p-param-PS )
      p-param-group   = trim( p-param-group )
      p-user-resp     = trim( p-user-resp )
    .
    if p-param-code = "":U then do:
      undo, return error substitute( "&1. Не задана метка параметра", vss-include-info1 ).
    end.
    if length( p-param-code ) > 8 then do:
      undo, return error substitute( "&1. Длина метки параметра не может превышать 8 символов (&2)", vss-include-info1, p-param-code ).
    end.
    if lookup( p-param-type, ',о,к,п':U ) = 0 then do:
      undo, return error substitute( '&1. Значение типа настройки "&2" не допустимо (&3)', vss-include-info1, p-param-type, p-param-code ).
    end.
    if lookup( p-param-type, 'к,п':U ) <> 0
      and lookup( p-attach-type, 'Нет':U ) = 0
    then do:
      undo, return error substitute( '&1. Для параметров с типом "&2" допустимы только привязки "&3" (&4)', vss-include-info1, 'к,п':U, 'Нет':U, p-param-code ).
    end.
    if p-param-name = "":U then do:
      undo, return error substitute( "&1. Не задано название параметра &2", vss-include-info1, p-param-code  ).
    end.
    if lookup( entry( 1, p-data-type ), "logical,integer,decimal,date,character":U ) = 0
      or num-entries( p-data-type ) > 2
      or ( num-entries( p-data-type ) = 2
           and entry( 2, p-data-type ) <> "list":U
         )
    then do:
      undo, return error substitute( "&1. Значение типа параметра &2 не допустимо (&3)", vss-include-info1, p-data-type, p-param-code ).
    end.
    if lookup( p-attach-type, 'Нет,Фирма,Объект':U ) = 0
    then do:
      undo, return error substitute( '&1. Значение привязки "&2" не допустимо (&3)', vss-include-info1, p-attach-type, p-param-code ).
    end.
  end.
  return.
end procedure.
procedure fill-cnf-struct :
  define input parameter p-file-name as character no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-file-name as character no-undo .
    define variable v-counter as integer   no-undo .
    define variable v-temp-fname       as character           no-undo.
    define variable v-last-key         as integer             no-undo .
    define variable v-new-line         as integer             no-undo .
    define variable v-read-chksum      as logical             no-undo .
    define variable v-md5-signature-av as character           no-undo .
    define variable v-md5-signature    as character           no-undo .
    define frame inf-cfg
      v-counter label "Просмотрено"
      with view-as dialog-box side-labels 1 columns three-d title ""
    .
    assign
      v-file-name = search( p-file-name )
    .
    if v-file-name = ""
      or v-file-name = ?
    then do:
      return error substitute( "&1. Не задан файл схемы конфигурации!", vss-include-info1 ).
    end.
    assign
      v-last-key         = 0
      v-read-chksum      = false
      v-md5-signature-av = "":U
      file-info:file-name = ".":U
      v-temp-fname = substitute( "&1\&2-&3-&4.tmp", file-info:full-pathname, time, etime, random( 1111111 , 9999999 ) )
    .
    input stream TxtStream from value( v-file-name ).
    output stream temp-stream to value(v-temp-fname) .
    block_read:
    repeat while v-last-key <> -2
    on error undo, return error
    :
      readkey stream TxtStream pause 0.
      assign
        v-last-key = lastkey
      .
      if chr( v-last-key ) = chr(1) then do:
        assign
          v-read-chksum = true
        .
      end.
      else do:
        if v-read-chksum = true then do:
          if v-last-key = 13 then do:
            leave block_read.
          end.
          else do:
            assign
              v-md5-signature-av = v-md5-signature-av + chr( v-last-key )
            .
          end.
        end.
        else do:
          if v-last-key = 13 then do:
            put stream temp-stream skip(v-new-line).
            assign
              v-new-line = 1
            .
          end.
          else do:
            put stream temp-stream unformatted chr( v-last-key ).
            assign
              v-new-line = 0
            .
          end.
        end.
      end.
    end.
    output stream temp-stream close.
    input stream TxtStream close.
    run gbl/md5.p
      ( input  search( v-temp-fname )
       ,output v-md5-signature
      ) no-error.
    if error-status :error then do:
      return error substitute("Ошибка при подсчете контрольной суммы текстового файла схемы &1", v-file-name ) .
    end.
    os-delete value( v-temp-fname ).
    assign
      v-md5-signature = sum-enc( v-md5-signature, 8 )
    .
    if v-md5-signature-av <> v-md5-signature then do:
      return error substitute( "Некорректная контрольная сумма текстового файла схемы &1", v-file-name ) .
    end.
    input stream TxtStream from value( v-file-name ).
    assign
      v-counter = 0
    .
    assign
      frame inf-cfg:title = "Чтение параметров конфигурации"
    .
    view frame inf-cfg.
    for each t_cnf-struct:
      delete t_cnf-struct.
    end.
    create t_cnf-struct no-error.
    read-cycle:
    repeat transaction
    on error  undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-counter = v-counter + 1
      .
      if ( v-counter modulo 10 ) = 0 then do:
        display
          v-counter
          with frame inf-cfg.
      end.
      import stream TxtStream delimiter '`':U t_cnf-struct.param-code t_cnf-struct.param-type t_cnf-struct.data-type t_cnf-struct.param-name t_cnf-struct.attach-type t_cnf-struct.list-value t_cnf-struct.default-value t_cnf-struct.PS t_cnf-struct.param-group t_cnf-struct.user-resp no-error.
      if error-status:error then do:
        return error substitute( "&1. Ошибка при чтении текстового файла схемы! Cтрока &1. (&2)", vss-include-info1, v-counter, error-status :get-message ( error-status :num-messages ) ).
      end.
      else do:
        if not ( t_cnf-struct.param-code begins chr(1) ) then do:
          assign
            t_cnf-struct.user-resp = decoding-user-resp( t_cnf-struct.param-code, t_cnf-struct.user-resp )
          .
          if t_cnf-struct.user-resp = "unknown":U then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2.", vss-include-info1, v-counter ).
          end.
          run check-cfg in this-procedure
            ( input-output t_cnf-struct.param-code
            ,input-output t_cnf-struct.param-type
            ,input-output t_cnf-struct.data-type
            ,input-output t_cnf-struct.param-name
            ,input-output t_cnf-struct.attach-type
            ,input-output t_cnf-struct.list-value
            ,input-output t_cnf-struct.default-value
            ,input-output t_cnf-struct.PS
            ,input-output t_cnf-struct.param-group
            ,input-output t_cnf-struct.user-resp
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2. &3 (&4)", vss-include-info1, v-counter, return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
          else do:
            find first cnf-struct
              where cnf-struct.param-code = t_cnf-struct.param-code
              no-error
            .
            if not available cnf-struct then do:
              create cnf-struct .
            end.
            buffer-copy t_cnf-struct to cnf-struct .
          end.
        end.
      end.
    end.
    delete t_cnf-struct no-error.
    hide frame inf-cfg.
    input stream TxtStream close.
  end.
  return.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new  shared variable g#auto as logical no-undo.
define new  shared variable g#news as logical no-undo.
define new  shared variable g#oxml as logical no-undo.
define new  shared variable g#esys as logical no-undo.
define new  shared variable g#news-source-db as integer no-undo.
define new  shared variable g#esys-source-esys as integer no-undo.
define new  shared variable g#db-num as integer   no-undo .
define new  shared variable g#userid as character no-undo .
define new  shared variable g#passwd as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info2, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info2 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info2 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
do
on error  undo, return error
:
  define variable v-ind            as integer       no-undo .
  define variable v-start-time     as int64         no-undo .
  define variable v-current-time   as character     no-undo .
  define variable w-login          as widget-handle no-undo.
  define buffer buf_config  for ub.config .
  define buffer buf1_config for ub.config .
  define stream txt-file .
  define stream necescnf .
  define stream del-cnf .
  define variable counter       as integer                   no-undo .
  define variable p-value       like ub.config.param-value      no-undo .
  define variable p-type        like ub.config.param-type       no-undo .
  define variable err-cnf-param as char                      no-undo .
  define variable err-log       as logical                   no-undo .
  define variable err-code      as integer init -1           no-undo .
  define variable load-cfg-now  as logical init TRUE         no-undo .
  define variable fname-txt     as char                      no-undo .
  define variable fname-cfg     as char    init "config.cfg" no-undo .
  define variable str-hdl       as handle                    no-undo .
  define variable v-curr-db          as integer   no-undo .
  define variable v-check-db-num     as integer   no-undo .
  define variable v-check-user-id    as character no-undo .
  define variable v-check-user-admin as logical   no-undo .
  define variable v-get-ro_read-only as logical   no-undo .
  define frame a
    v-ind           format ">>>>>>>9"   label "Обработано параметров" skip
    v-current-time  format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Проверка конфигурационных параметров"
    .
  if p-action <> "cfg-check":U
    and p-action <> "cfg-load":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка задания входных параметров.") skip
      substitute("action = &1", p-action ) skip
      view-as alert-box error .
    return error.
  end.
  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-check-db-num
  ,output v-check-user-id
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущей базы и текущего пользователя" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-curr-db = v-check-db-num
  .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run user-adm in g#library2
  (input  v-check-db-num
  ,input  v-check-user-id
  ,output v-check-user-admin
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении является ли пользователем администратор" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  create widget-pool .
  create window w-login
    assign
      title              = "Проверка параметров"
      column             = 31.5
      row                = 9
      height             = 2.0
      width              = 30
      resize             = false
      scroll-bars        = false
      status-area        = false
      three-d            = true
      message-area       = false
      sensitive          = true
      visible            = true
      .
  assign
    current-window   = w-login
    g#auto           = false
    g#news           = false
    g#news-source-db = -1
    g#db-num         = v-curr-db
    g#userid         = v-check-user-id
    g#passwd         = ""
  .
  if p-action <> "cfg-load":U then do:
    assign
      v-start-time = etime
    .
    view frame a.
    display
      v-ind
      v-current-time
      with frame a .
    run adm/cnf-str.p persistent set str-hdl no-error.
    if not valid-handle (str-hdl)  then do:
      message "Ошибка при попытке инициализировать работу со схемой конфигурации" view-as alert-box error.
      return error.
    end.
    for each cnf-struct
    on error undo, return error
    :
      delete cnf-struct.
    end.
    os-delete value( "necescnf.txt":U ) .
    assign
      fname-txt = "cmp/mold_db.sch"
    .
    if search( fname-txt ) = ? then do:
      message "Не найден файл схемы настроек" + chr(32) + fname-txt view-as alert-box error.
      return error.
    end.
    assign
      fname-txt = search( fname-txt )
    .
  end.
  assign
    err-code = -1
    load-cfg-now = true
    .
  do while err-code <> 0 and load-cfg-now = true
  :
    assign
      v-ind         = 0
      err-cnf-param = ""
    .
    if p-action <> "cfg-load":U then do:
      run fill-cnf-struct in this-procedure
        ( input fname-txt
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при чтении текстового файла схемы!" ) skip
          return-value skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return error.
      end.
      for each cnf-struct no-lock
      on error undo, return error
      :
        assign
          v-ind = v-ind + 1
        .
        if v-ind mod 10 = 0 then do:
          assign
            v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
          .
          display
            v-ind
            v-current-time
            with frame a.
        end.
        assign
          err-log = false
        .
        find first buf_config no-lock
          where buf_config.param-code = cnf-struct.param-code
            and buf_config.db-num     = v-curr-db
          no-error .
        if available buf_config then do:
          run cnv-param-type in str-hdl (cnf-struct.data-type).
          assign
            cnf-struct.data-type = return-value
          .
          if lookup(cnf-struct.param-type, 'к,п':U) > 0
          then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf_config.param-code
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output p-value
  ,output p-type
  ) no-error .
            if error-status :error
            or buf_config.param-type <> cnf-struct.data-type
            or buf_config.conf-type  <> cnf-struct.param-type
            then do:
              assign
                err-log = true
              .
            end.
          end.
          for each buf1_config no-lock
              where buf1_config.param-code = cnf-struct.param-code
                and buf1_config.db-num     = v-curr-db
          on error undo, return error
          :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf1_config.param-code
  ,input  buf1_config.host-code
  ,input  buf1_config.obj-type
  ,input  buf1_config.obj-code
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output p-value
  ,output p-type
  ) no-error .
            if error-status:error
              or buf1_config.param-type <> cnf-struct.data-type
              or buf1_config.conf-type  <> cnf-struct.param-type
            then do:
              assign
                err-log = true
              .
            end.
          end.
        end.
        else do:
          if lookup(cnf-struct.param-type, 'к,о':U) > 0
          then do:
            assign
              err-log = true
            .
          end.
        end.
        if err-log then do:
          run write-err-conf-list in this-procedure
            ( input cnf-struct.param-code
            ,input v-curr-db
            ,input cnf-struct.param-type
            ,input err-cnf-param
            ).
          assign
            err-cnf-param = err-cnf-param + " ":U + cnf-struct.param-code
            .
        end.
      end.
      for each cnf-struct
      on error undo, return error
      :
        delete cnf-struct.
      end.
    end.
    if v-get-ro_read-only = false then do:
      if p-action = "cfg-load":U then do:
        assign
          load-cfg-now = true
        .
      end.
      else do:
        if trim( err-cnf-param ) <> "":U then do:
          if v-check-user-admin <> true then do:
            message
              "Требуется загрузка параметров конфигурации системы!" skip
              "Список требуемых параметров выведен в файл" chr(32) "necescnf.txt":U skip
              "Обратитесь к администратору системы."
              view-as alert-box error.
            assign
              err-code     = 3
              load-cfg-now = false
            .
          end.
          else do:
            message
              "Требуется загрузка параметров конфигурации системы!" skip
              "Список требуемых параметров выведен в файл" chr(32) "necescnf.txt":U skip
              "Список удаленных параметров выведен в файл" chr(32) "del-cnf.txt":U skip
              "Загрузить параметры сейчас?" skip
              view-as alert-box question buttons yes-no update load-cfg-now.
            if load-cfg-now <> true then do:
              assign
                err-code = 3
              .
            end.
          end.
        end.
        else do:
          assign
            err-code = 0
            load-cfg-now = false
          .
        end.
      end.
    end.
    else do:
      assign
        load-cfg-now = false
      .
      if trim( err-cnf-param ) <> "":U then do:
        assign
          err-code = 3
        .
        message
          "В ОСНОВНУЮ БД требуется загрузить параметры конфигурации системы!" skip
          "Список требуемых параметров выведен в файл" chr(32) "necescnf.txt":U skip
          "Обратитесь к администратору системы."
          view-as alert-box error.
      end.
      else do:
        assign
          err-code = 0
        .
      end.
    end.
    if load-cfg-now = true then do:
      run adm/wloadcfg.w (input-output fname-cfg).
      if fname-cfg <> ""
        and fname-cfg <> ?
        and fname-cfg <> "?"
      then do:
        run adm/loadcfg.p (fname-cfg, "", "", yes, no, yes, 2, output err-code) no-error.
        if error-status:error then do:
          message error-status:get-message(1).
        end.
        if err-code = 0 then do:
          assign
            err-code = -1
          .
          message
            "Параметры загружены успешно"
            view-as alert-box information .
        end.
        else do:
          message
            "Параметры не загружены!" skip
            "Код завершения: " err-code
             view-as alert-box error .
        end.
      end.
      else do:
        message
          "Параметры не загружены!" skip
          "Не задан файл конфигурации." skip
          view-as alert-box error .
        assign
          err-code     = 1
          load-cfg-now = false
          .
      end.
    end.
    if p-action = "cfg-load":U then do:
      assign
        err-code     = 0
        load-cfg-now = false
      .
    end.
  end.
  if p-action <> "cfg-load":U then do:
    run kill1 in str-hdl .
  end.
  hide frame a .
  delete object w-login .
end.
if err-code <> 0 then do:
  return error.
end.
else do:
  return.
end.
procedure write-err-conf-list :
  define input parameter par-code      like ub.config.param-code no-undo .
  define input parameter p-db-num      like ub.config.db-num     no-undo .
  define input parameter cnf-type      like ub.config.conf-type  no-undo .
  define input parameter err-cnf-param as   character            no-undo .
  do transaction
  on error undo, return error
  :
    define variable p-code      like ub.config.param-code no-undo .
    define variable list-p-code as   character            no-undo .
    define variable ind         as   integer              no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_db       for ub.db .
    define buffer buf_config   for ub.config .
    assign
      list-p-code = par-code
    .
    do ind = 1 to num-entries( list-p-code )
    on error undo, return error
    :
      assign
        p-code = entry( ind, list-p-code )
      .
      if v-check-user-admin = true
      then do:
        output stream del-cnf to "del-cnf.txt":U page-size 0 append.
        for each buf_config exclusive-lock
          where buf_config.param-code = p-code
            and buf_config.db-num     = p-db-num
        on error undo, return error
        :
          if err-cnf-param = "":U then do:
            put stream del-cnf unformatted
              string("Дата удаления:" + " ":U + cur-time-string() )
              skip
            .
          end.
          export stream del-cnf buf_config .
          assign
            buf_config.stts = -1
          .
          delete buf_config .
        end.
        output stream del-cnf close.
      end.
      if err-cnf-param = "":U then do:
        output stream necescnf to "necescnf.txt":U.
        find first buf_sys-ctrl no-lock.
        find first buf_db no-lock
            where buf_db.db-num = buf_sys-ctrl.db-num
            .
        put stream necescnf unformatted
          string("Дата:" + " ":U + cur-time-string() )
          skip
          string("db: ":U + string(buf_db.db-num) + " db-name: ":U + buf_db.db-name + " db-key: ":U + buf_db.db-key )
          skip
        .
      end.
      else do:
        output stream necescnf to "necescnf.txt":U page-size 0 append.
      end.
      put stream necescnf unformatted p-code space(1) cnf-type skip.
      output stream necescnf close.
    end.
  end.
end procedure.
