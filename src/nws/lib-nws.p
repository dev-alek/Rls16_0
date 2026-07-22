block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lib-nws.p $
$Archive: nws/lib-nws.p $

Библиотека процедур для работы в СПН

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/06
Author: Bakhtadze Natalya
Creation date: 07/14/06

*/

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-nws.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: nws/lib-nws.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы в СПН":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ nws/lib-nws.i }
{ gbl/cur-time.i }
{ gbl/usrnickf.i }
{ gbl/key-rec.i  }
{ trg/checkart.i }

if valid-handle (g#lib-nws)
and g#lib-nws <> this-procedure :handle
and g#lib-nws :get-signature('lib-nws_clear-fill-option':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с СПН" skip
    g#lib-nws skip
    g#lib-nws :type skip
    g#lib-nws :file-name skip
    valid-handle(g#lib-nws) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-nws = this-procedure :handle
  .
end.

define temp-table temp-hist-nws-option no-undo like ub.hist-nws-option.
define buffer locked_hist-nws-option for ub.hist-nws-option.
define variable v-lock-type as integer no-undo .
define variable v-prev-lock-type as integer no-undo .
define variable v-cashed-version as character no-undo .
define variable v-cashed-time as int64 no-undo .


on delete of this-procedure do:
  for each temp-hist-nws-option:
    delete temp-hist-nws-option.
  end.
  assign
    g#lib-nws = ?
  .

end.

define stream str-err.


procedure lib-nws_clear-fill-option:
define input parameter p-fill-option as character no-undo .
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
  do
  on error undo, return error return-value
  :
    for each buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.fill-option = p-fill-option
    on error undo, return error :
      delete buf_temp-hist-nws-option.
    end.
    assign
    v-lock-type = v-prev-lock-type
    v-cashed-version = '':U
    v-cashed-time = 0
    .
  end.

end procedure. /* lib-nws_clear-fill-option */


procedure lib-nws_fill-dct:
define input parameter p-fill-option as character no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer buf_hist-nws-option for ub.hist-nws-option.
  do
  on error undo, return error return-value
  :
    v-prev-lock-type = v-lock-type.
    run lib-nws_clear-fill-option in this-procedure ( input {&table_c-dc-hist}).
    if v-lock-type = 0 then do:
      find first locked_hist-nws-option no-lock where
                locked_hist-nws-option.db-num = g#db-num
            and locked_hist-nws-option.hn-id = 0 .
      assign
      v-lock-type = NO-LOCK
      .
    end.

    for each buf_hist-nws-option no-lock where
             buf_hist-nws-option.db-num = g#db-num
         and buf_hist-nws-option.hn-id > 0
         and buf_hist-nws-option.subject-group = {&table_c-dc-hist}
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      create buf_temp-hist-nws-option.
      buffer-copy buf_hist-nws-option to buf_temp-hist-nws-option.
      assign
      buf_temp-hist-nws-option.fill-option = p-fill-option
      .
    end.
  end.

end procedure. /* lib-nws_fill-dct */

procedure lib-nws_fill-hn-option-table :
define input parameter p-lock-type as integer no-undo .
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.


  do
  on error undo, return error return-value
  :

    find first locked_hist-nws-option share-lock where
      locked_hist-nws-option.db-num = g#db-num
      and locked_hist-nws-option.hn-id = 0 .
    if v-cashed-version = locked_hist-nws-option.option-descr then do:
      release locked_hist-nws-option.
      return.
    end.
    assign
    v-lock-type = p-lock-type
    v-cashed-version = locked_hist-nws-option.option-descr
    v-cashed-time = etime
    .
    for each buf_temp-hist-nws-option:
      if buf_temp-hist-nws-option.charkey_one <> '':U
      or buf_temp-hist-nws-option.charkey_two <> '':U
      or buf_temp-hist-nws-option.charkey_three <> '':U
      or buf_temp-hist-nws-option.key#_one <> 0
      or buf_temp-hist-nws-option.key#_two <> 0
      or buf_temp-hist-nws-option.key#_three <> 0
      or buf_temp-hist-nws-option.host-code <> 0
      or buf_temp-hist-nws-option.obj-type <> '':U
      or buf_temp-hist-nws-option.obj-code <> 0 then next.
      delete buf_temp-hist-nws-option.
    end.
    for each buf_hist-nws-option no-lock where
             buf_hist-nws-option.db-num = g#db-num
         and buf_hist-nws-option.hn-id > 0
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      if buf_hist-nws-option.charkey_one <> '':U
      or buf_hist-nws-option.charkey_two <> '':U
      or buf_hist-nws-option.charkey_three <> '':U
      or buf_hist-nws-option.key#_one <> 0
      or buf_hist-nws-option.key#_two <> 0
      or buf_hist-nws-option.key#_three <> 0
      or buf_hist-nws-option.host-code <> 0
      or buf_hist-nws-option.obj-type <> '':U
      or buf_hist-nws-option.obj-code <> 0 then next.
      create buf_temp-hist-nws-option.
      buffer-copy buf_hist-nws-option to buf_temp-hist-nws-option.
    end.
    case p-lock-type:
      when no-lock then do:
        release locked_hist-nws-option.

      end.
      when share-lock then do:
        find current locked_hist-nws-option share-lock .

      end.
      when exclusive-lock then do:
        find current locked_hist-nws-option exclusive-lock .
      end.
    end case.
  end.

end procedure. /* lib-nws_fill-hn-option-table */

procedure lib-nws_get-hn-option :
define input parameter p-db-num as integer no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-CHarkey_one as character no-undo .
define input parameter p-CHarkey_two as character no-undo .
define input parameter p-CHarkey_three as character no-undo .
define input parameter p-key#_one as integer no-undo .
define input parameter p-key#_two as integer no-undo .
define input parameter p-key#_three as integer no-undo .
define input parameter p-option-name as character no-undo .
define output parameter p-option-value as integer no-undo .

define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :

    if v-cashed-version = '':U
    or  (etime - v-cashed-time > 1800000)
    or etime < v-cashed-time
    then do:
      run lib-nws_fill-hn-option-table  in this-procedure ( input no-lock) no-error .
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
    end.
    if p-option-name = {&smart-nws} then do:
      p-option-value = integer({&hn-is-off}).
    end.
    else do:
      p-option-value = integer({&hn-is-on}).
    end.
    find first buf_temp-hist-nws-option where
              buf_temp-hist-nws-option.db-num = p-db-num
          and buf_temp-hist-nws-option.table-name = p-table-name
          and buf_temp-hist-nws-option.CHarkey_one = p-CHarkey_one
          and buf_temp-hist-nws-option.CHarkey_two = p-CHarkey_two
          and buf_temp-hist-nws-option.CHarkey_three = p-CHarkey_three
          and buf_temp-hist-nws-option.key#_one = p-key#_one
          and buf_temp-hist-nws-option.key#_two = p-key#_two
          and buf_temp-hist-nws-option.key#_three = p-key#_three
          and buf_temp-hist-nws-option.host-code = p-host-code
          and buf_temp-hist-nws-option.obj-type = p-obj-type
          and buf_temp-hist-nws-option.obj-code = p-obj-code
          no-error.
    if not available buf_temp-hist-nws-option then return.
    assign
    p-option-value = buffer buf_temp-hist-nws-option:buffer-field(p-option-name):buffer-value
    no-error .
  end.

end procedure. /* lib-nws_get-hn-option */

procedure lib-nws_get-hn-option-record :
define input parameter p-db-num as integer no-undo .
define input parameter p-bh as handle no-undo.

define variable v-bh as handle no-undo .
define variable v-tbh as handle no-undo .
define variable v-phrase as character no-undo .
define variable glog as logical no-undo .
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer buf_hist-nws-option for ub.hist-nws-option.

  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    if v-cashed-version = '':U
    or  (etime - v-cashed-time > 1800000)
    or etime < v-cashed-time
    then do:
      run lib-nws_fill-hn-option-table  in this-procedure ( input no-lock) no-error .
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
      end.
    end.
    glog = p-bh:find-first('':U, v-lock-type).
    v-tbh = buffer buf_temp-hist-nws-option:handle.
    v-bh = buffer buf_hist-nws-option:handle.
    v-phrase =  substitute( 'where db-num = &1 ' +
                           'and table-name = "&2" ' +
                           'and CHarkey_one = "&3" ' +
                           'and CHarkey_two = "&4" ' +
                           'and CHarkey_three = "&5" ' +
                           'and key#_one = &6 ' +
                           'and key#_two = &7 ' +
                           'and key#_three = &8 ' +
                           'and host-code = &9 '
                           ,p-db-num
                           ,p-bh:buffer-field('table-name'):buffer-value
                           ,p-bh:buffer-field('charkey_one'):buffer-value
                           ,p-bh:buffer-field('charkey_two'):buffer-value
                           ,p-bh:buffer-field('charkey_three'):buffer-value
                           ,p-bh:buffer-field('key#_one'):buffer-value
                           ,p-bh:buffer-field('key#_two'):buffer-value
                           ,p-bh:buffer-field('key#_three'):buffer-value
                           ,p-bh:buffer-field('host-code'):buffer-value)
               + substitute('and obj-type = "&1" ' +
                            'and obj-code = &2 '
                            ,p-bh:buffer-field('obj-type'):buffer-value
                            ,p-bh:buffer-field('obj-code'):buffer-value).
    glog = v-tbh:find-first( v-phrase, no-lock) no-error .
    if not glog then do:
      glog = v-bh:find-first( v-phrase, no-lock) no-error .
      if glog then do:
        glog = p-bh:buffer-copy ( v-bh) no-error .
      end.
    end.
    else do:
      glog = p-bh:buffer-copy ( v-tbh) no-error .
    end.
  end.

end procedure. /* lib-nws_get-hn-option */

/* Блокировка маршрутизации */
procedure lib-nws_lock-route :

  define input  parameter p-action as character no-undo .
  define input  parameter p-db-num as integer   no-undo .
  define input  parameter p-esys-id as integer  no-undo.
  define input  parameter p-descr  as character no-undo .
  define output parameter p-msg    as character no-undo .
  define output parameter p-lock   as logical   no-undo .
  define output parameter p-ok     as logical   no-undo .

  do
  on error  undo, return error substitute( "&1 (lib-nws_lock-route). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (lib-nws_lock-route). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-nws_lock-route). endkey", vss-workfile )
  :

    define variable v-date as date    no-undo .
    define variable v-time as integer no-undo .
    define variable v-CharKey_One    as character    no-undo.
    define variable v-BP_Type        as character    no-undo.

    define buffer buf_BatchProcess for ub.BatchProcess .

      if p-esys-id = 0
      then do:
          assign
              v-CharKey_One = substitute( "&1&2", p-db-num
                                              , ( if p-esys-id = 0 then "":U else ",":U + string( p-esys-id ) ) )
              v-BP_Type     = {&btpr-type-lock-route}
          .
      end.        /* if p-esys-id = 0 */
      else do:
          assign
              v-CharKey_One = substitute( "&1&2", p-db-num
                                              , ( if p-esys-id = 0 then "":U else ",":U + string( p-esys-id ) ) )
              v-BP_Type     = {&btpr-type-lock-ext-sys-route}
          .
      end.        /* NOT ( if p-esys-id = 0 ) */

    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.BP_Type     = v-BP_Type
        and buf_BatchProcess.CharKey_One = v-CharKey_One
      no-error .

    assign
      p-ok = true
    .
    case p-action :
      when "lockfull":U /* без исключения */
      or when "lockwnws":U /* не действует только на СПН */
      then do:
        assign
          p-lock = true
        .
        if available buf_BatchProcess then do:
          assign
            p-ok  = false
            p-msg = substitute( "Блокировка маршрутизации для БД &1 уже установлена пользователем &2 (&3) &4 в &5 (&6)"
                                ,v-CharKey_One
                                ,usrnickf( buf_BatchProcess.User_ID )
                                ,buf_BatchProcess.User_ID
                                ,string( buf_BatchProcess.BP_SysDate, "99.99.9999" )
                                ,buf_BatchProcess.BP_SysTime
                                ,buf_BatchProcess.CharKey_Three
                              ).
          .
        end.
        else do:
          run cur-time ( output v-date
                        ,output v-time
                      ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
          end.
          create buf_BatchProcess .
          assign
            p-msg = substitute( "БД &1 заблокировка маршрутизации (&2)"
                                ,v-CharKey_One
                                ,p-descr
                              )
            buf_BatchProcess.BatchProcess#     = next-value (s-btpr, {&db-name_schema})
            buf_BatchProcess.BP_Status         = {&btpr-normal}
            buf_BatchProcess.BP_Type           = v-BP_Type
            buf_BatchProcess.User_ID           = g#userid
            buf_BatchProcess.BP_SysDate        = v-date
            buf_BatchProcess.BP_SysTimeInt     = v-time
            buf_BatchProcess.BP_SysTime        = string(v-time, 'HH:MM:SS':U)
            buf_BatchProcess.CharKey_One       = v-CharKey_One
            buf_BatchProcess.CharKey_Two       = p-action
            buf_BatchProcess.CharKey_Three     = p-descr
          .
        end.
      end.
      when "unlock":U then do:
        assign
          p-lock = false
        .
        if available buf_BatchProcess then do:
          find first buf_BatchProcess
            where buf_BatchProcess.BP_Status   = {&btpr-normal}
              and buf_BatchProcess.BP_Type     = v-BP_Type
              and buf_BatchProcess.CharKey_One = v-CharKey_One
            no-error .
          delete buf_BatchProcess .
          assign
            p-msg = "Блокировка снята"
          .
        end.
        else do:
          assign
            p-msg = "Блокировка не установлена"
          .
        end.
      end.
      when "check":U then do:
        if available buf_BatchProcess
          and ( buf_BatchProcess.CharKey_Two <> "lockwnws":U
                or
                ( buf_BatchProcess.CharKey_Two = "lockwnws":U
                  and g#news <> true
                )
              )
        then do:
          assign
            p-msg = substitute( "Маршрутизация в БД &1 заблокирована пользователем &2 (&3) &4 в &5 (&6)"
                                ,v-CharKey_One
                                ,usrnickf( buf_BatchProcess.User_ID )
                                ,buf_BatchProcess.User_ID
                                ,string( buf_BatchProcess.BP_SysDate, "99.99.9999" )
                                ,buf_BatchProcess.BP_SysTime
                                ,buf_BatchProcess.CharKey_Three
                              ).
            p-lock = true
          .
        end.
        else do:
          assign
            p-msg  = "Блокировка не установлена"
            p-lock = false
          .
        end.
      end.
      otherwise do:
        return error substitute( "&1. Нет обработки операции &2", vss-workfile, p-action ) .
      end.
    end case.

  end.

end procedure. /* lib-nws_lock-route */

/* Cоздание записи таблицы связей при создании route-dump */
procedure lib-nws_route-dump-write :

  define input parameter p-tbl-name   as character           no-undo .
  define input parameter p-bh_rtd     as handle              no-undo .
  define input parameter p-bh         as handle              no-undo .
  define input parameter p-dmp-ord    like ub.route.dump-ord no-undo .
  define input parameter p-rc-ord     as integer             no-undo .

  do
  on error  undo, return error substitute( "&1 (lib-nws_route-dump-write). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (lib-nws_route-dump-write). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-nws_route-dump-write). endkey", vss-workfile )
  :

    define buffer buf-rtdl_goods           for ub.goods .
    define buffer buf-rtdl_route-dump-link for ub.route-dump-link .

    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh_tt           as handle    no-undo .

    define variable v-num-fields     as integer no-undo .
    define variable v-ind            as integer no-undo .
    define variable v-avail-gds-code as logical no-undo .
    define variable v-avail-artic    as logical no-undo .
    define variable fh_tbl-name      as handle  no-undo .
    define variable fh_gds-code      as handle  no-undo .
    define variable fh_artic         as handle  no-undo .
    define variable fh_prod-type     as handle  no-undo .
    define variable fh_prod-code     as handle  no-undo .

    define variable v-ok             as logical   no-undo .

    define variable v-loc-key-rec like ub.route-dump-link.uniq-key-rec no-undo.
    create temp-table tth.

    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-name
    .
    if valid-handle(p-bh) then do:
      assign
        v-ok = tth:create-like( p-bh ) no-error
      .
    end.
    else do:
      assign
        v-ok = tth:create-like( p-tbl-name ) no-error
      .
    end.
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (1)", vss-workfile, tt-name ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (2)", vss-workfile, tt-name ) .
    end.

    assign
      bh_tt = tth:default-buffer-handle
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании буфера временной таблицы.", vss-workfile, p-tbl-name ).
    end.

    assign
      v-ok = bh_tt:raw-transfer ( false, p-bh_rtd:buffer-field("value-rec") ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. RAW-TRANSFER не прошел для таблицы &2", vss-workfile, p-tbl-name ).
    end.

    assign
      fh_artic      = bh_tt:buffer-field( "artic":U )
      fh_prod-type  = bh_tt:buffer-field( "prod-type":U )
      fh_prod-code  = bh_tt:buffer-field( "prod-code":U )
      fh_gds-code   = bh_tt:buffer-field( "gds-code":U )
      no-error
    .
    if fh_artic <> ? then do:
      assign
        v-avail-artic = true
      .
    end.
    if fh_gds-code <> ? then do:
      assign
        v-avail-gds-code = true
      .
    end.
    if v-avail-gds-code = true
      or v-avail-artic = true
    then do:
      if v-avail-gds-code = true then do:
        if fh_gds-code:buffer-value() > 0 then do:
          find first buf-rtdl_goods no-lock
            where buf-rtdl_goods.gds-code = fh_gds-code:buffer-value()
          no-error .
          if not available buf-rtdl_goods then do:
            return error substitute( "&1. Товар с кодом &2 не найден по таблице &3"
                                    ,vss-workfile
                                    ,fh_gds-code:buffer-value()
                                    ,p-tbl-name
                                  ).
          end.
        end.
      end.
      else do:
/*        if v-avail-artic = true then do:*/
          find first buf-rtdl_goods no-lock
            where buf-rtdl_goods.artic     = fh_artic:buffer-value()
              and buf-rtdl_goods.prod-type = fh_prod-type:buffer-value()
              and buf-rtdl_goods.prod-code = fh_prod-code:buffer-value()
          no-error .
          if not available buf-rtdl_goods then do:
            return error substitute( "&1. Товар с артикулом &2 производителя &3 &4 не найден по таблице &5"
                                    ,vss-workfile
                                    ,fh_artic:buffer-value()
                                    ,fh_prod-type:buffer-value()
                                    ,fh_prod-code:buffer-value()
                                    ,p-tbl-name
                                    ).
          end.
/*        end.*/
      end.

      if available buf-rtdl_goods then do:
        if v-avail-artic = true then do:
          run check-use-artic in this-procedure
            ( input p-tbl-name
            ,input fh_artic:buffer-value()
            ,input fh_prod-type:buffer-value()
            ,input fh_prod-code:buffer-value()
            ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.

        run gen-key-rec( input {&table_goods}
                        ,input (buffer buf-rtdl_goods:handle)
                        ,output v-loc-key-rec
                      ) no-error.
        if error-status :error then do:
          return error substitute( "&1. Ошибка при генерации уникального ключа по таблице &2 для &3. &4"
                                  ,vss-workfile
                                  ,{&table_goods}
                                  ,p-tbl-name
                                  ,return-value
                                ).
        end.
        create buf-rtdl_route-dump-link .
        assign
          buf-rtdl_route-dump-link.dump-ord     = p-dmp-ord
          buf-rtdl_route-dump-link.rec-ord      = p-rc-ord
          buf-rtdl_route-dump-link.uniq-key-rec = v-loc-key-rec
          buf-rtdl_route-dump-link.dump-name    = p-tbl-name
        .
      end.
    end.

    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при очистке временной таблицы &2", vss-workfile, tt-name ) .
    end.

    delete object tth no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении временной таблицы для &2", vss-workfile, tt-name ).
    end.

  end.

end procedure. /* lib-nws_route-dump-write */

/* $Workfile: lib-nws.p $   E n d */