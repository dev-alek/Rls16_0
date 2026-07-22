block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: ththovr.p $
$Archive: cmp/ththovr.p $

Создание продажных цен на основе старой версии TH и перенос в 16.0

Автор: Чернова Светлана Александровна
Дата создания: 01/11/09
Author: Svetlana Chernova
Creation date: 01/11/09

*/
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ththovr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/ththovr.p $":U .
define variable vss-description as character no-undo init "Создание продажных цен на основе старой версии TH и перенос в 16.0".
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
define buffer buf_price-doc-forming for ub.price-doc-forming  .
{ str/alt-calc.i "func"  }
{ str/alt-calc.i "proc" "''"  "''"  }
{ str/mpl-lib.i  }
{ str/mpl-lib3.i }
{ trg/check-bc.i }
{ str/lastincs.i }
{ ref/gdsoattr.i }
{ ref/obji-ad.i  }
{ ref/typl-ad.i  }
{ gbl/waitfram.i }
{ cmp/thth150.i }
{ cmp/thth14.i }
{ ref/extclass.i }
{ utl/ththsaco.i }


define variable v-ok as logical   no-undo .
define variable p-from-version as character no-undo .

define buffer new_clients     for ub.clients  .
define buffer new_ext-classif for ub.ext-classif  .
define buffer old_gds-obj     for src.gds-obj  .
define buffer old_goods       for src.goods  .
define buffer new_goods       for ub.goods  .

define variable new_obj-code  as integer   no-undo .
define variable new_obj-type  as character no-undo .
define variable new_host-code as integer   no-undo .
define variable new_gds-code  as integer   no-undo .
define variable v-counter     as integer   no-undo .
define variable v-ii          as integer   no-undo .
define variable v-err         as integer   no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .

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
define buffer buf_global-state for ub.global-state  .
find first buf_global-state exclusive-lock no-error .
if not available buf_global-state then do:
   create buf_global-state.
end.


&scop my-message substitute("Создание продажных цен на основе &1 БД и перенос в 16.0 ...", p-from-version)
{&display-message}.
run save-conf-par in this-procedure .
run proc_import in this-procedure .
run re-save-conf-par in this-procedure .
{&hide-count-message}.



procedure proc_import :
do
on error undo, return error  substitute("ошибка &1 &2" , error-status :get-message(1) , return-value )
:
  for each obj-list :
    EMPTY TEMP-TABLE gds-list no-error .
    if error-status :error then do:
      &scop my-message substitute("ошибка &1 &2" , error-status :get-message(1) , return-value )
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
      return error  .
    end.
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
    run ver-gtpl in this-procedure ( input new_obj-type
                                    ,input new_obj-code ).
    for each old_gds-obj no-lock where
           old_gds-obj.obj-type = obj-list.obj-type
       and old_gds-obj.obj-code = obj-list.obj-code
       and old_gds-obj.price-sale > 0 ,
       first old_goods no-lock where
          old_goods.gds-code = old_gds-obj.gds-code and
          ( old_gds-obj.fact-qnty     <> 0 or
            old_goods.stts = 0 )
           :
      /* поиск соответствия старого gds-code p-from-version версии  в 16.0 */
      find first new_ext-classif no-lock where
                new_ext-classif.classif-subject = {&table_goods}
            and  new_ext-classif.classif-name    = v-classif-name
            and  new_ext-classif.db-num          = - 1
            and  new_ext-classif.Key#_One        = old_goods.gds-code no-error .
      if error-status :error then do:
        &scop my-message substitute("Пропускаю &1 &2 (товар &3)" , error-status :get-message(1) , return-value , old_goods.gds-code)
        {&display-message}.
        next  .
      end.
      if new_ext-classif.uniq-key-rec = '' then do:
        &scop my-message substitute("Нет связки по товару &1" , old_goods.gds-code )
        {&display-message}.
        next  .
      end.

      run uni-k in this-procedure (
                   input  new_ext-classif.uniq-key-rec
                  ,input  {&table_goods}
                  ,output v-ttc
                  ,output v-ttc
                  ,output new_gds-code ) .

      find first new_goods no-lock where
                new_goods.gds-code = new_gds-code no-error .
      if new_goods.stts <> 0 then do:
        &scop my-message substitute("Удаленный &2 (товар &1) в новой БД" , new_goods.gds-name , new_goods.gds-code )
        {&display-message}.
        /* next. */
      end.
      find first gds-list where
                  gds-list.gds-code = new_gds-code no-error .
      if available gds-list then do:
        if gds-list.qnty <> old_gds-obj.price-sale then do:
          if gds-list.qnty < old_gds-obj.price-sale then do:
            gds-list.qnty = old_gds-obj.price-sale.
          end.
          /*
          &scop my-message substitute("ошибка при импорте товара (код в СВОЕЙ БД &1, код в ЧУЖОЙ БД &3) - более одного товара в ЧУЖОЙ БД на один товар в СВОЕЙ БД и ЦЕНЫ НЕ СВОПАДАЮТ" ~
                                    ,new_gds-code ~
                                    ,old_goods.gds-code)
          {&display-message}.
          return error  .
          */
        end.
      end.
      else do:
        create gds-list .
        buffer-copy new_goods to gds-list
        assign
        gds-list.qnty = old_gds-obj.price-sale
        .
     end.
   end.
    /* импорт шапки */
    run import-hed in this-procedure no-error .
    if error-status :error then do:
      &scop my-message substitute("ошибка при импорте документа ДНЦ  &1 &2" , error-status :get-message(1) , return-value )
      {&display-message}.
      return error  .
    end.
  end.

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

end.

end procedure. /* proc_import */

procedure import-hed :

define variable new_cli-type as character no-undo .
define variable new_cli-code as integer   no-undo .
define variable  v-price-doc-recid   as recid                            no-undo.
define variable  v-update            as logical                          no-undo.
define variable  v-price-sale        like ub.price-list.price-sale       no-undo.
define variable  v-counter           as integer                          no-undo.

define buffer buf_price-doc        for ub.price-doc.

do
on error undo, return error substitute("ошибка &1 &2" , error-status :get-message(1) , return-value )
:
  v-ii = v-ii + 1.
  if v-ii modulo 10 = 0 then do:
    &scop my-count-message substitute("Импорт ДНЦ ... записей &1", v-ii)
    {&display-count-message}.
  end.

  define variable v-host-code as integer   no-undo .

{ gbl/hostcode.i
  new_obj-type
  new_obj-code
  new_host-code
  }
  /*надо знать значение pr-altex pr-sclex pr-notls */
  { gbl/getsect.i run new_obj-type new_obj-code {&attr-overval} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-altex} then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-sclex} then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
      if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-notls} then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
  end.

  /* Создание переоценки */
  run prcreate-new-price-doc in this-procedure ( input v-cntxt-db-num
                                              , input new_obj-type
                                              , input new_obj-code
                                              , input ?
                                              , input ?
                                              , input ?
                                              , input ?
                                              , output v-price-doc-recid
                                              ) no-error.
  if error-status:error
  then do:
    &scop my-message substitute("Ошибка создания шапки ДНЦ   &1 &2", error-status :get-message(1) ,return-value )
    {&display-message}.
    return error.
  end.
  else do:
    find first buf_price-doc exclusive-lock
         where recid( buf_price-doc ) = v-price-doc-recid
    .
    find first buf_price-doc-forming no-lock where
          buf_price-doc-forming.plt-id     = buf_price-doc.plt-id
      and buf_price-doc-forming.plt-db-num = buf_price-doc.plt-db-num
      and buf_price-doc-forming.pdf-id     = buf_price-doc.pdf-id
      and buf_price-doc-forming.pdf-db     = buf_price-doc.pdf-db      no-error .

  end.

  assign
  v-counter = 0
  .
  gds-list-line-create:
  for each gds-list
  :
    assign
    v-counter = v-counter + 1
    .
    run prcreate-new-price-doc-forming-gds in this-procedure (
        input recid ( buf_price-doc-forming )
      , input new_obj-type
      , input new_obj-code
      , input par-pr-notls
      , input par-pr-altex
      , input par-pr-sclex
      , input v-counter
      , input gds-list.gds-code
      , input gds-list.qnty  /* цена */
      ) no-error.
    if error-status:error   then do:
      assign
      v-counter = v-counter - 1
      .
      &scop my-message substitute("Не удалось включить в ДНЦ товар   &1 &2", error-status :get-message(1) ,gds-list.gds-code )
      {&display-message}.
      next gds-list-line-create.
    end.
  end.

  &scop my-message substitute("Создан ДНЦ &1  на объектe &2&3 Количество товаров в документе: &4", buf_price-doc-forming.pdf-id , New_obj-type, new_obj-code,v-counter )
  {&display-message}.

  if available buf_price-doc then do:
    delete buf_price-doc.
  end.
/*
  run str/pdf-clos.p (
   parparentproc  ,
   p-parent-handle,
   p-log-handle ,
 ( string(recid( buf_price-doc-forming )) + {&delim-par} +
    'no' + {&delim-par} +
    'no' + {&delim-par} +
    '?'  + {&delim-par} +
    '?'  + {&delim-par} +
    {&fact} + {&delim-par} +
    '?' + {&delim-par} +
    string( false )  )
    ) no-error .
  */

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

procedure ver-gtpl :
 /* проверяет наличие и если надо создает ГОЦ и ГТПЛ для объекта 16.0  */
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define variable  v-plt-id        as integer   no-undo .
define variable  v-plt-db-num    as integer   no-undo .
define variable  v-col           as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable v-id     as integer   no-undo .
define variable v-db-num as integer   no-undo .
define variable v-curr-code as integer   no-undo .

define variable loc_calc-round-method  as character no-undo .
define variable loc_calc-round-base    as decimal   no-undo .
define variable loc_calc-increase-pc   as decimal   no-undo .
define variable loc_calc-method        as character no-undo .

define variable par-type as character no-undo .
define variable v-base-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable v-curr-abbr-bv as character no-undo .
define variable v-exch-rate as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-curr-abbr-vd as character no-undo .
define variable v-is-base as logical   no-undo .

define variable p-gop-id     as integer   no-undo .
define variable p-gop-db-num  as integer   no-undo .
define variable  p-recid as recid no-undo .


define buffer buf_obj-grp-obj-price for ub.obj-grp-obj-price  .
do
on error undo, return error return-value
:
&scop my-message substitute("Проверка наличия справочников ценообразования по объекту &1&2" ,  p-obj-type, p-obj-code )
{&display-message}.

{ gbl/gtplobjq.i
  p-obj-type
  p-obj-code
  v-plt-id
  v-plt-db-num
  v-col
  no-error }

if error-status :error or v-col  >= 1 then return .
  v-id = 0.
  find first buf_obj-grp-obj-price no-lock where
             buf_obj-grp-obj-price.stts = 0
         and buf_obj-grp-obj-price.obj-type = p-obj-type
         and buf_obj-grp-obj-price.obj-code = p-obj-code no-error .
  if available buf_obj-grp-obj-price then do:
    assign
    v-id     = buf_obj-grp-obj-price.gop-id
    v-db-num = buf_obj-grp-obj-price.gop-id
    .
  end.

  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/basecode.i  v-host-code   v-base-code }
  { gbl/r-b-curr.i  v-host-code   v-curr-code  }
  { gbl/exchrate.i v-base-code TODAY v-base-rate v-base-scale v-curr-abbr-bv }
  { gbl/exchrate.i v-curr-code TODAY v-exch-rate v-exch-scale v-curr-abbr-vd }

  { gbl/getsect.i run p-obj-type p-obj-code {&attr-overval} }
  for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-incpc} then loc_calc-increase-pc = thbjattr_thbj-attr.property-value-decimal .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndmt} then loc_calc-round-method = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndbs} then loc_calc-round-base = thbjattr_thbj-attr.property-value-decimal .
  end.

  case loc_calc-round-method:
    when "pr-round-9end" then
      loc_calc-round-method = {&pr-round-9end}.
    when "pr-round-9-99end" then
      loc_calc-round-method = {&pr-round-9-99end}.
    when "pr-round-integer" then
      loc_calc-round-method = {&pr-round-integer}.
    when "pr-round-select" then
      loc_calc-round-method = {&pr-round-select}.
    when "pr-round-up" then
      loc_calc-round-method = {&pr-round-up}.
    when "pr-round-coef" then
      loc_calc-round-method = {&pr-round-coef}.
    when "pr-round-off" then
      loc_calc-round-method = {&pr-round-off}.
    otherwise
      loc_calc-round-method = {&pr-round-off}.
  end case.


  { gbl/rbisbase.i v-is-base }
  loc_calc-method = {&pr-calc-no}.

  do transaction :
    if p-gop-id = 0 then do: /* если нет группы объектов */
      assign
      p-gop-id = next-value ( s-gop , {&db-name_schema} )
      p-gop-db-num =  v-cntxt-db-num
      .

      create ub.grp-obj-price.
      assign
      ub.grp-obj-price.gop-db-num   = p-gop-db-num
      ub.grp-obj-price.gop-id       = p-gop-id
      ub.grp-obj-price.db-num-chg   = v-cntxt-db-num
      ub.grp-obj-price.stts         = 0
      ub.grp-obj-price.sys-date     = today
      ub.grp-obj-price.sys-time     = time
      ub.grp-obj-price.sys-time-chr = string(ub.grp-obj-price.sys-time,"hh:mm")
      ub.grp-obj-price.who          = v-cntxt-userid
      ub.grp-obj-price.name-group   = "По объекту " + p-obj-type + string ( p-obj-code )
      .
      run  objo-ADD in this-procedure (
                                        input  p-gop-db-num
                                        ,input  p-gop-id
                                        ,input  p-obj-type
                                        ,input  p-obj-code
                                        ,input  0
                                        ,input  v-cntxt-db-num
                                        ,input  v-cntxt-userid
                                        ,output p-recid ) .
    end. /*if p-gop-id = 0 then do*/
    /* ГТПЛ */
    find first ub.price-list-type no-lock where
              ub.price-list-type.main = true
          and ub.price-list-type.gop-id = p-gop-id
          and ub.price-list-type.gop-db-num = p-gop-db-num
          and ub.price-list-type.stts       = 0
          and ub.price-list-type.only-gbd = integer ( true )
          and ub.price-list-type.plt-db-num = v-cntxt-db-num no-error .
    if available ub.price-list-type then do:
      v-plt-id = ub.price-list-type.plt-id .
    end.
    else do:
      v-plt-id = next-value (s-plt, {&db-name_schema})  .
      run type-price-list-ADD in this-procedure (
            input v-cntxt-db-num                                    /*p-db-num                       */
          , input v-plt-id                                          /*p-id                           */
          , input "ГТПЛ по объекту " + p-obj-type + string (p-obj-code) /*p-name                         */
          , input 0                                                 /*p-ban-discnt                   */
          , input loc_calc-round-method                             /*p-calc-round-method            */
          , input loc_calc-round-base                               /*p-calc-round-base              */
          , input loc_calc-increase-pc                              /*p-calc-increase-pc             */
          , input loc_calc-method                                   /*p-calc-method                  */
          , input int ( true )                                      /*p-create-price-doc             */
          , input false                                             /*p-fix-cource-crc-base          */
          , input false                                             /*p-fix-cource-crc-doc           */
          , input int ( false )                                     /*p-have-rs-qnty-group           */
          , input false                                             /*p-have-rs-sum-group            */
          , input true                                              /*p-main                         */
          , input int ( true  )                                     /*p-only-gbd                     */
          , input v-cntxt-db-num                                    /*p-plt-main-db-num              */
          , input  ?                                                /*p-plt-main-id                  */
          , input  0                                                /*p-priority                     */
          , input  0                                                /*p-rs-buyer                     */
          , input  true                                             /*p-send-cassa                   */
          , input  int  ( true  )                                   /*p-under-hand-corr              */
          , input  ?                                                /*p-under-round-method           */
          , input  ?                                                /*p-under-perc                   */
          , input  int ( false )                                    /*p-under-type-list              */
          , input  0                                                /*p-use-cassa                    */
          , input  int ( false )                                    /*p-use-gds-group                */
          , input  2                                                /*p-use-obj                      */
          , input  0                                                /*p-work-date                    */
          , input  v-cntxt-db-num                                   /*p-bgr-db-num                   */
          , input  ?                                                /*p-bgr-id                       */
          , input  v-curr-code                                      /*p-curr-code                    */
          , input  p-gop-db-num                                     /*p-gop-db-num                   */
          , input  v-cntxt-db-num                                   /*p-gop-db-num-for-calc-turnover */
          , input  p-gop-id                                         /*p-gop-id                       */
          , input  ?                                                /*p-gop-id-for-calc-turnover     */
          , input  v-cntxt-db-num                                   /*p-qgr-db-num                   */
          , input  ?                                                /*p-qgr-id                       */
          , input  v-cntxt-db-num                                   /*p-sgr-db-num                   */
          , input  ?                                                /*p-sgr-id                       */
          , input  v-cntxt-db-num                                   /*p-tog-db-num                   */
          , input  ?                                                /*p-tog-id                       */
          , input  ?                                                /*p-obj-turnover                 */
          , input  v-cntxt-db-num                                   /*p-ttg-summa                    */
          , input  v-cntxt-userid                                   /*p-userid                       */
          , input  v-cntxt-db-num                                   /*p-db-num-usr                   */
          , input  int( false )                                     /*p-have-rs-turn-group           */
          , input  0                                                /*p-have-tog-db-num              */
          , input  ?                                                /*p-have-tog-id                  */
          , input  int( false  )                                    /*p-use-cash-pay                 */
          , input  int( false  )                                    /*p-use-pay-type                 */
          , output p-recid                                   /*p-recid                        */
          , input table TT_cassa                             /*table for tt_cassa .*/
          , input table TT_grp                               /*table for tt_grp   .*/
          , input table TT_pay-type                          /*table for tt_pay-type .*/
          , input table TT_cash-pay                          /*table for tt_cash-pay .*/
          ) no-error .
      find first ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
      &scop my-message substitute("Создан  &3 (№ &4 ) &1 &2" , error-status :get-message(1) , return-value , ub.price-list-type.name , ub.price-list-type.plt-id)
      {&display-message}.
    end. /*else if available ub.price-list-type then do:*/
  end. /*  do transaction :*/
end. /*doe*/
end procedure.