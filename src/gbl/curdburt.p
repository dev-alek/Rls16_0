
/*------------------------------------------------------------------------


$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает текущий номер базы данных, пользователя, дату, время и количество секунд

Автор: Шкляр Елена
Дата создания: 04/10/06
Author: Shklyar Elena
Creation date: 04/10/06


  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
{ cmp/library.i  }

define output parameter this-proc-hndl as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Возвращает текущий номер базы данных, пользователя, дату, время и количество секунд".


do:
  
  this-proc-hndl = this-procedure.
  
end.
procedure curd_burt:
define output parameter p-user-db-num   like ub.contract.user-db-num   no-undo .
define output parameter p-user-name     like ub.contract.user-name     no-undo .
define output parameter p-sys-date      as  date      no-undo .
define output parameter p-sys-time      as  character no-undo .
define output parameter p-sys-time-int  as  integer   no-undo .
  
{ gbl/curdburt.i  p-user-db-num   p-user-name   p-sys-date   p-sys-time   p-sys-time-int  }

end procedure .