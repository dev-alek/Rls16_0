&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-add-ext-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-add-ext-client
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ввод данных для нового клиента во внешнем классификаторе соответствия контрагентов

Автор: Самков Сергей Васильевич
Дата создания: 14/05/2012
Author: Samkov Sergey
Creation date: 14/05/2012

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT  PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE OUTPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-obj-code AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-ext-obj-type AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-ext-obj-code AS integer NO-UNDO.
/*DEFINE OUTPUT PARAMETER p-db-num    AS integer NO-UNDO.*/
DEFINE OUTPUT PARAMETER p-Ok        AS logical NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Ввод данных для нового клиента во внешнем классификаторе соответствия контрагентов" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }

define variable ref-list as character no-undo.
define variable v-rec as recid no-undo .

define buffer buf_db for ub.db.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-add-ext-client

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit B-help fi-obj-type fi-obj-code ~
b-choose-client fi-ext-obj-type fi-ext-obj-code b-choose-contragent ~
/*b-choose-db*/
&Scoped-Define DISPLAYED-OBJECTS fi-obj-type fi-obj-code fi-ext-obj-type ~
fi-ext-obj-code /*fi-db-num*/

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-client
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-client"
     SIZE 3 BY 1.

DEFINE BUTTON b-choose-contragent
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-contragent"
     SIZE 3 BY 1.

/*DEFINE BUTTON b-choose-db*/
/*     IMAGE-UP FILE "btn-down-arrow":U*/
/*     IMAGE-DOWN FILE "btn-down-arrow":U*/
/*     IMAGE-INSENSITIVE FILE "btn-down-arrow":U*/
/*     LABEL "b-choose-db"*/
/*     SIZE 3 BY 1.*/

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/*DEFINE VARIABLE fi-db-num AS INTEGER FORMAT ">>>>9" INITIAL 0*/
/*     LABEL "Номер БД"*/
/*     VIEW-AS FILL-IN*/
/*     SIZE 6 BY 1*/
/*     BGCOLOR 15 .*/

DEFINE VARIABLE fi-ext-obj-code AS INTEGER FORMAT ">>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 9.2 BY 1 TOOLTIP "Соответствующий код контрагента в ТН или другой системе"
     BGCOLOR 15 .

DEFINE VARIABLE fi-ext-obj-type AS CHARACTER FORMAT "X(3)"
     LABEL "Контрагент"
     VIEW-AS FILL-IN
     SIZE 4.2 BY 1 TOOLTIP "Соответствующий тип контрагента в ТН или другой системе"
     BGCOLOR 15 .

DEFINE VARIABLE fi-obj-code AS INTEGER FORMAT ">>>>>>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 9.2 BY 1 TOOLTIP "код клиента"
     BGCOLOR 15 .

DEFINE VARIABLE fi-obj-type AS CHARACTER FORMAT "X(3)"
     LABEL "Клиент в ТН"
     VIEW-AS FILL-IN
     SIZE 4.2 BY 1 TOOLTIP "тип клиента"
     BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-add-ext-client
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 50
     fi-obj-type AT ROW 2.43 COL 13 COLON-ALIGNED
     fi-obj-code AT ROW 2.43 COL 18 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     b-choose-client AT ROW 2.43 COL 29
     fi-ext-obj-type AT ROW 3.86 COL 13 COLON-ALIGNED
     fi-ext-obj-code AT ROW 3.86 COL 18 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     b-choose-contragent AT ROW 3.86 COL 29
/*     fi-db-num AT ROW 5.29 COL 13 COLON-ALIGNED*/
/*     b-choose-db AT ROW 5.29 COL 21*/
     SPACE(34.37) SKIP(1.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Соответствие контрагентов"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-add-ext-client
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-add-ext-client:SCROLLABLE       = FALSE
       FRAME d-add-ext-client:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-db-num IN FRAME d-add-ext-client
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-add-ext-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-add-ext-client d-add-ext-client
ON GO OF FRAME d-add-ext-client /* Соответствие контрагентов */
DO:
  define buffer buf_db for ub.db .
  define buffer buf_clients for ub.clients.

  assign
    fi-obj-type
    fi-obj-code
    fi-ext-obj-type
    fi-ext-obj-code
/*    fi-db-num*/
  .
  find first buf_clients no-lock
    where buf_clients.obj-type = fi-obj-type
      and buf_clients.obj-code = fi-obj-code
    no-error.
  if not avail buf_clients then do:
    message
      substitute( "Не возможно найти клиента &1 &2", fi-obj-type, string( fi-obj-code ) )
      view-as alert-box error .
    apply "entry" to fi-obj-type.
    return no-apply.
  end.
/*  find first buf_db no-lock*/
/*    where buf_db.db-num = fi-db-num*/
/*    no-error .*/
/*  if not avail buf_db then do:*/
/*    message*/
/*      substitute( "Не существует база &1", string( fi-db-num ) )*/
/*      view-as alert-box error .*/
/*    apply "entry" to fi-db-num.*/
/*    return no-apply.*/
/*  end.*/
  assign
    p-obj-type     = fi-obj-type
    p-obj-code     = fi-obj-code
    p-ext-obj-type = fi-ext-obj-type
    p-ext-obj-code = fi-ext-obj-code
/*    p-db-num       = fi-db-num*/
    p-Ok = yes
  .

 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-add-ext-client d-add-ext-client
ON WINDOW-CLOSE OF FRAME d-add-ext-client /* Соответствие контрагентов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-client
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-client d-add-ext-client
ON CHOOSE OF b-choose-client IN FRAME d-add-ext-client /* b-choose-client */
DO:
  run ref/cli-all.w
  ( parparentproc
    , input  "b-sel"
    , ?
    , ?
    , ?
    , ?
    , ?
    , ?
  ,output ref-list
  ).
  If ref-list <> "" then do :
    find first ub.clients no-lock
      where recid(ub.clients) = integer(ref-list) no-error.
    if available ub.clients then do with frame {&frame-name}:
      assign
        fi-obj-type = ub.clients.obj-type
        fi-obj-code = ub.clients.obj-code
      .
      display fi-obj-type fi-obj-code.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choose-contragent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-contragent d-add-ext-client
ON CHOOSE OF b-choose-contragent IN FRAME d-add-ext-client /* b-choose-contragent */
DO:
  run ref/cli-all.w
  ( parparentproc
    , input  "b-sel"
    , ?
    , ?
    , ?
    , ?
    , ?
    , ?
  ,output ref-list
  ).
  If ref-list <> "" then do :
    find first ub.clients no-lock
         where recid(ub.clients) = integer(ref-list) no-error.
    if available ub.clients then do with frame {&frame-name}:
      assign
        fi-ext-obj-type = ub.clients.obj-type
        fi-ext-obj-code = ub.clients.obj-code
      .
      display fi-ext-obj-type fi-ext-obj-code.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*&Scoped-define SELF-NAME b-choose-db*/
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choose-db d-add-ext-client*/
/*ON CHOOSE OF b-choose-db IN FRAME d-add-ext-client /* b-choose-db */*/
/*DO:*/
/*  run adm/dbs.w ( input parParentProc*/
/*                , input {&lookup}*/
/*                , output v-rec ) no-error.*/
/*  if v-rec = ? then return.*/
/*  find first buf_db no-lock*/
/*    where recid(buf_db) = v-rec no-error .*/
/*  if avail buf_db then do with frame {&frame-name}:*/
/*    fi-db-num = buf_db.db-num.*/
/*    display fi-db-num.*/
/*  end.*/
/*END.*/

/*/* _UIB-CODE-BLOCK-END */*/
/*&ANALYZE-RESUME*/


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-add-ext-client
ON CHOOSE OF b-quit IN FRAME d-add-ext-client /* Отмена */
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-add-ext-client


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
  RUN MyEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-add-ext-client  _DEFAULT-DISABLE
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
  HIDE FRAME d-add-ext-client.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-add-ext-client  _DEFAULT-ENABLE
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
  DISPLAY fi-obj-type fi-obj-code fi-ext-obj-type fi-ext-obj-code /*fi-db-num*/
      WITH FRAME d-add-ext-client.
  ENABLE b-exit b-quit B-help fi-obj-type fi-obj-code b-choose-client
         fi-ext-obj-type fi-ext-obj-code b-choose-contragent /*b-choose-db*/
      WITH FRAME d-add-ext-client.
  VIEW FRAME d-add-ext-client.
  {&OPEN-BROWSERS-IN-QUERY-d-add-ext-client}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable d-add-ext-client
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    DISPLAY
    fi-obj-type fi-obj-code fi-ext-obj-type fi-ext-obj-code /*fi-db-num*/
    WITH FRAME d-add-ext-client.
  ENABLE
  B-exit
  B-quit
  B-Help
  fi-obj-type fi-obj-code b-choose-client fi-ext-obj-type fi-ext-obj-code b-choose-contragent /*fi-db-num b-choose-db*/
  WITH FRAME d-add-ext-client.
  VIEW FRAME d-add-ext-client.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME