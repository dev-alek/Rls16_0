&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_db FOR ub.db.
DEFINE BUFFER buf_fbr-prn FOR ub.fbr-prn.
DEFINE BUFFER buf_fbr-prn-gds FOR ub.fbr-prn-gds.
DEFINE BUFFER buf_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары на  принтере кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/26/03
Author: Bakhtadze Natalya
Creation date: 08/26/03

*/


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode as character no-undo.
/*может быть {&all} или "db":U или "printer":U или "goods" "object" "printer-object"*/

define input parameter bttns as character no-undo.
define input parameter p-db-num like ub.fbr-prn.db-num no-undo.
define input parameter p-prn-num like ub.fbr-prn.prn-num no-undo.
define input parameter p-obj-type like ub.fbr-prn-gds.obj-type no-undo.
define input parameter p-obj-code like ub.fbr-prn-gds.obj-code no-undo.
define input parameter p-gds-code like ub.fbr-prn-gds.gds-code no-undo .

define input-output parameter par-recid as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары на  принтере кухни".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new}
{ cmp/gds-list.i gds-list def "NEW SHARED" }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/prn-lib.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/fltopend.i defproc }

define variable filter-label as character no-undo init "Товары на принтере кухни" .
define variable filter-label0 as character no-undo init "Товары на принтере кухни" .
define variable filter-point0 as character no-undo init "fprngdss" .
define variable filter-point as character no-undo init "fprngdss" .
define variable sort-column-name as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-list as character no-undo.
define variable gds-rec as recid no-undo .
define variable v-doc-rec as recid no-undo .
define buffer X_goods for ub.goods.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-prn-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_fbr-prn-gds buf_goods

/* Definitions for BROWSE BR-prn-gds                                    */
&Scoped-define FIELDS-IN-QUERY-BR-prn-gds buf_fbr-prn-gds.prn-num get-fbr-obj-name(buf_fbr-prn-gds.db-num, buf_fbr-prn-gds.prn-num) buf_goods.gds-code buf_goods.gds-name buf_fbr-prn-gds.obj-type + string(buf_fbr-prn-gds.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-prn-gds
&Scoped-define SELF-NAME BR-prn-gds
&Scoped-define QUERY-STRING-BR-prn-gds FOR EACH buf_fbr-prn-gds NO-LOCK, ~
          FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_fbr-prn-gds.gds-code
&Scoped-define OPEN-QUERY-BR-prn-gds OPEN QUERY {&SELF-NAME} FOR EACH buf_fbr-prn-gds NO-LOCK, ~
          FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_fbr-prn-gds.gds-code.
&Scoped-define TABLES-IN-QUERY-BR-prn-gds buf_fbr-prn-gds buf_goods
&Scoped-define FIRST-TABLE-IN-QUERY-BR-prn-gds buf_fbr-prn-gds
&Scoped-define SECOND-TABLE-IN-QUERY-BR-prn-gds buf_goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-add B-delete B-chg B-gds B-print ~
B-sch B-help RS-Object BR-prn-gds sch-code sch-num
&Scoped-Define DISPLAYED-OBJECTS f-object RS-Object sch-code sch-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-fbr-obj-name Dialog-Frame
FUNCTION get-fbr-obj-name RETURNS CHARACTER
  ( input p-db-num as integer, input p-prn-num as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  ( p-gds-code as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-obj-name Dialog-Frame
FUNCTION get-obj-name RETURNS CHARACTER
  ( input p-obj-type as character, input p-obj-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-delete
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "В&ыход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-gds
     LABEL "&Товар"
     SIZE 10 BY 1.

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-object AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(20)":U
     LABEL "коду товара"
     VIEW-AS FILL-IN
     SIZE 14.38 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE sch-num AS CHARACTER FORMAT "X(20)":U
     LABEL "принтеру"
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 TOOLTIP "Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>" NO-UNDO.

DEFINE VARIABLE RS-Object AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 18.13 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-prn-gds FOR
                buf_fbr-prn-gds,
                buf_goods SCROLLING.

&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-prn-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-prn-gds Dialog-Frame _FREEFORM
  QUERY BR-prn-gds NO-LOCK DISPLAY
      buf_fbr-prn-gds.prn-num COLUMN-LABEL "N!пр-ра" FORMAT ">>9":U
      get-fbr-obj-name(buf_fbr-prn-gds.db-num, buf_fbr-prn-gds.prn-num) COLUMN-LABEL "Принтер!установлен" FORMAT "X(8)":U
      buf_goods.gds-code FORMAT "999999999":U
      buf_goods.gds-name FORMAT "X(48)":U
      buf_fbr-prn-gds.obj-type + string(buf_fbr-prn-gds.obj-code) COLUMN-LABEL "Объект!товара" FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.71.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-add AT ROW 1 COL 21
     B-delete AT ROW 1 COL 31
     B-chg AT ROW 1 COL 41
     B-gds AT ROW 1 COL 51
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-help AT ROW 1 COL 95
     f-object AT ROW 2.5 COL 22.25 NO-LABEL
     RS-Object AT ROW 2.54 COL 1.88 NO-LABEL
     BR-prn-gds AT ROW 3.58 COL 1
     sch-code AT ROW 20.71 COL 40 COLON-ALIGNED
     sch-num AT ROW 20.79 COL 19.63 COLON-ALIGNED
     "ПОИСК ПО" VIEW-AS TEXT
          SIZE 9.25 BY 1 AT ROW 20.79 COL 1.5
          FGCOLOR 4
     SPACE(88.49) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары на принтере кухни"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_db B "?" ? ub db
      TABLE: buf_fbr-prn B "?" ? ub fbr-prn
      TABLE: buf_fbr-prn-gds B "?" ? ub fbr-prn-gds
      TABLE: buf_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-prn-gds RS-Object Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-object IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-prn-gds
/* Query rebuild information for BROWSE BR-prn-gds
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH buf_fbr-prn-gds NO-LOCK,
   FIRST buf_goods NO-LOCK WHERE buf_goods.gds-code = buf_fbr-prn-gds.gds-code
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BR-prn-gds FOR
                buf_fbr-prn-gds,
                buf_goods SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-prn-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары на принтере кухни */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-add in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  run proc-chg in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delete Dialog-Frame
ON CHOOSE OF B-delete IN FRAME Dialog-Frame /* Удалить */
DO:
define buffer del_fbr-prn-gds for ub.fbr-prn-gds.
define variable loc#log as logical no-undo .
define variable glog as logical no-undo .
if not available buf_fbr-prn-gds then return no-apply.

  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    buf_fbr-prn-gds.obj-type
    buf_fbr-prn-gds.obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fbr-prn-goods_work':U
    {&cntxt-object}
    v-chk-act-host-code
    buf_fbr-prn-gds.obj-type
    buf_fbr-prn-gds.obj-code
    0
    0
    0
    true
    loc#log
  }


  if not loc#log then return no-apply.

glog = no.
message
"После удаления данный товар (блюдо) НЕ БУДЕТ" skip
"автоматически появляться (печататься)" skip
"на ЭТОМ принтера ( с номером " buf_fbr-prn-gds.prn-num " )" skip
"при заказе его на объекте" buf_fbr-prn-gds.obj-type buf_fbr-prn-gds.obj-code skip(1)
"Вы уверены ?" skip
" "
view-as alert-box question buttons OK-Cancel update glog.
if not glog then return no-apply.
FIND del_fbr-prn-gds WHERE recid( del_fbr-prn-gds ) = recid(buf_fbr-prn-gds) exclusive.
delete del_fbr-prn-gds .

RUN OpenBr in this-procedure ( input yes, input no, input "":U).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds Dialog-Frame
ON CHOOSE OF B-gds IN FRAME Dialog-Frame /* Товар */
DO:
define variable gds-rec as recid no-undo .

   if not available buf_goods then return no-apply.
    gds-rec = recid (buf_goods).
    run ref/gds-form.w ( input parparentproc
                        ,input {&lookup}
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input this-procedure:handle
                        ,input-output gds-rec).
    apply "entry" to br-prn-gds in frame {&frame-name}.
    return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-print in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  run proc-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-Object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-Object Dialog-Frame
ON VALUE-CHANGED OF RS-Object IN FRAME Dialog-Frame
DO:
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer loc_clients for ub.clients.

  Assign
  Rs-object.
  CASE RS-object:screen-value:
    when {&all} then do:
    assign
    RS-object
    v-list = {&all}
    p-obj-type = "":U
    p-obj-code = 0
    .
    DIsplay
    "":U @ f-object
    with frame {&frame-name}
    .
  end.
  when {&g___object}
  then do:
    define variable v-user-select as logical   no-undo .
    define variable v-obj-type    as character no-undo .
    define variable v-obj-code    as integer   no-undo .

    { gbl/hostcode.i
      p-obj-type
      p-obj-code
      v-host-code
    }
    { gbl/uobjsone.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-host-code
      p-obj-type
      p-obj-code
      v-user-select
      v-obj-type
      v-obj-code
    }
    if v-user-select <> true
    then do:
      RS-object:screen-value = {&all}.
      return no-apply.
    end.

    find first loc_clients no-lock
      where loc_clients.obj-type = v-obj-type
        and loc_clients.obj-code = v-obj-code
      no-error .
    if not available loc_clients
    then do:
        RS-object:screen-value = {&all}.
        return no-apply.
      end.
    if loc_clients.db-num <> v-db-num then do:
      message
      "Можно выбать только объект текущей БД"
      view-as alert-box error.
      RS-object:screen-value = {&all}.
      return no-apply.
    end.
    assign
    v-list = {&g___object}
    p-obj-type = loc_clients.obj-type
    p-obj-code = loc_clients.obj-code
    RS-object
    .
        DIsplay
    (p-obj-type + string(p-obj-code)) @ f-object
    with frame {&frame-name}
    .

    end.
  END CASE.
  RUn OpenBR in this-procedure ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON CTRL-J OF sch-code IN FRAME Dialog-Frame /* коду товара */
DO:
  run proc-find-code in this-procedure ( input yes, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON RETURN OF sch-code IN FRAME Dialog-Frame /* коду товара */
DO:
  run proc-find-code in this-procedure ( input no, input frame {&frame-name} sch-code) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-num Dialog-Frame
ON CTRL-J OF sch-num IN FRAME Dialog-Frame /* принтеру */
DO:
  run proc-find-num in this-procedure ( input yes, input frame {&frame-name} sch-num) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-num Dialog-Frame
ON RETURN OF sch-num IN FRAME Dialog-Frame /* принтеру */
DO:
  run proc-find-num in this-procedure ( input no, input frame {&frame-name} sch-num) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-prn-gds
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/f2.i br-prn-gds " " " " parparentproc }
{ gbl/brwrepos.i
&line-num=5 }
{ gbl/brwrefre.i "v-doc-rec = recid(buf_fbr-prn-gds). run openbr in this-procedure ( input yes, input no, input no). reposition br-prn-gds to recid(v-doc-rec). v-doc-rec = ? . " }

{ gbl/setfltnm.i }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
    CASE par-mode:
      when "printer":U or when "printer-object":U then do:
        FIND FIRST buf_fbr-prn no-lock where
                  buf_fbr-prn.db-num = p-db-num
              AND buf_fbr-prn.prn-num = p-prn-num no-error.
        if not available buf_fbr-prn then do:
                  message
                  "Неверное значение параметров p-db-num и/или p-prn-num" p-db-num p-prn-num
                  view-as alert-box error.
                  return error.
        end.
        { gbl/curdbnum.i v-db-num }
      end.
      when "db":U then do:
        find first buf_db no-lock where
                  buf_db.db-num = p-db-num no-error.
        if not available buf_db then do:
          message
          "Неверное значение параметра p-db-num" p-db-num
          view-as alert-box error.
          return error.
        end.
      end.
      when "goods" then do:
        find first X_goods no-lock where
                    X_goods.gds-code = p-gds-code no-error .
        if not available buf_goods then do:
          message
          "Неверное значение параметра p-gds-code" p-gds-code
          view-as alert-box error.
          return error.
        end.
      end.
      when "object":U or when "printer-object":U then do:
        find first buf_clients no-lock where
                  buf_clients.obj-type = p-obj-type
              AND buf_clients.obj-code = p-obj-code
                    no-error .
        if not available buf_clients then do:
          message
          "Неверное значение параметров p-obj-type и/или p-obj-code" p-obj-type p-obj-code
          view-as alert-box error.
          return error.
        end.
      end.

    END CASE.
  RUN MyEnable in this-procedure .
  run OpenBr in this-procedure ( input yes, input no, input '':U).
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
  DISPLAY f-object RS-Object sch-code sch-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-add B-delete B-chg B-gds B-print B-sch B-help RS-Object
         BR-prn-gds sch-code sch-num
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
ASSIGN
RS-object:radio-buttons in frame {&frame-name} = "Все" + {&comma-char} + {&all} + {&comma-char} + "Объект" + {&comma-char} + {&g___object}
RS-object = (if par-mode = "printer-object":U or par-mode = "object":U
             then {&g___object}
             else {&all}
            )
f-object =  if rs-object = {&g___object}
                        then (p-obj-type + string(p-obj-code))
                        else "":U
v-list = rs-object
.
DISPLAY
sch-code
sch-num
RS-object
f-object
with frame {&frame-name}.
ENABLE
B-exit
RS-object when (par-mode <> "printer-object":U and par-mode <> "object":U)
b-add when (par-mode = "goods" or ((par-mode = "printer":U or par-mode = "printer-object":U) and v-db-num = p-db-num))
b-delete when (par-mode = "goods" or ((par-mode = "printer":U or par-mode = "printer-object":U) and v-db-num = p-db-num))
/*b-chg when (par-mode = "goods":U or ((par-mode = "printer":U or par-mode = "printer-object":U) and v-db-num = p-db-num))*/
b-print
B-Help
BR-prn-gds
b-sch
b-gds
sch-code when par-mode <> "goods":U
sch-num when par-mode <> "printer":U or par-mode <> "printer-object":U
WITH FRAME Dialog-Frame.
if par-mode = "Printer":U or par-mode = "printer-object" then do:
  hide
  sch-num in frame {&frame-name} .
end.
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
define variable title0 as character no-undo.
title0 = "Товары на принтере кухни".
run waitfram-show in this-procedure ( input "Ждите...").
define variable sort-column-phrase as character no-undo .
define variable v-list-cond as character no-undo.
define variable where-cond as character no-undo .
define variable v-doc-rec as recid no-undo.

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


&scop flt-open-open-query OPEN QUERY br-prn-gds FOR EACH buf_fbr-prn-gds

&scop flt-open-dyn_open-query FOR EACH buf_fbr-prn-gds

&scop flt-open-query-handle QUERY br-prn-gds:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name buf_fbr-prn-gds

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name buf_fbr-prn-gds

define variable l-open-query as logical   no-undo .

filter-point = filter-point0 + par-mode.

CASE par-mode:
  when "printer":U then do:
    if p-open-query then do:
      ASSIGN
      frame {&frame-name}:TITLE = title0 + " Принтер: "+  string(p-prn-num)
      .
    end.
    assign
    filter-label = substitute("&1 Один принтер", filter-label0)
     .

&scop flt-open-open-query-tail    ,   FIRST buf_goods No-LOCK where ~
                     buf_goods.gds-code = buf_fbr-prn-gds.gds-code
    CASE v-list:
      when {&all} then do:
      { gbl/fltopend.i
          &where-cond = " buf_fbr-prn.db-num = p-db-num and buf_fbr-prn-gds.prn-num = p-prn-num "
          &dyn_where-cond = " substitute('buf_fbr-prn.db-num = &1 and buf_fbr-prn-gds.prn-num = &2 ', p-db-num, p-prn-num)"
          &use-ind    = "  "
          &by         = "  " }
      end.
      when {&g___object} then do:
      { gbl/fltopend.i
          &where-cond = " buf_fbr-prn.db-num = p-db-num and buf_fbr-prn-gds.prn-num = p-prn-num  ~
                          AND buf_fbr-prn-gds.obj-type = p-obj-type AND buf_fbr-prn-gds.obj-code = p-obj-code "
          &dyn_where-cond = " substitute('buf_fbr-prn.db-num = &1 and buf_fbr-prn-gds.prn-num = &2  ~
                          AND buf_fbr-prn-gds.obj-type = &3&4&3 AND buf_fbr-prn-gds.obj-code = &5 ', p-db-num, p-prn-num, ~{&double-quote~}, p-obj-type, p-obj-code)"

          &use-ind    = "  "
          &by         = "  " }
      end.
    END CASE.
  END.
  when {&all} then do:
    assign
    filter-point = filter-point0 + par-mode
    .
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 .
    end.

&scop flt-open-open-query-tail   , FIRST buf_goods No-LOCK where ~
                                buf_goods.gds-code = buf_fbr-prn-gds.gds-code
    CASE v-list :
      when {&all} then do:
      { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = "  "
          &by         = "  " }
      end.
      when {&g___object} then do:
        { gbl/fltopend.i
            &where-cond = " buf_fbr-prn-gds.obj-type = p-obj-type AND buf_fbr-prn-gds.obj-code = p-obj-code "
            &dyn_where-cond = " substitute('buf_fbr-prn-gds.obj-type = &1&2&1 AND buf_fbr-prn-gds.obj-code = &3 ', ~{&double-quote~}, p-obj-type, p-obj-code)"
            &use-ind    = "  "
            &by         = "  " }
      end.
    END CASE.
  end.
  when "db":U then do:
     assign
     filter-point = filter-point0 + par-mode
     filter-label = substitute("&1 Одна БД", filter-label0)
     .
     if p-open-query then do:
       ASSIGN frame {&frame-name}:TITLE = title0 + " БД: "+  string(p-db-num)
       .
     end.

&scop flt-open-open-query-tail    , FIRST buf_goods No-LOCK where  buf_goods.gds-code = buf_fbr-prn-gds.gds-code

    CASE v-list :
      when {&all} then do:
      { gbl/fltopend.i
          &where-cond = " buf_fbr-prn-gds.db-num = p-db-num  "
          &dyn_where-cond = " substitute('buf_fbr-prn-gds.db-num = &1', p-db-num  )"
          &use-ind    = "  "
          &by         = "  " }
      end.
      when {&g___object} then do:
        { gbl/fltopend.i
            &where-cond = " buf_fbr-prn-gds.db-num = p-db-num  AND  ~
                            buf_fbr-prn-gds.obj-type = p-obj-type AND buf_fbr-prn-gds.obj-code = p-obj-code "
            &dyn_where-cond = " substitute('buf_fbr-prn-gds.db-num = &1  AND  ~
                            buf_fbr-prn-gds.obj-type = &2&3&2 AND buf_fbr-prn-gds.obj-code = &4 ', p-db-num, ~{&double-quote~},   p-obj-type, p-obj-code)"

            &use-ind    = "  "
            &by         = "  " }
      end.
    END CASE.
  end.

  when "goods":U then do:
       filter-point = filter-point0 + par-mode.
       ASSIGN frame {&frame-name}:TITLE = title0 + " Товар: "+  string(p-gds-code)
       filter-label = substitute("&1 Один товар", filter-label0)
       .

&scop flt-open-open-query-tail    ,   FIRST buf_goods No-LOCK where ~
                     buf_goods.gds-code = buf_fbr-prn-gds.gds-code

    CASE v-list :
      when {&all} then do:
      { gbl/fltopend.i
          &where-cond = " buf_fbr-prn-gds.gds-code = p-gds-code "
          &dyn_where-cond = " substitute('buf_fbr-prn-gds.gds-code = &1', p-gds-code )"
          &use-ind    = "  "
          &by         = "  " }
      end.
      when {&g___object} then do:
        { gbl/fltopend.i
          &where-cond = " buf_fbr-prn-gds.gds-code = p-gds-code AND buf_fbr-prn-gds.obj-type = p-obj-type AND buf_fbr-prn-gds.obj-code = p-obj-code "
          &dyn_where-cond = " substitute('buf_fbr-prn-gds.gds-code = &1 AND buf_fbr-prn-gds.obj-type = &2&3&2 AND buf_fbr-prn-gds.obj-code = &4 ' ~
                              , p-gds-code, ~{&double-quote~}, p-obj-type, p-obj-code)"
          &use-ind    = "  "
          &by         = "  " }
      end.
    END CASE.
  end.
  when "object":U then do:
    assign
     filter-point = filter-point0 + par-mode
     filter-label = substitute("&1 Один объект", filter-label0)
     .
     if p-open-query then do:
       ASSIGN frame {&frame-name}:TITLE = title0 + " Объект: "+ p-obj-type + string(p-obj-code).
     end.

&scop flt-open-open-query-tail  ,   FIRST buf_goods No-LOCK where ~
                     buf_goods.gds-code = buf_fbr-prn-gds.gds-code

     { gbl/fltopend.i
        &where-cond = " buf_fbr-prn-gds.obj-type = p-obj-type AND buf_fbr-prn-gds.obj-code = p-obj-code "
        &dyn_where-cond = " substitute('buf_fbr-prn-gds.obj-type = &1&2&1 AND buf_fbr-prn-gds.obj-code = &3 ', ~{&double-quote~}, p-obj-type, p-obj-code)"
        &use-ind    = "  "
        &by         = "  " }
  end.
  when "printer-object":U then do:
    assign
    filter-point = filter-point0 + par-mode
    filter-label = substitute("&1 принетра одного объекта", filter-label0)
    .
    if p-open-query then do:
      ASSIGN frame {&frame-name}:TITLE = title0 + " Принтер: "+  string(p-prn-num) + " Объект: " + p-obj-type + string(p-obj-code)
      .
    end.
&scop flt-open-open-query-tail   ,       FIRST buf_goods No-LOCK where ~
                     buf_goods.gds-code = buf_fbr-prn-gds.gds-code
     { gbl/fltopend.i
        &where-cond = " buf_fbr-prn-gds.db-num = p-db-num AND buf_fbr-prn-gds.prn-num = p-prn-num AND  ~
                        buf_fbr-prn-gds.obj-type = p-obj-type AND buf_fbr-prn-gds.obj-code = p-obj-code "
        &dyn_where-cond = " substitute('buf_fbr-prn-gds.db-num = &1 AND buf_fbr-prn-gds.prn-num = &2 AND  ~
                        buf_fbr-prn-gds.obj-type = &3&4&3 AND buf_fbr-prn-gds.obj-code = &5 ', p-db-num, p-prn-num, ~{&double-quote~}, p-obj-type, p-obj-code)"

        &use-ind    = "  "
        &by         = "  " }
  end.
END CASE.

if not p-open-query and v-doc-rec <> ? then
REPOSITION br-prn-gds to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-prn-gds:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-prn-gds in frame {&frame-name}.
APPLY "ENTRY" TO br-prn-gds.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add Dialog-Frame
PROCEDURE proc-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-update as logical no-undo .
define variable v-rec as recid no-undo .
define buffer loc_fbr-prn-gds for ub.fbr-prn-gds.
define buffer loc_clients for ub.clients.
define buffer loc_fbr-prn for ub.fbr-prn.
define variable loc#log as logical no-undo .

CASE par-mode:
  when "printer":U then do:
    FOR EACH gds-list : /* Когда все ОК - цикл не вып-ся ни разу */
        delete gds-list.
    END.
    run str/gds-list.w (
                   input parparentproc
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code).
    message
    "Вы действительно хотите добавить " skip
    "товары данного списка на принтер?" p-prn-num
    view-as alert-box QUESTION buttons YES-NO update v-update.
    if not v-update then do:
      FOR EACH gds-list:
        delete gds-list.
      END.
      return error.
    end.


    { gbl/uobjclr.i  }

    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      return error .
    end.

    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      find first loc_clients no-lock
        where loc_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
          and loc_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
        no-error .
      if not available loc_clients then return error.
      if loc_clients.db-num <> v-db-num then do:
        message
        "Можно выбрать только объект текущей БД"
        view-as alert-box error.
        return error.
      end.
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_fbr-prn-goods_work':U
        {&cntxt-object}
        loc_clients.host-code
        loc_clients.obj-type
        loc_clients.obj-code
        0
        0
        0
        true
        loc#log
      }
      if not loc#log then do:
        return error.
      end.
    end.

    for each gds-list no-lock
    :
      for each buf_userobjs_temp-user-obj
      on error undo, return error return-value
      :
        run ref/fprngds1.p
          (input-output v-rec
          ,input {&add-def}
          ,input p-db-num
          ,input p-prn-num
          ,input buf_userobjs_temp-user-obj.obj-type
          ,input buf_userobjs_temp-user-obj.obj-code
          ,input gds-list.gds-code
          ) no-error .
        if error-status :error
        then do:
          /* ошибка игнорируется */
        end.
      end.
    end. /*for each gds-list*/
  end. /*when "printer":U*/
  when "goods":U then do:
        run ref/fprngdsi.w (
                   input parparentproc
                  ,input {&add-def}
                  ,input "goods":U
                  ,input 0 /*p-db-num*/
                  ,input 0 /*p-prn-num*/
                  ,input "":U
                  ,input 0
                  ,input p-gds-code
                  ,input-output v-rec) no-error.
    if error-status:error then return error.
  end.
  END CASE.
run OpenBr in this-procedure ( input yes, input no, input "":U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-chg Dialog-Frame
PROCEDURE proc-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-rec as recid no-undo.
define variable loc#log as logical no-undo .
if not available buf_fbr-prn-gds then return error.

  define variable v-chk-act-host-code as integer   no-undo .
  { gbl/hostcode.i
    buf_fbr-prn-gds.obj-type
    buf_fbr-prn-gds.obj-code
    v-chk-act-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fbr-prn-goods_work':U
    {&cntxt-object}
    v-chk-act-host-code
    buf_fbr-prn-gds.obj-type
    buf_fbr-prn-gds.obj-code
    0
    0
    0
    true
    loc#log
  }
  if not loc#log then return no-apply.

v-rec = recid(buf_fbr-prn-gds).

run ref/fprngdsi.w (
               input parparentproc
              ,input {&update}
              ,input "":U
              ,input buf_fbr-prn-gds.db-num
              ,input buf_fbr-prn-gds.prn-num
              ,input buf_fbr-prn-gds.obj-type
              ,input buf_fbr-prn-gds.obj-code
              ,input buf_fbr-prn-gds.gds-code
              ,input-output v-rec) no-error.
    if error-status:error then return error.
RUn OpenBr   in this-procedure ( input yes, input no, input "":U).
reposition BR-prn-gds to recid v-rec no-error.
APPLY "ENTRY" to br-prn-gds in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-code Dialog-Frame
PROCEDURE proc-find-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter pargds-code like ub.fbr-prn-gds.gds-code no-undo.
define variable var-gds-code-chr as character no-undo.
if sch-num:visible in frame {&frame-name} then
display
"  ":U @ sch-num
with frame {&frame-name}.
assign
var-gds-code-chr = string(pargds-code).
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_fbr-prn-gds.gds-code  = &1 "  , var-gds-code-chr)
    ).

apply "entry":u to sch-code in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-num Dialog-Frame
PROCEDURE proc-find-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter parprn-num like ub.fbr-prn-gds.prn-num no-undo.
define variable var-prn-num-chr as character no-undo.
display
"  ":U @ sch-code
with frame {&frame-name}.
assign
var-prn-num-chr = {&double-quote} + string(parprn-num) + {&double-quote}.
run OpenBr in this-procedure
    (input false /* p-open-query */
    ,input par-next  /* p-find-next  */
    ,input substitute("and buf_fbr-pnr-gds.prn-num  = &1 "
      , var-prn-num-chr)
    ).
apply "entry":u to sch-num in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print Dialog-Frame
PROCEDURE proc-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-fbr-obj-name as character no-undo.
define variable v-obj-name as character no-undo.
define variable v-gds-full as character no-undo.
define variable v-rec as recid no-undo.
define variable LIne as character no-undo.
define variable ii as integer no-undo.
DEFINE FRAME List
buf_fbr-prn-gds.prn-num COLUMN-LABEL "Принтер"
v-fbr-obj-name column-label "Установлен на" format "X(8)"
buf_goods.gds-code column-label "Код товара"
buf_goods.gds-name column-label "Название товара"
v-obj-name column-label "Объект" format "x(8)"
 HEADER
    cur-time-print() AT 5 format "x(35)"
        string( "Страница " + string( PAGE-NUMBER( Prnlibstream ) , ">>9") )
            AT 66 format "X(15)" SKIP
    Line format "x(116)" AT 1
with width {&A4_CW} down use-text stream-io no-box .

if num-results( "BR-prn-gds" ) = 0 then  do:
    message "Список  П У С Т !" skip view-as alert-box information .
    return error .
end.

if session:set-wait-state( "compiler" ) then .
Line = fill( "-" , 116 ) .
v-rec = recid( buf_fbr-prn-gds ) .
DO WHILE available buf_fbr-prn-gds :
    GET prev br-prn-gds NO-LOCK .
END.
GET next br-prn-gds NO-LOCK .
ii = 1 .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM HEADER
Line format "X(116)" SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
VIEW stream Prnlibstream FRAME CliBottomFrame .
PUT stream Prnlibstream space(20) frame {&frame-name}:title format "X(80)" SKIP(2) .
FORM with frame List .
DO WHILE available buf_fbr-prn-gds :
    DISPLAY stream Prnlibstream
        buf_fbr-prn-gds.prn-num
        get-fbr-obj-name(buf_fbr-prn-gds.db-num, buf_fbr-prn-gds.prn-num) @ v-fbr-obj-name
        buf_goods.gds-code
        buf_goods.gds-name
        buf_fbr-prn-gds.obj-type + string(buf_fbr-prn-gds.obj-code) @ v-obj-name
       with frame List .
    DOWN stream Prnlibstream 1
    with frame List .
    ii =  ii + 1 .
    if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
    run waitfram-show in this-procedure ( input ("Просмотрено строк : " + string( ii ) ) ).
    GET next br-prn-gds .
END.
PUT stream Prnlibstream Line format "X(116)" SKIP.
HIDE stream Prnlibstream FRAME CliBottomFrame .
output stream Prnlibstream close .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

reposition br-prn-gds to recid v-rec NO-ERROR .
run waitfram-hide in this-procedure.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sch Dialog-Frame
PROCEDURE proc-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'fbr-prn-gds'
  join-tbl = 'buf_fbr-prn-gds'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('gds-code', 'Код товара', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('prn-num', 'Номер принтера', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('db-num', '№ БД', 'db',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parparentproc
                      , INPUT (filter-point + {&delim-par} +
                                filter-label + {&delim-par} +
                                string(yes))
                      , INPUT tbl
                      , INPUT join-tbl
                      , INPUT fld
                      , INPUT lab
                      , INPUT spr
                      , INPUT dim ).
    RUN OpenBr in this-procedure ( input yes, input no, input '':U).
  END. /* Filter-Block */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-goods Dialog-Frame
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .

  /* перемещение на первую, последнюю, предыдущую, следующую */
  case p-direction :
    when "first":U
    then do:
      get first br-prn-gds.
    end.
    when "last":U
    then do:
      get last br-prn-gds.
    end.
    when "prev":U
    then do:
      get prev br-prn-gds.
      if not available buf_fbr-prn-gds then do:
        message
        "Это первый товар списка"
        view-as alert-box.
      end.
    end.
    when "next":U
    then do:
      get next {&browse-name}.
      if not available buf_fbr-prn-gds then do:
        message
        "Это последний товар списка"
        view-as alert-box.
      end.
    end.
  end case . /* p-direction */
  assign
  p-recid = recid(buf_goods)
  .
  run reposition-query in this-procedure
    (input recid(buf_fbr-prn-gds)
    ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

if p-recid <> ?
then do:
  reposition {&BROWSE-NAME} to recid p-recid no-error.
end.

do with frame {&frame-name}:
  apply "entry":u to browse {&browse-name} .
  apply "VALUE-CHANGED":u to browse {&browse-name} .
end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-fbr-obj-name Dialog-Frame
FUNCTION get-fbr-obj-name RETURNS CHARACTER
  ( input p-db-num as integer, input p-prn-num as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer loc_clients for ub.clients.

CASE par-mode:
    when "printer":U then do:
    end.
    when "db":U or when {&all} then do:
            find first buf_fbr-prn no-lock where
                        buf_fbr-prn.db-num = p-db-num
                    AND buf_fbr-prn.prn-num = p-prn-num no-error.
            if not available buf_fbr-prn then return ?.
    end.
END CASE.
return (buf_fbr-prn.fbr-obj-type + string(buf_fbr-prn.fbr-obj-code)).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-gds-name Dialog-Frame
FUNCTION get-gds-name RETURNS CHARACTER
  ( p-gds-code as integer) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define variable v-gds-name as character no-undo.
/*
run gdslib-get-full-name in this-procedure(p-gds-code, output v-gds-name) no-error.
if length(v-gds-name) >  65 then do:
    overlay( v-gds-name, length(v-gds-name) - 65 + 1, 3) = "...":U.
end.
*/
  RETURN v-gds-name.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-obj-name Dialog-Frame
FUNCTION get-obj-name RETURNS CHARACTER
  ( input p-obj-type as character, input p-obj-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer loc_clients for ub.clients.
find first loc_clients no-lock where
        buf_clients.obj-type = p-obj-type
    AND loc_clients.obj-code = p-obj-code no-error.
    if available loc_clients then
  RETURN loc_clients.obj-name.   /* Function return value. */
  return (p-obj-type + string(p-obj-code)).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
