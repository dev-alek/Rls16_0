/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Операции проводимые над записью

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/08/05
Author: Dmitry Ukhanov
Creation date: 09/08/05

*/
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop bef-action-code crush_code-range
/*действие необходимое произвести над записью таблицы*/
&glob crush_code-range '{&bef-action-code}':U
&scop action-title-{&bef-action-code} "Разбиение диапазона кодов (code-range)"
&scop list-db-{&bef-action-code}   'utl/cdrg-dbl.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/code-rgt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'comm-crush-cdrg':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'exec-crush-cdrg':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'rcvr-crush-cdrg':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/

&scop bef-action-code delete_code-range
&glob delete_code-range '{&bef-action-code}':U
&scop action-title-{&bef-action-code} "Удаление диапазона кодов (code-range)"
&scop list-db-{&bef-action-code}   'utl/cdrg-dbl.p':U
&scop main-prog-{&bef-action-code} 'trg/code-rgt.p':U
&scop commit-{&bef-action-code}    'comm-del-cdrg':U
&scop execution-{&bef-action-code} 'exec-del-cdrg':U
&scop recover-{&bef-action-code}   'rcvr-del-cdrg':U
&scop after-{&bef-action-code}   '':U

/*удаление неиспользову*/
&scop bef-action-code delete_nu-prt-bar-code
&scop action-title-{&bef-action-code} "Удаление неисп. бар-кода признака"
/*действие необходимое произвести над записью таблицы - удаление неиспользуемого бар-кода признака*/
&glob delete_nu-prt-bar-code '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'str/barcddb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/bar-codt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-del-prt-bar-code':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'delete-prt-bar-code':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-delete-prt-bar-code':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/


&scop bef-action-code delete_nu-part-bar-code
/*действие необходимое произвести над записью таблицы удаление неиспользуемого бар-кода партии*/
&scop action-title-{&bef-action-code} "Удаление неисп. бар-кода партиии"
&glob delete_nu-part-bar-code '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'str/barcddb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/bar-codt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-del-part-bar-code':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'delete-part-bar-code':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-delete-part-bar-code':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/

&scop bef-action-code delete_nu-ucli-bar-code
/*действие необходимое произвести над записью таблицы удаление неиспользуемого бар-кода на доп ед.изм*/
&scop action-title-{&bef-action-code} "Удаление неисп.бар-кода на доп ед.изм."
&glob delete_nu-ucli-bar-code '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'str/barcddb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/bar-codt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-del-ucli-bar-code':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'delete-ucli-bar-code':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-delete-ucli-bar-code':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/


&scop bef-action-code ren-art
/*действие необходимое произвести над записью таблицы*/
&glob ren-art '{&bef-action-code}':U
&scop action-title-{&bef-action-code} "Изм. артикула и(или) произв. товара"
&scop list-db-{&bef-action-code}   'utl/renartcd.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/goodst.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'comm-ren-art':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'exec-ren-art':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'rcvr-ren-art':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   'after-ren-art':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/

/*удаление неиспользуемой ДК*/
&scop bef-action-code delete_nu-dis-card
&scop action-title-{&bef-action-code} "Удаление неиспользуемой ДК"
/*действие необходимое произвести над записью таблицы - удаление неиспользуемой ДК*/
&glob delete_nu-dis-card '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'trg/discardb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/discardt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-del-dis-card':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'delete-dis-card':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-delete-dis-card':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/

/*смена владельца ДК*/
&scop bef-action-code chown-dis-card
&scop action-title-{&bef-action-code} "Смена владельца ДК"
/*действие необходимое произвести над записью таблицы - смена владельца ДК*/
&glob chown-dis-card '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'trg/discardb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/discardt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-chown-dis-card':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'chown-dis-card':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-chown-dis-card':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   'after-chown-dis-card':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/

/*удаление правила скидки по БД и фирме*/
&scop bef-action-code delete_nu-dis-rule
&scop action-title-{&bef-action-code} "Удаление правила скидки по фирме и глобального правила скидки"
/*действие необходимое произвести над записью таблицы - удаление правила скидки*/
&glob delete_nu-dis-rule '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'trg/disruldb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/dis-rult.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-del-dis-rule':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'delete-dis-rule':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-delete-dis-rule':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/


/*удаление неиспользуемой CLOB-DATA*/
&scop bef-action-code delete_nu-clob-data
&scop action-title-{&bef-action-code} "Удаление неиспользуемой clob-data"
/*действие необходимое произвести над записью таблицы - удаление неиспользуемой clob-data*/
&glob delete_nu-clob-data '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'trg/clbdatdb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/clobdatt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-del-clob-data':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'delete-clob-data':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-delete-clob-data':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/

/*удаление раскладки*/
&scop bef-action-code delete_nu-layout
&scop action-title-{&bef-action-code} "Удаление РАСКЛАДКИ"
/*действие необходимое произвести над записью таблицы - удаление РАСКЛАДКИ*/
&glob delete_nu-layout '{&bef-action-code}':U
&scop list-db-{&bef-action-code}   'trg/layoutdb.p':U
/*возвращает список БД в которых нужно выполнить действие*/
&scop main-prog-{&bef-action-code} 'trg/layoutt.p':U
/*библиотека процедур для выполнения действия */
&scop commit-{&bef-action-code}    'block-del-layout':U
/*название процедуры блокировки в данной библиотеке*/
&scop execution-{&bef-action-code} 'delete-layout':U
/*название процедуры выполняющей действие после блокировки - в данной библиотеке*/
&scop recover-{&bef-action-code}   'undo-delete-layout':U
/*название процедуры выполняющей откат действия и блокировки - в данной библиотеке*/
&scop after-{&bef-action-code}   '':U
/*название процедуры выполняемой после завершения выполнения действия над записью - в данной библиотеке*/



&glob db-rec-attr-list ( ~
{&crush_code-range} + {&comma-char} + ~
{&delete_code-range} + {&comma-char} + ~
{&delete_nu-prt-bar-code} + {&comma-char} + ~
{&delete_nu-part-bar-code} + {&comma-char} + ~
{&delete_nu-ucli-bar-code} + {&comma-char} + ~
{&delete_nu-dis-card} + {&comma-char} + ~
{&chown-dis-card} + {&comma-char} + ~
{&delete_nu-dis-rule} + {&comma-char} + ~
{&delete_nu-clob-data} + {&comma-char} + ~
{&delete_nu-layout} + {&comma-char} + ~
{&ren-art} )
/*сюда добавлить новые команды*/

&scop sel-action-title ~
  when ~{&~{&action-code~}~} then do: ~
    assign ~
      p-action-title        = ~{&action-title-~{&action-code~}~} ~
    . ~
  end.

&scop sel-action-code ~
  when ~{&~{&action-code~}~} then do: ~
    assign ~
      p-main-prog-name      = ~{&main-prog-~{&action-code~}~} ~
      p-list-db-proc-name   = ~{&list-db-~{&action-code~}~} ~
      p-commit-proc-name    = ~{&commit-~{&action-code~}~} ~
      p-execution-proc-name = ~{&execution-~{&action-code~}~} ~
      p-recover-proc-name   = ~{&recover-~{&action-code~}~} ~
      p-after-proc-name     = ~{&after-~{&action-code~}~} ~
    . ~
  end.


procedure progs-name :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-main-prog-name      as character no-undo .
  define output parameter p-list-db-proc-name   as character no-undo .
  define output parameter p-commit-proc-name    as character no-undo .
  define output parameter p-execution-proc-name as character no-undo .
  define output parameter p-recover-proc-name   as character no-undo .
  define output parameter p-after-proc-name     as character no-undo .

  do
  on error undo, return error
  :
    case p-action-code :
      &scop action-code crush_code-range
      {&sel-action-code}
      &scop action-code delete_code-range
      {&sel-action-code}
      &scop action-code delete_nu-prt-bar-code
      {&sel-action-code}
      &scop action-code delete_nu-part-bar-code
      {&sel-action-code}
      &scop action-code delete_nu-ucli-bar-code
      {&sel-action-code}
      &scop action-code delete_nu-dis-card
      {&sel-action-code}
      &scop action-code chown-dis-card
      {&sel-action-code}
      &scop action-code delete_nu-dis-rule
      {&sel-action-code}
      &scop action-code ren-art
      {&sel-action-code}
      &scop action-code delete_nu-clob-data
      {&sel-action-code}
      &scop action-code delete_nu-layout
      {&sel-action-code}
      /*сюда добавлить новые команды*/
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info{&vssseq}, p-action-code ).
      end.
    end case.
  end.

  return.
end procedure. /* progs-name */


procedure progs-title :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-action-title      as character no-undo .

  do
  on error undo, return error
  :
    case p-action-code :
      &scop action-code crush_code-range
      {&sel-action-title}
      &scop action-code delete_code-range
      {&sel-action-title}
      &scop action-code delete_nu-prt-bar-code
      {&sel-action-title}
      &scop action-code delete_nu-part-bar-code
      {&sel-action-title}
      &scop action-code delete_nu-ucli-bar-code
      {&sel-action-title}
      &scop action-code delete_nu-dis-card
      {&sel-action-title}
      &scop action-code chown-dis-card
      {&sel-action-title}
      &scop action-code delete_nu-dis-rule
      {&sel-action-title}
      &scop action-code ren-art
      {&sel-action-title}
      &scop action-code delete_nu-clob-data
      {&sel-action-title}
      &scop action-code delete_nu-layout
      {&sel-action-title}


      /*сюда добавлить новые команды*/
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info{&vssseq}, p-action-code ).
      end.
    end case.
  end.

  return.
end procedure. /* progs-name */

FUNCTION progs-title-function returns character(
   input  p-action-code         as character):
define variable p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
      &scop action-code crush_code-range
      {&sel-action-title}
      &scop action-code delete_code-range
      {&sel-action-title}
      &scop action-code delete_nu-prt-bar-code
      {&sel-action-title}
      &scop action-code delete_nu-part-bar-code
      {&sel-action-title}
      &scop action-code delete_nu-ucli-bar-code
      {&sel-action-title}
      &scop action-code delete_nu-dis-card
      {&sel-action-title}
      &scop action-code chown-dis-card
      {&sel-action-title}
      &scop action-code delete_nu-dis-rule
      {&sel-action-title}
      &scop action-code ren-art
      {&sel-action-title}
      &scop action-code delete_nu-clob-data
      {&sel-action-title}
      &scop action-code delete_nu-layout
      {&sel-action-title}


      /*сюда добавлить новые команды*/
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info{&vssseq}, p-action-code ).
      end.
    end case.
  end.

  return p-action-title.
end FUNCTION. /* progs-name */


procedure get-row-keyr-string :
 define input  parameter p-key-rec  as character no-undo.
 define output parameter p-tbl-title as character no-undo.
 define output parameter p-rec-string  as character no-undo.

  do
  on error undo, return error
  :
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh              as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-field-num     as integer   no-undo .
    define variable v-count-fld     as integer   no-undo .
    define variable v-tbl-name as character no-undo.

    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (get-row-keyr-string). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info{&vssseq} ).
    end.

    assign
      v-tbl-name      = entry( 1 , p-key-rec, {&delim-key} )
      v-full-tbl-name = "ub.":U + v-tbl-name
      v-field-num     = num-entries( p-key-rec, {&delim-key} ) - 1
      p-rec-string         = "":U
      v-count-fld     = 0
    .

    find {&db-name_schema}._file
      where {&db-name_schema}._file._file-name = v-tbl-name
      no-error.
    if not available {&db-name_schema}._file then do:
      return error substitute( "&1. Таблица &2 отсутствует в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.
    assign
    p-tbl-title = {&db-name_schema}._file._file-label
    .
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
      if p-rec-string = "":U then do:
        assign
          p-rec-string = "":U
        .
      end.
      else do:
        assign
          p-rec-string = p-rec-string + {&space-char} + {&comma-char}
        .
      end.
      assign
        p-rec-string = p-rec-string + (if p-rec-string = "":u then "":U else {&space-char}) + substitute( "&1 = &2":U, {&db-name_schema}._field._label, entry( v-count-fld + 1 , p-key-rec, {&delim-key} ) )
      .
    end.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info{&vssseq}, v-tbl-name ).
    end.
  end.
  return.
end procedure. /* get-row-keyr-string */

FUNCTION uniq-key-rec-string-f returns character(
   input  p-uniq-key-rec         as character):
define variable v-tbl-title as character no-undo .
define variable v-rec-string as character no-undo .
  do
  on error undo, return error
  :

    run get-row-keyr-string in this-procedure (
                                              input p-uniq-key-rec
                                              ,output v-tbl-title
                                              ,output v-rec-string).
    assign
    v-rec-string = (if v-tbl-title <> ? and
                    v-tbl-title <> "":U
                    then (v-tbl-title + ":")
                   else "":U) + {&space-char} + v-rec-string
    .
  end.

  return v-rec-string.
end FUNCTION. /* progs-name */


procedure create_db-rec_route :
  define input parameter p1-uniq-key-rec as character no-undo .
  define input parameter p1-action       as character no-undo .
  define input parameter p1-operation    as character no-undo .
  define input parameter p1-send-db-list as character no-undo .
  define input parameter p1-db-init      as integer   no-undo .
  define input parameter p1-parameters   as character no-undo .
  define input parameter p1-answer-code  as integer   no-undo .
  define input parameter p1-answer-msg   as character no-undo .

  do
  on error undo, return error
  :
    define variable v-command     as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .

    define buffer buf_sys-ctrl    for ub.sys-ctrl .

    find first buf_sys-ctrl no-lock .

    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .

    if v-curr-db = 0 then do:
      if p1-answer-code >= 0 then do:
      /* перенаправляем ОТВЕТ в БД инициализатор */
        if v-curr-db <> p1-db-init then do:
          assign
            v-db-for-send = string( p1-db-init )
          .
        end.
      end.
      else do:
      /* перенаправляем ЗАПРОС во все БД кроме БД инициализатора */
        assign
          v-num-entries = num-entries( p1-send-db-list, {&comma-char} )
        .
        do v-ind = 1 to v-num-entries:
          assign
            v-db-num-char = entry( v-ind, p1-send-db-list, {&comma-char} )
            v-db-num      = integer( v-db-num-char )
          .
          if v-db-num <> v-curr-db
            and v-db-num <> p1-db-init
          then do:
            if v-db-for-send = "":U then do:
              assign
                v-db-for-send = v-db-num-char
              .
            end.
            else do:
              assign
                v-db-for-send =  v-db-for-send + {&delim-nws} + v-db-num-char
              .
            end.
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-command = "command":U + {&delim-nws}
                    + "two-commit":U + {&delim-nws}
                    + p1-action + {&delim-nws}
                    + p1-operation + {&delim-nws}
                    + p1-uniq-key-rec + {&delim-nws}
                    + string( p1-db-init ) + {&delim-nws}
                    + p1-parameters + {&delim-nws}
                    + string( p1-answer-code ) + {&delim-nws}
                    + p1-answer-msg
      .
      run nws/cr-route.p ( input {&send-cmd}
                    ,input v-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error return-value.
      end.
    end.

  end.
  return.
end procedure. /* create_db-rec_route */

procedure create_msg_route :
  define input parameter p2-send-db-list as character no-undo .
  define input parameter p2-msg          as character no-undo .
  do
  on error undo, return error
  :
    define variable v-msg-command as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .

    define buffer buf_sys-ctrl    for ub.sys-ctrl .

    find first buf_sys-ctrl no-lock .

    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .

    if v-curr-db = 0 then do:
      assign
        v-num-entries = num-entries( p2-send-db-list, {&comma-char} )
      .
      do v-ind = 1 to v-num-entries:
        assign
          v-db-num-char = entry( v-ind, p2-send-db-list, {&comma-char} )
          v-db-num      = integer( v-db-num-char )
        .
        if v-db-num <> v-curr-db then do:
          if v-db-for-send = "":U then do:
            assign
              v-db-for-send = v-db-num-char
            .
          end.
          else do:
            assign
              v-db-for-send =  v-db-for-send + {&delim-nws} + v-db-num-char
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-msg-command = "command":U + {&delim-nws}
                        + "message-to-log":U + {&delim-nws}
                        + p2-msg
      .
      run nws/cr-route.p ( input {&send-cmd}
                    ,input v-msg-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error substitute( "&1&2&3"
                                  , return-value
                                  , {&new-line}
                                  , error-status :get-message(1)
                                ).
      end.
    end.
  end.
  return.
end procedure. /* create_msg_route */

function get-send-db-list returns character
  ( input p-curr-db     as integer
   ,input p-all-db-list as character
  )
:
  define variable v-send-db-list as character no-undo .

  if p-curr-db = 0 then do:
    assign
      v-send-db-list = p-all-db-list
    .
  end.
  else do:
    assign
      v-send-db-list = string(p-curr-db)
    .
  end.
  return v-send-db-list .

end function .

/* $Workfile$ e n d */