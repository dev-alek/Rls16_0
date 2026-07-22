
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Динамическое создание записи маршрутизации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/05
Author: Dmitry Ukhanov
Creation date: 03/23/05

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table t-raw no-undo
  field t-raw-field as raw
.

procedure cre-raw :
  define input  parameter p-tbl-name   as character no-undo.
  define input  parameter p-tbl-handle as handle    no-undo.
  define output parameter p-raw        as raw       no-undo.

  define variable bh_t-raw        as handle    no-undo .
  define variable v-ok            as logical   no-undo .
  define variable v-msg           as character no-undo .

  /* 21/II-2019  При удалении полей из БД на их месте остаются "дыры".
                 Новые поля добавляются в хвост, "дыры" не используются.
                 В итоге raw-transfer с буффера БД, в котором удалили третье поле,
                 содержит "дыру": |1|2||3|
                 Во временных таблицах, определённые через like, "дыры" отсутствуют.
                 Поэтому в raw-transfer с буффера временной таблицы "дыра" отсутствует: |1|2|3|
                 Несовпадение в "дырах" приводит к ошибке
                 Table signatures do not match in RAW-TRANSFER operation. (4955)

000020311, "RAW-TRANSFER error 4955 between temp-table and database table" 
https://knowledgebase.progress.com/articles/Article/P31686

000001160, "4GL. Signatures, RAW-TRANSFER, Temp Tables and How they Interact"                 
https://knowledgebase.progress.com/articles/Article/18430?popup=true

                 Создание временных таблиц для промежуточного хранения копируемого буффера пришлось вернуть.                  
  */
    define variable tth             as handle    no-undo .
    define variable tt-name         as character no-undo .
    define variable bh_tt           as handle    no-undo .

  do
  on error  undo, throw
  :
    create temp-table tth.
    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-handle:table
    .
    v-ok = tth:create-like( p-tbl-handle ) .
    v-ok = tth:temp-table-prepare( tt-name ) .
    bh_tt = tth:default-buffer-handle .
    v-ok = bh_tt:buffer-create .
    v-ok = bh_tt:buffer-copy( p-tbl-handle ) .
    
    empty temp-table t-raw .
    create t-raw.
    bh_t-raw = buffer t-raw:handle .
    v-ok =        bh_tt:raw-transfer ( true, bh_t-raw:buffer-field("t-raw-field":U) ) .
    p-raw = t-raw.t-raw-field .
    
/* 30/I-2019 - заменено на raw-transfer из входного параметра    
  on error  undo, return error substitute( "&1 (cre-raw). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-raw). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-raw). endkey", vss-include-info{&vssseq} )
  :
    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh_tt           as handle    no-undo .

    define variable bh_t-raw        as handle    no-undo .

    define variable v-ok            as logical   no-undo .
    define variable v-msg           as character no-undo .

    if not p-tbl-handle:available then do:
      return error substitute( "&1. Переданый буфер таблицы &2 не доступен", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    create temp-table tth.
    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-handle :table
/*      tt-name  = "tt_" + p-tbl-name */
    .
    assign
/*      v-ok = tth:create-like( "ub." + p-tbl-name ) no-error вообще пока нет возможности вытащить из route-dump записи которые не like ub., но будем стремиться к этому */
      v-ok = tth:create-like( p-tbl-handle ) no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (1)&3&4", vss-include-info{&vssseq}, tt-name, {&new-line}, error-status :get-message(1) ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (2)&3&4", vss-include-info{&vssseq}, tt-name, {&new-line}, error-status :get-message(1) ) .
    end.

    assign
      bh_tt = tth:default-buffer-handle
    .

    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. Ошибка при создании буфера временной таблицы &2&3&4", vss-include-info{&vssseq}, tt-name, {&new-line}, error-status :get-message(1) ).
    end.
    assign
      v-ok = bh_tt:buffer-copy( p-tbl-handle ) no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. buffer-copy не прошел для таблицы &2&3&4", vss-include-info{&vssseq}, tt-name, {&new-line}, error-status :get-message(1) ).
    end.

    create t-raw.
    assign
      bh_t-raw = buffer t-raw:handle
    .
    assign
      v-ok = bh_tt:raw-transfer ( true, bh_t-raw:buffer-field("t-raw-field":U) ) no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      assign
        v-ok  = false
        v-msg = substitute( "&1. raw-transfer не прошел для таблицы &2&3&4", vss-include-info{&vssseq}, tt-name, {&new-line}, error-status :get-message(1) )
      .
    end.
    assign
      p-raw = t-raw.t-raw-field
    .
    delete t-raw.
    if v-ok <> true then do:
      return error v-msg.
    end.

    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. Ошибка при очистке временной таблицы &2&3&4", vss-include-info{&vssseq}, tt-name, {&new-line}, error-status :get-message(1) ) .
    end.

    delete object tth.
*/

  catch exAppErrors as class Progress.Lang.AppError :
    v-msg = substitute( "&1 (cre-raw). raw-transfer не прошел для таблицы &2&3&4&3&5",
      vss-include-info{&vssseq},
      p-tbl-name,
      {&new-line},
      error-status:get-message (error-status:num-messages),
      exAppErrors:CallStack
    ) .
    undo, throw new Progress.Lang.AppError(v-msg)  .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    undo, throw exProErrors .
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
/*      Msg = "Unexpected error occurred..." .*/
    undo, throw exAnyErrors .
  end catch .
  finally :
    empty temp-table t-raw .
    v-ok = tth:clear() no-error .
    delete object tth.
  end finally .

  end.
end procedure.

procedure cre-raw-delta :
  define input  parameter p-tbl-name       as character no-undo.
  define input  parameter p-old-raw        as raw       no-undo.
  define input  parameter p-new-buf-handle as handle    no-undo.
  define output parameter p-raw            as raw       no-undo.

  do
  on error  undo, return error substitute( "&1 (cre-raw-delta). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-raw-delta). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-raw-delta). endkey", vss-include-info{&vssseq} )
  :
    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh-dlt_tt       as handle    no-undo .
    define variable bh-old_tt       as handle    no-undo .

    define variable bh_t-raw        as handle    no-undo .

    define variable v-num-fields    as integer   no-undo .
    define variable v-ind           as integer   no-undo .
    define variable v-name-field    as character no-undo .
    define variable v-fh-tt         as handle    no-undo .
    define variable v-fh-old        as handle    no-undo .
    define variable v-fh-new        as handle    no-undo .

    define variable v-ok            as logical   no-undo .

    if not p-new-buf-handle:available then do:
      return error substitute( "&1 (cre-raw-delta). Переданый буфер с новым значением таблицы &2 не доступен", vss-include-info{&vssseq}, p-tbl-name ).
    end.
    if p-old-raw = ?
/*      or p-old-raw = "":U*/
    then do:
      return error substitute( "&1 (cre-raw-delta). Переданый буфер со старым значением таблицы &2 не доступен", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    create temp-table tth.

    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-name
    .
    assign
      v-ok = tth:create-like( p-new-buf-handle ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании временной таблицы &2 (1)", vss-include-info{&vssseq}, tt-name ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании временной таблицы &2 (2)", vss-include-info{&vssseq}, tt-name ) .
    end.

    assign
      bh-dlt_tt = tth:default-buffer-handle
    .

    assign
      v-ok = bh-dlt_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании буфера временной таблицы для новых значений.", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    create buffer bh-old_tt for table tth.
    assign
      v-ok = bh-old_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). Ошибка при создании буфера временной таблицы для старых значений.", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    create t-raw.
    assign
      t-raw.t-raw-field = p-old-raw
      bh_t-raw          = buffer t-raw:handle
    .
    assign
      v-ok = bh-old_tt:raw-transfer ( false, bh_t-raw:buffer-field("t-raw-field":U) ) no-error
    .
    delete t-raw.
    if v-ok <> true then do:
      return error substitute( "&1 (cre-raw-delta). raw-transfer не прошел для таблицы &2 со старыми значениями", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      v-num-fields = p-new-buf-handle:num-fields
    .
    do v-ind = 1 to v-num-fields
    on error undo, return error substitute( "&1 (cre-raw-delta). &2", vss-include-info{&vssseq}, error-status :get-message ( 1 ) )
    :
      assign
        v-fh-new     = p-new-buf-handle:buffer-field( v-ind )
        v-name-field = v-fh-new:name
        v-fh-old     = bh-old_tt:buffer-field( v-name-field )
        v-fh-tt      = bh-dlt_tt:buffer-field( v-name-field )
      .
      /*v-fh-new:buffer-value <> v-fh-new:initial возможно*/
      if v-fh-new:buffer-value <> v-fh-old:buffer-value then do:
        assign
          bh-dlt_tt:buffer-field( v-name-field ):buffer-value = v-fh-new:buffer-value
        .
      end.
    end.

    create t-raw.
    assign
      bh_t-raw = buffer t-raw:handle
    .
    assign
      v-ok = bh-dlt_tt:raw-transfer ( true, bh_t-raw:buffer-field("t-raw-field":U) ) no-error
    .
    assign
      p-raw = t-raw.t-raw-field
    .
    delete t-raw.
    if v-ok <> true then do:
      return error substitute( "&1. raw-transfer не прошел для таблицы &2", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при очистке временной таблицы &2", vss-include-info{&vssseq}, tt-name ) .
    end.

    delete object bh-old_tt no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении ссылки на буфер временной таблицы &2", vss-include-info{&vssseq}, tt-name ).
    end.
    delete object tth no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении временной таблицы для &2", vss-include-info{&vssseq}, tt-name ).
    end.

  end.

end procedure.

PROCEDURE cre-route-dump :
  define input        parameter p-act-name   as character           no-undo .
  define input        parameter p-tbl-name   as character           no-undo.
  define input        parameter p-tbl-handle as handle              no-undo.
  define input        parameter p-dmp-ord    like ub.route.dump-ord no-undo.
  define input-output parameter p-rc-ord     as integer             no-undo.

  do transaction
  on error  undo, return error substitute( "&1 (cre-route-dump). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (cre-route-dump). stop", vss-include-info{&vssseq} )
  on endkey undo, return error substitute( "&1 (cre-route-dump). endkey", vss-include-info{&vssseq} )
  :
    define variable loc-key-rec like ub.route.uniq-key-rec   no-undo .
    define variable v-value-rec like ub.route-dump.value-rec no-undo .

    define variable bh_tbl-name  as handle    no-undo .
    define variable fh_tbl-name  as handle    no-undo .

    define variable v-ok         as logical   no-undo .

    define buffer buf_sys-ctrl for ub.sys-ctrl .

    if not p-tbl-handle:available then do:
      return error substitute( "&1. Переданый буфер таблицы &2 не доступен", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      p-rc-ord = p-rc-ord + 1
    .
    run gen-key-rec in this-procedure
      ( input p-tbl-name
       ,input p-tbl-handle
       ,output loc-key-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при генерации уникального ключа по таблице &2. &3"
                               ,vss-include-info{&vssseq}
                               ,p-tbl-name
                               ,return-value
                             ).
    end.

    run cre-raw in this-procedure
      ( input p-tbl-name
       ,input p-tbl-handle
       ,output v-value-rec
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при сжатии записи по таблице &2. &3"
                               ,vss-include-info{&vssseq}
                               ,p-tbl-name
                               ,return-value
                             ).
    end.
    case p-act-name :
      when {&send-tbl} then do:
        create buffer bh_tbl-name for table "ub.route-dump":U .
      end.
      when {&send-tbl-oxml}
      then do:
        create buffer bh_tbl-name for table "ub.esys-route-dump":U .
      end.
    end case.

    assign
      v-ok = bh_tbl-name:buffer-create no-error
    .
    if v-ok <> true
      or error-status :error
    then do:
      return error substitute( "&1. Ошибка при создании буфера таблицы маршрутизации &2&3&4.", vss-include-info{&vssseq}, p-tbl-name, {&new-line}, error-status :get-message(1) ).
    end.

    case p-act-name :
      when {&send-tbl} then do:
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("dump-name":U)
          fh_tbl-name:buffer-value = p-tbl-name
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("dump-ord":U)
          fh_tbl-name:buffer-value = p-dmp-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("rec-ord":U)
          fh_tbl-name:buffer-value = p-rc-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("uniq-key-rec":U)
          fh_tbl-name:buffer-value = loc-key-rec
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("value-rec":U)
          fh_tbl-name:buffer-value = v-value-rec
        .
        { nws/route-dw.i
          p-tbl-name
          bh_tbl-name
          p-tbl-handle
          p-dmp-ord
          p-rc-ord
          no-error
        }
        if error-status :error then do:
          return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ).
        end.
      end.
      when {&send-tbl-oxml}
      then do:
        find first buf_sys-ctrl no-lock .
/*        esrd-action*/
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-cr-db-num":U)
          fh_tbl-name:buffer-value = buf_sys-ctrl.db-num
          .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-dump-name":U)
          fh_tbl-name:buffer-value = p-tbl-name
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-dump-ord":U)
          fh_tbl-name:buffer-value = p-dmp-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-rec-ord":U)
          fh_tbl-name:buffer-value = p-rc-ord
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-uniq-key-rec":U)
          fh_tbl-name:buffer-value = loc-key-rec
        .
        assign
          fh_tbl-name              = bh_tbl-name:buffer-field("esrd-value-rec":U)
          fh_tbl-name:buffer-value = v-value-rec
        .
      end.
    end case.

    delete object bh_tbl-name.

  end.

END PROCEDURE.

/* $Workfile$ e n d */