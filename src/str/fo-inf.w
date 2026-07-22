&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME tt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS tt
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация по обработке накладной в АРМ Взаиморасчеты

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 12/23/04

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter par-host-code as integer   no-undo .

define new shared variable next-prev as logical no-undo .
define new shared variable br-handle as handle  no-undo .
define new shared buffer buf_fin-liab for fin-ob .
define new shared buffer buf_fin-liab-before for fin-ob-before .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация по обработке накладной в АРМ Взаиморасчеты".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME tt
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES fin-ob-trn

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 fin-ob-trn.doc-code fin-ob-trn.ps
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH fin-ob-trn WHERE fin-ob-trn.trn-doc-code = trn-doc.doc-code ~
      AND fin-ob-trn.trn-doc-code = trn-doc.doc-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH fin-ob-trn WHERE fin-ob-trn.trn-doc-code = trn-doc.doc-code ~
      AND fin-ob-trn.trn-doc-code = trn-doc.doc-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 fin-ob-trn
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 fin-ob-trn


/* Definitions for DIALOG-BOX tt                                        */
&Scoped-define OPEN-BROWSERS-IN-QUERY-tt ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS trn-doc.need-expfo trn-doc.need-incfo ~
trn-doc.need-incorexpfo trn-doc.cr-expfo trn-doc.expfo-date ~
trn-doc.cr-incfo trn-doc.incfo-date trn-doc.cr-incorexpfo
&Scoped-define ENABLED-TABLES trn-doc
&Scoped-define FIRST-ENABLED-TABLE trn-doc
&Scoped-Define ENABLED-OBJECTS b-save B-exit B-Help FILL-IN-1 r-trn-doc ~
B-lkp BROWSE-2 B-lkp-2
&Scoped-Define DISPLAYED-FIELDS trn-doc.need-expfo trn-doc.need-incfo ~
trn-doc.need-incorexpfo trn-doc.cr-expfo trn-doc.expfo-date ~
trn-doc.cr-incfo trn-doc.incfo-date trn-doc.cr-incorexpfo
&Scoped-define DISPLAYED-TABLES trn-doc
&Scoped-define FIRST-DISPLAYED-TABLE trn-doc
&Scoped-Define DISPLAYED-OBJECTS FILL-IN-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Накладная"
     SIZE 10 BY 1 TOOLTIP "Просмотр накладной".

DEFINE BUTTON B-lkp-2
     LABEL "&Фин.Обяз."
     SIZE 10 BY 1 TOOLTIP "Просмотр ФО или ПФО".

DEFINE BUTTON b-save AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-trn-doc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Выбор из списка накладных".

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Введите № накладной"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      fin-ob-trn SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 tt _STRUCTURED
  QUERY BROWSE-2 NO-LOCK DISPLAY
      fin-ob-trn.doc-code COLUMN-LABEL "Номер ФО" FORMAT "9999999":U
            WIDTH 15
      fin-ob-trn.ps COLUMN-LABEL "..." FORMAT "X(20)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 40 BY 6.75 ROW-HEIGHT-CHARS .67 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME tt
     b-save AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 90.5
     FILL-IN-1 AT ROW 2.25 COL 24 COLON-ALIGNED
     r-trn-doc AT ROW 2.25 COL 47
     B-lkp AT ROW 2.25 COL 51
     BROWSE-2 AT ROW 12.25 COL 2
     B-lkp-2 AT ROW 12.25 COL 42.5
     trn-doc.need-expfo AT ROW 4.25 COL 47.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
     trn-doc.need-incfo AT ROW 5.25 COL 47.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
     trn-doc.need-incorexpfo AT ROW 6.25 COL 47.5 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
     trn-doc.cr-expfo AT ROW 7.25 COL 43 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 4 BY .67
     trn-doc.expfo-date AT ROW 7.25 COL 87 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
     trn-doc.cr-incfo AT ROW 8.25 COL 43 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 4 BY .67
     trn-doc.incfo-date AT ROW 8.25 COL 87 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 11 BY .67
     trn-doc.cr-incorexpfo AT ROW 9.25 COL 43 COLON-ALIGNED
           VIEW-AS TEXT
          SIZE 4 BY .67
     "Связи с ФО и с ПФО" VIEW-AS TEXT
          SIZE 37 BY .67 AT ROW 11.25 COL 2.5
          FGCOLOR 4
     SPACE(61.37) SKIP(8.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Информация по обработке накладной"
         DEFAULT-BUTTON b-save CANCEL-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX tt
                                                                        */
/* BROWSE-TAB BROWSE-2 B-lkp tt */
ASSIGN
       FRAME tt:SCROLLABLE       = FALSE
       FRAME tt:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _TblList          = "ub.fin-ob-trn WHERE ub.trn-doc <external> ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _JoinCode[1]      = "fin-ob-trn.trn-doc-code = trn-doc.doc-code"
     _Where[1]         = "fin-ob-trn.trn-doc-code = trn-doc.doc-code"
     _FldNameList[1]   > ub.fin-ob-trn.doc-code
"fin-ob-trn.doc-code" "Номер ФО" ? "integer" ? ? ? ? ? ? no ? no no "15" yes no no "U" "" ""
     _FldNameList[2]   > ub.fin-ob-trn.ps
"fin-ob-trn.ps" "..." ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX tt
/* Query rebuild information for DIALOG-BOX tt
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX tt */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME tt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt tt
ON GO OF FRAME tt /* Информация по обработке накладной */
DO:
  ASSIGN fill-in-1.


  FIND trn-doc NO-LOCK WHERE trn-doc.doc-code = fill-in-1 NO-ERROR.
  IF NOT AVAILABLE trn-doc  THEN DO:
      MESSAGE "Не найден документ с номером"  fill-in-1 error-status :get-message(1) view-as alert-box error.
      RETURN NO-APPLY.
  END.


DISPLAY ub.trn-doc.cr-expfo ub.trn-doc.cr-incfo ub.trn-doc.cr-incorexpfo ub.trn-doc.expfo-date ub.trn-doc.incfo-date ub.trn-doc.need-expfo ub.trn-doc.need-incfo ub.trn-doc.need-incorexpfo
with frame {&frame-name} .
{&OPEN-QUERY-{&BROWSE-NAME}}

  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt tt
ON WINDOW-CLOSE OF FRAME tt /* Информация по обработке накладной */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help tt
ON CHOOSE OF B-Help IN FRAME tt /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp tt
ON CHOOSE OF B-lkp IN FRAME tt /* Накладная */
DO:
   if available trn-doc then
      run str/fishdoc.p
               ( ParParentProc,
                 par-host-code ,
                 trn-doc.obj-type,
                 trn-doc.obj-code,
                 trn-doc.doc-code , ? ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp-2 tt
ON CHOOSE OF B-lkp-2 IN FRAME tt /* Фин.Обяз. */
DO:
   IF not available  fin-ob-trn then return .
define variable p-doc-type   as character no-undo .
define variable  p-status_   as character no-undo .

define buffer buf_fin-ob   for fin-ob .
define buffer buf_fin-ob-before   for fin-ob-before  .
define variable g-log as logical no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_lookup':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
define variable rr as recid no-undo .


find first buf_fin-ob no-lock where buf_fin-ob.doc-code = fin-ob-trn.doc-code no-error .
    if available buf_fin-ob then do:
        rr = recid( buf_fin-ob ).
        p-doc-type = buf_fin-ob.doc-type .
        p-status_  = buf_fin-ob.status_  .
        br-handle = ? .
        next-prev = ? .
        find first buf_fin-liab no-lock where recid(buf_fin-liab) = rr no-error .
        run str/fi-liabi.w
         ( input  parParentProc,
           input {&lookup} ,
           input-output rr ,
           input par-host-code  ,
           input p-doc-type,
           input p-status_
           ).
     end.
   else do:
   /* ПФО */
      find first buf_fin-ob-before no-lock where buf_fin-ob-before.before-code = fin-ob-trn.doc-code no-error .
      if not available  buf_fin-ob-before  then return.
        rr = recid( buf_fin-ob-before ).
        p-doc-type = buf_fin-ob-before.doc-type .
        p-status_  = buf_fin-ob-before.status_  .
        br-handle = ? .
        next-prev = ? .
        find first buf_fin-liab-before no-lock where recid(buf_fin-liab-before) = rr no-error .
          run str/fi-liabb.w
          ( input parParentProc ,
            input {&lookup} ,
            input-output rr ,
            input par-host-code ,
            input p-doc-type ,
            input p-status_
            ).
        if br-handle = ? then reposition {&browse-name} to recid rr no-error.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME FILL-IN-1
&Scoped-define SELF-NAME r-trn-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-trn-doc tt
ON CHOOSE OF r-trn-doc IN FRAME tt
DO:
define variable  v-list-mode AS CHAR  NO-UNDO.
define variable  loc-ref-list AS CHAR NO-UNDO.
define variable v-obj-type as character no-undo .
define variable v-obj-code  as integer no-undo .
define buffer b#clients for clients.
define variable v-host-name as character no-undo .
define variable v-input-output as character no-undo .

find first b#clients WHERE
      b#clients.obj-code = par-host-code and
      b#clients.obj-type = {&cmp}
      No-LOCK No-ERROR.

v-host-name = b#clients.obj-name .



assign
  v-obj-type = v-cntxt-obj-type
  v-obj-code = v-cntxt-obj-code
.

if v-obj-type = ""
or v-obj-type = ?
or v-obj-code = 0
or v-obj-code = ?
then do:
  define variable v-select-obj-type  as character no-undo .
  define variable v-select-obj-code  as integer   no-undo .
  define variable v-object-available as logical   no-undo .

end.


run str/all-docs.w
 ( input  parparentproc
 ,input par-host-code
 ,input v-cntxt-obj-type
 ,input v-cntxt-obj-code
 ,input  {&company}
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  "b-sel":U
 ,input  ?
 ,input  false
 ,input  ?
 ,output loc-ref-list
 ).


    find trn-doc where recid (trn-doc) = integer(loc-ref-list) no-lock no-error .

    if not available trn-doc then do:
      message "Накладная не выбрана."
              view-as alert-box error.
      return no-apply.
    end.
    FILL-IN-1 = trn-doc.doc-code.

    Display   FILL-IN-1
    with frame {&frame-name} .


apply "go" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK tt


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

{ gbl/getcntxt.i get }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_UI in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI tt  _DEFAULT-DISABLE
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
  HIDE FRAME tt.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI tt  _DEFAULT-ENABLE
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
  DISPLAY FILL-IN-1
      WITH FRAME tt.
  IF AVAILABLE trn-doc THEN
    DISPLAY trn-doc.need-expfo trn-doc.need-incfo trn-doc.need-incorexpfo
          trn-doc.cr-expfo trn-doc.expfo-date trn-doc.cr-incfo
          trn-doc.incfo-date trn-doc.cr-incorexpfo
      WITH FRAME tt.
  ENABLE b-save B-exit B-Help FILL-IN-1 r-trn-doc B-lkp BROWSE-2 B-lkp-2
         trn-doc.need-expfo trn-doc.need-incfo trn-doc.need-incorexpfo
         trn-doc.cr-expfo trn-doc.expfo-date trn-doc.cr-incfo
         trn-doc.incfo-date trn-doc.cr-incorexpfo
      WITH FRAME tt.
  VIEW FRAME tt.
  {&OPEN-BROWSERS-IN-QUERY-tt}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME