block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gencutld.p $
$Archive: utl/gencutld.p $

Генерация include-файлов по пирогу обрезани

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gencutld.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/gencutld.p $":U .
define variable vss-description as character no-undo init "Генерация include-файлов по пирогу обрезания".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

&glob std-vss-header-ukh {&start-comment} + {&new-line} + {&new-line} + {&dollar} + 'Revision: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Author: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Date: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Workfile: ':U + {&dollar} ~
+ {&new-line} + {&dollar} + 'Archive: ':U + {&dollar} ~
+ {&new-line} + {&new-line} + 'ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ ' + program-name(1) ~
+ {&new-line} + {&new-line} ~
+ {&new-line} + "Автор: Уханов Дмитрий Юрьевич":U ~
+ {&new-line} + "Дата создания: 11/29/01":U ~
+ {&new-line} + "Author: Dmitry Ukhanov":U ~
+ {&new-line} + "Creation date: 11/29/01":U ~
+ {&new-line} + {&new-line} ~
+ {&end-comment} + {&new-line}

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

{ utl/gencredr.i v-gen-dir utl }

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
  {&std-vss-header-ukh} skip
  {&start-comment} + ' Список утилит пирога обрезания ' + {&end-comment} skip(2)
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