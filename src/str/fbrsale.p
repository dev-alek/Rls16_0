block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Производство блюд при продаже

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-parameters       as character   - Список параметров через {&delim-par}

Output:

*/

define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbrhist-handle as widget-handle    no-undo.
define input parameter p-log-handle     as handle           no-undo.
define input parameter p-parameters     as character        no-undo.
{ gbl/objsrv.i }

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Производство блюд при продаже":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/doc-code.i }
{ trg/partslib.i }
{ str/writelog.i def "'fbr.log'" no-create }
/*НЕ МЕНЯТЬ НА g e t c n t x t . i def!!!! процедра вызывается в автомате а g e t c n t x t . i get там не работает!!!*/
define variable v-cntxt-db-num as integer no-undo .
define variable v-cntxt-userid as character no-undo .
define variable v-cntxt-obj-type as character no-undo .
define variable v-cntxt-obj-code as integer no-undo .
define variable v-cntxt-host-code-obj  as integer no-undo .
{ str/temp_upd.i }
{ str/fbrrest.i  }
{ str/fbrlib.i   }
{ str/fbrpln.i   }
{ str/fbradd.i   }
{ str/fbrhist.i  }
{ str/trdcalib.i }
{ str/fbrattr.i  }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ gbl/ggoattr.i  }

{ str/fbr-log.i clear }

define temp-table temp_fbr-objects no-undo
   field obj-type as character
   field obj-code as integer

   index pi is primary unique obj-type obj-code
   .
define variable v-fbr-doc-code           as character no-undo.
define variable v-out-gds-code           as integer   no-undo.
define variable v-out-trn-type           as character no-undo.
define variable v-out-gds-qnty           as decimal   no-undo.
define variable v-out-recipe-type        as character no-undo.
define variable v-out-recipe-code        as character no-undo.
define variable v-recipe-found           as logical   no-undo.
define variable v-no-need-good           as logical   no-undo.
define variable v-same-good              as logical   no-undo.
define variable v-same-good-old-qnty     as decimal   no-undo.
define variable v-reserved               as logical   no-undo.
define variable v-doc-code               as character no-undo.
define variable v-kitchen-rest           as logical   no-undo.
define variable v-store-rest             as logical   no-undo.
define variable v-kitchen-free-qnty      as decimal   no-undo.
define variable v-restaurant-free-qnty   as decimal   no-undo.
define variable v-need-qnty              as decimal   no-undo.
define variable v-fbr-doc-is-not-empty   as logical   no-undo.
define variable v-fbrsale-hst-upper-code as integer   no-undo.
define variable v-upper-code             as integer   no-undo.

define variable v-store-type             as character no-undo.
define variable v-store-code             as integer   no-undo.
define variable v-host-code              as integer   no-undo.
define variable v-is-res                 as character no-undo.
define variable v-par-type               as character no-undo.
define variable v-mess                   as character no-undo .
define variable v-value                  as character no-undo .
define variable v-type                   as character no-undo .
define variable v-attr-value             as character no-undo .
define variable v-attr-value-rec         as character no-undo .
define variable v-attr-type              as character no-undo .
define buffer buf_recipe      for recipe.
define buffer buf_fbr-doc     for fbr-doc.
define buffer buf_doc-fbr-gds for doc-fbr-gds.
define buffer buf_goods       for goods.
define buffer buf_trn-doc     for trn-doc.
define buffer buf_sale-doc    for ub.sale-doc.
define buffer buf_obj_recipe  for recipe.
{ gbl/objsrv.i }

define variable v-ban-recipes as logical no-undo .
define variable v-ban-altr    as logical no-undo .

do
   for buf_recipe
   , buf_fbr-doc
   , buf_doc-fbr-gds
   , buf_goods
   , buf_trn-doc
   , buf_sale-doc
   on error undo, return error
   :     
   { gbl/working.i }
   /*НЕ ПЕРЕДЕЛЫВАТЬ НА g e t c n t x t .i get процедура вызывается в автомате!!!!*/
   run get-db-num in parparentproc ( output v-cntxt-db-num).
   run get-userid in parparentproc ( output v-cntxt-userid).
   assign
      v-doc-code     = entry( 1, p-parameters, {&delim-par} )
      v-kitchen-rest = ( entry( 2, p-parameters, {&delim-par} ) = "yes" )
      v-store-rest   = ( entry( 3, p-parameters, {&delim-par} ) = "yes" )
      .

   do transaction
      on error undo, return error
      :
      find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = v-doc-code
         .
      assign
         v-store-type = buf_trn-doc.obj-type
         v-store-code = buf_trn-doc.obj-code
         .
      assign
         v-cntxt-obj-type = buf_trn-doc.obj-type
         v-cntxt-obj-code = buf_trn-doc.obj-code
         .
      { gbl/hostcode.i
        v-store-type
        v-store-code
        v-host-code
    }
      run gbl/conf-rd.p (
         input "is-res"
         , input v-host-code
         , input v-store-type
         , input v-store-code
         , input ""
         , input ""
         , input ""
         , input no
         , output v-is-res
         , output v-par-type
         ) no-error.
      if error-status :error
         or v-is-res <> "yes"
         then 
      do:
         run write-log in p-log-handle (
            input 0
            , input substitute( "Не включен АРМ Ресторан.&1Невозможна автоматическая раскрутка товаров производства&1при закрытии продажи.&1&1Обратитесь к администратору."
            , {&new-line}
            )
            ).
      end. 
      
      if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-store-type, v-store-code):IsBanRecipes then v-ban-recipes = true . 
      if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-store-type, v-store-code):IsBanAltr then v-ban-altr = true .
      for each buf_sale-doc where
         buf_sale-doc.inkas-code = v-doc-code
         and buf_sale-doc.fbrsale = yes,
         each buf_doc-fbr-gds no-lock
         where buf_doc-fbr-gds.obj-type     = v-store-type
         and buf_doc-fbr-gds.obj-code     = v-store-code
         and buf_doc-fbr-gds.out-code     = buf_sale-doc.doc-code
         /* for each temp_fbr-goods */
         on error undo, return error
         :
         find first temp_fbr-objects
            where temp_fbr-objects.obj-type = buf_doc-fbr-gds.fbr-obj-type
            and temp_fbr-objects.obj-code = buf_doc-fbr-gds.fbr-obj-code
            no-error.
         if not available temp_fbr-objects
            then 
         do:
            create temp_fbr-objects.
            assign
               temp_fbr-objects.obj-type = buf_doc-fbr-gds.fbr-obj-type
               temp_fbr-objects.obj-code = buf_doc-fbr-gds.fbr-obj-code
               .
         end.
      end.        /* for each buf_doc-fbr-gds */
      run write-log in p-log-handle (
         input 1
         , input substitute( "Ресторан &1 &2. Документ продажи '&3'."
         , v-store-type
         , v-store-code
         , v-doc-code
         )
         ).
      run writelog in this-procedure (
         input log-file-name
         , input 0
         , input substitute( "Ресторан &1 &2. Документ продажи '&3'."
         , v-store-type
         , v-store-code
         , v-doc-code
         )
         ).
      if valid-handle ( p-fbrhist-handle )
         then 
      do:
         run fbrhist-set-zero-upper-code in p-fbrhist-handle.
         run fbrhist-write in p-fbrhist-handle (
            input v-cntxt-userid
            , input v-store-type
            , input v-store-code
            , input {&fbrhist-type-run}
            , input 1
            , input "str/fbrsale.p"
            , input substitute( "parameters: &1", p-parameters )
            , input v-doc-code
            , input {&res-autofbr}
            , input ""
            , input no
            , input ""
            , input ""
            , input 0
            , input ""
            , input 0
            , input substitute( "Запуск автопроизводства по документу продажи '&3' на объекте &1 &2."
            , v-store-type
            , v-store-code
            , v-doc-code
            )
            , input no
            ).
         run fbrhist-set-upper-code in p-fbrhist-handle.
         run fbrhist-save-current-code in p-fbrhist-handle.
      end.        /* if valid-handle ( p-fbrhist-handle ) */
      for each temp_fbr-objects
         on error undo, return error
         :
         run write-log in p-log-handle (
            input 3
            , input substitute( "Кухня &1 &2."
            , temp_fbr-objects.obj-type
            , temp_fbr-objects.obj-code
            )
            ).
         run writelog in this-procedure (
            input log-file-name
            , input 0
            , input substitute( "Кухня &1 &2."
            , temp_fbr-objects.obj-type
            , temp_fbr-objects.obj-code
            )
            ).
         run fbrpln-create-fbr-doc in this-procedure (
            input temp_fbr-objects.obj-type
            , input temp_fbr-objects.obj-code
            , input v-doc-code
            , input ( v-cntxt-db-num <> 0 )
            , input v-cntxt-userid
            , output v-fbr-doc-code
            ).
         run write-log in p-log-handle (
            input 5
            , input substitute( "Создается документ производства '&1'..."
            , v-fbr-doc-code
            )
            ).
         run writelog in this-procedure (
            input log-file-name
            , input 0
            , input substitute( "Создается документ производства '&1'..."
            , v-fbr-doc-code
            )
            ).
         run fbrattr-write in this-procedure (
            input {&fbrattr-type-fbr-doc}
            , input v-fbr-doc-code
            , input {&trdcattr-fbrauto}
            , input "yes":U
            ) no-error.
         if error-status :error
            then 
         do:
            v-mess = substitute("&1 &2 &3&4Не удалось установить атрибут для документа производства." +
               "Имя атрибута: &5:&4&6&4&7"
               ,vss-workfile
               ,vss-revision
               ,vss-description
               ,{&new-line}
               ,{&trdcattr-fbrauto}
               , error-status:get-message(1)
               , return-value
               ).
            run write-log in p-log-handle (
               input 5
               , input v-mess
               ).
            run writelog in this-procedure (
               input log-file-name
               , input 0
               , input v-mess
               ).

         end.
         if valid-handle ( p-fbrhist-handle )
            then 
         do:
            run fbrhist-write in p-fbrhist-handle (
               input v-cntxt-userid
               , input temp_fbr-objects.obj-type
               , input temp_fbr-objects.obj-code
               , input {&fbrhist-type-create-doc}
               , input 1
               , input "str/fbrsale.p"
               , input substitute( "parameters: &1", p-parameters )
               , input v-doc-code
               , input {&res-autofbr}
               , input {&g___new}
               , input no
               , input ""
               , input ""
               , input 0
               , input ""
               , input 0
               , input substitute( "Создан документ производства '&3' на объекте &1 &2."
               , temp_fbr-objects.obj-type
               , temp_fbr-objects.obj-code
               , v-fbr-doc-code
               )
               , input no
               ).
            run fbrhist-set-upper-code in p-fbrhist-handle.
         end.        /* if valid-handle ( p-fbrhist-handle ) */
          
         create-by-recipe:
         for each buf_sale-doc where
            buf_sale-doc.inkas-code = v-doc-code
            and buf_sale-doc.fbrsale = yes,
            each buf_doc-fbr-gds no-lock
            where buf_doc-fbr-gds.obj-type     = v-store-type
            and buf_doc-fbr-gds.obj-code     = v-store-code
            and buf_doc-fbr-gds.fbr-obj-type = temp_fbr-objects.obj-type
            and buf_doc-fbr-gds.fbr-obj-code = temp_fbr-objects.obj-code
            and buf_doc-fbr-gds.out-code     = buf_sale-doc.doc-code
            on error undo, return error
            :
            if v-kitchen-rest = yes
               then 
            do:
               /*Проверка рецепта по макировке
               if v-ban-altr or v-ban-recipes then 
               do:
                  /*проверка */
                  for each buf_obj_recipe no-lock where buf_obj_recipe.gds-code = buf_doc-fbr-gds.gds-code:
                     if buf_obj_recipe.recipe-type = {&manufacturing} and v-ban-recipes then
                     do:
                        for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                           run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                              , input  {&attr-mark-type}
                              , output v-attr-value
                              , output v-attr-type
                              ) no-error .
                           if v-attr-value <> "" and v-attr-value <> "not-type" then
                           do:
                              v-mess =  "Рецепт производства " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " содержит маркированный товар." .
                              run write-log in p-log-handle (
                                 input 5
                                 , input v-mess
                                 ).
                              run writelog in this-procedure (
                                 input log-file-name
                                 , input 0
                                 , input v-mess
                                 ).
                              undo create-by-recipe, next create-by-recipe.
                           end.
                        end.
                     end.
                     if buf_obj_recipe.recipe-type = {&alternative} and v-ban-altr then
                     do:
                        for first buf_goods no-lock where buf_goods.gds-code = buf_obj_recipe.gds-code,
                           first ub.gds-grp exclusive-lock where ub.gds-grp.node-code = buf_goods.grp-code:
                           run ggoattr-value (
                              input   ub.gds-grp.node-code
                              ,input   buf_obj_recipe.host-code
                              ,input   buf_obj_recipe.obj-type
                              ,input   buf_obj_recipe.obj-code
                              ,input   {&ggoattr-ban-sales-via-cd}
                              ,output   v-value
                              ,output   v-type
                              ) no-error .
                           if error-status :error then
                           do:
                              undo, return error.
                           end.
                           if v-value <> "yes" and v-value <> "true" then
                           do:
                              run ggoattr-value (
                                 input   ub.gds-grp.node-code
                                 ,input   0
                                 ,input   ""
                                 ,input   0
                                 ,input   {&ggoattr-ban-sales-via-cd}
                                 ,output   v-value
                                 ,output   v-type
                                 ) no-error .
                              if error-status :error then
                              do:
                                 undo, return error.
                              end.
                              if v-value <> "yes" and v-value <> "true" then
                              do:
                                 v-mess =  "Рецепт альтернатива " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + {&new-line} + "входит в группу, у которой не установлен атрибут: " + {&new-line} + "Запрет передачи на кассу." .
                                 run write-log in p-log-handle (
                                    input 5
                                    , input v-mess
                                    ).
                                 run writelog in this-procedure (
                                    input log-file-name
                                    , input 0
                                    , input v-mess
                                    ).
                                 undo create-by-recipe, next create-by-recipe.
                              end.
                           end.
                        end.
                     end.
                     if buf_obj_recipe.recipe-type = {&gathering} and v-ban-recipes then
                     do:
                        for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_obj_recipe.recipe-code:
                           run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                              , input  {&attr-mark-type}
                              , output v-attr-value
                              , output v-attr-type
                              ) no-error .
                           if v-attr-value <> "" and v-attr-value <> "not-type" then
                           do:
                              run gds-attr-value in this-procedure  ( input  buf_obj_recipe.gds-code
                                 , input  {&attr-mark-type}
                                 , output v-attr-value-rec
                                 , output v-attr-type
                                 ) no-error .
                              if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                              do:
                                 v-mess =   "Рецепт комплектации " + buf_obj_recipe.recipe-code + " " + buf_obj_recipe.recipe-name + " должен быть маркированным." .
                                 run write-log in p-log-handle (
                                    input 5
                                    , input v-mess
                                    ).
                                 run writelog in this-procedure (
                                    input log-file-name
                                    , input 0
                                    , input v-mess
                                    ).
                                 undo create-by-recipe, next create-by-recipe.
                              end.
                              else leave.
                           end.
                        end.
                     end.
                  end.
               end.   
               */                      

               run fbrrest-get-free-qnty in this-procedure (
                  input temp_fbr-objects.obj-type
                  , input temp_fbr-objects.obj-code
                  , input buf_doc-fbr-gds.gds-code
                  , input no
                  , output v-kitchen-free-qnty
                  ).
               if  v-store-type = temp_fbr-objects.obj-type
                  and v-store-code = temp_fbr-objects.obj-code
                  then 
               do:
                  assign
                     v-restaurant-free-qnty = 0
                     .
               end.
               else 
               do:
                  run fbrrest-get-free-qnty in this-procedure (
                     input v-store-type
                     , input v-store-code
                     , input buf_doc-fbr-gds.gds-code
                     , input no
                     , output v-restaurant-free-qnty
                     ).
               end.
            end.
            else 
            do:
               assign
                  v-kitchen-free-qnty    = 0
                  v-restaurant-free-qnty = 0
                  .
            end.
            assign
               v-need-qnty = buf_doc-fbr-gds.fact-qnty - v-kitchen-free-qnty - v-restaurant-free-qnty
               .
            if v-need-qnty <= 0
               then 
            do:
               undo create-by-recipe, next create-by-recipe.
            end.
            find first buf_goods no-lock
               where buf_goods.gds-code = buf_doc-fbr-gds.gds-code
               .
            run write-counter in p-log-handle (
               input substitute( "Приготовление блюда: &1 &2 ..."
               , buf_goods.artic
               , buf_goods.gds-name
               )
               ).
            run select-recipe in this-procedure (
               input parparentproc
               , input temp_fbr-objects.obj-type
               , input temp_fbr-objects.obj-code
               , input buf_doc-fbr-gds.gds-code
               , input {&income}                   /* p-trn-type */
               , input v-need-qnty                 /* p-gds-qnty */
               , input yes
               , input yes
               , output v-out-gds-code
               , output v-out-trn-type
               , output v-out-gds-qnty
               , output v-out-recipe-type
               , output v-out-recipe-code
               , output v-recipe-found
               , output v-no-need-good
               ).
            if v-recipe-found = no
               or v-out-gds-code <> buf_doc-fbr-gds.gds-code
               or v-out-trn-type <> {&income}
               then 
            do:
               v-mess = substitute("Не найден рецепт для производства товара&1" +
                  "Код товара: &2"  +
                  "Артикул: &3" +
                  "Наименование: &4"
                  , {&new-line}
                  , buf_doc-fbr-gds.gds-code
                  , buf_goods.artic
                  , buf_goods.gds-name).
               run write-log in p-log-handle (
                  input 5
                  , input v-mess
                  ).
               run writelog in this-procedure (
                  input log-file-name
                  , input 0
                  , input v-mess
                  ).
               undo, return error .
            end.
            find first buf_recipe no-lock
               where buf_recipe.recipe-code = v-out-recipe-code
               .
            if v-ban-altr or v-ban-recipes
            then do:
                /*проверка */
               if buf_recipe.recipe-type = {&manufacturing} and v-ban-recipes then
               do:
                  for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_recipe.recipe-code:
                     run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                        , input  {&attr-mark-type}
                        , output v-attr-value
                        , output v-attr-type
                        ) no-error .
                     if v-attr-value <> "" and v-attr-value <> "not-type" then
                     do:
                        v-mess =  "Рецепт производства " + buf_recipe.recipe-code + " " + buf_recipe.recipe-name + " содержит маркированный товар." .
                        run write-log in p-log-handle (
                           input 5
                           , input v-mess
                           ).
                        run writelog in this-procedure (
                           input log-file-name
                           , input 0
                           , input v-mess
                           ).
                        undo create-by-recipe, next create-by-recipe.
                     end.
                  end.
               end.
               if buf_recipe.recipe-type = {&alternative} and v-ban-altr then
               do:
                  for first buf_goods no-lock where buf_goods.gds-code = buf_recipe.gds-code,
                     first ub.gds-grp exclusive-lock where ub.gds-grp.node-code = buf_goods.grp-code:
                     run ggoattr-value (
                        input   ub.gds-grp.node-code
                        ,input   buf_recipe.host-code
                        ,input   buf_recipe.obj-type
                        ,input   buf_recipe.obj-code
                        ,input   {&ggoattr-ban-sales-via-cd}
                        ,output   v-value
                        ,output   v-type
                        ) no-error .
                     if error-status :error then
                     do:
                        undo, return error.
                     end.
                     if v-value <> "yes" and v-value <> "true" then
                     do:
                        run ggoattr-value (
                           input   ub.gds-grp.node-code
                           ,input   0
                           ,input   ""
                           ,input   0
                           ,input   {&ggoattr-ban-sales-via-cd}
                           ,output   v-value
                           ,output   v-type
                           ) no-error .
                        if error-status :error then
                        do:
                           undo, return error.
                        end.
                        if v-value <> "yes" and v-value <> "true" then
                        do:
                           v-mess =  "Рецепт альтернатива " + buf_recipe.recipe-code + " " + buf_recipe.recipe-name + {&new-line} + "входит в группу, у которой не установлен атрибут: " + {&new-line} + "Запрет передачи на кассу." .
                           run write-log in p-log-handle (
                              input 5
                              , input v-mess
                              ).
                           run writelog in this-procedure (
                              input log-file-name
                              , input 0
                              , input v-mess
                              ).
                           undo create-by-recipe, next create-by-recipe.
                        end.
                     end.
                  end.
               end.
               if buf_recipe.recipe-type = {&gathering} and v-ban-recipes then
               do:
                  for each ub.recipe-gds no-lock where ub.recipe-gds.recipe-code = buf_recipe.recipe-code:
                     run gds-attr-value in this-procedure  ( input  ub.recipe-gds.gds-code
                        , input  {&attr-mark-type}
                        , output v-attr-value
                        , output v-attr-type
                        ) no-error .
                     if v-attr-value <> "" and v-attr-value <> "not-type" then
                     do:
                        run gds-attr-value in this-procedure  ( input  buf_recipe.gds-code
                           , input  {&attr-mark-type}
                           , output v-attr-value-rec
                           , output v-attr-type
                           ) no-error .
                        if v-attr-value-rec = "" or v-attr-value-rec = "not-type" then
                        do:
                           v-mess =   "Рецепт комплектации " + buf_recipe.recipe-code + " " + buf_recipe.recipe-name + " должен быть маркированным." .
                           run write-log in p-log-handle (
                              input 5
                              , input v-mess
                              ).
                           run writelog in this-procedure (
                              input log-file-name
                              , input 0
                              , input v-mess
                              ).
                           undo create-by-recipe, next create-by-recipe.
                        end.
                        else leave.
                     end.
                  end.
               end.
            end.
            run create-initial-temp-goods in this-procedure (
               input v-fbr-doc-code
               , input buf_goods.artic
               , input buf_goods.prod-type
               , input buf_goods.prod-code
               , input {&income}
               , input v-out-recipe-type
               , input v-out-recipe-code
               , input v-need-qnty
               , output v-same-good
               , output v-same-good-old-qnty
               ).
            run calc-not-calculated-goods in this-procedure (
               input parparentproc
               , input p-fbrhist-handle
               , input v-fbr-doc-code
               , input v-same-good
               , input v-same-good-old-qnty
               , input no                          /* p-always-select-recipe */
               , input yes                         /* p-add-childs           */
               , input temp_fbr-objects.obj-type   /* p-price-sale-obj-type  */
               , input temp_fbr-objects.obj-code   /* p-price-sale-obj-code  */
               , input yes                         /* p-autofbr              */
               , input yes
               ).
            if valid-handle ( p-fbrhist-handle )
               then 
            do:
               run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                  , input temp_fbr-objects.obj-type
                  , input temp_fbr-objects.obj-code
                  , input {&fbrhist-type-create-line}
                  , input 2
                  , input "str/fbrsale.p"
                  , input substitute( "parameters: &1", p-parameters )
                  , input v-doc-code
                  , input {&res-autofbr}
                  , input {&g___new}
                  , input no
                  , input v-out-recipe-code
                  , input v-out-recipe-type
                  , input buf_goods.gds-code
                  , input {&income}
                  , input v-need-qnty
                  , input substitute( "Создана строка документа производства для товара '&1 &2' с количеством &3"
                  , buf_goods.artic
                  , buf_goods.gds-name
                  , v-need-qnty
                  )
                  , input no
                  ).
            end.        /* if valid-handle ( p-fbrhist-handle ) */
         end.        /* for each buf_doc-fbr-gds no-lock */
         run check-fbr-doc in this-procedure (
            input v-fbr-doc-code
            , output v-fbr-doc-is-not-empty
            ).
         run write-counter in p-log-handle (
            input ""
            ).
         if v-fbr-doc-is-not-empty = yes
            then 
         do:        /* В документе производства есть строки */
            run write-log in p-log-handle (
               input 5
               , input substitute( "Создан документ производства '&1'. Идет резервирование товаров..."
               , v-fbr-doc-code
               )
               ).
            find first buf_fbr-doc no-lock
               where buf_fbr-doc.doc-code = v-fbr-doc-code
               .
            run str/fbr-rsrv.p (
               input parparentproc
               , input p-fbrhist-handle
               , input recid( buf_fbr-doc )
               , input yes /* p-silent */
               , input yes /* autofbr */
               , input yes
               , input v-store-rest
               , output v-reserved
               ) no-error.            
            if error-status :error
               or v-reserved = no
               then 
            do:
               /* печатаем */
               define variable v-user-action as character no-undo .
               define variable v-printed     as logical   no-undo .
               /*if search({&fbr-rsrv-log-file-name}) <> ? then do:
                 run gbl/prnfilen.w (
                       input "Список не зарезервированных товаров при автопроизводстве":U
                     , input 8
                     , input search({&fbr-rsrv-log-file-name})
                     , input 7
                     , output v-user-action
                     , output v-printed
                 ).
                 os-delete value({&fbr-rsrv-log-file-name}) .
               end.*/
               if search ({&fbr-rsrv-tt-log-file-name}) <> ? then 
               do:
                  input stream stm from value({&fbr-rsrv-tt-log-file-name}).
                  repeat .
                     create tt-rsrv-err.
                     import stream stm tt-rsrv-err no-error.
                     if error-status:error 
                        then delete tt-rsrv-err.
                  END.
                  output stream stm to value (v-fbr-tt-log-file-name).
                  for each tt-rsrv-err no-lock break by tt-rsrv-err.artic:  
                     if last-of (tt-rsrv-err.artic) and tt-rsrv-err.artic <> "" then 
                     do:
                        put stream stm unformatted substitute("Ошибка при резервировании товара артикул &1 &5: требуемое кол-во &2 зарезервировано &3&4"
                           , tt-rsrv-err.artic
                           , tt-rsrv-err.req-qnty
                           , tt-rsrv-err.rsrv-qnty
                           , {&new-line}
                           , tt-rsrv-err.gds-name
                           ).
                     end.
                  end.
                  output stream stm close.
                  if search ({&fbr-rsrv-tt-log-file-name}) <> ? then 
                  do:
                     run gbl/prnfilen.w (
                        input "Список не зарезервированных товаров при автопроизводстве":U
                        , input 8
                        , input search({&fbr-rsrv-tt-log-file-name})
                        , input 7
                        , output v-user-action
                        , output v-printed
                        ).
                  end.
               end.
               v-mess =  substitute("Не удалось зарезервировать товары для производства.&1" +
                  "Объект (кухня): &2&3&1&4&1&5"
                  , {&new-line}
                  ,temp_fbr-objects.obj-type
                  ,temp_fbr-objects.obj-code
                  , error-status:get-message(1)
                  , return-value ).
               run write-log in p-log-handle (
                  input 5
                  , input v-mess
                  ).
               run writelog in this-procedure (
                  input log-file-name
                  , input 0
                  , input v-mess
                  ).
               if valid-handle ( p-fbrhist-handle )
                  then 
               do:
                  run fbrhist-set-upper-from-saved-code in p-fbrhist-handle.
                  run fbrhist-write in p-fbrhist-handle (
                     input v-cntxt-userid
                     , input temp_fbr-objects.obj-type
                     , input temp_fbr-objects.obj-code
                     , input {&fbrhist-type-close-fact}
                     , input 2
                     , input "str/fbrsale.p"
                     , input substitute( "parameters: &1", p-parameters )
                     , input v-doc-code
                     , input {&res-autofbr}
                     , input {&g___new}
                     , input no
                     , input ""
                     , input ""
                     , input 0
                     , input ""
                     , input 0
                     , input substitute( "Не удалось зарезервировать товары для производства на объекте (кухня) '&1 &2'. &3. &4."
                     , temp_fbr-objects.obj-type
                     , temp_fbr-objects.obj-code
                     , return-value
                     , trim(error-status :get-message(1))
                     )
                     , input yes
                     ).
               end.        /* if valid-handle ( p-fbrhist-handle ) */
               undo, return error .
            end.
            run write-log in p-log-handle (
               input 5
               , input substitute( "Зарезервированы товары по документу производства '&1'."
               , v-fbr-doc-code
               )
               ).
            run write-log in p-log-handle (
               input 0
               , input "                         Идет закрытие документа производства..."
               ).
            if valid-handle ( p-fbrhist-handle )
               then 
            do:
               run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                  , input temp_fbr-objects.obj-type
                  , input temp_fbr-objects.obj-code
                  , input {&fbrhist-type-close-fact}
                  , input 2
                  , input "str/fbrsale.p"
                  , input substitute( "parameters: &1", p-parameters )
                  , input v-doc-code
                  , input {&res-autofbr}
                  , input {&g___new}
                  , input no
                  , input ""
                  , input ""
                  , input 0
                  , input ""
                  , input 0
                  , input substitute( "Зарезервированы товары для производства на объекте (кухня) '&1 &2'."
                  , temp_fbr-objects.obj-type
                  , temp_fbr-objects.obj-code
                  )
                  , input no
                  ).
            end.        /* if valid-handle ( p-fbrhist-handle ) */
            run str/fbr-fact.p ( input parparentproc
               , input recid( buf_fbr-doc )
               , input no                   /* p-silent */
               ) no-error.
            if error-status :error
               then 
            do:
               v-mess = substitute("Не удалось закрыть документ производства.&1" +
                  "Объект (кухня): &2&3&1&4&1&5"
                  ,{&new-line}
                  ,temp_fbr-objects.obj-type
                  ,temp_fbr-objects.obj-code
                  , error-status:get-message(1)
                  , return-value ).
               run write-log in p-log-handle (
                  input 5
                  , input v-mess
                  ).
               run writelog in this-procedure (
                  input log-file-name
                  , input 0
                  , input v-mess
                  ).
               if valid-handle ( p-fbrhist-handle )
                  then 
               do:
                  run fbrhist-write in p-fbrhist-handle (
                     input v-cntxt-userid
                     , input temp_fbr-objects.obj-type
                     , input temp_fbr-objects.obj-code
                     , input {&fbrhist-type-close-fact}
                     , input 2
                     , input "str/fbrsale.p"
                     , input substitute( "parameters: &1", p-parameters )
                     , input v-doc-code
                     , input {&res-autofbr}
                     , input {&g___new}
                     , input no
                     , input ""
                     , input ""
                     , input 0
                     , input ""
                     , input 0
                     , input substitute( "Не удалось закрыть производство '&5' на объекте (кухня) '&1 &2'. &3. &4."
                     , temp_fbr-objects.obj-type
                     , temp_fbr-objects.obj-code
                     , return-value
                     , trim(error-status :get-message(1))
                     , v-fbr-doc-code
                     )
                     , input yes
                     ).
               end.        /* if valid-handle ( p-fbrhist-handle ) */
               undo, return error .
            end.
            run write-log in p-log-handle (
               input 5
               , input substitute( "Документ производства '&1' закрыт."
               , v-fbr-doc-code
               )
               ).
            if valid-handle ( p-fbrhist-handle )
               then 
            do:
               run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                  , input temp_fbr-objects.obj-type
                  , input temp_fbr-objects.obj-code
                  , input {&fbrhist-type-close-fact}
                  , input 2
                  , input "str/fbrsale.p"
                  , input substitute( "parameters: &1", p-parameters )
                  , input v-doc-code
                  , input {&res-autofbr}
                  , input {&g___new}
                  , input no
                  , input ""
                  , input ""
                  , input 0
                  , input ""
                  , input 0
                  , input substitute( "Закрыт документ производства '&3' на объекте (кухня) '&1 &2'."
                  , temp_fbr-objects.obj-type
                  , temp_fbr-objects.obj-code
                  , v-fbr-doc-code
                  )
                  , input no
                  ).
            end.        /* if valid-handle ( p-fbrhist-handle ) */
         end.        /* if v-fbr-doc-is-not-empty = yes  */
         else 
         do:
            run write-log in p-log-handle (
               input 5
               , input substitute( "В документе производства '&1' нет строк. Документ удален."
               , v-fbr-doc-code
               )
               ).
            if valid-handle ( p-fbrhist-handle )
               then 
            do:
               run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                  , input temp_fbr-objects.obj-type
                  , input temp_fbr-objects.obj-code
                  , input {&fbrhist-type-delete-doc}
                  , input 2
                  , input "str/fbrsale.p"
                  , input substitute( "parameters: &1", p-parameters )
                  , input v-doc-code
                  , input {&res-autofbr}
                  , input {&g___new}
                  , input no
                  , input ""
                  , input ""
                  , input 0
                  , input ""
                  , input 0
                  , input substitute( "Удален документ производства '&3' на объекте (кухня) '&1 &2'. Не требуется производства для закрытия продажи."
                  , temp_fbr-objects.obj-type
                  , temp_fbr-objects.obj-code
                  , v-fbr-doc-code
                  )
                  , input no
                  ).
            end.        /* if valid-handle ( p-fbrhist-handle ) */
         end.
         if temp_fbr-objects.obj-type <> v-store-type
            or temp_fbr-objects.obj-code <> v-store-code
            then 
         do:
            run write-log in p-log-handle (
               input 5
               , input "Создаются документы внутреннего перемещения блюд"
               ).
            run write-log in p-log-handle (
               input 0
               , input substitute( "                         с объекта кухни ( &1 &2 ) на объект ресторан  ( &3 &4 )..."
               , temp_fbr-objects.obj-type
               , temp_fbr-objects.obj-code
               , v-store-type
               , v-store-code
               )
               ).
            run str/fbr2sale.p (
               input parparentproc
               , input p-fbrhist-handle
               , input temp_fbr-objects.obj-type
               , input temp_fbr-objects.obj-code
               , input v-store-type
               , input v-store-code
               , input ( if available buf_fbr-doc then replace( buf_fbr-doc.doc-code, "-", "=" ) else "" )
               , input v-doc-code
               , input v-kitchen-rest
               ) no-error.
            if error-status :error
               then 
            do:
               if error-status :get-message(1) <> ""
                  or return-value <> "user-interrupt":U
                  then 
               do:
                  v-mess = substitute("Не удалось перевести товары для закрытия продажи.&1" +
                     "Объект (кухня): &2&3&1" +
                     "Объект (ресторан):&4&5&1&6&1&7"
                     , {&new-line}
                     , temp_fbr-objects.obj-type
                     , temp_fbr-objects.obj-code
                     , v-store-type
                     , v-store-code
                     , error-status:get-message(1)
                     , return-value ).

                  run write-log in p-log-handle (
                     input 5
                     , input v-mess
                     ).
                  run writelog in this-procedure (
                     input log-file-name
                     , input 0
                     , input v-mess
                     ).
               end.
               if valid-handle ( p-fbrhist-handle )
                  then 
               do:
                  run fbrhist-write in p-fbrhist-handle (
                     input v-cntxt-userid
                     , input temp_fbr-objects.obj-type
                     , input temp_fbr-objects.obj-code
                     , input {&fbrhist-type-close-fact}
                     , input 2
                     , input "str/fbrsale.p"
                     , input substitute( "parameters: &1", p-parameters )
                     , input v-doc-code
                     , input {&res-autofbr}
                     , input {&g___new}
                     , input no
                     , input ""
                     , input ""
                     , input 0
                     , input ""
                     , input 0
                     , input substitute( "Не удалось перевести товары для закрытия продажи с объекта (кухня) '&1 &2' на объект (ресторан) '&3 &4'. &5. &6."
                     , temp_fbr-objects.obj-type
                     , temp_fbr-objects.obj-code
                     , v-store-type
                     , v-store-code
                     , return-value
                     , trim(error-status :get-message(1))
                     )
                     , input yes
                     ).
               end.        /* if valid-handle ( p-fbrhist-handle ) */
               undo, return error return-value.
            end.
            run write-log in p-log-handle (
               input 5
               , input             "Созданы документы внутреннего перемещения блюд"
               ).
            run write-log in p-log-handle (
               input 0
               , input substitute( "                         с объекта кухни ( &1 &2 ) на объект ресторан  ( &3 &4 )."
               , temp_fbr-objects.obj-type
               , temp_fbr-objects.obj-code
               , v-store-type
               , v-store-code
               )
               ).
            if valid-handle ( p-fbrhist-handle )
               then 
            do:
               run fbrhist-write in p-fbrhist-handle (
                  input v-cntxt-userid
                  , input temp_fbr-objects.obj-type
                  , input temp_fbr-objects.obj-code
                  , input {&fbrhist-type-close-fact}
                  , input 2
                  , input "str/fbrsale.p"
                  , input substitute( "parameters: &1", p-parameters )
                  , input v-doc-code
                  , input {&res-autofbr}
                  , input {&g___new}
                  , input no
                  , input ""
                  , input ""
                  , input 0
                  , input ""
                  , input 0
                  , input substitute( "Созданы документы внутреннего перемещения блюд с объекта (кухня) '&1 &2' на объект (ресторан) '&3 &4'."
                  , temp_fbr-objects.obj-type
                  , temp_fbr-objects.obj-code
                  , v-store-type
                  , v-store-code
                  )
                  , input no
                  ).
            end.        /* if valid-handle ( p-fbrhist-handle ) */
         end.        /* if temp_fbr-objects.obj-type <> v-store-type */
      end.        /* for each temp_fbr-objects */
      run write-log in p-log-handle (
         input 1
         , input substitute( "Произведены товары для закрытия продажи '&1' на объекте &2 &3."
         , v-doc-code
         , v-store-type
         , v-store-code
         )
         ).
   end.        /* do transaction */

   if valid-handle ( p-fbrhist-handle )
      then 
   do:
      run fbrhist-write in p-fbrhist-handle (
         input v-cntxt-userid
         , input v-store-type
         , input v-store-code
         , input {&fbrhist-type-end}
         , input 1
         , input "str/fbrsale.p"
         , input substitute( "parameters: &1", p-parameters )
         , input v-doc-code
         , input {&res-autofbr}
         , input ""
         , input no
         , input ""
         , input ""
         , input 0
         , input ""
         , input 0
         , input substitute( "Произведены товары для закрытия продажи '&3' на объекте &1 &2."
         , v-store-type
         , v-store-code
         , v-doc-code
         )
         , input no
         ).
   end.        /* if valid-handle ( p-fbrhist-handle ) */
   { gbl/stopwork.i }
end.

/*==========================================================================*/
procedure check-fbr-doc :
   define input parameter p-doc-code   as character    no-undo.
   define output parameter p-ok        as logical      no-undo.

   define buffer buf_fbr-doc  for fbr-doc.
   define buffer buf_fbr-line for fbr-line.
   do
      for buf_fbr-doc
      , buf_fbr-line
      on error undo, return error
      :
      find first buf_fbr-line no-lock
         where buf_fbr-line.doc-code = p-doc-code
         no-error.
      if not available buf_fbr-line
         then 
      do:
         find first buf_fbr-doc exclusive-lock
            where buf_fbr-doc.doc-code = p-doc-code
            .
         delete buf_fbr-doc.
         assign
            p-ok = no
            .
      end.
      else 
      do:
         assign
            p-ok = yes
            .
      end.
   end.
end procedure. /* check-fbr-doc */