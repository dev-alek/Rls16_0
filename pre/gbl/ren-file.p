block-level on error undo, throw.
define input parameter p-file-source as character no-undo .
define input parameter p-file-target as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ren-file.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/ren-file.p $":U .
define variable vss-description as character no-undo init "Переименование файла или каталога".
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
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-err-mess as character no-undo .
  define variable v-str      as character no-undo .
  assign
    file-info:file-name = p-file-source
  .
  if file-info:file-type <> ? then do:
    if file-info:file-type begins "F":U then do:
      assign
        v-str = "файл"
      .
    end.
    else do:
      if file-info:file-type begins "D":U then do:
        assign
          v-str = "каталог"
        .
      end.
      else do:
        assign
          v-str = "незнаю что"
        .
      end.
    end.
  end.
  run gbl/del-file.p ( input p-file-target ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
  os-rename value( p-file-source ) value( p-file-target ).
  if os-error <> 0 then do:
    run adm/os-err.p ( output v-err-mess ).
    return error substitute( "&1. Невозможно переименовать &2 &3 в &4&5&6", vss-workfile, v-str, p-file-source, p-file-target, chr(10), v-err-mess ).
  end.
end.
return .
