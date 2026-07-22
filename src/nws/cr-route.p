block-level on error undo, throw.
/*

$Revision: f63859adafce, 2420, rls $
$Author: ASMorozov $
$Date: Ср июн 10 21:13:46 2020 +0300 $
$Workfile: cr-route.p $
$Archive: nws/cr-route.p $

Создание записи маршрутизации (route)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/
define input parameter p-act-name   as character no-undo .
define input parameter p-tbl-name   as character no-undo .
define input parameter p-tbl-handle as handle    no-undo.
define input parameter p-send-list  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: f63859adafce, 2420, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:46 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cr-route.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cr-route.p $":U .
define variable vss-description as character no-undo init "Создание записи маршрутизации (route)".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-act-name,p-tbl-name,p-tbl-handle,p-send-list)" }
{ cmp/trg-def.i  }
{ nws/lib-nws.i  }
{ nws/call-nws.i }
{ str/marks.i    }
{ gbl/key-rec.i  }
{ nws/cr-rtd.i   }
{ nws/cr-route.i }
{ gbl/cur-time.i }

block_cre-route:
do
on error  undo block_cre-route, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo block_cre-route, return error substitute( "&1. stop", vss-workfile )
on endkey undo block_cre-route, return error substitute( "&1. endkey", vss-workfile )
:
  define variable v-tbl-row      as rowid               no-undo.
  define variable v-dmp-ord      like ub.route.dump-ord no-undo .
  define variable v-rc-ord       as integer             no-undo .
  define variable v-ind          as integer             no-undo .
  define variable v-loc-key-rec  as character           no-undo .
  define variable v-send-checks  as logical             no-undo .
  define variable v-param-checks as logical             no-undo .
  define variable v-bush-rec     as logical             no-undo .
  define variable v-cre-time     as integer             no-undo .
  define variable v-cre-date     as date                no-undo .
  define variable v-cre-user     as character           no-undo .
  define variable v-act-name     as character           no-undo.
  define variable v-esr-act-name as character           no-undo.

  define variable v-send-list    as character no-undo .
  define variable v-rt-count     as integer   no-undo .

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for ub.db .

/*{ gbl/curdbnum.i*/
/*    v-cur-db-num#{&vssseq}*/
/*}*/
  if p-act-name = {&send-tbl}
  or p-act-name = {&send-cmd}
  then do:      /* При передаче новостей здесь передаётся только одно значение действия */
    assign
        v-act-name = p-act-name
    .
  end.
  else do:
    if num-entries( p-act-name ) < 2
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Передано неверное действие OXML"   skip
        "Действие"         p-act-name        skip
        "Таблица"          p-tbl-name        skip
        "Список рассылки"  p-send-list       skip
        view-as alert-box error .
      undo block_cre-route, return error return-value .
    end.
    else do:
        assign
            v-act-name      = entry( 1, p-act-name )
            v-esr-act-name  = entry( 2, p-act-name )
        .
        if v-esr-act-name <> {&nwsdochs_action_update}
        and v-esr-act-name <> {&nwsdochs_action_delete}
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка задания входных параметров" skip
                "Передано неверное действие OXML"   skip
                "Действие"         p-act-name        skip
                "Таблица"          p-tbl-name        skip
                "Список рассылки"  p-send-list       skip
                view-as alert-box error .
            undo block_cre-route, return error return-value .
        end.
    end.
  end.
  if v-act-name = {&send-tbl}
    or v-act-name = {&send-tbl-oxml}
  then do:
    if not p-tbl-handle:available then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Передана ссылка на не доступный буффер" skip
        "Действие"         p-act-name        skip
        "Таблица"          p-tbl-name        skip
        "Список рассылки"  p-send-list       skip
        view-as alert-box error .
      undo block_cre-route, return error return-value .
    end.
    else do:
      assign
        v-tbl-row       = p-tbl-handle :rowid
      .
    end.
  end.
  if v-act-name <> {&send-tbl}
    and v-act-name <> {&send-cmd}
    and v-act-name <> {&send-tbl-oxml}
/*    and v-act-name <> {&send-cmd-oxml}*/
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра Действие" skip
      "Действие"         p-act-name        skip
      "Таблица"          p-tbl-name        skip
      "Код записи"       string(v-tbl-row) skip
      "Список рассылки"  p-send-list       skip
      view-as alert-box error .
    undo block_cre-route, return error return-value .
  end.

  if p-tbl-name = ?
  or p-tbl-name = "":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не задан параметр таблица" skip
      "Действие"         p-act-name        skip
      "Таблица"          p-tbl-name        skip
      "Код записи"       string(v-tbl-row) skip
      "Список рассылки"  p-send-list       skip
      view-as alert-box error .
    undo block_cre-route, return error return-value .
  end.

  if trim( p-send-list ) = "":U
    or p-send-list = ?
  then do:
    if v-act-name = {&send-tbl-oxml}
      or v-act-name = {&send-cmd-oxml}
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не задан список рассылки" skip
        "Действие"         p-act-name        skip
        "Таблица"          p-tbl-name        skip
        "Код записи"       string(v-tbl-row) skip
        "Список рассылки"  p-send-list       skip
        view-as alert-box error .
      undo block_cre-route, return error return-value .
    end.
    else do:
      assign
        v-send-list = "":U
      .
      find first buf_sys-ctrl no-lock .
      if buf_sys-ctrl.db-num = 0 then do:
        for each buf_db no-lock
          where buf_db.db-num > 0
            and buf_db.db-num <> g#news-source-db
      on error undo block_cre-route, return error
        :
          assign
            v-send-list = v-send-list + {&delim-nws} + string( buf_db.db-num )
          .
        end.
        assign
          v-send-list = left-trim( v-send-list, {&delim-nws} )
        .
      end.
      else do:
        assign
          v-send-list = "0":U
        .
      end.
    end.
  end.
  else do:
    assign
      v-send-list = p-send-list
    .
  end.

  /* проверка на передачу чеков */
  if v-act-name = {&send-tbl}
    or v-act-name = {&send-cmd}
  then do:
    assign
      v-send-checks = false
    .
    if g#db-num = 0 then do:
      do v-ind = 1 to num-entries( v-send-list, {&delim-nws} )
      on error  undo block_cre-route, return error substitute( "&1. (send-checks) &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      on stop   undo block_cre-route, return error substitute( "&1. (send-checks) stop", vss-workfile )
      on endkey undo block_cre-route, return error substitute( "&1. (send-checks) endkey", vss-workfile )
      :
        find buf_db no-lock
          where buf_db.db-num = integer( entry( v-ind, v-send-list, {&delim-nws} ) )
        .
        if buf_db.send-check = true then do:
          assign
            v-send-checks = buf_db.send-check
          .
        end.
      end.
    end.
    else do:
      find buf_db no-lock
        where buf_db.db-num = g#db-num
      .
      assign
        v-send-checks = buf_db.send-check
      .
    end.
  end.
  else do:
    assign
      v-send-checks = true
    .
  end.


  assign
    v-dmp-ord = next-value( s-news-dord, {&db-name_schema} )
  .
  case p-act-name :
    when {&send-tbl}
    or when substitute( "&1,&2", {&send-tbl-oxml}, {&nwsdochs_action_update} )
    then do:
      assign
        v-rc-ord  = -1
      .

      RUN gen-key-rec in this-procedure
        ( input p-tbl-name
         ,input p-tbl-handle
         ,output v-loc-key-rec
        ) no-error.
      if error-status :error then do:
        undo  block_cre-route, return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3. Код таблицы &4.", vss-workfile, return-value, p-tbl-name, string(v-tbl-row) ).
      end.

      if v-loc-key-rec = ?
        or v-loc-key-rec = ""
      then do:
        undo  block_cre-route, return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2. Код таблицы &3.", vss-workfile, p-tbl-name, string(v-tbl-row) ).
      end.

      case p-tbl-name:
        when {&table_c-trn-doc}
        or when {&table_add-doc}
        or when {&table_price-doc}
        or when {&table_c-price-doc}
        or when {&table_contract}
        or when {&table_contract-specif}
        or when {&table_c-contract}
        or when {&table_fbr-doc}
        or when {&table_fbr-pln}
        or when {&table_recipe}
        or when {&table_c-fbr-doc}
        or when {&table_c-recipe}
        or when {&table_c-fbr-pln}
        or when {&table_rvs-doc}
        or when {&table_c-rvs-doc}
        or when {&table_icnt-doc}
        or when {&table_ord-doc}
        or when {&table_ord-doc-rcv}
        or when {&table_ord-cons}
        or when {&table_goods}
        or when {&table_shift-obj}
        or when {&table_c-shift-obj}
        or when {&table_fin-ob}
        or when {&table_c-fin-ob}
        or when {&table_fin-ob-before}
        or when {&table_fin-doc}
        or when {&table_c-fin-doc}
        or when {&table_dis-rule}
        or when {&table_dis-time-rule}
        or when {&table_abc-analysis}
        or when {&table_abcxyz-analysis}
        or when {&table_xyz-analysis}
        or when {&table_rang-abc-def}
        or when {&table_rang-xyz-def}
        or when {&table_doc-abc-def}
        or when {&table_doc-xyz-def}
        or when {&table_fin-statement}
        or when {&table_c-fin-statement}
        or when {&table_schet-fact-doc}
        or when {&table_c-schet-fact-doc}
        or when {&table_factur-connect}
        or when {&table_global-state}
        or when {&table_sum-group}
        or when {&table_qnty-group}
        or when {&table_turnover-group}
        or when {&table_buyer-group}
        or when {&table_buyer-in-buyer-group}
        or when {&table_grp-obj-price}
        or when {&table_turnover-buyer-main}
        or when {&table_price-list-type}
        or when {&table_price-doc-forming}
        or when {&table_c-price-list-type}
        or when {&table_c-price-doc-forming}
        or when {&table_stop-list}
        or when {&table_esys-route}
        or when {&table_layout}
        or when {&table_utd}
        then do:
          /* маршрутизация кустовой записи без проверки необходимости отправки чеков */
          assign
            v-bush-rec     = true
            v-param-checks = false
          .
        end.
        when {&table_trn-doc}
        or when {&table_wth-doc}
        or when {&table_c-wth-doc}
        or when {&table_inkas}
        or when {&table_c-inkas}
        or when {&table_c-chk-doc}
        then do:
          /* маршрутизация кустовой записи с проверкой необходимости отправки чеков */
          assign
            v-bush-rec     = true
            v-param-checks = true
          .
        end.
        otherwise do:
          assign
            v-bush-rec     = false
            v-param-checks = false
          .
        end.
      end case.

      run cre-route-dump in this-procedure
        ( input v-act-name
         ,input p-tbl-name
         ,input p-tbl-handle
         ,input v-dmp-ord
         ,input-output v-rc-ord
        ).

      if v-bush-rec = true then do:
        if v-param-checks = true then do:
          run value("cre-dump-":U + p-tbl-name) in this-procedure
            ( input v-act-name
             ,input v-tbl-row
             ,input v-dmp-ord
             ,input-output v-rc-ord
             ,input v-send-checks
            ).
        end.
        else do:
          run value("cre-dump-":U + p-tbl-name) in this-procedure
            ( input v-act-name
             ,input v-tbl-row
             ,input v-dmp-ord
             ,input-output v-rc-ord
            ).
        end.
      end.
    end.
    when substitute( "&1,&2", {&send-tbl-oxml}, {&nwsdochs_action_delete} )
    then do:
      assign
        v-rc-ord  = -1
      .
      RUN gen-key-rec in this-procedure
        ( input p-tbl-name
         ,input p-tbl-handle
         ,output v-loc-key-rec
        ) no-error.
      if error-status :error then do:
        undo  block_cre-route, return error substitute( "&1. Ошибка при генерации уникального ключа. &2. Имя таблицы &3. Код таблицы &4.", vss-workfile, return-value, p-tbl-name, string(v-tbl-row) ).
      end.

      if v-loc-key-rec = ?
        or v-loc-key-rec = ""
      then do:
        undo  block_cre-route, return error substitute( "&1. Уникальный ключ имеет неопределенное значение. Имя таблицы &2. Код таблицы &3.", vss-workfile, p-tbl-name, string(v-tbl-row) ).
      end.
      run cre-route-dump in this-procedure
         ( input v-act-name
          ,input p-tbl-name
          ,input p-tbl-handle
          ,input v-dmp-ord
          ,input-output v-rc-ord
         ).
    end.
    when {&send-cmd}
    then do:
      assign
        v-rc-ord  = 0
        v-loc-key-rec = "":U
      .
    end.
  end case.

  run cur-time in this-procedure
    ( output v-cre-date
     ,output v-cre-time
    ) no-error.
  if error-status :error then do:
    undo block_cre-route, return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
  end.

  if g#news then do:
    assign
      v-cre-user = substitute( "News (&1)":U, g#userid )
    .
    if g#news-source-db > 0 then do:
      assign
        v-cre-user = substitute( "&1 from BD &2":U, v-cre-user, g#news-source-db )
      .
    end.
  end.
  else do:
    assign
      v-cre-user = g#userid
    .
  end.
  if v-act-name = {&send-tbl}
    or v-act-name = {&send-cmd}
  then do:
    assign
      v-rt-count = 0
    .
    do v-ind = 1 to num-entries( v-send-list, {&delim-nws} )
    on error  undo block_cre-route, return error substitute( "&1. (cr-rt) &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo block_cre-route, return error substitute( "&1. (cr-rt) stop", vss-workfile )
    on endkey undo block_cre-route, return error substitute( "&1. (cr-rt) endkey", vss-workfile )
    :
      { nws/cr-rt.i
        &name-rec=p-tbl-name
        &db-num=integer(entry(v-ind,v-send-list,{&delim-nws}))
        &dump-ord=v-dmp-ord
        &uniq-key-rec=v-loc-key-rec
        &num-dump=v-rc-ord
        &CreDate=v-cre-date
        &CreTimeInt=v-cre-time
        &CreUserName=v-cre-user
        &cre-count=v-rt-count
      }
    end.
    if v-rt-count = 0 then do:
      do v-ind = 1 to num-entries( v-send-list, {&delim-nws} )
      on error  undo block_cre-route, return error substitute( "&1. (check-db-list) &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      on stop   undo block_cre-route, return error substitute( "&1. (check-db-list) stop", vss-workfile )
      on endkey undo block_cre-route, return error substitute( "&1. (check-db-list) endkey", vss-workfile )
      :
        find buf_db no-lock
          where buf_db.db-num = integer( entry( v-ind, v-send-list, {&delim-nws} ) )
        .
        if buf_db.db-key <> ?
          and buf_db.db-key <> "":U
        then do:
          undo block_cre-route, return error substitute( "&1. Есть список БД для отправки, но ни одна запись не маршрутизировалась!!!", vss-workfile ) .
        end.
      end.

      /* отправлять некуда, все необходимые БД отключены */
      undo block_cre-route, return .
    end.
  end.
  if v-act-name = {&send-tbl-oxml} then do:
    do v-ind = 1 to num-entries( v-send-list, {&delim-nws} )
    on error  undo block_cre-route, return error substitute( "&1. (cr-rto) &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo block_cre-route, return error substitute( "&1. (cr-rto) stop", vss-workfile )
    on endkey undo block_cre-route, return error substitute( "&1. (cr-rto) endkey", vss-workfile )
    :
      { nws/cr-rto.i
        &esr-name-rec=p-tbl-name
        &esr-db-num=g#db-num
        &esr-cr-db-num=g#db-num
        &esr-esys-id=integer(entry(v-ind,v-send-list,{&delim-nws}))
        &esr-dump-ord=v-dmp-ord
        &esr-uniq-key-rec=v-loc-key-rec
        &esr-uniq-gate-rec="''"
        &esr-num-dump=v-rc-ord
        &esr-CreDate=v-cre-date
        &esr-CreTimeInt=v-cre-time
        &esr-CreUserName=v-cre-user
        &esr-action=v-esr-act-name
        &esr-oper="''"
      }
    end.
  end.      /* if v-act-name = {&send-tbl-oxml} */

end. /* do on error... */