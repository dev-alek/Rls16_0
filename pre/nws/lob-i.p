block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-counter  as integer   no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-db-num as integer   no-undo .
define input  parameter p-int64-id as int64 no-undo .
define output parameter p-ok as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lob-i.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/lob-i.p $":U .
define variable vss-description as character no-undo init "Прием CLOB или BLOB".
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
define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable log-file-name as character no-undo init "":U.
define variable v-md5-signature as character no-undo .
define variable v-lob-bh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable v-jj as integer   no-undo .
define buffer buf_temp-nws-outline for temp-nws-outline .
define buffer buf_temp-ext-file-line for temp-ext-file-line .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_blob-data for ub.blob-data.
define temp-table temp-clob-data no-undo like ub.clob-data.
define temp-table temp-blob-data no-undo like ub.blob-data.
define buffer buf_temp-clob-data for temp-clob-data.
define buffer buf_temp-blob-data for temp-blob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run write-to-log in p-log-handle (
        input substitute("Получение &1: БД &2 id &3"
                        , p-table-name
                        , p-db-num
                        , p-int64-id
                          )).
  do counter = 1 to p-counter
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if counter modulo 10 = 0
    then do:
      run write-to-screen in p-log-handle (substitute("Получено записей &1", counter)) no-error.
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      undo main-block, return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, chr(1) )
    .
    CASE entry(1, v-rec-name, chr(4)) :
      when 'nws-outline':U then do:
        create buf_temp-nws-outline.
        run nws-impl in p-imp-handle
          ( input 'nws-outline':U
           ,input buffer buf_temp-nws-outline:handle
          ) no-error.
        if error-status :error then do:
          delete buf_temp-nws-outline.
          undo main-block, return error return-value .
        end.
        case p-table-name:
          when 'clob-data':U then do:
            create buf_temp-clob-data.
            assign
            v-lob-bh = buffer buf_temp-clob-data:handle.
          end.
          when 'blob-data':U then do:
            create buf_temp-blob-data.
            assign
            v-lob-bh = buffer buf_temp-blob-data:handle.
          end.
        end case.
        do v-ii = 1 to v-lob-bh:handle:num-fields:
          if not (v-lob-bh:buffer-field(v-ii):data-type = 'clob':U
                  or
                  v-lob-bh:buffer-field(v-ii):data-type = 'blob':U) then do:
              v-jj = v-jj + 1.
              case v-lob-bh:buffer-field(v-ii):data-type:
                when 'character':U then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = entry(v-jj, buf_temp-nws-outline.charkey_one, chr(3))
                .
                end.
                when 'int64':U then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = int64(entry(v-jj, buf_temp-nws-outline.charkey_one, chr(3)))
                .
                end.
                when 'integer':U then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = integer(entry(v-jj, buf_temp-nws-outline.charkey_one, chr(3)))
                .
                end.
                when 'date':U then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = date(entry(v-jj, buf_temp-nws-outline.charkey_one, chr(3)))
                .
                end.
                when 'logical':U then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = logical(entry(v-jj, buf_temp-nws-outline.charkey_one, chr(3)))
                .
                end.
              end case.
          end.
        end.
        case p-table-name:
          when 'clob-data':U then do:
            find first buf_clob-data where
                      buf_clob-data.db-num = buf_temp-clob-data.db-num
                  and buf_clob-data.int64-id = buf_temp-clob-data.int64-id  no-error.
            if not available buf_clob-data then do:
              create buf_clob-data.
            end.
            buffer-copy buf_temp-clob-data
            to buf_clob-data no-lobs.
            v-lob-bh = buffer buf_clob-data:handle.
          end.
          when 'blob-data':U then do:
            find first buf_blob-data where
                      buf_blob-data.db-num = buf_temp-blob-data.db-num
                  and buf_blob-data.int64-id = buf_temp-blob-data.int64-id  no-error.
            if not available buf_blob-data then do:
              create buf_blob-data.
            end.
            buffer-copy buf_temp-blob-data
            to buf_blob-data no-lobs.
            v-lob-bh = buffer buf_blob-data:handle.
          end.
        end case.
      end.
      when 'ext-file-line':U then do:
        create buf_temp-ext-file-line.
        run nws-impl in p-imp-handle
          ( input 'ext-file-line':U
           ,input buffer buf_temp-ext-file-line:handle
          ) no-error.
        if error-status :error then do:
          undo main-block, return error return-value .
        end.
        release buf_temp-ext-file-line.
      end.
    END CASE.
  end.
  run lob_write in this-procedure ( input v-lob-bh) .
  case p-table-name:
    when 'clob-data':U then do:
      if v-md5-signature <> buf_temp-clob-data.crc-field then do:
        run write-to-log in p-log-handle (
                                            substitute("!!!"
                                                  )).
      end.
    end.
    when 'blob-data':U then do:
      if v-md5-signature <> buf_temp-blob-data.crc-field then do:
        run write-to-log in p-log-handle (
                                            substitute("!!!"
                                                  )).
      end.
    end.
  end case.
  p-ok = yes.
  return '':U.
end.
procedure write-to-log :
define input parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
     run write-to-log in p-parent-handle (input p-message) .
  end.
end procedure.
