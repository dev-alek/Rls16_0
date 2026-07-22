block-level on error undo, throw.
/*

$Revision: d33fe82486ed, 142, rls $
$Author: ASMorozov $
$Date: Mon Feb 16 20:48:29 2015 +0400 $
$Workfile: fbr-rsrv.p $
$Archive: str/fbr-rsrv.p $

Расчет учетных цен и резервирование (дорезервирование) по всему документу производства

Автор: Белоусов Илья Александрович
Дата создания: 03/23/06
Author: Ilia Belousov
Creation date: 03/23/06

Input:
    parparentproc    as widget-handle   - mainmenu handle
    p-fbrhist-handle as widget-handle   - handle головной процедуры истории производства
    p-fbr-doc-recid  as recid           - recid документа производства
    p-autofbr        as logical         - автоматическое производство
    p-have-store     as logical         - остатки товаров смотреть на складе кухни
    p-kitchen-rest     as logical         - учитывать остатки товара на кухне ( остаток = остаток на кухне + остаток на складе)

Output:
    p-reserved      as logical          - товары зарезервированы

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbrhist-handle as widget-handle    no-undo.
define input parameter p-fbr-doc-recid  as recid            no-undo.
define input parameter p-silent         as logical          no-undo .
define input parameter p-autofbr        as logical          no-undo.
define input parameter p-have-store     as logical          no-undo.
define input parameter p-kitchen-rest   as logical          no-undo.
define output parameter p-reserved      as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: d33fe82486ed, 142, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:48:29 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-rsrv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr-rsrv.p $":U .
define variable vss-description as character no-undo init "Расчет учетных цен и резервирование (дорезервирование) по всему документу производства".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ trg/partslib.i }
{ str/fbrrest.i  }
{ str/fbrlib.i   }
{ rep/fbrrep.i   }
{ gbl/cur-time.i }
{ str/writelog.i def "'fbr.log'" no-create }

    define variable v-all-reserved  as logical init yes      no-undo.

    define variable v-write-off-sum-price-rubl      as decimal      no-undo.
    define variable v-write-off-sum-price-base      as decimal      no-undo.
    define variable v-write-off-sum-vat-price-rubl  as decimal      no-undo.
    define variable v-write-off-sum-vat-price-base  as decimal      no-undo.
    define variable v-conf-par-value                as character    no-undo.
    define variable v-conf-par-type                 as character    no-undo.
    define variable v-host-code                     as integer      no-undo.
    define variable v-store-obj-type                as character    no-undo.
    define variable v-store-obj-code                as integer      no-undo.
    define variable v-store-free-qnty               as decimal      no-undo.
    define variable v-kitchen-free-qnty             as decimal      no-undo.
    define variable v-continue                      as logical      no-undo.
    define variable v-ok                            as logical      no-undo.
    define variable v-del-zero-lines                as logical      no-undo.
    define variable v-not-reserved                  as logical      no-undo.

    define buffer buf_out_fbr-line  for ub.fbr-line.         /* строка производства {&write-off} */
    define buffer buf_in_fbr-line   for ub.fbr-line.             /* {&row} производства {&income} */
    define buffer buf_fbr-doc       for ub.fbr-doc.
    define buffer buf_goods         for ub.goods.

do
for buf_out_fbr-line
  , buf_in_fbr-line
  , buf_fbr-doc
  , buf_goods
on error undo, return error
:
    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid.

    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input "=====*** fbr-rsrv.p ***================================================"
    ).

    { gbl/hostcode.i
        buf_fbr-doc.obj-type
        buf_fbr-doc.obj-code
        v-host-code
    }
/* Если понадобится раскручивать автоматически производство при закрытии документа производства,
    а не только продажи */
/*    define variable v-autofbr                       as logical      no-undo.*/
/*    { gbl/conf-rd.i*/
/*        "'autosale'"*/
/*        v-host-code*/
/*        buf_fbr-doc.obj-type*/
/*        buf_fbr-doc.obj-code*/
/*        "''"*/
/*        "''"*/
/*        "''"*/
/*        no*/
/*        v-conf-par-value*/
/*        v-conf-par-type*/
/*        no-error*/
/*    }*/
/*    if error-status :error*/
/*    then do:*/
/*        assign*/
/*            v-autofbr = no*/
/*        .*/
/*    end.*/
/*    else do:*/
/*        assign*/
/*            v-autofbr = ( lookup( "autofbr", v-conf-par-value ) <> 0 )*/
/*        .*/
/*    end.*/
    /* При автоматической раскрутке из ресторана создается и закрывается документ внутреннего перемещения */
    /* со склада на кухню с товарами, необходимыми для производства. */
    if p-have-store = yes
    then do:
        run writelog in this-procedure (
              input log-file-name
            , input 0
            , input "=====*** Перемещение товаров со склада ***================================================"
        ).
        run fbrrest-get-catering-object in this-procedure (
              input buf_fbr-doc.obj-code
            , output v-store-obj-type
            , output v-store-obj-code
        ).
        run fbrrep-fill-qnty-and-prices in this-procedure (
            input buf_fbr-doc.doc-code
        ).
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input substitute( "Товары, которые надо переместить на кухню ( &1 &2 ) со склада ( &3 &4 )"
                                , buf_fbr-doc.obj-type
                                , buf_fbr-doc.obj-code
                                , v-store-obj-type
                                , v-store-obj-code
                                )
        ).
        run writelog in this-procedure (
              input log-file-name
            , input 2
            , input substitute( "     Артикул    |    Количество   | Не хватает на складе |     Наименование " )
        ).
        for each temp_fbrrep-goods
        on error undo, return error
        :
            if p-kitchen-rest = yes
            then do:
                run fbrrest-get-free-qnty in this-procedure (
                      input buf_fbr-doc.obj-type
                    , input buf_fbr-doc.obj-code
                    , input temp_fbrrep-goods.gds-code
                    , input p-autofbr
                    , output v-kitchen-free-qnty
                ).
            end.
            else do:
                assign
                    v-kitchen-free-qnty = 0
                .
            end.
            if temp_fbrrep-goods.is-not-office = yes
            and temp_fbrrep-goods.is-waste     = no
            and temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty > 0
            then do:
                run fbrrest-get-free-qnty in this-procedure (
                      input v-store-obj-type
                    , input v-store-obj-code
                    , input temp_fbrrep-goods.gds-code
                    , input yes
                    , output v-store-free-qnty
                ).
                run writelog in this-procedure (
                      input log-file-name
                    , input 2
                    , input substitute( "&1 &2 &3         &4 "
                                            , string( temp_fbrrep-goods.artic, "X(17)" )
                                            , string( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty, ">>>,>>>,>>>.999" )
                                            , string( ( if v-store-free-qnty - ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty ) < 0
                                                        then ( temp_fbrrep-goods.write-off-qnty - temp_fbrrep-goods.income-qnty - v-kitchen-free-qnty ) - v-store-free-qnty
                                                        else 0 ), ">>>,>>>,>>>.999" )
                                            , string( temp_fbrrep-goods.gds-name, "X(60)" )
                                      )

                ).
            end.
        end.
        run writelog in this-procedure (
              input log-file-name
            , input 5
            , input substitute( "Товары, которые надо переместить на кухню ( &1 &2 ) со склада ( &3 &4 )"
                                , buf_fbr-doc.obj-type
                                , buf_fbr-doc.obj-code
                                , v-store-obj-type
                                , v-store-obj-code
                                )
        ).
        run str/fbrstore.p (
              input parparentproc
            , input p-fbrhist-handle
            , input buf_fbr-doc.doc-code
            , input p-kitchen-rest
        ) no-error.
        if error-status :error
        then do:
            run writelog in this-procedure (
                  input log-file-name
                , input 0
                , input "=====*** Перемещение товаров со склада: Не удалось зарезервировать товар. ***========="
            ).

            if search ( "fbrgoods.log" ) <> ?
            then do:
                define variable v-user-action as character no-undo.
                define variable v-printed     as logical   no-undo.
                run gbl/prnfilen.w
                  (input  "Перемещение товаров со склада: Не удалось зарезервировать товар"
                  ,input  0
                  ,input  "fbrgoods.log"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                ).
            end.
            undo, return error substitute("&1 &2 &3&4Не удалось зарезервировать товар по документу пр-ва &5 при перемещении со склада.&4&6&4&7"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          , buf_fbr-doc.doc-code
                                          , error-status:get-message(1)
                                          , return-value ) .
        end.
        run writelog in this-procedure (
              input log-file-name
            , input 0
            , input "=====*** Перемещение товаров со склада завершено. ***============================="
        ).
        for each temp_fbrrep-goods
        on error undo, return error
        :
            run set-price-sale in this-procedure (
                  input buf_fbr-doc.doc-code
                , input temp_fbrrep-goods.artic
                , input temp_fbrrep-goods.prod-type
                , input temp_fbrrep-goods.prod-code
                , input temp_fbrrep-goods.gds-code
            ) no-error.
            if error-status :error
            then do:
              undo, return error substitute("&1 &2 &3&4Ошибка при определении в документе пр-ва &5&4" +
                                            "продажной цены ингредиента, перемещенного со склада на кухню ресторана.&4Товар &6 &7&4&8&4&9"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,buf_fbr-doc.doc-code
                                            ,temp_fbrrep-goods.artic
                                            ,temp_fbrrep-goods.gds-name
                                            ,error-status:get-message(1)
                                            ,return-value) .
            end.
        end.
    end.        /* if p-have-store = yes */
    assign
        p-reserved = no
    .
    if buf_fbr-doc.is-free = no
    then do:
        run fbrlib-put-in-order-recipe in this-procedure (
            input buf_fbr-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
           undo, return error substitute("&1 &2 &3&4Не удалось вычислить последовательность рецептов в документе производства &5&4&6&4&7"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        , buf_fbr-doc.doc-code
                                        , error-status:get-message(1)
                                        , return-value ) .
        end.
        if p-autofbr = yes
        then do:
            assign
                v-del-zero-lines = yes
            .
        end.
        reserv-fbr-line:
        for each temp_recipe-order no-lock
        on error undo, return error
        :       /* считаем данный рецепт. Если невозможно, rsrv-qnty останется 0 */
            run check-recipe in this-procedure (
                  input buf_fbr-doc.doc-code
                , input temp_recipe-order.recipe-code
                , input v-del-zero-lines
                , output v-del-zero-lines
                , output v-ok
            ) no-error.
            if error-status :error
            then do:
              undo, return error substitute("&1 &2 &3&4Ошибка проверки рецепта документа &5 Номер рецепта &6.&4&7&4&8"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            , buf_fbr-doc.doc-code
                                            , temp_recipe-order.recipe-code
                                            , error-status:get-message(1)
                                            , return-value ) .

            end.
            if v-ok = no
            then do:
                run writelog in this-procedure (
                      input log-file-name
                    , input 0
                    , input "=====*** fbr-rsrv.p ***========= ошибка при проверке рецепта  ========"
                ).
                assign
                    v-all-reserved  = no
                    v-continue      = no
                .
                leave reserv-fbr-line.
            end.
            
            run str/fbr-rcp.p (
                  input parparentproc
                , input p-fbrhist-handle
                , input p-fbr-doc-recid
                , input p-silent
                , input temp_recipe-order.recipe-code
                , input p-autofbr
                , input p-have-store
            ) no-error.
            if error-status:error
            then do:
                if return-value = 'not-reserved' then do:
                  v-not-reserved = true.
                  next reserv-fbr-line.
                end.
                assign
                    v-continue = no
                .
                run writelog in this-procedure (
                      input log-file-name
                    , input 0
                    , input "=====*** fbr-rsrv.p ***========= ошибка fbr-rcp.p  ========"
                ).
                if p-autofbr = no
                then do:
                    if error-status :get-message(1) <> ""
                    or return-value <> "user-interrupt":U
                    then do:
                    if p-silent then do:
                      undo, return error substitute("&1 &2 &3&4Ошибка резервирования по рецепту документа &5.&4Номер рецепта &6.&4&7&4&8"
                                                      ,vss-workfile
                                                      ,vss-revision
                                                      ,vss-description
                                                      ,{&new-line}
                                                      ,buf_fbr-doc.doc-code
                                                      ,temp_recipe-order.recipe-code
                                                      ,error-status:get-message(1)
                                                      ,return-value ) .
                     end.
                     else do:
                        message
                                vss-workfile vss-revision vss-description
                            skip "Ошибка резервирования по рецепту."
                            skip "Рецепт: " temp_recipe-order.recipe-code
                            skip return-value
                            skip trim(error-status :get-message(1))
                                trim(error-status :get-message(2))
                                trim(error-status :get-message(3))
                            skip (2)
                            skip "Продолжить расчет рецептов?"
                        view-as alert-box question
                        buttons yes-no
                        title "Расчет рецептов по документу"
                        update v-continue
                        .
                    end.
                    end. /*if error-status :get-message(1) <> ""*/
                    else do:
                      if p-silent then do:
                        undo, return error substitute("&1 &2 &3&4Товар(ы) не был(и) зарезервирован(ы). Документ производства &5.&4Номер рецепта &6.&4&7&4&8"
                                                        ,vss-workfile
                                                        ,vss-revision
                                                        ,vss-description
                                                        ,{&new-line}
                                                        ,buf_fbr-doc.doc-code
                                                        ,temp_recipe-order.recipe-code
                                                        ,error-status:get-message(1)
                                                        ,return-value ) .
                      end.
                    else do:
                        message
                            skip "Товар не был зарезервирован."
                            skip "Рецепт: " temp_recipe-order.recipe-code
                            skip (1)
                            skip "Продолжить расчет рецептов?"
                        view-as alert-box question
                        buttons yes-no
                        title "Расчет рецептов по документу"
                        update v-continue
                        .
                    end.
                    end.
                    assign
                        v-all-reserved = no
                    .
                    if v-continue = yes
                    then do:
                        run writelog in this-procedure (
                            input log-file-name
                            , input 0
                            , input "Выбрано продолжение расчёта рецептов."
                        ).
                        next reserv-fbr-line.
                    end.
                    else do:
                        leave reserv-fbr-line.
                    end.
                end.        /* if p-autofbr = no */
                else do:
                    if error-status :get-message(1) <> ""
                    or return-value <> "user-interrupt":U
                    then do:
                    if p-silent then do:
                      undo, return error substitute("&1 &2 &3&4Ошибка резервирования по рецепту документа &5.&4Номер рецепта &6.&4&7&4&8"
                                                  ,vss-workfile
                                                  ,vss-revision
                                                  ,vss-description
                                                  ,{&new-line}
                                                  ,buf_fbr-doc.doc-code
                                                  ,temp_recipe-order.recipe-code
                                                  ,error-status:get-message(1)
                                                  ,return-value ) .
                    end.
                    else do:
                        message
                                vss-workfile vss-revision vss-description
                            skip "Ошибка резервирования по рецепту."
                            skip "Рецепт: " temp_recipe-order.recipe-code
                            skip return-value
                            skip trim(error-status :get-message(1))
                                trim(error-status :get-message(2))
                                trim(error-status :get-message(3))
                        view-as alert-box error
                        title "Расчет рецептов по документу"
                        .
                    end.
                  end.
                  
                  if return-value <> 'not-reserved' then
                    undo, return error return-value .
                end.
            end.
            else do:        /* если зарезервирован хотя бы один рецепт */
                run writelog in this-procedure (
                      input log-file-name
                    , input 0
                    , input "=====*** fbr-rsrv.p ***=========fbr-rcp.p отработала без ошибок ========"
                ).
                assign
                    p-reserved = yes
                .
            end.
        end.        /* for each temp_recipe-order */
        
        if v-not-reserved then return error 'not-reserved'.
        
        if p-reserved = no
        then do:
          if p-silent then do:

          end.
          else do:
            message
                "Ни по одному рецепту документа резервирование не было успешным. "
                + {&new-line} + "Документ не может быть переведен в статус РАЗРЕШЕН."
            view-as alert-box.
        end.
        end.
    end.        /* if buf_fbr-doc.is-free = no */
    else do:
        assign
            v-all-reserved = yes
        .
        transaction-rsrv-free:
        do transaction
        on error undo, return error
        :
            run delete-zero-lines in this-procedure (
                  input buf_fbr-doc.doc-code
                , output v-continue
            ) no-error.
            if error-status :error
            then do:
              undo, return error substitute("&1 &2 &3&4Ошибка поиска и удаления нулевых строк в свободном документе производства &5.&4&6&4&7"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,{&new-line}
                                            ,buf_fbr-doc.doc-code
                                            ,error-status:get-message(1)
                                            ,return-value ) .
            end.
            if v-continue = no
            then do:
                assign
                    p-reserved      = no
                    v-all-reserved  = no
                .
                undo transaction-rsrv-free, leave transaction-rsrv-free.
            end.
            rsrv-free:
            for each buf_out_fbr-line exclusive-lock
            where buf_out_fbr-line.doc-code = buf_fbr-doc.doc-code
                and buf_out_fbr-line.trn-type = {&write-off}
            on error undo, return error
            :
                find first buf_goods no-lock
                     where buf_goods.artic     = buf_out_fbr-line.artic
                       and buf_goods.prod-type = buf_out_fbr-line.prod-type
                       and buf_goods.prod-code = buf_out_fbr-line.prod-code
                .
                run str/fbr-gds.p (
                      input parparentproc
                    , input p-fbrhist-handle
                    , input p-fbr-doc-recid
                    , input p-silent
                    , input recid( buf_goods )
                    , input p-autofbr
                    , input p-have-store
                ) no-error.
                if error-status :error
                then do:
                    assign
                        v-all-reserved = no
                    .
                  if p-silent then do:
                    undo, return error substitute("Не удалось зарезервировать товар &1 по док-ту пр-ва &2&3&4&3&5"
                                                  , buf_goods.gds-code
                                                  , buf_fbr-doc.doc-code
                                                  , {&new-line}
                                                  , error-status:get-message(1)
                                                  , return-value ).
                  end.
                  else do:
                    next rsrv-free.
                end.
                end.
                else do:
                    if buf_out_fbr-line.rsrv-qnty = buf_out_fbr-line.fact-qnty
                    then do:        /* все ли зарезервировано */
                        assign
                            p-reserved = yes
                            v-write-off-sum-price-rubl     = v-write-off-sum-price-rubl     + buf_out_fbr-line.price-rubl * buf_out_fbr-line.fact-qnty
                            v-write-off-sum-price-base     = v-write-off-sum-price-base     + buf_out_fbr-line.price-base * buf_out_fbr-line.fact-qnty
                            v-write-off-sum-vat-price-rubl = v-write-off-sum-vat-price-rubl + buf_out_fbr-line.price-sum-vat-rubl
                            v-write-off-sum-vat-price-base = v-write-off-sum-vat-price-base + buf_out_fbr-line.price-sum-vat-base
                        .
                    end.
                    else do:
                        assign
                            v-all-reserved = no
                        .
                    end.
                end.
            end.        /* for each buf_out_fbr-line exclusive-lock */
        end.        /* do transaction */
        if p-reserved = no
        then do:
          if p-silent then do:
          end.
          else do:
            message
                "Ни по одному товару документа резервирование не было успешным. "
                + {&new-line} + "Документ не может быть переведен в статус РАЗРЕШЕН."
            view-as alert-box.
        end.
        end.
        else do:
            if v-all-reserved = no
            then do:
              if p-silent then do:
                p-reserved = no.
              end.
              else do:
                message
                    "Не по всем товарам расхода резервирование было успешным. "
                    skip "Учетные цены приходуемых товаров должны быть заданы вручную."
                view-as alert-box.
            end.
            end.
            else do:        /* Сумма учетных цен списанных товаров раскидывается по приходам */
                run calc-free-doc-income-costs in this-procedure (
                      input buf_fbr-doc.doc-code
                    , input v-write-off-sum-price-rubl
                    , input v-write-off-sum-price-base
                    , input v-write-off-sum-vat-price-rubl
                    , input v-write-off-sum-vat-price-base
                ).
            end.
        end.
    end.        /* buf_fbr-doc.is-free <> no */
    /* считаем шапку */
    if v-all-reserved = yes
    then do:
        run fbrlib-fill-sum-fbr-doc in this-procedure (
            input p-fbr-doc-recid
            , input {&rsrv-dtl_action_reserv}
        ) no-error .
      if error-status:error then do:
        undo, return error  substitute("Ошибка при расчете шапки документа пр-ва &4&1&2&1&3"
                 , {&new-line}
                 , error-status:get-message(1)
                 , return-value
                 , buf_fbr-doc.doc-code
        ).
    end.
end.
end.

/*==========================================================================
Процедура раскидывает суммы учетных цен списания в свободном документе
по строкам прихода
*/
procedure calc-free-doc-income-costs :
do
on error undo, return error
:
define input parameter p-doc-code                       as character    no-undo.
define input parameter p-write-off-sum-price-rubl       as decimal      no-undo.
define input parameter p-write-off-sum-price-base       as decimal      no-undo.
define input parameter p-write-off-sum-vat-price-rubl   as decimal      no-undo.
define input parameter p-write-off-sum-vat-price-base   as decimal      no-undo.

    define variable v-fbr-line-cost-coeff   as decimal       no-undo.
    define variable v-income-sum-price-sale as decimal       no-undo.

    define buffer buf_fbr-line      for fbr-line.

    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-doc-code
         and buf_fbr-line.trn-type = {&income}
    on error undo, return error
    :
        assign
            v-income-sum-price-sale = v-income-sum-price-sale   + buf_fbr-line.price-sale * buf_fbr-line.fact-qnty
        .
    end.        /* for each buf_fbr-line */
    for each buf_fbr-line exclusive-lock
       where buf_fbr-line.doc-code = p-doc-code
         and buf_fbr-line.trn-type = {&income}
    on error undo, return error
    :
        assign
            buf_fbr-line.rsrv-qnty          = buf_fbr-line.fact-qnty
            v-fbr-line-cost-coeff           = buf_fbr-line.price-sale * buf_fbr-line.fact-qnty / v-income-sum-price-sale
            buf_fbr-line.price-sum-rubl     = p-write-off-sum-price-rubl     * v-fbr-line-cost-coeff
            buf_fbr-line.price-sum-base     = p-write-off-sum-price-base     * v-fbr-line-cost-coeff
            buf_fbr-line.price-sum-vat-rubl = p-write-off-sum-vat-price-rubl * v-fbr-line-cost-coeff
            buf_fbr-line.price-sum-vat-base = p-write-off-sum-vat-price-base * v-fbr-line-cost-coeff
            buf_fbr-line.price-rubl         = buf_fbr-line.price-sum-rubl / buf_fbr-line.fact-qnty
            buf_fbr-line.price-base         = buf_fbr-line.price-sum-base / buf_fbr-line.fact-qnty
        .
    end.        /* for each buf_fbr-line */
end.
end procedure. /* calc-free-doc-income-costs */

/*==========================================================================*/
procedure delete-zero-lines :
define input parameter p-doc-code   as character    no-undo.
define output parameter p-continue  as logical      no-undo.

    define variable v-yesno         as logical      no-undo.
    define variable v-need-del-zero as logical      no-undo.

    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_fbr-doc
  , buf_fbr-line
on error undo, return error
:
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-doc-code
    .
    if buf_fbr-doc.is-free = no
    then do:
       undo, return error substitute("&1 &2 &3&4Документ производства &5 не является свободным.&4Удаление нулевых строк невозможно.&4&6&4&7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,{&new-line}
                                    ,buf_fbr-doc.doc-code
                                    ,error-status:get-message(1)
                                    ,return-value ) .
    end.
    assign
        v-need-del-zero = no
    .
    for each buf_fbr-line no-lock
       where buf_fbr-line.doc-code = p-doc-code
    on error undo, return error
    :
        if buf_fbr-line.fact-qnty = 0
        then do:
          if p-silent then do:
            assign
            v-need-del-zero = yes
            .
          end.
          else do:
            message
                "В свободном документе производства"
                skip "есть строки с нулевым количеством."
                skip (1)
                skip "Вы можете удалить такие строки"
                skip "и продолжить закрытие документа"
                skip "или прервать процесс закрытия."
                skip (1)
                skip "Удалить нулевые строки?"
            view-as alert-box question
            buttons yes-no
            title "Удаление нулевых строк документа"
            update v-yesno.
            if v-yesno = no
            then do:
                assign
                    p-continue = no
                .
                undo, return .
            end.        /* if v-yesno = no */
            else do:
                assign
                    v-need-del-zero = yes
                .
            end.
        end.
    end.
    end.
    if v-need-del-zero = yes
    then do:
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code = p-doc-code
        on error undo, return error
        :
            if buf_fbr-line.fact-qnty = 0
            then do:
                delete buf_fbr-line.
            end.
        end.        /* for each buf_fbr-line */
    end.
    assign
        p-continue = yes
    .
end.
end procedure. /* delete-zero-lines */



PROCEDURE check-recipe :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-doc-code               as character        no-undo.
define input parameter p-recipe-code            as character        no-undo.
define input parameter p-del-zero-lines         as logical          no-undo.
define output parameter p-always-del-zero-lines as logical          no-undo.
define output parameter p-ok                    as logical          no-undo.


    define variable v-yesno    as logical      no-undo.

    define buffer buf_recipe        for recipe.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_recipe
  , buf_fbr-line
on error undo, return error
:
    assign
        p-always-del-zero-lines = p-del-zero-lines
    .
    find first buf_recipe no-lock
         where buf_recipe.recipe-code = p-recipe-code
    no-error.
    if available buf_recipe
    and buf_recipe.recipe-type = {&alternative}
    then do:        /* Удалить все нулевые строки в рецепте альтернативы */
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code     = p-doc-code
             and buf_fbr-line.is-comp      = no
             and buf_fbr-line.recipe-code  = p-recipe-code
             and buf_fbr-line.fact-qnty    = 0
        on error undo, return error
        :
            if p-del-zero-lines = no
            then do:
              if p-silent then do:
                assign
                p-del-zero-lines        = yes
                p-always-del-zero-lines = yes
               .

              end.
              else do:
                message
                         "В рецепте альтернативы"
                    skip "есть строки с количеством 0."
                    skip "Необходимо либо удалить эти строки,"
                    skip "либо продолжить редактирование документа."
                    skip(1)
                    skip "Документ:" buf_fbr-line.doc-code
                    skip "Рецепт:  " buf_fbr-line.recipe-code
                    skip(1)
                    skip "Удалить строки всех рецептов альтернативы"
                    skip "документа с количеством 0?"
                view-as alert-box information
                buttons yes-no
                title "Нулевые строки в рецепте альтернативы"
                update v-yesno .
                if v-yesno = no
                then do:
                    assign
                        p-always-del-zero-lines = no
                        p-ok                    = no
                    .
                    undo, return.
                end.
                else do:
                    assign
                        p-del-zero-lines        = yes
                        p-always-del-zero-lines = yes
                    .
                end.
              end.
            end.        /* if p-del-zero-lines = no */
            delete buf_fbr-line.
        end.        /* for each buf_fbr-line exclusive-lock */
    end.
    assign
        p-ok = yes
    .
end.
END PROCEDURE. /* check-recipe */

/*==========================================================================
    Процедура прописывает в строку ингредиента документа производства
    цену продажи.
*/
procedure set-price-sale :
define input parameter p-fbr-doc-code   as character        no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-prod-type      as character        no-undo.
define input parameter p-prod-code      as integer          no-undo.
define input parameter p-gds-code       as integer          no-undo.

    define variable v-b-code            as integer      no-undo.
    define variable v-void-character    as character    no-undo.
    define variable v-void-decimal      as decimal      no-undo.
    define variable v-price-sale        as decimal      no-undo.

    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_fbr-line      for fbr-line.
do
for buf_fbr-line
on error undo, return error
:
    find first buf_fbr-doc no-lock
         where buf_fbr-doc.doc-code = p-fbr-doc-code
    .
    { gbl/gdsbcode.i
        p-gds-code
        ?
        v-b-code
    no-error }
    if error-status :error
    then do:
       undo, return error substitute("&1 &2 &3&4Ошибка определения основного бар-кода товара с кодом &6 в документе производства &5.4&7&4&8"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,{&new-line}
                                      ,buf_fbr-doc.doc-code
                                      ,p-gds-code
                                      ,error-status:get-message(1)
                                      ,return-value ) .
    end.
    { gbl/bcodeprc.i
        buf_fbr-doc.obj-type
        buf_fbr-doc.obj-code
        v-b-code
        0
        0
        v-void-character
        v-price-sale
        v-void-decimal
        v-void-decimal
        no-error
    }
    if error-status :error
    then do:
       undo, return error substitute("&1 &2 &3&4Ошибка определения продажной цены основного бар-кода товара &6.&4Документ производства &5.&4&7&4&8"
                                      ,vss-workfile
                                      ,vss-revision
                                      ,vss-description
                                      ,{&new-line}
                                      ,buf_fbr-doc.doc-code
                                      , p-artic
                                      ,error-status:get-message(1)
                                      ,return-value ) .

    end.
    do transaction
    on error undo, return error
    :
        for each buf_fbr-line exclusive-lock
           where buf_fbr-line.doc-code  = p-fbr-doc-code
             and buf_fbr-line.is-comp   = no
             and buf_fbr-line.prod-type = p-prod-type
             and buf_fbr-line.prod-code = p-prod-code
             and buf_fbr-line.artic     = p-artic
        on error undo, return error
        :
            if buf_fbr-line.is-calc = no
            then do:        /* в строке цена из прайс-листа, руками не вводилась */
                if buf_fbr-line.price-sale <> v-price-sale
                then do:
                    assign
                        buf_fbr-line.price-sale = v-price-sale
                    .
                end.
            end.        /* if buf_fbr-line.is-calc = no */
        end.        /* for each buf_fbr-line */
    end.        /* do transaction */
end.
end procedure. /* set-price-sale */