/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Декларация об объемах розничной продажи алкогольной продукции (Нижегородская область) в Excel

Автор: Хныкин Павел Андреевич
Дата создания: 12/17/08
Author: Pavel Khnykin
Creation date: 12/17/08

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define alc06xl-data-label "DTA":U
&global-define alc06xl-format-label "FMT":U

&global-define alc06xl-sheetList  "Закупка,Продажа":U

&global-define alc06xl-sheet1_valutCode       "Закупка_valutCode":U
&global-define alc06xl-sheet1_columnList      "Закупка_columnList":U
&global-define alc06xl-sheet1_columnType      "Закупка_columnType":U
&global-define alc06xl-sheet1_subtotalList    "Закупка_subtotalList":U
&global-define alc06xl-sheet1_subtotalType    "Закупка_subtotalType":U

&global-define alc06xl-sheet2_valutCode       "Продажа_valutCode":U
&global-define alc06xl-sheet2_columnList      "Продажа_columnList":U
&global-define alc06xl-sheet2_columnType      "Продажа_columnType":U
&global-define alc06xl-sheet2_subtotalList    "Продажа_subtotalList":U
&global-define alc06xl-sheet2_subtotalType    "Продажа_subtotalType":U


&global-define alc06xl-h_firmname     "h_firmname":U
&global-define alc06xl-h_firminn      "h_firminn":U
&global-define alc06xl-h_firmaddress  "h_firmaddress":U
&global-define alc06xl-h_objcount     "h_objcount":U
&global-define alc06xl-h_licinfo      "h_licinfo":U
&global-define alc06xl-h_activity     "h_activity":U
&global-define alc06xl-h_daterange    "h_daterange":U
&global-define alc06xl-h_firmname2     "h_firmname2":U
&global-define alc06xl-h_firminn2      "h_firminn2":U
&global-define alc06xl-h_firmaddress2  "h_firmaddress2":U
&global-define alc06xl-h_objcount2     "h_objcount2":U
&global-define alc06xl-h_licinfo2      "h_licinfo2":U
&global-define alc06xl-h_activity2     "h_activity2":U
&global-define alc06xl-h_daterange2    "h_daterange2":U




&global-define alc06xl-sheet1-name "Закупка":U
&global-define alc06xl-sheet2-name "Продажа":U

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
    field npp           as character
    field alctypename   as character
    field alctypecode   as character
    field cliname       as character
    field cliinn        as character
    field cliaddress    as character
    field licnum        as character
    field licgive       as character
    field quantity      as character
index pi is primary unique
        xl-line-id
.

define temp-table temp_sheet2_line-data no-undo
    field sheet-name    as character
    field xl-line-id    as integer
    field npp2          as character
    field alctypename2  as character
    field alctypecode2  as character
    field ostbeg2       as character
    field pritot2       as character
    field proprod2      as character
    field proiorg2      as character
    field saletot2      as character
    field salelocprod2  as character
    field ostend2       as character
index pi is primary unique
        xl-line-id
.



define variable v-alc06xl-sheet1-cur-data-row  as integer      no-undo.
define variable v-alc06xl-sheet2-cur-data-row  as integer      no-undo.
define variable v-alc06xl-cell-file-name       as character    no-undo.
define variable v-alc06xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure alc06xl-init :

do
on error undo, return error
:
    assign
        v-alc06xl-sheet1-cur-data-row = 0
        v-alc06xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-alc06xl-data-file-name
    ).
    output stream excel-line to value( v-alc06xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-alc06xl-cell-file-name
    ).
    output stream excel-cell to value( v-alc06xl-cell-file-name ).
    run alc06xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&alc06xl-sheetList}
    ).
    if printrubl
    then do:
        run alc06xl-write-cell-data in this-procedure (
              input {&alc06xl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run alc06xl-write-cell-data in this-procedure (
              input {&alc06xl-sheet1_valutCode}
            , input "1":U
        ).
    end.
    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet1_columnList}
        , input "npp,alctypename,alctypecode,cliname,cliinn,cliaddress,licnum,licgive,quantity":U
    ).

    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet1_subtotalList}
        , input "":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet1_subtotalType}
        , input "":U
    ).
    if printrubl
    then do:
        run alc06xl-write-cell-data in this-procedure (
              input {&alc06xl-sheet2_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run alc06xl-write-cell-data in this-procedure (
              input {&alc06xl-sheet2_valutCode}
            , input "1":U
        ).
    end.
    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet2_columnList}
        , input "npp2,alctypename2,alctypecode2,ostbeg2,pritot2,proprod2,proiorg2,saletot2,salelocprod2,ostend2":U
    ).

    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet2_columnType}
        , input "S,S,S,S,S,S,S,S,S,S":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet2_subtotalList}
        , input "":U
    ).
    run alc06xl-write-cell-data in this-procedure (
          input {&alc06xl-sheet2_subtotalType}
        , input "":U
    ).

end.
end procedure. /* alc06xl-init */

/*==========================================================================*/
procedure alc06xl-sheet1-write-line-data :
  define input parameter p-npp           as character  no-undo .
  define input parameter p-alctypename   as character  no-undo .
  define input parameter p-alctypecode   as character  no-undo .
  define input parameter p-cliname       as character  no-undo .
  define input parameter p-cliinn        as character  no-undo .
  define input parameter p-cliaddress    as character  no-undo .
  define input parameter p-licnum        as character  no-undo .
  define input parameter p-licgive       as character  no-undo .
  define input parameter p-quantity      as character  no-undo .

define buffer buf_temp_sheet1_line-data  for temp_sheet1_line-data.

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
        v-alc06xl-sheet1-cur-data-row         = v-alc06xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name  = {&alc06xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id  = v-alc06xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.npp         = p-npp
        buf_temp_sheet1_line-data.alctypename = p-alctypename
        buf_temp_sheet1_line-data.alctypecode = p-alctypecode
        buf_temp_sheet1_line-data.cliname     = p-cliname
        buf_temp_sheet1_line-data.cliinn      = p-cliinn
        buf_temp_sheet1_line-data.cliaddress  = p-cliaddress
        buf_temp_sheet1_line-data.licnum      = p-licnum
        buf_temp_sheet1_line-data.licgive     = p-licgive
        buf_temp_sheet1_line-data.quantity    = p-quantity
    .

    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&alc06xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.npp
        {&tabulation}   buf_temp_sheet1_line-data.alctypename
        {&tabulation}   buf_temp_sheet1_line-data.alctypecode
        {&tabulation}   buf_temp_sheet1_line-data.cliname
        {&tabulation}   buf_temp_sheet1_line-data.cliinn
        {&tabulation}   buf_temp_sheet1_line-data.cliaddress
        {&tabulation}   buf_temp_sheet1_line-data.licnum
        {&tabulation}   buf_temp_sheet1_line-data.licgive
        {&tabulation}   buf_temp_sheet1_line-data.quantity
        {&new-line}
    .
end.
end procedure. /* alc06xl-sheet1-write-line-data */

/*==========================================================================*/
procedure alc06xl-sheet1-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet1_line-data        for temp_sheet1_line-data.
do
for buf_temp_sheet1_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&alc06xl-sheet1-name}
        {&tabulation}   {&alc06xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* alc06xl-sheet1-write-line-format */

/*==========================================================================*/
procedure alc06xl-sheet2-write-line-data :
  define input parameter p-npp2          as character   no-undo .
  define input parameter p-alctypename2  as character   no-undo .
  define input parameter p-alctypecode2  as character   no-undo .
  define input parameter p-ostbeg2       as character   no-undo .
  define input parameter p-pritot2       as character   no-undo .
  define input parameter p-proprod2      as character   no-undo .
  define input parameter p-proiorg2      as character   no-undo .
  define input parameter p-saletot2      as character   no-undo .
  define input parameter p-salelocprod2  as character   no-undo .
  define input parameter p-ostend2       as character   no-undo .

  define buffer buf_temp_sheet2_line-data  for temp_sheet2_line-data.

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
        v-alc06xl-sheet2-cur-data-row           = v-alc06xl-sheet2-cur-data-row + 1
        buf_temp_sheet2_line-data.sheet-name    = {&alc06xl-sheet2-name}
        buf_temp_sheet2_line-data.xl-line-id    = v-alc06xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.npp2          = p-npp2
        buf_temp_sheet2_line-data.alctypename2  = p-alctypename2
        buf_temp_sheet2_line-data.alctypecode2  = p-alctypecode2
        buf_temp_sheet2_line-data.ostbeg2       = p-ostbeg2
        buf_temp_sheet2_line-data.pritot2       = p-pritot2
        buf_temp_sheet2_line-data.proprod2      = p-proprod2
        buf_temp_sheet2_line-data.proiorg2      = p-proiorg2
        buf_temp_sheet2_line-data.saletot2      = p-saletot2
        buf_temp_sheet2_line-data.salelocprod2  = p-salelocprod2
        buf_temp_sheet2_line-data.ostend2       = p-ostend2
    .

    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        {&tabulation}   {&alc06xl-data-label}
        {&tabulation}   buf_temp_sheet2_line-data.npp2
        {&tabulation}   buf_temp_sheet2_line-data.alctypename2
        {&tabulation}   buf_temp_sheet2_line-data.alctypecode2
        {&tabulation}   buf_temp_sheet2_line-data.ostbeg2
        {&tabulation}   buf_temp_sheet2_line-data.pritot2
        {&tabulation}   buf_temp_sheet2_line-data.proprod2
        {&tabulation}   buf_temp_sheet2_line-data.proiorg2
        {&tabulation}   buf_temp_sheet2_line-data.saletot2
        {&tabulation}   buf_temp_sheet2_line-data.salelocprod2
        {&tabulation}   buf_temp_sheet2_line-data.ostend2
        {&new-line}
    .
end.
end procedure. /* alc06xl-sheet1-write-line-data */

/*==========================================================================*/
procedure alc06xl-sheet2-write-line-format :
define input parameter p-fmt-label       as character  no-undo.


    define buffer buf_temp_sheet2_line-data        for temp_sheet2_line-data.
do
for buf_temp_sheet2_line-data
on error undo, return error
:
    put stream excel-line unformatted
                        {&alc06xl-sheet2-name}
        {&tabulation}   {&alc06xl-format-label}
        {&tabulation}   p-fmt-label
        {&new-line}
    .
end.
end procedure. /* alc06xl-sheet1-write-line-format */

/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure alc06xl-write-cell-data :
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
end procedure. /* alc06xl-write-cell-data */

/*==========================================================================*/
procedure alc06xl-run-excel :
define input parameter p-header-filename    as character        no-undo.
define input parameter p-data-filename      as character        no-undo.

    define variable v-Template-file-name    as character    no-undo.
    define variable v-vb-file-name          as character    no-undo.

    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-Template-file-name    = search( "exe/alcdcl06.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
    if v-Template-file-name = ?
    or v-Template-file-name = "":U
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
          input {&paramls-Template}
        , input {&paramls-Template-file-name}
        , input v-Template-file-name
    ).
    run paramls-write in this-procedure (
          input {&paramls-Template}
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
end procedure. /* alc06xl-run-excel */


/*==========================================================================*/
procedure alc06xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/alcdcl06.xlt":U.
        export "exe/t_form.bas":U.
        export v-alc06xl-cell-file-name.
        export v-alc06xl-data-file-name.
    output close.
end.
end procedure. /* alc06xl-close */

/* $Workfile$ e n d */