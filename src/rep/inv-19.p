block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сличительная ведомость ИНВ-19

Автор: Демин Алексей Сергеевич
Дата создания: 10/03/07
Author: Alexey Demin
Creation date: 10/03/07

Input:

Output:

*/
define input parameter parParentProc   as widget-handle no-undo.
define input parameter p-trn-doc-recid as recid         no-undo.
define input parameter p-mode          as character     no-undo.

define stream out-stream .

define shared var PrintScale   as logical                          no-undo.
define shared var CostPrice    as logical                          no-undo.
define shared var sort-name    as logical                          no-undo.
define shared var sort-gr      as logical                          no-undo.
define shared var print-graft  as logical                          no-undo.
define shared var no-vat       as logical                          no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сличительная ведомость ИНВ-19".
{ cmp/vssrevis.i    }

define variable g#report-num as integer   no-undo .
define variable g#quest-print as logical   no-undo .
define variable g#log as logical   no-undo .

{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ str/trdcalib.i    }
{ cmp/r-pril.i      }
{ rep/p-fmt.i       }
{ rep/fmtcli.i      }
{ rep/torgconf.i    }
{ gbl/paramls.i     }
define variable v-sys-key           as character    no-undo.
{ rep/inv19xl.i     }

&scop qnty-format '->>>,>>>,>>>,>>9.999'

    define variable v-host-code                 as integer                  no-undo.
    define variable v-curr-code                 as integer                  no-undo.
    define variable v-inv19-line-counter        as integer      no-undo.

    define variable v-izl-sum           as decimal      no-undo.
    define variable v-ned-sum           as decimal      no-undo.
    define variable v-per-izl-sum       as decimal      no-undo.
    define variable v-per-ned-sum       as decimal      no-undo.
    define variable v-izl-qnty          as decimal      no-undo.
    define variable v-ned-qnty          as decimal      no-undo.
    define variable v-per-izl-qnty      as decimal      no-undo.
    define variable v-per-ned-qnty      as decimal      no-undo.
    define variable v-tot-izl-sum       as decimal      no-undo.
    define variable v-tot-ned-sum       as decimal      no-undo.
    define variable v-tot-per-izl-sum   as decimal      no-undo.
    define variable v-tot-per-ned-sum   as decimal      no-undo.
    define variable v-tot-izl-qnty      as decimal      no-undo.
    define variable v-tot-ned-qnty      as decimal      no-undo.
    define variable v-tot-per-izl-qnty  as decimal      no-undo.
    define variable v-tot-per-ned-qnty  as decimal      no-undo.

    define variable v-par-type          as character    no-undo.


    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
do
for buf_trn-doc
  , buf_doc-line
on error undo, return error
:
    { gbl/working.i }

    { gbl/currsysk.i
      v-sys-key
      no-error
    }

   run get-report-num  in parParentProc ( output g#report-num ).

   run get-quest-print in parParentProc ( output g#quest-print ).

    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = p-trn-doc-recid
    .
    run check-doc-sum in this-procedure (
        input buf_trn-doc.doc-code
    ).
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
          input "inv3"
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
    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
    run inv19xl-init in this-procedure .

    define variable v-obj-str as character no-undo .
    if lookup( 'L-Rus' , v-sys-key) > 0
    then do:
      assign
        v-obj-str = substitute( "&1, &2"
                              , v-torgconf-self-obj-name
                              , v-torgconf-self-obj-addres
                              )
      .
    end.
    else do:
      assign
        v-obj-str = v-torgconf-self-obj-name
      .
    end.

    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-organization}  , input v-torgconf-self-host-name                             ).
    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-organization}  , input v-torgconf-self-host-name                             ).
    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-object}        , input v-obj-str                                             ).
/*    run inv19xl-write-cell-data in this-procedure ( input {&inv19-sheet1-osnov}         , input v-torgconf-self-host-name                             ).*/
    if lookup( 'L-Rus' , v-sys-key) = 0
    then do:
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-docinvcode}    , input buf_trn-doc.doc-code                                  ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-docdate}       , input string( buf_trn-doc.doc-date , "99/99/9999" )         ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-startdate}     , input string( buf_trn-doc.doc-date , "99/99/9999" )         ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-enddate}       , input string( buf_trn-doc.fact-date, "99/99/9999" )         ).
    end.

    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-doccode}       , input buf_trn-doc.doc-code                                  ).
    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-factdate}      , input string( buf_trn-doc.fact-date, "99/99/9999" )         ).

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .

    assign
        v-tot-izl-sum      = 0.0
        v-tot-ned-sum      = 0.0
        v-tot-per-izl-sum  = 0.0
        v-tot-per-ned-sum  = 0.0
        v-tot-izl-qnty     = 0.0
        v-tot-ned-qnty     = 0.0
        v-tot-per-izl-qnty = 0.0
        v-tot-per-ned-qnty = 0.0
    .
    for each buf_doc-line no-lock
       where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
        run print-line in this-procedure (
              input buf_doc-line.doc-code
            , input buf_doc-line.artic
            , input buf_doc-line.prod-type
            , input buf_doc-line.prod-code
            , output v-izl-sum
            , output v-ned-sum
            , output v-per-izl-sum
            , output v-per-ned-sum
            , output v-izl-qnty
            , output v-ned-qnty
            , output v-per-izl-qnty
            , output v-per-ned-qnty
        ).
        assign
            v-tot-izl-sum      = v-tot-izl-sum      + v-izl-sum
            v-tot-ned-sum      = v-tot-ned-sum      + v-ned-sum
            v-tot-per-izl-sum  = v-tot-per-izl-sum  + v-per-izl-sum
            v-tot-per-ned-sum  = v-tot-per-ned-sum  + v-per-ned-sum
            v-tot-izl-qnty     = v-tot-izl-qnty     + v-izl-qnty
            v-tot-ned-qnty     = v-tot-ned-qnty     + v-ned-qnty
            v-tot-per-izl-qnty = v-tot-per-izl-qnty + v-per-izl-qnty
            v-tot-per-ned-qnty = v-tot-per-ned-qnty + v-per-ned-qnty
        .
    end.        /* for each buf_doc-line */

    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_rezIzlSum}    , input string( v-tot-izl-sum  ) ).
    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_rezNedSum}    , input string( v-tot-ned-sum  ) ).
    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_rezIzlQnty}   , input string( v-tot-izl-Qnty ) ).
    run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_rezNedQnty}   , input string( v-tot-ned-Qnty ) ).

    if lookup( 'L-Rus' , v-sys-key) > 0
    then do:
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_utochIzlSum}  , input string( 0                  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_utochNedSum}  , input string( 0                  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_peresIzlSum}  , input string( v-tot-per-izl-sum  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_peresNedSum}  , input string( v-tot-per-ned-sum  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endIzlSum}    , input string( v-tot-izl-sum      ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endNedSum1}   , input string( v-tot-ned-sum      ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endNedSum2}   , input string( 0                  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endNedSum3}   , input string( 0                  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_utochIzlQnty} , input string( 0                  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_utochNedQnty} , input string( 0                  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_peresIzlQnty} , input string( v-tot-per-izl-Qnty ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_peresNedQnty} , input string( v-tot-per-ned-Qnty ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endIzlQnty}   , input string( v-tot-izl-Qnty     ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endNedQnty1}  , input string( v-tot-ned-Qnty     ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endNedQnty2}  , input string( 0                  ) ).
      run inv19xl-write-cell-data in this-procedure ( input {&inv19xl-sheet1-it_endNedQnty3}  , input string( 0                  ) ).
    end.

    run inv19xl-close in this-procedure .

    { gbl/stopwork.i }

    output stream out-stream close.

    { rep/q-print.i 8}

end.


/*==========================================================================*/
procedure print-line :
define input parameter p-doc-code       as character        no-undo.
define input parameter p-artic          as character        no-undo.
define input parameter p-prod-type      as character        no-undo.
define input parameter p-prod-code      as integer          no-undo.
define output parameter p-izl-sum       as decimal          no-undo.
define output parameter p-ned-sum       as decimal          no-undo.
define output parameter p-per-izl-sum   as decimal          no-undo.
define output parameter p-per-ned-sum   as decimal          no-undo.
define output parameter p-izl-qnty       as decimal          no-undo.
define output parameter p-ned-qnty       as decimal          no-undo.
define output parameter p-per-izl-qnty   as decimal          no-undo.
define output parameter p-per-ned-qnty   as decimal          no-undo.

    define variable v-per-price         as decimal   no-undo.
    define variable v-inv-peresort-qnty as decimal   no-undo.
    define variable v-gds-name          as character no-undo .

    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_goods         for ub.goods.
    define buffer buf_units         for ub.units.
    define buffer buf_doc-line-sum  for ub.doc-line-sum.
    define buffer buf_gds-dtl       for ub.gds-dtl.
do
for buf_doc-line
  , buf_goods
  , buf_units
  , buf_doc-line-sum
  , buf_gds-dtl
on error undo, return error
:
    find first buf_doc-line no-lock
         where buf_doc-line.doc-code   = p-doc-code
           and buf_doc-line.artic      = p-artic
           and buf_doc-line.prod-type  = p-prod-type
           and buf_doc-line.prod-code  = p-prod-code
    .
    /* В документ входят только строки с изменениями */
    if buf_doc-line.fact-qnty = 0
    then do:
      return . /* --->>>--- */
    end.
    assign
        v-inv19-line-counter = v-inv19-line-counter + 1
    .
    find first buf_goods no-lock
         where buf_goods.artic      = p-artic
           and buf_goods.prod-type  = p-prod-type
           and buf_goods.prod-code  = p-prod-code
    .
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    .
    find first buf_doc-line-sum no-lock
         where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
           and buf_doc-line-sum.gds-code = buf_goods.gds-code
           and buf_doc-line-sum.sum-type = {&sum-general-doc}
    no-error.
    if available buf_doc-line-sum
    then do:
        if buf_doc-line-sum.fact-qnty >= 0
        then do:
            assign
                p-izl-qnty = buf_doc-line-sum.fact-qnty
                p-ned-qnty = 0.0
            .
            if costprice = yes
            then do:
                if no-vat = no then do:
                if PrintRubl = yes
                then do:
                    assign
                        p-izl-sum  = buf_doc-line-sum.cost-sum-rubl
                        p-ned-sum  = 0.0
                    .
                end.
                else do:
                    assign
                        p-izl-sum  = buf_doc-line-sum.cost-sum-base
                        p-ned-sum  = 0.0
                    .
                end.

                end.
                else do:
                if PrintRubl = yes
                then do:
                    assign
                        p-izl-sum  = buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl
                        p-ned-sum  = 0.0
                    .
                end.
                else do:
                    assign
                        p-izl-sum  = buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base
                        p-ned-sum  = 0.0
                    .
                end.

                end.        
            end.
            else do:
                if PrintRubl = yes
                then do:
                    assign
                        p-izl-sum  = buf_doc-line-sum.sale-sum-rubl
                        p-ned-sum  = 0.0
                    .
                end.
                else do:
                    assign
                        p-izl-sum  = buf_doc-line-sum.sale-sum-base
                        p-ned-sum  = 0.0
                    .
                end.
            end.
        end.
        else do:
            assign
                p-izl-qnty = 0.0
                p-ned-qnty = (-1) * buf_doc-line-sum.fact-qnty
            .
            if costprice = yes
            then do:
                if no-vat = no then do:
                    if PrintRubl = yes
                    then do:
                        assign
                            p-izl-sum  = 0.0
                            p-ned-sum  = -1.0 * buf_doc-line-sum.cost-sum-rubl
                        .
                    end.
                    else do:
                        assign
                            p-izl-sum  = 0.0
                            p-ned-sum  = -1.0 * buf_doc-line-sum.cost-sum-base
                        .
                    end.
                 end.   
                else do:
                    if PrintRubl = yes
                    then do:
                        assign
                            p-izl-sum  = 0.0
                            p-ned-sum  = -1.0 * (buf_doc-line-sum.cost-sum-rubl - buf_doc-line-sum.cost-VAT-rubl)
                        .
                    end.
                    else do:
                        assign
                            p-izl-sum  = 0.0
                            p-ned-sum  = -1.0 * (buf_doc-line-sum.cost-sum-base - buf_doc-line-sum.cost-VAT-base)
                        .
                    end.
                 end.
            end.
            else do:
                if PrintRubl = yes
                then do:
                    assign
                        p-izl-sum  = 0.0
                        p-ned-sum  = -1.0 * buf_doc-line-sum.sale-sum-rubl
                    .
                end.
                else do:
                    assign
                        p-izl-sum  = 0.0
                        p-ned-sum  = -1.0 * buf_doc-line-sum.sale-sum-base
                    .
                end.
            end.
        end.
    end.
    else do:
        if costprice = yes
        then do:
            if PrintRubl = yes
            then do:
                if buf_doc-line.fact-qnty >= 0
                then do:
                    assign
                        p-izl-qnty = buf_doc-line.fact-qnty
                        p-ned-qnty = 0.0
                        p-izl-sum  = buf_doc-line.price-rubl * buf_doc-line.fact-qnty.
                        p-ned-sum  = 0.0
                    .
                end.
                else do:
                    assign
                        p-izl-qnty = 0.0
                        p-ned-qnty = -1.0 * buf_doc-line.fact-qnty
                        p-izl-sum  = 0.0
                        p-ned-sum  = -1.0 * buf_doc-line.price-rubl * buf_doc-line.fact-qnty.
                    .
                end.
            end.
            else do:
                if buf_doc-line.fact-qnty >= 0
                then do:
                    assign
                        p-izl-qnty = buf_doc-line.fact-qnty
                        p-ned-qnty = 0.0
                        p-izl-sum  = buf_doc-line.price-base * buf_doc-line.fact-qnty.
                        p-ned-sum  = 0.0
                    .
                end.
                else do:
                    assign
                        p-izl-qnty = 0.0
                        p-ned-qnty = -1.0 * buf_doc-line.fact-qnty
                        p-izl-sum  = 0.0
                        p-ned-sum  = -1.0 * buf_doc-line.price-base * buf_doc-line.fact-qnty.
                    .
                end.
            end.
        end.        /* if costprice = yes  */
        else do:
            assign
                p-izl-qnty  = 0.0
                p-izl-sum   = 0.0
                p-ned-qnty  = 0.0
                p-ned-sum   = 0.0
            .
            for each buf_gds-dtl no-lock
                where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
                    and buf_gds-dtl.artic     = buf_doc-line.artic
                    and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                    and buf_gds-dtl.prod-code = buf_doc-line.prod-code
            :
                if buf_gds-dtl.doc-qnty >= 0
                then do:
                    assign
                        p-izl-qnty  = p-izl-qnty + buf_gds-dtl.doc-qnty
                        p-izl-sum   = p-izl-sum  + ( if PrintRubl = yes then  buf_gds-dtl.price-rubl else buf_gds-dtl.price-base ) * buf_gds-dtl.doc-qnty
                        p-ned-qnty  = 0.0
                        p-ned-sum   = 0.0
                    .
                end.
                else do:
                    assign
                        p-izl-qnty  = 0.0
                        p-izl-sum   = 0.0
                        p-ned-qnty  = p-ned-qnty + ( -1.0 * buf_gds-dtl.doc-qnty )
                        p-ned-sum   = p-ned-sum  + ( -1.0 * ( if PrintRubl = yes then  buf_gds-dtl.price-rubl else buf_gds-dtl.price-base ) * buf_gds-dtl.doc-qnty )
                    .
                end.
            end.
        end.        /* NOT ( if costprice = yes  ) */
    end.
    assign
        v-per-price     = 0.0
    .
    assign
        v-per-price = ( if p-izl-qnty = 0
                        then (  if p-ned-qnty = 0
                                then 0
                                else p-ned-sum / p-ned-qnty )
                        else p-izl-sum / p-izl-qnty )
        v-inv-peresort-qnty = buf_doc-line.inv-peresort-qnty
    .
    if v-inv-peresort-qnty >= 0
    then do:
        assign
            p-per-izl-qnty  = v-inv-peresort-qnty
            p-per-izl-sum   = v-per-price * v-inv-peresort-qnty
            p-per-ned-qnty  = 0.0
            p-per-ned-sum   = 0.0
        .
    end.
    else do:
        assign
            p-per-izl-qnty = 0.0
            p-per-izl-sum  = 0.0
            p-per-ned-qnty = -1.0 * v-inv-peresort-qnty
            p-per-ned-sum  = -1.0 * v-per-price * v-inv-peresort-qnty
        .
    end.
    assign
      v-gds-name = substitute( "&1 &2"
                             , buf_goods.artic
                             , buf_goods.gds-name
                             )
    .

    if lookup( 'L-Rus' , v-sys-key) > 0
    then do:
      run inv19xl-sheet1-write-line-data in this-procedure (
            input string( v-inv19-line-counter    )               /* p-num         */
          , input v-gds-name                                      /* p-gdsname     */
          , input string( buf_goods.gds-code      )               /* p-gdscode     */
          , input string( buf_units.OKEI          )               /* p-OKEI        */
          , input string( buf_goods.unit-base     )               /* p-EI          */
          , input string( buf_goods.OKDP          )               /* p-OKDP        */
          , input string( p-izl-qnty              )               /* p-rezIzlQnty  */
          , input string( p-izl-sum               )               /* p-rezIzlSum   */
          , input string( p-ned-qnty              )               /* p-rezNedQnty  */
          , input string( p-ned-sum               )               /* p-rezNedSum   */
          , input string( v-inv19-line-counter    )               /* p-num2        */
          , input "":U                                            /* p-utochIzlQnty*/
          , input "":U                                            /* p-utochIzlSum */
          , input "":U                                            /* p-utochNedQnty*/
          , input "":U                                            /* p-utochNedSum */
          , input string( p-per-izl-qnty           )              /* p-peresIzlQnty*/
          , input string( p-per-izl-sum            )              /* p-peresIzlSum */
          , input string( p-per-ned-qnty           )              /* p-peresNedQnty*/
          , input string( p-per-ned-sum            )              /* p-peresNedSum */
          , input string( p-izl-qnty               )              /* p-endIzlQnty  */
          , input string( p-izl-sum                )              /* p-endIzlSum   */
          , input string( p-ned-qnty               )              /* p-endNedQnty1 */
          , input string( p-ned-sum                )              /* p-endNedSum1  */
          , input "":U                                            /* p-endNedQnty2 */
          , input "":U                                            /* p-endNedSum2  */
          , input "":U                                            /* p-endNedQnty3 */
          , input "":U                                            /* p-endNedSum3  */
      ).
    end.
    else do:
      run inv19xl-sheet1-write-line-data in this-procedure (
            input string( v-inv19-line-counter    )               /* p-num         */
          , input v-gds-name                                      /* p-gdsname     */
          , input string( buf_goods.gds-code      )               /* p-gdscode     */
          , input string( buf_units.OKEI          )               /* p-OKEI        */
          , input string( buf_goods.unit-base     )               /* p-EI          */
          , input string( buf_goods.OKDP          )               /* p-OKDP        */
          , input trim(string( p-izl-qnty , {&qnty-format} ))     /* p-rezIzlQnty  */
          , input string( p-izl-sum               )               /* p-rezIzlSum   */
          , input trim(string( p-ned-qnty , {&qnty-format} ))     /* p-rezNedQnty  */
          , input string( p-ned-sum               )               /* p-rezNedSum   */
          , input string( v-inv19-line-counter    )               /* p-num2        */
          , input "":U                                            /* p-utochIzlQnty*/
          , input "":U                                            /* p-utochIzlSum */
          , input "":U                                            /* p-utochNedQnty*/
          , input "":U                                            /* p-utochNedSum */
          , input "":U                                            /* p-peresIzlQnty*/
          , input "":U                                            /* p-peresIzlSum */
          , input "":U                                            /* p-peresNedQnty*/
          , input "":U                                            /* p-peresNedSum */
          , input "":U                                            /* p-endIzlQnty  */
          , input "":U                                            /* p-endIzlSum   */
          , input "":U                                            /* p-endNedQnty1 */
          , input "":U                                            /* p-endNedSum1  */
          , input "":U                                            /* p-endNedQnty2 */
          , input "":U                                            /* p-endNedSum2  */
          , input "":U                                            /* p-endNedQnty3 */
          , input "":U                                            /* p-endNedSum3  */
      ).
    end.
end.
end procedure. /* print-line */


/*==========================================================================*/
procedure check-doc-sum :
define input parameter p-trn-doc-code   as character        no-undo.

    define variable v-attr-value as character no-undo .
    define variable v-attr-type as character no-undo .
do
on error undo, return error
:
/*Убрала , чтобы пересчитывалась*/
/*   { str/tdat-val.i                                  */
/*        p-trn-doc-code                               */
/*        {&trdcattr-addsum}                           */
/*        v-attr-value                                 */
/*        v-attr-type                                  */
/*    }                                                */
/*    if lookup( {&sum-general-doc}, v-attr-value ) = 0*/
/*    or lookup( {&sum-wastage-doc}, v-attr-value ) = 0*/
/*    then do:                                         */
        run utl/uaddsum.p (
              input p-trn-doc-code
            , input yes
            , input yes
            , input no
        ) no-error .
        if error-status :error
        then do:
            message
                     vss-workfile vss-revision vss-description
                skip(1)
                skip "ошибка расчёта сумм инвентаризации."
                skip return-value
                skip trim( error-status :get-message( 1 ) )
                     trim( error-status :get-message( 2 ) )
                     trim( error-status :get-message( 3 ) )
            view-as alert-box error.
            undo, return error.
        end.
/*    end.*/
end.
end procedure. /* check-doc-sum */