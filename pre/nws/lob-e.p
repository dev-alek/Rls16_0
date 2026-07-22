block-level on error undo, throw.
define input parameter p-lob-bh as handle no-undo .
define input  parameter p-db-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lob-e.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/lob-e.p $":U .
define variable vss-description as character no-undo init "Отсылка CLOB-DATA или BLOB-DATA по СПН".
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
define temp-table temp-nws-outline no-undo like ub.nws-outline.
define temp-table temp-ext-file-line no-undo like ub.ext-file-line.
procedure lob_clear :
  define buffer buf_temp-nws-outline  for temp-nws-outline .
  define buffer buf_temp-ext-file-line  for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-nws-outline
    on error undo, return error return-value
    :
      delete buf_temp-nws-outline .
    end.
    for each buf_temp-ext-file-line
    on error undo, return error return-value
    :
      delete buf_temp-ext-file-line .
    end.
  end.
end procedure.
procedure lob_read :
  define input  parameter p-lob-bh      as handle no-undo .
  define variable v-read-line             as character no-undo format "X(255)".
  define variable v-line-num              as integer   no-undo .
  define variable v-size                  as int64     no-undo .
  define variable v-cursor                as int64     no-undo .
  define variable v-longchar              as longchar  no-undo .
  define variable v-memptr                as memptr    no-undo .
  define buffer buf_temp-ext-file-line for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    run lob_clear in this-procedure       .
    if p-lob-bh:table = 'blob-data':U then do:
      COPY-LOB
      from object p-lob-bh:buffer-field("bdata"):buffer-value
      to v-memptr.
    end.
    else do:
      COPY-LOB
      from object p-lob-bh:buffer-field("cdata"):buffer-value
      to v-memptr.
    end.
     v-longchar = BASE64-ENCODE(v-memptr).
     COPY-LOB
     from v-longchar
     to v-memptr.
     v-size = get-size(v-memptr).
     v-longchar = '':U.
    assign
      v-line-num = 0
    .
    repeat while v-cursor < v-size
    :
      assign
        v-read-line = '':U
      .
      v-read-line = GET-STRING ( v-memptr , v-cursor + 1, (if v-line-num * 2048 <= v-size
                                                           then 2048
                                                           else (v-size - (v-line-num - 1)* 2048) ) ).
      create buf_temp-ext-file-line.
      assign
      v-line-num = v-line-num + 1
      v-cursor = v-cursor + length(v-read-line)
      buf_temp-ext-file-line.db-num         = -1
      buf_temp-ext-file-line.file-num       = -1
      buf_temp-ext-file-line.from-db-num    = -1
      buf_temp-ext-file-line.line-num       = v-line-num
      buf_temp-ext-file-line.line-text      = v-read-line
      .
    end.
    set-size(v-memptr) = 0.
  end.
end procedure.
procedure lob_write :
  define input  parameter p-lob-bh        as handle no-undo .
  define variable v-memptr as memptr no-undo .
  define variable v-memptr1 as memptr no-undo .
  define variable v-read-line             as character no-undo format "X(255)".
  define variable v-line-num              as integer   no-undo .
  define variable v-size                  as int64     no-undo .
  define variable v-cursor                as int64     no-undo .
  define variable v-longchar              as longchar  no-undo .
  define buffer buf_temp-ext-file-line for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-ext-file-line
    by buf_temp-ext-file-line.db-num
    by buf_temp-ext-file-line.file-num
    by buf_temp-ext-file-line.from-db-num
    by buf_temp-ext-file-line.line-num
    on error undo, return error return-value
    :
      assign
      v-size = v-size + length(buf_temp-ext-file-line.line-text).
    end.
    if v-size = 0 then return.
    set-size(v-memptr) = v-size.
    set-size(v-memptr1) = integer(8 / 6 * v-size) + 1.
    for each buf_temp-ext-file-line
    by buf_temp-ext-file-line.db-num
    by buf_temp-ext-file-line.file-num
    by buf_temp-ext-file-line.from-db-num
    by buf_temp-ext-file-line.line-num
    on error undo, return error return-value
    :
      PUT-STRING ( v-memptr , v-cursor + 1, length(buf_temp-ext-file-line.line-text) ) = buf_temp-ext-file-line.line-text.
      assign
      v-cursor = v-cursor + length(buf_temp-ext-file-line.line-text).
    end.
    COPY-LOB
    from v-memptr
    to v-longchar.
    v-memptr1 = BASE64-DECODE(v-longchar).
    v-longchar = '':U.
    if p-lob-bh:table = 'blob-data':U then do:
      COPY-LOB
      from v-memptr1
      to object p-lob-bh:buffer-field("bdata"):buffer-value
      .
    end.
    else do:
      COPY-LOB
      from v-memptr1
      to object p-lob-bh:buffer-field("cdata"):buffer-value
      .
    end.
    set-size(v-memptr) = 0.
    set-size(v-memptr1) = 0.
  end.
end procedure.
define variable v-cmd-proc-handle as handle no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-rec-ord as integer   no-undo .
define variable v-ii as integer   no-undo .
define buffer buf_db for ub.db.
define buffer buf_temp-nws-outline for temp-nws-outline.
define buffer buf_temp-ext-file-line for temp-ext-file-line.
main-block:
do
on error undo, return error return-value
:
  if p-lob-bh:available = no then do:
     message
     vss-workfile vss-revision vss-description skip
     "Передан буфер без записи"
     view-as alert-box error .
     undo main-block, return error .
  end.
  if not (p-lob-bh:table = 'clob-data':U
          or
          p-lob-bh:table = 'blob-data':U) then do:
     message
     vss-workfile vss-revision vss-description skip
     substitute("Работает только для &1 или &2", 'clob-data':U, 'blob-data':U)
     view-as alert-box error .
     undo main-block, return error .
  end.
  if p-db-list = '':U then do:
    if g#db-num > 0 then do:
       assign
       p-db-list = string(0).
    end.
    else do:
      for each buf_db where buf_db.db-num > 0 no-lock
      on error  undo,  return  error :
        assign p-db-list = p-db-list + chr(1) + string(buf_db.db-num).
      end.
      assign
      p-db-list = trim(p-db-list, chr(1))
      .
    end.
  end.
  run lob_read in this-procedure (
     input  p-lob-bh
    ) .
  if not valid-handle(v-cmd-proc-handle ) then dO:
    run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo main-block, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
  end.
  run begin-create-command in v-cmd-proc-handle (
                                                input  ('cmd-send-lob':U  + chr(6)
                                                      + p-lob-bh:table + chr(6)
                                                      + string(p-lob-bh::db-num) + chr(6)
                                                      + string(p-lob-bh::int64-id) )
                                                ,INPUT  p-db-list
                                                ,output v-cmd-code
    ) no-error.
  if error-status :error
  then do:
    delete procedure v-cmd-proc-handle .
    undo main-block, return error substitute("&1 &2 &3&4Ошибка при создании команды &5&4" +
                                        "&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,'cmd-send-binary':U
                                        ,error-status:get-message(1)
                                        ,return-value ).
  end.
  create buf_temp-nws-outline.
  assign
  buf_temp-nws-outline.outline-type = p-lob-bh:table
  buf_temp-nws-outline.no-id = 0
  .
  do v-ii = 1 to p-lob-bh:num-fields:
    if not (p-lob-bh:buffer-field(v-ii):data-type = 'clob':U
            or
            p-lob-bh:buffer-field(v-ii):data-type = 'blob':U) then do:
      assign
      buf_temp-nws-outline.charkey_one = buf_temp-nws-outline.charkey_one +
                                         (if v-ii = 1 then '':U else chr(3)) +
                                         string((if p-lob-bh:buffer-field(v-ii):buffer-value = ? then chr(63) else p-lob-bh:buffer-field(v-ii):buffer-value)).
    end.
  end.
  run add-dump in v-cmd-proc-handle
    (input v-cmd-code
    ,input 'nws-outline':U
    ,input '+update'
    ,input buffer buf_temp-nws-outline:handle
    ,input '':U
    ,output v-rec-ord
    ) no-error .
  if error-status :error
  then do:
    delete procedure v-cmd-proc-handle .
    undo main-block, return error substitute("&1 &2 &3Ошибка при добавлении записи &4 в команду с кодом &5 &6&3" +
                                        "&7&3БД"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,chr(10)
                                        ,p-lob-bh:table
                                        ,v-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value
                                        ).                                                       ~
  end.
  for each buf_temp-ext-file-line
  by buf_temp-ext-file-line.db-num
  by buf_temp-ext-file-line.file-num
  by buf_temp-ext-file-line.from-db-num
  by buf_temp-ext-file-line.line-num:
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code
      ,input 'ext-file-line':U
      ,input '+update'
      ,input (buffer buf_temp-ext-file-line:handle)
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo main-block, return error substitute("&1 &2 &3Ошибка при добавлении записи &4 в команду с кодом &5 &6&3" +
                                          "&7&3БД"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,chr(10)
                                          ,p-lob-bh:table
                                          ,v-cmd-code
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ).                                                       ~
    end.
  end.
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code
      ,input p-db-list
      ) no-error .
  if error-status :error then do:
    delete procedure v-cmd-proc-handle .
    undo main-block, return error substitute("&1 &2 &3&4Ошибка при отправке в новости команды с кодом &5 БД &8&4" +
                                        "&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,v-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value
                                        ,p-lob-bh::db-num
                                        ).
  end.
  delete procedure v-cmd-proc-handle .
end.
