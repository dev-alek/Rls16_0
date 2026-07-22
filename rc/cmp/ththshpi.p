block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ththshpi.p $
$Archive: cmp/ththshpi.p $

Получение соответствия данных по клиентам из старой версии системы TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/12/08
Author: Bakhtadze Natalya
Creation date: 12/12/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththshpi.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththshpi.p $":U .
define variable vss-description as character no-undo init "Получение данных по объектам из старой версии системы TH".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ cmp/thth150.i }
{ cmp/thth14.i }


define variable p-from-version as character no-undo .
define variable v-src-full-name as character no-undo .
define variable v-upper-code as integer no-undo .
define variable v-level as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable v-cli-classif-name as character no-undo .


define buffer src_clients for src.clients.
define buffer src_shop for src.shop.
define buffer src_store for src.store.
define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer src_dis-card for src.dis-card.


define variable log-file-name as character no-undo .

DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.

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
p-from-version =  entry(1, p-parameter, {&delim-par} )
.

case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-cli-classif-name = {&extclass_clients_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-cli-classif-name = {&extclass_clients_th-th14}
    .
  end.
end case.


/*очищаем все*/
log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).

&scop my-message "Очищаем старые данные..."
{&display-message}.
for each buf_ext-classif WHERE
            buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name = v-cli-classif-name
        AND buf_ext-classif.db-num = - 1
        and (buf_ext-classif.charkey_one = {&shop}
             or
             buf_ext-classif.charkey_one = {&stock}
             )
        and buf_ext-classif.key#_three = 0
        :
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Удалено &1", v-ii)
    {&display-count-message}.
  end.
  delete buf_ext-classif.
end.
v-ii = 0.
&scop my-message "Получение данных по объектам..."
{&display-message}.
_cli:
for each src_clients no-lock:
  if src_clients.obj-type = {&cmp}
  or src_clients.obj-type = {&prs} then next _cli.
  if src_clients.obj-name begins "ЗАКРЫТ!" then next _cli.
  if src_clients.stts > 0 then next _cli.
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Обработано &1 ", v-ii)
    {&display-count-message}.
  end.
  find first buf_ext-classif no-lock where
            buf_ext-classif.classif-subject = {&table_clients}
       and  buf_ext-classif.classif-name = v-cli-classif-name
       and buf_ext-classif.key#_one = src_clients.obj-code
       and buf_ext-classif.charkey_one = src_clients.obj-type
       and (buf_ext-classif.key#_three = 1
            or
            buf_ext-classif.key#_three = 2)
       no-error.
  if available buf_ext-classif then next _cli.

  /*
  if src_clients.is-prod = no
  and src_clients.buy-cons = no
  and src_clients.buy-gds = no
  and src_clients.buy-serv = no
  and src_clients.sup-cons = no
  and src_clients.sup-gds = no
  and src_clients.sup-serv = no then do:
    find first src_dis-card no-lock where
              src_dis-card.cli-type = src_clients.obj-type
          and src_dis-card.cli-code = src_clients.obj-code no-error.
    if available src_dis-card then do:
      next _cli.
    end.
  end.
  */

  case src_clients.obj-type:
    when {&shop} then do:
      find first src_shop no-lock where
                src_shop.obj-code = src_clients.obj-code no-error.
      if not available src_shop then do:
        &scop my-message substitute("Не найдена запись shop для записи clients &1&2 в БД-источнике", src_clients.obj-type, src_clients.obj-code)
        {&display-message}.
      end.
      run ref/extclas1.p (
                            input {&add-def}
                          ,input yes /*p-silent*/
                          ,input-output v-rec
                          ,input {&table_clients} /*p-classif-subject */
                          ,input v-cli-classif-name
                          ,input -1 /*p-db-num*/
                          ,input src_clients.obj-code /*p-Key#_One*/
                          ,input src_clients.host-code /*p-Key#_Two */
                          ,input 0  /*p-key#_Three*/
                          ,input src_clients.obj-type /*p-CharKey_One*/
                          ,input '' /*p-CharKey_Two*/
                          ,input src_clients.obj-name /*p-CharKey_Three*/
                          ,input 0 /*p-nonunique*/
                          ,input '' /*p-uniq-key-rec*/
                          ) no-error.
      if error-status:error then do:
        &scop my-message substitute('Ошибка при сохранении записи соответствия по клиенту &6 &1&2&3:&4&3&5' ~
                                     , src_clients.obj-type ~
                                     , src_clients.obj-code ~
                                     ,~{&new-line~} ~
                                     , error-status:get-message(1) ~
                                     , return-value ~
                                     , p-from-version ~
                                     )
        {&display-message}.
      end.
    end.
    when {&stock} then do:
      find first src_store no-lock where
                src_store.obj-code = src_clients.obj-code no-error.
      if not available src_store then do:
        &scop my-message substitute("Не найдена запись store для записи clients &1&2 в БД-источнике", src_clients.obj-type, src_clients.obj-code)
        {&display-message}.
      end.
      run ref/extclas1.p (
                            input {&add-def}
                          ,input yes /*p-silent*/
                          ,input-output v-rec
                          ,input {&table_clients} /*p-classif-subject */
                          ,input v-cli-classif-name
                          ,input -1 /*p-db-num*/
                          ,input src_clients.obj-code /*p-Key#_One*/
                          ,input src_clients.host-code /*p-Key#_Two */
                          ,input 0  /*p-key#_Three*/
                          ,input src_clients.obj-type /*p-CharKey_One*/
                          ,input '' /*p-CharKey_Two*/
                          ,input src_clients.obj-name /*p-CharKey_Three*/
                          ,input 0 /*p-nonunique*/
                          ,input ''  /*p-uniq-key-rec*/
                          ) no-error.
      if error-status:error then do:
        &scop my-message substitute('Ошибка при сохранении записи соответствия по клиенту &6 &1&2:&3&4&3&5' ~
                                     , src_clients.obj-type ~
                                     , src_clients.obj-code ~
                                     ,~{&new-line~} ~
                                     , error-status:get-message(1) ~
                                     , return-value ~
                                     , p-from-version )
        {&display-message}.
      end.
    end.
  end case.
end.
{&hide-count-message}.
&scop my-message substitute("Обработано &1 ", v-ii)
{&display-message}.