/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчёт Оборотная ведомость по матценностям - Excel

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/06/07
Author: Victor Guntner
Creation date: 09/06/07

Required:
    { g b l / p a r a m l s . i    }
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define rwthobxl-data-label "DTA":U
&global-define rwthobxl-format-label "FMT":U

&global-define rwthobxl-FMT_Object "Объект":U

&global-define rwthobxl-sheetList  "НачалоПериода,Обороты,КонецПериода":U

&global-define rwthobxl-sheet1_valutCode       "НачалоПериода_valutCode":U
&global-define rwthobxl-sheet1_columnList      "НачалоПериода_columnList":U
&global-define rwthobxl-sheet1_columnType      "НачалоПериода_columnType":U
&global-define rwthobxl-sheet1_subtotalList    "НачалоПериода_subtotalList":U
&global-define rwthobxl-sheet1_subtotalType    "НачалоПериода_subtotalType":U

&global-define rwthobxl-sheet2_valutCode       "Обороты_valutCode":U
&global-define rwthobxl-sheet2_columnList      "Обороты_columnList":U
&global-define rwthobxl-sheet2_columnType      "Обороты_columnType":U
&global-define rwthobxl-sheet2_subtotalList    "Обороты_subtotalList":U
&global-define rwthobxl-sheet2_subtotalType    "Обороты_subtotalType":U

&global-define rwthobxl-sheet3_valutCode       "КонецПериода_valutCode":U
&global-define rwthobxl-sheet3_columnList      "КонецПериода_columnList":U
&global-define rwthobxl-sheet3_columnType      "КонецПериода_columnType":U
&global-define rwthobxl-sheet3_subtotalList    "КонецПериода_subtotalList":U
&global-define rwthobxl-sheet3_subtotalType    "КонецПериода_subtotalType":U

&global-define rwthobxl-sheet1-name            "НачалоПериода":U
&global-define rwthobxl-sheet1-datePrint       "НачалоПериода_datePrint":U
&global-define rwthobxl-sheet1-objList         "НачалоПериода_objList":U
&global-define rwthobxl-sheet1-dateString      "НачалоПериода_dateString":U
&global-define rwthobxl-sheet1-extDocTypeList  "НачалоПериода_extDocTypeList":U
&global-define rwthobxl-sheet1-detail          "НачалоПериода_detail":U
&global-define rwthobxl-sheet1-dateFromString  "НачалоПериода_dateFromString":U
&global-define rwthobxl-sheet1-showStLtRb1     "НачалоПериода_showStLtRb1":U
&global-define rwthobxl-sheet1-showStLtRb2     "НачалоПериода_showStLtRb2":U
&global-define rwthobxl-sheet1-showStLtRb3     "НачалоПериода_showStLtRb3":U

&global-define rwthobxl-sheet2-name "Обороты":U
&global-define rwthobxl-sheet2-dateString      "Обороты_dateString":U

&global-define rwthobxl-sheet3-name         "КонецПериода":U
&global-define rwthobxl-sheet3-dateToString "КонецПериода_dateToString":U

&global-define rwthobxl-sheet2_hideColList  "Обороты_hideColList":U
&global-define rwthobxl-sheet2_withoutSt    "incIncmSt,incRetnSt,outSaleSt,outExchSt,payPaydDeskSt,payPaydSt,payExchSt,payRetnSt,clrRealSt,clrPOffSt,trsRealExpsSt,trsRealIncmSt,trsRealTrnsSt,trsPOffExpsSt,trsPOffIncmSt,trsPOffTrnsSt":U
&global-define rwthobxl-sheet2_withoutLt    "incIncmLt,incRetnLt,outSaleLt,outExchLt,payPaydDeskLt,payPaydLt,payExchLt,payRetnLt,clrRealLt,clrPOffLt,trsRealExpsLt,trsRealIncmLt,trsRealTrnsLt,trsPOffExpsLt,trsPOffIncmLt,trsPOffTrnsLt":U
&global-define rwthobxl-sheet2_withoutRb    "outSaleRb,outExchRb,payPaydRb,payExchRb,payPaydDeskRb,payRetnRb,clrRealRb,clrPOffRb,trsPOffExpsRb,trsPOffIncmRb,trsPOffTrnsRb":U

&global-define rwthobxl-sheet1_hideColList  "НачалоПериода_hideColList":U
&global-define rwthobxl-sheet1_withoutSt    "stkRealSt,stkPOffSt":U
&global-define rwthobxl-sheet1_withoutLt    "stkRealLt,stkPOffLt":U

&global-define rwthobxl-sheet3_hideColList  "КонецПериода_hideColList":U
&global-define rwthobxl-sheet3_withoutSt    "stkRealSt,stkPOffSt":U
&global-define rwthobxl-sheet3_withoutLt    "stkRealLt,stkPOffLt":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_sheet1_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field obj-type      as character
    field obj-code      as integer
    field wth-code      as integer
    field par-code      as integer
    field goodsName     as character
    field wthPar        as character
    field stkRealSt     as decimal
    field stkPOffSt     as decimal
    field stkRealLt     as decimal
    field stkPOffLt     as decimal
    field stkRealRb     as decimal
    field stkPOffRb     as decimal

    index pi is primary unique
        xl-line-id
.

define temp-table temp_sheet3_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field obj-type      as character
    field obj-code      as integer
    field wth-code      as integer
    field par-code      as integer
    field goodsName     as character
    field wthPar        as character
    field stkRealSt     as decimal
    field stkPOffSt     as decimal
    field stkRealLt     as decimal
    field stkPOffLt     as decimal
    field stkRealRb     as decimal
    field stkPOffRb     as decimal

    index pi is primary unique
        xl-line-id
.

define temp-table temp_sheet2_line-data no-undo
    field sheet-name      as character
    field xl-line-id      as integer
    field obj-type        as character
    field obj-code        as integer
    field wth-code        as integer
    field par-code        as integer
    field goodsName       as character
    field wthPar          as character
    field incIncmSt       as decimal
    field incIncmLt       as decimal
    field incRetnSt       as decimal
    field incRetnLt       as decimal
    field outSaleSt       as decimal
    field outSaleLt       as decimal
    field outSaleRb       as decimal
    field outExchSt       as decimal
    field outExchLt       as decimal
    field outExchRb       as decimal
    field payPaydDeskSt   as decimal
    field payPaydDeskLt   as decimal
    field payPaydDeskRb   as decimal
    field payPaydSt       as decimal
    field payPaydLt       as decimal
    field payPaydRb       as decimal
    field payExchSt       as decimal
    field payExchLt       as decimal
    field payExchRb       as decimal
    field payRetnSt       as decimal
    field payRetnLt       as decimal
    field payRetnRb       as decimal
    field clrRealSt       as decimal
    field clrRealLt       as decimal
    field clrRealRb       as decimal
    field clrPOffSt       as decimal
    field clrPOffLt       as decimal
    field clrPOffRb       as decimal
    field trsRealExpsSt   as decimal
    field trsRealExpsLt   as decimal
    field trsRealIncmSt   as decimal
    field trsRealIncmLt   as decimal
    field trsRealTrnsSt   as decimal
    field trsRealTrnsLt   as decimal
    field trsPOffExpsSt   as decimal
    field trsPOffExpsLt   as decimal
    field trsPOffExpsRb   as decimal
    field trsPOffIncmSt   as decimal
    field trsPOffIncmLt   as decimal
    field trsPOffIncmRb   as decimal
    field trsPOffTrnsSt   as decimal
    field trsPOffTrnsLt   as decimal
    field trsPOffTrnsRb   as decimal
    field total-code      as integer

    index pi is primary unique
        xl-line-id
    index basepi
        total-code
        obj-type
        obj-code
        wth-code
        par-code
.

define variable v-rwthobxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-rwthobxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-rwthobxl-sheet3-cur-data-row     as integer      no-undo.
define variable v-rwthobxl-cell-file-name       as character    no-undo.
define variable v-rwthobxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure rwthobxl-init :

do
on error undo, return error
:
    assign
        v-rwthobxl-sheet1-cur-data-row = 0
        v-rwthobxl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-rwthobxl-data-file-name
    ).
    output stream excel-line to value( v-rwthobxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-rwthobxl-cell-file-name
    ).
    output stream excel-cell to value( v-rwthobxl-cell-file-name ).
    run rwthobxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&rwthobxl-sheetList}
    ).
    if printrubl
    then do:
        run rwthobxl-write-cell-data in this-procedure (
              input {&rwthobxl-sheet1_valutCode}
            , input "0":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input {&rwthobxl-sheet2_valutCode}
            , input "0":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input {&rwthobxl-sheet3_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run rwthobxl-write-cell-data in this-procedure (
              input {&rwthobxl-sheet1_valutCode}
            , input "1":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input {&rwthobxl-sheet2_valutCode}
            , input "1":U
        ).
        run rwthobxl-write-cell-data in this-procedure (
              input {&rwthobxl-sheet3_valutCode}
            , input "1":U
        ).
    end.
/*    run rwthobxl-write-cell-data in this-procedure (*/
/*          input {&rwthobxl-sheet1_columnList}*/
/*        , input "seaname,seacode,ostbegtot,ostbeglocal,ostbegregion,ostbegimp,pritot,prilocal,priregion,priimp,saletot,salelocal,saleregion,saleimp,rettot,retlocal,retregion,retimp,othtot,othlocal,othregion,othimp,ostendtot,ostendlocal,ostendregion,ostendimp":U*/
/*    ).*/


    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1_columnList}
        , input "goodsName,wthPar,stkRealSt,stkPOffSt,stkRealLt,stkPOffLt":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1_columnType}
        , input "S,S,D,D,D,D":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1_subtotalList}
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet1_subtotalType}
        , input "":U
    ).

    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet3_columnList}
        , input "goodsName,wthPar,stkRealSt,stkPOffSt,stkRealLt,stkPOffLt":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet3_columnType}
        , input "S,S,D,D,D,D":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet3_subtotalList}
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet3_subtotalType}
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet2_columnList}
        , input "goodsName,wthPar,incIncmSt,incIncmLt,incRetnSt,incRetnLt,outSaleSt,outSaleLt,outSaleRb,outExchSt,outExchLt,outExchRb,payPaydDeskSt,payPaydDeskLt,payPaydDeskRb,payPaydSt,payPaydLt,payPaydRb,payExchSt,payExchLt,payExchRb,payRetnSt,payRetnLt,payRetnRb,clrRealSt,clrRealLt,clrRealRb,clrPOffSt,clrPOffLt,clrPOffRb,trsRealExpsSt,trsRealExpsLt,trsRealIncmSt,trsRealIncmLt,trsRealTrnsSt,trsRealTrnsLt,trsPOffExpsSt,trsPOffExpsLt,trsPOffExpsRb,trsPOffIncmSt,trsPOffIncmLt,trsPOffIncmRb,trsPOffTrnsSt,trsPOffTrnsLt,trsPOffTrnsRb":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet2_columnType}
        , input "S,S,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet2_subtotalList}
        , input "":U
    ).
    run rwthobxl-write-cell-data in this-procedure (
          input {&rwthobxl-sheet2_subtotalType}
        , input "":U
    ).
end.
end procedure. /* rwthobxl-init */

/*==========================================================================*/
procedure rwthobxl-sheet1-add-line-data :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-wth-code       as integer          no-undo.
define input parameter p-par-code       as integer          no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-sum-type       as character        no-undo.
define input parameter p-stkSt          as decimal          no-undo.
define input parameter p-stkLt          as decimal          no-undo.
define input parameter p-stkRb          as decimal          no-undo.

    define variable v-gds-name    as character    no-undo.

    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_wealth        for ub.wealth.
do
for buf_temp_sheet1_line-data
  , buf_wth-par
  , buf_wealth
on error undo, return error
:
    find first buf_temp_sheet1_line-data
         where buf_temp_sheet1_line-data.obj-type   = p-obj-type
           and buf_temp_sheet1_line-data.obj-code   = p-obj-code
           and buf_temp_sheet1_line-data.wth-code   = p-wth-code
           and buf_temp_sheet1_line-data.par-code   = p-par-code
    no-error.
    if not available buf_temp_sheet1_line-data
    then do:
        find first buf_wealth no-lock
             where buf_wealth.wth-code = p-wth-code
        .
        assign
            v-gds-name = buf_wealth.wth-name
        .
        find first buf_wth-par no-lock
             where buf_wth-par.par-code = p-par-code
        no-error.
        create buf_temp_sheet1_line-data.
        assign
            v-rwthobxl-sheet1-cur-data-row          = v-rwthobxl-sheet1-cur-data-row + 1
            buf_temp_sheet1_line-data.sheet-name    = {&rwthobxl-sheet1-name}
            buf_temp_sheet1_line-data.xl-line-id    = v-rwthobxl-sheet1-cur-data-row
            buf_temp_sheet1_line-data.obj-type      = p-obj-type
            buf_temp_sheet1_line-data.obj-code      = p-obj-code
            buf_temp_sheet1_line-data.wth-code      = p-wth-code
            buf_temp_sheet1_line-data.par-code      = p-par-code
            buf_temp_sheet1_line-data.goodsName     = v-gds-name
            buf_temp_sheet1_line-data.wthPar        = ( if available buf_wth-par then string( buf_wth-par.par-val ) else "":U )
        .
        assign
            buf_temp_sheet1_line-data.stkRealSt     = 0.0
            buf_temp_sheet1_line-data.stkPOffSt     = 0.0
            buf_temp_sheet1_line-data.stkRealLt     = 0.0
            buf_temp_sheet1_line-data.stkPOffLt     = 0.0
            buf_temp_sheet1_line-data.stkRealRb     = 0.0
            buf_temp_sheet1_line-data.stkPOffRb     = 0.0
        .
    end.
    case p-ext-doc-type
    :
        when {&WDEDT_Inc_Ext}
        or when {&WDEDT_Inc_Int_Free}
        or when {&WDEDT_Ret_Int_Free}
        then do:
            assign
                buf_temp_sheet1_line-data.stkRealSt     = buf_temp_sheet1_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet1_line-data.stkRealLt     = buf_temp_sheet1_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet1_line-data.stkRealRb     = buf_temp_sheet1_line-data.stkRealRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Inc_Ext} */
        when {&WDEDT_Exp_Ext}
        or when {&WDEDT_Dst_free}
        or when {&WDEDT_Ret_int_free}
        or when {&WDEDT_Exp_int_free}
        then do:
            assign
                buf_temp_sheet1_line-data.stkRealSt     = buf_temp_sheet1_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet1_line-data.stkRealLt     = buf_temp_sheet1_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet1_line-data.stkRealRb     = buf_temp_sheet1_line-data.stkRealRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Exp_Ext} */
        when {&WDEDT_Inc_Int_Put}
        or when {&WDEDT_Ret_Int_Put}
        or when {&WDEDT_Put_Cash}
        or when {&WDEDT_Put_Sale}
        or when {&WDEDT_Put_Cli}
        then do:
            assign
                buf_temp_sheet1_line-data.stkPOffSt     = buf_temp_sheet1_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet1_line-data.stkPOffLt     = buf_temp_sheet1_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet1_line-data.stkPOffRb     = buf_temp_sheet1_line-data.stkPOffRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Put_Cash} */
        when {&WDEDT_Exp_Int_Put}
        or when {&WDEDT_Dst_Put}
        then do:
            assign
                buf_temp_sheet1_line-data.stkPOffSt     = buf_temp_sheet1_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet1_line-data.stkPOffLt     = buf_temp_sheet1_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet1_line-data.stkPOffRb     = buf_temp_sheet1_line-data.stkPOffRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Exp_Int_Put} */
        when {&WDEDT_exch}
        then do:
            if p-sum-type = {&income}
            then do:
                assign
                    buf_temp_sheet1_line-data.stkPOffSt     = buf_temp_sheet1_line-data.stkPOffSt  + p-stkSt
                    buf_temp_sheet1_line-data.stkPOffLt     = buf_temp_sheet1_line-data.stkPOffLt  + p-stkLt
                    buf_temp_sheet1_line-data.stkPOffRb     = buf_temp_sheet1_line-data.stkPOffRb  + p-stkRb
                .
            end.
            else do:
                assign
                    buf_temp_sheet1_line-data.stkRealSt     = buf_temp_sheet1_line-data.stkRealSt  + p-stkSt
                    buf_temp_sheet1_line-data.stkRealLt     = buf_temp_sheet1_line-data.stkRealLt  + p-stkLt
                    buf_temp_sheet1_line-data.stkRealRb     = buf_temp_sheet1_line-data.stkRealRb  + p-stkRb
                .
            end.
        end.        /* when {&WDEDT_exch} */
        otherwise do:
        end.
    end case.       /* case p-ext-doc-type */
end.
end procedure. /* rwthobxl-sheet1-add-line-data */

/*==========================================================================*/
procedure rwthobxl-sheet1-write-line-data :

    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    break by buf_temp_sheet1_line-data.obj-type
          by buf_temp_sheet1_line-data.obj-code
          by buf_temp_sheet1_line-data.wth-code
          by buf_temp_sheet1_line-data.par-code
    :
        if first-of ( buf_temp_sheet1_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                buf_temp_sheet1_line-data.sheet-name
                {&tabulation}   {&rwthobxl-data-label}
                {&tabulation}   substitute( "По объекту &1 &2", buf_temp_sheet1_line-data.obj-type, buf_temp_sheet1_line-data.obj-code )
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&new-line}
            .
            run rwthobxl-sheet1-write-line-format in this-procedure (
                input {&rwthobxl-FMT_Object}
            ).
        end.
        put stream excel-line unformatted
                            buf_temp_sheet1_line-data.sheet-name
            {&tabulation}   {&rwthobxl-data-label}
            {&tabulation}   buf_temp_sheet1_line-data.goodsName
            {&tabulation}   buf_temp_sheet1_line-data.wthPar
            {&tabulation}   string( buf_temp_sheet1_line-data.stkRealSt )
            {&tabulation}   string( buf_temp_sheet1_line-data.stkPOffSt )
            {&tabulation}   string( buf_temp_sheet1_line-data.stkRealLt )
            {&tabulation}   string( buf_temp_sheet1_line-data.stkPOffLt )
            {&new-line}
        .
    end.
end.
end procedure. /* rwthobxl-sheet1-write-line-data */

/*==========================================================================*/
procedure rwthobxl-sheet3-add-line-data :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-wth-code       as integer          no-undo.
define input parameter p-par-code       as integer          no-undo.
define input parameter p-ext-doc-type   as character        no-undo.
define input parameter p-sum-type       as character        no-undo.
define input parameter p-stkSt          as decimal          no-undo.
define input parameter p-stkLt          as decimal          no-undo.
define input parameter p-stkRb          as decimal          no-undo.

    define variable v-gds-name    as character    no-undo.

    define buffer buf_temp_sheet3_line-data        for temp_sheet3_line-data.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_wealth        for ub.wealth.
do
for buf_temp_sheet3_line-data
  , buf_wth-par
  , buf_wealth
on error undo, return error
:
    find first buf_temp_sheet3_line-data
         where buf_temp_sheet3_line-data.obj-type   = p-obj-type
           and buf_temp_sheet3_line-data.obj-code   = p-obj-code
           and buf_temp_sheet3_line-data.wth-code   = p-wth-code
           and buf_temp_sheet3_line-data.par-code   = p-par-code
    no-error.
    if not available buf_temp_sheet3_line-data
    then do:
        find first buf_wealth no-lock
             where buf_wealth.wth-code = p-wth-code
        .
        assign
            v-gds-name = buf_wealth.wth-name
        .
        find first buf_wth-par no-lock
             where buf_wth-par.par-code = p-par-code
        no-error.
        create buf_temp_sheet3_line-data.
        assign
            v-rwthobxl-sheet3-cur-data-row          = v-rwthobxl-sheet3-cur-data-row + 1
            buf_temp_sheet3_line-data.sheet-name    = {&rwthobxl-sheet3-name}
            buf_temp_sheet3_line-data.xl-line-id    = v-rwthobxl-sheet3-cur-data-row
            buf_temp_sheet3_line-data.obj-type      = p-obj-type
            buf_temp_sheet3_line-data.obj-code      = p-obj-code
            buf_temp_sheet3_line-data.wth-code      = p-wth-code
            buf_temp_sheet3_line-data.par-code      = p-par-code
            buf_temp_sheet3_line-data.goodsName     = v-gds-name
            buf_temp_sheet3_line-data.wthPar        = ( if available buf_wth-par then string( buf_wth-par.par-val ) else "":U )
        .
        assign
            buf_temp_sheet3_line-data.stkRealSt     = 0.0
            buf_temp_sheet3_line-data.stkPOffSt     = 0.0
            buf_temp_sheet3_line-data.stkRealLt     = 0.0
            buf_temp_sheet3_line-data.stkPOffLt     = 0.0
            buf_temp_sheet3_line-data.stkRealRb     = 0.0
            buf_temp_sheet3_line-data.stkPOffRb     = 0.0
        .
    end.
    case p-ext-doc-type
    :
        when {&WDEDT_Inc_Ext}
        or when {&WDEDT_Inc_Int_Free}
        or when {&WDEDT_Ret_Int_Free}
        then do:
            assign
                buf_temp_sheet3_line-data.stkRealSt     = buf_temp_sheet3_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet3_line-data.stkRealLt     = buf_temp_sheet3_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet3_line-data.stkRealRb     = buf_temp_sheet3_line-data.stkRealRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Inc_Ext} */
        when {&WDEDT_Exp_Ext}
        or when {&WDEDT_Dst_free}
        or when {&WDEDT_Ret_Int_Free}
        or when {&WDEDT_Exp_Int_Free}
        then do:
            assign
                buf_temp_sheet3_line-data.stkRealSt     = buf_temp_sheet3_line-data.stkRealSt  + p-stkSt
                buf_temp_sheet3_line-data.stkRealLt     = buf_temp_sheet3_line-data.stkRealLt  + p-stkLt
                buf_temp_sheet3_line-data.stkRealRb     = buf_temp_sheet3_line-data.stkRealRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Exp_Ext} */
        when {&WDEDT_Inc_Int_Put}
        or when {&WDEDT_Ret_Int_Put}
        or when {&WDEDT_Put_Cash}
        or when {&WDEDT_Put_Sale}
        or when {&WDEDT_Put_Cli}
        then do:
            assign
                buf_temp_sheet3_line-data.stkPOffSt     = buf_temp_sheet3_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet3_line-data.stkPOffLt     = buf_temp_sheet3_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet3_line-data.stkPOffRb     = buf_temp_sheet3_line-data.stkPOffRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Put_Cash} */
        when {&WDEDT_Exp_Int_Put}
        or when {&WDEDT_Dst_Put}
        then do:
            assign
                buf_temp_sheet3_line-data.stkPOffSt     = buf_temp_sheet3_line-data.stkPOffSt  + p-stkSt
                buf_temp_sheet3_line-data.stkPOffLt     = buf_temp_sheet3_line-data.stkPOffLt  + p-stkLt
                buf_temp_sheet3_line-data.stkPOffRb     = buf_temp_sheet3_line-data.stkPOffRb  + p-stkRb
            .
        end.        /* when {&WDEDT_Exp_Int_Put} */
        when {&WDEDT_exch}
        then do:
            if p-sum-type = {&income}
            then do:
                assign
                    buf_temp_sheet3_line-data.stkPOffSt     = buf_temp_sheet3_line-data.stkPOffSt  + p-stkSt
                    buf_temp_sheet3_line-data.stkPOffLt     = buf_temp_sheet3_line-data.stkPOffLt  + p-stkLt
                    buf_temp_sheet3_line-data.stkPOffRb     = buf_temp_sheet3_line-data.stkPOffRb  + p-stkRb
                .
            end.
            else do:
                assign
                    buf_temp_sheet3_line-data.stkRealSt     = buf_temp_sheet3_line-data.stkRealSt  + p-stkSt
                    buf_temp_sheet3_line-data.stkRealLt     = buf_temp_sheet3_line-data.stkRealLt  + p-stkLt
                    buf_temp_sheet3_line-data.stkRealRb     = buf_temp_sheet3_line-data.stkRealRb  + p-stkRb
                .
            end.
        end.        /* when {&WDEDT_exch} */
    end case.       /* case p-ext-doc-type */
end.
end procedure. /* rwthobxl-sheet3-add-line-data */

/*==========================================================================*/
procedure rwthobxl-sheet3-write-line-data :

    define buffer buf_temp_sheet3_line-data        for temp_sheet3_line-data.
do
for buf_temp_sheet3_line-data
on error undo, return error
:
    for each buf_temp_sheet3_line-data
    break by buf_temp_sheet3_line-data.obj-type
          by buf_temp_sheet3_line-data.obj-code
          by buf_temp_sheet3_line-data.wth-code
          by buf_temp_sheet3_line-data.par-code
    :
        if first-of ( buf_temp_sheet3_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                buf_temp_sheet3_line-data.sheet-name
                {&tabulation}   {&rwthobxl-data-label}
                {&tabulation}   substitute( "По объекту &1 &2", buf_temp_sheet3_line-data.obj-type, buf_temp_sheet3_line-data.obj-code )
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&new-line}
            .
            run rwthobxl-sheet3-write-line-format in this-procedure (
                input {&rwthobxl-FMT_Object}
            ).
        end.
        put stream excel-line unformatted
                            buf_temp_sheet3_line-data.sheet-name
            {&tabulation}   {&rwthobxl-data-label}
            {&tabulation}   buf_temp_sheet3_line-data.goodsName
            {&tabulation}   buf_temp_sheet3_line-data.wthPar
            {&tabulation}   string( buf_temp_sheet3_line-data.stkRealSt )
            {&tabulation}   string( buf_temp_sheet3_line-data.stkPOffSt )
            {&tabulation}   string( buf_temp_sheet3_line-data.stkRealLt )
            {&tabulation}   string( buf_temp_sheet3_line-data.stkPOffLt )
            {&new-line}
        .
    end.
end.
end procedure. /* rwthobxl-sheet3-write-line-data */

/*==========================================================================*/
procedure rwthobxl-sheet2-add-line-data :
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.
define input parameter p-wth-code       as integer          no-undo.
define input parameter p-par-code       as integer          no-undo.
define input parameter p-incIncmSt      as decimal          no-undo.
define input parameter p-incIncmLt      as decimal          no-undo.
define input parameter p-incRetnSt      as decimal          no-undo.
define input parameter p-incRetnLt      as decimal          no-undo.
define input parameter p-outSaleSt      as decimal          no-undo.
define input parameter p-outSaleLt      as decimal          no-undo.
define input parameter p-outSaleRb      as decimal          no-undo.
define input parameter p-outExchSt      as decimal          no-undo.
define input parameter p-outExchLt      as decimal          no-undo.
define input parameter p-outExchRb      as decimal          no-undo.
define input parameter p-payPaydDeskSt  as decimal          no-undo.
define input parameter p-payPaydDeskLt  as decimal          no-undo.
define input parameter p-payPaydDeskRb  as decimal          no-undo.
define input parameter p-payPaydSt      as decimal          no-undo.
define input parameter p-payPaydLt      as decimal          no-undo.
define input parameter p-payPaydRb      as decimal          no-undo.
define input parameter p-payExchSt      as decimal          no-undo.
define input parameter p-payExchLt      as decimal          no-undo.
define input parameter p-payExchRb      as decimal          no-undo.
define input parameter p-payRetnSt      as decimal          no-undo.
define input parameter p-payRetnLt      as decimal          no-undo.
define input parameter p-payRetnRb      as decimal          no-undo.
define input parameter p-clrRealSt      as decimal          no-undo.
define input parameter p-clrRealLt      as decimal          no-undo.
define input parameter p-clrRealRb      as decimal          no-undo.
define input parameter p-clrPOffSt      as decimal          no-undo.
define input parameter p-clrPOffLt      as decimal          no-undo.
define input parameter p-clrPOffRb      as decimal          no-undo.
define input parameter p-trsRealExpsSt  as decimal          no-undo.
define input parameter p-trsRealExpsLt  as decimal          no-undo.
define input parameter p-trsRealIncmSt  as decimal          no-undo.
define input parameter p-trsRealIncmLt  as decimal          no-undo.
define input parameter p-trsRealTrnsSt  as decimal          no-undo.
define input parameter p-trsRealTrnsLt  as decimal          no-undo.
define input parameter p-trsPOffExpsSt  as decimal          no-undo.
define input parameter p-trsPOffExpsLt  as decimal          no-undo.
define input parameter p-trsPOffExpsRb  as decimal          no-undo.
define input parameter p-trsPOffIncmSt  as decimal          no-undo.
define input parameter p-trsPOffIncmLt  as decimal          no-undo.
define input parameter p-trsPOffIncmRb  as decimal          no-undo.
define input parameter p-trsPOffTrnsSt  as decimal          no-undo.
define input parameter p-trsPOffTrnsLt  as decimal          no-undo.
define input parameter p-trsPOffTrnsRb  as decimal          no-undo.

    define variable v-gds-name    as character    no-undo.

    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
    define buffer buf_wth-par       for ub.wth-par.
    define buffer buf_wealth        for ub.wealth.
do
for buf_temp_sheet2_line-data
  , buf_wth-par
  , buf_wealth
on error undo, return error
:
    find first buf_temp_sheet2_line-data
         where buf_temp_sheet2_line-data.total-code = 0
           and buf_temp_sheet2_line-data.obj-type   = p-obj-type
           and buf_temp_sheet2_line-data.obj-code   = p-obj-code
           and buf_temp_sheet2_line-data.wth-code   = p-wth-code
           and buf_temp_sheet2_line-data.par-code   = p-par-code
         no-error
         .
    if not available buf_temp_sheet2_line-data
    then do:
        find first buf_wealth no-lock
             where buf_wealth.wth-code = p-wth-code
        .
        assign
            v-gds-name = buf_wealth.wth-name
        .
        find first buf_wth-par no-lock
             where buf_wth-par.par-code = p-par-code
        no-error.
        create buf_temp_sheet2_line-data.
        assign
            v-rwthobxl-sheet2-cur-data-row = v-rwthobxl-sheet2-cur-data-row + 1
        .
        assign
            buf_temp_sheet2_line-data.sheet-name      = {&rwthobxl-sheet2-name}
            buf_temp_sheet2_line-data.xl-line-id      = v-rwthobxl-sheet2-cur-data-row
            buf_temp_sheet2_line-data.obj-type        = p-obj-type
            buf_temp_sheet2_line-data.obj-code        = p-obj-code
            buf_temp_sheet2_line-data.total-code      = 0
            buf_temp_sheet2_line-data.wth-code        = p-wth-code
            buf_temp_sheet2_line-data.par-code        = p-par-code
            buf_temp_sheet2_line-data.goodsName       = v-gds-name
            buf_temp_sheet2_line-data.wthPar          = ( if available buf_wth-par then string( buf_wth-par.par-val ) else "":U )
            buf_temp_sheet2_line-data.incIncmSt       = 0.0
            buf_temp_sheet2_line-data.incIncmLt       = 0.0
            buf_temp_sheet2_line-data.incRetnSt       = 0.0
            buf_temp_sheet2_line-data.incRetnLt       = 0.0
            buf_temp_sheet2_line-data.outSaleSt       = 0.0
            buf_temp_sheet2_line-data.outSaleLt       = 0.0
            buf_temp_sheet2_line-data.outSaleRb       = 0.0
            buf_temp_sheet2_line-data.outExchSt       = 0.0
            buf_temp_sheet2_line-data.outExchLt       = 0.0
            buf_temp_sheet2_line-data.outExchRb       = 0.0
            buf_temp_sheet2_line-data.payPaydDeskSt   = 0.0
            buf_temp_sheet2_line-data.payPaydDeskLt   = 0.0
            buf_temp_sheet2_line-data.payPaydDeskRb   = 0.0
            buf_temp_sheet2_line-data.payPaydSt       = 0.0
            buf_temp_sheet2_line-data.payPaydLt       = 0.0
            buf_temp_sheet2_line-data.payPaydRb       = 0.0
            buf_temp_sheet2_line-data.payExchSt       = 0.0
            buf_temp_sheet2_line-data.payExchLt       = 0.0
            buf_temp_sheet2_line-data.payExchRb       = 0.0
            buf_temp_sheet2_line-data.payRetnSt       = 0.0
            buf_temp_sheet2_line-data.payRetnLt       = 0.0
            buf_temp_sheet2_line-data.payRetnRb       = 0.0
            buf_temp_sheet2_line-data.clrRealSt       = 0.0
            buf_temp_sheet2_line-data.clrRealLt       = 0.0
            buf_temp_sheet2_line-data.clrRealRb       = 0.0
            buf_temp_sheet2_line-data.clrPOffSt       = 0.0
            buf_temp_sheet2_line-data.clrPOffLt       = 0.0
            buf_temp_sheet2_line-data.clrPOffRb       = 0.0
            buf_temp_sheet2_line-data.trsRealExpsSt   = 0.0
            buf_temp_sheet2_line-data.trsRealExpsLt   = 0.0
            buf_temp_sheet2_line-data.trsRealIncmSt   = 0.0
            buf_temp_sheet2_line-data.trsRealIncmLt   = 0.0
            buf_temp_sheet2_line-data.trsRealTrnsSt   = 0.0
            buf_temp_sheet2_line-data.trsRealTrnsLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffExpsSt   = 0.0
            buf_temp_sheet2_line-data.trsPOffExpsLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffExpsRb   = 0.0
            buf_temp_sheet2_line-data.trsPOffIncmSt   = 0.0
            buf_temp_sheet2_line-data.trsPOffIncmLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffIncmRb   = 0.0
            buf_temp_sheet2_line-data.trsPOffTrnsSt   = 0.0
            buf_temp_sheet2_line-data.trsPOffTrnsLt   = 0.0
            buf_temp_sheet2_line-data.trsPOffTrnsRb   = 0.0
        .
    end.
    assign
        buf_temp_sheet2_line-data.incIncmSt       = buf_temp_sheet2_line-data.incIncmSt      + p-incIncmSt
        buf_temp_sheet2_line-data.incIncmLt       = buf_temp_sheet2_line-data.incIncmLt      + p-incIncmLt
        buf_temp_sheet2_line-data.incRetnSt       = buf_temp_sheet2_line-data.incRetnSt      + p-incRetnSt
        buf_temp_sheet2_line-data.incRetnLt       = buf_temp_sheet2_line-data.incRetnLt      + p-incRetnLt
        buf_temp_sheet2_line-data.outSaleSt       = buf_temp_sheet2_line-data.outSaleSt      + p-outSaleSt
        buf_temp_sheet2_line-data.outSaleLt       = buf_temp_sheet2_line-data.outSaleLt      + p-outSaleLt
        buf_temp_sheet2_line-data.outSaleRb       = buf_temp_sheet2_line-data.outSaleRb      + p-outSaleRb
        buf_temp_sheet2_line-data.outExchSt       = buf_temp_sheet2_line-data.outExchSt      + p-outExchSt
        buf_temp_sheet2_line-data.outExchLt       = buf_temp_sheet2_line-data.outExchLt      + p-outExchLt
        buf_temp_sheet2_line-data.outExchRb       = buf_temp_sheet2_line-data.outExchRb      + p-outExchRb
        buf_temp_sheet2_line-data.payPaydDeskSt   = buf_temp_sheet2_line-data.payPaydDeskSt  + p-payPaydDeskSt
        buf_temp_sheet2_line-data.payPaydDeskLt   = buf_temp_sheet2_line-data.payPaydDeskLt  + p-payPaydDeskLt
        buf_temp_sheet2_line-data.payPaydDeskRb   = buf_temp_sheet2_line-data.payPaydDeskRb  + p-payPaydDeskRb
        buf_temp_sheet2_line-data.payPaydSt       = buf_temp_sheet2_line-data.payPaydSt      + p-payPaydSt
        buf_temp_sheet2_line-data.payPaydLt       = buf_temp_sheet2_line-data.payPaydLt      + p-payPaydLt
        buf_temp_sheet2_line-data.payPaydRb       = buf_temp_sheet2_line-data.payPaydRb      + p-payPaydRb
        buf_temp_sheet2_line-data.payExchSt       = buf_temp_sheet2_line-data.payExchSt      + p-payExchSt
        buf_temp_sheet2_line-data.payExchLt       = buf_temp_sheet2_line-data.payExchLt      + p-payExchLt
        buf_temp_sheet2_line-data.payExchRb       = buf_temp_sheet2_line-data.payExchRb      + p-payExchRb
        buf_temp_sheet2_line-data.payRetnSt       = buf_temp_sheet2_line-data.payRetnSt      + p-payRetnSt
        buf_temp_sheet2_line-data.payRetnLt       = buf_temp_sheet2_line-data.payRetnLt      + p-payRetnLt
        buf_temp_sheet2_line-data.payRetnRb       = buf_temp_sheet2_line-data.payRetnRb      + p-payRetnRb
        buf_temp_sheet2_line-data.clrRealSt       = buf_temp_sheet2_line-data.clrRealSt      + p-clrRealSt
        buf_temp_sheet2_line-data.clrRealLt       = buf_temp_sheet2_line-data.clrRealLt      + p-clrRealLt
        buf_temp_sheet2_line-data.clrRealRb       = buf_temp_sheet2_line-data.clrRealRb      + p-clrRealRb
        buf_temp_sheet2_line-data.clrPOffSt       = buf_temp_sheet2_line-data.clrPOffSt      + p-clrPOffSt
        buf_temp_sheet2_line-data.clrPOffLt       = buf_temp_sheet2_line-data.clrPOffLt      + p-clrPOffLt
        buf_temp_sheet2_line-data.clrPOffRb       = buf_temp_sheet2_line-data.clrPOffRb      + p-clrPOffRb
        buf_temp_sheet2_line-data.trsRealExpsSt   = buf_temp_sheet2_line-data.trsRealExpsSt  + p-trsRealExpsSt
        buf_temp_sheet2_line-data.trsRealExpsLt   = buf_temp_sheet2_line-data.trsRealExpsLt  + p-trsRealExpsLt
        buf_temp_sheet2_line-data.trsRealIncmSt   = buf_temp_sheet2_line-data.trsRealIncmSt  + p-trsRealIncmSt
        buf_temp_sheet2_line-data.trsRealIncmLt   = buf_temp_sheet2_line-data.trsRealIncmLt  + p-trsRealIncmLt
        buf_temp_sheet2_line-data.trsRealTrnsSt   = buf_temp_sheet2_line-data.trsRealTrnsSt  + p-trsRealTrnsSt
        buf_temp_sheet2_line-data.trsRealTrnsLt   = buf_temp_sheet2_line-data.trsRealTrnsLt  + p-trsRealTrnsLt
        buf_temp_sheet2_line-data.trsPOffExpsSt   = buf_temp_sheet2_line-data.trsPOffExpsSt  + p-trsPOffExpsSt
        buf_temp_sheet2_line-data.trsPOffExpsLt   = buf_temp_sheet2_line-data.trsPOffExpsLt  + p-trsPOffExpsLt
        buf_temp_sheet2_line-data.trsPOffExpsRb   = buf_temp_sheet2_line-data.trsPOffExpsRb  + p-trsPOffExpsRb
        buf_temp_sheet2_line-data.trsPOffIncmSt   = buf_temp_sheet2_line-data.trsPOffIncmSt  + p-trsPOffIncmSt
        buf_temp_sheet2_line-data.trsPOffIncmLt   = buf_temp_sheet2_line-data.trsPOffIncmLt  + p-trsPOffIncmLt
        buf_temp_sheet2_line-data.trsPOffIncmRb   = buf_temp_sheet2_line-data.trsPOffIncmRb  + p-trsPOffIncmRb
        buf_temp_sheet2_line-data.trsPOffTrnsSt   = buf_temp_sheet2_line-data.trsPOffTrnsSt  + p-trsPOffTrnsSt
        buf_temp_sheet2_line-data.trsPOffTrnsLt   = buf_temp_sheet2_line-data.trsPOffTrnsLt  + p-trsPOffTrnsLt
        buf_temp_sheet2_line-data.trsPOffTrnsRb   = buf_temp_sheet2_line-data.trsPOffTrnsRb  + p-trsPOffTrnsRb
    .
end.
end procedure. /* rwthobxl-add-line-data */

/*==========================================================================*/
procedure rwthobxl-sheet2-write-line-data :

    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
    define buffer bf_temp_sheet2_line-data         for temp_sheet2_line-data.
    define buffer b_temp_sheet2_line-data          for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
  , bf_temp_sheet2_line-data
  , b_temp_sheet2_line-data
on error undo, return error
:
   /* Итого лист */
   create b_temp_sheet2_line-data.
   assign
      v-rwthobxl-sheet2-cur-data-row = v-rwthobxl-sheet2-cur-data-row + 1
   .
   assign
      b_temp_sheet2_line-data.sheet-name      = {&rwthobxl-sheet2-name}
      b_temp_sheet2_line-data.xl-line-id      = v-rwthobxl-sheet2-cur-data-row
      b_temp_sheet2_line-data.obj-type        = "":U
      b_temp_sheet2_line-data.obj-code        = 0
      b_temp_sheet2_line-data.total-code      = 2
      b_temp_sheet2_line-data.wth-code        = 0
      b_temp_sheet2_line-data.par-code        = 0
      b_temp_sheet2_line-data.goodsName       = "Итого:"
      b_temp_sheet2_line-data.wthPar          = "":U
      b_temp_sheet2_line-data.incIncmSt       = 0.0
      b_temp_sheet2_line-data.incIncmLt       = 0.0
      b_temp_sheet2_line-data.incRetnSt       = 0.0
      b_temp_sheet2_line-data.incRetnLt       = 0.0
      b_temp_sheet2_line-data.outSaleSt       = 0.0
      b_temp_sheet2_line-data.outSaleLt       = 0.0
      b_temp_sheet2_line-data.outSaleRb       = 0.0
      b_temp_sheet2_line-data.outExchSt       = 0.0
      b_temp_sheet2_line-data.outExchLt       = 0.0
      b_temp_sheet2_line-data.outExchRb       = 0.0
      b_temp_sheet2_line-data.payPaydDeskSt   = 0.0
      b_temp_sheet2_line-data.payPaydDeskLt   = 0.0
      b_temp_sheet2_line-data.payPaydDeskRb   = 0.0
      b_temp_sheet2_line-data.payPaydSt       = 0.0
      b_temp_sheet2_line-data.payPaydLt       = 0.0
      b_temp_sheet2_line-data.payPaydRb       = 0.0
      b_temp_sheet2_line-data.payExchSt       = 0.0
      b_temp_sheet2_line-data.payExchLt       = 0.0
      b_temp_sheet2_line-data.payExchRb       = 0.0
      b_temp_sheet2_line-data.payRetnSt       = 0.0
      b_temp_sheet2_line-data.payRetnLt       = 0.0
      b_temp_sheet2_line-data.payRetnRb       = 0.0
      b_temp_sheet2_line-data.clrRealSt       = 0.0
      b_temp_sheet2_line-data.clrRealLt       = 0.0
      b_temp_sheet2_line-data.clrRealRb       = 0.0
      b_temp_sheet2_line-data.clrPOffSt       = 0.0
      b_temp_sheet2_line-data.clrPOffLt       = 0.0
      b_temp_sheet2_line-data.clrPOffRb       = 0.0
      b_temp_sheet2_line-data.trsRealExpsSt   = 0.0
      b_temp_sheet2_line-data.trsRealExpsLt   = 0.0
      b_temp_sheet2_line-data.trsRealIncmSt   = 0.0
      b_temp_sheet2_line-data.trsRealIncmLt   = 0.0
      b_temp_sheet2_line-data.trsRealTrnsSt   = 0.0
      b_temp_sheet2_line-data.trsRealTrnsLt   = 0.0
      b_temp_sheet2_line-data.trsPOffExpsSt   = 0.0
      b_temp_sheet2_line-data.trsPOffExpsLt   = 0.0
      b_temp_sheet2_line-data.trsPOffExpsRb   = 0.0
      b_temp_sheet2_line-data.trsPOffIncmSt   = 0.0
      b_temp_sheet2_line-data.trsPOffIncmLt   = 0.0
      b_temp_sheet2_line-data.trsPOffIncmRb   = 0.0
      b_temp_sheet2_line-data.trsPOffTrnsSt   = 0.0
      b_temp_sheet2_line-data.trsPOffTrnsLt   = 0.0
      b_temp_sheet2_line-data.trsPOffTrnsRb   = 0.0
   .

    for each  buf_temp_sheet2_line-data
        WHERE buf_temp_sheet2_line-data.total-code = 0
    break by buf_temp_sheet2_line-data.total-code
          by buf_temp_sheet2_line-data.obj-type
          by buf_temp_sheet2_line-data.obj-code

    :
        if first-of ( buf_temp_sheet2_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                buf_temp_sheet2_line-data.sheet-name
                {&tabulation}   {&rwthobxl-data-label}
                {&tabulation}   substitute( "По объекту &1 &2", buf_temp_sheet2_line-data.obj-type, buf_temp_sheet2_line-data.obj-code )
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&tabulation}   " ":U
                {&new-line}
            .
            run rwthobxl-sheet2-write-line-format in this-procedure (
                input {&rwthobxl-FMT_Object}
            ).
            /* Итоги по объекту */
            find first bf_temp_sheet2_line-data
                 where bf_temp_sheet2_line-data.total-code = 1
                   and bf_temp_sheet2_line-data.obj-type   = buf_temp_sheet2_line-data.obj-type
                   and bf_temp_sheet2_line-data.obj-code   = buf_temp_sheet2_line-data.obj-code
                   and bf_temp_sheet2_line-data.wth-code   = 0
                   and bf_temp_sheet2_line-data.par-code   = 0
                  no-error
                  .
            if not available bf_temp_sheet2_line-data
            then do:
               create bf_temp_sheet2_line-data.
               assign
                     v-rwthobxl-sheet2-cur-data-row = v-rwthobxl-sheet2-cur-data-row + 1
               .
               assign
                     bf_temp_sheet2_line-data.sheet-name      = {&rwthobxl-sheet2-name}
                     bf_temp_sheet2_line-data.xl-line-id      = v-rwthobxl-sheet2-cur-data-row
                     bf_temp_sheet2_line-data.obj-type        = buf_temp_sheet2_line-data.obj-type
                     bf_temp_sheet2_line-data.obj-code        = buf_temp_sheet2_line-data.obj-code
                     bf_temp_sheet2_line-data.total-code      = 1
                     bf_temp_sheet2_line-data.wth-code        = 0
                     bf_temp_sheet2_line-data.par-code        = 0
                     bf_temp_sheet2_line-data.goodsName       = SUBSTITUTE("Итого по объекту &1 &2:", buf_temp_sheet2_line-data.obj-type, buf_temp_sheet2_line-data.obj-code)
                     bf_temp_sheet2_line-data.wthPar          = "":U
                     bf_temp_sheet2_line-data.incIncmSt       = 0.0
                     bf_temp_sheet2_line-data.incIncmLt       = 0.0
                     bf_temp_sheet2_line-data.incRetnSt       = 0.0
                     bf_temp_sheet2_line-data.incRetnLt       = 0.0
                     bf_temp_sheet2_line-data.outSaleSt       = 0.0
                     bf_temp_sheet2_line-data.outSaleLt       = 0.0
                     bf_temp_sheet2_line-data.outSaleRb       = 0.0
                     bf_temp_sheet2_line-data.outExchSt       = 0.0
                     bf_temp_sheet2_line-data.outExchLt       = 0.0
                     bf_temp_sheet2_line-data.outExchRb       = 0.0
                     bf_temp_sheet2_line-data.payPaydDeskSt   = 0.0
                     bf_temp_sheet2_line-data.payPaydDeskLt   = 0.0
                     bf_temp_sheet2_line-data.payPaydDeskRb   = 0.0
                     bf_temp_sheet2_line-data.payPaydSt       = 0.0
                     bf_temp_sheet2_line-data.payPaydLt       = 0.0
                     bf_temp_sheet2_line-data.payPaydRb       = 0.0
                     bf_temp_sheet2_line-data.payExchSt       = 0.0
                     bf_temp_sheet2_line-data.payExchLt       = 0.0
                     bf_temp_sheet2_line-data.payExchRb       = 0.0
                     bf_temp_sheet2_line-data.payRetnSt       = 0.0
                     bf_temp_sheet2_line-data.payRetnLt       = 0.0
                     bf_temp_sheet2_line-data.payRetnRb       = 0.0
                     bf_temp_sheet2_line-data.clrRealSt       = 0.0
                     bf_temp_sheet2_line-data.clrRealLt       = 0.0
                     bf_temp_sheet2_line-data.clrRealRb       = 0.0
                     bf_temp_sheet2_line-data.clrPOffSt       = 0.0
                     bf_temp_sheet2_line-data.clrPOffLt       = 0.0
                     bf_temp_sheet2_line-data.clrPOffRb       = 0.0
                     bf_temp_sheet2_line-data.trsRealExpsSt   = 0.0
                     bf_temp_sheet2_line-data.trsRealExpsLt   = 0.0
                     bf_temp_sheet2_line-data.trsRealIncmSt   = 0.0
                     bf_temp_sheet2_line-data.trsRealIncmLt   = 0.0
                     bf_temp_sheet2_line-data.trsRealTrnsSt   = 0.0
                     bf_temp_sheet2_line-data.trsRealTrnsLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffExpsSt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffExpsLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffExpsRb   = 0.0
                     bf_temp_sheet2_line-data.trsPOffIncmSt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffIncmLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffIncmRb   = 0.0
                     bf_temp_sheet2_line-data.trsPOffTrnsSt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffTrnsLt   = 0.0
                     bf_temp_sheet2_line-data.trsPOffTrnsRb   = 0.0
               .
            end.

        end.
        put stream excel-line unformatted
                            buf_temp_sheet2_line-data.sheet-name
            {&tabulation}   {&rwthobxl-data-label}
            {&tabulation}   buf_temp_sheet2_line-data.goodsName
            {&tabulation}   buf_temp_sheet2_line-data.wthPar
            {&tabulation}   string( buf_temp_sheet2_line-data.incIncmSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.incIncmLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.incRetnSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.incRetnLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.outSaleSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.outSaleLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.outSaleRb     )
            {&tabulation}   string( buf_temp_sheet2_line-data.outExchSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.outExchLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.outExchRb     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payPaydDeskSt )
            {&tabulation}   string( buf_temp_sheet2_line-data.payPaydDeskLt )
            {&tabulation}   string( buf_temp_sheet2_line-data.payPaydDeskRb )
            {&tabulation}   string( buf_temp_sheet2_line-data.payPaydSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payPaydLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payPaydRb     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payExchSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payExchLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payExchRb     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payRetnSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payRetnLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.payRetnRb     )
            {&tabulation}   string( buf_temp_sheet2_line-data.clrRealSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.clrRealLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.clrRealRb     )
            {&tabulation}   string( buf_temp_sheet2_line-data.clrPOffSt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.clrPOffLt     )
            {&tabulation}   string( buf_temp_sheet2_line-data.clrPOffRb     )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsRealExpsSt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsRealExpsLt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsRealIncmSt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsRealIncmLt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsRealTrnsSt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsRealTrnsLt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffExpsSt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffExpsLt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffExpsRb )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffIncmSt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffIncmLt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffIncmRb )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffTrnsSt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffTrnsLt )
            {&tabulation}   string( buf_temp_sheet2_line-data.trsPOffTrnsRb )
            {&new-line}
        .
         assign
            bf_temp_sheet2_line-data.incIncmSt       = bf_temp_sheet2_line-data.incIncmSt      + buf_temp_sheet2_line-data.incIncmSt
            bf_temp_sheet2_line-data.incIncmLt       = bf_temp_sheet2_line-data.incIncmLt      + buf_temp_sheet2_line-data.incIncmLt
            bf_temp_sheet2_line-data.incRetnSt       = bf_temp_sheet2_line-data.incRetnSt      + buf_temp_sheet2_line-data.incRetnSt
            bf_temp_sheet2_line-data.incRetnLt       = bf_temp_sheet2_line-data.incRetnLt      + buf_temp_sheet2_line-data.incRetnLt
            bf_temp_sheet2_line-data.outSaleSt       = bf_temp_sheet2_line-data.outSaleSt      + buf_temp_sheet2_line-data.outSaleSt
            bf_temp_sheet2_line-data.outSaleLt       = bf_temp_sheet2_line-data.outSaleLt      + buf_temp_sheet2_line-data.outSaleLt
            bf_temp_sheet2_line-data.outSaleRb       = bf_temp_sheet2_line-data.outSaleRb      + buf_temp_sheet2_line-data.outSaleRb
            bf_temp_sheet2_line-data.outExchSt       = bf_temp_sheet2_line-data.outExchSt      + buf_temp_sheet2_line-data.outExchSt
            bf_temp_sheet2_line-data.outExchLt       = bf_temp_sheet2_line-data.outExchLt      + buf_temp_sheet2_line-data.outExchLt
            bf_temp_sheet2_line-data.outExchRb       = bf_temp_sheet2_line-data.outExchRb      + buf_temp_sheet2_line-data.outExchRb
            bf_temp_sheet2_line-data.payPaydDeskSt   = bf_temp_sheet2_line-data.payPaydDeskSt  + buf_temp_sheet2_line-data.payPaydDeskSt
            bf_temp_sheet2_line-data.payPaydDeskLt   = bf_temp_sheet2_line-data.payPaydDeskLt  + buf_temp_sheet2_line-data.payPaydDeskLt
            bf_temp_sheet2_line-data.payPaydDeskRb   = bf_temp_sheet2_line-data.payPaydDeskRb  + buf_temp_sheet2_line-data.payPaydDeskRb
            bf_temp_sheet2_line-data.payPaydSt       = bf_temp_sheet2_line-data.payPaydSt      + buf_temp_sheet2_line-data.payPaydSt
            bf_temp_sheet2_line-data.payPaydLt       = bf_temp_sheet2_line-data.payPaydLt      + buf_temp_sheet2_line-data.payPaydLt
            bf_temp_sheet2_line-data.payPaydRb       = bf_temp_sheet2_line-data.payPaydRb      + buf_temp_sheet2_line-data.payPaydRb
            bf_temp_sheet2_line-data.payExchSt       = bf_temp_sheet2_line-data.payExchSt      + buf_temp_sheet2_line-data.payExchSt
            bf_temp_sheet2_line-data.payExchLt       = bf_temp_sheet2_line-data.payExchLt      + buf_temp_sheet2_line-data.payExchLt
            bf_temp_sheet2_line-data.payExchRb       = bf_temp_sheet2_line-data.payExchRb      + buf_temp_sheet2_line-data.payExchRb
            bf_temp_sheet2_line-data.payRetnSt       = bf_temp_sheet2_line-data.payRetnSt      + buf_temp_sheet2_line-data.payRetnSt
            bf_temp_sheet2_line-data.payRetnLt       = bf_temp_sheet2_line-data.payRetnLt      + buf_temp_sheet2_line-data.payRetnLt
            bf_temp_sheet2_line-data.payRetnRb       = bf_temp_sheet2_line-data.payRetnRb      + buf_temp_sheet2_line-data.payRetnRb
            bf_temp_sheet2_line-data.clrRealSt       = bf_temp_sheet2_line-data.clrRealSt      + buf_temp_sheet2_line-data.clrRealSt
            bf_temp_sheet2_line-data.clrRealLt       = bf_temp_sheet2_line-data.clrRealLt      + buf_temp_sheet2_line-data.clrRealLt
            bf_temp_sheet2_line-data.clrRealRb       = bf_temp_sheet2_line-data.clrRealRb      + buf_temp_sheet2_line-data.clrRealRb
            bf_temp_sheet2_line-data.clrPOffSt       = bf_temp_sheet2_line-data.clrPOffSt      + buf_temp_sheet2_line-data.clrPOffSt
            bf_temp_sheet2_line-data.clrPOffLt       = bf_temp_sheet2_line-data.clrPOffLt      + buf_temp_sheet2_line-data.clrPOffLt
            bf_temp_sheet2_line-data.clrPOffRb       = bf_temp_sheet2_line-data.clrPOffRb      + buf_temp_sheet2_line-data.clrPOffRb
            bf_temp_sheet2_line-data.trsRealExpsSt   = bf_temp_sheet2_line-data.trsRealExpsSt  + buf_temp_sheet2_line-data.trsRealExpsSt
            bf_temp_sheet2_line-data.trsRealExpsLt   = bf_temp_sheet2_line-data.trsRealExpsLt  + buf_temp_sheet2_line-data.trsRealExpsLt
            bf_temp_sheet2_line-data.trsRealIncmSt   = bf_temp_sheet2_line-data.trsRealIncmSt  + buf_temp_sheet2_line-data.trsRealIncmSt
            bf_temp_sheet2_line-data.trsRealIncmLt   = bf_temp_sheet2_line-data.trsRealIncmLt  + buf_temp_sheet2_line-data.trsRealIncmLt
            bf_temp_sheet2_line-data.trsRealTrnsSt   = bf_temp_sheet2_line-data.trsRealTrnsSt  + buf_temp_sheet2_line-data.trsRealTrnsSt
            bf_temp_sheet2_line-data.trsRealTrnsLt   = bf_temp_sheet2_line-data.trsRealTrnsLt  + buf_temp_sheet2_line-data.trsRealTrnsLt
            bf_temp_sheet2_line-data.trsPOffExpsSt   = bf_temp_sheet2_line-data.trsPOffExpsSt  + buf_temp_sheet2_line-data.trsPOffExpsSt
            bf_temp_sheet2_line-data.trsPOffExpsLt   = bf_temp_sheet2_line-data.trsPOffExpsLt  + buf_temp_sheet2_line-data.trsPOffExpsLt
            bf_temp_sheet2_line-data.trsPOffExpsRb   = bf_temp_sheet2_line-data.trsPOffExpsRb  + buf_temp_sheet2_line-data.trsPOffExpsRb
            bf_temp_sheet2_line-data.trsPOffIncmSt   = bf_temp_sheet2_line-data.trsPOffIncmSt  + buf_temp_sheet2_line-data.trsPOffIncmSt
            bf_temp_sheet2_line-data.trsPOffIncmLt   = bf_temp_sheet2_line-data.trsPOffIncmLt  + buf_temp_sheet2_line-data.trsPOffIncmLt
            bf_temp_sheet2_line-data.trsPOffIncmRb   = bf_temp_sheet2_line-data.trsPOffIncmRb  + buf_temp_sheet2_line-data.trsPOffIncmRb
            bf_temp_sheet2_line-data.trsPOffTrnsSt   = bf_temp_sheet2_line-data.trsPOffTrnsSt  + buf_temp_sheet2_line-data.trsPOffTrnsSt
            bf_temp_sheet2_line-data.trsPOffTrnsLt   = bf_temp_sheet2_line-data.trsPOffTrnsLt  + buf_temp_sheet2_line-data.trsPOffTrnsLt
            bf_temp_sheet2_line-data.trsPOffTrnsRb   = bf_temp_sheet2_line-data.trsPOffTrnsRb  + buf_temp_sheet2_line-data.trsPOffTrnsRb

            b_temp_sheet2_line-data.incIncmSt       = b_temp_sheet2_line-data.incIncmSt      + buf_temp_sheet2_line-data.incIncmSt
            b_temp_sheet2_line-data.incIncmLt       = b_temp_sheet2_line-data.incIncmLt      + buf_temp_sheet2_line-data.incIncmLt
            b_temp_sheet2_line-data.incRetnSt       = b_temp_sheet2_line-data.incRetnSt      + buf_temp_sheet2_line-data.incRetnSt
            b_temp_sheet2_line-data.incRetnLt       = b_temp_sheet2_line-data.incRetnLt      + buf_temp_sheet2_line-data.incRetnLt
            b_temp_sheet2_line-data.outSaleSt       = b_temp_sheet2_line-data.outSaleSt      + buf_temp_sheet2_line-data.outSaleSt
            b_temp_sheet2_line-data.outSaleLt       = b_temp_sheet2_line-data.outSaleLt      + buf_temp_sheet2_line-data.outSaleLt
            b_temp_sheet2_line-data.outSaleRb       = b_temp_sheet2_line-data.outSaleRb      + buf_temp_sheet2_line-data.outSaleRb
            b_temp_sheet2_line-data.outExchSt       = b_temp_sheet2_line-data.outExchSt      + buf_temp_sheet2_line-data.outExchSt
            b_temp_sheet2_line-data.outExchLt       = b_temp_sheet2_line-data.outExchLt      + buf_temp_sheet2_line-data.outExchLt
            b_temp_sheet2_line-data.outExchRb       = b_temp_sheet2_line-data.outExchRb      + buf_temp_sheet2_line-data.outExchRb
            b_temp_sheet2_line-data.payPaydDeskSt   = b_temp_sheet2_line-data.payPaydDeskSt  + buf_temp_sheet2_line-data.payPaydDeskSt
            b_temp_sheet2_line-data.payPaydDeskLt   = b_temp_sheet2_line-data.payPaydDeskLt  + buf_temp_sheet2_line-data.payPaydDeskLt
            b_temp_sheet2_line-data.payPaydDeskRb   = b_temp_sheet2_line-data.payPaydDeskRb  + buf_temp_sheet2_line-data.payPaydDeskRb
            b_temp_sheet2_line-data.payPaydSt       = b_temp_sheet2_line-data.payPaydSt      + buf_temp_sheet2_line-data.payPaydSt
            b_temp_sheet2_line-data.payPaydLt       = b_temp_sheet2_line-data.payPaydLt      + buf_temp_sheet2_line-data.payPaydLt
            b_temp_sheet2_line-data.payPaydRb       = b_temp_sheet2_line-data.payPaydRb      + buf_temp_sheet2_line-data.payPaydRb
            b_temp_sheet2_line-data.payExchSt       = b_temp_sheet2_line-data.payExchSt      + buf_temp_sheet2_line-data.payExchSt
            b_temp_sheet2_line-data.payExchLt       = b_temp_sheet2_line-data.payExchLt      + buf_temp_sheet2_line-data.payExchLt
            b_temp_sheet2_line-data.payExchRb       = b_temp_sheet2_line-data.payExchRb      + buf_temp_sheet2_line-data.payExchRb
            b_temp_sheet2_line-data.payRetnSt       = b_temp_sheet2_line-data.payRetnSt      + buf_temp_sheet2_line-data.payRetnSt
            b_temp_sheet2_line-data.payRetnLt       = b_temp_sheet2_line-data.payRetnLt      + buf_temp_sheet2_line-data.payRetnLt
            b_temp_sheet2_line-data.payRetnRb       = b_temp_sheet2_line-data.payRetnRb      + buf_temp_sheet2_line-data.payRetnRb
            b_temp_sheet2_line-data.clrRealSt       = b_temp_sheet2_line-data.clrRealSt      + buf_temp_sheet2_line-data.clrRealSt
            b_temp_sheet2_line-data.clrRealLt       = b_temp_sheet2_line-data.clrRealLt      + buf_temp_sheet2_line-data.clrRealLt
            b_temp_sheet2_line-data.clrRealRb       = b_temp_sheet2_line-data.clrRealRb      + buf_temp_sheet2_line-data.clrRealRb
            b_temp_sheet2_line-data.clrPOffSt       = b_temp_sheet2_line-data.clrPOffSt      + buf_temp_sheet2_line-data.clrPOffSt
            b_temp_sheet2_line-data.clrPOffLt       = b_temp_sheet2_line-data.clrPOffLt      + buf_temp_sheet2_line-data.clrPOffLt
            b_temp_sheet2_line-data.clrPOffRb       = b_temp_sheet2_line-data.clrPOffRb      + buf_temp_sheet2_line-data.clrPOffRb
            b_temp_sheet2_line-data.trsRealExpsSt   = b_temp_sheet2_line-data.trsRealExpsSt  + buf_temp_sheet2_line-data.trsRealExpsSt
            b_temp_sheet2_line-data.trsRealExpsLt   = b_temp_sheet2_line-data.trsRealExpsLt  + buf_temp_sheet2_line-data.trsRealExpsLt
            b_temp_sheet2_line-data.trsRealIncmSt   = b_temp_sheet2_line-data.trsRealIncmSt  + buf_temp_sheet2_line-data.trsRealIncmSt
            b_temp_sheet2_line-data.trsRealIncmLt   = b_temp_sheet2_line-data.trsRealIncmLt  + buf_temp_sheet2_line-data.trsRealIncmLt
            b_temp_sheet2_line-data.trsRealTrnsSt   = b_temp_sheet2_line-data.trsRealTrnsSt  + buf_temp_sheet2_line-data.trsRealTrnsSt
            b_temp_sheet2_line-data.trsRealTrnsLt   = b_temp_sheet2_line-data.trsRealTrnsLt  + buf_temp_sheet2_line-data.trsRealTrnsLt
            b_temp_sheet2_line-data.trsPOffExpsSt   = b_temp_sheet2_line-data.trsPOffExpsSt  + buf_temp_sheet2_line-data.trsPOffExpsSt
            b_temp_sheet2_line-data.trsPOffExpsLt   = b_temp_sheet2_line-data.trsPOffExpsLt  + buf_temp_sheet2_line-data.trsPOffExpsLt
            b_temp_sheet2_line-data.trsPOffExpsRb   = b_temp_sheet2_line-data.trsPOffExpsRb  + buf_temp_sheet2_line-data.trsPOffExpsRb
            b_temp_sheet2_line-data.trsPOffIncmSt   = b_temp_sheet2_line-data.trsPOffIncmSt  + buf_temp_sheet2_line-data.trsPOffIncmSt
            b_temp_sheet2_line-data.trsPOffIncmLt   = b_temp_sheet2_line-data.trsPOffIncmLt  + buf_temp_sheet2_line-data.trsPOffIncmLt
            b_temp_sheet2_line-data.trsPOffIncmRb   = b_temp_sheet2_line-data.trsPOffIncmRb  + buf_temp_sheet2_line-data.trsPOffIncmRb
            b_temp_sheet2_line-data.trsPOffTrnsSt   = b_temp_sheet2_line-data.trsPOffTrnsSt  + buf_temp_sheet2_line-data.trsPOffTrnsSt
            b_temp_sheet2_line-data.trsPOffTrnsLt   = b_temp_sheet2_line-data.trsPOffTrnsLt  + buf_temp_sheet2_line-data.trsPOffTrnsLt
            b_temp_sheet2_line-data.trsPOffTrnsRb   = b_temp_sheet2_line-data.trsPOffTrnsRb  + buf_temp_sheet2_line-data.trsPOffTrnsRb
         .

        /* ИТОГО по объекту */
        if last-of ( buf_temp_sheet2_line-data.obj-code )
        then do:
            put stream excel-line unformatted
                                 bf_temp_sheet2_line-data.sheet-name
                  {&tabulation}  {&rwthobxl-data-label}
                  {&tabulation}  bf_temp_sheet2_line-data.goodsName
                  {&tabulation}  bf_temp_sheet2_line-data.wthPar
                  {&tabulation}  string( bf_temp_sheet2_line-data.incIncmSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.incIncmLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.incRetnSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.incRetnLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.outSaleSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.outSaleLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.outSaleRb     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.outExchSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.outExchLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.outExchRb     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payPaydDeskSt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payPaydDeskLt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payPaydDeskRb )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payPaydSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payPaydLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payPaydRb     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payExchSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payExchLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payExchRb     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payRetnSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payRetnLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.payRetnRb     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.clrRealSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.clrRealLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.clrRealRb     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.clrPOffSt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.clrPOffLt     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.clrPOffRb     )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsRealExpsSt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsRealExpsLt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsRealIncmSt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsRealIncmLt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsRealTrnsSt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsRealTrnsLt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffExpsSt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffExpsLt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffExpsRb )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffIncmSt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffIncmLt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffIncmRb )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffTrnsSt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffTrnsLt )
                  {&tabulation}  string( bf_temp_sheet2_line-data.trsPOffTrnsRb )
                  {&new-line}
            .
        END.
    end.
    put stream excel-line unformatted
                        b_temp_sheet2_line-data.sheet-name
         {&tabulation}  {&rwthobxl-data-label}
         {&tabulation}  b_temp_sheet2_line-data.goodsName
         {&tabulation}  b_temp_sheet2_line-data.wthPar
         {&tabulation}  string( b_temp_sheet2_line-data.incIncmSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.incIncmLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.incRetnSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.incRetnLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.outSaleSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.outSaleLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.outSaleRb     )
         {&tabulation}  string( b_temp_sheet2_line-data.outExchSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.outExchLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.outExchRb     )
         {&tabulation}  string( b_temp_sheet2_line-data.payPaydDeskSt )
         {&tabulation}  string( b_temp_sheet2_line-data.payPaydDeskLt )
         {&tabulation}  string( b_temp_sheet2_line-data.payPaydDeskRb )
         {&tabulation}  string( b_temp_sheet2_line-data.payPaydSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.payPaydLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.payPaydRb     )
         {&tabulation}  string( b_temp_sheet2_line-data.payExchSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.payExchLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.payExchRb     )
         {&tabulation}  string( b_temp_sheet2_line-data.payRetnSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.payRetnLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.payRetnRb     )
         {&tabulation}  string( b_temp_sheet2_line-data.clrRealSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.clrRealLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.clrRealRb     )
         {&tabulation}  string( b_temp_sheet2_line-data.clrPOffSt     )
         {&tabulation}  string( b_temp_sheet2_line-data.clrPOffLt     )
         {&tabulation}  string( b_temp_sheet2_line-data.clrPOffRb     )
         {&tabulation}  string( b_temp_sheet2_line-data.trsRealExpsSt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsRealExpsLt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsRealIncmSt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsRealIncmLt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsRealTrnsSt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsRealTrnsLt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffExpsSt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffExpsLt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffExpsRb )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffIncmSt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffIncmLt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffIncmRb )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffTrnsSt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffTrnsLt )
         {&tabulation}  string( b_temp_sheet2_line-data.trsPOffTrnsRb )
         {&new-line}
    .
end.
end procedure. /* rwthobxl-sheet2-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure rwthobxl-write-cell-data :
define input parameter p-data-key   as character        no-undo.
define input parameter p-data-value as character        no-undo.

    define buffer buf_temp_cell-data     for temp_cell-data.
do
for buf_temp_cell-data
on error undo, return error
:
    find first buf_temp_cell-data
         where buf_temp_cell-data.data-key = p-data-key
    no-error.
    if not available buf_temp_cell-data
    then do:
        create buf_temp_cell-data.
        assign
            buf_temp_cell-data.data-key = p-data-key
        .
    end.
    assign
        buf_temp_cell-data.data-value = p-data-value
    .
    put stream excel-cell unformatted
                        buf_temp_cell-data.data-key
        {&tabulation}   buf_temp_cell-data.data-value
        {&new-line}
    .
end.
end procedure. /* rwthobxl-write-cell-data */

/*==========================================================================*/
procedure rwthobxl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.

    define variable v-template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.

    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/rwthob.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
/*    assign*/
/*        v-template-file-name = search( v-template-file-name )*/
/*    .*/
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Ошибка имени файла шаблона."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Ошибка имени файла кода обработки."
        view-as alert-box error.
    end.
    run paramls-write in this-procedure (
          input {&paramls-template}
        , input {&paramls-template-file-name}
        , input v-template-file-name
    ).
    run paramls-write in this-procedure (
          input {&paramls-template}
        , input {&paramls-vb-file-name}
        , input v-vb-file-name
    ).
    run paramls-write in this-procedure (
          input {&paramls-data}
        , input {&paramls-data-header-filename}
        , input p-header-filename
    ).
    run paramls-write in this-procedure (
          input {&paramls-data}
        , input {&paramls-data-filename}
        , input p-data-filename
    ).
    run gbl/macroxlt.p (
        input-output table buf_temp-param
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка создания файла Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure. /* rwthobxl-run-excel */


/*==========================================================================*/
procedure rwthobxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/rwthob.xlt":U.
        export "exe/t_form.bas":U.
        export v-rwthobxl-cell-file-name.
        export v-rwthobxl-data-file-name.
    output close.
end.
end procedure. /* rwthobxl-close */

/*==========================================================================*/
procedure rwthobxl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&rwthobxl-sheet1-name}
        {&tabulation}   {&rwthobxl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* rwthobxl-sheet1-write-line-format */

/*==========================================================================*/
procedure rwthobxl-sheet2-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&rwthobxl-sheet2-name}
        {&tabulation}   {&rwthobxl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* rwthobxl-sheet2-write-line-format */

/*==========================================================================*/
procedure rwthobxl-sheet3-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet3_line-data        for temp_sheet3_line-data.
do
for buf_temp_sheet3_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&rwthobxl-sheet3-name}
        {&tabulation}   {&rwthobxl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* rwthobxl-sheet3-write-line-format */

/* $Workfile$ e n d */