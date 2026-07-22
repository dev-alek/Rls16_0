/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изображения.
Некоторые общие вещи

Автор: Топорец Александр
Дата создаения: 12/29/14
Author: Toporets Alexander
Creation date: 12/29/14

*/

&IF DEFINED(ImageDelimiter) = 0 &THEN
&GLOBAL-DEFINE ImageDelimiter ",":U
&ENDIF
&IF DEFINED(Slash) = 0 &THEN
&GLOBAL-DEFINE Slash \
&ENDIF
&IF DEFINED(PostD) = 0 &THEN
&GLOBAL-DEFINE PostD #
&ENDIF

DEFINE VARIABLE mImagePath     AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageDir      AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImagePreDir   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageTrash    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPhotomgd      AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mImagePh       AS LOGICAL     NO-UNDO.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.

PROCEDURE imagelist_loaddef:
    /* Установить основные константы */
    DEFINE VARIABLE vPar-val       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vPar-type      AS CHARACTER   NO-UNDO.

    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
	/* Режим картинок для товаров */
	{gbl/conf-rd.i "'photo':u"  "'':u" "'':u" 0 "'':u" "'':u" "'':u" no vPar-val vPar-type no-error}
	mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
    IF mImagePh THEN .
    ELSE RETURN.
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
	/* Путь к папке изображений */
	{gbl/conf-rd.i "'ph-dir':u" "'':u" "'':u" 0 "'':u" "'':u" "'':u" NO vPar-val vPar-type no-error}
    
	/* !!!!! */ 
    IF LENGTH (vPar-val) = 0 THEN
        RUN verify-ini-entry("ph-dir":U, "REP-SETS":U, "":U, YES, OUTPUT vPar-val) NO-ERROR.
    IF LENGTH (vPar-val) = 0 THEN vPar-val = "c:\temp\":U.
	/* !!!!! */
    
    ASSIGN
        mImagePath   = RIGHT-TRIM (vPar-val, "~\~/":U)
        mImagePath   = mImagePath + (IF LENGTH (mImagePath) > 0 THEN "{&Slash}":U ELSE "":U)
        mImagePreDir = mImagePath
        mImageDir    = mImagePreDir
        mImageTrash  = mImagePath + "trash{&Slash}":U
        .
    
    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
	/* Режим отдельных поддиректорий для каждого товара */
	    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_shema-foto} /*p-param-code*/
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
	/* {gbl/conf-rd.i "'photomgd':u"  "'':u" "'':u" 0 "'':u" "'':u" "'':u" no vPar-val vPar-type no-error}  */
	mPhotomgd = IF v-val-integer = 2 then yes else no.
    
END PROCEDURE.

PROCEDURE imagelist_decode:
    /* Развертывание списка */
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE INPUT  PARAMETER iImageGdsCode AS int    NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        .
   
    DO vInt = 1 TO NUM-ENTRIES (iImageList, {&ImageDelimiter}):
        vCh =ENTRY (vInt, iImageList, {&ImageDelimiter}).
        IF SUBSTRING (vCh, 1, 2) = "~\~\":U THEN .
        ELSE 
        DO:
            ASSIGN
                vCh = REPLACE (vCh, "~/":U, "{&Slash}":U)
                vCh = REPLACE (vCh, "~\":U, "{&Slash}":U)
                .
            IF SUBSTRING (vCh, 2, 2) = ":{&Slash}":U OR vCh BEGINS mImageDir THEN .
            ELSE vCh = mImagePreDir + (if mPhotomgd then string(iImageGdsCode) + "{&Slash}":U else '':U ) +  vCh.
            ENTRY (vInt, oImageList, {&ImageDelimiter}) = vCh.
        END.
    END.
END PROCEDURE.

PROCEDURE imagelist_encode:
    /* Свертывание списка */
    DEFINE INPUT  PARAMETER iImageList AS LONGCHAR  NO-UNDO.
    DEFINE OUTPUT PARAMETER oImageList AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt               AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vLen               AS INTEGER   NO-UNDO.
    ASSIGN
        oImageList = iImageList
        vLen       = LENGTH (mImageDir)
        .
    DO vInt = 1 TO NUM-ENTRIES (iImageList, {&ImageDelimiter}):
        vCh =ENTRY (vInt, iImageList, {&ImageDelimiter}).
        IF LENGTH (vCh) > 0 AND vLen > 0 AND vCh BEGINS mImageDir THEN 
            ENTRY (vInt, oImageList, {&ImageDelimiter}) = 
                SUBSTRING (vCh, vLen + 1).
    END.
END PROCEDURE.