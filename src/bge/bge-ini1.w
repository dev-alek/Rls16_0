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

Изменить progress.ini - добавить секцию BGE

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEF INPUT  PARAM strB AS CHAR. /* "bge" - экспорт во внешн бух, "buh" - импорт из IBS Trade */
DEF OUTPUT PARAM strReturn AS CHAR INIT "CANCEL".
     /* "OK" - согласие, "CANCEL" - отказ */

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Изменить progress.ini - добавить секцию BGE".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS imgName Btn_Next Btn_Cancel b-help EDITOR-1
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help AUTO-GO
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Next AUTO-GO
     LABEL "Дальше"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "         Важно!"
     VIEW-AS EDITOR SCROLLBAR-VERTICAL NO-BOX
     SIZE 37 BY 9 TOOLTIP "Администратору: изменится progress.ini !"
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE IMAGE imgName
     FILENAME "cmp/advisor.bmp":U
     SIZE 21.5 BY 6.96.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Next AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     b-help AT ROW 1.25 COL 54
     EDITOR-1 AT ROW 2.5 COL 27 NO-LABEL
     imgName AT ROW 3.75 COL 3.5
     SPACE(40.12) SKIP(1.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Установка каталога экспорта для Внешней Бухгалтерии"
         DEFAULT-BUTTON Btn_Next CANCEL-BUTTON Btn_Cancel.


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

ASSIGN
       EDITOR-1:AUTO-INDENT IN FRAME Dialog-Frame      = TRUE
       EDITOR-1:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE
       EDITOR-1:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Установка каталога экспорта для Внешней Бухгалтерии */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
DO:
  strReturn = "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Next Dialog-Frame
ON CHOOSE OF Btn_Next IN FRAME Dialog-Frame /* Дальше */
DO:
  strReturn = "OK".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

IF strB = "bge" THEN
 ASSIGN
 EDITOR-1 = "         Важно!" + {&new-line} +
 " Экспорт сумм по документам," + {&new-line} +
 " а также экспорт справочников " + {&new-line} +
 " будет сводится к записи в файлы." + {&new-line} +
 " Для них необходимо указать" + {&new-line} +
 " размещение - каталог." + {&new-line} +
 " Отметьте, что этот каталог" + {&new-line} +
 " должен обладать особым" + {&new-line} +
 " статусом: он должен быть" + {&new-line} +
 " доступен с других рабочих" + {&new-line} +
 " станций. Хорошим решением будет" + {&new-line} +
 " то, которое примет" + {&new-line} +
 " администратор системы!"

 FRAME Dialog-Frame:TITLE = "Установка каталога экспорта для Внешней Бухгалтерии"
 .
ELSE /*--- strb = "buh" ----*/
 ASSIGN
 EDITOR-1 = "         Важно!" + {&new-line} +
 " Фильтр для разделения проводимых" + {&new-line} +
 " документов IBS Trade необходимо" + {&new-line} +
 " хранить вне базы данных." + {&new-line} +
 " Для этого следует указать его" + {&new-line} +
 " размещение - каталог." + {&new-line} +
 " Отметьте, что этот каталог" + {&new-line} +
 " должен обладать особым" + {&new-line} +
 " статусом: он должен быть" + {&new-line} +
 " доступен с других рабочих" + {&new-line} +
 " станций. Хорошим решением будет" + {&new-line} +
 " то, которое примет" + {&new-line} +
 " администратор системы!"
 FRAME Dialog-Frame:TITLE = "Установка каталога для фильтра разделения документов IBS Trade"
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
  DISPLAY EDITOR-1
      WITH FRAME Dialog-Frame.
  ENABLE imgName Btn_Next Btn_Cancel b-help EDITOR-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME