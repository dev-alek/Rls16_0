block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththrep.p $
$Archive: cmp/ththrep.p $

Отчет по завершению утилиты растянутого upgrade

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/09
Author: Bakhtadze Natalya
Creation date: 04/22/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththrep.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththrep.p $":U .
define variable vss-description as character no-undo init "Отчет по заверешению утилиты растянутого upgrade".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/obj-list.i }
{ gbl/key-rec.i }
{ ref/extclass.i }
{ cmp/thth150.i }
{ cmp/thth14.i }

&scop fqf "->>>,>>>,>>>,>>9.999"
&scop cntf "->>>,>>>,>>9"
&scop gcf "->>>999999"

define variable p-from-version as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-new-obj-type as character no-undo .
define variable v-new-obj-code as integer   no-undo .
define variable v-ii as integer no-undo .
define variable p-all as integer   no-undo .
define variable log-file-name as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-num as integer no-undo .
define variable v-doc-list as character no-undo .
define variable v-card-list as character no-undo .
define variable v-card-nums as integer no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .

define buffer new_ext-classif for ub.ext-classif  .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer old_gds-obj for src.gds-obj.
define buffer src_goods for src.goods.
define buffer buf_goods for ub.goods.
define temp-table temp-goods no-undo
field old-obj-type as character
field old-obj-code as integer
field new-obj-type as character
field new-obj-code as integer
field new-artic as character
field new-prod-type as character
field new-prod-code as integer
field new-fact-qnty as decimal
field new-gds-code as integer
field old-gds-code as integer
field old-fact-qnty as decimal
field all-old-fact-qnty as decimal /*по всем слившимся карточка*/
field old-gds-name as character
field new-gds-name as character
field old-stts as integer
field new-stts as integer
field num as integer
field trn-doc-list as character
field card-list as character
field card-num as integer
index pi is unique
new-obj-type
new-obj-code
new-gds-code
num
index newi
new-gds-code
index oldi
old-gds-code
index ioldobj
old-obj-type
old-obj-code
old-gds-code
new-gds-code
 .

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
p-all = integer(entry(1, p-parameter, {&delim-par} ))
p-from-version = entry(2, p-parameter, {&delim-par})
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


for each obj-list:
   empty temp-table temp-goods.
  /* поиск соответствия старого obj-code p-from-version версии в 16.0 */
  find first new_ext-classif no-lock where
              new_ext-classif.classif-subject = {&table_clients}
          and new_ext-classif.classif-name    = v-cli-classif-name
          and new_ext-classif.db-num          = - 1
          and new_ext-classif.charkey_one     = obj-list.obj-type
          and new_ext-classif.Key#_One        = obj-list.obj-code
              no-error .

  if error-status :error or new_ext-classif.uniq-key-rec = '' then do:
    &scop my-message substitute ("Нет связки по объекту &1 &2 &3 &4" ,obj-list.obj-type, obj-list.obj-code , error-status :get-message(1) , return-value )
    {&display-message}.
    next  .
  end.
  define variable v-tbl-row as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  define buffer new_clients for ub.clients.
  run gen-row-keyr in this-procedure (
                                      input  new_ext-classif.uniq-key-rec
                                      ,input  ? /* буфер записи которую будем искать. если ищем по key-rec то ? */
                                      ,input  "ub"
                                      ,input  ? /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                      ,input  no-lock
                                      ,output v-tbl-row
                                      ,output v-tbl-name ).
  find first new_clients no-lock where
            rowid(new_clients) = v-tbl-row.
  v-obj-type = new_ext-classif.charkey_one.
  v-obj-code = new_ext-classif.key#_one.
  v-new-obj-type = new_clients.obj-type.
  v-new-obj-code = new_clients.obj-code.
    &scop my-message substitute("Объект &5 &1&2 v16.0 &3&4" ~
                         , obj-list.obj-type ~
                         ,obj-list.obj-code  ~
                         ,v-obj-type         ~
                         ,v-obj-code  ~
                         , p-from-version)
   {&display-message}.
   v-ii = 0.
  for each buf_trn-doc where
          buf_trn-doc.obj-type = v-new-obj-type
      and buf_trn-doc.obj-code = v-new-obj-code
      and buf_trn-doc.internal = no
      and buf_trn-doc.doc-type = {&income}
      and buf_trn-doc.ext-doc-type = {&TDEDT_pri_Vnesh}:
      v-ii = v-ii + 1.

        &scop my-count-message substitute("Обработано накладных &1", v-ii)
        {&display-count-message}.

      if buf_trn-doc.ps begins "Перенос остатков" then do:
        for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
            /* поиск соответствия старого gds-code p-from-versionверсии  в 16.0 */
            find first buf_goods no-lock where
                    buf_goods.artic = buf_doc-line.artic
              and buf_goods.prod-type = buf_doc-line.prod-type
              and buf_goods.prod-code = buf_doc-line.prod-code no-error.
            if available buf_goods then do:
              v-uniq-key-rec = {&table_goods} + {&delim-key} + string(buf_goods.gds-code).
            end.
            find first temp-goods no-lock where
                    temp-goods.new-gds-code = buf_goods.gds-code
               and temp-goods.new-obj-type = v-new-obj-type
               and temp-goods.new-obj-code = v-new-obj-code
               and temp-goods.num = 0
                    no-error.
            if not available temp-goods then do:
              find first new_ext-classif no-lock where
                        new_ext-classif.classif-subject = {&table_goods}
                    and new_ext-classif.classif-name    = v-classif-name
                    and new_ext-classif.db-num          = - 1
                    and new_ext-classif.uniq-key-rec    = v-uniq-key-rec use-index  irec
              no-error .

              create temp-goods.
              assign
              temp-goods.old-obj-type = obj-list.obj-type
              temp-goods.old-obj-code = obj-list.obj-code
              temp-goods.new-obj-type = v-new-obj-type
              temp-goods.new-obj-code = v-new-obj-code
              temp-goods.new-artic = buf_doc-line.artic
              temp-goods.new-prod-type = buf_doc-line.prod-type
              temp-goods.new-prod-code = buf_doc-line.prod-code
              temp-goods.new-gds-code = buf_goods.gds-code
              temp-goods.num = 0
              temp-goods.old-fact-qnty = 0
              temp-goods.new-fact-qnty = 0
              temp-goods.old-gds-code = (if available new_ext-classif then new_ext-classif.key#_one else - buf_goods.gds-code)
              temp-goods.new-gds-name = buf_goods.gds-name
              temp-goods.old-gds-name = (if available new_ext-classif
                                         then entry(1, new_ext-classif.charkey_three, {&delim-par})
                                         else "!!!НЕТ СООТВ")
              .
              if available new_ext-classif then do:
                find first  old_gds-obj where
                        old_gds-obj.obj-type = obj-list.obj-type
                    and old_gds-obj.obj-code = obj-list.obj-code
                    and old_gds-obj.gds-code = temp-goods.old-gds-code no-error.
                if available old_gds-obj then do:
                  temp-goods.old-fact-qnty = old_gds-obj.fact-qnty.
                end.
              end.
            end.
            assign
            temp-goods.new-fact-qnty = temp-goods.new-fact-qnty + buf_doc-line.doc-qnty
            temp-goods.trn-doc-list = temp-goods.trn-doc-list + (if temp-goods.trn-doc-list = ''
                                                                 then '' else {&comma-char}) +
                                      (if buf_trn-doc.status_ = {&fact}
                                      then substitute("<&1>", buf_trn-doc.doc-code)
                                      else buf_trn-doc.doc-code)
            .
            release temp-goods.
        end. /*for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:*/
      end. /*if buf_trn-doc.ps begins "Перенос остатков" then do:*/
  end. /*for each buf_trn-doc where*/
  v-ii = 0.
  v-num = 1.
  for each old_gds-obj where
            old_gds-obj.obj-type = obj-list.obj-type
       and  old_gds-obj.obj-code = obj-list.obj-code
       and old_gds-obj.fact-qnty > 0
       :
       v-ii = v-ii + 1.
       if v-ii modulo 100 = 0 then do:
         &scop my-count-message substitute("Обработано остатков в &2 &1", v-ii, p-from-version)
         {&display-count-message}.
       end.
    find first temp-goods where
              temp-goods.old-obj-type = old_gds-obj.obj-type
          and temp-goods.old-obj-code = old_gds-obj.obj-code
          and temp-goods.old-gds-code = old_gds-obj.gds-code no-error.
    if not available temp-goods then do:
      find first src_goods where src_goods.gds-code = old_gds-obj.gds-code no-error.
      find first new_ext-classif no-lock where
                new_ext-classif.classif-subject = {&table_goods}
            and new_ext-classif.classif-name    = v-classif-name
            and new_ext-classif.db-num          = - 1
            and new_ext-classif.key#_one    = old_gds-obj.gds-code no-error .
      if available new_ext-classif then do:
        find first buf_goods no-lock where
                buf_goods.gds-code = integer(entry(2, new_ext-classif.uniq-key-rec, {&delim-key})) no-error.
      end.
      else do:
        release buf_goods.
      end.
      create temp-goods.
      assign
      temp-goods.old-obj-type = old_gds-obj.obj-type
      temp-goods.old-obj-code = old_gds-obj.obj-code
      temp-goods.old-gds-code = old_gds-obj.gds-code
      temp-goods.old-fact-qnty = old_gds-obj.fact-qnty
      temp-goods.new-obj-type = v-new-obj-type
      temp-goods.new-obj-code = v-new-obj-code
      temp-goods.new-gds-code = (if available new_ext-classif  and new_ext-classif.uniq-key-rec > ''
                                then integer(entry(2, new_ext-classif.uniq-key-rec, {&delim-key}))
                                else (- old_gds-obj.gds-code))
      temp-goods.num = v-num
      v-num = v-num + 1
      temp-goods.new-gds-name = (if available buf_goods then buf_goods.gds-name else '')
      temp-goods.old-gds-name = (if available src_goods then src_goods.gds-name else '')
      temp-goods.old-stts = (if available src_goods then src_goods.stts else ?)
      temp-goods.new-stts = (if available buf_goods then buf_goods.stts else ?)
      .
      release temp-goods.
    end.
  end.
&scop my-message substitute("Вывожу в файл &1", log-file-name)
{&display-message}.
 define variable v-new-qnty as decimal no-undo .
 define variable v-old-qnty as decimal no-undo.
 define variable v-all-old-qnty as decimal no-undo .
 define variable v-all-new-qnty as decimal no-undo .
 define variable v-old-ii-count as integer   no-undo .
 define variable v-new-ii-count as integer   no-undo .
 define buffer buf_temp-goods for temp-goods.
 &scop my-message substitute("Ищем слияние карточек...")
 for each temp-goods no-lock where
         temp-goods.old-obj-type = v-new-obj-type
    and  temp-goods.old-obj-code = v-new-obj-code
 break
 by temp-goods.new-obj-type
 by temp-goods.new-obj-code
 by temp-goods.new-gds-code
 :
  if first-of(temp-goods.new-gds-code) then do:
    v-card-list = ''.
    v-card-nums = 0.
    v-old-qnty = 0.
  end.
  v-card-list = v-card-list + (if v-card-list = '' then '' else {&comma-char}) +  string(temp-goods.old-gds-code).
  v-card-nums = v-card-nums  + 1.
  v-old-qnty = v-old-qnty + temp-goods.old-fact-qnty.
  if last-of(temp-goods.new-gds-code) then do:
    for each buf_temp-goods where
           buf_temp-goods.new-obj-type = temp-goods.new-obj-type
       and buf_temp-goods.new-obj-type = temp-goods.new-obj-type
       and buf_temp-goods.new-gds-code = temp-goods.new-gds-code:
      buf_temp-goods.card-list = v-card-list.
      buf_temp-goods.card-num = v-card-nums.
      buf_temp-goods.all-old-fact-qnty = v-old-qnty.
    end.
  end.
 end.
 for each temp-goods no-lock where
         temp-goods.old-obj-type = obj-list.obj-type
    and  temp-goods.old-obj-code = obj-list.obj-code
 break
 by temp-goods.old-obj-type
 by temp-goods.old-obj-code
 by temp-goods.old-gds-code
 by temp-goods.new-gds-code
 :
   if first-of (temp-goods.old-obj-code) then do:
     v-new-qnty = 0.
     v-all-old-qnty = 0.
     v-old-ii-count = 0.
     v-all-new-qnty = 0.
     v-new-ii-count = 0.
     v-doc-list = ''.
   end.
   if first-of (temp-goods.old-gds-code) then do:
     v-new-qnty = 0.
     v-all-old-qnty = v-all-old-qnty + temp-goods.old-fact-qnty.
     v-old-ii-count = v-old-ii-count + 1.
     v-doc-list = ''.
   end.
   if temp-goods.num = 0 then do:
     v-new-ii-count = v-new-ii-count + 1.
   end.
   v-new-qnty = v-new-qnty + temp-goods.new-fact-qnty.
   v-all-new-qnty = v-all-new-qnty + temp-goods.new-fact-qnty.
   v-doc-list = v-doc-list + {&comma-char} + temp-goods.trn-doc-list.
   if last-of(temp-goods.old-gds-code)
   and p-all < 3
   then do:
     if p-all = 1
     or v-new-qnty <> temp-goods.old-fact-qnty then do:
      if temp-goods.card-num <= 1 then do:
        v-card-list = ''.
      end.
      else do:
        v-card-list = temp-goods.card-list.
        entry(lookup(string(temp-goods.old-gds-code), v-card-list), v-card-list) = ''.
        v-card-list = replace(v-card-list, {&comma-char} + {&comma-char}, {&comma-char}).
        v-card-list = trim(v-card-list, {&comma-char}).
      end.
    &scop my-message   substitute("Товар &4=&1 Статус в &4=&3 кол-во  &4=&2" ~
                                  ,string(temp-goods.old-gds-code, ~{&gcf~}) ~
                                  ,string(temp-goods.old-fact-qnty, ~{&fqf~}) ~
                                  ,(if temp-goods.old-stts > 0 then "удал" else " тек") ~
                                  , p-from-version ~
                                  )
    {&display-message}.
    &scop my-message temp-goods.old-gds-name
    {&display-message}.
    &scop my-message   substitute("Товар v16.0=&1 Статус в v16.0=&3 кол-во  v16.0=&2 " ~
                                  ,string(temp-goods.new-gds-code, ~{&gcf~}) ~
                                  ,string(v-new-qnty, ~{&fqf~}) ~
                                  ,(if temp-goods.new-stts > 0 then "удал" else " тек") ~
                                  )
    {&display-message}.
    &scop my-message temp-goods.new-gds-name
    {&display-message}.
    &scop my-message   v-doc-list
    {&display-message}.

    if p-all = 2 and temp-goods.card-num > 1 then do:
      &scop my-message substitute("Слияние карточек товаров!!!!:")
      {&display-message}.

      for each buf_temp-goods where
            buf_temp-goods.old-obj-type = obj-list.obj-type
          and buf_temp-goods.old-obj-code = obj-list.obj-code
          and buf_temp-goods.new-gds-code = temp-goods.new-gds-code:
          &scop my-message substitute("            &3: &1 кол-во &3: &2" ~
                                    , string(buf_temp-goods.old-gds-code, ~{&gcf~}) ~
                                    , string(buf_temp-goods.old-fact-qnty, ~{&fqf~}) ~
                                    , p-from-version )
          {&display-message}.
      end.
      &scop my-message substitute("               ----- Итого = &1", string(temp-goods.all-old-fact-qnty, ~{&fqf~}))
      {&display-message}.
    end.
    if p-all = 1 then do:
      for each buf_temp-goods where
              buf_temp-goods.old-gds-code = temp-goods.old-gds-code
          and buf_temp-goods.old-obj-type = obj-list.obj-type
          and buf_temp-goods.old-obj-code = obj-list.obj-code              :
          &scop my-message substitute("    Товар v16.0=&1 удал в v16.0=&3 кол-во v16.0=&2&4         v16.0: &6" ~
                                      ,string(buf_temp-goods.new-gds-code, ~{&gcf~})  ~
                                      ,string(buf_temp-goods.new-fact-qnty, ~{&fqf~}) ~
                                      ,buf_temp-goods.new-stts ~
                                      , ~{&new-line~} ~
                                      , buf_temp-goods.new-gds-name ~
                                      )
        {&display-message}.
        end.
      end. /*if p-all = 1*/
     end. /*if p-all = 1*/
     if p-all = 1
     or v-new-qnty <> temp-goods.old-fact-qnty then do:
      &scop my-message fill("-", 80)
      {&display-message}.
     end.
   end. /*if last-of(temp-goods.old-gds-code) then do:*/
   if last-of(temp-goods.old-obj-code) then do:
      &scop my-message substitute("&1&1", {&new-line})
      {&display-message}.
      &scop my-message substitute("&1&2 Ассортимент  &6 &3 кол-во &6 &4&5" ~
                                  ,temp-goods.old-obj-type ~
                                  ,temp-goods.old-obj-code ~
                                 ,string(v-old-ii-count, ~{&cntf~}) ~
                                 ,string(v-all-old-qnty, ~{&fqf~}) ~
                                 , ~{&new-line~} ~
                                 , p-from-version )
      {&display-message}.
      &scop my-message substitute("&1&2 Ассортимент  v16.0 &3 кол-во v16.0 &4&5" ~
                                    ,temp-goods.new-obj-type ~
                                    ,temp-goods.new-obj-code ~
                                    ,string(v-new-ii-count, ~{&cntf~}) ~
                                    ,string(v-all-new-qnty, ~{&fqf~}) ~
                                    , ~{&new-line~})
      {&display-message}.
   end.
 end. /*for each temp-goods no-lock*/
end. /*for each obj-list:*/