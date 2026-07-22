block-level on error undo, throw.
define input parameter p-action       as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-parameters   as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: db-rec.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/db-rec.p $":U .
def var vss-description as character no-undo init "Выполнение (удаленное) операций над записями".
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
do
on error  undo, return error substitute("&1. error &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey")
on stop   undo, return error substitute("&1. stop")
:
  define variable v-main-prog-name      as character no-undo .
  define variable v-list-db-proc-name   as character no-undo .
  define variable v-commit-proc-name    as character no-undo .
  define variable v-execution-proc-name as character no-undo .
  define variable v-recover-proc-name   as character no-undo .
  define variable v-after-proc-name     as character no-undo .
  define variable v-ext-prg-handle      as handle    no-undo .
  define variable v-err-msg      as character no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-send-db-list as character no-undo .
  define variable v-all-db-list  as character no-undo .
  define variable v-curr-db      as integer   no-undo .
  define variable v-db-init      as integer   no-undo .
  define variable v-operation    as character no-undo .
  define variable v-answer-code  as integer   no-undo .
  define variable v-answer-msg   as character no-undo .
  define variable v-is-begin     as logical   no-undo .
  define variable v-run-proc     as logical   no-undo .
  define variable v-command      as character no-undo .
  define buffer buf_sys-ctrl    for ub.sys-ctrl .
  define buffer buf_db          for ub.db .
  define buffer buf_db-rec-attr for ub.db-rec-attr .
  if num-entries( p-action, chr(1) ) = 2 then do:
    if entry( 2, p-action, chr(1) ) = "not-begin":U then do:
      assign
        p-action   = entry( 1, p-action, chr(1) )
        v-is-begin = false
      .
    end.
    else do:
      undo, return error substitute( "Недопустимый тип операции &1 над записью &2", p-action, p-uniq-key-rec ).
    end.
  end.
  else do:
    assign
      v-is-begin = true
    .
  end.
  find first buf_sys-ctrl no-lock .
  assign
    v-curr-db  = buf_sys-ctrl.db-num
    v-run-proc = true
  .
  run progs-name( input p-action
                 ,output v-main-prog-name
                 ,output v-list-db-proc-name
                 ,output v-commit-proc-name
                 ,output v-execution-proc-name
                 ,output v-recover-proc-name
                 ,output v-after-proc-name
                ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при определении имен процедур. &2", vss-workfile, return-value ).
  end.
  run value( v-list-db-proc-name )
    ( input p-action
     ,input p-uniq-key-rec
     ,output v-all-db-list
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при определении списка БД. &2", vss-workfile, return-value ).
  end.
  assign
    v-send-db-list = get-send-db-list( v-curr-db, v-all-db-list )
  .
  find first buf_db-rec-attr exclusive-lock
    where buf_db-rec-attr.db-num       = v-curr-db
      and buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
      and buf_db-rec-attr.attr-code    = p-action
    no-wait no-error.
  if available buf_db-rec-attr
    or ( not available buf_db-rec-attr
         and locked buf_db-rec-attr
       )
  then do:
    if v-is-begin = true then do:
      if g#news = true then do:
        return substitute( "Операция &1 над записью &2 уже производится"
                            , p-action, p-uniq-key-rec
                          ).
      end.
      else do:
        undo, return error substitute( "Операция &1 над записью &2 уже производится", p-action, p-uniq-key-rec ).
      end.
    end.
  end.
  else do:
    if v-is-begin = false then do:
      undo, return error substitute( "Недопустимо начинать выполнять операцию &1 над записью &2 без ее инициализации", p-action, p-uniq-key-rec ).
    end.
    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
        and buf_db-rec-attr.attr-code    = p-action
      no-wait no-error.
    if available buf_db-rec-attr
      or ( not available buf_db-rec-attr
          and locked buf_db-rec-attr
        )
    then do:
      undo, return error substitute( "&1. Уже есть запрос с кодом &2 для записи &3.", vss-workfile, p-action, p-uniq-key-rec ).
    end.
    assign
      v-db-init     = 0
      v-num-entries = num-entries( v-send-db-list, chr(44) )
    .
    if not ( ( v-num-entries = 1
                and v-send-db-list <> "0":U
              )
              or v-num-entries >= 2
            )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Данная процедура предназначена только для работы с" skip
        "несколькими БД, а запускается для работы с одной!!!" skip
        "Список БД:" v-send-db-list
        view-as alert-box error.
      undo, return error.
    end.
    if v-curr-db <> 0 then do:
      assign
        v-run-proc = false
        v-command = "command":U + chr(1)
                    + "inquiry-two-commit":U + chr(1)
                    + p-action + chr(1)
                    + p-uniq-key-rec + chr(1)
                    + p-parameters
      .
      run nws/cr-route.p ( input 'send-cmd':U
                      ,input v-command
                      ,input ?
                      ,input "0":U
                    ) no-error .
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при отправке команды на выполнение операции над записью &2.&3&4&5&6"
                                       , vss-workfile
                                       , p-uniq-key-rec
                                       , chr(10)
                                       , return-value
                                       , chr(10)
                                       , error-status :get-message(1)
                                     ).
      end.
    end.
    else do:
      do v-ind = 1 to v-num-entries
      :
        create buf_db-rec-attr.
        assign
          buf_db-rec-attr.db-num             = integer( entry( v-ind, v-send-db-list, chr(44) ) )
          buf_db-rec-attr.uniq-key-rec       = p-uniq-key-rec
          buf_db-rec-attr.attr-code          = p-action
          buf_db-rec-attr.attr-type          = "commit":U
          buf_db-rec-attr.attr-value         = p-parameters
          buf_db-rec-attr.attr-value-decimal = v-db-init
          buf_db-rec-attr.attr-value-date    = TODAY
          buf_db-rec-attr.attr-value-logical = FALSE
        .
        release buf_db-rec-attr.
      end.
      run create_msg_route in this-procedure
        ( input v-send-db-list
         ,input substitute( "Начинается выполнение операции &1 над записью &2"
                            ,p-action
                            ,p-uniq-key-rec
                          )
        ) no-error .
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при отправке сообщения по СПН. &2", vss-workfile, return-value ).
      end.
    end.
  end.
  if v-run-proc = true then do:
    find first buf_db-rec-attr exclusive-lock
      where buf_db-rec-attr.db-num       = v-curr-db
        and buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
        and buf_db-rec-attr.attr-code    = p-action
    .
    assign
      v-db-init   = buf_db-rec-attr.attr-value-decimal
      v-operation = buf_db-rec-attr.attr-type
    .
    run value( v-main-prog-name ) persistent
        set v-ext-prg-handle .
    case buf_db-rec-attr.attr-type :
      when "commit":U then do:
        if v-run-proc = true then do:
          run value( v-commit-proc-name ) in v-ext-prg-handle
            ( input buf_db-rec-attr.db-num
            , input buf_db-rec-attr.uniq-key-rec
            , input buf_db-rec-attr.attr-code
            , input buf_db-rec-attr.attr-value
            , output v-err-msg
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( "&1. Ошибка при блокировке записи &2.&3&4&5&6"
                                           , vss-workfile
                                           , buf_db-rec-attr.uniq-key-rec
                                           , chr(10)
                                           , return-value
                                           , chr(10)
                                           , error-status :get-message(1)
                                         ).
          end.
        end.
        if v-is-begin = true then do:
          if v-err-msg = "":U then do:
            run create_db-rec_route in this-procedure
              ( input p-uniq-key-rec
              , input p-action
              , input "commit":U
              , input v-send-db-list
              , input v-db-init
              , input p-parameters
              , input -1
              , input ""
              ) no-error .
            if error-status :error then do:
              undo, return error substitute( "&1. Ошибка при отправке команды по СПН. &2", vss-workfile, return-value ).
            end.
          end.
          else do:
            for each buf_db-rec-attr
              where buf_db-rec-attr.uniq-key-rec = p-uniq-key-rec
                and buf_db-rec-attr.attr-code    = p-action
            on error  undo, return error substitute("&1. error buf_db-rec-attr &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
            on endkey undo, return error substitute("&1. endkey buf_db-rec-attr")
            on stop   undo, return error substitute("&1. stop buf_db-rec-attr")
            :
              delete buf_db-rec-attr.
            end.
          end.
        end.
      end.
      when "execution":U then do:
        run value( v-execution-proc-name ) in v-ext-prg-handle
          ( input buf_db-rec-attr.db-num
          , input buf_db-rec-attr.uniq-key-rec
          , input buf_db-rec-attr.attr-code
          , input buf_db-rec-attr.attr-value
          , output v-err-msg
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( "&1. Ошибка при выполнении операции над записью &2.&3&4&5&6"
                                         , vss-workfile
                                         , buf_db-rec-attr.uniq-key-rec
                                         , chr(10)
                                         , return-value
                                         , chr(10)
                                         , error-status :get-message(1)
                                       ).
        end.
      end.
      when "recover":U then do:
        run value( v-recover-proc-name ) in v-ext-prg-handle
          ( input buf_db-rec-attr.db-num
          , input buf_db-rec-attr.uniq-key-rec
          , input buf_db-rec-attr.attr-code
          , input buf_db-rec-attr.attr-value
          , output v-err-msg
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( "&1. Ошибка при выполнении отката операции над записью &2.&3&4&5&6"
                                         , vss-workfile
                                         , buf_db-rec-attr.uniq-key-rec
                                         , chr(10)
                                         , return-value
                                         , chr(10)
                                         , error-status :get-message(1)
                                       ).
        end.
      end.
    end case.
    delete procedure v-ext-prg-handle .
    if v-err-msg <> "":U then do:
      return v-err-msg .
    end.
    else do:
      assign
        buf_db-rec-attr.attr-value-date    = TODAY
        buf_db-rec-attr.attr-value-logical = TRUE
      .
    end.
  end.
  return.
end.
