block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lock-nws.p $
$Archive: nws/lock-nws.p $

Блокировка базы данных для работы новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input parameter  p-db-num     as integer no-undo .
define parameter buffer pbuf_db for ub.db .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: lock-nws.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/lock-nws.p $":U .
def var vss-description as character no-undo init "Блокировка базы данных для работы новостей".
{ cmp/vssrevis.i "substitute('&1':u,p-db-num )" }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  find first pbuf_db exclusive-lock
    where pbuf_db.db-num = p-db-num
    no-wait no-error
  .
  if not available pbuf_db then do:
    if locked pbuf_db then do:
      return error string( vss-workfile + {&space-char}
                           + "Другой пользователь работает с базой данных" + {&space-char} + string( p-db-num )
                         ) .
    end.
    else do:
      return error string( vss-workfile + {&space-char}
                           + "БД с номером" + {&space-char} + string( p-db-num ) + {&space-char} + "не найдена"
                         ).
    end.
  end.

  find current pbuf_db share-lock .

  return.

end.