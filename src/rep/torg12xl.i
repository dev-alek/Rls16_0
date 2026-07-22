/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы torg-12 в Excel

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define torg12xl-line-data-key "LD":U
&global-define torg12xl-valutCode "valutCode":U
&global-define torg12xl-columnList "columnList":U
&global-define torg12xl-columnType "columnType":U
&global-define torg12xl-columnAmount "columnAmount":U
&global-define torg12xl-subtotalList "subtotalList":U
&global-define torg12xl-subtotalType "subtotalType":U
&global-define torg12xl-subtotalAmount "subtotalAmount":U

&global-define torg12xl-h_cargoTo "h_cargoTo":U
&global-define torg12xl-h_cargoToValue "h_cargoToValue":U
&global-define torg12xl-h_cliFrom "h_cliFrom":U
&global-define torg12xl-h_docCode "h_docCode":U
&global-define torg12xl-h_docDate "h_docDate":U
&global-define torg12xl-h_tbl_docCode "h_tbl_docCode":U
&global-define torg12xl-h_tbl_docDate "h_tbl_docDate":U
&global-define torg12xl-h_OKPO_0 "h_OKPO_0":U
&global-define torg12xl-h_OKPO "h_OKPO":U
&global-define torg12xl-h_OKPO2 "h_OKPO2":U
&global-define torg12xl-h_OKPO3 "h_OKPO3":U
&global-define torg12xl-h_operationType "h_operationType":U
&global-define torg12xl-h_orgFrom "h_orgFrom":U
&global-define torg12xl-h_reason "h_reason":U
&global-define torg12xl-h_reason_date "h_reason_date":U
&global-define torg12xl-h_reason_num "h_reason_num":U
&global-define torg12xl-h_saler "h_saler":U
&global-define torg12xl-h_supplier "h_supplier":U
&global-define torg12xl-h_uvd "h_uvd":U
&global-define torg12xl-f_buhName "f_buhName":U
&global-define torg12xl-f_lineAmount "f_lineAmount":U
&global-define torg12xl-f_massBrutto "f_massBrutto":U
&global-define torg12xl-f_massNetto "f_massNetto":U
&global-define torg12xl-f_pageAmount "f_pageAmount":U
&global-define torg12xl-f_permitterName "f_permitterName":U
&global-define torg12xl-f_permitterStatus "f_permitterStatus":U
&global-define torg12xl-f_placeAmount "f_placeAmount":U
&global-define torg12xl-f_sumLiteral1 "f_sumLiteral1":U
&global-define torg12xl-f_sumLiteral2 "f_sumLiteral2":U
&global-define torg12xl-it_qnty "it_qnty":U
&global-define torg12xl-it_SumNoVAT "it_SumNoVAT":U
&global-define torg12xl-it_VATsum "it_VATsum":U
&global-define torg12xl-it_sum "it_sum":U
&global-define torg12xl-f_sumLiteral1-length 40
&global-define torg12xl-h_from_to_uderline "h_from_to_uderline"
&global-define torg12xl-f_post "f_post"
&global-define torg12xl-f_wkr_name "f_wkr_name"
&global-define torg12xl-N_warrant_char "N_warrant_char"
&global-define torg12xl-Day_warrant "Day_warrant"
&global-define torg12xl-Date_warrant "Date_warrant"
&global-define torg12xl-accept_position "accept_position"
&global-define torg12xl-accept_fname "accept_fname"
&global-define torg12xl-N_ndovwho "N_ndovwho"
&global-define torg12xl-loadtplace "loadtplace"
&global-define torg12xl-loadtname "loadtname"
&global-define torg12xl-h_osn_doc_code "h_osn_doc_code"
&global-define torg12xl-h_osn_doc_date "h_osn_doc_date"
&global-define torg12xl-h_number_zak "h_number_zak"
&global-define torg12xl-h_number_post "h_number_post"
&global-define torg12xl-h_number_mag "h_number_mag"

define stream excel-line.
define stream excel-cell.

define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.
define temp-table temp_line-data no-undo
    field data-key     as character
    field xl-line-id   as integer
    field ID           as integer
    field Name         as character
    field gdscode      as character
    field EI           as character
    field OKEI         as character
    field pack         as character
    field AmountInPl   as character
    field PlaceAmount  as character
    field Mass         as character
    field qnty         as character
    field price        as character
    field SumNoVAT     as character
    field VATpc        as character
    field VATsum       as character
    field sum          as character
    field cntrycode    as character
    field cntryorg     as character
    field numgtd       as character

    index pi is primary unique xl-line-id
.

define variable v-torg12xl-current-data-row     as integer      no-undo.
define variable v-torg12xl-cell-file-name       as character    no-undo.
define variable v-torg12xl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure torg12xl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-torg12xl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-torg12xl-data-file-name
    ).
    output stream excel-line to value( v-torg12xl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-torg12xl-cell-file-name
    ).
    output stream excel-cell to value( v-torg12xl-cell-file-name ).

    if printrubl
    then do:
        run torg12xl-write-cell-data in this-procedure (
              input {&torg12xl-valutCode}
            , input "0":U
        ).
    end.
    else do:
        run torg12xl-write-cell-data in this-procedure (
              input {&torg12xl-valutCode}
            , input "1":U
        ).
    end.
    if lookup( "TOPAUKC":U, p-mode ) <> 0 and lookup( "GTD":U, p-mode ) <> 0
    then do:
      run torg12xl-write-cell-data in this-procedure (
            input {&torg12xl-columnList}
          , input "ID,Name,gdscode,EI,OKEI,pack,AmountInPl,PlaceAmount,Mass,qnty,price,SumNoVAT,VATpc,VATsum,sum,cntrycode,cntryorg,numgtd":U
      ).
      run torg12xl-write-cell-data in this-procedure (
            input {&torg12xl-columnType}
          , input "I,S,I,S,S,S,D,D,D,D,C,C,D,C,C,S,S,S":U
      ).
      run torg12xl-write-cell-data in this-procedure (
            input {&torg12xl-columnAmount}
          , input "18":U
      ).
    end.
    else do:
      run torg12xl-write-cell-data in this-procedure (
            input {&torg12xl-columnList}
          , input "ID,Name,gdscode,EI,OKEI,pack,AmountInPl,PlaceAmount,Mass,qnty,price,SumNoVAT,VATpc,VATsum,sum":U
      ).
      run torg12xl-write-cell-data in this-procedure (
            input {&torg12xl-columnType}
          , input "I,S,I,S,S,S,S,S,S,D,C,C,D,C,C":U
      ).
      run torg12xl-write-cell-data in this-procedure (
            input {&torg12xl-columnAmount}
          , input "15":U
      ).
    end.
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-subtotalList}
        , input "qnty,SumNoVAT,VATsum,sum":U
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-subtotalType}
        , input "S,S,S,S":U
    ).
    run torg12xl-write-cell-data in this-procedure (
          input {&torg12xl-subtotalAmount}
        , input "4":U
    ).
/*    find first buf_usr-flt exclusive-lock*/
/*         where buf_usr-flt.user-name    = g#userid*/
/*           and buf_usr-flt.call-point   = "macroxlt":U*/
/*    no-error.*/
/*    if not available buf_usr-flt*/
/*    then do:*/
/*        create buf_usr-flt.*/
/*        assign*/
/*            buf_usr-flt.user-name    = g#userid*/
/*            buf_usr-flt.call-point   = "macroxlt":U*/
/*        .*/
/*    end.*/
/*    assign*/
/*        buf_usr-flt.Naim    = "torg12"*/
/*        buf_usr-flt.List_   = substitute( "&1,&2"*/
/*                                , v-torg12xl-cell-file-name*/
/*                                , v-torg12xl-data-file-name*/
/*                              )*/
/*    .*/
end.
end procedure. /* torg12xl-init */

/*==========================================================================*/
procedure torg12xl-close :
define input parameter p-mode               as character        no-undo.
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
/*                , v-torg12xl-cell-file-name*/
/*                , v-torg12xl-data-file-name*/
/*            )*/
/*        .*/

        if lookup( "KEDR":U , p-mode ) <> 0 then do:
          export "exe/t12_97Kedr.xlt":U.
        end.
        else do:
          if lookup( "TOPAUKC":U, p-mode ) <> 0
          then do:
            if lookup( "GTD":U, p-mode ) <> 0
            then do:
              export "exe/t12_97bb.xlt":U.
            end.
            else do:
              export "exe/t12_97b.xlt":U.
            end.
          end.
          else do:
            export "exe/t12_97.xlt":U.
          end.
        end.
        export "exe/t_97.bas":U.
        export v-torg12xl-cell-file-name.
        export v-torg12xl-data-file-name.
    output close.
end.
end procedure. /* torg12xl-close */


/*==========================================================================*/
procedure torg12xl-write-cell-data :
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
end procedure. /* torg12xl-write-cell-data */


/*==========================================================================*/
procedure torg12xl-write-line-data :
define input parameter p-ID             as integer          no-undo.
define input parameter p-Name           as character        no-undo.
define input parameter p-gdscode        as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-OKEI           as character        no-undo.
define input parameter p-pack           as character        no-undo.
define input parameter p-AmountInPl     as character        no-undo.
define input parameter p-PlaceAmount    as character        no-undo.
define input parameter p-Mass           as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-SumNoVAT       as character        no-undo.
define input parameter p-VATpc          as character        no-undo.
define input parameter p-VATsum         as character        no-undo.
define input parameter p-sum            as character        no-undo.

    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:

    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-torg12xl-current-data-row = v-torg12xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&torg12xl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-torg12xl-current-data-row
        buf_temp_line-data.id           = p-id
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.gdscode      = p-gdscode
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.pack         = p-pack
        buf_temp_line-data.AmountInPl   = p-AmountInPl
        buf_temp_line-data.PlaceAmount  = p-PlaceAmount
        buf_temp_line-data.Mass         = p-Mass
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.SumNoVAT     = p-SumNoVAT
        buf_temp_line-data.VATpc        = p-VATpc
        buf_temp_line-data.VATsum       = p-VATsum
        buf_temp_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   ( if buf_temp_line-data.id = 0 then "":U else string( buf_temp_line-data.id ) )
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.gdscode
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.OKEI
        {&tabulation}   buf_temp_line-data.pack
        {&tabulation}   buf_temp_line-data.AmountInPl
        {&tabulation}   buf_temp_line-data.PlaceAmount
        {&tabulation}   buf_temp_line-data.Mass
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.SumNoVAT
        {&tabulation}   buf_temp_line-data.VATpc
        {&tabulation}   buf_temp_line-data.VATsum
        {&tabulation}   buf_temp_line-data.sum
        {&new-line}
    .
end.
end procedure. /* torg12xl-write-line-data */


/*==========================================================================*/
procedure torg12bbxl-write-line-data :
define input parameter p-ID             as integer          no-undo.
define input parameter p-Name           as character        no-undo.
define input parameter p-gdscode        as character        no-undo.
define input parameter p-EI             as character        no-undo.
define input parameter p-OKEI           as character        no-undo.
define input parameter p-pack           as character        no-undo.
define input parameter p-AmountInPl     as character        no-undo.
define input parameter p-PlaceAmount    as character        no-undo.
define input parameter p-Mass           as character        no-undo.
define input parameter p-qnty           as character        no-undo.
define input parameter p-price          as character        no-undo.
define input parameter p-SumNoVAT       as character        no-undo.
define input parameter p-VATpc          as character        no-undo.
define input parameter p-VATsum         as character        no-undo.
define input parameter p-sum            as character        no-undo.
define input parameter p-cntrycode      as character        no-undo.
define input parameter p-cntryorg       as character        no-undo.
define input parameter p-numgtd         as character        no-undo.

    define buffer buf_temp_line-data        for temp_line-data.
do
for buf_temp_line-data
on error undo, return error
:

    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-torg12xl-current-data-row = v-torg12xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&torg12xl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-torg12xl-current-data-row
        buf_temp_line-data.id           = p-id
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.gdscode      = p-gdscode
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.pack         = p-pack
        buf_temp_line-data.AmountInPl   = p-AmountInPl
        buf_temp_line-data.PlaceAmount  = p-PlaceAmount
        buf_temp_line-data.Mass         = p-Mass
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.SumNoVAT     = p-SumNoVAT
        buf_temp_line-data.VATpc        = p-VATpc
        buf_temp_line-data.VATsum       = p-VATsum
        buf_temp_line-data.sum          = p-sum
        buf_temp_line-data.cntrycode    = p-cntrycode
        buf_temp_line-data.cntryorg     = p-cntryorg
        buf_temp_line-data.numgtd       = p-numgtd
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   ( if buf_temp_line-data.id = 0 then "":U else string( buf_temp_line-data.id ) )
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.gdscode
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.OKEI
        {&tabulation}   buf_temp_line-data.pack
        {&tabulation}   buf_temp_line-data.AmountInPl
        {&tabulation}   buf_temp_line-data.PlaceAmount
        {&tabulation}   buf_temp_line-data.Mass
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.SumNoVAT
        {&tabulation}   buf_temp_line-data.VATpc
        {&tabulation}   buf_temp_line-data.VATsum
        {&tabulation}   buf_temp_line-data.sum
        {&tabulation}   buf_temp_line-data.cntrycode
        {&tabulation}   buf_temp_line-data.cntryorg
        {&tabulation}   buf_temp_line-data.numgtd
        {&new-line}
    .
end.
end procedure. /* torg12xl-write-line-data */


/*==========================================================================*/
procedure torg12xl-run-excel :
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

    if lookup( "TOPAUKC":U, p-mode ) <> 0
    then do:
      if lookup( "GTD":U, p-mode ) <> 0
      then do:
        assign
            v-template-file-name    = search( "exe/t12_97bb.xlt" )
        .
      end.
      else do:
        assign
            v-template-file-name    = search( "exe/t12_97b.xlt" )
        .
      end.
    end.
    else do:
      assign
          v-template-file-name    = search( "exe/t12_97.xlt" )
        .
      end.
    assign
        v-vb-file-name          = search( "exe/t_97.bas")
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
end procedure. /* torg12xl-run-excel */

/* $Workfile$ e n d */