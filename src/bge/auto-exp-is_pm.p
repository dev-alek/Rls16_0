block-level on error undo, throw.
/*

$Revision: b65640f2406f, 2724, rls $
$Author: SSlivenko $
$Date: Пн янв 18 10:14:31 2021 +0300 $
$Workfile: auto-exp-is_PM.p $
$Archive: bge/auto-exp-is_PM.p $

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
using ibs.th.bge.is_PM.*.


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num      as integer      no-undo .
define input parameter p-cre-db-num as integer   no-undo .
define input parameter p-task-type  as character no-undo .
define input parameter p-task-num   as integer   no-undo .

def var vss-revision    as character no-undo init "$Revision: b65640f2406f, 2724, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Пн янв 18 10:14:31 2021 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-exp-is_PM.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-exp-is_PM.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС меркурий".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ adm/auto-def.i }
{ gbl/getsect.i def }
{ ref/shd-attr.i }


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
  
  define variable v-appId           as character no-undo .
  define variable v-status_         as character no-undo .
  define variable v-Msg             as character no-undo .
  
  define buffer buf_clients           for ub.clients .
  define buffer buf_esys-all-attr     for ub.esys-all-attr .
  define buffer buf_db                for ub.db .
  
  define variable objKeyRec     as class ibs.th.gbl.keyrec                no-undo.
  define variable is_PM         as class is_PM no-undo .
  
  define variable v-param-list as character no-undo .
  define variable v-param-type as character no-undo .
  
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
  .
  run gbl/set-gbl.p
    (input true
    ,input g#auto-user-id
    ,input g#auto-user-password
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
    return error .
  end.
  assign
    g#auto = true
  .
  
  
  find first buf_db no-lock where buf_db.db-num = p-db-num .
  if buf_db.stts = 2
  then do :
    run write-to-log( "БД " + string(p-db-num) + " выгружается. Пропускаем." ).
    return error .
  end.
 
  run write-to-log( "Работа с БД " + string(p-db-num) ) .
  
  run schedule-attr-value in this-procedure
    (input  p-cre-db-num
    ,input  p-task-type
    ,input  p-task-num
    ,input  {&attr-schedule-param-list-h}
    ,output v-param-list
    ,output v-param-type
    ) .

  if v-param-list = ""
  then do :
    run write-to-log( "В расписании не заданы параметры выгрузки. Пропускаем." ).
    return error .
  end .
    
  clients_ :
  for each clients no-lock where clients.obj-type = {&shop} 
                             and clients.db-num = p-db-num
                             and clients.stts = 0 :
    
    is_PM = new is_PM (input p-db-num,
                       input clients.obj-code,
                       input v-param-list,
                       input parparentproc,
                       input this-procedure)
                      .
    
    is_PM:exec_1c() .
   
    run str/send1C-some-data.p (input parparentproc,
                                input this-procedure,
                                input parparentproc,
                                input is_PM:Data,
                                input "operating-balances") 
                                no-error .
    if error-status:error
    then do :
      run write-to-log( "Ошибка при отправке в 1С. " + return-value ).
    end .   
    
    if is_PM:oneMoreTime
    then do :
      is_PM:exec_1c() .
     
      run str/send1C-some-data.p (input parparentproc,
                                  input this-procedure,
                                  input parparentproc,
                                  input is_PM:Data,
                                  input "operating-balances") 
                                  no-error .
      if error-status:error
      then do :
        run write-to-log( "Ошибка при отправке в 1С. " + return-value ).
      end .
      is_PM:oneMoreTime = false .
    end .
    delete object is_PM .                                      
  end.
  
  run write-to-log( "Закончена работа с БД " + string(p-db-num) ) .

end.

/* $Workfile: auto-exp-is_PM.p $ end */