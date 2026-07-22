/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица и процедуры описывающие изменения, которые необходимос произвести над множеством записей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/21/05
Author: Bakhtadze Natalya
Creation date: 11/21/05

предполагается применять в утилитах обновления по спискам  и в импорте

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table temp-update-rule no-undo
field table-name as character /*имя обновляемой - добавляемой таблицы*/
field table-id as integer /*номер таблицы в общум спуле буферов*/
field field-name as character /*название обновляемого поля или * при добавлении*/
field bh as handle /*ссылка на буфер по котором заполняем ПК*/
field pk as character         /*первичный ключ для обновляемой таблицы*/
field gen-id as integer       /*ключ связывающий воедино все множество обновлений по таблицам для одной сложной сущности*/
field action as character     /*дествие которое необходимо произвести - {&add-def} {&update} {&deletion} link*/
/*поля для линкования*/
field table-name-s as character /*имя обновляемой - добавляемой таблицы*/
field table-id-s as integer /*номер таблицы в общем спуле буферов*/
field field-name-s as character /*название обновляемого поля или * при добавлении*/
field bh-s as handle /*ссылка налинкуемый  буфер */
field type_ as integer /*0 - изменяемое 1- дефолтное 2-линк*/
index pi is unique primary
gen-id
table-name
field-name
type_
table-name-s
field-name-s
index ps
gen-id
table-name-s
field-name-s
index itype
type_
.

procedure gen-temp-row-keyr :
  define input  parameter p-key-rec  as character no-undo.
  define input  parameter p-prefix   as character no-undo .
  define output parameter p-tbl-row  as rowid     no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-temp-row-keyr). &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-temp-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-temp-row-keyr). endkey", vss-workfile )
  :
    define variable v-tbl-name as character no-undo.
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh              as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-where         as character no-undo .
    define variable v-field-num     as integer   no-undo .
    define variable v-count-fld     as integer   no-undo .

    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-temp-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info{&vssseq} ).
    end.

    assign
      v-tbl-name      = entry( 1 , p-key-rec, {&delim-key} )
      v-full-tbl-name = 'ub.' + v-tbl-name
      v-field-num     = num-entries( p-key-rec, {&delim-key} ) - 1
      v-where         = "":U
      v-count-fld     = 0
    .

    find {&db-name_schema}._file
      where {&db-name_schema}._file._file-name = v-tbl-name
      no-error.
    if not available {&db-name_schema}._file then do:
      return error substitute( "&1. Таблица &2 отсутствует в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.
    find {&db-name_schema}._index
      where recid( {&db-name_schema}._index  ) = {&db-name_schema}._file._prime-index
      no-error.

    if not available {&db-name_schema}._index
      or LC( {&db-name_schema}._index._index-name ) = "default":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.

    block_where :
    for each {&db-name_schema}._index-field of {&db-name_schema}._index  ,
        each {&db-name_schema}._field of _index-field
        break by _index-seq
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      if v-where = "":U then do:
        assign
          v-where = "where":U
        .
      end.
      else do:
        assign
          v-where = v-where + {&space-char} + "and":U
        .
      end.
      if {&db-name_schema}._field._Data-Type ="character":U then do:
        assign
          v-where = v-where + {&space-char} + substitute( "&1 = '&2'":U, {&db-name_schema}._field._field-name, entry( v-count-fld + 1 , p-key-rec, {&delim-key} ) )
        .
      end.
      else do:
        assign
          v-where = v-where + {&space-char} + substitute( "&1 = &2":U, {&db-name_schema}._field._field-name, entry( v-count-fld + 1 , p-key-rec, {&delim-key} ) )
        .
      end.
    end.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.

    create buffer bh_tbl-name for table (p-prefix  + v-tbl-name) .

    bh_tbl-name:find-first( v-where, share-lock ) no-error .

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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info{&vssseq}, v-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure. /* gen-temp-row-keyr  */

/* $Workfile$ e n d */