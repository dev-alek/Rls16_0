/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Акт приема и недовоза нефтепродуктов - EXCEL

Автор: Сливенко Сергей Андреевич
Дата создания: 10/14/11
Author: Sergey Slivenko
Creation date: 10/14/11

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define apn-xl-line-data-key         "LD":U

&global-define apn-xl-valutCode             "valutCode":U
&global-define apn-xl-columnList            "columnList":U
&global-define apn-xl-columnType            "columnType":U
&global-define apn-xl-columnAmount          "columnAmount":U

&global-define apn-xl-subtotalList          "subtotalList":U
&global-define apn-xl-subtotalType          "subtotalType":U
&global-define apn-xl-subcolumnAmount       "subcolumnAmount":U

&global-define apn-xl-num_doc               "num_doc":U
&global-define apn-xl-object                "obj":U
&global-define apn-xl-str_date              "str_date":U
&global-define apn-xl-obj_address           "obj_address":U
&global-define apn-xl-cli_name_auto_ent     "cli_name_auto_ent":U
&global-define apn-xl-driver_name           "driver_name":U
&global-define apn-xl-driver_name2          "driver_name2":U
&global-define apn-xl-driver_name3          "driver_name3":U
&global-define apn-xl-host_name             "host_name":U
&global-define apn-xl-host_name2            "host_name2":U
&global-define apn-xl-mngr_name             "manager_name":U
&global-define apn-xl-gds-name              "par1":U
&global-define apn-xl-num_passport          "num_passport":U
&global-define apn-xl-norm_doc              "norm_doc":U
&global-define apn-xl-certif_fuel           "certif_fuel1":U
&global-define apn-xl-validity_certif       "validity_certif":U
&global-define apn-xl-num_areom             "num_areom":U
&global-define apn-xl-num_plotn             "num_plotn":U
&global-define apn-xl-date_pov_areom        "date_pov_areom":U
&global-define apn-xl-date_pov_plotn        "date_pov_plotn":U
&global-define apn-xl-passport_plotn        "passport_plotn":U
&global-define apn-xl-gds_name2             "gds_name2":U
&global-define apn-xl-gds_name3             "gds_name3":U
&global-define apn-xl-gds_name7             "gds_name7":U
&global-define apn-xl-doc-code              "par5":U
&global-define apn-xl-doc-date              "par5_2":U
&global-define apn-xl-cli-name              "par6":U
&global-define apn-xl-point_fill_fuel       "point_fill_fuel":U
&global-define apn-xl-time_pour             "time_pour":U
&global-define apn-xl-car-num               "par9":U
&global-define apn-xl-inspection_cert       "inspection_cert":U
&global-define apn-xl-date_cert             "date_cert":U
&global-define apn-xl-car_vol               "car_vol":U
&global-define apn-xl-date-start            "par13_1":U
&global-define apn-xl-time-start            "par13_2":U
&global-define apn-xl-time-end              "par13_3":U
&global-define apn-xl-trn_date_ic           "trn_date_ic":U
&global-define apn-xl-doc-qnty              "par16_1":U
&global-define apn-xl-tank-vol              "par16_2":U
&global-define apn-xl-doc-density           "par17_1":U
&global-define apn-xl-tank-density          "par17_2":U
&global-define apn-xl-temperature           "par18_1":U
&global-define apn-xl-dens_temp_fact        "dens_temp_fact":U
&global-define apn-xl-cli-qnty              "par19":U
&global-define apn-xl-fact_qnty_kg          "fact_qnty_kg":U
&global-define apn-xl-error_meas_kg         "error_meas_kg":U
&global-define apn-xl-norm_natur_losses     "norm_natur_losses":U
&global-define apn-xl-sum_errm_and_norml_kg "sum_errm_and_norml_kg":U
&global-define apn-xl-tank_vol_pomi_15C     "tank_vol_pomi_15C":U
&global-define apn-xl-tank_density_pomi_15C "tank_density_pomi_15C":U
&global-define apn-xl-tank_weight_kg_15C    "tank_weight_kg_15C":U
&global-define apn-xl-error_meas_kg_15C     "error_meas_kg_15C":U
&global-define apn-xl-norm_natur_losses_15C "norm_natur_losses_15C":U
&global-define apn-xl-sum_errm_and_norm_15C "sum_errm_and_norm_15C":U
&global-define apn-xl-diff_tank_vol_pomi    "diff_tank_vol_pomi":U
&global-define apn-xl-diff_tank_density_pomi "diff_tank_density_pomi":U
&global-define apn-xl-diff_dens_temp        "diff_dens_temp":U
&global-define apn-xl-diff_qnty_kg          "diff_qnty_kg":U
&global-define apn-xl-shortage_surplus_kg   "shortage_surplus_kg":U
&global-define apn-xl-diff_norm_natur_losses "diff_norm_natur_losses":U
&global-define apn-xl-diff_tank_vol_pomi_15C "diff_tank_vol_pomi_15C":U
&global-define apn-xl-tank_vol_pomi_DLL      "tank_vol_pomi_DLL":U
&global-define apn-xl-tank_density_pomi_DLL "tank_density_pomi_DLL":U
&global-define apn-xl-tank_weight_DLL       "tank_weight_DLL":U
&global-define apn-xl-diff_tnk_dens_pomi_15C "diff_tnk_dens_pomi_15C":U
&global-define apn-xl-diff_qnty_kg_15C      "diff_qnty_kg_15C":U
&global-define apn-xl-shor_surplus_kg_15C   "shor_surplus_kg_15C":U
&global-define apn-xl-diff_norm_nat_los_15C "diff_norm_nat_los_15C":U
&global-define apn-xl-a_b_tarir_fact        "a_b_tarir_fact":U
&global-define apn-xl-tank_name_and_coord   "tank_name_and_coord":U
&global-define apn-xl-driver_name4          "driver_name4":U
&global-define apn-xl-host_name3            "host_name3":U

define stream excel-line .
define stream excel-cell .

define temp-table temp_cell-data no-undo
    field data-key   as character
    field data-value as character

    index pi is primary unique data-key
.


define variable v-apn-xl-cell-file-name  as character    no-undo .
define variable v-apn-xl-data-file-name  as character    no-undo .

/*==========================================================================*/
procedure apn-xl-init :

do
on error undo, return error
:
        run gbl/_tmpfile.p (
          input "xd"
        , input ".txt"
        , output v-apn-xl-data-file-name
    ).
    output stream excel-line to value( v-apn-xl-data-file-name ).

    run gbl/_tmpfile.p (
          input "xc"
        , input ".txt"
        , output v-apn-xl-cell-file-name
    ).
    output stream excel-cell to value( v-apn-xl-cell-file-name ).

    run apn-xl-write-cell-data in this-procedure (
          input {&apn-xl-valutCode}
        , input "0":U
    ).

    run apn-xl-write-cell-data in this-procedure (
          input {&apn-xl-columnList}
        , input "":U
    ).
    run apn-xl-write-cell-data in this-procedure (
          input {&apn-xl-columnType}
        , input "":U
    ).
    run apn-xl-write-cell-data in this-procedure (
          input {&apn-xl-columnAmount}
        , input "0":U
    ).

end.
end procedure. /* apn-xl-init */


/*==========================================================================*/
procedure apn-xl-write-cell-data :
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
end procedure. /* apn-xl-write-cell-data */

/*==========================================================================*/
procedure apn-xl-run-excel :
define input parameter p-header-filename    as character    no-undo .
define input parameter p-data-filename      as character    no-undo .

define variable v-template-file-name        as character    no-undo .
define variable v-vb-file-name              as character    no-undo .

    define buffer buf_temp-param for temp-param .
do
for buf_temp-param
on error undo, return error
:
    create buf_temp-param.
    assign
        v-template-file-name    = search( "exe/akt-p-n-petrl.xlt" )
        v-vb-file-name          = search( "exe/akt-p-n-petrl.bas")
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
end procedure. /* apn-xl-run-excel */


/*==========================================================================*/
procedure apn-xl-close :


do
on error undo, return error
:
    output stream excel-line close.
    output stream excel-cell close.
    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) append.
        export "exe/akt-p-n-petrl.xlt":U.
        export "exe/akt-p-n-petrl.bas":U.
        export v-apn-xl-cell-file-name.
        export v-apn-xl-data-file-name.
    output close.
end.
end procedure. /* apn-xl-close */