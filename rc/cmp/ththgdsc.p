block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththgdsc.p $
$Archive: cmp/ththgdsc.p $

Конвертация файла бар-код;цена из старой версии TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/27/10
Author: Bakhtadze Natalya
Creation date: 04/27/10

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththgdsc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththgdsc.p $":U .
define variable vss-description as character no-undo init "Конвертация файла бар-код,цена из старой версии TH".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ cmp/thth150.i }
{ cmp/thth14.i }


define variable p-from-version as character no-undo .
define variable glog as logical no-undo .
define variable f-name as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-full-path-2      as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable log-file-name as character no-undo .
define variable v-ii as integer no-undo .
define variable ss as character no-undo .
define variable ss-1 as character no-undo .
define variable ss-2 as character no-undo .
define variable v-ii-format-err as integer no-undo .
define variable v-ii-b-code-err as integer no-undo .
define variable v-ii-node-code-err as integer no-undo .
define variable v-ii-part-err as integer no-undo .
define variable v-ii-bind-err as integer no-undo .
define variable v-ii-cli-base-rate-err as integer no-undo .
define variable v-ii-nf-bar-code-err as integer no-undo .
define variable v-num-src-gds-prt as integer no-undo .
define variable v-num-gds-prt as integer no-undo .
define variable v-src-empty-scale  as integer no-undo .
define variable v-empty-scale  as integer no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-found as logical no-undo .
define variable v-classif-name as character no-undo .


define buffer src_bar-code for src.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer src_gds-prt for src.gds-prt.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_ext-classif for ub.ext-classif.
define stream sout .

define temp-table temp-items no-undo
field ss as character
field line-num as integer
field b-code-old as integer
field b-code-151 as integer
field gds-code-old as integer
field gds-code-151 as integer
field unit-cli-old as character
field cli-base-rate-old as decimal
field unit-cli-151 as character
field cli-base-rate-151 as decimal
field price as decimal
field notes as character
index
pi is unique primary
line-num.

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

if num-entries(p-parameter, {&delim-par}) <> 1 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 1"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.
assign
p-from-version = entry(1, p-parameter, {&delim-par})
.
case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th14}
    .
  end.
end case.


for each src_gds-prt no-lock:
  v-num-src-gds-prt = v-num-src-gds-prt + 1.
end.
if v-num-src-gds-prt >= 1 then do:
  find first src_gds-prt where
            src_gds-prt.node-name = {&empty-scale} .
  assign
  v-src-empty-scale = src_gds-prt.node-code.
end.
for each buf_gds-prt no-lock:
  v-num-gds-prt = v-num-gds-prt + 1.
end.
if v-num-gds-prt >= 1 then do:
  find first buf_gds-prt where
            buf_gds-prt.node-name = {&empty-scale} .
  assign
  v-empty-scale = src_gds-prt.node-code.
end.


system-dialog get-file f-name
title "Выберите файл"
filters "Текстовый файл (*.csv)"   "*.csv" ,
        "Текстовый файл (*.txt)"   "*.txt" ,
        "Список кодов   (*.bb)"    "*.bb" ,
        "Все файлы" "*.*"
INITIAL-DIR "."
return-to-start-dir
must-exist
/* use-filename */
update glog
default-extension "txt".


if not glog then do:
end.

/*очищаем все*/
log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).

&scop my-message  substitute("Чтение файла &1", f-name)
{&display-message}.

run gbl/filename.p
  (input  f-name
  ,output v-full-path         /* p-full-path        */
  ,output v-path              /* p-path             */
  ,output v-file-name         /* p-file-name        */
  ,output v-file-name-no-ext  /* p-file-name-no-ext */
  ,output v-file-name-ext     /* p-file-name-ext    */
  ) no-error .
if error-status:error then do:
  &scop my-message substitute("Не удалось найти файл &1", f-name)
  {&display-message}
  .
  return.
end.
else do:
  input stream sout from value (v-full-path).
  _repeat:
  repeat:
    import stream sout unformatted ss.
    v-ii = v-ii + 1.
    ss = trim (ss).
    if ss = "" then next.
    create temp-items.
    assign
    temp-items.ss = ss
    temp-items.line-num = v-ii
    .
    if num-entries(ss, ";") < 2 then do:
      assign
      temp-items.notes = "Количество элементов спика (разделитель ;) < 2"
      .
      release temp-items.
      next _repeat.
    end.

    assign
    ss-1 = trim(entry(1, ss, ";"))
    ss-2 = trim(entry(2, ss, ";"))
    .
    if trim(ss-1, "0123456789") <> '' then do:
      assign
      temp-items.notes = "Неверные символы в бар-коде".
      release temp-items.
      next _repeat.
    end.
    if trim(ss-1, "0123456789.") <> '' then do:
      assign
      temp-items.notes = "Неверные символы в цене".
      release temp-items.
      next _repeat.
    end.
    assign
    ss-1 = left-trim(ss-1, "0")
    .
    if length(ss-1) > 9 then do:
      assign
      temp-items.notes = "Бар-код не может содержать более 9 цифр".
      release temp-items.
      next _repeat.
    end.
    assign
    temp-items.b-code-old = integer(ss-1)
    no-error.
    if error-status:error then do:
      assign
      temp-items.notes = substitute( "Ошибка при конвертации строки бар-кода в целое:&1&2&1&3"
                                     , {&new-line}
                                     , error-status:get-message(1)
                                     , return-value ).
       release temp-items.
       next _repeat.
    end.
    assign
    temp-items.price = decimal(ss-2)
    no-error.
    if error-status:error then do:
      assign
      temp-items.notes = substitute( "Ошибка при конвертации строки цены в десятичное:&1&2&1&3"
                                     , {&new-line}
                                     , error-status:get-message(1)
                                     , return-value ).
       release temp-items.
       next _repeat.
    end.
  end. /*repeat:*/
  input stream sout close.
end.
&scop my-message  substitute("Проверка файла &1", f-name)
{&display-message}.
v-ii = 0.
_items1:
for each temp-items:
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
  &scop my-count-message substitute("Просмотрено &1", v-ii)
  {&display-count-message}.
  end.
  if temp-items.notes > '' then do:
    v-ii-format-err = v-ii-format-err + 1.
  end.
  else do:
    find first src_bar-code no-lock where
              src_bar-code.b-code = temp-items.b-code-old no-error.
    if not available src_bar-code then do:
      assign
      temp-items.notes = substitute("не найден в БД &2 бар-код = &1", temp-items.b-code-old, p-from-version).
      v-ii-b-code-err = v-ii-b-code-err + 1.
    end. /*  if not available src_bar-code then do:*/
    else do:
      assign
      temp-items.unit-cli-old = src_bar-code.unit-cli
      temp-items.gds-code-old = src_bar-code.gds-code
      temp-items.cli-base-rate-old = src_bar-code.cli-base-rate
      .
      if src_bar-code.node-code <> v-src-empty-scale then do:
        assign
        temp-items.notes = substitute("бар-код &1 &2 относится к шкальным бар-кодам", temp-items.b-code-old, p-from-version).
        v-ii-node-code-err = v-ii-node-code-err + 1.
        next _items1.
      end. /*if src_bar-code.node-code <> v-empty-scales-vold then do:*/
      if src_bar-code.in-code <> ''
      or src_bar-code.part-code <> ''
      then do:
        assign
        temp-items.notes = substitute("бар-код &1 &2 относится к партионным бар-кодам", temp-items.b-code-old, p-from-version).
        v-ii-part-err = v-ii-part-err + 1.
        next _items1.
      end. /*if src_bar-code.node-code <> v-empty-scales-vold then do:*/
      find first buf_ext-classif no-lock where
                buf_ext-classif.classif-subject = {&table_goods}
            and buf_ext-classif.classif-name = v-classif-name
            and buf_ext-classif.key#_one = temp-items.gds-code-old no-error.
      if not available buf_ext-classif then do:
        assign
        temp-items.notes = substitute("Не найдена запись в таблице соотвествий для бар-кода &1 &3 (код товара &2) в v16.0 ", temp-items.b-code-old, temp-items.gds-code-old, p-from-version).
        v-ii-bind-err = v-ii-bind-err + 1.
        next _items1.
      end.
      if buf_ext-classif.uniq-key-rec = '' then do:
        assign
        temp-items.notes = substitute("Запись в таблице соотвествий для бар-кода &1 &3 (код товара &2) в v16.0 НЕЗАПОЛНЕНА", temp-items.b-code-old, temp-items.gds-code-old, p-from-version).
        v-ii-bind-err = v-ii-bind-err + 1.
        next _items1.
      end.
      if buf_ext-classif.key#_three = 0 then do:
        assign
        temp-items.notes = substitute("Запись в таблице соотвествий для бар-кода &1 &3 (код товара &2) ЕЩЕ В РАБОТЕ", temp-items.b-code-old, temp-items.gds-code-old, p-from-version).
        v-ii-bind-err = v-ii-bind-err + 1.
        next _items1.
      end.
      run gen-row-keyr in this-procedure (
                                          input  buf_ext-classif.uniq-key-rec
                                         ,input ? /*p-key-handle as handle     буфер записи которую будем искать. если ищем по key-rec то ? */
                                         ,input "ub"
                                         ,input ? /*p-tt-handle  as handle     буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                         ,input NO-LOCK
                                         ,output v-tbl-row
                                         ,output v-tbl-name) no-error.
      if error-status:error then do:
        assign
        temp-items.notes = substitute("Ошибка при поиске товара v16.0 по ключу записи (&1): &2 &3"
                                        , buf_ext-classif.uniq-key-rec
                                        , error-status:get-message(1)
                                        , return-value ).
        v-ii-bind-err = v-ii-bind-err + 1.
        next _items1.
      end.
      find first buf_goods no-lock where
                rowid(buf_goods) = v-tbl-row no-error.
      if not available buf_goods then do:
        assign
        temp-items.notes = substitute("Ошибка при поиске товара v16.0 по ключу записи (&1)", buf_ext-classif.uniq-key-rec).
        v-ii-bind-err = v-ii-bind-err + 1.
        next _items1.
      end.
      v-found = no.
      assign
      temp-items.gds-code-151 = buf_goods.gds-code.
      _bar-code:
      for each buf_bar-code no-lock where
              buf_bar-code.gds-code = buf_goods.gds-code:
        if buf_bar-code.in-code <> ''
        or buf_bar-code.part-code <> '' then next.
        if buf_bar-code.unit-cli = temp-items.unit-cli-old then do:
           assign
           temp-items.unit-cli-151 = buf_bar-code.unit-cli
           temp-items.cli-base-rate-151 = buf_bar-code.cli-base-rate
           .
           if temp-items.cli-base-rate-151 <> temp-items.cli-base-rate-old then do:
              assign
              temp-items.notes = substitute("Бар-код v16.0 (&1) имеет кратность ед.изм &2, бар-код &5 (&3) кратность &4"
                                            , temp-items.b-code-151
                                            , temp-items.cli-base-rate-151
                                            , temp-items.b-code-old
                                            , temp-items.cli-base-rate-old
                                            , p-from-version
                                            ).
              v-ii-cli-base-rate-err = v-ii-cli-base-rate-err + 1.
              next _items1.
           end.
           else do:
             v-found = yes.
             assign
             temp-items.b-code-151 = buf_bar-code.b-code
             temp-items.gds-code-151 = buf_bar-code.gds-code
             temp-items.unit-cli-151 = buf_bar-code.unit-cli
             temp-items.cli-base-rate-151 = buf_bar-code.cli-base-rate
             .
             leave _bar-code.
           end.
        end. /*if buf_bar-code.unit-cli = temp-items.unit-cli-old then do:*/
      end. /*      for each buf_bar-code no-lock where*/
      if not v-found then do:
        assign
        temp-items.notes = substitute("Не найден подходящий бар-код в v16.0 для бар-кода &4 &1 (код товара в &4 - &2, код товара в v16.0 - &2"
                                      , temp-items.b-code-old
                                      , temp-items.gds-code-old
                                      , temp-items.gds-code-151
                                      , p-from-version
                                      ).
        v-ii-nf-bar-code-err = v-ii-nf-bar-code-err + 1.
        next _items1.
      end.
    end. /*else   if not available src_bar-code then do:*/
  end. /*else if temp-items.notes > '' then do:*/
end. /*for each temp-items*/
&scop my-message substitute("Просмотрено непустых строк файла: &1", v-ii)
{&display-message}.
&scop my-message substitute("пропущено   записей с ошибочным форматом:                       &1", v-ii-format-err)
{&display-message}.
&scop my-message substitute("пропущено   записей с неизвестным бар-кодом:                     &1", v-ii-b-code-err)
{&display-message}.
&scop my-message substitute("пропущено   записей с шкальным бар-кодом:                        &1", v-ii-node-code-err)
{&display-message}.
&scop my-message substitute("пропущено   записей с партионным бар-кодом:                      &1", v-ii-part-err)
{&display-message}.
&scop my-message substitute("пропущено   записей без соответствия товара в v16.0:            &1", v-ii-bind-err)
{&display-message}.
&scop my-message substitute("пропущено   записей с другой кратностью бар-кода в v16.0:        &1", v-ii-cli-base-rate-err)
{&display-message}.
&scop my-message substitute("пропущено   записей с не найденным подходящим бар-кодом в v16.0: &1", v-ii-nf-bar-code-err)
{&display-message}.
&scop my-message substitute("...")
{&display-message} .
f-name = ''.
system-dialog get-file v-full-path-2
title "Введите имя файла, в который будет выведен список БАРКОД;ЦЕНА с бар-кодами из v16.0"
filters "Текстовый файл (*.csv)"   "*.csv" ,
        "Текстовый файл (*.txt)"   "*.txt" ,
        "Список кодов   (*.bb)"    "*.bb" ,
        "Все файлы" "*.*"
ask-overwrite
save-as
use-filename
update glog
default-extension "txt".
if not glog then do:
&scop my-message substitute("Отказ от записи в файл..")
{&display-message}.
return.
end.
else do:
  if v-full-path-2 = v-full-path then do:
    &scop my-message substitute("Нельзя затирать исходный файл..")
    {&display-message}.
    return.
  end.
  output stream sout to value (v-full-path-2).
  for each temp-items:
    if temp-items.notes = "" then do:
      put stream sout unformatted
      temp-items.b-code-151 ";"
      temp-items.price
      skip.
    end.
    else do:
      put stream sout unformatted
      substitute("#### Строка &1 (&2): &3", temp-items.line-num, temp-items.ss, temp-items.notes)
      skip.
    end.
  end.
  output stream sout close.
end.

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdsc.p $ $Revision: 1f78fe327cdf, 1091, rls $".

&if defined (include_key-rec) = 0 &then
&glob include_key-rec yes

procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .

    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .

    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info{&vssseq} ).
    end.

    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.

    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info{&vssseq}, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + {&delim-key} + substitute("&1", fh:buffer-value())
        .
      end.
    end.

    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info{&vssseq}, p-tbl-name ).
    end.

  end.
  return.
end procedure. /* gen-key-rec */

procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo . /* буфер записи которую будем искать. если ищем по key-rec то ? */
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo . /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  define input  parameter p-stts-lock  as integer   no-undo . /* этот параметр игнорируется для временных таблиц */
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-where          as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do: /* если ищем по буферу */
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info{&vssseq} ).
      end.
      if num-entries( p-key-rec, {&delim-key} ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info{&vssseq}, p-key-rec ).
      end.
    end.
    else do: /* если ищем по ключу */
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info{&vssseq} ).
      end.
    end.

    assign
      p-tbl-name = entry( 1 , p-key-rec, {&delim-key} )
    .

    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info{&vssseq}, p-tbl-name, {&new-line} ).
    end.

    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, p-tbl-name )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.

    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.

    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info{&vssseq}, p-tbl-name ).
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, p-tbl-name ).
    end.
    assign
      v-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, {&delim-key} ) - 1
      v-count-fld = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.

      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
        assign
          v-where = substitute( "&1 &2 &3 =", v-where, v-word-link, v-field-name )
        .
/*      if p-tt-handle = ? then do:*/
/*        assign*/
/*          v-where = substitute( "&1 &2 &3.&4 =", v-where, v-word-link, v-full-tbl-name, v-field-name )*/
/*        .*/
/*      end.*/
/*      else do:*/
/*        assign*/
/*          v-where = substitute( "&1 &2 &3 =", v-where, v-word-link, v-field-name )*/
/*        .*/
/*      end.*/
      if p-key-handle = ? then do:
        assign
          v-field-val = entry( v-count-fld + 1 , p-key-rec, {&delim-key} )
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info{&vssseq}, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.

      if fh_search:data-type ="character":U then do:
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

    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info{&vssseq}, p-tbl-name ).
    end.
    if p-tt-handle = ? then do:
      bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
    end.
    else do:
      bh_tbl-name:find-first( v-where ) no-error .
    end.

    if bh_tbl-name:available then do:
      assign
        p-tbl-row = bh_tbl-name:rowid
      .
    end.
    else do:
      assign
        p-tbl-row = ?
      .
    end.

    delete object bh_tbl-name.

  end.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info{&vssseq}, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.

end procedure. /* gen-row-keyr */

procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .

    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info{&vssseq} ).
    end.

    assign
      v-tbl-name      = entry( 1 , p-key-rec, {&delim-key} )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info{&vssseq} ).

    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.

    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.

    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info{&vssseq}, v-inform, v-tbl-name ).
    end.

    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, {&delim-key} ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.

      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, {&delim-key} )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = {&delim-key}
        .
      end.
    end.

    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.

    delete object bh_tbl-name.

  end.

  return.

end procedure. /* gen-key-fv */
&endif