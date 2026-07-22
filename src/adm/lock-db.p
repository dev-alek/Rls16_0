block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lock-db.p $
$Archive: adm/lock-db.p $

Блокировка БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: lock-db.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/lock-db.p $":U .
def var vss-description as character no-undo init "Блокировка БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/db-key.i   }
{ gbl/db-attr.i  }
{ nws/lib-nws.i  }

define input parameter p-db-num like ub.db.db-num no-undo .
define input parameter p-action as   character    no-undo .
define parameter buffer buf_db for ub.db .

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

  find first buf_db exclusive-lock
    where buf_db.db-num = p-db-num
    no-wait no-error
  .
  if not available buf_db then do:
    if locked buf_db then do:
      return error substitute( "&1. Другой пользователь работает с базой данных &2!", vss-workfile, p-db-num ) .
    end.
    else do:
      return error substitute( "&1. База данных &2 не найдена!!!", vss-workfile, p-db-num ) .
    end.
  end.
  else do:
    case p-action :
      when "unload_db":U then do:
        case buf_db.stts :
          when 0 then do:
            assign
              buf_db.stts = 2
            .
          end.
          when 2 then do:
            run db-attr-value ( input p-db-num
                               ,input {&attr-last-unload-db-key}
                               ,output v-last-key
                               ,output v-attr-type
                              ) no-error.
            if error-status :error then do:
              return error substitute( "&1. Ошибка при чтении ключа для БД &2, с которым происходила последняя выгрузка!", vss-workfile, p-db-num ) .
            end.
            run del-db-key ( input v-last-key ).
            assign
              v-lock = true
            .

            { nws/lock-rt.i
              "'unlock'"
              p-db-num
              0
              "''"
              v-msg
              v-lock
              v-ok
              no-error
            }
            if error-status :error
              or v-lock = true
              or v-ok   = false
            then do:
              return error substitute( "&1. &2&3&4", vss-workfile, v-msg, {&new-line}, return-value ) .
            end.
          end.
        end case.
      end.
    end case.
  end.

end.

/* $Workfile: lock-db.p $ end */