&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cli FOR clients.
DEFINE BUFFER for-c-gds-grp-hist FOR c-gds-grp-hist.
DEFINE BUFFER X_c-gds-grp-hist FOR c-gds-grp-hist.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник истории групп товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06
*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER bttns  as character  no-undo .
DEFINE INPUT PARAMETER p-mode as character no-undo.
/*{&all} или "gds-grp":U или "gds-grp-attr" или "gds-grp-obj" иkb tax-rate-gds-grp
или ("gds-grp-attr" + {&comma-char} + {&g___object})
или ("gds-grp-obj" + {&comma-char} + {&g___object})
или ("tax-rate-gds-grp" + {&comma-char} + {&g___object})
или ("gds-grp-attr" + {&comma-char} + "host")
или ("gds-grp-obj" + {&comma-char} + "host"})
или ("tax-rate-gds-grp" + {&comma-char} + "host")
или "gds-prt"

*/
DEFINE INPUT PARAMETER p-node-code like ub.c-gds-grp-hist.node-code no-undo.
DEFINE INPUT PARAMETER p-attr-code like ub.c-gds-grp-hist.attr-code no-undo.
DEFINE INPUT PARAMETER p-host-code like ub.c-gds-grp-hist.host-code no-undo.
DEFINE INPUT PARAMETER p-obj-type  like ub.c-gds-grp-hist.obj-type  no-undo.
DEFINE INPUT PARAMETER p-obj-code  like ub.c-gds-grp-hist.obj-code  no-undo.
define input parameter p-tax-code  like ub.c-gds-grp-hist.tax-code no-undo .
define input parameter p-is-del    as logical no-undo .
define input parameter p-subject   like ub.c-gds-grp-hist.subject no-undo .
DEFINE OUTPUT PARAMETER  P-rid-list    as  char no-undo . /* список recid'ов выбранных аписей */


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник истории групп товаров" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
{ ref/grp-attr.i }
{ cmp/mrk-strf.i }
{ gbl/usrfulnf.i }
{ gbl/fltopend.i defproc }
define variable v-rid-list as character no-undo .
define variable log-res as log no-undo.
define variable rr as recid no-undo.
define variable jj as integer no-undo .
define variable str as char no-undo.
define variable vartbl-name as char no-undo.
define variable varact      as char no-undo.
define variable filter-point0 as character no-undo init "cggrphis":U .
define variable filter-point as character no-undo init "cggrphis":U .
define variable filter-label as character no-undo init "История групп товаров":U .
define variable filter-label0 as character no-undo init "История групп товаров":U .
define variable sort-column-name as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer X_gds-grp for ub.gds-grp.
define buffer X_gds-prt for ub.gds-prt.
define buffer X_gds-grp-attr for ub.gds-grp-attr.
define buffer X_gds-grp-obj for ub.gds-grp-obj.
define buffer x_clients-obj for ub.clients.
define buffer X_sysconf for ub.sysconf.
define buffer X_tax for ub.tax.
{ ref/tmpchgs.i "NEW SHARED" }

&SCOPED-DEFINE hn-gds-grp-hist-code X_c-gds-grp-hist.subject
&SCOPED-DEFINE hn-0-gds-grp-hist-name  (if p-mode = {&table_gds-prt} then "Узел Шкалы" else {&hn-gds-grp-hist-name})

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-c-gds-grp-hist

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_c-gds-grp-hist temp-changes

/* Definitions for BROWSE BR-c-gds-grp-hist                             */
&Scoped-define FIELDS-IN-QUERY-BR-c-gds-grp-hist mark-string( recid(X_c-gds-grp-hist), v-rid-list ) X_c-gds-grp-hist.corr-date usrfulnf(X_c-gds-grp-hist.corr-user-name) X_c-gds-grp-hist.corr-user-db-num {&hn-0-gds-grp-hist-name} abs(X_c-gds-grp-hist.node-code) get-action(X_c-gds-grp-hist.action) string(X_c-gds-grp-hist.corr-time, "HH:MM") if X_c-gds-grp-hist.subject <> {&table_gds-grp} and X_c-gds-grp-hist.host-code > 0 then string(X_c-gds-grp-hist.host-code) else '':U if X_c-gds-grp-hist.subject <> {&table_gds-grp} and X_c-gds-grp-hist.obj-code > 0 then (X_c-gds-grp-hist.obj-type + string(X_c-gds-grp-hist.obj-code)) else '':U   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-c-gds-grp-hist   
&Scoped-define SELF-NAME BR-c-gds-grp-hist
&Scoped-define QUERY-STRING-BR-c-gds-grp-hist FOR EACH X_c-gds-grp-hist NO-LOCK
&Scoped-define OPEN-QUERY-BR-c-gds-grp-hist OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-grp-hist NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-c-gds-grp-hist X_c-gds-grp-hist
&Scoped-define FIRST-TABLE-IN-QUERY-BR-c-gds-grp-hist X_c-gds-grp-hist


/* Definitions for BROWSE BR-changes                                    */
&Scoped-define FIELDS-IN-QUERY-BR-changes temp-changes.l_name temp-changes.v_old temp-changes.v_new   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-changes   
&Scoped-define SELF-NAME BR-changes
&Scoped-define QUERY-STRING-BR-changes FOR EACH temp-changes
&Scoped-define OPEN-QUERY-BR-changes OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
&Scoped-define TABLES-IN-QUERY-BR-changes temp-changes
&Scoped-define FIRST-TABLE-IN-QUERY-BR-changes temp-changes


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-c-gds-grp-hist}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark b-sel B-sch B-Help mark-num ~
BR-c-gds-grp-hist BR-changes v-full-name-old v-full-name-new 
&Scoped-Define DISPLAYED-OBJECTS mark-num v-full-name-old v-full-name-new 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  (  p-action as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch 
     LABEL "&Фильтр" 
     SIZE 3 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор" 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-full-name-new AS CHARACTER FORMAT "X(256)":U 
     LABEL "Стало" 
     VIEW-AS FILL-IN 
     SIZE 91 BY 1 NO-UNDO.

DEFINE VARIABLE v-full-name-old AS CHARACTER FORMAT "X(256)":U 
     LABEL "Было" 
     VIEW-AS FILL-IN 
     SIZE 91 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-c-gds-grp-hist FOR 
      X_c-gds-grp-hist SCROLLING.

DEFINE QUERY BR-changes FOR 
      temp-changes SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-c-gds-grp-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-c-gds-grp-hist Dialog-Frame _FREEFORM
  QUERY BR-c-gds-grp-hist DISPLAY
      mark-string( recid(X_c-gds-grp-hist), v-rid-list ) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_c-gds-grp-hist.corr-date COLUMN-LABEL "Дата корр" FORMAT "99/99/9999":U
      usrfulnf(X_c-gds-grp-hist.corr-user-name) COLUMN-LABEL "Изменил" FORMAT "X(18)":U
      X_c-gds-grp-hist.corr-user-db-num COLUMN-LABEL "БД" FORMAT ">>>>9":U
            WIDTH 3
      {&hn-0-gds-grp-hist-name} COLUMN-LABEL "Предмет изменений" FORMAT "X(32)":U
      abs(X_c-gds-grp-hist.node-code) COLUMN-LABEL "Вн №" FORMAT ">,>>>,>>9":U
      get-action(X_c-gds-grp-hist.action) COLUMN-LABEL "Действие" FORMAT "X(10)":U
      string(X_c-gds-grp-hist.corr-time, "HH:MM") COLUMN-LABEL "Время!корр" FORMAT "X(5)":U
            WIDTH 6
      if X_c-gds-grp-hist.subject <> {&table_gds-grp} and X_c-gds-grp-hist.host-code > 0 then string(X_c-gds-grp-hist.host-code) else '':U COLUMN-LABEL "Фирма" FORMAT "X(5)":U
            WIDTH 6
      if X_c-gds-grp-hist.subject <> {&table_gds-grp} and X_c-gds-grp-hist.obj-code > 0 then
(X_c-gds-grp-hist.obj-type + string(X_c-gds-grp-hist.obj-code)) else '':U COLUMN-LABEL "Объект" FORMAT "X(9)":U
            WIDTH 10
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.25.

DEFINE BROWSE BR-changes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-changes Dialog-Frame _FREEFORM
  QUERY BR-changes DISPLAY
      temp-changes.l_name COLUMn-LABEL "Изменилось" format "X(40)"
temp-changes.v_old COLUMn-LABEL "Было" format "X(70)"
temp-changes.v_new COLUMn-LABEL "Стало" format "X(70)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     b-sel AT ROW 1 COL 14
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     mark-num AT ROW 1.92 COL 9 COLON-ALIGNED NO-LABEL
     BR-c-gds-grp-hist AT ROW 3 COL 1
     BR-changes AT ROW 14.5 COL 1
     v-full-name-old AT ROW 20 COL 2
     v-full-name-new AT ROW 21 COL 1
     SPACE(0.24) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Справочник истории групп товаров"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cli B "?" ? ub clients
      TABLE: for-c-gds-grp-hist B "?" ? ub c-gds-grp-hist
      TABLE: X_c-gds-grp-hist B "?" ? ub c-gds-grp-hist
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-c-gds-grp-hist mark-num Dialog-Frame */
/* BROWSE-TAB BR-changes BR-c-gds-grp-hist Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-c-gds-grp-hist:COLUMN-RESIZABLE IN FRAME Dialog-Frame       = TRUE.

/* SETTINGS FOR FILL-IN v-full-name-new IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-full-name-old IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-c-gds-grp-hist
/* Query rebuild information for BROWSE BR-c-gds-grp-hist
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_c-gds-grp-hist NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-c-gds-grp-hist */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-changes
/* Query rebuild information for BROWSE BR-changes
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-changes.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-changes */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Справочник истории групп товаров */
DO:
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник истории групп товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
define variable g#log as logical no-undo .
if not available X_c-gds-grp-hist then return no-apply.
  { gbl/markstrn.i X_c-gds-grp-hist v-rid-list }
  g#log = br-c-gds-grp-hist :refresh( )  in frame {&frame-name}.
  if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
          g#log = br-c-gds-grp-hist:select-next-row () in frame {&frame-name}.
          apply "value-changed" to br-c-gds-grp-hist in frame {&frame-name}.
  end.
  if num-entries (v-rid-list) = 0 then
      hide mark-num in frame {&frame-name}.
  else
  disp num-entries (v-rid-list) @ mark-num
  with frame {&frame-name}.
  apply "entry" to br-c-gds-grp-hist in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_c-gds-grp-hist ) AND ( v-rid-list = "" ) then
        v-rid-list = string( recid( X_c-gds-grp-hist ) ) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-c-gds-grp-hist
&Scoped-define SELF-NAME BR-c-gds-grp-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-gds-grp-hist Dialog-Frame
ON RETURN OF BR-c-gds-grp-hist IN FRAME Dialog-Frame
DO:
      apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-c-gds-grp-hist Dialog-Frame
ON VALUE-CHANGED OF BR-c-gds-grp-hist IN FRAME Dialog-Frame
DO:
  run proc-view-changes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-c-gds-grp-hist" }
{ gbl/setfltnm.i }
{ gbl/brwrefre.i "v-doc-rec = recid(X_c-gds-grp-hist). run openbr in this-procedure ( input yes, input no, input '':U). reposition br-c-gds-grp-hist to recid v-doc-rec no-error.
              APPLY 'VALUE-CHANGED' to br-c-gds-grp-hist. " }
{ gbl/brwrepos.i
&line-num=5
}
{ gbl/srt-clmd.i
  &browse-name    = "br-c-gds-grp-hist"
  &frame-name     = "{&frame-name}"
  &table-name     = "X_c-gds-grp-hist"
  &sort-clmn_1    = "X_c-gds-grp-hist.corr-date"
  &sort-clmn_2    = "X_c-gds-grp-hist.corr-user-db-num"
  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "no"
  &mv-brw-default = "no"
}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if LOOKUP(p-mode, ("gds-grp":U  + {&delim-par} +
                     "gds-prt":U + {&delim-par} +
                     "gds-grp-attr":U  + {&delim-par} +
                     "gds-grp-obj":U  + {&delim-par} +
                     "tax-rate-gds-grp":U  + {&delim-par} +
                     ("gds-grp-attr":U + {&comma-char} + {&g___object}) + {&delim-par} +
                     ("gds-grp-obj":U + {&comma-char} + {&g___object})  + {&delim-par} +
                     ("tax-rate-gds-grp":U + {&comma-char} + {&g___object})  + {&delim-par} +
                     ("gds-grp-attr":U + {&comma-char} + "host":U) + {&delim-par} +
                     ("gds-grp-obj":U + {&comma-char} + "host":U)  + {&delim-par} +
                     ("tax-rate-gds-grp":U + {&comma-char} + "host":U)),
                     {&delim-par}
                     ) > 0
   THEN DO:
     if p-mode = "gds-prt" then do:
      find first X_gds-prt no-lock where
                  X_gds-prt.node-code = p-node-code
              no-error .
      if not available X_gds-prt
      and not p-is-del
      then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-node-code и/или p-is-del" p-node-code p-is-del
          view-as alert-box ERROR.
          return.
      end.

     end.
     else do:
      find first X_gds-grp no-lock where
                  X_gds-grp.node-code = p-node-code
              no-error .
      if not available X_gds-grp
      and not p-is-del
      then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-node-code и/или p-is-del" p-node-code p-is-del
          view-as alert-box ERROR.
          return.
      end.
   end.

   if LOOKUP(p-mode,
                     {&g___object} ) > 0
   THEN DO:
    find first X_clients-obj no-lock where
              X_clients-obj.obj-type = p-obj-type
          AND X_clients-obj.obj-code = p-obj-code no-error .
    if not available X_clients-obj then do:
        message
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметров p-obj-type и/или p-obj-code" p-obj-type p-obj-code
        view-as alert-box ERROR.
        return.
    end.
    { gbl/hostcode.i p-obj-type p-obj-code p-host-code }
   end.
   if LOOKUP(p-mode,
                     "host":U ) > 0
   THEN DO:
      find first X_sysconf no-lock where
                X_sysconf.host-code = p-host-code  no-error .
      if not available X_sysconf then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-host-code" p-host-code
          view-as alert-box ERROR.
          return.
      end.
   end.
   if LOOKUP(p-mode, "tax-rate-gds-grp") > 0 then do:
    if NOT p-tax-code = 0 then do:
      find first X_tax no-lock where X_tax.tax-code = p-tax-code no-error .
      if not available X_sysconf then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-tax-code" p-tax-code
          view-as alert-box ERROR.
          return.
      end.
     end.
   end.
   if lookup(p-mode, "gds-grp-attr") > 0 then do:
      if lookup(p-attr-code, {&gds-grp-attr-list}) = 0 then do:
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение параметра p-attr-code" p-attr-code
          view-as alert-box ERROR.
          return.
      end.
   end.
  END. /*ша дщллгз - все моды*/
  else do:
      message vss-workfile vss-revision vss-description skip
      "Неверный вызов - p-mode=" p-mode
      view-as alert-box ERROR.
      return.
  end.
  RUN MyEnable.
  HIDE mark-num in frame {&frame-name} .
  run OpenBR in this-procedure ( input yes, input no, input '':U).
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-changes :handle
    ) .

  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  v-full-name-old:handle
    ) .
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  v-full-name-new:handle
    ) .

    run diasize_init in this-procedure .
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
  DISPLAY mark-num v-full-name-old v-full-name-new 
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark b-sel B-sch B-Help mark-num BR-c-gds-grp-hist BR-changes 
         v-full-name-old v-full-name-new 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
br-changes:title in frame {&frame-name}  = "":U.
assign
temp-changes.l_name:resizable in browse br-changes = true
temp-changes.v_old:resizable in browse br-changes = true
temp-changes.v_new:resizable in browse br-changes = true
temp-changes.l_name:width in browse br-changes = 30
temp-changes.v_old:width in browse br-changes = 40
temp-changes.v_new:width in browse br-changes = 40
.

DISPLAY
mark-num
br-changes
WITH FRAME Dialog-Frame.
ENABLE
B-quit
B-mark when lookup('b-mark':U, bttns) >0
B-sel when lookup('b-sel':U, bttns) >0
B-sch
B-Help
BR-c-gds-grp-hist
br-changes
mark-num
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame 
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .


run waitfram-show in this-procedure ("Ждите...").

define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-c-gds-grp-hist FOR EACH X_c-gds-grp-hist

&scop flt-open-dyn_open-query  FOR EACH X_c-gds-grp-hist

&scop flt-open-open-query-tail

&scop flt-open-query-handle query br-c-gds-grp-hist:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Справочник истории групп товаров"
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code > 0 "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "gds-grp":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн № группы &1",
                                                       p-node-code)
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Одна группа", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1', p-node-code) "
            &use-ind = "  "
            &by = "  "
          }
    end.
    when "gds-grp-attr":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 атрибут &2"
                                                       , p-node-code
                                                       , p-attr-code
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Атрибут группы", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.attr-code = p-attr-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_gds-grp-attr~} "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.attr-code = &2&3&2 AND ~
                            X_c-gds-grp-hist.subject = &2&4&2 ', p-node-code, ~{&double-quote~}, p-attr-code, ~{&table_gds-grp-attr~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when ("gds-grp-attr":U + {&G___Object}) then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 атрибут &2 объект &3&4"
                                                       , p-node-code
                                                       , p-attr-code
                                                       , p-obj-type
                                                       , p-obj-code
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Атрибут группы на объекте", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.attr-code = p-attr-code AND ~
                            X_c-gds-grp-hist.obj-type = p-obj-type AND ~
                            X_c-gds-grp-hist.obj-code = p-obj-code AND ~
                            X_c-gds-grp-hist.host-code = p-host-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_gds-grp-attr~} "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.attr-code = &2&3&2 AND ~
                            X_c-gds-grp-hist.obj-type = &2&4&2 AND ~
                            X_c-gds-grp-hist.obj-code = &5 AND ~
                            X_c-gds-grp-hist.host-code = &6 AND ~
                            X_c-gds-grp-hist.subject = &2&7&2', p-node-code, ~{&double-quote~}, p-attr-code, p-obj-type, p-obj-code, p-host-code, ~{&table_gds-grp-attr~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when ("gds-grp-attr":U + "host":U) then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 атрибут &2 фирма &3"
                                                       , p-node-code
                                                       , p-attr-code
                                                       , p-host-code
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 атрибута группы на фирме", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.attr-code = p-attr-code AND ~
                            X_c-gds-grp-hist.host-code = p-host-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_gds-grp-attr~} "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.attr-code = &2&3&2 AND ~
                            X_c-gds-grp-hist.host-code = &4 AND ~
                            X_c-gds-grp-hist.subject = &2&5&2', p-node-code, ~{&double-quote~}, p-attr-code, p-host-code, ~{&table_gds-grp-attr~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when "gds-grp-obj":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 параметры по объектам"
                                                       , p-node-code
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 параметры группы по объектам", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_gds-grp-obj~} "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.subject = &2&3&2', p-node-code, ~{&double-quote~}, ~{&table_gds-grp-obj~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when ("gds-grp-obj":U + {&comma-char} + {&g___object})then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 параметры для объекта &2&3"
                                                       , p-node-code
                                                       , p-obj-type
                                                       , p-obj-code
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 Параметры группы на объекте", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.obj-type = p-obj-type AND ~
                            X_c-gds-grp-hist.obj-code = p-obj-code AND ~
                            X_c-gds-grp-hist.host-code = p-host-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_gds-grp-obj~} "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.obj-type = &2&3&2 AND ~
                            X_c-gds-grp-hist.obj-code = &4 AND ~
                            X_c-gds-grp-hist.host-code = &5 AND ~
                            X_c-gds-grp-hist.subject = &2&6&2', p-node-code, ~{&double-quote~}, p-obj-type, p-obj-code, p-host-code, ~{&table_gds-grp-obj~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when ("gds-grp-obj":U + {&comma-char} + "host":U)then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 параметры по объектам фирмы &2"
                                                       , p-node-code
                                                       , p-host-code
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 параметры группы по объектам фирмы", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.host-code = p-host-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_gds-grp-obj~} "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.host-code = &2 AND ~
                            X_c-gds-grp-hist.subject = &3&4&3', p-node-code, p-host-code, ~{&double-quote~}, ~{&table_gds-grp-obj~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when "tax-rate-gds-grp":U then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 налог &2"
                                                       , p-node-code
                                                       , X_tax.tax-name
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 налоги группы", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.tax-code = p-tax-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_tax-rate-gds-grp~} "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.tax-code = &2 AND ~
                            X_c-gds-grp-hist.subject =&3&4&3', p-node-code, p-tax-code, ~{&double-quote~},  ~{&table_tax-rate-gds-grp~}) "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when ("tax-rate-gds-grp":U + {&comma-char} + {&g___object}) then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 налог &2 объект &3&4"
                                                       , p-node-code
                                                       , X_tax.tax-name
                                                       , p-obj-type
                                                       , p-obj-code

                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 налоги группы на объекте", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.tax-code = p-tax-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_tax-rate-gds-grp~}  AND ~
                            X_c-gds-grp-hist.host-code = p-host-code AND ~
                            X_c-gds-grp-hist.obj-type = p-obj-type AND ~
                            X_c-gds-grp-hist.obj-code = p-obj-code  "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.tax-code = &2 AND ~
                            X_c-gds-grp-hist.subject = &3&4&3  AND ~
                            X_c-gds-grp-hist.host-code = &5 AND ~
                            X_c-gds-grp-hist.obj-type = &3&6&3 AND ~
                            X_c-gds-grp-hist.obj-code = &7', p-node-code, p-tax-code, ~{&table_tax-rate-gds-grp~}, p-host-code, p-obj-type, p-obj-code)  "

            &use-ind = "  "
            &by = "  "
          }
    end.
    when ("tax-rate-gds-grp":U + {&comma-char} + "host":U) then do:
        ASSIGN frame {&frame-name}:TITLE = substitute("Справочник истории групп товаров: вн.№ &1 налог &2 фирма &3"
                                                       , p-node-code
                                                       , X_tax.tax-name
                                                       , p-host-code
                                                       )
        filter-point = filter-point0 + p-mode
        filter-label = substitute("&1 налоги группы на фирме", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_c-gds-grp-hist.node-code = p-node-code AND ~
                            X_c-gds-grp-hist.tax-code = p-tax-code AND ~
                            X_c-gds-grp-hist.subject = ~{&table_tax-rate-gds-grp~} AND  ~
                            X_c-gds-grp-hist.host-code = p-host-code "
            &dyn_where-cond = " substitute('X_c-gds-grp-hist.node-code = &1 AND ~
                            X_c-gds-grp-hist.tax-code = &2 AND ~
                            X_c-gds-grp-hist.subject = &3&4&3 AND  ~
                            X_c-gds-grp-hist.host-code = &5', p-node-code, p-tax-code, ~{&double-quote~}, ~{&table_tax-rate-gds-grp~}, p-host-code) "

            &use-ind = "  "
            &by = "  "
          }
    end.
END CASE.
apply "entry" to br-c-gds-grp-hist in frame {&frame-name}.
reposition br-c-gds-grp-hist to row 1 no-error.
run waitfram-hide in this-procedure .

APPLY "VALUE-CHANGED":U to br-c-gds-grp-hist.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame 
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
tbl = 'c-gds-grp-hist'
join-tbl = 'X_c-gds-grp-hist'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('subject', 'Предмет изменений', 'gds-grp-hist-subject',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('action', 'Действие', 'hist-action',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if p-mode <> "gds-prt" then do:
  run fltfield-add in this-procedure('tax-code', 'Код налога', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('attr-code', 'Код атрибута', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('host-code', 'Фирма', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
run fltfield-add in this-procedure('corr-date', 'Дата изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-time', 'Время изменений', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-db-num', 'БД изменений', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('corr-user-name', 'Изменил', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( input parparentproc
                    , input (filter-point + {&delim-par} +
                      filter-label + {&delim-par} +
                      string(yes))
                    , input tbl
                    , input join-tbl
                    , input fld
                    , input lab
                    , input spr
                    , input dim).
    RUN OpenBr in this-procedure ( INPUT yes, input no, input '':U).
END .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-changes Dialog-Frame 
PROCEDURE proc-view-changes :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-description as character no-undo .
for each temp-changes:
    delete temp-changes.
END.
if not available X_c-gds-grp-hist then do:
  Open QUery br-changes for each temp-changes.
  return.
end.
assign
v-full-name-old = "":U
v-full-name-new = "":U
.
run ref/cggrhisv.p (
                   input X_c-gds-grp-hist.node-code
                  ,input X_c-gds-grp-hist.attr-code
                  ,input X_c-gds-grp-hist.tax-code
                  ,input X_c-gds-grp-hist.corr-user-db-num
                  ,input X_c-gds-grp-hist.chip-num
                  ,input X_c-gds-grp-hist.host-code
                  ,input X_c-gds-grp-hist.obj-type
                  ,input X_c-gds-grp-hist.obj-code
                  ,input X_c-gds-grp-hist.subject
                  ,input X_c-gds-grp-hist.action
                  ,input no /*p-silent*/
                  ,output v-description
                  ,OUTPUT v-full-name-old
                  ,OUTPUT v-full-name-new
               ) no-error .
Open QUery br-changes for each temp-changes.
assign
br-changes:title in frame {&frame-name} = v-description
.
if v-full-name-old <> "":U
or v-full-name-new <> "":U  then do:
  DISPLAY
  v-full-name-old
  v-full-name-new
  WITH FRAME {&FRAME-NAME}.
end.
else do:
  hide
  v-full-name-old
  v-full-name-new
  IN FRAME {&FRAME-NAME}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-action Dialog-Frame 
FUNCTION get-action RETURNS CHARACTER
  (  p-action as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  &scop hn-action-code trim(string(p-action))
define variable dops as character no-undo.
assign dops = {&hn-action-name} no-error.

RETURN dops.   /* Function return value. */


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

