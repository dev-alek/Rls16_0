block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthob.p $
$Archive: rep/r-wthob.p $

Отчёт Оборотная ведомость по матценностям

Автор: Демин Алексей Сергеевич
Дата создания: 09/06/07
Author: Alexey Demin
Creation date: 09/06/07

Input:

Output:

*/
define temp-table temp_goods no-undo
    field gds-code  as integer
    field gds-name  as character

    index pi is primary unique
        gds-code
.
define temp-table temp_wthPar no-undo
    field par-code   as integer

    index pi is primary unique
        par-code
.
define temp-table temp_hideCol no-undo
    field colName   as character

    index pi is primary unique
        colName
.
define stream out-stream.

define input parameter p-begin-date         as date             no-undo.
define input parameter p-end-date           as date             no-undo.
define input parameter p-begin-shift        as integer          no-undo.
define input parameter p-end-shift          as integer          no-undo.
define input parameter p-obj-selection-type as character        no-undo.
define input parameter p-ext-doc-type-list  as character        no-undo.
define input parameter p-detal              as logical          no-undo.
define input parameter p-ob-liter           as logical          no-undo.
define input parameter p-ob-rubl            as logical          no-undo.
define input parameter p-ob-tal             as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthob.p $":U .
define variable vss-description as character no-undo init "Отчёт Оборотная ведомость по матценностям".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/r-pril.i new }
{ cmp/r-page1.i    }
{ gbl/cur-time.i   }
{ gbl/prn-lib.i    }
{ gbl/paramls.i    }
{ trg/factord.i    }
{ gbl/shiftfo.i    }

define variable g#report-num              as integer              no-undo .
run get-report-num in my-handle (output g#report-num).
{ rep/rwthobxl.i   }


    define variable v-obj-list-string   as character    no-undo.
    define variable v-date-from         as date         no-undo.
    define variable v-date-to           as date         no-undo.
    define variable v-date-string       as character    no-undo.
    define variable v-date-from-string  as character    no-undo.
    define variable v-date-to-string    as character    no-undo.
    define variable v-ext-doc-type-list as character    no-undo.
    define variable v-counter           as integer      no-undo.
    define variable v-fact-order-start  as decimal      no-undo.
    define variable v-fact-order-end    as decimal      no-undo.

    define variable v-hide-list         as character    no-undo.

    define buffer buf_clients               for ub.clients.
    define buffer buf_obj-list              for obj-list.
    define buffer buf_temp_shiftfo_obj-list for temp_shiftfo_obj-list.
do
for buf_clients
  , buf_obj-list
  , buf_temp_shiftfo_obj-list
on error undo, return error
:
    { gbl/working.i }

    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    output stream out-stream close.

    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    run rwthobxl-init in this-procedure.

    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1-datePrint}
        , input cur-time-string()
    ).
    run get-hide-list in this-procedure (
          input p-ext-doc-type-list
        , input p-ob-liter
        , input p-ob-rubl
        , input p-ob-tal
        , output v-hide-list
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet2_hideColList}
        , input v-hide-list
    ).
    run write-stLtRbList in this-procedure (
          input p-ob-tal
        , input p-ob-liter
        , input p-ob-rubl
    ).
    find first buf_obj-list
    no-error.
    if not available buf_obj-list
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Список объектов пуст."
        view-as alert-box error.
        undo, return error.
    end.
    case p-obj-selection-type
    :
        when "{&o-firm}"
        then do:
            assign
                v-obj-list-string = substitute( "Все по фирме: &1", buf_obj-list.obj-name )
            .
        end.        /* when {&o-firm} */
        when "{&o-currency}"
        then do:
            assign
                v-obj-list-string = substitute( "Текущий объект: &1", buf_obj-list.obj-name )
            .
        end.        /* when {&o-currency} */
        otherwise do:
            assign
                v-obj-list-string = ""
            .
            for each buf_obj-list
            on error undo, return error
            :
                assign
                    v-obj-list-string = substitute( "&1&2 &3"
                                            , v-obj-list-string
                                            , ( if v-obj-list-string = "" then "" else "," )
                                            , buf_obj-list.obj-name )
                .
            end.
        end.        /* otherwise */
    end case.       /* case p-obj-selection-type */
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1-objList}
        , input v-obj-list-string
    ).
    for each buf_obj-list
    on error undo, return error
    :
        create buf_temp_shiftfo_obj-list.
        assign
            buf_temp_shiftfo_obj-list.obj-type = buf_obj-list.obj-type
            buf_temp_shiftfo_obj-list.obj-code = buf_obj-list.obj-code
        .
    end.
    run fill-temp_shiftfo_fo-range in this-procedure (
          input x-Radio-Task
        , input x-Date-Start
        , input x-Date-End
        , input x-Shift-Start
        , input x-Shift-End
        , input x-Shift-Alone
        , output v-date-string
        , output v-date-from-string
        , output v-date-to-string
    ).
     ASSIGN
        v-date-string       = substitute( "с &1 по &2", v-date-from-string, v-date-to-string )
    .
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1-dateString}
        , input v-date-string
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet2-dateString}
        , input v-date-string
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1-dateFromString}
        , input v-date-from-string
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet3-dateToString}
        , input v-date-to-string
    ).

    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1-detail}
        , input ( if p-detal = yes then "есть" else "нет" )
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1-detail}
        , input ( if p-detal = yes then "есть" else "нет" )
    ).
    if p-ext-doc-type-list = "":U
    then do:
        assign
            v-ext-doc-type-list = "все"
        .
    end.
    else do:
        do v-counter = 1 to num-entries( p-ext-doc-type-list )
        on error undo, return error
        :
            assign
                v-ext-doc-type-list = substitute( "&1&2&3"
                                            , v-ext-doc-type-list
                                            , ( if v-ext-doc-type-list = "":U then "":U else ", ":U )
                                            , entry( v-counter, {&WDEDT_List-full} ) )
            .
        end.        /* do */
    end.
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1-extDocTypeList}
        , input v-ext-doc-type-list
    ).
    for each temp_shiftfo_fo-range
    :
        run fill-temp-tables in this-procedure (
              input temp_shiftfo_fo-range.obj-type
            , input temp_shiftfo_fo-range.obj-code
            , input temp_shiftfo_fo-range.fact-order-from
            , input temp_shiftfo_fo-range.fact-order-to
        ).
    end.
    run rwthobxl-sheet1-write-line-data in this-procedure .
    run rwthobxl-sheet2-write-line-data in this-procedure .
    run rwthobxl-sheet3-write-line-data in this-procedure .

    run rwthobxl-close in this-procedure .
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
    os-rename
        value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
        value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
    .
    { gbl/stopwork.i }
    /* печатаем */
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w (
          input "":U
        , input 8
        , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
        , input ReportFontNum
        , output v-user-action
        , output v-printed
    ).
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
end.

/*==========================================================================*/
procedure fill-temp-tables :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-fact-order-from    as decimal          no-undo.
define input parameter p-fact-order-to      as decimal          no-undo.

    define variable v-counter           as integer      no-undo.
    define variable v-counter-sum-type  as integer      no-undo.
    define variable v-sum-type          as character    no-undo.
    define variable v-ext-doc-type          as character    no-undo.

    define buffer buf_wealth        for ub.wealth.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_obj-list      for obj-list.
do
for buf_wealth
  , buf_wth-par
  , buf_obj-list
on error undo, return error
:
    for each buf_wealth no-lock
        where buf_wealth.is-ser = 1
    on error undo, return error
    :
        for each buf_wth-par no-lock
            where buf_wth-par.wth-code = buf_wealth.wth-code
        on error undo, return error
        :
            loop-sum-type:
            do v-counter-sum-type = 1 to num-entries( {&expense_income_return_write-off} )
            on error undo, return error
            :
                assign
                    v-sum-type = entry( v-counter-sum-type, {&expense_income_return_write-off} )
                .
                loop-ext-type:
                do v-counter = 1 to num-entries( {&WDEDT_List} )
                on error undo, return error
                :
                    assign
                        v-ext-doc-type = entry( v-counter, {&WDEDT_List} )
                    .
                    if ( v-sum-type = {&income}
                    and lookup( v-ext-doc-type, {&WDEDT_List-Income} ) <> 0 )
                    or ( v-sum-type = {&return}
                    and lookup( v-ext-doc-type, {&WDEDT_List-return} ) <> 0 )
                    or ( v-sum-type = {&expense}
                    and lookup( v-ext-doc-type, {&WDEDT_List-expense} ) <> 0 )
                    or ( v-sum-type = {&write-off}
                    and lookup( v-ext-doc-type, {&WDEDT_List-write-off} ) <> 0 )
                    or ( lookup( v-sum-type, {&expense_income} ) <> 0
                    and v-ext-doc-type = {&WDEDT_exch} )
                    then do:
                        run fill-temp-tables-by-doc-type in this-procedure (
                              input p-obj-type
                            , input p-obj-code
                            , input buf_wealth.wth-code
                            , input buf_wth-par.par-code
                            , input v-ext-doc-type
                            , input v-sum-type
                            , input p-fact-order-from
                            , input p-fact-order-to
                            , input buf_wth-par.par-val
                        ).
                    end.
                end.        /* do */
            end.        /* do */
        end.
    end.
end.
end procedure. /* fill-temp-tables */

/*==========================================================================*/
procedure fill-temp-tables-by-doc-type :
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-wth-code           as integer          no-undo.
define input parameter p-par-code           as integer          no-undo.
define input parameter p-ext-doc-type       as character        no-undo.
define input parameter p-sum-type           as character        no-undo.
define input parameter p-fact-order-from    as decimal          no-undo.
define input parameter p-fact-order-to      as decimal          no-undo.
define input parameter p-par-val            as decimal          no-undo.

    define variable v-incIncmSt          as decimal      no-undo.
    define variable v-incIncmLt          as decimal      no-undo.
    define variable v-incRetnSt          as decimal      no-undo.
    define variable v-incRetnLt          as decimal      no-undo.
    define variable v-outSaleSt          as decimal      no-undo.
    define variable v-outSaleLt          as decimal      no-undo.
    define variable v-outSaleRb          as decimal      no-undo.
    define variable v-outExchSt          as decimal      no-undo.
    define variable v-outExchLt          as decimal      no-undo.
    define variable v-outExchRb          as decimal      no-undo.
    define variable v-payPaydDeskSt      as decimal      no-undo.
    define variable v-payPaydDeskLt      as decimal      no-undo.
    define variable v-payPaydDeskRb      as decimal      no-undo.
    define variable v-payPaydSt          as decimal      no-undo.
    define variable v-payPaydLt          as decimal      no-undo.
    define variable v-payPaydRb          as decimal      no-undo.
    define variable v-payExchSt          as decimal      no-undo.
    define variable v-payExchLt          as decimal      no-undo.
    define variable v-payExchRb          as decimal      no-undo.
    define variable v-payRetnSt          as decimal      no-undo.
    define variable v-payRetnLt          as decimal      no-undo.
    define variable v-payRetnRb          as decimal      no-undo.
    define variable v-clrRealSt          as decimal      no-undo.
    define variable v-clrRealLt          as decimal      no-undo.
    define variable v-clrRealRb          as decimal      no-undo.
    define variable v-clrPOffSt          as decimal      no-undo.
    define variable v-clrPOffLt          as decimal      no-undo.
    define variable v-clrPOffRb          as decimal      no-undo.
    define variable v-trsRealExpsSt      as decimal      no-undo.
    define variable v-trsRealExpsLt      as decimal      no-undo.
    define variable v-trsRealIncmSt      as decimal      no-undo.
    define variable v-trsRealIncmLt      as decimal      no-undo.
    define variable v-trsRealTrnsSt      as decimal      no-undo.
    define variable v-trsRealTrnsLt      as decimal      no-undo.
    define variable v-trsPOffExpsSt      as decimal      no-undo.
    define variable v-trsPOffExpsLt      as decimal      no-undo.
    define variable v-trsPOffExpsRb      as decimal      no-undo.
    define variable v-trsPOffIncmSt      as decimal      no-undo.
    define variable v-trsPOffIncmLt      as decimal      no-undo.
    define variable v-trsPOffIncmRb      as decimal      no-undo.
    define variable v-trsPOffTrnsSt      as decimal      no-undo.
    define variable v-trsPOffTrnsLt      as decimal      no-undo.
    define variable v-trsPOffTrnsRb      as decimal      no-undo.

    define variable v-stkRealSt          as decimal      no-undo.
    define variable v-stkPOffSt          as decimal      no-undo.
    define variable v-stkRealLt          as decimal      no-undo.
    define variable v-stkPOffLt          as decimal      no-undo.
    define variable v-stkRealRb          as decimal      no-undo.
    define variable v-stkPOffRb          as decimal      no-undo.

    define variable v-arh-exists         as logical      no-undo.

    define variable v-sum-St-start    as decimal      no-undo.
    define variable v-sum-Lt-start    as decimal      no-undo.
    define variable v-sum-Rb-start    as decimal      no-undo.
    define variable v-sum-St-end      as decimal      no-undo.
    define variable v-sum-Lt-end      as decimal      no-undo.
    define variable v-sum-Rb-end      as decimal      no-undo.

    define buffer buf_arh-wth-tot       for ub.arh-wth-tot.
do
for buf_arh-wth-tot
on error undo, return error
:
    assign
        v-sum-St-start = 0.0
        v-sum-Lt-start = 0.0
        v-sum-Rb-start = 0.0
    .
    find last buf_arh-wth-tot
        where buf_arh-wth-tot.obj-type       = p-obj-type
          and buf_arh-wth-tot.obj-code       = p-obj-code
          and buf_arh-wth-tot.wth-code       = p-wth-code
          and buf_arh-wth-tot.par-code       = p-par-code
          and buf_arh-wth-tot.ext-doc-type   = p-ext-doc-type
          and buf_arh-wth-tot.sum-type       = p-sum-type
          and buf_arh-wth-tot.fact-order    <= p-fact-order-from
    use-index pi
    no-error.
    if available buf_arh-wth-tot
    then do:
        assign
            v-sum-St-start = buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty
            v-sum-Lt-start = ( buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty ) * p-par-val
            v-sum-Rb-start = buf_arh-wth-tot.in-sum-rubl - buf_arh-wth-tot.out-sum-rubl
        .
    end.
    assign
        v-sum-St-end   = 0.0
        v-sum-Lt-end   = 0.0
        v-sum-Rb-end   = 0.0
    .
    find last buf_arh-wth-tot
        where buf_arh-wth-tot.obj-type       = p-obj-type
          and buf_arh-wth-tot.obj-code       = p-obj-code
          and buf_arh-wth-tot.wth-code       = p-wth-code
          and buf_arh-wth-tot.par-code       = p-par-code
          and buf_arh-wth-tot.ext-doc-type   = p-ext-doc-type
          and buf_arh-wth-tot.sum-type       = p-sum-type
          and buf_arh-wth-tot.fact-order    <= p-fact-order-to
    use-index pi
    no-error.
    if available buf_arh-wth-tot
    then do:
        assign
            v-sum-St-end   = buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty
            v-sum-Lt-end   = ( buf_arh-wth-tot.in-qnty - buf_arh-wth-tot.out-qnty ) * p-par-val
            v-sum-Rb-end   = buf_arh-wth-tot.in-sum-rubl - buf_arh-wth-tot.out-sum-rubl
        .
    end.
    run rwthobxl-sheet1-add-line-data in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-wth-code
        , input p-par-code
        , input p-ext-doc-type
        , input p-sum-type
        , input v-sum-St-start
        , input v-sum-Lt-start
        , input v-sum-Rb-start
    ).
    run rwthobxl-sheet3-add-line-data in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-wth-code
        , input p-par-code
        , input p-ext-doc-type
        , input p-sum-type
        , input v-sum-St-end
        , input v-sum-Lt-end
        , input v-sum-Rb-end
    ).
    assign
        v-incIncmSt     = 0.0
        v-incIncmLt     = 0.0
        v-incRetnSt     = 0.0
        v-incRetnLt     = 0.0
        v-outSaleSt     = 0.0
        v-outSaleLt     = 0.0
        v-outSaleRb     = 0.0
        v-outExchSt     = 0.0
        v-outExchLt     = 0.0
        v-outExchRb     = 0.0
        v-payPaydDeskSt = 0.0
        v-payPaydDeskLt = 0.0
        v-payPaydDeskRb = 0.0
        v-payPaydSt     = 0.0
        v-payPaydLt     = 0.0
        v-payPaydRb     = 0.0
        v-payExchSt     = 0.0
        v-payExchLt     = 0.0
        v-payExchRb     = 0.0
        v-payRetnSt     = 0.0
        v-payRetnLt     = 0.0
        v-payRetnRb     = 0.0
        v-clrRealSt     = 0.0
        v-clrRealLt     = 0.0
        v-clrRealRb     = 0.0
        v-clrPOffSt     = 0.0
        v-clrPOffLt     = 0.0
        v-clrPOffRb     = 0.0
        v-trsRealExpsSt = 0.0
        v-trsRealExpsLt = 0.0
        v-trsRealIncmSt = 0.0
        v-trsRealIncmLt = 0.0
        v-trsRealTrnsSt = 0.0
        v-trsRealTrnsLt = 0.0
        v-trsPOffExpsSt = 0.0
        v-trsPOffExpsLt = 0.0
        v-trsPOffExpsRb = 0.0
        v-trsPOffIncmSt = 0.0
        v-trsPOffIncmLt = 0.0
        v-trsPOffIncmRb = 0.0
        v-trsPOffTrnsSt = 0.0
        v-trsPOffTrnsLt = 0.0
        v-trsPOffTrnsRb = 0.0
    .
    case p-ext-doc-type
    :
        when {&WDEDT_Inc_Ext}
        then do:
            assign
                v-incIncmSt = v-sum-St-end - v-sum-St-start
                v-incIncmLt = v-sum-Lt-end - v-sum-Lt-start
            .
        end.        /* when {&WDEDT_Inc_Ext} */
        when {&WDEDT_Exp_Ext}
        then do:
            assign
                v-outSaleSt = - ( v-sum-St-end - v-sum-St-start )
                v-outSaleLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-outSaleRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.        /* when {&WDEDT_Exp_Ext} */
        when {&WDEDT_Put_Cash}
        then do:
            assign
                v-payPaydDeskSt = v-sum-St-end - v-sum-St-start
                v-payPaydDeskLt = v-sum-Lt-end - v-sum-Lt-start
                v-payPaydDeskRb = v-sum-Rb-end - v-sum-Rb-start
            .
        end.        /* when {&WDEDT_Put_Cash} */
        when {&WDEDT_Put_Sale}
        then do:
            assign
                v-payPaydSt     = v-sum-St-end - v-sum-St-start
                v-payPaydLt     = v-sum-Lt-end - v-sum-Lt-start
                v-payPaydRb     = v-sum-Rb-end - v-sum-Rb-start
            .
        end.        /* when {&WDEDT_Put_Sale} */
        when {&WDEDT_Put_Cli}
        then do:
            assign
                v-payRetnSt     = v-sum-St-end - v-sum-St-start
                v-payRetnLt     = v-sum-Lt-end - v-sum-Lt-start
                v-payRetnRb     = v-sum-Rb-end - v-sum-Rb-start
            .
        end.        /* when {&WDEDT_Put_Sale} */
        when {&WDEDT_Dst_free}
        then do:
            assign
                v-clrRealSt = - ( v-sum-St-end - v-sum-St-start )
                v-clrRealLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-clrRealRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.        /* when {&WDEDT_Dst_free} */
        when {&WDEDT_Dst_Put}
        then do:
            assign
                v-clrPOffSt = - ( v-sum-St-end - v-sum-St-start )
                v-clrPOffLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-clrPOffRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.        /* when {&WDEDT_Dst_free} */
        when {&WDEDT_Inc_Int_Put}
        then do:
            assign
                v-trsPOffIncmSt =  ( v-sum-St-end - v-sum-St-start )
                v-trsPOffIncmLt =  ( v-sum-Lt-end - v-sum-Lt-start )
                v-trsPOffIncmRb =  ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.        /* when {&WDEDT_Inc_Int_Put} */
        when {&WDEDT_Exp_Int_Put}
        then do:
            assign
                v-trsPOffExpsSt = - ( v-sum-St-end - v-sum-St-start )
                v-trsPOffExpsLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                v-trsPOffExpsRb = - ( v-sum-Rb-end - v-sum-Rb-start )
            .
        end.        /* when {&WDEDT_Exp_Int_Put} */
        when {&WDEDT_Ret_Int_Put}
        then do:
            assign
                v-trsPOffTrnsSt = v-sum-St-end - v-sum-St-start
                v-trsPOffTrnsLt = v-sum-Lt-end - v-sum-Lt-start
                v-trsPOffTrnsRb = v-sum-Rb-end - v-sum-Rb-start
            .
        end.        /* when {&WDEDT_Ret_Int_Put} */
        when {&WDEDT_Inc_Int_Free}
        then do:
            assign
                v-trsRealIncmSt = v-sum-St-end - v-sum-St-start
                v-trsRealIncmLt = v-sum-Lt-end - v-sum-Lt-start
            .
        end.        /* when {&WDEDT_Inc_Int_Free} */
        when {&WDEDT_Exp_Int_Free}
        then do:
            assign
                v-trsRealExpsSt = - ( v-sum-St-end - v-sum-St-start )
                v-trsRealExpsLt = - ( v-sum-Lt-end - v-sum-Lt-start )
            .
        end.        /* when {&WDEDT_Exp_Int_Free} */
        when {&WDEDT_Ret_Int_Free}
        then do:
            assign
                v-trsRealTrnsSt = v-sum-St-end - v-sum-St-start
                v-trsRealTrnsLt = v-sum-Lt-end - v-sum-Lt-start
            .
        end.        /* when {&WDEDT_Ret_Int_Free} */
        when {&WDEDT_exch}
        then do:
            if p-sum-type = {&income}
            then do:
                assign
                    v-payExchSt = v-sum-St-end - v-sum-St-start
                    v-payExchLt = v-sum-Lt-end - v-sum-Lt-start
                    v-payExchRb = v-sum-Rb-end - v-sum-Rb-start
                .
            end.
            else do:
                assign
                    v-outExchSt = - ( v-sum-St-end - v-sum-St-start )
                    v-outExchLt = - ( v-sum-Lt-end - v-sum-Lt-start )
                    v-outExchRb = - ( v-sum-Rb-end - v-sum-Rb-start )
                .
            end.
        end.        /* when {&WDEDT_exch} */
    end case.       /* case buf_arh-wth-tot.ext-doc-type */
    run rwthobxl-sheet2-add-line-data in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-wth-code
        , input p-par-code
        , input v-incIncmSt
        , input v-incIncmLt
        , input v-incRetnSt
        , input v-incRetnLt
        , input v-outSaleSt
        , input v-outSaleLt
        , input v-outSaleRb
        , input v-outExchSt
        , input v-outExchLt
        , input v-outExchRb
        , input v-payPaydDeskSt
        , input v-payPaydDeskLt
        , input v-payPaydDeskRb
        , input v-payPaydSt
        , input v-payPaydLt
        , input v-payPaydRb
        , input v-payExchSt
        , input v-payExchLt
        , input v-payExchRb
        , input v-payRetnSt
        , input v-payRetnLt
        , input v-payRetnRb
        , input v-clrRealSt
        , input v-clrRealLt
        , input v-clrRealRb
        , input v-clrPOffSt
        , input v-clrPOffLt
        , input v-clrPOffRb
        , input v-trsRealExpsSt
        , input v-trsRealExpsLt
        , input v-trsRealIncmSt
        , input v-trsRealIncmLt
        , input v-trsRealTrnsSt
        , input v-trsRealTrnsLt
        , input v-trsPOffExpsSt
        , input v-trsPOffExpsLt
        , input v-trsPOffExpsRb
        , input v-trsPOffIncmSt
        , input v-trsPOffIncmLt
        , input v-trsPOffIncmRb
        , input v-trsPOffTrnsSt
        , input v-trsPOffTrnsLt
        , input v-trsPOffTrnsRb
    ).
end.
end procedure. /* fill-temp-tables-by-doc-type */


/*==========================================================================*/
procedure get-hide-list :
define input parameter p-ext-doc-type-list  as character        no-undo.
define input parameter p-ob-liter           as logical          no-undo.
define input parameter p-ob-rubl            as logical          no-undo.
define input parameter p-ob-tal             as logical          no-undo.
define output parameter p-hide-list         as character        no-undo.

    define variable v-counter       as integer      no-undo.
    define variable v-rec-amount    as integer      no-undo.
    define variable v-ext-doc-type  as character    no-undo.

    define buffer buf_temp_hideCol      for temp_hideCol.
do
for buf_temp_hideCol
on error undo, return error
:
    empty temp-table buf_temp_hideCol.
    if p-ob-tal = no
    then do:
        assign
            v-rec-amount =  num-entries( {&rwthobxl-sheet2_withoutSt} )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, {&rwthobxl-sheet2_withoutSt} ) ).
        end.
    end.
    if p-ob-liter = no
    then do:
        assign
            v-rec-amount =  num-entries( {&rwthobxl-sheet2_withoutLt} )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, {&rwthobxl-sheet2_withoutLt} ) ).
        end.
    end.
    if p-ob-rubl  = no
    then do:
        assign
            v-rec-amount =  num-entries( {&rwthobxl-sheet2_withoutRb} )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, {&rwthobxl-sheet2_withoutRb} ) ).
        end.
    end.
    if p-ext-doc-type-list <> "":U
    then do:
        assign
            v-rec-amount =  num-entries( {&WDEDT_List} )
        .
        do v-counter = 1 to v-rec-amount
        :
            assign
                v-ext-doc-type = entry( v-counter, {&WDEDT_List} )
            .
            if lookup( v-ext-doc-type, p-ext-doc-type-list ) = 0
            then do:
                case v-ext-doc-type
                :
                    when {&WDEDT_Inc_Ext}
                    then do:
                        run hide-list-add-item in this-procedure ( input "incIncmSt":U ).
                        run hide-list-add-item in this-procedure ( input "incIncmLt":U ).
                    end.        /* when {&WDEDT_Inc_Ext} */
                    when {&WDEDT_Exp_Ext}
                    then do:
                        run hide-list-add-item in this-procedure ( input "outSaleSt":U ).
                        run hide-list-add-item in this-procedure ( input "outSaleLt":U ).
                    end.        /* when {&WDEDT_Exp_Ext} */
                    when {&WDEDT_Put_Cash}
                    then do:
                        run hide-list-add-item in this-procedure ( input "payPaydDeskSt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydDeskLt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydDeskRb":U ).
                    end.        /* when {&WDEDT_Put_Cash} */
                    when {&WDEDT_Put_Sale}
                    then do:
                        run hide-list-add-item in this-procedure ( input "payPaydSt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydLt":U ).
                        run hide-list-add-item in this-procedure ( input "payPaydRb":U ).
                    end.        /* when {&WDEDT_Put_Sale} */
                    when {&WDEDT_Put_Cli}
                    then do:
                        run hide-list-add-item in this-procedure ( input "payRetnSt":U ).
                        run hide-list-add-item in this-procedure ( input "payRetnLt":U ).
                        run hide-list-add-item in this-procedure ( input "payRetnRb":U ).
                    end.        /* when {&WDEDT_Put_Sale} */
                    when {&WDEDT_Dst_free}
                    then do:
                        run hide-list-add-item in this-procedure ( input "clrRealSt":U ).
                        run hide-list-add-item in this-procedure ( input "clrRealLt":U ).
                        run hide-list-add-item in this-procedure ( input "clrRealRb":U ).
                    end.        /* when {&WDEDT_Dst_free} */
                    when {&WDEDT_Dst_Put}
                    then do:
                        run hide-list-add-item in this-procedure ( input "clrPOffSt":U ).
                        run hide-list-add-item in this-procedure ( input "clrPOffLt":U ).
                        run hide-list-add-item in this-procedure ( input "clrPOffRb":U ).
                    end.        /* when {&WDEDT_Dst_free} */
                    when {&WDEDT_Inc_Int_Put}
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsPOffIncmSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffIncmLt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffIncmRb":U ).
                    end.        /* when {&WDEDT_Inc_Int_Put} */
                    when {&WDEDT_Exp_Int_Put}
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsPOffExpsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffExpsLt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffExpsRb":U ).
                    end.        /* when {&WDEDT_Exp_Int_Put} */
                    when {&WDEDT_Ret_Int_Put}
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsPOffTrnsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffTrnsLt":U ).
                        run hide-list-add-item in this-procedure ( input "trsPOffTrnsRb":U ).
                    end.        /* when {&WDEDT_Ret_Int_Put} */
                    when {&WDEDT_Inc_Int_Free}
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsRealIncmSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsRealIncmLt":U ).
                    end.        /* when {&WDEDT_Inc_Int_Free} */
                    when {&WDEDT_Exp_Int_Free}
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsRealExpsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsRealExpsLt":U ).
                    end.        /* when {&WDEDT_Exp_Int_Free} */
                    when {&WDEDT_Ret_Int_Free}
                    then do:
                        run hide-list-add-item in this-procedure ( input "trsRealTrnsSt":U ).
                        run hide-list-add-item in this-procedure ( input "trsRealTrnsLt":U ).
                    end.        /* when {&WDEDT_Ret_Int_Free} */
                    when {&WDEDT_exch}
                    then do:
                        run hide-list-add-item in this-procedure ( input "payExchSt":U ).
                        run hide-list-add-item in this-procedure ( input "payExchLt":U ).
                        run hide-list-add-item in this-procedure ( input "payExchRb":U ).
                        run hide-list-add-item in this-procedure ( input "outExchSt":U ).
                        run hide-list-add-item in this-procedure ( input "outExchLt":U ).
                        run hide-list-add-item in this-procedure ( input "outExchRb":U ).
                    end.        /* when {&WDEDT_exch} */
                end case.       /* case entry( v-counter, p-ext-doc-type-list ) */
            end.
        end.
    end.
    assign
        p-hide-list = "":U
    .
    for each buf_temp_hideCol
    on error undo, return error
    :
        assign
            p-hide-list = substitute( "&1&2&3"
                                    , p-hide-list
                                    , ( if p-hide-list = "":U then "":U else ",":U )
                                    , buf_temp_hideCol.colName )
        .
    end.        /* for each buf_temp_hideCol */
end.
end procedure. /* get-hide-list */

/*==========================================================================*/
procedure hide-list-add-item :
define input parameter p-item-name  as character        no-undo.

    define buffer buf_temp_hideCol      for temp_hideCol.
do
for buf_temp_hideCol
on error undo, return error
:
    find first buf_temp_hideCol
         where buf_temp_hideCol.colName = p-item-name
    no-error.
    if not available buf_temp_hideCol
    then do:
        create buf_temp_hideCol.
        assign
            buf_temp_hideCol.colName = p-item-name
        .
    end.
end.
end procedure. /* hide-list-add-item */

/*==========================================================================*/
procedure write-stLtRbList :
define input parameter p-ob-tal   as logical          no-undo.
define input parameter p-ob-liter as logical          no-undo.
define input parameter p-ob-rubl  as logical          no-undo.

    define variable v-stLtRbList    as character    no-undo.
    define variable v-list-num      as integer      no-undo.
do
on error undo, return error
:
    assign
        v-stLtRbList = "":U
    .
    if p-ob-tal = yes
    then do:
        assign
            v-stLtRbList = substitute( "&1&2&3":U
                            , v-stLtRbList
                            , ( if v-stLtRbList = "":U then "":U else ",":U )
                            , "количестве талонов"
                            )
        .
    end.
    if p-ob-liter = yes
    then do:
        assign
            v-stLtRbList = substitute( "&1&2&3":U
                            , v-stLtRbList
                            , ( if v-stLtRbList = "":U then "":U else ",":U )
                            , "л топлива"
                            )
        .
    end.
    if p-ob-rubl = yes
    then do:
        assign
            v-stLtRbList = substitute( "&1&2&3":U
                            , v-stLtRbList
                            , ( if v-stLtRbList = "":U then "":U else ",":U )
                            , "суммах в {&abbr_rubl}"
                            )
        .
    end.
                run rwthobxl-write-cell-data in this-procedure (
                  input {&rwthobxl-sheet1-showStLtRb1}
                , input v-stLtRbList
            ).

end.
end procedure. /* write-stLtRbList */