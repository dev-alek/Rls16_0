&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-images
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-images 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изображения
Количество изображений автоматически ограничено количеством пиктограмм, 
которое может поместиться во фрейме. За счет увеличения ширины фрейма 
можно увеличить (пока ширины экрана хватает).
Количество изображений также ограничено максимальным размером записи БД.

Автор: Топорец Александр
Дата создания: 12/29/14
Author: Toporets Alexander
Creation date: 12/29/14

*/

&IF DEFINED (UIB_IS_RUNNING) &THEN
    DEFINE VARIABLE         parParentProc AS WIDGET-HANDLE NO-UNDO.
    DEFINE VARIABLE         bttns         AS CHARACTER     NO-UNDO.
    DEFINE VARIABLE         iGds-code     AS INTEGER       NO-UNDO.
    define variable         loc-mode      as character     no-undo .
    FOR LAST goods NO-LOCK:
       iGds-code = goods.gds-code.
    END.
    bttns = "b-add":U.
    DISABLE TRIGGERS FOR LOAD OF goods-attr.
&ELSE
    DEFINE INPUT  PARAMETER parParentProc AS WIDGET-HANDLE NO-UNDO.
    DEFINE INPUT  PARAMETER bttns         AS CHARACTER     NO-UNDO.
    DEFINE INPUT  PARAMETER iGds-code     AS INTEGER       NO-UNDO. /* список recid'ов выбранных записей */
    define INPUT  PARAMETER loc-mode      as character     no-undo .
    
    DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision$":U .
    DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author$":U .
    DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date$":U .
    DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile$":U .
    DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive$":U .
    DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "Изображения".
    { cmp/vssrevis.i }
    { cmp/showinf.i  }

&ENDIF

&SCOPED-DEFINE ImgIcoSize 32
&SCOPED-DEFINE ImgBoxSize 34
&SCOPED-DEFINE ImgSpace 3
&SCOPED-DEFINE MaxRecordSize 30000
&SCOPED-DEFINE ImgFilters FILTERS ~
        "Картинки" "*.jpg,*.png,*.bmp,*.gif":U, ~
        "Картинки *.jpg" "*.jpg":U, ~
        "Картинки *.png" "*.png":U, ~
        "Картинки *.bmp" "*.bmp":U, ~
        "Картинки *.gif" "*.gif":U, ~
        "Все файлы" "*.*":U

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/gds-attr.i }
{ cmp/ini-lib.i }

DEFINE TEMP-TABLE ttImgBar NO-UNDO
    FIELD fID    AS CHARACTER
    FIELD fFrame AS HANDLE
    FIELD fImage AS HANDLE
    FIELD fXPix  AS INTEGER
    FIELD fTrgs  AS HANDLE
    FIELD fFile  AS CHARACTER
    FIELD fNum   AS INTEGER
    INDEX i1 fXPix
    INDEX i2 fID
    INDEX i3 fNum
    .

/* mBoxForAdd - пустая иконка для добавления по двойному клику 
-1 - никогда; 0 - если нет картинок; 8 - всегда
*/
DEFINE VARIABLE mBoxForAdd     AS INTEGER     NO-UNDO INITIAL 0.
DEFINE VARIABLE mImageSID      AS INTEGER     NO-UNDO.
DEFINE VARIABLE mImageMax      AS INTEGER     NO-UNDO.
DEFINE VARIABLE mImgBarFrame   AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImgBarLib     AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImgSlider     AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImgSliderTrgs AS HANDLE      NO-UNDO.
DEFINE VARIABLE mImageCurID    AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mImageCurNum   AS INTEGER     NO-UNDO.
DEFINE VARIABLE mImageList     AS LONGCHAR    NO-UNDO.
DEFINE VARIABLE mLogical       AS LOGICAL     NO-UNDO.
DEFINE VARIABLE mEnab          AS LOGICAL     NO-UNDO.

/*ASSIGN*/
    if loc-mode <> {&lookup} then 
/*    mEnab = LOOKUP ( "b-add":U, bttns) > 0*/
    mEnab = yes.
    else mEnab = no.
    .

/*DEFINE VARIABLE mPar-val       AS CHARACTER   NO-UNDO.
DEFINE VARIABLE mPar-type      AS CHARACTER   NO-UNDO.*/

&IF DEFINED (UIB_IS_RUNNING) = 0 &THEN
if loc-mode = {&lookup} then do:
DEFINE VARIABLE mF_select_photo AS LOGICAL     NO-UNDO.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference_select_photo':U
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
end.
else do:
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
end.
&ENDIF

{ref/imagelist.i}
IF mImagePh THEN .
    ELSE RETURN.

IF mPhotomgd THEN 
    mImageDir = SUBSTITUTE ("&1&2{&Slash}":U, mImagePreDir, iGds-code).

RUN verify-file (mImagePath,
    "Не найден каталог " + mImagePath + {&new-line} +
    "параметр конфигурации ph-dir",
    NO, OUTPUT mLogical) NO-ERROR.
IF ERROR-STATUS:ERROR OR NOT mLogical THEN RETURN ERROR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-images

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-add b-del CurrentImage RECT-2 ~
f-Marker t-preview F-FileName 
&Scoped-Define DISPLAYED-OBJECTS t-preview F-FileName 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ImgXPix d-images 
FUNCTION ImgXPix RETURNS INTEGER
  (iNum AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 9 BY 1.

DEFINE BUTTON b-del 
     LABEL "&Удалить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 12 BY 1.

DEFINE VARIABLE F-FileName AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 63.5 BY 1 NO-UNDO.

DEFINE IMAGE CurrentImage
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 62.5 BY 15.5.

DEFINE RECTANGLE f-Marker
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 4.25 BY .13.

/*DEFINE RECTANGLE RECT-2                 */
/*     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL*/
/*     SIZE 63.5 BY 16.                   */

DEFINE VARIABLE t-preview AS LOGICAL INITIAL no 
     LABEL "Preview" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.5 BY .58 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-images
     b-exit AT ROW 1 COL 1
     b-add AT ROW 1 COL 13
     b-del AT ROW 1 COL 22.13
     t-preview AT ROW 20.25 COL 52.5 WIDGET-ID 20
     F-FileName AT ROW 21 COL 1 NO-LABEL WIDGET-ID 12
     CurrentImage AT ROW 5.25 COL 1.5 WIDGET-ID 2
/*     RECT-2 AT ROW 5 COL 1 WIDGET-ID 14*/
     f-Marker AT ROW 2.08 COL 1.13 WIDGET-ID 16
     SPACE(59.86) SKIP(19.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Изображения":L.

DEFINE FRAME FrameX
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 2.25
         SIZE 5 BY .75 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* REPARENT FRAME */
ASSIGN FRAME FrameX:FRAME = FRAME d-images:HANDLE.

/* SETTINGS FOR DIALOG-BOX d-images
   FRAME-NAME                                                           */
ASSIGN 
       FRAME d-images:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN F-FileName IN FRAME d-images
   ALIGN-L                                                              */
ASSIGN 
       F-FileName:READ-ONLY IN FRAME d-images        = TRUE.

/* SETTINGS FOR FRAME FrameX
                                                                        */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-images
/* Query rebuild information for DIALOG-BOX d-images
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-images */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-images
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-images d-images
ON CURSOR-LEFT OF FRAME d-images /* Изображения */
ANYWHERE DO:
    mImgSlider:SCREEN-VALUE = STRING (INTEGER (mImgSlider:SCREEN-VALUE) - 1) NO-ERROR.
    APPLY "VALUE-CHANGED":U TO mImgSlider.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-images d-images
ON CURSOR-RIGHT OF FRAME d-images /* Изображения */
ANYWHERE DO:
    mImgSlider:SCREEN-VALUE = STRING (INTEGER (mImgSlider:SCREEN-VALUE) + 1) NO-ERROR.
    APPLY "VALUE-CHANGED":U TO mImgSlider.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FrameX
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FrameX d-images
ON BACK-TAB OF FRAME FrameX
ANYWHERE DO:
  APPLY "ENTRY":U    TO SELF.
  APPLY "TAB":U      TO b-del IN FRAME {&FRAME-NAME}.
  APPLY "BACK-TAB":U TO FOCUS.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FrameX d-images
ON TAB OF FRAME FrameX
ANYWHERE DO:
  APPLY "ENTRY":U TO SELF.
  APPLY "TAB":U   TO b-del IN FRAME {&FRAME-NAME}.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-images
ON CHOOSE OF b-add IN FRAME d-images /* Добавить */
DO:
  &IF DEFINED (UIB_IS_RUNNING) = 0 &THEN
  IF NOT mF_update_photo THEN RETURN NO-APPLY.
  &ENDIF
  
  DEFINE VARIABLE vFile AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE vLog  AS LOGICAL     NO-UNDO.
  SYSTEM-DIALOG GET-FILE vFile
      {&ImgFilters}
      MUST-EXIST 
      TITLE "Выбор файла"
      /*USE-FILENAME*/
      UPDATE vLog 
      .
  IF NOT vLog THEN RETURN NO-APPLY.
  RUN ImageAdd IN THIS-PROCEDURE (vFile).
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-images
ON CHOOSE OF b-del IN FRAME d-images /* Удалить */
DO:
  &IF DEFINED (UIB_IS_RUNNING) = 0 &THEN
  IF NOT mF_update_photo THEN RETURN NO-APPLY.
  &ENDIF
  
  RUN ImageDel IN THIS-PROCEDURE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-preview
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-preview d-images
ON VALUE-CHANGED OF t-preview IN FRAME d-images /* Preview */
DO:
  DEFINE BUFFER ttImgBar FOR ttImgBar.

  IF SELF:CHECKED = NO THEN RETURN NO-APPLY.
  IF SELF:SENSITIVE THEN
  DO:
      MESSAGE 
          "Установить выбранное изображение в качестве используемого для предварительного просмотра?" SKIP (1)
          "(Изображение будет перемещено в начало списка)"
          VIEW-AS ALERT-BOX QUESTION BUTTONS OK-CANCEL TITLE "Вопрос" UPDATE vLog AS LOGICAL.
      IF vLog <> YES THEN
      DO:
          SELF:CHECKED = NO.
          RETURN NO-APPLY.
      END.
  END.

  FOR FIRST ttImgBar WHERE ttImgBar.fID = mImageCurID:
      ttImgBar.fFrame:X = 0.
      RUN DynaTrig IN THIS-PROCEDURE (ttImgBar.fFrame, "END-MOVE":U) NO-ERROR.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-images 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if mF_select_photo <> no or mF_update_photo <> no then do:
    RUN enable_ui.
    /*APPLY "VALUE-CHANGED":U TO {&browse-name} in frame {&frame-name}.*/
/*     ub.season.sea-name:RESIZABLE in  browse {&browse-name}   = true . */
/*     if num-entries (rid-list) = 0 then                                */
/*         hide mark-num in frame {&frame-name}.                         */
/*     else                                                              */
/*         disp                                                          */
/*         num-entries (rid-list) @ mark-num                             */
/*         with frame {&frame-name}.                                     */
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.
END.
DELETE PROCEDURE mImgSliderTrgs NO-ERROR.
FOR EACH ttImgBar:
    DELETE PROCEDURE ttImgBar.fTrgs NO-ERROR.
    DELETE OBJECT ttImgBar.fImage   NO-ERROR.
    DELETE OBJECT ttImgBar.fFrame   NO-ERROR.
    DELETE ttImgBar.
END.
RUN disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-images  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME d-images.
  HIDE FRAME FrameX.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DynaTrig d-images 
PROCEDURE DynaTrig :
/*------------------------------------------------------------------------------
  Purpose   : Динамический триггер    
  Parameters: Объект, Триггер
  Notes     :       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER iHandle  AS HANDLE    NO-UNDO.
    DEFINE INPUT PARAMETER iTrigger AS CHARACTER NO-UNDO.

    DEFINE VARIABLE vInt AS INTEGER NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    
    CASE iHandle:NAME:
        WHEN "ImgSlider":U THEN
            CASE iTrigger:
                WHEN "VALUE-CHANGED":U THEN
                    FOR FIRST ttImgBar NO-LOCK WHERE ttImgBar.fNum = INTEGER (iHandle:SCREEN-VALUE):
                        /*ttImgBar.fFrame:SELECTED = YES.*/
                        RUN DynaTrig IN THIS-PROCEDURE (ttImgBar.fFrame, "SELECTION":U) NO-ERROR.
                    END.
            END CASE.
        WHEN "Image":U THEN
            CASE iTrigger:
                WHEN "END-MOVE":U THEN
                DO:
                    FOR FIRST ttImgBar WHERE ttImgBar.fID = iHandle:PRIVATE-DATA:
                        ttImgBar.fXPix = iHandle:X.  
                    END.
                    ASSIGN
                        vInt       = mImageMax
                        mImageList = "":U
                        .
                    FOR EACH ttImgBar BY ttImgBar.fXPix DESCENDING:
                        ASSIGN
                            ttImgBar.fFrame:X = ImgXPix (vInt)
                            ttImgBar.fNum     = vInt
                            vInt              = vInt - 1
                            .
                    END.
                    FOR EACH ttImgBar:
                        ttImgBar.fXPix = ttImgBar.fFrame:X.
                    END.
                    ASSIGN
                        mImageCurID  = "":U
                        mImageCurNum = 0
                        .
                    RUN DynaTrig IN THIS-PROCEDURE (iHandle, "SELECTION":U) NO-ERROR.
                    RUN ImageListDump IN THIS-PROCEDURE.
                END.
                WHEN "SELECTION":U THEN
                    IF mImageCurID <> iHandle:PRIVATE-DATA THEN
                        RUN SelectImage IN THIS-PROCEDURE (?, iHandle:PRIVATE-DATA) NO-ERROR.
                WHEN "MOUSE-SELECT-DBLCLICK":U THEN
                DO:
                    IF mImageCurID <> iHandle:PRIVATE-DATA THEN
                        RUN SelectImage IN THIS-PROCEDURE (?, iHandle:PRIVATE-DATA) NO-ERROR.
                    IF f-FileName:SCREEN-VALUE IN FRAME {&FRAME-NAME} = "":U THEN
                        APPLY "CHOOSE":U TO b-add.
                    /*ELSE
                        APPLY "CHOOSE":U TO b-upd.*/
                    RETURN NO-APPLY.
                END.
            END CASE.
    END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-images 
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
    ENABLE
        b-exit
        b-add     WHEN loc-mode <> {&lookup}
        b-del     WHEN loc-mode <> {&lookup}
        f-marker
        t-preview WHEN loc-mode <> {&lookup}
        WITH FRAME  {&frame-name}.
    DISPLAY f-marker WITH FRAME {&frame-name}.
    RUN ImgBarInit IN THIS-PROCEDURE.
    
    RUN ImageListLoad IN THIS-PROCEDURE.
    RUN SensButtons   IN THIS-PROCEDURE.
    
    IF mBoxForAdd = 8 OR (mBoxForAdd = 0 AND mImageMax = 0) THEN
    RUN ImgBarAdd IN THIS-PROCEDURE ("":U).
    RUN ImgSlider IN THIS-PROCEDURE.
    RUN SelectImage IN THIS-PROCEDURE (1, ?) NO-ERROR.
 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImageAdd d-images 
PROCEDURE ImageAdd :
DEFINE INPUT PARAMETER iFile AS CHARACTER NO-UNDO.

    DEFINE BUFFER ttImgBar FOR ttImgBar.
    
    DEFINE VARIABLE vNum  AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vFile AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vTmp  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vInt  AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vCh2  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vExt  AS CHARACTER   NO-UNDO.

    RUN verify-file (mImagePreDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImagePreDir).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                                OS-ERROR, mImagePreDir)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    RUN verify-file (mImageDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImageDir).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                                OS-ERROR, mImageDir)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    
    IF iFile BEGINS mImageDir THEN vFile = iFile.
    ELSE
    DO:
        ASSIGN
            vTmp = SUBSTRING (iFile, 1 + 
                MAXIMUM (R-INDEX (iFile, "~\":U), R-INDEX (iFile, "~/":U)))
            vInt = R-INDEX (vTmp, ".":U)
            vExt = SUBSTRING (vTmp, vInt)
            vTmp = SUBSTRING (vTmp, 1, vInt - 1)
            vFile = mImageDir + vTmp + vExt
            .
        IF SEARCH (vFile) <> ? THEN
        bl0:
        DO:
            MESSAGE 
                "Файл с таким именем уже существует" SKIP
                vFile SKIP (1)
                "Сгенерировать новое имя файла и продолжить?"
                VIEW-AS ALERT-BOX WARNING BUTTONS OK-CANCEL 
                TITLE "Предупреждение" UPDATE mLogical.
            IF mLogical = NO THEN RETURN NO-APPLY.
            DO WHILE YES:
                bl1:
                DO:
                    vInt = R-INDEX (vTmp, "{&PostD}":U).
                    IF vInt > 0 THEN
                    DO:
                        vCh2 = SUBSTRING (vTmp, vInt + 1).
                        IF LENGTH (TRIM (vCh2, "0123456789":U)) = 0 THEN
                        DO:
                            ASSIGN
                                vTmp  = SUBSTRING (vTmp, 1, vInt) + 
                                    STRING (INTEGER (vCh2) + 1)
                                vFile = mImageDir + vTmp + vExt
                                .
                            LEAVE bl1.
                        END.
                    END.
                    ASSIGN
                        vTmp  = vTmp + "{&PostD}1":U
                        vFile = mImageDir + vTmp + vExt
                        .
                END.
                IF SEARCH (vFile) = ? THEN LEAVE bl0.
            END.
        END.
        OS-COPY VALUE (iFile) VALUE (vFile).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 копирования файла~n&2~n&3",
                                OS-ERROR, iFile, vFile)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.

    FOR LAST ttImgBar WHERE ttImgBar.fFile = "":U:
        ASSIGN
            vNum           = ttImgBar.fNum
            ttImgBar.fFile = vFile
            .
        ttImgBar.fImage:LOAD-IMAGE (vFile) NO-ERROR.
    END.
    IF vNum = 0 THEN 
    DO:
        RUN ImgBarAdd IN THIS-PROCEDURE (vFile).
        vNum = mImageMax.
    END.
    IF mBoxForAdd = 8 OR (mBoxForAdd = 0 AND mImageMax = 0) THEN
        RUN ImgBarAdd IN THIS-PROCEDURE ("":U).
    RUN ImgSlider IN THIS-PROCEDURE.
    RUN SelectImage IN THIS-PROCEDURE (vNum, ?).
    RUN ImageListDump IN THIS-PROCEDURE.
    RUN SensButtons IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImageDel d-images 
PROCEDURE ImageDel :
DEFINE VARIABLE vNum   AS INTEGER     NO-UNDO.
DEFINE VARIABLE vFile1 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE vFile2 AS CHARACTER   NO-UNDO.
DEFINE VARIABLE vExt   AS CHARACTER   NO-UNDO.
DEFINE VARIABLE vInt   AS INTEGER     NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.

    MESSAGE 
        "Удалить изображение?" SKIP
        VIEW-AS ALERT-BOX QUESTION BUTTONS OK-CANCEL 
        TITLE "Вопрос" UPDATE mLogical.
    IF mLogical = NO THEN RETURN NO-APPLY.

    RUN verify-file (mImageTrash, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImageTrash).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                                OS-ERROR, mImageTrash)
                VIEW-AS ALERT-BOX ERROR.
            RETURN NO-APPLY.
        END.
    END.
    
    ASSIGN
        vFile1 = F-FileName:SCREEN-VALUE IN FRAME {&FRAME-NAME}
        vFile2 = SUBSTRING (vFile1, 1 + 
                MAXIMUM (R-INDEX (vFile1, "~\":U), R-INDEX (vFile1, "~/":U)))
        vInt   = R-INDEX (vFile2, ".":U)
        vExt   = SUBSTRING (vFile2, vInt)
        vFile2 = SUBSTRING (vFile2, 1, vInt - 1)
        vFile2 = mImageTrash + vFile2 + " ":U + 
                REPLACE (STRING (NOW, "99999999 hh:mm:ss":U), ":":U, "":U) + vExt
        .
    OS-RENAME VALUE (vFile1) VALUE (vFile2).
    IF OS-ERROR <> 0 AND LENGTH (SEARCH (vFile1)) > 0 THEN
    DO:
        MESSAGE SUBSTITUTE ("Ошибка &1 перемещения файла~n&2~n&3",
                                OS-ERROR, vFile1, vFile2)
            VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.

    FOR FIRST ttImgBar WHERE ttImgBar.fID = mImageCurID:
        DELETE PROCEDURE ttImgBar.fTrgs NO-ERROR.
        DELETE OBJECT ttImgBar.fImage   NO-ERROR.
        DELETE OBJECT ttImgBar.fFrame   NO-ERROR.
        IF ttImgBar.fNum = mImageMax THEN vNum = mImageMax - 1.
        ELSE vNum = ttImgBar.fNum + 1.
        mImageMax = mImageMax - 1.
        DELETE ttImgBar.
    END.
    IF mImageMax = 0 THEN
    DO:
        IF mBoxForAdd = 8 OR (mBoxForAdd = 0 AND mImageMax = 0) THEN
        RUN ImgBarAdd IN THIS-PROCEDURE ("":U).
        vNum = mImageMax.
    END.
    RUN ImgSlider IN THIS-PROCEDURE.
    ASSIGN
        mImageCurID  = "":U
        mImageCurNum = 0
        .
    RUN SelectImage IN THIS-PROCEDURE (vNum, ?).
    FOR FIRST ttImgBar NO-LOCK WHERE ttImgBar.fNum = vNum:
        RUN DynaTrig IN THIS-PROCEDURE (ttImgBar.fFrame, "END-MOVE":U) NO-ERROR.
    END.
    IF mImageMax = 0 THEN
    DO:
        CurrentImage:LOAD-IMAGE ("":U) IN FRAME {&FRAME-NAME} NO-ERROR.
        RUN ImageListDump IN THIS-PROCEDURE.
    END.
    RUN SensButtons IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImageListDump d-images 
PROCEDURE ImageListDump :
/*------------------------------------------------------------------------------
  Purpose   : Сохранение списка изображений    
  Parameters:  <none>
  Notes     :       
------------------------------------------------------------------------------*/
  &IF DEFINED (UIB_IS_RUNNING) = 0 &THEN
  IF NOT mF_update_photo THEN RETURN.
  &ENDIF
  
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    mImageList = "":U.
    FOR EACH ttImgBar NO-LOCK:
        IF LENGTH (ttImgBar.fFile) > 0 THEN
            mImageList = 
                (IF LENGTH (mImageList) > 0 THEN 
                    mImageList + {&ImageDelimiter} ELSE "":U) 
                + ttImgBar.fFile
            .
    END.
    RUN imagelist_encode IN THIS-PROCEDURE (INPUT mImageList, OUTPUT mImageList).
    RUN gds-attr-write (iGds-code, "image-list":U, mImageList).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImageListLoad d-images 
PROCEDURE ImageListLoad :
/*------------------------------------------------------------------------------
  Purpose   : Чтение списка изображений    
  Parameters:  <none>
  Notes     :       
------------------------------------------------------------------------------*/    
    DEFINE VARIABLE vImageList AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vInt       AS INTEGER     NO-UNDO.
    
    RUN gds-attr-value (iGds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    /* MESSAGE vImageList VIEW-AS ALERT-BOX. */
    mImageList = "":U.
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, iGds-code, OUTPUT vImageList).
    DO vInt = 1 TO NUM-ENTRIES (vImageList, {&ImageDelimiter}):
        vCh =ENTRY (vInt, vImageList, {&ImageDelimiter}).
        RUN ImgBarAdd IN THIS-PROCEDURE (vCh).
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImgBarAdd d-images 
PROCEDURE ImgBarAdd PRIVATE :
/*------------------------------------------------------------------------------
  Purpose   : Добавить кнопку в навигатор    
  Parameters: Файл
  Notes     :       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER iFile AS CHARACTER NO-UNDO.
    DEFINE BUFFER ttImgBar FOR ttImgBar.
    CREATE ttImgBar.
    ASSIGN
        mImageSID      = mImageSID + 1
        mImageMax      = mImageMax + 1
        ttImgBar.fXPix = ImgXPix (mImageMax)
        ttImgBar.fID   = STRING (mImageSID)
        ttImgBar.fNum  = mImageMax
        ttImgBar.fFile = iFile
        .
    RUN ref\dynatrig.p PERSISTENT SET ttImgBar.fTrgs.
    CREATE FRAME ttImgBar.fFrame ASSIGN
        NAME             = "Image":U
        THREE-D          = YES
        FRAME            = mImgBarFrame
        PRIVATE-DATA     = ttImgBar.fID
        /*TITLE           = ttImgBar.fID*/
        WIDTH-PIXELS     = {&ImgBoxSize}
        HEIGHT-PIXELS    = mImgBarFrame:HEIGHT-PIXELS - 2
        Y                = 0
        X                = ttImgBar.fXPix
        MOVABLE          = YES AND mEnab
        SELECTABLE       = YES
        MANUAL-HIGHLIGHT = YES
        HIDDEN           = NO
        SENSITIVE        = YES
        VISIBLE          = YES
    TRIGGERS:
        ON "END-MOVE":U  ANYWHERE PERSISTENT RUN DynaTrig IN ttImgBar.fTrgs 
            ("END-MOVE":U ).
        ON "SELECTION":U ANYWHERE PERSISTENT RUN DynaTrig IN ttImgBar.fTrgs 
            ("SELECTION":U).
        ON "MOUSE-SELECT-DBLCLICK":U ANYWHERE PERSISTENT RUN DynaTrig IN ttImgBar.fTrgs 
            ("MOUSE-SELECT-DBLCLICK":U).
    END TRIGGERS.
    RUN SetHandle IN ttImgBar.fTrgs (ttImgBar.fFrame).
    CREATE IMAGE ttImgBar.fImage ASSIGN
        FRAME          = ttImgBar.fFrame
        WIDTH-PIXELS   = {&ImgIcoSize}
        HEIGHT-PIXELS  = {&ImgIcoSize}
        STRETCH-TO-FIT = YES
        RETAIN-SHAPE   = YES
        VISIBLE        = YES
        .
    /*IF SEARCH (ttImgBar.fFile) <> ? THEN*/
    ttImgBar.fImage:LOAD-IMAGE (ttImgBar.fFile) NO-ERROR.
    IF LENGTH (ttImgBar.fFile) > 0 THEN
        mImageList = 
            (IF LENGTH (mImageList) > 0 THEN mImageList + {&ImageDelimiter} ELSE "":U) 
            + ttImgBar.fFile.
    RELEASE ttImgBar.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImgBarInit d-images 
PROCEDURE ImgBarInit PRIVATE :
/*------------------------------------------------------------------------------
  Purpose   : Инициализация навгатора изображений    
  Parameters: Уже нет
  Notes     : Тянется во всю ширину фрейма      
------------------------------------------------------------------------------*/
    DEFINE VARIABLE vBorderTop     AS INTEGER   NO-UNDO.
    IF NOT VALID-HANDLE (mImgBarFrame) THEN
    DO:
        /*CREATE FRAME mImgBarFrame ASSIGN
            THREE-D       = YES
            FRAME         = iParent
            TITLE         = "":U
            .
        vBorderTop = mImgBarFrame:BORDER-TOP-PIXELS.
        DELETE OBJECT mImgBarFrame.*/
        RUN ref\dynatrig.p PERSISTENT SET mImgSliderTrgs.
        mImgBarFrame = FRAME FrameX:HANDLE.
        ASSIGN
            /*mImgBarFrame:TOP-ONLY      = YES
            mImgBarFrame:THREE-D       = YES
            mImgBarFrame:FRAME         = FRAME {&FRAME-NAME}:HANDLE*/
            mImgBarFrame:WIDTH-PIXELS  = FRAME {&FRAME-NAME}:VIRTUAL-WIDTH-PIXELS - 16
            mImgBarFrame:HEIGHT-PIXELS = 2 + ({&ImgBoxSize}) + vBorderTop
            /*mImgBarFrame:Y             = 5 + b-exit:X + b-exit:HEIGHT-PIXELS iY*/
            mImgBarFrame:HIDDEN        = NO
            mImgBarFrame:SENSITIVE     = YES
            mImgBarFrame:VISIBLE       = YES
            .
        DO WITH FRAME {&FRAME-NAME}:
            ASSIGN
                f-marker:WIDTH-PIXELS = {&ImgBoxSize}
                f-marker:X            = 1
                f-marker:Y            = MAX (1, mImgBarFrame:Y - f-marker:HEIGHT-PIXELS)
                .
        END.
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImgSlider d-images 
PROCEDURE ImgSlider :
/*------------------------------------------------------------------------------
  Purpose   : Слайдер
  Parameters:  <none>
  Notes     :       
------------------------------------------------------------------------------*/
    DEFINE VARIABLE vMax AS INTEGER INITIAL 2 NO-UNDO.


    IF mImageMax > 1 THEN 
    DO: 
        IF VALID-HANDLE (mImgSlider) THEN DELETE OBJECT mImgSlider.
        vMax = mImageMax.
    END.

    IF NOT VALID-HANDLE (mImgSlider) THEN
    DO:
        CREATE SLIDER mImgSlider ASSIGN
            NAME             = "ImgSlider":U
            TIC-MARKS        = "TOP":U
            FREQUENCY        = 1
            HORIZONTAL       = TRUE
            FRAME            = FRAME {&FRAME-NAME}:HANDLE
            MAX-VALUE        = vMax
            MIN-VALUE        = 1
            HEIGHT-PIXELS    = mImgBarFrame:HEIGHT-PIXELS + 26
            WIDTH-PIXELS     = ImgXPix (vMax) + {&ImgBoxSize}
            X                = mImgBarFrame:X
            Y                = mImgBarFrame:Y
            NO-CURRENT-VALUE = YES
            TRIGGERS:
                ON "VALUE-CHANGED":U  ANYWHERE PERSISTENT RUN DynaTrig IN mImgSliderTrgs 
                    ("VALUE-CHANGED":U).
            END TRIGGERS.
        RUN SetHandle IN mImgSliderTrgs (mImgSlider:HANDLE).
    END.
    IF mImageMax > 1 THEN
        ASSIGN
            mImgSlider:HIDDEN    = NO
            mImgSlider:SENSITIVE = YES
            mImgSlider:VISIBLE   = YES
            .
    ELSE
        ASSIGN
            mImgSlider:HIDDEN    = YES
            mImgSlider:SENSITIVE = NO
            mImgSlider:VISIBLE   = NO
            .
    mImgSlider:MOVE-TO-BOTTOM ().
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SelectImage d-images 
PROCEDURE SelectImage :
/*------------------------------------------------------------------------------
  Purpose   : Выбор картинки  
  Parameters: Номер, ID
  Notes:       
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER iNum AS INTEGER   NO-UNDO.
    DEFINE INPUT PARAMETER iID  AS CHARACTER NO-UNDO.

    DEFINE BUFFER ttImgBar FOR ttImgBar.

    FOR EACH ttImgBar NO-LOCK:
        IF ttImgBar.fNum = iNum OR ttImgBar.fID = iID THEN
        DO WITH FRAME {&FRAME-NAME}:
            ASSIGN
                f-marker:X               = ttImgBar.fFrame:X
                f-FileName:SCREEN-VALUE  = ttImgBar.fFile
                mImgSlider:SCREEN-VALUE  = STRING (ttImgBar.fNum)
                ttImgBar.fFrame:SELECTED = NO
                mImageCurID              = ttImgBar.fID
                mImageCurNum             = ttImgBar.fNum
                t-preview:CHECKED        = (ttImgBar.fNum = 1)
                t-preview:SENSITIVE      = (ttImgBar.fNum > 1) AND mEnab 
                .
            CurrentImage:LOAD-IMAGE (ttImgBar.fFile) NO-ERROR.
        END.
        ELSE
            ttImgBar.fFrame:SELECTED = NO.
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE SensButtons d-images 
PROCEDURE SensButtons :
/*------------------------------------------------------------------------------
  Purpose   :     
  Parameters:  <none>
  Notes     :       
------------------------------------------------------------------------------*/
    DO WITH FRAME {&FRAME-NAME}:
        ASSIGN 
            b-add:SENSITIVE = (ImgXPix (mImageMax + 1) + {&ImgBoxSize} < mImgBarFrame:WIDTH-PIXELS)
                AND mEnab
            b-del:SENSITIVE = mImageMax > 0 
                AND mEnab
            .
    END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ImgXPix d-images 
FUNCTION ImgXPix RETURNS INTEGER
  (iNum AS INTEGER) :
/*------------------------------------------------------------------------------
  Purpose: Смещение позиции 
    Notes:  
------------------------------------------------------------------------------*/

  RETURN 1 + (iNum - 1) * ({&ImgBoxSize} + {&ImgSpace}).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

