&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-sumgrp


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_sum-grp FOR ub.sum-grp.
DEFINE BUFFER locked_sum-grp FOR ub.sum-grp.
DEFINE TEMP-TABLE tt-sum-grp NO-UNDO LIKE ub.sum-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-sumgrp
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование групп суммовых чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

Author: Черных В.
Created: 19/10/98

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input        parameter p-mode as character  no-undo.
define input-output parameter p-ri       as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование групп суммовых чеков".
{ cmp/vssrevis.i }
{ cmp/showinf.i }

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
        
/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/imagelist.i }
{ cmp/ini-lib.i }

define variable tcode      like sum-grp.grp-code no-undo.
define variable rr         as recid    no-undo.

DEFINE VARIABLE mImageList AS LONGCHAR NO-UNDO.
DEFINE VARIABLE mLogical   AS LOGICAL  NO-UNDO.

DEFINE buffer buf_sum-grp-attr for ub.sum-grp-attr .
   
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
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-sumgrp

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-sum-grp.grp-code tt-sum-grp.grp-name
&Scoped-define ENABLED-TABLES tt-sum-grp
&Scoped-define FIRST-ENABLED-TABLE tt-sum-grp
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 v-IMAGE b-add ~
n-choose-goods 
&Scoped-Define DISPLAYED-FIELDS tt-sum-grp.grp-code tt-sum-grp.grp-name 
&Scoped-define DISPLAYED-TABLES tt-sum-grp
&Scoped-define FIRST-DISPLAYED-TABLE tt-sum-grp
&Scoped-Define DISPLAYED-OBJECTS n-choose-goods 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
    LABEL "&Добавить" 
    SIZE 15 BY 1.13.

DEFINE BUTTON b-exit AUTO-GO 
    LABEL "&Ввод " 
    SIZE 10 BY 1.

DEFINE BUTTON b-help 
    LABEL "Помо&щь" 
    SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
    LABEL "&Отмена" 
    SIZE 10 BY 1.

DEFINE IMAGE v-IMAGE
    STRETCH-TO-FIT RETAIN-SHAPE
    SIZE 25 BY 4.25.

DEFINE RECTANGLE RECT-1
    EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
    SIZE 61.88 BY 9.5.

DEFINE VARIABLE n-choose-goods AS LOGICAL INITIAL no 
    LABEL "Группа для выбора товаров на кассе" 
    VIEW-AS TOGGLE-BOX
    SIZE 39.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-sumgrp
    b-exit AT ROW 1 COL 1
    b-quit AT ROW 1 COL 11
    b-help AT ROW 1 COL 58 WIDGET-ID 2
    tt-sum-grp.grp-code AT ROW 3 COL 38 COLON-ALIGNED
    LABEL "Код группы" FORMAT "999"
    VIEW-AS FILL-IN 
    SIZE 4.5 BY 1
    tt-sum-grp.grp-name AT ROW 4.5 COL 16 COLON-ALIGNED
    LABEL "Название"
    VIEW-AS FILL-IN 
    SIZE 41 BY 1
    b-add AT ROW 6 COL 49 WIDGET-ID 8
    n-choose-goods AT ROW 6.25 COL 5.5 WIDGET-ID 4
    RECT-1 AT ROW 2.5 COL 3.5
    v-IMAGE AT ROW 7.25 COL 39.5 WIDGET-ID 10
    SPACE(4.87) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Параметры группы".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: buf_sum-grp B "?" ? ub sum-grp
      TABLE: locked_sum-grp B "?" ? ub sum-grp
      TABLE: tt-sum-grp T "?" NO-UNDO ub sum-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-sumgrp
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-sumgrp:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN tt-sum-grp.grp-code IN FRAME d-sumgrp
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-sum-grp.grp-name IN FRAME d-sumgrp
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-sumgrp
/* Query rebuild information for DIALOG-BOX d-sumgrp
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-sumgrp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-sumgrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-sumgrp d-sumgrp
ON GO OF FRAME d-sumgrp /* Параметры группы */
    DO:
        assign
            tt-sum-grp.grp-code
            tt-sum-grp.grp-name
            .
        RUN proc-save IN THIS-PROCEDURE NO-ERROR.
        IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-sumgrp
ON CHOOSE OF b-add IN FRAME d-sumgrp /* Добавить */
    DO:
        DEFINE VARIABLE vFile AS CHARACTER NO-UNDO.
        DEFINE VARIABLE vLog  AS LOGICAL   NO-UNDO.
 
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


&Scoped-define SELF-NAME n-choose-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL n-choose-goods d-sumgrp
ON VALUE-CHANGED OF n-choose-goods IN FRAME d-sumgrp /* Группа для выбора товаров на кассе */
    DO:
        assign n-choose-goods .
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-sumgrp


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON STOP       UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if not (p-mode = {&add-def}
        or p-mode = {&update}
        or p-mode = {&lookup}) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра p-mode" p-mode
  view-as alert-box error .
  undo, return error .
end.
if p-mode = {&add-def} then do:
  p-ri = ?.
  FIND LAST buf_sum-grp NO-LOCK NO-ERROR .
  if available buf_sum-grp then
      tcode = buf_sum-grp.grp-code + 1.
  else
      tcode = 1.
  if tcode >= 1000 then do:
     tcode = ?.
  end.
  CREATE tt-sum-grp.
  tt-sum-grp.grp-code = tcode.
end.
else do:
  if  p-mode = {&update} then do:
    FIND locked_sum-grp EXCLUSIVE-LOCK WHERE recid( locked_sum-grp ) = p-ri .
  end.
  else do:
    FIND locked_sum-grp no-LOCK WHERE recid( locked_sum-grp ) = p-ri .
  end.
  CREATE tt-sum-grp.
  buffer-copy locked_sum-grp to tt-sum-grp.
end.
session:data-entry-return = yes .

RUN Myenable IN THIS-PROCEDURE.

if p-mode = {&add-def} then
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-sum-grp.grp-code .
else
    WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS tt-sum-grp.grp-name .
END.
RUN disable_UI.
session:data-entry-return = no .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-sumgrp  _DEFAULT-DISABLE
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
  HIDE FRAME d-sumgrp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-sumgrp  _DEFAULT-ENABLE
PROCEDURE enable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     ENABLE the User Interface
      Parameters:  <none>
      Notes:       Here we display/view/enable the widgets in the
                   user-interface.  In addition, OPEN all queries
                   associated with each FRAME and BROWSE.
                   These statements here are based on the "Other 
                   Settings" section of the widget Property Sheets.
    ------------------------------------------------------------------------------*/
    DISPLAY n-choose-goods
        WITH FRAME d-sumgrp.
    IF AVAILABLE tt-sum-grp THEN 
        DISPLAY tt-sum-grp.grp-code tt-sum-grp.grp-name 
            WITH FRAME d-sumgrp.
    ENABLE b-exit b-quit b-help RECT-1 v-IMAGE tt-sum-grp.grp-code 
        tt-sum-grp.grp-name b-add n-choose-goods 
        WITH FRAME d-sumgrp.
    {&OPEN-BROWSERS-IN-QUERY-d-sumgrp}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable d-sumgrp
PROCEDURE MyEnable :
    DEFINE VARIABLE vPar-val  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vPar-type AS CHARACTER NO-UNDO.

    ASSIGN
        vPar-val  = "":U
        vPar-type = "":U
        .
    {gbl/conf-rd.i "'photo':u"  "'':u" "'':u" 0 "'':u" "'':u" "'':u" no vPar-val vPar-type no-error}
    define VARIABLE vFile as character no-undo .
    IF AVAILABLE tt-sum-grp THEN 
    do:
        DISPLAY tt-sum-grp.grp-code tt-sum-grp.grp-name
            WITH FRAME {&frame-name}.
        mImagePh = LOOKUP (vPar-val, "true,yes":U) > 0.
        if mImagePh then 
        do:
            if p-mode <> {&lookup} then 
            do:
                ENABLE
                    b-add
                    n-choose-goods
                    with frame {&frame-name}.
            end.
            else 
            do:
                display
                    b-add
                    n-choose-goods
                    with frame {&frame-name}.
            end.        
            for each buf_sum-grp-attr where buf_sum-grp-attr.grp-code = tt-sum-grp.grp-code:
                if buf_sum-grp-attr.attr-code = "image-list" then 
                do:
                    /*           RUN imagelist_loaddef IN THIS-PROCEDURE NO-ERROR.*/
                    if LOOKUP("grp", mImageDir, "{&Slash}") = 0 then 
                    do: 
                        vFile = mImageDir + "grp{&Slash}":U + buf_sum-grp-attr.attr-value .
                    end.
                    else vFile = mImageDir + buf_sum-grp-attr.attr-value .
                    v-IMAGE:LOAD-IMAGE (vFile) in frame {&frame-name} NO-ERROR.
                end.         
                if buf_sum-grp-attr.attr-code = "grp-image" then 
                do:
                    n-choose-goods = LOGICAL (buf_sum-grp-attr.attr-value) .
                    DISPLAY n-choose-goods with frame {&frame-name}.
                end.     
            end.    
        end.
    end. 
    ENABLE
        b-exit 
        when P-mode <> {&lookup}
        RECT-1
        b-quit
        tt-sum-grp.grp-code 
        WHEN p-mode = {&add-def}
        tt-sum-grp.grp-name 
        when P-mode <> {&lookup}
        n-choose-goods
        WITH FRAME {&frame-name}.
    if p-mode = {&lookup} then 
    do:
        hide
            b-exit in frame {&frame-name} .
        assign
            b-quit:label  = "&Выход"
            b-quit:column = 1
            .
    end.
    {&OPEN-BROWSERS-IN-QUERY-d-sumgrp}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save d-sumgrp 
PROCEDURE proc-save :
    if p-mode = {&lookup} then return.
    run ref/sumgrp01.p (
        input-output p-ri
        ,input p-mode
        ,INPUT NO /*p-silent*/
        ,INPUT tt-sum-grp.grp-code
        ,INPUT tt-sum-grp.grp-name) NO-ERROR.

    if error-status:error then 
    do:
        { gbl/reterhnd.i error }
        undo, return error.
    end.
    else 
    do:
        find first buf_sum-grp-attr where buf_sum-grp-attr.grp-code = tt-sum-grp.grp-code and buf_sum-grp-attr.attr-code = "grp-image" no-error .
        if AVAILABLE buf_sum-grp-attr then 
        do:
            buf_sum-grp-attr.attr-value = string(n-choose-goods) .
        end.    
        else 
        do:
            create buf_sum-grp-attr.
            ASSIGN
                buf_sum-grp-attr.attr-code  = "grp-image"
                buf_sum-grp-attr.attr-value = string(n-choose-goods)
                buf_sum-grp-attr.grp-code   = tt-sum-grp.grp-code
                .
        end.    
        
        find first buf_sum-grp-attr where buf_sum-grp-attr.grp-code = tt-sum-grp.grp-code and buf_sum-grp-attr.attr-code = "image-list" no-error .
        if AVAILABLE buf_sum-grp-attr then 
        do:
            if buf_sum-grp-attr.attr-value = "" or mImageList <> "" then 
            do:
                buf_sum-grp-attr.attr-value = mImageList .
            end.  
        end.  
        else 
        do:
            create buf_sum-grp-attr.
            ASSIGN
                buf_sum-grp-attr.attr-code  = "image-list"
                buf_sum-grp-attr.attr-value = mImageList
                buf_sum-grp-attr.grp-code   = tt-sum-grp.grp-code
                .
        end.  
          
    end.    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ImageAdd d-sumgrp  
PROCEDURE ImageAdd :
    DEFINE INPUT PARAMETER iFile AS CHARACTER NO-UNDO.

    DEFINE BUFFER ttImgBar FOR ttImgBar.
    
    DEFINE VARIABLE vNum  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vFile AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vTmp  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vInt  AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vCh2  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vExt  AS CHARACTER NO-UNDO.
    
    if LOOKUP("grp", mImageDir, "{&Slash}") = 0 then 
    do: 
        mImageDir = mImageDir + "grp{&Slash}":U .
    end.
    RUN verify-file (mImagePreDir, "":U, YES, OUTPUT mLogical) NO-ERROR.
    IF ERROR-STATUS:ERROR OR NOT mLogical THEN
    DO:
        OS-CREATE-DIR VALUE (mImagePreDir).
        IF OS-ERROR <> 0 THEN
        DO:
            MESSAGE SUBSTITUTE ("Ошибка &1 создания поддиректории~n&2",
                OS-ERROR, mImageDir)
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
            vTmp       = SUBSTRING (iFile, 1 + 
                MAXIMUM (R-INDEX (iFile, "~\":U), R-INDEX (iFile, "~/":U)))
            vInt       = R-INDEX (vTmp, ".":U)
            vExt       = SUBSTRING (vTmp, vInt)
            vTmp       = SUBSTRING (vTmp, 1, vInt - 1)
            vFile      = mImageDir + vTmp + vExt
            mImageList = vTmp + vExt .
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
        v-IMAGE:LOAD-IMAGE (vFile) in frame {&frame-name} NO-ERROR.
    END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME