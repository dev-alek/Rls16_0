&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заведение константных выражений даты и номера смены для фильтра

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/23/05
Author: Bakhtadze Natalya
Creation date: 03/23/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT-OUTPUT PARAMETER  p-name AS CHARACTER NO-UNDO.
define INPUT-OUTPUT parameter str     as character no-undo .
define INPUT-OUTPUT parameter str_rus as character no-undo .
define INPUT-OUTPUT parameter str-int     as CHARACTER no-undo .
define INPUT-OUTPUT parameter str_rus-int as character no-undo .
define INPUT-OUTPUT parameter str-int-shift-name     as CHARACTER no-undo .
define INPUT-OUTPUT parameter str_rus-int-shift-name as character no-undo .


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Заведение константных выражений даты и номера смены для фильтра".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/strcodec.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-Help F-name shift-date ~
toggle-date shift-name shift-num 
&Scoped-Define DISPLAYED-OBJECTS F-name shift-date toggle-date shift-name ~
shift-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO DEFAULT 
     LABEL "&Ввод":L 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-Help DEFAULT 
     LABEL "Помо&щь":L 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT 
     LABEL "&Отмена":L 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE F-name AS CHARACTER FORMAT "X(256)":U 
     LABEL "Название шаблона" 
     VIEW-AS FILL-IN 
     SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE shift-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата смены(учета)" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE shift-name AS CHARACTER FORMAT "X(2)":U 
     LABEL "№ смены" 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE shift-num AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "Пор.  смены" 
     VIEW-AS FILL-IN 
     SIZE 3.5 BY 1 NO-UNDO.

DEFINE VARIABLE toggle-date AS LOGICAL INITIAL no 
     LABEL "СЕГОДНЯ +/- ДНЕЙ" 
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-Help AT ROW 1 COL 65
     F-name AT ROW 3 COL 18 COLON-ALIGNED
     shift-date AT ROW 4.77 COL 1
     toggle-date AT ROW 4.77 COL 36
     shift-name AT ROW 6 COL 18 COLON-ALIGNED
     shift-num AT ROW 7.5 COL 7
     "(Для несменных объектов игнорируется)" VIEW-AS TEXT
          SIZE 49 BY 1 AT ROW 6 COL 24.5
          FGCOLOR 4 
     "(Для несменных объектов игнорируется)" VIEW-AS TEXT
          SIZE 49 BY 1 AT ROW 7.5 COL 24.5
          FGCOLOR 4 
     SPACE(0.37) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
   FRAME-NAME                                                           */
ASSIGN 
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN shift-date IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN shift-num IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit DIALOG-1
ON CHOOSE OF b-exit IN FRAME DIALOG-1 /* Ввод */
DO:
DEFINE VARIABLE v-dopi AS INTEGER NO-UNDO.
  ASSIGN
  f-name.
  IF f-name = "":U THEN DO:
      MESSAGE
      "Название шаблона не может быть пустым"
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
  END.
  ASSIGN
  v-dopi = INTEGER(INPUT FRAME {&FRAME-NAME} shift-name)
  NO-ERROR.
  IF ERROR-STATUS:ERROR
  OR v-dopi < 0 THEN DO:
      MESSAGE
      "Неверный № смены"
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1 


{ gbl/hot-key.i b-help }

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

{ gbl/ed_date.i shift-date }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR    UNDO MAIN-BLOCK, return error
      ON STOP       UNDO MAIN-BLOCK, return error
      ON END-KEY UNDO MAIN-BLOCK, return error :

  RUN UI_on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  ASSIGN
  f-name.
  if input frame {&frame-name} shift-date = "":U
  or input frame {&frame-name} shift-date = ?
  or input frame {&frame-name} shift-date = "?"
  then do:
    assign
      str = {&question-mark}
      str_rus = {&question-mark}
    .
  end.
  else do:
    if toggle-date :checked = true then do:
      define variable v-diff-value as integer   no-undo .
      define variable v-diff-str   as character no-undo .
      define variable v-diff-day   as character no-undo .
      assign
      v-diff-value = input frame {&frame-name} shift-date - today
      .
      if v-diff-value = 0 then do:
        assign
          v-diff-str = ""
          v-diff-day = ""
        .
      end.
      if v-diff-value > 0  then do:
        assign
          v-diff-str = '+ ':u + string(v-diff-value)
          v-diff-day = v-diff-str + " ДНЕЙ"
        .
      end.
      if v-diff-value < 0 then do:
        assign
          v-diff-str = '- ':u + string(abs(v-diff-value))
          v-diff-day = v-diff-str + " ДНЕЙ"
        .
      end.
      assign
      str = '(TODAY ':u + v-diff-str + ')':u
      str_rus = "СЕГОДНЯ " + v-diff-day
      .
    end.
    else do:
      define variable v-date as date      no-undo .
      assign
        v-date = input frame {&frame-name} shift-date
      .
      if v-date = ? then do:
        assign
          str = {&question-mark}
          str_rus = "НЕ_ЗАДАНА"
        .
      end.
      else do:
        assign
          str = 'date(':u + string(month(v-date))
              + '~~054':u + string(day(v-date))
              + '~~054':u + string(year(v-date))
              + ')':u
          str_rus = string(v-date, "99/99/9999")
        .
      end.
    end.
  end.

assign
  str-int = string(input frame {&frame-name} shift-num)
  str_rus-int = string(input shift-num)
  str-int-shift-name = input frame {&frame-name} shift-name
  str_rus-int-shift-name = input shift-name
  p-name = f-name
.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY F-name shift-date toggle-date shift-name shift-num 
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-quit b-Help F-name shift-date toggle-date shift-name 
         shift-num 
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI_on DIALOG-1 
PROCEDURE UI_on :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
DEFINE VARIABLE v-time as integer no-undo .
DEFINE VARIABLE v-dop AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dop1 AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dop2 AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dop3 AS CHARACTER NO-UNDO.
define variable v-dop-int as integer no-undo .
run cur-time in this-procedure (output shift-date, output v-time).
ASSIGN
f-name = p-name
v-dop = str
.
IF INDEX (str, "today") = 0  THEN DO:
   v-dop = str-decode(str, "":U).
   ASSIGN
   v-dop = substring(v-dop, 6)
   v-dop = TRIM(v-dop, ")")
   v-dop1 = ENTRY(1, v-dop, {&comma-char})
   v-dop2 = ENTRY(2, v-dop, {&comma-char})
   v-dop3 = ENTRY(3, v-dop, {&comma-char}).

END.
else do:
  assign
  v-dop = trim(str, "(")
  v-dop = trim(v-dop, ")")
  v-dop = replace(v-dop, "TODAY", "":U)
  v-dop = trim(v-dop)
  v-dop-int = integer(v-dop)
  .
  shift-date = shift-date  + v-dop-int.
end.

ASSIGN
shift-date = IF INDEX (str, "today") > 0
             THEN shift-date
             ELSE DATE( INTEGER(v-dop1),
                        INTEGER(v-dop2),
                        INTEGER(v-dop3)
                      )
toggle-date  = INDEX (str, "today") > 0
shift-num = integer(str-int)
shift-name = str-int-shift-name
.
display
f-name
shift-date
toggle-date
shift-num
shift-name with frame {&frame-name}.
enable
f-name
shift-date
toggle-date
shift-num
shift-name
b-exit
b-quit
b-help with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

