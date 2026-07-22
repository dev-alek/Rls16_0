/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы ТОРГ-29 в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 12/21/06
Author: Alexey Demin
Creation date: 12/21/06

Required: { p a r a m l s . i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define torg29xl-data-label "DTA":U
&global-define torg29xl-format-label "FMT":U

&global-define torg29xl-sheetList  "лист1,лист2":U

&global-define torg29xl-sheet1_valutCode       "лист1_valutCode":U
&global-define torg29xl-sheet1_columnList      "лист1_columnList":U
&global-define torg29xl-sheet1_columnType      "лист1_columnType":U
&global-define torg29xl-sheet1_subtotalList    "лист1_subtotalList":U
&global-define torg29xl-sheet1_subtotalType    "лист1_subtotalType":U

&global-define torg29xl-sheet2_valutCode       "лист2_valutCode":U
&global-define torg29xl-sheet2_columnList      "лист2_columnList":U
&global-define torg29xl-sheet2_columnType      "лист2_columnType":U
&global-define torg29xl-sheet2_subtotalList    "лист2_subtotalList":U
&global-define torg29xl-sheet2_subtotalType    "лист2_subtotalType":U

&global-define torg29xl-h_firmname      "h_firmname":U
&global-define torg29xl-h_objlist       "h_objlist":U
&global-define torg29xl-h_okpo          "h_okpo":U
&global-define torg29xl-h_printdate     "h_printdate":U
&global-define torg29xl-h_datestart     "h_datestart":U
&global-define torg29xl-h_dateend       "h_dateend":U
&global-define torg29xl-f_incomegds     "f_incomegds":U
&global-define torg29xl-f_incometara    "f_incometara":U
&global-define torg29xl-f_incostgds     "f_incostgds":U
&global-define torg29xl-f_incosttara    "f_incosttara":U
&global-define torg29xl-f_expgds        "f_expgds":U
&global-define torg29xl-f_exptara       "f_exptara":U
&global-define torg29xl-f_expostgds     "f_expostgds":U
&global-define torg29xl-f_exposttara    "f_exposttara":U
&global-define torg29xl-f_expostdateend "f_expostdateend":U

&global-define torg29xl-sheet1-name "лист1":U
&global-define torg29xl-sheet2-name "лист2":U

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
    field gdsname         as character
    field docdate         as character
    field doccode         as character
    field gdssum          as character
    field tarasum         as character
    field buhone          as character
    field buhtwo          as character
    index pi is primary unique
        xl-line-id
.

define temp-table temp_sheet2_line-data no-undo
    field sheet-name      as character
    field xl-line-id      as integer
    field gdsname         as character
    field docdate         as character
    field doccode         as character
    field gdssum          as character
    field tarasum         as character
    field buhone          as character
    field buhtwo          as character
index pi is primary unique
    xl-line-id
.

define variable v-torg29xl-sheet1-cur-data-row     as integer      no-undo.
define variable v-torg29xl-sheet2-cur-data-row     as integer      no-undo.
define variable v-torg29xl-cell-file-name       as character    no-undo.
define variable v-torg29xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure torg29xl-init :

do
on error undo, return error
:
    assign
        v-torg29xl-sheet1-cur-data-row = 0
        v-torg29xl-sheet2-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg29xl-data-file-name
    ).
    output stream excel-line to value( v-torg29xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg29xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg29xl-cell-file-name ).
    run torg29xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&torg29xl-sheetList}
    ).
    if printrubl
    then do:
        run torg29xl-write-cell-data in this-procedure (
              input {&torg29xl-sheet1_valutCode}
            , input "0":U
        ).
        run torg29xl-write-cell-data in this-procedure (
              input {&torg29xl-sheet2_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run torg29xl-write-cell-data in this-procedure (
              input {&torg29xl-sheet1_valutCode}
            , input "1":U
        ).
        run torg29xl-write-cell-data in this-procedure (
              input {&torg29xl-sheet2_valutCode}
            , input "1":U
        ).
    end.
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet1_columnList}
        , input "gdsname,docdate,doccode,gdssum,tarasum,buhone,buhtwo":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet1_columnType}
        , input "S,S,S,S,S,S,S":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet1_subtotalList}
        , input "":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet1_subtotalType}
        , input "":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet2_columnList}
        , input "gdsname,docdate,doccode,gdssum,tarasum,buhone,buhtwo":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet2_columnType}
        , input "S,S,S,S,S,S,S":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet2_subtotalList}
        , input "":U
    ).
    run torg29xl-write-cell-data in this-procedure (
          input {&torg29xl-sheet2_subtotalType}
        , input "":U
    ).
end.
end procedure. /* torg29xl-init */

/*==========================================================================*/
procedure torg29xl-sheet1-write-line-data :
define input parameter p-gdsname as character        no-undo.
define input parameter p-docdate as character        no-undo.
define input parameter p-doccode as character        no-undo.
define input parameter p-gdssum  as character        no-undo.
define input parameter p-tarasum as character        no-undo.
define input parameter p-buhone  as character        no-undo.
define input parameter p-buhtwo  as character        no-undo.

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
        v-torg29xl-sheet1-cur-data-row       = v-torg29xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name = {&torg29xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id = v-torg29xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.gdsname    = p-gdsname
        buf_temp_sheet1_line-data.docdate    = p-docdate
        buf_temp_sheet1_line-data.doccode    = p-doccode
        buf_temp_sheet1_line-data.gdssum     = p-gdssum
        buf_temp_sheet1_line-data.tarasum    = p-tarasum
        buf_temp_sheet1_line-data.buhone     = p-buhone
        buf_temp_sheet1_line-data.buhtwo     = p-buhtwo
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&torg29xl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.gdsname
        {&tabulation}   buf_temp_sheet1_line-data.docdate
        {&tabulation}   buf_temp_sheet1_line-data.doccode
        {&tabulation}   buf_temp_sheet1_line-data.gdssum
        {&tabulation}   buf_temp_sheet1_line-data.tarasum
        {&tabulation}   buf_temp_sheet1_line-data.buhone
        {&tabulation}   buf_temp_sheet1_line-data.buhtwo
        {&new-line}
    .
    .
end.
end procedure. /* torg29xl-write-line-data */

/*==========================================================================*/
procedure torg29xl-sheet2-write-line-data :
define input parameter p-gdsname as character        no-undo.
define input parameter p-docdate as character        no-undo.
define input parameter p-doccode as character        no-undo.
define input parameter p-gdssum  as character        no-undo.
define input parameter p-tarasum as character        no-undo.
define input parameter p-buhone  as character        no-undo.
define input parameter p-buhtwo  as character        no-undo.

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
        v-torg29xl-sheet2-cur-data-row = v-torg29xl-sheet2-cur-data-row + 1
    .
    assign
        buf_temp_sheet2_line-data.sheet-name = {&torg29xl-sheet2-name}
        buf_temp_sheet2_line-data.xl-line-id = v-torg29xl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.gdsname    = p-gdsname
        buf_temp_sheet2_line-data.docdate    = p-docdate
        buf_temp_sheet2_line-data.doccode    = p-doccode
        buf_temp_sheet2_line-data.gdssum     = p-gdssum
        buf_temp_sheet2_line-data.tarasum    = p-tarasum
        buf_temp_sheet2_line-data.buhone     = p-buhone
        buf_temp_sheet2_line-data.buhtwo     = p-buhtwo
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        {&tabulation}   {&torg29xl-data-label}
        {&tabulation}   buf_temp_sheet2_line-data.gdsname
        {&tabulation}   buf_temp_sheet2_line-data.docdate
        {&tabulation}   buf_temp_sheet2_line-data.doccode
        {&tabulation}   buf_temp_sheet2_line-data.gdssum
        {&tabulation}   buf_temp_sheet2_line-data.tarasum
        {&tabulation}   buf_temp_sheet2_line-data.buhone
        {&tabulation}   buf_temp_sheet2_line-data.buhtwo
        {&new-line}
    .
end.
end procedure. /* torg29xl-write-line-data */



/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure torg29xl-write-cell-data :
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
end procedure. /* torg29xl-write-cell-data */

/*==========================================================================*/
procedure torg29xl-run-excel :
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
        v-template-file-name    = search( "exe/torg29.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
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
end procedure. /* torg29xl-run-excel */


/*==========================================================================*/
procedure torg29xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
        export "exe/torg29.xlt":U.
        export "exe/t_form.bas":U.
        export v-torg29xl-cell-file-name.
        export v-torg29xl-data-file-name.
    output close.
end.
end procedure. /* torg29xl-close */

/* $Workfile$ e n d */