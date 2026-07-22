block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: unloaddc.p $
$Archive: adm/unloaddc.p $

Отключение БД участвующих в выгрузке УБД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: unloaddc.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/unloaddc.p $":U .
def var vss-description as character no-undo init "Отключение БД участвующих в выгрузке УБД".
{ cmp/vssrevis.i }

do
on error  undo, return error error-status :get-message ( error-status :num-messages )
on stop   undo, return error "stop":U
on endkey undo, return error "endkey":U
:

  define variable v-ind as integer no-undo .

  repeat v-ind = 1 to num-dbs:
    if ldbname( v-ind ) <> "ub":U then do:
      disconnect value( ldbname( v-ind ) ) .
    end.
  end.

  repeat v-ind = 1 to num-aliases:
    if alias( v-ind ) = "dst":U
      or alias( v-ind ) = "src":U
      or alias( v-ind ) = "db-orig":U
      or alias( v-ind ) = "db-copy":U
    then do:
      if ldbname( alias( v-ind ) ) = "ub":U then do:
        delete alias value( alias( v-ind ) ) .
      end.
      else do:
        if connected( alias( v-ind ) ) then do:
          disconnect value( alias( v-ind ) ) .
        end.
      end.
    end.
  end.

end.
return.

/* $Workfile: unloaddc.p $ end */