block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ren-gdsc.p $
$Archive: utl/ren-gdsc.p $

Изменение gds-code для одного товара

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/19/05
Author: Dmitry Ukhanov
Creation date: 07/19/05

*/
/*
- Таблицы имеющие индекс в котором поле gds-code стоит первым добавляются только в список TABLE_LIST
- Таблицы в которых есть поле gds-code, но переименовывать его не надо добавляются только в список TABLE_IGNORE
- Таблицы в которых нет индекса с полем gds-code или необходима спецобработка записей добавляютс
  в список TABLE_SPECIAL. В этом случае спецобработка описывается отдельно.
*/

define input  parameter old-gds-code  like ub.goods.gds-code  no-undo .
define input  parameter new-gds-code  like ub.goods.gds-code  no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ren-gdsc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ren-gdsc.p $":U .
define variable vss-description as character no-undo init "Изменение gds-code для одного товара".
{ cmp/vssrevis.i "substitute('&1|&2':u,old-gds-code,new-gds-code)" }
{ cmp/trg-def.i  }
{ gbl/key-rec.i  }
{ gbl/cur-time.i }
{ trg/goodsh.i   }
{ gbl/waitfram.i }
{ utl/ren-gdsc.i }
{ utl/rgds-tbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on quit   undo, return error substitute( "&1. quit", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define buffer buf_rename_goods for ub.goods .
  define buffer b-goods for ub.goods .
  define buffer buf_lock_batchprocess for ub.batchprocess .

  define variable old-gds-key-rec like ub.route.uniq-key-rec  no-undo.
  define variable v-ind         as integer   no-undo .
  define variable v-num-entries as integer   no-undo .
  define variable v-tbl-name    as character no-undo .


  run gbl/lockrngd.p
    (input {&lock-prc-goods-rename-gds-code} /* p-lock-gds-type   */
    ,input {&lock-prc-subtype-enable}        /* p-sub-type        */
    ,buffer buf_lock_batchprocess            /* lock_batchprocess */
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при блокировании функции переименования кода товара&2&3&2&4"
                                  ,vss-workfile
                                  ,{&new-line}
                                  ,error-status :get-message(1)
                                  ,return-value
                                  ) .
  end.

  update_block:
  do transaction
  on error  undo update_block, return error substitute( "&1 (update_block). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo update_block, return error substitute( "&1 (update_block). stop", vss-workfile )
  on quit   undo update_block, return error substitute( "&1 (update_block). quit", vss-workfile )
  on endkey undo update_block, return error substitute( "&1 (update_block). endkey", vss-workfile )
  :
    find first buf_rename_goods exclusive-lock
      where buf_rename_goods.gds-code = old-gds-code
      no-error .
    if not available buf_rename_goods then do:
      if g#news
      then do:
        /* товар пришел уже с новым кодом */
        return.
      end.
      else do:
        return error "Товар не доступен".
      end.
    end.

    if buf_rename_goods.gds-code <> old-gds-code then do:
      return error substitute( "Товарa с gds-code &1 НЕСУЩЕСТВУЕТ! Переименование не возможно.", old-gds-code ) .
    end.

    if new-gds-code = old-gds-code then do:
      if g#news then do:
        /* товар пришел уже с новым кодом */
        return.
      end.
      else do:
        return error "Новый код товара должен отличаться от старого" .
      end.
    end.

    if can-find(first b-goods no-lock where b-goods.gds-code  = new-gds-code) then do:
      return error substitute( "Уже существует товар с кодом &1", new-gds-code ) .
    end.

    RUN gen-key-rec
      (input {&table_goods}
      ,input (buffer buf_rename_goods:handle)
      ,output old-gds-key-rec
      ).

    run waitfram-show in this-procedure
      (input 'Переименование кода товара ' + string( buf_rename_goods.gds-code )
      ).

    run invalidate-md5-signature in this-procedure .

    assign
      v-num-entries = num-entries( {&TABLE-RGDS_LIST} )
    .
    do v-ind = 1 to v-num-entries
    on error  undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). stop", vss-workfile )
    on quit   undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). quit", vss-workfile )
    on endkey undo update_block, return error substitute( "&1 (TABLE-RGDS_LIST). endkey", vss-workfile )
    :
      assign
        v-tbl-name = entry( v-ind, {&TABLE-RGDS_LIST} )
      .
      run waitfram-show in this-procedure
        ( input substitute( "Переименование кода товара &1. Обработка таблицы &2", old-gds-code, v-tbl-name )
        ).
      run ren-gds-code in this-procedure
        ( input v-tbl-name
         ,input old-gds-key-rec
         ,input old-gds-code
         ,input new-gds-code
         ,input "":U /* search-bufs   */
         ,input "":U /* search-prefix */
         ,input "":U /* search-suffix */
        ) no-error.
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при переименовании кода товара в таблице &2&3&4&3&5"
                                      ,vss-workfile
                                      ,v-tbl-name
                                      ,{&new-line}
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ) .
      end.
    end.

    /* товар переименовывается последним */
    run waitfram-show in this-procedure
      (input substitute( "Переименование кода товара &1. Обработка таблицы &2", old-gds-code, {&table_goods} )
      ).
    run ren-gds-code in this-procedure
      ( input {&table_goods}
       ,input old-gds-key-rec
       ,input old-gds-code
       ,input new-gds-code
       ,input "":U /* search-bufs   */
       ,input "":U /* search-prefix */
       ,input "":U /* search-suffix */
      ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при переименовании кода товара в таблице &2&3&4&3&5"
                                    ,vss-workfile
                                    ,{&table_goods}
                                    ,{&new-line}
                                    ,error-status :get-message(1)
                                    ,return-value
                                  ) .
    end.

    run waitfram-show in this-procedure
      (input substitute( "Переименование кода товара &1. Создание записи истории", old-gds-code )
      ).

    run goodsh_write-goods-proc in this-procedure
      ( buffer buf_rename_goods
       ,input integer({&hn-rename})
       ,input {&hn-source-ren-gdsc}  /* p-source-type */
       ,input string( old-gds-code ) /* p-source-ref  */
      ) .

  end.

  run waitfram-hide in this-procedure .

  return .
end.


procedure invalidate-md5-signature :

  define buffer buf_archive-history for ub.archive-history .

  do
  on error undo, return error return-value
  :
    define variable v-create-chip-num as integer   no-undo .

    for each buf_archive-history exclusive-lock
      where buf_archive-history.file-valid = true
    break
    by buf_archive-history.obj-type
    by buf_archive-history.obj-code
    by buf_archive-history.archive-type
    on error undo, return error return-value
    :
      if first-of(buf_archive-history.archive-type)
      then do:
        run utl/arhiscr.p
          (input  buf_archive-history.obj-type     /* p-obj-type              */
          ,input  buf_archive-history.obj-code     /* p-obj-code              */
          ,input  buf_archive-history.archive-type /* p-archive-type          */
          ,input  {&archive-history-ren-gds-code}  /* p-action-type           */
          ,input  ""                               /* p-file-name             */
          ,input  ""                               /* p-file-md5              */
          ,input  0                                /* p-file-invalid-chip-num */
          ,input  ""                               /* p-source-type           */
          ,input  ""                               /* p-source-ref            */
          ,input  ?                                /* p-source-date           */
          ,output v-create-chip-num                /* p-create-chip-num       */
          ) .
      end.

      assign
        buf_archive-history.file-valid            = false
        buf_archive-history.file-invalid-chip-num = v-create-chip-num
      .
    end.
  end.
end procedure. /* invalidate-md5-signature */