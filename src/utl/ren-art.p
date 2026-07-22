block-level on error undo, throw.
/*

$Revision: d37bfb33277f, 3423, rls $
$Author: DRuban $
$Date: 2023/10/16 15:13:31 $
$Workfile: ren-art.p $
$Archive: utl/ren-art.p $

Изменение артикула и(или) производителя для одного товара

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/09/99
Author: Dmitry Ukhanov
Creation date: 09/09/99

*/
/*
- Таблицы имеющие индекс в котором поля artic prod-type prod-code стоят первыми добавляются в список TABLE-RART_LIST
- Таблицы в которых есть поля artic prod-type prod-code, но переименовывать его не надо добавляются в список TABLE-RART_IGNORE
- Таблицы в которых нет индекса с полеми artic prod-type prod-code в начале или необходима спецобработка записей добавляютс
  в список TABLE-RART_SPECIAL. В этом случае спецобработка описывается отдельно.
*/

define input  parameter old-gds-code  like ub.goods.gds-code  no-undo .
define input  parameter old-artic     like ub.goods.artic     no-undo .
define input  parameter old-prod-type like ub.goods.prod-type no-undo .
define input  parameter old-prod-code like ub.goods.prod-code no-undo .
define input  parameter new-artic     like ub.goods.artic     no-undo .
define input  parameter new-prod-type like ub.goods.prod-type no-undo .
define input  parameter new-prod-code like ub.goods.prod-code no-undo .

define variable vss-revision    as character no-undo init "$Revision: d37bfb33277f, 3423, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:31 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ren-art.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ren-art.p $":U .
define variable vss-description as character no-undo init "Изменение артикула и(или) производителя для одного товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/key-rec.i  }
{ gbl/cur-time.i }
{ trg/goodsh.i   }
{ gbl/waitfram.i }
{ gbl/temphost.i }
{ utl/ren-art.i  }
{ utl/rart-tbl.i }

do
on error undo, return error return-value
:

  define buffer buf_lock_batchprocess for ub.batchprocess .

  define variable v-ind         as integer   no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-tbl-name    as character no-undo .

  run valid-ren-art-tbl-list in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке списка таблиц для обработки." skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run gbl/lockrngd.p
    (input {&lock-prc-goods-rename-artic} /* p-lock-gds-type   */
    ,input {&lock-prc-subtype-enable}     /* p-sub-type        */
    ,buffer buf_lock_batchprocess         /* lock_batchprocess */
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при блокировании функции переименования артикула товара" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.

  update_block:
  do transaction
  on error undo update_block, return error return-value
  :

    define variable old-gds-key-rec like ub.route.uniq-key-rec  no-undo.

    define buffer buf_rename_goods for ub.goods .
    define buffer b-goods for ub.goods .

    find first buf_rename_goods exclusive-lock
      where buf_rename_goods.gds-code = old-gds-code
      no-error .

    if not available buf_rename_goods then do:
      return error "Товар не доступен" .
    end.


    if buf_rename_goods.artic     <> old-artic
    or buf_rename_goods.prod-type <> old-prod-type
    or buf_rename_goods.prod-code <> old-prod-code
    then do:
      return error substitute( "Товарa с gds-code &1 artic &2 prod-type &3 prod-code &4 НЕСУЩЕСТВУЕТ!", old-gds-code, old-artic, old-prod-type, old-prod-code ) .
    end.

    if new-artic = "" then do:
      return error "Новый артикул не может быть пустым" .
    end.

    if  new-artic     = old-artic
    and new-prod-type = old-prod-type
    and new-prod-code = old-prod-code
    then do:
      return "Новый артикул или производитель должен отличаться от старого" .
    end.

    if can-find(first b-goods no-lock
      where b-goods.artic     = new-artic
        and b-goods.prod-type = new-prod-type
        and b-goods.prod-code = new-prod-code )
    then do:
      return error substitute( "Уже существует товар с артикулом &1 и производителем &2 &3", new-artic, new-prod-type, new-prod-code) .
    end.

    RUN gen-key-rec
      (input {&table_goods}
      ,input (buffer buf_rename_goods:handle)
      ,output old-gds-key-rec
      ).

    run init-temphost .

    run waitfram-show in this-procedure
      ( input substitute( 'Переименование артикула &1 и(или) производителя &2 &3 товара', old-artic, old-prod-type, old-prod-code )
      ).

    assign
      v-num-entries = num-entries( {&TABLE-RART_LIST} )
    .
    do v-ind = 1 to v-num-entries
    on error  undo update_block, return error substitute( "&1 (TABLE-RART_LIST). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo update_block, return error substitute( "&1 (TABLE-RART_LIST). stop", vss-workfile )
    on quit   undo update_block, return error substitute( "&1 (TABLE-RART_LIST). quit", vss-workfile )
    on endkey undo update_block, return error substitute( "&1 (TABLE-RART_LIST). endkey", vss-workfile )
    :
      assign
        v-tbl-name = entry( v-ind, {&TABLE-RART_LIST} )
      .
      run waitfram-show in this-procedure
        ( input substitute( 'Переименование артикула &1 и(или) производителя &2 &3 товара. Обработка таблицы: &4'
                            ,old-artic
                            ,old-prod-type
                            ,old-prod-code
                            ,v-tbl-name
                          )
        ).
      run ren-artic in this-procedure
        ( input v-tbl-name
        ,input old-gds-key-rec
        ,input old-artic
        ,input old-prod-type
        ,input old-prod-code
        ,input new-artic
        ,input new-prod-type
        ,input new-prod-code
        ,input "":U /* search-bufs   */
        ,input "":U /* search-prefix */
        ,input "":U /* search-suffix */
        ) no-error.
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при переименовании артикула и(или) производителя товара в таблице &2&3&4&3&5"
                                      ,vss-workfile
                                      ,v-tbl-name
                                      ,{&new-line}
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ) .
      end.
    end.

    /* ----------------------------------------------------------------------------------- */
    /* здесь добавляется спецобработка переименования                                      */
    run waitfram-show in this-procedure
      ( input substitute( 'Переименование артикула &1 и(или) производителя &2 &3 товара. Обработка таблицы: &4'
                          ,old-artic
                          ,old-prod-type
                          ,old-prod-code
                          ,{&table_ot-line}
                        )
      ).
    run ren-artic in this-procedure
      ( input {&table_ot-line}
      ,input old-gds-key-rec
      ,input old-artic
      ,input old-prod-type
      ,input old-prod-code
      ,input new-artic
      ,input new-prod-type
      ,input new-prod-code
      ,input "temp-obj":U       /* search-bufs     */
      ,input "each temp-obj,":U /* search-prefix   */
      ,input "and ub.ot-line.obj-type = temp-obj.obj-type~
              and ub.ot-line.obj-code = temp-obj.obj-code":U /* search-suffix   */
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при переименовании артикула и(или) производителя товара в таблице &2&3&4&3&5"
                                    ,vss-workfile
                                    ,{&table_ot-line}
                                    ,{&new-line}
                                    ,error-status :get-message(1)
                                    ,return-value
                                  ) .
    end.

    run waitfram-show in this-procedure
      ( input substitute( 'Переименование артикула &1 и(или) производителя &2 &3 товара. Обработка таблицы: &4'
                          ,old-artic
                          ,old-prod-type
                          ,old-prod-code
                          ,{&table_stk-line}
                        )
      ).
    run ren-artic in this-procedure
      ( input {&table_stk-line}
      ,input old-gds-key-rec
      ,input old-artic
      ,input old-prod-type
      ,input old-prod-code
      ,input new-artic
      ,input new-prod-type
      ,input new-prod-code
      ,input "temp-obj":U       /* search-bufs     */
      ,input "each temp-obj,":U /* search-prefix   */
      ,input "and ub.stk-line.obj-type = temp-obj.obj-type~
              and ub.stk-line.obj-code = temp-obj.obj-code":U /* search-suffix   */
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при переименовании артикула и(или) производителя товара в таблице &2&3&4&3&5"
                                    ,vss-workfile
                                    ,{&table_stk-line}
                                    ,{&new-line}
                                    ,error-status :get-message(1)
                                    ,return-value
                                  ) .
    end.


    /*-----------------------------------------------------------------------*/
    /* в товаре артикул переименовывается в последнюю очередь */
    run waitfram-show in this-procedure
      ( input substitute( 'Переименование артикула &1 и(или) производителя &2 &3 товара. Обработка таблицы: &4'
                          ,old-artic
                          ,old-prod-type
                          ,old-prod-code
                          ,{&table_goods}
                        )
      ).
    run ren-artic in this-procedure
      ( input {&table_goods}
      ,input old-gds-key-rec
      ,input old-artic
      ,input old-prod-type
      ,input old-prod-code
      ,input new-artic
      ,input new-prod-type
      ,input new-prod-code
      ,input "":U /* search-bufs   */
      ,input "":U /* search-prefix */
      ,input "":U /* search-suffix */
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при переименовании артикула и(или) производителя товара в таблице &2&3&4&3&5"
                                    ,vss-workfile
                                    ,{&table_goods}
                                    ,{&new-line}
                                    ,error-status :get-message(1)
                                    ,return-value
                                  ) .
    end.

    run waitfram-show in this-procedure
      ( input substitute( 'Переименование артикула &1 и(или) производителя &2 &3 товара. Запись истории.'
                          ,old-artic
                          ,old-prod-type
                          ,old-prod-code
                        )
      ).

    run goodsh_write-goods-proc in this-procedure
      ( buffer buf_rename_goods
      ,input integer({&hn-update})
      ,input "":U /* p-source-type */
      ,input "":U /*p-source-ref  */
      ) .

    run waitfram-show in this-procedure
      ( input substitute( 'Переименование артикула &1 и(или) производителя &2 &3 товара. Корректировка атрибута производителя.'
                          ,old-artic
                          ,old-prod-type
                          ,old-prod-code
                        )
      ).
    run update-clients-prod in this-procedure .

  end.

  run waitfram-hide in this-procedure .

  return .

end.

procedure update-clients-prod :

  do
  on error undo, return error return-value
  :
    define buffer buf_clients for ub.clients .
    define buffer buf_goods for ub.goods .

    find buf_clients
      where buf_clients.obj-type = new-prod-type
        and buf_clients.obj-code = new-prod-code
    no-error  .
    if not avail buf_clients
    then
       return error substitute( "Производитель с типом &1 и кодом &2 НЕ СУЩЕСТВУЕТ!", new-prod-type, new-prod-code ) .
    if buf_clients.is-prod <> true
    then do:
      assign
        buf_clients.is-prod = true
      .
    end.

    if not can-find( first buf_goods no-lock
      where buf_goods.prod-type = old-prod-type
        and buf_goods.prod-code = old-prod-code
    )
    then do:
      find buf_clients
        where buf_clients.obj-type = old-prod-type
          and buf_clients.obj-code = old-prod-code
        .
      assign
        buf_clients.is-prod = false
      .
    end.
  end.

end procedure. /* update-clients-prod */
