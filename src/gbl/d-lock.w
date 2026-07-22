&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр заблокированных записей

Автор: Перваков Михаил Сергеевич
Дата создания: 08/17/00
Author: Mikhail Pervakov
Creation date: 08/17/00

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр заблокированных записей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }


/* Local Variable Definitions ---                                       */

DEF VAR sFindRecProgramName AS CHARACTER NO-UNDO.
def var s-loadlock-program  as character no-undo .

def var h-findrec-program   as handle no-undo .
def var h-loadlock-program   as handle no-undo .

DEFINE TEMP-TABLE temp-Lock NO-UNDO
  FIELD Lock_RecID     AS RECID     LABEL "RecId":u FORMAT "->>>>>>>>>>>>>>>9"
  FIELD Lock_TableName AS CHARACTER LABEL "Table Name":u FORMAT "x(30)"
  FIELD Lock_UserName  AS CHARACTER LABEL "User Name":u  format "x(20)"
  FIELD Lock_Flags     AS CHARACTER LABEL "Flags":u
  FIELD Lock_Type      as character LABEL "Type":u
.
{ gbl/cur-time.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-Lock

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 Lock_RecID Lock_TableName Lock_UserName Lock_Flags
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH temp-Lock NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH temp-Lock NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 temp-Lock
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 temp-Lock


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 BROWSE-1 FI-RecID b-find b-refresh ~
b-help b-exit FI-ScanTime
&Scoped-Define DISPLAYED-OBJECTS FI-RecID FI-ScanTime

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-find
     LABEL "Поис&к"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-refresh
     LABEL "&Обновить"
     SIZE 10 BY 1 TOOLTIP "Обновить список блокировок".

DEFINE VARIABLE FI-RecID AS INTEGER FORMAT ">,>>>,>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FI-ScanTime AS CHARACTER FORMAT "X(15)":U
     LABEL "Время сканирования"
      VIEW-AS TEXT
     SIZE 30.25 BY .63 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.5 BY 1.5.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      temp-Lock SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      Lock_RecID
      Lock_TableName
      Lock_UserName
      Lock_Flags
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 76.5 BY 11.75
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     BROWSE-1 AT ROW 2.04 COL 1
     FI-RecID AT ROW 14.17 COL 6.25 COLON-ALIGNED NO-LABEL
     b-find AT ROW 14.17 COL 23.5
     b-refresh AT ROW 14.17 COL 37.75
     b-help AT ROW 14.17 COL 57.75
     b-exit AT ROW 14.17 COL 67.75
     FI-ScanTime AT ROW 1.25 COL 19 COLON-ALIGNED
     "Описание FLAGS: S - SHARE LOCK, X - EXCLUSIVE LOCK, L - LIMBO TRANSACTION" VIEW-AS TEXT
          SIZE 76.25 BY .5 AT ROW 15.75 COL 1.5
     "RecID:" VIEW-AS TEXT
          SIZE 5.75 BY .5 AT ROW 14.42 COL 2
     RECT-1 AT ROW 13.92 COL 1
     SPACE(45.99) SKIP(3.40)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заблокированные записи".


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
/* BROWSE-TAB BROWSE-1 RECT-1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-Lock NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заблокированные записи */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-find
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-find Dialog-Frame
ON CHOOSE OF b-find IN FRAME Dialog-Frame /* Поиск */
DO:
  DEF VAR v-recid AS INTEGER NO-UNDO.
  DEF VAR sTableName AS CHARACTER NO-UNDO.

  assign
    v-RecID = INTEGER(FI-RecID :SCREEN-VALUE)
  .
  run findrec in h-findrec-program
     (input v-recid)
     .
  assign
    sTableName = RETURN-VALUE
  .
  IF sTableName <> "" THEN DO:
    MESSAGE
      "Record with RECID '" v-recid "' is in table" SKIP
      "'" sTableName "'"
      VIEW-AS ALERT-BOX INFORMATION.
  END.
  ELSE DO:
    MESSAGE
      "Can not locate record with RECID '" v-RecID "'"
      VIEW-AS ALERT-BOX WARNING.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh Dialog-Frame
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame /* Обновить */
DO:
  RUN make-temp-table.
  {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON DEFAULT-ACTION OF BROWSE-1 IN FRAME Dialog-Frame
DO:
  /* */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FI-RecID
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL FI-RecID Dialog-Frame
ON RETURN OF FI-RecID IN FRAME Dialog-Frame
DO:
  apply "entry":u to b-find .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


  RUN make-temp-table.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

  if valid-handle(h-findrec-program) then do:
    delete procedure h-findrec-program .
  end.

  IF  sFindRecProgramName <> ?
  AND sFindRecProgramName <> '' THEN DO:
    OS-DELETE VALUE(sFindRecProgramName) NO-ERROR.
  END.

  if valid-handle(h-loadlock-program) then do:
    delete procedure h-loadlock-program .
  end.

  if  s-loadlock-program <> ?
  and s-loadlock-program <> "" then do:
    os-delete value(s-loadlock-program) no-error.
  end.

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
  DISPLAY FI-RecID FI-ScanTime
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 BROWSE-1 FI-RecID b-find b-refresh b-help b-exit FI-ScanTime
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-findrec-procedure Dialog-Frame
PROCEDURE make-findrec-procedure :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF VAR sTableName AS CHARACTER NO-UNDO.

  run gbl/_tmpfile.p ( "f":u , ".ped":u , OUTPUT sFindRecProgramName ).

  OUTPUT TO VALUE(sFindRecProgramName).

  PUT UNFORMATTED "procedure findrec : ":u + {&new-line}.
  PUT UNFORMATTED "DEF INPUT PARAMETER pRECID AS RECID NO-UNDO.":u + {&new-line}.

  define variable v-ind       as integer no-undo .
  define variable v-proc-ind  as integer   no-undo .
  define variable v-proc-name as character no-undo .

  assign
    v-proc-ind = 0
  .


  FOR EACH _File NO-LOCK
    WHERE _File._Tbl-Type <> 'V'
  :
    assign
      sTableName = _File._File-Name
    .

    assign
      v-ind = v-ind + 1 .
    .

    if v-ind modulo 100 = 0
    then do:
      assign
        v-proc-ind = v-proc-ind + 1
        v-proc-name = 'findrec':u + string(v-proc-ind)
      .

      PUT UNFORMATTED
          "  run " + v-proc-name + " in this-procedure (input pRECID) .":U + {&new-line}.
      PUT UNFORMATTED
          " RETURN return-value .":u + {&new-line}.
      PUT UNFORMATTED "end procedure.":u + {&new-line}.

      PUT UNFORMATTED "procedure " + v-proc-name + " : ":u + {&new-line}.
      PUT UNFORMATTED "DEF INPUT PARAMETER pRECID AS RECID NO-UNDO.":u + {&new-line}.
    end.

    PUT UNFORMATTED
        " FIND FIRST ":u + sTableName + " NO-LOCK":u
      + " WHERE RECID(":u + sTableName + ") = pRECID NO-ERROR.":u
      + " IF AVAIL ":u + sTableName + " THEN RETURN '":u + sTableName + "'.":u
      + {&new-line}
    .
  END.

  PUT UNFORMATTED
      " RETURN ''.":u + {&new-line}.
  PUT UNFORMATTED "end procedure.":u + {&new-line}.

  OUTPUT CLOSE.

  run value(sFindRecProgramName) persistent set h-findrec-program .


  run gbl/_tmpfile.p ( "f":u , ".ped":u , OUTPUT s-loadlock-program ) .


  output to value(s-loadlock-program) .


  PUT UNFORMATTED
      "DEFINE TEMP-TABLE temp-Lock NO-UNDO                                        ":u + {&new-line}
    + "  FIELD Lock_RecID     AS RECID     LABEL 'RecId'                          ":u + {&new-line}
    + "  FIELD Lock_TableName AS CHARACTER LABEL 'Table Name' FORMAT 'x(30)'      ":u + {&new-line}
    + "  FIELD Lock_UserName  AS CHARACTER LABEL 'User Name'                      ":u + {&new-line}
    + "  FIELD Lock_Flags     AS CHARACTER LABEL 'Flags'                          ":u + {&new-line}
    + "  FIELD Lock_Type      as character LABEL 'Type'                           ":u + {&new-line}
    + ".                                                                          ":u + {&new-line}
    + "                                                                           ":u + {&new-line}
    + "procedure fill-lock :                                                      ":u + {&new-line}
    + "  define output parameter table for temp-lock .                            ":u + {&new-line}
    + "                                                                           ":u + {&new-line}
    + "  def var ind as integer no-undo .                                         ":u + {&new-line}
    + "                                                                           ":u + {&new-line}
    + "  FOR EACH _UserLock NO-LOCK                                               ":u + {&new-line}
    + "    WHERE _UserLock._UserLock-Usr <> ?                                     ":u + {&new-line}
    + "  :                                                                        ":u + {&new-line}
    + "    do ind = 1 to extent(_UserLock._UserLock-Recid)                        ":u + {&new-line}
    + "    :                                                                      ":u + {&new-line}
    + "      if _UserLock._UserLock-Recid[ind] <> ? then do:                      ":u + {&new-line}
    + "        create temp-lock.                                                  ":u + {&new-line}
    + "        assign                                                             ":u + {&new-line}
    + "          temp-lock.lock_recid    = _UserLock._UserLock-Recid[ind]         ":u + {&new-line}
    + "          temp-lock.lock_username = string(_UserLock._UserLock-Usr) + ' '  ":u + {&new-line}
    + "                                  + _UserLock._UserLock-Name               ":u + {&new-line}
    + "          temp-lock.lock_flags    = _UserLock._UserLock-Flags[ind]         ":u + {&new-line}
    + "          temp-lock.Lock_Type     = _UserLock._UserLock-Type[ind]          ":u + {&new-line}
    + "        .                                                                  ":u + {&new-line}
    + "      end.                                                                 ":u + {&new-line}
    + "    end.                                                                   ":u + {&new-line}
    + "  END.                                                                     ":u + {&new-line}
    + "end procedure .                                                            ":u + {&new-line}
  .
  output close .

  run value (s-loadlock-program) persistent set h-loadlock-program .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-temp-table Dialog-Frame
PROCEDURE make-temp-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-today as date      no-undo .
  define variable v-time  as integer   no-undo .

  RUN make-findrec-procedure.

  FOR EACH temp-Lock:
    DELETE temp-Lock.
  END.

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).

  DO WITH FRAME {&FRAME-NAME}:
    ASSIGN
      FI-ScanTime:SCREEN-VALUE = '*** SCANNING ***'
      FI-ScanTime = STRING( v-time, "HH:MM:SS" )
    .
  END.

  if valid-handle (h-loadlock-program) then do:
/*    define variable v-start-time as int64     no-undo .*/
/*    assign*/
/*      v-start-time = etime*/
/*    .*/
    run fill-lock in h-loadlock-program
      (output table temp-lock
      ).
/*    message*/
/*      "Время сканирования" etime - v-start-time*/
/*      view-as alert-box error .*/
  end.
  else do:
    message
      "Невозможно получить информацию о блокировках"
      view-as alert-box error .
  end.

  for each temp-lock
  :
    run findrec in h-findrec-program (input temp-lock.lock_recid) no-error.
    assign
      temp-lock.lock_tablename = return-value
    .
  end.

  DO WITH FRAME {&FRAME-NAME}:
    ASSIGN
      FI-ScanTime:SCREEN-VALUE = FI-ScanTime
    .
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME