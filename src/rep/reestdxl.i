/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы Реестр документов (Кедр-М) в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 12/18/08
Author: Alexey Demin
Creation date: 12/18/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define reestdxl-data-label "DTA":U
&global-define reestdxl-format-label "FMT":U

/*&global-define reestdxl-sheetList  "лист1,лист2,лист3,лист4,лист5,лист6":U */
&global-define reestdxl-sheetList  "Лист1,Лист2,Лист3,Лист4,Лист5,Лист6":U
/*&global-define reestdxl-sheetList  "Лист1,Лист2":U */

&global-define reestdxl-sheet1_valutCode       "Лист1_valutCode":U
&global-define reestdxl-sheet1_columnList      "Лист1_columnList":U
&global-define reestdxl-sheet1_columnType      "Лист1_columnType":U
&global-define reestdxl-sheet1_subtotalList    "Лист1_subtotalList":U
&global-define reestdxl-sheet1_subtotalType    "Лист1_subtotalType":U


&global-define reestdxl-sheet2_valutCode       "Лист2_valutCode":U
&global-define reestdxl-sheet2_columnList      "Лист2_columnList":U
&global-define reestdxl-sheet2_columnType      "Лист2_columnType":U
&global-define reestdxl-sheet2_subtotalList    "Лист2_subtotalList":U
&global-define reestdxl-sheet2_subtotalType    "Лист2_subtotalType":U

&global-define reestdxl-sheet3_valutCode       "Лист3_valutCode":U
&global-define reestdxl-sheet3_columnList      "Лист3_columnList":U
&global-define reestdxl-sheet3_columnType      "Лист3_columnType":U
&global-define reestdxl-sheet3_subtotalList    "Лист3_subtotalList":U
&global-define reestdxl-sheet3_subtotalType    "Лист3_subtotalType":U

&global-define reestdxl-sheet4_valutCode       "Лист4_valutCode":U
&global-define reestdxl-sheet4_columnList      "Лист4_columnList":U
&global-define reestdxl-sheet4_columnType      "Лист4_columnType":U
&global-define reestdxl-sheet4_subtotalList    "Лист4_subtotalList":U
&global-define reestdxl-sheet4_subtotalType    "Лист4_subtotalType":U

&global-define reestdxl-sheet5_valutCode       "Лист5_valutCode":U
&global-define reestdxl-sheet5_columnList      "Лист5_columnList":U
&global-define reestdxl-sheet5_columnType      "Лист5_columnType":U
&global-define reestdxl-sheet5_subtotalList    "Лист5_subtotalList":U
&global-define reestdxl-sheet5_subtotalType    "Лист5_subtotalType":U

&global-define reestdxl-sheet6_valutCode       "Лист6_valutCode":U
&global-define reestdxl-sheet6_columnList      "Лист6_columnList":U
&global-define reestdxl-sheet6_columnType      "Лист6_columnType":U
&global-define reestdxl-sheet6_subtotalList    "Лист6_subtotalList":U
&global-define reestdxl-sheet6_subtotalType    "Лист6_subtotalType":U


&global-define reestdxl-h_date      "h_date":U
&global-define reestdxl-h_obj       "h_obj":U
&global-define reestdxl-h_num       "h_num":U

&global-define reestdxl-f_sign      "f_sign":U
&global-define reestdxl-f_sign2     "f_sign2":U
&global-define reestdxl-f_sign3     "f_sign3":U
&global-define reestdxl-f_sign4     "f_sign4":U
&global-define reestdxl-f_sign5     "f_sign5":U
&global-define reestdxl-f_sign6     "f_sign6":U

&global-define reestdxl-sheet1-name "Лист1":U
&global-define reestdxl-sheet2-name "Лист2":U
&global-define reestdxl-sheet3-name "Лист3":U
&global-define reestdxl-sheet4-name "Лист4":U
&global-define reestdxl-sheet5-name "Лист5":U
&global-define reestdxl-sheet6-name "Лист6":U

define stream excel-line.
define stream excel-cell.
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_sheet1_line-data no-undo
    field sheet-name       as character
    field xl-line-id       as integer
    field ind              as character
    field clients          as character
    field data             as character
    field atrdoc           as character
    field doc              as character
    field sum_novat        as character
    field vat_ten          as character
    field vat_eight        as character
    field vat              as character
    field sum_cli          as character
    field sum_pr_list      as character
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet2_line-data no-undo
    field sheet-name       as character
    field xl-line-id       as integer
    field ind              as character
    field clients          as character
    field data             as character
    field doc              as character
    field qnty             as character
    field sum_novat        as character
    field vat_ten          as character
    field vat_eight        as character
    field vat              as character
    field sum_cli          as character
    field sum_pr_list      as character
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet3_line-data no-undo
    field sheet-name       as character
    field xl-line-id       as integer
    field ind              as character
    field data             as character
    field doc              as character
    field qnty             as character
    field sum              as character
       index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet4_line-data no-undo
    field sheet-name       as character
    field xl-line-id       as integer
    field ind              as character
    field clients          as character
    field data             as character
    field doc              as character
    field qnty             as character
    field sum_cli          as character
    field sum_bez_vat      as character
    field sum_pr_listt      as character
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet5_line-data no-undo
    field sheet-name       as character
    field xl-line-id       as integer
    field ind              as character
    field clients          as character
    field data             as character
    field doc              as character
    field qnty             as character
    field sum_cli          as character
    field sum_bez_vat      as character
    field sum_pr_listt      as character
    index pi is primary unique
        xl-line-id
.
define temp-table temp_sheet6_line-data no-undo
    field sheet-name       as character
    field xl-line-id       as integer
    field ind              as character
    field data             as character
    field doc              as character
    field qnty             as character
    field sum_cli          as character
    field sum_pr_list      as character
    index pi is primary unique
        xl-line-id
.

define variable v-reestdxl-sheet1-cur-data-row     as integer      no-undo.
define variable v-reestdxl-sheet2-cur-data-row     as integer      no-undo.
define variable v-reestdxl-sheet3-cur-data-row     as integer      no-undo.
define variable v-reestdxl-sheet4-cur-data-row     as integer      no-undo.
define variable v-reestdxl-sheet5-cur-data-row     as integer      no-undo.
define variable v-reestdxl-sheet6-cur-data-row     as integer      no-undo.
define variable v-reestdxl-cell-file-name          as character    no-undo.
define variable v-reestdxl-data-file-name          as character    no-undo.

/*==========================================================================*/
procedure reestdxl-init :

do
on error undo, return error
:
    assign
        v-reestdxl-sheet1-cur-data-row = 0
        v-reestdxl-sheet2-cur-data-row = 0
        v-reestdxl-sheet3-cur-data-row = 0
        v-reestdxl-sheet4-cur-data-row = 0
        v-reestdxl-sheet5-cur-data-row = 0
        v-reestdxl-sheet6-cur-data-row = 0

    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-reestdxl-data-file-name
    ).
    output stream excel-line to value( v-reestdxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-reestdxl-cell-file-name
    ).
    output stream excel-cell to value( v-reestdxl-cell-file-name ).
    run reestdxl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&reestdxl-sheetList}
    ).
    if printrubl
    then do:
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet1_valutCode}
            , input "0":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet2_valutCode}
            , input "0":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet3_valutCode}
            , input "0":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet4_valutCode}
            , input "0":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet5_valutCode}
            , input "0":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet6_valutCode}
            , input "0":U
        ).

    end.
    else do:
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet1_valutCode}
            , input "1":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet2_valutCode}
            , input "1":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet3_valutCode}
            , input "1":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet4_valutCode}
            , input "1":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet5_valutCode}
            , input "1":U
        ).
        run reestdxl-write-cell-data in this-procedure (
              input {&reestdxl-sheet6_valutCode}
            , input "1":U
        ).

    end.
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet1_columnList}
        , input "ind,clients,data,atrdoc,doc,sum_novat,vat_ten,vat_eight,vat,sum_cli,sum_pr_list":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet1_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet1_subtotalList}
        , input "":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet1_subtotalType}
        , input "":U
    ).

    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet2_columnList}
        , input "ind,clients,data,doc,qnty,sum_novat,vat_ten,vat_eight,vat,sum_cli,sum_pr_list":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet2_columnType}
        , input "S,S,S,S,S,S,S,S,S,S,S":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet2_subtotalList}
        , input "":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet2_subtotalType}
        , input "":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet3_columnList}
        , input "ind,data,doc,qnty,sum":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet3_columnType}
        , input "S,S,S,S,S":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet3_subtotalList}
        , input "":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet3_subtotalType}
        , input "":U
    ).

    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet4_columnList}
        , input "ind,clients,data,doc,qnty,sum_cli,sum_bez_vat,sum_pr_listt":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet4_columnType}
        , input "S,S,S,S,S,S,S":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet4_subtotalList}
        , input "":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet4_subtotalType}
        , input "":U
    ).

    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet5_columnList}
        , input "ind,clients,data,doc,qnty,sum_cli,sum_bez_vat,sum_pr_listt":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet5_columnType}
        , input "S,S,S,S,S,S,S,S":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet5_subtotalList}
        , input "":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet5_subtotalType}
        , input "":U
    ).

    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet6_columnList}
        , input "ind,data,doc,qnty,sum_cli,sum_pr_list":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet6_columnType}
        , input "S,S,S,S,S,S,S":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet6_subtotalList}
        , input "":U
    ).
    run reestdxl-write-cell-data in this-procedure (
          input {&reestdxl-sheet6_subtotalType}
        , input "":U
    ).


end.
end procedure. /* reestdxl-init */

/*==========================================================================*/
procedure reestdxl-sheet1-write-line-data :
define input parameter p-ind         as character        no-undo.
define input parameter p-clients     as character        no-undo.
define input parameter p-data        as character        no-undo.
define input parameter p-atrdoc      as character        no-undo.
define input parameter p-doc         as character        no-undo.
define input parameter p-sum_novat   as character        no-undo.
define input parameter p-vat_ten     as character        no-undo.
define input parameter p-vat_eight   as character        no-undo.
define input parameter p-vat         as character        no-undo.
define input parameter p-sum_cli     as character        no-undo.
define input parameter p-sum_pr_list as character        no-undo.

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
        v-reestdxl-sheet1-cur-data-row       = v-reestdxl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name = {&reestdxl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id = v-reestdxl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.ind            = p-ind
        buf_temp_sheet1_line-data.clients        = p-clients
        buf_temp_sheet1_line-data.data           = p-data
        buf_temp_sheet1_line-data.atrdoc         = p-atrdoc
        buf_temp_sheet1_line-data.doc            = p-doc
        buf_temp_sheet1_line-data.sum_novat      = p-sum_novat
        buf_temp_sheet1_line-data.vat_ten        = p-vat_ten
        buf_temp_sheet1_line-data.vat_eight      = p-vat_eight
        buf_temp_sheet1_line-data.vat            = p-vat
        buf_temp_sheet1_line-data.sum_cli        = p-sum_cli
        buf_temp_sheet1_line-data.sum_pr_list    = p-sum_pr_list
    .
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&reestdxl-data-label}
        {&tabulation}   buf_temp_sheet1_line-data.ind
        {&tabulation}   buf_temp_sheet1_line-data.clients
        {&tabulation}   buf_temp_sheet1_line-data.data
        {&tabulation}   buf_temp_sheet1_line-data.atrdoc
        {&tabulation}   buf_temp_sheet1_line-data.doc
        {&tabulation}   buf_temp_sheet1_line-data.sum_novat
        {&tabulation}   buf_temp_sheet1_line-data.vat_ten
        {&tabulation}   buf_temp_sheet1_line-data.vat_eight
        {&tabulation}   buf_temp_sheet1_line-data.vat
        {&tabulation}   buf_temp_sheet1_line-data.sum_cli
        {&tabulation}   buf_temp_sheet1_line-data.sum_pr_list
        {&new-line}
    .
    .
end.
end procedure. /* reestdxl-write-line-data */
/*==========================================================================*/
procedure reestdxl-sheet2-write-line-data :
define input parameter p-ind         as character        no-undo.
define input parameter p-clients     as character        no-undo.
define input parameter p-data        as character        no-undo.
define input parameter p-doc         as character        no-undo.
define input parameter p-qnty        as character        no-undo.
define input parameter p-sum_novat   as character        no-undo.
define input parameter p-vat_ten     as character        no-undo.
define input parameter p-vat_eight   as character        no-undo.
define input parameter p-vat         as character        no-undo.
define input parameter p-sum_cli     as character        no-undo.
define input parameter p-sum_pr_list as character        no-undo.

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
        v-reestdxl-sheet2-cur-data-row       = v-reestdxl-sheet2-cur-data-row + 1
        buf_temp_sheet2_line-data.sheet-name = {&reestdxl-sheet2-name}
        buf_temp_sheet2_line-data.xl-line-id = v-reestdxl-sheet2-cur-data-row
        buf_temp_sheet2_line-data.ind            = p-ind
        buf_temp_sheet2_line-data.clients        = p-clients
        buf_temp_sheet2_line-data.data           = p-data
        buf_temp_sheet2_line-data.doc            = p-doc
        buf_temp_sheet2_line-data.qnty           = p-qnty
        buf_temp_sheet2_line-data.sum_novat      = p-sum_novat
        buf_temp_sheet2_line-data.vat_ten        = p-vat_ten
        buf_temp_sheet2_line-data.vat_eight      = p-vat_eight
        buf_temp_sheet2_line-data.vat            = p-vat
        buf_temp_sheet2_line-data.sum_cli        = p-sum_cli
        buf_temp_sheet2_line-data.sum_pr_list    = p-sum_pr_list
    .
    put stream excel-line unformatted
                        buf_temp_sheet2_line-data.sheet-name
        {&tabulation}   {&reestdxl-data-label}
        {&tabulation}   buf_temp_sheet2_line-data.ind
        {&tabulation}   buf_temp_sheet2_line-data.clients
        {&tabulation}   buf_temp_sheet2_line-data.data
        {&tabulation}   buf_temp_sheet2_line-data.doc
        {&tabulation}   buf_temp_sheet2_line-data.qnty
        {&tabulation}   buf_temp_sheet2_line-data.sum_novat
        {&tabulation}   buf_temp_sheet2_line-data.vat_ten
        {&tabulation}   buf_temp_sheet2_line-data.vat_eight
        {&tabulation}   buf_temp_sheet2_line-data.vat
        {&tabulation}   buf_temp_sheet2_line-data.sum_cli
        {&tabulation}   buf_temp_sheet2_line-data.sum_pr_list
        {&new-line}
    .
    .
end.
end procedure. /* reestdxl-write-line-data */

/*==========================================================================*/
procedure reestdxl-sheet3-write-line-data :
define input parameter p-ind      as character        no-undo.
define input parameter p-data     as character        no-undo.
define input parameter p-doc      as character        no-undo.
define input parameter p-qnty     as character        no-undo.
define input parameter p-sum      as character        no-undo.

    define buffer buf_temp_sheet3_line-data        for temp_sheet3_line-data.
do
for buf_temp_sheet3_line-data
on error undo, return error
:
    for each buf_temp_sheet3_line-data
    :
        delete buf_temp_sheet3_line-data.
    end.
    create buf_temp_sheet3_line-data.
    assign
        v-reestdxl-sheet3-cur-data-row       = v-reestdxl-sheet3-cur-data-row + 1
        buf_temp_sheet3_line-data.sheet-name = {&reestdxl-sheet3-name}
        buf_temp_sheet3_line-data.xl-line-id = v-reestdxl-sheet3-cur-data-row
        buf_temp_sheet3_line-data.ind             = p-ind
        buf_temp_sheet3_line-data.data            = p-data
        buf_temp_sheet3_line-data.doc             = p-doc
        buf_temp_sheet3_line-data.qnty            = p-qnty
        buf_temp_sheet3_line-data.sum             = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_sheet3_line-data.sheet-name
        {&tabulation}   {&reestdxl-data-label}
        {&tabulation}   buf_temp_sheet3_line-data.ind
        {&tabulation}   buf_temp_sheet3_line-data.data
        {&tabulation}   buf_temp_sheet3_line-data.doc
        {&tabulation}   buf_temp_sheet3_line-data.qnty
        {&tabulation}   buf_temp_sheet3_line-data.sum
        {&new-line}
    .
    .
end.
end procedure. /* reestdxl-write-line-data */

/*==========================================================================*/
procedure reestdxl-sheet4-write-line-data :
define input parameter p-ind            as character        no-undo.
define input parameter p-clients        as character        no-undo.
define input parameter p-data           as character        no-undo.
define input parameter p-doc            as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-sum_cli        as character        no-undo.
define input parameter p-sum_bez_vat    as character        no-undo.
define input parameter p-sum_pr_list    as character        no-undo.

    define buffer buf_temp_sheet4_line-data        for temp_sheet4_line-data.
do
for buf_temp_sheet4_line-data
on error undo, return error
:
    for each buf_temp_sheet4_line-data
    :
        delete buf_temp_sheet4_line-data.
    end.
    create buf_temp_sheet4_line-data.
    assign
        v-reestdxl-sheet4-cur-data-row       = v-reestdxl-sheet4-cur-data-row + 1
        buf_temp_sheet4_line-data.sheet-name = {&reestdxl-sheet4-name}
        buf_temp_sheet4_line-data.xl-line-id = v-reestdxl-sheet4-cur-data-row
        buf_temp_sheet4_line-data.ind              = p-ind
        buf_temp_sheet4_line-data.clients          = p-clients
        buf_temp_sheet4_line-data.data             = p-data
        buf_temp_sheet4_line-data.doc              = p-doc
        buf_temp_sheet4_line-data.qnty             = p-qnty
        buf_temp_sheet4_line-data.sum_cli          = p-sum_cli
        buf_temp_sheet4_line-data.sum_bez_vat      = p-sum_bez_vat
        buf_temp_sheet4_line-data.sum_pr_list      = p-sum_pr_list
    .
    put stream excel-line unformatted
                        buf_temp_sheet4_line-data.sheet-name
        {&tabulation}   {&reestdxl-data-label}
        {&tabulation}   buf_temp_sheet4_line-data.ind
        {&tabulation}   buf_temp_sheet4_line-data.clients
        {&tabulation}   buf_temp_sheet4_line-data.data
        {&tabulation}   buf_temp_sheet4_line-data.doc
        {&tabulation}   buf_temp_sheet4_line-data.qnty
        {&tabulation}   buf_temp_sheet4_line-data.sum_cli
        {&tabulation}   buf_temp_sheet4_line-data.sum_bez_vat
        {&tabulation}   buf_temp_sheet4_line-data.sum_pr_list
        {&new-line}
    .
    .
end.
end procedure. /* reestdxl-write-line-data */
/*==========================================================================*/
procedure reestdxl-sheet5-write-line-data :
define input parameter p-ind            as character        no-undo.
define input parameter p-clients        as character        no-undo.
define input parameter p-data           as character        no-undo.
define input parameter p-doc            as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-sum_cli        as character        no-undo.
define input parameter p-sum_bez_vat    as character        no-undo.
define input parameter p-sum_pr_list    as character        no-undo.

    define buffer buf_temp_sheet5_line-data        for temp_sheet5_line-data.
do
for buf_temp_sheet5_line-data
on error undo, return error
:
    for each buf_temp_sheet5_line-data
    :
        delete buf_temp_sheet5_line-data.
    end.
    create buf_temp_sheet5_line-data.
    assign
        v-reestdxl-sheet5-cur-data-row       = v-reestdxl-sheet5-cur-data-row + 1
        buf_temp_sheet5_line-data.sheet-name = {&reestdxl-sheet5-name}
        buf_temp_sheet5_line-data.xl-line-id = v-reestdxl-sheet5-cur-data-row
        buf_temp_sheet5_line-data.ind              = p-ind
        buf_temp_sheet5_line-data.clients          = p-clients
        buf_temp_sheet5_line-data.data             = p-data
        buf_temp_sheet5_line-data.doc              = p-doc
        buf_temp_sheet5_line-data.qnty             = p-qnty
        buf_temp_sheet5_line-data.sum_cli          = p-sum_cli
        buf_temp_sheet5_line-data.sum_bez_vat      = p-sum_bez_vat
        buf_temp_sheet5_line-data.sum_pr_listt      = p-sum_pr_list
    .
    put stream excel-line unformatted
                        buf_temp_sheet5_line-data.sheet-name
        {&tabulation}   {&reestdxl-data-label}
        {&tabulation}   buf_temp_sheet5_line-data.ind
        {&tabulation}   buf_temp_sheet5_line-data.clients
        {&tabulation}   buf_temp_sheet5_line-data.data
        {&tabulation}   buf_temp_sheet5_line-data.doc
        {&tabulation}   buf_temp_sheet5_line-data.qnty
        {&tabulation}   buf_temp_sheet5_line-data.sum_cli
        {&tabulation}   buf_temp_sheet5_line-data.sum_bez_vat
        {&tabulation}   buf_temp_sheet5_line-data.sum_pr_listt
        {&new-line}
    .
    .
end.
end procedure. /* reestdxl-write-line-data */
/*==========================================================================*/
procedure reestdxl-sheet6-write-line-data :
define input parameter p-ind                as character        no-undo.
define input parameter p-data               as character        no-undo.
define input parameter p-doc                as character        no-undo.
define input parameter p-qnty               as character        no-undo.
define input parameter p-sum_cli            as character        no-undo.
define input parameter p-sum_pr_list        as character        no-undo.

    define buffer buf_temp_sheet6_line-data        for temp_sheet6_line-data.
do
for buf_temp_sheet6_line-data
on error undo, return error
:
    for each buf_temp_sheet6_line-data
    :
        delete buf_temp_sheet6_line-data.
    end.
    create buf_temp_sheet6_line-data.
    assign
        v-reestdxl-sheet6-cur-data-row       = v-reestdxl-sheet6-cur-data-row + 1
        buf_temp_sheet6_line-data.sheet-name = {&reestdxl-sheet6-name}
        buf_temp_sheet6_line-data.xl-line-id = v-reestdxl-sheet6-cur-data-row
        buf_temp_sheet6_line-data.ind               =  p-ind
        buf_temp_sheet6_line-data.data              =  p-data
        buf_temp_sheet6_line-data.doc               =  p-doc
        buf_temp_sheet6_line-data.qnty              =  p-qnty
        buf_temp_sheet6_line-data.sum_cli           = p-sum_cli
        buf_temp_sheet6_line-data.sum_pr_list       =  p-sum_pr_list
    .
    put stream excel-line unformatted
                        buf_temp_sheet6_line-data.sheet-name
        {&tabulation}   {&reestdxl-data-label}
        {&tabulation}   buf_temp_sheet6_line-data.ind
        {&tabulation}   buf_temp_sheet6_line-data.data
        {&tabulation}   buf_temp_sheet6_line-data.doc
        {&tabulation}   buf_temp_sheet6_line-data.qnty
        {&tabulation}   buf_temp_sheet6_line-data.sum_cli
        {&tabulation}   buf_temp_sheet6_line-data.sum_pr_list
        {&new-line}
    .
    .
end.
end procedure. /* reestdxl-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure reestdxl-write-cell-data :
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
end procedure. /* reestdxl-write-cell-data */

/*==========================================================================*/
procedure reestdxl-run-excel :
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
        v-template-file-name    = search( "exe/reestd.xlt" )
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
end procedure. /* reestdxl-run-excel */


/*==========================================================================*/
procedure reestdxl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/reestd.xlt":U.
        export "exe/t_form.bas":U.
        export v-reestdxl-cell-file-name.
        export v-reestdxl-data-file-name.
    output close.
end.
end procedure. /* reestdxl-close */

/* $Workfile$ e n d */