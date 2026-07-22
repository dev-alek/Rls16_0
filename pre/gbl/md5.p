block-level on error undo, throw.
define input  parameter p-file-name     as character no-undo .
define output parameter p-md5-signature as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: md5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/md5.p $":U .
define variable vss-description as character no-undo initial "".
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
define stream slog .
do
on error undo, return error return-value
:
  define variable v-exe-file-name        as character no-undo .
  define variable v-md5-checksum         as character no-undo .
  define variable v-command-gen-checksum as character no-undo .
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
  run gbl/filename.p
    (input  p-file-name
    ,output v-full-path
    ,output v-path
    ,output v-file-name
    ,output v-file-name-no-ext
    ,output v-file-name-ext
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute('&1':u, vss-workfile) + chr(10)
      + "Ошибка задания входных параметров" + chr(10)
      + substitute("Не найден файл &1", p-file-name)
      .
  end.
  assign
    v-exe-file-name = search('exe/md5.exe':u)
  .
  if v-exe-file-name = ?
  or v-exe-file-name = ""
  then do:
    undo, return error substitute('&1':u, vss-workfile) + chr(10)
      + "Ошибка задания входных параметров" + chr(10)
      + substitute("Не найден файл &1", 'exe/md5.exe':u)
      .
  end.
  define variable v-md5-error as character no-undo .
  assign
    v-md5-error = 'MD5ERROR':u
  .
  run gbl/_tmpfile.p
    (input  'md5':u
    ,input  '.md5':u
    ,output v-md5-checksum
    ).
  output stream slog to value(v-md5-checksum) .
  put stream slog unformatted v-md5-error + chr(10) .
  output stream slog close .
  assign
    v-command-gen-checksum = v-exe-file-name
      + ' ':u + '-n':u
      + ' "':u + '-o':u + v-md5-checksum + '"':u
      + ' "':u + v-full-path + '"':u
  .
  os-command silent value(v-command-gen-checksum) .
  input stream slog from value(v-md5-checksum) .
  do
  on error undo, leave
  on end-key undo, leave
  :
    import stream slog p-md5-signature .
  end.
  input stream slog close .
  os-delete value(v-md5-checksum) .
  if p-md5-signature = v-md5-error
  or p-md5-signature = ""
  then do:
    undo, return error substitute('&1':u, vss-workfile) + chr(10)
      + "Ошибка при вызове программы exe/md5.exe" + chr(10)
      .
  end.
end.
