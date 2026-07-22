block-level on error undo, throw.
/*
$Revision: 6f05299baa1a, 320, rls $
$Author: EShklyar $
$Date: Wed Dec 02 16:59:31 2015 +0300 $
$Workfile: image2lst.p $
$Archive: utl/image2lst.p $

Перенос изображений в структуру со списком изображений

Автор: Топорец Александр
Дата создания: 01/02/15
Author: Alexander Toporets
Creation date: 01/02/15
Last change: 01/02/15
*/

DEFINE INPUT PARAMETER parParentProc AS HANDLE NO-UNDO.

DEFINE VARIABLE mOldDir       AS CHARACTER 
    FORMAT "X(256)":U 
    VIEW-AS FILL-IN SIZE 75 BY 1 
    LABEL "Исходная директория" NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: 6f05299baa1a, 320, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 02 16:59:31 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: image2lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/image2lst.p $":U .
define variable vss-description as character no-undo init "Перенос изображений в структуру со списком изображений".

{ cmp/vssrevis.i }
{ cmp/showinf.i  }


{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/gds-attr.i }
{ cmp/ini-lib.i }

DEFINE VARIABLE mLogical       AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mLogFile       AS CHARACTER   NO-UNDO.
DEFINE STREAM mLogStr.
DEFINE STREAM mDirStr.

DEFINE VARIABLE mF_select_photo AS LOGICAL     NO-UNDO.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference_update_photo':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  mF_select_photo
}
IF NOT mF_select_photo THEN RETURN.
DEFINE VARIABLE mF_update_photo AS LOGICAL     NO-UNDO.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference_update_photo':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  mF_update_photo
}

{ref/imagelist.i}
IF mImagePh THEN .
    ELSE RETURN.

/*IF mPhotomgd THEN                                                      */
/*    mImageDir = SUBSTITUTE ("&1&2{&Slash}":U, mImagePreDir, iGds-code).*/

RUN verify-file (mImagePath,
    "Не найден каталог " + mImagePath + {&new-line} +
    "параметр конфигурации ph-dir",
    NO, OUTPUT mLogical) NO-ERROR.
IF ERROR-STATUS:ERROR OR NOT mLogical THEN RETURN ERROR.

/* MAIN */
/*UPDATE mOldDir WITH VIEW-AS DIALOG-BOX.*/
SYSTEM-DIALOG GET-DIR mOldDir
    INITIAL-DIR  mOldDir
    TITLE "Исходная директория"
    .

IF mOldDir > "":U THEN .
ELSE RETURN.
mLogFile = SUBSTITUTE ("&1&2.txt":U, SESSION:TEMP-DIRECTORY, GUID).
OUTPUT STREAM mLogStr TO VALUE (mLogFile).
RUN ProcDir IN THIS-PROCEDURE (mOldDir).
OUTPUT STREAM mLogStr CLOSE. 
OS-COMMAND NO-WAIT VALUE (
    SUBSTITUTE ("notepad ~"&1~"":U, mLogFile)).

/* FUNCTIONS */
FUNCTION DeBase RETURNS INTEGER PRIVATE 
    (iString AS CHARACTER , iBase AS INTEGER):
    DEFINE VARIABLE vPos  AS INTEGER    NO-UNDO.
    DEFINE VARIABLE vRes  AS INTEGER    NO-UNDO.
    DEFINE VARIABLE vMul  AS INTEGER    NO-UNDO.
    DEFINE VARIABLE vCode AS INTEGER    NO-UNDO.
    IF iString = ? THEN RETURN ?.
    IF iBase >= 2 AND iBase <= 36 THEN .
    ELSE RETURN ?.
    iString = TRIM (iString).
    IF LENGTH (iString) = 0 THEN RETURN 0.
    vMul = 1.
    DO vPos = LENGTH (iString) TO 1 BY -1:
        vCode = ASC (SUBSTRING (iString, vPos, 1)).
        IF vCode < 48 OR vCode > 90 THEN RETURN ?.
        vRes = vRes + vMul * (vCode - IF vCode <= 57 THEN 48 ELSE 55). 
        IF vPos > 1 THEN vMul = vMul * iBase.
    END.
    RETURN vRes.
END FUNCTION.

/* PROCEDURES */
PROCEDURE ProcDir PRIVATE:
    /* Обработка директории */
    DEFINE INPUT PARAMETER iDir AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vSubDirList AS LONGCHAR   NO-UNDO.
    DEFINE VARIABLE vCounter    AS INTEGER    NO-UNDO.
    DEFINE VARIABLE vShortFName AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vFullFName  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vFileAttr   AS CHARACTER  NO-UNDO.
    INPUT STREAM mDirStr FROM OS-DIR (iDir).
    FileBlock:
    REPEAT:
        IMPORT STREAM mDirStr vShortFName vFullFName vFileAttr.
        IF vShortFName = ".":U OR vShortFName = "..":U THEN NEXT FileBLock.
        IF INDEX (vFileAttr, "D":U) > 0 THEN
        DO:
            vSubDirList = vSubDirList + "~n":U + vFullFName.
            NEXT FileBLock.
        END.
        RUN ProcFile (vShortFName, vFullFName). 
    END.
    vSubDirList = TRIM (vSubDirList, "~n":U).
    IF LENGTH (vSubDirList) > 0 THEN
    DO vCounter = 1 TO NUM-ENTRIES (vSubDirList, "~n":U):
        RUN ProcDir (ENTRY (vCounter, vSubDirList, "~n":U)).
    END.
END PROCEDURE.

PROCEDURE ProcFile PRIVATE:
    /* Обработка файла */
    DEFINE INPUT PARAMETER iShortFName AS CHARACTER  NO-UNDO.
    DEFINE INPUT PARAMETER iFullFName  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vBarID             AS INTEGER    NO-UNDO INITIAL ?.
    DEFINE VARIABLE vGdsID             AS INTEGER    NO-UNDO INITIAL ?.
    DEFINE VARIABLE vGdsName           AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vLogFormat         AS CHARACTER  NO-UNDO
    	INITIAL "&1~t&2~t&3~t&4~t&5~t&6~t&7":U.
    DEFINE VARIABLE vNewFName          AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE mImageList         AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vCh                AS CHARACTER  NO-UNDO.
    DEFINE BUFFER bar-code FOR bar-code.
    DEFINE BUFFER goods    FOR goods.    
    vBarID = DeBase ( ENTRY (1, iShortFName, ".":U), 16).
    IF vBarID <> ? THEN
    DO:
        FOR FIRST bar-code NO-LOCK WHERE bar-code.b-code = vBarID,
            FIRST goods    NO-LOCK WHERE goods.gds-code  = bar-code.gds-code:
            ASSIGN
                vGdsID    = goods.gds-code
                vGdsName  = goods.gds-name.
            IF mPhotomgd THEN
                mImageDir = SUBSTITUTE ("&1&2{&Slash}":U, mImagePreDir, vGdsID).
            ASSIGN
                vNewFName = mImageDir + STRING (vGdsID) + 
                    SUBSTRING (iShortFName, INDEX (iShortFName, ".":U))
                .
            IF LENGTH (SEARCH (vNewFName)) > 0 THEN
            DO:
                PUT STREAM mLogStr UNFORMATTED 
                    SUBSTITUTE (vLogFormat, NOW, "ERROR2":U,
                    iFullFName, vNewFName, vGdsID, vGdsName, 
                    "Файл уже существует.") SKIP.            
            END.            
            RUN verify-file (mImagePreDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
            IF ERROR-STATUS:ERROR OR NOT mLogical THEN
            DO:
                OS-CREATE-DIR VALUE (mImagePreDir).
                IF OS-ERROR <> 0 THEN
                DO:
                    PUT STREAM mLogStr UNFORMATTED 
                        SUBSTITUTE (vLogFormat, NOW, "ERROR3":U,
                        iFullFName, vNewFName, vGdsID, vGdsName, 
                        SUBSTITUTE ("Ошибка &1 создания поддиректории &2",
                                        OS-ERROR, mImagePreDir)) SKIP.
                    RETURN.
                END.
            END.

            RUN verify-file (mImageDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
            IF ERROR-STATUS:ERROR OR NOT mLogical THEN
            DO:
                OS-CREATE-DIR VALUE (mImageDir).
                IF OS-ERROR <> 0 THEN
                DO:
                    PUT STREAM mLogStr UNFORMATTED 
                        SUBSTITUTE (vLogFormat, NOW, "ERROR4":U,
                        iFullFName, vNewFName, vGdsID, vGdsName, 
                        SUBSTITUTE ("Ошибка &1 создания поддиректории &2",
                                        OS-ERROR, mImageDir)) SKIP.
                    RETURN.
                END.
            END.
            
            OS-COPY VALUE (iFullFName) VALUE (vNewFName).
            IF OS-ERROR <> 0 THEN
            DO:
                PUT STREAM mLogStr UNFORMATTED 
                    SUBSTITUTE (vLogFormat, NOW, "ERROR5":U,
                        iFullFName, vNewFName, vGdsID, vGdsName, 
                        SUBSTITUTE ("Ошибка &1 копирования файла &2 в &3",
                                    OS-ERROR, iFullFName, vNewFName)) SKIP.
                RETURN.
            END.
        
            RUN gds-attr-value (vGdsID, "image-list":U, OUTPUT mImageList, OUTPUT vCh).
            RUN imagelist_decode IN THIS-PROCEDURE (INPUT mImageList,vGdsID, OUTPUT mImageList).
            mImageList = (IF LENGTH (mImageList) > 0 THEN mImageList + {&ImageDelimiter} 
                ELSE "":U) + vNewFName.
            RUN imagelist_encode IN THIS-PROCEDURE (INPUT mImageList, OUTPUT mImageList).
            RUN gds-attr-write (vGdsID, "image-list":U, mImageList). 
            PUT STREAM mLogStr UNFORMATTED SUBSTITUTE (vLogFormat, NOW, "OK":U,
                iFullFName, vNewFName, vGdsID, vGdsName) SKIP.
            RETURN.
        END.
    END.
        PUT STREAM mLogStr UNFORMATTED SUBSTITUTE (vLogFormat, NOW, "ERROR1":U,
            iFullFName, vBarID, vGdsID,            "Не найден товар") SKIP.
        RETURN.      
END PROCEDURE.