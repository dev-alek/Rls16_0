&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация каталога BGE 2

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEF INPUT  PARAM strB AS CHAR. /* "bge" - экспорт во внешн бух, "buh" - импорт из IBS Trade */
DEF OUTPUT PARAM strQuest   AS CHAR INIT "CANCEL".
DEF OUTPUT PARAM strDIR     AS CHAR INIT "".

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Инициализация каталога BGE 2".
{ cmp/vssrevis.i }

def var dir-type as char no-undo.
def var can-write as logical no-undo.

{ cmp/trg-def.i }
{ cmp/showinf.i  }
/* Local Variable Definitions ---                                       */
/*--DEF VAR strDIR     AS CHAR INIT "".--*/

DEF VAR strParentDir    AS CHARACTER NO-UNDO.
DEF VAR OKpressed       AS LOGICAL INITIAL TRUE NO-UNDO.
DEF VAR intCount        AS INT NO-UNDO.

DEF VAR strForEd2  AS CHAR NO-UNDO.

&if OPSYS = "UNIX" &then
&SCOP Slash /
&else
&SCOP Slash ~\
&endif

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel bt_DIR b-help EDITOR-2
&Scoped-Define DISPLAYED-OBJECTS EDITOR-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "OK"
     SIZE 10 BY 1 TOOLTIP "Подтверждение выбора каталога"
     BGCOLOR 8 .

DEFINE BUTTON bt_DIR
     LABEL "Каталог"
     SIZE 10 BY 1 TOOLTIP "Выбрать каталог".

DEFINE VARIABLE EDITOR-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 34.75 BY 8.5
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "wizdone":U
     SIZE 25.5 BY 8.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     bt_DIR AT ROW 1.25 COL 21.5
     b-help AT ROW 1.25 COL 54
     EDITOR-2 AT ROW 3 COL 29.5 NO-LABEL
     IMAGE-1 AT ROW 3 COL 1
     SPACE(38.62) SKIP(0.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Установка каталога для внешней бухгалтерии"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON Btn_OK IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       EDITOR-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR IMAGE IMAGE-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Установка каталога для внешней бухгалтерии */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* OK */
DO:
  RUN existDIR (strDir, "frg-acc", OUTPUT okPressed).
  IF NOT okPressed THEN DO. /* неудача */
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  RUN existDIR (strDir + "{&Slash}frg-acc", "dict", OUTPUT okPressed).
  IF NOT okPressed THEN DO. /* неудача */
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  RUN existDIR (strDir + "{&Slash}frg-acc", "exp-acc", OUTPUT okPressed).
  IF NOT okPressed THEN DO. /* неудача */
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  RUN existDIR (strDir + "{&Slash}frg-acc", "global", OUTPUT okPressed).
  IF NOT okPressed THEN DO. /* неудача */
    DISABLE EDITOR-2 WITH FRAME DIALOG-FRAME.
  END.
  ASSIGN
    /* strDIR - уже имеет значение */
    strQuest = "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt_DIR
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt_DIR Dialog-Frame
ON CHOOSE OF bt_DIR IN FRAME Dialog-Frame /* Каталог */
DO:
    IF SESSION:DISPLAY-TYPE = "GUI":U
    THEN do:
/*        SYSTEM-DIALOG GET-FILE strParentDir
             TITLE "Выборите каталог и введите OK"
             MUST-EXIST   SAVE-AS   USE-FILENAME
             UPDATE OKpressed
*/
        run gbl/dir-sel.p (
                        output strParentDir
                      , output dir-type
                      , output can-write
                            )
        .
        if can-write then OKpressed = true. else OKpressed = false.
    end.
    else do:
        update
            SKIP(2)
            SPACE(2) "Имя родительского каталога =" strParentDir SPACE(2)
            SKIP(2)
        with frame tty-frame
            view-as dialog-box no-labels
            title "Введите имя и нажмите <ENTER>"
        .
        message "Подтверждаете имя родительского каталога?" SKIP
            strParentDir
        view-as alert-box buttons ok-cancel update OKpressed.
    end.
    IF OKpressed = TRUE THEN DO.

            strDIR = strParentDir.

            IF strB = "bge" THEN
            EDITOR-2 = strForEd2 + {&new-line} + {&new-line} +
                    " Экспорт будет вестись в" + {&new-line} +
                    " каталог " + strDIR + "{&Slash}frg-acc"+ {&new-line} +
                    " Подтверждение - кнопка <OK>," + {&new-line} +
                    " отказ - кнопка <Отмена>".
            ELSE
            EDITOR-2 = strForEd2 + {&new-line} + {&new-line} +
                    " Фильтр будет храниться в" + {&new-line} +
                    " каталоге " + strDIR + "{&Slash}frg-acc" + {&new-line} +
                    " Подтверждение - кнопка <OK>," + {&new-line} +
                    " отказ - кнопка <Отмена>".
            DISPLAY EDITOR-2 WITH FRAME Dialog-Frame.
            ENABLE  btn_OK   WITH FRAME Dialog-Frame.
    END.
    ELSE DO.
        ASSIGN
            EDITOR-2 = strForEd2
            strDIR   = "".
        DISPLAY EDITOR-2 WITH FRAME Dialog-Frame.
        DISABLE btn_OK   WITH FRAME Dialog-Frame.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ASSIGN
  strForEd2 = IF strB = "bge" THEN
    " Кнопкой <Каталог> выберите" + {&new-line} +
    " родительский каталог," + {&new-line} +
    " в котором следует создать" + {&new-line} +
    " каталог хранения экспортных" + {&new-line} +
    " сумм и справочников (frg-acc)."
              ELSE
    " Кнопкой <Каталог> выберите" + {&new-line} +
    " родительский каталог," + {&new-line} +
    " в котором следует создать" + {&new-line} +
    " каталог хранения фильтра для" + {&new-line} +
    " документов IBS Trade (frg-acc)."

  FRAME Dialog-Frame:TITLE =  IF strB = "bge" THEN
    "Установка каталога для внешней бухгалтерии"
              ELSE
    "Установка каталога для хранения фильтра"

  EDITOR-2 = strForEd2
.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY EDITOR-2
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel bt_DIR b-help EDITOR-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE existDIR Dialog-Frame
PROCEDURE existDIR :
/*------------------------------------------------------------------------------
  Purpose:     Для каталога strParentDir определить есть ли в нем каталог strNameDir.
               Если нет, то сделать попытку создания. При неудаче создания вернуть NO.
               Иначе вернуть YES.
------------------------------------------------------------------------------*/
DEF INPUT  PARAM strParentDir AS CHAR. /* каталог в котором должен/будет содержаться каталог */
DEF INPUT  PARAM strNameDir   AS CHAR. /* искомый/создаваемый каталог */
DEF OUTPUT PARAM bolDirExist  AS LOG INIT NO NO-UNDO. /* дир есть или нет */

DEF VAR strDirMembShortName  AS CHAR NO-UNDO.  /* короткое имя в дир     */
DEF VAR strDirMembFullName   AS CHAR NO-UNDO.  /* путь   и имя в дир     */
DEF VAR strDirMembFlag       AS CHAR NO-UNDO.  /* признак - файл,дир,проч */

DEF VAR intErrorStatus       AS INT INIT 0  NO-UNDO. /*признак ошибки создания*/
DEF VAR bolDirCreated        AS LOG INIT NO NO-UNDO. /* дир создана сейчас */
DEF VAR strErrorStatus AS CHAR EXTENT 18 INIT [
    "Not owner",
    "No such file or directory",
    "Interrupted system call",
    "I/O error",
    "Bad file number",
    "No more processes",
    "Not enough core memory",
    "Permission denied",
    "Bad address",
    "File exists",
    "No such device",
    "Not a directory",
    "Is a directory",
    "File table overflow",
    "Too many open files",
    "File too large",
    "No space left on device",
    "Directory not empty"
] NO-UNDO.

    INPUT FROM OS-DIR (strParentDir).
    REPEAT.
        IMPORT strDirMembShortName strDirMembFullName strDirMembFLag.
        IF  CAPS(strDirMembShortName) = CAPS(strNameDir) AND
            CAPS(strDirMembFLag) = "D"                         /* это дир  */
        THEN DO. bolDirExist = YES. LEAVE. END.
        ELSE NEXT.
    END. /* of REPEAT */
    INPUT CLOSE.
    IF bolDirExist THEN RETURN.

    OS-CREATE-DIR value(strParentDir + "{&Slash}" + strNameDir).
    if OS-ERROR > 0 then do:
            MESSAGE " Не могу создать каталог " +
                     strParentDir + "{&Slash}" + strNameDir
            view-as alert-box title " Ошибка ".
        IF OS-ERROR <> 999 THEN DO.
            ASSIGN
                intErrorStatus = OS-ERROR
                EDITOR-2 = strForEd2 + "~012~012" +
                           " Ошибка создания каталога" + "~012 " +
                           strParentDir + "{&Slash}" + strNameDir + "~012 " +
                           STRING(intErrorStatus, ">9") + " " +
                           strErrorStatus[intErrorStatus].
            DISPLAY EDITOR-2 WITH FRAME Dialog-Frame.
        END.
        return "ERROR".
    end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME