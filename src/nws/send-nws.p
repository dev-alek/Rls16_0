block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: send-nws.p $
$Archive: nws/send-nws.p $

Отправка новостей в указанную БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input  parameter parparentproc   as   widget-handle        no-undo .
define input  parameter p-action        as   character            no-undo .
define input  parameter p-db-num        like ub.db.db-num         no-undo .
define input  parameter p-pack-num      like ub.pck-sent.pack-num no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: send-nws.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/send-nws.p $":U .
def var vss-description as character no-undo init "Отправка новостей в указанную БД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }

do
on error undo, return error
:
  define buffer buf-dst_db   for ub.db .
  define buffer buf-src_db   for ub.db .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_pck-sent for ub.pck-sent.
  define buffer buf_route    for ub.route .

  define variable v-ver-num      as character no-undo .
  define variable v-pack-num     as integer   no-undo .
  define variable v-pack-name    as character no-undo .
  define variable v-source-dir   as character no-undo .
  define variable v-target-dir   as character no-undo .
  define variable v-temp-dir     as character no-undo .
  define variable v-err-gen-pack as integer   no-undo . /* 0 - нет ошибок */
  define variable v-ind          as integer   no-undo .
  define variable v-max-p-queue  as integer   no-undo .
  define variable v-max-p-time   as integer   no-undo .
  define variable v-err-msg      as character no-undo .
  define variable v-send-1       as logical no-undo initial false. /* минус 1 */
  define variable v-sent-count   as integer no-undo initial 0.

  define temp-table t-list-pack no-undo
    field pack-num    like ub.pck-sent.pack-num
    field re-gen-time as   logical                 initial false
    field SendTxtDate like ub.pck-sent.SendTxtDate initial ?
    index pi is unique primary pack-num ascending
    index iregen re-gen-time SendTxtDate
  .
  define variable v-today        as date      no-undo .
  define variable v-time         as integer   no-undo .
  define variable v-time-wait    as integer   no-undo .


  find first buf_sys-ctrl no-lock .

  run get-version-num in parparentproc
    ( output v-ver-num
    ).

  find first buf-src_db no-lock
    where buf-src_db.db-num = buf_sys-ctrl.db-num
    no-error
  .
  if not available buf-src_db then do:
    run write-to-log( substitute( "&1. БД &2 не найдена", vss-workfile, buf_sys-ctrl.db-num ) ) .
    return error.
  end.

  find first buf-dst_db no-lock
    where buf-dst_db.db-num = p-db-num
    no-error
  .
  if not available buf-dst_db then do:
    run write-to-log( substitute( "&1. БД &2 не найдена", vss-workfile, p-db-num ) ) .
    return error.
  end.

  if buf_sys-ctrl.db-num = 0 then do:
    assign
      v-max-p-queue = buf-dst_db.max-p-queue
      v-max-p-time  = buf-dst_db.max-p-time
    .
  end.
  else do:
    assign
      v-max-p-queue = buf-src_db.max-p-queue
      v-max-p-time  = buf-src_db.max-p-time
    .
  end.

   if buf-dst_db.max-p-queue = 0 and p-db-num > 0  then do:
      run write-to-log( substitute( "Отправка в БД &1 отключена ", p-db-num ) ) .
      return .
   end.

   if buf-dst_db.max-p-queue = -1 then do:         /* минус 1 */
    v-send-1 = true. 
   end.

  case p-action:
    when "one-pack":U then do:
      run write-to-log( substitute("Отправка одного пакета новостей в БД &1", p-db-num ) ) .
    end.
    when "all-unconf":U then do:
      run write-to-log( substitute("Отправка всех неподтвержденных пакетов новостей в БД &1", p-db-num ) ) .
    end.
    when "all":U then do:
      run write-to-log( substitute("Отправка новостей в БД &1", p-db-num ) ) .
    end.
    otherwise do:
      message vss-workfile vss-revision vss-description skip
              substitute( "Не предусмотрена операция &1", p-action )
              view-as alert-box error.
      return error.
    end.
  end case.
  assign
    g#news-source-db = -1
  .

  run nws/lock-nws.p
    ( input p-db-num
     ,buffer buf-dst_db
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.

  assign
    v-err-gen-pack = 0
  .
  for each t-list-pack
  on error undo, return error
  :
    delete t-list-pack .
  end.

  if p-action = "one-pack":U then do:
    create t-list-pack .
    assign
      t-list-pack.pack-num = p-pack-num
    .
  end.
  else do:
    run cur-time in this-procedure
      ( output v-today
       ,output v-time
      ) no-error .
    if error-status :error then do:
      run write-to-log( substitute( "&1. Ошибка при определении текущего времени. &2&3&2&4", vss-workfile, {&new-line}, error-status :get-message(1) , return-value )
                      ) .
      return error.
    end.

    assign
      v-time-wait    = -1
    .

    for each buf_pck-sent no-lock
      where buf_pck-sent.db-num = p-db-num
        and buf_pck-sent.rcvd = no
    on error undo, leave
    : /* посчитаем и составим список отправленных, но неподтвержденных пакетов */
      find first t-list-pack no-lock
        where t-list-pack.pack-num = buf_pck-sent.pack-num
        no-error
      .
      if not available t-list-pack then do:
        create t-list-pack .
        assign
          t-list-pack.pack-num    = buf_pck-sent.pack-num
          t-list-pack.SendTxtDate = buf_pck-sent.SendTxtDate
          v-ind = v-ind + 1
        .
      end.

      if v-max-p-time <> 0
        and buf_pck-sent.SendTxtDate <> ?
        and buf_pck-sent.SendTxtTimeInt <> 0
        and ( buf_pck-sent.SendTxtDate < v-today
              or ( buf_pck-sent.SendTxtDate = v-today
                   and buf_pck-sent.SendTxtTimeInt <= v-time
                 )
            )
      then do:
        assign
          v-time-wait = ( v-today - buf_pck-sent.SendTxtDate ) * 24 * 60 * 60
                        + ( v-time - buf_pck-sent.SendTxtTimeInt )
        .
      end.

      if v-time-wait >= v-max-p-time * 60 then do:
        assign
          t-list-pack.re-gen-time = true
        .
      end.

    end.

    if p-action = "all":U
       and v-send-1 = false          /* минус 1 */
       and v-ind < v-max-p-queue
    then do:
      /* если неподтвержденных пакетов меньше чем задано в настройках, то и не будем их переформировывать */
      for each t-list-pack
        where t-list-pack.re-gen-time = false
          and t-list-pack.SendTxtDate <> ?
      on error undo, return error
      :
        delete t-list-pack .
      end.
    end.
  end.

  gen-pack:
  for each t-list-pack
    by t-list-pack.pack-num
  on error undo, return error
  :
    assign
      v-pack-num = t-list-pack.pack-num
    .
    delete t-list-pack .

    run nws/pck-num.p
      ( input "put":U
       ,input p-db-num
       ,input-output v-pack-num
       ,output v-pack-name
       ,output v-source-dir
       ,output v-target-dir
       ,output v-temp-dir
      ) no-error.
    if error-status:error then do:
      assign
        v-err-msg = substitute( "&1. Ошибка при генерации номера пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
      .
      run write-to-log( v-err-msg ) .
      return error.
    end.

    run nws/exp-pck.p
      ( input parparentproc
      , input p-db-num
      , input v-pack-num
      , input v-source-dir
      , input v-pack-name
      ) no-error.
    if error-status:error then do:
      assign
        v-err-msg = substitute( "&1. Ошибка при формировании пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
      .
      run write-to-log( v-err-msg ) .
      run send-msg-to-email in parparentproc
        ( input substitute( "ТН (ver &1) БД &2. Ошибка СПН при формировании пакета для БД &3", v-ver-num, buf_sys-ctrl.db-num, p-db-num )
         ,input v-err-msg
         ,input "":U
        ) no-error .
      if error-status :error then do:
        run write-to-log( substitute( "&1. &3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                        ) .
      end.
      return error.
    end.


    if v-err-gen-pack <> 2 then do:
      run nws/s-g-pack.p
        ( input "put":U
         ,input "7zip":U
         ,input v-pack-name
         ,input v-source-dir
         ,input v-target-dir
         ,input v-temp-dir
        ) no-error.
      if error-status:error then do:
        run write-to-log( substitute( "&1. Ошибка при отправке пакета. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                        ) .
        return error.
      end.
      v-sent-count = v-sent-count + 1.
    end.
    if v-err-gen-pack <> 0 then do:
      leave gen-pack.
    end.
  end.

  /* минус 1 */
  if v-send-1 = true then do:
  do transaction:

    find first buf-dst_db exclusive-lock
        where buf-dst_db.db-num = p-db-num
        no-error.
    if not available buf-dst_db then do:
        run write-to-log(substitute("&1. Не удалось обновить кол-во неподтвержденных пакетов для БД &2 ", vss-workfile, p-db-num)).
        return error.
    end.
    assign buf-dst_db.max-p-queue = v-sent-count + 1.

  end. 
    run write-to-log(substitute("отправлено &1 пакетов, кол-во неподтвержденных пакетов для БД &2", v-sent-count, buf-dst_db.max-p-queue)).
  end.


  for each t-list-pack
  on error undo, return error
  :
    delete t-list-pack .
  end.

  run gbl/del-file.p
    ( input v-temp-dir
    ) no-error .
  if error-status:error then do:
    run write-to-log( substitute( "&1. Ошибка при удалении временного файла. &2&3&2&4", vss-workfile, {&new-line}, error-status:get-message(1), return-value )
                    ) .
  end.

  case p-action:
    when "one-pack":U then do:
      run write-to-log( substitute("Завершена отправка одного пакета новостей в БД &1", p-db-num ) ) .
    end.
    when "all-unconf":U then do:
      run write-to-log( substitute("Завершена отправка всех неподтвержденных пакетов новостей в БД &1", p-db-num ) ) .
    end.
    when "all":U then do:
      run write-to-log( substitute("Завершена отправка новостей в БД &1", p-db-num ) ) .
    end.
  end case.

end.

/* $Workfile: send-nws.p $ end */