&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME get-rep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS get-rep
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно ввода параметров для таможенных отчетов

Автор: Суслов Алексей Юрьевич
Дата создания: 03/27/06
Author: Alexey Suslov
Creation date: 03/27/06

Input Parameters: partype-obj - тип объекта по которым производится выборка из справочника
Output Parameters:
  parcli-type  - тип объекта
  parcli-code  - код объекта
  partnved     - код ТНВЭД
  parcst-units - еденица измерени
  is-ok        - признак того, что все параметры установлены правильно

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input-output parameter from-date    as date no-undo .
define input-output parameter to-date    as date no-undo .
define input parameter p-curr-host-code-obj like ub.sysconf.host-code no-undo .
DEFINE INPUT  PARAMETER parobj-type  LIKE clients.obj-type NO-UNDO.
DEFINE OUTPUT PARAMETER parcli-type  LIKE clients.obj-type NO-UNDO.
DEFINE OUTPUT PARAMETER parcli-code  LIKE clients.obj-code NO-UNDO.
DEFINE OUTPUT PARAMETER partnved     AS CHARACTER     format "x(10)"     NO-UNDO.
DEFINE OUTPUT PARAMETER parcst-units AS CHARACTER          NO-UNDO.
DEFINE OUTPUT PARAMETER is-ok        AS LOGICAL INITIAL FALSE NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно ввода параметров для таможенных отчетов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/t-tnved.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */
def var ref-list as char no-undo.
def var f-name   as char no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME get-rep

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok RECT-3 RECT-22 b-quit b-help date-b ~
date-e varcli-type varcli-code r-clients varcst-units varrstnved
&Scoped-Define DISPLAYED-OBJECTS date-b date-e varcli-type varcli-code ~
varcst-units varTnved varrstnved varcli-name vartnved-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-ok AUTO-GO DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE BUTTON r-tnved
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-tnved"
     SIZE 3 BY .88.

DEFINE VARIABLE date-b AS DATE FORMAT "99/99/9999":U
     LABEL "&С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE date-e AS DATE FORMAT "99/99/9999":U
     LABEL "&По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.75 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.5 BY 1 NO-UNDO.

DEFINE VARIABLE varcli-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Об&ъект"
     VIEW-AS FILL-IN
     SIZE 4.88 BY 1 NO-UNDO.

DEFINE VARIABLE varTnved AS CHARACTER FORMAT "X(256)":U
     LABEL "&Уровень ТНВЕД"
     VIEW-AS FILL-IN
     SIZE 11.25 BY 1 NO-UNDO.

DEFINE VARIABLE vartnved-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.13 BY 1 NO-UNDO.

DEFINE VARIABLE varcst-units AS CHARACTER INITIAL "Таможенная"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Таможенная", "Таможенная",
"Ба&зовая", "Базовая"
     SIZE 39.88 BY 1 NO-UNDO.

DEFINE VARIABLE varrstnved AS CHARACTER INITIAL "Корень"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Корень", "Корень",
"&Выборочно", "Выборочно"
     SIZE 28.5 BY 1.04 NO-UNDO.

DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60.88 BY 3.29.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 62.75 BY 9.96.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME get-rep
     b-ok AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 41
     date-b AT ROW 3.17 COL 4 COLON-ALIGNED
     date-e AT ROW 3.17 COL 23.38 COLON-ALIGNED
     varcli-type AT ROW 3.17 COL 44 COLON-ALIGNED
     varcli-code AT ROW 3.17 COL 50.13 COLON-ALIGNED NO-LABEL
     r-clients AT ROW 3.17 COL 59.5
     varcst-units AT ROW 7.04 COL 22 NO-LABEL
     varTnved AT ROW 9.5 COL 3.38
     r-tnved AT ROW 9.5 COL 30.5
     varrstnved AT ROW 9.5 COL 33.75 NO-LABEL
     varcli-name AT ROW 4.79 COL 2.88 NO-LABEL
     vartnved-name AT ROW 11.04 COL 3 NO-LABEL
     "Единица измерения:" VIEW-AS TEXT
          SIZE 18.13 BY 1 AT ROW 7.04 COL 3.38
          BGCOLOR 7
     RECT-3 AT ROW 2.67 COL 1
     RECT-22 AT ROW 9.13 COL 1.88
     SPACE(1.47) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Задайте параметры отчета"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX get-rep
                                                                        */
ASSIGN
       FRAME get-rep:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON r-tnved IN FRAME get-rep
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcli-name IN FRAME get-rep
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varTnved IN FRAME get-rep
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN vartnved-name IN FRAME get-rep
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX get-rep
/* Query rebuild information for DIALOG-BOX get-rep
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX get-rep */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok get-rep
ON CHOOSE OF b-ok IN FRAME get-rep /* Ввод */
DO:
    assign frame {&frame-name}
        date-b
        date-e
        vartnved
        varcli-type
        varcli-code
        varcst-units
        .
    /*Проверим даты*/
    if date-e < date-b then
        do:
            message "Дата начала периода не может быть больше даты окончания!" view-as alert-box ERROR.
            APPLY "ENTRY" TO date-b IN FRAME {&FRAME-NAME}.
            return no-apply.
        end.
    /*Проверим код ТНВЭД*/
    IF varTnved <> "Всё" THEN DO:
      find first tt-tnved where tt-tnved.tnved = vartnved no-error.
      if not available tt-tnved then do:
            message "Неверный код ТНВЭД" view-as alert-box ERROR.
            APPLY "ENTRY" TO vartnved IN FRAME {&FRAME-NAME}.
            return no-apply.
      end.
    END.
    /*Проверим объект*/
    IF parobj-type <> "all" then do:
       RUN check-cli no-error.
       IF error-status:error then return no-apply.
    end.

   assign
   from-date    = date-b
   to-date      = date-e
   parcli-type  = varcli-type
   parcli-code  = varcli-code
   partnved     = vartnved
   parcst-units = varcst-units
   is-ok        = yes no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-b
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-b get-rep
ON return OF date-b IN FRAME get-rep /* С */
DO:
  apply "entry" to date-e in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-e
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-e get-rep
ON RETURN OF date-e IN FRAME get-rep /* По */
DO:
    APPLY "ENTRY" TO varcli-type IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-clients get-rep
ON CHOOSE OF r-clients IN FRAME get-rep
DO:
  RUN chs-cli no-error.
  if error-status:error then return no-apply.
  run check-cli no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-tnved
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-tnved get-rep
ON CHOOSE OF r-tnved IN FRAME get-rep /* r-tnved */
DO:
  RUN ch-tnved.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcli-code get-rep
ON MOUSE-SELECT-DBLCLICK OF varcli-code IN FRAME get-rep
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  if not error-status:error then
     apply "entry" to varcst-units in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcli-code get-rep
ON RETURN OF varcli-code IN FRAME get-rep
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  if not error-status:error then
     apply "entry" to varcst-units in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcli-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcli-type get-rep
ON MOUSE-SELECT-DBLCLICK OF varcli-type IN FRAME get-rep /* Объект */
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  apply "entry" to varcst-units in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcli-type get-rep
ON RETURN OF varcli-type IN FRAME get-rep /* Объект */
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  apply "entry" to varcst-units in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varcst-units
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varcst-units get-rep
ON return OF varcst-units IN FRAME get-rep
DO:
  apply "entry" to varrstnved in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varrstnved
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varrstnved get-rep
ON return OF varrstnved IN FRAME get-rep
DO:
  if input frame {&frame-name} varrstnved = "корень" then
      apply "entry" to b-ok in frame {&frame-name}.
  else
      apply "entry" to vartnved in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varrstnved get-rep
ON VALUE-CHANGED OF varrstnved IN FRAME get-rep
DO:
  RUN st-tnved.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varTnved
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varTnved get-rep
ON RETURN OF varTnved IN FRAME get-rep /* Уровень ТНВЕД */
DO:
    find first tt-tnved where tt-tnved.tnved = input frame {&frame-name} vartnved no-error.
    if not available tt-tnved then do:
       message "Неверный код ТНВЭД." view-as alert-box error.
       RUN ch-tnved no-error.
    end.
    display tt-tnved.f-name @ vartnved-name with frame {&frame-name}.
    apply "entry" to b-ok in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK get-rep


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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if from-date = ? OR to-date = ?
  then do:
        define variable v-today as date      no-undo.
        define variable v-time  as integer   no-undo.
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
            from-date = date( month( v-today ), 01, year( v-today ) )
            to-date   = v-today
        .
  end.
  assign
      date-b = from-date
      date-e = to-date
      .
  RUN enable_UI.
  if parobj-type = "all" then do:
     disable varcli-type varcli-code r-clients with frame {&frame-name}.
     hide varcli-type varcli-code r-clients in frame {&frame-name}.
  end.

  RUN st-tnved.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS date-b.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ch-tnved get-rep
PROCEDURE ch-tnved :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  DEFINE VARIABLE rid-tnved AS RECID NO-UNDO.
  run ref/t-tnved.w (no, output rid-tnved).
  find first tt-tnved where RECID(tt-tnved) = rid-tnved no-lock no-error.
  if available tt-tnved then disp tt-tnved.tnved  @ vartnved
                                  tt-tnved.f-name @ vartnved-name with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-cli get-rep
PROCEDURE check-cli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
find clients where clients.obj-code = input frame {&frame-name} varcli-code
               and clients.obj-type = input frame {&frame-name} varcli-type no-error.
if not available clients then do:
  if input frame {&frame-name} varcli-code <> ? and
     input frame {&frame-name} varcli-type <> ? then
    message "Неправильный код или тип контрагента." view-as alert-box error.
  apply "entry" to varcli-code in frame {&frame-name}.
  return error.
end.
disp clients.obj-type @ varcli-type with frame {&frame-name}.
if parobj-type = "" or
  clients.obj-type = parobj-type then do:
  if clients.obj-type = {&stock} then do:
      find store where store.obj-code = clients.obj-code no-lock.
      if store.host-code <> p-curr-host-code-obj then do:
        release clients no-error.
        message "Выбран склад другой фирмы."  view-as alert-box error.
        apply "entry" to varcli-code in frame {&frame-name}.
        return error.
      end.
  end.
  else if clients.obj-type = {&shop} then do:
      find shop where shop.obj-code = clients.obj-code no-lock.
      if shop.host-code <> p-curr-host-code-obj then do:
        release clients no-error.
        message "Выбран магазин другой фирмы." view-as alert-box error.
        apply "entry" to varcli-code in frame {&frame-name}.
        return error.
      end.
  end.
  else do:
        message "Выберите внутренний склад или магазин." view-as alert-box error.
        apply "entry" to varcli-code in frame {&frame-name}.
        return error.
  end.
end.
else do:
  release clients no-error.
  message "Отчет по внутренним " (if parobj-type = {&shop} then "магазинам." else "складам.")
          "Выберите внутренний " (if parobj-type = {&shop} then "магазин." else "склад.") view-as alert-box error.
  apply "entry" to varcli-code in frame {&frame-name}.
  return error.
end.

varcli-code = input frame {&frame-name} varcli-code.
varcli-type = input frame {&frame-name} varcli-type.
disp clients.obj-name @ varcli-name with frame {&frame-name}.
release clients.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chs-cli get-rep
PROCEDURE chs-cli :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-ref-rec as recid no-undo .
  run ref/cli-all.w ( parparentproc
                 , "b-sel"
                 , parobj-type
                 , ?
                 , ?
                 , ?
                 , ?
                 , ?
                 , output ref-list) .
  if ref-list <> "" then do:
    v-ref-rec = integer (ref-list).
    find clients where recid ( clients ) = v-ref-rec no-lock.
    disp clients.obj-code @ varcli-code
         clients.obj-name @ varcli-name
         clients.obj-type @ varcli-type with frame {&frame-name}.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI get-rep  _DEFAULT-DISABLE
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
  HIDE FRAME get-rep.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI get-rep  _DEFAULT-ENABLE
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
  DISPLAY date-b date-e varcli-type varcli-code varcst-units varTnved varrstnved
          varcli-name vartnved-name
      WITH FRAME get-rep.
  ENABLE b-ok RECT-3 RECT-22 b-quit b-help date-b date-e varcli-type
         varcli-code r-clients varcst-units varrstnved
      WITH FRAME get-rep.
  {&OPEN-BROWSERS-IN-QUERY-get-rep}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE st-tnved get-rep
PROCEDURE st-tnved :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  case input frame {&frame-name} varrstnved:
    when "Корень" then do:
      DISPLAY "Всё" @ vartnved
              ""    @ vartnved-name WITH FRAME {&frame-name}.
      DISABLE vartnved r-tnved WITH FRAME {&frame-name}.
    end.
    otherwise do:
      DISPLAY "?" @ vartnved WITH FRAME {&frame-name}.
      ENABLE vartnved r-tnved WITH FRAME {&frame-name}.
      APPLY "ENTRY" TO r-tnved.
      RETURN NO-APPLY.
    end.
  end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME