block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-spravm.p $
$Archive: rep/r-spravm.p $

Печатная форма Справка с раскладкой по менеджерам

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-spravm.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-spravm.p $":U .
define variable vss-description as character no-undo initial "Печатная форма Справка с раскладкой по менеджерам":U .

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i      }
{ rep/p-fmt.i       }
{ str/trdcalib.i    }
{ str/in-vatp.i def }
{ str/clcprtsl.i    }
{ rep/fmtcli.i      }

&scoped-define left-margin 5
&scoped-define right-margin 130
&scoped-define max-width 124

    define stream out-stream.

    define temp-table temp_manager no-undo
        field manager-id    as integer
        field manager-name  as character
        field sum-all-base  as decimal
        field sum-all-rubl  as decimal
        field sum-vat-base  as decimal
        field sum-vat-rubl  as decimal
        field is-selected   as logical

        index pi is primary unique
            manager-id
    .
    define temp-table temp_manager-vat no-undo
        field manager-id    as integer
        field vat-pc        as character
        field sum-vat-base  as decimal
        field sum-vat-rubl  as decimal

        index pi is primary unique manager-id vat-pc
    .
    define variable v-host-code         as integer      no-undo.
    define variable v-host-name         as character    no-undo.
    define variable v-manager-name      as character    no-undo.
    define variable v-operator-name     as character    no-undo.
    define variable v-store-boss        as character    no-undo.
    define variable v-supp-name         as character    no-undo.
    define variable v-supp-inn          as character    no-undo.

    define variable v-propis            as character    no-undo.
    define variable v-propis-cop        as character    no-undo.
    define variable v-attr-value        as character    no-undo.
    define variable v-attr-type         as character    no-undo.
    define variable v-factur-string     as character    no-undo.
    define variable v-obj-name          as character    no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_clients           for clients.
    define buffer buf_store             for store.
    define buffer buf_shop              for shop.
    define buffer buf_temp_manager      for temp_manager.
do
for buf_trn-doc
  , buf_clients
  , buf_store
  , buf_shop
  , buf_temp_manager
on error undo, return error
:
    { gbl/working.i }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    .
    message
        "Вы можете распечатать справку"
        skip "по всем менеджерам"
        skip "или выбрать одного менеджера."
        skip(1)
        skip "Распечатать справку по всем менеджерам?"
    view-as alert-box buttons yes-no-cancel
    update v-1 as logical.
    if v-1 = ?
    then do:
        undo, return.
    end.
    if v-1 = yes
    then do:
        run fill-manager-list in this-procedure (
              input {&all}
            , input buf_trn-doc.doc-code
        ).
    end.
    else do:
        run fill-manager-list in this-procedure (
              input "":U
            , input buf_trn-doc.doc-code
        ).
    end.
    { gbl/hostcode.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-host-code
    }
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.obj-type
           and buf_clients.obj-code = buf_trn-doc.obj-code
    .
    assign
        v-obj-name = substitute( "Объект: &1 &2 &3"
            , buf_clients.obj-type
            , buf_clients.obj-code
            , trim( buf_clients.obj-name ) )
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-host-code
    .
    assign
        v-host-name = substitute( "Фирма: &1", trim( buf_clients.obj-name ) )
    .
    find first buf_clients no-lock
         where buf_clients.obj-type = {&prs}
           and buf_clients.obj-code = buf_trn-doc.boss
    no-error.
    { gbl/usrnick.i
        buf_trn-doc.creid
        v-operator-name
    }
    assign
        v-manager-name  = ( if available buf_clients then trim( buf_clients.obj-name ) else "" )
    .
    if buf_trn-doc.obj-type = {&stock}
    then do:
        find first buf_store no-lock
             where buf_store.obj-code = buf_trn-doc.obj-code
        .
        assign
            v-store-boss = trim( buf_store.store-boss )
        .
    end.
    if buf_trn-doc.obj-type = {&shop}
    then do:
        find first buf_shop no-lock
             where buf_shop.obj-code = buf_trn-doc.obj-code
        .
        assign
            v-store-boss = trim( buf_shop.store-boss )
        .
    end.
    run fmtcli-get-client in this-procedure (
          input buf_trn-doc.cli-type
        , input buf_trn-doc.cli-code
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка вычисления параметров фирмы - контрагента"
            skip return-value
            skip trim( error-status :get-message( 1 ) )
                 trim( error-status :get-message( 2 ) )
                 trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        undo, return error substitute( "Ошибка вычисления параметров фирмы - контрагента. &1. &2"
                                    , return-value
                                    , trim( error-status :get-message( 1 ) ) ).
    end.
    assign
        v-supp-name = v-fmtcli-name
        v-supp-inn  = v-fmtcli-inn
    .
    if v-supp-inn <> "":U
    then do:
    assign
            v-supp-inn = substitute( "ИНН: &1", v-supp-inn )
    .
    end.
    { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-nsf}
        v-attr-value
        v-attr-type
    }
    if v-attr-value = ""
    then do:
        assign
            v-factur-string = buf_trn-doc.ord-num
        .
    end.
    else do:
        assign
            v-factur-string = v-attr-value
        .
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-dsf}
            v-attr-value
            v-attr-type
        }
        assign
            v-factur-string = v-factur-string + " от " + v-attr-value
        .
    end.
    define variable v-page-counter    as integer      no-undo.
    assign
        v-page-counter = 0
    .
    { cmp/open-out.i stream out-stream " " {&CS_PS} }
    for each buf_temp_manager
       where buf_temp_manager.is-selected = yes
    :
        if v-page-counter <> 0
        then do:
            page stream out-stream.
        end.
        run print-manager-page in this-procedure (
              input buf_trn-doc.doc-code
            , input buf_temp_manager.manager-id
        ).
        assign
            v-page-counter = v-page-counter + 1
        .
    end.

    output stream out-stream close.

    { gbl/stopwork.i }
    { rep/q-print.i 4 }

end.

/*==========================================================================*/
procedure fill-temp-VAT :
define input parameter p-doc-line-recid as recid            no-undo.
define input parameter p-manager-id     as integer          no-undo.

    define buffer buf_parts     for parts.
    define buffer buf_doc-line  for doc-line.
    define buffer buf_temp_manager-vat  for temp_manager-vat.
do
for buf_parts
  , buf_doc-line
  , buf_temp_manager-vat
on error undo, return error
:
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
    for each buf_parts no-lock
       where buf_parts.out-code   = buf_doc-line.doc-code
         and buf_parts.obj-type   = buf_doc-line.obj-type
         and buf_parts.obj-code   = buf_doc-line.obj-code
         and buf_parts.prod-type  = buf_doc-line.prod-type
         and buf_parts.prod-code  = buf_doc-line.prod-code
         and buf_parts.artic      = buf_doc-line.artic
         and buf_parts.status_    = true
    on error undo, return error return-value
    :
        find first buf_temp_manager-vat
             where buf_temp_manager-vat.manager-id  = p-manager-id
               and buf_temp_manager-vat.vat-pc      = trim( string( buf_parts.VAT-pc, ">>9" ) )
        no-error.
        if not available buf_temp_manager-vat
        then do:
            create buf_temp_manager-vat.
            assign
                buf_temp_manager-vat.manager-id     = p-manager-id
                buf_temp_manager-vat.vat-pc         = trim( string( buf_parts.VAT-pc, ">>9" ) )
                buf_temp_manager-vat.sum-vat-base   = 0
                buf_temp_manager-vat.sum-vat-rubl   = 0
            .
        end.
        { str/in-vatp.i calc-parts buf_parts. " " loc }
        assign
            buf_temp_manager-vat.sum-vat-base = buf_temp_manager-vat.sum-vat-base + ( vat-base-loc * buf_parts.fact-qnty )
            buf_temp_manager-vat.sum-vat-rubl = buf_temp_manager-vat.sum-vat-rubl + ( vat-rubl-loc * buf_parts.fact-qnty )
        .
    end.        /* for each buf_parts */
    for each buf_temp_manager-vat
       where buf_temp_manager-vat.manager-id  = p-manager-id
    on error undo, return error
    :
        if buf_temp_manager-vat.sum-vat-base = 0
        and buf_temp_manager-vat.sum-vat-rubl = 0
        then do:
            delete buf_temp_manager-vat.
        end.
    end.        /* for each buf_temp_manager-vat */
end.
end procedure. /* fill-temp-VAT */


/*==========================================================================
    Заполнение таблицы списка менеджеров

    input:
        p-mode          - режим вызова. {&all} - все менеджеры товаров документа.
                          Иначе предоставляется выбор одного менеджера.
        p-trn-doc-code  - номер документа.

*/
procedure fill-manager-list :
define input parameter p-mode           as character        no-undo.
define input parameter p-trn-doc-code   as character        no-undo.

    define variable v-grp-code      as integer      no-undo.
    define variable v-upper-code    as integer      no-undo.
    define variable v-success       as logical      no-undo.

    define buffer buf_doc-line              for doc-line.
    define buffer buf_gds-grp               for gds-grp.
    define buffer buf_goods                 for goods.
    define buffer buf_temp_manager          for temp_manager.
    define buffer buf_tt-allsum-line        for tt-allsum-line.

do
for buf_doc-line
  , buf_gds-grp
  , buf_goods
  , buf_temp_manager
  , buf_tt-allsum-line
on error undo, return error
:
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = p-trn-doc-code
    on error undo, return error
    :
        find first buf_goods no-lock
                where buf_goods.artic      = buf_doc-line.artic
                and buf_goods.prod-type  = buf_doc-line.prod-type
                and buf_goods.prod-code  = buf_doc-line.prod-code
        .
        find first buf_gds-grp no-lock
                where buf_gds-grp.node-code = buf_goods.grp-code
        .
        assign
            v-upper-code = buf_gds-grp.upper-code
        .
        do while buf_gds-grp.lvl-num > 1
        on error undo, return error
        :
            find first buf_gds-grp no-lock
                    where buf_gds-grp.node-code = v-upper-code
            .
            assign
                v-upper-code = buf_gds-grp.upper-code
            .
        end.
        if buf_gds-grp.lvl-num = 1
        then do:
            find first buf_temp_manager
                 where buf_temp_manager.manager-id = buf_gds-grp.node-code
            no-error.
            if not available buf_temp_manager
            then do:
                create buf_temp_manager.
                assign
                    buf_temp_manager.manager-id     = buf_gds-grp.node-code
                    buf_temp_manager.manager-name   = buf_gds-grp.node-name
                    buf_temp_manager.sum-all-base   = 0
                    buf_temp_manager.sum-all-rubl   = 0
                    buf_temp_manager.is-selected       = no
                .
            end.
            run clcprtsl_calc-line in this-procedure (
                input recid( buf_doc-line )
            ).
            find first buf_tt-allsum-line
                    where buf_tt-allsum-line.sum-type = {&sum-general}
            .
            assign
                buf_temp_manager.sum-all-base        = buf_temp_manager.sum-all-base + buf_tt-allsum-line.sum-dsc-base-acc
                buf_temp_manager.sum-all-rubl        = buf_temp_manager.sum-all-rubl + buf_tt-allsum-line.sum-dsc-rubl-acc
            .
            run fill-temp-vat in this-procedure (
                  input recid( buf_doc-line )
                , input buf_temp_manager.manager-id
            ).
        end.
    end.        /* for each buf_doc-line */
    if p-mode = {&all}
    then do:
        for each buf_temp_manager
        on error undo, return error
        :
            assign
                buf_temp_manager.is-selected = yes
            .
        end.        /* for each buf_temp_manager */
    end.        /* if p-mode = {&all} */
    else do:
        run rep/r-spravd.w (
              input p-trn-doc-code
            , output v-grp-code
            , output v-success
        ).
        if v-success = yes
        then do:
            find first buf_temp_manager
                 where buf_temp_manager.manager-id = v-grp-code
            .
            assign
                buf_temp_manager.is-selected     = yes
            .
        end.
    end.        /* NOT ( if p-mode = {&all} ) */
end.
end procedure. /* fill-manager-list */


/*==========================================================================*/
procedure print-manager-page :
define input parameter p-trn-doc-code   as character        no-undo.
define input parameter p-manager-id     as integer          no-undo.

    define variable v-sum-all    as decimal      no-undo.
    define variable v-sum-vat    as decimal      no-undo.

    define buffer buf_trn-doc           for trn-doc.
    define buffer buf_temp_manager      for temp_manager.
    define buffer buf_temp_manager-vat  for temp_manager-vat.
do
for buf_trn-doc
  , buf_temp_manager
  , buf_temp_manager-vat
on error undo, return error
:
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-code
    .
    find first buf_temp_manager
         where buf_temp_manager.manager-id = p-manager-id
    .
    assign
        v-sum-all = ( if PrintRubl then buf_temp_manager.sum-all-rubl else buf_temp_manager.sum-all-base )
    .
    put stream out-stream
        skip
        p-fmt-align-string( v-host-name, {&max-width}, 'right':U )
                                                    format "X({&max-width})"
        skip
        p-fmt-align-string( v-obj-name, {&max-width}, 'right':U )
                                                    format "X({&max-width})"

        skip(2) space( {&left-margin} )
            "Срок оплаты: ___________________"
            /*buf_trn-doc.doc-date                    format "99.99.9999"*/
        skip(1) space( {&left-margin} )
            "Менеджер:    "
            buf_temp_manager.manager-name           format "X({&max-width})"
        skip(2)
            p-fmt-align-string( substitute( "С П Р А В К А    &1", p-trn-doc-code ) , {&max-width}, 'center':U )
                                                    format "X({&max-width})"
        skip(1) space( {&left-margin} )
            p-fmt-align-string( v-supp-name, {&max-width}, 'center':U )
                                                    format "X({&max-width})"
        skip    space( {&left-margin} )
            p-fmt-align-string( v-supp-inn, {&max-width}, 'center':U )
                                                    format "X({&max-width})"
        skip(1) space( {&left-margin} )
            "Товар на сумму: "
            string( v-sum-all, ">>>>>>>>>9.99" )   format "X(13)"
            space( 1 )
            ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" )
    .
    if PrintRubl
    then do:        /* Если в  р у б л я х ,  то сумму прописью */
        run rep/wp-rub.p (
              input v-sum-all
            , output v-propis
            , output v-propis-cop
        ).
        put stream out-stream
            space(2)
            "( " + v-propis + " )"  format "X(100)"
        .
    end.
    put stream out-stream
        skip space( {&left-margin} )
            space( 4 ) "по фактуре: "
            v-factur-string         format "X(100)"
    .
    find first buf_temp_manager-vat
         where buf_temp_manager-vat.manager-id = p-manager-id
    no-error.
    if not available buf_temp_manager-vat
    then do:
        put stream out-stream
            skip space( {&left-margin} )
                space( 8 ) "без НДС"
        .
    end.        /* if not available buf_temp_manager-vat */
    else do:
        put stream out-stream
            skip space( {&left-margin} )
                 space( 8 ) "в том числе:"
        .
        for each buf_temp_manager-vat
           where buf_temp_manager-vat.manager-id = p-manager-id
        on error undo, return error
        :
            put stream out-stream
                skip space( {&left-margin} )
                    substitute( "                    НДС &1%:    &2 &3"
                            , buf_temp_manager-vat.vat-pc
                            , string( ( if PrintRubl
                                then buf_temp_manager-vat.sum-vat-rubl
                                else buf_temp_manager-vat.sum-vat-base ), ">>>,>>>,>>9.99" )
                            , ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" )
                    )                                                   format "X(110)"
            .
        end.        /* for each buf_temp_manager-vat */
    end.        /* if available buf_temp_manager-vat */
    put stream out-stream
        skip( 2 ) space( {&left-margin} )
            "Зав. магазином: "                    at 50
            v-store-boss    format "X(60)"
    .
end.
end procedure. /* print-manager-page */

