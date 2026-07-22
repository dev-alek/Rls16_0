block-level on error undo, throw.
/*

$Revision: 5baf537283c9, 2487, rls $
$Author: SSlivenko $
$Date: 2020/06/26 13:47:04 $
$Workfile: fbr-gds.p $
$Archive: str/fbr-gds.p $

Резервирование одного товара в документе производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

Процедура по резервирует на складе необходимое количество товара
и проставляет в строки документа производства учётные цены.
Перед вызовом процедуры для товара в документе должны быть сформированы
все строки на списание с количествами и продажными ценами товара.

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-fbrhist-handle as widget-handle    no-undo.
define input parameter p-fbr-doc-recid  as recid            no-undo.
define input parameter p-silent         as logical          no-undo .
define input parameter p-goods-recid    as recid            no-undo.   /* recid резервируемого товара */
define input parameter p-autofbr        as logical          no-undo.  /* раскрутка для ресторана, от продажи, на кухне */
define input parameter p-have-store     as logical          no-undo.  /* при раскрутке остатки смотреть на складе кухни */

define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/26 13:47:04 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr-gds.p $":U .
define variable vss-description as character no-undo init "Резервирование одного товара в документе производства".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ gbl/cur-time.i }
{ trg/partslib.i }
{ cmp/strcodec.i }
{ str/fbrrsrv.i  }
{ rep/fbrrep.i   }
{ str/writelog.i def "'fbr.log'" no-create }
{ str/fbr-log.i  }

do
on error undo, return error
:

    define variable v-required-qnty     like doc-line.doc-qnty  no-undo.    /* требуемое для резервирования - важна точность */
    define variable v-reserved-qnty     like doc-line.doc-qnty  no-undo.    /* количество для резервирования */
    define variable v-store-qnty                 as decimal      no-undo.
    define variable v-fbr-line-factor           as decimal      no-undo.
    define variable v-is-rsrv                   as logical      no-undo. /* удачно зарезервировано, результаты имеют смысл */
    define variable v-price-sale        like gds-dtl.price-rubl no-undo. /* продажная цена из производства */
    define variable v-trn-doc-doc-code          as character    no-undo.
    define variable v-old-price-base            as decimal      no-undo.
    define variable v-old-price-rubl            as decimal      no-undo.
    define variable v-old-price-sum-base        as decimal      no-undo.
    define variable v-old-price-sum-rubl        as decimal      no-undo.
    define variable v-old-price-sum-vat-base    as decimal      no-undo.
    define variable v-old-price-sum-vat-rubl    as decimal      no-undo.
    define variable v-store-sum-base            as decimal      no-undo.
    define variable v-store-sum-rubl            as decimal      no-undo.
    define variable v-store-sum-vat-base        as decimal      no-undo.
    define variable v-store-sum-vat-rubl        as decimal      no-undo.
    define variable v-cost-price-rubl           as decimal        no-undo.
    define variable v-cost-price-base           as decimal        no-undo.
    define variable v-cost-price-vat-rubl       as decimal        no-undo.
    define variable v-cost-price-vat-base       as decimal        no-undo.
    define variable v-err-msg                   as character      no-undo.
    
    define buffer buf_goods             for goods.
    define buffer buf_fbr-line          for fbr-line.
    define buffer buf_temp_fbrrep-goods for temp_fbrrep-goods.

    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input "=====*** fbr-gds.p ***================================================"
    ).
    find first fbr-doc no-lock
        where recid ( fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_goods no-lock
         where recid ( buf_goods )     = p-goods-recid
    .
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "Обработка товара &1 &2"
                            , buf_goods.artic
                            , buf_goods.gds-name  )
    ).
    run fbrrep-fill-qnty-and-prices-gds in this-procedure (
          input fbr-doc.doc-code
        , input buf_goods.gds-code
    ).
    find first buf_temp_fbrrep-goods
         where buf_temp_fbrrep-goods.artic     = buf_goods.artic
           and buf_temp_fbrrep-goods.prod-type = buf_goods.prod-type
           and buf_temp_fbrrep-goods.prod-code = buf_goods.prod-code
    use-index ar
    .
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "Вычислены суммы: "
            + {&new-line} + "                       fact-qnty           : &1"
            + {&new-line} + "                       write-off-rsrv-qnty : &2"
            + {&new-line} + "                       write-off-qnty      : &3"
            + {&new-line} + "                       income-qnty         : &4"
            + {&new-line} + "                       income-rsrv-qnty    : &5"
            + {&new-line} + "                       cost-rubl           : &6"
            + {&new-line} + "                       cost-base           : &7"
            + {&new-line} + "                       sum-cost-rubl       : &8"
            + {&new-line} + "                       sum-cost-base       : &9"
                        , buf_temp_fbrrep-goods.fact-qnty
                        , buf_temp_fbrrep-goods.write-off-rsrv-qnty
                        , buf_temp_fbrrep-goods.write-off-qnty
                        , buf_temp_fbrrep-goods.income-qnty
                        , buf_temp_fbrrep-goods.income-rsrv-qnty
                        , buf_temp_fbrrep-goods.cost-rubl
                        , buf_temp_fbrrep-goods.cost-base
                        , buf_temp_fbrrep-goods.sum-cost-rubl
                        , buf_temp_fbrrep-goods.sum-cost-base        )
    ).
    run writelog in this-procedure (
          input log-file-name
        , input 0
        , input substitute(
                            "                       vat-cost-rubl       : &1"
            + {&new-line} + "                       vat-cost-base       : &2"
            + {&new-line} + "                       sum-vat-cost-rubl   : &3"
            + {&new-line} + "                       sum-vat-cost-base   : &4"
            + {&new-line} + "                       price-sale          : &5"
            + {&new-line} + "                       deleted             : &6"
                        , buf_temp_fbrrep-goods.vat-cost-rubl
                        , buf_temp_fbrrep-goods.vat-cost-base
                        , buf_temp_fbrrep-goods.sum-vat-cost-rubl
                        , buf_temp_fbrrep-goods.sum-vat-cost-base
                        , buf_temp_fbrrep-goods.price-sale
                        , buf_temp_fbrrep-goods.deleted             )
    ).

    assign
        v-is-rsrv        = no
    .
    assign
        v-required-qnty  =    buf_temp_fbrrep-goods.write-off-qnty
                            - buf_temp_fbrrep-goods.write-off-rsrv-qnty
                            - buf_temp_fbrrep-goods.income-qnty
/*                            + buf_temp_fbrrep-goods.income-rsrv-qnty*/
        v-price-sale     = buf_temp_fbrrep-goods.price-sale
    .
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "Нужно зарезервировать количество: &1 с ценой: &2"
                            , v-required-qnty
                            , v-price-sale )
    ).
    if v-required-qnty > 0
    then do:
        run str/fbr-trn.p (
              input {&write-off}        /* тип формируемой накладной */
            , input fbr-doc.doc-code    /* документ производства */
            , input buf_goods.gds-code  /* товар */
            , output v-trn-doc-doc-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error substitute("&1 &2 &3&4Ошибка резервирования товара &5.&4Количество &6 продажная цена &7:&4&8&4&9"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,buf_goods.artic  + {&space-char} + buf_goods.gds-name
                                          ,v-required-qnty
                                          ,v-price-sale
                                          , error-status:get-message(1)
                                          , return-value ).

        end.
        run fill-doc-line in this-procedure (
              input v-trn-doc-doc-code
            , input p-fbr-doc-recid
            , input p-goods-recid       /* товар */
            , input v-price-sale        /* продажная цена */
            , input v-required-qnty     /* количество для резервирования */
            , output v-reserved-qnty    /* зарезервированное количество */
            , output v-store-qnty        /* зарезервированное количество по строке документа - ВСЕГО */
            , output v-store-sum-base     /* суммы - также ВСЕГО, по всему зарезервированному товару по строке документа */
            , output v-store-sum-rubl
            , output v-store-sum-vat-base
            , output v-store-sum-vat-rubl
        ) no-error.
        if error-status :error
        then do:
            assign
                v-reserved-qnty = 0
            .
            if error-status :get-message(1) <> ""
            or return-value <> "user-interrupt":U
            then do:
              if p-silent then do:
                v-err-msg = substitute("&1 &2 &3&4Не удалось зарезервировать товар на складе.&4" +
                                  "Товар: &5&4Требуемое количество: &6&4Зарезервировано количество:   &7&4&8&4&9"
                                  ,vss-workfile
                                  ,vss-revision
                                  ,vss-description
                                  ,{&new-line}
                                  ,buf_goods.artic + {&space-char} + buf_goods.gds-name
                                  ,v-required-qnty
                                  ,v-reserved-qnty
                                  , error-status:get-message(1)
                                  , return-value ).

              end.
              else do:
                v-err-msg = trim(error-status :get-message(1)) + " " +  trim(error-status :get-message(2)) + " " + trim(error-status :get-message(3)).
              end.
              
              find first tt-rsrv-err where tt-rsrv-err.artic = buf_goods.artic no-lock no-error.
              if not available tt-rsrv-err 
                then do: 
                  create tt-rsrv-err.
                  assign
                    tt-rsrv-err.artic = buf_goods.artic
                    tt-rsrv-err.gds-name = buf_goods.gds-name
                    .
                end.
              assign 
                tt-rsrv-err.rsrv-qnty = tt-rsrv-err.rsrv-qnty + v-reserved-qnty
                tt-rsrv-err.req-qnty = tt-rsrv-err.req-qnty + v-required-qnty
              .
              output stream stm to value (v-fbr-tt-log-file-name) append.
              export stream stm tt-rsrv-err.
              output stream stm close.
              if p-silent then do:
                if p-autofbr then do:
                  undo, return error "not-reserved":U.
                end.
                undo, return error v-err-msg.
              end.
              else do:
                message
                        vss-workfile vss-revision vss-description
                    skip "Не удалось зарезервировать товар на складе."
                    skip "Товар: " buf_goods.artic buf_goods.gds-name
                    skip (1)
                    skip "Требуемое количество:         " v-required-qnty
                    skip "Зарезервировано количество:   " v-reserved-qnty
                    skip return-value
                    skip v-err-msg
                view-as alert-box error.
            end.
            end.
            undo, return error return-value.
        end.
        if v-required-qnty <> v-reserved-qnty
        then do:
           if not p-silent then do:
            message
                skip "Не удалось зарезервировать товар на складе."
                skip "Товар: " buf_goods.artic buf_goods.gds-name
                skip (1)
                skip "Требуемое количество:         " v-required-qnty
                skip "Зарезервировано количество:   " v-reserved-qnty
            view-as alert-box error.
            end.
        end.
        assign
            v-is-rsrv = yes
        .
        run writelog in this-procedure (
              input log-file-name
            , input 1
            , input substitute( "Зарезервировано:"
                + {&new-line} + "                       v-reserved-qnty    : &1"
                + {&new-line} + "                       v-store-qnty        : &2"
                + {&new-line} + "                       v-store-sum-base    : &3"
                + {&new-line} + "                       v-store-sum-rubl    : &4"
                + {&new-line} + "                       v-store-sum-vat-base: &5"
                + {&new-line} + "                       v-store-sum-vat-rubl: &6"
                        , v-reserved-qnty
                        , v-store-qnty
                        , v-store-sum-base
                        , v-store-sum-rubl
                        , v-store-sum-vat-base
                        , v-store-sum-vat-rubl           )

        ).
        assign
            v-cost-price-rubl       = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-rubl     + buf_temp_fbrrep-goods.sum-cost-income-rubl      + v-store-sum-rubl     ) / buf_temp_fbrrep-goods.write-off-qnty
            v-cost-price-base       = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-base     + buf_temp_fbrrep-goods.sum-cost-income-base      + v-store-sum-base     ) / buf_temp_fbrrep-goods.write-off-qnty
            v-cost-price-vat-rubl   = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-rubl + buf_temp_fbrrep-goods.sum-vat-cost-income-rubl  + v-store-sum-vat-rubl ) / buf_temp_fbrrep-goods.write-off-qnty
            v-cost-price-vat-base   = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-base + buf_temp_fbrrep-goods.sum-vat-cost-income-base  + v-store-sum-vat-base ) / buf_temp_fbrrep-goods.write-off-qnty
        .
    end.        /* if v-required-qnty > 0 */
    else do:        /* Произведено товара достаточно для того, чтобы не брать со склада */
        assign
            v-store-qnty            = buf_temp_fbrrep-goods.write-off-qnty - buf_temp_fbrrep-goods.write-off-rsrv-qnty /* то, что будет зарезервировано из приходов */
            v-cost-price-rubl       = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-rubl     + ( buf_temp_fbrrep-goods.cost-income-rubl     * v-store-qnty ) ) / buf_temp_fbrrep-goods.write-off-qnty
            v-cost-price-base       = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-base     + ( buf_temp_fbrrep-goods.cost-income-base     * v-store-qnty ) ) / buf_temp_fbrrep-goods.write-off-qnty
            v-cost-price-vat-rubl   = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-rubl + ( buf_temp_fbrrep-goods.vat-cost-income-rubl * v-store-qnty ) ) / buf_temp_fbrrep-goods.write-off-qnty
            v-cost-price-vat-base   = ( buf_temp_fbrrep-goods.sum-write-off-rsrv-vat-base + ( buf_temp_fbrrep-goods.vat-cost-income-base * v-store-qnty ) ) / buf_temp_fbrrep-goods.write-off-qnty
        .
        run writelog in this-procedure (
              input log-file-name
            , input 1
            , input "Произведено товара достаточно для того, чтобы не брать со склада."
        ).
    end.
    run writelog in this-procedure (
          input log-file-name
        , input 1
        , input substitute( "Вычислены цены списания:"
            + {&new-line} + "                       v-store-qnty          : &1"
            + {&new-line} + "                       v-cost-price-rubl     : &2"
            + {&new-line} + "                       v-cost-price-base     : &3"
            + {&new-line} + "                       v-cost-price-vat-rubl : &4"
            + {&new-line} + "                       v-cost-price-vat-base : &5"
                    , v-store-qnty
                    , v-cost-price-rubl
                    , v-cost-price-base
                    , v-cost-price-vat-rubl
                    , v-cost-price-vat-base            )

    ).
    for each buf_fbr-line
       where buf_fbr-line.doc-code  = fbr-doc.doc-code
         and buf_fbr-line.trn-type  = {&write-off}
         and buf_fbr-line.artic     = buf_goods.artic
         and buf_fbr-line.prod-type = buf_goods.prod-type
         and buf_fbr-line.prod-code = buf_goods.prod-code
    on error undo, return error
    :       /* расставляем rsrv-qnty и учетные цены по всем списаниям */
        assign
            v-old-price-base            = buf_fbr-line.price-base
            v-old-price-rubl            = buf_fbr-line.price-rubl
            v-old-price-sum-base        = buf_fbr-line.price-sum-base
            v-old-price-sum-rubl        = buf_fbr-line.price-sum-rubl
            v-old-price-sum-vat-base    = buf_fbr-line.price-sum-vat-base
            v-old-price-sum-vat-rubl    = buf_fbr-line.price-sum-vat-rubl
        .
        assign
            buf_fbr-line.rsrv-qnty              = buf_fbr-line.fact-qnty
            buf_fbr-line.price-rubl             = v-cost-price-rubl
            buf_fbr-line.price-base             = v-cost-price-base
            buf_fbr-line.price-sum-rubl         = v-cost-price-rubl     * buf_fbr-line.fact-qnty
            buf_fbr-line.price-sum-base         = v-cost-price-base     * buf_fbr-line.fact-qnty
            buf_fbr-line.price-sum-vat-rubl     = v-cost-price-vat-rubl * buf_fbr-line.fact-qnty
            buf_fbr-line.price-sum-vat-base     = v-cost-price-vat-base * buf_fbr-line.fact-qnty
        .
        if (  ( v-old-price-base           <> buf_fbr-line.price-base         ) )
        or (  ( v-old-price-rubl           <> buf_fbr-line.price-rubl         ) )
        or (  ( v-old-price-sum-base       <> buf_fbr-line.price-sum-base     ) )
        or (  ( v-old-price-sum-rubl       <> buf_fbr-line.price-sum-rubl     ) )
        or (  ( v-old-price-sum-vat-base   <> buf_fbr-line.price-sum-vat-base ) )
        or (  ( v-old-price-sum-vat-rubl   <> buf_fbr-line.price-sum-vat-rubl ) )
        then do:        /* раскидываем изменённую цену по компонентам (разделка) или вычисляем приход (производство) */
            define buffer buf_fbr-recipe        for fbr-recipe.

            if fbr-doc.is-free = yes
            then do:
                run calc-income-fbr-line in this-procedure (
                      input buf_fbr-line.doc-code
                    , input buf_fbr-line.recipe-code
                ).
            end.        /* if fbr-doc.is-free = yes */
            else do:
                find first buf_fbr-recipe no-lock
                     where buf_fbr-recipe.recipe-code = buf_fbr-line.recipe-code
                     and buf_fbr-recipe.doc-code      = ub.fbr-doc.doc-code 
                .
                if buf_fbr-recipe.recipe-type <> {&dressing}
                and ( buf_fbr-recipe.recipe-type <> {&gathering}
                    or buf_fbr-line.trn-type  <> {&income} )
                then do:        /* Для разделки и разукомплектации надо раскидывать измененную цену по компонентам */
                    run calc-income-fbr-line in this-procedure (
                          input buf_fbr-line.doc-code
                        , input buf_fbr-line.recipe-code
                    ).

                end.
                else do:
                    run calc-write-off-fbr-line in this-procedure (
                          input buf_fbr-line.doc-code
                        , input buf_fbr-line.recipe-code
                    ).
                end.
            end.        /* if fbr-doc.is-free <> yes */
        end.
    end.        /* for each buf_fbr-line */
end.


/*==========================================================================
Заполнение строки складского документа с резервированием товара.

input:
    p-price-sale    -      продажная цена товара
    p-required-qnty -  требуемое количество (которое надо ДОРЕЗЕРВИРОВАТЬ по данной строке),
                        точность не важна, PROGRESS берет точность из вызывающей процедуры
output:
    p-reserved-qnty - зарезервированное количество (которое ДОРЕЗЕРВИРОВАНО по данной строке),
                        должно быть точности doc-line.doc-qnty (3), иначе будет накапливаться погрешность при резервировании
    p-full-qnty     - общее количество зарезервированного товара по строке
    p-cost-base     - учетная цена ВСЕГО зарезервированного по строке товара в базовой валюте
    p-cost-rubl     - учетная цена ВСЕГО зарезервированного по строке товара в р_ублях
    p-sum-base      - сумма учетных цен ВСЕГО по строке документа без НДС в базовой валюте
    p-sum-rubl      - сумма учетных цен ВСЕГО по строке документа без НДС в р_ублях
    p-sum-vat-base  - сумма НДС учетных цен ВСЕГО по строке документа в базовой валюте
    p-sum-vat-rubl  - сумма НДС учетных цен ВСЕГО по строке документа в р_ублях
==========================================================================*/
procedure fill-doc-line :

  define input  parameter p-trn-doc-doc-code  as character no-undo .
  define input  parameter p-fbr-doc-recid     as recid     no-undo .
  define input  parameter p-goods-recid       as recid     no-undo .
  define input  parameter p-price-sale        as decimal   no-undo .
  define input  parameter p-required-qnty     as decimal   no-undo .
  define output parameter p-reserved-qnty     as decimal   no-undo .
  define output parameter p-full-qnty         as decimal   no-undo .
  define output parameter p-sum-base          as decimal   no-undo .
  define output parameter p-sum-rubl          as decimal   no-undo .
  define output parameter p-sum-vat-base      as decimal   no-undo .
  define output parameter p-sum-vat-rubl      as decimal   no-undo .

  do
  on error undo, return error
  :

    define variable v-doc-line-recid    as recid        no-undo.
    define variable v-out-price-base    as decimal      no-undo.
    define variable v-out-price-rubl    as decimal      no-undo.
    define variable v-sum-base          as decimal      no-undo.
    define variable v-sum-rubl          as decimal      no-undo.
    define variable v-vat-base          as decimal      no-undo.
    define variable v-vat-rubl          as decimal      no-undo.
    define variable v-vat-pc            as decimal      no-undo.
    define variable v-host-code         as integer      no-undo.
    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-void-decimal      as decimal      no-undo.

    define buffer buf_fbr-doc       for fbr-doc.
    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_gds-dtl       for gds-dtl.

    find first buf_fbr-doc no-lock
         where recid( buf_fbr-doc ) = p-fbr-doc-recid
    .
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    /* создаем, если нет, строки НС или ПН */
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
            buf_doc-line.artic         = buf_goods.artic
            buf_doc-line.prod-type     = buf_goods.prod-type
            buf_doc-line.prod-code     = buf_goods.prod-code
            buf_doc-line.obj-type      = buf_trn-doc.obj-type
            buf_doc-line.obj-code      = buf_trn-doc.obj-code
            buf_doc-line.doc-code      = buf_trn-doc.doc-code
            buf_doc-line.prt-ok        = yes
            buf_doc-line.prt-root      = buf_goods.prt-root
            buf_doc-line.status_       = buf_trn-doc.status_
            buf_doc-line.doc-qnty      = 0
            buf_doc-line.cli-base-rate = 1
        .
    end.
    assign
        v-doc-line-recid = recid( buf_doc-line )
    .
    run fbrrsrv-rsrv-goods in this-procedure (
          input parparentproc
        , input p-goods-recid
        , input v-doc-line-recid
        , input p-required-qnty
        , input yes
        , input p-price-sale
        , input no
        , input ""
        , output p-reserved-qnty
    ) no-error.
    /*
    run rsrv-good in this-procedure (
          input  p-goods-recid
        , input  p-trn-doc-doc-code
        , input  v-doc-line-recid
        , input  p-price-sale
        , input  p-required-qnty
        , output p-reserved-qnty
    ) no-error.
    */
    if error-status :error
    then do:
        if error-status :get-message(1) <> ""
        or return-value <> "user-interrupt":U
        then do:
           if p-silent then do:
             undo, return error substitute("&1 &2 &3&4Ошибка резервирования товара.&4 &5&4&6"
                                           ,vss-workfile
                                           ,vss-revision
                                           ,vss-description
                                           ,{&new-line}
                                           , error-status:get-message(1)
                                           , return-value ).
           end.
           else do:
            message
            vss-workfile vss-revision vss-description
            skip "Ошибка резервирования товара."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
            view-as alert-box error.
        end.
        end.
        undo, return error return-value.
    end.
    if p-reserved-qnty <> round( p-required-qnty, 3 )
    then do:
        assign
            p-reserved-qnty = 0
            p-sum-base      = 0
            p-sum-rubl      = 0
            p-sum-vat-base  = 0
            p-sum-vat-rubl  = 0
        .
        undo, return error.
    end.
    run str/fbrcost.p (
          input recid( buf_doc-line )
        , input -1
        , input p-required-qnty
        , output v-sum-base
        , output v-sum-rubl
        , output v-vat-base
        , output v-vat-rubl
        , output v-vat-pc
      ) .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    { gbl/hostcode.i
        buf_fbr-doc.obj-type
        buf_fbr-doc.obj-code
        v-host-code
    }
    { gbl/pftxvalg.i
        buf_goods.gds-code
        {&vat-tax-code}
        ?
        v-host-code
        buf_fbr-doc.obj-type
        buf_fbr-doc.obj-code
        v-vat-pc
    }
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
     .
    assign
        p-full-qnty             = buf_doc-line.doc-qnty + p-reserved-qnty
        buf_doc-line.doc-qnty   = p-full-qnty
        buf_doc-line.fact-qnty  = p-full-qnty
        buf_gds-dtl.doc-qnty    = p-full-qnty
        buf_gds-dtl.fact-qnty   = p-full-qnty
        buf_trn-doc.status_     = {&manufactured}
        p-sum-base              = v-sum-base - v-vat-base
        p-sum-rubl              = v-sum-rubl - v-vat-rubl
        p-sum-vat-base          = v-vat-base
        p-sum-vat-rubl          = v-vat-rubl
    .
    assign      /* накладная заполняется как р_ублевая */
        buf_doc-line.price-cli  = v-sum-rubl / p-full-qnty
        buf_doc-line.price-base = v-sum-base / p-full-qnty
        buf_doc-line.price-rubl = v-sum-rubl / p-full-qnty
        buf_doc-line.VAT-pc     = v-vat-pc
    .
end.
end procedure. /* fill-doc-line */

/*==========================================================================
Резервирование товара в складском документе
input:
    p-goods-recid       - товар
    p-trn-doc-doc-code  - складской документ
    p-doc-line-recid    - строка складского документа
    p-price-sale        - продажная цена товара
    p-required-qnty     - требуемое количество (которое надо дорезервировать по данной строке),
                            точность не важна - PROGRESS берет точность из вызывающей процедуры
output:
    p-rsrv-qnty         - зарезервированное количество,
                            должно быть точности doc-line (3), иначе будет накапливаться погрешность при резервировании
*/
procedure rsrv-good :
do
on error undo, return error
:
define input parameter p-goods-recid        as recid                    no-undo.
define input parameter p-trn-doc-doc-code   as character                no-undo.
define input parameter p-doc-line-recid     as recid                    no-undo.
define input parameter p-price-sale         like fbr-line.price-sale    no-undo.
define input parameter p-required-qnty      like doc-line.doc-qnty      no-undo.
define output parameter p-rsrv-qnty         like doc-line.doc-qnty      no-undo.

    define variable v-r-b-is-base   as logical      no-undo.
    define variable v-cost-base     as decimal      no-undo.
    define variable v-cost-rubl     as decimal      no-undo.

    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.

    { gbl/rbisbase.i
        v-r-b-is-base
    }
    find first buf_goods no-lock
         where recid( buf_goods ) = p-goods-recid
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
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
    /* подставляем цены продажи из fbr и фиксируем их */
    if v-r-b-is-base = yes
    then do:
        assign
            buf_gds-dtl.price-rubl = buf_gds-dtl.price-base * buf_trn-doc.base-rate / buf_trn-doc.base-scale
            buf_gds-dtl.price-base = p-price-sale
        .
    end.
    else do:
        assign
            buf_gds-dtl.price-rubl = p-price-sale
            buf_gds-dtl.price-base = buf_gds-dtl.price-rubl / buf_trn-doc.base-rate * buf_trn-doc.base-scale
        .
    end.
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
    run trg/rsrv-dtl.p (
          input parparentproc
        , input {&rsrv-dtl_action_reserv}
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
        message
            "Неправильные цены резервирования:"
            skip "{&abbr_rubli_allshift}:   " v-cost-rubl
            skip "БАЗ.ВАЛ.:" v-cost-base
            skip "Артикул:" buf_doc-line.artic
        view-as alert-box error.
        undo, return error.
    end.
end.
end procedure. /* rsrv-good */

/*==========================================================================*/
procedure calc-income-fbr-line :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-recipe-code        as character    no-undo.

    define variable v-sum-price-rubl     as decimal       no-undo.
    define variable v-sum-price-base     as decimal       no-undo.
    define variable v-sum-vat-price-rubl as decimal       no-undo.
    define variable v-sum-vat-price-base as decimal       no-undo.

    define buffer buf_income_fbr-line     for fbr-line.
    define buffer buf_write-off_fbr-line     for fbr-line.

    for each buf_write-off_fbr-line no-lock
       where buf_write-off_fbr-line.doc-code    = p-fbr-doc-doc-code
         and buf_write-off_fbr-line.trn-type    = {&write-off}
         and buf_write-off_fbr-line.recipe-code = p-recipe-code
    on error undo, return error
    :
        assign
            v-sum-price-rubl     = v-sum-price-rubl     + ( if buf_write-off_fbr-line.price-rubl <> ? then buf_write-off_fbr-line.fact-qnty * buf_write-off_fbr-line.price-rubl else 0 )
            v-sum-price-base     = v-sum-price-base     + ( if buf_write-off_fbr-line.price-base <> ? then buf_write-off_fbr-line.fact-qnty * buf_write-off_fbr-line.price-base else 0 )
            v-sum-vat-price-rubl = v-sum-vat-price-rubl + ( if buf_write-off_fbr-line.price-sum-vat-rubl <> ? then buf_write-off_fbr-line.price-sum-vat-rubl else 0 )
            v-sum-vat-price-base = v-sum-vat-price-base + ( if buf_write-off_fbr-line.price-sum-vat-base <> ? then buf_write-off_fbr-line.price-sum-vat-base else 0 )
        .
    end.
    find first buf_income_fbr-line exclusive-lock
         where buf_income_fbr-line.doc-code    = p-fbr-doc-doc-code
           and buf_income_fbr-line.trn-type    = {&income}
           and buf_income_fbr-line.recipe-code = p-recipe-code
    .
    assign
        buf_income_fbr-line.price-sum-rubl        = v-sum-price-rubl
        buf_income_fbr-line.price-sum-base        = v-sum-price-base
        buf_income_fbr-line.price-sum-vat-rubl    = v-sum-vat-price-rubl
        buf_income_fbr-line.price-sum-vat-base    = v-sum-vat-price-base
        buf_income_fbr-line.price-rubl            = v-sum-price-rubl / buf_income_fbr-line.fact-qnty
        buf_income_fbr-line.price-base            = v-sum-price-base / buf_income_fbr-line.fact-qnty
    .
/*    message*/
/*        "X" buf_comp_fbr-line.artic*/
/*        skip buf_comp_fbr-line.price-sum-rubl*/
/*        skip buf_comp_fbr-line.price-sum-base*/
/*        skip buf_comp_fbr-line.price-sum-vat-rubl*/
/*        skip buf_comp_fbr-line.price-sum-vat-base*/
/*        skip buf_comp_fbr-line.price-rubl*/
/*        skip buf_comp_fbr-line.price-base*/
/*    view-as alert-box information.*/
end.
end procedure. /* calc-income-fbr-line */

/*==========================================================================*/
procedure calc-write-off-fbr-line :
do
on error undo, return error
:
define input parameter p-fbr-doc-doc-code   as character    no-undo.
define input parameter p-recipe-code        as character    no-undo.

    define variable v-sum-price-sale    as decimal       no-undo.
    define variable v-cost-factor       as decimal       no-undo.

    define buffer buf_income_fbr-line     for fbr-line.
    define buffer buf_write-off_fbr-line     for fbr-line.

    for each buf_income_fbr-line no-lock
       where buf_income_fbr-line.doc-code    = p-fbr-doc-doc-code
         and buf_income_fbr-line.trn-type    = {&income}
         and buf_income_fbr-line.recipe-code = p-recipe-code
    on error undo, return error
    :
        assign
            v-sum-price-sale = v-sum-price-sale + ( buf_income_fbr-line.price-sale * buf_income_fbr-line.fact-qnty )
        .
    end.
  find first buf_write-off_fbr-line no-lock
         where buf_write-off_fbr-line.doc-code    = p-fbr-doc-doc-code
           and buf_write-off_fbr-line.trn-type    = {&write-off}
           and buf_write-off_fbr-line.recipe-code = p-recipe-code
    .
    for each buf_income_fbr-line exclusive-lock
       where buf_income_fbr-line.doc-code    = p-fbr-doc-doc-code
         and buf_income_fbr-line.trn-type    = {&income}
         and buf_income_fbr-line.recipe-code = p-recipe-code
    on error undo, return error
    :
        assign
            v-cost-factor                            = buf_income_fbr-line.price-sale * buf_income_fbr-line.fact-qnty / v-sum-price-sale
            buf_income_fbr-line.price-rubl           = buf_write-off_fbr-line.price-rubl * v-cost-factor
            buf_income_fbr-line.price-base           = buf_write-off_fbr-line.price-base * v-cost-factor
            buf_income_fbr-line.price-sum-rubl       = buf_income_fbr-line.price-sum-rubl * buf_income_fbr-line.fact-qnty
            buf_income_fbr-line.price-sum-base       = buf_income_fbr-line.price-sum-base * buf_income_fbr-line.fact-qnty
            buf_income_fbr-line.price-sum-vat-rubl   = buf_write-off_fbr-line.price-sum-vat-rubl * v-cost-factor
            buf_income_fbr-line.price-sum-vat-base   = buf_write-off_fbr-line.price-sum-vat-base * v-cost-factor
        .
    end.
end.
end procedure. /* calc-write-off-fbr-line */