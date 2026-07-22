/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Резервирование товара в документах производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Required:
    { cmp/str-glbl.i }
    { cmp/library.i  }
    { cmp/strcodec.i }
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/*==========================================================================

Input:
    p-parent-proc         as handle               - mainmenu handle
    p-goods-recid         as recid                - recid товара для резервировани
    p-doc-line-recid      as recid                - recid строки складского документа
    p-required-qnty       like doc-line.doc-qnty  - требуемое количество
    p-set-price           as logical              - установить цену
    p-price               as decimal              - (если p-set-price = yes) - цена продажи
    p-rsrv-by-parts       as logical              - резервировать по партиям приходной накладной
    p-income-trn-doc-code as character            - (если p-rsrv-by-parts = yes) - номер приходной накладной

Output:
    p-rsrv-qnty           like doc-line.doc-qnty
*/
procedure fbrrsrv-rsrv-goods :

define input parameter p-parent-proc            as handle                   no-undo.
define input parameter p-goods-recid            as recid                    no-undo.
define input parameter p-doc-line-recid         as recid                    no-undo.
define input parameter p-required-qnty          like doc-line.doc-qnty      no-undo.
define input parameter p-set-price              as logical                  no-undo.
define input parameter p-price                  as decimal                  no-undo.
define input parameter p-rsrv-by-parts          as logical                  no-undo.
define input parameter p-income-trn-doc-code    as character                no-undo.
define output parameter p-rsrv-qnty             like doc-line.doc-qnty      no-undo.

    define variable v-parts-rsrv-qnty       as decimal      no-undo.
    define variable v-sum-parts-rsrv-qnty   as decimal      no-undo.

    define variable v-r-b-is-base           as logical      no-undo.
    define variable v-cost-base             as decimal      no-undo.
    define variable v-cost-rubl             as decimal      no-undo.
    define variable v-parts-parameter       as character    no-undo.
    define variable v-parts-found           as logical      no-undo.

    define variable v-price-base            as decimal      no-undo.
    define variable v-price-rubl            as decimal      no-undo.
    define variable v-yesno                 as logical      no-undo.

    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_parts         for parts.

do
for buf_goods
  , buf_gds-prt
  , buf_gds-dtl
  , buf_trn-doc
  , buf_doc-line
  , buf_parts
on error undo, return error
:
    { gbl/rbisbase.i
        v-r-b-is-base
    }
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = buf_doc-line.doc-code
    .
    assign
        buf_trn-doc.print-rubl = ( if v-r-b-is-base = yes then no else yes )
    .
    { str/crgdsdtl.i
        buf_trn-doc.obj-code
        buf_trn-doc.obj-type
        buf_trn-doc.doc-code
        buf_goods.artic
        buf_goods.prod-code
        buf_goods.prod-type
        buf_gds-prt.node-code
        yes
    no-error }
    if error-status:error
    then do:
        message
            "Ошибка при создании признака."
            skip return-value
        view-as alert-box error.
    end.
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
    .
    if p-set-price = yes
    then do:
        if v-r-b-is-base = yes
        then do:
            assign
                buf_gds-dtl.price-base = p-price
                buf_gds-dtl.price-rubl = p-price * buf_trn-doc.base-rate / buf_trn-doc.base-scale
            .
        end.
        else do:
            assign
                buf_gds-dtl.price-rubl = p-price
                buf_gds-dtl.price-base = p-price / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            .
        end.
    end.        /* if p-set-price = yes */
    else do:
        /*не распространяется количественная скидка на товар*/
        { str/set-pr.i
          recid(buf_gds-dtl)
          no
          ?
          no-error
        }
        if error-status:error
        then do:
            message
                "Ошибка при назначении цены признака."
                skip return-value
            view-as alert-box error.
        end.
        if v-r-b-is-base = yes
        then do:
            assign
                buf_gds-dtl.price-rubl = buf_gds-dtl.price-base * buf_trn-doc.base-rate / buf_trn-doc.base-scale
                buf_gds-dtl.price-base = buf_gds-dtl.price-base
            .
        end.
        else do:
            assign
                buf_gds-dtl.price-rubl = buf_gds-dtl.price-rubl
                buf_gds-dtl.price-base = buf_gds-dtl.price-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
            .
        end.
    end.        /* NOT ( if p-set-price = yes ) */
    assign
        buf_trn-doc.status_ = {&wayb}
        buf_trn-doc.flag_   = no
    .
/*  TODEL. для точности - в правой части должны быть аргументы одной (низкой) точности */
/*        p-rsrv-qnty     = p-required-qnty                       */
/*        p-rsrv-qnty     = p-rsrv-qnty - buf_doc-line.doc-qnty   */
    assign
        buf_gds-dtl.ov  = yes
        v-cost-base     = buf_doc-line.price-base
        v-cost-rubl     = buf_doc-line.price-rubl        /* это нужно на случай дельты = 0 */
        p-rsrv-qnty     = round( p-required-qnty, 3 )
    .
    if p-rsrv-by-parts = yes
    then do:
        assign
            v-parts-found           = no
            v-sum-parts-rsrv-qnty   = 0
        .
        if p-income-trn-doc-code <> ""
        then do:
            for each buf_parts no-lock
               where buf_parts.obj-type  = buf_doc-line.obj-type
                 and buf_parts.obj-code  = buf_doc-line.obj-code
                 and buf_parts.prod-type = buf_doc-line.prod-type
                 and buf_parts.prod-code = buf_doc-line.prod-code
                 and buf_parts.artic     = buf_doc-line.artic
                 and buf_parts.in-code   = p-income-trn-doc-code
                 and buf_parts.out-code  = p-income-trn-doc-code
            on error undo, return error return-value
            :
                assign
                    v-parts-found     = yes
                    v-parts-parameter = {&rsrv-dtl_action_reserv}
                                + ",":U + {&rsrv-dtl_no-message}
                                + ",":U + {&rsrv-dtl_rsrv-single-part}
                                + ",":U + {&rsrv-dtl_rsrv-in-code}   + "=":U + str-encode ( buf_parts.in-code  ,  "", ",=":U )
                                + ",":U + {&rsrv-dtl_rsrv-part-code} + "=":U + str-encode ( buf_parts.part-code,  "", ",=":U )
                .
                assign
                    v-parts-rsrv-qnty = ( if p-rsrv-qnty < buf_parts.fact-qnty then p-rsrv-qnty else buf_parts.fact-qnty )
                .
                run trg/rsrv-dtl.p (
                      input p-parent-proc
                    , input v-parts-parameter
                    , buffer buf_gds-dtl
                    , input-output v-parts-rsrv-qnty
                    , input-output v-cost-base
                    , input-output v-cost-rubl
                    , input -1
                    , input ""
                ) no-error.
                if error-status:error
                then do:
                    undo, return error return-value.
                end.
                if v-cost-base <= 0
                or v-cost-rubl <= 0
                then do:
                    undo, return error substitute("Неправильные цены резервирования:&1&2&3&1БАЗ.ВАЛ.:&4&1Артикул:&5"
                                                  ,{&new-line}
                                                  ,"{&abbr_rubli_allshift}:   "
                                                  ,v-cost-rubl
                                                  ,v-cost-base
                                                  ,buf_doc-line.artic).
                    .
                end.
                assign
                    v-sum-parts-rsrv-qnty = v-sum-parts-rsrv-qnty + v-parts-rsrv-qnty
                    p-rsrv-qnty           = p-rsrv-qnty           - v-parts-rsrv-qnty
                .
            end.        /* for each buf_parts no-lock */
        end.        /* if p-income-trn-doc-code <> "" */
        if p-rsrv-qnty > 0
        then do:
            run trg/rsrv-dtl.p (
                  input p-parent-proc
                , input {&rsrv-dtl_action_reserv}
                        + ",":U + {&rsrv-dtl_no-message}
                        + ",":U + {&rsrv-dtl_negative-check} + '=':U + '1':U
                , buffer buf_gds-dtl
                , input-output p-rsrv-qnty
                , input-output v-cost-base
                , input-output v-cost-rubl
                , input -1
                , input ""
            ) no-error.
            if error-status:error
            then do:
                undo, return error return-value.
            end.
            if v-cost-base <= 0
            or v-cost-rubl <= 0
            then do:
                undo, return error substitute("Неправильные цены резервирования:&1&2&3&1БАЗ.ВАЛ.:&4&1Артикул:&5"
                                              ,{&new-line}
                                              ,"{&abbr_rubli_allshift}:   "
                                              ,v-cost-rubl
                                              ,v-cost-base
                                              ,buf_doc-line.artic).

            end.
        end.
        assign
            p-rsrv-qnty = p-rsrv-qnty + v-sum-parts-rsrv-qnty
        .
    end.        /* if p-rsrv-by-parts = yes */
    else do:
        run trg/rsrv-dtl.p (
              input p-parent-proc
            , input {&rsrv-dtl_action_reserv}
                    + ",":U + {&rsrv-dtl_no-message}
                    + ",":U + {&rsrv-dtl_negative-check} + '=':U + '1':U
            , buffer buf_gds-dtl
            , input-output p-rsrv-qnty
            , input-output v-cost-base
            , input-output v-cost-rubl
            , input -1
            , input ""
        ) no-error.
        if error-status:error
        then do:
            undo, return error return-value.
        end.
        if v-cost-base <= 0
        or v-cost-rubl <= 0
        then do:
          undo, return error substitute("Неправильные цены резервирования:&1&2&3&1БАЗ.ВАЛ.:&4&1Артикул:&5"
                                        ,{&new-line}
                                        ,"{&abbr_rubli_allshift}:   "
                                        ,v-cost-rubl
                                        ,v-cost-base
                                        ,buf_doc-line.artic).

        end.
        /*         решили убрать, т.к. посчитали лишним для пользователей, особенно в авторежиме
        for each buf_parts no-lock
           where buf_parts.obj-type  = buf_doc-line.obj-type
             and buf_parts.obj-code  = buf_doc-line.obj-code
             and buf_parts.prod-type = buf_doc-line.prod-type
             and buf_parts.prod-code = buf_doc-line.prod-code
             and buf_parts.artic     = buf_doc-line.artic
             and buf_parts.in-code   = buf_doc-line.doc-code
             and buf_parts.out-code  = buf_doc-line.doc-code
        on error undo, return error return-value
        :
            message
                "При резервировании товара"
                skip "была создана порожденная партия."
                skip(1)
                skip "Товар:" buf_doc-line.artic buf_goods.gds-name
                skip "Необходимо количество:" p-required-qnty
                skip "Количество в отрицательной партии:" buf_parts.fact-qnty
                skip(1)
                skip "Продолжить закрытие документа?"
            view-as alert-box question
            buttons yes-no
            title "Создана порожденная партия"
            update v-yesno.
            if v-yesno <> yes
            then do:
                undo, return error "user-interrupt":U.
            end.
        end.
        */
    end.        /* if p-rsrv-by-parts <> yes */
end.
end procedure. /* fbrrsrv-rsrv-goods */


/* $Workfile$ e n d */