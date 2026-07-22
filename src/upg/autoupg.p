block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: autoupg.p $
$Archive: upg/autoupg.p $

автоматический upgrade

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

define input parameter p-curr-db-num as integer   no-undo .
define input parameter p-action      as character no-undo .
define input parameter p-step-num    as integer   no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: autoupg.p $":U .
def var vss-archive     as character no-undo init "$Archive: upg/autoupg.p $":U .
def var vss-description as character no-undo init "автоматический upgrade".
{ cmp/vssrevis.i }
{ adm/auto-def.i }
{ upg/upg-btpr.i }
{ cmp/strcodec.i }

/*
  BP_Type                   char  - {&btpr-type-upg}
  BP_Status                 char  - {&btpr-normal}
  Key#_One                  inte  - db-num
  Key#_Two                  inte  - complete ( 0 - false, 1 - complete )
  Key#_Three                inte  - step
  CharKey_One               char  - action
  CharKey_Two               char  - flag
  CharKey_Three             char
  User_ID                   char  - error message
  BP_ExecUser_ID            char
  BP_ExecSysDate            date
  BP_ExecSysTime            char
  BP_ExecSysTimeInt         inte
  BP_ExecCountTries         inte

*/

do
on error undo, return error
:
  define variable v-cmd        as character no-undo .

  define variable v-curr-date as date    no-undo .
  define variable v-curr-time as integer no-undo .

  define variable v-msg       as character no-undo .

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

  run upg/st-a-upg.p ( input p-action
                  ,input p-step-num
                  ,input p-curr-db-num
                  ) no-error.
  assign
    v-msg = return-value
  .
  if error-status :error then do:
    assign
      v-msg = vss-workfile + {&space-char}
              + substitute( "Ошибка выполнения upgrade в БД &1. Шаг &2", p-curr-db-num, p-step-num ) + {&new-line}
              + v-msg + {&new-line}
              + error-status:get-message(error-status:num-messages)
    .
    run write-to-log( v-msg ) .
    if p-curr-db-num <> 0 then do:
      /* Ошибка выполнения upgrade, рапортуем в ГБД об этом */
      assign
        v-cmd = "command":U + {&delim-nws}
                + "upgrade":U + {&delim-nws}
                + string( p-action ) + {&delim-nws}
                + string( p-step-num ) + {&delim-nws}
                + string( p-curr-db-num ) + {&delim-nws}
                + "Err":U + {&delim-nws}
                + str-encode ( v-msg, "":U, {&new-line} )
      .
      run nws/cr-route.p ( input {&send-cmd}, input v-cmd, input ?, input "0":U ).
    end.
  end.
  else do:
    run write-to-log( v-msg ) .
    if p-step-num = {&num-unblock-step} then do:
      run upg/upg-clbp.p no-error .
      if error-status :error then do:
        run write-to-log( vss-workfile + {&space-char} + "Ошибка при удалении записей о времени запуска Upgrade ! (1)" ).
      end.
    end.
    else do:
      run cur-time ( output v-curr-date
                    ,output v-curr-time
                    ).
      run upg/upg-edbp.p ( input p-action
                      ,input p-step-num
                      ,input string( p-curr-db-num )
                      ,input "Ok":U
                      ,input "":U
                      ,input v-curr-date
                      ,input v-curr-time
                     ) no-error .
      if error-status :error then do:
        run write-to-log( substitute( "Ошибка при записи времени запуска Upgrade в БД &1 !", p-curr-db-num ) ).
      end.
      if p-curr-db-num = 0 then do:
        /* Шаг выполнен успешно, переходим к выполнению следующего шага */
        run upg/upg-edbp.p ( input p-action
                        ,input p-step-num + 1
                        ,input string( p-curr-db-num )
                        ,input "Run":U
                        ,input "":U
                        ,input v-curr-date
                        ,input v-curr-time
                       ) no-error .
        if error-status :error then do:
          run write-to-log( substitute( "Ошибка при записи времени запуска Upgrade в БД &1 !", p-curr-db-num ) ).
        end.
/*
        if p-step-num = {&num-check-step} then do:
          run edit-next-run-nws no-error .
          if error-status :error then do:
            run write-to-log( "Ошибка при записи времени следующего сеанса связи!" ).
          end.
        end.
*/
      end.
      else do:
        /* Шаг выполнен успешно, рапортуем в ГБД об этом */
        assign
          v-cmd = "command":U + {&delim-nws}
                  + "upgrade":U + {&delim-nws}
                  + string( p-action ) + {&delim-nws}
                  + string( p-step-num ) + {&delim-nws}
                  + string( p-curr-db-num ) + {&delim-nws}
                  + "Ok":U + {&delim-nws}
                  + str-encode ( v-msg, "":U, {&new-line} )
        .
        run nws/cr-route.p ( input {&send-cmd}, input v-cmd, input ?, input "0":U ).
      end.
    end.
  end.

end.
/*
procedure edit-next-run-nws :
  do
  on error undo, return error
  :
    define variable v-curr-date as date    no-undo .
    define variable v-curr-time as integer no-undo .

    define buffer buf_db for ub.db .

    run cur-time ( output v-curr-date
                  ,output v-curr-time
                  ).

    for each buf_db no-lock
    on error undo, return error
    :
      find first buf_BatchProcess
        where buf_BatchProcess.BP_Type     = {&btpr-type-autonws}
          and buf_BatchProcess.CharKey_One = string( buf_db.db-num )
        no-error
      .
      if available buf_BatchProcess then do:
        assign
          buf_BatchProcess.BP_ExecSysDate    = v-curr-date
          buf_BatchProcess.BP_ExecSysTimeInt = v-curr-time
          buf_BatchProcess.BP_ExecSysTime    = string(v-curr-time, 'HH:MM:SS':U)
        .
      end.
    end.
  end.
end procedure. /* edit-next-run-nws */
*/