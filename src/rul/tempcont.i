/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контейнер для динамических временных таблиц, сслыки на которые сами хранятся в статической временной таблице temp-tables

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/13/07
Author: Bakhtadze Natalya
Creation date: 03/13/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable tempcont_v-num_ as integer no-undo .

define {1} temp-table temp-tables no-undo
field tbl-name as character
field new-tbl-handle as handle
field new-table-handle as handle
index pi is unique primary
tbl-name.

define {1} temp-table temp-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.


procedure tempcont_create-changes :
define input  parameter p-tbl-name   as character no-undo.
define input  parameter p-tbl-handle as handle    no-undo.
define input  parameter p-ttbl-handle as handle    no-undo.
define input  parameter p-action as integer no-undo .
define variable v-chg-fields as character no-undo .
define variable v-ii as integer no-undo .
define variable fh-main as handle no-undo .
define variable fh-temp as handle no-undo .
define variable fh as handle no-undo .
define variable th as handle no-undo .
define variable v-main-value as character no-undo .
define variable v-temp-value as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ind as integer no-undo .
define variable v-keys as character no-undo .

if p-tbl-handle:available then do:
  if p-tbl-handle:buffer-compare( p-ttbl-handle) = yes then return.
end.
do v-ii = 1 to min(p-tbl-handle:num-fields, p-ttbl-handle:num-fields):
  assign
  fh-main      = p-tbl-handle:buffer-field( v-ii )
  fh-temp      = p-ttbl-handle:buffer-field( v-ii )
  .
  if fh-main:name = fh-temp:name
  and fh-main:data-type = fh-temp:data-type then do:
    if fh-main:buffer-value ne fh-temp:buffer-value then do:
      if p-action = integer({&hn-create}) then do:
        assign
        fh = fh-temp
        th = p-ttbl-handle
        v-main-value = fh-main:initial
        v-keys  = p-ttbl-handle:keys
        .
      end.
      else do:
        assign
        fh = fh-main
        th = p-tbl-handle
        v-main-value = fh-main:string-value
        v-keys  = p-tbl-handle:keys
        .
      end.
      assign
      v-temp-value = fh-temp:string-value
     .
     if v-uniq-key-rec = '':U then do:
        v-uniq-key-rec = p-tbl-name.
        do v-ind = 1 to num-entries(v-keys)
        on error undo, return error
        :
          assign
          fh = th:buffer-field(entry(v-ind, v-keys))
          v-uniq-key-rec = v-uniq-key-rec + {&delim-key} + substitute("&1", fh:buffer-value())
          .
        end.
      end.
      create temp-changes.
      assign
      temp-changes.t_name = p-tbl-name
      temp-changes.f_name = fh-main:name
      temp-changes.l_name = '':U
      temp-changes.v_old  = v-main-value
      temp-changes.v_new  = v-temp-value
      temp-changes.action = p-action
      temp-changes.uniq-key-rec = v-uniq-key-rec
      temp-changes.num_   = tempcont_v-num_ + 1
      tempcont_v-num_     = tempcont_v-num_ + 1
      .
    end.
  end.
end. /*do v-ii = 1 to min(p-tbl-handle:num-fields, p-ttbl-handle:num-fields):*/
end procedure.


procedure tempcont_create-record :
define input  parameter p-tbl-name   as character no-undo.
define input  parameter p-new-tbl-handle as handle    no-undo.
define input  parameter p-action as integer no-undo .

do
on error  undo, return error substitute( "&1 (tempcont_create-record). &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1 (tempcont_create-record). stop", vss-include-info{&vssseq} )
on endkey undo, return error substitute( "&1 (tempcont_create-record). endkey", vss-include-info{&vssseq} )
:
  define variable tt-name          as character no-undo .
  define variable tth              as handle    no-undo .
  define variable bh_tt            as handle    no-undo .
  define variable v-ok             as logical   no-undo .
  define variable v-full-tbl-name  as character no-undo .
  define variable v-inform         as character no-undo .
  define variable v-ind            as integer   no-undo .
  define variable v-idx-field-qnty as integer   no-undo .
  define variable v-where          as character no-undo .
  define variable v-word-link      as character no-undo .
  define variable v-field-name     as character no-undo .
  define variable fh_tbl-name      as handle    no-undo .
  define variable fh_tt            as handle    no-undo .
  define variable v-field-val      as character no-undo .
  define variable compare-log      as logical no-undo .
  define buffer buf_temp-tables  for temp-tables.

  if not p-new-tbl-handle:available then do:
    return error substitute( "&1. Переданный буфер таблицы &2 не доступен", vss-include-info{&vssseq}, p-tbl-name ).
  end.

  assign
    v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
  .
  find first buf_temp-tables where
            buf_temp-tables.tbl-name = p-tbl-name no-error .
  if not available buf_temp-tables then do:
    /* создаем временную таблицу */
    create temp-table tth.

    assign
      tt-name = "wt-" + p-tbl-name
      tth:undo = no
    .
    v-ok = yes.
    assign
      v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании временной таблицы &2 (1)", vss-include-info{&vssseq}, tt-name ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании временной таблицы &2 (2)", vss-include-info{&vssseq}, tt-name ) .
    end.
    create buf_temp-tables.
    assign
    buf_temp-tables.tbl-name = p-tbl-name
    buf_temp-tables.new-tbl-handle = tth:default-buffer-handle
    buf_temp-tables.new-table-handle = tth
    .
    assign
    bh_tt = buf_temp-tables.new-tbl-handle
    .
  end. /*if not available buf_temp-tables then do:*/
  else do:
    if p-new-tbl-handle:table-handle = buf_temp-tables.new-tbl-handle:table-handle then do:
      assign
      bh_tt = p-new-tbl-handle
      .
    end.
    else do:
      assign
      bh_tt = buf_temp-tables.new-tbl-handle
      .
    end.
  end.
  /* проверим нет ли такой записи во временной таблице */
  assign
  v-inform = bh_tt:index-information(1)
  v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = bh_tt:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.

  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1 (tempcont_create-record). Таблица &2 не имеет первичного ключа в БД", vss-include-info{&vssseq}, p-tbl-name ).
  end.

  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1 (tempcont_create-record). Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, p-tbl-name ).
  end.

  assign
    v-where     = "where":U
    v-word-link = "":U
  .
  block_where:
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :

    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh_tbl-name  = bh_tt:buffer-field( v-field-name )
      fh_tt        = p-new-tbl-handle:buffer-field( v-field-name )
      v-field-val  = fh_tt:buffer-value
      v-where      = substitute( "&1 &2 &3.&4 =", v-where, v-word-link, fh_tbl-name:table, v-field-name )
    .
    if fh_tbl-name:data-type ="character":U then do:
        assign
        v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
        v-field-val = replace( v-field-val, '"':U, '~~"':U )
        v-field-val = replace( v-field-val, "'":U, "~~'":U )
        v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
        v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
        v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
        v-field-val = replace( v-field-val, chr(10), '~~n':U )
        v-field-val = replace( v-field-val, chr(9), '~~t':U )
        v-field-val = replace( v-field-val, chr(13), '~~r':U )
        v-field-val = replace( v-field-val, chr(27), '~~E':U )
        v-field-val = replace( v-field-val, chr(8), '~~b':U )
        v-field-val = replace( v-field-val, chr(12), '~~f':U )
        v-field-val = substitute( '"&1"', v-field-val )
        .
    end.
    assign
      v-where = substitute( "&1 &2", v-where, v-field-val )
    .
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.

  end.

  bh_tt:find-first( v-where, exclusive-lock ) no-error .

  if not bh_tt:available then do:
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании буфера временной таблицы.", vss-include-info{&vssseq}, p-tbl-name ).
    end.
    assign
      compare-log = false
    .
  end.
  else do:
    assign
      compare-log = bh_tt:buffer-compare( p-new-tbl-handle )
    .
  end.
  if compare-log = false then do:
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-copy( p-new-tbl-handle ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). BUFFER-COPY не прошел для таблицы &2", vss-include-info{&vssseq}, p-tbl-name ).
    end.
  end.

  assign
    v-ok = false
  .
  assign
    v-ok = bh_tt:buffer-release() no-error
  .
  if v-ok <> true then do:
    return error substitute( "&1 (tempcont_create-record). buffer-release не прошел для таблицы &2", vss-include-info{&vssseq}, p-tbl-name ).
  end.

  assign
    v-ok = false
  .
  assign
    fh_tbl-name  = ?
    fh_tt        = ?
    bh_tt        = ?
  .
end.

end procedure. /* tempcont_create-record */

procedure tempcont_get-buffer-handle :
define input parameter p-tbl-name as character no-undo .
define output parameter p-new-tbl-handle as handle no-undo .
do
on error undo, return error
:
  define variable tth              as handle    no-undo .
  define variable tt-name          as character no-undo .
  define variable v-ok             as logical   no-undo .
  define variable v-full-tbl-name  as character no-undo .
  define buffer buf_temp-tables  for temp-tables.
  find first buf_temp-tables where
           buf_temp-tables.tbl-name = p-tbl-name no-error .
  if not available buf_temp-tables then do:
    /* создаем временную таблицу */
    create temp-table tth.

    assign
    tt-name = "wt-" + p-tbl-name
    tth:undo = no
    v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .
    v-ok = yes.
    assign
    v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_get-buffer-handle). Ошибка при создании временной таблицы &2 (1)", vss-include-info{&vssseq}, tt-name ) .
    end.

    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_get-buffer-handle). Ошибка при создании временной таблицы &2 (2)", vss-include-info{&vssseq}, tt-name ) .
    end.
    create buf_temp-tables.
    assign
    buf_temp-tables.new-table-handle = tth
    buf_temp-tables.tbl-name = p-tbl-name
    buf_temp-tables.new-tbl-handle = tth:default-buffer-handle
    .
  end. /*if not available buf_temp-tables then do:*/
  p-new-tbl-handle = buf_temp-tables.new-tbl-handle.
end.

end procedure. /* tempcont_get-buffer-handle */

procedure tempcont_clear :
define buffer buf_temp-tables for temp-tables.
do
on error undo, return error return-value
:
  for each buf_temp-tables:
    if valid-handle(buf_temp-tables.new-table-handle) then do:
      buf_temp-tables.new-tbl-handle:empty-temp-table().
    end.
    delete object buf_temp-tables.new-table-handle.
  end.

end.

end procedure. /* tempcont_clear */


/* $Workfile$ e n d */