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

Запуск имеющихся отложенных заданий отсылки на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/08/03
Author: Bakhtadze Natalya
Creation date: 08/08/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type LIKE ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code LIKE ub.clients.obj-code no-undo .
define input-output parameter p-gds as logical no-undo .
define input-output parameter p-dcard as logical no-undo .
define input-output parameter p-seller as logical no-undo .
define input-output parameter p-cashier as logical no-undo .
define input-output parameter p-fgrp as logical no-undo .
define input parameter p-gds-note as character no-undo .
define input parameter p-dcard-note as character no-undo .
define input parameter p-seller-note as character no-undo .
define input parameter p-cashier-note as character no-undo .
define input parameter p-fgrp-note as character no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск имеющихся отложенных заданий отсылки на кассу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cd-attr.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help T-gds E-gds T-dcard ~
E-dcard T-seller E-seller T-cashier E-cashier T-fgrp E-fgrp
&Scoped-Define DISPLAYED-OBJECTS T-gds E-gds T-dcard E-dcard T-seller ~
E-seller T-cashier E-cashier T-fgrp E-fgrp t-maria

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

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE E-cashier AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 60.5 BY 2.79 NO-UNDO.

DEFINE VARIABLE E-dcard AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 60.5 BY 2.79 NO-UNDO.

DEFINE VARIABLE E-fgrp AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 60.5 BY 2.79 NO-UNDO.

DEFINE VARIABLE E-gds AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 60.5 BY 2.79 NO-UNDO.

DEFINE VARIABLE E-seller AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 60.5 BY 2.79 NO-UNDO.

DEFINE VARIABLE T-cashier AS LOGICAL INITIAL no
     LABEL "Кассиры"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE T-dcard AS LOGICAL INITIAL no
     LABEL "Клиенты (дисконтные карты)"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE T-fgrp AS LOGICAL INITIAL no
     LABEL "Группы блюд"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE T-gds AS LOGICAL INITIAL no
     LABEL "Товары"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE t-maria AS LOGICAL INITIAL no
     LABEL "Товары на кассе МАРКЕТЕР/МАРИЯ"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.

DEFINE VARIABLE T-seller AS LOGICAL INITIAL no
     LABEL "Продавцы"
     VIEW-AS TOGGLE-BOX
     SIZE 30 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 41
     T-gds AT ROW 2.29 COL 1.75
     E-gds AT ROW 2.33 COL 37.13 NO-LABEL
     T-dcard AT ROW 5.29 COL 1.75
     E-dcard AT ROW 5.33 COL 37.13 NO-LABEL
     T-seller AT ROW 8.29 COL 1.75
     E-seller AT ROW 8.33 COL 37.13 NO-LABEL
     T-cashier AT ROW 11.29 COL 1.75
     E-cashier AT ROW 11.33 COL 37.13 NO-LABEL
     T-fgrp AT ROW 14.29 COL 1.75
     E-fgrp AT ROW 14.33 COL 37.13 NO-LABEL
     t-maria AT ROW 17.29 COL 1.75
     SPACE(67.24) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отложенные задания для пересылки на кассу"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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
       E-cashier:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       E-dcard:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       E-fgrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       E-gds:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       E-seller:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR TOGGLE-BOX t-maria IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Отложенные задания для пересылки на кассу */
DO:
  assign
  T-cashier
  T-dcard
  T-gds
  T-seller
  T-fgrp
  p-cashier =  T-cashier
  p-dcard = T-dcard
  p-gds = T-gds
  p-seller = T-seller
  p-fgrp =  T-fgrp

  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Отложенные задания для пересылки на кассу */
DO:
  APPLY "END-ERROR":U TO SELF.
  return "error":U.
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
  { gbl/getcntxt.i get }
  if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
    message substitute("Невозможен Запуск имеющихся отложенных заданий отсылки на кассу в чужой БД&1" +
                       "БД текущего объекта &2, текущая БД &3"
                       , {&new-line}
                       , v-cntxt-db-num-obj
                       , v-cntxt-db-num)
    view-as alert-box error .
    return error.
  end.
  RUN MYenable.
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
  DISPLAY T-gds E-gds T-dcard E-dcard T-seller E-seller T-cashier E-cashier
          T-fgrp E-fgrp t-maria
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help T-gds E-gds T-dcard E-dcard T-seller E-seller
         T-cashier E-cashier T-fgrp E-fgrp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
define variable v-send-maria as logical no-undo .
define variable v-send as logical no-undo .
run str/mrkt-ts.p (input p-curr-obj-type
             ,input p-curr-obj-code
             ,input {&cd-type-maria}
             ,output v-send-maria) no-error .

assign
v-send = (if v-send-maria <> ?
          then v-send-maria
          else no)
.

assign
T-cashier = p-cashier
T-dcard  = p-dcard
T-gds  = p-gds
T-seller = p-seller
T-fgrp = p-fgrp
E-gds = p-gds-note
E-dcard = p-dcard-note
E-seller = p-seller-note
E-cashier = p-cashier-note
E-fgrp = p-fgrp-note
t-maria = v-send
.
DISPLAY
E-dcard E-cashier E-gds E-seller E-fgrp
T-gds
T-dcard
T-seller
T-cashier
T-fgrp
t-maria WHEN v-send <> ?
WITH FRAME {&frame-name}.

  ENABLE
  b-quit
  B-exit
  B-Help
  T-gds when p-gds
  T-dcard when p-dcard
  T-seller when p-seller
  T-cashier when p-cashier
  T-fgrp when p-fgrp
  E-gds when p-gds
  E-dcard when p-dcard
  E-seller when p-seller
  E-cashier when p-cashier
  E-fgrp when p-fgrp
   WITH FRAME {&frame-name}.
assign
p-gds = no
p-dcard = no
p-seller = no
p-cashier = no
p-fgrp = no
.
VIEW FRAME {&frame-name}.
IF v-send =? THEN DO:
    HIDE
    t-maria
    IN FRAME {&frame-name}.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME