block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththclig.p $
$Archive: cmp/ththclig.p $

Интерактивное сведение по товарам клиентов-производителей

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
define variable vss-workfile    as character no-undo init "$Workfile: ththclig.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththclig.p $":U .
define variable vss-description as character no-undo init "Интерактивное сведение по товарам клиентов-производителей".
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
define variable v-ii-ok as integer no-undo .
define variable v-start as logical no-undo init yes.
define variable v-has-ss as logical no-undo .
define variable v-cli-classif-name as character no-undo .
define buffer src_clients for src.clients.
define buffer src_firm for src.firm.
define buffer src_person for src.person.
define buffer buf_clients for ub.clients.
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define buffer src_sysconf for src.sysconf.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_temp-sysconf for temp-sysconf.
define buffer src_temp-sysconf for src-temp-sysconf.

define variable log-file-name as character no-undo .

DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
define buffer src_code-range for ub.code-range.

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

find first src_code-range no-lock where
          src_code-range.range-type = {&loc-ss-code}
          or
          src_code-range.range-type = {&gbl-ss-code} no-error.
if available src_code-range then do:
  v-has-ss = yes.
end.


v-ii = 0.
&scop my-message "Поиск соответствий..."
{&display-message}.
_cli:
for each src_clients no-lock:
  if src_clients.obj-type = {&shop}
  or src_clients.obj-type = {&stock}
  or src_clients.is-prod = no
  then next _cli.
  find first buf_ext-classif no-lock where
            buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.classif-name = v-cli-classif-name
        and buf_ext-classif.key#_one = src_clients.obj-code
        and buf_ext-classif.charkey_one = src_clients.obj-type no-error.
  if not available buf_ext-classif
  or buf_ext-classif.uniq-key-rec <> '' then next _cli.
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Обработано &1 из них найдено соответствие для &2", v-ii, v-ii-ok)
    {&display-count-message}.
  end.
  v-uniq-key-rec = ''.

  case src_clients.obj-type:
    when {&cmp} then do:
      find first src_firm no-lock where
                src_firm.firm-code = src_clients.obj-code no-error.
      if not available src_firm then do:
        &scop my-message substitute("Не найдена запись firm для записи clients &1&2 в БД-источнике", src_clients.obj-type, src_clients.obj-code)
        {&display-message}.
      end.
      find buf_firm no-lock where
                buf_firm.inn = src_firm.inn no-error.
      if available buf_firm
      then do:
        /*если это своя фирма - то она в обоих БД дожна быть своя фирма*/
        find first buf_temp-sysconf no-lock where
                  buf_temp-sysconf.host-code = buf_firm.firm-code no-error.
        find first src_temp-sysconf no-lock where
                  src_temp-sysconf.host-code = src_firm.firm-code no-error.
        if not ((available buf_temp-sysconf and available src_temp-sysconf) /*обе свои фирмы*/
                or
                (not available buf_temp-sysconf and not available src_temp-sysconf) /*обе не свои фирмы*/
                )
        then do:
          if available src_temp-sysconf then do:
            &scop my-message substitute("Импорт &1&2: в СИСТЕМЕ &1 это СВОЯ ФИРМА , а в v16.0 (&3&4) - НЕТ" ~
                                        , src_clients.obj-type ~
                                        , src_clients.obj-code ~
                                        , ~{&cmp~} ~
                                        , buf_firm.firm-code ~
                                        , p-from-version )
            {&display-message}.
          end.
          else do:
            &scop my-message substitute("Импорт &1&2: в СИСТЕМЕ v16.0 это СВОЯ ФИРМА (&3&4), а в &5  - НЕТ" ~
                                      , src_clients.obj-type ~
                                      , src_clients.obj-code ~
                                      , ~{&cmp~} ~
                                      , buf_firm.firm-code ~
                                      , p-from-version )

            {&display-message}.
          end.
        end.
        else do:
          run get-by-good ( input src_clients.obj-type
                           ,input src_clients.obj-code
                           ,input src_clients.obj-name
                           ,input src_firm.city
                           ,input src_firm.addres1
                           ,output v-uniq-key-rec) no-error.
          if return-value = "return" then leave _cli.
        end.
      end.
    end.
    when {&prs} then do:
      find first src_person no-lock where
                src_person.psn-code = src_clients.obj-code no-error.
      if not available src_person then do:
        &scop my-message substitute("Не найдена запись person для записи clients &1&2 в БД-источнике", src_clients.obj-type, src_clients.obj-code)
        {&display-message}.
      end.
      else do:
        run get-by-good ( input src_clients.obj-type
                          ,input src_clients.obj-code
                           ,input src_clients.obj-name
                           ,input src_person.city
                           ,input src_person.address
                          ,output v-uniq-key-rec) no-error.
        if return-value = "return" then leave _cli.
      end.
      if v-uniq-key-rec > '' then v-ii-ok = v-ii-ok + 1.
    end.
  end case.
  v-rec = recid(buf_ext-classif).
  run ref/extclas1.p (
                        input {&update}
                      ,input yes /*p-silent*/
                      ,input-output v-rec
                      ,input {&table_clients} /*p-classif-subject */
                      ,input v-cli-classif-name
                      ,input buf_ext-classif.db-num /*p-db-num*/
                      ,input buf_ext-classif.Key#_One
                      ,input buf_ext-classif.key#_two
                      ,input buf_ext-classif.key#_three
                      ,input buf_ext-classif.charkey_one
                      ,input buf_ext-classif.CharKey_Two
                      ,input buf_ext-classif.CharKey_Three
                      ,input buf_ext-classif.nonunique
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
{&hide-count-message}.
&scop my-message substitute("Обработано &1 из них найдено соответствие для &2", v-ii, v-ii-ok)
{&display-message}.


procedure get-by-good :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-obj-name as character no-undo .
define input  parameter p-city as character no-undo .
define input  parameter p-address as character no-undo .
define output parameter p-uniq-key-rec as character no-undo .

define variable glog as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-uniq-key-rec as character no-undo .

define buffer buf_clients for ub.clients.

define buffer src_goods for src.goods.
define buffer src_bar-code for src.bar-code.
define buffer src_prod-bc for src.prod-bc.

define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf2_ext-classif for ub.ext-classif.


  do
  on error undo, return error return-value
  :

    _prod-bc:
    for each src_goods no-lock where
            src_goods.prod-type = p-obj-type
        and src_goods.prod-code = p-obj-code,
        each src_bar-code no-lock where
            src_bar-code.gds-code = src_goods.gds-code,
        each src_prod-bc no-lock where
            src_prod-bc.b-code = src_bar-code.b-code:
      if src_bar-code.in-code <> '' then next _prod-bc.
      if src_bar-code.part-code <> '' then next _prod-bc.
      if src_prod-bc.bc-on = no then next _prod-bc.
      if length(src_prod-bc.b-str) < 6 then next _prod-bc. /*это весовые*/
      if v-has-ss
      and length(src_prod-bc.b-str) < 10
      then do:
        find first src_code-range no-lock where
                  src_code-range.range-type = {&loc-ss-code}
              and src_code-range.first-code >= integer(src_prod-bc.b-str)
              and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
        if available src_code-range then next _prod-bc.
        find first src_code-range no-lock where
                  src_code-range.range-type = {&gbl-ss-code}
              and src_code-range.first-code >= integer(src_prod-bc.b-str)
              and src_code-range.last-code <= integer(src_prod-bc.b-str) no-error.
        if available src_code-range then next _prod-bc.
      end.
      find first buf_prod-bc no-lock where
                buf_prod-bc.b-str = src_prod-bc.b-str no-error.
      if available buf_prod-bc then do:
        find first buf_bar-code no-lock where
                buf_bar-code.b-code = buf_prod-bc.b-code no-error.
        if available buf_bar-code then do:
          if not ((buf_bar-code.unit-cli = src_bar-code.unit-cli)
                  and
                  (buf_bar-code.cli-base-rate = src_bar-code.cli-base-rate)) then next _prod-bc.
          find first buf_goods no-lock where
                    buf_goods.gds-code = buf_bar-code.gds-code no-error.

          if available buf_goods then do:

            /*по шкалам не будем проверять!!!!!!*/
            /*проверим по ед-изм*/
            if buf_goods.unit-base <> src_goods.unit-base
            then do:
              next _prod-bc.
            end. /*if buf_goods.unit-base = src_goods.unit-base then do:*/
            /*ПО ГРУППЕ НЕ ПРОВЕРЯЕМ!!!!*/
            find first buf_clients no-lock where
                      buf_clients.obj-type = buf_goods.prod-type
                  and buf_clients.obj-code = buf_goods.prod-code no-error.
            if available buf_clients then do:
              run gen-key-rec in this-procedure ( input {&table_clients}
                                                ,input (buffer buf_clients:handle)
                                                ,output v-uniq-key-rec).
              find first buf2_ext-classif no-lock where
                      buf2_ext-classif.classif-subject = {&table_clients}
                  and buf2_ext-classif.classif-name = v-cli-classif-name
                  and buf2_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.
              if available buf2_ext-classif then next _prod-bc.

              assign
              v-mess = substitute("Совпадает ДопБК &1&2"
                                   , src_prod-bc.b-str
                                   , {&new-line}) +
                       substitute("Производитель в БД &7&1" +
                                   "&2&3 &4&1" +
                                   "Город= &5&1" +
                                   "АДрес= &6&1"
                                   , {&new-line}
                                   , p-obj-type
                                   , p-obj-code
                                   , p-obj-name
                                   , p-city
                                   , p-address
                                   , p-from-version
                                   ) + {&new-line} +
                      substitute("Товар с БД &5 &1" +
                                 "код товара= &2&1" +
                                 "Артикул= &3&1" +
                                 "Название= &4&1"
                                 , {&new-line}
                                 , src_goods.gds-code
                                 , src_goods.artic
                                 , src_goods.gds-name
                                 , p-from-version
                                 ) + {&new-line} +
                       substitute("Производитель в СВОЕЙ БД&1" +
                                   "&2&3 &4&1" +
                                   "Город= &5&1" +
                                   "АДрес= &6&1"
                                   , {&new-line}
                                   , buf_clients.obj-type
                                   , buf_clients.obj-code
                                   , buf_clients.obj-name
                                   , p-city
                                   , p-address) + {&new-line} +
                      substitute("Товар с БД &5 &1" +
                                 "код товара= &2&1" +
                                 "Артикул= &3&1" +
                                 "Название= &4&1"
                                 , {&new-line}
                                 , buf_goods.gds-code
                                 , buf_goods.artic
                                 , buf_goods.gds-name
                                 , p-from-version
                                 ) + {&new-line} +
                     substitute("СЧИТАТЬ КЛИЕНТОВ СОВПАДАЮШИМИ И СВЯЗАТЬ?") .
              message
              v-mess
              view-as alert-box QUESTION buttons YES-NO-CANCEL update glog.
              if glog then do:
                run gen-key-rec in this-procedure ( input {&table_clients}
                                                  ,input (buffer buf_clients:handle)
                                                  ,output p-uniq-key-rec).

                return.
              end.
              if glog = ? then return "return".
            end. /*if available buf_clients then do:*/
          end. /*if available buf_goods then do:*/
        end. /*if available buf_bar-code then do:*/
      end. /*if available buf_prod-bc then do:*/
   end. /*for each src_goods no-lock where*/
end. /*doe*/

end procedure. /* get-by-good */