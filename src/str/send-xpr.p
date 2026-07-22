block-level on error undo, throw.
/*

$Revision: 0d3673848966, 2893, rls $
$Author: DRuban $
$Date: Пн ноя 22 19:49:12 2021 +0300 $
$Workfile: send-xpr.p $
$Archive: str/send-xpr.p $

Отсылка на кассу параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/05/05
Author: Bakhtadze Natalya
Creation date: 12/05/05

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-db-num like ub.cash-desk.db-num no-undo .
define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
define input parameter p-what-send as character no-undo.
*/


define variable vss-revision    as character no-undo init "$Revision: 0d3673848966, 2893, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:12 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-xpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-xpr.p $":U .
define variable vss-description as character no-undo init "Отсылка на кассу параметров".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/get-chk-share.i new }
{ gbl/key-rec.i }
{ nws/bintrnpr.i "new shared" }

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


define variable p-cash-desk-uniq-key-rec as character no-undo .
define variable action     as character no-undo .
define variable p-ext-file-uniq-key-rec as character no-undo .


define variable i-obj-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable p-db-num   like ub.cash-desk.db-num no-undo .
define variable p-obj-code like ub.cash-desk.obj-code no-undo .
define variable p-pos-type like ub.cash-desk.pos-type no-undo .
define variable p-cash-num like ub.cash-desk.cash-num no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-error-num as integer no-undo .
define variable v-reply-file-name as character no-undo .
define variable v-param-num as integer no-undo .
define variable v-log-file-uniq-key-rec as character no-undo .
define variable v-reply-file-uniq-key-rec as character no-undo .
define variable v-unc-reply-file-name as character no-undo .
define variable v-unc-log-file-name as character no-undo .


define buffer target_cash-desk for ub.cash-desk.
define buffer buf_ext-file for ub.ext-file.
define buffer buf2_ext-file for ub.ext-file.
define new shared temp-table tt-ext-file no-undo like ub.ext-file.
define new shared temp-table tt-db       no-undo like ub.db.
define temp-table rtt-ext-file no-undo like ub.ext-file.
define buffer buf_tt-db for tt-db.
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_rtt-ext-file for rtt-ext-file.
define buffer buf_db for ub.db.
define buffer buf_ext-file-par for ub.ext-file-par.

{ nws/bintrn.i }

define stream bar.
define stream plucash.

{ bge/bgelib.i }
&glob xml-cd-doc-name 'config'
{ str/cd-xml.i }
{ str/cdsnddef.i }
log-file-name = "sendxprr.txt".

/*PROCEDURE putc-par*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-xpr.i }

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cyxpr.i }

/*PROCEDURE SENDING.*/
{ str/cd-sexpr.i }


assign
p-cash-desk-uniq-key-rec = entry(1, p-parameter, {&delim-par})
p-ext-file-uniq-key-rec    = entry(2, p-parameter, {&delim-par})
action     = entry(3, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).

log-file-name = substitute("&1_to_&2.txt"
                           , replace(p-ext-file-uniq-key-rec, {&delim-key}, "_")
                           , replace(p-cash-desk-uniq-key-rec, {&delim-key}, "_")
                           ).

run gen-row-keyr in this-procedure (
                                      input  p-cash-desk-uniq-key-rec
                                     ,input  ? /* p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
                                     ,input  "ub"
                                     ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                     ,input  no-lock
                                     ,output v-tbl-row
                                     ,output v-tbl-name) no-error.
find first target_cash-desk no-lock where
          rowid(target_cash-desk) = v-tbl-row no-error.
if not available target_cash-desk then do:
end.
assign
p-db-num = target_cash-desk.db-num
p-obj-code = target_cash-desk.obj-code
p-pos-type = target_cash-desk.pos-type
p-cash-num = target_cash-desk.cash-num
.
if p-db-num <> g#db-num then do:
  &scop my-message substitute("!!!Нельзя отслылать на кассу ЧУЖОЙ БД &1", p-db-num)
  {&display-message}.
  return.
end.

i-obj-code = p-obj-code.
{ gbl/hostcode.i ~{&shop~} p-obj-code v-host-code }

run gen-row-keyr in this-procedure (
                                      input  p-ext-file-uniq-key-rec
                                     ,input  ? /* p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
                                     ,input  "ub"
                                     ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                     ,input  no-lock
                                     ,output v-tbl-row
                                     ,output v-tbl-name) no-error.
find first buf_ext-file no-lock where
          rowid(buf_ext-file) = v-tbl-row no-error.
if not available buf_ext-file then do:
  &scop my-message substitute("!!!В хранилище текущей БД отсутствует файл &1", p-ext-file-uniq-key-rec)
  {&display-message}.
  return.
end.


run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка ФАЙЛА параметров на кассу &1 &2 маг&3", p-pos-type, p-cash-num, p-obj-code)
                                          ).
RUN SENDING no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке ФАЙЛА на кассу &1 &2 маг&3"
                         , p-pos-type, p-cash-num, p-obj-code
                        )
                                        ).

  assign
  v-view-log = yes
  .
end.
{ str/cdviewlg.i
"substitute('!!!При отсылке файла &1 на кассу &2 маг&3 произошли ошибки!!!', p-ext-file-uniq-key-rec, p-cash-num, p-obj-code)"
log-file-name
not-delete
}

for each tt-db:
  delete tt-db.
end.
for each tt-ext-file:
  delete tt-ext-file.
end.
for each tt-ext-file-par:
  delete tt-ext-file-par.
end.

/*готовим к отсылке лог файл*/
run bintrn_create-file-record in this-procedure ( input log-file-name
                                                 ,input p-cash-desk-uniq-key-rec
                                                 ,input {&shop}
                                                 ,input p-obj-code
                                                 ,output v-unc-log-file-name
                                                 ) no-error.
if error-status:error then do:
  &scop my-message    substitute("Ошибка при подготовке файла &1 к пересылке &2" + ~
              "&3&2&4" ~
              , v-full-path ~
              , ~{&new-line~} ~
              , error-status:get-message(1) ~
              , return-value ) ~
  {&display-message}.
end.


find first buf_db no-lock where
        buf_db.db-num = (if g#news
                         and g#db-num > 0
                         then 0
                         else g#db-num).
create buf_tt-db.
buffer-copy buf_db to buf_tt-db.
/*входной параметр к лог-файлу*/
run ext-file-par-write-temp in this-procedure (
                                              input  ? /*p-db-num*/ /*при посылке переделается - это ini значения для ext-file*/
                                              ,input  -1 /*from-db-num*/  /*при посылке переделается - это ini значения для ext-file*/
                                              ,input  1 /*p-file-num*/
                                              ,input  1 /*p-param-num */
                                              ,input  {&datatype-uniq-key-rec} /*p-value-type */
                                              ,input  p-cash-desk-uniq-key-rec
                                              ,input  p-ext-file-uniq-key-rec
                                              ,input  ? /*p-value-date*/
                                              ,input  0 /*p-value-integer */
                                              ,input  0.0 /*p-value-decimal */
                                              ,input  no /*p-value-logical */ ) no-error.

release buf_tt-db.
/*отсылка лог файла номер файла получим с через callbcack*/
run nws/sndfnwr.p ( input parparentproc
                  ,input this-procedure:handle
                  ,input p-log-handle
                  ,input ((if g#db-num > 0
                           and g#news
                           then {&save-db}
                           else {&save-this-db}) + {&delim-par} +
                          string(0) + {&delim-par} + /*относительны путь*/
                          log-file-name + {&delim-par} +
                          '' /*p-status_ здесь не нужен*/  )) no-error.
for each tt-ext-file:
  delete tt-ext-file.
end.
for each tt-ext-file-par:
  delete tt-ext-file-par.
end.
/*готовим к отсылке файл ответа*/
run bintrn_create-file-record in this-procedure ( input v-reply-file-name
                                                 ,input p-cash-desk-uniq-key-rec
                                                 ,input {&shop}
                                                 ,input p-obj-code
                                                 ,output v-unc-reply-file-name
                                                ) no-error.
if error-status:error then do:
  &scop my-message    substitute("Ошибка при подготовке файла &1 к пересылке &2" + ~
              "&3&2&4" ~
              , v-full-path ~
              , ~{&new-line~} ~
              , error-status:get-message(1) ~
              , return-value ) ~
  {&display-message}.
end.
/*входной параметр к файлу ответа - во временную таблицу*/
run ext-file-par-write-temp in this-procedure (
                                               input  ? /*p-db-num*/ /*при посылке переделается - это ini значения для ext-file*/
                                              ,input  -1 /*from-db-num*/ /*при посылке переделается - это ini значения для ext-file*/
                                              ,input  1 /*p-file-num*/
                                              ,input  1 /*p-param-num */
                                              ,input  {&datatype-uniq-key-rec} /*p-value-type */
                                              ,input  p-cash-desk-uniq-key-rec
                                              ,input  p-ext-file-uniq-key-rec
                                              ,input  ? /*p-value-date*/
                                              ,input  0 /*p-value-integer */
                                              ,input  0.0 /*p-value-decimal */
                                              ,input  no /*p-value-logical */ ) no-error.

/*отсылка файла ответа номер файла получим с через callbcack*/
run nws/sndfnwr.p ( input parparentproc
                  ,input this-procedure:handle
                  ,input p-log-handle
                  ,input ((if g#db-num > 0
                           and g#news
                           then {&save-db}
                           else {&save-this-db}) + {&delim-par} +
                          string(0) + {&delim-par} + /*относительны путь*/
                          v-reply-file-name + {&delim-par} +
                          '' /*p-status_ здесь не важен*/  )) no-error.

/*надо найти uniq-key-rec к файлу лога*/
/*надо найти uniq-key-rec к файлу ответа*/
for each buf_rtt-ext-file :
  if buf_rtt-ext-file.file-name = v-unc-log-file-name then do:
    run gen-key-rec in this-procedure ( input {&table_ext-file}
                                       ,input (buffer buf_rtt-ext-file:handle)
                                       ,output v-log-file-uniq-key-rec) no-error.
  end.
  if buf_rtt-ext-file.file-name = v-unc-reply-file-name then do:
    run gen-key-rec in this-procedure ( input {&table_ext-file}
                                       ,input (buffer buf_rtt-ext-file:handle)
                                       ,output v-reply-file-uniq-key-rec) no-error.
  end.
end.


/*готовим к отсылке параметры к основному файлу*/

find last buf_ext-file-par no-lock where
        buf_ext-file-par.db-num = buf_ext-file.db-num
    and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
    and buf_ext-file-par.file-num = buf_ext-file.file-num no-error.

v-param-num = (if available buf_ext-file-par
                then buf_ext-file-par.param-num + 1
                else 1).


/*лог-файл - входной параметр к основному файлу*/
run ext-file-par-write-and-send in this-procedure (
                                                  input  buf_ext-file.db-num
                                                  ,input  buf_ext-file.from-db-num
                                                  ,input  buf_ext-file.file-num
                                                  ,input  v-param-num    /*номер параметра - входной*/
                                                  ,input  {&datatype-uniq-key-rec} /*p-value-type) */
                                                  ,input  p-cash-desk-uniq-key-rec /*p-value-name*/
                                                  ,input  v-log-file-uniq-key-rec /*p-value-character*/
                                                  ,input  ? /*p-value-date */
                                                  ,input  0 /*p-value-integer */
                                                  ,input  0.0 /*p-value-decimal*/
                                                  ,input  (if v-view-log then no else yes) /*p-value-logical */
                                                  ,input  (if g#db-num > 0
                                                          and g#news
                                                          then yes
                                                          else no)
                                                  ,input  g#news-source-db ) no-error.


/*файл-ответа - выходной параметр к основному файлу*/
run ext-file-par-write-and-send in this-procedure (
                                                  input  buf_ext-file.db-num
                                                  ,input  buf_ext-file.from-db-num
                                                  ,input  buf_ext-file.file-num
                                                  ,input  (- v-param-num)    /*номер параметра - резльут*/
                                                  ,input  {&datatype-uniq-key-rec} /*p-value-type) */
                                                  ,input  p-cash-desk-uniq-key-rec /*p-value-name*/
                                                  ,input  v-reply-file-uniq-key-rec
                                                  ,input  ? /*p-value-date */
                                                  ,input  0 /*p-value-integer */
                                                  ,input  0.0 /*p-value-decimal*/
                                                  ,input  (if v-view-log then no else yes) /*p-value-logical */
                                                  ,input  (if g#db-num > 0
                                                          and g#news
                                                          then yes
                                                          else no)
                                                  ,input  g#news-source-db ) no-error.

procedure cb_set-ext-file_file-num :
define input parameter p-db-num as integer no-undo .
define input parameter p-from-db-num as integer no-undo .
define input parameter p-file-num as integer no-undo .
define buffer buf_tt-ext-file for tt-ext-file.
define buffer buf_rtt-ext-file for rtt-ext-file.
do
on error undo, return error
:
  find first buf_tt-ext-file.
  find first buf_rtt-ext-file where
            buf_rtt-ext-file.db-num = p-db-num
        and buf_rtt-ext-file.from-db-num = p-from-db-num
        and buf_rtt-ext-file.file-num = p-file-num no-error.
  if not available buf_rtt-ext-file then do:
    create buf_rtt-ext-file.
    buffer-copy buf_tt-ext-file
    except db-num from-db-num file-num
    to buf_rtt-ext-file
    assign
    buf_rtt-ext-file.db-num = p-db-num
    buf_rtt-ext-file.from-db-num = p-from-db-num
    buf_rtt-ext-file.file-num = p-file-num
    buf_rtt-ext-file.file-type = p-cash-desk-uniq-key-rec
    buf_rtt-ext-file.obj-type = {&shop}
    buf_rtt-ext-file.obj-code = p-obj-code
    .
    release buf_rtt-ext-file.
  end.
end.

end procedure. /* cb_set-ext-file_file-num */