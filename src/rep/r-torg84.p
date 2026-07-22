block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-torg84.p $
$Archive: rep/r-torg84.p $

Акт о приемке товаров. 1393НТФ №ТОРГ-8.4 (Кедр-М)

Автор: Комаров Иван Сергеевич
Дата создания: 02/26/10
Author: Ivan Komarov
Creation date: 02/26/10

Автор1: Демин Алексей Сергеевич
Дата создания1: 09/15/05

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.

    define stream out-stream.

    define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
    define variable vss-author      as character no-undo initial "$Author: expertek $":U .
    define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
    define variable vss-workfile    as character no-undo initial "$Workfile: r-torg84.p $":U .
    define variable vss-archive     as character no-undo initial "$Archive: rep/r-torg84.p $":U .
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
    define variable g#report-num    as integer      no-undo .
    define variable g#quest-print   as logical      no-undo .
    define variable g#log           as logical      no-undo .
    { rep/r-tg84xl.i  }
    { str/clcprtsl.i }
    { str/out-vatp.i def }

    define variable v-print-doc     as character    no-undo.
    define variable v-gds-name      as character    no-undo .
    define variable v-unit-name     as character    no-undo .
    define variable v-price         as decimal      no-undo .
    define variable v-price-NoVAT   as decimal      no-undo.
    define variable v-qnty-supp     as decimal      no-undo .
    define variable v-qnty-fact     as decimal      no-undo .
    define variable v-curr-code     as integer      no-undo .
    define variable v-host-code     as integer      no-undo .

    define variable v-sum-PlaceAmountSupp   as decimal      no-undo .
    define variable v-sum-SumSupp           as decimal      no-undo .
    define variable v-sum-PlaceAmountFact   as decimal      no-undo .
    define variable v-sum-SumFact           as decimal      no-undo .
    define variable v-sum-sum               as decimal      no-undo .
    define variable v-sum-VATsum            as decimal      no-undo .
    define variable v-sum-PlaceAmountDelt   as decimal      no-undo .
    define variable v-sum-SumDelt           as decimal      no-undo .

    define variable v-attr-value as character no-undo .
    define variable v-attr-type  as character no-undo .
    define variable v-osnov      as character no-undo .
    define variable v-data       as character no-undo .
    define variable v-month      as character no-undo .
    define variable v-name-month as character no-undo .
    define variable v-year       as character no-undo .
    define variable v-ndog       as character no-undo .
    define variable v-ddog       as character no-undo .

    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_parts         for ub.parts .
    define buffer buf_goods         for ub.goods .
    define buffer buf_units         for ub.units .
    define buffer buf_clients       for ub.clients .
    define buffer buf_contract      for ub.contract .

    define temp-table itog-vat
      field Name            as character
      field PlaceAmountSupp as decimal
      field SumSupp         as decimal
      field PlaceAmountFact as decimal
      field SumFact         as decimal
      field sum             as decimal
      field VAT-pc          as integer
      field VATsum          as decimal
      field PlaceAmountDelt as decimal
      field SumDelt         as decimal
    index pi is primary unique vat-pc .
do
for buf_trn-doc
  , buf_doc-line
  , buf_parts
  , buf_goods
  , buf_units
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
    run torgconf-read in this-procedure (
          input "torg1":U
        , input v-host-code
        , input buf_trn-doc.obj-type
        , input buf_trn-doc.obj-code
    ) no-error.
    if error-status :error
    then do :
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
    then do :
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
    then do :
        message
            vss-workfile vss-revision vss-description
            skip "Ошибка чтения параметров объекта клиента документа."
            skip return-value
            skip trim(error-status :get-message(1))
                trim(error-status :get-message(2))
                trim(error-status :get-message(3))
        view-as alert-box warning.
    end.
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

  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
  if v-attr-value > "" then do :
    assign v-osnov = "Накладная №" + v-attr-value .
  end .
  else do :
    assign v-osnov = "Накладная №" + buf_trn-doc.doc-code .
  end.

  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
  if v-attr-value > ""  then do :
    assign v-osnov = v-osnov + " от " + string(date(v-attr-value), "99/99/9999") .
  end.
  else do :
    assign v-osnov = v-osnov + " от " + v-torgconf-doc-date .
  end .
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-ndog} v-attr-value v-attr-type }
  if v-attr-value > "" then do :
    assign v-ndog = v-attr-value .
  end .
  else do :
    find first buf_contract no-lock
      where buf_Contract.host-code     = buf_trn-doc.host-code
        and buf_Contract.contract-code = buf_trn-doc.contract-code no-error .
        if available buf_contract then do :
            assign v-ndog = buf_contract.contract-prn-code .
        end .
  end .
  { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-ddog} v-attr-value v-attr-type }
  if v-attr-value > "" then do :
    assign v-ddog = string(date(v-attr-value), "99/99/9999") .
  end .
  else do :
    find first buf_contract no-lock
      where buf_Contract.host-code     = buf_trn-doc.host-code
        and buf_Contract.contract-code = buf_trn-doc.contract-code no-error .
        if available buf_contract then do :
            assign v-ddog = string(buf_contract.contract-date, "99/99/9999" ) .
        end .
  end .
  assign
    v-data = substring(v-ddog, 1, 2)
    v-month = substring(v-ddog, 4, 2)
    v-year = substring(v-ddog, 7, 4)
  .
  run gbl/num-monr.p (input v-month
                    , output v-name-month
                     ).

    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
   run tg84xl-init in this-procedure .

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    output stream out-stream close.

    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.

    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-organization}
        , input v-torgconf-organization
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-object}
        , input v-torgconf-self-obj-name
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-object2}
        , input v-torgconf-self-obj-name
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-cliFrom}
        , input v-torgconf-client-from
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-docCode}
        , input v-torgconf-doc-code
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-docDate}
        , input v-torgconf-doc-date
    ).

    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-cargoTo}
        , input v-torgconf-cargo-from-value
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-supplier}
        , input v-torgconf-supplier + ' ' +  v-torgconf-cli-phone
    ).

    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-ndog}
        , input v-ndog
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-nakl}
        , input v-osnov
    ).
    if v-data ne "?" and v-data > "" then do :
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-datadog}
        , input v-data
    ).
    end.
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-monthdog}
        , input v-name-month
    ).
    if v-year ne "?" and v-year > "" then do :
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-yeardog}
        , input v-year
    ).
    end .
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
            v-gds-name  = buf_goods.gds-name
            v-unit-name = buf_units.unit-name
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
            assign
                v-price-NoVAT         = v-price               - v-price * buf_parts.VAT-pc / ( 100 + buf_parts.VAT-pc )
                v-sum-PlaceAmountSupp = v-sum-PlaceAmountSupp + v-qnty-supp
                v-sum-SumSupp         = v-sum-SumSupp         + ( v-qnty-supp * v-price-NoVAT )
                v-sum-PlaceAmountFact = v-sum-PlaceAmountFact + v-qnty-fact
                v-sum-SumFact         = v-sum-SumFact         + ( v-qnty-fact * v-price-NoVAT )
                v-sum-sum             = v-sum-sum             + ( v-qnty-fact * v-price )
                v-sum-VATsum          = v-sum-VATsum          + ( buf_parts.VAT-pc / 100 * v-qnty-fact * v-price-NoVAT )
                v-sum-PlaceAmountDelt = v-sum-PlaceAmountDelt + ( v-qnty-fact - v-qnty-supp )
                v-sum-SumDelt         = v-sum-SumDelt         + ( ( v-qnty-fact - v-qnty-supp ) * v-price-NoVAT )
            .
            find first itog-vat
            where itog-vat.vat-pc = integer(buf_parts.VAT-pc)
            no-error.
            if not available itog-vat then do :
                create itog-vat.
                assign
                itog-vat.VAT-pc = integer(buf_parts.VAT-pc)
                .
            end.
            assign
                itog-vat.name            = "Итого по ставке " + string( itog-vat.VAT-pc ) + "%"
                itog-vat.PlaceAmountSupp = itog-vat.PlaceAmountSupp   + v-qnty-supp
                itog-vat.SumSupp         = itog-vat.SumSupp           + v-qnty-supp * v-price-NoVAT
                itog-vat.PlaceAmountFact = itog-vat.PlaceAmountFact   + v-qnty-fact
                itog-vat.SumFact         = itog-vat.SumFact           + v-qnty-fact * v-price-NoVAT
                itog-vat.sum             = itog-vat.sum               + v-qnty-fact * v-price
                itog-vat.VATsum          = itog-vat.VATsum            + buf_parts.VAT-pc / 100 * v-qnty-fact * v-price-NoVAT
                itog-vat.PlaceAmountDelt = itog-vat.PlaceAmountDelt   + v-qnty-fact - v-qnty-supp
                itog-vat.SumDelt         = itog-vat.SumDelt           + ( v-qnty-fact - v-qnty-supp ) * v-price-NoVAT
            .

            run tg84xl-write-line-data in this-procedure (
                  input v-gds-name                  /* p-Name*/
                , input v-unit-name                 /* p-EI*/
                , input v-price-NoVAT               /* p-price*/
                , input v-qnty-supp                 /* p-PlaceAmountSupp*/
                , input v-qnty-supp * v-price-NoVAT /* p-SumSupp*/
                , input v-qnty-fact                 /* p-PlaceAmountFact*/
                , input v-qnty-fact * v-price-NoVAT /* p-SumFact*/
                , input v-qnty-fact * v-price       /* p-sum*/
                , input itog-vat.VAT-pc            /* p-VATpc*/
                , input itog-vat.VAT-pc / 100 * v-qnty-fact * v-price-NoVAT /* p-VATsum*/
                , input v-qnty-fact - v-qnty-supp   /* p-PlaceAmountDelt*/
                , input ( v-qnty-fact - v-qnty-supp ) * v-price-NoVAT  /* p-SumDelt*/
            ).
        end.        /* for each buf_parts */
    end.        /* for each buf_doc-line */
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-PlaceAmountSupp}
        , input v-sum-PlaceAmountSupp
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-SumSupp}
        , input v-sum-SumSupp
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-PlaceAmountFact}
        , input v-sum-PlaceAmountFact
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-SumFact}
        , input v-sum-SumFact
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-sum}
        , input v-sum-sum
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-VATsum}
        , input v-sum-VATsum
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-PlaceAmountDelt}
        , input v-sum-PlaceAmountDelt
    ).
    run tg84xl-write-cell-data in this-procedure (
          input {&tg84xl-it-SumDelt}
        , input v-sum-SumDelt
    ).
    for each itog-vat no-lock by itog-vat.vat-pc :
        run tg84xl-write-line-data in this-procedure (
              input itog-vat.name
            , input ""
            , input ""
            , input itog-vat.PlaceAmountSupp
            , input itog-vat.SumSupp
            , input itog-vat.PlaceAmountFact
            , input itog-vat.SumFact
            , input itog-vat.sum
            , input itog-vat.VAT-pc
            , input itog-vat.VATsum
            , input itog-vat.PlaceAmountDelt
            , input itog-vat.SumDelt
        ).
    end.

    run tg84xl-close in this-procedure .

    { rep/q-print.i 4 }
    { gbl/stopwork.i }
end.