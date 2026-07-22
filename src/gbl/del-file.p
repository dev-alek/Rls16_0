block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: del-file.p $
$Archive: gbl/del-file.p $

Удаление каталога или файла

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/
define input parameter p-del-file-name as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: del-file.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/del-file.p $":U .
def var vss-description as character no-undo init "Удаление каталога или файла".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-err-mess as character no-undo .
  define variable v-str      as character no-undo .

  assign
    file-info:file-name = p-del-file-name
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

    os-delete value( p-del-file-name ).
    if os-error <> 0 then do:
      run adm/os-err.p ( output v-err-mess ).
      return error string( vss-workfile + {&space-char}
                          + substitute( "Невозможно удалить &1 &2", v-str, p-del-file-name )
                          + {&new-line} + v-err-mess
                        ).
    end.
  end.
end.

return.


/* $Workfile: del-file.p $ end */