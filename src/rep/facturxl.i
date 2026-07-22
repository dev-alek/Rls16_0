/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка данных для заполнения шаблона формы torg-12 в Excel

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

{ gbl/paramls.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define facturxl-line-data-key "LD":U
&global-define facturxl-valutCode "valutCode":U
&global-define facturxl-columnList "columnList":U
&global-define facturxl-columnType "columnType":U
&global-define facturxl-columnAmount "columnAmount":U
&global-define facturxl-subtotalList "subtotalList":U
&global-define facturxl-subtotalType "subtotalType":U
&global-define facturxl-subtotalAmount "subtotalAmount":U

&global-define facturxl-h_docCode "h_docCode":U
&global-define facturxl-h_docDate "h_docDate":U
&global-define facturxl-h_supplier "h_supplier":U
&global-define facturxl-h_supplierAddr "h_supplierAddr":U
&global-define facturxl-h_supplierINN "h_supplierINN":U
&global-define facturxl-h_cargoFrom "h_cargoFrom":U
&global-define facturxl-h_cargoTo "h_cargoTo":U
&global-define facturxl-h_platDoc "h_platDoc":U
&global-define facturxl-h_saler "h_saler":U
&global-define facturxl-h_salerAddr "h_salerAddr":U
&global-define facturxl-h_salerINN "h_salerINN":U
&global-define facturxl-h_summ_prop "h_summ_prop":U
&global-define facturxl-h_currency "h_currency":U
&global-define facturxl-h_suppNUM "h_suppNUM":U
&global-define facturxl-h_ordNUM "h_ordNUM":U
&global-define facturxl-h_idContract "h_idContract":U

&global-define facturxl-it_SumNoVAT "it_SumNoVAT":U
&global-define facturxl-it_VATsum "it_VATsum":U
&global-define facturxl-it_sum "it_sum":U

&global-define facturxl-it_sumNoVAT1 "it_sumNoVAT1":U
&global-define facturxl-it_VAT1 "it_VAT1":U
&global-define facturxl-it_sum1 "it_sum1":U
&global-define facturxl-it_sumNoVAT2 "it_sumNoVAT2":U
&global-define facturxl-it_VAT2 "it_VAT2":U
&global-define facturxl-it_sum2 "it_sum2":U

&global-define facturxl-f_buhName "f_buhName":U
&global-define facturxl-f_bossName "f_bossName":U
&global-define facturxl-f_ownerName "f_ownerName":U
&global-define facturxl-f_ownerReg "f_ownerReg":U

&global-define facturxl-f_labelVat10 "f_labelVat10":U
&global-define facturxl-f_sumNoVat10 "f_sumNoVat10":U
&global-define facturxl-f_sumVat10 "f_sumVat10":U
&global-define facturxl-f_sumWithVat10 "f_sumWithVat10":U
&global-define facturxl-f_labelVat18 "f_labelVat18":U
&global-define facturxl-f_sumNoVat18 "f_sumNoVat18":U
&global-define facturxl-f_sumVat18 "f_sumVat18":U
&global-define facturxl-f_sumWithVat18 "f_sumWithVat18":U


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
    field Name         as character
    field pokazately   as character
    field UAES         as character
    field OKEI         as character
    field EI           as character
    field qnty         as character
    field price        as character
    field SumNoVAT     as character
    field SumActciz    as character
    field VATpc        as character
    field VATsum       as character
    field sum          as character
    field countrycode  as character
    field country      as character
    field GTD          as character

    index pi is primary unique xl-line-id
.

define variable v-facturxl-current-data-row     as integer      no-undo.
define variable v-facturxl-cell-file-name       as character    no-undo.
define variable v-facturxl-data-file-name       as character    no-undo.

/*==========================================================================*/
procedure facturxl-init :

    define buffer buf_temp_cell-data        for temp_cell-data.
    define buffer buf_usr-flt               for ubflt.usr-flt.
    define variable v-column-list as character no-undo .
    define variable v-column-type as character no-undo .
    define variable v-num-cloumns as integer no-undo .
    
do
for buf_temp_cell-data
  , buf_usr-flt
on error undo, return error
:
    assign
        v-facturxl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-facturxl-data-file-name
    ).
    output stream excel-line to value( v-facturxl-data-file-name ).
    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-facturxl-cell-file-name
    ).
    output stream excel-cell to value( v-facturxl-cell-file-name ).

    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-valutCode}
        , input if printrubl then "0":U else "1":U
    ).

  if lookup ("corr" , p-mode) <> 0 then do :
    v-column-list = "Name,pokazately,UAES,OKEI,EI,qnty,price,SumNoVAT,SumActciz,VATpc,VATsum,sum":U .
    v-column-type = "S,S,S,I,S,D,C,C,S,D,C,C":U .
  end.
  else do :
    v-column-list = "Name,UAES,OKEI,EI,qnty,price,SumNoVAT,SumActciz,VATpc,VATsum,sum,countrycode,country,GTD":U .
    v-column-type = "S,S,I,S,D,C,C,S,D,C,C,I,S,S":U .
  end.
  v-num-cloumns = num-entries(v-column-list) .

  run facturxl-write-cell-data in this-procedure (
          input {&facturxl-columnList}
        , input v-column-list
  ).
  run facturxl-write-cell-data in this-procedure (
          input {&facturxl-columnType}
        , input v-column-type
  ).
  run facturxl-write-cell-data in this-procedure (
          input {&facturxl-columnAmount}
        , input string(v-num-cloumns)
  ).
  
  if lookup ("corr" , p-mode) <> 0 then .
  else do :
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-subtotalList}
        , input "SumNoVAT,VATsum,sum":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-subtotalType}
        , input "S,S,S":U
    ).
    run facturxl-write-cell-data in this-procedure (
          input {&facturxl-subtotalAmount}
        , input "3":U
    ).
  end.
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
/*                                , v-facturxl-cell-file-name*/
/*                                , v-facturxl-data-file-name*/
/*                              )*/
/*    .*/
end.
end procedure. /* facturxl-init */

/*==========================================================================*/
procedure facturxl-close :
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
/*                , v-facturxl-cell-file-name*/
/*                , v-facturxl-data-file-name*/
/*            )*/
/*        .*/
        export "exe/sf_97.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure. /* facturxl-close */


/*==========================================================================*/
procedure facturxl-close-10 :
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
/*                , v-facturxl-cell-file-name*/
/*                , v-facturxl-data-file-name*/
/*            )*/
/*        .*/
        export "exe/sf_97-10.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.
end.
end procedure. /* facturxl-close-10 */


/*==========================================================================*/
procedure facturxl-close-vat-itog :

do
on error undo, return error return-value
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97vat.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.

end.

end procedure. /* facturxl-close-vat-itog */


/*==========================================================================*/
procedure facturxl-close-topaukc :

do
on error undo, return error return-value
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/sf_97topaukc.xlt":U.
        export "exe/t_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.

end.

end procedure. /* facturxl-close-vat-itog */


/*==========================================================================*/
procedure facturxl-close-corr :

do
on error undo, return error return-value
:
/*  sheetf.Bas-Param-Add      = yes.
  sheetf.Bas-Params   = trim(v-lines-counter - 1).*/
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/corr_sf.xlt":U.
        export "exe/t_csf_97.bas":U.
        export v-facturxl-cell-file-name.
        export v-facturxl-data-file-name.
    output close.

end.

end procedure. /* facturxl-close-corr */


/*==========================================================================*/
procedure facturxl-write-cell-data :
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
end procedure. /* facturxl-write-cell-data */


/*==========================================================================*/
procedure facturxl-write-line-data :
define input parameter p-Name          as character        no-undo.
define input parameter p-UAES          as character        no-undo.
define input parameter p-OKEI          as character        no-undo.
define input parameter p-EI            as character        no-undo.
define input parameter p-qnty          as character        no-undo.
define input parameter p-price         as character        no-undo.
define input parameter p-SumNoVAT      as character        no-undo.
define input parameter p-SumActciz     as character        no-undo.
define input parameter p-VATpc         as character        no-undo.
define input parameter p-VATsum        as character        no-undo.
define input parameter p-sum           as character        no-undo.
define input parameter p-countrycode   as character        no-undo.
define input parameter p-country       as character        no-undo.
define input parameter p-GTD           as character        no-undo.


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
        v-facturxl-current-data-row = v-facturxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&facturxl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-facturxl-current-data-row
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.UAES         = p-UAES
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.SumNoVAT     = p-SumNoVAT
        buf_temp_line-data.SumActciz    = p-SumActciz
        buf_temp_line-data.VATpc        = p-VATpc
        buf_temp_line-data.VATsum       = p-VATsum
        buf_temp_line-data.sum          = p-sum
        buf_temp_line-data.countrycode  = p-countrycode
        buf_temp_line-data.country      = p-country
        buf_temp_line-data.GTD          = p-GTD
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.UAES
        {&tabulation}   buf_temp_line-data.OKEI
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.SumNoVAT
        {&tabulation}   buf_temp_line-data.SumActciz
        {&tabulation}   buf_temp_line-data.VATpc
        {&tabulation}   buf_temp_line-data.VATsum
        {&tabulation}   buf_temp_line-data.sum
        {&tabulation}   buf_temp_line-data.countrycode
        {&tabulation}   buf_temp_line-data.country
        {&tabulation}   buf_temp_line-data.GTD
        {&new-line}
    .
end.
end procedure. /* facturxl-write-line-data */


/*==========================================================================*/
procedure facturxl-write-line-data-corr :
define input parameter p-Name          as character        no-undo.
define input parameter p-pokazately    as character        no-undo.
define input parameter p-UAES          as character        no-undo.
define input parameter p-OKEI          as character        no-undo.
define input parameter p-EI            as character        no-undo.
define input parameter p-qnty          as character        no-undo.
define input parameter p-price         as character        no-undo.
define input parameter p-SumNoVAT      as character        no-undo.
define input parameter p-SumActciz     as character        no-undo.
define input parameter p-VATpc         as character        no-undo.
define input parameter p-VATsum        as character        no-undo.
define input parameter p-sum           as character        no-undo.


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
        v-facturxl-current-data-row = v-facturxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key     = {&facturxl-line-data-key}
        buf_temp_line-data.xl-line-id   = v-facturxl-current-data-row
        buf_temp_line-data.Name         = p-Name
        buf_temp_line-data.pokazately   = p-pokazately
        buf_temp_line-data.UAES         = p-UAES
        buf_temp_line-data.OKEI         = p-OKEI
        buf_temp_line-data.EI           = p-EI
        buf_temp_line-data.qnty         = p-qnty
        buf_temp_line-data.price        = p-price
        buf_temp_line-data.SumNoVAT     = p-SumNoVAT
        buf_temp_line-data.SumActciz    = p-SumActciz
        buf_temp_line-data.VATpc        = p-VATpc
        buf_temp_line-data.VATsum       = p-VATsum
        buf_temp_line-data.sum          = p-sum
    .
    put stream excel-line unformatted
                        buf_temp_line-data.data-key
        {&tabulation}   buf_temp_line-data.Name
        {&tabulation}   buf_temp_line-data.pokazately
        {&tabulation}   buf_temp_line-data.UAES
        {&tabulation}   buf_temp_line-data.OKEI
        {&tabulation}   buf_temp_line-data.EI
        {&tabulation}   buf_temp_line-data.qnty
        {&tabulation}   buf_temp_line-data.price
        {&tabulation}   buf_temp_line-data.SumNoVAT
        {&tabulation}   buf_temp_line-data.SumActciz
        {&tabulation}   buf_temp_line-data.VATpc
        {&tabulation}   buf_temp_line-data.VATsum
        {&tabulation}   buf_temp_line-data.sum
        {&new-line}
    .
end.
end procedure. /* facturxl-write-line-data-corr */



/*==========================================================================*/
procedure facturxl-run-excel :
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
        v-template-file-name    = search( "exe/sf_97.xlt" )
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
end procedure. /* facturxl-run-excel */

/* $Workfile$ e n d */