/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ŒÚ˜∏Ú Œ·ÓÓÚÌ‡ˇ ‚Â‰ÓÏÓÒÚ¸ ÔÓ Ï‡ÚˆÂÌÌÓÒÚˇÏ - Excel

¿‚ÚÓ: ƒÂÏËÌ ¿ÎÂÍÒÂÈ —Â„ÂÂ‚Ë˜
ƒ‡Ú‡ ÒÓÁ‰‡ÌËˇ: 09/06/07
Author: Alexey Demin
Creation date: 09/06/07

Required:
    { g b l / p a r a m l s . i    }
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define inv19xl-data-label "DTA":U
&global-define inv19xl-format-label "FMT":U

&global-define inv19xl-sheetList  "»Õ¬19":U

&global-define inv19xl-sheet1_valutCode       "»Õ¬19_valutCode":U
&global-define inv19xl-sheet1_columnList      "»Õ¬19_columnList":U
&global-define inv19xl-sheet1_columnType      "»Õ¬19_columnType":U
&global-define inv19xl-sheet1_subtotalList    "»Õ¬19_subtotalList":U
&global-define inv19xl-sheet1_subtotalType    "»Õ¬19_subtotalType":U
&global-define inv19xl-sheet1_hideColList     "»Õ¬19_hideColList":U
&global-define inv19xl-sheet1-name            "»Õ¬19":U

&global-define inv19xl-sheet1-organization   "organization":U
&global-define inv19xl-sheet1-object         "object":U
&global-define inv19xl-sheet1-osnov          "osnov":U
&global-define inv19xl-sheet1-docinvcode     "docinvcode":U
&global-define inv19xl-sheet1-docdate        "docdate":U
&global-define inv19xl-sheet1-startdate      "startdate":U
&global-define inv19xl-sheet1-enddate        "enddate":U
&global-define inv19xl-sheet1-doccode        "doccode":U
&global-define inv19xl-sheet1-factdate       "factdate":U

&global-define inv19xl-sheet1-it_rezIzlSum         "»Õ¬19_it_rezIzlSum":U
&global-define inv19xl-sheet1-it_rezNedSum         "»Õ¬19_it_rezNedSum":U
&global-define inv19xl-sheet1-it_utochIzlSum       "»Õ¬19_it_utochIzlSum":U
&global-define inv19xl-sheet1-it_utochNedSum       "»Õ¬19_it_utochNedSum":U
&global-define inv19xl-sheet1-it_peresIzlSum       "»Õ¬19_it_peresIzlSum":U
&global-define inv19xl-sheet1-it_peresNedSum       "»Õ¬19_it_peresNedSum":U
&global-define inv19xl-sheet1-it_endIzlSum         "»Õ¬19_it_endIzlSum":U
&global-define inv19xl-sheet1-it_endNedSum1        "»Õ¬19_it_endNedSum1":U
&global-define inv19xl-sheet1-it_endNedSum2        "»Õ¬19_it_endNedSum2":U
&global-define inv19xl-sheet1-it_endNedSum3        "»Õ¬19_it_endNedSum3":U
&global-define inv19xl-sheet1-it_rezIzlQnty         "»Õ¬19_it_rezIzlQnty":U
&global-define inv19xl-sheet1-it_rezNedQnty         "»Õ¬19_it_rezNedQnty":U
&global-define inv19xl-sheet1-it_utochIzlQnty       "»Õ¬19_it_utochIzlQnty":U
&global-define inv19xl-sheet1-it_utochNedQnty       "»Õ¬19_it_utochNedQnty":U
&global-define inv19xl-sheet1-it_peresIzlQnty       "»Õ¬19_it_peresIzlQnty":U
&global-define inv19xl-sheet1-it_peresNedQnty       "»Õ¬19_it_peresNedQnty":U
&global-define inv19xl-sheet1-it_endIzlQnty         "»Õ¬19_it_endIzlQnty":U
&global-define inv19xl-sheet1-it_endNedQnty1        "»Õ¬19_it_endNedQnty1":U
&global-define inv19xl-sheet1-it_endNedQnty2        "»Õ¬19_it_endNedQnty2":U
&global-define inv19xl-sheet1-it_endNedQnty3        "»Õ¬19_it_endNedQnty3":U

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_sheet1_line-data no-undo
    field sheet-name        as character
    field xl-line-id        as integer
    field num               as character
    field gdsname           as character
    field gdscode           as character
    field OKEI              as character
    field EI                as character
    field OKDP              as character
    field rezIzlQnty        as decimal
    field rezIzlSum         as character
    field rezNedQnty        as decimal
    field rezNedSum         as character
    field num2              as character
    field utochIzlQnty      as character
    field utochIzlSum       as character
    field utochNedQnty      as character
    field utochNedSum       as character
    field peresIzlQnty      as character
    field peresIzlSum       as character
    field peresNedQnty      as character
    field peresNedSum       as character
    field endIzlQnty        as character
    field endIzlSum         as character
    field endNedQnty1       as character
    field endNedSum1        as character
    field endNedQnty2       as character
    field endNedSum2        as character
    field endNedQnty3       as character
    field endNedSum3        as character

    index pi is primary unique
        xl-line-id
.

define variable v-inv19xl-sheet1-cur-data-row     as integer      no-undo.
define variable v-inv19xl-cell-file-name       as character    no-undo.
define variable v-inv19xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure inv19xl-init :

do
on error undo, return error
:
    assign
        v-inv19xl-sheet1-cur-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-inv19xl-data-file-name
    ).
    output stream excel-line to value( v-inv19xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-inv19xl-cell-file-name
    ).
    output stream excel-cell to value( v-inv19xl-cell-file-name ).
    run inv19xl-write-cell-data in this-procedure (
          input "sheetList":U
        , input {&inv19xl-sheetList}
    ).
    if printrubl
    then do:
        run inv19xl-write-cell-data in this-procedure (
              input {&inv19xl-sheet1_valutCode}
            , input "0":U
        ).
    end.
    else do:
        run inv19xl-write-cell-data in this-procedure (
              input {&inv19xl-sheet1_valutCode}
            , input "1":U
        ).
    end.
/*    run inv19xl-write-cell-data in this-procedure (*/
/*          input {&inv19xl-sheet1_columnList}*/
/*        , input "seaname,seacode,ostbegtot,ostbeglocal,ostbegregion,ostbegimp,pritot,prilocal,priregion,priimp,saletot,salelocal,saleregion,saleimp,rettot,retlocal,retregion,retimp,othtot,othlocal,othregion,othimp,ostendtot,ostendlocal,ostendregion,ostendimp":U*/
/*    ).*/
    if p-mode = "OKDP"
    then do :
      run inv19xl-write-cell-data in this-procedure (
            input {&inv19xl-sheet1_columnList}
          , input "num,gdsname,gdscode,OKEI,EI,OKDP,rezIzlQnty,rezIzlSum,rezNedQnty,rezNedSum,num2,utochIzlQnty,utochIzlSum,utochNedQnty,utochNedSum,peresIzlQnty,peresIzlSum,peresNedQnty,peresNedSum,endIzlQnty,endIzlSum,endNedQnty1,endNedSum1,endNedQnty2,endNedSum2,endNedQnty3,endNedSum3":U
      ).
      run inv19xl-write-cell-data in this-procedure (
            input {&inv19xl-sheet1_columnType}
          , input "I,S,S,S,S,S,C,C,C,C,I":U + fill( ",C,C":U, 8)
      ).
    end.
    else do :
    run inv19xl-write-cell-data in this-procedure (
          input {&inv19xl-sheet1_columnList}
        , input "num,gdsname,gdscode,OKEI,EI,rezIzlQnty,rezIzlSum,rezNedQnty,rezNedSum,num2,utochIzlQnty,utochIzlSum,utochNedQnty,utochNedSum,peresIzlQnty,peresIzlSum,peresNedQnty,peresNedSum,endIzlQnty,endIzlSum,endNedQnty1,endNedSum1,endNedQnty2,endNedSum2,endNedQnty3,endNedSum3":U
    ).
    run inv19xl-write-cell-data in this-procedure (
          input {&inv19xl-sheet1_columnType}
        , input "I,S,S,S,S,C,C,C,C,I":U + fill( ",C,C":U, 8)
    ).
    end.
    if lookup( 'L-Rus' , v-sys-key) > 0
    then do:
      run inv19xl-write-cell-data in this-procedure (
            input {&inv19xl-sheet1_subtotalList}
          , input "rezIzlQnty,rezIzlSum,rezNedQnty,rezNedSum,utochIzlQnty,utochIzlSum,utochNedQnty,utochNedSum,peresIzlQnty,peresIzlSum,peresNedQnty,peresNedSum,endIzlQnty,endIzlSum,endNedQnty1,endNedSum1,endNedQnty2,endNedSum2,endNedQnty3,endNedSum3":U
      ).
      run inv19xl-write-cell-data in this-procedure (
            input {&inv19xl-sheet1_subtotalType}
          , input "S":U + fill(",S":U, 19)
      ).
    end.
    else do:
      run inv19xl-write-cell-data in this-procedure (
            input {&inv19xl-sheet1_subtotalList}
          , input "rezIzlQnty,rezIzlSum,rezNedQnty,rezNedSum":U
      ).
      run inv19xl-write-cell-data in this-procedure (
            input {&inv19xl-sheet1_subtotalType}
          , input "S":U + fill(",S":U, 3)
      ).
    end.

end.
end procedure. /* inv19xl-init */

/*==========================================================================*/
procedure inv19xl-sheet1-write-line-data :
define input parameter p-num            as character        no-undo.
define input parameter p-gdsname        as character        no-undo.
define input parameter p-gdscode        as character        no-undo.
define input parameter p-OKEI           as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-OKDP           as character        no-undo.
define input parameter p-rezIzlQnty     as decimal          no-undo.
define input parameter p-rezIzlSum      as character        no-undo.
define input parameter p-rezNedQnty     as decimal          no-undo.
define input parameter p-rezNedSum      as character        no-undo.
define input parameter p-num2           as character        no-undo.
define input parameter p-utochIzlQnty   as character        no-undo.
define input parameter p-utochIzlSum    as character        no-undo.
define input parameter p-utochNedQnty   as character        no-undo.
define input parameter p-utochNedSum    as character        no-undo.
define input parameter p-peresIzlQnty   as character        no-undo.
define input parameter p-peresIzlSum    as character        no-undo.
define input parameter p-peresNedQnty   as character        no-undo.
define input parameter p-peresNedSum    as character        no-undo.
define input parameter p-endIzlQnty     as character        no-undo.
define input parameter p-endIzlSum      as character        no-undo.
define input parameter p-endNedQnty1    as character        no-undo.
define input parameter p-endNedSum1     as character        no-undo.
define input parameter p-endNedQnty2    as character        no-undo.
define input parameter p-endNedSum2     as character        no-undo.
define input parameter p-endNedQnty3    as character        no-undo.
define input parameter p-endNedSum3     as character        no-undo.

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
        v-inv19xl-sheet1-cur-data-row = v-inv19xl-sheet1-cur-data-row + 1
        buf_temp_sheet1_line-data.sheet-name    = {&inv19xl-sheet1-name}
        buf_temp_sheet1_line-data.xl-line-id    = v-inv19xl-sheet1-cur-data-row
        buf_temp_sheet1_line-data.num              = p-num
        buf_temp_sheet1_line-data.gdsname          = p-gdsname
        buf_temp_sheet1_line-data.gdscode          = p-gdscode
        buf_temp_sheet1_line-data.OKEI             = p-OKEI
        buf_temp_sheet1_line-data.EI               = p-EI
        buf_temp_sheet1_line-data.OKDP             = p-OKDP
        buf_temp_sheet1_line-data.rezIzlQnty       = p-rezIzlQnty
        buf_temp_sheet1_line-data.rezIzlSum        = p-rezIzlSum
        buf_temp_sheet1_line-data.rezNedQnty       = p-rezNedQnty
        buf_temp_sheet1_line-data.rezNedSum        = p-rezNedSum
        buf_temp_sheet1_line-data.num2             = p-num2
        buf_temp_sheet1_line-data.utochIzlQnty     = p-utochIzlQnty
        buf_temp_sheet1_line-data.utochIzlSum      = p-utochIzlSum
        buf_temp_sheet1_line-data.utochNedQnty     = p-utochNedQnty
        buf_temp_sheet1_line-data.utochNedSum      = p-utochNedSum
        buf_temp_sheet1_line-data.peresIzlQnty     = p-peresIzlQnty
        buf_temp_sheet1_line-data.peresIzlSum      = p-peresIzlSum
        buf_temp_sheet1_line-data.peresNedQnty     = p-peresNedQnty
        buf_temp_sheet1_line-data.peresNedSum      = p-peresNedSum
        buf_temp_sheet1_line-data.endIzlQnty       = p-endIzlQnty
        buf_temp_sheet1_line-data.endIzlSum        = p-endIzlSum
        buf_temp_sheet1_line-data.endNedQnty1      = p-endNedQnty1
        buf_temp_sheet1_line-data.endNedSum1       = p-endNedSum1
        buf_temp_sheet1_line-data.endNedQnty2      = p-endNedQnty2
        buf_temp_sheet1_line-data.endNedSum2       = p-endNedSum2
        buf_temp_sheet1_line-data.endNedQnty3      = p-endNedQnty3
        buf_temp_sheet1_line-data.endNedSum3       = p-endNedSum3
    .
    if p-mode = "OKDP"
    then
      put stream excel-line unformatted
                          buf_temp_sheet1_line-data.sheet-name
          {&tabulation}   {&inv19xl-data-label}
          {&tabulation}   string( buf_temp_sheet1_line-data.num          )
          {&tabulation}   string( buf_temp_sheet1_line-data.gdsname      )
          {&tabulation}   string( buf_temp_sheet1_line-data.gdscode      )
          {&tabulation}   string( buf_temp_sheet1_line-data.OKEI         )
          {&tabulation}   string( buf_temp_sheet1_line-data.EI           )
          {&tabulation}   string( buf_temp_sheet1_line-data.OKDP         )
          {&tabulation}   string( buf_temp_sheet1_line-data.rezIzlQnty   )
          {&tabulation}   string( buf_temp_sheet1_line-data.rezIzlSum    )
          {&tabulation}   string( buf_temp_sheet1_line-data.rezNedQnty   )
          {&tabulation}   string( buf_temp_sheet1_line-data.rezNedSum    )
          {&tabulation}   string( buf_temp_sheet1_line-data.num2         )
          {&tabulation}   string( buf_temp_sheet1_line-data.utochIzlQnty )
          {&tabulation}   string( buf_temp_sheet1_line-data.utochIzlSum  )
          {&tabulation}   string( buf_temp_sheet1_line-data.utochNedQnty )
          {&tabulation}   string( buf_temp_sheet1_line-data.utochNedSum  )
          {&tabulation}   string( buf_temp_sheet1_line-data.peresIzlQnty )
          {&tabulation}   string( buf_temp_sheet1_line-data.peresIzlSum  )
          {&tabulation}   string( buf_temp_sheet1_line-data.peresNedQnty )
          {&tabulation}   string( buf_temp_sheet1_line-data.peresNedSum  )
          {&tabulation}   string( buf_temp_sheet1_line-data.endIzlQnty   )
          {&tabulation}   string( buf_temp_sheet1_line-data.endIzlSum    )
          {&tabulation}   string( buf_temp_sheet1_line-data.endNedQnty1  )
          {&tabulation}   string( buf_temp_sheet1_line-data.endNedSum1   )
          {&tabulation}   string( buf_temp_sheet1_line-data.endNedQnty2  )
          {&tabulation}   string( buf_temp_sheet1_line-data.endNedSum2   )
          {&tabulation}   string( buf_temp_sheet1_line-data.endNedQnty3  )
          {&tabulation}   string( buf_temp_sheet1_line-data.endNedSum3   )
          {&new-line}
      .
    else
    put stream excel-line unformatted
                        buf_temp_sheet1_line-data.sheet-name
        {&tabulation}   {&inv19xl-data-label}
        {&tabulation}   string( buf_temp_sheet1_line-data.num          )
        {&tabulation}   string( buf_temp_sheet1_line-data.gdsname      )
        {&tabulation}   string( buf_temp_sheet1_line-data.gdscode      )
        {&tabulation}   string( buf_temp_sheet1_line-data.OKEI         )
        {&tabulation}   string( buf_temp_sheet1_line-data.EI           )
        {&tabulation}   string( buf_temp_sheet1_line-data.rezIzlQnty   )
        {&tabulation}   string( buf_temp_sheet1_line-data.rezIzlSum    )
        {&tabulation}   string( buf_temp_sheet1_line-data.rezNedQnty   )
        {&tabulation}   string( buf_temp_sheet1_line-data.rezNedSum    )
        {&tabulation}   string( buf_temp_sheet1_line-data.num2         )
        {&tabulation}   string( buf_temp_sheet1_line-data.utochIzlQnty )
        {&tabulation}   string( buf_temp_sheet1_line-data.utochIzlSum  )
        {&tabulation}   string( buf_temp_sheet1_line-data.utochNedQnty )
        {&tabulation}   string( buf_temp_sheet1_line-data.utochNedSum  )
        {&tabulation}   string( buf_temp_sheet1_line-data.peresIzlQnty )
        {&tabulation}   string( buf_temp_sheet1_line-data.peresIzlSum  )
        {&tabulation}   string( buf_temp_sheet1_line-data.peresNedQnty )
        {&tabulation}   string( buf_temp_sheet1_line-data.peresNedSum  )
        {&tabulation}   string( buf_temp_sheet1_line-data.endIzlQnty   )
        {&tabulation}   string( buf_temp_sheet1_line-data.endIzlSum    )
        {&tabulation}   string( buf_temp_sheet1_line-data.endNedQnty1  )
        {&tabulation}   string( buf_temp_sheet1_line-data.endNedSum1   )
        {&tabulation}   string( buf_temp_sheet1_line-data.endNedQnty2  )
        {&tabulation}   string( buf_temp_sheet1_line-data.endNedSum2   )
        {&tabulation}   string( buf_temp_sheet1_line-data.endNedQnty3  )
        {&tabulation}   string( buf_temp_sheet1_line-data.endNedSum3   )
        {&new-line}
    .
end.
end procedure. /* inv19xl-write-line-data */


/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
/*==========================================================================*/
procedure inv19xl-write-cell-data :
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
end procedure. /* inv19xl-write-cell-data */

/*==========================================================================*/
procedure inv19xl-run-excel :
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
        v-template-file-name    = search( "exe/inv19.xlt" )
        v-vb-file-name          = search( "exe/t_form.bas")
    .
/*    assign*/
/*        v-template-file-name = search( v-template-file-name )*/
/*    .*/
    if v-template-file-name = ?
    or v-template-file-name = "":U
    then do:
        message
            "Œ¯Ë·Í‡ ËÏÂÌË Ù‡ÈÎ‡ ¯‡·ÎÓÌ‡."
        view-as alert-box error.
    end.
    if v-vb-file-name = ?
    or v-vb-file-name = "":U
    then do:
        message
            "Œ¯Ë·Í‡ ËÏÂÌË Ù‡ÈÎ‡ ÍÓ‰‡ Ó·‡·ÓÚÍË."
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
            skip "Œ¯Ë·Í‡ ÒÓÁ‰‡ÌËˇ Ù‡ÈÎ‡ Excel."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.
end procedure. /* inv19xl-run-excel */


/*==========================================================================*/
procedure inv19xl-close :
do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
    if p-mode = "OKDP"
    then
        export "exe/inv19_okdp.xlt":U.
    else
        export "exe/inv19.xlt":U.
        export "exe/t_form.bas":U.
        export v-inv19xl-cell-file-name.
        export v-inv19xl-data-file-name.
    output close.
end.
end procedure. /* inv19xl-close */

/* $Workfile$ e n d */