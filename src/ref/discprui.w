&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-cpdisc NO-UNDO LIKE ub.dis-cp-rule
       field rule-label as character.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Скидки на платеж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/13/06
Author: Bakhtadze Natalya
Creation date: 12/13/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter p-cdpay-code like ub.dis-cp-rule.cdpay-code no-undo.
define input parameter p-curr-code  like ub.dis-cp-rule.curr-code no-undo .
define input parameter p-host-code like ub.dis-cp-rule.host-code no-undo.
define input parameter p-obj-type like ub.dis-cp-rule.obj-type no-undo.
define input parameter p-obj-code like ub.dis-cp-rule.obj-code no-undo.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки на платеж".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ ref/discprul.i interface parparentproc }
{ cmp/showinf.i }
{ gbl/get-regf.i }

define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
DEFINE VARIABLE dflt-cd AS CHARACTER NO-UNDO.
define variable v-tab-order as character no-undo .
define variable loc-glob as logical no-undo .
define variable loc-firm as logical no-undo .
define variable loc-object as logical no-undo .

&SCOPED-DEFINE cd-type-code temp-cpdisc.pos-type

&SCOPED-DEFINE label-clmn_2 'Тип скидки'


&scoped-define  discpru-type-get-error message "Ошибка при определении названия и типа скидки на платеж!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  discpru-value-get-error message "Ошибка при определении значения скидки на платеж!" ~
        skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dis-cp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-cpdisc

/* Definitions for BROWSE BR-dis-cp                                     */
&Scoped-define FIELDS-IN-QUERY-BR-dis-cp temp-cpdisc.templ-rl-root discpru-get-disc-label(temp-cpdisc.templ-rl-root) get-region(temp-cpdisc.host-code, temp-cpdisc.obj-type, temp-cpdisc.obj-code) temp-cpdisc.rule-num temp-cpdisc.rl-root {&cd-type-name}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-cp
&Scoped-define SELF-NAME BR-dis-cp
&Scoped-define QUERY-STRING-BR-dis-cp FOR EACH temp-cpdisc NO-LOCK
&Scoped-define OPEN-QUERY-BR-dis-cp OPEN QUERY {&SELF-NAME} FOR EACH temp-cpdisc NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-dis-cp temp-cpdisc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-cp temp-cpdisc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-dis-cp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-ins b-lkp b-chg b-del b-help ~
v-obj-name cd-cdpay-code cd-curr-code
&Scoped-Define DISPLAYED-OBJECTS v-obj-name cd-cdpay-code cd-curr-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-ins
       MENU-ITEM m_pos-type     LABEL "m_pos-type"
       MENU-ITEM m_bo           LABEL "Бэкофис"      .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить скидку на платеж".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить скидку на платеж".

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить скидку на платеж".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 10 BY 1 TOOLTIP "Просмотр скидки на платеж".

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".

DEFINE VARIABLE cd-cdpay-code AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "Код типа платежа"
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE cd-curr-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код валюты"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 55 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dis-cp FOR
      temp-cpdisc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-cp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-cp Dialog-Frame _FREEFORM
  QUERY BR-dis-cp DISPLAY
      temp-cpdisc.templ-rl-root COLUMN-LABEL "" FORMAT ">9":U
discpru-get-disc-label(temp-cpdisc.templ-rl-root) COLUMN-LABEL "Тип скидки" FORMAT "X(50)":U
get-region(temp-cpdisc.host-code, temp-cpdisc.obj-type, temp-cpdisc.obj-code) COLUMN-LABEL "Действует" FORMAT "X(12)":U
    WIDTH 13
temp-cpdisc.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
temp-cpdisc.rl-root COLUMN-LABEL "№ корн.!правила" FORMAT ">>>>>>>>9":U
{&cd-type-name} FORMAT "X(20)":U COLUMN-LABEL "Место использ."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-lkp AT ROW 1 COL 31
     b-chg AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     b-help AT ROW 1 COL 95
     BR-dis-cp AT ROW 4.47 COL 1
     v-obj-name AT ROW 2 COL 2.5 NO-LABEL
     cd-cdpay-code AT ROW 3.27 COL 2.5
     cd-curr-code AT ROW 3.27 COL 33.5
     SPACE(47.59) SKIP(15.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки на платеж".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-cpdisc T "?" NO-UNDO ub dis-cp-rule
      ADDITIONAL-FIELDS:
          field rule-label as character
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dis-cp b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-ins:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-ins:HANDLE.

/* SETTINGS FOR BROWSE BR-dis-cp IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cd-cdpay-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN cd-curr-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN v-obj-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-cp
/* Query rebuild information for BROWSE BR-dis-cp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-cpdisc NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-dis-cp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Скидки на платеж */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  if not avail temp-cpdisc then return no-apply.
  run proc-add-chg in this-procedure ( input no, input temp-cpdisc.pos-type) no-error .
  if error-status:error then return no-apply.
  RUN init-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable v-deleted as logical no-undo.
define variable loc#log as logical no-undo .
define variable v-rule-label as character no-undo .
  if not avail temp-cpdisc then return no-apply.
    run discpru-name in this-procedure
      (input  temp-cpdisc.templ-rl-root        /* p-templ-rl-root           */
      ,output v-rule-label          /* p-label          */
      ) no-error .
    if error-status :error then do:
      return no-apply .
    end.
  loc#log = no.
&scop cd-type-code temp-cpdisc.pos-type
  message
  substitute("Вы уверены, что хотите удалить скидку &1 (POS &2) на фирме &3 &4&5 для платежа"
           ,v-rule-label
           ,{&cd-type-name}
           ,temp-cpdisc.host-code
           ,temp-cpdisc.obj-type
           ,temp-cpdisc.obj-code
           )
          view-as alert-box QUESTIOn buttons YES-NO update loc#log.
  if NOT loc#log then return no-apply.
  run discpru-delete in this-procedure(
                                   input p-cdpay-code
                                  ,input p-curr-code
                                  ,input temp-cpdisc.host-code
                                  ,input temp-cpdisc.obj-type
                                  ,input temp-cpdisc.obj-code
                                  ,input temp-cpdisc.pos-type
                                  ,input temp-cpdisc.discnt-role
                                  ,input temp-cpdisc.nonunique
                                  ,output v-deleted
                                  ) no-error .
  if error-status:error then do:
    return no-apply.
  end.
  delete temp-cpdisc.
  updated = yes.
  run init-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ins
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ins Dialog-Frame
ON CHOOSE OF b-ins IN FRAME Dialog-Frame /* Добавить */
DO:
 if add-option = '':U then do:
       run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if add-option = '':U then return no-apply.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF not AVAILABLE temp-cpdisc then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход  */
DO:
/*
  for each temp-cpdisc no-lock:
    run cp-attr-write in this-procedure (
                                    input p-cdpay-code
                                    ,input p-curr-code
                                    ,input temp-cpdisc.host-code
                                    ,input temp-cpdisc.obj-type
                                    ,input temp-cpdisc.obj-code
                                    ,input add-option
                                    ,input temp-cpdisc.attr-value)  no-error.
    updated = yes.
  End.
  */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-cp
&Scoped-define SELF-NAME BR-dis-cp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dis-cp Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-dis-cp IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-cpdisc then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dis-cp Dialog-Frame
ON RETURN OF BR-dis-cp IN FRAME Dialog-Frame
DO:
  IF not AVAILABLE temp-cpdisc then return no-apply.
  RUN proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dis-cp Dialog-Frame
ON VALUE-CHANGED OF BR-dis-cp IN FRAME Dialog-Frame
DO:
  IF v-cntxt-db-num > 0
  AND (temp-cpdisc.obj-type = {&cmp}
  OR temp-cpdisc.obj-type = '':U) THEN DO:
     DISABLE
     b-chg
     with FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
      enable
      b-chg WHEN (p-mode <> {&lookup})
      with FRAME {&FRAME-NAME}.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_pos-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_pos-type Dialog-Frame
ON CHOOSE OF MENU-ITEM m_pos-type /* m_pos-type */
DO:
    add-option = dflt-cd.
  run proc-add-chg in this-procedure ( input yes, input add-option ) no-error.
  if error-status:error then do:
    add-option = '':U.
    return no-apply.
  end.
  add-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
 { gbl/app_help.i }

 frame {&frame-name}:TITLE = frame {&frame-name}:TITLE.
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if v-cntxt-db-num = 0 then do:
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_сp-discount_global_work':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      false
      loc-glob
      }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_cp-discount_firm_work':U
      {&cntxt-firm}
      p-host-code
      '':U
      0
      0
      0
      0
      false
      loc-firm
      }

   end.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_cp-discount_object_work':U
      {&cntxt-object}
      p-host-code
      p-obj-type
      p-obj-code
      0
      0
      0
      false
      loc-object
    }
  if ((if v-cntxt-db-num = 0 and loc-glob then 1 else 0) +
  (if v-cntxt-db-num = 0 and loc-firm then 1 else 0) +
  (if loc-object then 1 else 0)) = 0 then do:
    message
    "У Вас отсутствуют права на назначение скидки на тип платежа как по объекту, так и по фирме и глобально" skip
    "либо Вы находитесь в БД, в которой их назначить невозможно"
    view-as alert-box error .
    undo, return.
  end.

  RUN MyEnable in this-procedure no-error.
  if error-status:error then return error.
  Run init-proc in this-procedure .
  view frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
if updated then return {&update}.

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
  DISPLAY v-obj-name cd-cdpay-code cd-curr-code
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-lkp b-chg b-del b-help v-obj-name cd-cdpay-code
         cd-curr-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
define variable v-rule-label as character no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
for each temp-cpdisc:
  if p-mode = {&update}
  and (temp-cpdisc.obj-type = p-obj-type
    and
    temp-cpdisc.obj-code = p-obj-code)
  or (v-cntxt-db-num = 0
    and temp-cpdisc.obj-type = '':U
    and
    temp-cpdisc.obj-code = 0)
  or (v-cntxt-db-num = 0
    and temp-cpdisc.obj-type = {&cmp}
    and temp-cpdisc.obj-code = p-host-code)
    then do:
  end.
  else do:
    delete temp-cpdisc.
  end.
end.

add-option = "".

find first buf_cash-pay where
        buf_cash-pay.cdpay-code =  p-cdpay-code
    AND buf_cash-pay.curr-code = p-curr-code   no-lock no-error .

Assign
cd-cdpay-code = buf_cash-pay.cdpay-code
cd-curr-code = buf_cash-pay.curr-code
.
display
cd-cdpay-code
cd-curr-code
with frame {&frame-name}  .

For each buf_dis-cp-rule where
        buf_dis-cp-rule.cdpay-code  = p-cdpay-code
    and  buf_dis-cp-rule.curr-code  = p-curr-code no-lock
on error undo, return error
    :

  find first temp-cpdisc where
            temp-cpdisc.cdpay-code = buf_dis-cp-rule.cdpay-code
       and  temp-cpdisc.curr-code = buf_dis-cp-rule.curr-code
       and  temp-cpdisc.host-code = buf_dis-cp-rule.host-code
       and  temp-cpdisc.obj-type = buf_dis-cp-rule.obj-type
       and  temp-cpdisc.obj-code = buf_dis-cp-rule.obj-code
       and  temp-cpdisc.pos-type = buf_dis-cp-rule.pos-type
       and  temp-cpdisc.discnt-role = buf_dis-cp-rule.discnt-role
       and  temp-cpdisc.nonunique = buf_dis-cp-rule.nonunique no-error.
  if not available temp-cpdisc then do:
    create temp-cpdisc.
    assign
    temp-cpdisc.cdpay-code = buf_dis-cp-rule.cdpay-code
    temp-cpdisc.curr-code = buf_dis-cp-rule.curr-code
    temp-cpdisc.host-code = buf_dis-cp-rule.host-code
    temp-cpdisc.obj-type = buf_dis-cp-rule.obj-type
    temp-cpdisc.obj-code = buf_dis-cp-rule.obj-code
    temp-cpdisc.pos-type = buf_dis-cp-rule.pos-type
    temp-cpdisc.discnt-role = buf_dis-cp-rule.discnt-role
    temp-cpdisc.nonunique = buf_dis-cp-rule.nonunique
    .
  end.
  assign
  temp-cpdisc.rule-num = buf_Dis-cp-rule.rule-num
  temp-cpdisc.rl-root = buf_Dis-cp-rule.rl-root
  temp-cpdisc.templ-rl-root = buf_Dis-cp-rule.templ-rl-root
  temp-cpdisc.time-templ-rl-root = buf_Dis-cp-rule.time-templ-rl-root
  .
  run discpru-name ( input buf_dis-cp-rule.templ-rl-root
                      ,output v-rule-label
                        ).
  assign
  temp-cpdisc.rule-label = v-rule-label
  .
End.   /* FOR EACH */
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE BUFFER buf_Cash-pay FOR ub.cash-pay.
DEFINE VARIABLE v-h AS WIDGET-HANDLE NO-UNDO.
v-h = br-dis-cp:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&label-clmn_2} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
IF p-obj-type = {&shop} THEN DO:
  { gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
END.
if p-obj-type = {&stock} then do:
  dflt-cd = {&cd-type-no-cd}.
end.
ASSIGN
b-ins:POPUP-MENU IN FRAME {&frame-name} = MENU MENU-b-ins:HANDLE
b-ins:MENU-MOUSE = 1
MENU-ITEM m_pos-type:LABEL IN MENU menu-b-ins  = dflt-cd
MENU-ITEM m_pos-type:sensitive IN MENU menu-b-ins  = ((dflt-cd <> '':U) and (dflt-cd <> {&cd-type-no-cd}))
MENU-ITEM m_bo:sensitive IN MENU menu-b-ins  = no
.
assign
v-tab-order = "b-quit,b-ins,b-lkp,b-chg,b-del,b-help,br-dis-cp".

FIND FIRST buf_Cash-pay NO-LOCK WHERE
            buf_Cash-pay.cdpay-code = p-cdpay-code
      AND   buf_Cash-pay.curr-code = p-curr-code NO-ERROR.
IF AVAILABLE buf_cash-pay THEN DO:
    ASSIGN
    v-obj-name = buf_cash-pay.obj-name.
END.
ASSIGN b-ins:MENU-MOUSE in frame {&frame-name}  = 1.

DISPLAY
v-obj-name
WITH FRAME {&frame-name} .
ENABLE
b-quit
b-del when p-mode = {&update}
b-ins when p-mode = {&update}
b-chg when p-mode = {&update}
b-lkp
b-help BR-dis-cp
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" to br-dis-cp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-chg Dialog-Frame
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define input parameter p-pos-type as character no-undo .
define variable v-rule-label as character no-undo .         /*лабел атрибута */
DEFINE VARIABLE v-rule-num as integer no-undo .
define variable v-setted as logical no-undo .
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-templ-rl-root as integer no-undo .
define variable v-time-templ-rl-root as integer no-undo .
define variable v-cfg-nonunique as character no-undo .
define variable v-nonunique as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_temp-cpdisc for temp-cpdisc.


DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-obj-type like ub.clients.obj-type no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define variable v-ask-labels as character no-undo .
define variable choice as integer no-undo .
define variable v-discnt-role as character no-undo .


define var loc#log as logical no-undo.
CASE p-add:
  when yes then do:
    run ref/dis-pos.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "cd-type-list"
                        ,INPUT (if v-cntxt-db-num = 0 and loc-glob  then 1 else 0)
                        ,INPUT (if v-cntxt-db-num = 0 and loc-firm  then 1 else 0)
                        ,INPUT (if loc-object then 1 else 0)
                        ,input {&table_dis-cp-rule}
                        ,input '':U
                        ,input ?
                        ,INPUT p-pos-type
                        ,input '':U
                        ,INPUT-OUTPUT v-rid-list) NO-ERROR.
   IF ERROR-STATUS:ERROR
   OR v-rid-list = '':U THEN DO:
      RETURN.
   END.
   FIND FIRST buf_dis-cfg-rule NO-LOCK where
             recid(buf_dis-cfg-rule) = INTEGER(v-rid-list).
    assign
    v-templ-rl-root = buf_dis-cfg-rule.templ-rl-root
    v-time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
    V-cfg-NONUNIQUE = buf_dis-cfg-rule.nonunique
    v-discnt-role = buf_dis-cfg-rule.discnt-role
    .

    assign
    added = yes.
    v-rule-num = 0.
   if (buf_dis-cfg-rule.has-global +
       buf_dis-cfg-rule.has-host +
       buf_dis-cfg-rule.has-obj) > 1 then do:
      /*надо выбрать todo*/
      define variable v-sel-vals as character no-undo .
      define variable v-sel-labels as character no-undo .
      define variable var-region as character no-undo .
      assign
      v-sel-vals = v-sel-vals +
                    (if buf_dis-cfg-rule.has-global = 1
                    then (fill({&space-char}, 3)  + string(0) + {&comma-char})
                    else "":U)
      v-sel-labels = v-sel-labels +
                    (if buf_dis-cfg-rule.has-global  = 1
                    then ("Глобально" + {&comma-char})
                    else "":U)
      .
      assign
      v-sel-vals = v-sel-vals +
                    (if buf_dis-cfg-rule.has-host = 1
                    then ({&cmp}  + string(v-cntxt-host-code-obj)  + {&comma-char})
                    else "":U)
      v-sel-labels = v-sel-labels +
                    (if buf_dis-cfg-rule.has-host = 1
                    then ("Фирма"  + string(v-cntxt-host-code-obj) + {&comma-char})
                    else "":U)
      .
      assign
      v-sel-vals = v-sel-vals +
                    (if buf_dis-cfg-rule.has-obj = 1
                    then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + {&comma-char})
                    else "":U)
      v-sel-labels = v-sel-labels +
                    (if buf_dis-cfg-rule.has-obj = 1
                    then (v-cntxt-obj-type  + string(v-cntxt-obj-code)  + {&comma-char})
                    else "":U)
      .
      run gbl/d-list.w (
                          input "b-sel":U
                          ,input "Выберите область действия"
                          ,input v-sel-vals
                          ,input v-sel-labels
                          ,input {&comma-char}
                          ,input "":U
                          ,output var-region) no-error.
      if error-status:error then do:
        return error.
      end.
      assign
      v-obj-type = trim(substring(var-region, 1, 3))
      v-obj-code = integer(substring(var-region, 4))
      v-host-code = (if var-region begins {&cmp}
                     then integer(substring(var-region, 4))
                     else 0)
      v-obj-code = (if v-obj-type = {&cmp} then 0 else v-obj-code)
      v-obj-type = (if v-obj-type = {&cmp} then "" else v-obj-type)
    /*нам надо переконверитить из "   0" (глобально)  или "орг1" или "маг20" переконвертить к виду
    0 "" 0
    1 "" 0
    1 "маг" 20
    */.
      if v-host-code = 0
       and v-obj-type <> '':U then do:
        { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
      end.
    end.
    else do:
      if buf_dis-cfg-rule.has-obj = 1 then do:
        assign
        v-obj-type = p-obj-type
        v-obj-code = p-obj-code
        .
        { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
      end.
      if buf_dis-cfg-rule.has-host = 1 then do:
        { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
        assign
        v-obj-type = ""
        v-obj-code = 0
        .
      end.
      if buf_dis-cfg-rule.has-glob = 1 then do:
        assign
        v-host-code = 0
        v-obj-type = '':U
        v-obj-code = 0
        .
      end.
    end.
  end. /*when add*/
  when no then do:
        find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.table-name = {&table_dis-cp-rule}
          and buf_dis-cfg-rule.discnt-role = temp-cpdisc.discnt-role
          and buf_dis-cfg-rule.pos-type = temp-cpdisc.pos-type
          no-error .
    if available buf_dis-cfg-rule then do:
      assign
      v-nonunique = buf_dis-cfg-rule.nonunique.
    end.
    v-rule-num  = temp-cpdisc.rule-num.

  end. /*when chg*/
END CASE.
run discpru-edit in this-procedure (   input (if p-add then {&add-def} else {&update})
                                      ,input p-cdpay-code
                                      ,input p-curr-code
                                      ,input (if p-add then v-host-code else temp-cpdisc.host-code)
                                      ,input (if p-add then v-obj-type  else temp-cpdisc.obj-type)
                                      ,input (if p-add then v-obj-code  else temp-cpdisc.obj-code)
                                      ,INPUT (if p-add then p-pos-type else temp-cpdisc.pos-type)
                                      ,INPUT (if p-add then v-discnt-role else temp-cpdisc.discnt-role)
                                      ,input (if p-add then v-templ-rl-root else temp-cpdisc.templ-rl-root)
                                      ,input (if p-add then v-time-templ-rl-root else temp-cpdisc.time-templ-rl-root)
                                      ,input v-cfg-nonunique
                                      ,input 1
                                      ,input-output v-rule-num
                                      ,input-output v-nonunique
                                      ,output v-setted ) no-error.
if not v-setted then return error.
run discpru-write in this-procedure (
                                        input p-cdpay-code
                                        ,input p-curr-code
                                        ,input (if p-add then v-host-code else temp-cpdisc.host-code)
                                        ,input (if p-add then v-obj-type else temp-cpdisc.obj-type)
                                        ,input (if p-add then v-obj-code else temp-cpdisc.obj-code)
                                        ,input (if p-add then add-option else temp-cpdisc.pos-type)
                                        ,input (if p-add then v-discnt-role else temp-cpdisc.discnt-role)
                                        ,input (if p-add then v-templ-rl-root else temp-cpdisc.templ-rl-root)
                                        ,input (if p-add then v-time-templ-rl-root else temp-cpdisc.time-templ-rl-root)
                                        ,input v-rule-num
                                        ,input v-nonunique
                                      ) no-error .
  IF NOT error-status:error then do:
      assign
      updated = yes
      .
  END.
Run init-proc in this-procedure .

find first buf_temp-cpdisc no-lock where
          buf_temp-cpdisc.host-code =  (if p-add then v-host-code else temp-cpdisc.host-code)
      AND buf_temp-cpdisc.obj-type = (if p-add then v-obj-type else temp-cpdisc.obj-type)
      AND buf_temp-cpdisc.obj-code = (if p-add then v-obj-code else temp-cpdisc.obj-code)
      AND buf_temp-cpdisc.pos-type = (if p-add then add-option else temp-cpdisc.pos-type)
      AND buf_temp-cpdisc.pos-type = (if p-add then add-option else temp-cpdisc.pos-type)
      AND buf_temp-cpdisc.discnt-role = (if p-add then v-discnt-role else temp-cpdisc.discnt-role)
      AND buf_temp-cpdisc.nonunique = (if p-add then v-nonunique else temp-cpdisc.nonunique)
      no-error.
add-option = "":U.
if avail buf_temp-cpdisc then
temp-doc-rec = recid(buf_temp-cpdisc).
else temp-doc-rec = ?.
reposition BR-dis-cp to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
define variable disc-label as character no-undo .         /*лабел скидки*/

run discpru-name in this-procedure (
                                      input temp-cpdisc.templ-rl-root
                                    , output disc-label
                                ) no-error.
IF ERROR-STATUS:ERROR THEN DO:
    {&disgdsru-type-get-error}
    return error.
END.
run ref/show-dr.p ( input parparentproc
                   ,input temp-cpdisc.rule-num) no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME