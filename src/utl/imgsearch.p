block-level on error undo, throw.
/*
$Revision: 575d20d95ec1, 311, rls $
$Author: EShklyar $
$Date: Tue Dec 01 19:12:40 2015 +0300 $
$Workfile: imgsearch.p $
$Archive: utl/imgsearch.p $

Поиск изображений, которые не привязанны к товару (по товарам)

Автор: Шкляр Елена
Дата создания: 05/09/15
Author: Elena Shklyar
Creation date: 05/09/15
Last change: 05/09/15
*/

DEFINE INPUT PARAMETER parParentProc AS HANDLE NO-UNDO.


/*DEFINE VARIABLE mOldDir       AS CHARACTER*/
/*    FORMAT "X(256)":U                     */
/*    VIEW-AS FILL-IN SIZE 75 BY 1          */
/*    LABEL "Исходная директория" NO-UNDO.  */

define variable vss-revision    as character no-undo init "$Revision: 575d20d95ec1, 311, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:12:40 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imgsearch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imgsearch.p $":U .
define variable vss-description as character no-undo init "Поиск изображений, которые не привязанны к товару".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
/*{ gbl/getcntxt.i get }*/
{ ref/gds-attr.i }
{ cmp/ini-lib.i }

DEFINE VARIABLE mLogical       AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mLogFile       AS CHARACTER   NO-UNDO.
DEFINE STREAM mLogStr.
DEFINE STREAM mDirStr.
DEFINE STREAM mPrevDirStr.
DEFINE STREAM mGdsDirStr.
DEFINE VARIABLE mF_select_photo AS LOGICAL     NO-UNDO.
DEFINE VARIABLE vPhotoPath       AS CHARACTER   NO-UNDO.


{ref/imagelist.i}
IF mImagePh THEN .
    ELSE RETURN.

/*IF mPhotomgd THEN                                                      */
/*    mImageDir = SUBSTITUTE ("&1&2{&Slash}":U, mImagePreDir, iGds-code).*/


mPhotomgd = IF v-val-integer = 2 then yes else no.
if mPhotomgd = yes then do:
    vPhotoPath =  mImagePreDir .
RUN ProcDir IN THIS-PROCEDURE (vPhotoPath).

/*vPhotoPath =  mImagePreDir + string(iImageGdsCode) + "\":U .*/

end.    

/* PROCEDURES */
PROCEDURE ProcDir PRIVATE:
    /* Обработка директории */
    DEFINE INPUT PARAMETER iDir      AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vSubDirList      AS LONGCHAR   NO-UNDO.
    DEFINE VARIABLE vShortFName      AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vFullFName       AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vFileAttr        AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vGdsShortFName   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vGdsFullFName    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vGdsFileAttr     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vPrevShortFName  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vPrevFullFName   AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vPrevFileAttr    AS CHARACTER  NO-UNDO.    
/*Идем по директории gds*/
    INPUT STREAM mDirStr FROM OS-DIR (iDir).
    FileBlock:
    REPEAT:
        IMPORT STREAM mDirStr vShortFName vFullFName vFileAttr.
        IF vShortFName = ".":U OR vShortFName = "..":U THEN NEXT FileBLock.
        IF INDEX (vFileAttr, "D":U) > 0 THEN
        DO:
    /*Есть ли товар с таким бар-кодом*/
          FIND FIRST bar-code NO-LOCK WHERE bar-code.b-code = INTEGER(vShortFName) no-error.
          IF AVAILABLE bar-code THEN DO:
            FIND FIRST goods    NO-LOCK WHERE goods.gds-code  = bar-code.gds-code NO-ERROR.
            INPUT STREAM mPrevDirStr FROM OS-DIR (vFullFName).
            FileBlock1:
            REPEAT:
                IMPORT STREAM mPrevDirStr vPrevShortFName vPrevFullFName vPrevFileAttr.
                IF vPrevShortFName = ".":U OR vPrevShortFName = "..":U OR vPrevShortFName = "Thumbs.db":U THEN NEXT FileBLock1.
                IF INDEX (vPrevFileAttr, "D":U) > 0 and vPrevShortFName begins "PREV" THEN
                DO:
                    INPUT STREAM mGdsDirStr FROM OS-DIR (vPrevFullFName).
                    FileBlock2:
                    REPEAT:
                        IMPORT STREAM mGdsDirStr vGdsShortFName vGdsFullFName vGdsFileAttr.
                        IF vGdsShortFName = ".":U OR vGdsShortFName = "..":U OR vGdsShortFName = "Thumbs.db":U THEN NEXT FileBLock2.
                    IF INDEX (vGdsFileAttr, "F":U) > 0  THEN
                    vGdsShortFName = vPrevShortFName + "\" + vGdsShortFName.
                        RUN ProcFile (vShortFName, yes, vGdsShortFName).
                    END.
                    INPUT STREAM mGdsDirStr CLOSE.
                END.
                    IF INDEX (vPrevFileAttr, "F":U) > 0  THEN
                        RUN ProcFile (vShortFName, no, vPrevShortFName).
                    END.
            END.
            INPUT STREAM mPrevDirStr CLOSE.
            END. 

        END.
    INPUT STREAM mDirStr CLOSE.
END PROCEDURE.


/* PROCEDURES */
PROCEDURE ProcFile PRIVATE:
    /* Обработка директории */
    DEFINE INPUT PARAMETER v-bar-code      AS CHARACTER  NO-UNDO.
    DEFINE INPUT PARAMETER v-Prev          AS logical  NO-UNDO.
    DEFINE INPUT PARAMETER v-Path          AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vImageList             AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vFullFName             AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vType                  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE mImageList             AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vPrevFileAttr    AS CHARACTER  NO-UNDO.
/*Идем по директории gds*/
        FOR FIRST bar-code NO-LOCK WHERE bar-code.b-code = integer(v-bar-code),
            FIRST goods    NO-LOCK WHERE goods.gds-code  = bar-code.gds-code:
         RUN gds-attr-value (goods.gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vType).
         if v-Path <> "" or v-Path <> "Thumbs.db" then do:
             if v-Prev = yes then do:
                 IF LOOKUP (v-Path, vImageList) = 0  THEN do:
                 if vImageList = "" then mImageList = v-Path.
                 else mImageList = v-Path + "," + vImageList .
                   RUN gds-attr-write (goods.gds-code, "image-list":U, mImageList).
                 END.
             end.
             else do:
                 IF LOOKUP (v-Path, vImageList) = 0  THEN do:
                    if vImageList = "" then mImageList = v-Path.
                    else mImageList = vImageList + "," + v-Path.
                   RUN gds-attr-write (goods.gds-code, "image-list":U, mImageList).
                 end. 
             end.    
           end. 
          end. 
END PROCEDURE.
