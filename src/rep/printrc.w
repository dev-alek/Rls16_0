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

Отчет по версиям RC на УБД.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по версиям RC на УБД".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/clntattr.i }
{ gbl/prn-lib.i }

define variable v-obj-list  as character no-undo.
define variable v-host-code as integer   no-undo.
define variable v-host-name as character no-undo.
define variable v-today     as date      no-undo.
define variable v-time      as integer   no-undo.
define variable v-list      as character no-undo.


define temp-table temp_db-list no-undo
  field db-num as integer
  index pi is primary unique db-num
  .


&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 Btn_OK date_from date_to bt-set rs-1 ~
bt-sel-dbs 
&Scoped-Define DISPLAYED-OBJECTS date_from date_to ed-bd rs-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-sel-dbs 
  IMAGE-UP FILE "btn-down-arrow":U
  IMAGE-DOWN FILE "btn-down-arrow":U
  IMAGE-INSENSITIVE FILE "btn-down-arrow":U
  LABEL "..." 
  SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-set 
  LABEL "Выполнить" 
  SIZE 12 BY 1 .

DEFINE BUTTON Btn_OK DEFAULT 
  LABEL "&Выход" 
  SIZE 10 BY 1
  BGCOLOR 8 .

DEFINE VARIABLE ed-bd     AS CHARACTER 
  VIEW-AS EDITOR NO-BOX
  SIZE 35.63 BY 2.71
  FGCOLOR 1 NO-UNDO.

DEFINE VARIABLE date_from AS DATE      FORMAT "99/99/9999":U 
  LABEL "Дата с" 
  VIEW-AS FILL-IN 
  SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date_to   AS DATE      FORMAT "99/99/9999":U 
  LABEL "по" 
  VIEW-AS FILL-IN 
  SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE rs-1      AS INTEGER 
  VIEW-AS RADIO-SET VERTICAL
  RADIO-BUTTONS 
  "Все", 1,
  "Выборочно", 2
  SIZE 13.75 BY 2.38 NO-UNDO.

DEFINE RECTANGLE RECT-1
  EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
  SIZE 55.38 BY 3.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
  Btn_OK AT ROW 1.25 COL 1.5
  date_from AT ROW 2.75 COL 11.5 COLON-ALIGNED
  date_to AT ROW 2.75 COL 29 COLON-ALIGNED
  bt-set AT ROW 2.75 COL 45.5
  ed-bd AT ROW 6.04 COL 20.88 NO-LABEL
  rs-1 AT ROW 6.13 COL 3.13 NO-LABEL
  bt-sel-dbs AT ROW 7.38 COL 16.5
  "Список БД" VIEW-AS TEXT
  SIZE 12.5 BY .67 AT ROW 4.5 COL 2.5 WIDGET-ID 2
  RECT-1 AT ROW 5.5 COL 2
  SPACE(0.86) SKIP(0.32)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
  TITLE "Отчет по версиям RC и УБД".


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
   FRAME-NAME                                                           */
ASSIGN 
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.

/* SETTINGS FOR EDITOR ed-bd IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Отчет по версиям RC и УБД */
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-dbs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-dbs Dialog-Frame
ON CHOOSE OF bt-sel-dbs IN FRAME Dialog-Frame /* ... */
  DO:
    define variable v-db-list as character no-undo .
    define variable ii        as integer   no-undo .
    assign
      rs-1 :screen-value = "2"
      .
    for each temp_db-list:
      delete temp_db-list.
    end.

    run rep/selectBD.w (
      input parparentproc,
      output v-db-list) no-error .
    do ii = 1 to num-entries (v-db-list, {&comma-char}):
      create temp_db-list .
      assign 
        temp_db-list.db-num = integer(entry(ii, v-db-list, {&comma-char})) . 
    end.
    run db-select .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set Dialog-Frame
ON CHOOSE OF bt-set IN FRAME Dialog-Frame /* Выполнить */
  DO:
    ASSIGN
      date_from
      date_to
      rs-1
      .
    
    run test-input .
    
    run print_RC .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выход */
  DO:
    APPLY "GO" TO FRAME {&FRAME-NAME}.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_from Dialog-Frame
ON RETURN OF date_from IN FRAME Dialog-Frame /* Дата с */
  DO:
    APPLY "ENTRY" TO date_to IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_to Dialog-Frame
ON RETURN OF date_to IN FRAME Dialog-Frame /* по */
  DO:
    APPLY "ENTRY" TO btn_OK IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-1 Dialog-Frame
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
  DO:
    assign
      rs-1
      .
    run db-select in this-procedure no-error .
    if error-status :error
      then 
    do:
      undo, return no-apply.
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
  THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/ed_date.i date_from }
{ gbl/ed_date.i date_to   }

run cur-time in this-procedure ( output v-today
  , output v-time
  ).
ASSIGN
  date_from = 01.01.1990
  date_to   = v-today
  .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }

  RUN enable_UI.
  run db-select .
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
  DISPLAY date_from date_to ed-bd rs-1 
    WITH FRAME Dialog-Frame.
  ENABLE RECT-1 Btn_OK date_from date_to bt-set rs-1 bt-sel-dbs 
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE object-select Dialog-Frame 
PROCEDURE db-select :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    v-list = "" .
    case rs-1 :screen-value in frame Dialog-frame
      :
      when "1"
      then 
        do:
          assign
            ed-bd :screen-value = "Все"
            .
            
        end.
      when "2"
      then 
        do:
          for each temp_db-list
            :
            assign
              v-list = v-list + " " + string( temp_db-list.db-num ) 
              .
          end.
          ed-bd :screen-value = string( v-list ) .
        end.
    end case.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test-input Dialog-Frame 
PROCEDURE test-input :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    if date_from > date_to
      then 
    do:
      message
        "Даты интервала заданы неверно. "
        skip 
        " Нижняя дата интервала должна быть меньше верхней."
        skip(1) "Задайте интервал дат правильно или отмените экспорт."
        view-as alert-box information.
      apply "entry" to date_from in frame {&frame-name} .
      undo, return error.
    end.
  end.
END PROCEDURE. /* test-input */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print_RC Dialog-Frame 
PROCEDURE print_RC :
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  do
    on error undo, return error
    :
    run PROC-print-RC in this-procedure.

  end.
END PROCEDURE. /* print_RC */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print-RC Dialog-Frame 
PROCEDURE proc-print-RC :
  /*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/
  define variable v-dataseth as handle    no-undo .
  define variable v-xmlh     as handle    no-undo .
  define variable v-db-list  as character no-undo .
  do
    on error undo, return error
    :
    if v-list <> "" then 
    do:
      for each temp_db-list no-lock:
        if v-db-list = "" then v-db-list = string(temp_db-list.db-num) .
        else 
        do:
          assign
            v-db-list = substitute( "&1&2&3", v-db-list, {&comma-char}, temp_db-list.db-num )
            . 
        end.  
      end.
    end.  
        
    run rep/r-printRC.p ( INPUT parparentproc
      , INPUT date_from 
      , INPUT date_to
      , INPUT v-db-list
      , input yes
      ) .      
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

