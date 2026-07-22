block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: nws-stop.p $
$Archive: nws/nws-stop.p $

Отключение СПН для БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/03
Author: Dmitry Ukhanov
Creation date: 03/23/03

*/
define input parameter  p-action as   character    no-undo . /* "stop"  - блокировка СПН для БД, "check" - проверка заблокирована ли СПН для БД*/
define input parameter  p-db-num like ub.db.db-num no-undo .
define output parameter p-answer as   logical      no-undo . /* true если СПН для БД заблокирована */

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: nws-stop.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/nws-stop.p $":U .
def var vss-description as character no-undo init "Отключение СПН для БД".
{ cmp/vssrevis.i }

do
on error undo, return error
:
  define buffer buf_db for ub.db .

  if lookup( p-action, "stop,check":U ) = 0 then do:
     message
       substitute( "Не предусмотрена обработка операции &1", p-action )
       view-as alert-box.
  end.

  find first buf_db exclusive-lock
    where buf_db.db-num = p-db-num
    no-error
  .
  if not available buf_db then do:
    return error substitute( "БД с номером &1 не найдена", p-db-num ) .
  end.

  assign
    p-answer = false
  .

  case p-action :
    when "stop":U then do:
      assign
        buf_db.db-key     = "":U
        buf_db.db-key-enc = "":U
        p-answer          = true
      .
      release buf_db .
    end.
    when "check":U then do:
      if buf_db.db-key = "":U
          or buf_db.db-key = ?
      then do:
        assign
          p-answer = true
        .
      end.
    end.
  end case.

end.

return.

/* $Workfile: nws-stop.p $ end */