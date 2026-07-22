block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подготовка пакета(ов) OpenXML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/17/08
Author: Bakhtadze Natalya
Creation date: 02/17/08

*/

define input  parameter p-esys-id      like ub.ext-system.esys-id no-undo .
define input  parameter p-db-num       like ub.ext-system.db-num no-undo .
define output parameter p-err-gen-pack as   integer      no-undo . /* 0 - нет ошибок */
define output parameter p-cre-all-pck  as   logical      no-undo . /* true - созданы все возможные пакеты */


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Подготовка пакета(ов) OpenXML".
{ cmp/vssrevis.i "substitute('&1':u,p-db-num)" }

{ cmp/trg-def.i  }
{ bge/oxml-def.i  }
{ bge/esysattr.i  }
{ gbl/findlock.i }
{ bge/esallatr.i  }

  define variable v-pack-num   as integer   no-undo .
  define variable v-pack-name  as character no-undo .
  define variable v-source-dir as character no-undo .
  define variable v-target-dir as character no-undo .
  define variable v-temp-dir   as character no-undo .
  define variable v-log-file-name as character no-undo .
  define variable v-list-file-name as character no-undo .

  define variable route-cnt       as integer no-undo .
  define variable rec-cnt         as integer no-undo .
  define variable qnty-of-cur-rec as integer no-undo .
  define variable v-max-pack-size as integer no-undo .

  define variable v-today        as date    no-undo .
  define variable v-time         as integer no-undo .
  define variable v-last-tbl-ord like ub.route.tbl-ord no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-custom-pack-flag as logical   no-undo .

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_ext-system   for ub.ext-system.
  define buffer buf_esys-route    for ub.esys-route.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent .
  define buffer buf_esys-all-attr for ub.esys-all-attr.

  define variable esys-attr-value  as character no-undo .
/*  define variable esys-attr-type   as character no-undo . */
  define variable esys-attr-exist  as logical   no-undo .

  /* упреждающее чтение аттрибутов для подстановки в цикле */
  define variable db-esys-attr-exist as logical   no-undo .
  define variable db-esys-attr-value as character no-undo .
  define variable db-esys-attr-type  as character no-undo .

  define variable v-gen-new-xpack as logical   no-undo .

  define variable v-fst-pck      as integer   no-undo .
  define variable v-success      as logical   no-undo .

  define variable v-sys-key  as character no-undo . /* для чтения параметра конфигурации */

  define frame inf
    p-esys-id   label "для ВС" format ">>>>>>>>9"
    v-pack-num  label "Пакет N" format ">>>>>>>>9"
    route-cnt   label "Основных записей"
    rec-cnt     label "Привязанных"
    with view-as dialog-box side-labels 1 columns three-d title "** Формирование пакета".
  define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.      
  mFramHandle = frame inf:handle.

  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameoxmError"). 
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameoxmError"). 
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

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
    v-gen-new-xpack = false
    p-cre-all-pck  = true
  .

  { gbl/currsysk.i
    v-sys-key
    no-error
  }

  find first buf_ext-system no-lock where
          buf_Ext-system.esys-id = p-esys-id
      and buf_Ext-system.db-num = p-db-num.
  v-success = no.
  run bge/lockesys.p (
      input buf_ext-system.esys-id
    ,input buf_ext-system.db-num
    ,buffer buf_ext-system
    ,output v-success) no-error.
  if error-status:error
  or not v-success
  then do:
    run write-to-log in this-procedure ( substitute( "&1. &2", vss-workfile, return-value ) ).
    return .
  end.
  if buf_ext-system.esys-status = integer( {&openxml-status-new} )
  then do:
      run write-to-log in this-procedure  (

           input substitute( "Подготовка таблиц выгрузки внешней системы '&1'...", buf_ext-system.esys-name )
      ).
      run initial-export in this-procedure ( input buf_ext-system.esys-id
                                            ,input buf_Ext-system.db-num
                                            ,input buf_ext-system.esys-name) no-error.
      if error-status :error then do:
        run write-to-log (
             input substitute( "Ошибка при первоначальной выгрузке внешней системы '&1'...", buf_ext-system.esys-name )
        ).
        undo, return ''.
      end.
  end.        /* if buf_ext-system.esys-status = {&openxml-status-new} */

  find last buf_esys-route no-lock
    where buf_esys-route.esys-id = p-esys-id
      and buf_esys-route.db-num = p-db-num
      and buf_esys-route.esr-last-pack = -1
    no-error
  .
  v-last-tbl-ord = if available buf_esys-route then buf_esys-route.esr-tbl-ord else 0 .

  if mFrameView
  then do:
     view frame inf.
     do with frame inf
     :
        assign
        p-esys-id :screen-value   = string( p-esys-id, p-esys-id :format)
     .
     end.
  end.
  
      run ext-system-attr-exist (
                          input p-esys-id
                          ,input p-db-num
                          ,input {&attr-need-gen-new-xpack}
                          ,output db-esys-attr-exist
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute("&1. Ошибка при определении наличия атрибута формирования нового пакета для ВС &2"
                                    ,vss-workfile
                                    ,p-esys-id
                                    )
                        ) .
        undo, return error.
      end.
      run ext-system-attr-value (
                          input p-esys-id
                          ,input p-db-num
                          ,input {&attr-need-gen-new-xpack}
                          ,output db-esys-attr-value
                          ,output db-esys-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute("&1. Ошибка при чтении атрибута формирования нового пакета для ВС &2"
                                    ,vss-workfile
                                    ,p-esys-id
                                    )
                        ) .
        undo, return error.
      end.
  
  gen-pack:
  do while p-err-gen-pack = 0
  on error undo, return error
  :

    find first buf_esys-route share-lock
      where buf_esys-route.esys-id = p-esys-id
        and buf_esys-route.db-num = p-db-num
        and buf_esys-route.esr-last-pack = -1
      no-wait
      no-error
    .
    if available buf_esys-route
    and (buf_esys-route.esr-action = {&nwsdochs_action_command-bush}
    or  buf_esys-route.esr-action = {&nwsdochs_action_command-pbush})
    then do:
      /*структура должнв выгружаться целиком*/
      esys-attr-value = "yes":U.
    end.
    else do:
      esys-attr-exist = db-esys-attr-exist .
      esys-attr-value = db-esys-attr-value .
    end.
    v-custom-pack-name = ''.
    if ( available buf_esys-route
         and buf_esys-route.esr-tbl-ord <= v-last-tbl-ord
       )
      or (esys-attr-exist = false and available buf_esys-route)
      or esys-attr-value = "yes":U
    then do:
      assign
        v-pack-num     = -1
        v-gen-new-xpack = true
      .
      if buf_ext-system.delivery-method = integer({&esys-dm-nnold})
      or buf_ext-system.delivery-method = integer({&esys-dm-oracle-retail})
      or buf_ext-system.delivery-method = integer({&esys-dm-exite-edi})
	  or buf_ext-system.whole-send-news = integer({&esys-dm-contour-edi})
      then do:
        find first buf_esys-all-attr share-lock where
                buf_esys-all-attr.attr-code = {&attr-route-custom-pack-name}
            and buf_esys-all-attr.table-name = {&table_esys-route}
            and buf_esys-all-attr.key1 = buf_esys-route.esr-dump-ord
            and buf_esys-all-attr.key2 = buf_esys-route.esys-id
            and buf_esys-all-attr.key5 = buf_esys-route.db-num
            /*and buf_esys-all-attr.key6 = g#db-num*/ no-error.
        if available buf_esys-all-attr then do:
          v-custom-pack-name = buf_esys-all-attr.attr-value.
        end.
      end.

      run ext-system-attr-write (
                         input p-esys-id
                        ,input p-db-num
                        ,input {&attr-need-gen-new-xpack}
                        ,input "no":U
                        ) no-error.
      if error-status :error then do:
        run write-to-log( vss-workfile + {&space-char}
                          + "Ошибка записи атрибута формирования нового пакета для ВС" + {&space-char}
                          + string( p-esys-id )
                        ) .
        assign
          p-err-gen-pack = 2
        .
        undo, return error.
      end.
    end.
    else do:
      if v-gen-new-xpack = false then do:
        run write-to-log( substitute( "Нет новой информации для отправки в ВС &1", p-esys-id ) ) .
      end.
      leave gen-pack .
    end.
    run bge/espcknum.p // 28/X-2018 - v-source-dir и v-target-dir не используются;
                       // 12/VIII-2019 - v-temp-dir, v-log-file-name, v-list-file-name не используются
      ( input "put":U
       ,input p-esys-id
       ,input p-db-num
       ,input buf_ext-system.delivery-method
       ,input oxml-exch-dir
       ,input oxml-heap-dir
       ,input ""
       ,input-output v-pack-num
       ,input-output v-custom-pack-name
       ,output v-pack-name
       ,output v-source-dir
       ,output v-target-dir
       ,output v-temp-dir
       ,output v-log-file-name
       ,output v-list-file-name
       ,output v-custom-pack-flag
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
      if v-pack-num = v-fst-pck + 30
      or (buf_ext-system.delivery-method = integer({&esys-dm-erp-1C-RN}) and v-pack-num = v-fst-pck + 1)
      then do:    /*?????????????????????*/
        assign
          p-cre-all-pck = false
        .
        leave gen-pack .
      end.
    end.

    if mFrameView
    then do with frame inf
    :
      assign
        p-esys-id :screen-value   = string( p-esys-id, p-esys-id :format)
        v-pack-num :screen-value = string( v-pack-num, v-pack-num :format)
      .
    end.

    run write-to-log( substitute("Подготовка пакета N &1 для ВС N &2", v-pack-num, p-esys-id ) ).

    find first buf_ext-system
      where buf_ext-system.esys-id = p-esys-id
        and buf_ext-system.db-num = p-db-num
      no-error
    .
    if not available buf_ext-system then do:
      run write-to-log( substitute( "&1. Подготовка пакета прервана. ВС &2 не найдена.", vss-workfile, p-esys-id ) ).
      assign
        p-err-gen-pack = 2
      .
      undo, return error.
    end.

    /* пока такого поля нет
    assign
      v-max-pack-size = buf_ext-system.esys-max-p-size
    .

    */

    assign
    v-max-pack-size = 10000
    .
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

    find first buf_esys-pck-sent no-lock
      where buf_esys-pck-sent.esys-id   = p-esys-id
         and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-pack-num = v-pack-num
      no-error
    .
    if available buf_esys-pck-sent then do:
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
    &scop pack-num v-pack-num
    &scop cr-db-num g#db-num
    &scop esys-db-num p-db-num
    &scop esys-id p-esys-id
    &scop pack-time v-time
    &scop pack-date v-today
      { bge/cre-xpck.i }
      buf_esys-pck-sent.custom-pack-name = v-custom-pack-name.
      if index(v-custom-pack-name,  "&pack-num") > 0 then do:
        buf_esys-pck-sent.custom-pack-name = replace(v-custom-pack-name, "&pack-num", string(v-pack-num)).
      end.
      if v-custom-pack-flag = no then do: 
        assign buf_esys-pck-sent.custom-pack-name = buf_esys-pck-sent.custom-pack-name + "xml".
      end.
/*    end. 22/01/2019 Объединили создание esys-pck-sent и проставление его номера в esys-route в одну транзакцию */
      assign
        route-cnt = 0
        rec-cnt   = 0
      .
      define variable v-uniq-gate-rec as character no-undo init ?.
      define variable v-action as character no-undo .
      v-uniq-gate-rec = ?.
      route-label:
      for each buf_esys-route no-lock
        where buf_esys-route.esys-id   = p-esys-id
          and buf_esys-route.db-num    = p-db-num
          and buf_esys-route.esr-last-pack = -1
  /*        and buf_esys-route.esr-cr-db-num = g#db-num*/
        by buf_esys-route.esr-tbl-ord
      on error   undo, return error
      on end-key undo, return error
      :
        if buf_esys-route.esr-tbl-ord > v-last-tbl-ord then do:
          /* кладем в пакет только те записи, которые созданы до начала формирования пакета */
          leave route-label.
        end.
        if v-uniq-gate-rec = ? then do:
          assign
          v-uniq-gate-rec = buf_esys-route.uniq-gate-rec.
          v-action = buf_esys-route.esr-action.
        end.
        if buf_esys-route.uniq-gate-rec <> v-uniq-gate-rec then do:
          leave route-label.
        end.
        if v-action <> buf_esys-route.esr-action then do:
          leave route-label.
        end.
  
        find ub.esys-route exclusive-lock
          where rowid( ub.esys-route ) = rowid( buf_esys-route )
          no-wait no-error
        .
        if not available ub.esys-route then do:
          if locked ub.esys-route then do:
            run write-to-log( vss-workfile + {&space-char}
                              + substitute( "Подготовка пакета прервана на захваченной записи &1", buf_esys-route.esr-name-rec )
                            ).
            if v-sys-key = {&SuperSysKey}
            then do:
              run gbl/findlock.p
                (input  recid( buf_esys-route )
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
                              + substitute( "Подготовка пакета прервана на отсутствующей записи &1", buf_esys-route.esr-name-rec )
                            ).
          end.
          assign
            p-err-gen-pack = 1
          .
          leave route-label.
        end.
  
  
        if ub.esys-route.esr-num-dump = 0 then do:
          assign
            qnty-of-cur-rec = 1
          .
        end.
        else do:
          assign
            qnty-of-cur-rec = ub.esys-route.esr-num-dump
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
            p-esys-id :screen-value   = string( p-esys-id, p-esys-id :format)
            v-pack-num :screen-value = string( v-pack-num, v-pack-num :format)
            route-cnt :screen-value  = string( route-cnt, route-cnt :format)
            rec-cnt :screen-value  = string( rec-cnt - route-cnt, rec-cnt :format)
          .
        end.
  
        assign
          ub.esys-route.esr-last-pack = v-pack-num
        .
        if buf_esys-route.esr-action = {&nwsdochs_action_command-bush}
        and buf_ext-system.delivery-method <> integer({&esys-dm-erp-1C-RN}) 
        then do:
          leave route-label.
        end.
      end. /* for each buf_esys-route */

  /*  if p-err-gen-pack = 2 then do:*/
  /*    undo, return error.*/
  /*  end.*/

/*    do transaction                                                                                                                                                       */
/*    on error  undo, return error substitute( "&1 (pck-sent). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )*/
/*    on stop   undo, return error substitute( "&1 (pck-sent). stop", vss-workfile )                                                                                       */
/*    on endkey undo, return error substitute( "&1 (pck-sent). endkey", vss-workfile )                                                                                     */
/*    :                                                                                                                                                                    */

      find first ub.esys-pck-sent exclusive-lock
        where ub.esys-pck-sent.esys-id  = p-esys-id
          and ub.esys-pck-sent.db-num   = p-db-num
/*          and ub.esys-pck-sent.esps-cr-db-num  = g#db-num*/
          and ub.esys-pck-sent.esps-pack-num = v-pack-num
        no-error
      .
      if not available ub.esys-pck-sent then do:
        run write-to-log( substitute( "&1. Отсутствует шапка пакета с номером &2!", vss-workfile, v-pack-num ) ) .
        assign
          p-err-gen-pack = 2
        .
        undo, return error.
      end.
      assign
        ub.esys-pck-sent.esps-total-recs = route-cnt
      .
    end.

  end.
  if mFrameView
  then do:
    hide frame inf.
  end. 
end.

procedure initial-export :
define input  parameter p-esys-id as integer   no-undo .
define input  parameter p-db-num as integer   no-undo .
define input  parameter p-esys-name as character no-undo .

define buffer buf_esys-route for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.
define buffer buf_BatchProcess       for ub.BatchProcess.

do
on error undo, return error return-value
:
  for each buf_esys-route exclusive-lock
      where buf_esys-route.esys-id        = p-esys-id
        and buf_esys-route.db-num         = p-db-num
  :
      for each buf_esys-route-dump exclusive-lock
          where buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
      on error undo, return error
      :
          delete buf_esys-route-dump.
      end.
      delete buf_esys-route.
  end.
  run write-to-log (

        input substitute( "Подготовка таблиц выгрузки внешней системы '&1' завершена.", p-esys-name )
                                   ).
  { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="{&btpr-type-oxml-new}"
      &btpr-table="buf_BatchProcess"
      &btpr-lock-option="no-lock"
      &key#_one=p-esys-id
      &key#_two=p-db-num
  }
  if available buf_BatchProcess
  then do:
      run bge/oxmlinit.p (
            input this-procedure
          , input p-esys-id
          , input p-db-num
      ).
      do transaction
      on error undo, return error
      :
          { trg/btpr_upd.i
              &btpr-status="find"
              &btpr-type="{&btpr-type-oxml-new}"
              &btpr-table="buf_BatchProcess"
              &btpr-lock-option="exclusive-lock"
              &key#_one=p-esys-id
              &key#_two=p-db-num
          }
          delete buf_BatchProcess.
      end.        /* do transaction */
  end.

end.

end procedure. /* initial-export */