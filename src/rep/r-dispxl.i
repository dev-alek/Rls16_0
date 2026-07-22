/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Белоусов Илья Александрович
Дата создания: 11/27/07
Author: Ilia Belousov
Creation date: 11/27/07

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/* GLOBAL*/
&global-define disp-xl-line-data-key  "LD":U
&global-define disp-xl-valutCode      "valutCode":U
&global-define disp-xl-columnList     "columnList":U
&global-define disp-xl-columnType     "columnType":U
&global-define disp-xl-columnAmount   "columnAmount":U
&global-define disp-xl-subtotalList   "subtotalList":U
&global-define disp-xl-subtotalType   "subtotalType":U
&global-define disp-xl-subtotalAmount "subtotalAmount":U

/* шапка и подвал */
&global-define disp-xl-h_obj-name-list   "h_obj_name_list":U
&global-define disp-xl-h_date            "h_date":U
&global-define disp-xl-h_time            "h_time":U


/* VARIABLES*/
DEFINE VARIABLE v-disp-xl-current-data-row AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-disp-xl-cell-file-name   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-disp-xl-data-file-name   AS CHARACTER NO-UNDO.

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
    field obj-number      as character
    field obj-address     as character
    field obj-phone       as character
    field gds-name        as character
    field loc1            as character
    field max-qnty        as character
    field add-qnty        as character
    field sale-qnty-7     as character
    field curr-qnty       as character
    field level-water     as character
    field volume-water    as character
    field doc-qnty       as character
    field curr-date       as character
    field curr-time       as character
    field sale-qnty-1     as character

    index pi is primary unique
        xl-line-id
.

/************************************************************************
   PROCEDURES

*************************************************************************/
PROCEDURE disp-xl-init :
DO
ON ERROR UNDO, RETURN ERROR
:
   ASSIGN
      v-disp-xl-current-data-row = 0
   .
   run gbl/_tmpfile.p (
         INPUT "xd"
      , INPUT ".txt"
      , OUTPUT v-disp-xl-data-file-name
   ).
   OUTPUT STREAM excel-line TO value( v-disp-xl-data-file-name ).
   run gbl/_tmpfile.p (
         INPUT "xc"
      , INPUT ".txt"
      , OUTPUT v-disp-xl-cell-file-name
   ).
   OUTPUT STREAM excel-cell TO value( v-disp-xl-cell-file-name ).

   run disp-xl-write-cell-data in this-procedure (
         input {&disp-xl-valutCode}
      , input "1":U
   ).
   RUN disp-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT {&disp-xl-columnList}
      , INPUT "obj_number,obj_address,obj_phone,gds_name,loc1,max_qnty,add_qnty,sale_qnty_7,curr_qnty,doc_qnty,level_water,volume_water,curr_date,curr_time,sale_qnty_1":U
   ).
   RUN disp-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT {&disp-xl-columnType}
      , INPUT "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
   ).
   RUN disp-xl-write-cell-data IN THIS-PROCEDURE (
         INPUT {&disp-xl-columnAmount}
      , INPUT "15":U
   ).

END.
END PROCEDURE. /* disp-xl-init */



PROCEDURE disp-xl-close :
DO
ON ERROR UNDO, RETURN ERROR
:
    OUTPUT STREAM excel-line CLOSE.
    OUTPUT STREAM excel-cell CLOSE.
    OUTPUT TO value( STRING( SESSION:temp-directory + "$" + STRING( g#report-num ) ) + ".txl" ) /*!!! APPEND*/ .
        EXPORT "exe/rep-disp.xlt":U.
        EXPORT "exe/t_97.bas":U.
        EXPORT v-disp-xl-cell-file-name.
        EXPORT v-disp-xl-data-file-name.
    OUTPUT CLOSE.
END.
END PROCEDURE. /* disp-xl-close */



PROCEDURE disp-xl-write-cell-data :
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
end procedure. /* disp-xl-write-cell-data */



PROCEDURE disp-xl-write-line-data :
DEFINE INPUT PARAMETER p-obj-number  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-address AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-phone   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-gds-name    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-loc1        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-max-qnty    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-add-qnty    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-sale-qnty-7 AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-qnty   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-level-water AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-volume-water AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-doc-qnty    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-date   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-time   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-sale-qnty-1 AS CHARACTER NO-UNDO.


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
        v-disp-xl-current-data-row = v-disp-xl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key   = {&disp-xl-line-data-key}
        buf_temp_line-data.xl-line-id = v-disp-xl-current-data-row

        buf_temp_line-data.obj-number    = p-obj-number
        buf_temp_line-data.obj-address   = p-obj-address
        buf_temp_line-data.obj-phone     = p-obj-phone
        buf_temp_line-data.gds-name      = p-gds-name
        buf_temp_line-data.loc1          = p-loc1
        buf_temp_line-data.max-qnty      = p-max-qnty
        buf_temp_line-data.add-qnty      = p-add-qnty
        buf_temp_line-data.sale-qnty-7   = p-sale-qnty-7
        buf_temp_line-data.curr-qnty     = p-curr-qnty
        buf_temp_line-data.level-water   = p-level-water
        buf_temp_line-data.volume-water  = p-volume-water
/*        buf_temp_line-data.doc-qnty      = p-doc-qnty*/
        buf_temp_line-data.curr-date     = p-curr-date
        buf_temp_line-data.curr-time     = p-curr-time
        buf_temp_line-data.sale-qnty-1   = p-sale-qnty-1
    .

    PUT STREAM excel-line UNFORMATTED
                        buf_temp_line-data.data-key
        {&tabulation}   p-obj-number
        {&tabulation}   p-obj-address
        {&tabulation}   p-obj-phone
        {&tabulation}   p-gds-name
        {&tabulation}   p-loc1
        {&tabulation}   p-max-qnty
        {&tabulation}   p-add-qnty
        {&tabulation}   p-sale-qnty-7
        {&tabulation}   p-curr-qnty
        {&tabulation}   p-doc-qnty
        {&tabulation}   p-level-water
        {&tabulation}   p-volume-water
        {&tabulation}   p-curr-date
        {&tabulation}   p-curr-time
        {&tabulation}   p-sale-qnty-1
        {&new-line}
    .
END.
END PROCEDURE. /* disp-xl-write-line-data */



PROCEDURE disp-xl-run-excel :
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
        v-template-file-name    = SEARCH( "exe/rep-disp.xlt" )
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
END PROCEDURE. /* disp-xl-run-excel */
/* $Workfile$ e n d */