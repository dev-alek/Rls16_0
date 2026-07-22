block-level on error undo, throw.
define input parameter p-db-num like ub.ext-file.db-num no-undo .
define input parameter p-from-db-num like ub.ext-file.from-db-num no-undo .
define input parameter p-file-num like ub.ext-file.file-num no-undo .
define input parameter p-dir-path as character no-undo .
define input-output parameter p-override as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extfsavd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/extfsavd.p $":U .
define variable vss-description as character no-undo init "Сохранение на диск файла, хранящегося в БД".
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
define stream sinp .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-binfile-converter-program as character no-undo initial 'exe/base64.exe':U .
define temp-table temp-ext-file-line no-undo like ub.ext-file-line
  .
procedure binfile_clear :
  define input  parameter p-db-num      as integer   no-undo .
  define input  parameter p-from-db-num as integer   no-undo .
  define input  parameter p-file-num    as integer   no-undo .
  define buffer buf_temp-ext-file-line  for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-ext-file-line
      where buf_temp-ext-file-line.db-num   = p-db-num
        and buf_temp-ext-file-line.from-db-num = p-from-db-num
        and buf_temp-ext-file-line.file-num = p-file-num
    on error undo, return error return-value
    :
      delete buf_temp-ext-file-line .
    end.
  end.
end procedure.
procedure binfile_read :
  define input  parameter p-db-num       as integer   no-undo .
  define input  parameter p-from-db-num  as integer   no-undo .
  define input  parameter p-file-num     as integer   no-undo .
  define input  parameter p-file-name    as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-input-full-pathname   as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-read-line             as character no-undo .
  define variable v-line-num              as integer   no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_temp-ext-file-line for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    run binfile_clear in this-procedure
      (input p-db-num
      ,input p-from-db-num
      ,input p-file-num
      ) .
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-temp-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = p-file-name
      v-input-full-pathname   = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
    assign
      v-command-line = substitute('&1 -e "&2" &3':U
                                      ,v-convert-full-pathname
                                      ,v-input-full-pathname
                                      ,v-temp-full-pathname
                                      )
    .
    os-command silent value(v-command-line) .
    input stream sinp from value(v-temp-full-pathname) .
    assign
      v-line-num = 0
    .
    repeat
    :
      assign
        v-read-line = '':U
      .
      import stream sinp unformatted v-read-line .
      if v-read-line <> '':U
      then do:
        assign
          v-line-num  = v-line-num + 1
        .
        create buf_temp-ext-file-line .
        assign
          buf_temp-ext-file-line.db-num       = p-db-num
          buf_temp-ext-file-line.from-db-num  = p-from-db-num
          buf_temp-ext-file-line.file-num     = p-file-num
          buf_temp-ext-file-line.line-num     = v-line-num
          buf_temp-ext-file-line.sub-line-num = 0
          buf_temp-ext-file-line.line-text    = v-read-line
        .
      end.
    end.
    input stream sinp close .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
procedure binfile_write :
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-from-db-num   as integer   no-undo .
  define input  parameter p-file-num      as integer   no-undo .
  define input  parameter p-bin-file-name as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-output-full-pathname  as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_temp-ext-file-line for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
    output stream sinp to value(v-temp-file-name) .
    for each buf_temp-ext-file-line
      where buf_temp-ext-file-line.db-num   = p-db-num
        and buf_temp-ext-file-line.from-db-num = p-from-db-num
        and buf_temp-ext-file-line.file-num = p-file-num
    by buf_temp-ext-file-line.line-num
    by buf_temp-ext-file-line.sub-line-num
    on error undo, return error return-value
    :
      put stream sinp unformatted
        buf_temp-ext-file-line.line-text + chr(10)
        .
    end.
    output stream sinp close .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input p-bin-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = p-bin-file-name
      v-output-full-pathname   = file-info :full-pathname
    .
    assign
      v-command-line =  substitute('&1 -d &2 "&3"':U
                                  ,v-convert-full-pathname
                                  ,v-temp-full-pathname
                                  ,v-output-full-pathname
                                  )
    .
    os-command silent value(v-command-line) .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
procedure binfile_clear-from-db :
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-from-db-num   as integer   no-undo .
  define input  parameter p-file-num      as integer   no-undo .
  define buffer buf_ext-file-line for ub.ext-file-line .
  do
  on error undo, return error return-value
  :
    for each buf_ext-file-line
      where buf_ext-file-line.db-num   = p-db-num
        and buf_ext-file-line.from-db-num   = p-from-db-num
        and buf_ext-file-line.file-num = p-file-num
    on error undo, return error return-value
    :
      delete buf_ext-file-line .
    end.
  end.
end procedure.
procedure binfile_read-to-db :
  define input  parameter p-db-num         as integer   no-undo .
  define input  parameter p-from-db-num    as integer   no-undo .
  define input  parameter p-file-num       as integer   no-undo .
  define input  parameter p-file-name      as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-input-full-pathname   as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-read-line             as character no-undo .
  define variable v-line-num              as integer   no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_ext-file-line for ub.ext-file-line .
  do
  on error undo, return error return-value
  :
    run binfile_clear-from-db in this-procedure
      (input p-db-num
      ,input p-from-db-num
      ,input p-file-num
      ) .
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-temp-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = p-file-name
      v-input-full-pathname   = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
    assign
      v-command-line = substitute('&1 -e "&2" "&3"':U
                                      ,v-convert-full-pathname
                                      ,v-input-full-pathname
                                      ,v-temp-full-pathname
                                      )
    .
    os-command silent value(v-command-line) .
    input stream sinp from value(v-temp-full-pathname) .
    assign
      v-line-num = 0
    .
    repeat
    :
      assign
        v-read-line = '':U
      .
      import stream sinp unformatted v-read-line .
      if v-read-line <> '':U
      then do:
        assign
          v-line-num  = v-line-num + 1
        .
        create buf_ext-file-line .
        assign
          buf_ext-file-line.db-num       = p-db-num
          buf_ext-file-line.from-db-num  = p-from-db-num
          buf_ext-file-line.file-num     = p-file-num
          buf_ext-file-line.line-num     = v-line-num
          buf_ext-file-line.sub-line-num = 0
          buf_ext-file-line.line-text    = v-read-line
        .
      end.
    end.
    input stream sinp close .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
procedure binfile_write-from-db :
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-from-db-num   as integer   no-undo .
  define input  parameter p-file-num      as integer   no-undo .
  define input  parameter p-bin-file-name as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-output-full-pathname  as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_ext-file-line for ub.ext-file-line .
  do
  on error undo, return error return-value
  :
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
    output stream sinp to value(v-temp-file-name) .
    for each buf_ext-file-line
      where buf_ext-file-line.db-num   = p-db-num
        and buf_ext-file-line.from-db-num   = p-from-db-num
        and buf_ext-file-line.file-num = p-file-num
    by buf_ext-file-line.line-num
    by buf_ext-file-line.sub-line-num
    on error undo, return error return-value
    :
      put stream sinp unformatted
        buf_ext-file-line.line-text + chr(10)
        .
    end.
    output stream sinp close .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input p-bin-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = p-bin-file-name
      v-output-full-pathname   = file-info :full-pathname
    .
    assign
      v-command-line =  substitute('&1 -d &2 "&3"':U
                                  ,v-convert-full-pathname
                                  ,v-temp-full-pathname
                                  ,v-output-full-pathname
                                  )
    .
    os-command silent value(v-command-line) .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function prepare-path returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(92), chr(47))
v-prepared-path = right-trim(v-prepared-path, chr(47))
.
return v-prepared-path.
END FUNCTION.
function prepare-path2 returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(47), chr(92))
v-prepared-path = right-trim(v-prepared-path, chr(92))
.
return v-prepared-path.
END FUNCTION.
function quote-spaces returns character ( input p-full-path as character):
define variable v-ii as integer no-undo .
define variable v-result as character no-undo .
do v-ii = 1 to num-entries(p-full-path, chr(92)):
  v-result = v-result + (if v-ii = 1 then '' else chr(92)) +
             (if index(entry(v-ii, p-full-path, chr(92)), chr(32)) > 0
             then  substitute("&1&2&1", chr(34), entry(v-ii, p-full-path, chr(92)))
             else entry(v-ii, p-full-path, chr(92))
             )
  .
end.
return v-result.
end function.
define variable v-full-path-name as character no-undo .
define variable v-md5-signature as character no-undo .
define variable v-dir-type as character no-undo .
define variable v-can-write as logical no-undo .
define variable choice as integer no-undo .
define variable v-is-temp-file as logical no-undo .
define buffer buf_ext-file for ub.ext-file.
do
on error undo, return error return-value
:
   find first buf_ext-file  exclusive-lock where
            buf_Ext-file.db-num = p-db-num
        and buf_Ext-file.from-db-num = p-from-db-num
        and buf_Ext-file.file-num = p-file-num no-error .
  if not available buf_Ext-file then do:
    undo, return error substitute("Не найден файл, сохраненный в БД:&1БД &2 № файла &3"
                          , chr(10)
                          , p-db-num
                          , p-file-num).
  end.
  if p-dir-path = ? then do:
     run gbl/dir-sel.p (
                      output p-dir-path
                    , output v-dir-type
                    , output v-can-write
                          )
      .
    if p-dir-path = ? then do:
      return.
    end.
    if not v-can-write then do:
        message
        substitute("Вы не имеете прав на запись в выбранный каталог &1", p-dir-path)
        view-as alert-box error .
        return error.
    end.
  end.
  file-info:file-name = p-dir-path.
  if file-info:file-type = ?
  or index( file-info:file-type, "D" ) = 0 then do:
    assign
    v-full-path-name = p-dir-path
    v-is-temp-file = yes
    .
  end.
  else do:
  assign
  v-full-path-name = entry(1, buf_ext-file.file-name, ">")
  v-full-path-name = prepare-path(v-full-path-name)
  v-full-path-name = p-dir-path + chr(47) +
                     entry(num-entries(v-full-path-name, chr(47))
                           , v-full-path-name
                           , chr(47)
                          )
  .
  end.
  assign
  file-info:file-name = v-full-path-name.
  if file-info:full-pathname <> ? then do:
    if p-override = 0
    then do:
      run gbl/daskfile.w (
                    input "Дальнейшие действия"
                   ,input v-full-path-name
                   ,input file-info:file-size
                   ,input file-info:file-mod-date
                   ,input file-info:file-mod-time
                   ,input buf_ext-file.file-name
                   ,input buf_Ext-file.file-size
                   ,input buf_Ext-file.update-sys-date
                   ,input buf_Ext-file.update-sys-time-int
                   ,input 4
                   ,input 6
                   ,output choice).
      if choice = 6
      then do:
        p-override = choice.
        return.
      end.
    end.
    if choice = 2
    or choice = 4
    or choice = 5
    then do:
      p-override = choice.
    end.
    if choice = 3
    or choice = 4 then do:
      return.
    end.
  end.
  if file-info:full-pathname = ?
  or (p-override = 1
  or p-override = 2
  or (p-override = 5
      and  (buf_Ext-file.update-sys-date > file-info:file-mod-date
            or
            (buf_Ext-file.update-sys-date = file-info:file-mod-date
            and buf_Ext-file.update-sys-time-int >= file-info:file-mod-time)
            )
     )
  )
  or v-is-temp-file = yes
  then do:
    run binfile_write-from-db in this-procedure (
       input p-db-num
      ,input  p-from-db-num
      ,input  p-file-num
      ,input  v-full-path-name
      ) .
    run gbl/md5.p (
        input  v-full-path-name
      ,output v-md5-signature
      ) .
    if buf_ext-file.crc-field <> v-md5-signature then do:
      if p-dir-path = ? then do:
        message
        substitute("!!!Сохраненный файл &1 имеет неверную сигнатуру md5 - удаляется с диска"
              , v-full-path-name )
        view-as alert-box error .
        .
        os-delete value(v-full-path-name).
        return error .
      end.
      else do:
        return error  substitute("!!!Сохраненный файл &1 имеет неверную сигнатуру md5 - удаляется"
              , v-full-path-name ).
      end.
    end.
  end.
end.
