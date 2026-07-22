block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-upg.p $
$Archive: upg/chk-upg.p $

Проверка необходимости выполнения upgrade

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/
define output parameter p-action   as character no-undo .
define output parameter p-step-num as integer   no-undo .


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: chk-upg.p $":U .
def var vss-archive     as character no-undo init "$Archive: upg/chk-upg.p $":U .
def var vss-description as character no-undo init "Проверка необходимости выполнения upgrade".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/auto-def.i }
{ upg/upg-btpr.i }

do
on error undo, return error
:
  define buffer buf_sys-ctrl     for ub.sys-ctrl .
  define buffer buf_BatchProcess for ub.BatchProcess .
  define buffer buf_db           for ub.db .
  define buffer buf_route        for ub.route .

  define variable v-curr-db-num   as integer   no-undo .
  define variable v-curr-time     as integer   no-undo .
  define variable v-curr-date     as date      no-undo .
  define variable v-db-ready      as logical   no-undo .
  define variable v-cmd           as character no-undo .

  find first buf_sys-ctrl no-lock.

  assign
    v-curr-db-num = buf_sys-ctrl.db-num
    p-action     = ?
    p-step-num   = ?
  .

  run cur-time ( output v-curr-date
                ,output v-curr-time
               ) no-error.
  if error-status :error then do:
    return error string( vss-workfile + {&space-char} + "Ошибка при определении текущего времени" ) .
  end.

  find first buf_BatchProcess no-lock
    where buf_BatchProcess.BP_Type   = {&btpr-type-autoupg}
      and buf_BatchProcess.BP_Status = {&btpr-normal}
      and buf_BatchProcess.Key#_One  = v-curr-db-num
      and buf_BatchProcess.Key#_Two  = 0
      and ( buf_BatchProcess.BP_ExecSysDate < v-curr-date
            or (buf_BatchProcess.BP_ExecSysDate = v-curr-date
                and buf_BatchProcess.BP_ExecSysTimeInt <= v-curr-time
                )
          )
    no-error
  .
  if available buf_BatchProcess then do:
    assign
      p-action   = buf_BatchProcess.CharKey_One
      p-step-num = buf_BatchProcess.Key#_Three
      v-db-ready = TRUE
    .

    if v-curr-db-num = 0 then do:
      for each buf_db no-lock
         where buf_db.db-num > 0
      on error undo, return error
      :
        find first buf_BatchProcess /* exclusive-lock нельзя, транзакция недопустима */
          where buf_BatchProcess.BP_Type     = {&btpr-type-autoupg}
            and buf_BatchProcess.BP_Status   = {&btpr-normal}
            and buf_BatchProcess.Key#_One    = buf_db.db-num
            and buf_BatchProcess.Key#_Two    = 1
            and buf_BatchProcess.Key#_Three  = p-step-num
            and buf_BatchProcess.CharKey_One = p-action
          no-error
        .
        if not available buf_BatchProcess then do:
          if p-step-num = {&num-check-step} then do:
            assign
              v-db-ready = FALSE
            .
          end.
          find first buf_BatchProcess /* exclusive-lock нельзя, транзакция недопустима */
            where buf_BatchProcess.BP_Type     = {&btpr-type-autoupg}
              and buf_BatchProcess.BP_Status   = {&btpr-normal}
              and buf_BatchProcess.Key#_One    = buf_db.db-num
              and buf_BatchProcess.Key#_Two    = 0
              and buf_BatchProcess.Key#_Three  = p-step-num
              and buf_BatchProcess.CharKey_One = p-action
            no-error
          .
          assign
            v-cmd = "command":U + {&delim-nws}
                    + "upgrade":U + {&delim-nws}
                    + string( p-action ) + {&delim-nws}
                    + string( p-step-num ) + {&delim-nws}
                    + string( buf_db.db-num ) + {&delim-nws}
                    + "Run":U + {&delim-nws}
                    + "":U
          .
          if available buf_BatchProcess then do:
            if p-step-num = {&num-pie-step} then do:
              find first buf_route no-lock
                where buf_route.db-num    = buf_db.db-num
                  and buf_route.last-pack = -1
                  and buf_route.name-rec = v-cmd
                no-error
              .
              if available buf_route then do:
                assign
                  v-db-ready = FALSE
                .
              end.
            end.
            run write-to-log( substitute( "БД &1: не выполнен шаг &2", buf_db.db-num, p-step-num ) ) .
            if buf_BatchProcess.User_ID <> "":U then do:
              run write-to-log( buf_BatchProcess.User_ID ) .
            end.
          end.
          else do:
            if p-step-num = {&num-pie-step} then do:
              assign
                v-db-ready = FALSE
              .
  /*
              run edit-next-run-nws no-error .
              if error-status :error then do:
                run write-to-log( "Ошибка при записи времени следующего сеанса связи!" ).
              end.
  */
            end.

            run write-to-log( substitute( "Создание команды на выполнение шага &2 в БД &1 ", buf_db.db-num, p-step-num ) ) .
            run nws/cr-route.p ( input {&send-cmd}, input v-cmd, input ?, input string( buf_db.db-num ) ).

            run upg/upg-edbp.p ( input p-action
                            ,input p-step-num
                            ,input string( buf_db.db-num )
                            ,input "Run":U
                            ,input "":U
                            ,input v-curr-date
                            ,input v-curr-time
                           ) no-error .
            if error-status :error then do:
              run write-to-log( substitute( "Ошибка при записи времени запуска Upgrade в БД &1 !", buf_db.db-num ) ).
            end.
          end.
        end.
      end.
    end.
    if v-db-ready = false then do:
      assign
        p-action   = ?
        p-step-num = ?
      .
    end.

  end.

end.

return.

/* $Workfile: chk-upg.p $ end */