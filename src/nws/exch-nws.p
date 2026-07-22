block-level on error undo, throw.
/*

$Revision: 55d27c209910, 3559, rls $
$Author: BelovaMM $
$Date: 2023/11/27 08:31:19 $
$Workfile: exch-nws.p $
$Archive: nws/exch-nws.p $

Обмен новостями (при необходимости)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input  parameter parparentproc   as widget-handle no-undo .
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-list-db       as character no-undo .

def var vss-revision    as character no-undo init "$Revision: 55d27c209910, 3559, rls $":U .
def var vss-author      as character no-undo init "$Author: BelovaMM $":U .
def var vss-date        as character no-undo init "$Date: 2023/11/27 08:31:19 $":U .
def var vss-workfile    as character no-undo init "$Workfile: exch-nws.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/exch-nws.p $":U .
def var vss-description as character no-undo init "Обмен новостями (при необходимости)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }

do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
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


  if transaction then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile )
      view-as alert-box error .
    return error .
  end.
  if p-user-login ne ? and valid-handle( session :first-procedure ) then do:
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
    g#news                = true
    v-num-entries-db-list = num-entries( p-list-db )
  .
if     p-user-login    ne ?
     and p-user-password ne ?
  then do:
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
end.
  assign
    g#news = true
  .

  /* прием новостей из всех БД */
  do v-ind = 1 to v-num-entries-db-list
  on error undo, return error
  :
    assign
      v-db-num = integer( entry( v-ind, p-list-db ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.

    run nws/rcvd-nws.p
      ( input parparentproc
      , input "take+analys":U
      , input v-db-num
      , input -1
      ) no-error.
    if error-status:error then do:
      run write-to-log( substitute("&1. ERROR!!! Ошибка при приеме и(или) разборе пакетов новостей из БД &2&3&4&5&6"
                                   ,vss-workfile
                                   ,entry( v-ind, p-list-db )
                                   ,{&new-line}
                                   ,error-status:get-message(error-status:num-messages)
                                   ,{&new-line}
                                   ,return-value
                                  )
                      ) .
    end.
    assign
      add-log-file-name = ?
    .
  end.

  /* проверка необходимости выполнения шага upgrade */
/*  assign*/
/*    v-step-num = ?*/
/*  .*/
/*  run upg/chk-upg.p ( output v-action*/
/*                 ,output v-step-num*/
/*                ) no-error.*/
/*  if error-status:error then do:*/
/*    run write-to-log( substitute("&1. Ошибка при определении необходимости upgrade. &2&3&4"*/
/*                                  ,vss-workfile*/
/*                                  ,error-status:get-message(error-status:num-messages)*/
/*                                  ,{&new-line}*/
/*                                  ,return-value*/
/*                                )*/
/*                    ) .*/
/*  end.*/

/*  if v-step-num <> ? then do:*/
/*    run write-to-log ( substitute( "Запущена система автоматического Upgrade (шаг &1)", v-step-num ) ).*/

/*    /* перед выполнением шага upgrade необходимо удалить persistent procedures */*/
/*    run gbl/del-pers.p no-error .*/
/*    if error-status :error then do:*/
/*    run write-to-log( substitute("&1. Ошибка при удалении persistent procedures. &2&3&4"*/
/*                                  ,vss-workfile*/
/*                                  ,error-status:get-message(error-status:num-messages)*/
/*                                  ,{&new-line}*/
/*                                  ,return-value*/
/*                                )*/
/*                    ) .*/
/*    end.*/
/*    else do:*/
/*      /* выполнение шага upgrade */*/
/*      run upg/autoupg.p ( input g#db-num*/
/*                     ,input v-action*/
/*                     ,input v-step-num*/
/*                    ) no-error.*/
/*    end.*/

/*    run write-to-log ( substitute( "Завершена работа системы автоматического Upgrade (шаг &1)", v-step-num ) ).*/
/*  end.*/

  if v-num-entries-db-list > 0 then do:
    run write-to-log ( substitute( "Подготовка новых пакетов." ) ).
    run nws/cnew-pck.p
      ( input p-list-db
       ,output v-err-code
      ) no-error .
    if error-status:error then do:
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при подготовке пакетов новостей &2&3&4"
                                    ,vss-workfile
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                  )
                      ) .
    end.
    else do:
      assign
        v-message = return-value
      .
      if v-message <> "":U then do:
        run write-to-log ( substitute( "&1", v-message ) ).
      end.
      run write-to-log ( substitute( "Завершена подготовка новых пакетов." ) ).
    end.

    if v-err-code = 2 then do:
      return error .
    end.

  end.

  /* отправка новостей во все БД */
  do v-ind = 1 to v-num-entries-db-list
  on error undo, return error
  :

    assign
      v-db-num = integer( entry( v-ind, p-list-db ) )
    .
    if g#db-num = 0 then do:
      assign
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
    end.
    run nws/send-nws.p
      ( input parparentproc
      , input "all":U
      , input v-db-num
      , input -1
      ) no-error.
    if error-status:error then do:
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при отправке новостей в БД &2&3&4&5&6"
                                    ,vss-workfile
                                    ,entry( v-ind, p-list-db )
                                    ,{&new-line}
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                  )
                      ) .
    end.
    assign
      add-log-file-name = ?
    .
  end.

  /* удаление пакетов новостей получивших подтверждение */
  if g#db-num = 0 then do:

    do v-ind = 1 to v-num-entries-db-list
    on error undo, return error
    :
      assign
        v-db-num = integer( entry( v-ind, p-list-db ) )
        add-log-file-name = substring( log-file-name, 1, r-index( log-file-name, '.':u) - 1 ) + substitute( "-&1.log", v-db-num )
      .
      run nws/rem-pck.p
        ( input parparentproc
        , input v-db-num
        ) no-error.
      if error-status:error then do:
        run write-to-log( substitute( "&1. ERROR!!! Ошибка при удалении пакетов СПН по БД &2&3&4&5&6"
                                      ,vss-workfile
                                      ,v-db-num
                                      ,{&new-line}
                                      ,error-status:get-message(error-status:num-messages)
                                      ,{&new-line}
                                      ,return-value
                                    )
                        ) .
      end.
      assign
        add-log-file-name = ?
      .
    end.
  end.
  else do:
    run nws/rem-pck.p
      ( input parparentproc
      , input g#db-num
      ) no-error.
    if error-status:error then do:
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при удалении пакетов СПН &2&3&4&5"
                                    ,vss-workfile
                                    ,{&new-line}
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                  )
                      ) .
    end.
  end.

   /* архивирование лога проверки марок и удаление лога */
  run utl/gismt-arh.p no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. ERROR!!! Ошибка при архивировании лога проверки марок &2&3&4&5"
                                  ,vss-workfile
                                  ,{&new-line}
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                )
                    ) .
  end.
  
end.

/* $Workfile: exch-nws.p $ end */