block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание и обработка кустовых команд

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/23/04
Author: Dmitry Ukhanov
Creation date: 09/23/04

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание и обработка кустовых команд".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ nws/lib-nws.i  }
{ gbl/key-rec.i  }
{ nws/cr-rtd.i   }
{ gbl/cur-time.i }
{ gbl/gate-clb.i }
{ bge/esallatr.i work }

define temp-table for-route no-undo
  field name-rec as character
  field db-list  as character
  field dump-ord like ub.route.dump-ord
  field uniq-gate-rec like ub.route.uniq-gate-rec
  field custom-pck-name as character
  field action as character
  index pi is primary unique dump-ord
.

define temp-table for-route-dump no-undo like ub.route-dump 
    field blob-value-rec as blob.


on delete of this-procedure do:
  for each for-route
  :
    delete for-route.
  end.
  for each for-route-dump
  :
    delete for-route-dump.
  end.
end.

procedure begin-create-command :
  define input  parameter p-command-name as character no-undo .
  define input  parameter p-db-list      as character no-undo .
  define output parameter p-command-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (begin-create-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (begin-create-command). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (begin-create-command). endkey", vss-workfile )
  :
    if num-entries( p-command-name, {&delim-nws} ) > 1
      or num-entries( p-command-name, {&delim-key} ) > 1
    then do:
      return error substitute( "&1 (begin-create-command). Название команды не может содержать символы {&delim-nws}, {&delim-key}!!!", vss-workfile ) .
    end.
    if trim( p-command-name ) = "":U
      or p-command-name = ?
    then do:
      return error substitute( "&1 (begin-create-command). Команда должна иметь название!!!", vss-workfile ) .
    end.

    find last for-route
      no-error .
    if available for-route then do:
      assign
        p-command-code = for-route.dump-ord + 1
      .
    end.
    else do:
      assign
        p-command-code = 1
      .
    end.
    create for-route .
    assign
      for-route.name-rec = p-command-name
      for-route.db-list  = p-db-list
      for-route.dump-ord = p-command-code
    .
  end.
  return.
end procedure. /* begin-create-command */

procedure add-dump :
  define input  parameter p-command-code as integer   no-undo .
  define input  parameter p-dump-name    as character no-undo .
  define input  parameter p-action       as character no-undo .
  define input  parameter p-tbl-handle   as handle    no-undo .
  define input  parameter p-uniq-gate-rec as character no-undo .
  define output parameter p-rec-ord      as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (add-dump). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (add-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (add-dump). endkey", vss-workfile )
  :

    define variable v-rec-ord      like ub.route-dump.rec-ord .
    define variable v-uniq-key-rec like ub.route-dump.uniq-key-rec .
    define variable v-value-rec    like ub.route-dump.value-rec .

    define variable v-first-char as character no-undo .
    define variable v-cre-raw    as logical   no-undo .

    find first for-route
      where for-route.dump-ord = p-command-code
      no-error .
    if not available for-route then do:
      return error substitute( "&1 (add-dump). Команда с кодом &2 еще не создана!", vss-workfile, p-command-code ) .
    end.
    if p-uniq-gate-rec <> '' then do:
      if for-route.uniq-gate-rec = '':U then do:
        for-route.uniq-gate-rec = p-uniq-gate-rec.
      end.
      else do:
        if for-route.uniq-gate-rec <> p-uniq-gate-rec then do:
        /*если структура хранится в БД то продатасет должен быть указан в шапке команды и в нем таблицы для всех
        for-route-dump в которых uniq-data-rec <> '' */
            undo, return error
            substitute( "&1 (add-dump). &2&3&4"
                        , vss-workfile
                        , return-value
                        , {&new-line}
                        , substitute("в route-dump указан непустой gate &1 отличный от gate route (&2)"
                                     , for-route-dump.uniq-gate-rec
                                     , for-route.uniq-gate-rec)
                        ).
        end.
      end.
    end.
    assign
      v-first-char = substring( p-action, 1, 1 )
      v-cre-raw    = true
    .

    if trim( p-action ) <> "":U then do:
      if lookup( v-first-char, "+,-,_":U, ",":U ) = 0 then do:
        return error substitute( "&1 (add-dump). Ошибка задания входных параметров! &2"
                                + "Задан параметр action. Первый его символ должен быть '+' или '-' или '_'. "
                                + "Текущее значение: &3"
                                ,vss-workfile
                                ,{&new-line}
                                ,p-action
                              ) .
      end.
      else do:
        if v-first-char = "-":U
        or v-first-char = "_":U
        then do:
          assign
            v-cre-raw = false
          .
        end.
      end.
    end.

    find last for-route-dump
      where for-route-dump.dump-ord = p-command-code
      no-error .
    if available for-route-dump then do:
      assign
        v-rec-ord = for-route-dump.rec-ord + 1
      .
    end.
    else do:
      assign
        v-rec-ord = 1
      .
    end.
    if v-first-char <> '_' then do:
    run gen-key-rec in this-procedure
      ( input  p-dump-name
       ,input  p-tbl-handle
       ,output v-uniq-key-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1 (add-dump). Ошибка при генерации уникального ключа по таблице &2 для команды с кодом &3.&4&5&4&6"
                               ,vss-workfile
                               ,p-dump-name
                               ,p-command-code
                               ,{&new-line}
                               ,return-value
                               ,error-status :get-message ( 1 )
                              ) .
    end.
    end.
    if v-cre-raw = true then do:
      run cre-raw in this-procedure
        ( input  p-dump-name
         ,input  p-tbl-handle
         ,output v-value-rec
        ) no-error.
      if error-status :error then do:
        return error substitute( "&1 (add-dump). Ошибка при сжатии записи по таблице &2 в команду с кодом &3.&4&5&4&6"
                                ,vss-workfile
                                ,p-dump-name
                                ,p-command-code
                                ,{&new-line}
                                ,return-value
                                ,error-status :get-message ( 1 )
                                ) .
      end.
    end.
    create for-route-dump .
    assign
      for-route-dump.dump-name    = entry(1, p-dump-name, {&delim-par})
      for-route-dump.action       = p-action
      for-route-dump.dump-ord     = p-command-code
      for-route-dump.rec-ord      = v-rec-ord
      for-route-dump.uniq-key-rec = v-uniq-key-rec
      for-route-dump.value-rec    = v-value-rec
      for-route-dump.uniq-gate-rec = p-uniq-gate-rec
      p-rec-ord                   = v-rec-ord
    .
  end.
  return.
end procedure. /* add-dump */

procedure add-dump-data :
  define input  parameter p-command-code as integer   no-undo .
  define input  parameter p-dump-name    as character no-undo .
  define input  parameter p-action       as character no-undo .
  define input  parameter p-data         as memptr    no-undo .
  define output parameter p-rec-ord      as integer   no-undo .

  do
  on error  undo, return error substitute( "&1 (add-dump). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (add-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (add-dump). endkey", vss-workfile )
  :

    define variable v-rec-ord      like ub.route-dump.rec-ord .

    define variable v-first-char as character no-undo .
    
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error .
    if not available for-route then do:
      return error substitute( "&1 (add-dump). Команда с кодом &2 еще не создана!", vss-workfile, p-command-code ) .
    end.

    assign
      v-first-char = substring( p-action, 1, 1 ).
    if trim( p-action ) <> "":U then do:
      if lookup( v-first-char, "+,-,_":U, ",":U ) = 0 then do:
        return error substitute( "&1 (add-dump). Ошибка задания входных параметров! &2"
                                + "Задан параметр action. Первый его символ должен быть '+' или '-' или '_'. "
                                + "Текущее значение: &3"
                                ,vss-workfile
                                ,{&new-line}
                                ,p-action
                              ) .
      end.
    end.

    find last for-route-dump
      where for-route-dump.dump-ord = p-command-code
      no-error .
    if available for-route-dump then do:
      assign
        v-rec-ord = for-route-dump.rec-ord + 1
      .
    end.
    else do:
      assign
        v-rec-ord = 1
      .
    end.

    create for-route-dump .
    assign
      for-route-dump.dump-name    = entry(1, p-dump-name, {&delim-par})
      for-route-dump.uniq-key-rec = if num-entries(p-dump-name, {&delim-par}) > 1 then  entry(2, p-dump-name, {&delim-par}) else ""
      for-route-dump.action       = p-action
      for-route-dump.dump-ord     = p-command-code
      for-route-dump.rec-ord      = v-rec-ord
      for-route-dump.blob-value-rec    = p-data
      p-rec-ord                   = v-rec-ord
    .
  end.
  return.
end procedure. /* add-dump */

procedure delete-command :
  define input parameter p-command-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (delete-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (delete-command). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (delete-command). endkey", vss-workfile )
  :
    for each for-route
      where for-route.dump-ord = p-command-code
    on error undo, return error substitute( "&1 (delete-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      delete for-route.
    end.
    for each for-route-dump
      where for-route-dump.dump-ord = p-command-code
    on error undo, return error substitute( "&1 (delete-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      delete for-route-dump.
    end.
  end.
  return.
end procedure. /* delete-command */

procedure send-command :
  define input parameter p-command-code as integer   no-undo .
  define input parameter p-db-list      as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-command). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-command). endkey", vss-workfile )
  :
    define buffer buf_route      for ub.route .
    define buffer buf_route-dump for ub.route-dump .
    define buffer buf_db         for ub.db .

    define variable v-ind as integer no-undo .

    define variable v-dmp-ord      like ub.route.dump-ord     no-undo .
    define variable v-rec-ord      like ub.route-dump.rec-ord no-undo .
    define variable v-command-name like ub.route.name-rec     no-undo .
    define variable v-rt-count     as   integer               no-undo .


    define variable v_dataseth as handle no-undo .
    define variable v-xmlh as handle no-undo .
    define variable v-h as handle no-undo .

    define buffer buf_temp-xml-tables for temp-xml-tables.
    v-xmlh = buffer buf_temp-xml-tables:handle.


    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (send-command). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.

    if trim( for-route.db-list ) <> "":U then do:
      assign
        p-db-list = for-route.db-list
      .
    end.

    block_cre-route:
    do transaction
    on error  undo block_cre-route, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo block_cre-route, return error substitute( "&1 (send-command). stop", vss-workfile )
    on endkey undo block_cre-route, return error substitute( "&1 (send-command). endkey", vss-workfile )
    :
      assign
        v-dmp-ord = next-value( s-news-dord, {&db-name_schema} )
        v-rec-ord = 0
      .
      if for-route.uniq-gate-rec <> '':U then do:
        define variable v-longchar as longchar no-undo .
        v-longchar = ?.
        run get-gate-by-rec in this-procedure ( input for-route.uniq-gate-rec
                                               ,output v_dataseth
                                               ,input-output v-xmlh
                                               ,input-output v-longchar
                                               ) no-error.
        if error-status:error
        then do:
          return error substitute( "&1 (send-command) Ошибка при создании структуры маршрутизируемых данных согласно гейту: &2. &4&5&6"
                                    , vss-workfile
                                    , for-route.uniq-gate-rec
                                    , return-value
                                    , {&new-line}
                                    , error-status :get-message ( 1 ) ).
        end.
      end.

      for each for-route-dump
        where for-route-dump.dump-ord = for-route.dump-ord
      on error undo, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        assign
          v-rec-ord = v-rec-ord + 1
        .
        create buf_route-dump .
        buffer-copy for-route-dump to buf_route-dump
          assign
            buf_route-dump.dump-ord     = v-dmp-ord
            buf_route-dump.rec-ord      = v-rec-ord
        .
        if for-route-dump.uniq-gate-rec <> '':u then do:
          find first buf_temp-xml-tables where
                    buf_temp-xml-tables.tbl-name = for-route-dump.dump-name.
          v-h = buf_temp-xml-tables.tbl-handle_.

        end.
        else do:
          v-h = ?.
        end.

        { nws/route-dw.i
          for-route-dump.dump-name
          "(buffer buf_route-dump:handle)"
          v-h
          v-dmp-ord
          v-rec-ord
          no-error
        }
        if error-status :error then do:
          undo block_cre-route, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
        end.
      end.
      assign
        v-command-name = "command":U + {&delim-nws} + "bush":U + {&delim-nws} + for-route.name-rec
        v-rt-count     = 0
      .
      do v-ind = 1 to num-entries(p-db-list, {&delim-nws} )
      on error undo block_cre-route, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        { nws/cr-rt.i
          &name-rec=v-command-name
          &db-num=integer(entry(v-ind,p-db-list,{&delim-nws}))
          &dump-ord=v-dmp-ord
          &uniq-key-rec="''":U
          &num-dump=v-rec-ord
          &uniq-gate-rec=for-route.uniq-gate-rec
          &cre-count=v-rt-count
        }
      end.
      if v-rt-count = 0 then do:
        do v-ind = 1 to num-entries( p-db-list, {&delim-nws} )
        on error  undo block_cre-route, return error substitute( "&1. (check-db-list) &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
        on stop   undo block_cre-route, return error substitute( "&1. (check-db-list) stop", vss-workfile )
        on endkey undo block_cre-route, return error substitute( "&1. (check-db-list) endkey", vss-workfile )
        :
          find buf_db no-lock
            where buf_db.db-num = integer( entry( v-ind, p-db-list, {&delim-nws} ) )
          .
          if buf_db.db-key <> ?
            and buf_db.db-key <> "":U
          then do:
            undo block_cre-route, return error substitute( "&1. Есть список БД для отправки, но ни одна запись не маршрутизировалась!!!", vss-workfile ) .
          end.
        end.
        /* отправлять некуда, все необходимые БД отключены */
        undo block_cre-route, leave block_cre-route .
      end.
    end. /* transaction */

    for each for-route-dump
      where for-route-dump.dump-ord = for-route.dump-ord
    on error undo, return error substitute( "&1 (send-command). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      delete for-route-dump .
    end.

    delete for-route .
    run gate-clear in this-procedure
      ( input v_dataseth
      , input v-xmlh
      ) no-error.


  end.

  return.
end procedure. /* send-command */

procedure send-command-esys :
  define input parameter p-command-code as integer   no-undo .
  define input parameter p-esys-id-list      as character no-undo .
  define input parameter p-user-name    as character no-undo .
  define output parameter p-dmp-ord as int64 no-undo .
  do
  on error  undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-command-esys). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-command-esys). endkey", vss-workfile )
  :
    define buffer buf_esys-route      for ub.esys-route .
    define buffer buf_esys-route-dump for ub.esys-route-dump .

    define variable v-ind as integer no-undo .

    define variable v-dmp-ord      like ub.esys-route.esr-dump-ord .
    define variable v-rec-ord      like ub.esys-route-dump.esrd-rec-ord .
    define variable v-command-name like ub.esys-route.esr-name-rec .
    DEFINE VARIABLE v-cre-date as date no-undo .
    DEFINE VARIABLE v-cre-time as integer no-undo .
    define variable v-cre-user as character no-undo .
    define variable v-act-name as character no-undo .
    define variable v-oper     as character no-undo .
    define buffer buf_sys-ctrl for ub.sys-ctrl.
    define buffer buf_esys-all-attr for ub.esys-all-attr.

    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (send-command-esys). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    find first buf_sys-ctrl no-lock.

    if trim( for-route.db-list ) <> "":U then do:
      assign
        p-esys-id-list = for-route.db-list
      .
    end.

    do transaction
    on error  undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (send-command-esys). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (send-command-esys). endkey", vss-workfile )
    :
      assign
        v-dmp-ord = next-value( s-news-dord, {&db-name_schema} )
        v-rec-ord = 0
        v-oper = ""
      .

      for each for-route-dump
        where for-route-dump.dump-ord = for-route.dump-ord
      on error undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        assign
          v-rec-ord = v-rec-ord + 1
        .
        create buf_esys-route-dump .
        assign
        buf_esys-route-dump.esrd-action       = for-route-dump.action
        buf_esys-route-dump.esrd-cr-db-num    = buf_sys-ctrl.db-num
        buf_esys-route-dump.esrd-dump-name    = for-route-dump.dump-name
        buf_esys-route-dump.esrd-dump-ord     = v-dmp-ord
        buf_esys-route-dump.esrd-rec-ord      = v-rec-ord
        buf_esys-route-dump.esrd-uniq-key-rec = for-route-dump.uniq-key-rec
        buf_esys-route-dump.uniq-gate-rec     = for-route-dump.uniq-gate-rec
        buf_esys-route-dump.esrd-value-rec    = for-route-dump.value-rec
        .
        buf_esys-route-dump.esrd-blob-value-rec = for-route-dump.blob-value-rec .
        v-oper = buf_esys-route-dump.esrd-dump-name .
      end.
      assign
        v-command-name = "command":U + {&delim-nws} + "bush":U + {&delim-nws} + for-route.name-rec
      .
      run cur-time in this-procedure
        ( output v-cre-date
        ,output v-cre-time
        ) no-error.
      if error-status :error then do:
        return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
      end.


      assign
        v-cre-user = p-user-name
        v-act-name = {&send-tbl-oxml}
      .


      do v-ind = 1 to num-entries(p-esys-id-list, {&delim-nws} )
      on error  undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
      :
        { nws/cr-rto.i
          &esr-name-rec=v-command-name
          &esr-db-num=0
          &esr-cr-db-num=buf_sys-ctrl.db-num
          &esr-esys-id=integer(entry(v-ind,p-esys-id-list,{&delim-nws}))
          &esr-dump-ord=v-dmp-ord
          &esr-uniq-key-rec="''":U
          &esr-uniq-gate-rec=for-route.uniq-gate-rec
          &esr-num-dump=v-rec-ord
          &esr-CreDate=v-cre-date
          &esr-CreTimeInt=v-cre-time
          &esr-CreUserName=v-cre-user
          &esr-action="(if for-route.action = '' then {&nwsdochs_action_command-bush} else for-route.action)"
          &esr-oper=v-oper
        }
        if for-route.custom-pck-name > '' then do:
          create buf_esys-all-attr.
          assign
          buf_esys-all-attr.attr-code = {&attr-route-custom-pack-name}
          buf_esys-all-attr.table-name = {&table_esys-route}
          buf_esys-all-attr.key1 = v-dmp-ord
          buf_esys-all-attr.key2 = integer(entry(v-ind,p-esys-id-list,{&delim-nws}))
          buf_esys-all-attr.key5 = 0
          buf_esys-all-attr.attr-value  = for-route.custom-pck-name
          buf_esys-all-attr.key6 = buf_sys-ctrl.db-num
          .
        end.
      end.
    end. /* transaction */

    for each for-route-dump
      where for-route-dump.dump-ord = for-route.dump-ord
    on error undo, return error substitute( "&1 (send-command-esys). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      delete for-route-dump .
    end.

    delete for-route .
    p-dmp-ord = v-dmp-ord.
    
    for each buf_esys-route where buf_esys-route.esr-dump-ord = v-dmp-ord and buf_esys-route.whole-send-news = 1: /*обмен данными осущ. через гбд удаляем все, т.к. все ушло в новости гбд*/
      delete buf_esys-route.
      for each buf_esys-all-attr where buf_esys-all-attr.table-name = {&table_esys-route} and buf_esys-all-attr.key1 = v-dmp-ord:
        delete buf_esys-all-attr.
      end.
    end.
    
  end.
  return.
end procedure. /* send-command-esys */


procedure set-custom-esys-pck-name :
  define input parameter p-command-code as integer   no-undo .
  define input parameter p-custom-pck-name as character no-undo .
  do
  on error  undo, return error substitute( "&1 (set-custom-esys-pck-name). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-custom-esys-pck-name). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-custom-esys-pck-name). endkey", vss-workfile )
  :
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (set-custom-esys-pck-name). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    assign
    for-route.custom-pck-name = p-custom-pck-name.

  end.
  return.
end procedure. /* send-command-esys */


procedure get-db-list :

  define input  parameter p-command-code as integer   no-undo .
  define output parameter p-db-list      as character no-undo .

  do
  on error  undo, return error substitute( "&1 (get-db-list). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-db-list). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-db-list). endkey", vss-workfile )
  :
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (get-db-list). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    assign
      p-db-list = for-route.db-list
    .
  end.

end procedure. /* get-db-list */

procedure copy-dump :
  define input parameter p-src-command-code as integer   no-undo .
  define input parameter p-trg-command-code as integer   no-undo .
  define input parameter p-rec-ord          as integer   no-undo .
  define input parameter p-uniq-key-rec     as character no-undo .

  do
  on error  undo, return error substitute( "&1 (copy-dump). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (copy-dump). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (copy-dump). endkey", vss-workfile )
  :
    define variable v-rec-ord      like ub.route-dump.rec-ord .
    define variable v-uniq-key-rec like ub.route-dump.uniq-key-rec .
    define variable v-value-rec    like ub.route-dump.value-rec .

    define buffer buf_src-route for for-route.
    define buffer buf_trg-route for for-route.
    define buffer buf_src-route-dump for for-route-dump.
    define buffer buf_trg-route-dump for for-route-dump.

    find first buf_src-route-dump
      where buf_src-route-dump.dump-ord = p-src-command-code
        and buf_src-route-dump.rec-ord = p-rec-ord
      no-error .
    if not available buf_src-route-dump then do:
      return error substitute( "&1 (copy-dump). Запись-источник (код команды &2, код записи &3) еще не создана!", vss-workfile, p-trg-command-code, p-rec-ord ) .
    end.
    find first buf_trg-route-dump
      where buf_trg-route-dump.dump-ord = p-trg-command-code
        and buf_trg-route-dump.rec-ord = p-rec-ord
      no-error .
    if not available buf_trg-route-dump then do:
      create buf_trg-route-dump.
      assign
      buf_trg-route-dump.dump-ord = p-trg-command-code
      buf_trg-route-dump.rec-ord = p-rec-ord
      .
    end.
    buffer-copy buf_src-route-dump except dump-ord
    to buf_trg-route-dump.
  end.
  return.
end procedure. /* copy-dump */

procedure is-almost-empty :
define input parameter p-cmd-code as integer no-undo .
define output parameter p-is-empty as logical no-undo .

define buffer buf_for-route-dump for for-route-dump.
  do
  on error undo, return error
  :
    find first buf_for-route-dump no-lock where
              buf_for-route-dump.dump-ord = p-cmd-code
         and  buf_for-route-dump.dump-name < {&table_nws-outline}
              no-error.
    if not available buf_for-route-dump then do:
      find first buf_for-route-dump no-lock where
                buf_for-route-dump.dump-ord = p-cmd-code
          and  buf_for-route-dump.dump-name > {&table_nws-outline}  no-error.
      if not available buf_for-route-dump then do:
        assign
        p-is-empty = yes.
      end.
    end.
  end.

end procedure. /* is-almost-empty */

procedure is-empty :
define input parameter p-cmd-code as integer no-undo .
define output parameter p-is-empty as logical no-undo .

define buffer buf_for-route-dump for for-route-dump.
  do
  on error undo, return error
  :
    find first buf_for-route-dump no-lock where
              buf_for-route-dump.dump-ord = p-cmd-code no-error.
    if not available buf_for-route-dump then do:
      assign
      p-is-empty = yes.
    end.

  end.

end procedure. /* is-empty */

procedure get-last-rec-ord :
define input parameter p-cmd-code as integer no-undo .
define output parameter p-last-rec-ord as integer no-undo .

  do
  on error  undo, return error substitute( "&1 (get-last-rec-ord). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-last-rec-ord). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-last-rec-ord). endkey", vss-workfile )
  :
    find last for-route-dump
      where for-route-dump.dump-ord = p-cmd-code
      no-error
    .
    if not available for-route-dump then do:
      p-last-rec-ord = 0.
    end.
    else do:
      p-last-rec-ord = for-route-dump.rec-ord.
    end.
  end.

end procedure. /* get-last-rec-ord */

procedure undo-from-rec-ord :
define input parameter p-cmd-code as integer no-undo .
define input parameter p-last-rec-ord as integer no-undo .


  do
  on error undo, return error
  :

    for each for-route-dump where
            for-route-dump.dump-ord = p-cmd-code
        and for-route-dump.rec-ord > p-last-rec-ord
    on error  undo, return error substitute( "&1 (undo-from-rec-ord). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo, return error substitute( "&1 (undo-from-rec-ord). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (undo-from-rec-ord). endkey", vss-workfile ):
       delete for-route-dump.
    end.
  end.

end procedure. /* undo-from-rec-ord */

procedure set-esys-command-action :
define input parameter p-command-code as integer   no-undo .
define input parameter p-action as character no-undo .

  do
  on error  undo, return error substitute( "&1 (set-esys-command-action ). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (set-esys-command-action ). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (set-esys-command-action ). endkey", vss-workfile )
  :
    find first for-route
      where for-route.dump-ord = p-command-code
      no-error
    .
    if not available for-route then do:
      return error substitute( "&1 (set-esys-command-action ). Команда с номером &2 не создана!", vss-workfile, p-command-code ) .
    end.
    assign
    for-route.action = p-action.
  end.

end procedure. /* set-esys-command-action */



/* $Workfile$ end */