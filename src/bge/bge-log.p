block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-log.p $
$Archive: bge/bge-log.p $

Запись лога выгрузки для автопроцесса

Автор: Хныкин Павел Андреевич
Дата создания: 06/19/09
Author: Pavel Khnykin
Creation date: 06/19/09

*/
define input  parameter p-message as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-log.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-log.p $":U .
define variable vss-description as character no-undo init "Запись лога выгрузки для автопроцесса".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define variable v-str           as character no-undo .
define variable v-home-dir      as character no-undo .
define variable v-log-file      as character no-undo .
define variable v-pid           as integer   no-undo .

do
on error undo, return error return-value
:
  if g#auto = yes
  then do:
    run GetCurrentProcessId( output v-pid ) .
    assign
      v-str = replace(p-message, ({&new-line} + {&carriage-return}), {&new-line} )
      v-str = replace(v-str, ({&carriage-return} + {&new-line}), {&new-line} )
      v-str = replace(v-str, {&new-line}, ({&carriage-return} + {&new-line}) )
      v-log-file = substitute( "export-xml&1.log"
                             , v-pid
                             )
    .
    run gbl/fileapnd.p ( input v-log-file
                   , input v-str
                   , input 10 /* время ожинания освобождения файла */
                   ) no-error .
    if error-status :error = yes
    then do:
      return error return-value .
    end.
  end.
  else do:
    return . /* --->>>--- */
  end.
end.

PROCEDURE GetCurrentProcessId EXTERNAL "kernel32.dll" :
  DEFINE RETURN PARAMETER RetVal          AS LONG.
END PROCEDURE.