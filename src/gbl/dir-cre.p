block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dir-cre.p $
$Archive: gbl/dir-cre.p $

Создание заданного каталога

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/
define input parameter p-dir-name as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: dir-cre.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/dir-cre.p $":U .
def var vss-description as character no-undo init "Создание заданного каталога".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  define variable v-ind         as integer   no-undo .
  define variable v-ind1        as integer   no-undo .
  define variable v-dir-name    as character no-undo .
  define variable v-dir-name1   as character no-undo .
  define variable v-char        as character no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-first-num   as integer   no-undo .
  define variable v-err-mess    as character no-undo .

  assign
    file-info:file-name = p-dir-name
  .
  if file-info:file-type <> ?
    and index( file-info:file-type, "D":U ) <> 0
  then do:
    return string( "каталог" + {&space-char} + p-dir-name + {&space-char} + "уже существует." ) .
  end.

  assign
    v-dir-name = replace( p-dir-name, {&slash-char}, {&back-slash-char} )
  .

  if substring( v-dir-name, 1, 1 ) = {&back-slash-char}
     and substring( v-dir-name, 2, 1 ) = {&back-slash-char}
  then do:
    assign
      v-first-num = 5
    .
  end.
  else do:
    if substring( v-dir-name, 2, 1 ) = ":":U
       and substring( v-dir-name, 3, 1 ) = {&back-slash-char}
    then do:
      assign
        v-first-num = 2
      .
    end.
    else do:
      return error string( "путь к каталогу должен иметь формат" + {&new-line}
                            + {&back-slash-char} + {&back-slash-char} + " ...":U + {&back-slash-char} + " ...":U + {&new-line}
                            + "или" + {&space-char} + "... :\...":U
                          ).
    end.
  end.

  assign
    v-num-entries = num-entries( v-dir-name, {&back-slash-char} )
    v-dir-name1 = "":U
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error
  :
    if v-ind < v-first-num then do:
      assign
        v-dir-name1 = v-dir-name1 + entry(v-ind, v-dir-name, {&back-slash-char} ) + {&back-slash-char}
      .
    end.
    else do:
      assign
        file-info:file-name = v-dir-name1
      .
      if file-info:file-type <> ?
        and index( file-info:file-type, "D":U ) <> 0
      then do:
        assign
            v-dir-name1 = v-dir-name1 + entry(v-ind, v-dir-name, {&back-slash-char} ) + {&back-slash-char}
        .
        os-create-dir value( v-dir-name1 ) .
        if os-error <> 0 then do:
          run adm/os-err.p ( output v-err-mess ).
          return error string( "Не могу создать каталог" + {&space-char} + v-dir-name1 + {&new-line}
                              + v-err-mess + {&space-char} + "(":U + string( os-error ) + ")":U
                            ).
        end.
      end.
      else do:
        return error string( "Не могу создать каталог в ресурсе" + {&space-char} + v-dir-name1 ).
      end.
    end.
  end.

end.

return .

/* $Workfile: dir-cre.p $ end */