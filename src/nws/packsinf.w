&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME packs-info


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X1_pck-rcvd-attr FOR ub.pck-rcvd-attr.
DEFINE BUFFER X1_pck-sent-attr FOR ub.pck-sent-attr.
DEFINE BUFFER X2_pck-rcvd-attr FOR ub.pck-rcvd-attr.
DEFINE BUFFER X2_pck-sent-attr FOR ub.pck-sent-attr.
DEFINE BUFFER X3_pck-rcvd-attr FOR ub.pck-rcvd-attr.
DEFINE BUFFER X3_pck-sent-attr FOR ub.pck-sent-attr.
DEFINE BUFFER X4_pck-rcvd-attr FOR ub.pck-rcvd-attr.
DEFINE BUFFER X4_pck-sent-attr FOR ub.pck-sent-attr.
DEFINE BUFFER X_pck-rcvd FOR ub.pck-rcvd.
DEFINE BUFFER X_pck-sent FOR ub.pck-sent.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS packs-info 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация о пакетах по заданной БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/03
Author: Dmitry Ukhanov
Creation date: 03/23/03

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-db-num    like ub.pck-sent.db-num    no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация о пакетах по заданной БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME packs-info
&Scoped-define BROWSE-NAME br-pck-rcvd

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_pck-rcvd X_pck-sent

/* Definitions for BROWSE br-pck-rcvd                                   */
&Scoped-define FIELDS-IN-QUERY-br-pck-rcvd X_pck-rcvd.pack-num ~
string(X_pck-rcvd.CreDate, "99/99/99") + " " + X_pck-rcvd.CreTime ~
X_pck-rcvd.CreNum ~
STRING (X_pck-rcvd.SendTxtDate, "99/99/99") + " " + X_pck-rcvd.SendTxtTime ~
STRING (X_pck-rcvd.BegImpDate, "99/99/99") + " " + X_pck-rcvd.BegImpTime ~
STRING (X_pck-rcvd.EndImpDate, "99/99/99") + " " + X_pck-rcvd.EndImpTime ~
X_pck-rcvd.total-recs 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pck-rcvd 
&Scoped-define QUERY-STRING-br-pck-rcvd FOR EACH X_pck-rcvd ~
      WHERE X_pck-rcvd.db-num = p-db-num NO-LOCK ~
    BY ub.X_pck-rcvd.db-num DESCENDING ~
       BY ub.X_pck-rcvd.pack-num DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-pck-rcvd OPEN QUERY br-pck-rcvd FOR EACH X_pck-rcvd ~
      WHERE X_pck-rcvd.db-num = p-db-num NO-LOCK ~
    BY ub.X_pck-rcvd.db-num DESCENDING ~
       BY ub.X_pck-rcvd.pack-num DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-pck-rcvd X_pck-rcvd
&Scoped-define FIRST-TABLE-IN-QUERY-br-pck-rcvd X_pck-rcvd


/* Definitions for BROWSE br-pck-sent                                   */
&Scoped-define FIELDS-IN-QUERY-br-pck-sent X_pck-sent.pack-num ~
STRING (X_pck-sent.CreDate, "99/99/99") + " " + X_pck-sent.CreTime ~
X_pck-sent.CreNum ~
STRING (X_pck-sent.SendTxtDate, "99/99/99") + " " + X_pck-sent.SendTxtTime ~
STRING (X_pck-sent.BegImpDate, "99/99/99") + " " + X_pck-sent.BegImpTime ~
STRING (X_pck-sent.EndImpDate, "99/99/99") + " " + X_pck-sent.EndImpTime ~
STRING (X_pck-sent.RcvdDate, "99/99/99") + " " + X_pck-sent.RcvdTime ~
X_pck-sent.total-recs 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pck-sent 
&Scoped-define QUERY-STRING-br-pck-sent FOR EACH X_pck-sent ~
      WHERE X_pck-sent.db-num = p-db-num NO-LOCK ~
    BY ub.X_pck-sent.db-num DESCENDING ~
       BY ub.X_pck-sent.pack-num DESCENDING INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-pck-sent OPEN QUERY br-pck-sent FOR EACH X_pck-sent ~
      WHERE X_pck-sent.db-num = p-db-num NO-LOCK ~
    BY ub.X_pck-sent.db-num DESCENDING ~
       BY ub.X_pck-sent.pack-num DESCENDING INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-pck-sent X_pck-sent
&Scoped-define FIRST-TABLE-IN-QUERY-br-pck-sent X_pck-sent


/* Definitions for DIALOG-BOX packs-info                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-packs-info ~
    ~{&OPEN-QUERY-br-pck-rcvd}~
    ~{&OPEN-QUERY-br-pck-sent}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help br-pck-sent br-pck-rcvd 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-pck-rcvd FOR 
      X_pck-rcvd SCROLLING.

DEFINE QUERY br-pck-sent FOR 
      X_pck-sent SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-pck-rcvd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pck-rcvd packs-info _STRUCTURED
  QUERY br-pck-rcvd NO-LOCK DISPLAY
      X_pck-rcvd.pack-num COLUMN-LABEL "Пакет" FORMAT ">>>>>>>>>9":U
      string(X_pck-rcvd.CreDate, "99/99/99") + " " + X_pck-rcvd.CreTime COLUMN-LABEL "Создан" FORMAT "X(17)":U
      X_pck-rcvd.CreNum COLUMN-LABEL "формир." FORMAT ">>>>>>9":U
      STRING (X_pck-rcvd.SendTxtDate, "99/99/99") + " " + X_pck-rcvd.SendTxtTime COLUMN-LABEL "Отправлен" FORMAT "X(17)":U
      STRING (X_pck-rcvd.BegImpDate, "99/99/99") + " " + X_pck-rcvd.BegImpTime COLUMN-LABEL "Начало разбора" FORMAT "X(17)":U
      STRING (X_pck-rcvd.EndImpDate, "99/99/99") + " " + X_pck-rcvd.EndImpTime COLUMN-LABEL "Окончание разбора" FORMAT "X(17)":U
      X_pck-rcvd.total-recs COLUMN-LABEL "Записей" FORMAT ">>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10.25
         TITLE "Принятые пакеты" FIT-LAST-COLUMN.

DEFINE BROWSE br-pck-sent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pck-sent packs-info _STRUCTURED
  QUERY br-pck-sent NO-LOCK DISPLAY
      X_pck-sent.pack-num COLUMN-LABEL "Пакет" FORMAT ">>>>>>>>>9":U
      STRING (X_pck-sent.CreDate, "99/99/99") + " " + X_pck-sent.CreTime COLUMN-LABEL "Создан" FORMAT "X(17)":U
      X_pck-sent.CreNum COLUMN-LABEL "Формир." FORMAT ">>>>>>9":U
      STRING (X_pck-sent.SendTxtDate, "99/99/99") + " " + X_pck-sent.SendTxtTime COLUMN-LABEL "Отправлен" FORMAT "X(17)":U
      STRING (X_pck-sent.BegImpDate, "99/99/99") + " " + X_pck-sent.BegImpTime COLUMN-LABEL "Начало разбора" FORMAT "X(17)":U
      STRING (X_pck-sent.EndImpDate, "99/99/99") + " " + X_pck-sent.EndImpTime COLUMN-LABEL "Окончание разбора" FORMAT "X(17)":U
      STRING (X_pck-sent.RcvdDate, "99/99/99") + " " + X_pck-sent.RcvdTime COLUMN-LABEL "Подтвержден" FORMAT "X(17)":U
      X_pck-sent.total-recs COLUMN-LABEL "Записей" FORMAT ">>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10.25
         TITLE "Отравленные пакеты".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME packs-info
     b-exit AT ROW 1 COL 2
     b-help AT ROW 1 COL 96
     br-pck-sent AT ROW 2.25 COL 1.5 WIDGET-ID 100
     br-pck-rcvd AT ROW 12.75 COL 1.5 WIDGET-ID 200
     SPACE(0.37) SKIP(0.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Дополнительная информация о пакете"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X1_pck-rcvd-attr B "?" ? ub pck-rcvd-attr
      TABLE: X1_pck-sent-attr B "?" ? ub pck-sent-attr
      TABLE: X2_pck-rcvd-attr B "?" ? ub pck-rcvd-attr
      TABLE: X2_pck-sent-attr B "?" ? ub pck-sent-attr
      TABLE: X3_pck-rcvd-attr B "?" ? ub pck-rcvd-attr
      TABLE: X3_pck-sent-attr B "?" ? ub pck-sent-attr
      TABLE: X4_pck-rcvd-attr B "?" ? ub pck-rcvd-attr
      TABLE: X4_pck-sent-attr B "?" ? ub pck-sent-attr
      TABLE: X_pck-rcvd B "?" ? ub pck-rcvd
      TABLE: X_pck-sent B "?" ? ub pck-sent
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX packs-info
   FRAME-NAME                                                           */
/* BROWSE-TAB br-pck-sent b-help packs-info */
/* BROWSE-TAB br-pck-rcvd br-pck-sent packs-info */
ASSIGN 
       FRAME packs-info:SCROLLABLE       = FALSE
       FRAME packs-info:HIDDEN           = TRUE.

ASSIGN 
       br-pck-sent:NUM-LOCKED-COLUMNS IN FRAME packs-info     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pck-rcvd
/* Query rebuild information for BROWSE br-pck-rcvd
     _TblList          = "X_pck-rcvd"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ", FIRST OUTER USED, FIRST OUTER USED, FIRST OUTER USED, FIRST OUTER"
     _OrdList          = "ub.X_pck-rcvd.db-num|no,ub.X_pck-rcvd.pack-num|no"
     _Where[1]         = "X_pck-rcvd.db-num = p-db-num"
     _FldNameList[1]   > Temp-Tables.X_pck-rcvd.pack-num
"pack-num" "Пакет" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"string(X_pck-rcvd.CreDate, ""99/99/99"") + "" "" + X_pck-rcvd.CreTime" "Создан" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.X_pck-rcvd.CreNum
"CreNum" "формир." ">>>>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"STRING (X_pck-rcvd.SendTxtDate, ""99/99/99"") + "" "" + X_pck-rcvd.SendTxtTime" "Отправлен" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"STRING (X_pck-rcvd.BegImpDate, ""99/99/99"") + "" "" + X_pck-rcvd.BegImpTime" "Начало разбора" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"STRING (X_pck-rcvd.EndImpDate, ""99/99/99"") + "" "" + X_pck-rcvd.EndImpTime" "Окончание разбора" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > Temp-Tables.X_pck-rcvd.total-recs
"total-recs" "Записей" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-pck-rcvd */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pck-sent
/* Query rebuild information for BROWSE br-pck-sent
     _TblList          = "X_pck-sent"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _TblOptList       = ", FIRST OUTER USED, FIRST OUTER USED, FIRST OUTER USED, FIRST OUTER USED"
     _OrdList          = "ub.X_pck-sent.db-num|no,ub.X_pck-sent.pack-num|no"
     _Where[1]         = "X_pck-sent.db-num = p-db-num"
     _FldNameList[1]   > Temp-Tables.X_pck-sent.pack-num
"X_pck-sent.pack-num" "Пакет" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"STRING (X_pck-sent.CreDate, ""99/99/99"") + "" "" + X_pck-sent.CreTime" "Создан" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.X_pck-sent.CreNum
"X_pck-sent.CreNum" "Формир." ">>>>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"STRING (X_pck-sent.SendTxtDate, ""99/99/99"") + "" "" + X_pck-sent.SendTxtTime" "Отправлен" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"STRING (X_pck-sent.BegImpDate, ""99/99/99"") + "" "" + X_pck-sent.BegImpTime" "Начало разбора" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"STRING (X_pck-sent.EndImpDate, ""99/99/99"") + "" "" + X_pck-sent.EndImpTime" "Окончание разбора" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   > "_<CALC>"
"STRING (X_pck-sent.RcvdDate, ""99/99/99"") + "" "" + X_pck-sent.RcvdTime" "Подтвержден" "X(17)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[8]   > Temp-Tables.X_pck-sent.total-recs
"X_pck-sent.total-recs" "Записей" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-pck-sent */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX packs-info
/* Query rebuild information for DIALOG-BOX packs-info
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX packs-info */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME packs-info
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL packs-info packs-info
ON WINDOW-CLOSE OF FRAME packs-info /* Дополнительная информация о пакете */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pck-rcvd
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK packs-info 


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  assign
    frame {&frame-name}:title = substitute( "Дополнительная информация о пакетах по БД &1", p-db-num )
  .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI packs-info  _DEFAULT-DISABLE
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
  HIDE FRAME packs-info.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI packs-info  _DEFAULT-ENABLE
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
  ENABLE b-exit b-help br-pck-sent br-pck-rcvd 
      WITH FRAME packs-info.
  VIEW FRAME packs-info.
  {&OPEN-BROWSERS-IN-QUERY-packs-info}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

