block-level on error undo, throw.
define input parameter p-source-db    as integer   no-undo .
define input parameter p-full-command as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обработка команды two-commit".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure progs-name :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-main-prog-name      as character no-undo .
  define output parameter p-list-db-proc-name   as character no-undo .
  define output parameter p-commit-proc-name    as character no-undo .
  define output parameter p-execution-proc-name as character no-undo .
  define output parameter p-recover-proc-name   as character no-undo .
  define output parameter p-after-proc-name     as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-crush-cdrg':U       p-execution-proc-name = 'exec-crush-cdrg':U       p-recover-proc-name   = 'rcvr-crush-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-del-cdrg':U       p-execution-proc-name = 'exec-del-cdrg':U       p-recover-proc-name   = 'rcvr-del-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-prt-bar-code':U       p-execution-proc-name = 'delete-prt-bar-code':U       p-recover-proc-name   = 'undo-delete-prt-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-part-bar-code':U       p-execution-proc-name = 'delete-part-bar-code':U       p-recover-proc-name   = 'undo-delete-part-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-ucli-bar-code':U       p-execution-proc-name = 'delete-ucli-bar-code':U       p-recover-proc-name   = 'undo-delete-ucli-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-del-dis-card':U       p-execution-proc-name = 'delete-dis-card':U       p-recover-proc-name   = 'undo-delete-dis-card':U       p-after-proc-name     = '':U     .   end.
            when 'chown-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-chown-dis-card':U       p-execution-proc-name = 'chown-dis-card':U       p-recover-proc-name   = 'undo-chown-dis-card':U       p-after-proc-name     = 'after-chown-dis-card':U     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-main-prog-name      = 'trg/dis-rult.p':U       p-list-db-proc-name   = 'trg/disruldb.p':U       p-commit-proc-name    = 'block-del-dis-rule':U       p-execution-proc-name = 'delete-dis-rule':U       p-recover-proc-name   = 'undo-delete-dis-rule':U       p-after-proc-name     = '':U     .   end.
            when 'ren-art':U then do:     assign       p-main-prog-name      = 'trg/goodst.p':U       p-list-db-proc-name   = 'utl/renartcd.p':U       p-commit-proc-name    = 'comm-ren-art':U       p-execution-proc-name = 'exec-ren-art':U       p-recover-proc-name   = 'rcvr-ren-art':U       p-after-proc-name     = 'after-ren-art':U     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-main-prog-name      = 'trg/clobdatt.p':U       p-list-db-proc-name   = 'trg/clbdatdb.p':U       p-commit-proc-name    = 'block-del-clob-data':U       p-execution-proc-name = 'delete-clob-data':U       p-recover-proc-name   = 'undo-delete-clob-data':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-layout':U then do:     assign       p-main-prog-name      = 'trg/layoutt.p':U       p-list-db-proc-name   = 'trg/layoutdb.p':U       p-commit-proc-name    = 'block-del-layout':U       p-execution-proc-name = 'delete-layout':U       p-recover-proc-name   = 'undo-delete-layout':U       p-after-proc-name     = '':U     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info0, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
procedure progs-title :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info0, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
FUNCTION progs-title-function returns character(
   input  p-action-code         as character):
define variable p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info0, p-action-code ).
      end.
    end case.
  end.
  return p-action-title.
end FUNCTION.
procedure get-row-keyr-string :
 define input  parameter p-key-rec  as character no-undo.
 define output parameter p-tbl-title as character no-undo.
 define output parameter p-rec-string  as character no-undo.
  do
  on error undo, return error
  :
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh              as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-field-num     as integer   no-undo .
    define variable v-count-fld     as integer   no-undo .
    define variable v-tbl-name as character no-undo.
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (get-row-keyr-string). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info0 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = "ub.":U + v-tbl-name
      v-field-num     = num-entries( p-key-rec, chr(3) ) - 1
      p-rec-string         = "":U
      v-count-fld     = 0
    .
    find ub._file
      where ub._file._file-name = v-tbl-name
      no-error.
    if not available ub._file then do:
      return error substitute( "&1. Таблица &2 отсутствует в БД", vss-include-info0, v-tbl-name ).
    end.
    assign
    p-tbl-title = ub._file._file-label
    .
    find ub._index
      where recid( ub._index  ) = ub._file._prime-index
      no-error.
    if not available ub._index
      or LC( ub._index._index-name ) = "default":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info0, v-tbl-name ).
    end.
    block_where :
    for each ub._index-field of ub._index  ,
        each ub._field of _index-field
        break by _index-seq
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      if p-rec-string = "":U then do:
        assign
          p-rec-string = "":U
        .
      end.
      else do:
        assign
          p-rec-string = p-rec-string + chr(32) + chr(44)
        .
      end.
      assign
        p-rec-string = p-rec-string + (if p-rec-string = "":u then "":U else chr(32)) + substitute( "&1 = &2":U, ub._field._label, entry( v-count-fld + 1 , p-key-rec, chr(3) ) )
      .
    end.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info0, v-tbl-name ).
    end.
  end.
  return.
end procedure.
FUNCTION uniq-key-rec-string-f returns character(
   input  p-uniq-key-rec         as character):
define variable v-tbl-title as character no-undo .
define variable v-rec-string as character no-undo .
  do
  on error undo, return error
  :
    run get-row-keyr-string in this-procedure (
                                              input p-uniq-key-rec
                                              ,output v-tbl-title
                                              ,output v-rec-string).
    assign
    v-rec-string = (if v-tbl-title <> ? and
                    v-tbl-title <> "":U
                    then (v-tbl-title + ":")
                   else "":U) + chr(32) + v-rec-string
    .
  end.
  return v-rec-string.
end FUNCTION.
procedure create_db-rec_route :
  define input parameter p1-uniq-key-rec as character no-undo .
  define input parameter p1-action       as character no-undo .
  define input parameter p1-operation    as character no-undo .
  define input parameter p1-send-db-list as character no-undo .
  define input parameter p1-db-init      as integer   no-undo .
  define input parameter p1-parameters   as character no-undo .
  define input parameter p1-answer-code  as integer   no-undo .
  define input parameter p1-answer-msg   as character no-undo .
  do
  on error undo, return error
  :
    define variable v-command     as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      if p1-answer-code >= 0 then do:
        if v-curr-db <> p1-db-init then do:
          assign
            v-db-for-send = string( p1-db-init )
          .
        end.
      end.
      else do:
        assign
          v-num-entries = num-entries( p1-send-db-list, chr(44) )
        .
        do v-ind = 1 to v-num-entries:
          assign
            v-db-num-char = entry( v-ind, p1-send-db-list, chr(44) )
            v-db-num      = integer( v-db-num-char )
          .
          if v-db-num <> v-curr-db
            and v-db-num <> p1-db-init
          then do:
            if v-db-for-send = "":U then do:
              assign
                v-db-for-send = v-db-num-char
              .
            end.
            else do:
              assign
                v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
              .
            end.
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-command = "command":U + chr(1)
                    + "two-commit":U + chr(1)
                    + p1-action + chr(1)
                    + p1-operation + chr(1)
                    + p1-uniq-key-rec + chr(1)
                    + string( p1-db-init ) + chr(1)
                    + p1-parameters + chr(1)
                    + string( p1-answer-code ) + chr(1)
                    + p1-answer-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  return.
end procedure.
procedure create_msg_route :
  define input parameter p2-send-db-list as character no-undo .
  define input parameter p2-msg          as character no-undo .
  do
  on error undo, return error
  :
    define variable v-msg-command as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      assign
        v-num-entries = num-entries( p2-send-db-list, chr(44) )
      .
      do v-ind = 1 to v-num-entries:
        assign
          v-db-num-char = entry( v-ind, p2-send-db-list, chr(44) )
          v-db-num      = integer( v-db-num-char )
        .
        if v-db-num <> v-curr-db then do:
          if v-db-for-send = "":U then do:
            assign
              v-db-for-send = v-db-num-char
            .
          end.
          else do:
            assign
              v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-msg-command = "command":U + chr(1)
                        + "message-to-log":U + chr(1)
                        + p2-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-msg-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error substitute( "&1&2&3"
                                  , return-value
                                  , chr(10)
                                  , error-status :get-message(1)
                                ).
      end.
    end.
  end.
  return.
end procedure.
function get-send-db-list returns character
  ( input p-curr-db     as integer
   ,input p-all-db-list as character
  )
:
  define variable v-send-db-list as character no-undo .
  if p-curr-db = 0 then do:
    assign
      v-send-db-list = p-all-db-list
    .
  end.
  else do:
    assign
      v-send-db-list = string(p-curr-db)
    .
  end.
  return v-send-db-list .
end function .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, chr(10) ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) ).
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) )
    .
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
do
on error undo, return error
:
  define variable v-action            as character no-undo .
  define variable v-operation         as character no-undo .
  define variable v-uniq-key-rec      as character no-undo .
  define variable v-curr-db           as integer   no-undo .
  define variable v-db-init           as integer   no-undo .
  define variable v-parameters        as character no-undo .
  define variable v-answer-code       as integer   no-undo .
  define variable v-answer-msg        as character no-undo .
  define variable v-send-db-list      as character no-undo .
  define variable v-all-db-list       as character no-undo .
  define variable v-need-send-inquiry as logical   no-undo .
  define variable v-send-news         as logical   no-undo .
  define variable v-global-recover    as logical   no-undo .
  define variable v-main-prog-name      as character no-undo .
  define variable v-list-db-proc-name   as character no-undo .
  define variable v-commit-proc-name    as character no-undo .
  define variable v-execution-proc-name as character no-undo .
  define variable v-recover-proc-name   as character no-undo .
  define variable v-after-proc-name     as character no-undo .
  define variable v-db-num       as integer   no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-change-oper  as logical   no-undo .
  define variable v-new-oper     as character no-undo .
  define variable v-after-command as character no-undo .
  define variable v-message       as character no-undo .
  define variable v-err-stts      as character no-undo .
  define buffer buf_sys-ctrl        for ub.sys-ctrl .
  define buffer buf_db              for ub.db .
  define buffer buf_db-rec-attr     for ub.db-rec-attr .
  define buffer buf-all_db-rec-attr for ub.db-rec-attr .
  find first buf_sys-ctrl no-lock .
  assign
    v-curr-db      = buf_sys-ctrl.db-num
    v-action       = entry(3, p-full-command, chr(1))
    v-operation    = entry(4, p-full-command, chr(1))
    v-uniq-key-rec = entry(5, p-full-command, chr(1))
    v-db-init      = integer( entry(6, p-full-command, chr(1)) )
    v-parameters   = entry(7, p-full-command, chr(1))
    v-answer-code  = integer( entry(8, p-full-command, chr(1)) )
    v-answer-msg   = entry(9, p-full-command, chr(1))
  .
  run progs-name( input v-action
                 ,output v-main-prog-name
                 ,output v-list-db-proc-name
                 ,output v-commit-proc-name
                 ,output v-execution-proc-name
                 ,output v-recover-proc-name
                 ,output v-after-proc-name
                ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при определении имен процедур. &2", vss-workfile, return-value ).
  end.
  run value( v-list-db-proc-name )
    ( input v-action
     ,input v-uniq-key-rec
     ,output v-all-db-list
    ) no-error .
  if error-status :error then do:
    return error substitute( "&1. Ошибка при определении списка БД. &2", vss-workfile, return-value ).
  end.
  assign
    v-send-db-list = get-send-db-list( v-curr-db, v-all-db-list )
  .
  assign
    v-global-recover = TRUE
  .
  if v-answer-code >= 0
    and ( v-curr-db = 0
          or v-curr-db = v-db-init
        )
  then do:
    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.db-num             = p-source-db
        and buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
        and buf_db-rec-attr.attr-code          = v-action
        and buf_db-rec-attr.attr-value-decimal = v-db-init
    no-error.
    if not avail buf_db-rec-attr then
    do:
      run write-to-log( substitute( 'Для БД &1 не найдена запись об операции "&2(&3)" над записью &4'
                                    ,p-source-db
                                    ,v-action
                                    ,v-operation
                                    ,v-uniq-key-rec
                                  )
                      ).
      return.
    end.
    if v-answer-code = 0 then do:
      run write-to-log( substitute( 'Получен ответ из БД &1 об успешном выполнении шага "&2" операции "&3" над записью &4'
                                    ,p-source-db
                                    ,v-operation
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
                      ).
      if buf_db-rec-attr.attr-type = v-operation then do:
        assign
          buf_db-rec-attr.attr-value-logical = TRUE
          v-change-oper = TRUE
        .
        assign
          v-num-entries = num-entries( v-send-db-list, chr(44) )
        .
        ALL_DB_REC:
        do v-ind = 1 to v-num-entries
        on error undo, return error
        :
          assign
            v-db-num = integer( entry( v-ind, v-send-db-list, chr(44) ) )
          .
          if v-curr-db = 0 then do:
            if v-db-num = v-db-init
              and v-db-num <> 0
            then do:
              next.
            end.
            find first buf_db no-lock
              where buf_db.db-num = v-db-num
              no-error
            .
            if not available buf_db
              or buf_db.db-key = "":U
            then do:
              next.
            end.
          end.
          find first buf-all_db-rec-attr no-lock
            where buf-all_db-rec-attr.db-num             = v-db-num
              and buf-all_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
              and buf-all_db-rec-attr.attr-code          = v-action
              and buf-all_db-rec-attr.attr-value-decimal = v-db-init
            no-error
          .
          if not available buf-all_db-rec-attr then do:
             next ALL_DB_REC.
          end.
          if buf-all_db-rec-attr.attr-type <> v-operation
            or ( buf-all_db-rec-attr.attr-type = v-operation
                and buf-all_db-rec-attr.attr-value-logical = FALSE
              )
          then do:
            assign
              v-change-oper = FALSE
            .
          end.
        end.
        if v-change-oper = TRUE then do:
          if buf_db-rec-attr.attr-type = "commit":U then do:
            assign
              v-new-oper = "execution":U
            .
          end.
          else do:
            assign
              v-new-oper = "":U
            .
          end.
        end.
      end.
      else do:
        run write-to-log( substitute( 'Для БД &1 уже начато выполнение шага "&2" операции "&3" над записью &4'
                                      ,p-source-db
                                      ,buf_db-rec-attr.attr-type
                                      ,v-action
                                      ,v-uniq-key-rec
                                    )
                        ).
        assign
          v-change-oper = FALSE
        .
      end.
    end.
    else do:
      assign
        v-message = substitute( 'БД &1, шаг "&2", оп. "&3", запись &4.&5Ошибка: &6.&5Операция откатывается.'
                                ,p-source-db
                                ,v-operation
                                ,v-action
                                ,v-uniq-key-rec
                                ,chr(10)
                                ,v-answer-msg
                              )
      .
      run write-to-log( v-message ).
      run create_msg_route in this-procedure
        ( input v-send-db-list
         ,input v-message
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
      end.
      if buf_db-rec-attr.attr-type = v-operation then do:
        if v-curr-db <> 0
          and v-curr-db = v-db-init
          and v-answer-code = 10
        then do:
          assign
            v-global-recover = FALSE
          .
        end.
        else do:
          assign
            v-global-recover = TRUE
            v-answer-code    = 1
          .
        end.
        assign
          v-change-oper = TRUE
          v-new-oper = "recover":U
        .
      end.
      else do:
        assign
          v-change-oper = FALSE
        .
      end.
    end.
    if v-change-oper = TRUE then do:
      if v-new-oper = "":U then do:
        for each buf_db-rec-attr
          where buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
            and buf_db-rec-attr.attr-code          = v-action
            and buf_db-rec-attr.attr-value-decimal = v-db-init
        on error undo, return error
        :
          delete buf_db-rec-attr.
        end.
        if v-operation = "execution":U then do:
          assign
            v-message = substitute( 'Операция "&1" над записью &2 успешно завершена.'
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
          .
          run write-to-log( v-message ).
          run create_msg_route in this-procedure
            ( input v-send-db-list
            ,input v-message
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
          end.
        end.
        else do:
          assign
            v-message = substitute( 'Откат операции "&1" над записью &2 завершен.'
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
          .
          run write-to-log( v-message ).
          run create_msg_route in this-procedure
            ( input v-send-db-list
            ,input v-message
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
          end.
        end.
        if v-curr-db = v-db-init then do:
          assign
            v-after-command = "command":U + chr(1)
                              + "after-two-commit":U + chr(1)
                              + v-action + chr(1)
                              + v-uniq-key-rec + chr(1)
                              + string( v-db-init ) + chr(1)
                              + v-parameters
          .
          run nws/dbrecaft.p
            ( input ?
             ,input v-after-command
            ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при выполнении команды (after) по СПН. &2", vss-workfile, return-value ).
          end.
        end.
      end.
      if v-curr-db = v-db-init then do:
        if v-new-oper <> "":U then do:
          if v-new-oper = "recover":U
            and v-global-recover = FALSE
          then do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
                and buf_db-rec-attr.attr-code          = v-action
                and buf_db-rec-attr.attr-value-decimal = v-db-init
            on error undo, return error
            :
              if buf_db-rec-attr.db-num = v-curr-db then do:
                assign
                  buf_db-rec-attr.attr-type          = v-new-oper
                  buf_db-rec-attr.attr-value-logical = FALSE
                .
              end.
              else do:
                delete buf_db-rec-attr .
              end.
            end.
          end.
          else do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
                and buf_db-rec-attr.attr-code          = v-action
                and buf_db-rec-attr.attr-value-decimal = v-db-init
            on error undo, return error
            :
              assign
                buf_db-rec-attr.attr-type          = v-new-oper
                buf_db-rec-attr.attr-value-logical = FALSE
              .
            end.
          end.
          assign
            v-operation   = v-new-oper
            v-answer-code = -1
            v-answer-msg  = "":U
          .
        end.
      end.
      else do:
      end.
    end.
  end.
  if v-answer-code < 0 then do:
    if lookup( string( v-curr-db ), v-send-db-list, chr(44) ) <> 0 then do:
      find first buf_db-rec-attr
        where buf_db-rec-attr.db-num       = v-curr-db
          and buf_db-rec-attr.uniq-key-rec = v-uniq-key-rec
          and buf_db-rec-attr.attr-code    = v-action
        no-error.
      if available buf_db-rec-attr
        and buf_db-rec-attr.attr-value-decimal <> v-db-init
      then do:
        assign
          v-answer-msg = substitute( "Операцию &1 над записью &2 уже производит БД &3"
                                     , v-action, v-uniq-key-rec, buf_db-rec-attr.attr-value-decimal
                                   )
          v-answer-code = 10
        .
      end.
      else do:
        if available buf_db-rec-attr
          and buf_db-rec-attr.attr-type = v-operation
          and buf_db-rec-attr.attr-value-logical = TRUE
        then do:
          assign
            v-answer-msg = "":U
          .
        end.
        else do:
          assign
            v-message = substitute( 'Начинается выполнение шага "&1" операции "&2" над записью &3'
                                    ,v-operation
                                    ,v-action
                                    ,v-uniq-key-rec
                                   )
          .
          run write-to-log( v-message ).
          if not available buf_db-rec-attr then do:
            create buf_db-rec-attr.
            assign
              buf_db-rec-attr.db-num             = v-curr-db
              buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
              buf_db-rec-attr.attr-code          = v-action
            .
          end.
          assign
            buf_db-rec-attr.attr-type          = v-operation
            buf_db-rec-attr.attr-value         = v-parameters
            buf_db-rec-attr.attr-value-decimal = v-db-init
            buf_db-rec-attr.attr-value-date    = TODAY
            buf_db-rec-attr.attr-value-logical = FALSE
            v-err-stts = "":U
          .
          run nws/db-rec.p
            ( input substitute( "&1&2not-begin":U, v-action, chr(1) )
             ,input v-uniq-key-rec
             ,input v-parameters
            ) no-error .
          if error-status :error then do:
            assign
              v-err-stts = return-value
            .
          end.
          assign
            v-message = substitute( 'Завершилось выполнение шага "&1" операции "&2" над записью &3'
                                    ,v-operation
                                    ,v-action
                                    ,v-uniq-key-rec
                                  )
          .
          run write-to-log( v-message ).
          if v-err-stts <> "":U then do:
            return error v-err-stts.
          end.
          assign
            v-answer-msg = return-value
          .
          if v-answer-msg = "":U
            and ( v-operation = "execution":U
                  or v-operation = "recover":U
                )
            and v-curr-db <> 0
            and ( v-curr-db <> v-db-init
                  or
                  ( v-operation = "recover":U and v-global-recover = FALSE )
                )
          then do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec = v-uniq-key-rec
                and buf_db-rec-attr.attr-code    = v-action
            on error undo, return error
            :
              delete buf_db-rec-attr.
            end.
          end.
        end.
      end.
    end.
    assign
      v-send-news = TRUE
    .
    if v-curr-db = v-db-init then do:
      if v-operation = "recover":U
        and v-global-recover = FALSE
      then do:
        assign
          v-need-send-inquiry = FALSE
          v-send-news         = FALSE
        .
      end.
      else do:
        assign
          v-need-send-inquiry = TRUE
        .
      end.
    end.
    else do:
      assign
        v-need-send-inquiry = FALSE
      .
      if v-curr-db = 0 then do:
        assign
          v-num-entries = num-entries( v-send-db-list, chr(44) )
        .
        do v-ind = 1 to v-num-entries
        :
          assign
            v-db-num = integer( entry( v-ind, v-send-db-list, chr(44) ) )
          .
          if v-db-num = 0
            or v-db-num = v-db-init
          then do:
            next.
          end.
          assign
            v-need-send-inquiry = TRUE
          .
        end.
      end.
    end.
    if v-send-news = TRUE then do:
      if v-answer-msg = "":U
        and v-need-send-inquiry = TRUE
      then do:
        assign
          v-answer-code = -1
        .
        if v-curr-db = 0
        then do:
          assign
            v-num-entries = num-entries( v-send-db-list, chr(44) )
          .
          do v-ind = 1 to v-num-entries
          :
            assign
              v-db-num = integer( entry( v-ind, v-send-db-list, chr(44) ) )
            .
            if v-db-num = 0
            then do:
              next.
            end.
            find first buf_db-rec-attr
              where buf_db-rec-attr.db-num       = v-db-num
                and buf_db-rec-attr.uniq-key-rec = v-uniq-key-rec
                and buf_db-rec-attr.attr-code    = v-action
              no-error.
            if not available buf_db-rec-attr then do:
              create buf_db-rec-attr.
              assign
                buf_db-rec-attr.db-num             = v-db-num
                buf_db-rec-attr.uniq-key-rec       = v-uniq-key-rec
                buf_db-rec-attr.attr-code          = v-action
              .
            end.
            assign
              buf_db-rec-attr.attr-type          = v-operation
              buf_db-rec-attr.attr-value         = v-parameters
              buf_db-rec-attr.attr-value-decimal = v-db-init
              buf_db-rec-attr.attr-value-date    = TODAY
              buf_db-rec-attr.attr-value-logical = FALSE
            .
          end.
        end.
      end.
      else do:
        if v-answer-msg = "":U then do:
          assign
            v-answer-code = 0
          .
        end.
        else do:
          if v-answer-code <> 10 then do:
            assign
              v-answer-code = 1
            .
          end.
        end.
      end.
      run create_db-rec_route in this-procedure
        ( input v-uniq-key-rec
        ,input v-action
        ,input v-operation
        ,input v-send-db-list
        ,input v-db-init
        ,input v-parameters
        ,input v-answer-code
        ,input v-answer-msg
        ) no-error .
      if error-status :error then do:
        return error substitute( "&1. Ошибка при отправке команды по СПН. &2", vss-workfile, return-value ).
      end.
    end.
  end.
  return.
end.
