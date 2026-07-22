block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U.
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo init "$Workfile: cnf-db.p $":U.
define variable vss-archive     as character no-undo init "$Archive: adm/cnf-db.p $":U.
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      vss-include-info0 skip
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
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info0 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info0 )
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
      undo, return error substitute( "&1. Не задана метка параметра", vss-include-info0 ).
    end.
    if length( p-param-code ) > 8 then do:
      undo, return error substitute( "&1. Длина метки параметра не может превышать 8 символов (&2)", vss-include-info0, p-param-code ).
    end.
    if lookup( p-param-type, ',о,к,п':U ) = 0 then do:
      undo, return error substitute( '&1. Значение типа настройки "&2" не допустимо (&3)', vss-include-info0, p-param-type, p-param-code ).
    end.
    if lookup( p-param-type, 'к,п':U ) <> 0
      and lookup( p-attach-type, 'Нет':U ) = 0
    then do:
      undo, return error substitute( '&1. Для параметров с типом "&2" допустимы только привязки "&3" (&4)', vss-include-info0, 'к,п':U, 'Нет':U, p-param-code ).
    end.
    if p-param-name = "":U then do:
      undo, return error substitute( "&1. Не задано название параметра &2", vss-include-info0, p-param-code  ).
    end.
    if lookup( entry( 1, p-data-type ), "logical,integer,decimal,date,character":U ) = 0
      or num-entries( p-data-type ) > 2
      or ( num-entries( p-data-type ) = 2
           and entry( 2, p-data-type ) <> "list":U
         )
    then do:
      undo, return error substitute( "&1. Значение типа параметра &2 не допустимо (&3)", vss-include-info0, p-data-type, p-param-code ).
    end.
    if lookup( p-attach-type, 'Нет,Фирма,Объект':U ) = 0
    then do:
      undo, return error substitute( '&1. Значение привязки "&2" не допустимо (&3)', vss-include-info0, p-attach-type, p-param-code ).
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
      return error substitute( "&1. Не задан файл схемы конфигурации!", vss-include-info0 ).
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
    on error  undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
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
        return error substitute( "&1. Ошибка при чтении текстового файла схемы! Cтрока &1. (&2)", vss-include-info0, v-counter, error-status :get-message ( error-status :num-messages ) ).
      end.
      else do:
        if not ( t_cnf-struct.param-code begins chr(1) ) then do:
          assign
            t_cnf-struct.user-resp = decoding-user-resp( t_cnf-struct.param-code, t_cnf-struct.user-resp )
          .
          if t_cnf-struct.user-resp = "unknown":U then do:
            return error substitute( "&1. Ошибка параметра! Cтрока &2.", vss-include-info0, v-counter ).
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
            return error substitute( "&1. Ошибка параметра! Cтрока &2. &3 (&4)", vss-include-info0, v-counter, return-value, error-status :get-message ( error-status :num-messages ) ).
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable str-hdl as handle  no-undo .
define variable cnf-hdl as handle  no-undo .
procedure init :
  define input parameter  par-str-hdl as handle.
  do
  on error undo, return error return-value
  :
    if valid-handle (par-str-hdl)
    then do:
      assign
        str-hdl = par-str-hdl
      .
    end.
    else do:
      return "2" .
    end.
    return.
  end.
end procedure.
procedure kill :
  do
  on error undo, return error return-value
  :
    delete procedure this-procedure.
    return.
  end.
end procedure.
procedure loaddb :
  do
  on error undo, return error return-value
  :
    define buffer buf_db       for ub.db .
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define variable v-ok      as logical   no-undo .
    define variable MaxErr    as integer   no-undo .
    define variable v-db-list as character no-undo .
    if not valid-handle (cnf-hdl)
    then do:
      run find-library in this-procedure no-error.
      if not valid-handle (cnf-hdl)
      then do:
          run log-error in str-hdl ("Ошибка при загрузки в памяти библиотек", 2) no-error.
          return ("2") .
      end.
    end.
    read-cycle:
    do on error undo, leave read-cycle:
      find first buf_sys-ctrl no-lock .
      for each ub.config no-lock
      on error undo, leave read-cycle
      :
        find first buf_db no-lock
          where buf_db.db-num = ub.config.db-num
          .
        if ub.config.db-num = buf_sys-ctrl.db-num then do:
          assign
            MaxErr = 2
          .
        end.
        else do:
          assign
            MaxErr = 1
          .
        end.
        create cnf .
        if lookup( ub.config.conf-type, 'к,п':U ) > 0
        then do:
          run check-enc in this-procedure
            ( input ub.config.db-num
             ,input buf_db.db-key
             ,input ub.config.param-code
             ,input ub.config.param-value
             ,input ub.config.beg-date
             ,input ub.config.end-date
             ,input ub.config.param-encoded
             ,output v-ok
            ) no-error.
          if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
          if v-ok <> true
          then do:
            assign
              cnf.errorexist = MaxErr
            .
            run log-error in str-hdl
              ( input substitute("Параметр &1 для БД &2 - ошибка кодирования (&3)", ub.config.param-code, ub.config.db-num, ub.config.param-encoded )
               ,input MaxErr
              ).
          end.
        end.
        if ub.config.beg-date = ?
        or ub.config.end-date = ?
        then do:
          assign
            cnf.errorexist = MaxErr
          .
          run log-error in str-hdl
            ( input substitute("Параметр &1 для БД &2 - не задана дата действия параметра", ub.config.param-code, ub.config.db-num )
              ,input MaxErr
            ).
        end.
        buffer-copy ub.config to cnf
          assign
            cnf.db-key = buf_db.db-key
          no-error
        .
        if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
        release cnf no-error.
        if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
      end.
      for each cnf
      on error undo, leave read-cycle
      :
        run chk-param in cnf-hdl
          ( buffer cnf
          ) no-error.
                if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
      end.
      run chk-unref in cnf-hdl
        ( input ?
        , input ?
        , input 'к,о':U
        , input false
        ) no-error.
            if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
      return if err-level > 0 then string (err-level) else "".
    end.
    run log-sys-error in str-hdl ("При загрузке параметров возникла непредвиденная ошибка").
    return string (err-level).
  end.
end procedure.
procedure chk-company :
  define input  parameter par-host-code like ub.sysconf.host-code no-undo.
  define buffer buf_sysconf for ub.sysconf .
  do
  on error undo, return error return-value
  :
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = par-host-code
      no-error .
    if available buf_sysconf
    then do:
      return.
    end.
    else do:
      return "1".
    end.
  end.
end procedure.
procedure chk-host-code :
  define input  parameter obj-obj-type  as character no-undo .
  define input  parameter obj-obj-code  as integer   no-undo .
  define output parameter obj-host-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      obj-host-code = ?
    .
    if obj-obj-type = ""
    or obj-obj-code = 0
    then do:
      return.
    end.
    case obj-obj-type
    :
        when 'скл':U
        then do:
              find first ub.store where ub.store.obj-code = obj-obj-code no-lock no-error.
              if available ub.store then
                assign obj-host-code = ub.store.host-code.
              else
                run log-error in str-hdl ("Не допустимый код магазина " + string(obj-obj-code), 1).
        end.
        when 'маг':U
        then do:
              find first ub.shop where ub.shop.obj-code = obj-obj-code no-lock no-error.
              if available ub.shop then
                assign obj-host-code = ub.shop.host-code.
              else
                run log-error in str-hdl ("Не допустимый код склада " + string(obj-obj-code), 1).
        end.
        otherwise do:
              run log-error in str-hdl (" Недопустимый тип объекта привязки - " + obj-obj-type, 1).
        end.
    end.
    return.
  end.
end procedure.
procedure chk-cfg :
  define input-output parameter par-chg-encode as logical           no-undo.
  define variable authorise as logical initial "false" no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_cnf      for cnf .
  do
  on error undo, return error return-value
  :
    find first buf_sys-ctrl no-lock .
    for each cnf no-lock
      where cnf.NotUsed
     ,first cnf-struct no-lock
        where cnf-struct.param-code = cnf.param-code
    on error undo, return error return-value
    :
      if lookup( cnf.conf-type, 'к,о':U ) + lookup( cnf-struct.param-type, 'к,о':U ) <> 0
      then do:
        if cnf.db-num = buf_sys-ctrl.db-num
        then do:
          run log-error in str-hdl
            ( input substitute( "Отсутствует обязательный параметр &1 для текущей БД", cnf.param-code )
             ,input 2
            ).
        end.
        else do:
          run log-error in str-hdl
            ( input substitute( "Отсутствует обязательный параметр &1 для БД &2", cnf.param-code, cnf.db-num )
             ,input 1
            ).
        end.
      end.
    end.
    assign
      err-level = 0
    .
    find first buf_cnf
      where buf_cnf.ErrorExist >= 2
        and buf_cnf.db-num = buf_sys-ctrl.db-num
        and ( buf_cnf.NotUsed = false
              or buf_cnf.conf-type <> ""
            )
      no-error .
    if available buf_cnf then do:
      run log-error in str-hdl
        ( input "В параметрах для текущей БД есть ошибки, подлежащие исправлению"
         ,input 2
        ).
    end.
    find first buf_cnf
      where buf_cnf.ErrorExist >= 2
        and buf_cnf.db-num <> buf_sys-ctrl.db-num
        and ( buf_cnf.NotUsed = false
              or buf_cnf.conf-type <> ""
            )
      no-error .
    if available buf_cnf then do:
      run log-error in str-hdl
        ( input substitute( "В параметрах для БД &1 есть ошибки, подлежащие исправлению", buf_cnf.db-num )
         ,input 1
        ).
    end.
    if err-level > 2 then do:
      return.
    end.
                for each ub.config
      where lookup( ub.config.conf-type, 'к,п':U ) > 0
    on error undo, return error
    :
        find first cnf where ub.config.param-code = cnf.param-code and                  ub.config.host-code  = cnf.host-code  and                  ub.config.obj-type   = cnf.obj-type   and                  ub.config.obj-code   = cnf.obj-code   and                  ub.config.beg-date   = cnf.beg-date   and                  ub.config.end-date   = cnf.end-date   and                  ub.config.db-num     = cnf.db-num no-error.
        if not available cnf
        then do:
          run log-error in str-hdl ("В наборе параметров удален кодированный параметр " +
                                    ub.config.param-code, 0).
          Authorise = true.
          next.
        end.
        if cnf.param-value <> ub.config.param-value
        then do:
          run log-error in str-hdl ("Изменен кодированный параметр " + ub.config.param-code  + " на "  +
                                    cnf.param-value  + " с " + ub.config.param-value, 0).
          Authorise = true.
          next.
        end.
    end.
    for each cnf
      where lookup( ub.config.conf-type, 'к,п':U ) > 0
        and cnf.notused = false
    on error undo, return error
    :
        find first ub.config where ub.config.param-code = cnf.param-code and                  ub.config.host-code  = cnf.host-code  and                  ub.config.obj-type   = cnf.obj-type   and                  ub.config.obj-code   = cnf.obj-code   and                  ub.config.beg-date   = cnf.beg-date   and                  ub.config.end-date   = cnf.end-date   and                  ub.config.db-num     = cnf.db-num no-lock no-error.
        if not available ub.config
        then do:
          run log-error in str-hdl ("В новом наборе параметров есть новый кодированный параметр " +
                                    cnf.param-code, 0).
          Authorise = true.
          next.
        end.
    end.
    if authorise and not par-chg-encode
    then do:
      run gbl/authoriz.p (input "Run information dialog",output par-chg-encode ) no-error.
      if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
      if not par-chg-encode then
          run log-error in str-hdl ("Изменение кодированных параметров запрещено", 2).
    end.
  end.
end procedure.
procedure save-cfg :
  define input  parameter par-chg-encode as logical          no-undo.
  do
  on error undo, return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  :
  define buffer b-config for ub.config.
  assign
    err-level = 0
  .
  run chk-cfg in this-procedure
    (input-output par-chg-encode
    ) no-error.
  if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
  if err-level > 1 then do:
    return string (err-level) .
  end.
  run adm/cnf-chk.p no-error .
  if error-status :error then do:
    run log-error in str-hdl
      ( input substitute( "Текущий набор невозможно сохранить&1&2&1&3", chr(10), return-value, error-status :get-message ( 1 ) )
       ,input 2
      ).
    return "2".
  end.
  tran-write:
  do transaction
  on error undo tran-write, return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  :
    for each cnf
      where cnf.NotUsed = false
    on error undo tran-write, return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
    :
      find first ub.config exclusive-lock
        where ub.config.param-code = cnf.param-code and                  ub.config.host-code  = cnf.host-code  and                  ub.config.obj-type   = cnf.obj-type   and                  ub.config.obj-code   = cnf.obj-code   and                  ub.config.beg-date   = cnf.beg-date   and                  ub.config.end-date   = cnf.end-date   and                  ub.config.db-num     = cnf.db-num no-error.
      if not available ub.config
      then do:
        if locked ub.config
        then do:
            run log-error in str-hdl ("Запись текущего набора локирована, попробуйте записать позже", 2).
            undo Tran-Write, return string(err-level).
        end.
        else do:
          create ub.config no-error.
        end.
        if error-status:error then do:                                          run log-sys-error in str-hdl ("Системная ошибка").                   undo, return "2" .                                                      end.
      end.
      buffer-copy cnf to ub.config
        assign
          ub.config.stts = 0
      .
    end.
    for each ub.config no-lock
    on error undo tran-write, return "2"
    :
      if can-find (first cnf where ub.config.param-code = cnf.param-code and                  ub.config.host-code  = cnf.host-code  and                  ub.config.obj-type   = cnf.obj-type   and                  ub.config.obj-code   = cnf.obj-code   and                  ub.config.beg-date   = cnf.beg-date   and                  ub.config.end-date   = cnf.end-date   and                  ub.config.db-num     = cnf.db-num and not cnf.NotUsed) then next.
      find first b-config where ReciD(b-config) = recid(ub.config) exclusive-lock no-error.
      if not available b-config
      then do:
        if locked b-config then
            run log-error in str-hdl ("Запись текущего набора локирована, попробуйте записать позже", 2).
        else if error-status:error then
            run log-sys-error in str-hdl ("Запись текущего набора недоступна").
        if err-level > 0
        then do:
          undo Tran-Write, return string(err-level).
        end.
      end.
      else do:
        if par-chg-encode
        then do:
          assign
            b-config.stts = -1
          .
        end.
        delete b-config .
      end.
    end.
    return "".
  end.
  end.
end procedure.
procedure find-library :
  do
  on error undo, return error return-value
  :
    if valid-handle(cnf-hdl) then return.
    assign
      cnf-hdl = session :first-procedure
    .
    do while valid-handle (cnf-hdl)
    :
      if cnf-hdl:private-data = "Work-with-config"
      then do:
        leave.
      end.
      assign
        cnf-hdl = cnf-hdl :next-sibling
      .
    end.
  end.
end procedure.
