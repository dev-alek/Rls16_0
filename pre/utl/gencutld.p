block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gencutld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gencutld.p $":U .
define variable vss-description as character no-undo init "Генерация include-файлов по пирогу обрезания".
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
define stream upgstream.
define stream genstream.
define temp-table list-action no-undo
  field action         as character format "x(15)" label "Процедура"
  field file-name      as character
  index pi is unique primary
    file-name ascending
  .
define variable v-gen-dir       as character no-undo .
define variable v-dir-name      as character no-undo .
define variable v-gen-file      as character no-undo .
define variable v-type          as character no-undo .
define variable v-filename     as character no-undo.
define variable v-fullfilename as character no-undo.
define variable v-can-write     as logical   no-undo .
define variable v-gen-file-list as character no-undo .
run gbl/d-prompt.w (
    'title=':u + "Введите имя директории" + '\':u
  + 'text1=':u + "Введите имя директории" + '\':u
  + 'text2=':u + "где будут созданы файлы по структуре 'пирога' обрезания" + '\':u
  + 'format=x(256)\':u
  + 'type=char\':u
  ,input-output v-gen-dir
  ).
if return-value = 'false':u then do:
  return .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if trim( v-gen-dir ) = "":U then do:
  assign
    v-gen-dir = ".":U
  .
end.
assign
  file-info:file-name = v-gen-dir
.
if file-info :full-pathname = ""
or file-info :full-pathname = ?  then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Уазанный каталог (&1) не найден!", v-gen-dir ) skip
    view-as alert-box error .
  undo, return error .
end.
assign
  v-gen-dir = file-info:full-pathname + "/":U
.
  run gbl/dir-cre.p ( input v-gen-dir + "utl":U ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании каталога &1", v-gen-dir + "utl":U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error.
  end.
run gbl/d-prompt.w (
    'title=':u + "Введите имя каталога" + '\':u
  + 'text1=':u + "Введите имя каталога 'пирога' обрезания" + '\':u
  + 'format=x(256)\':u
  + 'type=char\':u
  ,input-output v-dir-name
  ).
if return-value = 'false':u then do:
  return .
end.
assign
  file-info :file-name = v-dir-name
.
if file-info :full-pathname = ""
or file-info :full-pathname = ?  then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Каталог: &1 ('пирог') не найден !!!", v-dir-name ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
  undo, return error .
end.
assign
  v-dir-name = file-info :full-pathname
.
input stream upgstream from os-dir ( v-dir-name ) .
repeat:
  import stream upgstream v-filename v-fullfilename v-type.
  if v-type = "f" then do:
    if num-entries( v-filename, "." ) > 1
      and lookup(entry( num-entries( v-filename, "." ), v-filename, "." ), "p,w") > 0
    then do:
      create list-action .
      assign
        list-action.action    = entry( num-entries( v-filename, "." ), v-filename, "." )
        list-action.file-name = (if entry(num-entries(v-dir-name,"\"),v-dir-name,"\") = "cut" then "cut":U else "cleandb")
                              + "/" + v-filename
      .
    end.
    else do:
      message
        substitute( 'В каталоге пирога есть недопустимый файл &1', v-filename ) skip
        "Файл будет проигнорирован!!!"
        view-as alert-box information
        .
    end.
  end.
end.
input stream upgstream close.
assign
  v-gen-file = if entry(num-entries(v-dir-name,"\"),v-dir-name,"\") = "cut" then "utl/cutld.i":U else "utl/clean_db.i":U.
  v-gen-file-list = v-gen-file-list + "," + v-gen-file
.
output stream genstream to value( v-gen-dir + v-gen-file ) .
put stream genstream unformatted
  chr(47) + chr(42) + chr(10) + chr(10) + chr(36) + 'Revision: ':U + chr(36) + chr(10) + chr(36) + 'Author: ':U + chr(36) + chr(10) + chr(36) + 'Date: ':U + chr(36) + chr(10) + chr(36) + 'Workfile: ':U + chr(36) + chr(10) + chr(36) + 'Archive: ':U + chr(36) + chr(10) + chr(10) + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) + chr(10) + chr(10) + chr(10) + "Автор: Уханов Дмитрий Юрьевич":U + chr(10) + "Дата создания: 11/29/01":U + chr(10) + "Author: Dmitry Ukhanov":U + chr(10) + "Creation date: 11/29/01":U + chr(10) + chr(10) + chr(42) + chr(47) + chr(10) skip
  chr(47) + chr(42) + ' Список утилит пирога обрезания ' + chr(42) + chr(47) skip(2)
.
for each list-action
  by file-name
on error undo, return error
:
  put stream genstream unformatted
    "create list-action .                                  " skip
    "assign                                                " skip
    "  list-action.action    = '" list-action.action    "' " skip
    "  list-action.file-name = '" list-action.file-name "' " skip
    "  .                                                   " skip
    .
end.
output stream genstream close .
message
  "В каталоге" v-gen-dir "сгенерированы файлы:" skip
  v-gen-file-list skip
  view-as alert-box information .
