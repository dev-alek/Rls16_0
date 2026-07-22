block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

процедура импорта пакета

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input  parameter parparentproc   as   widget-handle        no-undo .
define input  parameter p-db-src        like ub.db.db-num         no-undo. /* номер БД источника                 */
define input  parameter p-pck-num       like ub.pck-sent.pack-num no-undo. /* номер импортируемого пакета        */
define input  parameter p-file-pck-name as   character            no-undo. /* файл из которого происходит импорт */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "процедура импорта пакета".

{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-db-src,p-pck-num,p-file-pck-name)" }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }
{ gbl/db-attr.i  } /* используется в imp-pck.p */
{ gbl/pck-attr.i } /* используется в imp-pck.p */
{ str/imp2cd.i   }
{ nws/imp-pck.i new }
{ gbl/key-rec.i  }
{ gbl/gate-clb.i }
{ nws/lib-nws.i  }
{ nws/imp-pck1.i }

define stream imp-stream.

define temp-table tt_pck-rcvd      no-undo like ub.pck-rcvd .
define temp-table tt_pck-rcvd-attr no-undo like ub.pck-rcvd-attr .
define temp-table tt_pck-sent      no-undo like ub.pck-sent .

define variable v-sub-rec-cnt as integer   no-undo.
define variable v-rec-cnt     as integer   no-undo.
define variable v-file-hash   as character no-undo .

define frame imp-pck
  p-db-src        label "БД" skip
  p-pck-num       label "Пакет" format ">>>>>>>>>9" skip
  p-file-pck-name label "Файл пакета" format "x(50)" skip
  v-rec-cnt       label "Основных записей" format ">>>>>>>>>9" skip
  v-sub-rec-cnt   label "Привязанных" format ">>>>>>>>>9" skip
  with view-as dialog-box side-labels 1 columns three-d title "** Разбор пакета"
.
  define variable mFrameView      as logical   no-undo init yes.
  {gbl/batchmode.i imp-pck}
  
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
/*  return error substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile ).*/
end.

run str/imp2cdseth.p(this-procedure).

main_block:
do
on error  undo, return error substitute("&1. error main_block. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo, return error substitute("&1. endkey main_block")
on stop   undo, return error substitute("&1. stop main_block")
:

  define variable v-err-msg as character no-undo .

  /* все очистим */
  for each gds-list:
    delete gds-list.
  end.
  for each gdsolist:
    delete gdsolist.
  end.
  for each bc-list:
    delete bc-list.
  end.
  for each pbc-list:
    delete pbc-list.
  end.
  for each dc-list:
    delete dc-list.
  end.
  for each cash-txn:
    delete cash-txn.
  end.
  for each cash-txr:
    delete cash-txr.
  end.
  for each stpl-list:
    delete stpl-list.
  end.
  for each cash-pay-list:
    delete cash-pay-list.
  end.
  for each PromoAction-list:
    delete PromoAction-list.
  end.  
   for each ext-classif-list:
      delete ext-classif-list.
   end.
   for each c-ext-classif-list:
      delete c-ext-classif-list.
   end.
  assign
    v-err-msg = "":U .
  .

  run gbl/md5.p(p-file-pck-name, output v-file-hash).
  run write-to-log( substitute("Файл: &1; Контрольная сумма: &2.", p-file-pck-name,  v-file-hash) ) .

  input stream imp-stream from value( p-file-pck-name ).

  run local-imp-pck in this-procedure
     no-error .
  if error-status :error then do:
    assign
      /* Здесь надо хоть что-нибудь написать, иначе если вернется return-value пустой, то будет беда */
      v-err-msg = substitute( "Ошибка приема пакета &1&2&3", p-file-pck-name, {&new-line}, return-value ).
    .
  end.

  input stream imp-stream close .

  { nws/imp-pck3.i }

  run send-to-cash no-error.
  if error-status:error then do: /* это не глобальная ошибка поэтому отката не будет */
    run write-to-log("Ошибка при отправке на кассу" + {&new-line}
                     + return-value
                    ) no-error.
  end.
  assign
    g#news-source-db = -1
  .

  if v-err-msg <> "":U then do:
    undo, return error v-err-msg .
  end.

end.

return .

procedure local-imp-pck :

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define buffer buf_sys-ctrl          for ub.sys-ctrl .
    define buffer buf_pck-sent          for ub.pck-sent .
    define buffer buf_pck-rcvd          for ub.pck-rcvd .
    define buffer buf-src_db            for ub.db .
    define buffer buf-dst_db            for ub.db .
    define buffer buf-for-sent_pck-rcvd for ub.pck-rcvd.
    define buffer buf-for-rcvd_pck-sent for ub.pck-sent .
    define buffer buf_route             for ub.route .

    define variable v-ver-num     as character no-undo .

    define variable v-rec-full       as character no-undo.
    define variable v-rec-name       as character no-undo.
    define variable v-sub-rec-num    as integer   no-undo.
    define variable v-curr-rowid     as rowid     no-undo .
    define variable v-uniq-gate-rec  as character no-undo .
    define variable v-uniq-key-rt    as character no-undo .
    define variable Ok               as logical   no-undo.
    define variable pck-name-bad     as character no-undo.
    define variable v-present        as logical   no-undo .
    define variable v-ind            as integer   no-undo.
    define variable v-qnty-skip      as integer   no-undo.

    define variable v-today          as date      no-undo .
    define variable v-time           as integer   no-undo .

    define variable v-prev-crc       as character no-undo .
    define variable v-pos            as integer   no-undo .
    define variable v-temp-str       as character no-undo .
    define variable v-temp-all       as character extent 1000 no-undo .

    define variable v-beg-date      as character no-undo .
    define variable v-beg-time      as character no-undo .
    define variable v-type          as character no-undo .
    define variable v-deleted       as logical   no-undo .

    
    define variable v-pck-attr-exist as logical   no-undo .

    define variable v-del-pck-num    as integer   no-undo.
    define variable v-del-cnt        as integer   no-undo.

    define frame del-route
      v-del-pck-num   label "Пакет N" format ">>>>>>>>>9" skip
      v-del-cnt       label "Записей" format ">>>>>>>>>9"
      with view-as dialog-box side-labels 1 columns three-d title "Удаление маршрутизации"
    .

    find buf-src_db no-lock
      where buf-src_db.db-num = p-db-src
    .
    if trim( buf-src_db.db-key ) = "":U
      or buf-src_db.db-key = ?
    then do:
      run write-to-log( substitute("СПН для БД &1 отключена. Пакеты не принимаются.", p-db-src ) ) .
      undo, return error.
    end.
    find first buf_sys-ctrl no-lock .
    find buf-dst_db no-lock
      where buf-dst_db.db-num = buf_sys-ctrl.db-num
    .

    run write-to-log( substitute("Разбор пакета N &1 из БД N &2", p-pck-num, p-db-src ) ) no-error.

    if mFrameView
    then do: 
       view frame imp-pck.

       assign
         frame imp-pck:title = substitute( "&1 из БД &2", frame imp-pck:title, trim( string( p-db-src, ">>>>>>>>9" ) ) )
       .
    

       do with frame imp-pck
       :
          assign
             p-db-src :screen-value        = string( p-db-src, p-db-src :format)
             p-pck-num :screen-value       = string( p-pck-num, p-pck-num :format)
             p-file-pck-name :screen-value = string( p-file-pck-name, p-file-pck-name :format)
          .
       end.
    end.
    run cur-time in this-procedure
      ( output v-today
      , output v-time
      ) no-error .
    if error-status :error then do:
      run write-to-log( vss-workfile + {&space-char}
                        + "Ошибка при определении текущей даты!"
                      ).
      undo, return error.
    end.

    run pck-attr-exist
      ( input "pck-rcvd":U
      , input p-db-src
      , input p-pck-num
      , input {&attr-beg-imp-date}
      , output v-pck-attr-exist
      ) no-error.
    if error-status :error then do:
      run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута начала разбора пакета &2 из БД &3"
                                    ,vss-workfile
                                    ,p-pck-num
                                    ,p-db-src
                                  )
                      ) .
    end.
    if v-pck-attr-exist <> true then do:
      /* запомним информацию о времени начала разбора в атрибуты, */
      /* потому что самой записи pck-rcvd не будет пока пакет не разберется до конца */
      run pck-attr-write in this-procedure
        ( input "pck-rcvd":U
        , input p-db-src
        , input p-pck-num
        , input {&attr-beg-imp-date}
        , input string( v-today, "99/99/9999" )
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута даты начала разбора пакета &2 из БД &3"
                                      ,vss-workfile
                                      ,p-pck-num
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
      run pck-attr-write in this-procedure
        ( input "pck-rcvd":U
        , input p-db-src
        , input p-pck-num
        , input {&attr-beg-imp-time}
        , input string( v-time, ">>>>>>>>>9" )
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута времени начала разбора пакета &2 из БД &3"
                                      ,vss-workfile
                                      ,p-pck-num
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
      /* если вдруг пакет не будет принят до конца, то информацию о начале его разбора все-равно надо отправить */
      run db-attr-write in this-procedure
        ( input p-db-src
        ,input {&attr-need-gen-new-pack}
        ,input "yes":U
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута формирования нового пакета для БД &2"
                                      ,vss-workfile
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.
    end.

    find first buf_pck-rcvd no-lock
      where buf_pck-rcvd.db-num   = p-db-src
        and buf_pck-rcvd.pack-num = p-pck-num - 1
      no-error
    .
    if available buf_pck-rcvd then do:
      assign
        v-prev-crc = buf_pck-rcvd.crc-pack
      .
    end.
    else do:
      assign
        v-prev-crc = "":U
      .
    end.

    assign
      Ok = FALSE
      .

    assign
      g#news-source-db = p-db-src
      v-rec-cnt = 0
      v-sub-rec-cnt = 0
    .
    run nws-imps in this-procedure
      ( input-output v-sub-rec-cnt
       ,output       v-rec-full
      ) no-error.
    if error-status :error
      or v-rec-full = ?
    then do:
      undo, return error substitute( "Ошибка приема записи N &1&2&3", v-rec-cnt, {&new-line}, return-value ).
    end.
    else do:
      assign
        v-rec-name = trim( entry( 1, v-rec-full, {&delim-nws} ) )
      .
    end.

    if v-rec-name <> "pck-conf":U then do:
      run write-to-log( substitute( "&1. Ошибка пакета! Первая запись должна быть конфигурацией пакета ( pck-conf )"
                                    ,vss-workfile
                                  )
                      ).
      undo, return error.
    end.

    create t-pck-conf.
    run nws-impl-without-check in this-procedure
      ( input (buffer t-pck-conf:handle)
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.

    run get-version-num in parparentproc
      ( output v-ver-num
      ).

    /*if v-ver-num = "":U
      or num-entries( t-pck-conf.ver-num, ".":U ) < 2
      or num-entries( v-ver-num, ".":U ) < 2
      or entry( 1, t-pck-conf.ver-num, ".":U ) <> entry( 1, v-ver-num, ".":U )
      or entry( 2, t-pck-conf.ver-num, ".":U ) <> entry( 2, v-ver-num, ".":U )
    then do:
      run write-to-log( substitute( '&1. Ошибка приема! Текущая версия "&2", а данный пакет сформирован в версии "&3"'
                                    ,vss-workfile
                                    ,v-ver-num
                                    ,t-pck-conf.ver-num
                                  )
                      ).
      undo, return error.
    end.*/

    if t-pck-conf.db-num-dst <> g#db-num then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета для БД № &2, а данный пакет для БД № &3"
                                    ,vss-workfile
                                    ,g#db-num
                                    ,t-pck-conf.db-num-dst
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.db-num-src <> p-db-src then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета из БД № &2, а данный пакет из БД № &3"
                                    ,vss-workfile
                                    ,p-db-src
                                    ,t-pck-conf.db-num-src
                                  )

                      ).
      undo, return error.
    end.
    if t-pck-conf.src_db-key <> buf-src_db.db-key then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета из БД с ключем &2, а данный пакет из БД с ключем &3"
                                    ,vss-workfile
                                    ,buf-src_db.db-key
                                    ,t-pck-conf.src_db-key
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.dst_db-key <> buf-dst_db.db-key then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается прием пакета для БД с ключем &2, а данный пакет для БД с ключем &3"
                                    ,vss-workfile
                                    ,buf-dst_db.db-key
                                    ,t-pck-conf.dst_db-key
                                  )
                      ).
      undo, return error.
    end.
    if t-pck-conf.pack-num <> p-pck-num then do:
      run write-to-log( substitute( "&1. Ошибка приема! Ожидается пакет № &2, а данный пакет № &3"
                                  ,vss-workfile
                                  ,p-pck-num
                                  ,t-pck-conf.pack-num
                                  )
                      ).
      undo, return error.
    end.

    if t-pck-conf.prev-crc <> v-prev-crc then do:
      run write-to-log( substitute("&1. Ошибка приема! Пакет &2 сформирован в некорректной БД", vss-workfile, p-pck-num) ).
      undo, return error.
    end.

    run trg/db-stat.p
      (input p-db-src                     /* p-db-num    */
      ,input t-pck-conf.actual-date     /* p-fact-date */
      ,input t-pck-conf.actual-time-int /* p-fact-time */
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "Ошибка при вызове сохранении даты актуальности остатков &1 &2 запись N &3 ", {&new-line}, return-value, v-rec-cnt ) .
    end.

    beg-imp:
    repeat
    on error  undo, return error substitute("&1. error beg-imp. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on endkey undo, return error substitute("&1. endkey beg-imp")
    on stop   undo, return error substitute("&1. stop beg-imp")
    :

      assign
        v-sub-rec-cnt = 0
      .
      run nws-imps in this-procedure
        ( input-output v-sub-rec-cnt
         ,output       v-rec-full
        ) no-error.
      if error-status :error
        or v-rec-full = ?
      then do:
        undo, return error substitute( "Ошибка приема записи N &1&2&3", v-rec-cnt, {&new-line}, return-value ).
      end.

      assign
        v-rec-name    = trim( entry( 1, v-rec-full, {&delim-nws} ) )
      .
      if v-rec-name <> {&nwspck-end} then do:
        assign
          v-uniq-gate-rec = entry( num-entries( v-rec-full, {&delim-nws} ) - 4, v-rec-full, {&delim-nws} )
          v-uniq-key-rt   = entry( num-entries( v-rec-full, {&delim-nws} ) - 3, v-rec-full, {&delim-nws} )
          v-sub-rec-num   = integer( entry( num-entries( v-rec-full, {&delim-nws} ) - 2, v-rec-full, {&delim-nws} ) )
        .
      end.

      CASE v-rec-name:
        when "pck-conf":U then do :
          run nws-impl-without-check in this-procedure
            ( input (buffer t-pck-conf:handle)
            ) no-error.
          if error-status :error then do:
            return error return-value .
          end.
        end.
        when {&table_pck-sent} then do :

          transaction_block_pck-sent:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_pck-sent. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
          on endkey undo, return error substitute("&1. endkey transaction_block_pck-sent")
          on stop   undo, return error substitute("&1. stop transaction_block_pck-sent")
          :
            create tt_pck-sent.
            assign
              v-pos = seek( imp-stream )
            .
            run nws-impl-without-check in this-procedure
              ( input (buffer tt_pck-sent:handle)
              ) no-error.
            if error-status :error then do:
              return error return-value .
            end.
            if tt_pck-sent.pack-num = p-pck-num then do:
              /* запись о текущем пакете делается по окончании приема */
              if trim( tt_pck-sent.crc-pack ) = "" then do:
                seek stream imp-stream to v-pos .
                import stream imp-stream UNFORMATTED v-temp-str .
                run write-to-log( vss-workfile + {&space-char}
                                  + substitute( "Ошибка обработки пакета: пакет N &1 не имеет ключа!!!", p-pck-num ) + {&new-line}
                                  + substitute(" Позиция в файле &1", seek(imp-stream) ) + {&new-line}
                                  + substitute("&1", v-temp-str ) + {&new-line}
                                  ).
                undo, return error.
              end.
              if num-entries( tt_pck-sent.crc-pack, {&space-char} ) < 4 then do:
                seek stream imp-stream to v-pos .
                import stream imp-stream UNFORMATTED v-temp-str .
                run write-to-log( vss-workfile + {&space-char}
                                  + substitute( "Ошибка обработки пакета: некорректный ключ (&1) пакета N &2 !!!", tt_pck-sent.crc-pack, p-pck-num ) + {&new-line}
                                  + substitute(" Позиция в файле &1", seek(imp-stream) ) + {&new-line}
                                  + substitute("&1", v-temp-str ) + {&new-line}
                                  ).
                undo, return error.
              end.
            end.
            else do:
              find first buf-for-sent_pck-rcvd exclusive-lock
                where buf-for-sent_pck-rcvd.db-num   = p-db-src
                  and buf-for-sent_pck-rcvd.pack-num = tt_pck-sent.pack-num
                no-error.
              if not available buf-for-sent_pck-rcvd then do:
                create buf-for-sent_pck-rcvd.
                buffer-copy tt_pck-sent to buf-for-sent_pck-rcvd
                  assign
                    buf-for-sent_pck-rcvd.db-num     = p-db-src
                    buf-for-sent_pck-rcvd.rcvd-recs  = 0
                .
              end.
            end.
          end.
        end.
        when {&table_pck-rcvd} then do :
          create tt_pck-rcvd.
          run nws-impl-without-check in this-procedure
            ( input (buffer tt_pck-rcvd:handle)
            ) no-error.
          if error-status :error then do:
            return error return-value .
          end.

          find first buf-for-rcvd_pck-sent no-lock
            where buf-for-rcvd_pck-sent.db-num   = p-db-src
              and buf-for-rcvd_pck-sent.pack-num = tt_pck-rcvd.pack-num
            no-error.

          if available buf-for-rcvd_pck-sent then do:
            assign
              v-del-cnt = 0
            .
            if mFrameView
            then  
               view frame del-route .

            for each buf_route exclusive-lock
              where buf_route.db-num    = buf-for-rcvd_pck-sent.db-num
                and buf_route.last-pack = tt_pck-rcvd.pack-num
            on error  undo, return error substitute("&1. error buf_route &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
            on endkey undo, return error substitute("&1. endkey buf_route")
            on stop   undo, return error substitute("&1. stop buf_route")
            :
              assign
                v-del-cnt = v-del-cnt + 1
              .
              if mFrameView
              then do with frame del-route
              :
                assign
                  v-del-pck-num :screen-value   = string( buf_route.last-pack, v-del-pck-num :format)
                  v-del-cnt :screen-value       = string( v-del-cnt, v-del-cnt :format)
                .
              end.
              delete buf_route.
            end.

            if mFrameView
            then  
               hide frame del-route .

            transaction_block_pck-rcvd:
            do transaction
            on error  undo, return error substitute("&1. error transaction_block_pck-rcvd &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
            on endkey undo, return error substitute("&1. endkey transaction_block_pck-rcvd")
            on stop   undo, return error substitute("&1. stop transaction_block_pck-rcvd")
            :
              run cur-time in this-procedure
                ( output v-today
                , output v-time
                ) no-error .
              if error-status :error then do:
                run write-to-log( vss-workfile + {&space-char}
                                  + "Ошибка при определении текущей даты!"
                                ).
                undo, return error.
              end.
              find first buf-for-rcvd_pck-sent exclusive-lock
                where buf-for-rcvd_pck-sent.db-num   = p-db-src
                  and buf-for-rcvd_pck-sent.pack-num = tt_pck-rcvd.pack-num
                .
              if buf-for-rcvd_pck-sent.BegImpDate = ? then do:
                assign
                  buf-for-rcvd_pck-sent.BegImpDate    = tt_pck-rcvd.BegImpDate
                  buf-for-rcvd_pck-sent.BegImpTimeInt = tt_pck-rcvd.BegImpTimeInt
                  buf-for-rcvd_pck-sent.BegImpTime    = tt_pck-rcvd.BegImpTime
                .
              end.
              assign
                buf-for-rcvd_pck-sent.rcvd          = yes
                buf-for-rcvd_pck-sent.EndImpDate    = tt_pck-rcvd.EndImpDate
                buf-for-rcvd_pck-sent.EndImpTimeInt = tt_pck-rcvd.EndImpTimeInt
                buf-for-rcvd_pck-sent.EndImpTime    = tt_pck-rcvd.EndImpTime
                buf-for-rcvd_pck-sent.RcvdDate      = v-today
                buf-for-rcvd_pck-sent.RcvdTimeInt   = v-time
                buf-for-rcvd_pck-sent.RcvdTime      = string( v-time, "HH:MM:SS" )
              .
            end.
          end.
          delete tt_pck-rcvd.
        end.
        when {&table_pck-rcvd-attr} then do :
          create tt_pck-rcvd-attr.
          run nws-impl-without-check in this-procedure
            ( input (buffer tt_pck-rcvd-attr:handle)
            ) no-error.
          if error-status :error then do:
            return error return-value .
          end.
          transaction_block_pck-rcvd-attr:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_pck-rcvd-attr &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
          on endkey undo, return error substitute("&1. endkey transaction_block_pck-rcvd-attr")
          on stop   undo, return error substitute("&1. stop transaction_block_pck-rcvd-attr")
          :
            find first buf-for-rcvd_pck-sent exclusive-lock
              where buf-for-rcvd_pck-sent.db-num   = p-db-src
                and buf-for-rcvd_pck-sent.pack-num = tt_pck-rcvd-attr.pack-num
              no-error.

            if available buf-for-rcvd_pck-sent then do:
              case tt_pck-rcvd-attr.attr-code :
                when {&attr-beg-imp-date} then do:
                  assign
                    buf-for-rcvd_pck-sent.BegImpDate    = date( tt_pck-rcvd-attr.attr-value )
                  .
                end.
                when {&attr-beg-imp-time} then do:
                  assign
                    buf-for-rcvd_pck-sent.BegImpTimeInt = integer( tt_pck-rcvd-attr.attr-value )
                    buf-for-rcvd_pck-sent.BegImpTime    = string( buf-for-rcvd_pck-sent.BegImpTimeInt, "HH:MM:SS" )
                  .
                end.
              end case.
            end.
          end.
          delete tt_pck-rcvd-attr.
        end.
        when {&nwspck-end} then do:
          assign
            v-rec-cnt = v-rec-cnt - 1
            OK = yes
            .
          leave beg-imp.
        end.
        when      "delete"
          or when "create"
          or when "command"
          or when "get-seq"
          or when "put-seq"
          or when "dlcr"
        then do : /* обработка команд */
          transaction_block_command:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_command&3&2&3&4&3запись N &5&3привязанная запись &6", vss-workfile, return-value, {&new-line}, error-status :get-message(1), v-rec-cnt, v-sub-rec-cnt )
          on endkey undo, return error substitute("&1. endkey transaction_block_command&2запись N &3&2привязанная запись &4", vss-workfile, {&new-line}, v-rec-cnt, v-sub-rec-cnt )
          on stop   undo, return error substitute("&1. stop transaction_block_command&2запись N &3&2привязанная запись &4", vss-workfile, {&new-line}, v-rec-cnt, v-sub-rec-cnt )
          :
            run check-imp-rec in this-procedure
              ( input  "create":U
               ,input  p-db-src
               ,input  p-pck-num
               ,input  v-uniq-key-rt
               ,output v-present
              ) no-error .
            if error-status :error then do:
              undo, return error substitute( "&1 запись N &2&3Позиция в файле &4", return-value, v-rec-cnt, {&new-line}, seek(imp-stream) ) .
            end.
            if v-present = true then do:
              assign
                v-qnty-skip  = v-sub-rec-num * 2
              .
              do v-ind = 1 to v-qnty-skip :
                /* пропускаем строчки */
                import stream imp-stream v-temp-all .
              end.
            end.
            else do:
              run nws/imp-cmd.p
                ( input this-procedure
                 ,input v-rec-full
                 ,input v-sub-rec-num
                 ,input p-db-src
                ).
            end.
          end.
        end.
        otherwise do :
          transaction_block_otherwise:
          do transaction
          on error  undo, return error substitute("&1. error transaction_block_otherwise&3&2&3&4&3запись N &5&3привязанная запись &6", vss-workfile, return-value, {&new-line}, error-status :get-message(1), v-rec-cnt, v-sub-rec-cnt )
          on endkey undo, return error substitute("&1. endkey transaction_block_otherwise&2запись N &3&2привязанная запись &4", vss-workfile, {&new-line}, v-rec-cnt, v-sub-rec-cnt )
          on stop   undo, return error substitute("&1. stop transaction_block_otherwise&2запись N &3&2привязанная запись &4", vss-workfile, {&new-line}, v-rec-cnt, v-sub-rec-cnt )
          :
            run check-imp-rec in this-procedure
              ( input  "create":U
               ,input  p-db-src
               ,input  p-pck-num
               ,input  v-uniq-key-rt
               ,output v-present
              ) no-error .
            if error-status :error then do:
              undo, return error substitute( "&1 запись N &2&3Позиция в файле &4", return-value, v-rec-cnt, {&new-line}, seek(imp-stream) ) .
            end.
            if v-present = true then do:
              /* пропускаем строчки */
              assign
                v-qnty-skip  = v-sub-rec-num * 2 + 1
              .
              do v-ind = 1 to v-qnty-skip :
                import stream imp-stream v-temp-all .
              end.
            end.
            else do:
              { nws/imp-pck2.i
                v-rec-name
                v-uniq-gate-rec
                p-pck-num
                v-sub-rec-num
                v-curr-rowid
              }
            end.
          end.
        end.
      END CASE.
    end.

    if t-pck-conf.total-recs <> v-rec-cnt then do:
      run write-to-log( vss-workfile + {&space-char}
                        + "Не совпадает количество считанных записей и ожидаемое количество :" + {&new-line}
                        + "принято: " + string( v-rec-cnt ) + {&new-line}
                        + "должно быть:" + string( t-pck-conf.total-recs )
                      ).
      undo, return error.
    end.

    transaction_block_end:
    do transaction
    on error  undo, return error substitute("&1. error transaction_block_end &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on endkey undo, return error substitute("&1. endkey transaction_block_end")
    on stop   undo, return error substitute("&1. stop transaction_block_end")
    :
      /* создать запись о данном пакете в целевой ( данной ) БД */
      find first tt_pck-sent no-lock
        where tt_pck-sent.db-num   = g#db-num
          and tt_pck-sent.pack-num = p-pck-num
        no-error
      .
      if not available tt_pck-sent then do:
        run write-to-log( substitute( "&1. Отсутствует полная информация о пакете &2 для БД &3"
                                      ,vss-workfile
                                      ,p-pck-num
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.

      run cur-time in this-procedure
        ( output v-today
        , output v-time
        ) no-error .
      if error-status :error then do:
        run write-to-log( vss-workfile + {&space-char}
                          + "Ошибка при определении текущей даты!"
                        ).
        undo, return error.
      end.

      find first buf_pck-rcvd exclusive-lock
        where buf_pck-rcvd.db-num   = p-db-src
          and buf_pck-rcvd.pack-num = p-pck-num
        no-error.
      if not available buf_pck-rcvd then do:
        create buf_pck-rcvd.
        buffer-copy tt_pck-sent to buf_pck-rcvd
          assign
            buf_pck-rcvd.db-num     = p-db-src
        .
        run pck-attr-exist
          ( input "pck-rcvd":U
          , input p-db-src
          , input p-pck-num
          , input {&attr-beg-imp-date}
          , output v-pck-attr-exist
          ) no-error.
        if error-status :error then do:
          run write-to-log( substitute( "&1. Ошибка при определении наличия атрибута начала разбора пакета &2 из БД &3"
                                        ,vss-workfile
                                        ,p-pck-num
                                        ,p-db-src
                                      )
                          ) .
        end.
        if v-pck-attr-exist = true then do:
          run pck-attr-value in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input {&attr-beg-imp-date}
            , output v-beg-date
            , output v-type
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка получения атрибута даты начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.
          run pck-attr-delete in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input {&attr-beg-imp-date}
            , output v-deleted
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка при удалении атрибута даты начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.
          run pck-attr-value in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input {&attr-beg-imp-time}
            , output v-beg-time
            , output v-type
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка получения атрибута времени начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.

          run pck-attr-delete in this-procedure
            ( input "pck-rcvd":U
            , input p-db-src
            , input p-pck-num
            , input {&attr-beg-imp-time}
            , output v-deleted
            ) no-error.
          if error-status :error then do:
            run write-to-log( substitute( "&1. Ошибка при удалении атрибута времени начала разбора пакета &2 из БД &3"
                                          ,vss-workfile
                                          ,p-pck-num
                                          ,p-db-src
                                        )
                            ) .
            undo, return error.
          end.
          assign
            buf_pck-rcvd.BegImpDate    = date( v-beg-date )
            buf_pck-rcvd.BegImpTimeInt = integer( v-beg-time )
            buf_pck-rcvd.BegImpTime    = string( buf_pck-rcvd.BegImpTimeInt, "HH:MM:SS" )
          .
        end.
      end.
      assign
        buf_pck-rcvd.rcvd-recs     = v-rec-cnt
        buf_pck-rcvd.EndImpDate    = v-today
        buf_pck-rcvd.EndImpTimeInt = v-time
        buf_pck-rcvd.EndImpTime    = string( v-time, "HH:MM:SS" )
      .

      /* подтверждение на подтверждение -- возврат подтверждения */
      for each buf_pck-rcvd exclusive-lock
        where buf_pck-rcvd.db-num = p-db-src
          and buf_pck-rcvd.rcvd   = no
      on error  undo, return error substitute("&1. error buf_pck-rcvd &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      on endkey undo, return error substitute("&1. endkey buf_pck-rcvd")
      on stop   undo, return error substitute("&1. stop buf_pck-rcvd")
      :
        find first tt_pck-sent no-lock
          where tt_pck-sent.db-num   = g#db-num
            and tt_pck-sent.pack-num = buf_pck-rcvd.pack-num
          no-error .
        if not available tt_pck-sent then do:
          /* это значит, что в другой БД получили подтверждение о приняти здесь этого пакета */
          /* и эта запись больше в пакет ( для той БД ) передаваться не будет                */
          assign
            buf_pck-rcvd.rcvd = yes
          .
        end.
      end.

      run check-imp-rec in this-procedure
        ( input  "delete":U
        ,input  p-db-src
        ,input  p-pck-num
        ,input  ?
        ,output v-present
        ) no-error .
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка при удалении уникальных ключей строк пакета. &2", vss-workfile, return-value ) ).
        undo, return error.
      end.

      run db-attr-write in this-procedure
        ( input p-db-src
        ,input {&attr-need-gen-new-pack}
        ,input "yes":U
        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( "&1. Ошибка записи атрибута формирования нового пакета для БД &2"
                                      ,vss-workfile
                                      ,p-db-src
                                    )
                        ) .
        undo, return error.
      end.

    end. /* transaction_block_end */

    for each tt_pck-sent :
      delete tt_pck-sent.
    end.
    delete t-pck-conf.

    if not OK then do:
      run write-to-log ( "Пакет принят не полностью!.." + {&new-line}
                        + "Вероятно была ошибка ( передачи по модему," + {&new-line}
                        + "копирование с дискеты, ... )" + {&new-line}
                        + "Повторите прием пакета по модему, " + {&new-line}
                        + "замените дискету; либо обратитесь" + {&new-line}
                        + "к администратору системы."
                      ).
            /* переименовываем пакет, чтобы его можно было принять снова
                иначе батон "прием" в news.p не сработает */
      pck-name-bad = substr( p-file-pck-name, 1, r-index( p-file-pck-name, ".txt" )) + "bad".
      os-delete value( pck-name-bad ).
      if os-error <> 0 then do:
        run adm/os-err.p ( output err-mess ).
        run write-to-log( "Удаление файла: " + pck-name-bad + {&new-line} + err-mess ).
      end.
      os-rename value( p-file-pck-name ) value( pck-name-bad ).
      if os-error <> 0 then do:
        run adm/os-err.p ( output err-mess ).
        run write-to-log( "Переименование файла: " + p-file-pck-name
                          + "в файл: " + pck-name-bad + {&new-line}
                          + err-mess ).
      end.
      undo, return error.
    end.
    if mFrameView
    then 
       hide frame imp-pck.

  end.

end procedure. /* local-imp-pck */

procedure nws-imps :

  define input-output parameter p-counter  as integer   no-undo .
  define output       parameter p-rec-full as character no-undo .

  do
  on error  undo, return error substitute( "&1 (nws-imps). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (nws-imps). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (nws-imps). endkey", vss-workfile )
  :

    define variable v-imps-rec-name   as character no-undo .
    define variable v-rec-num         as integer   no-undo.
    define variable v-skip-rec        as logical   no-undo .

    assign
      v-skip-rec = false
    .

    block_imp-head-rec:
    repeat
    on error  undo, return error substitute("&1. error block_imp-head-rec. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on endkey undo, return error substitute("&1. endkey block_imp-head-rec")
    on stop   undo, return error substitute("&1. stop block_imp-head-rec")
    :
      if v-skip-rec = false then do:
        if p-counter = 0 then do:
          assign
            v-rec-cnt = v-rec-cnt + 1
          .
        end.
      end.
      else do:
        assign
          v-skip-rec = false
        .
      end.
      import stream imp-stream p-rec-full .
      assign
        v-imps-rec-name = trim( entry( 1, p-rec-full, {&delim-nws} ) )
      .
      if v-imps-rec-name begins "pck-null-rec":U then do:
        if p-counter > 0 then do:
          assign
            p-counter = p-counter + 1
          .
        end.
      end.
      else do:
        if v-imps-rec-name begins "pck-pause":U then do:
          assign
            v-skip-rec = true
          .
          message
            "Просили паузу? Получите..."  skip
            substitute( "&1", p-rec-full ) skip
            "После нажатия OK все продолжится." skip
            view-as alert-box.
        end.
        else do:
          if v-imps-rec-name begins "pck-log-write":U then do:
            assign
              v-skip-rec = true
            .
            run write-to-log( substitute( ">>> &1", p-rec-full ) ).
          end.
          else do:
            leave block_imp-head-rec .
          end.
        end.
      end.
    end.

    if v-imps-rec-name <> {&nwspck-end} then do:
      if p-counter = 0 then do:
        assign
          v-rec-num  = integer( entry( num-entries( p-rec-full, {&delim-nws} ), p-rec-full, {&delim-nws} ) )
        .
        if v-rec-cnt <> v-rec-num then do:
          undo, return error substitute( "&1. Ошибка обработки пакета: читается запись N &2, а должна быть N &3. Позиция в файле &4"
                                         ,vss-workfile
                                         ,v-rec-num
                                         ,v-rec-cnt
                                         ,seek(imp-stream)
                                       ).
        end.
      end.

      assign
        v-sub-rec-cnt = integer( entry( num-entries( p-rec-full, {&delim-nws} ) - 1, p-rec-full, {&delim-nws} ) )
      .
      if p-counter <> v-sub-rec-cnt then do:
        undo, return error substitute( "Ошибка пакета. Запись &1&2Принимается привязанная запись N &3, а должна быть N &4. Позиция в файле &5"
                                        ,v-rec-cnt
                                        ,{&new-line}
                                        ,v-sub-rec-cnt
                                        ,p-counter
                                        ,seek(imp-stream)
                                      ) .
      end.
      if mFrameView
      then  
      do with frame imp-pck
      :
        assign
          p-db-src :screen-value        = string( p-db-src, p-db-src :format)
          p-pck-num :screen-value       = string( p-pck-num, p-pck-num :format)
          p-file-pck-name :screen-value = string( p-file-pck-name, p-file-pck-name :format)
          v-rec-cnt :screen-value       = string( v-rec-cnt, v-rec-cnt :format)
          v-sub-rec-cnt :screen-value   = string( v-sub-rec-cnt, v-sub-rec-cnt :format)
        .
      end.
    end.

  end.

  return .

end procedure. /* nws-imps */

procedure nws-impl :

  define input  parameter p-tbl-name   as character no-undo .
  define input  parameter p-buf-handle as handle    no-undo .

  do
  on error  undo, return error substitute( "&1 (nws-impl). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (nws-impl). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (nws-impl). endkey", vss-workfile )
  :

    define variable v-fh-artic     as handle    no-undo .
    define variable v-fh-prod-type as handle    no-undo .
    define variable v-fh-prod-code as handle    no-undo .
    define variable v-fh-gds-code  as handle    no-undo .
    define variable v-fh-b-code    as handle    no-undo .

    define variable v-gds-code     as integer   no-undo .
    define variable v-b-code       as integer   no-undo .
    define variable v-old-b-code   as integer no-undo .

    run nws-impl-without-check in this-procedure
      ( input p-buf-handle
      ) no-error .
    if error-status :error then do:
      return error return-value .
    end.

    assign
      v-fh-artic    = p-buf-handle:buffer-field( 'artic':U )
      v-fh-gds-code = p-buf-handle:buffer-field( 'gds-code':U )
      v-fh-b-code   = p-buf-handle:buffer-field( 'b-code':U )
      no-error
    .

    if v-fh-artic <> ?
      and lookup( p-tbl-name, 'goods,c-goods':U) = 0
    then do:
      assign
        v-fh-prod-type = p-buf-handle:buffer-field( 'prod-type':U )
        v-fh-prod-code = p-buf-handle:buffer-field( 'prod-code':U )
        no-error
      .
      if v-fh-prod-type = ? then do:
        return error substitute( "(nws-impl) &1&2Поле &3 не найдено в таблице &4, а поле artic есть!"
                                  ,vss-workfile
                                  ,{&new-line}
                                  ,'prod-type':U
                                  ,p-buf-handle:name
                                ).
      end.
      if v-fh-prod-code = ? then do:
        return error substitute( "(nws-impl) &1&2Поле &3 не найдено в таблице &4, а поле artic есть!"
                                  ,vss-workfile
                                  ,{&new-line}
                                  ,'prod-code':U
                                  ,p-buf-handle:name
                                ).
      end.
      run check-avail-artic in this-procedure
        ( input v-fh-artic:buffer-value
         ,input v-fh-prod-type:buffer-value
         ,input integer( v-fh-prod-code:buffer-value )
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
    end.
    if v-fh-gds-code <> ?
/*      and lookup( p-tbl-name, '':U) = 0 */
    then do:
      assign
        v-gds-code = integer( v-fh-gds-code:buffer-value )
      .
      run check-avail-gds-code in this-procedure
        ( input-output v-gds-code
        ) no-error.
      if error-status :error then do:
        return error return-value .
      end.
      assign
        v-fh-gds-code:buffer-value = v-gds-code
      .
    end.
    if v-fh-b-code <> ?
      and lookup( p-tbl-name, 'bar-code,c-bar-code,c-gds-hist,c-prod-bc,c-chk-gds,chk-gds,c-sert':U) = 0
    then do:
      assign
        v-old-b-code = integer( v-fh-b-code:buffer-value )
        v-b-code = integer( v-fh-b-code:buffer-value )
      .
      define variable v-ok-b-code as logical no-undo .
      v-ok-b-code = no.
      run check-avail-b-code in this-procedure
        ( input-output v-b-code
        ) no-error.
      if error-status :error then do:
        case p-tbl-name:
          when {&table_chk-gds} then do:
          if v-old-b-code = 0
          and p-buf-handle:buffer-field("out-code"):buffer-value <> ? then do:
            /* todo доп проверка что это инвентр*/
              v-ok-b-code = yes.
          end.
          end.
          when {&table_doc-prts}
          or when {&table_c-doc-prts}
          then do:
            if v-fh-b-code:buffer-value  < 0
            /*это резервирование по партия юв издели с типос ед изм 2ед*/
            then do:
              v-ok-b-code = yes.
            end.
          end.
        end case.
        if v-ok-b-code = no then do:
          return error return-value .
        end.
      end. /*if error-status :error then do:*/
      assign
        v-fh-b-code:buffer-value = v-b-code
      .
    end.
  end.

  return .

end procedure. /* nws-impl */

procedure nws-impl-without-check :

  define input  parameter p-buf-handle as handle    no-undo .

  do
  on error  undo, return error substitute( "&1 (nws-impl-without-check). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (nws-impl-without-check). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (nws-impl-without-check). endkey", vss-workfile )
  :
    define variable v-imp-str    as character extent 1000 no-undo .
    define variable v-num-fields as integer   no-undo .
    define variable v-ind        as integer   no-undo .
    define variable v-fld-name   as character no-undo .
    define variable v-fld-value  as character no-undo .
    define variable v-fh         as handle    no-undo .

    if not p-buf-handle:available then do:
      return error substitute( "(nws-impl-without-check) &1&2Buffer таблицы &3 еще не создан!"
                                ,vss-workfile
                                ,{&new-line}
                                ,p-buf-handle:name
                              ).
    end.

    import stream imp-stream v-imp-str.

    if v-imp-str[1] <> "<num-fields>" then do:
      return error substitute( "(nws-impl-without-check) &1&2Неверный формат строки для импорта записи&2Строка должна начинаться с <num-fields> а начинается с &3!"
                                ,vss-workfile
                                ,{&new-line}
                                ,v-imp-str[1]
                              ).
    end.
    assign
      v-fld-name   = "":U
      v-fld-value  = "":U
      v-num-fields = integer( v-imp-str[2] )
    .
    block_read:
    do v-ind = 3 to v-num-fields * 2 + 2 by 2
    on error undo, return error
    :
      assign
        v-fld-name  = v-imp-str[v-ind]
      .
      if v-fld-name <> "":U then do:
        assign
          v-fld-name  = substring( v-fld-name, 2, length(v-fld-name) - 2)
          v-fld-value = v-imp-str[v-ind + 1]
        .
        assign
          v-fh = p-buf-handle:buffer-field( v-fld-name ) no-error
        .
        if (error-status :error
          or v-fh = ?)
          /* and можно убрать, когда во всех БД будет обновлена структура БД до 36 версии и выше */
          and p-buf-handle:name <> "locb-marking" 
        then do:
          return error substitute( "(nws-impl-without-check) &1&2Поле &3 не найдено в таблице &4&2&5"
                                    ,vss-workfile
                                    ,{&new-line}
                                    ,v-fld-name
                                    ,p-buf-handle:name
                                    ,error-status :get-message ( 1 )
                                  ).
        end.
        if v-fh <> ? then do:
          v-fh:buffer-value = v-fld-value.
        end.
      end.
      else do:
        leave block_read.
      end.
    end.
  end.

  return .

end procedure. /* nws-impl-without-check */

procedure check-imp-rec :
  define input  parameter p-action   as character no-undo .
  define input  parameter p-db-num   as integer   no-undo .
  define input  parameter p-pack-num as integer   no-undo .
  define input  parameter p-uniq-key as character no-undo .
  define output parameter p-present  as logical   no-undo .
  do
  on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
  :
    define buffer buf_pck-keys for ub.pck-keys .

    case p-action :
      when "create":U then do:
        if not transaction then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Вызов процедуры check-imp-rec( create ) возможен только в одной транзакции с приемом записи!" )
            view-as alert-box error
          .
          return error .
        end.
        find first buf_pck-keys
          where buf_pck-keys.db-num   = p-db-num
            and buf_pck-keys.pack-num = p-pack-num
            and buf_pck-keys.uniq-key = p-uniq-key
          no-error .
        if available buf_pck-keys then do:
          assign
            p-present = true
          .
        end.
        else do:
          do transaction
          on error undo, return error
          :
            create buf_pck-keys .
            assign
              buf_pck-keys.db-num   = p-db-num
              buf_pck-keys.pack-num = p-pack-num
              buf_pck-keys.uniq-key = p-uniq-key
              p-present = false
            .
          end.
        end.
      end.
      when "delete":U then do:
        for each buf_pck-keys exclusive-lock
          where buf_pck-keys.db-num   = p-db-num
            and buf_pck-keys.pack-num = p-pack-num
        on error  undo, return error substitute( "&1 (check-imp-rec). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        on stop   undo, return error substitute( "&1 (check-imp-rec). stop", vss-workfile )
        on endkey undo, return error substitute( "&1 (check-imp-rec). endkey", vss-workfile )
        :
          delete buf_pck-keys.
        end.
      end.
    end case.
  end.
  return.
end procedure. /* check-imp-rec */

procedure proc-load-standart :

  define input parameter p-tbl-name   as character no-undo.
  define input parameter p-uniq-gate-rec as character no-undo .
  define input parameter p-bh-handle  as handle    no-undo.
  define input parameter p-imp-handle as handle    no-undo.
  define input parameter l-counter    as integer   no-undo.
  define output parameter p-curr-rowid as rowid    no-undo.

  do
  on error  undo, return error substitute( "&1 (proc-load-standart). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (proc-load-standart). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (proc-load-standart). endkey", vss-workfile )
  :
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh_tbl-name     as handle    no-undo .

    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh_tt           as handle    no-undo .
    define variable fh_tt           as handle    no-undo .
    define variable v-ok            as logical   no-undo .

    define variable v-rowid         as rowid     no-undo .
    define variable v-tbl-name      as character no-undo .

    define variable compare-log     as logical   no-undo.
    define variable v_dataseth      as handle    no-undo.
    define variable v-xmlh          as handle    no-undo.
    define variable v-table-ready   as logical   no-undo.

    define buffer buf_temp-xml-tables for temp-xml-tables.
    v-xmlh = buffer buf_temp-xml-tables:handle.
&scop gate-clear if valid-handle(v_dataseth) then do: ~
                   run gate-clear in this-procedure ( input v_dataseth ~
                                                    , input buffer buf_temp-xml-tables:handle). ~
                  end


    if l-counter <> 0 then do:
      return error substitute( "&1 (proc-load-standart). Ошибка обработки записи &2&3Есть привязанные записи, а обработка идет для одной", vss-workfile, p-tbl-name, {&new-line} ).
    end.
    if p-bh-handle <> ?
    and (not valid-handle(p-bh-handle)
         or p-bh-handle:type <> "buffer") then do:
      return error substitute( "&1 (proc-load-standart). Ошибка обработки записи &2&3Передан невалидный handle или hanlde не типа BUFFER", vss-workfile, p-tbl-name, {&new-line} ).
    end.
    assign
      v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .

    /* создаем временную таблицу */
    create temp-table tth.

    assign
      tt-name = "wt-" + p-tbl-name
      tth:undo = no
      v-ok = false
    .
    if p-bh-handle = ? then do:
      if p-uniq-gate-rec = '':U then do:
        assign
          v-ok = tth:create-like( v-full-tbl-name ) no-error
        .
      end.
      else do:
        define variable v-longchar as longchar no-undo .
        v-longchar = ?.
        run get-gate-by-rec in this-procedure ( input p-uniq-gate-rec
                                                ,output v_dataseth
                                                ,input-output v-xmlh
                                                ,input-output v-longchar
                                                ) no-error.
        if error-status:error then do:
           return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (3)", vss-workfile, tt-name ) .
        end.
        find first buf_temp-xml-tables where
                  buf_temp-xml-tables.uniq-gate-rec = p-uniq-gate-rec
              and buf_temp-xml-tables.tbl-name = p-tbl-name no-error.
        if not available buf_temp-xml-tables then do:
           {&gate-clear}.
           return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (4)", vss-workfile, tt-name ) .
        end.
        /*таблицу create уже не надо - у нас уже есть!!!*/
        bh_tt = buf_temp-xml-tables.tbl-handle_.
        v-ok = yes.
        v-table-ready = yes.
      end.
    end.
    else do:
      assign
        v-ok = tth:create-like( p-bh-handle ) no-error
      .
    end.
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (1)", vss-workfile, tt-name ) .
    end.
    if not v-table-ready then do:
      assign
        v-ok = false
      .
      assign
        v-ok = tth:temp-table-prepare( tt-name ) no-error
      .
      if v-ok <> true then do:
      {&gate-clear}.
        return error substitute( "&1 (proc-load-standart). Ошибка при создании временной таблицы &2 (2)", vss-workfile, tt-name ) .
      end.

      assign
        bh_tt = tth:default-buffer-handle
      .

    end.
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      {&gate-clear}.
      return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-workfile ).
    end.

    /* считаем во временную таблицу запись из пакета */
    run nws-impl in p-imp-handle
      ( input p-tbl-name
       ,input bh_tt
      ) no-error.
    if error-status :error then do:
      {&gate-clear}.
      return error return-value .
    end.

   /* проверим нет ли такой записи в БД */

    if p-bh-handle = ? then do:
      run gen-row-keyr in this-procedure
        ( input p-tbl-name
         ,input bh_tt
         ,input "ub":U
         ,input ?
         ,input exclusive-lock
         ,output v-rowid
         ,output v-tbl-name
        ) no-error .
      if error-status :error then do:
        {&gate-clear}.
        return error substitute( "&1 (proc-load-standart). Ошибка при определении в БД rowid для записи &2.&3&4", vss-workfile, p-tbl-name, {&new-line}, return-value ).
      end.
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      run gen-row-keyr in this-procedure
        ( input p-tbl-name
         ,input bh_tt
         ,input ?
         ,input p-bh-handle
         ,input ?
         ,output v-rowid
         ,output v-tbl-name
        ) no-error .
      if error-status :error then do:
        {&gate-clear}.
        return error substitute( "&1 (proc-load-standart). Ошибка при определении в Temp-table rowid записи для ключа &2.&3&4", vss-workfile, p-tbl-name, {&new-line}, return-value ).
      end.
      create buffer bh_tbl-name for table p-bh-handle:table-handle .
    end.

    bh_tbl-name:find-by-rowid( v-rowid, exclusive-lock ) no-error .

    if not bh_tbl-name:available then do:
      assign
        v-ok = false
      .
      assign
        v-ok = bh_tbl-name:buffer-create no-error
      .
      if v-ok <> true then do:
        {&gate-clear}.
        return error substitute( "&1 (proc-load-standart). Ошибка при создании буфера временной таблицы.", vss-workfile, p-tbl-name ).
      end.
      assign
        compare-log = false
      .
    end.
    else do:
      assign
        compare-log = bh_tbl-name:buffer-compare( bh_tt, 'case-sensitive':U )
      .
    end.
    if compare-log = false then do:
      assign
        v-ok = false
      .
      assign
        v-ok = bh_tbl-name:buffer-copy( bh_tt ) no-error
      .
      if v-ok <> true then do:
        {&gate-clear}.
        return error substitute( "&1 (proc-load-standart). BUFFER-COPY не прошел для таблицы &2", vss-workfile, p-tbl-name ).
      end.
    end.

    assign
      v-ok = false
      p-curr-rowid = bh_tbl-name:rowid
    .

    assign
      v-ok = bh_tbl-name:buffer-release() no-error
    .
    if v-ok <> true then do:
      {&gate-clear}.
      return error substitute( "&1 (proc-load-standart). buffer-release не прошел для таблицы &2", vss-workfile, p-tbl-name ).
    end.

    assign
      v-ok = false
    .
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (proc-load-standart). Ошибка при очистке временной таблицы &2", vss-workfile, tt-name ) .
    end.

    delete object bh_tbl-name .
    delete object tth .
    {&gate-clear}.

    assign
      fh_tbl-name  = ?
      fh_tt        = ?
      bh_tt        = ?
      v_dataseth   = ?
      v-xmlh       = ?
    .

  end.

  return .

end procedure. /* proc-load-standart */

procedure skip-rec :

  do
  on error  undo, return error substitute( "&1 (skip-rec). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (skip-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (skip-rec). endkey", vss-workfile )
  :
  
    define variable v-skip-str    as character extent 1000 no-undo .

    import stream imp-stream v-skip-str.  
  
  end.
  
  return .
   
end procedure. /* skip-rec*/