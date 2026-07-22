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

файл-конвертер из формата POS в формат моб сканера MS-15

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/
/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "файл-конвертер из формата POS в формат моб сканера".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }


DEFINE STREAM IN-stream.
DEFINE STREAM OUT-stream.
DEFINE temp-table cc no-undo
FIELD f2 as char
FIELD f3 as char
FIELD f4 as char
FIELD f5 as char
FIELD f6 as char
FIELD f8 as char
INDEX pi is unique primary f2 f3 f4 f5 f6 f8.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help file-name ~
B-file-name B-file-name-2 file-name-2
&Scoped-Define DISPLAYED-OBJECTS file-name file-name-2

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-file-name
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-file-name-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл для конвертации"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE file-name-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл для вывода"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-Help AT ROW 1 COL 54.88
     file-name AT ROW 4.75 COL 22.75 COLON-ALIGNED
     B-file-name AT ROW 4.79 COL 50.38
     B-file-name-2 AT ROW 6.67 COL 50.25
     file-name-2 AT ROW 6.75 COL 22.75 COLON-ALIGNED
     SPACE(15.38) SKIP(4.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Конвертер файлов из формата POS-IBM в формат моб.сканера MS15"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Конвертер файлов из формата POS-IBM в формат моб.сканера MS15 */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
DEFINE variable s as char no-undo.
DEFINE variable exist as logical no-undo.
/*для раскладки строчки*/
define variable n-entry as char no-undo extent 20.
define variable ii as integer no-undo.

if search(file-name) = ? OR search(file-name-2)  = ? then do:

    message "Не найден/ы файл/ы ввода/вывода!" view-as alert-box ERROR.
    return no-apply.
END.


run waitfram-show in this-procedure ("Ждите ...").
input stream IN-STREAM from value(file-name) .
output stream OUT-STREAM to value(file-name-2).


REPEAT ON STOP UNDO, LEAVE ON ERROR UNDO, LEAVE ON END-KEY UNDO, LEAVE:
    import stream IN-STREAM unformatted s.
    if substr(s, 1, 2) <> "01"
    AND substr(s, 1, 2) <> "00"
    AND substr(s, 1, 2) <> "05"
    then NEXT.
    repeat:
        s = REPLACE(s, "  ", " ").
        if INDEX(s, "  ") = 0 then leave.
    end.
    DO ii = 1 to num-entries(s, " "):
        assign
        n-entry[ii] = entry(ii, s, " ")
        .
    END.
    DO ii = (num-entries(s, " ") + 1 ) to 20:
        assign
        n-entry[ii] = "".
    END.
    assign
    ii = num-entries(s, " ")    .

    CASE n-entry[1]:
        WHEN "00" then do:
            IF NOT CAN-FIND (FIRST cc No-LOCK WHERE
                                   cc.f2 = N-ENTRY[2] AND
                                   cc.f3 = N-ENTRY[3] AND
                                   cc.f4 = N-ENTRY[4] AND
                                   cc.f8 = N-ENTRY[8] AND
                                   cc.f6 = N-ENTRY[6] AND
                                   cc.f5 = N-ENTRY[5]) THEN DO:
                create cc.
                assign
                exist = no
                cc.f2 = N-ENTRY[2]
                cc.f3 = N-ENTRY[3]
                cc.f4 = N-ENTRY[4]
                cc.f8 = N-ENTRY[8]
                cc.f6 = N-ENTRY[6]
                cc.f5 = N-ENTRY[5]
                .
            END.
            ELSE
            assign
            exist = yes.
        END.
        WHEN "01" then do:
            IF NOT EXIST then
            PUT STREAM OUT-STREAM UNFORMATTED
            N-ENTRY[2]
            {&comma-char}
            REPLACE(N-ENTRY[4], "+", "")
            SKIP
            .
        END.
        WHEN "05" then do:
            IF NOT EXIST then
            PUT STREAM OUT-STREAM UNFORMATTED
            N-ENTRY[2]
            {&comma-char}
            N-ENTRY[3]
            SKIP
            .
        END.

    END CASE.
END.


input stream In-STREAM close.
output stream OUT-STREAM close.
run waitfram-hide in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-name Dialog-Frame
ON CHOOSE OF B-file-name IN FRAME Dialog-Frame
DO:
    define variable v_os-file   AS CHAR NO-UNDO INIT "".
    define variable ll_commit AS LOG    NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для конвертации"
        FILTERS
          " Все спулы POS-IBM (fl*.*) " "fl*.*",
          " Все архивы спулов POS-IBM (*.spl) " "*.spl",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".*"
        USE-FILENAME
        MUST-EXIST
        UPDATE ll_commit
        .

    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-name-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-name-2 Dialog-Frame
ON CHOOSE OF B-file-name-2 IN FRAME Dialog-Frame
DO:
    define variable v_os-file   AS CHAR NO-UNDO INIT "".
    define variable ll_commit AS LOG    NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для вывода"
        FILTERS
          " Все текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        INITIAL-FILTER 1
        DEFAULT-EXTENSION ".txt"
        USE-FILENAME
        SAVE-AS
        UPDATE ll_commit
        .

    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name-2 = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name-2 WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл для конвертации */
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name-2 Dialog-Frame
ON LEAVE OF file-name-2 IN FRAME Dialog-Frame /* Файл для вывода */
DO:
    ASSIGN file-name-2.
    IF SEARCH( file-name-2 ) <> ? AND SEARCH( file-name-2 ) <> "":U THEN DO:
        ASSIGN FILE-INFO:file-name = file-name-2.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name-2 = FILE-INFO:FULL-PATHNAME.
        DISP file-name-2 WITH FRAME {&FRAME-NAME}.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY file-name file-name-2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help file-name B-file-name B-file-name-2
         file-name-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME