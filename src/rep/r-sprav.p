block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-sprav.p $
$Archive: rep/r-sprav.p $

Печатная форма Справка.

Автор: Демин Алексей Сергеевич
Дата создания: 09/08/05
Author: Alexey Demin
Creation date: 09/08/05

Input:

Output:

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-recid      as recid            no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-sprav.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-sprav.p $":U .
define variable vss-description as character no-undo initial "Печатная форма Справка.":U .

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i      }
{ rep/p-fmt.i       }
{ str/trdcalib.i    }
{ str/in-vatp.i def }

&scoped-define left-margin 5
&scoped-define right-margin 130
&scoped-define max-width 124

    define stream out-stream.

    define temp-table temp_vat no-undo
        field vat-pc        as decimal
        field sum-vat-base  as decimal
        field sum-vat-rubl  as decimal

        index pi is primary unique vat-pc
    .

    define variable v-host-code         as integer      no-undo.
    define variable v-host-name         as character    no-undo.
    define variable v-manager-name      as character    no-undo.
    define variable v-operator-name     as character    no-undo.
    define variable v-store-boss        as character    no-undo.
    define variable v-supp-name         as character    no-undo.

    define variable v-fact-sum          as decimal      no-undo.

    define variable v-propis            as character    no-undo.
    define variable v-propis-cop        as character    no-undo.
    define variable v-attr-value        as character    no-undo.
    define variable v-attr-type         as character    no-undo.
    define variable v-factur-string     as character    no-undo.
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_clients       for clients.
    define buffer buf_store         for store.
    define buffer buf_shop          for shop.
    define buffer buf_temp_vat      for temp_vat.
do
for buf_trn-doc
  , buf_clients
  , buf_store
  , buf_shop
  , buf_temp_vat
on error undo, return error
:
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    .
    { gbl/hostcode.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-host-code
    }
    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-host-code
    .
    assign
        v-host-name = trim( buf_clients.obj-name )
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
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.cli-type
           and buf_clients.obj-code = buf_trn-doc.cli-code
    .
    assign
        v-supp-name = trim( buf_clients.obj-name )
    .
    assign
        v-fact-sum = ( if PrintRubl then buf_trn-doc.fact-rubl else buf_trn-doc.fact-base )
    .
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
    run fill-temp-VAT in this-procedure (
        input buf_trn-doc.doc-code
    ).
    { cmp/open-out.i stream out-stream " " {&CS_PS} }

    { gbl/working.i  }

    put stream out-stream
        space( {&left-margin} )
        p-fmt-align-string( v-host-name, {&max-width}, 'right':U )
                                                    format "X({&max-width})"
        skip(2) space( {&left-margin} )
            "Дата оплаты: "
            buf_trn-doc.doc-date                    format "99.99.9999"
        skip space( {&left-margin} )
            "Менеджер:    "
            v-manager-name                          format "X({&max-width})"
        skip(2)
            "С П Р А В К А"                                         at center-field( 1, {&right-margin}, 13 )
        skip(1) space( {&left-margin} )
            p-fmt-align-string( v-supp-name, {&max-width}, 'center':U )
                                                    format "X({&max-width})"
        skip(1) space( {&left-margin} )
            "Товар на сумму: "
            string( v-fact-sum, ">>>>>>>>>9.99" )   format "X(13)"
            space( 1 )
            ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" )
    .
    if PrintRubl
    then do:        /* Если в  р у б л я х ,  то сумму прописью */
        run rep/wp-rub.p (
              input v-fact-sum
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
    find first buf_temp_vat no-error.
    if not available buf_temp_vat
    then do:
        put stream out-stream
            skip space( {&left-margin} )
                space( 8 ) "без НДС"
        .
    end.        /* if not available buf_temp_vat */
    else do:
        put stream out-stream
            skip space( {&left-margin} )
                space( 8 ) "в том числе:"
        .
        for each buf_temp_vat
        on error undo, return error
        :
            put stream out-stream
                skip space( {&left-margin} )
                    space( 20 ) "НДС "
                    buf_temp_vat.vat-pc     format ">>9.99%"
                    ":"
                    space(4)
                    ( if PrintRubl then buf_temp_vat.sum-vat-rubl else buf_temp_vat.sum-vat-base )
                                            format ">>>,>>>,>>9.99"
                    space( 1 )
                    ( if PrintRubl then "{&abbr_rub_allshift}" else "баз.вал" )
            .
        end.        /* for each buf_temp_vat */
    end.        /* if available buf_temp_vat */
    put stream out-stream
        skip( 2 ) space( {&left-margin} )
            "Выписал:  "
            v-operator-name format "X(25)"
            "Зав. маг.: "                    at 80
            v-store-boss    format "X(40)"
    .

    output stream out-stream close.

    { rep/q-print.i 4 }
    { gbl/stopwork.i }

end.

/*==========================================================================*/
procedure fill-temp-VAT :
define input parameter p-doc-code   as character        no-undo.

    define buffer buf_parts     for parts.
    define buffer buf_doc-line  for doc-line.
    define buffer buf_temp_vat  for temp_vat.
do
for buf_parts
  , buf_doc-line
  , buf_temp_vat
on error undo, return error
:
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = p-doc-code
    on error undo, return error
    :
        for each buf_parts no-lock
           where buf_parts.out-code   = p-doc-code
             and buf_parts.obj-type   = buf_doc-line.obj-type
             and buf_parts.obj-code   = buf_doc-line.obj-code
             and buf_parts.prod-type  = buf_doc-line.prod-type
             and buf_parts.prod-code  = buf_doc-line.prod-code
             and buf_parts.artic      = buf_doc-line.artic
             and buf_parts.status_    = true
        on error undo, return error return-value
        :
            find first buf_temp_vat
                 where buf_temp_vat.vat-pc = buf_parts.VAT-pc
            no-error.
            if not available buf_temp_vat
            then do:
                create buf_temp_vat.
                assign
                    buf_temp_vat.vat-pc         = buf_parts.VAT-pc
                    buf_temp_vat.sum-vat-base   = 0
                    buf_temp_vat.sum-vat-rubl   = 0
                .
            end.
            { str/in-vatp.i calc-parts buf_parts. " " loc}
            assign
                buf_temp_vat.sum-vat-base = buf_temp_vat.sum-vat-base + ( vat-base-loc * buf_parts.fact-qnty )
                buf_temp_vat.sum-vat-rubl = buf_temp_vat.sum-vat-rubl + ( vat-rubl-loc * buf_parts.fact-qnty )
            .
        end.        /* for each buf_parts */
    end.        /* for each buf_doc-line */
    for each buf_temp_vat
    on error undo, return error
    :
        if buf_temp_vat.sum-vat-base = 0
        and buf_temp_vat.sum-vat-rubl = 0
        then do:
            delete buf_temp_vat.
        end.
    end.        /* for each buf_temp_vat */
end.
end procedure. /* fill-temp-VAT */
