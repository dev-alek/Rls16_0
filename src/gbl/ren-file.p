block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ren-file.p $
$Archive: gbl/ren-file.p $

Переименование файла или каталога

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/19/08
Author: Dmitry Ukhanov
Creation date: 06/19/08

*/

define input parameter p-file-source as character no-undo .
define input parameter p-file-target as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ren-file.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/ren-file.p $":U .
define variable vss-description as character no-undo init "Переименование файла или каталога".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
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
    return error substitute( "&1. Невозможно переименовать &2 &3 в &4&5&6", vss-workfile, v-str, p-file-source, p-file-target, {&new-line}, v-err-mess ).
  end.

end.

return .