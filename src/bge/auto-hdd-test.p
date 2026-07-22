block-level on error undo, throw.
/*

$Revision: 6106fe039332, 2330, rls $
$Author: SSlivenko $
$Date: Ср июн 10 21:13:32 2020 +0300 $
$Workfile: auto-hdd-test.p $
$Archive: bge/auto-hdd-test.p $

Работа с ФГИС меркурий

Автор: Сливенко Сергей
Дата создания: 05/28/18
Author: Slivenko Sergey
Creation date: 05/28/18

*/

using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.gbl.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.


define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-list-db       as character no-undo .

def var vss-revision    as character no-undo init "$Revision: 6106fe039332, 2330, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Ср июн 10 21:13:32 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-hdd-test.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-hdd-test.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС меркурий".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ adm/auto-def.i }
{ gbl/getsect.i def }
{ ref/extclass.i }

do
on error undo, return error
:
  define variable v-ind                    as integer   no-undo .
  define variable v-num-entries-db-list    as integer   no-undo .
  define variable v-db-num                 as integer   no-undo .
  define variable v-err-gen-pack           as integer   no-undo .
  define variable v-err-code               as integer   no-undo .
  define variable v-step-num               as integer   no-undo .
  define variable v-action                 as character no-undo .
  define variable v-message                as character no-undo .
  define variable v-proc-handle            as handle    no-undo .
  define variable v-main-proc-name         as character no-undo .

  define variable v-count-main-prc         as integer   no-undo .
  define variable v-pers-proc-name         as character no-undo .
  
  define variable v-apiKey              as character no-undo .
  define variable v-issuerId            as character no-undo .
  define variable v-login               as character no-undo .
  define variable v-login_is            as character no-undo .
  define variable v-password            as character no-undo .
  define variable v-initiator           as character no-undo .
  define variable v-type-connect        as integer   no-undo .
  define variable v-server              as integer   no-undo .
  define variable v-proxy-login         as character no-undo .
  define variable v-proxy-pswd          as character no-undo .
  define variable v-proxy-addres        as character no-undo .
  
  define variable v-appId           as character no-undo .
  define variable v-status_         as character no-undo .
  define variable v-Msg             as character no-undo .
  
  define buffer buf_devisPC           for ub.devisPC .
  define buffer buf_devisPC-attr      for ub.devisPC-attr .
  
  define variable objThObj      as clisub.
  define variable objKeyRec     as keyrec.
  
  define variable v-part-rowid as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  
  define variable ii as integer no-undo.

  if transaction then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile )
      view-as alert-box error .
    return error .
  end.
  if valid-handle( session :first-procedure ) then do:
    assign
      v-main-proc-name = "gbl/mainproc.p":U
      v-proc-handle    = session :first-procedure
      v-count-main-prc = 0
      v-pers-proc-name = "":U
    .
    do while valid-handle( v-proc-handle )
    :
      if v-proc-handle :file-name = v-main-proc-name then do:
        assign
          v-count-main-prc = v-count-main-prc + 1
        .
      end.
      else do:
        assign
          v-pers-proc-name = v-pers-proc-name + {&comma-char} + v-proc-handle :file-name
        .
      end.
      assign
        v-proc-handle = v-proc-handle:next-sibling no-error
      .
    end.
    if v-count-main-prc > 1
      or v-pers-proc-name <> "":U
    then do:
      message
        substitute( "&1. Вызов данной процедуры невозможен при наличии определений persistent prosedures &2"
                    + "Список недопустимых процедур: &3&2"
                    + "Исключение - единственная процедура &4&2"
                    + "Определений данной процедуры &5&2"
                    , vss-workfile
                    , {&new-line}
                    , v-pers-proc-name
                    , v-main-proc-name
                    , v-count-main-prc
                   )
        view-as alert-box error .
      return error .
    end.
  end.

  assign
    g#auto                = true
    v-num-entries-db-list = num-entries( p-list-db )
  .
  run gbl/set-gbl.p
    (input true
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  if error-status :error
  then do:
    run write-to-log( substitute("&1. Ошибка при инициализации переменных g#... &2&3&4"
                                  ,vss-workfile
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                )
                    ) .
    return error.
  end.
  assign
    g#auto = true
  .
  
  
  objThObj = new clisub ().
  
  run write-to-log( "Отправка запросов на кассы " ) .
    
  do v-ind = 1 to v-num-entries-db-list
  on error undo, return error
  :
    assign
      v-db-num = integer( entry( v-ind, p-list-db ) )
    .
    
    run write-to-log( "Работа с БД " + string(v-db-num) ) .

/*    Отправка запросов    */
    clients_ :
    for each clients no-lock where clients.obj-type = {&shop} 
                               and clients.db-num = v-db-num
                               and clients.stts = 0 :
      
      run write-to-log( "Отправка запросов по объекту " + clients.obj-type + string(clients.obj-code) ) .
  
    end .
    
    run write-to-log( "Закончена работа с БД " + string(v-db-num) ) .
    
    
  end.

  delete object objThObj no-error . 
  
end.

/* $Workfile: auto-hdd-test.p $ end */