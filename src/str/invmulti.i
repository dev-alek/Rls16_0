/*

$Revision$
$Author$
$Date$
$Workfile$
$rchive: $

Разница в инвентаризации сделанная автоматически
Автор: Шкляр Елена
Дата создания: 10/15/05
Author: Shklyar Elena
Creation date: 10/15/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable old-val                       like ub.gds-dtl.fact-qnty no-undo.
define variable varnew_gds-dtl                as logical   no-undo.
define variable varr-b                        as character no-undo.
define variable is-petrol                     as logical   no-undo initial no.
define variable is-pieces                     as logical   no-undo initial no.
define variable v-is-ptrl                     as character no-undo initial "":U.
define variable v-data-type                   as character no-undo initial "":U.
define variable v-expptr                      as character no-undo initial ?.
define variable r-petrol-rec                  as recid     no-undo initial ?.
define variable v-inv-prsr                    as character no-undo .
define variable store-type                    as character no-undo .
define variable store-code                    as integer   no-undo .
define variable v-fact-order                  as decimal   no-undo .
define variable v-single-place                as logical   no-undo .
define variable v-fact-order-day1             as date      no-undo .
define variable doc-rec                       as recid     no-undo.
define variable line-rec                      as recid     no-undo.
define variable gds-rec                       as recid     no-undo.
define variable cur-rec                       as recid     no-undo.
define variable prt-rec                       as recid     no-undo .
define variable node-type                     as character no-undo.

define variable vartot-docold                 like ub.trn-doc.tot-doc no-undo.
define variable vartot-rublold                like ub.trn-doc.tot-rubl no-undo.
define variable i-total-doc-line_tot-ovold    like ub.trn-doc.tot-ov no-undo.
define variable i-total-doc-line_fact-rublold like ub.trn-doc.fact-rubl no-undo.
define variable i-total-doc-line_fact-baseold like ub.trn-doc.fact-base no-undo.
define variable i-total-doc-line_fact-qntyold like ub.trn-doc.fact-qnty no-undo.
define variable i-total-doc-line_doc-qntyold  like ub.trn-doc.doc-qnty no-undo.
define variable i-total-doc-line_cli-qntyold  like ub.trn-doc.cli-qnty no-undo .
define variable i-total-parts_fact-baseold    as decimal   no-undo.
define variable i-total-parts_fact-rublold    as decimal   no-undo.
define variable i-total-parts_fact-qntyold    as decimal   no-undo.

define buffer old_doc for ub.trn-doc.   

    
DEFINE TEMP-TABLE tt-doc-pl NO-UNDO like ub.doc-pl
    field pl-code2 like ub.doc-pl.pl-code
    .
define temp-table tt-gds-line-err no-undo 
    field artic       as character
    field gds-name    as character
    field prod-code   as integer
    field prod-type   as character
    field date-report as date
    field time-report as INTEGER
    field qnty-tsd    as decimal
    index pi artic prod-code prod-type.

define buffer buf-upd_tt-doc-pl for tt-doc-pl .

define temp-table told_doc-pl no-undo like ub.doc-pl 
    field pl-code2 like ub.doc-pl.pl-code
    .

{ gbl/getcntxt.i get }
assign
    store-type = v-cntxt-obj-type
    store-code = v-cntxt-obj-code
    .

procedure invMulti:
    define input parameter parparentproc as widget-handle no-undo.
    define input parameter doc-rec       as recid         no-undo.
    define input parameter line-rec      as recid         no-undo.
    define input parameter gds-rec       as recid         no-undo.
    define input parameter cur-rec       as recid         no-undo.
    define input parameter chg-qnty like ub.gds-dtl.fact-qnty no-undo .
    define input parameter node-type     as character     no-undo.

    define variable v-err-msg     as character no-undo .
    define variable old-pl-qnty   as decimal   no-undo.  /* Уже зарезервированное количество cкладско-местного товара*/
    define variable new-pl-qnty   as decimal   no-undo.  /* Необходимое для резервирования количество cкладско-местного товара*/
    define variable v-count-place as integer   no-undo .
 
    define buffer buf_doc-pl for ub.doc-pl .

    for each told_doc-pl
        on error undo, return error return-value
        :
        delete told_doc-pl.
    end.

    find ub.gds-prt no-lock where recid( ub.gds-prt ) = cur-rec.
    find first ub.trn-doc no-lock
        where recid( ub.trn-doc ) = doc-rec
        .
    find first ub.doc-line no-lock
        where recid( ub.doc-line ) = line-rec
        .
    find first ub.goods no-lock
        where recid( ub.goods   ) = gds-rec
        .
    find first ub.clients no-lock
        where ub.clients.obj-code = ub.goods.prod-code
        and ub.clients.obj-type = ub.goods.prod-type
        .
    find first ub.prt-obj no-lock
        where ub.prt-obj.prt-code  = ub.gds-prt.node-code
        and ub.prt-obj.prod-code = ub.goods.prod-code
        and ub.prt-obj.prod-type = ub.goods.prod-type
        and ub.prt-obj.artic     = ub.goods.artic
        and ub.prt-obj.obj-code  = store-code
        and ub.prt-obj.obj-type  = store-type
        no-error.
    if ub.trn-doc.fact-date = ? then 
    do:
        assign
            old-val      = ( if available ub.prt-obj then ub.prt-obj.fact-qnty else 0 )
            v-fact-order = integer ( ub.trn-doc.doc-date ) + 0.99
            .
    end.
    else 
    do:
        /* Старое значение на fact-order */
        if available ub.prt-obj then 
        do:
            run doc-qnty-by-factord (
                input  recid(ub.trn-doc)   ,
                input  ub.trn-doc.obj-type ,
                input  ub.trn-doc.obj-code ,
                input  ub.goods.artic      ,
                input  ub.goods.prod-type  ,
                input  ub.goods.prod-code  ,
                input  ub.prt-obj.prt-code ,
                output old-val ,
                output v-fact-order
                ).
        end.
        else 
        do:
            old-val = 0.
            v-fact-order  = ub.trn-doc.fact-order.
        end.

    end.

    { gbl/conf-rd.i
    "'is-ptrl'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-is-ptrl
    v-data-type
    no-error
  }
    if error-status :error
        or v-data-type <> "L"
        or lookup( v-is-ptrl, "yes,no" ) = 0
        then 
    do:
        assign
            v-is-ptrl = "no"
            .
    end.
    if v-is-ptrl = "yes" then 
    do:
    { str/is-petrl.i
      ub.goods.artic
      ub.goods.prod-type
      ub.goods.prod-code
      is-petrol
      is-pieces
      no-error
    }
        if not error-status :error
            and is-petrol = yes
            and is-pieces = no
            then 
        do:
        { str/gtexpptr.i
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        yes
        no
        v-expptr
        no-error
      }
            if error-status :error
                or lookup( v-expptr, {&calc-petrol-list} ) = 0
                then 
            do:
                assign
                    v-expptr = {&calc-petrol-volume}
                    .
            end.
            if v-expptr <> ? then 
            do:
                find first ub.inv-line no-lock
                    where ub.inv-line.doc-code  = ub.doc-line.doc-code
                    and ub.inv-line.artic     = ub.doc-line.artic
                    and ub.inv-line.prod-type = ub.doc-line.prod-type
                    and ub.inv-line.prod-code = ub.doc-line.prod-code
                    no-error.
            end.
            assign
                v-count-place = 0
                .
            for each buf_doc-pl no-lock
                where buf_doc-pl.out-code = ub.doc-line.doc-code
                and buf_doc-pl.gds-code = ub.goods.gds-code
                on error undo, return error return-value
                :
                create tt-doc-pl.
                buffer-copy buf_doc-pl to tt-doc-pl .
                assign
                    v-count-place = v-count-place + 1
                    .
            end.
            if v-count-place = 1 then 
            do:
                assign
                    v-single-place = true
                    .
            end.
            else 
            do:
                assign
                    v-single-place = false
                    .
            end.
        end. /* is-petrol = yes and is-pieces = no */
    end. /* v-is-ptrl */


    find ub.doc-line exclusive-lock where recid( ub.doc-line ) = line-rec.
    if v-expptr <> ? then 
    do:
        find first ub.inv-line exclusive-lock
            where ub.inv-line.doc-code  = ub.doc-line.doc-code
            and ub.inv-line.artic     = ub.doc-line.artic
            and ub.inv-line.prod-type = ub.doc-line.prod-type
            and ub.inv-line.prod-code = ub.doc-line.prod-code
            .
    end. /* if v-expptr <> ? */

    find ub.gds-dtl  exclusive-lock where
        ub.gds-dtl.doc-code  = ub.trn-doc.doc-code   and
        ub.gds-dtl.prod-code = ub.doc-line.prod-code and
        ub.gds-dtl.prod-type = ub.doc-line.prod-type and
        ub.gds-dtl.artic     = ub.doc-line.artic     and
        ub.gds-dtl.prt-code  = ub.gds-prt.node-code  no-error.
    assign 
        varnew_gds-dtl = ( not available ub.gds-dtl ).
    { str/crgdsdtl.i
      ub.doc-line.obj-code
      ub.doc-line.obj-type
      ub.doc-line.doc-code
      ub.doc-line.artic
      ub.doc-line.prod-code
      ub.doc-line.prod-type
      ub.gds-prt.node-code
      yes
      no-error
    }
    if error-status :error then 
    do:
        message "Ошибка при создании признака." skip
            return-value
            view-as alert-box error.
        return error.
    end.

    if varnew_gds-dtl = yes then 
    do:
        find ub.gds-dtl exclusive-lock where
            ub.gds-dtl.doc-code  = ub.trn-doc.doc-code   and
            ub.gds-dtl.prod-code = ub.doc-line.prod-code and
            ub.gds-dtl.prod-type = ub.doc-line.prod-type and
            ub.gds-dtl.artic     = ub.doc-line.artic     and
            ub.gds-dtl.prt-code  = ub.gds-prt.node-code.
        assign 
            ub.gds-dtl.doc-qnty  = 0
            ub.gds-dtl.fact-qnty = old-val.
        find first ub.goods no-lock where
            ub.goods.artic     = ub.gds-dtl.artic     and
            ub.goods.prod-type = ub.gds-dtl.prod-type and
            ub.goods.prod-code = ub.gds-dtl.prod-code.
        { str/get-pr.i calc ub.gds-dtl.obj-type ub.gds-dtl.obj-code ub.goods.gds-code ub.gds-dtl.prt-code " " v-fact-order  }

        if gp-price-sale <> ? then 
        do:
            ASSIGN 
                ub.doc-line.excise   = gp-excise
                ub.doc-line.road-tax = gp-road-tax.
            if varr-b = "rubl":U then 
            do: 
                ASSIGN 
                    ub.gds-dtl.price-rubl = gp-price-sale. 
            end.
            else 
            do: 
                ASSIGN 
                    ub.gds-dtl.price-base = gp-price-sale. 
            end.
        end.
        else 
        do:
            /*!!!!*/
            if v-fact-order = 0  then  
            do:
                message "Невозможно рассчитать fact-order.  Возможно не открыта смена на объекте "  view-as alert-box error .
            end.
            else 
            do:
                run factord-to-date in this-procedure ( v-fact-order , output v-fact-order-day1 ) .
                message substitute("Нет цены для товара &1  &4 (признак &2) на дату &3. Сделайте переоценку " , ub.goods.artic , ub.gds-dtl.prt-code, string(v-fact-order-day1, "99/99/9999" ) , ub.goods.gds-name )  view-as alert-box .
                if varr-b = "rubl":U then 
                do: 
                    ASSIGN 
                        ub.gds-dtl.price-rubl = 0. 
                end.
                else 
                do: 
                    ASSIGN 
                        ub.gds-dtl.price-base = 0. 
                end.
            end.
        end.

        if varr-b = "base":U then 
        do:
            assign 
                ub.gds-dtl.price-rubl = ub.gds-dtl.price-base * ub.trn-doc.base-rate / ub.trn-doc.base-scale.
        end.
        else 
        do:
            assign 
                ub.gds-dtl.price-base = ub.gds-dtl.price-rubl / ub.trn-doc.base-rate * ub.trn-doc.base-scale.
        end.
    end. /* varnew_gds-dtl */
    if v-expptr <> ? then 
    do:
        define variable v-fact-qnty     as decimal no-undo .
        define variable v-fact-cli-qnty as decimal no-undo .
        define variable v-rest-qnty     as decimal no-undo .
        define variable v-rest-cli-qnty as decimal no-undo .

        assign
            v-rest-qnty     = 0.0
            v-rest-cli-qnty = 0.0
            .
        for each ub.doc-pl exclusive-lock
            where ub.doc-pl.out-code  = ub.doc-line.doc-code
            and ub.doc-pl.gds-code  = ub.goods.gds-code
            on error undo, return error return-value
            :
            assign
                old-pl-qnty = (- ub.doc-pl.doc-qnty)
                .
            if old-pl-qnty <> 0.0 then 
            do:
                run trg/rsrv-dtl.p
                    ( input parparentproc
                    ,input {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_pl-code} + "=" + string(ub.doc-pl.pl-code) + ',' + {&rsrv-dtl_negative-check} + "=1"
                    ,buffer ub.gds-dtl
                    ,input-output old-pl-qnty
                    ,input-output ub.doc-line.price-base
                    ,input-output ub.doc-line.price-rubl
                    ,-1
                    ,""
                    ) no-error.
                if error-status :error then 
                do:
                    assign
                        v-err-msg = substitute( "Ошибка при разрезервировании.&1&2", {&new-line}, return-value )
                        .
                end.
                else 
                do:
                    if old-pl-qnty <> (- ub.doc-pl.doc-qnty) then 
                    do:
                        assign
                            v-err-msg = substitute( "Не удалось снять резервы по ранее зарезервированному количеству.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                      , {&new-line}
                                      , (- ub.doc-pl.doc-qnty)
                                      , old-pl-qnty
                                      )
                            .
                    end.
                end.
                if v-err-msg <> "":U then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        v-err-msg skip
                        view-as alert-box error .
                    undo, return error v-err-msg .
                end.
            end.
            find first tt-doc-pl
                where tt-doc-pl.out-code = ub.doc-pl.out-code
                and tt-doc-pl.gds-code = ub.doc-pl.gds-code
                and tt-doc-pl.pl-code  = ub.doc-pl.pl-code
                .
            buffer-copy tt-doc-pl to ub.doc-pl .
            assign
                new-pl-qnty = ub.doc-pl.doc-qnty
                .
            if new-pl-qnty <> 0.0 then 
            do:
                run trg/rsrv-dtl.p
                    ( input parparentproc
                    ,input {&rsrv-dtl_action_reserv} + "," + {&rsrv-dtl_pl-code} + "=" + string(ub.doc-pl.pl-code) + ',' + {&rsrv-dtl_negative-check} + "=1"
                    ,buffer ub.gds-dtl
                    ,input-output new-pl-qnty
                    ,input-output ub.doc-line.price-base
                    ,input-output ub.doc-line.price-rubl
                    ,-1
                    ,""
                    ) no-error.
                if error-status :error then 
                do:
                    assign
                        v-err-msg = substitute( "Ошибка при резервировании.&1&2", {&new-line}, return-value )
                        .
                end.
                else 
                do:
                    if new-pl-qnty <> ub.doc-pl.doc-qnty then 
                    do:
                        assign
                            v-err-msg = substitute( "Не удалось зарезервировать все запрошенное количество.&1Запрошено: &2&1Удалось разрезервировать: &3&1"
                                      , {&new-line}
                                      , ub.doc-pl.doc-qnty - old-pl-qnty
                                      , new-pl-qnty - old-pl-qnty
                                      )
                            .
                    end.
                end.
                if v-err-msg <> "":U then 
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        v-err-msg skip
                        view-as alert-box error .
                    undo, return error v-err-msg .
                end.
            end.
            assign
                v-fact-qnty     = v-fact-qnty     + ub.doc-pl.fact-qnty
                v-fact-cli-qnty = v-fact-cli-qnty + ub.doc-pl.cli-fact-qnty
                v-rest-qnty     = v-rest-qnty     + ub.doc-pl.rest-af-qnty
                v-rest-cli-qnty = v-rest-cli-qnty + ub.doc-pl.cli-rest-af-qnty
                .
        end.
        if v-rest-qnty <> 0.0
            and v-rest-cli-qnty <> 0.0
            then 
        do:
            assign
                ub.doc-line.doc-density  = v-rest-cli-qnty / v-rest-qnty
                ub.doc-line.fact-density = ub.doc-line.doc-density
                .
        end.

        assign
            ub.gds-dtl.fact-qnty      = v-rest-qnty
            ub.doc-line.doc-qnty      = v-rest-qnty
            ub.inv-line.wast-cli-qnty = v-rest-cli-qnty
            ub.gds-dtl.doc-qnty       = v-fact-qnty
            ub.doc-line.fact-qnty     = v-fact-qnty
            ub.doc-line.cli-qnty      = v-fact-cli-qnty
            .
    end.
    else 
    do:
        IF ub.trn-doc.flag_ = YES THEN 
        DO:

            run trg/rsrv-dtl.p ( input        parParentProc,
                input        {&rsrv-dtl_action_reserv},
                buffer       ub.gds-dtl,
                input-output chg-qnty,
                input-output ub.doc-line.price-base,
                input-output ub.doc-line.price-rubl,
                input        -1,
                input        ""  ).
            assign 
                ub.gds-dtl.fact-qnty  = ub.gds-dtl.fact-qnty  + chg-qnty
                ub.gds-dtl.doc-qnty   = ub.gds-dtl.fact-qnty  - old-val
                ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty  + chg-qnty
                ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty.
        END. /* ub.trn-doc.flag_ = YES */
        ELSE 
        DO: /* ub.trn-doc.flag_ <> YES */
            run trg/rsrv-dtl.p ( input        parParentProc,
                input        {&rsrv-dtl_action_reserv},
                buffer       ub.gds-dtl,
                input-output chg-qnty,
                input-output ub.doc-line.price-base,
                input-output ub.doc-line.price-rubl,
                input        -1                    ,
                input        ""     ).
            assign 
                ub.gds-dtl.fact-qnty  = ub.gds-dtl.fact-qnty  + chg-qnty
                ub.gds-dtl.doc-qnty   = ub.gds-dtl.doc-qnty   + chg-qnty
                ub.doc-line.doc-qnty  = ub.doc-line.doc-qnty  + chg-qnty
                ub.doc-line.fact-qnty = ub.doc-line.fact-qnty + chg-qnty.
        END. /* ub.trn-doc.flag_ <> YES */
    end.

    assign 
        prt-rec = recid( ub.gds-dtl ).
    if ub.gds-dtl.doc-qnty = 0 then 
    do:
        delete ub.gds-dtl.
        assign 
            prt-rec = ?.
    end.

    assign 
        ub.doc-line.prt-OK = no. /* начальное значение prt-OK */
    find ub.gds-prt no-lock where ub.gds-prt.upper-code = ub.goods.prt-root.
    for each ub.gds-dtl where /* назначено по всем признакам */
        ub.gds-dtl.prod-code = ub.goods.prod-code   and
        ub.gds-dtl.prod-type = ub.goods.prod-type   and
        ub.gds-dtl.artic     = ub.goods.artic       and
        ub.gds-dtl.doc-code  = ub.doc-line.doc-code :
        if ub.gds-dtl.doc-qnty <> 0 and ub.gds-dtl.prt-code <> ub.gds-prt.node-code then 
        do:
            assign 
                ub.doc-line.prt-OK = yes.
        end.
    end.
end procedure. 


