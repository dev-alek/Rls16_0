block-level on error undo, throw.
define input  parameter p-search-file-name as character no-undo .
define output parameter p-full-path        as character no-undo .
define output parameter p-path             as character no-undo .
define output parameter p-file-name        as character no-undo .
define output parameter p-file-name-no-ext as character no-undo .
define output parameter p-file-name-ext    as character no-undo .
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: filename.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/filename.p $":U .
def var vss-description as character no-undo init "Возвращает компоненты имени файла".
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
      p-vss-parameters = substitute('&1',p-search-file-name)
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
do
on error undo, return error return-value
:
  def var v-full-pathname as character no-undo .
  define variable v-path-split as integer   no-undo .
  assign
    v-full-pathname = search(p-search-file-name)
  .
  if v-full-pathname = ""
  or v-full-pathname = ?
  then do:
    return error substitute("Файл &1 не найден", p-search-file-name) .
  end.
  assign
    file-info :file-name = v-full-pathname
  .
  assign
    v-full-pathname = file-info :full-pathname
  .
  assign
    p-full-path = v-full-pathname
  .
  if index(file-info :file-type, 'F':U) = 0
  then do:
    undo, return error "В качестве параметра указан не файл" + chr(32) + v-full-pathname .
  end.
  assign
    v-path-split = r-index(p-full-path, '\':u)
  .
  if v-path-split = 0 then do:
    undo, return error "Невозможно определить имя файла" + chr(32) + v-full-pathname .
  end.
  assign
    p-path      = substring(p-full-path, 1, v-path-split - 1)
    p-file-name = substring(p-full-path, v-path-split + 1)
  .
  define variable v-ext-split as integer   no-undo .
  assign
    v-ext-split = r-index(p-file-name, '.':u)
  .
  if v-ext-split > 0 then do:
    assign
      p-file-name-no-ext = substring(p-file-name, 1, v-ext-split - 1)
      p-file-name-ext    = substring(p-file-name, v-ext-split + 1)
    .
  end.
  else do:
    assign
      p-file-name-no-ext = p-file-name
      p-file-name-ext    = ""
    .
  end.
  if p-file-name-ext = "" then do:
    assign
      p-file-name = p-file-name-no-ext
    .
  end.
  assign
    p-full-path = p-path + '\':u + p-file-name
  .
end.
