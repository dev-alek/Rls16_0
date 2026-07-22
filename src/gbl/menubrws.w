&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-menubrsw
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-menubrsw
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Интерфейс работы с утилитами

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-mainmenu-handle as handle    no-undo .
define input parameter c-point           as character no-undo .
define input parameter c-title           as character no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Интерфейс работы с утилитами".
{ cmp/vssrevis.i "substitute('&1|&2':u,c-point,c-title)" }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/chk-entr.i }
{ cmp/library.i  }

if index (c-point, "%") > 0 then do:
  message "Указатель вызова интерфейса работы с утилитами не может содержать знак '%'."
  view-as alert-box error.
  return error.
end.
define temp-table br-proc no-undo
  field proc-index      as integer
  field proc-file       as character format "x(15)" label "Процедура"
  field proc-name       as character format "x(60)" label "Название"
  field c-point         as character
  field proc-install    as logical                  label "Автом. инст."
  field mainmenu-handle as logical                  label "Указатель меню"
  field proc-db-ver     as character format "x(10)" label "Версия БД"
  field proc-run-order  as character format "x(10)" label "Порядок запуска"
  field proc-client     as character format "x(10)" label "Для клиента"
  index i-up            is unique proc-index c-point
  index i-name          is primary c-point proc-name
  index i-file          proc-index c-point proc-file
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-menubrsw
&Scoped-define BROWSE-NAME br-proc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES br-proc

/* Definitions for BROWSE br-proc                                       */
&Scoped-define FIELDS-IN-QUERY-br-proc proc-name proc-file proc-install proc-db-ver proc-run-order
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-proc
&Scoped-define SELF-NAME br-proc
&Scoped-define QUERY-STRING-br-proc FOR EACH br-proc where br-proc.c-point = c-point
&Scoped-define OPEN-QUERY-br-proc OPEN QUERY br-proc FOR EACH br-proc where br-proc.c-point = c-point.
&Scoped-define TABLES-IN-QUERY-br-proc br-proc
&Scoped-define FIRST-TABLE-IN-QUERY-br-proc br-proc


/* Definitions for DIALOG-BOX d-menubrsw                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-menubrsw ~
    ~{&OPEN-QUERY-br-proc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS br-proc b-quit b-sel i-exit b-help find-name ~
find-file
&Scoped-Define DISPLAYED-OBJECTS find-name find-file

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel
     LABEL "_ В&ыполнить"
     SIZE 12 BY 1.

DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.

DEFINE VARIABLE find-file AS CHARACTER FORMAT "x(30)":U
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1 NO-UNDO.

DEFINE VARIABLE find-name AS CHARACTER FORMAT "x(60)":U
     VIEW-AS FILL-IN
     SIZE 60.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-proc FOR
      br-proc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-proc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-proc d-menubrsw _FREEFORM
  QUERY br-proc DISPLAY
      proc-name
      proc-file  format "x(30)"
      proc-install
      proc-db-ver
      proc-run-order
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90.75 BY 15.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-menubrsw
     br-proc AT ROW 2.63 COL 1
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     i-exit AT ROW 1.13 COL 11 WIDGET-ID 4
     b-help AT ROW 1 COL 70.5
     find-name AT ROW 20.71 COL 1.5 NO-LABEL
     find-file AT ROW 20.71 COL 60.25 COLON-ALIGNED NO-LABEL
     "названию" VIEW-AS TEXT
          SIZE 8.5 BY 1 AT ROW 19.71 COL 1.5
          FGCOLOR 4
     "процедуре" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 19.71 COL 62.25
          FGCOLOR 4
     "ПОИСК ПО:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 18.71 COL 1.5
          BGCOLOR 3 FGCOLOR 15
     SPACE(69.73) SKIP(2.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилиты"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-menubrsw
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB br-proc 1 d-menubrsw */
ASSIGN
       FRAME d-menubrsw:SCROLLABLE       = FALSE
       FRAME d-menubrsw:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN find-name IN FRAME d-menubrsw
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-proc
/* Query rebuild information for BROWSE br-proc
     _START_FREEFORM
OPEN QUERY br-proc FOR EACH br-proc where br-proc.c-point = c-point.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-proc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-menubrsw
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-menubrsw d-menubrsw
ON WINDOW-CLOSE OF FRAME d-menubrsw /* Утилиты */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-menubrsw
ON CHOOSE OF b-sel IN FRAME d-menubrsw /* _ Выполнить */
DO:
  do
  on stop  undo, return no-apply
  on error undo, return no-apply
  :
     run trg/userlog.p (
                input 'run-proc'
                , input ('Запущено выполнение процедуры: "'   
                + br-proc.proc-name +  '"' + {&delim-key} + br-proc.proc-file )
                , input ?
                , input ?
                , input "") no-error.
    if br-proc.proc-install then do:
      if br-proc.mainmenu-handle then do:
        run value (br-proc.proc-file)
          (input  p-mainmenu-handle
          ,input  false
          ) no-error .
      end.
      else do:
        run value (br-proc.proc-file)
          (input false
          ) no-error .
      end.
    end.
    else do:
      if br-proc.mainmenu-handle then do:
        run value (br-proc.proc-file)
          (input  p-mainmenu-handle
          ) no-error .
      end.
      else do:
        run value (br-proc.proc-file) no-error .
      end.
    end.
  end.
  run trg/userlog.p (
                input 'run-proc'
                , input ('Завершено выполнение процедуры' + (if error-status:error then ' с ошибкой "' else ' без ошибок "')  
                + br-proc.proc-name +  '"' + {&delim-key} + br-proc.proc-file )
                , input ?
                , input ?
                , input "") no-error.
  apply "ENTRY":U to br-proc in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-proc
&Scoped-define SELF-NAME br-proc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-proc d-menubrsw
ON MOUSE-SELECT-DBLCLICK OF br-proc IN FRAME d-menubrsw
DO:
  apply "CHOOSE":U to b-sel in frame {&frame-name}.
  apply "ENTRY":U to br-proc in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-proc d-menubrsw
ON RETURN OF br-proc IN FRAME d-menubrsw
DO:
  apply "CHOOSE":U to b-sel in frame {&frame-name}.
  apply "ENTRY":U to br-proc in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME find-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL find-file d-menubrsw
ON MOUSE-SELECT-DBLCLICK OF find-file IN FRAME d-menubrsw
DO:
  DEFINE VARIABLE rr AS RECID NO-UNDO.

  DEFINE BUFFER buf_proc FOR br-proc.

  DO ON STOP  UNDO, RETURN NO-APPLY
     ON ERROR UNDO, RETURN NO-APPLY :
    ASSIGN find-file.
    ASSIGN rr = ( IF AVAILABLE br-proc THEN RECID( br-proc ) ELSE ? ).
    FIND FIRST buf_proc WHERE RECID( buf_proc ) = rr NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO: FIND FIRST buf_proc WHERE buf_proc.c-point = c-point. END.
    FIND NEXT buf_proc WHERE
              buf_proc.c-point   =      c-point   AND
              buf_proc.proc-file BEGINS find-file NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO:
      FIND FIRST buf_proc WHERE
                 buf_proc.c-point   =      c-point   AND
                 buf_proc.proc-file BEGINS find-file NO-ERROR.
      IF NOT AVAILABLE buf_proc THEN DO:
        MESSAGE "Утилита" '"' + find-file + '"' "не найдена!" VIEW-AS ALERT-BOX INFORMATION.
        APPLY "ENTRY":U TO find-file IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    REPOSITION br-proc TO RECID rr NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: REPOSITION br-proc TO ROW 1. END.
  END.
  APPLY "ENTRY":U TO br-proc IN FRAME {&FRAME-NAME}.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL find-file d-menubrsw
ON RETURN OF find-file IN FRAME d-menubrsw
DO:
  DEFINE VARIABLE rr AS RECID NO-UNDO.

  DEFINE BUFFER buf_proc FOR br-proc.

  DO ON STOP  UNDO, RETURN NO-APPLY
     ON ERROR UNDO, RETURN NO-APPLY :
    ASSIGN find-file.
    ASSIGN rr = ( IF AVAILABLE br-proc THEN RECID( br-proc ) ELSE ? ).
    FIND FIRST buf_proc WHERE RECID( buf_proc ) = rr NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO: FIND FIRST buf_proc WHERE buf_proc.c-point = c-point. END.
    FIND NEXT buf_proc WHERE
              buf_proc.c-point   =      c-point   AND
              buf_proc.proc-file BEGINS find-file NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO:
      FIND FIRST buf_proc WHERE
                 buf_proc.c-point   =      c-point   AND
                 buf_proc.proc-file BEGINS find-file NO-ERROR.
      IF NOT AVAILABLE buf_proc THEN DO:
        MESSAGE "Утилита" '"' + find-file + '"' "не найдена!" VIEW-AS ALERT-BOX INFORMATION.
        APPLY "ENTRY":U TO find-file IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    REPOSITION br-proc TO RECID rr NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: REPOSITION br-proc TO ROW 1. END.
  END.
  APPLY "ENTRY":U TO br-proc IN FRAME {&FRAME-NAME}.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME find-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL find-name d-menubrsw
ON MOUSE-SELECT-DBLCLICK OF find-name IN FRAME d-menubrsw
DO:
  DEFINE VARIABLE rr AS RECID NO-UNDO.

  DEFINE BUFFER buf_proc FOR br-proc.

  DO ON STOP  UNDO, RETURN NO-APPLY
     ON ERROR UNDO, RETURN NO-APPLY :
    ASSIGN find-name.
    ASSIGN rr = ( IF AVAILABLE br-proc THEN RECID( br-proc ) ELSE ? ).
    FIND FIRST buf_proc WHERE RECID( buf_proc ) = rr NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO: FIND FIRST buf_proc WHERE buf_proc.c-point = c-point. END.
    FIND NEXT buf_proc WHERE
              buf_proc.c-point   =      c-point   AND
              buf_proc.proc-name BEGINS find-name NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO:
      FIND FIRST buf_proc WHERE
                 buf_proc.c-point   =      c-point   AND
                 buf_proc.proc-name BEGINS find-name NO-ERROR.
      IF NOT AVAILABLE buf_proc THEN DO:
        MESSAGE
          "Утилита с названием"   SKIP
          '  "' + find-name + '"' SKIP
          "не найдена!"
        VIEW-AS ALERT-BOX INFORMATION.
        APPLY "ENTRY":U TO find-name IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    REPOSITION br-proc TO RECID rr NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: REPOSITION br-proc TO ROW 1. END.
  END.
  APPLY "ENTRY":U TO br-proc IN FRAME {&FRAME-NAME}.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL find-name d-menubrsw
ON RETURN OF find-name IN FRAME d-menubrsw
DO:
  DEFINE VARIABLE rr AS RECID NO-UNDO.

  DEFINE BUFFER buf_proc FOR br-proc.

  DO ON STOP  UNDO, RETURN NO-APPLY
     ON ERROR UNDO, RETURN NO-APPLY :
    ASSIGN find-name.
    ASSIGN rr = ( IF AVAILABLE br-proc THEN RECID( br-proc ) ELSE ? ).
    FIND FIRST buf_proc WHERE RECID( buf_proc ) = rr NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO: FIND FIRST buf_proc WHERE buf_proc.c-point = c-point. END.
    FIND NEXT buf_proc WHERE
              buf_proc.c-point   =      c-point   AND
              buf_proc.proc-name BEGINS find-name NO-ERROR.
    IF NOT AVAILABLE buf_proc THEN DO:
      FIND FIRST buf_proc WHERE
                 buf_proc.c-point   =      c-point   AND
                 buf_proc.proc-name BEGINS find-name NO-ERROR.
      IF NOT AVAILABLE buf_proc THEN DO:
        MESSAGE
          "Утилита с названием"   SKIP
          '  "' + find-name + '"' SKIP
          "не найдена!"
        VIEW-AS ALERT-BOX INFORMATION.
        APPLY "ENTRY":U TO find-name IN FRAME {&FRAME-NAME}.
        RETURN NO-APPLY.
      END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    END.                      ELSE DO: ASSIGN rr = RECID( buf_proc ). END.
    REPOSITION br-proc TO RECID rr NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: REPOSITION br-proc TO ROW 1. END.
  END.
  APPLY "ENTRY":U TO br-proc IN FRAME {&FRAME-NAME}.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-menubrsw


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/brwrepos.i
  &line-num=10
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
  RUN load-br-proc-table IN THIS-PROCEDURE.
  RUN enable_UI          IN THIS-PROCEDURE.
  ASSIGN FRAME {&FRAME-NAME} :TITLE = c-title.

  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS br-proc.
END.
RUN disable_UI IN THIS-PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-br-proc d-menubrsw
PROCEDURE create-br-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-index       as integer   no-undo .
  define input  parameter p-proc-name   as character no-undo .
  define input  parameter p-proc-handle as handle    no-undo .
  define input  parameter p-curr-sys-key as character no-undo .

  define buffer buf_br-proc for br-proc .

  define variable v-c-point         as character no-undo .
  define variable v-proc-name       as character no-undo .
  define variable v-proc-file       as character no-undo .
  define variable v-proc-install    as logical   no-undo .
  define variable v-mainmenu-handle as logical   no-undo .
  define variable v-proc-db-ver     as character no-undo .
  define variable v-proc-run-order  as character no-undo .
  define variable v-proc-client     as character no-undo .

  do
  on error undo, return error return-value
  :
    run value(p-proc-name) in p-proc-handle
      (output v-c-point         /* p-call-point      */
      ,output v-proc-name       /* p-proc-name       */
      ,output v-proc-file       /* p-proc-file       */
      ,output v-proc-install    /* p-install         */
      ,output v-mainmenu-handle /* p-mainmenu-handle */
      ,output v-proc-db-ver     /* p-db-ver          */
      ,output v-proc-run-order  /* p-run-order       */
      ,output v-proc-client     /* p-client          */
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры создания пункта меню" p-proc-name skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      /* ошибку не возвращаем */
      /* это нормальное поведение программы */
      undo, return .
    end.
    if v-proc-client = "":U
      or caps( p-curr-sys-key ) = {&SuperSysKey}
      or check-entry-with-mask( p-curr-sys-key, v-proc-client, {&comma-char} ) = true
    then do:
      create buf_br-proc .
      assign
        buf_br-proc.proc-index      = p-index
        buf_br-proc.c-point         = v-c-point
        buf_br-proc.proc-name       = v-proc-name
        buf_br-proc.proc-file       = v-proc-file
        buf_br-proc.proc-install    = v-proc-install
        buf_br-proc.mainmenu-handle = v-mainmenu-handle
        buf_br-proc.proc-db-ver     = v-proc-db-ver
        buf_br-proc.proc-run-order  = v-proc-run-order
        buf_br-proc.proc-client     = v-proc-client
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-menubrsw  _DEFAULT-DISABLE
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
  HIDE FRAME d-menubrsw.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-menubrsw  _DEFAULT-ENABLE
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
  DISPLAY find-name find-file
      WITH FRAME d-menubrsw.
  ENABLE br-proc b-quit b-sel i-exit b-help find-name find-file
      WITH FRAME d-menubrsw.
  VIEW FRAME d-menubrsw.
  {&OPEN-BROWSERS-IN-QUERY-d-menubrsw}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-br-proc-table d-menubrsw
PROCEDURE load-br-proc-table :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  def var v-handle  as handle no-undo .
  def var v-handle2 as handle no-undo .

  define variable v-curr-sys-key as character no-undo .

  { gbl/currsysk.i
    v-curr-sys-key
    no-error
  }
  run gbl/menuload.p persistent set v-handle .
  run gbl/menuloa2.p persistent set v-handle2 .

  def var v-ind           as integer   no-undo .
  def var v-internal-proc  as character no-undo .
  def var v-internal-proc2 as character no-undo .
  define variable v-ord-index as integer   no-undo .


  define variable v-internal-entry-order-normal as logical   no-undo .
  define variable v-num-entries-internal-proc   as integer   no-undo .

  run gbl/int-ent.p
    (output v-internal-entry-order-normal
    ).

  assign
    v-internal-proc = v-handle :internal-entries
    v-internal-proc2 = v-handle2 :internal-entries
  .

  assign
    v-num-entries-internal-proc = num-entries(v-internal-proc)
  .
    if v-internal-entry-order-normal = true
  then do:
    do v-ind = 1 to v-num-entries-internal-proc by 1
    :
      assign
        v-ord-index = v-ord-index + 1
      .
      if entry(1, entry(v-ind, v-internal-proc), "%") = c-point then do:
        run create-br-proc in this-procedure
          ( input v-ord-index                   /* p-index       */
          , input entry(v-ind, v-internal-proc) /* p-proc-name   */
          , input v-handle                      /* p-proc-handle */
          , input v-curr-sys-key
          ) .
      end.
    end.
  end.
  else do:
    do v-ind = v-num-entries-internal-proc to 1 by -1
    :
      assign
        v-ord-index = v-ord-index + 1
      .
      if entry(1, entry(v-ind, v-internal-proc), "%") = c-point then do:
        run create-br-proc in this-procedure
          ( input v-ord-index                   /* p-index       */
          , input entry(v-ind, v-internal-proc) /* p-proc-name   */
          , input v-handle                      /* p-proc-handle */
          , input v-curr-sys-key
        ) .
      end.
    end.
  end.
  assign
    v-num-entries-internal-proc = num-entries(v-internal-proc2)
  .
    if v-internal-entry-order-normal = true
  then do:
    do v-ind = 1 to v-num-entries-internal-proc by 1
    :
      assign
        v-ord-index = v-ord-index + 1
      .
      if entry(1, entry(v-ind, v-internal-proc2), "%") = c-point then do:
        run create-br-proc in this-procedure
          ( input v-ord-index                    /* p-index       */
          , input entry(v-ind, v-internal-proc2) /* p-proc-name   */
          , input v-handle2                      /* p-proc-handle */
          , input v-curr-sys-key
          ) .
      end.
    end.
  end.
  else do:
    do v-ind = v-num-entries-internal-proc to 1 by -1
    :
      assign
        v-ord-index = v-ord-index + 1
      .
      if entry(1, entry(v-ind, v-internal-proc2), "%") = c-point then do:
        run create-br-proc in this-procedure
          ( input v-ord-index                    /* p-index       */
          , input entry(v-ind, v-internal-proc2) /* p-proc-name   */
          , input v-handle2                      /* p-proc-handle */
          , input v-curr-sys-key
          ) .
      end.
    end.
  end.

  delete procedure v-handle .
  delete procedure v-handle2.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME