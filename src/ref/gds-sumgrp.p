block-level on error undo, throw.
&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-sum-grp


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_sum-grp FOR ub.sum-grp.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-sum-grp
/*

$Revision: 31da2d7eacb9, 493, rls $
$Author: EShklyar $
$Date: Sun Feb 28 19:23:13 2016 +0400 $
$Workfile: gds-sumgrp.p $
$Archive: ref/gds-sumgrp.p $

Справочник групп товаров на кассах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns  as char   no-undo .
define input-output parameter p-rid-list    as  char no-undo . /* список recid'ов выбранных записей */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 31da2d7eacb9, 493, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: Sun Feb 28 19:23:13 2016 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: gds-sumgrp.p $":u .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-sumgrp.p $":u .
define variable vss-description as character no-undo init "Справочник групп товаров на кассах" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/obj-list.i new }
{ cmp/r-pril.i new}
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable dops as character no-undo.
define variable dopst as character no-undo.
define variable glog as logical no-undo .
DEFINE VARIABLE dgrpr-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define buffer b_sum-grp for ub.sum-grp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-sum-grp
&Scoped-define BROWSE-NAME br-sumgrps

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_sum-grp

/* Definitions for BROWSE br-sumgrps                                    */
&Scoped-define FIELDS-IN-QUERY-br-sumgrps if lookup(string(recid(X_sum-grp)), v-rid-list) > 0 then "*" else "":U X_sum-grp.grp-code X_sum-grp.grp-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-sumgrps
&Scoped-define SELF-NAME br-sumgrps
&Scoped-define QUERY-STRING-br-sumgrps FOR EACH X_sum-grp NO-LOCK     BY X_sum-grp.grp-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-sumgrps OPEN QUERY {&SELF-NAME} FOR EACH X_sum-grp NO-LOCK     BY X_sum-grp.grp-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-sumgrps X_sum-grp
&Scoped-define FIRST-TABLE-IN-QUERY-br-sumgrps X_sum-grp


/* Definitions for DIALOG-BOX d-sum-grp                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-sum-grp ~
    ~{&OPEN-QUERY-br-sumgrps}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-mark b-sel b-add b-chg b-del b-disc ~
b-hist b-print b-help mark-num br-sumgrps
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-disc
       MENU-ITEM m_lookup-disc  LABEL "Просмотр"
       MENU-ITEM m_update-disc  LABEL "Изменение"     .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1.

DEFINE BUTTON b-disc
     LABEL "&Скидки"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-hist
     LABEL "Истори&я"
     SIZE 3 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-print
     LABEL "П&ечать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор ":L
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.3 BY 1
     FGCOLOR 10  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-sumgrps FOR
      X_sum-grp SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-sumgrps
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-sumgrps d-sum-grp _FREEFORM
  QUERY br-sumgrps NO-LOCK DISPLAY
      if lookup(string(recid(X_sum-grp)), v-rid-list) > 0 then "*" else "":U FORMAT "X(1)":U
  X_sum-grp.grp-code FORMAT "999":U width 10
  X_sum-grp.grp-name COLUMN-LABEL "Наименование группы" FORMAT "X(65)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 80 BY 17
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-sum-grp
     b-quit AT ROW 1 COL 1
     b-mark AT ROW 1 COL 15
     b-sel AT ROW 1 COL 18
     b-add AT ROW 1 COL 28
     b-chg AT ROW 1 COL 38
     b-del AT ROW 1 COL 48
     b-disc AT ROW 1 COL 58 WIDGET-ID 2
     b-hist AT ROW 1 COL 73
     b-print AT ROW 1 COL 76
     b-help AT ROW 1 COL 79
     mark-num AT ROW 1.03 COL 9.1 COLON-ALIGNED NO-LABEL
     br-sumgrps AT ROW 2.9 COL 2.5
     SPACE(0.9) SKIP(0.3)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "ГРУППЫ ТОВАРОВ НА КАССАХ":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Temp-Tables and Buffers:
      TABLE: X_sum-grp B "?" ? ub sum-grp
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-sum-grp
   FRAME-NAME                                                           */
/* BROWSE-TAB br-sumgrps mark-num d-sum-grp */
ASSIGN
       FRAME d-sum-grp:SCROLLABLE       = FALSE.

ASSIGN
       b-disc:POPUP-MENU IN FRAME d-sum-grp       = MENU MENU-b-disc:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-sumgrps
/* Query rebuild information for BROWSE br-sumgrps
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_sum-grp NO-LOCK
    BY X_sum-grp.grp-code INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.sum-grp.grp-code|yes"
     _Query            is OPENED
*/  /* BROWSE br-sumgrps */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-sum-grp
/* Query rebuild information for DIALOG-BOX d-sum-grp
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-sum-grp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-sum-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-sum-grp d-sum-grp
ON END-ERROR OF FRAME d-sum-grp /* ГРУППЫ ТОВАРОВ НА КАССАХ */
OR ENDKEY OF FRAME {&frame-name} DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
    if error-status:error then return no-apply.
  run proc-send in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-sum-grp d-sum-grp
ON GO OF FRAME d-sum-grp /* ГРУППЫ ТОВАРОВ НА КАССАХ */
DO:
  p-rid-list = v-rid-list.
  run proc-send in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-sum-grp
ON CHOOSE OF b-add IN FRAME d-sum-grp /* Добавить */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-sum-grp
ON CHOOSE OF b-chg IN FRAME d-sum-grp /* Изменить */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del d-sum-grp
ON CHOOSE OF b-del IN FRAME d-sum-grp /* Удалить */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-disc d-sum-grp
ON CHOOSE OF b-disc IN FRAME d-sum-grp /* Скидки */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist d-sum-grp
ON CHOOSE OF b-hist IN FRAME d-sum-grp /* История */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark d-sum-grp
ON CHOOSE OF b-mark IN FRAME d-sum-grp /* * */
DO:
  if available X_sum-grp then do:
    { gbl/markstrn.i X_sum-grp v-rid-list }
    glog = br-sumgrps:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            glog = br-sumgrps:select-next-row ().
            apply "iteration-changed" to br-sumgrps in frame {&frame-name}.
      end.
    if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-sumgrps in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-sum-grp
ON CHOOSE OF b-print IN FRAME d-sum-grp /* Печать */
DO:

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-sum-grp
ON CHOOSE OF b-sel IN FRAME d-sum-grp /* Выбор  */
DO:
    if ( available X_sum-grp ) AND (( v-rid-list = "" ) or b-mark:sensitive = no) then
        v-rid-list = string( recid( X_sum-grp ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-sumgrps
&Scoped-define SELF-NAME br-sumgrps
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON DEFAULT-ACTION OF br-sumgrps IN FRAME d-sum-grp
DO:
  case yes:
      when  b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON INSERT-MODE OF br-sumgrps IN FRAME d-sum-grp
OR MOUSE-SELECT-DBLCLICK OF br-sumgrps
DO:
    if can-do(bttns, "b-mark") then
    apply "choose" to b-mark in frame {&frame-name} .
    else if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else dO:
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON MOUSE-SELECT-DBLCLICK OF br-sumgrps IN FRAME d-sum-grp
DO:
  if can-do( bttns, "b-sel" ) then do:
    apply "choose" to b-sel in frame {&frame-name} .
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-sumgrps d-sum-grp
ON RETURN OF br-sumgrps IN FRAME d-sum-grp
DO:
    if can-do( bttns, "b-sel" ) then
        apply "choose" to b-sel in frame {&frame-name} .
    else
         apply "DEFAULT-ACTION":U to self.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_lookup-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_lookup-disc d-sum-grp
ON CHOOSE OF MENU-ITEM m_lookup-disc /* Просмотр */
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_update-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_update-disc d-sum-grp
ON CHOOSE OF MENU-ITEM m_update-disc /* Изменение */
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-sum-grp


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   v-rid-list = p-rid-list.
   RUN enable_UI.
   HIDE mark-num in frame {&frame-name}.
   if v-rid-list <> "":U then do:
    assign
    rr = integer(v-rid-list) no-error .
    .
    if not error-status:error then do:
      reposition br-sumgrps to recid rr no-error .
    end.
    APPLY "ENTRY" to br-sumgrps.
   end.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-sum-grp  _DEFAULT-DISABLE
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
  HIDE FRAME d-sum-grp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-sum-grp
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
assign
b-disc:menu-mouse in frame {&frame-name} = 1
menu-item m_update-disc:sensitive in menu menu-b-disc = lookup("b-add", bttns) > 0 
.
ENABLE br-sumgrps b-quit
b-add WHEN lookup("b-add", bttns) > 0 and not transaction
b-del WHEN lookup("b-add", bttns) > 0 and not transaction
b-sel WHEN lookup("b-sel", bttns) > 0
b-chg WHEN lookup("b-add", bttns) > 0 and not transaction
b-disc WHEN lookup("b-add", bttns) > 0
b-mark when lookup("b-mark", bttns) > 0
b-hist
b-print
b-help
WITH FRAME {&FRAME-NAME}.
{&OPEN-BROWSERS-IN-QUERY-d-sum-grp}
APPLY "ENTRY" to br-sumgrps.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE grp-sending d-sum-grp
PROCEDURE grp-sending :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*define input parameter p-action as character no-undo .                        */
/*if NOT send-ref  then return.                                                 */
/*define variable p-var as integer no-undo .                                    */
/*FIND FIRST obj-list WHERE                                                     */
/*           obj-list.obj-code = b_sum-grp.grp-code No-ERROR.                   */
/*IF NOT avail obj-list then do:                                                */
/*  find last obj-list  use-index pi no-error .                                 */
/*   if available obj-list then p-var = obj-list.obj-id + 1.                    */
/*                         else p-var = 1.                                      */
/*                                                                              */
/*  create obj-list.                                                            */
/*  assign                                                                      */
/*   obj-list.obj-code = b_sum-grp.GRP-code                                     */
/*   obj-list.obj-name = (if p-action = "D":U then "D":U else obj-list.obj-name)*/
/*   obj-list.obj-id   = p-var                                                  */
/*  .                                                                           */
/*end.                                                                          */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-send d-sum-grp
PROCEDURE proc-send :
/*define variable glog as logical no-undo .                                                       */
/*if can-find(first ub.cash-desk where ub.cash-desk.pos-type = {&cd-type-ibm}) AND                */
/*       can-find(first obj-list) then do:                                                        */
/*  message                                                                                       */
/*  "Переслать изменения справочника на кассы?"                                                   */
/*  view-as alert-box question buttons YES-NO update glog.                                        */
/*  if  glog then do:                                                                             */
/*    run str/diallog.w (                                                                         */
/*            input parparentproc                                                                 */
/*          , input this-procedure                                                                */
/*          , input "str/snd-grup.p":U                                                            */
/*          , input string(v-cntxt-db-num) /*(string(cli-shops.obj-code) + {&delim-par} + "R":U)*/*/
/*          , input no /*p-auto-go*/                                                              */
/*          , input "":U                                                                          */
/*          , input substitute("Отсылка групп товаров на кассы БД &1", v-cntxt-db-num )           */
/*      ) no-error.                                                                               */
/*  end.                                                                                          */
/*end.                                                                                            */
/*for each obj-list:                                                                              */
/*  delete obj-list.                                                                              */
/*end.                                                                                            */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME