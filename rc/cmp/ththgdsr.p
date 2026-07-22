block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththgdsr.p $
$Archive: cmp/ththgdsr.p $

Детальный отчет по соответствиям и их отсутствию TH старой версии и v16.0

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/25/10
Author: Bakhtadze Natalya
Creation date: 04/25/10

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththgdsr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththgdsr.p $":U .
define variable vss-description as character no-undo init "Детальный отчет по соответствиям и их отсутствию TH старой версии и v16.0".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/ththgdsr.i "shared" }
{ ref/extclass.i }
{ cmp/thth150.i }
{ cmp/thth14.i }

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
define variable v-has-ss as logical no-undo .
define variable v-num-src-gds-prt as integer no-undo .
define variable v-num-gds-prt as integer no-undo .
define variable v-src-empty-scale  as integer no-undo .
define variable v-empty-scale  as integer no-undo .
define variable v-goods-uniq-key-rec as character no-undo .
define variable v-clients-uniq-key-rec as character no-undo .
define variable v-pbc as integer no-undo .
define variable v-pbc-ok as integer no-undo .
define variable v-b-str as character no-undo .
define variable v-rid as recid no-undo .
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.
define variable dif-pdbc as logical no-undo initial no.
define variable pbc-veto  as logical no-undo.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-grp-name as character no-undo .
define variable v-jj as integer   no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .


define buffer src_goods for src.goods.
define buffer src_bar-code for src.bar-code.
define buffer src_code-range for src.code-range.
define buffer src_gds-prt for src.gds-prt.
define buffer src_clients for src.clients.
define buffer buf_goods for ub.goods.
define buffer buf2_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_clients for ub.clients.
define buffer clients_ext-classif for ub.ext-classif.


define variable log-file-name as character no-undo .
define variable v-deleted-goods as logical no-undo .
define variable p-from-version as character no-undo .

DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
DEFINE BUFFER buf2_ext-classif FOR ub.ext-classif.






&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

/*очищаем все*/
log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).

if num-entries(p-parameter, {&delim-par}) <> 2 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 2"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.
assign
v-deleted-goods = logical(entry(1, p-parameter, {&delim-par} ))
p-from-version = entry(2, p-parameter, {&delim-par} )
.
case p-from-version:
  when {&thth150-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th150}
    v-cli-classif-name = {&extclass_clients_th-th150}
    .
  end.
  when {&thth14-from-version} then do:
    assign
    v-classif-name = {&extclass_goods_th-th14}
    v-cli-classif-name = {&extclass_clients_th-th14}
    .
  end.
end case.

v-ii = 0.
find first src_code-range no-lock where
          src_code-range.range-type = {&loc-ss-code}
          or
          src_code-range.range-type = {&gbl-ss-code} no-error.
if available src_code-range then do:
  v-has-ss = yes.
end.
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

run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-gds-ref}
    ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output dif-pdbc
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  '':U /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-gds-ref}
    ,input  {&attr-gds-ref_pbc-veto} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output pbc-veto
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.

for each temp-bind:
  delete temp-bind.
end.
for each temp-prod-bc:
  delete temp-prod-bc.
end.

&scop my-message substitute("Просматриваем товары &1...", p-from-version)
{&display-message}.

_goods:
for each src_goods no-lock :
  if src_goods.stts <> integer({&current-status-int})
  and not v-deleted-goods  then next.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Обработано &1 записей &2" ~
                                      , v-ii ~
                                      , p-from-version ~
                                      )
    {&display-count-message}.
  end.
  v-ii = v-ii + 1.
  find first temp-bind where
            temp-bind.src-gds-code = src_goods.gds-code no-error.
  if not available temp-bind then do:
    create temp-bind.
    assign
    temp-bind.src-gds-code  = src_goods.gds-code
    temp-bind.src-artic     = src_goods.artic
    temp-bind.src-prod-type = src_goods.prod-type
    temp-bind.src-prod-code = src_goods.prod-code
    temp-bind.src-gds-name  = src_goods.gds-name
    temp-bind.src-unit-base = src_goods.unit-base
    temp-bind.src-stts = src_goods.stts
    .
    find first src_bar-code no-lock where
              src_bar-code.gds-code = src_goods.gds-code
         and src_bar-code.unit-cli = src_goods.unit-base
         and src_bar-code.node-code = v-src-empty-scale
         and src_bar-code.in-code = ''
         and src_bar-code.part-code = '' no-error.
    if not available src_bar-code then do:
       &scop my-message substitute("Для товара &2 с кодом &1 не найден корневой бар-код", src_goods.gds-code, p-from-version )
       {&display-message}.
    end.
    run src_grplib-get-full-name in this-procedure ( input src_goods.grp-code
                                                    ,output temp-bind.src-grp-name) no-error.
    find first src_clients no-lock where
              src_clients.obj-type = src_goods.prod-type
          and src_clients.obj-code = src_goods.prod-code no-error.
    if not available src_clients then do:
       &scop my-message substitute("Для товара &4 с кодом &1 не найден произщводитель &2&3", src_goods.gds-code, src_goods.prod-type, src_goods.prod-code, p-from-version)
       {&display-message}.
    end.
    else do:
      temp-bind.src-prod-name = src_clients.obj-name.
    end.
  end.
  v-goods-uniq-key-rec = ''.
  find first buf_ext-classif no-lock where
            buf_ext-classif.classif-subject = {&table_goods}
       and  buf_ext-classif.classif-name = v-classif-name
       and buf_ext-classif.key#_one = src_goods.gds-code
       no-error.

  if available buf_ext-classif then do:
    temp-bind.has-bind = 1.
    if not (buf_ext-classif.key#_two = src_goods.prod-code
           and
           buf_ext-classif.charkey_two = src_goods.prod-type)
    then do:
      assign
      temp-bind.bind-producer = "п".
    end.
    if buf_ext-classif.charkey_one <> src_goods.artic then do:
      assign
      temp-bind.bind-artic = "а".
    end.
    if entry(1, buf_ext-classif.charkey_three, {&delim-par}) <> src_goods.gds-name then do:
      assign
      temp-bind.bind-name = "н".
    end.
    if num-entries(buf_ext-classif.charkey_three, {&delim-par}) < 2
    or entry(2, buf_ext-classif.charkey_three, {&delim-par}) <> src_goods.unit-base then do:
      assign
      temp-bind.bind-unit-base = "и".
    end.
    if buf_ext-classif.uniq-key-rec = '' then do:
      assign
      temp-bind.old-v151 = -1.
      /*не известна связь с 16.0 версией - заполним ДопБк и отвалим*/
      run fill-prod-bc-src in this-procedure ( input temp-bind.src-gds-code
                                          ,input temp-bind.src-b-code
                                          ,input temp-bind.src-unit-base
                                          ,input 0
                                          ,input 0
                                          ,input ''
                                          ).

      /*
      assign
      temp-bind.old-v151-artic = "А"
      temp-bind.old-v151-name = "Н"
      temp-bind.old-v151-unit-base = "И"
      temp-bind.old-v151-stts = "У"
      temp-bind.old-v151-grp = "Г"
      temp-bind.old-v151-prod = "П"
      .
      */
      next _goods.
    end.
    else do:
      assign
      temp-bind.old-v151 = 0.
      /*ищем товар по соответствию*/
      run gen-row-keyr in this-procedure ( input buf_ext-classif.uniq-key-rec
                                          ,input ? /*p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
                                          ,input "ub"
                                          ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                          ,input no-lock
                                          ,output v-tbl-row
                                          ,output v-tbl-name) no-error.
      find first buf_goods no-lock where
                rowid(buf_goods) = v-tbl-row no-error.
      if not available buf_goods then do:
        /*не нашли по связи с 16.0 версией - заполним ДопБк и отвалим*/
        run fill-prod-bc-src in this-procedure ( input temp-bind.src-gds-code
                                            ,input temp-bind.src-b-code
                                            ,input temp-bind.src-unit-base
                                            ,input 0
                                            ,input 0
                                            ,input ''
                                           ).
        next _goods.
      end.
      assign
      temp-bind.old-v151       = 1
      temp-bind.trg-gds-code  = buf_goods.gds-code
      temp-bind.trg-artic     = buf_goods.artic
      temp-bind.trg-prod-type = buf_goods.prod-type
      temp-bind.trg-prod-code = buf_goods.prod-code
      temp-bind.trg-gds-name  = buf_goods.gds-name
      temp-bind.trg-unit-base = buf_goods.unit-base
      temp-bind.trg-stts      = buf_goods.stts
      .
      if buf_goods.artic <> src_goods.artic then do:
        assign
        temp-bind.old-v151-artic = "А".
      end.
      if buf_goods.gds-name <> src_goods.gds-name then do:
        assign
        temp-bind.old-v151-name = "Н".
      end.
      if buf_goods.unit-base <> src_goods.unit-base then do:
        assign
        temp-bind.old-v151-unit-base = "И".
      end.
      if buf_goods.stts <> src_goods.stts then do:
        assign
        temp-bind.old-v151-stts = "У".
      end.
      find first buf_bar-code no-lock where
                buf_bar-code.gds-code = buf_goods.gds-code
          and buf_bar-code.unit-cli = buf_goods.unit-base
          and buf_bar-code.node-code = v-empty-scale
          and buf_bar-code.in-code = ''
          and buf_bar-code.part-code = '' no-error.
      if not available buf_bar-code then do:
        &scop my-message substitute("Для товара v16.0 с кодом &1 не найден корневой бар-код", buf_goods.gds-code)
        {&display-message}.
      end.
      else do:
        temp-bind.trg-b-code = buf_bar-code.b-code.
      end.
      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code
                                                  ,output temp-bind.trg-grp-name) no-error.
      if temp-bind.src-grp-name <> temp-bind.trg-grp-name then do:
        assign
        temp-bind.old-v151-grp = "Г".
      end.
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_goods.prod-type
            and buf_clients.obj-code = buf_goods.prod-code no-error.
      if not available buf_clients then do:
        &scop my-message substitute("Для товара v16.0 с кодом &1 не найден производитель &2&3", buf_goods.gds-code, buf_goods.prod-type, buf_goods.prod-code)
        {&display-message}.
      end.
      else do:
        temp-bind.trg-prod-name = buf_clients.obj-name.
      end.

      /*найдем соответствие производителя*/
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_goods.prod-type
            and buf_clients.obj-code = buf_goods.prod-code no-error.
      if available buf_clients then do:
        run gen-key-rec in this-procedure ( input {&table_clients}
                                          ,input (buffer buf_clients:handle)
                                          ,output v-clients-uniq-key-rec).
        find first clients_ext-classif share-lock where
                  clients_ext-classif.classif-subject  = {&table_clients}
              and  clients_ext-classif.classif-name  = v-cli-classif-name
              and clients_ext-classif.db-num = -1
              and clients_ext-classif.charkey_one = src_goods.prod-type
              and clients_ext-classif.key#_one = src_goods.prod-code
              and clients_ext-classif.uniq-key-rec = v-clients-uniq-key-rec no-error .
        if available clients_ext-classif then do:
          if not (clients_ext-classif.key#_one = temp-bind.src-prod-code
                  and
                  clients_ext-classif.charkey_one = temp-bind.src-prod-type) then do:
            assign
            temp-bind.old-v151-prod = "П".
          end.
          if temp-bind.src-prod-name <> temp-bind.trg-prod-name then do:
            assign
            temp-bind.bind-producer-name = "п".
          end.
        end. /*if available clients_ext-classif then do:*/
      end.
      else do:
        assign
        temp-bind.old-v151-prod = "П".
      end.
      /*заполним ДопБк и отвалим*/
      run fill-prod-bc-src in this-procedure ( input temp-bind.src-gds-code
                                          ,input temp-bind.src-b-code
                                          ,input temp-bind.src-unit-base
                                          ,input temp-bind.trg-gds-code
                                          ,input temp-bind.trg-b-code
                                          ,input temp-bind.trg-unit-base
                                          ).

    end.
  end.  /*if available buf_ext-classif then do:*/
  else do:
    if src_goods.stts = integer({&current-status-int}) then do:
      assign
      /*temp-bind.old-v151-artic = "А"
      temp-bind.old-v151-name = "Н"
      temp-bind.old-v151-name = "И"
      temp-bind.old-v151-name = "У"
      temp-bind.old-v151-grp = "Г"
      temp-bind.old-v151-prod = "П"
      */
      temp-bind.has-bind = 0
      .
      /*нет с связи с 15 версией - заполним ДопБк и отвалим*/
      run fill-prod-bc-src in this-procedure ( input temp-bind.src-gds-code
                                          ,input temp-bind.src-b-code
                                          ,input temp-bind.src-unit-base
                                          ,input 0
                                          ,input 0
                                          ,input ''
                                          ).
    end.
    next _goods.
  end.  /*else if available buf_ext-classif then do:*/
  release temp-bind.
end. /*for each src_goods no-lock:*/
/*пройдем по v151 найдем непривязанные и т.д*/
&scop my-message "Просматриваем товары v16.0..."
{&display-message}.
define variable v-kk as integer no-undo .
for each buf_goods no-lock :
  if v-kk modulo 10 = 0 then do:
    &scop my-count-message substitute("Обработано &1 записей v16.0" ~
                                      , v-kk ~
                                      )
    {&display-count-message}.
  end.
  v-kk = v-kk + 1.
  run gen-key-rec in this-procedure ( input {&table_goods}
                                     ,input (buffer buf_goods:handle)
                                     ,output v-uniq-key-rec).
  find first buf_bar-code no-lock where
            buf_bar-code.gds-code = buf_goods.gds-code
      and buf_bar-code.unit-cli = buf_goods.unit-base
      and buf_bar-code.node-code = v-empty-scale
      and buf_bar-code.in-code = ''
      and buf_bar-code.part-code = '' no-error.
  if not available buf_bar-code then do:
    &scop my-message substitute("Для товара v16.0 с кодом &1 не найден корневой бар-код", buf_goods.gds-code)
    {&display-message}.
  end.
  else do:

  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = buf_goods.prod-type
        and buf_clients.obj-code = buf_goods.prod-code no-error.


  run grplib-get-full-name in this-procedure ( input buf_goods.grp-code
                                              ,output v-grp-name) no-error.


  v-jj = 0.
  for each buf_ext-classif no-lock where
            buf_ext-classif.classif-subject = {&table_goods}
       and  buf_ext-classif.classif-name = v-classif-name
       and  buf_ext-classif.uniq-key-rec = v-uniq-key-rec:
    v-jj = v-jj + 1.
    find first temp-bind where
              temp-bind.trg-gds-code = buf_goods.gds-code
          and temp-bind.src-gds-code = buf_ext-classif.key#_one no-error.
    if not available temp-bind then do:
      create temp-bind.
      assign
      temp-bind.src-gds-code   = buf_ext-classif.key#_one
      temp-bind.src-artic      = ''
      temp-bind.src-prod-type  = ''
      temp-bind.src-prod-code  = 0
      temp-bind.src-gds-name   = ''
      temp-bind.src-unit-base  = ''
      temp-bind.src-b-code     = 0
      temp-bind.src-stts       = 0
      temp-bind.src-grp-name   = ''
      temp-bind.src-prod-name  = ''
      temp-bind.has-bind       = 1
      /*
      temp-bind.bind-producer  = "п"
      temp-bind.bind-producer-name  = "п"
      temp-bind.bind-artic     = "a"
      temp-bind.bind-name      = "н"
      temp-bind.bind-unit-base = "и"
      */
      temp-bind.trg-gds-code   = buf_goods.gds-code
      temp-bind.trg-artic      = buf_goods.artic
      temp-bind.trg-prod-type  = buf_goods.prod-type
      temp-bind.trg-prod-code  = buf_goods.prod-code
      temp-bind.trg-gds-name   = buf_goods.gds-name
      temp-bind.trg-unit-base  = buf_goods.unit-base
      temp-bind.trg-stts       = buf_goods.stts
      temp-bind.trg-b-code     = (if available buf_bar-code then buf_bar-code.b-code else 0)
      temp-bind.trg-grp-name  = v-grp-name
      temp-bind.trg-prod-name = (if available buf_clients then buf_clients.obj-name else '')
      /*
      temp-bind.old-v151-producer = "П"
      temp-bind.old-v151-artic = "А"
      temp-bind.old-v151-name = "Н"
      temp-bind.old-v151-Unit-base = "И"
      temp-bind.old-v151-stts = "У"
      temp-bind.old-v151-grp = "Г"
      */
      .

      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code
                                                  ,output temp-bind.trg-grp-name) no-error.
      find first buf_clients no-lock where
              buf_clients.obj-type = buf_goods.prod-type
          and buf_clients.obj-code = buf_goods.prod-code no-error.
      if available buf_clients then do:
        assign
        temp-bind.trg-prod-name = buf_clients.obj-name.
      end.

      run fill-prod-bc-trg in this-procedure ( input temp-bind.src-gds-code
                                          ,input temp-bind.src-b-code
                                          ,input temp-bind.src-unit-base
                                          ,input temp-bind.trg-gds-code
                                          ,input temp-bind.trg-b-code
                                          ,input temp-bind.trg-unit-base
                                          ).
      release temp-bind.
    end. /*if not available temp-bind then do:*/
    else do:

    end. /*else if not available temp-bind then do:*/
  end. /*  for each buf_ext-classif no-lock where*/
  if v-jj > 1 then do:
    for each temp-bind where
            temp-bind.trg-gds-code = buf_goods.gds-code:
      assign
      temp-bind.old-v151 = v-jj.
    end.
  end.
  if v-jj = 0 then do:
    find first temp-bind where
              temp-bind.src-b-code = 0
         and temp-bind.trg-b-code = buf_goods.gds-code no-error.
    if not available temp-bind then do:
      create temp-bind.
      assign
      temp-bind.src-gds-code   = 0
      temp-bind.src-artic      = ''
      temp-bind.src-prod-type  = ''
      temp-bind.src-prod-code  = 0
      temp-bind.src-gds-name   = ''
      temp-bind.src-unit-base  = ''
      temp-bind.src-b-code     = 0
      temp-bind.src-stts       = 0
      temp-bind.src-grp-name   = ''
      temp-bind.src-prod-name  = ''
      temp-bind.has-bind       = -1
      /*
      temp-bind.bind-producer  = "п"
      temp-bind.bind-producer-name  = "п"
      temp-bind.bind-artic     = "a"
      temp-bind.bind-name      = "н"
      temp-bind.bind-unit-base = "и"
      */
      temp-bind.trg-gds-code   = buf_goods.gds-code
      temp-bind.trg-artic      = buf_goods.artic
      temp-bind.trg-prod-type  = buf_goods.prod-type
      temp-bind.trg-prod-code  = buf_goods.prod-code
      temp-bind.trg-gds-name   = buf_goods.gds-name
      temp-bind.trg-unit-base  = buf_goods.unit-base
      temp-bind.trg-stts       = buf_goods.stts
      temp-bind.trg-b-code     = (if available buf_bar-code then buf_bar-code.b-code else 0)
      /*
      temp-bind.old-v151-producer = "П"
      temp-bind.old-v151-artic = "А"
      temp-bind.old-v151-name = "Н"
      temp-bind.old-v151-Unit-base = "И"
      temp-bind.old-v151-stts = "У"
      temp-bind.old-v151-grp = "Г"
      */
      temp-bind.old-v151 = 0
      .
      run grplib-get-full-name in this-procedure ( input buf_goods.grp-code
                                                  ,output temp-bind.trg-grp-name) no-error.
      find first buf_clients no-lock where
              buf_clients.obj-type = buf_goods.prod-type
          and buf_clients.obj-code = buf_goods.prod-code no-error.
      if available buf_clients then do:
        assign
        temp-bind.trg-prod-name = buf_clients.obj-name.
      end.

      run fill-prod-bc-trg in this-procedure ( input temp-bind.src-gds-code
                                          ,input temp-bind.src-b-code
                                          ,input temp-bind.src-unit-base
                                          ,input temp-bind.trg-gds-code
                                          ,input temp-bind.trg-b-code
                                          ,input temp-bind.trg-unit-base
                                          ).
      release temp-bind.
    end. /*if not available temp-bind then do:*/
  end. /*if v-jj = 0 then do:*/
end. /*for each buf_goods no-lock:*/
/*выясним какие допбк по каждому конкретному товаров частично связаны а частично нет или не стем товаров*/
&scop my-message "Проверяем правильность привязок ДопбК..."
{&display-message}.

define variable v-v151-gds-code as integer   no-undo .
define variable v-v150-gds-code as integer   no-undo .
define variable v-corr-bind as character no-undo .
for each temp-prod-bc where temp-prod-bc.src-gds-code > 0
break
by temp-prod-bc.src-gds-code:
  if first-of(temp-prod-bc.src-gds-code) then do:
     assign
     v-v151-gds-code = temp-prod-bc.v151-gds-code
     v-corr-bind = ""
     .
  end.
  if temp-prod-bc.v151-gds-code <> v-v151-gds-code
  or temp-prod-bc.correct-pbc-bind <> ""
  then do:
    v-corr-bind = "Д".
  end.
  if last-of(temp-prod-bc.src-gds-code) then do:
    for each temp-bind where
            temp-bind.src-gds-code = temp-prod-bc.src-gds-code:
      assign
      temp-bind.old-v151-pbc = v-corr-bind.
    end.
  end.
end.
for each temp-prod-bc where temp-prod-bc.trg-gds-code > 0
break
by temp-prod-bc.trg-gds-code:
  if first-of(temp-prod-bc.trg-gds-code) then do:
     assign
     v-v150-gds-code = temp-prod-bc.old-gds-code
     v-corr-bind = ""
     .
  end.
  if temp-prod-bc.old-gds-code <> v-v150-gds-code
  or temp-prod-bc.correct-pbc-bind <> ""
  then do:
    v-corr-bind = "Д".
  end.
  if last-of(temp-prod-bc.trg-gds-code) then do:
    for each temp-bind where
            temp-bind.trg-gds-code = temp-prod-bc.trg-gds-code:
      assign
      temp-bind.old-v151-pbc = v-corr-bind.
    end.
  end.
end.
&scop my-message "Отсеиваем проблемные товары..."
{&display-message}.

for each temp-bind:
  v-ii = v-ii + 1.
  assign
  temp-bind.correct-bind = temp-bind.bind-artic  +
                           temp-bind.bind-producer  +
                           temp-bind.bind-producer-name  +
                           temp-bind.bind-name  +
                           temp-bind.bind-unit-base  +
                           (if temp-bind.old-v151 = 1 then ' ' else  string(temp-bind.old-v151)) +
                           temp-bind.old-v151-artic +
                           temp-bind.old-v151-producer +
                           temp-bind.old-v151-name     +
                           temp-bind.old-v151-unit-base +
                           temp-bind.old-v151-stts  +
                           temp-bind.old-v151-grp       +
                           temp-bind.old-v151-pbc
  .
  if trim(temp-bind.correct-bind) <> '' then do:
    v-jj = v-jj + 1.
  end.
end.



&scop my-message substitute("Обработано связей &1, из них найдено проблем &2",  ~
                            v-ii, v-jj)
{&display-message}.
{&hide-count-message}.

&scop my-message substitute("Нажмите ВЫХОД - начнется печать отчета!")
{&display-message}.

procedure barcodcr :

  define input  parameter p-gds-code      like ub.bar-code.gds-code      no-undo .
  define input  parameter p-node-code     like ub.bar-code.node-code     no-undo .
  define input  parameter p-part-code     like ub.bar-code.part-code     no-undo .
  define input  parameter p-in-code       like ub.bar-code.in-code       no-undo .
  define input  parameter p-unit-cli      like ub.bar-code.unit-cli      no-undo .
  define input  parameter p-cli-base-rate like ub.bar-code.cli-base-rate no-undo .
  define output parameter p-is-new        as logical                     no-undo .
  define parameter buffer buf_bar-code for ub.bar-code .

  define variable vss-description as character no-undo initial "barcodcr-03: поиск/создание бар-кода" .

  define variable v-new-b-code like ub.bar-code.b-code no-undo .
  define variable v-unit-base  like ub.goods.unit-base no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-is-new = false
    .

    find first buf_bar-code no-lock
      where buf_bar-code.gds-code  = p-gds-code
        and buf_bar-code.node-code = p-node-code
        and buf_bar-code.part-code = p-part-code
        and buf_bar-code.in-code   = p-in-code
        and buf_bar-code.unit-cli  = p-unit-cli
      no-error .
    if not available buf_bar-code
    then do
    transaction
    on error undo, return error return-value
    :
      run gen-b-code in this-procedure
        ( input {&gbl-bc-code},
          output v-new-b-code
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при получении номера бар-кода" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
       run unitbase in this-procedure ( input p-gds-code, output v-unit-base) no-error.
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка определения базовой единицы измерения товара" skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.

      if p-unit-cli = v-unit-base
      then do:
        assign
          p-cli-base-rate = 1
        .
      end.

      if p-cli-base-rate = ?
      or p-cli-base-rate = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не задана коэффициент преобразования из одной единицы измерения в другую" skip
          "Код товара" p-gds-code skip
          "p-unit-cli" p-unit-cli skip
          "v-unit-base" v-unit-base skip
          "p-cli-base-rate" p-cli-base-rate skip
          view-as alert-box error .
        undo, return error return-value .
      end.


      assign
        p-is-new = true
      .

      create buf_bar-code .
      assign
        buf_bar-code.b-code        = v-new-b-code
        buf_bar-code.gds-code      = p-gds-code
        buf_bar-code.node-code     = p-node-code
        buf_bar-code.part-code     = p-part-code
        buf_bar-code.in-code       = p-in-code
        buf_bar-code.unit-cli      = p-unit-cli
        buf_bar-code.cli-base-rate = p-cli-base-rate
      .
    end. /*if not available buf_bar-code*/
    else do:
      if buf_bar-code.stts_ = integer({&hn-delete})
      or buf_bar-code.stts_ = integer({&hn-switch-off})
      then do:
        undo, return error substitute("бар-код &1 для товара &2 помечен к удалению или логически удален", buf_bar-code.b-code, p-gds-code).
      end.
    end.

  end.

end procedure. /* barcodcr */

procedure unitbase :

  define input  parameter p-gds-code  like ub.goods.gds-code  no-undo .
  define output parameter p-unit-base like ub.goods.unit-base no-undo .

  define variable vss-description as character no-undo initial "unitbase-01: определение базовой единицы измерения товара".

  define buffer buf_goods for ub.goods .

  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value . /* --->>>--- */
    end.

    assign
      p-unit-base = buf_goods.unit-base
    .
  end.

end procedure. /* unitbase */

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdsr.p $ $Revision: 1f78fe327cdf, 1091, rls $".

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
    create buffer bh_tbl-name for table v-full-tbl-name .

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

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: ththgdsr.p $ $Revision: 1f78fe327cdf, 1091, rls $".


procedure src_grplib-get-full-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.

    define variable v-upper-code    as integer           no-undo.

    define buffer buf_gds-grp       for src.gds-grp.
    define buffer buf_upper_gds-grp for src.gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "src_grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then {&delim-grp} else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error substitute("src_grplib-get-full-name: &1 Не найдена группа товаров с кодом &2" +
                                          ". Ошибка ссылки в дереве товаров для узла p-node-code"
                                           ,p-from-version
                                           ,v-upper-code ).

        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else {&delim-grp})
    .
end.
end procedure. /* grplib-get-full-name */


procedure fill-prod-bc-src :
define input  parameter p-src-gds-code as integer   no-undo .
define input  parameter p-src-root-code as integer   no-undo .
define input  parameter p-src-unit-base as character no-undo .
define input  parameter p-trg-gds-code as integer   no-undo .
define input  parameter p-trg-root-code as integer   no-undo .
define input  parameter p-trg-unit-base as character no-undo .
define variable v-found as logical   no-undo .
define buffer src_prod-bc for src.prod-bc.
define buffer src_bar-code for src.bar-code.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer src_code-range for src.code-range.

  /*находим соответствие*/
  _prod-bc:
  for each src_bar-code where src_bar-code.gds-code = p-src-gds-code,
       each src_prod-bc where src_prod-bc.b-code = src_bar-code.b-code:
    v-found = no.
    if src_bar-code.in-code <> '' then next _prod-bc.
    if src_bar-code.part-code <> '' then next _prod-bc.
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

    for each  buf_prod-bc no-lock where
              buf_prod-bc.b-str = src_prod-bc.b-str,
        first buf_bar-code no-lock where
              buf_bar-code.b-code = buf_prod-bc.b-code:
      find first temp-prod-bc where
                temp-prod-bc.v151-gds-code = buf_bar-code.gds-code
            and temp-prod-bc.v151-b-code = buf_bar-code.b-code
            and temp-prod-bc.v151-b-str = buf_prod-bc.b-str
            and temp-prod-bc.old-gds-code = p-src-gds-code
            and temp-prod-bc.old-b-code = src_bar-code.b-code
            and temp-prod-bc.old-b-str = src_prod-bc.b-str
            no-error.
      if not available temp-prod-bc then do:
        create temp-prod-bc.
        assign
        temp-prod-bc.old-gds-code      = src_bar-code.gds-code
        temp-prod-bc.old-b-code        = src_bar-code.b-code
        temp-prod-bc.old-b-str         = src_prod-bc.b-str
        temp-prod-bc.v151-gds-code      = buf_bar-code.gds-code
        temp-prod-bc.v151-b-code        = buf_bar-code.b-code
        temp-prod-bc.v151-b-str = buf_prod-bc.b-str

        temp-prod-bc.src-gds-code      = src_bar-code.gds-code
        temp-prod-bc.src-b-code        = src_bar-code.b-code
        temp-prod-bc.src-b-str         = src_prod-bc.b-str
        temp-prod-bc.src-root-code     = p-src-root-code
        temp-prod-bc.src-unit-base     = p-src-unit-base
        temp-prod-bc.src-unit-cli      = src_bar-code.unit-cli
        temp-prod-bc.src-cli-base-rate = src_bar-code.cli-base-rate
        temp-prod-bc.src-bc-on         = src_prod-bc.bc-on
        temp-prod-bc.trg-gds-code      = p-trg-gds-code
        temp-prod-bc.trg-root-code     = p-trg-root-code
        temp-prod-bc.trg-unit-base     = p-trg-unit-base
        temp-prod-bc.trg-unit-cli      = buf_bar-code.unit-cli
        temp-prod-bc.trg-cli-base-rate = buf_bar-code.cli-base-rate
        temp-prod-bc.trg-bc-on         = buf_prod-bc.bc-on
        temp-prod-bc.v151-gds-code      = buf_bar-code.gds-code
        temp-prod-bc.v151-bc-on         = buf_prod-bc.bc-on
        temp-prod-bc.v151-unit-cli      = buf_bar-code.unit-cli
        temp-prod-bc.v151-cli-base-rate = buf_bar-code.cli-base-rate
        temp-prod-bc.old-bc-on         = src_prod-bc.bc-on
        temp-prod-bc.old-root-code     = p-src-root-code
        temp-prod-bc.old-unit-base     = p-src-unit-base
        temp-prod-bc.old-unit-cli      = src_bar-code.unit-cli
        temp-prod-bc.old-cli-base-rate = src_bar-code.cli-base-rate
        temp-prod-bc.old-unit-base     = p-src-unit-base
        .
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_bar-code.gds-code no-error.

        if available buf_goods then do:
          assign
          temp-prod-bc.v151-unit-base =  buf_goods.unit-base
          .

        end. /*if available buf_goods then do:*/
      end. /*if not available temp-prod-bc then do:*/
      if temp-prod-bc.v151-gds-code <> temp-prod-bc.trg-gds-code
      then do:
        assign
        temp-prod-bc.old-v151-gds = "Т".
      end.
      if temp-prod-bc.src-unit-cli <> temp-prod-bc.trg-unit-cli
      and temp-prod-bc.trg-unit-cli   <> ''
      then do:
        assign
        temp-prod-bc.old-v151-unit-cli = "И".
      end.
      if temp-prod-bc.src-cli-base-rate <> temp-prod-bc.trg-cli-base-rate
      and temp-prod-bc.trg-cli-base-rate  <> 0
      then do:
        assign
        temp-prod-bc.old-v151-cli-base-rate = "К".
      end.
      if temp-prod-bc.src-bc-on <> temp-prod-bc.trg-bc-on
      and temp-prod-bc.trg-gds-code <> 0
      then do:
        assign
        temp-prod-bc.old-v151-bc-on = "У".
      end.
      v-found = yes.
      assign
      temp-prod-bc.correct-pbc-bind = temp-prod-bc.old-v151-bind +
                                temp-prod-bc.old-v151-gds  +
                                temp-prod-bc.old-v151-unit-cli +
                                temp-prod-bc.old-v151-cli-base-rate +
                                temp-prod-bc.old-v151-bc-on.
      release temp-prod-bc.
    end. /*for each  buf_prod-bc :*/
    if not v-found then do:
      find first temp-prod-bc where
                temp-prod-bc.v151-gds-code = 0
            and temp-prod-bc.v151-b-code = 0
            and temp-prod-bc.v151-b-str = ''
            and temp-prod-bc.old-gds-code = p-src-gds-code
            and temp-prod-bc.old-b-code = src_bar-code.b-code
            and temp-prod-bc.old-b-str = src_prod-bc.b-str
            no-error.
      if not available temp-prod-bc then do:
        create temp-prod-bc.
        assign
        temp-prod-bc.src-gds-code      = p-src-gds-code
        temp-prod-bc.src-b-code        = src_bar-code.b-code
        temp-prod-bc.src-b-str         = src_prod-bc.b-str
        temp-prod-bc.trg-gds-code      = p-trg-gds-code
        temp-prod-bc.v151-gds-code      = 0
        temp-prod-bc.v151-b-code        = 0
        temp-prod-bc.v151-b-str         = ''
        temp-prod-bc.old-gds-code      = p-src-gds-code
        temp-prod-bc.old-b-code        = src_bar-code.b-code
        temp-prod-bc.old-b-str         = src_prod-bc.b-str

        temp-prod-bc.src-root-code     = p-src-root-code
        temp-prod-bc.src-unit-base     = p-src-unit-base
        temp-prod-bc.src-unit-cli      = src_bar-code.unit-cli
        temp-prod-bc.src-cli-base-rate = src_bar-code.cli-base-rate
        temp-prod-bc.src-bc-on         = src_prod-bc.bc-on
        temp-prod-bc.trg-root-code     = p-trg-root-code
        temp-prod-bc.trg-unit-base     = p-trg-unit-base
        temp-prod-bc.v151-bc-on         = no
        temp-prod-bc.v151-unit-cli      = ''
        temp-prod-bc.v151-cli-base-rate = 0
        temp-prod-bc.v151-unit-base     = ''
        /*temp-prod-bc.old-v151-gds       = "Т"
        temp-prod-bc.old-v151-unit-cli  = "И"
        temp-prod-bc.old-v151-cli-base-rate = "К"
        temp-prod-bc.old-v151-bc-on     = "У"
        */
        temp-prod-bc.old-v151-bind = "-"
        temp-prod-bc.correct-pbc-bind = temp-prod-bc.old-v151-bind +
                                    temp-prod-bc.old-v151-gds  +
                                    temp-prod-bc.old-v151-unit-cli +
                                    temp-prod-bc.old-v151-cli-base-rate +
                                    temp-prod-bc.old-v151-bc-on

       .
       release temp-prod-bc.
      end. /*if not available temp-prod-bc then do:*/
    end.  /*if not v-found then do:*/
  end. /*  for each src_bar-code where src_bar-code.gds-code = src_goods.gds-code,*/
end procedure. /* fill-prod-bc-src */

procedure fill-prod-bc-trg :
define input  parameter p-src-gds-code as integer   no-undo .
define input  parameter p-src-root-code as integer   no-undo .
define input  parameter p-src-unit-base as character no-undo .
define input  parameter p-trg-gds-code as integer   no-undo .
define input  parameter p-trg-root-code as integer   no-undo .
define input  parameter p-trg-unit-base as character no-undo .

define variable v-found as logical   no-undo .
define buffer buf_code-range for src.code-range.
define buffer src_prod-bc for src.prod-bc.
define buffer src_bar-code for src.bar-code.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.

  /*находим соответствие*/
  _prod-bc:
  for each buf_bar-code where buf_bar-code.gds-code = p-src-gds-code,
       each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code:
    if buf_bar-code.in-code <> '' then next _prod-bc.
    if buf_bar-code.part-code <> '' then next _prod-bc.
    if length(buf_prod-bc.b-str) < 6 then next _prod-bc. /*это весовые*/
    if v-has-ss
    and length(buf_prod-bc.b-str) < 10
    then do:
      find first buf_code-range no-lock where
                buf_code-range.range-type = {&loc-ss-code}
            and buf_code-range.first-code >= integer(buf_prod-bc.b-str)
            and buf_code-range.last-code <= integer(buf_prod-bc.b-str) no-error.
      if available buf_code-range then next _prod-bc.
      find first buf_code-range no-lock where
                buf_code-range.range-type = {&gbl-ss-code}
            and buf_code-range.first-code >= integer(buf_prod-bc.b-str)
            and buf_code-range.last-code <= integer(buf_prod-bc.b-str) no-error.
      if available buf_code-range then next _prod-bc.
    end.
    v-found = no.
    for each src_prod-bc no-lock where
            src_prod-bc.b-str = buf_prod-bc.b-str,
        first src_bar-code no-lock where
              src_bar-code.b-code = src_prod-bc.b-code:
       find first temp-prod-bc where
                  temp-prod-bc.old-gds-code = src_bar-code.gds-code
              and temp-prod-bc.old-b-code   = src_bar-code.b-code
              and temp-prod-bc.old-b-str    = src_prod-bc.b-str
              and temp-prod-bc.v151-gds-code = buf_bar-code.gds-code
              and temp-prod-bc.v151-b-code   = buf_bar-code.b-code
              and temp-prod-bc.v151-b-str    = buf_prod-bc.b-str no-error.
       if not available temp-prod-bc then do:
        create temp-prod-bc.
        assign
        temp-prod-bc.old-gds-code      = src_bar-code.gds-code
        temp-prod-bc.old-b-code        = src_bar-code.b-code
        temp-prod-bc.old-b-str         = src_prod-bc.b-str
        temp-prod-bc.v151-gds-code      = buf_bar-code.gds-code
        temp-prod-bc.v151-b-code        = buf_bar-code.b-code
        temp-prod-bc.v151-b-str         = buf_prod-bc.b-str

        temp-prod-bc.src-gds-code      = src_bar-code.gds-code
        temp-prod-bc.src-b-code        = src_bar-code.b-code
        temp-prod-bc.src-b-str         = src_prod-bc.b-str
        temp-prod-bc.src-root-code     = p-src-root-code
        temp-prod-bc.src-unit-base     = p-src-unit-base
        temp-prod-bc.src-unit-cli      = src_bar-code.unit-cli
        temp-prod-bc.src-cli-base-rate = src_bar-code.cli-base-rate
        temp-prod-bc.src-bc-on         = src_prod-bc.bc-on
        temp-prod-bc.trg-gds-code      = p-trg-gds-code
        temp-prod-bc.trg-root-code     = p-trg-root-code
        temp-prod-bc.trg-unit-base     = p-trg-unit-base
        temp-prod-bc.v151-bc-on         = buf_prod-bc.bc-on
        temp-prod-bc.v151-unit-cli      = buf_bar-code.unit-cli
        temp-prod-bc.v151-cli-base-rate = buf_bar-code.cli-base-rate
        temp-prod-bc.old-bc-on         = src_prod-bc.bc-on
        temp-prod-bc.old-root-code     = p-src-root-code
        temp-prod-bc.old-unit-base     = p-src-unit-base
        temp-prod-bc.old-unit-cli      = src_bar-code.unit-cli
        temp-prod-bc.old-cli-base-rate = src_bar-code.cli-base-rate
        .
        find first src_goods no-lock where
                  src_goods.gds-code = src_bar-code.gds-code no-error.

        if available src_goods then do:
          assign
          temp-prod-bc.old-unit-base =  src_goods.unit-base
          .

        end. /*if available src_goods then do:*/
      end. /*if not available temp-prod-bc then do:*/
      if temp-prod-bc.old-gds-code <> temp-prod-bc.src-gds-code
      and temp-prod-bc.src-gds-code <> 0
      then do:
        assign
        temp-prod-bc.old-v151-gds = "Т".
      end.
      if temp-prod-bc.old-unit-cli <> temp-prod-bc.src-unit-cli
      and temp-prod-bc.src-unit-cli <> ''
      then do:
        assign
        temp-prod-bc.old-v151-unit-cli = "И".
      end.
      if temp-prod-bc.old-cli-base-rate <> temp-prod-bc.src-cli-base-rate
      and temp-prod-bc.src-cli-base-rate  <> 0
      then do:
        assign
        temp-prod-bc.old-v151-cli-base-rate = "К".
      end.
      if temp-prod-bc.old-bc-on <> temp-prod-bc.src-bc-on
      and temp-prod-bc.src-gds-code <> 0
      then do:
        assign
        temp-prod-bc.old-v151-bc-on = "У".
      end.
      v-found = yes.
      assign
      temp-prod-bc.correct-pbc-bind = temp-prod-bc.old-v151-bind +
                                temp-prod-bc.old-v151-gds  +
                                temp-prod-bc.old-v151-unit-cli +
                                temp-prod-bc.old-v151-cli-base-rate +
                                temp-prod-bc.old-v151-bc-on.
      release temp-prod-bc.
    end. /*for each src_prod-bc no-lock where*/
    if not v-found then do:
      find first temp-prod-bc where
                temp-prod-bc.old-gds-code = 0
            and temp-prod-bc.old-b-code   = 0
            and temp-prod-bc.old-b-str    = ''
            and temp-prod-bc.v151-gds-code = buf_bar-code.gds-code
            and temp-prod-bc.v151-b-code   = buf_bar-code.b-code
            and temp-prod-bc.v151-b-str    = buf_prod-bc.b-str no-error.
      if not available temp-prod-bc then do:
        create temp-prod-bc.
        assign
        temp-prod-bc.old-gds-code      = 0
        temp-prod-bc.old-b-code        = 0
        temp-prod-bc.old-b-str         = ''
        temp-prod-bc.v151-gds-code      = buf_bar-code.gds-code
        temp-prod-bc.v151-b-code        = buf_bar-code.b-code
        temp-prod-bc.v151-b-str         = buf_prod-bc.b-str

        temp-prod-bc.src-gds-code      = 0
        temp-prod-bc.src-b-code        = 0
        temp-prod-bc.src-b-str         = ''
        temp-prod-bc.src-root-code     = p-src-root-code
        temp-prod-bc.src-unit-base     = p-src-unit-base
        temp-prod-bc.src-unit-cli      = ''
        temp-prod-bc.src-cli-base-rate = 0
        temp-prod-bc.src-bc-on         = no
        temp-prod-bc.trg-gds-code      = p-trg-gds-code
        temp-prod-bc.trg-root-code     = p-trg-root-code
        temp-prod-bc.trg-unit-base     = p-trg-unit-base
        temp-prod-bc.v151-bc-on         = buf_prod-bc.bc-on
        temp-prod-bc.v151-unit-base     = p-trg-unit-base
        temp-prod-bc.v151-unit-cli      = buf_bar-code.unit-cli
        temp-prod-bc.v151-cli-base-rate = buf_bar-code.cli-base-rate
        temp-prod-bc.old-bc-on         = no
        temp-prod-bc.old-root-code     = p-src-root-code
        temp-prod-bc.old-unit-base     = p-src-unit-base
        temp-prod-bc.old-unit-cli      = ''
        temp-prod-bc.old-cli-base-rate = 0
        temp-prod-bc.old-v151-bind = "-"
        /*temp-prod-bc.old-v151-gds       = "Т"
        temp-prod-bc.old-v151-unit-cli  = "И"
        temp-prod-bc.old-v151-cli-base-rate = "К"
        temp-prod-bc.old-v151-bc-on     = "У"
        */
        .
        assign
        temp-prod-bc.correct-pbc-bind = temp-prod-bc.old-v151-bind +
                                temp-prod-bc.old-v151-gds  +
                                temp-prod-bc.old-v151-unit-cli +
                                temp-prod-bc.old-v151-cli-base-rate +
                                temp-prod-bc.old-v151-bc-on.

        release temp-prod-bc.
      end. /*if not available temp-prod-bc then do:*/
    end. /*if not v-found then do:*/
  end. /*  for each buf_bar-code where buf_bar-code.gds-code = p-src-gds-code,*/
end procedure. /* fill-prod-bc-trg */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile: ththgdsr.p $ $Revision: 1f78fe327cdf, 1091, rls $".

/*==========================================================================*/
procedure grplib-get-full-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.

    define variable v-upper-code    as integer           no-undo.

    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.

    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then {&delim-grp} else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else {&delim-grp})
    .
end.
end procedure. /* grplib-get-full-name */

procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .

define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.


do
on error undo, return error
:

  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, {&delim-grp}):
    assign
    v-entry = entry(v-ii, p-full-name, {&delim-grp}).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.

end procedure. /* grplib-get-node-from-full-name */