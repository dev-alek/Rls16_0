block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: st-a-upg.p $
$Archive: upg/st-a-upg.p $

Автоматический запуск выполнения шага upgrade

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/
define input parameter p-action    as character no-undo .
define input parameter p-step-num  as integer   no-undo .
define input parameter p-db-num    as integer   no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: st-a-upg.p $":U .
def var vss-archive     as character no-undo init "$Archive: upg/st-a-upg.p $":U .
def var vss-description as character no-undo init "Автоматический запуск выполнения шага upgrade".
{ cmp/vssrevis.i }
{ upg/upg-btpr.i }
{ gbl/cur-time.i }

do
on error undo, return error
:
  define variable v-str       as character no-undo .
  define variable v-curr-date as date      no-undo .
  define variable v-curr-time as integer   no-undo .
  define variable old-propath as character no-undo .

  define variable src-path    as character no-undo .
  define variable target-path as character no-undo .
  define variable prev-ver    as character no-undo .
  define variable ini-path    as character no-undo .


  if transaction then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile )
      view-as alert-box error .
    return error .
  end.
  if valid-handle( session :first-procedure) then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии определений persistent prosedures", vss-workfile )
      view-as alert-box error .
    return error .
  end.

  run init-upgrade ( output src-path
                    ,output target-path
                    ,output prev-ver
                    ,output ini-path
                   ).

  assign
    old-propath = propath
    propath = ".,":U + src-path + {&slash-char} + "upg,":U + src-path + {&slash-char} + "cust":U
  .

  run startupg.w ( input p-action
                 ,input p-step-num
                 ,input prev-ver
                 ,input src-path
                 ,input target-path
                 ,input ini-path
                 ,input true
                ) no-error.
  assign
    propath = old-propath
    v-str = return-value
  .
  if p-step-num = 2 then do:
    if error-status :error then do:
      message
        vss-workfile vss-revision skip
        substitute( "Ошибка выполнения шага &1 upgrade в БД", p-step-num, p-db-num ) skip
        v-str skip
        "Призовая игра"
        view-as alert-box error.
    end.
    else do:
      run upg/upg-clbp.p no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision skip
          "Ошибка при удалении записей о времени запуска Upgrade !"
          view-as alert-box error.
      end.
      message
        v-str skip
        "Необходимо запустить новую версию Автоматической Системы Передачи Новостей"
        view-as alert-box information.
    end.

    quit. /* именно quit, т.к. стуктура изменена и сессию необходимо завершить */
  end.
  else do:
    if error-status :error then do:
      return error v-str.
    end.
    else do:
      return v-str.
    end.
  end.
end.

procedure init-upgrade :

  define output parameter p-src-path    as character no-undo .
  define output parameter p-target-path as character no-undo .
  define output parameter p-prev-ver    as character no-undo .
  define output parameter p-ini-path    as character no-undo .
  do
  on error undo, return error
  :
    define variable err-msg as character no-undo .

    assign
      err-msg = "":U
    .

    get-key-value section "upgrade" key "upg-path" value p-src-path.
    if trim( p-src-path ) = "":U or p-src-path = ? then do:
      assign
        err-msg = (if err-msg = "":U then "":U else {&new-line} )
                  + "Не задан каталог источник пакета upgrade"
      .
    end.
    get-key-value section "upgrade" key "dir-ver"  value p-target-path.
    if trim( p-target-path ) = "":U or p-target-path = ? then do:
      assign
        err-msg = (if err-msg = "":U then "":U else {&new-line} )
                  + "Не задан корневой каталог версии"
      .
    end.
    get-key-value section "upgrade" key "prev-ver" value p-prev-ver.
    if trim( p-prev-ver ) = "":U or p-prev-ver = ? then do:
      assign
        err-msg = (if err-msg = "":U then "":U else {&new-line} )
                  + "Не задан номер версии, с которой производится upgrade"
      .
    end.
/*
    get-key-value section "upgrade" key "ini-path" value p-ini-path.
    if trim( p-ini-path ) = "":U or p-ini-path = ? then do:
      assign
        err-msg = (if err-msg = "":U then "":U else {&new-line} )
                  + "Не задан полный путь к INI файлу настроек системы"
      .
    end.
*/
    if err-msg <> "":U then do:
      run write-to-log( vss-workfile + {&space-char}
                        + "Ошибка инициализации переменных upgrade" + {&new-line}
                        + err-msg + {&new-line}
                        + error-status:get-message(error-status:num-messages)
                      ) .
      return error.
    end.
  end.
  return.
end procedure. /* init-upgrade */


/* $Workfile: st-a-upg.p $ end */