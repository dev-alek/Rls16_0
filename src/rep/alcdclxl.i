/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Калуга) в Excel

Автор: Кочетков Михаил Юрьевич
Дата создания: 12/21/06
Author: Michael Kochetkov
Creation date: 12/21/06

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define alcdclxl-data-label "DTA":U
&global-define alcdclxl-format-label "FMT":U

&global-define alcdclxl-sheetList  "Продажа,Поставщики":U

&global-define alcdclxl-sheet1_valutCode       "Продажа_valutCode":U
&global-define alcdclxl-sheet1_columnList      "Продажа_columnList":U
&global-define alcdclxl-sheet1_columnType      "Продажа_columnType":U
&global-define alcdclxl-sheet1_subtotalList    "Продажа_subtotalList":U
&global-define alcdclxl-sheet1_subtotalType    "Продажа_subtotalType":U

&global-define alcdclxl-sheet2_valutCode       "Поставщики_valutCode":U
&global-define alcdclxl-sheet2_columnList      "Поставщики_columnList":U
&global-define alcdclxl-sheet2_columnType      "Поставщики_columnType":U
&global-define alcdclxl-sheet2_subtotalList    "Поставщики_subtotalList":U
&global-define alcdclxl-sheet2_subtotalType    "Поставщики_subtotalType":U

&global-define alcdclxl-orgname       "orgname":U
&global-define alcdclxl-orghinn       "orghinn":U
&global-define alcdclxl-hostegrip     "hostegrip":U
&global-define alcdclxl-addr          "addr":U
&global-define alcdclxl-sertificate   "sertificate":U
&global-define alcdclxl-f_date        "f_date":U

&global-define alcdclxl-sheet1-name "Продажа":U

&global-define alcdclxl-sheet1-it-seaname      "Продажа_it_seaname":U
&global-define alcdclxl-sheet1-it-seacode      "Продажа_it_seacode":U
&global-define alcdclxl-sheet1-it-ostbegtot    "Продажа_it_ostbegtot":U
&global-define alcdclxl-sheet1-it-ostbeglocal  "Продажа_it_ostbeglocal":U
&global-define alcdclxl-sheet1-it-ostbegregion "Продажа_it_ostbegregion":U
&global-define alcdclxl-sheet1-it-ostbegimp    "Продажа_it_ostbegimp":U
&global-define alcdclxl-sheet1-it-pritot       "Продажа_it_pritot":U
&global-define alcdclxl-sheet1-it-prilocal     "Продажа_it_prilocal":U
&global-define alcdclxl-sheet1-it-priregion    "Продажа_it_priregion":U
&global-define alcdclxl-sheet1-it-priimp       "Продажа_it_priimp":U
&global-define alcdclxl-sheet1-it-saletot      "Продажа_it_saletot":U
&global-define alcdclxl-sheet1-it-salelocal    "Продажа_it_salelocal":U
&global-define alcdclxl-sheet1-it-saleregion   "Продажа_it_saleregion":U
&global-define alcdclxl-sheet1-it-saleimp      "Продажа_it_saleimp":U
&global-define alcdclxl-sheet1-it-rettot       "Продажа_it_rettot":U
&global-define alcdclxl-sheet1-it-retlocal     "Продажа_it_retlocal":U
&global-define alcdclxl-sheet1-it-retregion    "Продажа_it_retregion":U
&global-define alcdclxl-sheet1-it-retimp       "Продажа_it_retimp":U
&global-define alcdclxl-sheet1-it-othtot       "Продажа_it_othtot":U
&global-define alcdclxl-sheet1-it-othlocal     "Продажа_it_othlocal":U
&global-define alcdclxl-sheet1-it-othregion    "Продажа_it_othregion":U
&global-define alcdclxl-sheet1-it-othimp       "Продажа_it_othimp":U
&global-define alcdclxl-sheet1-it-ostendtot    "Продажа_it_ostendtot":U
&global-define alcdclxl-sheet1-it-ostendlocal  "Продажа_it_ostendlocal":U
&global-define alcdclxl-sheet1-it-ostendregion "Продажа_it_ostendregion":U
&global-define alcdclxl-sheet1-it-ostendimp    "Продажа_it_ostendimp":U

&global-define alcdclxl-sheet2-name "Поставщики":U

&global-define alcdclxl-sheet2-it-cliname           "Поставщики_it_cliname":U
&global-define alcdclxl-sheet2-it-cliinn            "Поставщики_it_cliinn":U
&global-define alcdclxl-sheet2-it-cliaddress        "Поставщики_it_cliaddress":U
&global-define alcdclxl-sheet2-it-cliregioncode     "Поставщики_it_cliregioncode":U
&global-define alcdclxl-sheet2-it-licnum            "Поставщики_it_licnum":U
&global-define alcdclxl-sheet2-it-licgive           "Поставщики_it_licgive":U
&global-define alcdclxl-sheet2-it-shipdate          "Поставщики_it_shipdate":U
&global-define alcdclxl-sheet2-it-seaname           "Поставщики_it_seaname":U
&global-define alcdclxl-sheet2-it-seacode           "Поставщики_it_seacode":U
&global-define alcdclxl-sheet2-it-prodtype          "Поставщики_it_prodtype":U
&global-define alcdclxl-sheet2-it-quantity          "Поставщики_it_quantity":U

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
    field seaname       as character
    field seacode       as character
/*    field ostbegtot     as character*/
    field ostbeglocal   as character
    field ostbegregion  as character
    field ostbegimp     as character
/*    field pritot        as character*/
    field prilocal      as character
    field priregion     as character
    field priimp        as character
/*    field saletot       as character*/
    field salelocal     as character
    field saleregion    as character
    field saleimp       as character
/*    field rettot        as character*/
    field retlocal      as character
    field retregion     as character
    field retimp        as character
/*    field othtot        as character*/
    field othlocal      as character
    field othregion     as character
    field othimp        as character
/*    field ostendtot     as character*/
/*    field ostendlocal   as character*/
/*    field ostendregion  as character*/
/*    field ostendimp     as character*/

    index pi is primary unique
        xl-line-id
.

define temp-table temp_sheet2_line-data no-undo
    field sheet-name      as character
    field xl-line-id      as integer
    field cliname         as character
    field cliinn          as character
    field cliaddress      as character
    field cliregioncode   as character
    field licnum          as character
    field licgive         as character
    field shipdate        as character
    field seaname         as character
    field seacode         as character
    field prodtype        as character
    field quantity        as character

    index pi is primary unique
        xl-line-id
.

define variable v-alcdclxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-alcdclxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-alcdclxl-cell-file-name       as character    no-undo.
define variable v-alcdclxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure alcdclxl-init :

do
on error undo, return error
:
    assign
        v-alcdclxl-sheet1-cur-data-row = 0
        v-alcdclxl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-alcdclxl-data-file-name
    ).
    output stream excel-line to value( v-alcdclxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-alcdclxl-cell-file-name
    ).
    output stream excel-cell to value( v-alcdclxl-cell-file-name ).
    run alcdclxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&alcdclxl-sheetList}
    ).

    printrubl = true .

    if printrubl
    then do:
        run alcdclxl-write-cell-data in this-procedure (
              input {&alcdclxl-sheet1_valutCode}
            , input "0":U
        ).
        run alcdclxl-write-cell-data in this-procedure (
              input {&alcdclxl-sheet2_valutCode}
            , input "0":U
        ).

    end.
    else do:
        run alcdclxl-write-cell-data in this-procedure (
              input {&alcdclxl-sheet1_valutCode}
            , input "1":U
        ).
        run alcdclxl-write-cell-data in this-procedure (
              input {&alcdclxl-sheet2_valutCode}
            , input "1":U
        ).

    end.

/*    run alcdclxl-write-cell-data in this-procedure (*/
/*          input {&alcdclxl-sheet1_columnList}*/
/*        , input "seaname,seacode,ostbegtot,ostbeglocal,ostbegregion,ostbegimp,pritot,prilocal,priregion,priimp,saletot,salelocal,saleregion,saleimp,rettot,retlocal,retregion,retimp,othtot,othlocal,othregion,othimp,ostendtot,ostendlocal,ostendregion,ostendimp":U*/
/*    ).*/
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet1_columnList}
        , input "seaname,seacode,ostbeglocal,ostbegregion,ostbegimp,prilocal,priregion,priimp,salelocal,saleregion,saleimp,retlocal,retregion,retimp,othlocal,othregion,othimp":U
    ).
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet1_columnType}
        , input "S,I,D,D,D,D,D,D,D,D,D,D,D,D,D,D,D":U
    ).
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet1_subtotalList}
        , input "":U
    ).
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet1_subtotalType}
        , input "":U
    ).
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet2_columnList}
        , input "cliname,cliinn,cliaddress,cliregioncode,licnum,licgive,shipdate,seaname,seacode,prodtype,quantity":U
    ).
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet2_columnType}
        , input "S,S,S,S,S,S,S,S,S,I,D":U
    ).
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet2_subtotalList}
        , input "":U
    ).
    run alcdclxl-write-cell-data in this-procedure (
          input {&alcdclxl-sheet2_subtotalType}
        , input "":U
    ).
end.
end procedure. /* alcdclxl-init */

/*==========================================================================*/
procedure alcdclxl-sheet1-write-line-data :
define input parameter p-seaname        as character        no-undo.
define input parameter p-seacode        as character        no-undo.
define input parameter p-ostbegtot      as character        no-undo.
define input parameter p-ostbeglocal    as character        no-undo.
define input parameter p-ostbegregion   as character        no-undo.
define input parameter p-ostbegimp      as character        no-undo.
define input parameter p-pritot         as character        no-undo.
define input parameter p-prilocal       as character        no-undo.
define input parameter p-priregion      as character        no-undo.
define input parameter p-priimp         as character        no-undo.
define input parameter p-saletot        as character        no-undo.
define input parameter p-salelocal      as character        no-undo.
define input parameter p-saleregion     as character        no-undo.
define input parameter p-saleimp        as character        no-undo.
define input parameter p-rettot         as character        no-undo.
define input parameter p-retlocal       as character        no-undo.
define input parameter p-retregion      as character        no-undo.
define input parameter p-retimp         as character        no-undo.
define input parameter p-othtot         as character        no-undo.
define input parameter p-othlocal       as character        no-undo.
define input parameter p-othregion      as character        no-undo.
define input parameter p-othimp         as character        no-undo.
define input parameter p-ostendtot      as character        no-undo.
define input parameter p-ostendlocal    as character        no-undo.
define input parameter p-ostendregion   as character        no-undo.
define input parameter p-ostendimp      as character        no-undo.

    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    for each buf_temp_sheet1_line-data
    :
        delete buf_temp_sheet1_line-data.
    end.
    create buf_temp_sheet1_line-data.
    assign
        v-alcdclxl-sheet1-cur-data-row = v-alcdclxl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = {&alcdclxl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id    = v-alcdclxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.seaname       = p-seaname
        buf_temp_sheet1_line-data.seacode       = p-seacode
/*        buf_temp_sheet1_line-data.ostbegtot     = p-ostbegtot*/
        buf_temp_sheet1_line-data.ostbeglocal   = p-ostbeglocal
        buf_temp_sheet1_line-data.ostbegregion  = p-ostbegregion
        buf_temp_sheet1_line-data.ostbegimp     = p-ostbegimp
/*        buf_temp_sheet1_line-data.pritot        = p-pritot*/
        buf_temp_sheet1_line-data.prilocal      = p-prilocal
        buf_temp_sheet1_line-data.priregion     = p-priregion
        buf_temp_sheet1_line-data.priimp        = p-priimp
/*        buf_temp_sheet1_line-data.saletot       = p-saletot*/
        buf_temp_sheet1_line-data.salelocal     = p-salelocal
        buf_temp_sheet1_line-data.saleregion    = p-saleregion
        buf_temp_sheet1_line-data.saleimp       = p-saleimp
/*        buf_temp_sheet1_line-data.rettot        = p-rettot*/
        buf_temp_sheet1_line-data.retlocal      = p-retlocal
        buf_temp_sheet1_line-data.retregion     = p-retregion
        buf_temp_sheet1_line-data.retimp        = p-retimp
/*        buf_temp_sheet1_line-data.othtot        = p-othtot*/
        buf_temp_sheet1_line-data.othlocal      = p-othlocal
        buf_temp_sheet1_line-data.othregion     = p-othregion
        buf_temp_sheet1_line-data.othimp        = p-othimp
/*        buf_temp_sheet1_line-data.ostendtot     = p-ostendtot*/
/*        buf_temp_sheet1_line-data.ostendlocal   = p-ostendlocal*/
/*        buf_temp_sheet1_line-data.ostendregion  = p-ostendregion*/
/*        buf_temp_sheet1_line-data.ostendimp     = p-ostendimp*/
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&alcdclxl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.seaname
        {&tabulation}   buf_temp_sheet1_line-data.seacode
        {&tabulation}   buf_temp_sheet1_line-data.ostbeglocal
        {&tabulation}   buf_temp_sheet1_line-data.ostbegregion
        {&tabulation}   buf_temp_sheet1_line-data.ostbegimp
        {&tabulation}   buf_temp_sheet1_line-data.prilocal
        {&tabulation}   buf_temp_sheet1_line-data.priregion
        {&tabulation}   buf_temp_sheet1_line-data.priimp
        {&tabulation}   buf_temp_sheet1_line-data.salelocal
        {&tabulation}   buf_temp_sheet1_line-data.saleregion
        {&tabulation}   buf_temp_sheet1_line-data.saleimp
        {&tabulation}   buf_temp_sheet1_line-data.retlocal
        {&tabulation}   buf_temp_sheet1_line-data.retregion
        {&tabulation}   buf_temp_sheet1_line-data.retimp
        {&tabulation}   buf_temp_sheet1_line-data.othlocal
        {&tabulation}   buf_temp_sheet1_line-data.othregion
        {&tabulation}   buf_temp_sheet1_line-data.othimp
        {&new-line}
    .
    .
end.
end procedure. /* alcdclxl-write-line-data */

/*==========================================================================*/
procedure alcdclxl-sheet2-write-line-data :
define input parameter p-cliname          as character        no-undo.
define input parameter p-cliinn           as character        no-undo.
define input parameter p-cliaddress       as character        no-undo.
define input parameter p-cliregioncode    as character        no-undo.
define input parameter p-licnum           as character        no-undo.
define input parameter p-licgive          as character        no-undo.
define input parameter p-shipdate         as character        no-undo.
define input parameter p-seaname          as character        no-undo.
define input parameter p-seacode          as character        no-undo.
define input parameter p-prodtype         as character        no-undo.
define input parameter p-quantity         as character        no-undo.

    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:

    for each buf_temp_sheet2_line-data
    :
        delete buf_temp_sheet2_line-data.
    end.
    create buf_temp_sheet2_line-data.
    assign
        v-alcdclxl-sheet2-cur-data-row = v-alcdclxl-sheet2-cur-data-row + 1
    .
    assign
        buf_temp_sheet2_line-data.sheet-name      = {&alcdclxl-sheet2-name}
        buf_temp_sheet2_line-data.xl-line-id      = v-alcdclxl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.cliname         = p-cliname
        buf_temp_sheet2_line-data.cliinn          = p-cliinn
        buf_temp_sheet2_line-data.cliaddress      = p-cliaddress
        buf_temp_sheet2_line-data.cliregioncode   = p-cliregioncode
        buf_temp_sheet2_line-data.licnum          = p-licnum
        buf_temp_sheet2_line-data.licgive         = p-licgive
        buf_temp_sheet2_line-data.shipdate        = p-shipdate
        buf_temp_sheet2_line-data.seaname         = p-seaname
        buf_temp_sheet2_line-data.seacode         = p-seacode
        buf_temp_sheet2_line-data.prodtype        = p-prodtype
        buf_temp_sheet2_line-data.quantity        = p-quantity
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        {&tabulation}   {&alcdclxl-data-label}
        {&tabulation}   buf_temp_sheet2_line-data.cliname
        {&tabulation}   buf_temp_sheet2_line-data.cliinn
        {&tabulation}   buf_temp_sheet2_line-data.cliaddress
        {&tabulation}   buf_temp_sheet2_line-data.cliregioncode
        {&tabulation}   buf_temp_sheet2_line-data.licnum
        {&tabulation}   buf_temp_sheet2_line-data.licgive
        {&tabulation}   buf_temp_sheet2_line-data.shipdate
        {&tabulation}   buf_temp_sheet2_line-data.seaname
        {&tabulation}   buf_temp_sheet2_line-data.seacode
        {&tabulation}   buf_temp_sheet2_line-data.prodtype
        {&tabulation}   buf_temp_sheet2_line-data.quantity
        {&new-line}
    .
end.
end procedure. /* alcdclxl-write-line-data */



/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure alcdclxl-write-cell-data :
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
end procedure. /* alcdclxl-write-cell-data */

/*==========================================================================*/
procedure alcdclxl-run-excel :
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
        v-template-file-name    = search( "exe/alcdcl.xlt" )
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
/*    run paramls-write in this-procedure (*/
/*          input {&paramls-saveas}*/
/*        , input {&paramls-excel-file-name}*/
/*        , input v-excel-file-name*/
/*    ).*/
/*    run paramls-write in this-procedure (*/
/*          input "charcol"*/
/*        , input ""*/
/*        , input "2"*/
/*    ).*/
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
end procedure. /* alcdclxl-run-excel */


/*==========================================================================*/
procedure alcdclxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
/*        put unformatted*/
/*            substitute("&2&1&3&1&4&1&1",*/
/*                  {&new-line}*/
/*                , "d:\ww\2\t12_97.xlt":U*/
/*                , v-alcdclxl-cell-file-name*/
/*                , v-alcdclxl-data-file-name*/
/*            )*/
/*        .*/
        export "exe/alcdcl.xlt":U.
        export "exe/t_form.bas":U.
        export v-alcdclxl-cell-file-name.
        export v-alcdclxl-data-file-name.
    output close.
end.
end procedure. /* alcdclxl-close */

/* $Workfile$ e n d */