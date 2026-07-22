block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththpri.p $
$Archive: cmp/ththpri.p $

Создание остатков и учетных цен на основе старой версии TH и перенос в 16.0

Автор: Чернова Светлана Александровна
Дата создания: 01/11/09
Author: Svetlana Chernova
Creation date: 01/11/09

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththpri.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththpri.p $":U .
define variable vss-description as character no-undo init "Создание остатков и учетных цен на основе старой версии БД и перенос в 16.0".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ ref/extclass.i }
{ gbl/key-rec.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i def  }
{ cmp/obj-list.i }
{ cmp/gds-list.i gds-list def }
{ ref/xobjgrp.i  }
{ str/hvrdtax.i  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ str/lib-def.i  }
{ cmp/df-sub.i   }
{ gbl/waitfram.i }
{ cmp/thth150.i }
{ cmp/thth14.i }
{ utl/ththsaco.i }


define temp-table gds-list1 no-undo like gds-list.
define temp-table gds-list2 no-undo
field gds-code as integer
index pi gds-code
.


define variable p-from-version as character no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .
define variable v-ok as logical   no-undo .
define variable v-f-cli-type as character no-undo .
define variable v-f-cli-code as integer   no-undo .
define variable v-ff as logical   no-undo .
define variable  varis-petrolium as logical   no-undo .
define variable  varis-pieces as logical   no-undo .

define stream str.
output stream str to value('negparts.gds') .

empty temp-table gds-list2.
v-f-cli-type = {&cmp} .


define buffer new_clients     for ub.clients  .
define buffer new_ext-classif for ub.ext-classif  .
define buffer old_gds-obj     for src.gds-obj  .
define buffer old_goods       for src.goods  .
define buffer new_goods       for ub.goods  .
define buffer old_parts       for src.parts  .
define buffer old_contract        for src.contract  .
define buffer old_contract-specif for src.contract-specif  .

 on WRITE of ub.goods          override do: end.

define temp-table temp_parts no-undo like ub.parts
field new_artic     as character
field new_prod-type as character
field new_prod-code as integer

index pi
supp-type
supp-code
host-code
contract-code
VAT-type
VAT-PC
prod-type
prod-code
artic
price-cli
part-code
fact-date
.

define temp-table temp-exist no-undo
field old-gds-code as integer
index pi is unique primary
old-gds-code.
define temp-table temp-2exists no-undo
field artic as character
field prod-type as character
field prod-code as integer
field doc-code as character
index pi is unique primary
doc-code
artic
prod-type
prod-code
.


define buffer buf2_temp_parts for temp_parts  .

define variable new_obj-code  as integer   no-undo .
define variable new_obj-type  as character no-undo .
define variable new_cli-code  as integer   no-undo .
define variable new_cli-type  as character no-undo .
define variable new_host-code as integer   no-undo .
define variable new_gds-code  as integer   no-undo .
define variable v-counter     as integer   no-undo .
define variable v-ii          as integer   no-undo .
define variable v-err         as integer   no-undo .
define variable kkk  as integer no-undo .
define variable p-q  like ub.ord-dtl-rcv.qnty no-undo .
define variable v-contract-code as integer no-undo .
define variable v-host-code as integer   no-undo .
define variable v-internal  as logical   no-undo .
define variable v-doc-type as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-status_ as character no-undo .
define variable v-print-rubl as logical   no-undo .
define variable v-curr-r-b as character no-undo .
define variable n-d as character no-undo .

define temp-table tt-trn-doc  no-undo like ub.trn-doc.
define temp-table tt-doc-line no-undo like ub.doc-line.
define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts    no-undo like ub.parts.

define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .

define buffer t_trn-doc   for ub.trn-doc  .
define buffer t_doc-line  for ub.doc-line .
define buffer t_gds-dtl   for ub.gds-dtl .
define buffer t_goods     for ub.goods .
define buffer buf_sysconf for ub.sysconf  .


define temp-table temp-line no-undo
field num           as integer
field supp-type     as character
field supp-code     as integer
field host-code     as integer
field contract-code as integer
field artic         as character
field prod-type     as character
field prod-code     as integer
field part-code     as character
field vat-type      as character
field vat-pc        as decimal
field price-cli     as decimal
field fact-qnty     as decimal
field cli-qnty      as decimal
index pi
  supp-type
  supp-code
  host-code
  contract-code
  vat-type
  vat-pc
  artic
  prod-type
  prod-code
  part-code
  price-cli
  num
.

define buffer new_line for temp-line  .

define variable v-tti as integer   no-undo .
define variable v-ttc as character no-undo .
define variable log-file-name as character no-undo .

&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
        )

&glob display-count-message  run write-counter in p-log-handle (input ~{&my-count-message~})

&glob hide-count-message  run hide-counter in p-log-handle

if num-entries(p-parameter, {&delim-par}) <> 3 then do:
  message
  substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 2"
             ,num-entries(p-parameter, {&delim-par}))
  view-as alert-box error .
  return.
end.

assign
v-f-cli-code = integer(entry(1, p-parameter, {&delim-par}))
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


log-file-name = substitute("&1.txt", entry(1, entry(num-entries(this-procedure:file-name, {&slash-char}), this-procedure:file-name, {&slash-char}), ".")).


&scop my-message substitute("Импорт остатков и учетных цен из &1 БД и перенос в 16.0 ...", p-from-version)
{&display-message}.
run save-conf-par in this-procedure .
run proc_import in this-procedure .
run re-save-conf-par in this-procedure .
output stream str close.
{&hide-count-message}.



procedure proc_import :
define variable v-find-doc-err as logical no-undo .
do
on error undo, return error  substitute("ошибка &1 &2" , error-status :get-message(1) , return-value )
:
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  if v-curr-r-b = {&r-b-base} then v-print-rubl = false .
                              else v-print-rubl = true .

  for each obj-list :

    empty temp-table gds-list no-error .
    empty temp-table temp-exist no-error.
    if error-status :error then do:
      &scop my-message substitute("ошибка 1 &1 &2" , error-status :get-message(1) , return-value )
      {&display-message}.
    end.
    empty temp-table temp-line no-error .
    if error-status :error then do:
      &scop my-message substitute("ошибка 1 &1 &2" , error-status :get-message(1) , return-value )
      {&display-message}.
    end.
    EMPTY TEMP-TABLE temp_parts no-error .
    if error-status :error then do:
      &scop my-message substitute("ошибка 2 &1 &2" , error-status :get-message(1) , return-value )
      {&display-message}.
    end.

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

    v-find-doc-err = no.
    run find-doc in this-procedure ( input new_ext-classif.charkey_one
                                    ,input new_ext-classif.key#_one
                                    ,output v-find-doc-err) no-error.
    if error-status:error
    or v-find-doc-err
    then do:
      if v-find-doc-err then do:
        &scop my-message substitute ("Объект &1&2 не готов для утилиты импорта остатков"  ~
                                    ,obj-list.obj-type ~
                                    ,obj-list.obj-code )
        {&display-message}.
      end.
      else do:
        &scop my-message substitute ("Объект &1&2 -ошибка при проверке готовности для утилиты импорта остатков:&3&4&3&5"  ~
                                    ,obj-list.obj-type ~
                                    ,obj-list.obj-code  ~
                                    , ~{&new-line~} ~
                                    , error-status:get-message(1)  ~
                                    , return-value )
        {&display-message}.
      end.
      next  .
    end. /*if error-status:error*/

    run uni-k in this-procedure (  input  new_ext-classif.uniq-key-rec
                ,input  {&table_clients}
                ,output new_obj-type
                ,output new_obj-code
                ,output v-tti ) .


    find first new_clients no-lock where
                new_clients.obj-type = new_obj-type and
                new_clients.obj-code = new_obj-code no-error .
    if error-status :error then do:
      &scop my-message substitute("ошибка &1 &2 ( новый объект &3 &4)" , error-status :get-message(1) , return-value , new_obj-type , new_obj-code)
      {&display-message}.
      return error  .
    end.

    { gbl/curobjdt.i
      new_obj-type
      new_obj-code
      to-day
    }
    { gbl/hostcode.i
      new_obj-type
      new_obj-code
      new_host-code
      }

    for each old_gds-obj no-lock where
           old_gds-obj.obj-type = obj-list.obj-type and
           old_gds-obj.obj-code = obj-list.obj-code ,
     first old_goods no-lock where
           old_goods.gds-code = old_gds-obj.gds-code
    :
      if old_goods.stts > 0 and old_gds-obj.fact-qnty = 0  then do:
        next.
      end.

      if old_gds-obj.fact-qnty = 0  then do:
        next.
      end.

      if old_goods.stts <> 0 then do:
        &scop my-message substitute("Внимание !!! товар в &3 &2 &1 статус УДАЛЕН но имеет остатки &3 ! " , old_goods.gds-name , old_goods.gds-code , old_gds-obj.fact-qnty, p-from-version)
        {&display-message}.
      end.

      /* поиск соответствия старого gds-code p-from-version версии  в 16.0 */
      find first new_ext-classif no-lock where
                new_ext-classif.classif-subject = {&table_goods}
            and new_ext-classif.classif-name    = v-classif-name
            and new_ext-classif.db-num          = - 1
            and new_ext-classif.Key#_One        = old_goods.gds-code no-error .
      if error-status :error then do:
        &scop my-message substitute("Пропускаю &1 (товар &2)" ,  return-value , old_goods.gds-code )
        {&display-message}.
        next  .
      end.
      if new_ext-classif.uniq-key-rec = '' then do:
        &scop my-message substitute("Нет связки по товару &1" , old_goods.gds-code )
        {&display-message}.
        next  .
      end.

      run uni-k in this-procedure ( input  new_ext-classif.uniq-key-rec
                  ,input  {&table_goods}
                  ,output v-ttc
                  ,output v-ttc
                  ,output new_gds-code ) .

      find first new_goods where
                new_goods.gds-code = new_gds-code no-error .
      if new_goods.stts <> 0 then do:
        &scop my-message substitute ( "Удаленный &2 (товар &1) в новой БД" , new_goods.gds-name , new_goods.gds-code )
        {&display-message}.
        new_goods.stts = 0 .
        find first gds-list2  where
                  gds-list2.gds-code = new_goods.gds-code no-error .
        if not available gds-list2 then do:
          create gds-list2 .
          assign
          gds-list2.gds-code = new_goods.gds-code
          .
        end.
      end. /*if new_goods.stts <> 0 then do:*/
      { str/is-petrl.i
        new_goods.artic
        new_goods.prod-type
        new_goods.prod-code
        varis-petrolium
        varis-pieces
        no-error
      }
      if  varis-petrolium then do:
        &scop my-message substitute("Пропускаю ТОПЛИВО &2 (товар &1)" , new_goods.gds-name , new_goods.gds-code )
        {&display-message}.
        next  .
      end.

      find first gds-list where
                  gds-list.gds-code = new_gds-code no-error .
      if available gds-list then do:
        find first temp-exist where
                  temp-exist.old-gds-code = old_goods.gds-code no-error.
        if available temp-exist then next.
        create temp-exist.
        assign
        temp-exist.old-gds-code = old_goods.gds-code
        .
        release temp-exist.
      end.
      else do:
        create gds-list .
        buffer-copy new_goods to gds-list
        .
      end.

      v-ff = false .
      for each old_parts no-lock where
              old_parts.artic     = old_goods.artic
          and old_parts.prod-type = old_goods.prod-type
          and old_parts.prod-code = old_goods.prod-code
          and old_parts.obj-type  = obj-list.obj-type
          and old_parts.obj-code  = obj-list.obj-code
          and old_parts.fact-qnty > 0
          and old_parts.price-cli > 0
          and old_parts.out-code  = {&free-code}
        :
        v-ff = true  .
        create temp_parts.
        buffer-copy old_parts to temp_parts
        assign
        temp_parts.new_artic     = new_goods.artic
        temp_parts.new_prod-type = new_goods.prod-type
        temp_parts.new_prod-code = new_goods.prod-code
        temp_parts.obj-type      = new_obj-type
        temp_parts.obj-code      = new_obj-code
        .
      end. /*for each old_parts no-lock where*/

      if v-ff = true  and  new_goods.stts <> 0 then do:
        &scop my-message substitute("Внимание !!! товар в 16.0 &2 &1 статус УДАЛЕН (&4 &3)! " , new_goods.gds-name , new_goods.gds-code, old_goods.gds-code, p-from-version)
        {&display-message}.
      end.
    end.
    /* импорт шапки */
    run import-hed in this-procedure no-error .
    for each gds-list2:
      find first ub.goods exclusive-lock where ub.goods.gds-code = gds-list2.gds-code no-error .
      if available ub.goods then do:
        ub.goods.stts  = 1 .
      end.
    end.
    if error-status :error then do:
      &scop my-message substitute("ошибка при импорте ПН  &1 &2" , error-status :get-message(1) , return-value )
      {&display-message}.
      return error  .
    end.
    for each gds-list2:
      find first ub.goods exclusive-lock where ub.goods.gds-code = gds-list2.gds-code no-error .
      if available ub.goods then do:
        ub.goods.stts  = 1 .
      end.
    end.

  end. /*for each obj-list :*/

  if v-ii = 0 then do:
    &scop my-message "Импортировано 0 документов"
    {&display-message}.
    return error  .
  end.
  else do:
    &scop my-message substitute("Импортировано документов: &1" , v-ii )
    {&display-message}.
    return .
  end.
end. /*doe*/

end procedure. /* proc_import */

procedure import-hed :

define variable v-qnty-fact as decimal   no-undo .
define variable v-qnty-cli  as decimal   no-undo .
define variable v-num       as integer   no-undo .

do
on error undo, return error substitute("ошибка &1 &2" , error-status :get-message(1) , return-value )
:
  assign
  v-qnty-fact = 0
  v-qnty-cli  = 0
  .
  &scop my-message substitute("Подготовка партий..."  )
  {&display-message}.

 for each temp_parts break
  by temp_parts.supp-type
  by temp_parts.supp-code
  by temp_parts.host-code
  by temp_parts.contract-code
  by temp_parts.VAT-type
  by temp_parts.VAT-PC
  by temp_parts.prod-type
  by temp_parts.prod-code
  by temp_parts.artic
  by temp_parts.price-cli
  by temp_parts.part-code
  :
    v-qnty-fact = v-qnty-fact + temp_parts.fact-qnty  .
    v-qnty-cli  = v-qnty-cli  + temp_parts.cli-qnty  .

    if last-of ( temp_parts.part-code ) then do:
      create temp-line .
      assign
      temp-line.vat-type      = temp_parts.vat-type
      temp-line.vat-pc        = temp_parts.vat-pc
      temp-line.supp-type     = temp_parts.supp-type
      temp-line.supp-code     = temp_parts.supp-code
      temp-line.host-code     = temp_parts.host-code
      temp-line.contract-code = temp_parts.contract-code
      temp-line.prod-type     = temp_parts.prod-type
      temp-line.prod-code     = temp_parts.prod-code
      temp-line.artic         = temp_parts.artic
      temp-line.price-cli     = temp_parts.price-cli
      temp-line.part-code     = temp_parts.part-code
      temp-line.fact-qnty     = v-qnty-fact
      temp-line.cli-qnty      = v-qnty-cli
      .
      v-qnty-fact = 0 .
      v-qnty-cli  = 0 .
    end. /*if last-of ( temp_parts.part-code ) then do:*/
  end. /* for each temp_parts break*/


  for each temp-line  break
  by temp-line.supp-type
  by temp-line.supp-code
  by temp-line.host-code
  by temp-line.contract-code
  by temp-line.vat-type
  by temp-line.vat-pc
  by temp-line.prod-type
  by temp-line.prod-code
  by temp-line.artic
  :
    if first-of (temp-line.artic) then do:
      v-num = 0 .
    end.
    v-num = v-num + 1 .
    temp-line.num = v-num .
  end.

  for each temp-line break
  by temp-line.supp-type
  by temp-line.supp-code
  by temp-line.host-code
  by temp-line.contract-code
  by temp-line.vat-type
  by temp-line.vat-pc
  by temp-line.num
  :
    if first-of (temp-line.num) then do:
      run clear-tt in this-procedure .
      run create-nakl in this-procedure  ( temp-line.num ) .
    end.
  end.
end. /*doe*/
end procedure. /* import-contr */

procedure uni-k :
define input  parameter p-uniq-key-rec as character no-undo .
define input  parameter p-table as character no-undo .
define output parameter p-obj-type as character no-undo .
define output parameter p-obj-code as integer   no-undo .
define output parameter p-gds-code as integer   no-undo .
do
on error undo, return error substitute("ошибка &1 &2" , error-status :get-message(1) , return-value )
:
  case p-table :
    when {&table_clients} then do:
      if entry(1, p-uniq-key-rec, {&delim-key}) = {&table_clients} then do:
        assign
        p-obj-type = entry(2, p-uniq-key-rec, {&delim-key})
        p-obj-code = integer(entry(3, p-uniq-key-rec, {&delim-key}))
        p-gds-code = ?
        .
      end.
    end.
    when {&table_goods} then do:
      if entry(1, p-uniq-key-rec, {&delim-key}) = {&table_goods} then do:
        assign
        p-obj-type = ?
        p-obj-code = ?
        p-gds-code = integer(entry(2, p-uniq-key-rec, {&delim-key}))
        .
      end.
    end.
  end case.
end. /*doe*/
end procedure. /* uni-k */


procedure create-nakl :
define input  parameter p-num as integer   no-undo .
do
on error undo, return error return-value
:
  assign
  v-doc-type       = {&income}
  v-internal       = false
  v-ext-doc-type   = {&TDEDT_Pri_Vnesh}
  v-discnt-type    = ""
  v-status_        = {&wayb}

  .
    if temp-line.supp-type = ""
    or temp-line.supp-type = {&stock}
    or temp-line.supp-type = {&shop} then  do:
      assign
      new_cli-type = v-f-cli-type
      new_cli-code = v-f-cli-code
      .
    end.
    else do:
     /* поиск соответствия старого cli-code p-from-version версии в 16.0 */
      find first new_ext-classif no-lock where
                 new_ext-classif.classif-subject = {&table_clients}
             and new_ext-classif.classif-name    = v-cli-classif-name
             and new_ext-classif.db-num          = - 1
             and new_ext-classif.charkey_one     = temp-line.supp-type
             and new_ext-classif.Key#_One        = temp-line.supp-code
             no-error .

      if error-status :error or new_ext-classif.uniq-key-rec = '' then do:
        &scop my-message substitute ("Нет связки по клиенту &1 &2 &3 &4" ,temp-line.supp-type, temp-line.supp-code , error-status :get-message(1) , return-value )
        {&display-message}.
        return error  .
      end.
      run uni-k in this-procedure (  input  new_ext-classif.uniq-key-rec
                  ,input  {&table_clients}
                  ,output new_cli-type
                  ,output new_cli-code
                  ,output v-tti ) .

    end. /*else     if temp-line.supp-type = "" */

    find first new_clients no-lock where
              new_clients.obj-type = new_cli-type
          and new_clients.obj-code = new_cli-code no-error .
    if error-status :error then do:
      &scop my-message substitute("ошибка &1 &2 ( новый клиент &3 &4)" , error-status :get-message(1) , return-value , new_cli-type , new_cli-code)
      {&display-message}.
      return error  .
    end.
  /*----------------*/
  run doc-code in this-procedure
    (input  "main":u,
     input  new_obj-type,
     input  new_obj-code,
     input  ?,
     output n-d ) no-error.

  if error-status:error then do:
    &scop my-message substitute("Ошибка при генерации номера документа &1 &2" ,new_obj-type, new_obj-code )
    {&display-message}.
    return error.
  end.

  &scop my-message substitute("Создание ПН № &1 объект &2&3 контраг &4&5 &6" , n-d  , new_obj-type , new_obj-code ,  new_cli-type ,  new_cli-code , temp-line.contract-code )
  {&display-message}.


  find first temp_parts where
             temp_parts.artic         = temp-line.artic     and
             temp_parts.prod-type     = temp-line.prod-type and
             temp_parts.prod-code     = temp-line.prod-code and
             temp_parts.supp-code     = temp-line.supp-code and
             temp_parts.supp-type     = temp-line.supp-type and
             temp_parts.host-code     = temp-line.host-code and
             temp_parts.vat-type      = temp-line.vat-type  and
             temp_parts.vat-pc        = temp-line.vat-pc    and
             temp_parts.contract-code = temp-line.contract-code  and
             temp_parts.part-code     = temp-line.part-code  and
             temp_parts.price-cli     = temp-line.price-cli  no-error .

  v-contract-code = temp_parts.contract-code.

  create  tt-trn-doc.
  buffer-copy  temp_parts to tt-trn-doc
  assign
  tt-trn-doc.status_        = "temp"
  tt-trn-doc.doc-code       = n-d
  tt-trn-doc.doc-date       = to-day
  tt-trn-doc.cli-type       = new_cli-type
  tt-trn-doc.cli-code       = new_cli-code
  tt-trn-doc.obj-type       = new_obj-type
  tt-trn-doc.obj-code       = new_obj-code
  tt-trn-doc.host-code      = new_host-code
  tt-trn-doc.contract-code  = v-contract-code
  tt-trn-doc.doc-type       = v-doc-type
  tt-trn-doc.internal       = v-internal
  tt-trn-doc.cr-db-num      = v-cntxt-db-num
  tt-trn-doc.office         = false
  tt-trn-doc.fact-num       = 0
  tt-trn-doc.PS             = "Перенос остатков"
  tt-trn-doc.creid          = v-cntxt-userid
  tt-trn-doc.flag_          = false
  tt-trn-doc.ext-doc-type   = v-ext-doc-type
  tt-trn-doc.discnt-type    = v-discnt-type
  tt-trn-doc.ret-supp       = false
  .
  if tt-trn-doc.exch-code = ? then tt-trn-doc.exch-code = 0 .

  { gbl/baserate.i
    new_host-code
    temp_parts.fact-date
    tt-trn-doc.base-rate
    tt-trn-doc.base-scale
    no-error  }
    if tt-trn-doc.base-rate = ? or tt-trn-doc.base-rate = 0  then tt-trn-doc.base-rate = 1 .
    if tt-trn-doc.base-scale = ? or tt-trn-doc.base-scale = 0  then tt-trn-doc.base-scale = 1 .

    if tt-trn-doc.exch-rate = ? or tt-trn-doc.exch-rate = 0  then tt-trn-doc.exch-rate = 1 .
    if tt-trn-doc.exch-scale = ? or tt-trn-doc.exch-scale = 0  then tt-trn-doc.exch-scale = 1 .

   { str/crtrndoc.i
      tt-trn-doc.acc-date
      tt-trn-doc.bge-date
      tt-trn-doc.base-rate
      tt-trn-doc.base-scale
      tt-trn-doc.cli-code
      tt-trn-doc.cli-type
      tt-trn-doc.cli-name
      tt-trn-doc.cr-db-num
      tt-trn-doc.creid
      tt-trn-doc.discnt-type
      tt-trn-doc.doc-code
      tt-trn-doc.doc-date
      tt-trn-doc.doc-type
      tt-trn-doc.flag_
      tt-trn-doc.host-code
      tt-trn-doc.internal
      tt-trn-doc.obj-code
      tt-trn-doc.obj-type
      tt-trn-doc.office
      tt-trn-doc.pay-code
      tt-trn-doc.ps
      tt-trn-doc.ret-supp
      tt-trn-doc.slt-type
      tt-trn-doc.status_
      tt-trn-doc.vat-type
      tt-trn-doc.ext-doc-type
      tt-trn-doc.purch-code
      no-error }
    .
  if error-status :error then do:
    &scop my-message substitute("Ошибка при генерации  документа1 &1 &2" , return-value , error-status :get-message(1) )
    {&display-message}.
    return error return-value .
  end.

  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
  if error-status :error then do:
    &scop my-message substitute("Ошибка при генерации  документа2 &1 &2" , return-value , error-status :get-message(1) )
    {&display-message}.
    return error return-value .
  end.

  assign
  new_trn-doc.contract-code  = v-contract-code
  new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
  new_trn-doc.exch-scale = tt-trn-doc.exch-scale
  new_trn-doc.exch-date  = to-day
  new_trn-doc.exch-code  = tt-trn-doc.exch-code
  new_trn-doc.status_    = v-status_
  new_trn-doc.hold-doc-code-child   = "no-hold"
  new_trn-doc.hold-doc-code-parent  = "no-hold"
  new_trn-doc.print-rubl = v-print-rubl
  .
  for each    new_line where
              new_line.supp-type      = temp_parts.supp-type     and
              new_line.supp-code      = temp_parts.supp-code     and
              new_line.host-code      = temp_parts.host-code     and
              new_line.vat-type       = temp_parts.vat-type      and
              new_line.vat-pc         = temp_parts.vat-pc        and
              new_line.contract-code  = temp_parts.contract-code and
              new_line.num            = p-num ,
  each buf2_temp_parts no-lock where
        buf2_temp_parts.host-code      = temp_parts.host-code and
        buf2_temp_parts.price-cli <> ? and
        buf2_temp_parts.price-cli <> 0 and
        buf2_temp_parts.vat-type       = temp_parts.vat-type and
        buf2_temp_parts.contract-code  = temp_parts.contract-code and
        buf2_temp_parts.supp-type      = temp_parts.supp-type and
        buf2_temp_parts.supp-code      = temp_parts.supp-code and
        buf2_temp_parts.vat-pc         = temp_parts.vat-pc    and
        buf2_temp_parts.artic          = new_line.artic       and
        buf2_temp_parts.prod-type      = new_line.prod-type   and
        buf2_temp_parts.prod-code      = new_line.prod-code   and
        buf2_temp_parts.part-code      = new_line.part-code   and
        buf2_temp_parts.price-cli      = new_line.price-cli
      :

    find first temp-2exists where
        temp-2exists.artic = buf2_temp_parts.artic
    and temp-2exists.prod-type = buf2_temp_parts.prod-type
    and temp-2exists.prod-code = buf2_temp_parts.prod-code
    and temp-2exists.doc-code = n-d
    no-error.
    if available temp-2exists then next.

    if new_line.price-cli <= 0  or new_line.price-cli = ? then do:
      &scop my-message substitute("Цена &2   = &1 Пропускаю " , new_line.price-cli  , new_line.artic )
      {&display-message}.
      next.
    end.

    if new_line.fact-qnty <= 0 then do:
      &scop my-message substitute("Количество &2   = &1 Пропускаю " , new_line.fact-qnty  , new_line.artic )
      {&display-message}.
      next.
    end.

    find first gds-list where
                gds-list.artic     = buf2_temp_parts.new_artic     and
                gds-list.prod-type = buf2_temp_parts.new_prod-type and
                gds-list.prod-code = buf2_temp_parts.new_prod-code no-lock no-error .
    if error-status :error then do:
      next.
    end.

    find first tt-doc-line exclusive-lock where
              tt-doc-line.doc-code       = n-d and
              tt-doc-line.artic          = gds-list.artic   and
              tt-doc-line.prod-code      = gds-list.prod-code and
              tt-doc-line.prod-type      = gds-list.prod-type  no-error .
    if not available tt-doc-line then do:
      create  tt-doc-line.
      assign
      tt-doc-line.cli-qnty       = 0
      tt-doc-line.doc-qnty       = 0
      tt-doc-line.fact-qnty      = 0
      .
      create temp-2exists.
      assign
      temp-2exists.artic = buf2_temp_parts.artic
      temp-2exists.prod-type = buf2_temp_parts.prod-type
      temp-2exists.prod-code = buf2_temp_parts.prod-code
      temp-2exists.doc-code = n-d
      .
      release temp-2exists.
    end.
    assign
    tt-doc-line.doc-code       = n-d
    tt-doc-line.status_        = "temp"
    tt-doc-line.obj-code       = new_obj-code
    tt-doc-line.obj-type       = new_obj-type
    tt-doc-line.slt-pc         = buf2_temp_parts.slt-pc
    tt-doc-line.vat-pc         = buf2_temp_parts.vat-pc
    tt-doc-line.cli-base-rate  = 1
    tt-doc-line.cli-qnty       = tt-doc-line.cli-qnty + new_line.fact-qnty
    tt-doc-line.doc-qnty       = tt-doc-line.doc-qnty + new_line.fact-qnty
    tt-doc-line.fact-qnty      = tt-doc-line.fact-qnty + new_line.fact-qnty
    tt-doc-line.ext-doc-type   = v-ext-doc-type
    tt-doc-line.line-num       = next-value (s-line-num, {&db-name_schema})
    tt-doc-line.price-base     = buf2_temp_parts.price-cli
    tt-doc-line.price-cli      = buf2_temp_parts.price-cli
    tt-doc-line.price-rubl     = buf2_temp_parts.price-cli
    tt-doc-line.artic          = gds-list.artic
    tt-doc-line.prod-code      = gds-list.prod-code
    tt-doc-line.prod-type      = gds-list.prod-type
    tt-doc-line.prt-root       = gds-list.prt-root
    tt-doc-line.unit-cli       = gds-list.unit-base
    tt-doc-line.doc-density     = 1 / tt-doc-line.cli-base-rate
    tt-doc-line.fact-density    = 1 / tt-doc-line.cli-base-rate
    .

    find first tt2-doc-line exclusive-lock where
              tt2-doc-line.doc-code       = n-d and
              tt2-doc-line.artic          = gds-list.artic   and
              tt2-doc-line.prod-code      = gds-list.prod-code and
              tt2-doc-line.prod-type      = gds-list.prod-type  no-error .
    if not available tt2-doc-line then do:
      create  tt2-doc-line .
    end.
    BUFFER-COPY tt-doc-line to tt2-doc-line.

    find first tt-gds-dtl exclusive-lock where
              tt-gds-dtl.doc-code   = n-d and
              tt-gds-dtl.prt-code   = tt-doc-line.prt-root and
              tt-gds-dtl.artic      = gds-list.artic   and
              tt-gds-dtl.prod-code  = gds-list.prod-code and
              tt-gds-dtl.prod-type  = gds-list.prod-type  no-error .
    if not available tt-doc-line then do:
      create  tt-gds-dtl .
    end.
    buffer-copy  tt-doc-line  to  tt-gds-dtl
    assign
    tt-gds-dtl.prt-code  =  tt-doc-line.prt-root
    .
  end. /*for each    new_line where*/
  for each tt2-doc-line :
    create tt-parts.
    BUFFER-COPY tt2-doc-line except  tt2-doc-line.status_  TO tt-parts
    assign
    tt-parts.prod-type      = tt2-doc-line.prod-type
    tt-parts.prod-code      = tt2-doc-line.prod-code
    tt-parts.artic          = tt2-doc-line.artic
    tt-parts.in-code        = new_trn-doc.doc-code
    tt-parts.out-code       = new_trn-doc.doc-code
    tt-parts.price-base     = tt2-doc-line.price-cli
    tt-parts.price-rubl     = tt2-doc-line.price-cli
    tt-parts.qnty           = tt2-doc-line.fact-qnty
    tt-parts.obj-type       = new_trn-doc.obj-type
    tt-parts.obj-code       = new_trn-doc.obj-code
    tt-parts.fact-date      = new_trn-doc.fact-date
    tt-parts.fact-num       = new_trn-doc.fact-num
    tt-parts.VAT-pc         = tt2-doc-line.vat-pc
    tt-parts.part-code      = ""
    tt-parts.PS             = ""
    tt-parts.pay-code       = new_trn-doc.pay-code
    tt-parts.status_        = no
    tt-parts.fact-qnty      = tt2-doc-line.fact-qnty
    tt-parts.supp-type      = new_trn-doc.cli-type
    tt-parts.supp-code      = new_trn-doc.cli-code
    tt-parts.rsrv-free      = ?
    tt-parts.doc-type       = new_trn-doc.doc-type
    tt-parts.cli-qnty       = tt2-doc-line.fact-qnty
    tt-parts.pl-code        = 0
    tt-parts.VAT-type       = new_trn-doc.vat-type
    tt-parts.exch-code      = 0
    tt-parts.price-cli      = tt2-doc-line.price-cli
    tt-parts.cli-base-rate  = tt2-doc-line.cli-base-rate
    tt-parts.SLT-pc         = 0
    tt-parts.host-code      = new_trn-doc.host-code
    tt-parts.is-supp        = yes
    tt-parts.SLT-type       = {&without-slt}
    tt-parts.cst-code       = ""
    tt-parts.last-date      = ?
    tt-parts.road-tax-base  = 0
    tt-parts.road-tax-rubl  = 0
    tt-parts.transport-base = 0
    tt-parts.transport-rubl = 0
    tt-parts.other-base     = 0
    tt-parts.other-rubl     = 0
    tt-parts.purch-code     = new_trn-doc.purch-code
    tt-parts.contract-code  = new_trn-doc.contract-code
    no-error.
  end. /*  for each tt2-doc-line :*/

  { str/copy-in.i
    parParentProc
    recid(new_trn-doc)
    tt-trn-doc
    tt2-doc-line
    tt-doc-line-attr
    tt-gds-dtl
    tt-parts
    yes
    yes
    no
    yes
    this-procedure
    no-error }
  if error-status:error then do :
      &scop my-message substitute("Не удалось добавить товар в приходную накладную  (copy-in.i)! &1 &2" , return-value , error-status :get-message(1) )
      {&display-message}.
      return error return-value .
  end.
  v-ii = v-ii + 1.
  run gbl/calc-trn.p ( input parparentproc, input recid(new_trn-doc)) no-error.
  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
  assign
  new_trn-doc.tot-cli = new_trn-doc.tot-calc
  .
  run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
  find first new_trn-doc where new_trn-doc.doc-code = n-d  no-lock no-error .
  if new_trn-doc.status_ <> {&fact} then do:
    &scop my-message substitute("Не удалось закрыть на факт ПН &1 &2 &3" ,n-d , return-value , error-status :get-message(1) )
    {&display-message}.
  end.
end. /*doe*/
end procedure. /* create-nakl */

procedure clear-tt :

do
on error undo, return error return-value
:
  for each tt-trn-doc:
  delete tt-trn-doc.
  end.

  for each tt2-doc-line :
      delete tt2-doc-line .
  end.
  for each tt-doc-line :
      delete tt-doc-line .
  end.
  for each tt-gds-dtl :
      delete tt-gds-dtl .
  end.
  for each tt-parts:
      delete tt-parts .
  end.
  for each lib-trn_ret-doc :
    delete lib-trn_ret-doc.
  end.
  for each lib-trn_ret-line :
    delete lib-trn_ret-line      .
  end.
  for each lib-trn_ret-line-attr :
    delete lib-trn_ret-line.
  end.
  for each lib-trn_ret-dtl :
    delete lib-trn_ret-dtl.
  end.
  for each lib-trn_ret-parts :
    delete lib-trn_ret-parts .
  end.
end. /*doe*/
end procedure. /* clear-tt */


procedure find-doc :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-err as logical   no-undo .
define variable v-err2 as logical   no-undo .
do
on error undo, return error return-value
:
define buffer buf_trn-doc for src.trn-doc  .
define buffer buf_parts   for src.parts  .
define buffer buf_goods   for src.goods  .

define variable v-err as integer   no-undo .
p-err = false .
  for each buf_trn-doc no-lock where
           buf_trn-doc.obj-type = p-obj-type and
           buf_trn-doc.obj-code = p-obj-code and
           buf_trn-doc.status_ <> {&fact}
  :
    &scop my-message substitute("Не закрыт документ &1  &2 " , buf_trn-doc.doc-code , buf_trn-doc.doc-type )
    {&display-message}.
    p-err = true  .
  end.
  for each buf_parts no-lock where
          buf_parts.obj-type = p-obj-type and
          buf_parts.obj-code = p-obj-code and
          buf_parts.out-code = {&free-code} and
          buf_parts.fact-qnty > 0  and
          buf_parts.contract-code > 0
   :
      if not can-find( first old_contract-specif no-lock where
                        old_contract-specif.contract-num = buf_parts.contract-code and
                        old_contract-specif.host-code    = buf_parts.host-code ) then next.

      find first buf_goods no-lock where
                buf_goods.artic     = buf_parts.artic and
                buf_goods.prod-type = buf_parts.prod-type and
                buf_goods.prod-code = buf_parts.prod-code
                  no-error .
      find first  old_contract-specif no-lock where
                  old_contract-specif.contract-num = buf_parts.contract-code and
                  old_contract-specif.host-code    = buf_parts.host-code and
                  old_contract-specif.gds-code     = buf_goods.gds-code  no-error .
      if not available old_contract-specif then do:
        &scop my-message substitute("Будет мешать закрытию ПН : Товара &1 &2 &3 &4 нет в текущей спецификации Договора Внутр.№ &5" , buf_goods.prod-type, buf_goods.prod-code ,buf_goods.artic,buf_goods.gds-name , buf_parts.contract-code )
        {&display-message}.
      end.
      else do:
       { str/ckcntspc.i
        buf_parts.host-code
        buf_parts.contract-code
        buf_goods.gds-code
        true
        buf_parts.VAT-type
        buf_parts.VAT-pc
        no-error
       }
       if error-status :error then do:
        &scop my-message substitute("Товара &1 &2 &3 &4 нет в текущей спецификации Договора Внутр.№ &5" , buf_goods.prod-type, buf_goods.prod-code ,buf_goods.artic,buf_goods.gds-name , old_contract-specif.contract-num )
        {&display-message}.
       end.
     end.
   end. /*  for each buf_parts no-lock where*/

   for each buf_parts no-lock where
            buf_parts.obj-type = p-obj-type and
            buf_parts.obj-code = p-obj-code and
            buf_parts.out-code = {&free-code} and
            buf_parts.fact-qnty < 0
   :
      find first buf_goods no-lock where
                buf_goods.artic     = buf_parts.artic and
                buf_goods.prod-type = buf_parts.prod-type and
                buf_goods.prod-code = buf_parts.prod-code and
                buf_goods.stts = 0 no-error .
    if available buf_goods then do:
      put stream str unformatted
      substitute("&5&1&5 &2 &5&3&5 &4" , buf_goods.prod-type, buf_goods.prod-code ,buf_goods.artic, 0 , {&double-quote} )
      skip.
      p-err = true  .
      v-err2 = true  .
    end.
  end. /*for each buf_parts no-lock where*/

  if v-err2 = true  then do:
    &scop my-message substitute("Есть отрицательные партии в свободной зоне ! Сделайте инвентаризацию по товарам из списка negparts.gds" )
    {&display-message}.
  end.

end. /*doe*/
end procedure. /* find-doc */

procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .
do
on error undo, return error return-value
:
define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable v-db-num as integer   no-undo .
  { gbl/objdbnum.i
     v-cntxt-obj-type
     v-cntxt-obj-code
     v-db-num
     }

  if v-db-num <> g#db-num then return .

  &scop my-message substitute(" Закрытие документа &1 на ФАКТ" , p-trn-code )
  {&display-message}.

  run str/trn-stat.p (
    input  parparentproc  ,
    input  this-procedure ,
    input  {&close-fact} ,
    input  p-trn-code,
    input  false /* проверка старого возврата */ ,
    input  v-cntxt-db-num,
    input  false /* проверка переоценки */,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  false ,
    output varchg-inv ,
    output table gds-list1 )
    no-error.
    if error-status:error then do :
        &scop my-message substitute(" Ошибка при закрытии документа &3 &1 &2" , error-status :get-message(1)  , return-value , p-trn-code )
        {&display-message}.
    end.
end. /*doe*/
end procedure. /* clos-trn2 */
