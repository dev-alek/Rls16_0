block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththclii.p $
$Archive: cmp/ththclii.p $

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

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththclii.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththclii.p $":U .
define variable vss-description as character no-undo init "Получение соответствия данных по клиентам из старой версии системы TH".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/key-rec.i }
{ cmp/thth150.i }
{ cmp/thth14.i }

define temp-table temp-sysconf no-undo like ub.sysconf.
define temp-table src-temp-sysconf no-undo like src.sysconf.


define variable p-from-version as character no-undo .
define variable v-src-full-name as character no-undo .
define variable v-upper-code as integer no-undo .
define variable v-level as integer no-undo .
define variable v-counter as integer no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-next as integer no-undo .
define variable v-ii-next-done as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable v-start as logical no-undo init yes.
define variable imp-d-card as character no-undo .
define variable v-cli-classif-name as character no-undo .


define buffer src_clients for src.clients.
define buffer src_firm for src.firm.
define buffer src2_firm for src.firm.
define buffer src_person for src.person.
define buffer buf_clients for ub.clients.
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define buffer src_dis-card for src.dis-card.
define buffer src_sysconf for src.sysconf.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_temp-sysconf for temp-sysconf.
define buffer src_temp-sysconf for src-temp-sysconf.

define variable log-file-name as character no-undo .

define temp-table temp-person  no-undo like src.person
index pi is unique primary psn-code
index iinn inn
.
define stream instream.

define temp-table temp-dis-card no-undo
like src.dis-card.

define buffer temp-src2_person for temp-person.


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

&scop my-message "Очищаем данные соответствий, полученные ПОСЛЕ upgrade или последнего завершенного переноса..."
{&display-message}.
for each buf_ext-classif WHERE
            buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name = v-cli-classif-name
        AND buf_ext-classif.db-num = - 1
        and (buf_ext-classif.charkey_one = {&prs}
             or
             buf_ext-classif.charkey_one = {&cmp}
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
&scop my-message "Копирование данных по СВОИМ ФИРМАМ во временную таблицу..."
{&display-message}.
for each buf_sysconf no-lock :
  create buf_temp-sysconf.
  buffer-copy buf_sysconf to buf_temp-sysconf.
end.
for each src_sysconf no-lock :
  create src_temp-sysconf.
  buffer-copy src_sysconf to src_temp-sysconf.
end.

for each temp-src2_person:
  delete temp-src2_person.
end.
&scop my-message "Копирование данных по ФИЗЛИЦАМ С ИНН во временную таблицу..."
{&display-message}.
for each src_person no-lock:
  if src_person.inn <> '' then do:
    create temp-src2_person.
    buffer-copy src_person to temp-src2_person.
  end.
end.


&scop my-message substitute("Импорт из файла-списка ДК, которые НЕ БУДЕМ ЗАКАЧИВАТЬ в НАШУ БД")
{&display-message}.


v-ii = 0.
&scop my-message "Поиск соответствий..."
{&display-message}.
_cli:
for each src_clients no-lock:
  if src_clients.obj-type = {&shop}
  or src_clients.obj-type = {&stock}
  then next _cli.
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Обработано &1 из них найдено соотв для &2 пропущено &3 уже сведено ранее &4", v-ii, v-ii-ok, v-ii-next, v-ii-next-done)
    {&display-count-message}.
  end.
  v-uniq-key-rec = ''.
  /*поищем - может быть там уже есть соответствие по старым клиентам или послуенное при сведении предыдущих магазинов*/
  find first buf_ext-classif no-lock where
            buf_ext-classif.classif-subject = {&table_clients}
       and  buf_ext-classif.classif-name = v-cli-classif-name
       and buf_ext-classif.key#_one = src_clients.obj-code
       and buf_ext-classif.charkey_one = src_clients.obj-type
       and (buf_ext-classif.key#_three = 1
            or
            buf_ext-classif.key#_three = 2)
       no-error.
  if available buf_ext-classif then do:
    v-ii-next-done = v-ii-next-done + 1.
    next _cli.
  end.


  case src_clients.obj-type:
    when {&cmp} then do:
      find first src_temp-sysconf no-lock where
                src_temp-sysconf.host-code = src_clients.obj-code no-error.
      find first src_firm no-lock where
                src_firm.firm-code = src_clients.obj-code no-error.
      if not available src_firm then do:
        &scop my-message substitute("Не найдена запись firm для записи clients &1&2 в БД-источнике", src_clients.obj-type, src_clients.obj-code)
        {&display-message}.
      end.
      if src_firm.inn = '' then do:
        /*отсеем держателей карт*/
        /*
        if src_clients.is-prod = no
        and src_clients.buy-cons = no
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
        /*
        &scop my-message substitute("&1&2 ПУСТОЙ {&abbr_inn_allshift}!!!!", src_clients.obj-type, src_clients.obj-code )
        {&display-message}.
        */
        v-uniq-key-rec = ''.
      end.
      else do:
        v-start = yes.
        find first src2_firm no-lock where
                src2_firm.inn = src_firm.inn
            and (src2_firm.firm-code > src_firm.firm-code
                 or
                 src2_firm.firm-code < src_firm.firm-code)
                no-error.
        if available src2_firm then do:
          &scop my-message substitute("&1&2 НЕУНИКАЛЬНЫЙ {&abbr_inn_allshift}!!!!", src_clients.obj-type, src_clients.obj-code )
          {&display-message}.
          v-uniq-key-rec = ''.
          v-start = no.
        end.
        find first temp-src2_person no-lock where
                  temp-src2_person.inn = src_firm.inn no-error.
        if available temp-src2_person then do:
          &scop my-message substitute("&1&2 НЕУНИКАЛЬНЫЙ {&abbr_inn_allshift}!!!!", src_clients.obj-type, src_clients.obj-code )
          {&display-message}.
          v-uniq-key-rec = ''.
          v-start = no.
        end.
        if v-start then  do:
          find buf_firm no-lock where
                    buf_firm.inn = src_firm.inn no-error.
          if available buf_firm
          and not can-find (first buf_person where buf_person.inn = src_firm.inn) then do:
            /*если это своя фирма - то она в обоих БД дожна быть своя фирма*/
            find first buf_temp-sysconf no-lock where
                      buf_temp-sysconf.host-code = buf_firm.firm-code no-error.
            if not ((available buf_temp-sysconf and available src_temp-sysconf) /*обе свои фирмы*/
                    or
                    (not available buf_temp-sysconf and not available src_temp-sysconf) /*обе не свои фирмы*/
                    )
            then do:
              if available src_temp-sysconf then do:
                &scop my-message substitute("Импорт &1&2: в СИСТЕМЕ &5 это СВОЯ ФИРМА , а в v16.0  (&3&4) - НЕТ" ~
                                            , src_clients.obj-type ~
                                            , src_clients.obj-code ~
                                            , ~{&cmp~} ~
                                            , buf_firm.firm-code ~
                                            , p-from-version)
                {&display-message}.
              end.
              else do:
                &scop my-message substitute("Импорт &1&2: в v16.0 это СВОЯ ФИРМА (&3&4), а в &5  - НЕТ" ~
                                          , src_clients.obj-type ~
                                          , src_clients.obj-code ~
                                          , ~{&cmp~} ~
                                          , buf_firm.firm-code ~
                                          , p-from-version )

                {&display-message}.
              end.
            end.
            else do:
              find first buf_clients no-lock where
                        buf_clients.obj-type = {&cmp}
                    and buf_clients.obj-code = buf_firm.firm-code.
              run gen-key-rec in this-procedure ( input {&table_clients}
                                                ,input (buffer buf_clients:handle)
                                                ,output v-uniq-key-rec).
            end.
          end.
          else do:
            if AMBIGUOUS(buf_firm)
            or available buf_person then do:
              &scop my-message substitute("Импорт &1&2: больше одного контрагента с {&abbr_inn_allshift}=&3", src_clients.obj-type, src_clients.obj-code, src_firm.inn )
              {&display-message}.
              v-uniq-key-rec = ''.
            end.
          end.
        end. /*if v-start*/
      end. /*src.firm.inn <> ''*/
      run ref/extclas1.p (
                            input {&add-def}
                          ,input yes /*p-silent*/
                          ,input-output v-rec
                          ,input {&table_clients} /*p-classif-subject */
                          ,input v-cli-classif-name
                          ,input -1 /*p-db-num*/
                          ,input src_clients.obj-code /*p-Key#_One*/
                          ,input (if available src_temp-sysconf then 1 else 0) /*p-Key#_Two */
                          ,input 0  /*p-key#_Three*/
                          ,input src_clients.obj-type /*p-CharKey_One*/
                          ,input src_firm.inn /*p-CharKey_Two*/
                          ,input src_clients.obj-name /*p-CharKey_Three*/
                          ,input 0 /*p-nonunique*/
                          ,input v-uniq-key-rec /*p-uniq-key-rec*/
                          ) no-error.
      if error-status:error then do:
        &scop my-message substitute('Ошибка при сохранении записи соответствия по клиенту &6 &1&2&3:&4&3&5' ~
                                     , src_clients.obj-type ~
                                     , src_clients.obj-code ~
                                     ,~{&new-line~} ~
                                     , error-status:get-message(1) ~
                                     , return-value ~
                                     , p-from-version )
        {&display-message}.
      end.
      if v-uniq-key-rec > '' then v-ii-ok = v-ii-ok + 1.
    end.
    when {&prs} then do:
      find first src_person no-lock where
                src_person.psn-code = src_clients.obj-code no-error.
      if not available src_person then do:
        &scop my-message substitute("Не найдена запись person для записи clients &1&2 в БД-источнике", src_clients.obj-type, src_clients.obj-code)
        {&display-message}.
      end.
      if src_person.inn = '' then do:
        v-uniq-key-rec = ''.
      end.
      else do:
        v-start = yes.
        find first src2_firm no-lock where
                src2_firm.inn = src_person.inn no-error.
        if available src2_firm then do:
          &scop my-message substitute("&1&2 НЕУНИКАЛЬНЫЙ {&abbr_inn_allshift}!!!!", src_clients.obj-type, src_clients.obj-code )
          {&display-message}.
          v-uniq-key-rec = ''.
          v-start = no.
        end.
        find first temp-src2_person no-lock where
                  temp-src2_person.inn = src_person.inn
              and (temp-src2_person.psn-code > src_person.psn-code
                   or
                   temp-src2_person.psn-code < src_person.psn-code)
                  no-error.
        if available temp-src2_person then do:
          &scop my-message substitute("&1&2 НЕУНИКАЛЬНЫЙ {&abbr_inn_allshift}!!!!", src_clients.obj-type, src_clients.obj-code )
          {&display-message}.
          v-uniq-key-rec = ''.
          v-start = no.
        end.
        if v-start then do:
          find buf_person no-lock where
                    buf_person.inn = src_person.inn no-error.
          if available buf_person
          and not can-find (first buf_firm where buf_firm.inn = src_firm.inn) then do:
            find first buf_clients no-lock where
                      buf_clients.obj-type = {&prs}
                  and buf_clients.obj-code = buf_person.psn-code.
            run gen-key-rec in this-procedure ( input {&table_clients}
                                              ,input (buffer buf_clients:handle)
                                              ,output v-uniq-key-rec).
          end.
          else do:
            if AMBIGUOUS(buf_person)
            or available buf_firm then do:
              &scop my-message substitute("Импорт &1&2: больше одного контрагента с {&abbr_inn_all_shift}=&3", src_clients.obj-type, src_clients.obj-code, src_person.inn )
              {&display-message}.
              v-uniq-key-rec = ''.
            end.
          end.
        end. /*if v-start then do:*/
      end.
      run ref/extclas1.p (
                            input {&add-def}
                          ,input yes /*p-silent*/
                          ,input-output v-rec
                          ,input {&table_clients} /*p-classif-subject */
                          ,input v-cli-classif-name
                          ,input -1 /*p-db-num*/
                          ,input src_clients.obj-code /*p-Key#_One*/
                          ,input 0 /*p-Key#_Two */
                          ,input 0  /*p-key#_Three*/
                          ,input src_clients.obj-type /*p-CharKey_One*/
                          ,input src_person.inn /*p-CharKey_Two*/
                          ,input src_clients.obj-name /*p-CharKey_Three*/
                          ,input 0 /*p-nonunique*/
                          ,input v-uniq-key-rec /*p-uniq-key-rec*/
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
      if v-uniq-key-rec > '' then v-ii-ok = v-ii-ok + 1.
    end.
  end case.
end.
{&hide-count-message}.
&scop my-message substitute("Обработано &1 из них найдено соотв для &2 пропущено &3 уже сведено ранее &4", v-ii, v-ii-ok, v-ii-next, v-ii-next-done)
{&display-message}.