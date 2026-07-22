block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для работы с записями goods

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "библиотека для работы с записями goods".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ cmp/tbl-name.i }
{ gbl/key-rec.i  }
{ gbl/cur-time.i }

procedure comm-ren-art :
  define input  parameter pc-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pc-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pc-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pc-parameters   as   character                   no-undo .
  define output parameter pc-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_goods        for ub.goods .
    define buffer buf-check_goods  for ub.goods .
    define buffer buf_BatchProcess for ub.BatchProcess .

    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .

    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .

    run gen-row-keyr in this-procedure
      ( input  pc-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. &3 &4", vss-workfile, pc-uniq-key-rec, {&new-line}, return-value ).
    end.
    if v-tbl-name <> {&table_goods} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей товаров", vss-workfile ).
    end.

    find first buf_goods exclusive-lock
      where rowid( buf_goods ) = v-rowid
      no-error .

    if not available buf_goods then do:
      return error substitute( "&1. Нет необходимого товара &2", vss-workfile, pc-uniq-key-rec ).
    end.
    assign
      v-gds-code      = integer( entry( 1, pc-parameters, {&delim-par} ) )
      v-old-artic     = entry( 2, pc-parameters, {&delim-par} )
      v-old-prod-type = entry( 3, pc-parameters, {&delim-par} )
      v-old-prod-code = integer( entry( 4, pc-parameters, {&delim-par} ) )
      v-new-artic     = entry( 5, pc-parameters, {&delim-par} )
      v-new-prod-type = entry( 6, pc-parameters, {&delim-par} )
      v-new-prod-code = integer( entry( 7, pc-parameters, {&delim-par} ) )
    .
    if v-old-artic        = v-new-artic
      and v-old-prod-type = v-new-prod-type
      and v-old-prod-code = v-new-prod-code
    then do:
      assign
        pc-err-msg = substitute( "Новый артикул &1 производитель &2 &3 должен отличаться от старого. Блокировка невозможна!!!"
                                  ,v-new-artic
                                  ,v-new-prod-type
                                  ,v-new-prod-code
                                )
      .
    end.
    else do:
      if buf_goods.artic = v-old-artic
        and buf_goods.prod-type = v-old-prod-type
        and buf_goods.prod-code = v-old-prod-code
      then do:
        find first buf-check_goods no-lock
          where buf-check_goods.artic     = v-new-artic
            and buf-check_goods.prod-type = v-new-prod-type
            and buf-check_goods.prod-code = v-new-prod-code
            and rowid( buf-check_goods ) <> v-rowid
          no-error
        .
        if available buf-check_goods then do:
          assign
            pc-err-msg = substitute( "Уже существует товар с артикулом &1 производителя &2 &3. Блокировка невозможна!!!"
                                    ,buf-check_goods.artic
                                    ,buf-check_goods.prod-type
                                    ,buf-check_goods.prod-code
                                  )
          .
        end.
        else do:
          { trg/btpr_upd.i
            &btpr-status="find"
            &btpr-type="{&btpr-type-ren-art}"
            &btpr-table="buf_BatchProcess"
            &btpr-lock-option="exclusive-lock"
            &charkey_one=v-new-artic
            &charkey_two=v-new-prod-type
            &key#_one=v-new-prod-code
          }
          if available buf_BatchProcess then do:
            assign
              pc-err-msg = substitute( "Уже идет операция в результате которой появится товар с артикулом &1 производителем &2 &3. Блокировка невозможна!!!"
                                      ,v-new-artic
                                      ,v-new-prod-type
                                      ,v-new-prod-code
                                    )
            .
          end.
          else do:
            if buf_goods.stts = integer({&current-status-int}) then do:
              assign
                buf_goods.stts = integer({&befor-artic-change-int})
              .
              { trg/btpr_upd.i
                &btpr-status="create"
                &btpr-type="{&btpr-type-ren-art}"
                &charkey_one=v-old-artic
                &charkey_two=v-old-prod-type
                &charkey_tree="old-artic":U
                &key#_one=v-old-prod-code
              }
              { trg/btpr_upd.i
                &btpr-status="create"
                &btpr-type="{&btpr-type-ren-art}"
                &charkey_one=v-new-artic
                &charkey_two=v-new-prod-type
                &charkey_tree="new-artic":U
                &key#_one=v-new-prod-code
              }
            end.
            else do:
              assign
                pc-err-msg = substitute( "Товар &1 уже заблокирован или удален!!! Блокировка невозможна!!!", pc-uniq-key-rec )
              .
            end.
          end.
        end.
      end.
      else do:
        return error substitute( "&1. Обнаружено фатальное отличие товаров", vss-workfile )
                    + {&new-line}
                    + substitute( "Должно быть: артикул &1 производитель &2 &3", v-old-artic
                                                                                , v-old-prod-type
                                                                                , v-old-prod-code )
                    + {&new-line}
                    + substitute( "В текущей БД: артикул &1 производитель &2 &3", buf_goods.artic
                                                                                , buf_goods.prod-type
                                                                                , buf_goods.prod-code )
        .
      end.
    end.
  end.
  return.
end procedure. /* comm-ren-art */

procedure exec-ren-art :
  define input  parameter pe-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pe-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pe-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pe-parameters   as   character                   no-undo .
  define output parameter pe-err-msg      as   character                   no-undo .

  do
  on error undo, return error return-value
  :
    define buffer buf_goods     for ub.goods .
    define buffer buf-new_goods for ub.goods .

    define variable v-rowid            as rowid     no-undo .
    define variable v-tbl-name         as character no-undo .

    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .
    define variable v-error-message as   character          no-undo .

    run gen-row-keyr in this-procedure
      ( input  pe-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. {&new-line} &3", vss-workfile, pe-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> {&table_goods} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей товаров", vss-workfile ).
    end.

    find first buf_goods
      where rowid( buf_goods ) = v-rowid
      no-error .

    if not available buf_goods then do:
      return error substitute( "&1. Нет необходимого товара &2", vss-workfile, pe-uniq-key-rec ).
    end.

    if buf_goods.stts <> integer({&befor-artic-change-int}) then do:
/*      assign*/
/*        pe-err-msg = substitute( "&1. Товар &2 не заблокирован для переименования артикула", vss-workfile, pe-uniq-key-rec )*/
/*      .*/
      return error substitute( "&1. Товар &2 не заблокирован для переименования артикула", vss-workfile, pe-uniq-key-rec ).
    end.

    assign
      v-gds-code      = integer( entry( 1, pe-parameters, {&delim-par} ) )
      v-old-artic     = entry( 2, pe-parameters, {&delim-par} )
      v-old-prod-type = entry( 3, pe-parameters, {&delim-par} )
      v-old-prod-code = integer( entry( 4, pe-parameters, {&delim-par} ) )
      v-new-artic     = entry( 5, pe-parameters, {&delim-par} )
      v-new-prod-type = entry( 6, pe-parameters, {&delim-par} )
      v-new-prod-code = integer( entry( 7, pe-parameters, {&delim-par} ) )
    .
    run utl/ren-art.p
      (input  v-gds-code      /* old-gds-code  */
      ,input  v-old-artic     /* old-artic     */
      ,input  v-old-prod-type /* old-prod-type */
      ,input  v-old-prod-code /* old-prod-code */
      ,input  v-new-artic     /* new-artic     */
      ,input  v-new-prod-type /* new-prod-type */
      ,input  v-new-prod-code /* new-prod-code */
      ) no-error.
    if error-status :error then do:
/*      assign*/
/*        pe-err-msg = substitute( "&1. Артикул товара &2 не изменен: &3&4&5", vss-workfile, pe-uniq-key-rec, v-error-message, {&new-line}, return-value )*/
/*      .*/
      return error substitute( "&1. Артикул товара &2 не изменен: &3&4&5", vss-workfile, pe-uniq-key-rec, v-error-message, {&new-line}, return-value ).
    end.

    if buf_goods.stts = integer({&befor-artic-change-int}) then do:
      assign
        buf_goods.stts = integer({&current-status-int})
      .
    end.

  end.
  return.
end procedure. /* exec-ren-art */

procedure rcvr-ren-art :
  define input  parameter pr-db-num       like ub.db-rec-attr.db-num       no-undo .
  define input  parameter pr-uniq-key-rec like ub.db-rec-attr.uniq-key-rec no-undo .
  define input  parameter pr-attr-code    like ub.db-rec-attr.attr-code    no-undo .
  define input  parameter pr-parameters   as   character                   no-undo .
  define output parameter pr-err-msg      as   character                   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_goods        for ub.goods .
    define buffer buf_BatchProcess for ub.BatchProcess .

    define variable v-rowid    as rowid     no-undo .
    define variable v-tbl-name as character no-undo .

    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .
    define variable v-error-message as   character          no-undo .

    run gen-row-keyr in this-procedure
      ( input  pr-uniq-key-rec
       ,input ?
       ,input "ub":U
       ,input ?
       ,input share-lock
       ,output v-rowid
       ,output v-tbl-name
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении rowid записи для ключа &2. {&new-line} &3", vss-workfile, pr-uniq-key-rec, return-value ).
    end.
    if v-tbl-name <> {&table_goods} then do:
      return error substitute( "&1. Данная процедура может работать только с таблицей товаров", vss-workfile ).
    end.

    find first buf_goods
      where rowid( buf_goods ) = v-rowid
      no-error .

    if not available buf_goods then do:
      return error substitute( "&1. Нет необходимого товара &2", vss-workfile, pr-uniq-key-rec ).
    end.

    assign
      v-gds-code      = integer( entry( 1, pr-parameters, {&delim-par} ) )
      v-old-artic     = entry( 2, pr-parameters, {&delim-par} )
      v-old-prod-type = entry( 3, pr-parameters, {&delim-par} )
      v-old-prod-code = integer( entry( 4, pr-parameters, {&delim-par} ) )
      v-new-artic     = entry( 5, pr-parameters, {&delim-par} )
      v-new-prod-type = entry( 6, pr-parameters, {&delim-par} )
      v-new-prod-code = integer( entry( 7, pr-parameters, {&delim-par} ) )
    .

    if buf_goods.artic = v-old-artic
      and buf_goods.prod-type = v-old-prod-type
      and buf_goods.prod-code = v-old-prod-code
    then do:
      /* переименовать не успели, значит ничего не будем делать */
    end.
    else do:
      if buf_goods.artic = v-new-artic
        and buf_goods.prod-type = v-new-prod-type
        and buf_goods.prod-code = v-new-prod-code
      then do:
        /* переименовываем назад */
        run utl/ren-art.p
          (input  v-gds-code      /* old-gds-code  */
          ,input  v-new-artic     /* old-artic     */
          ,input  v-new-prod-type /* old-prod-type */
          ,input  v-new-prod-code /* old-prod-code */
          ,input  v-old-artic     /* new-artic     */
          ,input  v-old-prod-type /* new-prod-type */
          ,input  v-old-prod-code /* new-prod-code */
          ) no-error.
        if error-status :error
          or return-value <> ""
        then do:
          return error substitute( "&1. Артикул и(или) производитель товара &2 не изменен: &3", vss-workfile, pr-uniq-key-rec, v-error-message ).
        end.
      end.
      else do:
        return error substitute( "&1. Артикул и(или) производитель товара &2 был изменен на &3 &4 &5. Это недопустимо!!!"
                                 ,vss-workfile
                                 ,pr-uniq-key-rec
                                 ,buf_goods.artic
                                 ,buf_goods.prod-type
                                 ,buf_goods.prod-code
                                ).
      end.
    end.

    if buf_goods.stts = integer({&befor-artic-change-int})
      or buf_goods.stts = integer({&artic-change-int})
    then do:
      assign
        buf_goods.stts = integer({&current-status-int})
      .
    end.

    { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="{&btpr-type-ren-art}"
      &btpr-table="buf_BatchProcess"
      &btpr-lock-option="exclusive-lock"
      &charkey_one=v-old-artic
      &charkey_two=v-old-prod-type
      &key#_one=v-old-prod-code
    }
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.
    { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="{&btpr-type-ren-art}"
      &btpr-table="buf_BatchProcess"
      &btpr-lock-option="exclusive-lock"
      &charkey_one=v-new-artic
      &charkey_two=v-new-prod-type
      &key#_one=v-new-prod-code
    }
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.


  end.
  return.
end procedure. /* rcvr-ren-art */

procedure after-ren-art :
  define input  parameter pa-action       as character no-undo .
  define input  parameter pa-uniq-key-rec as character no-undo .
  define input  parameter pa-db-init      as integer   no-undo .
  define input  parameter pa-parameters   as character no-undo .
  define output parameter pa-err-msg      as character no-undo .
  do
  on error undo, return error
  :
    define buffer buf_BatchProcess for ub.BatchProcess .

    define variable v-gds-code      like ub.goods.gds-code  no-undo .
    define variable v-old-artic     like ub.goods.artic     no-undo .
    define variable v-old-prod-type like ub.goods.prod-type no-undo .
    define variable v-old-prod-code like ub.goods.prod-code no-undo .
    define variable v-new-artic     like ub.goods.artic     no-undo .
    define variable v-new-prod-type like ub.goods.prod-type no-undo .
    define variable v-new-prod-code like ub.goods.prod-code no-undo .

    assign
      v-gds-code      = integer( entry( 1, pa-parameters, {&delim-par} ) )
      v-old-artic     = entry( 2, pa-parameters, {&delim-par} )
      v-old-prod-type = entry( 3, pa-parameters, {&delim-par} )
      v-old-prod-code = integer( entry( 4, pa-parameters, {&delim-par} ) )
      v-new-artic     = entry( 5, pa-parameters, {&delim-par} )
      v-new-prod-type = entry( 6, pa-parameters, {&delim-par} )
      v-new-prod-code = integer( entry( 7, pa-parameters, {&delim-par} ) )
    .

    { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="{&btpr-type-ren-art}"
      &btpr-table="buf_BatchProcess"
      &btpr-lock-option="exclusive-lock"
      &charkey_one=v-old-artic
      &charkey_two=v-old-prod-type
      &key#_one=v-old-prod-code
    }
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.
    { trg/btpr_upd.i
      &btpr-status="find"
      &btpr-type="{&btpr-type-ren-art}"
      &btpr-table="buf_BatchProcess"
      &btpr-lock-option="exclusive-lock"
      &charkey_one=v-new-artic
      &charkey_two=v-new-prod-type
      &key#_one=v-new-prod-code
    }
    if available buf_BatchProcess then do:
      delete buf_BatchProcess.
    end.
  end.
  return.
end procedure. /* after-ren-art */
/* $Workfile$ end */