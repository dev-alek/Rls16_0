block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подготовка пакета(ов) новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/04
Author: Dmitry Ukhanov
Creation date: 03/23/04

*/

define input  parameter p-db-num       like ub.db.db-num no-undo . /* БД, куда посылать новости */
define output parameter p-err-gen-pack as   integer      no-undo . /* 0 - нет ошибок */
define output parameter p-cre-all-pck  as   logical      no-undo . /* true - созданы все возможные пакеты */


def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Подготовка пакета(ов) новостей".
{ cmp/vssrevis.i "substitute('&1':u,p-db-num)" }

{ cmp/trg-def.i  }
{ nws/nws-def.i  }
{ gbl/db-attr.i  }
{ gbl/findlock.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-pack-num   as integer   no-undo .
  define variable v-pack-name  as character no-undo .
  define variable v-source-dir as character no-undo .
  define variable v-target-dir as character no-undo .
  define variable v-temp-dir   as character no-undo .

  define variable route-cnt       as integer no-undo .
  define variable rec-cnt         as integer no-undo .
  define variable qnty-of-cur-rec as integer no-undo .
  define variable v-max-pack-size as integer no-undo .

  define variable v-today        as date    no-undo .
  define variable v-time         as integer no-undo .
  define variable v-last-tbl-ord like ub.route.tbl-ord no-undo .

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf-src_db   for ub.db.
  define buffer buf-dst_db   for ub.db.
  define buffer buf_route    for ub.route.
  define buffer buf_pck-sent for ub.pck-sent .

  define variable db-attr-value  as character no-undo .
  define variable db-attr-type   as character no-undo .
  define variable db-attr-exist  as logical   no-undo .

  define variable v-gen-new-pack as logical   no-undo .

  define variable v-fst-pck      as integer   no-undo .

  define variable v-sys-key  as character no-undo . /* для чтения параметра конфигурации */

  define variable mFrameView      as logical   no-undo init yes.
  
  define frame inf
    p-db-num    label "для БД" format ">>>>>>>>9"
    v-pack-num  label "Пакет N" format ">>>>>>>>9"
    route-cnt   label "Основных записей"
    rec-cnt     label "Привязанных"
    with view-as dialog-box side-labels 1 columns three-d title "** Формирование пакета".
  define variable mFramHandle as handle no-undo.      
  mFramHandle = frame inf:handle.

  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameNWSError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameNWSError"). 
  end.
  {gbl/batchmode.i inf}
  mFrameView = not mBatchMode.
  if transaction then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Вызов данной процедуры невозможен при наличии транзакции" )
      view-as alert-box error
    .
    return error .
  end.

  assign
    v-fst-pck = ?
    p-err-gen-pack = 0
    v-gen-new-pack = false
    p-cre-all-pck  = true
  .

  { gbl/currsysk.i
    v-sys-key
    no-error
  }

  run nws/lock-nws.p
    ( input p-db-num
    ,buffer buf-dst_db
    ) no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.

  find last buf_route no-lock
    where buf_route.db-num = p-db-num
      and buf_route.last-pack = -1
    no-error
  .
  if available buf_route then do:
    assign
      v-last-tbl-ord = buf_route.tbl-ord
    .
  end.
  else do:
    assign
      v-last-tbl-ord = 0
    .

  end.
  if mFrameView
  then do:
     view frame inf.
     do with frame inf
     :
       assign
         p-db-num :screen-value   = string( p-db-num, p-db-num :format)
       .
     end.
  end.

  gen-pack:
  do while p-err-gen-pack = 0
  on error undo, return error
  :

    find first buf_route no-lock
      where buf_route.db-num = p-db-num
        and buf_route.last-pack = -1
      no-error
    .

    run db-attr-exist ( input p-db-num
                        ,input {&attr-need-gen-new-pack}
                        ,output db-attr-exist
                      ) no-error.
    if error-status :error then do:
      run write-to-log( substitute("&1. Ошибка при определении наличия атрибута формирования нового пакета для БД &2"
                                   ,vss-workfile
                                   ,p-db-num
                                  )
                      ) .
      undo, return error.
    end.
    run db-attr-value ( input p-db-num
                        ,input {&attr-need-gen-new-pack}
                        ,output db-attr-value
                        ,output db-attr-type
                      ) no-error.
    if error-status :error then do:
      run write-to-log( substitute("&1. Ошибка при чтении атрибута формирования нового пакета для БД &2"
                                   ,vss-workfile
                                   ,p-db-num
                                  )
                      ) .
      undo, return error.
    end.

    if ( available buf_route
         and buf_route.tbl-ord <= v-last-tbl-ord
       )
      or db-attr-exist = false
      or db-attr-value = "yes":U
    then do:
      assign
        v-pack-num     = -1
        v-gen-new-pack = true
      .
      run db-attr-write ( input p-db-num
                        ,input {&attr-need-gen-new-pack}
                        ,input "no":U
                        ) no-error.
      if error-status :error then do:
        run write-to-log( vss-workfile + {&space-char}
                          + "Ошибка записи атрибута формирования нового пакета для БД" + {&space-char}
                          + string( p-db-num )
                        ) .
        assign
          p-err-gen-pack = 2
        .
        undo, return error.
      end.
    end.
    else do:
      if v-gen-new-pack = false then do:
        run write-to-log( substitute( "Нет новой информации для отправки в БД &1", p-db-num ) ) .
      end.
      leave gen-pack .
    end.

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
      run write-to-log( vss-workfile + {&space-char}
                        + "Ошибка при генерации номера пакета." + {&new-line}
                        + substitute( "&1", error-status:get-message(error-status:num-messages) ) + {&new-line}
                        + substitute( "&1", return-value )
                      ) .
      undo, return error.
    end.
    if v-fst-pck = ? then do:
      assign
        v-fst-pck = v-pack-num
      .
    end.
    else do:
      if v-pack-num = v-fst-pck + 30 then do:    /*?????????????????????*/
        assign
          p-cre-all-pck = false
        .
        leave gen-pack .
      end.
    end.
    if mFrameView
    then do with frame inf:
      assign
        p-db-num :screen-value   = string( p-db-num, p-db-num :format)
        v-pack-num :screen-value = string( v-pack-num, v-pack-num :format)
      .
    end.

    run write-to-log( substitute("Подготовка пакета N &1 для БД N &2", v-pack-num, p-db-num ) ).

    find first buf-dst_db
      where buf-dst_db.db-num = p-db-num
      no-error
    .
    if not available buf-dst_db then do:
      run write-to-log( substitute( "&1. Подготовка пакета прервана. БД &2 не найдена.", vss-workfile, p-db-num ) ).
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.

    find first buf_sys-ctrl no-lock .

    find first buf-src_db
      where buf-src_db.db-num = buf_sys-ctrl.db-num
      no-error
    .
    if not available buf-src_db then do:
      run write-to-log( substitute( "&1. Подготовка пакета прервана. БД &2 не найдена.", vss-workfile, buf_sys-ctrl.db-num ) ).
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.

    if buf_sys-ctrl.db-num = 0 then do: /* информацию о кол-ве записей в пакете берем всегда из настроек УБД */
      assign
        v-max-pack-size = buf-dst_db.max-p-size
      .
    end.
    else do:
      assign
        v-max-pack-size = buf-src_db.max-p-size
      .
    end.

    run cur-time( output v-today
                 ,output v-time
                ) no-error .
    if error-status :error then do:
      run write-to-log( vss-workfile + {&space-char} + "Ошибка при определении текущей даты!" ) .
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.

    find first ub.pck-sent no-lock
      where ub.pck-sent.db-num   = p-db-num
        and ub.pck-sent.pack-num = v-pack-num
      no-error
    .
    if available ub.pck-sent then do:
      run write-to-log( substitute( "&1. Пакет с номером &2 уже существует.", vss-workfile, v-pack-num ) ) .
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.

    do transaction
    on error  undo, return error substitute( "&1 (pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (pck-sent). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (pck-sent). endkey", vss-workfile )
    :

      create ub.pck-sent.
      assign
        ub.pck-sent.CreDate        = v-today
        ub.pck-sent.CreTimeInt     = v-time
        ub.pck-sent.CreTime        = string( v-time, "HH:MM:SS" )
        ub.pck-sent.db-num         = p-db-num
        ub.pck-sent.pack-num       = v-pack-num
        ub.pck-sent.rcvd           = no
        ub.pck-sent.total-recs     = ?
        ub.pck-sent.CreNum         = 0
        ub.pck-sent.SendTxtDate    = ?
        ub.pck-sent.SendTxtTimeInt = 0
        ub.pck-sent.SendTxtTime    = "":U
        ub.pck-sent.RcvdDate       = ?
        ub.pck-sent.RcvdTimeInt    = 0
        ub.pck-sent.RcvdTime       = "":U
        ub.pck-sent.CRC-pack       = substitute( "&1 &2 &3 &4", today, time, etime, DBTASKID( "ub":U ) )
      .
    end.
    assign
      route-cnt = 0
      rec-cnt   = 0
    .
    route-label:
    for each buf_route no-lock
      where buf_route.db-num    = p-db-num
        and buf_route.last-pack = -1
      by buf_route.tbl-ord
    on error   undo, return error
    on end-key undo, return error
    :
      if buf_route.tbl-ord > v-last-tbl-ord then do:
        /* кладем в пакет только те записи, которые созданы до начала формирования пакета */
        leave route-label.
      end.

      find ub.route exclusive-lock
        where rowid( ub.route ) = rowid( buf_route )
        no-wait no-error
      .
      if not available ub.route then do:
        if locked ub.route then do:
          run write-to-log( vss-workfile + {&space-char}
                            + substitute( "Подготовка пакета прервана на захваченной записи &1", buf_route.name-rec )
                          ).
          if v-sys-key = {&SuperSysKey}
          then do:
            run gbl/findlock.p
              (input  recid( buf_route )
              ,output table temp-lock
              ) .
            for each temp-lock
            :
              run write-to-log( substitute( "Запись захватил пользователь &1", temp-lock.user-name )
                                + {&new-line} + substitute( "Номер подключения - &1":U, temp-lock.lock-conn-id )
                                + {&new-line} + substitute( "Флаги             - &1":U, temp-lock.lock-flag )
                                + {&new-line} + substitute( "Номер транзакции  - &1":U, temp-lock.trans-id )
                                + {&new-line} + substitute( "Тип подключения   - &1":U, temp-lock.connect-type )
                                + {&new-line} + substitute( "Устройство        - &1":U, temp-lock.connect-device )
                              ).
            end.
          end.
        end.
        else do:
          run write-to-log( vss-workfile + {&space-char}
                            + substitute( "Подготовка пакета прервана на отсутствующей записи &1", buf_route.name-rec )
                          ).
        end.
        assign
          p-err-gen-pack = 1
        .
        leave route-label.
      end.


      if ub.route.num-dump = 0 then do:
        assign
          qnty-of-cur-rec = 1
        .
      end.
      else do:
        assign
          qnty-of-cur-rec = ub.route.num-dump
        .
      end.
      assign
        route-cnt = route-cnt + 1
        rec-cnt = rec-cnt + qnty-of-cur-rec
      .
      if rec-cnt <> qnty-of-cur-rec
        and rec-cnt > v-max-pack-size
      then do:
        leave route-label.
      end.

      if mFrameView
      then do with frame inf
      :
        assign
          p-db-num :screen-value   = string( p-db-num, p-db-num :format)
          v-pack-num :screen-value = string( v-pack-num, v-pack-num :format)
          route-cnt :screen-value  = string( route-cnt, route-cnt :format)
          rec-cnt :screen-value  = string( rec-cnt - route-cnt, rec-cnt :format)
        .
      end.

      assign
        ub.route.last-pack = v-pack-num
      .
    end. /* for each buf_route */

  /*  if p-err-gen-pack = 2 then do:*/
  /*    undo, return error.*/
  /*  end.*/

    do transaction
    on error  undo, return error substitute( "&1 (pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (pck-sent). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (pck-sent). endkey", vss-workfile )
    :

      find first ub.pck-sent exclusive-lock
        where ub.pck-sent.db-num   = p-db-num
          and ub.pck-sent.pack-num = v-pack-num
        no-error
      .
      if not available ub.pck-sent then do:
        run write-to-log( substitute( "&1. Отсутствует шапка пакета с номером &2!", vss-workfile, v-pack-num ) ) .
        assign
          p-err-gen-pack = 2
        .
        undo, return error.
      end.
      assign
        ub.pck-sent.total-recs = route-cnt
      .
    end.

  end.

  if mFrameView
  then 
     hide frame inf.
end.