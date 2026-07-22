/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнения шаблона отчета по алкоголю

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/
/************************************************************************
   Definitions

*************************************************************************/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

/* GLOBAL*/
&global-define alcxl-line-data-key  "LD":U
&global-define alcxl-valutCode      "valutCode":U
&global-define alcxl-columnList     "columnList":U
&global-define alcxl-columnType     "columnType":U
&global-define alcxl-columnAmount   "columnAmount":U
&global-define alcxl-subtotalList   "subtotalList":U
&global-define alcxl-subtotalType   "subtotalType":U
&global-define alcxl-subtotalAmount "subtotalAmount":U
/* шапка и подвал */
&global-define alcxl-h_FirmName   "h_FirmName":U
&global-define alcxl-h_FirmINN    "h_FirmINN":U
&global-define alcxl-h_FirmAddr   "h_FirmAddr":U
&global-define alcxl-h_ObjAddr    "h_ObjAddr":U
&global-define alcxl-h_FirmSert   "h_FirmSert":U
&global-define alcxl-h_FirmWork   "h_FirmWork":U
&global-define alcxl-h_FirmRegion "h_FirmRegion":U
&global-define alcxl-h_Period     "h_Period":U

/* ИТОГО */
&global-define alcxl-it_BeginQnt "it_BeginQnt":U
&global-define alcxl-it_Income   "it_Income":U
&global-define alcxl-it_Sale     "it_Sale":U
&global-define alcxl-it_Outgo    "it_Outgo":U
&global-define alcxl-it_OutgoTot "it_OutgoTot":U
&global-define alcxl-it_EndQnt   "it_EndQnt":U

/* VARIABLES*/
DEFINE VARIABLE v-alcxl-current-data-row AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-alcxl-cell-file-name   AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-alcxl-data-file-name   AS CHARACTER NO-UNDO.

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
    FIELD AlcName       AS CHARACTER
    FIELD AlcCode       AS CHARACTER
    FIELD AlcVal        AS CHARACTER
    FIELD Proff         AS CHARACTER
    FIELD RegCode       AS CHARACTER
    FIELD ProcName      AS CHARACTER
    FIELD ProcINN       AS CHARACTER
    FIELD ProcAddr      AS CHARACTER
    FIELD BeginQnt      AS CHARACTER
    FIELD SuppName      AS CHARACTER
    FIELD SuppINN       AS CHARACTER
    FIELD SuppSet       AS CHARACTER
    FIELD SuppAddr      AS CHARACTER
    FIELD DocNum        AS CHARACTER
    FIELD DocDate       AS CHARACTER
    FIELD SuppSert      AS CHARACTER
    FIELD Income        AS CHARACTER
    FIELD Sale          AS CHARACTER
    FIELD Outgo         AS CHARACTER
    FIELD OutgoTot      AS CHARACTER
    FIELD EndQnt        AS CHARACTER

    index pi is primary unique xl-line-id
.


/************************************************************************
   PROCEDURES

*************************************************************************/
PROCEDURE alcxl-init :
DEFINE INPUT PARAMETER p-foreign AS LOGICAL NO-UNDO.
DO
ON ERROR UNDO, RETURN ERROR
:
    ASSIGN
        v-alcxl-current-data-row = 0
    .
    run gbl/_tmpfile.p (
          INPUT "xd"
        , INPUT ".txt"
        , OUTPUT v-alcxl-data-file-name
    ).
    OUTPUT STREAM excel-line TO value( v-alcxl-data-file-name ).
    run gbl/_tmpfile.p (
          INPUT "xc"
        , INPUT ".txt"
        , OUTPUT v-alcxl-cell-file-name
    ).
    OUTPUT STREAM excel-cell TO value( v-alcxl-cell-file-name ).

    run alcxl-write-cell-data in this-procedure (
          input {&alcxl-valutCode}
        , input "1":U
    ).
    IF p-foreign THEN DO:
       RUN alcxl-write-cell-data IN THIS-PROCEDURE (
             INPUT {&alcxl-columnList}
           , INPUT "AlcName,AlcCode,AlcVal,Proff,RegCode,ProcName,ProcAddr,ImpName,ImpAddr,BeginQnt,SuppName,SuppINN,SuppSet,SuppAddr,DocNum,DocDate,SuppSert,Income,Sale,Outgo,OutgoTot,EndQnt":U
       ).
       RUN alcxl-write-cell-data IN THIS-PROCEDURE (
             INPUT {&alcxl-columnType}
           , INPUT "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
       ).
       RUN alcxl-write-cell-data IN THIS-PROCEDURE (
             INPUT {&alcxl-columnAmount}
           , INPUT "22":U
       ).
    END.
    ELSE DO:
       RUN alcxl-write-cell-data IN THIS-PROCEDURE (
             INPUT {&alcxl-columnList}
           , INPUT "AlcName,AlcCode,AlcVal,Proff,RegCode,ProcName,ProcINN,ProcAddr,BeginQnt,SuppName,SuppINN,SuppSet,SuppAddr,DocNum,DocDate,SuppSert,Income,Sale,Outgo,OutgoTot,EndQnt":U
       ).
       RUN alcxl-write-cell-data IN THIS-PROCEDURE (
             INPUT {&alcxl-columnType}
           , INPUT "S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S":U
       ).
       RUN alcxl-write-cell-data IN THIS-PROCEDURE (
             INPUT {&alcxl-columnAmount}
           , INPUT "21":U
       ).
    END.
    /*
    RUN alcxl-write-cell-data IN THIS-PROCEDURE (
          input {&alcxl-subtotalList}
        , input "BeginQnt,Income,Sale,Outgo,OutgoTot,EndQnt":U
    ).
    RUN alcxl-write-cell-data IN THIS-PROCEDURE (
          INPUT {&alcxl-subtotalType}
        , INPUT "S,S,S,S,S,S":U
    ).
    RUN alcxl-write-cell-data IN THIS-PROCEDURE (
          INPUT {&alcxl-subtotalAmount}
        , INPUT "6":U
    ).
    */

END.
END PROCEDURE. /* alcxl-init */



PROCEDURE alcxl-close :
DEFINE INPUT PARAMETER p-foreign AS LOGICAL NO-UNDO.
DO
ON ERROR UNDO, RETURN ERROR
:
    OUTPUT STREAM excel-line CLOSE.
    OUTPUT STREAM excel-cell CLOSE.
    IF p-foreign THEN DO:
    OUTPUT TO value( STRING( SESSION:temp-directory + "rpt" + STRING( g#report-num ) ) + ".txl" ) /*!!! APPEND*/ .
        EXPORT "exe/r-alcms2.xlt":U.
        EXPORT "exe/t_97.bas":U.
        EXPORT v-alcxl-cell-file-name.
        EXPORT v-alcxl-data-file-name.
    END.
    ELSE DO:
    OUTPUT TO value( STRING( SESSION:temp-directory + "rpt" + STRING( g#report-num ) ) + ".txl" ) /*!!! APPEND*/ .
        EXPORT "exe/r-alcmos.xlt":U.
        EXPORT "exe/t_97.bas":U.
        EXPORT v-alcxl-cell-file-name.
        EXPORT v-alcxl-data-file-name.
    END.
    OUTPUT CLOSE.
END.
END PROCEDURE. /* alcxl-close */



PROCEDURE alcxl-write-cell-data :
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
end procedure. /* alcxl-write-cell-data */



PROCEDURE alcxl-write-line-data :
DEFINE INPUT PARAMETER p-foreign  AS LOGICAL NO-UNDO.
DEFINE INPUT PARAMETER p-AlcName  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-AlcCode  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-AlcVal   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-Proff    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-RegCode  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ProcName AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ProcINN  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ProcAddr AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ImpName  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-ImpAddr  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-BeginQnt AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-SuppName AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-SuppINN  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-SuppSet  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-SuppAddr AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-DocNum   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-DocDate  AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-SuppSert AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-Income   AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-Sale     AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-Outgo    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-OutgoTot AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-EndQnt   AS CHARACTER NO-UNDO.

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
        v-alcxl-current-data-row = v-alcxl-current-data-row + 1
    .
    assign
        buf_temp_line-data.data-key   = {&alcxl-line-data-key}
        buf_temp_line-data.xl-line-id = v-alcxl-current-data-row
        buf_temp_line-data.AlcName    = p-AlcName
        buf_temp_line-data.AlcCode    = p-AlcCode
        buf_temp_line-data.AlcVal     = p-AlcVal
        buf_temp_line-data.Proff      = p-Proff
        buf_temp_line-data.RegCode    = p-RegCode
        buf_temp_line-data.ProcName   = p-ProcName
        buf_temp_line-data.ProcINN    = p-ProcINN
        buf_temp_line-data.ProcAddr   = p-ProcAddr
        buf_temp_line-data.BeginQnt   = p-BeginQnt
        buf_temp_line-data.SuppName   = p-SuppName
        buf_temp_line-data.SuppINN    = p-SuppINN
        buf_temp_line-data.SuppSet    = p-SuppSet
        buf_temp_line-data.SuppAddr   = p-SuppAddr
        buf_temp_line-data.DocNum     = p-DocNum
        buf_temp_line-data.DocDate    = p-DocDate
        buf_temp_line-data.SuppSert   = p-SuppSert
        buf_temp_line-data.Income     = p-Income
        buf_temp_line-data.Sale       = p-Sale
        buf_temp_line-data.Outgo      = p-Outgo
        buf_temp_line-data.OutgoTot   = p-OutgoTot
        buf_temp_line-data.EndQnt     = p-EndQnt
    .

    IF p-foreign THEN DO:
    PUT STREAM excel-line UNFORMATTED
                        buf_temp_line-data.data-key
        {&tabulation}   p-AlcName
        {&tabulation}   p-AlcCode
        {&tabulation}   p-AlcVal
        {&tabulation}   p-Proff
        {&tabulation}   p-RegCode
        {&tabulation}   p-ProcName
        {&tabulation}   p-ProcAddr
        {&tabulation}   p-ImpName
        {&tabulation}   p-ImpAddr
        {&tabulation}   p-BeginQnt
        {&tabulation}   p-SuppName
        {&tabulation}   p-SuppINN
        {&tabulation}   p-SuppSet
        {&tabulation}   p-SuppAddr
        {&tabulation}   p-DocNum
        {&tabulation}   p-DocDate
        {&tabulation}   p-SuppSert
        {&tabulation}   p-Income
        {&tabulation}   p-Sale
        {&tabulation}   p-Outgo
        {&tabulation}   p-OutgoTot
        {&tabulation}   p-EndQnt
        {&new-line}
    .
    END.
    ELSE DO:
    PUT STREAM excel-line UNFORMATTED
                        buf_temp_line-data.data-key
        {&tabulation}   p-AlcName
        {&tabulation}   p-AlcCode
        {&tabulation}   p-AlcVal
        {&tabulation}   p-Proff
        {&tabulation}   p-RegCode
        {&tabulation}   p-ProcName
        {&tabulation}   p-ProcINN
        {&tabulation}   p-ProcAddr
        {&tabulation}   p-BeginQnt
        {&tabulation}   p-SuppName
        {&tabulation}   p-SuppINN
        {&tabulation}   p-SuppSet
        {&tabulation}   p-SuppAddr
        {&tabulation}   p-DocNum
        {&tabulation}   p-DocDate
        {&tabulation}   p-SuppSert
        {&tabulation}   p-Income
        {&tabulation}   p-Sale
        {&tabulation}   p-Outgo
        {&tabulation}   p-OutgoTot
        {&tabulation}   p-EndQnt
        {&new-line}
    .
    END.
END.
END PROCEDURE. /* alcxl-write-line-data */



PROCEDURE alcxl-run-excel :
DEFINE INPUT PARAMETER p-header-filename    AS CHARACTER        NO-UNDO.
DEFINE INPUT PARAMETER p-data-filename      AS CHARACTER        NO-UNDO.
DEFINE INPUT PARAMETER p-foreign            AS LOGICAL          NO-UNDO.

DEFINE VARIABLE v-template-file-name    AS CHARACTER    NO-UNDO.
DEFINE VARIABLE v-vb-file-name          AS CHARACTER    NO-UNDO.

DEFINE BUFFER buf_temp-param FOR temp-param .
DO
FOR buf_temp-param
ON ERROR UNDO, RETURN ERROR
:
    CREATE buf_temp-param.
    IF p-foreign THEN DO:
    ASSIGN
        v-template-file-name    = SEARCH( "exe/r-alcms2.xlt" )
        v-vb-file-name          = SEARCH( "exe/t_97.bas")
    .
    END.
    ELSE DO:
    ASSIGN
        v-template-file-name    = SEARCH( "exe/r-alcmos.xlt" )
        v-vb-file-name          = SEARCH( "exe/t_97.bas")
    .
    END.
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
END PROCEDURE. /* alcxl-run-excel */



/* $Workfile$ e n d */