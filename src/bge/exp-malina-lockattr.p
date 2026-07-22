block-level on error undo, throw.
/*

$Revision: 794b9cc81728, 98, rls $
$Author: EShklyar $
$Date: Fri Nov 07 16:47:37 2014 +0300 $
$Workfile: exp-malina-lockattr.p $
$Archive: bge/exp-malina-lockattr.p $

Блокировка атрибута БД

Автор: Кривошеин Александр Николаевич
Дата создания: 02/09/14
Author: Krivoshein Alexander
Creation date: 02/09/14

*/

def var vss-revision    as character no-undo init "$Revision: 794b9cc81728, 98, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Fri Nov 07 16:47:37 2014 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: exp-malina-lockattr.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/exp-malina-lockattr.p $":U .
def var vss-description as character no-undo init "Блокировка атрибута БД".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/db-key.i   }
{ gbl/db-attr.i  }
{ nws/lib-nws.i  }

define input parameter p-db-num like ub.db-attr.db-num no-undo .
define input parameter p-db-attr-code like ub.db-attr.attr-code no-undo .
define parameter buffer buf_db-attr for ub.db-attr .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-last-key  like ub.db.db-key no-undo .
  define variable v-attr-type as   character    no-undo .
  define variable v-lock      as   logical      no-undo .
  define variable v-msg       as   character    no-undo .
  define variable v-ok        as   logical      no-undo .

  FIND FIRST buf_db-attr EXCLUSIVE-LOCK
    WHERE buf_db-attr.db-num = p-db-num AND buf_db-attr.attr-code = p-db-attr-code
    NO-WAIT NO-ERROR
  .

  if not available buf_db-attr then do:
    if locked buf_db-attr then do:
      return error substitute( "&1. Другой пользователь работает с атрибутом &2!", vss-workfile, p-db-attr-code ) .
    end.
    else do:
      return error substitute( "&1. Атрибут &2 не найден!!!", vss-workfile, p-db-attr-code ) .
    end.
  end.
end.
