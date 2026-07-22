define input  parameter parparentproc as widget-handle no-undo .
define input  parameter spr          as character no-undo .
define input  parameter type         as character no-undo .
define output parameter sel_list     as character no-undo .
define output parameter sel_list_rus as character no-undo .
define output parameter incl         as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование фильтров - списки".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,spr,type)
    .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable flt-rec as recid no-undo.
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc ( output g#report-num ).
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info3, p-action-code ).
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
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info3, p-action-code ).
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
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info3, p-action-code ).
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
      return error substitute( "&1 (get-row-keyr-string). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 отсутствует в БД", vss-include-info3, v-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
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
define variable k as int no-undo.
define variable s as char no-undo.
define variable v_type     as char no-undo.
define variable vlistValue    as character no-undo.
define variable vlistValueRet as character no-undo.
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 8.75 BY 1.17 TOOLTIP "Ввести в список значение".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 8.75 BY 1.17 TOOLTIP "Удалить ранее включенное в список значение".
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 8.75 BY 1.17 TOOLTIP "Интерактивная помощь в формате *.html".
DEFINE BUTTON b-spr
     IMAGE-UP FILE "btn-left-arrow":U
     IMAGE-DOWN FILE "btn-left-arrow":U
     IMAGE-INSENSITIVE FILE "btn-left-arrow":U
     LABEL "":L
     SIZE 3 BY .88.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 10 BY 1.17 TOOLTIP "Отменить формирование критерия"
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить":L
     SIZE 10 BY 1.17 TOOLTIP "Сохранить сформированный критерий"
     BGCOLOR 8 .
DEFINE VARIABLE comb AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS " "
     SIZE 41 BY 1 NO-UNDO.
DEFINE VARIABLE in-char AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.
DEFINE VARIABLE in-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.
DEFINE VARIABLE in-dec AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.
DEFINE VARIABLE in-int AS INTEGER FORMAT "->>,>>>,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.
DEFINE VARIABLE list AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE
     SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 41.5 BY 5.5 NO-UNDO.
DEFINE VARIABLE togl AS LOGICAL INITIAL no
     LABEL "Включительно":L
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .83 NO-UNDO.
DEFINE VARIABLE in-log AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Да (Истино)", "TRUE",
"Нет (Ложь)", "FALSE"
     SIZE 14 BY 2.25 NO-UNDO.
DEFINE VARIABLE toggle-date AS LOGICAL INITIAL no
     LABEL "СЕГОДНЯ +/- ДНЕЙ"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.
DEFINE FRAME DIALOG-1
     in-int AT ROW 1.5 COL 3 NO-LABEL
     in-dec AT ROW 1.5 COL 3 NO-LABEL
     in-date AT ROW 1.5 COL 3 NO-LABEL
     in-log  AT ROW 1.5    COL  4.5 NO-LABEL
     toggle-date  AT ROW 1.5  COL 15
     in-char AT ROW 1.5 COL 3 NO-LABEL
     comb AT ROW 1.5 COL 1 COLON-ALIGNED NO-LABEL
     b-spr AT ROW 1.5 COL 31.5
     b-add AT ROW 2.75 COL 3
     b-del AT ROW 2.75 COL 13
     b-help AT ROW 2.75 COL 25.5
     list AT ROW 4.25 COL 3 NO-LABEL
     togl AT ROW 9.75 COL 3
     Btn_OK AT ROW 10.75 COL 3
     Btn_Cancel AT ROW 10.75 COL 34.75
     SPACE(2.12) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ASSIGN
       b-spr:HIDDEN IN FRAME DIALOG-1           = TRUE.
ON CHOOSE OF b-add IN FRAME DIALOG-1
DO:
define variable s-private as character no-undo .
  case type:
     when "character" then do:
        if comb:visible
        then do:
          s = input frame DIALOG-1 comb.
          if vlistValueRet ne ?
          then do:
             k = comb:lookup(s).
             s = entry( k, comb:list-items).
             s-private = entry( k, vlistValueRet)          .
           end.
        end.
        else s = input frame DIALOG-1 in-char.
     end.
     when "date" then
     assign
     s = if (input frame DIALOG-1 in-date = "":U or
             input frame DIALOG-1 in-date = ? or
             input frame DIALOG-1 in-date = "?")
         then chr(63)
         else string(input frame DIALOG-1 in-date, "99/99/9999").
     when "decimal" then s = string(input frame DIALOG-1 in-dec).
     when "integer" then do:
        if    comb:visible in frame DIALOG-1
        then do:
           assign
              s         =  input frame DIALOG-1 comb
              s-private =  entry(lookup(s,vlistValue), vlistValueRet) when vlistValueRet ne ?
          .
        end.
        else do:
           assign
              s = string(input frame DIALOG-1 in-int)
           .
        end.
     end.
     end case.
     k = lookup( s, list:list-items ).
     if k = 0 or k = ? then do:
        if list:add-last( s )
        then do:
           assign
              list:private-data = list:private-data + (if list:private-data = "":u then "":U else chr(44)) + s-private.
        end.
     end.
  apply "entry" to btn_cancel in frame DIALOG-1.
END.
ON CHOOSE OF b-del IN FRAME DIALOG-1
DO:
    define variable k as integer no-undo .
  assign list.
  if list:delete( list ) then do:
    if comb:visible then do:
      replace(list:private-data, entry(lookup(comb, comb:list-items), vlistValueRet), "":U) no-error .
      replace(list:private-data, (chr(44) + chr(44)), chr(44)).
    end.
  end.
    def var vValue as character no-undo .
    list:private-data = "" .
    do k = 1 to num-entries(list:list-items):
        vValue = entry(k,list:list-items) .
        list:private-data = list:private-data + chr(44) + entry(lookup(vValue,vListValue,","),vListValueRet,",") .
    end.
    list:private-data = trim(list:private-data,",") .
END.
ON CHOOSE OF b-spr IN FRAME DIALOG-1
DO:
  define variable grp-rec as recid no-undo.
  define variable ref-rec as recid no-undo.
  define variable grps as char no-undo.
  define variable gdss as char no-undo.
  define variable grp_name as char no-undo.
  define variable ref-list as char no-undo.
  define variable out-an as int no-undo.
  define buffer buf_db for ub.db.
  define variable  rid-list as character no-undo .
  case spr:
         when 'pay' then do:
            run ref/paytype.w ( input parparentproc, "b-sel", output  rid-list ).
            find ub.pay-type where recid ( ub.pay-type ) = integer( rid-list) no-lock no-error.
            if available ub.pay-type then do:
               in-int = ub.pay-type.obj-code.
               disp in-int with frame DIALOG-1.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'curr' then do:
            assign
            ref-rec = ?.
            run ref/currency.w (parparentproc, "b-sel", input-output ref-rec ).
            if ref-rec = ? then return no-apply.
            find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
            if available ub.currency then do:
               in-int = ub.currency.curr-code.
               disp in-int with frame DIALOG-1.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'unit' then do:
            run ref/units.w (
                          input parparentproc
                        , input yes
                        , output ref-rec).
            if ref-rec = ? then return no-apply.
            find ub.units where recid ( ub.units ) = ref-rec no-lock.
            if available ub.units then do:
               in-char = ub.units.unit-name.
               disp in-char with frame DIALOG-1.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'country' then do:
            run ref/countris.w (input parparentproc
                           ,input "b-sel"
                           ,input-output rid-list).
            if ref-rec = ? then return no-apply.
            find ub.country where recid ( ub.country ) = integer(rid-list) no-lock.
            if available ub.country then do:
               in-char = ub.country.alpha1.
               disp in-char with frame DIALOG-1.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'prt' then do:
            run ref/gdsprts.w ( parparentproc, yes, output ref-rec).
            find  ub.gds-prt where recid ( ub.gds-prt ) = ref-rec no-lock.
            if available ub.gds-prt then do:
               in-int = ub.gds-prt.upper-code.
               disp in-int with frame DIALOG-1.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'cligrp' then do:
                  ref-list = "".
                  run ref/cli-grps.w (input parparentproc, "b-sel", input-output ref-list).
                  grp-rec = int(ref-list).
                  if grp-rec <> 0 then do:
                     find ub.cli-grp where recid(ub.cli-grp) = grp-rec.
                     run cli-grplib-get-full-name in this-procedure(input ub.cli-grp.node-code, output grp_name).
                     in-char = grp_name.
                     disp in-char with frame DIALOG-1.
                     apply "choose" to b-add.
                     return no-apply.
                  end.
         end.
         when 'gdsgrp' then do:
          ref-list = "".
          run ref/gds-grp.w ( input parparentproc
                             ,input "b-sel"
                             ,input '':U
                             ,input 0
                             ,input-output ref-list).
          grp-rec = int(ref-list).
          if grp-rec <> 0 then do:
              find ub.gds-grp where recid(ub.gds-grp) = grp-rec.
              run grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output grp_name).
              in-char = grp_name.
              disp in-char with frame DIALOG-1.
              apply "choose" to b-add.
              return no-apply.
          end.
          else apply "entry" to b-spr.
         end.
         when 'db' then do:
          run adm/dbs.w (
                        input parparentproc
                       ,input 'ПРОСМОТР':U
                       ,output ref-rec).
          if ref-rec <> ? then do:
            find first buf_db no-lock where recid(buf_db) = ref-rec no-error.
            if available buf_db then do:
              assign
              in-int = buf_db.db-num
              .
              disp in-int with frame DIALOG-1.
              apply "choose" to b-add in frame DIALOG-1.
              return no-apply.
            end.
            else apply "entry":U to b-spr in frame DIALOG-1.
          end.
         end.
  end case.
END.
ON VALUE-CHANGED OF comb IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame DIALOG-1.
END.
ON RETURN OF in-char IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame DIALOG-1.
END.
ON RETURN OF in-date IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame DIALOG-1.
END.
ON RETURN OF in-dec IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame DIALOG-1.
END.
ON RETURN OF in-int IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame DIALOG-1.
END.
ON VALUE-CHANGED OF list IN FRAME DIALOG-1
DO:
  assign list.
  case type:
     when "character" then do:
        if comb:visible
        then do:
           comb = list.
           disp comb with frame DIALOG-1.
        end.
        else do:
           in-char = list.
           disp in-char with frame DIALOG-1.
        end.
     end.
     when "date" then do:
        in-date = date(list).
        disp in-date with frame DIALOG-1.
     end.
     when "decimal" then do:
        in-dec = decimal(list).
        disp in-dec with frame DIALOG-1.
     end.
     when "integer" then do:
        if comb:visible
        then do:
           comb = list.
           disp comb with frame DIALOG-1.
        end.
        else do:
           in-int = integer( list ).
           disp in-int with frame DIALOG-1.
        end.
     end.
  end case.
END.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame DIALOG-1 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame DIALOG-1. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
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
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of in-date in frame DIALOG-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of in-date in frame DIALOG-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of in-date in frame DIALOG-1
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of in-date in frame DIALOG-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of in-date in frame DIALOG-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of in-date in frame DIALOG-1
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date9
    MENU-ITEM m-ed-date9-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date9-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date9-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date9-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if in-date :POPUP-MENU in frame DIALOG-1 = ?
  then do:
    ASSIGN
      in-date :POPUP-MENU in frame DIALOG-1 = MENU m-ed-date9 :HANDLE
      in-date :MENU-MOUSE in frame DIALOG-1 = 3
    .
  end.
  define variable v-label-handle9 as handle no-undo .
  assign
    v-label-handle9 = in-date :side-label-handle in frame DIALOG-1
  .
  if valid-handle (v-label-handle9)
  then do:
    if v-label-handle9 :tooltip = ""
    or v-label-handle9 :tooltip = ?
    then do:
      assign
        v-label-handle9 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date9-1 in menu m-ed-date9 DO:
    apply "ctrl-b":U to in-date in frame DIALOG-1 .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-2 in menu m-ed-date9 DO:
    apply "ctrl-d":U to in-date in frame DIALOG-1 .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-3 in menu m-ed-date9 DO:
    apply "ctrl-e":U to in-date in frame DIALOG-1 .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-4 in menu m-ed-date9 DO:
    apply "ctrl-f":U to in-date in frame DIALOG-1 .
  END.
MAIN-BLOCK:
DO ON ERROR    UNDO MAIN-BLOCK, return error
      ON STOP       UNDO MAIN-BLOCK, return error
      ON END-KEY UNDO MAIN-BLOCK, return error :
  if can-do( "cligrp,gdsgrp,pay,curr,unit,prt,country,db", spr ) then
     assign
       b-spr:sensitive = yes
       b-spr:visible     = yes
       togl                   = yes.
  RUN UI_on.
  WAIT-FOR GO OF FRAME DIALOG-1.
  assign list.
  if list:num-items = 0 then return error.
  assign incl = input frame DIALOG-1 togl.
  assign
  sel_list_rus = list:list-items
  sel_list     = (if vlistValueRet ne ? then list:private-data else list:list-items)
  .
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY in-int in-dec in-date in-char comb list togl
      WITH FRAME DIALOG-1.
  ENABLE in-int in-dec in-date in-char comb b-add b-del list togl Btn_OK
         Btn_Cancel b-help
      WITH FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE UI_on :
assign
list:private-data in frame DIALOG-1 = "".
  disp togl with frame DIALOG-1.
  enable b-add b-del list togl Btn_OK Btn_Cancel b-help with frame DIALOG-1.
run InitForm.
toggle-date:visible = false.
END PROCEDURE.
procedure InitForm :
   define variable v-time as integer no-undo .
   define variable dca as integer no-undo .
   define variable v-label as character no-undo .
   define variable v-tooltip as character no-undo .
   define variable ii as integer no-undo .
   define variable v-device-kind as character no-undo .
   define variable v-device-integer as character no-undo .
   DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
   define variable objType    as ibs.th.gbl.propmap no-undo.
   define variable mCashDevice      as ibs.th.str.cash.CashDevice no-undo.
   assign
      vlistValue    = ""
      vlistValueRet = ""
   .
   publish "getComboList" (spr,output vlistValue, output vlistValueRet).
   if vlistValue eq ""
   then
      vlistValue = ?.
   if vlistValueRet eq ""
   then
      vlistValueRet = ?.
   case type:
      when "character" then do:
         if can-do( "trn-stat,trn-type,order-status-all,order-type-all,ext-doc-type,pr-stat,fbr-stat,gds-type,form-type,actions," +
                     "tbl-name,purch-code,fin-doc-stat,fin-doc-type,fin-ext-doc-type," +
                     "gds-hist-subject,cli-hist-subject,dc-hist-subject,dc-type-hist-subject,tax-hist-subject,hist-source-type,scl-hist-subject," +
                     "contract-type,usl-opl,db-rec-attr-type,db-rec-attr-cmd,nws-coll_codes," +
                     "gds-grp-hist-subject,cli-grp-hist-subject,fbr-gds-grp-hist-subject,plc-hist-subject,pmp-hist-subject,nzl-hist-subject," +
                     "sht-hist-subject,sert-hist-subject," +
                     "cd-types,cd-types-real,cd-types-discnt,rcv-type-all,wth-ext-type", spr )
            or vlistValue ne ?
         then do:
            frame DIALOG-1:title = "Выберите значение".
            if vlistValue eq ?
            then
               case spr:
                  when "trn-stat"            then vlistValue = 'запрос,накл,разрешен,факт,касс,прво,готов,отказ':U.
                  when "order-status-all"    then vlistValue = 'новый,факт,согласование,отказ,поставка,закрыто,распределение,запрос,разрешено,отгружено'.
                  when "order-type-all"      then vlistValue = 'ОФ,ФП,ОП,ОО,ОР,ПО'.
                  when "trn-type"            then vlistValue = 'при,рас,спи,возврат,инв':U.
                  when "db-rec-attr-type"    then vlistValue = "commit,execution,recover".
                  when "fin-doc-stat"        then vlistValue = 'новый,разрешен,банк,факт,отказ':U.
                  when "fin-doc-type"        then vlistValue = 'пко,рко,ппп,рпп,апп,апр':U.
                  when "pr-stat"             then vlistValue = ',приказ,разрешен,акт':U.
                  when "fbr-stat"            then vlistValue = ',разрешен,факт':U.
                  when "gds-type"            then vlistValue = 'т,у':U.
                  when "actions"             then vlistValue = 'у,с,и':U.
                  when "tbl-name"            then vlistValue = 'накладная,переоценка,гр-товаров,гр-блюд,гр-клиентов,автопров.,проводки,состав_проводки,группа_проводок,инвойсы,счета,аналитика,баланс,форма,корреспонденция,рецепт,рецепт,производство,продажа,доп-БК,фирма,человек,магазин,склад,ТО,ставки_на_товар,категория_налога,ТРК,пистолет_ТРК,склд.место,д-карта,маг-курс,признак,товар,оплата,кас_тов,ставки_на_товар,ед_изм,суммы,смена,МЦ,номинал_МЦ,место_хран_МЦ,док_перемщ_МЦ,конфигурация,принтер_кухни,группа_тов-принтер_кухни':U.
                  when "purch-code"          then vlistValue = 'выкуп,консигнация,ответственное хранение,старая консигнация':U.
                  when "form-type"           then vlistValue = "".
                  when "contract-type"       then vlistValue = 'Купли-продажи,Консигнации,Ответственного хранения,Агентский договор,Давальческого сырья,Продажи через ТПСИ,о Дополнительных расходах':U .
                  when "usl-opl"             then vlistValue = 'Не определено,По заказу,По поставке заказа,Отсрочка платежа по заказу,Отсрочка платежа по поставке заказа,По факту поставки,По факту реализации,Отсрочка платежа (по поставке),Отсрочка платежа (по реализации),По реализации части приход. накладной,По спецификации,Отсрочка платежа по спецификации,Предоплата,Предоплата(%),По факту поставки покупателю,Отсрочка платежа по поставке':U .
                  when "rcv-type-all"        then
                     assign
                        vlistValue    = 'внешн,внутр,запрос'
                        vlistValueRet = 'out,in,запрос'
                     .
                  when "ext-doc-type"        then
                     assign
                        vlistValue    = 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U
                        vlistValueRet = 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U
                     .
                  when "db-rec-attr-cmd"     then do:
                     assign
                        vlistValueRet = ( 'crush_code-range':U + chr(44) + 'delete_code-range':U + chr(44) + 'delete_nu-prt-bar-code':U + chr(44) + 'delete_nu-part-bar-code':U + chr(44) + 'delete_nu-ucli-bar-code':U + chr(44) + 'delete_nu-dis-card':U + chr(44) + 'chown-dis-card':U + chr(44) + 'delete_nu-dis-rule':U + chr(44) + 'delete_nu-clob-data':U + chr(44) + 'delete_nu-layout':U + chr(44) + 'ren-art':U )
                        vlistValue = "":U
                     .
                     do ii = 1 to num-entries(vlistValueRet):
                        vlistValue = (if ii = 1 then "":U else vlistValue) +
                                     (if ii = 1 then "":U else chr(44)) +
                                     progs-title-function(entry(ii, vlistValueRet))
                        .
                     end.
                  end.
                  when "nws-coll_codes" then do:
                     assign
                        vlistValueRet = 'ncoll_inn':U
                        vlistValue    = "":U
                     .
                                          do ii = 1 to num-entries('ncoll_inn':U):
                        vlistValue = (if ii = 1 then "":U else vlistValue) +
                                     (if ii = 1 then "":U else chr(44)) +
                                     entry (lookup (entry(ii, vlistValue), 'ncoll_inn':U), 'Коллизия по ИНН':U)
                        .
                     end.
                  end.
                  when "fin-ext-doc-type" then do:
                     assign
                        vlistValue = 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,апп,апр':U
                        vlistValueRet = 'пко,рко,ппп,рпп,апп,апр,':U
                     .
                  end.
                  when "gds-hist-subject"  then do:
                     assign
                        vlistValue    = 'Товар,Атр-т товара,Атр-т тов. на фирме,Атр-т тов. на объекте,Атрибут РЕСТОРАНа,Сезонный коэфф,Бар-код,Атрибуты бар-кодов,Атрибуты бар-кода на объекте,ДопБК,Варианты доставки,Сезон товара,Ставки налогов,Содержимое ассортиментных матр,Индикаторы,Товар на складском месте,Товар на ТРК,Сертификат на товар,АттрТовара на скл.месте,Скидка Товара на объ.,Внешний артикул товара,Внешний классификатор,Рецепт,Товар рецепта,Товар на объекте,Атр-т тов. для заказов':U
                        vlistValueRet = 'goods,goods-attr,gds-host-attr,gds-obj-attr,fbr-gds-obj,s-coeff,bar-code,bar-code-attr,bar-code-obj-attr,prod-bc,varianty-delivery-gds-obj,gds-season,tax-rate-gds,assortment-matrix-goods,gds-obj-prop,pl-gds,pl-gds-pump,sert-join,pl-gds-attr,dis-gds-rule,ext-artic,ext-classif,recipe,recipe-gds,gds-obj,gds-obj-prop-attr':U
                     .
                  end.
                  when "cli-hist-subject"  then
                     assign
                        vlistValue    = 'Клиент,Атрибут клиента,Параметры объекта TH,Своя фирма,Организация,Физ.лицо,Магазин,store,Персонал,Общие скидки,Внешний классификатор':U
                        vlistValueRet = 'clients,clients-attr,thbj-attr,sysconf,firm,person,shop,store,staff,dis-thbj-rule,ext-classif':U
                     .
                  when "dc-hist-subject"  then
                     assign
                        vlistValue    = 'Диск.карта,Свойства ДК,Итоги ДК на объ.,Итоги ДК фирма/общ,Скидки для ДК':U
                        vlistValueRet = 'dis-card,dis-card-property,dis-obj,dis-host,dis-dc-rule':U
                     .
                  when "dc-type-hist-subject"  then
                     assign
                        vlistValue    = 'Тип диск.карты,Аттр.типа диск.карты,Маска диск.карты,Привязка профайла к месту,Вызов правила,Параметры вызова правил,Скидки на типы ДК,Опции созд. ист. и маршрут.':U
                        vlistValueRet = 'dis-card-type,dis-card-type-attr,dis-card-mask,rp-by-call,rule-by-call,rule-call-param,dis-dct-rule,hist-nws-option':U
                     .
                  when "tax-hist-subject"  then do:
                     assign
                        vlistValue    = 'Налог,Ставка налога,Знач.ставки налога,Налоги на тип ед.изм.':U
                        vlistValueRet = 'tax,tax-rate,tax-rate-value,tax-units':U
                     .
                  end.
                  when "gds-grp-hist-subject"  then
                     assign
                        vlistValue    = 'Группа товаров,Атр-т группы товаров,Группа товаров на объекте,Налоги группы товаров,Скидки по группе':U
                        vlistValueRet = 'gds-grp,gds-grp-attr,gds-grp-obj,tax-rate-gds-grp,dis-grp-rule':U
                     .
                  when "cli-grp-hist-subject"  then
                     assign
                        vlistValue    = 'Группа клиентов,Скидки по группе':U
                        vlistValueRet = 'cli-grp,dis-grp-rule':U
                     .
                  when "fbr-gds-grp-hist-subject"  then
                     assign
                        vlistValue    = 'Группа блюд,Атр-т группы блюд':U
                        vlistValueRet = 'fbr-gds-grp,fbr-gds-grp-attr':U
                     .
                  when "plc-hist-subject"  then
                     assign
                        vlistValue    = 'Складское место,Товар на складском месте,Товар на ТРК,Резервуар/ТРК,Резервуар/ТРК/Пистолет,Атрибут Скл. места':U
                        vlistValueRet = 'place,pl-gds,pl-gds-pump,pl-pump,pl-pump-nozzle,place-attr':U
                     .
                  when "pmp-hist-subject"  then
                     assign
                        vlistValue    = 'Товар на ТРК,Резервуар/ТРК,Резервуар/ТРК/Пистолет,ТРК/Пистолет,ТРК,Атрибут ТРК':U
                        vlistValueRet = 'pl-gds-pump,pl-pump,pl-pump-nozzle,pump-nozzle,pump,pump-attr':U
                     .
                  when "nzl-hist-subject"  then
                     assign
                        vlistValue    = 'Пистолет,Резервуар/ТРК/Пистолет,ТРК/Пистолет,Атрибут Пистолета':U
                        vlistValueRet = 'nozzle,pl-pump-nozzle,pump-nozzle,nozzle-attr':U
                     .
                  when "sht-hist-subject"  then
                     assign
                        vlistValue    = 'Смена,Персонал смены':U
                        vlistValueRet = 'shift-obj,shift-staff':U
                     .
                  when "sert-hist-subject"  then
                     assign
                        vlistValue = 'Сертификат,Сертификат на товар':U
                        vlistValueRet = 'sert,sert-join':U
                     .
                  when "hist-source-type"  then do:
                     assign
                        vlistValue    = ',БД,ВС,Документ,Платеж,Фин.док.,Импорт,Пересчет,Документ МЦ,Коллизия,Апгрейд,Изм.группы,Стоплист,ДК':U
                        vlistValueRet = ',db,esys,trn-doc,payment,fin-doc,import,recalc,wth-doc,ren-gdsc,upgrade,grp-chg,stop-list,dis-card':U
                     .
                  end.
                  when "scl-hist-subject"  then do:
                     assign
                        vlistValue    = 'Весы,Группы товаров на весах,Товар на весах,Атрибут весов':U
                        vlistValueRet = 'scales,scales-grp,scales-gds,scales-attr':U
                     .
                  end.
                  when "cd-types" then do:
                     assign
                        vlistValue    = 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U
                        vlistValueRet = 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U
                     .
                  end.
                  when "cd-types-real" then do:
                     assign
                        vlistValue    = 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA':U
                        vlistValueRet = 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U
                     .
                  end.
                  when "cd-types-discnt" then do:
                     assign
                        vlistValue    = 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,MARIA,Накладная,Бэкофис':U
                        vlistValueRet = 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U
                     .
                  end.
                  when "wth-ext-type" then do:
                     assign
                        vlistValue    = 'приход внешний,расход внешний,приход внутренний,расход внутренний,приход внутри объекта,расход внутри объекта,приход внутриобъектн. в своб. зону,расход внутриобъектн. из своб. зоны,приход внутриобъектн. в зону погаш.,расход внутриобъектн. из зоны погаш.,списание,приход внешний через кассы,возврат покупателю через кассы,инвентаризация,возврат внутренний,приход внутр. в зону погашения,расход внутр. из зоны погашения,возврат внутр. в зону погашения,приход внутр. в своб. зону,расход внутр. из своб. зоны,возврат внутр. в своб зону,погашение через кассу,погашение за реализованное топливо,возврат от покупателя,уничтожение в свободной зоне,уничтожение в зоне погашения,уничтожение в зоне клиента,декларация,обмен':u
                        vlistValueRet = 'ie,ee,ii,ei,ij,ej,fj,jj,pj,oj,we,ci,ce,iy,rj,ip,ep,rp,ff,ef,rf,pc,ps,pz,df,dp,dc,de,xc':u
                     .
                  end.
               end case.
            comb:list-items   = vlistValue.
            if num-entries(vlistValue) > 2
            then
               comb:inner-lines = num-entries(vlistValue).
            comb = entry(1,comb:list-items).
            disp comb with frame DIALOG-1.
            enable comb  Btn_OK Btn_Cancel b-help with frame DIALOG-1.
            assign
               in-char     :visible = no
               in-date     :visible = no
               toggle-date :visible = no
               in-dec      :visible = no
               in-int      :visible = no
               in-log      :visible = no
            .
         end.
         else do:
            frame DIALOG-1:title = "Введите символьное значение".
            disp in-char with frame DIALOG-1.
            enable in-char  Btn_OK Btn_Cancel b-help with frame DIALOG-1.
            assign
               comb        :visible = no
               in-date     :visible = no
               toggle-date :visible = no
               in-dec      :visible = no
               in-int      :visible = no
               in-log      :visible = no
            .
         end.
      end.
      when "date" then do:
         frame DIALOG-1:title = "Введите дату".
         run cur-time in this-procedure (output in-date, output v-time).
         disp in-date toggle-date with frame DIALOG-1.
         enable in-date toggle-date Btn_OK Btn_Cancel b-help with frame DIALOG-1.
         assign
            comb        :visible = no
            in-char     :visible = no
            in-dec      :visible = no
            in-int      :visible = no
            in-log      :visible = no
         .
      end.
      when "decimal" then do:
         frame DIALOG-1:title = "Введите десятичное значение".
         disp in-dec with frame DIALOG-1.
         enable in-dec  Btn_OK Btn_Cancel b-help with frame DIALOG-1.
         assign
            comb        :visible = no
            in-date     :visible = no
            toggle-date :visible = no
            in-char     :visible = no
            in-int      :visible = no
            in-log      :visible = no
         .
      end.
      when "integer" then do:
       mCashDevice      = new ibs.th.str.cash.CashDevice().
       do v-ii = 1 to mCashDevice:mapType:GetItem(v-ii):
           objType = mCashDevice:CurrProp.
           v-device-kind = v-device-kind + chr(44) + objType:Label_ .
           v-device-integer = v-device-integer + chr(44) + string(objType:KeyIntDB) .
       end.
         if    can-do( "course-type,purch-code,hist-action,receipt-code,wth-receipt-code,cd-device-kind", spr )
            or vlistValue ne ?
         then do:
            frame DIALOG-1:title = "Выберите значение".
            if vlistValue eq ?
            then
               case spr :
                  when "course-type" then assign vlistValue = "ЦБ,ММВБ" vlistValueRet = "1,2".
                  when "purch-code"  then assign vlistValue = 'выкуп,консигнация,ответственное хранение,старая консигнация':U
                                                 vlistValueRet = '1,2,3,4':U
                                     .
                  when "hist-action"  then
                     assign
                        vlistValue    = 'Удаление,Создание,Изменение,Коррекция,Восстановление,Смена_кода,Смена_артик,Выключ.':U
                        vlistValueRet = '99,1,2,3,4,9,51,79':U
                     .
                  when "receipt-code" then assign vlistValue    = 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Приход_Корр,Расход_Корр':U
                                                  vlistValueRet = '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,43,44':U
                                           .
                  when "wth-receipt-code" then assign vlistValue    = 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U
                                                      vlistValueRet = '2,3,4,5,7':U
                                               .
                  when "cd-device-kind" then do:
                      assign
                      vlistValue = trim(v-device-kind,",")
                      vlistValueRet = trim(v-device-integer,",")
                      .
                  end.
               end case.
            comb:list-items   = vlistValue.
            if num-entries(vlistValue) > 2
            then
               comb:inner-lines = num-entries(vlistValue).
            assign comb = entry( 1, comb:list-items ).
            disp comb with frame DIALOG-1.
            enable comb  Btn_OK Btn_Cancel b-help with frame DIALOG-1.
            assign
               in-char:visible = no
               in-date:visible = no
               toggle-date:visible = no
               in-dec:visible  = no
               in-int:visible    = no
               in-log:visible   = no.
         end.
         else do:
            frame DIALOG-1:title = "Введите целое значение".
            disp in-int with frame DIALOG-1.
            enable in-int  Btn_OK Btn_Cancel b-help with frame DIALOG-1.
            assign
               comb        :visible = no
               in-date     :visible = no
               toggle-date :visible = no
               in-dec      :visible = no
               in-char     :visible = no
               in-log      :visible = no
            .
         end.
      end.
      when "logical" then do:
         frame DIALOG-1:title = "Выберите логическое значение".
         disp in-log with frame DIALOG-1.
         enable in-log  Btn_OK Btn_Cancel b-help with frame DIALOG-1.
         assign
            comb        :visible = no
            in-date     :visible = no
            toggle-date :visible = no
            in-dec      :visible = no
            in-int      :visible = no
            in-char     :visible = no
         .
      end.
   end case.
end procedure.
