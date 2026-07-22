/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 02/18/08
Author: Ilia Belousov
Creation date: 02/18/08

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


/* GLOBAL*/
&global-define np34-xl-line-data-key  "LD":U
&global-define np34-xl-valutCode      "valutCode":U
&global-define np34-xl-columnList     "columnList":U
&global-define np34-xl-columnType     "columnType":U
&global-define np34-xl-columnAmount   "columnAmount":U
&global-define np34-xl-subtotalList   "subtotalList":U
&global-define np34-xl-subtotalType   "subtotalType":U
&global-define np34-xl-subtotalAmount "subtotalAmount":U

/* шапка и подвал */
&global-define np34-xl-h_obj             "h_obj":U
&global-define np34-xl-h_date_begin      "h_date_begin":U
&global-define np34-xl-h_date_end        "h_date_end":U
&global-define np34-xl-h_firm            "h_firm":U
&global-define np34-xl-h_type            "h_type":U
&global-define np34-xl-h_director        "h_director":U
&global-define np34-xl-h_gen_acct        "h_gen_acct":U


/* VARIABLES*/
DEFINE VARIABLE v-np34-xl-current-data-row AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-np34-xl-cell-file-name   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-np34-xl-data-file-name   AS CHARACTER NO-UNDO.

/* STREAMS */
DEFINE STREAM excel-line.
DEFINE STREAM excel-cell.

/* TEMP-TABLES */
define temp-table temp_cell-data no-undo
    field data-key as character
    field data-value as character

    index pi is primary unique data-key
.

define temp-table temp_line-data no-undo
    field data-key      as character
    field xl-line-id    as integer

    field number             as character
    field gds_name           as character
    field gds_code           as character
    field auto               as character

    field income_qnty_t      as character
    field normal_wastage     as character
    field wastage_qnty       as character

    field total_wast_qnty      as character
    field price              as character
    field summ               as character

    index pi is primary unique
        xl-line-id
.

/************************************************************************
   PROCEDURES

*************************************************************************/
PROCEDURE np34-xl-init :
DO
ON ERROR UNDO, RETURN ERROR
:
   ASSIGN
      v-np34-xl-current-data-row = 0
   .
   run gbl/_tmpfile.p (
         INPUT "xd"
      , INPUT ".txt"
      , OUTPUT v-np34-xl-data-file-name
   ).
   OUTPUT STREAM excel-line TO value( v-np34-xl-data-file-name ).
   run gbl/_tmpfile.p (
         INPUT "xc"
      , INPUT ".txt"
      , OUTPUT v-np34-xl-cell-file-name
   ).
   OUTPUT STREAM excel-cell TO value( v-np34-xl-cell-file-name ).

   run np34-xl-write-cell-data in this-procedure (
         input {&np34-xl-valutCode}
      , input "1":U
   ).
   RUN np34-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT {&np34-xl-columnList}
      , INPUT "number,gds_name,gds_code,auto,income_qnty_t,normal_wastage,wastage_qnty,total_wast_qnty,price,summ":U

   ).
   RUN np34-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT {&np34-xl-columnType}
      , INPUT "S,S,S,S,S,S,S,S,S,S":U
   ).
   RUN np34-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT {&np34-xl-columnAmount}
      , INPUT "10":U
   ).

END.
END PROCEDURE. /* np34-xl-init */



PROCEDURE np34-xl-close :
DO
ON ERROR UNDO, RETURN ERROR
:
    OUTPUT STREAM excel-line CLOSE.
    OUTPUT STREAM excel-cell CLOSE.
    OUTPUT TO value( STRING( SESSION:temp-directory + "rpt" + STRING( g#report-num ) ) + ".txl" ) /*!!! APPEND*/ .
        EXPORT "exe/rep-np34.xlt":U.
        EXPORT "exe/t_97.bas":U.
        EXPORT v-np34-xl-cell-file-name.
        EXPORT v-np34-xl-data-file-name.
    OUTPUT CLOSE.
END.
END PROCEDURE. /* np34-xl-close */



PROCEDURE np34-xl-write-cell-data :
DEFINE INPUT PARAMETER p-data-key   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-data-value AS CHARACTER NO-UNDO.

define buffer buf_temp_cell-data     for temp_cell-data.

DO
ON ERROR UNDO, RETURN ERROR
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
end procedure. /* np34-xl-write-cell-data */



PROCEDURE np34-xl-write-line-data :
DEFINE INPUT PARAMETER p-number         AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-gds_name       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-gds_code       AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-auto           AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-income_qnty_t  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-normal_wastage AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-wastage_qnty   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-total_wast_qnty  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-price          AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-summ           AS CHARACTER NO-UNDO.


define buffer buf_temp_line-data        for temp_line-data.

DO
ON ERROR UNDO, RETURN ERROR
:

    for each buf_temp_line-data
    :
        delete buf_temp_line-data.
    end.
    create buf_temp_line-data.
    assign
        v-np34-xl-current-data-row = v-np34-xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key   = {&np34-xl-line-data-key}
        buf_temp_line-data.xl-line-id = v-np34-xl-current-data-row

        buf_temp_line-data.number          = p-number
        buf_temp_line-data.gds_name        = p-gds_name
        buf_temp_line-data.gds_code        = p-gds_code
        buf_temp_line-data.auto            = p-auto
        buf_temp_line-data.income_qnty_t   = p-income_qnty_t
        buf_temp_line-data.normal_wastage  = p-normal_wastage
        buf_temp_line-data.wastage_qnty    = p-wastage_qnty
        buf_temp_line-data.total_wast_qnty   = p-total_wast_qnty
        buf_temp_line-data.price           = p-price
        buf_temp_line-data.summ            = p-summ
    .

    PUT STREAM excel-line UNFORMATTED
                        buf_temp_line-data.data-key
        {&tabulation}   p-number
        {&tabulation}   p-gds_name
        {&tabulation}   p-gds_code
        {&tabulation}   p-auto
        {&tabulation}   p-income_qnty_t
        {&tabulation}   p-normal_wastage
        {&tabulation}   p-wastage_qnty
        {&tabulation}   p-total_wast_qnty
        {&tabulation}   p-price
        {&tabulation}   p-summ
        {&new-line}
    .
END.
END PROCEDURE. /* np34-xl-write-line-data */



PROCEDURE np34-xl-run-excel :
DEFINE INPUT PARAMETER p-header-filename    AS CHARACTER        NO-UNDO.
DEFINE INPUT PARAMETER p-data-filename      AS CHARACTER        NO-UNDO.

DEFINE VARIABLE v-template-file-name    AS CHARACTER    NO-UNDO.
DEFINE VARIABLE v-vb-file-name          AS CHARACTER    NO-UNDO.

DEFINE BUFFER buf_temp-param FOR temp-param .
DO
FOR buf_temp-param
ON ERROR UNDO, RETURN ERROR
:
    CREATE buf_temp-param.
    ASSIGN
        v-template-file-name    = SEARCH( "exe/rep-np34.xlt" )
        v-vb-file-name          = SEARCH( "exe/t_97.bas")
    .
    IF v-template-file-name = ?
    OR v-template-file-name = "":U
    THEN DO:
        MESSAGE
            "Ошибка имени файла шаблона."
        VIEW-AS ALERT-BOX ERROR.
    END.
    IF v-vb-file-name = ?
    OR v-vb-file-name = "":U
    THEN DO:
        MESSAGE
            "Ошибка имени файла кода обработки."
        VIEW-AS ALERT-BOX ERROR.
    END.

    RUN paramls-write IN THIS-PROCEDURE (
          INPUT {&paramls-template}
        , INPUT {&paramls-template-file-name}
        , INPUT v-template-file-name
    ).
    RUN paramls-write IN THIS-PROCEDURE (
          INPUT {&paramls-template}
        , INPUT {&paramls-vb-file-name}
        , INPUT v-vb-file-name
    ).
    RUN PARAMLS-WRITE IN THIS-PROCEDURE (
          INPUT {&paramls-data}
        , INPUT {&paramls-data-header-filename}
        , INPUT p-header-filename
    ).
    RUN paramls-write IN THIS-PROCEDURE (
          INPUT {&paramls-data}
        , INPUT {&paramls-data-filename}
        , INPUT p-data-filename
    ).
    run gbl/macroxlt.p (
        INPUT-OUTPUT table buf_temp-param
    ) NO-ERROR.
    IF ERROR-STATUS :ERROR
    THEN DO:
        MESSAGE
                 vss-workfile vss-revision vss-description
            SKIP(1)
            SKIP "Ошибка создания файла Excel."
            SKIP RETURN-VALUE
            SKIP TRIM(ERROR-STATUS :GET-MESSAGE(1))
                 TRIM(ERROR-STATUS :GET-MESSAGE(2))
                 TRIM(ERROR-STATUS :GET-MESSAGE(3))
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR .
    END.
END.
END PROCEDURE. /* np34-xl-run-excel *//* $Workfile$ e n d */