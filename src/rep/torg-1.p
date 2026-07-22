block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: torg-1.p $
$Archive: rep/torg-1.p $

Акт о приемке товаров

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Input:

Output:

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.

    define stream out-stream.

    define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
    define variable vss-author      as character no-undo initial "$Author: expertek $":U .
    define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
    define variable vss-workfile    as character no-undo initial "$Workfile: torg-1.p $":U .
    define variable vss-archive     as character no-undo initial "$Archive: rep/torg-1.p $":U .
    define variable vss-description as character no-undo initial "Акт о приемке товаров":U .
    { cmp/vssrevis.i }
    { cmp/str-glbl.i }
    { cmp/library.i  }
    { cmp/r-pril.i   }
    { str/lib-trn.i  }
    { str/trdcalib.i }
    { rep/w-rep.i    }
    { rep/fmtcli.i   }
    { rep/torgconf.i }
    { str/getctxtp.i def }
    { gbl/paramls.i  }
    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.
    { rep/torg1xl.i  }
    { str/clcprtsl.i }
    { str/out-vatp.i def }

    define variable v-line-counter  as integer         no-undo.
    define variable v-val-str       as char            no-undo.

    define variable v-print-doc                 as character                no-undo.

    define variable type-par        as character    no-undo .
    define variable v-gds-name      as character    no-undo.
    define variable v-gds-code      as integer      no-undo.
    define variable v-unit-name     as character    no-undo.
    define variable v-unit-okei     as integer      no-undo.
    define variable v-bar-code      as integer      no-undo.
    define variable v-sert          as character    no-undo.
    define variable v-price         as decimal      no-undo.
    define variable v-price-NoVAT   as decimal      no-undo.
    define variable v-qnty-supp     as decimal      no-undo.
    define variable v-qnty-fact     as decimal      no-undo.
    define variable v-curr-code     as integer      no-undo.
    define variable v-host-code     as integer      no-undo.

    define variable v-sum-PlaceAmountSupp   as decimal      no-undo.
    define variable v-sum-SumSupp           as decimal      no-undo.
    define variable v-sum-PlaceAmountFact   as decimal      no-undo.
    define variable v-sum-SumFact           as decimal      no-undo.
    define variable v-sum-sum               as decimal      no-undo.
    define variable v-sum-VATsum            as decimal      no-undo.
    define variable v-sum-PlaceAmountDelt   as decimal      no-undo.
    define variable v-sum-SumDelt           as decimal      no-undo.

    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_parts         for parts.
    define buffer buf_goods         for goods.
    define buffer buf_units         for units.
    define buffer buf_sert-join     for sert-join.
    define buffer buf_sert          for sert.
    define buffer buf_currency      for currency.
do
for buf_trn-doc
  , buf_doc-line
  , buf_parts
  , buf_goods
  , buf_units
  , buf_sert-join
  , buf_sert
  , buf_currency
on error undo, return error return-value
:
    { gbl/working.i }

    { str/getctxtp.i get p-mainmenu-handle }

    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).
    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = rec_id
    .
    { gbl/hostcode.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        v-host-code
    }
    if printRubl = yes
    then do:
        assign
            v-curr-code = 0
        .
    end.
    else do:
        { gbl/basecode.i
            v-host-code
            v-curr-code
        }
    end.
    run torgconf-read in this-procedure (
          input "torg1":U
        , input v-host-code
        , input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка чтения параметров печати формы."
            skip "Форма будет напечатана с параметрами по умолчанию."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box error.
    end.
    run torgconf-get-self-param in this-procedure (
          input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
        , input v-curr-code
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка чтения параметров объекта документа."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box warning.
    end.
    run torgconf-get-cli-param in this-procedure (
          input buf_trn-doc.host-code
        , input buf_trn-doc.cli-type
        , input buf_trn-doc.cli-code
        , input v-curr-code
    ) no-error.
    if error-status :error
    then do:
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка чтения параметров объекта клиента документа."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box warning.
    end.
{ gbl/getsect.i run buf_trn-doc.obj-type buf_trn-doc.obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .

    run torgconf-get-form-header in this-procedure (
          input Invers
        , input buf_trn-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input buf_trn-doc.doc-date
        , input buf_trn-doc.fact-date
        , input buf_trn-doc.doc-type
        , input buf_trn-doc.status_
        , input no
        , input no
    ).


    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    output stream out-stream close.

    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.


    run torg1xl-init in this-procedure .

    find first buf_currency no-lock
         where buf_currency.curr-code = buf_trn-doc.exch-code
    .
    assign
        v-val-str = ( if Invers
                      then buf_currency.curr-abbr
                      else ( if PrintRubl then "{&abbr_rublyah}" else "баз.вал" ) )
    .
/*FIND pay-type WHERE pay-type.obj-code = buf_trn-doc.pay-code NO-LOCK NO-ERROR .*/
/*string( "Основание: " + (if buf_trn-doc.doc-type = {&income} then buf_trn-doc.ord-num else "" ) ) format "X({&P0-X})"*/
/*string( "Примечание: " + (if NOT( buf_trn-doc.PS BEGINS "@" ) then buf_trn-doc.PS else "" ) ) format "X({&P0-X})"*/
/*string( "Вид оплаты: " + ( if available pay-type then pay-type.obj-name else "?" ) ) format "X({&P0-X1})"*/

    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-organization}
        , input v-torgconf-organization
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-cliFrom}
        , input v-torgconf-client-from
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-okpo}
        , input v-torgconf-okpo
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-docCode}
        , input v-torgconf-doc-code
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-docDate}
        , input v-torgconf-doc-date
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-operationType}
        , input ( if buf_trn-doc.doc-type = {&income} AND NOT Invers then " приход" else " расход" )
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-cargoTo}
        , input v-torgconf-torg12-cargo-label
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-cargoToValue}
        , input v-torgconf-cargo-from-value
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet1-supplier}
        , input v-torgconf-supplier
    ).
    assign
        v-line-counter = 0
    .
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.artic      = buf_doc-line.artic
               and buf_goods.prod-type  = buf_doc-line.prod-type
               and buf_goods.prod-code  = buf_doc-line.prod-code
        .
        find first buf_units no-lock
             where buf_units.unit-name = buf_goods.unit-base
        .
        assign
            v-gds-code  = buf_goods.gds-code
            v-gds-name  = buf_goods.gds-name
            v-unit-name = buf_units.unit-name
            v-unit-okei = buf_units.OKEI
        .
        for each tt-clcparts
        on error undo, return error
        :
            delete tt-clcparts.
        end.        /* for each tt-clcparts */
        for each buf_parts no-lock
           where buf_parts.out-code   = buf_trn-doc.doc-code
             and buf_parts.obj-type   = buf_trn-doc.obj-type
             and buf_parts.obj-code   = buf_trn-doc.obj-code
             and buf_parts.prod-type  = buf_doc-line.prod-type
             and buf_parts.prod-code  = buf_doc-line.prod-code
             and buf_parts.artic      = buf_doc-line.artic
        on error undo, return error return-value
        :
            assign
                v-line-counter = v-line-counter + 1
            .
            create tt-clcparts.
            buffer-copy buf_parts to tt-clcparts.
            run clcprtsl_calc-parts in this-procedure (
                  input recid( tt-clcparts )
                , input no
                , input no
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input "":U
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
                , input 0
            ).
            find first tt-allsum
                 where tt-allsum.sum-type = {&sum-general}
            .
            assign
                v-price     = ( if printrubl = yes then buf_parts.price-rubl else buf_parts.price-base )
                v-qnty-supp = buf_parts.qnty
                v-qnty-fact = buf_parts.fact-qnty
            .
            /*---S----- определяем строку с перечислением сертификатов ------*/
            assign
                v-sert = "":U
            .
            { gbl/gdsbcode.i
                buf_goods.gds-code
                ?
                v-bar-code
            no-error }.
            for each buf_sert-join no-lock
               where buf_sert-join.cli-type   = buf_goods.prod-type
                 and buf_sert-join.cli-code   = buf_goods.prod-code
                 and buf_sert-join.b-code     = v-bar-code
            :
                for each buf_sert no-lock
                   where buf_sert.sert-code = buf_sert-join.sert-code
                :
                    if  buf_trn-doc.fact-date <= buf_sert.last-date
                    and buf_trn-doc.fact-date >= buf_sert.first-date
                    then do:
                        assign
                            v-sert = v-sert
                                    + ( if trim( v-sert ) = "":U
                                        then "":U
                                        else ", ":U )
                                    + string( buf_sert-join.sert-code )
                        .
                    end.
                end.
            end.
        /*---E----- определяем строку с перечислением сертификатов ------*/
            assign
                v-price-NoVAT         = v-price - v-price * buf_parts.VAT-pc / ( 100 + buf_parts.VAT-pc )
                v-sum-PlaceAmountSupp = v-sum-PlaceAmountSupp + v-qnty-supp
                v-sum-SumSupp         = v-sum-SumSupp         + ( v-qnty-supp * v-price-NoVAT )
                v-sum-PlaceAmountFact = v-sum-PlaceAmountFact + v-qnty-fact
                v-sum-SumFact         = v-sum-SumFact         + ( v-qnty-fact * v-price-NoVAT )
                v-sum-sum             = v-sum-sum             + ( v-qnty-fact * v-price )
                v-sum-VATsum          = v-sum-VATsum          + ( buf_parts.VAT-pc / 100 * v-qnty-fact * v-price-NoVAT )
                v-sum-PlaceAmountDelt = v-sum-PlaceAmountDelt + ( v-qnty-fact - v-qnty-supp )
                v-sum-SumDelt         = v-sum-SumDelt         + ( ( v-qnty-fact - v-qnty-supp ) * v-price-NoVAT )
            .
            run torg1xl-sheet2-write-line-data in this-procedure (
                  input v-gds-name                  /* p-Name*/
                , input v-gds-code                  /* p-gdscode*/
                , input v-unit-name                 /* p-EI*/
                , input v-unit-okei                 /* p-OKEI*/
                , input v-price-NoVAT               /* p-price*/
                , input 1                           /* p-AmountInPlSupp*/
                , input v-qnty-supp                 /* p-PlaceAmountSupp*/
                , input 0                           /* p-MassSupp*/
                , input v-qnty-supp * v-price-NoVAT /* p-SumSupp*/
                , input 1                           /* p-AmountInPlFact*/
                , input v-qnty-fact                 /* p-PlaceAmountFact*/
                , input 0                           /* p-MassFact*/
                , input v-qnty-fact * v-price-NoVAT /* p-SumFact*/
                , input v-qnty-fact * v-price       /* p-sum*/
                , input buf_parts.VAT-pc            /* p-VATpc*/
                , input buf_parts.VAT-pc / 100 * v-qnty-fact * v-price-NoVAT /* p-VATsum*/
                , input 1                           /* p-AmountInPlDelt*/
                , input v-qnty-fact - v-qnty-supp   /* p-PlaceAmountDelt*/
                , input 0                           /* p-MassDelt*/
                , input ( v-qnty-fact - v-qnty-supp ) * v-price-NoVAT /* p-SumDelt*/
                , input v-sert                      /* p-Sertif*/
            ).
        end.        /* for each buf_parts */
    end.        /* for each buf_doc-line */
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-PlaceAmountSupp}
        , input v-sum-PlaceAmountSupp
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-SumSupp}
        , input v-sum-SumSupp
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-PlaceAmountFact}
        , input v-sum-PlaceAmountFact
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-SumFact}
        , input v-sum-SumFact
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-sum}
        , input v-sum-sum
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-VATsum}
        , input v-sum-VATsum
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-PlaceAmountDelt}
        , input v-sum-PlaceAmountDelt
    ).
    run torg1xl-write-cell-data in this-procedure (
          input {&torg1xl-sheet2-it-SumDelt}
        , input v-sum-SumDelt
    ).

    run torg1xl-close in this-procedure .

    { rep/q-print.i 4 }
    { gbl/stopwork.i }
end.