block-level on error undo, throw.
/*

$Revision: 5baf537283c9, 2487, rls $
$Author: SSlivenko $
$Date: 2020/06/26 13:47:04 $
$Workfile: rcscredl.p $
$Archive: rcs/rcscredl.p $

Импорт RCS: Создание строк приходной накладной

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-doc-code   as character    no-undo .
define input parameter p-gds-code           as integer      no-undo .
define input parameter p-required-qnty      as decimal      no-undo .
define input parameter p-price-cost         as decimal      no-undo .
define input parameter p-base-rate          as decimal      no-undo.
define input parameter p-base-scale         as integer      no-undo.
define input parameter p-line-num           as integer      no-undo.

define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/26 13:47:04 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcscredl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcscredl.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }

    define variable v-doc-line-recid            as recid     no-undo .
    define variable v-out-price-base            as decimal   no-undo .
    define variable v-out-price-rubl            as decimal   no-undo .
    define variable v-allsum-sum-dsc-base-acc   as decimal   no-undo .
    define variable v-allsum-sum-dsc-rubl-acc   as decimal   no-undo .
    define variable v-allsum-vat-base-acc       as decimal   no-undo .
    define variable v-allsum-vat-rubl-acc       as decimal   no-undo .
    define variable v-vat-pc                    as decimal   no-undo .
    define variable v-host-code                 as integer   no-undo.
    define variable v-cons-vat-pc               as decimal   no-undo.

    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_gds-dtl       for gds-dtl.
do
for buf_goods
  , buf_gds-prt
  , buf_trn-doc
  , buf_doc-line
  , buf_gds-dtl
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    { gbl/hostcode.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-host-code
    }
    { gbl/hostcvat.i
        v-host-code
        v-cons-vat-pc
    }
    { gbl/pftxvalg.i
        buf_goods.gds-code
        {&vat-tax-code}
        ?
        v-host-code
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-vat-pc
    }
    /* создаем, если нет, строчки НС и ПН */
    find first buf_doc-line exclusive-lock
         where buf_doc-line.doc-code  = buf_trn-doc.doc-code
           and buf_doc-line.artic     = buf_goods.artic
           and buf_doc-line.prod-type = buf_goods.prod-type
           and buf_doc-line.prod-code = buf_goods.prod-code
    no-error.
    if not available buf_doc-line
    then do:
        create buf_doc-line.
        assign
            buf_doc-line.doc-code      = buf_trn-doc.doc-code
            buf_doc-line.status_       = buf_trn-doc.status_
            buf_doc-line.artic         = buf_goods.artic
            buf_doc-line.prod-type     = buf_goods.prod-type
            buf_doc-line.prod-code     = buf_goods.prod-code
            buf_doc-line.obj-type      = buf_trn-doc.obj-type
            buf_doc-line.obj-code      = buf_trn-doc.obj-code
            buf_doc-line.prt-root      = buf_goods.prt-root
            buf_doc-line.cli-qnty      = p-required-qnty / buf_goods.cli-base-rate
            buf_doc-line.doc-qnty      = p-required-qnty
            buf_doc-line.fact-qnty     = p-required-qnty
            buf_doc-line.price-rubl    = p-price-cost
            buf_doc-line.price-base    = p-price-cost / p-base-rate * p-base-scale
            buf_doc-line.price-cli     = p-price-cost
            buf_doc-line.VAT-pc        = v-vat-pc               /* для порожденных партий - НДС для уч.цен. */
            buf_doc-line.VAT-pc        = 0
            buf_doc-line.line-num      = p-line-num
            buf_doc-line.unit-cli      = buf_goods.unit-base
            buf_doc-line.cli-base-rate = 1
            buf_doc-line.prt-ok        = yes
            buf_doc-line.cons-vat-pc   = v-cons-vat-pc
/*            buf_doc-line.price-base    = p-price-cost*/
            buf_doc-line.doc-qnty      = p-required-qnty
        .
    end.
    else do:
        message
                 vss-workfile vss-revision vss-description
            skip "Строка с импортируемым товаром уже есть в документе."
            skip "Номер документа:" buf_trn-doc.doc-code
            skip "Товар:" buf_goods.artic buf_goods.gds-name
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-doc-line-recid = recid( buf_doc-line )
    .
    /* резервируем товар */
    run rsrv-good in this-procedure (
          input buf_goods.gds-code                              /* товар */
        , input buf_trn-doc.doc-code                            /* приходная накладная */
        , input v-doc-line-recid                                /* строка приходной накладной */
        , input p-price-cost                                    /* цена р у б л и */
        , input p-price-cost / p-base-rate * p-base-scale       /* цена б.в. */
        , input p-required-qnty                                 /* количество для резервирования */
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка резервирования товара."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
     .
    assign
        buf_gds-dtl.doc-qnty    = p-required-qnty
        buf_gds-dtl.fact-qnty   = p-required-qnty
    .
end.

/*==========================================================================*/
procedure rsrv-good :


/*

p-price-cost    цена товара в р у б л я х ( для RCS - только в р у б л я х )
p-required-qnty требуемое количество,
                точность не важна - PROGRESS берет точность из вызывающей процедуры
p-rsrv-qnty     кол-во для резервирования,
                должно быть точности doc-line (3), иначе будет накапливатьс
                погрешность при резервировании

*/

do
on error undo, return error
:

define input parameter p-gds-code           as integer   no-undo .
define input parameter p-trn-doc-doc-code   as character no-undo .
define input parameter p-doc-line-recid     as recid     no-undo .
define input parameter p-price-cost-rubl    as decimal   no-undo .
define input parameter p-price-cost-base    as decimal   no-undo .
define input parameter p-required-qnty      as decimal   no-undo .

    define variable v-r-b-is-base   as logical      no-undo.

    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.

    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    { gbl/rbisbase.i
        v-r-b-is-base
    }
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
    find first buf_gds-dtl
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
     .
    /* округляем до третьего знака */
    /* именно с такой точностью учитывается товар в складских документах */
/*    assign*/
/*      p-rsrv-qnty = round( p-required-qnty, 3 )*/
/*    .*/
    if p-required-qnty = 0
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Невозможно зарезервировать количество 0."
          skip "Товар: " buf_goods.artic buf_goods.gds-name
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if p-price-cost-rubl <= 0
    then do:
        message
            "Неправильные цены резервирования:"
            skip "Учетная цена, {&abbr_rubli}:   " p-price-cost-rubl
            skip "Товар: " buf_goods.artic buf_goods.gds-name
        view-as alert-box error.
        undo, return error.
    end.
    run trg/rsrv-dtl.p (
          input p-mainmenu-handle
        , input {&rsrv-dtl_action_reserv}
        , buffer buf_gds-dtl
        , input-output p-required-qnty
        , input-output p-price-cost-base
        , input-output p-price-cost-rubl
        , input -1
        , input ""
    ) no-error.
    if error-status :error
    then do:
        if error-status :get-message(1) <> ""
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при резервировании товара."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
end procedure. /* rsrv-good */