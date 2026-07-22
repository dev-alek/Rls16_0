block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkfrmdb.p $
$Archive: utl/chkfrmdb.p $

Проверка соответствия БД оъекта главной БД фирмы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/16/03
Author: Bakhtadze Natalya
Creation date: 12/16/03

*/

define input parameter p-call-handle as handle no-undo .
define output parameter p-count as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkfrmdb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chkfrmdb.p $":U .
define variable vss-description as character no-undo init "Проверка соответствия БД оъекта главной БД фирмы".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }

define variable ind as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_clients for ub.clients .
define buffer buf_db for ub.db .
define buffer buf_sysconf for ub.sysconf.

run waitfram-show in this-procedure ("Ждите..." ).


  _cli:
  for each buf_db no-lock,
      each buf_clients no-lock where
           buf_clients.db-num = buf_db.db-num
  :
    assign
      ind = ind + 1
    .
    if ind mod 10 = 0 then do:
      run waitfram-show in this-procedure (input "Соответствие БД объекта главной БД фирмы " + buf_clients.obj-type + string(buf_clients.obj-code)
          + " Найдено ошибок " + STRING(p-count)
        ).
      process events .
    end.
    { gbl/hostcode.i buf_clients.obj-type buf_clients.obj-code v-host-code no-error }
    if error-status:error then do:
      run log-error in p-call-handle
        (input {&table_clients}
        ,input buf_clients.obj-type
        ,input buf_clients.obj-code
        ,input ""
        ,input ""
        ,input 0
        ,input 'host-num-error '
        ).
      next _cli.
    end.


    find first buf_sysconf no-lock where
               buf_sysconf.host-code = v-host-code no-error .
    if not available buf_sysconf then do:
      run log-error in p-call-handle
        (input {&table_clients}
        ,input buf_clients.obj-type
        ,input buf_clients.obj-code
        ,input ""
        ,input ""
        ,input 0
        ,input 'host-not-found '
        + ' host-code = ' + string(v-host-code)
        ).
      next _cli.
    end.

    if buf_sysconf.firm-db-num <> buf_clients.db-num
    AND buf_sysconf.firm-db-num <> 0
    then do:
      assign
        p-count = p-count + 1
      .
      run log-error in p-call-handle
        (input {&table_clients}
        ,input buf_clients.obj-type
        ,input buf_clients.obj-code
        ,input ""
        ,input ""
        ,input 0
        ,input 'clients-db-firm-db-num '
          + ' db-num = ' + string(buf_clients.db-num)
          + ' firm-db-num = ' + string(buf_sysconf.firm-db-num)
        ).
    end.

  end.
  run waitfram-hide in this-procedure .
