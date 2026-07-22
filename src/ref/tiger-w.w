&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Справочник весов и кодов тары

Автор: Бахтадзе Наталья Викторовна
Дата создания: 19/06/03
Author: Bakhtadze Natalya
Creation date: 19/06/03

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-db-num like ub.scales-attr.db-num no-undo.
define input parameter p-scales-num like ub.scales-attr.scales-num no-undo.
define input-output parameter p-value as character no-undo.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Справочник весов и кодов тары".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i }

define temp-table temp-tare no-undo
field tare-id as integer format "99"
field weight as decimal format ">,>>9.999"
index pi is unique
primary
tare-id
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-kat

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-tare

/* Definitions for BROWSE BR-kat                                        */
&Scoped-define FIELDS-IN-QUERY-BR-kat temp-tare.tare-id temp-tare.weight
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-kat temp-tare.weight
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-kat~
 ~{&FP1}weight ~{&FP2}weight ~{&FP3}
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-kat temp-tare
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-kat temp-tare
&Scoped-define SELF-NAME BR-kat
&Scoped-define OPEN-QUERY-BR-kat OPEN QUERY {&SELF-NAME} FOR EACH temp-tare.
&Scoped-define TABLES-IN-QUERY-BR-kat temp-tare
&Scoped-define FIRST-TABLE-IN-QUERY-BR-kat temp-tare


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-kat}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help v-tare-id BR-kat B-add ~
B-del
&Scoped-Define DISPLAYED-OBJECTS v-tare-id

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

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

DEFINE VARIABLE v-tare-id AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Код тары"
     VIEW-AS FILL-IN
     SIZE 8.88 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-kat FOR
      temp-tare SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-kat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-kat Dialog-Frame _FREEFORM
  QUERY BR-kat DISPLAY
      temp-tare.tare-id COLUMN-LABEL "Код тары"
temp-tare.weight COLUMN-LABEL "Вес тары"
ENABLE temp-tare.weight
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 20.75 BY 10.63.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 21
     v-tare-id AT ROW 2.29 COL 1.75
     BR-kat AT ROW 3.38 COL 1.75
     B-add AT ROW 3.58 COL 22.75
     B-del AT ROW 5.58 COL 22.75
     SPACE(0.62) SKIP(7.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Веса и коды тары"
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
/* BROWSE-TAB BR-kat v-tare-id Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-tare-id IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-kat
/* Query rebuild information for BROWSE BR-kat
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-tare.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-kat */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Категории скидок - % скидки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
{ gbl/stdbtn.i }
  define variable v-rec as recid no-undo.
  define buffer buf_temp-tare for temp-tare.
    assign
    v-tare-id
    .
    if v-tare-id = 0 or
       v-tare-id > 16 or
       can-find(first buf_temp-tare no-lock where
                      buf_temp-tare.tare-id = v-tare-id) then do:
        bell.
        return no-apply.
    end.
    create buf_temp-tare.
    assign
     buf_temp-tare.tare-id = v-tare-id
     v-rec = recid(buf_temp-tare)
     .
     release buf_temp-tare.
     assign
           v-tare-id = 0
           .
           display
           v-tare-id
           with frame {&frame-name}.

     {&OPEN-QUERY-{&BROWSE-NAME}}
     reposition br-kat to recid  v-rec no-error.
     apply "ENTRY" to br-kat.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
  define buffer buf_temp-tare for temp-tare.
  if not avail temp-tare then return no-apply.
  find first buf_temp-tare where
            recid(buf_temp-tare) = recid(temp-tare) no-error.
  if avail buf_temp-tare then do:
     delete buf_temp-tare.
  end.
  {&OPEN-QUERY-{&BROWSE-NAME}}
  APPLY "ENTRY" to br-kat.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
  run proc-go in this-procedure no-error.
    if error-status:error then do:
    message error-status:error error-status:get-message(1) view-as alert-box .
    return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-kat
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
   run fill-table in this-procedure.
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
  DISPLAY v-tare-id
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help v-tare-id BR-kat B-add B-del
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable ii as integer no-undo.
define variable v-tare-id as integer no-undo.
define variable v-weight as decimal no-undo.
define variable v-dop as character no-undo.


for each temp-tare:
    delete temp-tare.
end.
if p-value = "":U then do:
  do ii = 1 to 16:
    create temp-tare.
    assign
    temp-tare.tare-id = ii
    temp-tare.weight = 0
    .
  end.
end.

if p-value <> "":U then dops = p-value.
/*такой параметр есть или на входе есть переменная- разберем по косточкам*/
do ii = 1 to num-entries(dops, ";":U):
    assign
    v-dop = entry(ii, dops, ";":U)
    v-tare-id = 0
    v-tare-id = integer(entry(1, v-dop, "=":U))
    v-weight = 0
    v-weight =  decimal(entry(2, v-dop, "=":U))
    no-error
    .
    if error-status:error then do:

    end.
    else do:
        create temp-tare.
        assign
        temp-tare.tare-id = v-tare-id
        temp-tare.weight = v-weight
        .
    end.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table-zero Dialog-Frame
PROCEDURE fill-table-zero :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii as integer no-undo.

do ii = 1 to 10:

  create temp-tare.
    assign
    temp-tare.tare-id = ii
    temp-tare.weight = 0
    .

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-go Dialog-Frame
PROCEDURE proc-go :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value as character no-undo.
define variable v-dop as character no-undo.
define variable ii as integer no-undo.

for each temp-tare no-lock:
  assign
  v-dop = string(temp-tare.tare-id) + "=":U + string(temp-tare.weight)
  v-value = v-value + (if v-value = "":U then "":U else ";":U) + v-dop
  .
  ii = ii + 1 .
end.
if ii > 16 then  do:
  message
  "Нельзя задать более 16 соответствий"
  view-as alert-box error .
  return error.
end.
assign
p-value = v-value.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME