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

Список весов для выбранного товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/26/01
Author: Bakhtadze Natalya
Creation date: 10/26/01

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num like ub.scales-gds.db-num no-undo.
define input parameter p-b-code like ub.bar-code.b-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.


/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список весов для выбранного товара".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
define variable v-obj-type like ub.clients.obj-type no-undo.
define variable v-obj-code like ub.clients.obj-code no-undo.

define buffer b-bar-code for ub.bar-code.
define variable v-doc-rec as recid no-undo .
{ ref/gdsoattr.i }

{ str/get-pr.i def }
{ ref/sc-price.i }
{ gbl/getcntxt.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-scales

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.scales-gds ub.scales ub.bar-code ~
ub.gds-obj-attr

/* Definitions for BROWSE br-scales                                     */
&Scoped-define FIELDS-IN-QUERY-br-scales ub.scales.scales-num ~
ub.scales.scales-name IF (ub.scales.master = 0 ) THEN yes ELSE no ~
ub.scales-gds.obj-code ub.gds-obj-attr.attr-value ~
get-price(buffer goods , input scales-gds.obj-type, input scales-gds.obj-code, input scales-gds.b-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-scales
&Scoped-define QUERY-STRING-br-scales FOR EACH ub.scales-gds ~
      WHERE scales-gds.db-num = p-db-num ~
AND scales-gds.b-code = p-b-code ~
 AND (scales-gds.obj-type = v-obj-type or v-obj-type = "") ~
 AND (scales-gds.obj-code = v-obj-code or v-obj-code = 0) NO-LOCK, ~
      EACH ub.scales WHERE (scales.db-num = scales-gds.db-num ~
AND ~
scales.scales-num = scales-gds.scales-num) ~
  OR ~
(scales.db-num = scales-gds.db-num ~
AND  ~
scales.master = scales-gds.scales-num) NO-LOCK, ~
      EACH ub.bar-code WHERE bar-code.b-code = scales-gds.b-code NO-LOCK, ~
      EACH ub.gds-obj-attr WHERE TRUE /* Join to ub.scales-gds incomplete */ ~
      AND gds-obj-attr.obj-type = scales-gds.obj-type ~
 AND gds-obj-attr.obj-code = scales-gds.obj-code ~
 AND gds-obj-attr.gds-code = bar-code.gds-code ~
 AND gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK
&Scoped-define OPEN-QUERY-br-scales OPEN QUERY br-scales FOR EACH ub.scales-gds ~
      WHERE scales-gds.db-num = p-db-num ~
AND scales-gds.b-code = p-b-code ~
 AND (scales-gds.obj-type = v-obj-type or v-obj-type = "") ~
 AND (scales-gds.obj-code = v-obj-code or v-obj-code = 0) NO-LOCK, ~
      EACH ub.scales WHERE (scales.db-num = scales-gds.db-num ~
AND ~
scales.scales-num = scales-gds.scales-num) ~
  OR ~
(scales.db-num = scales-gds.db-num ~
AND  ~
scales.master = scales-gds.scales-num) NO-LOCK, ~
      EACH ub.bar-code WHERE bar-code.b-code = scales-gds.b-code NO-LOCK, ~
      EACH ub.gds-obj-attr WHERE TRUE /* Join to ub.scales-gds incomplete */ ~
      AND gds-obj-attr.obj-type = scales-gds.obj-type ~
 AND gds-obj-attr.obj-code = scales-gds.obj-code ~
 AND gds-obj-attr.gds-code = bar-code.gds-code ~
 AND gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-scales ub.scales-gds ub.scales ~
ub.bar-code ub.gds-obj-attr
&Scoped-define FIRST-TABLE-IN-QUERY-br-scales ub.scales-gds
&Scoped-define SECOND-TABLE-IN-QUERY-br-scales ub.scales
&Scoped-define THIRD-TABLE-IN-QUERY-br-scales ub.bar-code
&Scoped-define FOURTH-TABLE-IN-QUERY-br-scales ub.gds-obj-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-scales}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-scales B-add B-Help RS-all-shop ~
br-scales
&Scoped-Define DISPLAYED-OBJECTS RS-all-shop

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

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-scales
     LABEL "Товары на весах"
     SIZE 20 BY 1.

DEFINE VARIABLE RS-all-shop AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По текущему магазину", 1,
"По всем магазинам БД", 2
     SIZE 44.88 BY .79 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-scales FOR
      ub.scales-gds,
      ub.scales,
      ub.bar-code,
      ub.gds-obj-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-scales Dialog-Frame _STRUCTURED
  QUERY br-scales NO-LOCK DISPLAY
      ub.scales.scales-num FORMAT ">>9":U
      ub.scales.scales-name COLUMN-LABEL "Название весов" FORMAT "X(40)":U
      IF (ub.scales.master = 0 ) THEN yes ELSE no COLUMN-LABEL "Главные" FORMAT "+/":U
      ub.scales-gds.obj-code COLUMN-LABEL "Маг-н" FORMAT "99999":U
      ub.gds-obj-attr.attr-value COLUMN-LABEL "Вес.!код" FORMAT "X(5)":U
      get-price(buffer ub.goods , input ub.scales-gds.obj-type, input ub.scales-gds.obj-code, input ub.scales-gds.b-code) COLUMN-LABEL "Цена" FORMAT ">>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 78.38 BY 8.42.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-scales AT ROW 1 COL 11
     B-add AT ROW 1 COL 31
     B-Help AT ROW 1 COL 54.88
     RS-all-shop AT ROW 2.33 COL 3.75 NO-LABEL
     br-scales AT ROW 3.46 COL 1.88
     SPACE(0.23) SKIP(0.40)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Весы с товаром"
         CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB br-scales RS-all-shop Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-scales
/* Query rebuild information for BROWSE br-scales
     _TblList          = "ub.scales-gds,ub.scales WHERE ub.scales-gds ...,ub.bar-code WHERE ub.scales-gds ...,ub.gds-obj-attr WHERE ub.scales-gds ..."
     _Options          = "NO-LOCK"
     _Where[1]         = "scales-gds.db-num = p-db-num
AND scales-gds.b-code = p-b-code
 AND (scales-gds.obj-type = v-obj-type or v-obj-type = """")
 AND (scales-gds.obj-code = v-obj-code or v-obj-code = 0)"
     _JoinCode[2]      = "(scales.db-num = scales-gds.db-num
AND
scales.scales-num = scales-gds.scales-num)
  OR
(scales.db-num = scales-gds.db-num
AND
scales.master = scales-gds.scales-num)"
     _JoinCode[3]      = "bar-code.b-code = scales-gds.b-code"
     _Where[4]         = "gds-obj-attr.obj-type = scales-gds.obj-type
 AND gds-obj-attr.obj-code = scales-gds.obj-code
 AND gds-obj-attr.gds-code = bar-code.gds-code
 AND gds-obj-attr.attr-code = {&attr-scales-code-o}"
     _FldNameList[1]   = ub.scales.scales-num
     _FldNameList[2]   > ub.scales.scales-name
"scales.scales-name" "Название весов" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > "_<CALC>"
"IF (ub.scales.master = 0 ) THEN yes ELSE no" "Главные" "+/" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[4]   > ub.scales-gds.obj-code
"scales-gds.obj-code" "Маг-н" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   > ub.gds-obj-attr.attr-value
"gds-obj-attr.attr-value" "Вес.!код" "X(5)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[6]   > "_<CALC>"
"get-price(buffer goods , input scales-gds.obj-type, input scales-gds.obj-code, input scales-gds.b-code)" "Цена" ">>>,>>9.99" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE br-scales */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Весы с товаром */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add in this-procedure no-error.
  if error-status:error then return no-apply.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  APPLY "ENTRY" to br-scales.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-scales Dialog-Frame
ON CHOOSE OF B-scales IN FRAME Dialog-Frame /* Товары на весах */
DO:
  def buffer m-scales for ub.scales.
  if not avail ub.scales-gds then return no-apply.
  if ub.scales.master > 0 then do:
        find first m-scales no-lock where
                 m-scales.db-num = ub.scales.db-num
             AND m-scales.scales-num = ub.scales.master No-ERROR.

    message "Для просмотра товаров на весах"  skip
                "выберите соответствующие главные весы"
                (if avail m-scales
                then ("N ":U + string(m-scales.scales-num) + {&space-char} + m-scales.scales-name)
                else "")
    view-as alert-box.
    return no-apply.
  end.
  run proc-select-scales in this-procedure (buffer scales-gds).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-scales
&Scoped-define SELF-NAME br-scales
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-scales Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-scales IN FRAME Dialog-Frame
DO:
  if not avail ub.scales-gds then return no-apply.
    run proc-select-scales in this-procedure (buffer ub.scales-gds).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-scales Dialog-Frame
ON RETURN OF br-scales IN FRAME Dialog-Frame
DO:
  if not avail ub.scales-gds then return no-apply.
    run proc-select-scales in this-procedure (buffer ub.scales-gds).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-all-shop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-all-shop Dialog-Frame
ON VALUE-CHANGED OF RS-all-shop IN FRAME Dialog-Frame
DO:
  define variable glog as logical no-undo.
  assign
  rs-all-shop.
  case rs-all-shop:
    when 1 then do:
        assign
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
        .
        enable
        b-add
        with frame {&frame-name}.


    end.
     when 2 then do:
        if p-obj-type = {&shop} then do :
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_scales_another_obj':U
            {&cntxt-global}
            0
            '':U
            0
            0
            0
            0
            true
            glog
          }
          if not glog then do :
            assign
              rs-all-shop = 1
            .
            DISPLAY
              rs-all-shop
            WITH FRAME {&frame-name}.
          end.
          else do :
            assign
            v-obj-type = ""
            v-obj-code = 0
            .
            disable
            b-add
            with frame {&frame-name}.
          end.
        end.
        else do :
          assign
            v-obj-type = ""
            v-obj-code = 0
          .
          disable
          b-add
          with frame {&frame-name}.
        end.
    end.
  end case.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
   APPLY "ENTRY" to br-scales.
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
{ gbl/brwrefre.i "v-doc-rec = ?. if available ub.scales then v-doc-rec = recid(ub.scales). run openbr in this-procedure. reposition br-scales to recid v-doc-rec.
              v-doc-rec = ? . APPLY 'ENTRY' to br-scales. apply 'VALUE-CHANGED' to br-scales. " }
{ gbl/brwrepos.i
&line-num=5 }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  assign
  v-obj-type = p-obj-type
  v-obj-code = p-obj-code
  .
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY RS-all-shop
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-scales B-add B-Help RS-all-shop br-scales
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
  define variable glog as logical no-undo .

    FIND FIRST b-bar-code No-LOCK WHERE
               b-bar-code.b-code = p-b-code No-ERROR.
    if not avail b-bar-code then do:
        message vss-workfile vss-revision vss-description skip
                      "Не найден бар-код " p-b-code
        view-as alert-box ERROR.
        return.
    end.
    FIND FIRST ub.goods no-lock where
               ub.goods.gds-code = b-bar-code.gds-code NO-ERROR.
    if not avail ub.goods then return.
    ASSIGN frame {&frame-name}:TITLE = substitute("БД &1 Весы с товаром &2 &3&4 &5"
                                                  , p-db-num
                                                  , ub.goods.artic
                                                  , ub.goods.prod-type
                                                  , ub.goods.prod-code
                                                  , ub.goods.gds-name).
 DISPLAY RS-all-shop
      WITH FRAME Dialog-Frame.
  ENABLE
   b-add WHEN p-db-num = v-cntxt-db-num
   b-quit
   B-scales
   B-Help
   RS-all-shop
   br-scales
   WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  APPLY "ENTRY" to br-scales.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{&OPEN-query-BR-scales}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable rid-list as char no-undo.
  define variable ii as integer no-undo.
  define buffer b-scales for ub.scales.
  define buffer b-scales-gds for ub.scales-gds.
  run ref/scales.w (
               input parparentproc
              ,input p-obj-type
              ,input p-obj-type
              ,input "b-sel":U
              ,input 'db':U
              ,output rid-list) no-error.
  if error-status:error then return no-apply.
  _ii:
  do ii = 1 to num-entries(rid-list):
    find first b-scales  WHERE
               recid(b-scales) = integer(entry(ii, rid-list)) no-error.
    if not avail b-scales then next.
    if b-scales.master > 0 then do:
      message "Для того чтобы привязать товар к подчиненным весам," b-scales.scales-num b-scales.scales-name skip
              "выберите соответствующие главные весы" "N":U b-scales.master
      view-as alert-box ERROR.
      next _ii.
    end.
    if can-find(first b-scales-gds No-LOCK WHERE
                      b-scales-gds.b-code =  p-b-code AND
                      b-scales-gds.db-num =  b-scales.db-num AND
                      b-scales-gds.scales-num = b-scales.scales-num) then do:
      message "Товар уже имеется на весах N" b-scales.scales-num b-scales.scales-name
      view-as alert-box ERROR.
      next _ii.
    end.
    run ref/ves-pbc.p (
                        input parparentproc
                      , input {&add-def}
                      , input p-obj-type
                      , input p-obj-code
                      , input ? /*p-deadline*/
                      , input ? /*p-deaddate*/
                      , input ? /*p-deadflag*/
                      , input 0 /* исторически так работало  - добавлялось с 0 весом упаковкиp-wt-cart*/
                      , buffer b-bar-code
                      , buffer b-scales) no-error.
    if error-status:error then do:
      message "Не удалось привязать товар к весам N" b-scales.scales-num b-scales.scales-name
      view-as alert-box ERROR.
      return no-apply.
    end.
  end.
 {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
 APPLY "ENTRY" to br-scales in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-select-scales Dialog-Frame
PROCEDURE proc-select-scales :
define parameter buffer loc-scales-gds for ub.scales-gds.
define variable rid-list as character no-undo.
assign
rid-list = string(recid(loc-scales-gds))
.
run ref/scalelst.w (
                input parparentproc
               ,input p-obj-type
               ,input p-obj-code
               ,input loc-scales-gds.db-num
               ,input loc-scales-gds.scales-num
               ,input (if v-cntxt-db-num-obj = v-cntxt-db-num then  "b-chg":U else '':U)
               ,input {&goods}
               ,input-output rid-list).
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
 APPLY "ENTRY" to br-scales in frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME