block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U.
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo init "$Workfile: cnf-cnf.p $":U.
define variable vss-archive     as character no-undo init "$Archive: adm/cnf-cnf.p $":U.
define variable vss-description as character no-undo init "Процедуры работы с таблицей конфигурации".
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
define  shared temp-table cnf no-undo
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
def  shared temp-table log-table no-undo
    field stroka       as character format "x(256)".
def  shared variable err-level as integer no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
Function reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure check-enc.
  define input  parameter p-db-num    as integer   no-undo .
  define input  parameter p-db-key    as character no-undo .
  define input  parameter p-code      as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-beg-date  as date      no-undo .
  define input  parameter p-end-date  as date      no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  if p-db-num <> 0
    and p-db-key = "":U
  then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-db-key = "unload-db":U then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-code = ""  then do:
    assign
      tmp = string( p-db-num ) + reverse (p-db-key).
    .
  end.
  else do:
    assign
      tmp = string( p-db-num )
            + trim( p-db-key )
            + reverse( trim( p-code ) )
            + reverse( trim( p-value ) )
            + reverse( string( p-beg-date, "99.99.9999" ) )
            + reverse( string( p-end-date, "99.99.9999" ) )
    .
  end.
  run pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table cnf-struct no-undo
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
      vss-include-info2 skip
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
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info2 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info2 )
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
      undo, return error substitute( "&1. Не задана метка параметра", vss-include-info2 ).
    end.
    if length( p-param-code ) > 8 then do:
      undo, return error substitute( "&1. Длина метки параметра не может превышать 8 символов (&2)", vss-include-info2, p-param-code ).
    end.
    if lookup( p-param-type, ',о,к,п':U ) = 0 then do:
      undo, return error substitute( '&1. Значение типа настройки "&2" не допустимо (&3)', vss-include-info2, p-param-type, p-param-code ).
    end.
    if lookup( p-param-type, 'к,п':U ) <> 0
      and lookup( p-attach-type, 'Нет':U ) = 0
    then do:
      undo, return error substitute( '&1. Для параметров с типом "&2" допустимы только привязки "&3" (&4)', vss-include-info2, 'к,п':U, 'Нет':U, p-param-code ).
    end.
    if p-param-name = "":U then do:
      undo, return error substitute( "&1. Не задано название параметра &2", vss-include-info2, p-param-code  ).
    end.
    if lookup( entry( 1, p-data-type ), "logical,integer,decimal,date,character":U ) = 0
      or num-entries( p-data-type ) > 2
      or ( num-entries( p-data-type ) = 2
           and entry( 2, p-data-type ) <> "list":U
         )
    then do:
      undo, return error substitute( "&1. Значение типа параметра &2 не допустимо (&3)", vss-include-info2, p-data-type, p-param-code ).
    end.
    if lookup( p-attach-type, 'Нет,Фирма,Объект':U ) = 0
    then do:
      undo, return error substitute( '&1. Значение привязки "&2" не допустимо (&3)', vss-include-info2, p-attach-type, p-param-code ).
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
      return error substitute( "&1. Не задан файл схемы конфигурации!", vss-include-info2 ).
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
    on error  undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
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
        return error substitute( "&1. Ошибка при чтении текстового файла схемы! Cтрока &1. (&2)", vss-include-info2, v-counter, error-status :get-message ( error-status :num-messages ) ).
      end.
      else do:
        if not ( t_cnf-struct.param-code begins chr(1) ) then do:
          assign
            t_cnf-struct.user-resp = decoding-user-resp( t_cnf-struct.param-code, t_cnf-struct.user-resp )
          .
          if t_cnf-struct.user-resp = "unknown":U then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2.", vss-include-info2, v-counter ).
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
            return error substitute( "&1. Ошибка параметра! Cтрока &2. &3 (&4)", vss-include-info2, v-counter, return-value, error-status :get-message ( error-status :num-messages ) ).
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable str-hdl      as handle  no-undo .
define variable db-hdl       as handle  no-undo .
define variable stand-alone  as logical no-undo .
define stream txt-file.
define stream temp-stream.
define temp-table t-cnf no-undo like cnf.
procedure init.
define input parameter  par-str-hdl as handle.
define input parameter  par-db-hdl  as handle.
if valid-handle (par-str-hdl) then
   assign str-hdl = par-str-hdl.
else
   return "2".
if valid-handle (par-db-hdl) then
   assign db-hdl      = par-db-hdl
          stand-alone = false.
   else
          stand-alone = true.
this-procedure:private-data = "Work-with-config".
return.
end procedure.
Procedure Kill.
    Delete Procedure This-procedure.
    Return.
End Procedure.
function valid-length returns logical (par-str as character, par-len as integer, par-label as character).
if length(par-str) > par-len then do:
   run log-error in str-hdl ("Превышена максимальная длина "  + string(par-len) + " для " + par-label, 2).
   return false.
end.
   return true.
end.
PROCEDURE Import.
define input parameter par-FName   as character no-undo.
define input parameter par-Clear   as logical   no-undo.
define input parameter par-UseLast as logical   no-undo.
define input parameter p-stand-alone as logical    no-undo.
define input parameter p-db-load     as character  no-undo.
define variable Fname              as character           no-undo.
define variable Count              as integer   initial 0 no-undo.
define variable v-ok               as logical             no-undo .
define variable v-last-key         as integer             no-undo .
define variable v-new-line         as integer             no-undo .
define variable v-read-chksum      as logical             no-undo .
define variable v-md5-signature-av as character           no-undo .
define variable v-md5-signature    as character           no-undo .
define variable v-db-list          as character           no-undo .
define buffer buf_sys-ctrl for ub.sys-ctrl .
define buffer buf_db for ub.db .
assign
  err-level  = 0
.
if par-fname = "" then par-fname = "config.cfg".
  assign
    par-fname = SEARCH( par-fname )
  .
IF par-fname = ? then do:
   run log-error in str-hdl ("Не найден файл конфигурации " + par-fname, 2).
   return string (err-level).
end.
else do:
  run log-error in str-hdl("Чтение конфигурационных параметров " + par-fname, 0).
end.
assign
  v-last-key         = 0
  v-read-chksum      = false
  v-md5-signature-av = "":U
  file-info:file-name = ".":U
  FName = substitute( "&1\&2-&3-&4.tmp", file-info:full-pathname, time, etime, random( 1111111 , 9999999 ) )
.
input stream txt-file from value( par-fname ).
output stream temp-stream to value(FName) .
block_read:
repeat while v-last-key <> -2
on error undo, return error return-value
:
  readkey stream txt-file pause 0.
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
input stream txt-file close.
run gbl/md5.p
  ( input  search( FName )
  ,output v-md5-signature
  ) no-error.
if error-status :error then do:
  run log-error in str-hdl
    ( input substitute( "Ошибка при подсчете контрольной суммы файла конфигурации &1", par-fname )
     ,input 2
    ).
  return "2":U.
end.
os-delete value( FName ).
assign
  v-md5-signature = sum-enc( v-md5-signature, 10 )
.
if v-md5-signature-av <> v-md5-signature then do:
  run log-error in str-hdl
    ( input substitute( "Некорректная контрольная сумма файла конфигурации &1", par-fname )
     ,input 2
    ).
  if not p-stand-alone then do:
    return "2":U.
  end.
  else do:
    message
      substitute( "Некорректная контрольная сумма файла конфигурации &1!", par-fname ) skip
      substitute( "Вы действительно хотите загрузить этот файл?" )
      view-as alert-box question BUTTONS yes-no update v-ok.
    if v-ok <> true then do:
      return "2":U.
    end.
  end.
end.
main-block:
do on error undo main-block, leave main-block:
  if not p-stand-alone then do:
    find first buf_sys-ctrl no-lock .
  end.
  For each cnf
    where par-clear
       or cnf.NotUsed = true
  :
    delete cnf .
  end.
  for each t-cnf
  :
    delete t-cnf .
  end.
  create t-cnf .
  input stream txt-file from value( par-fname ).
read-cycle:
  Repeat transaction
  on error undo read-cycle, leave main-block
  :
        count = count + 1 .
        import stream Txt-File delimiter "`" t-cnf except stts                           param-PS                       param-name                     is-changed                     NotUsed                        ErrorExist no-error.
        if error-status:error then do:
           message
             t-cnf.param-name skip
             error-status :get-message(1) skip
             return-value skip
             view-as alert-box error .
           run log-error in str-hdl ("ошибка при чтении файла конфигурации, строка " + string(count), 2).
           input stream txt-file close.
           undo, return "2":U.
        end.
        if t-cnf.param-code begins chr(1) then do:
          if not p-stand-alone then do:
            if t-cnf.param-code = chr(1) + v-md5-signature then do:
              leave read-cycle.
            end.
            else do:
              run log-error in str-hdl
                ( input substitute( "Некорректная контрольная сумма файла конфигурации &1", par-fname )
                 ,input 2
                ).
              input stream txt-file close.
              undo, return "2":U.
            end.
          end.
          else do:
            leave read-cycle.
          end.
        end.
        if not valid-length (t-cnf.param-code, 8 , "Метка параметра")     then next read-cycle.
        if not valid-length (t-cnf.obj-type,   8 , "Тип объекта")         then next read-cycle.
        if p-db-load <> "":U
          and lookup( string( t-cnf.db-num ), p-db-load ) = 0
        then do:
          next read-cycle.
        end.
        if lookup( t-cnf.conf-type, 'к,п':U ) > 0
          and not p-stand-alone
        then do:
           find first buf_db no-lock
             where buf_db.db-num = t-cnf.db-num
             .
           run check-enc in this-procedure
             ( input t-cnf.db-num
              ,input buf_db.db-key
              ,input t-cnf.param-code
              ,input t-cnf.param-value
              ,input t-cnf.beg-date
              ,input t-cnf.end-date
              ,input t-cnf.param-encoded
              ,output v-ok
             ) no-error.
           if error-status :error
             or v-ok <> true
           then do:
              if t-cnf.db-num = buf_sys-ctrl.db-num
              then do:
                run log-error in str-hdl
                  ( input substitute("Параметр &1 для БД &2 (строка &3) - ошибка кодирования (&4)", t-cnf.param-code, t-cnf.db-num, Count, t-cnf.param-encoded )
                   ,input 2
                  ).
                input stream txt-file close.
                undo, return "2".
              end.
              else do:
                run log-error in str-hdl
                  ( input substitute("Параметр &1 для БД &2 (строка &3) - ошибка кодирования (&4). Параметр игнорируется", t-cnf.param-code, t-cnf.db-num, Count, t-cnf.param-encoded )
                   ,input 1
                  ).
                next read-cycle.
              end.
           end.
        end.
        if t-cnf.beg-date = ? then do:
          assign
            t-cnf.beg-date = 01/01/1900
          .
        end.
        if t-cnf.end-date = ? then do:
          assign
            t-cnf.end-date = 01/01/9999
          .
        end.
        find first cnf
          where cnf.param-code = t-cnf.param-code and                  cnf.host-code  = t-cnf.host-code  and                  cnf.obj-type   = t-cnf.obj-type   and                  cnf.obj-code   = t-cnf.obj-code   and                  cnf.beg-date   = t-cnf.beg-date   and                  cnf.end-date   = t-cnf.end-date   and                  cnf.db-num     = t-cnf.db-num
          no-error.
        if available cnf then do:
           if cnf.param-value   <> t-cnf.param-value or
              cnf.param-encoded <> t-cnf.param-encoded or
              cnf.param-type    <> t-cnf.param-type  or
              cnf.conf-type     <> t-cnf.conf-type   or
              cnf.NotUsed       =  true
           then do:
              if par-UseLast then do:
                  if cnf.param-value <> t-cnf.param-value
                  then do:
                    run log-error in str-hdl
                      ( input substitute( "Параметр &1 для БД &2. Значение &3 заменено на &4", cnf.param-code, cnf.db-num, cnf.param-value, t-cnf.param-value )
                      ,input 0
                      ).
                  end.
                  else do:
                    if cnf.param-encoded <> t-cnf.param-encoded
                    then do:
                      run log-error in str-hdl
                        ( input substitute( "Параметр &1 для БД &2 перекодирован", cnf.param-code, cnf.db-num )
                        ,input 0
                        ).
                    end.
                    else do:
                      run log-error in str-hdl
                        ( input substitute( "Изменены атрибуты параметра &1 для БД &2 ", cnf.param-code, cnf.db-num )
                        ,input 0
                        ).
                    end.
                  end.
                  if lookup( cnf.conf-type, 'к,п':U ) > 0
                    and lookup( t-cnf.conf-type, 'к,п':U ) = 0
                    and not p-stand-alone
                  then do:
                    assign
                      cnf.ErrorExist = 2
                    .
                  end.
                  else do:
                    assign
                      cnf.ErrorExist = 0
                    .
                  end.
                  buffer-copy t-cnf to cnf no-error.
                  if error-status:error then do:
                    run log-sys-error in str-hdl ("Системная ошибка").
                    input stream txt-file close.
                    undo, return "2" .
                  end.
                  assign
                    cnf.is-changed    = true
                    cnf.NotUsed       = false
                  .
              end.
              else
                 run log-error in str-hdl
                   ( input substitute( "Параметр &1 для БД &2. Новое значение игнорируется", cnf.param-code, cnf.db-num )
                    ,input 0
                   ).
           end.
        end.
        else do:
          create cnf no-error.
          if error-status:error then do:
            run log-sys-error in str-hdl ("Системная ошибка").
            input stream txt-file close.
            undo, return "2" .
          end.
          buffer-copy t-cnf to cnf no-error.
          if error-status:error then do:
            run log-sys-error in str-hdl ("Системная ошибка").
            input stream txt-file close.
            undo, return "2" .
          end.
          assign
            cnf.is-changed  = true
          .
        end.
     release cnf no-error.
      if error-status:error then do:
        run log-sys-error in str-hdl ("Системная ошибка").
        input stream txt-file close.
        undo, return "2" .
      end.
  end.
  input stream txt-file close.
  for each cnf
  on error undo, return error return-value
  :
    run chk-param (buffer cnf) no-error.
    if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
  end.
  run chk-unref in this-procedure
    ( input ?
    , input ?
    , input ?
    , input p-stand-alone
    ) no-error.
  if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
  return if err-level > 0 then string (err-level) else "".
end.
run log-sys-error in str-hdl ("При загрузке параметров возникла непредвиденная ошибка").
input stream txt-file close.
return if err-level > 0 then string (err-level) else "".
END PROCEDURE.
procedure get-db-list-for-cnf :
  define input  parameter p-stand-alone as logical          no-undo .
  define output parameter p-db-list     as character        no-undo .
  do
  on error  undo, return error substitute( "&1 (get-db-list-for-cnf). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-db-list-for-cnf). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-db-list-for-cnf). endkey", vss-workfile )
  :
    define variable v-num-entries as integer   no-undo .
    define variable v-ind         as integer   no-undo .
    define buffer buf_cnf      for cnf .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_db       for ub.db .
    assign
      p-db-list = "":U
    .
    if p-stand-alone = true then do:
      assign
        p-db-list = "?":U
      .
      for each buf_cnf
        where buf_cnf.db-num <> ?
        break by buf_cnf.db-num
      :
        if first-of( buf_cnf.db-num ) then do:
          assign
            p-db-list = substitute( "&1&2&3", p-db-list, chr(44), buf_cnf.db-num )
          .
        end.
      end.
    end.
    else do:
      find first buf_sys-ctrl no-lock .
      if buf_sys-ctrl.db-num <> 0 then do:
        assign
          p-db-list = string( buf_sys-ctrl.db-num )
        .
      end.
      else do:
        for each buf_db no-lock
        on error undo, return error return-value
        :
          if buf_db.db-key <> "":U
            and buf_db.db-key <> ?
          then do:
            assign
              p-db-list = substitute( "&1&2&3", p-db-list, chr(44), buf_db.db-num )
            .
          end.
        end.
        assign
          p-db-list = left-trim( p-db-list, chr(44) )
        .
      end.
    end.
  end.
  return .
end procedure.
PROCEDURE chk-unref .
  define input parameter p-param-code   like cnf.param-code no-undo .
  define input parameter p-db-list      as character        no-undo .
  define input parameter p-ingnore-type as character        no-undo .
  define input parameter p-stand-alone  as logical          no-undo .
  do
  on error  undo, return error substitute( "&1 (chk-unref). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (chk-unref). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (chk-unref). endkey", vss-workfile )
  :
    define variable v-db-num      as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-ind         as integer   no-undo .
    define buffer buf_cnf        for cnf .
    define buffer buf_cnf-struct for cnf-struct .
    if p-db-list = ? then do:
      run get-db-list-for-cnf in this-procedure
        ( input p-stand-alone
        , output p-db-list
        ) .
    end.
    for each buf_cnf-struct
      where p-param-code = ?
        or ( p-param-code <> ?
              and buf_cnf-struct.param-code = p-param-code
            )
    :
      if p-ingnore-type <> ?
        and lookup( buf_cnf-struct.param-type, p-ingnore-type ) > 0
      then do:
        next.
      end.
      assign
        v-num-entries = num-entries( p-db-list, chr(44) )
      .
      do v-ind = 1 to v-num-entries
      on error undo, return error return-value
      :
        assign
          v-db-num = integer( entry( v-ind, p-db-list, chr(44) ) )
        .
        find first buf_cnf no-lock
          where buf_cnf.param-code = buf_cnf-struct.param-code
            and buf_cnf.host-code  = 0
            and buf_cnf.obj-type   = ""
            and buf_cnf.obj-code   = 0
            and buf_cnf.beg-date   = 01/01/1900
            and buf_cnf.end-date   = 01/01/9999
            and buf_cnf.db-num     = v-db-num
          no-error .
        if not available buf_cnf then do:
          create cnf.
          assign
            cnf.param-code = buf_cnf-struct.param-code
            cnf.host-code  = 0
            cnf.obj-type   = ""
            cnf.obj-code   = 0
            cnf.beg-date   = 01/01/1900
            cnf.end-date   = 01/01/9999
            cnf.db-num     = v-db-num
            cnf.NotUsed    = True
          .
          run fill-default (buffer cnf).
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE fill-default.
  define parameter buffer b-cnf for cnf.
  define buffer b2-cnf for cnf.
  find first cnf-struct
    where cnf-struct.param-code = b-cnf.param-code
    no-error.
  if not available cnf-struct then do:
    return .
  end.
  assign
    b-cnf.param-value = if b-cnf.param-value = "" then cnf-struct.default-value else b-cnf.param-value
    b-cnf.param-ps    = cnf-struct.PS
    b-cnf.param-name  = cnf-struct.param-name
    b-cnf.conf-type   = cnf-struct.param-type
  .
  run cnv-param-type in str-hdl
    ( input cnf-struct.data-type
    ) no-error.
  if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
  assign
    b-cnf.param-type = return-value
  .
  if cnf-struct.attach-type <> 'Фирма':U
    and cnf-struct.attach-type <> 'Объект':U
  then do:
    assign
      b-cnf.host-code  = 0
    .
  end.
  if cnf-struct.attach-type <> 'Объект':U  then do:
    assign
      b-cnf.obj-code   = 0
      b-cnf.obj-type   = "":U
    .
  end.
  find first b2-cnf
    where b2-cnf.param-code = b-cnf.param-code and                  b2-cnf.host-code  = b-cnf.host-code  and                  b2-cnf.obj-type   = b-cnf.obj-type   and                  b2-cnf.obj-code   = b-cnf.obj-code   and                  b2-cnf.beg-date   = b-cnf.beg-date   and                  b2-cnf.end-date   = b-cnf.end-date   and                  b2-cnf.db-num     = b-cnf.db-num
      and recid(b2-cnf) <> recid(b-cnf)
    no-error.
  if available b2-cnf then do:
    if b2-cnf.NotUsed = true then do:
        delete b2-cnf .
    end.
    else do:
        delete b-cnf .
    end.
  end.
END PROCEDURE.
PROCEDURE export-cnf.
  define input  parameter p-conf-handle   as handle    no-undo .
  define input  parameter p-stand-alone   as logical   no-undo .
  define input  parameter p-cur-recid-cnf as recid     no-undo .
  define input  parameter p-mark-cnf      as character no-undo .
  define output parameter p-qnty-cnf      as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (export-cnf). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (export-cnf). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (export-cnf). endkey", vss-workfile )
  :
    define variable v-md5-signature as character no-undo .
    define variable v-file-name     as character no-undo .
    define variable v-exp-type      as character no-undo .
    define variable v-db-list       as character no-undo .
    define variable v-sel-dbs       as character no-undo .
    define variable v-new-db-num    as integer   no-undo .
    define variable v-new-db-key    as character no-undo .
    define variable v-selected      as logical   no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-with-err      as logical   no-undo .
    define variable v-err-msg       as character no-undo .
    define buffer buf_cnf        for cnf .
    define buffer buf1_cnf       for cnf .
    define buffer buf_cnf-struct for cnf-struct .
    for each buf_cnf
      where buf_cnf.db-num  <> ?
        and buf_cnf.notused = false
      break by buf_cnf.db-num
    :
      if first-of( buf_cnf.db-num )
      then do:
        assign
          v-db-list = substitute( "&1&2&3", v-db-list, chr(44), buf_cnf.db-num )
        .
      end.
    end.
    assign
      v-db-list  = left-trim( v-db-list, chr(44) )
      p-qnty-cnf = ?
    .
    if trim( v-db-list ) = "":U then do:
      message
        substitute("Нет включенных параметров ни для одной БД") skip
        view-as alert-box information .
      return .
    end.
    assign
      v-selected = false
    .
    if p-cur-recid-cnf <> ? then do:
      find first buf_cnf
        where recid( buf_cnf ) = p-cur-recid-cnf
        no-error .
      if available buf_cnf
        and buf_cnf.db-num <> ?
        and buf_cnf.NotUsed = false
        and buf_cnf.ErrorExist = 0
      then do:
        assign
          v-selected = true
        .
      end.
    end.
    assign
      v-file-name = "config.cfg"
    .
    run adm/expi.w
      ( input p-stand-alone
      , input v-selected
      , input-output v-file-name
      , input  v-db-list
      , output v-sel-dbs
      , output v-exp-type
      , output v-new-db-num
      , output v-new-db-key
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1 (export-cnf). Ошибка при запуске процедуры выбора параметров экспорта. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) ).
    end.
    if v-exp-type = ? then do:
      return .
    end.
    for each buf_cnf
      where buf_cnf.NotUsed = true
      ,first buf_cnf-struct
      where buf_cnf-struct.param-code = buf_cnf.param-code
    on error undo, return error return-value
    :
      if lookup( buf_cnf-struct.param-type, 'к,о':U) > 0
        and lookup( string( buf_cnf.db-num ), v-sel-dbs ) > 0
      then do:
        message
          "Не все обязательные параметры включены для выбранных БД"
          "Продолжить вывод?"
          view-as alert-box buttons yes-no update v-ok.
        if v-ok = false then do:
          return .
        end.
        else do:
          leave .
        end.
      end.
    end.
    for first buf_cnf
      where buf_cnf.ErrorExist <> 0
    on error undo, return error return-value
    :
      message
        "В наборе есть параметры с ошибками!" skip
        "Вывести их в файл?" skip(1)
        view-as alert-box buttons yes-no-cancel update v-with-err .
      if v-with-err = ? then do:
        return .
      end.
    end.
    assign
      p-qnty-cnf = 0
    .
    run waitfram-show in this-procedure ("Экспорт конфигурации").
    for each t-cnf
    :
      delete t-cnf .
    end.
    create t-cnf .
    output stream txt-file to value(v-file-name).
    block_exp:
    for each buf_cnf
      where buf_cnf.db-num <> ?
        and buf_cnf.NotUsed = false
      ,first buf_cnf-struct
      where buf_cnf-struct.param-code = buf_cnf.param-code
    on error  undo, retry block_exp
    on stop   undo, retry block_exp
    on endkey undo, retry block_exp
    :
      if retry then do:
        assign
          v-err-msg = substitute( "&1 (export-cnf). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        .
        output stream txt-file close.
        return error v-err-msg .
      end.
      else do:
        if v-with-err = false
          and buf_cnf.ErrorExist <> 0
        then do:
          next block_exp .
        end.
        if ( lookup( string( buf_cnf.db-num ), v-sel-dbs ) > 0
            and ( v-exp-type = "all":U
                  or ( v-exp-type = "mark":U    and lookup(string( recid( buf_cnf ) ), p-mark-cnf) > 0 )
                  or ( v-exp-type = "all-protect":U and lookup( buf_cnf-struct.param-type, 'к,п':U) > 0 )
                  or ( v-exp-type = "all-mandatory":U and lookup( buf_cnf-struct.param-type, 'к,о':U) > 0 )
                )
          )
          or ( v-exp-type = "curr":U
                and recid( buf_cnf ) = p-cur-recid-cnf
              )
        then do:
          buffer-copy buf_cnf to t-cnf .
          if v-new-db-num <> ? then do:
            assign
              t-cnf.db-num = v-new-db-num
              t-cnf.db-key        = v-new-db-key
              t-cnf.param-encoded = "":U
            .
          end.
          if p-stand-alone = true
            and lookup( t-cnf.conf-type, 'к,п':U ) > 0
          then do:
            run conf-enc in p-conf-handle
              ( input  t-cnf.db-num
              , input  t-cnf.db-key
              , input  t-cnf.param-code
              , input  t-cnf.param-value
              , input  t-cnf.beg-date
              , input  t-cnf.end-date
              , output t-cnf.param-encoded
              ) no-error.
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute("Ошибка кодировки параметра &1 для БД &2", t-cnf.param-code, t-cnf.db-num ) skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo block_exp, retry block_exp .
            end.
          end.
          export stream txt-file delimiter "`" t-cnf except stts                           param-PS                       param-name                     is-changed                     NotUsed                        ErrorExist.
          assign
            p-qnty-cnf = p-qnty-cnf + 1
          .
        end.
      end.
    end.
    output stream txt-file close.
    delete t-cnf .
    assign
      file-info:file-name = search( v-file-name )
      v-file-name         = file-info:full-pathname
    .
    run gbl/md5.p
      ( input  v-file-name
      , output v-md5-signature
      ) no-error.
    if error-status :error
      or trim( v-md5-signature ) = "":U
    then do:
      return error substitute( "&1 (export-cnf). Ошибка при подсчете контрольной суммы (&2) файла конфигурации!. &3&4&5"
                               , vss-workfile
                               , v-md5-signature
                               , return-value
                               , chr(10)
                               , error-status :get-message ( 1 )
                             ).
    end.
    output stream txt-file to value(v-file-name) append.
    put stream txt-file unformatted substitute( "&1&2", chr(1), sum-enc( v-md5-signature, 10 ) ) skip.
    output stream txt-file close.
    run waitfram-hide in this-procedure .
  end.
end procedure.
PROCEDURE chk-param.
  define parameter buffer par-cnf for cnf.
  assign
    err-level = par-cnf.ErrorExist
  .
  find first cnf-struct
    where cnf-struct.param-code = par-cnf.param-code
    no-error.
  if not available cnf-struct then do:
    assign
      par-cnf.NotUsed    = true
      par-cnf.ErrorExist = 2
    .
    run log-error in str-hdl ("параметр " + par-cnf.param-code + " не допустим в текущей схеме", 1).
    return.
  end.
  assign
    par-cnf.param-name = cnf-struct.param-name
    par-cnf.param-PS   = cnf-struct.PS
  .
  if stand-alone = true then do:
    assign
      par-cnf.conf-type = cnf-struct.param-type
    .
  end.
  if cnf-struct.param-type <> par-cnf.conf-type then do:
    run log-error in str-hdl ("параметр " + par-cnf.param-code + " имеет тип настройки (" +
                              par-cnf.conf-type + "), несоответствующий схеме (" + cnf-struct.param-type + ")", 2).
  end.
  run cnv-param-type in str-hdl (cnf-struct.data-type).
  if par-cnf.param-type <> return-value then do:
    run log-error in str-hdl ("параметр " + par-cnf.param-code + " имеет тип параметра (" +
                                par-cnf.param-type + "), несоответствующий схеме (" + cnf-struct.data-type + ")", 2).
  end.
  case cnf-struct.attach-type:
    when 'Фирма':U then do:
        if par-cnf.host-code <> 0 and not stand-alone then do:
          run chk-company in db-hdl (par-cnf.host-code) no-error.
          if return-value <> "" then do:
              run log-error in str-hdl ("параметр "  + par-cnf.param-code + " имеет неправильный код фирмы "
                                        + string(par-cnf.host-code), 1).
              if can-find (first cnf where cnf.param-code  = par-cnf.param-code and
                                            cnf.host-code   = 0                  and
                                            recid (cnf)    <> recid (par-cnf))  then do:
                run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                            + string(par-cnf.host-code) + " удален", 1).
                return.
              end.
              else do:
                par-cnf.host-code = 0 .
                run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                            + string(par-cnf.host-code) + " привязка отменена", 1).
              end.
          end.
        end.
        if (par-cnf.obj-code <> 0   or
            par-cnf.obj-type <> "" ) then do:
              run log-error in str-hdl ("параметр "  + par-cnf.param-code + " не может иметь привязки к объекту "
                                        + par-cnf.obj-type + " " + string (par-cnf.obj-code), 1).
              assign par-cnf.is-changed  = true
                      par-cnf.obj-code = 0
                      par-cnf.obj-type = "".
        end.
    end.
    when 'Объект':U then do:
        define variable obj-host-code like par-cnf.host-code no-undo.
        if not stand-alone then do:
            if par-cnf.host-code <> 0 then do:
              run chk-company in db-hdl (par-cnf.host-code) no-error.
              if return-value <> "" then do:
                  run log-error in str-hdl ("параметр "  + par-cnf.param-code + " имеет неправильный код фирмы "
                                            + string(par-cnf.host-code), 1).
                  if can-find (first cnf where cnf.param-code  = par-cnf.param-code and
                                                cnf.host-code   = 0                  and
                                                cnf.obj-type    = ""                 and
                                                cnf.Obj-code    = 0                  and
                                                recid (cnf)    <> recid (par-cnf))  then do:
                    run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                                + string(par-cnf.host-code) + " удален", 1).
                    delete par-cnf.
                    return.
                  end.
                  else do:
                    assign
                      par-cnf.host-code = 0
                      par-cnf.obj-type  = ""
                      par-cnf.obj-code  = 0 .
                    run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                                + string(par-cnf.host-code) + " привязка отменена", 1).
                  end.
              end.
            end.
            if par-cnf.obj-code  <> 0 then do:
              run chk-host-code in db-hdl (par-cnf.obj-type, par-cnf.obj-code, output obj-host-code).
              if obj-host-code      = ?              or
                par-cnf.host-code <> obj-host-code   then do:
                run log-error in str-hdl ("параметр "  + string (par-cnf.param-code) + " код фирмы " + string(par-cnf.host-code)
                                            + " номер объекта " + string(par-cnf.obj-code)
                                            + " тип объекта " + string(par-cnf.obj-type)
                                            + " имеет несоответствие объекта и фирмы ", 1).
                if can-find (first cnf where cnf.param-code  = par-cnf.param-code and
                                            cnf.host-code   = par-cnf.host-code  and
                                            cnf.obj-type    = ""                 and
                                            cnf.Obj-code    = 0                  and
                                            recid (cnf)    <> recid (par-cnf))  then do:
                  run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы " + string(par-cnf.host-code)
                                              + " номер объекта " + string(par-cnf.obj-code)
                                              + " тип объекта " + string(par-cnf.obj-type)
                                              + " удален", 1).
                  delete par-cnf.
                  return.
                end.
                else do:
                  assign
                    par-cnf.obj-type  = ""
                    par-cnf.obj-code  = 0 .
                  run log-error in str-hdl ("параметр "  + par-cnf.param-code + " код фирмы "
                                            + string(par-cnf.host-code) + " привязка к объекту отменена", 1).
                end.
              end.
            end.
        end.
    end.
    otherwise do:
        if par-cnf.host-code <> 0 then do:
              run log-error in str-hdl ("параметр "  + string(par-cnf.param-code) + " не может иметь привязки к фирме "
                                        + string(par-cnf.host-code), 1).
              assign par-cnf.is-changed    = true
                      par-cnf.host-code = 0 .
        end.
        if par-cnf.obj-code <> 0   or
          par-cnf.obj-type <> ""  then do:
              run log-error in str-hdl ("параметр "  + string(par-cnf.param-code) + " не может иметь привязки к объекту "
                                        + par-cnf.obj-type + " " + string (par-cnf.obj-code), 1).
              assign par-cnf.is-changed   = true
                      par-cnf.obj-code = 0
                      par-cnf.obj-type = "".
        end.
    end.
  end case.
  if cnf-struct.list-value <> "" then do:
    if lookup(par-cnf.param-value, cnf-struct.list-value) = 0 then do:
        run log-error in str-hdl ("параметр "  + string(par-cnf.param-code) + " имеет недопустимое значение "
                                  + par-cnf.param-value + "(из " + cnf-struct.list-value + ")", 1).
    end.
  end.
  par-cnf.ErrorExist = maximum (err-level, par-cnf.ErrorExist) .
END PROCEDURE.
