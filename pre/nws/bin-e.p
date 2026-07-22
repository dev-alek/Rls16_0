block-level on error undo, throw.
define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-file-num as integer no-undo .
define input parameter p-full-path-name as character no-undo .
define input parameter p-path-type as integer no-undo .
define input parameter p-path as character no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-md5-signature as character no-undo .
define parameter buffer buf_ext-file for ub.ext-file.
DEFINE TEMP-TABLE tt-ext-file-par NO-UNDO LIKE ub.ext-file-par.
define input parameter table for tt-ext-file-par.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bin-e.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/bin-e.p $":U .
define variable vss-description as character no-undo init "Передача бинарного файла по СПН".
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
define variable v-cmd-proc-handle as handle no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-md5-signature as character no-undo .
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-rec-ord                 as integer                  no-undo .
define buffer buf_temp-ext-file-line for temp-ext-file-line .
define buffer buf_tt-ext-file-par for tt-ext-file-par.
define buffer buf_ext-file-par for ub.ext-file-par.
define buffer buf_ext-file-line for ub.ext-file-line.
main-block:
do
on error undo, return error return-value
:
  run gbl/filename.p (
                  input p-full-path-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    undo main-block, return error substitute("&1 &2 &3&4Ошибка при определении имени файла &5&4" +
                                        "&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,p-full-path-name
                                        ,error-status:get-message(1)
                                        ,return-value ).
  end.
  if p-mode = 'save-this-db':U then do:
    run binfile_read-to-db in this-procedure (
      input  p-db-num
      ,input p-from-db-num
      ,input  p-file-num
      ,input  p-full-path-name
      ) .
    if buf_ext-file.file-type begins ('cash-desk':U + chr(3))
    then do:
      for each buf_tt-ext-file-par no-lock:
          find first buf_ext-file-par where
                    buf_ext-file-par.db-num = 0
                and buf_ext-file-par.from-db-num = 0
                and buf_ext-file-par.file-num = 0
                and buf_ext-file-par.param-num = buf_tt-ext-file-par.param-num  no-error.
          if not available buf_ext-file-par then do:
            create buf_ext-file-par.
          end.
          buffer-copy buf_tt-ext-file-par except db-num from-db-num file-num
          to buf_ext-file-par
          assign
          buf_ext-file-par.from-db-num = p-from-db-num
          buf_ext-file-par.db-num = p-db-num
          buf_ext-file-par.file-num = buf_Ext-file.file-num
          buf_ext-file-par.user-db-num = p-from-db-num
          .
      end.
    end.
    return.
  end.
  else do:
    if p-md5-signature = '':U then do:
      run gbl/md5.p (
        input  p-full-path-name
        ,output p-md5-signature
        ) .
    end.
    run binfile_read in this-procedure (
       input  p-db-num
      ,input  p-from-db-num
      ,input  p-file-num
      ,input  p-full-path-name
      ) .
  end.
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
                                                input  ('cmd-send-binary':U + chr(6)
                                                      + p-mode  + chr(6)
                                                      + string(p-file-num) + chr(6)
                                                      + v-file-name + chr(6)
                                                      + string(p-path-type) + chr(6)
                                                      + p-path + chr(6)
                                                      + p-md5-signature  )
                                                ,INPUT  string(if p-db-num > 0 then p-db-num else 0)
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
  run add-dump in v-cmd-proc-handle
    (input v-cmd-code
    ,input 'ext-file':U
    ,input '+update'
    ,input (buffer buf_ext-file:handle)
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
                                        ,'ext-file':U
                                        ,v-cmd-code
                                        ,error-status:get-message(1)
                                        ,return-value
                                        ).                                                       ~
  end.
  for each buf_temp-ext-file-line no-lock:
      find first buf_ext-file-line where
                buf_ext-file-line.db-num = p-db-num
            and buf_ext-file-line.from-db-num = p-from-db-num
            and buf_ext-file-line.file-num = p-file-num
            and buf_ext-file-line.line-num = buf_temp-ext-file-line.line-num
            and buf_ext-file-line.sub-line-num = buf_temp-ext-file-line.sub-line-num
            no-error.
      if not available buf_ext-file-line then do:
        create buf_ext-file-line.
      end.
      buffer-copy buf_temp-ext-file-line except db-num from-db-num file-num
      to buf_ext-file-line
      assign
      buf_ext-file-line.from-db-num = p-from-db-num
      buf_ext-file-line.db-num = p-db-num
      buf_ext-file-line.file-num = p-file-num
      .
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
                                          ,'ext-file-line':U
                                          ,v-cmd-code
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ).                                                       ~
    end.
  end.
  if p-mode = 'save-disk-and-run':U
  or p-mode = 'save-db-and-run':U
  or buf_ext-file.file-type begins ('cash-desk':U + chr(3))
  then do:
  for each buf_tt-ext-file-par no-lock:
      find first buf_ext-file-par where
                buf_ext-file-par.db-num = 0
            and buf_ext-file-par.from-db-num = 0
            and buf_ext-file-par.file-num = 0
            and buf_ext-file-par.param-num = buf_tt-ext-file-par.param-num  no-error.
      if not available buf_ext-file-par then do:
        create buf_ext-file-par.
      end.
      buffer-copy buf_tt-ext-file-par except db-num from-db-num file-num
      to buf_ext-file-par
      assign
      buf_ext-file-par.from-db-num = p-from-db-num
      buf_ext-file-par.db-num = p-db-num
      buf_ext-file-par.file-num = buf_Ext-file.file-num
      buf_ext-file-par.user-db-num = p-from-db-num
      .
      run add-dump in v-cmd-proc-handle
        (input v-cmd-code
        ,input 'ext-file-par':U
        ,input '+update'
        ,input (buffer buf_ext-file-par:handle)
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
                                            ,'ext-file-par':U
                                            ,v-cmd-code
                                            ,error-status:get-message(1)
                                            ,return-value
                                            ).                                                       ~
      end.
    end.
  end.
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code
      ,input string(if p-db-num > 0 then p-db-num else 0)
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
                                        ,p-db-num
                                        ).
  end.
  delete procedure v-cmd-proc-handle .
end.
