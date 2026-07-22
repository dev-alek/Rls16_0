block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт пакета новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input  parameter parparentproc as   widget-handle        no-undo .
define input  parameter p-db-num      like ub.db.db-num         no-undo . /* БД, куда посылать новости                             */
define input  parameter p-pack-num    like ub.pck-sent.pack-num no-undo . /* номер экспортируемого пакета                          */
define input  parameter p-source-dir  as   character            no-undo . /* каталог в котором создается файл                      */
define input  parameter p-pack-name   as   character            no-undo . /* файл в который происходит экспорт                     */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт пакета новостей".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-db-num,p-pack-num,p-source-dir,p-pack-name)" }

{ cmp/trg-def.i  }
{ nws/nws-def.i  }
{ gbl/db-attr.i  }
{ nws/exp-pck.i "'def'" new }
{ gbl/findlock.i }
{ gbl/gate-clb.i }


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-err    as integer no-undo . /* 0 - нет ошибок */

  define variable rec-cnt as integer no-undo .
  define variable lin-cnt as integer no-undo .

  define variable v-ver-num       as character no-undo .
  define variable v-today         as date      no-undo .
  define variable v-time          as integer   no-undo .
  define variable v-prev-crc      as character no-undo .
  define variable v-pck-full-name as character no-undo .
  define variable v-tmp-file      as character no-undo .

  define buffer buf-prev_pck-sent   for ub.pck-sent.
  define buffer buf_pck-sent        for ub.pck-sent.
  define buffer buf-dst_db          for ub.db.
  define buffer buf-src_db          for ub.db.
  define buffer buf_route           for ub.route.
  define buffer buf_route-dump      for ub.route-dump.
  define buffer buf_temp-xml-tables for temp-xml-tables.

  define variable v-uniq-key-rt    as character no-undo .

  define variable tt-name         as character no-undo .
  define variable tth             as handle    no-undo .
  define variable bh_tt           as handle    no-undo .
  define variable bh_route-dump   as handle    no-undo .
  define variable v-ok            as logical   no-undo .
  define variable v-first-char    as character no-undo .
  define variable v-dsh           as handle    no-undo .
  define variable v-dsh-dump      as handle    no-undo .
  define variable v-xmlh          as handle    no-undo .
  define variable v-found-gate    as logical   no-undo .
  define variable v-sys-key  as character no-undo . /* для чтения параметра конфигурации */

  define frame exp-pck
    p-db-num     label "для БД" skip
    p-source-dir label "Каталог" format "x(40)" skip
    p-pack-name  label "Пакет"   format "x(40)" skip
    rec-cnt      label "Записей в пакете"
    lin-cnt      label "Строк в пакете"
    with view-as dialog-box side-labels 1 columns three-d title "** Экспорт пакета".
  define variable mFrameView      as logical   no-undo init yes.
  
  {gbl/batchmode.i exp-pck}
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameNWSError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameNWSError"). 
  end.

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
    v-xmlh          = buffer buf_temp-xml-tables:handle
    v-pck-full-name = p-source-dir + {&back-slash-char} + p-pack-name
    v-tmp-file      = p-source-dir + {&back-slash-char} + substring( p-pack-name, 1, r-index( p-pack-name, '.':u) ) + 'tmp':U
  .

  { gbl/currsysk.i
    v-sys-key
    no-error
  }
if mFrameView
  then do:
     view frame exp-pck.
     assign
       frame exp-pck:title = substitute( "&1 для БД &2", frame exp-pck:title, trim( string( p-db-num, ">>>>>>>>9" ) ) )
     .
  end.
  
  assign
    v-err = 0
  .
  if mFrameView
  then
     display
       p-db-num
       p-source-dir
       p-pack-name
       with frame exp-pck.

  find first buf_pck-sent no-lock
    where buf_pck-sent.db-num   = p-db-num
      and buf_pck-sent.pack-num = p-pack-num
    no-error
  .
  if available buf_pck-sent then do:
    if buf_pck-sent.SendTxtDate <> ? then do:
      run write-to-log( substitute("Переформирование файла пакета N &1 для БД N &2", p-pack-num, p-db-num ) ).
    end.
    else do:
      run write-to-log( substitute("Формирование файла пакета N &1 для БД N &2", p-pack-num, p-db-num ) ).
    end.
  end.
  else do:
    run write-to-log( substitute("&1. Пакет N &2 для БД N &3 отсутствует.", vss-workfile, p-pack-num, p-db-num ) ).
    undo, return error .
  end.

  run gbl/del-file.p ( input v-tmp-file ) no-error .
  if error-status :error then do:
    return error return-value .
  end.

  find first buf-src_db no-lock
    where buf-src_db.db-num = g#db-num
  .
  find first buf-dst_db no-lock
    where buf-dst_db.db-num = p-db-num
    no-error
  .
  if not available buf-dst_db then do:
    run write-to-log( substitute( "&1. Формирование пакета прервано. БД &2 не найдена.", vss-workfile, p-db-num ) ).
    undo, return error.
  end.

  run get-version-num in parparentproc
    ( output v-ver-num
    ).

  { nws/exp-pck.i
    "'open'"
    v-tmp-file
  }

  assign
    rec-cnt       = 1
    lin-cnt       = 2
    v-uniq-key-rt = "":U
    .
  find buf-prev_pck-sent no-lock
    where buf-prev_pck-sent.db-num   = p-db-num
      and buf-prev_pck-sent.pack-num = p-pack-num - 1
    no-error
  .
  if available buf-prev_pck-sent then do:
    assign
      v-prev-crc = buf-prev_pck-sent.crc-pack
    .
  end.
  else do:
    assign
      v-prev-crc = "":U
    .
  end.

  create t-pck-conf.
  assign
    t-pck-conf.sys-key    = v-sys-key
    t-pck-conf.db-num-dst = p-db-num
    t-pck-conf.db-num-src = g#db-num
    t-pck-conf.pack-num   = p-pack-num
    t-pck-conf.total-recs = ?
    t-pck-conf.src_db-key = buf-src_db.db-key
    t-pck-conf.dst_db-key = buf-dst_db.db-key
    t-pck-conf.ver-num    = v-ver-num
    t-pck-conf.prev-crc   = v-prev-crc
  .
  find last buf_route no-lock
     where buf_route.db-num    = p-db-num
       and buf_route.last-pack = buf_pck-sent.pack-num
     use-index pi
     no-error .
  if available buf_route
  then do:
    assign
      t-pck-conf.actual-date     = buf_route.CreDate
      t-pck-conf.actual-time-int = buf_route.CreTimeInt
    .
  end.
  else do:
    assign
      t-pck-conf.actual-date     = buf_pck-sent.CreDate
      t-pck-conf.actual-time-int = buf_pck-sent.CreTimeInt
    .
  end.
  { nws/exp-pck.i
    "'exp-tbl+'"
    "'pck-conf'"
    "''"
    "(buffer t-pck-conf:handle)"
    "''"
    "''"
    "''"
    0
    0
    rec-cnt
  }

  for each ub.pck-sent no-lock
    where ub.pck-sent.db-num   = p-db-num
      and ub.pck-sent.rcvd     = no
      and ub.pck-sent.pack-num < p-pack-num
      and ub.pck-sent.SendTxtDate = ?
  on error  undo, return error substitute( "&1 (for each ub.pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each ub.pck-sent). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each ub.pck-sent). endkey", vss-workfile )
  :
    assign
      rec-cnt = rec-cnt + 1
      lin-cnt = lin-cnt + 2
      .
    { nws/exp-pck.i
      "'exp-tbl+'"
      "'pck-sent'"
      "''"
      "(buffer ub.pck-sent:handle)"
      "''"
      "''"
      "''"
      0
      0
      rec-cnt
    }
    if mFrameView
    then
       display
         rec-cnt
         lin-cnt
         with frame exp-pck.
  end. /* for each ub.pck-sent ... */
  for each ub.pck-rcvd no-lock
     where ub.pck-rcvd.db-num     = p-db-num
       and ub.pck-rcvd.rcvd       = no  /* еще не получено подтверждение на подтверждение */
       and ub.pck-rcvd.total-recs = ub.pck-rcvd.rcvd-recs  /* пакет разобран полностью */
  on error  undo, return error substitute( "&1 (for each ub.pck-rcvd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each ub.pck-rcvd). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each ub.pck-rcvd). endkey", vss-workfile )
  :
    assign
      rec-cnt = rec-cnt + 1
      lin-cnt = lin-cnt + 2
      .
    { nws/exp-pck.i
      "'exp-tbl+'"
      "'pck-rcvd'"
      "''"
      "(buffer ub.pck-rcvd:handle)"
      "''"
      "''"
      "''"
      0
      0
      rec-cnt
    }
    if mFrameView
    then
       display
         rec-cnt
         lin-cnt
         with frame exp-pck.
  end. /* for each ub.pck-rcvd ... */

  for each ub.pck-rcvd-attr no-lock
    where ub.pck-rcvd-attr.db-num = p-db-num
  on error  undo, return error substitute( "&1 (for each ub.pck-rcvd). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each ub.pck-rcvd). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each ub.pck-rcvd). endkey", vss-workfile )
  :
    assign
      rec-cnt = rec-cnt + 1
      lin-cnt = lin-cnt + 2
      .
    { nws/exp-pck.i
      "'exp-tbl+'"
      "'pck-rcvd-attr'"
      "''"
      "(buffer ub.pck-rcvd-attr:handle)"
      "''"
      "''"
      "''"
      0
      0
      rec-cnt
    }
    display
      rec-cnt
      lin-cnt
      with frame exp-pck.
  end. /* for each ub.pck-rcvd-attr ... */

  route-label:
  for each buf_route no-lock
     where buf_route.db-num    = p-db-num
       and buf_route.last-pack = buf_pck-sent.pack-num
     use-index pi
  on error  undo, return error substitute( "&1 (for each buf_route). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (for each buf_route). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (for each buf_route). endkey", vss-workfile )
  :
      find ub.route exclusive-lock
        where recid( ub.route ) = recid( buf_route )
        no-wait no-error
      .
      if not available ub.route then do:
        if locked ub.route then do:
          run write-to-log( substitute( "&1. Формирование пакета прервано на захваченной записи route (&2)", vss-workfile, buf_route.name-rec )
                            + {&new-line} + substitute( "recid route: &1 уникальный ключ записи: &2 ", recid( buf_route ), buf_route.uniq-key-rec )
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
          run write-to-log( substitute( "&1. Формирование пакета прервано на отсутствующей записи &2", vss-workfile, buf_route.name-rec )
                          ).
        end.
        assign
          v-err = 1
        .
        leave route-label.
      end.

      assign
        v-uniq-key-rt = substitute("&1&2&3", ub.route.tbl-ord, {&delim-urt}, ub.route.dump-ord )
      .

      case entry(1,ub.route.name-rec,{&delim-nws}) :
        when "delete"
        or when "create"
        or when "command"
        or when "get-seq"
        or when "put-seq"
        or when "dlcr"
        then do :
          assign
            rec-cnt = rec-cnt + 1
            lin-cnt = lin-cnt + 1
            .
          { nws/exp-pck.i
            "'exp-cmd'"
            ub.route.name-rec
            ub.route.uniq-gate-rec
            v-uniq-key-rt
            ub.route.num-dump
            0
            rec-cnt
          }
        end.
        otherwise do :
          assign
            rec-cnt = rec-cnt + 1
            .

          find first ub.route-dump no-lock
             where ub.route-dump.dump-ord = ub.route.dump-ord
             no-error.
          if not available ub.route-dump then do:
            run write-to-log( substitute( "&1. Отсутствуют записи связаной таблицы для &2, dump-ord=&3", vss-workfile, buf_route.name-rec, ub.route.dump-ord )
                            ).
            assign
              v-err = 2
            .
            leave route-label.

          end.
        end.
      end case.
      v-found-gate = no.

      if ub.route.uniq-gate-rec <> '':U then do:
        define variable v-longchar as longchar no-undo.
        v-longchar = ?.
        run get-gate-by-rec in this-procedure ( input ub.route.uniq-gate-rec
                                               ,output v-dsh
                                               ,input-output v-xmlh
                                               ,input-output v-longchar
                                               ) no-error.
        if error-status:error
        then do:
          run write-to-log( substitute("&1 Ошибка при создании структуры маршрутизируемых данных согласно гейту:&2&3"
                                       , vss-workfile
                                       , ub.route.uniq-gate-rec
                                       , ub.route.name-rec )
                          ).
          assign
            v-err = 2
          .
          leave route-label.
        end.
        v-found-gate = yes.
      end.

      for each ub.route-dump exclusive-lock
          where ub.route-dump.dump-ord = ub.route.dump-ord
          use-index pi
      on error  undo, return error substitute( "&1 (for each ub.route-dump). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (for each ub.route-dump). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (for each ub.route-dump). endkey", vss-workfile )
      :

        assign
          lin-cnt      = lin-cnt + 2
          v-first-char = substring( trim( ub.route-dump.action ), 1, 1 )
        .

        if v-first-char = "-":U then do:
          { nws/exp-pck.i
            "'exp-tbl-'"
            ub.route-dump.dump-name
            ub.route-dump.action
            "''"
            ub.route.uniq-key-rec
            ub.route-dump.uniq-gate-rec
            v-uniq-key-rt
            ub.route.num-dump
            ub.route-dump.rec-ord
            rec-cnt
          }
        end.
        else do:
           assign
           bh_route-dump = (buffer ub.route-dump:handle)
           tt-name       = "tt_":U + ub.route-dump.dump-name
           .
          if ub.route-dump.uniq-gate-rec = '':U then do:
            create temp-table tth.
            assign
              tth:undo      = false
             .

            assign
              v-ok = tth:create-like( "ub.":U + ub.route-dump.dump-name ) no-error
            .
            if v-ok <> true
              or error-status :error
            then do:
              return error substitute( "&1. Ошибка при создании временной таблицы &2 (1).&3&4", vss-workfile, tt-name, {&new-line}, error-status:get-message(1) ).
            end.

            assign
              v-ok = tth:temp-table-prepare( tt-name ) no-error
            .
            if v-ok <> true
              or error-status :error
            then do:
              return error substitute( "&1. Ошибка при создании временной таблицы &2 (2).&3&4", vss-workfile, tt-name, {&new-line}, error-status:get-message(1) ).
            end.

            assign
              bh_tt = tth:default-buffer-handle
            .
          end.
          else do:
            if ub.route-dump.uniq-gate-rec <> ub.route.uniq-gate-rec then do:
              v-longchar = ?.
              run get-gate-by-rec in this-procedure ( input ub.route-dump.uniq-gate-rec
                                                    ,output v-dsh-dump
                                                    ,input-output v-xmlh
                                                    ,input-output v-longchar
                                                    ) no-error.
              if error-status:error
              then do:
                run write-to-log( substitute("&1 Ошибка при создании структуры маршрутизируемых данных согласно гейту:&2&3"
                                            , vss-workfile
                                            , ub.route.uniq-gate-rec
                                            , ub.route.name-rec )
                                ).
                assign
                  v-err = 2
                .
                leave route-label.
              end.
              v-found-gate = yes.
            end.

            find first buf_temp-xml-tables no-lock where
                      buf_temp-xml-tables.tbl-name = ub.route-dump.dump-name
                  and buf_temp-xml-tables.uniq-gate-rec = ub.route-dump.uniq-gate-rec
                      no-error.
            if not available buf_temp-xml-tables then do:
              run write-to-log( substitute("&1 Не найдена таблица &2 в гейте &3"
                                          , vss-workfile
                                          , ub.route-dump.dump-name
                                          , ub.route-dump.uniq-gate-rec
                                          )
                              ).
              assign
                v-err = 2
              .
              leave route-label.
            end.
            assign
            bh_tt = buf_temp-xml-tables.tbl-handle_
            tth = buf_temp-xml-tables.table-handle_
            .
          end.
          assign
            v-ok = bh_tt:buffer-create no-error
          .
          if v-ok <> true
            or error-status :error
          then do:
            run all-gates-clear in this-procedure (  buffer buf_temp-xml-tables).
            return error substitute( "&1. Ошибка при создании буфера временной &2 .&3&4", vss-workfile, tt-name, {&new-line}, error-status:get-message(1) ).
          end.

          assign
            v-ok = bh_tt:raw-transfer ( false, bh_route-dump:buffer-field("value-rec") ) no-error
          .
          if v-ok <> true
            or error-status :error
          then do:
            run all-gates-clear in this-procedure ( buffer buf_temp-xml-tables).
            return error substitute( "&1. RAW-TRANSFER не прошел для таблицы &2 (dump-ord=&3, rec-ord=&4).&5&6"
                                      , vss-workfile
                                      , tt-name
                                      , bh_route-dump:buffer-field("dump-ord"):buffer-value
                                      , bh_route-dump:buffer-field("rec-ord"):buffer-value
                                      , {&new-line}
                                      , error-status:get-message(1) ).
          end.

          { nws/exp-pck.i
            "'exp-tbl+'"
            ub.route-dump.dump-name
            ub.route-dump.action
            bh_tt
            ub.route.uniq-key-rec
            ub.route-dump.uniq-gate-rec
            v-uniq-key-rt
            ub.route.num-dump
            ub.route-dump.rec-ord
            rec-cnt
          }
          if ub.route-dump.uniq-gate-rec = '':U then do:
            assign
              v-ok = tth:clear() no-error
            .
          end.
          else do:
            assign
              v-ok = bh_tt:buffer-delete no-error
            .
          end.
          if v-ok <> true
            or error-status :error
          then do:
            run all-gates-clear in this-procedure ( buffer buf_temp-xml-tables).
            return error substitute( "&1. Ошибка при очистке временной временной &2 .&3&4", vss-workfile, tt-name, {&new-line}, error-status:get-message(1) ).
          end.
          if ub.route-dump.uniq-gate-rec = '':U then do:
            delete object tth .
          end.

          if mFrameView
          then
             display
               lin-cnt
               with frame exp-pck.

        end.

      end. /*      for each ub.route-dump exclusive-lock*/
      if v-found-gate then do:
        run all-gates-clear in this-procedure (  buffer buf_temp-xml-tables).
      end.
      if mFrameView
      then
         display
           rec-cnt
           lin-cnt
           with frame exp-pck.
  end. /* for each buf_route */

  assign
    v-uniq-key-rt = "":U
  .

  run cur-time( output v-today
               ,output v-time
              ) no-error .
  if error-status :error then do:
    run write-to-log( substitute( "&1. Ошибка при определении текущей даты!", vss-workfile )
                    ) .
    run all-gates-clear in this-procedure ( buffer buf_temp-xml-tables).
    undo, return error.
  end.

  if v-err = 0 then do:
    do transaction
    on error  undo, return error substitute( "&1 (do transaction). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (do transaction). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (do transaction). endkey", vss-workfile )
    :

      find first buf_pck-sent exclusive-lock
        where buf_pck-sent.db-num   = p-db-num
          and buf_pck-sent.pack-num = p-pack-num
      .
      assign
        rec-cnt = rec-cnt + 1
        buf_pck-sent.total-recs     = rec-cnt + 1
        buf_pck-sent.CreNum         = buf_pck-sent.CreNum + 1
        buf_pck-sent.SendTxtDate    = v-today
        buf_pck-sent.SendTxtTimeInt = v-time
        buf_pck-sent.SendTxtTime    = string( v-time, "HH:MM:SS" )
        .
      { nws/exp-pck.i
        "'exp-tbl+'"
        "'pck-sent'"
        "''"
        "(buffer buf_pck-sent:handle)"
        "''"
        "''"
        "''"
        0
        0
        rec-cnt
      }
    end.

    assign
      rec-cnt               = rec-cnt + 1
      t-pck-conf.total-recs = rec-cnt
      .
    { nws/exp-pck.i
      "'exp-tbl+'"
      "'pck-conf'"
      "''"
      "(buffer t-pck-conf:handle)"
      "''"
      "''"
      "''"
      0
      0
      rec-cnt
    }
  end.

  delete t-pck-conf.

  { nws/exp-pck.i "'close'" }

  if v-err <> 0 then do:
    run all-gates-clear in this-procedure ( buffer buf_temp-xml-tables).
    undo, return error.
  end.
  else do:
    run gbl/ren-file.p
      ( input v-tmp-file
       ,input v-pck-full-name
      ) no-error .
    if error-status :error then do:
      run write-to-log( vss-workfile + {&space-char} + substitute( "&1", return-value ) ).
      return error return-value .
    end.

    return .
  end.


end.
if mFrameView
then
   hide frame exp-pck.