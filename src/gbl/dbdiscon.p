block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dbdiscon.p $
$Archive: gbl/dbdiscon.p $

Разрыв соединений со всеми базами данных

Автор: Перваков Михаил Сергеевич
Дата создания: 06/21/00
Author: Mikhail Pervakov
Creation date: 06/21/00

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: dbdiscon.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/dbdiscon.p $":U .
def var vss-description as character no-undo init "Разрыв соединений со всеми базами данных".
{ cmp/vssrevis.i }

do
on error  undo, return error substitute( "&1. ERROR &2", vss-workfile, error-status:get-message( error-status:num-messages ) )
on stop   undo, return error substitute( "&1. STOP", vss-workfile )
on endkey undo, return error substitute( "&1. ENDKEY", vss-workfile )
on quit   undo, return error substitute( "&1. QUIT", vss-workfile )
:
  define variable ind           as integer   no-undo .
  define variable database-list as character no-undo .
  define variable alias-list    as character no-undo .

  /* удаляем все persistent-procedure, иначе не произойдет disconnect */
  run gbl/del-pers.p no-error .
  if error-status :error then do:
    return error vss-workfile + "Ошибка при удалении persistent-procedures" .
  end.

  /* получаем список подключенных баз данных */
  assign
    database-list = ""
  .
  do ind = 1 to num-dbs
  :
    assign
      database-list = database-list
                    + ( if database-list > "" then "," else "" ) + ldbname(ind)
    .
  end.

  do ind = 1 to num-entries(database-list)
  on error undo, return error
  :
    disconnect value(entry(ind,database-list)) .
  end.

  assign
    alias-list = ""
  .
  do ind = 1 to num-aliases
  :
    assign
      alias-list = alias-list
                    + ( if alias-list > "" then "," else "" ) + alias(ind)
    .
  end.

  do ind = 1 to num-entries(alias-list)
  on error undo, return error
  :
    delete alias value(entry(ind,alias-list)) .
  end.

end.

/* $Workfile: dbdiscon.p $ end */